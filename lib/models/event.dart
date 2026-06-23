class EventChoice {
  String text;
  Map<String, int> effects;
  String? resultText;
  String? triggerEventId;

  EventChoice({
    required this.text,
    Map<String, int>? effects,
    this.resultText,
    this.triggerEventId,
  }) : effects = effects ?? {};

  Map<String, dynamic> toJson() => {
    'text': text,
    'effects': Map<String, int>.from(effects),
    'resultText': resultText,
    'triggerEventId': triggerEventId,
  };

  factory EventChoice.fromJson(Map<String, dynamic> json) => EventChoice(
    text: json['text'] as String? ?? '',
    effects:
        (json['effects'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as int),
        ) ??
        {},
    resultText: json['resultText'] as String?,
    triggerEventId: json['triggerEventId'] as String?,
  );
}

class GameEvent {
  String id;
  String title;
  String description;
  String? triggerCondition;
  List<EventChoice> choices;

  GameEvent({
    required this.id,
    required this.title,
    this.description = '',
    this.triggerCondition,
    List<EventChoice>? choices,
  }) : choices = choices ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'triggerCondition': triggerCondition,
    'choices': choices.map((c) => c.toJson()).toList(),
  };

  factory GameEvent.fromJson(Map<String, dynamic> json) => GameEvent(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    triggerCondition: json['triggerCondition'] as String?,
    choices:
        (json['choices'] as List<dynamic>?)
            ?.map((e) => EventChoice.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}
