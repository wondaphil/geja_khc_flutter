import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert'; // for photo
import 'dart:typed_data';  // for photo
import '../../../../core/api_client.dart';
import '../../../../core/endpoints.dart';

class MemberFullDetailPage extends StatefulWidget {
  final String id;
  const MemberFullDetailPage({super.key, required this.id});

  @override
  State<MemberFullDetailPage> createState() => _MemberFullDetailPageState();
}

class _MemberFullDetailPageState extends State<MemberFullDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ዝርዝር መረጃ'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'መሠረታዊ መረጃ'),
            Tab(text: 'አድራሻ'),
            Tab(text: 'ሥራ/ትምህርት'),
            Tab(text: 'ቤተሰብ'),
            Tab(text: 'ፎቶ'),
            Tab(text: 'አገልግሎት'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MemberInfoTab(memberId: widget.id),
          _AddressInfoTab(memberId: widget.id),
          _EducationAndJobInfoTab(memberId: widget.id),
          _FamilyInfoTab(memberId: widget.id),
          _MemberPhotoTab(memberId: widget.id),
		  _MemberMinistryTab(memberId: widget.id),
          //const _PlaceholderTab(title: 'የአገልግሎት መረጃ'),
        ],
      ),
    );
  }
}

/// --- MEMBER INFO TAB ----------------------------------------------------

class _MemberInfoTab extends StatefulWidget {
  final String memberId;
  const _MemberInfoTab({required this.memberId});

  @override
  State<_MemberInfoTab> createState() => _MemberInfoTabState();
}

