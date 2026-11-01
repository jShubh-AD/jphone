import 'package:flutter/material.dart';

import '../const/theme/app_color.dart';
import 'app_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final Function()? onTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onTap,
    this.showBack = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 65,
      titleSpacing: 8,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          if (showBack) ...[
            GestureDetector(
              onTap: () => Navigator.pop(context),
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

            SizedBox(width: 8),
          ],

          AppText(
            title,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral,
          ),
        ],
      ),
    );
  }
}
