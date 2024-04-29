--------------------------------------------------------
--  DDL for Package Body CSTPWPVR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPWPVR" AS
/* $Header: CSTPWPVB.pls 120.2.12010000.2 2010/01/22 11:14:48 smsasidh ship $ */

FUNCTION REPVAR
   (i_org_id          IN    NUMBER,
    i_close_period_id IN    NUMBER,
    i_user_id         IN    NUMBER,
    i_login_id        IN    NUMBER,
    err_buf           OUT NOCOPY  VARCHAR2)
RETURN INTEGER
IS
    cmlcpx_status      EXCEPTION;
    realloc_failed     EXCEPTION;
    l_status           NUMBER;
    l_group_id         NUMBER;
    l_eam_org	       VARCHAR2(1) := 'N';
    l_repe_var_type    NUMBER;
    where_num          NUMBER;
    my_rowid           ROWID;
    cursor c1 is
            SELECT a2.ROWID the_rowid
            FROM   WIP_TRANSACTION_ACCOUNTS a2
            ,      WIP_COST_TXN_INTERFACE i
            WHERE  i.group_id = l_group_id
            AND    i.transaction_id = a2.transaction_id
            AND    a2.base_transaction_value = 0;
    l_msg_count                 NUMBER := 0;
    l_msg_data                  VARCHAR2(8000);
    l_return_status    VARCHAR2(1);

