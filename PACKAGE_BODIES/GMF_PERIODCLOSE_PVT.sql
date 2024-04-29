--------------------------------------------------------
--  DDL for Package Body GMF_PERIODCLOSE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_PERIODCLOSE_PVT" AS
/* $Header: GMFVIAPB.pls 120.6.12010000.2 2009/04/13 07:45:49 phiriyan ship $ */
/*======================================================================+
|                Copyright (c) 2005 Oracle Corporation                  |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|   GMF_PeriodClose_PVT                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|   Period Close Private API for Process Organizations                  |
|   Generates period ending balances for process organizations          |
|                                                                       |
| HISTORY                                                               |
|                                                                       |
|   03-Jun-05 Rajesh Seshadri - Created                                 |
|   09-Apr-2009 Pramod B.H Bug 8404849                                  |
|     Modified procedure Compile_Inv_Period_Balances to ignore Non Quantity|
|     tracked subinventory txns from MMT / MTLN while rollbacking the txns.|
+======================================================================*/

/* Package Level Constants */
C_MODULE  CONSTANT VARCHAR2(80) := 'gmf.plsql.gmf_periodclose_pvt';

C_LOG_FILE CONSTANT NUMBER(1) := 1;
C_OUT_FILE CONSTANT NUMBER(1) := 2;

/* forward declarations */
PROCEDURE Log_Msg(p_file IN NUMBER, p_msg IN VARCHAR2);

PROCEDURE End_Process (
  p_errstat IN VARCHAR2,
  p_errmsg  IN VARCHAR2
  );

PROCEDURE Reset_Period_Status(
  p_organization_id IN NUMBER,
  p_acct_period_id IN NUMBER
  );


/*======================================================================
 * NAME
 *  Compile_Period_Balances
 *
 * DESCRIPTION
 *  Period Balances Concurrent Program for Process Orgs
 *
 * HISTORY
 *  03-Jun-05 Rajesh Seshadri   created.
 *
 *====================================================================*/
PROCEDURE Compile_Period_Balances (
  x_errbuf        OUT NOCOPY VARCHAR2,
  x_retcode       OUT NOCOPY VARCHAR2,
  p_organization_id        IN NUMBER,
  p_closing_acct_period_id    IN NUMBER
  )
IS

  l_log_module VARCHAR2(80);

  l_return_status VARCHAR2(1);
  l_return_msg  VARCHAR2(240);

  CURSOR c_per(p_organization_id IN NUMBER, p_acct_period_id IN NUMBER)
  IS
  SELECT
    mp.organization_code,
    UPPER(nvl(mp.process_enabled_flag,'N')) process_flag,
    oacp.period_name,
    oacp.period_close_date,
    oacp.schedule_close_date,
    oacp.open_flag
  FROM
    mtl_parameters mp,
    org_acct_periods oacp
  WHERE
    mp.organization_id = p_organization_id AND
    mp.organization_id = oacp.organization_id AND
    oacp.acct_period_id = p_acct_period_id
  ;

  l_le_schedule_close_date DATE;
  l_schedule_close_date DATE;
  l_rollback_to_date DATE;

  l_legal_entity_id NUMBER(15);

  l_organization_code VARCHAR2(3);
  l_org_process_flag VARCHAR2(1);
  l_period_name org_acct_periods.period_name%TYPE;
  l_le_period_close_date DATE;
  l_period_close_date DATE;
  l_per_open_flag VARCHAR2(1);

  e_inv_per_bal_failed EXCEPTION;

