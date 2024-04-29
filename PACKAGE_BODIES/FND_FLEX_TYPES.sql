--------------------------------------------------------
--  DDL for Package Body FND_FLEX_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_TYPES" AS
/* $Header: AFFFTYPB.pls 120.2.12010000.1 2008/07/25 14:14:34 appldev ship $ */



PROCEDURE validate_type(typ IN VARCHAR2, code IN VARCHAR2) IS
   dummy NUMBER;
BEGIN
   SELECT NULL INTO dummy
     FROM fnd_lookups
     WHERE lookup_type = typ
     AND lookup_code = code
     AND enabled_flag = 'Y'
     AND ( (start_date_active IS NULL)
           OR (start_date_active <= SYSDATE))
     AND ( (end_date_active IS NULL)
           OR (end_date_active >= SYSDATE));
EXCEPTION
   WHEN no_data_found THEN
      RAISE;
END;



PROCEDURE validate_default_type(code IN VARCHAR2) IS
BEGIN
   validate_type(typ => 'FLEX_DEFAULT_TYPE', code => code);
END;


PROCEDURE validate_range_code(code IN VARCHAR2) IS
BEGIN
   validate_type(typ => 'RANGE_CODES', code => code);
END;


PROCEDURE validate_field_type(code IN VARCHAR2) IS
BEGIN
   validate_type(typ => 'FIELD_TYPE', code => code);
END;


PROCEDURE validate_segval_type(code IN VARCHAR2) IS
BEGIN
   validate_type(typ => 'SEG_VAL_TYPES', code => code);
END;


PROCEDURE validate_event_type(code IN VARCHAR2) IS
BEGIN
   validate_type(typ => 'FLEX_VALIDATION_EVENTS', code => code);
END;


PROCEDURE validate_column_type(code IN VARCHAR2) IS
BEGIN
   validate_type(typ => 'COLUMN_TYPE', code => code);
END;

PROCEDURE validate_yes_no_flag(code IN VARCHAR2) IS
BEGIN
   validate_type(typ => 'YES_NO', code => code);
END;

FUNCTION get_code(typ IN VARCHAR2, descr IN VARCHAR2) RETURN VARCHAR2
  IS
     CURSOR codes_c IS
	SELECT lookup_code, Decode(language, 'US', 1, 2) pri
	  FROM fnd_lookup_values
	  WHERE meaning = descr
	  AND lookup_type = typ
	  ORDER BY pri;
     codes_r codes_c%ROWTYPE;
     rv fnd_lookups.lookup_code%TYPE;
BEGIN
   OPEN codes_c;
   FETCH codes_c INTO codes_r;
   IF(codes_c%found) THEN
      rv := codes_r.lookup_code;
    ELSE
      RAISE no_data_found;
   END IF;
   CLOSE codes_c;
   RETURN rv;
EXCEPTION
   WHEN OTHERS THEN
      CLOSE codes_c;
      RAISE;
END;

FUNCTION ad_dd_used_by_flex(p_application_id IN fnd_tables.application_id%TYPE,
			    p_table_name     IN fnd_tables.table_name%TYPE,
			    p_column_name    IN fnd_columns.column_name%TYPE,
			    x_message        OUT NOCOPY VARCHAR2) RETURN BOOLEAN
  IS
     l_message VARCHAR2(2000);
BEGIN
   IF (p_column_name IS NULL) THEN
      x_message := 'This table is not used by Flexfields.';
      IF (fnd_flex_dsc_api.is_table_used(p_application_id,
					 p_table_name,
					 l_message)) THEN
	 x_message := l_message;
	 RETURN(TRUE);
      END IF;
      IF (fnd_flex_key_api.is_table_used(p_application_id,
					 p_table_name,
					 l_message)) THEN
	 x_message := l_message;
	 RETURN(TRUE);
      END IF;
      IF (fnd_flex_val_api.is_table_used(p_application_id,
					 p_table_name,
					 l_message)) THEN
	 x_message := l_message;
	 RETURN(TRUE);
      END IF;
    ELSE
      x_message := 'This column is not used by Flexfields.';
      IF (fnd_flex_dsc_api.is_column_used(p_application_id,
					  p_table_name,
					  p_column_name,
					  l_message)) THEN
	 x_message := l_message;
	 RETURN(TRUE);
      END IF;
      IF (fnd_flex_key_api.is_column_used(p_application_id,
					  p_table_name,
					  p_column_name,
					  l_message)) THEN
	 x_message := l_message;
	 RETURN(TRUE);
      END IF;
      IF (fnd_flex_val_api.is_column_used(p_application_id,
					  p_table_name,
					  p_column_name,
					  l_message)) THEN
	 x_message := l_message;
	 RETURN(TRUE);
      END IF;
   END IF;
   RETURN(FALSE);
EXCEPTION
   WHEN OTHERS THEN
      x_message := 'FND_FLEX_TYPES.AD_DD_USED_BY_FLEX is failed. ' ||
	'SQLERRM : ' || Sqlerrm;
      RETURN(TRUE);
END ad_dd_used_by_flex;

END fnd_flex_types;			/* end package */

/
