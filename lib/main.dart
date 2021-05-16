import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

List _features ;

main() async {
  Map _quakeData = await getQuakes();

  _features = _quakeData['features'];

  //print("${_quakeData['features'][0]['properties']['time']}");

  runApp(MaterialApp(
      home:Quakes()
  ));
}

class Quakes extends StatefulWidget{
  @override
  _Quakesstate createState() => _Quakesstate();

}

class _Quakesstate extends State<Quakes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quakes"),
        backgroundColor: Colors.blueGrey[400],
      ),
      body: RefreshIndicator(
        child: ListView.builder(
            itemCount: _features.length,
            padding: const EdgeInsets.all(15),
            itemBuilder: (BuildContext context, int position) {
              var _time = _features[position]['properties']['time'];
              var format = DateFormat.yMMMMd("en_US").add_jm();
              var date = format.format(
                  DateTime.fromMillisecondsSinceEpoch(_time, isUtc: true));
              return Column(
                children: <Widget>[
                  if (position.isEven && position != 0 || position.isOdd)
                    new Divider(height: 5.5),
                  ListTile(
                    title: Text(
                      "$date",
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                    subtitle: Text(
                      "${_features[position]['properties']['place']}",
                      style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(
                        "${_features[position]['properties']['mag'].toStringAsFixed(1)}",
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    onTap: () =>
                        showMessageDialog(context,
                            "${_features[position]['properties']['title']}"),
                  ),
                ],
              );
            }),
        onRefresh: () {
          return Future.delayed(
          Duration(seconds: 1),
          () {setState(() {});}
          );
        }
      )
    );
  }

}

showMessageDialog(BuildContext context, String message) {
  var alert = AlertDialog(
    title: Text("Quake"),
    content: Text(message),
    actions: <Widget>[
      TextButton(
        style: TextButton.styleFrom(primary: Colors.blueGrey),
        child: Text(
          "My Sympathies",
          style: TextStyle(
              fontSize: 12.9,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: Colors.teal),
        ),
        onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Thanks , My Friend"), backgroundColor: Colors.blueGrey,
              duration: const Duration(milliseconds: 3500)));
        },
      ),
    ],
  );

  showDialog(context: context, builder: (context) => alert);
}

Future<Map> getQuakes() async {
  var apiUrl = Uri.parse(
      "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson");

  http.Response response = await http.get(apiUrl);

  return json.decode(response.body);
}
