import 'package:flutter/material.dart';
import 'Task.dart';

void main() {
  runApp(MaterialApp(
    home: NewTaskForm(title: 'New Task'), // Add the required 'title' parameter here
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const NewTaskForm(title: 'Flutter Demo Home Page'),
    );
  }
}

class NewTaskForm extends StatefulWidget {
  const NewTaskForm({super.key, this.title}); // Remove 'required'
  final String? title;
  @override
  _NewTaskFormState createState() => _NewTaskFormState();
}

class _NewTaskFormState extends State<NewTaskForm> {
  // Controllers for the text fields to access their content.
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDescriptionController = TextEditingController();


  void _createTask() {
    final String taskName = _taskNameController.text;
    final String taskDescription = _taskDescriptionController.text;

    print('Task Name: $taskName');
    print('Task Description: $taskDescription');

    // Pop the page and pass the taskName back to the previous screen.
    Navigator.of(context).pop({'name': taskName, 'description': taskDescription});
  }

  void _uploadImage() {
    // This function will handle the image upload logic.
    // You can use a package like `image_picker` for this.
    print('Upload image button pressed');
    // Implement image picker logic here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job ID: ABC1234'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Name Field
            Text(
              'Task Name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _taskNameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Task Description Field
            Text(
              'Task Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _taskDescriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Required Parts Section
            Text(
              'Require Parts(Optional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _uploadImage,
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.black),
                ),
                child: Icon(Icons.add),
              ),
            ),
            SizedBox(height: 50), // Spacing before the button

            // Create Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _createTask,
                icon: Icon(Icons.check, color: Colors.white),
                label: Text('Create', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC9C0E2), // A purplish color
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


