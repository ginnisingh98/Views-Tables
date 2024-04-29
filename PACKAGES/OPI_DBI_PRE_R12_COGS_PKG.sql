--------------------------------------------------------
--  DDL for Package OPI_DBI_PRE_R12_COGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_PRE_R12_COGS_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDECOGSPS.pls 120.1 2005/08/09 14:13:15 julzhang noship $ */


/*=================================================================
    This procedure extracts process data from the Pre R12 data model
    into the staging table. It is only called from the R12 COGS
    package when the global start date is before the R12 migration date.

    Parameters:
    - p_global_start_date: global start date
    - errbuf: error buffer
    - retcode: return code
===================================================================*/

PROCEDURE pre_r12_opm_cogs( p_global_start_date IN  DATE,
                            errbuf       IN OUT NOCOPY  VARCHAR2,
                            retcode      IN OUT NOCOPY  NUMBER);


END opi_dbi_pre_r12_cogs_pkg;

 

/
