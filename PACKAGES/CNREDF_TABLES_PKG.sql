--------------------------------------------------------
--  DDL for Package CNREDF_TABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CNREDF_TABLES_PKG" AUTHID CURRENT_USER as
-- $Header: cnredfbs.pls 115.1 99/07/16 07:14:01 porting ship $


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE DEFAULT_ROW ( X_table_id IN OUT number );


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE SELECT_COLUMNS (X_table_level	IN OUT		varchar2,
			    X_table_level_name  IN OUT		varchar2);


END CNREDF_Tables_PKG;

 

/
