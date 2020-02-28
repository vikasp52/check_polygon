
class HayHubModel {
  List<Geometry> geometry;

  HayHubModel({this.geometry});

  factory HayHubModel.fromJson(Map<String, dynamic> parsedJson) {

    var list = parsedJson['results']['geometry'][0] as List;
    print('list: $list');
    List<Geometry> imagesList = list.map((i) => Geometry.fromJson(i)).toList();

    print('imagesList: $imagesList');
    return HayHubModel(
        geometry: imagesList);
  }
}

class Geometry {
  final double lat;
  final double lon;

  Geometry({this.lat, this.lon});

  factory Geometry.fromJson(Map<String, dynamic> parsedJson){
    return Geometry(
        lat:parsedJson['lat'],
        lon:parsedJson['lon']
    );
  }
}
