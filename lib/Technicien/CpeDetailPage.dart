import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/Admin/AdminNavigation_drawer_widget.dart';
import 'package:frontend/Admin/Admincpelist.dart';
import 'package:frontend/Technicien/StatusWidget.dart';
import 'package:frontend/Technicien/navigation_drawer_widget.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CpeDetail extends StatefulWidget {
  final int id;

  const CpeDetail({
    required this.id,
  });
  @override
  State<CpeDetail> createState() => _CpeDetailState();
}

final _StatusKey = GlobalKey<FormState>();

class _CpeDetailState extends State<CpeDetail> {
  late Future<Cpe> cpe_;
  late Cpe cpe;
  //String email = '', name = '';

  bool admin = false;

  //Cpe cpe_ = new Cpe("",);

  String status = "";
  int status_ = -1;
  late StreamSubscription _sub;

  void dispose() {
    print('Dispose used');
    super.dispose();
  }

  @override
  void initState() {
    cpe_ = _getCpe();
  }

  /*final Stream _myStream =
        Stream.periodic(Duration(seconds: 5)).asyncMap((i) => _getCpe());
    _sub = _myStream.listen((event) {
      setState(() {
        print("beloooooooooooooow");
        this.setState(() {
          cpe_ = event;
        });
      });
    });
    // List<Cpe> cpes = [];
  }*/

