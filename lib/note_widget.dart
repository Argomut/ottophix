//Going Behind The Curtain I see :)
//This has been pushed

import 'dart:io'; //Normal dart pile path stuff
import 'package:flutter/material.dart'; //Basic UI stuff
import 'package:file_picker/file_picker.dart'; //Let's users pick files from their File Manager/Storage
import 'package:open_filex/open_filex.dart'; //Allows users to open upp the files once selected and put into the notes widget
import 'package:ottophix/main.dart'; // Supabase client

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
  bool _isLoading = false; // Loading state for database operations
  List<Map<String, dynamic>> _existingEvidence = []; // Store existing evidence entries
  bool _isLoadingEvidence = false; // Loading state for fetching evidence

  //TEController Dispose
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Load existing evidence from database
  Future<void> _loadExistingEvidence() async {
    setState(() {
      _isLoadingEvidence = true;
    });

    try {
      final result = await supabase
          .from('evidence')
          .select()
          .eq('task_id', widget.jobId)
          .order('created_at', ascending: false);

      setState(() {
        _existingEvidence = List<Map<String, dynamic>>.from(result);
        _isLoadingEvidence = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingEvidence = false;
      });
      print('Error loading evidence: $e');
    }
  }

  // Delete evidence entry
  Future<void> _deleteEvidence(Map<String, dynamic> evidence) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Evidence'),
        content: const Text('Are you sure you want to delete this evidence entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase
            .from('evidence')
            .delete()
            .eq('id', evidence['id']);

        // Reload evidence list to reflect the deletion
        await _loadExistingEvidence();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evidence deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting evidence: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Initialize evidence loading when widget expands
  void _onExpanded() {
    setState(() {
      _isExpanded = true;
    });
    _loadExistingEvidence();
  }

  //Save Feature For Text and Database
  Future<void> _saveNote() async {
    if (_notesController.text.trim().isEmpty && _attachedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a note or attach files'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert file paths to strings for JSON storage
      List<String> filePaths = _attachedFiles.map((file) => file.path).toList();

      // Prepare data for database insertion
      Map<String, dynamic> evidenceData = {
        'task_id': widget.jobId,
        'note_text': _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        'attached_files': filePaths.isNotEmpty ? filePaths : null,
      };

      // Save to database
      await supabase.from('evidence').insert(evidenceData);

      setState(() {
        _savedNote = _notesController.text;
      });

      // Clear the form after successful save
      _notesController.clear();
      _attachedFiles.clear();

      // Reload existing evidence to show the new entry
      await _loadExistingEvidence();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evidence saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving evidence: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
              onTap: () {
                if (!_isExpanded) {
                  _onExpanded(); // Load evidence when expanding
                } else {
                  setState(() => _isExpanded = false);
                }
              }, // toggle
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
                        onPressed: _isLoading ? null : _pickFiles,
                        icon: const Icon(Icons.attach_file),
                        label: const Text("Attach"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveNote,
                        icon: _isLoading
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Icon(Icons.save),
                        label: Text(_isLoading ? "Saving..." : "Save"),
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
                    ),

                  // Existing Evidence Section
                  if (_existingEvidence.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      "Previous Evidence:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._existingEvidence.map((evidence) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Evidence header with timestamp and delete button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Evidence Entry',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      evidence['created_at'] != null
                                          ? '${DateTime.parse(evidence['created_at']).day}/${DateTime.parse(evidence['created_at']).month}/${DateTime.parse(evidence['created_at']).year} ${DateTime.parse(evidence['created_at']).hour}:${DateTime.parse(evidence['created_at']).minute.toString().padLeft(2, '0')}'
                                          : 'Unknown date',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                      onPressed: _isLoading ? null : () => _deleteEvidence(evidence),
                                      tooltip: 'Delete evidence',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Note text
                            if (evidence['note_text'] != null && evidence['note_text'].toString().isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Notes:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    evidence['note_text'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),

                            // Attached files
                            if (evidence['attached_files'] != null && evidence['attached_files'].isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Attached Files:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  ...(evidence['attached_files'] as List).map((filePath) => Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.attach_file, size: 14),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            filePath.toString().split(Platform.isWindows ? '\\' : '/').last,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                          ],
                        ),
                      ),
                    )),
                  ],

                  // Loading indicator for existing evidence
                  if (_isLoadingEvidence)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),

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