BEGIN
  SAVEPOINT s_compile_period_balances;

  l_log_module := c_module || '.Compile_Period_Balances';

  /* Uncomment to run from command line */
  -- FND_FILE.PUT_NAMES('gmfviapb.log','gmfviapb.out','/appslog/opm_top/utl/opmmodv/log');

  /* Log the parameters */
  IF( fnd_log.level_procedure >= fnd_log.g_current_runtime_level )
  THEN
    fnd_log.string(fnd_log.level_procedure, l_log_module,'Begin...');
  END IF;

  Log_Msg(C_LOG_FILE, 'Compiling Period Balances for Process Orgs.');
  Log_Msg(C_LOG_FILE, 'Parameters: Organization_id: ' || p_organization_id ||
    ' Period Id: ' || p_closing_acct_period_id );

  /*
  * Validate the parameters
  * Validate if the org is a process org
  * All prior periods must be closed
  * The current period must not be closed already
  */

  OPEN c_per(p_organization_id, p_closing_acct_period_id);
  FETCH c_per INTO
    l_organization_code, l_org_process_flag,
    l_period_name, l_le_period_close_date, l_le_schedule_close_date,
    l_per_open_flag;

  IF( c_per%NOTFOUND )
  THEN
    CLOSE c_per;
    l_return_msg := 'Error: Unable to retrieve period information';
    Log_Msg(C_LOG_FILE, l_return_msg);
    RAISE_APPLICATION_ERROR(-20101, l_return_msg);
  END IF;
  CLOSE c_per;

  IF( l_org_process_flag <> 'Y' )
  THEN
    l_return_msg := 'Error: Org is not a Process Inventory Organization';
    Log_Msg(C_LOG_FILE,l_return_msg);
    RAISE_APPLICATION_ERROR(-20102, l_return_msg);
  END IF;

  IF( l_per_open_flag = 'N' AND l_le_period_close_date IS NOT NULL )
  THEN
    l_return_msg := 'Error: period is already closed';
    Log_Msg(C_LOG_FILE,l_return_msg);
    RAISE_APPLICATION_ERROR(-20103, l_return_msg);
  END IF;

  SELECT org_information2 INTO l_legal_entity_id
  FROM hr_organization_information
  WHERE organization_id = p_organization_id
  AND  org_information_context = 'Accounting Information';

  /* Get the server date for schedule close date */
  l_schedule_close_date := inv_le_timezone_pub.get_server_day_time_for_le(
      p_le_date => l_le_schedule_close_date,
      p_le_id => l_legal_entity_id );

  l_schedule_close_date := l_schedule_close_date + 1 - 1/(24*3600);

  /* Log the dates */
  IF( fnd_log.level_statement >= fnd_log.g_current_runtime_level )
  THEN
    fnd_log.string(fnd_log.level_statement, l_log_module,
      ' Per Sched. Close Date (le):' ||
  TO_CHAR(l_le_schedule_close_date,'yyyy/mm/dd hh24:mi:ss') ||
  ' Per Sched. Close Date (db):' ||
  TO_CHAR(l_schedule_close_date,'yyyy/mm/dd hh24:mi:ss') );
  END IF;

  IF( SYSDATE <= l_schedule_close_date )
  THEN
    l_return_msg := 'Error: Period end date has not been reached';
    Log_Msg(C_LOG_FILE,l_return_msg);
    RAISE_APPLICATION_ERROR(-20105, l_return_msg);
  END IF;

  /* Bug#5652481 ANTHIYAG 09-Nov-2006 Start */
  /* if there are already some prelim rows from some prior prelim close  -- delete them*/
  DELETE FROM gmf_period_balances
       WHERE acct_period_id = p_closing_acct_period_id
          AND organization_id = p_organization_id;
  IF (SQL%NOTFOUND) THEN
         NULL;
    Log_Msg(C_LOG_FILE,'        No rows found in gmf_period_balances to delete.');
  ELSE
    Log_Msg(C_LOG_FILE,'        Deleted '||SQL%ROWCOUNT||' rows from gmf_period_balances.');
  END IF;
  /* Bug#5652481 ANTHIYAG 09-Nov-2006 End */

  Log_Msg(C_LOG_FILE,'Beginning Inventory Balance compilation for ');
  Log_Msg(C_LOG_FILE,'Organization: ' || l_organization_code || ' Period: ' ||
    l_period_name);

  Compile_Inv_Period_Balances(
    p_organization_id => p_organization_id,
    p_closing_acct_period_id => p_closing_acct_period_id,
    p_schedule_close_date => l_schedule_close_date,
    p_final_close => 1,
    x_return_status => l_return_status,
    x_return_msg => l_return_msg
    );

  IF( l_return_status <> FND_API.G_RET_STS_SUCCESS )
  THEN
    x_errbuf := l_return_msg;
    x_retcode := 2;
    RAISE e_inv_per_bal_failed;
  END IF;

  Log_Msg(C_LOG_FILE,'Inventory Balance compilation completed.');

  /* All done, update period status to Closed */
  UPDATE org_acct_periods
  SET
    open_flag = 'N',
    summarized_flag = 'Y'
  WHERE
    organization_id = p_organization_id AND
    acct_period_id = p_closing_acct_period_id;

  COMMIT;

  Log_Msg(C_LOG_FILE,'Inventory Period is closed');

  /* Set conc mgr. return status */
  x_retcode := 0;
  x_errbuf := NULL;
  End_Process('NORMAL', NULL);

  IF( fnd_log.level_procedure >= fnd_log.g_current_runtime_level )
  THEN
    fnd_log.string(fnd_log.level_procedure, l_log_module,'...End');
  END IF;

  Log_Msg(C_LOG_FILE, 'Period Balances process completed');

EXCEPTION
  WHEN e_inv_per_bal_failed THEN
    ROLLBACK TO s_compile_period_balances;
    Reset_Period_Status(p_organization_id, p_closing_acct_period_id);
    x_retcode := 2;
    x_errbuf := 'Compilation of inventory period balances failed';
    End_Process('ERROR', x_errbuf);

  WHEN others THEN
    ROLLBACK TO s_compile_period_balances;
    Reset_Period_Status(p_organization_id, p_closing_acct_period_id);
    x_retcode := 2;
    x_errbuf := SQLCODE || ' ' || SQLERRM;
    End_Process('ERROR', x_errbuf);

END Compile_Period_Balances;

/*======================================================================
 * NAME
 *  Compile_Inv_Period_Balances
 *
 * DESCRIPTION
 *  Generate Period Balances for Process Orgs
 *  Called from the period balances concurrent program above
 *
 *  Validations:
 *    Org must be a process org
 *    Current period must be open and not pending close
 *    All prior periods must also be closed for this org
 *
 *  Approach:
 *    First we get the onhand balance from MOQD
 *    Then we rollback transactions until we hit period end date
 *    Finally the balance is written to period balances table
 *    Intransit balances are also maintained for the org
 *
 * HISTORY
 *  03-Jun-05 Rajesh Seshadri   created.
 *  09-Apr-2009 Pramod B.H Bug 8404849
 *    Modified the cursor "c_txns" to ignore Non Quantity tracked
 *    subinventory txns from MMT / MTLN.
 *====================================================================*/
