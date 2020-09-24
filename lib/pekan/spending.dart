import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../model/api.dart';
import '../model/pekan.dart';

class SpendingPage extends StatefulWidget {
  @override
  _SpendingPageState createState() => _SpendingPageState();
}

class _SpendingPageState extends State<SpendingPage> {
  final oCcy = new NumberFormat("#,##0", "en_US");
  final GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();
  DateTime selectedDate = DateTime.now();

  final listpekan = List<PekanModel>();

  var loading = false;
  double amount = 0;

  TextEditingController descController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController monthController = TextEditingController();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showMonthPicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        monthController.text = DateFormat('MM/yyyy').format(picked);
        selectedDate = picked;
        _readData();
      });
  }

  Future<void> _readData() async {
    setState(() {
      loading = true;
      amount = 0;
    });
    listpekan.clear();
    var response =
        await CallApi().getData('pekan?type=S&period=${monthController.text}');
    print("Spending : ${response.body}");
    final data = jsonDecode(response.body);
    double amountPekan = 0;
    if (data['data'] != null) {
      data['data'].forEach((api) {
        final ab = PekanModel(
          api['id'],
          api['user_id'],
          api['amount'] + .0,
          api['type'],
          api['description'],
          api['created_at'],
        );
        listpekan.add(ab);
        amountPekan += api['amount'];
      });
    }
    setState(() {
      loading = false;
      amount = amountPekan;
    });
  }

  Future<void> _saveData(BuildContext context) async {
    var data = {
      'type': "S",
      'description': descController.text,
      'amount': amountController.text
    };

    var response = await CallApi().postData(data, 'pekan');
    var body = jsonDecode(response.body);
    if (body['data'] != null) {
      print('created : $body');
      Navigator.pop(context);
      _readData();
    } else {
      print('SaveData : ${response.body}');
    }
  }

  Future<void> _updateData(BuildContext context, id) async {
    var data = {
      'type': "S",
      'description': descController.text,
      'amount': amountController.text
    };

    var response = await CallApi().putData(data, 'pekan/$id');
    var body = jsonDecode(response.body);
    if (body['data'] != null) {
      print('updated : $body');
      Navigator.pop(context);
      _readData();
    } else {
      print('SaveData : ${response.body}');
    }
  }

  Future<void> _deleteData(BuildContext context, id) async {
    print(id);
    var response = await CallApi().deleteData('pekan/$id');
    final data = jsonDecode(response.body);
    if (data['message'] == 'Pekan Deleted') {
      setState(() {
        Navigator.pop(context);
        _readData();
      });
    } else {
      print(data);
    }
  }

  dialogCreate(BuildContext context) {
    descController.text = "";
    amountController.text = "";
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return ListView(
                padding: EdgeInsets.all(16.0),
                shrinkWrap: true,
                children: <Widget>[
                  TextField(
                    controller: descController,
                    autofocus: false,
                    decoration: new InputDecoration(
                      contentPadding: EdgeInsets.all(13.0),
                      labelText: "Catatan",
                      labelStyle: TextStyle(fontSize: 13.0),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(15.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    controller: amountController,
                    autofocus: false,
                    keyboardType: TextInputType.number,
                    decoration: new InputDecoration(
                      contentPadding: EdgeInsets.all(13.0),
                      labelText: "Harga",
                      labelStyle: TextStyle(fontSize: 13.0),
                      prefixText: "Rp. ",
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(15.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  RaisedButton(
                    onPressed: () {
                      _saveData(context);
                    },
                    color: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    child: Container(
                      height: 45.0,
                      child: Center(
                        child: Text(
                          'Simpan',
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  dialogUpdate(BuildContext context, PekanModel x) {
    descController.text = x.description;
    amountController.text = x.amount.round().toString();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return ListView(
                padding: EdgeInsets.all(16.0),
                shrinkWrap: true,
                children: <Widget>[
                  TextField(
                    controller: descController,
                    autofocus: false,
                    decoration: new InputDecoration(
                      contentPadding: EdgeInsets.all(13.0),
                      labelText: "Catatan",
                      labelStyle: TextStyle(fontSize: 13.0),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(15.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    controller: amountController,
                    autofocus: false,
                    keyboardType: TextInputType.number,
                    decoration: new InputDecoration(
                      contentPadding: EdgeInsets.all(13.0),
                      labelText: "Harga",
                      labelStyle: TextStyle(fontSize: 13.0),
                      prefixText: "Rp. ",
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(15.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      ButtonTheme(
                        minWidth: 30.0,
                        child: RaisedButton(
                          onPressed: () {
                            _deleteData(context, x.id);
                          },
                          color: Colors.red.shade600,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          child: Container(
                            height: 40.0,
                            child: Center(
                                child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            )),
                          ),
                        ),
                      ),
                      SizedBox(width: 5.0),
                      RaisedButton(
                        onPressed: () {
                          _updateData(context, x.id);
                        },
                        color: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        child: Container(
                          height: 40.0,
                          child: Center(
                            child: Text(
                              'Ubah',
                              style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    monthController.text = DateFormat('MM/yyyy').format(selectedDate);
    _readData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pengeluaran",
          style: TextStyle(fontSize: 16),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('Rp. ' + oCcy.format(amount).toString(),
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
          ),
        ],
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: InkWell(
              onTap: () {
                _selectDate(context);
              },
              child: IgnorePointer(
                child: TextFormField(
                  controller: monthController,
                  decoration: new InputDecoration(
                    contentPadding: EdgeInsets.all(13.0),
                    labelText: "Bulan/Tahun",
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.calendar_today),
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              key: _refresh,
              onRefresh: _readData,
              child: Center(
                child: loading
                    ? Center(child: CircularProgressIndicator())
                    : listpekan.length == 0
                        ? Center(
                            child: Text(
                              'Data tidak ada',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemExtent: 55,
                            itemCount: listpekan.length,
                            itemBuilder: (context, i) {
                              final x = listpekan[i];
                              return ListTile(
                                title: Text(
                                  x.description,
                                  style: TextStyle(fontSize: 15),
                                ),
                                subtitle: Text(x.created,
                                    style: TextStyle(fontSize: 12)),
                                trailing: Container(
                                  child: Text(
                                    'Rp. ' + oCcy.format(x.amount).toString(),
                                  ),
                                ),
                                onTap: () {
                                  dialogUpdate(context, x);
                                },
                              );
                            },
                          ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 53.0,
        height: 53.0,
        child: FloatingActionButton(
          onPressed: () {
            dialogCreate(context);
          },
          backgroundColor: Colors.blueGrey,
          tooltip: 'Add',
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
