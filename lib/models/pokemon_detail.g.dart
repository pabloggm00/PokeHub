// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon_detail.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PokemonDetailAdapter extends TypeAdapter<PokemonDetail> {
  @override
  final int typeId = 1;

  @override
  PokemonDetail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PokemonDetail(
      id: fields[0] as int,
      speciesName: fields[1] as String,
      formName: fields[2] as String,
      imageUrl: fields[3] as String,
      shinyImageUrl: fields[4] as String,
      types: (fields[5] as List).cast<String>(),
      height: fields[6] as double,
      weight: fields[7] as double,
      abilities: (fields[8] as List).cast<String>(),
      stats: (fields[9] as Map).cast<String, int>(),
      description: fields[10] as String,
      evolutionChain: (fields[11] as List).cast<String>(),
      evolutionImages: (fields[12] as Map).cast<String, String>(),
      abilityDescriptions: (fields[13] as Map).cast<String, String>(),
      varieties: (fields[14] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PokemonDetail obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.speciesName)
      ..writeByte(2)
      ..write(obj.formName)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.shinyImageUrl)
      ..writeByte(5)
      ..write(obj.types)
      ..writeByte(6)
      ..write(obj.height)
      ..writeByte(7)
      ..write(obj.weight)
      ..writeByte(8)
      ..write(obj.abilities)
      ..writeByte(9)
      ..write(obj.stats)
      ..writeByte(10)
      ..write(obj.description)
      ..writeByte(11)
      ..write(obj.evolutionChain)
      ..writeByte(12)
      ..write(obj.evolutionImages)
      ..writeByte(13)
      ..write(obj.abilityDescriptions)
      ..writeByte(14)
      ..write(obj.varieties);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokemonDetailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