BEGIN

   /****************************************************************
    * Obtain a group_id
    ****************************************************************/
    where_num := 50;
    SELECT wip_transactions_s.nextval
    INTO l_group_id
    FROM dual;

   /****************************************************************
    * Obtain REPETITIVE_VARIANCE_TYPE
    ****************************************************************/
    where_num := 60;
  BEGIN
    SELECT REPETITIVE_VARIANCE_TYPE
    INTO   l_repe_var_type
    FROM   WIP_PARAMETERS
    WHERE  ORGANIZATION_ID = i_org_id;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN NULL;
  END;

   /****************************************************************
    * Insert header rows for each expense non-std job/eam job that is NOT
    * closed.
    ****************************************************************/
    where_num := 100;
    INSERT INTO wip_cost_txn_interface
       (TRANSACTION_ID,                LAST_UPDATE_DATE,
        LAST_UPDATED_BY,               CREATION_DATE,
        CREATED_BY,                    LAST_UPDATE_LOGIN,
        PROCESS_PHASE,                 PROCESS_STATUS,
        ORGANIZATION_ID,               WIP_ENTITY_ID,
        ACCT_PERIOD_ID,                TRANSACTION_TYPE,
        TRANSACTION_DATE,              GROUP_ID,
        LINE_ID)
    SELECT
        wip_transactions_s.nextval,    SYSDATE,
        i_user_id,                     SYSDATE,
        i_user_id,                     i_login_id,
        2,                             2,
        i_org_id,                      b.wip_entity_id,
        i_close_period_id,             5,
        oa.schedule_close_date,        l_group_id,
        NULL
    FROM wip_period_balances b,
         org_acct_periods oa,
         wip_discrete_jobs j
    WHERE b.class_type IN (4,6) -- Bug #2357983.
	/* modified for EAM (class_type = 6); modified for OSFM (class_type = 7) */
    AND   b.acct_period_id = i_close_period_id
    AND   j.wip_entity_id = b.wip_entity_id
    AND   b.organization_id = i_org_id
    AND   oa.organization_id = i_org_id
    AND   oa.acct_period_id = i_close_period_id
    AND   j.date_closed IS NULL;

   /*-------------------------------------------------------------
    | See whether there is any expense job
    --------------------------------------------------------------*/

    IF SQL%ROWCOUNT > 0  THEN

    /**************************************************************
     *     Asset Route Re-distribution
     *      - Maintenance Work Orders
     *************************************************************/

     select nvl(eam_enabled_flag, 'N')
     into l_eam_org
     from mtl_parameters
     where organization_id = i_org_id;

     if (l_eam_org = 'Y') then
       CST_eamCost_PUB.Redistribute_WIP_Accounts (
                  p_api_version         =>      1.0,
                  p_wcti_group_id       =>      l_group_id,
                  p_user_id             =>      i_user_id,
                  p_request_id          =>      null,
                  p_prog_id             =>      null,
                  p_prog_app_id         =>      null,
                  p_login_id            =>      i_login_id,
                  x_return_status       =>      l_return_status,
                  x_msg_count           =>      l_msg_count,
                  x_msg_data            =>      l_msg_data);

       if (l_return_status <> fnd_api.g_ret_sts_success) then
         raise realloc_failed;
       end if;
     end if;

     /***************************************************************
      * Elemental variance for wip valuation for expense/eam jobs
      **************************************************************/
      where_num := 120;
      INSERT INTO wip_transaction_accounts
        (TRANSACTION_ID,            REFERENCE_ACCOUNT,
        LAST_UPDATE_DATE,           LAST_UPDATED_BY,
        CREATION_DATE,              CREATED_BY,
        LAST_UPDATE_LOGIN,          ORGANIZATION_ID,
        TRANSACTION_DATE,           WIP_ENTITY_ID,
        REPETITIVE_SCHEDULE_ID,     ACCOUNTING_LINE_TYPE,
        TRANSACTION_VALUE,          BASE_TRANSACTION_VALUE,
        CONTRA_SET_ID,              COST_ELEMENT_ID )
      SELECT /*+ ORDERED INDEX(WPB WIP_PERIOD_BALANCES_N1) */
       wcti.transaction_id,
       decode(cce.cost_element_id,
                1, wdj.material_account,
                2, wdj.material_overhead_account,
                3, wdj.resource_account,
                4, wdj.outside_processing_account,
                5, wdj.overhead_account) ,
        SYSDATE, i_user_id, SYSDATE, i_user_id, i_login_id,
        wpb.organization_id,
        wcti.transaction_date,
        wpb.wip_entity_id,
        NULL,
        7,
        NULL,
        SUM(decode(cce.cost_element_id,
            1, ( NVL(wpb.pl_material_out, 0)
                -NVL(wpb.pl_material_in, 0)
                +NVL(wpb.pl_material_var, 0)
                +NVL(wpb.tl_material_out, 0)
                -0
                +NVL(wpb.tl_material_var, 0)),
            2, ( NVL(wpb.pl_material_overhead_out, 0)
                -NVL(wpb.pl_material_overhead_in, 0)
                +NVL(wpb.pl_material_overhead_var, 0)
                +NVL(wpb.tl_material_overhead_out,0)
                -0
                +NVL(wpb.tl_material_overhead_var, 0)),
            3, ( NVL(wpb.pl_resource_out, 0)
                -NVL(wpb.pl_resource_in, 0)
                +NVL(wpb.pl_resource_var, 0)
                +NVL(wpb.tl_resource_out, 0)
                -NVL(wpb.tl_resource_in, 0)
                +NVL(wpb.tl_resource_var, 0)),
            4, ( NVL(wpb.pl_outside_processing_out, 0)
                -NVL(wpb.pl_outside_processing_in, 0)
                +NVL(wpb.pl_outside_processing_var, 0)
                +NVL(wpb.tl_outside_processing_out, 0)
                -NVL(wpb.tl_outside_processing_in, 0)
                +NVL(wpb.tl_outside_processing_var, 0)),
            5, ( NVL(wpb.pl_overhead_out, 0)
                -NVL(wpb.pl_overhead_in, 0)
                +NVL(wpb.pl_overhead_var, 0)
                +NVL(wpb.tl_overhead_out, 0)
                -NVL(wpb.tl_overhead_in, 0)
                +NVL(wpb.tl_overhead_var, 0)))),
        wpb.wip_entity_id,
        DECODE((max(cce.cost_element_id) - min(cce.cost_element_id)),
          0, max(cce.cost_element_id), NULL)
      from
        wip_cost_txn_interface wcti,
        wip_discrete_jobs wdj,
        wip_period_balances wpb,
        cst_cost_elements cce
      WHERE  wcti.group_id = l_group_id
      AND    wcti.line_id IS NULL
      AND    wdj.wip_entity_id = wcti.wip_entity_id
      AND    wdj.organization_id = wcti.organization_id
      AND    wpb.wip_entity_id = wdj.wip_entity_id
      AND    wpb.organization_id = wdj.organization_id
      AND    wpb.acct_period_id <= wcti.acct_period_id
      /* sum across all prior accounting periods */
      group by
       wcti.transaction_id, wcti.wip_entity_id, wcti.organization_id,
       wpb.organization_id, wcti.transaction_date,
       wpb.wip_entity_id,
       decode(cce.cost_element_id,
                1, wdj.material_account,
                2, wdj.material_overhead_account,
                3, wdj.resource_account,
                4, wdj.outside_processing_account,
                5, wdj.overhead_account);

     /***************************************************************
      * Single level variance to variance account for expense/eam jobs
      **************************************************************/
      where_num := 140;
      INSERT INTO wip_transaction_accounts
        (TRANSACTION_ID,            REFERENCE_ACCOUNT,
        LAST_UPDATE_DATE,           LAST_UPDATED_BY,
        CREATION_DATE,              CREATED_BY,
        LAST_UPDATE_LOGIN,          ORGANIZATION_ID,
        TRANSACTION_DATE,           WIP_ENTITY_ID,
        REPETITIVE_SCHEDULE_ID,     ACCOUNTING_LINE_TYPE,
        TRANSACTION_VALUE,          BASE_TRANSACTION_VALUE,
        CONTRA_SET_ID,              COST_ELEMENT_ID )
      SELECT /*+ ORDERED INDEX(WPB WIP_PERIOD_BALANCES_N1) */
        wcti.transaction_id,
        decode(cce.cost_element_id,
                1, wdj.material_variance_account,
                3, wdj.resource_variance_account,
                4, wdj.outside_proc_variance_account,
                5, wdj.overhead_variance_account),
        SYSDATE, i_user_id, SYSDATE, i_user_id, i_login_id,
        wpb.organization_id,
        wcti.transaction_date,
        wpb.wip_entity_id,
        NULL,
        8,
        NULL,
        SUM(decode(cce.cost_element_id,
            1, -1 * (NVL(wpb.pl_material_out,0)
                    - NVL(wpb.pl_material_in,0)
                    + NVL(wpb.pl_material_var,0)
                    + NVL(wpb.pl_material_overhead_out,0)
                    - NVL(wpb.pl_material_overhead_in,0)
                    + NVL(wpb.pl_material_overhead_var,0)
                    + NVL(wpb.pl_resource_out,0)
                    - NVL(wpb.pl_resource_in,0)
                    + NVL(wpb.pl_resource_var,0)
                    + NVL(wpb.pl_outside_processing_out,0)
                    - NVL(wpb.pl_outside_processing_in,0)
                    + NVL(wpb.pl_outside_processing_var,0)
                    + NVL(wpb.pl_overhead_out,0)
                    - NVL(wpb.pl_overhead_in,0)
                    + NVL(wpb.pl_overhead_var,0)
                    + NVL(wpb.tl_material_out,0)
                    - 0
                    + NVL(wpb.tl_material_var,0)
                    + NVL(wpb.tl_material_overhead_out,0)
                    - 0
                    + NVL(wpb.tl_material_overhead_var,0)),
            3, -1 * (NVL(wpb.tl_resource_out,0)
                    - NVL(wpb.tl_resource_in,0)
                    + NVL(wpb.tl_resource_var,0)),
            4, -1 * (NVL(wpb.tl_outside_processing_out,0)
                    - NVL(wpb.tl_outside_processing_in,0)
                    + NVL(wpb.tl_outside_processing_var,0)),
            5, -1 * (NVL(wpb.tl_overhead_out,0)
                    - NVL(wpb.tl_overhead_in,0)
                    + NVL(wpb.tl_overhead_var,0)))),
        wpb.wip_entity_id,
        DECODE((max(cce.cost_element_id) - min(cce.cost_element_id)),
          0, max(cce.cost_element_id), NULL)
      from
        wip_cost_txn_interface wcti,
        wip_discrete_jobs wdj,
        wip_period_balances wpb,
        cst_cost_elements cce
      WHERE wcti.group_id = l_group_id
      AND   wcti.line_id IS NULL
      AND   wdj.wip_entity_id = wcti.wip_entity_id
      AND   wdj.organization_id = wcti.organization_id
      AND   wpb.wip_entity_id = wdj.wip_entity_id
      AND   wpb.organization_id = wdj.organization_id
      AND   wpb.acct_period_id <= wcti.acct_period_id
      /* sum across all prior accounting periods */
      and   cce.cost_element_id <> 2
      group by
       wcti.transaction_id, wcti.wip_entity_id, wcti.organization_id,
       wpb.organization_id, wcti.transaction_date,
       wpb.class_type, wpb.wip_entity_id,
       decode(cce.cost_element_id,
                1, wdj.material_variance_account,
                3, wdj.resource_variance_account,
                4, wdj.outside_proc_variance_account,
                5, wdj.overhead_variance_account);

     /****************************************************************
      * Update variance columns for expense/eam jobs
      ****************************************************************/
      where_num := 160;
      UPDATE WIP_PERIOD_BALANCES wpb
      SET (LAST_UPDATED_BY,  LAST_UPDATE_DATE,  LAST_UPDATE_LOGIN,
         PL_MATERIAL_VAR,  PL_MATERIAL_OVERHEAD_VAR,
         PL_RESOURCE_VAR,  PL_OUTSIDE_PROCESSING_VAR,
         PL_OVERHEAD_VAR,  TL_MATERIAL_VAR,
         TL_MATERIAL_OVERHEAD_VAR, TL_RESOURCE_VAR,
         TL_OUTSIDE_PROCESSING_VAR, TL_OVERHEAD_VAR ) =
        (SELECT i_user_id,  SYSDATE, i_login_id,
            SUM(  NVL(PL_MATERIAL_IN,0)
                - NVL(PL_MATERIAL_OUT,0)
                - decode(acct_period_id,i_close_period_id,0,NVL(PL_MATERIAL_VAR,0))),
            SUM(  NVL(PL_MATERIAL_OVERHEAD_IN,0)
                - NVL(PL_MATERIAL_OVERHEAD_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(PL_MATERIAL_OVERHEAD_VAR,0))),
            SUM(  NVL(PL_RESOURCE_IN,0)
                - NVL(PL_RESOURCE_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(PL_RESOURCE_VAR,0))),
            SUM(  NVL(PL_OUTSIDE_PROCESSING_IN,0)
                - NVL(PL_OUTSIDE_PROCESSING_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(PL_OUTSIDE_PROCESSING_VAR,0))),
            SUM(  NVL(PL_OVERHEAD_IN,0)
                - NVL(PL_OVERHEAD_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(PL_OVERHEAD_VAR,0))),
            SUM(  0
                - NVL(TL_MATERIAL_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(TL_MATERIAL_VAR,0))),
            SUM(  0
                - NVL(TL_MATERIAL_OVERHEAD_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(TL_MATERIAL_OVERHEAD_VAR,0))),
            SUM(  NVL(TL_RESOURCE_IN,0)
                - NVL(TL_RESOURCE_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(TL_RESOURCE_VAR,0))),
            SUM(  NVL(TL_OUTSIDE_PROCESSING_IN,0)
                - NVL(TL_OUTSIDE_PROCESSING_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(TL_OUTSIDE_PROCESSING_VAR,0))),
            SUM(  NVL(TL_OVERHEAD_IN,0)
                - NVL(TL_OVERHEAD_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(TL_OVERHEAD_VAR,0)))
        FROM WIP_PERIOD_BALANCES wpb2
        WHERE wpb2.wip_entity_id = wpb.wip_entity_id
        AND   wpb2.acct_period_id <= wpb.acct_period_id)
              /* sum across all periods */
      WHERE (wpb.acct_period_id, wpb.wip_entity_id) IN
          (SELECT i.acct_period_id, i.wip_entity_id
           FROM   WIP_COST_TXN_INTERFACE i
           WHERE  i.group_id = l_group_id
           AND    i.line_id IS NULL);

    END IF; /* end for expense jobs */

   /****************************************************************
    * Insert header rows for each schedule
    ****************************************************************/
    where_num := 200;
    INSERT INTO wip_cost_txn_interface
       (TRANSACTION_ID,                LAST_UPDATE_DATE,
        LAST_UPDATED_BY,               CREATION_DATE,
        CREATED_BY,                    LAST_UPDATE_LOGIN,
        PROCESS_PHASE,                 PROCESS_STATUS,
        ORGANIZATION_ID,               WIP_ENTITY_ID,
        ACCT_PERIOD_ID,                TRANSACTION_TYPE,
        TRANSACTION_DATE,              GROUP_ID,
        LINE_ID)
    SELECT
        wip_transactions_s.nextval,     SYSDATE,
        i_user_id,                      SYSDATE,
        i_user_id,                      i_login_id,
        2,                              2,
        i_org_id,                       wri.wip_entity_id,
        i_close_period_id,              5,
        oa.schedule_close_date,        l_group_id,
        wri.line_id
    FROM wip_repetitive_items wri,
         org_acct_periods oa
    WHERE oa.organization_id = i_org_id
    AND   oa.acct_period_id = i_close_period_id
    AND  (wri.wip_entity_id, wri.line_id) IN
        (SELECT s.wip_entity_id, s.line_id
         FROM wip_period_balances b,
              wip_repetitive_schedules s,
              org_acct_periods a
         WHERE b.acct_period_id = i_close_period_id
              /* only if the schedule has a balance row in this period */
         AND   b.organization_id = i_org_id
         AND   b.class_type = 2
         AND   b.wip_entity_id = s.wip_entity_id
         AND   b.repetitive_schedule_id = s.repetitive_schedule_id
         AND   a.organization_id =i_org_id
         AND   a.acct_period_id = i_close_period_id
         AND   (   (l_repe_var_type = 1)
                 OR
                   (l_repe_var_type = 2
                    AND s.status_type IN (5, 7)
                    AND s.date_closed BETWEEN a.period_start_date
                                      AND a.schedule_close_date+.99999)
               )
        );

