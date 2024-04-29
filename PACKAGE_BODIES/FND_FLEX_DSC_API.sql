--------------------------------------------------------
--  DDL for Package Body FND_FLEX_DSC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_DSC_API" AS
/* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */



bad_parameter EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_parameter, -06501);

value_too_large EXCEPTION;
PRAGMA EXCEPTION_INIT(value_too_large, -01401);


who_mode VARCHAR2(1000) := NULL;  /* whether customer_data or seed_data */
debug_mode_on BOOLEAN := FALSE;
do_validation BOOLEAN := TRUE;
internal_messages VARCHAR2(10000);
chr_newline VARCHAR2(8) := fnd_global.newline;

-- The following subtypes are used in the APIs rename_dff and migrate_dff
SUBTYPE fnd_app_type IS fnd_application%ROWTYPE;
SUBTYPE fnd_tbl_type IS fnd_tables%ROWTYPE;
SUBTYPE fnd_dff_type IS fnd_descriptive_flexs%ROWTYPE;

-- The following record is used in deleting flexfields with missing fnd_table
--  entries.
  TYPE descr_rec IS RECORD(
    d_app_short_name  fnd_application.application_short_name%TYPE,
    d_descr_flex_name fnd_descriptive_flexs.descriptive_flexfield_name%TYPE,
    d_appl_table_name fnd_descriptive_flexs.application_table_name%TYPE);
  TYPE t_descr_rec IS TABLE OF descr_rec INDEX BY BINARY_INTEGER;

  v_details t_descr_rec; -- vector of detail records

-- The following constants are used as error constants
error_context_not_set       CONSTANT NUMBER := -20001;
error_same_dff_name         CONSTANT NUMBER := -20002;
error_invalid_dff_name      CONSTANT NUMBER := -20003;
error_dff_already_exists    CONSTANT NUMBER := -20004;
error_same_table_name       CONSTANT NUMBER := -20005;
error_col_already_regis     CONSTANT NUMBER := -20006;
error_col_not_registered    CONSTANT NUMBER := -20007;
error_col_wrong_type        CONSTANT NUMBER := -20008;
error_col_wrong_size        CONSTANT NUMBER := -20009;
error_srs_dff               CONSTANT NUMBER := -20009;
error_others                CONSTANT NUMBER := -20100;

--cur_lang fnd_languages.nls_language%TYPE := fnd_global.current_language;
--cur_lang fnd_languages.language_code%TYPE := userenv('LANG');
CURSOR lang_cur IS
   SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          language_code
     FROM fnd_languages
     WHERE installed_flag IN ('I', 'B');


/* ------------------------------------------------------------ */
/*  messaging                                                   */
/* ------------------------------------------------------------ */


PROCEDURE debug_on IS
BEGIN
   debug_mode_on := TRUE;
END;

PROCEDURE debug_off IS
BEGIN
   debug_mode_on := FALSE;
END;

PROCEDURE set_validation(v_in IN BOOLEAN) IS
BEGIN
   do_validation := v_in;
END;


PROCEDURE message(msg VARCHAR2) IS
BEGIN
   internal_messages := internal_messages || msg || fnd_global.newline;
--   internal_messages := internal_messages || Sqlerrm; /* error stamp */
END;

PROCEDURE message_init IS
BEGIN
   internal_messages := '';
END;



FUNCTION version RETURN VARCHAR2 IS
BEGIN
   RETURN('$Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $');
END;



FUNCTION message RETURN VARCHAR2 IS
BEGIN
   RETURN internal_messages;
END;

PROCEDURE dbms_debug(p_debug IN VARCHAR2)
  IS
     i INTEGER;
     m INTEGER;
     c INTEGER := 75;
