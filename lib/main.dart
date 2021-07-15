import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';
import 'new_announcement.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();
var details = NotificationDetails(
    android: AndroidNotificationDetails(
  'id',
  'channel ',
  'description',
  priority: Priority.defaultPriority,
  importance: Importance.high,
));

void callbackDispatcher() {
  Workmanager().executeTask((task, data) {
    notificationsPlugin.initialize(InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher')));
    print("hello");
    debugPrint("hello there");
    //if (task == 'announcementUpload') {
    //   await notificationsPlugin.show(0, '${data['class']} | ${data['subject']}',
    //       'Posting your announcement...', details);

    //   List<String> _imagePaths = data['imagePaths'];
    //   List<String> _urls = [];
    //   List<String> _fileNames = [];
    //   var uploadResult = true;
    //   if (_imagePaths.length > 0) {
    //     print("inside here");
    //     List<UploadTask> tasks = [];
    //     List<Reference> _refs = [];
    //     bool res = false;
    //     var timestamp = DateTime.now()
    //         .toIso8601String()
    //         .replaceAll(":", "_")
    //         .replaceAll(".", "_");
    //     print(timestamp);
    //     Reference storageRef = FirebaseStorage.instance.ref();
    //     for (var i = 0; i < _imagePaths.length; i++) {
    //       String ext = p.extension(_imagePaths[i]);
    //       UploadTask uploadTask = storageRef
    //           .child('announcements/TTT$timestamp$i$ext')
    //           .putFile(File(_imagePaths[i]));
    //       //print("snapshot munnadi");
    //       tasks.add(uploadTask);
    //     }

    //     List<TaskSnapshot> snaps = await Future.wait<TaskSnapshot>(
    //       tasks,
    //       eagerError: true,
    //     );

    //     for (TaskSnapshot snapshot in snaps) {
    //       switch (snapshot.state) {
    //         case TaskState.success:
    //           res = true;
    //           print("Upload done");

    //           _urls.add(await snapshot.ref.getDownloadURL());
    //           _fileNames.add(snapshot.ref.name);
    //           _refs.add(snapshot.ref);
    //           break;
    //         case TaskState.canceled:
    //           print("upload cancel");
    //           res = false;
    //           _urls.clear();
    //           _fileNames.clear();
    //           _refs.forEach((element) {
    //             element.delete();
    //           });
    //           _refs.clear();
    //           break;
    //         case TaskState.error:
    //           res = false;
    //           print("upload error");
    //           _urls.clear();
    //           _fileNames.clear();
    //           _refs.forEach((element) {
    //             element.delete();
    //           });
    //           _refs.clear();
    //           break;
    //         default:
    //       }
    //     }
    //     uploadResult = res;
    //     print("upload results");
    //     print(uploadResult);
    //     print(_urls);
    //     print(_fileNames);
    //   }

    //   if (!uploadResult) {
    //     await notificationsPlugin.show(
    //         0,
    //         '${data['class']} | ${data['subject']}',
    //         'Upload failed...',
    //         details);
    //     return true;
    //   }
    //   var obj = {
    //     "announcement_id": Uuid().v1(),
    //     "title": data['title'],
    //     "body": data['body'],
    //     "attachments": _urls,
    //     "fileNames": _fileNames,
    //     "time": FieldValue.serverTimestamp(),
    //   };
    //   print(obj);
    //   var batch = FirebaseFirestore.instance.batch();
    //   if (data['class'] == "ALL CLASSES") {
    //     for (var i = 6; i <= 12; i++) {
    //       var classTemp = "CLASS $i";

    //       batch.update(
    //           FirebaseFirestore.instance
    //               .collection('$classTemp')
    //               .doc('NOTIFICATIONS'),
    //           {
    //             "announcements": FieldValue.arrayUnion([obj]),
    //             "updatedAt": FieldValue.serverTimestamp()
    //           });
    //     }
    //   } else {
    //     batch.update(
    //         FirebaseFirestore.instance
    //             .collection(data['class'])
    //             .doc(data['subject']),
    //         {
    //           "announcements": FieldValue.arrayUnion([obj]),
    //           "updatedAt": FieldValue.serverTimestamp()
    //         });
    //   }

    //   await batch.commit().then((value) {
    //     notificationsPlugin.show(0, '${data['class']} | ${data['subject']}',
    //         'Upload success...', details);
    //   }).catchError((e) {
    //     notificationsPlugin.show(0, '${data['class']} | ${data['subject']}',
    //         'Upload failed...', details);
    //   });
    // }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Announcement(),
    );
  }
}
