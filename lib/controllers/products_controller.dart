import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seller_finalproject/const/const.dart';
import 'package:seller_finalproject/models/collection_model.dart';
import 'package:path/path.dart';

class ProductsController extends GetxController {
  var isloading = false.obs;
  var productId = ''.obs;
  var averageRating = 0.0.obs;
  var reviewCount = 0.obs;
  var documentId = ''.obs;

  // Text field controllers
  var pnameController = TextEditingController();
  var pabproductController = TextEditingController();
  var pdescController = TextEditingController();
  var psizedesController = TextEditingController();
  var ppriceController = TextEditingController();
  var pquantityController = TextEditingController();
  var explainController = TextEditingController();

  var collectionsList = <String>[].obs;
  List<Collection> collection = [];
  var pImagesLinks = [];
  var pImagesList = RxList<dynamic>(List.filled(9, null, growable: true));

  List<String> imagesToDelete = [];
  var collectionsvalue = ''.obs;
  var selectedColorIndex = 0.obs;
  var selectedCollections = <String>[].obs;

  List<String> sizesList = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final selectedSizes = <String>[].obs;
  List<String> genderList = ['all', 'men', 'women'];
  RxString selectedGender = ''.obs;
  List<String> mixandmatchList = ['top', 'lower', 'not specified'];
  RxString selectedMixandmatch = ''.obs;
  List<String> situationList = [
    'formal',
    'semi-formal',
    'casual',
    'special-activity',
    'seasonal',
    'work-from-home'
  ];

  Map<String, String> situationDisplay = {
    'formal': 'Formal Attire',
    'semi-formal': 'Semi-Formal Attire',
    'casual': 'Casual Attire',
    'special-activity': 'Special Activity Attire',
    'seasonal': 'Seasonal Attire',
    'work-from-home': 'Work from Home',
  };

  final selectedSituations = <String>[].obs;
  List<String> collectionList = [
    'summer',
    'spring',
    'winter',
    'autumn',
  ];
  final selectedCollection = <String>[].obs;
  List<String> subcollectionList = [
    't-shirts',
    'skirts',
    'pants',
    'dresses',
    'jackets',
    'suits'
  ];
  RxString selectedSubcollection = ''.obs;

  final CollectionReference vendersCollection =
      FirebaseFirestore.instance.collection('venders');
  final String userId = currentUser!.uid;

  RxString selectedSkinColor = ''.obs;
  List<Map<String, dynamic>> skinColorList = [
    {'name': 'Light', 'color': const Color(0xFFFFDBAC)},
    {'name': 'Medium', 'color': const Color(0xFFE5A073)},
    {'name': 'Medium', 'color': const Color(0xFFCD8C5C)},
    {'name': 'Dark', 'color': const Color(0xFF5C3836)},
  ];

  RxList<int> selectedColorIndexes = <int>[].obs;
  final List<Map<String, dynamic>> allColors = [
    {'name': 'Black', 'color': Colors.black, 'value': 0xFF000000},
    {'name': 'Grey', 'color': greyColor, 'value': 0xFF808080},
    {'name': 'White', 'color': whiteColor, 'value': 0xFFFFFFFF},
    {
      'name': 'Purple',
      'color': const Color.fromRGBO(98, 28, 141, 1),
      'value': 0xFF621C8D
    },
    {
      'name': 'Deep Purple',
      'color': const Color.fromRGBO(202, 147, 235, 1),
      'value': 0xFFCA93EB
    },
    {
      'name': 'Blue',
      'color': Color.fromRGBO(32, 47, 179, 1),
      'value': 0xFF202FB3
    },
    {
      'name': 'Blue',
      'color': const Color.fromRGBO(48, 176, 232, 1),
      'value': 0xFF30B0E8
    },
    {
      'name': 'Blue Grey',
      'color': const Color.fromRGBO(83, 205, 191, 1),
      'value': 0xFF53CDBF
    },
    {
      'name': 'Green',
      'color': const Color.fromRGBO(23, 119, 15, 1),
      'value': 0xFF17770F
    },
    {
      'name': 'Green',
      'color': Color.fromRGBO(98, 207, 47, 1),
      'value': 0xFF62CF2F
    },
    {'name': 'Yellow', 'color': Colors.yellow, 'value': 0xFFFFFF00},
    {'name': 'Orange', 'color': Colors.orange, 'value': 0xFFFFA500},
    {'name': 'Pink', 'color': Colors.pinkAccent, 'value': 0xFFFF4081},
    {'name': 'Red', 'color': Colors.red, 'value': 0xFFFF0000},
    {
      'name': 'Brown',
      'color': Color.fromARGB(255, 121, 58, 31),
      'value': 0xFF793A1F
    },
  ];