PROCEDURE Compile_Inv_Period_Balances (
  p_organization_id        IN NUMBER,
  p_closing_acct_period_id    IN NUMBER,
  p_schedule_close_date     IN DATE,
  p_final_close     IN NUMBER,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_return_msg  OUT NOCOPY VARCHAR2
  )
IS

  l_log_module VARCHAR2(80);
  l_rollback_to_date DATE;

  /* onhand quantities */
  CURSOR c_onhand(p_organization_id IN NUMBER)
  IS
  SELECT
    moq.organization_id,
    moq.cost_group_id,
    moq.subinventory_code,
    moq.inventory_item_id,
    moq.locator_id,
    moq.lot_number,
    SUM(moq.primary_transaction_quantity) pri_qty, /*bug 5463187*/
    SUM(NVL(moq.secondary_transaction_quantity,0)) sec_qty
  FROM
    mtl_onhand_quantities_detail moq
  WHERE
    moq.organization_id = p_organization_id AND
    moq.is_consigned = 2  /* moq does not have sec qty */
  GROUP BY
    moq.organization_id,
    moq.cost_group_id,
    moq.subinventory_code,
    moq.inventory_item_id,
    moq.locator_id,
    moq.lot_number
  ;

  r_onhand c_onhand%ROWTYPE;

  /* Txns to rollback */
  CURSOR c_txns(
    p_organization_id IN NUMBER,
    p_rollback_to_date IN DATE)
  IS
  SELECT    /* lot controlled items */
    mmt.organization_id,
    mmt.cost_group_id,
    mmt.subinventory_code,
    mmt.inventory_item_id,
    mmt.locator_id,
    mtln.lot_number,
    SUM(mtln.primary_quantity) pri_qty,
    SUM(NVL(mtln.secondary_transaction_quantity,0)) sec_qty
  FROM
    mtl_transaction_lot_numbers mtln,
    mtl_material_transactions mmt,
    MTL_SECONDARY_INVENTORIES sinv /*B8404849*/
  WHERE
    mmt.transaction_id = mtln.transaction_id AND
    mmt.organization_id = p_organization_id AND
    mmt.transaction_date > p_rollback_to_date AND
    /* Ignore consigned */
    mmt.organization_id = NVL(mmt.owning_organization_id, mmt.organization_id) AND
    NVL(mmt.owning_tp_type,2) = 2 AND
    /* Ignore Logical Txns */
    NVL(mmt.logical_transaction,-1) <> 1
    /*B8404849 - Ignore Non Quantity tracked subinventory txns - START*/
    AND sinv.organization_id = mmt.organization_id
    AND sinv.secondary_inventory_name = mmt.subinventory_code
    AND nvl(sinv.quantity_tracked,1) = 1
    /*B8404849 - Ignore Non Quantity tracked subinventory txns - End*/
    /* TBD: do we need to exclude any specific txns in process orgs */
  GROUP BY
    mmt.organization_id,
    mmt.cost_group_id,
    mmt.subinventory_code,
    mmt.inventory_item_id,
    mmt.locator_id,
    mtln.lot_number
  UNION ALL
  SELECT   /*+ INDEX(mmt mtl_material_transactions_n5) */  /* non lot controlled items */
    mmt.organization_id,
    mmt.cost_group_id,
    mmt.subinventory_code,
    mmt.inventory_item_id,
    mmt.locator_id,
    null lot_number,
    SUM(mmt.primary_quantity) pri_qty,
    SUM(NVL(mmt.secondary_transaction_quantity,0)) sec_qty
  FROM
    mtl_system_items_b msi,
    mtl_material_transactions mmt,
    MTL_SECONDARY_INVENTORIES sinv /*B8404849*/
  WHERE
    mmt.inventory_item_id = msi.inventory_item_id AND
    mmt.organization_id = msi.organization_id AND
    msi.lot_control_code = 1 AND  /* no lot control */
    mmt.organization_id = p_organization_id AND
    mmt.transaction_date > p_rollback_to_date AND
    /* Ignore consigned */
    mmt.organization_id = NVL(mmt.owning_organization_id, mmt.organization_id) AND
    NVL(mmt.owning_tp_type,2) = 2 AND
    /* Ignore Logical Txns */
    NVL(mmt.logical_transaction,-1) <> 1
    /*B8404849 - Ignore Non Quantity tracked subinventory txns - START*/
    AND sinv.organization_id = mmt.organization_id
    AND sinv.secondary_inventory_name = mmt.subinventory_code
    AND nvl(sinv.quantity_tracked,1) = 1
    /*B8404849 - Ignore Non Quantity tracked subinventory txns - End*/
    /* TBD: do we need to exclude any specific txns in process orgs */
  GROUP BY
    mmt.organization_id,
    mmt.cost_group_id,
    mmt.subinventory_code,
    mmt.inventory_item_id,
    mmt.locator_id
  ;

  r_txns c_txns%ROWTYPE;

  /* retrieve balances from temp table */
  CURSOR c_bal_tmp
  (
  p_organization_id NUMBER, /* Bug#5652481 ANTHIYAG 09-Nov-2006 */
  p_acct_period_id  NUMBER  /* Bug#5652481 ANTHIYAG 09-Nov-2006 */
  )
  IS
  SELECT
    pbt.organization_id,
    pbt.cost_group_id,
    pbt.subinventory_code,
    pbt.inventory_item_id,
    pbt.locator_id,
    pbt.lot_number,
    SUM(pbt.primary_quantity) pri_qty,
    SUM(NVL(pbt.secondary_quantity,0)) sec_qty
  FROM
    gmf_period_balances_gt pbt
  WHERE
    organization_id = p_organization_id  /* Bug#5652481 ANTHIYAG 09-Nov-2006 */
    AND acct_period_id = p_acct_period_id /* Bug#5652481 ANTHIYAG 09-Nov-2006 */
  GROUP BY
    pbt.organization_id,
    pbt.cost_group_id,
    pbt.subinventory_code,
    pbt.inventory_item_id,
    pbt.locator_id,
    pbt.lot_number
  HAVING
    ( SUM(pbt.primary_quantity) <> 0 OR
      SUM(NVL(pbt.secondary_quantity,0)) <> 0 )
  ;

