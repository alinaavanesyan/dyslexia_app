import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:editable_image/editable_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dyslexia_project/screens/home_screen.dart';
import 'package:dyslexia_project/snack_bar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:dyslexia_project/services/database.dart';
import 'package:dyslexia_project/graphs/graph1.dart';
import 'package:dyslexia_project/screens/lessons.dart';
import 'package:dyslexia_project/services/database.dart';
import 'package:dyslexia_project/screens/reading_section.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:easy_pie_chart/easy_pie_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:io' as io;

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreen();
}

class _EditAccountScreen extends State<EditAccountScreen> {
  final User user = FirebaseAuth.instance.currentUser!;
  FirebaseStorage storage = FirebaseStorage.instance;
 // var currentpassword = FirestoreService().getPassword(FirebaseAuth.instance.currentUser!);
  String? imageUrl;
  File? _imageFile;
  String? url;
  bool isLoading = true;
  bool _isEmailVerified = false;

  getImageUrl() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    Reference ref = FirebaseStorage.instance.ref().child('avatars/${uid}.jpg');
    String directoryPath = 'avatars';
    Reference directoryRef = storage.ref().child(directoryPath);

    try {
      // Получение списка всех файлов в директории
      ListResult result = await directoryRef.listAll();

      // Фильтрация файлов по имени "cat" независимо от расширения
      List<Reference> catImages = result.items.where((item) {
        return item.name.startsWith(uid);
      }).toList();

      // Получение URL-адресов всех отфильтрованных изображений
      // List<String> urls = await Future.wait(
      //   catImages.map((item) => item.getDownloadURL()).toList(),
      // );

      if (catImages.length != 0) {
        String imageUrl2 = await catImages[0].getDownloadURL();
        setState(() {
          imageUrl = imageUrl2;
          isLoading = false;
        });
      }
      else {
        Reference originalRef = FirebaseStorage.instance.ref().child(
            'avatars/cat.jpeg');

        // Получить данные исходного изображения
        final data = await originalRef.getData();

        if (data != null) {
          // Получить ссылку на новое изображение
          Reference newRef = FirebaseStorage.instance.ref().child(
              'avatars/$uid.jpeg');

          await newRef.putData(data);
          var directoryRef = await storage.ref().child('avatars/$uid.jpeg').getDownloadURL();
          print('Файл успешно продублирован');
          setState(() {
            imageUrl = directoryRef;
            isLoading = false;
          });
        }
      }
    }