class _MemberInfoTabState extends State<_MemberInfoTab>
    with AutomaticKeepAliveClientMixin<_MemberInfoTab> {
  late Future<Map<String, dynamic>> _fullDetailFuture;

  @override
  void initState() {
    super.initState();
    _fullDetailFuture = _fetchFullDetail();
  }
  
  @override
  bool get wantKeepAlive => true;

  Future<Map<String, dynamic>> _fetchFullDetail() async {
    final dio = makeDio();

    print('--- Fetching full detail for memberId=${widget.memberId} ---');

    // 1️⃣ Get Member
    final memberRes = await dio.post(
      ApiPaths.getMember,
      data: {
        'Id': widget.memberId,
        'id': widget.memberId,
        'Name': '',
        'name': '',
        'MemberCode': '',
        'memberCode': '',
      },
      options: Options(validateStatus: (s) => true),
    );

    print('GetMember → ${memberRes.statusCode} ${memberRes.data}');
    final member = Map<String, dynamic>.from(memberRes.data);

    print('Member keys: ${member.keys}');
    print('GenderId = ${member['genderId']}');
    print('MidibId = ${member['midibId']}');
    print('NoMinistryReason = ${member['noMinistryReason']}');
    print('NoMinistryReason2 = ${member['noMinistryReason2']}');

    // 2️⃣ Get Gender Name
    String? genderName;
    final genderId = member['genderId'];
    if (genderId != null && genderId.toString().isNotEmpty) {
      final genderRes = await dio.post(
        ApiPaths.getGender,
        data: {
          'Id': genderId,
          'id': genderId,
          'Name': '',
          'name': '',
        },
        options: Options(validateStatus: (s) => true),
      );
      print('GetGender → ${genderRes.statusCode} ${genderRes.data}');
      if (genderRes.data is Map) {
        final data = Map<String, dynamic>.from(genderRes.data);
        genderName = data['Name'] ?? data['name'];
      }
    }

    // 3️⃣ Get Midib Name
    String? midibName;
    final midibId = member['midibId'];
    if (midibId != null && midibId.toString().isNotEmpty) {
      final midibRes = await dio.post(
        ApiPaths.getMidib,
        data: {
          'Id': midibId,
          'id': midibId,
          'MidibCode': '',
          'midibCode': '',
          'Name': '',
          'name': '',
        },
        options: Options(validateStatus: (s) => true),
      );
      print('GetMidib → ${midibRes.statusCode} ${midibRes.data}');
      if (midibRes.data is Map) {
        final data = Map<String, dynamic>.from(midibRes.data);
        midibName = data['Name'] ?? data['name'];
      }
    }

    // 4️⃣ Get Membership Means
    Map<String, dynamic>? membershipMeans;
    final meansId = member['membershipMeansId'];
    if (meansId != null && meansId.toString().isNotEmpty) {
      final meansRes = await dio.post(
        ApiPaths.getMembershipMeans,
        data: {
          'Id': meansId,
          'id': meansId,
          'Name': '',
          'name': '',
        },
        options: Options(validateStatus: (s) => true),
      );
      print('GetMembershipMeans → ${meansRes.statusCode} ${meansRes.data}');
      membershipMeans = Map<String, dynamic>.from(meansRes.data);
    }

    // 5️⃣ Get Birth Month
    String? birthMonthName;
    final birthMonthId = member['birthMonthId'];
    if (birthMonthId != null && birthMonthId.toString().isNotEmpty) {
      final birthMonthRes = await dio.post(
        ApiPaths.getMonth,
        data: {
          'Id': birthMonthId,
          'id': birthMonthId,
          'Name': '',
          'BirthMonthId': birthMonthId,
          'MembershipMonthId': '',
        },
        options: Options(validateStatus: (s) => true),
      );
      print('BirthMonth → ${birthMonthRes.statusCode} ${birthMonthRes.data}');
      if (birthMonthRes.data is Map) {
        final data = Map<String, dynamic>.from(birthMonthRes.data);
        birthMonthName = data['Name'] ?? data['name'];
      }
    }

    // 6️⃣ Get Membership Month
    String? membershipMonthName;
    final membershipMonthId = member['membershipMonthId'];
    if (membershipMonthId != null && membershipMonthId.toString().isNotEmpty) {
      final membershipMonthRes = await dio.post(
        ApiPaths.getMonth,
        data: {
          'Id': membershipMonthId,
          'id': membershipMonthId,
          'Name': '',
          'BirthMonthId': '',
          'MembershipMonthId': membershipMonthId,
        },
        options: Options(validateStatus: (s) => true),
      );
      print('MembershipMonth → ${membershipMonthRes.statusCode} ${membershipMonthRes.data}');
      if (membershipMonthRes.data is Map) {
        final data = Map<String, dynamic>.from(membershipMonthRes.data);
        membershipMonthName = data['Name'] ?? data['name'];
      }
    }

    // 7️⃣ Return everything combined
    return {
      'member': member,
      'genderName': genderName,
      'midibName': midibName,
      'membershipMeans': membershipMeans,
      'birthMonthName': birthMonthName,
      'membershipMonthName': membershipMonthName,
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
	
	return FutureBuilder<Map<String, dynamic>>(
      future: _fullDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('መረጃ አልተገኘም'));
        }

        final member = snapshot.data!['member'] as Map<String, dynamic>;
        final gender = snapshot.data!['genderName'] as String?;
        final midib = snapshot.data!['midibName'] as String?;
        final means = snapshot.data!['membershipMeans'] as Map<String, dynamic>?;
        final birthMonth = snapshot.data!['birthMonthName'] as String?;
        final membershipMonth = snapshot.data!['membershipMonthName'] as String?;

        String s(Object? v) => v?.toString().isNotEmpty == true ? v.toString() : '—';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _row('ስም', s(member['name'])),
            _row('የአባል ኮድ', s(member['memberCode'])),
            _row('ፆታ', s(gender)),
            _row('የእናት ስም', s(member['motherName'])),
            _row('ምድብ', s(midib)),
            _row(
              'የትውልድ ቀን',
              '${birthMonth ?? "—"} ${s(member['birthDate'])} / ${s(member['birthYear'])}',
            ),
            _row(
              'የአባልነት ጊዜ',
              '${membershipMonth ?? "—"} ${s(member['membershipDate'])} / ${s(member['membershipYear'])}',
            ),
            _row('የአባልነት መንገድ', s(means?['Name'] ?? means?['name'] ?? '—')),
            _row('አገልግሎት ከሌለ ምክንያት 1', s(member['noMinistryReason'] ?? '—')),
            _row('አገልግሎት ከሌለ ምክንያት 2', s(member['noMinistryReason2'] ?? '—')),
          ],
        );
      },
    );
  }
}