BEGIN
   execute immediate ('begin dbms' ||
		      '_output' ||
		      '.enable(1000000); end;');
   m := Ceil(Length(p_debug)/c);
   FOR i IN 1..m LOOP
      execute immediate ('begin dbms' ||
			 '_output' ||
			 '.put_line(''' ||
			 REPLACE(Substr(p_debug, 1+c*(i-1), c), '''', '''''') ||
			 '''); end;');
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END dbms_debug;

/* only used in testing */
PROCEDURE println(msg IN VARCHAR2) IS
BEGIN
   IF(debug_mode_on) THEN
      dbms_debug(msg);
   END IF;
END;

/* ------------------------------------------------------------ */
/*  who information                                             */
/* ------------------------------------------------------------ */


PROCEDURE set_session_mode(session_mode IN VARCHAR2) IS
BEGIN
   IF(session_mode NOT IN ('customer_data', 'seed_data')) THEN
      message('bad mode:'|| session_mode);
      message('valid values are: customer_data, seed_data');
      RAISE bad_parameter;
   END IF;
   who_mode := session_mode;
END;


FUNCTION customer_mode RETURN BOOLEAN IS
BEGIN
   IF(who_mode = 'customer_data') THEN
      RETURN TRUE;
    ELSIF(who_mode = 'seed_data') THEN
      RETURN FALSE;
    ELSE
      message('bad session mode:' || who_mode);
      message('use set_session_mode to specify');
      RAISE bad_parameter;
   END IF;
END;


FUNCTION created_by_f RETURN NUMBER IS
BEGIN
   IF(customer_mode) THEN
      RETURN 0;
    ELSE
      RETURN 1;
   END IF;
END;

FUNCTION creation_date_f RETURN DATE IS
BEGIN
   IF(customer_mode) THEN
      RETURN Sysdate;
    ELSE
      RETURN To_date('01011980', 'MMDDYYYY');
   END IF;
END;


FUNCTION last_update_date_f RETURN DATE IS
BEGIN
   RETURN creation_date_f;
END;

FUNCTION last_updated_by_f RETURN NUMBER IS
BEGIN
   RETURN created_by_f;
END;

FUNCTION last_update_login_f RETURN NUMBER IS
BEGIN
   RETURN 0;
END;



/* ====================================================================== */

FUNCTION application_id_f(application_short_name_in IN VARCHAR2)
RETURN fnd_application.application_id%TYPE
IS
  application_id_ret fnd_application.application_id%TYPE;
BEGIN
  SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          application_id
    INTO application_id_ret
    FROM fnd_application
   WHERE application_short_name = application_short_name_in;

  RETURN application_id_ret;

EXCEPTION
   WHEN OTHERS THEN
      message('error locating application id');
      IF application_short_name_in IS NULL THEN
	 message('must specify appl_short_name');
      ELSE
	 message('appl_short_name:' || application_short_name_in);
      END IF;
      RAISE bad_parameter;
END;

/* ---------------------------------------------------------------------- */

FUNCTION table_id_f(application_id_in IN fnd_tables.application_id%TYPE,
		    table_name_in     IN VARCHAR2)
RETURN fnd_tables.table_id%TYPE
IS
  table_id_ret fnd_tables.table_id%TYPE;
BEGIN
   SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          table_id
     INTO table_id_ret
     FROM fnd_tables
    WHERE table_name = table_name_in
      AND application_id = application_id_in;
   RETURN table_id_ret;
EXCEPTION
   WHEN no_data_found THEN
      message('bad table name:' || table_name_in);
      RAISE bad_parameter;
END;

/* ---------------------------------------------------------------------- */

PROCEDURE value_set_id_f(
	value_set_name IN VARCHAR2,
	value_set_id   OUT nocopy fnd_flex_value_sets.flex_value_set_id%TYPE)
  IS
BEGIN
   SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          flex_value_set_id
     INTO value_set_id
     FROM fnd_flex_value_sets
     WHERE flex_value_set_name = value_set_name;
EXCEPTION
   WHEN no_data_found THEN
      message('bad valueset name:' || value_set_name);
      RAISE bad_parameter;
END;


/* ====================================================================== */


/* check whether the named descr ff exists in the specified app */
PROCEDURE check_existance(
	application_id_in IN fnd_application.application_id%TYPE,
	descriptive_flexfield_name_in IN VARCHAR2)
  IS
     dummy NUMBER(1);
BEGIN
   SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          NULL INTO dummy
     FROM fnd_descriptive_flexs
     WHERE application_id = application_id_in
     AND descriptive_flexfield_name = descriptive_flexfield_name_in;
EXCEPTION
   WHEN no_data_found THEN
      message('bad descriptive flexfield name:' ||
	      descriptive_flexfield_name_in);
      RAISE bad_parameter;
END;

/* ---------------------------------------------------------------------- */

/* check whether the context exists in the
   named descr ff in the specified app */
PROCEDURE check_existance(
	application_id_in             IN fnd_application.application_id%TYPE,
	descriptive_flexfield_name_in IN VARCHAR2,
	descr_flex_context_code_in    IN VARCHAR2)
     IS
	dummy NUMBER(1);
BEGIN
   SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          NULL INTO dummy
     FROM fnd_descr_flex_contexts
     WHERE application_id = application_id_in
     AND descriptive_flexfield_name = descriptive_flexfield_name_in
     AND descriptive_flex_context_code = descr_flex_context_code_in;
EXCEPTION
   WHEN no_data_found THEN
      check_existance(application_id_in, descriptive_flexfield_name_in);
      message('bad descriptive context name:' ||
	      descr_flex_context_code_in);
      RAISE bad_parameter;
END;


/* ------------------------------------------------------------ */
/*  insert functions                                            */
/* ------------------------------------------------------------ */



PROCEDURE ins_descriptive_flexs(
	application_id_in               IN NUMBER,
	application_table_name          IN VARCHAR2,
	descriptive_flexfield_name      IN VARCHAR2,
	table_application_id            IN NUMBER,
        concatenated_segs_view_name     IN VARCHAR2,
        context_required_flag           IN VARCHAR2,
	context_column_name             IN VARCHAR2,
	context_user_override_flag      IN VARCHAR2,
	concatenated_segment_delimiter  IN VARCHAR2,
	freeze_flex_definition_flag     IN VARCHAR2,
	protected_flag                  IN VARCHAR2,
	default_context_field_name      IN VARCHAR2,
	default_context_value           IN VARCHAR2)
  IS
     last_update_login fnd_flex_value_sets.last_update_login%TYPE
       := last_update_login_f;
     last_update_date fnd_flex_value_sets.last_update_date%TYPE
       := last_update_date_f;
     last_updated_by fnd_flex_value_sets.last_updated_by%TYPE
       := last_updated_by_f;
     creation_date fnd_flex_value_sets.creation_date%TYPE
       := creation_date_f;
     created_by fnd_flex_value_sets.created_by%TYPE
       := created_by_f;
     dummy NUMBER(1);
BEGIN
   /* assume valid application_id, table_application_id */
   BEGIN
      SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          NULL INTO dummy
	FROM fnd_tables
	WHERE table_name = application_table_name
	AND application_id = table_application_id;
   EXCEPTION
      WHEN no_data_found THEN
	 message('bad application table name:'||application_table_name);
	 RAISE bad_parameter;
   END;

   INSERT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          INTO fnd_descriptive_flexs(application_id,
				     application_table_name,
				     descriptive_flexfield_name,
				     table_application_id,
                                     concatenated_segs_view_name,
				     last_update_date,
				     last_updated_by,
				     creation_date,
				     created_by,
				     last_update_login,
				     context_required_flag,
                                     context_synchronization_flag,
				     context_column_name,
				     context_user_override_flag,
				     concatenated_segment_delimiter,
				     freeze_flex_definition_flag,
				     protected_flag,
				     default_context_field_name,
				     default_context_value)
     VALUES(application_id_in,
	    application_table_name,
	    descriptive_flexfield_name,
	    table_application_id,
            concatenated_segs_view_name,
	    last_update_date,
	    last_updated_by,
	    creation_date,
	    created_by,
	    last_update_login,
	    context_required_flag,
            'X',
	    context_column_name,
	    context_user_override_flag,
	    concatenated_segment_delimiter,
	    freeze_flex_definition_flag,
	    protected_flag,
	    default_context_field_name,
	    default_context_value);
   println('inserted into fnd_descriptive_flexs');
EXCEPTION
   WHEN dup_val_on_index THEN
      message('insert to fnd_descriptive_flexs failed - ' ||
	      'duplicate flexfield name or application id');
      RAISE bad_parameter;
   WHEN value_too_large THEN
      message('insert to fnd_descriptive_flexs failed - ' ||
	      'value too large');
      RAISE bad_parameter;
END;


/* modify the fields that are normally input in the
 * segments form rather than the register descriptive
 * flexfields form. */
PROCEDURE upd_descriptive_flexs(
	application_id_in                  IN NUMBER,
	descriptive_flexfield_name_in      IN VARCHAR2,

	context_required_flag_in           IN VARCHAR2,
	context_user_override_flag_in      IN VARCHAR2,
	concat_segment_delimiter_in        IN VARCHAR2,
	freeze_flex_definition_flag_in     IN VARCHAR2,
	default_context_field_name_in      IN VARCHAR2,
	default_context_value_in           IN VARCHAR2,
	p_context_default_type             IN VARCHAR2,
	p_context_default_value            IN VARCHAR2,
	p_context_override_value_set_i     IN NUMBER,
	p_context_runtime_property_fun     IN VARCHAR2)
  IS
     last_update_login_i fnd_flex_value_sets.last_update_login%TYPE
       := last_update_login_f;
     last_update_date_i fnd_flex_value_sets.last_update_date%TYPE
       := last_update_date_f;
     last_updated_by_i fnd_flex_value_sets.last_updated_by%TYPE
       := last_updated_by_f;
BEGIN
   UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_descriptive_flexs SET
	context_required_flag = context_required_flag_in,
	context_user_override_flag = context_user_override_flag_in,
	concatenated_segment_delimiter = concat_segment_delimiter_in,
	freeze_flex_definition_flag = freeze_flex_definition_flag_in,
	default_context_field_name = default_context_field_name_in,
	default_context_value = default_context_value_in,
	context_default_type = p_context_default_type,
	context_default_value = p_context_default_value,
	context_override_value_set_id = p_context_override_value_set_i,
	context_runtime_property_funct = p_context_runtime_property_fun
     WHERE application_id = application_id_in
     AND descriptive_flexfield_name = descriptive_flexfield_name_in;
   IF(customer_mode) THEN
      UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_descriptive_flexs SET
	last_update_date = last_update_date_i,
	last_updated_by = last_updated_by_i,
	last_update_login = last_update_login_i
	WHERE application_id = application_id_in
	AND descriptive_flexfield_name = descriptive_flexfield_name_in;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      message('update on fnd_descriptive_flexs failed');
      RAISE bad_parameter;
END;



/* insert records, one for each installed language */
PROCEDURE insmul_descriptive_flexs_tl(
	application_id                  IN NUMBER,
	descriptive_flexfield_name      IN VARCHAR2,
	title                           IN VARCHAR2,
	description                     IN VARCHAR2,
	form_context_prompt             IN VARCHAR2)
  IS
     last_update_login fnd_flex_value_sets.last_update_login%TYPE
       := last_update_login_f;
     last_update_date fnd_flex_value_sets.last_update_date%TYPE
       := last_update_date_f;
     last_updated_by fnd_flex_value_sets.last_updated_by%TYPE
       := last_updated_by_f;
     creation_date fnd_flex_value_sets.creation_date%TYPE
       := creation_date_f;
     created_by fnd_flex_value_sets.created_by%TYPE
       := created_by_f;
BEGIN
   FOR lang_rec IN lang_cur
     LOOP
	println('inserting into fnd_descriptive flexs tl');
	println('application_id ='|| application_id);
	println('descriptive_flexfield_name ='|| descriptive_flexfield_name);
	println('title ='|| title);
	println('form_context_prompt ='|| form_context_prompt);
	println('lang_rec.language_code ='|| lang_rec.language_code);
	INSERT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          INTO fnd_descriptive_flexs_tl(application_id,
					     descriptive_flexfield_name,
					     title,
	                                     description,
					     form_context_prompt,
					     language,
					     last_update_date,
					     last_updated_by,
					     creation_date,
					     created_by,
					     last_update_login,
					     source_lang)
	  VALUES(application_id,
		 descriptive_flexfield_name,
		 title,
	         description,
		 form_context_prompt,
		 lang_rec.language_code,
		 last_update_date,
		 last_updated_by,
		 creation_date,
		 created_by,
		 last_update_login,
		 userenv('LANG'));
--	println('inserted into fnd_descriptive_flexs_tl');
     END LOOP;
EXCEPTION
   WHEN dup_val_on_index THEN
      message('insert failed - duplicate language, flexfield name, or application id');
      RAISE bad_parameter;
   WHEN value_too_large THEN
      message('insert failed - value too large');
      RAISE bad_parameter;
   WHEN OTHERS THEN
      message('insmul_descriptive_flexs_tl: ' || Sqlerrm);
      RAISE;
END;


PROCEDURE ins_descr_flex_contexts(
	application_id          		IN NUMBER,
	descriptive_flexfield_name              IN VARCHAR2,
	descriptive_flex_context_code           IN VARCHAR2,
	enabled_flag            		IN VARCHAR2,
	global_flag             		IN VARCHAR2,
	description             		IN VARCHAR2)
  IS
     last_update_login fnd_flex_value_sets.last_update_login%TYPE
       := last_update_login_f;
     last_update_date fnd_flex_value_sets.last_update_date%TYPE
       := last_update_date_f;
     last_updated_by fnd_flex_value_sets.last_updated_by%TYPE
       := last_updated_by_f;
     creation_date fnd_flex_value_sets.creation_date%TYPE
       := creation_date_f;
     created_by fnd_flex_value_sets.created_by%TYPE
       := created_by_f;
BEGIN
   INSERT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          INTO fnd_descr_flex_contexts(application_id,
				       descriptive_flexfield_name,
				       descriptive_flex_context_code,
				       last_update_date,
				       last_updated_by,
				       creation_date,
				       created_by,
				       last_update_login,
				       enabled_flag,
				       global_flag)
  VALUES(application_id,
	 descriptive_flexfield_name,
	 descriptive_flex_context_code,
	 last_update_date,
	 last_updated_by,
	 creation_date,
	 created_by,
	 last_update_login,
	 enabled_flag,
	 global_flag);
EXCEPTION
   WHEN dup_val_on_index THEN
      message('insert failed - duplicate value on index');
      RAISE bad_parameter;
   WHEN value_too_large THEN
      message('insert failed - value too large');
      RAISE bad_parameter;
END;



PROCEDURE insmul_descr_flex_contexts_tl(
	application_id          		IN NUMBER,
	descriptive_flexfield_name              IN VARCHAR2,
	descriptive_flex_context_code           IN VARCHAR2,
	descriptive_flex_context_name           IN VARCHAR2,
	description             		IN VARCHAR2)
  IS
     last_update_login fnd_flex_value_sets.last_update_login%TYPE
       := last_update_login_f;
     last_update_date fnd_flex_value_sets.last_update_date%TYPE
       := last_update_date_f;
     last_updated_by fnd_flex_value_sets.last_updated_by%TYPE
       := last_updated_by_f;
     creation_date fnd_flex_value_sets.creation_date%TYPE
       := creation_date_f;
     created_by fnd_flex_value_sets.created_by%TYPE
       := created_by_f;
BEGIN
   FOR lang_rec IN lang_cur
     LOOP
	println('application_id=' || application_id);
	println('descriptive_flexfield_name=' ||
		descriptive_flexfield_name);
	println('descriptive_flex_context_code=' ||
		descriptive_flex_context_code);
	println('descriptive_flex_context_name=' ||
		descriptive_flex_context_name);
	println('lang_rec.language_code=' ||
		lang_rec.language_code);
--	println('userenv('LANG')=' || userenv('LANG'));
	INSERT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          INTO fnd_descr_flex_contexts_tl(application_id,
					       descriptive_flexfield_name,
					       descriptive_flex_context_code,
					       descriptive_flex_context_name,
					       description,
					       language,
					       last_update_date,
					       last_updated_by,
					       creation_date,
					       created_by,
					       last_update_login,
					       source_lang)
	  VALUES(application_id,
		 descriptive_flexfield_name,
		 descriptive_flex_context_code,
		 descriptive_flex_context_name,
		 description,
		 lang_rec.language_code,
		 last_update_date,
		 last_updated_by,
		 creation_date,
		 created_by,
		 last_update_login,
		 userenv('LANG'));
     END LOOP;
EXCEPTION
   WHEN dup_val_on_index THEN
      message('insert to fnd_descr_flex_contexts failed - ' ||
	      'duplicate value on index');
      RAISE bad_parameter;
   WHEN value_too_large THEN
      message('insert to fnd_descr_flex_contexts failed - ' ||
	      'value too large');
      RAISE bad_parameter;
   WHEN OTHERS THEN
      message('insmul_descr_flex_contexts_tl: ' || Sqlerrm);
      RAISE;
END;


PROCEDURE ins_descr_flex_column_usages(
	application_id         			IN NUMBER,
	descriptive_flexfield_name              IN VARCHAR2,
	descriptive_flex_context_code           IN VARCHAR2,
	application_column_name         	IN VARCHAR2,
	end_user_column_name            	IN VARCHAR2,
	column_seq_num          		IN NUMBER,
	enabled_flag            		IN VARCHAR2,
	required_flag           		IN VARCHAR2,
	security_enabled_flag           	IN VARCHAR2,
	display_flag            		IN VARCHAR2,
	display_size            		IN NUMBER,
	maximum_description_len         	IN NUMBER,
	concatenation_description_len           IN NUMBER,
	form_left_prompt                	IN VARCHAR2,
	form_above_prompt               	IN VARCHAR2,
	description             		IN VARCHAR2,
	flex_value_set_id               	IN NUMBER,
	range_code              		IN VARCHAR2,
	default_type            		IN VARCHAR2,
	default_value           		IN VARCHAR2,
	runtime_property_function               IN VARCHAR2,
	srw_param               		IN VARCHAR2)
  IS
     last_update_login fnd_flex_value_sets.last_update_login%TYPE
       := last_update_login_f;
     last_update_date fnd_flex_value_sets.last_update_date%TYPE
       := last_update_date_f;
     last_updated_by fnd_flex_value_sets.last_updated_by%TYPE
       := last_updated_by_f;
     creation_date fnd_flex_value_sets.creation_date%TYPE
       := creation_date_f;
     created_by fnd_flex_value_sets.created_by%TYPE
       := created_by_f;
BEGIN
   INSERT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          INTO fnd_descr_flex_column_usages(application_id,
					    descriptive_flexfield_name,
					    descriptive_flex_context_code,
					    application_column_name,
					    end_user_column_name,
					    last_update_date,
					    last_updated_by,
					    creation_date,
					    created_by,
					    last_update_login,
					    column_seq_num,
					    enabled_flag,
					    required_flag,
					    security_enabled_flag,
					    display_flag,
					    display_size,
					    maximum_description_len,
					    concatenation_description_len,
					    flex_value_set_id,
					    range_code,
					    default_type,
					    default_value,
					    runtime_property_function,
					    srw_param)
     VALUES(application_id,
	    descriptive_flexfield_name,
	    descriptive_flex_context_code,
	    application_column_name,
	    end_user_column_name,
	    last_update_date,
	    last_updated_by,
	    creation_date,
	    created_by,
	    last_update_login,
	    column_seq_num,
	    enabled_flag,
	    required_flag,
	    security_enabled_flag,
	    display_flag,
	    display_size,
	    maximum_description_len,
	    concatenation_description_len,
	    flex_value_set_id,
	    range_code,
	    default_type,
	    default_value,
	    runtime_property_function,
	    srw_param);
EXCEPTION
   WHEN dup_val_on_index THEN
      message('insert failed - duplicate value on index');
      RAISE bad_parameter;
   WHEN value_too_large THEN
      message('insert failed - value too large');
      RAISE bad_parameter;
END;


PROCEDURE insmul_descr_flex_col_usage_tl(
	application_id          		IN NUMBER,
	descriptive_flexfield_name              IN VARCHAR2,
	descriptive_flex_context_code           IN VARCHAR2,
	application_column_name         	IN VARCHAR2,
	form_left_prompt               	 	IN VARCHAR2,
	form_above_prompt               	IN VARCHAR2,
	description             		IN VARCHAR2)
  IS
     last_update_login fnd_flex_value_sets.last_update_login%TYPE
       := last_update_login_f;
     last_update_date fnd_flex_value_sets.last_update_date%TYPE
       := last_update_date_f;
     last_updated_by fnd_flex_value_sets.last_updated_by%TYPE
       := last_updated_by_f;
     creation_date fnd_flex_value_sets.creation_date%TYPE
       := creation_date_f;
     created_by fnd_flex_value_sets.created_by%TYPE
       := created_by_f;
BEGIN
   FOR lang_rec IN lang_cur
     LOOP
	INSERT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          INTO fnd_descr_flex_col_usage_tl(application_id,
						descriptive_flexfield_name,
						descriptive_flex_context_code,
						application_column_name,
						form_left_prompt,
						form_above_prompt,
						description,
						language,
						last_update_date,
						last_updated_by,
						creation_date,
						created_by,
						last_update_login,
						source_lang)
	  VALUES(application_id,
		 descriptive_flexfield_name,
		 descriptive_flex_context_code,
		 application_column_name,
		 form_left_prompt,
		 form_above_prompt,
		 description,
		 lang_rec.language_code,
		 last_update_date,
		 last_updated_by,
		 creation_date,
		 created_by,
		 last_update_login,
		 userenv('LANG'));
     END LOOP;
EXCEPTION
   WHEN dup_val_on_index THEN
      message('insert failed - duplicate value on index');
      RAISE bad_parameter;
   WHEN value_too_large THEN
      message('insert failed - value too large');
      RAISE bad_parameter;
END;



PROCEDURE ins_default_context_fields(application_id_in      IN NUMBER,
				     flexfield_name_in      IN VARCHAR2,
				     context_field_name_in  IN VARCHAR2,
				     description_in         IN VARCHAR2)
  IS
     last_update_login fnd_flex_value_sets.last_update_login%TYPE
       := last_update_login_f;
     last_update_date fnd_flex_value_sets.last_update_date%TYPE
       := last_update_date_f;
     last_updated_by fnd_flex_value_sets.last_updated_by%TYPE
       := last_updated_by_f;
     creation_date fnd_flex_value_sets.creation_date%TYPE
       := creation_date_f;
     created_by fnd_flex_value_sets.created_by%TYPE
       := created_by_f;
BEGIN
   INSERT
     INTO fnd_default_context_fields(application_id,
				     descriptive_flexfield_name,
				     default_context_field_name,
				     last_update_date,
				     last_updated_by,
				     creation_date,
				     created_by,
				     last_update_login,
				     description)
     VALUES(application_id_in,
	    flexfield_name_in,
	    context_field_name_in,
	    last_update_date,
	    last_updated_by,
	    creation_date,
	    created_by,
	    last_update_login,
	    description_in);
END;


/* ------------------------------------------------------------ */
/* more validation                                              */
/* ------------------------------------------------------------ */


/* figure out whether the column name can be used in this context
   of this flexfield */
PROCEDURE validate_column_name(application_id_in             IN NUMBER,
			       descriptive_flexfield_name_in IN VARCHAR2,
			       descr_flex_context_code_in    IN VARCHAR2,
			       application_column_name_in    IN VARCHAR2)
  IS
     global_context_code_i
       fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE;
     srsprefix VARCHAR2(10) := '$SRS$.';
     dummy NUMBER(1);
BEGIN
   -- check whether the column name is usable with this
   -- flexfield
   BEGIN
      SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          NULL INTO dummy
	FROM fnd_columns c, fnd_tables t, fnd_descriptive_flexs df
	WHERE df.application_id = application_id_in
	AND df.descriptive_flexfield_name = descriptive_flexfield_name_in
	AND t.application_id = df.table_application_id
	AND t.table_name = df.application_table_name
	AND c.table_id = t.table_id
	AND c.application_id = t.application_id
	AND c.column_name = application_column_name_in
	AND c.flexfield_name = descriptive_flexfield_name_in
	AND c.flexfield_application_id = application_id_in
	AND c.flexfield_usage_code = 'D';
   EXCEPTION
      WHEN no_data_found THEN
	 -- SRS can get away with this, because we don't have all
	 -- the information to check.
	 IF(Substr(descriptive_flexfield_name_in, 1,
		   (Length(srsprefix))) <> srsprefix) THEN
	    message('The column name is not usable with this flexfield');
	    message('application id:' || application_id_in);
	    message('ff name:' || descriptive_flexfield_name_in);
	    message('ccode:' || descr_flex_context_code_in);
	    message('column name:' || application_column_name_in);
	    RAISE bad_parameter;
	 END IF;
   END;

   -- get the global context name, for use later
   BEGIN
      SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          descriptive_flex_context_code
	INTO global_context_code_i
	FROM fnd_descr_flex_contexts
	WHERE application_id = application_id_in
	AND descriptive_flexfield_name = descriptive_flexfield_name_in
	AND global_flag = 'Y';
   EXCEPTION
      WHEN no_data_found THEN
	 message('could not find a global context for this flexfield');
	 RAISE bad_parameter;
      WHEN too_many_rows THEN
	 message('more than one global context detected');
	 RAISE bad_parameter;
   END;

   -- make sure the context is not already being used
   BEGIN
      SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          NULL INTO dummy FROM dual
	WHERE NOT EXISTS
	(SELECT NULL
	 FROM fnd_descr_flex_column_usages cu
	 WHERE cu.application_id = application_id_in
	 AND cu.descriptive_flexfield_name = descriptive_flexfield_name_in
	 AND cu.application_column_name = application_column_name_in
	 AND (   -- already in use in the current context
	      (descriptive_flex_context_code = descr_flex_context_code_in)
	      OR -- already in the global context
	      (descriptive_flex_context_code = global_context_code_i)
	      OR -- we are in the global context
	      (descr_flex_context_code_in = global_context_code_i)));
   EXCEPTION
      WHEN no_data_found THEN
	 message('incompatible parameters detected');
	 RAISE bad_parameter;
   END;
END;


PROCEDURE check_context_field(application_id_in             IN NUMBER,
			      descriptive_flexfield_name_in IN VARCHAR2,
			      context_field_in              IN VARCHAR2)
  IS
     dummy VARCHAR2(1);
BEGIN
   -- null is also allowed for the field name
   IF(context_field_in IS NOT NULL) THEN
      SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          NULL INTO dummy
	FROM fnd_default_context_fields
	WHERE application_id = application_id_in
	AND descriptive_flexfield_name = descriptive_flexfield_name_in
	AND default_context_field_name = context_field_in;
   END IF;
EXCEPTION
   WHEN no_data_found THEN
      message('could not locate context field in fnd_default_context_fields:'
	      || context_field_in);
      RAISE bad_parameter;
END;


/* ------------------------------------------------------------ */
/*  public functions                                            */
/* ------------------------------------------------------------ */

PROCEDURE register(appl_short_name       IN VARCHAR2,
		   flexfield_name        IN VARCHAR2,
		   title                 IN VARCHAR2,
		   description           IN VARCHAR2,
		   table_appl_short_name IN VARCHAR2,
		   table_name            IN VARCHAR2,
		   structure_column      IN VARCHAR2,
		   /* context_prompt overwritten in setup_context */
		   context_prompt        IN VARCHAR2 DEFAULT 'Context Value',
		   protected_flag        IN VARCHAR2 DEFAULT 'N',
		   enable_columns        IN VARCHAR2 DEFAULT NULL,
                   concatenated_segs_view_name IN VARCHAR2 DEFAULT NULL)
  IS
     last_update_login_i fnd_flex_value_sets.last_update_login%TYPE
       := last_update_login_f;
     last_update_date_i fnd_flex_value_sets.last_update_date%TYPE
       := last_update_date_f;
     last_updated_by_i fnd_flex_value_sets.last_updated_by%TYPE
       := last_updated_by_f;
     application_id_i fnd_application.application_id%TYPE;
     table_application_id_i fnd_application.application_id%TYPE;
     application_table_id_i fnd_tables.table_id%TYPE;
     itisSRS BOOLEAN;
     numcount NUMBER;
     ffucode fnd_columns.flexfield_usage_code%TYPE;
BEGIN
   itisSRS := (SUBSTR(flexfield_name,1,6) = '$SRS$.');
   if (itisSRS is NULL) then
      itisSRS := FALSE;
   end if;
   message_init;
   println('starting registration for:' || flexfield_name);
   application_id_i := application_id_f(appl_short_name);
   println('application id:' || To_char(application_id_i));
   table_application_id_i := application_id_f(table_appl_short_name);
   println('table application id:' || To_char(table_application_id_i));
   ins_descriptive_flexs(
	application_id_in => application_id_i,
	application_table_name => table_name,
	descriptive_flexfield_name => flexfield_name,
	table_application_id => table_application_id_i,
        concatenated_segs_view_name => concatenated_segs_view_name,
        context_required_flag => 'N',
	context_column_name => structure_column,
	context_user_override_flag => 'Y',
	concatenated_segment_delimiter => '.',
	freeze_flex_definition_flag => 'N',
	protected_flag => protected_flag,
	default_context_field_name => NULL,
	default_context_value => NULL);

   insmul_descriptive_flexs_tl(application_id => application_id_i,
	       descriptive_flexfield_name => flexfield_name,
	       title => title,
     	       description => description,
	       form_context_prompt => Nvl(context_prompt, flexfield_name));

   application_table_id_i := table_id_f(table_application_id_i,
					 table_name);
   println('table_id:' || To_char(application_table_id_i));
   /* fix the columns (enabled) */
   /* WARNING: the value set information is not set here */

   IF (itisSRS) THEN
     BEGIN
        SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          flexfield_usage_code INTO ffucode
          FROM fnd_columns
	 WHERE application_id = register.table_application_id_i
	   AND table_id = register.application_table_id_i
--	   AND flexfield_usage_code = 'N'
	   AND column_name = register.structure_column;
        IF (ffucode = 'N') THEN
           UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_columns SET
              flexfield_usage_code = 'C'
	   WHERE application_id = register.table_application_id_i
	     AND table_id = register.application_table_id_i
--	     AND flexfield_usage_code = 'N'
	     AND column_name = register.structure_column;
        ELSIF (ffucode <> 'C') THEN
	   message('column '||structure_column||
		   ': $SRS$ context column is registered with'||
                   ' different code. :'||ffucode);
	   RAISE bad_parameter;
        END IF;
     EXCEPTION
       WHEN no_data_found THEN
	   message('column '||structure_column||
		   ': $SRS$ context column is not registered in fnd_columns.');
	   RAISE no_data_found;
       WHEN OTHERS THEN
           message('register : Error in $SRS$. structure column');
           RAISE;
     END;
   ELSE
     BEGIN
	IF(customer_mode) THEN
	   UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_columns SET
	     last_update_date  = last_update_date_i,
	     last_updated_by   = last_updated_by_i,
	     last_update_login = last_update_login_i
	     WHERE application_id = register.table_application_id_i
	     AND table_id = register.application_table_id_i
	     AND flexfield_usage_code = 'N'
	     AND column_name = register.structure_column;
	   IF SQL%ROWCOUNT <> 1 THEN
	      message('column '||structure_column||
		      ' could not be assigned as a context column');
	      RAISE bad_parameter;
	   END IF;
	END IF;

	UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_columns SET
	  flexfield_usage_code = 'C',
	  flexfield_application_id = register.application_id_i,
	  flexfield_name = register.flexfield_name
	  WHERE application_id = register.table_application_id_i
	  AND table_id = register.application_table_id_i
	  AND flexfield_usage_code = 'N'
	  AND column_name = register.structure_column;
	IF SQL%ROWCOUNT <> 1 THEN
	   message('column '||structure_column||
		   ' could not be assigned as a context column');
	   RAISE bad_parameter;
	END IF;
     END;
   END IF;


   --  enable columns named /ATTRIBUTE[0-9]*/
   IF (itisSRS) THEN
     BEGIN
        UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_columns SET
           flexfield_usage_code = 'D'
	 WHERE application_id = register.table_application_id_i
	   AND table_id = register.application_table_id_i
	   AND flexfield_usage_code = 'N'
	   AND column_name LIKE Nvl(enable_columns, 'ATTRIBUTE%')
	   AND ((column_name IS NOT NULL)
	         OR (Rtrim(column_name, '0123456789') = 'ATTRIBUTE'));

        SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          COUNT(*) INTO numcount
          FROM fnd_columns
	 WHERE application_id = register.table_application_id_i
	   AND table_id = register.application_table_id_i
	   AND flexfield_usage_code = 'D'
	   AND column_name LIKE Nvl(enable_columns, 'ATTRIBUTE%')
	   AND ((column_name IS NOT NULL)
	         OR (Rtrim(column_name, '0123456789') = 'ATTRIBUTE'));

        IF (numcount = 0) THEN
	   message('register : no attribute columns available for $SRS$.');
	   RAISE bad_parameter;
        END IF;
     EXCEPTION
        WHEN OTHERS THEN
           message('register : Error in $SRS$. attribute columns');
           RAISE;
     END;
   ELSE
     BEGIN
	IF(customer_mode) THEN
	   UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_columns SET
	     last_update_date = register.last_update_date_i,
	     last_updated_by = register.last_updated_by_i,
	     last_update_login = register.last_update_login_i
	     WHERE application_id = register.table_application_id_i
	     AND table_id = register.application_table_id_i
	     AND flexfield_usage_code = 'N'
	     AND column_name LIKE Nvl(enable_columns, 'ATTRIBUTE%')
	     AND ((column_name IS NOT NULL)
		   OR (Rtrim(column_name, '0123456789') = 'ATTRIBUTE'));

	  IF SQL%ROWCOUNT = 0 THEN
	     message('no attribute columns available');
	     RAISE bad_parameter;
	  END IF;

	END IF;

	UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_columns SET
	  flexfield_usage_code = 'D',
	  flexfield_application_id = register.application_id_i,
	  flexfield_name = register.flexfield_name
	  WHERE application_id = register.table_application_id_i
	  AND table_id = register.application_table_id_i
	  AND flexfield_usage_code = 'N'
	  AND column_name LIKE Nvl(enable_columns, 'ATTRIBUTE%')
	  AND ((column_name IS NOT NULL)
	       OR (Rtrim(column_name, '0123456789') = 'ATTRIBUTE'));
	IF SQL%ROWCOUNT = 0 THEN
	   message('no attribute columns available');
	   RAISE bad_parameter;
	END IF;

     END;
   END IF;
   /* now create the global context */
   println('about to create default context');
   create_context(
        appl_short_name => appl_short_name,
	flexfield_name => flexfield_name,
	context_code => 'Global Data Elements',
	context_name => 'Global Data Elements',
	description =>  'Global Data Element Context',
	enabled => 'Y',
	global_flag => 'Y');
   println('registered flexfield:' || flexfield_name);
EXCEPTION
   WHEN OTHERS THEN
      message('register: ' || Sqlerrm);
      RAISE;
END;



/* ------------------------------------------------------------ */
PROCEDURE enable_columns(appl_short_name       IN VARCHAR2,
			 flexfield_name        IN VARCHAR2,
			 pattern               IN VARCHAR2)
  IS
     last_update_login_i fnd_flex_value_sets.last_update_login%TYPE
       := last_update_login_f;
     last_update_date_i fnd_flex_value_sets.last_update_date%TYPE
       := last_update_date_f;
     last_updated_by_i fnd_flex_value_sets.last_updated_by%TYPE
       := last_updated_by_f;
     application_id_i fnd_application.application_id%TYPE;
     table_application_id_i fnd_application.application_id%TYPE;
     application_table_id_i fnd_tables.table_id%TYPE;
BEGIN
   message_init;
   println('enabling columns for:' || flexfield_name);
   application_id_i := application_id_f(appl_short_name);
   BEGIN
      SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          table_application_id, table_id
	INTO table_application_id_i, application_table_id_i
	FROM fnd_descriptive_flexs df, fnd_tables t
	WHERE df.application_id = application_id_i
	AND df.descriptive_flexfield_name = flexfield_name
	AND t.application_id = df.table_application_id
	AND t.table_name = df.application_table_name;
   EXCEPTION
      WHEN no_data_found THEN
	 message('could not lookup table information for: ' ||
		 flexfield_name);
	 RAISE bad_parameter;
   END;
   BEGIN
      IF(NOT customer_mode) THEN
	 UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_columns SET
	   flexfield_usage_code = 'D',
	   flexfield_application_id = application_id_i,
	   flexfield_name = enable_columns.flexfield_name
	   WHERE application_id = table_application_id_i
	   AND table_id = application_table_id_i
	   AND flexfield_usage_code = 'N'
	   AND column_name LIKE pattern;
       ELSE
	 UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_columns SET
	   flexfield_usage_code = 'D',
	   flexfield_application_id = application_id_i,
	   flexfield_name = enable_columns.flexfield_name,
	   last_update_date = last_update_date_i,
	   last_updated_by = last_updated_by_i,
	   last_update_login = last_update_login_i
	   WHERE application_id = table_application_id_i
	   AND table_id = application_table_id_i
	   AND flexfield_usage_code = 'N'
	   AND column_name LIKE pattern;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
	 message('could not update fnd_columns:' ||
		 Sqlerrm);
	 RAISE bad_parameter;
   END;
END;

/* ------------------------------------------------------------ */

PROCEDURE setup_context_field(appl_short_name       IN VARCHAR2,
			      flexfield_name        IN VARCHAR2,
			      segment_separator     IN VARCHAR2,
			      prompt    IN VARCHAR2 DEFAULT 'Context Value',
			      default_value         IN VARCHAR2,
			      reference_field       IN VARCHAR2,
			      value_required        IN VARCHAR2,
			      override_allowed      IN VARCHAR2,
			      freeze_flexfield_definition IN VARCHAR2 DEFAULT 'N',
			      context_default_type IN VARCHAR2 DEFAULT NULL,
			      context_default_value IN VARCHAR2 DEFAULT NULL,
			      context_override_value_set_nam IN VARCHAR2 DEFAULT NULL,
			      context_runtime_property_funct IN VARCHAR2 DEFAULT NULL)
  IS
     application_id_i fnd_application.application_id%TYPE;
     l_context_override_value_set_i NUMBER;
BEGIN
   message_init;
   application_id_i := application_id_f(appl_short_name);
   IF(do_validation) THEN
      check_context_field(application_id_i,
			  flexfield_name,
			  reference_field);
   END IF;

   IF (context_override_value_set_nam IS NOT NULL) THEN
      SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          flex_value_set_id
	INTO l_context_override_value_set_i
	FROM fnd_flex_value_sets
	WHERE flex_value_set_name = context_override_value_set_nam;
   END IF;

   upd_descriptive_flexs(
	application_id_in => application_id_i,
	descriptive_flexfield_name_in => flexfield_name,
	context_required_flag_in => value_required,
	context_user_override_flag_in => override_allowed,
	concat_segment_delimiter_in => segment_separator,
	freeze_flex_definition_flag_in => freeze_flexfield_definition,
	default_context_field_name_in => reference_field,
	default_context_value_in => default_value,
        p_context_default_type => context_default_type,
        p_context_default_value => context_default_value,
        p_context_override_value_set_i => l_context_override_value_set_i,
	p_context_runtime_property_fun => context_runtime_property_funct);
   IF(prompt IS NOT NULL) THEN
      UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_descriptive_flexs_tl
	SET
	form_context_prompt = prompt
	WHERE application_id = application_id_i
	AND descriptive_flexfield_name = flexfield_name;
   END IF;

   println('setup context info for flexfield:' || flexfield_name);
END;


/* ------------------------------------------------------------ */

PROCEDURE freeze(appl_short_name               IN VARCHAR2,
		 flexfield_name                IN VARCHAR2)
  IS
     last_update_login_i fnd_flex_value_sets.last_update_login%TYPE
       := last_update_login_f;
     last_update_date_i fnd_flex_value_sets.last_update_date%TYPE
       := last_update_date_f;
     last_updated_by_i fnd_flex_value_sets.last_updated_by%TYPE
       := last_updated_by_f;
     appid fnd_application.application_id%TYPE;
BEGIN
   message_init;
   appid := application_id_f(appl_short_name);
   UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_descriptive_flexs SET
     last_update_date = last_update_date_i,
     last_updated_by = last_updated_by_i,
     last_update_login = last_update_login_i,
     freeze_flex_definition_flag = 'Y'
     WHERE application_id = appid
     AND flexfield_name = descriptive_flexfield_name;
   println('froze ff:'|| flexfield_name);
END;

/* ------------------------------------------------------------ */

PROCEDURE create_context(appl_short_name          IN VARCHAR2,
			 flexfield_name           IN VARCHAR2,
			 /* data */
			 context_code             IN VARCHAR2,
			 context_name             IN VARCHAR2,
			 description              IN VARCHAR2,
			 enabled                  IN VARCHAR2,
			 global_flag              IN VARCHAR2 DEFAULT 'N')
  IS
     application_id_i fnd_application.application_id%TYPE;
BEGIN
   message_init;
   application_id_i := application_id_f(appl_short_name);
   check_existance(application_id_i, flexfield_name);
   println('inserting into desc flex contexts');
   ins_descr_flex_contexts(
	application_id => application_id_i,
	descriptive_flexfield_name => flexfield_name,
	descriptive_flex_context_code => context_code,
	enabled_flag => enabled,
	global_flag => global_flag,
	description => description);
   println('inserting into desc flex contexts tl');
   insmul_descr_flex_contexts_tl(
	application_id => application_id_i,
	descriptive_flexfield_name => flexfield_name,
	descriptive_flex_context_code => context_code,
	descriptive_flex_context_name => context_name,
	description => description);
   println('created context:' || context_name);
END;

/* ------------------------------------------------------------ */


PROCEDURE create_segment(appl_short_name        IN VARCHAR2,
			 flexfield_name		IN VARCHAR2,
			 context_name           IN VARCHAR2,
	/* data */
   	name		                IN VARCHAR2,
	column	                        IN VARCHAR2,
	description			IN VARCHAR2,
	sequence_number             	IN NUMBER,
	enabled				IN VARCHAR2,
	displayed			IN VARCHAR2,
	/* validation */
	value_set			IN VARCHAR2,
	default_type			IN VARCHAR2,
	default_value			IN VARCHAR2,
	required			IN VARCHAR2,
	security_enabled		IN VARCHAR2,
	/* sizes */
	display_size			IN NUMBER,
	description_size		IN NUMBER,
	concatenated_description_size   IN NUMBER,
	list_of_values_prompt  		IN VARCHAR2,
	window_prompt	              	IN VARCHAR2,
	RANGE                           IN VARCHAR2 DEFAULT NULL,
        srw_parameter                   IN VARCHAR2 DEFAULT NULL,
        runtime_property_function       IN VARCHAR2 DEFAULT NULL)
  IS
     application_id_i fnd_application.application_id%TYPE;
     default_type_i fnd_descr_flex_column_usages.default_type%TYPE;
     value_set_id_i fnd_flex_value_sets.flex_value_set_id%TYPE;
     range_code_i fnd_descr_flex_column_usages.range_code%TYPE;
     dummy NUMBER(1);
BEGIN
   message_init;
   application_id_i := application_id_f(appl_short_name);

   IF(do_validation) THEN
      -- check that the context exists
      check_existance(application_id_in => application_id_i,
		      descriptive_flexfield_name_in => flexfield_name,
		      descr_flex_context_code_in => context_name);

      -- make sure it's a valid value set
      IF(value_set IS NOT NULL) THEN
	 value_set_id_f(value_set_name => value_set,
			value_set_id => value_set_id_i);
      END IF;
   END IF;

   -- check the range code
   BEGIN
      IF(range IS NOT NULL) THEN
	 BEGIN
	    fnd_flex_types.validate_range_code(range);
	    range_code_i := range;
	 EXCEPTION
	    -- maybe it's still old style
	    WHEN no_data_found THEN
	       println('WARNING: old style parameter: range');
	       range_code_i := fnd_flex_types.get_code(typ => 'RANGE_CODES',
						       descr => range);
	 END;
       ELSIF(value_set IS NOT NULL) THEN
	 SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          Decode(validation_type, 'P', 'P', NULL)
	   INTO range_code_i
	   FROM fnd_flex_value_sets v
	   WHERE v.flex_value_set_id = value_set_id_i;
      END IF;
   EXCEPTION
      WHEN no_data_found THEN
	 message('bad range specified');
	 RAISE bad_parameter;
   END;

   IF(do_validation AND value_set IS NOT NULL) THEN
      BEGIN
	 SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          NULL
	   INTO dummy
	   FROM fnd_flex_value_sets v
	   WHERE v.flex_value_set_id = value_set_id_i
	   AND Decode(v.validation_type, 'P', 'P', 'A')
	   = Decode(range_code_i, 'P', 'P', 'A');
      EXCEPTION
	 WHEN no_data_found THEN
	    message('range code pair required with pair validated value set');
	    RAISE bad_parameter;
      END;
      -- make sure the value set can be used in this segment
      DECLARE
	 application_column_type_i
	   fnd_columns.column_type%TYPE;
	 application_column_width_i
	   fnd_columns.width%TYPE;
	 application_table_name_i
	   fnd_descriptive_flexs.application_table_name%TYPE;
      BEGIN
	 -- get information on the table column
        BEGIN
	   SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          c.column_type, c.width,
	     df.application_table_name
	     INTO application_column_type_i, application_column_width_i,
	     application_table_name_i
	     FROM fnd_columns c, fnd_tables t, fnd_descriptive_flexs df
	     WHERE c.application_id = t.application_id
	     AND c.table_id = t.table_id
	     AND c.column_name =  create_segment.column
	     AND t.table_name = df.application_table_name
	     AND t.application_id = df.table_application_id
	     AND df.application_id =  create_segment.application_id_i
	     AND df.descriptive_flexfield_name = create_segment.flexfield_name;
	EXCEPTION
	   WHEN OTHERS THEN
	      message('error getting information on the column:'||
		      column);
	      RAISE bad_parameter;
	END;

	-- check the validation type and the format type
	-- this should really be in the value sets package
        BEGIN
	   SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          NULL INTO dummy
	     FROM  fnd_flex_value_sets v, fnd_lookup_values vt,
		   fnd_lookup_values ft
	     WHERE v.flex_value_set_id = value_set_id_i
	     AND vt.lookup_type = 'SEG_VAL_TYPES'
	     AND vt.lookup_code = v.validation_type
	     AND ft.lookup_type = 'FIELD_TYPE'
	     AND ft.lookup_code = v.format_type
             AND ROWNUM = 1;
	EXCEPTION
	   WHEN no_data_found THEN
	      message('bad validation type or format type');
	      message('value set:' || value_set);
	      RAISE bad_parameter;
	END;
        BEGIN
	   SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          NULL INTO dummy
	     FROM fnd_flex_value_sets v, fnd_flex_validation_tables t
	     WHERE v.flex_value_set_id = value_set_id_i
	     AND v.flex_value_set_id = t.flex_value_set_id (+)
	     AND (application_column_type_i IN ('C', 'V')
		  OR v.validation_type = 'U'
		  OR application_column_type_i = Nvl(t.id_column_type,
						     Decode(v.format_type,
							    'M', 'N',
							    'T', 'D',
							    'I', 'D',
							    'X', 'D',
							    'Y', 'D',
							    'Z', 'D',
							    v.format_type)))
	     AND (application_column_type_i = 'D'
		  OR application_column_width_i
		  >= Nvl(t.id_column_size, v.maximum_size))
	     AND(v.validation_type <> 'D'
		 OR EXISTS (SELECT NULL
			    FROM fnd_descr_flex_column_usages u
			    WHERE application_id = application_id_i
			    AND descriptive_flexfield_name
			    = create_segment.flexfield_name
			    AND descriptive_flex_context_code
			    = create_segment.context_name
			    AND u.flex_value_set_id
			    = v.parent_flex_value_set_id));
	EXCEPTION
	   WHEN no_data_found THEN
	      message('this value set cannot be used with this column');
	      message('value set:' || value_set);
	      message('column:' || column);
	      message('table:' || application_table_name_i);
	      message('application_column_type_i:'||application_column_type_i);
	      message('application_column_width_i:' ||
		      application_column_width_i);
	      RAISE bad_parameter;
	   WHEN OTHERS THEN
	      message('possible size or format mismatch');
	      RAISE bad_parameter;
	END;
      END;
   END IF;			  /* do_validation and value_set not null */



  -- validate default type name
  BEGIN
     IF(default_type IS NOT NULL) THEN
	 BEGIN
	    fnd_flex_types.validate_default_type(default_type);
	    default_type_i := default_type;
	 EXCEPTION
	    -- maybe it's still old style
	    WHEN no_data_found THEN
	       println('WARNING: old style parameter: default_type');
	       default_type_i :=
		 fnd_flex_types.get_code(typ => 'FLEX_DEFAULT_TYPE',
					 descr => create_segment.default_type);
	 END;
     END IF;
  EXCEPTION
     WHEN no_data_found THEN
	message('could not create segment - bad type:' || default_type);
	RAISE bad_parameter;
  END;
  IF((default_type IS NULL) AND (default_value IS NOT NULL)) THEN
     message('default type required when default value specified');
     RAISE bad_parameter;
  END IF;
  -- check that the column name can be used
  validate_column_name(application_id_in => application_id_i,
	 descriptive_flexfield_name_in    => flexfield_name,
         descr_flex_context_code_in       => context_name,
         application_column_name_in       => column);

  ins_descr_flex_column_usages(
        application_id => application_id_i,
	descriptive_flexfield_name => flexfield_name,
	descriptive_flex_context_code => context_name,
	application_column_name => column,
	end_user_column_name => name,
	column_seq_num => sequence_number,
	enabled_flag => enabled,
	required_flag => required,
	security_enabled_flag => security_enabled,
	display_flag => displayed,
	display_size => display_size,
	maximum_description_len => description_size,
	concatenation_description_len => concatenated_description_size,
	form_left_prompt => window_prompt,
	form_above_prompt => list_of_values_prompt,
	description => description,
	flex_value_set_id => value_set_id_i,
	range_code => range_code_i,
	default_type => default_type_i,
	default_value => default_value,
	runtime_property_function => runtime_property_function,
	srw_param => srw_parameter);
  insmul_descr_flex_col_usage_tl(
	application_id => application_id_i,
	descriptive_flexfield_name => flexfield_name,
	descriptive_flex_context_code => context_name,
	application_column_name => column,
	form_left_prompt => window_prompt,
	form_above_prompt => list_of_values_prompt,
	description => description);
  println('created segment:' || context_name || '->'
	  || column || '(' || window_prompt || ')');
EXCEPTION
   WHEN OTHERS THEN
      message('error in create_segment:' || SQLCODE);
      message(Sqlerrm);
      message('descriptive flexfield name:'|| flexfield_name);
      message('application column name:'|| column);
      RAISE bad_parameter;
END;

PROCEDURE modify_segment
  (-- PK for segment
   p_appl_short_name  IN VARCHAR2,
   p_flexfield_name   IN VARCHAR2,
   p_context_code     IN VARCHAR2,
   p_segment_name     IN VARCHAR2 DEFAULT NULL,
   p_column_name      IN VARCHAR2 DEFAULT NULL,
   -- Data
   p_description      IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_sequence_number  IN NUMBER DEFAULT fnd_api.g_null_num,
   p_enabled          IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_displayed        IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   -- Validation
   p_value_set        IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_default_type     IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_default_value    IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_required         IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_security_enabled IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   -- Sizes
   p_display_size     IN NUMBER DEFAULT fnd_api.g_null_num,
   p_description_size IN NUMBER DEFAULT fnd_api.g_null_num,
   p_concat_desc_size IN NUMBER DEFAULT fnd_api.g_null_num,
   p_lov_prompt       IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_window_prompt    IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_range            IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_srw_parameter    IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   p_runtime_property_function IN VARCHAR2 DEFAULT fnd_api.g_null_char)
  IS
     l_application_id   fnd_descr_flex_col_usage_vl.application_id%TYPE;
     l_description      fnd_descr_flex_col_usage_vl.description%TYPE;
     l_sequence_number  fnd_descr_flex_col_usage_vl.column_seq_num%TYPE;
     l_enabled          fnd_descr_flex_col_usage_vl.enabled_flag%TYPE;
     l_displayed        fnd_descr_flex_col_usage_vl.display_flag%TYPE;
     l_default_type     fnd_descr_flex_col_usage_vl.default_type%TYPE;
     l_default_value    fnd_descr_flex_col_usage_vl.default_value%TYPE;
     l_required         fnd_descr_flex_col_usage_vl.required_flag%TYPE;
     l_security_enabled fnd_descr_flex_col_usage_vl.security_enabled_flag%TYPE;
     l_display_size     fnd_descr_flex_col_usage_vl.display_size%TYPE;
     l_description_size fnd_descr_flex_col_usage_vl.maximum_description_len%TYPE;
     l_concat_desc_size fnd_descr_flex_col_usage_vl.concatenation_description_len%TYPE;
     l_lov_prompt       fnd_descr_flex_col_usage_vl.form_above_prompt%TYPE;
     l_window_prompt    fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE;
     l_range            fnd_descr_flex_col_usage_vl.range_code%TYPE;
     l_srw_parameter    fnd_descr_flex_col_usage_vl.srw_param%TYPE;
     l_runtime_property_function fnd_descr_flex_col_usage_vl.runtime_property_function%TYPE;
     l_flex_value_set_id fnd_descr_flex_col_usage_vl.flex_value_set_id%TYPE;
     dummy              VARCHAR2(100);
     l_segment_name     fnd_descr_flex_col_usage_vl.end_user_column_name%TYPE;
     l_column_name      fnd_descr_flex_col_usage_vl.application_column_name%TYPE;
     l_column_type      fnd_columns.column_type%TYPE;
     l_column_width     fnd_columns.width%TYPE;
     l_table_name       fnd_descriptive_flexs.application_table_name%TYPE;

     l_last_update_login fnd_descr_flex_col_usage_vl.last_update_login%TYPE
       := last_update_login_f;
     l_last_update_date fnd_descr_flex_col_usage_vl.last_update_date%TYPE
       := last_update_date_f;
     l_last_updated_by fnd_descr_flex_col_usage_vl.last_updated_by%TYPE
       := last_updated_by_f;
BEGIN
   message_init;
   l_application_id := application_id_f(p_appl_short_name);
   IF (NOT segment_exists(p_appl_short_name,
			  p_flexfield_name,
			  p_context_code,
			  p_segment_name,
			  p_column_name)) THEN
      message('Segment does not exist.');
      RAISE bad_parameter;
   END IF;
   SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          description, column_seq_num, enabled_flag,
          display_flag, flex_value_set_id, default_type,
          default_value, required_flag, security_enabled_flag,
          display_size, maximum_description_len, concatenation_description_len,
          form_above_prompt, form_left_prompt, range_code, srw_param,
	  runtime_property_function,
          application_column_name,
          end_user_column_name
     INTO l_description, l_sequence_number, l_enabled,
          l_displayed, l_flex_value_set_id, l_default_type,
          l_default_value, l_required, l_security_enabled,
          l_display_size, l_description_size, l_concat_desc_size,
          l_lov_prompt, l_window_prompt, l_range, l_srw_parameter,
	  l_runtime_property_function,
          l_column_name,
          l_segment_name
     FROM fnd_descr_flex_col_usage_vl
     WHERE application_id = l_application_id
     AND descriptive_flexfield_name = p_flexfield_name
     AND descriptive_flex_context_code = p_context_code
     AND (((p_column_name IS NOT NULL) AND
	   (application_column_name = p_column_name)) OR
	  ((p_segment_name IS NOT NULL) AND
	   (end_user_column_name = p_segment_name)));

   IF (p_description = fnd_api.g_null_char) THEN
      NULL;
    ELSE
      l_description := p_description;
   END IF;

   IF (p_sequence_number = fnd_api.g_null_num) THEN
      NULL;
    ELSE
      l_sequence_number := p_sequence_number;
   END IF;

   IF (p_enabled = fnd_api.g_null_char) THEN
      NULL;
    ELSE
      fnd_flex_types.validate_yes_no_flag(p_enabled);
      l_enabled := p_enabled;
   END IF;

   IF (p_displayed = fnd_api.g_null_char) THEN
      NULL;
    ELSE
      fnd_flex_types.validate_yes_no_flag(p_displayed);
      l_displayed := p_displayed;
   END IF;

   IF (p_value_set = fnd_api.g_null_char) THEN
      NULL;
    ELSE
      value_set_id_f(p_value_set,
		     l_flex_value_set_id);
      -- check the validation type and the format type
      -- this should really be in the value sets package
      BEGIN
	 SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          NULL INTO dummy
	   FROM  fnd_flex_value_sets v, fnd_lookup_values vt,
	   fnd_lookup_values ft
	   WHERE v.flex_value_set_id = l_flex_value_set_id
	   AND vt.lookup_type = 'SEG_VAL_TYPES'
	   AND vt.lookup_code = v.validation_type
	   AND ft.lookup_type = 'FIELD_TYPE'
	   AND ft.lookup_code = v.format_type
	   AND ROWNUM = 1;
      EXCEPTION
	 WHEN no_data_found THEN
	    message('bad validation type or format type');
	    message('value set:' || p_value_set);
	    RAISE bad_parameter;
      END;

      -- Read the column information.
      BEGIN
	 SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          c.column_type, c.width, df.application_table_name
	   INTO l_column_type, l_column_width, l_table_name
	   FROM fnd_columns c, fnd_tables t, fnd_descriptive_flexs df
	   WHERE c.application_id = t.application_id
	     AND c.table_id = t.table_id
	     AND c.column_name =  l_column_name
	     AND t.table_name = df.application_table_name
	     AND t.application_id = df.table_application_id
	     AND df.application_id =  l_application_id
	     AND df.descriptive_flexfield_name = p_flexfield_name;
      EXCEPTION
	 WHEN OTHERS THEN
	    message('error getting information on the column:'||
		    l_column_name);
	    RAISE bad_parameter;
      END;

      -- check column type.
      BEGIN
	 SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          NULL INTO dummy
	   FROM fnd_flex_value_sets v, fnd_flex_validation_tables t
	  WHERE v.flex_value_set_id = l_flex_value_set_id
	    AND v.flex_value_set_id = t.flex_value_set_id (+)
	    AND (l_column_type IN ('C', 'V')
		 OR v.validation_type = 'U'
		 OR l_column_type = Nvl(t.id_column_type,
					Decode(v.format_type,
					       'M', 'N',
					       'T', 'D',
					       'I', 'D',
					       'X', 'D',
					       'Y', 'D',
					       'Z', 'D',
					       v.format_type)))
 	    AND (l_column_type = 'D'
		 OR l_column_width
		  >= Nvl(t.id_column_size, v.maximum_size))
	     AND(v.validation_type <> 'D'
		 OR EXISTS (SELECT NULL
			    FROM fnd_descr_flex_column_usages u
			    WHERE application_id = l_application_id
			    AND descriptive_flexfield_name
			    = p_flexfield_name
			    AND descriptive_flex_context_code
			    = p_context_code
			    AND u.flex_value_set_id
			    = v.parent_flex_value_set_id));
	EXCEPTION
	   WHEN no_data_found THEN
	      message('this value set cannot be used with this column');
	      message('value set:' || p_value_set);
	      message('column:' || l_column_name);
	      message('table:' || l_table_name);
	      message('column type:'|| l_column_type);
	      message('column width:' || l_column_width);
	      RAISE bad_parameter;
	   WHEN OTHERS THEN
	      message('possible size or format mismatch');
	      RAISE bad_parameter;
      END;
   END IF;

   -- Bug 13457601 Added "OR p_default_type is NULL"
   IF (p_default_type = fnd_api.g_null_char OR p_default_type is NULL) THEN
      NULL;
    ELSE
      fnd_flex_types.validate_default_type(p_default_type);
      l_default_type := p_default_type;
   END IF;

   IF (p_default_value = fnd_api.g_null_char) THEN
      NULL;
    ELSE
      l_default_value := p_default_value;
   END IF;

   IF (p_required = fnd_api.g_null_char) THEN
      NULL;
    ELSE
      fnd_flex_types.validate_yes_no_flag(p_required);
      l_required := p_required;
   END IF;

   IF (p_security_enabled = fnd_api.g_null_char) THEN
      NULL;
    ELSE
      fnd_flex_types.validate_yes_no_flag(p_security_enabled);
      l_security_enabled := p_security_enabled;
   END IF;

   IF (p_display_size = fnd_api.g_null_num) THEN
      NULL;
    ELSE
      l_display_size := p_display_size;
   END IF;

   IF (p_description_size = fnd_api.g_null_num) THEN
      NULL;
    ELSE
      l_description_size := p_description_size;
   END IF;

   IF (p_concat_desc_size = fnd_api.g_null_num) THEN
      NULL;
    ELSE
      l_concat_desc_size := p_concat_desc_size;
   END IF;

   IF (p_lov_prompt = fnd_api.g_null_char) THEN
      NULL;
    ELSE
      l_lov_prompt := p_lov_prompt;
   END IF;

   IF (p_window_prompt = fnd_api.g_null_char) THEN
      NULL;
    ELSE
      l_window_prompt := p_window_prompt;
   END IF;

   IF (p_runtime_property_function = fnd_api.g_null_char) THEN
      NULL;
    ELSE
      l_runtime_property_function := p_runtime_property_function;
   END IF;

   IF (p_range = fnd_api.g_null_char) THEN
      NULL;
    ELSE
      BEGIN
	 IF (p_range IS NOT NULL) THEN
	    fnd_flex_types.validate_range_code(p_range);
	    l_range := p_range;
	  ELSIF (l_flex_value_set_id IS NOT NULL) THEN
	    SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          Decode(validation_type, 'P', 'P', NULL)
	      INTO l_range
	      FROM fnd_flex_value_sets
	      WHERE flex_value_set_id = l_flex_value_set_id;
	 END IF;
      EXCEPTION
	 WHEN no_data_found THEN
	    message('bad range specified');
	    RAISE bad_parameter;
      END;
      IF (l_flex_value_set_id IS NOT NULL) THEN
	 BEGIN
	    SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          NULL
	      INTO dummy
	      FROM fnd_flex_value_sets
	      WHERE flex_value_set_id = l_flex_value_set_id
	      AND Decode(validation_type, 'P', 'P', 'A') =
	          Decode(l_range, 'P', 'P', 'A');
	 EXCEPTION
	    WHEN no_data_found THEN
	       message('range pair required with pair validated value set');
	       RAISE bad_parameter;
	 END;
      END IF;
   END IF;

   fnd_descr_flex_col_usage_pkg.update_row
     (x_application_id               => l_application_id,
      x_descriptive_flexfield_name   => p_flexfield_name,
      x_descriptive_flex_context_cod => p_context_code,
      x_application_column_name      => l_column_name,
      x_end_user_column_name         => l_segment_name,
      x_column_seq_num               => l_sequence_number,
      x_enabled_flag                 => l_enabled,
      x_required_flag                => l_required,
      x_security_enabled_flag        => l_security_enabled,
      x_display_flag                 => l_displayed,
      x_display_size                 => l_display_size,
      x_maximum_description_len      => l_description_size,
      x_concatenation_description_le => l_concat_desc_size,
      x_flex_value_set_id            => l_flex_value_set_id,
      x_range_code                   => l_range,
      x_default_type                 => l_default_type,
      x_default_value                => l_default_value,
      x_runtime_property_function    => l_runtime_property_function,
      x_srw_param                    => l_srw_parameter,
      x_form_left_prompt             => l_window_prompt,
      x_form_above_prompt            => l_lov_prompt,
      x_description                  => l_description,
      x_last_update_date             => l_last_update_date,
      x_last_updated_by              => l_last_updated_by,
      x_last_update_login            => l_last_update_login);
EXCEPTION
   WHEN OTHERS THEN
      message('modify_segment exception. SQLERRM : ' || Sqlerrm);
      RAISE;
END modify_segment;

PROCEDURE create_reference_field(appl_short_name    IN VARCHAR2,
				 flexfield_name     IN VARCHAR2,
				 context_field_name IN VARCHAR2,
				 description        IN VARCHAR2)
  IS
     application_id_i fnd_application.application_id%TYPE;
BEGIN
   message_init;
   application_id_i := application_id_f(appl_short_name);

   IF(do_validation) THEN
      -- check that the dff exists
      NULL;
   END IF;
   ins_default_context_fields(application_id_in => application_id_i,
			      flexfield_name_in => flexfield_name,
			      context_field_name_in => context_field_name,
			      description_in => description);

EXCEPTION
   WHEN OTHERS THEN
      message('error in create_reference_field: ' || SQLCODE);
      message(Sqlerrm);
      RAISE bad_parameter;
END;


PROCEDURE delete_reference_field(appl_short_name    IN VARCHAR2,
				 flexfield_name     IN VARCHAR2,
				 context_field_name IN VARCHAR2)
  IS
     application_id_i fnd_application.application_id%TYPE;
     rec_count NUMBER;
BEGIN
   message_init;
   application_id_i := application_id_f(appl_short_name);
   IF(do_validation) THEN
      -- A row cannot be deleted if the context field name
      -- is used as the default context field name for the
      -- descriptive flexfield.
      SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          count('x')
	INTO rec_count
	FROM fnd_descriptive_flexs
	WHERE application_id = application_id_i
	AND descriptive_flexfield_name = flexfield_name
	AND default_context_field_name = context_field_name;

      IF (rec_count > 0) THEN
	 message('this reference field is in use in a flexfield');
	 RAISE bad_parameter;
      END IF;
   END IF;
END;

PROCEDURE disable_columns(appl_short_name       IN VARCHAR2,
			  flexfield_name        IN VARCHAR2,
			  pattern               IN VARCHAR2)
  IS
     last_update_login_i fnd_flex_value_sets.last_update_login%TYPE
       := last_update_login_f;
     last_update_date_i fnd_flex_value_sets.last_update_date%TYPE
       := last_update_date_f;
     last_updated_by_i fnd_flex_value_sets.last_updated_by%TYPE
       := last_updated_by_f;
     application_id_i fnd_application.application_id%TYPE;
     table_application_id_i fnd_application.application_id%TYPE;
     application_table_id_i fnd_tables.table_id%TYPE;
BEGIN
   message_init;
   println('disabling columns for:' || flexfield_name);
   application_id_i := application_id_f(appl_short_name);
 BEGIN
      SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          table_application_id, table_id
	INTO table_application_id_i, application_table_id_i
	FROM fnd_descriptive_flexs df, fnd_tables t
	WHERE df.application_id = application_id_i
	AND df.descriptive_flexfield_name = flexfield_name
	AND t.application_id = df.table_application_id
	AND t.table_name = df.application_table_name;
   EXCEPTION
      WHEN no_data_found THEN
	 message('could not lookup table information for: ' ||
		 flexfield_name);
	 RAISE bad_parameter;
   END;
   BEGIN
      IF(NOT customer_mode) THEN
	 UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_columns SET
	   flexfield_usage_code = 'N',
	   flexfield_application_id = NULL,
	   flexfield_name = NULL
	   WHERE application_id = table_application_id_i
	   AND table_id = application_table_id_i
	   AND flexfield_usage_code = 'D'
	   AND column_name LIKE pattern;
       ELSE
	 UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_columns SET
	   flexfield_usage_code = 'N',
	   flexfield_application_id = application_id_i,
	   flexfield_name = disable_columns.flexfield_name,
	   last_update_date = last_update_date_i,
	   last_updated_by = last_updated_by_i,
	   last_update_login = last_update_login_i
	   WHERE application_id = table_application_id_i
	   AND table_id = application_table_id_i
	   AND flexfield_usage_code = 'D'
	   AND column_name LIKE pattern;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
	 message('could not update fnd_columns:' ||
		 Sqlerrm);
	 RAISE bad_parameter;
   END;
END;

PROCEDURE delete_flexfield(appl_short_name    IN VARCHAR2,
			   flexfield_name     IN VARCHAR2)
  IS
     application_id_i fnd_application.application_id%TYPE;
     table_application_id_i fnd_application.application_id%TYPE;
BEGIN
   message_init;
   application_id_i := application_id_f(appl_short_name);
   BEGIN
       drop_DFV(appl_short_name, flexfield_name);
   EXCEPTION
   WHEN OTHERS THEN
      message('Drop Descriptive Flexfield View (drop_DFV): ' || Sqlerrm);
      message(flexfield_name);
      RAISE;
   END;

  BEGIN
     DELETE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
       FROM fnd_descr_flex_col_usage_tl
       WHERE descriptive_flexfield_name = delete_flexfield.flexfield_name
       AND application_id = application_id_i;
     println('deleted from fnd_descr_col_usage_tl');
  END;

  BEGIN
     DELETE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
       FROM fnd_descr_flex_column_usages
       WHERE descriptive_flexfield_name = delete_flexfield.flexfield_name
       AND application_id = application_id_i;
     println('deleted from fnd_descr_column_usages');
  END;

  BEGIN
     DELETE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
       FROM fnd_descr_flex_contexts_tl
       WHERE descriptive_flexfield_name = delete_flexfield.flexfield_name
       AND application_id = application_id_i;
     println('deleted from fnd_descr_flex_contexts_tl');
  END;

  BEGIN
     DELETE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
       FROM fnd_descr_flex_contexts
       WHERE descriptive_flexfield_name = delete_flexfield.flexfield_name
       AND application_id = application_id_i;
     println('deleted from fnd_descr_flex_contexts');
  END;

  BEGIN
     DELETE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
       FROM fnd_descriptive_flexs_tl
       WHERE descriptive_flexfield_name = delete_flexfield.flexfield_name
       AND application_id = application_id_i;
     println('deleted from fnd_descriptive_flexs_tl');
  END;

  BEGIN
     SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          table_application_id
       INTO table_application_id_i
       FROM fnd_descriptive_flexs
       WHERE descriptive_flexfield_name = flexfield_name
       AND application_id = application_id_i;

     UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_columns SET
       flexfield_usage_code = 'N',
       flexfield_name = NULL
       WHERE flexfield_name = delete_flexfield.flexfield_name
       AND application_id = table_application_id_i;
     println('updated fnd_columns');
  EXCEPTION
     WHEN no_data_found THEN
	NULL;
  END;

  DELETE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
    FROM fnd_descriptive_flexs
    WHERE descriptive_flexfield_name = delete_flexfield.flexfield_name
    AND application_id = application_id_i;
  println('deleted from fnd_descriptive_flexs');

  DELETE  /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
    FROM fnd_default_context_fields
    WHERE application_id = application_id_i
    AND descriptive_flexfield_name = flexfield_name;
  println('deleted from fnd_default_context_fields');

  DELETE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
    FROM fnd_compiled_descriptive_flexs
    WHERE application_id = application_id_i
    AND descriptive_flexfield_name = flexfield_name;
  println('deleted fnd_compiled_descriptive_flexs');


   println('deleted flexfield:' || flexfield_name);
END;

/* Bug#5058433 - Added new API that will drop the DFF view */
PROCEDURE drop_DFV (p_application_short_name     IN VARCHAR2,
                    p_descriptive_flexfield_name IN VARCHAR2)
is
   PRAGMA AUTONOMOUS_TRANSACTION;

   cursor l_applsys_schemas is
      select fou.oracle_username
        from fnd_oracle_userid fou,
             fnd_product_installations fpi
       where fou.oracle_id = fpi.oracle_id
         and fpi.application_id = 0;

   l_dfv_name fnd_descriptive_flexs.concatenated_segs_view_name%TYPE;
   l_sql      varchar2(32000);

begin
   select concatenated_segs_view_name
     into l_dfv_name
     from fnd_descriptive_flexs fdf,
          fnd_application fa
    where fa.application_short_name = p_application_short_name
      and fdf.application_id = fa.application_id
      and fdf.descriptive_flexfield_name = p_descriptive_flexfield_name;

   l_sql := 'DROP VIEW ' || l_dfv_name;

   for l_applsys_schema in l_applsys_schemas loop
      ad_ddl.do_ddl(applsys_schema         => l_applsys_schema.oracle_username,
                    application_short_name => p_application_short_name,
                    statement_type         => ad_ddl.drop_view,
                    statement              => l_sql,
                    object_name            => l_dfv_name);
   end loop;

   commit;
exception
   when others then
      rollback;
end drop_DFV;


PROCEDURE enable_context(appl_short_name    IN VARCHAR2,
			 flexfield_name     IN VARCHAR2,
			 context            IN VARCHAR2,
			 enable             IN BOOLEAN DEFAULT TRUE)
  IS
     application_id_i fnd_application.application_id%TYPE;
     enabled_flag_i VARCHAR2(1);
     cnt NUMBER;
BEGIN
   message_init;
   application_id_i := application_id_f(appl_short_name);
   IF(enable) THEN
      enabled_flag_i := 'Y';
    ELSE
      enabled_flag_i := 'N';
   END IF;
   UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_descr_flex_contexts
     SET enabled_flag = enabled_flag_i
     WHERE descriptive_flex_context_code = context
     AND descriptive_flexfield_name = flexfield_name
     AND application_id = application_id_i;
   IF(SQL%rowcount = 0) THEN
      message('context ' || context ||
	      ' in flexfield ' || appl_short_name ||
	      '/' || flexfield_name || ' not found');
      raise_application_error(-20000, message);
   END IF;
END;

/* New API added for Bug 4390452 */
PROCEDURE update_context(
                       p_appl_short_name             IN VARCHAR2,
                       p_flexfield_name              IN VARCHAR2,
                       p_desc_flex_context_code      IN VARCHAR2,
                       p_desc_flex_context_name      IN VARCHAR2 DEFAULT NULL,
                       p_description                 IN VARCHAR2 DEFAULT NULL,
                       p_enabled_flag                IN VARCHAR2 DEFAULT NULL,
                       p_language                    IN VARCHAR2)
  IS
      l_application_id    fnd_application.application_id%TYPE;
      l_boolean_flag1      BOOLEAN;
      l_lang_exists    NUMBER;
      l_dflex_contexts_tl fnd_descr_flex_contexts_tl%ROWTYPE;
      l_enabled_flag      fnd_descr_flex_contexts.enabled_flag%TYPE;
BEGIN
   begin
   select 1 into l_lang_exists from fnd_languages where
     language_code = p_language and installed_flag in ('B','I') and rownum < 2;
   exception
     when no_data_found then
       raise_application_error(-20204, 'FND_FLEX_DSC_API.UPDATE_CONTEXT raised exception: No language exist with language_code ='|| p_language, TRUE);
   end;
   /* Check if context exists */
   l_boolean_flag1 := context_exists(p_appl_short_name,
                                    p_flexfield_name,
                                    p_desc_flex_context_code);
   IF (l_boolean_flag1=TRUE) THEN
     IF (not(p_desc_flex_context_name is NULL AND p_description is NULL and p_enabled_flag is NULL)) THEN
       l_application_id := application_id_f(p_appl_short_name);
       IF (not(p_desc_flex_context_name is NULL AND p_description is NULL)) THEN
          SELECT * into l_dflex_contexts_tl
          from fnd_descr_flex_contexts_tl
          WHERE descriptive_flex_context_code = p_desc_flex_context_code
          AND descriptive_flexfield_name = p_flexfield_name
          AND application_id = l_application_id
          AND language = p_language;

          UPDATE fnd_descr_flex_contexts_tl
          SET descriptive_flex_context_name = nvl(p_desc_flex_context_name, l_dflex_contexts_tl.descriptive_flex_context_name),
              description                   = nvl(p_description, l_dflex_contexts_tl.description)
          WHERE descriptive_flex_context_code = p_desc_flex_context_code
          AND descriptive_flexfield_name = p_flexfield_name
          AND application_id = l_application_id
          AND language = p_language;
       END IF;

       IF (p_enabled_flag is not NULL) THEN
          IF (p_enabled_flag in ('Y','N')) THEN
            SELECT enabled_flag into l_enabled_flag from fnd_descr_flex_contexts
            WHERE descriptive_flex_context_code = p_desc_flex_context_code
            AND descriptive_flexfield_name = p_flexfield_name
            AND application_id = l_application_id;

            UPDATE fnd_descr_flex_contexts
            SET enabled_flag = nvl(p_enabled_flag, l_enabled_flag)
            WHERE descriptive_flex_context_code = p_desc_flex_context_code
            AND descriptive_flexfield_name = p_flexfield_name
            AND application_id = l_application_id;
         ELSE
            raise_application_error(-20205, 'Enabled flag is not set properly. It has to be either Y/N');
         END IF;
       END IF;
     END IF;
   ELSE
      message('Context ' || p_desc_flex_context_code ||
              ' in flexfield ' || p_appl_short_name ||
               '/' || p_flexfield_name || ' not found');
      raise_application_error(-20000, message);
   END IF;
END;




PROCEDURE delete_context(appl_short_name    IN VARCHAR2,
			 flexfield_name     IN VARCHAR2,
			 context            IN VARCHAR2)
  IS
     application_id_i fnd_application.application_id%TYPE;
     rec_count NUMBER;
BEGIN
   message_init;
   application_id_i := application_id_f(appl_short_name);

   -- add this later
   -- when we have a delete reference field also
   IF(FALSE AND do_validation) THEN
      -- A row cannot be deleted if the context field name
      -- is used as the default context field name for the
      -- descriptive flexfield.
      SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          count('x')
	INTO rec_count
	FROM fnd_descriptive_flexs
	WHERE application_id = application_id_i
	AND descriptive_flexfield_name = flexfield_name
	AND default_context_field_name = context;

      IF (rec_count > 0) THEN
	 message('this context field is a reference field');
	 RAISE bad_parameter;
      END IF;
   END IF;

  BEGIN
     DELETE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
       FROM fnd_descr_flex_col_usage_tl
       WHERE descriptive_flex_context_code = context
       AND descriptive_flexfield_name = delete_context.flexfield_name
       AND application_id = application_id_i;
     println('deleted from fnd_descr_col_usage_tl');
  EXCEPTION
     WHEN no_data_found THEN
	NULL;
  END;

  BEGIN
     DELETE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
       FROM fnd_descr_flex_column_usages
       WHERE descriptive_flex_context_code = context
       AND descriptive_flexfield_name = delete_context.flexfield_name
       AND application_id = application_id_i;
     println('deleted from fnd_descr_column_usages');
  EXCEPTION
     WHEN no_data_found THEN
	NULL;
  END;

  BEGIN
     DELETE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
       FROM fnd_descr_flex_contexts_tl
       WHERE descriptive_flex_context_code = context
       AND descriptive_flexfield_name = delete_context.flexfield_name
       AND application_id = application_id_i;
     println('deleted from fnd_descr_flex_contexts_tl');
  EXCEPTION
     WHEN no_data_found THEN
	NULL;
  END;

  BEGIN
     DELETE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
       FROM fnd_descr_flex_contexts
       WHERE descriptive_flex_context_code = context
       AND descriptive_flexfield_name = delete_context.flexfield_name
       AND application_id = application_id_i;
     println('deleted from fnd_descr_flex_contexts');
  EXCEPTION
     WHEN no_data_found THEN
	NULL;
  END;

  println('deleted flexfield context:' ||
	  flexfield_name || '.' || context);
END;



PROCEDURE delete_segment(appl_short_name    IN VARCHAR2,
			 flexfield_name     IN VARCHAR2,
			 context            IN VARCHAR2,
			 segment            IN VARCHAR2)
  IS
     application_id_i fnd_application.application_id%TYPE;
BEGIN
   message_init;
   application_id_i := application_id_f(appl_short_name);

  BEGIN
     DELETE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
       FROM fnd_descr_flex_col_usage_tl t
       WHERE
       EXISTS (SELECT *
	       FROM fnd_descr_flex_column_usages cu
	       WHERE cu.end_user_column_name = segment
	       AND cu.descriptive_flex_context_code = context
	       AND cu.descriptive_flexfield_name = flexfield_name
	       AND cu.application_id = application_id_i
	       /* and join cond: */
	       AND cu.application_column_name = t.application_column_name
	       AND cu.descriptive_flex_context_code =
  	         t.descriptive_flex_context_code
	       AND cu.descriptive_flexfield_name = t.descriptive_flexfield_name
	       AND cu.application_id = t.application_id);
     println('deleted from fnd_descr_col_usage_tl');
  EXCEPTION
     WHEN no_data_found THEN
	NULL;
  END;

  BEGIN
     DELETE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
       FROM fnd_descr_flex_column_usages
       WHERE end_user_column_name = segment
       AND descriptive_flex_context_code = context
       AND descriptive_flexfield_name = flexfield_name
       AND application_id = application_id_i;
     println('deleted from fnd_descr_column_usages');
  EXCEPTION
     WHEN no_data_found THEN
	NULL;
  END;

  println('deleted flexfield segment:' ||
	  flexfield_name || '.' || context || '.' || segment);
END;


FUNCTION flexfield_exists(appl_short_name   IN VARCHAR2,
			  flexfield_name    IN VARCHAR2) RETURN BOOLEAN
  IS
     application_id_i fnd_application.application_id%TYPE;
     cnt NUMBER;
BEGIN
   message_init;
   application_id_i := application_id_f(appl_short_name);
   SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          COUNT(*)
     INTO cnt
     FROM fnd_descriptive_flexs
     WHERE application_id = application_id_i
     AND descriptive_flexfield_name = flexfield_name;
   IF(cnt > 0) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      message('exception in flexfield_exists:' || Sqlerrm);
      RAISE bad_parameter;
END;

FUNCTION context_exists(p_appl_short_name IN VARCHAR2,
			p_flexfield_name  IN VARCHAR2,
			p_context_code    IN VARCHAR2) RETURN BOOLEAN
  IS
     l_application_id fnd_application.application_id%TYPE;
BEGIN
   message_init;
   l_application_id := application_id_f(p_appl_short_name);
   BEGIN
      check_existance(l_application_id, p_flexfield_name);
      check_existance(l_application_id, p_flexfield_name, p_context_code);
   EXCEPTION
      WHEN OTHERS THEN
	 RETURN(FALSE);
   END;
   RETURN(TRUE);
EXCEPTION
   WHEN OTHERS THEN
      NULL;
      RAISE;
END context_exists;

FUNCTION segment_exists(p_appl_short_name IN VARCHAR2,
			p_flexfield_name  IN VARCHAR2,
			p_context_code    IN VARCHAR2,
			p_segment_name    IN VARCHAR2 DEFAULT NULL,
			p_column_name     IN VARCHAR2 DEFAULT NULL)
  RETURN BOOLEAN
  IS
     l_application_id fnd_application.application_id%TYPE;
     cnt NUMBER;
BEGIN
   message_init;
   l_application_id := application_id_f(p_appl_short_name);
   BEGIN
      check_existance(l_application_id, p_flexfield_name);
      check_existance(l_application_id, p_flexfield_name, p_context_code);
   EXCEPTION
      WHEN OTHERS THEN
	 RETURN(FALSE);
   END;
   IF (((p_column_name IS NULL) AND (p_segment_name IS NULL)) OR
       ((p_column_name IS NOT NULL) AND (p_segment_name IS NOT NULL))) THEN
      message('Please pass either p_column_name or p_segment_name but not both.');
      RAISE bad_parameter;
   END IF;
   SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          COUNT(*) INTO cnt
     FROM fnd_descr_flex_column_usages
     WHERE application_id = l_application_id
     AND descriptive_flexfield_name = p_flexfield_name
     AND descriptive_flex_context_code = p_context_code
     AND (((p_column_name IS NOT NULL) AND
	   (application_column_name = p_column_name)) OR
	  ((p_segment_name IS NOT NULL) AND
	   (end_user_column_name = p_segment_name)));
   IF (cnt > 0) THEN
      RETURN(TRUE);
    ELSE
      RETURN(FALSE);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      NULL;
      RAISE;
END segment_exists;

FUNCTION is_table_used(p_application_id IN fnd_tables.application_id%TYPE,
		       p_table_name     IN fnd_tables.table_name%TYPE,
		       x_message        OUT nocopy VARCHAR2) RETURN BOOLEAN
  IS
     up_table_name fnd_tables.table_name%TYPE := Upper(p_table_name);
     l_a_id       fnd_descriptive_flexs.application_id%TYPE;
     l_dff_name   fnd_descriptive_flexs.descriptive_flexfield_name%TYPE;
BEGIN
   x_message := 'This table is not used by Descriptive Flexfields.';
   BEGIN
      SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          application_id, descriptive_flexfield_name
	INTO l_a_id, l_dff_name
	FROM fnd_descriptive_flexs
	WHERE table_application_id = p_application_id
	AND Upper(application_table_name) = up_table_name
	AND ROWNUM = 1;
      x_message :=
	'This table is used by ' || chr_newline ||
	'APPLICATION_ID : ' || l_a_id || chr_newline ||
	'DESCRIPTIVE_FLEXFIELD_NAME : ' || l_dff_name;
      RETURN(TRUE);
   EXCEPTION
      WHEN no_data_found THEN
	 NULL;
      WHEN OTHERS THEN
	 x_message :=
	   'SELECT FROM FND_DESCRIPTIVE_FLEXS is failed. ' || chr_newline ||
	   'SQLERRM : ' || Sqlerrm;
	 RETURN(TRUE);
   END;
   RETURN(FALSE);
EXCEPTION
   WHEN OTHERS THEN
      x_message :=
	'FND_FLEX_DSC_API.IS_TABLE_USED is failed. ' || chr_newline ||
	'SQLERRM : ' || Sqlerrm;
      RETURN(TRUE);
END is_table_used;


FUNCTION is_column_used(p_application_id IN fnd_tables.application_id%TYPE,
			p_table_name     IN fnd_tables.table_name%TYPE,
			p_column_name    IN fnd_columns.column_name%TYPE,
			x_message        OUT nocopy VARCHAR2) RETURN BOOLEAN
  IS
     up_table_name  fnd_tables.table_name%TYPE := Upper(p_table_name);
     up_column_name fnd_columns.column_name%TYPE := Upper(p_column_name);
     l_a_id     fnd_descriptive_flexs.application_id%TYPE;
     l_dff_name fnd_descriptive_flexs.descriptive_flexfield_name%TYPE;
     l_context_col fnd_descriptive_flexs.context_column_name%TYPE;
     l_context  fnd_descr_flex_column_usages.descriptive_flex_context_code%TYPE;
     l_segment  fnd_descr_flex_column_usages.end_user_column_name%TYPE;
BEGIN
   x_message := 'This column is not used by Descriptive Flexfields.';
   BEGIN
      SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          application_id, descriptive_flexfield_name,
	context_column_name
	INTO l_a_id, l_dff_name, l_context_col
	FROM fnd_descriptive_flexs
	WHERE table_application_id = p_application_id
	AND Upper(application_table_name) = up_table_name
	AND Upper(context_column_name) = up_column_name
	AND ROWNUM = 1;
      x_message :=
	'This column is used by ' || chr_newline ||
	'APPLICATION_ID : ' || l_a_id || chr_newline ||
	'DESCRIPTIVE_FLEXFIELD_NAME : ' || l_dff_name || chr_newline ||
	'CONTEXT_COLUMN_NAME : ' || l_context_col;
      RETURN(TRUE);
   EXCEPTION
      WHEN no_data_found THEN
	 NULL;
      WHEN OTHERS THEN
	 x_message :=
	   'SELECT FROM FND_DESCRIPTIVE_FLEXS is failed.'||chr_newline ||
	   'SQLERRM : ' || Sqlerrm;
	 RETURN(TRUE);
   END;

   BEGIN
      SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          dfcu.application_id, dfcu.descriptive_flexfield_name,
	dfcu.descriptive_flex_context_code, dfcu.end_user_column_name
	INTO l_a_id, l_dff_name, l_context, l_segment
	FROM fnd_descr_flex_column_usages dfcu, fnd_descriptive_flexs df
	WHERE df.application_id = dfcu.application_id
	AND df.descriptive_flexfield_name = dfcu.descriptive_flexfield_name
	AND df.table_application_id = p_application_id
	AND Upper(df.application_table_name) = up_table_name
	AND Upper(dfcu.application_column_name) = up_column_name
	AND ROWNUM = 1;
      x_message :=
	'This column is used by ' || chr_newline ||
	'APPLICATION_ID : ' || l_a_id || chr_newline ||
	'DESCRIPTIVE_FLEXFIELD_NAME : ' || l_dff_name || chr_newline ||
	'CONTEXT_CODE : ' || l_context || chr_newline ||
	'SEGMENT_NAME : ' || l_segment;
      RETURN(TRUE);
   EXCEPTION
      WHEN no_data_found THEN
	 NULL;
      WHEN OTHERS THEN
	 x_message :=
	   'SELECT FROM FND_DESCR_FLEX_COLUMN_USAGES is failed.'||chr_newline ||
	   'SQLERRM : ' || Sqlerrm;
	 RETURN(TRUE);
   END;
   RETURN(FALSE);
EXCEPTION
   WHEN OTHERS THEN
      x_message :=
	'FND_FLEX_DSC_API.IS_COLUMN_USED is failed. ' || chr_newline ||
	'SQLERRM : ' || Sqlerrm;
      RETURN(TRUE);
END is_column_used;

-- This API gets the application details
PROCEDURE get_application
          (
            p_application_short_name IN fnd_application.application_short_name%TYPE,
            x_application            OUT NOCOPY fnd_app_type
          ) IS
BEGIN
   SELECT *
     INTO x_application
     FROM fnd_application fa
    WHERE fa.application_short_name = p_application_short_name;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20200,'No Application exists with application_short_name = '
        || p_application_short_name,TRUE);
