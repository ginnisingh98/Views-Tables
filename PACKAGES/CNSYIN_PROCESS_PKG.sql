--------------------------------------------------------
--  DDL for Package CNSYIN_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CNSYIN_PROCESS_PKG" AUTHID CURRENT_USER as
-- $Header: cnsyines.pls 115.1 99/07/16 07:18:02 porting ship $


  --
  -- Procedure Name
  --   populate_fields
  -- History
  --   01/26/94		Tony Lower		Created
  --
  PROCEDURE Populate_Fields ( X_Process_type			varchar2,
			      X_process_name	IN OUT		varchar2,
			      X_module_id			number,
			      X_module_name	IN OUT		varchar2);

END CNSYIN_Process_PKG;

 

/
