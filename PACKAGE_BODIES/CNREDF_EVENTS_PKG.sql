--------------------------------------------------------
--  DDL for Package Body CNREDF_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CNREDF_EVENTS_PKG" as
-- $Header: cnredffb.pls 115.1 99/07/16 07:14:22 porting ship $


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE DEFAULT_ROW ( X_event_id IN OUT number ) IS

  BEGIN

    IF X_event_id is NULL THEN

      SELECT cn_events_s.nextval
	INTO X_event_id
	FROM dual;

    END IF;

  END DEFAULT_ROW;

END CNREDF_events_PKG;

/
