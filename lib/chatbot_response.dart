class ChatbotResponse {
  final List<ChatMessage> messages;
  final String identification;
  final int remainingCalls;
  final ModelParameters modelParameters;
  final Map<String, dynamic> feedback;

  ChatbotResponse({
    required this.messages,
    required this.identification,
    required this.remainingCalls,
    required this.modelParameters,
    required this.feedback,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    return ChatbotResponse(
      messages: List<ChatMessage>.from(
          json['messages'].map((message) => ChatMessage.fromJson(message))),
      identification: json['identification'],
      remainingCalls: json['remaining_calls'],
      modelParameters: ModelParameters.fromJson(json['model_parameters']),
      feedback: json['feedback'] ?? {},
    );
  }
}

class ChatMessage {
  final String content;
  final String type;
  final DateTime created;

  ChatMessage({
    required this.content,
    required this.type,
    required this.created,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'],
      type: json['type'],
      created: DateTime.parse(json['created']),
    );
  }
}

class ModelParameters {
  final String model;
  final double temperature;

  ModelParameters({
    required this.model,
    required this.temperature,
  });

  factory ModelParameters.fromJson(Map<String, dynamic> json) {
    return ModelParameters(
      model: json['model'],
      temperature: json['temperature'],
    );
  }
}
