--------------------------------------------------------
--  DDL for Package OPI_DBI_WMS_CAPACITY_UTZ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_WMS_CAPACITY_UTZ_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDEWCUTZS.pls 120.0 2005/05/24 17:17:30 appldev noship $ */

/****************************************
 * Package Level Constants
 ****************************************/

--Name of the package
C_PKG_NAME CONSTANT VARCHAR2 (40) := 'OPI_DBI_WMS_CAPACITY_UTZ_PKG';

-- ETL identifier for the log table rows. No intended use yet.
C_ETL_TYPE CONSTANT VARCHAR2 (10) := 'CAP_UTZ';

-- Return codes for termination
C_ERROR CONSTANT NUMBER := -1;   -- concurrent manager error code
C_WARNING CONSTANT NUMBER := 1;  -- concurrent manager warning code
C_SUCCESS CONSTANT NUMBER := 0;  -- concurrent manager success code

-- Error messages will be 300 characters (arbitrary choice)
C_ERRBUF_SIZE CONSTANT NUMBER := 300;

-- Error code to store missing conversion to the reporting UOM.
C_MISSING_REP_CONV CONSTANT NUMBER := -1;

-- Measure lookup type for FND_LOOKUPS
C_MEASURE_LOOKUP_TYPE CONSTANT VARCHAR2(40) := 'OPI_DBI_UOM_MEASURE_TYPE';

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

-- From UOM code is not defined
C_NO_FROM_UOM_CODE CONSTANT NUMBER := -2;


/****************************************
 * Success Messages
 ****************************************/

C_SUCCESS_MESG CONSTANT VARCHAR2 (300) := 'Successful Termination.';

/****************************************
 * Warning Messages
 ****************************************/
C_CURR_UTZ_LOAD_WARN_MESG CONSTANT VARCHAR2 (300) :=
    'The Current Capacity Utilization report program has terminated with warnings. Please refer to the concurrent log file and/or concurrent request output file for details.';


/****************************************
 * Error Messages
 ****************************************/
C_CURR_UTZ_LOAD_ERROR_MESG CONSTANT VARCHAR2 (300) :=
    'The Current Capacity Utilization report program has terminated with errors. Please refer to the concurrent log file and/or concurrent request output file for details.';

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

-- Exception to raise if unable to extract locator capacity information
LOCATOR_CAP_CALC_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (LOCATOR_CAP_CALC_FAILED, -20004);
LOCATOR_CAP_CALC_MESG CONSTANT VARCHAR2(200) := 'Unable to extract weight/volume capacities of the warehouse (extraction at the locator level failed).';

-- Exception to raise if unable to extract locator capacity information
NO_REP_UOMS_DEFINED EXCEPTION;
PRAGMA EXCEPTION_INIT (NO_REP_UOMS_DEFINED, -20005);
NO_REP_UOMS_DEFINED_MESG CONSTANT VARCHAR2(200) := 'No reporting UOMs have been defined for the weight and volume measures. The Current Capacity Report can only collect data for a measure once a reporting UOM has been defined.';

-- Exception to raise if there are errors and we need to abort prematurely.
PREMATURE_ABORT EXCEPTION;
PRAGMA EXCEPTION_INIT (PREMATURE_ABORT, -20006);
PREMATURE_ABORT_MESG CONSTANT VARCHAR2(200) := 'The Current Capacity Utilization extraction program has encountered errors and is terminating.';

-- Exception to raise if summarizing capacities failed
SUMMARIZE_CAP_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (SUMMARIZE_CAP_FAILED, -20006);
SUMMARIZE_CAP_FAILED_MESG CONSTANT VARCHAR2(200) := 'An error occurred when summarizing locator capacities to the subinventory and organization level.';

-- Exception to raise if unable to extract item storage data
ITEM_STOR_CALC_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (ITEM_STOR_CALC_FAILED, -20007);
ITEM_STOR_CALC_FAILED_MESG CONSTANT VARCHAR2(200) := 'Unable to extract item storage in the various locators.';

-- Exception to raise if unable to check for locator capacity conversion
-- rates errors.
LOCATOR_ERR_CHECK_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (LOCATOR_ERR_CHECK_FAILED, -20008);
LOCATOR_ERR_CHECK_FAILED_MESG CONSTANT VARCHAR2(200) := 'Unable to identify locator capacity conversion rate errors.';

-- Exception to raise if unable to check for item storage conversion
-- rates errors.
ITEM_ERR_CHECK_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (ITEM_ERR_CHECK_FAILED, -20009);
ITEM_ERR_CHECK_FAILED_MESG CONSTANT VARCHAR2(200) := 'Unable to identify item weight/volume storage conversion rate errors.';

/**************************************************
* Public procedures
**************************************************/

/*  refresh_current_utilization

    Wrapper routine to refresh
    1. The weight/volume capacity of warehouses and their subinventories.
    2. The weight and volume of items stored currently in the
       warehouse's locators.

    Locator capacities:
    A locator may have a defined max weight and/or max volume capacity.
    Locators with neither values defined are ignored. Locators with
    only one of the quantities defined contribute to the corresponding
    measure for the subinventory to which they belong.

    Item Weights/volume:
    The item weight will be taken into account only if the locator
    it is present in has a defined weight capacity. Similar condition
    for the item volume. Item quantities present in locators with
    neither weight nor volume capacity defined are ignored.



    Errors are reported for all:
    1. Defined locator weight/volume capacities that cannot be
       converted to the weight/volume reporting UOM values.
    2. Defined item weights/volumes that cannot be converted
       into the weight/volume reporting UOM values.

    No data is collected for the report in case of errors, and the fact
    tables are left truncated.

    Warnings are generated for:
    1. All locators whose unit weight/volume capacities are undefined.
    2. All items whose unit weight/volume are undefined.

    Parameters:
        errbuf - error message on unsuccessful termination
        retcode - 0 on success, 1 on warning, -1 on error

    History:
    Date        Author              Action
    12/08/04    Dinkar Gupta        Wrote Function.
*/
PROCEDURE refresh_current_utilization (errbuf OUT NOCOPY VARCHAR2,
                                       retcode OUT NOCOPY NUMBER);



END opi_dbi_wms_capacity_utz_pkg;

 

/
