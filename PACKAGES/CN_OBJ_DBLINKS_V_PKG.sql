--------------------------------------------------------
--  DDL for Package CN_OBJ_DBLINKS_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_OBJ_DBLINKS_V_PKG" AUTHID CURRENT_USER AS
-- $Header: cnredbls.pls 115.1 99/07/16 07:13:50 porting ship $


--
-- Public Procedures
--

--
-- Procedure Name
--   insert_row
-- Purpose
--   Insert a new record in the cn_obj_dblinks_v view.
-- History
--   11-JUN-94		Devesh Khatu		Created
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
	X_seed_dblink_id	cn_obj_dblinks_v.seed_dblink_id%TYPE);


--
-- Procedure Name
--   select_row
-- Purpose
--   Selects a record from the cn_obj_dblinks_v view.
-- History
--   11-JUN-94		Devesh Khatu		Created
--
PROCEDURE select_row (
	recinfo IN OUT cn_obj_dblinks_v%ROWTYPE);


END cn_obj_dblinks_v_pkg;

 

/