    catch(e){
      print('Фото отсутствует, загружаем своё');
      // final Reference sourceRef = storage.ref().child(filePath);

      File image_file = io.File('/Users/mac/StudioProjects/dyslexia_project/assets/icons/cat.jpeg');
      UploadTask uploadTask = ref.putFile(image_file);
      print('Изображение успешно загружено в Firebase Storage');
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
        isLoading = false;
      });
    }
  }

  String answer = '';
  checkUserAuthProvider() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        user.providerData.forEach((profile) {
          if (profile.providerId == "password") {
            answer = 'email';
          }
        });
      } else {
        answer = 'google';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _checkInfo(user);
    getImageUrl();
    checkUserAuthProvider();
  }

  _checkInfo(User user) async {
    try {
      await user!.reload();
    }
    on FirebaseAuthException catch (e) {
      signOut();
    }
  }

  Future<void> signOut() async {
    final navigator = Navigator.of(context);
    await FirebaseAuth.instance.signOut();
    navigator.pushNamedAndRemoveUntil('/welcome', (Route<dynamic> route) => false);
  }

  _onImageChanged(File? image) async {
      PermissionStatus status = await Permission.photos.request();
      if (status.isGranted) {
        // Разрешение получено, теперь вы можете вызвать метод для выбора изображения из галереи
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      } else {
        // Разрешение не получено
        // Можно показать пользователю информацию о том, что разрешение не было получено
      }

    // _requestPermissionAndPickImage();
    // setState(() {
    //   _imageFile = image;
    // });
    //
  }

  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (_selectedIndex) {
        case 0:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Lessons()),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TextListScreen()),
          );
          break;
        // case 3:
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => EditAccountScreen()),
        //   );
        //   break;
      }
    });
  }

  Future<void> _uploadImageF() async{
    if (_imageFile != null) {
      _uploadImageToFirebase(_imageFile!);
    }
  }

  _uploadImageToFirebase(File imageFile) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageReference = storage.ref().child('avatars/${user.uid}.jpg');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    await uploadTask.whenComplete(() =>
        print('Image uploaded to Firebase Storage'));
        SnackBarService.showSnackBar(
          context,
          'Фотография успешно загружена',
          false,
        );
  }

  _updateUserEmail(String newEmail) async {
    if (newEmail.trim() != user!.email && EmailValidator.validate(newEmail.trim())) {

      try {
        print(newEmail.trim().runtimeType);
        print(user!.uid);
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('passwords_storage').doc(user!.uid).get();
        print(userDoc.get('Password'));

        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: user!.email!,
          password: userDoc.get('Password'),
        ).whenComplete(() => print("Success: Authentication completed!"))
            .catchError((error) {
          print("Error during reauthentication: $error");
          // Здесь вы можете добавить дополнительные действия при возникновении ошибки
        });        // LoginScreen.userpassword();

        await user.verifyBeforeUpdateEmail(newEmail.trim());

        // FirestoreService().checkEmail(user, newEmail);

        SnackBarService.showSnackBar(
              context,
              'Для потверждения изменений пройдите по ссылке, отправленной на указанную почту',
              false,);

        // try {
        //   await FirebaseAuth.instance
        //       .signInWithEmailAndPassword(
        //     email: user!.email!,
        //     password: userDoc.get('Password'),
        //   ).whenComplete(() => print("Success: Authentication completed!"))
        //       .catchError((error) {
        //     print("Error during reauthentication: $error");
        //     // Здесь вы можете добавить дополнительные действия при возникновении ошибки
        //   });
        // }
        // catch(e){
        //   final navigator = Navigator.of(context);
        //   navigator.pushNamedAndRemoveUntil('/welcome', (Route<dynamic> route) => false);
        // }

        } on FirebaseAuthException
      catch (e) {

        print('r');
        print(e.code);
        print(e);

      if (e.code == 'email-already-in-use') {
        SnackBarService.showSnackBar(
          context,
          'Такой Email уже используется, повторите попытку с использованием другого Email',
          true,
        );
        return;
      } else {
        SnackBarService.showSnackBar(
          context,
          'Некорректный Email адрес',
          true,
        );
      }
    }}
    else {
      if (!EmailValidator.validate(newEmail)) {
        SnackBarService.showSnackBar(
          context,
          'Некорректный Email адрес',
          true,
        );
      }
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameTextInputController = TextEditingController(text: FirebaseAuth.instance.currentUser!.displayName!);
  final TextEditingController _emailTextInputController = TextEditingController(text: FirebaseAuth.instance.currentUser!.email!);
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  void _changePassword() async {
    print(_nameTextInputController.text.trim().length);
    if (_nameTextInputController.text.trim().length != 0 &&  _nameTextInputController.text.trim() != user.displayName!) {
      user!.updateProfile(displayName: _nameTextInputController.text);
      SnackBarService.showSnackBar(
        context,
        'Имя изменено',
        false,
      );
    }
    print('а');
    if (_emailTextInputController.text.trim().length != 0) {
      _updateUserEmail(_emailTextInputController.text);
    }

    if (_oldPasswordController.text.trim().length != 0 || _newPasswordController.text.trim().length != 0 ||
        _confirmNewPasswordController.text.trim().length != 0) {
      try {
        User user = _auth.currentUser!;
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection(
              'passwords_storage').doc(user!.uid).get();
          print(userDoc.get('Password'));
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(
            email: user!.email!,
            password: userDoc.get('Password'),
          ).whenComplete(() {
            print("Success: Authentication completed!");
          })
              .catchError((error) {
            print("Error during reauthentication: $error");
          }); // LoginScreen.userpassword();
        }
        catch (e) {
          signOut();
        }
        String oldPassword = _oldPasswordController.text;
        String newPassword = _newPasswordController.text;
        String confirmNewPassword = _confirmNewPasswordController.text;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
            'passwords_storage').doc(user!.uid).get();

        if (oldPassword != userDoc.get('Password')) {
          SnackBarService.showSnackBar(
            context,
            'Старый пароль введен неверно',
            true,
          );
        }

        else {
          if (newPassword == confirmNewPassword) {
            await user.updatePassword(newPassword);
            FirestoreService().updatePassword(
                user, _confirmNewPasswordController.text.trim());
            print('Пароль изменён');
            SnackBarService.showSnackBar(
              context,
              'Пароль успешно обновлён',
              false,
            );
          } else {
            SnackBarService.showSnackBar(
              context,
              'Пароли не совпадают',
              true,
            );
          }
        }
      }
      catch (e) {
        print(e);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  bool isHiddenPassword = true;
  void togglePasswordView() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }

  String? _imagePath;
  String? avatarImage;
  File? _avatarImage2;
  Future<void> _addImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    print(image?.path);
    setState(() {
      _imagePath = image?.path;
    });
  }

  ImageProvider _avatarImage = AssetImage('assets/default_avatar.png');

  Future<void> _requestPermissionAndPickImage(File? image) async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
      setState(() {
        _imageFile = image;
      });
      if (!status.isGranted) {
        // Permission is still denied, handle this case
        throw Exception('Permission denied');
      }
    }    // Proceed with picking the imag
  }

  Future<void> _requestPermissionAndPickImage3() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
      if (!status.isGranted) {
          // Permission is still denied, handle this case
          throw Exception('Permission denied');
        }
      }
    }    // Proceed with picking the imag

    // requestPhotoPermission() async {
    // DeviceInfo deviceInfo = await DeviceInfoPlugin().androidInfo;
    // Permission permissionToRequest;
    //
    // if (defaultTargetPlatform == TargetPlatform.android && deviceInfo.version.sdkInt <= 32) {
    //   permissionToRequest = Permission.storage;
    // } else {
    //   permissionToRequest = Permission.photos;
    // }
    //
    // if (await permissionToRequest.status.isDenied) {
    //   return await permissionToRequest.request();
    // }
  // }

  Future<void> _requestPermissionAndPickImage2() async {
    var status = await Permission.photos.status;
    if (status.isGranted) {
      _pickImage();
    } else {
      status = await Permission.photos.request();
      if (status.isGranted) {
        _pickImage();
      } else {
        // Handle the case where permission is denied
        throw Exception('Permission denied');
      }
    }
  }

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        // _imageFile = File(pickedFile.path);
        _avatarImage2 = File(pickedFile.path);
      });
    }
  }

  // Future<void> _pickImage() async {
  //   final status = await Permission.photos.request();
  //   if (status.isGranted) {
  //     final picker = ImagePicker();
  //     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //     if (pickedFile != null) {
  //       setState(() {
  //         _avatarImage2 = File(pickedFile.path);
  //       });
  //     }
  //   } else {
  //     final status = await Permission.photos.request();
  //     if (status.isGranted) {
  //       final picker = ImagePicker();
  //       final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //       if (pickedFile != null) {
  //         setState(() {
  //           _avatarImage2 = File(pickedFile.path);
  //         });
  //       }
  //     }
  //     else {
  //       // Handle the case when the user denies the permission
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Permission denied. Unable to pick image.')),
  //       );
  //     }
  //   }
  // }


  Future<void> _pickImage2() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _avatarImage2 = File(pickedFile.path);
        });
      }
    } else {
      // Handle the case when the user denies the permission
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied. Unable to pick image.')),
      );
    }
  }
  void _showAvatarSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: GridView.builder(
            itemCount: 6, // Количество доступных аватарок
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              var avatarPath = 'assets/avatars/avatar_$index.png'; // Пути к аватаркам
              return GestureDetector(
                onTap: () {
                  setState(() {
                    avatarImage = avatarPath;
                  });
                  Navigator.pop(context);
                },
                child: Image.asset(avatarPath),
              );
            },
          ),
        );
      },
    );
  }

  void getImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      // Теперь у вас есть переменная _imageFile типа File, содержащая выбранное изображение
    } else {
      print('Ничего не выбрано');
    }
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading == false){
    return Scaffold(
        bottomNavigationBar: BottomNavyBar(
          selectedIndex: _selectedIndex,
          showElevation: true,
          onItemSelected: _onItemTapped,
          items: [
            BottomNavyBarItem(
                icon: const Icon(Icons.home),
                title: const Text('Главная'),
                activeColor: Colors.orange, //Color(0xffFFF6D4),
                inactiveColor: Colors.grey[300]),
            BottomNavyBarItem(
              icon: const Icon(Icons.favorite_rounded),
              title: const Text('Уроки'),
              inactiveColor: Colors.grey[300],
              activeColor: Colors.orange,
            ),
            BottomNavyBarItem(
              icon: const Icon(Icons.message),
              title: const Text('Чтение'),
              inactiveColor: Colors.grey[300],
              activeColor: Colors.orange,
            ),
            BottomNavyBarItem(
              icon: const Icon(Icons.person),
              title: const Text('Профиль'),
              inactiveColor: Colors.grey[300],
              activeColor: Colors.orange,
            ),
          ],
        ),
        body: Stack(
            fit: StackFit.expand,
            children: [

              Image.asset(
                "assets/images/back_star.png",
                fit: BoxFit.cover,
              ),

              Positioned(
              top: 50,
              left: 15,
              child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () =>  Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountScreen()),)
              )),

              Positioned(
                top: 50,
                right: 15,
                child: IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text('Вы уверены, что хотите выйти?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Отмена'),
                          ),
                          TextButton(
                            onPressed: () => signOut(),
                            child: Text('Выйти'),
                          ),
                        ],
                      ),
                    )
                ),
                ),

              SizedBox(height: 4, width: 10),
              Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 110),
                  // height: 200,
                  decoration: BoxDecoration(
                      color: Color(0xffffffff),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        )
                      ]),

                  child: ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      children: [

                        SizedBox(height: 8), // Добавляем небольшое отступ сверху
                        Text(
                          'РЕДАКТИРОВАНИЕ ПРОФИЛЯ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                          // indent: 50,
                          // endIndent: 50,
                        ),

                        SizedBox(height: 20),

                        // EditableImage(
                        //   onChange: _onImageChanged,
                        //   image: isLoading == false ? (_imageFile != null ? Image.file(_imageFile!, fit: BoxFit.cover) : Image.network(imageUrl!, fit: BoxFit.cover,)) : null,
                        //   size: 130,
                        //   imagePickerTheme: ThemeData(
                        //     primaryColor: Colors.white,
                        //     shadowColor: Colors.transparent,
                        //     colorScheme: const ColorScheme.light(background: Colors.white70),
                        //     iconTheme: const IconThemeData(color: Colors.black87),
                        //     fontFamily: 'Georgia',
                        //   ),
                        // ),

                        // CircleAvatar(
                        //   radius: 50,
                        //   backgroundImage:
                        //   _imageFile!= null ? FileImage(
                        //       _imageFile! ) : null,
                        // ),

                        // GestureDetector(
                        //   onTap: _requestPermissionAndPickImage2,
                        //   child: CircleAvatar(
                        //     radius: 50,
                        //     backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                        //   ),
                        // ),

                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            // minRadius: 50,
                            // maxRadius: 75,
                            radius: 90,
                            backgroundImage: isLoading == false ? (_avatarImage2 != null ?  FileImage(_avatarImage2!) : NetworkImage(imageUrl!,)) : null, // _avatarImage2 != null ? FileImage(_avatarImage2!) : null,
                            child: (_avatarImage2 != null || imageUrl != null) ? null : Icon(Icons.person, size: 60),
                          ),
                        ),

                        // GestureDetector(
                        //   onTap: _showAvatarSelection,
                        //   child: CircleAvatar(
                        //     radius: 60,
                        //     backgroundImage: avatarImage != null ? AssetImage(avatarImage!) : null,
                        //     child: avatarImage == null ? Icon(Icons.person, size: 60) : null,
                        //   ),
                        // ),


                        // PopupMenuButton(
                        //   onSelected: (value) {
                        //     setState(() {
                        //       selectedAnimal = value;
                        //     });
                        //   },
                        //   itemBuilder: (BuildContext context) {
                        //     return <PopupMenuEntry>[
                        //       PopupMenuItem(
                        //         value: 'котик',
                        //         child: Text('Котик'),
                        //       ),
                        //       PopupMenuItem(
                        //         value: 'песик',
                        //         child: Text('Песик'),
                        //       ),
                        //     ];
                        //   },
                        //   child: CircleAvatar(
                        //     radius: 50,
                        //     backgroundImage: AssetImage('assets/avatars/$selectedAnimal.png'),
                        //   ),
                        // ),

                        SizedBox(height: 25),
                        //    const Spacer(flex: 2),
                        Container(width: 10, child: _buildTextField(labelText: user.displayName!, fieldName: 'Имя', controller: _nameTextInputController)),
                        SizedBox(height: 20),
                        _buildTextField(labelText: user.email!, fieldName: 'Почта', controller: _emailTextInputController, ),
                        SizedBox(height: 20),
                        if (answer == 'email')
                          Column(children:
                              [
                          _buildTextFieldPassword(
                              labelText: '*****',
                              fieldName: 'Старый пароль',
                              controller: _oldPasswordController,
                              obscureText: true),
                          SizedBox(height: 20),
                          _buildTextFieldPassword(labelText: ' ',
                              fieldName: 'Новый пароль',
                              controller: _newPasswordController,
                              obscureText: true),
                          SizedBox(height: 20),
                          _buildTextFieldPassword(labelText: ' ',
                              fieldName: 'Повторите новый пароль',
                              controller: _confirmNewPasswordController,
                              obscureText: true),
                          SizedBox(height: 20),
                                ElevatedButton(
                                    onPressed: () => {
                                      _uploadImageF().whenComplete(() => _changePassword()
                                    )
                                    },
                                    child: new Text('СОХРАНИТЬ', style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xffFFCA0D),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15)),
                                      elevation: 1,
                                      minimumSize: const Size.fromHeight(50),
                                    )
                                )
                          ])
                        else
                          ElevatedButton(
                          onPressed: () => {
                            _uploadImageF(),
                          },
                          child: new Text('СОХРАНИТЬ', style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)
                          ),
                          style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffFFCA0D),
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                            elevation: 1,
                              minimumSize: const Size.fromHeight(50),
                          )
                          )
                      ])
              )
            ])
    );}
    else {
      return Stack(children: [
        Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          )),
        Positioned(
            top: 50,
            left: 15,
            child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomeScreen()),)
            )
        )
      ]);
    }
  }

  Column background(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/back_star.png"),
                  fit: BoxFit.fill)),
          child: Column(
            children: [
            ],
          ),
        ),
      ],
    );
  }

  TextFormField _buildTextField({String labelText = ' ', String fieldName = ' ', TextEditingController? controller, bool obscureText = false}) {
    if (labelText != 'Почта')
      return
      TextFormField(
        controller: controller,
        readOnly: false,
        // initialValue: controller != null ? null : labelText,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: fieldName,
          labelStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Color(0xffF9F9F9),
          border: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xffFFCA0D),
                width: 1.5,
              ),
              borderRadius: BorderRadius.all(
              Radius.circular(15),
              ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xffFFCA0D),
              width: 1.5,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),

        ),
      );
    else
      return
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          validator: (email) =>
          email != null && email.isNotEmpty && !EmailValidator.validate(email)
              ? 'Введите правильный Email'
              : null,
          controller: controller,
          readOnly: false,
          // initialValue: controller != null ? null : labelText,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: fieldName,
            labelStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Color(0xffF9F9F9),
            border: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xffFFCA0D),
                width: 1.5,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xffFFCA0D),
                width: 1.5,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),

          ),
        );

  }

  TextFormField _buildTextFieldPassword({String labelText = '', String fieldName = '', TextEditingController? controller, bool obscureText = false}) {
    return
      TextFormField(
        controller: controller,
        obscureText: isHiddenPassword,
        readOnly: false,
        // initialValue: labelText,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: fieldName,
          labelStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Color(0xffF9F9F9),
          suffix: InkWell(
            onTap: togglePasswordView,
            child: Icon(
              isHiddenPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.black,
            ),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xffFFCA0D),
              width: 1.5,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xffFFCA0D),
              width: 1.5,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),

        ),
      );

  }

}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreen();
}

