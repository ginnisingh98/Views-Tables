--------------------------------------------------------
--  DDL for Package Body OPI_DBI_CURR_INV_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_CURR_INV_EXP_PKG" AS
/*$Header: OPIDECIEXPB.pls 120.3 2005/11/30 01:36:22 srayadur noship $ */


/**************************************************
* File scope variables
**************************************************/

-- Package level variables for session info-
-- including schema name for truncating and
-- collecting stats. Initialized in global_setup.
s_opi_schema      VARCHAR2(30);
s_status          VARCHAR2(30);
s_industry        VARCHAR2(30);

-- Package level variables for the standard who columns
s_user_id                   NUMBER;
s_login_id                  NUMBER;
s_program_id                NUMBER;
s_program_login_id          NUMBER;
s_program_application_id    NUMBER;
s_request_id                NUMBER;

-- Conversion rate related variables: global currency code and rate type
s_global_curr_code  VARCHAR2(10);
s_global_rate_type  VARCHAR2(15);
-- secondary global currency
s_secondary_curr_code  VARCHAR2(10);
s_secondary_rate_type  VARCHAR2(15);


/**************************************************
* Common Procedures
*
* File scope functions (not in spec)
**************************************************/

-- Global variable setup and verification
PROCEDURE global_setup;

-- Global wrapup procedure
PROCEDURE global_wrapup (p_retcode IN NUMBER,
                         p_exp_rows_collected IN NUMBER);

-- Print out error message in a consistent manner
FUNCTION err_mesg (p_mesg IN VARCHAR2,
                   p_proc_name IN VARCHAR2,
                   p_stmt_id IN NUMBER)
    RETURN VARCHAR2;

-- Print stage done message
PROCEDURE print_stage_done_mesg (p_proc_name IN VARCHAR2,
                                 p_stmt_id IN NUMBER);

-- Clean up the inventory expiration status related tables
PROCEDURE clear_inv_exp_tables;

-- Extract the expired inventory value from OLTP and insert into fact.
PROCEDURE extract_expired_inventory (p_run_date IN DATE,
                                     p_rows_collected OUT NOCOPY NUMBER);

-- Check for missing currency conversion rates
PROCEDURE check_missing_rates (p_run_date IN DATE);

/**************************************************
 * Common Procedures Definitions
 **************************************************/

