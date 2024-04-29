--------------------------------------------------------
--  DDL for Package Body CSTPALPC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPALPC" AS
/* $Header: CSTALPCB.pls 120.11.12010000.3 2009/05/06 23:19:19 jkwac ship $ */

l_debug_flag VARCHAR2(1) := FND_PROFILE.VALUE('MRP_DEBUG');
PROCEDURE dyn_proc_call (
        i_proc_name        IN        VARCHAR2,
        i_legal_entity     IN        NUMBER,
        i_cost_type        IN        NUMBER,
        i_cost_group       IN        NUMBER,
        i_period_id        IN        NUMBER,
        i_transaction_id   IN        NUMBER,
        i_event_type_id    IN        VARCHAR2,
	i_txn_type_flag    IN      VARCHAR2, -- 4586534
        o_err_num          OUT NOCOPY        NUMBER,
        o_err_code         OUT NOCOPY        VARCHAR2,
        o_err_msg          OUT NOCOPY        VARCHAR2
)
IS
        l_sql_to_run       VARCHAR2(500);
        CONC_STATUS        BOOLEAN;
        l_err              NUMBER := 0;
        CST_PKG_FAIL       EXCEPTION;
        CST_PKG_FAIL2      EXCEPTION;
        l_stmt_num         NUMBER;
BEGIN

  l_stmt_num := 10;

  l_sql_to_run  := 'BEGIN ' || i_proc_name || '(';


  l_sql_to_run := l_sql_to_run || ':I_LEGAL_ENTITY';
  l_sql_to_run := l_sql_to_run || ', :I_COST_TYPE_ID';
  l_sql_to_run := l_sql_to_run || ', :I_COST_GROUP_ID';
  l_sql_to_run := l_sql_to_run || ', :I_PERIOD_ID';
  l_sql_to_run := l_sql_to_run || ', :I_TRANSACTION_ID';
  l_sql_to_run := l_sql_to_run || ', :I_EVENT_TYPE_ID';
  l_sql_to_run := l_sql_to_run || ', :I_TXN_TYPE_FLAG'; -- 4586534
  l_sql_to_run := l_sql_to_run || ', :O_ERR_NUM';
  l_sql_to_run := l_sql_to_run || ', :O_ERR_CODE';
  l_sql_to_run := l_sql_to_run || ', :O_ERR_MSG';
  l_sql_to_run  := l_sql_to_run || '); END;';

  l_stmt_num := 20;

  EXECUTE IMMEDIATE l_sql_to_run USING
                        I_LEGAL_ENTITY,
                        I_COST_TYPE,
                        I_COST_GROUP,
                        I_PERIOD_ID,
                        I_TRANSACTION_ID,
                        I_EVENT_TYPE_ID,
			I_TXN_TYPE_FLAG,
                        OUT O_ERR_NUM,
                        OUT O_ERR_CODE,
                        OUT O_ERR_MSG;
  IF (o_err_num <> 0 and o_err_num is not null) THEN
    RAISE CST_PKG_FAIL;
  END IF;

  IF(l_err <> 0) THEN
    RAISE CST_PKG_FAIL2;
  END IF;

EXCEPTION
  WHEN CST_PKG_FAIL THEN
    fnd_file.put_line(fnd_file.log,o_err_msg);
    fnd_file.put_line(fnd_file.log,'CSTPALPC.dyn_proc_call : Error Calling Package');
  WHEN CST_PKG_FAIL2 THEN
    o_err_num := l_err;
    o_err_code := SQLCODE;
    o_err_msg :=  'CSTPALPC.dyn_proc_call ('||l_err||'): Error Calling Package';
    fnd_file.put_line(fnd_file.log,o_err_msg);
  WHEN OTHERS THEN
    o_err_num := 30002;
    o_err_code := SQLCODE;
    o_err_msg := 'CSTPALPC.dyn_proc_call : ' || to_char(l_stmt_num) || ':'|| substr(SQLERRM,1,180);
    fnd_file.put_line(fnd_file.log,o_err_msg);
END dyn_proc_call;


PROCEDURE create_acct_entry (
        i_acct_lib_id       IN                NUMBER,
        i_legal_entity      IN                NUMBER,
        i_cost_type_id      IN                NUMBER,
        i_cost_group_id     IN                NUMBER,
        i_period_id         IN                NUMBER,
        i_mode              IN                NUMBER,
        o_err_num           OUT NOCOPY                NUMBER,
        o_err_code          OUT NOCOPY                VARCHAR2,
        o_err_msg           OUT NOCOPY                VARCHAR2
) IS
  l_err_rec                 CSTPALTY.CST_AE_ERR_REC_TYPE;
  l_stmt_num                NUMBER;
BEGIN
  IF l_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Create_Acct_Entry <<< ');
  END IF;

  IF (i_mode = 0) THEN
   /* Normal Mode */
    l_stmt_num := 10;
    CSTPALPC.create_dist_entry (
            i_acct_lib_id =>  i_acct_lib_id,
            i_legal_entity => i_legal_entity,
            i_cost_type_id => i_cost_type_id,
            i_cost_group_id => i_cost_group_id,
            i_period_id => i_period_id,
            o_err_num => o_err_num,
            o_err_code => o_err_code,
            o_err_msg => o_err_msg);
  ELSE
    /* Period End */
    l_stmt_num := 20;
    CSTPALPC.create_per_end_entry (
            i_acct_lib_id =>  i_acct_lib_id,
            i_legal_entity => i_legal_entity,
            i_cost_type_id => i_cost_type_id,
            i_cost_group_id => i_cost_group_id,
            i_period_id => i_period_id,
            o_err_num => o_err_num,
            o_err_code => o_err_code,
            o_err_msg => o_err_msg);
  END IF;
  IF l_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Create_Acct_Entry >>> ');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    o_err_num := 30001;
    o_err_code := SQLCODE;
    o_err_msg := 'CSTPALPC.create_acct_entry : ' || to_char(l_stmt_num) || ' :'|| substr(SQLERRM,1,180);
    fnd_file.put_line(fnd_file.log,l_err_rec.l_err_msg);

