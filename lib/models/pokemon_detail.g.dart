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
      name: fields[1] as String,
      imageUrl: fields[2] as String,
      shinyImageUrl: fields[3] as String,
      types: (fields[4] as List).cast<String>(),
      height: fields[5] as double,
      weight: fields[6] as double,
      abilities: (fields[7] as List).cast<String>(),
      stats: (fields[8] as Map).cast<String, int>(),
      description: fields[9] as String,
      evolutionChain: (fields[10] as List).cast<String>(),
      evolutionImages: (fields[11] as Map).cast<String, String>(),
      abilityDescriptions: (fields[12] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PokemonDetail obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.shinyImageUrl)
      ..writeByte(4)
      ..write(obj.types)
      ..writeByte(5)
      ..write(obj.height)
      ..writeByte(6)
      ..write(obj.weight)
      ..writeByte(7)
      ..write(obj.abilities)
      ..writeByte(8)
      ..write(obj.stats)
      ..writeByte(9)
      ..write(obj.description)
      ..writeByte(10)
      ..write(obj.evolutionChain)
      ..writeByte(11)
      ..write(obj.evolutionImages)
      ..writeByte(12)
      ..write(obj.abilityDescriptions);
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