  Rxn<Product> selectedTopProduct = Rxn<Product>();
  Rxn<Product> selectedLowerProduct = Rxn<Product>();

  void toggleCollection(String collection) {
    if (selectedCollections.contains(collection)) {
      selectedCollections.remove(collection);
    } else {
      selectedCollections.add(collection);
    }
  }

  bool isCollectionSelected(String collection) {
    return selectedCollections.contains(collection);
  }

  void setSelectedProduct(Product product, String part) {
    if (part == 'top') {
      selectedTopProduct.value = product;
    } else if (part == 'lower') {
      selectedLowerProduct.value = product;
    }
    update();
  }

  getCollection() async {
    var data =
        await rootBundle.loadString("lib/services/collection_model.json");
    var cat = collectionModelFromJson(data);
    collection = cat.collections;
    populateCollectionList();
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

  Future<void> uploadImages(BuildContext context) async {
    pImagesLinks.clear();
    bool hasImage = false;
    for (var item in pImagesList) {
      if (item != null && item is File) {
        hasImage = true;
        var filename = basename(item.path);
        var destination = 'images/vendors/${currentUser!.uid}/$filename';
        Reference ref = FirebaseStorage.instance.ref().child(destination);
        await ref.putFile(item);
        var n = await ref.getDownloadURL();
        pImagesLinks.add(n);
      } else if (item is String) {
        hasImage = true;
        pImagesLinks.add(item);
      }
    }

    if (!hasImage) {
      VxToast.show(context, msg: "You must add at least one image.");
      throw Exception("No images selected");
    }
  }

  Future<void> uploadProduct(BuildContext context) async {
    try {
      if (pnameController.text.isEmpty) {
        VxToast.show(context, msg: "You forgot to enter the product name.");
        return;
      }
      if (selectedSituations.isEmpty) {
        VxToast.show(context,
            msg: "You forgot to enter the product situations.");
        return;
      }
      if (ppriceController.text.isEmpty) {
        VxToast.show(context, msg: "You forgot to enter the product price.");
        return;
      }
      if (pquantityController.text.isEmpty) {
        VxToast.show(context, msg: "You forgot to enter the product quantity.");
        return;
      }
      if (selectedCollection.isEmpty) {
        VxToast.show(context,
            msg: "You forgot to select the product collection.");
        return;
      }
      if (selectedSubcollection.value.isEmpty) {
        VxToast.show(context, msg: "You forgot to select the product type.");
        return;
      }
      if (selectedGender.value.isEmpty) {
        VxToast.show(context,
            msg: "You forgot to select the gender suitability.");
        return;
      }
      if (selectedSizes.isEmpty) {
        VxToast.show(context, msg: "You forgot to specify the product sizes.");
        return;
      }
      if (selectedColorIndexes.isEmpty) {
        VxToast.show(context, msg: "You forgot to select the product colors.");
        return;
      }
      if (selectedMixandmatch.value.isEmpty) {
        VxToast.show(context,
            msg:
                "You forgot to select whether the product is a top or lower part.");
        return;
      }

      isloading(true);
      // Make sure images are uploaded first if they aren't already
      if (pImagesLinks.isEmpty) {
        await uploadImages(context);
      }
      var store = firestore.collection(productsCollection).doc();
      productId.value = store.id;
      await store.set({
        // Default
        'product_id': productId.value,
        'name': pnameController.text,
        'imgs': FieldValue.arrayUnion(pImagesLinks),
        'favorite_uid': FieldValue.arrayUnion([]),
        'favorite_count': 0,
        'description': pdescController.text,
        'aboutProduct': pabproductController.text,
        'collection': selectedCollection,
        'situations': selectedSituations,
        'subcollection': selectedSubcollection.value,
        'gender': selectedGender.value,
        'productsize ': selectedSizes,
        'part': selectedMixandmatch.value,
        'colors': selectedColorIndexes
            .map((index) => allColors[index]['color'].value)
            .toList(),
        'sizedes': psizedesController.text,
        'price': ppriceController.text,
        'quantity': pquantityController.text,
        'rating': "5.0",
        'vendor_id': currentUser!.uid,
        'vendor_reference': vendersCollection.doc(userId),
        'created_at': Timestamp.now(),
      });
      isloading(false);
      VxToast.show(context, msg: "Product successfully uploaded.");
    } catch (e) {
      isloading(false);
      VxToast.show(context, msg: "Failed to upload product: $e");
      print(e.toString()); // For debugging purposes
    }
  }

  void toggleColorSelection(int index) {
    if (selectedColorIndexes.contains(index)) {
      selectedColorIndexes.remove(index);
    } else {
      selectedColorIndexes.add(index);
    }
  }

  void setupProductData(Map<String, dynamic> productData) {
    pnameController.text = productData['name'] ?? '';
    pabproductController.text = productData['aboutProduct'] ?? '';
    pdescController.text = productData['description'] ?? '';
    psizedesController.text = productData['sizedes'] ?? '';
    ppriceController.text = productData['price'] ?? '';
    pquantityController.text = productData['quantity'] ?? '';
    selectedGender.value = productData['gender'] ?? '';
    selectedMixandmatch.value = productData['part'] ?? '';
    selectedSubcollection.value = productData['subcollection'] ?? '';

    // ตั้งค่าสีที่เลือก
    selectedColorIndexes.clear();
    List<dynamic> colorNumbers = productData['colors'] ?? [];
    for (var colorNumber in colorNumbers) {
      int colorIndex =
          allColors.indexWhere((color) => color['value'] == colorNumber);
      if (colorIndex != -1) {
        selectedColorIndexes.add(colorIndex);
      } else {
        print('Color number $colorNumber not found in allColors.');
      }
    }

    // ตั้งค่าคอลเลคชั่นที่เลือก
    if (productData['collection'] != null) {
      selectedCollection
          .assignAll(List<String>.from(productData['collection']));
    } else {
      selectedCollection.clear();
    }

    if (productData['situations'] != null) {
      selectedSituations
          .assignAll(List<String>.from(productData['situations']));
    } else {
      selectedSituations.clear();
    }

    // ตั้งค่าขนาดที่เลือก
    if (productData['productsize '] != null) {
      selectedSizes.assignAll(List<String>.from(productData['productsize ']));
    } else {
      selectedSizes.clear();
    }

    // ตั้งค่ารูปภาพที่มีอยู่
    if (productData['imgs'] != null) {
      initializeImages(List<String>.from(productData['imgs']));
    }

    // Print out the values for debugging
    // print('Product Name: ${pnameController.text}');
    // print('About Product: ${pabproductController.text}');
    // print('Description: ${pdescController.text}');
    // print('Size: ${psizedesController.text}');
    // print('Price: ${ppriceController.text}');
    // print('Quantity: ${pquantityController.text}');
    // print('Gender: ${selectedGender.value}');
    // print('Mix and Match: ${selectedMixandmatch.value}');
    // print('Subcollection: ${selectedSubcollection.value}');
    // print('Raw color data: $colorNumbers');
    // print('Selected Color Indexes: $selectedColorIndexes');
    // print('Selected Collection: $selectedCollection');
    // print('Selected Sizes: $selectedSizes');
  }

  void initializeImages(List<String> imageUrls) {
    // Clear existing list and add fresh from imageUrls ensuring it's growable
    pImagesList.clear();
    for (int i = 0; i < imageUrls.length; i++) {
      pImagesList.add(imageUrls[i]);
    }
    // Ensure there are always 9 slots in the list
    while (pImagesList.length < 9) {
      pImagesList.add(null);
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < pImagesList.length) {
      if (pImagesList[index] is String) {
        imagesToDelete.add(pImagesList[index] as String);
      }
      pImagesList.removeAt(index); // Directly remove the item at the index
      pImagesList.add(null); // Optional: Maintain list size by adding null
    }
  }

  Future<void> updateProduct(BuildContext context, String documentId) async {
    try {
      final productDoc = FirebaseFirestore.instance
          .collection(productsCollection)
          .doc(documentId);
      await productDoc.update({
        'collection': selectedCollection,
        'situations': selectedSituations,
        'subcollection': selectedSubcollection.value,
        'gender': selectedGender.value,
        'productsize': selectedSizes,
        'part': selectedMixandmatch.value,
        'colors': selectedColorIndexes
            .map((index) => allColors[index]['value'])
            .toList(),
        'description': pdescController.text,
        'name': pnameController.text,
        'aboutProduct': pabproductController.text,
        'size': psizedesController.text,
        'price': ppriceController.text,
        'quantity': pquantityController.text,
        'vendor_id': currentUser!.uid,
        'imgs': FieldValue.arrayUnion(pImagesLinks),
      });

      if (imagesToDelete.isNotEmpty) {
        await productDoc.update({
          'imgs': FieldValue.arrayRemove(imagesToDelete),
        });
        imagesToDelete.clear();
      }

      // VxToast.show(context, msg: "Product updated successfully.");
    } catch (e) {
      print("Error updating product: $e");
      VxToast.show(context,
          msg: "Error updating product. Please try again later.");
    }
  }

  bool isDataComplete() {
    return pImagesList.any((image) => image != null) &&
        pnameController.text.isNotEmpty &&
        pdescController.text.isNotEmpty &&
        ppriceController.text.isNotEmpty &&
        pquantityController.text.isNotEmpty &&
        selectedCollection.isNotEmpty &&
        selectedSubcollection.isNotEmpty &&
        selectedGender.isNotEmpty &&
        selectedSizes.isNotEmpty &&
        selectedColorIndexes.isNotEmpty &&
        selectedMixandmatch.isNotEmpty;
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

  removeMatch(docId) async {
    await firestore.collection(storematchsCollection).doc(docId).delete();
  }

  bool fieldProducComplete() {
    return pImagesList.any((image) => image != null) &&
        pnameController.text.isNotEmpty &&
        pdescController.text.isNotEmpty &&
        ppriceController.text.isNotEmpty &&
        pquantityController.text.isNotEmpty &&
        selectedCollection.isNotEmpty &&
        selectedSubcollection.isNotEmpty &&
        selectedGender.isNotEmpty &&
        selectedSizes.isNotEmpty &&
        selectedColorIndexes.isNotEmpty &&
        selectedMixandmatch.isNotEmpty;
  }

  void resetForm() {
    pnameController.clear();
    pabproductController.clear();
    pdescController.clear();
    psizedesController.clear();
    ppriceController.clear();
    pquantityController.clear();
    selectedColorIndexes.clear();
    selectedCollection.clear();
    selectedSituations.clear();
    pImagesLinks.clear();
    selectedSubcollection.value = '';
    selectedGender.value = '';
    selectedSizes.clear();
    imagesToDelete.clear();
    pImagesList.clear();
    selectedMixandmatch.value = '';
    while (pImagesList.length < 9) {
      pImagesList.add(null);
    }
  }

  var reviews = <QueryDocumentSnapshot>[].obs;
  void loadProductReviews(String productId) async {
    documentId.value = productId;
    var reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('product_id', isEqualTo: productId)
        .get();

    if (reviewsSnapshot.docs.isNotEmpty) {
      var totalRating = reviewsSnapshot.docs
          .fold<double>(0.0, (sum, doc) => sum + doc['rating']);
      averageRating.value = totalRating / reviewsSnapshot.docs.length;
      reviewCount.value = reviewsSnapshot.docs.length;
      reviews.assignAll(reviewsSnapshot.docs);
    } else {
      averageRating.value = 0.0;
      reviewCount.value = 0;
      reviews.clear();
    }
  }
}

class Product {
  final String id;
  final String name;
  final String vendorId;
  final String part;
  final String price;
  final String gendermixmatch;
  final List<String> collectionsmixmatch;
  final List<String> colormixmatch;
  final List<String> imageUrls;

  Product({
    required this.id,
    required this.name,
    required this.vendorId,
    required this.part,
    required this.price,
    required this.gendermixmatch,
    required this.collectionsmixmatch,
    required this.colormixmatch,
    required this.imageUrls,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Product data is null');
    }

    return Product(
      id: doc.id,
      name: data['p_name'] ?? '',
      vendorId: data['vendor_id'] ?? '',
      part: data['p_part'] ?? '',
      price: data['p_price'] ?? '',
      gendermixmatch: data['p_mixmatch_sex'] ?? '',
      collectionsmixmatch:
          List<String>.from(data['p_mixmatch_collection'] ?? []),
      colormixmatch: List<String>.from(data['p_mixmatch_colors'] ?? []),
      imageUrls: List<String>.from(data['p_imgs'] ?? []),
    );
  }
}
