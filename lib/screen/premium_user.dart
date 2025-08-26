import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';

class AlreadyPremiumPage extends StatefulWidget {
  const AlreadyPremiumPage({super.key});

  @override
  State<AlreadyPremiumPage> createState() => _AlreadyPremiumPageState();
}

class _AlreadyPremiumPageState extends State<AlreadyPremiumPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _crownController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _crownController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _crownController,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
    _crownController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _crownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E1E1E),
              const Color(0xFFb8ea6c).withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                // Animated Crown Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedBuilder(
                    animation: _rotateAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFb8ea6c),
                                const Color(0xFFb8ea6c).withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFb8ea6c)
                                    .withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.workspace_premium_rounded,
                            color: Colors.black,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Gap(25),

                // Premium Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFb8ea6c),
                        const Color(0xFFb8ea6c).withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: Colors.black,
                        size: 16,
                      ),
                      const Gap(5),
                      Text(
                        'PREMIUM USER',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(20),

                // Main Text
                Text(
                  'You\'re Already Premium!',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Gap(15),

                Text(
                  'You already have access to all premium features. Enjoy unlimited habits, detailed analytics, and exclusive themes!',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey.shade300,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Gap(25),

                // Premium Features List
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFb8ea6c).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFb8ea6c).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Premium Benefits',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFb8ea6c),
                        ),
                      ),
                      const Gap(15),
                      _buildFeatureItem(
                          'Unlimited Habits', Icons.add_circle_outline),
                      _buildFeatureItem('Detailed Calendar View',
                          Icons.calendar_today_rounded),
                      _buildFeatureItem(
                          'Advanced Analytics', Icons.analytics_outlined),
                      _buildFeatureItem(
                          'Custom Themes', Icons.palette_outlined),
                      _buildFeatureItem(
                          'Priority Support', Icons.support_agent_rounded),
                    ],
                  ),
                ),

                const Gap(30.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Navigate to premium features or settings
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFb8ea6c),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Explore',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFb8ea6c),
            size: 18,
          ),
          const Gap(12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFFb8ea6c),
            size: 16,
          ),
        ],
      ),
    );
  }
}
