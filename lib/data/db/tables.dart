import 'package:drift/drift.dart';
import '../../domain/entities/cadence.dart';

class CadenceConverter extends TypeConverter<Cadence, String> {
  const CadenceConverter();

  @override
  Cadence fromSql(String fromDb) => Cadence.values.byName(fromDb);

  @override
  String toSql(Cadence value) => value.name;
}

class Categories extends Table {
  TextColumn get id => text()(); // uuid
  TextColumn get name => text()();
  IntColumn get colorArgb => integer()();
  TextColumn get iconKey => text().withDefault(const Constant('folder'))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Works extends Table {
  TextColumn get id => text()(); // uuid v4
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  IntColumn get colorArgb => integer()();
  TextColumn get cadence => text().map(const CadenceConverter())();
  IntColumn get weekdayMask => integer().withDefault(const Constant(127))(); // bit0=Mon..bit6=Sun
  TextColumn get startDate => text()(); // 'YYYY-MM-DD'
  TextColumn get dueDate => text().nullable()(); // 'YYYY-MM-DD'
  IntColumn get effort => integer().withDefault(const Constant(1))(); // 1..3
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()(); // soft delete

  @override
  Set<Column> get primaryKey => {id};
}

class ProgressEntries extends Table {
  TextColumn get id => text()();
  TextColumn get workId => text().references(Works, #id)();
  TextColumn get periodStart => text()(); // 'YYYY-MM-DD'
  IntColumn get percent => integer().check(percent.isBetweenValues(0, 100))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {workId, periodStart}
      ];
}

class ProgressEvents extends Table {
  TextColumn get id => text()();
  TextColumn get workId => text().references(Works, #id)();
  TextColumn get periodStart => text()();
  IntColumn get fromPercent => integer()();
  IntColumn get toPercent => integer()();
  DateTimeColumn get at => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get workId => text().references(Works, #id)();
  IntColumn get minutesOfDay => integer()(); // 0..1439
  IntColumn get weekdayMask => integer().withDefault(const Constant(127))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