END get_application;

-- This API gets the table details
PROCEDURE get_table
          (
            p_application_id         IN fnd_application.application_id%TYPE,
            p_table_name             IN fnd_tables.table_name%TYPE,
            x_table                  OUT NOCOPY fnd_tbl_type
          ) IS
BEGIN
   SELECT *
     INTO x_table
     FROM fnd_tables ft
    WHERE ft.application_id = p_application_id
      AND ft.table_name = p_table_name;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20201,'No table exists with application_id = ' || p_application_id
        || ' and table_name = ' || p_table_name,TRUE);
END get_table;

-- This API gets the Descriptive Flexfield details
PROCEDURE get_descriptive_flexfield
          (
            p_application_id              IN fnd_application.application_id%TYPE,
            p_descriptive_flexfield_name  IN fnd_descriptive_flexs.descriptive_flexfield_name%TYPE,
            x_descriptive_flexfield       OUT NOCOPY fnd_dff_type
          ) IS
BEGIN
   SELECT *
     INTO x_descriptive_flexfield
     FROM fnd_descriptive_flexs fdff
    WHERE fdff.application_id = p_application_id
      AND fdff.descriptive_flexfield_name = p_descriptive_flexfield_name;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20203,'No descriptive flexfield exists with application_id = ' ||
         p_application_id || ' and descriptive_flexfield_name = ' || p_descriptive_flexfield_name,TRUE);
