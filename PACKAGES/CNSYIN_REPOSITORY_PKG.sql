--------------------------------------------------------
--  DDL for Package CNSYIN_REPOSITORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CNSYIN_REPOSITORY_PKG" AUTHID CURRENT_USER as
-- $Header: cnsyinds.pls 115.1 99/07/16 07:17:56 porting ship $


  --
  -- Procedure Name
  --   select_columns
  -- History
  --   01/26/94		Tony Lower		Created
  --
  PROCEDURE select_columns (	X_repository_id IN OUT 		number,
				X_status  	IN OUT		varchar2,
				X_status_name   IN OUT		varchar2,
				X_usage		IN OUT		varchar2,
				X_usage_name 	IN OUT		varchar2);


END CNSYIN_Repository_PKG;

 

/
