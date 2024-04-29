--------------------------------------------------------
--  DDL for Package Body CNREDF_TABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CNREDF_TABLES_PKG" as
-- $Header: cnredfbb.pls 115.1 99/07/16 07:13:59 porting ship $


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE DEFAULT_ROW ( X_table_id IN OUT number ) IS

  BEGIN

    IF X_table_id is NULL THEN

      SELECT cn_objects_s.nextval
	INTO X_table_id
	FROM dual;

    END IF;


  END DEFAULT_ROW;



  --
  -- Procedure Name
  --   select_columns
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE select_columns (X_table_level	IN OUT		varchar2,
			    X_table_level_name 	IN OUT		varchar2) IS

  BEGIN

    SELECT meaning
      INTO X_table_level_name
      FROM cn_lookups
     WHERE lookup_code = X_table_level
       AND lookup_type = 'TABLE_LEVEL';

  END select_columns;


END CNREDF_Tables_PKG;

/
