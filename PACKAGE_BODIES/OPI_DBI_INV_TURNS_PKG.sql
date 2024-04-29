--------------------------------------------------------
--  DDL for Package Body OPI_DBI_INV_TURNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_INV_TURNS_PKG" AS
/* $Header: OPIDEIVTNB.pls 120.0 2005/05/24 18:36:40 appldev noship $ */

/* File scope globals */
g_user_id NUMBER;
g_login_id NUMBER;
g_degree NUMBER;


/*++++++++++++++++++++++++++++++++++++++++*/
/* PACKAGE LEVEL CONSTANTS */
/*++++++++++++++++++++++++++++++++++++++++*/

s_pkg_name CONSTANT VARCHAR2 (50) := 'opi_dbi_inv_turns_pkg';
s_ERROR CONSTANT NUMBER := -1;   -- concurrent manager error code
s_WARNING CONSTANT NUMBER := 1;  -- concurrent manager warning code
s_SUCCESS CONSTANT NUMBER := 0;  -- concurrent manager success code


/*++++++++++++++++++++++++++++++++++++++++*/
/*  Package level exceptions defined for
    clearer error handling. */
/*++++++++++++++++++++++++++++++++++++++++*/

-- exception to raise if the temp table already exists
OBJECT_ALREADY_EXISTS EXCEPTION;
PRAGMA EXCEPTION_INIT (OBJECT_ALREADY_EXISTS, -955);


-- exception to raise if set up is not correct
SETUP_INVALID EXCEPTION;
PRAGMA EXCEPTION_INIT (SETUP_INVALID, -20000);

-- exception to raise if unable to get schema information
SCHEMA_INFO_NOT_FOUND EXCEPTION;
PRAGMA EXCEPTION_INIT (SCHEMA_INFO_NOT_FOUND, -20001);


/* initialize globals

    Procedure to initialize global/file scope variables

    Date            Author              Action
    04/29/04        Dinkar Gupta        Writing this
                                        function because new GSCC standard
                                        does not like globals initialized
                                        on declaration
*/
PROCEDURE initialize_globals
IS

    l_stmt_num NUMBER;
    l_proc_name VARCHAR2 (40);

BEGIN

    l_proc_name := 'initialize_globals';

    g_user_id := fnd_global.user_id;
    g_login_id := fnd_global.login_id;
    g_degree := 0;


END initialize_globals;


/*
    Refresh_inventory_turns

    Main procedure to refresh inventory turns.

    Date            Author              Action
    <>              Luis Tong           Wrote function.
    05/03/04        Dinkar Gupta        Bug fix 3593181. See file
                                        header for details.
*/

PROCEDURE Refresh_Inventory_Turns (errbuf OUT NOCOPY VARCHAR2,
                                   retcode OUT NOCOPY NUMBER)
IS

    l_stmt_num NUMBER;
    l_proc_name VARCHAR2 (40);

    l_row_count NUMBER;
    l_min_trx_date DATE;
    l_max_trx_date DATE;
    i_err_num NUMBER;
    i_err_msg VARCHAR2(255);
    TYPE c_range_dates_type IS REF CURSOR;
    c_range_dates c_range_dates_type;
    l_opi_schema      VARCHAR2(30);
    l_status          VARCHAR2(30);
    l_industry        VARCHAR2(30);

