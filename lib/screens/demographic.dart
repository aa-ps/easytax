import 'package:easytax/main.dart';
import 'package:flutter/material.dart';

class DemographicScreen extends StatefulWidget {
  const DemographicScreen({Key? key}) : super(key: key);

  @override
  _DemographicScreenState createState() => _DemographicScreenState();
}

class _DemographicScreenState extends State<DemographicScreen> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, dynamic> _profileData = {
    'name': '',
    'gender': '',
    'marital_status': '',
    'employment_status': '',
    'income_level': '',
    'occupation': '',
    'state_of_residence': '',
    'dependents_count': 0,
    'age': 0,
  };

 Future<void> completeProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState!.save();

    try {
      _profileData['id'] = supabase.auth.currentUser?.id;
      await supabase.from("profiles").insert(_profileData);
      Navigator.of(context).pushReplacementNamed("/");
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                      child: const Text(
                    "Profile Creation",
                  )),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your name' : null,
                    onSaved: (value) => _profileData["name"] = value!,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: ['Male', 'Female']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _profileData["gender"] = value!),
                  ),
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Marital Status'),
                    items: ['Single', 'Married', 'Divorced', 'Widowed']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _profileData["marital_status"] = value!),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Number of Dependents'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty
                        ? 'Please enter number of dependents'
                        : null,
                    onSaved: (value) => _profileData["dependents_count"] = int.parse(value!),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your age' : null,
                    onSaved: (value) => _profileData["age"] = int.parse(value!),
                  ),
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Employment Status'),
                    items:
                        ['Employed', 'Unemployed', 'Self-employed', 'Retired']
                            .map((label) => DropdownMenuItem(
                                  value: label,
                                  child: Text(label),
                                ))
                            .toList(),
                    onChanged: (value) =>
                        setState(() => _profileData["employment_status"] = value!),
                  ),
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Income Level'),
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
                    onChanged: (value) => setState(() => _profileData["income_level"] = value!),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Occupation'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your occupation' : null,
                    onSaved: (value) => _profileData["occupation"] = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText:
                            'State of Residence'), // TODO: ONLY ACCEPT 2 CHARACTER STATES LIKE TX OR FL
                    validator: (value) => value!.isEmpty
                        ? 'Please enter your state of residence'
                        : null,
                    onSaved: (value) => _profileData["state_of_residence"] = value!,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final form = _formKey.currentState;
                      if (form!.validate()) {
                        completeProfile();
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

