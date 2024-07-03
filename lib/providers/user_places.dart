import "dart:io";

import "package:favourite_places/models/place.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path_provider/path_provider.dart" as syspaths;
import "package:path/path.dart" as path;
import 'package:sqflite/sqflite.dart' as sql;
import "package:sqflite/sqlite_api.dart";

Future<Database> _getDatabase() async {
  // get the path for the db
  final dbPath = await sql.getDatabasesPath();

  // await sql.deleteDatabase(path.join(dbPath, 'places.db'));

//
// create the db with the name of the db
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE  IF NOT EXISTS user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)');
    },
    version: 1,
  );

  // await db.execute("DROP TABLE IF EXISTS tableName");

  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  Future<void> loadPlaces() async {
    try {
      // get the db
      final db = await _getDatabase();

      // query the collection
      final data = await db.query('user_places');

      final places = data
          .map(
            (row) => Place(
              id: row['id'] as String,
              title: row['title'] as String,
              image: File(row['image'] as String),
              location: PlaceLocation(
                latitude: row['lat'] as double?,
                longitude: row['lng'] as double?,
                address: row['address'] as String,
              ), // PlaceLocation
            ),
          )
          .toList();

      // print(places[0].image.path);

      state = places;
    } catch (err) {
      print(err);
    }
  }

  void addPlace(String title, File image, PlaceLocation location) async {
    // get the app doc directory
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    // print('app dir path');
    // print(appDir.path);
    // print(appDir.path.split('tmp'));

    // print('image path');
    // print(image.path);
    final filename = path.basename(image.path);
    // print('filename');
    // print(filename);

    final copiedImage = await image.copy('${appDir.path}/$filename');
    // print('copied img');
    // print(copiedImage);
    // final fileLength = await copiedImage.length();
    // print('File length: $fileLength bytes');

    final newPlace =
        Place(title: title, image: copiedImage, location: location);

    final db = await _getDatabase();

    // print(newPlace.image.path);

// insert the table with its table name and items into the db
    db.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'lat': newPlace.location.latitude,
      'lng': newPlace.location.longitude,
      'address': newPlace.location.address,
    });

    state = [newPlace, ...state];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
        (ref) => UserPlacesNotifier());

// shared preferences is an alternative to sqflite
