import 'dart:async';

import 'package:clubify/common/constants/colors.dart';
import 'package:clubify/common/models/postModel.dart';
import 'package:clubify/common/providers/inheritedDataProvider.dart';
import 'package:clubify/common/providers/postProvider.dart';
import 'package:clubify/common/widgets/postWidget.dart';
import 'package:clubify/common/widgets/scaffolds.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnnouncementScreen extends ConsumerStatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  ConsumerState<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends ConsumerState<AnnouncementScreen> {
  // final ScrollController _scrollController = ScrollController();
  ScrollController? _scrollController;
  List<PostModel> posts = [];
  bool _isLoading = false;
  double _progressValue = 0.0;
  late String userEmail;

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialPosts();
    });
    fetchUserEmail();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the scroll controller from InheritedDataProvider
    final inheritedData = InheritedDataProvider.of(context);
    _scrollController = inheritedData?.scrollController;
    
    if (_scrollController != null) {
      _scrollController!.addListener(_onScroll);
    }
  }

  Future<void> fetchUserEmail() async {
    try {
      userEmail = Supabase.instance.client.auth.currentUser!.email!;
      if (userEmail == null || userEmail == "") {
        SnackBars.showError(context, "Error fetching email");
      }
    } catch (e) {
      print("Error fetching user email: $e");
    }
  }

  void _loadInitialPosts() {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      final allPosts = ref.read(postProvider).posts;
      posts = allPosts;
    });
    setState(() {
      _isLoading = false;
    });
  }

  void _onScroll() {
    if (_scrollController!.position.pixels >=
        _scrollController!.position.maxScrollExtent - 200) {
      //loading when 200 px from botton
      if (ref.read(postProvider).hasMorePosts &&
          !ref.read(postProvider).isLoadingMore) {
        _loadMorePosts();
      }
    }
  }

  void _loadMorePosts() async {
    try {
      await ref.read(postProvider).loadMorePosts();
      _loadInitialPosts();
    } catch (e) {
      print("Error loading more posts: $e");
      SnackBars.showError(context, "Error loading more posts");
    }
  }

  void _updateProgress() {
    const oneSec = const Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer t) {
      setState(() {
        _progressValue += 0.1;
        if (_progressValue.toStringAsFixed(1) == '1.0') {
          _isLoading = false;
          t.cancel();
          return;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = ref.watch(postProvider);
    final posts = ref.watch(postProvider).posts;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: posts.isEmpty
          ? Center(
              child: Container(
                padding: EdgeInsets.all(12),
                child: _isLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          LinearProgressIndicator(
                            backgroundColor: Colors.white60,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryColor,
                            ),
                            value: _progressValue,
                          ),
                          SizedBox(),
                          Text("${(_progressValue * 100).round()}%"),
                        ],
                      )
                    : Center(child: Text("No Posts available")),
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount:
                  posts.length +
                  (ref.watch(postProvider).isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == posts.length) {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: primaryColor)),
                    ),
                  );
                }

                final singlePost = posts[index];
                return PostWidget(postModel: singlePost, userEmail: userEmail);
              },
            ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 60),
        child: FloatingActionButton(
          elevation: 2,
          backgroundColor: primaryColor.withOpacity(0.3),
          onPressed: () async {
            setState(() {
              _isLoading = true;
            });
            await ref.read(postProvider).refreshPosts();
            setState(() {
              _isLoading = false;
            });
          },
          tooltip: "Refresh",
          child: _isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Icon(CupertinoIcons.refresh),
        ),
      ),
    );
  }
}
