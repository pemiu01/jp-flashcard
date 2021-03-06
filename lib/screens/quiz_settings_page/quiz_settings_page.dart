import 'package:flutter/material.dart';
import 'package:jp_flashcard/models/quiz_settings.dart';
import 'package:jp_flashcard/services/displayed_string.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class QuizSettingsPage extends StatelessWidget {
  //ANCHOR Constructor
  QuizSettingsPage();

  @override
  //ANCHOR Builder
  Widget build(BuildContext context) {
    //ANCHOR Providers
    return ChangeNotifierProvider<QuizSettings>(
      create: (context) {
        return QuizSettings();
      },

      //ANCHOR Quiz settings page
      child: Scaffold(
        appBar: AppBar(
          title: Text(DisplayedString.zhtw['quiz settings'] ?? ''),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 30),
          child: Consumer<QuizSettings>(
            builder: (context, quizSettings, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CheckboxListTile(
                    title: Text(
                      DisplayedString.zhtw['only show favorite'] ?? '',
                    ),
                    value: quizSettings.onlyShowFavorite,
                    onChanged: (value) {
                      quizSettings.toggleShowFavorite();
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      DisplayedString.zhtw['enable answer audio'] ?? '',
                    ),
                    value: quizSettings.enableAnswerAudio,
                    onChanged: (value) {
                      quizSettings.toggleAnswerAudio();
                    },
                    
                  ),
                  Divider(
                    thickness: 1,
                    indent: 17,
                    endIndent: 17,
                    color: Colors.grey[400],
                  ),
                  CheckboxListTile(
                    title: Text(
                      DisplayedString
                              .zhtw['enable definition selection quiz'] ??
                          '',
                    ),
                    value: quizSettings.enableDefinitionSelectionQuiz,
                    onChanged: (value) {
                      quizSettings.toggleDefinitionSelectionQuiz();
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      DisplayedString
                              .zhtw['enable definition short answer quiz'] ??
                          '',
                    ),
                    value: quizSettings.enableDefinitionShortAnswerQuiz,
                    onChanged: (value) {
                      quizSettings.toggleDefinitionShortAnswerQuiz();
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      DisplayedString.zhtw['enable word selection quiz'] ?? '',
                    ),
                    value: quizSettings.enableWordSelectionQuiz,
                    onChanged: (value) {
                      quizSettings.toggleWordSelectionQuiz();
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      DisplayedString.zhtw['enable word short answer quiz'] ??
                          '',
                    ),
                    value: quizSettings.enableWordShortAnswerQuiz,
                    onChanged: (value) {
                      quizSettings.toggleWordShortAnswerQuiz();
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      DisplayedString.zhtw['enable kanji short answer quiz'] ??
                          '',
                    ),
                    value: quizSettings.enableKanjiShortAnswerQuiz,
                    onChanged: (value) {
                      quizSettings.toggleKanjiShortAnswerQuiz();
                    },
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
