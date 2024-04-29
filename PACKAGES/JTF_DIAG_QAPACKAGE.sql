--------------------------------------------------------
--  DDL for Package JTF_DIAG_QAPACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DIAG_QAPACKAGE" AUTHID CURRENT_USER AS
/* $Header: jtfdiagadptdqa_s.pls 120.2 2005/08/13 01:16:08 minxu noship $ */

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
