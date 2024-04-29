--------------------------------------------------------
--  DDL for Package IEM_DIAG_DATABASE_LINK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_DIAG_DATABASE_LINK_PVT" AUTHID CURRENT_USER AS
/* $Header: iemddbls.pls 115.2 2003/01/20 22:40:40 chtang noship $ */

PROCEDURE init;
PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL);
PROCEDURE cleanup;
PROCEDURE runTest(inputs IN JTF_DIAG_INPUTTBL,
                  reports OUT NOCOPY JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY CLOB);
PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2);
FUNCTION getTestMode RETURN INTEGER;
END;

 

/
