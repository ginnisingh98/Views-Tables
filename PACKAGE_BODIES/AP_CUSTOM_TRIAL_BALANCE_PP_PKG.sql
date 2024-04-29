--------------------------------------------------------
--  DDL for Package Body AP_CUSTOM_TRIAL_BALANCE_PP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CUSTOM_TRIAL_BALANCE_PP_PKG" AS
/*$Header: apctbppb.pls 120.3 2004/10/27 01:31:30 pjena noship $*/

/*==========================================================================
 Customize the Creation of Trial Balance from Posting
 *=====================================================================*/
PROCEDURE ap_custom_trial_balance_pp IS

  c                              INTEGER;
  rows                           INTEGER;
  statement                      VARCHAR2(2000);
  dummy                          VARCHAR2(25);
  l_country_code                 VARCHAR2(25);


BEGIN

  FND_PROFILE.GET('JGZZ_COUNTRY_CODE', l_country_code);

  IF l_country_code = 'BR' then

  BEGIN

  -- Call Stored Procedure JL_BR_AP_BAL_MAINTENANCE to create the balance
  -- and transactions

  SELECT 'X' into dummy
    from user_objects
     where object_name = 'JL_BR_AP_BALANCE_MAINTENANCE'
      and object_type = 'PACKAGE BODY';

  c := dbms_sql.open_cursor;
  statement := 'BEGIN
                JL_BR_AP_BALANCE_MAINTENANCE.JL_BR_AP_BAL_MAINTENANCE' ||
                '; END; ';

      dbms_sql.parse(c, statement, dbms_sql.native);

      rows := dbms_sql.execute(c);
      dbms_sql.close_cursor(c);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
         WHEN OTHERS THEN NULL;
      END;

ELSE

    return;

END IF;

END ap_custom_trial_balance_pp;

END AP_CUSTOM_TRIAL_BALANCE_PP_PKG;

/
