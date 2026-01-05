-- ============================================================
-- POKEMON DATABASE SCHEMA - SQLite
-- ============================================================

PRAGMA encoding = 'UTF-8';
PRAGMA foreign_keys = ON;

-- ============================================================
-- LANGUAGES
-- ============================================================

CREATE TABLE language (
    id INTEGER PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(50)
);

-- ============================================================
-- GENERATIONS
-- ============================================================

CREATE TABLE generation (
    id INTEGER PRIMARY KEY,
    code VARCHAR(20) UNIQUE -- 'generation-i', 'generation-ii', 'generation-iii'
);

CREATE TABLE generation_translation (
    generation_id INTEGER NOT NULL,
    language_id INTEGER NOT NULL,
    name VARCHAR(100),
    code VARCHAR(20),
    PRIMARY KEY (generation_id, language_id),
    FOREIGN KEY (generation_id) REFERENCES generation(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES language(id) ON DELETE CASCADE
);

-- ============================================================
-- REGIONS
-- ============================================================

CREATE TABLE region (
    id INTEGER PRIMARY KEY,
    code VARCHAR(20) UNIQUE,
    generation_id INTEGER NOT NULL
);

CREATE TABLE region_translation (
    region_id INTEGER NOT NULL,
    language_id INTEGER NOT NULL,
    name VARCHAR(100),
    PRIMARY KEY (region_id, language_id),
    FOREIGN KEY (region_id) REFERENCES region(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES language(id) ON DELETE CASCADE
);

-- ============================================================
-- POKEMON SPECIES (ESPECIES BASE)
-- ============================================================

CREATE TABLE pokemon_species (
    id INTEGER PRIMARY KEY,
    national_dex_number INTEGER NOT NULL UNIQUE,
    generation_id INTEGER NOT NULL,
    FOREIGN KEY (generation_id) REFERENCES generation(id) ON DELETE RESTRICT
);

-- ============================================================
-- POKEMON (FORMAS ESPECÍFICAS)
-- ============================================================

CREATE TABLE pokemon (
    id INTEGER PRIMARY KEY,
    species_id INTEGER NOT NULL,
    form_name VARCHAR(50) DEFAULT 'normal',
    height REAL,
    weight REAL,
    is_default_form BOOLEAN DEFAULT 1,
    FOREIGN KEY (species_id) REFERENCES pokemon_species(id) ON DELETE CASCADE
);

CREATE TABLE pokemon_translation (
    pokemon_id INTEGER NOT NULL,
    language_id INTEGER NOT NULL,
    form_display_name VARCHAR(100),
    description TEXT,
    PRIMARY KEY (pokemon_id, language_id),
    FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES language(id) ON DELETE CASCADE
);

-- ============================================================
-- POKEMON AVAILABILITY BY REGION (POKÉDEX)
-- ============================================================

CREATE TABLE pokemon_available_in_region (
    pokemon_id INTEGER NOT NULL,
    region_id INTEGER NOT NULL,
    regional_dex_number INTEGER,
    PRIMARY KEY (pokemon_id, region_id),
    FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
    FOREIGN KEY (region_id) REFERENCES region(id) ON DELETE CASCADE
);

-- ============================================================
-- TYPES
-- ============================================================

CREATE TABLE type (
    id INTEGER PRIMARY KEY,
    code VARCHAR(20) UNIQUE -- 'fire', 'water', 'grass'
);

CREATE TABLE type_translation (
    type_id INTEGER NOT NULL,
    language_id INTEGER NOT NULL,
    name VARCHAR(50),
    PRIMARY KEY (type_id, language_id),
    FOREIGN KEY (type_id) REFERENCES type(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES language(id) ON DELETE CASCADE
);

CREATE TABLE pokemon_type (
    pokemon_id INTEGER NOT NULL,
    type_id INTEGER NOT NULL,
    slot INTEGER,
    PRIMARY KEY (pokemon_id, type_id),
    FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
    FOREIGN KEY (type_id) REFERENCES type(id) ON DELETE CASCADE
);

CREATE TABLE type_image (
    type_id INTEGER PRIMARY KEY,
    image_url VARCHAR(500),
    FOREIGN KEY (type_id) REFERENCES type(id) ON DELETE CASCADE
);

-- ============================================================
-- ABILITIES
-- ============================================================

CREATE TABLE ability (
    id INTEGER PRIMARY KEY,
    generation INTEGER
);

CREATE TABLE ability_translation (
    ability_id INTEGER NOT NULL,
    language_id INTEGER NOT NULL,
    name VARCHAR(100),
    description TEXT,
    PRIMARY KEY (ability_id, language_id),
    FOREIGN KEY (ability_id) REFERENCES ability(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES language(id) ON DELETE CASCADE
);

CREATE TABLE pokemon_ability (
    pokemon_id INTEGER NOT NULL,
    ability_id INTEGER NOT NULL,
    is_hidden BOOLEAN,
    PRIMARY KEY (pokemon_id, ability_id),
    FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
    FOREIGN KEY (ability_id) REFERENCES ability(id) ON DELETE CASCADE
);

-- ============================================================
-- STATS
-- ============================================================

CREATE TABLE stat (
    id INTEGER PRIMARY KEY,
    code VARCHAR(20) UNIQUE -- 'hp', 'attack', 'defense', 'special-attack', 'special-defense', 'speed'
);

CREATE TABLE stat_translation (
    stat_id INTEGER NOT NULL,
    language_id INTEGER NOT NULL,
    name VARCHAR(50), -- 'HP', 'Attack', 'Defense' / 'PS', 'Ataque', 'Defensa'
    abbreviation VARCHAR(10), -- 'HP', 'ATK', 'DEF' / 'PS', 'AT', 'DEF'
    PRIMARY KEY (stat_id, language_id),
    FOREIGN KEY (stat_id) REFERENCES stat(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES language(id) ON DELETE CASCADE
);

CREATE TABLE pokemon_stat (
    pokemon_id INTEGER NOT NULL,
    stat_id INTEGER NOT NULL,
    base_value INTEGER,
    PRIMARY KEY (pokemon_id, stat_id),
    FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
    FOREIGN KEY (stat_id) REFERENCES stat(id) ON DELETE CASCADE
);

-- ============================================================
-- ITEMS (HOLD ITEMS & EVOLUTION ITEMS)
-- ============================================================

CREATE TABLE item (
    id INTEGER PRIMARY KEY,
    code VARCHAR(50) UNIQUE, -- 'leftovers', 'choice-band', 'fire-stone'
    category VARCHAR(50) -- 'competitive', 'evolution', 'held-item', 'type-boost'
);

CREATE TABLE item_translation (
    item_id INTEGER NOT NULL,
    language_id INTEGER NOT NULL,
    name VARCHAR(100),
    effect_description TEXT,
    PRIMARY KEY (item_id, language_id),
    FOREIGN KEY (item_id) REFERENCES item(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES language(id) ON DELETE CASCADE
);

CREATE TABLE pokemon_item (
    pokemon_id INTEGER NOT NULL,
    item_id INTEGER NOT NULL,
    PRIMARY KEY (pokemon_id, item_id),
    FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES item(id) ON DELETE CASCADE
);

CREATE TABLE item_image (
    item_id INTEGER PRIMARY KEY,
    image_url VARCHAR(500),
    FOREIGN KEY (item_id) REFERENCES item(id) ON DELETE CASCADE
);

-- ============================================================
-- NATURES
-- ============================================================

CREATE TABLE nature (
    id INTEGER PRIMARY KEY,
    code VARCHAR(50) UNIQUE, -- 'adamant', 'modest', 'jolly'
    increased_stat_id INTEGER,
    decreased_stat_id INTEGER,
    FOREIGN KEY (increased_stat_id) REFERENCES stat(id) ON DELETE SET NULL,
    FOREIGN KEY (decreased_stat_id) REFERENCES stat(id) ON DELETE SET NULL
);

CREATE TABLE nature_translation (
  nature_id INTEGER,
  language_id INTEGER,
  name VARCHAR(100),
  PRIMARY KEY (nature_id, language_id),
  FOREIGN KEY (nature_id) REFERENCES nature(id),
  FOREIGN KEY (language_id) REFERENCES language(id)
);

-- ============================================================
-- RECOMMENDED EV SETS
-- ============================================================

CREATE TABLE ev_set (
    id INTEGER PRIMARY KEY,
    pokemon_id INTEGER NOT NULL,
    title VARCHAR(100),
    notes TEXT,
    FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE
);

CREATE TABLE ev_value (
    ev_set_id INTEGER NOT NULL,
    stat_id INTEGER NOT NULL,
    value INTEGER,
    PRIMARY KEY (ev_set_id, stat_id),
    FOREIGN KEY (ev_set_id) REFERENCES ev_set(id) ON DELETE CASCADE,
    FOREIGN KEY (stat_id) REFERENCES stat(id) ON DELETE CASCADE
);

-- ============================================================
-- EVOLUTION CHAINS
-- ============================================================

CREATE TABLE evolution_chain (
    id INTEGER PRIMARY KEY
);

CREATE TABLE pokemon_evolution (
    id INTEGER PRIMARY KEY,
    chain_id INTEGER NOT NULL,
    from_pokemon_id INTEGER NOT NULL,
    to_pokemon_id INTEGER NOT NULL,
    FOREIGN KEY (chain_id) REFERENCES evolution_chain(id) ON DELETE CASCADE,
    FOREIGN KEY (from_pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
    FOREIGN KEY (to_pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE
);

CREATE TABLE pokemon_evolution_translation (
    evolution_id INTEGER NOT NULL,
    language_id INTEGER NOT NULL,
    condition TEXT, -- Descripción de la condición de evolución
    PRIMARY KEY (evolution_id, language_id),
    FOREIGN KEY (evolution_id) REFERENCES pokemon_evolution(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES language(id) ON DELETE CASCADE
);

-- ============================================================
-- MOVES (CORE)
-- ============================================================

CREATE TABLE move (
    id INTEGER PRIMARY KEY,
    type_id INTEGER,
    category VARCHAR(50),
    power INTEGER,
    accuracy INTEGER,
    pp INTEGER,
    priority INTEGER,
    FOREIGN KEY (type_id) REFERENCES type(id) ON DELETE SET NULL
);

CREATE TABLE move_translation (
    move_id INTEGER NOT NULL,
    language_id INTEGER NOT NULL,
    name VARCHAR(100),
    description TEXT,
    PRIMARY KEY (move_id, language_id),
    FOREIGN KEY (move_id) REFERENCES move(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES language(id) ON DELETE CASCADE
);

-- ============================================================
-- MOVE CATEGORIES
-- ============================================================

CREATE TABLE move_category (
    id INTEGER PRIMARY KEY,
    code VARCHAR(20) UNIQUE
);

CREATE TABLE move_category_translation (
    category_id INTEGER NOT NULL,
    language_id INTEGER NOT NULL,
    name VARCHAR(50),
    PRIMARY KEY (category_id, language_id),
    FOREIGN KEY (category_id) REFERENCES move_category(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES language(id) ON DELETE CASCADE
);

CREATE TABLE move_category_image (
    category_id INTEGER PRIMARY KEY,
    image_url VARCHAR(500),
    FOREIGN KEY (category_id) REFERENCES move_category(id) ON DELETE CASCADE
);

-- ============================================================
-- MOVE LEARN METHODS
-- ============================================================

CREATE TABLE move_learn_method (
    id INTEGER PRIMARY KEY,
    code VARCHAR(50) UNIQUE -- 'level-up', 'machine', 'egg', 'tutor', 'special'
);

CREATE TABLE move_learn_method_translation (
    method_id INTEGER NOT NULL,
    language_id INTEGER NOT NULL,
    name VARCHAR(100), -- 'Level Up' / 'Subiendo de nivel', 'Egg Move' / 'Movimiento huevo'
    PRIMARY KEY (method_id, language_id),
    FOREIGN KEY (method_id) REFERENCES move_learn_method(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES language(id) ON DELETE CASCADE
);

-- ============================================================
-- MOVES LEARNED BY LEVEL-UP
-- ============================================================

CREATE TABLE pokemon_move_level (
    pokemon_id INTEGER NOT NULL,
    move_id INTEGER NOT NULL,
    level INTEGER NOT NULL,
    PRIMARY KEY (pokemon_id, move_id, level),
    FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
    FOREIGN KEY (move_id) REFERENCES move(id) ON DELETE CASCADE
);

-- ============================================================
-- MACHINES (TM/TR/HM)
-- ============================================================

CREATE TABLE machine (
    id INTEGER PRIMARY KEY,
    code VARCHAR(20),
    move_id INTEGER,
    FOREIGN KEY (move_id) REFERENCES move(id) ON DELETE CASCADE
);

CREATE TABLE pokemon_machine_move (
    pokemon_id INTEGER NOT NULL,
    machine_id INTEGER NOT NULL,
    PRIMARY KEY (pokemon_id, machine_id),
    FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
    FOREIGN KEY (machine_id) REFERENCES machine(id) ON DELETE CASCADE
);

-- ============================================================
-- EGG MOVES
-- ============================================================

CREATE TABLE pokemon_egg_move (
    pokemon_id INTEGER NOT NULL,
    move_id INTEGER NOT NULL,
    PRIMARY KEY (pokemon_id, move_id),
    FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
    FOREIGN KEY (move_id) REFERENCES move(id) ON DELETE CASCADE
);

-- ============================================================
-- TUTOR MOVES
-- ============================================================

CREATE TABLE pokemon_tutor_move (
    pokemon_id INTEGER NOT NULL,
    move_id INTEGER NOT NULL,
    PRIMARY KEY (pokemon_id, move_id),
    FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
    FOREIGN KEY (move_id) REFERENCES move(id) ON DELETE CASCADE
);

-- ============================================================
-- SPECIAL / EVENT MOVES
-- ============================================================

CREATE TABLE pokemon_special_move (
    id INTEGER PRIMARY KEY,
    pokemon_id INTEGER NOT NULL,
    move_id INTEGER NOT NULL,
    source TEXT,
    FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
    FOREIGN KEY (move_id) REFERENCES move(id) ON DELETE CASCADE
);

-- ============================================================
-- POKEMON IMAGES
-- ============================================================

CREATE TABLE pokemon_image (
    pokemon_id INTEGER PRIMARY KEY,
    normal_image_url TEXT,
    shiny_image_url TEXT,
    FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_pokemon_species ON pokemon(species_id);
CREATE INDEX idx_pokemon_available_region_pokemon ON pokemon_available_in_region(pokemon_id);
CREATE INDEX idx_pokemon_available_region_region ON pokemon_available_in_region(region_id);
CREATE INDEX idx_pokemon_type_pokemon ON pokemon_type(pokemon_id);
CREATE INDEX idx_pokemon_type_type ON pokemon_type(type_id);
CREATE INDEX idx_pokemon_ability_pokemon ON pokemon_ability(pokemon_id);
CREATE INDEX idx_pokemon_stat_pokemon ON pokemon_stat(pokemon_id);
CREATE INDEX idx_pokemon_evolution_from ON pokemon_evolution(from_pokemon_id);
CREATE INDEX idx_pokemon_evolution_to ON pokemon_evolution(to_pokemon_id);
CREATE INDEX idx_pokemon_move_level_pokemon ON pokemon_move_level(pokemon_id);
CREATE INDEX idx_pokemon_move_level_move ON pokemon_move_level(move_id);
