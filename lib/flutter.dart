// import 'dart:io';

// import 'package:flutter/material.dart';

// class Condition {
//   final int id;

//   Condition({required this.id});
// }

// class Example extends StatelessWidget {
//   const Example({super.key});

//   final bool term = true;
//   var anything = '';
//   dynamic another = '';
//   Map<String, dynamic> json = {};

//   static const testA = '';
//   dynamic var test;

//   final Object object = Condition(id: 1);

//   int functionTest(String text) {
//     int value = 0;
//     switch (text) {
//       case '1':
//         value = 1;
//       case '2' when term == false:
//         value = 2;
//       default:
//         value = 3;
//     }

//     return value;
//   }

//   int functionTest2(String text) {
//     return switch (text) {
//       '1' => 1,
//       '2' when term == false => 2,
//       _ => 3,
//     };
//   }

//   int doSome(Object a) {
//     if (a case Condition(:final id) when term == true) {
//       return id;
//     }

//     if (a is Condition) return a.id;

//     if (a is! Condition) return 1;

//     anything = '';
//     another = 1;

//     return 0;
//   }

//   @override
//   Widget build(BuildContext context) {
    
//     return Column(
//       children: [
//         Container(),
//         if (term) const Text('', style: TextStyle(color: context.theme.text.colors.primary)),
//         if (term) ...[
//           const Text(''),
//           const Icon(IconData(1)),
//         ],
//         term ? const Text('true') : const Text('false')
//       ],
//     );
//   }
// }

// class MyWidget extends StatefulWidget {
//   const MyWidget({super.key});

//   @override
//   State<MyWidget> createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<MyWidget> {
//   late final value;
//   final name = 0;
//   @override
//   void initState() {
//     value = 1;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

// sealed class EstadoBase {
//   final id = 1;
// }

// class EstadoX extends EstadoBase {
//   void some() {
//     var a = id;
//   }
// }

// abstract interface class Repository {
//   Future<Result<RepositorySuccess, RepositoryFailure>> iDoSomething();
// }

// class RepositoryImpl implements Repository {
//   @override
//   Future<Result<RepositorySuccess, RepositoryFailure>> iDoSomething() async {
//     final term = await Future.delayed(Duration(milliseconds: 100));
//     if (term case HttpException(:final message)) {
//       return Result(RepositoryHttpFailure(code: message));
//     }

//     return Result(,RepositorySuccess());
//     // TODO: implement iDoSomething
//   }
// }

// class Result<Success, Failure> {
//   Result(Failure failure, Success success);
// }

// class Success extends Object {}

// class Failure extends Object {}

// class RepositorySuccess extends Success {}

// sealed class RepositoryFailure extends Failure {}

// class RepositoryHttpFailure extends RepositoryFailure {
//   final String code;

//   RepositoryHttpFailure({required this.code});
// }

// class RepositoryTimeoutFailure extends RepositoryFailure {}
