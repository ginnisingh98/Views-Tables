--------------------------------------------------------
--  DDL for Package Body CSTPALBR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPALBR" AS
/* $Header: CSTALBRB.pls 120.6.12010000.2 2010/01/27 20:53:59 fayang ship $ */

g_mrp_debug VARCHAR2(1) := NVL(fnd_profile.value('MRP_DEBUG'), 'N'); -- Added For bug 4586534

PROCEDURE dyn_proc_call (
        i_proc_name             IN        VARCHAR2,
        i_legal_entity          IN        NUMBER,
        i_cost_type             IN        NUMBER,
        i_cost_group            IN        NUMBER,
        i_period_id             IN        NUMBER,
        i_transaction_id        IN        NUMBER,
        i_event_type_id         IN        VARCHAR2,
	i_txn_type_flag         IN      VARCHAR2, -- 4586534
        o_err_num               OUT NOCOPY        NUMBER,
        o_err_code              OUT NOCOPY        VARCHAR2,
        o_err_msg               OUT NOCOPY        VARCHAR2
)
IS
        l_sql_to_run                  VARCHAR2(500);
        --l_parameters            CST_AE_LIB_PAR_TBL_TYPE         := CST_AE_LIB_PAR_TBL_TYPE();
        CONC_STATUS                 BOOLEAN;
        l_err                        NUMBER                                 := 0;
        CST_PKG_FAIL                EXCEPTION;
        CST_PKG_FAIL2                EXCEPTION;
        --l_num_params                NUMBER;
        l_stmt_num                NUMBER;
BEGIN

  l_stmt_num := 10;

  l_sql_to_run  := 'BEGIN ' || i_proc_name || '(';


  l_sql_to_run := l_sql_to_run || ':I_LEGAL_ENTITY';
  l_sql_to_run := l_sql_to_run || ', :I_COST_TYPE_ID';
  l_sql_to_run := l_sql_to_run || ', :I_COST_GROUP_ID';
  l_sql_to_run := l_sql_to_run || ', :I_PERIOD_ID';
  l_sql_to_run := l_sql_to_run || ', :I_TRANSACTION_ID';
  l_sql_to_run := l_sql_to_run || ', :I_EVENT_TYPE_ID';
  l_sql_to_run := l_sql_to_run || ', :I_TXN_TYPE_FLAG'; -- 4586527
  l_sql_to_run := l_sql_to_run || ', :O_ERR_NUM';
  l_sql_to_run := l_sql_to_run || ', :O_ERR_CODE';
  l_sql_to_run := l_sql_to_run || ', :O_ERR_MSG';
  l_sql_to_run  := l_sql_to_run || '); END;';

  l_stmt_num := 20;
     IF g_mrp_debug = 'Y' THEN  -- Added For bug 4586534
    fnd_file.put_line(fnd_file.log,l_sql_to_run);
    END IF;

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
  fnd_file.put_line(fnd_file.log,'CSTPALBR.dyn_proc_call : Error Calling Package');
  WHEN CST_PKG_FAIL2 THEN
        o_err_num := l_err;
        o_err_code := SQLCODE;
        o_err_msg :=  'CSTPALBR.dyn_proc_call ('||l_err||'): Error Calling Package';
        fnd_file.put_line(fnd_file.log,o_err_msg);
  WHEN OTHERS THEN
        o_err_num := 30002;
        o_err_code := SQLCODE;
        o_err_msg := 'CSTPALBR.dyn_proc_call : ' || to_char(l_stmt_num) || ':'|| substr(SQLERRM,1,180);
        fnd_file.put_line(fnd_file.log,o_err_msg);
END dyn_proc_call;


