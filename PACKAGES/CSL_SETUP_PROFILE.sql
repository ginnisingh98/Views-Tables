--------------------------------------------------------
--  DDL for Package CSL_SETUP_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_SETUP_PROFILE" AUTHID CURRENT_USER AS
/* $Header: cslstprs.pls 115.4 2002/11/08 14:01:24 asiegers ship $ */

 PROCEDURE init;
 PROCEDURE cleanup;
 PROCEDURE runtest(inputs IN  JTF_DIAG_INPUTTBL,
                   report OUT NOCOPY JTF_DIAG_REPORT,
                   reportClob OUT NOCOPY CLOB);
 PROCEDURE getComponentName(str OUT NOCOPY  VARCHAR2);
 PROCEDURE getTestName(str OUT NOCOPY  VARCHAR2);
 PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2);

END CSL_SETUP_PROFILE;

 

/
