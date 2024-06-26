import 'package:favourite_places/screens/map.dart';
import 'package:flutter/material.dart';

import '../models/place.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final Place place;

  String get locationImage {
    final lat = place.location.latitude;
    final lon = place.location.longitude;

    return 'https://maps.geoapify.com/v1/staticmap?style=osm-bright-smooth&width=600&height=300&center=lonlat:$lon,$lat&zoom=14.3497&marker=lonlat:$lon,$lat&apiKey=0809b027f7934f2eb5ba5f7ed7456f83';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
      ),
      body: Stack(
        children: [
          Image.file(
            place.image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => MapScreen(
                            location: place.location,
                            isSelecting: false,
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(locationImage),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black54],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter),
                    ),
                    child: Text(
                      place.location.address,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground),
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
