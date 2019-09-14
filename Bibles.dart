import 'Helpers.dart';
import 'BibleParser.dart';
import 'config.dart';

class Bibles {

  var bible1, bible2, bible3, iBible;

  String abbreviations;
  Map interfaceBibles = {
    "ENG": ["Compare", "Cross-references"],
    "TC": ["比較", "相關經文"],
    "SC": ["比较", "相关经文"],
  };

  Map getBibles() => {1: this.bible1, 2: this.bible1};

  Bibles(String abbreviations) {
    this.abbreviations = abbreviations;
  }

  List getALLBibleList() {
    var config = Config();
    return config.allBibleList..sort();
  }

  List getValidBibleList(List bibleList) {
    var validBibleList = [];
    var allBibleList = this.getALLBibleList();
    for (var bible in bibleList) {
      if (allBibleList.contains(bible)) validBibleList.add(bible);
    }
    validBibleList.sort();
    return validBibleList;
  }

  Future compareBibles(List bibleList, List bcvList) async {
    if ((bibleList.isNotEmpty) && (bcvList.isNotEmpty)) {
      var versesFound = await this.compareVerses([bcvList], bibleList);
      return versesFound;
    }
    return [];
  }

  Future compareVerses(List listOfBcvList, List bibleList) async {
    List<dynamic> versesFound = [];

    for (var bcvList in listOfBcvList) {
      versesFound.add([[], "[${interfaceBibles[this.abbreviations][0]} ${BibleParser(this.abbreviations).bcvToVerseReference(bcvList)}]", ""]);
      for (var bible in bibleList) {
        var verseText;
        if (bible == this.bible1.module) {
          verseText = this.bible1.openSingleVerse(bcvList);
        } else if (bible == this.bible2.module) {
          verseText = this.bible2.openSingleVerse(bcvList);
        } else {
          verseText = await Bible(bible, this.abbreviations).openCompareSingleVerse(bcvList);
        }
        versesFound.add([bcvList, "[$bible] $verseText", bible]);
      }
    }
    return versesFound;
  }

  List<dynamic> parallelBibles(List bcvList) {
    List<dynamic> versesFound = [];

    if (bcvList.isNotEmpty) {
      //versesFound.add([[], "[${BibleParser(this.abbreviations).bcvToChapterReference(bcvList)}]"]);

      var b = bcvList[0];
      var c = bcvList[1];
      //var v = bcvList[2];

      var bible1VerseList = this.bible1.getVerseList(b, c);
      var vs1 = bible1VerseList[0];
      var ve1 = bible1VerseList[(bible1VerseList.length - 1)];

      var bible2VerseList = this.bible2.getVerseList(b, c);
      var vs2 = bible2VerseList[0];
      var ve2 = bible2VerseList[(bible2VerseList.length - 1)];

      var vs, ve;
      (vs1 <= vs2) ? vs = vs1 : vs = vs2;
      (ve1 >= ve2) ? ve = ve1 : ve = ve2;

      for (var i = vs; i <= ve; i++) {
        var ibcv = [b, c, i];
        var verseText1 = this.bible1.openSingleVerse(ibcv);
        var verseText2 = this.bible2.openSingleVerse(ibcv);
        versesFound.add([ibcv, verseText1, this.bible1.module]);
        versesFound.add([ibcv, verseText2, this.bible2.module]);
      }
    }

    return versesFound;
  }

  Future crossReference(List bcvList) async {
    var xRefList;
    if (bcvList.isNotEmpty) xRefList = await this.getCrossReference(bcvList);
    if (xRefList.isNotEmpty) {
      xRefList = [bcvList, ...xRefList]; // include the original verse
      var versesFound = this.bible1.openMultipleVerses(xRefList, "[${interfaceBibles[this.abbreviations][1]}]");
      return versesFound;
    }
    return [];
  }

  Future getCrossReference(List bcvList) async {
    var filePath = FileIOHelper().getDataPath("xRef", "xRef");
    var jsonObject = await JsonHelper().getJsonObject(filePath);
    var bcvString = bcvList.join(".");
    var fetchResults = jsonObject.where((i) => (i["bcv"] == bcvString)).toList();
    var referenceString = fetchResults[0]["xref"];
    return BibleParser(this.abbreviations).extractAllReferences(referenceString);
  }

}

class Bible {

  String module;
  String biblePath;
  List data;
  List bookList;

  String abbreviations;
  Map interfaceBible = {
    "ENG": ["is found in", "verse(s)."],
    "TC": ["在", "節經文裡找到"],
    "SC": ["在", "节经文里找到"],
  };

  Bible(String bible, String abbreviations) {
    this.module = bible;
    this.biblePath = FileIOHelper().getDataPath("bible", bible);
    this.abbreviations = abbreviations;
  }

  Future loadData() async {
    this.data = await JsonHelper().getJsonObject(this.biblePath);
    this.bookList = getBookList();
  }

  Future openCompareSingleVerse(List bcvList) async {
    if (this.data == null) await this.loadData();

    String versesFound = "";

    var b = bcvList[0];
    var c = bcvList[1];
    var v = bcvList[2];

    var fetchResults = this.data.where((i) => ((i["bNo"] == b) && (i["cNo"] == c) && (i["vNo"] == v))).toList();
    for (var found in fetchResults) {
      var verseText = found["vText"].trim();
      versesFound += "$verseText ";
    }

    return versesFound.trimRight();
  }

  List getBookList() {
    Set books = {};
    for (var i in this.data) {
      if (i["bNo"] != 0) books.add(i["bNo"]);
    }
    return books.toList()..sort();
  }

