--------------------------------------------------------
--  DDL for Package Body CSTPCFMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPCFMS" AS
/* $Header: CSTCFMSB.pls 120.1.12010000.2 2008/10/27 21:45:33 hyu ship $ */

G_DEBUG        CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

PROCEDURE debug
( line       IN VARCHAR2,
  msg_prefix IN VARCHAR2  DEFAULT 'CST',
  msg_module IN VARCHAR2  DEFAULT 'CSTPCFMS',
  msg_level  IN NUMBER    DEFAULT FND_LOG.LEVEL_STATEMENT)
IS
  l_msg_prefix     VARCHAR2(64);
  l_msg_level      NUMBER;
  l_msg_module     VARCHAR2(256);
  l_beg_end_suffix VARCHAR2(15);
  l_org_cnt        NUMBER;
  l_line           VARCHAR2(32767);
BEGIN
    l_line       := line;
    l_msg_prefix := msg_prefix;
    l_msg_level  := msg_level;
    l_msg_module := msg_module;
    IF (INSTRB(upper(l_line), 'EXCEPTION') <> 0) THEN
      l_msg_level  := FND_LOG.LEVEL_EXCEPTION;
    END IF;
    IF l_msg_level <> FND_LOG.LEVEL_EXCEPTION AND G_DEBUG = 'N' THEN
      RETURN;
    END IF;
    IF ( l_msg_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(l_msg_level, l_msg_module, SUBSTRB(l_line,1,4000));
    END IF;
EXCEPTION
   WHEN OTHERS THEN RAISE;
END debug;



FUNCTION wip_cfm_cbr (
    i_org_id               NUMBER,
    i_user_id              NUMBER,
    i_login_id             NUMBER,
    i_acct_period_id       NUMBER,
    i_wip_entity_id        NUMBER,
    err_buf           OUT NOCOPY  VARCHAR2)
RETURN INTEGER
IS
    where_num              NUMBER;
BEGIN
    err_buf   := ' ';

    debug('wip_cfm_cbr+');

    /*----------------------------------------------------------+
    | Process CFM                                               |
    |                                                           |
    | Create a new row in WIP_PERIOD_BALANCES                   |
    | if the row does not exist for a certain acct_period_id,   |
    | wip_entity_id, org_id.                                    |
    | Also, create new rows in WIP_PERIOD_BALANCES              |
    | for other accounting periods that has not been created    |
    | yet for a certain wip_entity_id and org_id.               |
    +-----------------------------------------------------------*/
    where_num := 100;

    debug(where_num);

    INSERT INTO wip_period_balances
        (acct_period_id, wip_entity_id,
        repetitive_schedule_id, last_update_date,
        last_updated_by, creation_date,
        created_by, last_update_login,
        organization_id, class_type,
        tl_resource_in,  tl_overhead_in,           tl_outside_processing_in,
        pl_material_in,  pl_material_overhead_in,  pl_resource_in,  pl_overhead_in,  pl_outside_processing_in,
        tl_material_out, tl_material_overhead_out, tl_resource_out, tl_overhead_out, tl_outside_processing_out,
        pl_material_out, pl_material_overhead_out, pl_resource_out, pl_overhead_out, pl_outside_processing_out,
  pl_material_var, pl_material_overhead_var, pl_resource_var, pl_outside_processing_var,pl_overhead_var,
 tl_material_var, tl_material_overhead_var, tl_resource_var, tl_outside_processing_var,tl_overhead_var)
    SELECT
        oap.acct_period_id, i_wip_entity_id,
        NULL, SYSDATE,
        i_user_id, SYSDATE,
        i_user_id, i_login_id,
        i_org_id, wac.class_type,
        0,0,0,
	0,0,0,0,0,
	0,0,0,0,0,
	0,0,0,0,0,
	0,0,0,0,0,
	0,0,0,0,0
    FROM wip_flow_schedules wcs,
         wip_accounting_classes wac,
         org_acct_periods oap
    WHERE
          wcs.organization_id  = i_org_id
    AND   wcs.wip_entity_id    = i_wip_entity_id
    AND   wac.class_code       = wcs.class_code
    AND   wac.organization_id  = i_org_id
    AND   oap.acct_period_id   >= i_acct_period_id
    AND   oap.organization_id  = i_org_id
    AND   oap.acct_period_id   >
          (SELECT nvl(max(acct_period_id),0)
           FROM   wip_period_balances
           WHERE  organization_id = i_org_id
           AND    wip_entity_id   = i_wip_entity_id)
    AND   NOT EXISTS
          (SELECT 'x' FROM wip_period_balances
           WHERE organization_id = i_org_id
           AND   acct_period_id  = i_acct_period_id
           AND   wip_entity_id   = i_wip_entity_id);

   debug('wip_cfm_cbr-');
   RETURN(0); /* No error */

EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK;
       debug('CSTPCFMS:WIP_CFM_CBR:' || to_char(where_num) || substr(SQLERRM,1,150));
       err_buf := 'CSTPCFMS:WIP_CFM_CBR' || to_char(where_num) || substr(SQLERRM,1,150);
       RETURN(SQLCODE);
END wip_cfm_cbr;

/************************************************
 Completion for CFM
************************************************/
PROCEDURE wip_cfm_complete (
    i_trx_id               IN      NUMBER,
    i_org_id               IN      NUMBER,
    i_inv_item_id          IN      NUMBER,
    i_txn_qty              IN      NUMBER,
    i_wip_entity_id        IN      NUMBER,
    i_txn_src_type_id      IN      NUMBER,
    i_flow_schedule        IN      NUMBER,
    i_txn_action_id        IN      NUMBER,
    i_user_id              IN      NUMBER,
    i_login_id             IN      NUMBER,
    i_request_id           IN      NUMBER,
    i_prog_appl_id         IN      NUMBER,
    i_prog_id              IN      NUMBER,
    err_num                OUT NOCOPY     NUMBER,
    err_code               OUT NOCOPY     VARCHAR2,
    err_msg                OUT NOCOPY     VARCHAR2)
IS
    stmt_num                       NUMBER;
BEGIN

    debug('wip_cfm_complete+');

    -- initialize variables
    err_num   := 0;
    err_code  := ' ';
    err_msg   := ' ';


   /*-------------------------------
    Make sure it is a CFM completion
    --------------------------------*/

  --
  -- call by cfm scrap also
  --

   IF (i_txn_src_type_id = 5
       AND i_flow_schedule = 1
       AND (i_txn_action_id = 31 OR (i_txn_action_id = 30 AND i_txn_qty>0))) THEN

        stmt_num := 10;
        debug(stmt_num);
        INSERT INTO mtl_cst_txn_cost_details
          (
           transaction_id,
           organization_id,
           inventory_item_id,
           cost_element_id,
           level_type,
           transaction_cost,
           new_average_cost,
           percentage_change,
           value_change,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date)
        SELECT
           i_trx_id,
           i_org_id,
           i_inv_item_id,
           cce.cost_element_id,
           1,
           decode(cce.cost_element_id,
               1,sum(0                               - nvl(tl_material_out,0)),
               2,sum(0                               - nvl(tl_material_overhead_out,0)),
               3,sum(nvl(tl_resource_in,0)           - nvl(tl_resource_out,0)),
               4,sum(nvl(tl_outside_processing_in,0) - nvl(tl_outside_processing_out,0)),
               5,sum(nvl(tl_overhead_in,0)           - nvl(tl_overhead_out,0)))/ABS(i_txn_qty),
           NULL,
           NULL,
           NULL,
           SYSDATE,
           i_user_id,
           SYSDATE,
           i_user_id,
           i_login_id,
           i_request_id,
           i_prog_appl_id,
           i_prog_id,
           SYSDATE
        FROM
           cst_cost_elements   cce,
           wip_period_balances wpb
       WHERE
           wpb.wip_entity_id    =  i_wip_entity_id AND
           wpb.organization_id  =  i_org_id        AND
           cce.cost_element_id  <> 2
        GROUP BY
           cce.cost_element_id
        HAVING
           decode(cce.cost_element_id,
               1,sum(0                               - nvl(tl_material_out,0)),
               2,sum(0                               - nvl(tl_material_overhead_out,0)),
               3,sum(nvl(tl_resource_in,0)           - nvl(tl_resource_out,0)),
               4,sum(nvl(tl_outside_processing_in,0) - nvl(tl_outside_processing_out,0)),
               5,sum(nvl(tl_overhead_in,0)           - nvl(tl_overhead_out,0))) > 0;

        stmt_num := 20;
        debug(stmt_num);
        INSERT INTO mtl_cst_txn_cost_details
        (
           transaction_id,
           organization_id,
           inventory_item_id,
           cost_element_id,
           level_type,
           transaction_cost,
           new_average_cost,
           percentage_change,
           value_change,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date)
        SELECT
           i_trx_id,
           i_org_id,
           i_inv_item_id,
           cce.cost_element_id,
           2,
           decode(cce.cost_element_id,
               1,sum(nvl(pl_material_in,0)          - nvl(pl_material_out,0)),
               2,sum(nvl(pl_material_overhead_in,0) - nvl(pl_material_overhead_out,0)),
               3,sum(nvl(pl_resource_in,0)          - nvl(pl_resource_out,0)),
               4,sum(nvl(pl_outside_processing_in,0)- nvl(pl_outside_processing_out,0)),
               5,sum(nvl(pl_overhead_in,0)          - nvl(pl_overhead_out,0)))/ABS(i_txn_qty),
          NULL,
          NULL,
          NULL,
          SYSDATE,
          i_user_id,
          SYSDATE,
          i_user_id,
          i_login_id,
          i_request_id,
          i_prog_appl_id,
          i_prog_id,
          SYSDATE
        FROM
           cst_cost_elements cce,
           wip_period_balances wpb
        WHERE
           wpb.wip_entity_id    = i_wip_entity_id AND
           wpb.organization_id  = i_org_id
        GROUP BY
           cce.cost_element_id
        HAVING
           decode(cce.cost_element_id,
               1,sum(nvl(pl_material_in,0)          - nvl(pl_material_out,0)),
               2,sum(nvl(pl_material_overhead_in,0) - nvl(pl_material_overhead_out,0)),
               3,sum(nvl(pl_resource_in,0)          - nvl(pl_resource_out,0)),
               4,sum(nvl(pl_outside_processing_in,0)- nvl(pl_outside_processing_out,0)),
               5,sum(nvl(pl_overhead_in,0)          - nvl(pl_overhead_out,0))) > 0;

       IF (i_txn_action_id = 30 AND i_txn_qty>0) THEN
       debug('25');

       INSERT INTO WIP_SCRAP_VALUES
        (
         transaction_id,
         level_type,
         cost_element_id,
         cost_update_id,
         last_update_date,
         last_updated_by,
         created_by,
         creation_date,
         last_update_login,
         cost_element_value,
         request_id,
         program_application_id,
         program_id,
         program_update_date
        )
        SELECT
        i_trx_id,
        level_type,
        cost_element_id,
        NULL,
        SYSDATE,
        i_user_id,
        i_user_id,
        SYSDATE,
        i_login_id,
	transaction_cost,
        i_request_id,
        i_prog_appl_id,
        i_prog_id,
        SYSDATE
        FROM
	mtl_cst_txn_cost_details
	WHERE
	transaction_id = i_trx_id;
      END IF;
END IF;
debug('wip_cfm_complete-');

EXCEPTION
   WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := 'CSTPCFMS:' || 'wip_cfm_complete:' || to_char(stmt_num) ||
                 ' ' || substr(SQLERRM,1,150);
      debug(err_msg);
END wip_cfm_complete;


/************************************************
 Assembly Return for CFM
************************************************/

PROCEDURE wip_cfm_assy_return (
    i_trx_id               IN      NUMBER,
    i_org_id               IN      NUMBER,
    i_inv_item_id          IN      NUMBER,
    i_txn_qty              IN      NUMBER,
    i_wip_entity_id        IN      NUMBER,
    i_txn_src_type_id      IN      NUMBER,
    i_flow_schedule        IN      NUMBER,
    i_txn_action_id        IN      NUMBER,
    i_user_id              IN      NUMBER,
    i_login_id             IN      NUMBER,
    i_request_id           IN      NUMBER,
    i_prog_appl_id         IN      NUMBER,
    i_prog_id              IN      NUMBER,
    err_num                OUT NOCOPY     NUMBER,
    err_code               OUT NOCOPY     VARCHAR2,
    err_msg                OUT NOCOPY     VARCHAR2)
IS
 stmt_num                       NUMBER;
BEGIN

    debug('wip_cfm_assy_return +');

    -- initialize variables
    err_num   := 0;
    err_code  := ' ';
    err_msg   := ' ';


   /*-----------------------------------
   Make sure it is a CFM assembly return
   -------------------------------------*/

  --
  -- call by cfm scrap return also
  --
  IF (i_txn_src_type_id = 5
       AND i_flow_schedule = 1
       AND (i_txn_action_id = 32 OR (i_txn_action_id = 30 AND i_txn_qty<0))) THEN

        stmt_num := 10;

        debug(stmt_num);

        INSERT INTO mtl_cst_txn_cost_details
          (
           transaction_id,
           organization_id,
           inventory_item_id,
           cost_element_id,
           level_type,
           transaction_cost,
           new_average_cost,
           percentage_change,
           value_change,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date)
        SELECT
           i_trx_id,
           i_org_id,
           i_inv_item_id,
           cce.cost_element_id,
           1,
           decode(cce.cost_element_id,
               1,sum(nvl(tl_material_out,0)          - 0),
               2,sum(nvl(tl_material_overhead_out,0) - 0),
               3,sum(nvl(tl_resource_out,0)          - nvl(tl_resource_in,0)),
               4,sum(nvl(tl_outside_processing_out,0)- nvl(tl_outside_processing_in,0)),
               5,sum(nvl(tl_overhead_out,0)          - nvl(tl_overhead_in,0)))/ABS(i_txn_qty),
           NULL,
           NULL,
           NULL,
           SYSDATE,
           i_user_id,
           SYSDATE,
           i_user_id,
           i_login_id,
           i_request_id,
           i_prog_appl_id,
           i_prog_id,
           SYSDATE
        FROM
           cst_cost_elements   cce,
           wip_period_balances wpb
       WHERE
           wpb.wip_entity_id    =  i_wip_entity_id AND
           wpb.organization_id  =  i_org_id        AND
           cce.cost_element_id  <> 2
        GROUP BY
           cce.cost_element_id
        HAVING
           decode(cce.cost_element_id,
               1,sum(nvl(tl_material_out,0)          - 0),
               2,sum(nvl(tl_material_overhead_out,0) - 0),
               3,sum(nvl(tl_resource_out,0)          - nvl(tl_resource_in,0)),
               4,sum(nvl(tl_outside_processing_out,0)- nvl(tl_outside_processing_in,0)),
               5,sum(nvl(tl_overhead_out,0)          - nvl(tl_overhead_in,0))) > 0;

        stmt_num := 20;
        debug(stmt_num);
        INSERT INTO mtl_cst_txn_cost_details
        (
           transaction_id,
           organization_id,
           inventory_item_id,
           cost_element_id,
           level_type,
           transaction_cost,
           new_average_cost,
           percentage_change,
           value_change,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date)
        SELECT
           i_trx_id,
           i_org_id,
           i_inv_item_id,
           cce.cost_element_id,
           2,
           decode(cce.cost_element_id,
               1,sum(nvl(pl_material_out,0)          - nvl(pl_material_in,0)),
               2,sum(nvl(pl_material_overhead_out,0) - nvl(pl_material_overhead_in,0)),
               3,sum(nvl(pl_resource_out,0)          - nvl(pl_resource_in,0)),
               4,sum(nvl(pl_outside_processing_out,0)- nvl(pl_outside_processing_in,0)),
               5,sum(nvl(pl_overhead_out,0)          - nvl(pl_overhead_in,0)))/ABS(i_txn_qty),
          NULL,
          NULL,
          NULL,
          SYSDATE,
          i_user_id,
          SYSDATE,
          i_user_id,
          i_login_id,
          i_request_id,
          i_prog_appl_id,
          i_prog_id,
          SYSDATE
        FROM
           cst_cost_elements cce,
           wip_period_balances wpb
        WHERE
           wpb.wip_entity_id    = i_wip_entity_id AND
           wpb.organization_id  = i_org_id
        GROUP BY
           cce.cost_element_id
        HAVING
           decode(cce.cost_element_id,
               1,sum(nvl(pl_material_out,0)          - nvl(pl_material_in,0)),
               2,sum(nvl(pl_material_overhead_out,0) - nvl(pl_material_overhead_in,0)),
               3,sum(nvl(pl_resource_out,0)          - nvl(pl_resource_in,0)),
               4,sum(nvl(pl_outside_processing_out,0)- nvl(pl_outside_processing_in,0)),
               5,sum(nvl(pl_overhead_out,0)          - nvl(pl_overhead_in,0))) > 0;

       IF (i_txn_action_id = 30 AND i_txn_qty<0) THEN
       debug('25');
       INSERT INTO WIP_SCRAP_VALUES
        (
         transaction_id,
         level_type,
         cost_element_id,
         cost_update_id,
         last_update_date,
         last_updated_by,
         created_by,
         creation_date,
         last_update_login,
         cost_element_value,
         request_id,
         program_application_id,
         program_id,
         program_update_date
        )
        SELECT
        i_trx_id,
        level_type,
        cost_element_id,
        NULL,
        SYSDATE,
        i_user_id,
        i_user_id,
        SYSDATE,
        i_login_id,
	transaction_cost,
        i_request_id,
        i_prog_appl_id,
        i_prog_id,
        SYSDATE
        FROM
	mtl_cst_txn_cost_details
	WHERE
	transaction_id = i_trx_id;
      END IF;

END IF;
debug('wip_cfm_assy_return-');

EXCEPTION
   WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := 'CSTPCFMS:' || 'wip_cfm_assy_return:' || to_char(stmt_num) ||
                 ' ' || substr(SQLERRM,1,150);
      debug(err_msg);
END wip_cfm_assy_return;

PROCEDURE wip_cfm_var_relief (
    i_wip_entity_id     IN      NUMBER,
    i_txn_action_id     IN      NUMBER,
    i_acct_period_id    IN      NUMBER,
    i_org_id            IN      NUMBER,
    i_txn_date          IN      DATE,
    i_user_id           IN      NUMBER,
    i_login_id          IN      NUMBER,
    i_request_id        IN      NUMBER,
    i_prog_id           IN      NUMBER,
    i_prog_appl_id      IN      NUMBER,
    err_num             OUT NOCOPY     NUMBER,
    err_code            OUT NOCOPY     VARCHAR2,
    err_msg             OUT NOCOPY     VARCHAR2)
IS

	stmt_num		NUMBER;
	l_rowcount		NUMBER;
	l_txn_id		NUMBER;
	no_wpb_rows		EXCEPTION;

    l_trx_info         CST_XLA_PVT.t_xla_wip_trx_info;
    l_return_status    VARCHAR2(10);
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(2000);
    l_nb               NUMBER := 0;
BEGIN

       debug('wip_cfm_var_relief+');


	stmt_num := 10;

	select count(*)
	into
	l_rowcount
	from
	wip_period_balances
	where
	wip_entity_id = i_wip_entity_id and
	acct_period_id = i_acct_period_id;

	IF (l_rowcount = 0) then
	raise no_wpb_rows;
	END IF;


	-- Get the next value in the sequence to create a txn row

	stmt_num := 20;

	select wip_transactions_s.nextval
	into
	l_txn_id from dual;

 -- Insert the elemental CFM variance.

	stmt_num := 20;


    INSERT INTO wip_transaction_accounts
        (WIP_SUB_LEDGER_ID,
        TRANSACTION_ID,            REFERENCE_ACCOUNT,
        LAST_UPDATE_DATE,           LAST_UPDATED_BY,
        CREATION_DATE,              CREATED_BY,
        LAST_UPDATE_LOGIN,          ORGANIZATION_ID,
        TRANSACTION_DATE,           WIP_ENTITY_ID,
        REPETITIVE_SCHEDULE_ID,     ACCOUNTING_LINE_TYPE,
        TRANSACTION_VALUE,          BASE_TRANSACTION_VALUE,
        CONTRA_SET_ID,              PRIMARY_QUANTITY,
        RATE_OR_AMOUNT,             BASIS_TYPE,
        RESOURCE_ID,               COST_ELEMENT_ID,
        ACTIVITY_ID,                CURRENCY_CODE,
        CURRENCY_CONVERSION_DATE,   CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        REQUEST_ID,                 PROGRAM_APPLICATION_ID,
        PROGRAM_ID,                 PROGRAM_UPDATE_DATE)
   SELECT
        CST_WIP_SUB_LEDGER_ID_S.NEXTVAL,
        l_txn_id,
        decode(cce.cost_element_id,
            1, wdj.material_account,
            2, wdj.material_overhead_account,
            3, wdj.resource_account,
            4, wdj.outside_processing_account,
            5, wdj.overhead_account),
        SYSDATE,i_user_id,SYSDATE,i_user_id,i_login_id,
        i_org_id,i_txn_date,i_wip_entity_id,
        NULL,7,NULL,
	decode(cce.cost_element_id,
            1, (NVL(wpb.pl_material_out,0)
                    - NVL(wpb.pl_material_in,0)
                    + NVL(wpb.pl_material_var,0)
                    + NVL(wpb.tl_material_out,0)
                    - 0
                    + NVL(wpb.tl_material_var,0)),
            2, (NVL(wpb.pl_material_overhead_out,0)
                    - NVL(wpb.pl_material_overhead_in,0)
                    + NVL(wpb.pl_material_overhead_var,0)
                    + NVL(wpb.tl_material_overhead_out,0)
                    - 0
                    + NVL(wpb.tl_material_overhead_var,0)),
            3, (NVL(wpb.pl_resource_out,0)
                    - NVL(wpb.pl_resource_in,0)
                    + NVL(wpb.pl_resource_var,0)
                    + NVL(wpb.tl_resource_out,0)
                    - NVL(wpb.tl_resource_in,0)
                    + NVL(wpb.tl_resource_var,0)),
            4, (NVL(wpb.pl_outside_processing_out,0)
                    - NVL(wpb.pl_outside_processing_in,0)
                    + NVL(wpb.pl_outside_processing_var,0)
                    + NVL(wpb.tl_outside_processing_out,0)
                    - NVL(wpb.tl_outside_processing_in,0)
                    + NVL(wpb.tl_outside_processing_var,0)),
            5, (NVL(wpb.pl_overhead_out,0)
                    - NVL(wpb.pl_overhead_in,0)
                    + NVL(wpb.pl_overhead_var,0)
                    + NVL(wpb.tl_overhead_out,0)
                    - NVL(wpb.tl_overhead_in,0)
                    + NVL(wpb.tl_overhead_var,0))),
        i_wip_entity_id,NULL, NULL, NULL, NULL,
        cce.cost_element_id,
        NULL, NULL, NULL, NULL, NULL,
        i_request_id,i_prog_appl_id,i_prog_id,SYSDATE
	FROM
        wip_period_balances wpb,
        wip_flow_schedules  wdj,
        cst_cost_elements cce
    WHERE
	wpb.wip_entity_id = wdj.wip_entity_id			and
	wdj.wip_entity_id = i_wip_entity_id			and
        wpb.acct_period_id      =       i_acct_period_id;

 -- Inser the single level CFM variance

	stmt_num := 30;

     INSERT INTO wip_transaction_accounts
        ( WIP_SUB_LEDGER_ID,
        TRANSACTION_ID,            REFERENCE_ACCOUNT,
        LAST_UPDATE_DATE,           LAST_UPDATED_BY,
        CREATION_DATE,              CREATED_BY,
        LAST_UPDATE_LOGIN,          ORGANIZATION_ID,
        TRANSACTION_DATE,           WIP_ENTITY_ID,
        REPETITIVE_SCHEDULE_ID,     ACCOUNTING_LINE_TYPE,
        TRANSACTION_VALUE,          BASE_TRANSACTION_VALUE,
        CONTRA_SET_ID,              PRIMARY_QUANTITY,
        RATE_OR_AMOUNT,             BASIS_TYPE,
        RESOURCE_ID,               COST_ELEMENT_ID,
        ACTIVITY_ID,                CURRENCY_CODE,
        CURRENCY_CONVERSION_DATE,   CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        REQUEST_ID,                 PROGRAM_APPLICATION_ID,
        PROGRAM_ID,                 PROGRAM_UPDATE_DATE)
   SELECT
        CST_WIP_SUB_LEDGER_ID_S.NEXTVAL,
	l_txn_id,
	decode(cce.cost_element_id,
           1, wfs.material_variance_account,
           3, wfs.resource_variance_account,
           4, wfs.outside_proc_variance_account,
           5, wfs.overhead_variance_account),
	SYSDATE,i_user_id,SYSDATE,i_user_id,i_login_id,
	i_org_id,i_txn_date,i_wip_entity_id,
	NULL,8,NULL,
	decode(cce.cost_element_id,
            1, -1 * (NVL(wpb.pl_material_out,0)
                    - NVL(wpb.pl_material_in,0)
                    + NVL(wpb.pl_material_var,0)
                    + NVL(wpb.pl_material_overhead_out,0)
                    - NVL(wpb.pl_material_overhead_in,0)
                    + NVL(wpb.pl_material_overhead_var,0)
                    + NVL(wpb.pl_resource_out,0)
                    - NVL(wpb.pl_resource_in,0)
                    + NVL(wpb.pl_resource_var,0)
                    + NVL(wpb.pl_overhead_out,0)
                    - NVL(wpb.pl_overhead_in,0)
                    + NVL(wpb.pl_overhead_var,0)
                    + NVL(wpb.pl_outside_processing_out,0)
                    - NVL(wpb.pl_outside_processing_in,0)
                    + NVL(wpb.pl_outside_processing_var,0)
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
                    + NVL(wpb.tl_overhead_var,0))),
	i_wip_entity_id,NULL, NULL, NULL, NULL,
	cce.cost_element_id,
	NULL, NULL, NULL, NULL, NULL,
	i_request_id,i_prog_appl_id,i_prog_id,SYSDATE
	FROM
	   wip_period_balances wpb,
	   wip_flow_schedules wfs,
	   cst_cost_elements cce
    	WHERE
	wpb.wip_entity_id	=	wfs.wip_entity_id	and
	wpb.acct_period_id 	=	i_acct_period_id	and
	wfs.wip_entity_id	= 	i_wip_entity_id		and
	cce.cost_element_id 	<> 	2;


        l_nb := sql%rowcount;


	-- Update WPB

	stmt_num := 40;
/*Substraction By current Variance is removed for the Bug#1784535*/
    UPDATE WIP_PERIOD_BALANCES wpb
    SET (LAST_UPDATED_BY,  LAST_UPDATE_DATE,  LAST_UPDATE_LOGIN,
         PL_MATERIAL_VAR,  PL_MATERIAL_OVERHEAD_VAR,
         PL_RESOURCE_VAR,  PL_OUTSIDE_PROCESSING_VAR,
         PL_OVERHEAD_VAR,  TL_MATERIAL_VAR,
         TL_MATERIAL_OVERHEAD_VAR, TL_RESOURCE_VAR,
         TL_OUTSIDE_PROCESSING_VAR, TL_OVERHEAD_VAR ) =
        (SELECT i_user_id,  SYSDATE, i_login_id,
              NVL(PL_MATERIAL_IN,0)
                - NVL(PL_MATERIAL_OUT,0),
              NVL(PL_MATERIAL_OVERHEAD_IN,0)
                - NVL(PL_MATERIAL_OVERHEAD_OUT,0),
              NVL(PL_RESOURCE_IN,0)
                - NVL(PL_RESOURCE_OUT,0),
              NVL(PL_OUTSIDE_PROCESSING_IN,0)
                - NVL(PL_OUTSIDE_PROCESSING_OUT,0),
              NVL(PL_OVERHEAD_IN,0)
                - NVL(PL_OVERHEAD_OUT,0),
              0
                - NVL(TL_MATERIAL_OUT,0),
              0
                - NVL(TL_MATERIAL_OVERHEAD_OUT,0),
              NVL(TL_RESOURCE_IN,0)
                - NVL(TL_RESOURCE_OUT,0),
              NVL(TL_OUTSIDE_PROCESSING_IN,0)
                - NVL(TL_OUTSIDE_PROCESSING_OUT,0),
              NVL(TL_OVERHEAD_IN,0)
                - NVL(TL_OVERHEAD_OUT,0)
	        FROM WIP_PERIOD_BALANCES wpb2
        WHERE wpb2.wip_entity_id = wpb.wip_entity_id
        AND   wpb2.acct_period_id = wpb.acct_period_id)
    WHERE
	wpb.wip_entity_id 	=	i_wip_entity_id	AND
	wpb.acct_period_id	=	i_acct_period_id;


-- 	Insert a row into WIP trnsactions table.

	stmt_num := 50;

	INSERT INTO WIP_TRANSACTIONS
        (TRANSACTION_ID,                LAST_UPDATE_DATE,
        LAST_UPDATED_BY,                CREATION_DATE,
        CREATED_BY,                        LAST_UPDATE_LOGIN,
        ORGANIZATION_ID,                WIP_ENTITY_ID,
        ACCT_PERIOD_ID,                    DEPARTMENT_ID,
        TRANSACTION_TYPE,                TRANSACTION_DATE,
        LINE_ID,                        SOURCE_CODE,
        SOURCE_LINE_ID,                    OPERATION_SEQ_NUM,
        RESOURCE_SEQ_NUM,                EMPLOYEE_ID,
        RESOURCE_ID,                    AUTOCHARGE_TYPE,
        STANDARD_RATE_FLAG,                USAGE_RATE_OR_AMOUNT,
        BASIS_TYPE,                        TRANSACTION_QUANTITY,
        TRANSACTION_UOM,                PRIMARY_QUANTITY,
        PRIMARY_UOM,                    ACTUAL_RESOURCE_RATE,
        STANDARD_RESOURCE_RATE,            CURRENCY_CODE,
        CURRENCY_CONVERSION_DATE,        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,       CURRENCY_ACTUAL_RESOURCE_RATE,
        ACTIVITY_ID,                     REASON_ID,
        REFERENCE,                       MOVE_TRANSACTION_ID,
        PO_HEADER_ID,                   PO_LINE_ID,
        RCV_TRANSACTION_ID,              PRIMARY_ITEM_ID,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,
        ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,
        ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,
        ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,
        REQUEST_ID,PROGRAM_APPLICATION_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE,
        GROUP_ID,
        project_id,
        task_id,
        pm_cost_collected)
	SELECT
	l_txn_id,				SYSDATE,
	i_user_id,				SYSDATE,
	i_user_id,				i_login_id,
	i_org_id,				i_wip_entity_id,
	i_acct_period_id,			NULL,
	6,					i_txn_date,
	NULL,					NULL,
	NULL,                                   NULL,
	NULL,                                   NULL,
	NULL,                                   NULL,
	NULL,                                   NULL,
	NULL,                                   NULL,
	NULL,                                   NULL,
	NULL,                                   NULL,
	NULL,                                   NULL,
        NULL,                                   NULL,
        NULL,                                   NULL,
        NULL,                                   NULL,
        NULL,                                   NULL,
        NULL,                                   NULL,
        NULL,                                   NULL,
        NULL,                                   NULL,
        NULL,                                   NULL,
        NULL,                                   NULL,
        NULL,                                   NULL,
        NULL,                                   NULL,
	NULL,                                   NULL,
        NULL,                                   NULL,
        NULL,                                   NULL,
	i_request_id,				i_prog_appl_id,
	i_prog_id,				SYSDATE,
	NULL,					NULL,
	NULL,					NULL
	from dual;

    /* SLA Event Seeding */
    --{BUG#7300970
    stmt_num := 60;
    debug('l_nb :'||l_nb);

    IF l_nb > 0 THEN

      l_trx_info.TRANSACTION_ID      := l_txn_id;
      l_trx_info.INV_ORGANIZATION_ID := i_org_id;
      l_trx_info.WIP_RESOURCE_ID     := -1;
      l_trx_info.WIP_BASIS_TYPE_ID   := -1;
      l_trx_info.TXN_TYPE_ID         := 6;
      l_trx_info.TRANSACTION_DATE    := i_txn_date;

      CST_XLA_PVT.Create_WIPXLAEvent  (
            p_api_version       => 1,
            p_init_msg_list    => FND_API.G_FALSE,
            p_commit           => FND_API.G_FALSE,
            p_validation_level => FND_API.G_VALID_LEVEL_FULL,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data,
            p_trx_info         => l_trx_info);

    END IF;
    --}
    debug('wip_cfm_var_relief-');

EXCEPTION


   WHEN no_wpb_rows then
   rollback;
   err_num := 9999;
   err_code := 'CST_NO_BALANCE_ROW';
   FND_MESSAGE.set_name('BOM', 'CST_NO_BALANCE_ROW');
   err_msg := FND_MESSAGE.Get;
   debug(err_msg);

   WHEN OTHERS THEN
      rollback;
      err_num := SQLCODE;
      err_msg := 'CSTPCFMS:' || 'wip_cfm_var_relief:' || to_char(stmt_num) ||
                 ' ' || substr(SQLERRM,1,150);
      debug(err_msg);
END wip_cfm_var_relief;

END CSTPCFMS; /* end package body */

/
