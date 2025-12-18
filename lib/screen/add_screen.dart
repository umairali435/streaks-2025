import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:streaks/bloc/streaks_bloc.dart';
import 'package:streaks/components/custom_drop_down_field.dart';
import 'package:streaks/components/custom_text_field.dart';
import 'package:streaks/components/streaks_colors.dart';
import 'package:streaks/database/streaks_database.dart';
import 'package:streaks/purchases_bloc/purchases_bloc.dart';
import 'package:streaks/purchases_bloc/purchases_event.dart';
import 'package:streaks/purchases_bloc/purchases_state.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/res/constants.dart';
import 'package:streaks/res/strings.dart';
import 'package:streaks/screen/purchases_screen.dart';
import 'package:streaks/services/notification_service.dart';

class AddStrekScreen extends StatefulWidget {
  final Streak? streak;

  const AddStrekScreen({super.key, this.streak});

  @override
  State<AddStrekScreen> createState() => _AddStrekScreenState();
}

class _AddStrekScreenState extends State<AddStrekScreen> {
  final nameController = TextEditingController();
  final timeController = TextEditingController();
  final activeDaysController = TextEditingController();
  String selectedWeekDay = "Sunday";
  int selectedWeekIndex = 0;
  String selectedDaysPerWeek = "7";
  List<int> activeDays = [];
  int selectedColorCode = AppConstants.colors.first.toARGB32();
  int currentIndex = 0;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    context.read<PurchasesBloc>().add(TotalAddedStreaks(0));
    super.initState();
    if (widget.streak == null) {
      WidgetsBinding.instance.addPostFrameCallback((value) {
        _setSelectedTime();
      });
    }
  }

  void _setSelectedTime() {
    selectedTime = TimeOfDay.now();
    timeController.text = selectedTime?.format(context) ?? "";
  }

  @override
  void didChangeDependencies() {
    debugPrint(widget.streak?.daysOfWeek.first.toString() ?? "");
    setState(() {
      if (widget.streak != null) {
        nameController.text = widget.streak?.name ?? "";
        selectedTime = TimeOfDay(
          hour: widget.streak?.notificationHour ?? 0,
          minute: widget.streak?.notificationMinute ?? 0,
        );
        timeController.text = selectedTime?.format(context) ?? "";
        selectedWeekDay =
            AppText.getDayOfWeek(widget.streak?.selectedWeek ?? 0);
        selectedDaysPerWeek = widget.streak?.daysOfWeek.first.toString() ?? "";
        activeDaysController.text = selectedDaysPerWeek;
        activeDays.addAll(widget.streak?.selectedDays ?? []);
        selectedWeekIndex = widget.streak?.selectedWeek ?? 0;
        selectedColorCode = widget.streak!.colorCode;
        context.read<IconBloc>().add(
              UpdateSelectedIcon(
                IconData(
                  widget.streak!.iconCode,
                  fontFamily: "Lucide",
                  fontPackage: 'lucide_icons',
                ),
              ),
            );
      } else {
        activeDaysController.text = selectedDaysPerWeek;
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState is ThemeLoaded ? themeState.isDark : true;
        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                LucideIcons.chevronLeft,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              widget.streak == null ? "Add New Streak" : "Edit Streak",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18.0,
              ),
            ),
            actions: [
              BlocBuilder<PurchasesBloc, PurchasesState>(
                builder: (context, state) {
                  return IconButton(
                    onPressed: () {
                      if (state.totalStreaksLength >= 3 &&
                          !state.isSubscriptionActive) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PurchasesScreen()),
                        );
                      } else {
                        _saveStreak();
                      }
                    },
                    icon: Icon(
                      LucideIcons.checkCircle,
                    ),
                  );
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 14.0,
              right: 14.0,
              bottom: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(20.0),
                CustomTextField(
                  controller: nameController,
                  title: "Streak name",
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardColorTheme(isDark),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14.0),
                            child: BlocBuilder<IconBloc, IconState>(
                              builder: (context, state) {
                                return GestureDetector(
                                  onTap: () => _showIconPicker(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardColorTheme(isDark),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Icon(state.selectedIcon,
                                        color: AppColors.textColor(isDark)),
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () => _showIconPicker(context),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 12.0,
                                      right: 12.0,
                                      bottom: 12.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Icon",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textColor(isDark),
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        Icon(
                                          LucideIcons.chevronRight,
                                          color:
                                              AppColors.greyColorTheme(isDark),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _showColorPicker(context),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 12.0,
                                      right: 12.0,
                                      bottom: 12.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Color",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textColor(isDark),
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        const Gap(10.0),
                                        Row(
                                          children: [
                                            Container(
                                              height: 30.0,
                                              width: 30.0,
                                              decoration: BoxDecoration(
                                                color: Color(selectedColorCode),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const Gap(10.0),
                                            Icon(
                                              LucideIcons.chevronRight,
                                              color: AppColors.greyColorTheme(
                                                  isDark),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(20.0),
                CustomTextField(
                  controller: timeController,
                  isReadOnly: true,
                  title: "Notification Time",
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      selectedTime = pickedTime;
                      timeController.text = selectedTime?.format(context) ?? "";
                    });
                  },
                ),
                CustomDropDownField(
                  title: "Week start from",
                  items: const [
                    "Sunday",
                    "Monday",
                    "Tuesday",
                    "Wednesday",
                    "Thursday",
                    "Friday",
                    "Saturday"
                  ],
                  onChanged: (value) {
                    activeDays.clear();
                    setState(() {
                      selectedWeekDay = value;
                      selectedDaysPerWeek = "7";
                      activeDaysController.text = "7";
                      selectedWeekIndex = AppConstants.selectedWeekIndex(value);
                    });
                  },
                  value: selectedWeekDay,
                ),
                CustomDropDownField(
                  value: selectedDaysPerWeek,
                  controller: activeDaysController,
                  title:
                      "How many days per week should you complete this habit?",
                  items: const ["1", "2", "3", "4", "5", "6", "7"],
                  onChanged: (value) {
                    activeDays.clear();
                    for (int i = 0; i < int.parse(value); i++) {
                      int currentIndex = (selectedWeekIndex + i) % 7;
                      activeDays.add(currentIndex);
                    }
                    setState(() {
                      selectedDaysPerWeek = value;
                      activeDaysController.text = value;
                    });
                  },
                ),
                if (selectedDaysPerWeek != "7")
                  BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, themeState) {
                      final daysIsDark =
                          themeState is ThemeLoaded ? themeState.isDark : true;
                      return SelectStreakActiveDays(
                        activeDays: activeDays,
                        selectedWeekDayIndex: selectedWeekIndex,
                        isDark: daysIsDark,
                        onDaysSelected: (days) {
                          int selectedDayLength =
                              int.parse(selectedDaysPerWeek);
                          setState(() {
                            if (!activeDays.contains(
                                    AppConstants.selectedDayIndex(days)) &&
                                (activeDays.length == selectedDayLength)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.primaryColor,
                                  content: Text(
                                    "You can only select $selectedDayLength days",
                                    style: GoogleFonts.poppins(
                                      color: AppColors.whiteColor,
                                    ),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              setState(() {
                                if (activeDays.contains(
                                    AppConstants.selectedDayIndex(days))) {
                                  activeDays.remove(
                                      AppConstants.selectedDayIndex(days));
                                } else {
                                  activeDays
                                      .add(AppConstants.selectedDayIndex(days));
                                }
                              });
                            }
                          });
                        },
                      );
                    },
                  ),
                const Gap(30.0),
                BlocBuilder<PurchasesBloc, PurchasesState>(
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: () {
                        if (state.totalStreaksLength >= 3 &&
                            !state.isSubscriptionActive) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PurchasesScreen()),
                          );
                        } else {
                          _saveStreak();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 45.0,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child: Text(
                            "Save",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w900,
                              color: AppColors.blackColor,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Gap(20.0),
              ],
            ),
          ),
        );
      },
    );
  }

  void _errorDialog(String message) {
    final isDark = context.read<ThemeBloc>().state is ThemeLoaded
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDark
        : true;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardColorTheme(isDark),
          title: Text(
            "Error",
            style: GoogleFonts.poppins(color: AppColors.textColor(isDark)),
          ),
          content: Text(
            message,
            style: GoogleFonts.poppins(color: AppColors.textColor(isDark)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "OK",
                style: GoogleFonts.poppins(color: AppColors.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveStreak() async {
    if (activeDays.isEmpty) {
      activeDays.clear();
      for (int i = 0; i < 7; i++) {
        activeDays.add(i);
      }
    }
    if (nameController.text.isEmpty) {
      _errorDialog("Please enter a name for the streak");
      return;
    }
    if (selectedTime == null) {
      _errorDialog("Please select a notification time");
      return;
    }
    if (activeDays.length != int.parse(selectedDaysPerWeek)) {
      _errorDialog("Please select $selectedDaysPerWeek active days");
      return;
    }

    if (selectedTime != null) {
      timeController.text = selectedTime?.format(context) ?? "";
      await NotificationService.scheduleDailyNotification(selectedTime,
          streakName: nameController.text);
    }

    Streak newStreak = Streak(
      name: nameController.text,
      notificationHour: selectedTime?.hour ?? 0,
      notificationMinute: selectedTime?.minute ?? 0,
      daysOfWeek: [selectedDaysPerWeek],
      colorCode: selectedColorCode,
      streakDates: widget.streak?.streakDates ?? [],
      selectedWeek: selectedWeekIndex,
      iconCode: context.read<IconBloc>().state.selectedIcon.codePoint,
      selectedDays: activeDays,
    );

    final navigator = Navigator.of(context);

    if (widget.streak == null) {
      context.read<StreaksBloc>().add(AddStreak(newStreak));
    } else {
      newStreak.id = widget.streak!.id;
      context.read<StreaksBloc>().add(UpdateStreak(newStreak));
    }
    navigator.pop();
    if (widget.streak != null) {
      navigator.pop();
    }
  }

  void _showIconPicker(BuildContext ctx) {
    final isDark = context.read<ThemeBloc>().state is ThemeLoaded
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDark
        : true;
    final List<String> categories = [
      "All",
      "Habit",
      "Social",
      "Productivity",
      "Health & Wellness",
      "Lifestyle & Hobbies",
    ];
    showModalBottomSheet(
      backgroundColor: AppColors.secondaryColorTheme(isDark),
      showDragHandle: true,
      context: context,
      builder: (context) {
        return BottomSheet(
          backgroundColor: AppColors.secondaryColorTheme(isDark),
          onClosing: () {},
          builder: (context) {
            return DefaultTabController(
              length: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Gap(10.0),
                  BlocBuilder<IconBloc, IconState>(
                    bloc: context.read<IconBloc>(),
                    builder: (context, state) {
                      return SizedBox(
                        height: 40.0,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(right: 20.0),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 14.0),
                              child: InkWell(
                                onTap: () {
                                  context
                                      .read<IconBloc>()
                                      .add(UpdateTabIndex(index));
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      categories[index],
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        color: state.currentIndex == index
                                            ? AppColors.textColor(isDark)
                                            : AppColors.greyColorTheme(isDark),
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    const Gap(5.0),
                                    if (state.currentIndex == index)
                                      Container(
                                        height: 5.0,
                                        width: 24.0,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  BlocBuilder<IconBloc, IconState>(
                    builder: (context, state) {
                      return _buildIconGrid(
                        ctx,
                        state.currentIndex == 0
                            ? _allIcons
                            : state.currentIndex == 1
                                ? _habitIcons
                                : state.currentIndex == 2
                                    ? _socialIcons
                                    : state.currentIndex == 3
                                        ? _productivityIcons
                                        : state.currentIndex == 4
                                            ? _healthWellnessIcons
                                            : _lifestyleHobbiesIcons,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showColorPicker(BuildContext ctx) {
    final isDark = context.read<ThemeBloc>().state is ThemeLoaded
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDark
        : true;
    showModalBottomSheet(
      backgroundColor: AppColors.secondaryColorTheme(isDark),
      showDragHandle: true,
      context: ctx,
      builder: (context) {
        return BottomSheet(
          backgroundColor: AppColors.secondaryColorTheme(isDark),
          onClosing: () {},
          builder: (context) {
            return StreaksColors(
              initialColor: selectedColorCode,
              onColorSelected: (colorCode) {
                setState(() {
                  selectedColorCode = colorCode;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildIconGrid(BuildContext context, List<IconData> icons) {
    final isDark = context.read<ThemeBloc>().state is ThemeLoaded
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDark
        : true;
    return SizedBox(
      height: 300.0,
      child: GridView.builder(
        padding: const EdgeInsets.all(14.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final icon = icons[index];
          return GestureDetector(
            onTap: () {
              context.read<IconBloc>().add(UpdateSelectedIcon(icon));
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardColorTheme(isDark),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(icon, color: AppColors.textColor(isDark)),
            ),
          );
        },
      ),
    );
  }

  final List<IconData> _allIcons = [
    ..._habitIcons,
    ..._socialIcons,
    ..._productivityIcons,
    ..._healthWellnessIcons,
    ..._lifestyleHobbiesIcons,
  ];

  static final List<IconData> _habitIcons = [
    // Exercise & Fitness
    LucideIcons.dumbbell,
    LucideIcons.bike,
    LucideIcons.footprints,
    LucideIcons.activity,
    LucideIcons.heart,
    LucideIcons.flame,
    LucideIcons.trophy,
    LucideIcons.target,
    LucideIcons.zap,

    // Learning & Reading
    LucideIcons.book,
    LucideIcons.bookOpen,
    LucideIcons.graduationCap,
    LucideIcons.brain,
    LucideIcons.lightbulb,
    LucideIcons.pencil,

    // Sleep & Rest
    LucideIcons.bed,
    LucideIcons.moon,
    LucideIcons.alarmClock,
    LucideIcons.sun,
    LucideIcons.sunrise,
    LucideIcons.sunset,

    // Health & Wellness
    LucideIcons.glassWater,
    LucideIcons.utensils,
    LucideIcons.apple,
    LucideIcons.salad,
    LucideIcons.pill,
    LucideIcons.stethoscope,
    LucideIcons.heartPulse,
    LucideIcons.syringe,

    // Mindfulness & Mental Health
    LucideIcons.smile,
    LucideIcons.brain,
    LucideIcons.sparkles,
    LucideIcons.wind,
    LucideIcons.cloudy,

    // Breaking Bad Habits
    LucideIcons.ban,
    LucideIcons.cigarette,
    LucideIcons.beer,
    LucideIcons.monitorSmartphone,
    LucideIcons.phoneOff,
    LucideIcons.wifiOff,

    // Productivity & Work
    LucideIcons.briefcase,
    LucideIcons.code,
    LucideIcons.edit,
    LucideIcons.checkCircle,
    LucideIcons.listChecks,
    LucideIcons.clipboard,

    // Time Management
    LucideIcons.clock,
    LucideIcons.calendar,
    LucideIcons.timer,
    LucideIcons.hourglass,
    LucideIcons.watch,

    // Creative Activities
    LucideIcons.brush,
    LucideIcons.palette,
    LucideIcons.music,
    LucideIcons.mic,
    LucideIcons.camera,
    LucideIcons.video,

    // Self-Care & Hygiene
    LucideIcons.bath,
    LucideIcons.droplet,
    LucideIcons.sparkle,
    LucideIcons.scissors,

    // Finance & Savings
    LucideIcons.dollarSign,
    LucideIcons.piggyBank,
    LucideIcons.wallet,
    LucideIcons.coins,
    LucideIcons.trendingUp,

    // Social & Relationships
    LucideIcons.users,
    LucideIcons.user,
    LucideIcons.phone,
    LucideIcons.messageCircle,
    LucideIcons.mail,

    // Home & Chores
    LucideIcons.home,
    LucideIcons.recycle,
    LucideIcons.leaf,

    // Hobbies & Recreation
    LucideIcons.gamepad,
    LucideIcons.puzzle,
    LucideIcons.coffee,
    LucideIcons.flower,
    LucideIcons.trees,

    // Spiritual & Meditation
    LucideIcons.church,
    LucideIcons.candlestickChart,

    // General
    LucideIcons.star,
    LucideIcons.flag,
    LucideIcons.gift,
    LucideIcons.eye,
    LucideIcons.car,
    LucideIcons.layoutGrid,
  ];

  static final List<IconData> _socialIcons = [
    // Social Media
    LucideIcons.facebook,
    LucideIcons.instagram,
    LucideIcons.linkedin,
    LucideIcons.youtube,
    LucideIcons.twitter,
    LucideIcons.github,
    LucideIcons.gitlab,
    LucideIcons.slack,
    LucideIcons.dribbble,
    LucideIcons.figma,
    LucideIcons.twitch,

    // Engagement
    LucideIcons.heart,
    LucideIcons.thumbsUp,
    LucideIcons.thumbsDown,
    LucideIcons.messageCircle,
    LucideIcons.messageSquare,
    LucideIcons.share2,
    LucideIcons.send,
    LucideIcons.forward,
    LucideIcons.reply,

    // Activity & Status
    LucideIcons.activity,
    LucideIcons.flame,
    LucideIcons.zap,
    LucideIcons.trendingUp,
    LucideIcons.badgeCheck,
    LucideIcons.award,
    LucideIcons.medal,
    LucideIcons.crown,
    LucideIcons.star,

    // Communication
    LucideIcons.user,
    LucideIcons.users,
    LucideIcons.userPlus,
    LucideIcons.userCheck,
    LucideIcons.atSign,
    LucideIcons.mail,
    LucideIcons.phone,
    LucideIcons.video,
    LucideIcons.voicemail,

    // Content
    LucideIcons.image,
    LucideIcons.camera,
    LucideIcons.film,
    LucideIcons.music,
    LucideIcons.headphones,
    LucideIcons.mic,
    LucideIcons.rss,
    LucideIcons.podcast,

    // Interaction
    LucideIcons.smilePlus,
    LucideIcons.smile,
    LucideIcons.laugh,
    LucideIcons.meh,
    LucideIcons.frown,
    LucideIcons.vote,
    LucideIcons.flag,
    LucideIcons.bookmark,
    LucideIcons.eye,

    // Organization
    LucideIcons.book,
    LucideIcons.bookOpen,
    LucideIcons.stickyNote,
    LucideIcons.fileText,
    LucideIcons.folderOpen,
    LucideIcons.archive,

    // Search & Discover
    LucideIcons.search,
    LucideIcons.scan,
    LucideIcons.compass,
    LucideIcons.globe,
    LucideIcons.map,
    LucideIcons.navigation,

    // Notifications
    LucideIcons.bell,
    LucideIcons.bellRing,
    LucideIcons.bellOff,
    LucideIcons.inbox,

    // Community
    LucideIcons.partyPopper,
    LucideIcons.gift,
    LucideIcons.sparkles,
    LucideIcons.trophy,
    LucideIcons.target,
  ];

  static final List<IconData> _productivityIcons = [
    // Work & Business
    LucideIcons.briefcase,
    LucideIcons.building,
    LucideIcons.building2,
    LucideIcons.store,

    // Time Management
    LucideIcons.calendar,
    LucideIcons.calendarCheck,
    LucideIcons.calendarClock,
    LucideIcons.calendarDays,
    LucideIcons.clock,
    LucideIcons.timer,
    LucideIcons.alarmClock,
    LucideIcons.hourglass,
    LucideIcons.watch,

    // Tasks & Planning
    LucideIcons.checkCircle,
    LucideIcons.checkSquare,
    LucideIcons.listChecks,
    LucideIcons.clipboardCheck,
    LucideIcons.clipboardList,
    LucideIcons.clipboard,

    // Documents & Files
    LucideIcons.file,
    LucideIcons.fileText,
    LucideIcons.fileEdit,
    LucideIcons.fileSpreadsheet,
    LucideIcons.filePlus,
    LucideIcons.folder,
    LucideIcons.folderOpen,
    LucideIcons.folderPlus,
    LucideIcons.archive,

    // Writing & Editing
    LucideIcons.edit,
    LucideIcons.pencil,
    LucideIcons.penTool,
    LucideIcons.highlighter,
    LucideIcons.type,

    // Communication
    LucideIcons.mail,
    LucideIcons.inbox,
    LucideIcons.send,
    LucideIcons.phone,
    LucideIcons.phoneCall,
    LucideIcons.messageSquare,
    LucideIcons.messageCircle,
    LucideIcons.video,

    // Technology & Code
    LucideIcons.code,
    LucideIcons.monitor,
    LucideIcons.laptop,
    LucideIcons.terminal,
    LucideIcons.database,
    LucideIcons.server,
    LucideIcons.cpu,
    LucideIcons.hardDrive,

    // Organization & Storage
    LucideIcons.save,
    LucideIcons.download,
    LucideIcons.upload,
    LucideIcons.cloud,
    LucideIcons.box,

    // Security & Privacy
    LucideIcons.lock,
    LucideIcons.unlock,
    LucideIcons.key,
    LucideIcons.shield,
    LucideIcons.shieldCheck,
    LucideIcons.fingerprint,
    LucideIcons.eye,
    LucideIcons.eyeOff,

    // Search & Navigation
    LucideIcons.search,
    LucideIcons.filter,
    LucideIcons.map,
    LucideIcons.mapPin,
    LucideIcons.navigation,
    LucideIcons.compass,

    // Settings & Tools
    LucideIcons.settings,
    LucideIcons.sliders,
    LucideIcons.wrench,
    LucideIcons.cog,

    // Analytics & Charts
    LucideIcons.pieChart,
    LucideIcons.barChart,
    LucideIcons.lineChart,
    LucideIcons.trendingUp,
    LucideIcons.trendingDown,
    LucideIcons.activity,

    // Ideas & Innovation
    LucideIcons.lightbulb,
    LucideIcons.brain,
    LucideIcons.target,
    LucideIcons.focus,
    LucideIcons.zap,
    LucideIcons.sparkles,

    // Tags & Labels
    LucideIcons.tag,
    LucideIcons.tags,
    LucideIcons.bookmark,
    LucideIcons.pin,
    LucideIcons.flag,

    // Printing & Output
    LucideIcons.printer,
    LucideIcons.scan,
    LucideIcons.copy,

    // Links & Connections
    LucideIcons.link,
    LucideIcons.link2,
    LucideIcons.unlink,
    LucideIcons.share,
    LucideIcons.share2,

    // Finance & Money
    LucideIcons.dollarSign,
    LucideIcons.creditCard,
    LucideIcons.wallet,
    LucideIcons.receipt,
    LucideIcons.calculator,

    // Miscellaneous
    LucideIcons.award,
    LucideIcons.trophy,
    LucideIcons.medal,
    LucideIcons.star,
    LucideIcons.grid,
    LucideIcons.layout,
    LucideIcons.layers,
    LucideIcons.package,
  ];
  static final List<IconData> _healthWellnessIcons = [
    // Physical Health
    LucideIcons.heart,
    LucideIcons.heartPulse,
    LucideIcons.heartHandshake,
    LucideIcons.activity,

    // Medical & Healthcare
    LucideIcons.stethoscope,
    LucideIcons.pill,
    LucideIcons.syringe,
    LucideIcons.thermometer,
    LucideIcons.cross,

    // Nutrition & Diet
    LucideIcons.apple,
    LucideIcons.salad,
    LucideIcons.utensils,
    LucideIcons.utensilsCrossed,
    LucideIcons.soup,
    LucideIcons.beef,
    LucideIcons.candy,
    LucideIcons.croissant,
    LucideIcons.cookie,
    LucideIcons.egg,
    LucideIcons.fish,

    // Hydration
    LucideIcons.glassWater,
    LucideIcons.droplet,
    LucideIcons.droplets,
    LucideIcons.cupSoda,
    LucideIcons.milk,

    // Exercise & Fitness
    LucideIcons.dumbbell,
    LucideIcons.bike,
    LucideIcons.footprints,
    LucideIcons.flame,
    LucideIcons.zap,
    LucideIcons.trophy,
    LucideIcons.target,

    // Sleep & Rest
    LucideIcons.bed,
    LucideIcons.bedDouble,
    LucideIcons.moon,
    LucideIcons.moonStar,

    // Mental Health & Mindfulness
    LucideIcons.brain,
    LucideIcons.smile,
    LucideIcons.smilePlus,
    LucideIcons.laugh,
    LucideIcons.meh,
    LucideIcons.frown,
    LucideIcons.sparkles,
    LucideIcons.wind,
    LucideIcons.cloudRain,
    LucideIcons.sun,
    LucideIcons.sunrise,
    LucideIcons.sunset,

    // Meditation & Relaxation
    LucideIcons.flame,
    LucideIcons.flower,
    LucideIcons.flower2,
    LucideIcons.music,
    LucideIcons.headphones,
    LucideIcons.volume2,

    // Measurements & Tracking
    LucideIcons.ruler,
    LucideIcons.gauge,
    LucideIcons.trendingUp,
    LucideIcons.trendingDown,
    LucideIcons.lineChart,
    LucideIcons.barChart,
    LucideIcons.activity,

    // Body & Anatomy
    LucideIcons.eye,
    LucideIcons.ear,
    LucideIcons.hand,
    LucideIcons.footprints,
    LucideIcons.accessibility,

    // Hygiene & Self-Care
    LucideIcons.bath,
    LucideIcons.scissors,
    LucideIcons.sparkle,
    LucideIcons.droplet,

    // Wellness Activities
    LucideIcons.palmtree,
    LucideIcons.umbrella,
    LucideIcons.sunSnow,
    LucideIcons.waves,
    LucideIcons.tent,
    LucideIcons.mountain,
    LucideIcons.trees,
    LucideIcons.leaf,

    // Time & Scheduling
    LucideIcons.clock,
    LucideIcons.alarmClock,
    LucideIcons.timer,
    LucideIcons.calendar,
    LucideIcons.calendarHeart,

    // Goals & Progress
    LucideIcons.award,
    LucideIcons.medal,
    LucideIcons.trophy,
    LucideIcons.target,
    LucideIcons.checkCircle,
    LucideIcons.star,
  ];

  static final List<IconData> _lifestyleHobbiesIcons = [
    // Entertainment & Gaming
    LucideIcons.gamepad,
    LucideIcons.gamepad2,
    LucideIcons.joystick,
    LucideIcons.dices,
    LucideIcons.puzzle,
    LucideIcons.swords,
    LucideIcons.wand,
    LucideIcons.wand2,

    // Music & Audio
    LucideIcons.music,
    LucideIcons.music2,
    LucideIcons.music3,
    LucideIcons.music4,
    LucideIcons.mic,
    LucideIcons.mic2,
    LucideIcons.headphones,
    LucideIcons.speaker,
    LucideIcons.volume,
    LucideIcons.volume2,
    LucideIcons.radio,
    LucideIcons.podcast,

    // Arts & Crafts
    LucideIcons.brush,
    LucideIcons.palette,
    LucideIcons.paintbrush,
    LucideIcons.paintbrush2,
    LucideIcons.pipette,
    LucideIcons.sparkles,
    LucideIcons.wand,
    LucideIcons.scissors,
    LucideIcons.stamp,

    // Photography & Video
    LucideIcons.camera,
    LucideIcons.cameraOff,
    LucideIcons.video,
    LucideIcons.videoOff,
    LucideIcons.film,
    LucideIcons.clapperboard,
    LucideIcons.image,
    LucideIcons.scan,

    // Reading & Writing
    LucideIcons.book,
    LucideIcons.bookOpen,
    LucideIcons.bookMarked,
    LucideIcons.library,
    LucideIcons.newspaper,
    LucideIcons.scroll,
    LucideIcons.pencil,
    LucideIcons.feather,
    LucideIcons.stickyNote,

    // Cooking & Food
    LucideIcons.chefHat,
    LucideIcons.utensils,
    LucideIcons.utensilsCrossed,
    LucideIcons.soup,
    LucideIcons.pizza,
    LucideIcons.cake,
    LucideIcons.croissant,
    LucideIcons.coffee,
    LucideIcons.cupSoda,
    LucideIcons.wine,
    LucideIcons.martini,

    // Gardening & Nature
    LucideIcons.flower,
    LucideIcons.flower2,
    LucideIcons.leaf,
    LucideIcons.leafyGreen,
    LucideIcons.trees,
    LucideIcons.sprout,
    LucideIcons.palmtree,

    // Travel & Adventure
    LucideIcons.plane,
    LucideIcons.planeTakeoff,
    LucideIcons.planeLanding,
    LucideIcons.car,
    LucideIcons.bike,
    LucideIcons.train,
    LucideIcons.ship,
    LucideIcons.sailboat,
    LucideIcons.bus,
    LucideIcons.map,
    LucideIcons.mapPin,
    LucideIcons.compass,
    LucideIcons.globe,
    LucideIcons.luggage,
    LucideIcons.backpack,
    LucideIcons.tent,
    LucideIcons.mountain,
    LucideIcons.mountainSnow,

    // Sports & Outdoor Activities
    LucideIcons.target,

    // Shopping & Fashion
    LucideIcons.shoppingCart,
    LucideIcons.shoppingBag,
    LucideIcons.store,
    LucideIcons.shirt,
    LucideIcons.wallet,
    LucideIcons.creditCard,
    LucideIcons.tag,
    LucideIcons.ticket,
    LucideIcons.gift,
    LucideIcons.gem,
    LucideIcons.diamond,
    LucideIcons.watch,
    LucideIcons.glasses,

    // Home & DIY
    LucideIcons.home,
    LucideIcons.warehouse,
    LucideIcons.hammer,
    LucideIcons.wrench,
    LucideIcons.paintBucket,
    LucideIcons.ruler,
    LucideIcons.package,

    // Pets & Animals
    LucideIcons.dog,
    LucideIcons.cat,
    LucideIcons.bird,
    LucideIcons.fish,
    LucideIcons.bug,
    LucideIcons.squirrel,

    // Parties & Celebrations
    LucideIcons.partyPopper,
    LucideIcons.cake,
    LucideIcons.gift,
    LucideIcons.sparkles,
    LucideIcons.crown,

    // Learning & Education
    LucideIcons.graduationCap,
    LucideIcons.school,
    LucideIcons.microscope,
    LucideIcons.beaker,
    LucideIcons.atom,
    LucideIcons.dna,

    // Collecting & Hobbies
    LucideIcons.stamp,
    LucideIcons.coins,
    LucideIcons.medal,
    LucideIcons.award,
    LucideIcons.trophy,
    LucideIcons.archive,
    LucideIcons.box,

    // Technology & Gadgets
    LucideIcons.smartphone,
    LucideIcons.tablet,
    LucideIcons.laptop,
    LucideIcons.monitor,
    LucideIcons.tv,
    LucideIcons.radio,
    LucideIcons.battery,
    LucideIcons.usb,
    LucideIcons.plug,

    // Miscellaneous
    LucideIcons.star,
    LucideIcons.heart,
    LucideIcons.flame,
    LucideIcons.rocket,
    LucideIcons.rainbow,
    LucideIcons.umbrella,
    LucideIcons.snowflake,
    LucideIcons.sun,
    LucideIcons.moon,
    LucideIcons.cloud,
  ];
}

// Bloc for managing icon selection state
class IconBloc extends Bloc<IconEvent, IconState> {
  IconBloc()
      : super(
          IconState(
            selectedIcon: LucideIcons.dumbbell,
            currentIndex: 0,
          ),
        ) {
    on<UpdateSelectedIcon>((event, emit) {
      emit(state.copyWith(selectedIcon: event.icon));
    });
    on<UpdateTabIndex>((event, emit) {
      emit(state.copyWith(currentIndex: event.index));
    });
  }
}

class IconState {
  final IconData selectedIcon;
  final int currentIndex;

  IconState({required this.selectedIcon, required this.currentIndex});

  IconState copyWith({IconData? selectedIcon, int? currentIndex}) {
    return IconState(
      selectedIcon: selectedIcon ?? this.selectedIcon,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

abstract class IconEvent {}

class UpdateSelectedIcon extends IconEvent {
  final IconData icon;

  UpdateSelectedIcon(this.icon);
}

class UpdateTabIndex extends IconEvent {
  final int index;

  UpdateTabIndex(this.index);
}

class SelectStreakActiveDays extends StatefulWidget {
  final Function(String days) onDaysSelected;
  final int selectedWeekDayIndex;
  final List<int>? activeDays;
  final bool isDark;
  const SelectStreakActiveDays({
    super.key,
    required this.onDaysSelected,
    this.selectedWeekDayIndex = 0,
    this.activeDays,
    this.isDark = true,
  });

  @override
  State<SelectStreakActiveDays> createState() => _SelectStreakActiveDaysState();
}

class _SelectStreakActiveDaysState extends State<SelectStreakActiveDays> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Active Days",
          style: GoogleFonts.poppins(
            color: AppColors.greyColorTheme(widget.isDark),
            fontSize: 16.0,
          ),
        ),
        const Gap(10.0),
        SizedBox(
          height: 50.0,
          child: ListView.separated(
            separatorBuilder: (context, index) => const Gap(10.0),
            scrollDirection: Axis.horizontal,
            itemCount:
                AppConstants.reorderDaysByIndex(widget.selectedWeekDayIndex)
                    .length,
            itemBuilder: (context, index) {
              final days = AppConstants.reorderDaysByIndex(
                  widget.selectedWeekDayIndex)[index];
              return InkWell(
                onTap: () => widget.onDaysSelected(days),
                child: Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: (widget.activeDays?.contains(
                              AppConstants.selectedDayIndex(days),
                            ) ??
                            false)
                        ? AppColors.primaryColor
                        : AppColors.backgroundColor(widget.isDark),
                    borderRadius: BorderRadius.circular(5.0),
                    border: !(widget.activeDays?.contains(
                              AppConstants.selectedDayIndex(days),
                            ) ??
                            false)
                        ? Border.all(
                            color: AppColors.greyColorTheme(widget.isDark),
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      days,
                      style: TextStyle(
                        color: !(widget.activeDays?.contains(
                                  AppConstants.selectedDayIndex(days),
                                ) ??
                                false)
                            ? AppColors.textColor(widget.isDark)
                            : AppColors.darkBackgroundColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Gap(10.0),
      ],
    );
  }
}
