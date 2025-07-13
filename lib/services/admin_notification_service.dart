import 'package:dio/dio.dart';
import 'admin_account_service.dart';

class NotificationService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://localhost:3000';

  NotificationService() {
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  // Gửi thông báo đến một user
  Future<bool> sendNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/send-notification',
        data: {
          'userId': userId,
          'title': title,
          'body': body,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error sending notification to $userId: $e');
      return false;
    }
  }

  // Gửi thông báo đến danh sách user
  Future<Map<String, bool>> sendBulkNotifications({
    required List<String> userIds,
    required String title,
    required String body,
  }) async {
    Map<String, bool> results = {};

    final futures = userIds.map((userId) async {
      final success = await sendNotification(userId: userId, title: title, body: body);
      results[userId] = success;
    });

    await Future.wait(futures);
    return results;
  }

  // Gửi thông báo đến tất cả người dùng
  Future<bool> sendNotificationToAllUsers({
    required String title,
    required String body,
    required AdminAccountService accountService,
  }) async {
    try {
      final users = await accountService.getAllUsers();
      if (users.isEmpty) return false;

      await Future.wait(users.map((user) {
        return sendNotification(
          userId: user.id.toString(), // Sử dụng user.id thay vì user.userId
          title: title,
          body: body,
        );
      }));

      return true;
    } catch (e) {
      print('❌ Error sending to all users: $e');
      return false;
    }
  }
}
