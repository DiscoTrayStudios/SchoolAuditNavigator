import 'package:flutter/material.dart';
import 'package:school_audit_navigator/ResultsPage.dart';
import 'package:school_audit_navigator/objects/states.dart';
import 'api.dart';

void main() {
  searchColleges(true, 'ar');
  runApp(
    MaterialApp(
      home: const MyHomePage(title: "School Audit Navigator"),
      theme: ThemeData(  
        scaffoldBackgroundColor: const Color.fromARGB(255, 186, 189, 196),
      )
    ),
  );
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are always marked "final".

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  States stateValue = States.al;
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 76, 124, 175),
        title: Text(widget.title),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Welcome to the Federal Audit Clearinghouse App! Search nationally for a high school or university by name or use the drop down to filter by state."),
            const TextField(decoration: InputDecoration(
          labelText: 'Search by Name',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),),
        
          const SizedBox(height: 40.0,),
          const Text('-OR-',),
          const SizedBox(height: 40.0),
          const Text('Search by State'),
          const SizedBox(height: 20,),
          DropdownButton<States>(
            items: States.values.map((States classType) {
            return DropdownMenuItem<States>(
                value: classType, child: Text(classType.state));
          }).toList(),
            value: stateValue,
          onChanged: (States? newValue) {
            setState(() {
              stateValue = newValue!;
            });
          },
        ),
        const SizedBox(height: 20,),
          FloatingActionButton(
          onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsPage  (selectedState: stateValue,)
            )
          );
        },
          child: const Text('Go')
        ),
        ]
      ),
      )
    );
  }
}

