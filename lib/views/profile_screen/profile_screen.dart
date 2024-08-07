import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seller_finalproject/const/const.dart';
import 'package:seller_finalproject/const/styles.dart';
import 'package:seller_finalproject/controllers/auth_controller.dart';
import 'package:seller_finalproject/controllers/loading_Indcator.dart';
import 'package:seller_finalproject/controllers/profile_controller.dart';
import 'package:seller_finalproject/services/store_services.dart';
import 'package:seller_finalproject/views/auth_screen/login_screen.dart';
import 'package:seller_finalproject/views/messages_screen/messages_screen.dart';
import 'package:seller_finalproject/views/profile_screen/editprofile_screen.dart';
import 'package:seller_finalproject/views/profile_screen/allreview_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Setting',
          style: TextStyle(fontFamily: medium, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: StoreServices.getProfileStream(currentUser?.uid ?? ''),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return loadingIndicator(circleColor: primaryApp);
                } else if (!snapshot.data!.exists) {
                  return const Center(child: Text('No Profile Data'));
                } else {
                  controller.snapshotData = snapshot.data!;
                  return ListView(
                    children: [
                      Center(
                        child: Row(
                          children: [
                            25.widthBox,
                            Container(
                              width: 80,
                              height: 80,
                              child: controller.snapshotData['imageUrl'] == ''
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.asset(
                                        imgProfile,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      )
                                          .box
                                          .roundedFull
                                          .clip(Clip.antiAlias)
                                          .make(),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.network(
                                        controller.snapshotData['imageUrl'],
                                        width: 100,
                                      )
                                          .box
                                          .roundedFull
                                          .clip(Clip.antiAlias)
                                          .make(),
                                    ),
                            )
                                .box
                                .border(color: greyLine, width: 2)
                                .roundedFull
                                .make(),
                            15.widthBox,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${controller.snapshotData['name']}")
                                      .text
                                      .size(16)
                                      .fontFamily(medium)
                                      .fontFamily(bold)
                                      .make(),
                                  Text("${controller.snapshotData['email']}")
                                      .text
                                      .size(14)
                                      .fontFamily(medium)
                                      .make(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      10.heightBox,
                      const Divider(color: greyThin),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Image.asset(
                              icMe,
                              width: 22,
                            ),
                            title:
                                const Text('Edit Account').text.size(15).make(),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: () async {
                              bool? result =
                                  await Get.to(() => EditProfileScreen(
                                        username:
                                            controller.snapshotData['name'],
                                      ));
                              if (result == true) {
                                setState(() {
                                  // Refresh data
                                  controller.fetchUserData();
                                });
                              }
                            },
                          ),
                          ListTile(
                            leading: Image.asset(
                              icMessage,
                              width: 22,
                            ),
                            title: const Text('Message').text.size(15).make(),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: () {
                              Get.to(() => MessagesScreen(
                                  userName: controller.snapshotData['name']));
                            },
                          ),
                          ListTile(
                            leading: Image.asset(
                              icReview,
                              width: 22,
                            ),
                            title: const Text('Review from customer')
                                .text
                                .color(greyDark)
                                .fontFamily(medium)
                                .size(15)
                                .make(),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: () {
                              String vendorId = currentUser?.uid ??
                                  ''; // ดึงค่า id ของผู้ใช้งานปัจจุบัน
                              print('vendorId: $vendorId'); // พิมพ์ค่า vendorId
                              Get.to(() => AllReviewScreen(vendorId: vendorId));
                            },
                          ),
                        ],
                      ).box.padding(const EdgeInsets.all(4)).make(),
                    ],
                  ).box.padding(const EdgeInsets.all(24)).make();
                }
              },
            ),
          ),
          buildActionsSection(context)
        ],
      ),
    );
  }

  Widget buildActionsSection(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 30),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.transparent),
          ),
          onPressed: () => showLogoutDialog(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icLogout, width: 15),
              15.widthBox,
              const SizedBox(width: 8),
              const Text('Logout')
                  .text
                  .color(greyDark)
                  .fontFamily(medium)
                  .make(),
            ],
          ),
        )
            .box
            .color(greyThin)
            .rounded
            .margin(const EdgeInsets.fromLTRB(24, 0, 24, 30))
            .padding(const EdgeInsets.symmetric(horizontal: 8))
            .make(),
      ],
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              25.heightBox,
              const Text('Confirm Logout')
                  .text
                  .size(22)
                  .fontFamily(semiBold)
                  .color(greyDark)
                  .make(),
              10.heightBox,
              const Text('Are you sure you want to log out?')
                  .text
                  .size(14)
                  .fontFamily(regular)
                  .color(greyDark)
                  .make(),
              25.heightBox,
              const Divider(
                height: 1,
                color: greyLine,
              ),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextButton(
                        child: const Text('Cancel',
                            style: TextStyle(
                                color: redColor,
                                fontFamily: medium,
                                fontSize: 14)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const VerticalDivider(
                        width: 1, thickness: 1, color: greyLine),
                    Expanded(
                      child: TextButton(
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                              color: greyDark,
                              fontFamily: medium,
                              fontSize: 14),
                        ),
                        onPressed: () async {
                          await Get.put(AuthController())
                              .signoutMethod(context);
                          Navigator.of(dialogContext).pop();
                          Get.offAll(() => const LoginScreen());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).box.white.roundedLg.make(),
        );
      },
    );
  }
}
