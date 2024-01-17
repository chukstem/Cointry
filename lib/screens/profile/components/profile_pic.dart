import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info/device_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../../../constants.dart';
import '../../../language.dart';
import '../../../strings.dart';

class ProfilePic extends StatefulWidget {

  @override
  _ProfilePic createState() => _ProfilePic();
}

class _ProfilePic extends State<ProfilePic> {
  String avatar="", cover="", token="", username="";
  bool showprogress=false,  showprogress2=false, error=false, isCover=false;
  String errormsg="", path="";
  final ImagePicker _picker = ImagePicker();

  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      avatar = prefs.getString("avatar")!;
      cover = prefs.getString("cover")!;
      username = prefs.getString("username")!;
    });
  }

  Future<int> getSdkVersion() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
    return androidInfo.version.sdkInt;
  }


  @override
  void initState() {
    super.initState();
    getuser();
  }

  @override
  void dispose() {
    super.dispose();
  }


  Future<void> retrieveLostData() async {
    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) {
        return;
      }
      if (response.file != null) {
        if (response.type == RetrieveType.image && response.files == null) {
          if(isCover){
            saveCover(File(response.file!.path), context);
          }else{
            saveImage(File(response.file!.path), context);
          }
        }
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      width: MediaQuery.of(context).size.width*0.90,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
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
          InkWell(
            onTap: () async {
              setState(() {
                isCover=true;
              });
              if(Platform.isAndroid && await getSdkVersion() <= 30){
                FilePickerResult? res = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['jpg', 'png', 'jpeg'],
                );
                if (res != null) {
                  setState(() {
                    saveCover(File(res.files.first.path!), context);
                  });
                }
              }else{
                XFile? res = await _picker.pickImage(source: ImageSource.gallery);
                if (res != null) {
                  setState(() {
                    saveCover(File(res.path), context);
                  });
                }
              }
            },
            child: Container(
              height: 200,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40.0),
                child: showprogress?
                SizedBox(
                  height:20, width:20,
                  child: CircularProgressIndicator(
                    backgroundColor: kSecondary,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ) : Padding(
                  padding: EdgeInsets.all(1), // Border radius
                  child: CachedNetworkImage(
                    height: 200,
                    width: 200,
                    imageUrl: cover,
                    fit: BoxFit.cover, ), ),
              ),
            ),
          ),
          Positioned(
            left: -6,
            bottom: -6,
            child: SizedBox(
              height: 120,
              width: 120,
              child: InkWell(
                onTap: () async {
                  setState(() {
                    isCover=false;
                  });
                  if(Platform.isAndroid && await getSdkVersion() <= 30){
                    FilePickerResult? res = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'png', 'jpeg'],
                    );
                    if (res != null) {
                      setState(() {
                        saveImage(File(res.files.first.path!), context);
                      });
                    }
                  }else{
                    XFile? res = await _picker.pickImage(source: ImageSource.gallery);
                    if (res != null) {
                      setState(() {
                        saveImage(File(res.path), context);
                      });
                    }
                  }
                },
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: kSecondary,
                  child: showprogress2?
                  SizedBox(
                    height:20, width:20,
                    child: CircularProgressIndicator(
                      backgroundColor: kSecondary,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ) : Padding(
                    padding: EdgeInsets.all(2), // Border radius
                    child: ClipOval(child: CachedNetworkImage(
                      height: 120,
                      width: 120,
                      imageUrl: avatar,
                      fit: BoxFit.cover, ), ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future saveImage(File imageFile, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    token = prefs.getString("token")!;

    if(imageFile==null || imageFile.path.isEmpty){
      setState(() {
        showprogress2 = false;
        error = true;
        errormsg = Language.take_capture;
      });
    }else {
      setState(() {
        showprogress2 = true;
        error = false;
      });

      try {
        var stream = http.ByteStream(
            DelegatingStream.typed(imageFile.openRead()));

        var length = await imageFile.length();

        var uri = Uri.parse("${Strings.url}/upload_avatar");
        var request = http.MultipartRequest("POST", uri);
        request.headers['Content-Type'] = 'application/json';
        request.headers['Authentication'] = '$token';

        var multipartFile = http.MultipartFile(
            "file", stream, length, filename: imageFile.path.split('/').last);

        request.files.add(multipartFile);
        request.fields['username'] = username!;

        var respond = await request.send();
        try{
          if (respond.statusCode == 200) {
            var responseData = await respond.stream.toBytes();
            var responseString = String.fromCharCodes(responseData);
            var jsondata = json.decode(responseString);
            if (jsondata["status"].toString() == "success") {
              prefs.setString("avatar", jsondata["image_url"]);
              setState(() {
                error = false;
                avatar=jsondata["image_url"];
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
              errormsg = Language.network_error;
            });
          }
        } catch (e) {
          setState(() {
            error = true;
            errormsg = Language.network_error;
          });
        }
      } catch (e) {
        setState(() {
          error = true;
          errormsg = Language.network_error;
        });
      }
    }

    Toast.show(errormsg, duration: Toast.lengthLong, gravity: Toast.bottom);
    setState(() {
      showprogress2 = false;
    });
  }

  Future saveCover(File imageFile, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    token = prefs.getString("token")!;

    if(imageFile==null || imageFile.path.isEmpty){
      setState(() {
        showprogress = false;
        error = true;
        errormsg = Language.take_capture;
      });
    }else {
      setState(() {
        showprogress = true;
        error = false;
      });

      try {
        var stream = http.ByteStream(
            DelegatingStream.typed(imageFile.openRead()));

        var length = await imageFile.length();

        var uri = Uri.parse("${Strings.url}/upload_cover");
        var request = http.MultipartRequest("POST", uri);
        request.headers['Content-Type'] = 'application/json';
        request.headers['Authentication'] = '$token';

        var multipartFile = http.MultipartFile(
            "file", stream, length, filename: imageFile.path.split('/').last);

        request.files.add(multipartFile);
        request.fields['username'] = username!;

        var respond = await request.send();
        try{
          if (respond.statusCode == 200) {
            var responseData = await respond.stream.toBytes();
            var responseString = String.fromCharCodes(responseData);
            var jsondata = json.decode(responseString);
            if (jsondata["status"].toString() == "success") {
              prefs.setString("cover", jsondata["image_url"]);
              setState(() {
                error = false;
                cover=jsondata["image_url"];
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
              errormsg = Language.network_error;
            });
          }
        } catch (e) {
          setState(() {
            error = true;
            errormsg = Language.network_error;
          });
        }
      } catch (e) {
        setState(() {
          error = true;
          errormsg = Language.network_error;
        });
      }
    }

    Toast.show(errormsg, duration: Toast.lengthLong, gravity: Toast.bottom);
    setState(() {
      showprogress = false;
    });
  }

}
