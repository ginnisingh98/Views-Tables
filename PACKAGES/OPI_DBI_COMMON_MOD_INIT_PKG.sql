--------------------------------------------------------
--  DDL for Package OPI_DBI_COMMON_MOD_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_COMMON_MOD_INIT_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDCMODIS.pls 120.1 2005/08/10 01:37:35 sberi noship $ */

/*++++++++++++++++++++++++++++++++++++++++*/
/* Common Module Constants */
/*++++++++++++++++++++++++++++++++++++++++*/

/*  All DBI ETLs have a numeric ETL ID for identification. The ETL
    functionality to etl_id mapping is defined as: */

JOB_TXN_ETL CONSTANT NUMBER := 1;           -- Job Transaction Staging ETL (WIP Completions, Actual Usage and Scrap)
ACTUAL_RES_ETL CONSTANT NUMBER := 2;        -- Actual Resource Usage
RESOURCE_VAR_ETL CONSTANT NUMBER := 3;      -- Resource Variance
JOB_MASTER_ETL CONSTANT NUMBER := 4;        -- Job Master

/*  All ETLs can have one of two sources: */
OPI_SOURCE CONSTANT NUMBER := 1;
OPM_SOURCE CONSTANT NUMBER := 2;

/*  ETLs can have to stop for multiple reasons. The stop reason
    codes are defined as follows: */
STOP_UNCOSTED CONSTANT NUMBER := 1;
STOP_ALL_COSTED CONSTANT NUMBER := 2;

/*----------------------------------------*/



/* Outer wrapper routine for to run the common module */
PROCEDURE run_common_module_init (errbuf OUT NOCOPY VARCHAR2,
                                  retcode OUT NOCOPY NUMBER);


/* Compute the initial bounds for all ETLs and all sources.
*/
PROCEDURE compute_initial_etl_bounds (errbuf OUT NOCOPY VARCHAR2,
                                      retcode OUT NOCOPY NUMBER,
                                      p_global_start_date IN DATE,
									  p_opi_schema IN VARCHAR2);

/* API for ETLs to ensure that bounds are setup correctly for them */
FUNCTION init_end_bounds_setup (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN;

/* API for ETL initial loads to that they are mean to run and not the
   initial loads
 */
FUNCTION run_initial_load (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN;


/* Some Utilities for initial and incremental load packages */

/* Verify global parameter setup */
FUNCTION check_global_setup
    RETURN BOOLEAN;

/* Return true if some rows stopped because of uncosted transactions */
FUNCTION bounds_uncosted
    RETURN BOOLEAN;


/*  Print the MMT bounds before which the OPI discrete orgs stopped, and the
    reason for stopping
*/
PROCEDURE print_opi_org_bounds;


END opi_dbi_common_mod_init_pkg;

 

/