BEGIN

  l_log_module := c_module || '.Compile_Inv_Period_Balances';

  /* Log the parameters */
  IF( fnd_log.level_procedure >= fnd_log.g_current_runtime_level )
  THEN
    fnd_log.string(fnd_log.level_procedure, l_log_module,'Begin...');
  END IF;

  /* Retrieve additional information */

  /* Open cursors in read only mode */
  COMMIT;
  EXECUTE IMMEDIATE 'SET TRANSACTION READ ONLY';

  OPEN c_onhand(p_organization_id);
  /* SELECT SYSDATE INTO l_rollback_to_date FROM DUAL; */
  l_rollback_to_date := p_schedule_close_date;
  OPEN c_txns(p_organization_id, l_rollback_to_date);

  COMMIT;

  SAVEPOINT s_compile_inv_period_balances;

  /* Retrieve current onhand balance and write it in temp table */
  IF( fnd_log.level_statement >= fnd_log.g_current_runtime_level )
  THEN
    fnd_log.string(fnd_log.level_statement, 'l_log_module','Inserting Onhand Balances');
  END IF;

  <<onhand_balance>>
  LOOP
    FETCH c_onhand INTO r_onhand;
    EXIT WHEN c_onhand%NOTFOUND;

    /* insert into balances table */
    INSERT INTO gmf_period_balances_gt (
      source_type_id,
      acct_period_id,
      organization_id,
      cost_group_id,
      subinventory_code,
      inventory_item_id,
      lot_number,
      locator_id,
      primary_quantity,
      secondary_quantity,
      intransit_primary_quantity,
      intransit_secondary_quantity,
      accounted_value,
      intransit_accounted_value
    )
    VALUES
    (
      1,  /* onhand */
      p_closing_acct_period_id,
      p_organization_id,
      r_onhand.cost_group_id,
      r_onhand.subinventory_code,
      r_onhand.inventory_item_id,
      r_onhand.lot_number,
      r_onhand.locator_id,
      r_onhand.pri_qty,
      r_onhand.sec_qty,
      0,  /* intransit pri qty */
      0,  /* intransit sec qty */
      0,  /* accounted_value */
      0   /* intransit accounted value */
    );

  END LOOP onhand_balance;

  /* Rollback transactions until we hit the period close date */
  IF( fnd_log.level_statement >= fnd_log.g_current_runtime_level )
  THEN
    fnd_log.string(fnd_log.level_statement, 'l_log_module','Rolling back transactions');
  END IF;

  <<mtl_transactions>>
  LOOP
    FETCH c_txns INTO r_txns;
    EXIT WHEN c_txns%NOTFOUND;

    INSERT INTO gmf_period_balances_gt (
      source_type_id,
      acct_period_id,
      organization_id,
      cost_group_id,
      subinventory_code,
      inventory_item_id,
      lot_number,
      locator_id,
      primary_quantity,
      secondary_quantity,
      intransit_primary_quantity,
      intransit_secondary_quantity,
      accounted_value,
      intransit_accounted_value
    )
    VALUES
    (
      2,  /* txns */
      p_closing_acct_period_id,
      p_organization_id,
      r_txns.cost_group_id,
      r_txns.subinventory_code,
      r_txns.inventory_item_id,
      r_txns.lot_number,
      r_txns.locator_id,
      -1 * r_txns.pri_qty,
      -1 * r_txns.sec_qty,
      0,  /* intransit pri qty */
      0,  /* intransit sec qty */
      0,  /* accounted_value */
      0   /* intransit accounted value */
    );

  END LOOP mtl_transactions;

  /* Insert/Update balances table */
  IF( fnd_log.level_statement >= fnd_log.g_current_runtime_level )
  THEN
    fnd_log.string(fnd_log.level_statement, 'l_log_module','Inserting into balances');
  END IF;

  FOR r_bal_tmp IN c_bal_tmp (p_organization_id => p_organization_id, p_acct_period_id => p_closing_acct_period_id) /* Bug#5652481 ANTHIYAG 09-Nov-2006 */
  LOOP

    INSERT INTO gmf_period_balances (
      period_balance_id,
      acct_period_id,
      organization_id,
      cost_group_id,
      subinventory_code,
      inventory_item_id,
      lot_number,
      locator_id,
      primary_quantity,
      secondary_quantity,
      intransit_primary_quantity,
      intransit_secondary_quantity,
      accounted_value,
      intransit_accounted_value,
      costed_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      period_close_status
    )
    VALUES
    (
      gmf_period_balances_s.nextval,
      p_closing_acct_period_id,
      p_organization_id,
      r_bal_tmp.cost_group_id,
      r_bal_tmp.subinventory_code,
      r_bal_tmp.inventory_item_id,
      r_bal_tmp.lot_number,
      r_bal_tmp.locator_id,
      r_bal_tmp.pri_qty,
      r_bal_tmp.sec_qty,
      0,    /* intransit pri qty */
      0,    /* intransit sec qty */
      0,    /* accounted value */
      0,    /* intransit accounted value */
      'N',  /* costed flag */
      sysdate,
      fnd_global.user_id,
      sysdate,
      fnd_global.user_id,
      fnd_global.login_id,
      fnd_global.conc_request_id,
      fnd_global.prog_appl_id,
      fnd_global.conc_program_id,
      sysdate,
      decode(p_final_close,1,'F','P')
    );

  END LOOP;

  /* commit and exit */
  COMMIT;

  x_return_status := 'S';
  x_return_msg := NULL;

  IF( fnd_log.level_procedure >= fnd_log.g_current_runtime_level )
  THEN
    fnd_log.string(fnd_log.level_procedure, 'l_log_module','...End');
  END IF;