END create_acct_entry;

PROCEDURE create_dist_entry (
        i_acct_lib_id       IN          NUMBER,
        i_legal_entity      IN          NUMBER,
        i_cost_type_id      IN          NUMBER,
        i_cost_group_id     IN          NUMBER,
        i_period_id         IN          NUMBER,
        o_err_num           OUT NOCOPY  NUMBER,
        o_err_code          OUT NOCOPY  VARCHAR2,
        o_err_msg           OUT NOCOPY  VARCHAR2
) IS

  CURSOR c_txns IS
  SELECT mmt.transaction_id "TRANSACTION_ID",
         mmt.transaction_action_id "TRANSACTION_ACTION_ID",
         mmt.transaction_source_type_id "TRANSACTION_SOURCE_TYPE_ID",
         mmt.transaction_type_id "TRANSACTION_TYPE_ID",
         to_char(null) "TRANSACTION_TYPE",
         (to_char(mtt.transaction_type_id)||'-'||to_char(mtt.transaction_action_id)||'-'||to_char(mtt.transaction_source_type_id)) "EVENT_TYPE", --  4986702
         'INV' "TRANSACTION_TYPE_FLAG", -- 4986702
	 mmt.trx_source_line_id "TRX_SOURCE_LINE_ID"
  FROM mtl_material_transactions mmt,
       cst_cost_groups ccg,
       cst_cost_group_assignments ccga,
       cst_pac_periods cpp,
       mtl_transaction_types mtt /* Removed the access to view to directly access the base tables Bug 4968702 */
  WHERE
  /* Periodic Cost Updates have the item master organization_id as
     the organization_id in MMT. In this case, the org_cost_group
     ID is stamped in MMT */

  /* For Internal Order and Ordinary Interorg Intransit Shipment and Receipt,pick up
     intermediate transactions as well */

  mmt.organization_id = decode(mmt.transaction_type_id,
                               26, decode(nvl(mmt.org_cost_group_id, -1), ccga.cost_group_id, mmt.organization_id, ccga.organization_id),
                               21,decode(mmt.fob_point,
                                         1,mmt.organization_id,
                                         ccga.organization_id),
                               62,decode(mmt.fob_point,
                                         1,mmt.organization_id,
                                         ccga.organization_id),
                               12,decode(mmt.fob_point,
                                         2,mmt.organization_id,
                                         ccga.organization_id),
                               61,decode(mmt.fob_point,
                                         2,mmt.organization_id,
                                         ccga.organization_id),
                               ccga.organization_id)
  AND mmt.organization_id = decode(mmt.transaction_type_id,
                                   21,decode(mmt.fob_point,
                                             1,mmt.organization_id,
                                             NVL(mmt.owning_organization_id, mmt.organization_id)),
                                   62,decode(mmt.fob_point,
                                             1,mmt.organization_id,
                                             NVL(mmt.owning_organization_id, mmt.organization_id)),
                                   12,decode(mmt.fob_point,
                                             2,mmt.organization_id,
                                             NVL(mmt.owning_organization_id, mmt.organization_id)),
                                   61,decode(mmt.fob_point,
                                             2,mmt.organization_id,
                                             NVL(mmt.owning_organization_id, mmt.organization_id)),
                                   nvl(mmt.owning_organization_id, mmt.organization_id))
  AND nvl(mmt.owning_tp_type,2) = 2
  AND ccga.cost_group_id   = ccg.cost_group_id
  AND ccg.cost_group_id    = i_cost_group_id
  AND ccg.legal_entity     = i_legal_entity
  AND mmt.transaction_date BETWEEN trunc(cpp.period_start_date)
                            AND (trunc(cpp.period_end_date) + 0.99999)
  AND cpp.pac_period_id = i_period_id
 --AND caet.transaction_type_flag = 'INV'
  AND mtt.transaction_type_id = mmt.transaction_type_id -- Join with the base tables.Bug 4968702
  AND mtt.transaction_action_id = mmt.transaction_action_id
  AND mtt.transaction_source_type_id = mmt.transaction_source_type_id
  /*  Drop Ship/Global Proc:
    These transactions will be picked up from the union statement below. For now
    omit any Drop Ship/Global Proc transactions. */
  AND (  ( mmt.parent_transaction_id is null
           AND EXISTS (
             SELECT 1
              FROM mtl_pac_actual_cost_details mpacd
             WHERE mpacd.transaction_id = mmt.transaction_id
               AND mpacd.pac_period_id  = i_period_id
               AND mpacd.cost_group_id  = ccga.cost_group_id
               AND mpacd.cost_group_id  = i_COST_GROUP_ID
                     )
	   )
  /* Bug7629550: for better performance merged two heavy queries into one */
  /* This section will pick up all global procurement and Drop shipment txns
     However, parent physical transactions are omitted, since they have no
     ditributions against them */
	  OR ( mmt.parent_transaction_id is not null AND
               nvl(mmt.logical_transaction, 2) = 1
	      )
	)
  UNION
  SELECT
  wt.transaction_id "TRANSACTION_ID",
  to_number(null) "TRANSACTION_ACTION_ID",
  to_number(null) "TRANSACTION_SOURCE_TYPE_ID",
  wt.transaction_type "TRANSACTION_TYPE_ID",
  to_char(null) "TRANSACTION_TYPE",  -- Directly taking data from mfg_lookups instead of the caet view Bug 4968702
  (SELECT to_char(lookup_code) FROM mfg_lookups WHERE lookup_type = 'WIP_TRANSACTION_TYPE' AND lookup_code = wt.transaction_type) "EVENT_TYPE",  --Bug 4968702
  'WIP' "TRANSACTION_TYPE_FLAG",  -- 4968702
  NULL  "TRX_SOURCE_LINE_ID"
  FROM
  wip_transactions wt,
  cst_cost_groups ccg,
  cst_cost_group_assignments ccga,
  cst_pac_periods cpp
  WHERE
  wt.organization_id = ccga.organization_id AND
  ccga.cost_group_id = ccg.cost_group_id AND
  ccg.cost_group_id = i_cost_group_id AND
  ccg.legal_entity = i_legal_entity   AND
  cpp.pac_period_id = i_period_id   AND
  wt.transaction_date BETWEEN trunc(cpp.period_start_date)
		      AND (trunc(cpp.period_end_date) + 0.99999) AND
  (wt.transaction_type = 17  -- Added 17 to support Direct Items as part of eAM support in PAC
   OR (wt.transaction_type in (1,2,3,6) AND
       EXISTS (SELECT 1
               FROM   wip_pac_actual_cost_details wpacd
               WHERE  wpacd.transaction_id = wt.transaction_id AND
                      wpacd.pac_period_id = i_period_id  AND
                      wpacd.cost_group_id = i_cost_group_id)
   ))
