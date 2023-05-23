import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AddImage extends StatefulWidget {
  const AddImage(this.addImageFunc,{Key? key}) : super(key: key);

  final Function(File pickedImage) addImageFunc;

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage>
{

  File? pickedImage;

  void _pickImage() async{
    final imagePicker = ImagePicker();
    final pickedImageFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      maxHeight: 150
    );
    setState(() {
      if(pickedImageFile != null){
        pickedImage = File(pickedImageFile.path);
      }
    });
    widget.addImageFunc(pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      width: 300,
      height: 300,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.green[300],
            backgroundImage: pickedImage !=null ? FileImage(pickedImage!) : null,
          ),
          const SizedBox(
            height: 10,
          ),
          OutlinedButton.icon(
            onPressed: (){
              _pickImage();
            },
            icon: Icon(Icons.image),
            label: Text('Add image'),
          ),
          const SizedBox(
            height: 80,
          ),
          TextButton.icon(
            onPressed: () async{

              final refImage = FirebaseStorage.instance.ref().child('picked_image')
                  .child(FirebaseAuth.instance.currentUser!.uid + '.png');

              await refImage.putFile(pickedImage!);
              final url = await refImage.getDownloadURL();

              await FirebaseFirestore.instance.collection('user')
                  .doc(FirebaseAuth.instance.currentUser!.uid).update({
                'picked_image' : url
              });

              Navigator.pop(context);
            },
            icon: Icon(Icons.close),
            label: Text('Close'),
          ),
        ],
      ),
    );
  }
}
