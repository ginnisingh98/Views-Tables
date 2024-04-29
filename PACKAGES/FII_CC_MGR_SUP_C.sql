--------------------------------------------------------
--  DDL for Package FII_CC_MGR_SUP_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_CC_MGR_SUP_C" AUTHID CURRENT_USER AS
/*$Header: FIICMSCS.pls 115.6 2003/08/21 23:56:04 phu noship $*/

PROCEDURE Init_Load (errbuf          IN OUT NOCOPY VARCHAR2,
                     retcode         IN OUT NOCOPY VARCHAR2);

PROCEDURE Incre_Update (errbuf          IN OUT NOCOPY VARCHAR2,
                        retcode         IN OUT NOCOPY VARCHAR2);

  -- Populate the TMP table: FII_CC_MGR_HIER_GT
  PROCEDURE Populate_HIER_TMP;

END FII_CC_MGR_SUP_C;

 

/
