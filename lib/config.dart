import 'package:shared_preferences/shared_preferences.dart';

class Config {

  SharedPreferences prefs;

  String assets = "assets";
  List allBibleList = ["ASV", "BSB", "CUV", "CUVs", "ERV", "ISV", "KJV", "LEB", "LXX", "LXXE", "NET", "OHGB", "T4T", "ULT", "UST", "WEB"];
  // the following line is written for personal use only [not for public]
  //List allBibleList = ["CEVD", "CUV", "CSB", "ESV", "EXP", "ISV", "KJV", "LEB", "LXX", "LXXE", "NASB", "NET", "NIV", "OHGB", "WEB"];
  List hebrewBibles = ["OHGB"];
  List greekBibles = ["LXX", "OHGB"];

  // variables linked with shared preferences
  double fontSize = 18.0;
  var abbreviations = "ENG";
  var bible1 = "KJV";
  var bible2 = "NET";
  var historyActiveVerse = [[43, 3, 16]];
  var favouriteVerse = [[43, 3, 16]];
  var morphologySetup = false;

  Future setDefault() async {
    this.prefs = await SharedPreferences.getInstance();

    if (prefs.getDouble("fontSize") == null) {
      prefs.setDouble("fontSize", this.fontSize);
    } else {
      this.fontSize = prefs.getDouble("fontSize");
    }
    if (prefs.getString("abbreviations") == null) {
      prefs.setString("abbreviations", this.abbreviations);
    } else {
      this.abbreviations = prefs.getString("abbreviations");
    }
    if (prefs.getString("bible1") == null) {
      prefs.setString("bible1", this.bible1);
    } else {
      this.bible1 = prefs.getString("bible1");
    }
    if (prefs.getString("bible2") == null) {
      prefs.setString("bible2", this.bible2);
    } else {
      this.bible2 = prefs.getString("bible2");
    }
    if (prefs.getStringList("historyActiveVerse") == null) {
      prefs.setStringList("historyActiveVerse", ["43.3.16"]);
    } else {
      var tempHistoryActiveVerse = prefs.getStringList("historyActiveVerse").map((i) => i.split(".")).toList();
      this.historyActiveVerse = [];
      for (var i in tempHistoryActiveVerse) {
        this.historyActiveVerse.add(i.map((i) => int.parse(i)).toList());
      }
    }
    if (prefs.getStringList("favouriteVerse") == null) {
      prefs.setStringList("favouriteVerse", ["43.3.16"]);
    } else {
      var tempFavouriteVerse = prefs.getStringList("favouriteVerse").map((i) => i.split(".")).toList();
      this.favouriteVerse = [];
      for (var i in tempFavouriteVerse) {
        this.favouriteVerse.add(i.map((i) => int.parse(i)).toList());
      }
    }
    if (prefs.getBool("morphologySetup") == null) {
      prefs.setBool("morphologySetup", this.morphologySetup);
    } else {
      this.morphologySetup = prefs.getBool("morphologySetup");
    }

    return true;
  }

  Future read() async {
    this.prefs = await SharedPreferences.getInstance();

    if (prefs.getDouble("fontSize") != null) this.fontSize = prefs.getDouble("fontSize");
    if (prefs.getString("abbreviations") != null) this.abbreviations = prefs.getString("abbreviations");
    if (prefs.getString("bible1") != null) this.bible1 = prefs.getString("bible1");
    if (prefs.getString("bible2") != null) this.bible2 = prefs.getString("bible2");
    if (prefs.getStringList("historyActiveVerse") != null) {
      var tempHistoryActiveVerse = prefs.getStringList("historyActiveVerse").map((i) => i.split(".")).toList();
      this.historyActiveVerse = [];
      for (var i in tempHistoryActiveVerse) {
        this.historyActiveVerse.add(i.map((i) => int.parse(i)).toList());
      }
    }
    if (prefs.getStringList("favouriteVerse") != null) {
      var tempFavouriteVerse = prefs.getStringList("favouriteVerse").map((i) => i.split(".")).toList();
      this.favouriteVerse = [];
      for (var i in tempFavouriteVerse) {
        this.favouriteVerse.add(i.map((i) => int.parse(i)).toList());
      }
    }
    if (prefs.getBool("morphologySetup") != null) this.morphologySetup = prefs.getBool("morphologySetup");

    return true;
  }

  Future save(String feature, dynamic newSetting) async {
    switch (feature) {
      case "fontSize":
        await prefs.setDouble(feature, newSetting as double);
        break;
      case "abbreviations":
        await prefs.setString(feature, newSetting as String);
        break;
      case "bible1":
        await prefs.setString(feature, newSetting as String);
        break;
      case "bible2":
        await prefs.setString(feature, newSetting as String);
        break;
      case "morphologySetup":
        await prefs.setBool(feature, newSetting as bool);
        break;
    }

    return true;
  }

  Future add(feature, newItem) async {
    switch (feature) {
      case "historyActiveVerse":
        var tempHistoryActiveVerse = prefs.getStringList("historyActiveVerse");
        var newAddition = newItem.join(".");
        if (tempHistoryActiveVerse[0] != newAddition) {
          tempHistoryActiveVerse.insert(0, newAddition);
          // set limitations for the number of history records
          if (tempHistoryActiveVerse.length > 20) tempHistoryActiveVerse = tempHistoryActiveVerse.sublist(0, 20);
          await prefs.setStringList("historyActiveVerse", tempHistoryActiveVerse);
        }
        break;
      case "favouriteVerse":
        var tempFavouriteVerse = prefs.getStringList("favouriteVerse");
        var newAddition = newItem.join(".");
        if (tempFavouriteVerse[0] != newAddition) {
          // avoid duplication in favourite records:
          var check = tempFavouriteVerse.indexOf(newAddition);
          if (check != -1) tempFavouriteVerse.removeAt(check);
          tempFavouriteVerse.insert(0, newAddition);
          // set limitations for the number of history records
          if (tempFavouriteVerse.length > 20) tempFavouriteVerse = tempFavouriteVerse.sublist(0, 20);
          await prefs.setStringList("favouriteVerse", tempFavouriteVerse);
        }
        break;
    }
  }

  Future remove(feature, newItem) async {
    if (feature == "favouriteVerse") {
      var newAddition = newItem.join(".");
      var tempFavouriteVerse = prefs.getStringList("favouriteVerse");
      var check = tempFavouriteVerse.indexOf(newAddition);
      if (check != -1) tempFavouriteVerse.removeAt(check);
      await prefs.setStringList("favouriteVerse", tempFavouriteVerse);
    }
  }

}
