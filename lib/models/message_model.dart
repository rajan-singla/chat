class MessageModel {
  MessageModel({
    required this.msg,
    required this.toId,
    required this.read,
    required this.type,
    required this.sent,
    required this.fromId,
  });
  late final String msg;
  late final String toId;
  late final String read;
  late final Type type;
  late final String sent;
  late final String fromId;

  MessageModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    toId = json['toId'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == Type.text.name ? Type.text : Type.image;
    sent = json['sent'].toString();
    fromId = json['fromId'].toString();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['msg'] = msg;
    _data['toId'] = toId;
    _data['read'] = read;
    _data['type'] = type;
    _data['sent'] = sent;
    _data['fromId'] = fromId;
    return _data;
  }
}

enum Type { text, image }
