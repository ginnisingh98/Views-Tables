--------------------------------------------------------
--  DDL for Package CNREDF_TRIGGERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CNREDF_TRIGGERS_PKG" AUTHID CURRENT_USER as

-- $Header: cnredfds.pls 115.0 99/07/16 07:14:13 porting ship $

  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE DEFAULT_ROW ( X_trigger_id IN OUT number );


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE select_columns(	X_table_id		IN OUT	number,
				X_triggering_event	IN OUT	varchar2,
				X_table_name		IN OUT	varchar2,
				X_event_name		IN OUT	varchar2);


END CNREDF_triggers_PKG;

 

/
