import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterproject/app_state.dart';
import 'package:flutterproject/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ProfileImagePage extends StatefulWidget {
  const ProfileImagePage({super.key});

  @override
  State<ProfileImagePage> createState() => _ProfileImagePageState();
}

class _ProfileImagePageState extends State<ProfileImagePage> {
  late String email, userId;
  late bool isLoggedIn = false;
  bool isLoading = true;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String profileImageUrl = '${url}uploads/default.png';

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    email = appState.userDetails!['email'];
    userId = appState.userDetails!['_id'];
    isLoggedIn = appState.isLoggedIn;
    if (isLoggedIn) {
      fetchUserProfile();
    } else {
      _showToast("You're not logged in!", Colors.black, Colors.white);
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      var response = await http.get(
          Uri.parse('$getProfileUrl?email=${Uri.encodeComponent(email)}'),
          headers: {"Content-Type": "application/json"});

      var jsonUserResponse = jsonDecode(response.body);

      if (jsonUserResponse['status'] == true &&
          jsonUserResponse.containsKey('profile')) {
        setState(() {
          profileImageUrl = url + jsonUserResponse['profile']['profileImage'];
          isLoading = false;
        });
      } else {
        _showToast("Profile not found!", Colors.black, Colors.white);
      }
    } catch (error) {
      _showToast(
          "Error while loading profile! ${error}", Colors.black, Colors.white);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        print(_imageFile!.path);
      }); //_cropImage(pickedFile);
    } else {
      _showToast("No image selected !", Colors.black, Colors.white);
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      _showToast("Please select an image", Colors.black, Colors.white);
      return;
    }

    try {
      var request = http.MultipartRequest('POST',
          Uri.parse('$uploadImageUrl?email=${Uri.encodeComponent(email)}'));

      if (kIsWeb) {
        final bytes = await _imageFile!.readAsBytes();

        String? mimeType = _imageFile!.mimeType;
        String fileName = _imageFile!.name;

        if (mimeType == 'image/jpeg') {
          fileName += '.jpg';
        } else if (mimeType == 'image/png') {
          fileName += '.png';
        }
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: fileName,
        ));
      } else {
        if (_imageFile != null && _imageFile!.path.isNotEmpty) {
          request.files.add(
            await http.MultipartFile.fromPath(
              "image",
              _imageFile!.path,
            ),
          );
        } else {
          _showToast("Image file path is invalid", Colors.black, Colors.white);
          return;
        }
      }

      var response = await request.send();
      print(response);
      if (response.statusCode == 200) {
        _showToast(
            "Profile Image Updated successfully !", Colors.black, Colors.white);
        Navigator.pushReplacementNamed(context, '/profile');
      } else {
        _showToast("Profile Image not updated !", Colors.black, Colors.white);
        Navigator.pushReplacementNamed(context, '/profile');
      }
    } catch (error) {
      _showToast(
          "Error while uploading image on server", Colors.black, Colors.white);
    }
  }

  // Future<void> _cropImage(XFile image) async {
  //   final croppedFile = await ImageCropper().cropImage(
  //     sourcePath: image.path,
  //     aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
  //     uiSettings: [
  //       AndroidUiSettings(
  //         toolbarTitle: 'Adjust Image',
  //         toolbarColor: Colors.blue,
  //         toolbarWidgetColor: Colors.white,
  //         hideBottomControls: true,
  //       ),
  //       IOSUiSettings(
  //         title: 'Adjust Image',
  //       ),
  //     ],
  //   );

  //   if (croppedFile != null) {
  //     setState(() {
  //       _imageFile = croppedFile as XFile?;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Image'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: _imageFile != null
                                ? NetworkImage(_imageFile!.path)
                                : NetworkImage(profileImageUrl)
                                    as ImageProvider,
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _uploadImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 40.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Upload",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showToast(String message, Color bgColor, Color textColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: bgColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }
}
