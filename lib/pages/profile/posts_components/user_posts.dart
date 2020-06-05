import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yourpage/components/posts_components/post_card.dart';
import 'package:yourpage/models/comment.dart';
import 'package:yourpage/services/firestore.dart';
import 'package:yourpage/shared/loader.dart';

class UserPosts extends StatefulWidget {
  final user;

  UserPosts(this.user);

  @override
  _UserPostsState createState() => _UserPostsState();
}

class _UserPostsState extends State<UserPosts> {
  List _latestPosts = new List();
  String uid;
  bool _showLoader;
  int _postsListLength = 0;
  bool _isLastPost = false;
  DocumentSnapshot _lastDocument;
  ScrollController _scrollController = ScrollController();

  _getPosts() {
    bool found = false;
    _showLoader = true;
    FirestoreService()
        .getUserPosts(widget.user, _lastDocument)
        .snapshots()
        .listen((querySnapshot) => {
              querySnapshot.documents.forEach((newPost) => {
                    _latestPosts.asMap().forEach((index, post) => {
                          if (_latestPosts[index]['postId'] ==
                              newPost.data['postId'])
                            {
                              _latestPosts[index] = newPost.data,
                              found = true,
                            }
                        }),
                    if (!found)
                      {
                        _latestPosts.add(newPost.data),
                        _postsListLength = _postsListLength + 1,
                      },
                  }),
              if (_postsListLength == _latestPosts.length)
                {
                  setState(() {
                    _showLoader = false;
                  })
                }
            });
  }

  @override
  void initState() {
    _getPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !_showLoader &&
          !_isLastPost) {
        _getPosts();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.uid = Provider.of<String>(context);
    return !_showLoader
        ? _latestPosts.length == 0
            ? Text(
                'USER HAS NO POSTS',
                style: TextStyle(color: Colors.white),
              )
            : Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: <Widget>[
                    SliverAppBar(
                      title: Text('Posts'),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Container(
                          padding: EdgeInsets.only(bottom: 20),
                          child:
                              PostCard(_latestPosts[index], widget.user, index),
                        );
                      }, childCount: _latestPosts.length),
                    )
                  ],
                ),
              )
        : Loader();
  }
}
