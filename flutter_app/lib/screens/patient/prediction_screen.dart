import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/health_assessment_model.dart';
import '../../providers/prediction_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
import 'result_screen.dart';
import '../../themes/app_theme.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final ageController = TextEditingController();
  final cholesterolController = TextEditingController();
  final bpController = TextEditingController();
  final heartRateController = TextEditingController();
  final bloodSugarController = TextEditingController();
  final exerciseController = TextEditingController();
  final stressController = TextEditingController();

  String gender = 'Male';
  String smoking = 'Never';
  String alcohol = 'Unknown';
  String familyHistory = 'No';
  String diabetes = 'No';
  String obesity = 'No';
  String angina = 'No';
  String chestPain = 'Typical Angina';

  @override
  void dispose() {
    ageController.dispose();
    cholesterolController.dispose();
    bpController.dispose();
    heartRateController.dispose();
    bloodSugarController.dispose();
    exerciseController.dispose();
    stressController.dispose();
    super.dispose();
  }

  int parseInt(TextEditingController controller) {
    return int.tryParse(controller.text.trim()) ?? -1;
  }

  String? _validateNumber(String? rawValue, int minimum, int maximum) {
    final value = rawValue?.trim() ?? '';
    if (value.isEmpty) return 'This field is required.';
    final number = int.tryParse(value);
    if (number == null) return 'Enter a whole number.';
    if (number < minimum || number > maximum) {
      return 'Enter a value from $minimum to $maximum.';
    }
    return null;
  }

  Widget _numberField(
    String label,
    TextEditingController controller, {
    required int minimum,
    required int maximum,
    String? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        validator: (value) => _validateNumber(value, minimum, maximum),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          helperText: 'Valid range: $minimum–$maximum',
        ),
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 21),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> submitPrediction() async {
    FocusScope.of(context).unfocus();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to run a prediction.'),
        ),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review the highlighted assessment fields.'),
        ),
      );
      return;
    }

    final assessment = HealthAssessmentModel(
      age: parseInt(ageController),
      gender: gender,
      cholesterol: parseInt(cholesterolController),
      bloodPressure: parseInt(bpController),
      heartRate: parseInt(heartRateController),
      smoking: smoking,
      alcoholIntake: alcohol,
      exerciseHours: parseInt(exerciseController),
      familyHistory: familyHistory,
      diabetes: diabetes,
      obesity: obesity,
      stressLevel: parseInt(stressController),
      bloodSugar: parseInt(bloodSugarController),
      exerciseInducedAngina: angina,
      chestPainType: chestPain,
    );

    final predictionProvider = Provider.of<PredictionProvider>(
      context,
      listen: false,
    );

    final success = await predictionProvider.runPrediction(
      userId: user.uid,
      assessment: assessment,
    );

    if (!mounted) return;

    if (success && predictionProvider.latestPrediction != null) {
      final prediction = predictionProvider.latestPrediction!;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            riskLevel: prediction.riskLevel,
            probability: prediction.probability,
            recommendation: prediction.recommendation,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            predictionProvider.errorMessage ??
                'Prediction failed. Make sure the backend is running.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final predictionProvider = Provider.of<PredictionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('CARDIOGUARD')),
      body: predictionProvider.isLoading
          ? const Center(
              child: LoadingIndicator(message: 'Running prediction...'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cardiovascular Assessment',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your health details for heart disease risk prediction.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 25),

                    _section(
                      icon: Icons.person_outline,
                      title: 'Demographics',
                      children: [
                        _numberField(
                          'Age',
                          ageController,
                          minimum: 18,
                          maximum: 120,
                          suffix: 'years',
                        ),
                        _dropdown(
                          label: 'Gender',
                          value: gender,
                          items: genderOptions,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => gender = value);
                          },
                        ),
                      ],
                    ),
                    _section(
                      icon: Icons.monitor_heart_outlined,
                      title: 'Vitals & Biomarkers',
                      children: [
                        _numberField(
                          'Cholesterol',
                          cholesterolController,
                          minimum: 50,
                          maximum: 500,
                          suffix: 'mg/dL',
                        ),
                        _numberField(
                          'Blood Pressure',
                          bpController,
                          minimum: 60,
                          maximum: 250,
                          suffix: 'mmHg',
                        ),
                        _numberField(
                          'Heart Rate',
                          heartRateController,
                          minimum: 30,
                          maximum: 220,
                          suffix: 'bpm',
                        ),
                        _numberField(
                          'Blood Sugar',
                          bloodSugarController,
                          minimum: 50,
                          maximum: 500,
                          suffix: 'mg/dL',
                        ),
                      ],
                    ),
                    _section(
                      icon: Icons.directions_run_outlined,
                      title: 'Lifestyle Factors',
                      children: [
                        _numberField(
                          'Exercise Hours',
                          exerciseController,
                          minimum: 0,
                          maximum: 24,
                          suffix: 'hours',
                        ),
                        _numberField(
                          'Stress Level',
                          stressController,
                          minimum: 1,
                          maximum: 10,
                        ),
                        _dropdown(
                          label: 'Smoking',
                          value: smoking,
                          items: smokingOptions,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => smoking = value);
                          },
                        ),
                        _dropdown(
                          label: 'Alcohol Intake',
                          value: alcohol,
                          items: alcoholIntakeOptions,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => alcohol = value);
                          },
                        ),
                      ],
                    ),
                    _section(
                      icon: Icons.medical_information_outlined,
                      title: 'Medical History',
                      children: [
                        _dropdown(
                          label: 'Family History',
                          value: familyHistory,
                          items: yesNoOptions,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => familyHistory = value);
                          },
                        ),
                        _dropdown(
                          label: 'Diabetes',
                          value: diabetes,
                          items: yesNoOptions,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => diabetes = value);
                          },
                        ),
                        _dropdown(
                          label: 'Obesity',
                          value: obesity,
                          items: yesNoOptions,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => obesity = value);
                          },
                        ),
                      ],
                    ),
                    _section(
                      icon: Icons.assignment_outlined,
                      title: 'Clinical Findings',
                      children: [
                        _dropdown(
                          label: 'Exercise Induced Angina',
                          value: angina,
                          items: yesNoOptions,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => angina = value);
                          },
                        ),
                        _dropdown(
                          label: 'Chest Pain Type',
                          value: chestPain,
                          items: chestPainTypeOptions,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => chestPain = value);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    CustomButton(
                      text: 'Run Prediction',
                      icon: Icons.monitor_heart,
                      onPressed: submitPrediction,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
