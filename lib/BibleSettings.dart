import 'package:flutter/material.dart';
import 'BibleParser.dart';
import 'Bibles.dart';
import 'config.dart';

class BibleSettings extends StatefulWidget {
  final Bible _bible;
  final List _bcvList;
  final Map _favouriteActionMap;
  final Config _config;

  BibleSettings(
      this._bible, this._bcvList, this._favouriteActionMap, this._config);

  @override
  BibleSettingsState createState() =>
      BibleSettingsState(_bible, _bcvList, _favouriteActionMap, _config);
}

class BibleSettingsState extends State<BibleSettings> {
  List _interface;

  String abbreviations;
  Map interfaceBibleSettings = {
    "ENG": [
      "Settings",
      "Interface",
      "Bible",
      "Book",
      "Chapter",
      "Verse",
      "Font Size",
      "Versions for Comparison",
      "Favourite Action",
      "Instant Action",
      "Save",
      "Background Brightness",
    ],
    "TC": [
      "設定",
      "介面語言",
      "聖經",
      "書卷",
      "章",
      "節",
      "字體大小",
      "版本比較選項",
      "常用功能",
      "即時功能",
      "存檔",
      "背景顏色深淺",
    ],
    "SC": [
      "设定",
      "接口语言",
      "圣经",
      "书卷",
      "章",
      "节",
      "字体大小",
      "版本比较选项",
      "常用功能",
      "即时功能",
      "存档",
      "背景颜色深浅",
    ],
  };

  Bible _bible;

  BibleParser _parser;
  Map _abbreviations;
  List _bookList, _chapterList, _verseList;
  List<String> _compareBibleList;
  String _moduleValue,
      _bookValue,
      _chapterValue,
      _verseValue,
      _fontSizeValue,
      _interfaceValue,
      _colorDegreeValue;

  List fontSizeList = [
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18",
    "19",
    "20",
    "21",
    "22",
    "23",
    "24",
    "25",
    "26",
    "27",
    "28",
    "29",
    "30",
    "31",
    "32",
    "33",
    "34",
    "35",
    "36",
    "37",
    "38",
    "39",
    "40"
  ];

  List colorDegree = ["0", "100", "200", "300", "400", "500", "600", "700", "800", "900"];

  Map interfaceMap = {"English": "ENG", "繁體中文": "TC", "简体中文": "SC"};

  Map _instantActionMap = {
    "ENG": ["Tips", "Interlinear"],
    "TC": ["提示", "原文逐字翻譯"],
    "SC": ["提示", "原文逐字翻译"],
  };
  Map _favouriteActionMap;
  List _instantActionList, _favouriteActionList;
  int _instantAction, _favouriteAction;
  Config _config;

  BibleSettingsState(Bible bible, List bcvList, Map favouriteActionMap, this._config) {
    // The following line is used instead of "this._compareBibleList = compareBibleList";
    // Reason: To avoid direct update of original config settings
    // This allows users to cancel the changes made by pressing the "back" button
    this._compareBibleList = List<String>.from(_config.compareBibleList);

    this._fontSizeValue = _config.fontSize
        .toString()
        .substring(0, (_config.fontSize.toString().length - 2));
    this.abbreviations = _config.abbreviations;
    this._interface = interfaceBibleSettings[this.abbreviations];
    var interfaceMapReverse = {"ENG": "English", "TC": "繁體中文", "SC": "简体中文"};
    this._interfaceValue = interfaceMapReverse[this.abbreviations];
    this._colorDegreeValue = _config.backgroundColor.toString();

    this._parser = BibleParser(this.abbreviations);
    this._abbreviations = this._parser.standardAbbreviation;

    this._bible = bible;
    this._moduleValue = this._bible.module;

    this._bookValue = this._abbreviations[bcvList[0].toString()];
    this._chapterValue = bcvList[1].toString();
    this._verseValue = bcvList[2].toString();

    this._favouriteActionMap = favouriteActionMap;
    this._favouriteActionList =
        this._favouriteActionMap[this.abbreviations].sublist(4);
    this._favouriteActionList.insert(0, "---");
    this._favouriteAction = _config.favouriteAction + 1;

    this._instantActionList = this._instantActionMap[this.abbreviations];
    this._instantActionList.insert(0, "---");
    this._instantAction = _config.instantAction + 1;

    updateSettingsValues();
  }

  Future onModuleChanged(String module) async {
    this._bible = Bible(module, this.abbreviations);
    this._moduleValue = this._bible.module;
    await this._bible.loadData();

    setState(() {
      updateSettingsValues();
    });
  }