  List getChapterList(int b) {
    var fetchResults = this.data.where((i) => (i["bNo"] == b)).toList();
    return fetchResults.map((i) => i["cNo"]).toSet().toList()..sort();
  }

  List getVerseList(int b, int c) {
    var fetchResults = this.data.where((i) => ((i["bNo"] == b) && (i["cNo"] == c))).toList();
    return fetchResults.map((i) => i["vNo"]).toSet().toList()..sort();
  }

  String openSingleVerse(List bcvList) {

    String versesFound = "";

    var b = bcvList[0];
    var c = bcvList[1];
    var v = bcvList[2];

    var fetchResults = this.data.where((i) => ((i["bNo"] == b) && (i["cNo"] == c) && (i["vNo"] == v))).toList();
    for (var found in fetchResults) {
      var verseText = found["vText"].trim();
      versesFound += "$verseText ";
    }

    return versesFound.trimRight();
  }

  String openSingleVerseRange(List bcvList) {

    String versesFound = "";

    var b = bcvList[0];
    var c = bcvList[1];
    var v = bcvList[2];
    var c2 = bcvList[3];
    var v2 = bcvList[4];

    var check, fetchResults;

    if ((c2 == c) && (v2 > v)) {
      check = v;
      while (check <= v2) {
        fetchResults = this.data.where((i) => ((i["bNo"] == b) && (i["cNo"] == c) && (i["vNo"] == check))).toList();
        for (var found in fetchResults) {
          var verseText = "[${found["vNo"]}] ${found["vText"].trim()}";
          versesFound += "$verseText ";
        }
        check += 1;
      }
    } else if (c2 > c) {
      check = c;
      while (check < c2) {
        fetchResults = this.data.where((i) => ((i["bNo"] == b) && (i["cNo"] == check))).toList();
        for (var found in fetchResults) {
          var verseText = found["vText"].trim();
          versesFound += "$verseText ";
        }
        check += 1;
      }
      check = 0; // some bible versions may have chapters starting with verse 0.
      while (check <= v2) {
        fetchResults = this.data.where((i) => ((i["bNo"] == b) && (i["cNo"] == c) && (i["vNo"] == check))).toList();
        for (var found in fetchResults) {
          var verseText = found["vText"].trim();
          versesFound += "$verseText ";
        }
        check += 1;
      }
    }

    return versesFound.trimRight();
  }

  List openSingleChapter(List bcvList) {

    List<dynamic> versesFound = [];
    //versesFound.add([[], "[${BibleParser(this.abbreviations).bcvToChapterReference(bcvList)}, ${this.module}]", this.module]);
    var fetchResults = this.data.where((i) => ((i["bNo"] == bcvList[0]) && (i["cNo"] == bcvList[1]))).toList();
    for (var found in fetchResults) {
      var b = found["bNo"];
      var c = found["cNo"];
      var v = found["vNo"];
      var verseText = found["vText"].trim();
      versesFound.add([[b, c, v], verseText, this.module]);
    }
    return versesFound;
  }

  List openMultipleVerses(List listOfBcvList, [String featureString]) {

    List<dynamic> versesFound = [];
    if (featureString != null) versesFound.add([[], featureString, ""]);

    for (var bcvList in listOfBcvList) {
      var referenceString = "[${BibleParser(this.abbreviations).bcvToVerseReference(bcvList)}]";
      if (bcvList.length == 5) {
        var verse = openSingleVerseRange(bcvList);
        versesFound.add([bcvList, "$referenceString $verse", this.module]);
      } else {
        var verse = openSingleVerse(bcvList);
        versesFound.add([bcvList, "$referenceString $verse", this.module]);
      }
    }
    return versesFound;
  }

  List search(String searchString) {

    var fetchResults = this.data.where((i) => (i["vText"].contains(RegExp(searchString)) as bool)).toList();

    List<dynamic> versesFound = [];
    versesFound.add([[], "[$searchString ${interfaceBible[this.abbreviations][0]} ${fetchResults.length} ${interfaceBible[this.abbreviations][1]}]", ""]);

    for (var found in fetchResults) {
      var b = found["bNo"];
      var c = found["cNo"];
      var v = found["vNo"];
      var bcvRef = BibleParser(this.abbreviations).bcvToVerseReference([b, c, v]);
      var verseText = found["vText"];
      versesFound.add([[b, c, v], "[$bcvRef] $verseText", this.module]);
    }
    return versesFound;
  }

  List searchBooks(String searchString, List referenceList) {

    List<dynamic> versesFound = [];

    Set books = {};
    for (var ref in referenceList) {
      books.add(ref[0]);
    }
    var bookList = books.toList();
    bookList.sort();

    for (var book in bookList) {
      var fetchResults = this.data.where((i) => ((i["bNo"] == book) && (i["vText"].contains(RegExp(searchString)) as bool))).toList();
      for (var found in fetchResults) {
        var b = found["bNo"];
        var c = found["cNo"];
        var v = found["vNo"];
        var bcvRef = BibleParser(this.abbreviations).bcvToVerseReference([b, c, v]);
        var verseText = found["vText"];
        versesFound.add([[b, c, v], "[$bcvRef] $verseText", this.module]);
      }
    }

    versesFound.insert(0, [[], "[$searchString ${interfaceBible[this.abbreviations][0]} ${versesFound.length} ${interfaceBible[this.abbreviations][1]}]", ""]);

    return versesFound;
  }

}