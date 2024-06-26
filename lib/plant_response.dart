class PlantResponse {
  final Result result;

  PlantResponse({required this.result});

  factory PlantResponse.fromJson(Map<String, dynamic> json) {
    return PlantResponse(
      result: Result.fromJson(json['result']),
    );
  }
}

class Result {
  final Classification classification;

  Result({required this.classification});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      classification: Classification.fromJson(json['classification']),
    );
  }
}

class Classification {
  final List<Suggestion> suggestions;

  Classification({required this.suggestions});

  factory Classification.fromJson(Map<String, dynamic> json) {
    var list = json['suggestions'] as List;
    List<Suggestion> suggestionsList =
        list.map((e) => Suggestion.fromJson(e)).toList();

    return Classification(
      suggestions: suggestionsList,
    );
  }
}

class Suggestion {
  final String name;
  final double probability;
  final List<SimilarImage> similarImages;

  Suggestion({
    required this.name,
    required this.probability,
    required this.similarImages,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    var list = json['similarImages'] as List;
    List<SimilarImage> similarImagesList =
        list.map((e) => SimilarImage.fromJson(e)).toList();

    return Suggestion(
      name: json['name'],
      probability: json['probability'],
      similarImages: similarImagesList,
    );
  }
}

class SimilarImage {
  final String id;
  final double similarity;
  final String url;
  final String urlSmall;

  SimilarImage({
    required this.id,
    required this.similarity,
    required this.url,
    required this.urlSmall,
  });

  factory SimilarImage.fromJson(Map<String, dynamic> json) {
    return SimilarImage(
      id: json['id'],
      similarity: json['similarity'],
      url: json['url'],
      urlSmall: json['url_small'],
    );
  }
}
