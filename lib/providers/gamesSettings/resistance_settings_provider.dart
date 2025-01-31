
import 'package:flutter/material.dart';
import 'settings/resistance_game_settings.dart';

class ResistanceSettingsProvider with ChangeNotifier {
  ResistanceGameSettings _settings = ResistanceGameSettings();

  ResistanceGameSettings get settings => _settings;

  setSettings(ResistanceGameSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  // Implementación de setMaxForce
  void setMaxForce(double newMaxForce) {
    _settings.maxForce = newMaxForce;
    notifyListeners();  // Notifica a los escuchadores de un cambio en la configuración.
  }
}