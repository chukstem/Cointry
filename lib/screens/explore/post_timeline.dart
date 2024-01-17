import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:device_info/device_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:crypto_app/models/timeline_images_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';
import '../../constants.dart';
import '../../Language.dart' as language_string;
import 'package:http/http.dart' as http;
import '../../models/post.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import '../../widgets/snackbar.dart';
import '../home/ImageView.dart';
import 'dart:io' show Platform;

class NewPost extends StatefulWidget {
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  bool progress=false, error=false;
  String content="", videoPath="", audioPath="";
  final controller = TextEditingController();
  List<TimelineImagesModel> images = List.empty(growable: true);
  String errormsg="";
  final ImagePicker _picker = ImagePicker();


  post() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username")!;
    if (content.isNotEmpty) {
    String path="";
    if(audioPath.isNotEmpty) {
      setState(() {
        path = path.isEmpty? '{"audio": "$audioPath"}' : '$path, {"audio": "$audioPath"}';
      });
    }
    if(videoPath.isNotEmpty) {
      setState(() {
        path = path.isEmpty? '{"video": "$videoPath"}' : '$path, {"video": "$videoPath"}';
      });
    }

    if(images.isNotEmpty) {
      String path2 = "";
      for (var image in images) {
        setState(() {
          path2 = path2.isEmpty ? '{"url": "${image.url}"}' : '$path2, {"url": "${image.url}"}';
        });
      }
      setState(() {
        path = path.isEmpty ? '{"images": [$path2]}' : '$path, {"images": [$path2]}';
      });
    }
    setState(() {
      path="[$path]";
    });
    final Post posts = new Post(user: username, content: "$content", url: "/post_timeline", var1: "$path", retries: 0,
        uid: Uuid().v4());

    upload(posts, context);
    }else{
      Snackbar().show(context, ContentType.failure, language_string.Language.error, "Post body can not be empty");
    }

  }

  Future<int> getSdkVersion() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
    return androidInfo.version.sdkInt;
  }


  Future upload(Post post, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token=prefs.getString("token");
    String? username=prefs.getString("username");

    try{
      var uri = Uri.parse(Strings.url + post.url);

      QuickAlert.show(
        barrierDismissible: false,
        context: context,
        type: QuickAlertType.loading,
        title: language_string.Language.loading,
        text: language_string.Language.processing,
      );
      var request = http.MultipartRequest("POST", uri);
      List<http.MultipartFile> newList = [];

      //upload images
      try{
        var files=json.decode(post.var1.toString());
        for(var file in files) {
          var js = json.decode(jsonEncode(file["images"]));
          var images = js as List<dynamic>;
          int i=0;
          for (var img in images) {
            i++;
            String fileName = File(img["url"]).path.split("/").last;
            var stream = new http.ByteStream(DelegatingStream.typed(File(img["url"]).openRead()));
            var length = await File(img["url"]).length();
            var multipartFileSign = new http.MultipartFile('images[$i]', stream, length, filename: fileName);
            newList.add(multipartFileSign);
          }
          request.files.addAll(newList);
        }
      }catch(e){ }

      //upload audio
      try{
        var files=json.decode(post.var1.toString());
        for(var file in files){
          if(file["audio"]!=""){
            var stream = http.ByteStream(
                DelegatingStream.typed(File(file["audio"]).openRead()));
            var length = await File(file["audio"]).length();
            var multipartFile = http.MultipartFile(
                "audio", stream, length, filename: File(file["audio"]).path.split('/').last);
            newList.add(multipartFile);
          }
          request.files.addAll(newList);
        }
      }catch(e){ }

      //upload video
      try{
        var files=json.decode(post.var1.toString());
        for(var file in files) {
          if (file["video"]!="") {
            var stream = http.ByteStream(
                DelegatingStream.typed(File(file["video"]).openRead()));
            var length = await File(file["video"]).length();
            var multipartFile = http.MultipartFile(
                "video", stream, length,
                filename: File(file["video"]).path.split('/').last);
            newList.add(multipartFile);
          }
          request.files.addAll(newList);
        }
      }catch(e){ }


      request.headers['Content-Type'] = 'application/json';
      request.headers['Authentication'] = '$token';
      request.fields['username'] = '$username';
      request.fields['price'] = post.user;
      request.fields['content'] = post.content;
      request.fields['uid'] = post.uid;

      var respond = await request.send();
      if (respond.statusCode == 200) {
        var responseData = await respond.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var jsondata = json.decode(responseString);
        if (jsondata["status"].toString() == "success") {
          setState(() {
            error = false;
            errormsg = jsondata["response_message"];
          });
        } else {
          setState(() {
            error = true;
            errormsg = jsondata["response_message"];
          });
        }
      } else {
        setState(() {
          error = true;
          errormsg = language_string.Language.network_error;
        });
      }
    } catch (e) {
      setState(() {
        error = true;
        errormsg = language_string.Language.network_error;
      });
    }

    if(error!) {
      Snackbar().show(context, ContentType.failure, language_string.Language.error, errormsg!);
    }else{
      Snackbar().show(context, ContentType.success, language_string.Language.success, errormsg!);
    }
    Navigator.pop(context);
    Navigator.pop(context);

  }




  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: kWhite,
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          backAppbar(context, "Add New Post"),
          SizedBox(
            height: 20,
          ),
          FutureBuilder<void>(
            future: retrieveLostData(),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const SizedBox();
                case ConnectionState.done:
                  return SizedBox();
                case ConnectionState.active:
                  if (snapshot.hasError) {
                    return SizedBox();
                  } else {
                    return const SizedBox();
                  }
              }
            },
          ),
          Padding(
            padding:
            EdgeInsets.only(
                top: 10, right: 20, left: 20),
            child: TextField(
              minLines: 6,
              controller: controller,
              maxLines: 20,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "Write something...",
                isDense: true,
                // now you can customize it here or add padding widget
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  content = value;
                });
              },
            ),
          ),
          images.length ==1 ?
          Container(
            padding: EdgeInsets.all(15),
            constraints: BoxConstraints(
                maxHeight: 300
            ),
            child: InkWell(
              child: Image.file(File(images.first.url),
                fit: BoxFit.cover,
              ),
            ),
          ) :
          images.isNotEmpty?
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(left: 10, top: 2, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhotoGrid(
                  imageUrls: images,
                  onImageClicked: (i) => print('Image $i was clicked!'),
                  onExpandClicked: () => print('Expand Image was clicked'),
                  maxImages: 4,
                ),
              ],
            ),
          ) : SizedBox(),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: 40, top: 20, right: 40),
            padding: EdgeInsets.all(10),
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: kSecondary
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async{
                    if(audioPath.isEmpty && videoPath.isEmpty){
                      if(images.length<4) {
                        if(Platform.isAndroid && await getSdkVersion() <= 30){
                          FilePickerResult? res = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['jpg', 'png', 'jpeg'],
                          );
                        if (res != null) {
                          setState(() {
                            images.add(new TimelineImagesModel(url: res.files.first.path!));
                          });
                        }
                        }else{
                          XFile? res = await _picker.pickImage(source: ImageSource.gallery);
                          if (res != null) {
                            setState(() {
                              images.add(new TimelineImagesModel(url: res.path));
                            });
                          }
                        }
                      }else{
                        Toast.show("Maximum of 4 images", duration: Toast.lengthLong, gravity: Toast.bottom);
                      }
                    }else{
                      Toast.show("Only 1 media type is allowed.", duration: Toast.lengthLong, gravity: Toast.bottom);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 20,),
                      SizedBox(width: 5,),
                      Text(
                        "Attach Images to Post",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                /*
                SizedBox(width: 10,),
                InkWell(
                  onTap: () async{
                     if(images.isEmpty && audioPath.isEmpty){
                       if(Platform.isAndroid && await getSdkVersion() <= 30){
                         FilePickerResult? res = await FilePicker.platform.pickFiles(
                           type: FileType.custom,
                           allowedExtensions: ['mp4', '3gp'],
                         );
                         if (res != null) {
                           setState(() {
                             videoPath=res.files.first.path!;
                           });
                         }
                       }else{
                         final ImagePicker _picker = ImagePicker();
                         XFile? res = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: Duration(minutes: 1));
                         if (res != null) {
                           setState(() {
                             videoPath=res.path;
                           });
                         }
                       }
                     }else{
                       Toast.show("Only 1 media type is allowed.", duration: Toast.lengthLong, gravity: Toast.bottom);
                     }

                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_collection, size: 20,),
                      SizedBox(width: 5,),
                      Text(
                        "Select Video",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                videoPath.isEmpty && images.isEmpty ?
                SocialMediaRecorder(
                  backGroundColor: kSecondary,
                  recordIcon: Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: Icon(Icons.mic_rounded, size: 20),
                  ),
                  sendRequestFunction: (soundFile) {
                    setState(() {
                      audioPath=soundFile.path;
                    });
                  },
                  encode: AudioEncoderType.AAC,
                ) :
                InkWell(
                  onTap: () async{
                       Toast.show("Only 1 media type is allowed.", duration: Toast.lengthLong, gravity: Toast.bottom);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mic_rounded, size: 20,),
                      SizedBox(width: 5,),
                      Text(
                        "VN",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                */
              ],
            ),
          ),
          Padding(
              padding: EdgeInsets.only(
                  top: 20, right: 20, left: 20, bottom: 25),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: kPrimaryDarkColor,
                  minimumSize: Size.fromHeight(
                      40), // fromHeight use double.infinity as width and 40 is the height
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(
                      color: kSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  post();
                },
              )),
        ],
      ),
      ),
    );
  }


  Future<void> retrieveLostData() async {
    try{
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) {
        return;
      }
      if (response.file != null) {
        if (response.type == RetrieveType.video) {
          setState(() {
            videoPath = response.file!.path;
          });
        } else if (response.type == RetrieveType.image) {
          {
            setState(() {
              if (response.files == null) {
                images.add(new TimelineImagesModel(url: response.file!.path));
              }
            });
          }
        } else {}
      }
    }catch(e){}

  }


}