END get_descriptive_flexfield;

-- This API renames an exisisting descriptive flexfield
PROCEDURE rename_dff
          (
           p_old_application_short_name IN fnd_application.application_short_name%TYPE,
           p_old_dff_name               IN fnd_descriptive_flexs.descriptive_flexfield_name%TYPE,
           p_new_application_short_name IN fnd_application.application_short_name%TYPE,
           p_new_dff_name               IN fnd_descriptive_flexs.descriptive_flexfield_name%TYPE
          ) IS

   l_old_application                fnd_app_type;
   l_new_application                fnd_app_type;
   l_new_dff                        fnd_dff_type;
   l_old_dff                        fnd_dff_type;
   l_table                          fnd_tbl_type;
   l_dff_name                       fnd_descriptive_flexs.descriptive_flexfield_name%TYPE;
   l_error_message                  VARCHAR2(4000);
   l_illegal_character              VARCHAR2(1000);
   l_last_update_date               fnd_descriptive_flexs.last_update_date%TYPE;
   l_last_updated_by                fnd_descriptive_flexs.last_updated_by%TYPE;
   l_last_update_login              fnd_descriptive_flexs.last_update_login%TYPE;
BEGIN
   l_last_update_date  := SYSDATE;
   l_last_updated_by   := fnd_global.user_id();
   l_last_update_login := fnd_global.login_id();

   -- If l_last_updated_by IS NULL or equals to -1 or l_last_update_login IS NULL then ask user to set context
   IF ((l_last_updated_by IS NULL) OR (l_last_updated_by = -1)) OR (l_last_update_login IS NULL) THEN
        l_error_message := 'Application Security Context is  not set.Please set the context using fnd_global.apps_initialize() and try again.';
        RAISE_APPLICATION_ERROR(error_context_not_set, l_error_message, TRUE);
   END IF;

   -- make sure the old and new dff names are different
   IF p_old_application_short_name = p_new_application_short_name AND
      p_old_dff_name = p_new_dff_name THEN
      l_error_message := 'The old and new DFF names are same.';
      RAISE_APPLICATION_ERROR(error_same_dff_name, l_error_message, TRUE);
   END IF;

   l_illegal_character := REPLACE(TRANSLATE(UPPER(p_new_dff_name), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_$. ',
                                                                   '                                        '), ' ', '');
   IF p_new_dff_name IS NULL THEN
      l_error_message := 'The new DFF name is NULL';
      RAISE_APPLICATION_ERROR(error_invalid_dff_name, l_error_message, TRUE);
   ELSIF LENGTH(p_new_dff_name) > 40 THEN
      l_error_message := 'The name of the new DFF is more than 40 characters';
      RAISE_APPLICATION_ERROR(error_invalid_dff_name, l_error_message, TRUE);
   ELSIF l_illegal_character IS NOT NULL  THEN
      l_error_message := 'The new DFF name contains illegal characters (' || l_illegal_character || ')';
      RAISE_APPLICATION_ERROR(error_invalid_dff_name, l_error_message, TRUE);
   END IF;

   -- Get the old application Id
   get_application(p_application_short_name => p_old_application_short_name,
                   x_application            => l_old_application);

   -- Get the new application Id
   get_application(p_application_short_name => p_new_application_short_name,
                   x_application            => l_new_application);

   --Get the old DFF and make sure the old DFF exists.
   get_descriptive_flexfield(p_application_id             => l_old_application.application_id,
                             p_descriptive_flexfield_name => p_old_dff_name,
                             x_descriptive_flexfield      =>l_old_dff);

   -- Get the table_id
   get_table(p_application_id               => l_old_dff.table_application_id,
             p_table_name                   => l_old_dff.application_table_name,
             x_table                        => l_table);

   --Make sure the new DFF doesn't exist.
   BEGIN
      SELECT /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
             descriptive_flexfield_name
        INTO l_dff_name
        FROM fnd_descriptive_flexs
       WHERE application_id = l_new_application.application_id
         AND descriptive_flexfield_name = p_new_dff_name;
      l_error_message := 'A DFF with name ' || p_new_dff_name || ' already exists for the application table ' || l_old_dff.application_table_name;
      RAISE_APPLICATION_ERROR(error_dff_already_exists, l_error_message, TRUE);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
   END;


   UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_descriptive_flexs
      SET application_id = l_new_application.application_id,
          descriptive_flexfield_name = p_new_dff_name,
          last_update_date = l_last_update_date,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login
    WHERE application_id = l_old_application.application_id
      AND descriptive_flexfield_name = l_old_dff.descriptive_flexfield_name;

   UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_descriptive_flexs_tl
      SET application_id = l_new_application.application_id,
          descriptive_flexfield_name = p_new_dff_name,
          last_update_date = l_last_update_date,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login
    WHERE application_id = l_old_application.application_id
      AND descriptive_flexfield_name = l_old_dff.descriptive_flexfield_name;

   UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_default_context_fields
      SET application_id = l_new_application.application_id,
          descriptive_flexfield_name = p_new_dff_name,
          last_update_date = l_last_update_date,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login
    WHERE application_id = l_old_application.application_id
      AND descriptive_flexfield_name = l_old_dff.descriptive_flexfield_name;

   UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_descr_flex_contexts
      SET application_id = l_new_application.application_id,
          descriptive_flexfield_name = p_new_dff_name,
          last_update_date = l_last_update_date,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login
    WHERE application_id = l_old_application.application_id
      AND descriptive_flexfield_name = l_old_dff.descriptive_flexfield_name;

   UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_descr_flex_contexts_tl
      SET application_id = l_new_application.application_id,
          descriptive_flexfield_name = p_new_dff_name,
          last_update_date = l_last_update_date,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login
    WHERE application_id = l_old_application.application_id
      AND descriptive_flexfield_name = l_old_dff.descriptive_flexfield_name;

   UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_descr_flex_column_usages
      SET application_id = l_new_application.application_id,
          descriptive_flexfield_name = p_new_dff_name,
          last_update_date = l_last_update_date,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login
    WHERE application_id = l_old_application.application_id
      AND descriptive_flexfield_name = l_old_dff.descriptive_flexfield_name;

   UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_descr_flex_col_usage_tl
      SET application_id = l_new_application.application_id,
          descriptive_flexfield_name = p_new_dff_name,
          last_update_date = l_last_update_date,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login
    WHERE application_id = l_old_application.application_id
      AND descriptive_flexfield_name = l_old_dff.descriptive_flexfield_name;

   UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
          fnd_columns
      SET flexfield_application_id = l_new_application.application_id,
          flexfield_name = p_new_dff_name,
          last_update_date = l_last_update_date,
          last_updated_by = l_last_updated_by,
          last_update_login = l_last_update_login
    WHERE application_id = l_table.application_id
      AND table_id = l_table.table_id
      AND flexfield_application_id = l_old_dff.application_id
      AND flexfield_name = l_old_dff.descriptive_flexfield_name
      AND flexfield_usage_code IN ('C','D');

   DELETE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
     FROM fnd_compiled_descriptive_flexs
    WHERE application_id = l_old_application.application_id
      AND descriptive_flexfield_name = l_old_dff.descriptive_flexfield_name;

   DELETE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
     FROM fnd_compiled_descriptive_flexs
    WHERE application_id = l_new_application.application_id
      AND descriptive_flexfield_name = l_new_dff.descriptive_flexfield_name;
