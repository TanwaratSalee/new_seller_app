import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seller_finalproject/const/const.dart';
import 'package:seller_finalproject/const/styles.dart';
import 'package:seller_finalproject/controllers/auth_controller.dart';
import 'package:seller_finalproject/views/auth_screen/create_screen.dart';
import 'package:seller_finalproject/views/auth_screen/forgot_screen.dart';
import 'package:seller_finalproject/views/widgets/custom_textfield.dart';
import 'package:seller_finalproject/views/widgets/our_button.dart';
import 'package:velocity_x/velocity_x.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(AuthController());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: whiteColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Spacer(),
              Obx(
                () => Column(
                  children: [
                    const Text(loginTo)
                        .text
                        .size(36)
                        .color(blackColor)
                        .fontFamily(medium)
                        .make(),
                    Image.asset(
                      icbag,
                      width: 250,
                      height: 250,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Text(
                              'Enjoy selling and discovering the best fashion brands. Wishing you a successful first day!')
                          .text
                          .align(TextAlign.center)
                          .size(14)
                          .color(greyColor)
                          .make(),
                    ),
                    20.heightBox,
                    Column(
                      children: [
                        customTextField(
                            controller: controller.emailController,
                            label: 'Email'),
                        15.heightBox,
                        customTextFieldPassword(
                          label: password,
                          isPass: true,
                          readOnly: false,
                          controller: controller.passwordController,
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 12),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Get.to(() => ForgotScreen());
                          },
                          child: const Text(forgotPassword)
                              .text
                              .size(14)
                              .color(greyDark)
                              .fontFamily(medium)
                              .make(),
                        ),
                      ),
                    ),
                    10.heightBox,
                    controller.isloading.value
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(primaryApp),
                          )
                        : ourButton(
                            color: primaryApp,
                            title: 'Sign in',
                            textColor: whiteColor,
                            onPress: () async {
                              controller.isloading(true);
                              await controller.loginMethod(context);
                            },
                          )
                            .box
                            .margin(const EdgeInsets.symmetric(horizontal: 20))
                            .make(),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: greyLine, height: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: loginWith.text.color(greyColor).make(),
                        ),
                        const Expanded(
                          child: Divider(color: greyLine, height: 1),
                        ),
                      ],
                    ).marginSymmetric(horizontal: 30),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        socialIconList.length,
                        (index) => Expanded(
                          child: GestureDetector(
                            onTap: () {
                              switch (index) {
                                case 0:
                                  controller.signInWithGoogle(context);
                                  break;
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                              margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: greyLine,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    socialIconList[index],
                                    height: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text('Sign in with Google'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                            },
                            child: SingleChildScrollView(
                              child: Container(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom),
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "How to Sign Up for the Seller StyleFinder App",
                                        style: TextStyle(
                                            fontSize: 32, fontFamily: semiBold),
                                      ),
                                      SizedBox(height: 40),
                                      const Text(
                                        'If you already have an account with the StyleFinder app, you can seamlessly use the same email and password to create your store with us.',
                                        style: TextStyle(
                                            fontSize: 14, fontFamily: regular),
                                      ),
                                      20.heightBox,
                                      Text(
                                        'If you do not yet have an account with the StyleFinder app, please follow these steps:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: regular,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 18),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            SizedBox(height: 8),
                                            Text(
                                              '1. Download the StyleFinder app.',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: regular,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              '2. Register and log in using the app.',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: regular,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              '3. Once registered, you can use the same email and password to create your store account through the Seller StyleFinder app.',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: regular,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 60),
                                      Center(
                                        child: const Text(
                                          'Thank you for choosing StyleFinder to meet\n your fashion needs. We sincerely hope that\n  you will enjoy and appreciate our service.',
                                          style: TextStyle(
                                              fontSize: 16, fontFamily: regular, color: greyDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: const Text(
                      "How to Sign Up for the Seller StyleFinder App",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                        color: blackColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
