import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import '../../components/default_button.dart';
import '../../constants.dart';
import '../../language.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import '../../widgets/snackbar.dart';

class KycScreen extends StatefulWidget {

  @override
  _KycUIState createState() => _KycUIState();
}


class _KycUIState extends State<KycScreen> {

  String status="", email="", username="", errorText="", rejected_reason="";
  int count=0;
  var cameras;
  bool show=false;
  var firstCamera;

  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      status = prefs.getString("kyc_status")!;
      rejected_reason = prefs.getString("rejected_reason")!;
      email = prefs.getString("email")!;
    });

  }


  Future<void> main() async {
    // Obtain a list of the available cameras on the device.
    cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    firstCamera = cameras[1];
  }


  @override
  void initState() {
    super.initState();
    getuser();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      firstCamera = cameras[1];
    });
    main();
  }



  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    if(status.contains("Rejected") && !show){
      show=true;
      Snackbar().show(context, ContentType.failure, Language.kyc_rejected, rejected_reason);
    }
    return Scaffold(
      backgroundColor: kWhite,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              backAppbar(context, Language.kyc_title),
              SizedBox(
                height: 20,
              ),
              status.contains("Approved") ?
              Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: kSecondary,
                        borderRadius: BorderRadius.all(Radius.circular(10.0))
                    ),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20,),
                        Center(
                          child: SizedBox(
                            height: 200,
                            width: 200,
                            child: Image.asset("assets/images/kyc_pending.png"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Align(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.all(20),
                          alignment: Alignment.center,
                          child: Text(
                            'Your KYC Request has been approved. Welcome Onboard!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                    ),
                  )
                ],
              ) :
              status.contains("Pending") ?
              Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: kSecondary,
                        borderRadius: BorderRadius.all(Radius.circular(10.0))
                    ),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20,),
                        Center(
                          child: SizedBox(
                            height: 200,
                            width: 200,
                            child: Image.asset("assets/images/kyc_pending.png"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(20),
                      child: Text(
                        Language.kyc_under_review,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ) :
              Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: 10,
                        left: 16,
                        right: 16),
                    child: Image.asset('assets/images/kyc.png', width: 300, height: 300),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(20),
                      child: Text(
                        Language.take_selfie,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(20
                    ),
                    child: DefaultButton(
                      text: status.contains("Start") ? Language.start_kyc : Language.resubmit_kyc,
                      press: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TakePictureScreen(
                                camera: firstCamera,
                              ),
                            ));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: kWhite,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              backAppbar(context, Language.kyc_step1),
              SizedBox(
                height: 20,
              ),
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the Future is complete, display the preview.
                    return CameraPreview(_controller);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.loading,
            title: Language.loading,
            text: Language.scanning_selfie,
          );
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            if (!mounted) return;
            Navigator.pop(context);
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FORMScreen(
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}


class Document{
  const Document(this.name, this.id);
  final String name;
  final String id;
}

class FORMScreen extends StatefulWidget {
  FORMScreen({required this.imagePath});
  final String imagePath;
  @override
  _FORMUIState createState() => _FORMUIState();
}

class Item{
  Item(this.name);
  final String name;
}

class _FORMUIState extends State<FORMScreen> {
  String errormsg="", first_name="", last_name="", middle_name="", path="";
  bool error=false, showprogress=false;
  List<XFile>? _imageFileList;

  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }
  Document document=Document(
      Language.select_document_type, Language.select_document_type
  );
  List<Document> documents=<Document>[
    const Document('National ID CARD', 'id'),
    const Document('Voters Card', 'voters_card'),
    const Document('PASSPORT', 'passport'),
  ];

  dynamic _pickImageError;
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  Future<void> _onImageButtonPressed(ImageSource source,
      {BuildContext? context, bool isMultiImage = false}) async {

    await _displayPickImageDialog(
            (double? maxWidth, double? maxHeight, int? quality) async {
          try {
            final XFile? pickedFile = await _picker.pickImage(
              source: source,
              maxWidth: maxWidth,
              maxHeight: maxHeight,
              imageQuality: quality,
            );
            setState(() {
              _setImageFileListFromFile(pickedFile);
            });
          } catch (e) {
            setState(() {
              _pickImageError = e;
            });
          }
        });
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _displayPickImageDialog(OnPickImageCallback onPick) async {
    onPick(600, 200, 100);
  }


  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFileList != null) {
      return SizedBox(
        height: 200,
        width: 200,
        child: kIsWeb
            ? Image.network(_imageFileList![0].path)
            : Image.file(File(_imageFileList![0].path)),
      );

    } else if (_pickImageError != null) {
      return Text(
        '${Language.select_image_error}: $_pickImageError',
        textAlign: TextAlign.center,
        style: TextStyle(color: yellow100),
      );
    } else {
      return Text(
        Language.select_image_file,
        textAlign: TextAlign.center,
        style: TextStyle(color: yellow100),
      );
    }
  }

  Widget _handlePreview() {
    return _previewImages();
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (response.files == null) {
          _setImageFileListFromFile(response.file);
        } else {
          _imageFileList = response.files;
        }
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  List<Item> countries=<Item>[
    Item('Select Country'),
    Item('Algeria'),
    Item('Angola'),
    Item('Benin'),
    Item('Botswana'),
    Item('Burkina Faso'),
    Item('Burundi'),
    Item('Cabo Verde'),
    Item('Cameroon'),
    Item('Central African Republic'),
    Item('Chad'),
    Item('Comoros'),
    Item('Congo, Democratic Republic of the Congo'),
    Item("Republic of the Cote d'Ivoire"),
    Item('Djibouti'),
    Item('Egypt'),
    Item('Equatorial Guinea'),
    Item('Eritrea'),
    Item('Eswatini'),
    Item('Ethiopia'),
    Item('Gabon'),
    Item('Gambia'),
    Item('Ghana'),
    Item('Guinea'),
    Item('Guinea-Bissau'),
    Item('Kenya'),
    Item('Lesotho'),
    Item('Liberia'),
    Item('Libya'),
    Item('Madagascar'),
    Item('Malawi'),
    Item('Mali'),
    Item('Mauritania'),
    Item('Mauritius'),
    Item('Morocco'),
    Item('Mozambique'),
    Item('Namibia'),
    Item('Niger'),
    Item('Nigeria'),
    Item('Rwanda'),
    Item('Sao Tome and Principe'),
    Item('Senegal'),
    Item('Seychelles'),
    Item('Sierra Leone'),
    Item('Somalia'),
    Item('South Africa'),
    Item('Somalia'),
    Item('South Sudan'),
    Item('Sudan'),
    Item('Tanzania'),
    Item('Togo'),
    Item('Tunisia'),
    Item('Uganda'),
    Item('Zambia'),
    Item('Zimbabwe'),
  ];

  Item? country;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: kWhite,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              backAppbar(context, Language.kyc_form),
              SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: kSecondary,
                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20,),
                    Center(
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: Image.file(File(widget.imagePath)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: kSecondary,
                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                ),
                child: Column(
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                          hintText: Language.first_name,
                          hintStyle: TextStyle(color: kPrimary, fontSize: 15.0)
                      ),
                      onChanged: (value){
                        first_name=value;
                      },
                    ),
                    SizedBox(
                        height:20
                    ),
                    TextField(
                      decoration: InputDecoration(
                          hintText: Language.last_name,
                          hintStyle: TextStyle(color: kPrimary, fontSize: 15.0)
                      ),
                      onChanged: (value){
                        last_name=value;
                      },
                    ),
                    SizedBox(
                        height:20
                    ),
                    TextField(
                      decoration: InputDecoration(
                          hintText: Language.middle_name,
                          hintStyle: TextStyle(color: kPrimary, fontSize: 15.0)
                      ),
                      onChanged: (value){
                        middle_name=value;
                      },
                    ),
                    SizedBox(
                        height:20
                    ),
                    Container(
                        alignment: Alignment.center,
                        height: 60,
                        child: DropdownButtonFormField<Item>(
                          isExpanded: true,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              hintText: Language.select_country,
                              labelText: Language.select_country,
                              hintStyle: TextStyle(color: Colors.grey[800], fontSize: 2),
                              fillColor: kSecondary
                          ),
                          hint: Text(Language.select_country),
                          value: country,
                          onChanged: (Item? value){
                            country = value;
                          },
                          items: countries.map((Item item){
                            return DropdownMenuItem<Item>(value: item, child: Container(
                              width: MediaQuery.of(context).size.width-20,
                              height: 40,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                color: kSecondary,
                                borderRadius: BorderRadius.circular(10),),
                              child: Text(item.name, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
                            ),);
                          }).toList(),
                        )
                    ),
                    SizedBox(height: 20,),
                    Container(
                      alignment: Alignment.center,
                      height: 60,
                      child: DropdownButtonFormField<Document>(
                        isExpanded: true,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            hintText: Language.select_document_type,
                            labelText: Language.select_document_type,
                            hintStyle: TextStyle(color: Colors.grey[800], fontSize: 2),
                            fillColor: kSecondary
                        ),
                        hint: Text(Language.select_document_type),
                        value: document,
                        onChanged: (Document? value){
                          setState(() {
                            document=value!;
                          });
                        },
                        items: documents.map((Document cont){
                          return DropdownMenuItem<Document>(value: cont, child: Container(
                            width: MediaQuery.of(context).size.width-20,
                            height: 40,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              color: kSecondary,
                              borderRadius: BorderRadius.circular(10),),
                            child: Text(cont.name, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
                          ),);
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              InkWell(
                onTap: (){
                  _onImageButtonPressed(ImageSource.gallery, context: context);
                },
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: kSecondary,
                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 10,),
                      Center(
                        child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
                            ? FutureBuilder<void>(
                          future: retrieveLostData(),
                          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                              case ConnectionState.waiting:
                                return Text(
                                  Language.select_image_file,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: yellow100),
                                );
                              case ConnectionState.done:
                                return _handlePreview();
                              default:
                                if (snapshot.hasError) {
                                  return Text(
                                    '${Language.select_image_error}: ${snapshot.error}}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: yellow100),
                                  );
                                } else {
                                  return Text(
                                    Language.select_image_file,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: yellow100),
                                  );
                                }
                            }
                          },
                        )
                            : _handlePreview(),
                      ),
                    ],
                  ),
                ),
              ),
              _imageFileList == null ?
              Container() :
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                child: SizedBox(
                  height: 50, width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (){
                      if(!showprogress)
                        saveImage(File(_imageFileList![0].path), File(widget.imagePath), context);
                    },
                    child: Text(Language.proceed, style: TextStyle(fontSize: 20),),
                    //button corner radius
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }

  Future saveImage(File imageFile, File selfie, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token=prefs.getString("token");
    String? email=prefs.getString("email");
    if(_imageFileList![0].path.isEmpty){
      setState(() {
        showprogress = false;
        error = true;
        errormsg = Language.select_image;
      });
    }else if(first_name.isEmpty){
      setState(() {
        showprogress = false;
        error = true;
        errormsg = Language.enter_firstname;
      });
    }else if(last_name.isEmpty){
      setState(() {
        showprogress = false;
        error = true;
        errormsg = Language.enter_lastname;
      });
    }else if(country?.name == null){
      setState(() {
        showprogress = false;
        error = true;
        errormsg = Language.select_country;
      });
    }else if(document.name==Language.select_document_type){
      setState(() {
        showprogress = false;
        error = true;
        errormsg = Language.select_document_type;
      });
    }else {
      setState(() {
        showprogress = true;
        error = false;
      });
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: Language.loading,
        text: Language.processing,
      );
      try {
        var stream = new http.ByteStream(
            DelegatingStream.typed(selfie.openRead()));
        var stream2 = new http.ByteStream(
            DelegatingStream.typed(imageFile.openRead()));

        var length = await selfie.length();
        var length2 = await imageFile.length();

        var uri = Uri.parse(Strings.url + "/upload-kyc");
        var request = new http.MultipartRequest("POST", uri);

        var multipartFile = new http.MultipartFile(
            "selfie", stream, length, filename: basename(selfie.path));

        var multipartFile2 = new http.MultipartFile(
            "image", stream2, length2, filename: basename(imageFile.path));

        request.files.add(multipartFile);
        request.files.add(multipartFile2);
        request.headers['Content-Type'] = 'application/json';
        request.headers['Authentication'] = '$token';
        request.fields['token'] = token!;
        request.fields['email'] = email!;
        request.fields['first_name'] = first_name;
        request.fields['last_name'] = last_name;
        request.fields['country'] = "${country?.name}";
        request.fields['document'] = "${document?.id}";
        request.fields['middle_name'] = "${middle_name}";

        var respond = await request.send();
        try{
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
          errormsg = e.toString() + Language.network_error;
        });
      }
    }

    if(error!) {
      if(!showprogress){
        Snackbar().show(context, ContentType.failure, Language.error, errormsg!);
      }else {
        Navigator.pop(context);
        Snackbar().show(context, ContentType.failure, Language.error, errormsg!);
      }
    }else{
      prefs.setString("kyc_status", "Pending");
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      Snackbar().show(context, ContentType.success, Language.success, errormsg!);
    }
    setState(() {
      showprogress = false;
    });
  }


}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);
