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

//선택한 이미지 파일을 저장하는 역할
class _AddImageState extends State<AddImage>
{

  File? pickedImage;

  //ImagePicker를 사용해 갤러리에서 이미지를 선택하고, 선택한 이미지를 변수에 저장하는 역할
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
    //addImageFunc 함수 호출을 통해 선택한 이미지 전달
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
          //pickedImage 변수가 null이 아닐 경우, 선택한 이미지를 배경 이미지로 설정
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.green[300],
            backgroundImage: pickedImage !=null ? FileImage(pickedImage!) : null,
          ),
          const SizedBox(
            height: 10,
          ),

          //이미지 선택 버튼으로써 클릭 시 _pickImage 메서드 호출
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

          //이미지 업로드를 완료하고 창을 닫는 버튼
          //1. 클릭 시 파이어베이스 스토리지에 이미지 업로드
          //2. 이미지의 다운로드 URL을 파이어스토어에 저장한 다음, 창 닫기
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
