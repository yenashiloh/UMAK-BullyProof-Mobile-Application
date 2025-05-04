// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:bully_proof_umak/config.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportScreen extends StatefulWidget {
  final VoidCallback? onNavigateToHistory;
  const ReportScreen({super.key, this.onNavigateToHistory});

  @override
  // ignore: library_private_types_in_public_api
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final Logger _logger = Logger('ReportScreen');
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // final _victimNameController = TextEditingController();
  final _departmentCollege = TextEditingController();
  final _reportedTo = TextEditingController();
  final _perpetratorName = TextEditingController();
  final _describeActionsTaken = TextEditingController();
  // final _witnessInfo = TextEditingController();

  String? _relationship;
  String? _submitAs;
  String? _witnessChoice;
  // String? _victimRole;
  // String? _victimGradeYearLevel;
  String? _perpetratorRole;
  String? _perpetratorGradeYearLevel;
  // String? _hasWitnesses;
  String? _hasReportedBefore;
  String? _actionsTaken;
  String? _contactChoice;

  // final otherRelationship = TextEditingController();
  // final otherVictimRole = TextEditingController();
  // final otherVictimGradeYearLevelController = TextEditingController();
  // final otherPerpetratorRole = TextEditingController();
  // final otherPerpetratorGradeYearLevelController = TextEditingController();
  final otherPlatformController = TextEditingController();
  // final otherCyberbullyingController = TextEditingController();
  final witnessNamesController = TextEditingController();
  final incidentDetailsController = TextEditingController();
  final otherSupportController = TextEditingController();

  bool _agreedToPrivacyPolicy = false;
  bool _showSuccessDialog = false;

  List<String> selectedPlatforms = [];
  List<String> selectedCyberbullyingTypes = [];
  List<String> selectedSupportTypes = [];

  List<File> _images = [];
  final picker = ImagePicker();
  List<File> _selectedImages = [];
  File? selectedMedia;

  final platforms = [
    'Social Media (e.g., Facebook, Twitter, Instagram)',
    'Messaging Apps (e.g., WhatsApp, Messenger)',
    'Email',
    'School\'s Online Platform',
    'Others (Please Specify)'
  ];

  final cyberbullyingTypes = [
    'Harassment',
    'Impersonation',
    'Outing',
    'Exclusion',
    'Cyberstalking',
    'Doxxing',
    'Trolling',
    'Cyberthreats',
    'Flaming',
    'Happy Slapping',
    'Catfishing',
    'Meme Bullying',
    'Disinformation Campaigns',
    'Dissing',
    'Cookie Stuffing'
  ];

  final Map<String, String> cyberbullyingDefinitions = {
    'Harassment':
        'Repeatedly sending offensive, hurtful, or threatening messages online through platforms like emails, texts, or social media.',
    'Impersonation':
        'Pretending to be someone else online to spread false or harmful information, damage reputations, or cause distress.',
    'Outing':
        'Sharing private or embarrassing information, photos, or videos about someone without their consent.',
    'Exclusion':
        'Intentionally excluding someone from online groups, games, or social networks to isolate them.',
    'Cyberstalking':
        'Repeatedly stalking or harassing someone online with the intent to cause fear or anxiety.',
    'Doxxing':
        'Publishing private personal information, such as addresses or phone numbers, without permission, which can lead to physical harm or harassment.',
    'Trolling':
        'Posting inflammatory, offensive, or provocative content online to upset or provoke others, often for amusement.',
    'Cyberthreats':
        'Sending direct threats, such as violence or harm, through the internet to instill fear or distress.',
    'Flaming':
        'Engaging in hostile or argumentative interactions online, often meant to provoke strong emotional reactions, usually on public forums or social media.',
    'Happy Slapping':
        'Recording and posting videos of physical bullying or embarrassing acts, usually done to humiliate the victim.',
    'Catfishing':
        'Creating a fake identity to deceive or manipulate someone online, often used to exploit them emotionally or financially.',
    'Meme Bullying':
        'Using memes or viral content to mock, ridicule, or humiliate someone in a widespread manner.',
    'Disinformation Campaigns':
        'Spreading false information about someone to damage their reputation, spread lies, or cause harm to their life.',
    'Dissing':
        'Posting derogatory or insulting comments about someone to tarnish their reputation or embarrass them.',
    'Cookie Stuffing':
        'Inserting malicious links or tracking cookies into a victim\'s profile or online content to gather personal information or cause digital harm.',
  };

  final List<String> witnessOptions = ['Yes', 'No'];

  Future<void> getImage() async {
    // Allow selecting multiple images
    final pickedImages = await picker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        // Add selected images to the list
        _images =
            pickedImages.map((pickedImage) => File(pickedImage.path)).toList();
      });
    } else {
      print("No images were picked.");
    }
  }

  Future<void> selectImage() async {
    // Allow selecting multiple images
    final pickedImages = await picker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        // Add selected images to the list
        _selectedImages =
            pickedImages.map((pickedImage) => File(pickedImage.path)).toList();
      });
      await _processImages();
    } else {
      print("No images were picked.");
    }
  }

  Future<String?> _extractText(File file) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final InputImage inputImage = InputImage.fromFile(file);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    String text = recognizedText.text;
    textRecognizer.close();
    return text;
  }

  Future<void> _processImages() async {
    showLoadingDialog(context, message: 'Converting image to text...');

    String combinedText = "";
    for (var file in _selectedImages) {
      final text = await _extractText(file);
      if (text != null && text.isNotEmpty) {
        combinedText += "$text\n";
      }
    }

    setState(() {
      hideLoadingDialog(context); // Hide the loading dialog first
      if (combinedText.trim().isEmpty) {
        // Show a message if no text was extracted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'No text was detected in the selected images.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            backgroundColor: const Color(0xFF1A4594),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        incidentDetailsController.text =
            ''; // Clear the text field if no text is found
      } else {
        incidentDetailsController.text = combinedText; // Set the text if found
      }
    });
  }

  // Capture image from camera
  Future<void> captureImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _images.add(File(pickedImage.path));
      });
    } else {
      print("No image captured.");
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void submitReport() async {
    // Show loading dialog before starting the submission
    showLoadingDialog(context, message: 'Submitting report...');

    if (otherPlatformController.text.isNotEmpty) {
      selectedPlatforms.add(otherPlatformController.text);
    }
    // if (otherCyberbullyingController.text.isNotEmpty) {
    //   selectedCyberbullyingTypes.add(otherCyberbullyingController.text);
    // }

    List<String> base64Images = [];
    for (File image in _images) {
      List<int> imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      base64Images.add(base64Image);
    }

    // Helper function to return "N/A" for empty or null values
    String? getValueOrNA(dynamic value) {
      if (value == null) return "N/A";
      if (value is String && value.isEmpty) return "N/A";
      if (value is List && value.isEmpty) return "N/A";
      return value.toString();
    }

    var regBody = {
      "submitAs": getValueOrNA(_submitAs),
      "victimRelationship": getValueOrNA(_relationship),
      // "otherVictimRelationship": _getValueOrNA(otherRelationship.text),
      // "victimName": _getValueOrNA(_victimNameController.text),
      // "victimType": _getValueOrNA(_victimRole),
      // "gradeYearLevel": _getValueOrNA(_victimGradeYearLevel),
      "hasReportedBefore": getValueOrNA(_hasReportedBefore),
      "departmentCollege": getValueOrNA(_departmentCollege.text),
      "reportedTo": getValueOrNA(_reportedTo.text),
      "platformUsed": getValueOrNA(selectedPlatforms),
      "otherPlatformUsed": getValueOrNA(otherPlatformController.text),
      "cyberbullyingTypes": getValueOrNA(selectedCyberbullyingTypes),
      // "hasWitness": _getValueOrNA(_hasWitnesses),
      // "witnessInfo": _getValueOrNA(_witnessInfo.text),
      "incidentDetails": getValueOrNA(incidentDetailsController.text),
      "incidentEvidence": base64Images,
      "perpetratorName": getValueOrNA(_perpetratorName.text),
      "perpetratorRole": getValueOrNA(_perpetratorRole),
      "perpetratorGradeYearLevel": getValueOrNA(_perpetratorGradeYearLevel),
      "supportTypes": getValueOrNA(selectedSupportTypes),
      "otherSupportTypes": getValueOrNA(otherSupportController.text),
      "witnessChoice": getValueOrNA(_witnessChoice),
      "contactChoice": getValueOrNA(_contactChoice),
      "actionsTaken": getValueOrNA(_actionsTaken),
      "describeActions": getValueOrNA(_describeActionsTaken.text),
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

    // Hide loading dialog after response is received
    hideLoadingDialog(context);

    if (jsonResponse['status']) {
      setState(() {
        _showSuccessDialog = true;
      });
    } else {
      // Keep your existing error handling
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
      body: Stack(
        children: [
          Form(
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: details.onStepCancel,
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: Color(0xFF1A4594)),
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
          if (_showSuccessDialog)
            Container(
              color: Colors.black54,
              child: Center(
                child: TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated Check Container
                        TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 800),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          builder: (context, double value, child) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Pulsing circle animation
                                  TweenAnimationBuilder(
                                    duration:
                                        const Duration(milliseconds: 1500),
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    builder: (context, double value, child) {
                                      return Container(
                                        width: 80 * (1 + (value * 0.2)),
                                        height: 80 * (1 + (value * 0.2)),
                                        decoration: BoxDecoration(
                                          color: Colors.green
                                              .withOpacity(0.2 * (1 - value)),
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    },
                                  ),
                                  // Check icon with scale and rotate animation
                                  Transform.scale(
                                    scale: value,
                                    child: Transform.rotate(
                                      angle: value * 2 * 3.14159,
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        // Animated Text
                        TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 500),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: const Text(
                            'Report Submitted Successfully!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A4594),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Animated Description
                        TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 600),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: const Text(
                            'Thank you for taking action. Your report has been received, and we\'re here to help. You\'ll be notified of any updates. Remember, you\'re not alone—support is available if you need it.',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Animated Button
                        TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 700),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _clearFormInputs();
                                Navigator.pop(context);
                                widget.onNavigateToHistory?.call();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A4594),
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _validateCurrentStep() {
    bool isValid = true;
    String errorMessage = '';

    switch (_currentStep) {
      case 0:
        if (!_agreedToPrivacyPolicy) {
          _logger.warning('Privacy policy not agreed');
          errorMessage = 'Please agree to the privacy policy before continuing';
          isValid = false;
        }
        break;
      case 1:
        // Validate submit as
        if (_submitAs == null) {
          _logger.warning('No selected in submit report as');
          errorMessage =
              'Please choose if you submitting a report as the complainant';
          isValid = false;
          break;
        }

        // Validate relationship
        if (_submitAs ==
            'No, I am submitting as a witness, friend, or other third party.') {
          if (_relationship == null) {
            _logger.warning('Relationship not selected');
            errorMessage = 'Please select your relationship to the Complainant';
            isValid = false;
            break;
          }
        }
        // else if (_relationship == 'Other') {
        //   if (otherRelationship.text.isEmpty) {
        //     _logger.warning('Other Relationship not specified');
        //     errorMessage =
        //         'Please specify your relationship to the Complainant';
        //     isValid = false;
        //     break;
        //   }
        // }

        // Validate victim name
        // if (_victimNameController.text.isEmpty) {
        //   _logger.warning('Complainant name empty');
        //   errorMessage = "Please enter the Complainant's name";
        //   isValid = false;
        //   break;
        // }

        // Validate victim role
        // if (_victimRole == null) {
        //   _logger.warning('Complainant role not selected');
        //   errorMessage =
        //       "Please select the Complainant's role in the university";
        //   isValid = false;
        //   break;
        // }

        // Validate victim grade/year level
        // if (_victimGradeYearLevel == null) {
        //   _logger.warning('Complainant grade/year level not selected');
        //   errorMessage =
        //       "Please select the Complainant's Program/Year Level or Position";
        //   isValid = false;
        //   break;
        // }

        // Validate perpetrator name
        if (_perpetratorName.text.isEmpty) {
          _logger.warning('Complainee name empty');
          errorMessage = "Please enter the Complainee's name";
          isValid = false;
          break;
        }

        // Validate perpetrator role
        if (_perpetratorRole == null) {
          _logger.warning('Complainee role not selected');
          errorMessage =
              "Please select the Complainee's role in the university";
          isValid = false;
          break;
        }

        // Validate perpetrator grade/year level
        if (_perpetratorGradeYearLevel == null) {
          _logger.warning('Complainee grade/year level not selected');
          errorMessage =
              "Please select the Complainee's Program/Year Level or Position";
          isValid = false;
          break;
        }
        break;
      case 2:
        // Validate Platform
        if (selectedPlatforms.isEmpty) {
          _logger.warning('Platform not selected');
          errorMessage = 'Please select Platform or Medium Used';
          isValid = false;
          break;
        } else if (selectedPlatforms.contains('Others (Please Specify)')) {
          if (otherPlatformController.text.isEmpty) {
            _logger.warning('Other Platform or Medium Used not specified');
            errorMessage = 'Please specify the Platform or Medium Used';
            isValid = false;
            break;
          }
        }

        // Validate Cyberbullying Types
        if (selectedCyberbullyingTypes.isEmpty) {
          _logger.warning('Cyberbullying types not selected');
          errorMessage = 'Please select Cyberbullying Type';
          isValid = false;
          break;
        }

        // Validate witnesses
        // if (_hasWitnesses == null) {
        //   _logger.warning('Option not selected');
        //   errorMessage = 'Please select witnesses Option';
        //   isValid = false;
        //   break;
        // } else if (_hasWitnesses == 'Yes') {
        //   if (_witnessInfo.text.isEmpty) {
        //     _logger.warning('Witness Name and Contact not specified');
        //     errorMessage =
        //         'Please specify the Name and Contact information of witness';
        //     isValid = false;
        //     break;
        //   }
        // }

        // Validate Incident Details
        if (incidentDetailsController.text.isEmpty) {
          _logger.warning('Incident Details not specified');
          errorMessage = 'Please provide details of the incident';
          isValid = false;
          break;
        }

        // Validate Evidence
        if (_images.isEmpty) {
          _logger.warning('No Evidence provided');
          errorMessage = 'Please provide any evidence';
          isValid = false;
          break;
        }
        break;
      case 3:
        // Validate reported
        if (_hasReportedBefore == null) {
          _logger.warning('Have you reported is not specified');
          errorMessage = 'Please select option if you reported this incident';
          isValid = false;
          break;
        } else if (_hasReportedBefore == 'Yes') {
          if (_departmentCollege.text.isEmpty) {
            _logger.warning('Department or College not specified');
            errorMessage = 'Please specify the Department or College';
            isValid = false;
            break;
          }
          if (_reportedTo.text.isEmpty) {
            _logger.warning('Name of the person not specified');
            errorMessage =
                'Please specify the Name of the person from the department or college';
            isValid = false;
            break;
          }
          if (_actionsTaken == null) {
            _logger.warning('Option not selected');
            errorMessage = 'Please select if any actions been taken';
            isValid = false;
            break;
          } else if (_actionsTaken == 'Yes') {
            if (_describeActionsTaken.text.isEmpty) {
              _logger.warning('Actions not specified');
              errorMessage = 'Please specify actions taken';
              isValid = false;
              break;
            }
          }
        }

        // Validate Support
        if (_submitAs ==
            'Yes, I am the complainant (directly affected by the cyberbullying).') {
          if (selectedSupportTypes.isEmpty) {
            _logger.warning('type of support not selected');
            errorMessage = 'Please select type of support';
            isValid = false;
            break;
          } else if (selectedSupportTypes.contains('Others (Please Specify)')) {
            if (otherSupportController.text.isEmpty) {
              _logger.warning('Other type of support not specified');
              errorMessage = 'Please specify other type of support';
              isValid = false;
              break;
            }
          }
        } else if (_submitAs ==
            'No, I am submitting as a witness, friend, or other third party.') {
          if (_witnessChoice == null) {
            _logger.warning('No selected in investigation participate');
            errorMessage =
                'Please choose if you want to participate in investigation';
            isValid = false;
            break;
          } else if (_witnessChoice == 'Yes, I would like to participate.') {
            if (_contactChoice == null) {
              _logger.warning('Option not selected');
              errorMessage = 'Please select if we can contact you';
              isValid = false;
              break;
            }
          }
        }

        // Validate statements
        if (!_agreementChecked) {
          _logger.warning('above statements not agreed');
          errorMessage = 'Please agree that the above statements are true';
          isValid = false;
        }
        break;
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }

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
              color:
                  Color(0xFF1C4494), // Blue for emphasis, matching UI accents
            ),
          ),
          const SizedBox(height: 12), // Increased spacing for better separation
          const Text(
            '1. The information you provide will be used exclusively for addressing the bullying incident reported and will be handled in accordance with applicable data protection laws and university policies.\n'
            '2. All personal information shared in this report will be kept confidential and will only be accessible to authorized personnel involved in investigating and resolving the incident.\n'
            '3. We will not disclose your information to third parties without your explicit consent, unless required by law.\n'
            '4. We employ appropriate technical and organizational measures to protect your data from unauthorized access, alteration, disclosure, or destruction.\n'
            '5. You have the right to access, correct, or request the deletion of your personal information.\n'
            '6. If you have any concerns about how your data is handled, please contact our Data Protection Officer.\n'
            '7. Providing your personal information is voluntary, but please be aware that withholding certain details may impact our ability to address the bullying incident effectively.',
            style: TextStyle(
              fontSize: 16, // Slightly larger for better readability
              color: Colors.black87, // Softer black for better contrast
              height:
                  1.5, // Increased line height for better spacing between lines
            ),
          ),
          const SizedBox(height: 20), // Increased spacing before checkbox
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
                const SizedBox(
                    width: 12), // Increased spacing between checkbox and text
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _showTermsAndConditionsDialog(context);
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: 'I have read and agree to the\n',
                        style: TextStyle(
                          fontSize:
                              12, // Slightly larger for better readability
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(
                            text: ' and Data Privacy Statement.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Complainee\'s Details',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 20),
              // Radio Button for Complainant Submission
              const Text(
                'Are you submitting this report as the complainant?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                  color: Colors.black87,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Yes, I am the complainant (directly affected by the cyberbullying).',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      softWrap: true,
                    ),
                    leading: Radio<String>(
                      value:
                          'Yes, I am the complainant (directly affected by the cyberbullying).',
                      groupValue: _submitAs,
                      onChanged: (String? newValue) {
                        setState(() {
                          _submitAs = newValue;
                        });
                      },
                      activeColor: Colors.blue,
                      fillColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.blue;
                          }
                          return Colors.blue[200]!;
                        },
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'No, I am submitting as a witness, friend, or other third party.',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      softWrap: true,
                    ),
                    leading: Radio<String>(
                      value:
                          'No, I am submitting as a witness, friend, or other third party.',
                      groupValue: _submitAs,
                      onChanged: (String? newValue) {
                        setState(() {
                          _submitAs = newValue;
                        });
                      },
                      activeColor: Colors.blue,
                      fillColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.blue;
                          }
                          return Colors.blue[200]!;
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // Conditionally show fields based on radio button selection
              if (_submitAs != null) ...[
                const SizedBox(height: 20),
                if (_submitAs ==
                    'Yes, I am the complainant (directly affected by the cyberbullying).') ...[
                  // Complainee's Fields (only shown if "Yes" is selected)
                  const Text(
                    "Complainee's Name",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _perpetratorName,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                      hintText: "Surname, First Name M.I",
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the Complainee\'s name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Complainee's Role in the University",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
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
                    hint: const Text('Select role in the university'),
                    value: _perpetratorRole,
                    items: ['Student', 'Employee'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _perpetratorRole = newValue;
                      });
                    },
                    validator: (value) => value == null
                        ? 'Please select the Complainee\'s role'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Dynamically change label and options based on Complainee's Role
                  if (_perpetratorRole != null) ...[
                    Text(
                      _perpetratorRole == 'Student'
                          ? "Complainee's Year Level"
                          : "Complainee's Position",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 2.0),
                        ),
                      ),
                      hint: Text(_perpetratorRole == 'Student'
                          ? 'Select Year Level'
                          : 'Select Position'),
                      value: _perpetratorGradeYearLevel,
                      items: _perpetratorRole == 'Student'
                          ? [
                              'Not sure',
                              'Grade 11',
                              'Grade 12',
                              '1st Year College',
                              '2nd Year College',
                              '3rd Year College',
                              '4th Year College',
                              '5th Year College',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList()
                          : [
                              'Not sure',
                              'Administrative Assistant',
                              'Office Manager',
                              'Clerical Worker',
                              'Program Coordinator',
                              'Executive Assistant',
                              'Faculty',
                              'Clerk',
                              'Clerk Staff',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _perpetratorGradeYearLevel = newValue;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Please select ${_perpetratorRole == 'Student' ? 'Year Level' : 'Position'}'
                          : null,
                    ),
                  ],
                ] else if (_submitAs ==
                    'No, I am submitting as a witness, friend, or other third party.') ...[
                  const Text(
                    'Relationship to the Complainant',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
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
                    hint: const Text('Select Relationship to the Complainant'),
                    value: _relationship,
                    items: [
                      'Friend',
                      'Coworker',
                      'Classmate',
                      'Stranger',
                      'Acquaintance'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          softWrap: true,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _relationship = newValue;
                      });
                    },
                    validator: (value) => value == null
                        ? 'Please select your relationship to the Complainant'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Complainee's Fields (shown for both "Yes" and "No")
                  const Text(
                    "Complainee's Name",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _perpetratorName,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                      hintText: "Surname, First Name M.I",
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the Complainee\'s name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Complainee's Role in the University",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
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
                    hint: const Text('Select role in the university'),
                    value: _perpetratorRole,
                    items: ['Student', 'Employee'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _perpetratorRole = newValue;
                      });
                    },
                    validator: (value) => value == null
                        ? 'Please select the Complainee\'s role'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Dynamically change label and options based on Complainee's Role
                  if (_perpetratorRole != null) ...[
                    Text(
                      _perpetratorRole == 'Student'
                          ? "Complainee's Year Level"
                          : "Complainee's Position",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 2.0),
                        ),
                      ),
                      hint: Text(_perpetratorRole == 'Student'
                          ? 'Select Year Level'
                          : 'Select Position'),
                      value: _perpetratorGradeYearLevel,
                      items: _perpetratorRole == 'Student'
                          ? [
                              'Not sure',
                              'Grade 11',
                              'Grade 12',
                              '1st Year College',
                              '2nd Year College',
                              '3rd Year College',
                              '4th Year College',
                              '5th Year College',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList()
                          : [
                              'Not sure',
                              'Administrative Assistant',
                              'Office Manager',
                              'Clerical Worker',
                              'Program Coordinator',
                              'Executive Assistant',
                              'Faculty',
                              'Clerk',
                              'Clerk Staff',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _perpetratorGradeYearLevel = newValue;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Please select ${_perpetratorRole == 'Student' ? 'Year Level' : 'Position'}'
                          : null,
                    ),
                  ],
                ],
              ],
            ],
          ),
        ),
      ),
      isActive: _currentStep >= 1,
    );
  }

  //step 3
  Step _buildCyberbullyingDetailsStep() {
    return Step(
      title: const Text(''),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Incident Report Details',
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.black87,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 20),
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
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      hintText: 'Enter other platform',
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'What type of cyberbullying was involved? (Check all that apply)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.0,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.blue),
                onPressed: () {
                  _showDefinitionsDialog(context);
                },
              ),
            ],
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
          // if (selectedCyberbullyingTypes.contains('Others (Please Specify)'))
          //   Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 4.0),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         const Text(
          //           'Please specify other type of cyberbullying',
          //           style: TextStyle(
          //             fontWeight: FontWeight.bold,
          //             fontSize: 16.0,
          //           ),
          //         ),
          //         const SizedBox(height: 8.0),
          //         TextFormField(
          //           controller: otherCyberbullyingController,
          //           decoration: const InputDecoration(
          //             border: OutlineInputBorder(
          //               borderSide: BorderSide(color: Colors.grey, width: 1.0),
          //             ),
          //             enabledBorder: OutlineInputBorder(
          //               borderSide: BorderSide(color: Colors.grey, width: 1.0),
          //             ),
          //             focusedBorder: OutlineInputBorder(
          //               borderSide: BorderSide(color: Colors.blue, width: 2.0),
          //             ),
          //             hintText: 'Enter other type of cyberbullying',
          //           ),
          //           validator: (value) {
          //             if (selectedCyberbullyingTypes
          //                     .contains('Others (Please Specify)') &&
          //                 (value == null || value.isEmpty)) {
          //               return 'Please specify the other type of cyberbullying';
          //             }
          //             return null;
          //           },
          //         ),
          //       ],
          //     ),
          //   ),
          const SizedBox(height: 20),
          // const Text(
          //   'Were there any witnesses to the incident?',
          //   style: TextStyle(
          //     fontWeight: FontWeight.bold,
          //     fontSize: 17.0,
          //   ),
          // ),
          // const SizedBox(height: 8),
          // DropdownButtonFormField<String>(
          //   value: _hasWitnesses,
          //   decoration: const InputDecoration(
          //     border: OutlineInputBorder(
          //       borderSide: BorderSide(color: Colors.grey, width: 1.0),
          //     ),
          //     enabledBorder: OutlineInputBorder(
          //       borderSide: BorderSide(color: Colors.grey, width: 1.0),
          //     ),
          //     focusedBorder: OutlineInputBorder(
          //       borderSide: BorderSide(color: Colors.grey, width: 2.0),
          //     ),
          //     contentPadding: EdgeInsets.symmetric(horizontal: 16),
          //   ),
          //   hint: const Text('Select an option'),
          //   items: ['Yes', 'No'].map((String value) {
          //     return DropdownMenuItem<String>(
          //       value: value,
          //       child: Text(value),
          //     );
          //   }).toList(),
          //   onChanged: (String? newValue) {
          //     setState(() {
          //       _hasWitnesses = newValue;
          //     });
          //   },
          //   validator: (value) =>
          //       value == null ? 'Please select an option' : null,
          // ),
          // if (_hasWitnesses == 'Yes')
          //   Padding(
          //     padding: const EdgeInsets.only(top: 16),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         const Text(
          //             'If yes, please provide their names and contact information:',
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //               fontSize: 17.0,
          //             )),
          //         const SizedBox(height: 8),
          //         TextFormField(
          //           controller: _witnessInfo,
          //           decoration: InputDecoration(
          //             border: const OutlineInputBorder(
          //               borderSide: BorderSide(color: Colors.grey, width: 1.0),
          //             ),
          //             enabledBorder: const OutlineInputBorder(
          //               borderSide: BorderSide(color: Colors.grey, width: 1.0),
          //             ),
          //             focusedBorder: const OutlineInputBorder(
          //               borderSide: BorderSide(color: Colors.grey, width: 2.0),
          //             ),
          //             hintText: 'Name / Contact',
          //             hintStyle: TextStyle(
          //               color: Colors.black.withOpacity(0.6),
          //             ),
          //           ),
          //           validator: (value) => value?.isEmpty ?? true
          //               ? 'Please specify witness information'
          //               : null,
          //         ),
          //       ],
          //     ),
          //   ),
          // const SizedBox(height: 20),
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
                onPressed: selectImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 228, 228, 228),
                  foregroundColor: const Color.fromARGB(255, 44, 44, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text(
                  'Convert image to text',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: incidentDetailsController,
            maxLines: 12,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1A4594), width: 1.0),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              hintText:
                  'Enter detailed description of the incident here including date & time (Maximum of 500 words)...',
              hintStyle: TextStyle(
                color: Colors.black.withOpacity(0.6),
              ),
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
            'Please upload any image evidence related to the cyberbullying incident:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
          ),
          const SizedBox(height: 20),
          if (_images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Uploaded Images: ${_images.length}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Container(
            height: 350,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey[200]!),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  bottom: 70,
                  child: _images.isEmpty
                      ? const Center(
                          child: Text(
                            "No Images Selected",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16.0,
                            ),
                          ),
                        )
                      : _images.length == 1
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: double.infinity, // Ensure full width
                                  height:
                                      240, // Fixed height to match grid cell height (accounting for padding and spacing)
                                  child: Image.file(
                                    _images[0],
                                    fit: BoxFit
                                        .contain, // Consistent sizing from your reference
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _images.removeAt(
                                            0); // Remove the single image
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.white, width: 1.5),
                                      ),
                                      child: const Icon(Icons.close,
                                          size: 18, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    2, // Two-column grid from your reference
                                childAspectRatio:
                                    1, // Square aspect ratio from your reference
                                crossAxisSpacing:
                                    4, // Matching spacing from your reference
                                mainAxisSpacing:
                                    4, // Matching spacing from your reference
                              ),
                              itemCount: _images.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(
                                          4.0), // Matching padding from your reference
                                      child: Image.file(
                                        _images[index],
                                        fit: BoxFit
                                            .contain, // Changed to match single image sizing from your reference
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _images.removeAt(
                                                index); // Remove the specific image
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.7),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.white,
                                                width: 1.5),
                                          ),
                                          child: const Icon(Icons.close,
                                              size: 18, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: getImage,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add_circle_outline,
                              size: 30, color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: captureImage,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.camera_alt_outlined,
                              size: 30, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 2,
    );
  }

  //step 4
  bool _agreementChecked = false;
  Step _buildVictimInformationStep() {
    final supportTypes = [
      'Counseling for the complainant',
      'Talk between the complainant and complainee',
      'Disciplinary action against the complainee',
      'Others (Please Specify)'
    ];

    return Step(
      title: const Text(''),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions & Support Details',
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.black87,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Have you reported this incident to other Office/College/Department?',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Please specify the Office/College/Department',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0,
                          ),
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.help_outline, color: Colors.blue),
                        onPressed: () {
                          _showDepartmentsDialog(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _departmentCollege,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                      hintText: '(e.g., CSFD, CGCS, CCIS)',
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please specify the Department or College'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                      'Name of person from Office/College/Department you\'ve reported this incident.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      )),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reportedTo,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                      hintText: 'Full Name',
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please specify to whom you reported'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                      'Have any actions been taken to address or resolve this matter?',
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
                            controller: _describeActionsTaken,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 2.0),
                              ),
                              hintText: 'Describe the actions taken',
                              hintStyle: TextStyle(
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Please describe the actions taken'
                                : null,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          if (_submitAs ==
              'Yes, I am the complainant (directly affected by the cyberbullying).') ...[
            const Text(
              'What type of support would you like to receive?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: supportTypes.map((type) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  title: Text(type),
                  value: selectedSupportTypes.contains(type),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected ?? false) {
                        selectedSupportTypes.add(type);
                      } else {
                        selectedSupportTypes.remove(type);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            if (selectedSupportTypes.contains('Others (Please Specify)'))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: otherSupportController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        hintText: 'Specify other support',
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                      validator: (value) {
                        if (selectedSupportTypes
                                .contains('Others (Please Specify)') &&
                            (value == null || value.isEmpty)) {
                          return 'Please specify the other type of support';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
          ] else if (_submitAs ==
              'No, I am submitting as a witness, friend, or other third party.') ...[
            const Text(
              'Would you like to participate in an investigation if one is needed?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Yes, I would like to participate.',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: true,
                  ),
                  leading: Radio<String>(
                    value: 'Yes, I would like to participate.',
                    groupValue: _witnessChoice,
                    onChanged: (String? newValue) {
                      setState(() {
                        _witnessChoice = newValue;
                      });
                    },
                    activeColor: Colors.blue,
                    fillColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.blue;
                        }
                        return Colors.blue[200]!;
                      },
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'No, please keep my identity confidential regarding this event.',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: true,
                  ),
                  leading: Radio<String>(
                    value:
                        'No, please keep my identity confidential regarding this event.',
                    groupValue: _witnessChoice,
                    onChanged: (String? newValue) {
                      setState(() {
                        _witnessChoice = newValue;
                      });
                    },
                    activeColor: Colors.blue,
                    fillColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.blue;
                        }
                        return Colors.blue[200]!;
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (_witnessChoice == 'Yes, I would like to participate.') ...[
              const Text(
                'May we contact you if the investigation starts?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _contactChoice,
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
                    _contactChoice = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select an option' : null,
              ),
            ],
          ],
          const SizedBox(height: 20),
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
    // _victimNameController.dispose();
    super.dispose();
  }

  void _clearFormInputs() {
    setState(() {
      // _victimNameController.clear();
      _departmentCollege.clear();
      _reportedTo.clear();
      _perpetratorName.clear();
      _describeActionsTaken.clear();
      // _witnessInfo.clear();
      otherPlatformController.clear();
      // otherCyberbullyingController.clear();
      // witnessNamesController.clear();
      incidentDetailsController.clear();
      otherSupportController.clear();
      _agreementChecked = false;
      _actionsTaken = null;
      _contactChoice = null;
      // _victimGradeYearLevel = null;
      _perpetratorGradeYearLevel = null;
      _relationship = null;
      _submitAs = null;
      _witnessChoice = null;
      // _victimRole = null;
      _perpetratorRole = null;
      _hasReportedBefore = null;
      // _hasWitnesses = null;
      _agreedToPrivacyPolicy = false;
      selectedPlatforms.clear();
      selectedCyberbullyingTypes.clear();
      selectedSupportTypes.clear();
      _images.clear();
      _currentStep = 0;
    });
  }

  void showLoadingDialog(BuildContext context,
      {String message = 'Submitting report...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A4594)),
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDefinitionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Cyberbullying Types',
          style: TextStyle(
            color: Color(0xFF1C4494),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          height: 450,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: cyberbullyingTypes.map((type) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• $type',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cyberbullyingDefinitions[type] ??
                            'No definition available',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Close', style: TextStyle(color: Color(0xFF1C4494))),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showDepartmentsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Departments and Colleges',
          style: TextStyle(
            color: Color(0xFF1C4494),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const SizedBox(
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Institutes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('• Institute of Pharmacy (IOP)'),
                Text('• Institute of Nursing (ION)'),
                Text('• Institute of Imaging Health Sciences (IIHS)'),
                Text('• Institute of Psychology (IOPsy)'),
                Text('• Institute of Arts and Design (IAD)'),
                Text(
                    '• Institute for Social Development and Nation Building (ISNDB)'),
                Text('• Institute of Accountancy (IOA)'),
                Text(
                    '• Institute for Technical Education and Skills Training (ITEST)'),
                SizedBox(height: 8),
                Text(
                  'College',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('• College of Human Kinetics (CHK)'),
                Text('• College of Business and Financial Science (CBFS)'),
                Text('• College of Computing and Information Sciences (CCIS)'),
                Text('• College of Governance and Public Policy (CGPP)'),
                Text('• College of Engineering Technology (CET)'),
                Text(
                    '• College of Construction Sciences and Engineering (CCSE)'),
                Text('• College of Innovative Teacher Education (CITE)'),
                Text('• Higher School ng UMAK (HSU)'),
                Text('• College of Tourism and Hospitality Management (CTHM)'),
                Text('• College of Liberal Arts & Sciences (CLAS)'),
                SizedBox(height: 8),
                Text(
                  'Administration and Offices',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('• Office of the University President (OP)'),
                Text(
                    '• Office of the Vice President for Academic Affairs (OVPAA)'),
                Text(
                    '• Office of the Vice President for Planning and Research (OVPPR)'),
                Text(
                    '• Office of the Vice President for Student Services and Community Development (OVPSSCD)'),
                Text(
                    '• Office of the Vice President for Administration (OVPA)'),
                Text('• Office of the Vice President for Finance (OVPF)'),
                Text('• Office of the University Secretary (OUSEC)'),
                SizedBox(height: 8),
                Text(
                  'Others',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                    '• College of Continuing, Advanced and Professional Studies (CCAPS)'),
                Text('• School of Law (SOL)'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Close', style: TextStyle(color: Color(0xFF1C4494))),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showTermsAndConditionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms and Conditions and Data Privacy Policy',
            style: TextStyle(color: Color(0xFF1C4494))),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Introduction\nThese Terms and Conditions ("Terms") govern the use of the BullyProof mobile application ("App") developed by Intellitech, a group of students at the University of Makati (UMAK). The App is exclusively for use by students, employees, and authorized personnel of UMAK. By accessing and using the App, you ("User") agree to comply with these Terms. If you do not agree to these Terms, please do not use the App.\n\n'
                '2. Eligibility\nYou must be at least 18 years of age and a current student, employee, or authorized personnel of the University of Makati (UMAK) to use this App. By using the App, you represent and warrant that you meet this eligibility requirement.\n\n'
                '3. User Registration\nTo use certain features of the App, users may need to register an account. You agree to provide accurate, complete, and current information during the registration process, such as your UMAK student ID, employee ID, or other UMAK affiliation, and to maintain the security and confidentiality of your account. You may choose to remain anonymous when reporting incidents, as permitted by the App.\n\n'
                '4. Use of the App\nYou agree to:\n- Use the App for lawful purposes only, such as reporting cyberbullying incidents within the UMAK community.\n- Not engage in any activity that may disrupt or damage the App\'s functionality.\n- Not use the App to transmit malicious software, such as viruses or malware, or to harass, threaten, or harm others within or outside the UMAK community.\n\n'
                '5. Intellectual Property\nAll content on the App, including text, images, logos, and trademarks, is the intellectual property of Intellitech or its contributors at UMAK and is protected by intellectual property laws in the Philippines. You are granted a limited, non-exclusive license to use the App for personal, non-commercial purposes related to reporting and addressing cyberbullying within UMAK.\n\n'
                '6. Termination\nIntellitech may, at its sole discretion, suspend or terminate your access to the App if you violate these Terms, with or without notice, in consultation with UMAK authorities as needed.\n\n'
                '7. Disclaimer of Warranties\nThe App is provided "as is" and "as available." Intellitech does not provide any warranties or representations regarding the App\'s functionality, availability, or fitness for a particular purpose, except as required by law.\n\n'
                '8. Limitation of Liability\nTo the fullest extent permitted by law, Intellitech shall not be liable for any damages arising from the use or inability to use the App, including but not limited to direct, indirect, incidental, or consequential damages, related to cyberbullying reports or their outcomes within UMAK.\n\n'
                '9. Governing Law\nThese Terms shall be governed by and construed in accordance with the laws of the Philippines.\n\n'
                '10. Changes to Terms\nIntellitech reserves the right to modify or update these Terms at any time, in consultation with UMAK advisors. You will be notified of any changes via the App or email, and continued use of the App after such changes constitutes acceptance of the new Terms.\n\n'
                'DATA PRIVACY POLICY\n\n'
                '1. Introduction\nThis Data Privacy Policy outlines how Intellitech, a group of students at the University of Makati (UMAK), collects, uses, and protects your personal information when you use the BullyProof mobile application ("App"). We are committed to protecting your privacy in accordance with the Data Privacy Act of 2012 (Republic Act No. 10173) and other applicable laws in the Philippines, especially for users in the UMAK community.\n\n'
                '2. Personal Information We Collect\nWe collect the following types of personal information, which may be optional or anonymized:\n- Account Information: Your name, email address, phone number, or UMAK student/employee ID (optional, as you may report anonymously).\n- Device Information: Information about your device, including device type, operating system, and IP address (used for security and functionality).\n- Usage Data: Information about how you use the App, including activity logs related to reporting cyberbullying incidents.\nWe do not collect location information unless explicitly provided by the user for reporting purposes, and we prioritize anonymity where possible.\n\n'
                '3. How We Use Your Personal Information\nWe use your personal information for the following purposes:\n- To process and manage reports of cyberbullying submitted through the App within the UMAK community.\n- To communicate with you about your report, updates, or necessary follow-ups (e.g., with UMAK administrators or counselors).\n- To improve the App’s functionality and ensure a safe reporting environment for UMAK users.\n- To comply with legal obligations, such as reporting to UMAK authorities or law enforcement as required by law.\n\n'
                '4. Legal Basis for Data Processing\nWe process your personal information based on the following legal grounds:\n- Consent: By using the App, you consent to the collection and processing of your personal information for the purposes outlined in this policy.\n- Legitimate Interests: We process data to support a safe UMAK community and fulfill our mission to address cyberbullying, balancing your privacy with our educational goals.\n- Legal Obligations: We may process data to comply with UMAK policies, the Data Privacy Act of 2012, or other legal requirements.\n\n'
                '5. How We Protect Your Personal Information\nWe implement reasonable technical, administrative, and physical safeguards to protect your personal information from unauthorized access, loss, or misuse. We prioritize anonymity for reporters and limit data access to authorized UMAK personnel (e.g., administrators, counselors). However, please note that no method of transmission over the internet or electronic storage is 100% secure.\n\n'
                '6. Data Sharing and Disclosure\nWe do not sell, trade, or rent your personal information to third parties. We may share your information with:\n- UMAK authorities or administrators to address reported incidents, with your consent or as required by UMAK policies or law.\n- Trusted third-party service providers who assist in operating the App (e.g., cloud storage, analytics), under strict confidentiality agreements and with UMAK oversight.\n- Law enforcement or regulatory bodies if required by law or to protect the safety of the UMAK community.\n\n'
                '7. Data Retention\nWe will retain your personal information for as long as necessary to fulfill the purposes outlined in this policy, comply with UMAK policies, or meet legal requirements, such as investigation records. Anonymous reports may be retained for statistical purposes within UMAK without identifiable data.\n\n'
                '8. Your Data Privacy Rights\nAs a data subject under the Data Privacy Act of 2012, you have the following rights:\n- Right to Access: You may request access to the personal information we hold about you.\n- Right to Rectification: You may request correction of any inaccurate or incomplete information.\n- Right to Erasure: You may request the deletion of your personal information under certain circumstances, unless retention is required by law or UMAK policy.\n- Right to Object: You may object to the processing of your personal information for specific purposes, except where legally required.\n- Right to Portability: You may request a copy of your personal information in a structured, commonly used format.\nTo exercise any of these rights, please contact us at bullyproofumak@gmail.com.\n\n'
                '9. Children\'s Privacy\nOur App is intended for students, employees, and authorized personnel of UMAK who are at least 18 years old. We do not knowingly collect personal information from individuals under 18, as the App is restricted to users 18 and older.\n\n'
                '10. Changes to This Privacy Policy\nWe may update this Data Privacy Policy from time to time. If we make significant changes, we will notify you through the App or via email. Please review this policy periodically for any updates.\n\n'
                '11. Contact Information\nIf you have any questions or concerns about this Privacy Policy or how we handle your personal information, please contact us at:\n\n'
                'Intellitech, University of Makati\n'
                'J.P. Rizal Extension, West Rembo, Makati City\n'
                'Email: bullyproofumak@gmail.com\n'
                'Phone: +639052814840\n',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Close', style: TextStyle(color: Color(0xFF1C4494))),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}