EXCEPTION
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(error_others, 'FND_FLEX_DSC_API.RENAME_DFF raised exception: ' || sqlerrm || ' errcode : ' || sqlcode, TRUE);
END rename_dff;

-- This API makes the necessary updates to change the base table of a given DFF.
-- The only requirement is that the new table must have the same column names,
-- same column types, and same size or bigger size columns. (For ATTRIBUTE columns).

PROCEDURE migrate_dff
         (
           p_application_short_name      IN fnd_application.application_short_name%TYPE,
           p_descriptive_flexfield_name  IN fnd_descriptive_flexs.descriptive_flexfield_name%TYPE,
           p_new_table_appl_short_name   IN fnd_application.application_short_name%TYPE,
           p_new_table_name              IN fnd_tables.table_name%TYPE
        ) IS

   l_application                  fnd_app_type;
   l_dff                          fnd_dff_type;

   l_old_table                    fnd_tbl_type;
   l_new_table_app                fnd_app_type;
   l_new_table                    fnd_tbl_type;

   l_column_name                  fnd_columns.column_name%TYPE;
   l_error_message                VARCHAR2(4000);

   l_error_msg  VARCHAR2(4000) := '';
   l_last_update_date               fnd_descriptive_flexs.last_update_date%TYPE;
   l_last_updated_by                fnd_descriptive_flexs.last_updated_by%TYPE;
   l_last_update_login              fnd_descriptive_flexs.last_update_login%TYPE;

   CURSOR cur_columns_reg(p_dff       fnd_dff_type,
                          p_old_table fnd_tbl_type,
                          p_new_table fnd_tbl_type) IS
     SELECT old.column_name              old_column_name,
            old.column_type              old_column_type,
            old.width                    old_width,
            old.flexfield_usage_code     old_flexfield_usage_code,
            old.flexfield_application_id old_flexfield_application_id,
            old.flexfield_name           old_flexfield_name,
            new.column_name              new_column_name,
            new.column_type              new_column_type,
            new.width                    new_width,
            new.flexfield_usage_code     new_flexfield_usage_code,
            new.flexfield_application_id new_flexfield_application_id,
            new.flexfield_name           new_flexfield_name
       FROM fnd_columns old, fnd_columns new
      WHERE old.application_id = p_old_table.application_id
        AND old.table_id = p_old_table.table_id

        AND old.flexfield_usage_code in ('C', 'D')
        AND old.flexfield_application_id = p_dff.application_id
        AND old.flexfield_name = p_dff.descriptive_flexfield_name

        AND new.application_id(+) = p_new_table.application_id
        AND new.table_id(+) = p_new_table.table_id

        AND new.column_name(+) = old.column_name
   ORDER BY old.column_sequence;

