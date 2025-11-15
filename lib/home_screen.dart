import 'package:flutter/material.dart';
import 'main.dart'; // Access DashboardScreen

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeIn,
        child: Stack(
          children: [
            // 🔹 Background Image
            SizedBox.expand(
              child: Image.asset(
                'assets/images/home.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // 🔹 Semi-transparent overlay for readability
            Container(
              color: Colors.black.withOpacity(0.1),
            ),

            // 🔹 Foreground content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title
                      const Text(
                        'Nutri Health Tracker',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Headline
                      const Text(
                        'Stop Guessing. Start Tracking.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontStyle: FontStyle.italic,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'AI-Powered Wellness in Seconds.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19,
                          fontStyle: FontStyle.italic,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Light Blue Info Box
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue[50]!.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Column(
                          children: [
                            _FeatureLine(text: 'Get personalized AI insights'),
                            _FeatureLine(text: 'Log your meals instantly'),
                            _FeatureLine(text: 'Build healthier habits'),
                            _FeatureLine(text: 'Monitor hydration'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Icon Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          _IconTile(icon: Icons.restaurant, label: 'Meals'),
                          _IconTile(
                              icon: Icons.local_drink, label: 'Hydration'),
                          _IconTile(icon: Icons.insights, label: 'AI Insights'),
                          _IconTile(icon: Icons.favorite, label: 'Habits'),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Get Started Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DashboardScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[200],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 15,
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
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
    );
  }
}

// ✅ Each feature with centered alignment and green check
class _FeatureLine extends StatelessWidget {
  final String text;
  const _FeatureLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 22),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Icon row widget
class _IconTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _IconTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.amber.withOpacity(0.2),
          child: Icon(icon, color: Colors.purple, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
