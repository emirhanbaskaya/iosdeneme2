import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'note.dart';
import 'note_database.dart';
import 'note_detail_page.dart';
import 'note_edit_page.dart';
import 'splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Not Defteri',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: SplashScreen(),
    );
  }
}

class NoteListPage extends StatefulWidget {
  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  late Future<List<Note>> notes;
  bool _selectionMode = false;
  List<int> _selectedNotes = [];

  @override
  void initState() {
    super.initState();
    notes = NoteDatabase.instance.readAll();
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      _selectedNotes.clear();
    });
  }

  void _toggleNoteSelection(int id) {
    setState(() {
      if (_selectedNotes.contains(id)) {
        _selectedNotes.remove(id);
      } else {
        _selectedNotes.add(id);
      }
    });
  }

  void _deleteSelectedNotes() async {
    for (var id in _selectedNotes) {
      await NoteDatabase.instance.delete(id);
    }
    setState(() {
      notes = NoteDatabase.instance.readAll();
      _selectionMode = false;
      _selectedNotes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text(
          'Memory Power',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          if (_selectionMode)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _selectedNotes.isEmpty ? null : _deleteSelectedNotes,
            ),
          IconButton(
            icon: Icon(_selectionMode ? Icons.close : Icons.select_all),
            onPressed: _toggleSelectionMode,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.blue[200]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<Note>>(
          future: notes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Bir hata oluştu'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Henüz not yok'));
            } else {
              List<Note> sortedNotes = snapshot.data!;
              sortedNotes.sort((a, b) => b.isImportant ? 1 : -1);

              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: sortedNotes.length,
                itemBuilder: (context, index) {
                  final note = sortedNotes[index];
                  bool isSelected = _selectedNotes.contains(note.id!);
                  bool hasImage = note.imagePath != null && note.imagePath!.isNotEmpty;

                  return GestureDetector(
                    onTap: _selectionMode
                        ? () => _toggleNoteSelection(note.id!)
                        : () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NoteDetailPage(note: note),
                      ));
                      setState(() {
                        notes = NoteDatabase.instance.readAll();
                      });
                    },
                    child: Stack(
                      children: [
                        if (hasImage)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Image.file(
                                File(note.imagePath!.split(',')[0]),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(color: Colors.grey);
                                },
                              ),
                            ),
                          ),
                        if (hasImage)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                child: Container(
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                        Card(
                          margin: EdgeInsets.all(0),
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  note.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (note.imagePath != null && note.imagePath!.isNotEmpty)
                                      Icon(
                                        Icons.photo,
                                        color: Colors.white70,
                                      ),
                                    if (note.isImportant)
                                      Icon(
                                        Icons.star,
                                        color: Colors.white70,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_selectionMode && isSelected)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.blue[800],
                                  size: 24.0,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NoteEditPage(),
          ));
          setState(() {
            notes = NoteDatabase.instance.readAll();
          });
        },
        child: Icon(Icons.add, color: Colors.white), // Burayı beyaz yapıyoruz
        backgroundColor: Colors.blue[800],
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
