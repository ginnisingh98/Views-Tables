--------------------------------------------------------
--  DDL for Package FII_AP_INV_SUM_INC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_INV_SUM_INC" AUTHID CURRENT_USER AS
/* $Header: FIIAP19S.pls 115.1 2003/08/19 21:07:04 hredredd noship $ */


-----------------------------------------------------------
--  PROCEDURE COLLECT
-----------------------------------------------------------
Procedure Collect(Errbuf          IN OUT NOCOPY VARCHAR2,
                  Retcode         IN OUT NOCOPY VARCHAR2
                  );

END FII_AP_INV_SUM_INC;

 

/
