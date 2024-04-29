--------------------------------------------------------
--  DDL for Package Body OPI_DBI_COGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_COGS_PKG" AS
/* $Header: OPIDECOGSB.pls 120.15 2007/03/15 07:36:24 kvelucha ship $ */



/*=========================================
    Package Level Constants
==========================================*/

-- ETLs stop reason codes
STOP_UNCOSTED   CONSTANT VARCHAR2(30) := 'STOP_UNCOSTED';
STOP_ALL_COSTED CONSTANT VARCHAR2(30) := 'STOP_ALL_COSTED';


-- Marker for secondary conv. rate if the primary and secondary curr codes
-- and rate types are identical. Can't be -1, -2, -3 since the FII APIs
-- return those values.
C_PRI_SEC_CURR_SAME_MARKER  CONSTANT NUMBER := -9999;


--GL API returns -3 if EURO rate missing on 01-JAN-1999
C_EURO_MISSING_AT_START     CONSTANT NUMBER := -3;


-- return codes
g_ERROR     CONSTANT NUMBER := -1;
g_WARNING   CONSTANT NUMBER := 1;
g_ok        CONSTANT NUMBER := 0;


-- Source constants
OPI_SOURCE CONSTANT NUMBER := 1;
OPM_SOURCE CONSTANT NUMBER := 2;
PRE_R12_OPM_SOURCE CONSTANT NUMBER := 3;


g_euro_start_date CONSTANT DATE := to_date('01/01/1999','DD/MM/YYYY');


/*=========================================
    Package Level Variables
==========================================*/

-- Stage failure.
stage_failure EXCEPTION;
PRAGMA EXCEPTION_INIT (stage_failure, -20004);

-- Standard WHO columns
g_user_id                   NUMBER;
g_login_id                  NUMBER;
g_program_id                NUMBER;
g_program_login_id          NUMBER;
g_program_application_id    NUMBER;
g_request_id                NUMBER;


-- Conversion rate related variables
g_global_currency_code      VARCHAR2(10);
g_secondary_currency_code   VARCHAR2(10);
g_global_rate_type          VARCHAR2(15);
g_secondary_rate_type       VARCHAR2(15);


-- DBI Global start date
g_global_start_date         DATE;


/*===============================================================
    This procedure gather statistics of a table.

    Parameters:
    - p_table_name: table name
================================================================*/

PROCEDURE gather_stats(p_table_name VARCHAR2) IS

    l_table_owner   user_synonyms.table_owner%type;

    cursor get_table_owner is
        SELECT  table_owner
        FROM    user_synonyms
        WHERE   synonym_name = p_table_name;

    data_no_found   exception;
BEGIN

    bis_collection_utilities.put_line('Enter gather_stats() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    -- Find owner of the table passed to procedure
    open get_table_owner;
        fetch get_table_owner into l_table_owner;

        IF get_table_owner%notfound THEN
        --{
            raise data_no_found;
        --}
        END IF;
    close get_table_owner;

    -- Gather table statistics to be used by CBO
    -- for query optimization.

    fnd_stats.gather_table_stats(l_table_owner, p_table_name,
                                 percent=>10, degree=>4, cascade=>TRUE);

    bis_collection_utilities.put_line('Exit gather_stats '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));


END gather_stats;


/*===============================================================
    This procedure sets up global parameters, such as the global
    start date, globla/secondary currencies, WHO column variables.

    Parameters:
    - errbuf:   error buffer
    - retcode:  return code
=================================================================*/
PROCEDURE check_setup_globals(  errbuf  IN OUT NOCOPY VARCHAR2 ,
                                retcode IN OUT NOCOPY VARCHAR2) IS

    l_list              dbms_sql.varchar2_table;
    l_from_date         date;
    l_to_date           date;
    l_missing_day_flag  boolean;
    l_min_miss_date     date;
    l_max_miss_date     date;

