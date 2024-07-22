import 'dart:io';
import 'package:dr_plant/conversation_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:dr_plant/api_service.dart';
import 'package:dr_plant/details_result_screen.dart';
import 'package:dr_plant/diagnose_result_screen.dart';
import 'package:dr_plant/plant_response.dart';
import 'package:dr_plant/string_utils.dart';

class IdentificationResultScreen extends StatefulWidget {
  final String uploadedPlantImage;
  final PlantResponse plantResponse;
  final Position? position;

  const IdentificationResultScreen({
    Key? key,
    required this.uploadedPlantImage,
    this.position,
    required this.plantResponse,
  }) : super(key: key);

  @override
  _IdentificationResultScreenState createState() =>
      _IdentificationResultScreenState();
}

class _IdentificationResultScreenState
    extends State<IdentificationResultScreen> {
  int _selectedIndex = -1;
  List<Map<String, dynamic>> imagesWithNames = [];

  Offset _position = Offset.zero;

  @override
  void initState() {
    super.initState();
    _populateImagesWithNames();
    _getPosition();
  }

  void _getPosition() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Size size = MediaQuery.of(context).size;
      setState(() {
        _position = Offset(size.width - 45, size.height - 100);
      });
    });
  }

  void _populateImagesWithNames() {
    if (widget.plantResponse.result.classification?.suggestions != null) {
      for (var suggestion
          in widget.plantResponse.result.classification!.suggestions) {
        for (var similarImage in suggestion.similarImages) {
          imagesWithNames.add({
            'name': suggestion.name,
            'url': similarImage.url,
            'thumbsUp': false,
            'thumbsDown': false,
            'details': suggestion.details,
            'description': suggestion.details?.description?['value'],
          });
        }
      }
    }
  }

  void _handleThumbsUp(int index) {
    setState(() {
      imagesWithNames[index]['thumbsUp'] = true;
    });
  }

  void _handleThumbsDown(int index) {
    setState(() {
      if (_selectedIndex == index) {
        _selectedIndex = (_selectedIndex == imagesWithNames.length - 1)
            ? 0
            : _selectedIndex + 1;
      } else if (_selectedIndex > index) {
        _selectedIndex--;
      }
    });
  }

  Future<void> _diagnosePlantUsingAPI(int index) async {
    try {
      var plantResponse =
          await diagnosePlant(widget.uploadedPlantImage, widget.position);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiagnoseResultScreen(
            uploadedPlantImage: widget.uploadedPlantImage,
            plantResponse: plantResponse,
          ),
        ),
      );
    } catch (e) {
      print('Failed to diagnose plant: $e');
    }
  }

  Future<void> _getPlantDetails(int index) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsResultScreen(
            plantImage: widget.uploadedPlantImage,
            name: imagesWithNames[index]['name'],
            description: imagesWithNames[index]['description'],
            url: imagesWithNames[index]['url'],
            plantDetails: imagesWithNames[index]['details'] ?? {},
            accessToken: widget.plantResponse.accessToken,
            isSearchCall: false,
            isDiseaseDetailsCall: false,
          ),
        ),
      );
    } catch (e) {
      print('Failed to identify plant: $e');
    }
  }

  void _handleTap(int index) {
    setState(() {
      if (_selectedIndex == index) {
        _selectedIndex = -1;
      } else {
        _selectedIndex = index;
      }
      imagesWithNames[index]['thumbsUp'] = false;
      imagesWithNames[index]['thumbsDown'] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _selectedIndex != -1
          ? Stack(
              children: [
                Positioned(
                  left: _position.dx,
                  top: _position.dy,
                  child: Draggable(
                    feedback: _buildFloatingActionButton(),
                    childWhenDragging: Container(),
                    onDragEnd: (details) {
                      // Handle end of drag if needed
                    },
                    onDragUpdate: (details) {
                      setState(() {
                        _position += details.delta;
                      });
                    },
                    child: _buildFloatingActionButton(),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildFloatingActionButton() {
    return SizedBox(
      width: 45,
      height: 45,
      child: FittedBox(
        child: FloatingActionButton(
          onPressed: () {
            if (_selectedIndex >= 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationScreen(
                    accessToken: widget.plantResponse.accessToken,
                    plantName: imagesWithNames[_selectedIndex]['name'],
                    isDiseaseCall: false,
                  ),
                ),
              );
            }
          },
          backgroundColor: Colors.black,
          child: SizedBox(
            width: 22,
            height: 24,
            child: Image.asset(
              'assets/images/chatbot.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
      scrolledUnderElevation: 0,
      title: Image.asset('assets/images/Dr.Plant_Title.png', height: 30),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildImage(),
              if (widget.plantResponse.result.isPlant!) ...[
                const Text(
                  'Does your plant look like',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildImageList(),
                _buildActionButtons(),
                const SizedBox(height: 50),
              ] else ...[
                _buildNoPlantMessage(),
                const SizedBox(height: 400),
              ]
            ]),
      ),
    );
  }

  Widget _buildNoPlantMessage() {
    return const Center(
      child: Text(
        "Uploaded picture doesn't seem to be a plant.\nPlease try again with a plant photo.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(widget.uploadedPlantImage),
          height: 180,
          width: 180,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildImageList() {
    return Container(
      height: 286,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imagesWithNames.length,
        itemBuilder: (context, index) {
          var item = imagesWithNames[index];
          return InkWell(
            onTap: () => _handleTap(index),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: _selectedIndex == index ? 190 : 180,
                    width: _selectedIndex == index ? 190 : 180,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item['url']!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_selectedIndex == index &&
                      !item['thumbsUp'] &&
                      !item['thumbsDown']) ...[
                    _buildThumbsButtons(index),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbsButtons(int index) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => _handleThumbsUp(index),
              icon: const Icon(Icons.thumb_up_alt_rounded),
              color: Colors.black,
              iconSize: 20,
            ),
            IconButton(
              onPressed: () => _handleThumbsDown(index),
              icon: const Icon(Icons.thumb_down_alt_rounded),
              color: Colors.black,
              iconSize: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_selectedIndex >= 0 && imagesWithNames[_selectedIndex]['thumbsUp']) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            StringUtils.getFirstSentence(
                imagesWithNames[_selectedIndex]['description'] ?? ""),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _diagnosePlantUsingAPI(_selectedIndex),
                icon: SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(
                    'assets/images/crop-health.png',
                    fit: BoxFit.contain,
                  ),
                ),
                label: const Text(
                  'Diagnose',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () => _getPlantDetails(_selectedIndex),
                icon: const Icon(Icons.info, color: Colors.white, size: 20),
                label: const Text(
                  'Details',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return const SizedBox(height: 250);
    }
  }
}
