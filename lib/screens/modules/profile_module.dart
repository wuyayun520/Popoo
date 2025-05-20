import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../policy/terms_service_page.dart';
import '../policy/privacy_policy_page.dart';
import '../about/about_app_page.dart';

class ProfileModule extends StatefulWidget {
  const ProfileModule({super.key});

  @override
  State<ProfileModule> createState() => _ProfileModuleState();
}

class _ProfileModuleState extends State<ProfileModule> {
  final TextEditingController _nameController = TextEditingController();
  String _userName = 'User Name';
  String? _userImgPath;
  final ImagePicker _picker = ImagePicker();
  bool _isLoadingImage = false;
  File? _imageFile;
  final GlobalKey _profileImageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User Name';
      _userImgPath = prefs.getString('user_img_path');
      _nameController.text = _userName;
    });
    
    if (_userImgPath != null) {
      _loadImageFile();
    }
  }

  // 预加载图片文件
  Future<void> _loadImageFile() async {
    if (_userImgPath != null) {
      final path = await _getImagePath(_userImgPath!);
      final file = File(path);
      if (file.existsSync()) {
        setState(() {
          _imageFile = file;
        });
      }
    }
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text);
    setState(() {
      _userName = _nameController.text;
    });
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF69ACFF),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isLoadingImage = true;
      });

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Get app's document directory (persistent storage)
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImagePath = '${appDir.path}/$fileName';

        // Read the picked image file
        final Uint8List bytes = await pickedFile.readAsBytes();
        
        // Save to app's document directory
        final File savedImage = File(savedImagePath);
        await savedImage.writeAsBytes(bytes);

        // 删除旧图片
        if (_userImgPath != null) {
          final oldPath = await _getImagePath(_userImgPath!);
          final oldFile = File(oldPath);
          if (oldFile.existsSync()) {
            try {
              await oldFile.delete();
            } catch (e) {
              // 如果删除失败，不中断流程
              debugPrint('Failed to delete old image: $e');
            }
          }
        }

        // Save reference in SharedPreferences (using just the filename)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_img_path', fileName);

        setState(() {
          _userImgPath = fileName;
          _imageFile = savedImage; // 直接保存文件引用
          _isLoadingImage = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image updated'),
              backgroundColor: Color(0xFF69ACFF),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        setState(() {
          _isLoadingImage = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingImage = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update image: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Get the profile image to display
  Widget _getProfileImage() {
    if (_isLoadingImage) {
      return const CircularProgressIndicator(
        color: Colors.white,
      );
    }
    
    if (_imageFile != null && _imageFile!.existsSync()) {
      return CircleAvatar(
        key: _profileImageKey,
        radius: 50,
        backgroundColor: Colors.white,
        backgroundImage: FileImage(_imageFile!),
      );
    }
    
    // Default avatar
    return const CircleAvatar(
      radius: 50,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.person,
        size: 50,
        color: Color(0xFF69ACFF),
      ),
    );
  }

  Future<String> _getImagePath(String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/$fileName';
  }

  void _showEditNameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Edit Name',
          style: TextStyle(
            color: Color(0xFF69ACFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _saveUserData();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF69ACFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _navigateToAboutApp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutAppPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;
    
    return Container(
      color: Colors.grey[100],
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Background gradient - extend to cover status bar area
                Container(
                  height: 180 + statusBarHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF69ACFF),
                        Color(0xFF4285F4),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  padding: EdgeInsets.only(top: 0),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'MY PROFILE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Profile avatar
                Positioned(
                  top: 120 + statusBarHeight * 0.5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          _getProfileImage(),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF69ACFF),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _showEditNameDialog,
                    icon: const Icon(
                      Icons.edit,
                      color: Color(0xFF69ACFF),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildSettingsCard([
                SettingItem(
                  icon: Icons.info_outline,
                  title: 'About App',
                  onTap: _navigateToAboutApp,
                ),
                SettingItem(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsServicePage(),
                      ),
                    );
                  },
                ),
                SettingItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                if (index > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey[100],
                    indent: 16,
                    endIndent: 16,
                  ),
                InkWell(
                  onTap: item.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF69ACFF).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            color: const Color(0xFF69ACFF),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class SettingItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  SettingItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
} 