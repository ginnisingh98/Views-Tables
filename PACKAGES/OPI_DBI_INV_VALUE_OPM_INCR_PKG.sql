--------------------------------------------------------
--  DDL for Package OPI_DBI_INV_VALUE_OPM_INCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_INV_VALUE_OPM_INCR_PKG" AUTHID CURRENT_USER as
/* $Header: OPIDIPRS.pls 115.1 2003/04/29 22:11:33 warwu noship $ */

    PROCEDURE Extract_OPM_Daily_Activity
    (
        errbuf  IN OUT NOCOPY VARCHAR2,
        retcode IN OUT NOCOPY VARCHAR2,
        l_min_inception_date DATE
    );

    PROCEDURE OPM_Refresh
    (
        errbuf  IN OUT NOCOPY VARCHAR2,
        retcode IN OUT NOCOPY VARCHAR2
    );

END OPI_DBI_INV_VALUE_OPM_INCR_PKG;

 

/
