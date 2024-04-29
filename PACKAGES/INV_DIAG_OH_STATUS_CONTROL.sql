--------------------------------------------------------
--  DDL for Package INV_DIAG_OH_STATUS_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DIAG_OH_STATUS_CONTROL" AUTHID CURRENT_USER AS
/* $Header: INVDOH3S.pls 120.0.12010000.1 2009/03/18 09:22:43 aambulka noship $ */
test_out  VARCHAR2(200);
PROCEDURE getDependencies (package_names OUT NOCOPY  JTF_DIAG_DEPENDTBL);
PROCEDURE isDependencyPipelined (str OUT NOCOPY  VARCHAR2);
PROCEDURE getOutputValues(outputValues OUT NOCOPY  JTF_DIAG_OUTPUTTBL);

PROCEDURE init;
/*PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL);*/
PROCEDURE cleanup;
PROCEDURE runtest(inputs IN JTF_DIAG_INPUTTBL,
                  report OUT NOCOPY JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY CLOB);
PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2);
Function getTestMode return INTEGER;
END INV_DIAG_OH_STATUS_CONTROL;

/