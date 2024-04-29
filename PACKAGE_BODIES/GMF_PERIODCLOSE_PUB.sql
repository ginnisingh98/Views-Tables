--------------------------------------------------------
--  DDL for Package Body GMF_PERIODCLOSE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_PERIODCLOSE_PUB" AS
/* $Header: GMFPIAPB.pls 120.6 2006/07/25 10:27:36 jboppana noship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMF_PeriodClose_PUB';
  /* Package Level Constants */
  C_MODULE  CONSTANT VARCHAR2(80) := 'gmf.plsql.gmf_periodclose_pub';

  C_LOG_FILE CONSTANT NUMBER(1) := 1;
  C_OUT_FILE CONSTANT NUMBER(1) := 2;

/* forward declarations */
PROCEDURE Log_Msg(p_file IN NUMBER, p_msg IN VARCHAR2);

  PROCEDURE Get_PendingTxnCount(
    p_api_version          IN         NUMBER,
    p_org_id               IN         INTEGER,
    p_closing_period       IN         INTEGER,
    p_sched_close_date     IN         DATE,
    x_pend_receiving       OUT NOCOPY INTEGER,
    x_unproc_matl          OUT NOCOPY INTEGER,
    x_pend_matl            OUT NOCOPY INTEGER,
    x_pending_ship         OUT NOCOPY INTEGER,
    x_return_status        OUT NOCOPY VARCHAR2
 ) IS
    l_tcount             INTEGER;
    l_in_rec_type        WSH_INTEGRATION.ShpgUnTrxdInRecType;
    l_out_rec_type       WSH_INTEGRATION.ShpgUnTrxdOutRecType;
    l_io_rec_type        WSH_INTEGRATION.ShpgUnTrxdInOutRecType;
    l_return_status      VARCHAR2(200);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(200);
    l_le_closing_fm_date DATE;
    l_sched_close_date   DATE;
    l_legal_entity       NUMBER := 0;

    l_api_name CONSTANT VARCHAR2(30) := 'Get_PendingTxnCount';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    l_stmt_num NUMBER := 0;
    l_log_module VARCHAR2(80);

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Get_PendingTcount_PUB;

     l_log_module := c_module || '.Get_PendingTxnCount';
     /* Log the parameters */
     IF( fnd_log.level_procedure >= fnd_log.g_current_runtime_level )
     THEN
      fnd_log.string(fnd_log.level_procedure, l_log_module,'Begin...');
     END IF;

     Log_Msg(C_LOG_FILE, 'Get_PendingTxnCount.');
     Log_Msg(C_LOG_FILE, 'Parameters: Api Version: ' || p_api_version||' org id :'||p_org_id ||
             ' Closing period :' ||p_closing_period||' Schedule Close date: '||
              TO_CHAR(p_sched_close_date,'yyyy/mm/dd hh24:mi:ss'));
    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call
           ( p_current_version_number => l_api_version,
             p_caller_version_number => p_api_version,
             p_api_name => l_api_name,
             p_pkg_name => G_PKG_NAME
           )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check for message level threshold
    l_msg_level_threshold := FND_PROFILE.Value('FND_AS_MSG_LEVEL_THRESHOLD');

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => SUBSTR(
                          l_stmt_num||':'||
                          p_org_id||','||
                          p_closing_period||','||
                          p_sched_close_date,
                          1,
                          240
                        )
      );
    END IF;

    l_return_status := fnd_api.g_ret_sts_success;
    l_msg_count := 0;
    l_msg_data := '';

    l_stmt_num := 5;
    SELECT org_information2
    INTO   l_legal_entity
    FROM   hr_organization_information
    WHERE  organization_id = p_org_id
/** Bug#4496452 ANTHIYAG 08-May-2006 Start **/
    AND    org_information_context = 'Accounting Information';
