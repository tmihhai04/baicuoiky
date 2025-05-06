import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../models/user.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  TaskFormScreen({this.task});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'Low';
  String _status = 'To Do';
  DateTime? _dueDate;
  int? _assignedUserId;
  String? _attachmentPath;
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _priority = widget.task!.priority;
      _status = widget.task!.status;
      _dueDate = DateTime.parse(widget.task!.dueDate);
      _assignedUserId = widget.task!.assignedUserId;
      _attachmentPath = widget.task!.attachmentPath;
    }
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await Provider.of<TaskProvider>(context, listen: false).getAllUsers();
    setState(() {
      _users = users;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _attachmentPath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final currentUser = authProvider.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.task == null ? 'Add Task' : 'Edit Task',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 5,
        shadowColor: Colors.black45,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.title, color: Colors.white70),
                  ),
                  style: TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.description, color: Colors.white70),
                  ),
                  maxLines: 3,
                  style: TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _priority,
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                    dropdownColor: Colors.blue.shade800,
                    style: TextStyle(color: Colors.white),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
                    items: ['Low', 'Medium', 'High']
                        .map((priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority, style: TextStyle(color: Colors.white)),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _priority = value!;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _status,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                    dropdownColor: Colors.blue.shade800,
                    style: TextStyle(color: Colors.white),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
                    items: ['To Do', 'In Progress', 'Done']
                        .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status, style: TextStyle(color: Colors.white)),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _status = value!;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  color: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      _dueDate == null
                          ? 'Select Due Date'
                          : 'Due Date: ${DateFormat('yyyy-MM-dd').format(_dueDate!)}',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Icon(Icons.calendar_today, color: Colors.white70),
                    onTap: _pickDate,
                  ),
                ),
                SizedBox(height: 20),
                if (currentUser.isAdmin)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<int>(
                      value: _assignedUserId,
                      decoration: InputDecoration(
                        labelText: 'Assign to',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      dropdownColor: Colors.blue.shade800,
                      style: TextStyle(color: Colors.white),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
                      items: _users
                          .map((user) => DropdownMenuItem(
                        value: user.id,
                        child: Text(user.username, style: TextStyle(color: Colors.white)),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _assignedUserId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please assign a user';
                        }
                        return null;
                      },
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Assigned to: ${currentUser.username}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                SizedBox(height: 20),
                Card(
                  color: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      _attachmentPath == null ? 'Add Attachment' : 'Attachment: $_attachmentPath',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Icon(Icons.attach_file, color: Colors.white70),
                    onTap: _pickFile,
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade900],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _dueDate != null) {
                        final task = Task(
                          id: widget.task?.id,
                          title: _titleController.text,
                          description: _descriptionController.text,
                          priority: _priority,
                          status: _status,
                          dueDate: _dueDate!.toIso8601String(),
                          assignedUserId: currentUser.isAdmin ? _assignedUserId! : currentUser.id!,
                          createdById: currentUser.id!,
                          attachmentPath: _attachmentPath,
                        );

                        if (widget.task == null) {
                          taskProvider.addTask(task);
                        } else {
                          taskProvider.updateTask(task);
                        }
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.task == null ? 'Add Task' : 'Update Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}