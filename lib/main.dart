import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'profile_screen.dart';
import 'meal_logger_screen.dart';
import 'health_tracker_screen.dart';
import 'ai_assistant_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nutri Health Tracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[200],
        textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 16)),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// 🏠 Home Screen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ' Nutri Health Tracker 🩺📈',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade300,
      ),

      // ✅ SafeArea prevents overflow under status bar or system UI
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),

          // ✅ Scrollable content so it fits on smaller screens
          child: SingleChildScrollView(
            child: Column(
              children: [
                GridView.count(
                  // Disable the grid’s internal scrolling
                  physics: const NeverScrollableScrollPhysics(),
                  // Let it size itself based on its content
                  shrinkWrap: true,

                  crossAxisCount: 2,
                  mainAxisSpacing: 25,
                  crossAxisSpacing: 25,
                  childAspectRatio: 0.8,

                  children: [
                    _buildFeatureCard(
                      context: context,
                      icon: Icons.person,
                      title: 'My Profile',
                      imagePath: 'assets/images/profile.png',
                      screen: const ProfileScreen(),
                    ),
                    _buildFeatureCard(
                      context: context,
                      icon: Icons.fastfood,
                      title: 'Meal Logger',
                      imagePath: 'assets/images/meal.jpg',
                      screen: const MealLoggerScreen(),
                    ),
                    _buildFeatureCard(
                      context: context,
                      icon: Icons.health_and_safety,
                      title: 'Health Tracker',
                      imagePath: 'assets/images/health.jpg',
                      screen: const HealthTrackerScreen(),
                    ),
                    _buildFeatureCard(
                      context: context,
                      icon: Icons.chat,
                      title: 'AI Assistant',
                      imagePath: 'assets/images/ai.jpg',
                      screen: const AIAssistantScreen(),
                    ),
                  ],
                ),
                const SizedBox(height: 20), // 🧩 extra breathing room at bottom
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔗 Card builder with navigation
  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String imagePath,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 15),
            Icon(icon, size: 35, color: Colors.green),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
