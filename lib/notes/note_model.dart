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
        'noteContent': noteContent,
        'dateCreated': dateCreated.toIso8601String(),
        'hasReminder': hasReminder ? 1 : 0,
        'isBookmarked': isBookmarked ? 1 : 0,
        'reminderTime': reminderTime?.toIso8601String(),
        'isLocked': isLocked ? 1 : 0
      };

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
      noteId: json['noteId'],
      noteTitle: json['noteTitle'],
      noteType: json['noteType'],
      noteContent: json['noteContent'],
      dateCreated: DateTime.parse(json['dateCreated']),
      hasReminder: json['hasReminder'] == 1,
      isBookmarked: json['isBookmarked'] == 1,
      isLocked: json['isLocked'] == 1,
      reminderTime:
          json['reminderTime'] != null ? DateTime.parse(json['reminderTime']) : null);
}
