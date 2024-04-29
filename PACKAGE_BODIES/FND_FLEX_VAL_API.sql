--------------------------------------------------------
--  DDL for Package Body FND_FLEX_VAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_VAL_API" AS
/* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */


chr_newline CONSTANT VARCHAR2(8) := fnd_global.newline;

SUBTYPE vset_type  IS fnd_flex_value_sets%ROWTYPE;
SUBTYPE value_type IS fnd_flex_values_vl%ROWTYPE;
SUBTYPE noview_value_type IS fnd_flex_values%ROWTYPE;

TYPE bind_record_type IS RECORD
  (pos number,
   type VARCHAR2(1));

TYPE bind_array_type IS TABLE OF bind_record_type INDEX BY BINARY_INTEGER;

TYPE varchar2_array_type IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;

--
-- Error Constants
--
ERROR_UNABLE_TO_FIND_VSET_NAME constant number := -20001;
ERROR_UNABLE_TO_FIND_VSET_ID   constant number := -20002;
ERROR_FLEX_CODE_ERROR          constant number := -20003;
ERROR_EXCEPTION_OTHERS         constant number := -20004;
ERROR_VSET_IS_NOT_INDEPENDENT  constant number := -20005;
ERROR_VSET_IS_NOT_DEPENDENT    constant number := -20006;
ERROR_UNABLE_TO_FIND_HIER_CODE constant number := -20007;
ERROR_UNSUP_VALIDATION_TYPE    constant number := -20008;
ERROR_VALUE_ALREADY_EXISTS     constant number := -20009;
ERROR_UNABLE_TO_FIND_VALUE     constant number := -20010;
ERROR_INVALID_ENABLED_FLAG     constant number := -20011;
ERROR_INVALID_END_DATE         constant number := -20012;
ERROR_INVALID_SUMMARY_FLAG     constant number := -20013;
ERROR_INVALID_STR_HIER_LEVEL   constant number := -20014;
ERROR_UNABLE_TO_FIND_STH_LEVEL constant number := -20015;
ERROR_UNABLE_TO_SET_WHO        constant number := -20016;
ERROR_UNABLE_TO_LOAD_ROW       constant number := -20017;
ERROR_VALUE_VALIDATION_FAILED  constant number := -20018;
ERROR_UNABLE_TO_GET_PARENT_VST constant number := -20019;
ERROR_UNABLE_TO_GET_PARENT_VAL constant number := -20020;
ERROR_NOT_A_PARENT_VALUE       constant number := -20021;
ERROR_INVALID_RANGE_ATTRIBUTE  constant number := -20022;
ERROR_INVALID_HIGH_VALUE       constant number := -20023;
ERROR_HIERARCHY_ALREADY_EXISTS constant number := -20024;
ERROR_UNABLE_TO_INSERT_ROW     constant number := -20025;
ERROR_UNABLE_TO_SUBMIT_FDFCHY  constant number := -20026;
ERROR_INVALID_TABLE_VSET       constant number := -20027;

/* ------------------------------------------------------------ */
/*  globals                                                     */
/* ------------------------------------------------------------ */

/* START_PUBLIC */
bad_parameter EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_parameter, -06501);
/* END_PUBLIC */

value_too_large EXCEPTION;
PRAGMA EXCEPTION_INIT(value_too_large, -01401);

who_mode VARCHAR2(1000) := NULL;  /* whether customer_data or seed_data */
internal_messages VARCHAR2(10000);
debug_mode_on BOOLEAN := FALSE;

/* ------------------------------------------------------------ */

/* START_PUBLIC */
PROCEDURE debug_on IS
BEGIN
   debug_mode_on := TRUE;
END;

PROCEDURE debug_off IS
BEGIN
   debug_mode_on := FALSE;
END;
/* END_PUBLIC */

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

PROCEDURE println(msg IN VARCHAR2) IS
BEGIN
   IF(debug_mode_on) THEN
      dbms_debug(msg);
   END IF;
END;

/* ------------------------------------------------------------ */
/*  messaging                                                   */
/* ------------------------------------------------------------ */

PROCEDURE message(msg VARCHAR2) IS
BEGIN
   internal_messages := internal_messages || msg ||
     fnd_flex_val_api.chr_newline; /* hack to add LF */
END;

PROCEDURE message_init IS
BEGIN
   internal_messages := '';
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


/* ------------------------------------------------------------ */
/*  defaults                                                    */
/* ------------------------------------------------------------ */

PROCEDURE pre_insert(flex_value_set_id           IN NUMBER,
		     summary_allowed_flag	 IN VARCHAR2,
		     id_column_name		 IN VARCHAR2,
		     application_table_name      IN VARCHAR2,
		     table_application_id        IN NUMBER,

		     enabled_column_name         OUT nocopy VARCHAR2,
		     hierarchy_level_column_name OUT nocopy VARCHAR2,
		     start_date_column_name      OUT nocopy VARCHAR2,
		     end_date_column_name        OUT nocopy VARCHAR2,
		     summary_column_name         OUT nocopy VARCHAR2,
		     compiled_attribute_column_name OUT nocopy VARCHAR2)
  IS
BEGIN
   IF((summary_allowed_flag = 'Y') AND (id_column_name IS NOT NULL)) THEN
      message('allow summary values must be N to specify id column names');
      RAISE bad_parameter;
   END IF;

   BEGIN
      SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	column_name INTO hierarchy_level_column_name
	FROM fnd_columns c, fnd_tables t
	WHERE c.column_name = 'STRUCTURED_HIERARCHY_LEVEL'
	AND t.table_name = application_table_name
	AND t.application_id= table_application_id
	AND t.table_id = c.table_id
	AND t.application_id = c.application_id
	GROUP BY column_name;
   EXCEPTION
      WHEN no_data_found THEN
	 hierarchy_level_column_name := 'NULL';
   END;

   BEGIN
      SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	column_name INTO enabled_column_name
	FROM fnd_columns c, fnd_tables t
	WHERE c.column_name = 'ENABLED_FLAG'
	AND c.column_type IN ('C', 'V')
	AND t.table_name = application_table_name
	AND t.application_id= table_application_id
	AND t.table_id = c.table_id
	AND t.application_id = c.application_id
	GROUP BY column_name;
   EXCEPTION
      WHEN no_data_found THEN
	 enabled_column_name := '''Y''';
   END;

  BEGIN
  SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    column_name INTO start_date_column_name
    FROM fnd_columns c, fnd_tables t
   WHERE c.column_name = 'START_DATE_ACTIVE'
     AND t.table_name = application_table_name
     AND t.application_id= table_application_id
     AND t.table_id = c.table_id
     AND t.application_id = c.application_id
   GROUP BY column_name;
  EXCEPTION
    WHEN no_data_found THEN
      start_date_column_name := 'TO_DATE(NULL)';
  END;

  BEGIN
  SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    column_name INTO end_date_column_name
    FROM fnd_columns c, fnd_tables t
   WHERE c.column_name = 'END_DATE_ACTIVE'
     AND t.table_name = application_table_name
     AND t.application_id= table_application_id
     AND t.table_id = c.table_id
     AND t.application_id = c.application_id
   GROUP BY column_name;
  EXCEPTION
    WHEN no_data_found THEN
      end_date_column_name := 'TO_DATE(NULL)';
  END;

  BEGIN
  SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    column_name INTO summary_column_name
    FROM fnd_columns c, fnd_tables t
   WHERE c.column_name = 'SUMMARY_FLAG'
     AND t.table_name = application_table_name
     AND t.application_id= table_application_id
     AND t.table_id = c.table_id
     AND t.application_id = c.application_id
   GROUP BY column_name;
  EXCEPTION
    WHEN no_data_found THEN
       summary_column_name := '''N''';
  END;

  BEGIN
  SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    column_name INTO compiled_attribute_column_name
    FROM fnd_columns c, fnd_tables t
   WHERE c.column_name = 'COMPILED_VALUE_ATTRIBUTES'
     AND t.table_name = application_table_name
     AND t.application_id= table_application_id
     AND t.table_id = c.table_id
     AND t.application_id = c.application_id
   GROUP BY column_name;
  EXCEPTION
    WHEN no_data_found THEN
       compiled_attribute_column_name := 'NULL';
  END;

END;



/* ------------------------------------------------------------ */
/* lookups                                                      */
/* ------------------------------------------------------------ */

FUNCTION application_id_f(application_name_in       IN VARCHAR2,
			  application_short_name_in IN VARCHAR2)
  RETURN fnd_application.application_id%TYPE
  IS
     application_id_ret fnd_application.application_id%TYPE;
BEGIN
   BEGIN
      SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	application_id
	INTO application_id_ret
	FROM fnd_application
	WHERE application_short_name = application_short_name_in;
   EXCEPTION
      WHEN no_data_found THEN
	 SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	   application_id
	   INTO application_id_ret
	   FROM fnd_application_tl
	   WHERE application_name = application_name_in
             AND rownum =1;
   END;
   RETURN application_id_ret;
EXCEPTION
   WHEN OTHERS THEN
      IF(application_name_in IS NULL
	 AND application_short_name_in IS NULL) THEN
	 message('must specify appl_short_name');
       ELSE
	 message('error locating application id');
	 message('appl_short_name:' || application_short_name_in);
	 message('application_name:' || application_name_in);
	 message(Sqlerrm);
      END IF;
      RAISE bad_parameter;
END;


FUNCTION value_set_id_f(value_set_name_in IN VARCHAR2)
  RETURN fnd_flex_value_sets.flex_value_set_id%TYPE
  IS
     value_set_id_i fnd_flex_value_sets.flex_value_set_id%TYPE;
BEGIN
   SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
     flex_value_set_id
     INTO value_set_id_i
     FROM fnd_flex_value_sets
     WHERE flex_value_set_name = value_set_name_in;
   RETURN value_set_id_i;
EXCEPTION
   WHEN no_data_found THEN
      message('bad valueset name:' || value_set_name_in);
      RAISE bad_parameter;
END;


FUNCTION event_code_f(event_in IN VARCHAR2)
  RETURN fnd_flex_validation_events.event_code%TYPE
  IS
     event_code_i fnd_flex_validation_events.event_code%TYPE;
BEGIN
   BEGIN
      fnd_flex_types.validate_event_type(event_in);
      event_code_i := event_in;
   EXCEPTION
      -- maybe it's still old style
      WHEN no_data_found THEN
	 println('WARNING: old style parameter: event_code');
	 event_code_i :=
	   fnd_flex_types.get_code(typ => 'FLEX_VALIDATION_EVENTS',
				   descr => event_in);
   END;
   RETURN event_code_i;
EXCEPTION
   WHEN no_data_found THEN
      message('bad event name:' || event_in);
      RAISE bad_parameter;
END;


FUNCTION field_type_f(type_value_in IN VARCHAR2)
  RETURN fnd_lookups.lookup_code%TYPE
  IS
     type_i fnd_lookups.lookup_code%TYPE := NULL;
BEGIN
   IF(type_value_in IS NOT NULL) THEN
      BEGIN
	 fnd_flex_types.validate_field_type(type_value_in);
	 type_i := type_value_in;
      EXCEPTION
	 -- maybe it's still old style
	 WHEN no_data_found THEN
	    println('WARNING: old style parameter: field_type');
	 type_i :=
	   fnd_flex_types.get_code(typ => 'FIELD_TYPE',
				   descr => type_value_in);
      END;
   END IF;
   RETURN type_i;
EXCEPTION
   WHEN no_data_found THEN
      message('bad field type:' || type_value_in);
      RAISE bad_parameter;
END;


FUNCTION column_type_f(type_value_in IN VARCHAR2)
  RETURN fnd_lookups.lookup_code%TYPE
  IS
     type_i fnd_lookups.lookup_code%TYPE := NULL;
BEGIN
   IF(type_value_in IS NOT NULL) THEN
      BEGIN
	 fnd_flex_types.validate_column_type(type_value_in);
	 type_i := type_value_in;
      EXCEPTION
	 -- maybe it's still old style
	 WHEN no_data_found THEN
	    println('WARNING: old style parameter: column_type');
	 type_i :=
	   fnd_flex_types.get_code(typ => 'COLUMN_TYPE',
				   descr => type_value_in);
      END;
   END IF;
   RETURN type_i;
EXCEPTION
   WHEN no_data_found THEN
      message('bad column type:' || type_value_in);
      RAISE bad_parameter;
END;




FUNCTION invert_flag_f(flag IN VARCHAR2)
  RETURN VARCHAR2
  IS
BEGIN
   IF(flag = 'Y') THEN
      RETURN 'N';
    ELSIF(flag = 'N') THEN
      RETURN 'Y';
    ELSE
      message('bad Y/N value:' || flag);
      RAISE bad_parameter;
   END IF;
END;

/* ------------------------------------------------------------ */
/*  validation                                                  */
/* ------------------------------------------------------------ */

PROCEDURE check_yesno(val IN VARCHAR2) IS
BEGIN
   IF(val NOT IN ('Y', 'N')) then
      message('Y/N value contained invalid value:' || val);
      RAISE bad_parameter;
   END IF;
END;


-- check the type for the id column and for the meaning column.
-- these can be null
PROCEDURE check_type(table_application_id_in IN NUMBER,
		     application_table_name_in IN VARCHAR2,
		     column_name_in IN VARCHAR2)
  IS
     dummy NUMBER;
BEGIN
   IF(column_name_in IS NOT NULL) THEN
      SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	NULL INTO dummy
	FROM fnd_tables t, fnd_lookup_values l, fnd_columns c
	WHERE t.application_id = table_application_id_in
	AND t.table_name = application_table_name_in
	AND c.application_id = t.application_id
	AND c.column_name = column_name_in
	AND c.table_id = t.table_id
	AND l.lookup_type = 'COLUMN_TYPE'
	AND c.column_type = l.lookup_code
        AND rownum = 1;
--      AND c.column_type IN ('C', 'D', 'N', 'V');
   END IF;
EXCEPTION
   WHEN no_data_found THEN
      message('possible type mismatch with column:'||
	      column_name_in);
      RAISE bad_parameter;
END;

-- check the type for the value column (which is required)
PROCEDURE check_type(table_application_id_in IN NUMBER,
		     application_table_name_in IN VARCHAR2,
		     column_name_in IN VARCHAR2,
		     format_type_in IN VARCHAR2)
  IS
     column_type_i fnd_columns.column_type%TYPE;
     dummy NUMBER;
BEGIN
   BEGIN
      SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	column_type
	INTO column_type_i
	FROM fnd_tables t, fnd_lookup_values l, fnd_columns c
	WHERE t.application_id = table_application_id_in
	AND t.table_name = application_table_name_in
	AND c.application_id = t.application_id
	AND c.table_id = t.table_id
	AND c.column_name = column_name_in
	AND l.lookup_type = 'COLUMN_TYPE'
	AND l.lookup_code = c.column_type
        AND rownum = 1;
   EXCEPTION
      WHEN OTHERS THEN
	 message('error looking up column:'|| column_name_in);
	 message('application table name:'||application_table_name_in);
	 message(Sqlerrm);
	 RAISE bad_parameter;
   END;
   IF(NOT ((format_type_in IN ('D','T','t') AND column_type_i = 'D')
	   OR (format_type_in = 'N' AND column_type_i = 'N')
	   OR column_type_i IN ('C', 'V'))) THEN
      message('possible type mismatch with value column:'||
	      column_name_in);
      message('format type:' || format_type_in);
      message('column_type:' || column_type_i);
      RAISE bad_parameter;
   END IF;
END;

-- Check security for hierarchy setting

PROCEDURE check_yesno_hierarchy(val IN VARCHAR2) IS
BEGIN
   IF(val NOT IN ('Y', 'N','H')) then
      message('Y/N/H value contained invalid value:' || val);
      RAISE bad_parameter;
   END IF;
END;

/* ------------------------------------------------------------ */
/*  insertion functions                                         */
/* ------------------------------------------------------------ */

FUNCTION insert_flex_value_sets(
        /* basic parameters */
	value_set_name		        IN varchar2,
	description			IN varchar2,
	security_enabled_flag		IN varchar2,
	longlist_flag			IN varchar2,
	format_type			IN varchar2,
	maximum_size   			IN number,
	number_precision 		IN number,
	alphanumeric_allowed_flag 	IN varchar2,
	uppercase_only_flag 		IN varchar2,
	numeric_mode_enabled_flag	IN varchar2,
	minimum_value			IN varchar2,
	maximum_value 			IN varchar2,
	validation_type 		IN varchar2,

	/* when creating a dependent value set: */
        dependent_default_value		IN varchar2 DEFAULT null,
	dependent_default_meaning	IN varchar2 DEFAULT null,
	parent_flex_value_set_id	IN number   DEFAULT NULL)
  RETURN number
  IS
     last_update_login fnd_flex_value_sets.last_update_login%TYPE;
     last_update_date  fnd_flex_value_sets.last_update_date%TYPE;
     last_updated_by   fnd_flex_value_sets.last_updated_by%TYPE;
     creation_date     fnd_flex_value_sets.creation_date%TYPE;
     created_by        fnd_flex_value_sets.created_by%TYPE;
     rv NUMBER;
BEGIN
   last_update_login := last_update_login_f();
   last_update_date := last_update_date_f();
   last_updated_by := last_updated_by_f();
   creation_date := creation_date_f();
   created_by := created_by_f();

   check_yesno_hierarchy(security_enabled_flag);
   check_yesno(alphanumeric_allowed_flag);
   check_yesno(numeric_mode_enabled_flag);
   insert /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
     INTO
     fnd_flex_value_sets(flex_value_set_id,
			 flex_value_set_name,
			 validation_type,
			 security_enabled_flag,
			 longlist_flag,
			 format_type,
			 maximum_size,
			 alphanumeric_allowed_flag,
			 uppercase_only_flag,
			 numeric_mode_enabled_flag,
			 description,
			 minimum_value,
			 maximum_value,
			 number_precision,
			 protected_flag,
			 last_update_login,
			 last_update_date,
			 last_updated_by,
			 creation_date,
			 created_by,

			 dependant_default_value,/* note spelling */
			 dependant_default_meaning,/* note spelling */
			 parent_flex_value_set_id)
     VALUES(fnd_flex_value_sets_s.nextval,
	    value_set_name,
	    validation_type,
	    security_enabled_flag,
	    longlist_flag,
	    format_type,
	    maximum_size,
	    alphanumeric_allowed_flag,
	    uppercase_only_flag,
	    numeric_mode_enabled_flag,
	    description,
	    minimum_value,
	    maximum_value,
	    number_precision,
	    'N',
	    last_update_login,
	    last_update_date,
	    last_updated_by,
	    creation_date,
	    created_by,
	    dependent_default_value,
	    dependent_default_meaning,
	    parent_flex_value_set_id);


   println('created value set (type ' || validation_type || ') '
	   || value_set_name);

   SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
     fnd_flex_value_sets_s.CURRVAL INTO rv
     FROM dual;
   RETURN rv;
EXCEPTION
   when dup_val_on_index THEN
      message('insert failed - duplicate value set name or id');
      RAISE bad_parameter;
   when VALUE_TOO_LARGE then
      message('insert value_sets failed - value too large');
      RAISE bad_parameter;
END; /* function */


/* ------------------------------------------------------------ */

PROCEDURE insert_flex_validation_events(
        flex_value_set_id 		IN NUMBER,
	event_code			IN varchar2,
	user_exit			IN long)
  IS
     last_update_login fnd_flex_value_sets.last_update_login%TYPE;
     last_update_date  fnd_flex_value_sets.last_update_date%TYPE;
     last_updated_by   fnd_flex_value_sets.last_updated_by%TYPE;
     creation_date     fnd_flex_value_sets.creation_date%TYPE;
     created_by        fnd_flex_value_sets.created_by%TYPE;
BEGIN
   last_update_login := last_update_login_f();
   last_update_date := last_update_date_f();
   last_updated_by := last_updated_by_f();
   creation_date := creation_date_f();
   created_by := created_by_f();

   insert /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
     INTO
     fnd_flex_validation_events(flex_value_set_id,
				event_code,
				user_exit,
				last_update_login,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by)
     values(flex_value_set_id,
	    event_code,
	    user_exit,
	    last_update_login,
	    last_update_date,
	    last_updated_by,
	    creation_date,
	    created_by);

   println('created validation_events entry ' || event_code);
EXCEPTION
   when dup_val_on_index THEN
      message('insert failed - duplicate value on index');
      RAISE bad_parameter;
   when VALUE_TOO_LARGE then
      message('insert validation_events failed - value too large');
      RAISE bad_parameter;
END; /* proc */


/* ------------------------------------------------------------ */

PROCEDURE insert_flex_validation_tables(
		flex_value_set_id		IN number,
		application_table_name		IN varchar2,
		value_column_name		IN varchar2,
		value_column_type		IN varchar2,
		value_column_size		IN number,
		id_column_name			IN varchar2,
		id_column_type			IN varchar2,
		id_column_size			IN number,
		meaning_column_name		IN varchar2,
		meaning_column_type		IN varchar2,
		meaning_column_size		IN number,
		summary_allowed_flag		IN varchar2,
		table_application_id		IN NUMBER,
		additional_where_clause		IN long,
		additional_quickpick_columns	IN VARCHAR2)
  IS
     last_update_login fnd_flex_value_sets.last_update_login%TYPE;
     last_update_date  fnd_flex_value_sets.last_update_date%TYPE;
     last_updated_by   fnd_flex_value_sets.last_updated_by%TYPE;
     creation_date     fnd_flex_value_sets.creation_date%TYPE;
     created_by        fnd_flex_value_sets.created_by%TYPE;

     enabled_column_name
       fnd_flex_validation_tables.enabled_column_name%TYPE;
     hierarchy_level_column_name
       fnd_flex_validation_tables.hierarchy_level_column_name%TYPE;
     start_date_column_name
       fnd_flex_validation_tables.start_date_column_name%TYPE;
     end_date_column_name
       fnd_flex_validation_tables.end_date_column_name%TYPE;
     summary_column_name
       fnd_flex_validation_tables.summary_column_name%TYPE;
     compiled_attribute_column_name
       fnd_flex_validation_tables.compiled_attribute_column_name%TYPE;
BEGIN
   last_update_login := last_update_login_f();
   last_update_date := last_update_date_f();
   last_updated_by := last_updated_by_f();
   creation_date := creation_date_f();
   created_by := created_by_f();

   check_yesno(summary_allowed_flag);
   pre_insert(
	flex_value_set_id		=> flex_value_set_id,
	summary_allowed_flag		=> summary_allowed_flag,
      	id_column_name			=> id_column_name,
	application_table_name  	=> application_table_name,
     	table_application_id    	=> table_application_id,

	enabled_column_name         	=> enabled_column_name,
	hierarchy_level_column_name 	=> hierarchy_level_column_name,
	start_date_column_name      	=> start_date_column_name,
	end_date_column_name        	=> end_date_column_name,
	summary_column_name         	=> summary_column_name,
	compiled_attribute_column_name 	=> compiled_attribute_column_name);
   INSERT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
     INTO
     fnd_flex_validation_tables(flex_value_set_id,
				application_table_name,
				value_column_name,
				value_column_type,
				value_column_size,
				id_column_name,
				id_column_type,
				id_column_size,
				meaning_column_name,
				meaning_column_type,
				meaning_column_size,
				summary_allowed_flag,
				table_application_id,
				additional_where_clause,
				additional_quickpick_columns,

				compiled_attribute_column_name,
				enabled_column_name,
				hierarchy_level_column_name,
				start_date_column_name,
				end_date_column_name,
				summary_column_name,

				last_update_login,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by)
     VALUES(flex_value_set_id,
	    application_table_name,
	    value_column_name,
	    value_column_type,
	    value_column_size,
	    id_column_name,
	    id_column_type,
	    id_column_size,
	    meaning_column_name,
	    meaning_column_type,
	    meaning_column_size,
	    summary_allowed_flag,
	    table_application_id,
	    additional_where_clause,
	    additional_quickpick_columns,

	    compiled_attribute_column_name,
	    enabled_column_name,
	    hierarchy_level_column_name,
	    start_date_column_name,
	    end_date_column_name,
	    summary_column_name,

	    last_update_login,
	    last_update_date,
	    last_updated_by,
	    creation_date,
	    created_by);
   println('created validation_tables entry ');