PROCEDURE create_acct_entry (
        i_acct_lib_id                IN                NUMBER,
        i_legal_entity                IN                NUMBER,
        i_cost_type_id                IN                NUMBER,
        i_cost_group_id                IN                NUMBER,
        i_period_id                IN                NUMBER,
        i_mode                        IN                NUMBER,
        o_err_num                OUT NOCOPY                NUMBER,
        o_err_code                OUT NOCOPY                VARCHAR2,
        o_err_msg                OUT NOCOPY                VARCHAR2
) IS

                     /* Added for bug 4586534 */

 	             TYPE num_tab IS TABLE OF NUMBER;
 	             txn_id_tab           num_tab;
 	             txn_action_id_tab    num_tab;
 	             txn_src_typ_id_tab   num_tab;
 	             txn_type_id_tab      num_tab;
		     trx_source_line_id_tab num_tab;
 	             l_rec_cnt            NUMBER := 0;

 	             TYPE acct_event_char_tab is TABLE OF VARCHAR2(122);
 	             event_type_tab             acct_event_char_tab;
 	             transaction_type_flag_tab  acct_event_char_tab;


  CURSOR c_txns IS
  SELECT
  mmt.transaction_id "TRANSACTION_ID",
  mmt.transaction_action_id "TRANSACTION_ACTION_ID",
  mmt.transaction_source_type_id "TRANSACTION_SOURCE_TYPE_ID",
  mmt.transaction_type_id "TRANSACTION_TYPE_ID",
  (to_char(mtt.transaction_type_id)||'-'||to_char(mtt.transaction_action_id)||'-'||to_char(mtt.transaction_source_type_id)) "EVENT_TYPE", --  4586534
  'INV' "TRANSACTION_TYPE_FLAG", -- Bug 4968702
   mmt.trx_source_line_id "TRX_SOURCE_LINE_ID"
  FROM
  mtl_material_transactions mmt,
  mtl_parameters mp,    --INVCONV sikhanna changes
  cst_cost_groups ccg,
  cst_cost_group_assignments ccga,
  cst_pac_periods cpp,
  mtl_transaction_types mtt /* Removed the access to view to directly access the base tables Bug 4968702 */

  WHERE
  /* Periodic Cost Updates have the item master organization_id as
     the organization_id in MMT. In this case, the org_cost_group
     ID is stamped in MMT */
  /* Bug 2456402 */

  /* For Internal Order and Ordinary Interorg Intransit Shipment and Receipt,pick up
     intermediate transactions as well */
   mmt.organization_id = decode(mmt.transaction_type_id,
                                26, decode(nvl(mmt.org_cost_group_id, -1),
                                           ccga.cost_group_id, mmt.organization_id,
                                           ccga.organization_id),
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
  -- changed this condition as it was redundant sikhanna
  AND mmt.organization_id = NVL(mmt.owning_organization_id, mmt.organization_id)
  AND mmt.organization_id = mp.organization_id
  AND nvl(mp.process_enabled_flag,'N') = 'N'  --INVCONV sikhanna
  AND nvl(mmt.owning_tp_type,2) = 2
  AND ccga.cost_group_id = ccg.cost_group_id
  AND ccg.cost_group_id = i_cost_group_id
  AND ccg.legal_entity = i_legal_entity
  AND mmt.transaction_date BETWEEN trunc(cpp.period_start_date) AND
                (trunc(cpp.period_end_date) + 0.99999)
  AND cpp.pac_period_id = i_period_id
  AND mtt.transaction_type_id = mmt.transaction_type_id -- Join with the base tables.Bug 4968702
  AND mtt.transaction_action_id = mmt.transaction_action_id
  AND mtt.transaction_source_type_id = mmt.transaction_source_type_id
  AND EXISTS (
        SELECT
        1
        FROM
        mtl_pac_actual_cost_details mpacd
        WHERE
        mpacd.transaction_id = mmt.transaction_id AND
        mpacd.pac_period_id = cpp.pac_period_id AND
        mpacd.cost_group_id = ccga.cost_group_id
        )
  -- Revenue / COGS Matching
  UNION
  SELECT
  mmt.transaction_id "TRANSACTION_ID",
  mmt.transaction_action_id "TRANSACTION_ACTION_ID",
  mmt.transaction_source_type_id "TRANSACTION_SOURCE_TYPE_ID",
  mmt.transaction_type_id "TRANSACTION_TYPE_ID",
  (to_char(mtt.transaction_type_id)||'-'||to_char(mtt.transaction_action_id)||'-'||to_char(mtt.transaction_source_type_id)) "EVENT_TYPE", -- Bug 4968702
  'INV' "TRANSACTION_TYPE_FLAG", -- Bug 4968702
   mmt.trx_source_line_id "TRX_SOURCE_LINE_ID"
  FROM
  mtl_material_transactions mmt,
  cst_cost_groups ccg,
  cst_cost_group_assignments ccga,
  cst_pac_periods cpp,
  mtl_transaction_types mtt  -- Directly Using the base tables.Bug 4968702
  WHERE
  mmt.organization_id = ccga.organization_id AND
  mmt.organization_id = nvl(mmt.owning_organization_id, mmt.organization_id) AND
  nvl(mmt.owning_tp_type,2) = 2 AND
  ccga.cost_group_id = ccg.cost_group_id AND
  ccg.cost_group_id = i_cost_group_id AND
  ccg.legal_entity = i_legal_entity AND
  mmt.transaction_date BETWEEN trunc(cpp.period_start_date) AND
        (trunc(cpp.period_end_date) + 0.99999) AND
  cpp.pac_period_id = i_period_id AND
  mtt.transaction_type_id = mmt.transaction_type_id AND -- Bug 4968702 Join with base tables
  mtt.transaction_action_id = mmt.transaction_action_id AND
  mtt.transaction_source_type_id = mmt.transaction_source_type_id AND
  mmt.transaction_action_id = 36 AND
  mmt.transaction_source_type_id = 2
  UNION
  SELECT
  wt.transaction_id "transaction_id",
  to_number(null) "transaction_action_id",
  to_number(null) "transaction_source_type_id",
  wt.transaction_type "transaction_type_id", -- Bug 4968702 Using the base tables Directly
  (SELECT to_char(lookup_code) FROM mfg_lookups WHERE lookup_type = 'WIP_TRANSACTION_TYPE' AND lookup_code = wt.transaction_type) "EVENT_TYPE",  -- Bug 4968702
  'WIP' "TRANSACTION_TYPE_FLAG",  -- Bug 4968702
   NULL  "TRX_SOURCE_LINE_ID"
  FROM
  wip_transactions wt,
  cst_cost_groups ccg,
  cst_cost_group_assignments ccga,
  cst_pac_periods cpp -- Bug 4968702
  WHERE
  wt.organization_id = ccga.organization_id AND
  ccga.cost_group_id = ccg.cost_group_id AND
  ccg.cost_group_id = i_cost_group_id AND
  ccg.legal_entity = i_legal_entity AND
  cpp.pac_period_id = i_period_id AND
  --wt.transaction_type in (1,2,3,6) AND
  wt.transaction_date BETWEEN trunc(cpp.period_start_date)
		      AND (trunc(cpp.period_end_date) + 0.99999) AND
  (wt.transaction_type = 17  -- Added 17 to support Direct Items as part of eAM support in PAC
   OR (wt.transaction_type in (1,2,3,6) AND
       EXISTS ( SELECT 1
                FROM   wip_pac_actual_cost_details wpacd
                WHERE  wpacd.transaction_id = wt.transaction_id AND
        wpacd.pac_period_id = i_period_id AND
                       wpacd.cost_group_id = i_cost_group_id)
  ))
  --ORDER BY transaction_id
  ;


  l_ae_par_rec          CSTPALTY.CST_AE_PAR_REC_TYPE;
  l_err_rec                     CSTPALTY.CST_AE_ERR_REC_TYPE;
  --l_ae_par_rec                        CST_AE_PAR_REC_TYPE;
  --l_err_rec                   CST_AE_ERR_REC_TYPE;
  l_sql_to_run                  VARCHAR2(500);
  l_package_name                VARCHAR2(100);
  l_cursor                      NUMBER;
  l_event_type_id               VARCHAR2(15);
  l_accounting_package_id       NUMBER;
  l_event_pkg_exists            NUMBER;
  l_stmt_num                    NUMBER;
  l_so_issue_exists             NUMBER;
  CONC_STATUS                   BOOLEAN;
  CST_PKG_CALL_FAIL             EXCEPTION;
BEGIN
  IF (i_mode <> 0) THEN
    return;
  END IF;


  OPEN c_txns;



  /* Used Bulk Collect to improve  performance, Bug No. 4586534 */
  LOOP
    FETCH c_txns BULK COLLECT INTO txn_id_tab,
                                   txn_action_id_tab,
                                   txn_src_typ_id_tab,
                                   txn_type_id_tab,
				   event_type_tab,
				   transaction_type_flag_tab,
				   trx_source_line_id_tab LIMIT 5000;


     l_rec_cnt := txn_id_tab.COUNT;

     FOR i IN 1..l_rec_cnt LOOP

     IF g_mrp_debug = 'Y' THEN -- Bug No 4586534
     fnd_file.put_line(fnd_file.log,' ');
     fnd_file.put_line(fnd_file.log,'Processing Transaction : '||to_char(txn_id_tab(i)));
     END IF;


    l_stmt_num := 20;
    /* change for bug No. 4586534 to remove COUNT(*) to COUNT(1) by adding rownum check
          as it is used for existence check only */
       SELECT COUNT(1)
       INTO   l_event_pkg_exists
       FROM   cst_acct_lib_packages calp2
       WHERE  calp2.accounting_lib_id = i_acct_lib_id
       AND  calp2.event_type_id = event_type_tab(i)
       AND  ROWNUM < 2;

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
     IF g_mrp_debug = 'Y' THEN -- Bug No 4586534
    fnd_file.put_line(fnd_file.log,'Calling Package '||(l_package_name) ||' ...');
    END IF;

     l_so_issue_exists := 1;

    IF (transaction_type_flag_tab(i) = 'INV'  AND
        txn_action_id_tab(i) = 36  AND
        txn_src_typ_id_tab(i) = 2) THEN

       BEGIN
       l_stmt_num := 45;
       SELECT COUNT(1)
       INTO   l_so_issue_exists
       FROM   cst_revenue_cogs_match_lines crcml
       WHERE  cogs_om_line_id = trx_source_line_id_tab(i)
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
        txn_id_tab(i),
	event_type_tab(i),
	transaction_type_flag_tab(i),
        l_err_rec.l_err_num     ,
        l_err_rec.l_err_code    ,
        l_err_rec.l_err_msg
    );

    IF (l_err_rec.l_err_num <> 0 and  l_err_rec.l_err_num is not null) THEN
       RAISE CST_PKG_CALL_FAIL;
    END IF;
   END IF;

