import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:school_audit_navigator/api.dart';
import 'package:intl/intl.dart';
import 'package:school_audit_navigator/objects/line_graph_data.dart';
import 'package:school_audit_navigator/widgets/line_graph_widget.dart';
List<dynamic> _yearsStr = [];
class AuditPage extends StatefulWidget {
  final String? auditein;
  final String? auditID;
  final String? auditYear;
  final String? auditName;
  const AuditPage(
      {this.auditein, this.auditID, this.auditYear, this.auditName, super.key});

  @override
  State<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends State<AuditPage> {
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");
  late String dropdownValue = widget.auditYear.toString();
  @override
  Widget build(BuildContext context) {
    String ein = widget.auditein.toString();
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'School Audit Navigator',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color.fromARGB(255, 76, 124, 175),
          elevation: 2,
          centerTitle: true,
        ),
        body: Column(children: [
          Expanded(
              child: FutureBuilder(
                  future: Future.wait([
                    getCollegeinfofromYear(dropdownValue, ein),
                    graphData(ein),
                  ]),
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (!snapshot.hasData) {
                      return const Scaffold(
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Loading audit data...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  else if (snapshot.hasError) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 16),
                        Text(
                          'You have made too many requests. Try again later.',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );}
                    final List<Map<String, dynamic>> college =
                        snapshot.data![0][0];
                    Map<String, double> values = snapshot.data![0][1];
                    if (values.isEmpty) {
                      values["No Data"] = 1;
                    }
                    final collegeData = college[0];
                    final String acceptDate = collegeData['fac_accepted_date'];
                    final int expend = collegeData['total_amount_expended'];
                    final String auditee = collegeData['auditee_contact_name'];
                    final String auditeeContact = collegeData['auditee_email'];
                    final String auditor = collegeData['auditor_contact_name'];
                    final String auditorContact = collegeData['auditor_email'];
                    List<String> yearsStr = _yearsStr.cast<String>();
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 24.0),
                      child: Column(
                        children: [
                          DropdownButton(
                            value: dropdownValue,
                            items: yearsStr.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                          ),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    collegeData['auditee_name'],
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 76, 124, 175),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    'FAC Acceptance Date',
                                    acceptDate,
                                    Icons.calendar_today,
                                  ),
                                  const Divider(height: 24),
                                  _buildInfoRow(
                                    'Total Federal Expenditure',
                                    '\$${currencyFormatter.format(expend)}',
                                    Icons.attach_money,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Contact Information',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildContactInfo(
                                      'Auditee', auditee, auditeeContact),
                                  const SizedBox(height: 16),
                                  _buildContactInfo(
                                      'Auditor', auditor, auditorContact),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Funding Categories',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Center(
                                    child: PieChart(
                                      dataMap: values,
                                      chartRadius:
                                          MediaQuery.of(context).size.width /
                                              1.7,
                                      legendOptions: const LegendOptions(
                                          legendPosition:
                                              LegendPosition.bottom),
                                      chartValuesOptions:
                                          const ChartValuesOptions(
                                        showChartValuesInPercentage: true,
                                        decimalPlaces: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Expenditures over time',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Center(
                                      child: SizedBox(
                                          width: 400,
                                          height: 350,
                                          child: LineGraphWidget(
                                              snapshot.data![1]))),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  }))
        ]));
  }
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo(String role, String name, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          role,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.person_outline, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.email_outlined, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                email,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
void setyears(List<dynamic> years ){
  _yearsStr = years;
}