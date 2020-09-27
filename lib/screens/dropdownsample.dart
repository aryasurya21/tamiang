import 'package:flutter/material.dart';

class Item {
  Item(this.name);
  String name;
}

class DDL extends StatefulWidget {
  @override
  _DDLState createState() => _DDLState();
}

class _DDLState extends State<DDL> {
  List<Item> selectedUser = [null];
  List<Item> users;

  int ddlcount = 1;

  @override
  void initState() {
    super.initState();
    users = <Item>[
      Item('Aldo Cibai'),
      Item('Aldo Cibai 2'),
      Item('Aldo Cibai 3'),
      Item('Aldo Cibai 4'),
    ];
  }

  Widget _dropdownbutton(List<Item> userlist, int index) {
    return Container(
      padding: EdgeInsets.all(1),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.all(Radius.circular(15.0) //
            ),
      ),
      child: DropdownButton<Item>(
        underline: SizedBox(),
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down),
        hint: Text("Pilih 1"),
        value: selectedUser[index],
        onChanged: (Item value) {
          print(value.toString());
          print(index);
          setState(() {
            selectedUser[index] = value;
          });
        },
        items: userlist.map((Item user) {
          return DropdownMenuItem<Item>(
            value: user,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                Text(
                  user.name,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text(
            'Sample',
          ),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: screen.width - 10,
                  child: Column(
                    children: <Widget>[
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: ddlcount,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _dropdownbutton(users, index),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            child: Text("ADD DDL"),
                            onPressed: () {
                              selectedUser.add(null);
                              ddlcount++;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DDL(),
    );
  }
}
