import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart';

class MealLoggerScreen extends StatefulWidget {
  const MealLoggerScreen({super.key});

  @override
  State<MealLoggerScreen> createState() => _MealLoggerScreenState();
}

class _MealLoggerScreenState extends State<MealLoggerScreen> {
  final TextEditingController _mealController = TextEditingController();
  List<Map<String, dynamic>> _meals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('meals');
    if (data != null) {
      setState(() {
        _meals = List<Map<String, dynamic>>.from(json.decode(data));
      });
    }
  }

  Future<void> _saveMeals() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('meals', json.encode(_meals));
  }

  Future<void> _deleteMeal(int index) async {
    setState(() {
      _meals.removeAt(index);
    });
    await _saveMeals();
  }

  Future<void> _analyzeMeal(String meal, String mealType) async {
    setState(() => _isLoading = true);

    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {
                "text": "Estimate the total calories and provide a short AI health insight for this $mealType: $meal. "
                    "Format your response strictly as: Calories: X kcal | Insight: ..."
              }
            ]
          }
        ]
      }),
    );

    String calories = "Unknown kcal";
    String insight = "No insight provided.";

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final text =
          data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ?? "";
      final parts = text.split('|');
      calories = parts.isNotEmpty ? parts[0].trim() : "Unknown kcal";
      insight = parts.length > 1
          ? parts[1].replaceFirst('Insight:', '').trim()
          : "No insight provided.";
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Failed to analyze meal. Try again.")),
      );
    }

    final now = DateTime.now();
    final formattedDate =
        "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
    final formattedTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    setState(() {
      _meals.add({
        "meal": meal,
        "mealType": mealType,
        "calories": calories,
        "insight": insight,
        "date": formattedDate,
        "time": formattedTime,
      });
      _isLoading = false;
    });

    _saveMeals();
  }

  void _logMeal() {
    final meal = _mealController.text.trim();
    if (meal.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              const Text("Select meal type:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  for (final type in [
                    "Breakfast",
                    "Lunch",
                    "Dinner",
                    "Dessert",
                    "Snack"
                  ])
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _analyzeMeal(meal, type);
                        _mealController.clear();
                      },
                      child: Text(type),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Meal Logger 🍲",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.pink[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.teal[100],
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _mealController,
                        decoration: const InputDecoration(
                          hintText: "Describe your meal 😊...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.purple, size: 30),
                            onPressed: _logMeal,
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _meals.isEmpty
                  ? Center(
                      child: Text(
                        "No meals logged yet 🍛",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _meals.length,
                      itemBuilder: (context, index) {
                        final meal = _meals[index];
                        return Card(
                          color: Colors.pink[50],
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            title: Text(
                              "${meal['mealType']}: ${meal['meal']}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("🔥 ${meal['calories']}"),
                                Text("💡 ${meal['insight']}"),
                                Text(
                                  "🕒 ${meal['date']}  ${meal['time']}",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMeal(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
