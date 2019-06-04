import 'dart:convert';
import 'package:amap_base/amap_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:azlistview/azlistview.dart';
import 'package:lpinyin/lpinyin.dart';
import "package:renting_assistant/model/city_model.dart";
import 'package:renting_assistant/localstore/local_store.dart';
import 'package:renting_assistant/model/filter_condition.dart';

class CitySelectCustomHeaderRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _CitySelectCustomHeaderRouteState();
  }
}

class _CitySelectCustomHeaderRouteState
    extends State<CitySelectCustomHeaderRoute> {
  List<CityInfo> _cityList = List();

  int _suspensionHeight = 40;
  int _itemHeight = 50;
  String _suspensionTag = "";
  final _amapLocation = AMapLocation();
  final options = LocationClientOptions(
    isOnceLocation: true,
    locatingWithReGeocode: true,
  );
  String _currentCityName = "北京市";

  @override
  void initState() {
    super.initState();
    loadData();
    _amapLocation.init();
    _getCurrentCity();
  }

  void loadData() async {
    //加载城市列表
    rootBundle.loadString('assets/data/china.json').then((value) {
      Map countyMap = json.decode(value);
      List list = countyMap['china'];
      list.forEach((value) {
        _cityList.add(CityInfo(name: value['name']));
      });
      _handleList(_cityList);
      setState(() {});
    });
  }

  void _handleList(List<CityInfo> list) {
    if (list == null || list.isEmpty) return;
    for (int i = 0, length = list.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(list[i].name);
      String tag = pinyin.substring(0, 1).toUpperCase();
      list[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = "#";
      }
    }
    //根据A-Z排序
    SuspensionUtil.sortListBySuspensionTag(_cityList);
  }

  void _onSusTagChanged(String tag) {
    setState(() {
      _suspensionTag = tag;
    });
  }

  Widget _buildHeader() {
    List<CityInfo> hotCityList = List();
    hotCityList.addAll([
      CityInfo(name: "北京"),
      CityInfo(name: "广州"),
      CityInfo(name: "成都"),
      CityInfo(name: "深圳"),
      CityInfo(name: "杭州"),
      CityInfo(name: "武汉"),
    ]);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: 10.0,
        children: hotCityList.map((e) {
          return OutlineButton(
            borderSide: BorderSide(color: Colors.grey[300], width: .5),
            child: Text(e.name),
            onPressed: () {
              print("OnItemClick: $e");
              Navigator.pop(context, e);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSusWidget(String susTag) {
    return Container(
      height: _suspensionHeight.toDouble(),
      padding: const EdgeInsets.only(left: 15.0),
      color: Color(0xfff3f4f5),
      alignment: Alignment.centerLeft,
      child: Text(
        '$susTag',
        softWrap: false,
        style: TextStyle(
          fontSize: 14.0,
          color: Color(0xff999999),
        ),
      ),
    );
  }

  Widget _buildListItem(CityInfo model) {
    String susTag = model.getSuspensionTag();
    return Column(
      children: <Widget>[
        Offstage(
          offstage: model.isShowSuspension != true,
          child: _buildSusWidget(susTag),
        ),
        SizedBox(
          height: _itemHeight.toDouble(),
          child: ListTile(
            title: Text(model.name),
            onTap: () {
              print("OnItemClick: $model");
              LocalStore.saveCurrentCity(model.name);
              LocalStore.saveFilterCondition(FilterCondition());
              Navigator.pop(context, model);
            },
          ),
        )
      ],
    );
  }

  void _getCurrentCity() async {
    if (await Permissions().requestPermission()) {
      _amapLocation.getLocation(options).then(
            (value) {
          setState(() {
            if (value != null) {
              setState(() {
                _currentCityName = value.city;
              });
            }
          });
        },
      );
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('权限不足')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
            title: Text("当前城市"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.place,
                  size: 20.0,
                ),
                Text(_currentCityName),
              ],
            )),
        Divider(
          height: .0,
        ),
        Expanded(
            flex: 1,
            child: AzListView(
              data: _cityList,
              itemBuilder: (context, model) => _buildListItem(model),
              suspensionWidget: _buildSusWidget(_suspensionTag),
              isUseRealIndex: true,
              itemHeight: _itemHeight,
              suspensionHeight: _suspensionHeight,
              onSusTagChanged: _onSusTagChanged,
              header: AzListViewHeader(
                  tag: "★",
                  height: 140,
                  builder: (context) {
                    return _buildHeader();
                  }),
              indexHintBuilder: (context, hint) {
                return Container(
                  alignment: Alignment.center,
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                      color: Colors.black54, shape: BoxShape.circle),
                  child: Text(hint,
                      style: TextStyle(color: Colors.white, fontSize: 30.0)),
                );
              },
            )),
      ],
    );
  }
}
