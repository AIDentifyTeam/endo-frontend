class DiagnosisQuestion {
  final String id;
  final String title;
  final String text;
  final String help;
  final List<String> options;

  DiagnosisQuestion({
    required this.id,
    required this.title,
    required this.text,
    required this.help,
    required this.options,
  });
}

final List<DiagnosisQuestion> diagnosisQuestions = [
  DiagnosisQuestion(
    id: 'endo_history',
    title: 'Endodontic Treatment History',
    text: 'What is the history of endodontic treatment on the tooth?',
    help: 'Determine if the tooth has been previously treated, partially treated, or never treated with endodontic therapy. This helps assess prior interventions and guide current diagnosis.',
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
    help: 'Apply refrigerant spray or Endo-Ice on a cotton pellet for up to 15 seconds. Lingering or exaggerated response suggests irreversible pulpitis.',
    options: ['Negative', 'Normal', 'Hypersensitive', 'Lingering Pain'],
  ),
  DiagnosisQuestion(
    id: 'heat_test',
    title: 'Heat Test',
    text: 'How does the patient respond to heat stimulus?',
    help: 'A positive lingering response to heat may also indicate irreversible pulpitis.',
    options: ['Negative', 'Normal', 'Hypersensitive', 'Lingering Pain'],
  ),
  DiagnosisQuestion(
    id: 'ept',
    title: 'Electric Pulp Test (EPT)',
    text: 'What is the pulp response to EPT?',
    help: 'Dry the tooth, apply toothpaste as conductor, and test on the middle third of the crown. No response may indicate pulp necrosis.',
    options: ['Negative', 'Positive'],
  ),
  DiagnosisQuestion(
    id: 'palpation',
    title: 'Palpation Test',
    text: 'Is there tenderness on palpation of the periapical area?',
    help: 'Gentle pressure on the mucosa over the root apex. Sensitivity suggests periapical inflammation.',
    options: ['Negative', 'Positive'],
  ),
  DiagnosisQuestion(
    id: 'percussion',
    title: 'Percussion Test',
    text: 'Does the patient feel pain when the tooth is tapped? (Vertical percussion)',
    help: 'Pain often indicates inflammation of the periodontal ligament or apical tissues.',
    options: ['Negative', 'Positive'],
  ),
  DiagnosisQuestion(
    id: 'bite_test',
    title: 'Bite Test',
    text: 'Does the patient experience pain when biting down on a tooth slooth or cotton roll?',
    help: 'Useful for detecting cracked tooth syndrome or periapical involvement.',
    options: ['Negative', 'Positive'],
  ),
  DiagnosisQuestion(
    id: 'swelling',
    title: 'Swelling',
    text: 'Is there any visible or palpable facial or intraoral swelling?',
    help: 'Facial swelling may indicate a spreading odontogenic infection and often requires immediate attention.',
    options: ['Negative', 'Positive'],
  ),
  DiagnosisQuestion(
    id: 'sinus_tract',
    title: 'Sinus Tract',
    text: 'Is a sinus tract (draining fistula) present on clinical inspection?',
    help: 'A visible draining sinus usually indicates chronic periapical abscess.',
    options: ['Negative', 'Positive'],
  ),
];
