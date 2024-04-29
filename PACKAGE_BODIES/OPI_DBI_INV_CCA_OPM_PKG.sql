--------------------------------------------------------
--  DDL for Package Body OPI_DBI_INV_CCA_OPM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_INV_CCA_OPM_PKG" AS
/*$Header: OPIDEICCAPB.pls 120.1 2005/08/02 04:55:28 visgupta noship $ */

/**************************************************
* Global Varaiables
**************************************************/

g_ERROR CONSTANT NUMBER := -1;   -- concurrent manager error code
g_WARNING CONSTANT NUMBER := 1;  -- concurrent manager warning code
g_OK CONSTANT NUMBER := 0;  -- concurrent manager success code
g_CY_ZERO_DATE DATE :=  to_date(fnd_profile.value('SY$ZERODATE'),'yyyy/mm/dd');

/**************************************************
* User Defined Exceptions
**************************************************/

GLOBAL_START_DATE_NULL EXCEPTION;
PRAGMA EXCEPTION_INIT (GLOBAL_START_DATE_NULL, -20900);
GLOBAL_START_DATE_NULL_MESG CONSTANT VARCHAR2(200) := 'The global start date seems null. Please set up the global start date correctly.';

GLOBAL_SETUP_MISSING EXCEPTION;
PRAGMA EXCEPTION_INIT (GLOBAL_SETUP_MISSING, -20901);
GLOBAL_SETUP_MISSING_MESG CONSTANT VARCHAR2(200) := 'Unable to verify setup of global start date and global currency code.';

MISSING_DATES EXCEPTION;
PRAGMA EXCEPTION_INIT (MISSING_DATES, -20902);
MISSING_DATES_MESG CONSTANT VARCHAR2(200) := 'Missing Date.';

INITIALIZATION_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (INITIALIZATION_ERROR, -20903);

SETUP_LOG_INIT_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (SETUP_LOG_INIT_ERROR, -20904);

EXTRACT_ADJ_INIT_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (EXTRACT_ADJ_INIT_ERROR, -20906);

EXTRACT_MATCHES_INIT_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (EXTRACT_MATCHES_INIT_ERROR, -20907);

OPM_EXTRACTION_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (OPM_EXTRACTION_ERROR, -20910);
OPM_EXTRACTION_ERROR_MESG CONSTANT VARCHAR2(200) := 'Error Occured during OPM Extraction.';


/**************************************************
* File scope variables
**************************************************/

s_user_id    NUMBER := nvl(fnd_global.user_id, -1);
s_login_id   NUMBER := nvl(fnd_global.login_id, -1);

s_global_start_date DATE := NULL;

/**************************************************
* Common Procedures (to initial and incremental load)
*
* File scope functions (not in spec)
**************************************************/

/*FUNCTION check_global_setup
    RETURN BOOLEAN;
 */
FUNCTION err_mesg (p_mesg IN VARCHAR2,
                   p_proc_name IN VARCHAR2 DEFAULT NULL,
                   p_stmt_id IN NUMBER DEFAULT -1)
    RETURN VARCHAR2;

PROCEDURE setup_load;


/**************************************************
* Initial Load Procedures
*
* File scope functions (not in spec)
**************************************************/

--PROCEDURE setup_log_init;
PROCEDURE extract_adjustments_init;
PROCEDURE extract_exact_matches_init;

/**************************************************
* Incremental Load Procedures
*
* File scope functions (not in spec)
**************************************************/

-- No incremental load procedures

/**************************************************
* Common Procedures Definitions
**************************************************/

/* setup_load

    Gets the GSD.

    History:
    Date        Author              Action
    07/04/04    Vedhanarayanan G    Defined procedure.

*/

PROCEDURE setup_load
IS
    l_proc_name VARCHAR2 (40);
    l_stmt_id NUMBER;
    l_from_date  DATE;
    l_to_date    DATE;
    l_missing_day_flag BOOLEAN;
    l_min_miss_date DATE;
    l_max_miss_date DATE;

