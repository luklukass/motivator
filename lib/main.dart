import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motivator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black, // Set app bar background color to black
        ),
        scaffoldBackgroundColor: Colors.black26, // Set scaffold background color to light black
      ),
      home: const ScrolledLayout(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate
      ],
      supportedLocales: [
        Locale('en'),
        Locale('cs')
      ],
    );
  }
}

class ScrolledLayout extends StatefulWidget {
  const ScrolledLayout({Key? key}) : super(key: key);

  @override
  _ScrolledLayoutState createState() => _ScrolledLayoutState();
}

class _ScrolledLayoutState extends State<ScrolledLayout> {
  DateTime? arrivalDate;
  DateTime? departureDate;
  int remainingDays = 0;
  int passedDays = 0;
  int totalEarnedMoney = 0;
  TextEditingController earnedMoneyController = TextEditingController();

  void saveEarnedMoney(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('earnedMoney', value);
  }

  @override
  void initState() {
    super.initState();
    earnedMoneyController.addListener(computeEarnedMoney);

    // Retrieve saved dates from shared preferences
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.containsKey('arrivalDate')) {
        setState(() {
          arrivalDate = DateTime.parse(prefs.getString('arrivalDate')!);
          computePassedDays();
          computeRemainingDays();
          computeEarnedMoney();
        });
      }

      if (prefs.containsKey('departureDate')) {
        setState(() {
          departureDate = DateTime.parse(prefs.getString('departureDate')!);
          computePassedDays();
          computeRemainingDays();
          computeEarnedMoney();
        });
      }

      if (prefs.containsKey('earnedMoney')) {
        setState(() {
          totalEarnedMoney = prefs.getInt('earnedMoney') ?? 0;
        });
      }
      if (prefs.containsKey('earnedMoneyPerDay')) {
        setState(() {
          earnedMoneyController.text = prefs.getInt('earnedMoneyPerDay').toString();
        });
      }
    });
  }

  @override
  void dispose() {
    earnedMoneyController.removeListener(computeEarnedMoney);
    earnedMoneyController.dispose();
    super.dispose();
  }

  Future<void> _selectArrivalDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      locale: Locale('cs', 'CZ'), // Czech
      context: context,
      initialDate: arrivalDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(), // Apply dark theme to the date picker
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        arrivalDate = picked;
        computePassedDays();
        computeRemainingDays();
        computeEarnedMoney();
      });

      // Save arrival date to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('arrivalDate', arrivalDate.toString());
    }
  }

  Future<void> _selectDepartureDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      locale: Locale('cs', 'CZ'), // Czech
      context: context,
      initialDate: departureDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(), // Apply dark theme to the date picker
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        departureDate = picked;
        computePassedDays();
        computeRemainingDays();
        computeEarnedMoney();
      });

      // Save departure date to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('departureDate', departureDate.toString());
    }
  }

  void computeRemainingDays() {
    if (departureDate != null) {
      final difference = departureDate!.difference(DateTime.now());
      remainingDays = difference.inDays + 1;
    } else {
      remainingDays = 0;
    }
  }

  void computePassedDays() {
    if (arrivalDate != null) {
      final difference = arrivalDate!.difference(DateTime.now()).abs();
      passedDays = difference.inDays;
    } else {
      passedDays = 0;
    }
  }

  void computeEarnedMoney() {
    if (arrivalDate != null && earnedMoneyController.text.isNotEmpty) {
      int earnedMoneyPerDay = int.tryParse(earnedMoneyController.text) ?? 0;
      totalEarnedMoney = earnedMoneyPerDay * passedDays;
      saveEarnedMoney(totalEarnedMoney); // Save earned money value

      // Save the input value to shared preferences
      saveEarnedMoneyPerDay(earnedMoneyPerDay);
    } else {
      totalEarnedMoney = 0;
      saveEarnedMoney(0); // Save 0 when no value is available
    }
  }

  void saveEarnedMoneyPerDay(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('earnedMoneyPerDay', value);
  }

  void handleCheckButton() {
    setState(() {
      computeEarnedMoney();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motivator'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20), // Add a gap at the top
            GestureDetector(
              onTap: () {
                _selectArrivalDate(context);
              },
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10), // Set circular corners
                        child: Container(
                          height: 150,
                          color: Colors.blue,
                          child: Center(
                            child: arrivalDate == null
                                ? Text(
                              'Vyber datum příjezdu',
                              style: TextStyle(
                                fontSize: 25, // Set the font size to 20
                                fontWeight: FontWeight.bold, // Set the font weight to bold
                                color: Colors.black, // Set the text color to white
                              ),
                              textAlign: TextAlign.center,
                            )
                                : Text(
                              'Příjezd: \n${DateFormat('dd/MM/yyyy').format(arrivalDate!)}',
                              style: TextStyle(
                                fontSize: 20, // Set the font size to 20
                                fontWeight: FontWeight.bold, // Set the font weight to bold
                                color: Colors.black, // Set the text color to white
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _selectDepartureDate(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10), // Set circular corners
                          child: Container(
                            height: 150,
                            color: Colors.red,
                            child: Center(
                              child: departureDate == null
                                  ? Text(
                                'Vyber datum odjezdu',
                                style: TextStyle(
                                  fontSize: 25, // Set the font size to 20
                                  fontWeight: FontWeight.bold, // Set the font weight to bold
                                  color: Colors.black, // Set the text color to white
                                ),
                                textAlign: TextAlign.center,
                              )
                                  : Text(
                                'Odjezd: \n${DateFormat('dd/MM/yyyy').format(departureDate!)}',
                                style: TextStyle(
                                  fontSize: 20, // Set the font size to 20
                                  fontWeight: FontWeight.bold, // Set the font weight to bold
                                  color: Colors.black, // Set the text color to white
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // Add a gap between rows
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 150,
                        color: Colors.grey,
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Zbývající dny: \n',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '$remainingDays',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Set circular corners
                      child: Container(
                        height: 150,
                        color: Colors.grey,
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Uplynulé dny: \n',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '$passedDays',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Add a gap between rows
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 150,
                        color: Colors.grey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Částka za den',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextField(
                                controller: earnedMoneyController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: 'Zadej částku',
                                  hintStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black54,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey,
                                ),
                                onChanged: (value) {
                                  computeEarnedMoney();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: handleCheckButton,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10), // Set circular corners
                        child: Container(
                          height: 150,
                          color: Colors.lightGreen,
                          child: Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Vyděláno: \n',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '$totalEarnedMoney Kč',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}