/*  global_setup

    Performs global setup of file scope variables and does any checking
    needed for global DBI setups.

    Clean up tables if needed.

    Parameters: None

    History:
    Date        Author              Action
    07/07/05    Dinkar Gupta        Defined function.

*/
PROCEDURE global_setup
IS
-- {
    l_proc_name CONSTANT VARCHAR2 (40) := 'global_setup';
    l_stmt_id NUMBER;

    l_list DBMS_SQL.VARCHAR2_TABLE;

    l_setup_good BOOLEAN;

-- }
BEGIN
-- {
    -- Initialization block
    l_stmt_id := 0;
    s_opi_schema := NULL;
    s_status := NULL;
    s_industry := NULL;
    s_user_id := NULL;
    s_login_id := NULL;
    s_program_id := NULL;
    s_program_login_id := NULL;
    s_program_application_id := NULL;
    s_request_id := NULL;
    s_global_curr_code := NULL;
    s_global_rate_type := NULL;
    s_secondary_curr_code := NULL;
    s_secondary_rate_type := NULL;

    -- Common setup API
    l_stmt_id := 10;
    IF BIS_COLLECTION_UTILITIES.setup (p_object_name => C_PKG_NAME) = FALSE
    THEN
    -- {
        RAISE BIS_COMMON_API_FAILED;
    -- }
    END IF;

    l_stmt_id := 20;
    -- Obtain the OPI schema name to allow truncation of various tables
    -- get session parameters
    IF (NOT (fnd_installation.get_app_info(
                application_short_name => 'OPI',
                status => s_status,
                industry => s_industry,
                oracle_schema => s_opi_schema))) THEN
    -- {
        RAISE SCHEMA_INFO_NOT_FOUND;
    -- }
    END IF;

    l_stmt_id := 30;
    -- Package level variables for the user logged in
    s_user_id := nvl(fnd_global.user_id, -1);
    s_login_id := nvl(fnd_global.login_id, -1);
    s_program_id := nvl (fnd_global.conc_program_id, -1);
    s_program_login_id := nvl (fnd_global.conc_login_id, -1);
    s_program_application_id := nvl (fnd_global.prog_appl_id,  -1);
    s_request_id := nvl (fnd_global.conc_request_id, -1);

    l_stmt_id := 40;
    -- check for the DBI global currency setup
    l_list(1) := 'BIS_PRIMARY_CURRENCY_CODE';
    l_list(2) := 'BIS_GLOBAL_START_DATE';
    l_setup_good := BIS_COMMON_PARAMETERS.check_global_parameters (
                        p_parameter_list => l_list);

    l_stmt_id := 50;
    -- Ensure that the global currency code has been correctly set up
    IF (NOT (l_setup_good)) THEN
    -- {
        RAISE PRIMARY_CURR_SETUP_BAD;
    -- }
    END IF;

    l_stmt_id := 60;
    -- Get the DBI global currency code
    s_global_curr_code := BIS_COMMON_PARAMETERS.get_currency_code;

    l_stmt_id := 70;
    IF (s_global_curr_code IS NULL) THEN
    -- {
        RAISE NO_GLOBAL_CURR_CODE;
    -- }
    END IF;

    l_stmt_id := 80;
    -- Get the DBI Global rate type
    s_global_rate_type := BIS_COMMON_PARAMETERS.get_rate_type;

    l_stmt_id := 90;
    IF (s_global_rate_type IS NULL) THEN
    -- {
        RAISE NO_GLOBAL_RATE_TYPE;
    -- }
    END IF;

    l_stmt_id := 100;
    -- Get the DBI secondary currency code
    s_secondary_curr_code := BIS_COMMON_PARAMETERS.get_secondary_currency_code;

    l_stmt_id := 110;
    -- Get the DBI Global rate type
    s_secondary_rate_type := bis_common_parameters.get_secondary_rate_type;

    l_stmt_id := 100;
    IF (    (s_secondary_curr_code IS NULL AND
             s_secondary_rate_type IS NOT NULL)
         OR (s_secondary_curr_code IS NOT NULL AND
             s_secondary_rate_type IS NULL) ) THEN
    -- {
        RAISE SEC_CURR_SETUP_INVALID;
    -- }
    END IF;

    l_stmt_id := 110;
    -- clean the inventory setup tables
    clear_inv_exp_tables;

    return;
-- }
EXCEPTION
-- {
    WHEN SCHEMA_INFO_NOT_FOUND THEN
    -- {
        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => SCHEMA_INFO_NOT_FOUND_MESG,
                                    p_proc_name => l_proc_name, p_stmt_id => l_stmt_id));
        RAISE GLOBAL_SETUP_FAILED;
    -- }

    WHEN BIS_COMMON_API_FAILED THEN
    -- {
        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => BIS_COMMON_API_FAILED_MESG,
                                    p_proc_name => l_proc_name, p_stmt_id => l_stmt_id));
        RAISE GLOBAL_SETUP_FAILED;
    -- }

    WHEN EXP_TABLE_CLEANUP_FAILED THEN
    -- {
        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => EXP_TABLE_CLEANUP_FAILED_MESG,
                                    p_proc_name => l_proc_name,  p_stmt_id => l_stmt_id));
        RAISE GLOBAL_SETUP_FAILED;
    -- }

    WHEN PRIMARY_CURR_SETUP_BAD THEN
    -- {
        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => PRIMARY_CURR_SETUP_BAD_MESG,
                                     p_proc_name => l_proc_name,  p_stmt_id => l_stmt_id));
        RAISE GLOBAL_SETUP_FAILED;
    -- }

    WHEN NO_GLOBAL_CURR_CODE THEN
    -- {
        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => NO_GLOBAL_CURR_CODE_MESG,
                                     p_proc_name => l_proc_name, p_stmt_id => l_stmt_id));
        RAISE GLOBAL_SETUP_FAILED;
    -- }

    WHEN NO_GLOBAL_RATE_TYPE THEN
    -- {
        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => NO_GLOBAL_RATE_TYPE_MESG,
                                    p_proc_name => l_proc_name,p_stmt_id => l_stmt_id));
        RAISE GLOBAL_SETUP_FAILED;
    -- }

    WHEN SEC_CURR_SETUP_INVALID THEN
    -- {
        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => SEC_CURR_SETUP_INVALID_MESG,
                                    p_proc_name => l_proc_name,p_stmt_id => l_stmt_id));
        RAISE GLOBAL_SETUP_FAILED;
    -- }

    WHEN OTHERS THEN
    -- {
        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => SQLERRM, p_proc_name => l_proc_name,
                                    p_stmt_id => l_stmt_id));
        RAISE GLOBAL_SETUP_FAILED;
    -- }
-- }
END global_setup;


/*  global_wrapup

    Performs global wrapup.

    If program is successful or ending with a warning, then report success
    to the BIS logging module.

    Clean up tables if program is erroring out.

    Parameters:
    1. p_retcode - Current return code of the program.
        -1 = error
         1 = warning
         0 = success
    2. p_exp_rows_collected - Number of collected rows to report.

    History:
    Date        Author              Action
    07/07/05    Dinkar Gupta        Defined function.

*/
PROCEDURE global_wrapup (p_retcode IN NUMBER,
                         p_exp_rows_collected IN NUMBER)
