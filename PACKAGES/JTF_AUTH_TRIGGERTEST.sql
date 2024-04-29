--------------------------------------------------------
--  DDL for Package JTF_AUTH_TRIGGERTEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_AUTH_TRIGGERTEST" AUTHID CURRENT_USER AS
/* $Header: jtf_TriggerTestS.pls 115.0 2003/07/04 11:18:31 kgopalsa noship $ */
    PROCEDURE init;
    PROCEDURE cleanup;
    PROCEDURE runtest(inputs IN  JTF_DIAG_INPUTTBL,
                      report OUT NOCOPY JTF_DIAG_REPORT,
                      reportClob OUT NOCOPY CLOB);
    FUNCTION getTestMode RETURN INTEGER;
    PROCEDURE getTestName(testName OUT NOCOPY VARCHAR2);
    PROCEDURE getTestDesc(testDesc OUT NOCOPY VARCHAR2);
    PROCEDURE getComponentName(compName OUT NOCOPY VARCHAR2);
    PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL);
END;

 

/