BEGIN
   l_last_update_date  := SYSDATE;
   l_last_updated_by   := fnd_global.user_id();
   l_last_update_login := fnd_global.login_id();

   -- If l_last_updated_by IS NULL or equals to -1 or l_last_update_login IS NULL then ask user to set context
   IF ((l_last_updated_by IS NULL) OR (l_last_updated_by = -1)) OR (l_last_update_login IS NULL) THEN
      l_error_message := 'Application Security Context not set.Please set the context using fnd_global.apps_initialize() and try again.';
      RAISE_APPLICATION_ERROR(error_context_not_set, l_error_message, TRUE);
   END IF;

   IF p_descriptive_flexfield_name LIKE '$SRS$.%' THEN
      l_error_message := 'This Descriptive Flexfield is meant for SRS parameters and hence this cannot be migrated to some other table';
      RAISE_APPLICATION_ERROR(error_srs_dff, l_error_message, TRUE);
   END IF;
   -- Get the old  application_id
   get_application(p_application_short_name => p_application_short_name,
                   x_application            => l_application);

   --Get the DFF and make sure that it exists.
   get_descriptive_flexfield(
               p_application_id             => l_application.application_id,
               p_descriptive_flexfield_name =>  p_descriptive_flexfield_name,
               x_descriptive_flexfield      =>  l_dff);

   -- Get the old table_id
   get_table(p_application_id               => l_dff.table_application_id,
             p_table_name                   => l_dff.application_table_name,
             x_table                        => l_old_table);


   -- Get the new table application
   get_application(p_application_short_name => p_new_table_appl_short_name,
                   x_application            => l_new_table_app);

   -- Get the new table
   get_table(p_application_id               => l_new_table_app.application_id,
             p_table_name                   => p_new_table_name,
             x_table                        => l_new_table);

   -- Make sure the old and new table info are different
   IF l_new_table.application_id = l_old_table.application_id AND
      l_new_table.table_id = l_old_table.table_id THEN
      l_error_message := 'The old and new tables are same !!!';
      RAISE_APPLICATION_ERROR(error_same_table_name, l_error_message, TRUE);
   END IF;

   FOR rec_columns_reg IN cur_columns_reg(l_dff,
                                          l_old_table,
                                          l_new_table)
   LOOP
       -- Make sure the column is not registered under any other FF
       IF rec_columns_reg.new_column_name IS NULL THEN
          l_error_message := 'The new table does not have the column ' || rec_columns_reg.old_column_name || ' as in the old one';
          RAISE_APPLICATION_ERROR(error_col_not_registered,l_error_message,TRUE);
       ELSIF rec_columns_reg.new_column_type <> rec_columns_reg.old_column_type THEN
          l_error_message := 'The column ' || rec_columns_reg.new_column_name || ' is of different type than in the old table';
          RAISE_APPLICATION_ERROR(error_col_wrong_type,l_error_message,TRUE);
       ELSIF rec_columns_reg.new_width < rec_columns_reg.old_width THEN
          l_error_message := 'The width of the column ' || rec_columns_reg.new_column_name || '(' || rec_columns_reg.new_width || ') is less than the width of the column in the old table (' || rec_columns_reg.old_width || ')';
          RAISE_APPLICATION_ERROR(error_col_wrong_size,l_error_message,TRUE);
       ELSIF rec_columns_reg.new_flexfield_usage_code <> 'N' OR
             rec_columns_reg.new_flexfield_application_id IS NOT NULL OR
             rec_columns_reg.new_flexfield_name IS NOT NULL THEN
             l_error_message := 'The column ' || rec_columns_reg.new_column_name ||
                                 ' is already registered with the flexfield with name = ' || rec_columns_reg.old_flexfield_name ||
                                 ' and application_id = ' ||  rec_columns_reg.old_flexfield_application_id ||
                                 '.The flexfield_usage_code for this column is : ' || rec_columns_reg.new_flexfield_usage_code;
          RAISE_APPLICATION_ERROR(error_col_already_regis, l_error_message, TRUE);
       END IF;
   END LOOP;

    UPDATE /* $Header: AFFFDAIB.pls 120.8.12010000.5 2016/03/11 22:09:54 tebarnes ship $ */
           fnd_descriptive_flexs
       SET application_table_name = p_new_table_name,
           table_application_id = l_new_table.application_id,
           last_update_date = l_last_update_date,
           last_updated_by = l_last_updated_by,
           last_update_login = l_last_update_login
     WHERE application_id = l_dff.application_id
       AND descriptive_flexfield_name = l_dff.descriptive_flexfield_name;

   FOR rec_columns_reg IN cur_columns_reg(l_dff,
                                          l_old_table,
                                          l_new_table)
   LOOP
      -- Update for the column definition for the new table
      UPDATE fnd_columns
         SET flexfield_usage_code = rec_columns_reg.old_flexfield_usage_code,
             flexfield_application_id = l_dff.application_id,
             flexfield_name = l_dff.descriptive_flexfield_name,
             last_update_date = l_last_update_date,
             last_updated_by = l_last_updated_by,
             last_update_login = l_last_update_login
       WHERE application_id = l_new_table.application_id
         AND table_id = l_new_table.table_id
         AND column_name = rec_columns_reg.new_column_name;

      -- Update for the column definition for old table
      UPDATE fnd_columns
         SET flexfield_usage_code = 'N',
             flexfield_application_id = NULL,
             flexfield_name = NULL,
             last_update_date = l_last_update_date,
             last_updated_by = l_last_updated_by,
             last_update_login = l_last_update_login
       WHERE application_id = l_old_table.application_id
         AND table_id = l_old_table.table_id
         AND column_name = rec_columns_reg.old_column_name;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(error_others, 'FND_FLEX_DSC_API.MIGRATE_DFF raised exception: ' || sqlerrm || ' errcode : ' || sqlcode, TRUE);
