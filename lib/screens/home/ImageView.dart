import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/timeline_images_model.dart';
import '../../widgets/image.dart';

class PhotoGrid extends StatefulWidget {
  final int maxImages;
  final List<TimelineImagesModel> imageUrls;
  final Function(int) onImageClicked;
  final Function onExpandClicked;

  PhotoGrid(
      {
        Key? key,
        required this.imageUrls,
        required this.onImageClicked,
        required this.onExpandClicked,
        this.maxImages = 4})
      : super(key: key);

  @override
  createState() => _PhotoGridState();
}

class _PhotoGridState extends State<PhotoGrid> {
  @override
  Widget build(BuildContext context) {
    var images = buildImages();
    return GridView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      children: images,
    );
  }

  List<Widget> buildImages() {
    int numImages = widget.imageUrls.length;
    return List<Widget>.generate(min(numImages, widget.maxImages), (index) {
      String imageUrl = widget.imageUrls[index].url;

      if(imageUrl.contains("http")){
        if (index == widget.maxImages - 1) {
          int remaining = numImages - widget.maxImages;

          if (remaining == 0) {
            return GestureDetector(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
              ),
              onTap: () => ImagePreview().preview(context, imageUrl, setState),
            );
          } else {
            return GestureDetector(
              onTap: () => widget.onExpandClicked(),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(fit: BoxFit.cover, imageUrl: imageUrl),
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.black54,
                      child: Text(
                        '+' + remaining.toString(),
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        } else {
          return GestureDetector(
            child: CachedNetworkImage(
              fit: BoxFit.cover, imageUrl: imageUrl,
            ),
            onTap: () => ImagePreview().preview(context, imageUrl, setState),
          );
        }

      }else{
        if (index == widget.maxImages - 1) {
          int remaining = numImages - widget.maxImages;

          if (remaining == 0) {
            return GestureDetector(
              child: Image.file(
                File(imageUrl!),
                fit: BoxFit.cover,
              ),
              onTap: () => ImagePreview().preview(context, imageUrl, setState),
            );
          } else {
            return GestureDetector(
              onTap: () => widget.onExpandClicked(),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(imageUrl!),
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.black54,
                      child: Text(
                        '+' + remaining.toString(),
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        } else {
          return GestureDetector(
            child: Image.file(
              File(imageUrl!),
              fit: BoxFit.cover,
            ),
            onTap: () => ImagePreview().preview(context, imageUrl, setState),
          );
        }
      }
    });
  }


}