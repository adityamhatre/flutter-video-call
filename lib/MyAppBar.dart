import 'package:flutter/material.dart';

class MyAppBar extends AppBar {
  late final Widget title;

  MyAppBar({required appBarTitle}) {
    this.title = appBarTitle;
  }

  Widget build(BuildContext context) {
    return this;
  }
}
