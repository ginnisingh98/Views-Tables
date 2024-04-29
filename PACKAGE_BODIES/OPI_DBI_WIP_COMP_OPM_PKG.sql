--------------------------------------------------------
--  DDL for Package Body OPI_DBI_WIP_COMP_OPM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_WIP_COMP_OPM_PKG" AS
/*$Header: OPIDCOMPLOB.pls 115.4 2003/11/14 18:46:52 cdaly noship $ */

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
    Package level variables for session info, including schema name
    for truncating and collecting stats
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

    s_opi_schema      VARCHAR2(30);
    s_status          VARCHAR2(30);
    s_industry        VARCHAR2(30);
    s_SUCCESS CONSTANT NUMBER := 0;        -- concurrent manager success code
    s_pkg_name CONSTANT VARCHAR2 (50) := 'opi_dbi_wip_comp_opm_pkg';
    s_ERROR CONSTANT NUMBER := -1;         -- concurrent manager error code
    OPM_SOURCE CONSTANT NUMBER := 2;
    NON_PLANNED_ITEM CONSTANT NUMBER := 6; -- Non planned items have an mrp_planning_code of 6
    WIP_COMPLETION_ETL CONSTANT NUMBER := 1;    -- WIP completions

/*++++++++++++++++++++++++++++++++++++++++*/
/*  Package level variables for the logged
    in user.
/*++++++++++++++++++++++++++++++++++++++++*/

    s_user_id NUMBER := nvl(fnd_global.user_id, -1);
    s_login_id NUMBER := nvl(fnd_global.login_id, -1);


    could_not_log_success EXCEPTION;
    PRAGMA EXCEPTION_INIT (could_not_log_success, -20005);

    schema_info_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT (schema_info_not_found, -20000);

    run_common_module EXCEPTION;
    PRAGMA EXCEPTION_INIT (run_common_module, -20002);

PROCEDURE collect_opm_led_current (p_global_start_date DATE)
AS
BEGIN

/*
    Note that the inclusion of doc_type in each inline view is not needed functionally,
    but may benefit the optimizer in supporting the use of an index probe in the join.

    Modifications to this procedure should be applied to collect_opm_tst_current.
*/
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'opi_dbi_opm_wip_led_current');

    INSERT INTO opi_dbi_opm_wip_led_current
    (   orgn_code,
        item_id,
        gl_trans_date,
        trans_qty,
        amount_base)
    SELECT
        t.orgn_code,
        t.item_id,
        led.gl_trans_date,
        sum (t.trans_qty),
        sum (led.amount_base)
    FROM
        (   SELECT
                doc_type,
                doc_id,
                line_id,
                TRUNC(trans_date) trans_date,
                orgn_code,
                item_id,
                SUM(trans_qty) trans_qty
            FROM
                ic_tran_pnd
            WHERE
                doc_type = 'PROD'
            AND line_type IN (1,2)
            AND completed_ind = 1
            AND gl_posted_ind = 1
            AND trans_date >= p_global_start_date
            GROUP BY
                doc_type,
                doc_id,
                line_id,
                TRUNC(trans_date),
                orgn_code,
                item_id
        ) t,
        (   SELECT
                sub.doc_type,
                sub.doc_id,
                sub.line_id,
                TRUNC(sub.gl_trans_date) gl_trans_date,
                SUM(sub.amount_base * sub.debit_credit_sign) amount_base
            FROM
                gl_subr_led sub,
                opi_dbi_run_log_curr log
            WHERE
                sub.gl_trans_date >= p_global_start_date
            AND sub.acct_ttl_type = 1500
            AND sub.doc_type = 'PROD'
            AND log.source = OPM_SOURCE
            AND log.etl_id = WIP_COMPLETION_ETL
            AND log.organization_id IS NULL
            AND sub.subledger_id >= log.start_txn_id
            AND sub.subledger_id < log.next_start_txn_id
            GROUP BY
                sub.doc_type,
                sub.doc_id,
                sub.line_id,
                TRUNC(sub.gl_trans_date)
        ) led
    WHERE
        t.doc_type = led.doc_type
    AND t.doc_id = led.doc_id
    AND t.line_id = led.line_id
    AND t.trans_date = led.gl_trans_date
    GROUP BY
        t.orgn_code,
        t.item_id,
        led.gl_trans_date;