END LOOP;
EXIT WHEN c_txns%NOTFOUND; -- change for bug No. 4586534
END LOOP; -- change for bug No. 4586534
CLOSE c_txns;
     IF g_mrp_debug = 'Y' THEN -- Bug No 4586534
      fnd_file.put_line(fnd_file.log,'Total Transactions processed : '||to_char(l_rec_cnt));
     END IF;

COMMIT;

EXCEPTION
  WHEN CST_PKG_CALL_FAIL THEN
        o_err_num := l_err_rec.l_err_num;
        o_err_code := l_err_rec.l_err_code;
        o_err_msg :=  l_err_rec.l_err_msg;
  WHEN OTHERS THEN
        o_err_num := 30002;
        o_err_code := SQLCODE;
        o_err_msg := 'CSTPALBR.create_acct_entry : ' || to_char(l_stmt_num) || ':'|| substr(SQLERRM,1,180);
        fnd_file.put_line(fnd_file.log,l_err_rec.l_err_msg);

END create_acct_entry;

PROCEDURE insert_ae_lines (
        i_ae_txn_rec                IN        CSTPALTY.cst_ae_txn_rec_type,
        i_ae_line_rec_tbl        IN        CSTPALTY.cst_ae_line_tbl_type,
        o_err_rec                OUT NOCOPY        CSTPALTY.cst_ae_err_rec_type
)
IS
  l_ae_header_id                NUMBER;
  l_err_rec                     CSTPALTY.CST_AE_ERR_REC_TYPE;
  --l_err_rec                   CST_AE_ERR_REC_TYPE;
  l_stmt_num                    NUMBER;
  l_request_id                  NUMBER;
  l_user_id                     NUMBER;
  l_login_id                    NUMBER;
  l_prog_appl_id                NUMBER;
  l_prog_id                     NUMBER;
  CONC_STATUS                   BOOLEAN;