  _Reboot() async {
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context, rootNavigator: true).pop('dialog');
    }); //var host = "efbf-102-25-171-90.eu.ngrok.io"; //10.0.2.2:8000
    var cpeRebootEndPoint = "/api/cpe/" + widget.id.toString() + "/reboot";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var host = prefs.getString('host').toString();

    var response = await http.put(
      Uri.https(host,
          cpeRebootEndPoint), //host + cpe_list_end_point,queryParameters=queryParameters),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
                title: Text('Succes'), content: Text('Cpe Has been rebooted'));
          });
      Future.delayed(Duration(seconds: 3), () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      });
    }
  }

  Future<Cpe> _getCpe() async {
    //late Cpe cpe;
    await Future.delayed(const Duration(seconds: 5), () {});
    //var host = "efbf-102-25-171-90.eu.ngrok.io"; //10.0.2.2:8000
    var cpeDetailEndPoint = "/api/cpe/" + widget.id.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var host = prefs.getString('host').toString();

    admin = Jwt.parseJwt(token!)['is_admin'];

    var response = await http.get(
      Uri.https(host,
          cpeDetailEndPoint), //host + cpe_list_end_point,queryParameters=queryParameters),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 401) {
      //refresh token and call getUser again
      var refreshToken = prefs.getString('refreshToken');
      var host = "http://127.0.0.1:8000"; //10.0.2.2:8000
      var refreshTokenPoint = "api/token/refresh/";
      var response = await http.get(
        Uri.parse(host + refreshTokenPoint),
        // Send authorization headers to the backend.
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $refreshToken',
        },
      );
    } else if (response.statusCode == 200) {
      var cpeDetail = jsonDecode(response.body);
      //print('cpe_detail below !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      //print(cpeDetail);

      Client client = Client('', '', '', '', '');
      if (cpeDetail["client"]['username'] != null) {
        //print("Fill the client !!!!!!!!!!!!!!!!!!!!!!!!!");
        client = Client(
            cpeDetail["client"]['username'],
            cpeDetail["client"]['email'],
            cpeDetail["client"]['tel'],
            cpeDetail["client"]['city'],
            cpeDetail["client"]['address']);
      }

      cpe = Cpe(
          cpeDetail["temperature"],
          cpeDetail["cpu_usage"],
          cpeDetail["ram_usage"],
          cpeDetail["download_debit"],
          cpeDetail["upload_debit"],
          cpeDetail["status"],
          cpeDetail["id"],
          cpeDetail["token"],
          client);
    }
    setState(() {
      status_ = cpe.status == true ? 1 : 0;
      // status = cpe.status.toString();
      if (cpe.status == false)
        status = "OFF";
      else {
        status = "ON";
      }

      cpe_ = _getCpe();
      //sleep(const Duration(seconds: 10));
    });

    return cpe;
  }

  /*setUpTimedFetch() async {
    await Timer.periodic(Duration(milliseconds: 1000), (timer) {
      setState(() {
        cpe_ = _getCpe();
      });
    });
  }*/

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
        drawer:
            admin ? AdminNavigationDrawerWidget() : NavigationDrawerWidget(),
        appBar: AppBar(
          title: Text("Cpe Details [ status: " + status + "]"),
          actions: <Widget>[StatusWidget(status: status_)],
          centerTitle: true,
          backgroundColor: Colors.orange,
        ),
        body: ListView(children: [
          FutureBuilder<Cpe>(
              future: cpe_,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return Container(
                      child: const Center(child: Text("Loading...")));
                } else {
                  return Column(children: [
                    Container(
                      child: Card(
                        margin: const EdgeInsets.all(10),
                        elevation: 10,
                        shape: const RoundedRectangleBorder(
                            side: BorderSide(color: Colors.orange, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        shadowColor: Colors.orange,
                        child: Column(children: [
                          TextFormField(
                              readOnly: true,
                              initialValue:
                                  " Name : " + snapshot.data.client.username),
                          TextFormField(
                              readOnly: true,
                              initialValue:
                                  " email : " + snapshot.data.client.email),
                          TextFormField(
                              readOnly: true,
                              initialValue:
                                  " Number : " + snapshot.data.client.tel),
                          TextFormField(
                              readOnly: true,
                              initialValue:
                                  " city : " + snapshot.data.client.city),
                          TextFormField(
                              readOnly: true,
                              initialValue:
                                  " Address : " + snapshot.data.client.address),
                        ]),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    admin
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.orange),
                                ),
                                child: TextFormField(
                                    maxLines: 2,
                                    keyboardType: TextInputType.multiline,
                                    readOnly: true,
                                    initialValue:
                                        " Cpe Token : " + snapshot.data.token),
                              ),
                              const SizedBox(height: 1),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                  bottom: BorderSide(
                                      // width: 16.0,
                                      color: Colors.orange),
                                )),
                                child: TextFormField(
                                    maxLines: 1,
                                    keyboardType: TextInputType.multiline,
                                    readOnly: true,
                                    initialValue:
                                        " Cpe Id : " + widget.id.toString()),
                              ),
                            ],
                          )
                        : Container(),
                    const SizedBox(
                      height: 20,
                    ),
                    SfRadialGauge(
                      enableLoadingAnimation: true,
                      animationDuration: 3500,
                      title: GaugeTitle(text: 'TEMPERATURE'),
                      axes: <RadialAxis>[
                        RadialAxis(
                            annotations: <GaugeAnnotation>[
                              GaugeAnnotation(
                                  angle: 90,
                                  positionFactor: 0.5,
                                  widget: Text(
                                    (snapshot.data!.temperature.toString() +
                                        " °C"),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ))
                            ],
                            axisLineStyle: AxisLineStyle(thickness: 20),
                            showTicks: false,
                            ranges: <GaugeRange>[
                              GaugeRange(
                                  startValue: 0,
                                  endValue: 30,
                                  color: Colors.green,
                                  startWidth: 20,
                                  endWidth: 20),
                              GaugeRange(
                                  startValue: 30,
                                  endValue: 60,
                                  color: Colors.orange,
                                  startWidth: 20,
                                  endWidth: 20),
                              GaugeRange(
                                  startValue: 60,
                                  endValue: 100,
                                  color: Colors.red,
                                  startWidth: 20,
                                  endWidth: 20)
                            ],
                            pointers: <GaugePointer>[
                              NeedlePointer(
                                  value: snapshot.data!.temperature,
                                  enableAnimation: true,
                                  needleStartWidth: 0,
                                  needleEndWidth: 5,
                                  needleColor: Color(0xFFDADADA),
                                  knobStyle: KnobStyle(
                                      color: Colors.white,
                                      borderColor: Color(0xFFDADADA),
                                      knobRadius: 0.06,
                                      borderWidth: 0.04),
                                  tailStyle: TailStyle(
                                      color: Color(0xFFDADADA),
                                      width: 5,
                                      length: 0.15)),
                              RangePointer(
                                value: snapshot.data!.temperature,
                                width: 20,
                                enableAnimation: true,
                                color: Colors.transparent,
                              )
                            ])
                      ],
                    ),
                    SfRadialGauge(
                      enableLoadingAnimation: true,
                      animationDuration: 3500,
                      title: GaugeTitle(text: 'CPU USAGE'),
                      axes: <RadialAxis>[
                        RadialAxis(
                            annotations: <GaugeAnnotation>[
                              GaugeAnnotation(
                                  angle: 180 / 2,
                                  positionFactor: 0,
                                  widget: Text(
                                    (snapshot.data!.cpu_usage.toString() +
                                        " %"),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ))
                            ],
                            axisLineStyle: AxisLineStyle(thickness: 20),
                            showTicks: true,
                            pointers: <GaugePointer>[
                              RangePointer(
                                  value: snapshot.data!.cpu_usage,
                                  width: 0.13,
                                  color: Colors.indigo,
                                  sizeUnit: GaugeSizeUnit.factor),
                            ])
                      ],
                    ),
                    SfRadialGauge(
                      enableLoadingAnimation: true,
                      animationDuration: 3500,
                      title: GaugeTitle(text: 'RAM USAGE'),
                      axes: <RadialAxis>[
                        RadialAxis(
                            annotations: <GaugeAnnotation>[
                              GaugeAnnotation(
                                  angle: 180 / 2,
                                  positionFactor: 0,
                                  widget: Text(
                                    (snapshot.data!.ram_usage.toString() +
                                        " %"),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ))
                            ],
                            axisLineStyle: AxisLineStyle(thickness: 20),
                            showTicks: true,
                            pointers: <GaugePointer>[
                              RangePointer(
                                  value: snapshot.data!.ram_usage,
                                  width: 0.13,
                                  color: Colors.indigo,
                                  sizeUnit: GaugeSizeUnit.factor),
                            ])
                      ],
                    ),
                    SfRadialGauge(
                        enableLoadingAnimation: true,
                        animationDuration: 3500,
                        title: GaugeTitle(text: 'DOWNLOAD DEBIT'),
                        axes: <RadialAxis>[
                          RadialAxis(
                              minimum: 0,
                              maximum: 100,
                              showTicks: true,
                              annotations: <GaugeAnnotation>[
                                GaugeAnnotation(
                                    angle: 180 / 2,
                                    positionFactor: 0,
                                    widget: Text(
                                      (snapshot.data!.download_debit
                                              .toString() +
                                          " Mb/s"),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ))
                              ],
                              pointers: <GaugePointer>[
                                RangePointer(
                                    value: snapshot.data!.download_debit,
                                    width: 0.13,
                                    color: Color(0xFFFF7676),
                                    sizeUnit: GaugeSizeUnit.factor),
                              ],
                              axisLineStyle: AxisLineStyle(
                                thickness: 0.1,
                                thicknessUnit: GaugeSizeUnit.factor,
                                gradient: const SweepGradient(colors: <Color>[
                                  Color(0xFFFF7676),
                                  Color(0xFFF54EA2)
                                ], stops: <double>[
                                  0.25,
                                  0.75
                                ]),
                              )),
                        ]),
                    SfRadialGauge(
                        enableLoadingAnimation: true,
                        animationDuration: 3500,
                        title: GaugeTitle(text: 'UPLOAD DEBIT'),
                        axes: <RadialAxis>[
                          RadialAxis(
                              minimum: 0,
                              maximum: 100,
                              showTicks: true,
                              annotations: <GaugeAnnotation>[
                                GaugeAnnotation(
                                    angle: 180 / 2,
                                    positionFactor: 0,
                                    widget: Text(
                                      (snapshot.data!.upload_debit.toString() +
                                          " Mb/s"),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ))
                              ],
                              pointers: <GaugePointer>[
                                RangePointer(
                                    value: snapshot.data!.upload_debit,
                                    width: 0.13,
                                    color: Color(0xFFFF7676),
                                    sizeUnit: GaugeSizeUnit.factor),
                              ],
                              axisLineStyle: AxisLineStyle(
                                thickness: 0.1,
                                thicknessUnit: GaugeSizeUnit.factor,
                                gradient: const SweepGradient(colors: <Color>[
                                  Color(0xFFFF7676),
                                  Color(0xFFF54EA2)
                                ], stops: <double>[
                                  0.25,
                                  0.75
                                ]),
                              )),
                        ]),
                    TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          "Reboot",
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => new AlertDialog(
                              shape: RoundedRectangleBorder(
                                  side:
                                      BorderSide(color: Colors.red, width: 2)),
                              title: Row(children: [
                                Icon(Icons.warning, color: Colors.red),
                                SizedBox(width: 5, height: 5),
                                Text(
                                  "Are you sure to Reboot this Cpe?",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ]),
                              content: Text(
                                "It will Reboot this Cpe .",
                                style: TextStyle(fontSize: 15),
                              ),
                              actions: [
                                ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.orange)),
                                  child: Text("Reboot"),
                                  onPressed: _Reboot,
                                ),
                                ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.orange)),
                                    child: Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog'); // Return false
                                    }),
                              ],
                            ),
                          );
                        } //_Reboot,
                        /*color: Colors.red,
                      textColor: Colors.yellow,
                      padding: EdgeInsets.all(8.0),
                      splashColor: Colors.grey,*/
                        ),
                    const SizedBox(
                      height: 20,
                    ),
                  ]);
                }
              })
        ]));
  }

  /*void dispose() {
    print("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOUT");
    cpe_;
    super.dispose();*/
}

class Cpe {
  final Client? client;

  final double? temperature;
  final double? cpu_usage;
  final double? ram_usage;
  final double? download_debit;
  final double? upload_debit;
  final bool? status;
  final int? id;
  final String? token;

  Cpe(this.temperature, this.cpu_usage, this.ram_usage, this.download_debit,
      this.upload_debit, this.status, this.id, this.token, this.client);
}

class Client {
  final String? username;
  final String? email;
  final String? tel;
  final String? city;
  final String? address;

  Client(this.username, this.email, this.tel, this.city, this.address);
}