EXCEPTION
   when dup_val_on_index THEN
      message('insert failed - duplicate value on index');
      RAISE bad_parameter;
   when VALUE_TOO_LARGE then
      message('insert validation_tables failed - value too large');
      RAISE bad_parameter;
END; /* function */





/* START_PUBLIC */


/* ------------------------------------------------------------ */
/*  public function definitions                                 */
/* ------------------------------------------------------------ */

FUNCTION version RETURN VARCHAR2 IS
BEGIN
   RETURN('$Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $');
END;

FUNCTION message RETURN VARCHAR2 IS
BEGIN
   RETURN internal_messages;
END;

PROCEDURE raise_error(p_error_code IN NUMBER,
		      p_error_text IN VARCHAR2)
  IS
     l_error_text varchar2(32000);
BEGIN
   l_error_text := p_error_text || chr_newline ||
     dbms_utility.format_error_stack();

   raise_application_error(p_error_code, l_error_text);

   -- no exception handling here

END raise_error;

PROCEDURE create_valueset_none(
	/* basic parameters */
	value_set_name		        IN varchar2,
	description			IN varchar2,
	security_available		IN varchar2,
	enable_longlist			IN varchar2,
	format_type			IN varchar2,
	maximum_size   			IN number,
	precision 		        IN number    DEFAULT null,
	numbers_only 			IN varchar2,
	uppercase_only     		IN varchar2,
	right_justify_zero_fill		IN varchar2,
	min_value			IN varchar2,
        max_value 			IN VARCHAR2)
IS
   value_set_id fnd_flex_value_sets.flex_value_set_id%TYPE;
   validation_type fnd_flex_value_sets.validation_type%TYPE;
   format_code fnd_flex_value_sets.format_type%TYPE;
   alphanumeric_allowed fnd_flex_value_sets.alphanumeric_allowed_flag%TYPE;
BEGIN
   validation_type := 'N';

   message_init;
   format_code := field_type_f(format_type);
   alphanumeric_allowed := invert_flag_f(numbers_only);
   value_set_id := insert_flex_value_sets(
	value_set_name            => value_set_name,
	description               => description,
	security_enabled_flag     => security_available,
	longlist_flag             => enable_longlist,
	format_type               => format_code,
	maximum_size              => maximum_size,
	number_precision          => precision,
	alphanumeric_allowed_flag => alphanumeric_allowed,
	uppercase_only_flag       => uppercase_only,
	numeric_mode_enabled_flag => right_justify_zero_fill,
	minimum_value             => min_value,
	maximum_value             => max_value,
	validation_type           => validation_type);
EXCEPTION
   WHEN OTHERS THEN
      message('error in create valueset none');
      RAISE bad_parameter;
END; /* procedure */



PROCEDURE create_valueset_independent(
        /* basic parameters */
	value_set_name		        IN varchar2,
	description			IN varchar2,
	security_available		IN varchar2,
	enable_longlist			IN varchar2,
	format_type			IN varchar2,
	maximum_size   			IN number,
	precision 			IN number   DEFAULT null,
	numbers_only 			IN varchar2,
	uppercase_only     		IN varchar2,
	right_justify_zero_fill		IN varchar2,
	min_value			IN varchar2,
	max_value 			IN VARCHAR2)
IS
   value_set_id fnd_flex_value_sets.flex_value_set_id%TYPE;
   validation_type fnd_flex_value_sets.validation_type%TYPE;
   format_code fnd_flex_value_sets.format_type%TYPE;
   alphanumeric_allowed fnd_flex_value_sets.alphanumeric_allowed_flag%TYPE;
BEGIN
   validation_type := 'I';

   message_init;
   format_code := field_type_f(format_type);
   alphanumeric_allowed := invert_flag_f(numbers_only);
   value_set_id := insert_flex_value_sets(
	value_set_name            => value_set_name,
	description               => description,
	security_enabled_flag     => security_available,
	longlist_flag             => enable_longlist,
	format_type               => format_code,
	maximum_size              => maximum_size,
	number_precision          => precision,
	alphanumeric_allowed_flag => alphanumeric_allowed,
	uppercase_only_flag       => uppercase_only,
	numeric_mode_enabled_flag => right_justify_zero_fill,
	minimum_value             => min_value,
	maximum_value             => max_value,
	validation_type           => validation_type);
EXCEPTION
   WHEN OTHERS THEN
      message('error in create valueset independent');
      RAISE bad_parameter;
END; /* procedure */



PROCEDURE create_valueset_dependent(
        /* basic parameters */
	value_set_name		        IN varchar2,
	description			IN varchar2,
	security_available		IN varchar2,
	enable_longlist			IN varchar2,
	format_type			IN varchar2,
	maximum_size   			IN number,
	precision 			IN number   DEFAULT null,
	numbers_only 			IN varchar2,
	uppercase_only     		IN varchar2,
	right_justify_zero_fill		IN varchar2,
	min_value			IN varchar2,
	max_value 			IN varchar2,

	parent_flex_value_set		IN VARCHAR2,
	dependent_default_value		IN varchar2,
	dependent_default_meaning	IN VARCHAR2)
IS
   value_set_id fnd_flex_value_sets.flex_value_set_id%TYPE;
   parent_id fnd_flex_value_sets.parent_flex_value_set_id%TYPE;
   validation_type fnd_flex_value_sets.validation_type%TYPE;
   format_code fnd_flex_value_sets.format_type%TYPE;
   alphanumeric_allowed fnd_flex_value_sets.alphanumeric_allowed_flag%TYPE;
BEGIN
   validation_type := 'D';

   message_init;
   format_code := field_type_f(format_type);
   alphanumeric_allowed := invert_flag_f(numbers_only);
   BEGIN
      SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	flex_value_set_id INTO parent_id
	FROM fnd_flex_value_sets
	WHERE flex_value_set_name = parent_flex_value_set;
      /* the where clause is on a unique key, so 0 or 1 hits expected. */
   EXCEPTION
      WHEN no_data_found THEN
	 message('could not find value set ' || parent_flex_value_set);
	 RAISE bad_parameter;
   END;

   IF (dependent_default_value IS NULL)
      OR (dependent_default_meaning IS NULL) THEN
         message('Dependent Value Set must have dependent_default_value and' ||
                 ' dependent_default_meaning');
         RAISE bad_parameter;
   END IF;

   value_set_id := insert_flex_value_sets(
	value_set_name            => value_set_name,
	description               => description,
	security_enabled_flag     => security_available,
	longlist_flag             => enable_longlist,
	format_type               => format_code,
	maximum_size              => maximum_size,
	number_precision          => precision,
	alphanumeric_allowed_flag => alphanumeric_allowed,
	uppercase_only_flag       => uppercase_only,
	numeric_mode_enabled_flag => right_justify_zero_fill,
	minimum_value             => min_value,
	maximum_value             => max_value,
	validation_type           => validation_type,

	dependent_default_value   => dependent_default_value,
	dependent_default_meaning => dependent_default_meaning,
	parent_flex_value_set_id  => parent_id);
EXCEPTION
   WHEN OTHERS THEN
      message('error in create valueset dependent');
      RAISE bad_parameter;
END; /* procedure */



PROCEDURE create_valueset_table(
        /* basic parameters */
	value_set_name		        IN varchar2,
	description			IN varchar2,
	security_available		IN varchar2,
	enable_longlist			IN varchar2,
	format_type			IN varchar2,
	maximum_size   			IN number,
	precision 			IN number   DEFAULT null,
	numbers_only 			IN varchar2,
	uppercase_only     		IN varchar2,
	right_justify_zero_fill		IN varchar2,
	min_value			IN varchar2,
	max_value 			IN varchar2,

	table_application		IN VARCHAR2 DEFAULT NULL,
        table_appl_short_name           IN VARCHAR2 DEFAULT NULL,
	table_name			IN varchar2,
	allow_parent_values		IN varchar2,
	value_column_name		IN VARCHAR2,
	value_column_type		IN varchar2,
	value_column_size		IN NUMBER,
	meaning_column_name		IN varchar2 DEFAULT NULL,
	meaning_column_type		IN varchar2 DEFAULT NULL,
	meaning_column_size		IN NUMBER   DEFAULT NULL,
	id_column_name			IN varchar2 DEFAULT NULL,
	id_column_type			IN varchar2 DEFAULT NULL,
	id_column_size			IN number   DEFAULT NULL,
	where_order_by  		IN varchar2 DEFAULT NULL,
	additional_columns	        IN VARCHAR2 DEFAULT NULL)
IS
   validation_type     fnd_flex_value_sets.validation_type%TYPE;
   value_set_id        fnd_flex_value_sets.flex_value_set_id%TYPE;
   table_application_id_i      fnd_application.application_id%TYPE;
   format_code fnd_flex_value_sets.format_type%TYPE;
   value_column_type_code fnd_flex_value_sets.format_type%TYPE;
   meaning_column_type_code fnd_flex_value_sets.format_type%TYPE;
   id_column_type_code fnd_flex_value_sets.format_type%TYPE;
   alphanumeric_allowed fnd_flex_value_sets.alphanumeric_allowed_flag%TYPE;
   l_result       VARCHAR2(10);
   l_message      VARCHAR2(32000);
BEGIN
   validation_type := 'F';

   message_init;
   table_application_id_i := application_id_f(table_application,
					      table_appl_short_name);
   alphanumeric_allowed := invert_flag_f(numbers_only);

   -- get the format code from the type
   format_code := field_type_f(format_type);
   value_column_type_code := column_type_f(value_column_type);
   meaning_column_type_code := column_type_f(meaning_column_type);
   id_column_type_code := column_type_f(id_column_type);

/*
   -- check id column's type
   check_type(table_application_id_i,
	      table_name,
	      id_column_name);
   -- check meaning column's type
   check_type(table_application_id_i,
	      table_name,
	      meaning_column_name);
   -- check the value column
   check_type(table_application_id_i,
	      table_name,
	      value_column_name,
	      format_code);
*/

   validate_table_vset(p_flex_value_set_name           => value_set_name,
                       p_id_column_name                => id_column_name,
                       p_value_column_name             => value_column_name,
                       p_meaning_column_name           => meaning_column_name,
                       p_additional_quickpick_columns  => additional_columns,
                       p_application_table_name        => table_name,
                       p_additional_where_clause       => where_order_by,
                       x_result                        => l_result,
                       x_message                       => l_message);

   IF (l_result = 'Failure') THEN
      raise_error(ERROR_INVALID_TABLE_VSET,l_message);
   END IF;

   value_set_id := insert_flex_value_sets(
	value_set_name            => value_set_name,
	description               => description,
	security_enabled_flag     => security_available,
	longlist_flag             => enable_longlist,
	format_type               => format_code,
	maximum_size              => maximum_size,
	number_precision          => precision,
	alphanumeric_allowed_flag => alphanumeric_allowed,
	uppercase_only_flag       => uppercase_only,
	numeric_mode_enabled_flag => right_justify_zero_fill,
	minimum_value             => min_value,
	maximum_value             => max_value,
	validation_type           => validation_type);
   insert_flex_validation_tables(
	flex_value_set_id 		=> value_set_id,
	application_table_name 		=> table_name,
	value_column_name		=> value_column_name,
	value_column_type 		=> value_column_type_code,
	value_column_size 		=> value_column_size,
	id_column_name 			=> id_column_name,
	id_column_type 			=> id_column_type_code,
	id_column_size 			=> id_column_size,
	meaning_column_name 		=> meaning_column_name,
	meaning_column_type 		=> meaning_column_type_code,
	meaning_column_size 		=> meaning_column_size,
	summary_allowed_flag 		=> allow_parent_values,
	table_application_id 		=> table_application_id_i,
	additional_where_clause 	=> where_order_by,
	additional_quickpick_columns 	=> additional_columns);
EXCEPTION
   WHEN OTHERS THEN
      message('error in create valueset table');
      RAISE bad_parameter;
END; /* procedure */




PROCEDURE create_valueset_special(
        /* basic parameters */
	value_set_name		        IN varchar2,
	description			IN varchar2,
	security_available		IN varchar2,
	enable_longlist			IN varchar2,
	format_type			IN varchar2,
	maximum_size   			IN number,
	precision 			IN number   DEFAULT null,
	numbers_only 			IN varchar2,
	uppercase_only     		IN varchar2,
	right_justify_zero_fill	IN varchar2,
	min_value			IN varchar2,
	max_value 			IN VARCHAR2)
IS
   value_set_id fnd_flex_value_sets.flex_value_set_id%TYPE;
   validation_type fnd_flex_value_sets.validation_type%TYPE;
   format_code fnd_flex_value_sets.format_type%TYPE;
   alphanumeric_allowed fnd_flex_value_sets.alphanumeric_allowed_flag%TYPE;
BEGIN
   validation_type := 'U';

   message_init;
   -- get the format code from the type
   format_code := field_type_f(format_type);
   alphanumeric_allowed := invert_flag_f(numbers_only);
   value_set_id := insert_flex_value_sets(
	value_set_name            => value_set_name,
	description               => description,
	security_enabled_flag     => security_available,
	longlist_flag             => enable_longlist,
	format_type               => format_code,
	maximum_size              => maximum_size,
	number_precision          => precision,
	alphanumeric_allowed_flag => alphanumeric_allowed,
	uppercase_only_flag       => uppercase_only,
	numeric_mode_enabled_flag => right_justify_zero_fill,
	minimum_value             => min_value,
	maximum_value             => max_value,
	validation_type           => validation_type);
EXCEPTION
   WHEN OTHERS THEN
      message('error in create valueset special');
      RAISE bad_parameter;
END; /* procedure */




PROCEDURE create_valueset_pair(
        /* basic parameters */
	value_set_name		        IN varchar2,
	description			IN varchar2,
	security_available		IN varchar2,
	enable_longlist			IN varchar2,
	format_type			IN varchar2,
	maximum_size   			IN number,
	precision 		        IN number   DEFAULT null,
	numbers_only 	                IN varchar2,
	uppercase_only     		IN varchar2,
	right_justify_zero_fill	        IN varchar2,
	min_value			IN varchar2,
	max_value 			IN VARCHAR2)
IS
   value_set_id fnd_flex_value_sets.flex_value_set_id%TYPE;
   validation_type fnd_flex_value_sets.validation_type%TYPE;
   format_code fnd_flex_value_sets.format_type%TYPE;
   alphanumeric_allowed fnd_flex_value_sets.alphanumeric_allowed_flag%TYPE;
BEGIN
   validation_type := 'P';

   message_init;
   -- get the format code from the type
   format_code := field_type_f(format_type);
   alphanumeric_allowed := invert_flag_f(numbers_only);
   value_set_id := insert_flex_value_sets(
	value_set_name            => value_set_name,
	description               => description,
	security_enabled_flag     => security_available,
	longlist_flag             => enable_longlist,
	format_type               => format_code,
	maximum_size              => maximum_size,
	number_precision          => precision,
	alphanumeric_allowed_flag => alphanumeric_allowed,
	uppercase_only_flag       => uppercase_only,
	numeric_mode_enabled_flag => right_justify_zero_fill,
	minimum_value             => min_value,
	maximum_value             => max_value,
	validation_type           => validation_type);
EXCEPTION
   WHEN OTHERS THEN
      message('error in create valueset pair');
      RAISE bad_parameter;
END; /* procedure */



PROCEDURE add_event(value_set_name              IN VARCHAR2,
		    event	        	IN VARCHAR2,
		    function_text		IN long)
  IS
   event_code fnd_flex_validation_events.event_code%TYPE;
   value_set_id fnd_flex_value_sets.flex_value_set_id%TYPE;
BEGIN
   message_init;
   value_set_id := value_set_id_f(value_set_name);
   -- get the event code from the event name
   event_code := event_code_f(event);
   insert_flex_validation_events(flex_value_set_id => value_set_id,
				 event_code => event_code,
				 user_exit => function_text);
EXCEPTION
   WHEN OTHERS THEN
      message('error in add event');
      RAISE bad_parameter;
END; /* procedure */


PROCEDURE private_delete_valueset(p_value_set IN VARCHAR2,
				  p_force_delete IN BOOLEAN DEFAULT FALSE)
  IS
     l_value_set_id NUMBER(10);
     l_row_count NUMBER;
     l_dummy_vc2 VARCHAR2(90) := NULL;
BEGIN
  --
  -- Value set existance check
  --
  BEGIN
     SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
       flex_value_set_id
       INTO l_value_set_id
       FROM fnd_flex_value_sets
       WHERE flex_value_set_name = p_value_set;
  EXCEPTION
     WHEN no_data_found THEN
	message('could not find value set: ' || p_value_set);
	message('delete aborted');
	RAISE bad_parameter;
  END;

  --
  -- This parameter is used in destructive_rename.
  --
  IF (p_force_delete) THEN
     GOTO label_start_delete;
  END IF;

  --
  -- Check whether this value set is used in somewhere...
  -- Following code is taken from FNDFFMVS Form.
  --

  --
  -- Is this value set a parent value set?
  --
  SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    count(*) INTO l_row_count
    FROM fnd_flex_value_sets
    WHERE validation_type = fnd_flex_types.val_dependent
    AND parent_flex_value_set_id = l_value_set_id;

  IF (l_row_count <> 0) THEN
     message('This value set is used as a parent value set');
     message('You cannot delete independent value set of an ');
     message('independent-dependent value set pair. Delete aborted.');
     RAISE bad_parameter;
  END IF;

  BEGIN
  --
  -- Is this value set used by a key flexfield segment.
  --
  SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    count(*) INTO l_row_count
    FROM fnd_id_flex_segments
    WHERE flex_value_set_id = l_value_set_id;

--  IF (l_row_count <> 0) THEN
--     message('This value set is used in at least one of the key flexfield ');
--     message('segments. You cannot delete a used value set.');
--     message('Delete aborted.');
--     RAISE bad_parameter;
--  END IF;

  IF (l_row_count <> 0)  THEN
    SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
      g.application_id || ':' || g.id_flex_code || ':' ||
      c.id_flex_structure_name || ':' || g.application_column_name
      INTO l_dummy_vc2
      FROM fnd_id_flex_segments g, fnd_id_flex_structures_tl c
     WHERE g.flex_value_set_id = l_value_set_id
       AND c.id_flex_code = g.id_flex_code
       AND c.id_flex_num = g.id_flex_num
       AND c.application_id = g.application_id
       AND ROWNUM = 1;
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
         l_dummy_vc2 := NULL;
 END;

 IF (l_dummy_vc2 IS NOT NULL) THEN
    message('This value set is used by KFF segment : ' || l_dummy_vc2);
    message(' and ' || (l_row_count - 1) || ' other KFF segments.');
    message('You cannot delete a used value set.');
    message('Delete aborted.');
    RAISE bad_parameter;
 END IF;

 BEGIN
  --
  -- Is this value set used by a descriptive flexfield segment.
  --
  SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    count(*) INTO l_row_count
    FROM fnd_descr_flex_column_usages
    WHERE flex_value_set_id = l_value_set_id;

--  IF (l_row_count <> 0) THEN
--     message('This value set is used in at least one of the descriptive ');
--     message('flexfield segments. You cannot delete a used value set.');
--     message('Delete aborted.');
--     RAISE bad_parameter;
--  END IF;

  IF (l_row_count <> 0) THEN
    SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
      application_id || ':' || descriptive_flexfield_name || ':' ||
      end_user_column_name
      INTO l_dummy_vc2
      FROM fnd_descr_flex_column_usages
     WHERE flex_value_set_id = l_value_set_id
       AND ROWNUM = 1;
  END IF;
    EXCEPTION
      WHEN OTHERS THEN
           l_dummy_vc2 := NULL;
 END;

 IF (l_dummy_vc2 IS NOT NULL) THEN
    message('This value set is used by DFF segment : ' || l_dummy_vc2);
    message(' and ' || (l_row_count - 1) || ' other DFF segments.');
    message('You cannot delete a used value set.');
    message('Delete aborted.');
    RAISE bad_parameter;
 END IF;

  --
  -- Is this value set used by flexbuilder?
  -- Flexbuilde is not included in Release 11.0
  -- this part is commented out.
  --
  --   SELECT count(*) INTO row_count FROM fnd_flexbuilder_parameters
  --    WHERE flex_value_set_id = l_value_set_id;
  --
  --   if (row_count <> 0) then
  --      message('This value set is used by one of the flexbuilder rules.');
  --      message('You cannot delete a used value set.');
  --      message('Delete aborted.');
  --      RAISE bad_parameter;
  --   end if;
  --

  -- If we reached to this point, it is OK to delete the value set.

  --
  -- Note : DELETE statement doesn't raise an exception.
  --
  --
  -- Start with deleting values for this value set.
  --

  <<label_start_delete>>
  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_flex_values_tl
    WHERE flex_value_id IN
    (SELECT flex_value_id FROM fnd_flex_values
     WHERE flex_value_set_id = l_value_set_id);

  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_flex_values
    WHERE flex_value_set_id = l_value_set_id;

  --
  -- Delete Value rules.
  --
  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_flex_value_rules_tl
    WHERE flex_value_rule_id IN
    (SELECT flex_value_rule_id FROM fnd_flex_value_rules
     WHERE flex_value_set_id = l_value_set_id);

  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_flex_value_rules
    WHERE flex_value_set_id = l_value_set_id;

  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_flex_value_rule_lines
    WHERE flex_value_set_id = l_value_set_id;

  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_flex_value_rule_usages
    WHERE flex_value_set_id = l_value_set_id;

  --
  -- Delete Value hierarchies.
  --
  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_flex_hierarchies_TL
    WHERE flex_value_set_id = l_value_set_id;

  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_flex_hierarchies
    WHERE flex_value_set_id = l_value_set_id;

  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_flex_value_hierarchies
    WHERE flex_value_set_id = l_value_set_id;

  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_flex_value_norm_hierarchy
    WHERE flex_value_set_id = l_value_set_id;

  --
  -- Delete Table Validated Value set.
  --
  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_flex_validation_tables
    WHERE flex_value_set_id = l_value_set_id;

  --
  -- Delete Special Value set.
  --
  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_flex_validation_events
    WHERE flex_value_set_id = l_value_set_id;

  --
  -- Delete Value Set - Qualifier Assignments.
  --
  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_flex_validation_qualifiers
    WHERE flex_value_set_id = l_value_set_id;

  --
  -- Delete the value set from main table.
  --
  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_flex_value_sets
    WHERE flex_value_set_id = l_value_set_id;

  --
  -- Delete the FND_FLEX_VALUES Descriptive Flexfield context associated
  -- to this value set.
  --
  -- At this point it is better to call
  -- fnd_flex_dsc_api.delete_context('FND',value_set);
  -- But for compatibilty with Form, I am keeping following code.
  --
  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_descr_flex_contexts
    WHERE application_id = 0
    AND descriptive_flexfield_name = 'FND_FLEX_VALUES'
    AND descriptive_flex_context_code = p_value_set;

  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_descr_flex_contexts_TL
    WHERE application_id = 0
    AND descriptive_flexfield_name = 'FND_FLEX_VALUES'
    AND descriptive_flex_context_code = p_value_set;

  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_descr_flex_column_usages
    WHERE application_id = 0
    AND descriptive_flexfield_name = 'FND_FLEX_VALUES'
    AND descriptive_flex_context_code = p_value_set;

  DELETE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
    FROM fnd_descr_flex_col_usage_TL
    WHERE application_id = 0
    AND descriptive_flexfield_name = 'FND_FLEX_VALUES'
    AND descriptive_flex_context_code = p_value_set;

