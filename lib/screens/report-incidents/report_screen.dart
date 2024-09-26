// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bully_proof_umak/config.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final Logger _logger = Logger('ReportScreen');
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  final _victimNameController = TextEditingController();
  final _victimGradeYearLevelController = TextEditingController();
  String? _relationship;
  String? _victimRole;
  String? _hasReportedBefore;

  bool _agreedToPrivacyPolicy = false;
  String? _isAnonymous;

  List<String> selectedPlatforms = [];
  List<String> selectedCyberbullyingTypes = [];

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void submitReport() async {
    var regBody = {
      "victimName": _victimNameController.text,
      "victimType": _victimRole,
      "gradeYearLevel": _victimGradeYearLevelController.text,
    };

    // Retrieve the token
    String? token = await getToken();

    if (token == null) {
      // Handle missing token case, maybe prompt user to log in
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Authentication token missing. Please log in.'),
      ));
      return;
    }

    var response = await http.post(
      Uri.parse(report),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // Add the token in the header
      },
      body: jsonEncode(regBody),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    var jsonResponse = jsonDecode(response.body);

    if (jsonResponse['status']) {
      // ignore: use_build_context_synchronously
      _successMessage(context);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Center(
              child: Text("Registration failed!"),
            ),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 50),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

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
        _buildCyberbullyingDetailsStep(),
        _buildVictimInformationStep(),
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
            shadowColor: Colors.transparent,
          ),
          child: Stepper(
            type: StepperType.horizontal,
            elevation: 0,
            currentStep: _currentStep,
            onStepContinue: () {
              if (_validateCurrentStep()) {
                if (_currentStep < _steps.length - 1) {
                  setState(() => _currentStep++);
                } else {
                  _submitForm();
                }
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF1A4594)),
                          ),
                          child: const Text('Previous',
                              style: TextStyle(color: Color(0xFF1A4594))),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A4594),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(_currentStep == _steps.length - 1
                            ? 'Submit'
                            : 'Next'),
                      ),
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

  bool _validateCurrentStep() {
    bool isValid = true;

    switch (_currentStep) {
      case 0:
        if (!_agreedToPrivacyPolicy) {
          _logger.warning('Privacy policy not agreed');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Please agree to the privacy policy before continuing'),
            ),
          );
          isValid = false;
        }
        break;
      // case 1:
      //   if (_selectedLanguage == null) {
      //     _logger.warning('Language not selected');
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Please select a preferred language')),
      //     );
      //     isValid = false;
      //   }
      //   break;
      // case 2:
      //   if (!_formKey.currentState!.validate()) {
      //     _logger.warning('Victim information validation failed');
      //     isValid = false;
      //   }
      //   break;
      // case 3:
      //   if (selectedPlatforms.isEmpty) {
      //     _logger.warning('No platform selected');
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //           content: Text('Please select at least one platform')),
      //     );
      //     isValid = false;
      //   }
      //   if (selectedCyberbullyingTypes.isEmpty) {
      //     _logger.warning('No cyberbullying type selected');
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //           content:
      //               Text('Please select at least one type of cyberbullying')),
      //     );
      //     isValid = false;
      //   }
      //   if (!_formKey.currentState!.validate()) {
      //     _logger.warning('Form validation failed');
      //     isValid = false;
      //   }
      //   break;
      // default:
      //   isValid = true;
    }

    // if (!isValid) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please fill in all required fields')),
    //   );
    // }

    return isValid;
  }

  //step 1
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
              fontSize: 20,
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
            style: TextStyle(fontSize: 15.0),
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
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 0,
    );
  }

  //step 2
  Step _buildUserInformationStep() {
    return Step(
      title: const Text(''),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Anonymous Option
          const Text('Do you want to remain anonymous?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              )),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            hint: const Text('Select an option'),
            value: _isAnonymous,
            items: ['Yes', 'No'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _isAnonymous = newValue;
              });
            },
            validator: (value) =>
                value == null ? 'Please select an option' : null,
          ),
          const SizedBox(height: 20),

          // Victim Information
          const Text('Relationship to Victim',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              )),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
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
            hint: const Text('Select relationship to victim'),
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
            validator: (value) => value == null
                ? 'Please select your relationship to the victim'
                : null,
          ),
          if (_relationship == 'Other')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please specify your relationship to the victim',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      )),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
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
                ],
              ),
            ),
          const SizedBox(height: 20),

          const Text("Victim's Full Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              )),
          const SizedBox(height: 8),
          TextFormField(
            controller: _victimNameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
              ),
              hintText: "Enter victim's full name", // Added hint text
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the victim\'s name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          const Text("Victim's Role in the School",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              )),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
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
            hint: const Text('Select role in the school'),
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
          if (_victimRole == 'Other')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please specify the victim\'s role',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      )),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                      hintText: 'Enter the victim\'s role',
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please specify the victim\'s role'
                        : null,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          const Text(
            "Victim's Grade/Year Level or Position",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _victimGradeYearLevelController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
              ),
              hintText: "Enter victim's grade/year level or position",
            ),
            validator: (value) => value?.isEmpty ?? true
                ? 'Please enter the victim\'s grade/year level or position'
                : null,
          ),
          const SizedBox(height: 20),

          const Text(
            'Have you reported this incident to anyone else?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _hasReportedBefore,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            hint: const Text('Select an option'),
            items: ['Yes', 'No'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _hasReportedBefore = newValue;
              });
            },
            validator: (value) =>
                value == null ? 'Please select an option' : null,
          ),
          if (_hasReportedBefore == 'Yes')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please specify to whom you reported',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      )),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                      hintText: 'Enter the person or entity',
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please specify to whom you reported'
                        : null,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
      isActive: _currentStep >= 1,
    );
  }

  //step 3
  Step _buildCyberbullyingDetailsStep() {
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
    final witnessNamesController = TextEditingController();

    final List<String> witnessOptions = ['Yes', 'No'];

    final incidentDetailsController = TextEditingController();

    return Step(
      title: const Text(''),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform or Medium Used for Cyberbullying (Check all that apply)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: platforms.map((platform) {
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                visualDensity:
                    const VisualDensity(horizontal: -4, vertical: -4),
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
              );
            }).toList(),
          ),
          if (selectedPlatforms.contains('Others (Please Specify)'))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Please specify other platform',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: otherPlatformController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      hintText: 'Enter other platform',
                    ),
                    validator: (value) {
                      if (selectedPlatforms
                              .contains('Others (Please Specify)') &&
                          (value == null || value.isEmpty)) {
                        return 'Please specify the other platform';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'What type of cyberbullying was involved? (Check all that apply)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: cyberbullyingTypes.map((type) {
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                visualDensity:
                    const VisualDensity(horizontal: -4, vertical: -4),
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
              );
            }).toList(),
          ),
          if (selectedCyberbullyingTypes.contains('Others (Please Specify)'))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Please specify other type of cyberbullying',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: otherCyberbullyingController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      hintText: 'Enter other type of cyberbullying',
                    ),
                    validator: (value) {
                      if (selectedCyberbullyingTypes
                              .contains('Others (Please Specify)') &&
                          (value == null || value.isEmpty)) {
                        return 'Please specify the other type of cyberbullying';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'Describe the Incident in Detail:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 880,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 228, 228, 228),
                  foregroundColor: const Color.fromARGB(255, 44, 44, 44),
                ),
                child: const Text('Convert image to text'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: incidentDetailsController,
            maxLines: 6,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1A4594), width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              hintText: 'Enter detailed description of the incident here',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please provide details of the incident';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Please provide any evidence related to the incident:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 65,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, size: 27),
                        SizedBox(width: 16),
                        Icon(Icons.camera_alt_outlined, size: 27),
                        SizedBox(width: 16),
                        Icon(Icons.mic_outlined, size: 27),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 2,
    );
  }

  //step 4
  String? _perpetratorRole;
  String? _actionsTaken;
  bool _emotionalSupport = false;
  bool _legalSupport = false;
  bool _academicSupport = false;
  bool _otherSupport = false;
  bool _agreementChecked = false;
  Step _buildVictimInformationStep() {
    return Step(
      title: const Text(''),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Perpetrator's Full Name
          const Text("Perpetrator's Full Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              )),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
              ),
              hintText: "Enter perpetrator's full name",
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the perpetrator\'s name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Perpetrator's Role in the University
          const Text("Perpetrator's Role in the University",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              )),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
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
            hint: const Text('Select perpetrator\'s role'),
            value: _perpetratorRole,
            items: ['Student', 'Professor', 'School Staff', 'Other']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _perpetratorRole = newValue;
              });
            },
            validator: (value) =>
                value == null ? 'Please select the perpetrator\'s role' : null,
          ),
          if (_perpetratorRole == 'Other')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please specify the perpetrator\'s role',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      )),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                      hintText: 'Enter the perpetrator\'s role',
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please specify the perpetrator\'s role'
                        : null,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            "Perpetrator’s Grade/Year Level or Position",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
              ),
              hintText: "Enter perpetrator's grade/year level or position",
            ),
            validator: (value) => value?.isEmpty ?? true
                ? 'Please enter the perpetrator\'s grade/year level or position'
                : null,
          ),
          const SizedBox(height: 20),

          // Have any actions been taken so far?
          const Text(
            'What type of support would you like to receive?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _emotionalSupport,
                    onChanged: (bool? value) {
                      setState(() {
                        _emotionalSupport = value ?? false;
                      });
                    },
                  ),
                  const Text(
                    'Counseling for the victim',
                    style: TextStyle(fontSize: 17.0),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _legalSupport,
                    onChanged: (bool? value) {
                      setState(() {
                        _legalSupport = value ?? false;
                      });
                    },
                  ),
                  const Text(
                    'Talk between the victim and perpetrator',
                    style: TextStyle(fontSize: 17.0),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _academicSupport,
                    onChanged: (bool? value) {
                      setState(() {
                        _academicSupport = value ?? false;
                      });
                    },
                  ),
                  const Text(
                    'Disciplinary action against the perpetrator',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _otherSupport,
                    onChanged: (bool? value) {
                      setState(() {
                        _otherSupport = value ?? false;
                      });
                    },
                  ),
                  const Text(
                    'Other',
                    style: TextStyle(fontSize: 17.0),
                  ),
                ],
              ),
              if (_otherSupport)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                      hintText: 'Specify other support',
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please specify other support'
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          const Text('Have any actions been taken so far?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              )),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _actionsTaken,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 2.0),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            hint: const Text('Select an option'),
            items: ['Yes', 'No'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _actionsTaken = newValue;
              });
            },
            validator: (value) =>
                value == null ? 'Please select an option' : null,
          ),
          if (_actionsTaken == 'Yes')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please describe the actions taken',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      )),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                      hintText: 'Describe the actions taken',
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please describe the actions taken'
                        : null,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 50),
          Row(
            children: [
              Checkbox(
                value: _agreementChecked,
                onChanged: (bool? value) {
                  setState(() {
                    _agreementChecked = value ?? false;
                  });
                },
              ),
              const Expanded(
                child: Text(
                  'I agree that the above statements are true and accurate.',
                  style: TextStyle(
                    fontSize: 17.0,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      isActive: _currentStep >= 3,
    );
  }

  void _submitForm() {
    submitReport();
    // if (_formKey.currentState!.validate()) {
    //   if (!_agreedToPrivacyPolicy) {
    //     _logger.warning(
    //         'Form submission attempted without agreeing to privacy policy');
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content:
    //             Text('Please agree to the privacy policy before submitting'),
    //       ),
    //     );
    //     return;
    //   }
    //   submitReport();
    //   _logger.info('Form submitted successfully');
    //   // ScaffoldMessenger.of(context).showSnackBar(
    //   //   const SnackBar(content: Text('Report submitted successfully')),
    //   // );

    // } else {
    //   _logger.warning('Form validation failed');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please fill in all required fields')),
    //   );
    // }
  }

  @override
  void dispose() {
    _victimNameController.dispose();
    super.dispose();
  }

  _successMessage(BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Container(
        padding: const EdgeInsets.all(8),
        height: 80,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 81, 146, 83),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 40,
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Success",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Registration successful!",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ));
  }
}
