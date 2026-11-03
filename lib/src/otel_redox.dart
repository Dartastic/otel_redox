// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_redox_suppression.dart';

const _tracerName = 'dartastic_otel_libs_redox';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class RedoxResult {
  /// Creates a result.
  const RedoxResult({
    this.destinationName,
    this.destinationId,
    this.dataModel,
    this.eventType,
    this.fhirResourceType,
    this.fhirId,
    this.fhirVersion,
    this.patientId,
    this.encounterId,
    this.orderId,
    this.documentId,
    this.fhirBundleEntryCount,
    this.organizationId,
    this.endpointType,
    this.subscriptionId,
    this.responseTimeMs,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  final String? destinationName;
  final String? destinationId;

  /// Redox legacy data model:
  /// `PatientAdmin`, `Scheduling`, `Order`, `Results`, `Notes`,
  /// `Vaccination`, `Media`, `Inventory`, `Device`, `Claim`,
  /// `Financial`, `PatientEducation`, `PatientSearch`, `Referral`,
  /// `Clinical Summary`, `Carepath`, `Flowsheet`, `SurgicalScheduling`,
  /// `Quality`, `SSO`.
  final String? dataModel;

  /// Redox event type (`New`, `Update`, `Cancel`, `Reschedule`,
  /// `Discharge`, `Arrival`, `Departure`, `Transcription`, `Resulted`,
  /// `Preliminary`, `Corrected`, `Modified`).
  final String? eventType;

  /// FHIR resource type when using Redox's FHIR endpoints
  /// (`Patient`, `Encounter`, `Observation`, `Condition`, `Procedure`,
  /// `MedicationRequest`, `DocumentReference`, `DiagnosticReport`,
  /// `AllergyIntolerance`, `Immunization`, `CareTeam`, `CarePlan`,
  /// `Coverage`, `Bundle`).
  final String? fhirResourceType;
  final String? fhirId;

  /// `R4`, `DSTU2`, `STU3`.
  final String? fhirVersion;

  final String? patientId;
  final String? encounterId;
  final String? orderId;
  final String? documentId;

  /// Number of `entry` items in a FHIR Bundle.
  final int? fhirBundleEntryCount;

  final String? organizationId;

  /// `data_on_demand`, `subscription`, `dispatch`.
  final String? endpointType;

  final String? subscriptionId;
  final int? responseTimeMs;

  /// Redox error code (numeric or descriptive).
  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class RedoxCallResult<T> {
  /// Creates a call result.
  const RedoxCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final RedoxResult? result;
}

/// Wraps a Redox API call in a CLIENT span. [operation] is one of
/// `auth.token`, `auth.refresh`, `dispatch.send`,
/// `dataOnDemand.query`, `subscription.list`, `subscription.create`,
/// `subscription.delete`, `fhir.read`, `fhir.search`, `fhir.create`,
/// `fhir.update`, `fhir.patch`, `fhir.delete`, `fhir.bundle`,
/// `fhir.everything`, `fhir.member-match`, `legacy.patientAdmin.new`,
/// `legacy.patientAdmin.update`, `legacy.results.new`,
/// `legacy.order.new`, `legacy.scheduling.new`,
/// `legacy.scheduling.reschedule`, `legacy.notes.new`,
/// `legacy.financial.new`, `legacy.media.new`, `legacy.referral.new`.
Future<T> tracedRedox<T>({
  required String operation,
  required Future<RedoxCallResult<T>> Function() invoke,
}) async {
  if (redoxInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'redox',
    'rpc.method': operation,
    'redox.operation': operation,
  };

  final span = _tracer().startSpan(
    'redox $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.destinationName != null) {
        extras.add(OTelAPI.attributeString(
          'redox.destination.name',
          res.destinationName!,
        ));
      }
      if (res.destinationId != null) {
        extras.add(OTelAPI.attributeString(
          'redox.destination.id',
          res.destinationId!,
        ));
      }
      if (res.dataModel != null) {
        extras.add(OTelAPI.attributeString(
          'redox.data_model',
          res.dataModel!,
        ));
      }
      if (res.eventType != null) {
        extras.add(OTelAPI.attributeString(
          'redox.event_type',
          res.eventType!,
        ));
      }
      if (res.fhirResourceType != null) {
        extras.add(OTelAPI.attributeString(
          'redox.fhir.resource_type',
          res.fhirResourceType!,
        ));
      }
      if (res.fhirId != null) {
        extras.add(OTelAPI.attributeString('redox.fhir.id', res.fhirId!));
      }
      if (res.fhirVersion != null) {
        extras.add(OTelAPI.attributeString(
          'redox.fhir.version',
          res.fhirVersion!,
        ));
      }
      if (res.patientId != null) {
        extras.add(OTelAPI.attributeString('redox.patient.id', res.patientId!));
      }
      if (res.encounterId != null) {
        extras.add(OTelAPI.attributeString(
          'redox.encounter.id',
          res.encounterId!,
        ));
      }
      if (res.orderId != null) {
        extras.add(OTelAPI.attributeString('redox.order.id', res.orderId!));
      }
      if (res.documentId != null) {
        extras.add(OTelAPI.attributeString(
          'redox.document.id',
          res.documentId!,
        ));
      }
      if (res.fhirBundleEntryCount != null) {
        extras.add(OTelAPI.attributeInt(
          'redox.fhir.bundle.entry_count',
          res.fhirBundleEntryCount!,
        ));
      }
      if (res.organizationId != null) {
        extras.add(OTelAPI.attributeString(
          'redox.organization.id',
          res.organizationId!,
        ));
      }
      if (res.endpointType != null) {
        extras.add(OTelAPI.attributeString(
          'redox.endpoint.type',
          res.endpointType!,
        ));
      }
      if (res.subscriptionId != null) {
        extras.add(OTelAPI.attributeString(
          'redox.subscription.id',
          res.subscriptionId!,
        ));
      }
      if (res.responseTimeMs != null) {
        extras.add(OTelAPI.attributeInt(
          'redox.response_time_ms',
          res.responseTimeMs!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTelAPI.attributeString('redox.error.code', res.errorCode!));
        span.setStatus(SpanStatusCode.Error, 'Redox ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTelAPI.attributeString(
          'redox.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(SpanStatusCode.Error, 'Redox HTTP ${res.statusCode}');
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