BEGIN

    -- Initialization
    l_proc_name := 'setup_load';
    l_stmt_id := 0;
    l_missing_day_flag := FALSE;

    l_stmt_id := 10;
    -- Check for the primary currency code and global start date setup.
    -- These two parameters must be set up prior to any DBI load.
    -- done in Discrete package.
 /*   IF (NOT (check_global_setup ())) THEN
        RAISE GLOBAL_SETUP_MISSING;
    END IF;
   */
    -- Get the global start date
    l_stmt_id := 20;
    s_global_start_date := trunc (bis_common_parameters.get_global_start_date);
    IF (s_global_start_date IS NULL) THEN
        RAISE GLOBAL_START_DATE_NULL;
    END IF;


    l_stmt_id :=30;
    l_from_date := s_global_start_date;
    l_to_date := sysdate;

    fii_time_api.check_missing_date( P_FROM_DATE => l_from_date,
    				     P_TO_DATE => l_to_date,
    				     P_HAS_MISSING_DATE => l_missing_day_flag,
                                     P_MIN_MISSING_DATE => l_min_miss_date,
                                     P_MAX_MISSING_DATE => l_max_miss_date);

    IF (l_missing_day_flag) THEN
    	BIS_COLLECTION_UTILITIES.PUT_LINE ('Missing Dates Range from ' || l_min_miss_date ||
    					   'to' || l_max_miss_date);
    	RAISE MISSING_DATES;
    END IF;


EXCEPTION

    WHEN GLOBAL_SETUP_MISSING THEN

    	BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (GLOBAL_SETUP_MISSING_MESG,
                                                         l_proc_name, l_stmt_id));
        RAISE INITIALIZATION_ERROR;

    WHEN GLOBAL_START_DATE_NULL THEN

	BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (GLOBAL_START_DATE_NULL_MESG,
	                                             l_proc_name, l_stmt_id));
        RAISE INITIALIZATION_ERROR;

    WHEN MISSING_DATES THEN

    	BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (MISSING_DATES_MESG,
    	                                             l_proc_name, l_stmt_id));
        RAISE INITIALIZATION_ERROR;

    WHEN OTHERS THEN

    	RAISE INITIALIZATION_ERROR;

END setup_load;


/*  check_global_setup

    Checks to see if basic global parameters are set up.
    Currently these include the:
    1. Global start date
    2. Global currency code

    Parameters: None

    History:
    Date        Author              Action
    07/04/04    Vedhanarayanan G    Defined procedure.
*/
/*
FUNCTION check_global_setup
    RETURN BOOLEAN
IS
    l_proc_name VARCHAR2 (40);
    l_stmt_id NUMBER;
    l_setup_good BOOLEAN;
    l_list dbms_sql.varchar2_table;

BEGIN

    -- Initialization
    l_proc_name := 'check_global_setup';
    l_stmt_id  := 0;
    l_setup_good  := false;

    -- Parameters we want to check for
    l_list(1) := 'BIS_PRIMARY_CURRENCY_CODE';
    l_list(2) := 'BIS_GLOBAL_START_DATE';
    l_stmt_id := 10;
    l_setup_good := bis_common_parameters.check_global_parameters(l_list);
    return l_setup_good;

EXCEPTION

    WHEN OTHERS THEN
        rollback;
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                    l_stmt_id));
        l_setup_good := false;
        return l_setup_good;

END check_global_setup;


*/
/* err_mesg

    History:
    Date        Author              Action
    07/04/04    Vedhanarayanan G    Defined procedure.
*/

FUNCTION err_mesg (p_mesg IN VARCHAR2,
                   p_proc_name IN VARCHAR2 DEFAULT NULL,
                   p_stmt_id IN NUMBER DEFAULT -1)
    RETURN VARCHAR2
IS

    l_proc_name VARCHAR2 (60);
    l_stmt_id NUMBER;

    -- The variable declaration cannot take C_ERRBUF_SIZE (a defined constant)
    -- as the size of the declaration. I have to put 300 here.
    l_formatted_message VARCHAR2 (300) := NULL;

BEGIN

    l_proc_name  := 'err_mesg';
    l_stmt_id  := 0;

    l_stmt_id := 10;
    l_formatted_message := substr ((C_PKG_NAME || '.' || p_proc_name || ' #' ||
                                   to_char (p_stmt_id) || ': ' || p_mesg),
                                   1, C_ERRBUF_SIZE);

    commit;

    return l_formatted_message;