UNION
/* Drop Shipment changes: Omit any true drop shipment transactions */
  SELECT
  rt.transaction_id "TRANSACTION_ID",
  to_number(null) "TRANSACTION_ACTION_ID",
  to_number(null) "TRANSACTION_SOURCE_TYPE_ID",
  to_number(null) "TRANSACTION_TYPE_ID",
  rt.transaction_type "TRANSACTION_TYPE",
  plc.lookup_code "EVENT_TYPE",  --4968702  Directly taking data from mfg_lookup_codes instead of view caet
  'RCV' "TRANSACTION_TYPE_FLAG",  -- 4968702
  NULL  "TRX_SOURCE_LINE_ID"
  FROM
  rcv_transactions rt,
  cst_cost_groups ccg,
  cst_cost_group_assignments ccga,
  cst_pac_periods cpp,
  po_lookup_codes plc
  WHERE
  rt.organization_id = ccga.organization_id AND
  NVL(rt.consigned_flag,'N') = 'N' AND
  NVL(rt.dropship_type_code, 3) <> 2 AND -- FP BUG 5845861 do not pick up txn when DS with old accounting
  ccga.cost_group_id = ccg.cost_group_id AND
  ccg.cost_group_id = i_cost_group_id AND
  ccg.legal_entity = i_legal_entity AND
  rt.transaction_date BETWEEN trunc(cpp.period_start_date)
                      AND (trunc(cpp.period_end_date) + 0.99999) AND
  cpp.pac_period_id = i_PERIOD_ID AND
  plc.lookup_type = 'RCV TRANSACTION TYPE' AND   --joining with po_look_up codes. Bug 4968702
  plc.lookup_code = rt.transaction_type AND
  rt.source_document_code = 'PO' AND
  ((rt.transaction_type = 'RECEIVE' AND rt.parent_transaction_id = -1)
    OR (rt.transaction_type in ('MATCH','RETURN TO VENDOR','RETURN TO RECEIVING','DELIVER'))
    OR (rt.transaction_type = 'CORRECT' and rt.parent_transaction_id IN
           (select rt2.transaction_id from rcv_transactions rt2
            where
            (rt2.transaction_type = 'RECEIVE' AND rt2.parent_transaction_id = -1) OR
            (rt2.transaction_type in ('RETURN TO VENDOR','RETURN TO RECEIVING','MATCH','DELIVER'))
           )
       )
  )
  --pick up global procurement receipts even if set to period end accrual,
  --since period end will apply only to supplier facing org.
  AND exists (
           select 1
           from po_line_locations_all poll
           where poll.line_location_id = rt.po_line_location_id and
           poll.shipment_type <>'PREPAYMENT' and -- Added for complex work procurement
           (poll.transaction_flow_header_id is not null or
           ( poll.accrue_on_receipt_flag = 'Y' and
             not exists (
             select 1
             from po_distributions_all pod
             where pod.line_location_id = poll.line_location_id and
             accrue_on_receipt_flag = 'N')))
          )
UNION
  SELECT
  rae.accounting_event_id "TRANSACTION_ID",
  to_number(null) "TRANSACTION_ACTION_ID",
  to_number(null) "TRANSACTION_SOURCE_TYPE_ID",
  to_number(null) "TRANSACTION_TYPE_ID",     -- Removing the usage of CAET here
  decode(rae.event_type_id, 9, 'LOGICAL RECEIVE', 10, 'LOGICAL RETURN TO VENDOR') "TRANSACTION_TYPE",  -- Bug 4968702 Directly Using Base table
  decode(rae.event_type_id, 9, 'LOGICAL RECEIVE', 10, 'LOGICAL RETURN TO VENDOR') "EVENT_TYPE",-- Bug 4968702 Directly Using Base table
  'RAE' "TRANSACTION_TYPE_FLAG", -- Bug 4968702
   NULL  "TRX_SOURCE_LINE_ID"
  FROM
  rcv_accounting_events rae,
  rcv_transactions rt,
  cst_cost_groups ccg,
  cst_cost_group_assignments ccga,
  cst_pac_periods cpp

  WHERE
  rae.organization_id = ccga.organization_id AND
  rae.rcv_transaction_id = rt.transaction_id AND
  ccga.cost_group_id = ccg.cost_group_id AND
  ccg.cost_group_id = i_cost_group_id AND
  ccg.legal_entity = i_legal_entity AND
  rae.transaction_date BETWEEN trunc(cpp.period_start_date)
                      AND (trunc(cpp.period_end_date) + 0.99999) AND
  cpp.pac_period_id = i_PERIOD_ID AND
  cpp.legal_entity =ccg.legal_entity AND
  rae.event_source = 'RECEIVING' AND
  -- rae.trx_flow_header_id is not null AND /*Bug 5263514*/
  rae.event_type_id in (9,10) --Logical Receive OR Logical Return to Vendor
  --omit logical transactions from supplier facing org if accrual option is
  --period end.
  AND ( nvl(rae.procurement_org_flag, 'N') = 'N'
           OR EXISTS (
           select 1
           from po_line_locations_all poll
           where poll.line_location_id = rt.po_line_location_id and
           poll.accrue_on_receipt_flag = 'Y' and
           not exists (
             select 1
             from po_distributions_all pod
             where pod.line_location_id = poll.line_location_id and
             accrue_on_receipt_flag = 'N')
           ))

