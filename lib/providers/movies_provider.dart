import 'dart:async';
import 'dart:convert';

import 'package:fluter_peliculas/helpers/debouncer.dart';
import 'package:fluter_peliculas/models/search_response.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../models/models.dart';

class MoviesProvider extends ChangeNotifier {

  final String _apiKey = 'Here goes your api key from the moviedb';
  final String _baseUrl = 'api.themoviedb.org';
  final String _lenguage = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> movieCast = {};

  final debouncer = Debouncer(duration: const Duration( milliseconds: 500 ));
  final StreamController<List<Movie>> _suggestionStreamController = StreamController.broadcast();
  Stream<List<Movie>> get suggestionsStream => this._suggestionStreamController.stream;

  int _popularPage = 0;

  MoviesProvider () {
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    final url =
          Uri.https(_baseUrl, endpoint, {
            'api_key': _apiKey,
            'lenguage': _lenguage,
            'page': page,
          }.map((key, value) => MapEntry(key, value.toString())));

    // Await the http get response, then decode the json-formatted response.
    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {

    final jsonData = _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(await jsonData);
    onDisplayMovies = nowPlayingResponse.results;

    notifyListeners();
  }

  getPopularMovies() async {

    _popularPage++;
    final jsonData = _getJsonData('3/movie/popular', _popularPage);

    final popularResponse = PopularResponse.fromJson( await jsonData);

    popularMovies = [ ...popularMovies, ...popularResponse.results];

    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {

    if ( movieCast.containsKey(movieId) ) return movieCast[movieId]!;

    final jsonData = _getJsonData('3/movie/$movieId/credits');

    final creditsResponse = CreditsResponse.fromJson( await jsonData);

    movieCast[movieId] = creditsResponse.cast;

    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovies ( String query ) async {
    final url =
      Uri.https(_baseUrl,  '3/search/movie', {
        'api_key': _apiKey,
        'lenguage': _lenguage,
        'query': query
      }.map((key, value) => MapEntry(key, value.toString())));

    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);

    return searchResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final results = await searchMovies(value.toString());
      this._suggestionStreamController.add(results);
    };

    final timer = Timer.periodic(Duration(milliseconds: 300), (_) { 
      debouncer.value = searchTerm;
    });

    Future.delayed(Duration( milliseconds: 301)).then( ( _ ) => timer.cancel());
  }
}