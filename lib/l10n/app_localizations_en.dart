// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PokeHub';

  @override
  String get region => 'Region';

  @override
  String get all => 'National';

  @override
  String get type => 'Type';

  @override
  String get allTypes => 'All';

  @override
  String get noPokemonAvailable => 'No Pokémon available';

  @override
  String errorLoadingData(Object error) {
    return 'Error loading data: $error';
  }

  @override
  String errorLoadingDetails(Object error) {
    return 'Error loading details: $error';
  }

  @override
  String get searchPokemon => 'Search Pokémon';

  @override
  String get searchByNameOrId => 'Search by name or ID...';

  @override
  String searching(Object query) {
    return 'Searching: \"$query\"';
  }

  @override
  String pokemonCount(Object count) {
    return '$count Pokémon';
  }

  @override
  String get loadingAllPokemon => 'Loading all Pokémon...';

  @override
  String get errorLoadingPokemon => 'Error loading Pokémon';

  @override
  String get retry => 'Retry';

  @override
  String noResultsFound(Object query) {
    return 'No Pokémon found\nwith \"$query\"';
  }

  @override
  String get noPokemonToShow => 'No Pokémon to show';

  @override
  String get abilities => 'ABILITIES';

  @override
  String get stats => 'STATS';

  @override
  String get description => 'DESCRIPTION';

  @override
  String get evolution => 'EVOLUTION';

  @override
  String get varieties => 'VARIETIES';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String get shiny => 'Shiny';

  @override
  String get normal => 'Normal';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get settings => 'Settings';

  @override
  String get checkingUpdates => 'Checking for updates...';

  @override
  String currentVersion(Object version) {
    return 'Current version: $version';
  }

  @override
  String latestVersion(Object version) {
    return 'Latest version: $version';
  }

  @override
  String get upToDate => 'You\'re up to date';

  @override
  String get updateAvailable => 'Update available!';

  @override
  String get downloadUpdate => 'Download update';

  @override
  String get downloading => 'Downloading...';

  @override
  String get errorCheckingUpdate => 'Error checking for updates';

  @override
  String errorDownloading(Object error) {
    return 'Error downloading: $error';
  }

  @override
  String get updateDownloaded => 'Update downloaded';

  @override
  String get initializingDatabase => 'Initializing database...';

  @override
  String get descriptionNotAvailable => 'Description not available';

  @override
  String errorLoadingVersion(Object error) {
    return 'Error loading current version: $error';
  }

  @override
  String get couldNotGetVersionInfo => 'Could not get version information';

  @override
  String get appIsUpToDate => '✓ The app is already up to date';

  @override
  String errorGeneral(Object error) {
    return 'Error: $error';
  }

  @override
  String get downloadUrlNotAvailable => 'Download URL not available';

  @override
  String errorDownloadingApk(Object error) {
    return 'Error downloading APK: $error';
  }

  @override
  String updateToVersion(Object version) {
    return 'Update to $version';
  }

  @override
  String get alreadyUpdated => 'Already updated';

  @override
  String noPokemonFound(Object query) {
    return 'No Pokémon found\nwith \"$query\"';
  }
}
