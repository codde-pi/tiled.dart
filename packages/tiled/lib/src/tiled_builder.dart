part of tiled;

class TiledBuildingException implements Exception {
  final String name;
  final String? valueFound;
  final String reason;
  TiledBuildingException(this.name, this.valueFound, this.reason);
}

class XmlTiledBuilder extends TiledBuilder {
  XmlBuilder builder;
  XmlTiledBuilder({XmlBuilder? builder})
      : this.builder = builder ?? XmlBuilder();
  void buildValue(String name, dynamic value) {
    builder.attribute(name, value);
  }

  void buildData(TileLayer layer) {
    builder.element(
      'data',
      nest: () {
        //TODO: compression
        if (layer.tileData != null) {
          builder
            ..text(
              layer.tileData!
                  .map((e) => e.map((el) => el.tile).join(','))
                  .join(),
            )
            ..attribute('encoding', 'csv');
        } else if (layer.data != null)
          builder
            ..text(layer.data!.join())
            ..attribute('encoding', 'base64'); // TODO: need to serialize ?
      },
    );
  }

  // TODO: move to `property` file ?
  void buildProperties(CustomProperties properties) {
    if (properties.isNotEmpty) {
      builder.element(
        'properties',
        nest: () {
          properties.map((prop) {
            builder.element(
              'property',
              nest: () => builder
                ..attribute('name', prop.name)
                ..attribute('value', prop.value.toString())
                ..attribute('type', prop.type.name),
            );
          });
        },
      );
    }
  }

  void _build(Layer layer) {
    getBaseAttrs(layer).forEach((value) {
      builder.attribute(value.$1, value.$2);
    });
    buildProperties(layer.properties);
  }

  @override
  void buildObjectGroup(ObjectGroup layer) {
    builder.element(
      'objectgroup',
      nest: () {
        _build(layer);
        // TODO: layer.objects
      },
    );
  }

  @override
  void buildTileLayer(TileLayer layer) {
    builder.element(
      'layer',
      nest: () {
        _build(layer);
        [('width', layer.width), ('height', layer.height)].forEach((element) {
          buildValue(element.$1, element.$2);
          buildData(layer);
          // TODO: chunks
        });
      },
    );
  }

  @override
  XmlDocument build() {
    return builder.buildDocument();
  }
}

abstract class TiledBuilder {
  void buildObjectGroup(ObjectGroup layer);
  void buildTileLayer(TileLayer layer);
  void build();
}