/// --- ADDRESS INFO TAB ----------------------------------------------------

class _AddressInfoTab extends StatefulWidget {
  final String memberId;
  const _AddressInfoTab({required this.memberId});

  @override
  State<_AddressInfoTab> createState() => _AddressInfoTabState();
}

class _AddressInfoTabState extends State<_AddressInfoTab>
    with AutomaticKeepAliveClientMixin<_AddressInfoTab> {
  late Future<Map<String, dynamic>> _addressFuture;

  @override
  void initState() {
    super.initState();
    _addressFuture = _fetchAddressInfo();
  }

  @override
  bool get wantKeepAlive => true;

  Future<Map<String, dynamic>> _fetchAddressInfo() async {
    final dio = makeDio();

    print('--- Fetching address info for memberId=${widget.memberId} ---');

    // 1️⃣ Get AddressInfo by Member
    final res = await dio.post(
      ApiPaths.getAddressInfoByMember,
      data: {
        'Id': widget.memberId,
        'id': widget.memberId,
        'Name': '',
        'name': '',
        'MemberCode': '',
        'memberCode': '',
      },
      options: Options(validateStatus: (s) => true),
    );

    print('GetAddressInfo → ${res.statusCode} ${res.data}');
    if (res.statusCode != 200 || res.data == null) {
      throw Exception('Failed to load AddressInfo');
    }

    final address = Map<String, dynamic>.from(res.data);
    String? subcityName;
    String? houseOwnershipName;

    // 2️⃣ Fetch Subcity name if exists
    final subcityId = address['subcityId'];
    if (subcityId != null && subcityId.toString().isNotEmpty) {
      final subRes = await dio.post(
        ApiPaths.getSubcity,
        data: {
          'Id': subcityId,
          'id': subcityId,
          'Name': '',
          'name': '',
        },
        options: Options(validateStatus: (s) => true),
      );
      print('GetSubcity → ${subRes.statusCode} ${subRes.data}');
      if (subRes.data is Map) {
        final data = Map<String, dynamic>.from(subRes.data);
        subcityName = data['Name'] ?? data['name'];
      }
    }

    // 3️⃣ Fetch HouseOwnership name if exists
    final ownershipId = address['houseOwnershipId'];
    if (ownershipId != null && ownershipId.toString().isNotEmpty) {
      final houseRes = await dio.post(
        ApiPaths.getHouseOwnership,
        data: {
          'Id': ownershipId,
          'id': ownershipId,
          'Name': '',
          'name': '',
        },
        options: Options(validateStatus: (s) => true),
      );
      print('GetHouseOwnership → ${houseRes.statusCode} ${houseRes.data}');
      if (houseRes.data is Map) {
        final data = Map<String, dynamic>.from(houseRes.data);
        houseOwnershipName = data['Name'] ?? data['name'];
      }
    }

    return {
      'address': address,
      'subcityName': subcityName,
      'houseOwnershipName': houseOwnershipName,
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<Map<String, dynamic>>(
      future: _addressFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('መረጃ አልተገኘም'));
        }

        final address = snapshot.data!['address'] as Map<String, dynamic>;
        final subcity = snapshot.data!['subcityName'] as String?;
        final houseOwnership = snapshot.data!['houseOwnershipName'] as String?;

        String s(Object? v) =>
            v?.toString().isNotEmpty == true ? v.toString() : '—';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _row('ክፍለ ከተማ', s(subcity)),
            _row('ወረዳ', s(address['woreda'])),
            _row('ቀበሌ', s(address['kebele'])),
            _row('የቤት ቁጥር', s(address['houseNo'])),
            _row('የቤት ባለቤትነት', s(houseOwnership)),
            _row('የቤት ስልክ', s(address['homePhoneNo'])),
            _row('የቢሮ ስልክ', s(address['officePhoneNo'])),
            _row('የተንቀሳቃሽ ስልክ', s(address['mobilePhoneNo'])),
            _row('ኢሜል', s(address['email'])),
          ],
        );
      },
    );
  }
}

