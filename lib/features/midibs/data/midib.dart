class Midib {
  final String id;
  final String midibCode;
  final String name;
  final String? pastor;
  final String? remark;

  Midib({
    required this.id,
    required this.midibCode,
    required this.name,
    this.pastor,
    this.remark,
  });

  factory Midib.fromJson(Map<String, dynamic> j) => Midib(
        id: j['id']?.toString() ?? '',
        midibCode: j['midibCode']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        pastor: j['pastor']?.toString(),
        remark: j['remark']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'midibCode': midibCode,
        'name': name,
        'pastor': pastor,
        'remark': remark,
      };
}
