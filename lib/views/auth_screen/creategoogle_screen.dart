import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:seller_finalproject/const/const.dart';
import 'package:seller_finalproject/controllers/auth_controller.dart';
import 'package:seller_finalproject/controllers/loading_Indcator.dart';
import 'package:seller_finalproject/views/auth_screen/address_screen.dart';
import 'package:seller_finalproject/views/widgets/custom_textfield.dart';
import 'package:seller_finalproject/views/widgets/our_button.dart';

class CreateAccountGoogle extends StatefulWidget {
  
  final String email;
  final String uid;

  const CreateAccountGoogle({Key? key, required this.email, required this.uid}) : super(key: key);

  @override
  _CreateAccountGoogleState createState() => _CreateAccountGoogleState();
}

class _CreateAccountGoogleState extends State<CreateAccountGoogle> {
  final AuthController controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    controller.emailController.text = widget.email;
    controller.passwordController.text = widget.uid;
  }

  @override
  void dispose() {
    controller.clearAllData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Create Edit Account"),
        backgroundColor: whiteColor,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                onTap: controller.pickImage,
                child: Obx(() => CircleAvatar(
                      radius: 60,
                      backgroundColor: greyColor,
                      child: controller.imageFile.value == null
                          ? const Icon(Icons.add_a_photo,
                              color: greyColor, size: 50)
                          : ClipOval(
                              child: Image.file(
                                File(controller.imageFile.value!.path),
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            ),
                    )),
              ),
              const SizedBox(height: 20),
              Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    customTextField(
                      controller: controller.shopNameController,
                      label: 'Shop Name',
                    ),
                    const SizedBox(height: 20),
                    customTextField(
                      label: 'Description',
                      controller: controller.descriptionController,
                    ),
                    const SizedBox(height: 20),
                    customTextField(
                      label: 'Website',
                      controller: controller.websiteController,
                    ),
                    const SizedBox(height: 20),
                    customTextField(
                      controller: controller.mobileController,
                      label: 'Mobile',
                      hint: 'Mobile number',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 20),
                    controller.isloading.value
                        ? loadingIndicator()
                        : ourButton(
                            title: 'Next',
                            onPress: () {
                              // Check if the essential fields are empty
                              if (controller.shopNameController.text.isEmpty ||
                                  controller.mobileController.text.isEmpty) {
                                VxToast.show(context,
                                    msg: "Please fill all required fields.");
                                return;
                              }

                              String description =
                                  controller.descriptionController.text.isEmpty? '': controller.descriptionController.text;
                              String website =
                                  controller.websiteController.text.isEmpty? '': controller.websiteController.text;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>  AddressForm(
                                          documentId: currentUser?.uid ?? '',
                                          firstname: '',
                                          surname: '',
                                          address: '',
                                          city: '',
                                          state: '',
                                          postalCode: '',
                                          phone: '',
                                        )),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}