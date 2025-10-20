class Member {
  // Required
  final String id;          // GUID
  final String name;        // required
  final String memberCode;  // required, e.g. 02-0018
  final String midibId;     // relation to Midib

  // Optional (from MemberBaseDto)
  final String? motherName;
  final String? genderId;
  final int? birthDate;           // day in month (int?)
  final String? birthMonthId;     // e.g., code for month
  final int? birthYear;
  final int? membershipDate;      // day in month (int?)
  final String? membershipMonthId;
  final int? membershipYear;
  final String? membershipMeansId;
  final String? noMinistryReason;
  final String? noMinistryReason2;
  final String? remark;

  Member({
    required this.id,
    required this.name,
    required this.memberCode,
    required this.midibId,
    this.motherName,
    this.genderId,
    this.birthDate,
    this.birthMonthId,
    this.birthYear,
    this.membershipDate,
    this.membershipMonthId,
    this.membershipYear,
    this.membershipMeansId,
    this.noMinistryReason,
    this.noMinistryReason2,
    this.remark,
  });

  /// Helper to read ints that may come as int, num, or String.
  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  factory Member.fromJson(Map<String, dynamic> j) {
    String _s(dynamic v) => v?.toString() ?? '';

    final id          = _s(j['Id'] ?? j['id']);
    final name        = _s(j['Name'] ?? j['name']);
    final memberCode  = _s(j['MemberCode'] ?? j['memberCode']);
    final midibId     = _s(j['MidibId'] ?? j['midibId']);

    return Member(
      id: id,
      name: name,
      memberCode: memberCode,
      midibId: midibId,
      motherName: (j['MotherName'] ?? j['motherName'])?.toString(),
      genderId: (j['GenderId'] ?? j['genderId'])?.toString(),
      birthDate: _asInt(j['BirthDate'] ?? j['birthDate']),
      birthMonthId: (j['BirthMonthId'] ?? j['birthMonthId'])?.toString(),
      birthYear: _asInt(j['BirthYear'] ?? j['birthYear']),
      membershipDate: _asInt(j['MembershipDate'] ?? j['membershipDate']),
      membershipMonthId: (j['MembershipMonthId'] ?? j['membershipMonthId'])?.toString(),
      membershipYear: _asInt(j['MembershipYear'] ?? j['membershipYear']),
      membershipMeansId: (j['MembershipMeansId'] ?? j['membershipMeansId'])?.toString(),
      noMinistryReason: (j['NoMinistryReason'] ?? j['noMinistryReason'])?.toString(),
      noMinistryReason2: (j['NoMinistryReason2'] ?? j['noMinistryReason2'])?.toString(),
      remark: (j['Remark'] ?? j['remark'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        // required
        'Id': id, 'id': id,
        'Name': name, 'name': name,
        'MemberCode': memberCode, 'memberCode': memberCode,
        'MidibId': midibId, 'midibId': midibId,

        // optional (mirror both casings)
        if (motherName != null) ...{'MotherName': motherName, 'motherName': motherName},
        if (genderId != null) ...{'GenderId': genderId, 'genderId': genderId},
        if (birthDate != null) ...{'BirthDate': birthDate, 'birthDate': birthDate},
        if (birthMonthId != null) ...{'BirthMonthId': birthMonthId, 'birthMonthId': birthMonthId},
        if (birthYear != null) ...{'BirthYear': birthYear, 'birthYear': birthYear},
        if (membershipDate != null) ...{'MembershipDate': membershipDate, 'membershipDate': membershipDate},
        if (membershipMonthId != null) ...{'MembershipMonthId': membershipMonthId, 'membershipMonthId': membershipMonthId},
        if (membershipYear != null) ...{'MembershipYear': membershipYear, 'membershipYear': membershipYear},
        if (membershipMeansId != null) ...{'MembershipMeansId': membershipMeansId, 'membershipMeansId': membershipMeansId},
        if (noMinistryReason != null) ...{'NoMinistryReason': noMinistryReason, 'noMinistryReason': noMinistryReason},
        if (noMinistryReason2 != null) ...{'NoMinistryReason2': noMinistryReason2, 'noMinistryReason2': noMinistryReason2},
        if (remark != null) ...{'Remark': remark, 'remark': remark},
      };

  Member copyWith({
    String? id,
    String? name,
    String? memberCode,
    String? midibId,
    String? motherName,
    String? genderId,
    int? birthDate,
    String? birthMonthId,
    int? birthYear,
    int? membershipDate,
    String? membershipMonthId,
    int? membershipYear,
    String? membershipMeansId,
    String? noMinistryReason,
    String? noMinistryReason2,
    String? remark,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      memberCode: memberCode ?? this.memberCode,
      midibId: midibId ?? this.midibId,
      motherName: motherName ?? this.motherName,
      genderId: genderId ?? this.genderId,
      birthDate: birthDate ?? this.birthDate,
      birthMonthId: birthMonthId ?? this.birthMonthId,
      birthYear: birthYear ?? this.birthYear,
      membershipDate: membershipDate ?? this.membershipDate,
      membershipMonthId: membershipMonthId ?? this.membershipMonthId,
      membershipYear: membershipYear ?? this.membershipYear,
      membershipMeansId: membershipMeansId ?? this.membershipMeansId,
      noMinistryReason: noMinistryReason ?? this.noMinistryReason,
      noMinistryReason2: noMinistryReason2 ?? this.noMinistryReason2,
      remark: remark ?? this.remark,
    );
  }
}