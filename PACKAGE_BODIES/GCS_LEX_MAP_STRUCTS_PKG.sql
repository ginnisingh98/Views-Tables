--------------------------------------------------------
--  DDL for Package Body GCS_LEX_MAP_STRUCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_LEX_MAP_STRUCTS_PKG" AS
/* $Header: gcslxmsb.pls 115.2 2003/08/13 17:54:49 mikeward noship $ */
--
-- Package
--   gcs_lex_map_structs_pkg
-- Purpose
--   Package procedures for Lexical Mapping Structures
-- History
--   23-JUN-03	M Ward		Created
--   28-JUL-03	M Ward		Added translate_row
--

  PROCEDURE Insert_Row(	row_id	IN OUT NOCOPY	VARCHAR2,
			structure_name		VARCHAR2,
			description		VARCHAR2,
			table_use_type_code	VARCHAR2,
			last_update_date	DATE,
			last_updated_by		NUMBER,
			last_update_login	NUMBER,
			creation_date		DATE,
			created_by		NUMBER) IS
    CURSOR	struct_row IS
    SELECT	rowid
    FROM	gcs_lex_map_structs ms
    WHERE	ms.structure_name = insert_row.structure_name;
  BEGIN
    IF structure_name IS NULL THEN
      raise no_data_found;
    END IF;

    INSERT INTO gcs_lex_map_structs(	structure_id,
					structure_name,
					description,
					table_use_type_code,
					last_update_date,
					last_updated_by,
					last_update_login,
					creation_date,
					created_by)
    SELECT	gcs_lex_map_structs_s.nextval,
		structure_name,
		description,
		table_use_type_code,
		last_update_date,
		last_updated_by,
		last_update_login,
		creation_date,
		created_by
    FROM	dual
    WHERE	NOT EXISTS
		(SELECT	1
		 FROM	gcs_lex_map_structs ms
		 WHERE	ms.structure_name = insert_row.structure_name);

    OPEN struct_row;
    FETCH struct_row INTO row_id;
    IF struct_row%NOTFOUND THEN
      CLOSE struct_row;
      raise no_data_found;
    END IF;
    CLOSE struct_row;
  END Insert_Row;

  PROCEDURE Update_Row(	structure_name		VARCHAR2,
			description		VARCHAR2,
			table_use_type_code	VARCHAR2,
			last_update_date	DATE,
			last_updated_by		NUMBER,
			last_update_login	NUMBER) IS
  BEGIN
    UPDATE	gcs_lex_map_structs ms
    SET		description		= update_row.description,
		table_use_type_code	= update_row.table_use_type_code,
		last_update_date	= update_row.last_update_date,
		last_updated_by		= update_row.last_updated_by,
		last_update_login	= update_row.last_update_login
    WHERE	ms.structure_name = update_row.structure_name;

    IF SQL%NOTFOUND THEN
      raise no_data_found;
    END IF;
  END Update_Row;

  PROCEDURE Load_Row(	structure_name		VARCHAR2,
			owner			VARCHAR2,
			last_update_date	VARCHAR2,
			description		VARCHAR2,
			table_use_type_code	VARCHAR2,
			custom_mode		VARCHAR2) IS
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
      SELECT	ms.last_updated_by, ms.last_update_date
      INTO	db_luby, db_ludate
      FROM	GCS_LEX_MAP_STRUCTS ms
      WHERE	ms.structure_name = load_row.structure_name;

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
        update_row(	structure_name		=> structure_name,
			description		=> description,
			table_use_type_code	=> table_use_type_code,
			last_update_date	=> f_ludate,
			last_updated_by		=> f_luby,
			last_update_login	=> 0);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        insert_row(	row_id			=> row_id,
			structure_name		=> structure_name,
			description		=> description,
			table_use_type_code	=> table_use_type_code,
			last_update_date	=> f_ludate,
			last_updated_by		=> f_luby,
			last_update_login	=> 0,
			creation_date		=> f_ludate,
			created_by		=> f_luby);
    END;
  END Load_Row;

  PROCEDURE Translate_Row(	structure_name		VARCHAR2,
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
      SELECT	ms.last_updated_by, ms.last_update_date
      INTO	db_luby, db_ludate
      FROM	GCS_LEX_MAP_STRUCTS ms
      WHERE	ms.structure_name = translate_row.structure_name;

      -- Test for customization information
      IF fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate,
                                   custom_mode) THEN
        UPDATE	gcs_lex_map_structs ms
        SET	last_update_date	= f_ludate,
		last_updated_by		= f_luby,
		last_update_login	= 0
        WHERE	ms.structure_name = translate_row.structure_name;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
    END;
  END Translate_Row;

END GCS_LEX_MAP_STRUCTS_PKG;

/
