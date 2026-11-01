import 'package:flutter/material.dart';
import '../../../../core/const/theme/app_color.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/sliver_app_bar.dart';

/// The Expenses sub-app screen.
///
/// Serves as the independent "Expenses mini-app" entry point.
class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const CustomSliverAppBar(
              title: 'Expenses',
              showBack: true,
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 38,
                        color: Color(0xFF059669),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const AppText(
                      'Expenses App',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral,
                    ),
                    const SizedBox(height: 8),
                    const AppText(
                      'Track spending, manage budgets, and analyze transactions in this standalone sub-app.',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.navbarTextClr,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
