import 'package:flutter/material.dart';
import 'package:dr_plant/plant_response.dart';
import 'package:dr_plant/api_service.dart';

class ConversationScreen extends StatefulWidget {
  final String accessToken;
  final String plantName;
  final bool isDiseaseCall;

  const ConversationScreen({
    Key? key,
    required this.accessToken,
    required this.plantName,
    required this.isDiseaseCall,
  }) : super(key: key);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final List<String> questions = [
    "How do I take care of this plant?",
    "Is this plant edible?",
    "Best soil for this plant?",
    "How often to water this plant?",
    "Does it need direct sunlight?",
    "How to propagate this plant?",
  ];

  final List<String> diseaseQuestions = [
    "Chemical care for this plant?",
    "Bio care for this plant?",
    "Causes of this disease?",
    "Facts about this disease?",
    "Is the plant curable?",
    "Prevention of this disease?",
  ];

  final List<Map<String, String>> conversation = [];
  int messageIndex = 0;
  bool hasSentQuestion = false;
  bool isLoading = false;

  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> isSendButtonEnabled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      isSendButtonEnabled.value = _controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendRequestToChatbotAPI(String question) async {
    setState(() {
      isLoading = true;
    });

    try {
      var response = await getChatbotResponse(question, widget.accessToken);
      setState(() {
        conversation.add({'user': question});
        if (response.messages.isNotEmpty) {
          messageIndex++;
          conversation.add({'bot': response.messages[messageIndex].content});
        } else {
          conversation.add({'bot': 'No response from bot.'});
        }

        messageIndex++;
        hasSentQuestion = true;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching chatbot response: $e');
      setState(() {
        conversation.add({'bot': 'Error fetching response.'});
        isLoading = false;
      });
    }
  }

  void _handlePromptSelection(String question) {
    setState(() {
      _controller.text = question;
    });
  }

  void _handleSendButton() {
    if (_controller.text.isNotEmpty) {
      String question = _controller.text;
      _controller.clear();
      _sendRequestToChatbotAPI(question);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/Dr.Plant_Title.png', height: 30),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: conversation.length,
                itemBuilder: (context, index) {
                  final entry = conversation[index];
                  bool isUserMessage = entry.keys.first == 'user';
                  return Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: isUserMessage
                            ? Colors.blue[100]
                            : Colors.green[100],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.values.first,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(height: 3.0),
                          Text(
                            isUserMessage ? 'You' : 'Bot',
                            style: TextStyle(
                                fontSize: 10.0, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (!hasSentQuestion)
              widget.isDiseaseCall
                  ? _buildDiseaseQuestions()
                  : _buildQuestions(),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: questions.map((question) {
          return ElevatedButton(
            onPressed: () => _handlePromptSelection(question),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.black,
              textStyle: const TextStyle(
                fontSize: 11.0,
              ),
              side: const BorderSide(color: Colors.grey),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Text(question),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDiseaseQuestions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: diseaseQuestions.map((question) {
          return ElevatedButton(
            onPressed: () => _handlePromptSelection(question),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.black,
              textStyle: const TextStyle(
                fontSize: 12.0,
              ),
              side: const BorderSide(color: Colors.grey),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Text(question),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Talk to Plant Chatbot...',
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 3.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          ValueListenableBuilder<bool>(
            valueListenable: isSendButtonEnabled,
            builder: (context, value, child) {
              return ElevatedButton(
                onPressed: value ? _handleSendButton : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                child: const Text('Send'),
              );
            },
          ),
        ],
      ),
    );
  }
}
