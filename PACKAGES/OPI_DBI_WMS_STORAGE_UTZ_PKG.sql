--------------------------------------------------------
--  DDL for Package OPI_DBI_WMS_STORAGE_UTZ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_WMS_STORAGE_UTZ_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDEWSTORS.pls 120.0 2005/05/24 19:14:10 appldev noship $ */

--Name of the package
C_PKG_NAME CONSTANT VARCHAR2 (40) := 'OPI_DBI_WMS_STORAGE_UTZ_PKG';

-- Very old start date - for starting the initial load
C_START_RUN_DATE CONSTANT DATE := to_date ('01-01-1950', 'DD-MM-YYYY');

-- ETL identifier for the log table rows. No intended use yet.
C_ETL_TYPE CONSTANT VARCHAR2 (10) := 'STR_UTZ';

-- Return codes for termination
C_ERROR CONSTANT NUMBER := -1;   -- concurrent manager error code
C_WARNING CONSTANT NUMBER := 1;  -- concurrent manager warning code
C_SUCCESS CONSTANT NUMBER := 0;  -- concurrent manager success code

-- Identification of process vs. discrete organizations in the
-- inventory fact table
C_DISCRETE_ORGS CONSTANT NUMBER := 1;
C_PROCESS_ORGS CONSTANT NUMBER := 2;

-- Error messages will be 300 characters (arbitrary choice)
C_ERRBUF_SIZE CONSTANT NUMBER := 300;

-- Weight measure code in the measure master table, OPI_DBI_REP_UOMS
C_WT_MEASURE_CODE CONSTANT VARCHAR2(40) := 'WT';

-- Vol measure code in the measure master table, OPI_DBI_REP_UOMS
C_VOL_MEASURE_CODE CONSTANT VARCHAR2(40) := 'VOL';

-- Dummy UOM code to use when the UOM code set up is NULL. Needed during
-- join conditions of outer joins.
C_DUMMY_UOM_CODE CONSTANT VARCHAR2 (3) := '#?$';

-- Error codes for conversion rates:
-- Conversion is impossible because of missing setup
C_CONV_NOT_SETUP CONSTANT NUMBER := -1;

/****************************************
 * Success Messages
 ****************************************/

C_SUCCESS_MESG CONSTANT VARCHAR2 (300) := 'Successful Termination.';


/****************************************
 * Error Messages
 ****************************************/
C_STOR_INIT_LOAD_ERROR_MESG CONSTANT VARCHAR2 (300) :=
    'The Warehouse Storage Utilization report program initial load has terminated with errors. Please refer to the concurrent log file and/or concurrent request output file for details.';

C_STOR_INCR_LOAD_ERROR_MESG CONSTANT VARCHAR2 (300) :=
    'The Warehouse Storage Utilization report program incremental load has terminated with errors. Please refer to the concurrent log file and/or concurrent request output file for details.';

/**************************************************
* Package Level User Defined Exceptions for functions
**************************************************/

-- Exception to raise if the OPI schema information is not found
SCHEMA_INFO_NOT_FOUND EXCEPTION;
PRAGMA EXCEPTION_INIT (SCHEMA_INFO_NOT_FOUND, -20001);
SCHEMA_INFO_NOT_FOUND_MESG CONSTANT VARCHAR2(200) := 'OPI schema information not found.';

-- Exception to raise if global parameters such as global
-- start date and global currency code are not available
GLOBAL_SETUP_MISSING EXCEPTION;
PRAGMA EXCEPTION_INIT (GLOBAL_SETUP_MISSING, -20002);
GLOBAL_SETUP_MISSING_MESG CONSTANT VARCHAR2(200) := 'Unable to obtain setup information of global start date, OPI schema etc..';

-- Exception to raise if the setup of tables at the start fails
TABLE_SETUP_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (TABLE_SETUP_FAILED, -20003);
TABLE_SETUP_FAILED_MESG CONSTANT VARCHAR2(200) := 'The setup/cleanup of tables required at the start of the program was not successful.';

