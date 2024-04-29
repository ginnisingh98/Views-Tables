--------------------------------------------------------
--  DDL for Package Body CN_OBJ_TRIGGERS_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_OBJ_TRIGGERS_V_PKG" AS

-- $Header: cnretrgb.pls 115.0 99/07/16 07:15:20 porting ship $

--
-- Public Procedures
--

  PROCEDURE insert_row (
	X_rowid		OUT		ROWID,
	X_trigger_id			cn_obj_triggers_v.trigger_id%TYPE,
	X_name				cn_obj_triggers_v.name%TYPE,
	X_description			cn_obj_triggers_v.description%TYPE,
	X_dependency_map_complete	cn_obj_triggers_v.dependency_map_complete%TYPE,
	X_status			cn_obj_triggers_v.status%TYPE,
	X_repository_id			cn_obj_triggers_v.repository_id%TYPE,
	X_when_clause			cn_obj_triggers_v.when_clause%TYPE,
	X_triggering_event		cn_obj_triggers_v.triggering_event%TYPE,
	X_table_id			cn_obj_triggers_v.table_id%TYPE,
	X_event_id			cn_obj_triggers_v.event_id%TYPE,
	X_for_each_row			cn_obj_triggers_v.for_each_row%TYPE,
	X_trigger_type			cn_obj_triggers_v.trigger_type%TYPE,
	X_seed_trigger_id		cn_obj_triggers_v.seed_trigger_id%TYPE) IS

    X_primary_key		cn_obj_triggers_v.trigger_id%TYPE;
  BEGIN

    X_primary_key := X_trigger_id;
    IF (X_primary_key IS NULL) THEN
      SELECT cn_objects_s.NEXTVAL
        INTO X_primary_key
        FROM dual;
    END IF;

    INSERT INTO cn_obj_triggers_v (
	trigger_id,
	name,
	description,
	dependency_map_complete,
	status,
	repository_id,
	object_type,
	when_clause,
	triggering_event,
	table_id,
	event_id,
	for_each_row,
	trigger_type,
	seed_trigger_id)
      VALUES (
	X_primary_key,            -- AE 03-28-95
	X_name,
	X_description,
	X_dependency_map_complete,
	X_status,
	X_repository_id,
	'TRG',
	X_when_clause,
	X_triggering_event,
	X_table_id,
	X_event_id,
	X_for_each_row,
	X_trigger_type,
	X_seed_trigger_id);

    SELECT ROWID
      INTO X_rowid
      FROM cn_obj_triggers_v
     WHERE trigger_id = X_primary_key;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END insert_row;


  PROCEDURE select_row (
	row IN OUT cn_obj_triggers_v%ROWTYPE) IS

  BEGIN

    IF (row.trigger_id IS NOT NULL) THEN
      SELECT * INTO row
        FROM cn_obj_triggers_v
       WHERE cn_obj_triggers_v.trigger_id = row.trigger_id;
    END IF;

  END select_row;


END cn_obj_triggers_v_pkg;

/
