import 'package:fluter_peliculas/models/models.dart';
import 'package:fluter_peliculas/providers/movies_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CastingCards extends StatelessWidget {
  final int movieId;
  const CastingCards( this.movieId );

  @override
  Widget build(BuildContext context) {

    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);

    return FutureBuilder(
      future: moviesProvider.getMovieCast(movieId),
      builder: ( _ , AsyncSnapshot<List<Cast>> snapshot) {
        if ( !snapshot.hasData ) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 150),
            child: CupertinoActivityIndicator(),
          );
        }

        final castD = snapshot.data!;

        return Container(
          margin: const EdgeInsets.only( bottom: 30),
          width: double.infinity,
          height: 180,
          child: ListView.builder(
            itemCount: castD.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: ( _ , int index) =>  _CastCard(cast: castD[index])
          ),
        );
      },
    );
  }
}

class _CastCard extends StatelessWidget {

  final Cast cast;

  const _CastCard({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FadeInImage(
              placeholder: AssetImage('assets/no-image.jpg'),
              image: NetworkImage(cast.fullProfilePath),
              height: 140,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          
          const SizedBox(
            height: 5,
          ),

          Text(
            cast.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}