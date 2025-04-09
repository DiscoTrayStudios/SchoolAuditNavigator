import 'dart:convert';
import 'package:school_audit_navigator/objects/agencies.dart';
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
        "https://api.fac.gov/general?select=auditee_name,audit_year,report_id,auditee_uei&auditee_name=ilike.%$name%&and=(or(auditee_name.ilike.%school%,entity_type.eq.higher-ed))");
  } else if (state != null) {
    if (state.contains("IND")) {
      state = "IN";
    }
    print(state);
    // Search by state
    if (isHigherED) {
      url = Uri.parse(
          "https://api.fac.gov/general?select=auditee_name,audit_year,report_id,auditee_uei&auditee_state=eq.$state&auditee_name=ilike(any).{*College*,*University*}");
    } else {
      url = Uri.parse(
          "https://api.fac.gov/general?auditee_state=eq.$state&auditee_name=fts.school");
    }
  } else {
    throw Exception('Either name or state must be provided.');
  }

  var response = await http.get(url, headers: {'X-Api-Key': myAPI});
  final data =
      (json.decode(response.body) as List).cast<Map<String, dynamic>>();
  return data;
}

Future<List<Map<String, dynamic>>> getCollegeinfo(String id) async {
  var url = Uri.parse("https://api.fac.gov/general?report_id=eq.$id");
  var response = await http.get(url, headers: {'X-Api-Key': myAPI});
  final data =
      (json.decode(response.body) as List).cast<Map<String, dynamic>>();
  return data;
}

Future<List<Map<String, dynamic>>> getCollegeinfofromYear(
    String year, String uei) async {
  var url = Uri.parse(
      "https://api.fac.gov/general?audit_year=eq.$year&auditee_uei=eq.$uei");
  var response = await http.get(url, headers: {'X-Api-Key': myAPI});
  final data =
      (json.decode(response.body) as List).cast<Map<String, dynamic>>();
  return data;
}

//gets college data for the pie chart
Future<Map<String, double>> getCollegeDataMap(String year, String uei) async {
  var url1 = Uri.parse(
      "https://api.fac.gov/general?audit_year=eq.$year&auditee_uei=eq.$uei");
  var response1 = await http.get(url1, headers: {'X-Api-Key': myAPI});
  final data1 =
      (json.decode(response1.body) as List).cast<Map<String, dynamic>>();
  String reportID = data1[0]['report_id'];
  var url = Uri.parse(
      "https://api.fac.gov/federal_awards?report_id=eq.$reportID&select=federal_agency_prefix,amount_expended");
  var response = await http.get(url, headers: {'X-Api-Key': myAPI});
  final data =
      (json.decode(response.body) as List).cast<Map<String, dynamic>>();
  final Map<String, double> dataMap = {};
  int i = 0;
  print(data.length);
  while (i < data.length) {
    String agencyPrefix = data[i]['federal_agency_prefix'];
    int newPrefix = int.parse(agencyPrefix);
    print(newPrefix);
    String agencyName = agencies[newPrefix] ?? "Other Agency";
    if (!dataMap.containsKey(agencyName)) {
      dataMap[agencyName] = data[i]['amount_expended'].toDouble().abs().toDouble();
    } else {
      dataMap[agencyName] = dataMap[agencyName]! + data[i]['amount_expended'].abs().toDouble();
    }
    i++;
  }
  print(url);
  int j = 0;
  while(j < dataMap.length){
    print(dataMap.keys.elementAt(j));
    print(dataMap.values.elementAt(j));
    j++;
  }
  return dataMap;
}

//gets other years for the line graph
Future<Map<String, double>> getOtherYears(String uei) async {
  var url = Uri.parse(
      "https://api.fac.gov/general?auditee_uei=eq.$uei&select=audit_year,total_amount_expended&order=audit_year.asc");
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
  return dataMap;
}

//Tried to use this to get other years of audit in the dropdown, but not working
Future<List<dynamic>> getYearList(String uei) async {
  var url = Uri.parse(
      "https://api.fac.gov/general?auditee_uei=eq.$uei&select=audit_year&order=audit_year.asc");
  var response = await http.get(url, headers: {'X-Api-Key': myAPI});
  List<Map<String, dynamic>> data =
      (json.decode(response.body) as List).cast<Map<String, dynamic>>();
  List<dynamic> work =
      data.map((map) => map['audit_year']).toList() as List<dynamic>;
  List<dynamic> workFinal=
  work.toSet().toList();
  return workFinal;
}