IS
-- {
    l_proc_name CONSTANT VARCHAR2 (40) := 'global_wrapup';
    l_stmt_id NUMBER;
-- }
BEGIN
-- {
    -- Initialization block
    l_stmt_id := 0;

    l_stmt_id := 10;
    IF (p_retcode = C_ERROR) THEN
    -- {
        l_stmt_id := 20;
        -- clear up all tables
        clear_inv_exp_tables;

        l_stmt_id := 30;
        -- Program has failed. Call the BIS wrapup API appropriately.
        BIS_COLLECTION_UTILITIES.wrapup (
                p_status => FALSE,
                p_count => p_exp_rows_collected,
                p_message => C_CURR_INV_EXP_LOAD_ERROR_MESG);
    -- }
    ELSIF (p_retcode = C_WARNING OR p_retcode = C_SUCCESS) THEN
    -- {
        l_stmt_id := 40;
        -- from a BIS log perspective, program has been successful
        BIS_COLLECTION_UTILITIES.wrapup (TRUE, p_exp_rows_collected,
                                        C_SUCCESS_MESG);
    -- }
    END IF;

    return;

-- }
EXCEPTION
-- {

    WHEN EXP_TABLE_CLEANUP_FAILED THEN
    -- {
        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => EXP_TABLE_CLEANUP_FAILED_MESG,
                                    p_proc_name => l_proc_name, p_stmt_id => l_stmt_id));
        RAISE GLOBAL_WRAPUP_FAILED;
    -- }

    WHEN OTHERS THEN
    -- {
        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => SQLERRM, p_proc_name => l_proc_name,
                                    p_stmt_id => l_stmt_id));
        RAISE GLOBAL_WRAPUP_FAILED;
    -- }
-- }
END global_wrapup;


/*  clear_inv_exp_tables

    Clean up inventory expiration status tables.

    Parameters: None

    History:
    Date        Author              Action
    07/07/05    Dinkar Gupta        Defined function.

*/
PROCEDURE clear_inv_exp_tables
IS
-- {
    l_proc_name CONSTANT VARCHAR2 (40) := 'clear_inv_exp_tables';
    l_stmt_id NUMBER;
-- }
BEGIN
-- {
    -- Initialization block
    l_stmt_id := 0;

    l_stmt_id := 10;
    EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || s_opi_schema || '.' ||
                       'OPI_DBI_CURR_INV_EXP_F');

    return;

-- }
EXCEPTION
-- {

    WHEN OTHERS THEN
    -- {
        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => SQLERRM, p_proc_name =>l_proc_name,
                                    p_stmt_id =>l_stmt_id));
        RAISE EXP_TABLE_CLEANUP_FAILED;
    -- }
-- }
END clear_inv_exp_tables;



/*  err_mesg

    Return a C_ERRBUF_SIZE character long, properly formatted error
    message with the package name, procedure name and message.

    Parameters:
    p_mesg - Actual message to be printed
    p_proc_name - name of procedure that should be printed in the message
     (optional)
    p_stmt_id - step in procedure at which error occurred
     (optional)

    History:
    Date        Author              Action
    07/07/04    Dinkar Gupta        Defined function.
*/

FUNCTION err_mesg (p_mesg IN VARCHAR2,
                   p_proc_name IN VARCHAR2,
                   p_stmt_id IN NUMBER)
    RETURN VARCHAR2
IS
-- {
    l_proc_name CONSTANT VARCHAR2 (40) := 'err_mesg';
    l_stmt_id NUMBER;

    -- The variable declaration cannot take C_ERRBUF_SIZE (a defined constant)
    -- as the size of the declaration. I have to put 300 here.
    l_formatted_message VARCHAR2 (300);
-- }
BEGIN
-- {
    -- initialization block
    l_stmt_id := 0;

    -- initialization block
    l_formatted_message := NULL;

    l_stmt_id := 10;
    l_formatted_message := substr ((C_PKG_NAME || '.' || p_proc_name || ' #' ||
                                   to_char (p_stmt_id) || ': ' || p_mesg),
                                   1, C_ERRBUF_SIZE);

    commit;

    return l_formatted_message;
-- }
EXCEPTION
-- {
    WHEN OTHERS THEN
    -- {
        -- the exception happened in the exception reporting function !!
        -- return with ERROR.
        l_formatted_message := substr ((C_PKG_NAME || '.' || l_proc_name ||
                                       ' #' ||
                                        to_char (l_stmt_id) || ': ' ||
                                       SQLERRM),
                                       1, C_ERRBUF_SIZE);

        l_formatted_message := 'Error in error reporting.';
        return l_formatted_message;
    -- }
-- }
END err_mesg;

/*  print_stage_done_mesg

    Print a message of 'Done' for whatever procedure/statement called.

    Parameters:
    p_proc_name - name of procedure that should be printed in the message
    p_stmt_id - step in procedure at which error occurred

    History:
    Date        Author              Action
    07/07/04    Dinkar Gupta        Defined function.
*/

PROCEDURE print_stage_done_mesg (p_proc_name IN VARCHAR2,
                                 p_stmt_id IN NUMBER)
