import 'screens/login.dart';
import 'screens/dashboard.dart';
import 'screens/new_diagnosis.dart';
import 'screens/new_patient.dart';
import 'screens/patient_history.dart';
import 'screens/research_papers.dart';
import 'screens/settings.dart';          
import 'screens/notifications.dart';      
import 'screens/register.dart';
class Routes {
  static const login = '/';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const newDiagnosis = '/new_diagnosis';
  static const newPatient = '/new_patient';
  static const patientHistory = '/patient_history';
  static const research = '/research_papers';
  static const patientProfile = '/patient_profile';
  static const settings = '/settings';                  
  static const notifications = '/notifications';        

  static final map = {
    login: (ctx) => LoginScreen(),
    register: (ctx) => const RegisterScreen(),
    dashboard: (ctx) => MainDashboard(),
    newDiagnosis: (ctx) => NewDiagnosisScreen(),
    newPatient: (ctx) => NewPatientScreen(),
    patientHistory: (ctx) => PatientSelectionPage(),
    research: (ctx) => ResearchPapersScreen(),
    settings: (ctx) => SettingsScreen(),                
    notifications: (ctx) => NotificationsScreen(),      
  };
}
