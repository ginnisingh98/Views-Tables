--------------------------------------------------------
--  DDL for Package Body CN_OBJ_INDEXES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_OBJ_INDEXES_V_PKG" AS
-- $Header: cnreindb.pls 115.1 99/07/16 07:14:34 porting ship $


--
-- Public Procedures
--

  PROCEDURE insert_row (
	X_rowid		OUT	ROWID,
	X_index_id		cn_obj_indexes_v.index_id%TYPE,
	X_name			cn_obj_indexes_v.name%TYPE,
	X_description		cn_obj_indexes_v.description%TYPE,
	X_dependency_map_complete	cn_obj_indexes_v.dependency_map_complete%TYPE,
	X_status		cn_obj_indexes_v.status%TYPE,
	X_repository_id		cn_obj_indexes_v.repository_id%TYPE,
	X_table_id		cn_obj_indexes_v.table_id%TYPE,
	X_unique_flag		cn_obj_indexes_v.unique_flag%TYPE,
	X_seed_index_id		cn_obj_indexes_v.seed_index_id%TYPE) IS

    X_primary_key		cn_obj_indexes_v.index_id%TYPE;
  BEGIN

    X_primary_key := X_index_id;
    IF (X_primary_key IS NULL) THEN
      SELECT cn_objects_s.NEXTVAL
        INTO X_primary_key
        FROM dual;
    END IF;

    INSERT INTO cn_obj_indexes_v (
	index_id,
	name,
	description,
	dependency_map_complete,
	status,
	repository_id,
	table_id,
	unique_flag,
	object_type,
	seed_index_id)
      VALUES (
	X_primary_key,
	X_name,
	X_description,
	X_dependency_map_complete,
	X_status,
	X_repository_id,
	X_table_id,
	X_unique_flag,
	'IND',
	X_seed_index_id);

    SELECT ROWID
      INTO X_rowid
      FROM cn_obj_indexes_v
     WHERE index_id = X_primary_key;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END insert_row;


  PROCEDURE select_row (
	recinfo IN OUT cn_obj_indexes_v%ROWTYPE) IS
  BEGIN
    -- select row based on index_id (primary key)
    IF (recinfo.index_id IS NOT NULL) THEN

      SELECT * INTO recinfo
        FROM cn_obj_indexes_v coiv
        WHERE coiv.index_id = recinfo.index_id;

    END IF;
  END select_row;


END cn_obj_indexes_v_pkg;

/