EXCEPTION

    WHEN OTHERS THEN
        -- the exception happened in the exception reporting function !!
        -- return with ERROR.
        l_formatted_message := substr ((C_PKG_NAME || '.' || l_proc_name ||
                                       ' #' ||
                                        to_char (l_stmt_id) || ': ' ||
                                       SQLERRM),
                                       1, C_ERRBUF_SIZE);

        l_formatted_message := 'Error in error reporting.';
        return l_formatted_message;

END err_mesg;


/**************************************************
* Initial Load Procedure Definitions
**************************************************/

/* run_initial_load

    Wrapper routine for the initial load of the cycle count accuracy for OPM ETL.

    Parameters:
    retcode - 0 on successful completion, -1 on error and 1 for warning.
    errbuf - empty on successful completion, message on error or warning

    History:
    Date        Author              Action
    04/03/04    Vedhanarayanan G    Defined Procedure.

*/

PROCEDURE run_initial_load_opm(errbuf    in out NOCOPY  VARCHAR2,
                               retcode   in out NOCOPY  NUMBER)

IS

BEGIN

    setup_load();

    commit;

    extract_adjustments_init();

    commit;

    extract_exact_matches_init();

    commit;

    retcode := g_OK;


EXCEPTION

    WHEN OTHERS THEN

        retcode := g_ERROR;
        BIS_COLLECTION_UTILITIES.PUT_LINE (OPM_EXTRACTION_ERROR_MESG);
    	RAISE OPM_EXTRACTION_ERROR;


END run_initial_load_opm;


/* extract_adjustments_init

    Extracts adjustments from the test and the permanent subledger. All transactions of type
    PICY and transaction date >= the GSD are extracted from the test subledger and from the
    permanent subledger transactions with transaction date >= from transaction date and
    < transaction date from the log.

    R12 Changes
    ----------
    The adjustment collection will be from the permanent subledger only. As before migrating to R12,
    all the draft transactions will be posted to permanent. Also the upper bounds will
    be removed. Hence all the cycle count adjustments which are on or after GSD will be collected.
    This procedure will be called only when R12 migration date will be greater than GSD.

    History:
    Date        Author              Action
    07/04/04    Vedhanarayanan G    Defined procedure.
    07/04/05	Vishal Gupta	    Refer R12 Changes.

*/

PROCEDURE extract_adjustments_init
IS

    l_proc_name VARCHAR2 (40);
    l_stmt_id NUMBER;
    l_sysdate DATE;


