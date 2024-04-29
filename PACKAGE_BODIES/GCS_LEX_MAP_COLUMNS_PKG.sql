--------------------------------------------------------
--  DDL for Package Body GCS_LEX_MAP_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_LEX_MAP_COLUMNS_PKG" AS
/* $Header: gcslxmcb.pls 115.2 2003/08/13 17:55:00 mikeward noship $ */
--
-- Package
--   gcs_lex_map_structs_pkg
-- Purpose
--   Package procedures for Lexical Mapping Structures
-- History
--   23-JUN-03	M Ward		Created
--

  PROCEDURE Insert_Row(	row_id	IN OUT NOCOPY	VARCHAR2,
			structure_id		NUMBER,
			column_name		VARCHAR2,
			column_type_code	VARCHAR2,
			write_flag		VARCHAR2,
			error_code_column_flag	VARCHAR2,
			last_update_date	DATE,
			last_updated_by		NUMBER,
			last_update_login	NUMBER,
			creation_date		DATE,
			created_by		NUMBER) IS
    CURSOR	column_row IS
    SELECT	rowid
    FROM	gcs_lex_map_columns mc
    WHERE	mc.structure_id = insert_row.structure_id
    AND		mc.column_name = insert_row.column_name;
  BEGIN
    IF structure_id IS NULL OR column_name IS NULL THEN
      raise no_data_found;
    END IF;

    INSERT INTO gcs_lex_map_columns(	column_id,
					structure_id,
					column_name,
					column_type_code,
					write_flag,
					error_code_column_flag,
					last_update_date,
					last_updated_by,
					last_update_login,
					creation_date,
					created_by)
    SELECT	gcs_lex_map_columns_s.nextval,
		structure_id,
		column_name,
		column_type_code,
		write_flag,
		error_code_column_flag,
		last_update_date,
		last_updated_by,
		last_update_login,
		creation_date,
		created_by
    FROM	dual
    WHERE	NOT EXISTS
		(SELECT	1
		 FROM	gcs_lex_map_columns mc
		 WHERE	mc.structure_id = insert_row.structure_id
		 AND	mc.column_name = insert_row.column_name);

    OPEN column_row;
    FETCH column_row INTO row_id;
    IF column_row%NOTFOUND THEN
      CLOSE column_row;
      raise no_data_found;
    END IF;
    CLOSE column_row;
  END Insert_Row;

  PROCEDURE Update_Row(	structure_id		NUMBER,
			column_name		VARCHAR2,
			column_type_code	VARCHAR2,
			write_flag		VARCHAR2,
			error_code_column_flag	VARCHAR2,
			last_update_date	DATE,
			last_updated_by		NUMBER,
			last_update_login	NUMBER) IS
  BEGIN
    UPDATE	gcs_lex_map_columns mc
    SET		column_type_code	= update_row.column_type_code,
		write_flag		= update_row.write_flag,
		error_code_column_flag	= update_row.error_code_column_flag,
		last_update_date	= update_row.last_update_date,
		last_updated_by		= update_row.last_updated_by,
		last_update_login	= update_row.last_update_login
    WHERE	mc.structure_id = update_row.structure_id
    AND		mc.column_name = update_row.column_name;

    IF SQL%NOTFOUND THEN
      raise no_data_found;
    END IF;
  END Update_Row;

  PROCEDURE Load_Row(	structure_name		VARCHAR2,
			column_name		VARCHAR2,
			owner			VARCHAR2,
			last_update_date	VARCHAR2,
			column_type_code	VARCHAR2,
			write_flag		VARCHAR2,
			error_code_column_flag	VARCHAR2,
			custom_mode		VARCHAR2) IS
    row_id	VARCHAR2(64);
    struct_id	NUMBER;
    f_luby	NUMBER;	-- entity owner in file
    f_ludate	DATE;	-- entity update date in file
    db_luby	NUMBER; -- entity owner in db
    db_ludate	DATE;	-- entity update date in db
  BEGIN
    -- Get the structure ID given the structure name
    SELECT	structure_id
    INTO	struct_id
    FROM	gcs_lex_map_structs ms
    WHERE	ms.structure_name = load_row.structure_name;

    -- Get last updated information from the loader data file
    f_luby := fnd_load_util.owner_id(owner);
    f_ludate := nvl(to_date(last_update_date, 'YYYY/MM/DD'), sysdate);

    BEGIN
      SELECT	mc.last_updated_by, mc.last_update_date
      INTO	db_luby, db_ludate
      FROM	GCS_LEX_MAP_COLUMNS mc
      WHERE	mc.structure_id = struct_id
      AND	mc.column_name = load_row.column_name;

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
        update_row(	structure_id		=> struct_id,
			column_name		=> column_name,
			column_type_code	=> column_type_code,
			write_flag		=> write_flag,
			error_code_column_flag	=> error_code_column_flag,
			last_update_date	=> f_ludate,
			last_updated_by		=> f_luby,
			last_update_login	=> 0);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        insert_row(	row_id			=> row_id,
			structure_id		=> struct_id,
			column_name		=> column_name,
			column_type_code	=> column_type_code,
			write_flag		=> write_flag,
			error_code_column_flag	=> error_code_column_flag,
			last_update_date	=> f_ludate,
			last_updated_by		=> f_luby,
			last_update_login	=> 0,
			creation_date		=> f_ludate,
			created_by		=> f_luby);
    END;
  END Load_Row;

  PROCEDURE Translate_Row(	structure_name		VARCHAR2,
				column_name		VARCHAR2,
				owner			VARCHAR2,
				last_update_date	VARCHAR2,
				custom_mode		VARCHAR2) IS
    struct_id	NUMBER;
    f_luby	NUMBER;	-- entity owner in file
    f_ludate	DATE;	-- entity update date in file
    db_luby	NUMBER; -- entity owner in db
    db_ludate	DATE;	-- entity update date in db
  BEGIN
    -- Get the structure ID given the structure name
    SELECT	structure_id
    INTO	struct_id
    FROM	gcs_lex_map_structs ms
    WHERE	ms.structure_name = translate_row.structure_name;

    -- Get last updated information from the loader data file
    f_luby := fnd_load_util.owner_id(owner);
    f_ludate := nvl(to_date(last_update_date, 'YYYY/MM/DD'), sysdate);

    BEGIN
      SELECT	mc.last_updated_by, mc.last_update_date
      INTO	db_luby, db_ludate
      FROM	GCS_LEX_MAP_COLUMNS mc
      WHERE	mc.structure_id = struct_id
      AND	mc.column_name = translate_row.column_name;

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
        UPDATE	gcs_lex_map_columns mc
        SET	last_update_date	= f_ludate,
		last_updated_by		= f_luby,
		last_update_login	= 0
        WHERE	mc.structure_id = struct_id
        AND	mc.column_name = translate_row.column_name;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
    END;
  END Translate_Row;

END GCS_LEX_MAP_COLUMNS_PKG;

/
