import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'image_asset_model.dart';
export 'image_asset_model.dart';

class ImageAssetWidget extends StatefulWidget {
  const ImageAssetWidget({super.key});

  @override
  State<ImageAssetWidget> createState() => _ImageAssetWidgetState();
}

class _ImageAssetWidgetState extends State<ImageAssetWidget> {
  late ImageAssetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImageAssetModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.asset(
        'assets/images/image.png',
        width: 26.0,
        height: 26.0,
        fit: BoxFit.cover,
      ),
    );
  }
}
