--------------------------------------------------------
--  DDL for Package OPI_DBI_INV_CCA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_INV_CCA_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDEICCAS.pls 120.1 2005/08/02 04:55:53 visgupta noship $ */

/**************************************************
* Package Level Constants
**************************************************/

-- All OPI data is marked as source 1, OPM data is marked as source 2
C_OPI_SOURCE CONSTANT NUMBER := 1;
C_OPM_SOURCE CONSTANT NUMBER := 2;
C_PRER12_SOURCE CONSTANT NUMBER := 3;

-- All completed cycle count entries have a status of 5
C_COMPLETED_CCA_ENTRY CONSTANT NUMBER := 5;

-- The MTA inventory accounting line type is 1
C_INVENTORY_ACCOUNT CONSTANT NUMBER := 1;

-- The MMT transaction type id for cycle count adjustments is 4
C_MMT_CYCLE_COUNT_ADJ CONSTANT NUMBER := 4;

-- EURO currency became official on 1st Jan 1999
C_EURO_START_DATE CONSTANT DATE := to_date ('01/01/1999', 'mm/dd/yyyy');

-- GL API returns -3 if EURO rate missing on 01-JAN-1999
C_EURO_MISSING_AT_START CONSTANT NUMBER := -3;

-- This is the OPI_DBI_INV_CCA_PKG
C_PKG_NAME CONSTANT VARCHAR2 (50) := 'opi_dbi_inv_cca_pkg';

-- Rows for this ETL will be created with TYPE='CCA' in the log table
C_CCA_MARKER CONSTANT VARCHAR2(3) := 'CCA';

-- Rows in log table with 'MMT' type
C_MMT_MARKER CONSTANT VARCHAR2(3) := 'MMT';

-- Rows in log table with 'MIF' type
C_MIF_MARKER CONSTANT VARCHAR2(3) := 'MIF';

-- MMT has 5 decimal points of precision
C_MMT_PRECISION CONSTANT NUMBER := 5;

-- Return codes for termination
C_ERROR CONSTANT NUMBER := -1;   -- concurrent manager error code
C_WARNING CONSTANT NUMBER := 1;  -- concurrent manager warning code
C_SUCCESS CONSTANT NUMBER := 0;  -- concurrent manager success code

-- Error messages will be 300 characters (arbitrary choice)
C_ERRBUF_SIZE CONSTANT NUMBER := 300;

-- Hit are 1, misses are 0
C_MISS CONSTANT NUMBER := 0;
C_HIT CONSTANT NUMBER := 1;

-- Exact matches are 1, non matches are 0
C_NO_MATCH CONSTANT NUMBER := 0;
C_EXACT_MATCH CONSTANT NUMBER := 1;

-- Expense subinventories are marked as 2 in the asset_inventory field
C_EXPENSE_SUBINVENTORY CONSTANT NUMBER := 2;

-- -1 is an invalid transaction_id to mark in the log
C_INVALID_TRANSACTION_ID CONSTANT NUMBER := -1;

-- marker for secondary conv. rate if the primary and secondary curr codes
-- and rate types are identical. Can't be -1, -2, -3 since the FII APIs
-- return those values.
C_PRI_SEC_CURR_SAME_MARKER CONSTANT NUMBER := -9999;


-- For Bounds
C_ETL_TYPE	VARCHAR2(12)	:= 'CYCLE_COUNT';
C_LOAD_INIT	VARCHAR2(4)	:= 'INIT';
C_LOAD_INCR	VARCHAR2(4)	:= 'INCR';
C_LOG_MMT_DRV_TBL	VARCHAR2(3)	:='MMT';
C_LOG_GTV_DRV_TBL	VARCHAR2(3)	:='GTV';


/**************************************************
* Package Level User Defined Exceptions for functions
**************************************************/