-- Retro Changes---------------------------------------------------------
UNION
  SELECT RAE.ACCOUNTING_EVENT_ID "TRANSACTION_ID",
         TO_NUMBER(NULL)         "TRANSACTION_ACTION_ID",
         TO_NUMBER(NULL)         "TRANSACTION_SOURCE_TYPE_ID",
         TO_NUMBER(NULL)         "TRANSACTION_TYPE_ID",
         'Adjust Receive'        "TRANSACTION_TYPE",
         'ADJUST RECEIVE'        "EVENT_TYPE",
         'ADJ'                   "TRANSACTION_TYPE_FLAG",
          NULL  "TRX_SOURCE_LINE_ID"
  FROM RCV_ACCOUNTING_EVENTS RAE,
       RCV_TRANSACTIONS RT,
       CST_COST_GROUPS       CCG,
       CST_COST_GROUP_ASSIGNMENTS CCGA,
       CST_PAC_PERIODS CPP
  WHERE  RAE.ORGANIZATION_ID         = CCGA.ORGANIZATION_ID
  AND    CCGA.COST_GROUP_ID          = CCG.COST_GROUP_ID
  AND    CCG.COST_GROUP_ID           = i_cost_group_id
  AND    CCG.LEGAL_ENTITY            = i_legal_entity
  AND    RAE.TRANSACTION_DATE BETWEEN TRUNC(CPP.PERIOD_START_DATE)
                              AND (TRUNC(CPP.PERIOD_END_DATE) + 0.99999)
  AND    CPP.PAC_PERIOD_ID           = i_PERIOD_ID
  AND    RT.TRANSACTION_ID = RAE.RCV_TRANSACTION_ID
  AND    RT.TRANSACTION_DATE   < CPP.PERIOD_START_DATE
  AND    RAE.EVENT_TYPE_ID = 7
-- EVENT_TYPE_ID = 7 refers to ADJUST_RECEIVE
-- Number used to avoid RCV dependencies
-------------------------------------------------------------------------
/*----LCM CHANGE------------------------------------------*/
  UNION
  SELECT RAE.ACCOUNTING_EVENT_ID "TRANSACTION_ID",
         TO_NUMBER(NULL)         "TRANSACTION_ACTION_ID",
         TO_NUMBER(NULL)         "TRANSACTION_SOURCE_TYPE_ID",
         TO_NUMBER(NULL)         "TRANSACTION_TYPE_ID",
         decode(RAE.EVENT_TYPE_ID,18,'PAC LC ADJ REC',
	                          19,'PAC LC ADJ DEL ASSET',
				  20,'PAC LC ADJ DEL EXP') "TRANSACTION_TYPE",
         decode(RAE.EVENT_TYPE_ID,18,'PAC LC ADJ REC',
	                          19,'PAC LC ADJ DEL ASSET',
				  20,'PAC LC ADJ DEL EXP') "EVENT_TYPE",
         'LC ADJ'                   "TRANSACTION_TYPE_FLAG",
          NULL  "TRX_SOURCE_LINE_ID"
  FROM RCV_ACCOUNTING_EVENTS RAE,
       RCV_TRANSACTIONS RT,
       CST_COST_GROUPS       CCG,
       CST_COST_GROUP_ASSIGNMENTS CCGA,
       CST_PAC_PERIODS CPP
  WHERE  RAE.ORGANIZATION_ID         = CCGA.ORGANIZATION_ID
  AND    CCGA.COST_GROUP_ID          = CCG.COST_GROUP_ID
  AND    CCG.COST_GROUP_ID           = i_cost_group_id
  AND    CCG.LEGAL_ENTITY            = i_legal_entity
  AND    RAE.TRANSACTION_DATE BETWEEN TRUNC(CPP.PERIOD_START_DATE)
                              AND (TRUNC(CPP.PERIOD_END_DATE) + 0.99999)
  AND    CPP.PAC_PERIOD_ID           = i_PERIOD_ID
  AND    RT.TRANSACTION_ID = RAE.RCV_TRANSACTION_ID
  AND    RT.TRANSACTION_DATE   < CPP.PERIOD_START_DATE
  AND    RAE.EVENT_TYPE_ID in (18,19,20);

  l_err_rec                     CSTPALTY.CST_AE_ERR_REC_TYPE;
  l_sql_to_run                  VARCHAR2(500);
  l_package_name                VARCHAR2(100);
  l_cursor                      NUMBER;
  l_event_type_id               VARCHAR2(30);
  l_accounting_package_id       NUMBER;
  l_event_pkg_exists            NUMBER;
  l_stmt_num                    NUMBER;
  l_txn_count                   NUMBER;
  l_transaction_type_flag       VARCHAR2(100);
  l_period_end                  NUMBER;
  l_so_issue_exists             NUMBER;
  CONC_STATUS                   BOOLEAN;
  CST_PKG_CALL_FAIL             EXCEPTION;
