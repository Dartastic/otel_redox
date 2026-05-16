// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_redox/otel_redox.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(serviceName: 'otel_redox-test');
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('fhir.read records resource type + bundle entry count', () async {
    await tracedRedox<String>(
      operation: 'fhir.search',
      invoke: () async => const RedoxCallResult(
        value: 'ok',
        result: RedoxResult(
          destinationName: 'EpicProd',
          fhirResourceType: 'Patient',
          fhirVersion: 'R4',
          fhirBundleEntryCount: 12,
          responseTimeMs: 380,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('redox fhir.search')!);
    expect(a['redox.fhir.resource_type'], 'Patient');
    expect(a['redox.fhir.bundle.entry_count'], 12);
  });

  test('legacy.results.new records data model + event type', () async {
    await tracedRedox<String>(
      operation: 'legacy.results.new',
      invoke: () async => const RedoxCallResult(
        value: 'ok',
        result: RedoxResult(
          dataModel: 'Results',
          eventType: 'New',
          patientId: 'p_1',
          orderId: 'o_1',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('redox legacy.results.new')!);
    expect(a['redox.data_model'], 'Results');
    expect(a['redox.event_type'], 'New');
  });

  test('error sets span error', () async {
    await tracedRedox<String>(
      operation: 'dispatch.send',
      invoke: () async => const RedoxCallResult(
        value: 'ok',
        result: RedoxResult(
          errorCode: 'destination_offline',
          statusCode: 503,
        ),
      ),
    );
    expect(
      spans.findSpanByName('redox dispatch.send')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutRedoxInstrumentationAsync(() async {
      await tracedRedox<String>(
        operation: 'auth.token',
        invoke: () async => const RedoxCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('redox '), isEmpty);
  });
}
