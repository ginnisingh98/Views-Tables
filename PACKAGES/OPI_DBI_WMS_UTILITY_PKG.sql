--------------------------------------------------------
--  DDL for Package OPI_DBI_WMS_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_WMS_UTILITY_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDEWUTILS.pls 120.0 2005/05/24 17:56:29 appldev noship $ */

/**************************************************
 * Global variables
 **************************************************/

g_missing_uom boolean := false;

/****************************************
 * Package Level Constants
 ****************************************/

--Name of the package
C_PKG_NAME CONSTANT VARCHAR2 (40) := 'OPI_DBI_WMS_UTILITY_PKG';

-- Return codes for termination
C_ERROR CONSTANT NUMBER := -1;   -- concurrent manager error code
C_WARNING CONSTANT NUMBER := 1;  -- concurrent manager warning code
C_SUCCESS CONSTANT NUMBER := 0;  -- concurrent manager success code

-- Item level aggregation level flag value
C_ITEM_AGGR_LEVEL CONSTANT NUMBER := 0;

-- Error messages will be 300 characters (arbitrary choice)
C_ERRBUF_SIZE CONSTANT NUMBER := 300;

-- Column Spacing (5 spaces)
C_COL_SPACING CONSTANT NUMBER := 5;

-- Blank line for printing
C_BLANK_LINE CONSTANT VARCHAR2(1) := ' ';

-- Number of rows to report before deciding to print SQL.
C_NUM_ROWS_TO_REPORT NUMBER := 50;

-- Missing setup codes for the weight/volume measures
C_NOTHING_MISSING CONSTANT NUMBER := 0;
C_WT_MISSING CONSTANT NUMBER := 1;
C_VOL_MISSING CONSTANT NUMBER := 2;
C_WT_VOL_MISSING CONSTANT NUMBER := 3;

-- Various column widths
C_ORG_COL_WIDTH CONSTANT NUMBER := 45;
C_SUB_COL_WIDTH CONSTANT NUMBER := 15;
C_LOCATOR_COL_WIDTH CONSTANT NUMBER := 20;
C_ITEM_COL_WIDTH CONSTANT NUMBER := 35;
C_VOL_MISSING_COL_WIDTH CONSTANT NUMBER := 15;
C_WT_MISSING_COL_WIDTH CONSTANT NUMBER := 15;
C_VOL_UOM_COL_WIDTH CONSTANT NUMBER := 30;
C_WT_UOM_COL_WIDTH CONSTANT NUMBER := 30;

-- Asset subinventories are marked as 1.
C_ASSET_SUBINVENTORY CONSTANT NUMBER := 1;

-- Identifier for WDTH based CU1 date.
C_WDTH_CU1_DATE_TYPE CONSTANT VARCHAR2 (20) := 'WDTH_CU1_DATE';

-- Identifier for WMS Pick to ship start_date.
C_WMS_PTS_DATE_TYPE CONSTANT VARCHAR2 (20) := 'WMS_PTS_GSD';


/**************************************************
* Error messages
**************************************************/
C_ITEM_LOC_CONV_RATE_ERR CONSTANT VARCHAR2 (200) := 'The detail listing of item/locator conversion rates errors has failed';

/**************************************************
* Package Level User Defined Exceptions for functions
**************************************************/

-- Exception to raise item level conversion rates details program fails.
ITEM_CONV_RATES_DET_ERR EXCEPTION;
PRAGMA EXCEPTION_INIT (ITEM_CONV_RATES_DET_ERR, -20001);
ITEM_CONV_RATES_DET_ERR_MESG CONSTANT VARCHAR2(200) := 'An error occurred in listing out the item level conversion rates errors.';

-- Exception to raise item level conversion rates details program fails.
LOC_CONV_RATES_DET_ERR EXCEPTION;
PRAGMA EXCEPTION_INIT (LOC_CONV_RATES_DET_ERR, -20002);
LOC_CONV_RATES_DET_ERR_MESG CONSTANT VARCHAR2(200) := 'An error occurred in listing out the locator level conversion rates errors.';


/**************************************************
* Public procedures
**************************************************/

/*  report_item_setup_missing

    Reports the items in WMS organizations which are missing
    weight and/or volume setup.

    Parameters:
        errbuf - error message on unsuccessful termination
        retcode - 0 on success, 1 on warning, -1 on error

    History:
    Date        Author              Action
    12/20/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE report_item_setup_missing (errbuf OUT NOCOPY VARCHAR2,
                                     retcode OUT NOCOPY NUMBER);


/*  report_locator_setup_missing

    Reports the locators in WMS organizations which are missing
    weight and/or volume setup.

    Parameters:
        errbuf - error message on unsuccessful termination
        retcode - 0 on success, 1 on warning, -1 on error

    History:
    Date        Author              Action
    12/20/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE report_locator_setup_missing (errbuf OUT NOCOPY VARCHAR2,
                                        retcode OUT NOCOPY NUMBER);



/*  report_item_loc_conv_rate_err

    Report the item level and locator level information for missing
    conversion rates found by the ETLs for the Warehouse Storage Utilized
    and Current Capacity Utilization reports.

    This function is meant to be publicly accessed by a standalone
    concurrent program that the user can optionally run to debug
    their item/locator setups.

    History:
    Date        Author              Action
    01/10/05    Dinkar Gupta        Wrote Function.

*/
PROCEDURE report_item_loc_conv_rate_err (errbuf OUT NOCOPY VARCHAR2,
                                         retcode OUT NOCOPY NUMBER);

/*  set_wdth_cu1_date

    Get the CU1 date based on the data in the WMS_DISPATCHED_TASKS_HISTORY
    table. The CU1 date is the first one with transaction_temp_id not set
    as null.

    If no such date is found, then set the sysdate to be the CU1 date.

    In general since this API can be called simultaneously by multiple
    ETLs, it will merge the CU1 date into the OPI_DBI_CONC_PROG_RUN_LOG
    with type = 'WDTH_CU1_DATE'.

    Parameters:
    p_overwrite - if true, then function always picks the date from WDTH.
                  if false, then does nothing if a record already exists
                  in the OPI_DBI_CONC_PROG_RUN_LOG.

    History:
    Date        Author              Action
    02/17/05    Dinkar Gupta        Wrote Function.

*/
PROCEDURE set_wdth_cu1_date (p_overwrite BOOLEAN);


 /*  set_wms_pts_gsd

    Set the WMS pick to ship rack start date as the max of the
    WDTH CU1 date and GSD with a type of 'WMS_PTS_GSD'.

    As a side effect, populates/updates the WDTH CU1 date as needed.

    Parameters:
    p_overwrite - if true, then function force updates the WDTH CU1 date.
                  if false, then WDTH CU1 date is not modified (if
                  it already exists).

    History:
    Date        Author              Action
    02/18/05    Dinkar Gupta        Wrote Function.

*/
PROCEDURE set_wms_pts_gsd (p_overwrite BOOLEAN);


function get_uom_rate (p_inventory_item_id varchar2,
                       p_primary_uom_code varchar2,
                       p_txn_uom_code varchar2) return number parallel_enable;


END opi_dbi_wms_utility_pkg;

 

/
