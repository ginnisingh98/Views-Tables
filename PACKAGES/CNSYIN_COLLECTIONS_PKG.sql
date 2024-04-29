--------------------------------------------------------
--  DDL for Package CNSYIN_COLLECTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CNSYIN_COLLECTIONS_PKG" AUTHID CURRENT_USER as
-- $Header: cnsyincs.pls 115.1 99/07/16 07:17:50 porting ship $


  --
  -- Procedure Name
  --   default_row
  -- Purpose
  --
  -- History
  --   01/26/94		Tony Lower		Created
  --
  PROCEDURE default_row (	    X_module_id 	IN OUT	number);



  --
  -- Procedure Name
  --   default_row
  -- Purpose
  --
  -- History
  --   01/26/94		Tony Lower		Created
  --
  PROCEDURE select_columns (	    X_event_id		IN 	number,
				    X_event_name	IN OUT	varchar2);



  --
  -- Procedure Name
  --   get_event_id_defaults
  -- Purpose
  -- History
  --   01/26/94		Tony Lower		Created
  --
  PROCEDURE get_event_id_defaults ( X_event_id		IN OUT	number,
				    X_schema		IN OUT	varchar2,
				    X_application_type	IN OUT	varchar2,
				    X_description	IN OUT	varchar2,
				    X_version		IN OUT	varchar2,
				    X_status		IN OUT	varchar2,
				    X_repository_id	IN OUT	number);


END CNSYIN_Collections_PKG;

 

/
