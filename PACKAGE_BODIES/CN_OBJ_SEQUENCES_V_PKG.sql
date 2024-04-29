--------------------------------------------------------
--  DDL for Package Body CN_OBJ_SEQUENCES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_OBJ_SEQUENCES_V_PKG" AS
-- $Header: cnreseqb.pls 115.1 99/07/16 07:15:08 porting ship $


--
-- Public Procedures
--

  PROCEDURE insert_row (
	X_rowid		OUT	ROWID,
	X_sequence_id		cn_obj_sequences_v.sequence_id%TYPE,
	X_name			cn_obj_sequences_v.name%TYPE,
	X_description		cn_obj_sequences_v.description%TYPE,
	X_dependency_map_complete	cn_obj_sequences_v.dependency_map_complete%TYPE,
	X_status		cn_obj_sequences_v.status%TYPE,
	X_repository_id		cn_obj_sequences_v.repository_id%TYPE,
	X_start_value		cn_obj_sequences_v.start_value%TYPE,
	X_increment_value	cn_obj_sequences_v.increment_value%TYPE,
	X_seed_sequence_id	cn_obj_sequences_v.seed_sequence_id%TYPE) IS

    X_primary_key		cn_obj_sequences_v.sequence_id%TYPE;
  BEGIN

    X_primary_key := X_sequence_id;
    IF (X_primary_key IS NULL) THEN
      SELECT cn_objects_s.NEXTVAL
        INTO X_primary_key
        FROM dual;
    END IF;

    INSERT INTO cn_obj_sequences_v (
	sequence_id,
	name,
	description,
	dependency_map_complete,
	status,
	repository_id,
	start_value,
	increment_value,
	object_type,
	seed_sequence_id)
      VALUES (
	X_primary_key,
	X_name,
	X_description,
	X_dependency_map_complete,
	X_status,
	X_repository_id,
	X_start_value,
	X_increment_value,
	'SEQ',
	X_seed_sequence_id);

    SELECT ROWID
      INTO X_rowid
      FROM cn_obj_sequences_v
     WHERE sequence_id = X_primary_key;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END insert_row;


  PROCEDURE select_row (
	recinfo IN OUT cn_obj_sequences_v%ROWTYPE) IS
  BEGIN
    -- select row based on sequence_id (primary key)
    IF (recinfo.sequence_id IS NOT NULL) THEN

      SELECT * INTO recinfo
        FROM cn_obj_sequences_v crosv
        WHERE crosv.sequence_id = recinfo.sequence_id;

    END IF;
  END select_row;


END cn_obj_sequences_v_pkg;

/
