--------------------------------------------------------
--  DDL for Package Body CNREDF_EVENT_TRIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CNREDF_EVENT_TRIG_PKG" as
-- $Header: cnredfgb.pls 115.1 99/07/16 07:14:28 porting ship $


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE select_columns (X_trigger_id	IN OUT		number,
			    X_trigger_name 	IN OUT		varchar2,
			    X_table_name	IN OUT		varchar2) IS

  BEGIN

    SELECT trg.name, tab.name
      INTO X_trigger_name, X_table_name
      FROM cn_obj_triggers_v trg,
	   cn_obj_tables_v tab
     WHERE trg.trigger_id = X_trigger_id
       AND tab.table_id = trg.table_id;

  END select_columns;



  --
  -- Procedure Name
  --   delete_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE delete_row (X_trigger_ID 				number) IS

  BEGIN

    UPDATE cn_obj_triggers_v
       SET event_id = NULL
     WHERE trigger_id = X_trigger_id;

  END delete_row;

  PROCEDURE Insert_Row (X_trigger_id				number,
			X_event_id				number) IS

  BEGIN

    UPDATE cn_obj_triggers_v
       SET event_id = X_event_id
     WHERE trigger_id = X_trigger_id;

  END Insert_Row;



  --
  -- Procedure Name
  --   lock_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE Lock_Row (X_trigger_id				number) IS

      Dumy number(15);

  BEGIN

    SELECT trigger_id
      INTO Dumy
      FROM cn_obj_triggers_v
     WHERE trigger_id = X_trigger_ID
       FOR UPDATE OF cn_obj_triggers_v.event_id;

  END Lock_Row;


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE Get_Trigger_ID_Defaults (X_trigger_id		number,
				     X_table_id		IN OUT	varchar2,
				     X_table_name	IN OUT	varchar2) IS

  BEGIN

    SELECT trg.table_id, tab.name
      INTO X_table_id, X_table_name
      FROM cn_obj_triggers_v trg,
	   cn_obj_tables_v tab
     WHERE trg.trigger_id = X_trigger_id
       AND tab.table_id = trg.table_id;

  END Get_Trigger_ID_Defaults;


END CNREDF_event_trig_PKG;

/
