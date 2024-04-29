--------------------------------------------------------
--  DDL for Package BIS_DIAG_SETUP_ENV_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_DIAG_SETUP_ENV_TEST" AUTHID CURRENT_USER AS
/* $Header: BISPDENS.pls 120.0.12000000.1 2007/08/09 09:59:04 appldev noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 2007 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPDENS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Diagnostics Environment Test Package Spec                         |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | Date              Developer           Comments                        |
REM | 02-AUG-2007       nbarik              Creation                        |
REM |                                                                       |
REM +=======================================================================+
*/

PROCEDURE init;
PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL);
PROCEDURE cleanup;
PROCEDURE runtest(inputs IN JTF_DIAG_INPUTTBL, report OUT NOCOPY JTF_DIAG_REPORT, reportClob OUT NOCOPY CLOB);
PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2);

END BIS_DIAG_SETUP_ENV_TEST;

 

/
