import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

void main(){
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Quotes",
    home: QuotesHome(),
    theme: ThemeData(
      accentColor: Colors.orange,
    ),
  ));
}


List<Quotes> parseQuotes(String responBody){
  final parsed = json.decode(responBody).cast<Map<String,dynamic>>();
  return parsed.map<Quotes>((json) => Quotes.fromJson(json)).toList();
}

//async function for handling the api response
Future<List<Quotes>> fetchQuotes(http.Client client) async{
  final urlApi = "http://quotesondesign.com/wp-json/posts?filter[orderby]=rand&filter[posts_per_page]=10";
  final response = await client.get(urlApi);

  if(response.statusCode == 200){
    return compute(parseQuotes, response.body);
  }
  else{
    throw Exception("Failed to Load Quotes");
  }
}

//Quotes class
class QuotesHome extends StatefulWidget{
  @override
  _QuotesHomeState createState() => _QuotesHomeState();
}


class _QuotesHomeState extends State<QuotesHome>{

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(
          top: height/13,
          bottom: height/18,
        ),
        
        decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.amberAccent,Colors.deepOrangeAccent],
        ),  
        ),



        child: Column(
          children: <Widget>[
            Center(
              child: Text("Quotes",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 50.0,
               ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(
                top: height/25,
              ),
            ),

            FutureBuilder<List<Quotes>>(
              future: fetchQuotes(http.Client()),
              builder: (context, snapshot){
                if(snapshot.hasError) print(snapshot.error);

                if(snapshot.hasData){
                  return _buildQuotesSection(
                    width,
                    height,
                    snapshot.data
                  );
                }else{
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),

          ],
        ),
        
      ),
    );
  }

  Widget _buildQuotesSection(
      final double width,
      final double height,
      final List<Quotes> quotes
      ){

    String _htmlParsed(String text){
      var document = parse(text);
      String parsedString = parse(document.body.text).documentElement.text;
      return parsedString;
    }

    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quotes.length,
        itemBuilder: (context,index){
          return Container(
            margin: EdgeInsets.only(
              right: width/30,
              left: width/30,
            ),
            padding: EdgeInsets.all(20.0),
            width: width/1.1,
            height: height/2.5,
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.25),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                    child: Text(
                      _htmlParsed(quotes[index].content),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 25.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ),

                Center(
                  child: Text(
                    quotes[index].title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );

  }
}


//definition of data to be received from api
class Quotes{
  final int id;
  final String title;
  final String content;

  Quotes({this.id, this.title, this.content});

  factory Quotes.fromJson(Map<String, dynamic> json) {
    return Quotes(
      id: json['ID'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
}