END Compile_Inv_Period_Balances;

/*======================================================================
 * NAME
 *  Log_Msg
 *
 * DESCRIPTION
 *  Log messages to concurrent mgr log or output files
 *
 * HISTORY
 *  03-Jun-05 Rajesh Seshadri   created.
 *
 *====================================================================*/
PROCEDURE Log_Msg( p_file IN NUMBER, p_msg IN VARCHAR2)
IS

BEGIN

  IF( p_file = 2 )
  THEN
    fnd_file.put_line(fnd_file.output, p_msg);
  ELSE
    fnd_file.put_line(fnd_file.log, p_msg);
  END IF;

END Log_Msg;

/*======================================================================
 * NAME
 *  End_Process
 *
 * DESCRIPTION
 *  Log messages to concurrent mgr log or output files
 *
 * INPUT PARAMETERS
 *  p_errstat - Completion status, must be one of
 *  'NORMAL', 'WARNING', or 'ERROR'
 *  p_errmsg - Completion message to be passed back
 *
 * HISTORY
 *  03-Jun-05 Rajesh Seshadri   created.
 *
 *====================================================================*/
PROCEDURE End_Process (
  p_errstat IN VARCHAR2,
  p_errmsg  IN VARCHAR2
  )
IS
  l_retval BOOLEAN;
BEGIN

  l_retval := fnd_concurrent.set_completion_status(p_errstat,p_errmsg);

END End_Process;


/*======================================================================
 * NAME
 *  Reset_Period_Status
 *
 * DESCRIPTION
 *  Reset_Period_Status
 *
 * INPUT PARAMETERS
 * organization_id, acct_period_id
 *====================================================================*/

PROCEDURE Reset_Period_Status(
  p_organization_id IN NUMBER,
  p_acct_period_id IN NUMBER
  )
IS

BEGIN
  UPDATE org_acct_periods
  SET
    open_flag = 'Y',
    summarized_flag = NULL
  WHERE
    organization_id = p_organization_id AND
    p_acct_period_id = p_acct_period_id;

END Reset_Period_Status;



/*======================================================================
 * NAME
 *  Compile_Prelim_Period_Balances
 *
 * DESCRIPTION
 *  Close Inv period -- either prelim close or final close
 *
 * INPUT PARAMETERS
 *  legal entity id
 *  Fisacl year
 *  Fiscal Period
 *  Final Close --- Y if it is final close, N if it is Prelim Close
 *  Org Code -- can be null. If NULL close the period for all the organizations in the LE.
                 If value is passed, close the period for the entered organization.
 *
 * HISTORY
 *  19-Jun-06 Jahnavi Boppana   created.
 *
 *====================================================================*/


PROCEDURE Compile_Period_Balances_LE(
  x_errbuf        OUT NOCOPY VARCHAR2,
  x_retcode       OUT NOCOPY VARCHAR2,
  p_le_id IN NUMBER,
  p_fiscal_year IN NUMBER,
  p_fiscal_period IN NUMBER,
  p_final_close IN VARCHAR2,
  p_org_code IN VARCHAR2
  )
IS
   l_log_module VARCHAR2(80);

   l_return_status VARCHAR2(20);
   l_return_msg  VARCHAR2(240);

   l_period_set_name  VARCHAR2(15);

   l_row_count NUMBER;
   l_return_status1 NUMBER;

   l_final_close NUMBER;

   l_organization_id NUMBER;
   l_acct_period_id  NUMBER;
   l_start_date DATE;
   l_close_date DATE;

   l_proper_order                  BOOLEAN := TRUE;
   l_open_period_exists            BOOLEAN := TRUE;
   l_end_date_is_past              BOOLEAN := TRUE;
   l_prompt_to_reclose             BOOLEAN := TRUE;
   l_prior_acct_period_id          NUMBER;

   l_msg_count                     NUMBER;
   l_period_close                  VARCHAR2(1);
   l_msg_data                      VARCHAR2(30);
   l_close_failed                  BOOLEAN;
   l_period_name                   VARCHAR2(15);

   l_server_close_date               DATE;
   l_le_server_offset              NUMBER;
   l_pend_receiving                NUMBER;
   l_unproc_matl                   NUMBER;
   l_pend_matl                     NUMBER;
   l_pend_ship                     NUMBER;
   l_uncost_matl	                 NUMBER;

    l_user_id		fnd_user.user_id%TYPE;
    l_user             fnd_user.user_name%TYPE;
    l_login_id		NUMBER;
    l_prog_appl_id  	NUMBER;
    l_program_id	NUMBER;
    l_request_id	NUMBER;
    l_failed NUMBER;

   gmf_process_org_gt_failed   EXCEPTION;



   CURSOR get_process_org IS
   SELECT organization_code,
          organization_id
    FROM  gmf_process_organizations_gt
   ORDER BY organization_code;

  /* get the period to close*/
   CURSOR      cur_period_to_close(p_org_id IN NUMBER, p_year IN NUMBER, p_period IN NUMBER, p_period_set_name in varchar2)
     IS
     SELECT      acct_period_id, period_start_date start_date, schedule_close_date close_date, period_name
     FROM        ORG_ACCT_PERIODS
     WHERE       organization_id = p_org_id
     and         period_set_name = p_period_Set_name
     and         period_year = p_year
     and         period_num = p_period
     ORDER by    schedule_close_date;

