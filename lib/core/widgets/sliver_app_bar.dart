import 'package:flutter/material.dart';
import 'package:j_phone/core/const/theme/app_color.dart';

import '../const/app_images.dart';
import 'app_text.dart';

class CustomSliverAppBar extends StatelessWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final Function()? onTap;

  const CustomSliverAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.onBack,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      toolbarHeight: 65,
      automaticallyImplyLeading: false,
      pinned: false,
      floating: true,
      snap: true,

      titleSpacing: 8,
      title: Row(
        children: [
          if (showBack) ...[
            GestureDetector(
              onTap: onBack ??
                  () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
              child: Container(
                width: 35,
                height: 35,
                padding: const EdgeInsets.all(1.5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      Color(0xFFF97316),
                      Color(0xFFDB2777),
                      Color(0xFF2563EB),
                    ],
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: AppColors.neutral,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ] else ...[
            Container(
              width: 35,
              height: 35,
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFFF97316),
                    Color(0xFFDB2777),
                    Color(0xFF2563EB),
                  ],
                ),
              ),
              child: ClipOval(
                child: Image.asset(AppImages.appLogo, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 8),
          ],

          AppText(
            title,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral,
          ),
        ],
      ),

      actions: [
        if (title.toLowerCase() == 'home') ...[
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF1F5F9),
            ),
            child: const Icon(Icons.search_outlined, size: 22),
          ),

          const SizedBox(width: 4),
        ],

        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF1F5F9),
            ),
            child: const Icon(Icons.dashboard_customize_outlined, size: 22),
          ),
        ),

        const SizedBox(width: 16),
      ],
    );
  }
}
