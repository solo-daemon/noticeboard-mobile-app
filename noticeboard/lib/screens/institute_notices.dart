import 'package:flutter/material.dart';
import 'package:noticeboard/models/notice_intro.dart';
import '../enum/insti_notices_enum.dart';
import '../bloc/insti_notices_bloc.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final InstituteNoticesBloc _instituteNoticesBloc = InstituteNoticesBloc();

  @override
  void initState() {
    _instituteNoticesBloc.context = context;
    fetchNoticeEventSink();
    super.initState();
  }

  void fetchNoticeEventSink() {
    _instituteNoticesBloc.eventSink
        .add(InstituteNoticesEvent.fetchInstituteNotices);
  }

  Future refreshNotices() async {
    fetchNoticeEventSink();
    await Future.delayed(Duration(seconds: 1));
  }

  @override
  void dispose() {
    _instituteNoticesBloc.disposeStreams();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Institute Notices',
          style: TextStyle(color: Colors.black),
        ),
        automaticallyImplyLeading: false,
        leading: Container(
          padding: EdgeInsets.only(left: 11.0, top: 5.0),
          child: GestureDetector(
            onTap: () {
              _instituteNoticesBloc.eventSink
                  .add(InstituteNoticesEvent.pushProfileEvent);
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey[500],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refreshNotices,
        child: ListView(
          children: [
            Container(
              height: height * 0.88,
              width: width,
              child: StreamBuilder(
                stream: _instituteNoticesBloc.instiNoticesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length == 0) return buildNoResults();
                    return buildNoticesList(snapshot, width, height);
                  } else if (snapshot.hasError) {
                    return buildErrorWidget(snapshot);
                  }
                  return buildLoading();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Center buildNoticesList(AsyncSnapshot snapshot, double width, double height) {
    return Center(
      child: Container(
        width: width * 0.9,
        child: RefreshIndicator(
          onRefresh: refreshNotices,
          child: ListView.separated(
              separatorBuilder: (context, index) => Divider(
                    color: Colors.black,
                  ),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                NoticeIntro noticeIntroObj = snapshot.data[index];
                return buildListItem(noticeIntroObj, width, height);
              }),
        ),
      ),
    );
  }

  Container buildListItem(
      NoticeIntro noticeIntroObj, double width, double height) {
    return Container(
      width: width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: width,
                    child: Text(
                      noticeIntroObj.department,
                      overflow: TextOverflow.ellipsis,
                    )),
                SizedBox(
                  height: 5.0,
                ),
                Container(
                  width: width,
                  child: Text(noticeIntroObj.dateCreated,
                      overflow: TextOverflow.ellipsis),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Container(
                    width: width,
                    child: Text(noticeIntroObj.title,
                        overflow: TextOverflow.ellipsis))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Icon(
              Icons.bookmark_border,
              size: 30.0,
            ),
          )
        ],
      ),
    );
  }

  Center buildNoResults() {
    return Center(
      child: Text('No Notices'),
    );
  }

  Center buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Center buildErrorWidget(AsyncSnapshot snapshot) =>
      Center(child: Text(snapshot.error));
}