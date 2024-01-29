import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';

// ... autres importations nécessaires
class AppLocalizationsFr implements AppLocalizations {
  @override
  String get hello => 'Bonjour';

  @override
  String get goodbye => 'Au revoir';

  // ... autres traductions
}class AppLocalizationsEn implements AppLocalizations {
  @override
  String get hello => 'Hello';

  @override
  String get goodbye => 'Goodbye';

  // ... autres traductions en anglais

  String get callMe => 'Call me';
  String get howAreYou => 'How are you?';
  String get whatTimeIsIt => 'What time is it?';
  String get openSettings => 'Open settings';
  String get closeApp => 'Close app';
  String get pleaseWait => 'Please wait';
  String get anErrorOccurred => 'An error occurred';
  String get tryAgain => 'Try again';
  String get noInternetConnection => 'No internet connection';
  String get connectToWifi => 'Connect to Wi-Fi';
  String get or => 'or';
  String get useMobileData => 'Use mobile data';
  String get cancel => 'Cancel';
  String get yes => 'Yes';
  String get no => 'No';
  String get ok => 'OK';

  // ... autres traductions utiles en anglais

}



const locales = [
  'en', // Anglais
  'fr', // Français
  // ... autres locales
];

abstract class AppLocalizations {
  String get hello;

  String get goodbye;

  // ... autres traductions
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locales.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return AppLocalizationsEn();
      case 'fr':
        return AppLocalizationsFr();
      // ... autres locales
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
      ],
      supportedLocales: locales.map((locale) => Locale(locale)),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Exemple de conversion de texte en langage du téléphone'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              const Text(
                'Appuyez sur le bouton pour convertir le texte en langage du téléphone',
              ),
              ElevatedButton(
                onPressed: () async {
                  final locale = Localizations.localeOf(context);
                  
final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations) as AppLocalizations;


                  final helloText = localizations.hello;

                  final tts = FlutterTts();
                  await tts.speak(helloText);


                  
                },
                child: const Text('Convertir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() => runApp(const MyApp());
