library flareline_uikit;


import 'package:flareline_uikit/core/mvvm/bloc/bloc_base_state.dart';
import 'package:flareline_uikit/core/mvvm/bloc/bloc_base_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BlocBaseStlessWidget<VM extends BlocBaseViewModel<ST>, ST extends BlocBaseState> extends StatelessWidget {
  final Map<String, dynamic>? params;

  VM viewModelBuilder(BuildContext context);

  const BlocBaseStlessWidget({this.params, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final vm = viewModelBuilder(context);
        vm.setArgs(params);
        vm.onViewCreated(context);
        return vm;
      },
      child: BlocBuilder<VM, ST>(
          buildWhen: (previous, current) => needBuild(previous, current),
          builder: (context, state) {
            VM viewModel = BlocProvider.of<VM>(context);
            return BlocListener<VM, ST>(listener: blocListener, child: bodyWidget(context, viewModel, state));
          }),
    );
  }

  Widget bodyWidget(BuildContext context, VM viewModel, ST state);

  bool needBuild(ST previous, ST current) {
    return previous.props != current.props;
  }


  void blocListener(BuildContext context, ST state) {
  }
}
