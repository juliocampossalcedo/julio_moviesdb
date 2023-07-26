import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/movies_provider.dart';

class MovieSearchDelegate extends SearchDelegate {
  
  @override
  String get searchFieldLabel => 'Buscar pelicula';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton (
        icon: const Icon( Icons.clear),
        onPressed: () => query = ''
      )
    ]; 
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton (
        icon: const Icon( Icons.arrow_back),
        onPressed: () => close(context, null)
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text('buildResults');

  }

  Widget _emptyContainer() {
    return Container(
        child: const Center(
          child: Icon( Icons.movie_creation_outlined, color: Colors.black38, size: 100)
        )
    );
  }  

  @override
  Widget buildSuggestions(BuildContext context) {

    if ( query.isEmpty ) {
      return _emptyContainer();
    }



    final moviesProvider = Provider.of<MoviesProvider>(context, listen:  false);
    moviesProvider.getSuggestionsByQuery(query);

    return StreamBuilder(
      stream: moviesProvider.suggestionsStream,
      builder: ( _ , AsyncSnapshot<List<Movie>> snapshot) {

        if( !snapshot.hasData) return _emptyContainer();

        final movies = snapshot.data!;

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: ( _, int index ) =>  _MovieItem(movie: movies[index])
        );
      },
    );
  }

}

class _MovieItem extends StatelessWidget {

  final Movie movie;

  const _MovieItem({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    movie.heroid = 'search ${movie.id}';
    return ListTile(
      leading: Hero(
        tag: movie.heroid!,
        child: FadeInImage(
          width: 50,
          fit: BoxFit.contain,
          image: NetworkImage(movie.fullPosterImg), 
          placeholder: AssetImage('assets/no-image.jpg'),),
      ),
      title: Text(movie.title) ,
      subtitle: Text(movie.originalTitle),
      onTap: () => {
        Navigator.pushNamed(context, '/details', arguments: movie)
      },
    );
  }
}