import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seller_finalproject/const/const.dart';
import 'package:seller_finalproject/controllers/home_controller.dart';
import 'package:seller_finalproject/models/collection_model.dart';
import 'package:path/path.dart';

class ProductsController extends GetxController {
  var isloading = false.obs;

  //text field controllers

  var pnameController = TextEditingController();
  var pabproductController = TextEditingController();
  var pdescController = TextEditingController();
  var psizeController = TextEditingController();
  var ppriceController = TextEditingController();
  var pquantityController = TextEditingController();
  var explainController = TextEditingController();

  var collectionsList = <String>[].obs;
  var subcollectionList = <String>[].obs;
  List<Collection> collection = [];
  var pImagesLinks = [];
  var pImagesList = RxList<dynamic>.generate(9, (index) => null);

  var collectionsvalue = ''.obs;
  var subcollectionvalue = ''.obs;
  var selectedColorIndex = 0.obs;

  final RxSet<int> selectedColorIndexes = <int>{}.obs;

  List<String> sizesList = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  RxString selectedGender = ''.obs;
  List<String> genderList = [ 'All','Male', 'Female'];
  RxString selectedSize = ''.obs;

  RxString selectedSkinColor = ''.obs;
  List<Map<String, dynamic>> skinColorList = [
  {'name': 'Light', 'color': Color(0xFFFFDBAC)},   
  {'name': 'Medium', 'color': Color(0xFFE5A073)},  
  {'name': 'Medium', 'color': Color(0xFFCD8C5C)},  
  {'name': 'Dark', 'color': Color(0xFF5C3836)},    
];


   final List<Map<String, dynamic>> allColors = [
    {'name': 'Black', 'color': Colors.black},
    {'name': 'Grey', 'color': Colors.grey},
    {'name': 'White', 'color': Colors.white},
    {'name': 'Purple', 'color': Colors.purple},
    {'name': 'Deep Purple', 'color': Colors.deepPurple},
    {'name': 'Blue', 'color': Colors.lightBlue},
    {'name': 'Blue', 'color': Color.fromARGB(255, 36, 135, 216)},
    {'name': 'Blue Grey', 'color': const Color.fromARGB(255, 96, 139, 115)},
    {'name': 'Green', 'color': Color.fromARGB(255, 17, 82, 50)},
    {'name': 'Green', 'color': Colors.green},
    {'name': 'Green Accent', 'color': Colors.greenAccent},
    {'name': 'Yellow', 'color': Colors.yellow},
    {'name': 'Orange', 'color': Colors.orange},
    {'name': 'Red', 'color': Colors.red},
    {'name': 'Red Accent', 'color': Color.fromARGB(255, 237, 101, 146)},
  ];

  getCollection() async {
    var data =
        await rootBundle.loadString("lib/services/collection_model.json");
    var cat = collectionModelFromJson(data);
    collection = cat.collections;
  }

  populateCollectionList() {
    collectionsList.clear();

    for (var item in collection) {
      collectionsList.add(item.name);
    }
  }

  populateSubcollection(cat) {
    subcollectionList.clear();

    var data = collection.where((element) => element.name == cat).toList();

    for (var i = 0; i < data.first.subcollection.length; i++) {
      subcollectionList.add(data.first.subcollection[i]);
    }
  }

  pickImage(index, context) async {
    try {
      final img = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (img == null) {
        return;
      } else {
        pImagesList[index] = File(img.path);
      }
    } catch (e) {
      VxToast.show(context, msg: e.toString());
    }
  }

  uploadImages() async {
    pImagesLinks.clear();
    for (var item in pImagesList) {
      if (item != null) {
        var filename = basename(item.path);
        var destination = 'images/vendors/${currentUser!.uid}/$filename';
        Reference ref = FirebaseStorage.instance.ref().child(destination);
        await ref.putFile(item);
        var n = await ref.getDownloadURL();
        pImagesLinks.add(n);
      }
    }
  }

  Future<void> uploadProduct(BuildContext context) async {
  try {
    isloading(true);
    // Make sure images are uploaded first if they aren't already
    if (pImagesLinks.isEmpty) {
      await uploadImages();
    }
    var store = firestore.collection(productsCollection).doc();
    await store.set({
      'is_featured': false,
      'p_collection': collectionsvalue.value,
      'p_subcollection': subcollectionvalue.value,
      'p_colors': selectedColorIndexes.map((index) => allColors[index]['color'].value).toList(),
      'p_imgs': FieldValue.arrayUnion(pImagesLinks),
      'p_wishlist': FieldValue.arrayUnion([]),
      'p_desc': pdescController.text,
      'p_name': pnameController.text,
      'p_aboutProduct': pabproductController.text,
      'p_size': psizeController.text,
      'p_price': ppriceController.text,
      'p_quantity': pquantityController.text,
      'p_seller': Get.find<HomeController>().username,
      'p_rating': "5.0",
      'vendor_id': currentUser!.uid,
      'featured_id': ''
    });
    isloading(false);
    VxToast.show(context, msg: "Product successfully uploaded.");
  } catch (e) {
    isloading(false);
    VxToast.show(context, msg: "Failed to upload product: $e");
    print(e.toString());  // For debugging purposes
  }
}


  addFeatured(docId) async {
    await firestore.collection(productsCollection).doc(docId).set({
      'featured_id': currentUser!.uid,
      'is_featured': true,
    }, SetOptions(merge: true));
  }

  removeFeatured(docId) async {
    await firestore.collection(productsCollection).doc(docId).set({
      'featured_id': '',
      'is_featured': false,
    }, SetOptions(merge: true));
  }

  removeProduct(docId) async {
    await firestore.collection(productsCollection).doc(docId).delete();
  }

  void addSelectedColorIndex(int index) {
    selectedColorIndexes.add(index);
    updateSelectedColorsInFirebase();
  }

  void removeSelectedColorIndex(int index) {
    selectedColorIndexes.remove(index);
    updateSelectedColorsInFirebase();
  }

  void updateSelectedColorsInFirebase() async {
  try {
    // Create a list of selected colors from their indices
    var selectedColorsValues = selectedColorIndexes.map((index) => allColors[index]['color'] as Color).toList();

    // Your Firebase operation here...
  } catch (e) {
    print("Error: $e");
  }
}


  bool isSelectedColorIndex(int index) {
    return selectedColorIndexes.contains(index);
  }

  bool isDataComplete() {
  return pnameController.text.isNotEmpty &&
      pabproductController.text.isNotEmpty &&
      pdescController.text.isNotEmpty &&
      psizeController.text.isNotEmpty &&
      ppriceController.text.isNotEmpty &&
      pquantityController.text.isNotEmpty &&
      collectionsvalue.isNotEmpty &&
      subcollectionvalue.isNotEmpty &&
      selectedColorIndexes.isNotEmpty; // เพิ่มเงื่อนไขสำหรับสีที่ถูกเลือก
}

void resetForm() {
  pnameController.clear();
  pabproductController.clear();
  pdescController.clear();
  psizeController.clear();
  ppriceController.clear();
  pquantityController.clear();
  pImagesList.value = List<dynamic>.filled(9, null, growable: false);
  selectedColorIndexes.clear();
  collectionsvalue.value = '';
  subcollectionvalue.value = '';
  pImagesLinks.clear();
}



  MatchProducts(text) {}
}
