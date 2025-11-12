import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flareline/flutter_gen/app_localizations.dart';

class GridCard extends StatelessWidget {
  const GridCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      desktop: contentDesktopWidget,
      mobile: contentMobileWidget,
      tablet: contentMobileWidget,
    );
  }

  Widget contentDesktopWidget(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              final userCount = snapshot.hasData
                  ? snapshot.data!.docs.length.toString()
                  : '...';
              return _itemCardWidget(
                context,
                Icons.group,
                userCount,
                AppLocalizations.of(context)!.totalProduct,
                '0.43%',
                true,
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'Ame')
                .snapshots(),
            builder: (context, snapshot) {
              final ameCount = snapshot.hasData
                  ? snapshot.data!.docs.length.toString()
                  : '...';
              return _itemCardWidget(
                context,
                Icons.security_rounded,
                ameCount,
                'Total des Ames',
                '0.43%',
                false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget contentMobileWidget(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            final userCount = snapshot.hasData
                ? snapshot.data!.docs.length.toString()
                : '...';
            return _itemCardWidget(
              context,
              Icons.group,
              userCount,
              AppLocalizations.of(context)!.totalProduct,
              '0.43%',
              true,
            );
          },
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'Ame')
              .snapshots(),
          builder: (context, snapshot) {
            final ameCount = snapshot.hasData
                ? snapshot.data!.docs.length.toString()
                : '...';
            return _itemCardWidget(
              context,
              Icons.security_rounded,
              ameCount,
              'Total des "Ame"',
              '0.43%',
              false,
            );
          },
        ),
      ],
    );
  }

  Widget _itemCardWidget(
    BuildContext context,
    IconData icons,
    String text,
    String subTitle,
    String percentText,
    bool isGrow,
  ) {
    return CommonCard(
      height: 166,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                color: Colors.grey.shade200,
                child: Icon(
                  icons,
                  color: GlobalColors.sideBar,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  subTitle,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  percentText,
                  style: TextStyle(
                    fontSize: 10,
                    color: isGrow ? Colors.green : Colors.lightBlue,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  isGrow ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isGrow ? Colors.green : Colors.lightBlue,
                  size: 12,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
