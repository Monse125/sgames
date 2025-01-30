import 'package:flutter/material.dart';

import 'gamesSettings/game_settings.dart';

class GameSettingsProvider extends ChangeNotifier {
  final Map<String, GameSettings> _settings = {};

  void setSettings(String gameName, GameSettings settings) {
    _settings[gameName] = settings;
    notifyListeners();
  }

  T? getSettings<T extends GameSettings>(String gameName) {
    return _settings[gameName] as T?;
  }
}