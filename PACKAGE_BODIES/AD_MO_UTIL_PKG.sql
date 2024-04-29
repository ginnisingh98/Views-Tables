--------------------------------------------------------
--  DDL for Package Body AD_MO_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AD_MO_UTIL_PKG" AS
/* $Header: admoutlb.pls 120.7 2006/08/08 23:41:39 hxue noship $ */

PROCEDURE r12_moac_conv
           (p_prod_user_name         in VARCHAR2,
            p_view_name              in VARCHAR2,
            p_prod_tab_name          in VARCHAR2,
            p_prod_schema_name       in VARCHAR2,
            p_application_short_name in VARCHAR2,
            p_apps_user_name         in VARCHAR2,
            p_sec_policy_name        in VARCHAR2,
            p_action                 in VARCHAR2)

IS

   l_schema_owner  VARCHAR2(50);
   l_secured_object  VARCHAR2(30);
   l_base_object     VARCHAR2(30);

   v_synonym varchar2(100);
   v_sys_table varchar2(100);
   handle INTEGER;
   sql_stmt varchar2(2000);

   object_exists      EXCEPTION;
   object_not_exists  EXCEPTION;
   synonym_not_exists  EXCEPTION;
   pragma exception_init(object_exists, -955);
   pragma exception_init(object_not_exists, -942);
   pragma exception_init(synonym_not_exists, -1434);

   policy_flag VARCHAR2(10) := 'FALSE';

   CURSOR c_policy_exists
    ( xp_object_schema    VARCHAR2
     , xp_object_name      VARCHAR2
     , xp_policy_name      VARCHAR2
    )
   IS
    SELECT  'TRUE'
    FROM    sys.dual
    WHERE   EXISTS
      (SELECT  1
       FROM    dba_policies
       WHERE   object_owner = UPPER(xp_object_schema)
       AND     object_name  = UPPER(xp_object_name)
       AND     policy_name  = UPPER(xp_policy_name)
      );

BEGIN

  handle := DBMS_SQL.OPEN_CURSOR;
  v_synonym :=p_view_name ;

  --
  -- get the product name
  --
  v_sys_table := p_prod_schema_name ||'.'|| p_prod_tab_name;

  --
  -- Validate action passed is valid
  --

  IF (upper(p_action) NOT IN ('MOVW', 'MODFV', 'MOSYN', 'MOAOL', 'MOVPD')) THEN
      raise_application_error(-20000, 'AD_MO_UTIL_PKG - Invalid action');
  END IF;

  --
  -- Drop the view if action is MOVW
  --

  IF (upper(p_action) = 'MOVW') THEN
     sql_stmt:= 'drop view ' || p_apps_user_name ||  '.'|| p_view_name;
     dbms_sql.parse(handle,sql_stmt,DBMS_SQL.V7);

  --
  -- Replace db default
  --

  ELSIF ( upper(p_action) = 'MODFV') THEN
    sql_stmt:='alter table ' || v_sys_table ||
              ' modify ( org_id DEFAULT NULL )';
    dbms_sql.parse(handle,sql_stmt,DBMS_SQL.V7);

    sql_stmt:='alter synonym ' || p_apps_user_name || '.' ||
              p_prod_tab_name ||' compile';
    dbms_sql.parse(handle,sql_stmt,DBMS_SQL.V7);

  --
  -- Create synonym
  --

  ELSIF (upper(p_action) = 'MOSYN') THEN

  -- First drop synonym , needed to refresh VPD policy

    sql_stmt:= 'drop synonym ' || p_apps_user_name || '.'||v_synonym;
    dbms_sql.parse(handle,sql_stmt,DBMS_SQL.V7);

  -- Then create synonym

    sql_stmt:='create or replace synonym ' || p_apps_user_name || '.' ||
              v_synonym || ' for ' || v_sys_table;
    dbms_sql.parse(handle,sql_stmt,DBMS_SQL.V7);

  --
  -- Delete view from AOL data dictionary
  --

  ELSIF ( upper(p_action) = 'MOAOL') THEN

     Begin

  -- Delete from FND_VIEWS

     Fnd_Dictionary_Pkg.RemoveView(p_application_short_name, p_view_name);
     EXCEPTION
       WHEN OTHERS THEN NULL;
     end;

  --
  -- Add the security policy.
  --

  ELSIF (upper(p_action) = 'MOVPD') THEN

    OPEN c_policy_exists(p_apps_user_name, v_synonym, p_sec_policy_name);
    FETCH c_policy_exists INTO policy_flag;

-- if policy aleady exists then drop the policy.

    IF policy_flag='TRUE' THEN
      DBMS_RLS.DROP_POLICY( p_apps_user_name,
	  	           v_synonym,
		           p_sec_policy_name);
    END IF;

    IF (upper(v_synonym) in ('AP_EXPENSE_REPORTS',
                             'AP_EXPENSE_REPORT_PARAMS')) THEN

      dbms_rls.add_policy (p_apps_user_name,
                           v_synonym,
                           p_sec_policy_name,
                           p_apps_user_name,
                           'AP_WEB_UTILITIES_PKG.ORGSECURITY', -- OIC policy
                           'SELECT, INSERT, UPDATE, DELETE',
                           TRUE,
                           TRUE,
                           FALSE,
                           DBMS_RLS.SHARED_CONTEXT_SENSITIVE);

    ELSIF (upper(v_synonym) = 'QP_LIST_HEADERS_B') THEN

      dbms_rls.add_policy (p_apps_user_name,
                           v_synonym,
                           p_sec_policy_name,
                           p_apps_user_name,
                           'QP_SECURITY.QP_ORG_SECURITY', -- QP policy
                           'SELECT, INSERT, UPDATE, DELETE',
                           TRUE,
                           TRUE,
                           FALSE,
                           DBMS_RLS.SHARED_CONTEXT_SENSITIVE);

    ELSIF (upper(v_synonym) = 'AR_PAYMENT_SCHEDULES') THEN

      dbms_rls.add_policy (p_apps_user_name,
                           v_synonym,
                           p_sec_policy_name,
                           p_apps_user_name,
                           'MO_GLOBAL.ORG_SECURITY_GLOBAL',
                           'SELECT, INSERT, UPDATE, DELETE',
                           TRUE,
                           TRUE,
                           FALSE,
                           DBMS_RLS.SHARED_CONTEXT_SENSITIVE);

    ELSE
      dbms_rls.add_policy (p_apps_user_name,
                           v_synonym,
                           p_sec_policy_name,
                           p_apps_user_name,
                           'MO_GLOBAL.ORG_SECURITY',    -- Standard MO VPD policy
                           'SELECT, INSERT, UPDATE, DELETE',
                           TRUE,
                           TRUE,
                           FALSE,
                           DBMS_RLS.SHARED_CONTEXT_SENSITIVE);
    END IF;

 CLOSE c_policy_exists;

  END IF;

  EXCEPTION
  WHEN object_exists then null;
  WHEN object_not_exists then null;
  WHEN synonym_not_exists then

  --check for MOSYN action

  IF upper(p_action) = 'MOSYN' then
    sql_stmt:='create or replace synonym ' || p_apps_user_name || '.'||
              v_synonym || ' for ' || v_sys_table;
    dbms_sql.parse(handle,sql_stmt,DBMS_SQL.V7);
  END IF;

  WHEN OTHERS THEN

   raise_application_error(-20000, sqlerrm ||':  ' ||
                          'AD_MO_UTIL_PKG - Error in creating ' || p_view_name);


 END r12_moac_conv;
END ad_mo_util_pkg;

/
