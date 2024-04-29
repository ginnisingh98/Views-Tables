--------------------------------------------------------
--  DDL for Package OPI_DBI_REP_UOM_STD_CONV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_REP_UOM_STD_CONV_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDEREPUMS.pls 120.0 2005/05/24 18:22:35 appldev noship $ */

/****************************************
 * Package Level Constants
 ****************************************/

--Name of the package
C_PKG_NAME CONSTANT VARCHAR2 (40) := 'OPI_DBI_REP_UOM_STD_CONV_PKG';

-- Very old start date - for starting the initial load
C_START_RUN_DATE CONSTANT DATE := to_date ('01-01-1950', 'DD-MM-YYYY');

-- ETL identifier for the log table rows
C_ETL_TYPE CONSTANT VARCHAR2 (10) := 'REP_UOM';

-- Return codes for termination
C_ERROR CONSTANT NUMBER := -1;   -- concurrent manager error code
C_WARNING CONSTANT NUMBER := 1;  -- concurrent manager warning code
C_SUCCESS CONSTANT NUMBER := 0;  -- concurrent manager success code

-- Error messages will be 300 characters (arbitrary choice)
C_ERRBUF_SIZE CONSTANT NUMBER := 300;

-- Conversion rates precision - use 5 since that is what the core OLTP
-- Inventory Application supports.
C_CONV_PRECISION CONSTANT NUMBER := 5;

-- Measure lookup type for FND_LOOKUPS
C_MEASURE_LOOKUP_TYPE CONSTANT VARCHAR2(40) := 'OPI_DBI_UOM_MEASURE_TYPE';

-- Use inventory item Id of 0 for standard rates in the staging table.
C_STD_RATE_ITEM_ID CONSTANT NUMBER := 0;

-- Conversion rate types. 1 for Intra-class, 2 for Inter-class. Currently
-- only using intra-class.
C_INTRA_CONV_TYPE CONSTANT NUMBER := 1;
C_INTER_CONV_TYPE CONSTANT NUMBER := 2;

-- Base UOM flag values. 'Y' for base UOM, 'N' for non base UOM.
C_IS_BASE_UOM CONSTANT VARCHAR2(1) := 'Y';
C_NOT_BASE_UOM CONSTANT VARCHAR2(1) := 'N';

/****************************************
 * Success Messages
 ****************************************/

C_SUCCESS_MESG CONSTANT VARCHAR2 (300) := 'Successful Termination.';

/****************************************
 * Error Messages
 ****************************************/
C_INIT_LOAD_ERROR_MESG CONSTANT VARCHAR2 (300) :=
    'The Reporting UOMs standard conversion rate fact table update program''s initial load has terminated with errors. Please refer to the concurrent log file and/or concurrent request output file for details.';

C_INCR_LOAD_ERROR_MESG CONSTANT VARCHAR2 (300) :=
    'The Reporting UOMs standard conversion rate fact table update program''s incremental load has terminated with errors. Please refer to the concurrent log file and/or concurrent request output file for details.';

/**************************************************
* Package Level User Defined Exceptions for functions
**************************************************/

-- Exception to raise if initial/incremental load wrappers are unable to
-- find the global start date.
GLOBAL_START_DATE_NULL EXCEPTION;
PRAGMA EXCEPTION_INIT (GLOBAL_START_DATE_NULL, -20001);
GLOBAL_START_DATE_NULL_MESG CONSTANT VARCHAR2(200) := 'The global start date seems null. Please set up the global start date correctly.';

-- Exception to raise if the OPI schema information is not found
SCHEMA_INFO_NOT_FOUND EXCEPTION;
PRAGMA EXCEPTION_INIT (SCHEMA_INFO_NOT_FOUND, -20002);
SCHEMA_INFO_NOT_FOUND_MESG CONSTANT VARCHAR2(200) := 'OPI schema information not found.';

