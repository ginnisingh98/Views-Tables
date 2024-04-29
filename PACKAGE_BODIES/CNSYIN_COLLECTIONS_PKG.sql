--------------------------------------------------------
--  DDL for Package Body CNSYIN_COLLECTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CNSYIN_COLLECTIONS_PKG" as
-- $Header: cnsyincb.pls 115.1 99/07/16 07:17:47 porting ship $


  --
  -- Procedure Name
  --   default_row
  -- Purpose
  --
  -- History
  --   01/26/94		Tony Lower		Created
  --
  PROCEDURE default_row(	X_module_id	IN OUT		number) IS

  BEGIN

    IF X_module_id IS NULL THEN
      SELECT cn_modules_s.nextval
        INTO X_module_id
	FROM dual;

    END IF;

  END default_row;


  --
  -- Procedure Name
  --   default_row
  -- Purpose
  --
  -- History
  --   01/26/94		Tony Lower		Created
  --
  PROCEDURE select_columns (	X_event_id	IN 		number,
				X_event_name	IN OUT 		varchar2) IS

  BEGIN

    SELECT name
      INTO X_event_name
      FROM cn_events
     WHERE event_id = X_event_id;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN NULL;

  END select_columns;


  --
  -- Procedure Name
  --   get_event_id_defaults
  -- Purpose
  -- History
  --   01/26/94		Tony Lower		Created
  --
  PROCEDURE GET_event_id_DEFAULTS ( X_event_id		IN OUT	number,
				    X_schema		IN OUT	varchar2,
				    X_application_type	IN OUT	varchar2,
				    X_description	IN OUT	varchar2,
				    X_version		IN OUT	varchar2,
				    X_status		IN OUT	varchar2,
				    X_repository_id	IN OUT	number) IS
  BEGIN

    SELECT rr.schema, rr.application_type, rr.description,
	   rr.version, rr.status, rr.repository_id
      INTO X_schema, X_application_type, X_description, X_version,
	   X_status, X_repository_id
      FROM cn_repositories rr, cn_events re
     WHERE rr.repository_id = re.application_repository_id
       AND re.event_id = X_event_id;

  END GET_event_id_DEFAULTS;

END CNSYIN_Collections_PKG;

/
