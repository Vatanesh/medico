import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/patient_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api/api_service.dart';
import '../recording/recording_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isAuthenticated) {
      await authProvider.autoLogin();
    }
    
    if (authProvider.isAuthenticated && authProvider.userId != null) {
      final patientProvider = Provider.of<PatientProvider>(context, listen: false);
      await patientProvider.loadPatients(authProvider.userId!);
    }
  }

  Future<void> _addPatient() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.userId == null) return;

    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => const AddPatientDialog(),
    );

    if (result != null && mounted) {
      try {
        final patientProvider = Provider.of<PatientProvider>(context, listen: false);
        await patientProvider.addPatient({
          'name': result['name']!,
          'userId': authProvider.userId!,
          if (result['email'] != null) 'email': result['email'],
          if (result['pronouns'] != null) 'pronouns': result['pronouns'],
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final patientProvider = Provider.of<PatientProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.patients),
      ),
      body: patientProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : patientProvider.patients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noPatients,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.addFirstPatient,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    if (authProvider.userId != null) {
                      await patientProvider.loadPatients(authProvider.userId!);
                    }
                  },
                  child: ListView.builder(
                    itemCount: patientProvider.patients.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final patient = patientProvider.patients[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              patient.name[0].toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            patient.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: patient.email != null
                              ? Text(patient.email!)
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.mic),
                            onPressed: () {
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecordingScreen(
                                    patient: patient,
                                    userId: authProvider.userId!,
                                  ),
                                ),
                              );
                            },
                            tooltip: l10n.startRecording,
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPatient,
        icon: const Icon(Icons.add),
        label: Text(l10n.addPatient),
      ),
    );
  }
}

class AddPatientDialog extends StatefulWidget {
  const AddPatientDialog({super.key});

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pronounsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _pronounsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.addPatient),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.patientName,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter patient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.patientEmail,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pronounsController,
                decoration: InputDecoration(
                  labelText: l10n.pronouns,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'email': _emailController.text.isNotEmpty ? _emailController.text : null,
                'pronouns': _pronounsController.text.isNotEmpty ? _pronounsController.text : null,
              });
            }
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
