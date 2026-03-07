import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// No description provided for @about_verd.
  ///
  /// In en, this message translates to:
  /// **'About VERD'**
  String get about_verd;

  /// No description provided for @account_overview.
  ///
  /// In en, this message translates to:
  /// **'Account Overview'**
  String get account_overview;

  /// No description provided for @ai_insights.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get ai_insights;

  /// No description provided for @ai_insights_title.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Insights'**
  String get ai_insights_title;

  /// No description provided for @analysis_complete.
  ///
  /// In en, this message translates to:
  /// **'Analysis complete!'**
  String get analysis_complete;

  /// No description provided for @analyzing_crop.
  ///
  /// In en, this message translates to:
  /// **'Analyzing crop...'**
  String get analyzing_crop;

  /// No description provided for @analyzing_delay_desc.
  ///
  /// In en, this message translates to:
  /// **'This may take a few seconds'**
  String get analyzing_delay_desc;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @article_action_a.
  ///
  /// In en, this message translates to:
  /// **'Remove and burn any infected leaves immediately. Do not leave them on the ground. Wash your hands and tools after touching the sick plant.'**
  String get article_action_a;

  /// No description provided for @article_action_q.
  ///
  /// In en, this message translates to:
  /// **'2. Immediate Action'**
  String get article_action_q;

  /// No description provided for @article_library.
  ///
  /// In en, this message translates to:
  /// **'Learning Center'**
  String get article_library;

  /// No description provided for @article_look_a.
  ///
  /// In en, this message translates to:
  /// **'Look for small, brown spots on older leaves. These spots grow larger and look like a target with rings inside them. The leaves may turn yellow and fall off early.'**
  String get article_look_a;

  /// No description provided for @article_look_q.
  ///
  /// In en, this message translates to:
  /// **'1. What does it look like?'**
  String get article_look_q;

  /// No description provided for @article_treatment_a.
  ///
  /// In en, this message translates to:
  /// **'Space your crops further apart so wind can dry the leaves. Water the soil directly, not the leaves. Use an organic copper fungicide if the problem spreads to the stems.'**
  String get article_treatment_a;

  /// No description provided for @article_treatment_q.
  ///
  /// In en, this message translates to:
  /// **'3. Long-term Treatment'**
  String get article_treatment_q;

  /// No description provided for @audio_guide.
  ///
  /// In en, this message translates to:
  /// **'AUDIO GUIDE'**
  String get audio_guide;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @back_online.
  ///
  /// In en, this message translates to:
  /// **'Back online'**
  String get back_online;

  /// No description provided for @back_to_login.
  ///
  /// In en, this message translates to:
  /// **'BACK TO LOGIN'**
  String get back_to_login;

  /// No description provided for @based_on_history.
  ///
  /// In en, this message translates to:
  /// **'Based on your farming history'**
  String get based_on_history;

  /// No description provided for @call_us.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get call_us;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @change_language.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get change_language;

  /// No description provided for @change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get change_password;

  /// No description provided for @confidence_label.
  ///
  /// In en, this message translates to:
  /// **'Confidence: '**
  String get confidence_label;

  /// No description provided for @confirm_new_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirm_new_password;

  /// No description provided for @contact_us.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contact_us;

  /// No description provided for @copy_token.
  ///
  /// In en, this message translates to:
  /// **'Copy FCM Token'**
  String get copy_token;

  /// No description provided for @crop_diseases.
  ///
  /// In en, this message translates to:
  /// **'Crop Diseases'**
  String get crop_diseases;

  /// No description provided for @crop_diseases_desc_short.
  ///
  /// In en, this message translates to:
  /// **'Common diseases'**
  String get crop_diseases_desc_short;

  /// No description provided for @crop_diversity.
  ///
  /// In en, this message translates to:
  /// **'Crop Diversity'**
  String get crop_diversity;

  /// No description provided for @crop_identification.
  ///
  /// In en, this message translates to:
  /// **'Crop Identification'**
  String get crop_identification;

  /// No description provided for @crop_types.
  ///
  /// In en, this message translates to:
  /// **'Crop Types'**
  String get crop_types;

  /// No description provided for @current_password.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get current_password;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @debug_token_desc.
  ///
  /// In en, this message translates to:
  /// **'Use this to send test messages from Firebase Console'**
  String get debug_token_desc;

  /// No description provided for @debug_tools.
  ///
  /// In en, this message translates to:
  /// **'Debug Tools'**
  String get debug_tools;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @detected_issues.
  ///
  /// In en, this message translates to:
  /// **'Detected Issues'**
  String get detected_issues;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @discard_changes_desc.
  ///
  /// In en, this message translates to:
  /// **'Your unsaved changes will be lost.'**
  String get discard_changes_desc;

  /// No description provided for @discard_changes_q.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes?'**
  String get discard_changes_q;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @early_detection_desc.
  ///
  /// In en, this message translates to:
  /// **'Scan your crops regularly to catch diseases before they spread'**
  String get early_detection_desc;

  /// No description provided for @early_detection_title.
  ///
  /// In en, this message translates to:
  /// **'Early Detection Matters'**
  String get early_detection_title;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @email_hint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get email_hint;

  /// No description provided for @email_me_link.
  ///
  /// In en, this message translates to:
  /// **'Email me a link'**
  String get email_me_link;

  /// No description provided for @email_notifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get email_notifications;

  /// No description provided for @email_notifications_desc.
  ///
  /// In en, this message translates to:
  /// **'Receive updates via email'**
  String get email_notifications_desc;

  /// No description provided for @email_support.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get email_support;

  /// No description provided for @enter_current_password.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get enter_current_password;

  /// No description provided for @enter_email_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address.'**
  String get enter_email_error;

  /// No description provided for @enter_email_link_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email to receive a sign-in link.'**
  String get enter_email_link_error;

  /// No description provided for @enter_new_password.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enter_new_password;

  /// No description provided for @enter_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enter_password_hint;

  /// No description provided for @error_generic_desc.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.\nPlease try again.'**
  String get error_generic_desc;

  /// No description provided for @error_generic_title.
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get error_generic_title;

  /// No description provided for @explore_categories.
  ///
  /// In en, this message translates to:
  /// **'Explore Categories'**
  String get explore_categories;

  /// No description provided for @faq_accuracy_a.
  ///
  /// In en, this message translates to:
  /// **'Our AI model has been trained on thousands of crop images and maintains a 95% accuracy rate for common crop diseases.'**
  String get faq_accuracy_a;

  /// No description provided for @faq_accuracy_q.
  ///
  /// In en, this message translates to:
  /// **'How accurate is the disease detection?'**
  String get faq_accuracy_q;

  /// No description provided for @faq_offline_a.
  ///
  /// In en, this message translates to:
  /// **'Yes! Enable offline mode in settings. Previously downloaded disease data will be available for scanning.'**
  String get faq_offline_a;

  /// No description provided for @faq_offline_q.
  ///
  /// In en, this message translates to:
  /// **'Can I use the app offline?'**
  String get faq_offline_q;

  /// No description provided for @faq_scan_a.
  ///
  /// In en, this message translates to:
  /// **'Go to the Scan tab, position your crop within the frame, and tap the camera button. The app will analyze the image and provide results.'**
  String get faq_scan_a;

  /// No description provided for @faq_scan_q.
  ///
  /// In en, this message translates to:
  /// **'How do I scan a crop?'**
  String get faq_scan_q;

  /// No description provided for @faqs.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqs;

  /// No description provided for @farm_location.
  ///
  /// In en, this message translates to:
  /// **'Farm Location'**
  String get farm_location;

  /// No description provided for @farm_location_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Kumasi, Ghana'**
  String get farm_location_hint;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @farming_insights.
  ///
  /// In en, this message translates to:
  /// **'Farming Insights'**
  String get farming_insights;

  /// No description provided for @farming_overview.
  ///
  /// In en, this message translates to:
  /// **'Your Farming Overview'**
  String get farming_overview;

  /// No description provided for @feature_ai.
  ///
  /// In en, this message translates to:
  /// **'AI-powered crop disease detection'**
  String get feature_ai;

  /// No description provided for @feature_history.
  ///
  /// In en, this message translates to:
  /// **'History tracking and analytics'**
  String get feature_history;

  /// No description provided for @feature_learning.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive learning resources'**
  String get feature_learning;

  /// No description provided for @feature_offline.
  ///
  /// In en, this message translates to:
  /// **'Offline mode for remote areas'**
  String get feature_offline;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @fill_all_fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get fill_all_fields;

  /// No description provided for @filter_by_status.
  ///
  /// In en, this message translates to:
  /// **'Filter by Status'**
  String get filter_by_status;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get full_name;

  /// No description provided for @full_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get full_name_hint;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @gallery_desc_short.
  ///
  /// In en, this message translates to:
  /// **'Browse saved images'**
  String get gallery_desc_short;

  /// No description provided for @get_insights_desc.
  ///
  /// In en, this message translates to:
  /// **'Know if your crop is healthy, sick, or lacking nutrients'**
  String get get_insights_desc;

  /// No description provided for @get_insights_title.
  ///
  /// In en, this message translates to:
  /// **'Get Clear Insights'**
  String get get_insights_title;

  /// No description provided for @get_started.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get get_started;

  /// No description provided for @go_back.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get go_back;

  /// No description provided for @go_to_home.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get go_to_home;

  /// No description provided for @google_sign_up_failed.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-Up failed. Please try again.'**
  String get google_sign_up_failed;

  /// No description provided for @guide_diseases.
  ///
  /// In en, this message translates to:
  /// **'Crop Diseases Guide'**
  String get guide_diseases;

  /// No description provided for @guide_featured.
  ///
  /// In en, this message translates to:
  /// **'Identify Fall Armyworm'**
  String get guide_featured;

  /// No description provided for @guide_pests.
  ///
  /// In en, this message translates to:
  /// **'Pest Control Basics'**
  String get guide_pests;

  /// No description provided for @guide_soil.
  ///
  /// In en, this message translates to:
  /// **'Improving Soil Health'**
  String get guide_soil;

  /// No description provided for @guide_water.
  ///
  /// In en, this message translates to:
  /// **'Smart Irrigation'**
  String get guide_water;

  /// No description provided for @health_status.
  ///
  /// In en, this message translates to:
  /// **'Health Status'**
  String get health_status;

  /// No description provided for @help_support.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help_support;

  /// No description provided for @helpful_resources.
  ///
  /// In en, this message translates to:
  /// **'Helpful Resources'**
  String get helpful_resources;

  /// No description provided for @insights_error.
  ///
  /// In en, this message translates to:
  /// **'Insights Error'**
  String get insights_error;

  /// No description provided for @irrigation.
  ///
  /// In en, this message translates to:
  /// **'Irrigation'**
  String get irrigation;

  /// No description provided for @irrigation_desc_short.
  ///
  /// In en, this message translates to:
  /// **'Water tips'**
  String get irrigation_desc_short;

  /// No description provided for @keep_editing.
  ///
  /// In en, this message translates to:
  /// **'Keep Editing'**
  String get keep_editing;

  /// No description provided for @learning_center_desc_short.
  ///
  /// In en, this message translates to:
  /// **'Articles & tutorials'**
  String get learning_center_desc_short;

  /// No description provided for @learning_center_title.
  ///
  /// In en, this message translates to:
  /// **'Learning Center'**
  String get learning_center_title;

  /// No description provided for @learning_resources.
  ///
  /// In en, this message translates to:
  /// **'Learning Resources'**
  String get learning_resources;

  /// No description provided for @learning_topic.
  ///
  /// In en, this message translates to:
  /// **'Learning Topic'**
  String get learning_topic;

  /// No description provided for @learning_updates.
  ///
  /// In en, this message translates to:
  /// **'Learning Updates'**
  String get learning_updates;

  /// No description provided for @learning_updates_desc.
  ///
  /// In en, this message translates to:
  /// **'New articles and learning tips'**
  String get learning_updates_desc;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @listen_guide.
  ///
  /// In en, this message translates to:
  /// **'Listen to this guide (Audio)'**
  String get listen_guide;

  /// No description provided for @live_chat.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get live_chat;

  /// No description provided for @live_chat_desc.
  ///
  /// In en, this message translates to:
  /// **'Chat with our team'**
  String get live_chat_desc;

  /// No description provided for @local_analysis.
  ///
  /// In en, this message translates to:
  /// **'Local Analysis'**
  String get local_analysis;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logout_desc.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access your account.'**
  String get logout_desc;

  /// No description provided for @logout_q.
  ///
  /// In en, this message translates to:
  /// **'Log Out?'**
  String get logout_q;

  /// No description provided for @mission_desc.
  ///
  /// In en, this message translates to:
  /// **'VERD is dedicated to empowering farmers and agricultural professionals with cutting-edge AI technology to identify crop diseases early and improve crop yields. Our mission is to make agricultural expertise accessible to everyone.'**
  String get mission_desc;

  /// No description provided for @my_profile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get my_profile;

  /// No description provided for @name_empty_error.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get name_empty_error;

  /// No description provided for @new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get new_password;

  /// No description provided for @new_photo_selected.
  ///
  /// In en, this message translates to:
  /// **'New photo selected — tap Save to apply'**
  String get new_photo_selected;

  /// No description provided for @new_scan.
  ///
  /// In en, this message translates to:
  /// **'New Scan'**
  String get new_scan;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// No description provided for @no_insights_yet.
  ///
  /// In en, this message translates to:
  /// **'No insights available yet'**
  String get no_insights_yet;

  /// No description provided for @no_internet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get no_internet;

  /// No description provided for @no_internet_desc.
  ///
  /// In en, this message translates to:
  /// **'Please check your network settings\nand try again.'**
  String get no_internet_desc;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @open_settings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get open_settings;

  /// No description provided for @our_mission.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get our_mission;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @password_requirements.
  ///
  /// In en, this message translates to:
  /// **'Password Requirements:'**
  String get password_requirements;

  /// No description provided for @password_reset_sent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent! Check your inbox.'**
  String get password_reset_sent;

  /// No description provided for @password_too_short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get password_too_short;

  /// No description provided for @password_update_success.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get password_update_success;

  /// No description provided for @passwords_do_not_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwords_do_not_match;

  /// No description provided for @perm_camera_benefit1.
  ///
  /// In en, this message translates to:
  /// **'Take photos of crops for instant analysis'**
  String get perm_camera_benefit1;

  /// No description provided for @perm_camera_benefit2.
  ///
  /// In en, this message translates to:
  /// **'Identify diseases in real-time'**
  String get perm_camera_benefit2;

  /// No description provided for @perm_camera_benefit3.
  ///
  /// In en, this message translates to:
  /// **'Save scan history with photos'**
  String get perm_camera_benefit3;

  /// No description provided for @perm_camera_btn.
  ///
  /// In en, this message translates to:
  /// **'Allow Camera Access'**
  String get perm_camera_btn;

  /// No description provided for @perm_camera_desc.
  ///
  /// In en, this message translates to:
  /// **'VERD needs access to your camera to scan crops and identify diseases.'**
  String get perm_camera_desc;

  /// No description provided for @perm_camera_details.
  ///
  /// In en, this message translates to:
  /// **'Your photos are processed securely and never shared without your permission.'**
  String get perm_camera_details;

  /// No description provided for @perm_camera_title.
  ///
  /// In en, this message translates to:
  /// **'Camera Access Required'**
  String get perm_camera_title;

  /// No description provided for @perm_location_benefit1.
  ///
  /// In en, this message translates to:
  /// **'Get regional disease alerts'**
  String get perm_location_benefit1;

  /// No description provided for @perm_location_benefit2.
  ///
  /// In en, this message translates to:
  /// **'Receive weather-based recommendations'**
  String get perm_location_benefit2;

  /// No description provided for @perm_location_benefit3.
  ///
  /// In en, this message translates to:
  /// **'Find nearby agricultural resources'**
  String get perm_location_benefit3;

  /// No description provided for @perm_location_btn.
  ///
  /// In en, this message translates to:
  /// **'Allow Location Access'**
  String get perm_location_btn;

  /// No description provided for @perm_location_desc.
  ///
  /// In en, this message translates to:
  /// **'Enable location to get localized crop disease warnings and weather updates.'**
  String get perm_location_desc;

  /// No description provided for @perm_location_details.
  ///
  /// In en, this message translates to:
  /// **'Your location data is used only for providing relevant information and is never shared.'**
  String get perm_location_details;

  /// No description provided for @perm_location_title.
  ///
  /// In en, this message translates to:
  /// **'Location Access'**
  String get perm_location_title;

  /// No description provided for @perm_notif_benefit1.
  ///
  /// In en, this message translates to:
  /// **'Instant scan completion alerts'**
  String get perm_notif_benefit1;

  /// No description provided for @perm_notif_benefit2.
  ///
  /// In en, this message translates to:
  /// **'Disease outbreak warnings'**
  String get perm_notif_benefit2;

  /// No description provided for @perm_notif_benefit3.
  ///
  /// In en, this message translates to:
  /// **'Weekly crop health reports'**
  String get perm_notif_benefit3;

  /// No description provided for @perm_notif_btn.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get perm_notif_btn;

  /// No description provided for @perm_notif_desc.
  ///
  /// In en, this message translates to:
  /// **'Get timely notifications about disease outbreaks, scan results, and important agricultural updates.'**
  String get perm_notif_desc;

  /// No description provided for @perm_notif_details.
  ///
  /// In en, this message translates to:
  /// **'You can customize notification preferences anytime in settings.'**
  String get perm_notif_details;

  /// No description provided for @perm_notif_title.
  ///
  /// In en, this message translates to:
  /// **'Stay Informed'**
  String get perm_notif_title;

  /// No description provided for @permission_required.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permission_required;

  /// No description provided for @permission_required_desc.
  ///
  /// In en, this message translates to:
  /// **'This feature requires a permission that has been denied. Please enable it in your device settings.'**
  String get permission_required_desc;

  /// No description provided for @personalized_insights.
  ///
  /// In en, this message translates to:
  /// **'Personalized Insights'**
  String get personalized_insights;

  /// No description provided for @personlized_recommendations.
  ///
  /// In en, this message translates to:
  /// **'Personalized Recommendations'**
  String get personlized_recommendations;

  /// No description provided for @pest_control.
  ///
  /// In en, this message translates to:
  /// **'Pest Control'**
  String get pest_control;

  /// No description provided for @pest_control_desc_short.
  ///
  /// In en, this message translates to:
  /// **'Identify pests'**
  String get pest_control_desc_short;

  /// No description provided for @phone_hint.
  ///
  /// In en, this message translates to:
  /// **'+1 234 567 8900'**
  String get phone_hint;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

  /// No description provided for @please_log_in.
  ///
  /// In en, this message translates to:
  /// **'Please log in'**
  String get please_log_in;

  /// No description provided for @please_log_in_scanner.
  ///
  /// In en, this message translates to:
  /// **'Please log in to use the scanner'**
  String get please_log_in_scanner;

  /// No description provided for @popular_topics.
  ///
  /// In en, this message translates to:
  /// **'Popular Topics'**
  String get popular_topics;

  /// No description provided for @position_crop_instruction.
  ///
  /// In en, this message translates to:
  /// **'Position crop within frame'**
  String get position_crop_instruction;

  /// No description provided for @preferences_support.
  ///
  /// In en, this message translates to:
  /// **'Preferences & Support'**
  String get preferences_support;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profile_photo_selected.
  ///
  /// In en, this message translates to:
  /// **'Profile photo selected'**
  String get profile_photo_selected;

  /// No description provided for @profile_update_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile. Please try again.'**
  String get profile_update_error;

  /// No description provided for @profile_update_success.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profile_update_success;

  /// No description provided for @push_notifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get push_notifications;

  /// No description provided for @push_notifications_desc.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable push notifications'**
  String get push_notifications_desc;

  /// No description provided for @pwd_rule_case.
  ///
  /// In en, this message translates to:
  /// **'Contains uppercase and lowercase letters'**
  String get pwd_rule_case;

  /// No description provided for @pwd_rule_length.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters long'**
  String get pwd_rule_length;

  /// No description provided for @pwd_rule_number.
  ///
  /// In en, this message translates to:
  /// **'Contains at least one number'**
  String get pwd_rule_number;

  /// No description provided for @pwd_rule_special.
  ///
  /// In en, this message translates to:
  /// **'Contains at least one special character'**
  String get pwd_rule_special;

  /// No description provided for @quick_actions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quick_actions;

  /// No description provided for @quick_topics.
  ///
  /// In en, this message translates to:
  /// **'Quick Topics'**
  String get quick_topics;

  /// No description provided for @rec_diversify.
  ///
  /// In en, this message translates to:
  /// **'Try diversifying your crops for better soil health'**
  String get rec_diversify;

  /// No description provided for @rec_document.
  ///
  /// In en, this message translates to:
  /// **'Document treatments to track effectiveness'**
  String get rec_document;

  /// No description provided for @rec_scan_regularly.
  ///
  /// In en, this message translates to:
  /// **'Continue scanning regularly to build better insights'**
  String get rec_scan_regularly;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @save_result.
  ///
  /// In en, this message translates to:
  /// **'Save Result'**
  String get save_result;

  /// No description provided for @scan_crop.
  ///
  /// In en, this message translates to:
  /// **'Scan Crop'**
  String get scan_crop;

  /// No description provided for @scan_crop_desc_short.
  ///
  /// In en, this message translates to:
  /// **'Identify diseases instantly'**
  String get scan_crop_desc_short;

  /// No description provided for @scan_crops_desc.
  ///
  /// In en, this message translates to:
  /// **'Just take a photo. VERD checks your plant instantly.'**
  String get scan_crops_desc;

  /// No description provided for @scan_crops_title.
  ///
  /// In en, this message translates to:
  /// **'Scan Your Crops'**
  String get scan_crops_title;

  /// No description provided for @scan_history.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get scan_history;

  /// No description provided for @scan_results.
  ///
  /// In en, this message translates to:
  /// **'Scan Results'**
  String get scan_results;

  /// No description provided for @scan_results_desc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when your scan is complete'**
  String get scan_results_desc;

  /// No description provided for @search_articles.
  ///
  /// In en, this message translates to:
  /// **'Search Articles'**
  String get search_articles;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for crop diseases, pests...'**
  String get search_hint;

  /// No description provided for @send_link_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send link. Please try again.'**
  String get send_link_failed;

  /// No description provided for @server_error.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get server_error;

  /// No description provided for @server_error_desc.
  ///
  /// In en, this message translates to:
  /// **'Our servers are experiencing issues.\nPlease try again in a moment.'**
  String get server_error_desc;

  /// No description provided for @share_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Share functionality coming soon'**
  String get share_coming_soon;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @smart_companion.
  ///
  /// In en, this message translates to:
  /// **'Your smart agricultural companion'**
  String get smart_companion;

  /// No description provided for @soil_health.
  ///
  /// In en, this message translates to:
  /// **'Soil Health'**
  String get soil_health;

  /// No description provided for @soil_health_desc_short.
  ///
  /// In en, this message translates to:
  /// **'Maintain soil'**
  String get soil_health_desc_short;

  /// No description provided for @splash_powered.
  ///
  /// In en, this message translates to:
  /// **'powered by an offline AI'**
  String get splash_powered;

  /// No description provided for @splash_tagline.
  ///
  /// In en, this message translates to:
  /// **'CLARITY FOR YOUR CROPS'**
  String get splash_tagline;

  /// No description provided for @start_scanning.
  ///
  /// In en, this message translates to:
  /// **'Start Scanning'**
  String get start_scanning;

  /// No description provided for @start_scanning_desc.
  ///
  /// In en, this message translates to:
  /// **'Start scanning crops to get personalized insights'**
  String get start_scanning_desc;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @system_alerts.
  ///
  /// In en, this message translates to:
  /// **'System Alerts'**
  String get system_alerts;

  /// No description provided for @system_alerts_desc.
  ///
  /// In en, this message translates to:
  /// **'Important system and security updates'**
  String get system_alerts_desc;

  /// No description provided for @take_action_desc.
  ///
  /// In en, this message translates to:
  /// **'Get clear steps to protect your farm and grow more.'**
  String get take_action_desc;

  /// No description provided for @take_action_title.
  ///
  /// In en, this message translates to:
  /// **'Take Smart Action'**
  String get take_action_title;

  /// No description provided for @terms_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service coming soon'**
  String get terms_coming_soon;

  /// No description provided for @terms_of_service.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms_of_service;

  /// No description provided for @tip_of_the_day.
  ///
  /// In en, this message translates to:
  /// **'TIP OF THE DAY'**
  String get tip_of_the_day;

  /// No description provided for @token_copied.
  ///
  /// In en, this message translates to:
  /// **'Token copied to clipboard'**
  String get token_copied;

  /// No description provided for @topics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get topics;

  /// No description provided for @total_scans.
  ///
  /// In en, this message translates to:
  /// **'Total Scans'**
  String get total_scans;

  /// No description provided for @treatment_guide.
  ///
  /// In en, this message translates to:
  /// **'Treatment Guide'**
  String get treatment_guide;

  /// No description provided for @unexpected_error.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpected_error;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @upload_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Upload coming soon'**
  String get upload_coming_soon;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @view_history.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get view_history;

  /// No description provided for @view_history_desc_short.
  ///
  /// In en, this message translates to:
  /// **'Track your scans'**
  String get view_history_desc_short;

  /// No description provided for @welcome_to_verd.
  ///
  /// In en, this message translates to:
  /// **'Welcome to VERD'**
  String get welcome_to_verd;

  /// No description provided for @password_reset_sent_desc.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a password reset link to your email. Check your inbox and follow the instructions.'**
  String get password_reset_sent_desc;

  /// No description provided for @password_reset_instructions.
  ///
  /// In en, this message translates to:
  /// **'No worries! Enter your email and we\'ll send you reset instructions.'**
  String get password_reset_instructions;

  /// No description provided for @filter_all.
  ///
  /// In en, this message translates to:
  /// **'Filter All'**
  String get filter_all;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
