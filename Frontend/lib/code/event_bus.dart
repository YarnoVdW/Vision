import 'package:event_bus/event_bus.dart';

class EventBusService {
  factory EventBusService() => _instance;

  EventBusService._internal();

  static final EventBusService _instance = EventBusService._internal();

  final EventBus _eventBus = EventBus();

  EventBus get eventBus => _eventBus;
}

class CustomEvent {}
