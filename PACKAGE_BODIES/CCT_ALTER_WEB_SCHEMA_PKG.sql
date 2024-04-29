--------------------------------------------------------
--  DDL for Package Body CCT_ALTER_WEB_SCHEMA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_ALTER_WEB_SCHEMA_PKG" AS
/* $Header: cctupawb.pls 120.0 2005/06/02 09:38:20 appldev noship $ */
   PROCEDURE modify_column_delault (schema_name IN VARCHAR2,
		 table_name IN VARCHAR2, col_name IN VARCHAR2) IS

     table_not_found exception;
     pragma exception_init(table_not_found, -942);

     duplicate_column exception;
     pragma exception_init(duplicate_column, -1430);
   BEGIN
	 SAVEPOINT CCTUPG;
      EXECUTE IMMEDIATE 'LOCK TABLE ' || schema_name || '.' || table_name
         || ' IN EXCLUSIVE MODE';
      EXECUTE IMMEDIATE 'ALTER TABLE ' || schema_name || '.' || table_name
         || ' MODIFY ( ' || col_name  || '  DEFAULT 0 )';
      COMMIT ;  -- used to release the table lock.
   EXCEPTION
      WHEN table_not_found THEN
      COMMIT ;  -- used to release the table lock.
        raise_application_error(-20000, 'Table '||table_name||' not found') ;

      WHEN duplicate_column THEN
      COMMIT ;  -- used to release the table lock.
	   -- not a problem allows the script to be rerun.
	   null;

      WHEN OTHERS THEN
      COMMIT ;  -- used to release the table lock.
        raise_application_error(-20000, sqlerrm || '. Could not add column')  ;
   END modify_column_delault;

   PROCEDURE update_null_object_versions IS
   BEGIN

	 SAVEPOINT CCTUPGCOL;

      UPDATE cct_middlewares
	 SET object_version_number = 0
	 where object_version_number IS NULL;

      UPDATE CCT_CLASSIFICATIONS
	 SET object_version_number = 0
	 where object_version_number IS NULL;

      UPDATE CCT_CLASSIFICATION_RULES
	 SET object_version_number = 0
	 where object_version_number IS NULL;

      UPDATE CCT_IVR_MAPS
	 SET object_version_number = 0
	 where object_version_number IS NULL;

      UPDATE CCT_LINES
	 SET object_version_number = 0
	 where object_version_number IS NULL;

      UPDATE CCT_MIDDLEWARE_PARAMS
	 SET object_version_number = 0
	 where object_version_number IS NULL;

      UPDATE CCT_MIDDLEWARE_VALUES
	 SET object_version_number = 0
	 where object_version_number IS NULL;

      UPDATE CCT_TELESET_TYPES
	 SET object_version_number = 0
	 where object_version_number IS NULL;

      UPDATE CCT_STATIC_ROUTES
	 SET object_version_number = 0
	 where object_version_number IS NULL;

      UPDATE CCT_ROUTE_PARAMS
	 SET object_version_number = 0
	 where object_version_number IS NULL;

      UPDATE CCT_ROUTES
	 SET object_version_number = 0
	 where object_version_number IS NULL;

      UPDATE CCT_TELESETS
	 SET object_version_number = 0
	 where object_version_number IS NULL;
   EXCEPTION

      WHEN OTHERS THEN
	   rollback;
        raise_application_error(-20000, sqlerrm || '.UPDATE COL VALUE, Could not add column')  ;


   END;

   PROCEDURE update_route_param_operator(schema_name  IN  VARCHAR2) is
     l_str varchar2(200):=  'ALTER TABLE ' || schema_name || '.' ||'CCT_ROUTE_PARAMS MODIFY ( OPERATION DEFAULT '''||'='||''' )';
   BEGIN

   	SAVEPOINT CCTUPG1;

   	   EXECUTE IMMEDIATE 'LOCK TABLE ' || schema_name || '.' ||'CCT_ROUTE_PARAMS  IN EXCLUSIVE MODE';
        EXECUTE IMMEDIATE l_str;
        COMMIT ;  -- used to release the table lock.

        UPDATE CCT_ROUTE_PARAMS
	   SET operation = '='
	   where operation IS NULL;

        COMMIT ;  -- used to release the table lock.

   EXCEPTION

      WHEN OTHERS THEN
	   rollback;
        raise_application_error(-20000, sqlerrm || '.UPDATE_ROUTE_PARAM_OPERATOR COL VALUE, Could not modify')  ;

   END update_route_param_operator;

END cct_alter_web_schema_pkg;

/
