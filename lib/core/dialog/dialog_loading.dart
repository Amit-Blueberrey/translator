import 'package:flutter/material.dart';

class MyDialogs {
  static Future<void> showLoadingDialog(BuildContext context, {bool isShowing = true}) async {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () => Future.value(false), // Prevent dismissal by back button
        child: AlertDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(width * 0.02)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download,color: Colors.blue,),
                  SizedBox(width: width*0.05,),
                  Text("Please Wait .....", style: TextStyle(fontSize: height * 0.018)),
                ],
              ),
              SizedBox(height: height * 0.015),
              CircularProgressIndicator(
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop(); // Dismiss dialog from anywhere
  }
}




// class popSOS extends StatelessWidget {
//   const popSOS({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         child: Column(
//           children: [
//             Text("gdnnx"),
            
//             Row(() =>
//               length: 3
//                 return Container(
//                       padding: EdgeInsets.all(padding),
//                       decoration: BoxDecoration(
//                         color: Colors.green[50],
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Column(
//                         children: [
//                           Text(
//                             'Sarah',
//                             style: TextStyle(
//                               fontSize: screenWidth * 0.05,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                           ),
//                           SizedBox(height: screenHeight * 0.01),
//                           Text(
//                             'Reading these quotes daily has brought a sense of peace and purpose into my life. This app is a',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: screenWidth * 0.04,
//                               color: Colors.black54,
//                             ),
//                           ),
//                           SizedBox(height: screenHeight * 0.01),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: List.generate(5, (index) {
//                               return Icon(
//                                 Icons.star,
//                                 color: Colors.amber,
//                                 size: screenWidth * 0.07,
//                               );
//                             }),
//                           ),
//                         ],
//                       ),
//                     ),
              
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