BEGIN

    -- Initialization block, as per new GSCC standard
    l_proc_name := 'Refresh_Inventory_Turns';

    -- File scope globals
    initialize_globals ();


    if BIS_COLLECTION_UTILITIES.SETUP( 'OPI_DBI_INV_TURNS_F' ) = false then
        RAISE SETUP_INVALID;
    END IF;

    /* **********************
       Filling missing start date Time bucket rows
       ********************** */

    -- We restrict the completion within the min and max trx_date
    -- of OPI_INV_ITD_ORG_MV

    l_stmt_num := 10;
    IF fnd_installation.get_app_info( 'OPI', l_status,
                                       l_industry, l_opi_schema) THEN
        execute immediate 'truncate table ' || l_opi_schema ||
                          '.OPI_DBI_INV_TURNS_STG ';
    ELSE
        RAISE SCHEMA_INFO_NOT_FOUND;
    END IF;

    -- Pick the smallest date that has inventory or cogs activity
    -- to start at.
    l_stmt_num := 20;
    OPEN c_range_dates FOR
    'select min (transaction_date)
        from (
        select min(TRANSACTION_DATE) transaction_date
          from OPI_INV_ITD_ORG_MV
        union all
        select min (trunc (cogs_date)) transaction_date
          from opi_dbi_cogs_f
          where cogs_date is not null
            and turns_cogs_flag = 1)';
    FETCH c_range_dates INTO l_min_trx_date;
    CLOSE c_range_dates;

    -- Forcing row completion up to today.
    -- This will make the report query return rows up to today
    -- even though there is no data. It will assume balances are
    -- remaining the same.
    -- Also, Compute ITD inventory balance for all those org/date
    -- pairs that are not present in the inventory fact, but
    -- are present in the cogs fact.
    l_max_trx_date := sysdate;

    l_stmt_num := 30;
    INSERT INTO OPI_DBI_INV_TURNS_STG (
        ORGANIZATION_ID,
        TRANSACTION_DATE,
        INV_BALANCE_G,
        INV_BALANCE_B,
        INV_BALANCE_SG
    )
    SELECT
        ORGANIZATION_ID,
        TRANSACTION_DATE,
        INV_BALANCE_G,
        INV_BALANCE_B,
        INV_BALANCE_SG
      FROM
        (
        (
        select  keys.ORGANIZATION_ID ORGANIZATION_ID,
                keys.start_date TRANSACTION_DATE,
                (select INV_BALANCE_G
                  from OPI_INV_ITD_ORG_MV
                  where
                      ORGANIZATION_ID = keys.ORGANIZATION_ID
                  and TRANSACTION_DATE =
                            (select max(TRANSACTION_DATE) max_date
                               from OPI_INV_ITD_ORG_MV
                               where
                                   TRANSACTION_DATE <= keys.start_date
                               and ORGANIZATION_ID = keys.ORGANIZATION_ID)
                  and rownum < 2
                ) INV_BALANCE_G,
                (select INV_BALANCE_B
                  from OPI_INV_ITD_ORG_MV
                  where
                      ORGANIZATION_ID = keys.ORGANIZATION_ID
                  and TRANSACTION_DATE =
                            (select max(TRANSACTION_DATE) max_date
                               from OPI_INV_ITD_ORG_MV
                               where
                                   TRANSACTION_DATE <= keys.start_date
                               and ORGANIZATION_ID = keys.ORGANIZATION_ID)
                  and rownum < 2
                ) INV_BALANCE_B,
                (select INV_BALANCE_SG
                  from OPI_INV_ITD_ORG_MV
                  where
                      ORGANIZATION_ID = keys.ORGANIZATION_ID
                  and TRANSACTION_DATE =
                            (select max(TRANSACTION_DATE) max_date
                               from OPI_INV_ITD_ORG_MV
                               where
                                   TRANSACTION_DATE <= keys.start_date
                               and ORGANIZATION_ID = keys.ORGANIZATION_ID)
                  and rownum < 2
                ) INV_BALANCE_SG
          from
            (SELECT
                    ot.organization_id organization_id,
                    sd.start_date start_date
              FROM
                (
                select ORGANIZATION_ID
                  from OPI_INV_ITD_ORG_MV
                  group by ORGANIZATION_ID
                ) ot,
                (
                select start_date
                  from
                    (
                    select distinct WEEK_START_DATE start_date
                      from FII_TIME_DAY_ALL_V
                      where REPORT_DATE between l_min_trx_date and
                                                l_max_trx_date
                    union
                    select distinct ENT_PERIOD_START_DATE start_date
                      from FII_TIME_DAY_ALL_V
                      where REPORT_DATE between l_min_trx_date and
                                                l_max_trx_date
                    union
                    select distinct ENT_QTR_START_DATE start_date
                      from FII_TIME_DAY_ALL_V
                      where REPORT_DATE between l_min_trx_date and
                                                l_max_trx_date
                    union
                    select distinct ENT_YEAR_START_DATE start_date
                      from FII_TIME_DAY_ALL_V
                      where REPORT_DATE between l_min_trx_date and
                                                l_max_trx_date
                    )
                 where start_date between l_min_trx_date and l_max_trx_date
                ) sd
             UNION
             SELECT organization_id,
                    start_date
               FROM
                (
                 SELECT DISTINCT
                        organization_id organization_id,
                        trunc (cogs_date) start_date
                   FROM opi_dbi_cogs_f
                   WHERE cogs_date is not null
                     AND turns_cogs_flag = 1
                 MINUS
                 SELECT DISTINCT
                        organization_id organization_id,
                        transaction_date start_date
                   FROM opi_inv_itd_org_mv) cogs_keys
            ) keys
        )
        union
        select
            ORGANIZATION_ID,
            TRANSACTION_DATE,
            INV_BALANCE_G,
            INV_BALANCE_B,
            INV_BALANCE_SG
          from OPI_INV_ITD_ORG_MV
        );

    BIS_COLLECTION_UTILITIES.PUT_LINE('Finished Filling missing start date Time bucket rows process.');

 /* *******************************
    Calculating Weights, adding start dates
    ******************************* */


    l_stmt_num := 40;
    IF fnd_installation.get_app_info( 'OPI', l_status,
                                       l_industry, l_opi_schema) THEN
        execute immediate 'truncate table ' || l_opi_schema ||
                          '.OPI_DBI_INV_TURNS_F ';
    ELSE
        RAISE SCHEMA_INFO_NOT_FOUND;
    END IF;

    l_stmt_num := 50;
    -- This query was modified to do a full outer join between the
    -- COGS fact and TURNS stg table. However, that is not needed
    -- anymore since we ensure that all COGS keys are put into
    -- the TURNS stg. That is the only place we compute ITD inventory
    -- value for those COGS keys that are not part of the inventory fact.
    -- Since turns = annualized inv/annualized cogs, make sure the cogs
    -- value is never NULL. A corresponding fix was made the
    -- opi_inv_itd_org_mv. The MV earlier had a unique key of org, date
    -- and source, which caused two rows to be created for the same org/date
    -- once CPCS was introduced with source = 3. The MV has been modified
    -- to have a unique key of org, date.
    INSERT /*+ append */
    INTO opi_dbi_inv_turns_f
    (
        organization_id,
        transaction_date,
        start_date_wtd,
        start_date_mtd,
        start_date_qtd,
        start_date_ytd,
        weight,
        inv_balance_g,
        inv_balance_b,
        inv_balance_sg,
        cogs_val_g,
        cogs_val_b,
        cogs_val_sg,
        source,
        created_by,
        last_update_login,
        creation_date,
        last_updated_by,
        last_update_date
    )
    SELECT
        turns.organization_id,
        turns.transaction_date,
        cal.week_start_date start_date_wtd,
        cal.ent_period_start_date start_date_mtd,
        cal.ent_qtr_start_date start_date_qtd,
        cal.ent_year_start_date start_date_ytd,
        nvl (lead (turns.transaction_date, 1) over
             (partition by turns.organization_id
              order by turns.transaction_date) - turns.transaction_date,
             1) weight,
        turns.inv_balance_g inv_balance_g,
        turns.inv_balance_b inv_balance_b,
        turns.inv_balance_sg inv_balance_sg,
        nvl (cogs.cogs_val_g, 0) cogs_val_g,
        nvl (cogs.cogs_val_b, 0) cogs_val_b,
        nvl (cogs.cogs_val_sg, 0) cogs_val_sg,
        1, -- actually this does not matter here.
        g_user_id,
        g_login_id,
        sysdate,
        g_user_id,
        sysdate
      FROM
        opi_dbi_inv_turns_stg turns,
        fii_time_day_all_v cal,
        (SELECT /*+ no_merge */
                organization_id,
                trunc (cogs_date) cogs_date,
                nvl (sum (cogs_val_b), 0) cogs_val_b,
                nvl (sum (cogs_val_g), 0) cogs_val_g,
                nvl (sum (cogs_val_sg), 0) cogs_val_sg
           FROM opi_dbi_cogs_f
           WHERE cogs_date is not null
             AND turns_cogs_flag = 1
           GROUP BY
                organization_id,
                trunc (cogs_date)) cogs
        WHERE turns.transaction_date = cal.report_date
          AND turns.transaction_date = cogs.cogs_date(+)
          AND turns.organization_id = cogs.organization_id(+);

    l_row_count := sql%rowcount;

    BIS_COLLECTION_UTILITIES.PUT_LINE ('Inserted ' || l_row_count ||
                                       ' rows into the turns table successfully.');
    BIS_COLLECTION_UTILITIES.WRAPUP (TRUE, l_row_count,
                                     'Pushed successfully into turns table.');
    COMMIT;

    errbuf := '';
    retcode := s_SUCCESS;

