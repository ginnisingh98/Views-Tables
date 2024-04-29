--------------------------------------------------------
--  DDL for Package IEM_DIAG_CREATE_ACCOUNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_DIAG_CREATE_ACCOUNT_PVT" AUTHID CURRENT_USER AS
/* $Header: iemdacts.pls 115.3 2003/01/20 22:39:16 chtang noship $ */

TYPE account_type IS RECORD (
          email_user    iem_email_accounts.email_user%type,
          domain 	iem_email_accounts.domain%type,
          db_server_id 	iem_email_accounts.db_server_id%type,
          email_password iem_email_accounts.email_password%type);

TYPE account_tbl IS TABLE OF account_type
           INDEX BY BINARY_INTEGER;

PROCEDURE init;
PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL);
PROCEDURE cleanup;
PROCEDURE runTest(inputs IN JTF_DIAG_INPUTTBL,
                  reports OUT NOCOPY  JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY CLOB);
PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2);
FUNCTION getTestMode RETURN INTEGER;
END;

 

/
