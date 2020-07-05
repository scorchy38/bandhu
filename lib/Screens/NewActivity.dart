import 'dart:io';

import 'package:bandhunew/Widgets/CustomTextField.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:random_string/random_string.dart';

class NewActivity extends StatefulWidget {
  @override
  _NewActivityState createState() => _NewActivityState();
}

final activityName = TextEditingController();
final rawMaterial = TextEditingController();
final avgProduction = TextEditingController();
final dbRef = FirebaseDatabase.instance.reference();
final FirebaseAuth mAuth = FirebaseAuth.instance;
String name = "";

class _NewActivityState extends State<NewActivity> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ProgressDialog pr;
  bool _isLoading = false;
  double _progress = 0;

  String unique;
  File file;
  String fileName = '';
  String operationText = '';
  bool isUploaded = true;
  String result = '';
  List<String> imageUrls = [];
  List<String> videoUrls = [];

  Future<void> _uploadImage(File file, String filename) async {
    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://bandhu-d4b07.appspot.com');
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    StorageReference storageReference;
    storageReference =
        _storage.ref().child("ActivityImages").child(user.uid).child(fileName);

    final StorageUploadTask uploadTask = storageReference.putFile(file);
    Fluttertoast.showToast(msg: 'Uploading...', gravity: ToastGravity.CENTER);
    uploadTask.events.listen((event) {
      setState(() {
        _isLoading = true;
        _progress = (event.snapshot.bytesTransferred.toDouble() /
                event.snapshot.totalByteCount.toDouble()) *
            100;
        print('${_progress.toStringAsFixed(2)}%');
        pr.update(
          progress: double.parse(_progress.toStringAsFixed(2)),
          maxProgress: 100.0,
        );
      });
    }).onError((error) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(error.toString()),
        backgroundColor: Colors.red,
      ));
    });
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    print("URL is $url");
    imageUrls.add(url);
    Fluttertoast.showToast(
        msg: 'Upload Complete', gravity: ToastGravity.CENTER);
    setState(() {});
  }

  Future imagePicker(BuildContext context) async {
    try {
      file = await FilePicker.getFile(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'png', 'jpeg'],
      );
      setState(() {
        fileName = p.basename(file.path);
      });
      print(fileName);
      pr = ProgressDialog(
        context,
        type: ProgressDialogType.Download,
        textDirection: TextDirection.rtl,
        isDismissible: true,
      );
      pr.style(
        message: 'Uploading photos...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progressWidgetAlignment: Alignment.center,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
      );
      await pr.show();

      await _uploadImage(file, fileName);
    } on PlatformException catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sorry...'),
              content: Text('Unsupported exception: $e'),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
    setState(() async {
      await pr.hide();
      print(fileName);
    });
  }

  void _uploadVideo(File file, String filename) async {
    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://bandhu-d4b07.appspot.com');
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    StorageReference storageReference;
    storageReference =
        _storage.ref().child("ActivityVideos").child(user.uid).child(fileName);

    final StorageUploadTask uploadTask = storageReference.putFile(file);
    Fluttertoast.showToast(msg: 'Uploading...', gravity: ToastGravity.CENTER);
    uploadTask.events.listen((event) {
      setState(() {
        _isLoading = true;
        _progress = (event.snapshot.bytesTransferred.toDouble() /
                event.snapshot.totalByteCount.toDouble()) *
            100;
        print('${_progress.toStringAsFixed(2)}%');
        pr.update(
          progress: double.parse(_progress.toStringAsFixed(2)),
          maxProgress: 100.0,
        );
      });
    }).onError((error) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(error.toString()),
        backgroundColor: Colors.red,
      ));
    });
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    print("URL is $url");
    videoUrls.add(url);
    Fluttertoast.showToast(
        msg: 'Upload Complete', gravity: ToastGravity.CENTER);
    setState(() async {
      await pr.hide();
    });
  }

  Future videoPicker(BuildContext context) async {
    try {
      file = await FilePicker.getFile(
        type: FileType.video,
      );
      setState(() {
        fileName = p.basename(file.path);
      });
      print(fileName);
      pr = ProgressDialog(
        context,
        type: ProgressDialogType.Download,
        textDirection: TextDirection.rtl,
        isDismissible: true,
      );
      pr.style(
        message: 'Uploading videos...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progressWidgetAlignment: Alignment.center,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
      );
      await pr.show();
      _uploadVideo(file, fileName);
    } on PlatformException catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sorry...'),
              content: Text('Unsupported exception: $e'),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
    setState(() async {
      print(fileName);
    });
  }

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    int keyLength = randomBetween(5, 15);
    String key = randomAlpha(keyLength);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Add new activity',
          style: GoogleFonts.poppins(
              textStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 25)),
        ),
        backgroundColor: Color(0xFF6F35A5),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Color(0xFFF1E6FF),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              CustomTextField(activityName, 'Activity Name'),
              CustomTextField(rawMaterial, 'Raw material used'),
              CustomTextField(avgProduction, 'Average Production'),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(27, 0, 27, 0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black, width: 1)),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Images : ',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 15),
                          ),
                        ),
                        Text(
                          imageUrls.length.toString(),
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 15),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            imagePicker(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF6F35A5),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.add,
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
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(27, 0, 27, 0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black, width: 1)),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Videos : ',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 15),
                          ),
                        ),
                        Text(
                          videoUrls.length.toString(),
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 15),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            videoPicker(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF6F35A5),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
//                        ListView.builder(
//                            itemCount: imageUrls.length,
//                            itemBuilder: (context, index) {
//                              var item = imageUrls[index];
//                              return Image.network(item);
//                            }),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  setState(() {});
                  writeData(key);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF6F35A5),
                    borderRadius: BorderRadius.circular(33),
                  ),
                  width: ((MediaQuery.of(context).size).width * 0.8),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Publish',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void writeData(String key) async {
    final FirebaseUser user = await mAuth.currentUser();
    String uid = user.uid;
    dbRef.child('Activities').child(uid).child(key).update({
      'activtyName': activityName.text,
      'rawMaterial': rawMaterial.text,
      'avgProduction': avgProduction.text,
    });

    dbRef
        .child('Activities')
        .child(user.uid)
        .child(key)
        .update({"Images": imageUrls}).then((_) {
      Fluttertoast.showToast(msg: "Successfully Uploaded");

      setState(() {
        imageUrls.clear();
      });
    });

    dbRef
        .child('Activities')
        .child(user.uid)
        .child(key)
        .update({"Videos": videoUrls}).then((_) {
      Fluttertoast.showToast(msg: "Successfully Uploaded!");

      setState(() {
        videoUrls.clear();
      });
    });

    Fluttertoast.showToast(msg: 'Completed', toastLength: Toast.LENGTH_SHORT);

    activityName.clear();
    rawMaterial.clear();
    avgProduction.clear();
    Navigator.pop(context);
  }
}
