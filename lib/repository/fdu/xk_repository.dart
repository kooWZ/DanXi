/*
 *     Copyright (C) 2024  DanXi-Dev
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
  int? xkNo;
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

}

class XkRepository extends BaseRepositoryWithDio {
  // [xk.fudan.edu.cn] checks User-Agent so we use [www.urp.fudan.edu.cn]
  static const String XK_LOGIN_URL =
      'https://uis.fudan.edu.cn/authserver/login?service=http%3A%2F%2Fwww.urp.fudan.edu.cn%3A92%2Feams%2FstdElectCourse.action';
  static const String XK_URL =
      'http://www.urp.fudan.edu.cn:92/eams/stdElectCourse.action';
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

      RegExp xkNoPattern = RegExp(r"name='electionProfile.id' value='(\d+)'");
      RegExpMatch? xkNoMatch = xkNoPattern.firstMatch(xkPage.data!);
      stage.xkNo = int.tryParse(xkNoMatch!.group(1)!);

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
    //TODO
  }

  Future<XkCourseInfo?> queryCourse(PersonInfo? info, int semester, int courseId) {
    return UISLoginTool.tryAsyncWithAuth(
        dio, XK_LOGIN_URL, cookieJar!, info, () => _queryCourse(semester, courseId));
  }

  Future<XkCourseInfo?> _queryCourse(int semester, int courseId) async {
    //TODO
  }

  @override
  String get linkHost => "www.urp.fudan.edu.cn:92";
}
