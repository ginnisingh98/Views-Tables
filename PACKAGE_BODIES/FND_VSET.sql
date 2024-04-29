--------------------------------------------------------
--  DDL for Package Body FND_VSET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_VSET" AS
/* $Header: AFFFVDUB.pls 120.3.12010000.1 2008/07/25 14:14:50 appldev ship $ */


CURSOR value_c(valueset IN valueset_r,
	       enabled IN fnd_flex_values.enabled_flag%TYPE)
  RETURN value_dr
IS
     SELECT /* $Header: AFFFVDUB.pls 120.3.12010000.1 2008/07/25 14:14:50 appldev ship $ */
       flex_value,
       flex_value, description,
       start_date_active, end_date_active,
       parent_flex_value_low
       FROM fnd_flex_values_vl
       WHERE flex_value_set_id = valueset.vsid
       AND enabled_flag = enabled
       ORDER BY 1;


CURSOR value_d(valueset IN valueset_r,
  enabled IN fnd_flex_values.enabled_flag%TYPE)
  RETURN value_dr
IS
     SELECT /* $Header: AFFFVDUB.pls 120.3.12010000.1 2008/07/25 14:14:50 appldev ship $ */
       flex_value,
       flex_value_meaning, description,
       start_date_active, end_date_active,
       parent_flex_value_low
       FROM fnd_flex_values_vl
       WHERE flex_value_set_id = valueset.vsid
       AND enabled_flag = enabled
       ORDER BY 1;

debug_mode BOOLEAN; -- := false;
cursor_handle INTEGER;

PROCEDURE debug(state IN BOOLEAN) IS
BEGIN
   debug_mode := state;
END;

PROCEDURE dbms_debug(p_debug IN VARCHAR2)
  IS
     i INTEGER;
     m INTEGER;
     c INTEGER; -- := 75;
BEGIN
   c := 75;
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

PROCEDURE dbgprint(s IN VARCHAR2) IS
BEGIN
   IF(debug_mode) THEN
      dbms_debug(s);
   END IF;
END;

FUNCTION to_boolean(value IN VARCHAR2) RETURN BOOLEAN
  IS
     rv BOOLEAN;
BEGIN
   IF(value in ('Y', 'y')) THEN
      rv := TRUE;
    ELSE
      rv := FALSE;
   END IF;
   RETURN rv;
END;

FUNCTION to_flag(value IN BOOLEAN) RETURN VARCHAR2
  IS
     rv VARCHAR2(1);
BEGIN
   IF(value) THEN
      rv := 'Y';
    ELSE
      rv := 'N';
   END IF;
   RETURN rv;
END;


PROCEDURE get_valueset(valueset_id IN fnd_flex_values.flex_value_set_id%TYPE,
		       valueset    OUT nocopy valueset_r,
		       format      OUT nocopy valueset_dr)
  IS
     vset valueset_r;
     fmt  valueset_dr;
     table_info table_r;
BEGIN
   SELECT /* $Header: AFFFVDUB.pls 120.3.12010000.1 2008/07/25 14:14:50 appldev ship $ */
     flex_value_set_id, flex_value_set_name,
     validation_type
     INTO vset.vsid, vset.name, vset.validation_type
     FROM fnd_flex_value_sets
     WHERE flex_value_set_id = valueset_id;

   SELECT /* $Header: AFFFVDUB.pls 120.3.12010000.1 2008/07/25 14:14:50 appldev ship $ */
     format_type, alphanumeric_allowed_flag,
     uppercase_only_flag, numeric_mode_enabled_flag,
     maximum_size, maximum_value, minimum_value,
     longlist_flag
     INTO fmt.format_type, fmt.alphanumeric_allowed_flag,
     fmt.uppercase_only_flag, fmt.numeric_mode_flag,
     fmt.max_size, fmt.max_value, fmt.min_value,
     fmt.longlist_flag
     FROM fnd_flex_value_sets
     WHERE flex_value_set_id = valueset_id;

   fmt.longlist_enabled := (fmt.longlist_flag = 'Y');
   valueset := vset;
   IF(vset.validation_type = 'F') THEN	 -- table validated
      SELECT /* $Header: AFFFVDUB.pls 120.3.12010000.1 2008/07/25 14:14:50 appldev ship $ */
	application_table_name, id_column_name, id_column_type,
	value_column_name, meaning_column_name,
	additional_where_clause,
	start_date_column_name, end_date_column_name
	INTO table_info
	FROM fnd_flex_validation_tables
	WHERE flex_value_set_id = vset.vsid;
      valueset.table_info := table_info;
      fmt.has_id := (table_info.id_column_name IS NOT NULL);
      fmt.has_meaning:= (table_info.meaning_column_name IS NOT NULL);
    ELSE
      fmt.has_id := FALSE;
      fmt.has_meaning:= TRUE;
   END IF;
   format := fmt;
   dbgprint('returning valueset:' || vset.name);
