import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_survey/card_data.dart';

Map<String, Object> userMapAnswers = Map();
String octResponsePath;
String octSurveyPath;

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(SurveyWidget());
}

class SurveyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Survey",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.brown),
      home: SurveyHomeWidget(),
    );
  }
}

class SurveyHomeWidget extends StatefulWidget {
  @override
  _SurveyHomeWidgetState createState() => _SurveyHomeWidgetState();
}

class _SurveyHomeWidgetState extends State<SurveyHomeWidget> {
  double _scrollPercent = 0.0;
  int scrollPosition = 0;

  List<CardViewModel> listOfQuestion = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Top bar
          Container(
            width: double.infinity,
            height: 24.0,
          ),

          //Center
          /* Expanded(
            child: CardFlip(
              cards: loadDataFromFirestore(),
              onScroll: (double scrollPosition) {
                _scrollPercent = scrollPosition;

                setState(() {
                  this._scrollPercent = scrollPosition;
                });
              },
            ),
          ),*/

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection("2018/2018_survey/oct")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Text("Loading data");

                final int msgCount = snapshot.data.documents.length;

                print("SIZE ${msgCount}");
                print("SIZE ${listOfQuestion.length}");

                listOfQuestion.clear();
                for (int i = 0; i < msgCount; i++) {
                  var modelData = snapshot.data.documents[i].data;
                  listOfQuestion.add(CardViewModel(
                    slNo: modelData['slNo'],
                      question: modelData['question'],
                      optionOne: modelData['optionOne'],
                      optionTwo: modelData['optionTwo'],
                      optionThree: modelData['optionThree'],
                      optionFour: modelData['optionFour'],
                      imagePath: modelData['imagePath']));
                }

                print("SIZE INSIDE ${listOfQuestion.length}");
                return CardFlip(
                  cards: listOfQuestion,
                  onScroll: (double scrollPosition) {
                    _scrollPercent = scrollPosition;

                    setState(() {
                      this._scrollPercent = scrollPosition;
                    });
                  },
                );
              },
            ),
          ),
          //Bottom bar
          BottomBar(
            cardCount: listOfQuestion.length,
            scrollPercent: _scrollPercent,
          )
        ],
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  final int cardCount;
  final double scrollPercent;

  BottomBar({this.cardCount, this.scrollPercent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Info"),
                      content: const Text(
                          "This app ensure full anonymity to the user, so please answer genuinely."),
                      actions: <Widget>[
                        FlatButton(
                          child: const Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  });
            },
            child: Icon(
              Icons.info,
              color: Colors.white,
            ),
            backgroundColor: Colors.black,
          )),
          Expanded(
            child: Container(
              width: double.infinity,
              height: 6.0,
              child: ScrollIndicator(
                cardCount: cardCount,
                scrollPercent: scrollPercent,
              ),
            ),
          ),
          Expanded(
              child: FloatingActionButton(
            onPressed: () {
              print("Length ${userMapAnswers.length}");
              print("Length Card ${cardCount * 7}");
              if (userMapAnswers.length != (cardCount * 7) + 1) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Info"),
                        content: const Text(
                            "Look like you haven't answered all questions, please answer them."),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("OK"),
                          )
                        ],
                      );
                    });
              } else {
                var mainContext = context;
                showDialog(
                    context: mainContext,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Submit Feedback"),
                        content: const Text(
                            "We appreciate your feedback, thanks for it!\nNote: This will auto close app once feedback is submitted."),
                        actions: <Widget>[
                          FlatButton(
                            child: const Text("Not now"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          RaisedButton(
                            child: const Text("Send now"),
                            color: Colors.brown,
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.of(context).pop();

                              /* Scaffold.of(mainContext).showSnackBar(new SnackBar(
                                content: new Text("Your feedback is submitted successfully!"),
                              ));*/

                              Firestore.instance
                                  .collection("2018/2018_survey/oct_response")
                                  .add(userMapAnswers)
                                  .whenComplete(() {
                                showDialog(
                                    context: mainContext,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Thank you"),
                                        content: const Text(
                                            "Your response is recorded, thank you for your valuable feedback."),
                                        actions: <Widget>[
                                          FlatButton(
                                              child: const Text("OK"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                //exit(0);
                                              })
                                        ],
                                      );
                                    });
                              }).catchError((onError) {
                                showDialog(context: mainContext,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Error"),
                                    content: const Text(
                                        "Unable to submit please try again later"),
                                    actions: <Widget>[
                                      FlatButton(
                                          child: const Text("OK"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          })
                                    ],
                                  );
                                });
                              });
                              //exit(0);
                              //Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              }
            },
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            backgroundColor: Colors.black,
          ))
        ],
      ),
    );
  }
}

class ScrollIndicator extends StatelessWidget {
  final int cardCount;
  final double scrollPercent;

