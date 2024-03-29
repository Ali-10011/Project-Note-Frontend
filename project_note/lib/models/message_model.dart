class Message {
  //Message Class with Json Encode and Decode Function
  late String id;
  late String username;
  late String datetime;
  late String mediatype;
  late String message;
  late String path;
  late String isUploaded;
  Message(
      {required this.id,
      required this.username,
      required this.datetime,
      required this.mediatype,
      required this.message,
      required this.path,
      required this.isUploaded});

  factory Message.fromJson(Map<dynamic, dynamic> json) {
    return Message(
        id: json['_id'],
        username: json['username'],
        datetime: json['dateTime'],
        mediatype: json['mediatype'],
        message: json['message'],
        path: json['path'],
        isUploaded: json['isUploaded']);
  }

  Map<dynamic, dynamic> toJson() => {
        '_id': id,
        'username': username,
        'dateTime': datetime,
        'mediatype': mediatype,
        'message': message,
        'path': path,
        'isUploaded': isUploaded
      };
}