EXCEPTION
   WHEN OTHERS THEN
      message('error occured in private_delete_valueset: ' || p_value_set);
      RAISE bad_parameter;
END private_delete_valueset;

PROCEDURE delete_valueset(value_set IN VARCHAR2)
  IS
BEGIN
   message_init;
   private_delete_valueset(p_value_set => value_set,
			   p_force_delete => FALSE);
END delete_valueset;


PROCEDURE destructive_rename(old_value_set IN VARCHAR2,
			     new_value_set IN VARCHAR2)
  IS
     old_value_set_id NUMBER(10);
     new_value_set_id NUMBER(10);
BEGIN
   message_init;
   IF(old_value_set = new_value_set) THEN
      message('cannot replace self (old=new)');
      RAISE bad_parameter;
   END IF;

   /* get the original value set id */
  BEGIN
     SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
       flex_value_set_id
       INTO old_value_set_id
       FROM fnd_flex_value_sets
       WHERE flex_value_set_name = old_value_set;
  EXCEPTION
     WHEN no_data_found THEN
	message('could not find original value set: ' || old_value_set);
	message('operation aborted');
	RAISE bad_parameter;
  END;

  /* get the new value set id */
  BEGIN
     SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
       flex_value_set_id
       INTO new_value_set_id
       FROM fnd_flex_value_sets
       WHERE flex_value_set_name = new_value_set;
  EXCEPTION
     WHEN no_data_found THEN
	message('could not find new value set: ' || new_value_set);
	message('operation aborted');
	RAISE bad_parameter;
  END;

  /* delete the old value set, and all associated entries */
  BEGIN
     private_delete_valueset(p_value_set => old_value_set,
			     p_force_delete => TRUE);
  EXCEPTION
     WHEN OTHERS THEN
	message('error deleting old valueset - possible data corruption');
	RAISE bad_parameter;
  END;

  /* rename the new value set, and change the id */
  BEGIN
     UPDATE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
       fnd_flex_value_sets SET
       flex_value_set_id = old_value_set_id,
       flex_value_set_name = old_value_set
       WHERE flex_value_set_id = new_value_set_id;
  END;

  /* update fk references */
  BEGIN
     UPDATE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
       fnd_flex_validation_tables SET
       flex_value_set_id = old_value_set_id
       WHERE flex_value_set_id = new_value_set_id;
  EXCEPTION
     WHEN no_data_found THEN NULL;
  END;
  BEGIN
     UPDATE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
       fnd_flex_validation_events SET
       flex_value_set_id = old_value_set_id
       WHERE flex_value_set_id = new_value_set_id;
  EXCEPTION
     WHEN no_data_found THEN NULL;
  END;
  BEGIN
     UPDATE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
       fnd_flex_value_sets SET
       parent_flex_value_set_id = old_value_set_id
       WHERE parent_flex_value_set_id = new_value_set_id;
  EXCEPTION
     WHEN no_data_found THEN NULL;
  END;
EXCEPTION
   WHEN OTHERS THEN
      message('error occured in destructive_rename.');
      message('SQLERRM : ' || Sqlerrm);
      RAISE;
END;

/*  return true if the named value set exists */
FUNCTION valueset_exists(value_set IN VARCHAR2) RETURN BOOLEAN
  IS
     cnt NUMBER;
BEGIN
   SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
     COUNT(*)
     INTO cnt
     FROM fnd_flex_value_sets
     WHERE flex_value_set_name = value_set;
   IF(cnt > 0) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
   END IF;
END;


PROCEDURE crosscheck_size(valueset_r IN fnd_flex_value_sets%ROWTYPE);
PROCEDURE check_precision(valueset_r IN OUT nocopy fnd_flex_value_sets%ROWTYPE);


PROCEDURE update_maxsize(
      value_set_name IN VARCHAR2,
      maxsize        IN fnd_flex_value_sets.maximum_size%TYPE)
  IS
     last_update_login_i fnd_flex_value_sets.last_update_login%TYPE;
     last_update_date_i  fnd_flex_value_sets.last_update_date%TYPE;
     last_updated_by_i   fnd_flex_value_sets.last_updated_by%TYPE;

     valueset_r fnd_flex_value_sets%ROWTYPE;
     maxsize_old NUMBER;
BEGIN
   last_update_login_i := last_update_login_f();
   last_update_date_i := last_update_date_f();
   last_updated_by_i := last_updated_by_f();

   message_init;
   BEGIN
      SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	*
	INTO valueset_r
	FROM fnd_flex_value_sets
	WHERE flex_value_set_name = value_set_name;
   EXCEPTION
      WHEN no_data_found THEN
	 message('could not find valueset ' || value_set_name);
	 RAISE bad_parameter;
   END;

    maxsize_old := valueset_r.maximum_size;
    valueset_r.maximum_size := maxsize;

    --
    -- maxsize cannot be decreased for a database record.
    --
    IF (maxsize < maxsize_old) THEN
       fnd_message.set_name('FND', 'FLEX-CANNOT REDUCE MAX SIZE');
       app_exception.raise_exception;
    END IF;

    --
    -- Maximum_size cannot be changed if right justify is on
    --
    IF (valueset_r.numeric_mode_enabled_flag = 'Y') THEN
       fnd_message.set_name('FND', 'FLEX-NO SIZE CHANGE WITH NUM');
       app_exception.raise_exception;
    END IF;

    --
    -- maxsize must be positive
    --
    IF (maxsize < 1) THEN
      fnd_message.set_name('FND','FLEX-Max size must be positive');
      app_exception.raise_exception;
    END IF;

    --
    -- if format_type is date, datetime, or time, make sure maxsize is an
    -- acceptable value.
    --
    IF(valueset_r.format_type = 'D') THEN
       IF (maxsize NOT IN ('9','11')) THEN
	  fnd_message.set_name('FND','FLEX-Bad Date Length');
          app_exception.raise_exception;
       END IF;
     ELSIF(valueset_r.format_type = 'T') THEN
       IF (maxsize NOT IN ('15','17','18','20')) THEN
	  fnd_message.set_name('FND','FLEX-Bad DateTime Length');
          app_exception.raise_exception;
       END IF;
     ELSIF(valueset_r.format_type = 't') THEN
       IF (maxsize NOT IN (5,8)) THEN
	  fnd_message.set_name('FND','FLEX-Bad Time Length');
          app_exception.raise_exception;
       END IF;
     ELSIF(valueset_r.format_type = 'N') THEN
       IF (maxsize > 38) THEN
	  fnd_message.set_name('FND','FLEX-Bad Num Length');
          app_exception.raise_exception;
      END IF;
    END IF;

    crosscheck_size(valueset_r);
    check_precision(valueset_r);

    println('about to do update');

    BEGIN
       IF(customer_mode) THEN
	  UPDATE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	    fnd_flex_value_sets SET
	    maximum_size = valueset_r.maximum_size,
	    number_precision = valueset_r.number_precision,
	    last_update_date = last_update_date_i,
	    last_updated_by = last_updated_by_i,
	    last_update_login = last_update_login_i
	    WHERE flex_value_set_id = valueset_r.flex_value_set_id;
	ELSE
	  UPDATE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	    fnd_flex_value_sets SET
	    maximum_size = valueset_r.maximum_size,
	    number_precision = valueset_r.number_precision
	    WHERE flex_value_set_id = valueset_r.flex_value_set_id;
       END IF;
    EXCEPTION
       WHEN OTHERS THEN
	  message('error updating fnd_flex_value_sets: ' || Sqlerrm);
	  RAISE;
    END;
EXCEPTION
   WHEN OTHERS THEN
      message('error occured in update_maxsize while processing value set ' ||
	      value_set_name);
      message(Sqlerrm);
      RAISE bad_parameter;
END update_maxsize;



-- Cross check maximum size against table value column size, reducing
-- maximum size if needed.  Do not do cross check if not table-validated
-- or if type is date or if either size is null.

PROCEDURE crosscheck_size(valueset_r IN fnd_flex_value_sets%ROWTYPE)
  IS
     table_r fnd_flex_validation_tables%ROWTYPE;
BEGIN
   IF(valueset_r.validation_type = 'F') THEN
      SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	*
	INTO table_r
	FROM fnd_flex_validation_tables
	WHERE flex_value_set_id = valueset_r.flex_value_set_id;

      IF((valueset_r.validation_type = 'F') AND
	 (table_r.value_column_type <> 'D') AND
	 (valueset_r.maximum_size IS NOT NULL) AND
	 (table_r.value_column_size IS NOT NULL) AND
	 (valueset_r.maximum_size > table_r.value_column_size))
	   THEN
	 UPDATE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	   fnd_flex_validation_tables SET
	   value_column_size = valueset_r.maximum_size
	   WHERE flex_value_set_id = valueset_r.flex_value_set_id;
	 println('increasing value column size');
      END IF;
   END IF;
EXCEPTION
   WHEN no_data_found THEN
      message('internal inconsistency - could not locate table' ||
	      ' validated valueset info for #' ||
	      valueset_r.flex_value_set_id);
      RAISE bad_parameter;
END crosscheck_size;



--  Make sure precision < Max size (if both are non-null)

PROCEDURE check_precision(valueset_r IN OUT nocopy fnd_flex_value_sets%ROWTYPE)
  IS
BEGIN
   IF((valueset_r.maximum_size IS NOT NULL) AND
      (valueset_r.number_precision IS NOT NULL) AND
      (valueset_r.maximum_size <= valueset_r.number_precision)) THEN
      valueset_r.number_precision := valueset_r.maximum_size - 1;
   END IF;
END check_precision;


PROCEDURE check_id_size(valueset_r IN fnd_flex_value_sets%ROWTYPE,
			table_r    IN fnd_flex_validation_tables%ROWTYPE);

PROCEDURE check_meaning_size(valueset_r IN fnd_flex_value_sets%ROWTYPE,
                             table_r    IN fnd_flex_validation_tables%ROWTYPE);


PROCEDURE update_table_sizes(
      value_set_name   IN VARCHAR2,
      id_size          IN fnd_flex_validation_tables.id_column_size%TYPE
			     DEFAULT NULL,
      value_size       IN fnd_flex_validation_tables.value_column_size%TYPE
			     DEFAULT NULL,
      meaning_size     IN fnd_flex_validation_tables.meaning_column_size%TYPE
			     DEFAULT NULL)
  IS
     last_update_login_i fnd_flex_value_sets.last_update_login%TYPE;
     last_update_date_i  fnd_flex_value_sets.last_update_date%TYPE;
     last_updated_by_i   fnd_flex_value_sets.last_updated_by%TYPE;

     valueset_r fnd_flex_value_sets%ROWTYPE;
     table_r fnd_flex_validation_tables%ROWTYPE;
BEGIN
   last_update_login_i := last_update_login_f();
   last_update_date_i := last_update_date_f();
   last_updated_by_i := last_updated_by_f();

   message_init;
   BEGIN
      SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	*
	INTO valueset_r
	FROM fnd_flex_value_sets
	WHERE flex_value_set_name = value_set_name;
   EXCEPTION
      WHEN no_data_found THEN
	 message('could not find valueset ' || value_set_name);
	 RAISE bad_parameter;
   END;
   IF(valueset_r.validation_type <> 'F') THEN
      message('this valueset does not appear to be table validated');
      RAISE bad_parameter;
   END IF;
   BEGIN
      SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	*
	INTO table_r
	FROM fnd_flex_validation_tables
	WHERE flex_value_set_id = valueset_r.flex_value_set_id;
   EXCEPTION
      WHEN no_data_found THEN
	 message('internal inconsistency - could not locate table' ||
		 ' validated valueset info for #' ||
		 valueset_r.flex_value_set_id);
	 RAISE bad_parameter;
   END;


   IF(id_size IS NOT NULL) THEN
      table_r.id_column_size := id_size;
      check_id_size(valueset_r, table_r);
   END IF;

   IF(value_size IS NOT NULL) THEN
      table_r.value_column_size := value_size;
      update_maxsize(value_set_name, value_size);
   END IF;

   IF(meaning_size IS NOT NULL) THEN
      table_r.meaning_column_size := meaning_size;
      check_meaning_size(valueset_r, table_r);
   END IF;

   BEGIN
      IF(customer_mode) THEN
	 UPDATE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	   fnd_flex_validation_tables SET
	   id_column_size = table_r.id_column_size,
	   -- value_column_size = table_r.value_column_size,
	   meaning_column_size = table_r.meaning_column_size,
	   last_update_date = last_update_date_i,
	   last_updated_by = last_updated_by_i,
	   last_update_login = last_update_login_i
	   WHERE flex_value_set_id = table_r.flex_value_set_id;
       ELSE
	 UPDATE /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	   fnd_flex_validation_tables SET
	   id_column_size = table_r.id_column_size,
	   -- value_column_size = table_r.value_column_size,
	   meaning_column_size = table_r.meaning_column_size
	   WHERE flex_value_set_id = table_r.flex_value_set_id;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
	 message('error updating fnd_flex_validation_tables: ' || Sqlerrm);
	  RAISE;
   END;
EXCEPTION
   WHEN OTHERS THEN
      message('error in update_table_sizes: ' || Sqlerrm);
      RAISE bad_parameter;
END update_table_sizes;


PROCEDURE check_id_size(valueset_r IN fnd_flex_value_sets%ROWTYPE,
			table_r    IN fnd_flex_validation_tables%ROWTYPE)
  IS
     width_i NUMBER;
BEGIN
   BEGIN
      SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	width
	INTO width_i
	FROM fnd_columns c, fnd_tables t
	WHERE (t.application_id = table_r.table_application_id
	       OR table_r.table_application_id IS NULL)
		 AND t.table_id = c.table_id
		 AND t.application_id = c.application_id
		 AND c.column_name = table_r.id_column_name
		 AND t.table_name = table_r.application_table_name;
   EXCEPTION
      WHEN no_data_found THEN
	 -- it is possible for the table to not be specified properly
	 NULL;
   END;
   IF (table_r.id_column_size > width_i) THEN
      fnd_message.set_name('FND','FLEX-COLUMN WIDTH ERROR');
      fnd_message.set_token('SIZE',To_char(width_i));
      app_exception.raise_exception;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      message('check id size failed: ' || Sqlerrm);
      RAISE;
END;

PROCEDURE check_meaning_size(valueset_r IN fnd_flex_value_sets%ROWTYPE,
                             table_r    IN fnd_flex_validation_tables%ROWTYPE)
  IS
     width_i NUMBER;
BEGIN
   BEGIN
      SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	width
	INTO width_i
	FROM fnd_columns c, fnd_tables t
	WHERE (t.application_id = table_r.table_application_id
	       OR table_r.table_application_id IS NULL)
		 AND t.table_id = c.table_id
		 AND t.application_id = c.application_id
		 AND c.column_name = table_r.meaning_column_name
		 AND t.table_name = table_r.application_table_name;
   EXCEPTION
      WHEN no_data_found THEN
	 -- it is possible for the table to not be specified properly
	 NULL;
   END;
   IF(table_r.meaning_column_size > width_i) THEN
      fnd_message.set_name('FND','FLEX-COLUMN WIDTH ERROR');
      fnd_message.set_token('SIZE',To_char(width_i));
      app_exception.raise_exception;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      message('check meaning size failed: ' || Sqlerrm);
      RAISE;
END check_meaning_size;

--------------------------------------------------------------
-- Getting Select Statements For Value Sets.
--------------------------------------------------------------

PROCEDURE add_to_select(p_inc_col      IN VARCHAR2,
                        p_col_name     IN VARCHAR2,
                        p_map_code     IN VARCHAR2,
                        x_select       IN OUT nocopy VARCHAR2,
                        x_mapping_code IN OUT nocopy VARCHAR2)
  IS
BEGIN
   x_mapping_code := x_mapping_code || p_map_code;
   IF (p_inc_col = 'Y' AND p_col_name IS NOT NULL) THEN
      x_select := x_select || ',' || chr_newline || p_col_name ;
      x_mapping_code := x_mapping_code || '1';
    ELSE
      x_mapping_code := x_mapping_code || '0';
   END IF;
END add_to_select;

PROCEDURE get_valueset_select
  (p_validation_type IN VARCHAR2,
   p_value_set_name IN fnd_flex_value_sets.flex_value_set_name%TYPE
                       DEFAULT fnd_api.g_miss_char,
   p_value_set_id   IN fnd_flex_value_sets.flex_value_set_id%TYPE
                       DEFAULT fnd_api.g_miss_num,
   p_independent_value IN VARCHAR2 DEFAULT NULL,
   --
   -- Do you want to include these columns in SELECT statement?
   -- VALUE column is always included.
   -- ID and MEANING columns are included by default.
   --
   p_inc_id_col                 IN VARCHAR2 DEFAULT 'Y',
   p_inc_meaning_col            IN VARCHAR2 DEFAULT 'Y',
   p_inc_enabled_col            IN VARCHAR2 DEFAULT 'N',
   p_inc_start_date_col         IN VARCHAR2 DEFAULT 'N',
   p_inc_end_date_col           IN VARCHAR2 DEFAULT 'N',
   p_inc_summary_col            IN VARCHAR2 DEFAULT 'N',
   p_inc_compiled_attribute_col IN VARCHAR2 DEFAULT 'N',
   p_inc_hierarchy_level_col    IN VARCHAR2 DEFAULT 'N',
   p_inc_addtl_user_columns     IN VARCHAR2 DEFAULT 'N',
   p_additional_user_columns    IN VARCHAR2 DEFAULT NULL,
   p_inc_addtl_quickpick_cols   IN VARCHAR2 DEFAULT 'N',
   --
   -- Do you want to add extra checks in SELECT?
   --
   p_check_enabled_flag     IN VARCHAR2 DEFAULT 'Y',
   p_check_validation_date  IN VARCHAR2 DEFAULT 'Y',
   p_validation_date_char   IN VARCHAR2 DEFAULT 'SYSDATE',
   p_inc_user_where_clause  IN VARCHAR2 DEFAULT 'N',
   p_user_where_clause      IN VARCHAR2 DEFAULT NULL,
   p_inc_addtl_where_clause IN VARCHAR2 DEFAULT 'Y',

   x_select       OUT nocopy VARCHAR2,
   x_mapping_code OUT nocopy VARCHAR2,
   x_success      OUT nocopy NUMBER)
  IS
     l_func_name VARCHAR2(100);
     l_vset   fnd_flex_value_sets%ROWTYPE;
     l_tvset  fnd_flex_validation_tables%ROWTYPE;

     l_and VARCHAR2(10);
     l_select VARCHAR2(32000);
     l_inc_addtl_where_clause  VARCHAR2(1);
     l_inc_addtl_quickpick_cols VARCHAR2(1);
     l_mapping_code VARCHAR2(100);
     l_number NUMBER;