class _AccountScreen extends State<AccountScreen> {
  final User user = FirebaseAuth.instance.currentUser!;
  FirebaseStorage storage = FirebaseStorage.instance;
  String? imageUrl;
  File? _imageFile;
  String? url;
  bool isLoading = true;

  getImageUrl() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    Reference ref = FirebaseStorage.instance.ref().child('avatars/${uid}.jpg');
    String directoryPath = 'avatars';
    Reference directoryRef = storage.ref().child(directoryPath);

    try {
    // Получение списка всех файлов в директории
    ListResult result = await directoryRef.listAll();

    // Фильтрация файлов по имени "cat" независимо от расширения
    List<Reference> catImages = result.items.where((item) {
      return item.name.startsWith(uid);
    }).toList();

    // Получение URL-адресов всех отфильтрованных изображений
    // List<String> urls = await Future.wait(
    //   catImages.map((item) => item.getDownloadURL()).toList(),
    // );

    if (catImages.length != 0) {
      String imageUrl2 = await catImages[0].getDownloadURL();
      setState(() {
        imageUrl = imageUrl2;
        isLoading = false;
      });
    }
    else {
      Reference originalRef = FirebaseStorage.instance.ref().child(
          'avatars/cat.jpeg');

      // Получить данные исходного изображения
      final data = await originalRef.getData();

      if (data != null) {
        // Получить ссылку на новое изображение
        Reference newRef = FirebaseStorage.instance.ref().child(
            'avatars/$uid.jpeg');

        await newRef.putData(data);
        var directoryRef = await storage.ref().child('avatars/$uid.jpeg').getDownloadURL();
        print('Файл успешно продублирован');
        setState(() {
          imageUrl = directoryRef;
          isLoading = false;
        });
      }
    }
    }

