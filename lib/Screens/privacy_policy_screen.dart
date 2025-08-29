import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''
BeFAB Privacy Policy
BeFAB Privacy Policy
BeFAB Privacy Policy
Effective Date: August 24, 2025
BeFAB (“we”, “us”, “our”) is committed to protecting your privacy. This Privacy Policy describes how BeFAB collects, uses, shares, and protects your information through our mobile application (“App”), available on iOS and other platforms. By using BeFAB, you agree to the practices outlined herein.
1. Purpose and Research Commitment
BeFAB is a research-driven health and wellness platform developed for advanced academic research and educational initiatives. All data collected, especially health and fitness analytics, is for legitimate research, scientific analysis, feature improvement, and academic purposes. We do not use health data for advertising, profiling, or non-research commercial activities. Our privacy practices meet or exceed the requirements set forth by Apple, relevant data protection laws, and research ethics boards.
2. Information We Collect
A. Personal and Registration Information
- First Name, Last Name (used for administrative, research participation logging; never shown to other users)
- Username (visible to active users in the format “username@BeFAB”)
- Email address (required for account creation, communications, research participation consent)
- Password (encrypted, never accessible to staff)
- Record Number/ID (used for research tracking, participant management, or classwork – not public)
B. Profile and Account Information
- Profile picture (private, stored for your account only)
- Bio (optional, for self-description in research context)
- Settings, preferences (for customizing user experience and research segmentation)
C. Health and Fitness Data (Full Collection for Research)
BeFAB collects every available health and fitness analytic from the user’s linked Health App, including:
1. Activity / Fitness Measures
- Steps count (daily, hourly, trends): For research on activity patterns and mobility.
- Distance traveled (walking, running, cycling): To study exercise frequency and cardiovascular health.
- Calories burned (active + resting): To assess user metabolism and wellness trends.
- Exercise minutes and activity duration: For mapping engagement in physical activities.
- Flights climbed: To evaluate physical effort and cardiovascular strain.
- Workouts logged (type/frequency/intensity): To compare activity modalities.
- VO₂ Max: Aerobic capacity used for fitness and endurance research.
- Heart rate zones, pace, splits: For performance and intensity analysis.
2. Body Measurements
- Weight, BMI, body fat %, lean mass, height, waist/hip circumference: For longitudinal studies on body composition and health indicators.
3. Heart and Cardiovascular Metrics
- Resting and active heart rates: Assess cardiovascular health.
- Heart rate variability (HRV): For stress/resilience measurement.
- Blood pressure (if available): Chronic disease screening.
- ECG/EKG data: Cardiac function monitoring (requires explicit user device sharing).
4. Sleep Data
- Total sleep time, time in bed, sleep stages (light, deep, REM), sleep efficiency (%), bedtime/wake trends: Critical for studying rest quality and its effects on health markers.
5. Nutrition
- Calories consumed, macronutrients (protein, fat, carbs), micronutrients, water and caffeine intake: To analyze dietary patterns and hydration.
6. Mindfulness & Stress
- Mindfulness minutes, meditation sessions, stress tracking, breathing sessions: For psychological wellness and research into stress reduction.
7. Reproductive & Other Health
- Cycle tracking (menstrual phases, period, ovulation), symptoms logged (mood, pain), body temperature, blood oxygen (SpO₂), respiratory rate, skin temperature variation: For gender health, respiratory, and physiological research.
8. Medical / Clinical Data
- Lab results (e.g., cholesterol, A1C), vaccination records, medications logged, allergies, conditions: Used exclusively for research participants who explicitly consent.
9. Meta & Engagement Analytics
- App usage (sessions, streaks, log-in frequency), goal completion rates, consistency/streaks, trends/averages: To study user engagement, motivation, and intervention effectiveness.
All data types above are explained during onboarding, and users can review, limit, or revoke consent for each category at any time.
D. Activity and Content
- Videos, reels, comments, group participation, competitions, newsletters, resource saves, messages, survey responses: For community engagement research and analysis of social wellness interactions.
E. Device and Technical Data
- Device type, OS version, and technical logs (e.g., crash reports, performance): Used for app improvement and research on digital wellness tools.
3. How We Use Your Information
BeFAB uses collected information to:
- Conduct health, wellness, and behavioral research (with appropriate anonymization)
- Improve app features and provide personalized suggestions based on scientific findings
- Fulfill educational, classwork, or study requirements for participating institutions
- Enable peer comparison, leaderboard features, and activity logging for research on motivation and adherence
- Aggregate and analyze de-identified data for academic publications
- Ensure proper operation, troubleshooting, and secure user experience
All research is subject to ethical board review, and raw health data is never sold or shared for commercial purposes. Access to identifiable health data is restricted to research personnel bound by confidentiality agreements.
4. Data Sharing and Disclosure
- With Researchers and Research Partners: Only for approved, IRB-compliant studies. Data is de-identified prior to sharing when possible.
- With Admins: Limited to those managing research participation, study oversight, moderation, and compliance reviews.
- User-to-User: Only username is shown; health, personal, and contact details are never disclosed.
- Third-Party Integrations: HealthKit and Google Fit integrations occur solely for research purposes at your direction, with consent, and you may disconnect at any time.
- Legal and Ethical Compliance: Data may be disclosed if required by law, institutional policy, or safety concerns.
5. User Controls and Research Consent
You may:
- Review, adjust, or withdraw your data-sharing choices and research consent at any time in the app.
- Request data deletion, access your data, or modify your record through support.
- Opt out of research participation (except features required for core classwork or group research).
- Access Privacy Policy and research terms any time.
Consent is voluntary for all research features not required by institutional programs, and withdrawal will not affect your participation in non-research sections of the app.
6. Data Security
BeFAB uses industry-standard encryption, anonymization, network controls, and secure cloud infrastructure. Health data connections comply with Apple’s App Transport Security (ATS) requirements and HIPAA-aligned security best practices for research platforms. Access is strictly limited to authorized research staff.
7. Children’s and Minor’s Privacy
Accounts for minors are managed with parental/institutional consent as required by law. Data collection is minimized and only for educational/research participation, not for public display or social features.
8. Data Retention and Updates
We retain identifiable research data only for the duration of approved studies or as required by institutional policy. De-identified data may be retained for future academic or statistical work. When you delete your account, we remove identifiable information unless retention is required by law or research contract.
9. Compliance, Audit, and Ethics
BeFAB regularly reviews privacy and research practices for compliance with Apple guidelines, GDPR, HIPAA, and academic ethical standards. Any findings are promptly addressed and privacy practices updated.
10. Contact and Support
For requests, questions, or privacy concerns, contact BeFAB Support through the app. You may request to access, correct, or delete your data, or inquire about research participation.
11. Changes to This Policy
We may update this Privacy Policy as research requirements, Apple guidelines, or laws evolve. All significant changes will be notified in the app and, where appropriate, via email. The most current version is always accessible in-app.
12. Acceptance
By using BeFAB, you expressly consent to health and fitness data collection for research, as outlined above. If you do not wish to participate, adjust your preferences or refrain from using features requiring health and activity data.
End of Policy

Effective Date: August 24, 2025

(BeFAB privacy content here – paste full text from file)
          ''',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
