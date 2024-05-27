import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dyslexia_project/screens/home_screen.dart';

class PageViewInstruction extends StatefulWidget {
  const PageViewInstruction({super.key});

  @override
  State<PageViewInstruction> createState() => _PageViewInstructionState();
}

class _PageViewInstructionState extends State<PageViewInstruction>
    with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              "assets/images/instruction_back.png",
              fit: BoxFit.cover,
            ),
            PageView(
              controller: _pageViewController,
              onPageChanged: _handlePageViewChanged,
              children: <Widget>[
              Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Центрируем по вертикали
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(top: 10,  left: 200),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomeScreen())
                              );
                            },
                            child: Icon(Icons.close, size: 20,),
                          )),
                     Padding(
                        padding: EdgeInsets.only(top: 45, left: 30, right: 30),
                         child:
                        RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 20.0),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Привет!',
                              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Color(0xff494646),),
                            ),
                            TextSpan(text: '  Сейчас я расскажу тебе, как здесь всё устроено',
                              style: TextStyle(fontSize: 24.0, color: Color(0xff494646),),),
                          ],
                        ),
                      )
                     ),

                      SizedBox(
                        height: 60
                      ),

                      Image.asset(
                        "assets/finish_gifs/cute-heart.gif",
                        width: 350,
                        height: 350,
                      ),
                    ])
            ),

            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Центрируем по вертикали
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(top: 10,  left: 200),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomeScreen())
                              );
                            },
                            child: Icon(Icons.close, size: 20,),
                          )),
                      Padding(
                          padding: EdgeInsets.only(top: 20, left: 30, right: 30),
                          child:
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 20.0),
                          children: <TextSpan>[
                            TextSpan(text: 'На главном экране ты можешь перейти к урокам и начать развивать свой навык чтения 💪',
                              style: TextStyle(fontSize: 20.0, color: Color(0xff494646),),),
                          ],
                        ),
                      )
                      ),

                      SizedBox(
                          height: 30
                      ),

                      Image.asset(
                        "assets/images/inst1.png",
                        width: 450,
                        height: 450,
                      ),
                    ])
            ),

            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Центрируем по вертикали
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(top: 10,  left: 200),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomeScreen())
                              );
                            },
                            child: Icon(Icons.close, size: 20,),
                          )),
                      Padding(
                        padding: EdgeInsets.only(top: 20, left: 30, right: 30),
                        child:
                        RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 20.0),
                            children: <TextSpan>[
                              TextSpan(text: 'Каждый урок имеет свой номер и название. Справа от названия ты можешь увидеть свой прогресс. Рекомендуем проходить уроки по порядку, это поможет тебе быстрее усвоить материал',
                                style: TextStyle(fontSize: 20.0, color: Color(0xff494646),),),
                            ],
                          ),
                        )
                      ),

                      SizedBox(
                          height: 40
                      ),

                      Image.asset(
                        "assets/images/inst2.png",
                        width: 450,
                        height: 450,
                      ),
                    ])
            ),

            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(top: 10,  left: 200),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomeScreen())
                              );
                            },
                            child: Icon(Icons.close, size: 20,),
                          )),
                      Padding(
                          padding: EdgeInsets.only(top: 20, left: 30, right: 30),
                          child:
                          RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black, fontSize: 20.0),
                              children: <TextSpan>[
                                TextSpan(text: 'На главном экране ты также можешь выбрать тему, которая тебе нравится, и начать решать задания. Этот раздел нужен, чтобы потренироваться в том, что вызвало у тебя трудности в процессе выполнения урока',
                                  style: TextStyle(fontSize: 20.0, color: Color(0xff494646),),),
                              ],
                            ),
                          )
                      ),

                      SizedBox(
                          height: 40
                      ),

                      Image.asset(
                        "assets/images/inst3.png",
                        width: 450,
                        height: 450,
                      ),
                    ])
            ),

            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Центрируем по вертикали
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(top: 10,  left: 200),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomeScreen())
                              );
                            },
                            child: Icon(Icons.close, size: 20,),
                          )),
                      Padding(
                          padding: EdgeInsets.only(top: 20, left: 30, right: 30),
                          child:
                          RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black, fontSize: 20.0),
                              children: <TextSpan>[
                                TextSpan(text: 'Каждое задание имеет три уровня сложности, поэтому ты можешь выбрать те упражнения, которые подходят именно тебе 😎',
                                  style: TextStyle(fontSize: 20.0, color: Color(0xff494646),),),
                              ],
                            ),
                          )
                      ),

                      SizedBox(
                          height: 40
                      ),

                      Image.asset(
                        "assets/images/inst4.png",
                        width: 450,
                        height: 450,
                      ),
                    ])
            ),

            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Центрируем по вертикали
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(top: 10, left: 200),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomeScreen())
                              );
                            },
                            child: Icon(Icons.close, size: 20,),
                          )),
                      Padding(
                          padding: EdgeInsets.only(top: 20, left: 30, right: 30),
                          child:
                          RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black, fontSize: 20.0),
                              children: <TextSpan>[
                                TextSpan(text: 'Отслеживать свой прогресс ты можешь на странице личного кабинета',
                                  style: TextStyle(fontSize: 20.0, color: Color(0xff494646),),),
                              ],
                            ),
                          )
                      ),

                      SizedBox(
                          height: 40
                      ),

                      Image.asset(
                        "assets/images/inst5.png",
                        width: 450,
                        height: 450,
                      ),
                    ])
            ),

            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(top: 10,  left: 200),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomeScreen())
                              );
                            },
                            child: Icon(Icons.close, size: 20,),
                          )),
                      Padding(
                          padding: EdgeInsets.only(top: 20, left: 30, right: 30),
                          child:
                          RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black, fontSize: 20.0),
                              children: <TextSpan>[

                                TextSpan(text: 'Во вкладке “Чтение” находятся тексты разной длины. Ты можешь читать их и сохранять запись своего прочтения, чтобы твой родитель или логопед оценил ее.',
                                  style: TextStyle(fontSize: 17.0, color: Color(0xff494646),),),

                                TextSpan(text: '\n'),

                                TextSpan(text: '\n'),

                                TextSpan(text: 'Ты также можешь получить автоматическую оценку своего прочтения, если нажмешь на сохраненную запись. Но тогда придется немного подождать.',
                                  style: TextStyle(fontSize: 17.0, color: Color(0xff494646),),),
                              ],
                            ),
                          )
                      ),

                      SizedBox(
                          height: 5,
                      ),

                      Image.asset(
                        "assets/images/inst6.png",
                        width: 370,
                        height: 450,
                      ),
                    ])
            ),


            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Центрируем по вертикали
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(top: 10,  left: 200),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomeScreen())
                              );
                            },
                            child: Icon(Icons.close, size: 20,),
                          )),

                      Padding(
                          padding: EdgeInsets.only(top: 20, left: 30, right: 30),
                          child:
                          RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black, fontSize: 20.0),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Желаем тебе удачи в решении заданий!',
                                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Color(0xff494646),),
                                ),

                                TextSpan(text: '\n'),

                                TextSpan(text: '\n'),

                                TextSpan(text: 'Не расстраивайся, если что-то не получается.  К победе идут маленькими шагами и ты большой молодец, что начал заниматься!',
                                  style: TextStyle(fontSize: 18.0, color: Color(0xff494646),),),
                              ],
                            ),
                          )
                      ),

                      SizedBox(
                          height: 60
                      ),

                      Image.asset(
                        "assets/finish_gifs/love-cute.gif",
                        width: 350,
                        height: 350,
                      ),
                    ])
            ),

          ],
        ),


        PageIndicator(
          tabController: _tabController,
          currentPageIndex: _currentPageIndex,
          onUpdateCurrentPageIndex: _updateCurrentPageIndex,
          isOnDesktopAndWeb: _isOnDesktopAndWeb,
        ),
      ],
    )]);
  }

  void _handlePageViewChanged(int currentPageIndex) {
    if (!_isOnDesktopAndWeb) {
      return;
    }
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  bool get _isOnDesktopAndWeb {
    if (kIsWeb) {
      return true;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
    required this.isOnDesktopAndWeb,
  });

  final int currentPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;
  final bool isOnDesktopAndWeb;

  @override
  Widget build(BuildContext context) {
    if (!isOnDesktopAndWeb) {
      return const SizedBox.shrink();
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 0) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex - 1);
            },
            icon: const Icon(
              Icons.arrow_left_rounded,
              size: 32.0,
            ),
          ),
          TabPageSelector(
            controller: tabController,
            color: colorScheme.surface,
            selectedColor: colorScheme.primary,
          ),
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 2) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex + 1);
            },
            icon: const Icon(
              Icons.arrow_right_rounded,
              size: 32.0,
            ),
          ),
        ],
      ),
    );
  }
}