/* Bug number 11660202. In the above sql +.99999 is added to inculde the jobs closed in the last day of
 the period */
    IF SQL%ROWCOUNT > 0  THEN

       /***************************************************************
        * Insert header rows for each schedule in to allocation
        **************************************************************/
        where_num := 210;
        INSERT INTO wip_txn_allocations
            (transaction_id,                 repetitive_schedule_id,
             organization_id,                last_update_date,
             last_updated_by,                creation_date,
             created_by,                     last_update_login,
             transaction_quantity,           primary_quantity)
          SELECT i.transaction_id,
                b.repetitive_schedule_id,
                b.organization_id,
                SYSDATE, i_user_id, SYSDATE, i_user_id, i_login_id,
                0, 0
          FROM wip_cost_txn_interface i,
               wip_period_balances b,
               wip_repetitive_schedules s,
               org_acct_periods a
          WHERE i.group_id = l_group_id
          AND   i.line_id IS NOT NULL
	  AND   S.WIP_ENTITY_ID = I.WIP_ENTITY_ID
          AND   s.line_id = i.line_id
          AND   i.wip_entity_id = b.wip_entity_id
          AND   i.acct_period_id = b.acct_period_id
          AND   a.organization_id = i_org_id
          AND   a.acct_period_id = i_close_period_id
               /* only if the schedule exists in this period */
          AND   b.class_type = 2
          AND   b.repetitive_schedule_id = s.repetitive_schedule_id
          AND   (    (l_repe_var_type = 1)
                  OR
                     (l_repe_var_type = 2
                      AND s.status_type IN (5, 7)
                      AND s.date_closed BETWEEN a.period_start_date
                                        AND a.schedule_close_date+.99999)
                )
          AND   s.organization_id = i_org_id;
