--------------------------------------------------------
--  DDL for Package CNREDF_REPOSITORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CNREDF_REPOSITORIES_PKG" AUTHID CURRENT_USER as
-- $Header: cnredfas.pls 115.1 99/07/16 07:13:56 porting ship $


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE DEFAULT_ROW ( X_repository_id IN OUT number );


  --
  -- Procedure Name
  --   select_columns
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE SELECT_COLUMNS (X_application_type	     IN OUT	varchar2,
			    X_application_type_name  IN OUT	varchar2);


END CNREDF_Repositories_PKG;

 

/
