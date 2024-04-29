--------------------------------------------------------
--  DDL for Package INV_DIAG_RCV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DIAG_RCV" AUTHID CURRENT_USER AS
/* $Header: INVDR01S.pls 120.0.12000000.1 2007/06/22 01:21:55 musinha noship $ */

   test_out  VARCHAR2(200);

  PROCEDURE getDependencies (package_names OUT NOCOPY JTF_DIAG_DEPENDTBL);
  -- str OUT NOCOPY VARCHAR2);
  PROCEDURE isDependencyPipelined (str OUT NOCOPY VARCHAR2);
  PROCEDURE getOutputValues(outputValues OUT NOCOPY JTF_DIAG_OUTPUTTBL);

    PROCEDURE init;
    PROCEDURE cleanup;
    PROCEDURE runtest(inputs IN  JTF_DIAG_INPUTTBL,
                      report OUT NOCOPY JTF_DIAG_REPORT,
                      reportClob OUT NOCOPY CLOB);
    PROCEDURE getComponentName(str OUT NOCOPY VARCHAR2);
    PROCEDURE getTestName(str OUT NOCOPY VARCHAR2);
    PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2);
    PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL);
    FUNCTION  getTestMode return NUMBER;
END;

 

/
