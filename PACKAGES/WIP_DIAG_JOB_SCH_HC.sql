--------------------------------------------------------
--  DDL for Package WIP_DIAG_JOB_SCH_HC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_DIAG_JOB_SCH_HC" AUTHID CURRENT_USER AS
/* $Header: WIPDDEFS.pls 120.0.12000000.1 2007/07/10 09:44:18 mraman noship $ */
test_out  VARCHAR2(200);
PROCEDURE invalid_job_def_job(inputs IN JTF_DIAG_INPUTTBL,
                  report OUT NOCOPY JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY CLOB);

PROCEDURE failed_job_close_job(inputs IN JTF_DIAG_INPUTTBL,
                  report OUT NOCOPY JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY CLOB);

END;

 

/
