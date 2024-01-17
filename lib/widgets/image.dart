import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_app/widgets/snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants.dart';
import '../radius.dart';
import 'material.dart';

Widget cacheNetworkImage({
  required String imgUrl,
  required BoxFit fit,
  BoxShape shape = BoxShape.rectangle,
  required double width,
  required double height,

}) =>
    CachedNetworkImage(
      imageUrl: '$imgUrl',
      imageBuilder: (context, imageProvider) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            shape: shape,
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
            ),
          ),
        );
      },
      placeholder: (context, url) => Container(
        height: height,
        width: width,
        child: Center(child: CupertinoActivityIndicator()),
      ),
      errorWidget: (context, url, error) {
        return Container(
          height: height,
          width: width,
          child: Center(
            child: img.Image.asset('assets/logo.png'),
          ),
        );
      },
    );

class ImagePreview{
String _localPath="";
bool loading=false;
late TargetPlatform? platf;
void preview(context, String imgUrl, setState) {
  showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, state) {
              return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CachedNetworkImage(
                            imageUrl: imgUrl!,
                            fit: BoxFit.cover,
                          ),
                          /*
                          Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.40,
                            padding: EdgeInsets.only(
                                bottom: 2, left: 2, right: 2, top: 2),
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: circularRadius(AppRadius
                                    .border12),
                                color: kPrimaryColor
                            ),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              onPressed: () async {
                                bool permission = await _checkPermission();
                                if (permission) {
                                  setState(() {
                                    loading=true;
                                  });
                                  await _prepareSaveDir();
                                  try {
                                    await Dio().download(imgUrl,
                                        _localPath + "/" + "Cointry_${imgUrl.split('/').last}");
                                    Snackbar().show(
                                        context, ContentType.failure, Language.error,
                                        "File successfully downloaded in this path");
                                  } catch (e) {
                                    Snackbar().show(
                                        context, ContentType.failure, Language.error,
                                        "File successfully downloaded in this path");
                                  }
                                  setState(() {
                                    loading=false;
                                  });

                                } else {
                                  Snackbar().show(
                                      context, ContentType.failure, Language.error,
                                      "Please give permission to download file");
                                }
                              },
                              child: loading?
                              SizedBox(
                                height:20, width:20,
                                child: CircularProgressIndicator(
                                  backgroundColor: kSecondary,
                                  valueColor: AlwaysStoppedAnimation<Color>(yellow100),
                                ),
                              ) : Text(
                                "Save",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: kSecondary,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          */
                        ],
                      )));
            });
      },
      context: context);
}


  Future<bool> _checkPermission() async {
    if (platf== TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await findLocalPath())!;
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String?> findLocalPath() async {
    if (platf == TargetPlatform.android) {
      return "/sdcard/download/";
    } else {
      var directory = await getApplicationDocumentsDirectory();
      return '${directory.path}${Platform.pathSeparator}Download';
    }
  }



}
