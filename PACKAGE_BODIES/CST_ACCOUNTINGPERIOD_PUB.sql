--------------------------------------------------------
--  DDL for Package Body CST_ACCOUNTINGPERIOD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_ACCOUNTINGPERIOD_PUB" AS
/* $Header: CSTPAPEB.pls 120.9.12010000.8 2008/12/16 20:54:42 hyu ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_AccountingPeriod_PUB';

  PROCEDURE Get_PendingTcount(
    p_api_version          IN         NUMBER,
    p_org_id               IN         INTEGER,
    p_closing_period       IN         INTEGER,
    p_sched_close_date     IN         DATE,
    x_pend_receiving       OUT NOCOPY INTEGER,
    x_unproc_matl          OUT NOCOPY INTEGER,
    x_pend_matl            OUT NOCOPY INTEGER,
    x_uncost_matl          OUT NOCOPY INTEGER,
    x_pend_move            OUT NOCOPY INTEGER,
    x_pend_wip_cost        OUT NOCOPY INTEGER,
    x_uncost_wsm           OUT NOCOPY INTEGER,
    x_pending_wsm          OUT NOCOPY INTEGER,
    x_pending_ship         OUT NOCOPY INTEGER,
    /* Support for LCM */
    x_pending_lcm          OUT NOCOPY INTEGER,
    x_released_work_orders OUT NOCOPY INTEGER,
    x_return_status        OUT NOCOPY VARCHAR2
  ) IS
    l_tcount             INTEGER;
    l_eam_enabled        VARCHAR2(1);
    l_lcm_enabled        VARCHAR2(1); /* Support for LCM */
    l_in_rec_type        WSH_INTEGRATION.ShpgUnTrxdInRecType;
    l_out_rec_type       WSH_INTEGRATION.ShpgUnTrxdOutRecType;
    l_io_rec_type        WSH_INTEGRATION.ShpgUnTrxdInOutRecType;
    l_return_status      VARCHAR2(200);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(200);
    l_le_closing_fm_date DATE;
    l_sched_close_date   DATE;
    l_legal_entity       NUMBER := 0;

    l_api_name CONSTANT VARCHAR2(30) := 'Get_PendingTcount';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    l_stmt_num NUMBER := 0;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Get_PendingTcount_PUB;

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
    SELECT legal_entity
    INTO   l_legal_entity
    FROM   cst_acct_info_v
    WHERE  organization_id = p_org_id;

    l_stmt_num := 7;
    l_sched_close_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                            p_sched_close_date,
                            l_legal_entity);

    l_sched_close_date := l_sched_close_date + 1 - (1/(24*3600));

    l_stmt_num := 10;
    --  Unprocessed Material transactions (must resolve)
   BEGIN
      SELECT  COUNT(*)
      INTO    l_tcount
      FROM    mtl_material_transactions_temp
      WHERE   organization_id = p_org_id
      AND     transaction_date <= l_sched_close_date
      AND     NVL(transaction_status,0) <> 2; -- 2 indicates a save-only status

      x_unproc_matl := l_tcount;

      EXCEPTION
        when NO_DATA_FOUND then
          x_unproc_matl := 0;
        when OTHERS then
          x_unproc_matl := -1;
    END;

    l_stmt_num := 20;
    --  Uncosted Transactions (must resolve)
   BEGIN
      SELECT  /*+ INDEX (MMT MTL_MATERIAL_TRANSACTIONS_N10) */
              COUNT(*)
      INTO    l_tcount
      FROM    mtl_material_transactions MMT
      WHERE   organization_id = p_org_id
      AND     transaction_date <= l_sched_close_date
      AND     costed_flag is not null;

      x_uncost_matl := l_tcount;

      EXCEPTION
        when NO_DATA_FOUND then
          x_uncost_matl := 0;
        when OTHERS then
          x_uncost_matl := -1;
    END;

    l_stmt_num := 30;
    --  Pending WIP costing transactions (must resolve)
    BEGIN
      SELECT  COUNT(*)
      INTO    l_tcount
      FROM    wip_cost_txn_interface
      WHERE   organization_id = p_org_id
      AND     transaction_date <= l_sched_close_date;

      x_pend_wip_cost := l_tcount;

      EXCEPTION
        when NO_DATA_FOUND then
          x_pend_wip_cost := 0;
        when OTHERS then
          x_pend_wip_cost := -1;
    END;

    l_stmt_num := 40;
    --  Uncosted WSM transactions (must resolve)
    /*  Bug# 3926917: Period Close Diagnostics Project
        Uncosted WSM transactions are available in MMT from 11.5.9
        Hence need not be looked up separately. */

    x_uncost_wsm := 0;

    --  Pending WSM interface transactions (must resolve)
    /*  Bug# 3926917: Period Close Diagnostics Project
        Added check on two new interface tables wsm_lot_move_txn_interface
        And wsm_lot_split_merges_interface */

    BEGIN

      l_stmt_num := 50;
      -- Pending Split Merge Transactions interface

      SELECT  COUNT(*)
      INTO    l_tcount
      FROM    wsm_split_merge_txn_interface
      WHERE   organization_id = p_org_id
      AND     process_status <> wip_constants.completed
      AND     transaction_date <= l_sched_close_date;

      x_pending_wsm  := l_tcount;

      l_stmt_num := 52;
      -- Pending Lot Move Transactions Interface

      SELECT  COUNT(*)
      INTO    l_tcount
      FROM    wsm_lot_move_txn_interface
      WHERE   organization_id = p_org_id
      AND     status <> wip_constants.completed
      AND     transaction_date <= l_sched_close_date;

      x_pending_wsm  := x_pending_wsm + l_tcount;

      l_stmt_num := 55;
      -- Pending Lot Split Merges Interface

      SELECT  COUNT(*)
      INTO    l_tcount
      FROM    wsm_lot_split_merges_interface
      WHERE   organization_id = p_org_id
      AND     process_status <> wip_constants.completed
      AND     transaction_date <= l_sched_close_date;

      x_pending_wsm  := x_pending_wsm + l_tcount;

      EXCEPTION
        when NO_DATA_FOUND then
          x_pending_wsm  := 0;
        when OTHERS then
          x_pending_wsm  := -1;
    END;

    l_stmt_num := 60;
    -- Pending shipping delivery transactions
    --   This is either "must resolve" or "optional" depending on the client
    --   extension introduced in ER 2342913.
    BEGIN

      l_stmt_num := 63;
      SELECT  period_start_date
      INTO    l_le_closing_fm_date
      FROM    org_acct_periods
      WHERE   acct_period_id = p_closing_period
      AND     organization_id = p_org_id;

      l_stmt_num := 65;
      l_in_rec_type.closing_fm_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                                         l_le_closing_fm_date,
                                         l_legal_entity);

      l_in_rec_type.api_version_number := 1.0;
      l_in_rec_type.source_code := 'CST';
      l_in_rec_type.closing_to_date := l_sched_close_date;
      l_in_rec_type.ORGANIZATION_ID := p_org_id;

      l_stmt_num := 67;
      WSH_INTEGRATION.Get_Untrxd_Shpg_Lines_Count(
        p_in_attributes           => l_in_rec_type,
        p_out_attributes          => l_out_rec_type,
        p_inout_attributes        => l_io_rec_type,
        x_return_status           => l_return_status,
        x_msg_count               => l_msg_count,
        x_msg_data                => l_msg_data);

      IF l_return_status <> FND_API.g_ret_sts_success THEN
        x_pending_ship := -1;
      END IF;

      x_pending_ship := l_out_rec_type.untrxd_rec_count + l_out_rec_type.receiving_rec_count;

    END;

    l_stmt_num := 70;
    --  Unprocessed receiving transactions (optional)
    BEGIN
      SELECT  COUNT(*)
      INTO    l_tcount
      FROM    rcv_transactions_interface
      WHERE   to_organization_id = p_org_id
      AND     transaction_date <= l_sched_close_date
      AND     destination_type_code in ('INVENTORY','SHOP FLOOR');

      x_pend_receiving := l_tcount;

      EXCEPTION
        when NO_DATA_FOUND then
          x_pend_receiving := 0;
        when OTHERS then
          x_pend_receiving := -1;
    END;

    l_stmt_num := 80;
    -- Pending material transactions (optional)
    --     Need to ignore Ship Confirm Open Interface detail records.
    --     these are stored in WSH_PICKING_DETAILS_INTERFACE, which is a view
    --     on MTL_TRANSACTIONS_INTERFACE filtered by process_flag = 9
    BEGIN

      SELECT  COUNT(*)
      INTO    l_tcount
      FROM    mtl_transactions_interface
      WHERE   organization_id = p_org_id
      AND     transaction_date <= l_sched_close_date
      AND      process_flag <> 9;

      x_pend_matl := l_tcount;

      EXCEPTION
        when NO_DATA_FOUND then
          x_pend_matl := 0;
        when OTHERS then
          x_pend_matl := -1;
    END;

    l_stmt_num := 90;
    --  Pending shop floor move transactions (optional)
    BEGIN
      SELECT  COUNT(*)
      INTO    l_tcount
      FROM    wip_move_txn_interface
      WHERE   organization_id = p_org_id
      AND     transaction_date <= l_sched_close_date;

      x_pend_move  := l_tcount;

      EXCEPTION
        when NO_DATA_FOUND then
          x_pend_move  := 0;
        when OTHERS then
          x_pend_move  := -1;
    END;

    l_stmt_num := 100;
    --  Released EAM work orders (optional)
    BEGIN
      SELECT NVL(eam_enabled_flag, 'N'), NVL(lcm_enabled_flag, 'N')  /* Support for LCM */
      INTO   l_eam_enabled, l_lcm_enabled
      FROM   mtl_parameters
      WHERE  organization_id = p_org_id;

      IF (l_eam_enabled = 'Y') THEN
        SELECT count(*)
        INTO   l_tcount
        FROM   wip_discrete_jobs WDJ, wip_entities WE
        WHERE  WDJ.organization_id            = p_org_id
        AND    WDJ.scheduled_completion_date <= p_sched_close_date
        AND    WDJ.status_type                = 3  -- Released
        AND    WDJ.wip_entity_id              = WE.wip_entity_id
        AND    WDJ.organization_id            = WE.organization_id
        AND    WE.entity_type                 = 6; -- Maintenance Work Order
      ELSE
        l_tcount := 0;
      END IF;

      x_released_work_orders := l_tcount;

    END;


    /* Support for Landed Cost Management: Pending landed cost adjustment transactions */
    IF l_lcm_enabled = 'Y' THEN

      l_stmt_num := 110;
      SELECT  COUNT(*)
      INTO    l_tcount
      FROM    cst_lc_adj_interface
      WHERE   organization_id = p_org_id
      AND     transaction_date <= l_sched_close_date;

      x_pending_lcm  := l_tcount;

    ELSE
      x_pending_lcm  := 0;

    END IF;

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

  END Get_PendingTcount;



  PROCEDURE Open_Period(
    p_api_version               IN            NUMBER,
    p_org_id                    IN            NUMBER,
    p_user_id                   IN            NUMBER,
    p_login_id                  IN            NUMBER,
    p_acct_period_type          IN            VARCHAR2,
    p_org_period_set_name       IN            VARCHAR2,
    p_open_period_name          IN            VARCHAR2,
    p_open_period_year          IN            NUMBER,
    p_open_period_num           IN            NUMBER,
    x_last_scheduled_close_date IN OUT NOCOPY DATE,
    p_period_end_date           IN            DATE,
    x_prior_period_open         OUT NOCOPY    BOOLEAN,
    x_new_acct_period_id        IN OUT NOCOPY NUMBER,
    x_duplicate_open_period     OUT NOCOPY    BOOLEAN,
    x_commit_complete           OUT NOCOPY    BOOLEAN,
    x_return_status             OUT NOCOPY    VARCHAR2
  ) IS

    l_period_count       INTEGER;
    l_dummy_period_start DATE;
    l_first_period       INTEGER;
    l_err_msg            VARCHAR2(80);
    l_indust             VARCHAR2(10);
    l_return_code        NUMBER;
    l_wip_installed      BOOLEAN;
    l_installation       VARCHAR2(10);

    --  Retrieve close date of last open period
    CURSOR get_last_close_date IS
      SELECT  NVL(MAX(schedule_close_date), sysdate),
              count(*)
      FROM    org_acct_periods
      WHERE   organization_id = p_org_id;

    -- Check that there is no period prior to one we are trying to open
    -- that is in GL_PERIODS but not open (i.e. not in ORG_ACCT_PERIODS)
    -- A status of %NOTFOUND indicates it is okay to open the next period.
    CURSOR check_prior_open_period IS
      SELECT  start_date
      FROM    gl_periods
      WHERE   end_date < p_period_end_date
      AND     end_date >= x_last_scheduled_close_date
      AND     (period_name, period_year) not in
                (select period_name, period_year
                 from org_acct_periods
                 where organization_id = p_org_id)
      AND     period_type = p_acct_period_type
      AND     period_set_name = p_org_period_set_name
      AND     adjustment_period_flag = 'N';

    --  Get next period id
    CURSOR get_new_period_id IS
      SELECT  org_acct_periods_s.nextval
      FROM    sys.dual;

    --  See if another open period process has already committed same data
    CURSOR check_if_duplicating IS
      SELECT  period_start_date
      FROM    org_acct_periods
      WHERE   organization_id = p_org_id
      AND     period_name = p_open_period_name
      AND     period_year = p_open_period_year
      AND     period_num  = p_open_period_num
      AND     acct_period_id <> x_new_acct_period_id;

    --BUG#5903883
    CURSOR c_org_acct_unique IS
      SELECT NULL
      FROM   org_acct_periods
      WHERE  organization_id = p_org_id
      AND    period_year     = p_open_period_year
      AND    period_name     = p_open_period_name
      AND    period_num      = p_open_period_num;

    l_test     VARCHAR2(1);



    l_api_name CONSTANT VARCHAR2(30) := 'Open_Period';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    l_stmt_num NUMBER := 0;

    org_acct_periods_u2   EXCEPTION;
    PRAGMA EXCEPTION_INIT(org_acct_periods_u2,-1);

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Open_Period_PUB;

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
                          p_acct_period_type||','||
                          p_org_period_set_name||','||
                          p_open_period_name||','||
                          p_open_period_year||','||
                          p_open_period_num||','||
                          p_period_end_date,
                          1,
                          240
                        )
      );
    END IF;

    x_commit_complete       := FALSE;
    x_duplicate_open_period := FALSE;

    l_stmt_num := 10;
    -- Get the close date of the last open period, as well as
    -- the period_id of the next period to open, unless this is
    -- the first period opened
    OPEN  get_last_close_date;
    FETCH get_last_close_date
    INTO  x_last_scheduled_close_date, l_period_count;

    IF l_period_count = 0 THEN
      l_first_period := 1;
    ELSE
      l_first_period := 0;
    END IF;

    CLOSE get_last_close_date;

    l_stmt_num := 20;
    --  Verify that the prior period is open
    OPEN  check_prior_open_period;
    FETCH check_prior_open_period
    INTO  l_dummy_period_start;

    IF check_prior_open_period%NOTFOUND THEN
      x_prior_period_open := TRUE;
    ELSE
      x_prior_period_open := FALSE;
      GOTO procedure_end;
    END IF;
    CLOSE check_prior_open_period;

    l_stmt_num := 30;
    --  Get the next available period_id for the new opened period
    OPEN  get_new_period_id;
    FETCH get_new_period_id
    INTO  x_new_acct_period_id;

    IF get_new_period_id%NOTFOUND THEN
      x_new_acct_period_id := 0;
      GOTO procedure_end;
    END IF;

    CLOSE get_new_period_id;




    --{BUG#5903883
    OPEN c_org_acct_unique;
    FETCH c_org_acct_unique INTO l_test;
    IF c_org_acct_unique%FOUND THEN
        FND_MESSAGE.SET_NAME('FND','FORM_RECORD_CHANGED');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE c_org_acct_unique;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    --}



    l_stmt_num := 40;
    --  Insert record into org_acct_periods to open the period
    INSERT INTO org_acct_periods
     (acct_period_id,
      organization_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      period_set_name,
      period_year,
      period_num,
      period_name,
      description,
      period_start_date,
      schedule_close_date,
      open_flag,
      last_update_login)
    SELECT
      x_new_acct_period_id, -- acct_period_id
      p_org_id,             -- organization_id
      SYSDATE,              -- last_update_date
      p_user_id,            -- last_updated_by
      SYSDATE,              -- creation_date
      p_user_id,            -- created_by
      GLP.period_set_name,  -- period_set_name
      GLP.period_year,      -- period_year
      GLP.period_num,       -- period_num
      GLP.period_name,      -- period_name
      GLP.description,      -- description

      -- period_start_date
      decode(l_first_period,
             1, GLP.start_date,
             x_last_scheduled_close_date+1),

      GLP.end_date,         -- schedule_close_date
      'Y',                  -- open_flag
      -1                    -- last_update_login
    FROM  gl_periods GLP
    WHERE GLP.period_set_name = p_org_period_set_name
    AND   GLP.period_name     = p_open_period_name
    AND   GLP.period_type     = p_acct_period_type
    AND   GLP.adjustment_period_flag = 'N'
    AND  (GLP.period_name, GLP.period_year)
      NOT IN
       (SELECT period_name, period_year
        FROM   org_acct_periods
        WHERE  organization_id = p_org_id)
    AND NOT EXISTS
     (SELECT period_start_date
      FROM   org_acct_periods
      WHERE  organization_id = p_org_id
      AND    period_year     = p_open_period_year
      AND    period_name     = p_open_period_name
      AND    period_num      = p_open_period_num);

    l_stmt_num := 50;
    --  Update WIP costing if WIP is installed

    l_wip_installed := fnd_installation.get(appl_id     => 706,
                                          dep_appl_id => 706,
                                          status      => l_installation,
                                          industry    => l_indust);

    IF (l_wip_installed) THEN
      l_return_code := CSTPCWPB.WIPCBR( p_org_id,
                                        p_user_id,
                                        p_login_id,
                                        x_new_acct_period_id,
                                        l_err_msg);
    ELSE
      l_return_code := 0;
    END IF;

    IF (l_return_code <> 0) THEN
      l_err_msg := l_return_code || l_err_msg;
      GOTO error_label;
    END IF;

    l_stmt_num := 60;
    -- Prior to commit, ensure that no one else has simultaneously tried to
    -- open the period ...
    -- Check if it already exists with a different period_id.

    OPEN check_if_duplicating;
    FETCH check_if_duplicating
    INTO l_dummy_period_start;

    IF check_if_duplicating%FOUND then
      x_duplicate_open_period := TRUE;
      GOTO error_label;
    END IF;

    l_stmt_num := 70;
    -- Update last_schedule_close_date with newly opened period's
    -- scheduled close date
    SELECT NVL(MAX(schedule_close_date), SYSDATE)
    INTO x_last_scheduled_close_date
    FROM org_acct_periods
    WHERE organization_id = p_org_id;

    GOTO success_label;

    <<error_label>>
      ROLLBACK;
      raise_application_error(-20010, sqlerrm||'---'||l_err_msg);
      GOTO procedure_end;

    <<success_label>>
      COMMIT;
      x_commit_complete := TRUE;
      RETURN;

    <<procedure_end>>
      NULL;

  EXCEPTION
    WHEN org_acct_periods_u2 THEN
       ROLLBACK TO Open_Period_PUB;
       IF INSTRB(SQLERRM,'ORG_ACCT_PERIODS_U2') <> 0 THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       ELSE
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          THEN
             FND_MSG_PUB.Add_Exc_Msg(
               p_pkg_name => G_PKG_NAME,
               p_procedure_name => l_api_name,
               p_error_text => l_stmt_num||SUBSTR(SQLERRM,1,235)
              );
          END IF;
       END IF;

    WHEN FND_API.G_EXC_ERROR THEN
     --
     -- Ensure the rollback is happening
     --
      ROLLBACK TO Open_Period_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Open_Period_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      ROLLBACK TO Open_Period_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||SUBSTR(SQLERRM,1,235)
        );
      END IF;

  END Open_Period;




















  PROCEDURE Verify_PeriodClose(
    p_api_version             IN            NUMBER,
    p_org_id                  IN            NUMBER,
    p_closing_acct_period_id  IN            NUMBER,
    p_closing_end_date        IN            DATE,
    x_open_period_exists      OUT NOCOPY    BOOLEAN,
    x_proper_order            OUT NOCOPY    BOOLEAN,
    x_end_date_is_past        OUT NOCOPY    BOOLEAN,
    x_download_in_process     OUT NOCOPY    BOOLEAN,
    x_prompt_to_reclose       OUT NOCOPY    BOOLEAN,
    x_return_status           OUT NOCOPY    VARCHAR2
  ) IS

    l_temp_id         NUMBER;
    l_le_sysdate      DATE := NULL;
    l_operating_unit  NUMBER := 0;

    --  Finds the earliest period that can be closed
    CURSOR get_next_period_to_close IS
      SELECT acct_period_id
      FROM   org_acct_periods
      WHERE  organization_id = p_org_id
      AND    schedule_close_date = (SELECT MIN(schedule_close_date)
                                    FROM   org_acct_periods
                                    WHERE  organization_id = p_org_id
                                    AND   (open_flag = 'Y' or open_flag = 'P'));

    --  Finds the next period in org_acct_periods
    CURSOR get_next_open_period IS
      SELECT MIN(acct_period_id)
      FROM   org_acct_periods
      WHERE  organization_id = p_org_id
      AND    acct_period_id  > p_closing_acct_period_id;

    --  Checks if period is already in process of closing
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

    x_download_in_process := FALSE;

    l_stmt_num := 10;
    --  Check that this is the next period to close
    OPEN  get_next_period_to_close;
    FETCH get_next_period_to_close
    INTO  l_temp_id;

    IF (l_temp_id = p_closing_acct_period_id) THEN
      x_proper_order := TRUE;
    ELSE
      x_proper_order := FALSE;
      GOTO procedure_end;
    END IF;

    CLOSE get_next_period_to_close;

    l_stmt_num := 20;
    --  Check that the next period is open
    OPEN  get_next_open_period;
    FETCH get_next_open_period
    INTO  l_temp_id;

    IF get_next_open_period%FOUND THEN
      x_open_period_exists := TRUE;
    ELSE
      x_open_period_exists := FALSE;
      GOTO procedure_end;
    END IF;

    CLOSE get_next_open_period;

    --  Check that the period's end date is < today,
    --  adjusting for LE timezone.
    l_stmt_num := 30;
    SELECT operating_unit
    INTO   l_operating_unit
    FROM   cst_acct_info_v
    WHERE  organization_id = p_org_id;

    l_stmt_num := 40;
    l_le_sysdate := INV_LE_TIMEZONE_PUB.GET_LE_SYSDATE_FOR_OU(
                      l_operating_unit);

    l_stmt_num := 50;
    IF (p_closing_end_date < l_le_sysdate) THEN
      x_end_date_is_past := TRUE;
    ELSE
      x_end_date_is_past := FALSE;
      GOTO procedure_end;
    END IF;

    l_stmt_num := 60;
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
    x_wip_failed             IN OUT NOCOPY BOOLEAN,
    x_close_failed           OUT NOCOPY    BOOLEAN,
    x_req_id                 IN OUT NOCOPY NUMBER,
    x_unprocessed_txns       OUT NOCOPY    BOOLEAN,
    x_rec_rpt_launch_failed  OUT NOCOPY    BOOLEAN,
    x_return_status          OUT NOCOPY    VARCHAR2
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

    l_message VARCHAR2(255);

    l_rep_type NUMBER := 0;
    l_currency_code VARCHAR2(15);
    COULD_NOT_LAUNCH_REC_RPT EXCEPTION;

    l_sched_close_date DATE;
    l_period_start_date DATE;
    l_legal_entity NUMBER;
    l_count NUMBER;
    l_unprocessed_table VARCHAR2(30);
    UNPROCESSED_TXNS_EXIST EXCEPTION;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Close_Period_PUB;

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

    l_stmt_num := 10;
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
                          p_closing_acct_period_id,
                          1,
                          240
                        )
      );
    END IF;

    l_stmt_num := 20;
    --  Update period status to processing
    UPDATE org_acct_periods
    SET
      open_flag               = 'P',
      period_close_date       = trunc(sysdate),
      last_update_date        = trunc(sysdate),
      last_updated_by         = p_user_id,
      last_update_login       = p_login_id
    WHERE acct_period_id = p_closing_acct_period_id
    AND   organization_id = p_org_id
    -- program level check to make sure that
    -- the period is only closed once
    AND   open_flag = 'Y';

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_stmt_num := 30;
    --  Update WIP costing if WIP is installed
    l_wip_installed := fnd_installation.get(appl_id     => 706,
                                            dep_appl_id => 706,
                                            status      => l_installation,
                                            industry    => l_indust);

    l_stmt_num := 40;
    IF (l_wip_installed) THEN
      l_return_code := CSTPWPVR.REPVAR(
                         p_org_id,
                         p_closing_acct_period_id,
                         p_user_id,
                         p_login_id,
                         l_err_msg
                       );
    END IF;

    IF (l_wip_installed AND l_return_code <> 0) THEN
      x_wip_failed := TRUE;
      GOTO error_label;
    ELSE
      x_wip_failed := FALSE;
    END IF;

    l_stmt_num := 50;
    SELECT period_start_date, schedule_close_date
    INTO   l_period_start_date, l_sched_close_date
    FROM   org_acct_periods
    WHERE  acct_period_id = p_closing_acct_period_id
    AND    organization_id = p_org_id;

    l_stmt_num := 60;
    SELECT legal_entity
    INTO   l_legal_entity
    FROM   cst_acct_info_v
    WHERE  organization_id = p_org_id;

    l_stmt_num := 70;
    l_period_start_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                             l_period_start_date,
                             l_legal_entity
                           );

    l_stmt_num := 80;
    l_sched_close_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                            l_sched_close_date,
                            l_legal_entity
                          );

    l_sched_close_date := l_sched_close_date + 1;

    l_stmt_num := 90;
    -- check if there are unprocessed transactions in MMTT/MMT/WCTI
    SELECT  COUNT(*)
    INTO    l_count
    FROM    mtl_material_transactions_temp
    WHERE   organization_id = p_org_id
    AND     transaction_date < l_sched_close_date
    AND     NVL(transaction_status,0) <> 2
    AND     rownum = 1; -- transaction_status = 2 indicates a save-only status

    IF l_count <> 0 THEN
      l_unprocessed_table := 'MTL_MATERIAL_TRANSACTIONS_TEMP';
      RAISE UNPROCESSED_TXNS_EXIST;
    END IF;

    l_stmt_num := 100;
    SELECT  /*+ INDEX (MMT MTL_MATERIAL_TRANSACTIONS_N10) */
            COUNT(*)
    INTO    l_count
    FROM    mtl_material_transactions MMT
    WHERE   organization_id = p_org_id
    AND     transaction_date < l_sched_close_date
    AND     costed_flag is not null
    AND     rownum = 1;

    IF l_count <> 0 THEN
      l_unprocessed_table := 'MTL_MATERIAL_TRANSACTIONS';
      RAISE UNPROCESSED_TXNS_EXIST;
    END IF;

    l_stmt_num := 110;
    SELECT  COUNT(*)
    INTO    l_count
    FROM    wip_cost_txn_interface
    WHERE   organization_id = p_org_id
    AND     transaction_date < l_sched_close_date
    AND     rownum = 1;

    IF l_count <> 0 THEN
      l_unprocessed_table := 'WIP_COST_TXN_INTERFACE';
      RAISE UNPROCESSED_TXNS_EXIST;
    END IF;

    l_stmt_num := 120;
    SELECT  COUNT(*)
    INTO    l_count
    FROM    wsm_split_merge_transactions
    WHERE   organization_id = p_org_id
    AND     costed <> wip_constants.completed
    AND     transaction_date < l_sched_close_date
    AND     rownum = 1;

    IF l_count <> 0 THEN
      l_unprocessed_table := 'WSM_SPLIT_MERGE_TRANSACTIONS';
      RAISE UNPROCESSED_TXNS_EXIST;
    END IF;

    l_stmt_num := 130;
    SELECT  COUNT(*)
    INTO    l_count
    FROM    wsm_split_merge_txn_interface
    WHERE   organization_id = p_org_id
    AND     process_status <> wip_constants.completed
    AND     transaction_date < l_sched_close_date
    AND     rownum = 1;

    IF l_count <> 0 THEN
      l_unprocessed_table := 'WSM_SPLIT_MERGE_TXN_INTERFACE';
      RAISE UNPROCESSED_TXNS_EXIST;
    END IF;

    l_stmt_num := 140;
    UPDATE org_acct_periods
    SET    summarized_flag = 'N',
           open_flag = 'N'
    WHERE  organization_id = p_org_id
    AND    acct_period_id = p_closing_acct_period_id;

    -- if x_req_id remains at -1 then we did not attempt to launch CSTRPCRE
    x_req_id := -1;

    IF (FND_PROFILE.VALUE('CST_PERIOD_SUMMARY') = '1') THEN

      l_stmt_num := 150;
      SELECT ML.lookup_code
      INTO   l_rep_type
      FROM   mfg_lookups ML,
             mtl_parameters MP
      WHERE  MP.organization_id = p_org_id
      AND    ML.lookup_type = 'CST_PER_CLOSE_REP_TYPE'
      AND    ML.lookup_code =
             DECODE(MP.primary_cost_method,
               1,DECODE(
                   MP.wms_enabled_flag,
                   'Y',1,
                   DECODE(
                     MP.cost_group_accounting,
                     1,DECODE(
                         MP.project_reference_enabled,
                         1,1,
                         2
                       ),
                     2
                   )
                 ),
               1
             );

      l_stmt_num := 160;
      SELECT GL.currency_code
      INTO   l_currency_code
      FROM   hr_organization_information HOI,
             gl_ledgers GL
      WHERE  HOI.organization_id = p_org_id
      AND    HOI.org_information_context = 'Accounting Information'
      AND    TO_NUMBER(HOI.org_information1) = GL.ledger_id;

      l_stmt_num := 170;
      -- Launch reconciliation report
      x_req_id := FND_REQUEST.submit_request(
                    application => 'BOM',
                    program     => 'CSTRPCRE',
                    description => NULL,
                    start_time  => NULL,
                    sub_request => FALSE,
                    argument1   => p_org_id,
                    argument2   => FND_PROFILE.VALUE('MFG_CHART_OF_ACCOUNTS_ID'),
                    argument3   => l_rep_type,
                    argument4   => 1,
                    argument5   => p_closing_acct_period_id,
                    argument6   => NULL,
                    argument7   => NULL,
                    argument8   => NULL,
                    argument9   => NULL,
                    argument10  => NULL,
                    argument11  => NULL,
                    argument12  => NULL,
                    argument13 => l_currency_code,
                    argument14 => FND_PROFILE.VALUE('DISPLAY_INVERSE_RATE'),
                    argument15 => 2,
                    argument16 => 1);

      IF x_req_id = 0 THEN
        RAISE COULD_NOT_LAUNCH_REC_RPT;
      END IF;
    END IF;

    GOTO procedure_end;

    <<error_label>>
      ROLLBACK TO Close_Period_PUB;
      IF (x_wip_failed) THEN
        raise_application_error(-20000, l_err_msg);
      END IF;

    <<procedure_end>>
      COMMIT;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Close_Period_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
      ROLLBACK TO Close_Period_PUB;
      x_close_failed := TRUE;
    WHEN UNPROCESSED_TXNS_EXIST THEN
      ROLLBACK TO Close_Period_PUB;
      UPDATE org_acct_periods
      SET    open_flag = 'N'
      WHERE  organization_id = p_org_id
      AND    acct_period_id = p_closing_acct_period_id;
      x_unprocessed_txns := TRUE;
    WHEN COULD_NOT_LAUNCH_REC_RPT THEN
      COMMIT;
      x_rec_rpt_launch_failed := TRUE;
    WHEN OTHERS THEN
      ROLLBACK TO Close_Period_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      raise_application_error(-20000, 'statement ' || l_stmt_num || ':' || SQLERRM);
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||SUBSTR(SQLERRM,1,235)
        );
      END IF;

  END Close_Period;

  PROCEDURE Update_EndDate(
    p_api_version            IN         NUMBER,
    p_org_id                 IN         NUMBER,
    p_new_end_date           IN         DATE,
    p_changed_acct_period_id IN         NUMBER,
    p_user_id                IN         NUMBER,
    p_login_id               IN         NUMBER,
    x_period_order           OUT NOCOPY BOOLEAN,
    x_update_failed          OUT NOCOPY BOOLEAN,
    x_return_status          OUT NOCOPY VARCHAR2
  ) IS

    l_next_periods_enddate  DATE;
    l_prior_periods_enddate DATE;

    CURSOR get_prior_periods_enddate IS
      SELECT NVL(MAX(schedule_close_date), p_new_end_date - 1)
      FROM   org_acct_periods
      WHERE  organization_id = p_org_id
      AND    acct_period_id  < p_changed_acct_period_id;

    CURSOR get_next_periods_enddate IS
      SELECT NVL(MIN(schedule_close_date), p_new_end_date + 1)
      FROM   org_acct_periods
      WHERE  organization_id = p_org_id
      AND    acct_period_id  > p_changed_acct_period_id;

    l_api_name CONSTANT VARCHAR2(30) := 'Update_EndDate';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    l_stmt_num NUMBER := 0;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Update_EndDate_PUB;

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
                          p_new_end_date||','||
                          p_changed_acct_period_id||','||
                          p_user_id||','||
                          p_login_id,
                          1,
                          240
                        )
      );
    END IF;

    l_stmt_num := 10;
    --  Verify that new end date is after prior period's end date
    OPEN  get_prior_periods_enddate;
    FETCH get_prior_periods_enddate
    INTO  l_prior_periods_enddate;

    IF get_prior_periods_enddate%NOTFOUND THEN
      GOTO exception_label;
    END IF;

    CLOSE get_prior_periods_enddate;

    l_stmt_num := 20;
    --  Verify that new end date is before following period's end date
    OPEN  get_next_periods_enddate;
    FETCH get_next_periods_enddate
    INTO  l_next_periods_enddate;

    IF get_next_periods_enddate%NOTFOUND THEN
      GOTO exception_label;
    END IF;

    CLOSE get_next_periods_enddate;

    l_stmt_num := 30;
    IF ((p_new_end_date <= l_prior_periods_enddate) OR
        (p_new_end_date >= l_next_periods_enddate)) THEN

      x_period_order := FALSE;

    ELSE

      x_period_order := TRUE;

      --  Update end date for this period
      UPDATE org_acct_periods
      SET    schedule_close_date     = p_new_end_date,
             last_update_date        = trunc(SYSDATE),
             last_updated_by         = p_user_id,
             last_update_login       = p_login_id
      WHERE  organization_id = p_org_id
      AND    acct_period_id  = p_changed_acct_period_id;

      --  Update start date for next period
      UPDATE org_acct_periods
      SET    period_start_date       = p_new_end_date + 1,
             last_update_date        = trunc(SYSDATE),
             last_updated_by         = p_user_id,
             last_update_login       = p_login_id
      WHERE  organization_id = p_org_id
      AND    acct_period_id  =
       (SELECT MIN(acct_period_id)
        FROM   org_acct_periods
        WHERE  acct_period_id  > p_changed_acct_period_id
        AND    organization_id = p_org_id);

    END IF;

    x_update_failed := FALSE;

    COMMIT;
    GOTO procedure_end;

    <<exception_label>>
      x_update_failed := TRUE;

    <<procedure_end>>
      NULL;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_EndDate_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      ROLLBACK TO Update_EndDate_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||SUBSTR(SQLERRM,1,235)
        );
      END IF;
      x_update_failed := TRUE;

  END Update_EndDate;

  PROCEDURE Revert_PeriodStatus(
    p_api_version     IN         NUMBER,
    p_org_id          IN         NUMBER,
    x_acct_period_id  IN         NUMBER,
    x_revert_complete OUT NOCOPY BOOLEAN,
    x_return_status   OUT NOCOPY VARCHAR2
  ) IS

    l_api_name CONSTANT VARCHAR2(30) := 'Revert_PeriodStatus';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    l_stmt_num NUMBER := 0;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Revert_PeriodStatus_PUB;

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
                          p_org_id,
                          1,
                          240
                        )
      );
    END IF;

    l_stmt_num := 10;
    DELETE FROM org_acct_periods
    WHERE organization_id = p_org_id
    AND   acct_period_id =  x_acct_period_id;

    COMMIT;
    x_revert_complete := TRUE;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Revert_PeriodStatus_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      ROLLBACK TO Revert_PeriodStatus_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||SUBSTR(SQLERRM,1,235)
        );
      END IF;
      x_revert_complete := FALSE;

  END Revert_PeriodStatus;

  PROCEDURE Summarize_Period(
    p_api_version     IN         NUMBER,
    p_org_id          IN         NUMBER,
    p_period_id       IN         NUMBER,
    p_to_date         IN         DATE,
    p_user_id         IN         NUMBER,
    p_login_id        IN         NUMBER,
    p_simulation      IN         NUMBER,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_data        OUT NOCOPY VARCHAR2
  ) IS

    l_legal_entity NUMBER := 0;
    l_le_to_date DATE := NULL;
    l_to_date DATE := NULL;
    l_le_period_start_date DATE := NULL;
    l_period_start_date DATE := NULL;
    l_le_prior_end_date DATE := NULL;
    l_prior_end_date DATE := NULL;
    l_resummarize NUMBER := 0;
    l_prior_period_id NUMBER := 0;
    l_prev_summary NUMBER := 0;
    l_cpcs_count NUMBER := 0;
    l_current_period_closed NUMBER := 0;
    l_category_set_id NUMBER := 0;
    l_cost_method NUMBER := 0;

    l_return_status VARCHAR2(1) := '0';

    l_api_name CONSTANT VARCHAR2(30) := 'Summarize_Period';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    l_stmt_num NUMBER := 0;
    l_msg_count NUMBER := 0;
    l_msg_data VARCHAR2(2000);

    NO_PREV_SUMMARY_EXISTS EXCEPTION;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Summarize_Period_PUB;

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

    FND_MSG_PUB.Initialize;

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => SUBSTR(
                          l_stmt_num||':'||
                          p_org_id||','||
                          p_period_id||','||
                          p_to_date||','||
                          p_user_id||','||
                          p_login_id,
                          1,
                          240
                        )
      );
    END IF;

    l_stmt_num := 5;

    SELECT legal_entity
    INTO   l_legal_entity
    FROM   cst_acct_info_v
    WHERE  organization_id = p_org_id;

    l_stmt_num := 7;
    SELECT period_start_date, schedule_close_date
    INTO   l_le_period_start_date, l_le_to_date
    FROM   org_acct_periods
    WHERE  organization_id = p_org_id
    AND    acct_period_id  = p_period_id;

    l_stmt_num := 8;
    l_period_start_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                   l_le_period_start_date,
                   l_legal_entity);

    l_stmt_num := 10;
    IF p_to_date IS NULL THEN
      l_to_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                     l_le_to_date,
                     l_legal_entity);
    ELSE
      l_to_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                     p_to_date,
                     l_legal_entity);
    END IF;

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => l_stmt_num||': Using start date of ' || to_char(l_period_start_date,'DD-MON-YYYY HH24:MI:SS')
      );
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => l_stmt_num||': Using to date of ' || to_char(l_to_date,'DD-MON-YYYY HH24:MI:SS')
      );
    END IF;

    l_stmt_num := 20;
    --find id of the previous period
    SELECT MAX(acct_period_id)
    INTO   l_prior_period_id
    FROM   org_acct_periods
    WHERE  organization_id = p_org_id
    AND    acct_period_id < p_period_id;

    l_stmt_num := 30;
    --if summarized_flag in org_acct_periods is 'N' and data exists in CPCS
    --for the same period, delete the rows from CPCS.

    SELECT count(*)
    INTO   l_resummarize
    FROM   org_acct_periods
    WHERE  organization_id = p_org_id
    AND    acct_period_id = p_period_id
    AND    summarized_flag = 'N'
    AND EXISTS
          (SELECT 'Data exists in CPCS'
           FROM   cst_period_close_summary
           WHERE  organization_id = p_org_id
           AND    acct_period_id = p_period_id);

    IF (l_resummarize > 0) THEN

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Resummarizing: data exists in CPCS for org/period '
                          ||p_org_id || '/' || p_period_id
        );
      END IF;

      l_stmt_num := 35;

      DELETE cst_period_close_summary
      WHERE  organization_id = p_org_id
      AND    acct_period_id >= p_period_id;

      /* Updating org_acct_periods in case the customer has not updated summarized_flag
         for all succeeding periods */
      l_stmt_num := 37;
      UPDATE org_acct_periods
      SET    summarized_flag = 'N'
      WHERE  organization_id = p_org_id
      AND    acct_period_id >= p_period_id
      AND    summarized_flag = 'Y';
    END IF;

    l_stmt_num := 40;
    --check if previous period is summarized
    SELECT count(*)
    INTO   l_prev_summary
    FROM   org_acct_periods
    WHERE  organization_id = p_org_id
    AND    acct_period_id = l_prior_period_id
    AND    summarized_flag = 'Y';

    --check if CPCS is empty
    SELECT count(*)
    INTO   l_cpcs_count
    FROM   cst_period_close_summary
    WHERE  organization_id = p_org_id
    AND    rownum = 1;

    l_stmt_num := 45;
    --find default category set
    SELECT category_set_id
    INTO   l_category_set_id
    FROM   mtl_default_category_sets
    WHERE  functional_area_id = 5; -- Costing functional area

    IF (l_cpcs_count = 0) THEN

      l_stmt_num := 50;
      --find date to rollback to for initialization

      SELECT NVL(OAP1.schedule_close_date+1-(1/(24*3600)),
                 OAP2.period_start_date-(1/(24*3600)))
      INTO   l_le_prior_end_date
      FROM   org_acct_periods OAP1,
             org_acct_periods OAP2
      WHERE  OAP1.organization_id(+) = OAP2.organization_id
      AND    OAP1.acct_period_id(+) = l_prior_period_id
      AND    OAP2.organization_id = p_org_id
      AND    OAP2.acct_period_id = p_period_id;

      l_stmt_num := 51;
      l_prior_end_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                            l_le_prior_end_date,
                            l_legal_entity);

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Initializing new summary history in CPCS for org '
                          ||p_org_id|| ', rolling back to ' || to_char(l_prior_end_date,'DD-MON-YYYY HH24:MI:SS')
        );
      END IF;

      l_stmt_num := 52;
      CST_Inventory_PUB.Calculate_InventoryValue(
        p_api_version => 1.0,
        p_init_msg_list => CST_Utility_PUB.Get_False,
        p_organization_id => p_org_id,
        p_onhand_value => 1,
        p_intransit_value => 1,
        p_receiving_value => 0,
        p_valuation_date => l_prior_end_date,
        p_cost_type_id => NULL,
        p_item_from => NULL,
        p_item_to => NULL,
        p_category_set_id => l_category_set_id,
        p_category_from => NULL,
        p_category_to => NULL,
        p_cost_group_from => NULL,
        p_cost_group_to => NULL,
        p_subinventory_from => NULL,
        p_subinventory_to => NULL,
        p_qty_by_revision => NULL,
        p_zero_cost_only => NULL,
        p_zero_qty => NULL,
        p_expense_item => NULL,
        p_expense_sub => NULL,
        p_unvalued_txns => 0,
        p_receipt => 1,
        p_shipment => 1,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data
      );

      l_stmt_num := 54;
      INSERT
      INTO   cst_per_close_summary_temp(
             cost_group_id,
             subinventory_code,
             inventory_item_id,
             accounted_value,
             rollback_value,
             rollback_qty,
             rollback_onhand_value,
             rollback_intransit_value)
      SELECT CIQT.cost_group_id,
             CIQT.subinventory_code,
             CIQT.inventory_item_id,
             0 accounted_value,
             SUM(NVL(CIQT.rollback_qty,0))*NVL(CICT.item_cost,0) rollback_value,
             SUM(NVL(CIQT.rollback_qty,0)),
             SUM(DECODE(CIQT.qty_source,
                          3,NVL(CIQT.rollback_qty,0),
                          4,NVL(CIQT.rollback_qty,0),
                          5,NVL(CIQT.rollback_qty,0),
                          0))*NVL(CICT.item_cost,0) rollback_onhand_value,
             SUM(DECODE(CIQT.qty_source,
                          6,NVL(CIQT.rollback_qty,0),
                          7,NVL(CIQT.rollback_qty,0),
                          8,NVL(CIQT.rollback_qty,0),
                          0))*NVL(CICT.item_cost,0) rollback_intransit_value
      FROM   cst_inv_qty_temp CIQT,
             cst_inv_cost_temp CICT
      WHERE  CIQT.organization_id = p_org_id
      AND    CIQT.organization_id = CICT.organization_id
      AND    NVL(CIQT.cost_group_id,-1) =
             NVL(CICT.cost_group_id,NVL(CIQT.cost_group_id,-1))
      AND    CIQT.inventory_item_id = CICT.inventory_item_id
      AND    CICT.cost_source = 2 -- PAST
      GROUP BY
             CIQT.organization_id,
             CIQT.cost_group_id,
             CIQT.subinventory_code,
             CIQT.inventory_item_id,
             CICT.item_cost;

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Inserted  '||SQL%ROWCOUNT||
                          ' rows to CPCST for initialization'
        );
      END IF;

      l_stmt_num := 56;
      DELETE CST_ITEM_LIST_TEMP;
      DELETE CST_CG_LIST_TEMP;
      DELETE CST_SUB_LIST_TEMP;
      DELETE CST_INV_QTY_TEMP;
      DELETE CST_INV_COST_TEMP;

      l_stmt_num := 57;
      INSERT
      INTO   cst_inv_qty_temp(
             qty_source,
             organization_id,
             cost_group_id,
             subinventory_code,
             inventory_item_id,
             accounted_value)

      SELECT 1, -- PRIOR ONHAND
             p_org_id organization_id,
             CPCST.cost_group_id,
             CPCST.subinventory_code,
             CPCST.inventory_item_id,
             CPCST.rollback_onhand_value
      FROM   cst_per_close_summary_temp CPCST
      WHERE  CPCST.rollback_onhand_value <> 0

      UNION ALL

      SELECT 2, -- PRIOR INTRANSIT
             p_org_id organization_id,
             CPCST.cost_group_id,
             CPCST.subinventory_code,
             CPCST.inventory_item_id,
             CPCST.rollback_intransit_value
      FROM   cst_per_close_summary_temp CPCST
      WHERE  CPCST.rollback_intransit_value <> 0

      UNION ALL

      SELECT 21, -- CUMULATIVE ONHAND
             p_org_id organization_id,
             CPCST.cost_group_id,
             CPCST.subinventory_code,
             CPCST.inventory_item_id,
             CPCST.rollback_onhand_value
      FROM   cst_per_close_summary_temp CPCST
      WHERE  CPCST.rollback_onhand_value <> 0

      UNION ALL

      SELECT 22, -- CUMULATIVE INTRANSIT
             p_org_id organization_id,
             CPCST.cost_group_id,
             CPCST.subinventory_code,
             CPCST.inventory_item_id,
             CPCST.rollback_intransit_value
      FROM   cst_per_close_summary_temp CPCST
      WHERE  CPCST.rollback_intransit_value <> 0;

      l_stmt_num := 59;
      IF (p_simulation = 1) THEN
        DELETE cst_per_close_summary_temp;
      END IF;

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Inserted  '||SQL%ROWCOUNT||
                          ' rows to CIQT as baseline from CPCST'
        );
      END IF;

    ELSIF (l_prev_summary <> 1) THEN
      --only the first unsummarized period should be summarizable if
      --there is existing information in CPCS.
      RAISE NO_PREV_SUMMARY_EXISTS;
    END IF;

    IF (l_cpcs_count > 0) THEN
      l_stmt_num := 60;
      --we did not already insert baseline from
      --CPCST initialization, so insert from CPCS
      INSERT
      INTO   cst_inv_qty_temp(
             qty_source,
             organization_id,
             cost_group_id,
             subinventory_code,
             inventory_item_id,
             accounted_value)
      SELECT
             1, -- PRIOR ONHAND
             p_org_id organization_id,
             CPCS.cost_group_id,
             CPCS.subinventory_code,
             CPCS.inventory_item_id,
             CPCS.rollback_onhand_value
      FROM
             cst_period_close_summary CPCS
      WHERE  CPCS.organization_id = p_org_id
      AND    CPCS.acct_period_id = NVL(l_prior_period_id,-1)

      UNION ALL

      SELECT
             2, -- PRIOR INTRANSIT
             p_org_id organization_id,
             CPCS.cost_group_id,
             CPCS.subinventory_code,
             CPCS.inventory_item_id,
             CPCS.rollback_intransit_value
      FROM
             cst_period_close_summary CPCS
      WHERE  CPCS.organization_id = p_org_id
      AND    CPCS.acct_period_id = NVL(l_prior_period_id,-1)

      UNION ALL

      SELECT
             21, -- CUMULATIVE ONHAND
             p_org_id organization_id,
             CPCS.cost_group_id,
             CPCS.subinventory_code,
             CPCS.inventory_item_id,
             CPCS.cumulative_onhand_mta
      FROM
             cst_period_close_summary CPCS
      WHERE  CPCS.organization_id = p_org_id
      AND    CPCS.acct_period_id = NVL(l_prior_period_id,-1)

      UNION ALL

      SELECT
             22, -- CUMULATIVE INTRANSIT
             p_org_id organization_id,
             CPCS.cost_group_id,
             CPCS.subinventory_code,
             CPCS.inventory_item_id,
             CPCS.cumulative_intransit_mta
      FROM
             cst_period_close_summary CPCS
      WHERE  CPCS.organization_id = p_org_id
      AND    CPCS.acct_period_id = NVL(l_prior_period_id,-1);

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Inserted  '||SQL%ROWCOUNT||
                          ' rows to CIQT as baseline from CPCS'
        );
      END IF;

    END IF;

    l_stmt_num := 65;
    SELECT primary_cost_method
    INTO   l_cost_method
    FROM   mtl_parameters
    WHERE  organization_id = p_org_id;

    l_stmt_num := 70;
    --summarize accounted value from MTA where
    --the primary quantity is the same in MTA and MMT
    INSERT
    INTO   cst_inv_qty_temp(
           qty_source,
           organization_id,
           cost_group_id,
           subinventory_code,
           inventory_item_id,
           accounted_value)
    SELECT 11, -- CURRENT ONHAND
           p_org_id organization_id,
           DECODE(MTA.transaction_source_type_id,
                  5,
                  DECODE(
                    l_cost_method,
                    2,
                    NVL(MMT.transfer_cost_group_id,
                        MMT.cost_group_id),
                    MMT.cost_group_id),
                  MMT.cost_group_id),
           DECODE(MTA.transaction_source_type_id,
                  5,
                  DECODE(
                    l_cost_method,
                    2,
                    DECODE(MMT.transfer_cost_group_id,
                           NULL, MMT.subinventory_code,
					/* Bug 3500534
					It is possible to have normal issue to WIP transactions in
					average costing organizations with transfer_cost_group_id
					= cost_group_id.  The following condition ensures such cases
					are handled as normal issue to WIP rather than common. */
				   MMT.cost_group_id, MMT.subinventory_code,
                           NULL),
                    MMT.subinventory_code),
                  MMT.subinventory_code),
           MMT.inventory_item_id,
           SUM(MTA.base_transaction_value)
    FROM   mtl_material_transactions MMT,
           mtl_transaction_accounts MTA /*,
           mtl_secondary_inventories SUB */
    WHERE  MTA.accounting_line_type = 1 -- inventory
    AND    MTA.transaction_date >= l_period_start_date
    AND    MTA.transaction_date <= l_to_date+1-(1/(24*3600))
    AND    MTA.organization_id = p_org_id
