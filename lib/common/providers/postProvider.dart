import 'dart:io';
import 'dart:math';

import 'package:clubify/common/models/postModel.dart';
import 'package:clubify/common/widgets/scaffolds.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostProvider extends ChangeNotifier with WidgetsBindingObserver {
  List<PostModel> _posts = [];
  final supabase = Supabase.instance.client;
  bool _isInitialized = false;

  //pagination related variables
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;
  int _currentPage = 1;
  final int _postsPerPage = 10;

  //getters
  List<PostModel> get posts => _posts;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMorePosts => _hasMorePosts;
  int get currentPage => _currentPage;

  PostProvider() {
    WidgetsBinding.instance.addObserver(this);
    //loading posts when provider is created at app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadPosts();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _resetPagination() {
    _currentPage = 1;
    _hasMorePosts = true;
    _isLoadingMore = false;
  }

  //loading the posts (at start)
  Future<String?> loadPosts() async {
    final userEmail = supabase.auth.currentUser?.email;
    if (userEmail == null) return null;

    try {
      //reset pagination for fresh load
      _resetPagination();

      final response = await supabase
          .from("postDetails")
          .select()
          .order("created_at", ascending: false)
          .range(0, _postsPerPage - 1);

      final newPosts = (response as List)
          .map((post) => PostModel.fromJson(post))
          .toList();

      _posts = newPosts;
      _isInitialized = true;

      _hasMorePosts = newPosts.length == _postsPerPage;
      notifyListeners();
    } on SocketException {
      // SnackBars.showError(context, "No internet connection");
      return "No internet connection";
    } on PostgrestException catch (e) {
      // SnackBars.showError(context, "Error loading posts");
      print("postgrestException: $e");
      return "Error loading posts";
    } catch (e) {
      // SnackBars.showError(context, "Error occurred");
      print("Error: $e");
      return "Error occurred";
    }
  }

  //load more posts for pagination
  Future<String?> loadMorePosts() async {
    if (_isLoadingMore || !_hasMorePosts) return null;

    final userEmail = supabase.auth.currentUser?.email;
    if (userEmail == null) return null;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;

      final startRange = (_currentPage - 1) * _postsPerPage;
      final endRange = startRange + _postsPerPage - 1;

      final response = await supabase
          .from("postDetails")
          .select()
          .order("created_at", ascending: false)
          .range(startRange, endRange);

      final newPosts = (response as List)
          .map((post) => PostModel.fromJson(post))
          .toList();

      if (newPosts.isNotEmpty) {
        _posts.addAll(newPosts);
        _hasMorePosts = newPosts.length == _postsPerPage;
      } else {
        _hasMorePosts = false;
      }
    } on SocketException {
      return "No internet connection while loading more posts";
    } on PostgrestException catch (e) {
      print("Error loading more posts: $e");
      return "Error loading more posts: $e";
    } catch (e) {
      print("Error occurred: $e");
      return "Error occurred";
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  //delete post
  Future<String?> deletePost(int id) async {
    try {
      await supabase.from("postDetails").delete().eq('id', id);
      _posts.removeWhere((post) => post.id == id);
      notifyListeners();
    } catch (e) {
      print("Error deleting post: $e");
      return "Error deleting post";
    }
  }

  //refresh posts
  Future<void> refreshPosts() async {
    try {
      await loadPosts();
    } catch (e) {
      print("Error refreshing posts: $e");
    }
  }
}

final postProvider = ChangeNotifierProvider<PostProvider>(
  (ref) => PostProvider()
);