BEGIN
   l_func_name := 'get_valueset_select() : ';
   l_and := chr_newline || 'AND (';

   l_inc_addtl_where_clause := p_inc_addtl_where_clause;
   l_inc_addtl_quickpick_cols := p_inc_addtl_quickpick_cols;
   x_select := NULL;
   x_success := g_ret_no_error;
   x_mapping_code := NULL;
   --
   -- We really need XOR.
   --
   IF(p_value_set_name = fnd_api.g_miss_char AND
      p_value_set_id = fnd_api.g_miss_num)
     OR
     (p_value_set_name <> fnd_api.g_miss_char AND
      p_value_set_id <> fnd_api.g_miss_num)
     OR
     (p_value_set_id IS NULL OR p_value_set_name IS NULL) THEN
      message(l_func_name || 'Invalid value set name or id is passed.');
      x_success := g_ret_invalid_parameter;
      RETURN;
   END IF;

   --
   -- At this point either value_set_[id or name] is passed not both.
   --
   BEGIN
      SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	*
	INTO l_vset
	FROM fnd_flex_value_sets
       WHERE (   (p_value_set_id = fnd_api.g_miss_num
		  AND flex_value_set_name = p_value_set_name)
	      OR (p_value_set_name = fnd_api.g_miss_char
		  AND flex_value_set_id = p_value_set_id));
   EXCEPTION
      WHEN no_data_found THEN
	 message(l_func_name || 'Value set does not exist.');
	 x_success := g_ret_no_value_set;
	 RETURN;
      WHEN OTHERS THEN
	 message(l_func_name || 'SELECT FROM fnd_flex_value_sets is failed.' ||
		 chr_newline || 'Error : ' || Sqlerrm);
	 x_success := g_ret_others;
	 RETURN;
   END;
   IF (l_vset.validation_type <> p_validation_type) THEN
      message(l_func_name || 'Validation Type Mismatch.');
      x_success := g_ret_vtype_mismatch;
      RETURN;
   END IF;

   IF (l_vset.validation_type = 'F') THEN
      BEGIN
	 SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	   *
	   INTO l_tvset
	   FROM fnd_flex_validation_tables
	   WHERE flex_value_set_id = l_vset.flex_value_set_id;
      EXCEPTION
	 WHEN no_data_found THEN
	    message(l_func_name || 'Table Info does not exist.');
	    x_success := g_ret_no_table_info;
	    RETURN;
	 WHEN OTHERS THEN
	    message(l_func_name || 'SELECT FROM fnd_flex_validation_tables '||
		    'is failed.' || chr_newline || 'Error : ' || Sqlerrm);
	    x_success := g_ret_others;
	    RETURN;
      END;
    ELSIF (l_vset.validation_type IN ('I','D')) THEN
       l_tvset.application_table_name := 'FND_FLEX_VALUES_VL';

       l_tvset.value_column_name := 'FLEX_VALUE';
       l_tvset.value_column_type := 'V';
       l_tvset.value_column_size := 150;

       l_tvset.id_column_name := 'FLEX_VALUE';
       l_tvset.id_column_type := 'V';
       l_tvset.id_column_size := 150;

       l_tvset.meaning_column_name := 'DESCRIPTION';
       l_tvset.meaning_column_type := 'V';
       l_tvset.meaning_column_size := 240;

       l_tvset.compiled_attribute_column_name := 'COMPILED_VALUE_ATTRIBUTES';
       l_tvset.enabled_column_name := 'ENABLED_FLAG';
       l_tvset.hierarchy_level_column_name := 'STRUCTURED_HIERARCHY_LEVEL';
       l_tvset.start_date_column_name := 'START_DATE_ACTIVE';
       l_tvset.end_date_column_name := 'END_DATE_ACTIVE';
       l_tvset.summary_column_name := 'SUMMARY_FLAG';

       l_tvset.additional_quickpick_columns := NULL;
       l_inc_addtl_where_clause := 'Y';
       IF (l_vset.validation_type = 'I') THEN
	  l_tvset.additional_where_clause := 'FLEX_VALUE_SET_ID = ' ||
	    To_char(l_vset.flex_value_set_id);
	ELSIF (l_vset.validation_type = 'D') THEN
	  IF (p_independent_value IS NULL) THEN
	     message(l_func_name || 'NULL is not a valid independent value.');
	     x_success := g_ret_no_parent_value;
	     RETURN;
	  END IF;
	  l_tvset.additional_where_clause := 'FLEX_VALUE_SET_ID = ' ||
	    To_char(l_vset.flex_value_set_id) || chr_newline ||
	    'AND PARENT_FLEX_VALUE_LOW = ''' || p_independent_value || '''';
       END IF;
    ELSE
       message(l_func_name || 'Unknown validation type is passed.');
       x_success := g_ret_vtype_not_supported;
       RETURN;
   END IF;

   --
   -- Construct SELECT upto WHERE clause.
   --
   l_select := 'SELECT ' || l_tvset.value_column_name;
   l_mapping_code := 'S:VA1';
   add_to_select(p_inc_id_col,
		 l_tvset.id_column_name,'ID',
		 l_select, l_mapping_code);
   add_to_select(p_inc_meaning_col,
		 l_tvset.meaning_column_name,'ME',
		 l_select, l_mapping_code);
   add_to_select(p_inc_enabled_col,
		 l_tvset.enabled_column_name,'EN',
		 l_select, l_mapping_code);
   add_to_select(p_inc_start_date_col,
		 l_tvset.start_date_column_name,'SD',
		 l_select, l_mapping_code);
   add_to_select(p_inc_end_date_col,
		 l_tvset.end_date_column_name,'ED',
		 l_select, l_mapping_code);
   add_to_select(p_inc_summary_col,
		 l_tvset.summary_column_name,'SM',
		 l_select, l_mapping_code);
   add_to_select(p_inc_compiled_attribute_col,
		 l_tvset.compiled_attribute_column_name,'CA',
		 l_select, l_mapping_code);
   add_to_select(p_inc_hierarchy_level_col,
		 l_tvset.hierarchy_level_column_name,'HL',
		 l_select, l_mapping_code);
   add_to_select(p_inc_addtl_user_columns,
		 p_additional_user_columns,'AU',
		 l_select, l_mapping_code);
   --
   -- Additional Quickpick columns may contain INTO statement
   --
   l_number := Instr(Upper(l_tvset.additional_quickpick_columns),' INTO ');
   IF (l_number > 0) THEN
      l_inc_addtl_quickpick_cols := 'N';
   END IF;
   --
   -- Additional columns may also have (*) or ([123456789]) in it.
   -- However PL/SQL doesn't have regular expression search functionality.
   --
   add_to_select(l_inc_addtl_quickpick_cols,
		 l_tvset.additional_quickpick_columns,'AQ',
		 l_select, l_mapping_code);

   l_select := (l_select || chr_newline || 'FROM ' ||
		l_tvset.application_table_name || chr_newline);

   --
   -- Now WHERE clause.
   --
   l_select := l_select || 'WHERE (1 = 1)';
   l_mapping_code := l_mapping_code || 'W:WW1';
   IF (p_check_enabled_flag = 'Y' AND
       l_tvset.enabled_column_name IS NOT NULL) THEN
      l_select := (l_select || l_and ||
		   l_tvset.enabled_column_name || ' = ''Y'')');
      l_mapping_code := l_mapping_code || 'EF1';
    ELSE
      l_mapping_code := l_mapping_code || 'EF0';
   END IF;
   l_number := 0;
   IF (p_check_validation_date = 'Y') THEN
     IF (l_tvset.start_date_column_name IS NOT NULL) THEN
	l_select := (l_select || l_and || l_tvset.start_date_column_name ||
		    ' IS NULL OR ' ||
		    l_tvset.start_date_column_name || ' <= ' ||
		    p_validation_date_char || ')');
	l_number := l_number + 1;
     END IF;
     IF (l_tvset.end_date_column_name IS NOT NULL) THEN
	l_select := (l_select || l_and || l_tvset.end_date_column_name ||
		    ' IS NULL OR ' ||
		    l_tvset.end_date_column_name || ' >= ' ||
		    p_validation_date_char || ')');
	l_number := l_number + 2;
     END IF;
   END IF;
   l_mapping_code := l_mapping_code || 'VD' || To_char(l_number);
   IF (p_inc_user_where_clause = 'Y' AND
       p_user_where_clause IS NOT NULL) THEN
      l_select := l_select || l_and || p_user_where_clause || ')';
      l_mapping_code := l_mapping_code || 'UW1';
    ELSE
      l_mapping_code := l_mapping_code || 'UW0';
   END IF;
   IF (l_inc_addtl_where_clause = 'Y' AND
       length(l_tvset.additional_where_clause) <> 0) THEN
      l_tvset.additional_where_clause :=
	Ltrim(l_tvset.additional_where_clause);
      l_number := Instr(Upper(l_tvset.additional_where_clause),'WHERE ');
      IF (l_number = 1) THEN
	 l_tvset.additional_where_clause :=
	   Substr(l_tvset.additional_where_clause,7);
      END IF;
      --
      -- It may be only ORDER BY clause.
      --
      l_number := Instr(Upper(l_tvset.additional_where_clause),'ORDER BY ');
      IF (l_number = 1) THEN
	 l_select := l_select || chr_newline ||
	   l_tvset.additional_where_clause;
       ELSE
	 l_select := l_select || chr_newline || 'AND ' ||
	   l_tvset.additional_where_clause;
      END IF;
      l_mapping_code := l_mapping_code || 'AW1';
    ELSE
      l_mapping_code := l_mapping_code || 'AW0';
   END IF;

   x_select := l_select;
   x_mapping_code := l_mapping_code;
   x_success := g_ret_no_error;
EXCEPTION
   WHEN OTHERS THEN
      message(l_func_name || ' is failed.' || chr_newline ||
	      'Error : ' || Sqlerrm);
      x_success := g_ret_others;
END get_valueset_select;

PROCEDURE get_table_vset_select
  (p_value_set_name IN fnd_flex_value_sets.flex_value_set_name%TYPE
                       DEFAULT fnd_api.g_miss_char,
   p_value_set_id   IN fnd_flex_value_sets.flex_value_set_id%TYPE
                       DEFAULT fnd_api.g_miss_num,
   --
   -- Do you want to include these columns in SELECT statement?
   -- VALUE column is always included.
   -- ID and MEANING columns are included by default.
   --
   p_inc_id_col                 IN VARCHAR2 DEFAULT 'Y',
   p_inc_meaning_col            IN VARCHAR2 DEFAULT 'Y',
   p_inc_enabled_col            IN VARCHAR2 DEFAULT 'N',
   p_inc_start_date_col         IN VARCHAR2 DEFAULT 'N',
   p_inc_end_date_col           IN VARCHAR2 DEFAULT 'N',
   p_inc_summary_col            IN VARCHAR2 DEFAULT 'N',
   p_inc_compiled_attribute_col IN VARCHAR2 DEFAULT 'N',
   p_inc_hierarchy_level_col    IN VARCHAR2 DEFAULT 'N',
   p_inc_addtl_user_columns     IN VARCHAR2 DEFAULT 'N',
   p_additional_user_columns    IN VARCHAR2 DEFAULT NULL,
   p_inc_addtl_quickpick_cols   IN VARCHAR2 DEFAULT 'N',
   --
   -- Do you want to add extra checks in SELECT?
   --
   p_check_enabled_flag     IN VARCHAR2 DEFAULT 'Y',
   p_check_validation_date  IN VARCHAR2 DEFAULT 'Y',
   p_validation_date_char   IN VARCHAR2 DEFAULT 'SYSDATE',
   p_inc_user_where_clause  IN VARCHAR2 DEFAULT 'N',
   p_user_where_clause      IN VARCHAR2 DEFAULT NULL,
   p_inc_addtl_where_clause IN VARCHAR2 DEFAULT 'Y',

   x_select OUT NOCOPY  VARCHAR2,
   x_mapping_code OUT NOCOPY VARCHAR2,
   x_success OUT NOCOPY NUMBER)
  IS
     l_success NUMBER;
     l_func_name VARCHAR2(100);
BEGIN
   l_func_name := 'get_table_vset_select() : ';

   message_init;
   get_valueset_select
     (p_validation_type            => 'F',
      p_value_set_name             => p_value_set_name,
      p_value_set_id               => p_value_set_id,
      p_independent_value          => NULL,
      p_inc_id_col                 => p_inc_id_col,
      p_inc_meaning_col            => p_inc_meaning_col,
      p_inc_enabled_col            => p_inc_enabled_col,
      p_inc_start_date_col         => p_inc_start_date_col,
      p_inc_end_date_col           => p_inc_end_date_col,
      p_inc_summary_col            => p_inc_summary_col,
      p_inc_compiled_attribute_col => p_inc_compiled_attribute_col,
      p_inc_hierarchy_level_col    => p_inc_hierarchy_level_col,
      p_inc_addtl_user_columns     => p_inc_addtl_user_columns,
      p_additional_user_columns    => p_additional_user_columns,
      p_inc_addtl_quickpick_cols   => p_inc_addtl_quickpick_cols,
      p_check_enabled_flag         => p_check_enabled_flag,
      p_check_validation_date      => p_check_validation_date,
      p_validation_date_char       => p_validation_date_char,
      p_inc_user_where_clause      => p_inc_user_where_clause,
      p_user_where_clause          => p_user_where_clause,
      p_inc_addtl_where_clause     => p_inc_addtl_where_clause,
      x_select                     => x_select,
      x_mapping_code               => x_mapping_code,
      x_success                    => l_success);
   x_success := l_success;
   IF (l_success = fnd_flex_val_api.g_ret_vtype_mismatch) THEN
      message(l_func_name || 'Value set is not table validated.');
      x_success := g_ret_not_table_validated;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      message(l_func_name || ' is failed.' || chr_newline ||
	      'Error : ' || Sqlerrm);
      x_success := g_ret_others;
END get_table_vset_select;

PROCEDURE get_independent_vset_select
  (p_value_set_name IN fnd_flex_value_sets.flex_value_set_name%TYPE
                       DEFAULT fnd_api.g_miss_char,
   p_value_set_id   IN fnd_flex_value_sets.flex_value_set_id%TYPE
                       DEFAULT fnd_api.g_miss_num,
   --
   -- Do you want to include these columns in SELECT statement?
   -- VALUE column is always included.
   -- ID and MEANING columns are included by default.
   --
   p_inc_id_col                 IN VARCHAR2 DEFAULT 'Y',
   p_inc_meaning_col            IN VARCHAR2 DEFAULT 'Y',
   p_inc_enabled_col            IN VARCHAR2 DEFAULT 'N',
   p_inc_start_date_col         IN VARCHAR2 DEFAULT 'N',
   p_inc_end_date_col           IN VARCHAR2 DEFAULT 'N',
   p_inc_summary_col            IN VARCHAR2 DEFAULT 'N',
   p_inc_compiled_attribute_col IN VARCHAR2 DEFAULT 'N',
   p_inc_hierarchy_level_col    IN VARCHAR2 DEFAULT 'N',
   --
   -- Do you want to add extra checks in SELECT?
   --
   p_check_enabled_flag     IN VARCHAR2 DEFAULT 'Y',
   p_check_validation_date  IN VARCHAR2 DEFAULT 'Y',
   p_validation_date_char   IN VARCHAR2 DEFAULT 'SYSDATE',
   p_inc_user_where_clause  IN VARCHAR2 DEFAULT 'N',
   p_user_where_clause      IN VARCHAR2 DEFAULT NULL,

   x_select OUT NOCOPY VARCHAR2,
   x_mapping_code OUT NOCOPY VARCHAR2,
   x_success OUT NOCOPY NUMBER)
  IS
     l_success NUMBER;
     l_func_name VARCHAR2(100);
BEGIN
   l_func_name := 'get_independent_vset_select() : ';

   message_init;
   get_valueset_select
     (p_validation_type            => 'I',
      p_value_set_name             => p_value_set_name,
      p_value_set_id               => p_value_set_id,
      p_independent_value          => NULL,
      p_inc_id_col                 => p_inc_id_col,
      p_inc_meaning_col            => p_inc_meaning_col,
      p_inc_enabled_col            => p_inc_enabled_col,
      p_inc_start_date_col         => p_inc_start_date_col,
      p_inc_end_date_col           => p_inc_end_date_col,
      p_inc_summary_col            => p_inc_summary_col,
      p_inc_compiled_attribute_col => p_inc_compiled_attribute_col,
      p_inc_hierarchy_level_col    => p_inc_hierarchy_level_col,
      p_inc_addtl_user_columns     => 'N',
      p_additional_user_columns    => NULL,
      p_inc_addtl_quickpick_cols   => 'N',
      p_check_enabled_flag         => p_check_enabled_flag,
      p_check_validation_date      => p_check_validation_date,
      p_validation_date_char       => p_validation_date_char,
      p_inc_user_where_clause      => p_inc_user_where_clause,
      p_user_where_clause          => p_user_where_clause,
      p_inc_addtl_where_clause     => 'N',
      x_select                     => x_select,
      x_mapping_code               => x_mapping_code,
      x_success                    => l_success);
   x_success := l_success;
   IF (l_success = fnd_flex_val_api.g_ret_vtype_mismatch) THEN
      message(l_func_name || 'Value set is not independent.');
      l_success := g_ret_not_indep_validated;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      message(l_func_name || ' is failed.' || chr_newline ||
	      'Error : ' || Sqlerrm);
      x_success := g_ret_others;
END get_independent_vset_select;

PROCEDURE get_dependent_vset_select
  (p_value_set_name IN fnd_flex_value_sets.flex_value_set_name%TYPE
                       DEFAULT fnd_api.g_miss_char,
   p_value_set_id   IN fnd_flex_value_sets.flex_value_set_id%TYPE
                       DEFAULT fnd_api.g_miss_num,
   p_independent_value IN VARCHAR2 DEFAULT NULL,
   --
   -- Do you want to include these columns in SELECT statement?
   -- VALUE column is always included.
   -- ID and MEANING columns are included by default.
   --
   p_inc_id_col                 IN VARCHAR2 DEFAULT 'Y',
   p_inc_meaning_col            IN VARCHAR2 DEFAULT 'Y',
   p_inc_enabled_col            IN VARCHAR2 DEFAULT 'N',
   p_inc_start_date_col         IN VARCHAR2 DEFAULT 'N',
   p_inc_end_date_col           IN VARCHAR2 DEFAULT 'N',
   p_inc_summary_col            IN VARCHAR2 DEFAULT 'N',
   p_inc_compiled_attribute_col IN VARCHAR2 DEFAULT 'N',
   p_inc_hierarchy_level_col    IN VARCHAR2 DEFAULT 'N',
   --
   -- Do you want to add extra checks in SELECT?
   --
   p_check_enabled_flag     IN VARCHAR2 DEFAULT 'Y',
   p_check_validation_date  IN VARCHAR2 DEFAULT 'Y',
   p_validation_date_char   IN VARCHAR2 DEFAULT 'SYSDATE',
   p_inc_user_where_clause  IN VARCHAR2 DEFAULT 'N',
   p_user_where_clause      IN VARCHAR2 DEFAULT NULL,

   x_select OUT NOCOPY VARCHAR2,
   x_mapping_code OUT NOCOPY VARCHAR2,
   x_success OUT NOCOPY NUMBER)
  IS
     l_success NUMBER;
     l_func_name VARCHAR2(100);
BEGIN
   l_func_name := 'get_dependent_vset_select() : ';

   message_init;
   get_valueset_select
     (p_validation_type            => 'D',
      p_value_set_name             => p_value_set_name,
      p_value_set_id               => p_value_set_id,
      p_independent_value          => p_independent_value,
      p_inc_id_col                 => p_inc_id_col,
      p_inc_meaning_col            => p_inc_meaning_col,
      p_inc_enabled_col            => p_inc_enabled_col,
      p_inc_start_date_col         => p_inc_start_date_col,
      p_inc_end_date_col           => p_inc_end_date_col,
      p_inc_summary_col            => p_inc_summary_col,
      p_inc_compiled_attribute_col => p_inc_compiled_attribute_col,
      p_inc_hierarchy_level_col    => p_inc_hierarchy_level_col,
      p_inc_addtl_user_columns     => 'N',
      p_additional_user_columns    => NULL,
      p_inc_addtl_quickpick_cols   => 'N',
      p_check_enabled_flag         => p_check_enabled_flag,
      p_check_validation_date      => p_check_validation_date,
      p_validation_date_char       => p_validation_date_char,
      p_inc_user_where_clause      => p_inc_user_where_clause,
      p_user_where_clause          => p_user_where_clause,
      p_inc_addtl_where_clause     => 'N',
      x_select                     => x_select,
      x_mapping_code               => x_mapping_code,
      x_success                    => l_success);
   x_success := l_success;
   IF (l_success = fnd_flex_val_api.g_ret_vtype_mismatch) THEN
      message(l_func_name || 'Value set is not dependent.');
      x_success := g_ret_not_dep_validated;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      message(l_func_name || ' is failed.' || chr_newline ||
	      'Error : ' || Sqlerrm);
      x_success := g_ret_others;
END get_dependent_vset_select;

FUNCTION is_table_used(p_application_id IN fnd_tables.application_id%TYPE,
		       p_table_name     IN fnd_tables.table_name%TYPE,
		       x_message        OUT NOCOPY VARCHAR2) RETURN BOOLEAN
  IS
     up_table_name fnd_tables.table_name%TYPE;
     l_vset_name fnd_flex_value_sets.flex_value_set_name%TYPE;
BEGIN
   up_table_name := Upper(p_table_name);

   x_message := 'This table is not used by Flexfield Value Sets';
   BEGIN
      SELECT fvs.flex_value_set_name
	INTO l_vset_name
	FROM fnd_flex_value_sets fvs, fnd_flex_validation_tables fvt
	WHERE fvs.validation_type = 'F'
	AND fvs.flex_value_set_id = fvt.flex_value_set_id
	AND Nvl(fvt.table_application_id, p_application_id) = p_application_id
	AND (Upper(fvt.application_table_name) = up_table_name OR
	     Upper(fvt.application_table_name) LIKE '% ' || up_table_name OR
	     Upper(fvt.application_table_name) LIKE up_table_name||' %' OR
	     Upper(fvt.application_table_name) LIKE '% '||up_table_name||' %')
	AND ROWNUM = 1;
      x_message :=
	'This table is used by ' || chr_newline ||
	'VALUE_SET : ' || l_vset_name;
      RETURN(TRUE);
   EXCEPTION
      WHEN no_data_found THEN
	 NULL;
      WHEN OTHERS THEN
	 x_message :=
	   'SELECT FROM FND_FLEX_VALIDATION_TABLES is failed. '||chr_newline||
	   'SQLERRM : ' || Sqlerrm;
	 RETURN(TRUE);
   END;
   RETURN(FALSE);
EXCEPTION
   WHEN OTHERS THEN
      x_message :=
	'FND_FLEX_VAL_API.IS_TABLE_USED is failed. ' || chr_newline ||
	'SQLERRM : ' || Sqlerrm;
      RETURN(TRUE);
END is_table_used;


FUNCTION is_column_used(p_application_id IN fnd_tables.application_id%TYPE,
			p_table_name     IN fnd_tables.table_name%TYPE,
			p_column_name    IN fnd_columns.column_name%TYPE,
			x_message        OUT NOCOPY VARCHAR2) RETURN BOOLEAN
  IS
     up_table_name fnd_tables.table_name%TYPE;
     up_column_name fnd_columns.column_name%TYPE;
     l_vset_name fnd_flex_value_sets.flex_value_set_name%TYPE;
BEGIN
   up_table_name := Upper(p_table_name);
   up_column_name := Upper(p_column_name);

   x_message := 'This column is not used by Flexfield Value Sets';
   BEGIN
      SELECT /* $Header: AFFFVAIB.pls 120.25.12010000.5 2014/08/22 14:09:49 hgeorgi ship $ */
	fvs.flex_value_set_name
	INTO l_vset_name
	FROM fnd_flex_value_sets fvs, fnd_flex_validation_tables fvt
	WHERE fvs.validation_type = 'F'
	AND fvs.flex_value_set_id = fvt.flex_value_set_id
	AND Nvl(fvt.table_application_id, p_application_id) = p_application_id
	AND (Upper(fvt.application_table_name) = up_table_name OR
	     Upper(fvt.application_table_name) LIKE '% ' || up_table_name OR
	     Upper(fvt.application_table_name) LIKE up_table_name||' %' OR
	     Upper(fvt.application_table_name) LIKE '% '||up_table_name||' %')
	AND (Nvl(Upper(fvt.value_column_name), 'X'||up_column_name)
	     = up_column_name OR
	     Nvl(Upper(fvt.compiled_attribute_column_name),'X'||up_column_name)
	     = up_column_name OR
	     Nvl(Upper(fvt.enabled_column_name), 'X'||up_column_name)
	     = up_column_name OR
	     Nvl(Upper(fvt.hierarchy_level_column_name), 'X'||up_column_name)
	     = up_column_name OR
	     Nvl(Upper(fvt.start_date_column_name), 'X'||up_column_name)
	     = up_column_name OR
	     Nvl(Upper(fvt.end_date_column_name), 'X'||up_column_name)
	     = up_column_name OR
	     Nvl(Upper(fvt.summary_column_name), 'X'||up_column_name)
	     = up_column_name OR
	     Nvl(Upper(fvt.id_column_name), 'X'||up_column_name)
	     = up_column_name OR
	     Nvl(Upper(fvt.meaning_column_name), 'X'||up_column_name)
	     = up_column_name )
	AND ROWNUM = 1;
      x_message :=
	'This column is used by ' || chr_newline ||
	'VALUE_SET : ' || l_vset_name;
      RETURN(TRUE);
   EXCEPTION
      WHEN no_data_found THEN
	 NULL;
      WHEN OTHERS THEN
	 x_message :=
	   'SELECT FROM FND_FLEX_VALIDATION_TABLES is failed. '||chr_newline||
	   'SQLERRM : ' || Sqlerrm;
	 RETURN(TRUE);
   END;
   RETURN(FALSE);
EXCEPTION
   WHEN OTHERS THEN
      x_message :=
	'FND_FLEX_VAL_API.IS_COLUMN_USED is failed. ' || chr_newline ||
	'SQLERRM : ' || Sqlerrm;
      RETURN(TRUE);
END is_column_used;

-- ---------------------------------------------------------------------------
PROCEDURE get_vset(p_flex_value_set_name IN VARCHAR2 DEFAULT NULL,
		   p_flex_value_set_id   IN NUMBER DEFAULT NULL,
		   x_vset                OUT nocopy vset_type)
  IS
BEGIN
   IF (p_flex_value_set_name IS NOT NULL) THEN
      BEGIN
	 SELECT *
	   INTO x_vset
	   FROM fnd_flex_value_sets
	   WHERE flex_value_set_name = p_flex_value_set_name;
      EXCEPTION
	 WHEN OTHERS THEN
	    raise_error(ERROR_UNABLE_TO_FIND_VSET_NAME,
			'Unable to find flex value set (name): ' ||
			p_flex_value_set_name);
      END;
    ELSIF (p_flex_value_set_id IS NOT NULL) THEN
      BEGIN
	 SELECT *
	   INTO x_vset
	   FROM fnd_flex_value_sets
	   WHERE flex_value_set_id = p_flex_value_set_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    raise_error(ERROR_UNABLE_TO_FIND_VSET_ID,
			'Unable to find flex value set (id): ' ||
			p_flex_value_set_id);
      END;
    ELSE
      raise_error(ERROR_FLEX_CODE_ERROR,
		  'Flex Code Error: One of the arguments must be not null.');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      raise_error(ERROR_EXCEPTION_OTHERS,
		  'Failure in get_vset().');
END get_vset;

-- ---------------------------------------------------------------------------
PROCEDURE get_ind_vset(p_flex_value_set_name IN VARCHAR2 DEFAULT NULL,
		       p_flex_value_set_id   IN NUMBER DEFAULT NULL,
		       px_vset               IN OUT nocopy vset_type)
  IS
BEGIN
   get_vset(p_flex_value_set_name, p_flex_value_set_id, px_vset);

   -- Make sure it is an independent value set
   IF (px_vset.validation_type <> 'I') THEN
      raise_error(ERROR_VSET_IS_NOT_INDEPENDENT,
		  'Value set (' || px_vset.flex_value_set_name ||
		  ') is not an independent value set.');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      raise_error(ERROR_EXCEPTION_OTHERS,
		  'Failure in get_ind_vset().');
END get_ind_vset;

-- ---------------------------------------------------------------------------
PROCEDURE get_dep_vset(p_flex_value_set_name IN VARCHAR2 DEFAULT NULL,
		       p_flex_value_set_id   IN NUMBER DEFAULT NULL,
		       px_vset               IN OUT nocopy vset_type)
  IS
BEGIN
   get_vset(p_flex_value_set_name, p_flex_value_set_id, px_vset);

   -- Make sure it is a dependent value set
   IF (px_vset.validation_type <> 'D') THEN
      raise_error(ERROR_VSET_IS_NOT_DEPENDENT,
		  'Value set (' || px_vset.flex_value_set_name ||
		  ') is not a dependent value set.');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      raise_error(ERROR_EXCEPTION_OTHERS,
		  'Failure in get_dep_vset().');
END get_dep_vset;

-- ---------------------------------------------------------------------------
PROCEDURE get_hierarchy_id(p_flex_value_set_name IN VARCHAR2,
			   p_hierarchy_code      IN VARCHAR2,
			   x_hierarchy_id        OUT NOCOPY NUMBER)
  IS
     l_vset vset_type;
BEGIN
   get_vset(p_flex_value_set_name, NULL, l_vset);

   BEGIN
      SELECT hierarchy_id
	INTO x_hierarchy_id
	FROM fnd_flex_hierarchies
	WHERE flex_value_set_id = l_vset.flex_value_set_id
	AND hierarchy_code = p_hierarchy_code;
   EXCEPTION
      WHEN OTHERS THEN
	 raise_error(ERROR_UNABLE_TO_FIND_HIER_CODE,
		     'Unable to find hierarchy code: ' ||
		     p_hierarchy_code);
   END;

EXCEPTION
   WHEN OTHERS THEN
      raise_error(ERROR_EXCEPTION_OTHERS,
		  'Failure in get_hierarchy_id().');
END get_hierarchy_id;

-- ---------------------------------------------------------------------------
PROCEDURE check_value_existance(p_vset         IN vset_type,
				p_parent_value IN VARCHAR2,
				p_flex_value   IN VARCHAR2)
  IS
     l_count NUMBER;
BEGIN
   IF (p_vset.validation_type = 'I') THEN
      SELECT COUNT(*)
	INTO l_count
	FROM fnd_flex_values
	WHERE flex_value_set_id = p_vset.flex_value_set_id
	AND flex_value = p_flex_value
	AND ROWNUM = 1;

    ELSIF (p_vset.validation_type = 'D') THEN
      SELECT COUNT(*)
	INTO l_count
	FROM fnd_flex_values
	WHERE flex_value_set_id = p_vset.flex_value_set_id
	AND parent_flex_value_low = p_parent_value
	AND flex_value = p_flex_value
	AND ROWNUM = 1;

    ELSE
      raise_error(ERROR_UNSUP_VALIDATION_TYPE,
		  'Flex Code Error: Unsupported validation type: ' ||
		  p_vset.validation_type);
   END IF;

   IF (l_count > 0) THEN
      raise_error(ERROR_VALUE_ALREADY_EXISTS,
		  'Value (' || p_flex_value || ') already exists.');
   END IF;

   -- No exception handling here.

END check_value_existance;

/*-------------------------------------------------------------------
When a value record exists in fnd_flex_values table, but not in
fnd_flex_values_tl, the record also does not exist in the view,
fnd_flex_values_vl. We read the existing value from fnd_flex_values,
then copy the column contents to the view record for further processing
--------------------------------------------------------------------*/
PROCEDURE copy_to_px_value(v_value        IN noview_value_type,
                           px_value       IN OUT nocopy value_type)
  IS
BEGIN
   px_value.flex_value_set_id := v_value.flex_value_set_id;
   px_value.flex_value_id := v_value.flex_value_id;
   px_value.flex_value := v_value.flex_value;
   px_value.last_update_date := v_value.last_update_date;
   px_value.last_updated_by := v_value.last_updated_by;
   px_value.creation_date := v_value.creation_date;
   px_value.created_by := v_value.created_by;
   px_value.last_update_login := v_value.last_update_login;
   px_value.enabled_flag := v_value.enabled_flag;
   px_value.summary_flag := v_value.summary_flag;
   px_value.start_date_active := v_value.start_date_active;
   px_value.end_date_active := v_value.end_date_active;
   px_value.parent_flex_value_low := v_value.parent_flex_value_low;
   px_value.parent_flex_value_high := v_value.parent_flex_value_high;
   px_value.structured_hierarchy_level := v_value.structured_hierarchy_level;
   px_value.hierarchy_level := v_value.hierarchy_level;
   px_value.compiled_value_attributes := v_value.compiled_value_attributes;
   px_value.value_category := v_value.value_category;
   px_value.attribute1 := v_value.attribute1;
   px_value.attribute2 := v_value.attribute2;
   px_value.attribute3 := v_value.attribute3;
   px_value.attribute4 := v_value.attribute4;
   px_value.attribute5 := v_value.attribute5;
   px_value.attribute6 := v_value.attribute6;
   px_value.attribute7 := v_value.attribute7;
   px_value.attribute8 := v_value.attribute8;
   px_value.attribute9 := v_value.attribute9;
   px_value.attribute10 := v_value.attribute10;
   px_value.attribute11 := v_value.attribute11;
   px_value.attribute12 := v_value.attribute12;
   px_value.attribute13 := v_value.attribute13;
   px_value.attribute14 := v_value.attribute14;
   px_value.attribute15 := v_value.attribute15;
   px_value.attribute16 := v_value.attribute16;
   px_value.attribute17 := v_value.attribute17;
   px_value.attribute18 := v_value.attribute18;
   px_value.attribute19 := v_value.attribute19;
   px_value.attribute20 := v_value.attribute20;
   px_value.attribute21 := v_value.attribute21;
   px_value.attribute22 := v_value.attribute22;
   px_value.attribute23 := v_value.attribute23;
   px_value.attribute24 := v_value.attribute24;
   px_value.attribute25 := v_value.attribute25;
   px_value.attribute26 := v_value.attribute26;
   px_value.attribute27 := v_value.attribute27;
   px_value.attribute28 := v_value.attribute28;
   px_value.attribute29 := v_value.attribute29;
   px_value.attribute30 := v_value.attribute30;
   px_value.attribute31 := v_value.attribute31;
   px_value.attribute32 := v_value.attribute32;
   px_value.attribute33 := v_value.attribute33;
   px_value.attribute34 := v_value.attribute34;
   px_value.attribute35 := v_value.attribute35;
   px_value.attribute36 := v_value.attribute36;
   px_value.attribute37 := v_value.attribute37;
   px_value.attribute38 := v_value.attribute38;
   px_value.attribute39 := v_value.attribute39;
   px_value.attribute40 := v_value.attribute40;
   px_value.attribute41 := v_value.attribute41;
   px_value.attribute42 := v_value.attribute42;
   px_value.attribute43 := v_value.attribute43;
   px_value.attribute44 := v_value.attribute44;
   px_value.attribute45 := v_value.attribute45;
   px_value.attribute46 := v_value.attribute46;
   px_value.attribute47 := v_value.attribute47;
   px_value.attribute48 := v_value.attribute48;
   px_value.attribute49 := v_value.attribute49;
   px_value.attribute50 := v_value.attribute50;
   px_value.flex_value_meaning := v_value.flex_value;
   px_value.description := NULL;
   px_value.attribute_sort_order := v_value.attribute_sort_order;

END copy_to_px_value; /* procedure */


-- ---------------------------------------------------------------------------
PROCEDURE get_value(p_vset         IN vset_type,
		    p_parent_value IN VARCHAR2,
		    p_flex_value   IN VARCHAR2,
		    px_value       IN OUT nocopy value_type)
  IS

v_value       noview_value_type;

BEGIN
   IF (p_vset.validation_type = 'I') THEN
      BEGIN
	 SELECT *
	   INTO px_value
	   FROM fnd_flex_values_vl
	   WHERE flex_value_set_id = p_vset.flex_value_set_id
	   AND flex_value = p_flex_value;
      EXCEPTION
         WHEN no_data_found THEN
            BEGIN
               SELECT *
                 INTO v_value
                 FROM fnd_flex_values
                 WHERE flex_value_set_id = p_vset.flex_value_set_id
                 AND flex_value = p_flex_value;
               copy_to_px_value(v_value, px_value);
               EXCEPTION
                  WHEN OTHERS THEN
                     raise_error(ERROR_UNABLE_TO_FIND_VALUE,
                        'Unable to find value: ' || p_flex_value);
            END;

	 WHEN OTHERS THEN
	    raise_error(ERROR_UNABLE_TO_FIND_VALUE,
			'Unable to find value: ' || p_flex_value);
      END;

    ELSIF (p_vset.validation_type = 'D') THEN
      BEGIN
	 SELECT *
	   INTO px_value
	   FROM fnd_flex_values_vl
	   WHERE flex_value_set_id = p_vset.flex_value_set_id
	   AND parent_flex_value_low = p_parent_value
	   AND flex_value = p_flex_value;
      EXCEPTION
         WHEN no_data_found THEN
            BEGIN
               SELECT *
                 INTO v_value
                 FROM fnd_flex_values
                 WHERE flex_value_set_id = p_vset.flex_value_set_id
                 AND parent_flex_value_low = p_parent_value
                 AND flex_value = p_flex_value;
               copy_to_px_value(v_value, px_value);
               EXCEPTION
                  WHEN OTHERS THEN
                     raise_error(ERROR_UNABLE_TO_FIND_VALUE,
                        'Unable to find value: ' || p_flex_value);
            END;

	 WHEN OTHERS THEN
	    raise_error(ERROR_UNABLE_TO_FIND_VALUE,
			'Unable to find value: ' || p_flex_value);
      END;

    ELSE
      raise_error(ERROR_UNSUP_VALIDATION_TYPE,
		  'Flex Code Error: Unsupported validation type: ' ||
		  p_vset.validation_type);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      raise_error(ERROR_EXCEPTION_OTHERS,
		  'Failure in get_value().');
END get_value;

-- ---------------------------------------------------------------------------
PROCEDURE check_flags_etc(p_vset         IN vset_type,
			  p_value        IN value_type)
  IS
BEGIN
   -- Validate enabled_flag

   IF (Nvl(p_value.enabled_flag, 'X') NOT IN ('Y', 'N')) THEN
      raise_error(ERROR_INVALID_ENABLED_FLAG,
		  'Enabled flag should be Y or N');
   END IF;

   -- Validate start_date_active and end_date_active

   IF ((p_value.start_date_active IS NOT NULL) AND
       (p_value.end_date_active IS NOT NULL) AND
       (p_value.start_date_active > p_value.end_date_active)) THEN
      raise_error(ERROR_INVALID_END_DATE,
		  'End date should be later than the start date.');
   END IF;

   -- Validate summary_flag

   IF (Nvl(p_value.summary_flag, 'X') NOT IN ('Y', 'N')) THEN
      raise_error(ERROR_INVALID_SUMMARY_FLAG,
		  'Summary flag should be Y or N');
   END IF;

   -- Validate structured_hierarchy_level

   IF (p_value.structured_hierarchy_level IS NOT NULL) THEN

      IF (p_value.summary_flag <> 'Y') THEN
	 raise_error(ERROR_INVALID_STR_HIER_LEVEL,
		     'Structured Hierarchy Level can only be specified for Parent Values.');
      END IF;

      DECLARE
	 l_hierarchy_code fnd_flex_hierarchies.hierarchy_code%TYPE;
      BEGIN
	 SELECT hierarchy_code
	   INTO l_hierarchy_code
	   FROM fnd_flex_hierarchies
	   WHERE flex_value_set_id = p_vset.flex_value_set_id
	   AND hierarchy_id = p_value.structured_hierarchy_level;
      EXCEPTION
	 WHEN OTHERS THEN
	    raise_error(ERROR_UNABLE_TO_FIND_STH_LEVEL,
			'Unable to find structured hierarchy level: ' ||
			p_value.structured_hierarchy_level);
      END;
   END IF;

   -- No exception handling here.

END check_flags_etc;

-- ---------------------------------------------------------------------------
PROCEDURE set_who(px_who IN OUT nocopy fnd_flex_loader_apis.who_type)
  IS
BEGIN
   px_who.created_by := fnd_global.user_id();
   px_who.creation_date := Sysdate;
   px_who.last_updated_by := fnd_global.user_id();
   px_who.last_update_date := Sysdate;
   px_who.last_update_login := fnd_global.login_id();
EXCEPTION
   WHEN OTHERS THEN
      raise_error(ERROR_UNABLE_TO_SET_WHO,
		  'Unable to set WHO Information.');
END set_who;

-- ---------------------------------------------------------------------------
PROCEDURE call_load_row(p_vset  IN vset_type,
			p_value IN value_type)
  IS
     l_who fnd_flex_loader_apis.who_type;
BEGIN

   -- Set WHO Info

   set_who(l_who);

   -- Ready to insert/update

   BEGIN
      fnd_flex_values_pkg.load_row
	(x_flex_value_set_name          => p_vset.flex_value_set_name,
	 x_parent_flex_value_low        => p_value.parent_flex_value_low,
	 x_flex_value                   => p_value.flex_value,
	 x_who                          => l_who,
	 x_enabled_flag                 => p_value.enabled_flag,
	 x_summary_flag                 => p_value.summary_flag,
	 x_start_date_active            => p_value.start_date_active,
	 x_end_date_active              => p_value.end_date_active,
	 x_parent_flex_value_high       => p_value.parent_flex_value_high,
	 x_structured_hierarchy_level   => p_value.structured_hierarchy_level,
	 x_hierarchy_level              => p_value.hierarchy_level,
	 x_compiled_value_attributes    => p_value.compiled_value_attributes,
	 x_value_category               => p_value.value_category,
	 x_attribute1                   => p_value.attribute1,
	 x_attribute2                   => p_value.attribute2,
	 x_attribute3                   => p_value.attribute3,
 	 x_attribute4                   => p_value.attribute4,
	 x_attribute5                   => p_value.attribute5,
	 x_attribute6                   => p_value.attribute6,
	 x_attribute7                   => p_value.attribute7,
	 x_attribute8                   => p_value.attribute8,
	 x_attribute9                   => p_value.attribute9,
	 x_attribute10                  => p_value.attribute10,
	 x_attribute11                  => p_value.attribute11,
	 x_attribute12                  => p_value.attribute12,
	 x_attribute13                  => p_value.attribute13,
	 x_attribute14                  => p_value.attribute14,
	 x_attribute15                  => p_value.attribute15,
	 x_attribute16                  => p_value.attribute16,
	 x_attribute17                  => p_value.attribute17,
	 x_attribute18                  => p_value.attribute18,
	 x_attribute19                  => p_value.attribute19,
	 x_attribute20                  => p_value.attribute20,
	 x_attribute21                  => p_value.attribute21,
	 x_attribute22                  => p_value.attribute22,
	 x_attribute23                  => p_value.attribute23,
	 x_attribute24                  => p_value.attribute24,
	 x_attribute25                  => p_value.attribute25,
	 x_attribute26                  => p_value.attribute26,
	 x_attribute27                  => p_value.attribute27,
	 x_attribute28                  => p_value.attribute28,
	 x_attribute29                  => p_value.attribute29,
	 x_attribute30                  => p_value.attribute30,
	 x_attribute31                  => p_value.attribute31,
	 x_attribute32                  => p_value.attribute32,
	 x_attribute33                  => p_value.attribute33,
	 x_attribute34                  => p_value.attribute34,
	 x_attribute35                  => p_value.attribute35,
	 x_attribute36                  => p_value.attribute36,
	 x_attribute37                  => p_value.attribute37,
	 x_attribute38                  => p_value.attribute38,
	 x_attribute39                  => p_value.attribute39,
	 x_attribute40                  => p_value.attribute40,
	 x_attribute41                  => p_value.attribute41,
	 x_attribute42                  => p_value.attribute42,
	 x_attribute43                  => p_value.attribute43,
	 x_attribute44                  => p_value.attribute44,
	 x_attribute45                  => p_value.attribute45,
	 x_attribute46                  => p_value.attribute46,
	 x_attribute47                  => p_value.attribute47,
	 x_attribute48                  => p_value.attribute48,
	 x_attribute49                  => p_value.attribute49,
	 x_attribute50                  => p_value.attribute50,
	 x_attribute_sort_order         => p_value.attribute_sort_order,
	 x_flex_value_meaning           => p_value.flex_value_meaning,
	 x_description                  => p_value.description);

   EXCEPTION
      WHEN OTHERS THEN
	 raise_error(ERROR_UNABLE_TO_LOAD_ROW,
		     'Unable to load row.');
   END;
EXCEPTION
   WHEN OTHERS THEN
      raise_error(ERROR_EXCEPTION_OTHERS,
		  'Failure in call_load_row().');
END call_load_row;

-- ---------------------------------------------------------------------------
PROCEDURE create_independent_vset_value
  (p_flex_value_set_name        IN VARCHAR2,
   p_flex_value                 IN VARCHAR2,
   p_description                IN VARCHAR2 DEFAULT NULL,
   p_enabled_flag               IN VARCHAR2 DEFAULT 'Y',
   p_start_date_active          IN DATE DEFAULT NULL,
   p_end_date_active            IN DATE DEFAULT NULL,
   p_summary_flag               IN VARCHAR2 DEFAULT 'N',
   p_structured_hierarchy_level IN NUMBER DEFAULT NULL,
   p_hierarchy_level            IN VARCHAR2 DEFAULT NULL,
   x_storage_value              OUT NOCOPY VARCHAR2)
  IS
     l_vset          vset_type;
     l_value         value_type;

     l_storage_value VARCHAR2(32000);
     l_display_value VARCHAR2(32000);
     l_success       BOOLEAN;

BEGIN
   -- Get the value set.
   get_ind_vset(p_flex_value_set_name, NULL, l_vset);

   -- Format validate the value
   fnd_flex_val_util.validate_value
     (p_value          => p_flex_value,
      p_is_displayed   => TRUE,
      p_vset_name      => l_vset.flex_value_set_name,
      p_vset_format    => l_vset.format_type,
      p_max_length     => l_vset.maximum_size,
      p_precision      => l_vset.number_precision,
      p_alpha_allowed  => l_vset.alphanumeric_allowed_flag,
      p_uppercase_only => l_vset.uppercase_only_flag,
      p_zero_fill      => l_vset.numeric_mode_enabled_flag,
      p_min_value      => l_vset.minimum_value,
      p_max_value      => l_vset.maximum_value,
      x_storage_value  => l_storage_value,
      x_display_value  => l_display_value,
      x_success        => l_success);

   IF (NOT l_success) THEN
      raise_error(ERROR_VALUE_VALIDATION_FAILED,
		  'Value validation failed with the error message: ' ||
		  fnd_message.get());
   END IF;

   -- Populate the l_value, by default everything is NULL.

   l_value.parent_flex_value_low        := NULL;
   l_value.flex_value                   := l_storage_value;
   l_value.enabled_flag                 := p_enabled_flag;
   l_value.summary_flag                 := p_summary_flag;
   l_value.start_date_active            := p_start_date_active;
   l_value.end_date_active              := p_end_date_active;
   l_value.parent_flex_value_high       := NULL;
   l_value.structured_hierarchy_level   := p_structured_hierarchy_level;
   l_value.hierarchy_level              := p_hierarchy_level;
   l_value.compiled_value_attributes    := NULL;
   l_value.flex_value_meaning           := l_storage_value;
   l_value.description                  := p_description;

   -- Check the flags etc.

   check_flags_etc(l_vset, l_value);

   -- Check if this value already exists

   check_value_existance(l_vset, NULL, l_storage_value);

   -- Ready to insert

   call_load_row(l_vset, l_value);

   -- Value is created successfully, return the storage value

   x_storage_value := l_storage_value;

EXCEPTION
   WHEN OTHERS THEN
      raise_error(ERROR_EXCEPTION_OTHERS,
		  'Failure in create_independent_vset_value().');
END create_independent_vset_value;

-- ---------------------------------------------------------------------------
PROCEDURE create_dependent_vset_value
  (p_flex_value_set_name        IN VARCHAR2,
   p_parent_flex_value          IN VARCHAR2,
   p_flex_value                 IN VARCHAR2,
   p_description                IN VARCHAR2 DEFAULT NULL,
   p_enabled_flag               IN VARCHAR2 DEFAULT 'Y',
   p_start_date_active          IN DATE DEFAULT NULL,
   p_end_date_active            IN DATE DEFAULT NULL,
   p_hierarchy_level            IN VARCHAR2 DEFAULT NULL,
   x_storage_value              OUT NOCOPY VARCHAR2)
  IS
     l_vset          vset_type;
     l_value         value_type;

     l_parent_vset   vset_type;
     l_parent_value  value_type;

     l_storage_value VARCHAR2(32000);
     l_display_value VARCHAR2(32000);
     l_success       BOOLEAN;

BEGIN
   -- Get the value set.
   get_dep_vset(p_flex_value_set_name, NULL, l_vset);

   -- Get the parent value set
   BEGIN
      get_ind_vset(NULL, l_vset.parent_flex_value_set_id, l_parent_vset);
   EXCEPTION
      WHEN OTHERS THEN
	 raise_error(ERROR_UNABLE_TO_GET_PARENT_VST,
		     'Unable to get parent value set of flex value set: ' ||
		     p_flex_value_set_name);
   END;

   -- Get the parent value
   BEGIN
      get_value(l_parent_vset, NULL, p_parent_flex_value, l_parent_value);
   EXCEPTION
      WHEN OTHERS THEN
	 raise_error(ERROR_UNABLE_TO_GET_PARENT_VAL,
		     'Unable to get parent value: ' ||
		     p_parent_flex_value);
   END;

   -- Format validate the value
   fnd_flex_val_util.validate_value
     (p_value          => p_flex_value,
      p_is_displayed   => TRUE,
      p_vset_name      => l_vset.flex_value_set_name,
      p_vset_format    => l_vset.format_type,
      p_max_length     => l_vset.maximum_size,
      p_precision      => l_vset.number_precision,
      p_alpha_allowed  => l_vset.alphanumeric_allowed_flag,
      p_uppercase_only => l_vset.uppercase_only_flag,
      p_zero_fill      => l_vset.numeric_mode_enabled_flag,
      p_min_value      => l_vset.minimum_value,
      p_max_value      => l_vset.maximum_value,
      x_storage_value  => l_storage_value,
      x_display_value  => l_display_value,
      x_success        => l_success);

   IF (NOT l_success) THEN
      raise_error(ERROR_VALUE_VALIDATION_FAILED,
		  'Value validation failed with the error message: ' ||
		  fnd_message.get());
   END IF;

   -- Populate the l_value, by default everything is NULL.

   l_value.parent_flex_value_low        := l_parent_value.flex_value;
   l_value.flex_value                   := l_storage_value;
   l_value.enabled_flag                 := p_enabled_flag;
   l_value.summary_flag                 := 'N';
   l_value.start_date_active            := p_start_date_active;
   l_value.end_date_active              := p_end_date_active;
   l_value.parent_flex_value_high       := NULL;
   l_value.structured_hierarchy_level   := NULL;
   l_value.hierarchy_level              := p_hierarchy_level;
   l_value.compiled_value_attributes    := NULL;
   l_value.flex_value_meaning           := l_storage_value;
   l_value.description                  := p_description;

   -- Check flags etc.

   check_flags_etc(l_vset, l_value);

   -- Check if this value already exists

   check_value_existance(l_vset, l_parent_value.flex_value, l_storage_value);

   -- Ready to insert

   call_load_row(l_vset, l_value);

   -- Value is created successfully, return the storage value

   x_storage_value := l_storage_value;

EXCEPTION
   WHEN OTHERS THEN
      raise_error(ERROR_EXCEPTION_OTHERS,
		  'Failure in create_dependent_vset_value().');
END create_dependent_vset_value;

-- ---------------------------------------------------------------------------
PROCEDURE update_field(px_field IN OUT nocopy VARCHAR2,
		       p_value  IN VARCHAR2)
  IS
BEGIN
   IF (p_value IS NOT NULL) THEN
      IF (p_value = g_null_varchar2) THEN
	 px_field := NULL;
       ELSE
	 px_field := p_value;
      END IF;
   END IF;
END update_field;

-- ---------------------------------------------------------------------------
PROCEDURE update_field(px_field IN OUT nocopy NUMBER,
		       p_value  IN NUMBER)
  IS
BEGIN
   IF (p_value IS NOT NULL) THEN
      IF (p_value = g_null_number) THEN
	 px_field := NULL;
       ELSE
	 px_field := p_value;
      END IF;
   END IF;
END update_field;

-- ---------------------------------------------------------------------------
PROCEDURE update_field(px_field IN OUT nocopy DATE,
		       p_value  IN DATE)
  IS
BEGIN
   IF (p_value IS NOT NULL) THEN
      IF (p_value = g_null_date) THEN
	 px_field := NULL;
       ELSE
	 px_field := p_value;
      END IF;
   END IF;
END update_field;

-- ---------------------------------------------------------------------------
PROCEDURE update_independent_vset_value
  (p_flex_value_set_name        IN VARCHAR2,
   p_flex_value                 IN VARCHAR2,
   p_description                IN VARCHAR2 DEFAULT NULL,
   p_enabled_flag               IN VARCHAR2 DEFAULT NULL,
   p_start_date_active          IN DATE DEFAULT NULL,
   p_end_date_active            IN DATE DEFAULT NULL,
   p_summary_flag               IN VARCHAR2 DEFAULT NULL,
   p_structured_hierarchy_level IN NUMBER DEFAULT NULL,
   p_hierarchy_level            IN VARCHAR2 DEFAULT NULL,
   x_storage_value              OUT NOCOPY VARCHAR2)
  IS
     l_vset          vset_type;
     l_value         value_type;

     l_storage_value VARCHAR2(32000);
     l_display_value VARCHAR2(32000);
     l_success       BOOLEAN;

     l_tmp           VARCHAR2(32000);

BEGIN
   -- Get the value set.

   get_ind_vset(p_flex_value_set_name, NULL, l_vset);

   -- Get the value

   get_value(l_vset, NULL, p_flex_value, l_value);

   -- Format validate the value

   fnd_flex_val_util.validate_value
     (p_value          => l_value.flex_value,
      p_is_displayed   => FALSE,
      p_vset_name      => l_vset.flex_value_set_name,
      p_vset_format    => l_vset.format_type,
      p_max_length     => l_vset.maximum_size,
      p_precision      => l_vset.number_precision,
      p_alpha_allowed  => l_vset.alphanumeric_allowed_flag,
      p_uppercase_only => l_vset.uppercase_only_flag,
      p_zero_fill      => l_vset.numeric_mode_enabled_flag,
      p_min_value      => l_vset.minimum_value,
      p_max_value      => l_vset.maximum_value,
      x_storage_value  => l_storage_value,
      x_display_value  => l_display_value,
      x_success        => l_success);

   IF (NOT l_success) THEN
      raise_error(ERROR_VALUE_VALIDATION_FAILED,
		  'Value validation failed with the error message: ' ||
		  fnd_message.get());
   END IF;

   -- Update fields

   update_field(l_value.description,                p_description);
   update_field(l_value.enabled_flag,               p_enabled_flag);
   update_field(l_value.start_date_active,          p_start_date_active);
   update_field(l_value.end_date_active,            p_end_date_active);
   update_field(l_value.summary_flag,               p_summary_flag);
   update_field(l_value.structured_hierarchy_level, p_structured_hierarchy_level);
   update_field(l_value.hierarchy_level,            p_hierarchy_level);

   IF (l_value.summary_flag = 'N') THEN
      l_value.structured_hierarchy_level := NULL;

      DELETE FROM fnd_flex_value_norm_hierarchy
	WHERE flex_value_set_id = l_vset.flex_value_set_id
	AND parent_flex_value = l_value.flex_value;
   END IF;

   -- Check the flags etc.

   check_flags_etc(l_vset, l_value);

   -- Ready to update

   call_load_row(l_vset, l_value);

   -- Value is updated successfully, return the storage value

   x_storage_value := l_storage_value;

EXCEPTION
   WHEN OTHERS THEN
      raise_error(ERROR_EXCEPTION_OTHERS,
		  'Failure in update_independent_vset_value().');
END update_independent_vset_value;

-- ---------------------------------------------------------------------------
PROCEDURE update_dependent_vset_value
  (p_flex_value_set_name        IN VARCHAR2,
   p_parent_flex_value          IN VARCHAR2,
   p_flex_value                 IN VARCHAR2,
   p_description                IN VARCHAR2 DEFAULT NULL,
   p_enabled_flag               IN VARCHAR2 DEFAULT NULL,
   p_start_date_active          IN DATE DEFAULT NULL,
   p_end_date_active            IN DATE DEFAULT NULL,
   p_hierarchy_level            IN VARCHAR2 DEFAULT NULL,
   x_storage_value              OUT NOCOPY VARCHAR2)
  IS
     l_vset          vset_type;
     l_value         value_type;

     l_parent_vset   vset_type;
     l_parent_value  value_type;

     l_storage_value VARCHAR2(32000);
     l_display_value VARCHAR2(32000);
     l_success       BOOLEAN;

BEGIN
   -- Get the value set.
   get_dep_vset(p_flex_value_set_name, NULL, l_vset);

   -- Get the parent value set
   BEGIN
      get_ind_vset(NULL, l_vset.parent_flex_value_set_id, l_parent_vset);
   EXCEPTION
      WHEN OTHERS THEN
	 raise_error(ERROR_UNABLE_TO_GET_PARENT_VST,
		     'Unable to get parent value set of flex value set: ' ||
		     p_flex_value_set_name);
   END;

   -- Get the parent value
   BEGIN
      get_value(l_parent_vset, NULL, p_parent_flex_value, l_parent_value);
   EXCEPTION
      WHEN OTHERS THEN
	 raise_error(ERROR_UNABLE_TO_GET_PARENT_VAL,
		     'Unable to get parent value: ' ||
		     p_parent_flex_value);
   END;

   -- Get the value
   get_value(l_vset, l_parent_value.flex_value, p_flex_value, l_value);

   -- Format validate the value

   fnd_flex_val_util.validate_value
     (p_value          => l_value.flex_value,
      p_is_displayed   => FALSE,
      p_vset_name      => l_vset.flex_value_set_name,
      p_vset_format    => l_vset.format_type,
      p_max_length     => l_vset.maximum_size,
      p_precision      => l_vset.number_precision,
      p_alpha_allowed  => l_vset.alphanumeric_allowed_flag,
      p_uppercase_only => l_vset.uppercase_only_flag,
      p_zero_fill      => l_vset.numeric_mode_enabled_flag,
      p_min_value      => l_vset.minimum_value,
      p_max_value      => l_vset.maximum_value,
      x_storage_value  => l_storage_value,
      x_display_value  => l_display_value,
      x_success        => l_success);

   IF (NOT l_success) THEN
      raise_error(ERROR_VALUE_VALIDATION_FAILED,
		  'Value validation failed with the error message: ' ||
		  fnd_message.get());
   END IF;

   -- Update fields

   update_field(l_value.description,                p_description);
   update_field(l_value.enabled_flag,               p_enabled_flag);
   update_field(l_value.start_date_active,          p_start_date_active);
   update_field(l_value.end_date_active,            p_end_date_active);
   update_field(l_value.hierarchy_level,            p_hierarchy_level);

   -- Check flags etc.

   check_flags_etc(l_vset, l_value);

   -- Ready to update

   call_load_row(l_vset, l_value);

   -- Value is updated successfully, return the storage value

   x_storage_value := l_storage_value;

EXCEPTION
   WHEN OTHERS THEN
      raise_error(ERROR_EXCEPTION_OTHERS,
		  'Failure in update_dependent_vset_value().');
END update_dependent_vset_value;

-- ---------------------------------------------------------------------------
PROCEDURE create_value_hierarchy
  (p_flex_value_set_name        IN VARCHAR2,
   p_parent_flex_value          IN VARCHAR2,
   p_range_attribute            IN VARCHAR2,
   p_child_flex_value_low       IN VARCHAR2,
   p_child_flex_value_high      IN VARCHAR2)
  IS
     l_vset  vset_type;
     l_value value_type;

     l_storage_value_low VARCHAR2(32000);
     l_storage_value_high VARCHAR2(32000);

     l_display_value VARCHAR2(32000);
     l_success       BOOLEAN;

     l_who fnd_flex_loader_apis.who_type;
BEGIN
   -- Get the value set.
   get_ind_vset(p_flex_value_set_name, NULL, l_vset);

   -- Get the value
   get_value(l_vset, NULL, p_parent_flex_value, l_value);

   -- Make sure it is a Parent Value
   IF (l_value.summary_flag <> 'Y') THEN
      raise_error(ERROR_NOT_A_PARENT_VALUE,
		  'Summary Flag of the value is not Y.');
   END IF;

   -- Validate the range attribute
   IF (Nvl(p_range_attribute, 'X') NOT IN ('C', 'P')) THEN
      raise_error(ERROR_INVALID_RANGE_ATTRIBUTE,
		  'Range Attribute should be C or P');
   END IF;

   -- Validate the child value low

   fnd_flex_val_util.validate_value
     (p_value          => p_child_flex_value_low,
      p_is_displayed   => TRUE,
      p_vset_name      => l_vset.flex_value_set_name,
      p_vset_format    => l_vset.format_type,
      p_max_length     => l_vset.maximum_size,
      p_precision      => l_vset.number_precision,
      p_alpha_allowed  => l_vset.alphanumeric_allowed_flag,
      p_uppercase_only => l_vset.uppercase_only_flag,
      p_zero_fill      => l_vset.numeric_mode_enabled_flag,
      p_min_value      => l_vset.minimum_value,
      p_max_value      => l_vset.maximum_value,
      x_storage_value  => l_storage_value_low,
      x_display_value  => l_display_value,
      x_success        => l_success);

   IF (NOT l_success) THEN
      raise_error(ERROR_VALUE_VALIDATION_FAILED,
		  'Low Value validation failed with the error message: ' ||
		  fnd_message.get());
   END IF;


   -- Validate the child value high

   fnd_flex_val_util.validate_value
     (p_value          => p_child_flex_value_high,
      p_is_displayed   => TRUE,
      p_vset_name      => l_vset.flex_value_set_name,
      p_vset_format    => l_vset.format_type,
      p_max_length     => l_vset.maximum_size,
      p_precision      => l_vset.number_precision,
      p_alpha_allowed  => l_vset.alphanumeric_allowed_flag,
      p_uppercase_only => l_vset.uppercase_only_flag,
      p_zero_fill      => l_vset.numeric_mode_enabled_flag,
      p_min_value      => l_vset.minimum_value,
      p_max_value      => l_vset.maximum_value,
      x_storage_value  => l_storage_value_high,
      x_display_value  => l_display_value,
      x_success        => l_success);

   IF (NOT l_success) THEN
      raise_error(ERROR_VALUE_VALIDATION_FAILED,
		  'High Value validation failed with the error message: ' ||
		  fnd_message.get());
   END IF;

   -- Make sure the order in Low and High Values
   IF (l_storage_value_low > l_storage_value_high) THEN
      raise_error(ERROR_INVALID_HIGH_VALUE,
		  'High value cannot be lower than Low value.');
   END IF;

   -- Check if this hierarchy already exists

   DECLARE
      l_count NUMBER;
   BEGIN
      SELECT COUNT(*)
	INTO l_count
	FROM fnd_flex_value_norm_hierarchy
	WHERE flex_value_set_id = l_vset.flex_value_set_id
	AND parent_flex_value = l_value.flex_value
	AND range_attribute = p_range_attribute
	AND child_flex_value_low = l_storage_value_low
	AND child_flex_value_high = l_storage_value_high
	AND ROWNUM = 1;

      IF (l_count > 0) THEN
	 raise_error(ERROR_HIERARCHY_ALREADY_EXISTS,
		     'Hierarchy (' || l_value.flex_value ||
		     ' (' || p_range_attribute ||
		     ') : ' || l_storage_value_low ||
		     ' - ' || l_storage_value_high || ') already exists.');
      END IF;
   END;

   -- Set WHO Info

   set_who(l_who);

   -- Ready to insert

   BEGIN
      INSERT INTO fnd_flex_value_norm_hierarchy
        (
         flex_value_set_id,
         parent_flex_value,
         range_attribute,
         child_flex_value_low,
         child_flex_value_high,

         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,

         start_date_active,
         end_date_active
         )
        VALUES
        (
         l_vset.flex_value_set_id,
         l_value.flex_value,
         p_range_attribute,
         l_storage_value_low,
         l_storage_value_high,

         l_who.created_by,
         l_who.creation_date,
         l_who.last_updated_by,
         l_who.last_update_date,
         l_who.last_update_login,

         NULL,
         NULL
         );

   EXCEPTION
      WHEN OTHERS THEN
	 raise_error(ERROR_UNABLE_TO_INSERT_ROW,
		     'Unable to insert row.');
   END;

   -- Hierarchy is created successfully

END create_value_hierarchy;

-- ---------------------------------------------------------------------------
PROCEDURE submit_vset_hierarchy_compiler
  (p_flex_value_set_name        IN VARCHAR2,
   x_request_id                 OUT NOCOPY NUMBER)
  IS
     l_vset       vset_type;
     l_request_id NUMBER;
BEGIN
   -- Get the value set.
   get_ind_vset(p_flex_value_set_name, NULL, l_vset);

   BEGIN
      l_request_id  := fnd_request.submit_request
        (application => 'FND',
         program     => 'FDFCHY',
         description => 'VAI.submit_vset_hierarchy_compiler',
         start_time  => NULL,
         sub_request => FALSE,
         argument1   => l_vset.flex_value_set_id);

   EXCEPTION
      WHEN OTHERS THEN
	 raise_error(ERROR_UNABLE_TO_SUBMIT_FDFCHY,
		     'Unable to submit FDFCHY request for flex value set: ' ||
		     p_flex_value_set_name || '. Error: ' ||
		     fnd_message.get());
   END;

   IF (l_request_id = 0) THEN
      raise_error(ERROR_UNABLE_TO_SUBMIT_FDFCHY,
		  'Unable to submit FDFCHY request for flex value set: ' ||
		  p_flex_value_set_name || '. Error: ' ||
		  fnd_message.get());
   END IF;

   x_request_id := l_request_id;

END submit_vset_hierarchy_compiler;


-- Purpose
--   Validate a valuset for a given segment, based on
--   critera commented below, and give a error message if the
--   valueset is not valid for that segment. This gives
--   the user a chance to see why he cannot attach a vset to a
--   certain segment. We use the same procedure to validate all
--   FF which include KFF, DFF, and SRS.
--
-- Arguments
--   All the arguments for the procedure is_valueset_allowed()
--   are not needed. Which arguments are needed will depend
--   on which FF is being valiated.  If an argument is
--   not needed, then just set it to null in the calling function.
--
--   flex_field                For all FF
--   value_set_id              For all FF
--   allow_id_valuesets        For all FF
--   segment_name              For all FF
--   id_flex_num               For KFF only
--   segment_num               For KFF only
--   desc_flex_context_code    For DFF and SRS
--   column_seq_num            For DFF and SRS
--   application_column_type   For KFF and DFF
--   application_column_size   For KFF and DFF

PROCEDURE is_valueset_allowed(p_flex_field in VARCHAR2,
                              p_value_set_id in NUMBER,
                              p_allow_id_valuesets in VARCHAR2,
                              p_segment_name in VARCHAR2,
                              p_id_flex_num in NUMBER,
                              p_segment_num in NUMBER,
                              p_desc_flex_context_code in VARCHAR2,
                              p_column_seq_num in NUMBER,
                              p_application_column_type in VARCHAR2,
                              p_application_column_size in NUMBER)
  IS

    l_validation_type         VARCHAR2(1);
    l_format_type             VARCHAR2(1);
    l_maximum_size            NUMBER(3);
    l_id_column_name          VARCHAR2(240);
    l_id_column_type          VARCHAR2(1);
    l_id_column_size          NUMBER(3);
    l_appl_col_size           NUMBER(15);
    l_segment_num             NUMBER(3);
    l_column_seq_num          NUMBER(3);
    l_column_type             VARCHAR2(1);
    l_number_precision        NUMBER(2);
    l_application_column_type VARCHAR2(1);
    l_application_column_size NUMBER(15);

    l_flex_value_set_name     VARCHAR2(60);
    l_format_type_name        VARCHAR2(80);
    l_appl_column_type_name   VARCHAR2(80);
    l_parent_value_set_name   VARCHAR2(60);
    l_parent_value_set_id     NUMBER(10);


  BEGIN
   BEGIN

    -- If no vset id is passed in, assume no valueset to valdate.
    IF (p_value_set_id IS NULL)
    THEN
     RETURN;
    END IF;

    -- Initialize all local variables needed for validation.

    l_application_column_type := p_application_column_type;
    l_application_column_size := p_application_column_size;

    SELECT
     v.validation_type, v.format_type, v.maximum_size,
     v.number_precision, v.flex_value_set_name,
     t.id_column_name, t.id_column_type, t.id_column_size
    INTO
     l_validation_type, l_format_type, l_maximum_size,
     l_number_precision, l_flex_value_set_name,
     l_id_column_name, l_id_column_type, l_id_column_size
    FROM
     fnd_flex_value_sets v,
     fnd_flex_validation_tables t
    WHERE
     v.flex_value_set_id = p_value_set_id and
     v.flex_value_set_id = t.flex_value_set_id(+);


    IF(p_flex_field = 'SRS') THEN

      SELECT
       c.column_type, c.width
      INTO
       l_column_type, l_appl_col_size
      FROM
       fnd_flex_value_sets v,
       fnd_flex_validation_tables t,
       fnd_columns c, fnd_tables tb
      WHERE
       v.flex_value_set_id = p_value_set_id and
       v.flex_value_set_id = t.flex_value_set_id(+) and
       tb.application_id = 0 and
       tb.table_name = 'FND_SRS_MASTER' and
       tb.application_id = c.application_id and
       tb.table_id = c.table_id and c.column_name = 'ATTRIBUTE1';

      -- The SRS form does not need to save the Parameter values entered
      -- in the FF. Because of this, there is no base table to validate
      -- against. Instead of validating against a base table we use
      -- column attributes from fnd_column and fnd_tables.
      -- We assign the values returned to what normally we would
      -- get from the base table. Now normal validation can continue
      -- since we have values for p_application_column_type and
      -- p_application_column_size. They are passed in as null from
      -- the SRS form.

      l_application_column_type := l_column_type;
      l_application_column_size := l_appl_col_size;

    END IF;


   -- Please note the order in which the rules are checked is based
   -- which ones are more serious. A value set may have more than
   -- one rule that it violates. The one we display first is the most
   -- serious. For example, if a vset format type is obsolete, I don't
   -- want to first get an error message saying that my format type does
   -- not match the database column data type. The first thing I want to
   -- know is the the vset is obsolete.





    /*
    For KFF and DFF and SRS
    This rule is to make sure Date and DateTime value sets
    format types are not used since they are now obsolete and
    are replaced by Standard Date(X) and Standard DateTime(Y) format types.
    */
    IF(l_format_type='D' or l_format_type='T')
    THEN
        fnd_message.set_name('FND','FLEX-VSET TYPE OBSOLETE');
        fnd_message.set_token('VSET_NAME',l_flex_value_set_name);
        fnd_message.set_token('SEG_NAME',p_segment_name);
        app_exception.raise_exception;
    END IF;


    IF(p_flex_field = 'KFF') THEN
    /*
    For KFF Only
    Table Validate value sets with hidden ID columns may
    not be used with KFF's defiend with 'ID VS not allowed'.
    Check to see if the FF is allowed to have an ID VS.
    If so, then the VS can be used. If the FF
    is not allowed to have an ID VS, then we need to
    check if the value set is defined as an ID VS.
    if the id_column_name is null, then it is not an
    ID VS and it can be displayed.
    */
      IF(NOT(p_allow_id_valuesets = 'Y' OR
          (p_allow_id_valuesets = 'N' AND l_id_column_name is NULL)))
      THEN
          fnd_message.set_name('FND','FLEX-VSET IDVSET RESTRICTED');
          fnd_message.set_token('VSET_NAME',l_flex_value_set_name);
          fnd_message.set_token('SEG_NAME',p_segment_name);
          app_exception.raise_exception;
      END IF;


      /*
      For KFF Only
      Table Validate value sets with hidden ID columns may
      not be used with KFF's defiend with 'ID VS not allowed'.
      Check to see if the FF is allowed to have an ID VS.
      If so, then the VS can be displayed. If the FF
      is not allowed to have an ID VS, then we need to
      check if the Value Set is defined as an ID VS.
      If the VS has a Validation Type of Translatable
      Independent/Dependent, then it cannot be used
      because those validation types are internally
      ID value sets.
      */
      IF(NOT(p_allow_id_valuesets = 'Y' OR
          (p_allow_id_valuesets = 'N' AND
           l_validation_type <> 'X' AND l_validation_type <> 'Y')))
      THEN
         fnd_message.set_name('FND','FLEX-VSET IDVSET TR RESTRICTED');
         fnd_message.set_token('VSET_NAME',l_flex_value_set_name);
         fnd_message.set_token('SEG_NAME',p_segment_name);
         app_exception.raise_exception;
      END IF;


      /*
      'Date', 'DateTime', 'Time' and 'Number with Precision'
      vsets are a type of ID vsets.
      Some KFF's do not allow ID vsets. If ID vsets are not
      allowed then we must make sure these vsets are not used.
      */
      IF(NOT(p_allow_id_valuesets = 'Y' OR
            ( p_allow_id_valuesets = 'N' AND
            (l_format_type <> 'X' AND
             l_format_type <> 'Y' AND
             l_format_type <> 'I' AND
             l_format_type <> 'N') OR
            ((l_format_type = 'N' AND
             l_number_precision IS NOT NULL AND
             l_number_precision = 0)))))
      THEN
         fnd_message.set_name('FND','FLEX-VSET IDVSET DN RESTRICTED');
         fnd_message.set_token('VSET_NAME',l_flex_value_set_name);
         fnd_message.set_token('SEG_NAME',p_segment_name);
         app_exception.raise_exception;
      END IF;
    END IF; /* KFF Check */


    /*
    For KFF and DFF and SRS
    This rule is to make sure that the base table underlying column
    can store values from a VS based on its format type or id_column_type.
    If the underlying column type is a C=Char or V=Varchar2 then that
    column can store any VS value format. If the VS Validation Type
    is U=Special then it does not store any values in the base table
    so that can be used. If the underlying column is anything other
    than C=Char or V=Varchar2 then we need to make sure the VS will be
    compatible with the underlying column. First we check the VS
    Table ID Type. If it is not null then we can use that Type to compare
    to the underlying column and they must match. If the VS Table ID
    Type is null, then we use the VS Format Type to compare to the
    underlying column. If the underlying column is of type
    Date(D), then only VS Format Types T=DateTime, I=Time, X=StandardDate,
    Y=StandardDateTime, Z=StandardTime can be used.
    */
    IF(NOT((l_application_column_type = 'C' OR l_application_column_type = 'V')
           OR l_validation_type = 'U' OR
           ((l_application_column_type = l_id_column_type and
             l_id_column_type is not null) or
            (l_format_type in ('T','I','X','Y','Z') and
             l_application_column_type = 'D' and
             l_id_column_type is null) or
            (l_format_type not in ('T','I','X','Y','Z') and
             l_application_column_type = l_format_type and
             l_id_column_type is null))))
    THEN
        -- Get description of codes for the error message --

        select meaning
        into l_appl_column_type_name
        from fnd_lookups
        where lookup_code=l_application_column_type and
        lookup_type='COLUMN_TYPE';

        IF( l_id_column_type is NULL )
        THEN
          select meaning
          into l_format_type_name
          from fnd_lookups
          where lookup_code=l_format_type and lookup_type='FIELD_TYPE';
          fnd_message.set_name('FND','FLEX-VSET FORMAT TYPE CONFLICT');
        ELSE
          select meaning
          into l_format_type_name
          from fnd_lookups
          where lookup_code=l_id_column_type and lookup_type='COLUMN_TYPE';
          fnd_message.set_name('FND','FLEX-VSET ID COL TYPE CONFLICT');
        END IF;

        fnd_message.set_token('VSET_NAME',l_flex_value_set_name);
        fnd_message.set_token('SEG_NAME',p_segment_name);
        fnd_message.set_token('FORMAT_TYPE',l_format_type_name);
        fnd_message.set_token('DATA_TYPE',l_appl_column_type_name);
        app_exception.raise_exception;

    END IF;


    /*
    For KFF and DFF and SRS
    This rule is to make sure that the max value set size
    or the ID column size is not bigger than the underlying column.
    If the underlying table column is a date type then no need to
    check column size since a date column can store any date type.
    */
    IF(NOT( (l_application_column_type = 'D')
         OR (l_application_column_size >= l_maximum_size
             AND l_id_column_size IS NULL)
         OR (l_application_column_size >= l_id_column_size
             AND l_id_column_size IS NOT NULL)))
    THEN

        IF( l_id_column_type is NULL )
        THEN
           fnd_message.set_name('FND','FLEX-VSET MAX SIZE');
           fnd_message.set_token('VSET_MAXSIZE',l_maximum_size);
        ELSE
           fnd_message.set_name('FND','FLEX-VSET ID COL SIZE');
           fnd_message.set_token('ID_COL_SIZE',l_id_column_size);
        END IF;

        fnd_message.set_token('VSET_NAME',l_flex_value_set_name);
        fnd_message.set_token('SEG_NAME',p_segment_name);
        fnd_message.set_token('COL_SIZE',l_application_column_size);
        app_exception.raise_exception;
    END IF;


    IF(p_flex_field = 'KFF') THEN
      /*
      For KFF Only
      This rule is to make sure that a Dependent VS has it's
      Indpendent VS to reference in the previous segment
      If it is not a Dependent VS then no need to check child
      parent relationship.  If it is a Dependent value set then
      make sure it has it's parent.
      */
      IF(l_validation_type ='D' or l_validation_type ='Y') THEN
        BEGIN
          SELECT
           s.segment_num, v.parent_flex_value_set_id
          INTO
           l_segment_num, l_parent_value_set_id
          FROM
           fnd_flex_value_sets v, fnd_id_flex_segments s
          WHERE
           v.flex_value_set_id = p_value_set_id
           AND s.id_flex_num = p_id_flex_num
           AND v.parent_flex_value_set_id = s.flex_value_set_id;

          IF(NOT(l_segment_num < p_segment_num)) THEN

             select flex_value_set_name
             into l_parent_value_set_name
             from fnd_flex_value_sets
             where
             flex_value_set_id=l_parent_value_set_id;

             fnd_message.set_name('FND','FLEX-VSET IND DEP VSET ORDER');
             fnd_message.set_token('VSET_NAME',l_flex_value_set_name);
             fnd_message.set_token('SEG_NAME',p_segment_name);
             fnd_message.set_token('PARENT_VSET_NAME',l_parent_value_set_name);
             app_exception.raise_exception;
          END IF;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN

              select flex_value_set_name
              into l_parent_value_set_name
              from fnd_flex_value_sets
              where
              flex_value_set_id in (select parent_flex_value_set_id
                                    from fnd_flex_value_sets
                                    where flex_value_set_id=p_value_set_id);

              fnd_message.set_name('FND','FLEX-VSET PARENT VSET MISSING');
              fnd_message.set_token('VSET_NAME',l_flex_value_set_name);
              fnd_message.set_token('SEG_NAME',p_segment_name);
              fnd_message.set_token('PARENT_VSET_NAME',l_parent_value_set_name);
              app_exception.raise_exception;
            WHEN OTHERS THEN RAISE;
        END;
      END IF;
   END IF; /* KFF Check */


    IF(p_flex_field = 'DFF' OR p_flex_field = 'SRS') THEN
      /*
      For DFF and SRS
      This rule is to make sure that a Dependent VS has it's
      Indpendent VS to reference in the previous segment
      If it is not a Dependent VS then no need to check child
      parent relationship.  If it is a Dependent value set then
      make sure it has it's parent.
      */
      IF(l_validation_type ='D' or l_validation_type ='Y') THEN
        BEGIN
          SELECT
           u.column_seq_num, v.parent_flex_value_set_id
          INTO
           l_column_seq_num, l_parent_value_set_id
          FROM
           fnd_flex_value_sets v, fnd_descr_flex_column_usages u
          WHERE
           v.flex_value_set_id = p_value_set_id and
           -- Bug#4410208, In SRS agruments form there is no context code
           (p_desc_flex_context_code is null or
           u.descriptive_flex_context_code = p_desc_flex_context_code) and
           v.parent_flex_value_set_id = u.flex_value_set_id;

          IF(NOT(l_column_seq_num < p_column_seq_num)) THEN

             select flex_value_set_name
             into l_parent_value_set_name
             from fnd_flex_value_sets
             where
             flex_value_set_id=l_parent_value_set_id;

             fnd_message.set_name('FND','FLEX-VSET IND DEP VSET ORDER');
             fnd_message.set_token('VSET_NAME',l_flex_value_set_name);
             fnd_message.set_token('SEG_NAME',p_segment_name);
             fnd_message.set_token('PARENT_VSET_NAME',l_parent_value_set_name);
             app_exception.raise_exception;
          END IF;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN

            select flex_value_set_name
            into l_parent_value_set_name
            from fnd_flex_value_sets
            where
            flex_value_set_id in (select parent_flex_value_set_id
                                  from fnd_flex_value_sets
                                  where flex_value_set_id=p_value_set_id);

            fnd_message.set_name('FND','FLEX-VSET PARENT VSET MISSING');
            fnd_message.set_token('VSET_NAME',l_flex_value_set_name);
            fnd_message.set_token('SEG_NAME',p_segment_name);
            fnd_message.set_token('PARENT_VSET_NAME',l_parent_value_set_name);
            app_exception.raise_exception;
          WHEN OTHERS THEN RAISE;
        END;
      END IF;
    END IF; /* DFF Check */

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE;
          WHEN OTHERS THEN RAISE;
  END;

END is_valueset_allowed;

PROCEDURE check_base_table_column(
                p_application_column_type   IN   fnd_columns.column_type%TYPE,
                p_application_column_size   IN   fnd_columns.width%TYPE,
                p_id_column_type            IN   fnd_flex_validation_tables.id_column_type%TYPE,
                p_id_column_size            IN   fnd_flex_validation_tables.id_column_size%TYPE,
                p_validation_type           IN   fnd_flex_value_sets.validation_type%TYPE,
                p_format_type               IN   fnd_flex_value_sets.format_type%TYPE,
                p_maximum_size              IN   fnd_flex_value_sets.maximum_size%TYPE,
                p_flex_value_set_name       IN   fnd_flex_value_sets.flex_value_set_name%TYPE,
                p_segment_name              IN   fnd_id_flex_segments.segment_name%TYPE)
IS

    l_format_type_name        VARCHAR2(80);
    l_appl_column_type_name   VARCHAR2(80);

BEGIN

   /*
    This rule is to make sure that the base table underlying column
    can store values from a VS based on its format type or id_column_type.
    If the underlying column type is a C=Char or V=Varchar2 then that
    column can store any VS value format. If the VS Validation Type
    is U=Special then it does not store any values in the base table
    so that can be used. If the underlying column is anything other
    than C=Char or V=Varchar2 then we need to make sure the VS will be
    compatible with the underlying column. First we check the VS
    Table ID Type. If it is not null then we can use that Type to compare
    to the underlying column and they must match. If the VS Table ID
    Type is null, then we use the VS Format Type to compare to the
    underlying column. If the underlying column is of type
    Date(D), then only VS Format Types T=DateTime, I=Time, X=StandardDate,
    Y=StandardDateTime, Z=StandardTime can be used.
    */
    IF(NOT((p_application_column_type = 'C' OR p_application_column_type = 'V')
           OR p_validation_type = 'U' OR
           ((p_application_column_type = p_id_column_type and
             p_id_column_type is not null) or
            (p_format_type in ('T','I','X','Y','Z') and
             p_application_column_type = 'D' and
             p_id_column_type is null) or
            (p_format_type not in ('T','I','X','Y','Z') and
             p_application_column_type = p_format_type and
             p_id_column_type is null))))
    THEN
        -- Get description of codes for the error message --

        select meaning
        into l_appl_column_type_name
        from fnd_lookups
        where lookup_code=p_application_column_type and
        lookup_type='COLUMN_TYPE';

        IF( p_id_column_type is NULL )
        THEN
          select meaning
          into l_format_type_name
          from fnd_lookups
          where lookup_code=p_format_type and lookup_type='FIELD_TYPE';
          fnd_message.set_name('FND','FLEX-VSET FORMAT TYPE CONFLICT');
        ELSE
          select meaning
          into l_format_type_name
          from fnd_lookups
          where lookup_code=p_id_column_type and lookup_type='COLUMN_TYPE';
          fnd_message.set_name('FND','FLEX-VSET ID COL TYPE CONFLICT');
        END IF;

        fnd_message.set_token('VSET_NAME',p_flex_value_set_name);
        fnd_message.set_token('SEG_NAME',p_segment_name);
        fnd_message.set_token('FORMAT_TYPE',l_format_type_name);
        fnd_message.set_token('DATA_TYPE',l_appl_column_type_name);
        app_exception.raise_exception;

    END IF;


    /*
    This rule is to make sure that the max value set size
    or the ID column size is not bigger than the underlying column.
    If the underlying table column is a date type then no need to
    check column size since a date column can store any date type.
    */
    IF(NOT( (p_application_column_type = 'D')
         OR (p_application_column_size >= p_maximum_size
             AND p_id_column_size IS NULL)
         OR (p_application_column_size >= p_id_column_size
             AND p_id_column_size IS NOT NULL)))
    THEN

        IF( p_id_column_type is NULL )
        THEN
           fnd_message.set_name('FND','FLEX-VSET MAX SIZE');
           fnd_message.set_token('VSET_MAXSIZE',p_maximum_size);
        ELSE
           fnd_message.set_name('FND','FLEX-VSET ID COL SIZE');
           fnd_message.set_token('ID_COL_SIZE',p_id_column_size);
        END IF;

        fnd_message.set_token('VSET_NAME',p_flex_value_set_name);
        fnd_message.set_token('SEG_NAME',p_segment_name);
        fnd_message.set_token('COL_SIZE',p_application_column_size);
        app_exception.raise_exception;
    END IF;

END check_base_table_column;

PROCEDURE is_vset_obsolete(
             p_format_type               IN   fnd_flex_value_sets.format_type%TYPE,
             p_flex_value_set_name       IN   fnd_flex_value_sets.flex_value_set_name%TYPE,
             p_segment_name              IN   fnd_id_flex_segments.segment_name%TYPE)
IS
BEGIN

   /*
   This rule is to make sure Date and DateTime value sets
   format types are not used since they are now obsolete and
   are replaced by Standard Date(X) and Standard DateTime(Y) format types.
   */
   IF(p_format_type='D' or p_format_type='T')
   THEN
       fnd_message.set_name('FND','FLEX-VSET TYPE OBSOLETE');
       fnd_message.set_token('VSET_NAME',p_flex_value_set_name);
       fnd_message.set_token('SEG_NAME',p_segment_name);
       app_exception.raise_exception;
   END IF;

END is_vset_obsolete;


-- Purpose
--   Validate a valuset for a given segment, based on
--   critera commented below, and give a error message if the
--   valueset is not valid for that segment. This gives
--   the user a chance to see why he cannot attach a vset to a
--   certain segment. Now we have a separate procedure for DFF/SRS.

PROCEDURE is_value_set_allowed_dff
          (p_flex_value_set_id               IN   fnd_flex_value_sets.flex_value_set_id%TYPE,
           p_application_id                  IN   fnd_descr_flex_column_usages.application_id%TYPE,
           p_descriptive_flexfield_name      IN   fnd_descr_flex_column_usages.descriptive_flexfield_name%TYPE,
           p_desc_flex_context_code          IN   fnd_descr_flex_column_usages.descriptive_flex_context_code%TYPE,
           p_application_column_name         IN   fnd_descr_flex_column_usages.application_column_name%TYPE,
           p_end_user_column_name            IN   fnd_descr_flex_column_usages.end_user_column_name%TYPE,
           p_column_seq_num                  IN   fnd_descr_flex_column_usages.column_seq_num%TYPE)
IS
    l_validation_type           VARCHAR2(1);
    l_format_type               VARCHAR2(1);
    l_maximum_size              NUMBER(3);
    l_column_seq_num            NUMBER(3);
    l_id_column_type            VARCHAR2(1);
    l_id_column_size            NUMBER(3);
    l_application_column_name   VARCHAR2(30);
    l_application_column_type   VARCHAR2(1);
    l_application_column_size   NUMBER(15);

    l_flex_value_set_name       VARCHAR2(60);
    l_parent_value_set_name     VARCHAR2(60);
    l_parent_value_set_id       NUMBER(10);

BEGIN
  BEGIN

    -- If no vset id is passed in, assume no valueset to valdate.
    IF (p_flex_value_set_id IS NULL)
    THEN
     RETURN;
    END IF;

    -- Initialize all local variables needed for validation.
    l_application_column_name := p_application_column_name;

    -- Bug 4657356.
    IF (instr(p_descriptive_flexfield_name,'$SRS$') > 0) THEN
      -- The SRS form does not need to save the Parameter values entered
      -- in the FF. Because of this, there is no base table to validate
      -- against. Instead of validating against a base table we use
      -- column attributes from fnd_column and fnd_tables.
      -- We assign the values returned to what normally we would
      -- get from the base table. Now normal validation can continue
      -- since we have values for p_application_column_type and
      -- p_application_column_size. They are passed in as null from
      -- the SRS form.

      SELECT
       c.column_type, c.width
      INTO
       l_application_column_type, l_application_column_size
      FROM
       fnd_columns c, fnd_tables tb
      WHERE
       tb.application_id = 0 and
       tb.table_name = 'FND_SRS_MASTER' and
       tb.application_id = c.application_id and
       tb.table_id = c.table_id and c.column_name = 'ATTRIBUTE1';
    ELSE
      SELECT
       c.column_type, c.width
      INTO
       l_application_column_type, l_application_column_size
      FROM
       fnd_descriptive_flexs dff,
       fnd_tables tb,
       fnd_columns c
      WHERE
       c.application_id = tb.application_id and
       c.table_id = tb.table_id and
       c.application_id = dff.table_application_id and
       tb.table_name = dff.application_table_name and
       dff.application_id = p_application_id and
       dff.descriptive_flexfield_name = p_descriptive_flexfield_name
       and c.column_name = l_application_column_name;
    END IF;

    SELECT
     v.validation_type, v.format_type, v.maximum_size,
     v.flex_value_set_name, t.id_column_type,
     t.id_column_size
    INTO
     l_validation_type, l_format_type, l_maximum_size,
     l_flex_value_set_name, l_id_column_type,
     l_id_column_size
    FROM
     fnd_flex_value_sets v,
     fnd_flex_validation_tables t
    WHERE
     v.flex_value_set_id = p_flex_value_set_id and
     v.flex_value_set_id = t.flex_value_set_id(+);


   -- Please note the order in which the rules are checked is based
   -- which ones are more serious. A value set may have more than
   -- one rule that it violates. The one we display first is the most
   -- serious. For example, if a vset format type is obsolete, I don't
   -- want to first get an error message saying that my format type does
   -- not match the database column data type. The first thing I want to
   -- know is the the vset is obsolete.

    is_vset_obsolete(l_format_type,
                     l_flex_value_set_name,
                     p_end_user_column_name);

    check_base_table_column(l_application_column_type,
                            l_application_column_size,
                            l_id_column_type,
                            l_id_column_size,
                            l_validation_type,
                            l_format_type,
                            l_maximum_size,
                            l_flex_value_set_name,
                            p_end_user_column_name);

    /*
    This rule is to make sure that a Dependent VS has it's
    Indpendent VS to reference in the previous segment
    If it is not a Dependent VS then no need to check child
    parent relationship.  If it is a Dependent value set then
    make sure it has it's parent.
    */
    IF(l_validation_type ='D' or l_validation_type ='Y') THEN
      BEGIN
        SELECT
         min(u.column_seq_num), v.parent_flex_value_set_id
        INTO
         l_column_seq_num, l_parent_value_set_id
        FROM
         fnd_flex_value_sets v, fnd_descr_flex_column_usages u
        WHERE
         v.flex_value_set_id = p_flex_value_set_id
         -- Bug#4564981
         AND u.application_id = p_application_id
         AND u.descriptive_flexfield_name = p_descriptive_flexfield_name
         -- Bug#4410208, In SRS agruments form,the context is null when a parameter is defined
         AND (p_desc_flex_context_code is null or
         u.descriptive_flex_context_code = p_desc_flex_context_code)
         AND v.parent_flex_value_set_id = u.flex_value_set_id
         group by v.parent_flex_value_set_id;

        IF(NOT(l_column_seq_num < p_column_seq_num)) THEN

           select flex_value_set_name
           into l_parent_value_set_name
           from fnd_flex_value_sets
           where
           flex_value_set_id=l_parent_value_set_id;

           fnd_message.set_name('FND','FLEX-VSET IND DEP VSET ORDER');
           fnd_message.set_token('VSET_NAME',l_flex_value_set_name);
           fnd_message.set_token('SEG_NAME',p_end_user_column_name);
           fnd_message.set_token('PARENT_VSET_NAME',l_parent_value_set_name);
           app_exception.raise_exception;
        END IF;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN

          select flex_value_set_name
          into l_parent_value_set_name
          from fnd_flex_value_sets
          where
          flex_value_set_id in (select parent_flex_value_set_id
                                from fnd_flex_value_sets
                                where flex_value_set_id=p_flex_value_set_id);

          fnd_message.set_name('FND','FLEX-VSET PARENT VSET MISSING');
          fnd_message.set_token('VSET_NAME',l_flex_value_set_name);
          fnd_message.set_token('SEG_NAME',p_end_user_column_name);
          fnd_message.set_token('PARENT_VSET_NAME',l_parent_value_set_name);
          app_exception.raise_exception;
        WHEN OTHERS THEN RAISE;
      END;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE;
    WHEN OTHERS THEN RAISE;
  END;

END is_value_set_allowed_dff;


-- Purpose
--   Validate a valuset for a given segment, based on
--   critera commented below, and give a error message if the
--   valueset is not valid for that segment. This gives
--   the user a chance to see why he cannot attach a vset to a
--   certain segment. Now we have a separate procedure for KFF.

PROCEDURE is_value_set_allowed_kff
          (p_flex_value_set_id         IN   fnd_flex_value_sets.flex_value_set_id%TYPE,
           p_application_id            IN   fnd_id_flex_segments.application_id%TYPE,
           p_id_flex_code              IN   fnd_id_flex_segments.id_flex_code%TYPE,
           p_id_flex_num               IN   fnd_id_flex_segments.id_flex_num%TYPE,
           p_application_column_name   IN   fnd_id_flex_segments.application_column_name%TYPE,
           p_segment_name              IN   fnd_id_flex_segments.segment_name%TYPE,
           p_segment_num               IN   fnd_id_flex_segments.segment_num%TYPE)
IS

    l_validation_type         VARCHAR2(1);
    l_format_type             VARCHAR2(1);
    l_maximum_size            NUMBER(3);
    l_allow_id_valuesets      VARCHAR2(1);
    l_id_column_name          VARCHAR2(240);
    l_id_column_type          VARCHAR2(1);
    l_id_column_size          NUMBER(3);
    l_segment_num             NUMBER(3);
    l_number_precision        NUMBER(2);
    l_application_column_type VARCHAR2(1);
    l_application_column_size NUMBER(15);

    l_flex_value_set_name     VARCHAR2(60);
    l_parent_value_set_name   VARCHAR2(60);
    l_parent_value_set_id     NUMBER(10);

BEGIN
  BEGIN

    -- If no vset id is passed in, assume no valueset to valdate.
    IF (p_flex_value_set_id IS NULL)
    THEN
     RETURN;
    END IF;

    -- Initialize all local variables needed for validation.

    SELECT
     c.column_type, c.width, kff.allow_id_valuesets
    INTO
     l_application_column_type, l_application_column_size, l_allow_id_valuesets
    FROM
     fnd_id_flexs kff,
     fnd_tables tb,
     fnd_columns c
    WHERE
     c.application_id = tb.application_id and
     c.table_id = tb.table_id and
     c.application_id = kff.table_application_id and
     tb.table_name = kff.application_table_name and
     kff.application_id = p_application_id and
     kff.id_flex_code = p_id_flex_code
     and c.column_name = p_application_column_name;

    SELECT
     v.validation_type, v.format_type, v.maximum_size,
     v.number_precision, v.flex_value_set_name,
     t.id_column_name, t.id_column_type, t.id_column_size
    INTO
     l_validation_type, l_format_type, l_maximum_size,
     l_number_precision, l_flex_value_set_name,
     l_id_column_name, l_id_column_type, l_id_column_size
    FROM
     fnd_flex_value_sets v,
     fnd_flex_validation_tables t
    WHERE
     v.flex_value_set_id = p_flex_value_set_id and
     v.flex_value_set_id = t.flex_value_set_id(+);


   -- Please note the order in which the rules are checked is based
   -- which ones are more serious. A value set may have more than
   -- one rule that it violates. The one we display first is the most
   -- serious. For example, if a vset format type is obsolete, I don't
   -- want to first get an error message saying that my format type does
   -- not match the database column data type. The first thing I want to
   -- know is the the vset is obsolete.

    is_vset_obsolete(l_format_type,
                     l_flex_value_set_name,
                     p_segment_name);

    /*
    Table Validate value sets with hidden ID columns may
    not be used with KFF's defiend with 'ID VS not allowed'.
    Check to see if the FF is allowed to have an ID VS.
    If so, then the VS can be used. If the FF
    is not allowed to have an ID VS, then we need to
    check if the value set is defined as an ID VS.
    if the id_column_name is null, then it is not an
    ID VS and it can be displayed.
    */
    IF(NOT(l_allow_id_valuesets = 'Y' OR
        (l_allow_id_valuesets = 'N' AND l_id_column_name is NULL)))
    THEN
        fnd_message.set_name('FND','FLEX-VSET IDVSET RESTRICTED');
        fnd_message.set_token('VSET_NAME',l_flex_value_set_name);
        fnd_message.set_token('SEG_NAME',p_segment_name);
        app_exception.raise_exception;
    END IF;


    /*
    Table Validate value sets with hidden ID columns may
    not be used with KFF's defiend with 'ID VS not allowed'.
    Check to see if the FF is allowed to have an ID VS.
    If so, then the VS can be displayed. If the FF
    is not allowed to have an ID VS, then we need to
    check if the Value Set is defined as an ID VS.
    If the VS has a Validation Type of Translatable
    Independent/Dependent, then it cannot be used
    because those validation types are internally
    ID value sets.
    */
    IF(NOT(l_allow_id_valuesets = 'Y' OR
        (l_allow_id_valuesets = 'N' AND
         l_validation_type <> 'X' AND l_validation_type <> 'Y')))
    THEN
       fnd_message.set_name('FND','FLEX-VSET IDVSET TR RESTRICTED');
       fnd_message.set_token('VSET_NAME',l_flex_value_set_name);
       fnd_message.set_token('SEG_NAME',p_segment_name);
       app_exception.raise_exception;
    END IF;


    /*
    'Date', 'DateTime', 'Time' and 'Number with Precision'
    vsets are a type of ID vsets.
    Some KFF's do not allow ID vsets. If ID vsets are not
    allowed then we must make sure these vsets are not used.
    */
    IF(NOT(l_allow_id_valuesets = 'Y' OR
          (l_allow_id_valuesets = 'N' AND
          (l_format_type <> 'X' AND
           l_format_type <> 'Y' AND
           l_format_type <> 'I' AND
           l_format_type <> 'N') OR
          ((l_format_type = 'N' AND
           l_number_precision IS NOT NULL AND
           l_number_precision = 0)))))
    THEN
       fnd_message.set_name('FND','FLEX-VSET IDVSET DN RESTRICTED');
       fnd_message.set_token('VSET_NAME',l_flex_value_set_name);
       fnd_message.set_token('SEG_NAME',p_segment_name);
       app_exception.raise_exception;
    END IF;


    check_base_table_column(l_application_column_type,
                            l_application_column_size,
                            l_id_column_type,
                            l_id_column_size,
                            l_validation_type,
                            l_format_type,
                            l_maximum_size,
                            l_flex_value_set_name,
                            p_segment_name);


    /*
    This rule is to make sure that a Dependent VS has it's
    Indpendent VS to reference in the previous segment
    If it is not a Dependent VS then no need to check child
    parent relationship.  If it is a Dependent value set then
    make sure it has it's parent.
    */
    IF(l_validation_type ='D' or l_validation_type ='Y') THEN
      BEGIN
        SELECT
         min(s.segment_num), v.parent_flex_value_set_id
        INTO
         l_segment_num, l_parent_value_set_id
        FROM
         fnd_flex_value_sets v, fnd_id_flex_segments s
        WHERE
         v.flex_value_set_id = p_flex_value_set_id
         -- Bug#4564981
         AND s.application_id = p_application_id
         AND s.id_flex_code = p_id_flex_code
         AND s.id_flex_num = p_id_flex_num
         AND v.parent_flex_value_set_id = s.flex_value_set_id
         group by v.parent_flex_value_set_id;

        IF(NOT(l_segment_num < p_segment_num)) THEN

           select flex_value_set_name
           into l_parent_value_set_name
           from fnd_flex_value_sets
           where
           flex_value_set_id=l_parent_value_set_id;

           fnd_message.set_name('FND','FLEX-VSET IND DEP VSET ORDER');
           fnd_message.set_token('VSET_NAME',l_flex_value_set_name);
           fnd_message.set_token('SEG_NAME',p_segment_name);
           fnd_message.set_token('PARENT_VSET_NAME',l_parent_value_set_name);
           app_exception.raise_exception;
        END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN

            select flex_value_set_name
            into l_parent_value_set_name
            from fnd_flex_value_sets
            where
            flex_value_set_id in (select parent_flex_value_set_id
                                  from fnd_flex_value_sets
                                  where flex_value_set_id=p_flex_value_set_id);

            fnd_message.set_name('FND','FLEX-VSET PARENT VSET MISSING');
            fnd_message.set_token('VSET_NAME',l_flex_value_set_name);
            fnd_message.set_token('SEG_NAME',p_segment_name);
            fnd_message.set_token('PARENT_VSET_NAME',l_parent_value_set_name);
            app_exception.raise_exception;
        WHEN OTHERS THEN RAISE;
      END;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE;
          WHEN OTHERS THEN RAISE;
  END;

END is_value_set_allowed_kff;


/**********************************************************************
This procedure will take a string and give you the
location (begining and end postion), of the first bind variable it
finds.  It starts it's search from the location of position p_sbegin.
p_sql_clause is the input string to be parsed.
p_sbegin is the location the search will start from.
x_bbegin is the location of the begining of the bind variable.
x_bend is the location of the end of the bind variable.
**********************************************************************/

PROCEDURE find_bind(
        p_sql_clause   IN    VARCHAR2,
        p_sbegin       IN    NUMBER,
        x_bbegin       OUT   NOCOPY NUMBER,
        x_bend         OUT   NOCOPY NUMBER)
 IS

   l_marker bind_array_type;
   l_sbegin NUMBER;
   l_bbegin NUMBER;
   l_bend   NUMBER;
   temppos  NUMBER;
   temptype      VARCHAR2(1);
   WHITESPACE    VARCHAR2(1);
   SINGLEQ       VARCHAR2(1);
   PAREN         VARCHAR2(1);
   COMMA         VARCHAR2(1);
   EQUALTO       VARCHAR2(1);

BEGIN

   WHITESPACE  := ' ';
   SINGLEQ     := '''';
   PAREN       := ')';
   COMMA       := ',';
   EQUALTO     := '=';

  l_sbegin := p_sbegin;

  LOOP
     -- Find the colon. The colon signifies a possible bind variable.
     -- We say possible because the colon could be inside single quotes.
     l_bbegin := INSTR(p_sql_clause, ':', l_sbegin);
     if(l_bbegin = 0) then
         -- No more colons found, return 0 for begin
         -- position of the bind variable.
          x_bbegin := l_bbegin;
          x_bend := 0;
          EXIT;
     end if;

     -- After the colon look for these ending markers. The one that
     -- comes first, is the marker that indicates the end of the bind variable.
     -- The exception is the single quote. A single quote signifies
     -- No bind because the : appears within single quotes.
     -- The markers are White Space, Parenthesis, and Comma.
     l_marker(1).pos:=INSTR (p_sql_clause, WHITESPACE, l_bbegin);
     l_marker(1).type:=WHITESPACE;
     l_marker(2).pos := INSTR (p_sql_clause, SINGLEQ, l_bbegin);
     l_marker(2).type:=SINGLEQ;
     l_marker(3).pos := INSTR(p_sql_clause, PAREN, l_bbegin);
     l_marker(3).type:=PAREN;
     l_marker(4).pos := INSTR(p_sql_clause, COMMA, l_bbegin);
     l_marker(4).type:=COMMA;
     l_marker(5).pos := INSTR(p_sql_clause, EQUALTO, l_bbegin);
     l_marker(5).type:=EQUALTO;


     -- Sort the markers to see which one comes first.
     -- Sort the markers in order of first occurance
     -- The l_marker will equal 0 if a marker is not found.
     -- Place all 0 values at the end of sort order. All numbers
     -- will be sorted in ascending order except for 0. 0's will
     -- be always at the end since it means not found.
     FOR i IN 1..4 LOOP
       FOR j IN (i+1)..5 LOOP
           IF (((l_marker(i).pos > l_marker(j).pos) AND
                (l_marker(j).pos<>0)) OR
                (l_marker(i).pos=0 AND l_marker(j).pos<>0)) THEN
                   temppos := l_marker(j).pos;
                   temptype := l_marker(j).type;
                   l_marker(j).pos := l_marker(i).pos;
                   l_marker(j).type := l_marker(i).type;
                   l_marker(i).pos := temppos;
                   l_marker(i).type := temptype;
            END IF;
       END LOOP;
     END LOOP;

     IF (l_marker(1).pos <> 0 AND l_marker(1).type <> SINGLEQ) THEN
       -- Bind found, return begin and end position of the bind variable.
       x_bbegin := l_bbegin;
       x_bend := l_marker(1).pos;
       EXIT;
     ELSIF (l_marker(1).pos = 0 AND l_marker(1).type <> SINGLEQ) THEN
       -- Bind found, return begin and end position of the bind variable.
       -- Assume Bind is from : to end of string, since no markers were found.
       x_bbegin := l_bbegin;
       x_bend := length(p_sql_clause) + 1;
       EXIT;
     ELSE
      -- No bind found, look for next colon.
      l_sbegin := l_bbegin + 1;
     END IF;

  END LOOP;

