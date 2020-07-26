import 'package:flutter/material.dart';
import 'package:jp_flashcard/models/displayed_word_settings.dart';
import 'package:jp_flashcard/models/flashcard_info.dart';
import 'package:jp_flashcard/models/flashcard_list.dart';
import 'package:jp_flashcard/models/general_settings.dart';
import 'package:jp_flashcard/screens/flashcard_page/flashcard_page.dart';
import 'package:jp_flashcard/screens/repo/edit_flashcard_page.dart';
import 'package:jp_flashcard/services/database.dart';
import 'package:jp_flashcard/services/displayed_string.dart';
import 'package:jp_flashcard/services/text_to_speech.dart';
import 'package:jp_flashcard/components/displayed_word.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class FlashcardCard extends StatelessWidget {
  int repoId;
  int flashcardCardIndex;
  FlashcardInfo flashcardInfo;
  Function navigateToFlashcard;

  @override
  FlashcardCard({
    this.repoId,
    this.flashcardInfo,
    this.flashcardCardIndex,
    this.navigateToFlashcard,
  });

  deleteAlertDialog(BuildContext context) {
    return showDialog(
      context: context,
      child: AlertDialog(
        title: Text(DisplayedString.zhtw['delete flashcard alert title'] ?? ''),
        content:
            Text(DisplayedString.zhtw['delete flashcard alert content'] ?? ''),
        contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 10),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(DisplayedString.zhtw['cancel'] ?? '')),
          FlatButton(
            onPressed: () {
              DBManager.db.deleteFlashcard(repoId, flashcardInfo.flashcardId);
              Navigator.of(context).pop(true);
            },
            child: Text(DisplayedString.zhtw['confirm'] ?? ''),
          )
        ],
      ),
    );
  }

  //ANCHOR Initialize displayed definition list
  List<Widget> displayedDefinitionList = [];
  void initDisplayedDefinitionList() {
    displayedDefinitionList.clear();
    int i = 1;
    for (final definition in flashcardInfo.definition) {
      displayedDefinitionList.add(Padding(
        padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
        child: Text(
          flashcardInfo.definition.length > 1
              ? '$i. ' + definition
              : definition,
          style: TextStyle(
            fontSize: 17,
          ),
        ),
      ));
      i++;
    }
  }
  //TODO Width overflow

  void speak() {
    TextToSpeech.tts.speak('ja-JP', flashcardInfo.word);
    return;
  }

  FlashcardList flashcardList;
  void initVariables(BuildContext context) {
    flashcardList = Provider.of<FlashcardList>(context);
  }

  @override
  Widget build(BuildContext context) {
    //ANCHOR Initialize
    initDisplayedDefinitionList();
    initVariables(context);

    //ANCHOR Flashcard card widget
    return Container(
      padding: EdgeInsets.fromLTRB(15, 1, 15, 1),
      child: Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(5),
          onTap: () {
            /*
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return FlashcardPage(
                flashcardIndex:  flashcardCardIndex,
                flashcardList: flashcardList.info,
              );
            })).then((value) {
              updateFlashcardCardList();
            });
            */
            //navigateToFlashcard(flashcardCardIndex);
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(15, 12, 0, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                //ANCHOR Displayed word and definition list
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //ANCHOR Displayed word
                    Consumer<DisplayingSettings>(
                      builder: (context, generalSettings, child) {
                        return DisplayedWord(
                          flashcardInfo: flashcardInfo,
                          displayedWordSettings: DisplayedWordSettings.medium(),
                        );
                      },
                    ),

                    SizedBox(
                      height: 5,
                    ),

                    //ANCHOR Displayed definition list
                    ...displayedDefinitionList,
                  ],
                ),

                //ANCHOR Action buttons
                Row(
                  children: <Widget>[
                    //ANCHOR Speech button
                    IconButton(
                      icon: Icon(
                        Icons.volume_up,
                        size: 23.0,
                      ),
                      onPressed: () {
                        speak();
                      },
                    ),

                    //ANCHOR Favorite button
                    IconButton(
                      icon: Icon(
                        Icons.star_border,
                        size: 23.0,
                      ),
                      onPressed: () {
                        //TODO Favorite button
                      },
                    ),

                    //ANCHOR More info button
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert),
                      offset: Offset(0, 100),
                      tooltip: DisplayedString.zhtw['more'] ?? '',
                      onSelected: (String result) async {
                        if (result == 'edit') {
                          //ANCHOR Edit button
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return EditFlashcardPage(
                              repoId: repoId,
                              flashcardInfo: flashcardInfo,
                            );
                          })).then((newFlashcardInfo) {});
                        } else if (result == 'delete') {
                          //ANCHOR Delete button
                          if (await deleteAlertDialog(context)) {}
                        }
                      },

                      //ANCHOR Button list
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text(DisplayedString.zhtw['edit'] ?? ''),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(DisplayedString.zhtw['delete'] ?? ''),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}