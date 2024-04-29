--------------------------------------------------------
--  DDL for Package CSM_SETUP_JTMCONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_SETUP_JTMCONC" AUTHID CURRENT_USER AS
/* $Header: csmdjcrs.pls 120.1 2005/07/22 04:57:34 trajasek noship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
-- Enter package declarations as shown below

    PROCEDURE init;
    PROCEDURE cleanup;
    PROCEDURE runtest(inputs IN JTF_DIAG_INPUTTBL,
                      report OUT NOCOPY JTF_DIAG_REPORT,
                      reportClob OUT NOCOPY CLOB);
    PROCEDURE getComponentName(str OUT NOCOPY  VARCHAR2);
    PROCEDURE getTestName(str OUT NOCOPY  VARCHAR2);
    PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2);

END; -- Package spec

 

/
