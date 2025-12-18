// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streaks_database.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStreakCollection on Isar {
  IsarCollection<Streak> get streaks => this.collection();
}

const StreakSchema = CollectionSchema(
  name: r'Streak',
  id: 2927724474768415338,
  properties: {
    r'colorCode': PropertySchema(
      id: 0,
      name: r'colorCode',
      type: IsarType.long,
    ),
    r'daysOfWeek': PropertySchema(
      id: 1,
      name: r'daysOfWeek',
      type: IsarType.stringList,
    ),
    r'iconCode': PropertySchema(
      id: 2,
      name: r'iconCode',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    ),
    r'notificationHour': PropertySchema(
      id: 4,
      name: r'notificationHour',
      type: IsarType.long,
    ),
    r'notificationMinute': PropertySchema(
      id: 5,
      name: r'notificationMinute',
      type: IsarType.long,
    ),
    r'selectedDays': PropertySchema(
      id: 6,
      name: r'selectedDays',
      type: IsarType.longList,
    ),
    r'selectedWeek': PropertySchema(
      id: 7,
      name: r'selectedWeek',
      type: IsarType.long,
    ),
    r'streakDates': PropertySchema(
      id: 8,
      name: r'streakDates',
      type: IsarType.dateTimeList,
    ),
    r'unlockedBadges': PropertySchema(
      id: 9,
      name: r'unlockedBadges',
      type: IsarType.longList,
    )
  },
  estimateSize: _streakEstimateSize,
  serialize: _streakSerialize,
  deserialize: _streakDeserialize,
  deserializeProp: _streakDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _streakGetId,
  getLinks: _streakGetLinks,
  attach: _streakAttach,
  version: '3.3.0-dev.3',
);

int _streakEstimateSize(
  Streak object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.daysOfWeek.length * 3;
  {
    for (var i = 0; i < object.daysOfWeek.length; i++) {
      final value = object.daysOfWeek[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.selectedDays.length * 8;
  bytesCount += 3 + object.streakDates.length * 8;
  {
    final value = object.unlockedBadges;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  return bytesCount;
}

void _streakSerialize(
  Streak object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.colorCode);
  writer.writeStringList(offsets[1], object.daysOfWeek);
  writer.writeLong(offsets[2], object.iconCode);
  writer.writeString(offsets[3], object.name);
  writer.writeLong(offsets[4], object.notificationHour);
  writer.writeLong(offsets[5], object.notificationMinute);
  writer.writeLongList(offsets[6], object.selectedDays);
  writer.writeLong(offsets[7], object.selectedWeek);
  writer.writeDateTimeList(offsets[8], object.streakDates);
  writer.writeLongList(offsets[9], object.unlockedBadges);
}

Streak _streakDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Streak(
    colorCode: reader.readLong(offsets[0]),
    daysOfWeek: reader.readStringList(offsets[1]) ?? [],
    iconCode: reader.readLong(offsets[2]),
    name: reader.readString(offsets[3]),
    notificationHour: reader.readLong(offsets[4]),
    notificationMinute: reader.readLong(offsets[5]),
    selectedDays: reader.readLongList(offsets[6]) ?? [],
    selectedWeek: reader.readLong(offsets[7]),
    streakDates: reader.readDateTimeList(offsets[8]) ?? [],
    unlockedBadges: reader.readLongList(offsets[9]),
  );
  object.id = id;
  return object;
}

P _streakDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLongList(offset) ?? []) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDateTimeList(offset) ?? []) as P;
    case 9:
      return (reader.readLongList(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _streakGetId(Streak object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _streakGetLinks(Streak object) {
  return [];
}

void _streakAttach(IsarCollection<dynamic> col, Id id, Streak object) {
  object.id = id;
}

extension StreakQueryWhereSort on QueryBuilder<Streak, Streak, QWhere> {
  QueryBuilder<Streak, Streak, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StreakQueryWhere on QueryBuilder<Streak, Streak, QWhereClause> {
  QueryBuilder<Streak, Streak, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Streak, Streak, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterWhereClause> nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterWhereClause> nameNotEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension StreakQueryFilter on QueryBuilder<Streak, Streak, QFilterCondition> {
  QueryBuilder<Streak, Streak, QAfterFilterCondition> colorCodeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorCode',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> colorCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorCode',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> colorCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorCode',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> colorCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> daysOfWeekElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'daysOfWeek',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      daysOfWeekElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'daysOfWeek',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> daysOfWeekElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'daysOfWeek',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> daysOfWeekElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'daysOfWeek',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      daysOfWeekElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'daysOfWeek',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> daysOfWeekElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'daysOfWeek',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> daysOfWeekElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'daysOfWeek',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> daysOfWeekElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'daysOfWeek',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      daysOfWeekElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'daysOfWeek',
        value: '',
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      daysOfWeekElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'daysOfWeek',
        value: '',
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> daysOfWeekLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'daysOfWeek',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> daysOfWeekIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'daysOfWeek',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> daysOfWeekIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'daysOfWeek',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> daysOfWeekLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'daysOfWeek',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      daysOfWeekLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'daysOfWeek',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> daysOfWeekLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'daysOfWeek',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> iconCodeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconCode',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> iconCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iconCode',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> iconCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iconCode',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> iconCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iconCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> notificationHourEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationHour',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      notificationHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notificationHour',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> notificationHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notificationHour',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> notificationHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notificationHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> notificationMinuteEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      notificationMinuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notificationMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      notificationMinuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notificationMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> notificationMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notificationMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      selectedDaysElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'selectedDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      selectedDaysElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'selectedDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      selectedDaysElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'selectedDays',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      selectedDaysElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'selectedDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> selectedDaysLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedDays',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> selectedDaysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedDays',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> selectedDaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedDays',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      selectedDaysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedDays',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      selectedDaysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedDays',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> selectedDaysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedDays',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> selectedWeekEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'selectedWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> selectedWeekGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'selectedWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> selectedWeekLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'selectedWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> selectedWeekBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'selectedWeek',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> streakDatesElementEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streakDates',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      streakDatesElementGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streakDates',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      streakDatesElementLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streakDates',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> streakDatesElementBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streakDates',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> streakDatesLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'streakDates',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> streakDatesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'streakDates',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> streakDatesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'streakDates',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> streakDatesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'streakDates',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      streakDatesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'streakDates',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> streakDatesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'streakDates',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> unlockedBadgesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unlockedBadges',
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      unlockedBadgesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unlockedBadges',
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      unlockedBadgesElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedBadges',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      unlockedBadgesElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockedBadges',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      unlockedBadgesElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockedBadges',
        value: value,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      unlockedBadgesElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockedBadges',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      unlockedBadgesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedBadges',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition> unlockedBadgesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedBadges',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      unlockedBadgesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedBadges',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      unlockedBadgesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedBadges',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      unlockedBadgesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedBadges',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Streak, Streak, QAfterFilterCondition>
      unlockedBadgesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedBadges',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension StreakQueryObject on QueryBuilder<Streak, Streak, QFilterCondition> {}

extension StreakQueryLinks on QueryBuilder<Streak, Streak, QFilterCondition> {}

extension StreakQuerySortBy on QueryBuilder<Streak, Streak, QSortBy> {
  QueryBuilder<Streak, Streak, QAfterSortBy> sortByColorCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorCode', Sort.asc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> sortByColorCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorCode', Sort.desc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> sortByIconCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCode', Sort.asc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> sortByIconCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCode', Sort.desc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> sortByNotificationHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationHour', Sort.asc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> sortByNotificationHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationHour', Sort.desc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> sortByNotificationMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationMinute', Sort.asc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> sortByNotificationMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationMinute', Sort.desc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> sortBySelectedWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedWeek', Sort.asc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> sortBySelectedWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedWeek', Sort.desc);
    });
  }
}

extension StreakQuerySortThenBy on QueryBuilder<Streak, Streak, QSortThenBy> {
  QueryBuilder<Streak, Streak, QAfterSortBy> thenByColorCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorCode', Sort.asc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> thenByColorCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorCode', Sort.desc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> thenByIconCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCode', Sort.asc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> thenByIconCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCode', Sort.desc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> thenByNotificationHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationHour', Sort.asc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> thenByNotificationHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationHour', Sort.desc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> thenByNotificationMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationMinute', Sort.asc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> thenByNotificationMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationMinute', Sort.desc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> thenBySelectedWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedWeek', Sort.asc);
    });
  }

  QueryBuilder<Streak, Streak, QAfterSortBy> thenBySelectedWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedWeek', Sort.desc);
    });
  }
}

