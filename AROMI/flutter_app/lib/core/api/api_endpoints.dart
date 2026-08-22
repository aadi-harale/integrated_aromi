/// API endpoint constants for the AROMI backend.
class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';

  // Children
  static const String children = '/children/';
  static String child(int id) => '/children/$id';

  // Growth
  static const String growthRecord = '/growth/record';
  static String growthHistory(int childId) => '/growth/child/$childId';

  // Dashboard
  static const String dashboardStats = '/dashboard/stats';

  // Voice
  static const String voiceProcess = '/voice/process';
  static const String voiceLogs = '/voice/logs';

  // Attendance
  static const String attendanceBulk = '/attendance/bulk';
  static const String attendanceToday = '/attendance/today';

  // Activity
  static const String activityGenerate = '/activity/generate';
  static const String activityToday = '/activity/today';

  // MPR
  static const String mprGenerate = '/mpr/generate';

  // RAG
  static const String ragQuery = '/rag/query';
  static const String ragSources = '/rag/sources';

  // Agent
  static const String agentEvents = '/agent/events';
  static const String agentPipelineStatus = '/agent/pipeline/status';

  // Photo
  static const String photoCheck = '/photo/check';
  static const String photoCheckDemo = '/photo/check-demo';

  // Visits
  static const String visits = '/visits/';
  static const String visitsDue = '/visits/due';
}
