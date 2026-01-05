// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'PokeHub';

  @override
  String get region => 'Región';

  @override
  String get all => 'Nacional';

  @override
  String get type => 'Tipo';

  @override
  String get allTypes => 'Todos';

  @override
  String get noPokemonAvailable => 'No hay Pokémon disponibles';

  @override
  String errorLoadingData(Object error) {
    return 'Error al cargar datos: $error';
  }

  @override
  String errorLoadingDetails(Object error) {
    return 'Error al cargar detalles: $error';
  }

  @override
  String get searchPokemon => 'Buscar Pokémon';

  @override
  String get searchByNameOrId => 'Buscar por nombre o ID...';

  @override
  String searching(Object query) {
    return 'Buscando: \"$query\"';
  }

  @override
  String pokemonCount(Object count) {
    return '$count Pokémon';
  }

  @override
  String get loadingAllPokemon => 'Cargando todos los Pokémon...';

  @override
  String get errorLoadingPokemon => 'Error al cargar Pokémon';

  @override
  String get retry => 'Reintentar';

  @override
  String noResultsFound(Object query) {
    return 'No se encontraron Pokémon\ncon \"$query\"';
  }

  @override
  String get noPokemonToShow => 'No hay Pokémon para mostrar';

  @override
  String get abilities => 'HABILIDADES';

  @override
  String get stats => 'ESTADÍSTICAS';

  @override
  String get description => 'DESCRIPCIÓN';

  @override
  String get evolution => 'EVOLUCIÓN';

  @override
  String get varieties => 'VARIEDADES';

  @override
  String get height => 'Altura';

  @override
  String get weight => 'Peso';

  @override
  String get shiny => 'Shiny';

  @override
  String get normal => 'Normal';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get settings => 'Configuración';

  @override
  String get checkingUpdates => 'Buscando actualizaciones...';

  @override
  String currentVersion(Object version) {
    return 'Versión actual: $version';
  }

  @override
  String latestVersion(Object version) {
    return 'Última versión: $version';
  }

  @override
  String get upToDate => 'Estás actualizado';

  @override
  String get updateAvailable => '¡Actualización disponible!';

  @override
  String get downloadUpdate => 'Descargar actualización';

  @override
  String get downloading => 'Descargando...';

  @override
  String get errorCheckingUpdate => 'Error al buscar actualizaciones';

  @override
  String errorDownloading(Object error) {
    return 'Error al descargar: $error';
  }

  @override
  String get updateDownloaded => 'Actualización descargada';

  @override
  String get initializingDatabase => 'Inicializando base de datos...';

  @override
  String get descriptionNotAvailable => 'Descripción no disponible';

  @override
  String errorLoadingVersion(Object error) {
    return 'Error cargando versión actual: $error';
  }

  @override
  String get couldNotGetVersionInfo =>
      'No se pudo obtener información de la versión';

  @override
  String get appIsUpToDate => '✓ La app ya está actualizada';

  @override
  String errorGeneral(Object error) {
    return 'Error: $error';
  }

  @override
  String get downloadUrlNotAvailable => 'URL de descarga no disponible';

  @override
  String errorDownloadingApk(Object error) {
    return 'Error descargando APK: $error';
  }

  @override
  String updateToVersion(Object version) {
    return 'Actualizar a $version';
  }

  @override
  String get alreadyUpdated => 'Ya está actualizada';

  @override
  String noPokemonFound(Object query) {
    return 'No se encontraron Pokémon\ncon \"$query\"';
  }
}