  ScrollIndicator({this.cardCount, this.scrollPercent});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ScrollIndicatorPainter(
          cardCount: cardCount, scrollPercent: scrollPercent),
      child: Container(),
    );
  }
}

class ScrollIndicatorPainter extends CustomPainter {
  final int cardCount;
  final double scrollPercent;
  final Paint trackPaint;
  final Paint thumbPaint;

  ScrollIndicatorPainter({this.cardCount, this.scrollPercent})
      : trackPaint = Paint()
          ..color = Color(0xFF444444)
          ..style = PaintingStyle.fill,
        thumbPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    //Track
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(0.0, 0.0, size.width, size.height),
            topLeft: Radius.circular(3.0),
            topRight: Radius.circular(3.0),
            bottomLeft: Radius.circular(3.0),
            bottomRight: Radius.circular(3.0)),
        trackPaint);

    //Thumb
    final thumbWidth = size.width / cardCount;
    final thumbLeft = scrollPercent * size.width;
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(thumbLeft, 0.0, thumbWidth, size.height),
            topLeft: Radius.circular(3.0),
            topRight: Radius.circular(3.0),
            bottomLeft: Radius.circular(3.0),
            bottomRight: Radius.circular(3.0)),
        thumbPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CardFlip extends StatefulWidget {
  final List<CardViewModel> cards;
  final Function(double scrollPosition) onScroll;

  CardFlip({this.cards, this.onScroll});

  @override
  _CardFlipState createState() => _CardFlipState();
}

class _CardFlipState extends State<CardFlip> with TickerProviderStateMixin {
  double scrollPercent = 0.0;
  Offset startDrag;
  double startDragPercentScroll = 0.0;
  double finishScrollStart = 0.0;
  double finishScrollEnd = 0.0;
  AnimationController finishScrollController;

  @override
  void initState() {
    super.initState();

    finishScrollController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this)
      ..addListener(() {
        setState(() {
          scrollPercent = lerpDouble(
              finishScrollStart, finishScrollEnd, finishScrollController.value);

          if (widget.onScroll != null) {
            widget.onScroll(scrollPercent);
          }
        });
      });
  }

  @override
  void dispose() {
    finishScrollController.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    startDrag = details.globalPosition;
    startDragPercentScroll = scrollPercent;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final currentDrag = details.globalPosition;
    final dragDistance = currentDrag.dx - startDrag.dx;
    final singleCardDragPos = dragDistance / context.size.width;

    setState(() {
      print(singleCardDragPos);
      scrollPercent =
          (startDragPercentScroll + (-singleCardDragPos / widget.cards.length))
              .clamp(0.0, 1.0 - (1 / widget.cards.length));

      if (widget.onScroll != null) {
        widget.onScroll(scrollPercent);
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    print("Start: ${finishScrollStart} end ${finishScrollEnd}");

    finishScrollStart = scrollPercent;
    finishScrollEnd =
        (scrollPercent * widget.cards.length).round() / widget.cards.length;
    finishScrollController.forward(from: 0.0);

    setState(() {
      print("Drag end");

      startDrag = null;
      startDragPercentScroll = null;
    });
  }

  List<Widget> _buildCards() {
    final cardsNum = widget.cards.length;

    int position = -1;
    return widget.cards.map((CardViewModel cardViewModel) {
      ++position;

      return _buildCard(cardViewModel, position, cardsNum, scrollPercent);
    }).toList();
  }

  Matrix4 _buildCardProjections(double scrollPercent) {
    final perspective = 0.002;
    final radius = 1.0;
    final angle = scrollPercent * pi / 6;
    final horizontalTranslation = 0.0;

    Matrix4 projection = Matrix4.identity()
      ..setEntry(0, 0, 1 / radius)
      ..setEntry(1, 1, 1 / radius)
      ..setEntry(3, 2, -perspective)
      ..setEntry(2, 3, -radius)
      ..setEntry(3, 3, perspective * radius + 1.0);

    final rotationMultiplex = angle > 0.0 ? angle / angle.abs() : 1.0;
    projection *= Matrix4.translationValues(
            horizontalTranslation + (rotationMultiplex * 300.0), 0.0, 0.0) *
        Matrix4.rotationY(angle) *
        Matrix4.translationValues(0.0, 0.0, radius) *
        Matrix4.translationValues(-rotationMultiplex * 300.0, 0.0, 0.0);

    return projection;
  }

  Widget _buildCard(CardViewModel cardViewModel, int position, int cardCount,
      double scrollPercent) {
    final cardScrollPercentage = scrollPercent / (1 / cardCount);
    final parallax = scrollPercent - (position / cardCount);

    return FractionalTranslation(
        translation: Offset(position - cardScrollPercentage, 0.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Transform(
              transform: _buildCardProjections(cardScrollPercentage - position),
              child: Card(cardViewModel, parallexPercent: parallax, totalCards: cardCount)),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: _buildCards(),
      ),
    );
  }
}

class Card extends StatelessWidget {
  final CardViewModel cardViewModel;
  final double parallexPercent;
  final int totalCards;

  Card(this.cardViewModel, {this.parallexPercent, this.totalCards});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: FractionalTranslation(
              translation: Offset(parallexPercent * 2.0, 0.0),
              child: OverflowBox(
                maxWidth: double.infinity,
                child: Image.network(
                  cardViewModel.imagePath,
                  fit: BoxFit.cover,
                ),
                /*child: Image.asset(
                  cardViewModel.imagePath,
                  fit: BoxFit.cover,
                ),*/
              ),
            )),
        QuestionWidget(cardViewModel, totalCards)
      ],
    );
  }
}