END migrate_dff;

--
-- Modify_segment_null_default only sets the default_type and default_value
-- to NULL

PROCEDURE modify_segment_null_default
  (-- PK for segment
   p_appl_short_name  IN VARCHAR2,
   p_flexfield_name   IN VARCHAR2,
   p_context_code     IN VARCHAR2,
   p_segment_name     IN VARCHAR2 DEFAULT NULL,
   p_column_name      IN VARCHAR2 DEFAULT NULL)

  IS
     l_application_id   fnd_descr_flex_col_usage_vl.application_id%TYPE;
     l_description      fnd_descr_flex_col_usage_vl.description%TYPE;
     l_sequence_number  fnd_descr_flex_col_usage_vl.column_seq_num%TYPE;
     l_enabled          fnd_descr_flex_col_usage_vl.enabled_flag%TYPE;
     l_displayed        fnd_descr_flex_col_usage_vl.display_flag%TYPE;
     l_default_type     fnd_descr_flex_col_usage_vl.default_type%TYPE;
     l_default_value    fnd_descr_flex_col_usage_vl.default_value%TYPE;
     l_required         fnd_descr_flex_col_usage_vl.required_flag%TYPE;
     l_security_enabled fnd_descr_flex_col_usage_vl.security_enabled_flag%TYPE;
     l_display_size     fnd_descr_flex_col_usage_vl.display_size%TYPE;
     l_description_size
