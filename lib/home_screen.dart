import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'camera_screen.dart';
import 'api_service.dart';
import 'identification_result_screen.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  bool _isLocationEnabled = false;
  Position? _currentPosition;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  bool _showText = false;
  String infoText = 'Improves accuracy of ID/Diagnosis';

  @override
  void initState() {
    super.initState();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showInfoText() {
    setState(() {
      if (!_showText) {
        _showText = true;
      } else {
        _showText = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          body: Stack(
            children: <Widget>[
              _buildMainContent(),
              _buildLocationToggle(),
              Positioned(
                top: 60.0,
                right: 30.0,
                child: Visibility(
                  visible: _showText,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      infoText,
                      style: const TextStyle(fontSize: 12.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton:
              _image != null ? _buildFloatingActionButton() : null,
        ),
        if (_isLoading) _buildLoadingIndicator(),
      ],
    );
  }

  Widget _buildMainContent() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 100),
          _buildImageContainer(),
          const SizedBox(height: 50),
          _buildButtonRow(),
        ],
      ),
    );
  }

  Widget _buildImageContainer() {
    return InkWell(
      onTap: _takePicture,
      child: SizedBox(
        width: 300,
        height: 300,
        child: _image == null
            ? Image.asset(
                'assets/images/bg-canvas.png',
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _image!,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  Widget _buildButtonRow() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16.0,
      runSpacing: 16.0,
      children: <Widget>[
        _buildUploadButton(),
        const SizedBox(width: 5),
        _buildTakePictureButton(),
        _buildTutorialButton(),
        const SizedBox(width: 5),
        _buildClearButton(),
      ],
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: 120,
      height: 45,
      child: ElevatedButton.icon(
        onPressed: _pickImage,
        icon: const Icon(Icons.cloud_upload),
        label: const Text('Upload'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _buildTakePictureButton() {
    return SizedBox(
      width: 120,
      height: 45,
      child: ElevatedButton.icon(
        onPressed: _takePicture,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Take Picture'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialButton() {
    return SizedBox(
      width: 120,
      height: 45,
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => _buildTutorialDialog(),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        label: const Text('Tutorial'),
        icon: SizedBox(
          width: 20,
          height: 20,
          child: Image.asset(
            'assets/images/tutorial.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialDialog() {
    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('How to Use Dr. Plant'),
            const SizedBox(height: 16.0),
            AspectRatio(
              aspectRatio: 20 / 40,
              child: Image.asset(
                'assets/videos/DrPlant-Tutorial.gif',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              icon: const Icon(Icons.close),
              label: const Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return SizedBox(
      width: 120,
      height: 45,
      child: ElevatedButton.icon(
        onPressed: _image == null
            ? null
            : () {
                setState(() {
                  _image = null;
                });
              },
        icon: SizedBox(
          width: 20,
          height: 20,
          child: Image.asset(
            'assets/images/clear.png',
            fit: BoxFit.contain,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        label: const Text('Clear'),
      ),
    );
  }

  Widget _buildLocationToggle() {
    return Positioned(
      top: 20.0,
      right: 35.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            const Text(
              'Location',
              style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(width: 5.0),
            FlutterSwitch(
              activeColor: Colors.green,
              width: 50.0,
              height: 25.0,
              valueFontSize: 12.0,
              toggleSize: 20.0,
              value: _isLocationEnabled,
              borderRadius: 20.0,
              padding: 2.0,
              showOnOff: false,
              activeToggleColor: Colors.black,
              activeText: 'Location',
              inactiveText: 'Location',
              onToggle: (val) {
                setState(() {
                  _isLocationEnabled = val;
                  if (_isLocationEnabled) {
                    _getCurrentLocation();
                  }
                });
              },
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: 12.0,
              height: 20.0,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 16.0,
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () {
                  _showInfoText();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Stack(
      children: [
        Positioned(
          right: 16.0,
          bottom: 16.0,
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: const BorderSide(color: Colors.black, width: 2.0),
            ),
            child: InkWell(
              onTap: () {
                if (!_isLoading) {
                  _identifyPlantUsingAPI();
                }
              },
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.black,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/plant-search.png',
                    width: 35.0,
                    height: 35.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _identifyPlantUsingAPI() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var plantResponse = await identifyPlant(_image!.path, _currentPosition);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IdentificationResultScreen(
            uploadedPlantImage: _image!.path,
            position: _currentPosition,
            plantResponse: plantResponse,
          ),
        ),
      );
    } catch (e) {
      print('Failed to identify plant: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePicture() async {
    try {
      List<CameraDescription> cameras = await availableCameras();

      final imagePath = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CameraScreen(cameras: cameras)),
      );

      if (imagePath != null) {
        setState(() {
          _image = File(imagePath);
        });
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });
      _showLocationServicesDialog();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
        });
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
      });
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _isLoading = false;
    });
  }

  void _showLocationServicesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Location Services'),
          content: const Text(
              'Location services are disabled. Please enable location services to use this feature.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }
}
