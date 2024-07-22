import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dr_plant/conversation_screen.dart';
import 'package:dr_plant/string_utils.dart';
import 'package:dr_plant/plant_response.dart';

class DetailsResultScreen extends StatefulWidget {
  final String plantImage;
  final Details plantDetails;
  final String name;
  final String description;
  final String url;
  final bool isSearchCall;
  final bool isDiseaseDetailsCall;
  final String accessToken;

  const DetailsResultScreen({
    Key? key,
    required this.plantImage,
    required this.plantDetails,
    required this.name,
    required this.description,
    required this.url,
    required this.isSearchCall,
    required this.isDiseaseDetailsCall,
    required this.accessToken,
  }) : super(key: key);

  @override
  _DetailsResultScreenState createState() => _DetailsResultScreenState();
}

class _DetailsResultScreenState extends State<DetailsResultScreen> {
  final List<DetailItem> detailItems = [];
  int expandedIndex = -1;
  Offset _position = Offset.zero;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.isDiseaseDetailsCall) {
      _populateDiseaseDetailItems();
    } else {
      _populateDetailItems();
    }
    _getPosition();
  }

  void _getPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Size size = MediaQuery.of(context).size;
      setState(() {
        _position = Offset(size.width - 45, size.height - 100);
      });
    });
  }

  void _populateDetailItems() {
    _addDetailItem('Common Names', widget.plantDetails.commonNames?.join(', '),
        'assets/images/plant-list.png');
    _addDetailItem(
      'Taxonomy',
      _formatTaxonomy(widget.plantDetails.taxonomy),
      'assets/images/taxonomy.png',
    );
    _addDetailItem('Synonyms', widget.plantDetails.synonyms?.join(', '),
        'assets/images/aliases.png');
    _addDetailItem('Edible Parts', widget.plantDetails.edibleParts?.join(', '),
        'assets/images/edible.png');
    _addDetailItem(
        'Propagation Methods',
        widget.plantDetails.propagationMethods?.join(', '),
        'assets/images/propagation.png');
    _addDetailItem(
        'Watering',
        widget.plantDetails.watering?.entries.map((e) {
          return '${e.key}: ${wateringInfo[e.value.toString()]}';
        }).join(', '),
        'assets/images/watering-plants.png');
  }

  Map<String, String> wateringInfo = {
    '1': 'Dry',
    '2': 'Medium',
    '3': 'Wet',
  };

  String _formatTaxonomy(Map<String, dynamic>? taxonomy) {
    if (taxonomy != null && taxonomy.isNotEmpty) {
      return taxonomy.entries
          .map((e) => '${e.key.toUpperCase()}: ${e.value}')
          .join('\n');
    } else {
      return '';
    }
  }

  void _populateDiseaseDetailItems() {
    detailItems.clear();
    _addDetailItem(
      'Common Names',
      widget.plantDetails.commonNames,
      'assets/images/plant-list.png',
    );
    _addDetailItem(
      'Cause',
      widget.plantDetails.cause,
      'assets/images/leaf-insect.png',
    );
    _addDetailItem(
      'Biological Treatment',
      widget.plantDetails.treatment?['biological'],
      'assets/images/bio-care.png',
    );
    _addDetailItem(
      'Chemical Treatment',
      widget.plantDetails.treatment?['chemical'],
      'assets/images/chem-care.png',
    );
    _addDetailItem(
      'Prevention',
      widget.plantDetails.treatment?['prevention'],
      'assets/images/prevention.png',
    );
  }

  void _addDetailItem(String title, dynamic value, String iconPath) {
    if (value != null) {
      if (value is List && value.isNotEmpty) {
        detailItems.add(DetailItem(
          title: title,
          value: value.join('\n'),
          iconPath: iconPath,
        ));
      } else if (value is String && value.isNotEmpty && value != 'N/A') {
        detailItems.add(DetailItem(
          title: title,
          value: value,
          iconPath: iconPath,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: Stack(
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
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      title: Image.asset('assets/images/Dr.Plant_Title.png', height: 30),
      centerTitle: true,
    );
  }

  Widget _buildFloatingActionButton() {
    return SizedBox(
      width: 45,
      height: 45,
      child: FittedBox(
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConversationScreen(
                  accessToken: widget.accessToken,
                  plantName: widget.name,
                  isDiseaseCall: widget.isDiseaseDetailsCall,
                ),
              ),
            );
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

  Widget _buildBody() {
    return NotificationListener<ScrollNotification>(
      child: Scrollbar(
        trackVisibility: true,
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            color: Colors.white,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildImage(),
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                widget.isDiseaseDetailsCall
                    ? _buildDiseaseDetailButtons()
                    : _buildDetailButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailButtons() {
    List<Widget> widgets = [];
    for (int i = 0; i < detailItems.length; i++) {
      widgets.add(
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              if (expandedIndex == i) {
                expandedIndex = -1;
              } else {
                expandedIndex = i;
              }
            });
          },
          icon: Image.asset(
            detailItems[i].iconPath,
            width: 20,
            height: 20,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          label: Text(detailItems[i].title),
        ),
      );

      if (expandedIndex == i) {
        widgets.add(
          Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: _buildDetailValue(detailItems[i])),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12.0,
          runSpacing: 10.0,
          children: List.generate(
            widgets.length,
            (index) {
              return widgets[index];
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailValue(DetailItem detailItem) {
    if (detailItem.title == 'Taxonomy') {
      return StringUtils.buildTaxonomyRichText(detailItem.value!);
    } else if (detailItem.title == 'Watering') {
      return StringUtils.buildWateringRichText(detailItem.value!);
    } else {
      return Text(
        detailItem.value!,
        style: const TextStyle(
          fontSize: 14,
        ),
      );
    }
  }

  Widget _buildDiseaseDetailButtons() {
    List<Widget> widgets = [];
    for (int i = 0; i < detailItems.length; i++) {
      widgets.add(
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              if (expandedIndex == i) {
                expandedIndex = -1;
              } else {
                expandedIndex = i;
              }
            });
          },
          icon: Image.asset(
            detailItems[i].iconPath,
            width: 20,
            height: 20,
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
          label: Text(detailItems[i].title),
        ),
      );

      if (expandedIndex == i) {
        widgets.add(
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: Text(
              detailItems[i].value!,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16.0,
          runSpacing: 16.0,
          children: List.generate(
            widgets.length,
            (index) {
              return widgets[index];
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: widget.isSearchCall || widget.isDiseaseDetailsCall
            ? Image.network(
                widget.plantImage,
                height: 230,
                width: 230,
                fit: BoxFit.cover,
              )
            : Image.file(
                File(widget.plantImage),
                height: 230,
                width: 230,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

class DetailItem {
  String title;
  String? value;
  String iconPath;
  bool isExpanded;

  DetailItem({
    required this.title,
    this.value,
    required this.iconPath,
    this.isExpanded = false,
  });
}
