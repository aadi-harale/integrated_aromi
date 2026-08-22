// ── API Models for AROMI ──
// Typed Dart models matching the backend schemas exactly.

// ── Worker ──
class Worker {
  final int id;
  final String name;
  final String email;
  final String centreId;
  final String centreName;
  final String? village;
  final String? district;

  Worker({
    required this.id,
    required this.name,
    required this.email,
    required this.centreId,
    required this.centreName,
    this.village,
    this.district,
  });

  factory Worker.fromJson(Map<String, dynamic> json) => Worker(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        centreId: json['centre_id'] as String,
        centreName: json['centre_name'] as String,
        village: json['village'] as String?,
        district: json['district'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'centre_id': centreId,
        'centre_name': centreName,
        'village': village,
        'district': district,
      };
}

// ── Token ──
class AuthToken {
  final String accessToken;
  final String tokenType;

  AuthToken({required this.accessToken, this.tokenType = 'bearer'});

  factory AuthToken.fromJson(Map<String, dynamic> json) => AuthToken(
        accessToken: json['access_token'] as String,
        tokenType: json['token_type'] as String? ?? 'bearer',
      );
}

// ── Child ──
class Child {
  final int id;
  final String name;
  final String dob;
  final String? gender;
  final String? parentName;
  final double? currentWeightKg;
  final double? currentHeightCm;
  final double? currentMuacCm;
  final String nutritionStatus;
  final String riskLevel;
  final bool immunisationUpToDate;
  final bool phcReferred;
  final int? ageMonths;

  Child({
    required this.id,
    required this.name,
    required this.dob,
    this.gender,
    this.parentName,
    this.currentWeightKg,
    this.currentHeightCm,
    this.currentMuacCm,
    this.nutritionStatus = 'unknown',
    this.riskLevel = 'low',
    this.immunisationUpToDate = false,
    this.phcReferred = false,
    this.ageMonths,
  });

  factory Child.fromJson(Map<String, dynamic> json) => Child(
        id: json['id'] as int,
        name: json['name'] as String,
        dob: json['dob'] as String,
        gender: json['gender'] as String?,
        parentName: json['parent_name'] as String?,
        currentWeightKg: (json['current_weight_kg'] as num?)?.toDouble(),
        currentHeightCm: (json['current_height_cm'] as num?)?.toDouble(),
        currentMuacCm: (json['current_muac_cm'] as num?)?.toDouble(),
        nutritionStatus: json['nutrition_status'] as String? ?? 'unknown',
        riskLevel: json['risk_level'] as String? ?? 'low',
        immunisationUpToDate: json['immunisation_up_to_date'] as bool? ?? false,
        phcReferred: json['phc_referred'] as bool? ?? false,
        ageMonths: json['age_months'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dob': dob,
        'gender': gender,
        'parent_name': parentName,
        'current_weight_kg': currentWeightKg,
        'current_height_cm': currentHeightCm,
        'current_muac_cm': currentMuacCm,
        'nutrition_status': nutritionStatus,
        'risk_level': riskLevel,
        'immunisation_up_to_date': immunisationUpToDate,
        'phc_referred': phcReferred,
        'age_months': ageMonths,
      };

  String get displayAge {
    if (ageMonths == null) return '';
    final years = ageMonths! ~/ 12;
    final months = ageMonths! % 12;
    if (years > 0 && months > 0) return '$years yr $months mo';
    if (years > 0) return '$years yr';
    return '$months mo';
  }

  String get genderLabel {
    if (gender == 'M') return 'Male';
    if (gender == 'F') return 'Female';
    return gender ?? '';
  }
}

// ── Child Create ──
class ChildCreate {
  final String name;
  final String dob;
  final String? gender;
  final String? parentName;
  final String? parentPhone;
  final String? address;

  ChildCreate({
    required this.name,
    required this.dob,
    this.gender,
    this.parentName,
    this.parentPhone,
    this.address,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'dob': dob,
        'gender': gender,
        'parent_name': parentName,
        'parent_phone': parentPhone,
        'address': address,
      };
}

// ── Growth Record ──
class GrowthRecord {
  final int id;
  final int childId;
  final String recordedDate;
  final double? weightKg;
  final double? heightCm;
  final double? muacCm;
  final String nutritionStatus;
  final double? waz;
  final double? haz;
  final double? whz;
  final String? shapExplanation;
  final String? aiNotes;

  GrowthRecord({
    required this.id,
    required this.childId,
    required this.recordedDate,
    this.weightKg,
    this.heightCm,
    this.muacCm,
    this.nutritionStatus = 'unknown',
    this.waz,
    this.haz,
    this.whz,
    this.shapExplanation,
    this.aiNotes,
  });