END find_bind;


/**********************************************************************
This function takes a string and replaces any bind variables
(such as :block.field, :$FLEX$.<vset> and :$PROFILE$.<profile>)
with a 'null'. It then returns the new string to the calling function
**********************************************************************/
FUNCTION replace_binds(p_sql_clause IN VARCHAR2)
 RETURN VARCHAR2
 IS

  l_sql_clause          VARCHAR2(32000);
  l_build_nobind_clause VARCHAR2(32000);
  l_nobinds_clause      VARCHAR2(32000);
  l_bind_exists NUMBER;
  l_sbegin      NUMBER;
  l_bbegin      NUMBER;
  l_bend        NUMBER;
  NEWLINE       VARCHAR2(4);
  TAB           VARCHAR2(4);
  WHITESPACE    VARCHAR2(1);

BEGIN

   NEWLINE     := fnd_global.newline;
   TAB         := fnd_global.tab;
   WHITESPACE  := ' ';

   if(p_sql_clause is not NULL) then

      -- Replace ALL NEWLINES and TABS with a WHITESPACE
      l_sql_clause := replace(p_sql_clause,NEWLINE, WHITESPACE);
      l_sql_clause := replace(l_sql_clause,TAB, WHITESPACE);

      -- Check to see if any binds vars exist in the sql clause
      l_bind_exists := instr(l_sql_clause, ':');

      -- If there are no bind vars then the sql clause can be tested as is
      if(l_bind_exists = 0) then
           l_nobinds_clause := l_sql_clause;
      else
          -- If binds exist then they need to be removed and replaced
          -- with the value null. We cannot resolve binds at this point
          -- so we just replace them with null and test the rest of
          -- the awc for valid column names and syntax.

          l_build_nobind_clause := '';
          -- Start search from the begining of the string.
          l_sbegin := 1;

          LOOP

            find_bind(l_sql_clause, l_sbegin, l_bbegin, l_bend);

            if(l_bbegin=0) then
               -- No more bind variables found.
                EXIT;
            end if;

            -- Build string without binds.
            -- Grab the text from the end of last bind to the
            -- beginning of the next bind.
            l_build_nobind_clause := l_build_nobind_clause ||
            substr(l_sql_clause, l_sbegin, l_bbegin - l_sbegin );

            -- Insert null to replace the bind variable
            l_build_nobind_clause := l_build_nobind_clause||'null';

            -- Begin next search at the end of the bind variable in the string.
            l_sbegin := l_bend;

          END LOOP;

          -- No more binds found, concatenate the rest of the string.
          l_build_nobind_clause := l_build_nobind_clause ||
                substr(l_sql_clause, l_sbegin,
                length(l_sql_clause) - l_sbegin + 1);


          l_nobinds_clause := l_build_nobind_clause;

      end if;
   else
          l_nobinds_clause := p_sql_clause;
   end if;

   RETURN l_nobinds_clause;


