import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final Logger _logger = Logger('ReportScreen');
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  final _victimNameController = TextEditingController();
  String? _selectedLanguage;
  String? _relationship;
  String? _victimRole;
  bool _hasReportedBefore = false;
  bool _agreedToPrivacyPolicy = false;

  @override
  void initState() {
    super.initState();
    _setupLogging();
  }

  void _setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  List<Step> get _steps => [
        _buildPrivacyPolicyStep(),
        _buildUserInformationStep(),
        _buildVictimInformationStep(),
        _buildCyberbullyingDetailsStep(),
      ];

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Form(
      key: _formKey,
      child: Theme(
        data: Theme.of(context).copyWith(
          primaryColor: const Color(0xFF1A4594),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF1A4594),
            secondary: const Color(0xFF1A4594),
          ),
          shadowColor: Colors.transparent, // Removes shadow from all widgets
        ),
        child: Stepper(
          type: StepperType.horizontal,
          elevation: 0, // Ensures the stepper itself has no shadow
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < _steps.length - 1) {
              setState(() => _currentStep++);
            } else {
              _submitForm();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          steps: _steps,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: details.onStepCancel,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF1A4594)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text(
                              'Previous',
                              style: TextStyle(color: Color(0xFF1A4594)),
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A4594),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            _currentStep == _steps.length - 1
                                ? 'Submit'
                                : 'Next',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}


  Step _buildPrivacyPolicyStep() {
    return Step(
      title: const Text(
        '',
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Privacy Statement:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            '\n1. The information you provide will be used exclusively for addressing the bullying incident reported and will be handled in accordance with applicable data protection laws and university policies.\n'
            '2. All personal information shared in this report will be kept confidential and will only be accessible to authorized personnel involved in investigating and resolving the incident.\n'
            '3. We will not disclose your information to third parties without your explicit consent, unless required by law.\n'
            '4. We employ appropriate technical and organizational measures to protect your data from unauthorized access, alteration, disclosure, or destruction.\n'
            '5. You have the right to access, correct, or request the deletion of your personal information.\n'
            '6. If you have any concerns about how your data is handled, please contact our Data Protection Officer.\n'
            '7. Providing your personal information is voluntary, but please be aware that withholding certain details may impact our ability to address the bullying incident effectively.\n\n',
            style: TextStyle(fontSize: 14),
          ),
          Container(
            margin: const EdgeInsets.only(left: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _agreedToPrivacyPolicy,
                  onChanged: (bool? value) {
                    setState(() {
                      _agreedToPrivacyPolicy = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFF1A4594),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                ),
                const Text(
                  'I have read and agree to the data privacy policy.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 0,
    );
  }

 Step _buildUserInformationStep() {
  return Step(
    title: const Text(''),
    content: Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Preferred Language',
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 2.0),
            ),
          ),
          value: _selectedLanguage,
          items: ['Tagalog', 'English'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedLanguage = newValue;
            });
          },
          validator: (value) =>
              value == null ? 'Please select a language' : null,
        ),
      ],
    ),
    isActive: _currentStep >= 1,
  );
}

 Step _buildVictimInformationStep() {
  return Step(
    title: const Text(''),
    content: Column(
      children: [
        // Relationship to Victim is now the first question
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Relationship to Victim',
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 2.0),
            ),
          ),
          value: _relationship,
          items: ['Self', 'Parent/Guardian', 'Professor', 'Friend', 'Other']
              .map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _relationship = newValue;
            });
          },
          validator: (value) =>
              value == null ? 'Please select your relationship to the victim' : null,
        ),
        if (_relationship == 'Other')
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Please specify',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                ),
              ),
              validator: (value) => value?.isEmpty ?? true
                  ? 'Please specify your relationship'
                  : null,
            ),
          ),
        const SizedBox(height: 16), // Add spacing between fields

        // Victim's Full Name
        TextFormField(
          controller: _victimNameController,
          decoration: const InputDecoration(
            labelText: "Victim's Full Name",
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 2.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the victim\'s name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16), // Add spacing between fields

        // Victim's Role in the School
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: "Victim's Role in the School",
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 2.0),
            ),
          ),
          value: _victimRole,
          items: ['Student', 'School Staff', 'Professor', 'Other']
              .map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _victimRole = newValue;
            });
          },
          validator: (value) =>
              value == null ? 'Please select the victim\'s role' : null,
        ),
        const SizedBox(height: 16),

        TextFormField(
          decoration: const InputDecoration(
            labelText: "Victim's Grade/Year Level or Position",
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 2.0),
            ),
          ),
          validator: (value) => value?.isEmpty ?? true
              ? 'Please enter the victim\'s grade/year level or position'
              : null,
        ),
        const SizedBox(height: 16),

        SwitchListTile(
          title: const Text('Have you reported this incident to anyone else?'),
          value: _hasReportedBefore,
          onChanged: (bool value) {
            setState(() {
              _hasReportedBefore = value;
            });
          },
        ),
        if (_hasReportedBefore)
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'If yes, whom did you report it to?',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
              ),
            ),
            validator: (value) => value?.isEmpty ?? true
                ? 'Please specify whom you reported to'
                : null,
          ),
      ],
    ),
    isActive: _currentStep >= 2,
  );
}


