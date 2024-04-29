--------------------------------------------------------
--  DDL for Package GL_BC_EVENT_TSTAMPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BC_EVENT_TSTAMPS_PKG" AUTHID CURRENT_USER AS
/* $Header: glibcets.pls 120.2 2005/05/05 00:59:22 kvora ship $ */
--
-- Package
--   gl_bc_event_tstamps_pkg
-- Purpose
--   To contain validation and insertion routines for gl_bc_event_timestamps
-- History
--   12-03-93  	D. J. Ogg	Created

  --
  -- Procedure
  --   insert_event_timestamp
  -- Purpose
  --   Used to insert a record into gl_bc_event_timestamps,
  --   if one has not yet been inserted for this chart of accounts
  --   and event.
  -- History
  --   12-03-93  D. J. Ogg    Created
  -- Arguments
  --   x_chart_of_accounts_id   ID of the chart of accounts
  --   x_event_code             Code for the event (B - budget, S - ?)
  --   x_last_updated_by	ID of the user doing the insertion
  --   x_last_update_login      Login ID of the user doing the insertion
  -- Example
  --   gl_bc_event_tstamps_pkg.insert_event_timestamp(101, 'B', 15, 25)
  -- Notes
  --
  PROCEDURE insert_event_timestamp(
			x_chart_of_accounts_id	NUMBER,
                        x_event_code            VARCHAR2,
			x_last_updated_by 	NUMBER,
			x_last_update_login	NUMBER);

  --
  -- Procedure
  --   set_event_timestamp
  -- Purpose
  --   Sets the event timestamp to the current time
  -- History
  --   12-03-93  D. J. Ogg    Created
  -- Arguments
  --   x_chart_of_accounts_id   ID of the chart of accounts
  --   x_event_code             Code for the event (B - budget, S - ?)
  --   x_last_updated_by	ID of the user doing the insertion
  --   x_last_update_login      Login ID of the user doing the insertion
  -- Example
  --   gl_bc_event_tstamps_pkg.set_event_timestamp(101, 'B', 15, 25)
  -- Notes
  --
  PROCEDURE set_event_timestamp(
  			x_chart_of_accounts_id	NUMBER,
                        x_event_code            VARCHAR2,
			x_last_updated_by	NUMBER,
			x_last_update_login     NUMBER);

  --
  -- Procedure
  --   lock_event_timestamp
  -- Purpose
  --   Locks the event timestamp
  -- History
  --   12-16-93  D. J. Ogg    Created
  -- Arguments
  --   x_chart_of_accounts_id   ID of the chart of accounts
  --   x_event_code             Code for the event (B - budget, S - ?)
  -- Example
  --   gl_bc_event_tstamps_pkg.lock_event_timestamp(101, 'B')
  -- Notes
  --
  PROCEDURE lock_event_timestamp(
  			x_chart_of_accounts_id	NUMBER,
                        x_event_code            VARCHAR2);

END gl_bc_event_tstamps_pkg;

 

/
