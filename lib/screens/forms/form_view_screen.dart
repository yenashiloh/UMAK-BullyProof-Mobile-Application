// lib/screens/forms/form_view_screen.dart (updated)
import 'dart:convert';
import 'package:bully_proof_umak/services/form_service.dart';
import 'package:flutter/material.dart';
import 'package:bully_proof_umak/models/form_model.dart';
import 'package:bully_proof_umak/models/form_element_model.dart';
import 'package:bully_proof_umak/services/form_element_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FormViewScreen extends StatefulWidget {
  final FormModel form;
  final String token;
  final String userId;

  const FormViewScreen({
    super.key,
    required this.form,
    required this.token,
    required this.userId,
  });

  @override
  State<FormViewScreen> createState() => _FormViewScreenState();
}

class _FormViewScreenState extends State<FormViewScreen> {
  int _currentStep = 1;
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<FormElementModel> _formElements = [];
  Map<String, dynamic> _formData = {};

  // Controllers for various form elements
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, String?> _dropdownValues = {};
  final Map<String, List<String>> _checkboxValues = {};
  final Map<String, String?> _radioValues = {};
  final Map<String, List<File>> _fileValues = {};

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchFormElements();
  }

  @override
  void dispose() {
    _textControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _fetchFormElements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final elements = await FormElementService.fetchFormElements(
          widget.token, widget.form.id);

      elements.sort(
          (a, b) => int.parse(a.position).compareTo(int.parse(b.position)));

      setState(() {
        _formElements = elements;
        _initializeControllers(elements);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching form elements: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load form elements: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFile(
      FormElementModel element,
      FormFieldState<List<File>> state,
      List<String> allowedFileTypes,
      bool allowSpecificTypes) async {
    try {
      // Determine file type filter based on allowed types
      FileType fileType = FileType.any;
      List<String>? allowedExtensions;

      if (allowSpecificTypes && allowedFileTypes.isNotEmpty) {
        if (allowedFileTypes.contains('image') &&
            allowedFileTypes.length == 1) {
          fileType = FileType.image;
        } else if (allowedFileTypes.contains('pdf') &&
            allowedFileTypes.length == 1) {
          fileType = FileType.custom;
          allowedExtensions = ['pdf'];
        } else if (allowedFileTypes.contains('video') &&
            allowedFileTypes.length == 1) {
          fileType = FileType.video;
        } else if (allowedFileTypes.contains('audio') &&
            allowedFileTypes.length == 1) {
          fileType = FileType.audio;
        } else if (allowedFileTypes.contains('media') &&
            allowedFileTypes.length == 1) {
          fileType = FileType.media;
        } else {
          fileType = FileType.custom;
          allowedExtensions = [];

          for (var type in allowedFileTypes) {
            switch (type) {
              case 'image':
                allowedExtensions.addAll(['jpg', 'jpeg', 'png', 'gif', 'webp']);
                break;
              case 'pdf':
                allowedExtensions.add('pdf');
                break;
              case 'video':
                allowedExtensions.addAll(['mp4', 'mov', 'avi', 'wmv']);
                break;
              case 'audio':
                allowedExtensions.addAll(['mp3', 'wav', 'ogg', 'm4a']);
                break;
            }
          }
        }
      }

      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions:
            fileType == FileType.custom ? allowedExtensions : null,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile platformFile = result.files.first;

        if (platformFile.path != null) {
          final file = File(platformFile.path!);

          // Add file to the list
          setState(() {
            _fileValues[element.id]!.add(file);
            state.didChange(_fileValues[element.id]);
          });
        }
      }
    } catch (e) {
      print('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto(
      FormElementModel element, FormFieldState<List<File>> state) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80, // Slightly compress the image
    );

    if (pickedFile != null) {
      setState(() {
        _fileValues[element.id]!.add(File(pickedFile.path));
        state.didChange(_fileValues[element.id]);
      });
    }
  }

  void _initializeControllers(List<FormElementModel> elements) {
    for (var element in elements) {
      if (element.elementType == 'paragraph') {
        _textControllers[element.id] = TextEditingController();
      }
    }
  }

  List<FormElementModel> _getCurrentStepElements() {
    if (_formElements.isEmpty) return [];

    final currentStepId = widget.form.steps[_currentStep - 1].id;
    return _formElements
        .where((element) => element.stepId == currentStepId)
        .toList();
  }

  bool _validateCurrentStep() {
    if (_formKey.currentState?.validate() ?? false) {
      _saveCurrentStepData();
      return true;
    }
    return false;
  }

  void _saveCurrentStepData() {
    final currentElements = _getCurrentStepElements();

    for (var element in currentElements) {
      switch (element.elementType) {
        case 'paragraph':
          _formData[element.id] = _textControllers[element.id]?.text ?? '';
          break;
        case 'dropdown':
          _formData[element.id] = _dropdownValues[element.id];
          break;
        case 'multiple_choice':
          _formData[element.id] = _radioValues[element.id];
          break;
        case 'checkbox':
          _formData[element.id] = _checkboxValues[element.id];
          break;
        case 'file_upload':
          _formData[element.id] = _fileValues[element.id];
          break;
      }
    }
  }

  // Update the _submitForm method in form_view_screen.dart
  Future<void> _submitForm() async {
    if (!_validateCurrentStep()) return;

    // Show loading indicator
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Organize data by steps
      final Map<String, Map<String, dynamic>> stepsData = {};

      // Prepare completed steps list
      final List<String> completedSteps = [];

      // Process each step
      for (int i = 0; i < widget.form.steps.length; i++) {
        final String stepId = widget.form.steps[i].id;
        completedSteps.add(stepId);

        // Get elements for this step
        final stepElements =
            _formElements.where((element) => element.stepId == stepId).toList();

        // Create data map for this step
        final Map<String, dynamic> stepDataMap = {};

        for (var element in stepElements) {
          dynamic value;

          switch (element.elementType) {
            case 'paragraph':
              value = _textControllers[element.id]?.text ?? '';
              break;
            case 'dropdown':
              value = _dropdownValues[element.id];
              break;
            case 'multiple_choice':
              value = _radioValues[element.id];
              break;
            case 'checkbox':
              value = _checkboxValues[element.id] ?? [];
              break;
            case 'file_upload':
              // For file uploads, convert to base64 strings
              List<Map<String, dynamic>> fileDataList = [];

              if (_fileValues.containsKey(element.id)) {
                for (File file in _fileValues[element.id]!) {
                  // Read file as bytes
                  List<int> fileBytes = await file.readAsBytes();
                  // Convert to base64
                  String base64File = base64Encode(fileBytes);
                  // Get filename
                  String fileName = file.path.split('/').last;

                  // Create a map with file info
                  fileDataList.add({
                    'fileName': fileName,
                    'fileContent': base64File,
                    'fileSize': fileBytes.length,
                    'fileType': fileName.split('.').last.toLowerCase(),
                  });
                }
              }

              value = fileDataList;
              break;
          }

          // Add to step data map
          stepDataMap[element.id] = value;
        }

        // Add to steps data
        stepsData[stepId] = stepDataMap;
      }

      // Create the final form data object
      final formData = {
        "form_builder_id": widget.form.id,
        "steps_data": stepsData,
        "completed_steps": completedSteps,
        "reported_by": widget.userId,
        "status": "For Review",
        "validated": true,
        "reported_at": DateTime.now().toIso8601String(),
        "last_modified_at": DateTime.now().toIso8601String(),
        "metadata": {"device_info": "mobile", "form_version": "1.0"}
      };

      // Submit the form
      final success = await FormService.submitFormData(widget.token, formData);

      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Form submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Form submission failed');
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting form: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Hide loading indicator
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A4594),
        title: Text(
          widget.form.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < widget.form.steps.length; i++) ...[
            // Step indicator
            _buildStepIndicator(i + 1),

            // Connector line (except after the last step)
            if (i < widget.form.steps.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: 20,
                  height: 2,
                  color: i < _currentStep - 1
                      ? const Color(0xFF1A4594)
                      : Colors.grey[300],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step) {
    bool isCompleted = step < _currentStep;
    bool isCurrent = step == _currentStep;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted || isCurrent
            ? const Color(0xFF1A4594)
            : Colors.grey[300],
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            color: isCompleted || isCurrent ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final currentElements = _getCurrentStepElements();

    if (currentElements.isEmpty) {
      return const Center(
        child: Text('No form elements found for this step.'),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Step title as heading
          Text(
            widget.form.steps[_currentStep - 1].title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A4594),
            ),
          ),
          const SizedBox(height: 20),
          ...currentElements.map(_buildFormElement).toList(),
        ],
      ),
    );
  }

  Widget _buildFormElement(FormElementModel element) {
    switch (element.elementType) {
      case 'paragraph':
        return _buildParagraphField(element);
      case 'dropdown':
        return _buildDropdownField(element);
      case 'multiple_choice':
        return _buildMultipleChoiceField(element);
      case 'checkbox':
        return _buildCheckboxField(element);
      case 'file_upload':
        return _buildFileUploadField(element);
      default:
        return ListTile(
          title: Text('Unsupported element type: ${element.elementType}'),
        );
    }
  }

  Widget _buildParagraphField(FormElementModel element) {
    if (!_textControllers.containsKey(element.id)) {
      _textControllers[element.id] = TextEditingController();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: element.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (element.isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _textControllers[element.id],
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF1A4594), width: 2),
              ),
              hintText: 'Enter your answer here',
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 5,
            style: const TextStyle(fontSize: 16),
            validator: element.isRequired
                ? (value) => (value == null || value.isEmpty)
                    ? 'This field is required'
                    : null
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(FormElementModel element) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: element.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (element.isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _dropdownValues[element.id],
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF1A4594), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            hint: const Text('Select an option'),
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1A4594)),
            isExpanded: true,
            items: element.options.map((option) {
              return DropdownMenuItem<String>(
                value: option.id,
                child: Text(option.text),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _dropdownValues[element.id] = value;
              });
            },
            validator: element.isRequired
                ? (value) => value == null ? 'This field is required' : null
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceField(FormElementModel element) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: element.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (element.isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FormField<String>(
            initialValue: _radioValues[element.id],
            validator: element.isRequired
                ? (value) => value == null ? 'This field is required' : null
                : null,
            builder: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...element.options.map((option) {
                    return RadioListTile<String>(
                      title: Text(
                        option.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                      value: option.id,
                      groupValue: _radioValues[element.id],
                      activeColor: const Color(0xFF1A4594),
                      contentPadding: EdgeInsets.zero,
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                      onChanged: (value) {
                        setState(() {
                          _radioValues[element.id] = value;
                          state.didChange(value);
                        });
                      },
                    );
                  }).toList(),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 8),
                      child: Text(
                        state.errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxField(FormElementModel element) {
    if (!_checkboxValues.containsKey(element.id)) {
      _checkboxValues[element.id] = [];
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: element.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (element.isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FormField<List<String>>(
            initialValue: _checkboxValues[element.id],
            validator: element.isRequired
                ? (value) => (value == null || value.isEmpty)
                    ? 'Please select at least one option'
                    : null
                : null,
            builder: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...element.options.map((option) {
                    return CheckboxListTile(
                      title: Text(
                        option.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                      value: _checkboxValues[element.id]!.contains(option.id),
                      activeColor: const Color(0xFF1A4594),
                      contentPadding: EdgeInsets.zero,
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                      controlAffinity: ListTileControlAffinity.trailing,
                      onChanged: (checked) {
                        setState(() {
                          if (checked!) {
                            _checkboxValues[element.id]!.add(option.id);
                          } else {
                            _checkboxValues[element.id]!.remove(option.id);
                          }
                          state.didChange(_checkboxValues[element.id]);
                        });
                      },
                    );
                  }).toList(),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 8),
                      child: Text(
                        state.errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadField(FormElementModel element) {
    if (!_fileValues.containsKey(element.id)) {
      _fileValues[element.id] = [];
    }

    // Parse settings
    final settings = element.settings;
    final maxFilesString = settings['max_files'] ?? '1';
    int maxFiles = 1; // Default

    // Handle different max_files values
    if (maxFilesString == 'Unlimited') {
      maxFiles = 100; // A high number to represent unlimited
    } else {
      maxFiles = int.tryParse(maxFilesString) ?? 1;
    }

    // Get file type restrictions
    final allowSpecificTypes = settings['allow_specific_types'] == 'true';
    List<String> allowedFileTypes = [];

    if (allowSpecificTypes && settings['file_types'] != null) {
      if (settings['file_types'] is List) {
        allowedFileTypes = List<String>.from(settings['file_types']);
      } else if (settings['file_types'] is String) {
        try {
          final dynamic parsedTypes = jsonDecode(settings['file_types']);
          if (parsedTypes is List) {
            allowedFileTypes = List<String>.from(parsedTypes);
          }
        } catch (e) {
          print('Error parsing file types: $e');
        }
      }
    }

    // Parse max file size
    final maxFileSizeString = settings['max_file_size'] ?? '10';
    String maxFileSizeLabel = '10 MB'; // Default label

    switch (maxFileSizeString) {
      case '1':
        maxFileSizeLabel = '1 MB';
        break;
      case '10':
        maxFileSizeLabel = '10 MB';
        break;
      case '100':
        maxFileSizeLabel = '100 MB';
        break;
      case '1000':
        maxFileSizeLabel = '1 GB';
        break;
    }

    String fileTypeHint = 'Any file type';
    if (allowSpecificTypes && allowedFileTypes.isNotEmpty) {
      fileTypeHint = 'Allowed: ${allowedFileTypes.join(", ")}';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with required indicator
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: element.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (element.isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // File restrictions info
          Text(
            'Max size: $maxFileSizeLabel • $fileTypeHint',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          // Form field for validation
          FormField<List<File>>(
            initialValue: _fileValues[element.id],
            validator: element.isRequired
                ? (value) => (value == null || value.isEmpty)
                    ? 'Please upload at least one file'
                    : null
                : null,
            builder: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display uploaded files
                  if (_fileValues[element.id]!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...List.generate(_fileValues[element.id]!.length, (index) {
                      final file = _fileValues[element.id]![index];
                      final fileName = file.path.split('/').last;
                      final fileExt = fileName.split('.').last.toLowerCase();

                      // Choose appropriate icon based on file type
                      IconData fileIcon;
                      if (['jpg', 'jpeg', 'png', 'gif', 'webp']
                          .contains(fileExt)) {
                        fileIcon = Icons.image;
                      } else if (['pdf'].contains(fileExt)) {
                        fileIcon = Icons.picture_as_pdf;
                      } else if (['mp4', 'mov', 'avi', 'wmv']
                          .contains(fileExt)) {
                        fileIcon = Icons.video_file;
                      } else if (['mp3', 'wav', 'ogg'].contains(fileExt)) {
                        fileIcon = Icons.audio_file;
                      } else {
                        fileIcon = Icons.insert_drive_file;
                      }

                      // File item with delete button
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(fileIcon, color: const Color(0xFF1A4594)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fileName,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _fileValues[element.id]!.removeAt(index);
                                  state.didChange(_fileValues[element.id]);
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              iconSize: 20,
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                  // Upload buttons
                  if (_fileValues[element.id]!.length < maxFiles)
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.upload_file,
                                    color: Colors.white),
                                label: const Text('Choose File'),
                                onPressed: () async {
                                  await _pickFile(element, state,
                                      allowedFileTypes, allowSpecificTypes);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3355AA),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.camera_alt,
                                    color: Colors.white),
                                label: const Text('Take Photo'),
                                onPressed: () async {
                                  await _takePhoto(element, state);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3355AA),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_fileValues[element.id]!.length > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${_fileValues[element.id]!.length} of $maxFiles files added',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                      ],
                    ),
                  // Error message
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        state.errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: _currentStep > 1
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.end,
        children: [
          // Back button
          if (_currentStep > 1)
            SizedBox(
              width: 120,
              height: 48,
              child: OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1A4594)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFF1A4594),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

          // Next/Submit button
          SizedBox(
            width: 120,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      if (_validateCurrentStep()) {
                        if (_currentStep < widget.form.steps.length) {
                          setState(() {
                            _currentStep++;
                          });
                        } else {
                          _submitForm();
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A4594),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _currentStep == widget.form.steps.length
                          ? 'Submit'
                          : 'Next',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