-- Exception to raise if global parameters such as global
-- start date and global currency code are not available
GLOBAL_SETUP_MISSING EXCEPTION;
PRAGMA EXCEPTION_INIT (GLOBAL_SETUP_MISSING, -20003);
GLOBAL_SETUP_MISSING_MESG CONSTANT VARCHAR2(200) := 'Unable to obtain setup information of global start date, OPI schema etc..';

-- Exception to raise if the setup of tables at the start fails
TABLE_INIT_SETUP_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (TABLE_INIT_SETUP_FAILED, -20004);
TABLE_INIT_SETUP_FAILED_MESG CONSTANT VARCHAR2(200) := 'The setup/cleanup of tables required at the start of the program was not successful.';

-- Exception to raise if the incremental run does not find the
-- last run record in the log table.
LAST_RUN_RECORD_MISSING EXCEPTION;
PRAGMA EXCEPTION_INIT (LAST_RUN_RECORD_MISSING, -20005);
LAST_RUN_RECORD_MISSING_MESG CONSTANT VARCHAR2(200) := 'The record of when this program was run last cannot be found. The incremental load cannot be run. Please run the initial load.';

-- Exception to raise if setting up the list of measures of interest failed.
MEASURE_LIST_SETUP_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (MEASURE_LIST_SETUP_FAILED, -20006);
MEASURE_LIST_SETUP_FAILED_MESG CONSTANT VARCHAR2(200) := 'Unable to set up the list of measures for which conversions are required.';

-- Exception to raise if computing all intra class conversion rates
-- fails.
INTRA_STD_CONV_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (INTRA_STD_CONV_FAILED, -20007);
INTRA_STD_CONV_FAILED_MESG CONSTANT VARCHAR2(200) := 'Unable to compute all intra-class standard conversion rates to the reporting units of measure.';

-- Exception to raise if computing all inter class conversion rates
-- fails.
INTER_STD_CONV_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (INTER_STD_CONV_FAILED, -20008);
INTER_STD_CONV_FAILED_MESG CONSTANT VARCHAR2(200) := 'Unable to compute all inter-class standard conversion rates to the reporting units of measure.';

-- Exception to raise if unable to insert conversion rates into the
-- fact table during the initial load.
INSERT_NEW_RATES_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (INSERT_NEW_RATES_FAILED, -20009);
INSERT_NEW_RATES_FAILED_MESG CONSTANT VARCHAR2(200) := 'Unable to insert new rates into the rates base fact.';

-- Exception to raise if unable to merge conversion rates into fact table
-- during the incremental load.
MERGE_STD_RATES_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (MERGE_STD_RATES_FAILED, -20010);
MERGE_STD_RATES_FAILED_MESG CONSTANT VARCHAR2(200) := 'Unable to update UOM conversion rates.';

-- Exception to raise if unable to update the log table.
LOG_UPDATE_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (LOG_UPDATE_FAILED, -20011);
LOG_UPDATE_FAILED_MESG CONSTANT VARCHAR2(200) := 'Unable to the log table with the current run information.';


/**************************************************
* Public procedures
**************************************************/


/* populate_rep_uom_std_conv_init

    Wrapper routine for the initial load of the standard conversion
    rates program.

    Parameters:
        errbuf - error message on unsuccessful termination
        retcode - 0 on success, 1 on warning, -1 on error

    History:
    Date        Author              Action
    12/01/04    Dinkar Gupta        Wrote Function.
*/
PROCEDURE populate_rep_uom_std_conv_init (errbuf OUT NOCOPY VARCHAR2,
                                          retcode OUT NOCOPY NUMBER);

/* populate_rep_uom_std_conv_incr

    Wrapper routine for the incremental load of the standard conversion
    rates program.

    Parameters:
        errbuf - error message on unsuccessful termination
        retcode - 0 on success, 1 on warning, -1 on error

    History:
    Date        Author              Action
    12/01/04    Dinkar Gupta        Wrote Function.
*/
PROCEDURE populate_rep_uom_std_conv_incr (errbuf OUT NOCOPY VARCHAR2,
                                          retcode OUT NOCOPY NUMBER);

END opi_dbi_rep_uom_std_conv_pkg;

 

/
