import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:thelab/code/bluetooth/BluetoothHandler.dart';
import 'package:thelab/code/widgets/settings/menu_button.dart';
import 'package:thelab/code/widgets/settings/settings_sheet_media.dart';

class GalleryAccess extends StatefulWidget {
  final BluetoothHandler bluetoothHandler;

  const GalleryAccess({super.key, required this.bluetoothHandler});

  @override
  State<GalleryAccess> createState() => _GalleryAccessState();
}

class _GalleryAccessState extends State<GalleryAccess> {
  File? galleryFile;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor:
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
          shadowColor: Colors.transparent,
          leading: CustomIconButton(
            icon: Icons.settings,
            onPressed: () {
              SideSheet.left(
                  body: const SettingsSheetMedia(), context: context);
            },
          ),
        ),
        body: Container(
          color:
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.secondary)),
                child: Text(
                  S.of(context)!.selectImage,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary),
                ),
                onPressed: () {
                  _showPicker(context: context);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: SizedBox(
                  height: 200,
                  child: galleryFile == null
                      ? Center(child: Text(S.of(context)!.sorryNothingSelected))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                              Image.file(
                                galleryFile!,
                                height: 150,
                              ),
                              IconButton(
                                  onPressed: () => _sendMedia(
                                      widget.bluetoothHandler, galleryFile),
                                  icon: const Icon(Icons.send_rounded))
                            ]),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          surfaceTintColor: Theme.of(context)
              .colorScheme
              .secondaryContainer
              .withOpacity(0.2),
          color:
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.mic_none,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                iconSize: 48.0,
              )
            ],
          ),
        ));
  }

  void _showPicker({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(S.of(context)!.library),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(S.of(context)!.camera),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future getImage(
    ImageSource img,
  ) async {
    final pickedFile = await picker.pickImage(source: img);
    XFile? xfilePick = pickedFile;
    setState(
      () {
        if (xfilePick != null) {
          galleryFile = File(pickedFile!.path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context)!.nothingSelected)));
        }
      },
    );
  }
}

_sendMedia(BluetoothHandler bluetoothHandler, File? galleryFile) async {
  if (galleryFile == null) {
    return;
  }

  File croppedFile = await _cropImageTo240x240AndCompress(galleryFile);
  String base64 = await _fileToBase64(croppedFile);

  bluetoothHandler.sendMediaOverBluetooth(base64);
}

Future<String> _fileToBase64(File file) async {
  List<int> bytes = await file.readAsBytes();
  String base64Image = base64Encode(bytes);
  return base64Image;
}

Future<File> _cropImageTo240x240AndCompress(File imageFile) async {
  int displayWidth = 240;

  File imageFileCompressed =
      await FlutterNativeImage.compressImage(imageFile.path, quality: 50);

  // Read the image file
  List<int> imageBytes = await imageFileCompressed.readAsBytes();
  img.Image? image = img.decodeImage(imageBytes);

  if (image == null) {
    // Return null or throw an error based on your requirement
    return Future.error('Failed to decode image');
  }

  // Crop the image to 240x240 pixels
  img.Image croppedImage = img.copyResizeCropSquare(image, displayWidth);

  // Encode the cropped image
  List<int> encodedBytes = img.encodePng(croppedImage);

  // Create a temporary file to save the cropped image
  String tempPath = await getTemporaryDirectoryPath();
  String tempFileName = '${DateTime.now().millisecondsSinceEpoch}.png';
  String tempFilePath = '$tempPath/$tempFileName';

  // Save the cropped image to the temporary file
  File tempFile = File(tempFilePath);
  await tempFile.writeAsBytes(encodedBytes);

  return tempFile;
}

Future<String> getTemporaryDirectoryPath() async {
  Directory tempDir = await getTemporaryDirectory();
  return tempDir.path;
}
