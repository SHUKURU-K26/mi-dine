import 'package:supabase_flutter/supabase_flutter.dart';

String friendlyError(Object error) {
  if (error is AuthRetryableFetchException) {
    return 'No connection. Check your internet and try again.';
  }
  if (error is AuthException) return error.message;
  if (error is PostgrestException) {
    if (error.code == '23505') {
      return 'You already have an ingredient with that name.';
    }
    return 'We could not complete that request. Please try again.';
  }
  return 'Something went wrong. Please try again.';
}