  factory GrowthRecord.fromJson(Map<String, dynamic> json) => GrowthRecord(
        id: json['id'] as int,
        childId: json['child_id'] as int,
        recordedDate: json['recorded_date'] as String,
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        heightCm: (json['height_cm'] as num?)?.toDouble(),
        muacCm: (json['muac_cm'] as num?)?.toDouble(),
        nutritionStatus: json['nutrition_status'] as String? ?? 'unknown',
        waz: (json['waz'] as num?)?.toDouble(),
        haz: (json['haz'] as num?)?.toDouble(),
        whz: (json['whz'] as num?)?.toDouble(),
        shapExplanation: json['shap_explanation'] as String?,
        aiNotes: json['ai_notes'] as String?,
      );
}

// ── Growth Record Create ──
class GrowthRecordCreate {
  final int childId;
  final String recordedDate;
  final double? weightKg;
  final double? heightCm;
  final double? muacCm;

  GrowthRecordCreate({
    required this.childId,
    required this.recordedDate,
    this.weightKg,
    this.heightCm,
    this.muacCm,
  });

  Map<String, dynamic> toJson() => {
        'child_id': childId,
        'recorded_date': recordedDate,
        if (weightKg != null) 'weight_kg': weightKg,
        if (heightCm != null) 'height_cm': heightCm,
        if (muacCm != null) 'muac_cm': muacCm,
      };
}

// ── Dashboard Stats ──
class DashboardStats {
  final int totalChildren;
  final int presentToday;
  final int mamCount;
  final int samCount;
  final int normalCount;
  final int visitsDueToday;
  final double workerHoursSaved;
  final double reportsAutomatedPct;

  DashboardStats({
    required this.totalChildren,
    required this.presentToday,
    required this.mamCount,
    required this.samCount,
    required this.normalCount,
    required this.visitsDueToday,
    required this.workerHoursSaved,
    required this.reportsAutomatedPct,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        totalChildren: json['total_children'] as int? ?? 0,
        presentToday: json['present_today'] as int? ?? 0,
        mamCount: json['mam_count'] as int? ?? 0,
        samCount: json['sam_count'] as int? ?? 0,
        normalCount: json['normal_count'] as int? ?? 0,
        visitsDueToday: json['visits_due_today'] as int? ?? 0,
        workerHoursSaved: (json['worker_hours_saved'] as num?)?.toDouble() ?? 0,
        reportsAutomatedPct:
            (json['reports_automated_pct'] as num?)?.toDouble() ?? 0,
      );
}

// ── Attendance ──
class AttendanceRecord {
  final int? id;
  final int childId;
  final String date;
  bool present;
  bool mealGiven;
  final String? notes;

  AttendanceRecord({
    this.id,
    required this.childId,
    required this.date,
    this.present = true,
    this.mealGiven = false,
    this.notes,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        id: json['id'] as int?,
        childId: json['child_id'] as int,
        date: json['date'] as String,
        present: json['present'] as bool? ?? true,
        mealGiven: json['meal_given'] as bool? ?? false,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'child_id': childId,
        'date': date,
        'present': present,
        'meal_given': mealGiven,
        if (notes != null) 'notes': notes,
      };
}

// ── Home Visit ──
class HomeVisit {
  final int id;
  final int childId;
  final String? scheduledDate;
  final String? visitedDate;
  final bool completed;
  final String priority;
  final String? visitReason;
  final String? findings;
  final String? actionsTaken;
  final String? nextVisitDue;

  // Joined child name for display
  final String? childName;

  HomeVisit({
    required this.id,
    required this.childId,
    this.scheduledDate,
    this.visitedDate,
    this.completed = false,
    this.priority = 'low',
    this.visitReason,
    this.findings,
    this.actionsTaken,
    this.nextVisitDue,
    this.childName,
  });

  factory HomeVisit.fromJson(Map<String, dynamic> json) => HomeVisit(
        id: json['id'] as int,
        childId: json['child_id'] as int,
        scheduledDate: json['scheduled_date'] as String?,
        visitedDate: json['visited_date'] as String?,
        completed: json['completed'] as bool? ?? false,
        priority: json['priority'] as String? ?? 'low',
        visitReason: json['visit_reason'] as String?,
        findings: json['findings'] as String?,
        actionsTaken: json['actions_taken'] as String?,
        nextVisitDue: json['next_visit_due'] as String?,
        childName: json['child_name'] as String?,
      );
}

// ── Voice Response ──
class VoiceResponse {
  final String transcribedText;
  final String detectedIntent;
  final Map<String, dynamic> extractedEntities;
  final String agentResponseText;
  final String? language;

  // Derived fields for Flutter UI
  String get mode {
    final intent = detectedIntent.toLowerCase();
    if (intent == 'log_weight') return 'pending_action';
    if (intent.startsWith('navigate_')) return 'navigate';
    if (intent.startsWith('list_') || intent.startsWith('get_cases') || intent.startsWith('search_')) {
      return 'list';
    }
    return 'answer';
  }

