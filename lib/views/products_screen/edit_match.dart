import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:seller_finalproject/const/const.dart';
import 'package:seller_finalproject/const/styles.dart';

class EditMatchProduct extends StatefulWidget {
  @override
  _EditMatchProductState createState() => _EditMatchProductState();
}

class _EditMatchProductState extends State<EditMatchProduct> {
  final TextEditingController explanationController = TextEditingController();
  List<String> selectedCollections = [];
  String selectedGender = '';
  late DocumentSnapshot document;
  Map<String, dynamic> productDetails = {};
  String pIdTop = '';
  String pIdLower = '';
  String topProductImg = '';
  String lowerProductImg = '';
  String topProductName = '';
  String lowerProductName = '';
  double topProductPrice = 0.0;
  double lowerProductPrice = 0.0;

  @override
  void initState() {
    super.initState();
    document = Get.arguments['document'];
    productDetails = Get.arguments['productDetails'];
    selectedGender = document['p_sex'];
    selectedCollections = List<String>.from(document['p_collection']);
    explanationController.text = document['p_desc'];
    pIdTop = document['p_id_top'];
    pIdLower = document['p_id_lower'];
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    final topSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(pIdTop)
        .get();
    final lowerSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(pIdLower)
        .get();

    if (topSnapshot.exists) {
      setState(() {
        topProductImg = topSnapshot.data()!['p_imgs'][0];
        topProductName = topSnapshot.data()!['p_name'];
        topProductPrice =
            double.tryParse(topSnapshot.data()!['p_price'].toString()) ?? 0.0;
      });
    }

    if (lowerSnapshot.exists) {
      setState(() {
        lowerProductImg = lowerSnapshot.data()!['p_imgs'][0];
        lowerProductName = lowerSnapshot.data()!['p_name'];
        lowerProductPrice =
            double.tryParse(lowerSnapshot.data()!['p_price'].toString()) ?? 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Match Product')
            .text
            .size(24)
            .fontFamily(medium)
            .make(),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await onSaveButtonPressed(context);
              Get.back();
            },
            child: const Text('Save', style: TextStyle(color: primaryApp)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // const Text("Product IDs")
              //     .text
              //     .size(16)
              //     .color(blackColor)
              //     .fontFamily(medium)
              //     .make(),
              // const SizedBox(height: 8),
              // Text("Top Product ID: $pIdTop").text.size(14).color(blackColor).make(),
              // const SizedBox(height: 8),
              // Text("Lower Product ID: $pIdLower").text.size(14).color(blackColor).make(),
              // const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      // const Text("Top Product")
                      //     .text
                      //     .size(16)
                      //     .color(blackColor)
                      //     .fontFamily(medium)
                      //     .make(),
                      if (topProductImg.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            topLeft: Radius.circular(15),
                          ),
                          child: Image.network(
                            topProductImg,
                            width: 160,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),

                      SizedBox(
                        width: 130,
                        child: Text(
                          topProductName,
                          style: TextStyle(fontSize: 14, color: blackColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("${NumberFormat('#,##0').format(topProductPrice)} Bath")
                          .text
                          .size(14)
                          .color(greyColor)
                          .make(),
                    ],
                  ).box.border(color: greyLine).rounded.make(),
                  const SizedBox(width: 5),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.add,
                        color: whiteColor,
                      )
                          .box
                          .color(primaryApp)
                          .roundedFull
                          .padding(EdgeInsets.all(4))
                          .make(),
                    ],
                  ),
                  const SizedBox(width: 5),
                  Column(
                    children: [
                      // const Text("Lower Product")
                      //     .text
                      //     .size(16)
                      //     .color(blackColor)
                      //     .fontFamily(medium)
                      //     .make(),
                      // const SizedBox(height: 8),
                      if (lowerProductImg.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            topLeft: Radius.circular(15),
                          ),
                          child: Image.network(
                            lowerProductImg,
                            width: 160,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 130,
                        child: Text(
                          lowerProductName,
                          style: TextStyle(fontSize: 14, color: blackColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("${NumberFormat('#,##0').format(lowerProductPrice)} Bath")
                          .text
                          .size(14)
                          .color(greyColor)
                          .make(),
                    ],
                  ).box.border(color: greyLine).rounded.make()
                ],
              ),
              const SizedBox(height: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Suitable for gender")
                      .text
                      .size(16)
                      .color(blackColor)
                      .fontFamily(medium)
                      .make(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['male', 'female', 'other'].map((gender) {
                      bool isSelected = selectedGender == gender;
                      return Container(
                        width: 105,
                        child: ChoiceChip(
                          showCheckmark: false,
                          label: Container(
                            alignment: Alignment.center,
                            child: Text(
                              capitalize(gender),
                              style: TextStyle(
                                color: isSelected ? primaryApp : greyColor,
                                fontFamily: isSelected ? semiBold : regular,
                              ),
                            ).text.size(14).make(),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedGender = gender;
                              });
                            }
                          },
                          selectedColor: thinPrimaryApp,
                          backgroundColor: whiteColor,
                          side: isSelected
                              ? const BorderSide(color: primaryApp, width: 2)
                              : const BorderSide(color: greyLine),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 15),
                  const Text("Collection")
                      .text
                      .size(16)
                      .color(blackColor)
                      .fontFamily(medium)
                      .make(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 1,
                    children: [
                      'summer',
                      'winter',
                      'autumn',
                      'dinner',
                      'everydaylook'
                    ].map((collection) {
                      bool isSelected =
                          selectedCollections.contains(collection);
                      return ChoiceChip(
                        showCheckmark: false,
                        label: Container(
                          width: 75,
                          alignment: Alignment.center,
                          child: Text(
                            capitalize(collection),
                            style: TextStyle(
                              color: isSelected ? primaryApp : greyColor,
                              fontFamily: isSelected ? semiBold : regular,
                            ),
                          ).text.size(14).make(),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (isSelected) {
                              selectedCollections.remove(collection);
                            } else {
                              selectedCollections.add(collection);
                            }
                          });
                        },
                        selectedColor: thinPrimaryApp,
                        backgroundColor: whiteColor,
                        side: isSelected
                            ? const BorderSide(color: primaryApp, width: 2)
                            : const BorderSide(color: greyLine, width: 1.3),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          "Explain clothing matching",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: medium,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: explanationController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Enter your explanation here',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Color.fromRGBO(240, 240, 240, 1),
                          ),
                          style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: regular,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).paddingSymmetric(horizontal: 12),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onSaveButtonPressed(BuildContext context) async {
    String currentUserUID = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserUID.isEmpty) {
      VxToast.show(context, msg: "User is not logged in.");
      print('Error: User is not logged in.');
      return;
    }

    Map<String, dynamic> userData = {
      'p_id_top': pIdTop,
      'p_id_lower': pIdLower,
      'p_collection': selectedCollections,
      'p_sex': selectedGender,
      'p_desc': explanationController.text,
    };

    await FirebaseFirestore.instance
        .collection('storemixandmatchs')
        .doc(document.id)
        .update(userData)
        .then((_) {
      VxToast.show(context, msg: "Match updated successfully.");
      print('Match updated successfully.');
    }).catchError((error) {
      print('Error updating match: $error');
      VxToast.show(context, msg: "Error updating match.");
    });
  }
}
