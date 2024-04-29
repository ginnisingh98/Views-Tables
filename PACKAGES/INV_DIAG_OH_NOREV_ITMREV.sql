--------------------------------------------------------
--  DDL for Package INV_DIAG_OH_NOREV_ITMREV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DIAG_OH_NOREV_ITMREV" AUTHID CURRENT_USER AS
/* $Header: INVDO04S.pls 120.0.12000000.1 2007/06/22 01:02:39 musinha noship $ */

test_out  VARCHAR2(200);
PROCEDURE getDependencies (package_names OUT NOCOPY  JTF_DIAG_DEPENDTBL);
PROCEDURE isDependencyPipelined (str OUT NOCOPY  VARCHAR2);
PROCEDURE getOutputValues(outputValues OUT NOCOPY  JTF_DIAG_OUTPUTTBL);
Function getTestMode return INTEGER;

PROCEDURE init;
PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL);
PROCEDURE cleanup;
PROCEDURE runtest(inputs IN JTF_DIAG_INPUTTBL,
                  report OUT NOCOPY JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY CLOB);
PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2);
END INV_DIAG_OH_NOREV_ITMREV;

 

/
