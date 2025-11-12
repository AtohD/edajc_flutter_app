library flareline_uikit;

import 'package:flareline_uikit/core/mvvm/base_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class BaseWidget<VM extends BaseViewModel>
    extends StatelessWidget {
  final Map<String, dynamic>? params;

  VM viewModelBuilder(BuildContext context);

  const BaseWidget({this.params, super.key});

  @override
  Widget build(BuildContext context) {
    final VM mViewMode = viewModelBuilder(context);
    mViewMode.setArgs(params);
    mViewMode.onViewCreated(context);

    return ChangeNotifierProvider<VM>(
        create: (context) => mViewMode,
        child: Consumer<VM>(
          builder: (context, viewModel, child) =>
              bodyWidget(context, viewModel, child),
          child: staticChild(),
        ));
  }

  Widget bodyWidget(BuildContext context, VM viewModel, Widget? child);

  Widget? staticChild() {
    return null;
  }
}