extension StreakQueryWhereDistinct on QueryBuilder<Streak, Streak, QDistinct> {
  QueryBuilder<Streak, Streak, QDistinct> distinctByColorCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorCode');
    });
  }

  QueryBuilder<Streak, Streak, QDistinct> distinctByDaysOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'daysOfWeek');
    });
  }

  QueryBuilder<Streak, Streak, QDistinct> distinctByIconCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconCode');
    });
  }

  QueryBuilder<Streak, Streak, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Streak, Streak, QDistinct> distinctByNotificationHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationHour');
    });
  }

  QueryBuilder<Streak, Streak, QDistinct> distinctByNotificationMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationMinute');
    });
  }

  QueryBuilder<Streak, Streak, QDistinct> distinctBySelectedDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'selectedDays');
    });
  }

  QueryBuilder<Streak, Streak, QDistinct> distinctBySelectedWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'selectedWeek');
    });
  }

  QueryBuilder<Streak, Streak, QDistinct> distinctByStreakDates() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streakDates');
    });
  }

  QueryBuilder<Streak, Streak, QDistinct> distinctByUnlockedBadges() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedBadges');
    });
  }
}

extension StreakQueryProperty on QueryBuilder<Streak, Streak, QQueryProperty> {
  QueryBuilder<Streak, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Streak, int, QQueryOperations> colorCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorCode');
    });
  }

  QueryBuilder<Streak, List<String>, QQueryOperations> daysOfWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'daysOfWeek');
    });
  }

  QueryBuilder<Streak, int, QQueryOperations> iconCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconCode');
    });
  }

  QueryBuilder<Streak, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Streak, int, QQueryOperations> notificationHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationHour');
    });
  }

  QueryBuilder<Streak, int, QQueryOperations> notificationMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationMinute');
    });
  }

  QueryBuilder<Streak, List<int>, QQueryOperations> selectedDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selectedDays');
    });
  }

  QueryBuilder<Streak, int, QQueryOperations> selectedWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selectedWeek');
    });
  }

  QueryBuilder<Streak, List<DateTime>, QQueryOperations> streakDatesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streakDates');
    });
  }

  QueryBuilder<Streak, List<int>?, QQueryOperations> unlockedBadgesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedBadges');
    });
  }
}
