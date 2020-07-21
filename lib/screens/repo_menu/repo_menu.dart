import 'package:flutter/material.dart';
import 'package:jp_flashcard/models/repo_info.dart';
import 'package:jp_flashcard/screens/repo_menu/repo_card.dart';
import 'package:jp_flashcard/screens/repo_menu/sort_filter.dart';
import 'package:jp_flashcard/screens/repo_menu/tag_filter.dart';
import 'package:jp_flashcard/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RepoMenu extends StatefulWidget {
  @override
  _RepoMenuState createState() => _RepoMenuState();
}

class _RepoMenuState extends State<RepoMenu> {
  final Map _displayedStringZHTW = {
    'repository': '學習集',
    'sort by': '排序依據',
    'increasing': '標題: A 到 Z',
    'decreasing': '標題: Z 到 A',
  };

  final TextStyle h2TextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  bool displayTag = true;
  SortBy sortBy = SortBy.increasing;
  Icon displayTagButtonIcon = Icon(Icons.label_outline);

  List<RepoCard> repoList = [];
  Future<bool> initRepoList() async {
    repoList.clear();
    await getPersistData();
    await DBManager.db.getRepoList().then((repoInfoList) async {
      for (final repoInfo in repoInfoList) {
        String title = repoInfo['title'];
        int id = repoInfo['repoId'];
        int numMemorized = repoInfo['numMemorized'];
        int numTotal = repoInfo['numTotal'];

        bool filterPassed = false;
        if (filterTagList.isEmpty) {
          filterPassed = true;
        }

        //Get tag list of the repo and validate
        List<String> tagList = [];
        await DBManager.db.getTagListOfRepo(id).then((resultTagList) {
          for (final tag in resultTagList) {
            tagList.add(tag['tag']);
            for (final filterTag in filterTagList) {
              if (filterTag == tag['tag'] || filterPassed) {
                filterPassed = true;
                break;
              }
            }
          }
          tagList.sort();
        });

        if (!filterPassed) {
          continue;
        }

        RepoInfo newRepoInfo = RepoInfo(
          title: title,
          repoId: id,
          numMemorized: numMemorized,
          numTotal: numTotal,
          tagList: tagList,
        );

        repoList.add(RepoCard(
          info: newRepoInfo,
          displayTag: displayTag,
        ));

        if (sortBy == SortBy.increasing) {
          repoList.sort((a, b) {
            return a.info.title.compareTo(b.info.title);
          });
        } else if (sortBy == SortBy.decreasing) {
          repoList.sort((a, b) {
            return b.info.title.compareTo(a.info.title);
          });
        }
      }
    });
    return true;
  }

  List<String> filterTagList = [];

  var persistData;
  Future<void> getPersistData() async {
    persistData = await SharedPreferences.getInstance();

    displayTag = persistData.getBool('displayTag') ?? false;
    if (displayTag) displayTagButtonIcon = Icon(Icons.label);

    String sortByString = persistData.getString('sortBy') ?? 'increasing';
    if (sortByString == 'increasing') {
      sortBy = SortBy.increasing;
    } else if (sortByString == 'decreasing') {
      sortBy = SortBy.decreasing;
    }
    filterTagList = persistData.getStringList('filterTagList') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    getPersistData();
    return FutureBuilder<bool>(
        future: initRepoList(),
        builder: (context, snapshot) {
          return Container(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppBar(
                title: Text(_displayedStringZHTW['repository']),
                actions: <Widget>[
                  IconButton(
                      icon: displayTagButtonIcon,
                      onPressed: () {
                        setState(() {
                          if (!displayTag) {
                            displayTagButtonIcon = Icon(Icons.label);

                            displayTag = true;
                          } else {
                            displayTagButtonIcon = Icon(Icons.label_outline);
                            displayTag = false;
                          }
                          persistData.setBool('displayTag', displayTag);
                        });
                      }),
                  IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: () async {
                        TagFilter tagFilter =
                            TagFilter(filterTagList: filterTagList);
                        await tagFilter.tagFilterDialog(context);
                        setState(() {
                          filterTagList = tagFilter.filterTagList;
                          persistData.setStringList(
                              'filterTagList', filterTagList);
                        });
                      }),
                  PopupMenuButton<String>(
                    offset: Offset(0, 250),
                    tooltip: _displayedStringZHTW['sort by'] ?? '',
                    icon: Icon(Icons.sort),
                    onSelected: (String result) {
                      setState(() {
                        if (result == 'increasing') {
                          sortBy = SortBy.increasing;
                          persistData.setString('sortBy', 'increasing');
                        } else if (result == 'decreasing') {
                          sortBy = SortBy.decreasing;
                          persistData.setString('sortBy', 'decreasing');
                        }
                      });
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'title',
                        enabled: false,
                        child: Text(
                          _displayedStringZHTW['sort by'] ?? '',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      PopupMenuDivider(
                        height: 0,
                      ),
                      PopupMenuItem<String>(
                        value: 'increasing',
                        child: Text(
                          _displayedStringZHTW['increasing'] ?? '',
                          style: TextStyle(
                              color: sortBy == SortBy.increasing
                                  ? Theme.of(context).primaryColor
                                  : Colors.black),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'decreasing',
                        child: Text(_displayedStringZHTW['decreasing'] ?? '',
                            style: TextStyle(
                                color: sortBy == SortBy.decreasing
                                    ? Theme.of(context).primaryColor
                                    : Colors.black)),
                      ),
                    ],
                  )
                ],
              ),
              Expanded(
                  child: NotificationListener<OverscrollIndicatorNotification>(
                      onNotification:
                          (OverscrollIndicatorNotification overscroll) {
                        overscroll.disallowGlow();
                        return false;
                      },
                      child: ListView.builder(
                          itemCount: repoList.length,
                          itemBuilder: (context, index) {
                            return repoList[index];
                          }))),
            ],
          ));
        });
  }
}
