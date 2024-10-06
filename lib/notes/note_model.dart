class NoteModel {
  String noteId;
  String noteTitle;
  String noteType;
  String noteContent;
  DateTime dateCreated;
  bool hasReminder;
  bool isBookmarked;
  bool isLocked;
  DateTime? reminderTime;

  NoteModel(
      {required this.noteId,
      required this.noteTitle,
      required this.noteType,
      required this.noteContent,
      required this.dateCreated,
      this.isLocked = false,
      this.hasReminder = false,
      this.isBookmarked = false,
      this.reminderTime});

  Map<String, dynamic> toJson() => {
        'noteId': noteId,
        'noteTitle': noteTitle,
        'noteType': noteType,
        'content': noteContent,
        'dateCreated': dateCreated.toIso8601String(),
        'hasReminder': hasReminder,
        'isBookmarked': isBookmarked,
        'reminderTime': reminderTime?.toIso8601String(),
        'isLocked': isLocked
      };

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
      noteId: json['noteId'],
      noteTitle: json['noteTitle'],
      noteType: json['noteType'],
      noteContent: json['content'],
      dateCreated: DateTime.parse(json['dateCreated']),
      hasReminder: json['hasReminder'] ?? false,
      isLocked: json['isLocked'] ?? false,
      reminderTime:
          json['reminderTime'] != null ? DateTime.parse(json['reminderTime']) : null);
}
