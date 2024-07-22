class PlantResponse {
  final String accessToken;
  final Result result;
  PlantResponse({required this.accessToken, required this.result});

  factory PlantResponse.fromJson(Map<String, dynamic> json, isHealthCall) {
    return PlantResponse(
      accessToken: json['access_token'] ?? '',
      result: Result.fromJson(json['result'] ?? {}, isHealthCall),
    );
  }
}

class Result {
  final bool? isPlant;
  final double? plantProbability;
  final bool? isHealthy;
  final double? healthProbability;
  final Classification? classification;
  final Classification? disease;

  Result({
    this.isPlant,
    this.plantProbability,
    this.isHealthy,
    this.healthProbability,
    this.classification,
    this.disease,
  });

  factory Result.fromJson(Map<String, dynamic> json, bool isHealthCall) {
    return Result(
      isPlant: json['is_plant']?['binary'],
      plantProbability: json['is_plant']?['probability'],
      isHealthy: json['is_healthy']?['binary'],
      healthProbability: json['is_healthy']?['probability'],
      classification: json.containsKey('classification')
          ? Classification.fromJson(json['classification'] ?? {}, isHealthCall)
          : null,
      disease: json.containsKey('disease')
          ? Classification.fromJson(json['disease'] ?? {}, isHealthCall)
          : null,
    );
  }
}

class Classification {
  final List<Suggestion> suggestions;

  Classification({required this.suggestions});

  factory Classification.fromJson(
      Map<String, dynamic> json, bool isHealthCall) {
    var list = json['suggestions'] as List?;
    List<Suggestion> suggestionsList =
        list?.map((e) => Suggestion.fromJson(e, isHealthCall)).toList() ?? [];

    return Classification(
      suggestions: suggestionsList,
    );
  }
}

class Suggestion {
  final String id;
  final String name;
  final double probability;
  final List<SimilarImage> similarImages;
  final bool? redundant;
  final Details? details;

  Suggestion({
    required this.id,
    required this.name,
    required this.probability,
    required this.similarImages,
    this.redundant,
    this.details,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json, bool isHealthCall) {
    var list = json['similar_images'] as List?;
    List<SimilarImage> similarImagesList =
        list?.map((e) => SimilarImage.fromJson(e)).toList() ?? [];

    return Suggestion(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      probability: (json['probability'] as num?)?.toDouble() ?? 0.0,
      similarImages: similarImagesList,
      redundant: json['redundant'] ?? false,
      details: json.containsKey('details')
          ? Details.fromJson(json['details'] ?? {}, isHealthCall)
          : null,
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
      id: json['id'] ?? '',
      similarity: (json['similarity'] as num?)?.toDouble() ?? 0.0,
      url: json['url'] ?? '',
      urlSmall: json['url_small'] ?? '',
    );
  }
}

class Details {
  final List<String>? commonNames;
  final Map<String, dynamic>? taxonomy;
  final Map<String, dynamic>? description;
  final String? nameAuthority;
  final String? rank;
  final int? gbifId;
  final int? inaturalistId;
  final Map<String, dynamic>? image;
  final List<Map<String, dynamic>>? images;
  final List<String>? synonyms;
  final List<String>? edibleParts;
  final List<String>? propagationMethods;
  final Map<String, dynamic>? watering;

  final String? localName;
  final Map<String, dynamic>? treatment;
  final List<String>? diseaseClassification;
  final List<String>? diseaseCommonNames;
  final String? cause;

  //common for both
  final String url;
  final String? diseaseDescription;

  Details({
    this.commonNames,
    this.taxonomy,
    this.description,
    this.nameAuthority,
    this.rank,
    this.gbifId,
    this.inaturalistId,
    this.image,
    this.images,
    this.synonyms,
    this.edibleParts,
    this.propagationMethods,
    this.watering,
    this.localName,
    this.treatment,
    this.diseaseClassification,
    this.diseaseCommonNames,
    this.cause,

    //common for both
    required this.url,
    this.diseaseDescription,
  });

  factory Details.fromJson(Map<String, dynamic> json, bool isHealthCall) {
    return Details(
        // Plant details
        commonNames:
            (json['common_names'] as List?)?.map((e) => e as String).toList(),
        taxonomy: json['taxonomy'] as Map<String, dynamic>?,
        nameAuthority: json['name_authority'] as String?,
        rank: json['rank'] as String?,
        gbifId: json['gbif_id'] as int?,
        inaturalistId: json['inaturalist_id'] as int?,
        image: json['image'] as Map<String, dynamic>?,
        images: (json['images'] as List?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList(),
        synonyms: (json['synonyms'] as List?)?.map((e) => e as String).toList(),
        edibleParts:
            (json['edible_parts'] as List?)?.map((e) => e as String).toList(),
        propagationMethods: (json['propagation_methods'] as List?)
            ?.map((e) => e as String)
            .toList(),
        watering: json['watering'] as Map<String, dynamic>?,

        // Disease details
        localName: json['local_name'] as String?,
        treatment: json['treatment'] as Map<String, dynamic>?,
        diseaseClassification:
            (json['classification'] as List?)?.map((e) => e as String).toList(),
        diseaseCommonNames:
            (json['common_names'] as List?)?.map((e) => e as String).toList(),
        cause: json['cause'] as String?,

        // Common for both
        url: json['url'] as String,
        diseaseDescription:
            isHealthCall ? json['description'] as String? : null,
        description:
            isHealthCall ? null : json['description'] as Map<String, dynamic>?);
  }
}