BEGIN

    l_stmt_id  := 0;
    l_proc_name  := 'extract_adjustments_init';


    BIS_COLLECTION_UTILITIES.PUT_LINE('Extracting Adjustments Initial Load from - ' ||
    				       TO_CHAR(s_global_start_date,'mm-dd-yyyy hh24:mi:ss'));
    BIS_COLLECTION_UTILITIES.PUT_LINE('Extracting Adjustemnts Initail Load Start Time - ' ||
                                       TO_CHAR(SYSDATE, 'hh24:mi:ss'));

    l_stmt_id :=20;

    INSERT /*+ append parallel(OPI_DBI_INV_CCA_STG) */
    INTO opi_dbi_inv_cca_stg (
        organization_id,
        inventory_item_id,
        cycle_count_header_id,
        abc_class_id,
        subinventory_code,
        cycle_count_entry_id,
        source,
        approval_date,
        uom_code,
        system_inventory_qty,
        positive_adjustment_qty,
        negative_adjustment_qty,
        item_unit_cost,
        item_adj_unit_cost,
        hit_miss_pos,
        hit_miss_neg,
        exact_match)
    SELECT/*+ full(ich) use_hash(ica,ich,irm,iwi,icd,icmb,iwm,msi,gl_join)
           parallel(ica) parallel(ich) parallel(irm) parallel(iwi) parallel(icd)
           parallel(icmb) parallel(iwm) parallel(msi) parallel(gl_join) */
    	iwm.mtl_organization_id,
	msi.inventory_item_id,
	-1,
	nvl(iwi.whse_abccode,to_char(-1)),
	to_char(-1),
	ica.cycle_id||'-'||ica.seq_no,
	C_PRER12_SOURCE,
	trunc(ich.last_update_date) approval_date,
	msi.primary_uom_code,
	ica.frozen_qty1,
	CASE WHEN ica.var_qty1 > 0 THEN
		ica.var_qty1
	     ELSE 0
	END,
	CASE WHEN ica.var_qty1 < 0 THEN
		-1*ica.var_qty1
	     ELSE 0
	END,
	opi_dbi_inv_cca_opm_pkg.get_unit_cost(ica.item_id,ica.whse_code,iwm.orgn_code,trunc(icd.creation_date)),
	abs(gl_join.amount_base/ica.var_qty1),
	irm.percent_warn,
	irm.percent_warn,
	decode(ica.var_qty1,0,1,0)
   FROM
   	ic_cycl_adt ica,
	ic_cycl_hdr ich,
	ic_rank_mst irm,
	ic_whse_inv iwi,
	ic_cycl_dtl icd,
	ic_item_mst_b icmb,
	ic_whse_mst iwm,
	mtl_system_items_b msi,
    	(SELECT /*+ use_hash(gsl,itc) parallel(gsl) parallel(itc) */
		gsl.amount_base amount_base,
		itc.whse_code whse_code,
		itc. item_id item_id,
		itc.lot_id lot_id,
		itc.location location,
		itc.doc_id doc_id,
		itc.line_id line_id
	FROM
		gl_subr_led gsl,
		ic_tran_cmp itc
	WHERE
		gsl.line_id = itc.line_id and
		gsl.doc_id = itc.doc_id and
		gsl.doc_type = 'PICY' and
		gsl.acct_ttl_type = 1500 and
		gsl.creation_date >= s_global_start_date and
		itc.doc_type = gsl.doc_type and
		itc.gl_posted_ind = 1 and
		itc.trans_qty <> 0
	) gl_join
    WHERE
    	gl_join.item_id = ica.item_id and
    	gl_join.whse_code = ica.whse_code and
    	gl_join.lot_id = ica.lot_id and
    	gl_join.location = ica.location and
    	gl_join.doc_id = ica.cycle_id and
    	ica.cycle_id = ich.cycle_id and
    	ica.cycle_id = icd.cycle_id and
    	ica.whse_code = icd.whse_code and
    	ica.item_id = icd.item_id and
    	ica.lot_id = icd.lot_id and
    	ica.location = icd.location and
    	ica.count_no = icd.count_no and
    	ica.item_id = iwi.item_id and
    	ica.whse_code = iwi.whse_code and
    	ica.whse_code = iwm.whse_code and
    	ica.item_id = icmb.item_id and
    	irm.whse_code(+) = iwi.whse_code and
    	irm.abc_code(+) = iwi.whse_abccode and
	ich.last_update_date >= s_global_start_date and
	ich.delete_mark = 1 and
    	msi.segment1 = icmb.item_no and
	msi.organization_id = iwm.mtl_organization_id;


        BIS_COLLECTION_UTILITIES.PUT_LINE('Extracting Pre R12 Adjustments Initial Load End Time - ' ||
                                       TO_CHAR(SYSDATE, 'hh24:mi:ss'));


EXCEPTION

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                         l_stmt_id));

    RAISE EXTRACT_ADJ_INIT_ERROR;

END extract_adjustments_init;


/* extract_exact_matches_init

    Extracts all exact match entries where the approval date is between the GSD and
    the sysdate inserted in the log. Item Count date is checked for > '1-Jan-1970'
    to eliminate all cycle count info for items for which no count qty was entered in
    the cycle count form and the cycle count posted.

    R12 Changes
    ----------
    The upper bounds will be removed.

    History:
    Date        Author              Action
    07/04/04    Vedhanarayanan G    Defined procedure.
    07/04/05    Vishal Gupta        Refer R12 Changes above.
*/

PROCEDURE extract_exact_matches_init
IS

    l_proc_name VARCHAR2 (40);
    l_stmt_id NUMBER;
    l_sysdate DATE;

