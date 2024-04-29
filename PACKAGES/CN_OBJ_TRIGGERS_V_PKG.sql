--------------------------------------------------------
--  DDL for Package CN_OBJ_TRIGGERS_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_OBJ_TRIGGERS_V_PKG" AUTHID CURRENT_USER AS

-- $Header: cnretrgs.pls 115.0 99/07/16 07:15:23 porting ship $

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
--   12/15/93		Devesh Khatu		Created
--   16-FEB-94          Devesh Khatu		Modified
--
PROCEDURE insert_row (
	X_rowid		OUT	ROWID,
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
	X_seed_trigger_id		cn_obj_triggers_v.seed_trigger_id%TYPE);

--
-- Procedure Name
--   select_row
-- Purpose
--   Select a row from the table, given the primary key
-- History
--   12/15/93		Devesh Khatu		Created
--
PROCEDURE select_row (row IN OUT cn_obj_triggers_v%ROWTYPE);


END cn_obj_triggers_v_pkg;

 

/
