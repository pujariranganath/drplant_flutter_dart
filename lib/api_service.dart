import 'dart:convert';
import 'dart:io';
import 'package:dr_plant/chatbot_response.dart';
import 'package:dr_plant/custom_response.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'plant_response.dart';
import 'package:flutter/services.dart';

Future<CustomResponse> loadJsonFromAsset(String filePath) async {
  String jsonString = await rootBundle.loadString(filePath);
  Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
  return CustomResponse.fromJson(jsonResponse);
}

const apiKey = 'bV3kX21qoaKLx0qWhWFqha3aMmtD6T7sXbB7D78yQ7v92XydEG';

Future<PlantResponse> identifyPlant(
    String imagePath, Position? position) async {
  const idApiUrl = 'https://plant.id/api/v3/identification';
  List<String> details = [
    'common_names',
    'url',
    'description',
    'taxonomy',
    'name_authority',
    'rank',
    'gbif_id',
    'inaturalist_id',
    'image',
    'images',
    'synonyms',
    'edible_parts',
    'propagation_methods',
    'watering'
  ];
  String detailsParam = details.join(',');

  try {
    List<int> imageBytes = await File(imagePath).readAsBytes();

    String base64Image = base64Encode(imageBytes);

    Map<String, dynamic> json = {
      "images": ["data:image/jpg;base64,$base64Image"],
      "latitude": position?.latitude,
      "longitude": position?.longitude,
      "similar_images": true,
    };

    String requestBody = jsonEncode(json);

    var response = await http.post(
      Uri.parse(idApiUrl).replace(queryParameters: {'details': detailsParam}),
      headers: {
        'Api-Key': apiKey,
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: requestBody,
    );

    /*
    CustomResponse response = await loadJsonFromAsset(
        'assets/responses/api_identification_result.json');*/

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PlantResponse.fromJson(jsonDecode(response.body), false);
    } else {
      throw Exception('Failed to identify plant');
    }
  } catch (e) {
    throw Exception('Failed to identify plant: $e');
  }
}

Future<PlantResponse> diagnosePlant(
    String imagePath, Position? position) async {
  const diagnoseApiUrl =
      'https://plant.id/api/v3/health_assessment?details=local_name,description,url,treatment,classification,common_names,cause';
  List<String> details = [
    'local_name',
    'common_names',
    'url',
    'description',
    'treatment',
    'classification',
    'cause',
  ];
  String detailsParam = details.join(',');

  try {
    List<int> imageBytes = await File(imagePath).readAsBytes();

    String base64Image = base64Encode(imageBytes);

    Map<String, dynamic> json = {
      "images": ["data:image/jpg;base64,$base64Image"],
      "latitude": position?.latitude,
      "longitude": position?.longitude,
      "similar_images": true
    };

    String requestBody = jsonEncode(json);

    var response = await http.post(
      Uri.parse(diagnoseApiUrl)
          .replace(queryParameters: {'details': detailsParam}),
      headers: {
        'Api-Key': apiKey,
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: requestBody,
    );

    /*
    CustomResponse response = await loadJsonFromAsset(
        'assets/responses/api_health_diagnosis_result.json');*/

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PlantResponse.fromJson(jsonDecode(response.body), true);
    } else {
      throw Exception('Failed to fetch diagnose plant');
    }
  } catch (e) {
    throw Exception('Failed to diagnose plant: $e');
  }
}

Future<ChatbotResponse> getChatbotResponse(
    String question, String accessToken) async {
  String chatbotApiUrl =
      'https://plant.id/api/v3/identification/$accessToken/conversation';

  try {
    Map<String, dynamic> json = {"question": question, "temperature": 0.7};

    String requestBody = jsonEncode(json);
    var response = await http.post(
      Uri.parse(chatbotApiUrl),
      headers: {
        'Api-Key': apiKey,
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ChatbotResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get chatbot response');
    }

    /*
    CustomResponse response =
        await loadJsonFromAsset('assets/responses/api_chatbot_result.json');
    return ChatbotResponse.fromJson(jsonDecode(response.body));
    */
  } catch (e) {
    throw Exception('Failed to get chatbot response: $e');
  }
}

Future<List<String>> getNewPrompts(
    String plantName, String context, String botResponse) async {
  const gptApiKey = 'sk-proj-ov0lUWs9dTc0hDEQaLMlT3BlbkFJ3PK1KjSrPE3g0wjXO9Um';
  const gptApiUrl = 'https://api.openai.com/v1/chat/completions';

  final response = await http.post(
    Uri.parse(gptApiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $gptApiKey',
    },
    body: jsonEncode({
      'model': 'gpt-4o',
      'messages': [
        {
          'role': 'user',
          'content': generatePrompt(plantName, context, botResponse),
        }
      ],
      'temperature': 0.7,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return parseNewPrompts(data);
  } else {
    throw Exception('Failed to load new prompts');
  }
}

String generatePrompt(String plantName, String context, String botResponse) {
  return "Based on the following information responses: $plantName, $context and $botResponse, \nGenerate 3 One Line replies user can select from.";
}

List<String> parseNewPrompts(Map<String, dynamic> responseData) {
  List<String> prompts = [];

  List<dynamic> choices = responseData['choices'];

  for (var choice in choices) {
    String content = choice['message']['content'];

    List<String> lines =
        content.split('\n').where((line) => line.isNotEmpty).toList();

    prompts.addAll(lines);
  }

  return prompts;
}

Future<List<Map<String, String>>> searchPlantsByName(String query) async {
  const searchApiUrl = 'https://plant.id/api/v3/kb/plants/name_search';
  try {
    final response = await http.get(
      Uri.parse(searchApiUrl).replace(queryParameters: {'q': query}),
      headers: {
        'Api-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return parseSearchResults(data);
    } else {
      throw Exception('Failed to search for plants');
    }
  } catch (e) {
    throw Exception('Failed to search for plants: $e');
  }
}

List<Map<String, String>> parseSearchResults(
    Map<String, dynamic> responseData) {
  List<Map<String, String>> results = [];
  if (responseData.containsKey('entities')) {
    for (var entity in responseData['entities']) {
      results.add({
        'entity_name': entity['entity_name'] as String,
        'access_token': entity['access_token'] as String,
      });
    }
  }
  return results;
}

Future<Details> getPlantDetailsUsingAPI(String accessToken) async {
  String idApiUrl = 'https://plant.id/api/v3/kb/plants/$accessToken';
  List<String> details = [
    'common_names',
    'url',
    'description',
    'taxonomy',
    'name_authority',
    'rank',
    'gbif_id',
    'inaturalist_id',
    'image',
    'images',
    'synonyms',
    'edible_parts',
    'propagation_methods',
    'watering'
  ];
  String detailsParam = details.join(',');

  try {
    var response = await http.get(
      Uri.parse(idApiUrl).replace(queryParameters: {'details': detailsParam}),
      headers: {
        'Api-Key': apiKey,
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    /*
    CustomResponse response = await loadJsonFromAsset(
        'assets/responses/api_identification_result.json');*/

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Details.fromJson(jsonDecode(response.body), false);
    } else {
      throw Exception('Failed to identify plant');
    }
  } catch (e) {
    throw Exception('Failed to identify plant: $e');
  }
}
