--------------------------------------------------------
--  DDL for Package INV_DIAG_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DIAG_ORG" AUTHID CURRENT_USER AS
/* $Header: INVDORGS.pls 120.1 2008/01/25 06:10:47 ssadasiv noship $ */
test_out  VARCHAR2(200);
g_org_id  NUMBER;
PROCEDURE getDependencies (package_names OUT NOCOPY JTF_DIAG_DEPENDTBL);
PROCEDURE isDependencyPipelined (str OUT NOCOPY VARCHAR2);
PROCEDURE getOutputValues(outputValues OUT NOCOPY JTF_DIAG_OUTPUTTBL);

PROCEDURE init;
PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL);
PROCEDURE cleanup;
PROCEDURE runtest(inputs IN JTF_DIAG_INPUTTBL,
                  report OUT NOCOPY JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY CLOB);
PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2);
Function getTestMode return INTEGER;
END;

/
