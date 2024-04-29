--------------------------------------------------------
--  DDL for Package CSK_DIAG_SOLUTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSK_DIAG_SOLUTION_PVT" AUTHID CURRENT_USER AS
  /* $Header: csktsols.pls 120.1 2005/06/22 12:26:39 appldev noship $ */
    PROCEDURE init;
    PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL);
    PROCEDURE cleanup;
    PROCEDURE runtest(inputs     IN  JTF_DIAG_INPUTTBL,
                      report     OUT NOCOPY JTF_DIAG_REPORT,
                      reportClob OUT NOCOPY CLOB);
    PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2);
    PROCEDURE getTestName(name OUT NOCOPY VARCHAR2);
    PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2);
                          l_statusStr VARCHAR2(50);
                          l_errStr VARCHAR2(4000);
                          l_fixInfo VARCHAR2(4000);
                          l_isFatal VARCHAR2(50);
END CSK_DIAG_SOLUTION_PVT;

 

/