-- Exception to raise if global parameters such as global
-- start date and global currency code are not available
GLOBAL_SETUP_MISSING EXCEPTION;
PRAGMA EXCEPTION_INIT (GLOBAL_SETUP_MISSING, -20001);
GLOBAL_SETUP_MISSING_MESG CONSTANT VARCHAR2(200) := 'Unable to verify setup of global start date and global currency code.';


-- Exception to raise if the OPI schema information is not found
SCHEMA_INFO_NOT_FOUND EXCEPTION;
PRAGMA EXCEPTION_INIT (SCHEMA_INFO_NOT_FOUND, -20002);
SCHEMA_INFO_NOT_FOUND_MESG CONSTANT VARCHAR2(200) := 'OPI schema information not found.';


-- Exception to raise if the bounds in the log table are incorrect.
INIT_BOUNDS_MISSING EXCEPTION;
PRAGMA EXCEPTION_INIT (INIT_BOUNDS_MISSING, -20003);
INIT_BOUNDS_MISSING_MESG CONSTANT VARCHAR2(200) := 'Bounds information missing for initial load in the log table. Please run the initial load collection program using the request set.';

-- Exception to raise if initial/incremental load wrappers are unable to
-- find the global start date.
GLOBAL_START_DATE_NULL EXCEPTION;
PRAGMA EXCEPTION_INIT (GLOBAL_START_DATE_NULL, -20004);
GLOBAL_START_DATE_NULL_MESG CONSTANT VARCHAR2(200) := 'The global start date seems null. Please set up the global start date correctly.';

-- Exception to raise if initial/incremental load wrappers are unable to
-- find the DBI global currency code.
NO_GLOBAL_CURR_CODE EXCEPTION;
PRAGMA EXCEPTION_INIT (NO_GLOBAL_CURR_CODE, -20005);
NO_GLOBAL_CURR_CODE_MESG CONSTANT VARCHAR2(200) := 'The DBI global currency code is NULL. Please set up the global currency code correctly.';

-- Exception to raise if initial/incremental load wrappers are unable to
-- find the DBI global currency code.
NO_GLOBAL_RATE_TYPE EXCEPTION;
PRAGMA EXCEPTION_INIT (NO_GLOBAL_RATE_TYPE, -20006);
NO_GLOBAL_RATE_TYPE_MESG CONSTANT VARCHAR2(200) := 'The DBI global rate type is NULL. Please set up the global rate type correctly.';


-- Exception to raise if initial/incremental load wrappers are unable to
-- find the DBI global currency code.
MISSING_CONV_RATES EXCEPTION;
PRAGMA EXCEPTION_INIT (MISSING_CONV_RATES, -20007);
MISSING_CONV_RATES_MESG CONSTANT VARCHAR2(200) := 'There are missing currency conversion rates. Check the program output and log files for missing rate details. Please fix the rates and run the program again.';


-- Exception to raise if the bounds in the log table are incorrect for the
-- incremental load.
INCR_BOUNDS_MISSING EXCEPTION;
PRAGMA EXCEPTION_INIT (INCR_BOUNDS_MISSING, -20008);
INCR_BOUNDS_MISSING_MESG CONSTANT VARCHAR2(200) := 'Bounds information missing for incremental load in the log table. Please run the incremental load collection program using the request set.';

-- Exception to raise if one of the secondary currency code and rate type
-- is null, but the other is not.
SEC_CURR_SETUP_INVALID EXCEPTION;
PRAGMA EXCEPTION_INIT (SEC_CURR_SETUP_INVALID, -20009);
SEC_CURR_SETUP_INVALID_MESG CONSTANT VARCHAR2(200) := 'The secondary currency code cannot be null when the rate type is defined or vice versa.';


/**************************************************
* Package Level User Defined Exceptions for ETL stages
**************************************************/

-- Exception to raise if initial/incremental load wrappers are unable to
-- to complete their initialization steps.
INITIALIZATION_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (INITIALIZATION_ERROR, -21000);
INITIALIZATION_ERROR_MESG CONSTANT VARCHAR2(200) := 'An error occurred during the initialization steps (global parameter checking, table truncation, bounds checking). See concurrent log for details.';

