// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xk.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

XkExam _$XkExamFromJson(Map<String, dynamic> json) => XkExam()
  ..examType = $enumDecodeNullable(_$ExamTypeEnumMap, json['examType'])
  ..startTime = json['startTime'] == null
      ? null
      : DateTime.parse(json['startTime'] as String)
  ..endTime = json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String);

Map<String, dynamic> _$XkExamToJson(XkExam instance) => <String, dynamic>{
      'examType': _$ExamTypeEnumMap[instance.examType],
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
    };

const _$ExamTypeEnumMap = {
  ExamType.PAPER: 'PAPER',
  ExamType.OPEN_BOOK: 'OPEN_BOOK',
  ExamType.CLOSED_BOOK: 'CLOSED_BOOK',
  ExamType.ORAL: 'ORAL',
  ExamType.OTHER: 'OTHER',
  ExamType.NONE: 'NONE',
};

XkCourse _$XkCourseFromJson(Map<String, dynamic> json) => XkCourse()
  ..courseId = json['courseId'] as int?
  ..courseNo = json['courseNo'] as int?
  ..courseName = json['courseName'] as String?
  ..credits = (json['credits'] as num?)?.toDouble()
  ..times = (json['times'] as List<dynamic>?)
      ?.map((e) => CourseTime.fromJson(e as Map<String, dynamic>))
      .toList()
  ..withdrawable = json['withdrawable'] as bool?
  ..teacherNames =
      (json['teacherNames'] as List<dynamic>?)?.map((e) => e as String).toList()
  ..campus = $enumDecodeNullable(_$CampusEnumMap, json['campus'])
  ..rooms = json['rooms'] as String?
  ..elected = json['elected'] as int?
  ..capacity = json['capacity'] as int?;

Map<String, dynamic> _$XkCourseToJson(XkCourse instance) => <String, dynamic>{
      'courseId': instance.courseId,
      'courseNo': instance.courseNo,
      'courseName': instance.courseName,
      'credits': instance.credits,
      'times': instance.times,
      'withdrawable': instance.withdrawable,
      'teacherNames': instance.teacherNames,
      'campus': _$CampusEnumMap[instance.campus],
      'rooms': instance.rooms,
      'elected': instance.elected,
      'capacity': instance.capacity,
    };

const _$CampusEnumMap = {
  Campus.HANDAN_CAMPUS: 'HANDAN_CAMPUS',
  Campus.FENGLIN_CAMPUS: 'FENGLIN_CAMPUS',
  Campus.JIANGWAN_CAMPUS: 'JIANGWAN_CAMPUS',
  Campus.ZHANGJIANG_CAMPUS: 'ZHANGJIANG_CAMPUS',
  Campus.NONE: 'NONE',
};

XkCurrent _$XkCurrentFromJson(Map<String, dynamic> json) => XkCurrent(
      (json['courses'] as List<dynamic>?)
          ?.map((e) => XkCourse.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..totalCredit = (json['totalCredit'] as num?)?.toDouble();

Map<String, dynamic> _$XkCurrentToJson(XkCurrent instance) => <String, dynamic>{
      'courses': instance.courses,
      'totalCredit': instance.totalCredit,
    };