IS
-- {
    l_proc_name CONSTANT VARCHAR2 (40) := 'print_stage_done_mesg';
    l_stmt_id NUMBER;

    -- The variable declaration cannot take C_ERRBUF_SIZE (a defined constant)
    -- as the size of the declaration. I have to put 300 here.
    l_formatted_message VARCHAR2 (300);
-- }
BEGIN
-- {
    -- initialization block
    l_stmt_id := 0;

    -- initialization block
    l_formatted_message := NULL;

    l_stmt_id := 10;
    l_formatted_message := substr ((C_PKG_NAME || '.' || p_proc_name || ' #' ||
                                   to_char (p_stmt_id) || ': ' || 'Done.'),
                                   1, C_ERRBUF_SIZE);

    BIS_COLLECTION_UTILITIES.PUT_LINE (l_formatted_message);

    return;
-- }
EXCEPTION
-- {
    WHEN OTHERS THEN
    -- {
        -- the exception happened in the print function
        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => SQLERRM, p_proc_name => l_proc_name,
                                    p_stmt_id => l_stmt_id));

        RAISE; -- on to wrapper
    -- }
-- }
END print_stage_done_mesg;

/* extract_expired_inventory

    Extract the onhand and expired lot controlled inventory quantity/value
    as of the run time from the inventory current snapshot tables,
    MTL_ONHAND_QUANTITIES and MTL_LOT_NUMBERS. All inventory that is not
    lot controlled will be ignored in this extraction.

    Inventory value is computed using the current item costs stored in the
    system.

    Store the inventory value in the functional currency, DBI primary
    global currency and DBI secondary global currency (if set up).

    Aggregate the information for high level report queries, by rolling
    up along item and inventory category.

    Query details below.

    DO NOT COMMIT DATA HERE!!

    Parameters:
    1. p_run_date - Date on which the program was run. Trunc'ed already.


*/
PROCEDURE extract_expired_inventory (p_run_date IN DATE,
                                     p_rows_collected OUT NOCOPY NUMBER)
