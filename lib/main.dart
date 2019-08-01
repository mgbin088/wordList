// Create an infinite scrolling lazily loaded list

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'dart:async';
import 'package:starflut/starflut.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Startup Name Generator',
      theme: new ThemeData(          // Add the 3 lines from here...
        primaryColor: Colors.blue,
      ),
      home: new RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => new RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  String _outputString = "python 3.6";
  final List<WordPair> _suggestions = <WordPair>[];
  final Set<WordPair> _saved = new Set<WordPair>();   // Add this line.
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  RandomWordsState()
  {
    _initStarCore();
  }

  StarSrvGroupClass srvGroup;
  void _initStarCore() async{
    StarCoreFactory starcore = await Starflut.getFactory();
    StarServiceClass Service = await starcore.initSimple("test", "123", 0, 0, []);
    await starcore.regMsgCallBackP(
            (int serviceGroupID, int uMsg, Object wParam, Object lParam) async{
          if( uMsg == Starflut.MSG_DISPMSG || uMsg == Starflut.MSG_DISPLUAMSG ){
            ShowOutput(wParam);
          }
          print("$serviceGroupID  $uMsg   $wParam   $lParam");
          return null;
        });
    srvGroup = await Service["_ServiceGroup"];
    bool isAndroid = await Starflut.isAndroid();
    if( isAndroid == true ){
      String libraryDir = await Starflut.getNativeLibraryDir();
      String docPath = await Starflut.getDocumentPath();
      if( libraryDir.indexOf("arm64") > 0 ){
        Starflut.unzipFromAssets("lib-dynload-arm64.zip", docPath, true);
      }else if( libraryDir.indexOf("x86_64") > 0 ){
        Starflut.unzipFromAssets("lib-dynload-x86_64.zip", docPath, true);
      }else if( libraryDir.indexOf("arm") > 0 ){
        Starflut.unzipFromAssets("lib-dynload-armeabi.zip", docPath, true);
      }else{  //x86
        Starflut.unzipFromAssets("lib-dynload-x86.zip", docPath, true);
      }
      var py_result1 = await Starflut.copyFileFromAssets("test.py", "flutter_assets/starfiles","flutter_assets/starfiles");
      py_result1 = await Starflut.copyFileFromAssets("python3.6.zip", "flutter_assets/starfiles",null);  //desRelatePath must be null
      await Starflut.copyFileFromAssets("unicodedata.cpython-36m.so", null,null);
      await Starflut.loadLibrary("libpython3.6m.so");
    }

    if( await srvGroup.initRaw("python36", Service) == true ){
      _outputString = "init starcore and python 3.6 successfully";
      print("$_outputString");
    }else{
      _outputString = "init starcore and python 3.6 failed";
      print("$_outputString");
    }

    print("starsrvgroup = " + await srvGroup.getString());

    bool run_result = await srvGroup.runScript("python36", "print(\"Hello World!\")", "");
    print("$run_result");

    dynamic rr1 = await srvGroup.initRaw("python36", Service);
    print("initRaw = $rr1");

    String docPath = await Starflut.getDocumentPath();
    print("docPath = $docPath");

    String resPath = await Starflut.getResourcePath();
    print("resPath = $resPath");

    var result = await srvGroup.loadRawModule("python", "", resPath + "/flutter_assets/starfiles/" + "test.py", false);
    print("loadRawModule = $result");

    dynamic python = await Service.importRawContext("python", "", false, "");
    print("python = "+ await python.getString());

    StarObjectClass retobj = await python.call("tt", ["hello ", "world"]);
    print(await retobj[0]);
    print(await retobj[1]);

    print(await python["g1"]);

    StarObjectClass yy = await python.call("yy", ["hello ", "world", 123]);
    print(await yy.call("__len__",[]));

    StarObjectClass multiply = await Service.importRawContext("python", "Multiply", true, "");
    StarObjectClass multiply_inst = await multiply.newObject(["", "", 33, 44]);
    print(await multiply_inst.getString());

    print(await multiply_inst.call("multiply", [11, 22]));
    await srvGroup.clearService();
    await starcore.moduleExit();
  }

  void ShowOutput(String Info) async{
    if( Info == null || Info.length == 0)
      return;
    _outputString = _outputString + "\n" + Info;
    setState((){

    });
  }

  void runScriptCode(String text) async{
    await srvGroup.runScript("python", text, null);
    setState((){

    });
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Startup Name Generator'),
        actions: <Widget>[      // Add 3 lines from here...
          new IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
        ],                      //
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return const Divider();
          }
          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(WordPair pair) {
    final bool alreadySaved = _saved.contains(pair);  // Add this line.
    return new ListTile(
      title: new Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: new Icon(   // Add the lines from here...
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),                    // ... to here.
      onTap: () {      // Add 9 lines from here...
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },               // ... to here.
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(   // Add 20 lines from here...
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
                (WordPair pair) {
              return new ListTile(
                title: new Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final List<Widget> divided = ListTile
              .divideTiles(
            context: context,
            tiles: tiles,
          )
              .toList();
          return new Scaffold(         // Add 6 lines from here...
            appBar: new AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: new ListView(children: divided),
          );                           // ... to here.
        },
      ),                           // ... to here.
    );
  }
}