END collect_opm_led_current;


PROCEDURE capture_opm_tst_prior
AS
  l_prior_populated NUMBER;
BEGIN

-- Modified 11/13/03 by CDALY
-- to use stop_reason_code in log to determine if the prior table needes populating
-- or if it was already populated by an aborted but committed previous attempt.
-- If prior were allowed to be  truncated when current was already truncated by an
-- aborted but committed previous attempt, then the prior data would be lost.

select stop_reason_code into l_prior_populated  -- get state of prior table from log
from opi_dbi_run_log_curr
where etl_id = 1
  and source = 2;

if NVL(l_prior_populated, 0) <> 9999    --if state = successful
  then
       EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' || 'opi_dbi_opm_wip_tst_prior');

       INSERT INTO opi_dbi_opm_wip_tst_prior
             (orgn_code, item_id, gl_trans_date, trans_qty, amount_base)
       SELECT orgn_code, item_id, gl_trans_date, trans_qty, amount_base
       FROM opi_dbi_opm_wip_tst_current;

       update opi_dbi_run_log_curr           -- state = prior populated and current truncated
         set
             stop_reason_code  = 9999,       -- flag to indicate prior tst table has been populated
             last_update_date  = sysdate,
             last_updated_by   = s_user_id,
             last_update_login = s_login_id
        where etl_id = 1
          and source = 2;
        commit;
     END IF;

END capture_opm_tst_prior;


PROCEDURE collect_opm_tst_current (p_global_start_date DATE)
AS
BEGIN
/*
    Differences between this procedure and collect_opm_LED_current:

    * target table is opi_dbi_opm_wip_TST_current  (rather than ... LED_current)
    * subr table is gl_subr_TST     (rather than gl_subr_LED)
    * ic_tran_pnd.gl_posted_ind = 0 (rather than 1)

    Noting these differences here makes it possible to propagate maintenance to the
    led_current procedure by copying it and applying the differences.  This is a
    good practice, because the procedures as so similar.
*/

    INSERT INTO opi_dbi_opm_wip_tst_current
    (   orgn_code,
        item_id,
        gl_trans_date,
        trans_qty,
        amount_base)
    SELECT
        t.orgn_code,
        t.item_id,
        led.gl_trans_date,
        sum (t.trans_qty),
        sum (led.amount_base)
    FROM
        (   SELECT
                doc_type,
                doc_id,
                line_id,
                TRUNC(trans_date) trans_date,
                orgn_code,
                item_id,
                SUM(trans_qty) trans_qty
            FROM
                ic_tran_pnd
            WHERE
                doc_type = 'PROD'
            AND line_type IN (1,2)
            AND completed_ind = 1
            AND gl_posted_ind = 0
            AND trans_date >= p_global_start_date
            GROUP BY
                doc_type,
                doc_id,
                line_id,
                TRUNC(trans_date),
                orgn_code,
                item_id
        ) t,
        (   SELECT
                doc_type,
                doc_id,
                line_id,
                TRUNC(gl_trans_date) gl_trans_date,
                SUM(amount_base * debit_credit_sign) amount_base
            FROM
                gl_subr_tst
            WHERE
                gl_trans_date >= p_global_start_date
            AND acct_ttl_type = 1500
            AND doc_type = 'PROD'
            GROUP BY
                doc_type,
                doc_id,
                line_id,
                TRUNC(gl_trans_date)
        ) led
    WHERE
        t.doc_type = led.doc_type
    AND t.doc_id = led.doc_id
    AND t.line_id = led.line_id
    AND t.trans_date = led.gl_trans_date
    GROUP BY
        t.orgn_code,
        t.item_id,
        led.gl_trans_date;