BEGIN

  l_request_id          := FND_GLOBAL.conc_request_id;
  l_user_id             := FND_GLOBAL.user_id;
  l_login_id            := FND_GLOBAL.login_id;
  l_prog_appl_id        := FND_GLOBAL.prog_appl_id;
  l_prog_id             := FND_GLOBAL.conc_program_id;

  l_stmt_num := 10;
 -- For Bug No. 4586534
/*
  SELECT
  cst_ae_headers_s.NEXTVAL
  INTO
  l_ae_header_id
  FROM
  dual;
*/

  IF i_ae_line_rec_tbl.EXISTS(1) THEN
    IF g_mrp_debug = 'Y' THEN -- Bug No 4586534
    fnd_file.put_line(fnd_file.log,'Inserting in Headers table ...');
    END IF;

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
    cross_currency_flag
    )
    VALUES
    (
    cst_ae_headers_s.NEXTVAL,
    i_ae_txn_rec.transaction_id,
    i_ae_txn_rec.set_of_books_id,
    i_ae_txn_rec.legal_entity_id,
    i_ae_txn_rec.cost_group_id,
    i_ae_txn_rec.cost_type_id,
    i_ae_txn_rec.ae_category,
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
    NULL
    )RETURNING ae_header_id INTO l_ae_header_id; -- Bug No.4586534

    FOR i IN i_ae_line_rec_tbl.FIRST..i_ae_line_rec_tbl.LAST LOOP
      IF g_mrp_debug = 'Y' THEN -- Bug No 4586534
       fnd_file.put_line(fnd_file.log,'Inserting in Lines table ...');
      END IF;

      l_stmt_num := 30;

      IF (i_ae_line_rec_tbl(i).actual_flag = 'E') THEN


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

EXCEPTION
WHEN OTHERS THEN
        o_err_rec.l_err_num := 30001;
        o_err_rec.l_err_code := SQLCODE;
        o_err_rec.l_err_msg := 'CSTPALBR.insert_ae_lines : ' || to_char(l_stmt_num) || ':'|| substr(SQLERRM,1,180);
        CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',o_err_rec.l_err_msg);
        fnd_file.put_line(fnd_file.log,o_err_rec.l_err_msg);



END insert_ae_lines;

END CSTPALBR;


/