/*  AND    SUB.organization_id (+) = MMT.organization_id
    AND    SUB.secondary_inventory_name (+) = MMT.subinventory_code
    AND    NVL(SUB.asset_inventory,1) = 1 */
    AND     (sign(MMT.primary_quantity) = sign(MTA.primary_quantity)/*BUG7326014*/
                         OR
              MMT.transaction_action_id = 24)
    AND    MMT.transaction_id = MTA.transaction_id
    AND    MMT.transaction_type_id <> 25
    GROUP BY
           DECODE(MTA.transaction_source_type_id,
                  5,
                  DECODE(
                    l_cost_method,
                    2,
                    NVL(MMT.transfer_cost_group_id,
                        MMT.cost_group_id),
                    MMT.cost_group_id),
                  MMT.cost_group_id),
           DECODE(MTA.transaction_source_type_id,
                  5,
                  DECODE(
                    l_cost_method,
                    2,
                    DECODE(MMT.transfer_cost_group_id,
                           NULL, MMT.subinventory_code,
					/* Bug 3500534
					It is possible to have normal issue to WIP transactions in
					average costing organizations with transfer_cost_group_id
					= cost_group_id.  The following condition ensures such cases
					are handled as normal issue to WIP rather than common. */
				   MMT.cost_group_id, MMT.subinventory_code,
                           NULL),
                    MMT.subinventory_code),
                  MMT.subinventory_code),
           MMT.inventory_item_id;

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => l_stmt_num||': Inserted  '||SQL%ROWCOUNT||
                        ' rows to CIQT for same MMT MTA primary quantity'
      );
    END IF;

    l_stmt_num := 80;
    --summarize accounted value from MTA where
    --the primary quantity is different in MTA and MMT (using transfer sub, org, etc)
    INSERT
    INTO   cst_inv_qty_temp(
           qty_source,
           organization_id,
           cost_group_id,
           subinventory_code,
           inventory_item_id,
           accounted_value)
    SELECT 11, -- CURRENT ONHAND
           p_org_id organization_id,
           MMT.transfer_cost_group_id,
           MMT.transfer_subinventory,
           MMT.inventory_item_id,
           SUM(MTA.base_transaction_value)
    FROM   mtl_material_transactions MMT,
           mtl_transaction_accounts MTA /*,
           mtl_secondary_inventories SUB */
    WHERE  MTA.accounting_line_type = 1 -- inventory
    AND    MTA.transaction_date >= l_period_start_date
    AND    MTA.transaction_date <= l_to_date+1-(1/(24*3600))
    AND    MTA.organization_id = p_org_id
 /* AND    SUB.organization_id (+) = MMT.transfer_organization_id
    AND    SUB.secondary_inventory_name (+) = MMT.transfer_subinventory
    AND    NVL(SUB.asset_inventory,1) = 1 */
    AND    sign(MMT.primary_quantity )<>sign( MTA.primary_quantity)/*BUG7326014*/
    AND    MMT.transaction_id = MTA.transaction_id
    AND    MMT.transaction_action_id in (1,2,3,5,28,55)
    GROUP BY
           MMT.transfer_cost_group_id,
           MMT.transfer_subinventory,
           MMT.inventory_item_id;

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => l_stmt_num||': Inserted  '||SQL%ROWCOUNT||
                        ' rows to CIQT for different MMT MTA primary quantity'
      );
    END IF;

    l_stmt_num := 85;
    --summarize intransit value from MTA
    INSERT
    INTO   cst_inv_qty_temp(
             qty_source,
             organization_id,
             cost_group_id,
             subinventory_code,
             inventory_item_id,
             accounted_value)
    SELECT 12, -- CURRENT INTRANSIT
           p_org_id organization_id,
           DECODE(MMT.transaction_action_id,
                  24,MMT.cost_group_id,
                  MMT.transfer_cost_group_id),
           NULL,
           MMT.inventory_item_id,
           SUM(MTA.base_transaction_value)
    FROM   mtl_material_transactions MMT,
	   mtl_transaction_accounts MTA
    WHERE  MTA.accounting_line_type = 14 -- intransit account
    AND    MTA.transaction_date >= l_period_start_date
    AND    MTA.transaction_date <= l_to_date+1-(1/(24*3600))
    AND    MTA.organization_id = p_org_id
    AND    MMT.transaction_id = MTA.transaction_id
    GROUP
    BY     MMT.inventory_item_id,
           DECODE(MMT.transaction_action_id,
                  24,MMT.cost_group_id,
                  MMT.transfer_cost_group_id);

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => l_stmt_num||': Inserted  '||SQL%ROWCOUNT||
                        ' rows to CIQT for intransit quantity'
      );
    END IF;

    l_stmt_num := 90;
    --function call to calculate onhand value
    CST_Inventory_PUB.Calculate_InventoryValue(
      p_api_version => 1.0,
      p_init_msg_list => CST_Utility_PUB.Get_False,
      p_organization_id => p_org_id,
      p_onhand_value => 1,
      p_intransit_value => 1,
      p_receiving_value => 0,
      p_valuation_date => l_to_date+1-(1/(24*3600)),
      p_cost_type_id => NULL,
      p_item_from => NULL,
      p_item_to => NULL,
      p_category_set_id => l_category_set_id,
      p_category_from => NULL,
      p_category_to => NULL,
      p_cost_group_from => NULL,
      p_cost_group_to => NULL,
      p_subinventory_from => NULL,
      p_subinventory_to => NULL,
      p_qty_by_revision => NULL,
      p_zero_cost_only => NULL,
      p_zero_qty => NULL,
      p_expense_item => NULL,
      p_expense_sub => NULL,
      p_unvalued_txns => 0,
      p_receipt => 1,
      p_shipment => 1,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data
    );

    l_stmt_num := 100;

    --choose which table to insert
    IF (p_simulation = 1) THEN
      l_stmt_num := 110;
      x_return_status := '3';
      --period open -> CPCST (simulation)
      INSERT
      INTO   cst_per_close_summary_temp(
             cost_group_id,
             subinventory_code,
             inventory_item_id,
             accounted_value,
             rollback_value,
             rollback_qty)
      SELECT CIQT.cost_group_id,
             CIQT.subinventory_code,
             CIQT.inventory_item_id,
             SUM(DECODE(CIQT.qty_source,
                  21,0,
                  22,0,
                  NVL(CIQT.accounted_value,0))) accounted_value,
             SUM(NVL(CIQT.rollback_qty,0))*NVL(CICT.item_cost,0) rollback_value,
             SUM(NVL(CIQT.rollback_qty,0))
      FROM   cst_inv_qty_temp CIQT,
             cst_inv_cost_temp CICT
      WHERE  CIQT.organization_id = p_org_id
      AND    CIQT.organization_id = CICT.organization_id(+)
      AND    NVL(CIQT.cost_group_id,-1) =
             NVL(CICT.cost_group_id,NVL(CIQT.cost_group_id,-1))
      AND    CIQT.inventory_item_id = CICT.inventory_item_id(+)
      AND    CICT.cost_source(+) = 2 -- PAST
      GROUP BY
             CIQT.cost_group_id,
             CIQT.subinventory_code,
             CIQT.inventory_item_id,
             CICT.item_cost;

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => l_stmt_num||': Inserted  '||SQL%ROWCOUNT||
                        ' rows to CPCST for simulation purposes'
      );
    END IF;

    ELSE

      l_stmt_num := 120;
      x_return_status := '2';
      --period closed -> CPCS
      INSERT
      INTO   cst_period_close_summary(
             acct_period_id,
             organization_id,
             cost_group_id,
             subinventory_code,
             inventory_item_id,
             accounted_value,
             rollback_value,
             rollback_quantity,
             rollback_onhand_value,
             rollback_intransit_value,
             accounted_onhand_value,
             accounted_intransit_value,
             onhand_value_discrepancy,
             intransit_value_discrepancy,
             cumulative_onhand_mta,
             cumulative_intransit_mta,
             last_update_date,
             last_updated_by,
             creation_date,
             creation_by)
      SELECT p_period_id,
             CIQT.organization_id,
             CIQT.cost_group_id,
             CIQT.subinventory_code,
             CIQT.inventory_item_id,
             SUM(DECODE(CIQT.qty_source,
                         21,0,
                         22,0,
                         NVL(CIQT.accounted_value,0))) accounted_value,
             SUM(NVL(CIQT.rollback_qty,0))*NVL(CICT.item_cost,0) rollback_value,
             SUM(NVL(CIQT.rollback_qty,0)),
             SUM(DECODE(CIQT.qty_source,
                         3,NVL(CIQT.rollback_qty,0),
                         4,NVL(CIQT.rollback_qty,0),
                         5,NVL(CIQT.rollback_qty,0),
                         0))*NVL(CICT.item_cost,0) rollback_onhand_value,
             SUM(DECODE(CIQT.qty_source,
                         6,NVL(CIQT.rollback_qty,0),
                         7,NVL(CIQT.rollback_qty,0),
                         8,NVL(CIQT.rollback_qty,0),
                         0))*NVL(CICT.item_cost,0) rollback_intransit_value,
             SUM(DECODE(CIQT.qty_source,
                         1,NVL(CIQT.accounted_value,0),
                         11,NVL(CIQT.accounted_value,0),
                         0)) accounted_onhand_value,
             SUM(DECODE(CIQT.qty_source,
                         2,NVL(CIQT.accounted_value,0),
                         12,NVL(CIQT.accounted_value,0),
                         0)) accounted_intransit_value,
             SUM(DECODE(CIQT.qty_source,
                         3,NVL(CIQT.rollback_qty,0),
                         4,NVL(CIQT.rollback_qty,0),
                         5,NVL(CIQT.rollback_qty,0),
                         0))*NVL(CICT.item_cost,0) -
             SUM(DECODE(CIQT.qty_source,
                         1,NVL(CIQT.accounted_value,0),
                         11,NVL(CIQT.accounted_value,0),
                         0)) onhand_value_discrepancy,
             SUM(DECODE(CIQT.qty_source,
                         6,NVL(CIQT.rollback_qty,0),
                         7,NVL(CIQT.rollback_qty,0),
                         8,NVL(CIQT.rollback_qty,0),
                         0))*NVL(CICT.item_cost,0) -
             SUM(DECODE(CIQT.qty_source,
                         2,NVL(CIQT.accounted_value,0),
                         12,NVL(CIQT.accounted_value,0),
                         0)) intransit_value_discrepancy,
             SUM(DECODE(CIQT.qty_source,
                         11,NVL(CIQT.accounted_value,0),
                         21,NVL(CIQT.accounted_value,0),
                         0)) cumulative_onhand_mta,
             SUM(DECODE(CIQT.qty_source,
                         12,NVL(CIQT.accounted_value,0),
                         22,NVL(CIQT.accounted_value,0),
                         0)) cumulative_intransit_mta,
             SYSDATE,
             1,
             SYSDATE,
             1
      FROM   cst_inv_qty_temp CIQT,
             cst_inv_cost_temp CICT
      WHERE  CIQT.organization_id = p_org_id
      AND    CIQT.organization_id = CICT.organization_id(+)
      AND    NVL(CIQT.cost_group_id,-1) =
             NVL(CICT.cost_group_id,NVL(CIQT.cost_group_id,-1))
      AND    CIQT.inventory_item_id = CICT.inventory_item_id(+)
      AND    CICT.cost_source(+) = 2 -- PAST
      GROUP BY
             CIQT.organization_id,
             CIQT.cost_group_id,
             CIQT.subinventory_code,
             CIQT.inventory_item_id,
             CICT.item_cost;

      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Inserted  '||SQL%ROWCOUNT||
                          ' rows to CPCS for org/period ' || p_org_id || '/' || p_period_id
        );
      END IF;

      l_stmt_num := 130;
      UPDATE org_acct_periods
      SET    summarized_flag = 'Y'

      WHERE  organization_id = p_org_id
      AND    acct_period_id = p_period_id;

    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Summarize_Period_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_PREV_SUMMARY_EXISTS THEN
      ROLLBACK TO Summarize_Period_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||': Only first unsummarized period can be summarized'
        );
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO Summarize_Period_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => l_stmt_num||SUBSTR(SQLERRM,1,235)
        );
      END IF;

  END Summarize_Period;

END CST_AccountingPeriod_PUB;

/
