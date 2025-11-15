import 'package:flutter/material.dart';
import 'dart:math';

class HealthTrackerScreen extends StatefulWidget {
  const HealthTrackerScreen({super.key});

  @override
  State<HealthTrackerScreen> createState() => _HealthTrackerScreenState();
}

class _HealthTrackerScreenState extends State<HealthTrackerScreen> {
  final _formKey = GlobalKey<FormState>();

  double? height; // in cm
  double? weight; // in kg
  double? sleep;
  double? water;
  String? activityLevel;
  String? hasCondition;
  String? conditionName;
  double? bmi;

  String aiSuggestion = "Please enter your health data to get insights.";
  bool isThinking = false;

  void calculateBMI() {
    if (height != null && weight != null && height! > 0) {
      double heightInMeters = height! / 100;
      double calculatedBMI = weight! / pow(heightInMeters, 2);

      setState(() {
        bmi = double.parse(calculatedBMI.toStringAsFixed(1));
      });

      generateAISuggestion();
    }
  }

  Future<void> generateAISuggestion() async {
    if (bmi == null) return;
    setState(() => isThinking = true);

    await Future.delayed(const Duration(seconds: 2)); // simulate thinking

    String suggestion = "";

    if (bmi! < 18.5) {
      suggestion =
          "Your BMI indicates you're underweight. Consider a balanced diet.";
    } else if (bmi! >= 18.5 && bmi! < 25) {
      suggestion = "Great! Your BMI is within the healthy range.";
    } else if (bmi! >= 25 && bmi! < 30) {
      suggestion = "You are slightly overweight. Try regular exercise.";
    } else {
      suggestion = "Your BMI indicates obesity. Consult a healthcare provider.";
    }

    if (sleep != null && sleep! < 6) {
      suggestion += "\n💤 Try getting more sleep for better recovery.";
    }

    if (water != null && water! < 1.5) {
      suggestion += "\n💧 Drink more water to stay hydrated.";
    }

    if (activityLevel == "Low") {
      suggestion += "\n🏃‍♂️ Increase physical activity for better health.";
    }

    if (hasCondition == "Yes" &&
        conditionName != null &&
        conditionName!.isNotEmpty) {
      suggestion += "\n⚕️ Monitor your condition: $conditionName.";
    }

    setState(() {
      aiSuggestion = suggestion;
      isThinking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '    Health Tracker ❣️📋',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 23,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.pink[100],
        automaticallyImplyLeading: true, // ✅ shows back arrow
      ),
      backgroundColor: Colors.lightBlue[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bmi != null)
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: bmi!.clamp(0, 40)),
                      duration: const Duration(seconds: 1),
                      builder: (context, value, _) {
                        final percentage = (value / 40).clamp(0.0, 1.0);
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: CircularProgressIndicator(
                                value: percentage,
                                strokeWidth: 10,
                                backgroundColor: Colors.grey[300],
                                color: value < 18.5
                                    ? Colors.orange
                                    : value < 25
                                        ? Colors.green
                                        : value < 30
                                            ? Colors.amber
                                            : Colors.red,
                              ),
                            ),
                            Text(
                              "BMI\n${value.toStringAsFixed(1)}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 25),
                buildTextField("Height (cm)", (v) {
                  height = double.tryParse(v);
                  calculateBMI();
                }),
                buildTextField("Weight (kg)", (v) {
                  weight = double.tryParse(v);
                  calculateBMI();
                }),
                buildTextField(
                    "Sleep (hours)", (v) => sleep = double.tryParse(v)),
                buildTextField(
                    "Water Intake (litres)", (v) => water = double.tryParse(v)),
                const SizedBox(height: 10),
                buildDropdown("Activity Level", ["Low", "Moderate", "High"],
                    (v) => setState(() => activityLevel = v)),
                buildDropdown("Any Underlying Medical Condition?",
                    ["No", "Yes"], (v) => setState(() => hasCondition = v)),
                if (hasCondition == "Yes")
                  buildTextField(
                      "Which condition(s)?", (v) => conditionName = v),
                const SizedBox(height: 20),
                Card(
                  color: Colors.yellow[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: isThinking
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "🤖 AI is analyzing your health data...",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            aiSuggestion,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: generateAISuggestion,
                    icon: const Icon(Icons.insights),
                    label: const Text("Get AI Insights"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable text field builder
  Widget buildTextField(String label, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: TextInputType.number,
        onChanged: onChanged,
      ),
    );
  }

  // Reusable dropdown builder
  Widget buildDropdown(
      String label, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        value: items.contains(activityLevel) ? activityLevel : null,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
