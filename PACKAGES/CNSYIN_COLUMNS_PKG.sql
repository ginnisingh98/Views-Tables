--------------------------------------------------------
--  DDL for Package CNSYIN_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CNSYIN_COLUMNS_PKG" AUTHID CURRENT_USER as
-- $Header: cnsyinbs.pls 115.1 99/07/16 07:17:45 porting ship $


  --
  -- Procedure Name
  --   select_columns
  -- History
  --   01/26/94		Tony Lower		Created
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
  --   01/26/94		Tony Lower		Created
  --
  PROCEDURE default_row (	X_table_id		IN OUT	number,
				X_position		IN OUT	number,
				X_column_id		IN OUT	number);


END CNSYIN_Columns_PKG;

 

/
