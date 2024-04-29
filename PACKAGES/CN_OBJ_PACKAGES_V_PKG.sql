--------------------------------------------------------
--  DDL for Package CN_OBJ_PACKAGES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_OBJ_PACKAGES_V_PKG" AUTHID CURRENT_USER AS
-- $Header: cnrepkgs.pls 115.1 99/07/16 07:14:59 porting ship $



  --
  -- Procedure Name
  --   insert_row
  -- Purpose
  --   Insert a new record in the table underlying the view with the values
  --   supplied by the parameters.
  -- History
  --   11/17/93		Devesh Khatu		Created
  --   16-FEB-94	Devesh Khatu		Modified
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
	X_seed_package_id		cn_obj_packages_v.seed_package_id%TYPE);

  --
  -- Procedure Name
  --   select_row
  -- Purpose
  --   Select a row from the table, given the primary key
  -- History
  --   11/17/93		Devesh Khatu		Created
  --
  PROCEDURE select_row (
	row IN OUT cn_obj_packages_v%ROWTYPE);


END cn_obj_packages_v_pkg;

 

/
