--------------------------------------------------------
--  DDL for Package CNREDF_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CNREDF_EVENTS_PKG" AUTHID CURRENT_USER as
-- $Header: cnredffs.pls 115.1 99/07/16 07:14:25 porting ship $


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE DEFAULT_ROW ( X_event_id IN OUT number );

END CNREDF_events_PKG;

 

/