EXCEPTION

    WHEN SETUP_INVALID THEN

        rollback;

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ': #' ||
                  to_char (l_stmt_num) || ': ' ||
                  'Setup of OPI_DBI_INV_TURNS_F table is incorrect.';

        BIS_COLLECTION_UTILITIES.WRAPUP(FALSE,
                                        l_row_count,
                                        'EXCEPTION '|| SQLCODE ||' : ' ||
                                        errbuf);


        return;


    WHEN SCHEMA_INFO_NOT_FOUND THEN

        rollback;

        retcode := s_ERROR;
        errbuf := s_pkg_name || '.' || l_proc_name || ': #' ||
                  to_char (l_stmt_num) || ': ' ||
                  'Unable to get OPI schema information.';

        BIS_COLLECTION_UTILITIES.WRAPUP(FALSE,
                                        l_row_count,
                                        'EXCEPTION '|| SQLCODE ||' : ' ||
                                        errbuf);


        return;

    WHEN OTHERS THEN

        rollback;

        retcode := s_ERROR;
            errbuf := s_pkg_name || '.' || l_proc_name || ': ' ||
                  to_char (l_stmt_num) || ': ' ||
                  substr(SQLERRM, 1,200);


        BIS_COLLECTION_UTILITIES.WRAPUP(FALSE,
                                        l_row_count,
                                        'EXCEPTION '|| SQLCODE ||' : ' ||
                                        errbuf);
        return;

END Refresh_Inventory_Turns;

END OPI_DBI_INV_TURNS_PKG;

/
