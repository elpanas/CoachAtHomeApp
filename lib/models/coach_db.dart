import 'package:coachapp/models/coach.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class CoachDb {
  DatabaseFactory dbFactory = databaseFactoryIo;
  //Database _db;
  final store = intMapStoreFactory.store('coaches'); // percorso di salvataggio

  Future _openDb() async {
    final percorsoDocumenti = await getApplicationDocumentsDirectory();
    final percorsoDb = join(percorsoDocumenti.path, 'coaches.db');
    final db = await dbFactory.openDatabase(percorsoDb);
    return db;
  }

  Future inserisciCoach(Coach coach) async {
    Database db = await _openDb();
    int id = await store.add(db, coach.toMap());
    return id;
  }

  Future<List<Coach>> leggiCoaches() async {
    Database db = await _openDb();
    final finder = Finder(sortOrders: [
      SortOrder('name'),
    ]);
    final coachesSnapshot = await store.find(db, finder: finder);
    return coachesSnapshot.map((element) {
      final coach = Coach.fromMap(element.value);
      coach.idb = element.key;
      return coach;
    }).toList();
  }

  Future eliminaCoach(int idb) async {
    Database db = await _openDb();
    final finder = Finder(filter: Filter.byKey(idb));
    await store.delete(db, finder: finder);
  }
}
