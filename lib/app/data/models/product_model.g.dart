// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 1;

  @override
  ProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return ProductModel(
      id: fields[0] as String,
      image: fields[1] as String,
      name: fields[2] as String,
      ctgry: fields[3] as String,
      pksz: fields[4] as String,
      description: fields[5] as String,
      quantity: fields[6] as int,
      price: fields[7] as double,
      brand: fields[8] as String,
      subctgry: fields[9] as String,
      effectivePrice: fields[10] as double,
      bulkPrices: (fields[11] as List?)?.cast<BulkPrice>() ?? [],
      mrp: fields[12] as double, // Deserialize MRP
      gst: fields[13] as double, // Deserialize GST
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(14) // Update the number of fields to 14
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.image)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.ctgry)
      ..writeByte(4)
      ..write(obj.pksz)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.quantity)
      ..writeByte(7)
      ..write(obj.price)
      ..writeByte(8)
      ..write(obj.brand)
      ..writeByte(9)
      ..write(obj.subctgry)
      ..writeByte(10)
      ..write(obj.effectivePrice)
      ..writeByte(11)
      ..write(obj.bulkPrices)
      ..writeByte(12)
      ..write(obj.mrp) // Serialize MRP
      ..writeByte(13)
      ..write(obj.gst); // Serialize GST
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
