import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:provider/provider.dart';
import 'package:smarthome_pad/utils/enums.dart';  

import '../utils/BehaviorStep.dart';
import '../widgets/Menu.dart';
import '../Store.dart';
import '../widgets/BehaviorStepCard.dart';
import '../widgets/AddEventDialog.dart';
import '../widgets/AddGroupDialog.dart';
import '../widgets/AttachActionOrGroupDialog.dart';

class BehaviorScreen extends StatefulWidget {
  BehaviorScreen({Key key}) : super(key: key);
  final double tileHeight = 100;
  final double headerHeight = 80;
  final double tileWidth = 200;

  @override
  BehaviorScreenState createState() => BehaviorScreenState();
}

class BehaviorScreenState extends State<BehaviorScreen> {
  LinkedHashMap<String, List<BehaviorStep>> board;
  LinkedHashMap<String, List<BehaviorStep>> localBoard;

  bool removeDragTargetVisible = false;
  double removeDragTargetScale = 1;

  @override
  Widget build(BuildContext context) {
    this.board = LinkedHashMap();
    this.localBoard = LinkedHashMap();

    S provider = Provider.of<S>(context);

    if ((provider.sharedFlow != null) && (provider.modules != null)) {
      provider.sharedFlow.forEach((String eventOrGroup, dynamic steps) {
        board[eventOrGroup] = <BehaviorStep>[];

        if (steps != null) {
          steps.forEach((String step, dynamic parameters) {
            if (parameters is Map) {
              board[eventOrGroup].add(BehaviorStep(id: step, listId: eventOrGroup, params: parameters));
            } else {
              board[eventOrGroup].add(BehaviorStep(id: step, listId: eventOrGroup));
            }
          });
        }
      });
    }

    if (provider.localFlow != null) {
      provider.localFlow.forEach((String event, dynamic steps) {
        localBoard[event] = <BehaviorStep>[];

        if (steps != null) {
          steps.forEach((String step, dynamic parameters) {
            if (parameters is Map) {
              localBoard[event].add(BehaviorStep(id: step, listId: event, params: parameters));
            } else {
              localBoard[event].add(BehaviorStep(id: step, listId: event));
            }
          });
        }
      });
    }

    buildKanbanList(String listId, List<BehaviorStep> items, { FlowType flowType }) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildHeader(listId, flowType: flowType),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 80,
                child: Container(
                  child: Row(
                    children: [
                      ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          // A stack that provides:
                          // * A draggable object
                          // * An area for incoming draggables

                          BehaviorStepCard card = BehaviorStepCard(
                            id: items[index].id,
                            step: items[index],
                          );

                          return Stack(
                            children: [
                              LongPressDraggable<BehaviorStep>(
                                data: items[index],
                                child: card, // A card waiting to be dragged
                                childWhenDragging: Opacity(
                                  // The card that's left behind
                                  opacity: 0.2,
                                  child: card,
                                ),
                                feedback: card,
                                onDragStarted: () => this.setState(() {
                                  this.removeDragTargetVisible = true;
                                }),
                                onDragEnd: (DraggableDetails details) => this.setState(() {
                                  this.removeDragTargetVisible = false;
                                }),
                              ),
                              buildItemDragTarget(listId, index, widget.tileHeight),
                            ],
                          );
                        },
                      ),
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.add,
                              size: 30,
                              color: Colors.grey[800],
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                child: AttachActionOrGroupDialog(
                                  eventOrGroup: listId,
                                )
                              );
                            }, 
                          ),
                        ),
                      )
                    ],
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
      ),
      body: Stack(
        children: [
          Column(
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
                      child: Text('Add Event'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          child: AddEventDialog()
                        );
                      }
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                        child: RaisedButton(
                        child: Text('Add Action Group'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            child: AddGroupDialog(/*flowType: FlowType.Shared*/)
                          );
                        }
                      ),
                    ),
                    RaisedButton(
                      child: Text('Apply'),
                      onPressed: () {
                        S().confirm(context, 'Do you really wish to update the shared system behavior?', () {
                          S().applySharedFlow(this.board);
                        });
                      }
                    ),
                  ],
                ),
              ),
              if (S().sharedFlow != null) Container(
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
              if (S().sharedFlow == null) Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(top: 20),
                child: Text('No shared behavior has been defined yet. Start by adding an event or action group.',
                  style: TextStyle(color: Colors.grey[800])
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 12, top: 20, right: 10),
                child: Row(
                  children: [
                    Text('Local',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    Spacer(),
                    RaisedButton(
                      child: Text('Save as Default'),
                      onPressed: () {
                        S().confirm(context, 'Do you really wish to save this behavior as default local? When the user interface is loaded on a new device, this behavior will be automatically loaded.', () {
                          S().saveDefaultLocalFlow();
                        });
                      }
                    ),
                  ],
                ),
              ),
              if (S().localFlow != null) Container(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: localBoard.keys.map((String key) {
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
                              buildKanbanList(key, localBoard[key], flowType: FlowType.Local)
                            ]
                          )
                        ),
                      );
                    }).toList()
                  ),
                ),
              ),
              if (S().localFlow == null) Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(top: 20),
                child: Text('No local behavior has been defined yet. Start by adding a button in the Controls screen.',
                  style: TextStyle(color: Colors.grey[800])
                ),
              ),
              if (S().localFlow.isEmpty) Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(top: 20),
                child: Text('No local behavior has been defined yet. Start by adding a button in the Controls screen.',
                  style: TextStyle(color: Colors.grey[800])
                ),
              ),
            ],
          ),
          // remove drag target
          if (this.removeDragTargetVisible)
          Positioned(
            top: 0,
            right: 0,
            child: Opacity(
              opacity: (this.removeDragTargetScale == 2) ? 1 : 0.75,
              child: Container(
                width: 100,
                height: 100,
                alignment: Alignment.topRight,
                child: Transform.scale(
                  scale: this.removeDragTargetScale,
                  child: DragTarget<BehaviorStep>(
                    onWillAccept: (BehaviorStep data) {
                      this.setState(() {
                        this.removeDragTargetScale = 2;
                      });

                      return true;
                    },
                    onLeave: (Object obj) {
                      this.setState(() {
                        this.removeDragTargetScale = 1;
                      });
                    },
                    // Moves the card into the position
                    onAccept: (BehaviorStep data) {
                      setState(() {

                        // check whether the dropped step is from sharedFlow
                        if (S().sharedFlow != null) {
                          if (S().sharedFlow.containsKey(data.listId)) {
                            if (data.id == data.listId) {
                              S().removeSharedEventOrGroupDefinition(data.id);
                            } else {
                              S().removeSharedActionOrGroupCall(data.listId, data.id);
                            }
                          }
                        }

                        // check whether the dropped step is from localFlow
                        if (S().localFlow != null) {
                          if (S().localFlow.containsKey(data.listId)) {
                            if (data.id == data.listId) {
                              S().alert(context, 'Local events are removed by removing their corresponding button from the Controls screen.');
                            } else {
                              S().removeLocalActionOrGroupCall(data.listId, data.id);
                            }
                          }
                        }

                        this.removeDragTargetScale = 1;
                      });
                    },
                    builder: (BuildContext context, List<BehaviorStep> data, List<dynamic> rejectedData) {
                      return Container(
                        width: 100,
                        height: 100,
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.only(top: 10, right: 10),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[300],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(100)
                          )
                        ),
                        child: Transform.scale(
                          scale: (this.removeDragTargetScale == 2) ? 0.5 : 1,
                          child: Icon(
                            Icons.delete,
                            size: 60,
                            color: Colors.white
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ) 
        ]
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
        return true;
        /*return board[listId].isEmpty || data.id != board[listId][targetPosition].id;*/
      },
      // Moves the card into the position
      onAccept: (BehaviorStep data) {
        setState(() {
          /*board[data.listId].remove(data);
          data.listId = listId;
          if (board[listId].length > targetPosition) {
            board[listId].insert(targetPosition + 1, data);
          } else {
            board[listId].add(data);
          }*/
        });
      },
      builder:
          (BuildContext context, List<BehaviorStep> data, List<dynamic> rejectedData) {
        /*if (data.isEmpty) {
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
                  child: BehaviorStepCard(
                    id: item.id,
                    step: item
                  ),
                );
              }).toList()
            ],
          );
        }*/

        return null;
      },
    );
  }

  buildHeader(String listId, { FlowType flowType }) {
    BehaviorStep headerStep = BehaviorStep(id: listId, listId: listId);

    Widget header = BehaviorStepCard(
      id: listId,
      step: headerStep,
      isLocalEvent: (flowType == FlowType.Local) ? true : false,
    );

    return Stack(
      // The header
      children: [
        LongPressDraggable<BehaviorStep>(
          data: headerStep,
          child: header, // A header waiting to be dragged
          childWhenDragging: Opacity(
            // The header that's left behind
            opacity: 0.2,
            child: header,
          ),
          feedback: header,
          onDragStarted: () => this.setState(() {
            this.removeDragTargetVisible = true;
          }),
          onDragEnd: (DraggableDetails details) => this.setState(() {
            this.removeDragTargetVisible = false;
          }),
        ),
        buildItemDragTarget(listId, 0, widget.headerHeight),
        DragTarget<BehaviorStep>(
          // Will accept others, but not himself
          onWillAccept: (BehaviorStep incoming) {
            return listId != incoming.listId;
          },
          // Moves the card into the position
          onAccept: (BehaviorStep incoming) {
            setState(() {
                LinkedHashMap<String, List<BehaviorStep>> reorderedBoard =
                    LinkedHashMap();
                for (String key in board.keys) {
                  if (key == incoming.listId) {
                    reorderedBoard[listId] = board[listId];
                  } else if (key == listId) {
                    reorderedBoard[incoming.listId] = board[incoming.listId];
                  } else {
                    reorderedBoard[key] = board[key];
                  }
                }
                board = reorderedBoard;
              },
            );
          },

          builder: (BuildContext context, List<BehaviorStep> data,
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
