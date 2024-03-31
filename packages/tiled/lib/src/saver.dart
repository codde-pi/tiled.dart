part of tiled;

class BuildingException implements Exception {
  final String name;
  final String? valueFound;
  final String reason;
  BuildingException(this.name, this.valueFound, this.reason);
}

class XmlSaver extends Saver {
  final XmlBuilder builder;
  XmlSaver({XmlBuilder? builder}) : this.builder = builder ?? XmlBuilder();

  @override
  XmlElement exportObjectGroup(ObjectGroup layer) {
    final base = _export(layer);
    return XmlElement(XmlName('objectgroup'), base.$1,
        [base.$2]); // TODO: [base.$2, ...layer.objects.export()]);
  }

  XmlElement exportTileLayer(TileLayer layer) {
    final base = _export(layer);
    final attrs = [('width', layer.width), ('height', layer.height)];
    base.$1.addAll(attrs.map((value) => setValue(value.$1, value.$2)));
    // TODO: chunks
    return XmlElement(XmlName('layer'), base.$1,
        [base.$2, if (setData(layer) != null) setData(layer)!]);
  }

  (List<XmlAttribute>, XmlElement) _export(Layer layer) {
    return (
      getBaseAttrs(layer).map((value) => setValue(value.$1, value.$2)).toList(),
      setProperties(layer.properties)
    );
  }

  XmlAttribute setValue(String name, dynamic value) {
    return XmlAttribute(XmlName(name), value.toString());
  }

  XmlElement? setData(TileLayer layer) {
    final dataName = XmlName('data');
    encoding(String value) => XmlAttribute(XmlName('encoding'), value);
    //TODO: compression
    XmlElement? data;
    if (layer.tileData != null) {
      data = XmlElement(dataName, [encoding('csv')]);
      data.innerText =
          layer.tileData!.map((e) => e.map((el) => el.tile).join(",")).join("");
    } else if (layer.data != null) {
      data = XmlElement(dataName, [encoding('base64')]);
      data.innerText = layer.data!.join(""); // TODO: serialize ?
    }
    return data;
  }
}

abstract class Saver {
  XmlElement exportObjectGroup(ObjectGroup layer);
  XmlElement exportTileLayer(TileLayer layer);
}

List<(String, dynamic)> getBaseAttrs(Layer layer) => [
      if (layer.id != null) ('id', layer.id!),
      ('name', layer.name),
      if (layer.class_ != null) ('class', layer.class_!),
      ('x', layer.x),
      ('y', layer.y),
      ('offsetx', layer.offsetX),
      ('offsety', layer.offsetY),
      ('parallaxx', layer.parallaxX),
      ('parallaxy', layer.parallaxY),
      if (layer.startX != null) ('startx', layer.startX),
      if (layer.startY != null) ('starty', layer.startY),
      if (layer.tintColorHex != null) ('tintcolor', layer.tintColorHex),
      ('opacity', layer.opacity),
      ('visible', layer.visible),
    ];
