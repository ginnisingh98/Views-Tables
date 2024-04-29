--------------------------------------------------------
--  DDL for Package FII_BUDGET_BASE_UPG_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_BUDGET_BASE_UPG_C" AUTHID CURRENT_USER AS
/*$Header: FIIBUDUPS.pls 120.0 2006/01/17 02:05:39 lpoon noship $*/
PROCEDURE UPDATE_TABLE(errbuf  IN OUT NOCOPY VARCHAR2,
                       retcode IN OUT NOCOPY VARCHAR2);

END FII_BUDGET_BASE_UPG_C;

 

/