class QuestionWidget extends StatefulWidget {
  final CardViewModel cardViewModel;
  final int totalQuestions;

  QuestionWidget(this.cardViewModel, this.totalQuestions);

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState(cardViewModel, totalQuestions);
}

class _QuestionWidgetState extends State<QuestionWidget> {
  int _groupValue;

  final CardViewModel _cardViewModel;
  final int totalQuestions;

  _QuestionWidgetState(this._cardViewModel, this.totalQuestions);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.only(
                top: 32.0, left: 16.0, right: 16.0, bottom: 18.0),
            child: Text(_cardViewModel.question,
                style: TextStyle(
                    fontSize: 24.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Radio(
                  onChanged: (num) => changeState(num, _cardViewModel, totalQuestions),
                  activeColor: Colors.white,
                  value: 1,
                  groupValue: _groupValue,
                ),
                Expanded(
                  child: Container(
                    margin:
                        EdgeInsets.only(bottom: 12.0, right: 24.0, top: 12.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.white, width: 1.0),
                        color: Colors.black.withOpacity(0.3)),
                    child: FlatButton(
                      onPressed: () {
                        changeState(1, _cardViewModel, totalQuestions);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(_cardViewModel.optionOne,
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.white)),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Radio(
                  onChanged: (num) => changeState(num, _cardViewModel, totalQuestions),
                  activeColor: Colors.white,
                  value: 2,
                  groupValue: _groupValue,
                ),
                Expanded(
                  child: Container(
                    margin:
                        EdgeInsets.only(bottom: 12.0, right: 24.0, top: 12.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.white, width: 1.0),
                        color: Colors.black.withOpacity(0.3)),
                    child: FlatButton(
                      onPressed: () {
                        changeState(2, _cardViewModel, totalQuestions);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(_cardViewModel.optionTwo,
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Radio(
                  onChanged: (num) => changeState(num, _cardViewModel, totalQuestions),
                  activeColor: Colors.white,
                  value: 3,
                  groupValue: _groupValue,
                ),
                Expanded(
                  child: Container(
                      margin:
                          EdgeInsets.only(bottom: 12.0, right: 24.0, top: 12.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.white, width: 1.0),
                          color: Colors.black.withOpacity(0.3)),
                      child: FlatButton(
                        onPressed: () {
                          changeState(3, _cardViewModel, totalQuestions);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(_cardViewModel.optionThree,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.white)),
                        ),
                      )),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Radio(
                  onChanged: (num) => changeState(num, _cardViewModel, totalQuestions),
                  activeColor: Colors.white,
                  value: 4,
                  groupValue: _groupValue,
                ),
                Expanded(
                  child: Container(
                    margin:
                        EdgeInsets.only(bottom: 12.0, right: 24.0, top: 12.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.white, width: 1.0),
                        color: Colors.black.withOpacity(0.3)),
                    child: FlatButton(
                      onPressed: () {
                        changeState(4, _cardViewModel, totalQuestions);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          _cardViewModel.optionFour,
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        )
      ],
    );
  }

  void changeState(int num, CardViewModel viewModel, int totalQuestions) {

    userMapAnswers["question${viewModel.slNo}"] = viewModel.question;
    userMapAnswers["optionOne${viewModel.slNo}"] = viewModel.optionOne;
    userMapAnswers["optionTwo${viewModel.slNo}"] = viewModel.optionTwo;
    userMapAnswers["optionThree${viewModel.slNo}"] = viewModel.optionThree;
    userMapAnswers["optionFour${viewModel.slNo}"] = viewModel.optionFour;
    userMapAnswers["response${viewModel.slNo}"] = num;
    userMapAnswers["timestamp${viewModel.slNo}"] = FieldValue.serverTimestamp();
    userMapAnswers["totalQuestions"] = totalQuestions.toString();

    setState(() {
      _groupValue = num;
    });
  }
}
