--------------------------------------------------------
--  DDL for Package Body CN_OBJ_PACKAGES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_OBJ_PACKAGES_V_PKG" AS
-- $Header: cnrepkgb.pls 115.1 99/07/16 07:14:56 porting ship $


  --
  -- Public Functions
  --

  --
  -- Procedure Name
  --   insert_row
  -- Purpose
  --   Insert row into CN_REP_OBJ_PKGS_V.
  -- History
  --   16-FEB-94		Devesh Khatu		Modified
  --
  PROCEDURE insert_row (
	X_rowid		OUT		ROWID,
	X_package_id			cn_obj_packages_v.package_id%TYPE,
	X_name				cn_obj_packages_v.name%TYPE,
	X_description			cn_obj_packages_v.description%TYPE,
	X_dependency_map_complete	cn_obj_packages_v.dependency_map_complete%TYPE,
	X_status			cn_obj_packages_v.status%TYPE,
	X_repository_id			cn_obj_packages_v.repository_id%TYPE,
	X_package_type			cn_obj_packages_v.package_type%TYPE,
	X_package_specification_id	cn_obj_packages_v.package_specification_id%TYPE,
	X_seed_package_id		cn_obj_packages_v.seed_package_id%TYPE) IS

    X_object_type		cn_obj_packages_v.object_type%TYPE;
    X_primary_key		cn_obj_packages_v.package_id%TYPE;

  BEGIN

    X_primary_key := X_package_id;
    IF (X_primary_key IS NULL) THEN
      SELECT cn_objects_s.NEXTVAL
        INTO X_primary_key
        FROM dual;
    END IF;

    IF (X_package_specification_id IS NULL) THEN
      -- package specification
      X_object_type := 'PKS';
    ELSE
      -- package body
      X_object_type := 'PKB';
    END IF;

    INSERT INTO cn_obj_packages_v(
	package_id,
	name,
	description,
	dependency_map_complete,
	status,
	repository_id,
	package_type,
	package_specification_id,
	object_type,
	seed_package_id)
    VALUES(
	X_primary_key,
	X_name,
	X_description,
	X_dependency_map_complete,
	X_status,
	X_repository_id,
        X_package_type,
	X_package_specification_id,
	X_object_type,
	X_seed_package_id);

    SELECT ROWID
      INTO X_rowid
      FROM cn_obj_packages_v
     WHERE package_id = X_primary_key;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END insert_row;



  --
  -- Procedure Name
  --   select_row
  -- Purpose
  --   Select row from CN_REP_OBJ_PKGS_V.
  -- History
  --
  PROCEDURE select_row(
	row IN OUT cn_obj_packages_v%ROWTYPE) IS

  BEGIN

    IF (row.package_id IS NOT NULL) THEN
      SELECT *
	INTO row
        FROM cn_obj_packages_v
       WHERE cn_obj_packages_v.package_id = row.package_id;
    END IF;

  END select_row;


END cn_obj_packages_v_pkg;

/
