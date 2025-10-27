import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api_client.dart';
import '../../../core/endpoints.dart';
import '../../../app/widgets/error_view.dart';

class MemberPhotoEntryPage extends StatefulWidget {
  final String memberId;
  const MemberPhotoEntryPage({super.key, required this.memberId});

  @override
  State<MemberPhotoEntryPage> createState() => _MemberPhotoEntryPageState();
}

class _MemberPhotoEntryPageState extends State<MemberPhotoEntryPage> {
  final dio = makeDio();
  final ImagePicker _picker = ImagePicker();

  Uint8List? _photoBytes;
  String? _photoId;
  String? _photoFilePath;
  bool _loading = false;
  bool _modified = false;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    try {
      final res = await dio.post(
        ApiPaths.getMemberPhotoByMember,
        data: {
          'Id': widget.memberId,
          'id': widget.memberId,
          'Name': '',
          'name': '',
          'MemberCode': '',
          'memberCode': '',
        },
        options: Options(validateStatus: (s) => true),
      );

      if (res.statusCode == 200 && res.data != null) {
        final data = Map<String, dynamic>.from(res.data);

        _photoId = data['Id']?.toString() ?? data['id']?.toString();
        final photoBase64 = data['Photo'] ?? data['photo'];
        _photoFilePath = data['PhotoFilePath'] ?? data['photoFilePath'];

        if (photoBase64 != null && photoBase64.toString().isNotEmpty) {
          try {
            _photoBytes = base64Decode(photoBase64.toString());
          } catch (e) {
            debugPrint('⚠️ Error decoding photo: $e');
          }
        } else {
          _photoBytes = null;
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading photo: $e');
      rethrow;
    }
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    try {
      final picked = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (picked == null) return;

      final bytes = await File(picked.path).readAsBytes();

      final originalFileName = picked.path.split('/').last;
      final photoPath = '/photos/$originalFileName';

      debugPrint('📸 Picked file: $originalFileName');
      debugPrint('📸 Will upload with PhotoFilePath: $photoPath');

      setState(() {
        _photoBytes = bytes;
        _photoFilePath = photoPath;
        _modified = true;
      });
    } catch (e) {
      debugPrint('❌ Image pick error: $e');
    }
  }

  Future<void> _savePhoto() async {
    if (_photoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('እባክዎን ፎቶ ይምረጡ።')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final base64Photo = base64Encode(_photoBytes!);
      final body = {
        'Id': _photoId?.isNotEmpty == true ? _photoId : 'a',
        'MemberId': widget.memberId,
        'PhotoFilePath': _photoFilePath ?? '/photos/a.jpg',
        'Photo': base64Photo,
        'Remark': '',
      };

      debugPrint('📤 Uploading photo...');
      debugPrint('🆔 MemberId: ${widget.memberId}');
      debugPrint('🆔 PhotoId: $_photoId');
      debugPrint('📸 PhotoFilePath: $_photoFilePath');
      debugPrint('📸 Photo bytes length: ${_photoBytes?.length}');
      debugPrint('📸 Base64 length: ${base64Photo.length}');

      final res = await dio.post(
        ApiPaths.setMemberPhoto,
        data: body,
        options: Options(
          contentType: Headers.jsonContentType,
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 120),
          validateStatus: (_) => true,
        ),
      );

      debugPrint('📥 Response status: ${res.statusCode}');
      debugPrint('📥 Response data: ${res.data}');

      if (res.statusCode == 200 &&
          (res.data['exceptionNumber'] == 0 ||
              res.data['ExceptionNumber'] == 0)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ፎቶ ተቀምጧል!')),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to save photo');
      }
    } catch (e) {
      debugPrint('❌ Save error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ፎቶ ማስቀመጥ አልተሳካም።')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('የፎቶ መረጃ'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _savePhoto),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initFuture,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return ErrorView(
                  message:
                      'ፎቶ ለመጫን አልተሳካም።\nእባክዎ ኢንተርኔት ግንኙነትዎን ያረጋግጡ ወይም በኋላ ይሞክሩ።',
                  onRetry: () => setState(() => _initFuture = _loadPhoto()),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_photoBytes != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            _photoBytes!,
                            width: double.infinity,
                            height: 400,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 400,
                          height: 400,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.person,
                              size: 120, color: Colors.grey),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library),
                        label: const Text('ፎቶ ይምረጡ'),
                        onPressed: () => _pickImage(fromCamera: false),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('ካሜራ ይጠቀሙ'),
                        onPressed: () => _pickImage(fromCamera: true),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 🔄 Uploading overlay indicator
          if (_loading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'ፎቶ በመጫን ላይ...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}