BEGIN

  l_stmt_num := 5;
  IF l_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Create_Dist_Entry <<< ');
  END IF;
  l_txn_count := 0;

  FOR c_txns_rec IN c_txns LOOP
    l_stmt_num := 10;
    IF l_debug_flag = 'Y' THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Transaction: '||to_char(c_txns_rec.transaction_id));
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Transaction Type: '||c_txns_rec.transaction_type);
    END IF;
    l_transaction_type_flag := c_txns_rec.transaction_type_flag;
    l_event_type_id := c_txns_rec.event_type;

    l_stmt_num := 20;

    SELECT
    count(*)
    INTO
    l_event_pkg_exists
    FROM
    cst_acct_lib_packages calp2
    WHERE
    calp2.accounting_lib_id = i_acct_lib_id AND
    calp2.event_type_id = l_event_type_id;

    IF (l_event_pkg_exists > 0) THEN

      l_stmt_num := 30;

      SELECT
      cap.accounting_package_id,
      cap.package_name
      INTO
      l_accounting_package_id,
      l_package_name
      FROM
      cst_acct_lib_packages calp,
      cst_accounting_packages cap
      WHERE
      calp.accounting_lib_id = i_acct_lib_id AND
      calp.event_type_id = l_event_type_id AND
      cap.accounting_package_id = calp.accounting_package_id;

    ELSE

      l_stmt_num := 40;

      SELECT
      cap.accounting_package_id,
      cap.package_name
      INTO
      l_accounting_package_id,
      l_package_name
      FROM
      cst_acct_lib_packages calp,
      cst_accounting_packages cap
      WHERE
      calp.accounting_lib_id = i_acct_lib_id AND
      calp.event_type_id IS NULL AND
      cap.accounting_package_id = calp.accounting_package_id;

    END IF;
    IF l_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Calling Package '||(l_package_name) ||' ...');
    END IF;

    l_so_issue_exists := 1;

    IF (c_txns_rec.transaction_type_flag = 'INV'  AND
        c_txns_rec.transaction_action_id = 36      AND
        c_txns_rec.transaction_source_type_id = 2) THEN

       BEGIN
       l_stmt_num := 45;
       SELECT COUNT(1)
       INTO   l_so_issue_exists
       FROM   cst_revenue_cogs_match_lines crcml
       WHERE  cogs_om_line_id = c_txns_rec.trx_source_line_id
       AND    pac_cost_type_id = i_cost_type_id;

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_so_issue_exists := 0;
       END;
    END IF;

   IF (l_so_issue_exists <> 0) THEN

    dyn_proc_call(
        l_package_name,
        i_legal_entity,
        i_cost_type_id   ,
        i_cost_group_id  ,
        i_period_id   ,
        c_txns_rec.transaction_id,
        l_event_type_id,
	l_transaction_type_flag,
        l_err_rec.l_err_num     ,
        l_err_rec.l_err_code    ,
        l_err_rec.l_err_msg
    );

    IF (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) THEN
      RAISE CST_PKG_CALL_FAIL;
    END IF;
 END IF; -- End of l_so_issue_exists

  l_txn_count := l_txn_count + 1;
END LOOP;

  IF l_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Total Transactions processed : '||to_char(l_txn_count));
    fnd_file.put_line(fnd_file.log, 'Create_Dist_Entry >>> ');
  END IF;

COMMIT;

EXCEPTION
  WHEN CST_PKG_CALL_FAIL THEN
        o_err_num := l_err_rec.l_err_num;
        o_err_code := l_err_rec.l_err_code;
        o_err_msg :=  l_err_rec.l_err_msg || ': CSTPALPC.create_dist_entry : ' || to_char(l_stmt_num);
        fnd_file.put_line(fnd_file.log,o_err_msg);
  WHEN OTHERS THEN
        o_err_num := 30002;
        o_err_code := SQLCODE;
        o_err_msg := 'CSTPALPC.create_dist_entry : ' || to_char(l_stmt_num) || ':'|| substr(SQLERRM,1,180);
        fnd_file.put_line(fnd_file.log,l_err_rec.l_err_msg);

END create_dist_entry;

