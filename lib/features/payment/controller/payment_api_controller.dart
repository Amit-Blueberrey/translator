import 'dart:convert';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:translator/core/navigation/navigation_service.dart';
import 'package:translator/data/dbhelper.dart';

class Paymenthandelcontroller extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  RxString app_user_id = "".obs;
  RxDouble price = 0.0.obs;
  RxString productID = "".obs;
  RxString currency = "".obs;
  RxString email = "".obs;
  RxString name = "".obs;
  RxString osType = "".obs;
  RxString ip = "".obs;
  RxBool isFirstTime = true.obs;

  Future<void> sendPurchaseDataToServer() async {
    print('call Api 1');
    print('call Api 2');
    osType.value = Platform.isAndroid ? 'android' : 'ios';
    print('Name of the user: ${name}');
    print('User email addres: ${email}');
    print('User subscription: ${app_user_id}');

    Map<String, dynamic> requestBody = {
      'name': name.value,
      'productid': productID.value,
      'app_user_id': app_user_id.value,
      'amt': currency.value,
      'email': email.value,
      'os_type': osType.value,
      'ip': ip.value,
      "app_name": "translator"
    };
    print(requestBody);

    String requestBodyJson = jsonEncode(requestBody);
    String apiUrl =
        'https://appvpn.cloudtevent.com/api/in-app/lander/payment-confirm';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: requestBodyJson,
      );

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        var responseBody = jsonDecode(response.body);
        // Extract the 'is_paid' value from the response body
        bool isPaid = responseBody['users']['is_paid'];
        String token = responseBody['token'];
        TranslationDb.isPaid = isPaid;
        TranslationDb.token = token;
        // Save the 'is_paid' value to Pref.ispaid
        // Handle the response body here
        print('Response Body: $responseBody');
        // For example, you can save response data to a variable or process it as needed
        // ...
        // await userlogController.initDeviceInfo();
        print('analytics: Payment_success_new_user');
        await analytics.logEvent(
            name: 'payment_success_new_user',
            parameters: <String, Object>{
              'name': name.value,
              'productid': productID.value,
              'app_user_id': app_user_id.value,
              'amt': currency.value,
              'email': email.value,
              'os_type': osType.value,
              'ip': ip.value,
              'app_name': 'translator',
              'user_isPaid': '$isPaid',
              'token': '$token',
            });
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       backgroundColor: Color.fromARGB(224, 0, 188, 34),
        //       content: Text('Payment successful 🎉  🥳'),
        //       duration: Duration(seconds: 7),
        //       onVisible: () {
        //         Get.offAllNamed("/home");
        //       }, // Adjust the duration as needed
        //     ),
        //   );
        NavigationService.replaceTo('/translator');
      } else {
        // If the server returns a non-200 status code, handle the error
        await analytics.logEvent(
            name: 'payment_error',
            parameters: <String, Object>{
              'name': name.value,
              'productid': productID.value,
              'app_user_id': app_user_id.value,
              'amt': currency.value,
              'email': email.value,
              'os_type': osType.value,
              'ip': ip.value,
              'app_name': 'translator',
              'response_code': '${response.statusCode}',
            });
        print('Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
        // Optionally, you can throw an exception or handle the error as needed
        throw Exception('Failed to send purchase data');
      }
    } catch (error) {
      // Handle any exceptions that occur during the HTTP request
      print('Exception: $error');
      // Optionally, you can rethrow the error or handle it as needed
      // ...
    }
  }

  void showCustomDialog(BuildContext context, VoidCallback onCancel) {
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              "Enter Name and Email",
              style: TextStyle(
                  // color: Theme.of(context).buttonColor,
                  // color: homeController.getButtonColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w600),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name (Required)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
                        if (!nameRegExp.hasMatch(value)) {
                          return 'Please enter a valid name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email (Required)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        final emailRegExp = RegExp(
                            r'^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$');
                        if (!emailRegExp.hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Perform actions with the entered data and close dialog
                            name.value = nameController.text;
                            email.value = emailController.text;
                            print('Name: $name, Email: $email');
                            Navigator.of(context).pop();
                            onCancel();
                          }
                        },
                        child: Text(
                          "Continue",
                          style: TextStyle(
                              // color: Theme.of(context).buttonColor,
                              // color: homeController.getButtonColor,
                              fontSize: 19,
                              fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
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
  }
}
