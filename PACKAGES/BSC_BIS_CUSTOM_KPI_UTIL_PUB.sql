--------------------------------------------------------
--  DDL for Package BSC_BIS_CUSTOM_KPI_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_BIS_CUSTOM_KPI_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCCSUBS.pls 120.2.12000000.3 2007/10/09 11:42:21 bijain ship $ */

/*REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCCSUBS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper API for KPI CRUD                                  |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |     13-Aug-04    rpenneru   Created.                                  |
REM |     17-AUG-04    adrao      Modified API SetGlobalFlag and added API  |
REM |                             Is_BSC52_Applied for Bug@3836170          |
REM |     05-OCT-04    ankgoel    Bug#3933075 Moved Get_Pmf_Metadata_By_Objective,
REM |                             get_Region_Code and C_AK_DATASOURCE here  |
REM |                             from BSCCRUDB.pls                         |
REM |     11-Feb-05    sawu       Bug#4057761: added Get_Unqiue_Tab_Name and|
REM |                             Get_Unqiue_Tab_Group_Name                 |
REM |     29-APR-05    ankagarw   Modified API Is_Short_Name_Available for Bug#4336571|
REM |                             Made it public.                           |
REM |     09-MAY-05    adrao      Added API is_Objective_Report_Type        |
REM |                             and is_Objective_Page_Type                |
REM |     26-SEP-2005 arhegde bug# 4624100 Moved get_format_mask code to    |
REM |          BSC_BIS_CUSTOM_KPI_UTIL_PUB from BSC_BIS_KPI_CRUD_PUB since  |
REM |          pure BIS can use it too.                                     |
REM |     02-Oct-2007 bijain   Bug#6327035  Changing the display name of a  |
REM |                 DashBord for End to End Kpi should update BSC MetaData|
REM +=======================================================================+ */

G_MDDD_52  NUMBER := 0;

C_BSC_PATCH_LEVEL_UNINIT    CONSTANT NUMBER := 0;
C_BSC_PATCH_LEVEL_511       CONSTANT NUMBER := 1; -- BSC.G (5110)
C_BSC_PATCH_LEVEL_52        CONSTANT NUMBER := 2;

C_AK_DATASOURCE                CONSTANT VARCHAR2(2) := 'AK';

C_MAX_LOOP_COUNT            CONSTANT NUMBER := 10000; --prevent infinite loop

C_OBJECT_TYPE_REPORT        CONSTANT VARCHAR2(6) := 'REPORT';
C_OBJECT_TYPE_PAGE          CONSTANT VARCHAR2(4) := 'PAGE';

C_BSC_DATA_SOURCE           CONSTANT VARCHAR2(15) := 'BSC_DATA_SOURCE';


-- added for Bug#4476730
C_DELETED_OBJECTIVE_FLAG    CONSTANT NUMBER := 2;

FUNCTION is_KPI_EndToEnd_Measure(p_Short_Name VARCHAR2) RETURN VARCHAR2;

FUNCTION is_KPI_EndToEnd_Measure(p_Measure_id NUMBER) RETURN VARCHAR2;

FUNCTION is_KPI_EndToEnd_MeasureGroup(p_Short_Name VARCHAR2) RETURN VARCHAR2;

FUNCTION is_kpi_endtoend_MeasureGroup(p_Measure_Group_Id NUMBER) RETURN VARCHAR2;

FUNCTION is_KPI_EndToEnd_MeasureCol(p_Measure_Col VARCHAR2,p_MesGrp_Short_Name VARCHAR2) RETURN VARCHAR2;

FUNCTION is_KPI_EndToEnd_MeasureCol(p_Measure_Col VARCHAR2) RETURN VARCHAR2;

/*this function will return 'T' if the passed short_name of scorecard
  is created through KPI End to End module otherwise 'F'
*/
FUNCTION is_KPI_EndToEnd_Scorecard(p_Short_Name VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_User_Function_Name(p_function_name VARCHAR2) RETURN VARCHAR2;

PROCEDURE SetGlobalFlag;

/*
  This public function is to test whether parameter is null or not.
*/
-- Added a public API to check for short_name via SetGlobalFlag
FUNCTION Is_Short_Name_Available RETURN VARCHAR2;

FUNCTION enableVarchar2Implementation  RETURN VARCHAR2;

FUNCTION Get_Region_Code (
            p_Kpi_Id NUMBER
          , p_AO_Id NUMBER := NULL
) RETURN VARCHAR2;

-- added for bug#3759819
PROCEDURE Get_Pmf_Metadata_By_Objective
(  p_Dataset_Id         IN         NUMBER
 , p_Measure_Short_Name IN         VARCHAR2
 , x_Actual_Source_Type OUT NOCOPY VARCHAR2
 , x_Actual_Source      OUT NOCOPY VARCHAR2
 , x_Function_Name      OUT NOCOPY VARCHAR2
);

--added for bug#4057761
FUNCTION Get_Unqiue_Tab_Name(
 p_tab_name        BSC_TABS_TL.NAME%TYPE
) RETURN BSC_TABS_TL.NAME%TYPE;

FUNCTION Get_Unqiue_Tab_Name(
 p_tab_name        BSC_TABS_TL.NAME%TYPE
 , p_tab_id          BSC_TABS_TL.TAB_ID%TYPE
) RETURN BSC_TABS_TL.NAME%TYPE;
FUNCTION Get_Unqiue_Tab_Group_Name(
 p_tab_grp_name        BSC_TAB_IND_GROUPS_TL.NAME%TYPE
) RETURN BSC_TAB_IND_GROUPS_TL.NAME%TYPE;

FUNCTION Get_Unqiue_Tab_Group_Name(
 p_tab_grp_name        BSC_TAB_IND_GROUPS_TL.NAME%TYPE
 , p_tab_grp_id          BSC_TAB_IND_GROUPS_TL.IND_GROUP_ID%TYPE
) RETURN BSC_TAB_IND_GROUPS_TL.NAME%TYPE;

-- API to check if the report is S2E or AG Report.

FUNCTION is_Report_S2E(
   p_Region_Function_Name IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION is_Objective_Report_Type (
    p_Short_Name IN VARCHAR2
) RETURN VARCHAR2;


FUNCTION is_Objective_Page_Type (
    p_Short_Name IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION Is_Objective_AutoGen_Type (
    p_Short_Name IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION Get_Format_Mask (
  p_Format_Id NUMBER
) RETURN VARCHAR2;

procedure update_kpi_End_To_End_Name(
p_Commit                       IN         VARCHAR2 := FND_API.G_FALSE
,p_Name                        IN         VARCHAR2
,p_Short_Name                  IN         VARCHAR2
,x_Return_Status               OUT NOCOPY VARCHAR2
,x_Msg_Count                   OUT NOCOPY NUMBER
,x_Msg_Data                    OUT NOCOPY VARCHAR2
);

END BSC_BIS_CUSTOM_KPI_UTIL_PUB;

 

/
