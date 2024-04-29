--------------------------------------------------------
--  DDL for Package Body CNREDF_TRIG_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CNREDF_TRIG_COLUMNS_PKG" as
-- $Header: cnredfeb.pls 115.1 99/07/16 07:14:16 porting ship $


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE DEFAULT_ROW ( X_column_trigger_id IN OUT number ) IS

  BEGIN

    IF X_column_trigger_id is NULL THEN

      SELECT cn_column_trg_maps_s.nextval
	INTO X_column_trigger_id
	FROM dual;

    END IF;

  END DEFAULT_ROW;



  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE select_columns (X_column_id		IN OUT		number,
			    X_column_name 	IN OUT		varchar2) IS
  BEGIN

    SELECT name
      INTO X_column_name
      FROM cn_obj_columns_v
     WHERE column_id = X_column_id;

  END select_columns;


END CNREDF_trig_columns_PKG;

/
