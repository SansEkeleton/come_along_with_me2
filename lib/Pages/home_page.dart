import 'package:come_along_with_me/Pages/group_page.dart';
import 'package:come_along_with_me/Pages/profile_page.dart';
import 'package:come_along_with_me/Pages/users_page.dart';
import 'package:come_along_with_me/cubit/auth/cubit/auth_cubit.dart';
import 'package:come_along_with_me/cubit/user/cubit/user_cubit.dart';
import 'package:come_along_with_me/data/user_model.dart';
import 'package:come_along_with_me/domain/entities/user_entity.dart';
import 'package:come_along_with_me/widgets/TextFieldContainer.dart';
import 'package:come_along_with_me/widgets/custom_tool_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  final String uid;
  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

 

  
  TextEditingController _searchController = TextEditingController();
  PageController _pageViewController = PageController(initialPage: 0);
  bool _isSearch = false;
  int _toolBarPageIndex = 0;

  List<String> _popuMenuList = [
    "Log out",
  ];

  List<Widget> get pages =>
      [GroupPage(), UsersPage(users: [],), ProfilePage(currentUser: UserModel(),)];
  @override
  void dispose() {
    _searchController.dispose();
    _pageViewController.dispose();
    super.dispose();
  }

  Widget _buildSearchWidget() {
    return Container(
        margin: EdgeInsets.only(top: 50),
        height: 40,
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.3),
              blurRadius: 2,
              spreadRadius: 1,
              offset: Offset(0, 0.50)),
        ]),
        child: TextFieldContainerWidget(
          hintText: "Search",
          prefixIcon: Icons.arrow_back,
          keyboardType: TextInputType.text,
          controller: _searchController,
          borderRadius: 0.0,
          color: Colors.white,
          iconClickEvent: () {
            setState(() {
              _isSearch = !_isSearch;
            });
          },
        ));
  }

  Widget _emptyContainer() {
    return Container(
      height: 0,
      width: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: _isSearch == true
              ? Colors.transparent
              : Color.fromRGBO(82, 131, 202, 1),
          title: _isSearch == true ? _emptyContainer() : Text("CAWM"),
          flexibleSpace:
              _isSearch == true ? _buildSearchWidget() : _emptyContainer(),
          actions: _isSearch == true
              ? []
              : [
                  InkWell(
                      onTap: () {
                        setState(
                          () {
                            _isSearch = !_isSearch;
                          },
                        );
                      },
                      child: const Icon(Icons.search)),
                  PopupMenuButton(
                      onSelected: (value) {
                        if (value == "Log out") {
                          BlocProvider.of<AuthCubit>(context).loggedOut();
                        }
                      },
                      itemBuilder: (_) => _popuMenuList.map((menuItem) {
                            return PopupMenuItem(
                              child: Text("$menuItem"),
                              value: menuItem,
                            );
                          }).toList()),
                ],
        ),
        body: BlocBuilder<UserCubit, UserState>(
          builder: (context, userState) {
            
            

            if (userState is UserLoaded){

            final currentUser = userState.users.firstWhere((element) => element.uid == widget.uid, orElse: () => UserModel(),);
            final users = userState.users.where((element) => element.uid != widget.uid).toList();

              return Column(children: [
              _isSearch == true
                  ? _emptyContainer()
                  : CustomToolBarWidget(
                      pageIndex: _toolBarPageIndex,
                      toolBarIndexController: (index) {
                        print("current page $index");
                        setState(() {
                          _toolBarPageIndex = index;
                        });
                        _pageViewController.jumpToPage(index);
                      },
                    ),
              Expanded(
                child: PageView.builder(
                    controller: _pageViewController,
                    onPageChanged: (index) {
                      setState(() {
                        _toolBarPageIndex = index;
                      });
                    },
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      return _switchPage(users:users, currentUser: currentUser);
                    }),
              ),
            ]);
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
  Widget _switchPage({required List<UserEntity> users, required UserEntity currentUser}){
    switch(_toolBarPageIndex){
      case 0:
        return GroupPage();
      case 1:
        return UsersPage(users: users);
      case 2:
        return ProfilePage(currentUser: currentUser,);
      default:
        return Container();
    }
  }
}
