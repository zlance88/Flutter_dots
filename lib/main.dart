import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:charts_flutter/flutter.dart' as charts;

void main() {
  runApp(MyApp());
}

int _counterBlack = 0;
int _counterWhite = 0;
var today = DateTime.now().toString().replaceAll("-", "").substring(0, 8);
var todayB = today + "B";
var todayW = today + "W";
var mapBlack = new Map();
var mapWhite = new Map();
enum WhyFarther { one, two, three, four }
List<DailyDots> dataDotsB = [];
List<DailyDots> dataDotsW = [];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '意念之石',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // English, no country code
        const Locale('es', ''), // Spanish, no country code
        const Locale('cn', ''),
      ],
      routes: {
        // '/': (context) => SignUpScreen(),
        // '/welcome': (context) => WelcomeScreen(),
        '/': (context) => WelcomeScreen(),
        '/home': (context) => MyHomePage(title: '意念之石'),
      },
    );
  }
}

void _counterRead() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  _counterBlack = (prefs.getInt('counterB') ?? 0);
  _counterWhite = (prefs.getInt('counterW') ?? 0);
}

void mapRead() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  dataDotsB.clear();
  dataDotsW.clear();
  for (int i = 9; i >= 0; i--) {
    var key = DateTime.now()
        .subtract((const Duration(days: 1)) * i)
        .toString()
        .replaceAll("-", "")
        .substring(0, 8);
    var keyB = key + "B";
    var keyW = key + "W";
    int valB = (prefs.getInt(keyB) ?? 0);
    int valW = (prefs.getInt(keyW) ?? 0);
    mapBlack[keyB] = valB;
    mapWhite[keyW] = valW;
    dataDotsB.add(DailyDots(i, valB));
    dataDotsW.add(DailyDots(i, valW));
  }
}

void mapWriteBlack(int counter) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(todayB, counter);
  mapRead();
}

void mapWriteWhite(int counter) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(todayW, counter);
  //int test = (prefs.getInt(todayW) ?? 0);
  //print('Map value updated:$test');
  mapRead();
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounterBlack() async {
    setState(() {
      _counterBlack++;
      //print('Pressed $_counterBlack times.');
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counterB', _counterBlack);
    mapWriteBlack(_counterBlack);
  }

  void _incrementCounterWhite() async {
    setState(() {
      _counterWhite++;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counterW', _counterWhite);
    mapWriteWhite(_counterWhite);
  }

  void _counterClear() async {
    setState(() {
      _counterBlack = 0;
      _counterWhite = 0;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counterB', _counterBlack);
    await prefs.setInt('counterW', _counterWhite);
  }

  List<Icon> _buildIcons(int count, int ddtype) {
    List<Icon> iconObjet = List.generate(
      count,
      (int index) => Icon(
        Icons.fiber_manual_record,
        color: (ddtype < 2) ? Colors.black : Colors.white,
        size: 30,
      ),
    );
    return iconObjet;
  }

  // var _selection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton<WhyFarther>(
            icon: Icon(Icons.list),
            onSelected: (WhyFarther result) {
              //setState(() {
              //  _selection = result;
              // });
              switch (result) {
                case WhyFarther.one:
                  {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          _buildPopupChart(context),
                    );
                    break;
                  }
                case WhyFarther.two:
                  {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          _buildPopupDialog(context),
                    );
                    break;
                  }
                case WhyFarther.three:
                  {
                    _counterClear();
                    break;
                  }
                default:
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<WhyFarther>>[
              const PopupMenuItem<WhyFarther>(
                value: WhyFarther.one,
                child: ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: Text('十天记录'),
                ),
              ),
              const PopupMenuItem<WhyFarther>(
                value: WhyFarther.two,
                child: ListTile(
                  leading: const Icon(Icons.visibility),
                  title: Text('关于'),
                ),
              ),
              const PopupMenuItem<WhyFarther>(
                value: WhyFarther.three,
                child: ListTile(
                  leading: const Icon(Icons.delete),
                  title: Text('扫除'),
                ),
              ),
            ],
          )
        ],
      ),
      body: Center(
        child: Container(
          color: Colors.blue.shade100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  color: Colors.grey.shade400,
                  height: 350,
                  child: Row(children: <Widget>[
                    Flexible(
                      // width:200,
                      child: GridView.count(
                          crossAxisCount: 6,
                          padding: EdgeInsets.all(16.0),
                          childAspectRatio: 8.0 / 9.0,
                          children: _buildIcons(_counterBlack, 1) // Replace
                          ),
                    ),
                    Flexible(
                      // width:200,
                      child: GridView.count(
                          crossAxisCount: 6,
                          padding: EdgeInsets.all(16.0),
                          childAspectRatio: 8.0 / 9.0,
                          children: _buildIcons(_counterWhite, 2) // Replace
                          ),
                    ),
                  ])),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    '$_counterBlack',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Text(
                    '$_counterWhite',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      iconSize: 100,
                      icon: Icon(
                        Icons.fiber_manual_record,
                        color: Colors.black,
                      ),
                      onPressed: _incrementCounterBlack),
                  IconButton(
                      iconSize: 100,
                      icon: Icon(
                        Icons.fiber_manual_record,
                        color: Colors.white,
                      ),
                      onPressed: _incrementCounterWhite),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Text('意念之石', style: Theme.of(context).textTheme.headline2),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                '《大藏经》《贤愚经》卷第十三，（六七）<优波毱提品>第六十讲到一个故事，说阿难的弟子耶贳，为一位居士的小儿子优波毱提说法，教使系念。以白黑石子，用当筹算。善念下白，恶念下黑。优波毱提奉受其教，善恶之念，辄投石子。初黑偏多，白者甚少。渐渐修习，白黑正等。系念不止，更无黑石，纯有白者。善念已盛，逮得初果。（4，442b）',
                style: Theme.of(context).textTheme.bodyText1),
          ),
          TextButton(
            onPressed: () {
              _counterRead();
              mapRead();
              Navigator.of(context).pushNamed('/home');
            },
            child: Text("开始", style: Theme.of(context).textTheme.headline3),
          ),
        ],
      )),
    );
  }
}

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: SignUpForm(),
          ),
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _firstNameTextController = TextEditingController();
  final _lastNameTextController = TextEditingController();
  final _usernameTextController = TextEditingController();

  double _formProgress = 0;
  void _updateFormProgress() {
    var progress = 0.0;
    final controllers = [
      _firstNameTextController,
      _lastNameTextController,
      _usernameTextController
    ];

    for (final controller in controllers) {
      if (controller.value.text.isNotEmpty) {
        progress += 1 / controllers.length;
      }
    }

    setState(() {
      _formProgress = progress;
    });
  }

  void _showWelcomeScreen() {
    Navigator.of(context).pushNamed('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      onChanged: _updateFormProgress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedProgressIndicator(value: _formProgress),
          Text('Sign up', style: Theme.of(context).textTheme.headline4),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _firstNameTextController,
              decoration: InputDecoration(hintText: 'First name'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _lastNameTextController,
              decoration: InputDecoration(hintText: 'Last name'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _usernameTextController,
              decoration: InputDecoration(hintText: 'Username'),
            ),
          ),
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.resolveWith(
                  (Set<MaterialState> states) {
                return states.contains(MaterialState.disabled)
                    ? null
                    : Colors.white;
              }),
              backgroundColor: MaterialStateProperty.resolveWith(
                  (Set<MaterialState> states) {
                return states.contains(MaterialState.disabled)
                    ? null
                    : Colors.blue;
              }),
            ),
            onPressed: _formProgress == 1 ? _showWelcomeScreen : null,
            child: Text('Sign up'),
          ),
        ],
      ),
    );
  }
}

