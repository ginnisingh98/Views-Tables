--------------------------------------------------------
--  DDL for Package Body CN_OBJ_DBLINKS_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_OBJ_DBLINKS_V_PKG" AS
-- $Header: cnredblb.pls 115.1 99/07/16 07:13:47 porting ship $


--
-- Public Procedures
--

  PROCEDURE insert_row (
	X_rowid		OUT	ROWID,
	X_dblink_id		cn_obj_dblinks_v.dblink_id%TYPE,
	X_name			cn_obj_dblinks_v.name%TYPE,
	X_description		cn_obj_dblinks_v.description%TYPE,
	X_dependency_map_complete	cn_obj_dblinks_v.dependency_map_complete%TYPE,
	X_status		cn_obj_dblinks_v.status%TYPE,
	X_repository_id		cn_obj_dblinks_v.repository_id%TYPE,
	X_connect_to_username	cn_obj_dblinks_v.connect_to_username%TYPE,
	X_connect_to_password	cn_obj_dblinks_v.connect_to_password%TYPE,
	X_connect_to_host	cn_obj_dblinks_v.connect_to_host%TYPE,
	X_seed_dblink_id	cn_obj_dblinks_v.seed_dblink_id%TYPE) IS

    X_primary_key		cn_obj_dblinks_v.dblink_id%TYPE;
  BEGIN

    X_primary_key := X_dblink_id;
    IF (X_primary_key IS NULL) THEN
      SELECT cn_objects_s.NEXTVAL
        INTO X_primary_key
        FROM dual;
    END IF;

    INSERT INTO cn_obj_dblinks_v (
	dblink_id,
	name,
	description,
	dependency_map_complete,
	status,
	repository_id,
	connect_to_username,
	connect_to_password,
	connect_to_host,
	object_type,
	seed_dblink_id)
      VALUES (
	X_primary_key,
	X_name,
	X_description,
	X_dependency_map_complete,
	X_status,
	X_repository_id,
	X_connect_to_username,
	X_connect_to_password,
	X_connect_to_host,
	'DBL',
	X_seed_dblink_id);

    SELECT ROWID
      INTO X_rowid
      FROM cn_obj_dblinks_v
     WHERE dblink_id = X_primary_key;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END insert_row;


  PROCEDURE select_row (
	recinfo IN OUT cn_obj_dblinks_v%ROWTYPE) IS
  BEGIN
    -- select row based on dblink_id (primary key)
    IF (recinfo.dblink_id IS NOT NULL) THEN

      SELECT * INTO recinfo
        FROM cn_obj_dblinks_v crosv
        WHERE crosv.dblink_id = recinfo.dblink_id;

    END IF;
  END select_row;


END cn_obj_dblinks_v_pkg;

/
