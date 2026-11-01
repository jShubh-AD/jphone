import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:j_phone/core/router/app_routes.dart';

import '../../../../core/const/theme/app_color.dart';
import '../../../../core/widgets/sliver_app_bar.dart';
import '../../../../core/widgets/app_elevated_button.dart';

class Planner extends StatelessWidget {
  const Planner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const CustomSliverAppBar(title: 'Planner', showBack: true),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AppElevatedButton(
                    text: 'Add Task',
                    icon: Icons.add,
                    iconSize: 22,
                    borderWidth: 0,
                    borderRadius: 100,
                    shadowColor: const Color(0xFFF97316).withValues(alpha: 0.35),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.buttonGradient,
                        AppColors.buttonGradient2,
                        AppColors.buttonGradient3,
                      ],
                    ),
                    onPressed: () {
                      context.push(AppRoutes.plannerCreate);
                    },
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
