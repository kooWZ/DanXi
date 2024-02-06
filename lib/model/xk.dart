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
import 'package:dan_xi/common/constant.dart';
import 'package:dan_xi/model/time_table.dart';
import 'package:json_annotation/json_annotation.dart';

part 'xk.g.dart';

enum ExamType {
  PAPER,
  OPEN_BOOK,
  CLOSED_BOOK,
  ORAL,
  OTHER,
  NONE
}

@JsonSerializable()
class XkExam {
  ExamType? examType;
  DateTime? startTime;
  DateTime? endTime;

  XkExam();

  factory XkExam.fromJson(Map<String, dynamic> json) => _$XkExamFromJson(json);

  Map<String, dynamic> toJson() => _$XkExamToJson(this);
}

@JsonSerializable()
class XkCourse {
  int? courseId;
  int? courseNo;
  String? courseName;
  double? credits;
  List<CourseTime>? times;
  bool? withdrawable;
  List<String>? teacherNames;
  Campus? campus;
  String? rooms; //TODO: maybe combine room with time?

  int? elected;
  int? capacity;

  XkCourse();

  factory XkCourse.fromJson(Map<String, dynamic> json) => _$XkCourseFromJson(json);

  Map<String, dynamic> toJson() => _$XkCourseToJson(this);
}

@JsonSerializable()
class XkCurrent {
  List<XkCourse>? courses;
  double? totalCredit; //TODO

  XkCurrent(this.courses);

  factory XkCurrent.fromJson(Map<String, dynamic> json) => _$XkCurrentFromJson(json);

  Map<String, dynamic> toJson() => _$XkCurrentToJson(this);
}