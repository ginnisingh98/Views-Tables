--------------------------------------------------------
--  DDL for Package BSC_TIME_DIM_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_TIME_DIM_TEST" AUTHID CURRENT_USER AS
/* $Header: BSCTIMDS.pls 120.1.12000000.1 2007/08/09 09:54:38 appldev noship $ */
PROCEDURE init;
PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL);
PROCEDURE cleanup;
PROCEDURE runtest(inputs IN JTF_DIAG_INPUTTBL,
report OUT NOCOPY JTF_DIAG_REPORT,
reportClob OUT NOCOPY CLOB);
PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2);
FUNCTION getTestMode RETURN INTEGER;
END;

 

/
