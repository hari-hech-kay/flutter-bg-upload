import 'package:bg_upload/show_loader.dart';
import 'package:cross_connectivity/cross_connectivity.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';

class Announcement extends StatefulWidget {
  Announcement();
  @override
  _AnnouncementState createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  List<String> _imagePaths = [];
  List<String> _urls = [];
  List<String> _fileNames = [];
  String _cls = "ALL CLASSES";
  String _sub;
  //List<String> _blurHashes = new [];

  final Map<String, List<String>> classes = {
    'ALL CLASSES': ['NOTIFICATIONS'],
    'CLASS 6': [
      'NOTIFICATIONS',
      'ENGLISH',
      'TAMIL',
      'MATHEMATICS',
      'SCIENCE',
      'SOCIAL SCIENCE'
    ],
    'CLASS 7': [
      'NOTIFICATIONS',
      'ENGLISH',
      'TAMIL',
      'MATHEMATICS',
      'SCIENCE',
      'SOCIAL SCIENCE'
    ],
    'CLASS 8': [
      'NOTIFICATIONS',
      'ENGLISH',
      'TAMIL',
      'MATHEMATICS',
      'SCIENCE',
      'SOCIAL SCIENCE'
    ],
    'CLASS 9': ['NOTIFICATIONS', 'MATHEMATICS', 'SCIENCE'],
    'CLASS 10': ['NOTIFICATIONS', 'MATHEMATICS', 'SCIENCE'],
    'CLASS 11': [
      'NOTIFICATIONS',
      'MATHEMATICS',
      'PHYSICS',
      'ACCOUNTANCY (ONLINE ONLY)',
      'APPLIED MATHEMATICS'
    ],
    'CLASS 12': [
      'NOTIFICATIONS',
      'MATHEMATICS',
      'PHYSICS',
      'CHEMISTRY',
      'ACCOUNTANCY (ONLINE ONLY)',
      'APPLIED MATHEMATICS',
      'COMPUTER SCIENCE'
    ]
  };

  PersistentBottomSheetController bottomSheetController;
  TextEditingController bodyController = new TextEditingController();
  TextEditingController titleController = new TextEditingController();

  List<DropdownMenuItem> subjects = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //_intentDataStreamSubscription.cancel();
    bodyController.dispose();
    titleController.dispose();
    super.dispose();
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Discard this announcement?'),
            actions: <Widget>[
              new TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("DISCARD"),
              ),
              //SizedBox(height: 16),
              new TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("KEEP EDITING"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future getFromCamera() async {
    final picker = ImagePicker();
    var _pickedFile =
        await picker.getImage(source: ImageSource.camera, imageQuality: 1);

    setState(() {
      if (_pickedFile != null) _imagePaths.add(_pickedFile.path);
    });
  }

  Future getFromGallery() async {
    FilePickerResult _pickedFiles;
    _pickedFiles = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        onFileLoading: (status) {
          if (status.index == 0)
            Fluttertoast.showToast(msg: "Loading images...");
        });

    setState(() {
      if (_pickedFiles != null)
        _imagePaths.addAll(_pickedFiles.files.map((file) => file.path));
    });
  }

  // Future<bool> uploadAttachments() async {
  //   List<UploadTask> tasks = [];
  //   List<Reference> _refs = [];
  //   bool res = false;
  //   var timestamp = DateTime.now()
  //       .toIso8601String()
  //       .replaceAll(":", "_")
  //       .replaceAll(".", "_");
  //   print(timestamp);
  //   Reference storageRef = FirebaseStorage.instance.ref();
  //   for (var i = 0; i < _imagePaths.length; i++) {
  //     String ext = p.extension(_imagePaths[i]);
  //     UploadTask uploadTask = storageRef
  //         .child('announcements/TTT$timestamp$i$ext')
  //         .putFile(File(_imagePaths[i]));
  //     //print("snapshot munnadi");
  //     tasks.add(uploadTask);
  //   }