END collect_opm_tst_current;


PROCEDURE collect_init_opm_stg
IS
BEGIN
    INSERT INTO OPI_DBI_WIP_COMP_STG (
        organization_id,
        inventory_item_id,
        transaction_date,
        completion_quantity,
        completion_value_b,
        uom_code,
        source,
        planned_item,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login)
    SELECT
        msi.organization_id,
        msi.inventory_item_id,
        t.gl_trans_date,
        sum (t.trans_qty),
        sum (t.amount_base),
        msi.primary_uom_code,
        OPM_SOURCE,             -- this is only for OPI orgs
        decode (msi.mrp_planning_code,
                NON_PLANNED_ITEM, 'N',
                'Y'),
        sysdate,
        sysdate,
        s_user_id,
        s_user_id,
        s_login_id
    FROM
        sy_orgn_mst_b org,
        ic_whse_msT w,
        ic_item_mst_b iim,
        mtl_system_items_b msi,
        (
            SELECT orgn_code, item_id, gl_trans_date,
                   SUM(trans_qty) trans_qty, SUM(amount_base) amount_base
            FROM
                (
                SELECT orgn_code, item_id, gl_trans_date, trans_qty, amount_base
                FROM opi_dbi_opm_wip_led_current
                UNION ALL
                SELECT orgn_code, item_id, gl_trans_date, trans_qty, amount_base
                FROM opi_dbi_opm_wip_tst_current
                )
            GROUP BY orgn_code, item_id, gl_trans_date
            HAVING SUM(trans_qty) <> 0 OR SUM(amount_base) <> 0
        ) t
    WHERE
        org.orgn_code = t.orgn_code
    AND w.whse_code = org.resource_whse_code
    AND iim.item_id = t.item_id
    AND msi.organization_id = w.mtl_organization_id
    AND msi.segment1 = iim.item_no
    GROUP BY
        msi.organization_id,
        msi.inventory_item_id,
        t.gl_trans_date,
        msi.primary_uom_code,
        msi.mrp_planning_code;

END collect_init_opm_stg;


PROCEDURE collect_init_opm_wip_comp (errbuf OUT NOCOPY VARCHAR2,
                                     retcode OUT NOCOPY NUMBER,
                                     p_global_start_date IN DATE)
IS

    l_proc_name VARCHAR2 (60) := 'collect_init_opm_wip_comp';
    l_stmt_id NUMBER := 0;

