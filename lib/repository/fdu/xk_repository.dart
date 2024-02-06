/*
 *     Copyright (C) 2024  kooWZ
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:convert';

import 'package:dan_xi/common/constant.dart';
import 'package:dan_xi/model/person.dart';
import 'package:dan_xi/model/xk.dart';
import 'package:dan_xi/model/time_table.dart';
import 'package:dan_xi/provider/settings_provider.dart';
import 'package:dan_xi/repository/base_repository.dart';
import 'package:dan_xi/repository/fdu/uis_login_tool.dart';
import 'package:dan_xi/util/io/cache.dart';
import 'package:dan_xi/util/io/dio_utils.dart';
import 'package:dan_xi/util/retrier.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:html/dom.dart' as dom;

class XkStage {
  bool valid;
  int? semester;
  String? name;
  DateTime? startElectTime;
  DateTime? endElectTime;
  DateTime? startDropTime;
  DateTime? endDropTime;
  XkStage(this.valid);
}

class XkResult {
  bool success;
  String? msg;
  XkResult(this.success);
}

class XkCourseInfo {
  XkCourseInfo();
}

class XkRepository extends BaseRepositoryWithDio {
  // [xk.fudan.edu.cn] checks User-Agent so we use [www.urp.fudan.edu.cn]
  static const String XK_LOGIN_URL =
      'https://uis.fudan.edu.cn/authserver/login?service=http%3A%2F%2Fwww.urp.fudan.edu.cn%3A92%2Feams%2FstdElectCourse.action';
  static const String XK_URL =
      'http://www.urp.fudan.edu.cn:92/eams/stdElectCourse.action';
  static const String XK_MAIN_URL =
      'http://www.urp.fudan.edu.cn:92/eams/stdElectCourse!defaultPage.action'; //?electionProfile.id=2685
  static const String QUERY_URL =
      'http://www.urp.fudan.edu.cn:92/eams/stdElectCourse!queryLesson.action'; //?profileId=2685
  static const String OPERATOR_URL =
      'http://www.urp.fudan.edu.cn:92/eams/stdElectCourse!batchOperator.action'; //?profileId=2685
  static const String HOST = "http://www.urp.fudan.edu.cn:92/";

  XkRepository._();

  static final _instance = XkRepository._();

  factory XkRepository.getInstance() => _instance;

  Future<XkStage?> loadXkStage(PersonInfo? info) {
    return UISLoginTool.tryAsyncWithAuth(
        dio, XK_LOGIN_URL, cookieJar!, info, () => _loadXkStage());
  }

  Future<XkStage?> _loadXkStage() async {
    Response<String> xkPage = await dio.get(XK_URL);
    if (xkPage.data?.contains("学期") ?? false) {
      XkStage stage = XkStage(true);

      RegExp xkNamePattern = RegExp(r'<h2(.*?)>(.*?)</h2>');
      RegExpMatch? xkNameMatch = xkNamePattern.firstMatch(xkPage.data!);
      stage.name = xkNameMatch?.group(2);

      RegExp semesterPattern = RegExp(r"name='electionProfile.id' value='(\d+)'");
      RegExpMatch? semesterMatch = semesterPattern.firstMatch(xkPage.data!);
      stage.semester = int.tryParse(semesterMatch!.group(1)!);

      DateFormat timeFormat = DateFormat("yyyy-MM-dd HH:mm");
      RegExp timePattern = RegExp(
          r'(选课开放时间|退课开放时间): (\d{4}-\d{2}-\d{2} \d{2}:\d{2}) - (\d{4}-\d{2}-\d{2} \d{2}:\d{2})');
      Iterable<RegExpMatch> timeMatches = timePattern.allMatches(xkPage.data!);
      for (RegExpMatch match in timeMatches) {
        String type = match.group(1)!;
        String start = match.group(2)!;
        String end = match.group(3)!;

        if (type == "选课开放时间") {
          stage.startElectTime = timeFormat.parse(start);
          stage.endElectTime = timeFormat.parse(end);
        } else if (type == "退课开放时间") {
          stage.startDropTime = timeFormat.parse(start);
          stage.endDropTime = timeFormat.parse(end);
        }
      }

      return stage;
    }
    return XkStage(false);
  }

  Future<XkCurrent?> loadXkCurrent(PersonInfo? info, int semester) {
    return UISLoginTool.tryAsyncWithAuth(
        dio, XK_LOGIN_URL, cookieJar!, info, () => _loadXkCurrent(semester));
  }

  Future<XkCurrent?> _loadXkCurrent(int semester) async {
    Response<String> electedResponse = await dio.post(
        XK_MAIN_URL,
        data: "electionProfile.id=$semester");

  }

  Future<XkResult?> electCourse(PersonInfo? info, int semester, int courseId) {
    return UISLoginTool.tryAsyncWithAuth(
        dio, XK_LOGIN_URL, cookieJar!, info, () => _electCourse(semester, courseId));
  }

  Future<XkResult?> _electCourse(int semester, int courseId) async {
    //TODO
  }

  Future<XkResult?> dropCourse(PersonInfo? info, int semester, int courseId) {
    return UISLoginTool.tryAsyncWithAuth(
        dio, XK_LOGIN_URL, cookieJar!, info, () => _electCourse(semester, courseId));
  }

  Future<XkResult?> _dropCourse(int semester, int courseId) async {
    Response<String> response = await dio.post(
        "$OPERATOR_URL?profileId=$semester",
        data: "optype=&operator0=&captcha_response=captcha_response");
    if (response.data?.contains('成功') ?? false) {
      return XkResult(true);
    }
    XkResult result = XkResult(false);
    if (response.data != null){
      if (response.data!.contains('失败')){
        //TODO
      } else {
        result.msg = 'Unknown Error';
      }
    } else {
      result.msg = 'Null Response!';
    }
    return result;
  }

  Future<List<XkCourseInfo>?> queryCourseByName(PersonInfo? info, int semester, String courseName) {
    String queryParam = 'lessonNo=&courseCode=&courseName=$courseName';
    return UISLoginTool.tryAsyncWithAuth(
        dio, XK_LOGIN_URL, cookieJar!, info, () => _queryCourse(semester, queryParam));
  }

  Future<List<XkCourseInfo>?> queryCourseByCode(PersonInfo? info, int semester, String courseCode) {
    String queryParam = 'lessonNo=&courseCode=$courseCode&courseName=';
    return UISLoginTool.tryAsyncWithAuth(
        dio, XK_LOGIN_URL, cookieJar!, info, () => _queryCourse(semester, queryParam));
  }

  Future<List<XkCourseInfo>?> queryCourseByNo(PersonInfo? info, int semester, String courseNo) {
    String queryParam = 'lessonNo=$courseNo&courseCode=&courseName=';
    return UISLoginTool.tryAsyncWithAuth(
        dio, XK_LOGIN_URL, cookieJar!, info, () => _queryCourse(semester, queryParam));
  }

  Future<List<XkCourseInfo>?> _queryCourse(int semester, String queryParam) async {
    List<XkCourseInfo> result = [];
    Response<String> response = await dio.post(
        "$QUERY_URL?profileId=$semester",
        data: queryParam);
    if (response.data == null){
      return result;
    } else {
      //TODO
    }
  }

  @override
  String get linkHost => "www.urp.fudan.edu.cn:92";
}