END;


PROCEDURE make_cursor(valueset  IN  valueset_r)
  IS
     sqlstring VARCHAR2(32767);
     cols VARCHAR2(1500);
     dummy_vc VARCHAR2(1);
     dummy_num NUMBER;
     dummy_int INTEGER;
     dummy_date DATE;
     table_info table_r;
     /* these are from the tables - should really be doing a select */
     max_id_size NUMBER; -- := 150;
     max_val_size NUMBER; -- := 150;
     max_meaning_size NUMBER; -- := 240;
BEGIN
   max_id_size := 150;
   max_val_size := 150;
   max_meaning_size := 240;
   dbgprint('make_cursor: making new cursor (table) ...');
   table_info := valueset.table_info;
   cols :=
     table_info.start_date_column_name || ', ' ||
     table_info.end_date_column_name || ', ' ||
     table_info.value_column_name;
   IF(table_info.meaning_column_name IS NOT NULL) THEN
      dbgprint('  using meaning column since it is not null ('
               || table_info.meaning_column_name || ')');
      cols := cols || ' , ' || table_info.meaning_column_name || ' ' ||
              'DESCRIPTION';
    ELSE
      cols := cols || ', NULL ';
   END IF;
   IF (table_info.id_column_name IS NOT NULL) THEN
      dbgprint('  using id column since it is not null ('
               || table_info.id_column_name || ')');

      --
      -- to_char() conversion function is defined only for
      -- DATE and NUMBER datatypes.
      --
      IF (table_info.id_column_type IN ('D', 'N')) THEN
         dbgprint(' using to_char(id_column_name). '
                  || 'id_column_type :('||table_info.id_column_type||')');
         cols := cols || ' , To_char(' || table_info.id_column_name || ')';
      ELSE
         dbgprint(' NOT using to_char(id_column_name). '
                  || 'id_column_type :('||table_info.id_column_type||')');
         cols := cols || ' , ' || table_info.id_column_name || ' ' ||
                 'ID_COL';
      END IF;
   ELSE
      cols := cols || ', NULL ';
   END IF;
   sqlstring := 'select ' || cols ||
     ' from ' || table_info.table_name ||
     '  ' || table_info.where_clause;
   dbgprint('  sql stmt = ' || sqlstring);
   cursor_handle := dbms_sql.open_cursor;
   dbms_sql.parse(cursor_handle, sqlstring, dbms_sql.native);
   dbms_sql.define_column(cursor_handle, 1, dummy_date);
   dbms_sql.define_column(cursor_handle, 2, dummy_date);
   dbms_sql.define_column(cursor_handle, 3, dummy_vc, max_val_size);
   dbms_sql.define_column(cursor_handle, 4, dummy_vc, max_meaning_size);
   dbms_sql.define_column(cursor_handle, 5, dummy_vc, max_id_size);
   dummy_int := dbms_sql.execute(cursor_handle);
END;

PROCEDURE get_value_init(valueset     IN  valueset_r,
			 enabled_only IN  BOOLEAN)
  IS
BEGIN
   dbgprint('get_value_init: opening cursor...');
   IF(valueset.validation_type in ('I', 'D')) THEN
      IF value_c%isopen THEN
	 CLOSE value_c;
      END IF;
      OPEN value_c(valueset, to_flag(enabled_only));
   ELSIF(valueset.validation_type in ('X', 'Y')) THEN
      IF value_d%isopen THEN
         CLOSE value_d;
      END IF;
      OPEN value_d(valueset, to_flag(enabled_only));
   ELSIF(valueset.validation_type = 'F') THEN
      make_cursor(valueset);
   END IF;
   dbgprint('get_value_init: done.');
