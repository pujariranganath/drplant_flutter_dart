import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dr_plant/plant_response.dart';

class IdentificationResultScreen extends StatelessWidget {
  final String imagePath;
  final PlantResponse plantResponse;

  const IdentificationResultScreen({
    Key? key,
    required this.imagePath,
    required this.plantResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Identification Results'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20),
            child: Image.file(
              File(imagePath),
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: plantResponse.result.classification.suggestions.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                var suggestion =
                    plantResponse.result.classification.suggestions[index];
                
                var imageUrl = suggestion.similarImages.isNotEmpty
                    ? suggestion.similarImages[0].url
                    : '';

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Image.network(
                        imageUrl,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 8),
                      Text(
                        suggestion.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                          'Probability: ${suggestion.probability.toStringAsFixed(2)}'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
