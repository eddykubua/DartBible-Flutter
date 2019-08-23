// Copyright 2019 Eliran Wong. All rights reserved.

import 'package:flutter/material.dart';
import 'package:indexed_list_view/indexed_list_view.dart';
import 'config.dart' as config;
import 'Bibles.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unique Bible App',
      home: UniqueBible(),
    );
  }
}

class UniqueBible extends StatefulWidget {
  @override
  UniqueBibleState createState() => UniqueBibleState();
}

class UniqueBibleState extends State<UniqueBible> {

  final _bibleFont = const TextStyle(fontSize: 18.0);
  List<dynamic> _data = [];
  Bibles bibles;
  int _scrollIndex;

  Future _startup() async {
    if (!config.startup) {
      bibles = Bibles();
      var fetchResults = await bibles.openBible(config.bible1, config.lastReference);
      _data = fetchResults;
      _scrollIndex = 16;
      config.startup = true;
      setState(() {
        print("new data loaded!");
      });
    }

    /* original main function in command-line version:
    if ((arguments.isNotEmpty) && (arguments.length >= 3)) {
      var actions = {
        "open": bibles.openBible,
        "search": bibles.searchBible,
        "compare": bibles.compareBibles,
        "parallel": bibles.parallelBibles,
        "reference": bibles.crossReference,
      };
      var action = arguments[0];
      if (actions.keys.contains(action.toLowerCase())) {
        var module = arguments[1];
        var entry = arguments.sublist(2).join(" ");
        actions[action](module, entry);
      } else {
        bibles.openBible(config.bible1, arguments.join(" "));
      }
    } else {
      bibles.openBible(config.bible1, arguments.join(" "));
    }
    */

  }

  @override
  build(BuildContext context) {
    _startup();
    return Scaffold(
      appBar: AppBar(
        title: Text('Unique Bible App'),

        actions: <Widget>[
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () async {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
              /*
              if (selected != null && selected != _lastIntegerSelected) {
                setState(() {
                  _lastIntegerSelected = selected;
                });
              }
              */
            },
          ),
        ],
      ),
      body: _buildVerses(),
    );
  }

  Widget _buildVerses() {
    var scrollController;
    if (_scrollIndex == null) {
      scrollController = IndexedScrollController();
    } else {
      scrollController = IndexedScrollController(
          initialIndex: _scrollIndex,
          initialScrollOffset: 0.0
      );
    }
    return IndexedListView.builder(
        padding: const EdgeInsets.all(16.0),
        controller: scrollController,
        itemCount: _data.length,
        itemBuilder: (context, i) {
          return _buildRow(i);
        });
  }

  Widget _buildRow(int i) {
    return ListTile(
      title: Text(
        _data[i][1],
        style: _bibleFont,
      ),

      onTap: () {
        setState(() {
          // TODO open a chapter on this verse
          print("Tap; index = $i");
        });
      },

      onLongPress: () {
        setState(() {
          // TODO open cross-references
          print("Long tap; index = $i");
        });
      },
    );
  }

}

class CustomSearchDelegate extends SearchDelegate {

  final _bibleFont = const TextStyle(fontSize: 18.0);
  List<dynamic> _data = [];
  Bibles bibles;
  int _scrollIndex;

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // does not search item less than 2 letters
    if (query.length < 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Search term must be longer than two letters.",
            ),
          )
        ],
      );
    } else {
      return _buildVerses();  
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Column();
  }
  
  Widget _buildVerses() {
    var scrollController;
    if (_scrollIndex == null) {
      scrollController = IndexedScrollController();
    } else {
      scrollController = IndexedScrollController(
          initialIndex: _scrollIndex,
          initialScrollOffset: 0.0
      );
    }
    return IndexedListView.builder(
        padding: const EdgeInsets.all(16.0),
        controller: scrollController,
        itemCount: _data.length,
        itemBuilder: (context, i) {
          return _buildRow(i);
        });
  }

  Widget _buildRow(int i) {
    return ListTile(
      title: Text(
        _data[i][1],
        style: _bibleFont,
      ),

      onTap: () {
        setState(() {
          // TODO open a chapter on this verse
          print("Tap; index = $i");
        });
      },

      onLongPress: () {
        setState(() {
          // TODO open cross-references
          print("Long tap; index = $i");
        });
      },
    );
  }

}