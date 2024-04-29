--------------------------------------------------------
--  DDL for Package Body CN_OBJ_PROCEDURES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_OBJ_PROCEDURES_V_PKG" AS
-- $Header: cnreprcb.pls 115.1 99/07/16 07:15:02 porting ship $


  --
  -- Public Functions
  --

  PROCEDURE insert_row (
	X_rowid		OUT		ROWID,
	X_procedure_id			cn_obj_procedures_v.procedure_id%TYPE,
	X_name				cn_obj_procedures_v.name%TYPE,
	X_description			cn_obj_procedures_v.description%TYPE,
	X_dependency_map_complete	cn_obj_procedures_v.dependency_map_complete%TYPE,
	X_status			cn_obj_procedures_v.status%TYPE,
	X_repository_id			cn_obj_procedures_v.repository_id%TYPE,
	X_parameter_list		cn_obj_procedures_v.parameter_list%TYPE,
	X_procedure_type		cn_obj_procedures_v.procedure_type%TYPE,
	X_return_type			cn_obj_procedures_v.return_type%TYPE,
	X_package_id			cn_obj_procedures_v.package_id%TYPE,
	X_public_flag			cn_obj_procedures_v.public_flag%TYPE,
	X_seed_procedure_id		cn_obj_procedures_v.seed_procedure_id%TYPE) IS

    X_primary_key			cn_obj_procedures_v.procedure_id%TYPE;
  BEGIN

    X_primary_key := X_procedure_id;
    IF (X_primary_key IS NULL) THEN
      SELECT cn_objects_s.NEXTVAL
        INTO X_primary_key
        FROM dual;
    END IF;

    INSERT INTO cn_obj_procedures_v(
	procedure_id,
	name,
	description,
	dependency_map_complete,
	status,
	repository_id,
	object_type,
	parameter_list,
	procedure_type,
	return_type,
	package_id,
	public_flag,
	seed_procedure_id)
    VALUES(
	X_primary_key,
	X_name,
	X_description,
	X_dependency_map_complete,
	X_status,
	X_repository_id,
	'PRC',
	X_parameter_list,
	X_procedure_type,
	X_return_type,
	X_package_id,
	X_public_flag,
	X_seed_procedure_id);

    SELECT ROWID
      INTO X_rowid
      FROM cn_obj_procedures_v
     WHERE procedure_id = X_primary_key;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END insert_row;


  PROCEDURE select_row (
	row IN OUT cn_obj_procedures_v%ROWTYPE) IS

  BEGIN
    IF (row.procedure_id IS NOT NULL) THEN

      SELECT * INTO row
        FROM cn_obj_procedures_v
       WHERE cn_obj_procedures_v.procedure_id = row.procedure_id;

    END IF;
  END select_row;


END cn_obj_procedures_v_pkg;

/
