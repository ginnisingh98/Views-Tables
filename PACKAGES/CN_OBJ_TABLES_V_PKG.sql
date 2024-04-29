--------------------------------------------------------
--  DDL for Package CN_OBJ_TABLES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_OBJ_TABLES_V_PKG" AUTHID CURRENT_USER AS
-- $Header: cnretbls.pls 115.1 99/07/16 07:15:17 porting ship $


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
  --   11/17/93		Devesh Khatu		Created
  --   16-FEB-94	Devesh Khatu		Modified
  --
  PROCEDURE insert_row (
	X_rowid			OUT	rowid,
        X_row_id                        rowid		default NULL,
	X_table_id 		IN OUT	number,
	X_name 				varchar2,
	X_description 			varchar2	default NULL,
	X_status 			varchar2,
	X_dependency_map_complete 	varchar2,
	X_repository_id			number,
	X_alias				varchar2	default NULL,
	X_table_level			varchar2	default NULL,
	X_table_type			varchar2	default NULL,
	X_seed_table_id			varchar2	default NULL);

  --
  -- Procedure Name
  --   update_row
  -- Purpose
  --   Update a row in the table, with the information given in the parameters
  -- History
  --   11/24/93		Tony Lower		Created
  --
  PROCEDURE update_row (
	X_rowid				varchar2,
	X_table_id 			number,
	X_name 				varchar2,
	X_description			varchar2	default NULL,
	X_repository_id			number,
	X_alias				varchar2	default NULL,
	X_table_level			varchar2	default NULL,
	X_table_type			varchar2	default NULL);


  --
  -- Procedure Name
  --   lock_row
  -- History
  --   11/17/93		Devesh Khatu		Created
  --
  PROCEDURE lock_row( tab_id IN number);



  --
  -- Procedure Name
  --   select_row
  -- Purpose
  --   Select a row from the table, given the primary key
  -- History
  --   11/17/93		Devesh Khatu		Created
  --
  PROCEDURE select_row (
	row IN OUT cn_obj_tables_v%ROWTYPE);


END cn_obj_tables_v_pkg;

 

/
