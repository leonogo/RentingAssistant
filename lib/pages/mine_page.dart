import 'package:flutter/material.dart';
import 'package:renting_assistant/api/net_data_repo.dart';
import 'package:renting_assistant/even_bus/even_bus.dart';
import 'package:renting_assistant/localstore/local_store.dart';
import 'package:renting_assistant/model/user_info.dart';
import 'package:renting_assistant/pages/collect_page.dart';
import 'package:renting_assistant/pages/history_page.dart';
import 'package:renting_assistant/pages/message_page.dart';

class MinePage extends StatefulWidget {
  @override
  State<MinePage> createState() {
    return _MinePageState();
  }
}

class _MinePageState extends State<MinePage>
    with AutomaticKeepAliveClientMixin {
  final _iconTextStyle = TextStyle(fontSize: 15.0, color: Colors.black38);
  String accessToken;
  UserInfo userInfo;

  @override
  void initState() {
    loadAccessToken();
    super.initState();

  }

  loadAccessToken() async {
    await LocalStore.readAccessToken().then((value) {
      if (value != null) {
        accessToken = value;
        loadUserInfo(value);//加载UserInfo
      } else {

      }
    });
  }

  loadUserInfo(String accessToken) {
    LocalStore.readUserInfo().then((value) {
      if (value == null) {
        print(accessToken);
        NetDataRepo().obtainUserInfo(accessToken).then((value) {
          if (value != null) {
            LocalStore.saveUserInfo(value);
            setState(() {
              userInfo = value;
            });
          }
        });
      } else {
        setState(() {
          userInfo = value;
        });
      }
    });
  }

  _listen() {
    eventBus.on<LogOutEvent>().listen((event) {
      setState(() {
        accessToken = null;
        userInfo = null;
      });
    });
    eventBus.on<SignInEvent>().listen((event) {
      loadAccessToken();
    });
  }


  @override
  Widget build(BuildContext context) {
    _listen();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () => Navigator.of(context).pushNamed("/setting"),
              icon: Icon(
                Icons.settings,
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
                left: 20.0, top: 20.0, bottom: 16.0, right: 20.0),
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    if (userInfo == null) {
                      Navigator.of(context).pushNamed("/sign-in").then((value) {
                      });
                    } else {
                      print("编辑个人信息");
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 25.0),
                    width: 65.0,
                    height: 65.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(65.0),
                      image: DecorationImage(
                        image: NetworkImage(
                          userInfo != null
                              ? userInfo.avatar
                              : "https://avatar.gitee.com/uploads/29/4790229_leonzm.png!avatar100?1548256827",
                        ),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (userInfo == null) {
                      Navigator.of(context).pushNamed("/sign-in").then((value) {
                      });
                    } else {
                      print("编辑个人信息");
                    }
                  },
                  child: Container(
                    width: 200.0,
                    child: Text(
                      userInfo != null ? userInfo.nickname : "登录/注册",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(left: 8.0, right: 8.0, top: 15.0, bottom: 15.0),
            color: Colors.white,
            child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (userInfo == null) {
                        print("ToLogin");
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return CollectPage();
                        }));
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.favorite_border,
                          color: Theme.of(context).primaryColor,
                        ),
                        Text(
                          "关注",
                          style: _iconTextStyle,
                        )
                      ],
                    ),
                  )
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (userInfo == null) {
                        print("ToLogin");
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return HistoryPage();
                        }));
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.history,
                          color: Theme.of(context).primaryColor,
                        ),
                        Text(
                          "足迹",
                          style: _iconTextStyle,
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (userInfo == null) {
                        print("ToLogin");
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return MessagePage();
                        }));
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.question_answer,
                          color: Theme.of(context).primaryColor,
                        ),
                        Text(
                          "消息",
                          style: _iconTextStyle,
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.chat_bubble_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      Text(
                        "话题",
                        style: _iconTextStyle,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Text('房源数据'),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
