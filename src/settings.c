#include <fluidsynth.h>
#include <Rinternals.h>

static int option_count = 0;

static const char * type_to_string(enum fluid_types_enum type){
  static const char *string_type = "string";
  static const char *double_type = "double";
  static const char *integer_type = "integer";
  static const char *set_type = "set";
  switch (type) {
  case FLUID_NUM_TYPE:
    return double_type;
  case FLUID_STR_TYPE:
    return string_type;
  case FLUID_INT_TYPE:
    return integer_type;
  case FLUID_SET_TYPE:
    return set_type;
  default:
    return NULL;
  }
}

static void setting_iter(void *data, const char *name, int type){
  if(data != NULL){
    SET_STRING_ELT(VECTOR_ELT((SEXP)data, 0), option_count, Rf_mkChar(name));
    SET_STRING_ELT(VECTOR_ELT((SEXP)data, 1), option_count, Rf_mkChar(type_to_string(type)));
  }
  option_count++;
}

SEXP C_fluidsynth_list_settings(void){
  option_count = 0;
  fluid_settings_t* settings = new_fluid_settings();
  fluid_settings_foreach(settings, NULL, setting_iter);
  SEXP df = PROTECT(Rf_allocVector(VECSXP, 2));
  SET_VECTOR_ELT(df, 0, Rf_allocVector(STRSXP, option_count));
  SET_VECTOR_ELT(df, 1, Rf_allocVector(STRSXP, option_count));
  option_count = 0;
  fluid_settings_foreach(settings, df, setting_iter);
  delete_fluid_settings(settings);
  UNPROTECT(1);
  return df;
}

static void option_iter(void *data, const char *name, const char *option){
  if(data != NULL){
    SET_STRING_ELT((SEXP) data, option_count, Rf_mkChar(option));
  }
  option_count++;
}

SEXP C_fluidsynth_list_options(SEXP setting){
  option_count = 0;
  fluid_settings_t* settings = new_fluid_settings();
  fluid_settings_foreach_option(settings, CHAR(Rf_asChar(setting)), NULL, option_iter);
  SEXP out = PROTECT(Rf_allocVector(STRSXP, option_count));
  option_count = 0;
  fluid_settings_foreach_option(settings, CHAR(Rf_asChar(setting)), out, option_iter);
  delete_fluid_settings(settings);
  UNPROTECT(1);
  return out;
}

SEXP C_fluidsynth_get_default(SEXP setting){
  const char *name = CHAR(Rf_asChar(setting));
  fluid_settings_t* settings = new_fluid_settings();
  int type = fluid_settings_get_type(settings, name);
  char *strval = "";
  SEXP out = R_NilValue;
  switch (type) {
  case FLUID_NUM_TYPE:
    out = PROTECT(Rf_ScalarReal(NA_REAL));
    fluid_settings_getnum_default(settings, name, REAL(out));
    break;
  case FLUID_INT_TYPE:
    out = PROTECT(Rf_ScalarInteger(NA_INTEGER));
    fluid_settings_getint_default(settings, name, INTEGER(out));
    break;
  case FLUID_STR_TYPE:
    fluid_settings_getstr_default(settings, name, &strval);
    out = PROTECT(Rf_mkString(strval));
    break;
  }
  UNPROTECT(1);
  delete_fluid_settings(settings);
  return out;
}

SEXP C_fluidsynth_version(void){
  return Rf_mkString(fluid_version_str());
}
