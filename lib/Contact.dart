import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Contact extends StatelessWidget {
  final dynamic user;
  final Function onClicked;

  Contact(this.user, this.onClicked);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
            // Renders a `Material` in its build method
            child: CachedNetworkImage(
          imageUrl: user['imageUrl'],
          height: 150,
          width: 150,
          imageBuilder: (context, imageProvider) {
            return Material(
              // color: Colors.blueAccent,
              child: Ink.image(
                image: imageProvider,
                fit: BoxFit.cover,
                child: InkWell(onTap: () {
                  onClicked.call(context);
                }),
              ),
            );
          },
          fadeOutDuration: Duration.zero,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(),
          ),
        )),
        Text(user['name'].toString())
      ],
    );
  }
}
