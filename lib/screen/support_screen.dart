import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streaks/res/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _headerController;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  int selectedContactIndex = -1;
  int expandedFAQIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    _headerController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headerController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          _buildAnimatedAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildContactOptions(),
                    const Gap(30),
                    _buildFAQSection(),
                    const Gap(30),
                    _buildAppInfo(),
                    const Gap(20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        background: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFb8ea6c).withValues(alpha: 0.8),
                  const Color(0xFFb8ea6c).withValues(alpha: 0.6),
                  Colors.black,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Gap(40),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const Gap(15),
                  Text(
                    'Support Center',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'We\'re here to help you succeed',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildContactOptions() {
    final contactOptions = [
      {
        'icon': Icons.email_rounded,
        'title': 'Email Support',
        'subtitle': 'Get help within 24 hours',
        'action': 'umairali2k181@gmail.com',
      },
      {
        'icon': Icons.phone_rounded,
        'title': 'Phone Support',
        'subtitle': 'Call us Mon-Fri 9AM-5PM',
        'action': '+923409568028',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How can we help?',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Gap(20),
        ...contactOptions.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> option = entry.value;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 15),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleContactOption(option['action'], index),
                borderRadius: BorderRadius.circular(15),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: selectedContactIndex == index
                        ? const Color(0xFFb8ea6c).withValues(alpha: 0.1)
                        : const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: selectedContactIndex == index
                          ? const Color(0xFFb8ea6c)
                          : Colors.grey.withValues(alpha: 0.2),
                      width: selectedContactIndex == index ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFb8ea6c).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          option['icon'],
                          color: const Color(0xFFb8ea6c),
                          size: 24,
                        ),
                      ),
                      const Gap(15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['title'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const Gap(5),
                            Text(
                              option['subtitle'],
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: selectedContactIndex == index
                            ? const Color(0xFFb8ea6c)
                            : Colors.grey.shade600,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      {
        'question': 'How many habits can I add as non premium user?',
        'answer': 'You can add as up to 4 habits as non premium user',
      },
      {
        'question': 'Where can I see the dots or calendar marks?',
        'answer':
            'You can click on any streak and it will take you to the details of the streaks where you can see your progress calendar. However, this feature is available only for premium users.',
      },
      {
        'question': 'What premium features do I get?',
        'answer':
            'Premium users get access to detailed streak calendars, advanced analytics, habit insights, custom themes, and priority support. Upgrade to unlock the full potential of your habit tracking!',
      },
      {
        'question': 'How do I upgrade to Premium?',
        'answer':
            'Tap on the Premium button in the main menu or go to Settings > Premium. Choose your preferred subscription plan and complete the payment.',
      },
      {
        'question': 'What happens if I miss a day?',
        'answer':
            'Missing a day will break your current streak, but don\'t worry! You can start building a new streak immediately. Consistency is more important than perfection.',
      },
      {
        'question': 'How do I reset my habit streak?',
        'answer':
            'You can reset your habit streak by going to the habit details page and tapping the "Reset Streak" button. This action cannot be undone.',
      },
      {
        'question': 'How do I delete a habit?',
        'answer':
            'Press and hold on any habit in your list, then select "Delete" from the menu. You can also delete habits from the habit details page.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Gap(20),
        ...faqs.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, String> faq = entry.value;
          bool isExpanded = expandedFAQIndex == index;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isExpanded
                    ? const Color(0xFFb8ea6c).withValues(alpha: 0.5)
                    : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    expandedFAQIndex = isExpanded ? -1 : index;
                  });
                },
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              faq['question']!,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: isExpanded
                                  ? const Color(0xFFb8ea6c)
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: const SizedBox.shrink(),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(
                            faq['answer']!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade300,
                              height: 1.5,
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
        }),
      ],
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFb8ea6c).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFb8ea6c),
              size: 30,
            ),
          ),
          const Gap(15),
          Text(
            'App Information',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Gap(15),
          _buildInfoRow('Version', '1.0.6'),
          _buildInfoRow('Build', '11'),
          _buildInfoRow('Platform', 'Flutter'),
          const Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                'Rate App',
                Icons.star_rounded,
                () => _rateApp(),
              ),
              Gap(10.0),
              _buildActionButton(
                'Share App',
                Icons.share_rounded,
                () => _shareApp(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String text, IconData icon, VoidCallback onPressed) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFb8ea6c).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFb8ea6c).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: const Color(0xFFb8ea6c),
                  size: 18,
                ),
                const Gap(8),
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFb8ea6c),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleContactOption(String action, int index) {
    setState(() {
      selectedContactIndex = selectedContactIndex == index ? -1 : index;
    });

    HapticFeedback.lightImpact();

    switch (action) {
      case 'umairali2k181@gmail.com':
        _launchEmail();
        break;
      case '+923409568028':
        _makePhoneCall();
        break;
    }
  }

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'umairali2k181@gmail.com',
      query: 'subject=Support Request&body=Hello, I need help with...',
    );

    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      _showSnackBar('Could not open email app');
    }
  }

  void _makePhoneCall() async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: '+923409568028');

    try {
      await launchUrl(phoneLaunchUri);
    } catch (e) {
      _showSnackBar('Could not make phone call');
    }
  }

  void _rateApp() async {
    AppUtils.showRatingDialog(context);
  }

  void _shareApp() async {
    AppUtils.showShareDialog(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFb8ea6c),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
