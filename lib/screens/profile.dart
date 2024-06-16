import 'package:easytax/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> _profileData = {};

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final Map<String, dynamic> result = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user!.id)
          .single();
      setState(() {
        _profileData = result;
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> completeProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState!.save();
    setState(() {});

    final Map<String, dynamic> updatedProfileData = {
      'name': _profileData["name"],
      'gender': _profileData["gender"],
      'marital_status': _profileData["marital_status"],
      'employment_status': _profileData["employment_status"],
      'income_level': _profileData["income_level"],
      'occupation': _profileData["occupation"],
      'state_of_residence': _profileData["state_of_residence"],
      'dependents_count': _profileData["dependents_count"],
      'age': _profileData["age"],
    };
    setState(() => _isLoading = true);

    try {
      await supabase
          .from('profiles')
          .update(updatedProfileData)
          .match({'id': _profileData["id"]});
    } catch (e) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> signOut(BuildContext context) async {
    await supabase.auth.signOut();
    Navigator.of(context).pushReplacementNamed("/");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
          ),
          body: _buildProfileForm(),
        ),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildProfileForm() {
    return !_isLoading
        ? Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            key: UniqueKey(),
                            initialValue: _profileData["name"],
                            decoration:
                                const InputDecoration(labelText: 'Name'),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter your name'
                                : null,
                            onSaved: (value) => _profileData["name"] = value!,
                          ),
                          DropdownButtonFormField<String>(
                            value: _profileData["gender"],
                            decoration:
                                const InputDecoration(labelText: 'Gender'),
                            items: ['Male', 'Female']
                                .map((label) => DropdownMenuItem(
                                      value: label,
                                      child: Text(label),
                                    ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _profileData["gender"] = value!),
                          ),
                          DropdownButtonFormField<String>(
                            value: _profileData["marital_status"],
                            decoration: const InputDecoration(
                                labelText: 'Marital Status'),
                            items: ['Single', 'Married', 'Divorced', 'Widowed']
                                .map((label) => DropdownMenuItem(
                                      value: label,
                                      child: Text(label),
                                    ))
                                .toList(),
                            onChanged: (value) => setState(
                                () => _profileData["marital_status"] = value!),
                          ),
                          TextFormField(
                            key: UniqueKey(),
                            initialValue:
                                _profileData["dependents_count"].toString(),
                            decoration: const InputDecoration(
                                labelText: 'Number of Dependents'),
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter number of dependents'
                                : null,
                            onSaved: (value) =>
                                _profileData["dependents_count"] =
                                    int.parse(value!),
                          ),
                          TextFormField(
                            key: UniqueKey(),
                            initialValue: _profileData["age"].toString(),
                            decoration: const InputDecoration(labelText: 'Age'),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter your age' : null,
                            onSaved: (value) =>
                                _profileData["age"] = int.parse(value!),
                          ),
                          DropdownButtonFormField<String>(
                            value: _profileData["employment_status"],
                            decoration: const InputDecoration(
                                labelText: 'Employment Status'),
                            items: [
                              'Employed',
                              'Unemployed',
                              'Self-employed',
                              'Retired'
                            ]
                                .map((label) => DropdownMenuItem(
                                      value: label,
                                      child: Text(label),
                                    ))
                                .toList(),
                            onChanged: (value) => setState(() =>
                                _profileData["employment_status"] = value!),
                          ),
                          DropdownButtonFormField<String>(
                            value: _profileData["income_level"],
                            decoration: const InputDecoration(
                                labelText: 'Income Level'),
                            items: [
                              'Under 25K',
                              '25K-50K',
                              '50K-75K',
                              'Over 75K'
                            ] // TODO: FIND TAX BRACKETS
                                .map((label) => DropdownMenuItem(
                                      value: label,
                                      child: Text(label),
                                    ))
                                .toList(),
                            onChanged: (value) => setState(
                                () => _profileData["income_level"] = value!),
                          ),
                          TextFormField(
                            initialValue: _profileData["occupation"],
                            decoration:
                                const InputDecoration(labelText: 'Occupation'),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter your occupation'
                                : null,
                            onSaved: (value) =>
                                _profileData["occupation"] = value!,
                          ),
                          TextFormField(
                            key: UniqueKey(),
                            initialValue: _profileData["state_of_residence"],
                            decoration: const InputDecoration(
                                labelText:
                                    'State of Residence'), // TODO: ONLY ACCEPT 2 CHARACTER STATES LIKE TX OR FL
                            validator: (value) => value!.isEmpty
                                ? 'Please enter your state of residence'
                                : null,
                            onSaved: (value) =>
                                _profileData["state_of_residence"] = value!,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              final form = _formKey.currentState;
                              if (form!.validate()) {
                                completeProfile();
                              }
                            },
                            child: const Text('Update Profile'),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    signOut(context);
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}
