import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../screens/loading_manager.dart';
import '../services/global_method.dart';
import '../controllers/MenuController.dart';
import '../responsive.dart';
import '../services/utils.dart';
import '../widgets/buttons.dart';
import '../widgets/header.dart';
import '../widgets/side_menu.dart';
import '../widgets/text_widget.dart';

class UploadProductForm extends StatefulWidget {
  static const routeName = '/UploadProductForm';

  const UploadProductForm({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _UploadProductFormState createState() => _UploadProductFormState();
}

class _UploadProductFormState extends State<UploadProductForm> {
  final _formKey = GlobalKey<FormState>();
  String _catValue = 'Vegetables';
  late final TextEditingController _titleController, _priceController;
  int _groupValue = 1;
  bool isPiece = false;
  File? _pickedImage;
  Uint8List webImage = Uint8List(8);

  @override
  void initState() {
    _priceController = TextEditingController();
    _titleController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  void _uploadForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      if (_pickedImage == null) {
        GlobalMethods.errorDialog(
          subtitle: 'Please pick up an image',
          context: context,
        );
        return;
      }
      // ignore: no_leading_underscores_for_local_identifiers
      final _uuid = const Uuid().v4();
      try {
        setState(() {
          _isLoading = true;
        });

        final ref = FirebaseStorage.instance
            .ref()
            .child('productsImages')
            .child('$_uuid.jpg');

        if (kIsWeb) /* if web */ {
          // putData() accepts Uint8List type argument
          await ref.putData(webImage).whenComplete(() async {
            final imageUri = await ref.getDownloadURL();
            await FirebaseFirestore.instance
                .collection('products')
                .doc(_uuid)
                .set({
              'id': _uuid,
              'title': _titleController.text,
              'price': _priceController.text,
              'salePrice': 0.1,
              'imageUrl': imageUri.toString(),
              'productCategoryName': _catValue,
              'isOnSale': false,
              'isPiece': isPiece,
              'createdAt': Timestamp.now(),
            });
          });
        } else /* if mobile */ {
          // putFile() accepts File type argument
          await ref.putFile(_pickedImage!).whenComplete(() async {
            final imageUri = await ref.getDownloadURL();
            await FirebaseFirestore.instance
                .collection('products')
                .doc(_uuid)
                .set({
              'id': _uuid,
              'title': _titleController.text,
              'price': _priceController.text,
              'salePrice': 0.1,
              'imageUrl': imageUri.toString(),
              'productCategoryName': _catValue,
              'isOnSale': false,
              'isPiece': isPiece,
              'createdAt': Timestamp.now(),
            });
          });
        }

        // await FirebaseFirestore.instance.collection('products').doc(_uuid).set({
        //   'id': _uuid,
        //   'title': _titleController.text,
        //   'price': _priceController.text,
        //   'salePrice': 0.1,
        //   'imageUrl': '',
        //   'prosuctCategoryName': _catValue,
        //   'isOnSale': false,
        //   'isPiece': isPiece,
        //   'createdAt': Timestamp.now(),
        // });
        _clearForm();
        Fluttertoast.showToast(
          msg: "Product uploaded succefully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          // backgroundColor: ,
          // textColor: ,
          // fontSize: 16.0
        );
      } on FirebaseException catch (error) {
        GlobalMethods.errorDialog(
          subtitle: '${error.message}',
          context: context,
        );
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        GlobalMethods.errorDialog(
          subtitle: '$error',
          context: context,
        );
        setState(() {
          _isLoading = false;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // void _uploadForm() async {
  //   final isValid = _formKey.currentState!.validate();
  // }

  void _clearForm() {
    _priceController.clear();
    _titleController.clear();
    _groupValue = 1;
    isPiece = false;
    setState(() {
      _pickedImage = null;
      webImage = Uint8List(8);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Utils(context).getTheme;
    final color = Utils(context).color;
    // ignore: no_leading_underscores_for_local_identifiers
    final _scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    Size size = Utils(context).getScreenSize;

    var inputDecoration = InputDecoration(
      filled: true,
      fillColor: _scaffoldColor,
      border: InputBorder.none,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 1.0,
        ),
      ),
    );
    return Scaffold(
      key: context.read<MenuControllerA>().getAddProductscaffoldKey,
      drawer: const SideMenu(),
      body: LoadingManager(
        isLoading: _isLoading,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                child: SideMenu(),
              ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Header(
                        fct: () {
                          context
                              .read<MenuControllerA>()
                              .controlAddProductsMenu();
                        },
                        title: 'Add Product',
                        showTextField: false,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Container(
                      width: size.width > 650 ? 650 : size.width,
                      color: Theme.of(context).cardColor,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextWidget(
                              text: 'Product title*',
                              color: color,
                              isTitle: true,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: _titleController,
                              key: const ValueKey('Title'),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a Title';
                                }
                                return null;
                              },
                              decoration: inputDecoration,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: FittedBox(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: 'Price in \$*',
                                          color: color,
                                          isTitle: true,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: TextFormField(
                                            controller: _priceController,
                                            key: const ValueKey('Price \$'),
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Price is missed';
                                              }
                                              return null;
                                            },
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9.]')),
                                            ],
                                            decoration: inputDecoration,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        TextWidget(
                                          text: 'Porduct category*',
                                          color: color,
                                          isTitle: true,
                                        ),
                                        const SizedBox(height: 10),
                                        // Drop down menu code here
                                        _categoryDropDown(),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        TextWidget(
                                          text: 'Measure unit*',
                                          color: color,
                                          isTitle: true,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        // Radio button code here
                                        Row(
                                          children: [
                                            TextWidget(
                                              text: 'KG',
                                              color: color,
                                            ),
                                            Radio(
                                              value: 1,
                                              groupValue: _groupValue,
                                              onChanged: (valuee) {
                                                setState(() {
                                                  _groupValue = 1;
                                                  isPiece = false;
                                                });
                                              },
                                              activeColor: Colors.green,
                                            ),
                                            TextWidget(
                                              text: 'Piece',
                                              color: color,
                                            ),
                                            Radio(
                                              value: 2,
                                              groupValue: _groupValue,
                                              onChanged: (valuee) {
                                                setState(() {
                                                  _groupValue = 2;
                                                  isPiece = true;
                                                });
                                              },
                                              activeColor: Colors.green,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Image to be picked code is here

                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: size.width > 650
                                          ? 350
                                          : size.width * 0.45,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: _pickedImage == null
                                          ? dottedBorder(color: color)
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: kIsWeb
                                                  ? Image.memory(webImage,
                                                      fit: BoxFit.fill)
                                                  : Image.file(_pickedImage!,
                                                      fit: BoxFit.fill),
                                            ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: FittedBox(
                                      child: Column(
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _pickedImage = null;
                                                webImage = Uint8List(8);
                                              });
                                            },
                                            child: TextWidget(
                                              text: 'Clear',
                                              color: Colors.red,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {},
                                            child: TextWidget(
                                              text: 'Update image',
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ButtonsWidget(
                                    onPressed: () {
                                      _clearForm();
                                    },
                                    text: 'Clear form',
                                    icon: IconlyBold.danger,
                                    backgroundColor: Colors.red.shade300,
                                  ),
                                  ButtonsWidget(
                                    onPressed: () {
                                      _uploadForm();
                                    },
                                    text: 'Upload',
                                    icon: IconlyBold.upload,
                                    backgroundColor: Colors.blue,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (!kIsWeb) {
      // ignore: no_leading_underscores_for_local_identifiers
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        setState(() {
          _pickedImage = selected;
        });
      } else {
        if (kDebugMode) {
          print('No imahe has been picked');
        }
      }
    } else if (kIsWeb) {
      // ignore: no_leading_underscores_for_local_identifiers
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
          _pickedImage = File('a');
        });
      } else {
        if (kDebugMode) {
          print('No imahe has been picked');
        }
      }
    } else {
      if (kDebugMode) {
        print('Somthing went wrong');
      }
    }
  }

  Widget dottedBorder({
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DottedBorder(
        dashPattern: const [6.7],
        borderType: BorderType.RRect,
        color: color,
        radius: const Radius.circular(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                color: color,
                size: 50,
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: (() {
                  _pickImage();
                }),
                child: TextWidget(
                  text: 'Choose an image',
                  color: Colors.blue,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryDropDown() {
    final color = Utils(context).color;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          value: _catValue,
          onChanged: (value) {
            setState(() {
              _catValue = value!;
            });
            // print(_catValue);
          },
          hint: const Text('Select a category'),
          items: const [
            DropdownMenuItem(
              value: 'Vegetables',
              child: Text(
                'Vegetables',
              ),
            ),
            DropdownMenuItem(
              value: 'Fruits',
              child: Text(
                'Fruits',
              ),
            ),
            DropdownMenuItem(
              value: 'Grains',
              child: Text(
                'Grains',
              ),
            ),
            DropdownMenuItem(
              value: 'Nuts',
              child: Text(
                'Nuts',
              ),
            ),
            DropdownMenuItem(
              value: 'Herbs',
              child: Text(
                'Herbs',
              ),
            ),
            DropdownMenuItem(
              value: 'Spices',
              child: Text(
                'Spices',
              ),
            )
          ],
        )),
      ),
    );
  }
}
