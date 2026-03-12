import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../graphql/queries/current_user.graphql.dart';
import '../components/action_buttons.dart';
import '../components/genre_chip.dart';
import '../components/title_basic_info.dart';
import '../graphql/queries/title.graphql.dart';
import '../screens/not_found_screen.dart';

class ShowTitleScreen extends StatefulWidget {
  const ShowTitleScreen({super.key, required this.id, this.videoId});

  final String id;
  final String? videoId;

  @override
  State<ShowTitleScreen> createState() => _ShowTitleScreenState();
}

class _ShowTitleScreenState extends State<ShowTitleScreen> {
  Country _country = Country.parse('US');

  void _openCountryPicker(List<String> countryFilter) {
    showCountryPicker(
      countryFilter: countryFilter,
      context: context,
      onSelect: (value) {
        setState(() {
          _country = value;
        });
      },
    );
  }

  Widget _getWatchProviders(String titleName, Query$Title$title$watchProviders titleWatchProviders) {
    if (titleWatchProviders.nodes.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Watch in',
                style: GoogleFonts.blackHanSans(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Query$CurrentUser$Widget(
                builder: (result, {fetchMore, refetch}) {
                  final currentUser = result.parsedData?.currentUser;

                  if (currentUser != null) {
                    _country = Country.tryParse(currentUser.identityUser.countryCode) ?? Country.parse('US');
                  }

                  return IconButton(
                    onPressed: () => _openCountryPicker(
                      titleWatchProviders.nodes
                          .map((watchProvider) => watchProvider.countryCodes)
                          .expand((codes) => codes)
                          .toList(),
                    ),
                    icon: Row(
                      children: [
                        Text(_country.flagEmoji, style: const TextStyle(fontSize: 20)),
                        const Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: titleWatchProviders.nodes
                .where((watchProvider) => watchProvider.countryCodes.contains(_country.countryCode))
                .map(
                  (watchProvider) => IconButton(
                    onPressed: () async {},
                    tooltip: watchProvider.watchProvider.name,
                    icon: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: watchProvider.watchProvider.logoImageUrl != null
                          ? Image.network(watchProvider.watchProvider.logoImageUrl.toString(), height: 64)
                          : Text(watchProvider.watchProvider.name),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _getCast(Query$Title$title$cast cast) {
    if (cast.nodes.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          width: double.infinity,
          child: Text(
            'Cast',
            style: GoogleFonts.blackHanSans(
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cast.nodes
                .map(
                  (cast) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 100,
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 40,
                          child: ClipOval(
                            child: cast.person.profileImageUrl != null
                                ? Image.network(
                                    cast.person.profileImageUrl.toString(),
                                    width: 71,
                                    height: 71,
                                    fit: BoxFit.cover,
                                  )
                                : const SizedBox(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cast.person.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Query$Title$Widget(
      options: Options$Query$Title(variables: Variables$Query$Title(id: widget.id)),
      builder: (result, {fetchMore, refetch}) {
        final title = result.parsedData?.title;

        if (title == null) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const NotFoundScreen();
          }
        }

        return Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Color(0xffF3EAF4)),
            backgroundColor: Colors.transparent,
          ),
          backgroundColor: const Color(0xff353535),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 14, bottom: 32, left: 14),
                  child: Column(
                    children: [
                      title.posterImageUrl != null
                          ? Image.network(title.posterImageUrl.toString(), width: 200)
                          : const SizedBox(),
                      const SizedBox(height: 12),
                      ActionButtons(direction: Axis.horizontal, titleId: title.id, videoId: widget.videoId),
                      const SizedBox(height: 12),
                      Text(
                        title.name,
                        style: GoogleFonts.blackHanSans(
                          textStyle: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TitleBasicInfo(
                        releasedOn: title.releasedOn,
                        directorName: title.crew.nodes.firstOrNull?.person.name,
                        runtime: title.runtime,
                        mediaType: title.mediaType,
                      ),
                    ],
                  ),
                ),
                _getWatchProviders(title.name, title.watchProviders),
                Container(
                  margin: const EdgeInsets.only(right: 14, bottom: 32, left: 14),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Synopsis',
                          style: GoogleFonts.blackHanSans(
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title.overview,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
                      ),
                      title.genres.nodes.isNotEmpty
                          ? Container(
                              margin: const EdgeInsets.only(top: 12),
                              width: double.infinity,
                              child: Wrap(
                                runSpacing: 8,
                                children: title.genres.nodes.map((genre) => GenreChip(name: genre.name)).toList(),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
                _getCast(title.cast),
              ],
            ),
          ),
        );
      },
    );
  }
}