  //   List<TaskSnapshot> snaps = await Future.wait<TaskSnapshot>(
  //     tasks,
  //     eagerError: true,
  //   );

  //   for (TaskSnapshot snapshot in snaps) {
  //     switch (snapshot.state) {
  //       case TaskState.success:
  //         res = true;
  //         print("Upload done");

  //         _urls.add(await snapshot.ref.getDownloadURL());
  //         _fileNames.add(snapshot.ref.name);
  //         _refs.add(snapshot.ref);
  //         break;
  //       case TaskState.canceled:
  //         print("upload cancel");
  //         res = false;
  //         _urls.clear();
  //         _fileNames.clear();
  //         _refs.forEach((element) {
  //           element.delete();
  //         });
  //         _refs.clear();
  //         break;
  //       case TaskState.error:
  //         res = false;
  //         print("upload error");
  //         _urls.clear();
  //         _fileNames.clear();
  //         _refs.forEach((element) {
  //           element.delete();
  //         });
  //         _refs.clear();
  //         break;
  //       default:
  //     }
  //   }
  //   return res;
  // }

  sendAnnouncement() async {
    Workmanager().registerOneOffTask(
      'someTask', 'announcementUpload',
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.connected),
      // inputData: {
      //   'class': _cls,
      //   'subject': _sub,
      //   'imagePaths': _imagePaths,
      //   'title': titleController.text,
      //   'body': bodyController.text
      // }
    );
  }

  removeAttachments(List announcements) {
    announcements.forEach((ann) {
      ann['fileNames'].forEach((name) async {
        await FirebaseStorage.instance
            .ref("announcements/" + name.toString())
            .delete();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: new Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            appBar: new AppBar(
              title: Text(
                'Send',
                style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.w500),
              ),
              actions: <Widget>[
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: ListTile(
                          leading: Icon(Icons.camera_alt),
                          title: Text('Camera')),
                      value: 1,
                    ),
                    PopupMenuItem(
                      child: ListTile(
                          leading: Icon(Icons.photo_library),
                          title: Text('Gallery')),
                      value: 2,
                    ),
                  ],
                  onSelected: (value) {
                    FocusScope.of(context).unfocus();
                    switch (value) {
                      case 1:
                        getFromCamera();
                        break;
                      case 2:
                        getFromGallery();
                        break;
                    }
                  },
                  icon: Icon(Icons.attachment),
                ),
                IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      if (await Connectivity().checkConnectivity() ==
                          ConnectivityStatus.none) {
                        showOfflineAlert(context);
                        return;
                      }

                      if (bodyController.text.trim().isNotEmpty &&
                          titleController.text.trim().isNotEmpty) {
                        FocusScope.of(context).unfocus();
                        sendAnnouncement();
                      } else
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            "Enter title and message to send",
                          ),
                          behavior: SnackBarBehavior.fixed,
                        ));
                    })
              ],
            ),
            floatingActionButton: (_imagePaths.length != 0)
                ? FloatingActionButton.extended(
                    onPressed: () {
                      bottomSheetController = _scaffoldKey.currentState
                          .showBottomSheet((context) => showAttachmentSheet());
                    },
                    label: Text(_imagePaths.length.toString()),
                    icon: Icon(Icons.attachment),
                  )
                : null,
            body: ConnectivityBuilder(
              builder: (context, isConnected, status) {
                bool connected = (status != ConnectivityStatus.none);

                return new Stack(
                  fit: StackFit.expand,
                  children: [
                    ListView(
                        padding: EdgeInsets.fromLTRB(12, 0, 12, 18),
                        children: <Widget>[
                          Text(
                            "Share with students",
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5),
                          ),
                          Divider(
                            height: 15,
                          ),
                          DropdownButtonFormField(
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.class_,
                                    color: Theme.of(context).accentColor),
                                border: InputBorder.none),
                            value: _cls == null ? "ALL CLASSES" : _cls,
                            hint: Text('Select Class'),
                            isExpanded: false,
                            //style: TextStyle(color: Colors.indigoAccent),
                            items: classes.keys.map(
                              (val) {
                                return DropdownMenuItem<String>(
                                  value: val,
                                  child: Text(val),
                                );
                              },
                            ).toList(),
                            onChanged: (value) {
                              setState(
                                () {
                                  _cls = value;
                                  _sub = null;
                                },
                              );
                            },
                          ),
                          DropdownButtonFormField(
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.featured_play_list,
                                  color: Theme.of(context).accentColor,
                                ),
                                border: InputBorder.none),
                            value: (_sub == null) ? "NOTIFICATIONS" : _sub,
                            hint: Text('Select Subject'),
                            disabledHint: Text('NOTIFICATIONS'),
                            isExpanded: false,
                            items: (_cls == null || _cls == 'ALL CLASSES')
                                ? null
                                : classes[_cls].map(
                                    (val) {
                                      return DropdownMenuItem<String>(
                                        value: val,
                                        child: Text(val),
                                      );
                                    },
                                  ).toList(),
                            onChanged: (value) {
                              setState(() {
                                _sub = value;
                              });
                            },
                          ),
                          Divider(
                            height: 1,
                          ),
                          TextFormField(
                            controller: titleController,
                            style: TextStyle(height: 1.3, fontSize: 18),
                            cursorColor: Colors.amber,
                            //maxLength: 50,
                            //maxLengthEnforced: true,
                            //expands: true,
                            //maxLines: 2,
                            minLines: 1,
                            enableSuggestions: true,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                  height: 2,
                                  fontSize: 18,
                                  fontFamily: 'Poppins'),
                              hintText: "Title",
                              border: InputBorder.none,
                            ),
                          ),
                          Divider(
                            height: 1,
                          ),
                          TextFormField(
                            controller: bodyController,
                            style: TextStyle(height: 1.3, fontSize: 18),
                            cursorColor: Colors.amber,
                            //autofocus: true,
                            enableInteractiveSelection: true,
                            enableSuggestions: true,
                            //expands: true,
                            maxLines: 150,
                            minLines: 20,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                  height: 1.5,
                                  fontSize: 18,
                                  fontFamily: 'Poppins'),
                              hintText: 'Type your message....',
                              border: InputBorder.none,
                              // hintStyle: TextStyle(
                              //   color: Colors.indigoAccent,
                              // )),
                            ),
                          )
                        ]),
                    (!connected)
                        ? Positioned(
                            height: 24.0,
                            left: 0.0,
                            right: 0.0,
                            child: Container(
                              color: connected
                                  ? Color(0xFF0EE44)
                                  : Color(0xFFEE4400),
                              child: Center(
                                child: Text(
                                  'OFFLINE',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        : Container()
                  ],
                );
              },
            )),
      ),
    );
  }

  void getSubjects() {
    if (_cls == null || _cls == 'ALL CLASSES') {
      subjects = null;
    } else {
      subjects.clear();
      subjects = classes[_cls].map(
        (val) {
          return DropdownMenuItem<String>(
            value: val,
            child: Text(val),
          );
        },
      ).toList();
    }
  }

  Widget showAttachmentSheet() => Card(
        child: Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 24),
            itemCount: _imagePaths.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () {
                setState(() {
                  _imagePaths.removeAt(index);
                  if (_imagePaths.length == 0)
                    bottomSheetController.close();
                  else
                    //print("im here");
                    bottomSheetController.setState(() {});
                });
              },
              child: ImageAttachment(
                File(_imagePaths.elementAt(index)),
              ),
            ),
          ),
        ),
      );
}

class ImageAttachment extends StatelessWidget {
  final File _image;

  ImageAttachment(this._image);

  @override
  Widget build(BuildContext context) {
    return _image != null
        ? Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            height: 100.0,
            width: 100.0,
            alignment: Alignment.center,
            child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white60,
                child: Icon(
                  Icons.close,
                  size: 18,
                )),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                image: DecorationImage(
                    image: FileImage(_image), fit: BoxFit.cover)),
          )
        : Container();
  }
}
