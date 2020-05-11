import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:provider/provider.dart';

import '../utils/BehaviorStep.dart';
import '../widgets/BehaviorRow.dart';
import '../widgets/Menu.dart';
import '../Store.dart';
import '../widgets/BehaviorStepCard.dart';

class BehaviorScreen extends StatefulWidget {
  BehaviorScreen({Key key}) : super(key: key);
  final double tileHeight = 100;
  final double headerHeight = 80;
  final double tileWidth = 200;

  @override
  _BehaviorScreenState createState() => _BehaviorScreenState();
}

class _BehaviorScreenState extends State<BehaviorScreen> {
  LinkedHashMap<String, List<BehaviorStep>> board;
  bool codeView = false;

  @override
  Widget build(BuildContext context) {
    S provider = Provider.of<S>(context);

    if ((provider.sharedFlow != null) && (provider.modules != null)) {
      provider.sharedFlow.forEach((String eventOrGroup, dynamic steps) {
        board[eventOrGroup] = <BehaviorStep>[];

        steps.forEach((String step, dynamic parameters) {
          if (parameters is Map) {
            board[eventOrGroup].add(BehaviorStep(id: step, listId: eventOrGroup, params: parameters));
          } else {
            board[eventOrGroup].add(BehaviorStep(id: step, listId: eventOrGroup));
          }
        });
      });
    }

    buildKanbanList(String listId, List<BehaviorStep> items) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildHeader(listId),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 80,
                child: Container(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      // A stack that provides:
                      // * A draggable object
                      // * An area for incoming draggables
                      return Stack(
                        children: [
                          LongPressDraggable<BehaviorStep>(
                            data: items[index],
                            child: BehaviorRow(
                              item: items[index],
                            ), // A card waiting to be dragged
                            childWhenDragging: Opacity(
                              // The card that's left behind
                              opacity: 0.2,
                              child: BehaviorRow(item: items[index]),
                            ),
                            feedback: Container(
                              // A card floating around
                              height: widget.tileHeight,
                              width: widget.tileWidth,
                              child: FloatingWidget(
                                  child: BehaviorRow(
                                item: items[index],
                              )),
                            ),
                          ),
                          buildItemDragTarget(listId, index, widget.tileHeight),
                        ],
                      );
                    },
                  ),
                ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: Menu(),
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text('Behavior'),
        /*actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.code),
            onPressed: () {
              this.setState(() {
                this.codeView = !this.codeView;
              });
            },
          ),
        ],*/
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 12, top: 20, right: 10),
            child: Row(
              children: [
                Text('Shared',
                  style: Theme.of(context).textTheme.headline1,
                ),
                Spacer(),
                RaisedButton(
                  child: Text('Add Timeline'),
                  onPressed: () {
                  }
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                child: RaisedButton(
                  child: Text('Apply'),
                  onPressed: () {
                    S().confirm(context, 'Updating the shared system behavior may take several seconds.', () {
                      S().applySharedFlow(this.board);
                    });
                  }
                ),
                ),
              ],
            ),
          ),
          Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: board.keys.map((String key) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      margin: EdgeInsets.only(top: 10, left: 10),
                      child: Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[600] 
                            ),
                          ),
                          buildKanbanList(key, board[key])
                        ]
                      )
                    ),
                  );
                }).toList()
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 12, top: 20, right: 10),
            child: Text('Local',
              style: Theme.of(context).textTheme.headline1,
            ),
          ),
        ],
      )
    );
  }

  @override
  void initState() {
    board = LinkedHashMap();

    super.initState();
  }

  buildItemDragTarget(listId, targetPosition, double height) {
    return DragTarget<BehaviorStep>(
      // Will accept others, but not himself
      onWillAccept: (BehaviorStep data) {
        return board[listId].isEmpty ||
            data.id != board[listId][targetPosition].id;
      },
      // Moves the card into the position
      onAccept: (BehaviorStep data) {
        setState(() {
          board[data.listId].remove(data);
          data.listId = listId;
          if (board[listId].length > targetPosition) {
            board[listId].insert(targetPosition + 1, data);
          } else {
            board[listId].add(data);
          }
        });
      },
      builder:
          (BuildContext context, List<BehaviorStep> data, List<dynamic> rejectedData) {
        if (data.isEmpty) {
          // The area that accepts the draggable
          return Container(
            width: 200,
            //height: height,
          );
        } else {
          return Row(
            // What's shown when hovering on it
            children: [
              Container(
                //height: height,
                width: 200,
              ),
              ...data.map((BehaviorStep item) {
                return Opacity(
                  opacity: 0.5,
                  child: BehaviorRow(item: item),
                );
              }).toList()
            ],
          );
        }
      },
    );
  }

  buildHeader(String listId) {
    Widget header = BehaviorStepCard(id: listId);

    return Stack(
      // The header
      children: [
        LongPressDraggable<String>(
          data: listId,
          child: header, // A header waiting to be dragged
          childWhenDragging: Opacity(
            // The header that's left behind
            opacity: 0.2,
            child: header,
          ),
          feedback: FloatingWidget(
            child: Container(
              // A header floating around
              width: widget.tileWidth,
              child: header,
            ),
          ),
        ),
        buildItemDragTarget(listId, 0, widget.headerHeight),
        DragTarget<String>(
          // Will accept others, but not himself
          onWillAccept: (String incomingListId) {
            return listId != incomingListId;
          },
          // Moves the card into the position
          onAccept: (String incomingListId) {
            setState(() {
                LinkedHashMap<String, List<BehaviorStep>> reorderedBoard =
                    LinkedHashMap();
                for (String key in board.keys) {
                  if (key == incomingListId) {
                    reorderedBoard[listId] = board[listId];
                  } else if (key == listId) {
                    reorderedBoard[incomingListId] = board[incomingListId];
                  } else {
                    reorderedBoard[key] = board[key];
                  }
                }
                board = reorderedBoard;
              },
            );
          },

          builder: (BuildContext context, List<String> data,
              List<dynamic> rejectedData) {
            if (data.isEmpty) {
              // The area that accepts the draggable
              return Container(
                height: widget.headerHeight,
                width: widget.tileWidth,
              );
            } else {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 3,
                    color: Colors.blueAccent,
                  ),
                ),
                height: widget.headerHeight,
                width: widget.tileWidth,
              );
            }
          },
        )
      ],
    );
  }
}

class FloatingWidget extends StatelessWidget {
  final Widget child;

  const FloatingWidget({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.1,
      child: child,
    );
  }
}
