class DiagnosisQuestion {
  final String id;
  final String title;
  final String text;
  final String help;
  final List<String> options;
  final bool isOptional;

  const DiagnosisQuestion({
    required this.id,
    required this.title,
    required this.text,
    required this.help,
    required this.options,
    this.isOptional = false,
  });
}

final List<DiagnosisQuestion> diagnosisQuestions = [
  DiagnosisQuestion(
    id: 'chief_complaint',
    title: 'Chief Complaint',
    text: 'Is there any chief complaint related to this tooth?',
    help: 'This determines whether the diagnostic workflow should proceed. If "No", the logic skips the rest of the questions.',
    options: ['Yes', 'No'],
  ),
  DiagnosisQuestion(
    id: 'etiology_assessment',
    title: 'Etiology Assessment',
    text: 'What do you suspect as the cause of the current condition?',
    help: 'You can select multiple causes. If you are not sure, select "Not sure". This affects all potential etiology outputs.',
    options: [
      'Caries',
      'Restorative',
      'Trauma',
      'Crack',
      'Vertical root fracture',
      'Periodontal',
      'Persistent infection',
      'Not sure'
    ],
  ),
  DiagnosisQuestion(
    id: 'endo_history',
    title: 'Endodontic Treatment History',
    text: 'What is the history of endodontic treatment on the tooth?',
    help: 'Determine if the tooth has been previously treated, partially treated, or never treated with endodontic therapy.',
    options: [
      'No previous endodontics treatment',
      'Previously initiated',
      'Previously treated',
    ],
  ),
  DiagnosisQuestion(
    id: 'cold_test',
    title: 'Cold Test',
    text: 'How does the patient respond to cold stimulus on the affected tooth?',
    help: 'Apply refrigerant spray or Endo-Ice. Lingering or exaggerated response suggests irreversible pulpitis.',
    options: ['Negative', 'Normal', 'Hypersensitive', 'Lingering Pain'],
  ),
  DiagnosisQuestion(
    id: 'heat_test',
    title: 'Heat Test',
    text: 'How does the patient respond to heat stimulus?',
    help: 'A positive lingering response to heat may also indicate irreversible pulpitis.',
    options: ['Negative', 'Normal', 'Hypersensitive', 'Lingering Pain'],
    isOptional: true,
  ),
  DiagnosisQuestion(
    id: 'ept',
    title: 'Electric Pulp Test (EPT)',
    text: 'What is the pulp response to EPT?',
    help: 'Dry the tooth, apply conductor paste, and test. No response may indicate pulp necrosis.',
    options: ['Negative', 'Positive'],
    isOptional: true,
  ),
  DiagnosisQuestion(
    id: 'palpation',
    title: 'Palpation Test',
    text: 'Is there tenderness on palpation of the periapical area?',
    help: 'Apply gentle pressure on the root apex. Sensitivity suggests periapical inflammation.',
    options: ['Negative', 'Positive'],
  ),
  DiagnosisQuestion(
    id: 'percussion',
    title: 'Percussion Test',
    text: 'Does the patient feel pain when the tooth is tapped (vertically)?',
    help: 'Pain may indicate inflammation of the periodontal ligament or apical tissues.',
    options: ['Negative', 'Positive'],
  ),
  DiagnosisQuestion(
    id: 'bite_test',
    title: 'Bite Test',
    text: 'Does the patient feel pain when biting on a tooth slooth or cotton roll?',
    help: 'Useful for diagnosing cracked tooth syndrome or apical involvement.',
    options: ['Negative', 'Positive'],
  ),
  DiagnosisQuestion(
    id: 'swelling',
    title: 'Swelling',
    text: 'Is there any visible or palpable swelling?',
    help: 'May indicate a spreading infection requiring immediate intervention.',
    options: ['Negative', 'Positive'],
  ),
  DiagnosisQuestion(
    id: 'sinus_tract',
    title: 'Sinus Tract',
    text: 'Is a sinus tract present upon clinical inspection?',
    help: 'A draining fistula indicates chronic periapical abscess.',
    options: ['Negative', 'Positive'],
  ),
  DiagnosisQuestion(
    id: 'mobility',
    title: 'Tooth Mobility',
    text: 'What is the grade of mobility observed in the tooth?',
    help: 'Mobility may suggest periodontal involvement or trauma.',
    options: ['None', 'Mild', 'Moderate', 'Severe'],
    isOptional: true,
  ),
  DiagnosisQuestion(
    id: 'radiographic_findings',
    title: 'Radiographic Findings',
    text: 'What does the periapical radiograph reveal?',
    help: 'Evaluate periapical radiolucency, PDL widening, resorption, etc.',
    options: [
      'No abnormal findings',
      'PDL widening',
      'Periapical radiolucency',
      'External resorption',
      'Internal resorption',
      'Condensing osteitis',
      'Root fracture'
    ],
  ),
];