-- Exception to raise if initial/incremental load wrappers are unable to
-- to complete their initialization steps.
CONV_RATES_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (CONV_RATES_ERROR, -21010);
CONV_RATES_ERROR_MESG CONSTANT VARCHAR2(200) := 'An error occurred during computation of conversion rates. Please fix these errors before re-running the program. See concurrent log for details.';

-- Exception to raise if initial/incremental load wrappers are unable to
-- set up runtime bounds
BOUNDS_SETUP_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (BOUNDS_SETUP_ERROR, -21020);
BOUNDS_SETUP_ERROR_MESG CONSTANT VARCHAR2(200) := 'An error occurred during computation of runtime bounds. See concurrent log for details.';


-- Exception to raise if initial/incremental load wrappers are unable to
-- extract adjustment entry data successfully.
ADJUSTMENT_EXTR_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (ADJUSTMENT_EXTR_ERROR, -21030);
ADJUSTMENT_EXTR_ERROR_MESG CONSTANT VARCHAR2(200) := 'An error occurred during extraction of adjusted cycle count entries. See concurrent log for details.';

-- Exception to raise if initial/incremental load wrappers are unable to
-- extract exact match entry data successfully.
EXACT_MATCH_EXTR_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (EXACT_MATCH_EXTR_ERROR, -21040);
EXACT_MATCH_EXTR_ERROR_MESG CONSTANT VARCHAR2(200) := 'An error occurred during extraction of exact match cycle count entries. See concurrent log for details.';

-- Exception to raise if initial/incremental load wrappers are unable to
-- update runtime bounds after successful extraction.
BOUNDS_UPDATE_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (BOUNDS_UPDATE_ERROR, -21050);
BOUNDS_UPDATE_ERROR_MESG CONSTANT VARCHAR2(200) := 'An error occurred while updating the runtime bounds after data extraction. See concurrent log for details.';
-- Exception to raise if initial/incremental load wrappers are unable to
-- merge the newly extracted data to the fact table
FACT_MERGE_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (FACT_MERGE_ERROR, -21060);
FACT_MERGE_ERROR_MESG CONSTANT VARCHAR2(200) := 'An error occurred while inserting the newly extracted data to the base fact table. See concurrent log for details.';

-- Exception to raise if the OPM function throws an exception
OPM_EXTRACTION_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (OPM_EXTRACTION_ERROR, -21070);
OPM_EXTRACTION_ERROR_MESG CONSTANT VARCHAR2(200) := 'An error occurred while extracting data for process manufacturing organizations. See concurrent log for details.';

-- Exception to raise if the extract_CCA_MMT function throws an exception
CCA_MMT_STG_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (CCA_MMT_STG_ERROR, -21070);
CCA_MMT_STG_ERROR_MESG CONSTANT VARCHAR2(200) := 'An error occurred while extracting data from MMT. See concurrent log for details.';

/* run_initial_load

    Wrapper routine for the initial load of the cycle count accuracy ETL.

    Parameters:
    retcode - 0 on successful completion, -1 on error and 1 for warning.
    errbuf - empty on successful completion, message on error or warning

    History:
    Date        Author              Action
    01/12/04    Dinkar Gupta        Defined specification.

*/
PROCEDURE run_initial_load (errbuf OUT NOCOPY VARCHAR2,
                            retcode OUT NOCOPY NUMBER);


/* run_incr_load

    Wrapper routine for the incremental load of the cycle count accuracy ETL.

    Parameters:
    retcode - 0 on successful completion, -1 on error and 1 for warning.
    errbuf - empty on successful completion, message on error or warning

    History:
    Date        Author              Action
    01/12/04    Dinkar Gupta        Defined specification.

*/
PROCEDURE run_incr_load (errbuf OUT NOCOPY  VARCHAR2,
                         retcode OUT NOCOPY NUMBER);



END opi_dbi_inv_cca_pkg;

 

/
