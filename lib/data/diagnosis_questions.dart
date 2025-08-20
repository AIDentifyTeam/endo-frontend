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
  // ------------------ PAGE 1: PATIENT HISTORY ------------------

  DiagnosisQuestion(
    id: 'chief_complaint',
    title: 'Chief Complaint',
    text: 'Is there any chief complaint related to this tooth?',
    help:
        'If "No", you can still proceed, but history and evaluation may be limited.',
    options: ['Yes', 'No'],
  ),

  // P
  DiagnosisQuestion(
    id: 'P',
    title: 'Toothache',
    text: 'Do you have or have you experienced a toothache?',
    help:
        'If "No", the app will skip the detailed history questions and move to clinical/radiographic evaluation.',
    options: ['Yes', 'No'],
  ),

  // Q
  DiagnosisQuestion(
    id: 'Q',
    title: 'Cold triggers/aggravates pain',
    text: 'Does cold temperature trigger or aggravate the pain?',
    help:
        'Cold sensitivity pattern helps differentiate reversible vs. irreversible pulpitis.',
    options: ['No', 'For a few seconds', 'Longer than few seconds'],
  ),

  // R
  DiagnosisQuestion(
    id: 'R',
    title: 'Cold alleviates pain',
    text: 'Does cold temperature alleviate the pain?',
    help: 'Pain relief with cold can be associated with acute pulpitis.',
    options: ['No', 'For a few seconds', 'Longer than few seconds'],
  ),

  // S
  DiagnosisQuestion(
    id: 'S',
    title: 'Biting/chewing triggers pain',
    text: 'Does biting or chewing trigger or aggravate the pain?',
    help: 'Bite-provoked pain may suggest cracked tooth or apical involvement.',
    options: ['Yes', 'No'],
  ),

  // T
  DiagnosisQuestion(
    id: 'T',
    title: 'Ability to function on painful side',
    text: 'Are you able to function (bite or chew) on the painful side?',
    help: 'Functional limitation indicates severity and PDL involvement.',
    options: ['Yes', 'No'],
  ),

  // U
  DiagnosisQuestion(
    id: 'U',
    title: 'Spontaneous pain',
    text: 'Do you experience spontaneous pain?',
    help: 'Spontaneous pain is more consistent with irreversible pulpitis.',
    options: ['Yes', 'No'],
  ),

  // V
  DiagnosisQuestion(
    id: 'V',
    title: 'Pain affects sleep',
    text: 'Does the pain wake you up at night or interfere with sleep?',
    help: 'Night pain often accompanies severe pulpal inflammation.',
    options: ['Yes', 'No'],
  ),

  // W
  DiagnosisQuestion(
    id: 'W',
    title: 'Pain quality',
    text: 'Does the pain have any of the following qualities?',
    help: 'Pain quality contributes to the pulpal/periapical differential.',
    options: ['No', 'Sharp', 'Throbbing'],
  ),

  // X
  DiagnosisQuestion(
    id: 'X',
    title: 'Referred pain',
    text:
        'Do you also feel the pain in other areas like jawbone, ear, temple, eye, or cheek?',
    help: 'Referred pain suggests broader neural involvement.',
    options: ['Yes', 'No'],
  ),

  // ------------------ PAGE 2: CLINICAL & RADIOGRAPHIC ------------------

  DiagnosisQuestion(
    id: 'etiology_assessment',
    title: 'Etiology Assessment',
    text: 'What do you suspect as the cause of the current condition?',
    help:
        'You can select multiple causes. If you are not sure, select "Not sure".',
    options: [
      'Abrasion',
      'Attrition',
      'Caries',
      'Congenital anomalies (Dens invaginatus/evaginatus; palatal/lingual grooves)',
      'Crack',
      'External cervical resorption',
      'Non-endodontic pain',
      'Periodontal disease',
      'Persistent infection',
      'Restorative',
      'Trauma',
      'Vertical root fracture',
      'Not sure',
    ],
  ),

  DiagnosisQuestion(
    id: 'endo_history',
    title: 'Endodontic Treatment History',
    text: 'What is the history of endodontic treatment on the tooth?',
    help:
        'Has the tooth been previously treated, partially treated, or never treated?',
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
    help: 'Lingering or exaggerated response suggests irreversible pulpitis.',
    options: ['Negative', 'Normal', 'Hypersensitive', 'Lingering Pain'],
  ),

  DiagnosisQuestion(
    id: 'heat_test',
    title: 'Heat Test',
    text: 'How does the patient respond to heat stimulus?',
    help: 'Lingering response to heat may indicate irreversible pulpitis.',
    options: ['Negative', 'Normal', 'Hypersensitive', 'Lingering Pain'],
    isOptional: true,
  ),

  DiagnosisQuestion(
    id: 'ept',
    title: 'Electric Pulp Test (EPT)',
    text: 'What is the pulp response to EPT?',
    help: 'No response may indicate pulp necrosis.',
    options: ['Negative', 'Positive'],
    isOptional: true,
  ),

  DiagnosisQuestion(
    id: 'palpation',
    title: 'Palpation Test',
    text: 'Is there tenderness on palpation of the periapical area?',
    help: 'Sensitivity suggests periapical inflammation.',
    options: ['Negative', 'Positive'],
  ),

  DiagnosisQuestion(
    id: 'percussion',
    title: 'Percussion Test',
    text: 'Does the patient feel pain when the tooth is tapped (vertically)?',
    help: 'May indicate PDL or apical inflammation.',
    options: ['Negative', 'Positive'],
  ),

  DiagnosisQuestion(
    id: 'bite_test',
    title: 'Bite Test',
    text: 'Does the patient feel pain when biting on a tooth slooth or cotton roll?',
    help: 'Useful for cracked tooth or apical involvement.',
    options: ['Negative', 'Positive'],
  ),

  DiagnosisQuestion(
    id: 'swelling',
    title: 'Swelling',
    text: 'Is there any visible or palpable swelling?',
    help: 'May indicate spreading infection.',
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
    id: 'radiographic_findings',
    title: 'Radiographic Findings',
    text: 'What does the periapical radiograph reveal?',
    help: 'Evaluate periapical radiolucency, PDL widening, resorption, etc.',
    options: [
      'No abnormal findings',
      'PDL widening',
      'Periapical radiolucency',
    ],
  ),
];
