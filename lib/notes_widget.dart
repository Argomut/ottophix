//Going Behind The Curtain I see :)
//This has been pushed

import 'dart:io'; //Normal dart pile path stuff
import 'package:flutter/material.dart'; //Basic UI stuff
import 'package:file_picker/file_picker.dart'; //Let's users pick files from their File Manager/Storage
import 'package:open_filex/open_filex.dart'; //Allows users to open upp the files once selected and put into the notes widget

//Widget Declaration - Object creation
class NotesWidget extends StatefulWidget {
  final String jobId; //Tracks which note this instance is
  const NotesWidget({Key? key, required this.jobId}) : super(key: key); //

  @override
  State<NotesWidget> createState() => _NotesWidgetState();
}
//Variables
class _NotesWidgetState extends State<NotesWidget> {
  bool _isExpanded = false;//Checks if the widget has been dropped down or not
  final TextEditingController _notesController = TextEditingController(); //Text field editor
  String? _savedNote; //Text Field Variable
  List<File> _attachedFiles = []; //All attachements are saved here

  //TEController Dispose
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  //Save Feature For Text
  void _saveNote() {
    setState(() {
      _savedNote = _notesController.text;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note saved!')),
    );
  }

//File Picker for Selecting Objects from
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _attachedFiles.addAll(
          result.paths.whereType<String>().map((path) => File(path)),
        );
      });
    }
  }

  //Opens Files when tapped on by the user after selecting in Attachment list
  Future<void> _openFile(File file) async {
    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open file')),
      );
    }
  }

  //Unique icon for specific media
  IconData _fileIcon(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.png')) return Icons.image;
    if (lower.endsWith('.mp4') || lower.endsWith('.mov')) return Icons.videocam;
    if (lower.endsWith('.mp3') || lower.endsWith('.wav')) return Icons.audiotrack;
    return Icons.insert_drive_file;
  }




  //Structure of Widget
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          //This is the foldable header
          //This is the foldable header
          Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 152, 0, 1), // custom yellow-orange
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: ListTile(
              title: const Text(
                "Notes",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // white text
                ),
              ),
              trailing: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white, // white expand icon
              ),
              onTap: () => setState(() => _isExpanded = !_isExpanded), // toggle
            ),
          ),


          //Folding Animation
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_savedNote != null && _savedNote!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        "Saved note: $_savedNote",
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                  //Notes Text Field Area
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Write your notes here...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickFiles,
                        icon: const Icon(Icons.attach_file),
                        label: const Text("Attach"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _saveNote,
                        icon: const Icon(Icons.save),
                        label: const Text("Save"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Attached files list show along with Delete Function
                  if (_attachedFiles.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Attachments:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        ..._attachedFiles.map((file) => ListTile(
                          leading: Icon(_fileIcon(file.path)),
                          title: Text(
                            file.path.split('/').last,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _openFile(file),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete File'),
                                  content: const Text(
                                      'Are you sure you want to remove this attachment?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: const Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                setState(() {
                                  _attachedFiles.remove(file);
                                });
                              }
                            },
                          ),
                        )),
                      ],
                    )

                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
