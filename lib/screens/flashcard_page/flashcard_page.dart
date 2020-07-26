import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jp_flashcard/models/general_settings.dart';
import 'package:jp_flashcard/screens/flashcard_page/displayed_flashcard.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class FlashcardPage extends StatefulWidget {
  int flashcardIndex;
  List<Widget> flashcardList = [];
  Function toggleFurigana;
  FlashcardPage({this.flashcardIndex, this.flashcardList, this.toggleFurigana});
  @override
  _FlashcardPageState createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  //ANCHOR Variables
  bool playFlashcards = false;
  bool inFlashcardPage = false;
  PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  Future<void> changePage() async {
    for (int i = _currentPage; i < widget.flashcardList.length; i++) {
      DisplayedFlashcard flashcard = widget.flashcardList[i];

      if (!inFlashcardPage || !playFlashcards) break;
      flashcard.flipPageToFront();

      if (!inFlashcardPage || !playFlashcards) break;
      await flashcard.speakWord();

      if (!inFlashcardPage || !playFlashcards) break;
      flashcard.flipPageToBack();

      await Future.delayed(Duration(milliseconds: 500));
      if (!inFlashcardPage || !playFlashcards) break;
      await flashcard.speakDefinition();

      if (_currentPage < widget.flashcardList.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
        i = -1;
      }

      if (!inFlashcardPage || !playFlashcards) break;
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  Icon displayTagButtonIcon = Icon(Icons.label_outline);

  @override
  void initState() {
    super.initState();
    inFlashcardPage = true;
    playFlashcards = false;
    _pageController = PageController(initialPage: widget.flashcardIndex);
    _currentPage = widget.flashcardIndex;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DisplayingSettings>(
      create: (context) {
        return DisplayingSettings();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              inFlashcardPage = false;
              Navigator.maybePop(context);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon:
                  !playFlashcards ? Icon(Icons.play_arrow) : Icon(Icons.pause),
              onPressed: () {
                setState(() {
                  if (!playFlashcards) {
                    playFlashcards = true;
                    changePage();
                  } else {
                    playFlashcards = false;
                  }
                });
              },
            ),
            //ANCHOR Kanji toggle button
            Consumer<DisplayingSettings>(
                builder: (context, generalSettings, child) {
              return IconButton(
                icon: generalSettings.hasKanji
                    ? Icon(Icons.visibility)
                    : Icon(Icons.visibility_off),
                onPressed: () {
                  generalSettings.toggleKanji();
                },
              );
            }),
            //ANCHOR Furigana toggle button
            Consumer<DisplayingSettings>(
                builder: (context, generalSettings, child) {
              return IconButton(
                icon: generalSettings.hasFurigana
                    ? Icon(Icons.speaker_notes)
                    : Icon(Icons.speaker_notes_off),
                onPressed: () {
                  generalSettings.toggleFurigana();
                },
              );
            })
          ],
        ),
        body: PageView(
          controller: _pageController,
          children: widget.flashcardList,
          onPageChanged: (index) {
            _currentPage = index;
          },
        ),
      ),
    );
  }
}