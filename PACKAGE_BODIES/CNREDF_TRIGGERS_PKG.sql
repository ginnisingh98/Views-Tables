--------------------------------------------------------
--  DDL for Package Body CNREDF_TRIGGERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CNREDF_TRIGGERS_PKG" as

-- $Header: cnredfdb.pls 115.0 99/07/16 07:14:10 porting ship $

  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE select_columns(	X_table_id		IN OUT	number,
				X_triggering_event	IN OUT	varchar2,
				X_table_name		IN OUT	varchar2,
				X_event_name		IN OUT	varchar2) IS

  BEGIN

    IF X_table_ID is NOT NULL THEN

      SELECT name
        INTO X_table_name
        FROM cn_obj_tables_v
       WHERE table_id = X_table_id;

    ELSE
      X_table_name := NULL;
    END IF;


    IF X_triggering_event is NOT NULL THEN
      SELECT meaning
        INTO X_event_name
        FROM cn_lookups
       WHERE lookup_code = X_triggering_event
	 AND lookup_type = 'TRIGGERING_EVENT';

    ELSE
      X_event_name := NULL;
    END IF;

  END select_columns;



  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE default_row (	X_trigger_id		IN OUT	number) IS

  BEGIN

    IF X_trigger_id is NULL THEN
      SELECT cn_objects_s.nextval
        INTO X_trigger_id FROM dual;
    END IF;

  END default_row;


END CNREDF_triggers_PKG;

/
