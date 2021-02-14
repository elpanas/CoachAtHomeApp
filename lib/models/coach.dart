class Coach {
  int idb;
  String id, name, mail, phone, facebook, instagram, linkedin, web, bio, city;
  bool im;

  Coach(this.id, this.name, this.mail, this.phone, this.facebook,
      this.instagram, this.linkedin, this.web, this.bio, this.im, this.city);

  Coach.fromJson(Map<String, dynamic> jsondata) {
    this.id = jsondata['_id'];
    this.name = jsondata['name'];
    this.mail = jsondata['mail'];
    this.phone = jsondata['phone'];
    this.facebook = jsondata['facebook'];
    this.instagram = jsondata['instagram'];
    this.linkedin = jsondata['linkedin'];
    this.web = jsondata['web'];
    this.bio = jsondata['bio'];
    this.im = jsondata['instant_msg'];
    this.city = jsondata['city'];
  }

  Coach.toDb(this.id, this.name, this.city);

  Map<String, dynamic> toMap() {
    return {
      'idb': idb ?? null,
      'id': id,
      'name': name,
      'city': city,
    };
  }

  Coach.fromMap(Map<String, dynamic> map) {
    idb = map['idb'];
    id = map['id'];
    name = map['name'];
    city = map['city'];
  }
}