BEGIN

   SAVEPOINT Compile_Period_Balances_LE;


  l_log_module := c_module || '.Compile_Period_Balances_LE';

  /* Uncomment to run from command line */
  -- FND_FILE.PUT_NAMES('gmfviapb.log','gmfviapb.out','/appslog/opm_top/utl/opmmodv/log');

  /* Log the parameters */
  IF( fnd_log.level_procedure >= fnd_log.g_current_runtime_level )
  THEN
    fnd_log.string(fnd_log.level_procedure, l_log_module,'Begin...');
  END IF;


  Log_Msg(C_LOG_FILE, 'Compiling Period Balances for Process Orgs.');
  IF  p_final_close = 'Y'
      THEN
        Log_Msg(C_LOG_FILE, 'The period is selected for final close');
      ELSE
        Log_Msg(C_LOG_FILE, 'The period is selected for preliminary close');
   END IF;

  Log_Msg(C_LOG_FILE, 'Parameters: Legal Entity_Id : '||p_le_id||' Organization_id: ' || p_org_code ||
    ' Fiscal Year: '||p_fiscal_year||' Fiscal Period: ' ||p_fiscal_period||' Final Close: '||p_final_close);


  l_failed := 0;

 IF( p_le_id IS NULL OR
      p_fiscal_year IS NULL OR
      p_fiscal_period IS NULL OR
      p_final_close IS NULL)
  THEN
    l_return_msg := 'Not all input parameters entered';
    Log_Msg(C_LOG_FILE, l_return_msg);
    RAISE_APPLICATION_ERROR(-20101, l_return_msg);
  END IF;

     l_user_id := FND_PROFILE.VALUE('USER_ID');

      SELECT user_name INTO l_user
      FROM   fnd_user
      WHERE  user_id = l_user_id;

      l_login_id      := FND_GLOBAL.LOGIN_ID;
      l_prog_appl_id  := FND_GLOBAL.PROG_APPL_ID;
      l_program_id    := FND_GLOBAL.CONC_PROGRAM_ID;
      l_request_id    := FND_GLOBAL.CONC_REQUEST_ID;


   IF  p_final_close = 'Y'
      THEN
        l_final_close := 1;
      ELSE
        l_final_close := 0;
   END IF;


  begin
    select  b.period_set_name
    into    l_period_Set_name
    from    gmf_fiscal_policies a,
            gl_ledgers b
    where   a.legal_entity_id = p_le_id
    and     b.ledger_id = a.ledger_id;
  exception
    when others then
      l_period_Set_name := NULL;
  end;

  Log_Msg(C_LOG_FILE,'Period Set Name for Legal Entity => ' ||p_le_id||' is '||l_period_Set_name);


  GMF_ORGANIZATIONS_PKG.get_process_organizations
  (
  p_Legal_Entity_id     =>        p_le_id,
  p_From_Orgn_Code      =>        p_org_code,
  p_To_Orgn_Code        =>        p_org_code,
  x_Row_Count           =>        l_row_count,
  x_Return_Status       =>        l_return_status1
  );

   IF (l_return_status1 <> 0) THEN
      RAISE gmf_process_org_gt_failed;
   END IF;


  Log_Msg(C_LOG_FILE,  'Loaded '||l_row_count||' Process Organizations for Legal Entity => ' ||p_le_id);



  FOR org_rec IN get_process_org LOOP
     SAVEPOINT Compile_Period_Balances_LE;
     l_organization_id := org_rec.organization_id;
     Log_Msg(C_LOG_FILE, 'Processing Period Close for Organization : ' || org_rec.organization_code);

     OPEN cur_period_to_close(l_organization_id, p_fiscal_year, p_fiscal_period, l_period_set_name);
     FETCH cur_period_to_close INTO l_acct_period_id,l_start_date,l_close_date, l_period_name;
     IF cur_period_to_close%notfound THEN
         Log_Msg(C_LOG_FILE, '        There is no Open/Closed Period for Organization : ' || org_rec.organization_code||
                 '. The period may be not yet opened.');
         CLOSE cur_period_to_close;
         GOTO period_close;
     END IF;
     CLOSE cur_period_to_close;
        Log_Msg(C_LOG_FILE,'        Processing Period : ' || l_period_name);

        GMF_PeriodClose_PUB.Verify_PeriodClose
        (
        p_api_version            => 1.0,
        p_org_id                 => l_organization_id,
        p_closing_acct_period_id => l_acct_period_id,
        p_closing_end_date       => l_close_date,
        x_open_period_exists     => l_open_period_exists,
        x_proper_order           => l_proper_order,
        x_end_date_is_past       => l_end_date_is_past,
        x_prompt_to_reclose      => l_prompt_to_reclose,
        x_return_status          => l_return_status
        );

        IF (NOT l_proper_order)  AND l_final_close = 1  THEN
             Log_Msg(C_LOG_FILE,'        Period ' || l_period_name ||' cannot be closed until prior open periods are closed');
             Log_Msg(C_LOG_FILE,'        Skipping closing of this period because of the above error');
             l_failed := l_failed + 1;
             GOTO period_close;
         ELSIF (NOT l_open_period_exists) THEN
             Log_Msg(C_LOG_FILE,'        Cannot close the period '|| l_period_name || '. Period is already final closed for this organization');
             Log_Msg(C_LOG_FILE,'        Skipping closing of this period because of the above error');
             l_failed := l_failed + 1;
             GOTO period_close;
         ELSIF (NOT l_end_date_is_past) THEN
             l_server_close_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE
                                  (l_close_date + .99999, p_le_id);

             l_le_server_offset := l_close_date + .99999 - l_server_close_date;

             if (l_start_date - l_le_server_offset > sysdate) then
               Log_Msg(C_LOG_FILE,'        Cannot close this period because it starts in the future.');
               Log_Msg(C_LOG_FILE,'        Skipping closing of this period because of the above error');
               l_failed := l_failed + 1;
               GOTO period_close;
             end if;
        end if;



        /* we reach here if the 1) period is not already final closed
                                2) prior periods are closed in case of final close
                                3) period doesnot start in future.*/

        IF l_final_close = 1 THEN /*check for pending transactions only for final close*/
              GMF_PeriodClose_PUB.Get_PendingTxnCount(
               p_api_version          => 1.0,
               p_org_id               => l_organization_id,
               p_closing_period       => l_acct_period_id,
               p_sched_close_date     => l_close_date,
               x_pend_receiving       => l_pend_receiving,
               x_unproc_matl          => l_unproc_matl,
               x_pend_matl            => l_pend_matl,
               x_pending_ship         => l_pend_ship,
               x_return_status        => l_return_status);

             IF l_return_status <> fnd_api.g_ret_sts_success THEN
                Log_Msg(C_LOG_FILE,'        GMF_PeriodClose_PUB.Get_PendingTxnCount failed');
                Log_Msg(C_LOG_FILE,'        Skipping closing of this period because of the above error');
                l_failed := l_failed + 1;
                GOTO period_close;
             END IF;

             IF (l_pend_receiving > 0 OR l_unproc_matl > 0 OR l_pend_matl > 0 OR l_pend_ship > 0 )  THEN
                IF l_pend_receiving > 0 THEN
                   Log_Msg(C_LOG_FILE,'        Pending receiving transactions: '||l_pend_receiving);
                END IF;
                IF l_unproc_matl > 0 THEN
                   Log_Msg(C_LOG_FILE,'        Unprocessed Material transactions: '||l_unproc_matl);
                END IF;
                IF l_pend_matl > 0 THEN
                   Log_Msg(C_LOG_FILE,'        Pending Material transactions: '||l_pend_matl);
                END IF;
                IF l_pend_ship > 0 THEN
                   Log_Msg(C_LOG_FILE,'        Pending Shipping transactions: '||l_pend_ship);
                END IF;
                Log_Msg(C_LOG_FILE,'        Skipping closing of this period because of the existing pending transactions');
                l_failed := l_failed + 1;
                GOTO period_close;
             END IF;

             INV_LOGICAL_TRANSACTIONS_PUB.Check_Accounting_Period_Close
              (
              x_return_status	      =>        l_return_status,
              x_msg_count           =>        l_msg_count,
              x_msg_data		      =>        l_msg_data,
              x_period_close	      =>        l_period_close,
              p_api_version_number  =>        1.0,
              p_init_msg_lst 	      =>        'F',
              p_organization_id	    =>        l_organization_id,
              p_org_id		          =>        null,
              p_period_start_date   =>        l_start_date,
              p_period_end_date	    =>        l_close_date
      	      );

              IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
                  Log_Msg(C_LOG_FILE,'        INV_LOGICAL_TRANSACTIONS_PUB.Check_Accounting_Period_Close failed');
                  Log_Msg(C_LOG_FILE,'        Skipping closing of this period because of the above error');
                  l_failed := l_failed + 1;
                  GOTO period_close;
              END IF;
              IF (l_period_close = 'N') THEN
                   Log_Msg(C_LOG_FILE,'        Deferred INV Logical transactions exist for Period with Start Date '||to_char(l_start_date,'dd-mon-yyyy hh24:mi:ss')||' and End Date '||to_char(l_close_date,'dd-mon-yyyy hh24:mi:ss'));
                   Log_Msg(C_LOG_FILE,'        Skipping closing of this period because of the above error');
                   l_failed := l_failed + 1;
                   GOTO period_close;
              END IF;

              /* you are here if all the checks are successful*/
             UPDATE org_acct_periods
               SET
                 open_flag               = 'P',
                 period_close_date       = trunc(sysdate),
                 last_update_date        = trunc(sysdate),
                 last_updated_by         = l_user_id,
                 last_update_login       = l_login_id
               WHERE
                 acct_period_id = l_acct_period_id AND
                 -- program level check to make sure that
                 -- the period is only closed once
                 open_flag = 'Y' AND
                 organization_id = l_organization_id AND
                 period_set_name = l_period_set_name;

               IF (SQL%NOTFOUND) THEN
                 Log_Msg(C_LOG_FILE,'        Failed Updating org_acct_periods to pending.');
                 RAISE NO_DATA_FOUND;
               END IF;

        END IF;

         /* we reach here if the 1) period is not already final closed
                                 2) prior periods are closed in case of final close
                                 3) period doesnot start in future.
                                 4) no pending txns in case of final close
                                 5) no deferred inv logical txns in case of final close.*/

        l_server_close_date := inv_le_timezone_pub.get_server_day_time_for_le(l_close_date,p_le_id);
        l_server_close_date := l_server_close_date + 1 - 1/(24*3600);

        /* Log the dates */
        Log_Msg(C_LOG_FILE,'        Per Sched. Close Date (le):' ||  TO_CHAR(l_close_date,'yyyy/mm/dd hh24:mi:ss') ||
        ' Per Sched. Close Date (db):' || TO_CHAR(l_server_close_date,'yyyy/mm/dd hh24:mi:ss') );


        /* dont check for end_daate if it is prelim close*/
        IF l_final_close = 1 THEN
           IF( SYSDATE <= l_server_close_date )
           THEN
             l_return_msg := '        Error: Period end date has not been reached';
             Log_Msg(C_LOG_FILE,l_return_msg);
             Reset_Period_Status(l_organization_id, l_acct_period_id);
             l_failed := l_failed + 1;
             GOTO period_close;
           END IF;
        END IF;

        /* if there are already some prelim rows from some prior prelim close  -- delete them*/
         DELETE FROM gmf_period_balances
               WHERE acct_period_id = l_acct_period_id
                  AND organization_id = l_organization_id;
         IF (SQL%NOTFOUND) THEN
                 NULL;
            Log_Msg(C_LOG_FILE,'        No rows found in gmf_period_balances to delete.');
         ELSE
            Log_Msg(C_LOG_FILE,'        Deleted '||SQL%ROWCOUNT||' rows from gmf_period_balances.');
         END IF;

        Log_Msg(C_LOG_FILE,'        Beginning Inventory Balance compilation for Organization: ' || org_rec.organization_code || ' Period: ' ||l_period_name);

        Compile_Inv_Period_Balances(
          p_organization_id => l_organization_id,
          p_closing_acct_period_id => l_acct_period_id,
          p_schedule_close_date => l_server_close_date,
          p_final_close => l_final_close,
          x_return_status => l_return_status,
          x_return_msg => l_return_msg
          );

        IF( l_return_status <> FND_API.G_RET_STS_SUCCESS )
        THEN
          x_errbuf := l_return_msg;
          x_retcode := 2;
          Reset_Period_Status(l_organization_id, l_acct_period_id);
          Log_Msg(C_LOG_FILE,'        Error: Compilation of inventory period balances failed');
          l_failed := l_failed + 1;
          GOTO period_close;
          /*RAISE e_inv_per_bal_failed;*/
        END IF;

        SAVEPOINT Compile_Period_Balances_LE;

        Log_Msg(C_LOG_FILE,'        Inventory Balance compilation completed.');

        /* All done, update period status to Closed */
        IF l_final_close = 1 THEN
           UPDATE org_acct_periods
           SET
             open_flag = 'N',
             summarized_flag = 'Y'
           WHERE
             organization_id = l_organization_id AND
             acct_period_id = l_acct_period_id;

           IF (SQL%NOTFOUND) THEN
                 Log_Msg(C_LOG_FILE,'        Failed Updating org_acct_periods to closed');
                 RAISE NO_DATA_FOUND;
           END IF;

        END IF;


        COMMIT;

        Log_Msg(C_LOG_FILE,'        Inventory Period is closed');
    <<period_close>>
        NULL;
  END LOOP;
        Log_Msg(C_LOG_FILE, 'Compile Period Balances LE process completed');
   /* Set conc mgr. return status */
        IF l_failed > 0 THEN /* period close for atleast one org failed*/
           x_retcode := 2;
           x_errbuf := 'Period Close process failed for one of the orgs.';
           Log_Msg(C_LOG_FILE,'Period Close process failed for one of the orgs.');
           End_Process('ERROR', x_errbuf);
        ELSE
           x_retcode := 1;
           x_errbuf := NULL;
           End_Process('NORMAL', NULL);

        END IF;





EXCEPTION
   WHEN gmf_process_org_gt_failed THEN
      ROLLBACK TO Compile_Period_Balances_LE;
      x_retcode := 2;
      x_errbuf := 'Loading gmf_process_organizations_gt failed';
      End_Process('ERROR', x_errbuf);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Compile_Period_Balances_LE;
      Reset_Period_Status(l_organization_id, l_acct_period_id);
      x_retcode := 2;
      x_errbuf := 'Unexpected error';
      End_Process('ERROR', x_errbuf);

    WHEN NO_DATA_FOUND THEN
      ROLLBACK TO Compile_Period_Balances_LE;
      Reset_Period_Status(l_organization_id, l_acct_period_id);
      x_retcode := 2;
      x_errbuf := 'No data found';
      End_Process('ERROR', x_errbuf);

  WHEN others THEN
    ROLLBACK TO Compile_Period_Balances_LE;
    Reset_Period_Status(l_organization_id, l_acct_period_id);
    x_retcode := 2;
    x_errbuf := SQLCODE || ' ' || SQLERRM;
    End_Process('ERROR', x_errbuf);

END Compile_Period_Balances_LE;


END GMF_PeriodClose_PVT;

/
