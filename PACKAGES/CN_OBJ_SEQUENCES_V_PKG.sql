--------------------------------------------------------
--  DDL for Package CN_OBJ_SEQUENCES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_OBJ_SEQUENCES_V_PKG" AUTHID CURRENT_USER AS
-- $Header: cnreseqs.pls 115.1 99/07/16 07:15:11 porting ship $


--
-- Public Procedures
--

--
-- Procedure Name
--   insert_row
-- Purpose
--   Insert a new record in the cn_obj_sequences_v view.
-- History
--   11-FEB-94		Devesh Khatu		Created
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
	X_seed_sequence_id	cn_obj_sequences_v.seed_sequence_id%TYPE);


--
-- Procedure Name
--   select_row
-- Purpose
--   Selects a record from the cn_obj_sequences_v view.
-- History
--   11-FEB-94		Devesh Khatu		Created
--
PROCEDURE select_row (
	recinfo IN OUT cn_obj_sequences_v%ROWTYPE);


END cn_obj_sequences_v_pkg;

 

/
