--------------------------------------------------------
--  DDL for Package CNREDF_TRIG_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CNREDF_TRIG_COLUMNS_PKG" AUTHID CURRENT_USER as
-- $Header: cnredfes.pls 115.1 99/07/16 07:14:20 porting ship $


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE DEFAULT_ROW (X_column_trigger_id IN OUT number);


  --
  -- Procedure Name
  --   select_columns
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE select_columns (X_column_id		IN OUT		number,
			    X_column_name 	IN OUT		varchar2);


END CNREDF_trig_columns_PKG;

 

/
