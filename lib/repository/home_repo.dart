import 'package:get/get.dart';

import '../constants/app_constants.dart';
import '../services/http_service.dart';

class HomeRepository {
  HomeRepository._();
  static final HomeRepository instance = HomeRepository._();
  final ApiClient _apiClient = ApiClient();

  Future<Response?> createProject({
    required String name,
    required String key,
  }) async {
    try {
      final String endpoint = '/projects?apiKey=${AppConstants.apiKey}';
      Map<String, dynamic>? params = {
        "name": name,
        "key": key.toUpperCase(),
        "chartEnabled": true,
        "subtaskingEnabled": true,
        "projectLeaderCanEditProjectLeader": false,
        "textFormattingRule": "markdown"
      };
     final Response res =  await _apiClient.postData(null, endpoint, params);
      return res;
    } catch (_) {
      return null;
    }
  }

  Future<bool> addAdminToProject({required String projectId}) async {
    try {
      final String endpoint =
          '/projects/$projectId/teams?apiKey=${AppConstants.apiKey}';
      Map<String, dynamic>? params = {
        "teamId": AppConstants.adminTeamId,
      };
      await _apiClient.postData(null, endpoint, params);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createMulitiIssuesType({required String projectId}) async {
    try {
      final issues = [
        "Lên danh sách chức năng của dự án",
        "Thiết kế design chi tiết các chức năng",
        "Dev các chức năng của dự án, chia nhỏ theo subtasks",
        "Tạo graphics request",
        "Tạo ASO document",
        "Thiết kế appicon và SRC",
        "Test các chức năng",
        "Lên kịch bản ads",
        "Gắn ads theo kịch bản",
        "Release ver đầu tiên"
      ];

      final Response? resIssuesList = await getIssueTypes(projectId: projectId);
      if (resIssuesList == null) {
        return false;
      }
      final List<dynamic> issuesTask = (resIssuesList.body as List)
          .where((item) => item['name'] == 'Task')
          .toList();
      await Future.wait(
        issues.map(
          (issue) => createIssueType(
            projectId: projectId,
            issueName: issue,
            issueTypeId: issuesTask.first['id'].toString(),
          ),
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Response> createIssueType({
    required String issueName,
    required String projectId,
    required String issueTypeId,
  }) async {
    final String endpoint = '/issues?apiKey=${AppConstants.apiKey}';

    Map<String, dynamic>? params = {
      "projectId": projectId,
      "summary": issueName,
      "issueTypeId": issueTypeId,
      "priorityId": 3
    };

    final Response response = await _apiClient.postData(
      null,
      endpoint,
      params,
    );

    return response;
  }

  Future<Response?> getIssueTypes({
    required String projectId,
  }) async {
    try {
      final String endpoint =
          '/projects/$projectId/issueTypes?apiKey=${AppConstants.apiKey}';
      final Response response = await _apiClient.getData(
        null,
        endpoint,
      );
      return response;
    } catch (_) {
      return null;
    }
  }

  Future<Response?> getWiki({required String projectId}) async {
    try {
      final String endPoint =
          '/wikis?projectIdOrKey=$projectId&apiKey=${AppConstants.apiKey}';
      final Response res = await _apiClient.getData(null, endPoint);
      return res;
    } catch (_) {
      return null;
    }
  }

  Future<bool> createWiki({required String projectId}) async {
    try {
      final Response? res = await getWiki(projectId: projectId);
      if (res == null) {
        return false;
      }
      final dynamic wiki =
          (res.body as List).where((e) => e['name'] == 'Home').toList().first;
      final String endPoint =
          '/wikis/${wiki['id']}?apiKey=${AppConstants.apiKey}';
      final String content = """
| STT  | Nội dung | Link |
| ------------- | ------------- | ------------- |
| 1  | Function List  |  |
| 2  | Design  |  |
| 3  | Git  |  |
| 4  | Graphics request  |  |
| 5  | Graphics  |  |
| 6  | ASO  |  |
| 7  | List Bugs  |  |
| 8  | Kb Ads  |  |
| 9  | Store Url |  |
| 10  | Request Update |  |
""";
      final Map<String, dynamic> params = {
        "name": "Resources Link",
        "content": content,
      };
      await _apiClient.patchData(null, endPoint, params);
      return true;
    } catch (_) {
      return false;
    }
  }
}
