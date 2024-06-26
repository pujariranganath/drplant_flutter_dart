import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'plant_response.dart';

Future<PlantResponse> identifyImage(String imagePath) async {
  const apiKey = 'vv5xvG5VqtMlSqBRRV7F0lSIfXYOwu54l5Zl2Hno4nDY2NVus5';
  const apiUrl = 'https://plant.id/api/v3/identification';

  try {
    List<int> imageBytes = await File(imagePath).readAsBytes();

    String base64Image = base64Encode(imageBytes);

    Map<String, dynamic> json = {
      "images": ["data:image/jpg;base64,$base64Image"],
      "latitude": 49.207,
      "longitude": 16.608,
      "similar_images": true
    };

    String requestBody = jsonEncode(json);

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        HttpHeaders.authorizationHeader: 'Api-Key $apiKey',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      return PlantResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to identify image');
    }
  } catch (e) {
    throw Exception('Failed to identify image: $e');
  }
}
