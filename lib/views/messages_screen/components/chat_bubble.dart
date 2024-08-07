import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seller_finalproject/const/const.dart';
import 'package:intl/intl.dart' as intl;
import 'package:seller_finalproject/const/styles.dart';

Widget chatBubble(DocumentSnapshot data) {
  var t =
      data['created_on'] == null ? DateTime.now() : data['created_on'].toDate();
  var time = intl.DateFormat("h:mma").format(t);
  bool isCurrentUser = data['uid'] == currentUser!.uid;

  return Directionality(
    textDirection: isCurrentUser ? TextDirection.ltr : TextDirection.ltr,
    child: Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isCurrentUser ? primaryMessage : greyMessage,
            borderRadius: isCurrentUser
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
          ),
          constraints: const BoxConstraints(maxWidth: 200),
          child: data['msg']
              .toString()
              .text
              .fontFamily(regular)
              .size(14)
              .color(isCurrentUser ? whiteColor : blackColor)
              .make(),
        ),
        Align(
          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: time.text
              .size(12)
              .fontFamily(regular)
              .color(blackColor.withOpacity(0.8))
              .make(),
        ),
        5.heightBox,
      ],
    ),
  );
}