-- Exception to raise if the incremental run does not find the
-- last run record in the log table.
LAST_RUN_RECORD_MISSING EXCEPTION;
PRAGMA EXCEPTION_INIT (LAST_RUN_RECORD_MISSING, -20004);
LAST_RUN_RECORD_MISSING_MESG CONSTANT VARCHAR2(200) := 'The record of when this program was run last cannot be found. The incremental load cannot be run. Please run the initial load.';

-- Exception to raise if unable to update the log table.
LOG_UPDATE_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (LOG_UPDATE_FAILED, -20005);
LOG_UPDATE_FAILED_MESG CONSTANT VARCHAR2(200) := 'Unable to the log table with the current run information.';

-- Exception to raise if unable to extract locator capacity information
NO_REP_UOMS_DEFINED EXCEPTION;
PRAGMA EXCEPTION_INIT (NO_REP_UOMS_DEFINED, -20006);
NO_REP_UOMS_DEFINED_MESG CONSTANT VARCHAR2(200) := 'No reporting UOMs have been defined for the weight and volume measures. The Current Capacity Report can only collect data for a measure once a reporting UOM has been defined.';

-- Exception to raise if unable to extract item storage data
CONV_RATE_CALC_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (CONV_RATE_CALC_FAILED, -20007);
CONV_RATE_CALC_FAILED_MESG CONSTANT VARCHAR2(200) := 'Unable to extract conversion rates for the needed item/org combinations.';


-- Exception to raise if unable to extract item storage data
MISSING_RATES_FOUND EXCEPTION;
PRAGMA EXCEPTION_INIT (MISSING_RATES_FOUND, -20008);
MISSING_RATES_FOUND_MESG CONSTANT VARCHAR2(200) := 'There are missing conversion rates to the reporting UOMs. Please check the concurrent output file for details of missing rates that are causing the program to error out.';

-- Exception to raise if unable to extract item storage data
MERGE_RATES_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (MERGE_RATES_FAILED, -20009);
MERGE_RATES_FAILED_MESG CONSTANT VARCHAR2(200) := 'Failed to merge new conversion rates into the conversion rates fact table.';

-- Exception to raise if find missing rates
CONV_RATES_CHECK_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (CONV_RATES_CHECK_FAILED, -20010);
CONV_RATES_CHECK_FAILED_MESG CONSTANT VARCHAR2(200) := 'Unable to perform check for missing conversion rates.';

-- Exception to raise if find missing rates
TRX_STG_TO_FACT_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (TRX_STG_TO_FACT_FAILED, -20011);
TRX_STG_TO_FACT_FAILED_MESG CONSTANT VARCHAR2(200) := 'Unable to transfer from fact table to staging given conversion rate errors.';

/**************************************************
* Public procedures
**************************************************/

/*  wt_vol_init_load

    Set up conversion rates in the reporting UOM conversion rates facts
    for the weight and volume measures.

    The conversion rates are set up for all items in the inventory
    value fact, OPI_DBI_INV_VALUE_F, for WMS enabled, discrete
    manufacturing organizations.

    Currently only interested in conversion rates for weights/volumes.

    History:
    Date        Author              Action
    12/13/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE wt_vol_init_load (errbuf OUT NOCOPY VARCHAR2,
                            retcode OUT NOCOPY NUMBER);

/*  wt_vol_incr_load

    Set up conversion rates in the reporting UOM conversion rates facts
    for the weight and volume measures.

    The conversion rates are set up for all items in the inventory
    value fact, OPI_DBI_INV_VALUE_F, for WMS enabled, discrete
    manufacturing organizations.

    Currently only interested in conversion rates for weights/volumes.

    During the incremental load, consider only those items/orgs that
    have been added during incremental runs of the inventory program
    after the previous run of the WMS conversion rates program.

    History:
    Date        Author              Action
    12/13/04    Dinkar Gupta        Wrote Function.

*/
PROCEDURE wt_vol_incr_load (errbuf OUT NOCOPY VARCHAR2,
                            retcode OUT NOCOPY NUMBER);


END opi_dbi_wms_storage_utz_pkg;

 

/
