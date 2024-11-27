// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:gallery_picker/gallery_picker.dart';
import 'package:gallery_picker/models/media_file.dart';
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

  final _victimNameController = TextEditingController();
  final _departmentCollege = TextEditingController();
  final _reportedTo = TextEditingController();
  final _perpetratorName = TextEditingController();
  final _describeActionsTaken = TextEditingController();
  final _witnessInfo = TextEditingController();

  String? _relationship;
  String? _victimRole;
  String? _victimGradeYearLevel;
  String? _perpetratorRole;
  String? _perpetratorGradeYearLevel;
  String? _hasWitnesses;
  String? _hasReportedBefore;
  String? _actionsTaken;

  final otherRelationship = TextEditingController();
  // final otherVictimRole = TextEditingController();
  // final otherVictimGradeYearLevelController = TextEditingController();
  // final otherPerpetratorRole = TextEditingController();
  // final otherPerpetratorGradeYearLevelController = TextEditingController();
  final otherPlatformController = TextEditingController();
  final otherCyberbullyingController = TextEditingController();
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
    showLoadingDialog(context);

    String combinedText = "";
    for (var file in _selectedImages) {
      final text = await _extractText(file);
      if (text != null && text.isNotEmpty) {
        combinedText += "$text\n";
      }
    }

    setState(() {
      hideLoadingDialog(context);
      incidentDetailsController.text = combinedText;
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
    if (otherPlatformController.text.isNotEmpty) {
      selectedPlatforms.add(otherPlatformController.text);
    }
    if (otherCyberbullyingController.text.isNotEmpty) {
      selectedCyberbullyingTypes.add(otherCyberbullyingController.text);
    }

    List<String> base64Images = [];
    for (File image in _images) {
      List<int> imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      base64Images.add(base64Image);
    }

    var regBody = {
      "victimRelationship": _relationship,
      "otherVictimRelationship": otherRelationship.text,
      "victimName": _victimNameController.text,
      "victimType": _victimRole,
      "gradeYearLevel": _victimGradeYearLevel,
      "hasReportedBefore": _hasReportedBefore,
      "departmentCollege": _departmentCollege.text,
      "reportedTo": _reportedTo.text,
      "platformUsed": selectedPlatforms,
      "otherPlatformUsed": otherPlatformController.text,
      "hasWitness": _hasWitnesses,
      "witnessInfo": _witnessInfo.text,
      "incidentDetails": incidentDetailsController.text,
      "incidentEvidence": base64Images,
      "perpetratorName": _perpetratorName.text,
      "perpetratorRole": _perpetratorRole,
      "perpetratorGradeYearLevel": _perpetratorGradeYearLevel,
      "supportTypes": selectedSupportTypes,
      "otherSupportTypes": otherSupportController.text,
      "actionsTaken": _actionsTaken,
      "describeActions": _describeActionsTaken.text,
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
                                _showSuccessDialog = false;
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
        // Validate relationship
        if (_relationship == null) {
          _logger.warning('Relationship not selected');
          errorMessage = 'Please select your relationship to the Complainant';
          isValid = false;
          break;
        } else if (_relationship == 'Other') {
          if (otherRelationship.text.isEmpty) {
            _logger.warning('Other Relationship not specified');
            errorMessage =
                'Please specify your relationship to the Complainant';
            isValid = false;
            break;
          }
        }

        // Validate victim name
        if (_victimNameController.text.isEmpty) {
          _logger.warning('Complainant name empty');
          errorMessage = "Please enter the Complainant's name";
          isValid = false;
          break;
        }

        // Validate victim role
        if (_victimRole == null) {
          _logger.warning('Complainant role not selected');
          errorMessage =
              "Please select the Complainant's role in the university";
          isValid = false;
          break;
        }

        // Validate victim grade/year level
        if (_victimGradeYearLevel == null) {
          _logger.warning('Complainant grade/year level not selected');
          errorMessage =
              "Please select the Complainant's Program/Year Level or Position";
          isValid = false;
          break;
        }

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

        // Validate witnesses
        if (_hasWitnesses == null) {
          _logger.warning('Option not selected');
          errorMessage = 'Please select witnesses Option';
          isValid = false;
          break;
        } else if (_hasWitnesses == 'Yes') {
          if (_witnessInfo.text.isEmpty) {
            _logger.warning('Witness Name and Contact not specified');
            errorMessage =
                'Please specify the Name and Contact information of witness';
            isValid = false;
            break;
          }
        }

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
          // Victim Information
          const Text('Relationship to the Complainant',
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
            hint: const Text('Select Relationship to the Complainant'),
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
                ? 'Please select your relationship to the Complainant'
                : null,
          ),
          if (_relationship == 'Other')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      'Please specify your relationship to the Complainant',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      )),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: otherRelationship,
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

          const Text("Complainant's Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              )),
          const SizedBox(height: 8),
          TextFormField(
            controller: _victimNameController,
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
                return 'Please enter the Complainant\'s name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          const Text("Complainant's Role in the University",
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
            hint: const Text('Select role in the university'),
            value: _victimRole,
            items: ['Student', 'School Staff', 'Professor'].map((String value) {
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
                value == null ? 'Please select the Complainant\'s role' : null,
          ),
          const SizedBox(height: 20),

          const Text(
            "Complainant's Program/Year Level or Position",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
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
            hint: const Text('Select Program/Year Level or Position'),
            value: _victimGradeYearLevel,
            items: [
              'Grade 11',
              'Grade 12',
              '1st Year College',
              '2nd Year College',
              '3rd Year College',
              '4th Year College',
              '5th Year College',
              'Professor',
              'staff',
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _victimGradeYearLevel = newValue;
              });
            },
            validator: (value) => value == null
                ? 'Please select Program/Year Level or Position'
                : null,
          ),
          const SizedBox(height: 20),
          const Text("Complainee's Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              )),
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

          // Perpetrator's Role in the University
          const Text("Complainee's Role in the University",
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
            hint: const Text('Select role in the university'),
            value: _perpetratorRole,
            items: ['Student', 'Professor', 'School Staff'].map((String value) {
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
                value == null ? 'Please select the Complainee\'s role' : null,
          ),
          const SizedBox(height: 20),
          const Text(
            "Complainee’s Program/Year Level or Position",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
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
            hint: const Text('Select Program/Year Level or Position'),
            value: _perpetratorGradeYearLevel,
            items: [
              'Grade 11',
              'Grade 12',
              '1st Year College',
              '2nd Year College',
              '3rd Year College',
              '4th Year College',
              '5th Year College',
              'Professor',
              'staff',
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _perpetratorGradeYearLevel = newValue;
              });
            },
            validator: (value) => value == null
                ? 'Please select Program/Year Level or Position'
                : null,
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

    final List<String> witnessOptions = ['Yes', 'No'];

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
          // const Text(
          //   'What type of cyberbullying was involved? (Check all that apply)',
          //   style: TextStyle(
          //     fontWeight: FontWeight.bold,
          //     fontSize: 17.0,
          //   ),
          // ),
          // const SizedBox(height: 16),
          // Column(
          //   children: cyberbullyingTypes.map((type) {
          //     return CheckboxListTile(
          //       contentPadding: EdgeInsets.zero,
          //       controlAffinity: ListTileControlAffinity.leading,
          //       visualDensity:
          //           const VisualDensity(horizontal: -4, vertical: -4),
          //       title: Text(type),
          //       value: selectedCyberbullyingTypes.contains(type),
          //       onChanged: (bool? selected) {
          //         setState(() {
          //           if (selected ?? false) {
          //             selectedCyberbullyingTypes.add(type);
          //           } else {
          //             selectedCyberbullyingTypes.remove(type);
          //           }
          //         });
          //       },
          //     );
          //   }).toList(),
          // ),
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
          // const SizedBox(height: 20),
          const Text(
            'Were there any witnesses to the incident?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _hasWitnesses,
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
                _hasWitnesses = newValue;
              });
            },
            validator: (value) =>
                value == null ? 'Please select an option' : null,
          ),
          if (_hasWitnesses == 'Yes')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      'If yes, please provide their names and contact information:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      )),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _witnessInfo,
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
                      hintText: 'Name / Contact',
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please specify witness information'
                        : null,
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
                onPressed: selectImage,
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
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1A4594), width: 1.0),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              hintText:
                  'Enter detailed description of the incident here (Maximum of 500 words)...',
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
            'Please provide any evidence related to the incident:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 300, // Increased height for better visibility
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  bottom: 40,
                  child: _images.isEmpty
                      ? const Center(
                          child: Text("No Images are selected"),
                        )
                      : _images.length == 1
                          ? Center(
                              child: Image.file(
                                _images[0],
                                fit: BoxFit.contain,
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                              itemCount: _images.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.file(
                                    _images[index],
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: getImage,
                        child: const Icon(Icons.add_circle_outline, size: 27),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: captureImage,
                        child: const Icon(Icons.camera_alt_outlined, size: 27),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.mic_outlined, size: 27),
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
      'Counseling for the victim',
      'Talk between the victim and perpetrator',
      'Disciplinary action against the perpetrator',
      'Others (Please Specify)'
    ];

    return Step(
      title: const Text(''),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Have you reported this incident to other department or college?',
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
                  const Text('Please specify the Department or College',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      )),
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
                      'Name of the person from the department or college you\'ve reported this incident.',
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
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      hintText: 'Specify other support',
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    validator: (value) {
                      if (selectedCyberbullyingTypes
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
    _victimNameController.dispose();
    super.dispose();
  }

  void _clearFormInputs() {
    setState(() {
      _victimNameController.clear();
      _departmentCollege.clear();
      _reportedTo.clear();
      _perpetratorName.clear();
      _describeActionsTaken.clear();
      _witnessInfo.clear();
      otherPlatformController.clear();
      otherCyberbullyingController.clear();
      witnessNamesController.clear();
      incidentDetailsController.clear();
      otherSupportController.clear();
      _agreementChecked = false;
      _actionsTaken = null;
      _victimGradeYearLevel = null;
      _perpetratorGradeYearLevel = null;
      _relationship = null;
      _victimRole = null;
      _perpetratorRole = null;
      _hasReportedBefore = null;
      _hasWitnesses = null;
      _agreedToPrivacyPolicy = false;
      selectedPlatforms.clear();
      selectedCyberbullyingTypes.clear();
      selectedSupportTypes.clear();
      _images.clear();
      _currentStep = 0;
    });
  }

  _successMessage(BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
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
                      "Your report has been submitted!",
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
      ),
    );
  }

  void showLoadingDialog(BuildContext context) {
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
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A4594)),
                ),
                SizedBox(height: 20),
                Text(
                  'Converting image to text...',
                  style: TextStyle(
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

  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}
