
import 'package:flutter/material.dart';
import 'package:translator/features/weidget_page/chose_translation.dart';

void showBottomSheetForLanguageSelection(BuildContext context ,bool isSource) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return Container(
          height: MediaQuery.of(context).size.height * 0.95,
          child: ChooseLanguage(isSource: isSource,));
    },
  );
}