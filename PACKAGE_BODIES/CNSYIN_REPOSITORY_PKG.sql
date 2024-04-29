--------------------------------------------------------
--  DDL for Package Body CNSYIN_REPOSITORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CNSYIN_REPOSITORY_PKG" as
-- $Header: cnsyindb.pls 115.1 99/07/16 07:17:53 porting ship $


  --
  -- Procedure Name
  --   select_columns
  -- History
  --   01/26/94		Tony Lower		Created
  --
  PROCEDURE select_columns (	X_repository_id IN OUT 		number,
				X_status	IN OUT		varchar2,
				X_status_name   IN OUT		varchar2,
				X_usage		IN OUT		varchar2,
				X_usage_name 	IN OUT		varchar2) IS

  BEGIN

    SELECT lookup1.meaning, lookup2.meaning
      INTO X_status_name, X_usage_name
      FROM cn_lookups lookup1, cn_lookups lookup2
     WHERE lookup1.lookup_type = 'REPOSITORY_STATUS'
       AND lookup1.lookup_code = X_status
       AND lookup2.lookup_type = 'REPOSITORY_USAGE'
       AND lookup2.lookup_code = X_usage;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      NULL;

  END select_columns;


END CNSYIN_Repository_PKG;

/
