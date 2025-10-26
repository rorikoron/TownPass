import 'package:flutter/material.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_text.dart';

class HackathonDemoView extends StatelessWidget{
  const HackathonDemoView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TPAppBar(title: 'Hackathon Demo View'),
        body: SafeArea(
        child: Column(
        children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
             itemBuilder: (_, index) {
               return TPText("test texts! index: $index");
             }
            )
          ]
        )
      ),
    );
  }
}