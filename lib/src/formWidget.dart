import 'package:flutter/material.dart';
import 'package:simple_form_builder/global/constant.dart';
import 'package:simple_form_builder/src/widgets/customDropdownWidget.dart';
import 'package:simple_form_builder/src/widgets/descriptionWidget.dart';
import 'package:flutter/services.dart';
import '../global/checklistModel.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class FormBuilder extends StatefulWidget {
  final Map<String, dynamic> initialData;

  final InputDecoration? textfieldDecoration;
  final String onUpload;
  final String? title; 
  final TextStyle? titleStyle;
  final CrossAxisAlignment widgetCrossAxisAlignment;
  final String? description;
  final TextStyle? descriptionStyle;
  final bool showIndex;
  final String? multipleimage,
      dropdownImage,
      dateImage,
      textImage,
      checkboxImage,
      remarkImage,
      submitButtonText;
  final int index;
  final double? textFieldWidth;
  final bool showIcon;
  final Function onSubmit;
  final double? submitButtonWidth;
  final BoxDecoration? submitButtonDecoration;
  final TextStyle? submitTextDecoration;
  final TextStyle? titleTextDecoration;
  final TextStyle? descriptionTextDecoration;
  

  FormBuilder({
    required this.initialData,
    required this.index,
    required this.onUpload, //variable to add the uploaded file
    this.textfieldDecoration, //adds inputdecoration to textfields
    this.textFieldWidth, //to change the width of textField
    this.multipleimage, //adds  image for case 'multiple'
    this.dropdownImage, //adds  image for case 'dropdown'
    this.checkboxImage, //adds  image for case 'checkbox'
    this.dateImage, //adds  image for case 'date'
    this.textImage, //adds  image for case 'text'
    this.remarkImage, //adds image for remarks
    this.submitButtonText,
    this.showIcon = false, //to enable or disable question icon
    required this.onSubmit,
    this.showIndex = true,
    this.submitButtonDecoration,
    this.submitButtonWidth = 0.5,
    this.submitTextDecoration,
    this.title,
    this.description,
    this.descriptionStyle,
    this.titleStyle,
    this.widgetCrossAxisAlignment = CrossAxisAlignment.start,
    this.titleTextDecoration,
    this.descriptionTextDecoration,
  });

  @override
  _FormBuilderState createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  bool servicestatus = false;

  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
       String long = "", lat = "";
  late StreamSubscription<Position> positionStream;
  ChecklistModel? checklistModel;
  @override
  void initState() {
    checklistModel = ChecklistModel.fromJson(widget.initialData);
    super.initState();
  }
 checkGps() async {
      servicestatus = await Geolocator.isLocationServiceEnabled();
      if(servicestatus){
            permission = await Geolocator.checkPermission();
          
            if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied) {
                    print('Location permissions are denied');
                }else if(permission == LocationPermission.deniedForever){
                    print("'Location permissions are permanently denied");
                }else{
                   haspermission = true;
                }
            }else{
               haspermission = true;
            }

            if(haspermission){
                setState(() {
                  //refresh the UI
                });

                getLocation();
    List<Questions>? questions = checklistModel!.data![0].questions;
    for (Questions item in questions!) {
            if(item.title == 'longitude'){
        item.answer=long;
                   setState(() {
              //refresh UI on update
            });
      }
     if(item.title == 'latitude'){
        item.answer=lat;
                   setState(() {
              //refresh UI on update
            });

      }}
              
              

            }
      }else{
        print("GPS Service is not enabled, turn on GPS location");
      }

      setState(() {
         //refresh the UI
      });
  }
    getLocation() async {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457

      long = position.longitude.toString();
      lat = position.latitude.toString();

      setState(() {
         //refresh UI
      });

      LocationSettings locationSettings = LocationSettings(
            accuracy: LocationAccuracy.high, //accuracy of the location data
            distanceFilter: 100, //minimum distance (measured in meters) a 
                                 //device must move horizontally before an update event is generated;
      );

      StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
            locationSettings: locationSettings).listen((Position position) {
  //          print(position.longitude); //Output: 80.24599079
  //          print(position.latitude); //Output: 29.6593457

            long = position.longitude.toString();
            lat = position.latitude.toString();

            setState(() {
              //refresh UI on update
            });
      });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: widget.widgetCrossAxisAlignment,
          children: [
            widget.title != null
                ? Text(
                    widget.title!,
                    style: widget.titleStyle ?? TextStyle(),
                  )
                : SizedBox.shrink(),
                        Center(child: Column(children:[ElevatedButton(onPressed:() => checkGps() , child: const Text('Gps')),
                                         
                     Text("Longitude: $long", style:TextStyle(fontSize: 20)),
                     Text("Latitude: $lat", style: TextStyle(fontSize: 20))]
             
                  
            )),
            widget.description != null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.description!,
                      style: widget.descriptionStyle ?? TextStyle(),
                    ),
                  )
                : SizedBox.shrink(),
            ...checklistModel!.data![widget.index].questions!
                .map((e) => questionWidget(e, widget.showIcon))
                .toList(),
            SizedBox(
              height: 10,
            ),
            Center(
              child: InkWell(
                onTap: () {
                  widget.onSubmit(getCompleteData(widget.index));
                },
                child: Container(
                  height: 50,
                  width: screenWidth(
                    context: context,
                    mulBy: widget.submitButtonWidth ?? 0.5,
                  ),
                  decoration: widget.submitButtonDecoration ??
                      BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.blue,
                      ),
                  child: Center(
                    child: Text(
                      widget.submitButtonText ?? "Envoyer",
                      style: widget.submitTextDecoration ??
                          TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  getCompleteData(int index) {
    int f = 0;
    List<Questions>? questions = checklistModel!.data![index].questions;
    for (Questions item in questions!) {
            if(item.title == 'longitude'){
        item.answer=long;
      }
     if(item.title == 'latitude'){
        item.answer=lat;
      }
      
      if (item.answer == null && item.isMandatory == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${item.title} est obligatoire"),
          ),
        );
        f = 1;
        break;
      }

    }
    return f == 0 ? checklistModel : null;
  }

  Widget questionWidget(
    Questions e,
    remarks,
  ) {
    switch (e.type) {
      case "multiple":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.showIcon
                      ? iconContainer(widget.multipleimage)
                      : Container(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                      "${widget.showIndex ? "${checklistModel!.data![widget.index].questions!.indexOf(e) + 1}. " : ""}${e.title}",
                      style: widget.titleTextDecoration ?? TextStyle(),
                    ),
                  ),
                  descriptionWidget(
                      e, context, widget.descriptionTextDecoration),
                ],
              ),
            ),
            Column(
              children: e.fields!
                  .map(
                    (val) => RadioListTile(
                      value: val,
                      groupValue: e.answer,
                      title: Text(
                        val,
                        style: TextStyle(
                          color: e.answer != val ? Colors.grey : Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: screenWidth(
                            context: context,
                            mulBy: 0.04,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        e.answer = value;
                        setState(() {});
                      },
                    ),
                  )
                  .toList(),
            ),
            remarkWidget(e, remarks, widget.remarkImage),
          ],
        );

      case "dropdown":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.showIcon
                      ? iconContainer(widget.dropdownImage)
                      : Container(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                        "${widget.showIndex ? "${checklistModel!.data![widget.index].questions!.indexOf(e) + 1}. " : ""}${e.title}"),
                  ),
                  descriptionWidget(
                      e, context, widget.descriptionTextDecoration),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 24,
              ),
              child: Container(
                width: screenWidth(context: context, mulBy: 0.9),
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: e.answer != null ? Colors.blue : Colors.grey,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton(
                    underline: SizedBox(),
                    hint: e.answer == null
                        ? Text('Sélectionner une option')
                        : Text(
                            e.answer,
                            style: TextStyle(
                              color:
                                  e.answer != null ? Colors.blue : Colors.grey,
                            ),
                          ),
                    isExpanded: true,
                    iconSize: 30.0,
                    style: TextStyle(color: Colors.grey),
                    items: e.fields!.map(
                      (val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        e.answer = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            remarkWidget(e, remarks, widget.remarkImage),
          ],
        );

      case "checkbox":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.showIcon
                      ? iconContainer(widget.checkboxImage)
                      : Container(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                        "${widget.showIndex ? "${checklistModel!.data![widget.index].questions!.indexOf(e) + 1}. " : ""}${e.title}"),
                  ),
                  descriptionWidget(
                      e, context, widget.descriptionTextDecoration),
                ],
              ),
            ),
            Column(
              children: e.fields!
                  .map(
                    (val) => CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      title: Text(
                        val,
                        style: TextStyle(
                          color: e.answer[e.fields!.indexOf(val)] != true
                              ? Colors.grey
                              : Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: screenWidth(
                            context: context,
                            mulBy: 0.04,
                          ),
                        ),
                      ),
                      value: e.answer[e.fields!.indexOf(val)],
                      onChanged: (value) {
                        e.answer[e.fields!.indexOf(val)] = value;
                        setState(() {});
                      },
                    ),
                  )
                  .toList(),
            ),
            remarkWidget(e, remarks, widget.remarkImage),
          ],
        );

      case "datetime":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.showIcon
                      ? iconContainer(widget.dateImage)
                      : Container(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                        "${widget.showIndex ? "${checklistModel!.data![widget.index].questions!.indexOf(e) + 1}. " : ""}${e.title}"),
                  ),
                  descriptionWidget(
                      e, context, widget.descriptionTextDecoration),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                children: <Widget>[
                  Theme(
                    data: ThemeData(),
                    child: Builder(
                      builder: (context) => customDropdownWidget(
                        onChanged: (val) {
                          print(val);
                        },
                        onTap: () async {
                          DateTime tempDate = await selectDate(context);

                          if (e.answer == null) {
                            setState(() {
                              e.answer = tempDate;
                            });
                          } else {
                            setState(() {
                              e.answer = DateTime(
                                tempDate.year,
                                tempDate.month,
                                tempDate.day,
                                e.answer.hour,
                                e.answer.minute,
                              );
                            });
                          }
                        },
                        title: e.answer == null
                            ? "DD-MM-YYYY"
                            : dateFormater.format(e.answer),
                        // date != null ? dateFormater.format(date) : "DD-MM-YYYY",
                        context: context,

                        showImage: false,
                        isRequired: false,
                        width: screenWidth(context: context, mulBy: 0.4),
                      ),
                    ),
                  ),
                  customDropdownWidget(
                    onChanged: (val) {},
                    onTap: () async {
                      TimeOfDay tempTime = await selectTime(context);

                      if (e.answer == null) {
                        setState(() {
                          e.answer = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            tempTime.hour,
                            tempTime.minute,
                          );
                        });
                      } else {
                        setState(() {
                          e.answer = DateTime(
                            e.answer.year,
                            e.answer.month,
                            e.answer.day,
                            tempTime.hour,
                            tempTime.minute,
                          );
                        });
                      }

                      // reminderController.updateIschanged(true);
                    },
                    title: e.answer != null
                        ? formatTimeOfDay(TimeOfDay.fromDateTime(e.answer))
                        : "Hr:Mins",
                    context: context,
                    showImage: false,
                    isRequired: false,
                    width: screenWidth(context: context, mulBy: 0.3),
                  ),
                ],
              ),
            ),
            remarkWidget(e, remarks, widget.remarkImage),
          ],
        );
      case "time":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.showIcon
                      ? iconContainer(widget.dateImage)
                      : Container(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                        "${widget.showIndex ? "${checklistModel!.data![widget.index].questions!.indexOf(e) + 1}. " : ""}${e.title}"),
                  ),
                  descriptionWidget(
                      e, context, widget.descriptionTextDecoration),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                children: <Widget>[
                  customDropdownWidget(
                    onChanged: (val) {},
                    onTap: () async {
                      TimeOfDay tempTime = await selectTime(context);

                      if (e.answer == null) {
                        setState(() {
                          e.answer = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            tempTime.hour,
                            tempTime.minute,
                          );
                        });
                      } else {
                        setState(() {
                          e.answer = DateTime(
                            e.answer.year,
                            e.answer.month,
                            e.answer.day,
                            tempTime.hour,
                            tempTime.minute,
                          );
                        });
                      }

                      // reminderController.updateIschanged(true);
                    },
                    title: e.answer != null
                        ? formatTimeOfDay(TimeOfDay.fromDateTime(e.answer))
                        : "Hr:Mins",
                    context: context,
                    showImage: false,
                    isRequired: false,
                    width: screenWidth(context: context, mulBy: 0.3),
                  ),
                ],
              ),
            ),
            remarkWidget(e, remarks, widget.remarkImage),
          ],
        );

      case "date":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.showIcon
                      ? iconContainer(widget.dateImage)
                      : Container(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                        "${widget.showIndex ? "${checklistModel!.data![widget.index].questions!.indexOf(e) + 1}. " : ""}${e.title}"),
                  ),
                  descriptionWidget(
                      e, context, widget.descriptionTextDecoration),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                children: <Widget>[
                  Theme(
                    data: ThemeData(),
                    child: Builder(
                      builder: (context) => customDropdownWidget(
                        onChanged: (val) {
                          print(val);
                        },
                        onTap: () async {
                          DateTime tempDate = await selectDate(context);

                          if (e.answer == null) {
                            setState(() {
                              e.answer = tempDate;
                            });
                          } else {
                            setState(() {
                              e.answer = DateTime(
                                tempDate.year,
                                tempDate.month,
                                tempDate.day,
                                e.answer.hour,
                                e.answer.minute,
                              );
                            });
                          }
                        },
                        title: e.answer == null
                            ? "DD-MM-YYYY"
                            : dateFormater.format(e.answer),
                        // date != null ? dateFormater.format(date) : "DD-MM-YYYY",
                        context: context,

                        showImage: false,
                        isRequired: false,
                        width: screenWidth(context: context, mulBy: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            remarkWidget(e, remarks, widget.remarkImage),
          ],
        );

      case "file":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 16),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                        "${widget.showIndex ? "${checklistModel!.data![widget.index].questions!.indexOf(e) + 1}. " : ""}${e.title}"),
                  ),
                ),
                descriptionWidget(e, context, widget.descriptionTextDecoration),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          height: 70,
                          width: 100,
                          child: Icon(
                            Icons.add_a_photo_outlined,
                            color: Colors.grey[500],
                            size: 70,
                          ),
                        ),
                        e.answer != null
                            ? CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 15,
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      String url = widget.onUpload;
                      setState(() {
                        e.answer = url;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        "Upload",
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            remarkWidget(e, remarks, widget.remarkImage),
          ],
        );

      case "text":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.showIcon
                      ? iconContainer(widget.textImage)
                      : Container(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                        "${widget.showIndex ? "${checklistModel!.data![widget.index].questions!.indexOf(e) + 1}. " : ""}${e.title}"),
                  ),
                  descriptionWidget(
                      e, context, widget.descriptionTextDecoration),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16,
              ),
              child: Container(
                width: screenWidth(
                    context: context,
                    mulBy: widget.textFieldWidth == null
                        ? 0.9
                        : widget.textFieldWidth),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      maxLines: e.maxline,
                      onChanged: (value) {
                        // e.answer = value;
                        setState(() {
                          e.answer = value;
                        });
                      },
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: widget.textfieldDecoration ??
                          InputDecoration.collapsed(
                            hintText: "Entrez un texte ...",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
            ),
            remarkWidget(e, remarks, widget.remarkImage),
          ],
        );
        case "long":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.showIcon
                      ? iconContainer(widget.textImage)
                      : Container(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                        "${widget.showIndex ? "${checklistModel!.data![widget.index].questions!.indexOf(e) + 1}. " : ""}${e.title}"),
                  ),
                  descriptionWidget(
                      e, context, widget.descriptionTextDecoration),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16,
              ),
              child: Container(
                width: screenWidth(
                    context: context,
                    mulBy: widget.textFieldWidth == null
                        ? 0.9
                        : widget.textFieldWidth),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      readOnly:true,
                      maxLines: e.maxline,
                      onChanged: (value) {
                        // e.answer = value;
                        setState(() {
                          e.answer = value;
                        });
                      },
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: widget.textfieldDecoration ??
                          InputDecoration.collapsed(
                            hintText:long,
                            hintStyle: TextStyle(
                             fontWeight: FontWeight.normal,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
            ),
            remarkWidget(e, remarks, widget.remarkImage),
          ],
        );
         case "lat":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.showIcon
                      ? iconContainer(widget.textImage)
                      : Container(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                        "${widget.showIndex ? "${checklistModel!.data![widget.index].questions!.indexOf(e) + 1}. " : ""}${e.title}"),
                  ),
                  descriptionWidget(
                      e, context, widget.descriptionTextDecoration),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16,
              ),
              child: Container(
                width: screenWidth(
                    context: context,
                    mulBy: widget.textFieldWidth == null
                        ? 0.9
                        : widget.textFieldWidth),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      readOnly:true,
                      maxLines: e.maxline,
                      onChanged: (value) {
                        // e.answer = value;
                        setState(() {
                          e.answer = value;
                        });
                      },
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: widget.textfieldDecoration ??
                          InputDecoration.collapsed(
                            hintText: lat,
                            hintStyle: TextStyle(
                             fontWeight: FontWeight.normal,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
            ),
            remarkWidget(e, remarks, widget.remarkImage),
          ],
        );
        case "number":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.showIcon
                      ? iconContainer(widget.textImage)
                      : Container(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                        "${widget.showIndex ? "${checklistModel!.data![widget.index].questions!.indexOf(e) + 1}. " : ""}${e.title}"),
                  ),
                  descriptionWidget(
                      e, context, widget.descriptionTextDecoration),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16,
              ),
              child: Container(
                width: screenWidth(
                    context: context,
                    mulBy: widget.textFieldWidth == null
                        ? 0.9
                        : widget.textFieldWidth),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      maxLines: e.maxline,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
//                       inputFormatters: <TextInputFormatter>[
//                         FilteringTextInputFormatter.allow(RegExp(_getRegexString())),
//                         TextInputFormatter.withFunction(
//                           (oldValue, newValue) => newValue.copyWith(
//                             text: newValue.text.replaceAll('.', ','),
//                           ),
//                         ),
//                       ],
                      onChanged: (value) {
                        // e.answer = value;
                        setState(() {
                          e.answer = value;
                        });
                      },
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: widget.textfieldDecoration ??
                          InputDecoration.collapsed(
                            hintText: "Entrez une valeur ...",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
            ),
            remarkWidget(e, remarks, widget.remarkImage),
          ],
        );  

      default:
        return SizedBox();
    }
  }

  Widget iconContainer(image) {
    return image == null
        ? Container()
        : Container(
            padding: EdgeInsets.all(10),
            child: Image.asset(
              image,
              height: 20,
            ),
          );
  }

  Widget remarkWidget(Questions e, showIcon, image) {
    return e.remark
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: <Widget>[
                    showIcon == false
                        ? SizedBox(
                            width: 16,
                          )
                        : image == null
                            ? Container(
                                padding: EdgeInsets.only(left: 16),
                              )
                            : Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Image.asset(
                                  image,
                                  height: 20,
                                ),
                              ),
                    Text("Entrer votre commentaire"),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          onChanged: (value) {
                            e.remarkData = value;
                            setState(() {});
                          },
                          decoration: InputDecoration.collapsed(
                            hintText: "Entrer votre commentaire",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : SizedBox.shrink();
  }
}
