--------------------------------------------------------
--  DDL for Package CN_MOD_OBJ_DEPENDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_MOD_OBJ_DEPENDS_PKG" AUTHID CURRENT_USER AS
-- $Header: cnremods.pls 115.1 99/07/16 07:14:42 porting ship $



--
-- Procedure Name
--   insert_row
-- Purpose
--   Insert a new record in the cn_mod_obj_depends table.
-- History
--   11-JUN-94		Devesh Khatu		Created
--
PROCEDURE insert_row (
	X_rowid		OUT	ROWID,
	X_mod_obj_depends_id	cn_mod_obj_depends.mod_obj_depends_id%TYPE,
	X_object_id		cn_mod_obj_depends.object_id%TYPE,
	X_parent_object_id	cn_mod_obj_depends.parent_object_id%TYPE,
	X_action		cn_mod_obj_depends.action%TYPE,
	X_module_id		cn_mod_obj_depends.module_id%TYPE);


--
-- Procedure Name
--   select_row
-- Purpose
--   Select a row from the table, given the primary key
-- History
--   11-JUN-94		Devesh Khatu		Created
--
PROCEDURE select_row (
	recinfo IN OUT cn_mod_obj_depends%ROWTYPE);


END cn_mod_obj_depends_pkg;

 

/