PROCEDURE create_per_end_entry (
        i_acct_lib_id       IN          NUMBER,
        i_legal_entity      IN          NUMBER,
        i_cost_type_id      IN          NUMBER,
        i_cost_group_id     IN          NUMBER,
        i_period_id         IN          NUMBER,
        o_err_num           OUT NOCOPY  NUMBER,
        o_err_code          OUT NOCOPY  VARCHAR2,
        o_err_msg           OUT NOCOPY  VARCHAR2
) IS

  ---------------------------------------------------------------------------
  -- Complex Work Procurement Changes
  -- Transactions related to PREPAYMENT shipment type should not be considered.
  ---------------------------------------------------------------------------
  CURSOR c_txns IS
  SELECT
  rt.transaction_id "TRANSACTION_ID",
  to_number(null) "TRANSACTION_ACTION_ID",
  to_number(null) "TRANSACTION_SOURCE_TYPE_ID",
  to_number(null) "TRANSACTION_TYPE_ID",
  rt.transaction_type "TRANSACTION_TYPE",
  caet.event_type "EVENT_TYPE",
  caet.transaction_type_flag "TRANSACTION_TYPE_FLAG"
  FROM
  rcv_transactions rt,
  cst_cost_groups ccg,
  cst_cost_group_assignments ccga,
  cst_pac_periods cpp,
  cst_accounting_event_types_v caet
  WHERE
  rt.organization_id = ccga.organization_id AND
  NVL(rt.consigned_flag,'N') = 'N' AND
  ccga.cost_group_id = ccg.cost_group_id AND
  ccg.cost_group_id = i_cost_group_id AND
  ccg.legal_entity = i_legal_entity AND
  rt.transaction_date <= (trunc(cpp.period_end_date) + 0.99999) AND
  cpp.pac_period_id = i_period_id AND
  rt.source_document_code = 'PO' AND
  caet.transaction_type_flag = 'ACR' AND
  ((rt.transaction_type = 'RECEIVE' AND rt.parent_transaction_id = -1)
  OR
  (rt.transaction_type = 'MATCH'))
  AND exists (
                        select
                        1
                        from
                        po_line_locations_all poll,
			po_headers_all poh /*Added for bug 5352511 */
                        where poll.line_location_id = rt.po_line_location_id and
                        poll.accrue_on_receipt_flag = 'N' and /* Begin Bug5352511 */
			poh.po_header_id = poll.po_header_id and
			( (nvl(poll.closed_date,poh.closed_date) >=
			    (trunc(cpp.period_end_date)+0.9999)) OR
			  (nvl(poh.closed_date,poll.closed_date) is null)
			) and /* End Bug 5352511 */
                        poll.shipment_type <> 'PREPAYMENT' and
                        not exists (
                        select
                        1
                        from
                        po_distributions_all pod
                        where pod.line_location_id = poll.line_location_id and
                        accrue_on_receipt_flag = 'Y'));

  l_err_rec                     CSTPALTY.CST_AE_ERR_REC_TYPE;
  l_sql_to_run                  VARCHAR2(500);
  l_package_name                VARCHAR2(100);
  l_cursor                      NUMBER;
  l_event_type_id               VARCHAR2(30);
  l_accounting_package_id       NUMBER;
  l_event_pkg_exists            NUMBER;
  l_stmt_num                    NUMBER;
  l_txn_count                   NUMBER;
  l_transaction_type_flag       VARCHAR2(100);
  l_period_end                  NUMBER;
  CONC_STATUS                   BOOLEAN;
  CST_PKG_CALL_FAIL             EXCEPTION;
BEGIN


  fnd_file.put_line(fnd_file.log,'CSTPALPC.create_per_end_entries in');
  l_txn_count := 0;

  FOR c_txns_rec IN c_txns LOOP

    l_transaction_type_flag := c_txns_rec.transaction_type_flag;
    fnd_file.put_line(fnd_file.log,'Processing Transaction : '||to_char(c_txns_rec.transaction_id));

    l_stmt_num := 10;
    l_event_type_id := c_txns_rec.EVENT_TYPE;

    l_stmt_num := 20;

    SELECT
    count(*)
    INTO
    l_event_pkg_exists
    FROM
    cst_acct_lib_packages calp2
    WHERE
    calp2.accounting_lib_id = i_acct_lib_id AND
    calp2.event_type_id = l_event_type_id;

    IF (l_event_pkg_exists > 0) THEN

      l_stmt_num := 30;

      SELECT
      cap.accounting_package_id,
      cap.package_name
      INTO
      l_accounting_package_id,
      l_package_name
      FROM
      cst_acct_lib_packages calp,
      cst_accounting_packages cap
      WHERE
      calp.accounting_lib_id = i_acct_lib_id AND
      calp.event_type_id = l_event_type_id AND
      cap.accounting_package_id = calp.accounting_package_id;

    ELSE

      l_stmt_num := 40;

      SELECT
      cap.accounting_package_id,
      cap.package_name
      INTO
      l_accounting_package_id,
      l_package_name
      FROM
      cst_acct_lib_packages calp,
      cst_accounting_packages cap
      WHERE
      calp.accounting_lib_id = i_acct_lib_id AND
      calp.event_type_id IS NULL AND
      cap.accounting_package_id = calp.accounting_package_id;

    END IF;

    fnd_file.put_line(fnd_file.log,'Calling Package '||(l_package_name) ||' ...');

    dyn_proc_call(
        l_package_name,
        i_legal_entity,
        i_cost_type_id   ,
        i_cost_group_id  ,
        i_period_id   ,
        c_txns_rec.transaction_id,
        l_event_type_id,
	l_transaction_type_flag,
        l_err_rec.l_err_num     ,
        l_err_rec.l_err_code    ,
        l_err_rec.l_err_msg
    );

  IF (l_err_rec.l_err_num <> 0 and l_err_rec.l_err_num is not null) THEN
    RAISE CST_PKG_CALL_FAIL;
  END IF;
  l_txn_count := l_txn_count + 1;

END LOOP;
fnd_file.put_line(fnd_file.log,'Total Transactions processed : '||to_char(l_txn_count));

--COMMIT;

EXCEPTION
  WHEN CST_PKG_CALL_FAIL THEN
        o_err_num := l_err_rec.l_err_num;
        o_err_code := l_err_rec.l_err_code;
        o_err_msg :=  l_err_rec.l_err_msg;
  WHEN OTHERS THEN
        o_err_num := 30002;
        o_err_code := SQLCODE;
        o_err_msg := 'CSTPALPC.create_per_end_entry : ' || to_char(l_stmt_num) || ':'|| substr(SQLERRM,1,180);
        fnd_file.put_line(fnd_file.log,l_err_rec.l_err_msg);

END create_per_end_entry;



PROCEDURE insert_ae_lines (
        i_ae_txn_rec       IN         CSTPALTY.cst_ae_txn_rec_type,
        i_ae_line_rec_tbl  IN         CSTPALTY.cst_ae_line_tbl_type,
        o_err_rec          OUT NOCOPY CSTPALTY.cst_ae_err_rec_type
)
IS
        l_ae_header_id     NUMBER;
        l_err_rec          CSTPALTY.CST_AE_ERR_REC_TYPE;
        l_stmt_num         NUMBER;
        l_request_id       NUMBER;
        l_user_id          NUMBER;
        l_login_id         NUMBER;
        l_prog_appl_id     NUMBER;
        l_prog_id          NUMBER;
        CONC_STATUS        BOOLEAN;


