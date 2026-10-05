import 'package:flutter/material.dart';

import '../const/app_images.dart';
import 'app_text.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final Function()? onTap;

  const CustomAppBar({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      toolbarHeight: 65,
      automaticallyImplyLeading: false,
      pinned: false,
      floating: true,
      snap: true,

      titleSpacing: 10,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
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

          SizedBox(width: 10),

          AppText(title, fontSize: 26, fontWeight: FontWeight.w700, height: 34),
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
