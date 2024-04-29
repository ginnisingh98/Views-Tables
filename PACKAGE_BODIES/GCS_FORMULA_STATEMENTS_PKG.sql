--------------------------------------------------------
--  DDL for Package Body GCS_FORMULA_STATEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_FORMULA_STATEMENTS_PKG" AS
/* $Header: gcserfsb.pls 120.1 2005/10/30 05:18:15 appldev noship $ */
--
-- Package
--   gcs_formula_statements_pkg
-- Purpose
--   Package procedures for GCS formula statements table
-- History
--   27-APR-04	J Huang  	Created
--

  PROCEDURE Insert_Row(	row_id	IN OUT NOCOPY	VARCHAR2,
			statement_num		VARCHAR2,
			rule_type_code		VARCHAR2,
			statement_text       	VARCHAR2,
			compiled_variables	VARCHAR2,
			last_update_date	DATE,
			last_updated_by		NUMBER,
			last_update_login	NUMBER,
			creation_date		DATE,
			created_by		NUMBER) IS
    CURSOR	var_row IS
    SELECT	rowid
    FROM	gcs_formula_statements fs
    WHERE	fs.statement_num = insert_row.statement_num
    AND         fs.rule_type_code = insert_row.rule_type_code;

  BEGIN
    IF statement_num IS NULL THEN
      raise no_data_found;
    ELSIF rule_type_code IS NULL THEN
      raise no_data_found;
    END IF;

    INSERT INTO gcs_formula_statements(	statement_num,
					rule_type_code,
					statement_text,
					compiled_variables,
					last_update_date,
					last_updated_by,
					last_update_login,
					creation_date,
					created_by)
    SELECT	statement_num,
		rule_type_code,
		statement_text,
		compiled_variables,
		last_update_date,
		last_updated_by,
		last_update_login,
		creation_date,
		created_by
    FROM	dual
    WHERE	NOT EXISTS
		(SELECT	1
		 FROM	gcs_formula_statements fs
		 WHERE	fs.statement_num = insert_row.statement_num
                 AND    fs.rule_type_code = insert_row.rule_type_code);

    OPEN var_row;
    FETCH var_row INTO row_id;
    IF var_row%NOTFOUND THEN
      CLOSE var_row;
      raise no_data_found;
    END IF;
    CLOSE var_row;
  END Insert_Row;

  PROCEDURE Update_Row(	statement_num		VARCHAR2,
			rule_type_code		VARCHAR2,
			statement_text       	VARCHAR2,
			compiled_variables	VARCHAR2,
			last_update_date	DATE,
			last_updated_by		NUMBER,
			last_update_login	NUMBER) IS
  BEGIN
    UPDATE	gcs_formula_statements fs
    SET		rule_type_code		= update_row.rule_type_code,
		statement_text		= update_row.statement_text,
		compiled_variables 	= update_row.compiled_variables,
		last_update_date	= update_row.last_update_date,
		last_updated_by		= update_row.last_updated_by,
		last_update_login	= update_row.last_update_login
    WHERE	fs.statement_num  = update_row.statement_num
    AND         fs.rule_type_code = update_row.rule_type_code;

    IF SQL%NOTFOUND THEN
      raise no_data_found;
    END IF;
  END Update_Row;

  PROCEDURE Load_Row(	statement_num		VARCHAR2,
			rule_type_code		VARCHAR2,
			owner			VARCHAR2,
			last_update_date	VARCHAR2,
			statement_text 		VARCHAR2,
			compiled_variables	VARCHAR2,
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
      SELECT	fs.last_updated_by, fs.last_update_date
      INTO	db_luby, db_ludate
      FROM	GCS_FORMULA_STATEMENTS fs
      WHERE	fs.statement_num = load_row.statement_num
      AND       fs.rule_type_code = load_row.rule_type_code;

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
        update_row(	statement_num		=> statement_num,
			rule_type_code		=> rule_type_code,
			statement_text     	=> statement_text,
			compiled_variables	=> compiled_variables,
			last_update_date	=> f_ludate,
			last_updated_by		=> f_luby,
			last_update_login	=> 0);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        insert_row(	row_id			=> row_id,
			statement_num		=> statement_num,
			rule_type_code		=> rule_type_code,
			statement_text     	=> statement_text,
			compiled_variables	=> compiled_variables,
			last_update_date	=> f_ludate,
			last_updated_by		=> f_luby,
			last_update_login	=> 0,
			creation_date		=> f_ludate,
			created_by		=> f_luby);
    END;
  END Load_Row;

  PROCEDURE Translate_Row(	statement_num		VARCHAR2,
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
      SELECT	fs.last_updated_by, fs.last_update_date
      INTO	db_luby, db_ludate
      FROM	GCS_FORMULA_STATEMENTS fs
      WHERE	fs.statement_num = translate_row.statement_num
      AND       fs.rule_type_code = translate_row.rule_type_code;

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
        UPDATE	gcs_formula_statements fs
        SET	last_update_date	= f_ludate,
		last_updated_by		= f_luby,
		last_update_login	= 0
        WHERE	fs.statement_num = translate_row.statement_num
        AND       fs.rule_type_code = translate_row.rule_type_code;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
    END;
  END Translate_Row;

END GCS_FORMULA_STATEMENTS_PKG;

/