/* Bug number 11660202. In the above sql +.99999 is added to inculde the jobs closed in the last day of
 the period */

       /***************************************************************
        * Elemental variance for wip valuation for schedules
        **************************************************************/
        where_num := 220;
        INSERT INTO wip_transaction_accounts
          (TRANSACTION_ID,            REFERENCE_ACCOUNT,
          LAST_UPDATE_DATE,           LAST_UPDATED_BY,
          CREATION_DATE,              CREATED_BY,
          LAST_UPDATE_LOGIN,          ORGANIZATION_ID,
          TRANSACTION_DATE,           WIP_ENTITY_ID,
          REPETITIVE_SCHEDULE_ID,     ACCOUNTING_LINE_TYPE,
          TRANSACTION_VALUE,          BASE_TRANSACTION_VALUE,
          CONTRA_SET_ID,              COST_ELEMENT_ID)
        SELECT
          wcti.transaction_id,
          decode(cce.cost_element_id,
                1, wrs.material_account,
                2, wrs.material_overhead_account,
                3, wrs.resource_account,
                4, wrs.outside_processing_account,
                5, wrs.overhead_account),
          SYSDATE, i_user_id, SYSDATE, i_user_id, i_login_id,
          wpb.organization_id,
          wcti.transaction_date,
          wpb.wip_entity_id,
          wpb.repetitive_schedule_id,
          7,
          NULL,
          SUM(decode(cce.cost_element_id,
            1, ( NVL(wpb.pl_material_out, 0)
                -NVL(wpb.pl_material_in, 0)
                +NVL(wpb.pl_material_var, 0)
                +NVL(wpb.tl_material_out, 0)
                -0
                +NVL(wpb.tl_material_var, 0)),
            2, ( NVL(wpb.pl_material_overhead_out, 0)
                -NVL(wpb.pl_material_overhead_in, 0)
                +NVL(wpb.pl_material_overhead_var, 0)
                +NVL(wpb.tl_material_overhead_out,0)
                -0
                +NVL(wpb.tl_material_overhead_var, 0)),
            3, ( NVL(wpb.pl_resource_out, 0)
                -NVL(wpb.pl_resource_in, 0)
                +NVL(wpb.pl_resource_var, 0)
                +NVL(wpb.tl_resource_out, 0)
                -NVL(wpb.tl_resource_in, 0)
                +NVL(wpb.tl_resource_var, 0)),
            4, ( NVL(wpb.pl_outside_processing_out, 0)
                -NVL(wpb.pl_outside_processing_in, 0)
                +NVL(wpb.pl_outside_processing_var, 0)
                +NVL(wpb.tl_outside_processing_out, 0)
                -NVL(wpb.tl_outside_processing_in, 0)
                +NVL(wpb.tl_outside_processing_var, 0)),
            5, ( NVL(wpb.pl_overhead_out, 0)
                -NVL(wpb.pl_overhead_in, 0)
                +NVL(wpb.pl_overhead_var, 0)
                +NVL(wpb.tl_overhead_out, 0)
                -NVL(wpb.tl_overhead_in, 0)
                +NVL(wpb.tl_overhead_var, 0)))),
          wpb.repetitive_schedule_id,
          DECODE((max(cce.cost_element_id) - min(cce.cost_element_id)),
            0, max(cce.cost_element_id), NULL)
        from
          wip_cost_txn_interface wcti,
          wip_txn_allocations alloc,
          wip_period_balances wpb,
          cst_cost_elements cce,
          wip_repetitive_schedules wrs
        WHERE  wcti.group_id = l_group_id
        AND    wcti.line_id IS NOT NULL
	AND    WRS.WIP_ENTITY_ID = WCTI.WIP_ENTITY_ID
        AND    wrs.line_id = wcti.line_id
        AND    wcti.transaction_id = alloc.transaction_id
        AND    wcti.organization_id = alloc.organization_id
        AND    wcti.wip_entity_id = wpb.wip_entity_id
        AND    wcti.acct_period_id >= wpb.acct_period_id
               /* need to sum up across all prior acct periods */
        AND    alloc.repetitive_schedule_id = wpb.repetitive_schedule_id
        and    alloc.repetitive_schedule_id = wrs.repetitive_schedule_id
        AND    wrs.organization_id = alloc.organization_id
        group by
           wcti.transaction_id, wcti.wip_entity_id, wcti.organization_id,
           wpb.organization_id, wcti.transaction_date, wcti.line_id,
           wpb.class_type, wpb.wip_entity_id,
           wpb.repetitive_schedule_id,
           decode(cce.cost_element_id,
                1, wrs.material_account,
                2, wrs.material_overhead_account,
                3, wrs.resource_account,
                4, wrs.outside_processing_account,
                5, wrs.overhead_account);

       /***************************************************************
        * Single level variance to variance account for schedules
        **************************************************************/
        where_num := 240;
        INSERT INTO wip_transaction_accounts
           (TRANSACTION_ID,            REFERENCE_ACCOUNT,
           LAST_UPDATE_DATE,           LAST_UPDATED_BY,
           CREATION_DATE,              CREATED_BY,
           LAST_UPDATE_LOGIN,          ORGANIZATION_ID,
           TRANSACTION_DATE,           WIP_ENTITY_ID,
           REPETITIVE_SCHEDULE_ID,     ACCOUNTING_LINE_TYPE,
           TRANSACTION_VALUE,          BASE_TRANSACTION_VALUE,
           CONTRA_SET_ID,              COST_ELEMENT_ID )
        SELECT
           wcti.transaction_id,
           decode(cce.cost_element_id,
                1, wrs.material_variance_account,
                3, wrs.resource_variance_account,
                4, wrs.outside_proc_variance_account,
                5, wrs.overhead_variance_account),
           SYSDATE, i_user_id, SYSDATE, i_user_id, i_login_id,
           wpb.organization_id,
           wcti.transaction_date,
           wpb.wip_entity_id,
           wpb.repetitive_schedule_id,
           8,
           NULL,
           SUM(decode(cce.cost_element_id,
            1, -1 * (NVL(wpb.pl_material_out,0)
                    - NVL(wpb.pl_material_in,0)
                    + NVL(wpb.pl_material_var,0)
                    + NVL(wpb.pl_material_overhead_out,0)
                    - NVL(wpb.pl_material_overhead_in,0)
                    + NVL(wpb.pl_material_overhead_var,0)
                    + NVL(wpb.pl_resource_out,0)
                    - NVL(wpb.pl_resource_in,0)
                    + NVL(wpb.pl_resource_var,0)
                    + NVL(wpb.pl_outside_processing_out,0)
                    - NVL(wpb.pl_outside_processing_in,0)
                    + NVL(wpb.pl_outside_processing_var,0)
                    + NVL(wpb.pl_overhead_out,0)
                    - NVL(wpb.pl_overhead_in,0)
                    + NVL(wpb.pl_overhead_var,0)
                    + NVL(wpb.tl_material_out,0)
                    - 0
                    + NVL(wpb.tl_material_var,0)
                    + NVL(wpb.tl_material_overhead_out,0)
                    - 0
                    + NVL(wpb.tl_material_overhead_var,0)
                    ),
            3, -1 * (NVL(wpb.tl_resource_out,0)
                    - NVL(wpb.tl_resource_in,0)
                    + NVL(wpb.tl_resource_var,0)),
            4, -1 * (NVL(wpb.tl_outside_processing_out,0)
                    - NVL(wpb.tl_outside_processing_in,0)
                    + NVL(wpb.tl_outside_processing_var,0)),
            5, -1 * (NVL(wpb.tl_overhead_out,0)
                    - NVL(wpb.tl_overhead_in,0)
                    + NVL(wpb.tl_overhead_var,0)))),
           wpb.repetitive_schedule_id,
           DECODE((max(cce.cost_element_id) - min(cce.cost_element_id)),
             0, max(cce.cost_element_id), NULL)
        from
           wip_cost_txn_interface wcti,
           wip_txn_allocations alloc,
           wip_period_balances wpb,
           cst_cost_elements cce,
           wip_repetitive_schedules wrs
        WHERE  wcti.group_id = l_group_id
        AND    wcti.line_id IS NOT NULL
	AND    WRS.WIP_ENTITY_ID = WCTI.WIP_ENTITY_ID
        AND    wrs.line_id = wcti.line_id
        AND    wcti.transaction_id = alloc.transaction_id
        AND    wcti.organization_id = alloc.organization_id
        AND    wcti.wip_entity_id = wpb.wip_entity_id
        AND    wcti.acct_period_id >= wpb.acct_period_id
              /* need to sum up across all prior acct periods */
        AND    alloc.repetitive_schedule_id = wpb.repetitive_schedule_id
        and    alloc.repetitive_schedule_id = wrs.repetitive_schedule_id
        AND    wrs.organization_id = alloc.organization_id
        AND    cce.cost_element_id <> 2
        group by
           wcti.transaction_id, wcti.wip_entity_id, wcti.organization_id,
           wpb.organization_id, wcti.transaction_date, wcti.line_id,
           wpb.class_type, wpb.wip_entity_id,
           wpb.repetitive_schedule_id,
           decode(cce.cost_element_id,
                1, wrs.material_variance_account,
                3, wrs.resource_variance_account,
                4, wrs.outside_proc_variance_account,
                5, wrs.overhead_variance_account);

       /*--------------------------------------------------------------------+
        | Update variance columns for schedules
        +---------------------------------------------------------------*/
        where_num := 260;
        UPDATE WIP_PERIOD_BALANCES wpb
        SET (LAST_UPDATED_BY,  LAST_UPDATE_DATE,  LAST_UPDATE_LOGIN,
         PL_MATERIAL_VAR,  PL_MATERIAL_OVERHEAD_VAR,
         PL_RESOURCE_VAR,  PL_OUTSIDE_PROCESSING_VAR,
         PL_OVERHEAD_VAR,  TL_MATERIAL_VAR,
         TL_MATERIAL_OVERHEAD_VAR, TL_RESOURCE_VAR,
         TL_OUTSIDE_PROCESSING_VAR, TL_OVERHEAD_VAR ) =
        (SELECT i_user_id,  SYSDATE, i_login_id,
            SUM(  NVL(PL_MATERIAL_IN,0)
                - NVL(PL_MATERIAL_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(PL_MATERIAL_VAR,0))),
            SUM(  NVL(PL_MATERIAL_OVERHEAD_IN,0)
                - NVL(PL_MATERIAL_OVERHEAD_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(PL_MATERIAL_OVERHEAD_VAR,0))),
            SUM(  NVL(PL_RESOURCE_IN,0)
                - NVL(PL_RESOURCE_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(PL_RESOURCE_VAR,0))),
            SUM(  NVL(PL_OUTSIDE_PROCESSING_IN,0)
                - NVL(PL_OUTSIDE_PROCESSING_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(PL_OUTSIDE_PROCESSING_VAR,0))),
            SUM(  NVL(PL_OVERHEAD_IN,0)
                - NVL(PL_OVERHEAD_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(PL_OVERHEAD_VAR,0))),
            SUM(  0
                - NVL(TL_MATERIAL_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(TL_MATERIAL_VAR,0))),
            SUM(  0
                - NVL(TL_MATERIAL_OVERHEAD_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(TL_MATERIAL_OVERHEAD_VAR,0))),
            SUM(  NVL(TL_RESOURCE_IN,0)
                - NVL(TL_RESOURCE_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(TL_RESOURCE_VAR,0))),
            SUM(  NVL(TL_OUTSIDE_PROCESSING_IN,0)
                - NVL(TL_OUTSIDE_PROCESSING_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(TL_OUTSIDE_PROCESSING_VAR,0))),
            SUM(  NVL(TL_OVERHEAD_IN,0)
                - NVL(TL_OVERHEAD_OUT,0)
                -  decode(acct_period_id,i_close_period_id,0,NVL(TL_OVERHEAD_VAR,0)))
         FROM  WIP_PERIOD_BALANCES wpb2
         WHERE wpb2.wip_entity_id = wpb.wip_entity_id
         AND   wpb2.acct_period_id <= wpb.acct_period_id
               /* sum across all acct periods */
         AND   wpb2.organization_id = wpb.organization_id
         AND   wpb2.repetitive_schedule_id = wpb.repetitive_schedule_id)
        WHERE wpb.acct_period_id = i_close_period_id
        AND   wpb.organization_id = i_org_id
        AND   (wpb.wip_entity_id,    wpb.repetitive_schedule_id) IN
             (SELECT i.wip_entity_id,
                     alloc.repetitive_schedule_id
              FROM WIP_COST_TXN_INTERFACE i,
                   WIP_TXN_ALLOCATIONS alloc
               WHERE i.group_id = l_group_id
               AND   i.transaction_id = alloc.transaction_id
               AND   i.line_id IS NOT NULL);

    END IF; /* end of schedules */

    /***************************************************************
     * Delete any 0 value accounting rows
     * Note :
     *  has to use cursor because of the PL/SQL limitation on rowid
     **************************************************************/

     where_num := 550;
     OPEN c1;
     LOOP
       FETCH c1 into my_rowid;
       EXIT WHEN c1%NOTFOUND;
       DELETE FROM WIP_TRANSACTION_ACCOUNTS
       WHERE  ROWID = my_rowid;
     END LOOP;
     CLOSE c1;


    where_num := 560;

    /* Update WTA with WIP_SUB_LEDGER_ID */
    UPDATE WIP_TRANSACTION_ACCOUNTS
    SET    WIP_SUB_LEDGER_ID = CST_WIP_SUB_LEDGER_ID_S.NEXTVAL
    WHERE  TRANSACTION_ID    IN
           ( SELECT TRANSACTION_ID
             FROM WIP_COST_TXN_INTERFACE
             WHERE GROUP_ID        = l_group_id
             AND   ORGANIZATION_ID = i_org_id );


   where_num := 570;

    /* Create the Events for the transactions in the WCTI group */

    CST_XLA_PVT.CreateBulk_WIPXLAEvent(
      p_api_version      => 1.0,
      p_init_msg_list    => FND_API.G_FALSE,
      p_commit           => FND_API.G_FALSE,
      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
      x_return_status    => l_return_status,
      x_msg_count        => l_msg_count,
      x_msg_data         => l_msg_data,
      p_wcti_group_id    => l_group_id,
      p_organization_id  => i_org_id );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;



    /***************************************************************
     * Delete any balance rows for schedule beyond the cancel or
     * completion date
     **************************************************************/
     where_num := 600;

     DELETE FROM wip_period_balances wpb
     WHERE  wpb.acct_period_id > i_close_period_id
     AND    wpb.organization_id = i_org_id
     AND   (wpb.wip_entity_id, wpb.repetitive_schedule_id) IN
                 (SELECT i.wip_entity_id,
                         alloc.repetitive_schedule_id
                  FROM WIP_COST_TXN_INTERFACE i,
                       WIP_TXN_ALLOCATIONS alloc,
                       WIP_REPETITIVE_SCHEDULES s,
                       ORG_ACCT_PERIODS oap
                  WHERE i.group_id = l_group_id
                  AND   i.line_id IS NOT NULL
                  AND   i.transaction_id = alloc.transaction_id
                  AND   alloc.repetitive_schedule_id = s.repetitive_schedule_id
                  AND   s.organization_id = i_org_id
                  AND   oap.acct_period_id = i_close_period_id
                --AND   s.date_closed IS NOT NULL)
                  AND   s.date_closed between oap.period_start_date and
                        oap.schedule_close_date
                  AND   oap.organization_id = i_org_id)
       ;

    /*---------------------------------------------------------------+
     | Copy rows from wip_cost_txn_interface to wip_transactions
     | and delete from wip_cost_txn_interface
     +---------------------------------------------------------------*/
     l_status := CSTPWCPX.CMLCPX(l_group_id,i_org_id,5,i_user_id,i_login_id,-1,-1,-1,err_buf);
     IF l_status <> 0 THEN
        RAISE cmlcpx_status;
     END IF;

     RETURN(0);

EXCEPTION
    WHEN cmlcpx_status THEN
        ROLLBACK;
        RETURN(l_status);

    WHEN realloc_failed THEN
        ROLLBACK;
        err_buf := 'CSTPWPVR: Failed to redistribute Asset Route';
        RETURN(l_status);

    WHEN OTHERS THEN
        ROLLBACK;
        err_buf := 'CSTPWPVR:' || to_char(where_num) || substr(SQLERRM,1,150);
        RETURN(SQLCODE);

END REPVAR;

END CSTPWPVR; /* end package body */

/