BEGIN
    -- If all bounds have been set up, extract all the data.
    -- The data is simply inserted into the staging table, since
    -- this is the initial load the staging table should be empty.
    --
    -- WIP completions transactions (acct_ttl_type = 1500, doc_type = 'PROD',
    --                               line_type = 1,2) cause WIP completion
    -- quantity/value to increase.
    --
    -- GSL acct_ttl_type 1500 represents the INV valuation account.
    -- To restrict to WIP, doc_type must be restricted to PROD.
    -- To restrict WIP transactions to completions, line_type must be 1 or 2.
    -- GSL.amount_base is unsigned, so prior to summing, it must be multiplied
    -- by GSL.debit_credit_sign.
    --
    -- When joining to ITP, ITP should be restricted to GL_POSTED_IND = 1,
    -- since corrections may have been made (with balancing inventory transactions)
    -- that have not yet been posted to GSL.  Those corrections can only be picked up
    -- in the extraction from GST (gl_subr_tst).
    --
    -- There is no restriction on the appearance of Expense Items in GSL, GST, or ITP.
    --
    -- Note that it is necessary to pre-aggregate (via in-line view) GSL and ITP,
    -- prior to joining, since both have a high granularity than is supported by the
    -- LINE_ID level join.  In ITP, there may be multiple TRANS_IDs per LINE_ID, and in
    -- GSL, there may be multiple SUBLEDGER_IDs per LINE_ID.  Failure to pre-aggregate
    -- could have the effect of double-counting inventory transactions or subledger
    -- transactions.
    --
    -- There is no concept of a non standard discrete jobs, so no exclusion logig is needed.
    --
    -- 3 separate tables are used for the led_current, tst_current, and tst_prior rows.
    -- This facilitates debugging, and makes it easier to truncate "current" tables
    -- rather than use delete. The tst_prior table is not used for initial load.
    --

    IF (NOT (fnd_installation.get_app_info('OPI', s_status, s_industry, s_opi_schema))) THEN
        RAISE schema_info_not_found;
    END IF;

    -- Clear OPM-specific work tables
    l_stmt_id := 10;
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' || 'opi_dbi_opm_wip_tst_current');
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' || 'opi_dbi_opm_wip_tst_prior');
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' || 'opi_dbi_opm_wip_led_current');

    -- Check if all the bounds have been properly set up
    l_stmt_id := 20;
    IF (NOT (opi_dbi_common_mod_init_pkg.init_end_bounds_setup
                (WIP_COMPLETION_ETL, OPM_SOURCE))) THEN
        RAISE run_common_module;
    END IF;

    -- Collect WIP Completions from Permanent (led) and Test (tst) Subledgers
    l_stmt_id := 30;
    collect_opm_led_current(p_global_start_date);
    l_stmt_id := 40;
    collect_opm_tst_current(p_global_start_date);

    -- Sum up WIP Completions, join in other needed tables
    l_stmt_id := 50;
    collect_init_opm_stg;

    -- Report success to OPI_DBI_RUN_LOG_CURR.
    l_stmt_id := 60;
    IF (NOT (opi_dbi_common_mod_incr_pkg.etl_report_success
                (WIP_COMPLETION_ETL, OPM_SOURCE))) THEN
        RAISE could_not_log_success;
    END IF;

--Following lines moved to beginning of Incremental ETL by CDALY 11/13/03
    -- Move tst_current date to tst_prior
--    l_stmt_id := 70;
--    capture_opm_tst_prior;

    -- Since data pushed to staging table and success logged, commit everything
    l_stmt_id := 80;
    COMMIT;

    -- Truncate work tables whose data is no longer needed
    l_stmt_id := 90;

-- Following line moved to capture_opm_tst_prior by CDALY 11/13/03
--    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' || 'opi_dbi_opm_wip_tst_current');

    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' || 'opi_dbi_opm_wip_tst_prior');
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' || 'opi_dbi_opm_wip_led_current');

    -- all done, so return successfully.
    l_stmt_id := 100;
    retcode := s_SUCCESS;
    errbuf := '';
    return;

EXCEPTION

    WHEN could_not_log_success THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' || l_proc_name || ' ' ||
                              '#' || l_stmt_id || ': ' ||
                              'WIP Completion ETLs Initial load OPI data extraction success could not be logged into log table. Aborting.');


        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Completion ETLs Initial load OPI data extraction success could not be logged into log table. Aborting.';
        RAISE;  -- propagate exception to wrapper.


    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' || l_proc_name || ' ' ||
                              '#' || l_stmt_id || ': ' ||  SQLERRM);

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Completion ETLs Initial load OPI data extraction failed.';
        RAISE;  -- propagate exception to wrapper.

END collect_init_opm_wip_comp;


