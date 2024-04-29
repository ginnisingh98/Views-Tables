--------------------------------------------------------
--  DDL for Package CNREDF_EVENT_TRIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CNREDF_EVENT_TRIG_PKG" AUTHID CURRENT_USER as
-- $Header: cnredfgs.pls 115.1 99/07/16 07:14:31 porting ship $


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE select_columns (X_trigger_id	IN OUT		number,
			    X_trigger_name 	IN OUT		varchar2,
			    X_table_name	IN OUT		varchar2);



  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE delete_row (X_trigger_ID 				number);


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE Insert_Row (X_trigger_id				number,
			X_event_id				number);



  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE Lock_Row (X_trigger_id				number);



  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE Get_Trigger_ID_Defaults (X_trigger_id		number,
				     X_table_id		IN OUT	varchar2,
				     X_table_name	IN OUT	varchar2);

END CNREDF_event_trig_PKG;

 

/