END replace_binds;



PROCEDURE validate_table_vset(
        p_flex_value_set_name           IN  fnd_flex_value_sets.flex_value_set_name%TYPE,
        p_id_column_name                IN  fnd_flex_validation_tables.id_column_name%TYPE,
        p_value_column_name             IN  fnd_flex_validation_tables.value_column_name%TYPE,
        p_meaning_column_name           IN  fnd_flex_validation_tables.meaning_column_name%TYPE,
        p_additional_quickpick_columns  IN  fnd_flex_validation_tables.additional_quickpick_columns%TYPE,
        p_application_table_name        IN  fnd_flex_validation_tables.application_table_name%TYPE,
        p_additional_where_clause       IN  fnd_flex_validation_tables.additional_where_clause%TYPE,
        x_result                        OUT  NOCOPY VARCHAR2,
        x_message                       OUT  NOCOPY VARCHAR2)
IS
   l_stmt  VARCHAR2(32000);
   l_stmt1 VARCHAR2(32000);
   l_message VARCHAR(32000);
   l_cur_hdl INTEGER;
   l_tmpaddlclmn fnd_flex_validation_tables.additional_quickpick_columns%TYPE;
   l_tmpaddlclmnfrmt fnd_flex_validation_tables.additional_quickpick_columns%TYPE;
   l_double_quote varchar2(3);
   l_appl_string varchar2(10);
   l_star varchar2(2);
   l_name_string varchar2(10);
   l_open_bracket varchar2(3);
   l_close_bracket varchar2(3);
   l_additional_column_width1 fnd_flex_validation_tables.additional_quickpick_columns%TYPE;
   l_additional_column_width2 fnd_flex_validation_tables.additional_quickpick_columns%TYPE;
   l_additional_where_clause fnd_flex_validation_tables.additional_where_clause%TYPE;
   l_id_column_name fnd_flex_validation_tables.id_column_name%TYPE;
   l_value_column_name fnd_flex_validation_tables.value_column_name%TYPE;
   l_additional_column_width3 varchar2(20);
   l_position1_double_quote number;
   l_position2_double_quote number;
   l_position_open_bracket number;
   l_position_close_bracket number;
   l_position_appl_string number;
   l_position_name_string number;
   l_starting_position number;
   NEWLINE       VARCHAR2(4);
   WHITESPACE    VARCHAR2(4);
   COMMA         VARCHAR2(1);
   l_into  varchar2_array_type;
   l_tmpaddlclmn1 fnd_flex_validation_tables.additional_quickpick_columns%TYPE;
   l_tmpaddlclmn_no_into fnd_flex_validation_tables.additional_quickpick_columns%TYPE;
   l_char varchar2(4);
   l_position number;
   l_into_begin number;
   l_into_end number;
   l_where varchar2(10);
   l_orderby varchar2(10);
   l_ltrim_where_clause fnd_flex_validation_tables.additional_where_clause%TYPE;
   l_ret number;
