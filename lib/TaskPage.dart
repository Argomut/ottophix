import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  /// read task from supabase
  Future<void> _loadTasks() async {
    final response = await Supabase.instance.client
        .from('tasks')
        .select()
        .order('creation_time', ascending: false);

    setState(() {
      tasks = List<Map<String, dynamic>>.from(response);
    });
  }

  /// add new task
  Future<void> _addTask() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    if (name.isEmpty) return;

    await Supabase.instance.client.from('tasks').insert({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'description': desc,
    });

    _nameController.clear();
    _descController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Task added ")),
    );

    _loadTasks(); // reload task list
  }

  /// delete task
  Future<void> _deleteTask(String id) async {
    await Supabase.instance.client.from('tasks').delete().eq('id', id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Task deleted ")),
    );

    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Task Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Add Task"),
                ),
              ],
            ),
          ),

          const Divider(),

          // task list
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text("No tasks yet"))
                : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(task['name']),
                    subtitle: Text(task['description'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // time
                        if (task['creation_time'] != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                              DateTime.parse(task['creation_time'])
                                  .toLocal()
                                  .toString()
                                  .split('.')[0], // remove millisecond
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        // delete button
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () {
                            _deleteTask(task['id'].toString());
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}