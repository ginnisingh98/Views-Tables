--------------------------------------------------------
--  DDL for Package Body JMF_SUBCONTRCT_DIAG_INTERLOCK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SUBCONTRCT_DIAG_INTERLOCK" AS
/* $Header: JMFDSUBB.pls 120.0.12010000.2 2010/06/28 06:28:07 abhissri ship $ */

--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JMFDSUBB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|   Subcontracting Diagnostics Test : Package Specification             |
--|                                                                       |
--| FUNCTIONS/PROCEDURE                                                   |
--|    init                                                               |
--|    cleanup                                                            |
--|    runtest                                                            |
--|    getComponentName                                                   |
--|    getTestDesc                                                        |
--|    getTestName                                                        |
--|    getDefaultTestParams                                               |
--| HISTORY                                                               |
--|      20-DEC-2007     kdevadas       Created                           |
--|                                                                       |
--+=======================================================================+

--=============================================
-- GLOBALS
--=============================================

--=============================================
-- PROCEDURES AND FUNCTIONS
--=============================================

--========================================================================
-- PROCEDURE : init    PUBLIC
-- PARAMETERS: NONE
-- COMMENT   : This procedure is invoked by the diagnostics framework
--             to  initialize test datastructures and executed prior to
--             the test run
--========================================================================
PROCEDURE init IS
BEGIN
-- test writer could insert special setup code here
NULL;
END init;


--========================================================================
-- PROCEDURE : cleanup    PUBLIC
-- PARAMETERS: NONE
-- COMMENT   : This procedure is invoked by the diagnostics framework to
--             cleanup any test datastructures that were setup in the init.
--========================================================================
PROCEDURE cleanup IS
BEGIN
-- test writer could insert special cleanup code here
NULL;
END cleanup;


--========================================================================
-- PROCEDURE : runtest    PUBLIC
-- PARAMETERS: inputs      Input for the test
--             report      Test Report Output
--             reportClob  Test Report Output
-- COMMENT   : This procedure is invoked by the doagnostics framework to
--             execute the PLSQL test
--========================================================================
PROCEDURE runtest(inputs IN JTF_DIAG_INPUTTBL,
  report OUT NOCOPY JTF_DIAG_REPORT,
  reportClob OUT NOCOPY CLOB)
IS
  reportStr LONG;
  statusStr VARCHAR2(50);
  errStr VARCHAR2(4000);
  fixInfo VARCHAR2(4000);
  isFatal VARCHAR2(50);
BEGIN
  JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
  JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
  JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

  statusStr :=  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_SUCCESS ;

  IF JMF_SUBCONTRCT_DIAG_UTIL.Check_Profiles <>  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_SUCCESS
  THEN
    statusStr := JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF ;

  IF JMF_SUBCONTRCT_DIAG_UTIL.Check_WIP_Parameters <>  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_SUCCESS
  THEN
    statusStr := JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF;

  IF JMF_SUBCONTRCT_DIAG_UTIL.Check_Accounting_Periods <>  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_SUCCESS
  THEN
    statusStr := JMF_SUBCONTRCT_DIAG_UTIL.g_status_failure;
  END IF;

  IF JMF_SUBCONTRCT_DIAG_UTIL.Check_Routings <>  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_SUCCESS
  THEN
    statusStr := JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF;

  IF JMF_SUBCONTRCT_DIAG_UTIL.Check_Shipping_Network <>  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_SUCCESS
  THEN
    statusStr := JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF;

  IF JMF_SUBCONTRCT_DIAG_UTIL.Check_Shipping_Methods <>  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_SUCCESS
  THEN
    statusStr := JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF;

  IF JMF_SUBCONTRCT_DIAG_UTIL.Check_Cust_Supp_Association <>  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_SUCCESS
  THEN
    statusStr := JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF;

  IF JMF_SUBCONTRCT_DIAG_UTIL.Check_Price_List <>  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_SUCCESS
  THEN
    statusStr := JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF;

  report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
  reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;

--============================================================================
-- PROCEDURE : getComponentName    PUBLIC
-- PARAMETERS: name      Component Name
-- COMMENT   : This procedure retuns the component name to the diagnostics fwk
--============================================================================
PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
  name := 'Subcontracting : Interlock Manager';
END getComponentName;

--=============================================================================
-- PROCEDURE : getComponentName    PUBLIC
-- PARAMETERS: descStr      Component Description
-- COMMENT   : This procedure retuns the test description to the diagnostics fwk
--=============================================================================
PROCEDURE getTestDesc(descStr OUT  NOCOPY VARCHAR2) IS
BEGIN
  descStr := 'Check for errors during the Interlock Manager run';
END getTestDesc;


--========================================================================
-- PROCEDURE : getTestName    PUBLIC
-- PARAMETERS: descStr      Test Description
-- COMMENT   : This procedure retuns the test description to the diagnostics fwk
--========================================================================
PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
  name := 'Interlock Manager errors';
END getTestName;


--========================================================================
-- PROCEDURE : getComponentName    PUBLIC
-- PARAMETERS: defaultInputValues      Default Test Parameters
-- COMMENT   : This procedure provides the default paramters for the test
--========================================================================
PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
tempInput JTF_DIAG_INPUTTBL;
BEGIN
  NULL;
END getDefaultTestParams;

END  JMF_SUBCONTRCT_DIAG_INTERLOCK ;

/
