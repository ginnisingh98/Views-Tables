--------------------------------------------------------
--  DDL for Package JTF_DIAGNOSTIC_ADAPTUTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DIAGNOSTIC_ADAPTUTIL" AUTHID CURRENT_USER AS
/* $Header: jtfdiagadptutl_s.pls 120.8 2008/03/11 10:01:40 sramados noship $ */

 HIDDEN     INTEGER  := 0;
 VISIBLE    INTEGER  := 1;

 /* Different types of test mode. In BASIC_MODE, the test should be able to run
    with default parameters defined in it, or the test should be able to run
    without parameters.  In ADVANCE_MODE, the test can accept parameters
    which will be set by the driver.   In BOTH_MODE the test is visible
    on both basic and advanced pages in the UI.
 */
 BASIC_MODE      INTEGER  := 0;
 ADVANCED_MODE   INTEGER  := 1;
 BOTH_MODE       INTEGER  := 2;

 b_html_on  BOOLEAN;
 reportClob CLOB;

 FUNCTION checkValidAPI(packageName IN VARCHAR2) RETURN INTEGER;
 FUNCTION checkValidPackage(packageName IN VARCHAR2) RETURN INTEGER;
 FUNCTION checkPackageExists(packageName IN VARCHAR2) RETURN INTEGER;
 FUNCTION initInputTable RETURN JTF_DIAG_INPUTTBL;
 FUNCTION initReportTable RETURN JTF_DIAG_REPORTTBL;
 FUNCTION initReportClob  RETURN CLOB;
 FUNCTION getReportClob RETURN CLOB;
 FUNCTION compareResults(oper IN VARCHAR2,arg1 IN VARCHAR2,arg2 IN VARCHAR2) RETURN BOOLEAN;
 FUNCTION compareResults(oper IN VARCHAR2,arg1 IN INTEGER,arg2 IN INTEGER) RETURN BOOLEAN;
 FUNCTION extractVersion(versionStr IN VARCHAR2) RETURN VARCHAR2;
 FUNCTION constructReport(status    IN VARCHAR2 DEFAULT 'FAILED',
			  errStr    IN VARCHAR2 DEFAULT 'Internal Error',
			  fixInfo   IN VARCHAR2 DEFAULT 'No Fix Information Available',
			  isFatal   IN VARCHAR2 DEFAULT 'FALSE') RETURN JTF_DIAG_REPORT;
 FUNCTION getInputValue(argName IN VARCHAR2,inputs IN JTF_DIAG_INPUTTBL) RETURN VARCHAR2;
 FUNCTION getVersion(packageName IN VARCHAR2) RETURN VARCHAR2;
 FUNCTION addInput(inputs IN JTF_DIAG_INPUTTBL,var IN  VARCHAR2,val IN  VARCHAR2) RETURN JTF_DIAG_INPUTTBL;
 FUNCTION addInput(inputs IN JTF_DIAG_INPUTTBL,var IN VARCHAR2,val IN VARCHAR2,showValue IN BOOLEAN) RETURN JTF_DIAG_INPUTTBL;
 PROCEDURE setUpVars;
 PROCEDURE addStringToReport (reportStr IN LONG);
 FUNCTION  getTestMethodsForPkg(pkgName VARCHAR2) RETURN JTF_VARCHAR2_TABLE_4000;
 FUNCTION  getTestPackages(pkgName VARCHAR2) RETURN JTF_VARCHAR2_TABLE_4000;
 FUNCTION  getUnitTestPackages(pkgName VARCHAR2) RETURN JTF_VARCHAR2_TABLE_4000;
 PROCEDURE assert(message VARCHAR2,condition BOOLEAN);
 PROCEDURE fail(message VARCHAR2);
 PROCEDURE assertTrue(message VARCHAR2, condition BOOLEAN);
 PROCEDURE assertTrue(message VARCHAR2, operand VARCHAR2,arg1 VARCHAR2,arg2 VARCHAR2);
 PROCEDURE assertTrue(message VARCHAR2, operand VARCHAR2,arg1 NUMBER,arg2 NUMBER);
 PROCEDURE assertEquals(message VARCHAR2,arg1 NUMBER,arg2 NUMBER);
 PROCEDURE assertEquals(message VARCHAR2,arg1 VARCHAR2,arg2 VARCHAR2);
 PROCEDURE assertEquals(message VARCHAR2,arg1 CLOB,arg2 CLOB);
 PROCEDURE assertNotNull(message VARCHAR2,arg1 VARCHAR2);
 PROCEDURE assertNull(message VARCHAR2,arg1 VARCHAR2);
 PROCEDURE failNotEquals(message VARCHAR2,arg1 VARCHAR2,arg2 VARCHAR2);
 PROCEDURE failNotEquals(message VARCHAR2,arg1 NUMBER,arg2 NUMBER);
 PROCEDURE failNotEquals(message VARCHAR2,arg1 CLOB,arg2 CLOB);
 PROCEDURE failFormatted(message VARCHAR2,expected VARCHAR2,actual VARCHAR2);
 PROCEDURE failFormatted(message VARCHAR2,expected NUMBER,actual NUMBER);

 ----------------------------
 --- PipeLining APIs
 ----------------------------
 FUNCTION addOutput(outputs IN JTF_DIAG_OUTPUTTBL,var IN  VARCHAR2,val IN  VARCHAR2) RETURN JTF_DIAG_OUTPUTTBL;
 FUNCTION initOutputTable RETURN JTF_DIAG_OUTPUTTBL;

 FUNCTION addDependency(dependencies IN JTF_DIAG_DEPENDTBL, val IN  VARCHAR2) RETURN JTF_DIAG_DEPENDTBL;
 FUNCTION initDependencyTable RETURN JTF_DIAG_DEPENDTBL;


 ----------------------------
 --- Deprecated APIs
 ----------------------------
 PROCEDURE setUpVars(reportClob OUT NOCOPY CLOB);
 PROCEDURE addStringToReport(reportClob IN OUT NOCOPY CLOB,reportStr IN LONG);

 ---------------------------
 -- Procedure to add xml unsafe strings to report
 ---------------------------
 Procedure addSafeStringToReport(reportStr IN LONG);

 --------------------------------------------
 -- new API to initialise inputs and add them
 --------------------------------------------
 FUNCTION addInput(inputs IN JTF_DIAG_TEST_INPUTS,
                   name   IN  VARCHAR2,
                   value   IN  VARCHAR2,
                   isConfidential IN VARCHAR2 default 'FALSE',
                   defaultValue IN VARCHAR2 default null,
                   tip IN  VARCHAR2 default null,
                   isMandatory IN  VARCHAR2 default 'FALSE',
                   isDate IN VARCHAR2 default 'FALSE',
                   isNumber IN VARCHAR2 default 'FALSE') RETURN JTF_DIAG_TEST_INPUTS;


FUNCTION initialiseInput RETURN JTF_DIAG_TEST_INPUTS;


FUNCTION GET_SITE_DATE_FORMAT RETURN VARCHAR2;
FUNCTION GET_DATE_FORMAT(user_id IN number) RETURN VARCHAR2;
END JTF_DIAGNOSTIC_ADAPTUTIL;

/