Step _buildCyberbullyingDetailsStep() {
  List<String> selectedPlatforms = [];
  List<String> selectedCyberbullyingTypes = [];

  final platforms = [
    'Social Media (e.g., Facebook, Twitter, Instagram)',
    'Messaging Apps (e.g., WhatsApp, Messenger)',
    'Email',
    'School\'s Online Platform',
    'Others (Please Specify)'
  ];

  final cyberbullyingTypes = [
    'Harassment',
    'Threats',
    'Spreading Rumors',
    'Exclusion',
    'Doxing (Revealing personal information)',
    'Impersonation',
    'Others (Please Specify)'
  ];

  final otherPlatformController = TextEditingController();
  final otherCyberbullyingController = TextEditingController();

  return Step(
    title: const Text(''),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Platform or Medium Used for Cyberbullying:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Column(
          children: platforms.map((platform) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0), 
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(platform),
                value: selectedPlatforms.contains(platform),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected ?? false) {
                      selectedPlatforms.add(platform);
                    } else {
                      selectedPlatforms.remove(platform);
                    }
                  });
                },
              ),
            );
          }).toList(),
        ),
        if (selectedPlatforms.contains('Others (Please Specify)'))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: TextFormField(
              controller: otherPlatformController,
              decoration: const InputDecoration(
                labelText: 'Please specify other platform',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                ),
              ),
              validator: (value) {
                if (selectedPlatforms.contains('Others (Please Specify)') &&
                    (value == null || value.isEmpty)) {
                  return 'Please specify the other platform';
                }
                return null;
              },
            ),
          ),

        const SizedBox(height: 16), // Keep this for spacing between sections

        // Type of Cyberbullying Involved
        const Text(
          'What type of cyberbullying was involved? (Check all that apply)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Column(
          children: cyberbullyingTypes.map((type) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0), // Reduced vertical padding
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(type),
                value: selectedCyberbullyingTypes.contains(type),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected ?? false) {
                      selectedCyberbullyingTypes.add(type);
                    } else {
                      selectedCyberbullyingTypes.remove(type);
                    }
                  });
                },
              ),
            );
          }).toList(),
        ),
        if (selectedCyberbullyingTypes.contains('Others (Please Specify)'))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: TextFormField(
              controller: otherCyberbullyingController,
              decoration: const InputDecoration(
                labelText: 'Please specify other type of cyberbullying',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                ),
              ),
              validator: (value) {
                if (selectedCyberbullyingTypes.contains('Others (Please Specify)') &&
                    (value == null || value.isEmpty)) {
                  return 'Please specify the other type of cyberbullying';
                }
                return null;
              },
            ),
          ),

        const SizedBox(height: 16), // Keep this for spacing between sections

        // Any validation or additional fields can be added here
      ],
    ),
    isActive: _currentStep >= 3,
  );
}

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (!_agreedToPrivacyPolicy) {
        _logger.warning(
            'Form submission attempted without agreeing to privacy policy');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Please agree to the privacy policy before submitting')),
        );
        return;
      }
      _logger.info('Form submitted successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully')),
      );
    } else {
      _logger.warning('Form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
    }
  }

  @override
  void dispose() {
    _victimNameController.dispose();
    super.dispose();
  }
}