IS
-- {

    l_proc_name CONSTANT VARCHAR2 (40) := 'check_missing_rates';
    l_stmt_id NUMBER;

-- }
BEGIN
-- {

    -- initialization block
    l_stmt_id := 0;
    p_rows_collected := 0; -- nothing collected yet.

    l_stmt_id := 10;
    -- Extract data. Query logic is as follows:
    --
    -- Extract the onhand and expired lot controlled inventory quantity and
    -- value as of the run time from the inventory current snapshot tables,
    -- MTL_ONHAND_QUANTITIES and MTL_LOT_NUMBERS. All inventory that is not
    -- lot controlled will be ignored in this extraction. Since the MTL
    -- tables store quantity in the item's primary uom, there is no need
    -- for unit of measure conversions.
    --
    -- Expiration of lots is determined as follows:
    -- 1. Lot expiration date = NULL
    --      ==> Lot has not expired
    -- 2. Lot expiration date >=  p_run_date
    --      ==> Lot has not expired yet
    -- 3. Lot expiration date < p_run_date
    --      ==> Lot has expired
    --
    -- Inventory value is computed using the current item costs stored in the
    -- system. The cost type is determined from the primary_cost_method
    -- (1 = standard, else layered) from MTL_PARAMETERS.
    --
    -- For standard costing organizations, the current item cost can
    -- be obtained from the CST_ITEM_COSTS table. Since there are multiple
    -- cost_type_id's in the CIC table, we care only about frozen cost
    -- (cost_type_id = 1). Also, CIC may not have a frozen (cost_type_id = 2)
    -- record for a layered costing org item, but may have other
    -- cost_type_id records. Hence the need to do an outer join on the
    -- cost_type_id(+) = 1 filter condition instead of using just the
    -- nvl (cost_type_id, 1) = 1 condition.
    --
    -- For layered costing organization, the item cost
    -- must be obtained from CST_QUANTITY_LAYERS at the cost group level.
    --
    --
    -- Due to presence of expense items and the fact that CQL only has
    -- records for items in layered costing organizations, the joins to
    -- both costing tables will be outer joins. Join to MTL_SYSTEM_ITEMS_B
    -- to check whether an item is an expense item or not.
    --
    -- Similarly items in expense subinventories will be assigned 0 value.
    --
    -- Store the inventory value in the functional currency, DBI primary
    -- global currency and DBI secondary global currency (if set up). Use
    -- the standard fii_currency.get_global_rate_primary and
    -- fii_currency.get_global_rate_secondary to get conversion rates.
    --
    -- Rates are only needed for all distinct organizations with defined lots
    -- as of the day on which the program is being run.
    -- The FII conversion rate APIs behave as follows:
    -- 1 for currency code of 'USD' which is the global currency
    -- ## - conversion factor if conversion rate is defined.
    -- -1 for dates for which there is no currency conversion rate
    -- -2 for unrecognized currency conversion rates
    -- -3 for missing EUR to USD rates on 01-JAN-1999 when the
    --    transaction_date is prior to 01-JAN-1999 (when the EUR
    --    officially went into circulation).
    --  (This last case will not happen here since this program always runs
    --  as of sysdate)
    --
    -- Additionally, the secondary conversion rate API returns NULL if
    -- the DBI secondary global currency has not been set up. Since the
    -- number of distinct organizations will be small and there is no
    -- separate conversion rates staging table, the primary and
    -- secondary currency rate APIs will be called for all orgs, even if
    -- the primary and secondary currencies are the same.
    --
    -- Aggregate the information for high level report queries, by rolling
    -- up along item and inventory category. Store the item_org_id from
    -- the item dimension table, ENI_OLTP_ITEM_STAR for report queries.
    -- As a result, the highest rollup is at the organization level.
    --
    -- Maintain the functional currency code and conversion rates
    -- corresponding to organizations at all records. That way, missing
    -- rates can be detected very easily by querying the rolled up org
    -- level records.

    -- For process organizations, we use the get_opm_item_cost API to get
    -- the cost as on the run date. We collect cost for the lot-controlled items
    -- in MTL_ONHAND_QUANTITIES that belong to process organizations.These orgs
    -- are determined from the process_enabled_flag = 'Y' from MTL_PARAMETERS.
    --
    INSERT /*+ append parallel (opi_dbi_curr_inv_exp_f) */
    INTO opi_dbi_curr_inv_exp_f (
        organization_id,
        inventory_item_id,
        item_org_id,
        uom_code,
        inv_category_id,
        func_currency_code,
        aggregation_level_flag,
        onhand_qty,
        expired_qty,
        onhand_val_b,
        onhand_val_g,
        onhand_val_sg,
        expired_val_b,
        expired_val_g,
        expired_val_sg,
        conversion_rate,
        sec_conversion_rate,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login,
        program_id,
        program_login_id,
        program_application_id,
        request_id
    )
    SELECT /*+ parallel (exp_inv) parallel (conv_rates) */
        exp_inv.organization_id,
        exp_inv.inventory_item_id,
        exp_inv.item_org_id,
        exp_inv.primary_uom_code,
        exp_inv.inv_category_id,
        conv_rates.func_currency_code,
        grouping_id (exp_inv.inv_category_id,
                     exp_inv.item_org_id)
            aggregation_level_flag,
        sum (exp_inv.onhand_qty) onhand_qty,
        sum (exp_inv.expired_qty) expired_qty,
        sum (exp_inv.onhand_val_b) onhand_val_b,
        sum (exp_inv.onhand_val_b * conv_rates.conversion_rate)
            onhand_val_g,
        sum (exp_inv.onhand_val_b * conv_rates.sec_conversion_rate)
            onhand_val_sg,
        sum (exp_inv.expired_val_b) expired_val_b,
        sum (exp_inv.expired_val_b * conv_rates.conversion_rate)
            expired_val_g,
        sum (exp_inv.expired_val_b * conv_rates.sec_conversion_rate)
            expired_val_sg,
        conv_rates.conversion_rate,
        conv_rates.sec_conversion_rate,
        sysdate,
        sysdate,
        s_user_id,
        s_user_id,
        s_login_id,
        s_program_id,
        s_program_login_id,
        s_program_application_id,
        s_request_id
      FROM
        (
        SELECT /*+  parallel (exp_qty) parallel (cic) parallel (cql)
                    parallel (items) parallel (msi) parallel (mp)
                    parallel (subs) */
            exp_qty.organization_id,
            exp_qty.inventory_item_id,
            items.id item_org_id,
            items.primary_uom_code,
            nvl (items.inv_category_id, -1) inv_category_id,
            sum (exp_qty.onhand_qty) onhand_qty,
            sum (exp_qty.expired_qty) expired_qty,
            sum (decode (subs.asset_inventory,
                         C_EXPENSE_SUBINVENTORY, 0,
                         (decode (msi.inventory_asset_flag,
                                  C_EXPENSE_ITEM_FLAG, 0,
                                  exp_qty.onhand_qty *
                                  decode(mp.process_enabled_flag,'Y',
					OPI_DBI_INV_VALUE_INIT_PKG.GET_OPM_ITEM_COST(exp_qty.organization_id,
									   exp_qty.inventory_item_id,
									   p_run_date),
				  decode (mp.primary_cost_method,
                                          C_STANDARD_COSTING_ORG,
                                                cic.item_cost,
                                          cql.item_cost))))))
                onhand_val_b,
            sum (decode (subs.asset_inventory,
                         C_EXPENSE_SUBINVENTORY, 0,
                         (decode (msi.inventory_asset_flag,
                                  C_EXPENSE_ITEM_FLAG, 0,
                                  exp_qty.expired_qty *
                                  decode(mp.process_enabled_flag,'Y',
					 OPI_DBI_INV_VALUE_INIT_PKG.GET_OPM_ITEM_COST(exp_qty.organization_id,
									   exp_qty.inventory_item_id,
									   p_run_date),
					  decode (mp.primary_cost_method,
						  C_STANDARD_COSTING_ORG,
						  cic.item_cost,
                                                  cql.item_cost))))))
                expired_val_b
          FROM
            (
            SELECT /*+ parallel (moq) parallel (mln)
                       use_hash (moq, mln) */
                moq.organization_id,
                moq.inventory_item_id,
                moq.cost_group_id,
                moq.subinventory_code,
                sum (moq.transaction_quantity) onhand_qty,
                sum (CASE WHEN mln.expiration_date < p_run_date THEN
                            moq.transaction_quantity
                          ELSE
                            0
                     END)
                    expired_qty
              FROM  mtl_onhand_quantities moq,
                    mtl_lot_numbers mln
              WHERE moq.inventory_item_id   = mln.inventory_item_id
                AND moq.organization_id     = mln.organization_id
                AND moq.lot_number          = mln.lot_number
              GROUP BY
                moq.organization_id,
                moq.inventory_item_id,
                moq.cost_group_id,
                moq.subinventory_code
            ) exp_qty,
            mtl_system_items_b msi,
            eni_oltp_item_star items,
            mtl_parameters mp,
            cst_item_costs cic,
            cst_quantity_layers cql,
            mtl_secondary_inventories subs
          WHERE exp_qty.inventory_item_id   = msi.inventory_item_id
            AND exp_qty.organization_id     = msi.organization_id
            AND exp_qty.inventory_item_id   = items.inventory_item_id
            AND exp_qty.organization_id     = items.organization_id
            AND exp_qty.organization_id     = mp.organization_id
            AND exp_qty.inventory_item_id   = cic.inventory_item_id (+)
            AND exp_qty.organization_id     = cic.organization_id (+)
            AND 1                           = cic.cost_type_id (+)
            AND exp_qty.inventory_item_id   = cql.inventory_item_id (+)
            AND exp_qty.organization_id     = cql.organization_id (+)
            AND exp_qty.cost_group_id       = cql.cost_group_id (+)
            AND exp_qty.organization_id     = subs.organization_id
            AND exp_qty.subinventory_code   = subs.secondary_inventory_name
          GROUP BY
            exp_qty.organization_id,
            exp_qty.inventory_item_id,
            items.id,
            items.primary_uom_code,
            nvl (items.inv_category_id, -1)
        ) exp_inv,
        (
        SELECT /*+ parallel (to_conv) parallel (curr_codes) */
            to_conv.organization_id,
            curr_codes.currency_code func_currency_code,
            p_run_date run_date,
            decode (curr_codes.currency_code,
                    s_global_curr_code, 1,
                    fii_currency.get_global_rate_primary (
                           curr_codes.currency_code,
                           p_run_date) )
                conversion_rate,
            decode (s_secondary_curr_code,
                    NULL, NULL,
                    curr_codes.currency_code, 1,
                    fii_currency.get_global_rate_secondary (
                           curr_codes.currency_code,
                           p_run_date))
                sec_conversion_rate
          FROM
            (SELECT /*+ parallel (mtl_lot_numbers) */
             DISTINCT organization_id
               FROM mtl_lot_numbers) to_conv,
            (SELECT /*+ leading (hoi) full (hoi) use_hash (gsob)
                        parallel (hoi) parallel (gsob)*/
             DISTINCT hoi.organization_id, gsob.currency_code
               FROM hr_organization_information hoi,
                    gl_sets_of_books gsob
               WHERE hoi.org_information_context  = 'Accounting Information'
                 AND hoi.org_information1  = to_char(gsob.set_of_books_id))
            curr_codes
          WHERE curr_codes.organization_id  = to_conv.organization_id
        ) conv_rates
      WHERE conv_rates.organization_id = exp_inv.organization_id
      GROUP BY
        exp_inv.organization_id,
        conv_rates.func_currency_code,
        conv_rates.conversion_rate,
        conv_rates.sec_conversion_rate,
        ROLLUP (
                exp_inv.inv_category_id,
                (exp_inv.item_org_id,
                 exp_inv.inventory_item_id,
                 exp_inv.primary_uom_code)
               );

    l_stmt_id := 20;
    -- Count the number of rows collected
    p_rows_collected := SQL%ROWCOUNT;

    return;

-- }
EXCEPTION
-- {

    WHEN OTHERS THEN
    -- {
        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => SQLERRM, p_proc_name =>l_proc_name,
                                    p_stmt_id => l_stmt_id));

        RAISE EXP_INV_EXTRACT_ERROR;
    -- }
