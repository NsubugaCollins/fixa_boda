enum UserRole {
  rider,
  mechanic,
}

enum ContactMethod {
  phone,
  email,
}

class OnboardingData {
  UserRole? role;

  ContactMethod contactMethod = ContactMethod.email;

  String fullName = '';
  String phone = '';
  String email = '';
  String password = '';
  String area = 'Wandegeya, Kampala';

  bool acceptedTerms = true;
}