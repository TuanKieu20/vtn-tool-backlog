import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vtn_web_backlog/repository/home_repo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, widget) {
        return OKToast(child: widget!);
      },
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

//id 146648

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String text = '';
  final TextEditingController controller = TextEditingController();
  final List<String> listAppCreatedSuccess = [];

  void _incrementCounter() async {
    // final result = await HomeRepository.instance
    //     .createProject(name: 'ProjectTest', key: 'App993');
    //add teamAdmin
    // final result =
    //     await HomeRepository.instance.addAdminToProject(projectId: '146648');
    // create issue type
    // final result = await HomeRepository.instance
    //     .createMulitiIssuesType(projectId: '146648');
    //
    // final result =
    //     await HomeRepository.instance.createWiki(projectId: '146648');
    // print(result.body);
    // text = result.bodyString!;
    // setState(() {});
  }

  Future<bool> createTemplate() async {
    if (controller.text.isEmpty) {
      _showToast('Vui lòng nhập thông tin !!!');
      return false;
    }
    final List<String> listApps = controller.text.split('\n');
    for (final item in listApps) {
      final List<String> parts = item.split('-');
      if (parts.length > 2 || parts.first == item) {
        _showToast('Err: $item is valid !!!');
      } else {
        final Response? responseProject = await HomeRepository.instance
            .createProject(name: parts.last, key: parts.first);
        if (responseProject == null) {
          _showToast('Err: Please try again!!!');
          return false;
        }
        final String projectId = responseProject.body['id'].toString();
        final List<bool> result =await Future.wait([
          HomeRepository.instance.addAdminToProject(projectId: projectId),
          HomeRepository.instance.createMulitiIssuesType(projectId: projectId),
          HomeRepository.instance.createWiki(projectId: projectId),
        ]);
        if(!result.every((e)=>e==true)){
          print('error');
          return false;
        }
        listAppCreatedSuccess.add('$item - $projectId');
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Nhập tên ứng dụng muốn tạo:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 6),
                  Text(
                    '(Enter để nhập nhiều ứng dụng)',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 24),
              TextField(
                controller: controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                    hintText: 'Example: Appxxx-ProjectName',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
              ),
              SizedBox(height: 28),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final result = await createTemplate();
                    if (result) {
                      _showToast('Add Project Success !!!');
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 64),
                    decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showToast(String msg) {
    showToast(
      msg,
      textStyle: TextStyle(
        fontSize: 20,
        color: Colors.white,
      ),
      textPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      position: ToastPosition.bottom,
    );
  }
}
