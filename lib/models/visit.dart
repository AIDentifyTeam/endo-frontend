import 'dart:convert';

class Visit {
  final int id;
  final String caseId;
  final int patient;
  final String visitDate;
  final String toothNumber;
  final Map<String, dynamic> answers;

  // These can be null from the API
  final String? pulpDiagnosis;
  final String? periapicalDisease;
  final String? etiology;

  Visit({
    required this.id,
    required this.caseId,
    required this.patient,
    required this.visitDate,
    required this.toothNumber,
    required this.answers,
    this.pulpDiagnosis,
    this.periapicalDisease,
    this.etiology,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    String? _nn(dynamic v) =>
        (v == null || v.toString().trim().isEmpty) ? null : v.toString().trim();

    int _asInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

    String _asString(dynamic v) => v?.toString() ?? '';

    // answers may be a Map, a Stringified JSON, or null
    final rawAnswers = json['answers'];
    Map<String, dynamic> parsedAnswers = {};
    if (rawAnswers is Map) {
      parsedAnswers = Map<String, dynamic>.from(rawAnswers);
    } else if (rawAnswers is String && rawAnswers.isNotEmpty) {
      try {
        parsedAnswers = Map<String, dynamic>.from(jsonDecode(rawAnswers));
      } catch (_) {
        parsedAnswers = {};
      }
    }

    return Visit(
      id: _asInt(json['id']),
      caseId: _asString(json['case_id']),
      patient: _asInt(json['patient']),
      visitDate: _asString(json['visit_date']),
      toothNumber: _asString(json['tooth_number']),
      answers: parsedAnswers,
      pulpDiagnosis: _nn(json['pulp_diagnosis']),
      periapicalDisease: _nn(json['periapical_disease']),
      etiology: _nn(json['etiology']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'case_id': caseId,
      'patient': patient,
      'visit_date': visitDate,
      'tooth_number': toothNumber,
      'answers': answers,
      'pulp_diagnosis': pulpDiagnosis,
      'periapical_disease': periapicalDisease,
      'etiology': etiology,
    };
    // Remove nulls so DRF receives only set fields
    map.removeWhere((_, v) => v == null);
    return map;
  }
}