BEGIN

   l_double_quote := '"';
   l_appl_string := 'APPL=';
   l_star := '*';
   l_name_string := 'NAME=';
   l_open_bracket := '(';
   l_close_bracket := ')';
   l_starting_position  := 1;
   NEWLINE := fnd_global.newline;
   WHITESPACE  := fnd_global.local_chr(32);
   l_into(0) := WHITESPACE||'into'||WHITESPACE;
   l_into(1) := WHITESPACE||'into'||NEWLINE;
   l_into(2) := NEWLINE||'into'||WHITESPACE;
   l_into(3) := NEWLINE||'into'||NEWLINE;
   COMMA := ',';

   l_stmt := NULL; -- Initialize

   l_stmt := p_value_column_name || ' VALUE ';

   IF (p_meaning_column_name is not NULL) THEN
       l_stmt := l_stmt||', '||p_meaning_column_name || ' DESCRIPTION ';
   END IF;

   IF (p_id_column_name is not NULL) THEN
       l_stmt := l_stmt||', '||p_id_column_name;
   END IF;

   IF (p_additional_quickpick_columns is not NULL) THEN

       l_tmpaddlclmn := p_additional_quickpick_columns;
       l_tmpaddlclmnfrmt := p_additional_quickpick_columns;

       /* Following section replaces message name with DUMMY string */
       LOOP
          l_position1_double_quote := instr(l_tmpaddlclmn,l_double_quote,l_starting_position);
          l_position2_double_quote := instr(l_tmpaddlclmn,l_double_quote,l_position1_double_quote+1);

          EXIT WHEN (l_position1_double_quote=0 or l_position2_double_quote=0);

          /* Checking for message name starting with APPL= in quotations */
          l_additional_column_width2 := substr(l_tmpaddlclmn,l_position1_double_quote+1,l_position2_double_quote-l_position1_double_quote-1);
          l_position_appl_string := instr(l_additional_column_width2,l_appl_string);

          if (l_position_appl_string>0)
          then
             /* Check if NAME= is present */
             l_position_name_string := instr(l_additional_column_width2,l_name_string);
             if (l_position_name_string>0)
             then
                l_tmpaddlclmn := replace(l_tmpaddlclmn,l_additional_column_width2,'DUMMY');
                l_position2_double_quote := instr(l_tmpaddlclmn,l_double_quote,l_position1_double_quote+1);
             end if;
          end if;
          l_starting_position := l_position2_double_quote + 1;
       END LOOP;

       /* Following section removes (width) from addtl. columns */
       l_starting_position := 1;
       LOOP
          l_position_open_bracket := instr(l_tmpaddlclmn,l_open_bracket,l_starting_position);
          l_position_close_bracket := instr(l_tmpaddlclmn,l_close_bracket,l_position_open_bracket+1);

          EXIT WHEN (l_position_open_bracket=0 or l_position_close_bracket=0);

          l_char := substr(l_tmpaddlclmn,l_position_open_bracket-1,1);
          if ((l_char = WHITESPACE) or (l_char = NEWLINE) or (l_char = l_double_quote))
          then
             l_additional_column_width1 := substr(l_tmpaddlclmn,l_position_open_bracket+1,l_position_close_bracket-l_position_open_bracket-1);
             /* Bug 4586657 - Added check for verifying the column width value */
             l_additional_column_width2 := replace(translate(l_additional_column_width1,'1234567890*','00000000000'),'0','');
             if (l_additional_column_width2 is not NULL) then
                 x_result := 'Failure';
                 x_message := 'Invalid Width specified for Additional Column';
                 return;
             end if;

             l_tmpaddlclmnfrmt := substr(l_tmpaddlclmn,1,l_position_open_bracket-1)||substr(l_tmpaddlclmn,l_position_close_bracket+1);
             l_tmpaddlclmn := l_tmpaddlclmnfrmt;
             l_starting_position := l_position_open_bracket + 1;
          else
             l_starting_position := l_position_close_bracket + 1;
          end if;
       END LOOP;

       /* Bug 4908763 problem 1. Remove all " into field " from
          Additional Columns.
          select application_id "ap_id' into ap_id from fnd_application;
          becomes
          select application_id "ap_id" from fnd_application; */

       l_tmpaddlclmn_no_into := l_tmpaddlclmn;
       for i in 0..3
       loop
          l_into_begin := instr(lower(l_tmpaddlclmn_no_into), l_into(i));
          while (l_into_begin > 0)
          loop
             l_tmpaddlclmn1 := substr(l_tmpaddlclmn_no_into, 0, l_into_begin);
             l_into_end := l_into_begin + 5;
             l_position := 0;

             l_char := substr(l_tmpaddlclmn_no_into, l_into_end, 1);
             while ((l_char = WHITESPACE) or (l_char = NEWLINE))
             loop
                l_position := l_position + 1;
                l_char := substr(l_tmpaddlclmn_no_into, l_into_end + l_position, 1);
             end loop; /* Located beginning of field name after INTO */

             while ((l_char <> WHITESPACE) and (l_char <> NEWLINE) and (l_char <> COMMA) and (l_char is not NULL))
             loop
                l_position := l_position + 1;
                l_char := substr(l_tmpaddlclmn_no_into, l_into_end + l_position, 1);
             end loop; /* Located end of field name after INTO */

             l_tmpaddlclmn_no_into := l_tmpaddlclmn1||WHITESPACE||substr(l_tmpaddlclmn_no_into, l_into_end + l_position);
             l_into_begin := instr(lower(l_tmpaddlclmn_no_into), l_into(i));
          end loop;
       end loop;

       l_tmpaddlclmn := l_tmpaddlclmn_no_into;
       l_stmt := l_stmt||', '||l_tmpaddlclmn;

   END IF;

   l_cur_hdl := dbms_sql.open_cursor;

   IF (l_stmt is not NULL) THEN

      -- Remove bind variables, if any, and replace with null
      l_stmt := replace_binds(p_sql_clause => l_stmt);

      -- Test Value Column, ID Column and Additional Columns
      l_stmt1 := 'select '||l_stmt||
      ' from '||p_application_table_name||
      ' where rownum=1';
      dbms_sql.parse(l_cur_hdl, l_stmt1, dbms_sql.native);

   END IF;

   -- Test the ID Column
   IF (p_id_column_name is not NULL) THEN

       l_id_column_name := replace_binds(p_sql_clause => p_id_column_name);

       l_stmt1 := 'select '||l_stmt||
       ' from '||p_application_table_name||
       ' where rownum=1 and '||
       l_id_column_name||' is NULL';
       dbms_sql.parse(l_cur_hdl, l_stmt1, dbms_sql.native);