PROCEDURE collect_incr_opm_stg
IS
BEGIN
    INSERT INTO OPI_DBI_WIP_COMP_STG (
        organization_id,
        inventory_item_id,
        transaction_date,
        completion_quantity,
        completion_value_b,
        uom_code,
        source,
        planned_item,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login)
    SELECT
        msi.organization_id,
        msi.inventory_item_id,
        t.gl_trans_date,
        sum (t.trans_qty),
        sum (t.amount_base),
        msi.primary_uom_code,
        OPM_SOURCE,             -- this is only for OPI orgs
        decode (msi.mrp_planning_code,
                NON_PLANNED_ITEM, 'N',
                'Y'),
        sysdate,
        sysdate,
        s_user_id,
        s_user_id,
        s_login_id
    FROM
        sy_orgn_mst_b org,
        ic_whse_msT w,
        ic_item_mst_b iim,
        mtl_system_items_b msi,
        (
            SELECT orgn_code, item_id, gl_trans_date,
                   SUM(trans_qty) trans_qty, SUM(amount_base) amount_base
            FROM
                (
                SELECT orgn_code, item_id, gl_trans_date, trans_qty, amount_base
                FROM opi_dbi_opm_wip_led_current
                UNION ALL
                SELECT orgn_code, item_id, gl_trans_date, trans_qty, amount_base
                FROM opi_dbi_opm_wip_tst_current
                UNION ALL
                SELECT orgn_code, item_id, gl_trans_date, -trans_qty, -amount_base
                FROM opi_dbi_opm_wip_tst_prior
                )
            GROUP BY orgn_code, item_id, gl_trans_date
            HAVING SUM(trans_qty) <> 0 OR SUM(amount_base) <> 0
        ) t
    WHERE
        org.orgn_code = t.orgn_code
    AND w.whse_code = org.resource_whse_code
    AND iim.item_id = t.item_id
    AND msi.organization_id = w.mtl_organization_id
    AND msi.segment1 = iim.item_no
    GROUP BY
        msi.organization_id,
        msi.inventory_item_id,
        t.gl_trans_date,
        msi.primary_uom_code,
        msi.mrp_planning_code;

END collect_incr_opm_stg;


PROCEDURE collect_incr_opm_wip_comp (errbuf OUT NOCOPY VARCHAR2,
                                     retcode OUT NOCOPY NUMBER,
                                     p_global_start_date IN DATE)
IS

    l_proc_name VARCHAR2 (60) := 'collect_incr_opm_wip_comp';
    l_stmt_id NUMBER := 0;

/*
    This is just like the initial load version with the following exceptions:

    * removal of the TRUNCATE of tst_prior at beginning
    * call to collect_incr_opm_stg (rather than collect_init_opm_stg)
*/
BEGIN
    -- If all bounds have been set up, extract all the data.
    -- The data is simply inserted into the staging table, since
    -- this is the initial load the staging table should be empty.
    --
    -- WIP completions transactions (acct_ttl_type = 1500, doc_type = 'PROD',
    --                               line_type = 1,2) cause WIP completion
    -- quantity/value to increase.
    --
    -- GSL acct_ttl_type 1500 represents the INV valuation account.
    -- To restrict to WIP, doc_type must be restricted to PROD.
    -- To restrict WIP transactions to completions, line_type must be 1 or 2.
    -- GSL.amount_base is unsigned, so prior to summing, it must be multiplied
    -- by GSL.debit_credit_sign.
    --
    -- When joining to ITP, ITP should be restricted to GL_POSTED_IND = 1,
    -- since corrections may have been made (with balancing inventory transactions)
    -- that have not yet been posted to GSL.  Those corrections can only be picked up
    -- in the extraction from GST (gl_subr_tst).
    --
    -- There is no restriction on the appearance of Expense Items in GSL, GST, or ITP.
    --
    -- Note that it is necessary to pre-aggregate (via in-line view) GSL and ITP,
    -- prior to joining, since both have a high granularity than is supported by the
    -- LINE_ID level join.  In ITP, there may be multiple TRANS_IDs per LINE_ID, and in
    -- GSL, there may be multiple SUBLEDGER_IDs per LINE_ID.  Failure to pre-aggregate
    -- could have the effect of double-counting inventory transactions or subledger
    -- transactions.
    --
    -- There is no concept of a non standard discrete jobs, so no exclusion logig is needed.
    --
    -- 3 separate tables are used for the led_current, tst_current, and tst_prior rows.
    -- This facilitates debugging, and makes it easier to truncate "current" tables
    -- rather than use delete. The tst_prior table is not used for initial load.
    --

    IF (NOT (fnd_installation.get_app_info('OPI', s_status, s_industry, s_opi_schema))) THEN
        RAISE schema_info_not_found;
    END IF;

    -- Clear OPM-specific work tables and populate prior table
    l_stmt_id := 10;