    catch(e){
      print('Фото отсутствует, загружаем своё');
      // final Reference sourceRef = storage.ref().child(filePath);

      File image_file = io.File('/Users/mac/StudioProjects/dyslexia_project/assets/icons/cat.jpeg');
      UploadTask uploadTask = ref.putFile(image_file);
      print('Изображение успешно загружено в Firebase Storage');
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getImageUrl();
    _checkInfo(user);
    // checkUser();
  }

  _checkInfo(User user) async {
    try {
      if (!user!.email.toString().contains('gmail.com')) {
        await user!.reload();
      }
    }
    on FirebaseAuthException catch (e) {
      signOut();
    }
  }


  // Future<void> checkUser() async {
  //   try {
  //     User user = FirebaseAuth.instance.currentUser!;
  //     DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
  //         'passwords_storage').doc(user!.uid).get();
  //
  //     FirebaseAuth.instance
  //         .signInWithEmailAndPassword(
  //       email: user!.email!,
  //       password: userDoc.get('Password'),
  //     ).whenComplete(() => print("Success: Authentication completed!"))
  //         .catchError((error) {
  //       print("Error during reauthentication: $error");
  //       // Здесь вы можете добавить дополнительные действия при возникновении ошибки
  //     });
  //   } catch(e) {
  //     signOut();
  //   }
  // }

