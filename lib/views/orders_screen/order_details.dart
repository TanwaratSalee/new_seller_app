import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:seller_finalproject/const/styles.dart';
import 'package:seller_finalproject/controllers/loading_Indcator.dart';
import 'package:seller_finalproject/controllers/orders_controller.dart';
import 'package:seller_finalproject/controllers/profile_controller.dart';
import 'package:seller_finalproject/views/messages_screen/chat_screen.dart';
import 'package:seller_finalproject/views/messages_screen/messages_screen.dart';
import 'package:seller_finalproject/views/widgets/our_button.dart';
import '../../const/const.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart' as intl;

class OrderDetails extends StatefulWidget {
  final dynamic data;
  const OrderDetails({super.key, this.data});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  var controller = Get.find<OrdersController>();

  @override
  void initState() {
    super.initState();
    controller.getOrders(widget.data);
    controller.confirmed.value = widget.data['order_confirmed'];
    controller.ondelivery.value = widget.data['order_on_delivery'];
    controller.delivered.value = widget.data['order_delivered'];
  }

  String formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length == 10) {
      final RegExp regExp = RegExp(r'(\d{3})(\d{3})(\d{4})');
      return cleaned.replaceAllMapped(regExp, (Match match) {
        return '(+66) ${match[1]}-${match[2]}-${match[3]}';
      });
    } else if (cleaned.length == 9) {
      final RegExp regExp = RegExp(r'(\d{2})(\d{3})(\d{4})');
      return cleaned.replaceAllMapped(regExp, (Match match) {
        return '(+66) ${match[1]}-${match[2]}-${match[3]}';
      });
    }
    return phone;
  }

  Future<Map<String, dynamic>> getProductDetails(String productId) async {
    if (productId.isEmpty) {
      debugPrint('Error: productId is empty.');
      return {
        'name': 'Unknown Product',
        'id': productId,
        'imageUrl': '',
        'price': 0.0
      };
    }

    try {
      var productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      if (productSnapshot.exists) {
        debugPrint('Document ID: ${productSnapshot.id}');
        var productData = productSnapshot.data() as Map<String, dynamic>?;
        return {
          'name': productData?['name'] ?? 'Unknown Product',
          'id': productId,
          'imageUrl':
              (productData?['imgs'] != null && productData!['imgs'].isNotEmpty)
                  ? productData['imgs'][0]
                  : '',
          'price': productData != null && productData['price'] != null
              ? double.parse(productData['price'].toString())
              : 0.0,
        };
      } else {
        return {
          'name': 'Unknown Product',
          'id': productId,
          'imageUrl': '',
          'price': 0.0
        };
      }
    } catch (e) {
      debugPrint('Error getting product details: $e');
      return {
        'name': 'Unknown Product',
        'id': productId,
        'imageUrl': '',
        'price': 0.0
      };
    }
  }

  Future<Map<String, String>> getVendorDetails(String vendorId) async {
    if (vendorId.isEmpty) {
      debugPrint('Error: vendorId is empty.');
      return {'name': 'Unknown Vendor', 'imageUrl': ''};
    }

    try {
      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(vendorId)
          .get();
      if (userSnapshot.exists) {
        var vendorData = userSnapshot.data() as Map<String, dynamic>?;
        return {
          'name': vendorData?['name'] ?? 'Unknown Vendor',
          'imageUrl': vendorData?['imageUrl'] ?? ''
        };
      } else {
        return {'name': 'Unknown Vendor', 'imageUrl': ''};
      }
    } catch (e) {
      debugPrint('Error getting vendor details: $e');
      return {'name': 'Unknown Vendor', 'imageUrl': ''};
    }
  }

  Future<String> getChatDocId(String userId) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (currentUserId.isEmpty) {
        throw Exception('Current user ID is empty');
      }

      var chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .where('user_id', isEqualTo: userId)
          .where('vendor_id', isEqualTo: currentUserId)
          .limit(1)
          .get();

      if (chatDoc.docs.isNotEmpty) {
        return chatDoc.docs.first.id;
      } else {
        // Create a new chat document if none exists
        var newChatDoc =
            await FirebaseFirestore.instance.collection('chats').add({
          'user_id': userId,
          'vendor_id': currentUserId,
          'created_on': FieldValue.serverTimestamp(),
          'last_msg': '',
          'users': {userId: null, currentUserId: null},
        });
        return newChatDoc.id;
      }
    } catch (e) {
      debugPrint('Error fetching or creating chatDocId: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
          appBar: AppBar(
            title: const Text("Order Details")
                .text
                .size(24)
                .fontFamily(medium)
                .make(),
          ),
          bottomNavigationBar: Visibility(
            visible: !controller.confirmed.value,
            child: SizedBox(
              height: 100,
              width: context.screenWidth,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 30),
                child: ourButton(
                  color: primaryApp,
                  onPress: () {
                    controller.confirmed(true);
                    controller.changeStatus(
                        title: "order_confirmed",
                        status: true,
                        docID: widget.data.id);
                  },
                  title: "Confirm Order",
                  textColor: whiteColor,
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Visibility(
                    visible: controller.confirmed.value,
                    child: Column(
                      children: [
                        10.heightBox,
                        const Text("Order Status")
                            .text
                            .fontFamily(semiBold)
                            .size(20)
                            .make(),
                        ListTile(
                          title: const Text("Placed"),
                          trailing: Switch(
                            activeColor: whiteColor,
                            activeTrackColor: primaryApp,
                            inactiveThumbColor: greyDark,
                            inactiveTrackColor: whiteColor,
                            value: true,
                            onChanged: (value) {},
                          ),
                        ),
                        ListTile(
                          title: const Text("Confirmed"),
                          trailing: Switch(
                            activeColor: whiteColor,
                            activeTrackColor: primaryApp,
                            inactiveThumbColor: greyDark,
                            inactiveTrackColor: whiteColor,
                            value: controller.confirmed.value,
                            onChanged: (value) {
                              controller.confirmed.value = value;
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text("On Delivery"),
                          trailing: Switch(
                            activeColor: whiteColor,
                            activeTrackColor: primaryApp,
                            inactiveThumbColor: greyDark,
                            inactiveTrackColor: whiteColor,
                            value: controller.ondelivery.value,
                            onChanged: (value) {
                              controller.ondelivery.value = value;
                              controller.changeStatus(
                                  title: "order_on_delivery",
                                  status: value,
                                  docID: widget.data.id);
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text("Delivered"),
                          trailing: Switch(
                            activeColor: whiteColor,
                            activeTrackColor: primaryApp,
                            inactiveThumbColor: greyDark,
                            inactiveTrackColor: whiteColor,
                            value: controller.delivered.value,
                            onChanged: (value) {
                              controller.delivered.value = value;
                              controller.changeStatus(
                                  title: "order_delivered",
                                  status: value,
                                  docID: widget.data.id);
                            },
                          ),
                        ),
                      ],
                    )
                        .box
                        .color(whiteColor)
                        .roundedSM
                        .border(color: greyLine)
                        .padding(const EdgeInsets.symmetric(horizontal: 18))
                        .make(),
                  ),
                  15.heightBox,
                  Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Shipping Address",
                          ).text.size(20).black.fontFamily(medium).make(),
                          5.heightBox,
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined),
                              20.widthBox,
                              Text(
                                  "${widget.data['address']['order_by_firstname'] ?? ''} ${widget.data['address']['order_by_surname'] ?? ''},\n"
                                  "${widget.data['address']['order_by_address'] ?? ''},\n"
                                  "${widget.data['address']['order_by_city'] ?? ''}, "
                                  "${widget.data['address']['order_by_state'] ?? ''}, "
                                  "${widget.data['address']['order_by_postalcode'] ?? ''}\n"
                                  "${formatPhoneNumber(widget.data['address']['order_by_phone'] ?? '')}"),
                            ],
                          ),
                        ],
                      )
                          .box
                          .color(whiteColor)
                          .roundedSM
                          .border(color: greyLine)
                          .padding(const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 12))
                          .make(),
                      const SizedBox(height: 15),
                      Container(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text('Order Code :    ')
                                        .text
                                        .size(14)
                                        .black
                                        .fontFamily(semiBold)
                                        .make(),
                                    Text(widget.data['order_id'] ??
                                        'N/A') // เพิ่ม default value
                                  ],
                                ),
                                5.heightBox,
                                Row(
                                  children: [
                                    Text('Order Date :    ')
                                        .text
                                        .size(14)
                                        .black
                                        .fontFamily(semiBold)
                                        .make(),
                                    Text(widget.data['created_at'] != null
                                        ? intl.DateFormat().add_yMd().format(
                                            (widget.data['created_at']
                                                .toDate()))
                                        : 'N/A') // เพิ่ม default value
                                  ],
                                ),
                                5.heightBox,
                                Row(
                                  children: [
                                    Text('Payment Method :    ')
                                        .text
                                        .size(14)
                                        .black
                                        .fontFamily(semiBold)
                                        .make(),
                                    Text(widget.data['payment_method'] ??
                                        'N/A') // เพิ่ม default value
                                  ],
                                ),
                              ],
                            )),
                      )
                          .box
                          .color(whiteColor)
                          .roundedSM
                          .border(color: greyLine)
                          .padding(const EdgeInsets.all(6))
                          .make(),
                    ],
                  ),
                  15.heightBox,
                  GestureDetector(
                    onTap: () async {
                      String chatDocId =
                          await getChatDocId(widget.data['user_id']);
                      if (chatDocId.isNotEmpty) {
                        Get.to(() => ChatScreen(
                              userName: widget.data['address']
                                  ['order_by_firstname'],
                              chatDocId: chatDocId,
                              friendId:
                                  widget.data['user_id'], // Customer's UID
                              sellerId:
                                  FirebaseAuth.instance.currentUser?.uid ??
                                      '', // Current user's UID (seller)
                              userImageUrl:
                                  "", // Pass the correct user image URL if available
                            ));
                      } else {
                        // Handle the case where chatDocId could not be generated or fetched
                        debugPrint('Error: chatDocId is empty');
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              icMessage,
                              width: 25,
                            ),
                            SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chat with purchaser',
                                  style: TextStyle(
                                    color: blackColor,
                                    fontFamily: medium,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Product, pre-shipping issues, and other questions',
                                  style: TextStyle(
                                    color: greyDark,
                                    fontFamily: regular,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Image.asset(
                          icSeeAll,
                          width: 12,
                        ),
                      ],
                    ),
                  )
                      .box
                      .color(whiteColor)
                      .padding(EdgeInsets.fromLTRB(6, 10, 6, 10))
                      .roundedSM
                      .border(color: greyLine)
                      .make(),
                  15.heightBox,
                  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(
                          children: [
                            Image.asset(iconsStore, width: 20),
                            10.widthBox,
                            const Text("Order Lists")
                                .text
                                .size(16)
                                .fontFamily(semiBold)
                                .make(),
                          ],
                        ),
                        5.heightBox,
                        Divider(
                          color: greyLine,
                        ),
                        5.heightBox,
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: controller.orders.length,
                          itemBuilder: (context, index) {
                            var productId =
                                controller.orders[index]['product_id'];
                            return FutureBuilder<Map<String, dynamic>>(
                              future: getProductDetails(productId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return loadingIndicator();
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return Text('Error loading product details');
                                }

                                var productDetails = snapshot.data!;
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("${controller.orders[index]['qty']}x",
                                        style: const TextStyle(
                                            fontSize: 14, fontFamily: regular)),
                                    const SizedBox(width: 5),
                                    Image.network(
                                      productDetails['imageUrl'],
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ).box.color(whiteOpacity).make(),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 180,
                                          child: Text(
                                            productDetails['name'],
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: medium),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          "${NumberFormat('#,##0').format(productDetails['price'])} Bath",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: regular,
                                              color: greyColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ).paddingSymmetric(vertical: 3);
                              },
                            );
                          },
                        ),
                        8.heightBox,
                        Text("Total ${NumberFormat('#,##0').format(double.parse((widget.data['total_amount'] ?? '0').toString()).toInt())} Bath")
                            .text
                            .size(16)
                            .fontFamily(medium)
                            .make(),
                      ])
                      .box
                      .color(whiteColor)
                      .roundedSM
                      .padding(EdgeInsets.all(18))
                      .border(color: greyLine)
                      .make(),
                  100.heightBox,
                ],
              ),
            ),
          )),
    );
  }
}
