class Streak {
  int? _id;
  String? _title;
  int? _goal;

  Streak(this._title, this._goal);
  Streak.withId(this._id, this._title, this._goal);

  int get id => _id!;

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'title': _title,
      'goal': _goal,
    };
  }

  String get title => _title!;

  int get goal => _goal!;

  set goal(int value) {
    _goal = value;
  }

  set title(String value) {
    _title = value;
  }

  set id(int value) {
    _id = value;
  }

  Streak.fromMap(Map<String, dynamic> map) {
    _id = map['id'];
    _title = map['title'];
    _goal = map['goal'];
  }
}
