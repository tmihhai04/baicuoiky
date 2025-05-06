import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';
import 'task_form_screen.dart';
import 'task_detail_screen.dart';
import 'login_screen.dart';

// Màn hình hiển thị danh sách các công việc
class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController(); // Controller để xử lý input tìm kiếm
  String? _selectedStatus;     // Lọc theo trạng thái công việc
  String? _selectedPriority;   // Lọc theo mức độ ưu tiên

  @override
  void initState() {
    super.initState();
    // Lấy người dùng hiện tại từ AuthProvider
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;

    // Gọi hàm fetchTasks để lấy dữ liệu từ SQLite khi khởi động
    Provider.of<TaskProvider>(context, listen: false).fetchTasks(
      userId: user!.id,
      isAdmin: user.isAdmin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context); // Lấy TaskProvider để truy cập danh sách task
    final authProvider = Provider.of<AuthProvider>(context); // Lấy AuthProvider để đăng xuất
    final user = authProvider.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Manager',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade900], // Gradient màu xanh
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          // Nút đăng xuất
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              authProvider.logout(); // Gọi logout từ AuthProvider
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
        elevation: 5,
        shadowColor: Colors.black45,
      ),

      // Phần thân chính của ứng dụng
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Ô tìm kiếm task
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search tasks',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  // Khi người dùng gõ tìm kiếm, lọc danh sách task
                  taskProvider.searchTasks(
                    userId: user.id,
                    isAdmin: user.isAdmin,
                    query: value,
                    status: _selectedStatus,
                    priority: _selectedPriority,
                  );
                },
              ),
            ),

            // Các dropdown filter: trạng thái và mức độ ưu tiên
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Dropdown lọc theo trạng thái
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      hint: Text('Status', style: TextStyle(color: Colors.white70)),
                      value: _selectedStatus,
                      dropdownColor: Colors.blue.shade800,
                      style: TextStyle(color: Colors.white),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
                      underline: SizedBox(),
                      items: ['To Do', 'In Progress', 'Done']
                          .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status, style: TextStyle(color: Colors.white)),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                        taskProvider.searchTasks(
                          userId: user.id,
                          isAdmin: user.isAdmin,
                          query: _searchController.text,
                          status: value,
                          priority: _selectedPriority,
                        );
                      },
                    ),
                  ),

                  // Dropdown lọc theo độ ưu tiên
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      hint: Text('Priority', style: TextStyle(color: Colors.white70)),
                      value: _selectedPriority,
                      dropdownColor: Colors.blue.shade800,
                      style: TextStyle(color: Colors.white),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
                      underline: SizedBox(),
                      items: ['Low', 'Medium', 'High']
                          .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority, style: TextStyle(color: Colors.white)),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value;
                        });
                        taskProvider.searchTasks(
                          userId: user.id,
                          isAdmin: user.isAdmin,
                          query: _searchController.text,
                          status: _selectedStatus,
                          priority: value,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Danh sách hiển thị các task
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                itemCount: taskProvider.tasks.length,
                itemBuilder: (context, index) {
                  final task = taskProvider.tasks[index];
                  return TaskItem(
                    task: task,
                    onTap: () {
                      // Khi bấm vào 1 task, chuyển đến màn hình chi tiết
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailScreen(task: task),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Nút thêm mới task
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Mở màn hình thêm task
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskFormScreen()),
          );
        },
        backgroundColor: Colors.blue.shade600,
        child: Icon(Icons.add, color: Colors.white, size: 28),
        elevation: 6,
        hoverElevation: 10,
      ),
    );
  }
}