fnd_descr_flex_col_usage_vl.maximum_description_len%TYPE;
     l_concat_desc_size
fnd_descr_flex_col_usage_vl.concatenation_description_len%TYPE;
     l_lov_prompt       fnd_descr_flex_col_usage_vl.form_above_prompt%TYPE;
     l_window_prompt    fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE;
     l_range            fnd_descr_flex_col_usage_vl.range_code%TYPE;
     l_srw_parameter    fnd_descr_flex_col_usage_vl.srw_param%TYPE;
     l_runtime_property_function
fnd_descr_flex_col_usage_vl.runtime_property_function%TYPE;
     l_flex_value_set_id fnd_descr_flex_col_usage_vl.flex_value_set_id%TYPE;
     dummy              VARCHAR2(100);
     l_segment_name     fnd_descr_flex_col_usage_vl.end_user_column_name%TYPE;
     l_column_name
fnd_descr_flex_col_usage_vl.application_column_name%TYPE;
     l_column_type      fnd_columns.column_type%TYPE;
     l_column_width     fnd_columns.width%TYPE;
     l_table_name       fnd_descriptive_flexs.application_table_name%TYPE;

     l_last_update_login fnd_descr_flex_col_usage_vl.last_update_login%TYPE
       := last_update_login_f;
     l_last_update_date fnd_descr_flex_col_usage_vl.last_update_date%TYPE
       := last_update_date_f;
     l_last_updated_by fnd_descr_flex_col_usage_vl.last_updated_by%TYPE
       := last_updated_by_f;
BEGIN
   message_init;
   l_application_id := application_id_f(p_appl_short_name);
   IF (NOT segment_exists(p_appl_short_name,
                          p_flexfield_name,
                          p_context_code,
                          p_segment_name,
                          p_column_name)) THEN
      message('Segment does not exist.');
      RAISE bad_parameter;
   END IF;

   SELECT
          description, column_seq_num, enabled_flag,
          display_flag, flex_value_set_id, default_type,
          default_value, required_flag, security_enabled_flag,
          display_size, maximum_description_len, concatenation_description_len,
          form_above_prompt, form_left_prompt, range_code, srw_param,
          runtime_property_function,
          application_column_name,
          end_user_column_name
     INTO l_description, l_sequence_number, l_enabled,
          l_displayed, l_flex_value_set_id, l_default_type,
          l_default_value, l_required, l_security_enabled,
          l_display_size, l_description_size, l_concat_desc_size,
          l_lov_prompt, l_window_prompt, l_range, l_srw_parameter,
          l_runtime_property_function,
          l_column_name,
          l_segment_name
     FROM fnd_descr_flex_col_usage_vl
     WHERE application_id = l_application_id
     AND descriptive_flexfield_name = p_flexfield_name
     AND descriptive_flex_context_code = p_context_code
     AND (((p_column_name IS NOT NULL) AND
           (application_column_name = p_column_name)) OR
          ((p_segment_name IS NOT NULL) AND
           (end_user_column_name = p_segment_name)));

     -- Set the the default_type and defaul_value to be NULL bug8586864

     l_default_type := fnd_api.g_null_char;
     l_default_value := fnd_api.g_null_char;

fnd_descr_flex_col_usage_pkg.update_row
     (x_application_id               => l_application_id,
      x_descriptive_flexfield_name   => p_flexfield_name,
      x_descriptive_flex_context_cod => p_context_code,
      x_application_column_name      => l_column_name,
      x_end_user_column_name         => l_segment_name,
      x_column_seq_num               => l_sequence_number,
      x_enabled_flag                 => l_enabled,
      x_required_flag                => l_required,
      x_security_enabled_flag        => l_security_enabled,
      x_display_flag                 => l_displayed,
      x_display_size                 => l_display_size,
      x_maximum_description_len      => l_description_size,
      x_concatenation_description_le => l_concat_desc_size,
      x_flex_value_set_id            => l_flex_value_set_id,
      x_range_code                   => l_range,
      x_default_type                 => l_default_type,
      x_default_value                => l_default_value,
      x_runtime_property_function    => l_runtime_property_function,
      x_srw_param                    => l_srw_parameter,
      x_form_left_prompt             => l_window_prompt,
      x_form_above_prompt            => l_lov_prompt,
      x_description                  => l_description,
      x_last_update_date             => l_last_update_date,
      x_last_updated_by              => l_last_updated_by,
      x_last_update_login            => l_last_update_login);
EXCEPTION
   WHEN OTHERS THEN
      message('modify_segment_null_default exception. SQLERRM : ' || Sqlerrm);
      RAISE;
END modify_segment_null_default;

--
-- Remove descriptive flexfields whose base table is not registered in
-- fnd_tables.
--

  PROCEDURE delete_missing_tbl_flexs IS

    l_limit_read NUMBER := 1000;

    CURSOR missing_DFF_base_tbl IS
      SELECT an.application_short_name,
             df.descriptive_flexfield_name,
             df.application_table_name
        FROM fnd_descriptive_flexs df, fnd_application an
       WHERE df.descriptive_flexfield_name NOT LIKE '$SRS$%'
         AND NOT EXISTS
                 (SELECT NULL
                    FROM fnd_tables t
                   WHERE t.table_name = df.application_table_name)
         AND an.application_id = df.application_id;

  BEGIN

      OPEN missing_DFF_base_tbl;

      -- Detail LOOP 1
      LOOP
        FETCH missing_DFF_base_tbl
         BULK COLLECT
         INTO v_details
        LIMIT l_limit_read;

        EXIT WHEN(v_details.COUNT = 0);

        FOR l_row IN v_details.FIRST .. v_details.LAST LOOP


         delete_flexfield( v_details(l_row).d_app_short_name ,
                     v_details(l_row).d_descr_flex_name );


        END LOOP l_row;

      END LOOP; -- End Detail Loop 1

      CLOSE missing_DFF_base_tbl;

  END delete_missing_tbl_flexs;


END fnd_flex_dsc_api;
/* end package */

/
