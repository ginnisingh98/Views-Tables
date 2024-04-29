--------------------------------------------------------
--  DDL for Package Body CN_OBJ_TABLES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_OBJ_TABLES_V_PKG" AS
-- $Header: cnretblb.pls 115.1 99/07/16 07:15:14 porting ship $


--
-- Public Procedures
--

  --
  -- Procedure Name
  --   insert_row
  -- Purpose
  --   Insert a new record in the table underlying the view with the values
  --   supplied by the parameters.
  -- History
  --   11/17/93		Devesh Khatu		Created
  --   16-FEB-94	Devesh Khatu		Modified
  --
  PROCEDURE insert_row (
	X_rowid			OUT	rowid,
        X_row_id                        rowid		default NULL,
	X_table_id 		IN OUT	number,
	X_name 				varchar2,
	X_description 			varchar2	default NULL,
	X_status 			varchar2,
	X_dependency_map_complete 	varchar2,
	X_repository_id			number,
	X_alias				varchar2	default NULL,
	X_table_level			varchar2	default NULL,
	X_table_type			varchar2	default NULL,
	X_seed_table_id			varchar2	default NULL) IS


    CURSOR C IS SELECT rowid
                  FROM cn_obj_tables_v
	         WHERE table_id = X_table_id;

    CURSOR C2 IS SELECT cn_objects_s.nextval
                   FROM sys.dual;

  BEGIN

    IF (X_table_id is NULL) THEN
      OPEN C2;
      FETCH C2 INTO X_table_id;
      CLOSE C2;
    END IF;

    INSERT INTO cn_obj_tables_v(
	row_id,
	table_id,
	name,
	description,
	repository_id,
	object_type,
	status,
	dependency_map_complete,
	alias,
	table_level,
	table_type,
	seed_table_id)
    VALUES (
	X_row_id,
	X_table_id,
	X_name,
	X_description,
	X_repository_id,
	'TBL',
	X_status,
	X_dependency_map_complete,
	X_alias,
	X_table_level,
	X_table_type,
	X_seed_table_id);

    OPEN C;
    FETCH C INTO X_rowid;

    if (C%NOTFOUND) THEN
      CLOSE C;
      RAISE NO_DATA_FOUND;
    end if;

    CLOSE C;

  END insert_row;



  --
  -- Procedure Name
  --   update_row
  -- History
  --   11/17/93		Devesh Khatu		Created
  --
  PROCEDURE update_row (
	X_rowid				varchar2,
	X_table_id 			number,
	X_name 				varchar2,
	X_description			varchar2	default NULL,
	X_repository_id			number,
	X_alias				varchar2	default NULL,
	X_table_level			varchar2	default NULL,
	X_table_type			varchar2	default NULL) IS

  BEGIN
    UPDATE cn_obj_tables_v
       SET
	 name			= X_name,
	 description		= X_description,
	 repository_id		= X_repository_id,
	 object_type		= 'TBL',
    	 alias			= X_alias,
	 table_level		= X_table_level,
	 table_type		= X_table_type
     WHERE table_id = X_table_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;



  --
  -- Procedure Name
  --   lock_row
  -- History
  --   11/17/93		Devesh Khatu		Created
  --
  PROCEDURE lock_row (tab_id IN number) IS
	Tony Number;
  BEGIN
    -- Tony, I have commented this out, so that the procedure compiles
    -- without errors. Devesh
    Tony := NULL;
/*
	select rep_tables.table_id into Tony
	from rep_tables, rep_objects
	where rep_tables.table_id = tab_id AND rep_objects.object_id = tab_id
	for update of rep_tables.table_type, rep_objects.name,
			rep_objects.description, rep_tables.alias;
*/
  END lock_row;



  --
  -- Procedure Name
  --   select_row
  -- Purpose
  --   Select a row from the table, given the primary key
  -- History
  --   11/17/93		Devesh Khatu		Created
  --
  PROCEDURE select_row
	(row IN OUT cn_obj_tables_v%ROWTYPE) IS

  BEGIN
    IF (row.table_id IS NOT NULL) THEN

      SELECT * INTO row
        FROM cn_obj_tables_v
       WHERE cn_obj_tables_v.table_id = row.table_id;

    END IF;

  END select_row;


END cn_obj_tables_v_pkg;

/
