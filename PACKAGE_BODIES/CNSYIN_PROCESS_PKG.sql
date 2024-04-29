--------------------------------------------------------
--  DDL for Package Body CNSYIN_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CNSYIN_PROCESS_PKG" as
-- $Header: cnsyineb.pls 115.1 99/07/16 07:17:59 porting ship $


  --
  -- Procedure Name
  --   populate_fields
  -- History
  --   01/26/94		Tony Lower		Created
  --
  PROCEDURE Populate_Fields ( X_Process_type			varchar2,
			      X_process_name	IN OUT		varchar2,
			      X_module_id			number,
			      X_module_name	IN OUT		varchar2) IS

  BEGIN

    SELECT name
      INTO X_module_name
      FROM cn_modules
     WHERE module_id = X_module_id;

  END Populate_Fields;


END CNSYIN_Process_PKG;

/
