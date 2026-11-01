import 'package:flutter/material.dart';
import 'package:j_phone/core/widgets/app_bar.dart';
import 'package:j_phone/core/widgets/app_text.dart';

import '../../../../core/const/theme/app_color.dart';

class CreatePlan extends StatelessWidget {
  const CreatePlan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Create Plan", showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(

          children: [
            const AppText(
              "Goals",
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral,
            ),
            Container()
          ],
        ),
      ),
    );
  }
}
