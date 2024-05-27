// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonDat _$JsonDatFromJson(Map<String, dynamic> json) => JsonDat(
  tasks: json['tasks'] as String,
  match: json['match'] as String,
  id: json['id'] as int,
  word: json['word'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$JsonDatToJson(JsonDat instance) => <String, dynamic>{
  'tasks': instance.tasks,
  'match': instance.match,
  'id': instance.id,
  'word': instance.word,
  'description': instance.description,
};