/// --- EDUCATION AND JOB INFO TAB ----------------------------------------------------

class _EducationAndJobInfoTab extends StatefulWidget {
  final String memberId;
  const _EducationAndJobInfoTab({required this.memberId});

  @override
  State<_EducationAndJobInfoTab> createState() => _EducationAndJobInfoTabState();
}

class _EducationAndJobInfoTabState extends State<_EducationAndJobInfoTab>
    with AutomaticKeepAliveClientMixin<_EducationAndJobInfoTab> {
  late Future<Map<String, dynamic>> _eduJobFuture;

  @override
  void initState() {
    super.initState();
    _eduJobFuture = _fetchEducationAndJobInfo();
  }

  @override
  bool get wantKeepAlive => true;

  Future<Map<String, dynamic>> _fetchEducationAndJobInfo() async {
    final dio = makeDio();

    print('--- Fetching EducationAndJobInfo for memberId=${widget.memberId} ---');

    // 1️⃣ Get EducationAndJobInfo by Member
    final res = await dio.post(
      ApiPaths.getEducationAndJobInfoByMember,
      data: {
        'Id': widget.memberId,
        'id': widget.memberId,
        'Name': '',
        'name': '',
        'MemberCode': '',
        'memberCode': '',
      },
      options: Options(validateStatus: (s) => true),
    );

    print('GetEducationAndJobInfoByMember → ${res.statusCode} ${res.data}');
    if (res.statusCode != 200 || res.data == null) {
      throw Exception('Failed to load EducationAndJobInfo');
    }

    final info = Map<String, dynamic>.from(res.data);

    String? educationLevelName;
    String? fieldOfStudyName;
    String? jobName;
    String? jobTypeName;

    // 2️⃣ Fetch Education Level
    final educationId = info['educationLevelId'];
    if (educationId != null && educationId.toString().isNotEmpty) {
      final eduRes = await dio.post(
        ApiPaths.getEducationLevel,
        data: {
          'Id': educationId,
          'id': educationId,
          'Name': '',
          'name': '',
        },
        options: Options(validateStatus: (s) => true),
      );
      print('GetEducationLevel → ${eduRes.statusCode} ${eduRes.data}');
      if (eduRes.data is Map) {
        final data = Map<String, dynamic>.from(eduRes.data);
        educationLevelName = data['Name'] ?? data['name'];
      }
    }

    // 3️⃣ Fetch Field of Study
    final fieldId = info['fieldOfStudyId'];
    if (fieldId != null && fieldId.toString().isNotEmpty) {
      final fieldRes = await dio.post(
        ApiPaths.getFieldOfStudy,
        data: {
          'Id': fieldId,
          'id': fieldId,
          'Name': '',
          'name': '',
        },
        options: Options(validateStatus: (s) => true),
      );
      print('GetFieldOfStudy → ${fieldRes.statusCode} ${fieldRes.data}');
      if (fieldRes.data is Map) {
        final data = Map<String, dynamic>.from(fieldRes.data);
        fieldOfStudyName = data['Name'] ?? data['name'];
      }
    }

    // 4️⃣ Fetch Job
    final jobId = info['jobId'];
    if (jobId != null && jobId.toString().isNotEmpty) {
      final jobRes = await dio.post(
        ApiPaths.getJob,
        data: {
          'Id': jobId,
          'id': jobId,
          'Name': '',
          'name': '',
        },
        options: Options(validateStatus: (s) => true),
      );
      print('GetJob → ${jobRes.statusCode} ${jobRes.data}');
      if (jobRes.data is Map) {
        final data = Map<String, dynamic>.from(jobRes.data);
        jobName = data['Name'] ?? data['name'];
      }
    }

    // 5️⃣ Fetch Job Type
    final jobTypeId = info['jobTypeId'];
    if (jobTypeId != null && jobTypeId.toString().isNotEmpty) {
      final jobTypeRes = await dio.post(
        ApiPaths.getJobType,
        data: {
          'Id': jobTypeId,
          'id': jobTypeId,
          'Name': '',
          'name': '',
        },
        options: Options(validateStatus: (s) => true),
      );
      print('GetJobType → ${jobTypeRes.statusCode} ${jobTypeRes.data}');
      if (jobTypeRes.data is Map) {
        final data = Map<String, dynamic>.from(jobTypeRes.data);
        jobTypeName = data['Name'] ?? data['name'];
      }
    }

    return {
      'info': info,
      'educationLevelName': educationLevelName,
      'fieldOfStudyName': fieldOfStudyName,
      'jobName': jobName,
      'jobTypeName': jobTypeName,
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<Map<String, dynamic>>(
      future: _eduJobFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('መረጃ አልተገኘም'));
        }

        final info = snapshot.data!['info'] as Map<String, dynamic>;
        final edu = snapshot.data!['educationLevelName'] as String?;
        final field = snapshot.data!['fieldOfStudyName'] as String?;
        final job = snapshot.data!['jobName'] as String?;
        final jobType = snapshot.data!['jobTypeName'] as String?;

        String s(Object? v) =>
            v?.toString().isNotEmpty == true ? v.toString() : '—';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _row('የትምህርት ደረጃ', s(edu)),
            _row('የትምህርት መስክ', s(field)),
            _row('ሥራ', s(job)),
            _row('የሥራ አይነት', s(jobType)),
          ],
        );
      },
    );
  }
}

