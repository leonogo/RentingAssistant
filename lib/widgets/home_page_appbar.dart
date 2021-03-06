import 'package:amap_base/amap_base.dart';
import 'package:flutter/material.dart';
import 'package:renting_assistant/pages/city_select_page.dart';
import 'package:renting_assistant/localstore/local_store.dart';
import 'package:renting_assistant/even_bus/even_bus.dart';

class HomePageAppBar extends StatefulWidget implements PreferredSizeWidget {
  final height = 56.0;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<HomePageAppBar> createState() {
    return HomePageAppBarState();
  }
}

class HomePageAppBarState extends State<HomePageAppBar>
    with AutomaticKeepAliveClientMixin {
  String _cityName = "北京";
  final _amapLocation = AMapLocation();
  final options = LocationClientOptions(
    isOnceLocation: true,
    locatingWithReGeocode: true,
  );

  @override
  void initState() {
    super.initState();
    _amapLocation.init();
    _readLocalCurrentCity();
    _initCurrentCity();
  }

  void _initCurrentCity() async {
    LocalStore.readCurrentCity().then((currentCity) {
      if (currentCity == null) {
        _getCurrentCity();
      }
    });
  }

  void _getCurrentCity() async {
      if (await Permissions().requestPermission()) {
        _amapLocation.getLocation(options).then(
              (value) {
            setState(() {
              if (value != null) {
                setState(() {
                  _cityName = value.city.replaceAll("市", "");
                });
                LocalStore.saveCurrentCity(value.city.replaceAll("市", ""));
                LocalStore.saveCurrentGeo(
                    "${value.latitude},${value.longitude}");
              }
            });
          },
        );
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text('权限不足')));
      }
    }

  void _readLocalCurrentCity() async {
    LocalStore.readCurrentCity().then((value) {
      if (value != null) {
        setState(() {
          _cityName = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        height: 56.0,
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Row(
                    children: <Widget>[
                      Text(
                        _cityName,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey[500],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return CitySelectPage();
                    })).then((value) {
                      if (value != null) {
                        setState(() {
                          _cityName = value.name;
                        });
                        eventBus.fire(RefreshHomeRecommendList("reset"));
                      }
                    });
                  },
                )),
            Expanded(
                flex: 4,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    height: 40.0,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.search,
                          color: Colors.grey[500],
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          "请输入小区、商圈、地铁",
                          style: TextStyle(
                              fontSize: 14.0, color: Colors.grey[600]),
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey[200],
                            offset: Offset(0.0, 2.0),
                            blurRadius: 4.0,
                            spreadRadius: 2.0),
                      ],
                    ),
                  ),
                  onTap: () => Navigator.of(context).pushNamed('/search'),
                )),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