  Future<void> signOut() async {
    final navigator = Navigator.of(context);

    await FirebaseAuth.instance.signOut();

    navigator.pushNamedAndRemoveUntil('/welcome', (Route<dynamic> route) => false);
  }

  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (_selectedIndex) {
        case 0:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Lessons()),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TextListScreen()),
          );
          break;
      }
    });
  }
  final List<PieData> pies = [
    PieData(value: 0.15, color: Colors.yellow),
    PieData(value: 0.35, color: Colors.cyan),
    PieData(value: 0.45, color: Colors.lightGreen),
  ];

  @override
  Widget build(BuildContext context) {
    if (isLoading == false) {
      return Scaffold(
          bottomNavigationBar: BottomNavyBar(
            selectedIndex: _selectedIndex,
            showElevation: true,
            onItemSelected: _onItemTapped,
            items: [
              BottomNavyBarItem(
                  icon: const Icon(Icons.home),
                  title: const Text('Главная'),
                  activeColor: Colors.orange, //Color(0xffFFF6D4),
                  inactiveColor: Colors.grey[300]),
              BottomNavyBarItem(
                icon: const Icon(Icons.favorite_rounded),
                title: const Text('Уроки'),
                inactiveColor: Colors.grey[300],
                activeColor: Colors.orange,
              ),
              BottomNavyBarItem(
                icon: const Icon(Icons.message),
                title: const Text('Чтение'),
                inactiveColor: Colors.grey[300],
                activeColor: Colors.orange,
              ),
              BottomNavyBarItem(
                icon: const Icon(Icons.person),
                title: const Text('Профиль'),
                inactiveColor: Colors.grey[300],
                activeColor: Colors.orange,
              ),
            ],
          ),
          body: Stack(
              fit: StackFit.expand,
              children: [

                Image.asset(
                  "assets/images/back_star.png",
                  fit: BoxFit.cover,
                ),

                Positioned(
                  top: 50,
                  right: 15,
                  child:
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => EditAccountScreen()));
                    },
                  ),
                ),

                Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 150),
                    // height: 200,
                    decoration: BoxDecoration(
                        color: Color(0xffffffff),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          )
                        ]),

                    child:
                            SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                padding: const EdgeInsets.all(8),
                                child: Column(children: [

                                  SizedBox(height: 120,),

                                  SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          // shrinkWrap: true,
                          // padding: const EdgeInsets.all(8),
                          child:
                            Padding(
                              // scrollDirection: Axis.vertical,
                              //   // controller: scrollController,
                              //   shrinkWrap: true,
                              padding: EdgeInsets.only(top: 40, left: 10, right: 10, bottom: 5),
                                child: Column(children: [

                                Container(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  height: MediaQuery.of(context).size.height * 0.3,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    color: Color(0xffFDE3FF), // Color(0xffEB01FF),
                                  ),
                                  child: BarChartSample1(),
                                  // child: Center(
                                  //   child: Text(
                                  //     'Жирный текст',
                                  //     style: TextStyle(fontWeight: FontWeight.bold,
                                  //      fontSize: 16.0,),
                                  //   ),
                                  // ),
                                ),

                                  Container(child: PieChart1()),
                                    Center(
                                        child: Container(
                                            // height: MediaQuery.of(context).size.height * .7,
                                            // width: MediaQuery.of(context).size.width * 1.5,
                                            // padding: EdgeInsets.all(16.0), // Устанавливаем padding
                                            padding: EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 5),
                                            margin: EdgeInsets.all(16.0), // Устанавливаем margin
                                            decoration: BoxDecoration(
                                              color: Color(0xffFFF3C7), // Устанавливаем прозрачность фона
                                              borderRadius: BorderRadius.circular(12.0), // Устанавливаем угловой радиус
                                            ),
                                            child:
                                            Column(children: [
                                              Text('СТАТИСТИКА ПО ТЕМАМ',  style: TextStyle(
                                                fontSize: 20,
                                                height: 0,
                                                letterSpacing: 0.85,
                                                color: Color(0xffFF9E0D),
                                                fontWeight: FontWeight.bold,)),
                                              Container(child: Chart3()),

                                  ]),),

                                  // Container(child: TableWithDropdown()),


                                    )]),

                      ))
                                ]
                        ))),

                Positioned(
                  top: 150,
                  left: 0,
                  right: 0,
                  child: Align(child: Container(
                    height: 130,
                    // color: Colors.white,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        ),
                  ),
                )),

                Align(
                             alignment: Alignment.topCenter,
                             child: Padding(
                                 padding: const EdgeInsets.only(top: 75),
                                 child: Container(
                                   width: 150.0,
                                   height: 150.0,
                                   clipBehavior: Clip.antiAlias,
                                   decoration: BoxDecoration(
                                     shape: BoxShape.circle,
                                   ),
                                   child: isLoading == false ? (_imageFile != null ? Image
                                       .file(_imageFile!, fit: BoxFit.cover) : Image
                                       .network(imageUrl!, fit: BoxFit.cover,)) : null,
                                 )),
                           ),

                Align(
                               alignment: Alignment.topCenter,
                               child: Padding(
                                 padding: const EdgeInsets.only(top: 240),
                                 child: Text(user.displayName!,
                                   style: TextStyle(
                                     fontSize: 18,
                                     fontWeight: FontWeight.bold,
                                     color: Colors.grey,
                                   ),
                                   textAlign: TextAlign.center,),)
                           ),

              ]
          )
      );
    }
    else {
      return Stack(children: [
        Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            )),
        Positioned(
            top: 50,
            left: 15,
            child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomeScreen()),)
            )
        )
      ]);
    }
  }

  Column background_container(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 20),
          // heаight: 200,
          decoration: BoxDecoration(
            // color: Color(0xff294CFF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                )
              ]),
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),


                  ],
                ),
              ),

            ],
          ),
        ),
      ],
    );
  }

  Column background(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/back_star.png"),
                  fit: BoxFit.fill)),
          child: Column(
            children: [
            ],
          ),
        ),
      ],
    );
  }
}

