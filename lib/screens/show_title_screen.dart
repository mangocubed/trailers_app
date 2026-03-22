import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trailers/graphql/queries/title_watch_providers.graphql.dart';

import '../components/current_user.dart';
import '../components/action_buttons.dart';
import '../components/genre_chip.dart';
import '../components/title_basic_info.dart';
import '../graphql/queries/title.graphql.dart';
import '../screens/not_found_screen.dart';
import '../utils.dart';

class ShowTitleScreen extends StatefulWidget {
  const ShowTitleScreen({super.key, required this.id});

  final String id;

  @override
  State<ShowTitleScreen> createState() => _ShowTitleScreenState();
}

class _ShowTitleScreenState extends State<ShowTitleScreen> {
  String? _countryCode;

  Country get _country => Country.parse(_countryCode ?? 'US');

  Widget _getWatchProviders(Query$Title$title title) {
    final textTheme = TextTheme.of(context);

    return CurrentUser(
      builder: (user, {refetch}) {
        _countryCode ??= user?.identityUser.countryCode;

        return Query$TitleWatchProviders$Widget(
          options: Options$Query$TitleWatchProviders(
            variables: Variables$Query$TitleWatchProviders(id: title.id, countryCode: _country.countryCode),
          ),
          builder: (result, {fetchMore, refetch}) {
            final nodes = result.parsedData?.title?.watchProviders.nodes;
            late final Widget watchProviders;

            if (nodes != null && nodes.isNotEmpty) {
              watchProviders = Row(
                children: nodes
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
              );
            } else if (result.isLoading) {
              watchProviders = const Center(child: CircularProgressIndicator());
            } else {
              watchProviders = Center(child: Text('No services found in this country 🙁', style: textTheme.bodySmall));
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
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => showCountryPicker(
                          countryFilter: title.watchProviders.nodes
                              .map((watchProvider) => watchProvider.countryCodes)
                              .expand((codes) => codes)
                              .toList(),

                          context: context,
                          onSelect: (value) {
                            setState(() {
                              _countryCode = value.countryCode;
                            });
                            refetch?.call();
                          },
                        ),
                        icon: Row(
                          children: [
                            Text(_country.flagEmoji, style: const TextStyle(fontSize: 20)),
                            const Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  width: double.infinity,
                  child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: watchProviders),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        );
      },
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
                fontSize: 20,
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

        createUserTitleTie(context, title);

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
                      ActionButtons(direction: Axis.horizontal, titleId: title.id),
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
                _getWatchProviders(title),
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
                              fontSize: 20,
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
