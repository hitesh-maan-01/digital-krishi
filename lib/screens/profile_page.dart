import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmerProfilePage extends StatefulWidget {
  const FarmerProfilePage({super.key});

  @override
  _FarmerProfilePageState createState() => _FarmerProfilePageState();
}

class _FarmerProfilePageState extends State<FarmerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool isEditing = false;

  String name = '';
  int? age;
  String gender = 'Male';
  String contactNumber = '';
  String location = '';
  String farmDetails = '';
  String language = 'Malayalam';
  String farmingPractices = '';
  String devicePreference = 'Voice';
  List<String> subsidies = [];

  final List<String> genders = ['Male', 'Female', 'Other'];
  final List<String> languages = [
    'Malayalam',
    'English',
    'Hindi',
    'Tamil',
    'Kannada',
  ];
  final List<String> devicePrefs = ['Voice', 'Text'];

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _contactController;
  late TextEditingController _locationController;
  late TextEditingController _farmDetailsController;
  late TextEditingController _farmingPracticesController;
  late TextEditingController _subsidyController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _contactController = TextEditingController();
    _locationController = TextEditingController();
    _farmDetailsController = TextEditingController();
    _farmingPracticesController = TextEditingController();
    _subsidyController = TextEditingController();
    _loadProfile();
  }

  String safeDropdown(List<String> options, String? value, String fallback) {
    if (value != null && options.contains(value)) return value;
    return fallback;
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String loadedGender = prefs.getString('gender') ?? 'Male';
    String loadedLanguage = prefs.getString('language') ?? 'Malayalam';
    String loadedDevicePref = prefs.getString('devicePreference') ?? 'Voice';

    gender = safeDropdown(genders, loadedGender, genders.first);
    language = safeDropdown(languages, loadedLanguage, languages.first);
    devicePreference = safeDropdown(
      devicePrefs,
      loadedDevicePref,
      devicePrefs.first,
    );

    setState(() {
      name = prefs.getString('name') ?? '';
      age = prefs.getInt('age');
      contactNumber = prefs.getString('contactNumber') ?? '';
      location = prefs.getString('location') ?? '';
      farmDetails = prefs.getString('farmDetails') ?? '';
      farmingPractices = prefs.getString('farmingPractices') ?? '';
      subsidies = prefs.getStringList('subsidies') ?? [];
      _nameController.text = name;
      _ageController.text = age?.toString() ?? '';
      _contactController.text = contactNumber;
      _locationController.text = location;
      _farmDetailsController.text = farmDetails;
      _farmingPracticesController.text = farmingPractices;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text.trim());
    final parsedAge = int.tryParse(_ageController.text.trim());
    if (parsedAge != null) {
      await prefs.setInt('age', parsedAge);
    }
    await prefs.setString('gender', gender);
    await prefs.setString('contactNumber', _contactController.text.trim());
    await prefs.setString('location', _locationController.text.trim());
    await prefs.setString('farmDetails', _farmDetailsController.text.trim());
    await prefs.setString('language', language);
    await prefs.setString(
      'farmingPractices',
      _farmingPracticesController.text.trim(),
    );
    await prefs.setString('devicePreference', devicePreference);
    await prefs.setStringList('subsidies', subsidies);

    setState(() {
      name = _nameController.text.trim();
      age = parsedAge;
      contactNumber = _contactController.text.trim();
      location = _locationController.text.trim();
      farmDetails = _farmDetailsController.text.trim();
      farmingPractices = _farmingPracticesController.text.trim();
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully!')),
    );
  }

  void _editSubsidy({int? index}) {
    if (index != null) {
      _subsidyController.text = subsidies[index];
    } else {
      _subsidyController.clear();
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 240, 243, 245),
        title: Text(
          index == null ? 'Add Subsidy/Scheme' : 'Edit Subsidy/Scheme',
        ),
        content: TextField(
          controller: _subsidyController,
          decoration: const InputDecoration(
            hintText: 'Enter subsidy or scheme name',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 5, 150, 105),
            ),
            child: const Text('Save'),
            onPressed: () {
              final text = _subsidyController.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  if (index == null) {
                    subsidies.add(text);
                  } else {
                    subsidies[index] = text;
                  }
                });
                _saveProfile();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _removeSubsidy(int index) {
    setState(() {
      subsidies.removeAt(index);
    });
    _saveProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _locationController.dispose();
    _farmDetailsController.dispose();
    _farmingPracticesController.dispose();
    _subsidyController.dispose();
    super.dispose();
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 5, 150, 105)),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Row(
                children: [
                  Icon(icon, color: const Color.fromARGB(255, 5, 150, 105)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            else
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            if (icon != null) const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkGreen = const Color.fromARGB(255, 5, 150, 105);
    final lightBg = const Color.fromARGB(255, 240, 243, 245);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Profile'),
        titleTextStyle: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 20,
        ),
        backgroundColor: darkGreen,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            tooltip: isEditing ? 'Save' : 'Edit',
            onPressed: () async {
              if (isEditing) {
                await _saveProfile();
              } else {
                setState(() => isEditing = true);
              }
            },
          ),
        ],
      ),
      backgroundColor: lightBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar & Name Atop
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: darkGreen,
                      child: Text(
                        (name.isNotEmpty ? name[0].toUpperCase() : 'F'),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name.isNotEmpty ? name : 'Your Name',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      location.isNotEmpty ? location : 'Your Location',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              _profileCard(
                title: "Personal & Contact",
                icon: Icons.person,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      enabled: isEditing,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Please enter name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: 'Age'),
                      enabled: isEditing,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (isEditing) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter age';
                          }
                          if (int.tryParse(val) == null) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Gender'),
                      value: gender,
                      items: genders
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: isEditing
                          ? (val) => setState(() => gender = val ?? gender)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                      ),
                      enabled: isEditing,
                      keyboardType: TextInputType.phone,
                      validator: (val) =>
                          isEditing && (val == null || val.isEmpty)
                          ? 'Please enter contact number'
                          : null,
                    ),
                  ],
                ),
              ),

              _profileCard(
                title: "Farm & Preferences",
                icon: Icons.agriculture_outlined,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _farmDetailsController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Farm Details (Landholding, Soil, Crops)',
                        hintText: 'e.g. 2 acres, Loamy soil, Banana & Coconut',
                      ),
                      enabled: isEditing,
                      validator: (val) =>
                          isEditing && (val == null || val.isEmpty)
                          ? 'Please enter farm details'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Village/City, District, State',
                      ),
                      enabled: isEditing,
                      validator: (val) =>
                          isEditing && (val == null || val.isEmpty)
                          ? 'Please enter location'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Preferred Language',
                      ),
                      value: language,
                      items: languages
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: isEditing
                          ? (val) => setState(() => language = val ?? language)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Preferred Communication Mode',
                      ),
                      value: devicePreference,
                      items: devicePrefs
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: isEditing
                          ? (val) => setState(
                              () => devicePreference = val ?? devicePreference,
                            )
                          : null,
                    ),
                  ],
                ),
              ),

              _profileCard(
                title: "Farming Practices",
                icon: Icons.history_edu,
                child: TextFormField(
                  controller: _farmingPracticesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Farming Practices & History',
                    hintText: 'e.g. Organic, Drip irrigation history',
                  ),
                  enabled: isEditing,
                  validator: (val) => isEditing && (val == null || val.isEmpty)
                      ? 'Please enter history'
                      : null,
                ),
              ),

              _profileCard(
                title: "Schemes & Subsidies",
                icon: Icons.wallet_giftcard_rounded,
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: subsidies.length,
                      itemBuilder: (context, index) {
                        final s = subsidies[index];
                        return Card(
                          color: const Color.fromARGB(255, 240, 243, 245),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(Icons.stars, color: darkGreen),
                            title: Text(s, style: GoogleFonts.poppins()),
                            trailing: isEditing
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.green,
                                        ),
                                        onPressed: () =>
                                            _editSubsidy(index: index),
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _removeSubsidy(index),
                                        tooltip: 'Remove',
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                    if (isEditing)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add Subsidy/Scheme'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkGreen,
                            ),
                            onPressed: () => _editSubsidy(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