  void updateSettingsValues() {
    this._bookList = this._bible.bookList;
    this._bookList =
        this._bookList.map((i) => this._abbreviations[(i).toString()]).toList();
    if (!(this._bookList.contains(this._bookValue))) {
      this._bookValue = this._bookList[0];
      this._chapterValue = "1";
      this._verseValue = "1";
    }

    var bookNoString = getBookNo();

    this._chapterList = this._bible.getChapterList(int.parse(bookNoString));
    this._chapterList = this._chapterList.map((i) => (i).toString()).toList();
    if (!(this._chapterList.contains(this._chapterValue)))
      this._chapterValue = this._chapterList[0];

    this._verseList = this
        ._bible
        .getVerseList(int.parse(bookNoString), int.parse(this._chapterValue));
    this._verseList = this._verseList.map((i) => (i).toString()).toList();
    if (!(this._verseList.contains(this._verseValue)))
      this._verseValue = this._verseList[0];
  }

  void updateInterface(String newValue) {
    var bookIndex = this._bookList.indexOf(this._bookValue);

    this._interfaceValue = newValue;
    this.abbreviations = this.interfaceMap[newValue];

    this._interface = interfaceBibleSettings[this.abbreviations];
    this._abbreviations = BibleParser(this.abbreviations).standardAbbreviation;
    this._bookList = this._bible.bookList;
    this._bookList =
        this._bookList.map((i) => this._abbreviations[(i).toString()]).toList();
    this._bookValue = this._bookList[bookIndex];

    this._favouriteActionList =
        this._favouriteActionMap[this.abbreviations].sublist(3);
    this._favouriteActionList.insert(0, "---");

    this._instantActionList = this._instantActionMap[this.abbreviations];
    this._instantActionList.insert(0, "---");
  }

  String getBookNo() {
    if (this._parser.bibleBookNo.keys.contains(this._bookValue)) {
      return this._parser.bibleBookNo[this._bookValue];
    } else if (this._parser.bibleBookNo.keys.contains("${this._bookValue}.")) {
      return this._parser.bibleBookNo["${this._bookValue}."];
    }
    return null;
  }

