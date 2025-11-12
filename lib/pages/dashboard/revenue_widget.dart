import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline/components/charts/bar_chart.dart';
import 'package:flareline_uikit/components/charts/line_chart.dart';
import 'package:responsive_builder/responsive_builder.dart';

class RevenueWidget extends StatefulWidget {
  const RevenueWidget({super.key});

  @override
  State<RevenueWidget> createState() => _RevenueWidgetState();
}

class _RevenueWidgetState extends State<RevenueWidget> {
  String _period = 'Monthly';
  String _selectedRole = 'Tous';
  List<Map<String, dynamic>> _addedUsers = [];

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year);
    final startOfMonth = DateTime(now.year, now.month);

    print('⏳ _loadChartData appelée');
    print('Période : $_period');
    print('startOfMonth: $startOfMonth');
    print('startOfYear: $startOfYear');
    print('Filtre rôle : $_selectedRole');

    Query usersQuery = FirebaseFirestore.instance.collection('users');

    if (_selectedRole != 'Tous') {
      usersQuery = usersQuery.where('role', isEqualTo: _selectedRole);
    }

    final addedQuery = await usersQuery
        .where('createdAt',
            isGreaterThanOrEqualTo:
                _period == 'Monthly' ? startOfMonth : startOfYear)
        .get();

    final added = <String, int>{};

    print('📦 Documents trouvés : ${addedQuery.docs.length}');

    for (var doc in addedQuery.docs) {
      final createdAtRaw = doc['createdAt'];
      final createdAt = createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.tryParse(createdAtRaw.toString()) ?? now;

      print('🗂️ Document : ${doc.id} | createdAt: $createdAt');

      final key = _period == 'Monthly'
          ? createdAt.day.toString().padLeft(2, '0')
          : _monthAbbr(createdAt.month);

      added[key] = (added[key] ?? 0) + 1;
    }

    final labels = _period == 'Monthly'
        ? List.generate(DateTime(now.year, now.month + 1, 0).day,
            (i) => (i + 1).toString().padLeft(2, '0'))
        : [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
          ];

    final chartData = labels.map((x) => {'x': x, 'y': added[x] ?? 0}).toList();

    print('📊 Données finales pour le graphe : $chartData');

    setState(() {
      _addedUsers = chartData;
    });
  }

  String _monthAbbr(int month) {
    return [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      desktop: _revenueWidgetDesktop,
      mobile: _revenueWidgetMobile,
      tablet: _revenueWidgetMobile,
    );
  }

  Widget _revenueWidgetDesktop(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _lineChart(),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: _barChart(),
          ),
        ],
      ),
    );
  }

  Widget _revenueWidgetMobile(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 360, child: _lineChart()),
        const SizedBox(height: 16),
        SizedBox(height: 360, child: _barChart()),
      ],
    );
  }

  Widget _lineChart() {
    final roles = [
      'Tous',
      'Ame',
      'admin',
      'Assistant générale',
      'Directeur regionale',
      'Assistant accueil',
      'Enseignant titulaire',
      'Enseignant de recyclage',
      'user',
    ];

    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedRole,
                  items: roles
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                    _loadChartData();
                  },
                ),
                DropdownButton<String>(
                  value: _period,
                  items: ['Monthly', 'Yearly']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _period = value!;
                    });
                    _loadChartData();
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: LineChartWidget(
                title: 'Statistiques des Utilisateurs',
                dropdownItems: const [], // Désactivé ici
                onDropdownChanged: (_) {},
                datas: [
                  {
                    'name': 'Ajoutés',
                    'color': const Color(0xFF01B7F9),
                    'data': _addedUsers,
                  },
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barChart() {
    return CommonCard(
      child: BarChartWidget(),
    );
  }
}
