// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_redox/otel_redox.dart';

/// Traces Redox calls with OpenTelemetry.
///
/// `otel_redox` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Redox call in
/// [tracedRedox]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'redox-example');

  // Wraps a Redox API call in a CLIENT span.
  final redoxId = await tracedRedox<String>(
    operation: 'subscription.create',
    invoke: () async {
      // Make the Redox call here, then report what it returned.
      const id = 'redox_8f3a2c';
      return const RedoxCallResult(
          value: id,
          result: RedoxResult(
              destinationName: 'example',
              destinationId: 'destination_8f3a2c',
              dataModel: 'PatientAdmin',
              eventType: 'New',
              fhirResourceType: 'Patient',
              fhirId: 'fhir_8f3a2c',
              fhirVersion: 'R4',
              patientId: 'patient_8f3a2c',
              encounterId: 'encounter_8f3a2c',
              orderId: 'order_8f3a2c',
              documentId: 'document_8f3a2c',
              fhirBundleEntryCount: 3,
              organizationId: 'organization_8f3a2c',
              endpointType: 'data_on_demand',
              subscriptionId: 'subscription_8f3a2c',
              responseTimeMs: 120,
              errorCode: 'example',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedRedox subscription.create returned $redoxId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutRedoxInstrumentationAsync.
  await runWithoutRedoxInstrumentationAsync(
    () => tracedRedox<String>(
      operation: 'subscription.create',
      invoke: () async {
        const id = 'redox_8f3a2c';
        return const RedoxCallResult(
            value: id,
            result: RedoxResult(
                destinationName: 'example',
                destinationId: 'destination_8f3a2c',
                dataModel: 'PatientAdmin',
                eventType: 'New',
                fhirResourceType: 'Patient',
                fhirId: 'fhir_8f3a2c',
                fhirVersion: 'R4',
                patientId: 'patient_8f3a2c',
                encounterId: 'encounter_8f3a2c',
                orderId: 'order_8f3a2c',
                documentId: 'document_8f3a2c',
                fhirBundleEntryCount: 3,
                organizationId: 'organization_8f3a2c',
                endpointType: 'data_on_demand',
                subscriptionId: 'subscription_8f3a2c',
                responseTimeMs: 120,
                errorCode: 'example',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
