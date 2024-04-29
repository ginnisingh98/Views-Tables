--------------------------------------------------------
--  DDL for Package FII_AP_INV_SUM_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_INV_SUM_INIT" AUTHID CURRENT_USER AS
/* $Header: FIIAP18S.pls 115.1 2003/08/19 21:01:48 hredredd noship $ */


PROCEDURE WORKER(Errbuf          IN OUT NOCOPY VARCHAR2,
                 Retcode         IN OUT NOCOPY VARCHAR2,
                 p_from_date     IN            VARCHAR2,
                 p_to_date       IN            VARCHAR2,
                 p_worker_no     IN            NUMBER);


-----------------------------------------------------------
--  PROCEDURE COLLECT
-----------------------------------------------------------
Procedure Collect(Errbuf          IN OUT NOCOPY VARCHAR2,
                  Retcode         IN OUT NOCOPY VARCHAR2,
                  p_from_date     IN            VARCHAR2,
                  p_to_date       IN            VARCHAR2,
                  p_no_worker     IN            NUMBER);

END FII_AP_INV_SUM_INIT;

 

/