-- }
END extract_expired_inventory;


/*  check_missing_rates

    If any primary conversion rates are missing, throw an exception.
    If any secondary currency rates are missing (after the secondary
    currency has been set up) throw an exception.

    Data is checked directly in the fact in the org level records since
    currency conversion rate errors can be detected at that level.

    Parameters:
    1. p_run_date - Date on which the program was run.

    History:
    Date        Author              Action
    07/07/05    Dinkar Gupta        Defined procedure.
*/

PROCEDURE check_missing_rates (p_run_date IN DATE)
IS
-- {
    l_proc_name CONSTANT VARCHAR2 (40) := 'check_missing_rates';
    l_stmt_id NUMBER;

    -- Cursor to see if any rates are missing. See below for details
    -- about the +999 for sec_conversion_rates.
    CURSOR invalid_rates_exist_csr IS
    -- {
        SELECT 1
          FROM opi_dbi_curr_inv_exp_f
          WHERE (   nvl (conversion_rate, -999) < 0
                 OR nvl (sec_conversion_rate, 999) < 0)
            AND rownum < 2;
    -- }

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
    -- (This will not happen in our case since this is a complete
    -- refresh program, written well after 1999).
    --
    -- However, with the secondary currency, the null rate means it
    -- has not been setup and should therefore not be reported as an
    -- error.
    --
    -- Since this is a full refresh program with a nested fact, we report
    -- missing rates of the org level records (aggregation_level_flag = 3)
    -- since currency codes are defined at that level.
    --
    -- Note: If some orgs never had a functional currency code defined,
    -- they will show up as errors here.
    CURSOR invalid_rates_csr (p_pri_sec_curr_same NUMBER) IS
    -- {
        SELECT /*+ parallel (compare) */
        DISTINCT
            report_order,
            curr_code,
            rate_type,
            p_run_date run_date,
            func_currency_code
          FROM (
            SELECT /*+ parallel (conv) */
                s_global_curr_code curr_code,
                s_global_rate_type rate_type,
                1 report_order, -- ordering global currency first
                conv.func_currency_code
              FROM opi_dbi_curr_inv_exp_f conv
              WHERE nvl (conv.conversion_rate, -999) < 0 -- null is not fine
                AND conv.aggregation_level_flag = 3 -- org level records
            UNION ALL
            SELECT /*+ parallel (conv) */
                s_secondary_curr_code curr_code,
                s_secondary_rate_type rate_type,
                2 report_order,     --ordering secondary currency next
                conv.func_currency_code
              FROM opi_dbi_curr_inv_exp_f conv
              WHERE nvl (conv.sec_conversion_rate, 999) < 0 -- null is fine
                AND conv.aggregation_level_flag = 3 -- org level records
                -- check here if primary not same as secondary
                AND p_pri_sec_curr_same = 0
          ) compare
          ORDER BY
                report_order ASC,
                func_currency_code;
        -- }

    -- Flag to ensure all rates have been found.
    l_all_rates_found BOOLEAN;

    -- Boolean to check if the primary and secondary currencies are the
    -- same
    l_pri_sec_curr_same NUMBER;
-- }
BEGIN
-- {
    -- initialization block
    l_stmt_id := 0;
    l_all_rates_found := true;
    l_pri_sec_curr_same := 0;

    l_stmt_id := 10;
    -- check if the primary and secondary currencies and rate types are
    -- identical.
    IF (s_global_curr_code = nvl (s_secondary_curr_code, '---') AND
        s_global_rate_type = nvl (s_secondary_rate_type, '---') ) THEN
    -- {
        l_pri_sec_curr_same := 1;
    -- }
    END IF;


    l_stmt_id := 20;
    -- Check that all rates have been found and are non-negative.
    -- If there is a problem, notify user.
    OPEN invalid_rates_exist_csr;
    FETCH invalid_rates_exist_csr INTO invalid_rates_exist_rec;
    IF (invalid_rates_exist_csr%FOUND) THEN
    -- {
        l_stmt_id := 30;
        -- print the header out
        BIS_COLLECTION_UTILITIES.writeMissingRateHeader;

        l_stmt_id := 40;
        -- all rates not found
        l_all_rates_found := false;

        l_stmt_id := 50;
        FOR invalid_rate_rec IN invalid_rates_csr (l_pri_sec_curr_same)
        LOOP
        -- {
            l_stmt_id := 60;
            BIS_COLLECTION_UTILITIES.writeMissingRate(
               p_rate_type => invalid_rate_rec.rate_type,
               p_from_currency => invalid_rate_rec.func_currency_code,
               p_to_currency => invalid_rate_rec.curr_code,
               p_date => invalid_rate_rec.run_date);
        -- }
        END LOOP;
    -- }
    END IF;

    l_stmt_id := 70;
    CLOSE invalid_rates_exist_csr;

    -- If all rates not found raise an exception
    l_stmt_id := 80;
    IF (l_all_rates_found = FALSE) THEN
        RAISE MISSING_CONV_RATES;
    END IF;

    RETURN;

EXCEPTION
-- {

    WHEN MISSING_CONV_RATES THEN
    -- {
        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => MISSING_CONV_RATES_MESG,
                                    p_proc_name => l_proc_name, p_stmt_id => l_stmt_id));
        RAISE CONV_RATES_ERROR;
    -- }

    WHEN OTHERS THEN
    -- {
        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => SQLERRM,  p_proc_name => l_proc_name,
                                     p_stmt_id => l_stmt_id));

        RAISE CONV_RATES_ERROR;
    -- }
