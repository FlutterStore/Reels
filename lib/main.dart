import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:velocity_x/velocity_x.dart';



RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const Reelsload(),
    );
  }
}

class Reelsload extends StatefulWidget {

   const Reelsload();

  @override
  _ReelsloadState createState() => _ReelsloadState();
}

class _ReelsloadState extends State<Reelsload>with RouteAware {
  PageController? _pageController;
  int current = 0;
  bool isOnPageTurning = false;

  List<String> videos = [
  'assets/video/1.mp4',
  'assets/video/2.mp4',
  'assets/video/3.mp4',
  'assets/video/4.mp4',
  'assets/video/5.mp4',
];



  void scrollListener() {
    if (isOnPageTurning &&
        _pageController!.page == _pageController!.page!.roundToDouble()) {
      setState(() {
        current = _pageController!.page!.toInt();
        isOnPageTurning = false;
      });
    } else if (!isOnPageTurning &&
        current.toDouble() != _pageController!.page) {
      if ((current.toDouble() - _pageController!.page!).abs() > 0.1) {
        setState(() {
          isOnPageTurning = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController!.addListener(scrollListener);
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(
        this, ModalRoute.of(context) as PageRoute<dynamic>); //Subscribe it here
    super.didChangeDependencies();
  }

  var duration = const Duration(seconds: 2);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Reels',style: TextStyle(fontSize: 15),),
      ),
      body: SafeArea(
        child: PageView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemBuilder: (context, position) {
            return VideoPage(videos[position], position,current,isOnPageTurning);
          },
          itemCount: videos.length,
        ),
      ),
    );
  }
}

class VideoPage extends StatefulWidget {
  final String video;
  final int pageindex;
  final int currentPageIndex;
  final bool isPaused;

  // ignore: use_key_in_widget_constructors
  const VideoPage(this.video,this.pageindex,this.currentPageIndex,this.isPaused);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> with RouteAware {
  bool initialized = false;
  bool isLiked = false;


  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.video)
      ..initialize().then((value) {
        setState(() {
          _controller.setLooping(true);
          initialized = true;
        });
      });
  }

  @override
  void didPopNext() {
    _controller.play();
    super.didPopNext();
  }

  @override
  void didPushNext() {
    _controller.pause();
    super.didPushNext();
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(
        this, ModalRoute.of(context) as PageRoute<dynamic>); //Subscribe it here
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  var duration = const Duration(seconds: 2);

  var dropdownvalue = 'Reason1';
  var items = ['Reason1', 'Reason2', 'Reason3', 'Reason4'];
  @override
  Widget build(BuildContext context) {
    if (widget.pageindex == widget.currentPageIndex &&
        !widget.isPaused &&
        initialized) {
      _controller.play();
    } else {
      _controller.pause();
    }
    return Scaffold(
      backgroundColor:Colors.white,
      body: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            },
            child:  SizedBox(
              height: MediaQuery.of(context).size.height,
              child: _controller.value.isInitialized ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller)) 
              :  Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height,
                  child: CircularProgressIndicator()
                ),
            ),
          )
        ],
      )
    );
  }
}