END;


PROCEDURE get_value(valueset     IN  valueset_r,
		    rowcount     OUT nocopy NUMBER,
		    found        OUT nocopy BOOLEAN,
		    value        OUT nocopy value_dr)
  IS
     value_i value_dr;
BEGIN
   dbgprint('get_value: getting a value...');
   IF(valueset.validation_type in ('I', 'D')) THEN
      dbgprint('get_value: doing fetch (indep, or dep) ...');
      FETCH value_c INTO value_i;
      dbgprint('get_value: assigning values (indep, or dep) ...');
      value := value_i;
      found := value_c%found;
    ELSIF(valueset.validation_type in ('X', 'Y')) THEN
      dbgprint('get_value: doing fetch (trans indep, or dep) ...');
      FETCH value_d INTO value_i;
      dbgprint('get_value: assigning values (trans indep,or dep) ...');
      value := value_i;
      found := value_d%found;
    ELSIF(valueset.validation_type = 'F') THEN
      dbgprint('get_value: doing fetch (table) ...');
      found := (dbms_sql.fetch_rows(cursor_handle) > 0);
      dbgprint('get_value: assigning values (table) ...');
      dbms_sql.column_value(cursor_handle, 1, value.start_date_active);
      dbms_sql.column_value(cursor_handle, 2, value.end_date_active);
      dbms_sql.column_value(cursor_handle, 3, value.value);
      dbms_sql.column_value(cursor_handle, 4, value.meaning);
      dbms_sql.column_value(cursor_handle, 5, value.id);
   END IF;
   rowcount := NULL;
   dbgprint('get_value: done.');
END;


PROCEDURE get_value_end(valueset IN valueset_r)
  IS
BEGIN
   dbgprint('get_value_end: closing cursor...');
   IF(valueset.validation_type in ('I', 'D')) THEN
      IF value_c%isopen THEN
	 CLOSE value_c;
      END IF;
    ELSIF(valueset.validation_type in ('X', 'Y')) THEN
      IF value_d%isopen THEN
         CLOSE value_d;
      END IF;
    ELSIF(valueset.validation_type = 'F') THEN
      IF(dbms_sql.is_open(cursor_handle)) THEN
	 dbms_sql.close_cursor(cursor_handle);
      END IF;
   END IF;
   dbgprint('get_value_end: done.');
END;

FUNCTION To_str(val BOOLEAN) RETURN VARCHAR2 IS
   rv VARCHAR2(100);
BEGIN
   IF(val) THEN
      rv := 'TRUE';
    ELSE
      rv := 'FALSE';
   END IF;
   RETURN rv;
END;

PROCEDURE test(vsid IN NUMBER) IS
   vset valueset_r;
   fmt valueset_dr;
   found BOOLEAN;
   row NUMBER;
   value value_dr;
BEGIN
   get_valueset(vsid, vset, fmt);
   get_value_init(vset, TRUE);
   dbms_debug('valueset=' || vset.name);
   dbms_debug('type=' || vset.validation_type);
   dbms_debug('has id=' || To_str(fmt.has_id));
   dbms_debug('has meaning=' || To_str(fmt.has_meaning));
   get_value(vset, row, found, value);
   WHILE(found) LOOP
      dbms_debug('value=' || value.value ||
		 '; meaning=' || value.meaning ||
		 '; id=' || value.id ||
		 '; dates=' || To_char(value.start_date_active) ||
		 '/' || To_char(value.end_date_active) ||
                 '; ind value=' || value.parent_flex_value_low);
      get_value(vset, row, found, value);
   END LOOP;
   get_value_end(vset);
END;

PROCEDURE test_independent IS
BEGIN
   test(102429);
END;

PROCEDURE test_table IS
BEGIN
--   test(103473);			/* applications */
   test(103473);			/* fnd_flex_values */
END;

BEGIN
   debug_mode := FALSE;

END fnd_vset;			/* end package */

/
