import "package:fluter_peliculas/models/models.dart";
import "package:flutter/material.dart";

class MoviewSlider extends StatefulWidget {
  final String? title;
  final List<Movie> movies;
  final Function onNextPage;

  const MoviewSlider({
    super.key, 
    this.title, 
    required this.movies,
    required this.onNextPage});

  @override
  State<MoviewSlider> createState() => _MoviewSliderState();
}

class _MoviewSliderState extends State<MoviewSlider> {

  final ScrollController scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels > scrollController.position.maxScrollExtent - 500 ){
        widget.onNextPage();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            if (widget.title != null) 
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text( widget.title!, style: const TextStyle( fontSize: 20, fontWeight: FontWeight.bold))
              ),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.movies.length,
                itemBuilder: ( _ , int index) =>  _MoviePoster(movie: widget.movies[index], heroId: '${widget.title}-${index}-${widget.movies[index].id}')
              ),
            ),
        ],
      ),
    );
  }
}

class _MoviePoster extends StatelessWidget {
  final Movie movie;
  final String heroId;

  const _MoviePoster({super.key, required this.movie, required this.heroId});

  @override
  Widget build(BuildContext context) {
    print('heroId : ' + heroId);
    movie.heroid = heroId;
    return Container(
      width: 130,
      height: 190,
      margin: const EdgeInsets.symmetric( horizontal: 10),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/details', arguments: movie),
            child: Hero(
              tag: this.heroId ,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FadeInImage(
                  placeholder: AssetImage('assets/no-image.jpg'), 
                  image: NetworkImage(movie.fullPosterImg),
                  width: 130,
                  height: 190,
                  fit: BoxFit.cover
                ),
              ),
            ),
          ),
          SizedBox(height: 5), 
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}