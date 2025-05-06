class Task {
  final int? id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final String dueDate;
  final int assignedUserId;
  final int createdById;
  final String? attachmentPath;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.assignedUserId,
    required this.createdById,
    this.attachmentPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'dueDate': dueDate,
      'assignedUserId': assignedUserId,
      'createdById': createdById,
      'attachmentPath': attachmentPath,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      priority: map['priority'],
      status: map['status'],
      dueDate: map['dueDate'],
      assignedUserId: map['assignedUserId'],
      createdById: map['createdById'],
      attachmentPath: map['attachmentPath'],
    );
  }
}