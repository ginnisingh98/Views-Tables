--------------------------------------------------------
--  DDL for Package OPI_DBI_COMMON_MOD_INCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_COMMON_MOD_INCR_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDCMODRS.pls 120.1 2005/08/10 01:51:01 sberi noship $ */


/* Outer wrapper routine for to run the common module */
PROCEDURE run_common_module_incr (errbuf OUT NOCOPY VARCHAR2,
                                  retcode OUT NOCOPY NUMBER);


/* API for user ETLs to report successful collection */
FUNCTION etl_report_success (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN;

/* API for ETLs to ensure that bounds are setup correctly for them */
FUNCTION incr_end_bounds_setup (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN;

/* API for ETL incremental loads to that they are meant to run and not the
   incremental loads
 */
FUNCTION run_incr_load (p_etl_id IN NUMBER, p_source IN NUMBER)
    RETURN BOOLEAN;

END opi_dbi_common_mod_incr_pkg;

 

/
