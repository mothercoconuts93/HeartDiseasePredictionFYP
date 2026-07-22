// Searchable Practitioner directory combining Patient profiles and predictions.

import 'package:flutter/material.dart';

import '../../models/prediction_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../themes/app_theme.dart';
import '../../widgets/risk_badge.dart';
import 'patient_detail_screen.dart';

/// Lets a Practitioner search, filter, sort, and select Patient records.
class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final _searchController = TextEditingController();
  String _riskFilter = 'All';
  String _sort = 'Name';
  int _visibleCount = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Maps a prediction's risk label to its directory accent color.
  Color _riskColor(String risk) {
    if (risk.contains('High')) return AppTheme.danger;
    if (risk.contains('Moderate')) return AppTheme.warning;
    return AppTheme.success;
  }

  /// Formats a prediction date for compact Patient cards.
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Associates a Patient UID with the first, newest matching prediction.
  PredictionModel? _latestPredictionFor(
    String userId,
    List<PredictionModel> predictions,
  ) {
    for (final prediction in predictions) {
      if (prediction.userId == userId) return prediction;
    }
    return null;
  }

  /// Joins streams in memory, then applies search, risk, sort, and pagination.
  List<_PatientRecord> _visibleRecords(
    List<UserModel> patients,
    List<PredictionModel> predictions,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    final records = patients
        .map(
          (patient) => _PatientRecord(
            patient,
            _latestPredictionFor(patient.uid, predictions),
          ),
        )
        .where((record) {
          final matchesSearch =
              query.isEmpty ||
              record.patient.fullName.toLowerCase().contains(query) ||
              record.patient.email.toLowerCase().contains(query);
          final risk = record.prediction?.riskLevel ?? '';
          final matchesRisk =
              _riskFilter == 'All' ||
              (_riskFilter == 'No result'
                  ? record.prediction == null
                  : risk.contains(_riskFilter));
          return matchesSearch && matchesRisk;
        })
        .toList();

    switch (_sort) {
      case 'Highest risk':
        records.sort(
          (a, b) => (b.prediction?.probability ?? -1).compareTo(
            a.prediction?.probability ?? -1,
          ),
        );
      case 'Latest prediction':
        records.sort(
          (a, b) => (b.prediction?.createdAt ?? DateTime(1970)).compareTo(
            a.prediction?.createdAt ?? DateTime(1970),
          ),
        );
      default:
        records.sort(
          (a, b) => a.patient.fullName.toLowerCase().compareTo(
            b.patient.fullName.toLowerCase(),
          ),
        );
    }
    return records;
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('CARDIOGUARD')),
      body: StreamBuilder<List<UserModel>>(
        stream: firestoreService.getPatients(),
        builder: (context, patientSnapshot) {
          if (patientSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (patientSnapshot.hasError) {
            return const Center(child: Text('Unable to load patients.'));
          }

          final patients = patientSnapshot.data ?? [];
          if (patients.isEmpty) {
            return const Center(child: Text('No patients found.'));
          }

          return StreamBuilder<List<PredictionModel>>(
            stream: firestoreService.getAllPredictions(),
            builder: (context, predictionSnapshot) {
              if (predictionSnapshot.hasError) {
                return const Center(
                  child: Text('Unable to load patient risk information.'),
                );
              }
              final records = _visibleRecords(
                patients,
                predictionSnapshot.data ?? [],
              );

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient Directory',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() => _visibleCount = 10),
                          decoration: InputDecoration(
                            hintText: 'Search by name or email...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _visibleCount = 10);
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                ['All', 'High', 'Moderate', 'Low', 'No result']
                                    .map(
                                      (filter) => Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: ChoiceChip(
                                          label: Text(filter),
                                          selected: _riskFilter == filter,
                                          onSelected: (_) => setState(() {
                                            _riskFilter = filter;
                                            _visibleCount = 10;
                                          }),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '${records.length} patient${records.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const Spacer(),
                            DropdownButton<String>(
                              value: _sort,
                              underline: const SizedBox.shrink(),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Name',
                                  child: Text('Name'),
                                ),
                                DropdownMenuItem(
                                  value: 'Highest risk',
                                  child: Text('Highest risk'),
                                ),
                                DropdownMenuItem(
                                  value: 'Latest prediction',
                                  child: Text('Latest prediction'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _sort = value;
                                    _visibleCount = 10;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: records.isEmpty
                        ? const Center(
                            child: Text('No patients match these filters.'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount:
                                records.take(_visibleCount).length +
                                (records.length > _visibleCount ? 1 : 0),
                            itemBuilder: (context, index) {
                              final visibleRecords = records
                                  .take(_visibleCount)
                                  .toList();
                              if (index == visibleRecords.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    bottom: 12,
                                  ),
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        setState(() => _visibleCount += 10),
                                    child: Text(
                                      'Load More (${records.length - visibleRecords.length} remaining)',
                                    ),
                                  ),
                                );
                              }
                              final record = visibleRecords[index];
                              final patient = record.patient;
                              final latestPrediction = record.prediction;
                              final riskLevel = latestPrediction?.riskLevel;
                              final color = riskLevel == null
                                  ? AppTheme.textSecondary
                                  : _riskColor(riskLevel);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                clipBehavior: Clip.antiAlias,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor: color.withValues(
                                      alpha: 0.1,
                                    ),
                                    child: Icon(
                                      Icons.person_outline,
                                      color: color,
                                    ),
                                  ),
                                  title: Text(
                                    patient.fullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 7),
                                    child: latestPrediction == null
                                        ? Text(patient.email)
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              RiskBadge(
                                                riskLevel:
                                                    latestPrediction.riskLevel,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Latest prediction: ${_formatDate(latestPrediction.createdAt)}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right,
                                    color: AppTheme.primary,
                                  ),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PatientDetailScreen(
                                        patient: patient,
                                        latestPrediction: latestPrediction,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Internal view model pairing a Patient profile with an optional prediction.
class _PatientRecord {
  final UserModel patient;
  final PredictionModel? prediction;

  const _PatientRecord(this.patient, this.prediction);
}