END IF;

   -- Test the Value Column
   IF (p_value_column_name is not NULL) THEN

       l_value_column_name :=replace_binds(p_sql_clause => p_value_column_name);

       l_stmt1 := 'select '||l_stmt||
       ' from '||p_application_table_name||
       ' where rownum=1 and '||
       l_value_column_name||' is NULL';
       dbms_sql.parse(l_cur_hdl, l_stmt1, dbms_sql.native);

   END IF;

   -- Test the Additional Where clause
   IF(p_additional_where_clause is not NULL) THEN

        -- Limit the Addt'l Where clause to 32K
        l_additional_where_clause := substr(p_additional_where_clause,0,32000);

        l_additional_where_clause :=
                      replace_binds(p_sql_clause => l_additional_where_clause);

        /*
           Bug 4908763 problems 3 and 7. Add " where " if "where" or "order by"
           is not there in Where/Order By clause.
        */
        l_ltrim_where_clause := lower(ltrim(ltrim(l_additional_where_clause, WHITESPACE), NEWLINE));
        l_where := substr(l_ltrim_where_clause, 0, 5);
        l_orderby := substr(l_ltrim_where_clause, 0, 8);
        if ((l_where='where') or (l_orderby='order by'))
        then
           l_stmt1 := 'select '||l_stmt||' from '||p_application_table_name||' '||
                       l_additional_where_clause;
        else
           l_stmt1 := 'select '||l_stmt||' from '||p_application_table_name
                       || ' where ' ||l_additional_where_clause;
        end if;
        dbms_sql.parse(l_cur_hdl, l_stmt1, dbms_sql.native);

        l_ret := instr(l_ltrim_where_clause, 'group by', 1, 1);
   END IF;

   dbms_sql.close_cursor(l_cur_hdl);

   IF(l_ret > 0) THEN
        x_result := 'Failure';
        l_message := substr(l_stmt1,1,32000);
        x_message := 'You may not use GROUP BY in your WHERE clause';
        x_message := substr(x_message || NEWLINE || l_message,1,32000);
   ELSE
        x_result := 'Success';
   END IF;

EXCEPTION
   WHEN OTHERS THEN
       if dbms_sql.is_open(l_cur_hdl) then
           dbms_sql.close_cursor(l_cur_hdl);
       end if;
       x_result  := 'Failure';
       l_message := substr(l_stmt1,1,32000);
       x_message := substr(SQLERRM || NEWLINE || l_message,1,32000);

END validate_table_vset; /* procedure */




/* END_PUBLIC */

END fnd_flex_val_api; /* package body*/

/
