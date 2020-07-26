import 'package:flutter/material.dart';
import 'package:jp_flashcard/models/displayed_word_settings.dart';
import 'package:jp_flashcard/models/flashcard_info.dart';
import 'package:jp_flashcard/screens/learning/answer_correct_dialog.dart';
import 'package:jp_flashcard/screens/learning/answer_incorrect_dialog.dart';
import 'package:jp_flashcard/screens/repo/widget/input_field.dart';
import 'package:jp_flashcard/components/displayed_word.dart';

// ignore: must_be_immutable
class DefinitionShortAnswerQuiz extends StatefulWidget {
  int repoId;
  FlashcardInfo flashcardInfo;
  bool hasFurigana;
  Function nextQuiz;
  DefinitionShortAnswerQuiz(
      {this.flashcardInfo, this.repoId, this.hasFurigana, this.nextQuiz});
  @override
  _DefinitionShortAnswerQuizState createState() =>
      _DefinitionShortAnswerQuizState();
}

class _DefinitionShortAnswerQuizState extends State<DefinitionShortAnswerQuiz> {
  List<String> definition = [];

  List<bool> definitionIsAnswered = [];
  List<TextEditingController> inputValueList = [];
  List<GlobalKey<FormState>> validationKeyList = [];
  List<Widget> answerInputList = [];

  void answerCorrect() async {
    AnswerCorrectDialog answerCorrectDialog = AnswerCorrectDialog(
      flashcardInfo: widget.flashcardInfo,
      hasFurigana: widget.hasFurigana,
    );
    await answerCorrectDialog.dialog(context);

    widget.nextQuiz();
  }

  void answerIncorrect() async {
    AnswerIncorrectDialog answerIncorrectDialog = AnswerIncorrectDialog(
      incorrectFlashcardInfo: widget.flashcardInfo,
      correctFlashcardInfo: widget.flashcardInfo,
      hasFurigana: widget.hasFurigana,
    );
    await answerIncorrectDialog.dialog(context);
    widget.nextQuiz();
  }

  void initAnswerInputList() {
    definitionIsAnswered.clear();
    inputValueList.clear();
    validationKeyList.clear();
    answerInputList.clear();
    definition = widget.flashcardInfo.definition;
    for (int i = 0; i < definition.length; i++) {
      definitionIsAnswered.add(false);
      inputValueList.add(TextEditingController());
      validationKeyList.add(GlobalKey<FormState>());
      answerInputList.add(
        Padding(
          padding: EdgeInsets.fromLTRB(25, 0, 25, 10),
          child: InputField(
            validationKey: validationKeyList[i],
            inputValue: inputValueList[i],
            displayedString: '請輸入定義',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    initAnswerInputList();
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DisplayedWord(
                  flashcardInfo: widget.flashcardInfo,
                  displayedWordSettings: DisplayedWordSettings.large(),
                )
              ],
            ),
          ),
          ...answerInputList,
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 25, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ButtonTheme(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  minWidth: 0,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: FlatButton(
                    onPressed: () async {
                      answerIncorrect();
                    },
                    child: Text('不知道'),
                  ),
                ),
                ButtonTheme(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  minWidth: 0,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: FlatButton(
                    onPressed: () {
                      bool allCorrect = true;
                      bool isEmpty = false;
                      for (int i = 0; i < definition.length; i++) {
                        if (validationKeyList[i].currentState.validate()) {
                          bool correct = false;
                          for (int j = 0; j < definition.length; j++) {
                            if (definition[j] ==
                                    inputValueList[i].text.toString() &&
                                !definitionIsAnswered[j]) {
                              correct = true;
                              definitionIsAnswered[j] = true;
                              break;
                            }
                          }
                          if (!correct) {
                            allCorrect = false;
                            break;
                          }
                        } else {
                          isEmpty = true;
                        }
                      }
                      if (isEmpty) {
                        return;
                      }
                      if (allCorrect) {
                        answerCorrect();
                      } else {
                        answerIncorrect();
                      }
                    },
                    child: Text('確認'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}