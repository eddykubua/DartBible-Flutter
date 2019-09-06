import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:unique_bible_app/Helpers.dart';
import 'package:unique_bible_app/BibleParser.dart';

// a very simple html parser, not exhaustive
class HTMLParser {

  final double _fontSize;
  final String _abbreviations;
  BibleParser _parser;
  RegexHelper _regex;
  TextStyle _defaultStyle, _bcvStyle, _hStyle, _iStyle, _uStyle, _bStyle;

  HTMLParser(this._abbreviations, this._fontSize) {
    _parser = BibleParser(this._abbreviations);
    _regex = RegexHelper();
    _defaultStyle = TextStyle(fontSize: this._fontSize);
    _bcvStyle = TextStyle(fontSize: (this._fontSize - 2), color: Colors.indigo, decoration: TextDecoration.underline);
    _hStyle = TextStyle(fontSize: (this._fontSize + 4), fontWeight: FontWeight.bold);
    _iStyle = TextStyle(fontSize: this._fontSize, fontStyle: FontStyle.italic);
    _uStyle = TextStyle(fontSize: this._fontSize, decoration: TextDecoration.underline);
    _bStyle = TextStyle(fontSize: this._fontSize, fontWeight: FontWeight.bold);
  }

  convertHtmlText(String htmlText) {
    _regex.searchReplace = [
      ['\n|<p>', ''],
      [r'<h([0-9]*?)>(.*?)</h\1>', r'％＄\2％</p>'],
      ['<br>|<br/>|<br />', '\n'],
      ['</p>', '\n\n'],
      ['<i>(.*?)</i>', r'％｛\1％'],
      ['<b>(.*?)</b>', r'％＊\1％'],
      ['<u>(.*?)</u>', r'％｝\1％'],
      [r'<ref onclick="bcv\(([0-9,]+?)\)">.*?</ref>', r'％＠\1％'],
    ];
    return _regex.doSearchReplace(htmlText);
  }

  Widget buildRichText(BuildContext context, String plainText, Function bcvAction) {

    List<TextSpan> textSpans = [];
    List<String> textList = plainText.split("％");
    for (var text in textList) {
      if (text.startsWith("＠")) {
        List<dynamic> bcvList = text.substring(1).split(",");
        bcvList = bcvList.map((i) => int.parse(i)).toList();
        String bcvReference = _parser.bcvToVerseReference(bcvList);
        textSpans.add(TextSpan(text: bcvReference, style: _bcvStyle, recognizer: TapGestureRecognizer()..onTap = () => bcvAction(bcvList)));
      } else if (text.startsWith("＄")) {
        textSpans.add(TextSpan(text: text.substring(1), style: _hStyle));
      } else if (text.startsWith("｛")) {
        textSpans.add(TextSpan(text: text.substring(1), style: _iStyle));
      } else if (text.startsWith("＊")) {
        textSpans.add(TextSpan(text: text.substring(1), style: _bStyle));
      } else if (text.startsWith("｝")) {
        textSpans.add(TextSpan(text: text.substring(1), style: _uStyle));
      } else {
        textSpans.add(TextSpan(text: text, style: _defaultStyle));
      }
    }

    return RichText(
      text: TextSpan(
        //style: DefaultTextStyle.of(context).style,
        children: textSpans,
      ),
    );
  }

}