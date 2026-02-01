class Api {
  // 🌐 Base URL (change IP to your Flask server LAN IP)
  static const String baseUrl = "http://127.0.0.1:5000";

  // ---------------- Q/A ----------------
  static String getAnswerWithId(int id) => "$baseUrl/Ans/getanswer/$id";

  // CFG
  static const String getCfgRules = "$baseUrl/nlp/get-rules";
  static const String getPosTags = "$baseUrl/nlp/get-pos-tags";
  static const String addRule = "$baseUrl/nlp/add-rule";
  static const String validateCFG = "$baseUrl/nlp/validate";

  // Vocabulary
  static const String addVocabulary = "$baseUrl/nlp/add-vocabulary";

  // Users
  static const String seeAllBlinds = "$baseUrl/user/blind-with-assistant";
  static const String seeAllAssistants = "$baseUrl/user/assis";

  // ---------------- Assistant ----------------
  static const String assistantLogin = "$baseUrl/user/login";
  static const assistantSignup = "$baseUrl/user/assis/create";


// ---------------- Blind ----------------
static const blindSignup = "$baseUrl/user/blinds/create";

  // Blinds route (for fetching blind assigned to Specific assistant)
  static String getBlindsByAssistant(int assistantId) =>
      "$baseUrl/user/assistant/$assistantId/blinds";


  // Add Person (Create Contact with Pics)
  static String createContactWithPics = "$baseUrl/contacts/create-with-pics";

  // Assistant Home (Fetch all contacts for a blind user with pics)
  static String getContactsWithPics(int blindId) =>
      "$baseUrl/contacts/$blindId/with-pics";

//Interaction Log
  static String getInteractionLogs(int assistantId) =>
      "$baseUrl/blind/getHistory/$assistantId";

 //Transcribe Service for Q/A
   static const String sttTranscribe = "$baseUrl/audio/transcribe";

 //Transcribe Service for Q/A
   static const String sttCommand = "$baseUrl/audio/voice/command";  
      
}
