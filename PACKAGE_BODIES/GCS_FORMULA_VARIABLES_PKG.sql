--------------------------------------------------------
--  DDL for Package Body GCS_FORMULA_VARIABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_FORMULA_VARIABLES_PKG" AS
/* $Header: gcserfvb.pls 120.1 2005/10/30 05:18:19 appldev noship $ */
--
-- Package
--   gcs_formula_variables_pkg
-- Purpose
--   Package procedures for Lexical Mapping Structures
-- History
--   27-APR-04	J Huang  	Created
--

  PROCEDURE Insert_Row(	row_id	IN OUT NOCOPY	VARCHAR2,
			user_variable_name	VARCHAR2,
			rule_type_code		VARCHAR2,
			sql_statement_value 	NUMBER,
			compiled_variable_name	VARCHAR2,
			sql_expression       	VARCHAR2,
			last_update_date	DATE,
			last_updated_by		NUMBER,
			last_update_login	NUMBER,
			creation_date		DATE,
			created_by		NUMBER) IS
    CURSOR	var_row IS
    SELECT	rowid
    FROM	gcs_formula_variables fv
    WHERE	fv.user_variable_name = insert_row.user_variable_name;
  BEGIN
    IF user_variable_name IS NULL THEN
      raise no_data_found;
    END IF;

    INSERT INTO gcs_formula_variables(	user_variable_name,
					rule_type_code,
					sql_statement_value,
					compiled_variable_name,
					sql_expression,
					last_update_date,
					last_updated_by,
					last_update_login,
					creation_date,
					created_by)
    SELECT	user_variable_name,
		rule_type_code,
		sql_statement_value,
		compiled_variable_name,
		sql_expression,
		last_update_date,
		last_updated_by,
		last_update_login,
		creation_date,
		created_by
    FROM	dual
    WHERE	NOT EXISTS
		(SELECT	1
		 FROM	gcs_formula_variables fv
		 WHERE	fv.user_variable_name = insert_row.user_variable_name);

    OPEN var_row;
    FETCH var_row INTO row_id;
    IF var_row%NOTFOUND THEN
      CLOSE var_row;
      raise no_data_found;
    END IF;
    CLOSE var_row;
  END Insert_Row;

  PROCEDURE Update_Row(	user_variable_name	VARCHAR2,
			rule_type_code		VARCHAR2,
			sql_statement_value 	NUMBER,
			compiled_variable_name	VARCHAR2,
			sql_expression       	VARCHAR2,
			last_update_date	DATE,
			last_updated_by		NUMBER,
			last_update_login	NUMBER) IS
  BEGIN
    UPDATE	gcs_formula_variables fv
    SET		rule_type_code		= update_row.rule_type_code,
		sql_statement_value	= update_row.sql_statement_value,
		compiled_variable_name  = update_row.compiled_variable_name,
		sql_expression		= update_row.sql_expression,
		last_update_date	= update_row.last_update_date,
		last_updated_by		= update_row.last_updated_by,
		last_update_login	= update_row.last_update_login
    WHERE	fv.user_variable_name = update_row.user_variable_name;

    IF SQL%NOTFOUND THEN
      raise no_data_found;
    END IF;
  END Update_Row;

  PROCEDURE Load_Row(	user_variable_name	VARCHAR2,
			owner			VARCHAR2,
			last_update_date	VARCHAR2,
			rule_type_code		VARCHAR2,
			sql_statement_value 	NUMBER,
			compiled_variable_name	VARCHAR2,
			sql_expression       	VARCHAR2,
			custom_mode		VARCHAR2)IS
    row_id	VARCHAR2(64);
    f_luby	NUMBER;	-- entity owner in file
    f_ludate	DATE;	-- entity update date in file
    db_luby	NUMBER; -- entity owner in db
    db_ludate	DATE;	-- entity update date in db
  BEGIN
    -- Get last updated information from the loader data file
    f_luby := fnd_load_util.owner_id(owner);
    f_ludate := nvl(to_date(last_update_date, 'YYYY/MM/DD'), sysdate);

    BEGIN
      SELECT	fv.last_updated_by, fv.last_update_date
      INTO	db_luby, db_ludate
      FROM	GCS_FORMULA_VARIABLES fv
      WHERE	fv.user_variable_name = load_row.user_variable_name;

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
        update_row(	user_variable_name	=> user_variable_name,
			rule_type_code		=> rule_type_code,
			sql_statement_value      => sql_statement_value,
			compiled_variable_name	=> compiled_variable_name,
			sql_expression		=> sql_expression,
			last_update_date	=> f_ludate,
			last_updated_by		=> f_luby,
			last_update_login	=> 0);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        insert_row(	row_id			=> row_id,
			user_variable_name	=> user_variable_name,
			rule_type_code		=> rule_type_code,
			sql_statement_value      => sql_statement_value,
			compiled_variable_name	=> compiled_variable_name,
			sql_expression		=> sql_expression,
			last_update_date	=> f_ludate,
			last_updated_by		=> f_luby,
			last_update_login	=> 0,
			creation_date		=> f_ludate,
			created_by		=> f_luby);
    END;
  END Load_Row;

  PROCEDURE Translate_Row(	user_variable_name	VARCHAR2,
  			        rule_type_code          VARCHAR2,
				owner			VARCHAR2,
				last_update_date	VARCHAR2,
				custom_mode		VARCHAR2) IS
    f_luby	NUMBER;	-- entity owner in file
    f_ludate	DATE;	-- entity update date in file
    db_luby	NUMBER; -- entity owner in db
    db_ludate	DATE;	-- entity update date in db
  BEGIN
    -- Get last updated information from the loader data file
    f_luby := fnd_load_util.owner_id(owner);
    f_ludate := nvl(to_date(last_update_date, 'YYYY/MM/DD'), sysdate);

    BEGIN
      SELECT	fv.last_updated_by, fv.last_update_date
      INTO	db_luby, db_ludate
      FROM	GCS_FORMULA_VARIABLES fv
      WHERE	fv.user_variable_name = translate_row.user_variable_name;

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
        UPDATE	gcs_formula_variables fv
        SET	last_update_date	= f_ludate,
		last_updated_by		= f_luby,
		last_update_login	= 0
        WHERE	fv.user_variable_name = translate_row.user_variable_name;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
    END;
  END Translate_Row;

END GCS_FORMULA_VARIABLES_PKG;

/
