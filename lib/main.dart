import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  runApp(MyApp());
}

class CustomTheme {
  static ThemeData lightTheme = ThemeData.light();
  static ThemeData darkTheme = ThemeData.dark();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeData _currentTheme = CustomTheme.lightTheme;

  void toggleTheme() {
    setState(() {
      if (_currentTheme == CustomTheme.lightTheme) {
        _currentTheme = CustomTheme.darkTheme;
      } else {
        _currentTheme = CustomTheme.lightTheme;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _currentTheme,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Invoice'),
          actions: [
            Switch(
              value: _currentTheme == CustomTheme.darkTheme,
              onChanged: (value) {
                toggleTheme();
              },
            ),
          ],
        ),
        body: MyTable(),
      ),
    );
  }
}

class MyTable extends StatefulWidget {
  @override
  _MyTableState createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> {
  ScreenshotController screenshotController = ScreenshotController();
  int rowCount = 10;
  List<double> amounts = List.generate(10, (index) => 0.0);

  List<TextEditingController> weightControllers =
      List.generate(10, (index) => TextEditingController());
  List<TextEditingController> rateControllers =
      List.generate(10, (index) => TextEditingController());

  GlobalKey _repaintBoundaryKey = GlobalKey();

  void clearEntries() {
    setState(() {
      for (int i = 0; i < rowCount; i++) {
        weightControllers[i].clear();
        rateControllers[i].clear();
        amounts[i] = 0.0;
      }
      updateTotal();
    });
  }

  void updateTotal() {
    double total = 0.0;
    double wt = 0.0;
    for (int i = 0; i < rowCount; i++) {
      if (weightControllers[i].text.isNotEmpty &&
          rateControllers[i].text.isNotEmpty) {
        amounts[i] =
            double.parse(weightControllers[i].text) * double.parse(rateControllers[i].text);
        total += amounts[i];
        if (i < 5) wt += double.parse(weightControllers[i].text);
      } else {
        amounts[i] = 0.0;
      }
    }
    weightControllers[5].text = wt.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    updateTotal();
    Wakelock.enable();
  }

  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: RepaintBoundary(
        key: _repaintBoundaryKey,
        child: Screenshot(
          controller: screenshotController,
          child: Container(
            color: theme.brightness == Brightness.light
                ? Colors.white // Light mode background color
                : const Color.fromARGB(255, 54, 54, 54), // Dark mode background color
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Table(
                      border: TableBorder.all(),
                      children: [
                        TableRow(
                          children: [
                            TableCell(
                              child: Center(
                                child: Text(
                                  'Weight',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: Text(
                                  'Rate',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: Text(
                                  'Amount',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        for (int i = 0; i < rowCount; i++)
                          TableRow(
                            children: [
                              TableCell(
                                child: Container(
                                  color: i == 5
                                      ? (theme.brightness == Brightness.light
                                          ? Color.fromARGB(255, 203, 203, 203) // Light mode color
                                          : Color.fromARGB(255, 54, 54, 54)) // Dark mode color
                                      : null,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: weightControllers[i],
                                    decoration: InputDecoration(
                                      hintText: '',
                                      contentPadding: EdgeInsets.all(10),
                                      alignLabelWithHint: true,
                                      counterText: '',
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        updateTotal();
                                      });
                                    },
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              TableCell(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: rateControllers[i],
                                  decoration: InputDecoration(
                                    hintText: '',
                                    contentPadding: EdgeInsets.all(10),
                                    alignLabelWithHint: true,
                                    counterText: '',
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      updateTotal();
                                    });
                                  },
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Center(
                                  child: Text(
                                    amounts[i].toStringAsFixed(2),
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: clearEntries,
                        child: Text('Clear'),
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Total Amount: ${(amounts[0] + amounts[1] + amounts[2] + amounts[3] + amounts[4] + amounts[5] + amounts[6] + amounts[7] + amounts[8] + amounts[9]).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          takeScreenshot();
                        },
                        child: Text('Take Screenshot'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void takeScreenshot() async {
    final uint8List = await screenshotController.capture();

    if (uint8List != null) {
      final buffer = uint8List.buffer.asUint8List();

      final result = await ImageGallerySaver.saveImage(buffer);
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Screenshot saved successfully'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save screenshot'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to capture the screenshot'),
      ));
    }
  }
}
