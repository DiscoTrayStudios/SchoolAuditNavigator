import 'dart:collection';
import 'dart:convert';
import 'package:school_audit_navigator/objects/agencies.dart';
import 'package:school_audit_navigator/audit_page.dart';
import 'package:http/http.dart' as http;

// The API key is in this file. It should not be part of the repo. If it is
// then we need to trash it and get a new one.
import 'package:school_audit_navigator/apikey.dart';

//used for the search function
Future<List<Map<String, dynamic>>> searchColleges(
    {bool isHigherED = false, String? state, String? name}) async {
  Uri url;

  if (name != null && name.isNotEmpty) {
    // Search by college name
    url = Uri.parse(
        "https://api.fac.gov/general?select=auditee_name,audit_year,report_id,auditee_ein&auditee_name=ilike.%$name%&and=(or(auditee_name.ilike.%school%,entity_type.eq.higher-ed))");
  } else if (state != null) {
    if (state.contains("IND")) {
      state = "IN";
    }
    // Search by state
    if (isHigherED) {
      url = Uri.parse(
          "https://api.fac.gov/general?select=auditee_name,audit_year,report_id,auditee_ein&auditee_state=eq.$state&auditee_name=ilike(any).{*College*,*University*}");
    } else {
      url = Uri.parse(
          "https://api.fac.gov/general?auditee_state=eq.$state&auditee_name=fts.school");
    }
  } else {
    throw Exception('Either name or state must be provided.');
  }

  var response = await http.get(url, headers: {'X-Api-Key': myAPI});
  if (response.body.contains("OVER_RATE_LIMIT")) {
    throw Exception('Slow Down!');
  }
  final data =
      (json.decode(response.body) as List).cast<Map<String, dynamic>>();
  return data;
}
Future<List<dynamic>> getCollegeinfofromYear(String year, String ein) async {
  var url = Uri.parse(
      "https://api.fac.gov/general?audit_year=eq.$year&auditee_ein=eq.$ein");
  var response = await http.get(url, headers: {'X-Api-Key': myAPI});
  if (response.body.contains("OVER_RATE_LIMIT")) {
    throw Exception('Slow Down!');
  }
  final data =
      (json.decode(response.body) as List).cast<Map<String, dynamic>>();
  Map<String, double> dataMap= await getCollegeDataMap(data);
  return [data,dataMap];
}

//gets college data for the pie chart
Future<Map<String, double>> getCollegeDataMap(List<Map<String, dynamic>> data) async {
  String reportID = data[0]['report_id'];
  var url = Uri.parse(
      "https://api.fac.gov/federal_awards?report_id=eq.$reportID&select=federal_agency_prefix,amount_expended");
  var response = await http.get(url, headers: {'X-Api-Key': myAPI});
  if (response.body.contains("OVER_RATE_LIMIT")) {
    throw Exception('Slow Down!');
  }
  final agencyData =
      (json.decode(response.body) as List).cast<Map<String, dynamic>>();
  final Map<String, double> dataMap = {};
  int i = 0;
  while (i < agencyData.length) {
    String agencyPrefix = agencyData[i]['federal_agency_prefix'];
    int newPrefix = int.parse(agencyPrefix);
    String agencyName = agencies[newPrefix] ?? "Other";
    if (!dataMap.containsKey(agencyName)) {
      dataMap[agencyName] = agencyData[i]['amount_expended'].toDouble().abs().toDouble();
    } else {
      dataMap[agencyName] = dataMap[agencyName]! + agencyData[i]['amount_expended'].abs().toDouble();
    }
    i++;
  }
  return dataMap;

}

//gets other years for the line graph
Future<Map<String, double>> getOtherYears(String ein) async {
  var url = Uri.parse(
      "https://api.fac.gov/general?auditee_ein=eq.$ein&select=audit_year,total_amount_expended&order=audit_year.asc");
  var response = await http.get(url, headers: {'X-Api-Key': myAPI});
  final data =
      (json.decode(response.body) as List).cast<Map<String, dynamic>>();
  final Map<String, double> dataMap = {};
  int i = 0;
  while (i < data.length) {
    if(dataMap[data[i]['audit_year'].toString()] == null){
    dataMap[data[i]['audit_year'].toString()] =
        data[i]['total_amount_expended'].toDouble();
  }
    i++;
  }
  List<dynamic> work =
      data.map((map) => map['audit_year']).toList() as List<dynamic>;
  List<dynamic> workFinal=
  work.toSet().toList();
  setyears(workFinal);
  return dataMap;
}