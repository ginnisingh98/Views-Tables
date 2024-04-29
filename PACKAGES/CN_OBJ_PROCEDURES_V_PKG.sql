--------------------------------------------------------
--  DDL for Package CN_OBJ_PROCEDURES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_OBJ_PROCEDURES_V_PKG" AUTHID CURRENT_USER AS
-- $Header: cnreprcs.pls 115.1 99/07/16 07:15:06 porting ship $


  --
  -- Procedure Name
  --   insert_row
  -- Purpose
  --   Insert a new record(s) in the tables(s) underlying the view with the values
  --   supplied by the parameters.
  -- History
  --   16-FEB-94		Devesh Khatu		Modified
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
	X_seed_procedure_id		cn_obj_procedures_v.seed_procedure_id%TYPE);



  --
  -- Procedure Name
  --   select_row
  -- Purpose
  --   Select a row from the table, given the primary key
  -- History
  --   11/17/93		Devesh Khatu		Created
  --
  PROCEDURE select_row(
	row IN OUT cn_obj_procedures_v%ROWTYPE);


END cn_obj_procedures_v_pkg;

 

/