/// --- FAMILY INFO TAB ----------------------------------------------------

class _FamilyInfoTab extends StatefulWidget {
  final String memberId;
  const _FamilyInfoTab({required this.memberId});

  @override
  State<_FamilyInfoTab> createState() => _FamilyInfoTabState();
}

class _FamilyInfoTabState extends State<_FamilyInfoTab>
    with AutomaticKeepAliveClientMixin<_FamilyInfoTab> {
  late Future<Map<String, dynamic>> _familyFuture;

  @override
  void initState() {
    super.initState();
    _familyFuture = _fetchFamilyInfo();
  }

  @override
  bool get wantKeepAlive => true;

  Future<Map<String, dynamic>> _fetchFamilyInfo() async {
    final dio = makeDio();

    print('--- Fetching FamilyInfo for memberId=${widget.memberId} ---');

    // 1️⃣ Get FamilyInfo by Member
    final res = await dio.post(
      ApiPaths.getFamilyInfoByMember,
      data: {
        'Id': widget.memberId,
        'id': widget.memberId,
        'Name': '',
        'name': '',
        'MemberCode': '',
        'memberCode': '',
      },
      options: Options(validateStatus: (s) => true),
    );

    print('GetFamilyInfoByMember → ${res.statusCode} ${res.data}');
    if (res.statusCode != 200 || res.data == null) {
      throw Exception('Failed to load FamilyInfo');
    }

    final info = Map<String, dynamic>.from(res.data);

    // 2️⃣ Fetch Marital Status name
    String? maritalStatusName;
    final maritalId = info['maritalStatusId'];
    if (maritalId != null && maritalId.toString().isNotEmpty) {
      final maritalRes = await dio.post(
        ApiPaths.getMaritalStatus,
        data: {
          'Id': maritalId,
          'id': maritalId,
          'Name': '',
          'name': '',
        },
        options: Options(validateStatus: (s) => true),
      );
      print('GetMaritalStatus → ${maritalRes.statusCode} ${maritalRes.data}');
      if (maritalRes.data is Map) {
        final data = Map<String, dynamic>.from(maritalRes.data);
        maritalStatusName = data['Name'] ?? data['name'];
      }
    }

    return {
      'info': info,
      'maritalStatusName': maritalStatusName,
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<Map<String, dynamic>>(
      future: _familyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('መረጃ አልተገኘም'));
        }

        final info = snapshot.data!['info'] as Map<String, dynamic>;
        final marital = snapshot.data!['maritalStatusName'] as String?;

        String s(Object? v) =>
            v?.toString().isNotEmpty == true ? v.toString() : '—';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _row('የጋብቻ ሁኔታ', s(marital)),
            _row('የትዳር አጋር', s(info['spouseName'])),
            _row('የጋብቻ ዘመን', s(info['marriageYear'])),
            const SizedBox(height: 10),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            const Text('የወንድ ልጆች ብዛት',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            _row('ጠቅላላ', s(info['noOfSons'])),
            _row('ዕድሜ 1–5', s(info['noOfSons1to5'])),
            _row('ዕድሜ 6–12', s(info['noOfSons6to12'])),
            _row('ዕድሜ 13–20', s(info['noOfSons13to20'])),
            _row('ዕድሜ ከ20 በላይ', s(info['noOfSonsAbove20'])),
            const SizedBox(height: 10),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            const Text('የሴት ልጆች ብዛት',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            _row('ጠቅላላ', s(info['noOfDaughters'])),
            _row('ዕድሜ 1–5', s(info['noOfDaughters1to5'])),
            _row('ዕድሜ 6–12', s(info['noOfDaughters6to12'])),
            _row('ዕድሜ 13–20', s(info['noOfDaughters13to20'])),
            _row('ዕድሜ ከ20 በላይ', s(info['noOfDaughtersAbove20'])),
          ],
        );
      },
    );
  }
}

