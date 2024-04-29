--------------------------------------------------------
--  DDL for Package BOM_DIAGUNITTEST_CATHLCHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DIAGUNITTEST_CATHLCHK" AUTHID CURRENT_USER AS
/* $Header: BOMDGICS.pls 120.0.12000000.1 2007/07/26 13:26:57 vggarg noship $ */
test_out  VARCHAR2(200);
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
END BOM_DIAGUNITTEST_CATHLCHK;

 

/