/** Bug#4496452 ANTHIYAG 08-May-2006 End **/

  IF( fnd_log.level_statement >= fnd_log.g_current_runtime_level )
  THEN
    fnd_log.string(fnd_log.level_statement, l_log_module,
      ' Legal Entity Id is ' ||l_legal_entity||' for organization id'||p_org_id);
  END IF;


    l_stmt_num := 7;
    l_sched_close_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                            p_sched_close_date,
                            l_legal_entity);

    l_sched_close_date := l_sched_close_date + 1 - (1/(24*3600));

    /* Log the dates */
  IF( fnd_log.level_statement >= fnd_log.g_current_runtime_level )
  THEN
    fnd_log.string(fnd_log.level_statement, l_log_module,
      ' Per Sched. Close Date (le):' ||
  TO_CHAR(p_sched_close_date,'yyyy/mm/dd hh24:mi:ss') ||
  ' Per Sched. Close Date (db):' ||
  TO_CHAR(l_sched_close_date,'yyyy/mm/dd hh24:mi:ss') );
  END IF;

    l_stmt_num := 10;
    --  Unprocessed Material transactions (must resolve)
   BEGIN
      SELECT  COUNT(*)
      INTO    l_tcount
      FROM    mtl_material_transactions_temp
      WHERE   organization_id = p_org_id
      AND     trunc(transaction_date) <= l_sched_close_date
      AND     NVL(transaction_status,0) <> 2; -- 2 indicates a save-only status

      x_unproc_matl := l_tcount;

      EXCEPTION
        when NO_DATA_FOUND then
          x_unproc_matl := 0;
        when OTHERS then
          x_unproc_matl := -1;
    END;
  IF( fnd_log.level_statement >= fnd_log.g_current_runtime_level )
  THEN
    fnd_log.string(fnd_log.level_statement, l_log_module,
      'Count of Unprocessed Material transactions: ' ||x_unproc_matl );
  END IF;


    l_stmt_num := 20;
    -- Pending shipping delivery transactions
    --   This is either "must resolve" or "optional" depending on the client
    --   extension introduced in ER 2342913.
    BEGIN

      l_stmt_num := 21;
      SELECT  period_start_date
      INTO    l_le_closing_fm_date
      FROM    org_acct_periods
      WHERE   acct_period_id = p_closing_period
      AND     organization_id = p_org_id;

      l_stmt_num := 22;
      l_in_rec_type.closing_fm_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                                         l_le_closing_fm_date,
                                         l_legal_entity);

      l_in_rec_type.api_version_number := 1.0;
      l_in_rec_type.source_code := 'GMF';
      l_in_rec_type.closing_to_date := l_sched_close_date;
      l_in_rec_type.ORGANIZATION_ID := p_org_id;

      l_stmt_num := 23;
      Log_Msg(C_LOG_FILE, 'Calling WSH_INTEGRATION.Get_Untrxd_Shpg_Lines_Count.. ');
      WSH_INTEGRATION.Get_Untrxd_Shpg_Lines_Count(
        p_in_attributes           => l_in_rec_type,
        p_out_attributes          => l_out_rec_type,
        p_inout_attributes        => l_io_rec_type,
        x_return_status           => l_return_status,
        x_msg_count               => l_msg_count,
        x_msg_data                => l_msg_data);
      Log_Msg(C_LOG_FILE, 'Completed WSH_INTEGRATION.Get_Untrxd_Shpg_Lines_Count.. ');

      IF l_return_status <> FND_API.g_ret_sts_success THEN
        x_pending_ship := -1;
      END IF;

      x_pending_ship := l_out_rec_type.untrxd_rec_count;

    END;

    l_stmt_num := 30;
    --  Unprocessed receiving transactions (optional)
    BEGIN
      SELECT  COUNT(*)
      INTO    x_pend_receiving
      FROM    rcv_transactions_interface
      WHERE   to_organization_id = p_org_id
      AND     transaction_date <= l_sched_close_date
      AND     destination_type_code = 'INVENTORY';

      EXCEPTION
        when NO_DATA_FOUND then
          x_pend_receiving := 0;
        when OTHERS then
          x_pend_receiving := -1;
    END;

    IF( fnd_log.level_statement >= fnd_log.g_current_runtime_level )
    THEN
    fnd_log.string(fnd_log.level_statement, l_log_module,
      'Count of Unprocessed receiving transactions: ' ||x_pend_receiving );
    END IF;

    l_stmt_num := 40;
    -- Pending material transactions (optional)
    --     Need to ignore Ship Confirm Open Interface detail records.
    --     these are stored in WSH_PICKING_DETAILS_INTERFACE, which is a view
    --     on MTL_TRANSACTIONS_INTERFACE filtered by process_flag = 9
    BEGIN

      SELECT  COUNT(*)
      INTO    x_pend_matl
      FROM    mtl_transactions_interface
      WHERE   organization_id = p_org_id
      AND     transaction_date <= l_sched_close_date
      AND     process_flag <> 9;

      EXCEPTION
        when NO_DATA_FOUND then
          x_pend_matl := 0;
        when OTHERS then
          x_pend_matl := -1;
    END;
    IF( fnd_log.level_statement >= fnd_log.g_current_runtime_level )
    THEN
    fnd_log.string(fnd_log.level_statement, l_log_module,
      'Count of Pending material transactions: ' ||x_pend_matl );
    END IF;
    /*
    l_stmt_num := 20;
    --  Uncosted Transactions (must resolve)
   BEGIN
      SELECT  COUNT(*)
      INTO    x_uncost_matl
      FROM    mtl_material_transactions
      WHERE   organization_id = p_org_id
      AND     transaction_date <= l_sched_close_date
      AND     costed_flag is not null;

      EXCEPTION
        when NO_DATA_FOUND then
          x_uncost_matl := 0;
        when OTHERS then
          x_uncost_matl := -1;
    END;

    l_stmt_num := 30;
    --  Pending batch resource transactions (must resolve)
    BEGIN
      SELECT  COUNT(*)
      INTO    x_uncost_rsrc_txns
      FROM    gme_resource_txns
      -- WHERE   organization_id = p_org_id
      WHERE   p_org_id = p_org_id
      AND     doc_type = 'PROD'
      AND     posted_ind != 0
      AND     completed_ind = 1
      AND     delete_mark = 0
      AND     trans_date >= l_in_rec_type.closing_fm_date
      AND     trans_date <= l_sched_close_date;

      EXCEPTION
        when NO_DATA_FOUND then
          x_uncost_rsrc_txns := 0;
        when OTHERS then
          x_uncost_rsrc_txns := -1;
    END;

    l_stmt_num := 40;
    --  Uncosted Production Batches (must resolve)
    BEGIN
      SELECT  COUNT(*)
      INTO    x_uncost_prod_batches
      FROM    gme_batch_header
      -- WHERE   organization_id = p_org_id
      WHERE   p_org_id = p_org_id
      AND     gl_posted_ind != 0
      AND     delete_mark = 0
      AND     actual_cmplt_date >= l_in_rec_type.closing_fm_date
      AND     actual_cmplt_date <= l_sched_close_date;

      EXCEPTION
        when NO_DATA_FOUND then
          x_uncost_prod_batches := 0;
        when OTHERS then
          x_uncost_prod_batches := -1;
    END;
    */
  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_PendingTcount_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      ROLLBACK TO Get_PendingTcount_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||SUBSTR(SQLERRM,1,235)
        );
      END IF;

  END Get_PendingTxnCount;

  PROCEDURE Verify_PeriodClose(
    p_api_version             IN            NUMBER,
    p_org_id                  IN            NUMBER,
    p_closing_acct_period_id  IN            NUMBER,
    p_closing_end_date        IN            DATE,
    x_open_period_exists      OUT NOCOPY    BOOLEAN,
    x_proper_order            OUT NOCOPY    BOOLEAN,
    x_end_date_is_past        OUT NOCOPY    BOOLEAN,
    x_prompt_to_reclose       OUT NOCOPY    BOOLEAN,
    x_return_status           OUT NOCOPY    VARCHAR2
  ) IS

    l_temp_id         NUMBER;
    l_le_sysdate      DATE := NULL;
    l_operating_unit  NUMBER := 0;
    l_log_module VARCHAR2(80);

    --  Finds whether there are any prior open periods
    CURSOR get_prior_open_period IS
      SELECT acct_period_id
      FROM   org_acct_periods
      WHERE  organization_id = p_org_id
      AND    schedule_close_date = (SELECT MIN(oap1.schedule_close_date)
                                    FROM org_acct_periods oap1, org_acct_periods oap2
                                    WHERE
                                         oap1.organization_id = p_org_id
                                     AND (oap1.open_flag = 'Y' or oap1.open_flag = 'P')
                                     and oap2.organization_id = oap1.organization_id
                                     and oap1.schedule_close_date < oap2.schedule_close_date
                                     and oap2.acct_period_id = p_closing_acct_period_id);


    -- Finds whether the period is closed or not
    CURSOR check_current_period_open IS
       SELECT acct_period_id
       FROM   org_acct_periods
       WHERE  organization_id = p_org_id
         AND  acct_period_id = p_closing_acct_period_id
         AND  (open_flag = 'Y' or open_flag = 'P');


    --  Finds the next period in org_acct_periods
   /* CURSOR get_next_open_period IS
      SELECT MIN(acct_period_id)
      FROM   org_acct_periods
      WHERE  organization_id = p_org_id
      AND    acct_period_id  > p_closing_acct_period_id;

    /* INVCONV
    --  Checks if period is already in process of GL transfer
    CURSOR get_download_in_process IS
      SELECT acct_period_id
      FROM   org_gl_batches
      WHERE  organization_id = p_org_id
      AND    gl_batch_id     = 0;
    */

    --  Checks if period is already in process of closing
    /* rseshadr - Enabled the check below */
    CURSOR check_reclose_period IS
      SELECT acct_period_id
      FROM   org_acct_periods
      WHERE  organization_id = p_org_id
      AND    acct_period_id  = p_closing_acct_period_id
      AND    period_close_date IS NOT NULL
      AND    open_flag = 'P';

    l_api_name CONSTANT VARCHAR2(30) := 'Verify_PeriodClose';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    l_stmt_num NUMBER := 0;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Verify_PeriodClose_PUB;
    l_log_module := c_module || '.Verify_PeriodClose';
    Log_Msg(C_LOG_FILE, 'Verify_PeriodClose.');
     Log_Msg(C_LOG_FILE, 'Parameters: Api Version: ' || p_api_version||' org id :'||p_org_id ||
             ' Closing Acct period :' ||p_closing_acct_period_id||' Closing End date: '||
              TO_CHAR(p_closing_end_date ,'yyyy/mm/dd hh24:mi:ss'));
    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call
           ( p_current_version_number => l_api_version,
             p_caller_version_number => p_api_version,
             p_api_name => l_api_name,
             p_pkg_name => G_PKG_NAME
           )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check for message level threshold
    l_msg_level_threshold := FND_PROFILE.Value('FND_AS_MSG_LEVEL_THRESHOLD');

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => SUBSTR(
                          l_stmt_num||':'||
                          p_org_id||','||
                          p_closing_acct_period_id||','||
                          p_closing_end_date,
                          1,
                          240
                        )
      );
    END IF;

    l_stmt_num := 10;

    OPEN  get_prior_open_period;
    FETCH get_prior_open_period
    INTO  l_temp_id;

    IF get_prior_open_period%FOUND THEN
      x_proper_order := FALSE;
      CLOSE get_prior_open_period;
      GOTO procedure_end;
    ELSE
      x_proper_order := TRUE;
    END IF;


    CLOSE get_prior_open_period;

    l_stmt_num := 20;
    --  Check that the next period is open
    OPEN  check_current_period_open;
    FETCH check_current_period_open
    INTO  l_temp_id;

    IF check_current_period_open%FOUND THEN
      x_open_period_exists := TRUE;
    ELSE
      x_open_period_exists := FALSE;
      CLOSE check_current_period_open;
      GOTO procedure_end;
    END IF;

    CLOSE check_current_period_open;

    --  Check that the period's end date is < today,
    --  adjusting for LE timezone.
    l_stmt_num := 23;

       SELECT org_information3
       INTO   l_operating_unit
       FROM   hr_organization_information
       WHERE  organization_id = p_org_id
       AND    org_information_context = 'Accounting Information';




   IF( fnd_log.level_statement >= fnd_log.g_current_runtime_level )
  THEN
    fnd_log.string(fnd_log.level_statement, l_log_module,
      ' Operating Unit is ' ||l_operating_unit||' for organization id'||p_org_id);
  END IF;
    l_stmt_num := 25;
    l_le_sysdate := INV_LE_TIMEZONE_PUB.GET_LE_SYSDATE_FOR_OU(
                      l_operating_unit);

    l_stmt_num := 27;
    IF (p_closing_end_date < l_le_sysdate) THEN
      x_end_date_is_past := TRUE;
    ELSE
      x_end_date_is_past := FALSE;
      GOTO procedure_end;
    END IF;

    /* rseshadr - Added the check below */
    l_stmt_num := 40;
    --  See if this period is already processing. If so, prompt to reclose.
    x_prompt_to_reclose := FALSE;

    OPEN  check_reclose_period;
    FETCH check_reclose_period
    INTO  l_temp_id;

    IF check_reclose_period%FOUND THEN
      x_prompt_to_reclose := TRUE;
    ELSE
      x_prompt_to_reclose := FALSE;
    END IF;

    CLOSE check_reclose_period;
    <<procedure_end >>
      NULL;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Verify_PeriodClose_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      ROLLBACK TO Verify_PeriodClose_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||SUBSTR(SQLERRM,1,235)
        );
      END IF;

  END Verify_PeriodClose;

  PROCEDURE Close_Period(
    p_api_version            IN            NUMBER,
    p_org_id                 IN            NUMBER,
    p_user_id                IN            NUMBER,
    p_login_id               IN            NUMBER,
    p_closing_acct_period_id IN            NUMBER,
    p_period_close_date      IN            DATE,
    p_schedule_close_date    IN            DATE,
    x_close_failed           OUT NOCOPY    BOOLEAN,
    x_return_status          OUT NOCOPY    VARCHAR2,
    x_req_id                 OUT NOCOPY    NUMBER
  ) IS

    l_err_msg       VARCHAR2(80);
    l_indust        VARCHAR2(10);
    l_wip_installed BOOLEAN;
    l_installation  VARCHAR2(10);
    l_return_code   NUMBER;

    l_api_name CONSTANT VARCHAR2(30) := 'Close_Period';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    l_stmt_num NUMBER := 0;

    l_req_id NUMBER := 0;
    l_current_period_status  VARCHAR2(1);

    /* rseshadr */
    e_perbal_failed EXCEPTION;

    l_log_module VARCHAR2(80);


  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Close_Period_PUB;
    l_log_module := c_module || '.Close_Period';
    Log_Msg(C_LOG_FILE, 'Verify_PeriodClose.');
    Log_Msg(C_LOG_FILE, 'Parameters: Api Version: ' || p_api_version||' org id :'||p_org_id ||
             ' User id: '||p_user_id||' Org Id :' ||p_org_id||' Closing Acct period :' ||p_closing_acct_period_id||' Period Close date: '||
              TO_CHAR(p_period_close_date ,'yyyy/mm/dd hh24:mi:ss')||' Schedule Close date: '||
              TO_CHAR(p_schedule_close_date ,'yyyy/mm/dd hh24:mi:ss'));

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call
           ( p_current_version_number => l_api_version,
             p_caller_version_number => p_api_version,
             p_api_name => l_api_name,
             p_pkg_name => G_PKG_NAME
           )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check for message level threshold
    l_msg_level_threshold := FND_PROFILE.Value('FND_AS_MSG_LEVEL_THRESHOLD');

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => SUBSTR(
                          l_stmt_num||':'||
                          p_org_id||','||
                          p_user_id||','||
                          p_login_id||','||
                          p_closing_acct_period_id||','||
                          p_period_close_date||','||
                          p_schedule_close_date||','||
                          1,
                          240
                        )
      );
    END IF;

    l_stmt_num := 5;
    --  Update period status to processing
    /**
    * rseshadr - Set status to Processing
    * The period will be set to Closed once
    * balances are compiled
    **/
    UPDATE org_acct_periods
    SET
      open_flag               = 'P',
      period_close_date       = trunc(sysdate),
      last_update_date        = trunc(sysdate),
      last_updated_by         = p_user_id,
      last_update_login       = p_login_id
    WHERE
      acct_period_id = p_closing_acct_period_id AND
      -- program level check to make sure that
      -- the period is only closed once
      open_flag = 'Y' AND
      organization_id = p_org_id
    ;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    --
    -- we can submit the SLA accouting program for this org
    --
    /**
    * rseshadr - Submit the period balance program
    **/
    l_req_id := fnd_request.submit_request(
      application => 'GMF',
      program => 'GMFPBAL',
      description => NULL,
      start_time => NULL,
      sub_request => NULL,
      argument1 => p_org_id,
      argument2 => p_closing_acct_period_id
      );

    IF( l_req_id = 0 )
    THEN
      x_close_failed := TRUE;
      RAISE e_perbal_failed;
    END IF;

    x_req_id := l_req_id;

    COMMIT;

  EXCEPTION
    WHEN e_perbal_failed THEN
      /* rseshadr */
      ROLLBACK TO Close_Period_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_close_failed := TRUE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Close_Period_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_close_failed := TRUE;

    WHEN NO_DATA_FOUND THEN
      ROLLBACK TO Close_Period_PUB;
      x_close_failed := TRUE;

    WHEN OTHERS THEN
      ROLLBACK TO Close_Period_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_close_failed := TRUE;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||SUBSTR(SQLERRM,1,235)
        );
      END IF;

  END Close_Period;

  /*****************************************************************************
   *  Procedure
   *    get_prev_inv_period_status
   *
   *  DESCRIPTION
   *    Based on current OPM period end date, get prior Inventory Calendar and Period.
   *    Also, set x_close_status to TRUE if period is closed for all inv. orgs.
   *
   *    Is getting called in
   *    1. CMACPED.fmb and
   *    2. SLA Accounting Pre-Processor Submission screen and wrapper.
   *
   *  HISTORY
   *    15-Nov-2005 Uday Moogala    - Created
   ******************************************************************************/
  PROCEDURE get_prev_inv_period_status(
    p_legal_entity_id        IN            VARCHAR2,
    p_cost_type_id           IN            VARCHAR2,
    p_period_end_date        IN            DATE,
    x_close_status           OUT NOCOPY    BOOLEAN,
    x_inv_period_year        OUT NOCOPY    NUMBER,
    x_inv_period_num         OUT NOCOPY    NUMBER,
    x_return_status          OUT NOCOPY    VARCHAR2,
    x_errbuf                 OUT NOCOPY    VARCHAR2
  )
  IS

    CURSOR c_get_prev_period_end_date (
        cp_le_id        VARCHAR2,
        cp_ct_id        VARCHAR2,
        cp_end_date     DATE
      )
    IS
      SELECT gps.period_id
        FROM gmf_period_statuses gps
       WHERE gps.legal_entity_id  = cp_le_id
         AND gps.cost_type_id     = cp_ct_id
         AND gps.end_date         = cp_end_date
       ORDER BY gps.end_date desc
    ;

    l_prev_period_id    gmf_period_statuses.period_id%TYPE;
    l_open_periods_cnt  BINARY_INTEGER;

  BEGIN

    x_return_status := 'S';


    --
    -- First get prior period id based on the current
    -- LE, CT and Period End Date
    --
    OPEN c_get_prev_period_end_date(p_legal_entity_id, p_cost_type_id, p_period_end_date);
    FETCH c_get_prev_period_end_date INTO l_prev_period_id;
    CLOSE c_get_prev_period_end_date;

    IF l_prev_period_id IS NULL
    THEN
      x_return_status := 'E';
      x_errbuf        := 'No Prior Period for Legal Entity, Cost Type and Period End Date combination';
      RETURN;
    END IF;

    --
    -- Now using OPM's Prior Period, get the Inventory Period Year and Number.
    --
    SELECT oap.period_year, oap.period_num
      INTO x_inv_period_year, x_inv_period_num
      FROM org_acct_periods oap,
           gmf_period_statuses gps,
           hr_organization_information hoi
     WHERE gps.period_id           = l_prev_period_id
       AND gps.legal_entity_id     = hoi.org_information2
       AND hoi.org_information_context = 'Accounting Information'
       AND oap.organization_id     = hoi.organization_id
       AND oap.schedule_close_date =  TRUNC(gps.end_date)
       AND rownum = 1
    ;

    --
    -- Now see whether period is closed for all Process Orgs.
    --
    SELECT SUM(decode(open_flag,'Y',1,'P',1, 0))
      INTO l_open_periods_cnt
      FROM org_acct_periods oap,
           mtl_parameters mp,
           hr_organization_information hoi
     WHERE hoi.org_information2     = p_legal_entity_id
       AND hoi.org_information_context = 'Accounting Information'
       AND hoi.organization_id      = oap.organization_id
       AND hoi.organization_id      = mp.organization_id
       AND mp.process_enabled_flag  = 'Y'
       AND oap.period_year          = x_inv_period_year
       AND oap.period_num           = x_inv_period_num
       AND oap.schedule_close_date  = TRUNC(p_period_end_date)
    ;

    IF l_open_periods_cnt > 0
    THEN
      x_close_status := FALSE;
    ELSE
      x_close_status := TRUE;
    END IF;


  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      x_return_status := 'E';
      x_errbuf        := 'No Inventory Prior Period found for Legal Entity, Cost Type and Period End Date combination';
  END get_prev_inv_period_status;

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

END GMF_PeriodClose_PUB;

/
