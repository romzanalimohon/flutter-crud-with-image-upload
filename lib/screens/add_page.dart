import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



import 'package:async/async.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path/path.dart';
class AddTodoPage extends StatefulWidget {
  final Map? user;
  const AddTodoPage({Key? key, this.user}) : super(key: key);

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isEdit = false;

  File? image;
  final _picker = ImagePicker();
  bool showSpinner = false;

  Future getImage() async{
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if(pickedFile != null){
      image = File(pickedFile.path);
      setState(() {

      });
    }else{
      print('no image selected');
    }
  }
  @override
  void initState() {
    super.initState();
    final user = widget.user;
    if(user != null){
      isEdit = true;
      final username = user['username'];
      final password = user['password'];
      usernameController.text = username;
      passwordController.text = password;
    }
  }


  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEdit? 'Edit ' : 'Add ',
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(hintText: 'title'),
            ),
            SizedBox(height: 20,),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(hintText: 'description'),
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 8,
            ),
            SizedBox(height: 20,),


            GestureDetector(
              onTap: getImage,
              child: Container(
                child: image == null ?
                Center(child: Text('pick image'),)
                    : Container(
                  child: Center(
                    child: Image.file(
                      File(image!.path).absolute,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),


            SizedBox(height: 20,),
            ElevatedButton(
                onPressed: isEdit? updateData : submitData,
                child: Text(
                  isEdit? 'update' : 'submit',
                )
            ),
          ],
        ),
      ),
    );
  }








  Future<void> submitData() async {
    final url = 'http://192.168.0.103:5000/users';
    final uri = Uri.parse(url);

    ///to upload image
    var stream = http.ByteStream(image!.openRead());
    stream.cast();
    var length = await image!.length();
    var request = new http.MultipartRequest('POST', uri);
    var multipart = new http.MultipartFile(
        'image', stream, length, filename: basename(image!.path));

    request.fields['username'] = usernameController.text;
    request.fields['password'] = passwordController.text;
    request.files.add(multipart);

    var response = await request.send();

    if (response.statusCode == 200) {
      usernameController.text = '';
      passwordController.text = '';
      request.files.clear();
      print('creation success');
      print('uploaded');
    } else {
      print('creation failed');
    }
  }
    // Future<void> submitData() async{
    //   final username = usernameController.text;
    //   final password = passwordController.text;
    //   final body = {
    //     "username": username,
    //     "password": password,
    //   };
    //   //submit data to the server
    //   final url = 'http://192.168.0.103:5000/users';
    //   final uri = Uri.parse(url);
    //   final response = await http.post(uri,
    //       body: jsonEncode(body),
    //       headers: {'Content-Type': 'application/json'}
    //   );
    //   if(response.statusCode == 200){
    //     usernameController.text = '';
    //     passwordController.text = '';
    //     print('creation success');
    //     print('uploaded');
    //   }else{
    //     print('creation failed');
    //     //print(response.body);
    //   }
    //
    // }



  Future<void> updateData() async{
    final user = widget.user;
    if(user == null){
      print("you can't call update without todo data");
      return;
    }
    final id = user['id'];
    final username = usernameController.text;
    final password = passwordController.text;
    final body = {
      "username": username,
      "password": password,

    };
    //submit updata to the server
    final url = 'http://192.168.0.103:5000/users/$id';
    final uri = Uri.parse(url);
    final response = await http.put(uri,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'}
    );
    if(response.statusCode == 200){
      print('updated');

    }else{
      print('failed');
      print(response.body);
    }
  }




}