BEGIN

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'CSTPALPC.Insert_Ae_Lines <<< ');

  l_request_id          := FND_GLOBAL.conc_request_id;
  l_user_id             := FND_GLOBAL.user_id;
  l_login_id            := FND_GLOBAL.login_id;
  l_prog_appl_id        := FND_GLOBAL.prog_appl_id;
  l_prog_id             := FND_GLOBAL.conc_program_id;

  l_stmt_num := 10;

  SELECT
  cst_ae_headers_s.NEXTVAL
  INTO
  l_ae_header_id
  FROM
  dual;


  IF i_ae_line_rec_tbl.EXISTS(1) THEN

    fnd_file.put_line(fnd_file.log,'Inserting in Headers table ...');

    l_stmt_num := 20;

    INSERT INTO
    cst_ae_headers (
    ae_header_id,
    accounting_event_id,
    set_of_books_id,
    legal_entity_id,
    cost_group_id,
    cost_type_id,
    ae_category,
    period_id,
    period_name,
    accounting_date,
    gl_transfer_flag,
    gl_transfer_run_id,
    description,
    gl_transfer_error_code,
    acct_event_source_table,
    organization_id,
    accounting_error_code,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    program_update_date,
    program_application_id,
    program_id,
    request_id,
    cross_currency_flag,
    gl_reversal_flag
    )
    VALUES
    (
    l_ae_header_id,
    i_ae_txn_rec.transaction_id,
    i_ae_txn_rec.set_of_books_id,
    i_ae_txn_rec.legal_entity_id,
    i_ae_txn_rec.cost_group_id,
    i_ae_txn_rec.cost_type_id,
    decode(i_ae_txn_rec.ae_category,'RCV','Receiving',
                                    'ACR','Accrual',
                                    'ADJ','Receiving',
                                    'RAE','Receiving',
				    'LC ADJ','Receiving',i_ae_txn_rec.ae_category),
    i_ae_txn_rec.accounting_period_id,
    i_ae_txn_rec.accounting_period_name,
    i_ae_txn_rec.accounting_date,
    'N',
    -1,
    i_ae_txn_rec.description,   --description??
    NULL,       -- gl xfer error code
    i_ae_txn_rec.source_table,
    i_ae_txn_rec.organization_id,
    NULL,
    sysdate,
    l_user_id,
    sysdate,
    l_user_id,
    l_login_id,
    sysdate,
    l_prog_appl_id,
    l_prog_id,
    l_request_id,
    NULL,
    decode(i_ae_txn_rec.ae_category,'ACR','Y',NULL)
    );

    FOR i IN i_ae_line_rec_tbl.FIRST..i_ae_line_rec_tbl.LAST LOOP

      fnd_file.put_line(fnd_file.log,'Inserting in Lines table ...');

      l_stmt_num := 30;
      IF (i_ae_line_rec_tbl(i).actual_flag = 'E') then

      INSERT INTO
      cst_encumbrance_lines (
      encumbrance_line_id,
      ae_header_id,
      ae_line_number,
      ae_line_type_code,
      code_combination_id,
      currency_code,
      currency_conversion_type,
      currency_conversion_date,
      currency_conversion_rate,
      entered_dr,
      entered_cr,
      accounted_dr,
      accounted_cr,
      source_table,
      source_id,
      rate_or_amount,
      basis_type,
      resource_id,
      cost_element_id,
      activity_id,
      repetitive_schedule_id,
      overhead_basis_factor,
      basis_resource_id,
      gl_sl_link_id,
      description,
      accounting_error_code,
      stat_amount,
      ussgl_transaction_code,
      subledger_doc_sequence_id,
      subledger_doc_sequence_value,
      gl_transfer_error_code,
      encumbrance_type_id,
      po_distribution_id,
      reference1,
      reference2,
      reference3,
      reference4,
      reference5,
      reference6,
      reference7,
      reference8,
      reference9,
      reference10,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      program_update_date,
      program_application_id,
      program_id,
      request_id
      )
      VALUES
      (
      cst_encumbrance_lines_s.nextval,
      l_ae_header_id,
      i,
      i_ae_line_rec_tbl(i).ae_line_type,
      i_ae_line_rec_tbl(i).account,
      i_ae_line_rec_tbl(i).currency_code,
      i_ae_line_rec_tbl(i).currency_conv_type,
      i_ae_line_rec_tbl(i).currency_conv_date,
      decode(i_ae_line_rec_tbl(i).currency_conv_rate,
            -1,decode(i_ae_line_rec_tbl(i).currency_code,
            NULL,NULL,
            i_ae_line_rec_tbl(i).currency_conv_rate),
            i_ae_line_rec_tbl(i).currency_conv_rate),
      i_ae_line_rec_tbl(i).entered_dr,
      i_ae_line_rec_tbl(i).entered_cr,
      i_ae_line_rec_tbl(i).accounted_dr,
      i_ae_line_rec_tbl(i).accounted_cr,
      i_ae_line_rec_tbl(i).source_table,        -- source table
      i_ae_line_rec_tbl(i).source_id,   -- source id
      i_ae_line_rec_tbl(i).rate_or_amount,
      i_ae_line_rec_tbl(i).basis_type,
      i_ae_line_rec_tbl(i).resource_id,
      i_ae_line_rec_tbl(i).cost_element_id,
      i_ae_line_rec_tbl(i).activity_id,
      i_ae_line_rec_tbl(i).repetitive_schedule_id,
      i_ae_line_rec_tbl(i).overhead_basis_factor,
      i_ae_line_rec_tbl(i).basis_resource_id,
      NULL,     -- gl_sl_link??   null
      i_ae_line_rec_tbl(i).description, -- desc accting line desc
      NULL,     -- error code null
      NULL,     -- stat amount null
      NULL,     -- ussgl null
      NULL,     -- sub ledger doc seq id
      NULL,     -- sub ledger doc  seq value
      NULL,     -- gl xfer error code
      i_ae_line_rec_tbl(i).encum_type_id,
      i_ae_line_rec_tbl(i).po_distribution_id,
      i_ae_line_rec_tbl(i).reference1,
      i_ae_line_rec_tbl(i).reference2,
      i_ae_line_rec_tbl(i).reference3,
      i_ae_line_rec_tbl(i).reference4,
      i_ae_line_rec_tbl(i).reference5,
      i_ae_line_rec_tbl(i).reference6,
      i_ae_line_rec_tbl(i).reference7,
      i_ae_line_rec_tbl(i).reference8,
      i_ae_line_rec_tbl(i).reference9,
      i_ae_line_rec_tbl(i).reference10,
      sysdate,
      l_user_id,
      sysdate,
      l_user_id,
      l_login_id,
      sysdate,
      l_prog_appl_id,
      l_prog_id,
      l_request_id
      );

      ELSE

      INSERT INTO
      cst_ae_lines (
      ae_line_id,
      ae_header_id,
      ae_line_number,
      ae_line_type_code,
      code_combination_id,
      currency_code,
      currency_conversion_type,
      currency_conversion_date,
      currency_conversion_rate,
      entered_dr,
      entered_cr,
      accounted_dr,
      accounted_cr,
      source_table,
      source_id,
      rate_or_amount,
      basis_type,
      resource_id,
      cost_element_id,
      activity_id,
      repetitive_schedule_id,
      overhead_basis_factor,
      basis_resource_id,
      gl_sl_link_id,
      description,
      accounting_error_code,
      stat_amount,
      ussgl_transaction_code,
      subledger_doc_sequence_id,
      subledger_doc_sequence_value,
      gl_transfer_error_code,
      po_distribution_id,
      wip_entity_id,
      reference1,
      reference2,
      reference3,
      reference4,
      reference5,
      reference6,
      reference7,
      reference8,
      reference9,
      reference10,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      program_update_date,
      program_application_id,
      program_id,
      request_id
      )
      VALUES
      (
      cst_ae_lines_s.nextval,
      l_ae_header_id,
      i,
      i_ae_line_rec_tbl(i).ae_line_type,
      i_ae_line_rec_tbl(i).account,
      i_ae_line_rec_tbl(i).currency_code,
      i_ae_line_rec_tbl(i).currency_conv_type,
      i_ae_line_rec_tbl(i).currency_conv_date,
      decode(i_ae_line_rec_tbl(i).currency_conv_rate,
            -1,decode(i_ae_line_rec_tbl(i).currency_code,
            NULL,NULL,
            i_ae_line_rec_tbl(i).currency_conv_rate),
            i_ae_line_rec_tbl(i).currency_conv_rate),
      i_ae_line_rec_tbl(i).entered_dr,
      i_ae_line_rec_tbl(i).entered_cr,
      i_ae_line_rec_tbl(i).accounted_dr,
      i_ae_line_rec_tbl(i).accounted_cr,
      i_ae_line_rec_tbl(i).source_table,        -- source table
      i_ae_line_rec_tbl(i).source_id,   -- source id
      i_ae_line_rec_tbl(i).rate_or_amount,
      i_ae_line_rec_tbl(i).basis_type,
      i_ae_line_rec_tbl(i).resource_id,
      i_ae_line_rec_tbl(i).cost_element_id,
      i_ae_line_rec_tbl(i).activity_id,
      i_ae_line_rec_tbl(i).repetitive_schedule_id,
      i_ae_line_rec_tbl(i).overhead_basis_factor,
      i_ae_line_rec_tbl(i).basis_resource_id,
      NULL,     -- gl_sl_link??   null
      i_ae_line_rec_tbl(i).description, -- desc accting line desc
      NULL,     -- error code null
      NULL,     -- stat amount null
      NULL,     -- ussgl null
      NULL,     -- sub ledger doc seq id
      NULL,     -- sub ledger doc  seq value
      NULL,     -- gl xfer error code
      i_ae_line_rec_tbl(i).po_distribution_id,
      i_ae_line_rec_tbl(i).wip_entity_id,
      i_ae_line_rec_tbl(i).reference1,
      i_ae_line_rec_tbl(i).reference2,
      i_ae_line_rec_tbl(i).reference3,
      i_ae_line_rec_tbl(i).reference4,
      i_ae_line_rec_tbl(i).reference5,
      i_ae_line_rec_tbl(i).reference6,
      i_ae_line_rec_tbl(i).reference7,
      i_ae_line_rec_tbl(i).reference8,
      i_ae_line_rec_tbl(i).reference9,
      i_ae_line_rec_tbl(i).reference10,
      sysdate,
      l_user_id,
      sysdate,
      l_user_id,
      l_login_id,
      sysdate,
      l_prog_appl_id,
      l_prog_id,
      l_request_id
      );
      END IF;


    END LOOP;

  END IF;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'CSTPALPC.Insert_Ae_Lines >>> ');

EXCEPTION
WHEN OTHERS THEN
        o_err_rec.l_err_num := 30001;
        o_err_rec.l_err_code := SQLCODE;
        o_err_rec.l_err_msg := 'CSTPALPC.insert_ae_lines : ' || to_char(l_stmt_num) || ':'|| substr(SQLERRM,1,180);
        CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',o_err_rec.l_err_msg);
        fnd_file.put_line(fnd_file.log,o_err_rec.l_err_msg);



END insert_ae_lines;

END CSTPALPC;


/