--Following lines moved from end of Initial and Incremental ETL by CDALY 11/13/03
--Now only called here at the beginning of Incremental ETL
    -- Move tst_current data to tst_prior
    capture_opm_tst_prior;


    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' || 'opi_dbi_opm_wip_tst_current');
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' || 'opi_dbi_opm_wip_led_current');

    -- Check if all the bounds have been properly set up
    l_stmt_id := 20;
    IF (NOT (opi_dbi_common_mod_init_pkg.init_end_bounds_setup
                (WIP_COMPLETION_ETL, OPM_SOURCE))) THEN
        RAISE run_common_module;
    END IF;

    -- Collect WIP Completions from Permanent (led) and Test (tst) Subledgers
    l_stmt_id := 30;
    collect_opm_led_current(p_global_start_date);
    l_stmt_id := 40;
    collect_opm_tst_current(p_global_start_date);

    -- Sum up WIP Completions, join in other needed tables
    l_stmt_id := 50;
    collect_incr_opm_stg;

    -- Report success to OPI_DBI_RUN_LOG_CURR.
    l_stmt_id := 60;
    IF (NOT (opi_dbi_common_mod_incr_pkg.etl_report_success
                (WIP_COMPLETION_ETL, OPM_SOURCE))) THEN
        RAISE could_not_log_success;
    END IF;

-- Added 11/13/03 by CDALY
-- set stop_reason_code in log to NULL to indicate to capture_opm_tst_prior that prior table is no longer needed
    update opi_dbi_run_log_curr           -- state = successful
         set
             stop_reason_code  = NULL,       -- flag to indicate prior tst table has been populated
             last_update_date  = sysdate,
             last_updated_by   = s_user_id,
             last_update_login = s_login_id
        where etl_id = 1
          and source = 2;

-- Following lines moved to beginning of this Incremental ETL by CDALY 11/13/03
    -- Move tst_current date to tst_prior
--    l_stmt_id := 70;
--    capture_opm_tst_prior;

    -- Since data pushed to staging table and success logged, commit everything
    l_stmt_id := 80;
    COMMIT;

    -- Truncate work tables whose data is no longer needed
    l_stmt_id := 90;

-- Following line moved to capture_opm_tst_prior by CDALY 11/13/03
--    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' || 'opi_dbi_opm_wip_tst_current');

    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' || 'opi_dbi_opm_wip_tst_prior');
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' || 'opi_dbi_opm_wip_led_current');

    -- all done, so return successfully.
    l_stmt_id := 100;
    retcode := s_SUCCESS;
    errbuf := '';
    return;

EXCEPTION

    WHEN could_not_log_success THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' || l_proc_name || ' ' ||
                              '#' || l_stmt_id || ': ' ||
                              'WIP Completion ETLs Initial load OPI data extraction success could not be logged into log table. Aborting.');


        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Completion ETLs Initial load OPI data extraction success could not be logged into log table. Aborting.';
        RAISE;  -- propagate exception to wrapper.


    WHEN OTHERS THEN
        rollback;

        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' || l_proc_name || ' ' ||
                              '#' || l_stmt_id || ': ' ||  SQLERRM);

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ' ' || '#' ||
                  l_stmt_id || ': ' ||
                  'WIP Completion ETLs Initial load OPI data extraction failed.';
        RAISE;  -- propagate exception to wrapper.

END collect_incr_opm_wip_comp;


END opi_dbi_wip_comp_opm_pkg;

/
