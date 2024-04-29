--------------------------------------------------------
--  DDL for Package CN_OBJ_INDEXES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_OBJ_INDEXES_V_PKG" AUTHID CURRENT_USER AS
-- $Header: cnreinds.pls 115.1 99/07/16 07:14:36 porting ship $


--
-- Public Procedures
--

--
-- Procedure Name
--   insert_row
-- Purpose
--   Insert a new record in the cn_obj_indexes_v view.
-- History
--   11-FEB-94		Devesh Khatu		Created
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
	X_seed_index_id		cn_obj_indexes_v.seed_index_id%TYPE);


--
-- Procedure Name
--   select_row
-- Purpose
--   Selects a record from the cn_obj_indexes_v view.
-- History
--   11-FEB-94		Devesh Khatu		Created
--
PROCEDURE select_row (
	recinfo IN OUT cn_obj_indexes_v%ROWTYPE);


END cn_obj_indexes_v_pkg;

 

/
