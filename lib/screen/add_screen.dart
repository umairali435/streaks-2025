import 'package:flex_color_scheme/flex_color_scheme.dart';
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
import 'package:streaks/res/colors.dart';
import 'package:streaks/res/constants.dart';
import 'package:streaks/res/strings.dart';
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
  int selectedColorCode = AppConstants.colors.first.value;
  int selectedContainerColorCode =
      AppConstants.primaryContainerColors.first.value;
  int currentIndex = 0;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    activeDaysController.text = selectedDaysPerWeek;
    if (widget.streak != null) {
      nameController.text = widget.streak?.name ?? "";
      selectedTime = TimeOfDay(
          hour: widget.streak?.notificationHour ?? 0,
          minute: widget.streak?.notificationMinute ?? 0);
      timeController.text = TimeOfDay(
              hour: widget.streak?.notificationHour ?? 0,
              minute: widget.streak?.notificationMinute ?? 0)
          .format(context);
      selectedWeekDay = AppText.getDayOfWeek(widget.streak?.selectedWeek ?? 0);
      selectedDaysPerWeek = widget.streak?.daysOfWeek.first ?? "";
      activeDaysController.text = selectedDaysPerWeek;
      activeDays = widget.streak?.selectedDays ?? [];
      selectedWeekIndex = widget.streak?.selectedWeek ?? 0;
      selectedColorCode = widget.streak!.colorCode;
      selectedContainerColorCode = widget.streak!.containerColor;
      setState(() {});
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.chevronLeft,
            color: AppColors.whiteColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.streak == null ? "Add New Streak" : "Edit Streak",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppColors.whiteColor,
            fontSize: 18.0,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _saveStreak,
            icon: const Icon(
              LucideIcons.checkCircle,
              color: AppColors.whiteColor,
            ),
          ),
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
              title: "How many days per week should you complete this habit?",
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
              SelectStreakActiveDays(
                activeDays: activeDays,
                selectedWeekDayIndex: selectedWeekIndex,
                onDaysSelected: (days) {
                  int selectedDayLength = int.parse(selectedDaysPerWeek);
                  setState(() {
                    if (!activeDays
                            .contains(AppConstants.selectedDayIndex(days)) &&
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
                        if (activeDays
                            .contains(AppConstants.selectedDayIndex(days))) {
                          activeDays
                              .remove(AppConstants.selectedDayIndex(days));
                        } else {
                          activeDays.add(AppConstants.selectedDayIndex(days));
                        }
                      });
                    }
                  });
                },
              ),
            Text(
              "Select Streak Color",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w900,
                color: AppColors.whiteColor,
                fontSize: 18.0,
              ),
            ),
            const Gap(8.0),
            StreaksColors(
              initialColor: selectedColorCode,
              onColorSelected: (colorCode, containerColorCode) {
                setState(() {
                  selectedColorCode = colorCode;
                  selectedContainerColorCode = containerColorCode;
                });
              },
            ),
            const Gap(8.0),
            Text(
              "Select Streak Icon",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w900,
                color: AppColors.whiteColor,
                fontSize: 18.0,
              ),
            ),
            const Gap(8.0),
            BlocBuilder<IconBloc, IconState>(
              builder: (context, state) {
                return GestureDetector(
                  onTap: () => _showIconPicker(context),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.whiteColor),
                    ),
                    child:
                        Icon(state.selectedIcon, color: AppColors.whiteColor),
                  ),
                );
              },
            ),
            const Gap(30.0),
            GestureDetector(
              onTap: _saveStreak,
              child: Container(
                width: double.infinity,
                height: 45.0,
                decoration: BoxDecoration(
                  color: const Color.from(
                      alpha: 1, red: 0.894, green: 0.404, blue: 0.486),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Text(
                    "Save",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w900,
                      color: AppColors.whiteColor,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
            ),
            const Gap(20.0),
          ],
        ),
      ),
    );
  }

  _errorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
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
      containerColor: selectedContainerColorCode,
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
  }

  void _showIconPicker(BuildContext ctx) {
    final List<String> categories = [
      "All",
      "Social",
      "Productivity",
      "Sports",
    ];
    showModalBottomSheet(
      backgroundColor: AppColors.secondaryColor,
      context: context,
      isScrollControlled: true,
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
                                        ? AppColors.whiteColor
                                        : FlexColor.greyDarkSecondary,
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
                                      borderRadius: BorderRadius.circular(10.0),
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
                            ? _socialIcons
                            : state.currentIndex == 2
                                ? _productivityIcons
                                : _sportsIcons,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconGrid(BuildContext context, List<IconData> icons) {
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
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.whiteColor),
              ),
              child: Icon(icon, color: AppColors.whiteColor),
            ),
          );
        },
      ),
    );
  }

  final List<IconData> _allIcons = [
    LucideIcons.dumbbell,
    LucideIcons.book,
    LucideIcons.briefcase,
    LucideIcons.camera,
    LucideIcons.heart,
    LucideIcons.music,
    LucideIcons.star,
    LucideIcons.bike,
    LucideIcons.brush,
    LucideIcons.calendar,
    LucideIcons.car,
    LucideIcons.checkCircle,
    LucideIcons.clock,
    LucideIcons.cloud,
    LucideIcons.code,
    LucideIcons.coffee,
    LucideIcons.dollarSign,
    LucideIcons.download,
    LucideIcons.edit,
    LucideIcons.eye,
    LucideIcons.file,
    LucideIcons.film,
    LucideIcons.flag,
    LucideIcons.flame,
    LucideIcons.folder,
    LucideIcons.gamepad,
    LucideIcons.gift,
    LucideIcons.globe,
    LucideIcons.headphones,
    LucideIcons.home,
    LucideIcons.image,
    LucideIcons.inbox,
    LucideIcons.info,
    LucideIcons.key,
    LucideIcons.lightbulb,
    LucideIcons.link,
    LucideIcons.lock,
    LucideIcons.mail,
    LucideIcons.map,
    LucideIcons.mic,
    LucideIcons.monitor,
    LucideIcons.moon,
    LucideIcons.phone,
    LucideIcons.pieChart,
    LucideIcons.pin,
    LucideIcons.play,
    LucideIcons.plusCircle,
    LucideIcons.pocket,
    LucideIcons.printer,
    LucideIcons.save,
    LucideIcons.search,
    LucideIcons.send,
    LucideIcons.settings,
    LucideIcons.shield,
    LucideIcons.shoppingCart,
    LucideIcons.smile,
    LucideIcons.speaker,
    LucideIcons.sun,
    LucideIcons.tag,
    LucideIcons.thermometer,
    LucideIcons.trash,
    LucideIcons.truck,
    LucideIcons.tv,
    LucideIcons.upload,
    LucideIcons.user,
    LucideIcons.video,
    LucideIcons.volume,
    LucideIcons.watch,
    LucideIcons.wifi,
    LucideIcons.zap,
    // Add more icons as needed
  ];

  final List<IconData> _socialIcons = [
    LucideIcons.activity,
    LucideIcons.badgeCheck,
    LucideIcons.heart,
    LucideIcons.flame,
    LucideIcons.dribbble,
    LucideIcons.facebook,
    LucideIcons.instagram,
    LucideIcons.linkedin,
    LucideIcons.youtube,
    LucideIcons.flag,
    LucideIcons.messageCircle,
    LucideIcons.rss,
    LucideIcons.share2,
    LucideIcons.thumbsUp,
    LucideIcons.thumbsDown,
    LucideIcons.slack,
    LucideIcons.smilePlus,
    LucideIcons.user,
    LucideIcons.vote,
    LucideIcons.stickyNote,
    LucideIcons.book,
    LucideIcons.search,
    LucideIcons.scan,
    // Add more social icons as needed
  ];

  final List<IconData> _productivityIcons = [
    LucideIcons.briefcase,
    LucideIcons.calendar,
    LucideIcons.clock,
    LucideIcons.code,
    LucideIcons.edit,
    LucideIcons.file,
    LucideIcons.folder,
    LucideIcons.inbox,
    LucideIcons.key,
    LucideIcons.lightbulb,
    LucideIcons.lock,
    LucideIcons.mail,
    LucideIcons.map,
    LucideIcons.monitor,
    LucideIcons.phone,
    LucideIcons.pieChart,
    LucideIcons.printer,
    LucideIcons.save,
    LucideIcons.search,
    LucideIcons.send,
    LucideIcons.settings,
    LucideIcons.tag,
    // Add more productivity icons as needed
  ];

  final List<IconData> _sportsIcons = [
    LucideIcons.award,
    LucideIcons.gauge,
    LucideIcons.dumbbell,
    LucideIcons.bike,
    LucideIcons.landmark,
    LucideIcons.medal,
    LucideIcons.trophy,
    LucideIcons.waves,
    LucideIcons.treeDeciduous,
    LucideIcons.sun,
    LucideIcons.leaf,
    // Add more sports icons as needed
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
  const SelectStreakActiveDays({
    super.key,
    required this.onDaysSelected,
    this.selectedWeekDayIndex = 0,
    this.activeDays,
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
            fontWeight: FontWeight.w700,
            color: AppColors.whiteColor,
            letterSpacing: 0.8,
            fontSize: 18.0,
          ),
        ),
        const Gap(8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: AppConstants.reorderDaysByIndex(widget.selectedWeekDayIndex)
              .map(
                (days) => InkWell(
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
                          : AppColors.blackColor,
                      borderRadius: BorderRadius.circular(5.0),
                      border: !(widget.activeDays?.contains(
                                AppConstants.selectedDayIndex(days),
                              ) ??
                              false)
                          ? Border.all(
                              color: FlexColor.greyDarkSecondary,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        days,
                        style: const TextStyle(
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const Gap(10.0),
      ],
    );
  }
}
