import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/api/apis.dart';
import 'package:chat/helper/dialogs.dart';
import 'package:chat/main.dart';
import 'package:chat/models/chat_user.dart';
import 'package:chat/screens/auth/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});
  final ChatUser user;

  @override
  State<ProfileScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: Text('Profile'),
          ),

          // FLoating action to logout the user
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(
                backgroundColor: Colors.redAccent,
                onPressed: () async {
                  //for showing progress dialog
                  Dialogs.showLoading(context);

                  // await APIs.updateActiveStatus(false);

                  //sign out from app
                  await APIs.auth.signOut().then((value) async {
                    await GoogleSignIn().signOut().then((value) {
                      //for hiding progress dialog
                      Navigator.pop(context);

                      //for moving to home screen
                      Navigator.pop(context);

                      // APIs.auth = FirebaseAuth.instance;

                      //replacing home screen with login screen
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                    });
                  });
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout')),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.height * 0.05),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: mq.height * 0.02),
                reverse: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // for adding some space
                    SizedBox(
                      width: mq.width,
                      height: mq.height * 0.03,
                    ),

                    // user profile picture
                    Stack(
                      children: [
                        _image != null
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * 0.1),
                                child: Image.file(
                                  File(_image!),
                                  fit: BoxFit.cover,
                                  height: mq.height * 0.2,
                                  width: mq.height * 0.2,
                                ))
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * 0.1),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  height: mq.height * 0.2,
                                  width: mq.height * 0.2,
                                  imageUrl: _image != null
                                      ? _image!
                                      : widget.user.image,
                                  errorWidget: (_, __, ___) => CircleAvatar(
                                    child: Icon(CupertinoIcons.person),
                                  ),
                                ),
                              ),

                        //edit image button
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            elevation: 1,
                            onPressed: () {
                              _showBottomSheet();
                            },
                            shape: const CircleBorder(),
                            color: Colors.white,
                            child: const Icon(Icons.edit, color: Colors.blue),
                          ),
                        )
                      ],
                    ),

                    // for adding some space
                    SizedBox(
                      width: mq.width,
                      height: mq.height * 0.03,
                    ),

                    // user email label
                    Text(widget.user.email,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 16)),

                    // for adding some space
                    SizedBox(height: mq.height * .05),

                    // name input field
                    TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => APIs.me.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          hintText: 'eg. Happy Singh',
                          label: Text('Name')),
                    ),

                    // for adding some space
                    SizedBox(height: mq.height * .02),

                    // about input field
                    TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => APIs.me.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: const InputDecoration(
                          prefixIcon:
                              Icon(Icons.info_outline, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          hintText: 'eg. Feeling Happy',
                          label: Text('About')),
                    ),

                    // for adding some space
                    SizedBox(height: mq.height * .05),

                    // update profile button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          minimumSize: Size(mq.width * .5, mq.height * .06)),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          await APIs.updateUserInfo().then((value) {
                            Dialogs.showSnackbar(
                                context, 'Profile Updated Successfully!');
                          });
                        }
                      },
                      icon: const Icon(Icons.edit, size: 28),
                      label:
                          const Text('UPDATE', style: TextStyle(fontSize: 16)),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }

  // bottom sheet for picking a profile picture for user
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              //pick profile picture label
              const Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

              //for adding some space
              SizedBox(height: mq.height * .02),

              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePicture(File(_image!));

                          // for hiding bottom sheet
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/add_image.png')),

                  //take picture from camera button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(
                        mq.width * .3,
                        mq.height * .15,
                      ),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      // Pick an Image
                      final xFile = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 80,
                      );

                      if (xFile != null) {
                        log('Image Path: ${xFile.path}');
                        setState(() {
                          _image = xFile.path;
                        });

                        await APIs.updateProfilePicture(File(_image!));

                        // for hiding bottom sheet
                        if (mounted) Navigator.pop(context);
                      }
                    },
                    child: Image.asset(
                      'assets/camera.png',
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }
}
