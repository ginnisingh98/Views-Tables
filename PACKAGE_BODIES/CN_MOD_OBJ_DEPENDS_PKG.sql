--------------------------------------------------------
--  DDL for Package Body CN_MOD_OBJ_DEPENDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_MOD_OBJ_DEPENDS_PKG" AS
-- $Header: cnremodb.pls 115.1 99/07/16 07:14:39 porting ship $


--
-- Public Procedures
--

  PROCEDURE insert_row (
	X_rowid		OUT	ROWID,
	X_mod_obj_depends_id	cn_mod_obj_depends.mod_obj_depends_id%TYPE,
	X_object_id		cn_mod_obj_depends.object_id%TYPE,
	X_parent_object_id	cn_mod_obj_depends.parent_object_id%TYPE,
	X_action		cn_mod_obj_depends.action%TYPE,
	X_module_id		cn_mod_obj_depends.module_id%TYPE) IS

    X_primary_key		cn_mod_obj_depends.mod_obj_depends_id%TYPE;
  BEGIN

    X_primary_key := X_mod_obj_depends_id;
    IF (X_primary_key IS NULL) THEN
      SELECT cn_objects_s.NEXTVAL
        INTO X_primary_key
        FROM dual;
    END IF;

    INSERT INTO cn_mod_obj_depends (
	mod_obj_depends_id,
	object_id,
	parent_object_id,
	action,
	module_id)
      VALUES (
	X_primary_key,
	X_object_id,
	X_parent_object_id,
	X_action,
	X_module_id);

    SELECT ROWID
      INTO X_rowid
      FROM cn_mod_obj_depends
     WHERE mod_obj_depends_id = X_primary_key;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END insert_row;


  PROCEDURE select_row (
	recinfo IN OUT cn_mod_obj_depends%ROWTYPE) IS
  BEGIN
    -- select row based on mod_obj_depends_id (primary key)
    IF (recinfo.mod_obj_depends_id IS NOT NULL) THEN

      SELECT * INTO recinfo
        FROM cn_mod_obj_depends cmom
        WHERE cmom.mod_obj_depends_id = recinfo.mod_obj_depends_id;

    END IF;
  END select_row;


END cn_mod_obj_depends_pkg;

/