BEGIN

    l_stmt_id  := 0;
    l_proc_name  := 'extract_exact_matches_init';

    l_stmt_id := 10;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Extracting Exact Matches Inital Load from - ' ||
    				       TO_CHAR(s_global_start_date,'mm-dd-yyyy hh24:mi:ss'));
    BIS_COLLECTION_UTILITIES.PUT_LINE('Extracting Exact Matches Initail Load Start Time - ' ||
                                       TO_CHAR(SYSDATE, 'hh24:mi:ss'));

    l_stmt_id := 20;

    INSERT /*+ append parallel(OPI_DBI_INV_CCA_STG) */
    INTO opi_dbi_inv_cca_stg (
        organization_id,
        inventory_item_id,
        cycle_count_header_id,
        abc_class_id,
        subinventory_code,
        cycle_count_entry_id,
        source,
        approval_date,
        uom_code,
        system_inventory_qty,
        positive_adjustment_qty,
        negative_adjustment_qty,
        item_unit_cost,
        item_adj_unit_cost,
        hit_miss_pos,
        hit_miss_neg,
        exact_match)
    SELECT /*+ full(ich) use_hash(ica, ich, irm, iwi, icd, icmb, iwm, msi)
           parallel(ica) parallel(ich) parallel(irm) parallel(iwi) parallel(icd)
           parallel(icmb) parallel(iwm) parallel(msi) */
    	iwm.mtl_organization_id,
	msi.inventory_item_id,
	-1,
	nvl(iwi.whse_abccode,to_char(-1)),
	to_char(-1),
	ica.cycle_id||'-'||ica.seq_no,
	C_PRER12_SOURCE,
	trunc(ich.last_update_date) approval_date,
	msi.primary_uom_code,
	ica.frozen_qty1,
	0,
	0,
	opi_dbi_inv_cca_opm_pkg.get_unit_cost(ica.item_id,ica.whse_code,iwm.orgn_code,
	                       trunc(icd.creation_date)),
	0,
	NULL,
	NULL,
	1
    FROM
    	ic_cycl_adt ica,
	ic_cycl_hdr ich,
	ic_rank_mst irm,
	ic_whse_inv iwi,
	ic_whse_mst iwm,
	ic_cycl_dtl icd,
	ic_item_mst_b icmb,
	mtl_system_items_b msi
    WHERE
	ica.cycle_id = ich.cycle_id and
	ica.cycle_id = icd.cycle_id and
	ica.item_id = icd.item_id and
	ica.whse_code = icd.whse_code and
	ica.location = icd.location and
	ica.count_no = icd.count_no and
	ica.lot_id = icd.lot_id and
	ica.item_id = iwi.item_id and
	ica.whse_code = iwi.whse_code and
	ica.whse_code = iwm.whse_code and
	ica.item_id = icmb.item_id and
	ica.var_qty1 = 0 and
	ica.item_count_dt > g_CY_ZERO_DATE and
	ich.last_update_date >= s_global_start_date and
	irm.whse_code(+) = iwi.whse_code and
	irm.abc_code(+) = iwi.whse_abccode and
	ich.delete_mark = 1 and
	msi.segment1 = icmb.item_no and
	msi.organization_id = iwm.mtl_organization_id;

    BIS_COLLECTION_UTILITIES.PUT_LINE('Extracted Exact Matches Initail Load End Time - ' ||
                                       TO_CHAR(SYSDATE, 'hh24:mi:ss'));


EXCEPTION

    WHEN OTHERS THEN

        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,
                                                         l_stmt_id));

    RAISE EXTRACT_MATCHES_INIT_ERROR;

END extract_exact_matches_init;

/****************************************************
* Public Functions                                  *
****************************************************/
/* get_unit_cost
 *
 * History:
 * Date        Author              Action
 * 03/06/04    Vedhanarayanan G    Defined procedure.
 *
 */
FUNCTION get_unit_cost(p_item_id IN NUMBER,
                   p_whse_code IN VARCHAR2,
                   p_orgn_code IN VARCHAR2,
                   p_creation_date IN DATE)
    RETURN NUMBER
    PARALLEL_ENABLE
IS
BEGIN
    return
    gmf_cmcommon.unit_cost(p_item_id,p_whse_code,p_orgn_code,p_creation_date);
END get_unit_cost;

END opi_dbi_inv_cca_opm_pkg;

/