BEGIN

    bis_collection_utilities.put_line('Enter check_setup_globals() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    -- Initialization block
    l_missing_day_flag := FALSE;
    retcode   := g_ok;


    -- package level variables
    g_user_id := nvl(fnd_global.user_id, -1);
    g_login_id := nvl(fnd_global.login_id, -1);
    g_program_id := nvl (fnd_global.conc_program_id, -1);
    g_program_login_id := nvl (fnd_global.conc_login_id, -1);
    g_program_application_id := nvl (fnd_global.prog_appl_id,  -1);
    g_request_id := nvl (fnd_global.conc_request_id, -1);


    -- check for mandatory global setups
    l_list(1) := 'BIS_PRIMARY_CURRENCY_CODE';
    l_list(2) := 'BIS_GLOBAL_START_DATE';
    l_list(3) := 'BIS_PRIMARY_RATE_TYPE';

    IF (bis_common_parameters.check_global_parameters(l_list)) THEN
    --{

        -- Since these are file scope variables that are cached at a session
        -- level, make sure to reinitialize them explicitly each time.

        -- GSD - already checked if GSD is set up
        g_global_start_date := bis_common_parameters.get_global_start_date;

        -- Global currency codes - already checked if primary is set up
        g_global_currency_code := bis_common_parameters.get_currency_code;
        g_secondary_currency_code :=
                    bis_common_parameters.get_secondary_currency_code;

        -- Global rate types -- already checked if primary is set up
        g_global_rate_type := bis_common_parameters.get_rate_type;
        g_secondary_rate_type := bis_common_parameters.get_secondary_rate_type;

         -- check that either both the secondary rate type and secondary
        -- rate are null, or that neither are null.

        IF ((g_secondary_currency_code IS NULL and
             g_secondary_rate_type IS NOT NULL) OR
            (g_secondary_currency_code IS NOT NULL and
             g_secondary_rate_type IS NULL) ) THEN
        --{
                retcode := g_error;
                errbuf := 'Please check log file for details';
                bis_collection_utilities.put_line ('The global secondary currency code setup is incorrect.  ' ||
                                                   'The secondary currency code cannot be null when the secondary ' ||
                                                   'rate type is defined and vice versa.');
        --}

        END IF;

        -- Sysdate
        SELECT sysdate INTO l_to_date FROM dual;

        -- check_missing_date
        fii_time_api.check_missing_date (g_global_start_date,
                                        l_to_date,
                                        l_missing_day_flag,
                                        l_min_miss_date,
                                        l_max_miss_date);

        IF l_missing_day_flag THEN
        --{
            retcode := g_error;
            errbuf  := 'Please check log file for details. ';
            bis_collection_utilities.put_line('There are missing date in time dimension.');
            bis_collection_utilities.put_line( 'The range is from '
                                                || l_min_miss_date
                                                ||' to ' || l_max_miss_date );
        --}
        END IF;
    --}
    ELSE
    --{
        retcode := g_error;
        errbuf  := 'Please check log file for details. ';
        bis_collection_utilities.put_line('Global Parameters are not setup.');

        bis_collection_utilities.put_line('Please check that the profile options: BIS_PRIMARY_CURRENCY_CODE,  BIS_GLOBAL_START_DATE, BIS_PRIMARY_RATE_TYPE are setup.');
    --}
    END IF;

     bis_collection_utilities.put_line('Exit check_setup_globals() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION
    WHEN OTHERS THEN
    --{
        retcode := SQLCODE;
        errbuf := 'Error in opi_dbi_cogs_pkg.check_setup_globals ' || substr(SQLERRM, 1,200);

        bis_collection_utilities.put_line('Error Number: ' ||  retcode);
        bis_collection_utilities.put_line('Error Message: ' || errbuf);
    --}
END check_setup_globals;


/*===============================================================
    This procedure extracts discrete data into the staging table
    for initial load.

    Parameters:
    - errbuf: error buffer
    - retcode : return code
================================================================*/

PROCEDURE init_opi_cogs ( errbuf    IN OUT NOCOPY  VARCHAR2,
                          retcode   IN OUT NOCOPY  VARCHAR2 ) IS

BEGIN

    bis_collection_utilities.put_line('Enter init_opi_cogs() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));


    retcode := 0;

    -- big insert for OPI COGS

     INSERT /*+ append parallel(m) */ INTO opi_dbi_cogs_fstg m (
        m.inventory_item_id,
        m.organization_id,
        m.order_line_id,
        m.top_model_line_id,
        m.top_model_item_id,
        m.top_model_item_uom,
        m.top_model_org_id,
        m.customer_id,
        m.cogs_val_b_draft,
        m.cogs_val_b,
        m.cogs_date,
        m.source,
        m.turns_cogs_flag,
        m.internal_flag )
     -- 2 Regular sales order  -- 8 Internal Sales Order
    SELECT /*+ use_hash(mmt)
                parallel(log) parallel(mmt) parallel(mta)
                parallel(l) parallel(pl) parallel(h)
                parallel(cust_acct) parallel(item)*/
            mmt.inventory_item_id,
            mmt.organization_id,
            lines.line_id,
            p_lines.line_id             top_model_line_id,
            p_lines.inventory_item_id   top_model_item_id,
            item.primary_uom_code       top_model_item_uom,
            p_lines.ship_from_org_id    top_model_org_id,
            nvl(cust_acct.party_id, -1),
            0                       cogs_val_b_draft,
            mta.base_transaction_value,
            mmt.transaction_date,
            OPI_SOURCE,
            decode(p_lines.source_type_code, 'EXTERNAL', 2, 1 ),
            decode(p_lines.order_source_id,10,1,0)
    FROM    opi_dbi_conc_prog_run_log       log,
            mtl_material_transactions       mmt,
            mtl_transaction_accounts        mta,
            oe_order_lines_all              lines,  -- child line
            oe_order_lines_all              p_lines, -- parent line
            oe_order_headers_all            header,
            hz_cust_accounts                cust_acct,
            mtl_system_items_b              item
    WHERE   mmt.transaction_id >= log.from_bound_id
    AND     mmt.transaction_id < log.to_bound_id
    AND     mmt.organization_id = log.bound_level_entity_id
    AND     log.load_type = 'INIT'
    AND     log.etl_type =  'COGS'
    AND     mmt.transaction_source_type_id IN (2,8)
    AND     mmt.transaction_type_id        in (33, 34, 62)
    AND     mmt.transaction_action_id      IN (1, 21)
    AND     mmt.transaction_id = mta.transaction_id
    AND     mta.accounting_line_type <> 1
    AND     lines.line_id = mmt.trx_source_line_id
    AND     lines.order_source_id <> 27  -- retroactive billing
    AND     p_lines.line_id = nvl(lines.top_model_line_id, lines.line_id)
    AND     lines.header_id        = header.header_id
    AND     header.sold_to_org_id   = cust_acct.cust_account_id(+)
    AND     item.inventory_item_id = p_lines.inventory_item_id
    AND     item.organization_id   = p_lines.ship_from_org_id
    UNION ALL
    -- 12 RMA
    SELECT /*+ index(mmt,MTL_MATERIAL_TRANSACTIONS_N8)
                use_nl(mmt,item,mta,h,cust_acct)
                parallel(log) parallel(mmt) parallel(mta) parallel(l) parallel(pl)
                parallel(cl) parallel(h) parallel(cust_acct) parallel(item)*/
            mmt.inventory_item_id,
            mmt.organization_id,
            lines.line_id,
            p_lines.line_id             top_model_line_id,
            p_lines.inventory_item_id   top_model_item_id,
            item.primary_uom_code       top_model_item_uom,
            p_lines.ship_from_org_id    top_model_org_id,
            nvl(cust_acct.party_id, -1),
            0                           cogs_val_b_draft,
            mta.base_transaction_value,
            mmt.transaction_date,
            OPI_SOURCE,
            1,
            0
    FROM    opi_dbi_conc_prog_run_log       log,
            mtl_material_transactions       mmt,
            mtl_transaction_accounts        mta,
            oe_order_lines_all              lines,  -- child line
            oe_order_lines_all              l_lines,     -- linking line
            oe_order_lines_all              p_lines, -- parent line
            oe_order_headers_all            header,
            hz_cust_accounts                cust_acct,
            mtl_system_items_b              item
    WHERE   mmt.transaction_id >= log.from_bound_id
    AND     mmt.transaction_id < log.to_bound_id
    AND     mmt.organization_id = log.bound_level_entity_id
    AND     log.load_type = 'INIT'
    AND     log.etl_type = 'COGS'
    AND     mmt.transaction_source_type_id = 12
    AND     mmt.transaction_id = mta.transaction_id
    AND     mta.accounting_line_type <> 1
    AND     lines.line_id = mmt.trx_source_line_id
    AND     lines.line_category_code = 'RETURN'
    AND     lines.order_source_id <> 27  -- retroactive billing
    AND     l_lines.line_id = nvl(lines.link_to_line_id, lines.line_id)
    AND     p_lines.line_id = nvl(l_lines.top_model_line_id, l_lines.line_id)
    AND     lines.header_id        = header.header_id
    AND     header.sold_to_org_id   = cust_acct.cust_account_id(+)
    AND     item.inventory_item_id = p_lines.inventory_item_id
    AND     item.organization_id   = p_lines.ship_from_org_id
    UNION ALL
    -- Drop ship
     SELECT /*+ leading(log) use_nl(mmt) index(mmt,MTL_MATERIAL_TRANSACTIONS_N9)
                parallel(log) parallel(mmt) parallel(mta) parallel(l) parallel(pl)
                parallel(h) parallel(cust_acct) parallel(item)*/
            mmt.inventory_item_id,
            mmt.organization_id,
            lines.line_id,
            p_lines.line_id             top_model_line_id,
            p_lines.inventory_item_id   top_model_item_id,
            item.primary_uom_code       top_model_item_uom,
            p_lines.ship_from_org_id    top_model_org_id,
            nvl(cust_acct.party_id, -1),
            0                       cogs_val_b_draft,
            mta.base_transaction_value,
            mmt.transaction_date,
            OPI_SOURCE,
            decode(p_mmt.transaction_type_id, 33, 1, 2),
            0
    FROM    opi_dbi_conc_prog_run_log       log,
            mtl_material_transactions       mmt,
            mtl_material_transactions       p_mmt,
            mtl_transaction_accounts        mta,
            oe_order_lines_all              lines,
            oe_order_lines_all              p_lines, -- parent line
            oe_order_headers_all            header,
            hz_cust_accounts                cust_acct,
            mtl_system_items_b              item
    WHERE   mmt.transaction_id >= log.from_bound_id
    AND     mmt.transaction_id < log.to_bound_id
    AND     mmt.organization_id = log.bound_level_entity_id
    AND     log.load_type = 'INIT'
    AND     log.etl_type = 'COGS'
    AND     mmt.transaction_type_id     in (11,30)
    AND     mmt.transaction_action_id   in (7,9)
    AND     mmt.organization_id         = lines.ship_from_org_id
    AND     p_mmt.transaction_id        = mmt.parent_transaction_id
    AND     ( -- internal drop
             (p_mmt.transaction_type_id = 33
              and p_mmt.transaction_action_id = 1 )
            OR -- external drop
             (p_mmt.transaction_type_id = 19
              and p_mmt.transaction_action_id = 26 ))
    AND     mmt.transaction_id = mta.transaction_id
    AND     mta.accounting_line_type <> 1
    AND     lines.line_id = mmt.trx_source_line_id
    AND     lines.order_source_id <> 27  -- retroactive billing
    AND     p_lines.line_id = nvl(lines.top_model_line_id, lines.line_id)
    AND     lines.header_id        = header.header_id
    AND     header.sold_to_org_id   = cust_acct.cust_account_id(+)
    AND     item.inventory_item_id = p_lines.inventory_item_id
    AND     item.organization_id   = p_lines.ship_from_org_id;

    COMMIT;

     bis_collection_utilities.put_line('Exit init_opi_cogs() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN
--{
   errbuf:= Sqlerrm;
   retcode:= SQLCODE;

   ROLLBACK;

   bis_collection_utilities.put_line('Exception in init_opi_cogs ' || errbuf );
--}
END init_opi_cogs;



/*===============================================================
    This procedure extracts discrete data into the staging table
    for incremental load.

    Parameters:
    - errbuf: error buffer
    - retcode : return code
================================================================*/

PROCEDURE incremental_opi_cogs ( errbuf      IN OUT NOCOPY  VARCHAR2,
                                 retcode     IN OUT NOCOPY  VARCHAR2 ) IS

BEGIN

    bis_collection_utilities.put_line('Enter incremental_opi_cogs() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    retcode := 0;

    INSERT /*+ append */ INTO opi_dbi_cogs_fstg m (
            m.inventory_item_id,
            m.organization_id,
            m.order_line_id,
            m.top_model_line_id,
            m.top_model_item_id,
            m.top_model_item_uom,
            m.top_model_org_id,
            m.customer_id,
            m.cogs_val_b_draft,
            m.cogs_val_b,
            m.cogs_date,
            m.source,
            m.turns_cogs_flag,
            m.internal_flag
            )
      -- 2 Regular sales order  -- 8 Internal Sales Order
    SELECT /*+ leading(log) index(mmt,MTL_MATERIAL_TRANSACTIONS_U2) use_nl(mmt,item,mta,h,cust_acct) */
            mmt.inventory_item_id,
            mmt.organization_id,
            lines.line_id,
            p_lines.line_id             top_model_line_id,
            p_lines.inventory_item_id   top_model_item_id,
            item.primary_uom_code       top_model_item_uom,
            p_lines.ship_from_org_id    top_model_org_id,
            nvl(cust_acct.party_id, -1),
            0                           cogs_val_b_draft,
            mta.base_transaction_value,
            mmt.transaction_date,
            OPI_SOURCE,
            decode(p_lines.source_type_code, 'EXTERNAL', 2, 1 ),
            decode(p_lines.order_source_id,10,1,0)
    FROM    opi_dbi_conc_prog_run_log   log,
            mtl_material_transactions   mmt,
            mtl_transaction_accounts    mta,
            oe_order_lines_all          lines,  -- child line
            oe_order_lines_all          p_lines, -- parent line
            oe_order_headers_all        header,
            hz_cust_accounts            cust_acct,
            mtl_system_items_b          item
    WHERE   mmt.transaction_id >= log.from_bound_id
    AND     mmt.transaction_id < log.to_bound_id
    AND     mmt.organization_id = log.bound_level_entity_id
    AND     log.load_type = 'INCR'
    AND     log.etl_type = 'COGS'
    AND     mmt.transaction_source_type_id IN (2,8)
    and     mmt.transaction_type_id        in (33, 34, 62)
    and     mmt.transaction_action_id      IN (1, 21)
    and     mmt.transaction_id = mta.transaction_id
    and     mta.accounting_line_type <> 1
    and     lines.line_id = mmt.trx_source_line_id
    and     lines.order_source_id <> 27  -- retroactive billing
    AND     p_lines.line_id = nvl(lines.top_model_line_id, lines.line_id)
    and     lines.header_id        = header.header_id
    and     header.sold_to_org_id   = cust_acct.cust_account_id(+)
    and     item.inventory_item_id = p_lines.inventory_item_id
    and     item.organization_id   = p_lines.ship_from_org_id
    UNION ALL    -- 12 RMA
    SELECT /*+ leading(log) use_nl(mmt) */
            mmt.inventory_item_id,
            mmt.organization_id,
            lines.line_id,
            p_lines.line_id             top_model_line_id,
            p_lines.inventory_item_id   top_model_item_id,
            item.primary_uom_code       top_model_item_uom,
            p_lines.ship_from_org_id    top_model_org_id,
            nvl(cust_acct.party_id, -1),
            0                           cogs_val_b_draft,
            mta.base_transaction_value,
            mmt.transaction_date,
             OPI_SOURCE,
            1,
            0
    FROM    opi_dbi_conc_prog_run_log       log,
            mtl_material_transactions       mmt,
            mtl_transaction_accounts        mta,
            oe_order_lines_all              lines,  -- child line
            oe_order_lines_all              l_lines,     -- linking line
            oe_order_lines_all              p_lines, -- parent line
            oe_order_headers_all            header,
            hz_cust_accounts                cust_acct,
            mtl_system_items_b              item
    WHERE   mmt.transaction_id >= log.from_bound_id
    AND     mmt.transaction_id < log.to_bound_id
    AND     mmt.organization_id = log.bound_level_entity_id
    AND     log.load_type = 'INCR'
    AND     log.etl_type = 'COGS'
    AND     mmt.transaction_source_type_id = 12
    AND     mmt.transaction_id = mta.transaction_id
    AND     mta.accounting_line_type <> 1
    AND     lines.line_id = mmt.trx_source_line_id
    AND     lines.order_source_id <> 27  -- retroactive billing
    AND     lines.line_category_code = 'RETURN'
    AND     l_lines.line_id = nvl(lines.link_to_line_id, lines.line_id)
    AND     p_lines.line_id = nvl(l_lines.top_model_line_id, l_lines.line_id)
    AND     lines.header_id        = header.header_id
    AND     header.sold_to_org_id   = cust_acct.cust_account_id(+)
    AND     item.inventory_item_id = p_lines.inventory_item_id
    AND     item.organization_id   = p_lines.ship_from_org_id
    UNION ALL    -- drop ship
    SELECT /*+ leading(log) use_nl(mmt) index(mmt,MTL_MATERIAL_TRANSACTIONS_N9) */
            mmt.inventory_item_id,
            mmt.organization_id,
            lines.line_id,
            p_lines.line_id             top_model_line_id,
            p_lines.inventory_item_id   top_model_item_id,
            item.primary_uom_code       top_model_item_uom,
            p_lines.ship_from_org_id    top_model_org_id,
            nvl(cust_acct.party_id, -1),
            0                           cogs_val_b_draft,
            mta.base_transaction_value,
            mmt.transaction_date,
            OPI_SOURCE,
            decode(p_mmt.transaction_type_id, 33, 1, 2),
            0
    FROM    opi_dbi_conc_prog_run_log       log,
            mtl_material_transactions       mmt,
            mtl_material_transactions       p_mmt,
            mtl_transaction_accounts        mta,
            oe_order_lines_all              lines,
             oe_order_lines_all              p_lines, -- parent line
            oe_order_headers_all            header,
            hz_cust_accounts                cust_acct,
            mtl_system_items_b              item
    WHERE   mmt.transaction_id >= log.from_bound_id
    AND     mmt.transaction_id < log.to_bound_id
    AND     mmt.organization_id = log.bound_level_entity_id
    AND     log.load_type = 'INCR'
    AND     log.etl_type = 'COGS'
    AND     mmt.transaction_type_id     in (11,30)
    AND     mmt.transaction_action_id   in (7,9)
    AND     mmt.organization_id         = lines.ship_from_org_id
    AND     p_mmt.transaction_id        = mmt.parent_transaction_id
    AND     ( -- internal drop
             (p_mmt.transaction_type_id = 33
              and p_mmt.transaction_action_id = 1 )
            OR -- external drop
             (p_mmt.transaction_type_id = 19
              and p_mmt.transaction_action_id = 26 ))
    AND     mmt.transaction_id = mta.transaction_id
    AND     mta.accounting_line_type <> 1
    AND     lines.line_id = mmt.trx_source_line_id
    AND     p_lines.line_id = nvl(lines.top_model_line_id, lines.line_id)
    AND     lines.header_id        = header.header_id
    AND     lines.order_source_id <> 27  -- retroactive billing
    AND     header.sold_to_org_id   = cust_acct.cust_account_id(+)
    AND     item.inventory_item_id = p_lines.inventory_item_id
    AND     item.organization_id   = p_lines.ship_from_org_id
    ;

    COMMIT;

    bis_collection_utilities.put_line('Exit incremental_opi_cogs() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN
--{
    errbuf:= Sqlerrm;
    retcode:= SQLCODE;

    ROLLBACK;

    bis_collection_utilities.put_line('Exception in incremental_opi_cogs() ' || errbuf );
--}
END incremental_opi_cogs;


/*===============================================================
    This procedure extracts process data into the staging table.

    Parameters:
    - p_from_bound_date: lower run bound
    - p_to_bound_date: upper run bound
    - errbuf: error buffer
    - retcode : return code
================================================================*/
PROCEDURE initial_opm_cogs( p_from_bound_date IN DATE,
                            p_to_bound_date   IN DATE,
                            errbuf      IN OUT NOCOPY VARCHAR2,
                            retcode     IN OUT NOCOPY VARCHAR2) IS

BEGIN

    bis_collection_utilities.put_line('Enter initial_opm_cogs() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    retcode := 0;

    INSERT /*+ append parallel(m) */ INTO opi_dbi_cogs_fstg m (
            m.inventory_item_id,
            m.organization_id,
            m.order_line_id,
            m.top_model_line_id,
            m.top_model_item_id,
            m.top_model_item_uom,
            m.top_model_org_id,
            m.customer_id,
            m.cogs_val_b_draft,
            m.cogs_val_b,
            m.cogs_date,
            m.source,
            m.turns_cogs_flag,
            m.internal_flag
            )
     -- 33 Sales order issue; 34 Internal order issue;  62 Int Order Intr Ship
    SELECT  gtv.inventory_item_id,
            gtv.organization_id,
            lines.line_id,
            p_lines.line_id             top_model_line_id,
            p_lines.inventory_item_id   top_model_item_id,
            item.primary_uom_code       top_model_item_uom,
            p_lines.ship_from_org_id    top_model_org_id,
            nvl(cust_acct.party_id, -1),
            gtv.draft_value,
            gtv.final_value,
            gtv.transaction_date,
            OPM_SOURCE,
            decode(p_lines.source_type_code, 'EXTERNAL', 2, 1 ),
            decode(p_lines.order_source_id,10,1,0)
     FROM   oe_order_lines_all              lines,  -- child line
            oe_order_lines_all              p_lines, -- parent line
            oe_order_headers_all            header,
            hz_cust_accounts                cust_acct,
            mtl_system_items_b              item,
         (
            SELECT  gtv.transaction_id,
                    gtv.inventory_item_id,
                    gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date,
                    sum(decode(gtv.accounted_flag, 'D', -gtv.txn_base_value, 0)) draft_value,
                    sum(decode(gtv.accounted_flag, 'D', 0, -gtv.txn_base_value)) final_value
            FROM    gmf_transaction_valuation   gtv,
                    opi_dbi_org_le_temp         tmp
            WHERE   gtv.transaction_type_id in (33, 34, 62)
            AND     nvl(gtv.accounted_flag, 'F') <> 'N'
            AND     nvl(gtv.final_posting_date, p_from_bound_date) >= p_from_bound_date
            AND     nvl(gtv.final_posting_date, p_from_bound_date) < p_to_bound_date
            AND     gtv.transaction_date >= g_global_start_date
            AND     gtv.journal_line_type = 'INV'
            AND     gtv.ledger_id = tmp.ledger_id
            AND     gtv.legal_entity_id = tmp.legal_entity_id
            AND     gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
            AND     gtv.organization_id = tmp.organization_id
            GROUP BY
                    gtv.transaction_id,
                    gtv.inventory_item_id,
                    gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date) gtv
    WHERE   lines.line_id = gtv.line_id
    AND     lines.order_source_id <> 27  -- retroactive billing
    AND     p_lines.line_id = nvl(lines.top_model_line_id, lines.line_id)
    AND     lines.header_id        = header.header_id
    AND     header.sold_to_org_id   = cust_acct.cust_account_id(+)
    AND     item.inventory_item_id = p_lines.inventory_item_id
    AND     item.organization_id   = p_lines.ship_from_org_id
    UNION ALL
    -- 37  RMA Return; 16 Logical RMA Receipt; 15 RMA Receipt
    SELECT  gtv.inventory_item_id,
            gtv.organization_id,
            lines.line_id,
            p_lines.line_id             top_model_line_id,
            p_lines.inventory_item_id   top_model_item_id,
            item.primary_uom_code       top_model_item_uom,
            p_lines.ship_from_org_id    top_model_org_id,
            nvl(cust_acct.party_id, -1),
            gtv.draft_value,
            gtv.final_value,
            gtv.transaction_date,
            OPM_SOURCE,
            1,
            0
    FROM    oe_order_lines_all              lines,  -- child line
            oe_order_lines_all              l_lines, -- linking line
            oe_order_lines_all              p_lines, -- parent line
            oe_order_headers_all            header,
            hz_cust_accounts                cust_acct,
            mtl_system_items_b              item,
            (
            SELECT  gtv.transaction_id,
                    gtv.inventory_item_id,
                      gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date,
                    sum(decode(gtv.accounted_flag, 'D', -gtv.txn_base_value, 0)) draft_value,
                    sum(decode(gtv.accounted_flag, 'D', 0, -gtv.txn_base_value)) final_value
            FROM    gmf_transaction_valuation   gtv,
                    opi_dbi_org_le_temp         tmp
            WHERE   gtv.transaction_type_id in (37, 16, 15)
            AND     nvl(gtv.accounted_flag, 'F') <> 'N'
            AND     nvl(gtv.final_posting_date, p_from_bound_date) >= p_from_bound_date
            AND     nvl(gtv.final_posting_date, p_from_bound_date) < p_to_bound_date
            AND     gtv.transaction_date >= g_global_start_date
            AND     gtv.journal_line_type = 'INV'
            AND     gtv.ledger_id = tmp.ledger_id
            AND     gtv.legal_entity_id = tmp.legal_entity_id
            AND     gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
            AND     gtv.organization_id = tmp.organization_id
            GROUP BY
                    gtv.transaction_id,
                    gtv.inventory_item_id,
                    gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date) gtv
    WHERE   lines.line_id = gtv.line_id
    AND     lines.line_category_code = 'RETURN'
    AND     lines.order_source_id <> 27  -- retroactive billing
    AND     l_lines.line_id = nvl(lines.link_to_line_id, lines.line_id)
    AND     p_lines.line_id = nvl(lines.top_model_line_id, lines.line_id)
    AND     lines.header_id        = header.header_id
    AND     header.sold_to_org_id   = cust_acct.cust_account_id(+)
    AND     item.inventory_item_id = p_lines.inventory_item_id
    AND     item.organization_id   = p_lines.ship_from_org_id
    UNION ALL
    -- Drop Ship
    SELECT  gtv.inventory_item_id,
            gtv.organization_id,
            lines.line_id,
            p_lines.line_id             top_model_line_id,
            p_lines.inventory_item_id   top_model_item_id,
            item.primary_uom_code       top_model_item_uom,
            p_lines.ship_from_org_id    top_model_org_id,
            nvl(cust_acct.party_id, -1),
            gtv.draft_value,
            gtv.final_value,
            gtv.transaction_date,
            OPM_SOURCE,
            1,
            0
     FROM   oe_order_lines_all              lines,  -- child line
            oe_order_lines_all              p_lines, -- parent line
            oe_order_headers_all            header,
            hz_cust_accounts                cust_acct,
            mtl_system_items_b              item,
            mtl_material_transactions       mmt,
            mtl_material_transactions       p_mmt,
             (
            SELECT  gtv.transaction_id,
                    gtv.inventory_item_id,
                    gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date,
                    sum(decode(gtv.accounted_flag, 'D', -gtv.txn_base_value, 0)) draft_value,
                    sum(decode(gtv.accounted_flag, 'D', 0, -gtv.txn_base_value)) final_value
            FROM    gmf_transaction_valuation   gtv,
                    opi_dbi_org_le_temp         tmp
            WHERE   gtv.transaction_type_id in (11, 30) -- 11 Logical intercompany sales issue
                                                        -- 30 Logical sales order issue
            AND     nvl(gtv.accounted_flag, 'F') <> 'N'
            AND     nvl(gtv.final_posting_date, p_from_bound_date) >= p_from_bound_date
            AND     nvl(gtv.final_posting_date, p_from_bound_date) < p_to_bound_date
            AND     gtv.transaction_date >= g_global_start_date
            AND     gtv.journal_line_type = 'INV'
            AND     gtv.ledger_id = tmp.ledger_id
            AND     gtv.legal_entity_id = tmp.legal_entity_id
            AND     gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
            AND     gtv.organization_id = tmp.organization_id
            GROUP BY
                    gtv.transaction_id,
                    gtv.inventory_item_id,
                    gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date) gtv
    WHERE   gtv.transaction_id = mmt.transaction_id
    AND     p_mmt.transaction_id = mmt.parent_transaction_id
    AND     (p_mmt.transaction_type_id = 33 -- sales order issue, internal drop
            OR p_mmt.transaction_type_id = 19) -- logical PO receipt, external drop
    AND     gtv.line_id = lines.line_id
    AND     gtv.organization_id = lines.ship_from_org_id
    AND     lines.order_source_id <> 27  -- retroactive billing
    AND     p_lines.line_id = nvl(lines.top_model_line_id, lines.line_id)
    AND     lines.header_id        = header.header_id
    AND     header.sold_to_org_id   = cust_acct.cust_account_id(+)
    AND     item.inventory_item_id = p_lines.inventory_item_id
    AND     item.organization_id   = p_lines.ship_from_org_id;


    COMMIT;

    bis_collection_utilities.put_line('Exit initial_opm_cogs() ' ||
                                       To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN
--{
    errbuf := Sqlerrm;
    retcode := 1;

    ROLLBACK;

    bis_collection_utilities.put_line('Error in initial_opm_cogs()' || errbuf);
--}
END initial_opm_cogs;


/*======================================================================
    This is the wrapper to extract COGS OPM data in initial load.
    It gets the process run bounds, R12 migration, and calls
    initial_opm_cogs and pre_r12_opm_cogs.

    Parameters:
    - errbuf: error buffer
    - retcode: return code
=======================================================================*/

PROCEDURE initial_load_opm_cogs(errbuf   IN OUT  NOCOPY  VARCHAR2,
                                retcode  IN OUT  NOCOPY  VARCHAR2) IS

    -- Declaration block

    l_r12_mgr_date      opi_dbi_conc_prog_run_log.last_run_date%type;
    l_from_bound_date   opi_dbi_conc_prog_run_log.from_bound_date%type;
    l_to_bound_date     opi_dbi_conc_prog_run_log.to_bound_date%type;

    no_bounds_found     exception;
BEGIN

    bis_collection_utilities.put_line('Enter initial_load_opm_cogs() ' ||
                                       To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    -- Initialization block
    retcode := 0;

    -- Get R12 migration date.  If GSD < R12 migration date,
    -- get OPM data from Pre R12 data model

    BEGIN
        SELECT  last_run_date
        INTO    l_r12_mgr_date
        FROM    opi_dbi_conc_prog_run_log
        WHERE   etl_type = 'R12_MIGRATION';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        --{
            l_r12_mgr_date := g_global_start_date;
        --}
    END;

    IF (g_global_start_date < l_r12_mgr_date) THEN
    --{
        opi_dbi_pre_r12_cogs_pkg.pre_r12_opm_cogs(p_global_start_date => g_global_start_date,
                                                  errbuf => errbuf,
                                                  retcode => retcode);
    --}
    END IF;

   -- Get process data from R12 converged data model

     BEGIN
        SELECT  from_bound_date, to_bound_date
        INTO    l_from_bound_date, l_to_bound_date
        FROM    opi_dbi_conc_prog_run_log
        WHERE   etl_type = 'COGS'
        AND     driving_table_code = 'GTV'
        AND     load_type = 'INIT';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        --{
            RAISE NO_BOUNDS_FOUND;
        --}
    END;

    -- Call API to load ledger data into Global temp table
    -- This temp table will be joined to extract process adjustments
    bis_collection_utilities.put_line ('Loading Ledger data into temp table');
    opi_dbi_bounds_pkg.load_opm_org_ledger_data;

    -- Committing the data. Since the temp table is made with On Commit preserve rows
    -- there will be no problem.
    commit;

    initial_opm_cogs(p_from_bound_date => l_from_bound_date,
                     p_to_bound_date => l_to_bound_date,
                     errbuf => errbuf,
                     retcode => retcode);

    COMMIT;

    bis_collection_utilities.put_line('Exit initial_load_opm_cogs() ' ||
                                       To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN
--{
    ROLLBACK;

    bis_collection_utilities.put_line('Error in initial_load_opm_cogs() ' || Sqlerrm );
    errbuf  := Sqlerrm;
    retcode := -1;
--}
END initial_load_opm_cogs;


/*=================================================================
    This procedure incrementally extracts process data into the
    staging table.

    Parameters:
    - p_from_bound_date: lower run bound
    - p_to_bound_date: upper run bound
    - errbuf: error buffer
    - retcode: return code
===================================================================*/

PROCEDURE incremental_opm_cogs( p_from_bound_date   IN DATE,
                                p_to_bound_date     IN DATE,
                                errbuf              IN OUT NOCOPY NUMBER,
                                retcode             IN OUT NOCOPY VARCHAR2 ) IS

BEGIN

    bis_collection_utilities.put_line('Enter incremental_opm_cogs() ' ||
                                       To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));
    retcode := 0;

    INSERT /*+ append */ INTO opi_dbi_cogs_fstg m (
            m.inventory_item_id,
            m.organization_id,
            m.order_line_id,
            m.top_model_line_id,
            m.top_model_item_id,
            m.top_model_item_uom,
            m.top_model_org_id,
            m.customer_id,
            m.cogs_val_b_draft,
            m.cogs_val_b,
            m.cogs_date,
            m.source,
            m.turns_cogs_flag,
            m.internal_flag )
     -- 33 Sales order issue; 34 Internal order issue; 62 Int Order Intr Ship
    SELECT  /*+ ordered use_nl(lines, p_lines, header, cust_acct, item) */
            gtv.inventory_item_id,
            gtv.organization_id,
            lines.line_id,
            p_lines.line_id             top_model_line_id,
            p_lines.inventory_item_id  top_model_item_id,
            item.primary_uom_code       top_model_item_uom,
            p_lines.ship_from_org_id    top_model_org_id,
            nvl(cust_acct.party_id, -1),
            gtv.draft_value,
            gtv.final_value,
            gtv.transaction_date,
            OPM_SOURCE,
            decode(p_lines.source_type_code, 'EXTERNAL', 2, 1 ),
            decode(p_lines.order_source_id,10,1,0)
     FROM   (
            SELECT  gtv.transaction_id,
                    gtv.inventory_item_id,
                    gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date,
                    sum(-gtv.txn_base_value) draft_value,
                    0 final_value
            FROM    gmf_transaction_valuation   gtv,
                    opi_dbi_org_le_temp         tmp
            WHERE   gtv.transaction_type_id in (33, 34, 62)
            AND     gtv.accounted_flag = 'D'
            AND     gtv.transaction_date >= g_global_start_date
            AND     gtv.journal_line_type = 'INV'
            AND     gtv.ledger_id = tmp.ledger_id
            AND     gtv.legal_entity_id = tmp.legal_entity_id
            AND     gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
            AND     gtv.organization_id = tmp.organization_id
            GROUP BY
                    gtv.transaction_id,
                    gtv.inventory_item_id,
                    gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date
            UNION ALL
            SELECT  gtv.transaction_id,
                    gtv.inventory_item_id,
                    gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date,
                    0 draft_value,
                    sum(-gtv.txn_base_value) final_value
            FROM    gmf_transaction_valuation   gtv,
                    opi_dbi_org_le_temp         tmp
            WHERE   gtv.transaction_type_id in (33, 34, 62)
            AND     gtv.accounted_flag is NULL
            AND     gtv.final_posting_date >= p_from_bound_date
            AND     gtv.final_posting_date < p_to_bound_date
            AND     gtv.transaction_date >= g_global_start_date
            AND     gtv.journal_line_type = 'INV'
            AND     gtv.ledger_id = tmp.ledger_id
            AND     gtv.legal_entity_id = tmp.legal_entity_id
            AND     gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
            AND     gtv.organization_id = tmp.organization_id
            GROUP BY
                    gtv.transaction_id,
                    gtv.inventory_item_id,
                    gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date) gtv,
            oe_order_lines_all              lines,  -- child line
            oe_order_lines_all              p_lines, -- parent line
            oe_order_headers_all            header,
            hz_cust_accounts                cust_acct,
            mtl_system_items_b              item
    WHERE   lines.line_id = gtv.line_id
    AND     lines.order_source_id <> 27  -- retroactive billing
    AND     p_lines.line_id = nvl(lines.top_model_line_id, lines.line_id)
    AND     lines.header_id        = header.header_id
    AND     header.sold_to_org_id   = cust_acct.cust_account_id(+)
    AND     item.inventory_item_id = p_lines.inventory_item_id
    AND     item.organization_id   = p_lines.ship_from_org_id
    UNION ALL
 -- 37  RMA Return; 16 Logical RMA Receipt; 15 RMA Receipt
    SELECT  /*+ ordered use_nl(lines, p_lines, l_lines,header, cust_acct, item) */
            gtv.inventory_item_id,
            gtv.organization_id,
            lines.line_id,
            p_lines.line_id             top_model_line_id,
            p_lines.inventory_item_id   top_model_item_id,
            item.primary_uom_code       top_model_item_uom,
            p_lines.ship_from_org_id    top_model_org_id,
            nvl(cust_acct.party_id, -1),
            gtv.draft_value,
            gtv.final_value,
            gtv.transaction_date,
             OPM_SOURCE,
            1,
            0
     FROM   (
            SELECT  gtv.transaction_id,
                    gtv.inventory_item_id,
                    gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date,
                    sum(-gtv.txn_base_value) draft_value,
                    0 final_value
            FROM    gmf_transaction_valuation   gtv,
                    opi_dbi_org_le_temp         tmp
            WHERE   gtv.transaction_type_id in (37, 16, 15)
            AND     gtv.accounted_flag = 'D'
            AND     gtv.transaction_date >= g_global_start_date
            AND     gtv.journal_line_type = 'INV'
            AND     gtv.ledger_id = tmp.ledger_id
            AND     gtv.legal_entity_id = tmp.legal_entity_id
            AND     gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
            AND     gtv.organization_id = tmp.organization_id
            GROUP BY
                    gtv.transaction_id,
                    gtv.inventory_item_id,
                    gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date
            UNION ALL
            SELECT  gtv.transaction_id,
                    gtv.inventory_item_id,
                    gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date,
                    0 draft_value,
                    sum(-gtv.txn_base_value) final_value
            FROM    gmf_transaction_valuation   gtv,
                    opi_dbi_org_le_temp         tmp
            WHERE   gtv.transaction_type_id in (37, 16, 15)
            AND     gtv.accounted_flag is NULL
            AND     gtv.final_posting_date >= p_from_bound_date
            AND     gtv.final_posting_date < p_to_bound_date
            AND     gtv.transaction_date >= g_global_start_date
            AND     gtv.journal_line_type = 'INV'
            AND     gtv.ledger_id = tmp.ledger_id
            AND     gtv.legal_entity_id = tmp.legal_entity_id
            AND     gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
            AND     gtv.organization_id = tmp.organization_id
            GROUP BY
                    gtv.transaction_id,
                    gtv.inventory_item_id,
                    gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date) gtv,
            oe_order_lines_all              lines,  -- child line
            oe_order_lines_all              l_lines, -- linking line
            oe_order_lines_all              p_lines, -- parent line
            oe_order_headers_all            header,
            hz_cust_accounts                cust_acct,
            mtl_system_items_b              item
    WHERE   lines.line_id = gtv.line_id
    AND     lines.line_category_code = 'RETURN'
    AND     lines.order_source_id <> 27  -- retroactive billing
    AND     l_lines.line_id = nvl(lines.link_to_line_id, lines.line_id)
      AND     p_lines.line_id = nvl(lines.top_model_line_id, lines.line_id)
    AND     lines.header_id        = header.header_id
    AND     header.sold_to_org_id   = cust_acct.cust_account_id(+)
    AND     item.inventory_item_id = p_lines.inventory_item_id
    AND     item.organization_id   = p_lines.ship_from_org_id
    UNION ALL
    -- Drop Ship
    SELECT /*+ ordered use_nl(mmt, p_mmt, lines, p_lines, header, cust_acct, item) index(mmt,mtl_material_transactions_u1)*/
            gtv.inventory_item_id,
            gtv.organization_id,
            lines.line_id,
            p_lines.line_id             top_model_line_id,
            p_lines.inventory_item_id   top_model_item_id,
            item.primary_uom_code       top_model_item_uom,
            p_lines.ship_from_org_id    top_model_org_id,
            nvl(cust_acct.party_id, -1),
            gtv.draft_value,
            gtv.final_value,
            gtv.transaction_date,
            OPM_SOURCE,
            1,
            0
     FROM   (
            SELECT  gtv.transaction_id,
                    gtv.inventory_item_id,
                    gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date,
                    sum(-gtv.txn_base_value) draft_value,
                    0 final_value
            FROM    gmf_transaction_valuation   gtv,
                    opi_dbi_org_le_temp         tmp
            WHERE   gtv.transaction_type_id in (11, 30) -- 11 Logical intercompany sales issue
                                                        -- 30 Logical sales order issue
            AND     gtv.accounted_flag = 'D'
            AND     gtv.transaction_date >= g_global_start_date
            AND     gtv.journal_line_type = 'INV'
            AND     gtv.ledger_id = tmp.ledger_id
            AND     gtv.legal_entity_id = tmp.legal_entity_id
            AND     gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
            AND     gtv.organization_id = tmp.organization_id
            GROUP BY
                    gtv.transaction_id,
                    gtv.inventory_item_id,
                    gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date
            UNION ALL
            SELECT  gtv.transaction_id,
                    gtv.inventory_item_id,
                    gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date,
                    0 draft_value,
                    sum(-gtv.txn_base_value) final_value
            FROM    gmf_transaction_valuation gtv,
                    opi_dbi_org_le_temp         tmp
            WHERE   gtv.transaction_type_id in (11, 30) -- 11 Logical intercompany sales issue
                                                        -- 30 Logical sales order issue
            AND     gtv.accounted_flag is NULL
            AND     gtv.final_posting_date >= p_from_bound_date
            AND     gtv.final_posting_date < p_to_bound_date
            AND     gtv.transaction_date >= g_global_start_date
            AND     gtv.journal_line_type = 'INV'
            AND     gtv.ledger_id = tmp.ledger_id
            AND     gtv.legal_entity_id = tmp.legal_entity_id
            AND     gtv.valuation_cost_type_id = tmp.valuation_cost_type_id
            AND     gtv.organization_id = tmp.organization_id
            GROUP BY
                    gtv.transaction_id,
                    gtv.inventory_item_id,
                    gtv.organization_id,
                    gtv.line_id,
                    gtv.transaction_date) gtv,
            mtl_material_transactions       mmt,
            mtl_material_transactions       p_mmt,
            oe_order_lines_all              lines,  -- child line
            oe_order_lines_all              p_lines, -- parent line
            oe_order_headers_all            header,
            hz_cust_accounts                cust_acct,
            mtl_system_items_b              item
    WHERE   gtv.transaction_id = mmt.transaction_id
    AND     p_mmt.transaction_id = mmt.parent_transaction_id
    AND     (p_mmt.transaction_type_id = 33 -- sales order issue, internal drop
            OR p_mmt.transaction_type_id = 19) -- logical PO receipt, external drop
    AND     gtv.line_id = lines.line_id
    AND     gtv.organization_id = lines.ship_from_org_id
    AND     lines.order_source_id <> 27  -- retroactive billing
    AND     p_lines.line_id = nvl(lines.top_model_line_id, lines.line_id)
    AND     lines.header_id        = header.header_id
    AND     header.sold_to_org_id   = cust_acct.cust_account_id(+)
    AND     item.inventory_item_id = p_lines.inventory_item_id
    AND     item.organization_id   = p_lines.ship_from_org_id;

    COMMIT;

    bis_collection_utilities.put_line('Exit incremental_opm_cogs() ' ||
                                       To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN
--{
    ROLLBACK;

    retcode := -1;
    bis_collection_utilities.put_line(' Error in incremental_opm_cogs()');
    bis_collection_utilities.put_line( Sqlerrm );
--}
END incremental_opm_cogs;


/*=======================================================================
    This is the wrapper for OPM COGS incremental load.
    It gets the process run bounds and calls incremental_opm_cogs.

    Parameters:
    - errbuf: error buffer
    - retcode: return code
========================================================================*/

PROCEDURE incremental_load_opm_cogs(errbuf   IN OUT  NOCOPY  VARCHAR2,
                                    retcode  IN OUT  NOCOPY  VARCHAR2) IS

    l_from_bound_date   opi_dbi_conc_prog_run_log.from_bound_date%type;
    l_to_bound_date     opi_dbi_conc_prog_run_log.to_bound_date%type;

    no_bounds_found     exception;

BEGIN

    bis_collection_utilities.put_line('Enter incremental_load_opm_cogs() ' ||
                                       To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    -- Initialization
    retcode := 0;

    -- Get process data from R12 converged data model

    BEGIN
        SELECT  from_bound_date, to_bound_date
        INTO    l_from_bound_date, l_to_bound_date
        FROM    opi_dbi_conc_prog_run_log
        WHERE   etl_type = 'COGS'
        AND     driving_table_code = 'GTV'
        AND     load_type = 'INCR';

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        --{
            RAISE NO_BOUNDS_FOUND;
        --}
    END;

     -- Call API to load ledger data into Global temp table
    -- This temp table will be joined to extract process adjustments
    bis_collection_utilities.put_line ('Loading Ledger data into temp table');
    opi_dbi_bounds_pkg.load_opm_org_ledger_data;

    -- Committing the data. Since the temp table is made with On Commit preserve rows
    -- there will be no problem.
    commit;

    incremental_opm_cogs(p_from_bound_date => l_from_bound_date,
                         p_to_bound_date => l_to_bound_date,
                         errbuf => errbuf,
                         retcode => retcode);

    COMMIT;

    bis_collection_utilities.put_line('Exit incremental_load_opm_cogs() ' ||
                                       To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));
EXCEPTION WHEN OTHERS THEN
--{
    ROLLBACK;

    bis_collection_utilities.put_line ('Error in incremental_load_opm_cogs() '|| Sqlerrm );
    errbuf  := Sqlerrm;
    retcode := -1;
--}
END incremental_load_opm_cogs;


/*===============================================================
    This procedure gets conversion rates for COGS in incremental
    load.

    Parameters:
    - errbuf: error buffer
    - retcode : return code
================================================================*/

PROCEDURE get_cogs_conversion_rate ( errbuf  IN OUT NOCOPY VARCHAR2,
                                     retcode IN OUT NOCOPY VARCHAR2) IS

    -- Cursor to see if any rates are missing. See below for details
    CURSOR invalid_rates_exist_csr IS
        SELECT 1
        FROM    opi_dbi_cogsf_conv_rates
        WHERE   (nvl (conversion_rate, -999) < 0 OR
                 nvl (sec_conversion_rate, 999) < 0)
        AND rownum < 2;

    invalid_rates_exist_rec invalid_rates_exist_csr%ROWTYPE;


    -- Set up a cursor to get all the invalid rates.
    -- By the logic of the fii_currency.get_global_rate_primary
    -- and fii_currency.get_global_rate_secondary APIs, the returned value
    -- is -ve if no rate exists:
    -- -1 for dates with no rate.
    -- -2 for unrecognized conversion rates.
    -- -3 for missing EUR to USD rates on 01-JAN-1999 when the
    --    transaction_date is prior to 01-JAN-1999 (when the EUR
    --    officially went into circulation).
    --
    -- However, with the secondary currency, the null rate means it
    -- has not been setup and should therefore not be reported as an
    -- error.
    --
    -- Also, cross check with the org-date pairs in the staging table,
    -- in case some orgs never had a functional currency code defined.
    CURSOR get_missing_rates_c (p_pri_sec_curr_same NUMBER) IS
        SELECT /*+ parallel (compare) */
        DISTINCT
            report_order,
            curr_code,
            rate_type,
            cogs_date,
            func_currency_code
          FROM (
           SELECT /*+ parallel (conv) parallel (mp) parallel (to_conv) */
           DISTINCT
                    g_global_currency_code curr_code,
                    g_global_rate_type rate_type,
                    1 report_order, -- ordering global currency first
                    mp.organization_code,
                    decode (conv.conversion_rate,
                            C_EURO_MISSING_AT_START, g_euro_start_date,
                            conv.transaction_date) cogs_date,
                    conv.f_currency_code func_currency_code
              FROM opi_dbi_cogsf_conv_rates conv,
                   mtl_parameters mp,
                  (SELECT /*+ parallel (opi_dbi_cogs_fstg) */
                    DISTINCT organization_id, trunc (cogs_date) cogs_date
                     FROM opi_dbi_cogs_fstg) to_conv
              WHERE nvl (conv.conversion_rate, -999) < 0 -- null is not fine
                AND mp.organization_id = to_conv.organization_id
                AND conv.transaction_date (+) = to_conv.cogs_date
                AND conv.organization_id (+) = to_conv.organization_id
            UNION ALL
            SELECT /*+ parallel (conv) parallel (mp) parallel (to_conv) */
            DISTINCT
                    g_secondary_currency_code curr_code,
                    g_secondary_rate_type rate_type,
                    decode (p_pri_sec_curr_same,
                            1, 1,
                            2) report_order, --ordering secondary currency next
                    mp.organization_code,
                    decode (conv.sec_conversion_rate,
                            C_EURO_MISSING_AT_START, g_euro_start_date,
                            conv.transaction_date) cogs_date,
                    conv.f_currency_code func_currency_code
              FROM opi_dbi_cogsf_conv_rates conv,
                   mtl_parameters mp,
                  (SELECT /*+ parallel (opi_dbi_cogs_fstg) */
                   DISTINCT organization_id, trunc (cogs_date) cogs_date
                     FROM opi_dbi_cogs_fstg) to_conv
              WHERE nvl (conv.sec_conversion_rate, 999) < 0 -- null is fine
                AND mp.organization_id = to_conv.organization_id
                AND conv.transaction_date (+) = to_conv.cogs_date
                AND conv.organization_id (+) = to_conv.organization_id)
          compare
          ORDER BY
                report_order ASC,
                cogs_date,
                func_currency_code;

    l_stmt_num NUMBER;
    no_currency_rate_flag NUMBER;

    -- Flag to check if the primary and secondary currencies are the same
    l_pri_sec_curr_same NUMBER;


BEGIN

    bis_collection_utilities.put_line('Enter get_cogs_conversion_rate() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    l_stmt_num := 0;
    -- initialization block
    retcode := g_ok;
    no_currency_rate_flag := 0;
    l_pri_sec_curr_same := 0;

    l_stmt_num := 10;
    -- check if the primary and secondary currencies and rate types are same

    IF (g_global_currency_code = nvl (g_secondary_currency_code, '---') AND
        g_global_rate_type = nvl (g_secondary_rate_type, '---') ) THEN
    --{
        l_pri_sec_curr_same := 1;
    --}
    END IF;


    l_stmt_num := 20;
    -- Use the fii_currency.get_global_rate_primary function to get the
    -- conversion rate given a currency code and a date.
    -- The function returns:
    -- 1 for currency code of 'USD' which is the global currency
    -- -1 for dates for which there is no currency conversion rate
    -- -2 for unrecognized currency conversion rates
    -- -3 for missing EUR to USD rates on 01-JAN-1999 when the
    --    transaction_date is prior to 01-JAN-1999 (when the EUR
    --    officially went into circulation).

    -- Use the fii_currency.get_global_rate_secondary to get the secondary
    -- global rate. If the secondary currency has not been set up,
    -- make the rate null. If the secondary currency/rate types are the
    -- same as the primary, don't call the API but rather use an update
    -- statement followed by the insert.

    -- By selecting distinct org and currency code from the gl_set_of_books
    -- and hr_organization_information, take care of duplicate codes.

    INSERT /*+ append parallel(rates) */
    INTO opi_dbi_cogsf_conv_rates rates (
        organization_id,
        f_currency_code,
        transaction_date,
        conversion_rate,
        sec_conversion_rate)
    SELECT /*+ parallel (to_conv) parallel (curr_codes) */
        to_conv.organization_id,
        curr_codes.currency_code,
        to_conv.cogs_date,
        decode (curr_codes.currency_code,
                g_global_currency_code, 1,
                fii_currency.get_global_rate_primary (
                                    curr_codes.currency_code,
                                    to_conv.cogs_date) ),
        decode (g_secondary_currency_code,
                NULL, NULL,
                curr_codes.currency_code, 1,
                decode (l_pri_sec_curr_same,
                        1, C_PRI_SEC_CURR_SAME_MARKER,
                        fii_currency.get_global_rate_secondary (
                            curr_codes.currency_code,
                            to_conv.cogs_date)))
      FROM
        (SELECT /*+ parallel (opi_dbi_cogs_fstg) */
         DISTINCT organization_id, trunc (cogs_date) cogs_date
           FROM opi_dbi_cogs_fstg) to_conv,
        (SELECT /*+ leading (hoi) full (hoi) use_hash (gsob)
                    parallel (hoi) parallel (gsob)*/
         DISTINCT hoi.organization_id, gsob.currency_code
           FROM hr_organization_information hoi,
                gl_sets_of_books gsob
           WHERE hoi.org_information_context  = 'Accounting Information'
             AND hoi.org_information1  = to_char(gsob.set_of_books_id))
        curr_codes
      WHERE curr_codes.organization_id  = to_conv.organization_id;


    --Introduced commit because of append parallel in the insert stmt above.
    commit;

    l_stmt_num := 40;
    -- if the primary and secondary currency codes are the same, then
    -- update the secondary with the primary
    IF (l_pri_sec_curr_same = 1) THEN
    --{
        UPDATE /*+ parallel (opi_dbi_cogsf_conv_rates) */
        opi_dbi_cogsf_conv_rates
        SET sec_conversion_rate = conversion_rate;

        -- safe to commit, as before
        commit;
    --}
    END IF;

     -- report missing rate
    l_stmt_num := 50;

    OPEN invalid_rates_exist_csr;
    FETCH invalid_rates_exist_csr INTO invalid_rates_exist_rec;
    IF (invalid_rates_exist_csr%FOUND) THEN
    --{
        bis_collection_utilities.put_line('missing conversion rates');

        -- there are missing rates - prepare to report them.
        no_currency_rate_flag := 1;
        bis_collection_utilities.writeMissingRateHeader;

        l_stmt_num := 60;
        FOR get_missing_rates_rec IN get_missing_rates_c (l_pri_sec_curr_same)
        LOOP

            bis_collection_utilities.writemissingrate (
                get_missing_rates_rec.rate_type,
                get_missing_rates_rec.func_currency_code,
                get_missing_rates_rec.curr_code,
                get_missing_rates_rec.cogs_date);

        END LOOP;
    --}
    END IF;
    CLOSE invalid_rates_exist_csr;


    l_stmt_num := 70; /* check no_currency_rate_flag  */
    IF (no_currency_rate_flag = 1) THEN /* missing rate found */
        bis_collection_utilities.put_line('ERROR: Please setup conversion rate for all missing rates reported');

        retcode := g_error;
    END IF;

    bis_collection_utilities.put_line('Exit get_cogs_conversion_rate() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION
    WHEN OTHERS THEN
    --{
        rollback;
        retcode := SQLCODE;
        errbuf  := 'REPORT_MISSING_RATE (' || to_char(l_stmt_num)
                    || '): '|| substr(SQLERRM, 1,200);

        bis_collection_utilities.put_line('Error at statement ('
                    || to_char(l_stmt_num)
                    || ')');

        bis_collection_utilities.put_line('Error Number: ' ||  retcode );
        bis_collection_utilities.put_line('Error Message: ' || errbuf  );
    --}
END get_cogs_conversion_rate;



/*===============================================================
    This procedure gets conversion rates for COGS in incremental
    load.

    Parameters:
    - errbuf: error buffer
    - retcode : return code
================================================================*/

PROCEDURE get_cogs_conversion_rate_incr ( errbuf  IN OUT NOCOPY VARCHAR2,
                                          retcode IN OUT NOCOPY VARCHAR2)
IS

    -- Cursor to see if any rates are missing. See below for details
    CURSOR invalid_rates_exist_csr IS
        SELECT 1
          FROM opi_dbi_cogsf_conv_rates
          WHERE (   nvl (conversion_rate, -999) < 0
                 OR nvl (sec_conversion_rate, 999) < 0)
            AND rownum < 2;

    invalid_rates_exist_rec invalid_rates_exist_csr%ROWTYPE;


    -- Set up a cursor to get all the invalid rates.
    -- By the logic of the fii_currency.get_global_rate_primary
    -- and fii_currency.get_global_rate_secondary APIs, the returned value
    -- is -ve if no rate exists:
    -- -1 for dates with no rate.
    -- -2 for unrecognized conversion rates.
    -- -3 for missing EUR to USD rates on 01-JAN-1999 when the
    --    transaction_date is prior to 01-JAN-1999 (when the EUR
    --    officially went into circulation).
    --
    -- However, with the secondary currency, the null rate means it
    -- has not been setup and should therefore not be reported as an
    -- error.
    --
    -- Also, cross check with the org-date pairs in the staging table,
    -- in case some orgs never had a functional currency code defined.
    CURSOR get_missing_rates_c (p_pri_sec_curr_same NUMBER) IS
        SELECT DISTINCT
            report_order,
            curr_code,
            rate_type,
            cogs_date,
            func_currency_code
          FROM (
           SELECT DISTINCT
                    g_global_currency_code curr_code,
                    g_global_rate_type rate_type,
                    1 report_order, -- ordering global currency first
                    mp.organization_code,
                    decode (conv.conversion_rate,
                            C_EURO_MISSING_AT_START, g_euro_start_date,
                            conv.transaction_date) cogs_date,
                    conv.f_currency_code func_currency_code
              FROM opi_dbi_cogsf_conv_rates conv,
                   mtl_parameters mp,
                  (SELECT /*+ parallel (opi_dbi_cogs_fstg) */
                   DISTINCT organization_id, trunc (cogs_date) cogs_date
                     FROM opi_dbi_cogs_fstg) to_conv
              WHERE nvl (conv.conversion_rate, -999) < 0 -- null is not fine
                AND mp.organization_id = to_conv.organization_id
                AND conv.transaction_date (+) = to_conv.cogs_date
                AND conv.organization_id (+) = to_conv.organization_id
            UNION ALL
            SELECT DISTINCT
                    g_secondary_currency_code curr_code,
                    g_secondary_rate_type rate_type,
                    decode (p_pri_sec_curr_same,
                            1, 1,
                            2) report_order, --ordering secondary currency next
                    mp.organization_code,
                    decode (conv.sec_conversion_rate,
                            C_EURO_MISSING_AT_START, g_euro_start_date,
                            conv.transaction_date) cogs_date,
                    conv.f_currency_code func_currency_code
              FROM opi_dbi_cogsf_conv_rates conv,
                   mtl_parameters mp,
                  (SELECT /*+ parallel (opi_dbi_cogs_fstg) */
                   DISTINCT organization_id, trunc (cogs_date) cogs_date
                     FROM opi_dbi_cogs_fstg) to_conv
              WHERE nvl (conv.sec_conversion_rate, 999) < 0 -- null is fine
                AND mp.organization_id = to_conv.organization_id
                AND conv.transaction_date (+) = to_conv.cogs_date
                AND conv.organization_id (+) = to_conv.organization_id)
          ORDER BY
                report_order ASC,
                cogs_date,
                func_currency_code;

    l_stmt_num NUMBER;
    no_currency_rate_flag NUMBER := 0;

    -- Flag to check if the primary and secondary currencies are the
    -- same
    l_pri_sec_curr_same NUMBER;


BEGIN

    bis_collection_utilities.put_line('Enter get_cogs_conversion_rate_incr() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    -- Initialization block
    l_stmt_num := 0;
    retcode := g_ok;
    no_currency_rate_flag := 0;
    l_pri_sec_curr_same := 0;

    l_stmt_num := 10;
    -- check if the primary and secondary currencies and rate types are same

    IF (g_global_currency_code = nvl (g_secondary_currency_code, '---') AND
        g_global_rate_type = nvl (g_secondary_rate_type, '---') ) THEN
    --{
        l_pri_sec_curr_same := 1;
    --}
    END IF;


    l_stmt_num := 20;
    -- Use the fii_currency.get_global_rate_primary function to get the
    -- conversion rate given a currency code and a date.
    -- The function returns:
    -- 1 for currency code of 'USD' which is the global currency
    -- -1 for dates for which there is no currency conversion rate
    -- -2 for unrecognized currency conversion rates
    -- -3 for missing EUR to USD rates on 01-JAN-1999 when the
    --    transaction_date is prior to 01-JAN-1999 (when the EUR
    --    officially went into circulation).

    -- Use the fii_currency.get_global_rate_secondary to get the secondary
    -- global rate. If the secondary currency has not been set up,
    -- make the rate null. If the secondary currency/rate types are the
    -- same as the primary, don't call the API but rather use an update
    -- statement followed by the insert.

    -- By selecting distinct org and currency code from the gl_set_of_books
    -- and hr_organization_information, take care of duplicate codes.

    INSERT /*+ append */
    INTO opi_dbi_cogsf_conv_rates rates (
        organization_id,
        f_currency_code,
        transaction_date,
        conversion_rate,
        sec_conversion_rate)
    SELECT
        to_conv.organization_id,
        curr_codes.currency_code,
        to_conv.cogs_date,
         decode (curr_codes.currency_code,
                g_global_currency_code, 1,
                fii_currency.get_global_rate_primary (
                                    curr_codes.currency_code,
                                    to_conv.cogs_date) ),
        decode (g_secondary_currency_code,
                NULL, NULL,
                curr_codes.currency_code, 1,
                decode (l_pri_sec_curr_same,
                        1, C_PRI_SEC_CURR_SAME_MARKER,
                        fii_currency.get_global_rate_secondary (
                            curr_codes.currency_code,
                            to_conv.cogs_date)))
      FROM
        (SELECT
         DISTINCT organization_id, trunc (cogs_date) cogs_date
           FROM opi_dbi_cogs_fstg) to_conv,
        (SELECT
         DISTINCT hoi.organization_id, gsob.currency_code
           FROM hr_organization_information hoi,
                gl_sets_of_books gsob
           WHERE hoi.org_information_context  = 'Accounting Information'
             AND hoi.org_information1  = to_char(gsob.set_of_books_id))
        curr_codes
      WHERE curr_codes.organization_id  = to_conv.organization_id;


    --Introduced commit because of append parallel in the insert stmt above.
    commit;

    l_stmt_num := 40;
    -- if the primary and secondary currency codes are the same, then
    -- update the secondary with the primary
    IF (l_pri_sec_curr_same = 1) THEN
    --{
        UPDATE /*+ parallel (opi_dbi_cogsf_conv_rates) */
        opi_dbi_cogsf_conv_rates
        SET sec_conversion_rate = conversion_rate;

        -- safe to commit, as before
        commit;
    --}
    END IF;


    -- report missing rate
    l_stmt_num := 50;

    OPEN invalid_rates_exist_csr;
    FETCH invalid_rates_exist_csr INTO invalid_rates_exist_rec;
    IF (invalid_rates_exist_csr%FOUND) THEN
    --{
         -- there are missing rates - prepare to report them.
        no_currency_rate_flag := 1;
        bis_collection_utilities.writeMissingRateHeader;

        l_stmt_num := 60;
        FOR get_missing_rates_rec IN get_missing_rates_c (l_pri_sec_curr_same)
        LOOP

            bis_collection_utilities.writemissingrate (
                get_missing_rates_rec.rate_type,
                get_missing_rates_rec.func_currency_code,
                get_missing_rates_rec.curr_code,
                get_missing_rates_rec.cogs_date);

        END LOOP;
    --}
    END IF;
    CLOSE invalid_rates_exist_csr;


    l_stmt_num := 70; /* check no_currency_rate_flag  */
    IF (no_currency_rate_flag = 1) THEN /* missing rate found */
    --{
        bis_collection_utilities.put_line('ERROR: Please setup conversion rate for all missing rates reported');

        retcode := g_error;
    --}
    END IF;

    bis_collection_utilities.put_line('Exit get_cogs_conversion_rate_incr() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION
    WHEN OTHERS THEN
    --{
        rollback;
        retcode := SQLCODE;
        errbuf  := 'REPORT_MISSING_RATE (' || to_char(l_stmt_num)
                    || '): '|| substr(SQLERRM, 1,200);

        bis_collection_utilities.put_line('Error at statement ('
                    || to_char(l_stmt_num)
                    || ')');

        bis_collection_utilities.put_line('Error Number: ' ||  retcode );
        bis_collection_utilities.put_line('Error Message: ' || errbuf  );
    --}
END get_cogs_conversion_rate_incr;

/*======================================================================
    This is the wrapper procedure for COGS initial load which extracts
    data for discrete and process organizations.

    Parameters:
    - errbuf: error buffer
    - retcode: return code
=======================================================================*/

PROCEDURE initial_load_cogs ( errbuf    IN OUT  NOCOPY  VARCHAR2,
                              retcode   IN OUT  NOCOPY  VARCHAR2 ) IS

    -- Declaration

    l_stmt_num  NUMBER;
    l_row_count NUMBER;
    l_error_flag  BOOLEAN;
    l_bounds_warning BOOLEAN;

    l_opi_schema      VARCHAR2(30);
    l_status          VARCHAR2(30);
    l_industry        VARCHAR2(30);

    schema_info_not_found   exception;
BEGIN

    bis_collection_utilities.put_line('Enter initial_load_cogs() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));
    -- Initialization
    l_error_flag := FALSE;
    retcode := 0;

    bis_collection_utilities.put_line ('Initial Load COGS  starts at '
                            || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    IF bis_collection_utilities.setup('OPI_DBI_COGS_F' ) = false THEN
    --{
        RAISE_APPLICATION_ERROR(-20000, errbuf);
    --}
    END IF;

    -- Performance tuning change
    execute immediate 'alter session set hash_area_size=100000000';
    execute immediate 'alter session set sort_area_size=100000000';

    -- Setup globals
    l_stmt_num := 10;

    check_setup_globals(errbuf => errbuf, retcode => retcode);

    IF retcode <> 0 THEN
    --{
        RETURN ;
     --}
    END IF;


    -- Common Clean up
    l_stmt_num := 20;

    IF fnd_installation.get_app_info( 'OPI', l_status, l_industry, l_opi_schema) THEN
    --{
        execute immediate 'truncate table ' || l_opi_schema
        || '.opi_dbi_cogsf_conv_rates ';

        execute immediate 'truncate table ' || l_opi_schema
        || '.opi_dbi_cogs_run_log ';

        execute immediate 'truncate table ' || l_opi_schema
        || '.opi_dbi_cogs_fstg ';

        -- bug 3863905- mv log is now dropped before initial load
        -- we shouldnt be truncating mv log anymore

        --  execute immediate 'truncate table ' || l_opi_schema
        --|| '.mlog$_opi_dbi_cogs_f';

        execute immediate 'truncate table ' || l_opi_schema
        || '.opi_dbi_cogs_f PURGE MATERIALIZED VIEW LOG';
    --}
    ELSE
    --{
        RAISE schema_info_not_found;
    --}
    END IF;


    -- Get start/end bounds for Discrete and Process
    l_stmt_num := 30;

    opi_dbi_bounds_pkg.maintain_opi_dbi_logs(p_etl_type => 'COGS', p_load_type => 'INIT');

    IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;


    -- check if some bounds are uncosted before calling any other
    -- procedure that can wipe out the stop reason code
    l_stmt_num:= 40;
    l_bounds_warning := opi_dbi_bounds_pkg.bounds_uncosted(p_etl_type => 'COGS',
                                                                                                                  p_load_type => 'INIT');

    -- Print the discrete org collection bounds
    l_stmt_num := 50;
    opi_dbi_bounds_pkg.print_opi_org_bounds(p_etl_type => 'COGS', p_load_type => 'INIT');


    -- Load discrete cogs into staging table
    l_stmt_num := 60;

    bis_collection_utilities.put_line('Load OPI cogs into stg '
            || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    init_opi_cogs( errbuf => errbuf, retcode => retcode);

    IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;



    -- Load process cogs into staging table
    l_stmt_num :=70;

    bis_collection_utilities.put_line('Load OPM cogs into stg '
            || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    initial_load_opm_cogs(errbuf => errbuf, retcode => retcode);

    IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;



    -- Get conversion rates
    -- For improve perf, need to commit in stg/conversion rate tables
    -- and gather statistics

    l_stmt_num := 80;


    gather_stats(p_table_name => 'OPI_DBI_COGS_FSTG');

    get_cogs_conversion_rate( errbuf => errbuf, retcode => retcode );
     commit;

    gather_stats(p_table_name => 'OPI_DBI_COGSF_CONV_RATES');


    IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;


    IF l_error_flag <> TRUE THEN
    --{
        -- Load from staging table into fact table
        l_stmt_num := 90;

        INSERT /*+ append parallel(m) */ INTO opi_dbi_cogs_f m (
                m.inventory_item_id,
                m.organization_id,
                m.order_line_id,
                m.top_model_line_id,
                m.top_model_item_id,
                m.top_model_item_uom,
                m.top_model_org_id,
                m.customer_id,
                m.cogs_val_b_draft,
                m.cogs_val_b,
                m.cogs_val_g,
                m.cogs_val_sg,
                m.cogs_date,
                m.source,
                m.turns_cogs_flag,
                m.internal_flag,
                m.creation_date,
                m.last_update_date,
                m.created_by,
                m.last_updated_by,
                m.last_updated_login,
                m.program_id,
                m.program_login_id,
                m.program_application_id,
                m.request_id)
        SELECT  /*+ parallel(stg) parallel(rate) */
                stg.inventory_item_id,
                stg.organization_id,
                stg.order_line_id,
                stg.top_model_line_id,
                stg.top_model_item_id,
                stg.top_model_item_uom,
                stg.top_model_org_id,
                stg.customer_id,
                 sum(stg.cogs_val_b_draft),
                sum(stg.cogs_val_b_draft + stg.cogs_val_b),
                sum((stg.cogs_val_b_draft + stg.cogs_val_b) * rate.conversion_rate),
                sum((stg.cogs_val_b_draft + stg.cogs_val_b) * rate.sec_conversion_rate),
                trunc (stg.cogs_date),
                stg.source,
                stg.turns_cogs_flag,
                stg.internal_flag,
                sysdate,
                sysdate,
                g_user_id,
                g_user_id,
                g_login_id,
                g_program_id,
                g_program_login_id,
                g_program_application_id,
                g_request_id
        FROM    opi_dbi_cogs_fstg stg,
                opi_dbi_cogsf_conv_rates rate
        WHERE   stg.organization_id   = rate.organization_id
        AND     trunc (stg.cogs_date) = rate.transaction_date
        GROUP BY
                stg.inventory_item_id,
                stg.organization_id,
                stg.order_line_id,
                stg.top_model_line_id,
                stg.top_model_item_id,
                stg.top_model_item_uom,
                stg.top_model_org_id,
                stg.customer_id,
                stg.cogs_date,
                stg.source,
                stg.turns_cogs_flag,
                stg.internal_flag;
        l_row_count := sql%rowcount;

        bis_collection_utilities.put_line('Loaded ' || l_row_count || ' rows into opi_dbi_cogs_f.');

        -- Report etl success
        l_stmt_num := 100;

        opi_dbi_bounds_pkg.set_load_successful(p_etl_type => 'COGS', p_load_type => 'INIT');

        COMMIT;

         -- if uncosted transactions were found, return a warning.
        l_stmt_num :=110;
        IF (l_bounds_warning) THEN
        --{
            bis_collection_utilities.put_line('COGS Initial Load found uncosted transactions.');
            retcode := g_WARNING;
            errbuf := 'COGS Initial Load Found Uncosted Transactions. ';
        --}
        END IF;


        -- Common clean up
        l_stmt_num := 120;

        execute immediate 'truncate table ' || l_opi_schema
            || '.opi_dbi_cogsf_conv_rates ';

        execute immediate 'truncate table ' || l_opi_schema
            || '.opi_dbi_cogs_fstg ';

        bis_collection_utilities.wrapup(p_status => TRUE,
                                        p_count => l_row_count,
                                        p_message => 'successful in initial_load_cogs.');
    --}
    ELSE
    --{
        rollback;
        retcode := g_error ;
        errbuf  := 'Please check log file for details.';
        bis_collection_utilities.wrapup(p_status => FALSE,
                                        p_count => 0,
                                        p_message => 'failed in initial_load_cogs.');
    --}
    END IF;

    bis_collection_utilities.put_line('Exit initial_load_cogs() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN

    errbuf:= Sqlerrm;
    retcode:= SQLCODE;

    ROLLBACK;
    bis_collection_utilities.put_line('Error in initial_load_cogs() at ' || l_stmt_num);
    bis_collection_utilities.wrapup(p_status => FALSE,
                                    p_count => 0,
                                    p_message => 'failed in initial_load_cogs.');

   RAISE_APPLICATION_ERROR(-20000,errbuf);

END initial_load_cogs;



/*======================================================================
    This is the wrapper procedure for COGS incremental load which extracts
    data for discrete and process organizations.

    Parameters:
    - errbuf: error buffer
    - retcode: return code
=======================================================================*/

PROCEDURE incremental_load_cogs ( errbuf      IN OUT NOCOPY  VARCHAR2,
                                  retcode     IN OUT NOCOPY  VARCHAR2 ) IS

    -- Declaration
    l_stmt_num          NUMBER;
    l_row_count         NUMBER;
    l_error_flag        BOOLEAN;
    l_bounds_warning    BOOLEAN;

    l_opi_schema        VARCHAR2(30);
    l_status            VARCHAR2(30);
    l_industry          VARCHAR2(30);

    schema_info_not_found   EXCEPTION;
BEGIN

    bis_collection_utilities.put_line('Enter incremental_load_cogs() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    -- Initialization
    l_error_flag := false;
    retcode :=0;

    bis_collection_utilities.put_line('Incrmental Load COGS  starts at '
                                || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    IF bis_collection_utilities.setup( 'OPI_DBI_COGS_F' ) = false THEN
    --{
        RAISE_APPLICATION_ERROR(-20000, errbuf);
    --}
    END IF;

    -- Performance tuning change
    execute immediate 'alter session set hash_area_size=100000000 ';
    execute immediate 'alter session set sort_area_size=100000000 ';

    -- Setup globals
    l_stmt_num := 10;

    check_setup_globals(errbuf => errbuf, retcode => retcode);

    IF retcode <> 0 THEN
    --{
        RETURN ;
     --}
    END IF;

    -- Common clean up
    l_stmt_num := 20;
    IF fnd_installation.get_app_info( 'OPI', l_status, l_industry, l_opi_schema) THEN
    --{
        execute immediate 'truncate table ' || l_opi_schema
        || '.opi_dbi_cogsf_conv_rates ';

        execute immediate 'truncate table ' || l_opi_schema
        || '.opi_dbi_cogs_fstg ';
    --}
    ELSE
    --{
        RAISE schema_info_not_found;
    --}
    END IF;


    -- Get start/end bounds for discrete and process
    l_stmt_num := 30;

    opi_dbi_bounds_pkg.maintain_opi_dbi_logs(p_etl_type => 'COGS', p_load_type => 'INCR');

    IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;



    -- check if some bounds are uncosted before calling any other
    -- procedure that can wipe out the stop reason code
    l_stmt_num:= 40;
    l_bounds_warning := opi_dbi_bounds_pkg.bounds_uncosted(p_etl_type => 'COGS',
                                                           p_load_type => 'INCR');

    -- Print the discrete org collection bounds
    l_stmt_num := 50;
    opi_dbi_bounds_pkg.print_opi_org_bounds(p_etl_type => 'COGS', p_load_type => 'INCR');


    -- Load discrete cogs into staging table
    l_stmt_num :=60;

    bis_collection_utilities.put_line('Load discrete cogs into stg '
                || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    incremental_opi_cogs( errbuf => errbuf, retcode => retcode);

    IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;


    -- Load process cogs into staging table
    l_stmt_num := 70;

    bis_collection_utilities.put_line('Load process cogs into stg '
                || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    incremental_load_opm_cogs( errbuf => errbuf, retcode => retcode);

    IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;


    -- Get conversion rates
    -- For improve perf, need to commit in stg/conversion rate tables
    -- and gather statistics

    l_stmt_num := 80;
    gather_stats(p_table_name => 'OPI_DBI_COGS_FSTG');

    get_cogs_conversion_rate_incr( errbuf => errbuf, retcode => retcode );

    commit;

    gather_stats(p_table_name => 'OPI_DBI_COGSF_CONV_RATES');

    IF retcode <> 0 THEN
    --{
        l_error_flag := TRUE;
    --}
    END IF;


    IF l_error_flag <> TRUE THEN
    --{
        l_stmt_num := 90;

        -- Load data from staging table into fact table

        MERGE /*+ index(m, OPI_DBI_COGS_F_N2) */ INTO opi_dbi_cogs_f m
        USING (
        SELECT
                stg.inventory_item_id,
                stg.organization_id,
                stg.order_line_id,
                stg.top_model_line_id,
                stg.top_model_item_id,
                stg.top_model_item_uom,
                stg.top_model_org_id,
                stg.customer_id,
                sum(stg.cogs_val_b_draft) cogs_val_b_draft,
                sum(stg.cogs_val_b) cogs_val_b,
                trunc (stg.cogs_date) cogs_date,
                stg.source,
                stg.turns_cogs_flag,
                stg.internal_flag,
                min(rate.conversion_rate)       conversion_rate,
                min(rate.sec_conversion_rate)   sec_conversion_rate
        FROM    opi_dbi_cogs_fstg stg,
                opi_dbi_cogsf_conv_rates rate
        WHERE   stg.organization_id = rate.organization_id
        AND     trunc (stg.cogs_date) = rate.transaction_date
        GROUP BY
                stg.inventory_item_id,
                stg.organization_id,
                stg.order_line_id,
                stg.top_model_line_id,
                stg.top_model_item_id,
                stg.top_model_item_uom,
                stg.top_model_org_id,
                stg.customer_id,
                trunc (stg.cogs_date),
                stg.source,
                stg.turns_cogs_flag,
                stg.internal_flag
        ) rstg
        ON  (m.order_line_id = rstg.order_line_id )
        WHEN matched THEN UPDATE SET
                m.cogs_val_b_draft = rstg.cogs_val_b_draft,
                m.cogs_val_b = m.cogs_val_b - m.cogs_val_b_draft + rstg.cogs_val_b_draft + rstg.cogs_val_b,
                m.cogs_val_g = (m.cogs_val_b - m.cogs_val_b_draft + rstg.cogs_val_b_draft + rstg.cogs_val_b)
                               * rstg.conversion_rate,
                m.cogs_val_sg = (m.cogs_val_b - m.cogs_val_b_draft + rstg.cogs_val_b_draft + rstg.cogs_val_b)
                               * rstg.sec_conversion_rate,
                m.cogs_date  = rstg.cogs_date,
                m.last_update_date = sysdate,
                m.last_updated_by  = g_user_id,
                m.last_updated_login = g_login_id
        WHEN NOT matched THEN
        INSERT (m.inventory_item_id,
                m.organization_id,
                m.order_line_id,
                m.top_model_line_id,
                m.top_model_item_id,
                m.top_model_item_uom,
                m.top_model_org_id,
                m.customer_id,
                m.cogs_val_b_draft,
                m.cogs_val_b,
                m.cogs_val_g,
                m.cogs_val_sg,
                m.cogs_date,
                m.source,
                m.turns_cogs_flag,
                m.internal_flag,
                m.creation_date,
                m.last_update_date,
                m.created_by,
                m.last_updated_by,
                m.last_updated_login,
                m.program_id,
                m.program_login_id,
                program_application_id,
                request_id )
        VALUES (rstg.inventory_item_id,
                rstg.organization_id,
                rstg.order_line_id,
                rstg.top_model_line_id,
                rstg.top_model_item_id,
                rstg.top_model_item_uom,
                rstg.top_model_org_id,
                rstg.customer_id,
                rstg.cogs_val_b_draft,
                rstg.cogs_val_b_draft + rstg.cogs_val_b,
                (rstg.cogs_val_b_draft + rstg.cogs_val_b) * rstg.conversion_rate,
                (rstg.cogs_val_b_draft + rstg.cogs_val_b) * rstg.sec_conversion_rate,
                rstg.cogs_date,
                rstg.source,
                rstg.turns_cogs_flag,
                rstg.internal_flag,
                sysdate,
                sysdate,
                g_user_id,
                g_user_id,
                g_login_id,
                g_program_id,
                g_program_login_id,
                g_program_application_id,
                g_request_id );


        l_row_count := sql%rowcount;

         bis_collection_utilities.put_line('Loaded ' || l_row_count || ' rows into opi_dbi_cogs_f.');
        -- Report etl success
        l_stmt_num := 100;

        opi_dbi_bounds_pkg.set_load_successful(p_etl_type => 'COGS', p_load_type => 'INCR');

        COMMIT;

        -- if uncosted transactions were found, return a warning.
        l_stmt_num := 110;
        IF (l_bounds_warning) THEN
        --{
            bis_collection_utilities.put_line('COGS Incremental Load found uncosted transactions.');
            retcode := g_WARNING;
            errbuf := ' COGS Incremental Load Found Uncosted Transactions. ';
        --}
        END IF;

        -- common clean up
        l_stmt_num := 110;

        execute immediate 'truncate table ' || l_opi_schema
            || '.opi_dbi_cogsf_conv_rates ';

        execute immediate 'truncate table ' || l_opi_schema
            || '.opi_dbi_cogs_fstg ';

        bis_collection_utilities.wrapup( p_status => TRUE,
                                         p_count => l_row_count,
                                         p_message => 'successful in incremental_load_cogs.');
    --}
    ELSE
    --{
        rollback;
        retcode := g_error ;
        errbuf  := 'Please check log file for details.';
        bis_collection_utilities.wrapup(p_status => FALSE,
                   p_count => 0,
                   p_message => 'failed in incremental_load_cogs.'
                   );
    --}
   END IF;

    bis_collection_utilities.put_line('Exit incremental_load_cogs() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN
--{
    errbuf:= Sqlerrm;
    retcode:= SQLCODE;

    ROLLBACK;
    bis_collection_utilities.put_line('Error in incremental_load_cogs() at ' || l_stmt_num);
    bis_collection_utilities.wrapup(p_status => FALSE,
                   p_count => 0,
                   p_message => 'failed in incremental_load_cogs.'
                   );

   RAISE_APPLICATION_ERROR(-20000,errbuf);
--}

END incremental_load_cogs;

END opi_dbi_cogs_pkg;

/
