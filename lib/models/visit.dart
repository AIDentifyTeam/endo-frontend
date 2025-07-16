class Visit {
  final int id;
  final String caseId;
  final int patient;
  final String visitDate;
  final String toothNumber;
  final Map<String, dynamic> answers;
  final String pulpDiagnosis;
  final String periapicalDisease;
  final String etiology;

  Visit({
    required this.id,
    required this.caseId,
    required this.patient,
    required this.visitDate,
    required this.toothNumber,
    required this.answers,
    required this.pulpDiagnosis,
    required this.periapicalDisease,
    required this.etiology,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      caseId: json['case_id'] ?? '',
      patient: json['patient'],
      visitDate: json['visit_date'],
      toothNumber: json['tooth_number'],
      answers: Map<String, dynamic>.from(json['answers']),
      pulpDiagnosis: json['pulp_diagnosis'],
      periapicalDisease: json['periapical_disease'],
      etiology: json['etiology'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient': patient,
      'visit_date': visitDate,
      'tooth_number': toothNumber,
      'answers': answers,
      'pulp_diagnosis': pulpDiagnosis,
      'periapical_disease': periapicalDisease,
      'etiology': etiology,
    };
  }
}
