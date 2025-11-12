library flareline_uikit;

import 'dart:async';

import 'package:flareline_uikit/core/event/global_event.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

abstract class BaseViewModel extends ChangeNotifier {
  var logger = Logger();

  bool _isDisposed = false;

  Map<String, dynamic>? param;

  bool get isRegisterEventBus => false;

  bool get isStickEventBus => false;

  StreamSubscription? _eventBusFn;

  // --- Ajout de la gestion de l'état busy ---
  bool _busy = false;
  bool get isBusy => _busy;

  void setBusy(bool value) {
    if (_busy == value) return; // évite les notifications inutiles
    _busy = value;
    notifyListeners();
  }
  // ------------------------------------------

  BaseViewModel(BuildContext context) {
    if (isRegisterEventBus) {
      _registerEventBus(context);
    }

    init(context);
  }

  void setArgs(Map<String, dynamic>? param) {
    this.param = param;
  }

  void init(BuildContext context) {}

  void onViewCreated(BuildContext context) {}

  void _registerEventBus(BuildContext context) {
    if (isStickEventBus) {
      _eventBusFn = GlobalEvent.eventBus.onSticky<EventInfo>().listen((event) {
        if (_isDisposed) {
          return;
        }
        handleEventBus(context, event);
      });
      return;
    }
    _eventBusFn = GlobalEvent.eventBus.on<EventInfo>().listen((event) {
      if (_isDisposed) {
        return;
      }
      handleEventBus(context, event);
    });
  }

  void _unRegisterEventBus() {
    if (_eventBusFn != null) {
      _eventBusFn!.cancel();
    }
  }

  void handleEventBus(BuildContext context, EventInfo eventInfo) {}

  @override
  void notifyListeners() {
    if (_isDisposed) {
      return;
    }

    super.notifyListeners();
  }

  void log(String msg) {
    logger.f(msg);
  }

  @override
  void dispose() {
    if (!_isDisposed) {
      _unRegisterEventBus();
      onSafeDispose();
    }
    _isDisposed = true;
    super.dispose();
  }

  void onSafeDispose() {}
}
