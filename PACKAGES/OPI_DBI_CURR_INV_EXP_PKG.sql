--------------------------------------------------------
--  DDL for Package OPI_DBI_CURR_INV_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_CURR_INV_EXP_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDECIEXPS.pls 120.1 2005/11/30 01:35:47 srayadur noship $ */

/****************************************
 * Package Level Constants
 ****************************************/

--Name of the package
C_PKG_NAME CONSTANT VARCHAR2 (40) := 'OPI_DBI_CURR_INV_EXP_PKG';

-- ETL identifier for the log table rows.
C_ETL_TYPE CONSTANT VARCHAR2 (20) := 'CURR_INV_EXP';

-- Return codes for termination
C_ERROR CONSTANT NUMBER := -1;   -- concurrent manager error code
C_WARNING CONSTANT NUMBER := 1;  -- concurrent manager warning code
C_SUCCESS CONSTANT NUMBER := 0;  -- concurrent manager success code

-- Error messages will be 300 characters (arbitrary choice)
C_ERRBUF_SIZE CONSTANT NUMBER := 300;

-- Primary cost method for standard costing organizations
C_STANDARD_COSTING_ORG CONSTANT NUMBER := 1;

-- Frozen cost type for standard costing orgs
C_FROZEN_COST_TYPE CONSTANT NUMBER := 1;

-- Primary cost method for standard costing organizations
C_EXPENSE_ITEM_FLAG CONSTANT VARCHAR2(1) := 'N';

-- Marker for expense subinventories
C_EXPENSE_SUBINVENTORY CONSTANT NUMBER := '2';

-- These EURO constants are here purely for completeness. This ETL
-- should not have anything to do with the EURO really since this
-- is a current runtime report.
-- EURO currency became official on 1st Jan 1999
C_EURO_START_DATE CONSTANT DATE := to_date ('01/01/1999', 'mm/dd/yyyy');

-- GL API returns -3 if EURO rate missing on 01-JAN-1999
C_EURO_MISSING_AT_START CONSTANT NUMBER := -3;


/****************************************
 * Success Messages
 ****************************************/

C_SUCCESS_MESG CONSTANT VARCHAR2 (300) := 'Successful Termination.';


/****************************************
 * Error Messages
 ****************************************/
C_CURR_INV_EXP_LOAD_ERROR_MESG CONSTANT VARCHAR2 (300) :=
    'The Current Inventory Expiration report''s load program has terminated with errors. Please refer to the concurrent log file and/or concurrent request output file for details.';

/**************************************************
* Package Level User Defined Exceptions for functions
**************************************************/

-- Exception to raise if the OPI schema information is not found
SCHEMA_INFO_NOT_FOUND EXCEPTION;
PRAGMA EXCEPTION_INIT (SCHEMA_INFO_NOT_FOUND, -20001);
SCHEMA_INFO_NOT_FOUND_MESG CONSTANT VARCHAR2(300) := 'OPI schema information not found.';

-- Exception to raise if a BIS common setup/wrapup type API fails
BIS_COMMON_API_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (BIS_COMMON_API_FAILED, -20002);
BIS_COMMON_API_FAILED_MESG CONSTANT VARCHAR2(300) := 'A BIS Common API has failed.';

-- Exception to raise if global parameters such as global
-- start date and global currency code are not available
GLOBAL_SETUP_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (GLOBAL_SETUP_FAILED, -20003);
GLOBAL_SETUP_FAILED_MESG CONSTANT VARCHAR2(300) := 'Unable to obtain setup information of global start date, OPI schema etc..';

-- Exception to raise if the wrapup routine encounters errors.
GLOBAL_WRAPUP_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (GLOBAL_WRAPUP_FAILED, -20004);
GLOBAL_WRAPUP_FAILED_MESG CONSTANT VARCHAR2(300) := 'Unable to wrap up program.';

-- Exception to raise if the wrapup routine encounters errors.
EXP_TABLE_CLEANUP_FAILED EXCEPTION;
PRAGMA EXCEPTION_INIT (EXP_TABLE_CLEANUP_FAILED, -20005);
EXP_TABLE_CLEANUP_FAILED_MESG CONSTANT VARCHAR2(300) := 'Unable to clean up the inventory expiration report tables.';

-- Exception to raise if initial/incremental load wrappers are unable to
-- find the DBI global currency code.
NO_GLOBAL_CURR_CODE EXCEPTION;
PRAGMA EXCEPTION_INIT (NO_GLOBAL_CURR_CODE, -20006);
NO_GLOBAL_CURR_CODE_MESG CONSTANT VARCHAR2(300) := 'The DBI global currency code is NULL. Please set up the global currency code correctly.';

-- Exception to raise if initial/incremental load wrappers are unable to
-- find the DBI global currency code.
NO_GLOBAL_RATE_TYPE EXCEPTION;
PRAGMA EXCEPTION_INIT (NO_GLOBAL_RATE_TYPE, -20007);
NO_GLOBAL_RATE_TYPE_MESG CONSTANT VARCHAR2(300) := 'The DBI global rate type is NULL. Please set up the global rate type correctly.';

-- Exception to raise if one of the secondary currency code and rate type
-- is null, but the other is not.
SEC_CURR_SETUP_INVALID EXCEPTION;
PRAGMA EXCEPTION_INIT (SEC_CURR_SETUP_INVALID, -20008);
SEC_CURR_SETUP_INVALID_MESG CONSTANT VARCHAR2(300) := 'The secondary currency code cannot be null when the rate type is defined or vice versa.';

-- Exception to raise if one of the secondary currency code and rate type
-- is null, but the other is not.
PRIMARY_CURR_SETUP_BAD EXCEPTION;
PRAGMA EXCEPTION_INIT (PRIMARY_CURR_SETUP_BAD, -20009);
PRIMARY_CURR_SETUP_BAD_MESG CONSTANT VARCHAR2(300) := 'The primary currency setup has errors as per the BIS API.';

-- Exception to raise if an error occurred while checking for missing
-- conversion rates.
CONV_RATES_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (CONV_RATES_ERROR, -20010);
CONV_RATES_ERROR_MESG CONSTANT VARCHAR2(300) := 'An error occurred while checking for missing rates.';

-- Exception to raise if missing currency conversion rates are found.
MISSING_CONV_RATES EXCEPTION;
PRAGMA EXCEPTION_INIT (MISSING_CONV_RATES, -20011);
MISSING_CONV_RATES_MESG CONSTANT VARCHAR2(300) := 'There are missing currency conversion rates. Check the program output and log files for missing rate details. Please fix the rates and run the program again.';

-- Exception to raise if missing currency conversion rates are found.
EXP_INV_EXTRACT_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (EXP_INV_EXTRACT_ERROR, -20012);
EXP_INV_EXTRACT_ERROR_MESG CONSTANT VARCHAR2(300) := 'An error occurred during the extraction of expired inventory value from the OLTP system.';

/**************************************************
* Public procedures
**************************************************/

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
                            retcode OUT NOCOPY NUMBER);

END OPI_DBI_CURR_INV_EXP_PKG;

 

/
