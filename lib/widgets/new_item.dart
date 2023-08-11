import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery/data/categories.dart';
import 'package:grocery/models/category.dart';
import 'package:grocery/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget{
  const NewItem({super.key});
  @override
  State<NewItem> createState() {
    // TODO: implement createState
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem>{
  final _formKey=GlobalKey<FormState>();
  var _enteredValue='';
  var _enteredQuantity=1;
  var _selectedCategory=categories[Categories.vegetables]!;
  var _isSending=false;
  void _saveItem() async
  {
    if(_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending=true;
      });
      final url=Uri.https('grocery-1055f-default-rtdb.firebaseio.com','shopping-list.json');
       final response=await http.post(url,headers: {
        'Content-type': 'application/json',
      },body: json.encode({
        'name': _enteredValue,
        'quantity': _enteredQuantity,
        'category': _selectedCategory.title,
          },
        ),
      );
       final Map<String,dynamic> resData=json.decode(response.body);
      if(!context.mounted)
        return;
      Navigator.of(context).pop(GroceryItem(
          id: resData['name'],
          name: _enteredValue,
          quantity: _enteredQuantity,
          category: _selectedCategory,
      ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value){
                  if(value==null || value.isEmpty)
                  return 'Thik se enter kar chutiye';
                  return null;
                },
                onSaved: (value){

                  _enteredValue=value!;
                },
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value){
                        if(value==null || value.isEmpty ||
                        int.tryParse(value)==null ||
                        int.tryParse(value)!<=0)
                          return 'Must be valid positive number';
                        return null;
                      },
                      onSaved: (value){
                        _enteredQuantity=int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8,),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                        items: [
                          for(final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(width: 8,),
                                    Text(category.value.title),
                                  ],
                                ))
                        ],
                        onChanged: (value){
                        setState(() {
                          _selectedCategory=value!;
                        });
                        }),
                  )
                ],
              ),
              const SizedBox(height: 12,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed:_isSending? null: () {
                        _formKey.currentState!.reset();
                      },
                      child: Text('Reset'),
                  ),
                  ElevatedButton(
                      onPressed:_isSending?null: _saveItem,
                      child:_isSending? SizedBox(width: 16,height: 16,child: CircularProgressIndicator(),): Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}