#include <fluidsynth.h>
#include <Rinternals.h>

static int option_count = 0;

static const char * type_to_string(enum fluid_types_enum val){
  static const char *string_type = "string";
  static const char *double_type = "double";
  static const char *integer_type = "integer";
  static const char *set_type = "set";
  switch (val) {
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
  fluid_settings_t* settings = new_fluid_settings();
  option_count = 0;
  fluid_settings_foreach(settings, NULL, setting_iter);
  SEXP df = PROTECT(Rf_allocVector(VECSXP, 2));
  SET_VECTOR_ELT(df, 0, Rf_allocVector(STRSXP, option_count));
  SET_VECTOR_ELT(df, 1, Rf_allocVector(STRSXP, option_count));
  option_count = 0;
  fluid_settings_foreach(settings, df, setting_iter);
  UNPROTECT(1);
  return df;
}
