--------------------------------------------------------
--  DDL for Package OPI_DBI_PRE_R12_RES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_PRE_R12_RES_PKG" AUTHID CURRENT_USER AS
/* $Header: OPIDREOS.pls 120.1 2005/08/09 14:25:37 julzhang noship $ */


/*======================================================
This procedure extracts actual resource usage data
    from the Pre-R12 data model into the staging table for
    initial load.  It is only called when the global start
    date is before the R12 migration date.

    Parameters:
    - errbuf: error buffer
    - retcode: return code
=======================================================*/
PROCEDURE pre_r12_opm_res_actual (errbuf    IN OUT NOCOPY VARCHAR2,
                                  retcode   IN OUT NOCOPY VARCHAR2);

END opi_dbi_pre_r12_res_pkg;

 

/
