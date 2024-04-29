--------------------------------------------------------
--  DDL for Package Body FND_FLEX_KEY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_KEY_API" AS
/* $Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $ */

-- ==================================================
-- CACHING
-- ==================================================
g_cache_return_code VARCHAR2(30);
g_cache_key         VARCHAR2(2000);
g_cache_value       fnd_plsql_cache.generic_cache_value_type;

-- --------------------------------------------------
-- soq : Segment Order by Qualifier Name Cache
-- --------------------------------------------------
soq_cache_controller      fnd_plsql_cache.cache_1to1_controller_type;
soq_cache_storage         fnd_plsql_cache.generic_cache_values_type;

value_too_large EXCEPTION;
PRAGMA EXCEPTION_INIT(value_too_large, -01401);

debug_mode_on BOOLEAN := FALSE;
do_validation BOOLEAN := TRUE;
internal_messages VARCHAR2(10000);
chr_newline VARCHAR2(8) := fnd_global.newline;


/* ---------- WHO INFORMATION ---------- */

who_mode VARCHAR2(1000) := NULL;  /* whether customer_data or seed_data */
last_update_login_i fnd_flex_value_sets.last_update_login%TYPE;
last_update_date_i  fnd_flex_value_sets.last_update_date%TYPE;
last_updated_by_i   fnd_flex_value_sets.last_updated_by%TYPE;
creation_date_i     fnd_flex_value_sets.creation_date%TYPE;
created_by_i        fnd_flex_value_sets.created_by%TYPE;

--
-- ERROR constants
--
error_others                   CONSTANT NUMBER := -20100;
error_no_data_found            CONSTANT NUMBER := -20101;
error_tag_white_space          CONSTANT NUMBER := -20102;
error_tag_max_length           CONSTANT NUMBER := -20103;
error_tag_exists               CONSTANT NUMBER := -20104;
error_tag_not_exists           CONSTANT NUMBER := -20105;
error_clause_comments          CONSTANT NUMBER := -20106;
error_awc_null                 CONSTANT NUMBER := -20107;
error_clause_exists            CONSTANT NUMBER := -20108;

CURSOR structure_c(flexfield IN flexfield_type,
		   enabled   IN VARCHAR2 DEFAULT NULL) IS
   SELECT id_flex_structure_name structure_name,
          id_flex_num structure_number
     FROM fnd_id_flex_structures_vl
    WHERE application_id = flexfield.application_id
      AND id_flex_code = flexfield.flex_code
      AND (structure_c.enabled IS NULL OR enabled_flag = 'Y')
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL
    ORDER BY id_flex_code;

CURSOR segment_c(flexfield IN flexfield_type,
		 structure IN structure_type,
		 enabled   IN VARCHAR2 DEFAULT NULL) IS
   SELECT segment_name,
          application_column_name
     FROM fnd_id_flex_segments_vl
    WHERE application_id = flexfield.application_id
      AND id_flex_code = flexfield.flex_code
      AND id_flex_num = structure.structure_number
      AND (enabled IS NULL or enabled_flag = 'Y')
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL
    ORDER BY segment_num;


--
-- TYPEs
--
SUBTYPE app_type         IS fnd_application%ROWTYPE;

  TYPE rec_key IS RECORD(
    k_app_short_name  fnd_application.application_short_name%TYPE,
    k_id_flex_code    fnd_id_flexs.id_flex_code%TYPE,
    k_id_flex_name    fnd_id_flexs.id_flex_name%TYPE,
    k_appl_table_name fnd_id_flexs.application_table_name%TYPE);

  TYPE t_rec_key IS TABLE OF rec_key INDEX BY BINARY_INTEGER;

  v_keys t_rec_key; -- vector of KEY records



--
-- Global Variables
--
g_unused_argument  VARCHAR2(100);

--
-- Forward declerations;
--

FUNCTION customer_mode RETURN BOOLEAN;

/* ============================================================ */
/* MESSAGING                                                    */
/* ============================================================ */
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
   internal_messages := internal_messages || msg || chr_newline;
--   internal_messages := internal_messages || Sqlerrm; /* error stamp */
END;

PROCEDURE message_init IS
BEGIN
   internal_messages := '';
   IF (customer_mode) THEN
      internal_messages := 'CUSTOMER_DATA:' || chr_newline;
    ELSE
      internal_messages := 'SEED_DATA:' || chr_newline;
   END IF;
END;

FUNCTION version RETURN VARCHAR2 IS
BEGIN
   RETURN('$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $');
END;


FUNCTION message RETURN VARCHAR2 IS
BEGIN
   RETURN internal_messages;
END;

/* only used in testing */
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

PROCEDURE flush IS
BEGIN
   IF(debug_mode_on) THEN
      dbms_debug(' ');
   END IF;
END;

PROCEDURE printbuf(msg IN VARCHAR2) IS
   i NUMBER;
   len NUMBER;
