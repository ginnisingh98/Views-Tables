--------------------------------------------------------
--  DDL for Package Body BSC_OBJECTIVE_METADATA_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_OBJECTIVE_METADATA_SETUP" AS
/* $Header: BSCOBMDB.pls 120.1.12000000.2 2007/08/09 12:34:07 akoduri noship $ */
/*=======================================================================+
 |  Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |                      BSCOBMDB.pls                                     |
 |                                                                       |
 | Creation Date:                                                        |
 |                      August 07, 2007                                  |
 |                                                                       |
 | Creator:                                                              |
 |                      Ajitha Koduri                                    |
 |                                                                       |
 | Description:                                                          |
 |          Public version.                                              |
 |          This package contains all the APIs related to diagnostics  of|
 |          objective report                                             |
 |                                                                       |
 | History:                                                              |
 |          07-AUG-2007 akoduri Bug 6083208 Diagnostics for Objectives   |
 *=======================================================================*/


/************************************************************************************
--      API name        : get_message_name
--      Type            : Public
--      Function        :
--
************************************************************************************/

--FUNCTION get_message_name(message_name VARCHAR2) RETURN VARCHAR2;

/************************************************************************************
--      API name        : init
--      Type            : Public
--      Function        :
--
************************************************************************************/
PROCEDURE init IS
BEGIN
    -- test writer could insert special setup code here
    NULL;
END init;
/************************************************************************************
--      API name        : cleanup
--      Type            : Public
--      Function        :
--
************************************************************************************/
PROCEDURE cleanup IS
BEGIN
    -- test writer could insert special cleanup code here
    NULL;
END cleanup;

/************************************************************************************
--      API name        : runtest
--      Type            : Public
--      Function        :
--
************************************************************************************/
PROCEDURE runtest(inputs IN JTF_DIAG_INPUTTBL,
                  report OUT NOCOPY JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY CLOB) IS
  l_kpi_Id       bsc_kpis_vl.indicator%TYPE;
  l_Is_AG_Report BOOLEAN := FALSE;
  statusStr      VARCHAR2(50);
  errStr         VARCHAR2(4000);
  fixInfo        VARCHAR2(4000);
  isFatal        VARCHAR2(50);
  l_Num_Rows     NUMBER := 0;
  l_Where_Clause VARCHAR2(1000);
  l_patch_number NUMBER;
BEGIN
     JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
     JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
     JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;
     l_kpi_Id := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue(get_message_name('BSC_OBJECTIVE'),inputs);
     IF l_kpi_Id IS NULL OR l_kpi_Id = '' THEN
       statusStr := 'FAILURE';
       errStr := get_message_name('BSC_EMPTY_OBJ_ID');
       fixInfo := get_message_name('BSC_SELECT_VALID_OBJECTIVE');
       JTF_DIAGNOSTIC_COREAPI.BRPrint;
       JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(fixInfo);
       isFatal := 'FALSE';
     ELSE
       JTF_DIAGNOSTIC_COREAPI.BRPrint;
       l_Where_Clause :=  ' WHERE indicator ='|| l_kpi_Id;
       l_Num_Rows := JTF_DIAGNOSTIC_COREAPI.Display_Table('bsc_kpis_vl','BSC_KPIS_VL', l_Where_Clause);
       l_Num_Rows := JTF_DIAGNOSTIC_COREAPI.Display_Table('bsc_kpi_analysis_measures_vl','BSC_KPI_ANALYSIS_MEASURES_VL', l_Where_Clause);
       l_Num_Rows := JTF_DIAGNOSTIC_COREAPI.Display_Table('bsc_kpi_analysis_groups','BSC_KPI_ANALYSIS_GROUPS', l_Where_Clause);
       l_Num_Rows := JTF_DIAGNOSTIC_COREAPI.Display_Table('bsc_kpi_analysis_options_vl','BSC_KPI_ANALYSIS_OPTIONS_VL', l_Where_Clause);
       l_Num_Rows := JTF_DIAGNOSTIC_COREAPI.Display_Table('bsc_kpi_dim_levels_vl','BSC_KPI_DIM_LEVELS_VL', l_Where_Clause);
       l_Num_Rows := JTF_DIAGNOSTIC_COREAPI.Display_Table('bsc_kpi_dim_level_properties','BSC_KPI_DIM_LEVEL_PROPERTIES', l_Where_Clause);
       l_Num_Rows := JTF_DIAGNOSTIC_COREAPI.Display_Table('bsc_kpi_periodicities','BSC_KPI_PERIODICITIES', l_Where_Clause);
       l_Num_Rows := JTF_DIAGNOSTIC_COREAPI.Display_Table('bsc_kpi_calculations','BSC_KPI_CALCULATIONS', l_Where_Clause);

       SELECT
         TO_NUMBER(REPLACE(property_value,'.','')) patch_number
       INTO
         l_patch_number
       FROM
         bsc_sys_init
       WHERE
         property_code = 'PATCH_NUMBER';

       IF l_patch_number >= 603 THEN
         l_Num_Rows := JTF_DIAGNOSTIC_COREAPI.Display_Table('bsc_kpi_measure_props','BSC_KPI_MEASURE_PROPS', l_Where_Clause);
       END IF;
       statusStr := 'SUCCESS';
     END IF;
     report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
     reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
 END runTest;

/************************************************************************************
--      API name        : runtest
--      Type            : Public
--      Function        :
--
************************************************************************************/
PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
    name := get_message_name('BSC_PMD_MODULE');
END getComponentName;

/************************************************************************************
--      API name        : getTestDesc
--      Type            : Public
--      Function        :
--
************************************************************************************/
PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2) IS
BEGIN
    descStr := get_message_name('BSC_PRINT_OBJ_INFO');
END getTestDesc;

/************************************************************************************
--      API name        : getTestName
--      Type            : Public
--      Function        :
--
************************************************************************************/
PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
    name := get_message_name('BSC_OBJECTIVE_DIAG');
END getTestName;

/************************************************************************************
--      API name        : getDefaultTestParams
--      Type            : Public
--      Function        :
--
************************************************************************************/
PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
    tempInput JTF_DIAG_INPUTTBL;
BEGIN
    tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
    tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,get_message_name('BSC_OBJECTIVE'),'LOV-oracle.apps.bsc.diag.lov.ObjectiveLOV');
    defaultInputValues := tempInput;
EXCEPTION
    WHEN OTHERS THEN
        defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
END getDefaultTestParams;

/************************************************************************************
--      API name        : getTestMode
--      Type            : Public
--      Function        :
--
************************************************************************************/

FUNCTION getTestMode RETURN INTEGER IS
BEGIN
    RETURN  JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;
END;

/************************************************************************************
--      API name        : get_message_name
--      Type            : Public
--      Function        :
--
************************************************************************************/

FUNCTION get_message_name(message_name VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  RETURN FND_MESSAGE.get_string('BSC',message_name);
END;

END BSC_OBJECTIVE_METADATA_SETUP;

/
