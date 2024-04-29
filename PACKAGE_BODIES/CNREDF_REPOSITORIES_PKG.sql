--------------------------------------------------------
--  DDL for Package Body CNREDF_REPOSITORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CNREDF_REPOSITORIES_PKG" as
-- $Header: cnredfab.pls 115.1 99/07/16 07:13:53 porting ship $


  --
  -- Procedure Name
  --   default_row
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE default_row ( X_repository_id IN OUT number ) IS

  BEGIN

    IF X_repository_id is NULL THEN

      SELECT cn_repositories_s.nextval
	INTO X_repository_id
	FROM dual;

    END IF;

  END DEFAULT_ROW;


  --
  -- Procedure Name
  --   select_columns
  -- History
  --   12/28/93		Paul Mitchell		Created
  --
  PROCEDURE select_columns (X_application_type	    IN OUT	varchar2,
			    X_application_type_name IN OUT	varchar2) IS

  BEGIN

    SELECT meaning INTO X_application_type_name
      FROM cn_lookups
     WHERE lookup_code = X_application_type
       AND lookup_type = 'APPLICATION_TYPE';

  END select_columns;


END CNREDF_Repositories_PKG;

/
