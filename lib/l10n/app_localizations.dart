import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'PokeHub'**
  String get appTitle;

  /// No description provided for @region.
  ///
  /// In es, this message translates to:
  /// **'Región'**
  String get region;

  /// No description provided for @all.
  ///
  /// In es, this message translates to:
  /// **'Nacional'**
  String get all;

  /// No description provided for @type.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get type;

  /// No description provided for @allTypes.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get allTypes;

  /// No description provided for @noPokemonAvailable.
  ///
  /// In es, this message translates to:
  /// **'No hay Pokémon disponibles'**
  String get noPokemonAvailable;

  /// No description provided for @errorLoadingData.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar datos: {error}'**
  String errorLoadingData(Object error);

  /// No description provided for @errorLoadingDetails.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar detalles: {error}'**
  String errorLoadingDetails(Object error);

  /// No description provided for @searchPokemon.
  ///
  /// In es, this message translates to:
  /// **'Buscar Pokémon'**
  String get searchPokemon;

  /// No description provided for @searchByNameOrId.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre o ID...'**
  String get searchByNameOrId;

  /// No description provided for @searching.
  ///
  /// In es, this message translates to:
  /// **'Buscando: \"{query}\"'**
  String searching(Object query);

  /// No description provided for @pokemonCount.
  ///
  /// In es, this message translates to:
  /// **'{count} Pokémon'**
  String pokemonCount(Object count);

  /// No description provided for @loadingAllPokemon.
  ///
  /// In es, this message translates to:
  /// **'Cargando todos los Pokémon...'**
  String get loadingAllPokemon;

  /// No description provided for @errorLoadingPokemon.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar Pokémon'**
  String get errorLoadingPokemon;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @noResultsFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron Pokémon\ncon \"{query}\"'**
  String noResultsFound(Object query);

  /// No description provided for @noPokemonToShow.
  ///
  /// In es, this message translates to:
  /// **'No hay Pokémon para mostrar'**
  String get noPokemonToShow;

  /// No description provided for @abilities.
  ///
  /// In es, this message translates to:
  /// **'HABILIDADES'**
  String get abilities;

  /// No description provided for @stats.
  ///
  /// In es, this message translates to:
  /// **'ESTADÍSTICAS'**
  String get stats;

  /// No description provided for @description.
  ///
  /// In es, this message translates to:
  /// **'DESCRIPCIÓN'**
  String get description;

  /// No description provided for @evolution.
  ///
  /// In es, this message translates to:
  /// **'EVOLUCIÓN'**
  String get evolution;

  /// No description provided for @varieties.
  ///
  /// In es, this message translates to:
  /// **'VARIEDADES'**
  String get varieties;

  /// No description provided for @height.
  ///
  /// In es, this message translates to:
  /// **'Altura'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In es, this message translates to:
  /// **'Peso'**
  String get weight;

  /// No description provided for @shiny.
  ///
  /// In es, this message translates to:
  /// **'Shiny'**
  String get shiny;

  /// No description provided for @normal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// No description provided for @checkingUpdates.
  ///
  /// In es, this message translates to:
  /// **'Buscando actualizaciones...'**
  String get checkingUpdates;

  /// No description provided for @currentVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión actual: {version}'**
  String currentVersion(Object version);

  /// No description provided for @latestVersion.
  ///
  /// In es, this message translates to:
  /// **'Última versión: {version}'**
  String latestVersion(Object version);

  /// No description provided for @upToDate.
  ///
  /// In es, this message translates to:
  /// **'Estás actualizado'**
  String get upToDate;

  /// No description provided for @updateAvailable.
  ///
  /// In es, this message translates to:
  /// **'¡Actualización disponible!'**
  String get updateAvailable;

  /// No description provided for @downloadUpdate.
  ///
  /// In es, this message translates to:
  /// **'Descargar actualización'**
  String get downloadUpdate;

  /// No description provided for @downloading.
  ///
  /// In es, this message translates to:
  /// **'Descargando...'**
  String get downloading;

  /// No description provided for @errorCheckingUpdate.
  ///
  /// In es, this message translates to:
  /// **'Error al buscar actualizaciones'**
  String get errorCheckingUpdate;

  /// No description provided for @errorDownloading.
  ///
  /// In es, this message translates to:
  /// **'Error al descargar: {error}'**
  String errorDownloading(Object error);

  /// No description provided for @updateDownloaded.
  ///
  /// In es, this message translates to:
  /// **'Actualización descargada'**
  String get updateDownloaded;

  /// No description provided for @initializingDatabase.
  ///
  /// In es, this message translates to:
  /// **'Inicializando base de datos...'**
  String get initializingDatabase;

  /// No description provided for @descriptionNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'Descripción no disponible'**
  String get descriptionNotAvailable;

  /// No description provided for @errorLoadingVersion.
  ///
  /// In es, this message translates to:
  /// **'Error cargando versión actual: {error}'**
  String errorLoadingVersion(Object error);

  /// No description provided for @couldNotGetVersionInfo.
  ///
  /// In es, this message translates to:
  /// **'No se pudo obtener información de la versión'**
  String get couldNotGetVersionInfo;

  /// No description provided for @appIsUpToDate.
  ///
  /// In es, this message translates to:
  /// **'✓ La app ya está actualizada'**
  String get appIsUpToDate;

  /// No description provided for @errorGeneral.
  ///
  /// In es, this message translates to:
  /// **'Error: {error}'**
  String errorGeneral(Object error);

  /// No description provided for @downloadUrlNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'URL de descarga no disponible'**
  String get downloadUrlNotAvailable;

  /// No description provided for @errorDownloadingApk.
  ///
  /// In es, this message translates to:
  /// **'Error descargando APK: {error}'**
  String errorDownloadingApk(Object error);

  /// No description provided for @updateToVersion.
  ///
  /// In es, this message translates to:
  /// **'Actualizar a {version}'**
  String updateToVersion(Object version);

  /// No description provided for @alreadyUpdated.
  ///
  /// In es, this message translates to:
  /// **'Ya está actualizada'**
  String get alreadyUpdated;

  /// No description provided for @noPokemonFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron Pokémon\ncon \"{query}\"'**
  String noPokemonFound(Object query);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
