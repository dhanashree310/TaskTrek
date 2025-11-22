import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class GoogleCalendarService {
  final AuthService _authService;

  GoogleCalendarService(this._authService);

  /// Get authenticated Calendar API client
  Future<cal.CalendarApi?> getCalendarApi() async {
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) return null;

    final client = _AuthClient(accessToken);
    return cal.CalendarApi(client);
  }

  /// Create a calendar event
  Future<void> createEvent({
    required String title,
    required String description,
    required DateTime start,
    required DateTime end,
  }) async {
    final calendarApi = await getCalendarApi();
    if (calendarApi == null) return;

    final event = cal.Event()
      ..summary = title
      ..description = description
      ..start = cal.EventDateTime(dateTime: start)
      ..end = cal.EventDateTime(dateTime: end);

    await calendarApi.events.insert(event, 'primary');
  }

  /// Fetch upcoming events
  Future<List<cal.Event>> fetchUpcomingEvents({int maxResults = 10}) async {
    final calendarApi = await getCalendarApi();
    if (calendarApi == null) return [];

    final events = await calendarApi.events.list(
      'primary',
      maxResults: maxResults,
      singleEvents: true,
      orderBy: 'startTime',
      timeMin: DateTime.now().toUtc(),
    );

    return events.items ?? [];
  }
}

/// Simple HTTP client that adds the Bearer token
class _AuthClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _inner = http.Client();

  _AuthClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _inner.send(request);
  }
}