  String? get route {
    switch (detectedIntent.toLowerCase()) {
      case 'navigate_dashboard':
        return '/home';
      case 'navigate_cases':
        return '/records';
      case 'navigate_alerts':
        return '/alerts';
      case 'navigate_reports':
        return '/more/reports';
      case 'navigate_profile':
        return '/more/profile';
      default:
        return null;
    }
  }

  VoiceResponse({
    required this.transcribedText,
    required this.detectedIntent,
    required this.extractedEntities,
    required this.agentResponseText,
    this.language,
  });

  factory VoiceResponse.fromJson(Map<String, dynamic> json) => VoiceResponse(
        transcribedText: json['transcribed_text'] as String? ?? '',
        detectedIntent: json['detected_intent'] as String? ?? 'general_query',
        extractedEntities:
            (json['extracted_entities'] as Map<String, dynamic>?) ?? {},
        agentResponseText: json['agent_response_text'] as String? ?? '',
        language: json['language'] as String?,
      );
}

// ── Voice Log ──
class VoiceLog {
  final int id;
  final String? transcribedText;
  final String? detectedIntent;
  final String? extractedEntities;
  final String? agentResponseText;
  final bool success;
  final String? createdAt;

  VoiceLog({
    required this.id,
    this.transcribedText,
    this.detectedIntent,
    this.extractedEntities,
    this.agentResponseText,
    this.success = true,
    this.createdAt,
  });

  factory VoiceLog.fromJson(Map<String, dynamic> json) => VoiceLog(
        id: json['id'] as int,
        transcribedText: json['transcribed_text'] as String?,
        detectedIntent: json['detected_intent'] as String?,
        extractedEntities: json['extracted_entities'] as String?,
        agentResponseText: json['agent_response_text'] as String?,
        success: json['success'] as bool? ?? true,
        createdAt: json['created_at'] as String?,
      );
}

// ── MPR Report ──
class MPReport {
  final int? mprId;
  final int month;
  final int year;
  final int totalChildren;
  final int normalCount;
  final int mamCount;
  final int samCount;
  final double avgAttendancePct;
  final int homeVisitsCompleted;
  final int phcReferrals;
  final int immunisationCompleted;
  final String? summaryHindi;

  MPReport({
    this.mprId,
    required this.month,
    required this.year,
    required this.totalChildren,
    required this.normalCount,
    required this.mamCount,
    required this.samCount,
    required this.avgAttendancePct,
    required this.homeVisitsCompleted,
    required this.phcReferrals,
    required this.immunisationCompleted,
    this.summaryHindi,
  });

  factory MPReport.fromJson(Map<String, dynamic> json) => MPReport(
        mprId: json['mpr_id'] as int?,
        month: json['month'] as int,
        year: json['year'] as int,
        totalChildren: json['total_children'] as int? ?? 0,
        normalCount: json['normal_count'] as int? ?? 0,
        mamCount: json['mam_count'] as int? ?? 0,
        samCount: json['sam_count'] as int? ?? 0,
        avgAttendancePct:
            (json['avg_attendance_pct'] as num?)?.toDouble() ?? 0,
        homeVisitsCompleted: json['home_visits_completed'] as int? ?? 0,
        phcReferrals: json['phc_referrals'] as int? ?? 0,
        immunisationCompleted: json['immunisation_completed'] as int? ?? 0,
        summaryHindi: json['summary_hindi'] as String?,
      );
}

// ── Activity Plan ──
class ActivityPlan {
  final int? planId;
  final Map<String, dynamic>? plan;
  final String? language;
  final String? message;

  ActivityPlan({this.planId, this.plan, this.language, this.message});

  factory ActivityPlan.fromJson(Map<String, dynamic> json) => ActivityPlan(
        planId: json['plan_id'] as int?,
        plan: json['plan'] as Map<String, dynamic>?,
        language: json['language'] as String?,
        message: json['message'] as String?,
      );
}

// ── RAG Response ──
class RAGResponse {
  final String answer;
  final List<String> sources;
  final String language;

  RAGResponse({
    required this.answer,
    required this.sources,
    required this.language,
  });

  factory RAGResponse.fromJson(Map<String, dynamic> json) => RAGResponse(
        answer: json['answer'] as String? ?? '',
        sources: (json['sources'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        language: json['language'] as String? ?? 'hindi',
      );
}

// ── Pending Voice Action ──
class PendingVoiceAction {
  final String actionType; // 'growth_record', 'update_child', etc.
  final int? childId;
  final String? childName;
  final Map<String, dynamic> newValues;
  final Map<String, dynamic>? currentValues;
  final String transcription;
  final bool isSuspicious;
  final String? warningMessage;

  PendingVoiceAction({
    required this.actionType,
    this.childId,
    this.childName,
    required this.newValues,
    this.currentValues,
    required this.transcription,
    this.isSuspicious = false,
    this.warningMessage,
  });
}
