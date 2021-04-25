// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(MaterialApp(
    title: "GraphQL App",
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink('https://countries.trevorblades.com/');
    final ValueNotifier<GraphQLClient> client =
        ValueNotifier<GraphQLClient>(GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    ));
    return GraphQLProvider(
      child: HomePage(),
      client: client,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String readRepositories = """
    query Countries {
            countries {
                 name
                 emoji
                 currency
                 capital
            }
    }""";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Country List"),
      ),
      backgroundColor: Colors.black,
      body: Query(
          options: QueryOptions(
            document: gql(readRepositories),
            variables: {
              'nRepositories': 50,
            },
            pollInterval: Duration(seconds: 1),
          ),
          builder: (QueryResult result,
              {VoidCallback refetch, FetchMore fetchMore}) {
            if (result.hasException) {
              return Text("Value:" + result.exception.toString());
            }
            if (result.data == null) {
              return Text("No Data Found", style: TextStyle(color: Colors.red));
            }
            if (result.isLoading) {
              return Text(
                'Loading',
                style: TextStyle(color: Colors.red),
              );
            }
            return _countriesView(result);
          }),
    );
  }
}

ListView _countriesView(QueryResult result) {
  final countryList = result.data['countries'];
  return ListView.separated(
    itemCount: countryList.length,
    itemBuilder: (context, index) {
      return ListTile(
        title: Text(
          countryList[index]['name'],
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          'Currency: ${countryList[index]['currency']}',
          style: TextStyle(color: Colors.green),
        ),
        leading: Text(
          countryList[index]['emoji'] ?? "Empty",
          style: TextStyle(color: Colors.red, fontSize: 50),
        ),
        onTap: () {
          final snackBar = SnackBar(
              content: Text(
                  'Selected Country Capital: ${countryList[index]['capital']}'));
          Scaffold.of(context).showSnackBar(snackBar);
        },
      );
    },
    separatorBuilder: (context, index) {
      return Divider();
    },
  );
}