BEGIN
   len := Length(msg);
   IF(len > 240) THEN
      FOR i IN 1..len LOOP
	 IF(MOD(i, 70) = 0) THEN
	    dbms_debug(''' ||');
	    dbms_debug('''');
	 END IF;
	 dbms_debug(Substr(msg, i, 1));
      END LOOP;
      dbms_debug(' ');
    ELSE
      dbms_debug(msg);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      message('printbuf: ' || Sqlerrm);
      message('while printing: ' || msg);
      RAISE;
END;

/* ------------------------------------------------------------ */
/*  who information                                             */
/* ------------------------------------------------------------ */
FUNCTION customer_mode RETURN BOOLEAN IS
BEGIN
  IF (who_mode = 'customer_data') THEN
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
  IF (customer_mode) THEN
     RETURN 0;
  ELSE
     RETURN 1;
  END IF;
END;

FUNCTION creation_date_f RETURN DATE IS
BEGIN
  IF (customer_mode) THEN
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

PROCEDURE set_session_mode(session_mode IN VARCHAR2) IS
BEGIN
  IF (session_mode NOT IN ('customer_data', 'seed_data')) THEN
     message('bad mode:'|| session_mode);
     message('valid values are: customer_data, seed_data');
     RAISE bad_parameter;
  END IF;
  who_mode := session_mode;

  last_update_login_i := last_update_login_f;
  last_update_date_i := last_update_date_f;
  last_updated_by_i := last_updated_by_f;
  creation_date_i := creation_date_f;
  created_by_i := created_by_f;
END;

/* ------------------------------------------------- */
/* to_string Functions 				     */
/* ------------------------------------------------- */
FUNCTION to_string(flexfield IN flexfield_type)
RETURN VARCHAR2
IS
   sbuf VARCHAR2(2000);
BEGIN
   sbuf := '[Flexfield:' ||
     ' APP=' || flexfield.application_id ||
     ' CODE=' || flexfield.flex_code ||
     ']';
   RETURN sbuf;
END;

FUNCTION to_string(flexfield IN flexfield_type,
		   structure IN structure_type)
RETURN VARCHAR2
IS
   sbuf VARCHAR2(2000);
BEGIN
   sbuf := '[Structure:' ||
     ' ' || to_string(flexfield) ||
     ' STRUCT=' || structure.structure_name ||
     ' SNUM=' || structure.structure_number ||
     ']';
   RETURN sbuf;
END;

FUNCTION to_string(flexfield IN flexfield_type,
		   structure IN structure_type,
		   segment   IN segment_type)
RETURN VARCHAR2
IS
   sbuf VARCHAR2(2000);
BEGIN
   sbuf := '[Segment:' ||
     ' ' || to_string(flexfield, structure) ||
     ' SEG=' || segment.segment_name ||
     ' COL=' || segment.column_name ||
     ']';
   RETURN sbuf;
END;

/* -------------------------------------------------------- */
/* default check Functions				    */
/* -------------------------------------------------------- */

FUNCTION is_default(val IN VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
   IF(val = fnd_api.g_null_char) THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;
END;

FUNCTION is_default(val IN NUMBER) RETURN BOOLEAN
  IS
BEGIN
   IF(val = fnd_api.g_null_num) THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;
END;

PROCEDURE make_default(val IN OUT nocopy VARCHAR2)
  IS
BEGIN
   val := fnd_api.g_null_char;
END;

PROCEDURE make_default(val IN OUT nocopy NUMBER)
  IS
BEGIN
   val := fnd_api.g_null_num;
END;

PROCEDURE set_value(val IN VARCHAR2, var OUT nocopy VARCHAR2)
  IS
BEGIN
   if ( val <> fnd_api.g_null_char ) then
      var := val;
   else
      var := NULL;
   end if;
END;

PROCEDURE set_value(val IN NUMBER, var OUT nocopy NUMBER)
  IS
BEGIN
   if ( val <> fnd_api.g_null_num ) then
      var := val;
   else
      var := NULL;
   end if;
END;

/* ---------------------------------------------------- */
/*      Validate Functions			        */
/* ---------------------------------------------------- */
PROCEDURE check_instantiated(flexfield IN flexfield_type)
  IS
BEGIN
   IF(flexfield.instantiated IS NULL) THEN
      message('cannot perform operation on uninstantiated flexfield');
      message('use new_flexfield or find_flexfield to describe a flexfield');
      RAISE bad_parameter;
    ELSIF(flexfield.instantiated = 'N') THEN
      message('cannot perform operation on uninstantiated flexfield');
      message('use register to instantiate a flexfield');
      RAISE bad_parameter;
    ELSIF(flexfield.instantiated <> 'Y') THEN
      message('inconsistent internal state: instantiated=' ||
	      flexfield.instantiated);
      RAISE bad_parameter;
   END IF;
END;

/* ---------------------------------------------------------------------- */
PROCEDURE check_instantiated(structure IN structure_type)
  IS
BEGIN
   IF(structure.instantiated IS NULL) THEN
      message('cannot perform operation on uninstantiated structure');
      message('use new_structure or find_structure to describe a structure');
      RAISE bad_parameter;
    ELSIF(structure.instantiated = 'N') THEN
      message('cannot perform operation on uninstantiated strucuture');
      message('use add_structure to instantiate a structure');
      RAISE bad_parameter;
    ELSIF(structure.instantiated <> 'Y') THEN
      message('inconsistent internal state: instantiated=' ||
	      structure.instantiated);
      RAISE bad_parameter;
   END IF;
END;

/* ---------------------------------------------------------------------- */
PROCEDURE check_instantiated(segment IN segment_type)
  IS
BEGIN
   IF(segment.instantiated IS NULL) THEN
      message('cannot perform operation on uninstantiated segment');
      message('use new_segment or find_segment to describe a segment');
      RAISE bad_parameter;
    ELSIF(segment.instantiated = 'N') THEN
      message('cannot perform operation on uninstantiated strucuture');
      message('use add_segment to instantiate a segment');
      RAISE bad_parameter;
    ELSIF(segment.instantiated <> 'Y') THEN
      message('inconsistent internal state: instantiated=' ||
	      segment.instantiated);
      RAISE bad_parameter;
   END IF;
END;

/* ------------------------------------------------------------ */
PROCEDURE validate_column_name(flexfield      IN flexfield_type,
			       structure      IN structure_type,
			       segment        IN segment_type,
			       column_name_in IN VARCHAR2)
  IS
     dummy NUMBER;
BEGIN
   IF(NOT do_validation) THEN
      RETURN;
   END IF;

   -- check column name in table
   SELECT NULL
     INTO dummy
     FROM fnd_columns c    --, fnd_lookups ct
     WHERE c.application_id = flexfield.table_application_id
     AND c.table_id = flexfield.table_id
     AND c.column_name = column_name_in
--     AND c.flexfield_application_id = flexfield.application_id
--     AND c.flexfield_name = flexfield.flex_code
     AND c.flexfield_usage_code = 'K'
--     AND ct.lookup_type = 'COLUMN_TYPE'
--     AND ct.lookup_code = column_type
     -- check that it is not already in use
     AND NOT EXISTS (SELECT NULL FROM fnd_id_flex_segments
		     WHERE application_id = flexfield.application_id
		     AND id_flex_code = flexfield.flex_code
		     AND id_flex_num = structure.structure_number
		     AND application_column_name = c.column_name)
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

EXCEPTION
   WHEN OTHERS THEN
      message('validate column name: ' || column_name_in);
      message(to_string(flexfield, structure, segment));
      RAISE;
END;

/* ------------------------------------------------------------ */
PROCEDURE validate_valueset(flexfield IN flexfield_type,
			    structure IN structure_type,
			    segment   IN segment_type,
			    vset      IN NUMBER)
  IS
     application_column_size_i fnd_columns.width%TYPE;
     application_column_type_i fnd_columns.column_type%TYPE;
     dummy NUMBER;
BEGIN
   IF(NOT do_validation) THEN
      RETURN;
   END IF;

   BEGIN
      SELECT width, column_type
	INTO application_column_size_i,
	application_column_type_i
	FROM fnd_columns
	WHERE application_id = flexfield.table_application_id
	AND table_id = flexfield.table_id
	AND column_name = segment.column_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   EXCEPTION
      WHEN no_data_found THEN
	 message('error looking up table information');
	 RAISE;
   END;

   SELECT NULL
     INTO dummy
     FROM fnd_flex_value_sets v,
     fnd_flex_validation_tables t
     WHERE v.flex_value_set_id = vset
     AND v.flex_value_set_id = t.flex_value_set_id (+)
     AND (flexfield.allow_id_value_sets = 'Y'
	  OR (flexfield.allow_id_value_sets = 'N' AND t.id_column_name IS NULL))
     AND v.flex_value_set_name NOT LIKE '$FLEX$.%'
     AND ((application_column_type_i IN ('C', 'V')
          OR v.validation_type = 'U'
	  OR application_column_type_i = Nvl(t.id_column_type,
		   Decode(v.format_type,
	  'M', 'N', 'T', 'D', 't', 'D', 'X', 'D', 'Y', 'D', 'Z', 'D',
	  v.format_type))))
     AND (application_column_type_i = 'D'
	  OR application_column_size_i >= Nvl(id_column_size, maximum_size))
     AND (validation_type <> 'D' OR EXISTS
	  (SELECT NULL FROM fnd_id_flex_segments s
	   WHERE application_id = flexfield.application_id
	   AND id_flex_code = flexfield.flex_code
	   AND id_flex_num = structure.structure_number
	   AND s.flex_value_set_id = v.parent_flex_value_set_id
	   AND segment_num < segment.segment_number))
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
EXCEPTION
   WHEN OTHERS THEN
      message('validate_valueset: ' || vset);
      message('segment num: ' || segment.segment_number);
      RAISE;
END;


/* ------------------------------------------------------------ */
PROCEDURE validate_flexfield(
                   flexfield IN OUT nocopy flexfield_type)
IS
BEGIN
  fnd_flex_types.validate_yes_no_flag(flexfield.dynamic_inserts);
  fnd_flex_types.validate_yes_no_flag(flexfield.allow_id_value_sets);
  fnd_flex_types.validate_yes_no_flag(flexfield.index_flag);
EXCEPTION
  WHEN OTHERS THEN
     message('invalid parameter in flexfield');
     message('validate flexfield : Error ' ||Sqlerrm);
     message(to_string(flexfield));
     RAISE bad_parameter;
END;



/* ------------------------------------------------------------ */
PROCEDURE validate_structure(
                  flexfield IN flexfield_type,
		  structure IN OUT nocopy structure_type)
IS
BEGIN
  IF (is_default(structure.structure_number))
     OR (structure.structure_number IS NULL) THEN
     message('validate structure : you must pass a structure number');
     RAISE bad_parameter;
  END IF;

  IF (is_default(structure.structure_name))
     OR (structure.structure_name IS NULL) THEN
     message('validate structure : you must pass a structure name');
     RAISE bad_parameter;
  END IF;

  IF is_default(structure.description) THEN
     structure.description := NULL;
  END IF;

  IF is_default(structure.view_name) THEN
     structure.view_name := NULL;
  END IF;

  fnd_flex_types.validate_yes_no_flag(structure.freeze_flag);

  fnd_flex_types.validate_yes_no_flag(structure.enabled_flag);

  IF (is_default(structure.segment_separator))
     OR (structure.segment_separator IS NULL) THEN
     message('validate structure : you must pass a segment_separator');
     RAISE bad_parameter;
  END IF;

  fnd_flex_types.validate_yes_no_flag(structure.cross_val_flag);

  fnd_flex_types.validate_yes_no_flag(structure.freeze_rollup_flag);

  fnd_flex_types.validate_yes_no_flag(structure.dynamic_insert_flag);

  fnd_flex_types.validate_yes_no_flag(structure.shorthand_enabled_flag);

  IF is_default(structure.shorthand_prompt) THEN
     structure.shorthand_prompt := NULL;
  END IF;

  IF is_default(structure.shorthand_length) THEN
     structure.shorthand_length := NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     message('invalid parameter in structure');
     message('validate structure : Error ' ||Sqlerrm);
     message(to_string(flexfield,structure));
     RAISE bad_parameter;
END;

/* ------------------------------------------------------------ */
PROCEDURE validate_segment(
                  flexfield IN flexfield_type,
		  structure IN structure_type,
                  segment IN OUT nocopy segment_type)
IS
BEGIN
  IF (is_default(segment.segment_name))
     OR (segment.segment_name IS NULL) THEN
     message('validate segment : you must pass a segment name');
     RAISE bad_parameter;
  END IF;

  IF is_default(segment.description) THEN
     segment.description := NULL;
  END IF;

  validate_column_name(flexfield,structure,segment,segment.column_name);

  IF (is_default(segment.segment_number))
     OR (segment.segment_number IS NULL) THEN
     message('validate segment : you must pass a segment number');
     RAISE bad_parameter;
  END IF;

  fnd_flex_types.validate_yes_no_flag(segment.enabled_flag);

  fnd_flex_types.validate_yes_no_flag(segment.displayed_flag);

  fnd_flex_types.validate_yes_no_flag(segment.indexed_flag);

  IF is_default(segment.value_set_id) THEN
     segment.value_set_id := NULL;
     segment.value_set_name := NULL;
  ELSIF (segment.value_set_id IS NOT NULL) THEN
     validate_valueset(flexfield,structure,segment,segment.value_set_id);
  END IF;

  IF is_default(segment.default_type) THEN
     segment.default_type := NULL;
  ELSIF segment.default_type IS NOT NULL THEN
     fnd_flex_types.validate_default_type(segment.default_type);
  END IF;

  IF is_default(segment.default_value) THEN
     segment.default_value := NULL;
  END IF;

  fnd_flex_types.validate_yes_no_flag(segment.required_flag);

  fnd_flex_types.validate_yes_no_flag(segment.security_flag);

  IF is_default(segment.range_code) THEN
     segment.range_code := NULL;
  ELSIF segment.range_code IS NOT NULL THEN
     fnd_flex_types.validate_range_code(segment.range_code);
  END IF;

  IF (is_default(segment.display_size))
     OR (segment.display_size IS NULL) THEN
     message('validate segment : you must pass a display_size');
     RAISE bad_parameter;
  END IF;

  IF (is_default(segment.description_size))
     OR (segment.description_size IS NULL) THEN
     message('validate segment : you must pass a description_size');
     RAISE bad_parameter;
  END IF;

  IF (is_default(segment.concat_size))
     OR (segment.concat_size IS NULL) THEN
     message('validate segment : you must pass a concat_size');
     RAISE bad_parameter;
  END IF;

  IF (is_default(segment.lov_prompt))
     OR (segment.lov_prompt IS NULL) THEN
     message('validate segment : you must pass a lov_prompt');
     RAISE bad_parameter;
  END IF;

  IF (is_default(segment.window_prompt))
     OR (segment.window_prompt IS NULL) THEN
     message('validate segment : you must pass a window_prompt');
     RAISE bad_parameter;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     message('invalid parameter in segment');
     message('validate segment : Error ' ||Sqlerrm);
     message(to_string(flexfield,structure,segment));
     RAISE bad_parameter;
END;

/* ------------------------------------------------------------ */
FUNCTION check_duplicate_structure(
		flexfield IN flexfield_type,
		structure_name IN fnd_id_flex_structures_vl.id_flex_structure_name%TYPE)
RETURN NUMBER
IS
   row_count NUMBER;
BEGIN
  --
  -- Check for duplicate structure name.
  --
  SELECT count(*)
    INTO row_count
    FROM fnd_id_flex_structures_vl
   WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND id_flex_structure_name = structure_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
  RETURN row_count;
END;

/* ------------------------------------------------------------ */
FUNCTION check_duplicate_segment(
		flexfield IN flexfield_type,
		structure IN structure_type,
		segment_name IN fnd_id_flex_segments_vl.segment_name%TYPE)
RETURN NUMBER
IS
   row_count NUMBER;
BEGIN
  --
  -- Check for duplicate segment name.
  --
  SELECT count(*)
    INTO row_count
    FROM fnd_id_flex_segments_vl v
   WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND id_flex_num = structure.structure_number
     AND v.segment_name = check_duplicate_segment.segment_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
  RETURN row_count;
END;

/* ---------------------------------------------------------------------- */
/*        Name to Id conversion functions			          */
/* ---------------------------------------------------------------------- */
FUNCTION application_id_f(application_short_name_in IN VARCHAR2)
RETURN fnd_application.application_id%TYPE
IS
   application_id_ret fnd_application.application_id%TYPE;
BEGIN
  SELECT application_id
    INTO application_id_ret
    FROM fnd_application
   WHERE application_short_name = application_short_name_in
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

  RETURN application_id_ret;
EXCEPTION
   WHEN OTHERS THEN
      IF(application_short_name_in IS NULL) THEN
	 message('must specify appl_short_name');
      ELSE
	 message('error locating application id');
	 message('appl_short_name:' || application_short_name_in);
      END IF;
      RAISE bad_parameter;
END;

/* ------------------------------------------------------------ */
FUNCTION table_id_f(application_id_in IN fnd_tables.application_id%TYPE,
		    table_name_in     IN VARCHAR2)
  RETURN fnd_tables.table_id%TYPE
  IS
     table_id_ret fnd_tables.table_id%TYPE;
BEGIN
   SELECT table_id
     INTO table_id_ret
     FROM fnd_tables
     WHERE table_name = table_name_in
     AND application_id = application_id_in
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   RETURN table_id_ret;
EXCEPTION
   WHEN no_data_found THEN
      message('bad table name:' || table_name_in);
      RAISE;
END;

/* ------------------------------------------------------------ */
FUNCTION value_set_id_f(value_set_name IN VARCHAR2)
  RETURN fnd_flex_value_sets.flex_value_set_id%TYPE
  IS
     value_set_id fnd_flex_value_sets.flex_value_set_id%TYPE;
BEGIN
   IF(value_set_name IS NULL) THEN
      RETURN NULL;
   END IF;

   SELECT flex_value_set_id
     INTO value_set_id
     FROM fnd_flex_value_sets
     WHERE flex_value_set_name = value_set_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   RETURN value_set_id;
EXCEPTION
   WHEN no_data_found THEN
      message('bad valueset name:' || value_set_name);
      RAISE;
END;



/* ---------------------------------------------------------------------- */
/*  Set - Unset Column Functions					  */
/* ---------------------------------------------------------------------- */
PROCEDURE set_structure_column(flexfield         IN flexfield_type,
			       structure_column  IN VARCHAR2)
  IS
BEGIN
   IF(structure_column IS NOT NULL) THEN
      UPDATE fnd_columns SET
	flexfield_usage_code = 'S',
--	flexfield_application_id = flexfield.application_id,
--	flexfield_name = flexfield.flex_code,
	last_update_date =  last_update_date_i,
	last_updated_by = last_updated_by_i,
	last_update_login = last_update_login_i
	WHERE application_id = flexfield.table_application_id
	AND table_id = flexfield.table_id
	AND column_name = structure_column
	AND flexfield_usage_code = 'N'
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
      IF(SQL%notfound) THEN
	 message('could not acquire column');
	 message('structure column=' || structure_column);
	 RAISE no_data_found;
      END IF;
   END IF;
END;

/* --------------------------------------------------------------- */
PROCEDURE unset_structure_column(flexfield         IN flexfield_type)
  IS
BEGIN
   IF(flexfield.structure_column IS NOT NULL) THEN
      UPDATE fnd_columns SET
	flexfield_usage_code = 'N',
--	flexfield_application_id = flexfield.application_id,
--	flexfield_name = flexfield.flex_code,
	last_update_date =  last_update_date_i,
	last_updated_by = last_updated_by_i,
	last_update_login = last_update_login_i
	WHERE application_id = flexfield.table_application_id
	AND table_id = flexfield.table_id
	AND column_name = flexfield.structure_column
	AND flexfield_usage_code = 'S'
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
      IF(SQL%notfound) THEN
	 message('could not acquire column');
	 message('structure column=' || flexfield.structure_column);
	 RAISE no_data_found;
      END IF;
   END IF;
END;

/* ---------------------------------------------------------------------- */
PROCEDURE set_id_column(flexfield IN flexfield_type,
			id_column IN VARCHAR2)
  IS
BEGIN
   UPDATE fnd_columns SET
     flexfield_usage_code = 'I',
--     flexfield_application_id = flexfield.application_id,
--     flexfield_name = flexfield.flex_code,
     last_update_date =  last_update_date_i,
     last_updated_by = last_updated_by_i,
     last_update_login = last_update_login_i
     WHERE application_id = flexfield.table_application_id
     AND table_id = flexfield.table_id
     AND column_name = id_column
     AND flexfield_usage_code = 'N'
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   IF(SQL%notfound) THEN
      message('could not acquire column');
      message('unique id column=' || id_column);
      RAISE no_data_found;
   END IF;
END;

/* ---------------------------------------------------------------------- */
PROCEDURE unset_id_column(flexfield IN flexfield_type)
  IS
BEGIN
   UPDATE fnd_columns SET
     flexfield_usage_code = 'N',
--     flexfield_application_id = flexfield.application_id,
--     flexfield_name = flexfield.flex_code,
     last_update_date =  last_update_date_i,
     last_updated_by = last_updated_by_i,
     last_update_login = last_update_login_i
     WHERE application_id = flexfield.table_application_id
     AND table_id = flexfield.table_id
     AND column_name = flexfield.unique_id_column
     AND flexfield_usage_code = 'I'
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   IF(SQL%notfound) THEN
      message('could not acquire column');
      message('unique id column=' || flexfield.unique_id_column);
      RAISE no_data_found;
   END IF;
END;


/* ---------------------------------------------------------------------- */
/*  Compose Functions */
/* ---------------------------------------------------------------------- */
-- compose(a,b) = ( b ? b : a )
-- dcnt is count of number of defaults used
FUNCTION compose(orig  IN VARCHAR2,
		 chng  IN VARCHAR2,
		 dcnt  IN OUT nocopy NUMBER) RETURN VARCHAR2
  IS
BEGIN
   IF(chng = fnd_api.g_null_char) THEN
      dcnt := dcnt + 1;
      RETURN orig;
    ELSE
      RETURN chng;
   END IF;
END;

/* ---------------------------------------------------------------------- */
-- dcnt is count of number of defaults used
FUNCTION compose(orig  IN NUMBER,
		 chng  IN NUMBER,
		 dcnt  IN OUT nocopy NUMBER) RETURN NUMBER
  IS
BEGIN
   IF(chng = fnd_api.g_null_num) THEN
      dcnt := dcnt + 1;
      RETURN orig;
    ELSE
      RETURN chng;
   END IF;
END;

/* ---------------------------------------------------------------------- */
-- for (almost) every x in F: F.x = compose(F1.x, F2.x)

FUNCTION compose(f1 flexfield_type,
		 f2 flexfield_type,
		 cnt OUT nocopy NUMBER) RETURN flexfield_type
  IS
     f flexfield_type;
     dcnt NUMBER := 0;
BEGIN
   f.instantiated                := f1.instantiated;
   -- PK
   f.application_id              := f1.application_id;
   f.appl_short_name             := f1.appl_short_name;
   f.flex_code                   := f1.flex_code;

   f.flex_title                  := compose(f1.flex_title, f2.flex_title, dcnt);
   f.description                 := compose(f1.description, f2.description, dcnt);
   f.table_appl_short_name       := compose(f1.table_appl_short_name, f2.table_appl_short_name, dcnt);
   f.table_name                  := compose(f1.table_name, f2.table_name, dcnt);
   f.concatenated_segs_view_name := compose(f1.concatenated_segs_view_name, f2.concatenated_segs_view_name, dcnt);
   f.unique_id_column            := compose(f1.unique_id_column, f2.unique_id_column, dcnt);
   f.structure_column            := compose(f1.structure_column, f2.structure_column, dcnt);
   f.dynamic_inserts             := compose(f1.dynamic_inserts, f2.dynamic_inserts, dcnt);
   f.allow_id_value_sets         := compose(f1.allow_id_value_sets, f2.allow_id_value_sets, dcnt);
   f.index_flag                  := compose(f1.index_flag, f2.index_flag, dcnt);
   f.concat_seg_len_max          := compose(f1.concat_seg_len_max, f2.concat_seg_len_max, dcnt);
   f.concat_len_warning          := compose(f1.concat_len_warning, f2.concat_len_warning, dcnt);

   f.table_application_id        := compose(f1.table_application_id, f2.table_application_id, dcnt);
   f.table_id                    := compose(f1.table_id, f2.table_id, dcnt);

   cnt := dcnt;
   RETURN f;
END;

/* ---------------------------------------------------------------------- */
FUNCTION compose(f1 flexfield_type,
		 f2 flexfield_type) RETURN flexfield_type
  IS
     cnt NUMBER := 0;
BEGIN
   RETURN compose(f1, f2, cnt);
END;

/* ---------------------------------------------------------------------- */
FUNCTION compose(s1 structure_type,
		 s2 structure_type,
		 cnt OUT nocopy NUMBER) RETURN structure_type
  IS
     s structure_type;
     dcnt NUMBER := 0;
BEGIN
   s.instantiated           := s1.instantiated;
   -- PK
   s.structure_number       := s1.structure_number;

   s.structure_code         := compose(s1.structure_code, s2.structure_code, dcnt);
   s.structure_name         := compose(s1.structure_name, s2.structure_name, dcnt);
   s.description            := compose(s1.description, s2.description, dcnt);
   s.view_name              := compose(s1.view_name, s2.view_name, dcnt);
   s.freeze_flag            := compose(s1.freeze_flag, s2.freeze_flag, dcnt);
   s.enabled_flag           := compose(s1.enabled_flag, s2.enabled_flag, dcnt);
   s.segment_separator      := compose(s1.segment_separator, s2.segment_separator, dcnt);
   s.cross_val_flag         := compose(s1.cross_val_flag, s2.cross_val_flag, dcnt);
   s.freeze_rollup_flag     := compose(s1.freeze_rollup_flag, s2.freeze_rollup_flag, dcnt);
   s.dynamic_insert_flag    := compose(s1.dynamic_insert_flag, s2.dynamic_insert_flag, dcnt);
   s.shorthand_enabled_flag := compose(s1.shorthand_enabled_flag, s2.shorthand_enabled_flag, dcnt);
   s.shorthand_prompt       := compose(s1.shorthand_prompt, s2.shorthand_prompt, dcnt);
   s.shorthand_length       := compose(s1.shorthand_length, s2.shorthand_length, dcnt);

   cnt := dcnt;
   RETURN s;
END;

/* ---------------------------------------------------------------------- */
FUNCTION compose(s1 structure_type,
		 s2 structure_type) RETURN structure_type
  IS
     cnt NUMBER := 0;
BEGIN
   RETURN compose(s1, s2, cnt);
END;


/* ---------------------------------------------------------------------- */
FUNCTION compose(s1 segment_type,
		 s2 segment_type,
		 cnt OUT nocopy NUMBER) RETURN segment_type
  IS
     s segment_type;
     dcnt NUMBER := 0;
BEGIN
   s.instantiated              := s1.instantiated;
   -- PK
   s.column_name               := s1.column_name;

   s.segment_name              := compose(s1.segment_name, s2.segment_name, dcnt);
   s.description               := compose(s1.description, s2.description, dcnt);
   s.segment_number            := compose(s1.segment_number, s2.segment_number, dcnt);
   s.enabled_flag              := compose(s1.enabled_flag, s2.enabled_flag, dcnt);
   s.displayed_flag            := compose(s1.displayed_flag, s2.displayed_flag, dcnt);
   s.indexed_flag              := compose(s1.indexed_flag, s2.indexed_flag, dcnt);
   s.value_set_id              := compose(s1.value_set_id, s2.value_set_id, dcnt);
   s.value_set_name            := compose(s1.value_set_name, s2.value_set_name, dcnt);
   s.default_type              := compose(s1.default_type, s2.default_type, dcnt);
   s.default_value             := compose(s1.default_value, s2.default_value, dcnt);
   s.required_flag             := compose(s1.required_flag, s2.required_flag, dcnt);
   s.security_flag             := compose(s1.security_flag, s2.security_flag, dcnt);

   s.range_code                := compose(s1.range_code, s2.range_code, dcnt);
   s.display_size              := compose(s1.display_size, s2.display_size, dcnt);
   s.description_size          := compose(s1.description_size, s2.description_size, dcnt);
   s.concat_size               := compose(s1.concat_size, s2.concat_size, dcnt);
   s.lov_prompt                := compose(s1.lov_prompt, s2.lov_prompt, dcnt);
   s.window_prompt             := compose(s1.window_prompt, s2.window_prompt, dcnt);
   s.runtime_property_function := compose(s1.runtime_property_function,
					  s2.runtime_property_function, dcnt);
   s.additional_where_clause   := compose(s1.additional_where_clause,
                                          s2.additional_where_clause, dcnt);
   cnt := dcnt;
   RETURN s;
END;

/* ---------------------------------------------------------------------- */
FUNCTION compose(s1 segment_type,
		 s2 segment_type) RETURN segment_type
  IS
     cnt NUMBER := 0;
BEGIN
   RETURN compose(s1, s2, cnt);
END;

/* ---------------------------------------------------------------------- */
/*       Internal Structure Add 					  */
/* ---------------------------------------------------------------------- */
PROCEDURE add_structure_internal
  (appl_short_name        IN VARCHAR2,
   flex_code              IN VARCHAR2,

   structure_code         IN VARCHAR2,
   structure_title        IN VARCHAR2,
   description            IN VARCHAR2,
   view_name              IN VARCHAR2,
   freeze_flag            IN VARCHAR2 DEFAULT 'N',
   enabled_flag           IN VARCHAR2 DEFAULT 'N',
   segment_separator      IN VARCHAR2,
   cross_val_flag         IN VARCHAR2,
   freeze_rollup_flag     IN VARCHAR2 DEFAULT 'N',
   dynamic_insert_flag    IN VARCHAR2 DEFAULT 'N',
   shorthand_enabled_flag IN VARCHAR2 DEFAULT 'N',
   shorthand_prompt       IN VARCHAR2,
   shorthand_length       IN NUMBER,
   flex_num               IN NUMBER)
  IS
     application_id_i fnd_id_flexs.application_id%TYPE;
     rowid_i VARCHAR2(64);
BEGIN
   message_init;
   application_id_i := application_id_f(appl_short_name);

   fnd_id_flex_structures_pkg.insert_row(
		      X_ROWID => rowid_i,
		      X_APPLICATION_ID  => application_id_i,
		      X_ID_FLEX_CODE => flex_code,
		      X_ID_FLEX_NUM => flex_num,
		      X_ID_FLEX_STRUCTURE_CODE => structure_code,
		      X_CONCATENATED_SEGMENT_DELIMIT => segment_separator,
		      X_CROSS_SEGMENT_VALIDATION_FLA => cross_val_flag,
		      X_DYNAMIC_INSERTS_ALLOWED_FLAG => dynamic_insert_flag,
		      X_ENABLED_FLAG => enabled_flag,
		      X_FREEZE_FLEX_DEFINITION_FLAG => freeze_flag,
		      X_FREEZE_STRUCTURED_HIER_FLAG => freeze_rollup_flag,
		      X_SHORTHAND_ENABLED_FLAG => shorthand_enabled_flag,
		      X_SHORTHAND_LENGTH => shorthand_length,
		      X_STRUCTURE_VIEW_NAME => view_name,
		      X_ID_FLEX_STRUCTURE_NAME => structure_title,
		      X_DESCRIPTION => description,
		      X_SHORTHAND_PROMPT => shorthand_prompt,
		      X_CREATION_DATE => creation_date_i,
		      X_CREATED_BY => created_by_i,
		      X_LAST_UPDATE_DATE => last_update_date_i,
		      X_LAST_UPDATED_BY => last_updated_by_i,
		      X_LAST_UPDATE_LOGIN => last_update_login_i);

   --
   -- Copied from FNDFFMIS.STRUCT_PRIVATE.populate_workflow_processes.
   --
   IF (application_id_i <> 101 OR
       flex_code <> 'GL#' OR
       flex_num = 101) THEN
      NULL;
    ELSE
      INSERT INTO FND_FLEX_WORKFLOW_PROCESSES
	(APPLICATION_ID, ID_FLEX_CODE, ID_FLEX_NUM, WF_ITEM_TYPE,
	 WF_PROCESS_NAME, LAST_UPDATE_DATE, LAST_UPDATED_BY,
	 CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN)
	SELECT application_id_i, flex_code,
	flex_num, FWP.WF_ITEM_TYPE,
	'DEFAULT_ACCOUNT_GENERATION',
	last_update_date_i, last_updated_by_i, creation_date_i,
	created_by_i, last_update_login_i
	FROM FND_FLEX_WORKFLOW_PROCESSES FWP
	WHERE FWP.APPLICATION_ID = application_id_i
	AND FWP.ID_FLEX_CODE = flex_code
	AND FWP.ID_FLEX_NUM = 101
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      message('add structure: ' || Sqlerrm);
      RAISE;
END;


/* ---------------------------------------------------------------------- */
FUNCTION has_defaults(flexfield IN flexfield_type)
  RETURN BOOLEAN
  IS
     cnt NUMBER;
     f flexfield_type;
BEGIN
   f := compose(flexfield, flexfield, cnt);
   IF(cnt > 0) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
   END IF;
END;

/* ------------------------------------------------------------ */
/*  public functions                                            */
/* ------------------------------------------------------------ */
/* ------------------------------------------------------------ */
/*  FLEXFIELD RELATED FUNCTIONS */
/* ------------------------------------------------------------ */
FUNCTION flexfield_exists(appl_short_name    IN VARCHAR2,
			  flex_code          IN VARCHAR2 DEFAULT NULL,
			  flex_title         IN VARCHAR2 DEFAULT NULL)
  RETURN BOOLEAN
  IS
     cnt NUMBER;
     application_id_i fnd_id_flexs.application_id%TYPE;
BEGIN
   message_init;
   application_id_i := application_id_f(appl_short_name);
   SELECT COUNT(*)
     INTO cnt
     FROM fnd_id_flexs
     WHERE application_id = application_id_i
     AND (id_flex_code = flex_code
	  OR id_flex_name = flex_title)
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   IF(cnt > 0) THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      message('flexfield_exists: ' || Sqlerrm);
      RAISE;
END;

/* ---------------------------------------------------------------------- */
FUNCTION new_flexfield
  (appl_short_name             IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   flex_code                   IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   flex_title                  IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   description                 IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   table_appl_short_name       IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   table_name                  IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   unique_id_column            IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   structure_column            IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   dynamic_inserts             IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   allow_id_value_sets         IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   index_flag                  IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   concat_seg_len_max          IN NUMBER   DEFAULT fnd_api.g_null_num,
   concat_len_warning          IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   concatenated_segs_view_name IN VARCHAR2 DEFAULT fnd_api.g_null_char)
RETURN flexfield_type
IS
     flexfield flexfield_type;
BEGIN
   message_init;
   flexfield.instantiated := 'N';
   set_value(appl_short_name, flexfield.appl_short_name);
   flexfield.application_id := application_id_f(appl_short_name);
   set_value(flex_code, flexfield.flex_code);
   set_value(flex_title, flexfield.flex_title);
   set_value(description, flexfield.description);
   set_value(table_appl_short_name, flexfield.table_appl_short_name);
   set_value(table_name, flexfield.table_name);
   set_value(unique_id_column, flexfield.unique_id_column);
   set_value(structure_column, flexfield.structure_column);
   set_value(dynamic_inserts, flexfield.dynamic_inserts);
   set_value(allow_id_value_sets, flexfield.allow_id_value_sets);
   set_value(index_flag, flexfield.index_flag);
   set_value(concat_seg_len_max, flexfield.concat_seg_len_max);
   set_value(concat_len_warning, flexfield.concat_len_warning);
   set_value(concatenated_segs_view_name, flexfield.concatenated_segs_view_name);

   IF (NOT is_default(table_appl_short_name)) THEN
      flexfield.table_application_id := application_id_f(table_appl_short_name);
      IF (NOT is_default(table_name)) THEN
	 flexfield.table_id := table_id_f(flexfield.table_application_id,
					  table_name);
       ELSE
	 make_default(flexfield.table_id);
      END IF;
    ELSE
      make_default(flexfield.table_application_id);
   END IF;
   last_flexfield := flexfield;
   println('created flexfield: ' || to_string(flexfield));
   RETURN flexfield;
EXCEPTION
   WHEN OTHERS THEN
      message('new flexfield: ' || Sqlerrm);
      RAISE;
END;

/* ---------------------------------------------------------------------- */

FUNCTION find_flexfield_notab(appl_short_name    IN VARCHAR2,
                        flex_code          IN VARCHAR2)
RETURN flexfield_type
IS
   flexfield flexfield_type;
BEGIN
   message_init;
   flexfield.application_id := application_id_f(appl_short_name);
   flexfield.flex_code := flex_code;


   SELECT 'Y',
     find_flexfield_notab.appl_short_name,
     id_flex_code,
     id_flex_name,
     idf.description,
     tap.application_short_name,
     application_table_name,
     concatenated_segs_view_name,
     unique_id_column_name,
     set_defining_column_name structure_column,
     dynamic_inserts_feasible_flag,
     allow_id_valuesets,
     index_flag,
     maximum_concatenation_len,
     concatenation_len_warning,
     idf.application_id,
     tap.application_id,
     0
     INTO flexfield
     FROM fnd_id_flexs idf, fnd_application tap
     WHERE idf.application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND idf.table_application_id = tap.application_id
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;


   last_flexfield := flexfield;
   RETURN flexfield;
EXCEPTION
   WHEN OTHERS THEN
      message('find_flexfield_notab: ' || Sqlerrm);
      RAISE;
END;


/* ---------------------------------------------------------------------- */
FUNCTION find_flexfield(appl_short_name    IN VARCHAR2,
			flex_code          IN VARCHAR2)
RETURN flexfield_type
IS
   flexfield flexfield_type;
BEGIN
   message_init;
   flexfield.application_id := application_id_f(appl_short_name);
   flexfield.flex_code := flex_code;

   SELECT 'Y',
     find_flexfield.appl_short_name,
     id_flex_code,
     id_flex_name,
     idf.description,
     tap.application_short_name,
     application_table_name,
     concatenated_segs_view_name,
     unique_id_column_name,
     set_defining_column_name structure_column,
     dynamic_inserts_feasible_flag,
     allow_id_valuesets,
     index_flag,
     maximum_concatenation_len,
     concatenation_len_warning,
     idf.application_id,
     tap.application_id,
     tab.table_id
     INTO flexfield
     FROM fnd_id_flexs idf, fnd_application tap, fnd_tables tab
     WHERE idf.application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND idf.table_application_id = tap.application_id
     AND tab.application_id = table_application_id
     AND tab.table_name = application_table_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   last_flexfield := flexfield;
   RETURN flexfield;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      flexfield := find_flexfield_notab(appl_short_name => appl_short_name,
                               flex_code => flex_code);
      RETURN flexfield;
   WHEN OTHERS THEN
      message('find_flexfield: ' || Sqlerrm);
      RAISE;
END;


/* ---------------------------------------------------------------------- */
--
-- create a new key flex
--
PROCEDURE register(flexfield             IN OUT nocopy flexfield_type,
		   enable_columns        IN VARCHAR2 DEFAULT 'Y')
  IS
BEGIN
   message_init;

   IF(has_defaults(flexfield)) THEN
      message('some data missing in flexfield');
      RAISE bad_parameter;
   END IF;

   validate_flexfield(flexfield);
   INSERT
     INTO fnd_id_flexs (application_id,
			id_flex_code,
			id_flex_name,

			table_application_id,
			application_table_name,
                        concatenated_segs_view_name,
			allow_id_valuesets,
			dynamic_inserts_feasible_flag,
			index_flag,
			unique_id_column_name,
			description,
			application_table_type,
			set_defining_column_name,
			maximum_concatenation_len,
			concatenation_len_warning,

			last_update_date,
			last_updated_by,
			creation_date,
			created_by,
			last_update_login)
     VALUES (flexfield.application_id,
	     flexfield.flex_code,
	     flexfield.flex_title,

	     flexfield.table_application_id,
	     flexfield.table_name,
             flexfield.concatenated_segs_view_name,
	     flexfield.allow_id_value_sets,
	     flexfield.dynamic_inserts,
	     flexfield.index_flag,
	     flexfield.unique_id_column,
	     flexfield.description,
	     NULL,
	     flexfield.structure_column,
	     flexfield.concat_seg_len_max,
	     flexfield.concat_len_warning,

	     last_update_date_i,
	     last_updated_by_i,
	     creation_date_i,
	     created_by_i,
	     last_update_login_i);

   BEGIN
      --
      -- If the user has specified a set defining column
      -- mark the column.
      --
      set_structure_column(flexfield, flexfield.structure_column);
      --
      -- Mark the unique ID column
      --
      set_id_column(flexfield, flexfield.unique_id_column);

      --
      -- Mark all unmarked "SEGMENT" columns as potential
      -- Key flexfield segment columns. These can later be
      -- changed in the COLUMN block.
      --
      IF(enable_columns = 'Y') THEN
	 UPDATE fnd_columns SET
	   flexfield_usage_code = 'K',
--	   flexfield_application_id = flexfield.application_id,
--	   flexfield_name = flexfield.flex_code,
	   last_update_date =  last_update_date_i,
	   last_updated_by = last_updated_by_i,
	   last_update_login = last_update_login_i
	   WHERE application_id = flexfield.table_application_id
	   AND table_id = flexfield.table_id
	   AND column_name like 'SEGMENT%'
	   AND rtrim(column_name, '0123456789') = 'SEGMENT'
	   AND flexfield_usage_code = 'N'
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
      END IF;
      --
      -- Create a default structure (# 101) for the key
      -- flexfield.
      --
      add_structure_internal(appl_short_name => flexfield.appl_short_name,
			     flex_code => flexfield.flex_code,
			     structure_code => REPLACE(Upper(flexfield.flex_title),
						       ' ','_'),
			     structure_title => flexfield.flex_title,
			     description => NULL,
			     view_name => NULL,
			     freeze_flag => 'Y',
			     enabled_flag => 'Y',
			     segment_separator => '.',
			     cross_val_flag => 'N',
			     freeze_rollup_flag => 'N',
			     dynamic_insert_flag => 'N',
			     shorthand_enabled_flag => 'N',
			     shorthand_prompt => NULL,
			     shorthand_length => NULL,
			     flex_num => 101);
   END;
   flexfield.instantiated := 'Y';

   last_flexfield := flexfield;
   println('added flexfield: ' || to_string(flexfield));
EXCEPTION
   WHEN OTHERS THEN
      message('register: ' || Sqlerrm);
      message(to_string(flexfield));
      RAISE;
END register;

/* ---------------------------------------------------------------------- */
PROCEDURE enable_column(flexfield             IN flexfield_type,
			column_name           IN VARCHAR2,
			enable_flag           IN VARCHAR2 DEFAULT 'Y')
  IS
BEGIN
   message_init;
   check_instantiated(flexfield);

   IF(enable_flag = 'Y') THEN
      UPDATE fnd_columns SET
	flexfield_usage_code = 'K',
--	flexfield_application_id = flexfield.application_id,
--	flexfield_name = flexfield.flex_code,
	last_update_date =  last_update_date_i,
	last_updated_by = last_updated_by_i,
	last_update_login = last_update_login_i
	WHERE application_id = flexfield.table_application_id
	AND table_id = flexfield.table_id
	AND fnd_columns.column_name = enable_column.column_name
   	AND flexfield_usage_code = 'N'
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
      IF(SQL%notfound) THEN
	 message('could not acquire column');
	 message('column name=' || column_name);
	 message(to_string(flexfield));
	 RAISE no_data_found;
      END IF;
    ELSE
      UPDATE fnd_columns SET
	flexfield_usage_code = 'N',
--	flexfield_application_id = NULL,
--	flexfield_name = NULL,
	last_update_date =  last_update_date_i,
	last_updated_by = last_updated_by_i,
	last_update_login = last_update_login_i
	WHERE application_id = flexfield.table_application_id
	AND table_id = flexfield.table_id
	AND fnd_columns.column_name = enable_column.column_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
--	AND flexfield_application_id = flexfield.application_id
--	AND flexfield_name = flexfield.flex_code
      IF(SQL%notfound) THEN
	 message('could not release column');
	 message('column=' || column_name);
	 RAISE no_data_found;
      END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      message('enable_column: ' || Sqlerrm);
      message(to_string(flexfield));
      message('column name=' || column_name);
      RAISE;
END;

/* ---------------------------------------------------------------------- */
PROCEDURE enable_columns_like(flexfield            IN flexfield_type,
			      pattern               IN VARCHAR2,
			      enable_flag           IN VARCHAR2 DEFAULT 'Y')
  IS
BEGIN
   message_init;
   check_instantiated(flexfield);

   RAISE bad_parameter;
END;

/* ---------------------------------------------------------------------- */
--
-- create a new flexfield qualifier
--
PROCEDURE add_flex_qualifier(flexfield             IN flexfield_type,

			     qualifier_name        IN VARCHAR2,
			     prompt                IN VARCHAR2,
			     description           IN VARCHAR2,
			     global_flag           IN VARCHAR2 DEFAULT 'N',
			     required_flag         IN VARCHAR2 DEFAULT 'N',
			     unique_flag           IN VARCHAR2 DEFAULT 'N')
  IS
BEGIN
   message_init;
   check_instantiated(flexfield);

   INSERT
     INTO fnd_segment_attribute_types(application_id,
				      id_flex_code,
				      segment_attribute_type,
				      global_flag,
				      required_flag,
				      unique_flag,
				      segment_prompt,
				      description,

				      creation_date,
				      created_by,
				      last_update_date,
				      last_updated_by,
				      last_update_login)
     VALUES(flexfield.application_id,
	    flexfield.flex_code,
	    qualifier_name,
	    global_flag,
	    required_flag,
	    unique_flag,
	    prompt,
	    description,

	    creation_date_i,
	    created_by_i,
	    last_update_date_i,
	    last_updated_by_i,
	    last_update_login_i);

-- If there are any segments defined
-- populate fnd_segment_attribute_values table.
-- Similar code exists in FNDFFIIF.SEG.other_inserts.

    INSERT INTO fnd_segment_attribute_values
      (application_id,
       id_flex_code,
       id_flex_num,
       application_column_name,
       segment_attribute_type,
       attribute_value,

       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login)
    SELECT ifsg.application_id,
           ifsg.id_flex_code,
           ifsg.id_flex_num,
           ifsg.application_column_name,
           add_flex_qualifier.qualifier_name,
           add_flex_qualifier.global_flag,

	   creation_date_i,
	   created_by_i,
	   last_update_date_i,
	   last_updated_by_i,
	   last_update_login_i
    FROM fnd_id_flex_segments ifsg
    WHERE application_id = flexfield.application_id
    AND id_flex_code = flexfield.flex_code
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

EXCEPTION
   WHEN OTHERS THEN
      message('add_flex_qualifier: ' || Sqlerrm);
      message(to_string(flexfield));
      message('flex_qualifier=' || qualifier_name);
      RAISE;
END;

FUNCTION delete_flex_qualifier(flexfield        IN flexfield_type,
			       qualifier_name   IN VARCHAR2,
			       recursive_delete IN BOOLEAN DEFAULT TRUE)
  RETURN NUMBER
  IS
     CURSOR vat_cur(p_application_id IN NUMBER,
		    p_id_flex_code IN VARCHAR2,
		    p_segment_attribute_type IN VARCHAR2)
       IS
	  SELECT value_attribute_type
	    FROM fnd_value_attribute_types vat
	    WHERE vat.application_id = p_application_id
	    AND vat.id_flex_code = p_id_flex_code
	    AND vat.segment_attribute_type = p_segment_attribute_type
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
     l_return NUMBER := 0;
     l_number NUMBER := 0;
     l_recursive_delete BOOLEAN := Nvl(recursive_delete, FALSE);
     l_vc2  varchar2(32000);
BEGIN
   message_init;
   check_instantiated(flexfield);

   --
   -- Check flexfield qualifier exists, otherwise return 0.
   --
   BEGIN
      SELECT 0
	INTO l_return
	FROM fnd_segment_attribute_types sat
	WHERE sat.application_id = flexfield.application_id
	AND sat.id_flex_code = flexfield.flex_code
	AND sat.segment_attribute_type = qualifier_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   EXCEPTION
      WHEN no_data_found THEN
	 message('Flexfield qualifier does not exist.');
	 RETURN(0);
      WHEN OTHERS THEN
	 message('SELECT FROM SAT is failed ' || chr_newline ||
		 'SQLERRM : ' || Sqlerrm);
	 RETURN(-1);
   END;

   --
   -- Check flexfield qualifier is not used by some segment, otherwise return -1.
   --
   BEGIN
      SELECT s.application_id || '/' ||
             s.id_flex_code || '/' ||
             s.id_flex_num || '/' ||
             s.application_column_name || '/' ||
             s.segment_name
          INTO l_vc2
          FROM fnd_id_flex_segments s, fnd_segment_attribute_values sav
         WHERE s.application_id = sav.application_id
           AND s.id_flex_code = sav.id_flex_code
           AND s.id_flex_num = sav.id_flex_num
           AND s.application_column_name = sav.application_column_name
           AND s.enabled_flag = 'Y'
           AND sav.application_id = flexfield.application_id
           AND sav.id_flex_code = flexfield.flex_code
           AND sav.attribute_value = 'Y'
           AND sav.segment_attribute_type = qualifier_name
           AND ROWNUM < 2
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

      message('Delete is not allowed. Flexfield qualifier <' || qualifier_name || '> is used by segment: <' || l_vc2 || '>');
      RETURN(-1);
   EXCEPTION
      WHEN no_data_found THEN
         null;
   END;

   l_number := 0;
   FOR vat_rec IN vat_cur(flexfield.application_id, flexfield.flex_code, qualifier_name) LOOP
      l_number := l_number + 1;
   END LOOP;

   IF ((NOT l_recursive_delete) AND (l_number > 0)) THEN
      message('There are segment qualifiers for this flexfield ' ||
	      'qualifier, and you passed recursive_delete => FALSE.');
      RETURN(-1);
   END IF;

   --
   -- Now delete segment qualifiers.
   --
   FOR vat_rec IN vat_cur(flexfield.application_id, flexfield.flex_code, qualifier_name) LOOP
      l_number := delete_seg_qualifier(flexfield,
				       qualifier_name,
				       vat_rec.value_attribute_type);
      IF (l_number = -1) THEN
	 RETURN (-1);
      END IF;
      l_return := l_return + l_number;
   END LOOP;

   --
   -- Delete from SAV
   --
   DELETE FROM fnd_segment_attribute_values sav
     WHERE sav.application_id = flexfield.application_id
     AND sav.id_flex_code = flexfield.flex_code
     AND sav.segment_attribute_type = qualifier_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   l_return := l_return + SQL%rowcount;

   --
   -- Delete from SAT
   --
   DELETE  FROM fnd_segment_attribute_types sat
     WHERE sat.application_id = flexfield.application_id
     AND sat.id_flex_code = flexfield.flex_code
     AND sat.segment_attribute_type = qualifier_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   l_return := l_return + SQL%rowcount;
   RETURN(l_return);
EXCEPTION
   WHEN OTHERS THEN
      message('Top level error : ' || Sqlerrm);
      RETURN(-1);
END delete_flex_qualifier;

FUNCTION fill_segment_attribute_values
  RETURN NUMBER
  IS
     l_return NUMBER := 0;
BEGIN
   message_init;

   INSERT INTO fnd_segment_attribute_values
     (application_id,
      id_flex_code,
      id_flex_num,
      application_column_name,
      segment_attribute_type,
      attribute_value,

      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login)
     SELECT ifsg.application_id,
     ifsg.id_flex_code,
     ifsg.id_flex_num,
     ifsg.application_column_name,
     sat.segment_attribute_type,
     sat.global_flag,

     creation_date_i,
     created_by_i,
     last_update_date_i,
     last_updated_by_i,
     last_update_login_i
     FROM fnd_id_flex_segments ifsg,
     fnd_segment_attribute_types sat
     WHERE sat.application_id = ifsg.application_id
     AND sat.id_flex_code = ifsg.id_flex_code
     AND NOT exists
     (SELECT NULL
      FROM fnd_segment_attribute_values sav
      WHERE sav.application_id = ifsg.application_id
      AND sav.id_flex_code = ifsg.id_flex_code
      AND sav.id_flex_num = ifsg.id_flex_num
      AND sav.application_column_name = ifsg.application_column_name
      AND sav.segment_attribute_type = sat.segment_attribute_type)
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   l_return := SQL%rowcount;
   RETURN(l_return);
EXCEPTION
   WHEN OTHERS THEN
      message('Top level error : ' || Sqlerrm);
      RETURN(-1);
END fill_segment_attribute_values;


/* ---------------------------------------------------------------------- */
--
-- create a new segment qualifier
--
PROCEDURE add_seg_qualifier(flexfield             IN flexfield_type,
			    flex_qualifier        IN VARCHAR2,

			    qualifier_name        IN VARCHAR2,
			    prompt                IN VARCHAR2,
			    description           IN VARCHAR2,
			    derived_column        IN VARCHAR2,
			    quickcode_type        IN VARCHAR2,
			    default_value         IN VARCHAR2)
  IS
dummy NUMBER;
l_rowid VARCHAR2(64);
BEGIN
   message_init;
   check_instantiated(flexfield);

-- Check flex_qualifier is a valid qualifier.
   BEGIN
     SELECT 1
       INTO dummy
       FROM dual
      WHERE EXISTS
       (SELECT 1
          FROM fnd_segment_attribute_types sat
         WHERE sat.application_id = flexfield.application_id
           AND sat.id_flex_code = flexfield.flex_code
           AND sat.segment_attribute_type = flex_qualifier)
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   EXCEPTION
     WHEN no_data_found THEN
         message('flexfield qualifier is not valid');
	 RAISE;
   END;


-- Check derived_column is registered in fnd_columns and has usage code 'N'
   BEGIN
     SELECT 1
       INTO dummy
       FROM dual
      WHERE EXISTS
       (SELECT 1
          FROM fnd_columns c
         WHERE c.application_id = flexfield.table_application_id
           AND c.table_id = flexfield.table_id
           AND c.column_name = derived_column
           AND c.flexfield_usage_code = 'N')
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   EXCEPTION
     WHEN no_data_found THEN
         message('derived column is either not registered ' ||
                 'or already in use.');
	 RAISE;
   END;

-- Check that quickcode_type and default_value are valid.
   BEGIN
     SELECT 1
       INTO dummy
       FROM dual
      WHERE EXISTS
       (SELECT 1
          FROM fnd_lookups
         WHERE lookup_type = quickcode_type
           AND lookup_code = default_value
           AND enabled_flag = 'Y'
           AND (   (start_date_active IS NULL)
                OR (start_date_active <= sysdate))
           AND (   (end_date_active IS NULL)
                OR (end_date_active >= sysdate)))
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   EXCEPTION
     WHEN no_data_found THEN
         message('quickcode_type, default_value ' ||
                 'pair either is not valid, disabled, or expired.');
	 RAISE;
   END;

-- Use fnd_val_attribute_types_pkg to make insert.
   FND_VAL_ATTRIBUTE_TYPES_PKG.INSERT_ROW(
      X_ROWID => l_rowid,
      X_APPLICATION_ID => flexfield.application_id,
      X_ID_FLEX_CODE => flexfield.flex_code,
      X_SEGMENT_ATTRIBUTE_TYPE => flex_qualifier,
      X_VALUE_ATTRIBUTE_TYPE => qualifier_name,
      X_REQUIRED_FLAG => 'Y',
      X_APPLICATION_COLUMN_NAME => derived_column,
      X_DESCRIPTION => description,
      X_DEFAULT_VALUE => default_value,
      X_LOOKUP_TYPE => quickcode_type,
      X_DERIVATION_RULE_CODE => 'G12',
      X_DERIVATION_RULE_VALUE1 => 'N',
      X_DERIVATION_RULE_VALUE2 => 'Y',
      X_PROMPT => prompt,
      X_CREATION_DATE => creation_date_i,
      X_CREATED_BY => created_by_i,
      X_LAST_UPDATE_DATE => last_update_date_i,
      X_LAST_UPDATED_BY => last_updated_by_i,
      X_LAST_UPDATE_LOGIN => last_update_login_i);

-- Mark the qualifier column in fnd_columns.
   UPDATE fnd_columns
      SET flexfield_usage_code = 'Q',
          last_update_date = last_update_date_i,
          last_updated_by = last_updated_by_i,
          last_update_login = last_update_login_i
    WHERE application_id = flexfield.table_application_id
      AND table_id = flexfield.table_id
      AND column_name = derived_column
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

--
-- Insert into FND_FLEX_VALIDATION_QUALIFIERS
--
   INSERT INTO fnd_flex_validation_qualifiers (flex_value_set_id,
					       id_flex_application_id,
					       id_flex_code,
					       segment_attribute_type,
					       value_attribute_type,
					       assignment_date)
   SELECT DISTINCT
          ifsg.flex_value_set_id,
          flexfield.application_id,
          flexfield.flex_code,
          flex_qualifier,
          qualifier_name,
          SYSDATE
     FROM fnd_segment_attribute_values sav,
          fnd_id_flex_segments ifsg
    WHERE sav.application_id = flexfield.application_id
      AND sav.id_flex_code = flexfield.flex_code
      AND sav.segment_attribute_type = flex_qualifier
      AND sav.attribute_value = 'Y'
      AND ifsg.application_id = sav.application_id
      AND ifsg.id_flex_code = sav.id_flex_code
      AND ifsg.id_flex_num = sav.id_flex_num
      AND ifsg.application_column_name = sav.application_column_name
      AND ifsg.flex_value_set_id IS NOT NULL
      AND ifsg.enabled_flag = 'Y'
      AND NOT EXISTS
          (SELECT NULL
             FROM fnd_flex_validation_qualifiers q
            WHERE q.flex_value_set_id = ifsg.flex_value_set_id
              AND q.id_flex_application_id = flexfield.application_id
              AND q.id_flex_code = flexfield.flex_code
              AND q.segment_attribute_type = flex_qualifier
              AND q.value_attribute_type = qualifier_name)
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

EXCEPTION
   WHEN OTHERS THEN
      message('add_seg_qualifier: ' || Sqlerrm);
      message(to_string(flexfield));
      message('flex_qualifier=' || flex_qualifier);
      message('segment_qualifier=' || qualifier_name);
      RAISE;
END;


FUNCTION delete_seg_qualifier(flexfield          IN flexfield_type,
			      flex_qualifier     IN VARCHAR2,
			      qualifier_name     IN VARCHAR2) RETURN NUMBER
  IS
     l_return NUMBER := 0;
BEGIN
   message_init;
   check_instantiated(flexfield);
   --
   -- Check flexfield qualifier exists, otherwise return 0.
   --
   BEGIN
      SELECT 0
	INTO l_return
	FROM fnd_segment_attribute_types sat
	WHERE sat.application_id = flexfield.application_id
	AND sat.id_flex_code = flexfield.flex_code
	AND sat.segment_attribute_type = flex_qualifier
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   EXCEPTION
      WHEN no_data_found THEN
	 message('Flexfield qualifier does not exist.');
	 RETURN(0);
      WHEN OTHERS THEN
	 message('SELECT FROM SAT is failed ' || chr_newline ||
		 'SQLERRM : ' || Sqlerrm);
	 RETURN(-1);
   END;
   --
   -- Check segment qualifier exists, otherwise return 0.
   --
   BEGIN
      SELECT 0
	INTO l_return
	FROM fnd_value_attribute_types vat
	WHERE vat.application_id = flexfield.application_id
	AND vat.id_flex_code = flexfield.flex_code
	AND vat.segment_attribute_type = flex_qualifier
	AND vat.value_attribute_type = qualifier_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   EXCEPTION
      WHEN no_data_found THEN
	 message('Segment qualifier does not exist.');
	 RETURN(0);
      WHEN OTHERS THEN
	 message('SELECT FROM VAT is failed ' || chr_newline ||
		 'SQLERRM : ' || Sqlerrm);
	 RETURN(-1);
   END;
   --
   -- Delete from fnd_flex_validation_qualifiers
   --
   DELETE FROM fnd_flex_validation_qualifiers fvq
     WHERE  fvq.id_flex_application_id = flexfield.application_id
     AND fvq.id_flex_code = flexfield.flex_code
     AND fvq.segment_attribute_type = flex_qualifier
     AND fvq.value_attribute_type = qualifier_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   l_return := SQL%rowcount;

   --
   -- Delete From VAT_TL table
   --
   DELETE FROM fnd_val_attribute_types_tl vat
     WHERE vat.application_id = flexfield.application_id
     AND vat.id_flex_code = flexfield.flex_code
     AND vat.segment_attribute_type = flex_qualifier
     AND vat.value_attribute_type = qualifier_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   l_return := l_return + SQL%rowcount;

   --
   -- Delete from VAT table
   --
   DELETE FROM fnd_value_attribute_types vat
     WHERE vat.application_id = flexfield.application_id
     AND vat.id_flex_code = flexfield.flex_code
     AND vat.segment_attribute_type = flex_qualifier
     AND vat.value_attribute_type = qualifier_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   l_return := l_return + SQL%rowcount;

   RETURN(l_return);
EXCEPTION
   WHEN OTHERS THEN
      message('Top level error : ' || Sqlerrm);
      RETURN(-1);
END delete_seg_qualifier;


/* ------------------------------------------------------------ */
PROCEDURE modify_flexfield(original        IN flexfield_type,
			   modified        IN flexfield_type)
  IS
     flexfield flexfield_type;
BEGIN
   message_init;
   check_instantiated(original);

   flexfield := compose(original, modified);

   UPDATE fnd_id_flexs SET
     id_flex_name = flexfield.flex_title,

     table_application_id = flexfield.table_application_id,
     application_table_name = flexfield.table_name,
     concatenated_segs_view_name = flexfield.concatenated_segs_view_name,
     allow_id_valuesets = flexfield.allow_id_value_sets,
     dynamic_inserts_feasible_flag = flexfield.dynamic_inserts,
     index_flag = flexfield.index_flag,
     unique_id_column_name = flexfield.unique_id_column,
     description = flexfield.description,
     application_table_type = NULL,
     set_defining_column_name = flexfield.structure_column,
     maximum_concatenation_len = flexfield.concat_seg_len_max,
     concatenation_len_warning = flexfield.concat_len_warning,

     last_update_date = last_update_date_i,
     last_updated_by = last_updated_by_i,
     last_update_login = last_update_login_i
     WHERE application_id = original.application_id
     AND id_flex_code = original.flex_code
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   unset_structure_column(original);
   set_structure_column(flexfield, flexfield.structure_column);

   unset_id_column(original);
   set_id_column(flexfield, flexfield.unique_id_column);

   last_flexfield := flexfield;
   println('modified ' || to_string(original));

EXCEPTION
   WHEN OTHERS THEN
      message(': ' || Sqlerrm);
      message(to_string(original));
      RAISE;
END;

/* ------------------------------------------------------------ */
PROCEDURE delete_flexfield(appl_short_name       IN VARCHAR2,
			   flex_code             IN VARCHAR2)
  IS
     flexfield flexfield_type;
BEGIN
   message_init;
   flexfield := find_flexfield(appl_short_name => appl_short_name,
			       flex_code => flex_code);
   delete_flexfield(flexfield);
EXCEPTION
   WHEN no_data_found THEN
      message('delete_flexfield: Either this flexfield is already deleted');
      message('or fnd_tables information is missing.');
      RAISE;
   WHEN OTHERS THEN
      message('delete_flexfield: ' || Sqlerrm);
      RAISE;
END;

/* ---------------------------------------------------------------------- */
PROCEDURE delete_flexfield(flexfield  IN flexfield_type)
  IS
     structure structure_type;
BEGIN
   message_init;

   BEGIN
     drop_KFV( p_application_id => flexfield.application_id,
               p_flex_code => flexfield.flex_code);
   EXCEPTION
   WHEN OTHERS THEN
      message('Drop Key Flexfield Concatenated View (drop_KFV): ' || Sqlerrm);
      message(to_string(flexfield));
      RAISE;
   END;


   -- delete the structures
   FOR structure_r IN structure_c(flexfield) LOOP
      BEGIN
	 structure := find_structure(flexfield => flexfield,
			  structure_number => structure_r.structure_number);
      EXCEPTION
	 WHEN OTHERS THEN
	    message('error locating structure');
	    message(to_string(flexfield));
	    message('structure number = ' || structure_r.structure_number);
	    RAISE;
      END;
      BEGIN
	 delete_structure(flexfield => flexfield,
			  structure => structure);
      EXCEPTION
	 WHEN OTHERS THEN
	    message('error deleting structure');
	    message(to_string(flexfield, structure));
	    RAISE;
      END;
   END LOOP;

   DELETE FROM fnd_val_attribute_types_tl
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   DELETE FROM fnd_value_attribute_types
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   DELETE FROM fnd_segment_attribute_types
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   BEGIN
      UPDATE fnd_columns SET
	flexfield_usage_code = 'N',
--	flexfield_application_id = NULL,
--	flexfield_name = NULL,
	last_update_date =  last_update_date_i,
	last_updated_by = last_updated_by_i,
	last_update_login = last_update_login_i
	WHERE application_id = flexfield.table_application_id
	AND table_id = flexfield.table_id
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
--	AND flexfield_name = flexfield.flex_code
--	AND flexfield_application_id = flexfield.application_id
   EXCEPTION
      WHEN OTHERS THEN
	 message('error updating fnd_columns');
	 RAISE;
   END;

   DELETE FROM fnd_id_flexs
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   DELETE FROM fnd_compiled_id_flexs
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   println('deleted flexfield: ' || to_string(flexfield));
EXCEPTION
   WHEN no_data_found THEN
      NULL;
   WHEN OTHERS THEN
      message('delete_flexfield: ' || Sqlerrm);
      message(to_string(flexfield));
      RAISE;
END;

-- drop key flexfield view bug#5058433
PROCEDURE drop_KFV(p_application_id       IN VARCHAR2,
                   p_flex_code             IN VARCHAR2)
is
   PRAGMA AUTONOMOUS_TRANSACTION;

   cursor l_applsys_schemas is
      select fou.oracle_username
        from fnd_oracle_userid fou,
             fnd_product_installations fpi
       where fou.oracle_id = fpi.oracle_id
         and fpi.application_id = 0;

   l_kfv_name fnd_id_flexs.concatenated_segs_view_name%TYPE;
   l_appl_short_name	fnd_application.application_short_name%TYPE;
   l_sql      varchar2(32000);

begin

   select fi.concatenated_segs_view_name, fa.application_short_name
     into l_kfv_name, l_appl_short_name
     from fnd_id_flexs fi,
          fnd_application fa
    where fa.application_id = p_application_id
      and fi.application_id = fa.application_id
      and fi.id_flex_code = p_flex_code;

   if l_kfv_name is not null then

     l_sql := 'DROP VIEW ' || l_kfv_name;

     for l_applsys_schema in l_applsys_schemas loop
       ad_ddl.do_ddl(applsys_schema         => l_applsys_schema.oracle_username,
                    application_short_name => l_appl_short_name,
                    statement_type         => ad_ddl.drop_view,
                    statement              => l_sql,
                    object_name            => l_kfv_name);
     end loop;

   end if;
   commit;
exception
   when others then
      rollback;
end drop_KFV;

/* ------------------------------------------------------------ */
/*  STRUCTURE RELATED FUNCTIONS */
/* ------------------------------------------------------------ */
FUNCTION new_structure(flexfield              IN flexfield_type,
		       structure_code         IN VARCHAR2 DEFAULT fnd_api.g_null_char,
		       structure_title        IN VARCHAR2 DEFAULT fnd_api.g_null_char,
		       description            IN VARCHAR2 DEFAULT fnd_api.g_null_char,
		       view_name              IN VARCHAR2 DEFAULT fnd_api.g_null_char,
		       freeze_flag            IN VARCHAR2 DEFAULT fnd_api.g_null_char,
		       enabled_flag           IN VARCHAR2 DEFAULT fnd_api.g_null_char,
		       segment_separator      IN VARCHAR2 DEFAULT fnd_api.g_null_char,
		       cross_val_flag         IN VARCHAR2 DEFAULT fnd_api.g_null_char,
		       freeze_rollup_flag     IN VARCHAR2 DEFAULT fnd_api.g_null_char,
		       dynamic_insert_flag    IN VARCHAR2 DEFAULT fnd_api.g_null_char,
		       shorthand_enabled_flag IN VARCHAR2 DEFAULT fnd_api.g_null_char,
                       shorthand_prompt       IN VARCHAR2 DEFAULT fnd_api.g_null_char,
                       shorthand_length       IN NUMBER   DEFAULT fnd_api.g_null_num)
  RETURN structure_type
  IS
     structure structure_type;
BEGIN
   message_init;
   check_instantiated(flexfield);

   IF customer_mode THEN
      SELECT fnd_id_flex_structures_s.NEXTVAL
	INTO structure.structure_number
	FROM dual;
   ELSE
      SELECT NVL(MAX(ifs.id_flex_num),0) + 1
	INTO structure.structure_number
	FROM fnd_id_flex_structures ifs
       WHERE ifs.application_id = flexfield.application_id
	 AND ifs.id_flex_code = flexfield.flex_code
	 AND ifs.id_flex_num < 101
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
      IF structure.structure_number = 101 THEN
        message('new structure : Developer defined key flexfield structure number'||
                ' cannot be greater than 100. Structure number limit exceeded');
        message(to_string(flexfield));
        RAISE value_too_large;
      END IF;
   END IF;

   set_value(structure_code, structure.structure_code);
   set_value(structure_title, structure.structure_name);
   set_value(description, structure.description);
   set_value(view_name, structure.view_name);
   set_value(freeze_flag, structure.freeze_flag);
   set_value(enabled_flag, structure.enabled_flag);
   set_value(segment_separator, structure.segment_separator);
   set_value(cross_val_flag, structure.cross_val_flag);
   set_value(freeze_rollup_flag, structure.freeze_rollup_flag);
   set_value(dynamic_insert_flag, structure.dynamic_insert_flag);
   set_value(shorthand_enabled_flag, structure.shorthand_enabled_flag);
   set_value(shorthand_prompt, structure.shorthand_prompt);
   set_value(shorthand_length, structure.shorthand_length);

   last_structure := structure;

   RETURN structure;

EXCEPTION
   WHEN OTHERS THEN
      message('new_structure: ' || Sqlerrm);
      RAISE;
END;

/* ---------------------------------------------------------------------- */
FUNCTION find_structure(flexfield              IN flexfield_type,
			structure_code         IN VARCHAR2)
  RETURN structure_type
  IS
     structure structure_type;
BEGIN
   message_init;
   check_instantiated(flexfield);

   SELECT 'Y',
     id_flex_num,
     id_flex_structure_code,
     id_flex_structure_name,
     description,
     structure_view_name,
     freeze_flex_definition_flag,
     enabled_flag,
     concatenated_segment_delimiter,
     cross_segment_validation_flag,
     freeze_structured_hier_flag,
     dynamic_inserts_allowed_flag,
     shorthand_enabled_flag,
     shorthand_prompt,
     shorthand_length
     INTO structure
     FROM fnd_id_flex_structures_vl
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND id_flex_structure_code = structure_code
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   -- find_structure.structure title will give strange errors

   last_structure := structure;

   RETURN structure;

EXCEPTION
   WHEN OTHERS THEN
      message('find_structure/title: ' || Sqlerrm);
      message(to_string(flexfield));
      RAISE;
END;

/* ---------------------------------------------------------------------- */
FUNCTION find_structure(flexfield              IN flexfield_type,
			structure_number       IN NUMBER)
  RETURN structure_type
  IS
     structure structure_type;
BEGIN
   message_init;
   check_instantiated(flexfield);

   SELECT 'Y',
     id_flex_num,
     id_flex_structure_code,
     id_flex_structure_name,
     description,
     structure_view_name,
     freeze_flex_definition_flag,
     enabled_flag,
     concatenated_segment_delimiter,
     cross_segment_validation_flag,
     freeze_structured_hier_flag,
     dynamic_inserts_allowed_flag,
     shorthand_enabled_flag,
     shorthand_prompt,
     shorthand_length
     INTO structure
     FROM fnd_id_flex_structures_vl
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND id_flex_num = find_structure.structure_number
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   last_structure := structure;

   RETURN structure;

EXCEPTION
   WHEN OTHERS THEN
      message('find_structure/number: ' || Sqlerrm);
      message(to_string(flexfield));
      RAISE;
END;

/* ---------------------------------------------------------------------- */
FUNCTION add_structure(flexfield              IN flexfield_type,
		       structure_code         IN VARCHAR2,
			structure_title        IN VARCHAR2,
			description            IN VARCHAR2,
			view_name              IN VARCHAR2,
			freeze_flag            IN VARCHAR2 DEFAULT 'N',
			enabled_flag           IN VARCHAR2 DEFAULT 'N',
			segment_separator      IN VARCHAR2,
			cross_val_flag         IN VARCHAR2,
			freeze_rollup_flag     IN VARCHAR2 DEFAULT 'N',
			dynamic_insert_flag    IN VARCHAR2 DEFAULT 'N',
			shorthand_enabled_flag IN VARCHAR2 DEFAULT 'N',
			shorthand_prompt       IN VARCHAR2 DEFAULT NULL,
			shorthand_length       IN NUMBER DEFAULT NULL)
RETURN structure_type
  IS
     structure structure_type;
BEGIN
   message_init;
   check_instantiated(flexfield);
   structure := new_structure(flexfield => flexfield,
			      structure_code => structure_code,
			      structure_title => structure_title,
			      description => description,
			      view_name => view_name,
			      freeze_flag => freeze_flag,
			      enabled_flag => enabled_flag,
			      segment_separator => segment_separator,
			      cross_val_flag => cross_val_flag,
			      freeze_rollup_flag => freeze_rollup_flag,
			      dynamic_insert_flag => dynamic_insert_flag,
			      shorthand_enabled_flag => shorthand_enabled_flag,
			      shorthand_prompt => shorthand_prompt,
			      shorthand_length => shorthand_length);
   add_structure(flexfield => flexfield,
		 structure => structure);

   RETURN structure;
EXCEPTION
   WHEN OTHERS THEN
      message('add_structure: ' || Sqlerrm);
      message('structure name=' || structure_title);
      RAISE;
END;

/* ---------------------------------------------------------------------- */
PROCEDURE add_structure(flexfield IN flexfield_type DEFAULT last_flexfield,
			structure IN OUT nocopy structure_type)
  IS
BEGIN
   message_init;
   check_instantiated(flexfield);

   IF check_duplicate_structure(flexfield => flexfield,
		 		structure_name => structure.structure_name) <> 0 THEN
      message('add_structure : This structure name already exists');
      message(to_string(flexfield,structure));
      RAISE bad_parameter;
   END IF;

   validate_structure(flexfield,structure);

   add_structure_internal(appl_short_name        => flexfield.appl_short_name,
			  flex_code              => flexfield.flex_code,
			  structure_code         => structure.structure_code,
			  structure_title        => structure.structure_name,
			  description            => structure.description,
			  view_name              => structure.view_name,
			  freeze_flag            => structure.freeze_flag,
			  enabled_flag           => structure.enabled_flag,
			  segment_separator      => structure.segment_separator,
			  cross_val_flag         => structure.cross_val_flag,
			  freeze_rollup_flag     => structure.freeze_rollup_flag,
			  dynamic_insert_flag    => structure.dynamic_insert_flag,
			  shorthand_enabled_flag => structure.shorthand_enabled_flag,
			  shorthand_prompt       => structure.shorthand_prompt,
			  shorthand_length       => structure.shorthand_length,
			  flex_num               => structure.structure_number);

   structure.instantiated := 'Y';

   last_structure := structure;

   println('added structure: ' || to_string(flexfield, structure));
EXCEPTION
   WHEN OTHERS THEN
      message('add_structure: ' || Sqlerrm);
      message(to_string(flexfield, structure));
      message('structure name=' || structure.structure_name);
      RAISE;
END;

/* ------------------------------------------------------------ */
PROCEDURE modify_structure(flexfield       IN flexfield_type,
			   original        IN structure_type,
			   modified        IN structure_type)
  IS
     structure structure_type;
BEGIN
   message_init;
   check_instantiated(flexfield);
   check_instantiated(original);

   IF (check_duplicate_structure(flexfield => flexfield,
		 		 structure_name => modified.structure_name) <> 0)
      AND (modified.structure_name <> original.structure_name) THEN
         message('modify_structure : This structure name already exists');
         message(to_string(flexfield,modified));
         RAISE bad_parameter;
   END IF;

   structure := compose(original, modified);
   validate_structure(flexfield,structure);

   fnd_id_flex_structures_pkg.update_row
     (X_APPLICATION_ID               => flexfield.application_id,
      X_ID_FLEX_CODE                 => flexfield.flex_code,
      X_ID_FLEX_NUM                  => structure.structure_number,
      X_ID_FLEX_STRUCTURE_CODE       => structure.structure_code,
      X_CONCATENATED_SEGMENT_DELIMIT => structure.segment_separator,
      X_CROSS_SEGMENT_VALIDATION_FLA => structure.cross_val_flag,
      X_DYNAMIC_INSERTS_ALLOWED_FLAG => structure.dynamic_insert_flag,
      X_ENABLED_FLAG                 => structure.enabled_flag,
      X_FREEZE_FLEX_DEFINITION_FLAG  => structure.freeze_flag,
      X_FREEZE_STRUCTURED_HIER_FLAG  => structure.freeze_rollup_flag,
      X_SHORTHAND_ENABLED_FLAG       => structure.shorthand_enabled_flag,
      X_SHORTHAND_LENGTH             => structure.shorthand_length,
      X_STRUCTURE_VIEW_NAME          => structure.view_name,
      X_ID_FLEX_STRUCTURE_NAME       => structure.structure_name,
      X_DESCRIPTION                  => structure.description,
      X_SHORTHAND_PROMPT             => structure.shorthand_prompt,
      X_LAST_UPDATE_DATE             => last_update_date_i,
      X_LAST_UPDATED_BY              => last_updated_by_i,
      X_LAST_UPDATE_LOGIN            => last_update_login_i);

   last_structure := structure;
   println('modified ' || to_string(flexfield, structure));

EXCEPTION
   WHEN OTHERS THEN
      message('modify_structure: ' || Sqlerrm);
      message(to_string(flexfield, original));
      message(to_string(flexfield, modified));
      RAISE;
END;


/* ---------------------------------------------------------------------- */
PROCEDURE delete_structure(flexfield             IN flexfield_type,
			   structure             IN structure_type)
  IS
     segment segment_type;
BEGIN
   message_init;

   BEGIN
     drop_KFSV( p_application_id=> flexfield.application_id,
                p_flex_code=> flexfield.flex_code,
                p_struct_num=> structure.structure_number);
   EXCEPTION
   WHEN OTHERS THEN
      message('Drop Key Flexfield Structure View (drop_KFSV): ' || Sqlerrm);
      message(to_string(flexfield, structure));
      RAISE;
   END;

   -- delete the segments
   FOR segment_r IN segment_c(flexfield, structure) LOOP
      BEGIN
	 segment := find_segment(flexfield => flexfield,
				 structure => structure,
				 segment_name => segment_r.segment_name);
      EXCEPTION
	 WHEN OTHERS THEN
	    message('error locating segment');
	    message(to_string(flexfield, structure));
	    message('segment = ' || segment_r.segment_name);
	    RAISE;
      END;
      BEGIN
	 delete_segment(flexfield => flexfield,
			structure => structure,
			segment => segment);
      EXCEPTION
	 WHEN OTHERS THEN
	    message('error deleting segment');
	    message(to_string(flexfield, structure, segment));
	    RAISE;
      END;
   END LOOP;

   DELETE FROM fnd_shorthand_flex_aliases
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND id_flex_num = structure.structure_number
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   --
   -- flexbuilder assignments ??
   --

   --
   -- cross validation stuff
   --
   DELETE FROM fnd_flex_validation_rules
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND id_flex_num = structure.structure_number
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   DELETE FROM fnd_flex_vdation_rules_tl
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND id_flex_num = structure.structure_number
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   DELETE FROM fnd_flex_validation_rule_lines
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND id_flex_num = structure.structure_number
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   DELETE FROM fnd_flex_include_rule_lines
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND id_flex_num = structure.structure_number
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   DELETE FROM fnd_flex_exclude_rule_lines
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND id_flex_num = structure.structure_number
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   DELETE FROM fnd_flex_validation_rule_stats
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND id_flex_num = structure.structure_number
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   DELETE FROM fnd_id_flex_structures_tl
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND id_flex_num = structure.structure_number
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   DELETE FROM fnd_id_flex_structures
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND id_flex_num = structure.structure_number
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   DELETE FROM fnd_compiled_id_flex_structs
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND id_flex_num = structure.structure_number
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   println('deleted structure: ' || to_string(flexfield, structure));
EXCEPTION
   WHEN OTHERS THEN
      message('delete_structure: ' || Sqlerrm);
      message(to_string(flexfield, structure));
      RAISE;
END;


-- drop key flexfield structure view bug#5058433
PROCEDURE drop_KFSV
  (p_application_id       IN VARCHAR2,
   p_flex_code             IN VARCHAR2,
   p_struct_num            IN NUMBER)
is
   PRAGMA AUTONOMOUS_TRANSACTION;

   cursor l_applsys_schemas is
      select fou.oracle_username
        from fnd_oracle_userid fou,
             fnd_product_installations fpi
       where fou.oracle_id = fpi.oracle_id
         and fpi.application_id = 0;

   l_kfsv_name fnd_id_flex_structures.structure_view_name%TYPE;
   l_appl_short_name	fnd_application.application_short_name%TYPE;
   l_sql      varchar2(32000);

begin
   select fs.structure_view_name, fa.application_short_name
     into l_kfsv_name, l_appl_short_name
     from fnd_id_flex_structures fs,
          fnd_application fa
    where fa.application_id = p_application_id
      and fs.application_id = fa.application_id
      and fs.id_flex_code = p_flex_code
      and fs.id_flex_num = p_struct_num;

   if l_kfsv_name is not null then
     l_sql := 'DROP VIEW ' || l_kfsv_name;

     for l_applsys_schema in l_applsys_schemas loop
        ad_ddl.do_ddl(applsys_schema         => l_applsys_schema.oracle_username,
                    application_short_name => l_appl_short_name,
                    statement_type         => ad_ddl.drop_view,
                    statement              => l_sql,
                    object_name            => l_kfsv_name);
     end loop;

   end if;

   commit;
exception
   when others then
      rollback;
end drop_KFSV;

/* ---------------------------------------------------------------------- */
/* SEGMENT RELATED FUNCTIONS */
/* ---------------------------------------------------------------------- */
FUNCTION new_segment
  (flexfield                 IN flexfield_type,
   structure                 IN structure_type,
   segment_name              IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   description               IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   column_name               IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   segment_number            IN NUMBER DEFAULT fnd_api.g_null_num,
   enabled_flag              IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   displayed_flag            IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   indexed_flag              IN VARCHAR2 DEFAULT fnd_api.g_null_char,

   /* validation */
   value_set                 IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   default_type              IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   default_value             IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   required_flag             IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   security_flag             IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   range_code                IN VARCHAR2 DEFAULT fnd_api.g_null_char,

   /* sizes */
   display_size              IN NUMBER DEFAULT fnd_api.g_null_num,
   description_size          IN NUMBER DEFAULT fnd_api.g_null_num,
   concat_size               IN NUMBER DEFAULT fnd_api.g_null_num,

   /* prompts */
   lov_prompt                IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   window_prompt             IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   runtime_property_function IN VARCHAR2 DEFAULT fnd_api.g_null_char,
   additional_where_clause   IN VARCHAR2 DEFAULT fnd_api.g_null_char)
  RETURN segment_type
  IS
     segment segment_type;
BEGIN
   message_init;
   check_instantiated(flexfield);
   check_instantiated(structure);


   set_value(segment_name, segment.segment_name);
   set_value(description, segment.description);
   set_value(column_name, segment.column_name);
   set_value(segment_number, segment.segment_number);
   set_value(enabled_flag, segment.enabled_flag);
   set_value(displayed_flag, segment.displayed_flag);
   set_value(indexed_flag, segment.indexed_flag);

   set_value(value_set, segment.value_set_name);
   IF(NOT is_default(value_set)) THEN
      segment.value_set_id := value_set_id_f(value_set);
    ELSE
      make_default(segment.value_set_id);
   END IF;
   set_value(default_type, segment.default_type);
   set_value(default_value, segment.default_value);
   set_value(required_flag, segment.required_flag);
   set_value(security_flag, segment.security_flag);

   set_value(range_code, segment.range_code);
   set_value(display_size, segment.display_size);
   set_value(description_size, segment.description_size);
   set_value(concat_size, segment.concat_size);

   set_value(lov_prompt, segment.lov_prompt);
   set_value(window_prompt, segment.window_prompt);
   set_value(runtime_property_function, segment.runtime_property_function);

   set_value(additional_where_clause, segment.additional_where_clause);

   last_segment := segment;

   RETURN segment;
EXCEPTION
   WHEN OTHERS THEN
      message('new_segment: ' || Sqlerrm);
      message(to_string(flexfield, structure));
      message('segment name=' || segment_name);
      RAISE;
END;

/* ------------------------------------------------------------ */
FUNCTION find_segment(flexfield    IN flexfield_type,
		      structure    IN structure_type,
		      segment_name IN VARCHAR2)
  RETURN segment_type
  IS
     segment segment_type;
BEGIN
   check_instantiated(flexfield);
   check_instantiated(structure);

   SELECT 'Y' instantiated,
     seg.segment_name,
     seg.description,
     seg.application_column_name,
     seg.segment_num,
     seg.enabled_flag,
     seg.display_flag,
     seg.application_column_index_flag,
     seg.flex_value_set_id,
     NULL,
     seg.default_type,
     seg.default_value,
     seg.runtime_property_function,
     seg.additional_where_clause,
     seg.required_flag,
     seg.security_enabled_flag,
     seg.range_code,

     seg.display_size,
     seg.maximum_description_len,
     seg.concatenation_description_len,
     seg.form_above_prompt,
     seg.form_left_prompt
     INTO segment
     FROM fnd_id_flex_segments_vl seg
     WHERE seg.application_id = flexfield.application_id
     AND seg.id_flex_code = flexfield.flex_code
     AND seg.id_flex_num = structure.structure_number
     AND seg.segment_name = find_segment.segment_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   last_segment := segment;
   RETURN segment;

EXCEPTION
   WHEN OTHERS THEN
      message('find_segment: ' || Sqlerrm);
      message('segment_name=' || segment_name);
      message(to_string(flexfield, structure));
      RAISE;
END;

/* ---------------------------------------------------------------------- */
--
-- add a segment to a structure
--
PROCEDURE add_segment(flexfield IN flexfield_type,
		      structure IN structure_type,
		      segment   IN OUT nocopy segment_type)
  IS
BEGIN
   message_init;
   check_instantiated(flexfield);
   check_instantiated(structure);

   IF check_duplicate_segment(flexfield => flexfield,
			      structure => structure,
		 	      segment_name => segment.segment_name) <> 0 THEN
      message('add_segment : This segment name already exists');
      message(to_string(flexfield,structure,segment));
      RAISE bad_parameter;
   END IF;

   validate_segment(flexfield, structure, segment);

   INSERT
     INTO fnd_id_flex_segments (application_id,
				id_flex_code,
				id_flex_num,

				application_column_name,
				segment_name,
				segment_num,
				application_column_index_flag,
				enabled_flag,
				required_flag,
				display_flag,
				display_size,
				security_enabled_flag,
				maximum_description_len,
				concatenation_description_len,
--				form_left_prompt,
--				form_above_prompt,
--				description,

				flex_value_set_id,
				range_code,
				default_type,
				default_value,
				runtime_property_function,
                                additional_where_clause,

				creation_date,
				created_by,
				last_update_date,
				last_updated_by,
				last_update_login)
     VALUES (flexfield.application_id,
	     flexfield.flex_code,
	     structure.structure_number,

	     segment.column_name,
	     segment.segment_name,
	     segment.segment_number,
	     segment.indexed_flag,
	     segment.enabled_flag,
	     segment.required_flag,
	     segment.displayed_flag,
	     segment.display_size,
	     segment.security_flag,
	     segment.description_size,
	     segment.concat_size,
--	     segment.window_prompt,
--	     segment.lov_prompt,
--	     segment.description,

	     segment.value_set_id,
	     segment.range_code,
	     segment.default_type,
	     segment.default_value,
	     segment.runtime_property_function,
	     segment.additional_where_clause,

	     creation_date_i,
	     created_by_i,
	     last_update_date_i,
	     last_updated_by_i,
	     last_update_login_i);


   BEGIN
      INSERT INTO fnd_segment_attribute_values(id_flex_code,
					       id_flex_num,
					       application_column_name,
					       segment_attribute_type,

					       creation_date,
					       created_by,
					       last_update_date,
					       last_updated_by,
					       last_update_login,

					       attribute_value,
					       application_id)
	SELECT
	s.id_flex_code,
	s.id_flex_num,
	s.application_column_name,
	segment_attribute_type,

	creation_date_i,
	created_by_i,
	last_update_date_i,
	last_updated_by_i,
	last_update_login_i,

	t.global_flag,
	s.application_id
	FROM fnd_id_flex_segments s, fnd_segment_attribute_types t
	WHERE s.application_id = flexfield.application_id
	AND s.application_column_name = segment.column_name
	AND s.id_flex_code = flexfield.flex_code
	AND s.id_flex_num = structure.structure_number
	AND t.application_id = s.application_id
	AND t.id_flex_code = s.id_flex_code
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

    INSERT INTO fnd_flex_validation_qualifiers (flex_value_set_id,
						id_flex_application_id,
						id_flex_code,
						segment_attribute_type,
						value_attribute_type,
						assignment_date)
      SELECT
      segment.value_set_id,
      flexfield.application_id,
      flexfield.flex_code,
      sav.segment_attribute_type,
      vat.value_attribute_type,
      sysdate
      FROM fnd_segment_attribute_values sav,
      fnd_value_attribute_types vat
      WHERE segment.value_set_id IS NOT NULL
	AND segment.enabled_flag = 'Y'
	AND sav.application_id = flexfield.application_id
	AND sav.id_flex_code = flexfield.flex_code
	AND sav.id_flex_num = structure.structure_number
	AND sav.application_column_name = segment.column_name
	AND sav.attribute_value = 'Y'
	AND sav.application_id = vat.application_id
	AND sav.id_flex_code = vat.id_flex_code
	AND sav.segment_attribute_type = vat.segment_attribute_type
	AND NOT EXISTS
	(SELECT NULL
	 FROM fnd_flex_validation_qualifiers q
	 WHERE q.flex_value_set_id = segment.value_set_id
	 AND q.id_flex_application_id = flexfield.application_id
	 AND q.id_flex_code = flexfield.flex_code
	 AND q.segment_attribute_type = sav.segment_attribute_type
	 AND q.value_attribute_type = vat.value_attribute_type)
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   END;

   INSERT INTO fnd_id_flex_segments_tl(application_id,
				       id_flex_code,
				       id_flex_num,
				       application_column_name,
				       language,
				       form_above_prompt,
				       form_left_prompt,
				       description,

				       creation_date,
				       created_by,
				       last_update_date,
				       last_updated_by,
				       last_update_login,

				       source_lang)
     SELECT
     flexfield.application_id,
     flexfield.flex_code,
     structure.structure_number,
     segment.column_name,
     l.language_code,
     segment.lov_prompt,
     segment.window_prompt,
     segment.description,

     creation_date_i,
     created_by_i,
     last_update_date_i,
     last_updated_by_i,
     last_update_login_i,
     userenv('LANG')
     FROM fnd_languages l
     WHERE l.installed_flag IN ('I', 'B')
     AND NOT EXISTS
     (SELECT NULL
      FROM fnd_id_flex_segments_tl t
      WHERE t.application_id = flexfield.application_id
    AND t.id_flex_code = flexfield.flex_code
      AND t.id_flex_num = structure.structure_number
    AND t.application_column_name = segment.column_name
    AND t.language = l.language_code)
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;



   segment.instantiated := 'Y';

   last_segment := segment;

   println('added segment: ' || to_string(flexfield, structure, segment));
EXCEPTION
   WHEN OTHERS THEN
      message('add_segment: ' || Sqlerrm);
      message(to_string(flexfield, structure, segment));
      RAISE;
END add_segment;

/* ---------------------------------------------------------------------- */
--
-- qualifiers are automatiicaly assigned as disabled when the segment
-- is created.
--
PROCEDURE assign_qualifier(flexfield             IN flexfield_type,
			   structure             IN structure_type,
			   segment               IN segment_type,
			   flexfield_qualifier   IN VARCHAR2,
			   enable_flag           IN VARCHAR2 DEFAULT 'Y')
  IS
BEGIN
   message_init;
   check_instantiated(flexfield);
   check_instantiated(structure);
   check_instantiated(segment);

   UPDATE fnd_segment_attribute_values SET
     attribute_value = enable_flag,
     last_update_date =  last_update_date_i,
     last_updated_by = last_updated_by_i,
     last_update_login = last_update_login_i
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND id_flex_num = structure.structure_number
     AND application_column_name = segment.column_name
     AND segment_attribute_type = flexfield_qualifier
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   INSERT INTO fnd_flex_validation_qualifiers (flex_value_set_id,
					       id_flex_application_id,
					       id_flex_code,
					       segment_attribute_type,
					       value_attribute_type,
					       assignment_date)
     SELECT
     segment.value_set_id,
     flexfield.application_id,
     flexfield.flex_code,
     sav.segment_attribute_type,
     vat.value_attribute_type,
     sysdate
     FROM fnd_segment_attribute_values sav,
     fnd_value_attribute_types vat
     WHERE segment.value_set_id IS NOT NULL
       AND segment.enabled_flag = 'Y'
       AND sav.application_id = flexfield.application_id
       AND sav.id_flex_code = flexfield.flex_code
       AND sav.id_flex_num = structure.structure_number
       AND sav.application_column_name = segment.column_name
       AND sav.attribute_value = 'Y'
       AND sav.application_id = vat.application_id
       AND sav.id_flex_code = vat.id_flex_code
       AND sav.segment_attribute_type = vat.segment_attribute_type
       AND sav.segment_attribute_type = flexfield_qualifier
       AND NOT EXISTS
       (SELECT NULL
	FROM fnd_flex_validation_qualifiers q
	WHERE q.flex_value_set_id = segment.value_set_id
	AND q.id_flex_application_id = flexfield.application_id
	AND q.id_flex_code = flexfield.flex_code
	AND q.segment_attribute_type = sav.segment_attribute_type
	AND q.value_attribute_type = vat.value_attribute_type)
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

EXCEPTION
   WHEN OTHERS THEN
      message('assign_qualifier: ' || Sqlerrm);
      message(to_string(flexfield, structure, segment));
      message('flexfield_qualifier=' || flexfield_qualifier);
      RAISE;
END;

/* ---------------------------------------------------------------------- */
PROCEDURE modify_segment(flexfield       IN flexfield_type,
			 structure       IN structure_type,
			 original        IN segment_type,
			 modified        IN segment_type)
  IS
     segment segment_type;
BEGIN
   check_instantiated(flexfield);
   check_instantiated(structure);
   check_instantiated(original);

   IF (check_duplicate_segment(flexfield => flexfield,
			       structure => structure,
		 	       segment_name => modified.segment_name) <> 0)
      AND (modified.segment_name <> original.segment_name) THEN
         message('modify_segment : This segment name already exists');
         message(to_string(flexfield,structure,modified));
         RAISE bad_parameter;
   END IF;

   segment := compose(original, modified);

--  set flag so that validate segment does not call validate_column_name
--  which will return an error as column_name already exists on a modify - dag

   do_validation := FALSE;
      validate_segment(flexfield, structure, segment);
   do_validation := TRUE;

   UPDATE fnd_id_flex_segments SET
     --     application_column_name = segment.column_name,
     segment_name = segment.segment_name,
     segment_num = segment.segment_number,
     application_column_index_flag = segment.indexed_flag,
     enabled_flag = segment.enabled_flag,
     required_flag = segment.required_flag,
     display_flag = segment.displayed_flag,
     display_size = segment.display_size,
     security_enabled_flag = segment.security_flag,
     maximum_description_len = segment.description_size,
     concatenation_description_len = segment.concat_size,

     flex_value_set_id = segment.value_set_id,
     range_code = segment.range_code,
     default_type = segment.default_type,
     default_value = segment.default_value,
     runtime_property_function = segment.runtime_property_function,
     additional_where_clause = segment.additional_where_clause,

     last_update_date = last_update_date_i,
     last_updated_by = last_updated_by_i,
     last_update_login = last_update_login_i
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND id_flex_num = structure.structure_number
     AND application_column_name = original.column_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   IF(segment.column_name <> original.column_name) THEN
      UPDATE fnd_segment_attribute_values SET
	application_column_name = segment.column_name,
	last_update_date = last_update_date_i,
	last_updated_by = last_updated_by_i,
	last_update_login = last_update_login_i
	WHERE application_id = flexfield.application_id
	AND id_flex_code = flexfield.flex_code
	AND id_flex_num = structure.structure_number
	AND application_column_name = original.column_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
   END IF;

  BEGIN
     INSERT INTO fnd_flex_validation_qualifiers
       (flex_value_set_id,
	id_flex_application_id,
	id_flex_code,
	segment_attribute_type,
	value_attribute_type,
	assignment_date)
       SELECT
       segment.value_set_id,
       flexfield.application_id,
       flexfield.flex_code,
       sav.segment_attribute_type,
       vat.value_attribute_type,
       Sysdate
       FROM fnd_segment_attribute_values sav,
       fnd_value_attribute_types vat
       WHERE segment.value_set_id IS NOT NULL
	 AND segment.enabled_flag = 'Y'
	 AND sav.application_id = flexfield.application_id
	 AND sav.id_flex_code = flexfield.flex_code
	 AND sav.id_flex_num = structure.structure_number
	 AND sav.application_column_name = segment.column_name
	 AND sav.attribute_value = 'Y'
	 AND sav.application_id = vat.application_id
	 AND sav.id_flex_code = vat.id_flex_code
	 AND sav.segment_attribute_type = vat.segment_attribute_type
	 AND NOT EXISTS
	 (SELECT NULL FROM fnd_flex_validation_qualifiers q
	  WHERE q.flex_value_set_id = segment.value_set_id
       AND q.id_flex_application_id = flexfield.application_id
	  AND q.id_flex_code = flexfield.flex_code
	  AND q.segment_attribute_type = sav.segment_attribute_type
	  AND q.value_attribute_type = vat.value_attribute_type)
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
  END;


   UPDATE fnd_id_flex_segments_tl SET
     application_column_name = segment.column_name,
     form_left_prompt = segment.window_prompt,
     form_above_prompt = segment.lov_prompt,
     description = segment.description,

     source_lang = userenv('LANG'),

     last_update_date = last_update_date_i,
     last_updated_by = last_updated_by_i,
     last_update_login = last_update_login_i
     WHERE application_id = flexfield.application_id
     AND id_flex_code = flexfield.flex_code
     AND id_flex_num = structure.structure_number
     AND application_column_name = original.column_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   println('modified ' || to_string(flexfield, structure, original));
   println('to ' || to_string(flexfield, structure, segment));

EXCEPTION
   WHEN OTHERS THEN
      message('modify_segment: ' || Sqlerrm);
      message(to_string(flexfield, structure, original));
      message(to_string(flexfield, structure, modified));
      RAISE;
END;

/* ---------------------------------------------------------------------- */
PROCEDURE delete_segment(flexfield             IN flexfield_type,
			 structure             IN structure_type,
			 segment               IN segment_type)
  IS
BEGIN
   message_init;
--
-- Delete "Flexfield Qualifier - Segment" assignments for this segment.
--
   DELETE FROM fnd_segment_attribute_values
    WHERE application_id = flexfield.application_id
      AND id_flex_code = flexfield.flex_code
      AND id_flex_num = structure.structure_number
      AND application_column_name = segment.column_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

--
-- Delete from translation table.
--
   DELETE FROM fnd_id_flex_segments_tl
    WHERE application_id = flexfield.application_id
      AND id_flex_code = flexfield.flex_code
      AND id_flex_num = structure.structure_number
      AND application_column_name = segment.column_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

--
-- Delete from base key flexfield segment table.
--
   DELETE FROM fnd_id_flex_segments
    WHERE application_id = flexfield.application_id
      AND id_flex_code = flexfield.flex_code
      AND id_flex_num = structure.structure_number
      AND segment_name = segment.segment_name
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

   println('deleted segment: ' || to_string(flexfield, structure, segment));
EXCEPTION
   WHEN OTHERS THEN
      message('delete_segment: ' || Sqlerrm);
      RAISE;
END;


/* ---------------------------------------------------------------------- */
/* Testing */
/* ---------------------------------------------------------------------- */
PROCEDURE test(name IN VARCHAR2)
  IS
     flexfield flexfield_type;
     structure structure_type;
     sname VARCHAR2(1000);
BEGIN
   println('starting test');
   IF(name = 'newflex') THEN
      flexfield := new_flexfield(appl_short_name => 'FND',
				 flex_code => 'RW2',
				 flex_title => 'Rajiv*s test flex',
				 description => 'testing key flex API',
				 table_appl_short_name => 'FND',
				 table_name => 'AF_FLEX_TEST',
				 unique_id_column => 'UNIQUE_ID_COLUMN',
				 structure_column => 'SET_DEFINING_COLUMN',
				 dynamic_inserts => 'Y',
				 allow_id_value_sets => 'Y',
				 concat_seg_len_max => '81',
				 concat_len_warning => 'len overflow warning',
                                 concatenated_segs_view_name => NULL);
      register(flexfield);
      println('created new flexfield');
    ELSE
      flexfield := find_flexfield(appl_short_name => 'FND',
				  flex_code => 'RW2');

      IF(name = 'newstruct') THEN
	 SELECT 'test' || To_char(MAX(To_number(Substr(id_flex_structure_name, 4))) + 1)
	   INTO sname
	   FROM fnd_id_flex_structures_vl
	   WHERE application_id = 0
	   AND id_flex_code = 'RW2'
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

	 structure := new_structure(flexfield => flexfield,
				    structure_title => sname,
				    description => 'a test structure',
				    view_name => NULL,
				    freeze_flag => 'N',
				    enabled_flag => 'N',
				    segment_separator => '-',
				    cross_val_flag => 'N',
				    shorthand_enabled_flag => 'N');
	 add_structure(flexfield, structure);
	 println('added structure');
       ELSE
	 structure := find_structure(flexfield => flexfield,
				     structure_code => 'test struct1');
	 IF(name = 'newseg') THEN
	    NULL;
	    println('added segment');
	  ELSE
	    println('doing nothing');
	 END IF;
      END IF;
   END IF;

   println('test complete');
EXCEPTION
   WHEN OTHERS THEN
      println(message);
      RAISE;
END;

/* ---------------------------------------------------------------------- */
FUNCTION quot(val IN NUMBER) RETURN VARCHAR2 IS
BEGIN
   IF(val IS NULL) THEN
      RETURN 'NULL';
    ELSE
      RETURN To_char(val);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      message('quot/num: ' || Sqlerrm);
      RAISE;
END;

/* ---------------------------------------------------------------------- */
FUNCTION quot(str IN VARCHAR2) RETURN VARCHAR2
  IS
     sout VARCHAR2(2000);
BEGIN
   IF(Length(str) > 1500) THEN
      message('string overflow');
      RAISE bad_parameter;
   END IF;

   IF(str IS NULL) THEN
      sout := 'NULL';
    ELSE
      -- escape quotes
      sout := REPLACE(str, '''', '''''');
      -- add surrounding quotes
      sout :=  '''' || sout || '''';
   END IF;
   RETURN sout;
EXCEPTION
   WHEN OTHERS THEN
      message('quot/str: ' || Sqlerrm);
      RAISE;
END;


/* ---------------------------------------------------------------------- */
/*  DUMP FUNCTIONS */
/* ---------------------------------------------------------------------- */
PROCEDURE dump_flexfield(flexfield IN flexfield_type,
			 recurse   IN BOOLEAN DEFAULT TRUE)
  IS
     CURSOR column_c IS
	SELECT column_name
       FROM fnd_columns
       WHERE application_id = flexfield.table_application_id
       AND table_id = flexfield.table_id
--       AND flexfield_application_id = flexfield.application_id
--       AND flexfield_name = flexfield.flex_code
       AND flexfield_usage_code = 'K'
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
BEGIN
   message_init;

   printbuf('/* FLEXFIELD */');
   printbuf('flexfield := fnd_flex_key_api.new_flexfield(');
   printbuf('appl_short_name             => ' || quot(flexfield.appl_short_name)             || ',');
   printbuf('flex_code                   => ' || quot(flexfield.flex_code)                   || ',');
   printbuf('flex_title                  => ' || quot(flexfield.flex_title)                  || ',');
   printbuf('description                 => ' || quot(flexfield.description)                 || ',');
   printbuf('table_appl_short_name       => ' || quot(flexfield.table_appl_short_name)       || ',');
   printbuf('table_name                  => ' || quot(flexfield.table_name)                  || ',');
   printbuf('unique_id_column            => ' || quot(flexfield.unique_id_column)            || ',');
   printbuf('structure_column            => ' || quot(flexfield.structure_column)            || ',');
   printbuf('dynamic_inserts             => ' || quot(flexfield.dynamic_inserts)             || ',');
   printbuf('allow_id_value_sets         => ' || quot(flexfield.allow_id_value_sets)         || ',');
   printbuf('index_flag                  => ' || quot(flexfield.index_flag)                  || ',');
   printbuf('concat_seg_len_max          => ' || quot(flexfield.concat_seg_len_max)          || ',');
   printbuf('concat_len_warning          => ' || quot(flexfield.concat_len_warning)          || ',');
   printbuf('concatenated_segs_view_name => ' || quot(flexfield.concatenated_segs_view_name) || ');');

   printbuf('fnd_flex_key_api.register(flexfield,');
   printbuf('enable_columns => ''N'');');

   FOR column_r IN column_c LOOP
      printbuf('/* ENABLE COLUMN */');
      printbuf('fnd_flex_key_api.enable_column(flexfield => flexfield,');
      printbuf('column_name => ' || quot(column_r.column_name) || ');');
   END LOOP;

   IF(recurse) THEN
	dump_all_flex_qualifiers(flexfield => flexfield,
				 recurse => recurse);
	dump_all_structures(flexfield => flexfield,
			    recurse => recurse);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      message('dump_flexfield: ' || Sqlerrm);
      RAISE;
END;

/* ---------------------------------------------------------------------- */
PROCEDURE dump_all_flex_qualifiers(flexfield IN flexfield_type,
				   recurse   IN BOOLEAN DEFAULT TRUE)
  IS
     CURSOR flex_qualifier_c IS
	SELECT *
	  FROM fnd_segment_attribute_types
	  WHERE application_id = flexfield.application_id
	  AND id_flex_code = flexfield.flex_code
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
BEGIN
   FOR flex_qualifier_r IN flex_qualifier_c LOOP
      printbuf('/* FLEX QUALIFIER */');
      printbuf('fnd_flex_key_api.add_flex_qualifier(flexfield => flexfield,');
      printbuf('qualifier_name => ' || quot(flex_qualifier_r.segment_attribute_type) || ',');
      printbuf('prompt         => ' || quot(flex_qualifier_r.segment_prompt)         || ',');
      printbuf('description    => ' || quot(flex_qualifier_r.description)            || ',');
      printbuf('global_flag    => ' || quot(flex_qualifier_r.global_flag)            || ',');
      printbuf('required_flag  => ' || quot(flex_qualifier_r.required_flag)          || ',');
      printbuf('unique_flag    => ' || quot(flex_qualifier_r.unique_flag)            || ');');

      IF(recurse) THEN
	 dump_all_seg_qualifiers(flexfield      => flexfield,
                                 flex_qualifier => flex_qualifier_r.segment_attribute_type);
      END IF;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      message('dump_all_flex_qualifiers: ' || Sqlerrm);
      RAISE;
END;


/* ---------------------------------------------------------------------- */
PROCEDURE dump_all_seg_qualifiers(flexfield      IN flexfield_type,
				  flex_qualifier IN VARCHAR2)
  IS
     CURSOR seg_qualifier_c IS
	SELECT *
	  FROM fnd_val_attribute_types_vl
	  WHERE application_id = flexfield.application_id
	  AND id_flex_code = flexfield.flex_code
	  AND segment_attribute_type = flex_qualifier
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
BEGIN
    FOR seg_qualifier_r IN seg_qualifier_c LOOP
      printbuf('/* SEGMENT QUALIFIER */');
      printbuf('fnd_flex_key_api.add_seg_qualifier(flexfield => flexfield,');
      printbuf('flex_qualifier => ' || quot(flex_qualifier)                          || ',');
      printbuf('qualifier_name => ' || quot(seg_qualifier_r.value_attribute_type)    || ',');
      printbuf('prompt         => ' || quot(seg_qualifier_r.prompt)                  || ',');
      printbuf('description    => ' || quot(seg_qualifier_r.description)             || ',');
      printbuf('derived_column => ' || quot(seg_qualifier_r.application_column_name) || ',');
      printbuf('quickcode_type => ' || quot(seg_qualifier_r.lookup_type)             || ',');
      printbuf('default_value  => ' || quot(seg_qualifier_r.default_value)           || ');');
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      message('dump_all_seg_qualifiers: ' || Sqlerrm);
      RAISE;
END;

/* ---------------------------------------------------------------------- */
PROCEDURE dump_all_structures(flexfield      IN flexfield_type,
			      recurse        IN BOOLEAN DEFAULT TRUE)
  IS
     structure structure_type;
BEGIN
   message_init;
   FOR structure_r IN structure_c(flexfield) LOOP
      structure := find_structure(flexfield => flexfield,
                                  structure_number => structure_r.structure_number);
      dump_structure(flexfield => flexfield,
		     structure => structure,
		     recurse => recurse);
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      message('dump_all_structures: ' || Sqlerrm);
      RAISE;
END;

/* ---------------------------------------------------------------------- */
PROCEDURE dump_structure(flexfield       IN flexfield_type,
			 structure       IN structure_type,
			 recurse         IN BOOLEAN DEFAULT TRUE)
  IS
BEGIN
   message_init;

   printbuf('/* STRUCTURE */');
   printbuf('structure := fnd_flex_key_api.new_structure(flexfield => flexfield,');
   printbuf('structure_code         => ' || quot(structure.structure_code)         || ',');
   printbuf('structure_title        => ' || quot(structure.structure_name)         || ',');
   printbuf('description            => ' || quot(structure.description)            || ',');
   printbuf('view_name              => ' || quot(structure.view_name)              || ',');
   printbuf('freeze_flag            => ' || quot(structure.freeze_flag)            || ',');
   printbuf('enabled_flag           => ' || quot(structure.enabled_flag)           || ',');
   printbuf('segment_separator      => ' || quot(structure.segment_separator)      || ',');
   printbuf ('cross_val_flag        => ' || quot(structure.cross_val_flag)         || ',');
   printbuf('freeze_rollup_flag     => ' || quot(structure.freeze_rollup_flag)     || ',');
   printbuf('dynamic_insert_flag    => ' || quot(structure.dynamic_insert_flag)    || ',');
   printbuf('shorthand_enabled_flag => ' || quot(structure.shorthand_enabled_flag) || ',');
   printbuf('shorthand_prompt       => ' || quot(structure.shorthand_prompt)       || ',');
   printbuf('shorthand_length       => ' || quot(structure.shorthand_length)       || ');');

   IF(structure.structure_number = 101) THEN
      printbuf('structure2 := fnd_flex_key_api.find_structure(');
      printbuf('flexfield => flexfield,');
      printbuf('structure_number => 101);');
      printbuf('fnd_flex_key_api.modify_structure(flexfield => flexfield,');
      printbuf('original => structure2,');
      printbuf('modified => structure);');
    ELSE
      printbuf('fnd_flex_key_api.add_structure(flexfield => flexfield,');
      printbuf('structure => structure);');
   END IF;

   IF(recurse) THEN
      dump_all_segments(flexfield => flexfield,
			structure => structure);
   END IF;

   flush;

EXCEPTION
   WHEN OTHERS THEN
      message('dump_structure: ' || Sqlerrm);
      RAISE;
END;

/* ---------------------------------------------------------------------- */
PROCEDURE dump_qualifier_assignments(flexfield       IN flexfield_type,
				     structure       IN structure_type,
				     segment         IN segment_type)
  IS
     CURSOR assignments_c IS
	SELECT sav.segment_attribute_type
	  FROM fnd_segment_attribute_values sav,
	  fnd_segment_attribute_types sat
	  WHERE sav.application_id = flexfield.application_id
	  AND sav.id_flex_code = flexfield.flex_code
	  AND sav.id_flex_num = structure.structure_number
	  AND sav.application_column_name = segment.column_name
	  AND sav.attribute_value = 'Y'
	  -- and not global
	  AND sat.application_id = sav.application_id
	  AND sat.id_flex_code = sav.id_flex_code
	  AND sat.segment_attribute_type = sav.segment_attribute_type
	  AND sat.global_flag = 'N'
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
BEGIN
   FOR assignments_r IN assignments_c LOOP
      printbuf('/* QUALIFIER ASSIGNMENT */');
      printbuf('fnd_flex_key_api.assign_qualifier(');
      printbuf('flexfield => flexfield,' );
      printbuf('structure => structure,' );
      printbuf('segment => segment,');
      printbuf('flexfield_qualifier => ' ||
	       quot(assignments_r.segment_attribute_type) || ',');
      printbuf('enable_flag => ''Y'');');
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      message('dump_qualifier_assignments: ' || Sqlerrm);
      RAISE;
END;

/* ---------------------------------------------------------------------- */
PROCEDURE dump_segment(flexfield       IN flexfield_type,
		       structure       IN structure_type,
		       segment         IN segment_type)
  IS
BEGIN
   message_init;

   printbuf('/* SEGMENT */');
   printbuf('segment := fnd_flex_key_api.new_segment(');
   printbuf('flexfield                 => flexfield,');
   printbuf('structure                 => structure,');
   printbuf('segment_name              => ' || quot(segment.segment_name)              || ',');
   printbuf('description               => ' || quot(segment.description)               || ',');
   printbuf('column_name               => ' || quot(segment.column_name)               || ',');
   printbuf('segment_number            => ' || quot(segment.segment_number)            || ',');
   printbuf('enabled_flag              => ' || quot(segment.enabled_flag)              || ',');
   printbuf('displayed_flag            => ' || quot(segment.displayed_flag)            || ',');
   printbuf('indexed_flag              => ' || quot(segment.indexed_flag)              || ',');
   printbuf('value_set                 => ' || quot(segment.value_set_name)            || ',');
   printbuf('default_type              => ' || quot(segment.default_type)              || ',');
   printbuf('default_value             => ' || quot(segment.default_value)             || ',');
   printbuf('required_flag             => ' || quot(segment.required_flag)             || ',');
   printbuf('security_flag             => ' || quot(segment.security_flag)             || ',');
   printbuf('range_code                => ' || quot(segment.range_code)                || ',');
   printbuf('display_size              => ' || quot(segment.display_size)              || ',');
   printbuf('description_size          => ' || quot(segment.description_size)          || ',');
   printbuf('concat_size               => ' || quot(segment.concat_size)               || ',');
   printbuf('lov_prompt                => ' || quot(segment.lov_prompt)                || ',');
   printbuf('window_prompt             => ' || quot(segment.window_prompt)             || ',');
   printbuf('runtime_property_function => ' || quot(segment.runtime_property_function) || ',');
   printbuf('additional_where_clause   => ' || quot(segment.additional_where_clause)   || ');');

   printbuf('fnd_flex_key_api.add_segment(flexfield => flexfield,');
   printbuf('structure => structure,');
   printbuf('segment => segment);');

   dump_qualifier_assignments(flexfield => flexfield,
			      structure => structure,
			      segment => segment);
   flush;

EXCEPTION
   WHEN OTHERS THEN
      message('dump_segment: ' || Sqlerrm);
      RAISE;
END;

/* ---------------------------------------------------------------------- */
PROCEDURE dump_all_segments(flexfield       IN flexfield_type,
			    structure       IN structure_type)
  IS
     segment segment_type;
BEGIN
   message_init;

   FOR segment_r IN segment_c(flexfield, structure) LOOP
      segment :=
	find_segment(flexfield => flexfield,
		     structure => structure,
		     segment_name => segment_r.segment_name);
      dump_segment(flexfield => flexfield,
		   structure => structure,
		   segment => segment);
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      message('dump_all_segments: ' || Sqlerrm);
      RAISE;
END;

/* ---------------------------------------------------------------------- */
PROCEDURE get_structures(flexfield    IN flexfield_type,
			 enabled_only IN BOOLEAN DEFAULT TRUE,
			 nstructures  OUT nocopy NUMBER,
			 structures   OUT nocopy structure_list)
  IS
     rv structure_list;
     i NUMBER;
     en_flag VARCHAR2(1);
BEGIN
   i := 0;
   IF(enabled_only) THEN
      en_flag := 'Y';
   END IF;
   FOR structure_r IN structure_c(flexfield, en_flag) LOOP
      i := i + 1;
      rv(i) := structure_r.structure_number;
   END LOOP;
   nstructures := i;
   structures := rv;
EXCEPTION
   WHEN OTHERS THEN
      message('get_structures: ' || Sqlerrm);
      RAISE;
END;

/* ---------------------------------------------------------------------- */
PROCEDURE get_segments(flexfield    IN flexfield_type,
		       structure    IN structure_type,
		       enabled_only IN BOOLEAN DEFAULT TRUE,
		       nsegments    OUT nocopy NUMBER,
		       segments     OUT nocopy segment_list)
  IS
     rv segment_list;
     i NUMBER;
     en_flag VARCHAR2(1);
BEGIN
   i := 0;
   IF(enabled_only) THEN
      en_flag := 'Y';
   END IF;
   FOR segment_r IN segment_c(flexfield, structure, en_flag) LOOP
      i := i + 1;
      rv(i) := segment_r.segment_name;
   END LOOP;
   nsegments := i;
   segments := rv;
EXCEPTION
   WHEN OTHERS THEN
      message('get_segments: ' || Sqlerrm);
      RAISE;
END;

FUNCTION is_table_used(p_application_id IN fnd_tables.application_id%TYPE,
		       p_table_name     IN fnd_tables.table_name%TYPE,
		       x_message        OUT nocopy VARCHAR2) RETURN BOOLEAN
  IS
     up_table_name fnd_tables.table_name%TYPE := Upper(p_table_name);
     l_a_id      fnd_id_flexs.application_id%TYPE;
     l_flex_code fnd_id_flexs.id_flex_code%TYPE;
     l_flex_name fnd_id_flexs.id_flex_name%TYPE;
BEGIN
   x_message := 'This table is not used by Key Flexfields.';
   BEGIN
      SELECT application_id, id_flex_code, id_flex_name
	INTO l_a_id, l_flex_code, l_flex_name
	FROM fnd_id_flexs
	WHERE table_application_id = p_application_id
	AND Upper(application_table_name) = up_table_name
	AND ROWNUM = 1
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
      x_message :=
	'This table is used by ' || chr_newline ||
	'APPLICATION_ID : ' || l_a_id || chr_newline ||
	'ID_FLEX_CODE : ' || l_flex_code || chr_newline ||
	'ID_FLEX_NAME : ' || l_flex_name;
      RETURN(TRUE);
   EXCEPTION
      WHEN no_data_found THEN
	 NULL;
      WHEN OTHERS THEN
	 x_message :=
	   'SELECT FROM FND_ID_FLEXS is failed. ' || chr_newline ||
	   'SQLERRM : ' || Sqlerrm;
	 RETURN(TRUE);
   END;
   RETURN(FALSE);
EXCEPTION
   WHEN OTHERS THEN
      x_message :=
	'FND_FLEX_KEY_API.IS_TABLE_USED is failed. ' || chr_newline ||
	'SQLERRM : ' || Sqlerrm;
      RETURN(TRUE);
END is_table_used;


FUNCTION is_column_used(p_application_id IN fnd_tables.application_id%TYPE,
			p_table_name     IN fnd_tables.table_name%TYPE,
			p_column_name    IN fnd_columns.column_name%TYPE,
			x_message        OUT nocopy VARCHAR2) RETURN BOOLEAN
  IS
     up_table_name fnd_tables.table_name%TYPE := Upper(p_table_name);
     up_column_name fnd_columns.column_name%TYPE := Upper(p_column_name);
     l_a_id      fnd_id_flexs.application_id%TYPE;
     l_flex_code fnd_id_flexs.id_flex_code%TYPE;
     l_flex_name fnd_id_flexs.id_flex_name%TYPE;
     l_flex_num  fnd_id_flex_segments.id_flex_num%TYPE;
     l_segment   fnd_id_flex_segments.segment_name%TYPE;
     l_seg_att   fnd_value_attribute_types.segment_attribute_type%TYPE;
     l_val_att   fnd_value_attribute_types.value_attribute_type%TYPE;
     l_id_col    fnd_id_flexs.unique_id_column_name%TYPE;
     l_set_col   fnd_id_flexs.set_defining_column_name%TYPE;
BEGIN
   x_message := 'This column is not used by Key Flexfields.';
   BEGIN
      SELECT application_id, id_flex_code, id_flex_name,
	unique_id_column_name
	INTO l_a_id, l_flex_code, l_flex_name, l_id_col
	FROM fnd_id_flexs
	WHERE table_application_id = p_application_id
	AND Upper(application_table_name) = up_table_name
	AND Upper(unique_id_column_name) = up_column_name
	AND ROWNUM = 1
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
      x_message :=
	'This column is used by ' || chr_newline ||
	'APPLICATION_ID : ' || l_a_id || chr_newline ||
	'ID_FLEX_CODE : ' || l_flex_code || chr_newline ||
	'ID_FLEX_NAME : ' || l_flex_name || chr_newline ||
	'UNIQUE_ID_COLUMN_NAME : ' || l_id_col;
      RETURN(TRUE);
   EXCEPTION
      WHEN no_data_found THEN
	 NULL;
      WHEN OTHERS THEN
	 x_message :=
	   'SELECT FROM FND_ID_FLEXS is failed. ' || chr_newline ||
	   'SQLERRM : ' || Sqlerrm;
	 RETURN(TRUE);
    END;
    BEGIN
      SELECT application_id, id_flex_code, id_flex_name,
	set_defining_column_name
	INTO l_a_id, l_flex_code, l_flex_name, l_set_col
	FROM fnd_id_flexs
	WHERE table_application_id = p_application_id
	AND Upper(application_table_name) = up_table_name
	AND set_defining_column_name IS NOT NULL
	AND Upper(set_defining_column_name) = up_column_name
	AND ROWNUM = 1
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
      x_message :=
	'This column is used by ' || chr_newline ||
	'APPLICATION_ID : ' || l_a_id || chr_newline ||
	'ID_FLEX_CODE : ' || l_flex_code || chr_newline ||
	'ID_FLEX_NAME : ' || l_flex_name || chr_newline ||
	'SET_DEFINING_COLUMN_NAME : ' || l_set_col;
      RETURN(TRUE);
   EXCEPTION
      WHEN no_data_found THEN
	 NULL;
      WHEN OTHERS THEN
	 x_message :=
	   'SELECT FROM FND_ID_FLEXS is failed. ' || chr_newline ||
	   'SQLERRM : ' || Sqlerrm;
	 RETURN(TRUE);
   END;

   BEGIN
      SELECT idf.application_id, idf.id_flex_code,
	idf.id_flex_name, ifst.id_flex_num, ifst.segment_name
	INTO l_a_id, l_flex_code, l_flex_name, l_flex_num, l_segment
	FROM fnd_id_flexs idf, fnd_id_flex_segments ifst
	WHERE idf.application_id = ifst.application_id
	AND idf.id_flex_code = ifst.id_flex_code
	AND idf.table_application_id = p_application_id
	AND Upper(idf.application_table_name) = up_table_name
	AND Upper(ifst.application_column_name) = up_column_name
	AND ROWNUM = 1
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
      x_message :=
	'This column is used by ' || chr_newline ||
	'APPLICATION_ID : ' || l_a_id || chr_newline ||
	'ID_FLEX_CODE : ' || l_flex_code || chr_newline ||
	'ID_FLEX_NAME : ' || l_flex_name || chr_newline ||
	'IF_FLEX_NUM : ' || l_flex_num || chr_newline ||
	'SEGMENT_NAME : ' || l_segment;
      RETURN(TRUE);
   EXCEPTION
      WHEN no_data_found THEN
	 NULL;
      WHEN OTHERS THEN
	 x_message :=
	   'SELECT FROM FND_ID_FLEX_SEGMENTS is failed. ' || chr_newline ||
	   'SQLERRM : ' || Sqlerrm;
	 RETURN(TRUE);
   END;

   BEGIN
      SELECT idf.application_id, idf.id_flex_code,
	idf.id_flex_name, vat.segment_attribute_type, vat.value_attribute_type
	INTO l_a_id, l_flex_code, l_flex_name, l_seg_att, l_val_att
	FROM fnd_id_flexs idf, fnd_value_attribute_types vat
	WHERE idf.application_id = vat.application_id
	AND idf.id_flex_code = vat.id_flex_code
	AND idf.table_application_id = p_application_id
	AND Upper(idf.application_table_name) = up_table_name
	AND Upper(vat.application_column_name) = up_column_name
	AND ROWNUM = 1
      AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;
      x_message :=
	'This column is used by ' || chr_newline ||
	'APPLICATION_ID : ' || l_a_id || chr_newline ||
	'ID_FLEX_CODE : ' || l_flex_code || chr_newline ||
	'ID_FLEX_NAME : ' || l_flex_name || chr_newline ||
	'FLEXFIELD_QUALIFER : ' || l_seg_att || chr_newline ||
	'SEGMENT_QUALIFIER : ' || l_val_att;
      RETURN(TRUE);
   EXCEPTION
      WHEN no_data_found THEN
	 NULL;
      WHEN OTHERS THEN
	 x_message :=
	   'SELECT FROM FND_VALUE_ATTRIBUTE_TYPES is failed. ' ||chr_newline||
	   'SQLERRM : ' || Sqlerrm;
	 RETURN(TRUE);
   END;
   RETURN(FALSE);
EXCEPTION
   WHEN OTHERS THEN
      x_message :=
	'FND_FLEX_KEY_API.IS_COLUMN_USED is failed. ' || chr_newline ||
	'SQLERRM : ' || Sqlerrm;
      RETURN(TRUE);
END is_column_used;

--
-- Get the segment display order given the qualifier name.
--
FUNCTION get_seg_order_by_qual_name(p_application_id         IN  NUMBER,
				    p_id_flex_code           IN  VARCHAR2,
				    p_id_flex_num            IN  NUMBER,
				    p_segment_attribute_type IN  VARCHAR2,
				    x_segment_order          OUT nocopy NUMBER)
  RETURN BOOLEAN IS
     l_segment_num   NUMBER;
     l_segment_order NUMBER;
BEGIN
   g_cache_key := (p_application_id || '.' || p_id_flex_code || '.' ||
		   p_id_flex_num || '.' || p_segment_attribute_type);

   fnd_plsql_cache.generic_1to1_get_value(soq_cache_controller,
					  soq_cache_storage,
					  g_cache_key,
					  g_cache_value,
					  g_cache_return_code);

   IF (g_cache_return_code = fnd_plsql_cache.CACHE_FOUND) THEN
      l_segment_order := g_cache_value.number_1;
    ELSE
      SELECT s.segment_num
	INTO l_segment_num
	FROM fnd_id_flex_segments s, fnd_segment_attribute_values sav,
	fnd_segment_attribute_types sat
	WHERE s.application_id = p_application_id
	AND s.id_flex_code = p_id_flex_code
	AND s.id_flex_num = p_id_flex_num
	AND s.enabled_flag = 'Y'
	AND s.application_column_name = sav.application_column_name
	AND sav.application_id = p_application_id
	AND sav.id_flex_code = p_id_flex_code
	AND sav.id_flex_num = p_id_flex_num
	AND sav.attribute_value = 'Y'
	AND sav.segment_attribute_type = sat.segment_attribute_type
	AND sat.application_id = p_application_id
	AND sat.id_flex_code = p_id_flex_code
	AND sat.unique_flag = 'Y'
	AND sat.segment_attribute_type = p_segment_attribute_type
	AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

      SELECT count(segment_num)
	INTO l_segment_order
	FROM fnd_id_flex_segments
	WHERE application_id = p_application_id
	AND id_flex_code = p_id_flex_code
	AND id_flex_num = p_id_flex_num
	AND enabled_flag = 'Y'
	AND segment_num <= l_segment_num
	AND '$Header: AFFFKAIB.pls 120.10.12010000.3 2016/03/11 22:17:50 tebarnes ship $' IS NOT NULL;

      fnd_plsql_cache.generic_cache_new_value
	(x_value    => g_cache_value,
	 p_number_1 => l_segment_order);

      fnd_plsql_cache.generic_1to1_put_value(soq_cache_controller,
					     soq_cache_storage,
					     g_cache_key,
					     g_cache_value);
   END IF;

   x_segment_order := l_segment_order;
   return(TRUE);

EXCEPTION
   WHEN OTHERS then
      return(FALSE);
END get_seg_order_by_qual_name;

--------------------------------------------------------------------------------
-- Wrapper for raise_application_error(<code>, <error>, TRUE);
--------------------------------------------------------------------------------
PROCEDURE raise_error
  (p_code  IN NUMBER,
   p_error IN VARCHAR2)
  IS
BEGIN
   raise_application_error(p_code, p_error, TRUE);

   -- No exception handling here
END raise_error;



--------------------------------------------------------------------------------
-- Raises exception for 'when others then' block
--------------------------------------------------------------------------------
PROCEDURE raise_others
  (p_method IN VARCHAR2,
   p_arg1   IN VARCHAR2 DEFAULT g_unused_argument,
   p_arg2   IN VARCHAR2 DEFAULT g_unused_argument,
   p_arg3   IN VARCHAR2 DEFAULT g_unused_argument,
   p_arg4   IN VARCHAR2 DEFAULT g_unused_argument,
   p_arg5   IN VARCHAR2 DEFAULT g_unused_argument,
   p_arg6   IN VARCHAR2 DEFAULT g_unused_argument,
   p_arg7   IN VARCHAR2 DEFAULT g_unused_argument,
   p_arg8   IN VARCHAR2 DEFAULT g_unused_argument,
   p_arg9   IN VARCHAR2 DEFAULT g_unused_argument)
  IS
   l_error VARCHAR2(32000);
BEGIN
   l_error := p_method || '(';

   if (p_arg1 <> g_unused_argument) then
      l_error := l_error || p_arg1;
   end if;

   if (p_arg2 <> g_unused_argument) then
      l_error := l_error || ', ' || p_arg2;
   end if;

   if (p_arg3 <> g_unused_argument) then
      l_error := l_error || ', ' || p_arg3;
   end if;

   if (p_arg4 <> g_unused_argument) then
      l_error := l_error || ', ' || p_arg4;
   end if;

   if (p_arg5 <> g_unused_argument) then
      l_error := l_error || ', ' || p_arg5;
   end if;

   if (p_arg6 <> g_unused_argument) then
      l_error := l_error || ', ' || p_arg6;
   end if;

   if (p_arg7 <> g_unused_argument) then
      l_error := l_error || ', ' || p_arg7;
   end if;

   if (p_arg8 <> g_unused_argument) then
      l_error := l_error || ', ' || p_arg8;
   end if;

   if (p_arg9 <> g_unused_argument) then
      l_error := l_error || ', ' || p_arg9;
   end if;

   l_error := l_error || ') raised exception.';

   raise_error(error_others, l_error);

   -- No exception handling here
END raise_others;


--------------------------------------------------------------------------------
-- Raises exception for 'when no_data_found then' block
--------------------------------------------------------------------------------
PROCEDURE raise_no_data_found
  (p_entity    IN VARCHAR2,
   p_key1      IN VARCHAR2,
   p_value1    IN VARCHAR2,
   p_key2      IN VARCHAR2 DEFAULT NULL,
   p_value2    IN VARCHAR2 DEFAULT NULL,
   p_key3      IN VARCHAR2 DEFAULT NULL,
   p_value3    IN VARCHAR2 DEFAULT NULL,
   p_key4      IN VARCHAR2 DEFAULT NULL,
   p_value4    IN VARCHAR2 DEFAULT NULL,
   p_key5      IN VARCHAR2 DEFAULT NULL,
   p_value5    IN VARCHAR2 DEFAULT NULL,
   p_key6      IN VARCHAR2 DEFAULT NULL,
   p_value6    IN VARCHAR2 DEFAULT NULL,
   p_key7      IN VARCHAR2 DEFAULT NULL,
   p_value7    IN VARCHAR2 DEFAULT NULL)
  IS
     l_error VARCHAR2(32000);
BEGIN
   l_error := ('<' || p_entity || '> does not exist. Primary Key: ' ||
               Upper(p_key1) || ':''' || p_value1 || '''');
   IF (p_key2 IS NOT NULL) THEN
      l_error := l_error || ', ' || Upper(p_key2) || ':''' || p_value2 || '''';
   END IF;
   IF (p_key3 IS NOT NULL) THEN
      l_error := l_error || ', ' || Upper(p_key3) || ':''' || p_value3 || '''';
   END IF;
   IF (p_key4 IS NOT NULL) THEN
      l_error := l_error || ', ' || Upper(p_key4) || ':''' || p_value4 || '''';
   END IF;
   IF (p_key5 IS NOT NULL) THEN
      l_error := l_error || ', ' || Upper(p_key5) || ':''' || p_value5 || '''';
   END IF;
   IF (p_key6 IS NOT NULL) THEN
      l_error := l_error || ', ' || Upper(p_key6) || ':''' || p_value6 || '''';
   END IF;
   IF (p_key7 IS NOT NULL) THEN
      l_error := l_error || ', ' || Upper(p_key7) || ':''' || p_value7 || '''';
   END IF;

   raise_error(error_no_data_found, l_error);

   -- No exception handling here.
END raise_no_data_found;


--------------------------------------------------------------------------------
-- Returns Application details.
--------------------------------------------------------------------------------
PROCEDURE get_app
  (p_application_short_name   IN  fnd_application.application_short_name%TYPE,
   x_app                      OUT nocopy app_type)
  IS
BEGIN
   BEGIN
      SELECT fa.*
        INTO x_app
        FROM fnd_application fa
        WHERE fa.application_short_name = p_application_short_name;
   EXCEPTION
      WHEN no_data_found THEN
         raise_no_data_found
           ('Application',
            'application_short_name', p_application_short_name);
   END;
EXCEPTION
   WHEN OTHERS THEN
      raise_others('get_app',
                   p_application_short_name);
END get_app;


-- Deletes compiled definition from fnd_compiled_id_flexs and fnd_compiled_id_flex_structs tables.

PROCEDURE delete_compiled_definition
   (p_application_id IN fnd_application.application_id%TYPE,
    p_id_flex_code   IN fnd_id_flexs.id_flex_code%TYPE,
    p_id_flex_num    IN fnd_id_flex_structures.id_flex_num%TYPE)
   IS
BEGIN

   DELETE FROM fnd_compiled_id_flexs
     WHERE application_id = p_application_id
     AND   id_flex_code   = p_id_flex_code;

   DELETE FROM fnd_compiled_id_flex_structs
     WHERE application_id = p_application_id
     AND   id_flex_code   = p_id_flex_code
     AND   id_flex_num    = p_id_flex_num;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;
END delete_compiled_definition;


-- Parses the AWC elements.
-- Returns an array of AWC elements.
-- Example of awc string:
-- ((1=1)
-- AND /* VALUE_GT_101 */
-- (FLEX_VALUE > '101')
-- AND /* VALUE_LT_999 */
-- (FLEX_VALUE < '999'))

PROCEDURE get_awc_elements
                 (p_flexfield               IN flexfield_type,
                  p_structure               IN structure_type,
                  p_segment                 IN segment_type,
                  x_numof_awc_elements      OUT nocopy number,
                  x_awc_elements            OUT nocopy awc_elements_type)
IS

 i             NUMBER := 0;
 l_str_length  NUMBER := 0;
 l_tag_length  NUMBER := 0;
 l_awc_length  NUMBER := 0;
 l_current_loc NUMBER := 1;
 l_first_occur NUMBER := 1;
 l_last_occur  NUMBER := 1;
 l_numof_awc_elements NUMBER := 0;
 l_awc_elements awc_elements_type;
 l_additional_where_clause fnd_id_flex_segments.additional_where_clause%TYPE;
 l_app app_type;


BEGIN

   get_app(p_flexfield.appl_short_name, l_app);

   SELECT additional_where_clause
   INTO l_additional_where_clause
   FROM fnd_id_flex_segments
   WHERE application_id = l_app.application_id
   AND id_flex_code = p_flexfield.flex_code
   AND id_flex_num = p_structure.structure_number
   AND application_column_name = p_segment.column_name;


   -- Get the length of the whole awc string
   l_str_length := length(l_additional_where_clause);

   IF (l_str_length > 0) THEN

     LOOP

        -- Exit loop when no more '/*' is found which means
        -- there are no more TAGS which also means there are
        -- no more WHERE CLAUSES
        IF(instr(l_additional_where_clause, '/*', l_current_loc) = 0) THEN
           EXIT;
        END IF;

        i := i+1; -- Count the number of awc

        -- Parse string to get the where clause TAG
        -- The TAG is in between the  characters /* */
        l_current_loc := instr(l_additional_where_clause, '/*', l_current_loc);
        l_first_occur := l_current_loc + 3;
        l_current_loc := instr(l_additional_where_clause, '*/', l_current_loc);
        l_last_occur  := l_current_loc - 1;
        l_tag_length  := l_last_occur - l_first_occur;

        -- Copy the TAG into the awc array
        l_awc_elements(i).tag :=
          substr(l_additional_where_clause, l_first_occur, l_tag_length);

        --------------

        -- Parse string to get the ADDITIONAL WHERE CLAUSE
        -- The WHERE CLAUSE is in between the  characters ( )
        -- We need to be careful because there could be nested parens
        -- within the main () which holds the awc i.e. ( col1 < (col3 - col2) )

        -- Get the first open paren which comes right after
        -- The closing '*/' for the Tag
        l_current_loc := instr(l_additional_where_clause, '(', l_current_loc);
        l_first_occur := l_current_loc + 1;

        -- To find the closing paren we search for the TAG of the
        -- next where clause, we then search backwards for the
        -- first occurance of the closig paren. This will give us
        -- the closing paren. We must do this because a WHERE
        -- clause could have nested parens so we cannot just
        -- look for the frst open paren and the next closing paren
        l_current_loc := instr(l_additional_where_clause, '/*', l_current_loc);


        -- If there are no more occurences of a Tag then that means we
        -- are at the last WHERE clause. To find the last ) we need to
        -- search backwards from the end. We need to find the second
        -- closing paren from the end because the very last ) is the closing
        -- of the whole string and not the last ) of the WHERE clause
        if(l_current_loc = 0) then
           l_current_loc := 1;
           -- Find the last closing paren
           l_current_loc:=instr(l_additional_where_clause, ')', -l_current_loc);
           -- Move the current loc past the last closing paren
           -- so we can find the second to the last closing paren
           l_current_loc := (l_awc_length - (l_current_loc -2));

        else
           -- When instr searches backwards it searches from location
           -- specified by l_current_loc reading from R2L
           -- This gives the position of the next '/*' counting from end R2L
           l_current_loc := l_str_length - l_current_loc;
        end if;

        l_current_loc := instr(l_additional_where_clause, ')', -l_current_loc);
        l_last_occur  := l_current_loc - 0;
        l_awc_length  := l_last_occur - l_first_occur;


        -- Copy the WHERE CLAUSE into the awc array
        l_awc_elements(i).clause :=
          substr(l_additional_where_clause, l_first_occur, l_awc_length);

        -- Update the Current location pointer
        l_current_loc := l_last_occur;


     END LOOP;

     x_numof_awc_elements := i;
     x_awc_elements := l_awc_elements;

   ELSE
     l_awc_elements(1).tag := NULL;
     l_awc_elements(1).clause := NULL;
     x_numof_awc_elements := 0;
     x_awc_elements := l_awc_elements;
   END IF;


   EXCEPTION
      WHEN no_data_found THEN
         raise_no_data_found
           ('Get AWC Elements',
            'application_id', l_app.application_id,
            'id_flex_code', p_flexfield.flex_code,
            'id_flex_num', p_structure.structure_number,
            'application_column_name', p_segment.column_name);

END get_awc_elements;


PROCEDURE add_awc(p_flexfield               IN flexfield_type,
                  p_structure               IN structure_type,
                  p_segment                 IN segment_type,
                  p_tag                     IN varchar2,
                  p_clause                  IN varchar2)
          IS
l_numof_awc_elements NUMBER := 0;
l_awc_elements awc_elements_type;
l_additional_where_clause fnd_id_flex_segments.additional_where_clause%TYPE;
l_application_id fnd_id_flex_segments.application_id%TYPE;
l_app app_type;

BEGIN

  -- Check for white space in tag.

  IF ((instr(p_tag, ' ') > 0) OR
      (instr(p_tag, chr_newline) > 0) OR
      (instr(p_tag, fnd_global.tab) > 0)) THEN
    raise_application_error(error_tag_white_space, 'The tag cannot have white space in it.', TRUE);
  END IF;

  -- Check for maximum length of TAG.

  IF (length(p_tag) > 30) THEN
    raise_application_error(error_tag_max_length, 'Maximum length of tag is 30.', TRUE);
  END IF;

  -- Check for comments (/*, */) in CLAUSE.

  IF ((instr(p_clause, '/*') > 0) OR
      (instr(p_clause, '*') > 0)) THEN
    raise_application_error(error_clause_comments, 'The clause contains /* or */ string.', TRUE);
  END IF;

  -- Get the existing tags and clauses.

   get_awc_elements
      (p_flexfield => p_flexfield,
       p_structure => p_structure,
       p_segment => p_segment,
       x_numof_awc_elements => l_numof_awc_elements,
       x_awc_elements => l_awc_elements);

   get_app(p_flexfield.appl_short_name, l_app);

   l_additional_where_clause := chr_newline;
   l_additional_where_clause := l_additional_where_clause||'((1=1)';
   l_additional_where_clause := l_additional_where_clause||chr_newline;

   FOR i in 1 .. l_numof_awc_elements LOOP
      IF (l_awc_elements(i).tag = p_tag) THEN
         raise_application_error(error_tag_exists, 'Tag already present', TRUE);
      ELSIF (l_awc_elements(i).clause = p_clause) THEN
         raise_application_error(error_clause_exists, 'Clause already present for TAG '||l_awc_elements(i).tag, TRUE);
      ELSE
         l_additional_where_clause := l_additional_where_clause||'AND /* ';
         l_additional_where_clause := l_additional_where_clause||l_awc_elements(i).tag;
         l_additional_where_clause := l_additional_where_clause||' */';
         l_additional_where_clause := l_additional_where_clause||chr_newline;
         l_additional_where_clause := l_additional_where_clause||'(';
         l_additional_where_clause := l_additional_where_clause||l_awc_elements(i).clause;
         l_additional_where_clause := l_additional_where_clause||')';
         l_additional_where_clause := l_additional_where_clause||chr_newline;
      END IF;
   END LOOP;

   l_additional_where_clause := l_additional_where_clause||'AND /* ';
   l_additional_where_clause := l_additional_where_clause||p_tag;
   l_additional_where_clause := l_additional_where_clause||' */';
   l_additional_where_clause := l_additional_where_clause||chr_newline;
   l_additional_where_clause := l_additional_where_clause||'(';
   l_additional_where_clause := l_additional_where_clause||p_clause;
   l_additional_where_clause := l_additional_where_clause||')';
   l_additional_where_clause := l_additional_where_clause||chr_newline;

   l_additional_where_clause := l_additional_where_clause||')';
   l_additional_where_clause := l_additional_where_clause||chr_newline;

   -- Update the segments' additional_where_clause column.

   UPDATE fnd_id_flex_segments
      SET additional_where_clause = l_additional_where_clause
      WHERE application_id = l_app.application_id
      AND id_flex_code = p_flexfield.flex_code
      AND id_flex_num = p_structure.structure_number
      AND application_column_name = p_segment.column_name;

   -- Delete compiled definition.

   delete_compiled_definition(l_app.application_id, p_flexfield.flex_code, p_structure.structure_number);

END add_awc;


PROCEDURE delete_awc(p_flexfield               IN flexfield_type,
                     p_structure               IN structure_type,
                     p_segment                 IN segment_type,
                     p_tag                     IN varchar2)
          IS
l_numof_awc_elements NUMBER := 0;
l_awc_elements awc_elements_type;
l_additional_where_clause fnd_id_flex_segments.additional_where_clause%TYPE;
l_application_id fnd_id_flex_segments.application_id%TYPE;
l_found  boolean;
l_app app_type;

BEGIN

  -- Get the existing tags and clauses.

   get_awc_elements
      (p_flexfield => p_flexfield,
       p_structure => p_structure,
       p_segment => p_segment,
       x_numof_awc_elements => l_numof_awc_elements,
       x_awc_elements => l_awc_elements);

   get_app(p_flexfield.appl_short_name, l_app);

   l_additional_where_clause := chr_newline;
   l_additional_where_clause := l_additional_where_clause||'((1=1)';
   l_additional_where_clause := l_additional_where_clause||chr_newline;

   l_found := FALSE;
   FOR i in 1 .. l_numof_awc_elements LOOP
      IF (l_awc_elements(i).tag = p_tag) THEN
           l_found := TRUE;
      ELSE
         l_additional_where_clause := l_additional_where_clause||'AND /* ';
         l_additional_where_clause := l_additional_where_clause||l_awc_elements(i).tag;
         l_additional_where_clause := l_additional_where_clause||' */';
         l_additional_where_clause := l_additional_where_clause||chr_newline;
         l_additional_where_clause := l_additional_where_clause||'(';
         l_additional_where_clause := l_additional_where_clause||l_awc_elements(i).clause;
         l_additional_where_clause := l_additional_where_clause||')';
         l_additional_where_clause := l_additional_where_clause||chr_newline;
      END IF;
   END LOOP;

   IF (NOT l_found) then
	   raise_application_error(error_tag_not_exists, 'Tag not found', TRUE);
   END IF;

   l_additional_where_clause := l_additional_where_clause||')';
   l_additional_where_clause := l_additional_where_clause||chr_newline;

   -- Update the segments' additional_where_clause column.

   UPDATE fnd_id_flex_segments
      SET additional_where_clause = l_additional_where_clause
      WHERE application_id = l_app.application_id
      AND id_flex_code = p_flexfield.flex_code
      AND id_flex_num = p_structure.structure_number
      AND application_column_name = p_segment.column_name;

   -- Delete compiled definition.

   delete_compiled_definition(l_app.application_id, p_flexfield.flex_code, p_structure.structure_number);

END delete_awc;


FUNCTION awc_exists(p_flexfield               IN flexfield_type,
                     p_structure               IN structure_type,
                     p_segment                 IN segment_type,
                     p_tag                     IN varchar2)
         RETURN BOOLEAN IS
l_numof_awc_elements NUMBER := 0;
l_awc_elements awc_elements_type;

BEGIN

  -- Get the existing tags and clauses.

   get_awc_elements
      (p_flexfield => p_flexfield,
       p_structure => p_structure,
       p_segment => p_segment,
       x_numof_awc_elements => l_numof_awc_elements,
       x_awc_elements => l_awc_elements);

   FOR i in 1 .. l_numof_awc_elements LOOP
      IF (l_awc_elements(i).tag = p_tag) THEN
           RETURN TRUE;
      END IF;
   END LOOP;

   RETURN FALSE;

END awc_exists;

--
-- Remove all key flexfields whose base table is not registered in fnd_tables
--

  PROCEDURE delete_missing_tbl_flexs IS

    l_limit_read NUMBER := 1000;

    CURSOR missing_KFF_base_tbl IS
      SELECT an.application_short_name,
             kf.id_flex_code,
             kf.id_flex_name,
             kf.application_table_name
        FROM fnd_id_flexs kf, fnd_application an
       WHERE NOT EXISTS
                 (SELECT NULL
                    FROM fnd_tables t
                   WHERE t.table_name = kf.application_table_name)
         AND an.application_id = kf.application_id;

  BEGIN
      OPEN missing_KFF_base_tbl;

      -- Key LOOP
      LOOP
        FETCH missing_KFF_base_tbl
         BULK COLLECT
          INTO v_keys
         LIMIT l_limit_read;

        EXIT WHEN(v_keys.COUNT = 0);

        FOR l_row IN v_keys.FIRST .. v_keys.LAST LOOP

          delete_flexfield( v_keys(l_row).k_app_short_name ,
                      v_keys(l_row).k_id_flex_code );

        END LOOP l_row;

      END LOOP; -- End Key Loop

      CLOSE missing_KFF_base_tbl;

  END delete_missing_tbl_flexs;

--
-- Cleanup both key and descriptive flexfields for data dictionary cleanup
-- initiative.  Requires removal of all key and descriptive flexfields
-- whose base table is not registered in fnd_tables.  The fnd_tables was
-- cleaned as part of the data dictionary cleanup initiative.  All entries
-- were removed when not found in either dba_tables, dba_views, or
-- dba_synonyms.  Flexfield base tables may be a table, view, or synonym.
--


  PROCEDURE cleanup_flex_tables IS

  BEGIN
     fnd_flex_dsc_api.set_session_mode('customer_data');
     fnd_flex_key_api.set_session_mode('customer_data');

     fnd_flex_dsc_api.delete_missing_tbl_flexs;
     fnd_flex_key_api.delete_missing_tbl_flexs;

  EXCEPTION
     WHEN OTHERS THEN
      message('cleanup_flex_tables failed ');
      RAISE;


  END cleanup_flex_tables;


BEGIN
   fnd_plsql_cache.generic_1to1_init('KAI.SOQ',
				     soq_cache_controller,
				     soq_cache_storage);

END fnd_flex_key_api;

/
