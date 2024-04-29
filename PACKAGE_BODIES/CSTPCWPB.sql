--------------------------------------------------------
--  DDL for Package Body CSTPCWPB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPCWPB" AS
/* $Header: CSTPWPBB.pls 120.1.12000000.3 2007/05/31 14:20:45 sbhati ship $ */

FUNCTION WIPCBR (
    i_org_id                      NUMBER,
    i_user_id                     NUMBER,
    i_login_id                    NUMBER,
    i_from_period_id              NUMBER,
    err_buf                OUT NOCOPY    VARCHAR2)
RETURN INTEGER
IS
    where_num        NUMBER;

   cursor c_period_lists
          (l_organization_id number,
	   l_acct_per_id     number)
	  is
  select acct_period_id
    from org_acct_periods
   where organization_id   = l_organization_id
     and acct_period_id   >= l_acct_per_id;

BEGIN

    err_buf   := ' ';

    /*----------------------------------------------------------+
    | Process discrete jobs                                     |
    +-----------------------------------------------------------*/

    FOR acct_period_rec IN c_period_lists(i_org_id,i_from_period_id) LOOP

    where_num := 100;

    INSERT INTO WIP_PERIOD_BALANCES
        (ACCT_PERIOD_ID, WIP_ENTITY_ID,
        REPETITIVE_SCHEDULE_ID, LAST_UPDATE_DATE,
        LAST_UPDATED_BY, CREATION_DATE,
        CREATED_BY, LAST_UPDATE_LOGIN,
        ORGANIZATION_ID, CLASS_TYPE,
        TL_RESOURCE_IN, TL_OVERHEAD_IN,
        TL_OUTSIDE_PROCESSING_IN, PL_MATERIAL_IN,
        PL_MATERIAL_OVERHEAD_IN, PL_RESOURCE_IN,
        PL_OVERHEAD_IN, PL_OUTSIDE_PROCESSING_IN,
        TL_MATERIAL_OUT, TL_MATERIAL_OVERHEAD_OUT, TL_RESOURCE_OUT,
        TL_OVERHEAD_OUT, TL_OUTSIDE_PROCESSING_OUT,
        PL_MATERIAL_OUT, PL_MATERIAL_OVERHEAD_OUT,
        PL_RESOURCE_OUT, PL_OVERHEAD_OUT,
        PL_OUTSIDE_PROCESSING_OUT,
        PL_MATERIAL_VAR, PL_MATERIAL_OVERHEAD_VAR,
        PL_RESOURCE_VAR, PL_OUTSIDE_PROCESSING_VAR,
        PL_OVERHEAD_VAR, TL_MATERIAL_VAR, TL_MATERIAL_OVERHEAD_VAR,
        TL_RESOURCE_VAR, TL_OUTSIDE_PROCESSING_VAR,
        TL_OVERHEAD_VAR)
    SELECT
        acct_period_rec.acct_period_id,
	WDJ.WIP_ENTITY_ID,
        NULL, SYSDATE,
        i_user_id, SYSDATE,
        i_user_id, i_login_id,
        i_org_id, WAC.CLASS_TYPE,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    FROM WIP_DISCRETE_JOBS WDJ,
         WIP_ACCOUNTING_CLASSES WAC
    WHERE WDJ.STATUS_TYPE IN (3, 4, 5, 6, 7, 14, 15)
    AND   WDJ.DATE_RELEASED is not NULL
    AND   WDJ.ORGANIZATION_ID = i_org_id
    AND   WAC.CLASS_CODE = WDJ.CLASS_CODE
    AND   WAC.ORGANIZATION_ID = i_org_id;


    /*----------------------------------------------------------+
    | Process repetitive schedules                              |
    +-----------------------------------------------------------*/

    where_num := 200;
    INSERT INTO WIP_PERIOD_BALANCES
        (ACCT_PERIOD_ID, WIP_ENTITY_ID,
        REPETITIVE_SCHEDULE_ID, LAST_UPDATE_DATE,
        LAST_UPDATED_BY, CREATION_DATE,
        CREATED_BY, LAST_UPDATE_LOGIN,
        ORGANIZATION_ID, CLASS_TYPE,
        TL_RESOURCE_IN, TL_OVERHEAD_IN,
        TL_OUTSIDE_PROCESSING_IN, PL_MATERIAL_IN,
        PL_MATERIAL_OVERHEAD_IN, PL_RESOURCE_IN,
        PL_OVERHEAD_IN, PL_OUTSIDE_PROCESSING_IN,
        TL_MATERIAL_OUT, TL_MATERIAL_OVERHEAD_OUT, TL_RESOURCE_OUT,
        TL_OVERHEAD_OUT, TL_OUTSIDE_PROCESSING_OUT,
        PL_MATERIAL_OUT, PL_MATERIAL_OVERHEAD_OUT,
        PL_RESOURCE_OUT, PL_OVERHEAD_OUT,
        PL_OUTSIDE_PROCESSING_OUT,
        PL_MATERIAL_VAR, PL_MATERIAL_OVERHEAD_VAR,
        PL_RESOURCE_VAR, PL_OUTSIDE_PROCESSING_VAR,
        PL_OVERHEAD_VAR, TL_MATERIAL_VAR, TL_MATERIAL_OVERHEAD_VAR,
        TL_RESOURCE_VAR, TL_OUTSIDE_PROCESSING_VAR,
        TL_OVERHEAD_VAR)
    SELECT
        acct_period_rec.acct_period_id,
	WRS.WIP_ENTITY_ID,
        WRS.REPETITIVE_SCHEDULE_ID, SYSDATE,
        i_user_id, SYSDATE,
        i_user_id, i_login_id,
        i_org_id, 2,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    FROM WIP_REPETITIVE_SCHEDULES WRS
    WHERE WRS.STATUS_TYPE IN (3, 4, 6)
    AND   WRS.ORGANIZATION_ID = i_org_id;

    RETURN(0); /* No error */

    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        err_buf := 'CSTPCWPB:' || to_char(where_num) || substr(SQLERRM,1,150);
        RETURN(SQLCODE);

END WIPCBR;

END CSTPCWPB; /* end package body */

/