  @override
  build(BuildContext context) {
    return Theme(
      data: ThemeData(
        canvasColor: (int.parse(_colorDegreeValue) >= 500) ? Colors.blueGrey[int.parse(_colorDegreeValue) - 200] : Colors.blueGrey[int.parse(_colorDegreeValue)],
        unselectedWidgetColor: (int.parse(_colorDegreeValue) >= 500) ? Colors.blue[300] : Colors.blue[700],
        accentColor: (int.parse(_colorDegreeValue) >= 500) ? Colors.blueAccent[100] : Colors.blueAccent[700],
        dividerColor: (int.parse(_colorDegreeValue) >= 500) ? Colors.grey[400] : Colors.grey[700],
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: (int.parse(_colorDegreeValue) >= 500) ? Colors.blueGrey[int.parse(_colorDegreeValue) - 200] : Colors.blue[600],
          title: Text(this._interface[0]),
          actions: <Widget>[
            IconButton(
              tooltip: _interface[10],
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(
                    context,
                    BibleSettingsParser(
                      this._moduleValue,
                      getBookNo(),
                      this._chapterValue,
                      this._verseValue,
                      this.interfaceMap[this._interfaceValue],
                      this._fontSizeValue,
                      this._compareBibleList,
                      this._favouriteAction,
                      this._instantAction,
                      this._colorDegreeValue,
                    ));
              },
            ),
          ],
        ),
        body: _bibleSettings(context),
      ),
    );
  }

  Widget _bibleSettings(BuildContext context) {
    TextStyle style = (int.parse(_colorDegreeValue) >= 500) ? TextStyle(color: Colors.grey[300]) : TextStyle(color: Colors.black);

    Color dropdownBackground = (int.parse(_colorDegreeValue) >= 500) ? Colors.blueGrey[int.parse(_colorDegreeValue) - 200] : Colors.blueGrey[int.parse(_colorDegreeValue)];
    Color dropdownBorder = (int.parse(_colorDegreeValue) >= 500) ? Colors.grey[400] : Colors.grey[700];
    Color dropdownDisabled = (int.parse(_colorDegreeValue) >= 500) ? Colors.blueAccent[100] : Colors.blueAccent[700];
    Color dropdownEnabled = (int.parse(_colorDegreeValue) >= 500) ? Colors.blueAccent[100] : Colors.blueAccent[700];

    Widget dropdownUnderline = Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: dropdownBorder))
      ),
    );

    List moduleList = Bibles(this.abbreviations).getALLBibleList();
    List<Widget> versionRowList =
        moduleList.map((i) => _buildVersionRow(context, i, dropdownBackground)).toList();



    return Container(
      color: Colors.blueGrey[int.parse(_colorDegreeValue)],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text(this._interface[1], style: style),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: this._interfaceValue,
                onChanged: (String newValue) {
                  if (this._interfaceValue != newValue) {
                    setState(() {
                      this.updateInterface(newValue);
                    });
                  }
                },
                items: <String>[...interfaceMap.keys.toList()]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(this._interface[11], style: style),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: _colorDegreeValue,
                onChanged: (String newValue) {
                  if (this._colorDegreeValue != newValue) {
                    setState(() {
                      this._colorDegreeValue = newValue;
                    });
                  }
                },
                items: <String>[...colorDegree]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(this._interface[6], style: style),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: this._fontSizeValue,
                onChanged: (String newValue) {
                  if (this._verseValue != newValue) {
                    setState(() {
                      this._fontSizeValue = newValue;
                    });
                  }
                },
                items: <String>[...fontSizeList]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(this._interface[2], style: style),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: this._moduleValue,
                onChanged: (String newValue) {
                  if (this._moduleValue != newValue) {
                    onModuleChanged(newValue);
                  }
                },
                items: <String>[...moduleList]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(this._interface[3], style: style),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: this._bookValue,
                onChanged: (String newValue) {
                  if (this._bookValue != newValue) {
                    setState(() {
                      this._bookValue = newValue;
                      this._chapterList =
                          this._bible.getChapterList(int.parse(getBookNo()));
                      this._chapterList =
                          this._chapterList.map((i) => (i).toString()).toList();
                      this._chapterValue = "1";
                      this._verseList = this._bible.getVerseList(
                          int.parse(getBookNo()), int.parse(this._chapterValue));
                      this._verseList =
                          this._verseList.map((i) => (i).toString()).toList();
                      this._verseValue = "1";
                    });
                  }
                },
                items: <String>[...this._bookList]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(this._interface[4], style: style),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: this._chapterValue,
                onChanged: (String newValue) {
                  if (this._chapterValue != newValue) {
                    setState(() {
                      this._chapterValue = newValue;
                      this._verseList = this._bible.getVerseList(
                          int.parse(getBookNo()), int.parse(this._chapterValue));
                      this._verseList =
                          this._verseList.map((i) => (i).toString()).toList();
                      this._verseValue = "1";
                    });
                  }
                },
                items: <String>[...this._chapterList]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(this._interface[5], style: style),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: this._verseValue,
                onChanged: (String newValue) {
                  if (this._verseValue != newValue) {
                    setState(() {
                      this._verseValue = newValue;
                    });
                  }
                },
                items: <String>[...this._verseList]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(this._interface[9], style: style),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: this._instantActionList[this._instantAction],
                onChanged: (String newValue) {
                  if (this._instantActionList[this._instantAction] != newValue) {
                    setState(() {
                      this._instantAction =
                          this._instantActionList.indexOf(newValue);
                    });
                  }
                },
                items: <String>[...this._instantActionList]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(this._interface[8], style: style,),
              trailing: DropdownButton<String>(
                style: style,
                underline: dropdownUnderline,
                iconDisabledColor: dropdownDisabled,
                iconEnabledColor: dropdownEnabled,
                value: this._favouriteActionList[this._favouriteAction],
                onChanged: (String newValue) {
                  if (this._favouriteActionList[this._favouriteAction] !=
                      newValue) {
                    setState(() {
                      this._favouriteAction =
                          this._favouriteActionList.indexOf(newValue);
                    });
                  }
                },
                items: <String>[...this._favouriteActionList]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ExpansionTile(
              title: Text(this._interface[7], style: style),
              backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
              children: versionRowList,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionRow(BuildContext context, String version, Color dropdownBackground) {
    return Container(
      color: dropdownBackground,
      child: CheckboxListTile(
        title: Text(version, style: TextStyle(color: (int.parse(_colorDegreeValue) >= 700) ? Colors.blue[300] : Colors.blue[700]),),
        //activeColor: (int.parse(_colorDegreeValue) >= 500) ? Colors.blueGrey[int.parse(_colorDegreeValue) - 200] : Colors.blue[600],
        //checkColor: (int.parse(_colorDegreeValue) >= 500) ? Colors.grey[300] : Colors.black,
        value: (this._compareBibleList.contains(version)),
        onChanged: (bool value) {
          setState(() {
            if (value) {
              this._compareBibleList.add(version);
            } else {
              var versionIndex = this._compareBibleList.indexOf(version);
              this._compareBibleList.removeAt(versionIndex);
            }
          });
        },
      ),
    );
  }

}

class BibleSettingsParser {
  final String module, _book, _chapter, _verse, abbreviations, _fontSize, _backgroundColor;
  final List<String> _compareBibleList;
  final int _instantAction, _quickAction;
  int book, chapter, verse, instantAction, favouriteAction, backgroundColor;
  double fontSize;
  List<String> compareBibleList;

  BibleSettingsParser(
      this.module,
      this._book,
      this._chapter,
      this._verse,
      this.abbreviations,
      this._fontSize,
      this._compareBibleList,
      this._quickAction,
      this._instantAction,
      this._backgroundColor,) {
    this.book = int.parse(this._book);
    this.chapter = int.parse(this._chapter);
    this.verse = int.parse(this._verse);
    this.fontSize = double.parse(this._fontSize);
    this.compareBibleList = this._compareBibleList..sort();
    this.favouriteAction = this._quickAction - 1;
    this.instantAction = this._instantAction - 1;
    this.backgroundColor = int.parse(this._backgroundColor);
  }
}