-- }
END check_missing_rates;


/*  ref_curr_inv_exp

    Refresh the current inventory expiration fact with the onhand
    quantity/value and expired quantity/value of lot controlled inventory
    as of the run time of the program.

    Data is reported in functional, DBI global and DBI secondary global
    currencies. Missing conversion rates cause program to error out. The
    fact table is truncated when the program errors out, if possible.

    History:
    Date        Author              Action
    07/07/05    Dinkar Gupta        Wrote Function.

*/
PROCEDURE ref_curr_inv_exp (errbuf OUT NOCOPY VARCHAR2,
                            retcode OUT NOCOPY NUMBER)
IS
-- {
    l_proc_name CONSTANT VARCHAR2 (40) := 'ref_curr_inv_exp';
    l_stmt_id NUMBER;

    l_rows_collected NUMBER;

    l_missing_conv_rates BOOLEAN;

    l_run_date DATE;
-- }
BEGIN
-- {
    -- Initialization block.
    l_stmt_id := 0;
    l_rows_collected := 0;  -- nothing collected yet
    retcode := C_SUCCESS;   -- by default, success
    errbuf := C_SUCCESS_MESG;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 10;
    -- Call the global setup API
    global_setup ();
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 20;
    -- Today's date
    l_run_date := trunc (sysdate);
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 30;
    -- Extract all the expired inventory data.
    -- Only extract data and insert to fact. Don't commit.
    extract_expired_inventory (l_run_date,
                               l_rows_collected);
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 40;
    -- Commit all data centrally in main procedure.
    commit;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 50;
    -- Check for missing conversion rates.
    -- Throws CONV_RATES_ERROR exception if missing rates are found.
    check_missing_rates (l_run_date);
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 60;
    -- Successful completion
    retcode := C_SUCCESS;
    errbuf := C_SUCCESS_MESG;
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    l_stmt_id := 70;
    -- General wrapup procedure
    global_wrapup (retcode, l_rows_collected);
    print_stage_done_mesg (l_proc_name, l_stmt_id);

    return;

-- }
EXCEPTION
-- {
    WHEN GLOBAL_SETUP_FAILED THEN
    -- {
        rollback;
        retcode := C_ERROR;
        errbuf := C_CURR_INV_EXP_LOAD_ERROR_MESG;
        global_wrapup (retcode, l_rows_collected);

        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => GLOBAL_SETUP_FAILED_MESG,
                                    p_proc_name => l_proc_name, p_stmt_id => l_stmt_id));
        return;
    -- }

    WHEN EXP_INV_EXTRACT_ERROR THEN
    -- {
        rollback;
        retcode := C_ERROR;
        errbuf := C_CURR_INV_EXP_LOAD_ERROR_MESG;
        global_wrapup (retcode, l_rows_collected);

        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => EXP_INV_EXTRACT_ERROR_MESG,
                                    p_proc_name => l_proc_name,p_stmt_id => l_stmt_id));
        return;
    -- }

    WHEN CONV_RATES_ERROR THEN
    -- {
        rollback;
        retcode := C_ERROR;
        errbuf := C_CURR_INV_EXP_LOAD_ERROR_MESG;
        global_wrapup (retcode, l_rows_collected);

        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => CONV_RATES_ERROR_MESG,
                                    p_proc_name => l_proc_name,p_stmt_id => l_stmt_id));
        return;
    -- }

    WHEN GLOBAL_WRAPUP_FAILED THEN
    -- {
        rollback;
        retcode := C_ERROR;
        errbuf := C_CURR_INV_EXP_LOAD_ERROR_MESG;
        -- try calling it again?? This time it'll clear the fact.
        global_wrapup (retcode, l_rows_collected);

        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => GLOBAL_WRAPUP_FAILED_MESG,
                                    p_proc_name => l_proc_name, p_stmt_id => l_stmt_id));
        return;
    -- }

    WHEN OTHERS THEN
    -- {
        rollback;
        retcode := C_ERROR;
        errbuf := C_CURR_INV_EXP_LOAD_ERROR_MESG;
        global_wrapup (retcode, l_rows_collected);

        BIS_COLLECTION_UTILITIES.PUT_LINE (
                p_text => err_mesg (p_mesg => SQLERRM,p_proc_name => l_proc_name,
                                    p_stmt_id => l_stmt_id));

        return;
    --}
-- }
END ref_curr_inv_exp;



END OPI_DBI_CURR_INV_EXP_PKG;

/
