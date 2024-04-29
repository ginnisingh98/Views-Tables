--------------------------------------------------------
--  DDL for Package CNREDF_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CNREDF_COLUMNS_PKG" AUTHID CURRENT_USER as
-- $Header: cnredfcs.pls 115.1 99/07/16 07:14:07 porting ship $


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE select_columns(	X_data_type		IN OUT	varchar2,
				X_column_type		IN OUT	varchar2,
				X_dimension_id		IN OUT	number,
				X_data_type_name	IN OUT	varchar2,
				X_type_name		IN OUT	varchar2,
				X_dimension_name	IN OUT	varchar2);


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE default_row (	X_column_id		IN OUT	number);

END CNREDF_columns_PKG;

 

/