class AnimatedProgressIndicator extends StatefulWidget {
  final double value;

  AnimatedProgressIndicator({
    required this.value,
  });

  @override
  State<StatefulWidget> createState() {
    return _AnimatedProgressIndicatorState();
  }
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _curveAnimation;

  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: Duration(milliseconds: 1200), vsync: this);

    final colorTween = TweenSequence([
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.red, end: Colors.orange),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.orange, end: Colors.yellow),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.yellow, end: Colors.green),
        weight: 1,
      ),
    ]);

    _colorAnimation = _controller.drive(colorTween);
    _curveAnimation = _controller.drive(CurveTween(curve: Curves.easeIn));
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.animateTo(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => LinearProgressIndicator(
        value: _curveAnimation.value,
        valueColor: _colorAnimation,
        backgroundColor: _colorAnimation.value?.withOpacity(0.4),
      ),
    );
  }
}

Widget _buildPopupDialog(BuildContext context) {
  return new AlertDialog(
    title: const Text('About this app:'),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Developped by zlance@163.com"),
        Text("Visit us: https://canfo.cf "),
      ],
    ),
    actions: <Widget>[
      new TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        //textColor: Theme.of(context).primaryColor,
        child: const Text('Close'),
      ),
    ],
  );
}

Widget _buildPopupChart(BuildContext context) {
  return new Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(10),
      child: Stack(
        //overflow: Overflow.visible,
        alignment: Alignment.center,
        children: <Widget>[
          Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.lightBlue[200]),
              padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: charts.LineChart(
                    _createList(),
                    animate: false,
                    defaultRenderer:
                        new charts.LineRendererConfig(includePoints: true),
                  ))
              //child: SimpleLineChart.withSampleData()
              ),
        ],
      ));
}

class DailyDots {
  final int days;
  final int dots;
  toString() {
    return "days: $days , dots:  $dots";
  }

  DailyDots(this.days, this.dots);
}

List<charts.Series<DailyDots, int>> _createList() {
  //print(dataDots);
  return [
    new charts.Series<DailyDots, int>(
      id: 'Black dots',
      colorFn: (_, __) => charts.MaterialPalette.black,
      domainFn: (DailyDots dots, _) => dots.days,
      measureFn: (DailyDots dots, _) => dots.dots,
      data: dataDotsB,
    ),
    new charts.Series<DailyDots, int>(
      id: 'white dots',
      colorFn: (_, __) => charts.MaterialPalette.white,
      domainFn: (DailyDots dots, _) => dots.days,
      measureFn: (DailyDots dots, _) => dots.dots,
      data: dataDotsW,
    ),
  ];
}