/// --- MEMBER PHOTO TAB ----------------------------------------------------

class _MemberPhotoTab extends StatefulWidget {
  final String memberId;
  const _MemberPhotoTab({required this.memberId});

  @override
  State<_MemberPhotoTab> createState() => _MemberPhotoTabState();
}

class _MemberPhotoTabState extends State<_MemberPhotoTab>
    with AutomaticKeepAliveClientMixin<_MemberPhotoTab> {
  late Future<Map<String, dynamic>> _photoFuture;

  @override
  void initState() {
    super.initState();
    _photoFuture = _fetchMemberPhoto();
  }

  @override
  bool get wantKeepAlive => true;

  Future<Map<String, dynamic>> _fetchMemberPhoto() async {
    final dio = makeDio();

    print('--- Fetching MemberPhoto for memberId=${widget.memberId} ---');

    final res = await dio.post(
      ApiPaths.getMemberPhotoByMember,
      data: {
        'Id': widget.memberId,
        'id': widget.memberId,
        'Name': '',
        'name': '',
        'MemberCode': '',
        'memberCode': '',
      },
      options: Options(validateStatus: (s) => true),
    );

    print('GetMemberPhotoByMember → ${res.statusCode}');
    if (res.statusCode != 200 || res.data == null) {
      throw Exception('Failed to load MemberPhoto');
    }

    final data = Map<String, dynamic>.from(res.data);
    final photoBase64 = data['Photo'] ?? data['photo'];
    final remark = data['Remark'] ?? data['remark'];

    Uint8List? imageBytes;
    if (photoBase64 != null && photoBase64.toString().isNotEmpty) {
      try {
        imageBytes = base64Decode(photoBase64.toString());
      } catch (e) {
        print('Error decoding photo: $e');
      }
    }

    return {
      'imageBytes': imageBytes,
      'remark': remark,
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<Map<String, dynamic>>(
      future: _photoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('ፎቶ አልተገኘም'));
        }

        final imageBytes = snapshot.data!['imageBytes'] as Uint8List?;
        final remark = snapshot.data!['remark'] as String?;

        if (imageBytes == null) {
          return const Center(child: Text('ፎቶ አልተገኘም'));
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 400,
                ),
              ),
              const SizedBox(height: 16),
              if (remark != null && remark.trim().isNotEmpty)
                Text(
                  remark,
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// --- MEMBER MINISTRIES TAB ----------------------------------------------------

class _MemberMinistryTab extends StatefulWidget {
  final String memberId;
  const _MemberMinistryTab({required this.memberId});

  @override
  State<_MemberMinistryTab> createState() => _MemberMinistryTabState();
}

class _MemberMinistryTabState extends State<_MemberMinistryTab>
    with AutomaticKeepAliveClientMixin<_MemberMinistryTab> {
  late Future<List<Map<String, dynamic>>> _ministriesFuture;

  @override
  void initState() {
    super.initState();
    _ministriesFuture = _fetchMemberMinistries();
  }

  @override
  bool get wantKeepAlive => true;

  Future<List<Map<String, dynamic>>> _fetchMemberMinistries() async {
    final dio = makeDio();

    print('--- Fetching MemberMinistries for memberId=${widget.memberId} ---');

    // 1️⃣ Get all ministries for this member
    final res = await dio.post(
      ApiPaths.getMemberMinistriesByMember,
      data: {
        'Id': widget.memberId,
        'id': widget.memberId,
        'Name': '',
        'name': '',
        'MemberCode': '',
        'memberCode': '',
      },
      options: Options(validateStatus: (s) => true),
    );

    print('GetMemberMinistriesByMember → ${res.statusCode}');
    if (res.statusCode != 200 || res.data == null) {
      throw Exception('Failed to load MemberMinistries');
    }

    // Expecting a list of MemberMinistryDto
    final List<dynamic> listData =
        res.data is List ? res.data : [res.data]; // ensure it's a list

    final ministries = <Map<String, dynamic>>[];

    for (var item in listData) {
      final m = Map<String, dynamic>.from(item);

      String? ministryTypeName;
      String? ministryName;

      // 2️⃣ Fetch MinistryType name
      final typeId = m['ministryTypeId'];
      if (typeId != null && typeId.toString().isNotEmpty) {
        final typeRes = await dio.post(
          ApiPaths.getMinistryType,
          data: {
            'Id': typeId,
            'id': typeId,
            'Name': '',
            'name': '',
          },
          options: Options(validateStatus: (s) => true),
        );
        print('GetMinistryType → ${typeRes.statusCode} ${typeRes.data}');
        if (typeRes.data is Map) {
          final data = Map<String, dynamic>.from(typeRes.data);
          ministryTypeName = data['Name'] ?? data['name'];
        }
      }

      // 3️⃣ Fetch Ministry name
      final ministryId = m['ministryId'];
      if (ministryId != null && ministryId.toString().isNotEmpty) {
        final minRes = await dio.post(
          ApiPaths.getMinistry,
          data: {
            'Id': ministryId,
            'id': ministryId,
            'Name': '',
            'name': '',
          },
          options: Options(validateStatus: (s) => true),
        );
        print('GetMinistry → ${minRes.statusCode} ${minRes.data}');
        if (minRes.data is Map) {
          final data = Map<String, dynamic>.from(minRes.data);
          ministryName = data['Name'] ?? data['name'];
        }
      }

      ministries.add({
        'ministryType': ministryTypeName ?? '—',
        'ministry': ministryName ?? '—',
      });
    }

    return ministries;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _ministriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('አገልግሎት መረጃ አልተገኘም'));
        }

        final ministries = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ministries.length,
          itemBuilder: (context, i) {
            final m = ministries[i];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.church_outlined, size: 32),
                title: Text(
                  m['ministry'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  m['ministryType'],
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// --- PLACEHOLDER TABS ----------------------------------------------------

class _PlaceholderTab extends StatelessWidget {
  final String title;
  const _PlaceholderTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

/// --- COMMON ROW HELPER ---------------------------------------------------

Widget _row(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Text(value, style: const TextStyle(fontSize: 15)),
        ),
      ],
    ),
  );
}