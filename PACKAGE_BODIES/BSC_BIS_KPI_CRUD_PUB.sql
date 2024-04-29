--------------------------------------------------------
--  DDL for Package Body BSC_BIS_KPI_CRUD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_BIS_KPI_CRUD_PUB" AS
/* $Header: BSCCRUDB.pls 120.51 2007/10/09 13:03:34 bijain ship $ */

/*
REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCCRUDB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper API for Configure KPI List Page                   |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |     15-APR-04    akchan  Created                                      |
REM |     23-APR-04    adrao   Added Update/Delete  APIs                    |
REM |     06-MAY-04    hcamcho added dbdrv hint "plb" to package            |
REM |     07-MAY-04    adrao   KPI End-to-end Phase II: Modified CRUD APIs  |
REM |                          to handle 1 Dimension per Analysis Option    |
REM |     11-MAY-04    adrao   KPI End-to-end Phase II: Modified CRUD APIs  |
REM |                          to add Parameter Portlet Region Code as an   |
REM |                          nested region item and not add Dimension     |
REM |                          Level region items.                          |
REM |     14-MAY-04    adrao   Added 2 additional regions/analysis options  |
REM |     17-MAY-04    adrao   Enh: Modified Create_Kpi, Create_Tab,        |
REM |                          Create_Kpi_Group to use short_name           |
REM |     19-MAY-04    adrao   Used Page Function Name for KPI, KPI Group   |
REM |     20-MAY-04    adrao   Added the Create_Dimension API               |
REM |     24-MAY-04    adrao   Made Function User Name more descriptive     |
REM |                          Bug #3644445                                 |
REM |     26-MAY-04    akchan  remove method Create_PPX_Region_Item()       |
REM |                          change variable names on methods             |
REM |                          Does_Dim_Grp_Exist() and Does_KPI_Exist()    |
REM |                          use Constant for String "MEASURE_NOTARGET"   |
REM |     27-MAY-04    adrao   Modularized all CRUD APIs                    |
REM |     04-JUN-04    adrao   Added Autofactoring for Measure,  Compare To |
REM |     10-JUN-04    adrao   Modified Create_Measure and Update_Measure   |
REM |                          to disable Projection                        |
REM |     14-JUN-04    adrao   Modified Update and Create AK Regions for    |
REM |                          Bug#3688263 and Bug#3688300                  |
REM |     14-JUN-04    adrao   Added APIs to check for Time Dimension Objs  |
REM |     17-JUN-04    adrao   Modified Bug3698962 and Bug3698936 to remove |
REM |                          ATTRIBUTE3 to NULL except CHANGE_MEASURE and |
REM |                          set ATTRIBUTE10 to "Y" for MEASURE_NOTARGET  |
REM |     18-JUN-04    adrao   Added API Get_Next_Region_Code_By_AO for     |
REM |                          Enh#3691035                                  |
REM |     22-JUN-04    adrao   Bug#3717084, added a new column              |
REM |                          BSC_DB_MEASURE_GROUPS_TL.SHORT_NAME          |
REM |     05-JUL-04    adrao   Bug#3742500, Enabled Graph display at the    |
REM |                          measure level region item in create/update   |
REM |     14-JUL-04    adrao   Bug#3766260 Modified Does_KPI_Exist() to     |
REM |                          check for Deleted Objectives                 |
REM |     15-JUL-04    adrao   Fixed Bug#3766839 to get KPI_ID from         |
REM |                          measure short_name instead of Page Function  |
REM |     19-JUL-04    adrao   added API is_XTD_Enabled () for              |
REM |                          Bug#3767168 for Parameter Portlets           |
REM |     21-JUL-04    adrao   added API Get_S2EObjective_With_XTD for      |
REM |                          Bug#3780082                                  |
REM |     21-JUL-04    adrao   made short_name nonunique. prototype_flag =2 |
REM |                          Bug#3781764                                  |
REM |     22-JUL-04    adrao   Fixed Bug#3770986 (please see bug)           |
REM |     02-AUG-04    adrao   Fixed Bug#3802192                            |
REM |     04-AUG-04    adrao   Added API Populate_DBI_Calendar()            |
REM |                          for Bug#3809721                              |
REM |     11-AUG-04    adrao   Added API Get_Region_Codes_By_Short_Name     |
REM |                          for Bug#3777647                              |
REM |     18-AUG-04    adrao   Added API Check_XTD_Summarization() for      |
REM |                          Bug#3831859                                  |
REM |     23-AUG-04    adrao   Fixed Bug#3844823                            |
REM |     24-AUG-04    adrao   Updated Report Name for Bug#3844849          |
REM |     02-SEP-04    adrao   Added API Get_Kpi_Details for Bug#3814292    |
REM |     09-SEP-04    adrao   Added API Get_Change_Disp_Type_By_Mask() for |
REM |                          Bug#3876413                                  |
REM |     20-SEP-04    ankgoel Added Get_Pmf_Metadata_By_Objective for      |
REM |                          Bug#3759819                                  |
REM |     21-SEP-04    adrao   Added exception handling to Create_Measure   |
REM |                          API for Bug#3755656                          |
REM |     27-SEP-04    ankgoel Modified Get_Pmf_Metadata_By_Objective for   |
REM |                          Bug#3916377                                  |
REM |     29-SEP-04    adrao   Modified base column attribute3 based on the |
REM |                          format masking for Bug#3919666               |
REM |     30-SEP-04   rpenneru Added Get_S2ESCR_DeleteMessage,              |
REM |                           , Delete_S2E_Metadata for bug#3893949       |
REM |     05-OCT-04   ankgoel  Bug#3933075 Moved Get_Pmf_Metadata_By_Objective
REM |                          and C_AK_DATASOURCE and get_Region_Code to   |
REM |                          BSCCSUBB.pls. Moved C_BSC_UNDERSCORE to      |
REM |                          BSCUTILB.pls. Removed Get_KpiId_By_DatasetId |
REM |     30-SEP-04   rpenneru Modified for bug#3938515                     |
REM |     30-SEP-04   skchoudh Modified for bug#3940652, changed            |
REM |                          Validate_Kpi_Delete                          |
REM |     02-NOV-04   akoduri  Modified for bug#3977463                     |
REM |     21-DEC-04   adrao    Modified for 8i compatibility, Bug#4079898   |
REM |     28-JAN-05   visuri   added Has_Compare_To_Or_Plan() , modified    |
REM |                        Create_Addl_Ak_Region_Items() for Enh. 4065089 |
REM |     08-FEB-05   visuri   Modified Create_Addl_Ak_Region_Items() for   |
REM |                          Enh. 4065098                                 |
REM |     11-Feb-05   sawu    Bug#4057761: create unique tab name, group    |
REM |                         name                                          |
REM |     22-FEB-05   adrao   Autogenerated Measures Enhancement for Report |
REM |                         Designer                                      |
REM |     01-MAR-05   adrao   Fixed Bug#4213345 and modify the API          |
REM |                         Get_Dim_Info_From_ParamPortlet                |
REM |     07-MAR-05   vtulasi Added procedure Get_Dep_Obj_Func_Name         |
REM |                         for bug# 3786130                              |
REM |     21-Feb-05   rpenneru Enh#4059160, Add FA as property to Custom KPIs|
REM |     10-MAR-05   adrao   added API Convert_AutoGen_To_ViewBased for    |
REM |                         Convert AGR to VBR enhancement.               |
REM |     18-MAR-05   adrao   Made modification to ensure Duplication of    |
REM |                         reports and added a few util APIs             |
REM |     24-MAR-05   visuri Modified Delete_Misc_Region_Items() Bug 4231753|
REM |     30-MAR-05   adrao   Modified Create AG report to manage deleted   |
REM |                         measures                                      |
REM |     21-Feb-05   rpenneru Bug#4287317, Pass p_Measure_Short_Name to    |
REM |                          createBscBisMetaData instread of default NULL|
REM |     12-APR-05   kyadamak  Modified for bug# 4288237 calling           |
REM |                          update_measure only from report designer     |
REM |     22-APR-05   akoduri Enhancement#3865711 -- Obsolete Seeded Objects|
REM |     26-APR-05   visuri Enhancement#4309381 --Length of WHERE_CLAUSE of|
REM |                        BSC_SYS_DI_LEVELS_BY_GROUP increased to 4000   |
REM |     27-APR-05   adrao  Fixed bug#4327887 - Moved validation to lower  |
REM |                        PL/SQL API Create_Bsc_Bis_Metadata             |
REM |     04-MAY-05   adrao  Always create default measure group for AG     |
REM |     03-MAY-2005  akoduri  Enh #4268374 -- Weighted Average Measures   |
REM |     11-MAY-2005  adrao   Created the following APIs for               |
REM |                         selective cascading of Dimensions and Measures|
REM |                               Has_Measure_Column_Changed              |
REM |                               Has_Time_Dim_Obj_Changed                |
REM |                               Has_Non_Time_Dim_Obj_Changed            |
REM |     19-MAY-2005  visuri   GSCC Issues bug 4363884                     |
REM |     22-JUN-2005  ppandey  Bug #4447283, used cursor.                  |
REM |     28-JUN-2005  rpenneru Bug #4447654, Has_Measure_Column_Changed    |
REM |                           modified                                    |
REM |     30-JUN-2005  akoduri  Bug#4370200 , Default Number of Rows not    |
REM |                           getting saved                               |
REM |     08-jul-05    ASHANKAR added the method is_Scorecard_From_Reports  |
REM |     02-JUN-2005  adrao  Added APIs for Calendar Enhancement (4376162) |
REM |     13-JUL-2005  adrao  Enabled addition of Time based Periodicities  |
REM |                         in the Calendar+Periodicity format #4376162   |
REM |     15-JUL-2005  akoduri  Provided warning messasges for strucutural |
REM |                          and color changes #4492177                   |
REM |     04-AUG-2005  adrao  Fixed Bug#4520525                             |
REM |     16-AUG-2005  akoduri  Bug#4482355   Removing attribute_code and   |
REM|                            attribute2 dependency in Report Designer    |
REM |     25-AUG-2005  adrao   Filtered out Rolling Dimension Object type   |
REM |                          by calling API Get_Non_Rolling_Dim_Obj for   |
REM |                          Bug#4566634                                  |
REM |     25-AUG-2005  rpenneru Report formFunction parameters should have  |
REM |                           'pParameters=pParamIds@Y'. bug#4560857      |
REM |     05-SEP-2005  adrao   Modifed AGReport creation without AS_OF_DATE |
REM |                          Bug#4552657                                  |
REM |     14-SEP-2005  adrao   Fixed Bug#4599432 for updating non seeded    |
REM |                          existing source measures                     |
REM |     07-SEP-2005  adrao  Implemented dynamic Parameter Portlet builder |
REM |                         as required by Bug#4558279                    |
REM |     23-SEP-2005  akoduri Bug #4389280 Removing all the measures from  |
REM |                          an AG Report is not showing warning          |
REM |     26-SEP-2005 arhegde bug# 4624100 Moved get_format_mask code to    |
REM |   BSC_BIS_CUSTOM_KPI_UTIL_PUB since pure BIS can use it too.          |
REM |     28-SEP-2005  akoduri Bug #4626935 Unchecking all the periodicities|
REM |                          is not updating bsc_kpi_periodicities        |
REM |     26-SEP-2005 ashankar Bug#4619367 Made chnages to the following API|
REM |                          1.Has_Time_Dim_Obj_Changed                   |
REM |                          2.Has_Measure_Column_Changed                 |
REM |     30-SEP-2005 adrao    Modified code to ensure that the compare is  |
REM |                          populated when the measure is created        |
REM |                          Fixed Bug#4638384                            |
REM |07-NOV-2005 arhegde bug# 4720781 Handle bisviewer.showReport changed to|
REM |     OA.jsp?page=/oracle/apps/bis/report/webui/BISReportPG             |
REM |     25-DEC-2005 adrao   Added APIs following APIs for Enh#3909868     |
REM |                           - Migrate_AGR_To_PLSQL                      |
REM |                           - Is_Primary_Source_Of_Measure              |
REM |                           - Cascade_Attr_Code_Into_Measure            |
REM |                           - Cascade_Changes_Into_Forumla              |
REM |     03-JAN-2005 adrao   Added API for Is_Dim_Associated_To_Objective()|
REM |                         for Bug#4923006                               |
REM |     06-JAN-2006 akoduri  Enh#4739401 - Hide Dimensions/Dim Objects    |
REM |     17-JAN-2006 rpenneru bug#4741919 - AG report deletion             |
REM |     17-JAN-2006 adrao    Modified Migrate_AGR_To_PLSQL()              |
REM |                          for Bug#4958056                              |
REM |     19-JAN-2006 adrao    Added API Migrate_To_Existing_Source() for   |
REM |                          Enhancement#4952167                          |
REM |     07-FEB-2006 hengliu  Bug#4955493 - Not overwrite global menu/title|
REM |     07-FEB-2006 ppandey  Bug#4771854 - Rolling Periods for AG         |
REM |     16-FEB-2006 adrao    added ABS() to DBMS_UTILITY.GET_TIME for     |
REM |                          Bug#5039894                                  |
REM |     08-MAR-2006 adrao    Bug#5081180 - Ensured that Delete_Dimension  |
REM |                          is not called in Delete_AG_Bsc_Metadata()    |
REM |                          when there is no dimension                   |
REM |     18-MAY-2006 akoduri  Bug #5072842  Added Have_Measures_Changed API|
REM |                          to check for structural changes              |
REM |     19-MAY-2006 ankgoel  Bug #5201116 Get correct Comparison Source   |
REM |     22-MAY-2006 akoduri  Bug #5104426 Data Source getting updated     |
REM |                          BSC Type measures                            |
REM |     11-OCT-2006 akoduri  Bug #5554168 Issue with Measures having      |
REM |                          different short names in bis_indicators &    |
REM |                          bsc_sys_measures                             |
REM |     09-feb-2007 ashankar Simulation Tree Enhacement 5386112           |
REM |     22-Mar-2007 ashankar Fixed the Bug#5930808                        |
REM +=======================================================================+
*/


FUNCTION Is_Assign_To_Tab
(
   p_indicator      IN     BSC_KPIS_B.indicator%TYPE
  ,p_tabId          IN     BSC_TABS_B.tab_id%TYPE
)RETURN VARCHAR2 IS

l_count     NUMBER;
l_attached  VARCHAR2(2);

BEGIN

 l_attached := FND_API.G_TRUE;
 SELECT COUNT(0)
 INTO   l_count
 FROM   bsc_tab_indicators
 WHERE  tab_id = p_tabId
 AND    indicator =  p_indicator;

 IF(l_count =0)THEN
    l_attached := FND_API.G_FALSE;
 END IF;

 RETURN l_attached;

END  Is_Assign_To_Tab;


--------------------------------------------------------------------------------
-- Create BSC KPI with BIS Dimension from start to end.
--------------------------------------------------------------------------------
PROCEDURE Create_Kpi_End_To_End(
      p_Commit                      IN         VARCHAR2 := FND_API.G_FALSE
     ,p_Responsibility_Id           IN         NUMBER
     ,p_Create_New_Kpi              IN         VARCHAR2 := FND_API.G_FALSE
     ,p_Kpi_Id_To_Add_Measure       IN         VARCHAR2 := NULL
     ,p_Param_Portlet_Region_Code   IN         VARCHAR2
     ,p_Kpi_Name                    IN         VARCHAR2 := NULL
     ,p_Kpi_Description             IN         VARCHAR2 := NULL
     ,p_Measure_Name                IN         VARCHAR2
     ,p_Measure_Short_Name          IN         VARCHAR2 := NULL
     ,p_Measure_Description         IN         VARCHAR2 := NULL
     ,p_Measure_Type                IN         NUMBER   := NULL
     ,p_Measure_Operation           IN         VARCHAR2 := BSC_BIS_MEASURE_PUB.c_SUM
     ,p_Dataset_Format_Id           IN         NUMBER   := NULL
     ,p_Dataset_Autoscale_Flag      IN         NUMBER   := NULL
     ,p_Measure_Increase_In_Measure IN         VARCHAR2 := NULL
     ,p_Measure_Random_Style        IN         NUMBER   := NULL
     ,p_Measure_Min_Act_Value       IN         NUMBER   := NULL
     ,p_Measure_Max_Act_Value       IN         NUMBER   := NULL
     ,p_Page_Function_Name          IN         VARCHAR2
     ,p_Kpi_Portlet_Function_Name   IN         VARCHAR2
     ,p_Create_Region_Per_Ao        IN         VARCHAR2 := FND_API.G_TRUE
     ,p_Measure_App_Id              IN         NUMBER   := NULL
     ,p_Func_Area_Short_Name        IN         VARCHAR2 := NULL
     ,x_Measure_Short_Name          OUT NOCOPY VARCHAR2
     ,x_Kpi_Id                      OUT NOCOPY NUMBER
     ,x_Return_Status               OUT NOCOPY VARCHAR2
     ,x_Msg_Count                   OUT NOCOPY NUMBER
     ,x_Msg_Data                    OUT NOCOPY VARCHAR2
) IS


  l_Dataset_Id                      NUMBER;
  l_Does_Kpi_Exist                  BOOLEAN;
  l_Kpi_Id                          NUMBER;
  l_Max_Seq_Number                  NUMBER;
  l_User_Page_Name                  VARCHAR2(100);
  l_User_Portlet_Name               VARCHAR2(100);
  l_Analysis_Option                 NUMBER;
  l_Region_Code                     VARCHAR2(80);

  -- added for Bug#4064587
  l_Bsc_Kpi_Entity_Rec              BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

  l_Param_Region_Code               AK_REGIONS.REGION_CODE%TYPE;
  l_Param_Region_Application_Id     AK_REGIONS.REGION_APPLICATION_ID%TYPE;

BEGIN
    SAVEPOINT CreateEndToEndKPI;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    IF (p_Param_Portlet_Region_Code IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_PARAM_PORTLET');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- added for Bug#4558279
    BSC_BIS_KPI_CRUD_PUB.Cascade_Parameter_Portlet (
          p_Commit                       => p_Commit
        , p_Page_Function_Name           => p_Page_Function_Name
        , p_Param_Region_Code            => p_Param_Portlet_Region_Code
        , p_Param_Region_Application_Id  => Get_Region_Application_Id(p_Param_Portlet_Region_Code)
        , p_Action_Type                  => BSC_UTILITY.C_CREATE
        , x_Region_Code                  => l_Param_Region_Code
        , x_Region_Application_Id        => l_Param_Region_Application_Id
        , x_Return_Status                => x_Return_Status
        , x_Msg_Count                    => x_Msg_Count
        , x_Msg_Data                     => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_User_Page_Name    := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_User_Function_Name(p_Page_Function_Name);
    l_User_Portlet_Name := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_User_Function_Name(p_Kpi_Portlet_Function_Name);

    l_Does_Kpi_Exist    := BSC_BIS_KPI_CRUD_PUB.Does_KPI_Exist(p_Page_Function_Name);

    BSC_BIS_KPI_CRUD_PUB.Create_Bsc_Bis_Metadata(
            p_Commit                      => p_Commit
          , p_Create_Region_Per_Ao        => p_Create_Region_Per_Ao
          , p_Param_Portlet_Region_Code   => l_Param_Region_Code
          , p_Page_Function_Name          => p_Page_Function_Name
          , p_Kpi_Portlet_Function_Name   => p_Kpi_Portlet_Function_Name
          , p_Region_Function_Name        => NULL
          , p_Region_User_Function_Name   => NULL
          , p_Dim_Obj_Short_Names         => NULL
          , p_Measure_Short_Name          => p_Measure_Short_Name
          , p_Force_Create_Dim            => FND_API.G_FALSE
          , p_Responsibility_Id           => p_Responsibility_Id
          , p_Measure_Name                => p_Measure_Name
          , p_Measure_Description         => p_Measure_Description
          , p_Dataset_Format_Id           => p_Dataset_Format_Id
          , p_Dataset_Autoscale_Flag      => p_Dataset_Autoscale_Flag
          , p_Measure_Operation           => p_Measure_Operation
          , p_Measure_Increase_In_Measure => p_Measure_Increase_In_Measure
          , p_Measure_Obsolete            => FND_API.G_FALSE
      , p_Type                        => NULL
          , p_Measure_Random_Style        => p_Measure_Random_Style
          , p_Measure_Min_Act_Value       => p_Measure_Min_Act_Value
          , p_Measure_Max_Act_Value       => p_Measure_Max_Act_Value
          , p_Measure_Type                => p_Measure_Type
          , p_Measure_App_Id              => p_Measure_App_Id
          , p_Func_Area_Short_Name        => p_Func_Area_Short_Name
          , x_Measure_Short_Name          => x_Measure_Short_Name
          , x_Kpi_Id                      => x_Kpi_Id
          , x_Return_Status               => x_Return_Status
          , x_Msg_Count                   => x_Msg_Count
          , x_Msg_Data                    => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF (x_Measure_Short_Name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_DIP_MEASURE_SNAME_IS_NULL');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Get the KPI Associated
    l_Kpi_Id          := x_Kpi_Id;
    l_Dataset_Id      := BSC_BIS_KPI_CRUD_PUB.Get_Dataset_Id(x_Measure_Short_Name);
    l_Analysis_Option := BSC_BIS_KPI_CRUD_PUB.Get_AO_Id_By_Measure(l_Kpi_Id, l_Dataset_Id);

    IF ((p_Create_Region_Per_AO = FND_API.G_TRUE) OR (l_Does_Kpi_Exist = FALSE)) THEN

        BSC_BIS_KPI_CRUD_PUB.Create_Ak_Metadata(
              p_Commit                      =>  p_Commit
            , p_Create_Region_Per_AO        =>  p_Create_Region_Per_AO
            , p_Kpi_Id                      =>  l_Kpi_Id
            , p_Analysis_Option_Id          =>  l_Analysis_Option
            , p_Dim_Set_Id                  =>  0
            , p_Measure_Short_Name          =>  x_Measure_Short_Name
            , p_Measure_Name                =>  p_Measure_Name
            , p_Measure_Description         =>  p_Measure_Description
            , p_User_Portlet_Name           =>  l_User_Portlet_Name
            , p_Dataset_Format_Id           =>  p_Dataset_Format_Id
            , p_Application_Id              =>  BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID -- BSC
            , p_Disable_View_By             =>  'N'
            , p_Param_Portlet_Region_Code   =>  l_Param_Region_Code
            , x_Return_Status               =>  x_Return_Status
            , x_Msg_Count                   =>  x_Msg_Count
            , x_Msg_Data                    =>  x_Msg_Data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSE

        -- Single Region (BSC_<KPIID>)
        l_Region_Code    := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Region_Code(l_Kpi_Id, -1);

        l_Max_Seq_Number := BSC_BIS_KPI_CRUD_PUB.Find_Max_Seq_Of_Region_Item(l_Region_Code);
        l_Max_Seq_Number := l_Max_Seq_Number + 10;

        BSC_BIS_KPI_CRUD_PUB.Create_Measure_Region_Item(
            p_Commit                  => p_Commit
           ,p_Measure_Short_Name      => x_Measure_Short_Name
           ,p_Sequence_Number         => l_Max_Seq_Number
           ,p_Kpi_Id                  => l_Kpi_Id
           ,p_Analysis_Option         => NULL
           ,p_Dataset_Format_Id       => p_Dataset_Format_Id
           ,p_Dataset_Autoscale_Flag  => p_Dataset_Autoscale_Flag
           ,p_Analysis_Option_Name    => l_User_Portlet_Name
           ,x_Return_Status           => x_Return_Status
           ,x_Msg_Count               => x_Msg_Count
           ,x_Msg_Data                => x_Msg_Data
        );
        IF (x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;

    IF (p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateEndToEndKPI;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateEndToEndKPI;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateEndToEndKPI;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Create_Kpi_End_To_End ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Create_Kpi_End_To_End ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CreateEndToEndKPI;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Create_Kpi_End_To_End ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Create_Kpi_End_To_End ';
        END IF;
END Create_Kpi_End_To_End;


/*
  API to updaate End 2 End KPI
*/

PROCEDURE Update_Kpi_End_To_End(
  p_Commit                      IN         VARCHAR2 := FND_API.G_FALSE
 ,p_Param_Portlet_Region_Code   IN         VARCHAR2
 ,p_Page_Function_Name          IN         VARCHAR2
 ,p_Kpi_Portlet_Function_Name   IN         VARCHAR2
 ,p_Measure_Name                IN         VARCHAR2
 ,p_Measure_Short_Name          IN         VARCHAR2 := NULL
 ,p_Measure_Description         IN         VARCHAR2 := NULL
 ,p_Measure_Type                IN         NUMBER   := NULL
 ,p_Measure_Operation           IN         VARCHAR2 := BSC_BIS_MEASURE_PUB.c_SUM
 ,p_Dataset_Format_Id           IN         NUMBER   := NULL
 ,p_Dataset_Autoscale_Flag      IN         NUMBER   := NULL
 ,p_Measure_Increase_In_Measure IN         VARCHAR2 := NULL
 ,p_Measure_Random_Style        IN         NUMBER   := NULL
 ,p_Measure_Min_Act_Value       IN         NUMBER   := NULL
 ,p_Measure_Max_Act_Value       IN         NUMBER   := NULL
 ,p_Measure_App_Id              IN         NUMBER   := NULL
 ,p_Func_Area_Short_Name        IN         VARCHAR2 := NULL
 ,x_Return_Status               OUT NOCOPY VARCHAR2
 ,x_Msg_Count                   OUT NOCOPY NUMBER
 ,x_Msg_Data                    OUT NOCOPY VARCHAR2
) IS

  x_Non_Time_Dimension_Groups       BSC_VARCHAR2_TBL_TYPE;
  x_Non_Time_Dimension_Objects      BSC_VARCHAR2_TBL_TYPE;
  x_Non_Time_Dim_Obj_Short_Names    VARCHAR2(32000) := NULL;
  x_Time_Dimension_Groups           BSC_VARCHAR2_TBL_TYPE;
  x_Time_Dimension_Objects          BSC_VARCHAR2_TBL_TYPE;
  x_Time_Dim_Obj_Short_Names        VARCHAR2(32000) := NULL;
  x_All_Dim_Group_Ids               BSC_NUMBER_TBL_TYPE;
  x_Non_Time_Counter                NUMBER;
  x_Time_Counter                    NUMBER;
  l_Dataset_Source                  VARCHAR2(10) := NULL;
  l_Dataset_Id                      NUMBER;
  l_Does_Dim_Group_Exist            BOOLEAN;
  l_Does_Kpi_Exist                  BOOLEAN;
  l_Indicator                       NUMBER;
  l_Tab_Id                          NUMBER;
  l_Kpi_Group_Id                    NUMBER;
  l_Kpi_Id                          NUMBER;
  l_Real_Kpi_Name                   BSC_KPIS_VL.NAME%TYPE;
  l_Fid                             NUMBER;
  l_Rowid                           ROWID;
  l_form_parameters                 VARCHAR2(32000);
  l_max_seq_number                  NUMBER;
  l_sequence                        NUMBER;
  l_Bsc_Measure_Id                  NUMBER;
  l_report_region_rec               BIS_AK_REGION_PUB.Bis_Region_Rec_Type;
  l_Analysis_Option_Id              NUMBER;
  l_AO_Id                           NUMBER;
  l_Region_Code                     VARCHAR2(30);
  l_Has_Region_By_AO                BOOLEAN;


BEGIN

    SAVEPOINT UpdateEndToEndKPI;
    -- Initialize the Messaging
    FND_MSG_PUB.Initialize;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    -- Get the KPI ID from the Measure Short_Name (Bug#3766839)
    l_Kpi_Id     := NVL(BSC_BIS_KPI_CRUD_PUB.Get_Objective_By_Kpi(p_Measure_Short_Name),
                          BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY);
    l_Dataset_Id := BSC_BIS_KPI_CRUD_PUB.Get_Dataset_Id(p_Measure_Short_Name);
    l_sequence   := 10;

    -- Validate Input Parameters.
    -- check if the KPI is in production mode, if yes throw and exception

    IF (p_Param_Portlet_Region_Code IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_PARAM_PORTLET');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('is_Indicator_In_Production');

    l_AO_Id       := BSC_BIS_KPI_CRUD_PUB.Get_AO_Id_By_Measure (l_Kpi_Id, l_Dataset_Id);
    l_Region_Code := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Region_Code (l_Kpi_Id ,l_AO_Id);


    BSC_BIS_KPI_CRUD_PUB.Get_Dim_Info_From_Region_Code(
          p_Param_Portlet_Region_Code      =>  BSC_BIS_KPI_CRUD_PUB.Get_Param_Portlet_By_Region(l_Region_Code)
         , x_Non_Time_Dimension_Groups     =>  x_Non_Time_Dimension_Groups
         , x_Non_Time_Dimension_Objects    =>  x_Non_Time_Dimension_Objects
         , x_Non_Time_Dim_Obj_Short_Names  =>  x_Non_Time_Dim_Obj_Short_Names
         , x_All_Dim_Group_Ids             =>  x_All_Dim_Group_Ids
         , x_Non_Time_Counter              =>  x_Non_Time_Counter
         , x_Time_Dimension_Groups         =>  x_Time_Dimension_Groups
         , x_Time_Dimension_Objects        =>  x_Time_Dimension_Objects
         , x_Time_Dim_Obj_Short_Names      =>  x_Time_Dim_Obj_Short_Names
         , x_Time_Counter                  =>  x_Time_Counter
         , x_Msg_Data                      =>  x_Msg_Data
    );
    IF (x_Msg_Data IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_REG_DIM_AK ');
        FND_MESSAGE.SET_TOKEN('CODE', p_Param_Portlet_Region_Code);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Need to update the Region Item FORMAT_ID and AUTOSCALE FLAG
    --l_sequence


    l_Sequence := BSC_BIS_KPI_CRUD_PUB.Get_Sequence_Id_By_Region(
                        p_Region_Code               => l_Region_Code
                      , p_Region_Application_Id     => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID -- BSC
                      , p_Attribute_Code            => p_Measure_Short_Name
                      , p_Attribute_Application_Id  => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID -- BSC
                  );



    IF BSC_BIS_KPI_CRUD_PUB.is_Valid_Region_Code(l_Region_Code) THEN
      l_Analysis_Option_Id := l_AO_Id;
    ELSE
      l_Analysis_Option_Id := NULL;
    END IF;


    -- Upade the Measure Prototype Data.

    --DBMS_OUTPUT.PUT_LINE('Outside BSC_BIS_MEASURE_PUB.Update_Measure' );

    -- Push the query to a function (mod)
    SELECT
    m.measure_id
    INTO
    l_Bsc_Measure_Id
    FROM
    bsc_sys_measures m,
    bsc_sys_datasets_vl d,
    bis_indicators i
    WHERE
    i.dataset_id  = d.dataset_id AND
    d.measure_id1 = m.measure_id AND
    i.short_name  = p_measure_short_name;

    -- Passed AK type and AK source (pl/sql), since they were getting updated to null
    BSC_BIS_MEASURE_PUB.Update_Measure(
       p_Commit                      =>  p_commit
      ,p_Dataset_Id                  =>  l_dataset_id
      ,p_Dataset_Source              =>  BSC_BIS_MEASURE_PUB.c_BSC
      ,p_Dataset_Name                =>  p_measure_name
      ,p_Dataset_Help                =>  p_measure_description
      ,p_Dataset_Measure_Id1         =>  l_Bsc_Measure_Id
      ,p_Dataset_Operation           =>  NULL
      ,p_Dataset_Measure_Id2         =>  NULL
      ,p_Dataset_Format_Id           =>  p_dataset_format_id
      ,p_Dataset_Color_Method        =>  NULL
      ,p_Dataset_Autoscale_Flag      =>  p_dataset_autoscale_flag
      ,p_Dataset_Projection_Flag     =>  NULL
      ,p_Measure_Short_Name          =>  p_measure_short_name
      ,p_Measure_Act_Data_Src_Type   =>  'AK'
      ,p_Measure_Act_Data_Src        =>  l_Region_Code || '.' || p_measure_short_name
      ,p_Measure_Comparison_Source   =>  NULL
      ,p_Measure_Operation           =>  p_measure_operation
      ,p_Measure_Uom_Class           =>  NULL
      ,p_Measure_Increase_In_Measure =>  p_measure_increase_in_measure
      ,p_Measure_Random_Style        =>  p_measure_random_style
      ,p_Measure_Min_Act_Value       =>  p_measure_min_act_value
      ,p_Measure_Max_Act_Value       =>  p_measure_max_act_value
      ,p_Measure_Min_Bud_Value       =>  NULL
      ,p_Measure_Max_Bud_Value       =>  NULL
      ,p_Measure_App_Id              =>  p_Measure_App_Id
      ,p_Measure_Col                 =>  NULL
      ,p_Measure_Group_Id            =>  NULL
      ,p_Measure_Projection_Id       =>  BSC_BIS_KPI_CRUD_PUB.C_NO_PROJECTION
      ,p_Measure_Type                =>  p_measure_type
      ,p_Measure_Apply_Rollup        =>  NULL
      ,p_Measure_Function_Name       =>  l_Region_Code
      ,p_Measure_Enable_Link         =>  'Y'
      ,p_Time_Stamp                  =>  NULL
      ,p_Dimension1_Id               =>  x_all_dim_group_ids(1)
      ,p_Dimension2_Id               =>  x_all_dim_group_ids(2)
      ,p_Dimension3_Id               =>  x_all_dim_group_ids(3)
      ,p_Dimension4_Id               =>  x_all_dim_group_ids(4)
      ,p_Dimension5_Id               =>  x_all_dim_group_ids(5)
      ,p_Dimension6_Id               =>  x_all_dim_group_ids(6)
      ,p_Dimension7_Id               =>  x_all_dim_group_ids(7)
      ,p_Y_Axis_Title                =>  NULL
      ,p_func_area_short_name        =>  p_Func_Area_Short_Name
      ,x_Return_Status               =>  x_return_status
      ,x_Msg_Count                   =>  x_msg_count
      ,x_Msg_Data                    =>  x_msg_data
    );

    IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;



    --DBMS_OUTPUT.PUT_LINE('Outside Update_Kpi_Analysis_Option' );
    BSC_BIS_KPI_CRUD_PUB.Update_Kpi_Analysis_Option(
           p_Commit               => p_Commit
          ,p_Kpi_Id               => l_Kpi_Id
          ,p_Dataset_Id           => l_Dataset_Id
          ,p_Measure_Name         => p_Measure_Name
          ,p_Measure_Description  => p_Measure_Description
          ,x_return_status        => x_return_status
          ,x_msg_count            => x_msg_count
          ,x_msg_data             => x_msg_data
    );

    IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
        -- debug
        FND_MESSAGE.SET_NAME('BSC','BSC_ANA_OPT_NO_UPD_DEL');
        FND_MESSAGE.SET_TOKEN('ACTION', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON','UPDATE'));
        FND_MESSAGE.SET_TOKEN('KPI', l_Kpi_Id);
        FND_MESSAGE.SET_TOKEN('DATASET_ID', l_Dataset_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -------------------------------------------------------
    ----- BSC and BIS tables


    -- IF Analysis_Option is passed as NULL, the lower APIs
    -- ASSUME that the format of the Region Code is of the format
    -- BSC_<KPIID>, else BSC_<KPIID>_<AO> is calculated.

    BSC_BIS_KPI_CRUD_PUB.Update_Measure_Region_Item(
          p_commit                 => p_commit,
          p_measure_short_name     => p_measure_short_name,
          p_sequence_number        => l_sequence,
          p_kpi_id                 => l_Kpi_Id,
          p_Analysis_Option        => l_Analysis_Option_Id,
          p_dataset_format_id      => p_dataset_format_id,
          p_dataset_autoscale_flag => p_dataset_autoscale_flag,
          p_Analysis_Option_Name   => p_Measure_Name,
          x_return_status          => x_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_BIS_KPI_CRUD_PUB.Update_Addl_Ak_Region_Items(
          p_commit                 => p_commit
        , p_Region_Code            => l_Region_Code
        , p_Region_Application_Id  => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
        , p_Display_Format         => Get_Format_Mask(p_Dataset_Format_Id)
        , p_Format_Id              => p_Dataset_Format_Id
        , p_Measure_Short_Name     => p_measure_short_name
        , x_return_status          => x_return_status
        , x_msg_count              => x_msg_count
        , x_msg_data                => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Changed p_Disable_View_By = 'N' for Bug#3844823

    -- Do not update Region if the region is not in the format BSC_<KPI>_<AO>
    -- The Measures exists under the same AK Region (common Dimensions)
    IF (l_Analysis_Option_Id IS NOT NULL AND (l_Analysis_Option_Id <> -1)) THEN
        BSC_BIS_KPI_CRUD_PUB.Update_Region_By_AO (
              p_Commit                 => p_Commit
            , p_Kpi_Id                 => l_Kpi_Id
            , p_Analysis_Option_Id     => l_Analysis_Option_Id
            , p_Dim_Set_Id             => 0
            , p_Region_Name            => p_Measure_Name
            , p_Region_Description     => p_Measure_Description
            , p_Region_Application_Id  => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID -- BSC
            , p_Disable_View_By        => 'N'
            , x_return_status          => x_return_status
            , x_msg_count              => x_msg_count
            , x_msg_data               => x_msg_data
        )  ;
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- added for Bug#3844849
        l_Form_Parameters := 'pForceRun=Y' || '&' || 'pRegionCode=' || l_Region_Code
                         || '&' || 'pFunctionName=' || l_Region_Code
                 || '&' || 'pParameters=pParamIds@Y';

        FND_FORM_FUNCTIONS_PKG.UPDATE_ROW
        (
           X_FUNCTION_ID            => BSC_BIS_KPI_CRUD_PUB.Get_Function_Id_By_Name(l_Region_Code)
          ,X_WEB_HOST_NAME          => ''
          ,X_WEB_AGENT_NAME         => ''
          ,X_WEB_HTML_CALL          => BSC_BIS_KPI_CRUD_PUB.c_bisreportpg
          ,X_WEB_ENCRYPT_PARAMETERS => 'N'
          ,X_WEB_SECURED            => 'N'
          ,X_WEB_ICON               => ''
          ,X_OBJECT_ID              => NULL
          ,X_REGION_APPLICATION_ID  => NULL
          ,X_REGION_CODE            => ''
          ,X_FUNCTION_NAME          => l_Region_Code
          ,X_APPLICATION_ID         => NULL
          ,X_FORM_ID                => NULL
          ,X_PARAMETERS             => l_Form_Parameters
          ,X_TYPE                   => 'JSP'
          ,X_USER_FUNCTION_NAME     => p_Measure_Name
          ,X_DESCRIPTION            => p_Measure_Description
          ,X_LAST_UPDATE_DATE       => SYSDATE
          ,X_LAST_UPDATED_BY        => FND_GLOBAL.USER_ID
          ,X_LAST_UPDATE_LOGIN      => FND_GLOBAL.LOGIN_ID
        );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        ROLLBACK TO UpdateEndToEndKPI;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO UpdateEndToEndKPI;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Update_Kpi_End_To_End ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Update_Kpi_End_To_End ';
        END IF;
        ROLLBACK TO UpdateEndToEndKPI;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Update_Kpi_End_To_End ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Update_Kpi_End_To_End ';
        END IF;
        ROLLBACK TO UpdateEndToEndKPI;
END Update_Kpi_End_To_End;


/*

  Start the DELETE APIs from here on.

*/


PROCEDURE Delete_Kpi_End_To_End(
      p_Commit                      IN         VARCHAR2 := FND_API.G_FALSE
     ,p_Param_Portlet_Region_Code   IN         VARCHAR2
     ,p_Measure_Short_Name          IN         VARCHAR2 := NULL
     ,p_Page_Function_Name          IN         VARCHAR2
     ,p_Kpi_Portlet_Function_Name   IN         VARCHAR2
     ,x_Return_Status               OUT NOCOPY VARCHAR2
     ,x_Msg_Count                   OUT NOCOPY NUMBER
     ,x_Msg_Data                    OUT NOCOPY VARCHAR2
) IS
  l_Dataset_Source                  VARCHAR2(10) := NULL;
  l_Dataset_Id                      NUMBER;
  l_Does_Dim_Group_Exist            BOOLEAN;
  l_Does_Kpi_Exist                  BOOLEAN;
  l_Tab_Id                          NUMBER;
  l_Kpi_Group_Id                    NUMBER;
  l_Kpi_Id                          NUMBER;
  l_Real_Kpi_Name                   BSC_KPIS_VL.NAME%TYPE;
  l_Fid                             NUMBER;
  l_Rowid                           ROWID;
  l_form_parameters                 VARCHAR2(32000);
  l_max_seq_number                  NUMBER;
  l_sequence                        NUMBER := 10;
  l_report_region_rec               BIS_AK_REGION_PUB.Bis_Region_Rec_Type;
  l_Region_Code                     VARCHAR2(30);
  l_Analysis_Option_Id              NUMBER;
  l_Count                           NUMBER;
  l_Last_Analysis_Option            NUMBER;

  l_Parameter_Portlet               VARCHAR2(30);

BEGIN

  -- Load local variables.
    SAVEPOINT DeleteEndToEndKPI;

    FND_MSG_PUB.Initialize;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;


    IF (p_Param_Portlet_Region_Code IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_PARAM_PORTLET');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- should take l_kpi_id from the measure_short_name only and not from
    -- the Page function name. Bug#3766839
    l_Kpi_Id       := NVL(BSC_BIS_KPI_CRUD_PUB.Get_Objective_By_Kpi(p_Measure_Short_Name),
                          BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY);
    l_Dataset_Id   := BSC_BIS_KPI_CRUD_PUB.Get_Dataset_Id(p_Measure_Short_Name);

    -- If the KPI has been deleted, throw a valid message

    SELECT COUNT(1) INTO l_Count
    FROM   BSC_SYS_DATASETS_B
    WHERE  DATASET_ID = l_Dataset_Id;
    IF l_count = 0 THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON','EDW_MEASURE'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT COUNT(1) INTO l_Count
    FROM   BSC_KPIS_B
    WHERE  INDICATOR = l_Kpi_Id;
    IF l_count = 0 THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON','KPI'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('Get_Num_Measures_By_Kpi -> ' || Get_Num_Measures_By_Kpi(l_Kpi_Id));

    IF(BSC_BIS_KPI_CRUD_PUB.Get_Num_Measures_By_Kpi(l_Kpi_Id) > 1) THEN
        -- Start deleting the PMV/AK Metadata
        -- Delete the Measure Metadata
        -- IF the Measure has its own AK Region, we need to delete it.
        IF(has_Measure_AK_Region(l_Kpi_Id, l_Dataset_Id)) THEN
          l_Analysis_Option_Id := Get_AO_Id_By_Measure (l_Kpi_Id, l_Dataset_Id);
          l_Region_Code        := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Region_Code(l_Kpi_Id, l_Analysis_Option_Id);


          -- Need to find out Param Portlet before AK is deleted
          l_Parameter_Portlet  := BSC_BIS_KPI_CRUD_PUB.Get_Param_Portlet_By_Region(l_Region_Code);

          -- Deletes all the AK Metadata Related to the Analysis Option
          BSC_BIS_KPI_CRUD_PUB.Delete_AK_Metadata(
                p_Commit                     => p_Commit
              , p_Region_Code                => l_Region_Code
              , p_Region_Code_Application_Id => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
              , x_Return_Status              => x_Return_Status
              , x_Msg_Count                  => x_Msg_Count
              , x_Msg_Data                   => x_Msg_Data
          );
          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

        ELSE     -- If the Analysis Option does not have its own AK Region
            l_Region_Code := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Region_Code(l_Kpi_Id, NULL);

            -- Need to find out Param Portlet before AK is deleted
            l_Parameter_Portlet  := BSC_BIS_KPI_CRUD_PUB.Get_Param_Portlet_By_Region(l_Region_Code);

            BSC_BIS_KPI_CRUD_PUB.Delete_Measure_Region_Item(
               p_Commit                    =>  p_commit
              ,p_Param_Portlet_Region_Code =>  l_Region_Code
              ,p_Measure_Short_Name        =>  p_Measure_Short_Name
              ,p_Application_Id            =>  BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID -- BSC
              ,x_return_status             =>  x_return_status
              ,x_msg_count                 =>  x_msg_count
              ,x_msg_data                  =>  x_msg_data
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;


        BSC_BIS_KPI_CRUD_PUB.Unassign_Kpi_Analysis_Option (
           p_Commit         => p_commit
          ,p_Kpi_Id         => l_kpi_Id
          ,p_Dataset_Id     => l_Dataset_Id
          ,x_return_status  => x_return_status
          ,x_msg_count      => x_msg_count
          ,x_msg_data       => x_msg_data
        );

        IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_ANA_OPT_NO_UPD_DEL');
            FND_MESSAGE.SET_TOKEN('ACTION', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON','UPDATE'));
            FND_MESSAGE.SET_TOKEN('KPI',  l_kpi_Id);
            FND_MESSAGE.SET_TOKEN('DATASET_ID',  l_Dataset_Id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        -- Delete the Measure from the DB (BSC and BIS).

        BSC_BIS_MEASURE_PUB.Delete_Measure(
           p_Commit         => p_commit
          ,p_Dataset_Id     => l_Dataset_Id
          ,x_return_status  => x_return_status
          ,x_msg_count      => x_msg_count
          ,x_msg_data       => x_msg_data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        SELECT NVL(MAX(ANALYSIS_OPTION0), 0)
        INTO   l_Last_Analysis_Option
        FROM   BSC_KPI_ANALYSIS_MEASURES_B
        WHERE  INDICATOR = l_kpi_Id;

        IF(l_Analysis_Option_Id <= l_Last_Analysis_Option) THEN
            BSC_BIS_KPI_CRUD_PUB.Referesh_AK_Metadata (
                    p_Commit                    => p_Commit
                  , p_Kpi_Id                    => l_Kpi_Id
                  , p_Deleted_AO_Index          => l_Analysis_Option_Id
                  , p_Param_Portlet_Region_Code => l_Parameter_Portlet
                  , x_Return_Status             => x_Return_Status
                  , x_Msg_Count                 => x_Msg_Count
                  , x_Msg_Data                  => x_Msg_Data
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

    ELSE -- End - IF NOT Get_Num_Measures_By_Kpi > 1 (delete all the KPI Metatada and Regions)

        -- Start deleting the PMV/AK Metadata
        -- Delete the Measure Metadata
        --DBMS_OUTPUT.PUT_LINE('Outside Delete_Measure_Region_Item' );
        IF(has_Measure_AK_Region(l_Kpi_Id, l_Dataset_Id)) THEN
          l_Analysis_Option_Id := Get_AO_Id_By_Measure (l_Kpi_Id, l_Dataset_Id);
          l_Region_Code := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Region_Code(l_Kpi_Id, l_Analysis_Option_Id);
        ELSE
          l_Region_Code := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Region_Code(l_Kpi_Id, NULL); -- Tyep BSC_<KPIID>
        END IF;

        BSC_BIS_KPI_CRUD_PUB.Delete_AK_Metadata(
              p_Commit                     => p_Commit
            , p_Region_Code                => l_Region_Code
            , p_Region_Code_Application_Id => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
            , x_Return_Status              => x_Return_Status
            , x_Msg_Count                  => x_Msg_Count
            , x_Msg_Data                   => x_Msg_Data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        /*
          At this point, Delete ALL the KPI Metadata and info related to the KPI.
        */
        --DBMS_OUTPUT.PUT_LINE('Outside BSC_PMF_UI_WRAPPER.Delete_Kpi' );
        --DBMS_OUTPUT.PUT_LINE('Outside FND_FORM_FUNCTIONS_PKG.DELETE_ROW ' );
        BSC_PMF_UI_WRAPPER.Delete_Kpi(
              p_commit          =>  p_commit
             ,p_Kpi_Id          =>  l_Kpi_Id
             ,x_Return_Status   =>  x_Return_Status
             ,x_Msg_Count       =>  x_Msg_Count
             ,x_Msg_Data        =>  x_Msg_Data
        );
        IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('Outside FND_FORM_FUNCTIONS_PKG.DELETE_ROW ' );

        -- Delete the Actual Measure from BSC and BIS Datamodel.
        --DBMS_OUTPUT.PUT_LINE('Outside BSC_BIS_MEASURE_PUB.Delete_Measure ' );
        BSC_BIS_MEASURE_PUB.Delete_Measure(
           p_Commit         => p_Commit
          ,p_Dataset_Id     => l_Dataset_Id
          ,x_return_status  => x_return_status
          ,x_msg_count      => x_msg_count
          ,x_msg_data       => x_msg_data
        );
        IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_Parameter_Portlet  := BSC_BIS_KPI_CRUD_PUB.Get_Param_Portlet_By_Region(l_Region_Code);

        -- parameter was dynamically created - so delete it and its region/region items
        -- added for Bug#4558279
        IF (p_Param_Portlet_Region_Code <> l_Parameter_Portlet) THEN
            BSC_BIS_KPI_CRUD_PUB.Delete_AK_Metadata(
                  p_Commit                     => p_Commit
                , p_Region_Code                => l_Parameter_Portlet
                , p_Region_Code_Application_Id => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
                , x_Return_Status              => x_Return_Status
                , x_Msg_Count                  => x_Msg_Count
                , x_Msg_Data                   => x_Msg_Data
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;


            BSC_BIS_DIMENSION_PUB.Delete_Dimension
            (       p_commit          => p_Commit
                ,   p_dim_short_name  => l_Parameter_Portlet
                ,   x_return_status   => x_Return_Status
                ,   x_msg_count       => x_Msg_Count
                ,   x_msg_data        => x_Msg_Data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;


    END IF;   -- End - Get_Num_Measures_By_Kpi
    --DBMS_OUTPUT.PUT_LINE('End of Delete_Kpi_End_To_End' );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        ROLLBACK TO DeleteEndToEndKPI;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO DeleteEndToEndKPI;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Delete_Kpi_End_To_End ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Delete_Kpi_End_To_End ';
        END IF;
        ROLLBACK TO DeleteEndToEndKPI;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Delete_Kpi_End_To_End ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Delete_Kpi_End_To_End ';
        END IF;
        ROLLBACK TO DeleteEndToEndKPI;
END Delete_Kpi_End_To_End;




PROCEDURE Get_Dim_Info_From_Region_Code(
        p_param_portlet_region_code    IN         VARCHAR2
       ,x_non_time_dimension_groups    OUT NOCOPY BSC_VARCHAR2_TBL_TYPE
       ,x_non_time_dimension_objects   OUT NOCOPY BSC_VARCHAR2_TBL_TYPE
       ,x_non_time_dim_obj_short_names OUT NOCOPY VARCHAR2
       ,x_all_dim_group_ids            OUT NOCOPY BSC_NUMBER_TBL_TYPE
       ,x_non_time_counter             OUT NOCOPY NUMBER
       ,x_time_dimension_groups        OUT NOCOPY BSC_VARCHAR2_TBL_TYPE
       ,x_time_dimension_objects       OUT NOCOPY BSC_VARCHAR2_TBL_TYPE
       ,x_time_dim_obj_short_names     OUT NOCOPY VARCHAR2
       ,x_time_counter                 OUT NOCOPY NUMBER
       ,x_msg_data                     OUT NOCOPY VARCHAR2
) IS

  l_ak_attr2          VARCHAR2(2000);
  l_display_sequence  NUMBER;
  l_dimension_grp     bsc_varchar2_tbl_type;
  l_dimension_object  bsc_varchar2_tbl_type;
  l_counter           NUMBER := 1;
  l_dimension_grp_id  NUMBER;
  l_msg_count         NUMBER;
  l_Dim_Id_Cnt        NUMBER;


  -- attribute2 stores dim+dim obj
  CURSOR c_dim(p_region_code varchar2) IS
   SELECT   DISTINCT a.attribute2, a.display_sequence
   FROM     ak_region_items a
   WHERE    a.region_code = p_region_code
   AND      ATTRIBUTE1  IN ('DIMENSION LEVEL',
              'DIM LEVEL SINGLE VALUE',
              'DIMENSION VALUE',
              'HIDE_VIEW_BY',
              'HIDE_VIEW_BY_SINGLE',
              'HIDE PARAMETER',
              'VIEWBY PARAMETER',
              'HIDE_DIM_LVL',
              'HIDE DIMENSION LEVEL',
              'HIDE VIEW BY DIMENSION',
              'HIDE_VIEW_BY_DIM_SINGLE')
   AND      a.attribute2 LIKE '%+%'
   AND      a.attribute2  NOT LIKE 'TIME_COMPARISON_TYPE%'
   ORDER BY a.display_sequence;

   CURSOR c_DimId IS
      SELECT a.dimension_id
      FROM   bis_dimensions a
      WHERE  UPPER(a.short_name) = UPPER(l_dimension_grp(l_counter));

BEGIN

  x_non_time_dim_obj_short_names := NULL;
  x_non_time_counter := 1;
  x_time_counter := 1;
  l_Dim_Id_Cnt   := 0;

  x_all_dim_group_ids(1) := NULL;
  x_all_dim_group_ids(2) := NULL;
  x_all_dim_group_ids(3) := NULL;
  x_all_dim_group_ids(4) := NULL;
  x_all_dim_group_ids(5) := NULL;
  x_all_dim_group_ids(6) := NULL;
  x_all_dim_group_ids(7) := NULL;

  IF c_Dim%ISOPEN THEN
    CLOSE c_Dim;
  END IF;

  OPEN c_dim(p_param_portlet_region_code);

  LOOP

   FETCH c_dim INTO l_ak_attr2, l_display_sequence; --HRI_PERSON+HRI_PER_USRDR_H
   EXIT WHEN c_dim%NOTFOUND;
   l_dimension_grp(l_counter) := substr(l_ak_attr2, 1, instr(l_ak_attr2,'+')-1);
   l_dimension_object(l_counter) := substr(l_ak_attr2, instr(l_ak_attr2,'+')+1);

   IF ((l_dimension_grp(l_counter) <> BSC_BIS_KPI_CRUD_PUB.c_oltp_time) AND
       (l_dimension_grp(l_counter) <> BSC_BIS_KPI_CRUD_PUB.c_edw_time)) THEN

      x_non_time_dimension_groups(x_non_time_counter) := l_dimension_grp(l_counter);
      x_non_time_dimension_objects(x_non_time_counter) := l_dimension_object(l_counter);

      -- concatenate non time dimension object short name
      IF (x_non_time_dim_obj_short_names IS NULL) THEN
         x_non_time_dim_obj_short_names := l_dimension_object(l_counter);
      ELSE
         x_non_time_dim_obj_short_names := x_non_time_dim_obj_short_names || ',' || l_dimension_object(l_counter);
      END IF;
      x_non_time_counter := x_non_time_counter + 1;

   ELSE
      -- for time dimension
      x_time_dimension_groups(x_time_counter) := l_dimension_grp(l_counter);
      x_time_dimension_objects(x_time_counter) := l_dimension_object(l_counter);
      x_time_counter := x_time_counter + 1;
      -- concatenate time dimension object short name
      IF (x_time_dim_obj_short_names IS NULL) THEN
         x_time_dim_obj_short_names := l_dimension_object(l_counter);
      ELSE
         x_time_dim_obj_short_names := x_time_dim_obj_short_names || ',' || l_dimension_object(l_counter);
      END IF;

   END IF;

   FOR cDimId IN c_DimId LOOP
     l_dimension_grp_id := cDimId.DIMENSION_ID;
     l_Dim_Id_Cnt := l_Dim_Id_Cnt + 1;
   END LOOP;

   IF l_Dim_Id_Cnt <> 1 THEN
     FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_SHORT_NAME');
     FND_MESSAGE.SET_TOKEN('BSC_GROUP_SHORT_NAME', l_dimension_grp(l_counter), TRUE);
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_Dim_Id_Cnt := 0;

   x_all_dim_group_ids(l_counter) := l_dimension_grp_id;

   l_counter := l_counter + 1;

  END LOOP;

  CLOSE c_dim;

  -- if no dimension set, raise exception
  IF (l_counter = 1) THEN
     FND_MESSAGE.SET_NAME('BSC','BSC_NO_DIM_SET_ASSOC');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- decrement by one to match the actual number of elements
  x_non_time_counter := x_non_time_counter - 1;
  x_time_counter := x_time_counter - 1;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF c_Dim%ISOPEN THEN
           CLOSE c_Dim;
        END IF;

        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF c_Dim%ISOPEN THEN
           CLOSE c_Dim;
        END IF;

        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

    WHEN NO_DATA_FOUND THEN
        IF c_Dim%ISOPEN THEN
           CLOSE c_Dim;
        END IF;

        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Get_Dim_Info_From_Region_Code ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Get_Dim_Info_From_Region_Code ';
        END IF;
    WHEN OTHERS THEN
        IF c_Dim%ISOPEN THEN
           CLOSE c_Dim;
        END IF;

        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Get_Dim_Info_From_Region_Code ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Get_Dim_Info_From_Region_Code ';
        END IF;

END Get_Dim_Info_From_Region_Code;




PROCEDURE Create_Dim_Level_Region_Item(
      p_commit                               VARCHAR2 := FND_API.G_FALSE
     ,p_non_time_counter                     NUMBER
     ,p_non_time_dimension_objects           bsc_varchar2_tbl_type
     ,p_non_time_dimension_groups            bsc_varchar2_tbl_type
     ,p_time_counter                         NUMBER
     ,p_time_dimension_objects               bsc_varchar2_tbl_type
     ,p_time_dimension_groups                bsc_varchar2_tbl_type
     ,p_kpi_id                               NUMBER
     ,p_Analysis_Option                      NUMBER  := NULL
     ,x_sequence                      IN OUT NOCOPY NUMBER
     ,x_return_status                 OUT    NOCOPY VARCHAR2
     ,x_msg_count                     OUT    NOCOPY NUMBER
     ,x_msg_data                      OUT    NOCOPY VARCHAR2)
IS

      l_dim                        NUMBER;
      l_region_item_table_dim_set  BIS_AK_REGION_PUB.Bis_Region_Item_Tbl_Type;
      l_region_item_rec            BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type;
      l_real_counter               NUMBER := 1;
      l_Region_Code                VARCHAR2(80);

BEGIN


    FOR l_dim IN 1..p_non_time_counter LOOP


      l_region_item_rec.Attribute_Code := p_non_time_dimension_objects(l_dim);
      l_region_item_rec.Attribute_Application_Id := BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID;
      l_region_item_rec.Display_Sequence := x_sequence;
      l_region_item_rec.Node_Display_Flag := ' ';
      l_region_item_rec.Required_Flag := ' ';
      l_region_item_rec.Queryable_Flag := 'Y';
      l_region_item_rec.Display_Length := 0;
      l_region_item_rec.Long_Label := p_non_time_dimension_objects(l_dim);
      l_region_item_rec.Sort_Sequence := NULL;
      l_region_item_rec.Initial_Sort_Sequence := NULL;
      l_region_item_rec.Sort_Direction := NULL;
      l_region_item_rec.Url := NULL;
      l_region_item_rec.Attribute_Type := 'DIMENSION LEVEL';
      l_region_item_rec.Display_Format := NULL;
      l_region_item_rec.Display_Type := NULL;
      l_region_item_rec.Measure_Level := p_non_time_dimension_groups(l_dim) || '+' || p_non_time_dimension_objects(l_dim);
      l_region_item_rec.Base_Column := NULL;
      l_region_item_rec.Lov_Where_Clause := NULL;
      l_region_item_rec.Graph_Position := NULL;
      l_region_item_rec.Graph_Style := NULL;
      l_region_item_rec.Lov_Table := NULL;
      l_region_item_rec.Aggregate_Function := NULL;
      l_region_item_rec.Display_Total := NULL;
      l_region_item_rec.Variance := NULL;
      l_region_item_rec.Schedule := NULL;
      l_region_item_rec.Override_Hierarchy := NULL;
      l_region_item_rec.Additional_View_By := NULL;
      l_region_item_rec.Rolling_Lookup := NULL;
      l_region_item_rec.Operator_Lookup := NULL;
      l_region_item_rec.Dual_YAxis_Graphs := NULL;
      l_region_item_rec.Custom_View_Name := NULL;
      l_region_item_rec.Graph_Measure_Type := NULL;
      l_region_item_rec.Hide_Target_In_Table := NULL;
      l_region_item_rec.Parameter_Render_Type := NULL;
      l_region_item_rec.Privilege := NULL;

      l_region_item_table_dim_set(l_real_counter) := l_region_item_rec;
      l_real_counter := l_real_counter + 1;
      x_sequence := x_sequence + 10;

    END LOOP;


    FOR l_dim IN 1..p_time_counter LOOP


      l_region_item_rec.Attribute_Code := p_time_dimension_objects(l_dim);
      l_region_item_rec.Attribute_Application_Id := BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID;
      l_region_item_rec.Display_Sequence := x_sequence;
      l_region_item_rec.Node_Display_Flag := ' ';
      l_region_item_rec.Required_Flag := ' ';
      l_region_item_rec.Queryable_Flag := 'Y';
      l_region_item_rec.Display_Length := 0;
      l_region_item_rec.Long_Label := p_time_dimension_objects(l_dim);
      l_region_item_rec.Sort_Sequence := NULL;
      l_region_item_rec.Initial_Sort_Sequence := NULL;
      l_region_item_rec.Sort_Direction := NULL;
      l_region_item_rec.Url := NULL;
      l_region_item_rec.Attribute_Type := 'DIMENSION LEVEL';
      l_region_item_rec.Display_Format := NULL;
      l_region_item_rec.Display_Type := NULL;
      l_region_item_rec.Measure_Level := p_time_dimension_groups(l_dim) || '+' || p_time_dimension_objects(l_dim);
      l_region_item_rec.Base_Column := NULL;
      l_region_item_rec.Lov_Where_Clause := NULL;
      l_region_item_rec.Graph_Position := NULL;
      l_region_item_rec.Graph_Style := NULL;
      l_region_item_rec.Lov_Table := NULL;
      l_region_item_rec.Aggregate_Function := NULL;
      l_region_item_rec.Display_Total := NULL;
      l_region_item_rec.Variance := NULL;
      l_region_item_rec.Schedule := NULL;
      l_region_item_rec.Override_Hierarchy := NULL;
      l_region_item_rec.Additional_View_By := NULL;
      l_region_item_rec.Rolling_Lookup := NULL;
      l_region_item_rec.Operator_Lookup := NULL;
      l_region_item_rec.Dual_YAxis_Graphs := NULL;
      l_region_item_rec.Custom_View_Name := NULL;
      l_region_item_rec.Graph_Measure_Type := NULL;
      l_region_item_rec.Hide_Target_In_Table := NULL;
      l_region_item_rec.Parameter_Render_Type := NULL;
      l_region_item_rec.Privilege := NULL;

      l_region_item_table_dim_set(l_real_counter) := l_region_item_rec;
      l_real_counter := l_real_counter + 1;
      x_sequence := x_sequence + 10;

    END LOOP;

    l_Region_Code := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Region_Code(
                         p_Kpi_Id => p_kpi_id,
                         p_AO_Id => p_Analysis_Option
                     );


    BIS_PMV_REGION_ITEMS_PVT.CREATE_REGION_ITEMS
    (
                       p_commit                 => p_commit
                      ,p_region_code            => l_Region_Code
                      ,p_region_application_id  => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
                      ,p_Region_Item_Tbl        => l_region_item_table_dim_set
                      ,x_return_status          => x_return_status
                      ,x_msg_count              => x_msg_count
                      ,x_msg_data               => x_msg_data
    );

--DBMS_OUTPUT.PUT_LINE('region_code  = ' || BSC_UTILITY.C_BSC_UNDERSCORE || p_kpi_id);
--DBMS_OUTPUT.PUT_LINE('return_status_for dim_ak_region_item = ' || x_return_status);

END Create_Dim_Level_Region_Item;





PROCEDURE Create_Measure(
      p_commit                        VARCHAR2 := FND_API.G_FALSE
     ,x_dataset_id                    OUT NOCOPY NUMBER
     ,p_kpi_id                        NUMBER
     ,p_dataset_source                VARCHAR2
     ,p_measure_name                  VARCHAR2
     ,p_measure_short_name            VARCHAR2
     ,p_measure_description           VARCHAR2
     ,p_dataset_format_id             NUMBER
     ,p_dataset_autoscale_flag        NUMBER
     ,p_measure_operation             VARCHAR2
     ,p_measure_increase_in_measure   VARCHAR2
     ,p_measure_obsolete              VARCHAR2 := FND_API.G_FALSE
     ,p_type                          VARCHAR2 -- This is used for weighted kpis,This can take values CDS_SCORE,CDS_PERF or Null
     ,p_measure_random_style          NUMBER
     ,p_measure_min_act_value         NUMBER
     ,p_measure_max_act_value         NUMBER
     ,p_measure_type                  NUMBER
     ,p_measure_function_name         VARCHAR2
     ,p_measure_group_id              NUMBER
     ,p_dimension1_id                 NUMBER
     ,p_dimension2_id                 NUMBER
     ,p_dimension3_id                 NUMBER
     ,p_dimension4_id                 NUMBER
     ,p_dimension5_id                 NUMBER
     ,p_dimension6_id                 NUMBER
     ,p_dimension7_id                 NUMBER
     ,p_Measure_App_Id                NUMBER := NULL
     ,p_Func_Area_Short_Name          VARCHAR2 := NULL
     ,x_return_status                 OUT NOCOPY VARCHAR2
     ,x_msg_count                     OUT NOCOPY NUMBER
     ,x_msg_data                      OUT NOCOPY VARCHAR2
)
IS

    l_actual_data_source    VARCHAR2(1000) := NULL;
    l_measure_short_name    VARCHAR2(100);

BEGIN

    --DBMS_OUTPUT.PUT_LINE('STAGE 8B1');


    SAVEPOINT CreateMeasureSP;
    FND_MSG_PUB.Initialize;
    x_Return_Status  := FND_API.G_RET_STS_SUCCESS;

    --DBMS_OUTPUT.PUT_LINE('STAGE 8B1');

    -- added exception handling for Bug#3755656
    BSC_BIS_MEASURE_PUB.Create_Measure(
                  p_commit => p_commit
                 ,x_dataset_id => x_dataset_id
                 ,p_dataset_source => p_dataset_source --'BSC' data source
                 ,p_dataset_name => p_measure_name
                 ,p_dataset_help => p_measure_description
                 ,p_dataset_measure_id1 => NULL
                 ,p_dataset_operation => NULL
                 ,p_dataset_measure_id2 => NULL
                 ,p_dataset_format_id => p_dataset_format_id
                 ,p_dataset_color_method => NULL
                 ,p_dataset_autoscale_flag => p_dataset_autoscale_flag
                 ,p_dataset_projection_flag => NULL
                 ,p_measure_short_name => p_measure_short_name
                 ,p_measure_act_data_src_type => NULL
                 --,p_measure_act_data_src => l_actual_data_source
                 ,p_measure_act_data_src => NULL
                 ,p_measure_comparison_source => NULL
                 ,p_measure_operation => p_measure_operation
                 ,p_measure_uom_class => NULL
                 ,p_measure_increase_in_measure => p_measure_increase_in_measure
                 ,p_measure_random_style => p_measure_random_style
                 ,p_measure_min_act_value => p_measure_min_act_value
                 ,p_measure_max_act_value => p_measure_max_act_value
                 ,p_measure_min_bud_value => NULL
                 ,p_measure_max_bud_value => NULL
                 ,p_measure_app_id => p_Measure_App_Id
                 ,p_measure_col => NULL
                 ,p_measure_group_id => p_measure_group_id
                 ,p_measure_projection_id => BSC_BIS_KPI_CRUD_PUB.C_NO_PROJECTION
                 ,p_measure_type => p_measure_type
                 ,p_measure_apply_rollup => NULL
                 ,p_measure_function_name => p_measure_function_name
                 ,p_measure_enable_link => 'N'
                 ,p_measure_obsolete => p_measure_obsolete
         ,p_type => p_type
                 ,p_dimension1_id => p_dimension1_id
                 ,p_dimension2_id => p_dimension2_id
                 ,p_dimension3_id => p_dimension3_id
                 ,p_dimension4_id => p_dimension4_id
                 ,p_dimension5_id => p_dimension5_id
                 ,p_dimension6_id => p_dimension6_id
                 ,p_dimension7_id => p_dimension7_id
                 ,p_y_axis_title => NULL
                 ,p_func_area_short_name => p_Func_Area_Short_Name
                 ,x_return_status => x_return_status
                 ,x_msg_count => x_msg_count
                 ,x_msg_data => x_msg_data);
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('STAGE 8B2 - ' || x_dataset_id);
    --DBMS_OUTPUT.PUT_LINE('STAGE 8B3 - ' || p_measure_short_name);
    --use the sql statement to get the measure_short_name out.


    IF (p_measure_short_name IS NULL) THEN
      SELECT a.short_name
      INTO l_measure_short_name
      FROM bsc_sys_measures a
      WHERE a.measure_id =
        (SELECT b.measure_id1
         FROM bsc_sys_datasets_b b
         WHERE b.dataset_id = x_dataset_id);


    END IF;
    --DBMS_OUTPUT.PUT_LINE('STAGE 8B4 - ' || l_measure_short_name);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateMeasureSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateMeasureSP;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateMeasureSP;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Create_Measure ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Create_Measure ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CreateMeasureSP;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Create_Measure ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Create_Measure ';
        END IF;
END Create_Measure;


PROCEDURE Associate_KPI_To_AO(
      p_Commit                        VARCHAR2 := FND_API.G_FALSE
     ,p_Indicator                     NUMBER
     ,p_Dataset_Id                    NUMBER
     ,p_Measure_Name                  VARCHAR2
     ,p_Measure_Description           VARCHAR2
     ,x_Measure_Short_Name            OUT NOCOPY VARCHAR2
     ,x_Return_Status                 OUT NOCOPY VARCHAR2
     ,x_Msg_Count                     OUT NOCOPY NUMBER
     ,x_Msg_Data                      OUT NOCOPY VARCHAR2)
IS

    l_Measure_Short_Name    VARCHAR2(1000);
    l_Region_Code           AK_REGIONS.REGION_CODE%TYPE;


BEGIN
    SAVEPOINT AssociateKPIToAO;
    FND_MSG_PUB.Initialize;
    x_Return_Status  := FND_API.G_RET_STS_SUCCESS;

    SELECT A.SHORT_NAME
    INTO   l_Measure_Short_Name
    FROM   BSC_SYS_MEASURES A
    WHERE A.MEASURE_ID =
      (SELECT B.MEASURE_ID1
       FROM   BSC_SYS_DATASETS_B B
       WHERE  B.DATASET_ID = p_Dataset_Id);

    x_measure_short_name := l_measure_short_name;

    --Call procedure to assign the real measure to the analysis option group.
    -- As of now passing AO Group Id as 0
    l_Region_Code := BSC_BIS_KPI_CRUD_PUB.Get_Next_Region_Code_By_AO(
                                           p_Kpi_Id          => p_Indicator
                                          ,p_Analysis_Group0 => 0
                                        );

    BSC_BIS_KPI_MEAS_PUB.Create_KPI_Analysis_Options(
         p_Commit             => p_Commit
        ,p_Kpi_Id             => p_Indicator
        ,p_Analysis_Group_Id  => 0
        ,p_Data_Set_Id        => p_Dataset_Id
        ,p_Measure_Short_Name => l_Measure_Short_Name
        ,p_Measure_Name       => p_Measure_Name
        ,p_Measure_Help       => p_Measure_Description
        ,p_Time_Stamp         => NULL
        ,p_Short_Name         => l_Region_Code
        ,x_Return_Status      => x_Return_Status
        ,x_Msg_Count          => x_Msg_Count
        ,x_Msg_Data           => x_Msg_Data
     );

    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Currently we need to indentify if the first analysis option will
    -- be replaced by the newly added AO or not, until that is figured out
    -- we call the API Refresh_Short_Names to set the Short_Names in place.

    BSC_ANALYSIS_OPTION_PVT.Refresh_Short_Names
    (
            p_Commit        => p_Commit
          , p_Kpi_Id        => p_Indicator
          , x_Return_Status => x_return_status
          , x_Msg_Count     => x_msg_count
          , x_Msg_Data      => x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO AssociateKPIToAO;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO AssociateKPIToAO;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO AssociateKPIToAO;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Associate_KPI_To_AO ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Associate_KPI_To_AO ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO AssociateKPIToAO;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Associate_KPI_To_AO ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Associate_KPI_To_AO ';
        END IF;
END Associate_KPI_To_AO;


PROCEDURE Create_Measure_Region_Item(
            p_commit                   VARCHAR2,
            p_measure_short_name       VARCHAR2,
            p_sequence_number          NUMBER,
            p_kpi_id                   NUMBER,
            p_Analysis_Option          NUMBER := NULL,
            p_dataset_format_id        NUMBER,
            p_dataset_autoscale_flag   NUMBER,
            p_Analysis_Option_Name     VARCHAR2,
            x_return_status            OUT NOCOPY VARCHAR2,
            x_msg_count                OUT NOCOPY NUMBER,
            x_msg_data                 OUT NOCOPY VARCHAR2
) IS

    l_region_item_rec                BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type;
    l_region_item_table_measure      BIS_AK_REGION_PUB.Bis_Region_Item_Tbl_Type;
    l_Region_Code                    VARCHAR2(80);

BEGIN

    l_Region_Code := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Region_Code(p_Kpi_Id, p_Analysis_Option);

    --DBMS_OUTPUT.PUT_LINE('Create_Measure_Region_Item - region_code  = ' || l_Region_Code);

    l_region_item_rec.Attribute_Code           := p_measure_short_name;
    l_region_item_rec.Attribute_Application_Id := BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID;
    l_region_item_rec.Display_Sequence         := p_sequence_number;
    l_region_item_rec.Node_Display_Flag        := 'Y';
    l_region_item_rec.Required_Flag            := ' ';
    l_region_item_rec.Queryable_Flag           := ' ';
    l_region_item_rec.Display_Length           := length(p_Analysis_Option_Name);
    l_region_item_rec.Long_Label               := p_Analysis_Option_Name;
    l_region_item_rec.Sort_Sequence            := NULL;
    l_region_item_rec.Initial_Sort_Sequence    := NULL;
    l_region_item_rec.Sort_Direction           := NULL;
    l_region_item_rec.Url                      := NULL;
    l_region_item_rec.Attribute_Type           := BSC_BIS_KPI_CRUD_PUB.C_MEASURE_ATTRIBURE_TYPE;
    -- We need to reconvert the format_id to a correct mask
    l_region_item_rec.Display_Format           := Get_Format_Mask(p_dataset_format_id);
    l_region_item_rec.Display_Type             := NULL;
    l_region_item_rec.Measure_Level            := p_measure_short_name;
    l_region_item_rec.Base_Column              := p_kpi_id;
    l_region_item_rec.Lov_Where_Clause         := NULL;
    l_region_item_rec.Graph_Position           := NULL;
    l_region_item_rec.Graph_Style              := NULL;
    l_region_item_rec.Lov_Table                := NULL;
    l_region_item_rec.Aggregate_Function       := NULL;
    l_region_item_rec.Display_Total            := NULL;
    l_region_item_rec.Variance                 := NULL;
    l_region_item_rec.Schedule                 := NULL;
    l_region_item_rec.Override_Hierarchy       := NULL;
    l_region_item_rec.Additional_View_By       := NULL;
    l_region_item_rec.Rolling_Lookup           := NULL;
    l_region_item_rec.Operator_Lookup          := NULL;
    l_region_item_rec.Dual_YAxis_Graphs        := NULL;
    l_region_item_rec.Custom_View_Name         := NULL;
    l_region_item_rec.Graph_Measure_Type       := NULL;
    l_region_item_rec.Hide_Target_In_Table     := NULL;
    l_region_item_rec.Parameter_Render_Type    := NULL;
    l_region_item_rec.Privilege                := NULL;

    l_region_item_table_measure(1) := l_region_item_rec;

    BIS_PMV_REGION_ITEMS_PVT.CREATE_REGION_ITEMS(
        p_commit                 => p_commit
       ,p_region_code            => l_Region_Code
       ,p_region_application_id  => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
       ,p_Region_Item_Tbl        => l_region_item_table_measure
       ,x_return_status          => x_return_status
       ,x_msg_count              => x_msg_count
       ,x_msg_data               => x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


END Create_Measure_Region_Item;


FUNCTION Does_Dim_Grp_Exist(p_param_portlet_region_code VARCHAR2)
RETURN BOOLEAN IS
  l_Has_One_Row   NUMBER;
BEGIN

  SELECT COUNT(1)
  INTO   l_Has_One_Row
  FROM   BSC_SYS_DIM_GROUPS_TL A
  WHERE  A.SHORT_NAME = p_Param_Portlet_Region_Code
  AND    A.LANGUAGE   = USERENV('LANG');

  IF (l_Has_One_Row > 0) THEN
   RETURN TRUE;
  ELSE
   RETURN FALSE;
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN RETURN FALSE;

END Does_Dim_Grp_Exist;


-- Modified API for Bug#3766260

FUNCTION Does_KPI_Exist(p_portlet_function_name VARCHAR2)
RETURN BOOLEAN IS
  l_Has_One_Row   NUMBER;
BEGIN
  SELECT COUNT(1)
  INTO   l_Has_One_Row
  FROM   BSC_KPIS_B A
  WHERE  A.SHORT_NAME = p_Portlet_Function_Name
  AND    A.PROTOTYPE_FLAG <> BSC_KPI_PUB.DELETE_KPI_FLAG;

  IF (l_Has_One_Row > 0) THEN
   RETURN TRUE;
  ELSE
   RETURN FALSE;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN FALSE;
END Does_KPI_Exist;


FUNCTION Find_Max_Seq_Of_Region_Item(p_Region_Code VARCHAR2) RETURN NUMBER IS

    l_max_seq_num      NUMBER;

BEGIN

  SELECT NVL(MAX(A.DISPLAY_SEQUENCE), 0)
  INTO   l_max_seq_num
  FROM   AK_REGION_ITEMS A
  WHERE  A.REGION_CODE = p_Region_Code;

  return l_max_seq_num;

END Find_Max_Seq_Of_Region_Item;


-- adrao modified for Bug#3770986
PROCEDURE RETRIEVE_DIMENSION_OBJECTS(p_region_code                VARCHAR2,
                                     x_dim_obj_list    OUT NOCOPY VARCHAR2,
                                     x_msg_data        OUT NOCOPY VARCHAR2)
IS

  l_ak_attr2              VARCHAR2(1000);
  l_dimension_object      VARCHAR2(1000);
  l_dimension_object_name VARCHAR2(1000);
  l_counter               NUMBER := 1;
  l_dim_obj_short_names   VARCHAR2(1000);
  x_return_status         VARCHAR2(1000);
  x_msg_count             NUMBER;

  CURSOR c_dim(p_region_code varchar2) IS
   SELECT DISTINCT a.attribute2
   FROM   ak_region_items a
   WHERE  a.region_code = Get_Param_Portlet_By_Region(p_region_code)
   AND    a.attribute2 like '%+%'
   AND    a.attribute2 NOT LIKE 'TIME_COMPARISON_TYPE%'
   AND    a.attribute1 <> C_COMP_TO_DIM_LEVEL
   UNION
   SELECT DISTINCT a.attribute2
   FROM   ak_region_items a
   WHERE  a.region_code = p_region_code
   AND    a.attribute2 like '%+%'
   AND    a.attribute2 NOT LIKE 'TIME_COMPARISON_TYPE%'
   AND    a.attribute1 <> C_COMP_TO_DIM_LEVEL;

 CURSOR c_DimObj_Name IS     SELECT a.name
  FROM   bsc_sys_dim_levels_tl a, bsc_sys_dim_levels_b b
  WHERE  a.dim_level_id = b.dim_level_id
  AND    a.language   = USERENV('LANG')
  AND    b.short_name = l_dimension_object;

BEGIN


  OPEN c_dim(p_region_code);
  LOOP

   FETCH c_dim INTO l_ak_attr2;   -- HRI_PERSON+HRI_PER_USRDR_H
   EXIT WHEN c_dim%NOTFOUND;

   l_dimension_object :=  substr(l_ak_attr2, instr(l_ak_attr2, '+')+1);


  l_dimension_object_name := NULL;
    FOR cDimObjName IN c_DimObj_Name LOOP
     l_dimension_object_name  := cDimObjName.NAME;
  END LOOP;

   -- concatenate dimension object short name
    IF ((l_dimension_object_name IS NOT NULL) AND
        (Is_Excluded_Dimension_Object(l_dimension_object) = FND_API.G_FALSE)) THEN
      if (l_counter = 1) then
        l_dim_obj_short_names := l_dimension_object_name;
      else
        l_dim_obj_short_names := l_dim_obj_short_names || '!@#$' || l_dimension_object_name;
      end if;
      l_counter := l_counter + 1;
    END IF;
  END LOOP;

--DBMS_OUTPUT.PUT_LINE('final l_dim_obj_short_names = ' || l_dim_obj_short_names);
  CLOSE c_dim;

  -- if no dimension set, raise exception
  IF (l_counter = 1) THEN
     FND_MESSAGE.SET_NAME('BSC','BSC_NO_DIM_OBJ_PARAM_PORTLET');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_dim_obj_list := l_dim_obj_short_names;


EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --ROLLBACK TO BSCCrtKPIWBisDimWrp;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.RETRIEVE_DIMENSION_OBJECTS ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.RETRIEVE_DIMENSION_OBJECTS ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.RETRIEVE_DIMENSION_OBJECTS ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.RETRIEVE_DIMENSION_OBJECTS ';
        END IF;

END RETRIEVE_DIMENSION_OBJECTS;


-- Returns the Tab Id of a Tab (aka Scorecard)
FUNCTION Get_Tab_Id( p_page_function_name VARCHAR2)
RETURN NUMBER IS
   l_tab_id     NUMBER;
BEGIN
   SELECT a.tab_id
   INTO   l_tab_id
   FROM   bsc_tabs_b a
   WHERE  a.short_name = p_page_function_name;

   RETURN l_tab_id;

EXCEPTION
   WHEN OTHERS THEN
     RETURN BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY;
END Get_Tab_Id;


-- Returns the KPI Group Id (aka Objective Group)

FUNCTION Get_Group_Id(p_kpi_portlet_function_name VARCHAR2)
RETURN NUMBER IS

   l_Group_Id    NUMBER;

   CURSOR c_GetId IS
       SELECT A.IND_GROUP_ID
       FROM   BSC_TAB_IND_GROUPS_B A
       WHERE  A.SHORT_NAME = p_Kpi_Portlet_Function_Name;
BEGIN
   l_Group_Id := BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY;
      FOR cGetId IN c_GetId LOOP
        l_Group_Id := cGetId.IND_GROUP_ID;
   END LOOP;
   RETURN l_group_id;

EXCEPTION
   WHEN OTHERS THEN
     RETURN BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY;

END Get_Group_Id;


-------------------------------
-- william cano's code below
-------------------------------


FUNCTION Is_More
(
        p_dim_short_names IN  OUT NOCOPY  VARCHAR2
    ,   p_dim_name        OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS
    l_pos_ids               NUMBER;
    l_pos_rel_types         NUMBER;
    l_pos_rel_columns       NUMBER;
BEGIN
    IF (p_dim_short_names IS NOT NULL) THEN
        l_pos_ids           := INSTR(p_dim_short_names,   ','); -- adeulgao changed from ";" to ","
        IF (l_pos_ids > 0) THEN
            p_dim_name      :=  TRIM(SUBSTR(p_dim_short_names,    1,    l_pos_ids - 1));

            p_dim_short_names     :=  TRIM(SUBSTR(p_dim_short_names,    l_pos_ids + 1));
        ELSE
            p_dim_name      :=  TRIM(p_dim_short_names);

            p_dim_short_names     :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;




Procedure Assign_Kpi_Periodicities(
  p_commit              IN             VARCHAR2 --:= FND_API.G_FALSE
 ,p_kpi_id              IN             NUMBER
 ,p_Time_Dim_obj_sns    IN             VARCHAR2 -- 'MONTH,QUATERLY'
 ,p_Dft_Dim_obj_sn      IN             VARCHAR2 --:= NULL
 ,p_Daily_Flag          IN             VARCHAR2 --:= FND_API.G_FALSE
 ,p_Is_XTD_Enabled      IN             VARCHAR2
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS
 l_Time_Dim_Obj_sh    VARCHAR2(40);
 l_Time_Dim_obj_sns   VARCHAR2(800);
 l_periodicity_id     NUMBER;
 l_periodicity_ids    VARCHAR2(400) := NULL;
 l_calendar_id        NUMBER := NULL;
 l_calendar_id_aux    NUMBER := NULL;
 l_Dft_periodicity_id NUMBER := NULL;
 l_message           VARCHAR2(400);
 l_flag              BOOLEAN;
 l_kpi_calendar_id    NUMBER;
 l_Time_Dim_Object    BIS_LEVELS.SHORT_NAME%TYPE;

 CURSOR c_YearPeriodity IS
   SELECT a.PERIODICITY_ID
   FROM BSC_sys_periodicities a
   WHERE a.CALENDAR_id = l_calendar_id
   AND a.PERIODICITY_TYPE = 9;

 CURSOR c1(p_Calendar NUMBER) IS
   SELECT CALENDAR_ID
   FROM   BSC_SYS_CALENDARS_B
   WHERE  EDW_CALENDAR_TYPE_ID = 1
   AND    EDW_CALENDAR_ID      = p_Calendar;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT BSCAsgnKpiPeriodicities;
   FND_MSG_PUB.Initialize;
   l_Time_Dim_obj_sns:= p_Time_Dim_obj_sns;
   IF (p_Time_Dim_obj_sns IS NULL AND p_Is_XTD_Enabled = FND_API.G_TRUE) THEN
     SELECT CALENDAR_ID
     INTO l_kpi_calendar_id
     FROM BSC_KPIS_B
     WHERE INDICATOR = p_kpi_id;
     IF (l_kpi_calendar_id IS NOT NULL) THEN
       l_Time_Dim_obj_sns := BSC_PERIODS_UTILITY_PKG.Get_Daily_Periodicity_Sht_Name(l_kpi_calendar_id);
     END IF;
   END IF;


  -- Convert Time Dimension Short Names into BCS-BIS Periodicities
  WHILE (is_more(p_dim_short_names  =>  l_Time_Dim_obj_sns
                 ,p_dim_name        =>  l_Time_Dim_Obj_sh)) LOOP
      l_periodicity_id := NULL;

       -- added condition for Calendar Enhancement#4376162
       IF (BSC_BIS_KPI_CRUD_PUB.Is_DimObj_Periodicity(l_Time_Dim_Obj_Sh) = FND_API.G_TRUE) THEN
            BSC_BIS_KPI_CRUD_PUB.Get_Non_DBI_Periodicities (
                  p_Time_Short_Name => l_Time_Dim_Obj_Sh
                , x_Periodicity_Id  => l_Periodicity_Id
                , x_Calendar_Id     => l_Calendar_Id_Aux
                , x_Return_Status   => x_Return_Status
                , x_Msg_Count       => x_Msg_Count
                , x_Msg_Data        => x_Msg_Data
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

       ELSE

        -- Fixed for Bug#4566634
        l_Time_Dim_Object := l_Time_Dim_Obj_sh;
        l_flag  := BSC_PERIODS_UTILITY_PKG.Get_Bsc_Periodicity(
                     x_time_level_name    => l_Time_Dim_Object
                    ,x_periodicity_id     => l_periodicity_Id
                    ,x_calendar_id        => l_calendar_id_aux
                    ,x_message            => l_message
                   );
      END IF;


      IF l_periodicity_id IS NOT NULL THEN
        IF l_periodicity_ids IS NOT NULL THEN
          l_periodicity_ids := l_periodicity_ids || ',' || l_periodicity_id;
        ELSE
          l_periodicity_ids := l_periodicity_ids  || l_periodicity_id;
          l_calendar_id := l_calendar_id_aux;
        END IF;
        IF l_Time_Dim_Obj_sh = p_Dft_Dim_obj_sn THEN
           l_Dft_periodicity_id := l_periodicity_id;
        END IF;
      ELSE
            FND_MESSAGE.SET_NAME('BSC','BSC_NO_PERIODICITY_FOUND_DL');
            FND_MESSAGE.SET_TOKEN('SHORT_NAME', l_Time_Dim_Obj_sh );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
      END IF;
      --DBMS_OUTPUT.PUT_LINE(' l_periodicity_ids = '||l_periodicity_ids);
    END LOOP;
    --DBMS_OUTPUT.PUT_LINE(' l_calendar_id = '||l_calendar_id);
    --DBMS_OUTPUT.PUT_LINE(' l_periodicity_ids = '||l_periodicity_ids);

    IF l_calendar_id IS NOT NULL THEN
      --DBMS_OUTPUT.PUT_LINE(' p_Daily_Flag = '||p_Daily_Flag);
      IF p_Is_XTD_Enabled = FND_API.G_TRUE THEN
         --DBMS_OUTPUT.PUT_LINE(' before open c_YearPerioditY');
         OPEN c_YearPeriodity;
         --DBMS_OUTPUT.PUT_LINE(' AFTER open c_YearPerioditY');
            FETCH c_YearPeriodity into l_periodicity_id;
            IF (c_YearPeriodity%FOUND) THEN
              --DBMS_OUTPUT.PUT_LINE(' l_periodicity_id = '||l_periodicity_id);
              IF INSTR( ',' ||  l_periodicity_ids || ',', ',' || l_periodicity_id ||  ',')  <= 0 THEN
                  l_periodicity_ids := l_periodicity_ids  || ',' || l_periodicity_id;
              END IF;
            END IF;
            CLOSE c_YearPeriodity;
      END IF;

      --  Asisgn BSC-BIS Periodicities to the KPI
      BSC_PMF_UI_WRAPPER.Update_Kpi_Periodicities(
        p_commit              => p_commit
       ,p_kpi_id              => p_kpi_id
       ,p_calendar_id         => l_calendar_id
       ,p_periodicity_ids     => l_periodicity_ids
        ,p_Dft_periodicity_id  => l_Dft_periodicity_id
       ,x_return_status       => x_return_status
       ,x_msg_count           => x_msg_count
       ,x_msg_data            => x_msg_data
      );
     IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    ELSE -- if l_Calendar_Id is NULL added for Bug#3769227
      IF (p_Is_XTD_Enabled = FND_API.G_TRUE) THEN
         OPEN  c1 (1001);
         FETCH c1 INTO l_Calendar_Id;
         CLOSE c1;

         BSC_PMF_UI_WRAPPER.Update_Kpi_Periodicities(
           p_commit              => p_Commit
          ,p_kpi_id              => p_Kpi_Id
          ,p_calendar_id         => l_Calendar_Id
          ,p_periodicity_ids     => NULL
          ,p_Dft_periodicity_id  => NULL
          ,x_return_status       => x_Return_Status
          ,x_msg_count           => x_Msg_Count
          ,x_msg_data            => x_Msg_Data
         );

         IF (x_Return_Status  <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

      END IF;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCAsgnKpiPeriodicities;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCAsgnKpiPeriodicities;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO BSCAsgnKpiPeriodicities;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Assign_Kpi_Periodicities ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Assign_Kpi_Periodicities ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

end Assign_Kpi_Periodicities;

PROCEDURE Update_Actual_Data_Source(
             p_Kpi_Id               IN NUMBER
           , p_Dataset_Id           IN NUMBER
           , p_Measure_Short_Name   IN VARCHAR2
           , p_Create_Region_Per_AO IN VARCHAR2 := FND_API.G_FALSE

) IS

  l_value         VARCHAR2(1000);
  l_Region_Code   VARCHAR2(80);
  l_Analysis_Option NUMBER;

BEGIN


  l_Analysis_Option := NULL;

  IF (p_Create_Region_Per_AO = FND_API.G_TRUE) THEN
      l_Analysis_Option := Get_AO_Id_By_Measure (
                               p_Kpi_Id     => p_kpi_id
                             , p_Dataset_Id => p_dataset_id
                           );
  END IF;


  l_Region_Code := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Region_Code(
                   p_Kpi_Id => p_kpi_id,
                   p_AO_Id  => l_Analysis_Option
              );

  l_Value := l_Region_Code || '.' || p_Measure_Short_Name;


  UPDATE  BIS_INDICATORS
  SET     ACTUAL_DATA_SOURCE      = l_Value
        , ACTUAL_DATA_SOURCE_TYPE = 'AK'
        , FUNCTION_NAME           = l_Region_Code
        , ENABLE_LINK             = 'Y'
  WHERE   DATASET_ID              = p_Dataset_Id;

END Update_Actual_Data_Source;



PROCEDURE Update_Dim_Dim_Level_Columns(
        p_dim_object_short_name                  VARCHAR2,
        p_non_time_dimension_objects             bsc_varchar2_tbl_type,
        p_non_time_counter                       NUMBER,
        x_msg_data                    OUT NOCOPY VARCHAR2)
IS


  l_index             NUMBER;
  l_total_flag        NUMBER;
  l_comparison_flag   NUMBER;
  l_where_clause      BSC_SYS_DIM_LEVELS_BY_GROUP.WHERE_CLAUSE%TYPE;
  l_dim_group_id      NUMBER;
  l_dim_level_id      NUMBER;
  x_return_status     VARCHAR2(80);
  x_msg_count         NUMBER;


BEGIN

  x_msg_data := NULL;

  FOR l_index in 1..p_non_time_counter LOOP

     x_Msg_Data := BSC_APPS.Get_Message('BSC_DIP_ERR_GET_GROUP_ID');
     SELECT d.total_flag, d.comparison_flag, d.where_clause
     INTO   l_total_flag, l_comparison_flag, l_where_clause
     FROM   bsc_sys_dim_groups_tl a,
            bis_dimensions b,
            bis_levels c,
            bsc_sys_dim_levels_by_group d,
            bsc_sys_dim_levels_b e
     WHERE  c.short_name = p_non_time_dimension_objects(l_index)
     AND    c.dimension_id = b.dimension_id
     AND    b.short_name = a.short_name
     AND    a.language = userenv('LANG')
     AND    a.dim_group_id = d.dim_group_id
     AND    e.short_name = p_non_time_dimension_objects(l_index)
     AND    e.dim_level_id = d.dim_level_id;


     x_Msg_Data := BSC_APPS.Get_Message('BSC_DIP_ERR_GET_DIM_REL');
     SELECT d.dim_group_id, d.dim_level_id
     INTO   l_dim_group_id, l_dim_level_id
     FROM   bsc_sys_dim_groups_tl a,
            bsc_sys_dim_levels_by_group d,
            bsc_sys_dim_levels_b e
     WHERE  d.dim_group_id = a.dim_group_id
     AND    a.short_name = p_dim_object_short_name
     AND    a.language = userenv('LANG')
     AND    e.short_name = p_non_time_dimension_objects(l_index)
     AND    e.dim_level_id = d.dim_level_id;

     x_Msg_Data := BSC_APPS.Get_Message('BSC_DIP_ERR_UPDATE_DIM_REL');
     UPDATE bsc_sys_dim_levels_by_group
     SET    total_flag = l_total_flag,
            comparison_flag = l_comparison_flag,
            where_clause = l_where_clause
     WHERE  dim_group_id = l_dim_group_id
     AND    dim_level_id = l_dim_level_id;


  END LOOP;

  x_Msg_Data := NULL;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Update_Dim_Dim_Level_Columns ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Update_Dim_Dim_Level_Columns ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Update_Dim_Dim_Level_Columns ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Update_Dim_Dim_Level_Columns ';
        END IF;

END Update_Dim_Dim_Level_Columns;

/*

Update Section Added here

*/


/* -*********************************************** */

PROCEDURE Update_Measure_Region_Item(
         p_Commit                   VARCHAR2,
         p_Measure_Short_Name       VARCHAR2,
         p_Sequence_Number          NUMBER,
         p_Kpi_Id                   NUMBER,
         p_Analysis_Option          NUMBER := NULL,
         p_Dataset_Format_Id        NUMBER,
         p_Dataset_Autoscale_Flag   NUMBER,
         p_Analysis_Option_Name     VARCHAR2,
         x_Return_Status OUT NOCOPY VARCHAR2,
         x_Msg_Count     OUT NOCOPY NUMBER,
         x_Msg_Data      OUT NOCOPY VARCHAR2)
IS

    l_region_item_rec                BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type;
    l_region_item_table_measure      BIS_AK_REGION_PUB.Bis_Region_Item_Tbl_Type;
    l_Region_Code                    VARCHAR2(30);
    l_Colspan_Attr_Code VARCHAR2(30);
BEGIN

--DBMS_OUTPUT.PUT_LINE( 'measure sequence = ' || p_sequence_number);
    -- Currently we cannot use Column Span Bug#3688263, its not supported.

    l_Region_Code := BSC_BIS_CUSTOM_KPI_UTIL_PUB.get_Region_Code (p_Kpi_Id, p_Analysis_Option);

    l_Colspan_Attr_Code := get_Unique_Attribute_Code (
                              p_Region_Code         => l_Region_Code
                            , p_Measure_Short_Name  => p_Measure_Short_Name
                            , p_Append_String       => BSC_BIS_KPI_CRUD_PUB.C_COLSPAN
                          );

    l_region_item_rec.Attribute_Code := p_measure_short_name;
    l_region_item_rec.Attribute_Application_Id := BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID;

-- We currently do not have a retrive API to get the Sequence Numbers.
    l_region_item_rec.Display_Sequence := p_sequence_number;

    -- Added Graph_Position = 1 for Bug#3742500

    l_Region_Item_Rec.Node_Display_Flag     := 'Y';
    l_Region_Item_Rec.Required_Flag         := ' ';
    l_Region_Item_Rec.Queryable_Flag        := ' ';
    l_Region_Item_Rec.Display_Length        := LENGTH(p_Analysis_Option_Name);
    l_Region_Item_Rec.Long_Label            := p_Analysis_Option_Name;
    l_Region_Item_Rec.Sort_Sequence         := NULL;
    l_Region_Item_Rec.Initial_Sort_Sequence := NULL;
    l_Region_Item_Rec.Sort_Direction        := NULL;
    l_Region_Item_Rec.Url                   := NULL;
    l_Region_Item_Rec.Attribute_Type        := BSC_BIS_KPI_CRUD_PUB.C_MEASURE_ATTRIBURE_TYPE;
    l_Region_Item_Rec.Display_Format        := Get_Format_Mask(p_Dataset_Format_Id);
    l_Region_Item_Rec.Display_Type          := BSC_BIS_KPI_CRUD_PUB.C_AUTOFACTOR_GROUP1;
    l_Region_Item_Rec.Measure_Level         := p_Measure_Short_Name; -- Earlier we were using l_Colspan_Attr_Code;
    l_Region_Item_Rec.Base_Column           := NULL;
    l_Region_Item_Rec.Lov_Where_Clause      := NULL;
    l_Region_Item_Rec.Graph_Position        := 1;
    l_Region_Item_Rec.Graph_Style           := NULL;
    l_Region_Item_Rec.Lov_Table             := NULL;
    l_Region_Item_Rec.Aggregate_Function    := NULL;
    l_Region_Item_Rec.Display_Total         := 'Y' ;
    l_Region_Item_Rec.Variance              := NULL;
    l_Region_Item_Rec.Schedule              := NULL;
    l_Region_Item_Rec.Override_Hierarchy    := NULL;
    l_Region_Item_Rec.Additional_View_By    := NULL;
    l_Region_Item_Rec.Rolling_Lookup        := NULL;
    l_Region_Item_Rec.Operator_Lookup       := NULL;
    l_Region_Item_Rec.Dual_YAxis_Graphs     := NULL;
    l_Region_Item_Rec.Custom_View_Name      := NULL;
    l_Region_Item_Rec.Graph_Measure_Type    := NULL;
    l_Region_Item_Rec.Hide_Target_In_Table  := NULL;
    l_Region_Item_Rec.Parameter_Render_Type := NULL;
    l_Region_Item_Rec.Privilege             := NULL;
    l_region_item_rec.Grand_Total_Flag      := 'Y';

    l_Region_Item_Table_Measure(1) := l_Region_Item_Rec;

    BIS_PMV_REGION_ITEMS_PVT.UPDATE_REGION_ITEMS(
        p_Commit                 => p_Commit
       ,p_Region_Code            => l_Region_Code
       ,p_Region_Application_Id  => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
       ,p_Region_Item_Tbl        => l_Region_Item_Table_Measure
       ,x_Return_Status          => x_Return_Status
       ,x_Msg_Count              => x_Msg_Count
       ,x_Msg_Data               => x_Msg_Data
    );
    IF (x_Return_Status <>  FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('region_code  = ' || BSC_UTILITY.C_BSC_UNDERSCORE || p_kpi_id);
    --DBMS_OUTPUT.PUT_LINE('return_status_for measure_region_item = ' || x_return_status);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Update_Measure_Region_Item ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Update_Measure_Region_Item ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Update_Measure_Region_Item ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Update_Measure_Region_Item ';
        END IF;
END Update_Measure_Region_Item;




/*
  Procedure to Delete the Measure Region Item
*/

PROCEDURE Delete_Measure_Region_Item(
                 p_commit                    VARCHAR2 := FND_API.G_FALSE,
                 p_Param_Portlet_Region_Code VARCHAR2,
                 p_Measure_Short_Name        VARCHAR2,
                 p_Application_Id            NUMBER,
                 x_return_status             OUT NOCOPY VARCHAR2,
                 x_msg_count                 OUT NOCOPY NUMBER,
                 x_msg_data                  OUT NOCOPY VARCHAR2)
IS
      l_Attribute_Code_Tbl    BISVIEWER.t_char ;
      l_Attribute_App_Id_Tbl  BISVIEWER.t_num ;
BEGIN

      l_Attribute_Code_Tbl(1) := p_Measure_Short_Name;
      l_Attribute_App_Id_Tbl(1) := p_Application_Id;

      BIS_PMV_REGION_ITEMS_PVT.DELETE_REGION_ITEMS
      (       p_commit                 => p_commit
          ,   p_region_code            => p_Param_Portlet_Region_Code
          ,   p_region_application_id  => p_Application_Id
          ,   p_Attribute_Code_Tbl     => l_Attribute_Code_Tbl
          ,   p_Attribute_Appl_Id_Tbl  => l_Attribute_App_Id_Tbl
          ,   x_return_status          => x_return_status
          ,   x_msg_count              => x_msg_count
          ,   x_msg_data               => x_msg_data
      );

      --DBMS_OUTPUT.PUT_LINE('Delete_Measure_Region_Item (x_msg_data) - ' || x_msg_data);
      --DBMS_OUTPUT.PUT_LINE('Delete_Measure_Region_Item (x_return_status) - ' || x_return_status);

END Delete_Measure_Region_Item;



PROCEDURE  Unassign_Kpi_Analysis_Option (
           p_Commit         VARCHAR2 := FND_API.G_FALSE
          ,p_Kpi_Id         NUMBER
          ,p_Dataset_Id     NUMBER
          ,x_return_status  OUT NOCOPY VARCHAR2
          ,x_msg_count      OUT NOCOPY NUMBER
          ,x_msg_data       OUT NOCOPY VARCHAR2)
IS

  l_Option0           NUMBER;
  l_Option1           NUMBER;
  l_Option2           NUMBER;
  l_Series_Id         NUMBER;

  l_counter           NUMBER;

  CURSOR c_AO IS
    SELECT A.ANALYSIS_OPTION0
         , A.ANALYSIS_OPTION1
         , A.ANALYSIS_OPTION2
         , A.SERIES_ID
    FROM   BSC_KPI_ANALYSIS_MEASURES_B A
    WHERE  A.INDICATOR   = p_Kpi_Id
    AND    A.DATASET_ID  = p_Dataset_Id;


BEGIN
  --DBMS_OUTPUT.PUT_LINE('Inside Unassign_Kpi_Analysis_Option' );


  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_counter    := 0;

  l_Option0    := 0;
  l_Option1    := 0;
  l_Option2    := 0;
  l_Series_Id  := 0;

  FOR AO IN c_AO LOOP
      l_Option0    := AO.ANALYSIS_OPTION0;
      l_Option1    := AO.ANALYSIS_OPTION1;
      l_Option2    := AO.ANALYSIS_OPTION2;
      l_Series_Id  := AO.SERIES_ID;

      l_counter    := l_counter + 1;

      --DBMS_OUTPUT.PUT_LINE('l_Option0    '  || l_Option0);
      --DBMS_OUTPUT.PUT_LINE('l_Option1    '  || l_Option1);
      --DBMS_OUTPUT.PUT_LINE('l_Option2    '  || l_Option2);
      --DBMS_OUTPUT.PUT_LINE('l_Series_Id  '  || l_Series_Id);
  END LOOP;


  -- We need to ensure that we dont delete invalid entries, since
  -- currently we are querying only using (Indicator, Dataset_Id)

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  IF (l_counter = 1) THEN
     BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Multi_Groups_Opts
     (       p_commit        =>  p_Commit
         ,   p_kpi_id        =>  p_Kpi_Id
         ,   p_data_source   =>  BSC_BIS_MEASURE_PUB.c_BSC
         ,   p_Option_0      =>  l_Option0
         ,   p_Option_1      =>  l_Option1
         ,   p_Option_2      =>  l_Option2
         ,   p_Sid           =>  l_Series_Id
         ,   p_time_stamp    =>  NULL
         ,   x_return_status =>  x_return_status
         ,   x_msg_count     =>  x_msg_count
         ,   x_msg_data      =>  x_msg_data
     );

     --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Multi_Groups_Opts - x_return_status  '  || x_return_status);
  ELSE
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

END Unassign_Kpi_Analysis_Option;





FUNCTION Get_Num_Measures_By_Kpi(p_Kpi_Id NUMBER) RETURN NUMBER
IS
  l_count  NUMBER;
BEGIN

  l_count  := 0 ;


  SELECT COUNT(1)
  INTO   l_count
  FROM   BSC_KPI_ANALYSIS_MEASURES_B K
  WHERE  K.INDICATOR = p_Kpi_Id;

  RETURN l_count;
END Get_Num_Measures_By_Kpi;


FUNCTION Get_Kpi_Id(p_Page_Function_Name VARCHAR2) RETURN NUMBER
IS
   l_kpi_id     NUMBER;
BEGIN
   -- when there is no matching, return -1000 to inform the caller
   -- Fixed for Bug#3781764 added PROTOTYPE_FLAG
   SELECT K.INDICATOR
   INTO   l_Kpi_Id
   FROM   BSC_KPIS_B K
   WHERE  K.SHORT_NAME = p_Page_Function_Name
   AND    K.PROTOTYPE_FLAG <> BSC_KPI_PUB.DELETE_KPI_FLAG;

   RETURN l_kpi_id;
EXCEPTION
   WHEN OTHERS THEN RETURN -1000;
END Get_Kpi_Id;


PROCEDURE Delete_Dim_Level_Region_Item(
      p_commit                               VARCHAR2 := FND_API.G_FALSE
     ,p_Application_Id                       NUMBER
     ,p_Non_Time_Counter                     NUMBER
     ,p_Non_Time_Dimension_Objects           bsc_varchar2_tbl_type
     ,p_Non_Time_Dimension_Groups            bsc_varchar2_tbl_type
     ,p_Time_Counter                         NUMBER
     ,p_Time_Dimension_Objects               bsc_varchar2_tbl_type
     ,p_Time_Dimension_Groups                bsc_varchar2_tbl_type
     ,p_Region_Code                          VARCHAR2
     ,x_Return_Status                 OUT    NOCOPY VARCHAR2
     ,x_Msg_Count                     OUT    NOCOPY NUMBER
     ,x_Msg_Data                      OUT    NOCOPY VARCHAR2)
IS
      l_Attribute_Code_Tbl         BISVIEWER.t_char ;
      l_Attribute_App_Id_Tbl       BISVIEWER.t_num ;
      l_Dim                        NUMBER;
      l_Real_Counter               NUMBER;
BEGIN

    l_real_counter := 1;

    FOR l_dim IN 1..p_non_time_counter LOOP
      l_Attribute_Code_Tbl(l_real_counter) := p_non_time_dimension_objects(l_dim);
      l_Attribute_App_Id_Tbl(l_real_counter) := p_Application_Id;

      l_real_counter := l_real_counter + 1;
    END LOOP;


    FOR l_dim IN 1..p_time_counter LOOP
      l_Attribute_Code_Tbl(l_real_counter)   := p_time_dimension_objects(l_dim);
      l_Attribute_App_Id_Tbl(l_real_counter) := p_Application_Id;

      l_real_counter := l_real_counter + 1;
    END LOOP;

    BIS_PMV_REGION_ITEMS_PVT.DELETE_REGION_ITEMS
    (       p_commit                 => p_commit
        ,   p_region_code            => p_Region_Code
        ,   p_region_application_id  => p_Application_Id
        ,   p_Attribute_Code_Tbl     => l_Attribute_Code_Tbl
        ,   p_Attribute_Appl_Id_Tbl  => l_Attribute_App_Id_Tbl
        ,   x_return_status          => x_return_status
        ,   x_msg_count              => x_msg_count
        ,   x_msg_data               => x_msg_data
    );

    --DBMS_OUTPUT.PUT_LINE('Delete_Dim_Level_Region_Item (x_msg_data) - ' || x_msg_data);
    --DBMS_OUTPUT.PUT_LINE('Delete_Dim_Level_Region_Item (x_return_status) - ' || x_return_status);

END Delete_Dim_Level_Region_Item;


/*
  Function to get the FunctionId, when Function name is passed.
*/

FUNCTION Get_Function_Id_By_Name(p_kpi_portlet_function_name VARCHAR2) RETURN NUMBER
IS
   l_fun_id  NUMBER;
BEGIN
   -- when there is no matching, return -1000 to inform the caller
   SELECT F.Function_Id
   INTO   l_Fun_Id
   FROM   FND_FORM_FUNCTIONS F
   WHERE  F.Function_Name = p_Kpi_Portlet_Function_Name;

   RETURN l_Fun_Id;
EXCEPTION
   WHEN NO_DATA_FOUND THEN RETURN -1000;
END Get_Function_Id_By_Name;


/*
  Update_Kpi_Analysis_Option - Updates the KPI Analysis Option Name and Description..
*/


PROCEDURE Update_Kpi_Analysis_Option (
           p_Commit               VARCHAR2 := FND_API.G_FALSE
          ,p_Kpi_Id               NUMBER
          ,p_Dataset_Id           NUMBER
          ,p_Measure_Name         VARCHAR2
          ,p_Measure_Description  VARCHAR2
          ,x_return_status        OUT NOCOPY VARCHAR2
          ,x_msg_count            OUT NOCOPY NUMBER
          ,x_msg_data             OUT NOCOPY VARCHAR2)
IS

  l_Option0           NUMBER;

  l_counter           NUMBER;

  CURSOR c_AO IS
    SELECT A.ANALYSIS_OPTION0
    FROM   BSC_KPI_ANALYSIS_MEASURES_B A
    WHERE  A.INDICATOR   = p_Kpi_Id
    AND    A.DATASET_ID  = p_Dataset_Id;


BEGIN
  --DBMS_OUTPUT.PUT_LINE('Inside Update_Kpi_Analysis_Option' );

  l_counter    := 0;

  l_Option0    := 0;

  FOR AO IN c_AO LOOP
      l_Option0    := AO.ANALYSIS_OPTION0;

      l_counter    := l_counter + 1;

      --DBMS_OUTPUT.PUT_LINE('l_Option0    '  || l_Option0);
  END LOOP;


  -- We need to ensure that we dont delete invalid entries, since
  -- currently we are querying only using (Indicator, Dataset_Id)

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  IF (l_Counter = 1) THEN
      UPDATE BSC_KPI_ANALYSIS_OPTIONS_TL
         SET NAME = p_Measure_Name
            ,HELP = p_Measure_Description
            ,SOURCE_LANG = USERENV('LANG')
      WHERE INDICATOR             = p_Kpi_Id
        AND ANALYSIS_GROUP_ID     = 0
        AND OPTION_ID             = l_Option0
        AND PARENT_OPTION_ID      = 0
        AND GRANDPARENT_OPTION_ID = 0
        AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

      UPDATE BSC_KPI_ANALYSIS_MEASURES_TL
         SET NAME               = p_Measure_Name
            ,HELP               = p_Measure_Description
            ,SOURCE_LANG        = USERENV('LANG')
      WHERE INDICATOR           = p_Kpi_Id
        AND ANALYSIS_OPTION0    = l_Option0
        AND ANALYSIS_OPTION1    = 0
        AND ANALYSIS_OPTION2    = 0
        AND SERIES_ID           = 0
        AND USERENV('LANG')     IN (LANGUAGE, SOURCE_LANG);

  ELSE
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;


END Update_Kpi_Analysis_Option;



FUNCTION Get_Sequence_Id_By_Region(
             p_Region_Code              VARCHAR2
           , p_Region_Application_Id    NUMBER
           , p_Attribute_Code           VARCHAR2
           , p_Attribute_Application_Id NUMBER
)  RETURN NUMBER
IS
   l_Sequence_Id  NUMBER;
BEGIN
   -- when there is no matching, return -1000 to inform the caller
   SELECT A.Display_Sequence
   INTO   l_Sequence_Id
   FROM   AK_REGION_ITEMS A
   WHERE  A.REGION_APPLICATION_ID    = p_Region_Application_Id
   AND    A.REGION_CODE              = p_Region_Code
   AND    A.ATTRIBUTE_APPLICATION_ID = p_Attribute_Application_Id
   AND    A.ATTRIBUTE_CODE           = p_Attribute_Code;

   RETURN l_Sequence_Id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN RETURN -1;

END Get_Sequence_Id_By_Region;

-- Gets the Dataset Id

FUNCTION Get_Dataset_Id(
    p_measure_short_name IN VARCHAR2
    ) RETURN NUMBER IS
    l_dataset_id NUMBER;
BEGIN
  SELECT
    i.dataset_id
  INTO l_dataset_id
  FROM
    bis_indicators i
  WHERE
    i.short_name = p_Measure_Short_Name;

    RETURN l_dataset_id;
EXCEPTION
  WHEN OTHERS THEN
     RETURN -1000;
END Get_Dataset_Id;

PROCEDURE Get_Page_Name (
          p_Page_Function_Name        IN VARCHAR2
        , p_Kpi_Portlet_Function_Name IN VARCHAR2
        , x_Page_Names                OUT NOCOPY  VARCHAR2
) IS

  l_Tab_Id   NUMBER;
  l_Kpi_Id   NUMBER;
  l_Count    NUMBER;

  CURSOR c_PageNames IS
    SELECT T.NAME
    FROM   BSC_TABS_VL T, BSC_TAB_INDICATORS K
    WHERE  T.TAB_ID = K.TAB_ID
    AND    T.TAB_ID <> l_Tab_Id
    AND    K.INDICATOR = l_Kpi_Id;

BEGIN
    x_Page_Names := NULL;
    l_Count := 0;

    l_tab_id := Get_Tab_Id(p_Page_Function_Name);
    l_Kpi_Id := Get_Kpi_Id(p_Page_Function_Name);

    FOR cname IN c_PageNames LOOP
      IF(l_Count = 0) THEN
         x_Page_Names := cname.NAME;
      ELSE
         x_Page_Names := x_Page_Names || ', ' || cname.NAME;
      END IF;
      l_Count := 1;
    END LOOP;

END Get_Page_Name;


FUNCTION Get_AO_Id_By_Measure (
            p_Kpi_Id   NUMBER
           ,p_Dataset_Id NUMBER
) RETURN NUMBER IS
  l_AO_Id  NUMBER;

  CURSOR c_AO IS
    SELECT ANALYSIS_OPTION0
    FROM   BSC_KPI_ANALYSIS_MEASURES_B
    WHERE  DATASET_ID = p_Dataset_Id
    AND    INDICATOR = p_Kpi_Id;
BEGIN

  l_AO_id := -1;

  FOR ao IN c_AO LOOP
   l_AO_Id := ao.Analysis_Option0;
  END LOOP;

  RETURN l_AO_id;
END Get_AO_Id_By_Measure;


PROCEDURE Create_Region_By_AO (
          p_Commit                    VARCHAR2 := FND_API.G_FALSE
        , p_Kpi_Id                 IN NUMBER
        , p_Analysis_Option_Id     IN NUMBER  := NULL
        , p_Dim_Set_Id             IN NUMBER
        , p_Region_Name            IN VARCHAR2
        , p_Region_Description     IN VARCHAR2
        , p_Region_Application_Id  IN NUMBER
        , p_Disable_View_By        IN VARCHAR2 := 'N'
        , x_return_status          OUT NOCOPY VARCHAR2
        , x_msg_count              OUT NOCOPY NUMBER
        , x_msg_data               OUT NOCOPY VARCHAR2
) IS

    l_report_region_rec               BIS_AK_REGION_PUB.Bis_Region_Rec_Type;

BEGIN



     --DBMS_OUTPUT.PUT_LINE('p_Kpi_Id = ' || p_Kpi_Id);
     --DBMS_OUTPUT.PUT_LINE('p_Analysis_Option_Id = ' || p_Analysis_Option_Id);

     l_report_region_rec.Region_Code := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Region_Code(
                                            p_Kpi_Id => p_Kpi_Id,
                                            p_AO_Id => p_Analysis_Option_Id
                                         );
     --DBMS_OUTPUT.PUT_LINE('l_report_region_rec.Region_Code = ' || l_report_region_rec.Region_Code);

     l_report_region_rec.Region_Name := p_Region_Name;
     l_report_region_rec.Region_Description := p_Region_Description;
     l_report_region_rec.Region_Application_Id := p_Region_Application_Id;
     l_report_region_rec.Database_Object_Name := 'ICX_PROMPTS';
     l_report_region_rec.Region_Style := 'TABLE';
     l_report_region_rec.Region_Object_Type := NULL;
     l_report_region_rec.Help_Target := NULL;
     l_report_region_rec.Display_Rows := NULL;
     l_report_region_rec.Disable_View_By := p_Disable_View_By;
     l_report_region_rec.No_Of_Portlet_Rows := NULL;
     l_report_region_rec.Schedule := NULL;
     l_report_region_rec.Header_File_Procedure := NULL;
     l_report_region_rec.Footer_File_Procedure := NULL;
     l_report_region_rec.Group_By := NULL;
     l_report_region_rec.Order_By := NULL;
     l_report_region_rec.Plsql_For_Report_Query := p_Kpi_Id||'.'||p_Analysis_Option_Id;
     l_report_region_rec.Display_Subtotals := NULL;
     l_report_region_rec.Data_Source := BSC_BIS_KPI_CRUD_PUB.C_BSC_SOURCE;
     l_report_region_rec.Where_Clause := NULL;
     l_report_region_rec.Dimension_Group := NULL;
     l_report_region_rec.Parameter_Layout := NULL;
     l_report_region_rec.Kpi_Id := p_Kpi_Id;
     l_report_region_rec.Analysis_Option_Id := p_Analysis_Option_Id;
     l_report_region_rec.Dim_Set_Id := p_Dim_Set_Id;

     BIS_PMV_REGION_PVT.CREATE_REGION
     (
                         p_commit                 => p_commit
                        ,p_Report_Region_Rec      => l_report_region_rec
                        ,x_return_status          => x_return_status
                        ,x_msg_count              => x_msg_count
                        ,x_msg_data               => x_msg_data
     );
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

    WHEN NO_DATA_FOUND THEN
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Create_Region_By_AO ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Create_Region_By_AO ';
        END IF;
    WHEN OTHERS THEN
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Create_Region_By_AO ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Create_Region_By_AO ';
        END IF;

END Create_Region_By_AO;


-- Update Region By Analysis Option ID

PROCEDURE Update_Region_By_AO (
          p_Commit                    VARCHAR2 := FND_API.G_FALSE
        , p_Kpi_Id                 IN NUMBER
        , p_Analysis_Option_Id     IN NUMBER
        , p_Dim_Set_Id             IN NUMBER
        , p_Region_Name            IN VARCHAR2
        , p_Region_Description     IN VARCHAR2
        , p_Region_Application_Id  IN NUMBER
        , p_Disable_View_By        IN VARCHAR2 := 'N'
        , x_return_status          OUT NOCOPY VARCHAR2
        , x_msg_count              OUT NOCOPY NUMBER
        , x_msg_data               OUT NOCOPY VARCHAR2
) IS

    l_report_region_rec               BIS_AK_REGION_PUB.Bis_Region_Rec_Type;

BEGIN


     l_report_region_rec.Region_Code := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Region_Code(
                                            p_Kpi_Id => p_Kpi_Id,
                                            p_AO_Id => p_Analysis_Option_Id
                                         );
     l_report_region_rec.Region_Name := p_Region_Name;
     l_report_region_rec.Region_Description := p_Region_Description;
     l_report_region_rec.Region_Application_Id := p_Region_Application_Id;
     l_report_region_rec.Database_Object_Name := 'ICX_PROMPTS';
     l_report_region_rec.Region_Style := 'TABLE';
     l_report_region_rec.Region_Object_Type := NULL;
     l_report_region_rec.Help_Target := NULL;
     l_report_region_rec.Display_Rows := NULL;
     l_report_region_rec.Disable_View_By := p_Disable_View_By;
     l_report_region_rec.No_Of_Portlet_Rows := NULL;
     l_report_region_rec.Schedule := NULL;
     l_report_region_rec.Header_File_Procedure := NULL;
     l_report_region_rec.Footer_File_Procedure := NULL;
     l_report_region_rec.Group_By := NULL;
     l_report_region_rec.Order_By := NULL;
     l_report_region_rec.Plsql_For_Report_Query := p_Kpi_Id||'.'||p_Analysis_Option_Id;
     l_report_region_rec.Display_Subtotals := NULL;
     l_report_region_rec.Data_Source := BSC_BIS_KPI_CRUD_PUB.C_BSC_SOURCE;
     l_report_region_rec.Where_Clause := NULL;
     l_report_region_rec.Dimension_Group := NULL;
     l_report_region_rec.Parameter_Layout := NULL;
     l_report_region_rec.Kpi_Id := p_Kpi_Id;
     l_report_region_rec.Analysis_Option_Id := p_Analysis_Option_Id;
     l_report_region_rec.Dim_Set_Id := p_Dim_Set_Id;

     BIS_PMV_REGION_PVT.UPDATE_REGION
     (
                         p_commit                 => p_Commit
                        ,p_Report_Region_Rec      => l_report_region_rec
                        ,x_return_status          => x_return_status
                        ,x_msg_count              => x_msg_count
                        ,x_msg_data               => x_msg_data
     );
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

    WHEN NO_DATA_FOUND THEN
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Update_Region_By_AO ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Update_Region_By_AO ';
        END IF;
    WHEN OTHERS THEN
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Update_Region_By_AO ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Update_Region_By_AO ';
        END IF;


END Update_Region_By_AO;


/*
  Get the KPI_ID and OPTION_ID from the Region_Code
  Also, specify if the Region Has been created per Analysis Option
*/

PROCEDURE Get_KPI_AO_From_Region(
              p_Region_Code             IN         VARCHAR2
            , x_Kpi_Id                  OUT NOCOPY NUMBER
            , x_Analysis_Option_Id      OUT NOCOPY NUMBER
) IS

BEGIN
     x_Kpi_Id := -1;
     x_Analysis_Option_Id := -1;

     IF p_Region_Code IS NOT NULL THEN
         x_Kpi_Id := SUBSTR(p_Region_Code, (LENGTH(BSC_UTILITY.C_BSC_UNDERSCORE)+1), (INSTR(p_Region_Code, '_', '5') - (LENGTH(BSC_UTILITY.C_BSC_UNDERSCORE)+1)));
         x_Analysis_Option_Id := SUBSTR(p_Region_Code, (INSTR(p_Region_Code, '_', '5')+1)) ;
     END IF;

END Get_KPI_AO_From_Region;


/*
  RETURNS if the region_code has an analysis option associated with the region.
*/

FUNCTION has_Region_Per_Measure (
           p_Region_Code IN VARCHAR2
)  RETURN BOOLEAN IS
BEGIN
  IF (NVL(INSTR(SUBSTR(p_Region_Code, LENGTH(BSC_UTILITY.C_BSC_UNDERSCORE)+1), '_'), -1) > 0) THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;

END has_Region_Per_Measure;


/*
  Checks if the region code is valid or not
*/

FUNCTION is_Valid_Region_Code (
           p_Region_Code IN VARCHAR2
)  RETURN BOOLEAN IS
   l_Count NUMBER;
BEGIN
   l_Count := 0;

   SELECT COUNT(1)
   INTO   l_Count
   FROM   AK_REGIONS
   WHERE  REGION_CODE = p_Region_Code;

   IF (l_Count > 0) THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;

END is_Valid_Region_Code;


/*
  Checks to see if the Measure p_Dataset_Id has its own region item
  for the Analysis Option for which it is associated with the KPI.
*/

FUNCTION has_Measure_AK_Region (
            p_Kpi_Id   NUMBER
           ,p_Dataset_Id NUMBER
) RETURN BOOLEAN IS

  l_Analysis_Option NUMBER;
  l_Region_Code     VARCHAR2(30);

BEGIN

  l_Analysis_Option := Get_AO_Id_By_Measure(p_Kpi_Id, p_Dataset_Id);
  l_Region_Code := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Region_Code(p_Kpi_Id, l_Analysis_Option);

  IF is_Valid_Region_Code(l_Region_Code) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

END has_Measure_AK_Region;

FUNCTION has_Dim_Level (
            p_Region_Code VARCHAR2
) RETURN BOOLEAN IS

  l_Count NUMBER;

BEGIN

  l_Count := 0;

  SELECT COUNT(1)
  INTO   l_Count
  FROM   AK_REGION_ITEMS
  WHERE  REGION_CODE = p_Region_Code
  AND    ( (ATTRIBUTE1  = 'DIMENSION LEVEL') OR
           (ATTRIBUTE1  = 'DIM LEVEL SINGLE VALUE') OR
           (ATTRIBUTE1  = 'DIMENSION VALUE') OR
           (ATTRIBUTE1  = 'HIDE_VIEW_BY') OR
           (ATTRIBUTE1  = 'HIDE_VIEW_BY_SINGLE') OR
           (ATTRIBUTE1  = 'HIDE PARAMETER') OR
           (ATTRIBUTE1  = 'VIEWBY PARAMETER') OR
           (ATTRIBUTE1  = 'HIDE_DIM_LVL') OR
           (ATTRIBUTE1  = 'HIDE DIMENSION LEVEL') OR
           (ATTRIBUTE1  = 'HIDE VIEW BY DIMENSION') OR
           (ATTRIBUTE1  = 'HIDE_VIEW_BY_DIM_SINGLE'))
   AND     attribute2 NOT LIKE 'TIME_COMPARISON_TYPE%';


  IF l_Count = 0 THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;
END has_Dim_Level;

-- Gets the Region Application ID for any AK Region

FUNCTION Get_Region_Application_Id (
            p_Region_Code VARCHAR2
) RETURN NUMBER IS
  l_App_Id NUMBER;
BEGIN

  l_App_Id := -1;

  SELECT A.REGION_APPLICATION_ID
  INTO   l_App_Id
  FROM   AK_REGIONS A
  WHERE  A.REGION_CODE = p_Region_Code;


  RETURN l_App_Id;
EXCEPTION
  WHEN OTHERS THEN
     RETURN -1;
END Get_Region_Application_Id;


FUNCTION Get_Format_Mask (
          p_Format_Id NUMBER
) RETURN VARCHAR2 IS
BEGIN
  RETURN BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Format_Mask(p_Format_Id);
END Get_Format_Mask;


PROCEDURE Create_Nested_Region_Item(
      p_commit                       IN VARCHAR2
    , p_Root_AK_Region_Code          IN VARCHAR2
    , p_Param_Portlet_Region_Code    IN VARCHAR2
    , p_sequence_number              IN NUMBER
    , x_return_status                OUT NOCOPY VARCHAR2
    , x_msg_count                    OUT NOCOPY NUMBER
    , x_msg_data                     OUT NOCOPY VARCHAR2
)
IS

    l_region_item_rec                BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type;
    l_region_item_table_nest         BIS_AK_REGION_PUB.Bis_Region_Item_Tbl_Type;

BEGIN

    l_region_item_rec.Attribute_Code           := p_Param_Portlet_Region_Code;
    l_region_item_rec.Attribute_Application_Id := BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID;
    l_region_item_rec.Display_Sequence         := p_sequence_number;
    l_region_item_rec.Node_Display_Flag        := 'Y';
    l_region_item_rec.Required_Flag            := ' ';
    l_region_item_rec.Queryable_Flag           := ' ';
    l_region_item_rec.Display_Length           := 0;
    l_region_item_rec.Long_Label               := NULL;
    l_region_item_rec.Sort_Sequence            := NULL;
    l_region_item_rec.Initial_Sort_Sequence    := NULL;
    l_region_item_rec.Sort_Direction           := NULL;

    l_region_item_rec.Item_Style               := BIS_AK_REGION_PUB.c_NESTED_REGION_STYLE;
    l_region_item_rec.Nested_Region_Code       := p_Param_Portlet_Region_Code;
    l_region_item_rec.Nested_Region_Application_Id  := Get_Region_Application_Id(p_Param_Portlet_Region_Code);

    l_region_item_rec.Url                      := NULL;
    l_region_item_rec.Attribute_Type           := NULL;
    l_region_item_rec.Display_Format           := NULL;
    l_region_item_rec.Display_Type             := NULL;
    l_region_item_rec.Measure_Level            := NULL;
    l_region_item_rec.Base_Column              := NULL;
    l_region_item_rec.Lov_Where_Clause         := NULL;
    l_region_item_rec.Graph_Position           := NULL;
    l_region_item_rec.Graph_Style              := NULL;
    l_region_item_rec.Lov_Table                := NULL;
    l_region_item_rec.Aggregate_Function       := NULL;
    l_region_item_rec.Display_Total            := NULL;
    l_region_item_rec.Variance                 := NULL;
    l_region_item_rec.Schedule                 := NULL;
    l_region_item_rec.Override_Hierarchy       := NULL;
    l_region_item_rec.Additional_View_By       := NULL;
    l_region_item_rec.Rolling_Lookup           := NULL;
    l_region_item_rec.Operator_Lookup          := NULL;
    l_region_item_rec.Dual_YAxis_Graphs        := NULL;
    l_region_item_rec.Custom_View_Name         := NULL;
    l_region_item_rec.Graph_Measure_Type       := NULL;
    l_region_item_rec.Hide_Target_In_Table     := NULL;
    l_region_item_rec.Parameter_Render_Type    := NULL;
    l_region_item_rec.Privilege                := NULL;

    l_region_item_table_nest(1) := l_region_item_rec;

    BIS_PMV_REGION_ITEMS_PVT.CREATE_REGION_ITEMS(
        p_commit                 => p_commit
       ,p_region_code            => p_Root_AK_Region_Code
       ,p_region_application_id  => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
       ,p_Region_Item_Tbl        => l_region_item_table_nest
       ,x_return_status          => x_return_status
       ,x_msg_count              => x_msg_count
       ,x_msg_data               => x_msg_data
    );

    --DBMS_OUTPUT.PUT_LINE('x_return_status           = ' || x_return_status);
    --DBMS_OUTPUT.PUT_LINE('x_msg_data           = ' || x_msg_data);

END Create_Nested_Region_Item;


PROCEDURE Delete_Nested_Region_Item(
                 p_commit                    VARCHAR2 := FND_API.G_FALSE,
                 p_Root_AK_Region            VARCHAR2,
                 p_Application_Id            NUMBER,
                 p_Nested_Region_Code        VARCHAR2,
                 x_return_status             OUT NOCOPY VARCHAR2,
                 x_msg_count                 OUT NOCOPY NUMBER,
                 x_msg_data                  OUT NOCOPY VARCHAR2
) IS
      l_Attribute_Code_Tbl    BISVIEWER.t_char ;
      l_Attribute_App_Id_Tbl  BISVIEWER.t_num ;
BEGIN

      l_Attribute_Code_Tbl(1) := p_Nested_Region_Code;
      l_Attribute_App_Id_Tbl(1) := BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID;

      BIS_PMV_REGION_ITEMS_PVT.DELETE_REGION_ITEMS
      (       p_commit                 => p_commit
          ,   p_region_code            => p_Root_AK_Region
          ,   p_region_application_id  => p_Application_Id
          ,   p_Attribute_Code_Tbl     => l_Attribute_Code_Tbl
          ,   p_Attribute_Appl_Id_Tbl  => l_Attribute_App_Id_Tbl
          ,   x_return_status          => x_return_status
          ,   x_msg_count              => x_msg_count
          ,   x_msg_data               => x_msg_data
      );

END Delete_Nested_Region_Item;

/*
  This private function is to test whether parameter is null or not.
*/
FUNCTION IS_NOT_NULL(p_name VARCHAR2)
  RETURN VARCHAR2 IS
  BEGIN
    IF (p_name IS NULL) THEN
      RETURN FND_API.G_FALSE;
    END IF;
    RETURN FND_API.G_TRUE;
END IS_NOT_NULL;


/*this function will return 'T' (FND_API.G_TRUE) if the passed short_name of KPI Group
  is created through KPI End to End module otherwise 'F' (FND_API.G_FALSE)

  This function assumes the Short_Name passed is valid and exists in
  BSC Metadata. It will not be checked from BSC tables due to performance reasons.

  p_Short_Name Corresponds to BSC_TAB_IND_GROUPS_B.Short_Name
*/
FUNCTION is_KPI_EndToEnd_Group(p_Short_Name VARCHAR2)
  RETURN VARCHAR2 IS
  BEGIN
    RETURN IS_NOT_NULL(p_Short_Name);
  EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END is_KPI_EndToEnd_Group;


/*this function will return 'T' (FND_API.G_TRUE) if the passed short_name of KPI
  is created through KPI End to End module otherwise 'F' (FND_API.G_FALSE)

  This function assumes the Short_Name passed is valid and exists in
  BSC Metadata. It will not be checked from BSC tables due to performance reasons.

  p_Short_Name Corresponds to BSC_KPIS_B.Short_Name
*/
 FUNCTION is_KPI_EndToEnd_KPI(p_Short_Name VARCHAR2)
 RETURN VARCHAR2 IS
  BEGIN
    RETURN IS_NOT_NULL(p_Short_Name);
  EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
 END is_KPI_EndToEnd_KPI;

FUNCTION is_KPI_EndToEnd_AnaOpt(p_Short_Name VARCHAR2)
  RETURN VARCHAR2 IS
  BEGIN
    RETURN IS_NOT_NULL(p_Short_Name);
  EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END is_KPI_EndToEnd_AnaOpt;



/*this function will return 'T' (FND_API.G_TRUE) if the passed short_name of Dimension Object
  is created through KPI End to End module otherwise 'F' (FND_API.G_FALSE)

  This function assumes the Short_Name passed is valid and exists in
  BSC Metadata. It will not be checked from BSC tables due to performance reasons.

  p_Short_Name Corresponds to BSC_SYS_DIM_LEVELS_B.Short_Name
*/
FUNCTION is_KPI_EndToEnd_DimObject(p_Short_Name VARCHAR2)
RETURN VARCHAR2 IS
  l_Count NUMBER;
BEGIN
    IF (p_Short_Name IS NULL) THEN
        RETURN FND_API.G_FALSE;
    END IF;

    l_Count := 0;

    SELECT COUNT(1) INTO l_Count
    FROM   AK_REGION_ITEMS
    WHERE  Attribute_Code            = p_Short_Name;
    --AND    Attribute_Application_Id  = 271;

    IF (l_Count = 0) THEN
        RETURN FND_API.G_FALSE;
    ELSE
        RETURN FND_API.G_TRUE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END is_KPI_EndToEnd_DimObject;


/*this function will return 'T' (FND_API.G_TRUE) if the passed short_name of Dimension
  is created through KPI End to End module otherwise 'F' (FND_API.G_FALSE)

  This function assumes the Short_Name passed is valid and exists in
  BSC Metadata. It will not be checked from BSC tables due to performance reasons.

  p_Short_Name Corresponds to BSC_SYS_DIM_GROUPS_TL.Short_Name
*/
FUNCTION is_KPI_EndToEnd_Dimension(p_Short_Name VARCHAR2)
RETURN VARCHAR2 IS
  l_Count NUMBER;
BEGIN
    IF (p_Short_Name IS NULL) THEN
        RETURN FND_API.G_FALSE;
    END IF;

    l_Count := 0;

    SELECT COUNT(1) INTO l_Count
    FROM   AK_REGIONS
    WHERE  Region_Code           = p_Short_Name;
    --AND    Region_Application_Id = 271;--hardcoded application id will be removed with a constant

    IF (l_Count = 0) THEN
        RETURN FND_API.G_FALSE;
    ELSE
        RETURN FND_API.G_TRUE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END is_KPI_EndToEnd_Dimension;


-- This function is scalable only to 99 region items for any regions,
-- if more is required, then we need to modify the API

FUNCTION get_Unique_Attribute_Code (
               p_Region_Code         IN VARCHAR2
             , p_Measure_Short_Name  IN VARCHAR2
             , p_Append_String       IN VARCHAR2
) RETURN VARCHAR2 IS

  l_short_name    VARCHAR2(30);
  l_attr_code     VARCHAR2(30);

  l_temp1         VARCHAR2(30);
  l_temp2         VARCHAR2(30);
  l_appended      VARCHAR2(30);

  l_append_string VARCHAR2(5);

  l_final_string  VARCHAR2(30);

  l_len1          NUMBER;
  l_len2          NUMBER;

  l_exist_cnt     NUMBER;
BEGIN

  l_short_name    := p_Measure_Short_Name;
  l_append_string := p_Append_String;

  l_len1 := LENGTH(l_short_name);
  l_len2 := LENGTH(l_append_string);

  l_exist_cnt := 1;
  --bug 4525431 handled cases where l_short_name length is 28 or 30

  IF((l_len1 + l_len2) >  30) THEN
    l_temp1    := SUBSTR(l_short_name, 1, (l_len1-(LENGTH(l_Append_String)+2)));
    l_appended := l_temp1;

    WHILE (l_exist_cnt <> 0) LOOP
      l_appended := BSC_UTILITY.get_Next_DispName(l_appended);
      l_temp2 := REPLACE(l_appended , ' ', '_');
      l_Final_String := l_temp2 || l_Append_String;

      SELECT COUNT(1) INTO l_exist_cnt
      FROM   AK_REGION_ITEMS
      WHERE  REGION_CODE    = p_Region_Code
      AND    ATTRIBUTE_CODE = l_final_string;
    END LOOP;
  ELSE
    l_final_string := l_short_name || l_append_string;
  END IF;

  RETURN l_final_string;

END get_Unique_Attribute_Code;

/*
    Create Wrapper for Generic Region Item Creation
*/

PROCEDURE Create_Sim_Generic_Region_Item(
      p_commit                       IN VARCHAR2 := FND_API.G_FALSE
    , p_Region_Code                  IN VARCHAR2
    , p_Region_Application_Id        IN NUMBER
    , p_Attribute_Code               IN VARCHAR2
    , p_Attribute_Application_Id     IN NUMBER
    , p_Display_Sequence             IN NUMBER
    , p_Node_Display_Flag            IN VARCHAR2
    , p_Required_Flag                IN VARCHAR2
    , p_Queryable_Flag               IN VARCHAR2
    , p_Display_Length               IN NUMBER
    , p_Long_Label                   IN VARCHAR2
    , p_Url                          IN VARCHAR2
    , p_Attribute_Type               IN VARCHAR2
    , p_Display_Format               IN VARCHAR2
    , p_Display_Type                 IN VARCHAR2
    , p_Measure_Level                IN VARCHAR2
    , p_Base_Column                  IN VARCHAR2
    , p_Graph_Position               IN NUMBER
    , p_Graph_Style                  IN VARCHAR2
    , p_Aggregate_Function           IN VARCHAR2
    , p_Display_Total                IN VARCHAR2
    , p_Graph_Measure_Type           IN VARCHAR2
    , p_Item_Style                   IN VARCHAR2
    , p_Grand_Total_Flag             IN VARCHAR2
    , p_Nested_Region_Code           IN VARCHAR2
    , p_Nested_Region_Application_Id IN NUMBER
    , x_return_status            OUT NOCOPY VARCHAR2
    , x_msg_count                OUT NOCOPY NUMBER
    , x_msg_data                 OUT NOCOPY VARCHAR2
) IS

    l_region_item_rec                             BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type;
    l_region_item_table_measure                   BIS_AK_REGION_PUB.Bis_Region_Item_Tbl_Type;
BEGIN

    l_region_item_rec.Attribute_Code                := p_Attribute_Code;
    l_region_item_rec.Attribute_Application_Id      := p_Attribute_Application_Id;
    l_region_item_rec.Display_Sequence              := p_Display_Sequence;
    l_region_item_rec.Node_Display_Flag             := p_Node_Display_Flag;
    l_region_item_rec.Required_Flag                 := p_Required_Flag;
    l_region_item_rec.Queryable_Flag                := p_Queryable_Flag;
    l_region_item_rec.Display_Length                := p_Display_Length;
    l_region_item_rec.Long_Label                    := p_Long_Label;
    l_region_item_rec.Sort_Sequence                 := NULL;
    l_region_item_rec.Initial_Sort_Sequence         := NULL;
    l_region_item_rec.Sort_Direction                := NULL;
    l_region_item_rec.Url                           := p_Url;
    l_region_item_rec.Attribute_Type                := p_Attribute_Type;
    l_region_item_rec.Display_Format                := p_Display_Format;
    l_region_item_rec.Display_Type                  := p_Display_Type;
    l_region_item_rec.Measure_Level                 := p_Measure_Level;
    l_region_item_rec.Base_Column                   := p_Base_Column;
    l_region_item_rec.Lov_Where_Clause              := NULL;
    l_region_item_rec.Graph_Position                := p_Graph_Position;
    l_region_item_rec.Graph_Style                   := NULL;
    l_region_item_rec.Lov_Table                     := NULL;
    l_region_item_rec.Aggregate_Function            := p_Aggregate_Function;
    l_region_item_rec.Display_Total                 := p_Display_Total;
    l_region_item_rec.Variance                      := NULL;
    l_region_item_rec.Schedule                      := NULL;
    l_region_item_rec.Override_Hierarchy            := NULL;
    l_region_item_rec.Additional_View_By            := NULL;
    l_region_item_rec.Rolling_Lookup                := NULL;
    l_region_item_rec.Operator_Lookup               := NULL;
    l_region_item_rec.Dual_YAxis_Graphs             := NULL;
    l_region_item_rec.Custom_View_Name              := NULL;
    l_region_item_rec.Graph_Measure_Type            := p_Graph_Measure_Type;
    l_region_item_rec.Hide_Target_In_Table          := NULL;
    l_region_item_rec.Parameter_Render_Type         := NULL;
    l_region_item_rec.Privilege                     := NULL;
    l_region_item_rec.Item_Style                    := p_Item_Style;
    l_region_item_rec.Grand_Total_Flag              := p_Grand_Total_Flag;
    l_region_item_rec.Nested_Region_Code            := p_Nested_Region_Code;
    l_region_item_rec.Nested_Region_Application_Id  := p_Nested_Region_Application_Id;


    l_region_item_table_measure(1) := l_region_item_rec;

    BIS_PMV_REGION_ITEMS_PVT.CREATE_REGION_ITEMS(
        p_commit                 => p_commit
       ,p_region_code            => p_Region_Code
       ,p_region_application_id  => p_Region_Application_Id
       ,p_Region_Item_Tbl        => l_region_item_table_measure
       ,x_return_status          => x_return_status
       ,x_msg_count              => x_msg_count
       ,x_msg_data               => x_msg_data
    );

END Create_Sim_Generic_Region_Item;

/*
 The API creates a All additional Region Items for the specified
 AK Region
*/
PROCEDURE Create_Addl_Ak_Region_Items(
      p_commit                       IN VARCHAR2 := FND_API.G_FALSE
    , p_Region_Code                  IN VARCHAR2
    , p_Region_Application_Id        IN NUMBER
    , p_Display_Sequence             IN NUMBER
    , p_Display_Format               IN VARCHAR2
    , p_Format_Id                    IN NUMBER
    , p_Measure_Short_Name           IN VARCHAR2
    , p_Param_Portlet_Region_Code    IN VARCHAR2
    , p_Analysis_Option_Name         IN VARCHAR2
    , p_Kpi_Id                       IN NUMBER
    , x_return_status            OUT NOCOPY VARCHAR2
    , x_msg_count                OUT NOCOPY NUMBER
    , x_msg_data                 OUT NOCOPY VARCHAR2
) IS
    l_Attribute_Code               VARCHAR2(30);
    l_Compare_Column               VARCHAR2(30);
    l_Lookup_Meaning               VARCHAR2(80);
    l_Colspan_Attr_Code            VARCHAR2(30);
    l_Format_Type                  VARCHAR2(3);
    l_Base_Column                  NUMBER;
    l_has_comp_or_plan             BOOLEAN;
    l_non_time_dimension_groups    BSC_BIS_KPI_CRUD_PUB.BSC_VARCHAR2_TBL_TYPE;
    l_non_time_dimension_objects   BSC_BIS_KPI_CRUD_PUB.BSC_VARCHAR2_TBL_TYPE;
    l_non_time_dim_obj_short_names VARCHAR2(32000);
    l_all_dim_group_ids            BSC_BIS_KPI_CRUD_PUB.BSC_NUMBER_TBL_TYPE;
    l_non_time_counter             NUMBER;
    l_time_dimension_groups        BSC_BIS_KPI_CRUD_PUB.BSC_VARCHAR2_TBL_TYPE;
    l_time_dimension_objects       BSC_BIS_KPI_CRUD_PUB.BSC_VARCHAR2_TBL_TYPE;
    l_time_dim_obj_short_names     VARCHAR2(32000);
    l_time_counter                 NUMBER;
    l_msg_data                     VARCHAR2(2000);
BEGIN

    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_has_comp_or_plan := BSC_BIS_KPI_CRUD_PUB.Has_Compare_To_Or_Plan (p_Param_Portlet_Region_Code);

    -- Create a new Nested Region Item (with Param Region Code)
    Create_Sim_Generic_Region_Item(
          p_commit                       => p_Commit
        , p_Region_Code                  => p_Region_Code
        , p_Region_Application_Id        => p_Region_Application_Id
        , p_Attribute_Code               => p_Param_Portlet_Region_Code
        , p_Attribute_Application_Id     => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
        , p_Display_Sequence             => (p_Display_Sequence + 10)
        , p_Node_Display_Flag            => 'Y'
        , p_Required_Flag                => ' '
        , p_Queryable_Flag               => ' '
        , p_Display_Length               => 0
        , p_Long_Label                   => NULL
        , p_Url                          => NULL
        , p_Attribute_Type               => NULL
        , p_Display_Format               => NULL
        , p_Display_Type                 => NULL
        , p_Measure_Level                => NULL
        , p_Base_Column                  => NULL
        , p_Graph_Position               => NULL
        , p_Graph_Style                  => NULL
        , p_Aggregate_Function           => NULL
        , p_Display_Total                => NULL
        , p_Graph_Measure_Type           => NULL
        , p_Item_Style                   => BIS_AK_REGION_PUB.c_NESTED_REGION_STYLE
        , p_Grand_Total_Flag             => NULL
        , p_Nested_Region_Code           => p_Param_Portlet_Region_Code
        , p_Nested_Region_Application_Id => Get_Region_Application_Id(p_Param_Portlet_Region_Code)
        , x_return_status                => x_return_status
        , x_msg_count                    => x_msg_count
        , x_msg_data                     => x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ---------------------------------------------------------------------
    /*
      If time parameter is not present in parameter portlet, we need to create a
      Daily Periodicity time parameter and pass it on to PMV
      Added by visuri for Enhancement 4065098
    */

    BSC_BIS_KPI_CRUD_PUB.Get_Dim_Info_From_Region_Code(
        p_param_portlet_region_code=>p_Param_Portlet_Region_Code
       ,x_non_time_dimension_groups=>l_non_time_dimension_groups
       ,x_non_time_dimension_objects=>l_non_time_dimension_objects
       ,x_non_time_dim_obj_short_names=> l_non_time_dim_obj_short_names
       ,x_all_dim_group_ids=>l_all_dim_group_ids
       ,x_non_time_counter=>l_non_time_counter
       ,x_time_dimension_groups=>l_time_dimension_groups
       ,x_time_dimension_objects=>l_time_dimension_objects
       ,x_time_dim_obj_short_names=>l_time_dim_obj_short_names
       ,x_time_counter=>l_time_counter
       ,x_msg_data=>l_msg_data
       );

    IF (l_msg_data IS NOT NULL) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_time_dim_obj_short_names IS NULL) THEN

       BSC_BIS_KPI_CRUD_PUB.Create_Sim_Generic_Region_Item(
             p_commit                      => p_Commit
           , p_Region_Code                 => p_Region_Code
           , p_Region_Application_Id       => p_Region_Application_Id
           , p_Attribute_Code              => BSC_BIS_KPI_CRUD_PUB.C_DAILY_PERIOD_ATTR_CODE
           , p_Attribute_Application_Id    => BSC_BIS_KPI_CRUD_PUB.C_BIS_APPLICATION_ID
           , p_Display_Sequence            =>(p_Display_Sequence + 15)
           , p_Node_Display_Flag           => 'N'
           , p_Required_Flag               => 'N'
           , p_Queryable_Flag              => 'Y'
           , p_Display_Length              => 0
           , p_Long_Label                  => NULL
           , p_Url                         => NULL
           , p_Attribute_Type              => BSC_BIS_KPI_CRUD_PUB.C_HIDE_PARAMETER
           , p_Display_Format              => NULL
           , p_Display_Type                => NULL
           , p_Measure_Level               => BSC_BIS_KPI_CRUD_PUB.C_DAILY_PERIOD_ATTR2
           , p_Base_Column                 => NULL
           , p_Graph_Position              => NULL
           , p_Graph_Style                 => NULL
           , p_Aggregate_Function          => NULL
           , p_Display_Total               => NULL
           , p_Graph_Measure_Type          => NULL
           , p_Item_Style                  => NULL
           , p_Grand_Total_Flag            => NULL
           , p_Nested_Region_Code          => NULL
           , p_Nested_Region_Application_Id=> NULL
           , x_return_status               => x_return_status
           , x_msg_count                   => x_msg_count
           , x_msg_data                    => x_msg_data
    );


    END IF;

    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    ---------------------------------------------------------------------

    -- Get the column spand attribute code.
    l_Colspan_Attr_Code := get_Unique_Attribute_Code (
                              p_Region_Code         => p_Region_Code
                            , p_Measure_Short_Name  => p_Measure_Short_Name
                            , p_Append_String       => BSC_BIS_KPI_CRUD_PUB.C_COLSPAN
                         );


    -- Create a new Measure Region Item
    -- Added Graph_Position = 1 for Bug#3742500
    Create_Sim_Generic_Region_Item(
          p_commit                       => p_Commit
        , p_Region_Code                  => p_Region_Code
        , p_Region_Application_Id        => p_Region_Application_Id
        , p_Attribute_Code               => p_Measure_Short_Name
        , p_Attribute_Application_Id     => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
        , p_Display_Sequence             => (p_Display_Sequence + 20)
        , p_Node_Display_Flag            => 'Y'
        , p_Required_Flag                => ' '
        , p_Queryable_Flag               => ' '
        , p_Display_Length               => NVL(LENGTH(p_Analysis_Option_Name), 0)
        , p_Long_Label                   => p_Analysis_Option_Name
        , p_Url                          => NULL
        , p_Attribute_Type               => BSC_BIS_KPI_CRUD_PUB.C_MEASURE_ATTRIBURE_TYPE
        , p_Display_Format               => p_Display_Format
        , p_Display_Type                 => BSC_BIS_KPI_CRUD_PUB.C_AUTOFACTOR_GROUP1
        , p_Measure_Level                => p_Measure_Short_Name  --Earlier COLSPAN l_Colspan_Attr_Code -- COLSPAN Attribute as level
        , p_Base_Column                  => NULL
        , p_Graph_Position               => 1
        , p_Graph_Style                  => NULL
        , p_Aggregate_Function           => NULL
        , p_Display_Total                => 'Y'
        , p_Graph_Measure_Type           => NULL
        , p_Item_Style                   => NULL
        , p_Grand_Total_Flag             => 'Y'
        , p_Nested_Region_Code           => NULL
        , p_Nested_Region_Application_Id => NULL
        , x_return_status                => x_return_status
        , x_msg_count                    => x_msg_count
        , x_msg_data                     => x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


  -- Create a Compare-To Region Item
    IF (l_has_comp_or_plan) THEN
      l_Attribute_Code := get_Unique_Attribute_Code (
                              p_Region_Code         => p_Region_Code
                            , p_Measure_Short_Name  => p_Measure_Short_Name
                            , p_Append_String       => BSC_BIS_KPI_CRUD_PUB.C_COMPARISON_APPEND_STRING
                         );
      l_Compare_Column := l_Attribute_Code;

      l_Lookup_Meaning := BSC_APPS.GET_LOOKUP_VALUE('BSC_UI_BACKEND', 'COMPARE_TO');  -- creates Prior
      -- No lookup for Compare To
      Create_Sim_Generic_Region_Item(
          p_commit                       => p_Commit
        , p_Region_Code                  => p_Region_Code
        , p_Region_Application_Id        => p_Region_Application_Id
        , p_Attribute_Code               => l_Attribute_Code
        , p_Attribute_Application_Id     => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
        , p_Display_Sequence             => p_Display_Sequence + 30
        , p_Node_Display_Flag            => 'Y'
        , p_Required_Flag                => ' '
        , p_Queryable_Flag               => ' '
        , p_Display_Length               => NVL(LENGTH(l_Lookup_Meaning), 0)
        , p_Long_Label                   => l_Lookup_Meaning
        , p_Url                          => NULL
        , p_Attribute_Type               => BSC_BIS_KPI_CRUD_PUB.C_COMPARE_ATTRIBURE_TYPE
        , p_Display_Format               => p_Display_Format
        , p_Display_Type                 => BSC_BIS_KPI_CRUD_PUB.C_AUTOFACTOR_GROUP1
        , p_Measure_Level                => p_Measure_Short_Name
        , p_Base_Column                  => NULL
        , p_Graph_Position               => 1
        , p_Graph_Style                  => NULL
        , p_Aggregate_Function           => NULL
        , p_Display_Total                => 'Y'
        , p_Graph_Measure_Type           => NULL
        , p_Item_Style                   => NULL
        , p_Grand_Total_Flag             => 'Y'
        , p_Nested_Region_Code           => NULL
        , p_Nested_Region_Application_Id => NULL
        , x_return_status                => x_return_status
        , x_msg_count                    => x_msg_count
        , x_msg_data                     => x_msg_data
      );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


    -- Create a Change Region Item

    -- Added for Bug#3919666
      l_Format_Type := BSC_BIS_KPI_CRUD_PUB.Get_Change_Disp_Type_By_Mask(p_Format_Id);

      IF (l_Format_Type = BSC_BIS_KPI_CRUD_PUB.C_FORMAT_INTEGER) THEN
         l_Base_Column := BSC_BIS_KPI_CRUD_PUB.C_CHANGE_TYPE_INTEGER;
      ELSE
         l_Base_Column := BSC_BIS_KPI_CRUD_PUB.C_CHANGE_TYPE_PERCENT;
      END IF;

      l_Attribute_Code := get_Unique_Attribute_Code (
                              p_Region_Code         => p_Region_Code
                            , p_Measure_Short_Name  => p_Measure_Short_Name
                            , p_Append_String       => BSC_BIS_KPI_CRUD_PUB.C_CHANGE_APPEND_STRING
                         );

      l_Lookup_Meaning := BSC_APPS.GET_LOOKUP_VALUE('BSC_UI_BACKEND', 'CHANGE');
      Create_Sim_Generic_Region_Item(
          p_commit                       => p_Commit
        , p_Region_Code                  => p_Region_Code
        , p_Region_Application_Id        => p_Region_Application_Id
        , p_Attribute_Code               => l_Attribute_Code
        , p_Attribute_Application_Id     => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
        , p_Display_Sequence             => (p_Display_Sequence + 40)
        , p_Node_Display_Flag            => 'Y'
        , p_Required_Flag                => ' '
        , p_Queryable_Flag               => ' '
        , p_Display_Length               => NVL(LENGTH(l_Lookup_Meaning), 0)
        , p_Long_Label                   => l_Lookup_Meaning
        , p_Url                          => NULL
        , p_Attribute_Type               => BSC_BIS_KPI_CRUD_PUB.C_CHANGE_ATTRIBURE_TYPE
        , p_Display_Format               => NULL
        , p_Display_Type                 => l_Format_Type
        , p_Measure_Level                => p_Measure_Short_Name -- Earlier using l_Colspan_Attr_Code -- COLSPAN Attribute as level
        , p_Base_Column                  => l_Base_Column
        , p_Graph_Position               => NULL
        , p_Graph_Style                  => NULL
        , p_Aggregate_Function           => NULL
        , p_Display_Total                => NULL
        , p_Graph_Measure_Type           => NULL
        , p_Item_Style                   => NULL
        , p_Grand_Total_Flag             => NULL
        , p_Nested_Region_Code           => NULL
        , p_Nested_Region_Application_Id => NULL
        , x_return_status                => x_return_status
        , x_msg_count                    => x_msg_count
        , x_msg_data                     => x_msg_data
      );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;


    -- Create a Region Item for COULMN SPAN
    -- As of now, we do not need Column Spanning as per Bug#3688263

    /*Create_Sim_Generic_Region_Item(
          p_commit                       => p_Commit
        , p_Region_Code                  => p_Region_Code
        , p_Region_Application_Id        => p_Region_Application_Id
        , p_Attribute_Code               => l_Colspan_Attr_Code
        , p_Attribute_Application_Id     => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
        , p_Display_Sequence             => (p_Display_Sequence + 70)
        , p_Node_Display_Flag            => 'Y'
        , p_Required_Flag                => ' '
        , p_Queryable_Flag               => ' '
        , p_Display_Length               => NVL(LENGTH(l_Colspan_Attr_Code), 0)
        , p_Long_Label                   => l_Colspan_Attr_Code
        , p_Url                          => NULL
        , p_Attribute_Type               => BSC_BIS_KPI_CRUD_PUB.C_COLUMN_SPAN_ATTRIBURE_TYPE
        , p_Display_Format               => NULL
        , p_Display_Type                 => NULL
        , p_Measure_Level                => NULL
        , p_Base_Column                  => NULL
        , p_Graph_Position               => NULL
        , p_Graph_Style                  => NULL
        , p_Aggregate_Function           => NULL
        , p_Display_Total                => NULL
        , p_Graph_Measure_Type           => NULL
        , p_Item_Style                   => NULL
        , p_Nested_Region_Code           => NULL
        , p_Nested_Region_Application_Id => NULL
        , x_return_status                => x_return_status
        , x_msg_count                    => x_msg_count
        , x_msg_data                     => x_msg_data
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF; */

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

    WHEN NO_DATA_FOUND THEN
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Create_Addl_Ak_Region_Items ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Create_Addl_Ak_Region_Items ';
        END IF;
    WHEN OTHERS THEN
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Create_Addl_Ak_Region_Items ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Create_Addl_Ak_Region_Items ';
        END IF;
END Create_Addl_Ak_Region_Items;


PROCEDURE Delete_Misc_Region_Items(
             p_commit                    VARCHAR2 := FND_API.G_FALSE,
             p_Region_Code               VARCHAR2,
             p_Application_Id            NUMBER,
             x_return_status             OUT NOCOPY VARCHAR2,
             x_msg_count                 OUT NOCOPY NUMBER,
             x_msg_data                  OUT NOCOPY VARCHAR2
) IS
      l_Attribute_Code_Tbl    BISVIEWER.t_char ;
      l_Attribute_App_Id_Tbl  BISVIEWER.t_num ;

      l_index                NUMBER;

      CURSOR c_Attrs IS
        SELECT ATTRIBUTE_CODE, ATTRIBUTE_APPLICATION_ID
        FROM   AK_REGION_ITEMS
        WHERE  REGION_CODE = p_Region_Code;
BEGIN
      l_index := 1;

      FOR cattr IN c_Attrs LOOP
          l_Attribute_Code_Tbl(l_index)   := cattr.ATTRIBUTE_CODE;
          l_Attribute_App_Id_Tbl(l_index) := cattr.ATTRIBUTE_APPLICATION_ID;

          l_index := l_index + 1;
      END LOOP;

      BIS_PMV_REGION_ITEMS_PVT.DELETE_REGION_ITEMS
      (       p_commit                 => p_commit
          ,   p_region_code            => p_Region_Code
          ,   p_region_application_id  => p_Application_Id
          ,   p_Attribute_Code_Tbl     => l_Attribute_Code_Tbl
          ,   p_Attribute_Appl_Id_Tbl  => l_Attribute_App_Id_Tbl
          ,   x_return_status          => x_return_status
          ,   x_msg_count              => x_msg_count
          ,   x_msg_data               => x_msg_data
      );



      --DBMS_OUTPUT.PUT_LINE('Delete_Misc_Region_Items (x_msg_data) - ' || x_msg_data);
      --DBMS_OUTPUT.PUT_LINE('Delete_Misc_Region_Items (x_return_status) - ' || x_return_status);

END Delete_Misc_Region_Items;



/*
    Update Wrapper for Generic Region Item Creation
*/

PROCEDURE Update_Sim_Generic_Region_Item(
      p_commit                       IN VARCHAR2 := FND_API.G_FALSE
    , p_Region_Code                  IN VARCHAR2
    , p_Region_Application_Id        IN NUMBER
    , p_Attribute_Code               IN VARCHAR2
    , p_Attribute_Application_Id     IN NUMBER
    , p_Display_Sequence             IN NUMBER
    , p_Node_Display_Flag            IN VARCHAR2
    , p_Required_Flag                IN VARCHAR2
    , p_Queryable_Flag               IN VARCHAR2
    , p_Display_Length               IN NUMBER
    , p_Long_Label                   IN VARCHAR2
    , p_Url                          IN VARCHAR2
    , p_Attribute_Type               IN VARCHAR2
    , p_Display_Format               IN VARCHAR2
    , p_Display_Type                 IN VARCHAR2
    , p_Measure_Level                IN VARCHAR2
    , p_Base_Column                  IN VARCHAR2
    , p_Graph_Position               IN NUMBER
    , p_Graph_Style                  IN VARCHAR2
    , p_Aggregate_Function           IN VARCHAR2
    , p_Display_Total                IN VARCHAR2
    , p_Graph_Measure_Type           IN VARCHAR2
    , p_Item_Style                   IN VARCHAR2
    , p_Grand_Total_Flag             IN VARCHAR2
    , p_Nested_Region_Code           IN VARCHAR2
    , p_Nested_Region_Application_Id IN NUMBER
    , x_return_status            OUT NOCOPY VARCHAR2
    , x_msg_count                OUT NOCOPY NUMBER
    , x_msg_data                 OUT NOCOPY VARCHAR2
) IS

    l_region_item_rec                             BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type;
    l_region_item_table_measure                   BIS_AK_REGION_PUB.Bis_Region_Item_Tbl_Type;


BEGIN

    l_region_item_rec.Attribute_Code                := p_Attribute_Code;
    l_region_item_rec.Attribute_Application_Id      := p_Attribute_Application_Id;
    l_region_item_rec.Display_Sequence              := p_Display_Sequence;
    l_region_item_rec.Node_Display_Flag             := p_Node_Display_Flag;
    l_region_item_rec.Required_Flag                 := p_Required_Flag;
    l_region_item_rec.Queryable_Flag                := p_Queryable_Flag;
    l_region_item_rec.Display_Length                := p_Display_Length;
    l_region_item_rec.Long_Label                    := p_Long_Label;
    l_region_item_rec.Sort_Sequence                 := NULL;
    l_region_item_rec.Initial_Sort_Sequence         := NULL;
    l_region_item_rec.Sort_Direction                := NULL;
    l_region_item_rec.Url                           := p_Url;
    l_region_item_rec.Attribute_Type                := p_Attribute_Type;
    l_region_item_rec.Display_Format                := p_Display_Format;
    l_region_item_rec.Display_Type                  := p_Display_Type;
    l_region_item_rec.Measure_Level                 := p_Measure_Level;
    l_region_item_rec.Base_Column                   := p_Base_Column;
    l_region_item_rec.Lov_Where_Clause              := NULL;
    l_region_item_rec.Graph_Position                := p_Graph_Position;
    l_region_item_rec.Graph_Style                   := NULL;
    l_region_item_rec.Lov_Table                     := NULL;
    l_region_item_rec.Aggregate_Function            := p_Aggregate_Function;
    l_region_item_rec.Display_Total                 := p_Display_Total;
    l_region_item_rec.Variance                      := NULL;
    l_region_item_rec.Schedule                      := NULL;
    l_region_item_rec.Override_Hierarchy            := NULL;
    l_region_item_rec.Additional_View_By            := NULL;
    l_region_item_rec.Rolling_Lookup                := NULL;
    l_region_item_rec.Operator_Lookup               := NULL;
    l_region_item_rec.Dual_YAxis_Graphs             := NULL;
    l_region_item_rec.Custom_View_Name              := NULL;
    l_region_item_rec.Graph_Measure_Type            := p_Graph_Measure_Type;
    l_region_item_rec.Hide_Target_In_Table          := NULL;
    l_region_item_rec.Parameter_Render_Type         := NULL;
    l_region_item_rec.Privilege                     := NULL;
    l_region_item_rec.Item_Style                    := p_Item_Style;
    l_region_item_rec.Grand_Total_Flag              := p_Grand_Total_Flag;
    l_region_item_rec.Nested_Region_Code            := p_Nested_Region_Code;
    l_region_item_rec.Nested_Region_Application_Id  := p_Nested_Region_Application_Id;


    l_region_item_table_measure(1) := l_region_item_rec;

    BIS_PMV_REGION_ITEMS_PVT.UPDATE_REGION_ITEMS(
        p_commit                 => p_commit
       ,p_region_code            => p_Region_Code
       ,p_region_application_id  => p_Region_Application_Id
       ,p_Region_Item_Tbl        => l_region_item_table_measure
       ,x_return_status          => x_return_status
       ,x_msg_count              => x_msg_count
       ,x_msg_data               => x_msg_data
    );


END Update_Sim_Generic_Region_Item;



PROCEDURE Update_Addl_Ak_Region_Items(
      p_commit                       IN VARCHAR2 := FND_API.G_FALSE
    , p_Region_Code                  IN VARCHAR2
    , p_Region_Application_Id        IN NUMBER
    , p_Display_Format               IN VARCHAR2
    , p_Format_id                    IN NUMBER
    , p_Measure_Short_Name           IN VARCHAR2
    , x_return_status            OUT NOCOPY VARCHAR2
    , x_msg_count                OUT NOCOPY NUMBER
    , x_msg_data                 OUT NOCOPY VARCHAR2
) IS
    l_Attribute_Code   VARCHAR2(30);
    l_Compare_Column   VARCHAR2(30);
    l_Display_Sequence NUMBER;
    l_Lookup_Value     VARCHAR2(80);
    l_Colspan_Attr_Code VARCHAR2(30);

    l_Format_Type       VARCHAR2(3);
    l_Base_Column       NUMBER;

    CURSOR c_Upd_Change IS
        SELECT ATTRIBUTE_CODE
        FROM   AK_REGION_ITEMS
        WHERE  REGION_CODE = p_Region_Code
        AND    ATTRIBUTE1  = BSC_BIS_KPI_CRUD_PUB.C_CHANGE_ATTRIBURE_TYPE;

    CURSOR c_Upd_CompareTo IS
        SELECT ATTRIBUTE_CODE
        FROM   AK_REGION_ITEMS
        WHERE  REGION_CODE = p_Region_Code
        AND    ATTRIBUTE1  = BSC_BIS_KPI_CRUD_PUB.C_COMPARE_ATTRIBURE_TYPE;

    CURSOR c_Upd_GT_Actual IS
        SELECT ATTRIBUTE_CODE
        FROM   AK_REGION_ITEMS
        WHERE  REGION_CODE = p_Region_Code
        AND    ATTRIBUTE1  = BSC_BIS_KPI_CRUD_PUB.C_GRAND_TOTAL_ATTRIBURE_TYPE
        AND    ATTRIBUTE3  = p_Measure_Short_Name;

    CURSOR c_Upd_GT_Compare IS
        SELECT ATTRIBUTE_CODE
        FROM   AK_REGION_ITEMS
        WHERE  REGION_CODE = p_Region_Code
        AND    ATTRIBUTE1  = BSC_BIS_KPI_CRUD_PUB.C_GRAND_TOTAL_ATTRIBURE_TYPE
        AND    ATTRIBUTE3  = l_Compare_Column;

BEGIN

    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;



    l_Colspan_Attr_Code := get_Unique_Attribute_Code (
                              p_Region_Code         => p_Region_Code
                            , p_Measure_Short_Name  => p_Measure_Short_Name
                            , p_Append_String       => BSC_BIS_KPI_CRUD_PUB.C_COLSPAN
                         );

    -- Update a Compare-To Region Item
    FOR cUComp IN c_Upd_CompareTo LOOP

        l_Attribute_Code := cUComp.Attribute_Code;
        l_Compare_Column := l_Attribute_Code;
        l_Display_Sequence := Get_Sequence_Id_By_Region(
                                 p_Region_Code               => p_Region_Code
                               , p_Region_Application_Id     => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
                               , p_Attribute_Code            => l_Attribute_Code
                               , p_Attribute_Application_Id  => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
                              );

        -- currently we do not have lookup for "Compare To"
        l_Lookup_Value := BSC_APPS.GET_LOOKUP_VALUE('BSC_UI_BACKEND', 'COMPARE_TO');

        Update_Sim_Generic_Region_Item(
              p_commit                       => p_Commit
            , p_Region_Code                  => p_Region_Code
            , p_Region_Application_Id        => p_Region_Application_Id
            , p_Attribute_Code               => l_Attribute_Code
            , p_Attribute_Application_Id     => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
            , p_Display_Sequence             => l_Display_Sequence
            , p_Node_Display_Flag            => 'Y'
            , p_Required_Flag                => ' '
            , p_Queryable_Flag               => ' '
            , p_Display_Length               => LENGTH(l_Lookup_Value)
            , p_Long_Label                   => l_Lookup_Value
            , p_Url                          => NULL
            , p_Attribute_Type               => BSC_BIS_KPI_CRUD_PUB.C_COMPARE_ATTRIBURE_TYPE
            , p_Display_Format               => p_Display_Format
            , p_Display_Type                 => BSC_BIS_KPI_CRUD_PUB.C_AUTOFACTOR_GROUP1
            , p_Measure_Level                => p_Measure_Short_Name
            , p_Base_Column                  => NULL
            , p_Graph_Position               => 1
            , p_Graph_Style                  => NULL
            , p_Aggregate_Function           => NULL
            , p_Display_Total                => 'Y'
            , p_Graph_Measure_Type           => NULL
            , p_Item_Style                   => NULL
            , p_Grand_Total_Flag             => 'Y'
            , p_Nested_Region_Code           => NULL
            , p_Nested_Region_Application_Id => NULL
            , x_return_status                => x_return_status
            , x_msg_count                    => x_msg_count
            , x_msg_data                     => x_msg_data
        );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;


    -- Update a Change Region Item
    -- Bug#3688263, should not be using Column Spanning.

    FOR cUChange IN c_Upd_Change LOOP

        l_Attribute_Code := cUChange.Attribute_Code;

        l_Display_Sequence := Get_Sequence_Id_By_Region(
                                 p_Region_Code               => p_Region_Code
                               , p_Region_Application_Id     => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
                               , p_Attribute_Code            => l_Attribute_Code
                               , p_Attribute_Application_Id  => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
                              );


        l_Lookup_Value := BSC_APPS.GET_LOOKUP_VALUE('BSC_UI_BACKEND', 'CHANGE');

        -- Added for Bug#3919666
        l_Format_Type := BSC_BIS_KPI_CRUD_PUB.Get_Change_Disp_Type_By_Mask(p_Format_Id);

        IF (l_Format_Type = BSC_BIS_KPI_CRUD_PUB.C_FORMAT_INTEGER) THEN
           l_Base_Column := BSC_BIS_KPI_CRUD_PUB.C_CHANGE_TYPE_INTEGER;
        ELSE
           l_Base_Column := BSC_BIS_KPI_CRUD_PUB.C_CHANGE_TYPE_PERCENT;
        END IF;


        Update_Sim_Generic_Region_Item(
              p_commit                       => p_Commit
            , p_Region_Code                  => p_Region_Code
            , p_Region_Application_Id        => p_Region_Application_Id
            , p_Attribute_Code               => l_Attribute_Code
            , p_Attribute_Application_Id     => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
            , p_Display_Sequence             => l_Display_Sequence
            , p_Node_Display_Flag            => 'Y'
            , p_Required_Flag                => ' '
            , p_Queryable_Flag               => ' '
            , p_Display_Length               => LENGTH(l_Lookup_Value)
            , p_Long_Label                   => l_Lookup_Value
            , p_Url                          => NULL
            , p_Attribute_Type               => BSC_BIS_KPI_CRUD_PUB.C_CHANGE_ATTRIBURE_TYPE
            , p_Display_Format               => NULL
            , p_Display_Type                 => l_Format_Type
            , p_Measure_Level                => p_Measure_Short_Name
            , p_Base_Column                  => l_Base_Column
            , p_Graph_Position               => NULL
            , p_Graph_Style                  => NULL
            , p_Aggregate_Function           => NULL
            , p_Display_Total                => NULL
            , p_Graph_Measure_Type           => NULL
            , p_Item_Style                   => NULL
            , p_Grand_Total_Flag             => NULL
            , p_Nested_Region_Code           => NULL
            , p_Nested_Region_Application_Id => NULL
            , x_return_status                => x_return_status
            , x_msg_count                    => x_msg_count
            , x_msg_data                     => x_msg_data
        );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;




EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

    WHEN NO_DATA_FOUND THEN
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Update_Addl_Ak_Region_Items ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Update_Addl_Ak_Region_Items ';
        END IF;
    WHEN OTHERS THEN
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Update_Addl_Ak_Region_Items ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Update_Addl_Ak_Region_Items ';
        END IF;
END Update_Addl_Ak_Region_Items;


FUNCTION Get_Measure_Group_Id (
               p_Kpi_Portlet_Function_Name  IN VARCHAR2,
               x_Return_Status              OUT NOCOPY VARCHAR2,
               x_Msg_Data                   OUT NOCOPY VARCHAR2

) RETURN NUMBER
IS

  l_Measure_Group_Id   NUMBER;
  x_Measure_Group_Id   NUMBER;

BEGIN

  SELECT MEASURE_GROUP_ID
  INTO   l_Measure_Group_Id
  FROM   BSC_DB_MEASURE_GROUPS_VL
  WHERE  UPPER(HELP) = UPPER(p_Kpi_Portlet_Function_Name);

  -- reason: help is used as name, and it's not unique.  We are trying to
  -- avoid the situation of having two same names with different cases.


  RETURN l_measure_group_id;



EXCEPTION

  WHEN NO_DATA_FOUND THEN

    -- insert a new row for the measure group
    BSC_DB_MEASURE_GROUPS_PKG.INSERT_ROW( x_Measure_Group_Id => x_Measure_Group_Id
                                         ,x_Help             => p_Kpi_Portlet_Function_Name
                                         ,x_Short_Name       => p_Kpi_Portlet_Function_Name);

    RETURN x_measure_group_id;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := BSC_APPS.GET_MESSAGE( 'BSC_KPI_ETE_MEASURE_GROUP_ERR');

    RETURN BSC_BIS_KPI_CRUD_PUB.c_measure_group_id_error;


END get_measure_group_id;


PROCEDURE is_Kpi_In_Production(
               p_Page_Function_Name   IN VARCHAR2
             , x_Is_Kpi_In_Production OUT NOCOPY VARCHAR2
) IS
  l_Prototype_Flag   NUMBER;
  l_Kpi_Id           NUMBER;

  CURSOR c_Production IS
    SELECT PROTOTYPE_FLAG
    FROM   BSC_KPIS_B
    WHERE  INDICATOR = l_Kpi_Id;

BEGIN
   l_Prototype_Flag := 3;

   l_Kpi_Id := Get_Kpi_Id(p_Page_Function_Name);

   FOR ckpi IN c_Production LOOP
     l_Prototype_Flag := ckpi.Prototype_Flag;
   END LOOP;

   IF (l_Prototype_Flag = 0) THEN
        x_Is_Kpi_In_Production := 'T';
   ELSE
        x_Is_Kpi_In_Production := 'F';
   END IF;
END is_Kpi_In_Production;


/*

Create a dimension for Parameter Portlet and associates
Dimension Object Properties with Dimensions.

*/

PROCEDURE Create_Dimension(
     p_Commit              IN VARCHAR2 := FND_API.G_FALSE
    ,p_Dim_Short_Name      IN VARCHAR2
    ,p_Display_Name        IN VARCHAR2
    ,p_Description         IN VARCHAR2
    ,p_Dim_Objs_Record     IN BSC_BIS_KPI_CRUD_PUB.BSC_VARCHAR2_TBL_TYPE
    ,p_Dim_Obj_Short_Names IN VARCHAR2
    ,p_Dim_Objects_Counter IN NUMBER
    ,p_Application_Id      IN NUMBER
    ,p_hide                IN VARCHAR2 := FND_API.G_FALSE
    ,x_Return_Status       OUT NOCOPY VARCHAR2
    ,x_Msg_Count           OUT NOCOPY NUMBER
    ,x_Msg_Data            OUT NOCOPY VARCHAR2
) IS
    l_Index               NUMBER;
    l_Total_Flag          NUMBER;
    l_Comparison_Flag     NUMBER;
    l_Where_Clause        BSC_SYS_DIM_LEVELS_BY_GROUP.WHERE_CLAUSE%TYPE;
    l_Dim_Obj_Short_Name  VARCHAR2(30);

    CURSOR c_Get_Prop_Dim IS
        SELECT D.TOTAL_FLAG,
               D.COMPARISON_FLAG,
               D.WHERE_CLAUSE
        FROM   BSC_SYS_DIM_GROUPS_TL        A,
               BIS_DIMENSIONS               B,
               BIS_LEVELS                   C,
               BSC_SYS_DIM_LEVELS_BY_GROUP  D,
               BSC_SYS_DIM_LEVELS_B         E
        WHERE  C.SHORT_NAME   = l_Dim_Obj_Short_Name
        AND    C.DIMENSION_ID = B.DIMENSION_ID
        AND    B.SHORT_NAME   = A.SHORT_NAME
        AND    A.LANGUAGE     = USERENV('LANG')
        AND    A.DIM_GROUP_ID = D.DIM_GROUP_ID
        AND    E.SHORT_NAME   = l_Dim_Obj_Short_Name
        AND    E.DIM_LEVEL_ID = D.DIM_LEVEL_ID;

   /* CURSOR c_temp IS
      select dim_group_id, dim_level_id, dim_level_index
      from   bsc_sys_dim_levels_by_group
      where  dim_group_id in
           (select dim_group_id
            from   bsc_sys_dim_groups_vl
            where  short_name = p_Dim_Short_Name);*/


BEGIN
    SAVEPOINT KpiCrudCreateDimension;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;


    -- Attempt to create a Dimension for the Parameter Portlet RegionCode.
    BSC_BIS_DIMENSION_PUB.Create_Dimension(
         p_commit              => p_Commit
        ,p_dim_short_name      => p_Dim_Short_Name
        ,p_display_name        => p_Dim_Short_Name
        ,p_description         => p_Dim_Short_Name
        ,p_dim_obj_short_names => p_Dim_Obj_Short_Names
        ,p_application_id      => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID -- BSC
        ,p_hide                => p_hide
        ,x_return_status       => x_Return_Status
        ,x_msg_count           => x_Msg_Count
        ,x_msg_data            => x_Msg_Data
    );

    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (c_Get_Prop_Dim%ISOPEN) THEN
        CLOSE c_Get_Prop_Dim;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('(step 13 b)p_Dim_Objects_Counter - ' || p_Dim_Objects_Counter);

    -- Assoicate Dimnension Object Properties within Dimension
   /* FOR l_Index in 1..p_Dim_Objects_Counter LOOP
        l_Dim_Obj_Short_Name := p_Dim_Objs_Record(l_Index);

        --DBMS_OUTPUT.PUT_LINE('(step 13 b)l_Dim_Obj_Short_Name - ' || l_Dim_Obj_Short_Name);

        OPEN c_Get_Prop_Dim;
        FETCH c_Get_Prop_Dim INTO l_Total_Flag, l_Comparison_Flag, l_Where_Clause;

        IF(c_Get_Prop_Dim%NOTFOUND) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_DIP_ERR_GET_GROUP_ID');
            FND_MSG_PUB.ADD;
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        CLOSE c_Get_Prop_Dim;

        -- ADRAO added condition for Bug#3770986
        IF (Is_Excluded_Dimension_Object(l_Dim_Obj_Short_Name) = FND_API.G_FALSE) THEN
            BSC_BIS_DIMENSION_PUB.Assign_Dimension_Object
            (       p_commit                =>  FND_API.G_FALSE
                ,   p_dim_short_name        =>  p_Dim_Short_Name
                ,   p_dim_obj_short_name    =>  l_Dim_Obj_Short_Name
                ,   p_comp_flag             =>  l_Comparison_Flag -- this value is acting like a flag
                ,   p_no_items              =>  0
                ,   p_parent_in_tot         =>  2
                ,   p_total_flag            =>  l_Total_Flag
                ,   p_default_value         => 'T'
                ,   p_time_stamp            =>  NULL
                ,   p_where_clause          =>  l_Where_Clause
                ,   x_return_status         =>  x_return_status
                ,   x_msg_count             =>  x_msg_count
                ,   x_msg_data              =>  x_msg_data
            );
            --DBMS_OUTPUT.PUT_LINE('(step 13 c)l_Dim_Obj_Short_Name - ' || l_Dim_Obj_Short_Name);
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END LOOP;*/

    /*for ctmp in C_Temp LOOP
      DBMS_OUTPUT.PUT_LINE (' dim_group_id    - ' || ctmp.dim_group_id);
      DBMS_OUTPUT.PUT_LINE (' dim_level_id    - ' || ctmp.dim_level_id);
      DBMS_OUTPUT.PUT_LINE (' dim_level_index - ' || ctmp.dim_level_index);
    END LOOP; */


    x_Return_Status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO KpiCrudCreateDimension;
        IF (c_Get_Prop_Dim%ISOPEN) THEN
           CLOSE c_Get_Prop_Dim;
        END IF;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO KpiCrudCreateDimension;
        IF (c_Get_Prop_Dim%ISOPEN) THEN
           CLOSE c_Get_Prop_Dim;
        END IF;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO KpiCrudCreateDimension;
        IF (c_Get_Prop_Dim%ISOPEN) THEN
           CLOSE c_Get_Prop_Dim;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Create_Dimension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Create_Dimension ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO KpiCrudCreateDimension;
        IF (c_Get_Prop_Dim%ISOPEN) THEN
           CLOSE c_Get_Prop_Dim;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Create_Dimension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Create_Dimension ';
        END IF;
END Create_Dimension;


/*
  Creates all the AK Metadata Required by an KPI, Analysis Options combination.
*/

PROCEDURE Create_Ak_Metadata(
      p_Commit                      IN           VARCHAR2 := FND_API.G_FALSE
    , p_Create_Region_Per_AO        IN           VARCHAR2 := FND_API.G_TRUE
    , p_Kpi_Id                      IN           NUMBER
    , p_Analysis_Option_Id          IN           NUMBER
    , p_Dim_Set_Id                  IN           NUMBER
    , p_Measure_Short_Name          IN           VARCHAR2
    , p_Measure_Name                IN           VARCHAR2
    , p_Measure_Description         IN           VARCHAR2
    , p_User_Portlet_Name           IN           VARCHAR2
    , p_Dataset_Format_Id           IN           NUMBER
    , p_Application_Id              IN           NUMBER
    , p_Disable_View_By             IN           VARCHAR2
    , p_Param_Portlet_Region_Code   IN           VARCHAR2
    , x_Return_Status               OUT NOCOPY   VARCHAR2
    , x_Msg_Count                   OUT NOCOPY   NUMBER
    , x_Msg_Data                    OUT NOCOPY   VARCHAR2
) IS
      l_fid                             NUMBER;
      l_rowid                           ROWID;
      l_Form_Parameters                 VARCHAR2(1000);
      l_Max_Seq_Number                  NUMBER;
      l_Sequence                        NUMBER := 10;
      l_Region_Code                     VARCHAR2(80);
      l_Count                           NUMBER;
      l_Function_Name                   VARCHAR2(80);
BEGIN
        SAVEPOINT CreateAkMetadata;
        FND_MSG_PUB.Initialize;

        -- Initialize Procedure Variables.
        x_Return_Status                := FND_API.G_RET_STS_SUCCESS;

        Create_Region_By_AO (
              p_Commit                 => p_Commit
            , p_Kpi_Id                 => p_Kpi_Id
            , p_Analysis_Option_Id     => p_Analysis_Option_Id
            , p_Dim_Set_Id             => p_Dim_Set_Id
            , p_Region_Name            => p_Measure_Name
            , p_Region_Description     => p_Measure_Description
            , p_Region_Application_Id  => p_Application_Id
            , p_Disable_View_By        => p_Disable_View_By
            , x_return_status          => x_Return_Status
            , x_msg_count              => x_Msg_Count
            , x_msg_data               => x_Msg_Data
       );
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


       l_Region_Code := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Region_Code(p_Kpi_Id, p_Analysis_Option_Id);
       --DBMS_OUTPUT.PUT_LINE('Region Code  -  ' || l_Region_Code);

       -- Create a Nested Region Item for a Parameter Portlet Region.
       l_Max_Seq_Number := Find_Max_Seq_Of_Region_Item(l_Region_Code);
       l_Max_Seq_Number := l_Max_Seq_Number + 10;


       -- Passed p_measure_name instead of Page Name for Measure Long Label AK_REGION_ITEMS_VL
       -- for Bug#3802192
       -- Create Compare TO and Change Region Items
       Create_Addl_Ak_Region_Items(
             p_commit                    => p_Commit
           , p_Region_Code               => l_Region_Code
           , p_Region_Application_Id     => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
           , p_Display_Sequence          => l_Max_Seq_Number
           , p_Display_Format            => Get_Format_Mask(p_Dataset_Format_Id)
           , p_Format_Id                 => p_Dataset_Format_Id
           , p_Measure_Short_Name        => p_Measure_Short_Name
           , p_Param_Portlet_Region_Code => p_Param_Portlet_Region_Code
           , p_Analysis_Option_Name      => p_Measure_Name
           , p_Kpi_Id                    => p_Kpi_Id
           , x_return_status             => x_Return_Status
           , x_msg_count                 => x_Msg_Count
           , x_msg_data                  => x_Msg_Data
       );

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --DBMS_OUTPUT.PUT_LINE('Outside Create_Measure_Region_Item ' );

     -- udpate the actual data source column in
     -- bis_indicators as the api validate the akregion

      Update_Actual_Data_Source(
            p_kpi_id               => p_Kpi_Id
          , p_dataset_id           => Get_Dataset_Id(p_Measure_Short_Name)
          , p_measure_short_name   => p_Measure_Short_Name
          , p_Create_Region_Per_AO => p_Create_Region_Per_AO
      );

     --DBMS_OUTPUT.PUT_LINE('Outside Update_Actual_Data_Source ' );
     -- Create a new Form Function
     -- Need to modularize.


     SELECT FND_FORM_FUNCTIONS_S.nextval
     INTO   l_fid
     FROM   SYS.DUAL;

     l_Form_Parameters := 'pForceRun=Y' || '&' || 'pRegionCode=' || l_Region_Code
                          || '&' || 'pFunctionName=' || l_Region_Code
              || '&' || 'pParameters=pParamIds@Y';

     --DBMS_OUTPUT.PUT_LINE('Creating Form Function ' );

     FND_FORM_FUNCTIONS_PKG.INSERT_ROW
     ( X_ROWID                      => l_Rowid
      ,X_FUNCTION_ID                => l_Fid
      ,X_WEB_HOST_NAME              => ''
      ,X_WEB_AGENT_NAME             => ''
      ,X_WEB_HTML_CALL              => BSC_BIS_KPI_CRUD_PUB.c_bisreportpg
      ,X_WEB_ENCRYPT_PARAMETERS     => 'N'
      ,X_WEB_SECURED                => 'N'
      ,X_WEB_ICON                   => ''
      ,X_OBJECT_ID                  => NULL
      ,X_REGION_APPLICATION_ID      => NULL
      ,X_REGION_CODE                => ''
      ,X_FUNCTION_NAME              => l_Region_Code
      ,X_APPLICATION_ID             => NULL
      ,X_FORM_ID                    => NULL
      ,X_PARAMETERS                 => l_Form_Parameters
      ,X_TYPE                       => 'JSP'
      ,X_USER_FUNCTION_NAME         => p_Measure_Name
      ,X_DESCRIPTION                => p_Measure_Description
      ,X_CREATION_DATE              => SYSDATE
      ,X_CREATED_BY                 => FND_GLOBAL.USER_ID
      ,X_LAST_UPDATE_DATE           => SYSDATE
      ,X_LAST_UPDATED_BY            => FND_GLOBAL.USER_ID
      ,X_LAST_UPDATE_LOGIN          => FND_GLOBAL.LOGIN_ID
      ,X_MAINTENANCE_MODE_SUPPORT   => 'NONE'
      ,X_CONTEXT_DEPENDENCE         => 'RESP'
     );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateAkMetadata;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateAkMetadata;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateAkMetadata;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Create_Ak_Metadata ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Create_Ak_Metadata ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CreateAkMetadata;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Create_Ak_Metadata ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Create_Ak_Metadata ';
        END IF;

END Create_Ak_Metadata;


-- Creates all the Required BSC and BIS AK Metadata

/*

*/

PROCEDURE Create_Bsc_Bis_Metadata(
      p_Commit                      IN VARCHAR2
    , p_Create_Region_Per_Ao        IN VARCHAR2
    , p_Param_Portlet_Region_Code   IN VARCHAR2
    , p_Page_Function_Name          IN VARCHAR2
    , p_Kpi_Portlet_Function_Name   IN VARCHAR2
    , p_Region_Function_Name        IN VARCHAR2    -- added for AGRD
    , p_Region_User_Function_Name   IN VARCHAR2    -- added for AGRD
    , p_Dim_Obj_Short_Names         IN VARCHAR2    -- added for AGRD
    , p_Force_Create_Dim            IN VARCHAR2    -- added for AGRD
    , p_Measure_Short_Name          IN VARCHAR2    -- added for AGRD
    , p_Responsibility_Id           IN NUMBER
    , p_Measure_Name                IN VARCHAR2
    , p_Measure_Description         IN VARCHAR2
    , p_Dataset_Format_Id           IN NUMBER
    , p_Dataset_Autoscale_Flag      IN NUMBER
    , p_Measure_Operation           IN VARCHAR2
    , p_Measure_Increase_In_Measure IN VARCHAR2
    , p_Measure_Obsolete            IN VARCHAR2 := FND_API.G_FALSE
    , p_Type                        IN VARCHAR2-- This is used for weighted kpis,This can take values CDS_SCORE,CDS_PERF or Null
    , p_Measure_Random_Style        IN NUMBER
    , p_Measure_Min_Act_Value       IN NUMBER
    , p_Measure_Max_Act_Value       IN NUMBER
    , p_Measure_Type                IN NUMBER
    , p_Measure_App_Id              IN NUMBER := NULL
    , p_Func_Area_Short_Name        IN VARCHAR2 := NULL
    , p_Obj_Grp_Id                  IN NUMBER   --Added for Simulation Designer
    , p_Obj_Tab_Id                  IN NUMBER   --Added for Simulation Designer
    , p_Obj_Type                    IN NUMBER   --Added for Simulation Designer
    , x_Measure_Short_Name          OUT NOCOPY   VARCHAR2
    , x_Kpi_Id                      OUT NOCOPY   NUMBER
    , x_Return_Status               OUT NOCOPY   VARCHAR2
    , x_Msg_Count                   OUT NOCOPY   NUMBER
    , x_Msg_Data                    OUT NOCOPY   VARCHAR2
) IS
  l_Commit                          VARCHAR2(2);
  x_Non_Time_Dimension_Groups       BSC_VARCHAR2_TBL_TYPE;
  x_Non_Time_Dimension_Objects      BSC_VARCHAR2_TBL_TYPE;
  x_Non_Time_Dim_Obj_Short_Names    VARCHAR2(2056);
  x_Time_Dimension_Groups           BSC_VARCHAR2_TBL_TYPE;
  x_Time_Dimension_Objects          BSC_VARCHAR2_TBL_TYPE;
  x_Time_Dim_Obj_Short_Names        VARCHAR2(2056);
  x_All_Dim_Group_Ids               BSC_NUMBER_TBL_TYPE;
  x_Non_Time_Counter                NUMBER;
  x_Time_Counter                    NUMBER;
  l_Dataset_Source                  BSC_SYS_MEASURES.SOURCE%TYPE;
  l_Dataset_Id                      NUMBER;
  l_Does_Dim_Group_Exist            BOOLEAN;
  l_Does_Kpi_Exist                  BOOLEAN;
  l_Indicator                       NUMBER;
  l_Tab_Id                          NUMBER;
  l_Kpi_Group_Id                    NUMBER;
  l_Kpi_Id                          NUMBER;
  l_Real_Kpi_Name                   BSC_SYS_DATASETS_TL.NAME%TYPE;
  l_Fid                             NUMBER;
  l_Rowid                           ROWID;
  l_Form_Parameters                 FND_FORM_FUNCTIONS.PARAMETERS%TYPE;
  l_Max_Seq_Number                  NUMBER;
  l_Sequence                        NUMBER;
  l_Report_Region_Rec               BIS_AK_REGION_PUB.Bis_Region_Rec_Type;
  l_User_Page_Report_Name           FND_FORM_FUNCTIONS_VL.USER_FUNCTION_NAME%TYPE;
  l_User_Portlet_Name               FND_FORM_FUNCTIONS_VL.USER_FUNCTION_NAME%TYPE;
  l_Analysis_Option                 NUMBER;
  l_Measure_Function_Name           BIS_INDICATORS.FUNCTION_NAME%TYPE;
  l_Region_Code                     AK_REGIONS.REGION_CODE%TYPE;
  l_Count                           NUMBER;
  l_Function_Name                   FND_FORM_FUNCTIONS_VL.USER_FUNCTION_NAME%TYPE;
  l_Measure_Group_Id                NUMBER;

  l_Measure_Short_Name              BSC_SYS_MEASURES.SHORT_NAME%TYPE;

   --added for bug#4057761
  l_tab_name                        BSC_TABS_TL.NAME%TYPE;
  l_group_name                      BSC_TAB_IND_GROUPS_TL.NAME%TYPE;

  -- added for AGRD
  l_Is_From_Report_Designer         BOOLEAN;
  l_Key_Short_Name                  FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE;
  l_Anal_Opt_Rec                    APPS.BSC_ANALYSIS_OPTION_PUB.BSC_OPTION_REC_TYPE;
  x_Anal_Opt_Rec                    APPS.BSC_ANALYSIS_OPTION_PUB.BSC_OPTION_REC_TYPE;
  l_Dimension_Short_Name            BSC_SYS_DIM_GROUPS_TL.SHORT_NAME%TYPE;
  l_Is_XTD_Enabled                  VARCHAR2(1);
  l_Bsc_Measure_Id                  NUMBER;
  l_Measure_Source                  BSC_SYS_MEASURES.SOURCE%TYPE;
  l_Returned_Kpi_Id                 NUMBER;
  l_Actual_Data_Source              BIS_INDICATORS.ACTUAL_DATA_SOURCE%TYPE;
  l_Actual_Data_Source_Type         BIS_INDICATORS.ACTUAL_DATA_SOURCE_TYPE%TYPE;
  l_Count1                          NUMBER;
  l_attribute_code                  AK_REGION_ITEMS.ATTRIBUTE_CODE%TYPE;
  l_Comparison_Source               BIS_INDICATORS.COMPARISON_SOURCE%TYPE;
  l_Compare_Attribute_Code          AK_REGION_ITEMS.ATTRIBUTE_CODE%TYPE;
  l_as_of_date                      VARCHAR2(1);

  l_obj_type                        NUMBER;

BEGIN
    SAVEPOINT CreateBscBisMetadata;

    FND_MSG_PUB.Initialize;

    -- Initialize Procedure Variables.
    x_Return_Status                := FND_API.G_RET_STS_SUCCESS;




    -- procedure block to check if the updatable measure being passed is of AG type or not,
    -- if not AG type, then the procedure just roll back with staus "S"
    BEGIN
       IF (p_Measure_Short_Name IS NOT NULL) THEN
         SELECT
     M.SOURCE
   INTO
     l_Measure_Source
   FROM
     bsc_sys_measures m,
     bsc_sys_datasets_vl d,
     bis_indicators i
   WHERE
     i.dataset_id  = d.dataset_id AND
     d.measure_id1 = m.measure_id AND
     i.short_name  = p_Measure_Short_Name;


         --DBMS_OUTPUT.PUT_LINE('STAGE 1A - l_Measure_Source - ' || l_Measure_Source);
         --DBMS_OUTPUT.PUT_LINE('STAGE 1A - p_Measure_Short_Name - ' || p_Measure_Short_Name);

         /*IF (NVL(l_Measure_Source, 'PMF') <> BSC_BIS_MEASURE_PUB.c_BSC) THEN
           ROLLBACK TO CreateBscBisMetadata;
           RETURN;
         END IF;*/

       END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       NULL;
      WHEN OTHERS THEN
         ROLLBACK TO CreateBscBisMetadata;
         RETURN;
    END;

    -- Initialize if the code is coming from report designer

    --DBMS_OUTPUT.PUT_LINE('STAGE 1');

    IF (p_Region_Function_Name IS NOT NULL) THEN
        l_Is_From_Report_Designer  := TRUE;
        l_Key_Short_Name           := p_Region_Function_Name;
    ELSE
        l_Is_From_Report_Designer  := FALSE;
        l_Key_Short_Name           := p_Page_Function_Name;
    END IF;

    -- This is fix for Bug#4327887
    -- Check if AS_OF_DATE is enabled at the Paramter Portlet
    IF ((is_XTD_Enabled(p_Param_Portlet_Region_Code) = FND_API.G_TRUE) OR (l_Is_From_Report_Designer)) THEN
     -- Check if Advance Summarization Profile > 1, else throw and error.
     IF (BSC_UTILITY.Is_Adv_Summarization_Enabled = FND_API.G_FALSE) THEN
         FND_MESSAGE.SET_NAME('BSC','BSC_ENABLE_ADV_SUMMARIZATION');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
    END IF;

    x_Non_Time_Dim_Obj_Short_Names := NULL;
    x_Time_Dim_Obj_Short_Names     := NULL;
    l_Dataset_Source               := NULL;
    l_Sequence                     := 10;
    l_Dataset_Source               := BSC_BIS_MEASURE_PUB.c_BSC;
    l_Measure_Short_Name           := NULL;
    x_All_Dim_Group_Ids(1)         := NULL;
    x_All_Dim_Group_Ids(2)         := NULL;
    x_All_Dim_Group_Ids(3)         := NULL;
    x_All_Dim_Group_Ids(4)         := NULL;
    x_All_Dim_Group_Ids(5)         := NULL;
    x_All_Dim_Group_Ids(6)         := NULL;
    x_All_Dim_Group_Ids(7)         := NULL;


    IF (l_Is_From_Report_Designer = FALSE) THEN
      -- Get the Dimenension Object Info from the Parameter Portler Region
      BSC_BIS_KPI_CRUD_PUB.Get_Dim_Info_From_Region_Code(
          p_Param_Portlet_Region_Code    => p_Param_Portlet_Region_Code
        , x_Non_Time_Dimension_Groups    => x_Non_Time_Dimension_Groups
        , x_Non_Time_Dimension_Objects   => x_Non_Time_Dimension_Objects
        , x_Non_Time_Dim_Obj_Short_Names => x_Non_Time_Dim_Obj_Short_Names
        , x_All_Dim_Group_Ids            => x_All_Dim_Group_Ids
        , x_Non_Time_Counter             => x_Non_Time_Counter
        , x_Time_Dimension_Groups        => x_Time_Dimension_Groups
        , x_Time_Dimension_Objects       => x_Time_Dimension_Objects
        , x_Time_Dim_Obj_Short_Names     => x_Time_Dim_Obj_Short_Names
        , x_Time_Counter                 => x_Time_Counter
        , x_Msg_Data                     => x_Msg_Data
      );
      IF (x_msg_data IS NOT NULL) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSE
       IF (p_Dim_Obj_Short_Names IS NOT NULL) THEN
          BSC_BIS_KPI_CRUD_PUB.Get_Dim_Info_From_ParamPortlet(
              p_Dimension_Info               => p_Dim_Obj_Short_Names
             ,x_non_time_dimension_groups    => x_Non_Time_Dimension_Groups
             ,x_non_time_dimension_objects   => x_Non_Time_Dimension_Objects
             ,x_non_time_dim_obj_short_names => x_Non_Time_Dim_Obj_Short_Names
             ,x_all_dim_group_ids            => x_All_Dim_Group_Ids
             ,x_non_time_counter             => x_Non_Time_Counter
             ,x_time_dimension_groups        => x_Time_Dimension_Groups
             ,x_time_dimension_objects       => x_Time_Dimension_Objects
             ,x_time_dim_obj_short_names     => x_Time_Dim_Obj_Short_Names
             ,x_time_counter                 => x_Time_Counter
             ,x_msg_data                     => x_Msg_Data
             ,x_is_as_of_date                => l_as_of_date
          );
       END IF;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('STAGE 2');

    -- Get the User DBI Page name to be populated into Scorecards (a.k.a Tabs)
    l_User_Page_Report_Name    := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_User_Function_Name(l_Key_Short_Name);

    IF(p_Obj_Tab_Id IS NOT NULL) THEN
       l_tab_name              := Get_Tab_Name(p_Obj_Tab_Id);
    ELSE
     l_tab_name                := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Unqiue_Tab_Name(l_User_Page_Report_Name);
    END IF;

    IF(p_Obj_Grp_Id IS NOT NULL)THEN
      l_group_name             := Get_Objective_Group_Name(p_Obj_Grp_Id);
    ELSE
      l_group_name             := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Unqiue_Tab_Group_Name(l_User_Page_Report_Name);
    END IF;
    -- need to verify why this will be used in future.
    l_User_Portlet_Name        := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_User_Function_Name(p_Kpi_Portlet_Function_Name);

    IF (l_Is_From_Report_Designer = TRUE) THEN
        l_Measure_Group_Id  := BSC_BIS_KPI_CRUD_PUB.C_DEFAULT_MEASURE_GROUP_ID;
    ELSE
        -- Get the Source Group ID to be populated to BSC_DB_MEASURE_COLS_VL
        l_Measure_Group_Id  := Get_Measure_Group_Id(l_Key_Short_Name, x_Return_Status, x_Msg_Data);
        IF (x_Msg_Data IS NOT NULL) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;


    --DBMS_OUTPUT.PUT_LINE('STAGE 3 - ' || l_Key_Short_Name);

    -- Get the existance of Dimension and KPI (a.k.a Indicator, Objective)
    l_Does_Kpi_Exist  := Does_KPI_Exist(l_Key_Short_Name);
    --DBMS_OUTPUT.PUT_LINE('STAGE 3 - ' || l_Key_Short_Name);


    IF (l_Does_Kpi_Exist = FALSE) THEN
        -- Create a new Tab, aka Scorecard

        --DBMS_OUTPUT.PUT_LINE('STAGE 3A - ');
        IF(p_Obj_Tab_Id IS NULL ) THEN

          l_Tab_Id := Get_Tab_Id(l_Key_Short_Name);

          --DBMS_OUTPUT.PUT_LINE('STAGE 4 - ' ||l_Tab_Id);

          IF (l_Tab_Id = BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY AND p_Obj_Type = BSC_BIS_KPI_CRUD_PUB.C_MULTI_BAR_INDICATOR) THEN
              BSC_PMF_UI_WRAPPER.Create_Tab(
                   p_Commit            => p_Commit
                  ,p_Responsibility_Id => p_Responsibility_Id
                  ,p_Parent_Tab_Id     => NULL
                  ,p_Owner_Id          => NULL
                  ,p_Short_Name        => l_Key_Short_Name
                  ,x_Tab_Id            => l_Tab_Id
                  ,x_Return_Status     => x_Return_Status
                  ,x_Msg_Count         => x_Msg_Count
                  ,x_Msg_Data          => x_Msg_Data
                  ,p_Tab_Name          => l_tab_name
                  ,p_Tab_Help          => l_User_Page_Report_Name
                  ,p_Tab_Info          => l_User_Page_Report_Name
              );
              IF (x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
                  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
          END IF;
        ELSE
         l_Tab_Id :=p_Obj_Tab_Id;
        END IF;

        IF(p_Obj_Grp_Id IS NULL)THEN

          l_Kpi_Group_Id := Get_Group_Id(l_Key_Short_Name);
          --DBMS_OUTPUT.PUT_LINE('STAGE 5 - ' ||l_Kpi_Group_Id);

          IF (l_Kpi_Group_Id = BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY) THEN
              -- Create a new KPI Group, aka Objective Group
              BSC_PMF_UI_WRAPPER.Create_Kpi_Group(
                   p_Commit               => p_Commit
                  ,p_Tab_Id               => NULL
                  ,p_Kpi_Group_Id         => NULL
                  ,p_Kpi_Group_Short_Name => l_Key_Short_Name
                  ,p_Kpi_Group_Name       => l_group_name
                  ,p_Kpi_Group_Help       => l_User_Page_Report_Name
                  ,x_Kpi_Group_Id         => l_Kpi_Group_Id
                  ,x_Return_Status        => x_Return_Status
                  ,x_Msg_Count            => x_Msg_Count
                  ,x_Msg_Data             => x_Msg_Data
              );
              IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
          END IF;
        ELSE
          l_Kpi_Group_Id := p_Obj_Grp_Id;
        END IF;

        --DBMS_OUTPUT.PUT_LINE('STAGE 5A - ' ||l_Kpi_Group_Id);

        -- Create a new KPI, aka Objective
        -- Bug#4064587 - l_Kpi_Id will exist till the end.

        l_obj_type := p_Obj_Type;



        BSC_PMF_UI_WRAPPER.Create_Kpi(
             p_Commit             => p_Commit
            ,p_Group_Id           => l_Kpi_Group_Id
            ,p_Responsibility_Id  => p_Responsibility_Id
            ,p_Kpi_Name           => l_User_Page_Report_Name
            ,p_Kpi_Help           => l_User_Page_Report_Name
            ,p_Kpi_Short_Name     => l_Key_Short_Name
            ,p_Kpi_Indicator_Type => l_obj_type
            ,x_Kpi_Id             => l_Kpi_Id
            ,x_Return_Status      => x_Return_Status
            ,x_Msg_Count          => x_Msg_Count
            ,x_Msg_Data           => x_Msg_Data
        );
        IF (x_Return_Status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;



        --DBMS_OUTPUT.PUT_LINE('STAGE 6 - ' ||l_Kpi_Id);
        -- API to enable XTD, iViewer will show XTD Checked default.
        -- Enable XTD if enabled at the Parameter Portlet level only.
        -- added condition for AGRD
        IF (l_Is_From_Report_Designer = FALSE) THEN
           IF (is_XTD_Enabled(p_Param_Portlet_Region_Code) = FND_API.G_TRUE) THEN

               BSC_BIS_KPI_CRUD_PUB.Enable_Kpi_Calculation (
                       p_Commit           => p_Commit
                     , p_Kpi_Id           => l_Kpi_Id
                     , p_Calculation_Id   => BSC_BIS_KPI_CRUD_PUB.C_CALC_XTD
                     , p_Default_Checked  => BSC_BIS_KPI_CRUD_PUB.C_ENABLE_CALC_KPI
                     , x_Return_Status    => x_Return_Status
                     , x_Msg_Count        => x_Msg_Count
                     , x_Msg_Data         => x_Msg_Data
               );
               IF (x_Return_Status  <> FND_API.G_RET_STS_SUCCESS) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
           END IF;
        END IF;

        --DBMS_OUTPUT.PUT_LINE('STAGE 7');
        --For simulation Tree Enhancement tabid is not mandatory.
        --So in that case we don't need to call the api which creates the
        -- association between objective and tab
        -- only if tab_id is valid then only call this api

      --DBMS_OUTPUT.PUT_LINE('l_Tab_Id - ' ||l_Tab_Id);



      IF(l_Tab_Id <> BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY) THEN

        --DBMS_OUTPUT.PUT_LINE('INSIDE l_Kpi_Group_Id - ' ||l_Kpi_Group_Id);
        IF(l_obj_type = BSC_BIS_KPI_CRUD_PUB.C_SIMULATION_INDICATOR) THEN

            BSC_PMF_UI_WRAPPER.Assign_KPI(
                 p_Commit         =>  FND_API.G_FALSE
                ,p_kpi_id         =>  l_kpi_id
                ,p_tab_id         =>  l_Tab_Id
                ,x_return_status  =>  x_return_status
                ,x_msg_count      =>  x_msg_count
                ,x_msg_data       =>  x_msg_data
            );

            IF (x_Return_Status  <> FND_API.G_RET_STS_SUCCESS) THEN
                 RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

        ELSE
           BSC_PMF_UI_WRAPPER.Assign_KPI_Group(
               p_Commit        => p_Commit
              ,p_Kpi_Group_Id  => l_Kpi_Group_Id
              ,p_Tab_Id        => l_Tab_Id
              ,x_Return_Status => x_Return_Status
              ,x_Msg_Count     => x_Msg_Count
              ,x_Msg_Data      => x_Msg_Data
            );
        END IF;
        IF (x_Return_Status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END IF;


    IF(p_Obj_Type = BSC_BIS_KPI_CRUD_PUB.C_SIMULATION_INDICATOR AND p_Obj_Tab_Id IS NOT NULL) THEN

      --Check if the indicator is attahced to the scorecard or not
      --if not then attach it
      --

       l_kpi_id := Get_Kpi_Id(l_Key_Short_Name);

        IF(l_kpi_id <> -1000 AND Is_Assign_To_Tab(l_kpi_id,p_Obj_Tab_Id)=FND_API.G_FALSE)THEN
            BSC_PMF_UI_WRAPPER.Assign_KPI(
             p_Commit         =>  FND_API.G_FALSE
            ,p_kpi_id         =>  l_kpi_id
            ,p_tab_id         =>  p_Obj_Tab_Id
            ,x_return_status  =>  x_return_status
            ,x_msg_count      =>  x_msg_count
            ,x_msg_data       =>  x_msg_data
            );
            IF (x_Return_Status  <> FND_API.G_RET_STS_SUCCESS) THEN
               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
     END IF;


   --DBMS_OUTPUT.PUT_LINE('STAGE 7A');

    -- Create a BSC and BIS Measure (aka KPI)
    -- the KPI Should always be created for the current page.
   l_Kpi_Id := Get_Kpi_Id(l_Key_Short_Name);

   --DBMS_OUTPUT.PUT_LINE('STAGE 7B - ' || l_Kpi_Id);
   --DBMS_OUTPUT.PUT_LINE('STAGE 7B - ' || l_Kpi_Id);

   -- Check if measure exists
   -- If measure exists
   --  ) Update Measure Properties
   --  ) Update Objective Analysis Measures metadata.
   -- Create normal measure.
   SELECT COUNT(1) INTO l_Count
   FROM   BIS_INDICATORS
   WHERE  SHORT_NAME = p_measure_short_name;

       l_Region_Code := BIS_PMV_UTIL.GetReportRegion(p_Region_Function_Name);
       l_attribute_code := BSC_BIS_KPI_CRUD_PUB.Get_Attribute_Code_For_Measure(l_Region_Code,p_Measure_Short_Name);
   IF (l_Count <> 0 AND l_Is_From_Report_Designer = TRUE) THEN
       l_Returned_Kpi_Id := BSC_BIS_KPI_CRUD_PUB.Get_Objective_By_AGKpi(p_Measure_Short_Name);



       l_Dataset_Id := BSC_BIS_KPI_CRUD_PUB.Get_Dataset_Id(p_Measure_Short_Name);

       -- the Update_Measure API expects Measure_Id1 to be present as a non-Null parameter.
       SELECT
         m.measure_id
       INTO
         l_Bsc_Measure_Id
       FROM
         bsc_sys_measures m,
         bsc_sys_datasets_vl d,
         bis_indicators i
       WHERE
         i.dataset_id  = d.dataset_id AND
         d.measure_id1 = m.measure_id AND
         i.short_name  = p_measure_short_name;
       --DBMS_OUTPUT.PUT_LINE('STAGE 7C - ' || l_Dataset_Id);
       --DBMS_OUTPUT.PUT_LINE('STAGE 7D - ' || BSC_BIS_MEASURE_PUB.c_BSC);
       --DBMS_OUTPUT.PUT_LINE('STAGE 7E - ' || l_Bsc_Measure_Id);
       --DBMS_OUTPUT.PUT_LINE('STAGE 7F - ' || p_Region_Function_Name || '.' || p_Measure_Short_Name);

       l_Actual_Data_Source := BSC_BIS_KPI_CRUD_PUB.Get_Actual_Source_Data(p_Measure_Short_Name);
       l_Actual_Data_Source_Type := BSC_BIS_KPI_CRUD_PUB.Get_Actual_Source_Data_Type(p_Measure_Short_Name);
       l_Function_Name := BSC_BIS_KPI_CRUD_PUB.Get_Measure_Function_Name(p_Measure_Short_Name);

       IF (l_Actual_Data_Source IS NULL) THEN
          l_Actual_Data_Source := l_Region_Code || '.' || l_attribute_code;
       END IF;

       IF (l_Function_Name IS NULL) THEN
          l_Function_Name := p_Region_Function_Name;
       END IF;

       -- Bug#5201116
       IF (l_Region_Code = SUBSTR(l_Actual_Data_Source, 1, INSTR(l_Actual_Data_Source, '.') - 1)) THEN
         -- Primary Data Source
         l_Compare_Attribute_Code := Get_Compare_Attribute_Code(p_Region_Function_Name, p_Measure_Short_Name);

   IF (l_Compare_Attribute_Code IS NOT NULL) THEN
           l_Comparison_Source := l_Region_Code || '.' || l_Compare_Attribute_Code;
         ELSE
           l_Comparison_Source := NULL;
         END IF;

       ELSE
         l_Comparison_Source := BSC_BIS_KPI_CRUD_PUB.Get_Comparison_Source(p_Measure_Short_Name);
       END IF;

       -- Passed AK type and AK source (pl/sql), since they were getting updated to null
       -- modified condition for Bug#4599432


       IF (BSC_UTILITY.Is_Measure_Seeded(p_Measure_Short_Name) = FND_API.G_FALSE AND BSC_UTILITY.is_Calculated_kpi(p_Measure_Short_Name)= FND_API.G_FALSE) THEN

           BSC_BIS_MEASURE_PUB.Update_Measure(
              p_Commit                      =>  p_Commit
             ,p_Dataset_Id                  =>  l_Dataset_Id
             ,p_Dataset_Source              =>  l_Measure_Source
             ,p_Dataset_Name                =>  p_Measure_Name
             ,p_Dataset_Help                =>  p_Measure_Description
             ,p_Dataset_Measure_Id1         =>  l_Bsc_Measure_Id
             ,p_Dataset_Operation           =>  NULL
             ,p_Dataset_Measure_Id2         =>  NULL
             ,p_Dataset_Format_Id           =>  p_Dataset_Format_Id
             ,p_Dataset_Color_Method        =>  NULL
             ,p_Dataset_Autoscale_Flag      =>  p_Dataset_Autoscale_Flag
             ,p_Dataset_Projection_Flag     =>  NULL
             ,p_Measure_Short_Name          =>  p_Measure_Short_Name
             ,p_Measure_Act_Data_Src_Type   =>  l_Actual_Data_Source_Type
             ,p_Measure_Act_Data_Src        =>  l_Actual_Data_Source
             ,p_Measure_Comparison_Source   =>  l_Comparison_Source
             ,p_Measure_Operation           =>  p_Measure_Operation
             ,p_Measure_Uom_Class           =>  NULL
             ,p_Measure_Increase_In_Measure =>  p_Measure_Increase_In_Measure
             ,p_Measure_Random_Style        =>  p_Measure_Random_Style
             ,p_Measure_Min_Act_Value       =>  p_Measure_Min_Act_Value
             ,p_Measure_Max_Act_Value       =>  p_Measure_Max_Act_Value
             ,p_Measure_Min_Bud_Value       =>  NULL
             ,p_Measure_Max_Bud_Value       =>  NULL
             ,p_Measure_App_Id              =>  p_Measure_App_Id
             ,p_Measure_Col                 =>  NULL
             ,p_Measure_Group_Id            =>  NULL
             ,p_Measure_Projection_Id       =>  BSC_BIS_KPI_CRUD_PUB.C_NO_PROJECTION
             ,p_Measure_Type                =>  p_Measure_Type
             ,p_Measure_Apply_Rollup        =>  NULL
             ,p_Measure_Function_Name       =>  l_Function_Name
             ,p_Measure_Enable_Link         =>  'Y'
             ,p_Measure_Obsolete            =>  p_Measure_Obsolete
             ,p_Type                        =>  p_Type
             ,p_Time_Stamp                  =>  NULL
             ,p_Dimension1_Id               =>  x_All_Dim_Group_Ids(1)
             ,p_Dimension2_Id               =>  x_All_Dim_Group_Ids(2)
             ,p_Dimension3_Id               =>  x_All_Dim_Group_Ids(3)
             ,p_Dimension4_Id               =>  x_All_Dim_Group_Ids(4)
             ,p_Dimension5_Id               =>  x_All_Dim_Group_Ids(5)
             ,p_Dimension6_Id               =>  x_All_Dim_Group_Ids(6)
             ,p_Dimension7_Id               =>  x_All_Dim_Group_Ids(7)
             ,p_Y_Axis_Title                =>  NULL
             ,p_Func_Area_Short_Name        => p_Func_Area_Short_Name
             ,x_Return_Status               =>  x_Return_Status
             ,x_Msg_Count                   =>  x_Msg_Count
             ,x_Msg_Data                    =>  x_Msg_Data
           );

           IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
       END IF;


       -- if the measure added is of type Exisitng, then add the
       -- same to the list of data series.
       SELECT COUNT(1) INTO l_Count1
       FROM   BSC_KPI_ANALYSIS_MEASURES_B B
       WHERE  B.DATASET_ID = l_Dataset_Id
       AND    B.INDICATOR  = l_Kpi_id;

       IF((l_Returned_Kpi_Id =BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY AND l_Measure_Source =BSC_BIS_MEASURE_PUB.c_BSC) OR l_Count1 = 0) THEN
            l_Anal_Opt_Rec.Bsc_Kpi_Id                 := l_Kpi_Id;
            l_Anal_Opt_Rec.Bsc_Dataset_Id             := l_Dataset_Id;
            l_Anal_Opt_Rec.Bsc_Dataset_Default_Value  := 1;
            l_Anal_Opt_Rec.Bsc_Measure_Long_Name      := p_Measure_Name;
            l_Anal_Opt_Rec.Bsc_Measure_Help           := p_Measure_Description;

            --DBMS_OUTPUT.PUT_LINE('STAGE 10 - Create_Data_Series');
            --DBMS_OUTPUT.PUT_LINE('p_Commit -->'|| p_Commit);



            BSC_ANALYSIS_OPTION_PUB.Create_Data_Series(
                p_Commit        => p_Commit
              , p_Anal_Opt_Rec  => l_Anal_Opt_Rec
              , x_Anal_Opt_Rec  => x_Anal_Opt_Rec
              , x_Return_Status => x_Return_Status
              , x_Msg_Count     => x_Msg_Count
              , x_Msg_Data      => x_Msg_Data
           );
           IF (x_Return_Status  <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;



       ELSE
           l_Anal_Opt_Rec.Bsc_Kpi_Id                 := l_Kpi_Id;
           l_Anal_Opt_Rec.Bsc_Dataset_Series_Id      := BSC_BIS_KPI_CRUD_PUB.Get_Data_Series_Id(l_Kpi_Id, l_Dataset_Id);
           l_Anal_Opt_Rec.Bsc_Option_Group0          := 0;
           l_Anal_Opt_Rec.Bsc_Option_Group1          := 0;
           l_Anal_Opt_Rec.Bsc_Option_Group2          := 0;
           l_Anal_Opt_Rec.Bsc_Dataset_Default_Value  := 1;
           l_Anal_Opt_Rec.Bsc_Measure_Long_Name      := p_Measure_Name;
           l_Anal_Opt_Rec.Bsc_Measure_Help           := p_Measure_Description;

           --DBMS_OUTPUT.PUT_LINE('STAGE 10 - Update_Data_Series');

           BSC_ANALYSIS_OPTION_PUB.Update_Data_Series(
               p_Commit        => p_Commit
             , p_Anal_Opt_Rec  => l_Anal_Opt_Rec
             , x_Return_Status => x_Return_Status
             , x_Msg_Count     => x_Msg_Count
             , x_Msg_Data      => x_Msg_Data
           );
           IF (x_Return_Status  <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

       END IF;

    ELSE
        IF ((p_Measure_Short_Name IS NOT NULL) OR (l_Is_From_Report_Designer = FALSE)) THEN -- check if the report is null
            -- Changed from l_Measure_Short_Name to p_Measure_Short_Name
            BSC_BIS_KPI_CRUD_PUB.Create_Measure(
                  p_Commit                      => p_Commit
                 ,x_Dataset_Id                  => l_Dataset_Id
                 ,p_Kpi_Id                      => l_Kpi_Id
                 ,p_Dataset_Source              => l_Dataset_Source
                 ,p_Measure_Name                => p_Measure_Name
                 ,p_Measure_Short_Name          => p_Measure_Short_Name
                 ,p_Measure_Description         => p_Measure_Description
                 ,p_Dataset_Format_Id           => p_Dataset_Format_Id
                 ,p_Dataset_Autoscale_Flag      => p_Dataset_Autoscale_Flag
                 ,p_Measure_Operation           => p_Measure_Operation
                 ,p_Measure_Increase_In_Measure => p_Measure_Increase_In_Measure
                 ,p_Measure_Obsolete            => p_Measure_Obsolete
                 ,p_Type                        => p_Type
                 ,p_Measure_Random_Style        => p_Measure_Random_Style
                 ,p_Measure_Min_Act_Value       => p_Measure_Min_Act_Value
                 ,p_Measure_Max_Act_Value       => p_Measure_Max_Act_Value
                 ,p_Measure_Type                => p_Measure_Type
                 ,p_Measure_Function_Name       => NULL
                 ,p_Measure_Group_Id            => l_Measure_Group_Id
                 ,p_Dimension1_Id               => x_All_Dim_Group_Ids(1)
                 ,p_Dimension2_Id               => x_All_Dim_Group_Ids(2)
                 ,p_Dimension3_Id               => x_All_Dim_Group_Ids(3)
                 ,p_Dimension4_Id               => x_All_Dim_Group_Ids(4)
                 ,p_Dimension5_Id               => x_All_Dim_Group_Ids(5)
                 ,p_Dimension6_Id               => x_All_Dim_Group_Ids(6)
                 ,p_Dimension7_Id               => x_All_Dim_Group_Ids(7)
                 ,p_Measure_App_Id              => p_Measure_App_Id
             ,p_Func_Area_Short_Name        => p_Func_Area_Short_Name
                 ,x_Return_Status               => x_Return_Status
                 ,x_Msg_Count                   => x_Msg_Count
                 ,x_Msg_Data                    => x_Msg_Data
            );
            IF (x_Return_Status  <> FND_API.G_RET_STS_SUCCESS) THEN
                  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            --DBMS_OUTPUT.PUT_LINE('STAGE 8');

            -- Update Disabled Calcuations -- Pending Approval
            BSC_BIS_KPI_CRUD_PUB.Apply_Disabled_Calculations (
                    p_Commit         => p_Commit
                  , p_Dataset_Id     => l_Dataset_Id
                  , x_Return_Status  => x_Return_Status
                  , x_Msg_Count      => x_Msg_Count
                  , x_Msg_Data       => x_Msg_Data
            );
            IF (x_Return_Status  <> FND_API.G_RET_STS_SUCCESS) THEN
                  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -- Assign the above Measure (aka KPI) to the Analysis Option (aka Measure)
            -- of the KPI (aka Objective)
            --DBMS_OUTPUT.PUT_LINE('STAGE 9');
            -- added for Report Designer (AG Measures) AGRD
            -- added logic to call Pl/SQL API BSC_ANALYSIS_OPTION_PUB.Create_Data_Series to create Data Series
            IF (l_Is_From_Report_Designer) THEN

                 l_Anal_Opt_Rec.Bsc_Kpi_Id                 := l_Kpi_Id;
                 l_Anal_Opt_Rec.Bsc_Dataset_Id             := l_Dataset_Id;
                 l_Anal_Opt_Rec.Bsc_Dataset_Default_Value  := 1;
                 l_Anal_Opt_Rec.Bsc_Measure_Long_Name      := p_Measure_Name;
                 l_Anal_Opt_Rec.Bsc_Measure_Help           := p_Measure_Description;

                 --DBMS_OUTPUT.PUT_LINE('STAGE 10 - Create_Data_Series');
                 --DBMS_OUTPUT.PUT_LINE('l_Anal_Opt_Rec.Bsc_Kpi_Id                - ' || l_Anal_Opt_Rec.Bsc_Kpi_Id);
                 --DBMS_OUTPUT.PUT_LINE('l_Anal_Opt_Rec.Bsc_Dataset_Default_Value - ' || l_Anal_Opt_Rec.Bsc_Dataset_Default_Value);
                 --DBMS_OUTPUT.PUT_LINE('l_Anal_Opt_Rec.Bsc_Measure_Long_Name     - ' || l_Anal_Opt_Rec.Bsc_Measure_Long_Name);
                 --DBMS_OUTPUT.PUT_LINE('l_Anal_Opt_Rec.Bsc_Measure_Help          - ' || l_Anal_Opt_Rec.Bsc_Measure_Help);

                  --DBMS_OUTPUT.PUT_LINE('p_Commit -->'|| p_Commit);




                 BSC_ANALYSIS_OPTION_PUB.Create_Data_Series(
                     p_Commit        => p_Commit
                   , p_Anal_Opt_Rec  => l_Anal_Opt_Rec
                   , x_Anal_Opt_Rec  => x_Anal_Opt_Rec
                   , x_Return_Status => x_Return_Status
                   , x_Msg_Count     => x_Msg_Count
                   , x_Msg_Data      => x_Msg_Data
                 );
                 --DBMS_OUTPUT.PUT_LINE('(10) x_Return_Status                 ' || x_Return_Status);
                 --DBMS_OUTPUT.PUT_LINE('(10) x_msg_data                  ' || x_Msg_Data);

                 IF (x_Return_Status  <> FND_API.G_RET_STS_SUCCESS) THEN
                      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

                 /*
                 Need to move the below to a new PL/SQL API - TODO
                 */

                 BEGIN
                    SELECT A.SHORT_NAME
                    INTO   x_Measure_Short_Name
                    FROM   BSC_SYS_MEASURES A
                    WHERE  A.MEASURE_ID =
                        (
                         SELECT B.MEASURE_ID1
                         FROM   BSC_SYS_DATASETS_B B
                         WHERE  B.DATASET_ID = l_Dataset_Id
                        );
                 EXCEPTION
                   WHEN OTHERS THEN
                     x_Measure_Short_Name := NULL;
                 END;

                 -- added for Bug#4638384
                 l_Compare_Attribute_Code := Get_Compare_Attribute_Code(p_Region_Function_Name, p_Measure_Short_Name);

                 IF (l_Compare_Attribute_Code IS NOT NULL) THEN
                    l_Comparison_Source := p_Region_Function_Name || '.' || l_Compare_Attribute_Code;
                 END IF;

                 UPDATE  BIS_INDICATORS
                 SET     ACTUAL_DATA_SOURCE      = p_Region_Function_Name || '.' || l_attribute_code
                       , ACTUAL_DATA_SOURCE_TYPE = 'AK'
                       , FUNCTION_NAME           = p_Region_Function_Name
                       , COMPARISON_SOURCE       = l_Comparison_Source
                       , ENABLE_LINK             = 'Y'
                 WHERE   DATASET_ID              = l_Dataset_Id;


            ELSE

                 BSC_BIS_KPI_CRUD_PUB.Associate_KPI_To_AO(
                        p_Commit              => p_Commit
                      , p_Indicator           => l_Kpi_Id
                      , p_Dataset_Id          => l_Dataset_Id
                      , p_Measure_Name        => p_Measure_Name
                      , p_Measure_Description => p_Measure_Description
                      , x_Measure_Short_Name  => x_Measure_Short_Name
                      , x_Return_Status       => x_Return_Status
                      , x_Msg_Count           => x_Msg_Count
                      , x_Msg_Data            => x_Msg_Data
                 );
                 IF (x_Return_Status  <> FND_API.G_RET_STS_SUCCESS) THEN
                      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;


            END IF;
        END IF;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('STAGE 11');

    IF (l_Is_From_Report_Designer) THEN
       l_Dimension_Short_Name := l_Key_Short_Name;
       l_Is_XTD_Enabled       := BSC_BIS_KPI_CRUD_PUB.is_XTD_Enabled(BIS_PMV_UTIL.GetReportRegion(p_Region_Function_Name));
    ELSE
       l_Dimension_Short_Name := p_Param_Portlet_Region_Code;
       l_Is_XTD_Enabled       := BSC_BIS_KPI_CRUD_PUB.is_XTD_Enabled(p_Param_Portlet_Region_Code);
    END IF;
    l_Does_Dim_Group_Exist := Does_Dim_Grp_Exist(l_Dimension_Short_Name);


    IF (l_Does_Kpi_Exist = FALSE) THEN
         --DBMS_OUTPUT.PUT_LINE('STAGE 11E1');
        IF (l_Does_Dim_Group_Exist = FALSE) THEN
             --DBMS_OUTPUT.PUT_LINE('STAGE 11E');

        -- Create a Dimension Group, if it does not exist for
        -- Parameter Portlet. It updates the Dimension Object Properties as well.

            BSC_BIS_KPI_CRUD_PUB.Create_Dimension(
                 p_Commit              => p_Commit
                ,p_Dim_Short_Name      => l_Dimension_Short_Name
                ,p_Display_Name        => l_Dimension_Short_Name
                ,p_Description         => l_Dimension_Short_Name
                ,p_Dim_Objs_Record     => x_Non_Time_Dimension_Objects
                ,p_Dim_Obj_Short_Names => x_Non_Time_Dim_Obj_Short_Names
                ,p_Dim_Objects_Counter => NVL(x_Non_Time_Counter, 0)
                ,p_Application_Id      => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
                ,p_hide                => FND_API.G_TRUE
                ,x_Return_Status       => x_Return_Status
                ,x_Msg_Count           => x_Msg_Count
                ,x_Msg_Data            => x_Msg_Data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                 RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

        END IF;

        --DBMS_OUTPUT.PUT_LINE('STAGE 12');

        -- Assign the Time dimension peroidicities to the KPI (Objective)
        BSC_BIS_KPI_CRUD_PUB.Assign_KPI_Periodicities(
              p_Commit            => p_Commit
             ,p_Kpi_Id            => l_Kpi_Id
             ,p_Time_Dim_Obj_Sns  => x_Time_Dim_Obj_Short_Names
             ,p_Dft_Dim_Obj_Sn    => NULL
             ,p_Daily_Flag        => FND_API.G_TRUE
             ,p_Is_XTD_Enabled    => l_Is_XTD_Enabled
             ,x_Return_Status     => x_Return_Status
             ,x_Msg_Count         => x_Msg_Count
             ,x_Msg_Data          => x_Msg_Data
        );
        IF (x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;



        --DBMS_OUTPUT.PUT_LINE('STAGE 13');

        SELECT COUNT(1) INTO l_Count
        FROM BSC_SYS_DIM_LEVELS_BY_GROUP
        WHERE DIM_GROUP_ID IN
        (
          SELECT DIM_GROUP_ID
          FROM BSC_SYS_DIM_GROUPS_VL
          WHERE SHORT_NAME = l_Dimension_Short_Name
        );


        --DBMS_OUTPUT.PUT_LINE('STAGE 13 - ' || l_Count);


        -- Assign the Dimension Created to the KPI via a Dimension Set (defaulted to 0)
        BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set(
              p_Commit             => p_Commit
             ,p_Kpi_Id             => l_Kpi_Id
             ,p_Dim_Set_Id         => 0
             ,p_Dim_Short_Names    => l_Dimension_Short_Name
             ,p_Time_Stamp         => NULL
             ,x_Return_Status      => x_Return_Status
             ,x_Msg_Count          => x_Msg_Count
             ,x_Msg_Data           => x_Msg_Data
        );


        --DBMS_OUTPUT.PUT_LINE('(13) x_Return_Status             ' || x_Return_Status);
        --DBMS_OUTPUT.PUT_LINE('(13) x_msg_data                  ' || x_Msg_Data);
        IF (x_Return_Status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSIF ((l_Is_From_Report_Designer) AND (l_Does_Dim_Group_Exist) AND (p_Force_Create_Dim = FND_API.G_TRUE)) THEN
        -- should we add a condition to check for existance of dimension here?
        BSC_BIS_DIMENSION_PUB.Assign_Dimension_Objects
        (       p_commit               => p_Commit
            ,   p_dim_short_name       => l_Dimension_Short_Name
            ,   p_dim_obj_short_names  => x_Non_Time_Dim_Obj_Short_Names
            ,   p_time_stamp           => NULL
            ,   p_create_view          => 0
            ,   x_return_status        => x_Return_Status
            ,   x_msg_count            => x_Msg_Count
            ,   x_msg_data             => x_Msg_Data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;



        --DBMS_OUTPUT.PUT_LINE('STAGE 11A');

        -- code to recreate Periodicities goes here.

        BSC_BIS_KPI_CRUD_PUB.Assign_KPI_Periodicities(
              p_Commit            => p_Commit
             ,p_Kpi_Id            => l_Kpi_Id
             ,p_Time_Dim_Obj_Sns  => x_Time_Dim_Obj_Short_Names
             ,p_Dft_Dim_Obj_Sn    => NULL
             ,p_Daily_Flag        => FND_API.G_TRUE
             ,p_Is_XTD_Enabled    => l_Is_XTD_Enabled
             ,x_Return_Status     => x_Return_Status
             ,x_Msg_Count         => x_Msg_Count
             ,x_Msg_Data          => x_Msg_Data
        );
        IF (x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        --DBMS_OUTPUT.PUT_LINE('STAGE 11B');

    END IF;

    --DBMS_OUTPUT.PUT_LINE('STAGE 14');

    -- Pass the KPI Back;
    x_Kpi_Id := l_Kpi_Id;

-- called Delete_Kpi_AT() to remove AT created KPI base metadata, Bug#4064587
-- its necessary to be called, since there would be still metadata left in BSC_KPIS_B/TL table.
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

        ROLLBACK TO CreateBscBisMetadata;

        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

     x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        ROLLBACK TO CreateBscBisMetadata;

        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN

        ROLLBACK TO CreateBscBisMetadata;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Create_Bsc_Bis_Metadata ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Create_Bsc_Bis_Metadata ';
        END IF;
    WHEN OTHERS THEN

        ROLLBACK TO CreateBscBisMetadata;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Create_Bsc_Bis_Metadata ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Create_Bsc_Bis_Metadata ';
        END IF;
END Create_Bsc_Bis_Metadata;


-- Deletes all the AK Metadata Corresponding to a Region Code

PROCEDURE Delete_AK_Metadata(
      p_Commit                     IN VARCHAR2
    , p_Region_Code                IN VARCHAR2
    , p_Region_Code_Application_Id IN NUMBER
    , x_Return_Status              OUT NOCOPY   VARCHAR2
    , x_Msg_Count                  OUT NOCOPY   NUMBER
    , x_Msg_Data                   OUT NOCOPY   VARCHAR2
) IS
BEGIN
    SAVEPOINT DeleteAKMetadata;
    FND_MSG_PUB.Initialize;

    -- Initialize Procedure Variables.
    x_Return_Status  := FND_API.G_RET_STS_SUCCESS;

    BSC_BIS_KPI_CRUD_PUB.Delete_Misc_Region_Items(
         p_commit           => p_commit
       , p_Region_Code      => p_Region_Code
       , p_Application_Id   => p_Region_Code_Application_Id
       , x_return_status    => x_return_status
       , x_msg_count        => x_msg_count
       , x_msg_data         => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    BIS_PMV_REGION_PVT.DELETE_REGION
    (     p_commit                 => p_commit
      ,   p_Region_Code            => p_Region_Code
      ,   p_Region_Application_Id  => p_Region_Code_Application_Id
      ,   x_return_status          => x_return_status
      ,   x_msg_count              => x_msg_count
      ,   x_msg_data               => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    FND_FORM_FUNCTIONS_PKG.DELETE_ROW (
        X_FUNCTION_ID => BSC_BIS_KPI_CRUD_PUB.Get_Function_Id_By_Name(p_Region_Code)
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteAKMetadata;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteAKMetadata;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteAKMetadata;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Delete_AK_Metadata ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Delete_AK_Metadata ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO DeleteAKMetadata;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Delete_AK_Metadata ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Delete_AK_Metadata ';
        END IF;

END Delete_AK_Metadata;


-- Refreshes AK Metadata Repository with correct Analysis Option combination.

PROCEDURE Referesh_AK_Metadata (
            p_Commit                    IN VARCHAR2
          , p_Kpi_Id                    IN NUMBER
          , p_Deleted_AO_Index          IN NUMBER
          , p_Param_Portlet_Region_Code IN VARCHAR2
          , x_Return_Status             OUT NOCOPY   VARCHAR2
          , x_Msg_Count                 OUT NOCOPY   NUMBER
          , x_Msg_Data                  OUT NOCOPY   VARCHAR2
) IS
    l_Region_Code         AK_REGIONS.REGION_CODE%TYPE;

    CURSOR c_RefreshAK IS
        SELECT A.ANALYSIS_OPTION0 ,
               A.DATASET_ID,
               D.NAME,
               D.HELP,
               M.SHORT_NAME,
               D.FORMAT_ID
        FROM   BSC_KPI_ANALYSIS_MEASURES_VL A,
               BIS_INDICATORS               M,
               BSC_SYS_DATASETS_VL          D
        WHERE  A.ANALYSIS_OPTION0 >= p_Deleted_AO_Index
        AND    A.ANALYSIS_OPTION1 =  0
        AND    A.ANALYSIS_OPTION2 =  0
        AND    A.SERIES_ID        =  0
        AND    A.INDICATOR        =  p_Kpi_Id
        AND    D.DATASET_ID       =  A.DATASET_ID
        AND    M.DATASET_ID       =  D.DATASET_ID;
BEGIN

    SAVEPOINT RefereshAKMetadata;
    FND_MSG_PUB.Initialize;
    x_Return_Status  := FND_API.G_RET_STS_SUCCESS;

    -- Delete all AK Data Starting from p_Deleted_AO_Index (Analysis Option Index + 1)
    FOR cRefresh IN c_RefreshAK LOOP
        l_Region_Code :=  BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Region_Code(p_Kpi_Id, (cRefresh.ANALYSIS_OPTION0)+1);
        BSC_BIS_KPI_CRUD_PUB.Delete_AK_Metadata(
                p_Commit                     => p_Commit
              , p_Region_Code                => l_Region_Code
              , p_Region_Code_Application_Id => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
              , x_Return_Status              => x_Return_Status
              , x_Msg_Count                  => x_Msg_Count
              , x_Msg_Data                   => x_Msg_Data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;


    -- Recreate AK Metadata with new Analysis Option combination
    FOR cRefresh IN c_RefreshAK LOOP
        BSC_BIS_KPI_CRUD_PUB.Create_Ak_Metadata(
              p_Commit                      =>  p_Commit
            , p_Create_Region_Per_AO        =>  FND_API.G_TRUE
            , p_Kpi_Id                      =>  p_Kpi_Id
            , p_Analysis_Option_Id          =>  cRefresh.ANALYSIS_OPTION0
            , p_Dim_Set_Id                  =>  0
            , p_Measure_Short_Name          =>  cRefresh.SHORT_NAME
            , p_Measure_Name                =>  cRefresh.NAME
            , p_Measure_Description         =>  cRefresh.HELP
            , p_User_Portlet_Name           =>  cRefresh.NAME
            , p_Dataset_Format_Id           =>  cRefresh.FORMAT_ID
            , p_Application_Id              =>  BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
            , p_Disable_View_By             =>  'N'
            , p_Param_Portlet_Region_Code   =>  p_Param_Portlet_Region_Code
            , x_Return_Status               =>  x_Return_Status
            , x_Msg_Count                   =>  x_Msg_Count
            , x_Msg_Data                    =>  x_Msg_Data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO RefereshAKMetadata;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO RefereshAKMetadata;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO RefereshAKMetadata;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Referesh_AK_Metadata ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Referesh_AK_Metadata ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO RefereshAKMetadata;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Referesh_AK_Metadata ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Referesh_AK_Metadata ';
        END IF;

END Referesh_AK_Metadata;


-- Applies Disabled Calculation by Measure (DATASET_ID)
PROCEDURE Apply_Disabled_Calculations (
        p_Commit                    IN VARCHAR2
      , p_Dataset_Id                IN NUMBER
      , x_Return_Status             OUT NOCOPY   VARCHAR2
      , x_Msg_Count                 OUT NOCOPY   NUMBER
      , x_Msg_Data                  OUT NOCOPY   VARCHAR2
) IS

    l_Disable_Calc_List   BSC_NUM_LIST;

BEGIN

    SAVEPOINT ApplyDisableCalculations;
    FND_MSG_PUB.Initialize;
    x_Return_Status  := FND_API.G_RET_STS_SUCCESS;

    -- Call type Constructor.
    l_Disable_Calc_List := BSC_NUM_LIST(
                                BSC_BIS_KPI_CRUD_PUB.C_CALC_TC
                              , BSC_BIS_KPI_CRUD_PUB.C_CALC_GROWTH
                              , BSC_BIS_KPI_CRUD_PUB.C_CALC_QTD
                              , BSC_BIS_KPI_CRUD_PUB.C_CALC_YDG
                              , BSC_BIS_KPI_CRUD_PUB.C_CALC_AVG
                              , BSC_BIS_KPI_CRUD_PUB.C_CALC_YYG
                              , BSC_BIS_KPI_CRUD_PUB.C_CALC_DV
                           );

    -- Apply the disabled Calculations.
    BSC_BIS_MEASURE_PUB.Apply_Dataset_Calc(
      p_commit               =>  p_Commit
     ,p_dataset_id           =>  p_Dataset_Id
     ,p_disabled_calc_table  =>  l_Disable_Calc_List
     ,x_return_status        =>  x_Return_Status
     ,x_msg_count            =>  x_Msg_Count
     ,x_msg_data             =>  x_Msg_Data
    );
    IF ((x_return_status <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO ApplyDisableCalculations;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO ApplyDisableCalculations;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO ApplyDisableCalculations;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Apply_Disable_Calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Apply_Disable_Calculations ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO ApplyDisableCalculations;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Apply_Disable_Calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Apply_Disable_Calculations ';
        END IF;
END Apply_Disabled_Calculations;



-- Enables any KPI Calculation, by KPI for the specified Calculation Id
-- Default_Checked, enables or disables the Calculation by default in iViewer
-- 1 Enables by default and 0 disables at the KPI Level

PROCEDURE Enable_Kpi_Calculation (
        p_Commit                    IN VARCHAR2
      , p_Kpi_Id                    IN NUMBER
      , p_Calculation_Id            IN NUMBER
      , p_Default_Checked           IN NUMBER
      , x_Return_Status             OUT NOCOPY   VARCHAR2
      , x_Msg_Count                 OUT NOCOPY   NUMBER
      , x_Msg_Data                  OUT NOCOPY   VARCHAR2
) IS
    l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
BEGIN
    SAVEPOINT EnableKpiCalculation;
    FND_MSG_PUB.Initialize;
    x_Return_Status  := FND_API.G_RET_STS_SUCCESS;

    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id             := p_Kpi_Id;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Calculation_Id := p_Calculation_Id;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0    := BSC_BIS_KPI_CRUD_PUB.C_ENABLE_CALC_U0;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1    := BSC_BIS_KPI_CRUD_PUB.C_ENABLE_CALC_U1;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value  := p_Default_Checked;

    -- Call the private API to update BSC_KPI_CALCULATIONS.DEFAULT_VALUE, USER_LEVEL0, USER_LEVEL1
    BSC_KPI_PVT.Update_Kpi_Calculations(
          p_commit              => p_commit
         ,p_Bsc_Kpi_Entity_Rec  => l_Bsc_Kpi_Entity_Rec
         ,x_Return_Status       => x_Return_Status
         ,x_Msg_Count           => x_Msg_Count
         ,x_Msg_Data            => x_Msg_Data
    );
    IF ((x_return_status <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO EnableKpiCalculation;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO EnableKpiCalculation;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO EnableKpiCalculation;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Enable_Kpi_Calculation ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Enable_Kpi_Calculation ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO EnableKpiCalculation;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Enable_Kpi_Calculation ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Enable_Kpi_Calculation ';
        END IF;
END Enable_Kpi_Calculation;





/*
   FUN   : Returns the list of Time Dimension Objects associated with any Dimension.
*/


PROCEDURE Get_Time_Dim_Obj_By_Dim (
         p_Dim_Short_Name                IN VARCHAR2
       , x_Time_Dim_Obj_Short_Names      OUT NOCOPY VARCHAR2
       , x_Time_Dim_Obj_Counter          OUT NOCOPY NUMBER
       , x_Return_Status                 OUT NOCOPY VARCHAR2
       , x_Msg_Count                     OUT NOCOPY NUMBER
       , x_Msg_Data                      OUT NOCOPY VARCHAR2
) IS
    l_Dummy_Non_Time_Dims     VARCHAR2(32000);
    l_Dummy_Non_Time_Counter  NUMBER;
BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status  := FND_API.G_RET_STS_SUCCESS;

    BSC_BIS_KPI_CRUD_PUB.Get_Dim_Obj_By_Dimension (
         p_Dim_Short_Name                => p_Dim_Short_Name
       , x_Time_Dim_Obj_Short_Names      => x_Time_Dim_Obj_Short_Names
       , x_Time_Dim_Obj_Counter          => x_Time_Dim_Obj_Counter
       , x_Non_Time_Dim_Obj_Short_Names  => l_Dummy_Non_Time_Dims
       , x_Non_Time_Dim_Obj_Counter      => l_Dummy_Non_Time_Counter
       , x_Return_Status                 => x_Return_Status
       , x_Msg_Count                     => x_Msg_Count
       , x_Msg_Data                      => x_Msg_Data
    );
    IF ((x_return_status <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
    WHEN OTHERS THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Get_Time_Dim_Obj_By_Dim ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Get_Time_Dim_Obj_By_Dim ';
        END IF;
END Get_Time_Dim_Obj_By_Dim;



/*
    Returns the list of Non Time Dimension Objects associated with any Dimension.
*/


PROCEDURE Get_Non_Time_Dim_Obj_By_Dim (
         p_Dim_Short_Name                IN VARCHAR2
       , x_Non_Time_Dim_Obj_Short_Names  OUT NOCOPY VARCHAR2
       , x_Non_Time_Dim_Obj_Counter      OUT NOCOPY NUMBER
       , x_Return_Status                 OUT NOCOPY VARCHAR2
       , x_Msg_Count                     OUT NOCOPY NUMBER
       , x_Msg_Data                      OUT NOCOPY VARCHAR2
) IS
    l_Dummy_Time_Dims     VARCHAR2(32000);
    l_Dummy_Time_Counter  NUMBER;
BEGIN

    FND_MSG_PUB.Initialize;
    x_Return_Status  := FND_API.G_RET_STS_SUCCESS;

    BSC_BIS_KPI_CRUD_PUB.Get_Dim_Obj_By_Dimension (
         p_Dim_Short_Name                => p_Dim_Short_Name
       , x_Time_Dim_Obj_Short_Names      => l_Dummy_Time_Dims
       , x_Time_Dim_Obj_Counter          => l_Dummy_Time_Counter
       , x_Non_Time_Dim_Obj_Short_Names  => x_Non_Time_Dim_Obj_Short_Names
       , x_Non_Time_Dim_Obj_Counter      => x_Non_Time_Dim_Obj_Counter
       , x_Return_Status                 => x_Return_Status
       , x_Msg_Count                     => x_Msg_Count
       , x_Msg_Data                      => x_Msg_Data
    );
    IF ((x_return_status <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
    WHEN OTHERS THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Get_Non_Time_Dim_Obj_By_Dim ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Get_Non_Time_Dim_Obj_By_Dim ';
        END IF;
END Get_Non_Time_Dim_Obj_By_Dim;


/*
  Returns both Time and Non_Time Dimension Objects Associated with Dimension
*/

PROCEDURE Get_Dim_Obj_By_Dimension (
         p_Dim_Short_Name                IN VARCHAR2
       , x_Time_Dim_Obj_Short_Names      OUT NOCOPY VARCHAR2
       , x_Time_Dim_Obj_Counter          OUT NOCOPY NUMBER
       , x_Non_Time_Dim_Obj_Short_Names  OUT NOCOPY VARCHAR2
       , x_Non_Time_Dim_Obj_Counter      OUT NOCOPY NUMBER
       , x_Return_Status                 OUT NOCOPY VARCHAR2
       , x_Msg_Count                     OUT NOCOPY NUMBER
       , x_Msg_Data                      OUT NOCOPY VARCHAR2
) IS

  CURSOR  c_Dim_Obj_Short_Name IS
    SELECT  DO.SHORT_NAME
    FROM    BSC_SYS_DIM_GROUPS_VL       DG
          , BSC_SYS_DIM_LEVELS_BY_GROUP DD
          , BSC_SYS_DIM_LEVELS_B        DO
    WHERE   DG.DIM_GROUP_ID = DD.DIM_GROUP_ID
    AND     DD.DIM_LEVEL_ID = DO.DIM_LEVEL_ID
    AND     DG.SHORT_NAME   = p_Dim_Short_Name;

    l_Count  NUMBER;

BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status  := FND_API.G_RET_STS_SUCCESS;

    x_Time_Dim_Obj_Counter     := 0;
    x_Non_Time_Dim_Obj_Counter := 0;

    SELECT COUNT(1) INTO l_Count
    FROM   BSC_SYS_DIM_GROUPS_VL
    WHERE  SHORT_NAME = p_Dim_Short_Name;

    IF l_Count = 0 THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_SHORT_NAME');
        FND_MESSAGE.SET_TOKEN('BSC_GROUP_SHORT_NAME', p_Dim_Short_Name, TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    FOR c_DSN IN c_Dim_Obj_Short_Name LOOP
        IF(BSC_BIS_KPI_CRUD_PUB.Is_Time_Dim_Obj(c_DSN.SHORT_NAME) = FND_API.G_TRUE) THEN
            IF(x_Time_Dim_Obj_Counter = 0) THEN
                x_Time_Dim_Obj_Short_Names := c_DSN.SHORT_NAME;
            ELSE
                x_Time_Dim_Obj_Short_Names := x_Time_Dim_Obj_Short_Names || ',' || c_DSN.SHORT_NAME;
            END IF;
            x_Time_Dim_Obj_Counter := x_Time_Dim_Obj_Counter + 1;
        ELSE
            IF(x_Non_Time_Dim_Obj_Counter = 0) THEN
                x_Non_Time_Dim_Obj_Short_Names := c_DSN.SHORT_NAME;
            ELSE
                x_Non_Time_Dim_Obj_Short_Names := x_Non_Time_Dim_Obj_Short_Names || ',' || c_DSN.SHORT_NAME;
            END IF;
            x_Non_Time_Dim_Obj_Counter := x_Non_Time_Dim_Obj_Counter + 1;
        END IF;
    END LOOP;


EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
    WHEN OTHERS THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Get_Dim_Obj_By_Dimension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Get_Dim_Obj_By_Dimension ';
        END IF;
END Get_Dim_Obj_By_Dimension;



/*
   Returns "T" if the current Dimension Object is a Time Dimension Object, else returns "F"
*/


FUNCTION Is_Time_Dim_Obj (
          p_Dim_Obj_Short_Name IN VARCHAR2
) RETURN VARCHAR2
IS
    l_Is_Time_Dim_Obj  VARCHAR2(2);
BEGIN
    NULL;
    SELECT DECODE(COUNT(1), 0, FND_API.G_FALSE, FND_API.G_TRUE)
    INTO   l_Is_Time_Dim_Obj
    FROM   BSC_SYS_DIM_GROUPS_VL       DG,
           BSC_SYS_DIM_LEVELS_BY_GROUP DD,
           BSC_SYS_DIM_LEVELS_B        DO
    WHERE  DG.DIM_GROUP_ID = DD.DIM_GROUP_ID
    AND    DD.DIM_LEVEL_ID = DO.DIM_LEVEL_ID
    AND   ((DG.SHORT_NAME  = BSC_BIS_KPI_CRUD_PUB.C_OLTP_TIME) OR (DG.SHORT_NAME = BSC_BIS_KPI_CRUD_PUB.C_EDW_TIME))
    AND    DO.SHORT_NAME   =  p_Dim_Obj_Short_Name;

    RETURN l_Is_Time_Dim_Obj;

END Is_Time_Dim_Obj;


/*
   Procedure version of is_Time_Dim_Obj
*/

PROCEDURE Is_Time_Dim_Obj (
            p_Dim_Obj_Short_Name IN VARCHAR2
          , x_Is_Time_Dim_Obj    OUT NOCOPY VARCHAR2
) IS
BEGIN

    x_Is_Time_Dim_Obj := NULL;

    SELECT DECODE(COUNT(1), 0, FND_API.G_FALSE, FND_API.G_TRUE)
    INTO   x_Is_Time_Dim_Obj
    FROM   BSC_SYS_DIM_GROUPS_VL       DG,
           BSC_SYS_DIM_LEVELS_BY_GROUP DD,
           BSC_SYS_DIM_LEVELS_B        DO
    WHERE  DG.DIM_GROUP_ID = DD.DIM_GROUP_ID
    AND    DD.DIM_LEVEL_ID = DO.DIM_LEVEL_ID
    AND   ((DG.SHORT_NAME  = BSC_BIS_KPI_CRUD_PUB.C_OLTP_TIME) OR (DG.SHORT_NAME = BSC_BIS_KPI_CRUD_PUB.C_EDW_TIME))
    AND    DO.SHORT_NAME   =  p_Dim_Obj_Short_Name;

END Is_Time_Dim_Obj;


-- Checks if the Dimension Passed is a Time Dimension or Not.

PROCEDURE Is_Time_Dimension (
            p_Dimension_Short_Name IN VARCHAR2
          , x_Is_Time_Dimension    OUT NOCOPY VARCHAR2
) IS
BEGIN

    IF((p_Dimension_Short_Name = BSC_BIS_KPI_CRUD_PUB.C_OLTP_TIME) OR
       (p_Dimension_Short_Name = BSC_BIS_KPI_CRUD_PUB.C_EDW_TIME)) THEN
       x_Is_Time_Dimension := FND_API.G_TRUE;
    ELSE
       x_Is_Time_Dimension := FND_API.G_FALSE;
    END IF;
END Is_Time_Dimension;


/*
    Returns the region code that will be associated with the next Analysis Option
    This will be populated as the SHORT_NAME to the table BSC_KPI_ANALYSIS_OPTIONS_B

    This API is specific to Start-to-End KPI, do not use it when we have Multiple AO Groups.
*/
FUNCTION Get_Next_Region_Code_By_AO (
        p_Kpi_Id           IN NUMBER
      , p_Analysis_Group0  IN NUMBER
)  RETURN VARCHAR2
IS
    l_Region_Code          AK_REGIONS.REGION_CODE%TYPE;
    l_Next_Analysis_Option NUMBER;
    l_Count                NUMBER;
BEGIN

    l_Region_Code := NULL;
    l_Count       := 0;

    SELECT (NVL(MAX(OPTION_ID), -1)+1)
    INTO   l_Next_Analysis_Option
    FROM   BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE  INDICATOR          = p_Kpi_Id
    AND    ANALYSIS_GROUP_ID  = NVL(p_Analysis_Group0, 0);


    l_Region_Code := BSC_UTILITY.C_BSC_UNDERSCORE || p_Kpi_Id || '_' || l_Next_Analysis_Option;

    RETURN l_Region_Code;

EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END Get_Next_Region_Code_By_AO;

-- Gets BSC_KPIS_VL.INDICATOR using BIS_INDICATORS.SHORT_NAME
-- Used in UI

FUNCTION Get_Objective_By_Kpi(
            p_Short_Name   IN VARCHAR2
) RETURN VARCHAR2
IS
  l_Count  NUMBER;
  l_Kpi_Id VARCHAR2(10);
BEGIN
  l_Count := 0;

  SELECT
    COUNT(1)
  INTO
    l_Count
  FROM
    bsc_sys_measures m,
    bsc_sys_datasets_vl d,
    bis_indicators i
  WHERE
    i.dataset_id  = d.dataset_id AND
    d.measure_id1 = m.measure_id AND
    i.short_name  = p_Short_Name AND
    m.source  = BSC_BIS_MEASURE_PUB.c_BSC;

  -- Measure Does not exist or not a BSC Measure
  IF l_Count = 0 THEN
    RETURN NULL;
  END IF;

  SELECT DISTINCT INDICATOR
  INTO   l_Kpi_Id
  FROM   BSC_KPI_ANALYSIS_OPTIONS_B
  WHERE  SHORT_NAME = (SELECT SUBSTR(ACTUAL_DATA_SOURCE, 1, INSTR(ACTUAL_DATA_SOURCE, '.') - 1) REGION_CODE
                       FROM   BIS_INDICATORS
                       WHERE SHORT_NAME = p_Short_Name);

  RETURN l_Kpi_Id;

EXCEPTION
  WHEN OTHERS THEN
     RETURN NULL;

END Get_Objective_By_Kpi;


-- Gets the parameter portlet associated with the current AK Region.
FUNCTION Get_Param_Portlet_By_Region (
           p_Region_Code IN VARCHAR2
) RETURN VARCHAR2
IS
   l_Region_Code VARCHAR2(30);

   CURSOR cAttrCode IS
      SELECT ATTRIBUTE_CODE
      FROM   AK_REGION_ITEMS
      WHERE  REGION_CODE = p_Region_Code
      AND    ITEM_STYLE  = BIS_AK_REGION_PUB.c_NESTED_REGION_STYLE
      AND    NESTED_REGION_CODE IS NOT NULL;
BEGIN

   l_Region_Code := NULL;

   FOR cAC IN cAttrCode LOOP
      l_Region_Code := cAC.ATTRIBUTE_CODE;
   END LOOP;

   RETURN l_Region_Code;

EXCEPTION
  WHEN OTHERS THEN
     RETURN NULL;
END Get_Param_Portlet_By_Region;



-- Checks if AS_OF_DATE is enabled for the Parameter Portlet
-- Its recommended that this API be used only for validating Paramter Portlets.
-- Added for Bug#3767168

FUNCTION is_XTD_Enabled (
           p_Region_Code IN VARCHAR2
) RETURN VARCHAR2
IS
   l_Count NUMBER;
BEGIN

   l_Count := 0;

   SELECT COUNT(1)
   INTO   l_Count
   FROM   AK_REGION_ITEMS
   WHERE  REGION_CODE    = p_Region_Code
   AND    ATTRIBUTE_CODE = BSC_BIS_KPI_CRUD_PUB.C_AS_OF_DATE;

   IF (l_Count = 0) THEN
      RETURN FND_API.G_FALSE;
   ELSE
      RETURN FND_API.G_TRUE;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     RETURN FND_API.G_FALSE;
END is_XTD_Enabled;


-- Checks if AS_OF_DATE is enabled for the Parameter Portlet
-- Overloaded for AGRD
FUNCTION is_XTD_Enabled (
           p_Time_Dimension_Objects IN BSC_VARCHAR2_TBL_TYPE
) RETURN VARCHAR2
IS
BEGIN

   FOR i IN 1..p_Time_Dimension_Objects.COUNT LOOP
     IF (p_Time_Dimension_Objects(i) = BSC_BIS_KPI_CRUD_PUB.C_AS_OF_DATE) THEN
        RETURN FND_API.G_TRUE;
     END IF;
   END LOOP;


   RETURN FND_API.G_FALSE;

EXCEPTION
  WHEN OTHERS THEN
     RETURN FND_API.G_FALSE;
END is_XTD_Enabled;



/*
  Which will return a VARCHAR2 as follows, with objectives ordered by Objective ID
  (BSC_KPIS_VL.INDICATOR)

  "3001 - Sales Overview Page, 3002 - Email Classification Page, 3003 - ASO BIL Page"

  Added for Bug#3780082
*/


FUNCTION Get_S2EObjective_With_XTD
RETURN VARCHAR2 IS

   l_Name_Holder   VARCHAR2(32000); -- needs to be large enough
   l_Count         NUMBER;

   CURSOR c_Obj_Names IS
      SELECT  (KV.INDICATOR || ' - ' || KV.NAME) XTDOBJECTIVE
      FROM    BSC_KPIS_VL          KV
             ,BSC_KPI_CALCULATIONS KC
      WHERE  KC.INDICATOR      = KV.INDICATOR
      AND    KC.CALCULATION_ID = BSC_BIS_KPI_CRUD_PUB.C_CALC_XTD
      AND    KC.USER_LEVEL0    = BSC_BIS_KPI_CRUD_PUB.C_ENABLE_CALC_U0
      AND    KC.USER_LEVEL1    = BSC_BIS_KPI_CRUD_PUB.C_ENABLE_CALC_U1
      AND    KV.SHORT_NAME IS NOT NULL
      ORDER  BY KV.INDICATOR;

BEGIN

   l_Name_Holder := NULL;
   l_Count       := 0;


   FOR cObjNames IN c_Obj_Names LOOP
      IF (l_Count = 0) THEN
         l_Name_Holder := cObjNames.XTDOBJECTIVE;
      ELSE
         l_Name_Holder :=  l_Name_Holder || ', ' || cObjNames.XTDOBJECTIVE;
      END IF;
      l_Count := l_Count + 1;

      -- We are restricting display to a maximum of 200 Objectives.
      IF (l_Count > BSC_BIS_KPI_CRUD_PUB.C_MAX_OBJECTIVES_DISPLAY) THEN
        EXIT;
      END IF;
   END LOOP;

   RETURN l_Name_Holder;


EXCEPTION
   WHEN OTHERS THEN
       RETURN NULL;
END Get_S2EObjective_With_XTD;


--
-- Returns if the Dimension Object(level) has been excluded from Constant Class
-- BSC_BIS_KPI_CRUD_PUB.G_EXCLUDE_DIMOBJ_CLASS
--
-- Returns "T" if Dimension Object is excluded, else returns "F"
-- Example : PLAN_SNAPSHOT will return "T"
--

FUNCTION Is_Excluded_Dimension_Object(
             p_Short_Name  IN VARCHAR2
) RETURN VARCHAR2 IS

  l_Index    NUMBER;
  l_Return   VARCHAR2(3);

BEGIN
  l_Return := FND_API.G_FALSE;

  FOR l_Index IN 1..G_EXCLUDE_DIMOBJ_CLASS.LAST LOOP
     IF (p_Short_Name = G_EXCLUDE_DIMOBJ_CLASS(l_Index)) THEN
        l_Return := FND_API.G_TRUE;
        EXIT;
     END IF;
  END LOOP;

  RETURN l_Return;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FND_API.G_FALSE;
END Is_Excluded_Dimension_Object;



-- Validates of the Start-to-End KPI can be deleted using the Delete button from Update KPI Page.
-- This implementation is not complete at this point of time
-- None of the messages have been approved by PM, so please do not modify the API
PROCEDURE Validate_Kpi_Delete
(
         p_Measure_Short_Name            IN  VARCHAR2
       , x_Return_Status                 OUT NOCOPY VARCHAR2
       , x_Msg_Count                     OUT NOCOPY NUMBER
       , x_Msg_Data                      OUT NOCOPY VARCHAR2
) IS
   l_Return_Status         VARCHAR2(3);
   l_Msg_Count             NUMBER;
   l_Return_Msg            VARCHAR2(32000);
   l_Message               VARCHAR2(32000);
   l_Temp_Message          VARCHAR2(32000);
   l_Dep_Message           VARCHAR2(32000);
   l_Measure_Short_Name    BIS_INDICATORS.SHORT_NAME%TYPE;
   l_Report_Function_Name  BIS_INDICATORS.FUNCTION_NAME%TYPE;
   l_Parent_Obj_Table      BIS_RSG_PUB_API_PKG.t_BIA_RSG_Obj_Table;
   l_Index_Count           NUMBER;
   l_Trigger_Exception     BOOLEAN;
   l_Trigger_Warning       BOOLEAN;
   l_Loop                  NUMBER;
   l_Parent_Object_Type    VARCHAR2(10);
   l_Kpi_Name              BIS_INDICATORS_TL.NAME%TYPE;

   l_Msg_Count_Size        NUMBER;
   l_Msg_Max_Count_Size    NUMBER;
   l_Msg_Exceeds_Size      BOOLEAN;
   l_Tmp_Msg_Count_Size    NUMBER;

   CURSOR c_Tab_List IS
     SELECT T.NAME
     FROM   BSC_TABS_VL                 T
          , BSC_TAB_INDICATORS          TI
          , BSC_KPI_ANALYSIS_MEASURES_B AM
          , BIS_INDICATORS              BI
     WHERE  BI.SHORT_NAME   = l_Measure_Short_Name
     AND    AM.DATASET_ID   = BI.DATASET_ID
     AND    TI.INDICATOR    = AM.INDICATOR
     AND    T.TAB_ID        = TI.TAB_ID;

   CURSOR c_Report_List IS
     SELECT B.FUNCTION_NAME
     FROM   BIS_INDICATORS B
     WHERE  B.SHORT_NAME = l_Measure_Short_Name;

   CURSOR c_Kpi_Report_List IS
     SELECT   K.NAME || ' [' || K.INDICATOR || ']' NAME
     FROM     BSC_KPIS_VL                 K
            , BSC_KPI_ANALYSIS_MEASURES_B A
            , BIS_INDICATORS              B
     WHERE  K.INDICATOR  = A.INDICATOR
     AND    A.DATASET_ID = B.DATASET_ID
     AND    B.SHORT_NAME = l_Measure_Short_Name;

   CURSOR c_PMV_Report_List IS
     SELECT DISTINCT R.NAME NAME
     FROM   AK_REGION_ITEMS RI,
            AK_REGIONS_VL   R
     WHERE  RI.ATTRIBUTE1 IN ('MEASURE', 'MEASURE_NOTARGET')
     AND    RI.ATTRIBUTE2  = l_Measure_Short_Name
     AND    RI.REGION_CODE = R.REGION_CODE;
BEGIN

    FND_MSG_PUB.Initialize;
    x_Return_Status     := FND_API.G_RET_STS_SUCCESS;


   l_Index_Count        := 0;
   l_Measure_Short_Name := p_Measure_Short_Name;
   l_Trigger_Exception  := FALSE;
   l_Trigger_Warning := FALSE;

   l_Msg_Count_Size        := 0;
   l_Tmp_Msg_Count_Size    := 0;
   l_Msg_Max_Count_Size    := BSC_BIS_KPI_CRUD_PUB.C_MAX_MESSAGE_SIZE;
   l_Msg_Exceeds_Size      := FALSE;

   FOR cReportList IN c_Report_List LOOP
      l_Report_Function_Name := cReportList.FUNCTION_NAME;
   END LOOP;

   l_Message :=  '<ol>';


   -- The same code needs to be executed for KPI Portlets and DBI Pages, hence the look 1..2
   FOR l_Loop IN 1..2 LOOP

       IF (NOT l_Msg_Exceeds_Size) THEN
           IF l_Loop = 1 THEN
             l_Parent_Object_Type := 'PAGE';
           ELSE
             l_Parent_Object_Type := 'PORTLET';
           END IF;

           l_Index_Count          := 0;
           -- Get a list of Pages associated with the (RSG BIA Cache table)
           l_Parent_Obj_Table  :=   BIS_RSG_PUB_API_PKG.GetParentObjects
                                    (
                                        p_Dep_Obj_Name  => l_Report_Function_Name
                                      , p_Dep_Obj_Type  => 'REPORT'
                                      , p_Obj_Type      => l_Parent_Object_Type
                                      , x_Return_Status => l_Return_Status
                                      , x_Msg_Data      => l_Return_Msg
                                    );
            IF ((l_Return_Status IS NOT NULL) AND (l_Return_Status  <> FND_API.G_RET_STS_SUCCESS)) THEN
              FND_MSG_PUB.Initialize;
              FND_MESSAGE.SET_NAME('BIS',l_Return_Msg);
              FND_MSG_PUB.ADD;
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -- If the Report is associated with more than 1 Overview pages/KPI List.
            IF (l_Parent_Obj_Table.COUNT > 1) THEN


                l_Index_Count := l_Parent_Obj_Table.FIRST;

                LOOP
                   IF l_Loop = 1 THEN
                      FND_MESSAGE.SET_NAME('BSC','BSC_KPI_DEP_DBIPAGE'); -- Need to use BSC_KPI_DEP_DBIPAGE
                      l_Trigger_Warning   := TRUE;
                   ELSE
                      FND_MESSAGE.SET_NAME('BSC','BSC_KPI_DEP_KPI_REGION'); -- Message here is correct BSC_KPI_DEP_KPI_REGION
                  l_Trigger_Exception := TRUE;

                   END IF;

                   FND_MESSAGE.SET_TOKEN('DEP_OBJECT',BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_User_Function_Name(l_Parent_Obj_Table(l_Index_Count).Object_Name));
                   l_Dep_Message := '<li type=1>'||FND_MESSAGE.GET || '</li>';


                   IF (LENGTH(l_Message||l_Dep_Message) >= l_Msg_Max_Count_Size) THEN
                        l_Msg_Exceeds_Size := TRUE;
                        EXIT;
                   ELSE
                        l_Message := l_Message || l_Dep_Message;
                   END IF;

                   EXIT WHEN l_Index_Count = l_Parent_Obj_Table.LAST;
                   l_Index_Count := l_Parent_Obj_Table.NEXT(l_Index_Count);
                END LOOP;

            END IF;
        END IF;
    END LOOP;

    -- Case #1
    -- Check for Scorecards
    IF (NOT l_Msg_Exceeds_Size) THEN
        OPEN c_Tab_List;
          LOOP
            FETCH c_Tab_List INTO l_Dep_Message;
            EXIT WHEN c_Tab_List%NOTFOUND;

            FND_MESSAGE.SET_NAME('BSC','BSC_KPI_DEP_SCORECARD'); -- Need to use BSC_KPI_DEP_SCORECARD
            FND_MESSAGE.SET_TOKEN('DEP_OBJECT', l_Dep_Message);
            l_Dep_Message := FND_MESSAGE.GET;

            l_Temp_Message := l_Temp_Message || '<li type=1>'||l_Dep_Message || '</li>';
          END LOOP;


        -- There is no need to log message if we have only 1 or 0 Scorecards associated to the KPI
          IF c_Tab_List%ROWCOUNT > 1 THEN
              IF(LENGTH(l_Message || l_Temp_Message) >= l_Msg_Max_Count_Size) THEN
                l_Msg_Exceeds_Size := TRUE;
              ELSE
                l_Trigger_Exception := TRUE;
                l_Message           := l_Message || l_Temp_Message;
              END IF;
          END IF;
        CLOSE c_Tab_List;
    END IF;

    -- Case #2
    -- Check for KPI reports in iViewer
    IF (NOT l_Msg_Exceeds_Size) THEN
        OPEN c_Kpi_Report_List;
          LOOP
            FETCH c_Kpi_Report_List INTO l_Dep_Message;
            EXIT WHEN c_Kpi_Report_List%NOTFOUND;

            FND_MESSAGE.SET_NAME('BSC','BSC_KPI_DEP_KPIREPORT'); -- Need to use BSC_KPI_DEP_KPIREPORT
            FND_MESSAGE.SET_TOKEN('DEP_OBJECT', l_Dep_Message);
            l_Dep_Message := FND_MESSAGE.GET;

            l_Temp_Message := l_Temp_Message || '<li type=1>'||l_Dep_Message || '</li>';

          END LOOP;

          -- There is no need to log message if we have only 1 Objective(s) associated to the KPI
          IF c_Kpi_Report_List%ROWCOUNT > 1 THEN
              IF(LENGTH(l_Message || l_Temp_Message) >= l_Msg_Max_Count_Size) THEN
                  l_Msg_Exceeds_Size := TRUE;
              ELSE
                  l_Trigger_Exception := TRUE;
                  l_Message           := l_Message || l_Temp_Message;
              END IF;
          END IF;
        CLOSE c_Kpi_Report_List;
    END IF;


    -- Case #3
    -- Check for PMV Reports
    IF (NOT l_Msg_Exceeds_Size) THEN
        OPEN c_PMV_Report_List;
          LOOP
            FETCH c_PMV_Report_List INTO l_Dep_Message;
            EXIT WHEN c_PMV_Report_List%NOTFOUND;

            FND_MESSAGE.SET_NAME('BSC','BSC_KPI_DEP_KPI_REGION'); -- Need to use BSC_KPI_DEP_PMVREPORT
            FND_MESSAGE.SET_TOKEN('DEP_OBJECT', l_Dep_Message);
            l_Dep_Message := FND_MESSAGE.GET;

            l_Temp_Message := l_Temp_Message || '<li type=1>'||l_Dep_Message || '</li>';

          END LOOP;

          -- There is no need to log message if we have only 1 Report(s) associated to the KPI
          IF c_PMV_Report_List%ROWCOUNT > 1 THEN
              IF(LENGTH(l_Message || l_Temp_Message) >= l_Msg_Max_Count_Size) THEN
                  l_Msg_Exceeds_Size := TRUE;
              ELSE
                  l_Trigger_Exception := TRUE;
                  l_Message           := l_Message || l_Temp_Message;
              END IF;
          END IF;
        CLOSE c_PMV_Report_List;
    END IF;

    l_Message := l_Message || '</ol>';

    BEGIN
      SELECT NAME
      INTO   l_Kpi_Name
      FROM   BIS_INDICATORS_VL
      WHERE  SHORT_NAME = l_Measure_Short_Name;
    EXCEPTION WHEN OTHERS THEN
      l_Kpi_Name := l_Measure_Short_Name;
    END;

    IF (l_Trigger_Warning = TRUE AND l_Trigger_Exception = FALSE) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_KPI_DELETE_WARNING');
    FND_MESSAGE.SET_TOKEN('OBJ_NAME', l_Kpi_Name);
    FND_MESSAGE.SET_TOKEN('DEP_OBJ_LIST', l_Message);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get
    (  p_encoded   =>  FND_API.G_FALSE
       ,   p_count     =>  x_Msg_Count
       ,   p_data      =>  x_Msg_Data
        );
    END IF;

    IF (l_Trigger_Exception = TRUE ) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_KPI_IN_USE');
      FND_MESSAGE.SET_TOKEN('OBJ_NAME', l_Kpi_Name);
      FND_MESSAGE.SET_TOKEN('DEP_OBJ_LIST', l_Message);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_Return_Status     := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_Kpi_Report_List%ISOPEN) THEN
            CLOSE c_Kpi_Report_List;
        END IF;

        IF (c_Tab_List%ISOPEN) THEN
            CLOSE c_Tab_List;
        END IF;

        IF (c_PMV_Report_List%ISOPEN) THEN
            CLOSE c_PMV_Report_List;
        END IF;

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_Msg_Count
           ,   p_data      =>  x_Msg_Data
        );

        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        IF (c_Kpi_Report_List%ISOPEN) THEN
            CLOSE c_Kpi_Report_List;
        END IF;

        IF (c_Tab_List%ISOPEN) THEN
            CLOSE c_Tab_List;
        END IF;

        IF (c_PMV_Report_List%ISOPEN) THEN
            CLOSE c_PMV_Report_List;
        END IF;

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_Msg_Count
           ,   p_data      =>  x_Msg_Data
        );

        IF (x_Msg_Data IS NOT NULL) THEN
            x_Msg_Data      :=  x_Msg_Data; --||' -> BSC_BIS_KPI_CRUD_PUB.Validate_Kpi_Delete ';
        ELSE
            x_Msg_Data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Validate_Kpi_Delete ';
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;


END Validate_Kpi_Delete;


-- Loads DBI calendar required for Start-to-End KPI.
PROCEDURE Populate_DBI_Calendar
(
         x_Return_Status                 OUT NOCOPY VARCHAR2
       , x_Msg_Count                     OUT NOCOPY NUMBER
       , x_Msg_Data                      OUT NOCOPY VARCHAR2
) IS

    l_Error_Msg  VARCHAR2(255);
BEGIN

    FND_MSG_PUB.Initialize;
    x_Return_Status     := FND_API.G_RET_STS_SUCCESS;

    -- call the DBI API to populate DBI Calendars into BSC_SYS_CALENDARS and BSC_SYS_PERIODICITIES.
    BSC_DBI_CALENDAR.Load_Dbi_Cal_Metadata(l_Error_Msg);

    IF (l_Error_Msg IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_ERR_LOAD_DBI_CAL_METADATA');
        FND_MESSAGE.SET_TOKEN('ERRMSG', l_Error_Msg);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_Msg_Count
           ,   p_data      =>  x_Msg_Data
        );

        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_Msg_Count
           ,   p_data      =>  x_Msg_Data
        );

        IF (x_Msg_Data IS NOT NULL) THEN
            x_Msg_Data      :=  x_Msg_Data||' -> BSC_BIS_KPI_CRUD_PUB.Populate_DBI_Calendar ';
        ELSE
            x_Msg_Data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Populate_DBI_Calendar ';
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;

END Populate_DBI_Calendar;

-- added for Bug#3777647
PROCEDURE Get_Region_Codes_By_Short_Name (
              p_Short_Name    IN VARCHAR
            , x_Region_Codes  OUT NOCOPY VARCHAR2
) IS

  l_Kpi_Id        NUMBER;
  l_Count         NUMBER;

  -- short_name now stores the AK Region codes for the Objective AOs
  CURSOR c_Regions IS
    SELECT SHORT_NAME
    FROM   BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE  INDICATOR = l_Kpi_Id;

BEGIN

  l_Count        := 0;
  x_Region_Codes := NULL;

  l_Kpi_Id       := NVL(Get_Objective_By_Kpi(p_Short_Name), BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY);

  IF l_Kpi_Id <> BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY THEN
     FOR cRgn IN c_Regions LOOP
        IF l_Count = 0 THEN
           x_Region_Codes := cRgn.SHORT_NAME;
        ELSE
           x_Region_Codes := x_Region_Codes || ','|| cRgn.SHORT_NAME;
        END IF;
        l_Count := l_Count + 1;
     END LOOP;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
     x_Region_Codes := NULL;
END Get_Region_Codes_By_Short_Name;


/*
 Check_XTD_Summarization returns the error message, when the XTD is available at the
 Parameter Portlet level and the profile ADV Summarization is truned off.
*/

PROCEDURE Check_XTD_Summarization
(
         p_Param_Portlet_Region_Code     IN  VARCHAR2
       , x_Return_Status                 OUT NOCOPY VARCHAR2
       , x_Msg_Count                     OUT NOCOPY NUMBER
       , x_Msg_Data                      OUT NOCOPY VARCHAR2
)
IS
BEGIN
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    IF (p_Param_Portlet_Region_Code IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_PARAM_PORTLET');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Check if AS_OF_DATE is enabled at the Paramter Portlet
    IF (is_XTD_Enabled(p_Param_Portlet_Region_Code) = FND_API.G_TRUE) THEN
       -- Check if Advance Summarization Profile >= 0, else throw and error.
       IF (BSC_UTILITY.Is_Adv_Summarization_Enabled = FND_API.G_FALSE) THEN
           FND_MESSAGE.SET_NAME('BSC','BSC_ENABLE_ADV_SUMMARIZATION');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_Msg_Count
           ,   p_data      =>  x_Msg_Data
        );

        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_Msg_Count
           ,   p_data      =>  x_Msg_Data
        );

        IF (x_Msg_Data IS NOT NULL) THEN
            x_Msg_Data      :=  x_Msg_Data||' -> BSC_BIS_KPI_CRUD_PUB.Check_XTD_Summarization ';
        ELSE
            x_Msg_Data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Check_XTD_Summarization ';
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;

END Check_XTD_Summarization;

-- Return the Custom KPI details for Bug#3814292
PROCEDURE Get_Kpi_Details
(
         p_Measure_Short_Name            IN  VARCHAR2
       , x_Kpi_Name                      OUT NOCOPY VARCHAR2
       , x_Report_Code                   OUT NOCOPY VARCHAR2
) IS
BEGIN
  BEGIN
      SELECT NAME
      INTO   x_Kpi_Name
      FROM   BSC_SYS_DATASETS_VL
      WHERE  DATASET_ID  = Get_Dataset_Id(p_Measure_Short_Name);
  EXCEPTION
     WHEN OTHERS THEN
       x_Kpi_Name := NULL;
  END;


  BEGIN
     SELECT SUBSTR(ACTUAL_DATA_SOURCE, 1, INSTR(ACTUAL_DATA_SOURCE, '.') - 1)
     INTO   x_Report_Code
     FROM   BIS_INDICATORS
     WHERE  SHORT_NAME = p_Measure_Short_Name;
  EXCEPTION
     WHEN OTHERS THEN
       x_Report_Code := NULL;
  END;

EXCEPTION
     WHEN OTHERS THEN
        NULL;
END Get_Kpi_Details;


/*
  This API takes the format ID.
  The format id 0, 1, 2 in BSC represents percentage format and the rest is of non-percent
  type

  This API returns the display type for the Change Attribute for a PMV report and
  implements the standard has been for change to be displayed in units if actual
  is in percent, and change displayed in percent if actual displayed in units.

*/

FUNCTION Get_Change_Disp_Type_By_Mask (
          p_Format_Id NUMBER
) RETURN VARCHAR2 IS

  l_Display_Type   VARCHAR2(5);
  l_Format_Id      NUMBER;

BEGIN

      l_Format_Id := p_Format_Id;
      l_Display_Type := BSC_BIS_KPI_CRUD_PUB.C_FORMAT_POINTER; -- displays %age

      -- Check for standard format ids
      IF (p_Format_Id NOT IN (0, 1, 2, 5, 6, 7)) THEN
         l_Format_Id := 0;
      END IF;

      -- If format_id is 0, 1 or 2 it means that the Display Mask is
      -- percentage, we then should return integer, else we must return
      -- percentage as the display type

      IF (l_Format_Id IN (0, 1, 2)) THEN
         l_Display_Type := BSC_BIS_KPI_CRUD_PUB.C_FORMAT_INTEGER;
      ELSE
         l_Display_Type := BSC_BIS_KPI_CRUD_PUB.C_FORMAT_POINTER;
      END IF;


      RETURN l_Display_Type;

EXCEPTION
   WHEN OTHERS THEN
      RETURN l_Display_Type;
END Get_Change_Disp_Type_By_Mask;


-- added for bug#3893949

 /*
   API to delete S2E Objective and all the analysis options under the Objective
   deleting each analysis option will delete the assosiated base Measure,
   Fnd Form function and Report.
 */
 PROCEDURE Delete_S2E_Objective(
   p_commit              IN          VARCHAR2 := FND_API.G_FALSE
  ,p_indicator           IN      NUMBER
  ,x_return_status       OUT NOCOPY     VARCHAR2
  ,x_msg_count           OUT NOCOPY     NUMBER
  ,x_msg_data            OUT NOCOPY     VARCHAR2
 ) IS

  l_measure_shortname BIS_INDICATORS.SHORT_NAME%TYPE;
  l_ana_option0 BSC_KPI_ANALYSIS_MEASURES_B.ANALYSIS_OPTION0%TYPE;
  l_ana_option1 BSC_KPI_ANALYSIS_MEASURES_B.ANALYSIS_OPTION1%TYPE;
  l_ana_option2 BSC_KPI_ANALYSIS_MEASURES_B.ANALYSIS_OPTION2%TYPE;
  l_series_id BSC_KPI_ANALYSIS_MEASURES_B.SERIES_ID%TYPE;

  CURSOR c_get_ana_options IS
   SELECT a.indicator,a.analysis_option0,a.analysis_option1,a.analysis_option2,a.series_id
   FROM bsc_oaf_analysys_opt_comb_v a
   WHERE a.indicator = p_indicator;

  CURSOR c_get_measure_short_name(p_ana_option0 BSC_KPI_ANALYSIS_MEASURES_B.ANALYSIS_OPTION0%TYPE
          ,p_ana_option1 BSC_KPI_ANALYSIS_MEASURES_B.ANALYSIS_OPTION1%TYPE
          ,p_ana_option2 BSC_KPI_ANALYSIS_MEASURES_B.ANALYSIS_OPTION2%TYPE
          ,p_series_id BSC_KPI_ANALYSIS_MEASURES_B.SERIES_ID%TYPE) IS
   SELECT a.short_name FROM bis_indicators a,bsc_kpi_analysis_measures_b b
   WHERE a.dataset_id = b.dataset_id
   AND B.INDICATOR = p_indicator
   AND B.ANALYSIS_OPTION0 = p_ana_option0
   AND B.ANALYSIS_OPTION1 = p_ana_option1
   AND B.ANALYSIS_OPTION2 = p_ana_option2
   AND B.SERIES_ID = p_series_id;

   TYPE shortnames_array IS TABLE OF BIS_INDICATORS.SHORT_NAME%TYPE INDEX BY BINARY_INTEGER;
   l_measure_names shortnames_array;
   l_index pls_integer;

 BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_index := 1;

   FOR cd_get_analysis_option IN c_get_ana_options LOOP
     l_ana_option0 := cd_get_analysis_option.analysis_option0;
     l_ana_option1 := cd_get_analysis_option.analysis_option1;
     l_ana_option2 := cd_get_analysis_option.analysis_option2;
     l_series_id  :=  cd_get_analysis_option.series_id;

     IF (c_get_measure_short_name%ISOPEN) THEN
       CLOSE c_get_measure_short_name;
     END IF;

     OPEN c_get_measure_short_name(l_ana_option0,l_ana_option1,l_ana_option2,l_series_id);
     FETCH c_get_measure_short_name INTO l_measure_shortname;
     CLOSE c_get_measure_short_name;

     l_measure_names(l_index) := l_measure_shortname;
     l_index := l_index +1;
   END LOOP;

   l_index := l_measure_names.first;
   WHILE l_index IS NOT NULL
   LOOP
     l_measure_shortname := l_measure_names(l_index);
     BSC_BIS_KPI_CRUD_PUB.Delete_Kpi_End_To_End(
      p_Commit  => p_commit,
      p_Param_Portlet_Region_Code => 'DUMMY',
      p_Measure_Short_Name => l_measure_shortname,
      p_Page_Function_Name => NULL,
      p_Kpi_Portlet_Function_Name => NULL,
      x_Return_Status  => x_return_status ,
      x_Msg_Count => x_msg_count ,
      x_Msg_Data => x_msg_data);
      l_index := l_measure_names.next(l_index);
   END LOOP;

   IF(p_Commit = FND_API.G_TRUE) THEN
     commit;
   END IF;

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (   p_encoded   =>  FND_API.G_FALSE
           ,p_count     =>  x_msg_count
           ,p_data      =>  x_msg_data
        );
      END IF;
      x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        ( p_encoded   =>  FND_API.G_FALSE
         ,p_count     =>  x_msg_count
         ,p_data      =>  x_msg_data
         );
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
       x_msg_data      :=  x_msg_data||' -> Delete_S2E_Objective ';
     ELSE
       x_msg_data      :=  SQLERRM||' at Delete_S2E_Objective ';
     END IF;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> Delete_S2E_Objective ';
     ELSE
        x_msg_data      :=  SQLERRM||' at Delete_S2E_Objective ';
     END IF;
 END Delete_S2E_Objective;


 /*
   API to delete S2E Objective Group. This is wrapper API to delete Objective group after
   deleting all objectives under this group.
 */

 PROCEDURE Delete_S2E_ObjectiveGroup(
   p_commit              IN          VARCHAR2 := FND_API.G_FALSE
  ,p_tabId               IN      NUMBER
  ,x_return_status       OUT NOCOPY     VARCHAR2
  ,x_msg_count           OUT NOCOPY     NUMBER
  ,x_msg_data            OUT NOCOPY     VARCHAR2
 ) IS

  l_kpiGroup_id bsc_tab_ind_groups_vl.IND_GROUP_ID%TYPE;

  CURSOR c_get_kpiGroup IS
   SELECT ind_group_id FROM bsc_tab_ind_groups_vl
   WHERE tab_id = p_tabId;

 BEGIN

   IF(c_get_kpiGroup%ISOPEN) THEN
     CLOSE c_get_kpiGroup;
   END IF;

   OPEN c_get_kpiGroup;
   FETCH c_get_kpiGroup INTO l_kpiGroup_id;
   CLOSE c_get_kpiGroup;

   BSC_PMF_UI_WRAPPER.Delete_Kpi_Group(
      p_kpi_group_id => l_kpiGroup_id
    , p_tab_id => -1
    , x_return_status => x_return_status
    , x_msg_count => x_msg_count
    , x_msg_data  => x_msg_data
    );

   IF(p_Commit = FND_API.G_TRUE) THEN
     commit;
   END IF;

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (   p_encoded   =>  FND_API.G_FALSE
           ,p_count     =>  x_msg_count
           ,p_data      =>  x_msg_data
        );
      END IF;
      x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        ( p_encoded   =>  FND_API.G_FALSE
         ,p_count     =>  x_msg_count
         ,p_data      =>  x_msg_data
         );
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
       x_msg_data      :=  x_msg_data||' -> Delete_S2E_ObjectiveGroup';
     ELSE
       x_msg_data      :=  SQLERRM||' at Delete_S2E_ObjectiveGroup ';
     END IF;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> Delete_S2E_ObjectiveGroup ';
     ELSE
        x_msg_data      :=  SQLERRM||' at Delete_S2E_ObjectiveGroup ';
     END IF;
 END Delete_S2E_ObjectiveGroup;

 /*
   API to delete S2E Scorecard. This is wrapper API to delete scorecard
 */
 PROCEDURE Delete_S2E_Scorecard(
   p_commit              IN          VARCHAR2 := FND_API.G_FALSE
  ,p_tabId               IN      number
  ,x_return_status       OUT NOCOPY     varchar2
  ,x_msg_count           OUT NOCOPY     number
  ,x_msg_data            OUT NOCOPY     varchar2
 ) IS
 BEGIN
   BSC_PMF_UI_WRAPPER.Delete_Tab(
     p_tab_id => p_tabId
    , x_return_status => x_return_status
    , x_msg_count => x_msg_count
    , x_msg_data => x_msg_data
   );

   IF(p_Commit = FND_API.G_TRUE) THEN
     commit;
   END IF;

 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
       FND_MSG_PUB.Count_And_Get
        (   p_encoded   =>  FND_API.G_FALSE
           ,p_count     =>  x_msg_count
           ,p_data      =>  x_msg_data
        );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        ( p_encoded   =>  FND_API.G_FALSE
         ,p_count     =>  x_msg_count
         ,p_data      =>  x_msg_data
         );
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
       x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Delete_Tab ';
     ELSE
       x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Delete_Tab ';
     END IF;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_PMF_UI_WRAPPER.Delete_Tab ';
     ELSE
        x_msg_data      :=  SQLERRM||' at BSC_PMF_UI_WRAPPER.Delete_Tab ';
     END IF;
 END Delete_S2E_Scorecard;


 procedure Delete_S2E_Metadata(
  p_commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_tab_id              IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) IS

  l_ret_status            varchar2(10);
  l_msg_data              varchar2(2000);
  l_msg_count             number(5);

  l_indicator        bsc_tab_indicators.indicator%TYPE;


  CURSOR c_tab_indicators IS
   SELECT indicator FROM bsc_tab_indicators
   WHERE tab_id = p_tab_id;

 BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (c_tab_indicators%ISOPEN) THEN
     CLOSE c_tab_indicators;
   END IF;

   OPEN c_tab_indicators ;
   FETCH c_tab_indicators INTO l_indicator;
   CLOSE c_tab_indicators;

   Delete_S2E_Objective(
     p_commit        => FND_API.G_FALSE
    ,p_indicator     => l_indicator
    ,x_return_status => l_ret_status
    ,x_msg_count     => l_msg_count
    ,x_msg_data      => l_msg_data );

   IF (l_ret_status is not null AND l_ret_status <> FND_API.G_RET_STS_SUCCESS ) THEN
     RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   Delete_S2E_ObjectiveGroup(
     p_commit        =>  FND_API.G_FALSE
    ,p_tabId         => p_tab_id
    ,x_return_status => l_ret_status
    ,x_msg_count     => l_msg_count
    ,x_msg_data      => l_msg_data );


   IF (l_ret_status is not null AND l_ret_status <> FND_API.G_RET_STS_SUCCESS ) THEN
     RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   Delete_S2E_Scorecard(
     p_commit        => FND_API.G_FALSE
    ,p_tabId         => p_tab_id
    ,x_return_status => l_ret_status
    ,x_msg_count     => l_msg_count
    ,x_msg_data      => l_msg_data );


   IF (l_ret_status is not null AND l_ret_status <> FND_API.G_RET_STS_SUCCESS ) THEN
     RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF(p_Commit = FND_API.G_TRUE) THEN
     commit;
   END IF;

 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (   p_encoded   =>  FND_API.G_FALSE
           ,p_count     =>  x_msg_count
           ,p_data      =>  x_msg_data
        );
      END IF;
      x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        ( p_encoded   =>  FND_API.G_FALSE
         ,p_count     =>  x_msg_count
         ,p_data      =>  x_msg_data
         );
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
       x_msg_data      :=  x_msg_data||' -> Delete_S2E_Metadata ';
     ELSE
       x_msg_data      :=  SQLERRM||' at Delete_S2E_Metadata ';
     END IF;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> Delete_S2E_Metadata ';
     ELSE
        x_msg_data      :=  SQLERRM||' at Delete_S2E_Metadata ';
     END IF;
 END Delete_S2E_Metadata;

PROCEDURE Get_S2ESCR_DeleteMessage(
   p_tabId               IN      number
  ,x_return_status       OUT NOCOPY     varchar2
  ,x_msg_count           OUT NOCOPY     number
  ,x_msg_data            OUT NOCOPY     varchar2
 ) IS

 l_objective_name  BSC_KPIS_VL.NAME%TYPE;
 l_indicator BSC_KPIS_VL.INDICATOR%TYPE;
 l_cust_kpi_name  bsc_oaf_analysys_opt_comb_v.full_name%TYPE;
 l_cust_kpis  varchar2(1000) := '';

 CURSOR c_get_objective IS
  SELECT a.name,a.indicator FROM BSC_KPIS_VL a,BSC_TAB_INDICATORS b
  WHERE a.indicator = b.indicator
  AND b.tab_id = p_tabId;

 CURSOR c_get_custom_Kpis(p_indicator bsc_oaf_analysys_opt_comb_v.indicator%TYPE) IS
  SELECT a.full_name FROM bsc_oaf_analysys_opt_comb_v a
  WHERE a.indicator = p_indicator;

 BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF(c_get_objective%ISOPEN) THEN
     CLOSE c_get_objective;
   END IF;
   OPEN c_get_objective;
   FETCH c_get_objective INTO l_objective_name,l_indicator;
   CLOSE c_get_objective;

   FOR cd_get_custom_Kpis IN c_get_custom_Kpis(l_indicator) LOOP
     l_cust_kpi_name :=  cd_get_custom_Kpis.full_name;
     IF ( l_cust_kpis = '' OR l_cust_kpis IS NULL ) THEN
       l_cust_kpis := l_cust_kpi_name;
     ELSE
       l_cust_kpis := l_cust_kpis || ',' || l_cust_kpi_name;
     END IF;
   END LOOP;

   FND_MESSAGE.SET_NAME('BSC','BSC_SCR_DELETE_WARN');
   FND_MESSAGE.SET_TOKEN('OBJECTIVE', l_objective_name);
   FND_MESSAGE.SET_TOKEN('CUST_KPI_LIST',l_cust_kpis);
   FND_MSG_PUB.ADD;

   FND_MSG_PUB.Count_And_Get
   (     p_encoded   =>  FND_API.G_FALSE
     ,   p_count     =>  x_msg_count
     ,   p_data      =>  x_msg_data
   );

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
       x_msg_data      :=  x_msg_data||' -> Get_S2E_Scorecard_DeleteMessage ';
     ELSE
       x_msg_data      :=  SQLERRM||' at  ';
     END IF;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> Get_S2E_Scorecard_DeleteMessage ';
     ELSE
        x_msg_data      :=  SQLERRM||' at Get_S2E_Scorecard_DeleteMessage ';
   END IF;
 END Get_S2ESCR_DeleteMessage;


----added by visuri for Enh. 4035089
 FUNCTION Has_Compare_To_Or_Plan (p_param_portlet_region_code  IN   VARCHAR2)
 RETURN BOOLEAN IS
  l_count       NUMBER;

 BEGIN

   SELECT  COUNT(1)
   INTO    l_count
   FROM    ak_region_items AK
   WHERE   AK.region_code = p_param_portlet_region_code
   AND     ATTRIBUTE1  IN ('DIMENSION LEVEL',
               'DIM LEVEL SINGLE VALUE',
               'DIMENSION VALUE',
               'HIDE_VIEW_BY',
               'HIDE_VIEW_BY_SINGLE',
               'HIDE PARAMETER',
               'VIEWBY PARAMETER',
               'HIDE_DIM_LVL',
               'HIDE DIMENSION LEVEL',
               'HIDE VIEW BY DIMENSION',
               'HIDE_VIEW_BY_DIM_SINGLE')
   AND      AK.attribute2  LIKE '%+%'
   AND      (AK.attribute2  LIKE '%TIME_COMPARISON_TYPE%' OR  AK.attribute2  LIKE '%PLAN_SNAPSHOT%');


   IF (l_count = 0) THEN
     RETURN FALSE;
   ELSE
     RETURN TRUE;
   END IF;

 EXCEPTION
    WHEN OTHERS THEN
    RETURN TRUE;
 END Has_Compare_To_Or_Plan;


-- added for AGRD
-- Modified for Calendar Enhancement (Bug#4376162)
PROCEDURE Get_Dim_Info_From_ParamPortlet(
        p_Dimension_Info               IN         VARCHAR2
       ,x_non_time_dimension_groups    OUT NOCOPY BSC_VARCHAR2_TBL_TYPE
       ,x_non_time_dimension_objects   OUT NOCOPY BSC_VARCHAR2_TBL_TYPE
       ,x_non_time_dim_obj_short_names OUT NOCOPY VARCHAR2
       ,x_all_dim_group_ids            OUT NOCOPY BSC_NUMBER_TBL_TYPE
       ,x_non_time_counter             OUT NOCOPY NUMBER
       ,x_time_dimension_groups        OUT NOCOPY BSC_VARCHAR2_TBL_TYPE
       ,x_time_dimension_objects       OUT NOCOPY BSC_VARCHAR2_TBL_TYPE
       ,x_time_dim_obj_short_names     OUT NOCOPY VARCHAR2
       ,x_time_counter                 OUT NOCOPY NUMBER
       ,x_msg_data                     OUT NOCOPY VARCHAR2
       ,x_is_as_of_date                OUT NOCOPY VARCHAR2
) IS

  l_Dimension_Info          VARCHAR2(8000);
  l_Dim_Plus_DimObj_Info    VARCHAR2(512);
  l_Display_Sequence  NUMBER;
  l_Dimension_Grp     BSC_VARCHAR2_TBL_TYPE;
  l_Dimension_Object  BSC_VARCHAR2_TBL_TYPE;
  l_Counter           NUMBER := 1;
  l_Dimension_Grp_Id  NUMBER;
  l_Msg_Count         NUMBER;
  l_Dim_Id_Cnt        NUMBER;

  CURSOR c_DimId IS
    SELECT a.DIMENSION_ID
    FROM   BIS_DIMENSIONS A
    WHERE  UPPER(a.SHORT_NAME) = UPPER(l_Dimension_Grp(l_Counter));



BEGIN

  x_Non_Time_Dim_Obj_Short_Names := NULL;
  x_Non_Time_Counter             := 1;
  x_Time_Counter                 := 1;
  l_Dim_Id_Cnt                   := 0;
  l_Dimension_Info               := p_Dimension_Info;
  x_All_Dim_Group_Ids(1)         := NULL;
  x_All_Dim_Group_Ids(2)         := NULL;
  x_All_Dim_Group_Ids(3)         := NULL;
  x_All_Dim_Group_Ids(4)         := NULL;
  x_All_Dim_Group_Ids(5)         := NULL;
  x_All_Dim_Group_Ids(6)         := NULL;
  x_All_Dim_Group_Ids(7)         := NULL;
  x_is_as_of_date                := FND_API.G_FALSE;

  WHILE (
      is_More(  p_dim_short_names  =>  l_Dimension_Info
              , p_dim_name         =>  l_Dim_Plus_DimObj_Info
             )
  ) LOOP

    l_Dimension_Grp(l_counter)    := SUBSTR(l_Dim_Plus_DimObj_Info, 1, INSTR(l_Dim_Plus_DimObj_Info,'+') - 1);
    l_Dimension_Object(l_counter) := SUBSTR(l_Dim_Plus_DimObj_Info, INSTR(l_Dim_Plus_DimObj_Info,'+') + 1);

    IF (l_Dimension_Grp(l_counter) = C_AS_OF_DATE OR l_Dimension_Object(l_counter) = C_AS_OF_DATE) THEN
      x_is_as_of_date := FND_API.G_TRUE;
    END IF;

    IF ((l_Dimension_Grp(l_counter) <> C_TIME_COMPARISON)
            AND ( NOT((l_Dimension_Grp(l_counter) = C_AS_OF_DATE) OR (l_Dimension_Object(l_counter) = C_AS_OF_DATE)))) THEN
        IF  ((l_Dimension_Grp(l_Counter) <> BSC_BIS_KPI_CRUD_PUB.C_OLTP_TIME) AND
            (l_Dimension_Grp(l_Counter) <> BSC_BIS_KPI_CRUD_PUB.C_EDW_TIME) AND
            (BSC_BIS_KPI_CRUD_PUB.Is_Dimension_Calendar(l_Dimension_Grp(l_Counter)) <> FND_API.G_TRUE)) THEN

           x_Non_Time_Dimension_Groups(x_Non_Time_Counter)  := l_Dimension_Grp(l_Counter);
           x_Non_Time_Dimension_Objects(x_Non_Time_Counter) := l_dimension_object(l_Counter);

           -- concatenate non time dimension object short name
           IF (x_Non_Time_Dim_Obj_Short_Names IS NULL) THEN
              x_Non_Time_Dim_Obj_Short_Names := l_Dimension_Object(l_Counter);
           ELSE
              x_Non_Time_Dim_Obj_Short_Names := x_Non_Time_Dim_Obj_Short_Names || ',' || l_Dimension_Object(l_counter);
           END IF;

           x_Non_Time_Counter := x_Non_Time_Counter + 1;

        ELSE      -- for time dimension
           x_Time_Dimension_Groups(x_Time_Counter)  := l_Dimension_Grp(l_Counter);
           x_Time_Dimension_Objects(x_Time_Counter) := l_Dimension_Object(l_Counter);

           x_Time_Counter := x_time_counter + 1;

           -- concatenate time dimension object short name
           IF (x_Time_Dim_Obj_Short_Names IS NULL) THEN
              x_Time_Dim_Obj_Short_Names := l_Dimension_Object(l_Counter);
           ELSE
              x_Time_Dim_Obj_Short_Names := x_Time_Dim_Obj_Short_Names || ',' || l_Dimension_Object(l_Counter);
           END IF;
        END IF;

        FOR cDimId IN c_DimId LOOP
          l_Dimension_Grp_Id := cDimId.DIMENSION_ID;
          l_Dim_Id_Cnt := l_Dim_Id_Cnt + 1;
        END LOOP;

        IF l_Dim_Id_Cnt <> 1 THEN
          FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_SHORT_NAME');
          FND_MESSAGE.SET_TOKEN('BSC_GROUP_SHORT_NAME', l_dimension_grp(l_counter), TRUE);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_Dim_Id_Cnt := 0;

        x_All_Dim_Group_Ids(l_counter) := l_Dimension_Grp_Id;
        l_Counter := l_Counter + 1;
    END IF;
  END LOOP;

 -- decrement by one to match the actual number of elements
 x_Non_Time_Counter := x_Non_Time_Counter - 1;
 x_Time_Counter     := x_Time_Counter - 1;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

    WHEN NO_DATA_FOUND THEN
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Get_Dim_Info_From_ParamPortlet ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Get_Dim_Info_From_ParamPortlet ';
        END IF;
    WHEN OTHERS THEN
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Get_Dim_Info_From_ParamPortlet ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Get_Dim_Info_From_ParamPortlet ';
        END IF;

END Get_Dim_Info_From_ParamPortlet;

PROCEDURE Refresh_Ak_Bsc_Bis_Metadata(
      p_Commit                      IN VARCHAR2
    , p_Region_Code                 IN VARCHAR2
    , p_Region_Application_Id       IN NUMBER
    , p_Kpi_Id                      IN NUMBER
    , p_Analysis_Option_Id          IN NUMBER
    , p_Dim_Set_Id                  IN NUMBER
    , p_Dim_Obj_Short_Names         IN VARCHAR2
    , p_Force_Create_Dim            IN VARCHAR2
    , x_Return_Status               OUT NOCOPY   VARCHAR2
    , x_Msg_Count                   OUT NOCOPY   NUMBER
    , x_Msg_Data                    OUT NOCOPY   VARCHAR2
) IS
    l_Global_Menu                     VARCHAR2(150);
    l_Global_Title                    VARCHAR2(150);
BEGIN

    Get_Global_Menu_Title(
        p_Region_Code           =>  p_Region_Code
      , p_Region_Application_Id =>  p_Region_Application_Id
      , x_Global_Menu           =>  l_Global_Menu
      , x_Global_Title          =>  l_Global_Title
    );

    REFRESH_AK_BSC_BIS_METADATA(
        p_Commit                => p_Commit
      , p_Region_Code           => p_Region_Code
      , p_Region_Application_Id => p_Region_Application_Id
      , p_Kpi_Id                => p_Kpi_Id
      , p_Analysis_Option_Id    => p_Analysis_Option_Id
      , p_Dim_Set_id            => p_Dim_Set_Id
      , p_Global_Menu           => l_Global_Menu
      , p_Global_Title          => l_Global_Title
      , p_Dim_Obj_Short_Names   => p_Dim_Obj_Short_Names
      , p_Force_Create_Dim      => p_Force_Create_Dim
      , x_Return_Status         => x_Return_Status
      , x_Msg_Count             => x_Msg_Count
      , x_Msg_Data              => x_Msg_Data
    );
    --SAVEPOINT RefreshAkBscBisMeta;



EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

       IF (x_msg_data IS NULL) THEN
           FND_MSG_PUB.Count_And_Get
           (      p_encoded   =>  FND_API.G_FALSE
              ,   p_count     =>  x_msg_count
              ,   p_data      =>  x_msg_data
           );
       END IF;
       x_Return_Status :=  FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       IF (x_msg_data IS NULL) THEN
           FND_MSG_PUB.Count_And_Get
           (      p_encoded   =>  FND_API.G_FALSE
              ,   p_count     =>  x_msg_count
              ,   p_data      =>  x_msg_data
           );
       END IF;
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN NO_DATA_FOUND THEN

       IF (x_msg_data IS NOT NULL) THEN
           x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Refresh_Ak_Bsc_Bis_Metadata ';
       ELSE
           x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Refresh_Ak_Bsc_Bis_Metadata ';
       END IF;
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN

       IF (x_msg_data IS NOT NULL) THEN
           x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Refresh_Ak_Bsc_Bis_Metadata ';
       ELSE
           x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Refresh_Ak_Bsc_Bis_Metadata ';
       END IF;
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END Refresh_Ak_Bsc_Bis_Metadata;

PROCEDURE Refresh_Ak_Bsc_Bis_Metadata(
      p_Commit                      IN VARCHAR2
    , p_Region_Code                 IN VARCHAR2
    , p_Region_Application_Id       IN NUMBER
    , p_Kpi_Id                      IN NUMBER
    , p_Analysis_Option_Id          IN NUMBER
    , p_Dim_Set_Id                  IN NUMBER
    , p_Global_Menu                 IN VARCHAR2
    , p_Global_Title                IN VARCHAR2
    , p_Dim_Obj_Short_Names         IN VARCHAR2
    , p_Force_Create_Dim            IN VARCHAR2
    , x_Return_Status               OUT NOCOPY   VARCHAR2
    , x_Msg_Count                   OUT NOCOPY   NUMBER
    , x_Msg_Data                    OUT NOCOPY   VARCHAR2
) IS
    l_report_region_rec               BIS_AK_REGION_PUB.Bis_Region_Rec_Type;
    x_Non_Time_Dimension_Groups       BSC_VARCHAR2_TBL_TYPE;
    x_Non_Time_Dimension_Objects      BSC_VARCHAR2_TBL_TYPE;
    x_Non_Time_Dim_Obj_Short_Names    VARCHAR2(2056);
    x_Time_Dimension_Groups           BSC_VARCHAR2_TBL_TYPE;
    x_Time_Dimension_Objects          BSC_VARCHAR2_TBL_TYPE;
    x_Time_Dim_Obj_Short_Names        VARCHAR2(2056);
    x_All_Dim_Group_Ids               BSC_NUMBER_TBL_TYPE;
    x_Non_Time_Counter                NUMBER;
    x_Time_Counter                    NUMBER;
    l_Measure_Short_Names             VARCHAR2(4096);

    l_Region_Name                     Ak_Regions_Tl.NAME%TYPE;
    l_Region_Description              Ak_Regions_Tl.DESCRIPTION%TYPE;
    l_Region_Created_By               Ak_Regions_Tl.CREATED_BY%TYPE;
    l_Region_Creation_Date            Ak_Regions_Tl.CREATION_DATE%TYPE;
    l_Region_Last_Updated_By          Ak_Regions_Tl.LAST_UPDATED_BY%TYPE;
    l_Region_Last_Update_Date         Ak_Regions_Tl.LAST_UPDATE_DATE%TYPE;
    l_Region_Last_Update_Login        Ak_Regions_Tl.LAST_UPDATE_LOGIN%TYPE;
    l_Is_XTD_Enabled                  VARCHAR2(1);

BEGIN
    SAVEPOINT RefreshAkBscBisMeta;

    FND_MSG_PUB.Initialize;
    x_Return_Status                := FND_API.G_RET_STS_SUCCESS;

   -- 1) Cascaded back to AK Metadata (AK_REGIONS, AK_REGION_ITEMS, FND_FORM_FUNCTIONS_VL
    l_report_region_rec.Region_Code            := p_Region_Code;
    l_report_region_rec.Region_Name            := BIS_COMMON_UTILS.G_DEF_CHAR;
    l_report_region_rec.Region_Description     := BIS_COMMON_UTILS.G_DEF_CHAR;
    l_report_region_rec.Region_Application_Id  := p_Region_Application_Id;
    l_report_region_rec.Database_Object_Name   := 'ICX_PROMPTS';
    l_report_region_rec.Region_Style           := BIS_COMMON_UTILS.G_DEF_CHAR;
    l_report_region_rec.Region_Object_Type     := NULL;
    l_report_region_rec.Help_Target            := NULL;
    l_report_region_rec.Display_Rows           := BIS_COMMON_UTILS.G_DEF_NUM;
    l_report_region_rec.Disable_View_By        := BIS_COMMON_UTILS.G_DEF_CHAR;
    l_report_region_rec.No_Of_Portlet_Rows     := NULL;
    l_report_region_rec.Schedule               := NULL;
    l_report_region_rec.Header_File_Procedure  := NULL;
    l_report_region_rec.Footer_File_Procedure  := NULL;
    l_report_region_rec.Group_By               := NULL;
    l_report_region_rec.Order_By               := NULL;
    l_report_region_rec.Plsql_For_Report_Query := p_Kpi_Id||'.'||p_Analysis_Option_Id;
    l_report_region_rec.Display_Subtotals      := NULL;
    l_report_region_rec.Data_Source            := BSC_BIS_KPI_CRUD_PUB.C_BSC_SOURCE;
    l_report_region_rec.Where_Clause           := NULL;
    l_report_region_rec.Dimension_Group        := NULL;
    l_report_region_rec.Parameter_Layout       := NULL;
    l_report_region_rec.Kpi_Id                 := p_Kpi_Id;
    l_report_region_rec.Analysis_Option_Id     := p_Analysis_Option_Id;
    l_report_region_rec.Dim_Set_Id             := p_Dim_Set_Id;
    l_report_region_rec.Global_Menu            := p_Global_Menu;
    l_report_region_rec.Global_Title           := p_Global_Title;

    BIS_PMV_REGION_PVT.UPDATE_REGION
    (
        p_commit                 => p_Commit
       ,p_Report_Region_Rec      => l_report_region_rec
       ,x_return_status          => x_return_status
       ,x_msg_count              => x_msg_count
       ,x_msg_data               => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


   -- 2) Sequence the Data Series

   -- awaiting PL/SQL from William.

   -- 3) Refresh Dimension Metadata
   IF (p_Force_Create_Dim = FND_API.G_TRUE) THEN

      x_Non_Time_Dim_Obj_Short_Names := NULL;

      IF (p_Dim_Obj_Short_Names IS NOT NULL) THEN
          BSC_BIS_KPI_CRUD_PUB.Get_Dim_Info_From_ParamPortlet(
              p_Dimension_Info               => p_Dim_Obj_Short_Names
             ,x_non_time_dimension_groups    => x_Non_Time_Dimension_Groups
             ,x_non_time_dimension_objects   => x_Non_Time_Dimension_Objects
             ,x_non_time_dim_obj_short_names => x_Non_Time_Dim_Obj_Short_Names
             ,x_all_dim_group_ids            => x_All_Dim_Group_Ids
             ,x_non_time_counter             => x_Non_Time_Counter
             ,x_time_dimension_groups        => x_Time_Dimension_Groups
             ,x_time_dimension_objects       => x_Time_Dimension_Objects
             ,x_time_dim_obj_short_names     => x_Time_Dim_Obj_Short_Names
             ,x_time_counter                 => x_Time_Counter
             ,x_msg_data                     => x_Msg_Data
             ,x_is_as_of_date                => l_Is_XTD_Enabled
          );

          -- code to recreate Periodicities goes here.

          IF (Has_Time_Dim_Obj_Changed(x_Time_Dim_Obj_Short_Names, p_Kpi_Id, l_Is_XTD_Enabled) = FND_API.G_TRUE) THEN
              BSC_BIS_KPI_CRUD_PUB.Assign_KPI_Periodicities(
                    p_Commit            => p_Commit
                   ,p_Kpi_Id            => p_Kpi_Id
                   ,p_Time_Dim_Obj_Sns  => x_Time_Dim_Obj_Short_Names
                   ,p_Dft_Dim_Obj_Sn    => NULL
                   ,p_Daily_Flag        => l_Is_XTD_Enabled
                   ,p_Is_XTD_Enabled    => l_Is_XTD_Enabled
                   ,x_Return_Status     => x_Return_Status
                   ,x_Msg_Count         => x_Msg_Count
                   ,x_Msg_Data          => x_Msg_Data
              );
              IF (x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
                  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
          END IF;
      END IF;

      IF (Has_Non_Time_Dim_Obj_Changed(x_Non_Time_Dim_Obj_Short_Names, p_Kpi_Id)= FND_API.G_TRUE) THEN
          BSC_BIS_DIMENSION_PUB.Update_Dimension
          (       p_commit                => p_Commit
              ,   p_dim_short_name        => p_Region_Code
              ,   p_display_name          => p_Region_Code
              ,   p_description           => p_Region_Code
              ,   p_application_id        => p_Region_Application_Id
              ,   p_dim_obj_short_names   => x_Non_Time_Dim_Obj_Short_Names
              ,   p_time_stamp            => NULL
              ,   p_hide                  => FND_API.G_TRUE
              ,   x_return_status         => x_Return_Status
              ,   x_msg_count             => x_Msg_Count
              ,   x_msg_data              => x_Msg_Data
          );
          IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          -- added for Bug#4923006
          IF (Is_Dim_Associated_To_Objective (p_Region_Code, p_Kpi_Id) = FND_API.G_FALSE) THEN
            BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set(
                  p_Commit             => p_Commit
                 ,p_Kpi_Id             => p_Kpi_Id
                 ,p_Dim_Set_Id         => 0
                 ,p_Dim_Short_Names    => p_Region_Code
                 ,p_Time_Stamp         => NULL
                 ,x_Return_Status      => x_Return_Status
                 ,x_Msg_Count          => x_Msg_Count
                 ,x_Msg_Data           => x_Msg_Data
            );
            IF (x_Return_Status  <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;
      END IF;
   END IF;


   -- reorder the Measure at the series level (Including delete/add)
   l_Measure_Short_Names := BSC_BIS_KPI_CRUD_PUB.Get_DS_Sequence_From_AK(p_Region_Code, p_Kpi_Id);

   IF (Has_Measure_Column_Changed(l_Measure_Short_Names, p_Kpi_Id) = FND_API.G_TRUE) THEN
       BSC_ANALYSIS_OPTION_PUB.Rearrange_Data_Series(
          p_commit            => FND_API.G_FALSE
         ,p_Kpi_Id            => p_Kpi_Id
         ,p_option_group0     => 0
         ,p_option_group1     => 0
         ,p_option_group2     => 0
         ,p_Measure_Seq       => l_Measure_Short_Names
         ,p_add_flag          => FND_API.G_TRUE
         ,p_remove_flag       => FND_API.G_TRUE
         ,x_return_status     => x_return_status
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
      );
      IF ((x_Return_Status IS NOT NULL) AND (x_Return_Status <> FND_API.G_RET_STS_SUCCESS)) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END IF;

  -- Update the Objective Name to correspond with the AK Region Code
  -- Modification for Bug#4448994

  BIS_AK_REGION_PUB.Get_Region_Code_TL_Data (
      p_Region_Code              => p_Region_Code
    , p_Region_Application_Id    => p_Region_Application_Id
    , x_Region_Name              => l_Region_Name
    , x_Region_Description       => l_Region_Description
    , x_Region_Created_By        => l_Region_Created_By
    , x_Region_Creation_Date     => l_Region_Creation_Date
    , x_Region_Last_Updated_By   => l_Region_Last_Updated_By
    , x_Region_Last_Update_Date  => l_Region_Last_Update_Date
    , x_Region_Last_Update_Login => l_Region_Last_Update_Login
    , x_return_status            => x_return_status
    , x_msg_count                => x_msg_count
    , x_msg_data                 => x_msg_data
  );
  IF ((x_Return_Status IS NOT NULL) AND (x_Return_Status <> FND_API.G_RET_STS_SUCCESS)) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- We have BSC_KPIS_TL.HELP is VARCHAR2(150);
  l_Region_Description := SUBSTR(l_Region_Description, 1, 150);

  BSC_PMF_UI_WRAPPER.Update_Kpi(
    p_Commit         => p_Commit
   ,p_Kpi_Id         => p_Kpi_Id
   ,x_Return_Status  => x_return_status
   ,x_Msg_Count      => x_msg_count
   ,x_Msg_Data       => x_msg_data
   ,p_Kpi_Name       => l_Region_Name
   ,p_Kpi_Help       => l_Region_Description
 );
 IF ((x_Return_Status IS NOT NULL) AND (x_Return_Status <> FND_API.G_RET_STS_SUCCESS)) THEN
   RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO RefreshAkBscBisMeta;

       IF (x_msg_data IS NULL) THEN
           FND_MSG_PUB.Count_And_Get
           (      p_encoded   =>  FND_API.G_FALSE
              ,   p_count     =>  x_msg_count
              ,   p_data      =>  x_msg_data
           );
       END IF;
       x_Return_Status :=  FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO RefreshAkBscBisMeta;

       IF (x_msg_data IS NULL) THEN
           FND_MSG_PUB.Count_And_Get
           (      p_encoded   =>  FND_API.G_FALSE
              ,   p_count     =>  x_msg_count
              ,   p_data      =>  x_msg_data
           );
       END IF;
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN NO_DATA_FOUND THEN
       ROLLBACK TO RefreshAkBscBisMeta;

       IF (x_msg_data IS NOT NULL) THEN
           x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Refresh_Ak_Bsc_Bis_Metadata ';
       ELSE
           x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Refresh_Ak_Bsc_Bis_Metadata ';
       END IF;
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
       ROLLBACK TO RefreshAkBscBisMeta;

       IF (x_msg_data IS NOT NULL) THEN
           x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Refresh_Ak_Bsc_Bis_Metadata ';
       ELSE
           x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Refresh_Ak_Bsc_Bis_Metadata ';
       END IF;
       x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END Refresh_Ak_Bsc_Bis_Metadata;


-- Gets the short_names of the AUTOGENERATED measures in the AK_REGION SPECIFICED.

FUNCTION Get_DS_Sequence_From_AK (
      p_Region_Code     IN VARCHAR2
    , p_Kpi_Id          IN VARCHAR2
) RETURN VARCHAR2 IS
  CURSOR cMeasureShortNames IS
    SELECT ATTRIBUTE2
    FROM   AK_REGION_ITEMS
    WHERE  REGION_CODE = p_Region_Code
    AND    ATTRIBUTE1 IN ('BUCKET_MEASURE', 'MEASURE', 'MEASURE_NOTARGET', 'SUB MEASURE')
    ORDER BY DISPLAY_SEQUENCE;

  l_Measure_Short_Names VARCHAR2(4096);
  l_Measure_Short_Name  BIS_INDICATORS.SHORT_NAME%TYPE;
  l_Kpi_Id              NUMBER;
  l_Dataset_Id          NUMBER;
  l_Count               NUMBER;
BEGIN
  l_Measure_Short_Name := NULL;
  l_Count              := 0;

  FOR cMSN IN cMeasureShortNames LOOP
    l_Measure_Short_Name := cMSN.ATTRIBUTE2;

    l_Kpi_Id := BSC_BIS_KPI_CRUD_PUB.Get_Objective_By_AGKpi(l_Measure_Short_Name);

    IF(p_Kpi_Id = l_Kpi_Id) THEN
       IF (l_Measure_Short_Names IS NULL) THEN
         l_Measure_Short_Names := l_Measure_Short_Name;
       ELSE
         l_Measure_Short_Names := l_Measure_Short_Names  || ',' || l_Measure_Short_Name;
       END IF;
    ELSE
       l_Dataset_Id := BSC_BIS_KPI_CRUD_PUB.Get_Dataset_Id(l_Measure_Short_Name);

       SELECT COUNT(1) INTO l_Count
       FROM   BSC_KPI_ANALYSIS_MEASURES_B B
       WHERE  B.DATASET_ID = l_Dataset_Id
       AND    B.INDICATOR  = p_Kpi_Id;

       -- the dataset already belongs to the current indicator data series.
       IF (l_Count <> 0) THEN
          IF (l_Measure_Short_Names IS NULL) THEN
            l_Measure_Short_Names := l_Measure_Short_Name;
          ELSE
            l_Measure_Short_Names := l_Measure_Short_Names  || ',' || l_Measure_Short_Name;
          END IF;
       END IF;
    END IF;
  END LOOP;

  RETURN l_Measure_Short_Names;
EXCEPTION
  WHEN OTHERS THEN
     RETURN NULL;
END Get_DS_Sequence_From_AK;


-- The following Utility API gets the
-- This API should not be used for Muliple Analysis Options, since only default AO is used.

FUNCTION Get_Data_Series_Id(
     p_Kpi_Id     IN NUMBER
   , p_Dataset_Id IN NUMBER
) RETURN NUMBER IS

   l_Data_Series_Id NUMBER;
BEGIN

   SELECT A.SERIES_ID
   INTO   l_Data_Series_Id
   FROM   BSC_KPI_ANALYSIS_MEASURES_B A
   WHERE  A.INDICATOR        = p_Kpi_Id
   AND    A.ANALYSIS_OPTION0 = 0
   AND    A.ANALYSIS_OPTION1 = 0
   AND    A.ANALYSIS_OPTION2 = 0
   AND    A.DATASET_ID       = p_Dataset_Id;

   RETURN l_Data_Series_Id;

EXCEPTION
  WHEN OTHERS THEN
     RETURN BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY;
END Get_Data_Series_Id;


 PROCEDURE Get_Dep_Obj_Func_Name( p_dep_object_name               IN      VARCHAR2
                  ,p_dep_object_type              IN      VARCHAR2
                  ,p_object_type                  IN      VARCHAR2
                  ,x_ret_status                   OUT     NOCOPY  VARCHAR2
                      ,x_mesg_data                    OUT     NOCOPY  VARCHAR2
                ) IS

 parent_object_table bis_rsg_pub_api_pkg.t_BIA_RSG_Obj_Table;
 l_Index_Count NUMBER;
 result VARCHAR2(1000);
 object_name VARCHAR2(100);

 BEGIN
    parent_object_table :=  bis_rsg_pub_api_pkg.GetParentObjects
                (
                  p_dep_obj_name  => p_dep_object_name
                 ,p_dep_obj_type  => p_dep_object_type
                 ,p_obj_type      => p_object_type
                 ,x_return_status => x_ret_status
                 ,x_msg_data      => x_mesg_data
                );

    l_Index_Count := 0;
    result := '';

    IF (parent_object_table.COUNT > 0) THEN
       l_Index_Count := parent_object_table.FIRST;
       LOOP
            object_name := parent_object_table(l_Index_Count).object_name;
            result := result || object_name || ',';
            EXIT WHEN l_Index_Count = parent_object_table.LAST;
            l_Index_Count := parent_object_table.NEXT(l_Index_Count);
       END LOOP;
    END IF;
    x_mesg_data := result;


END Get_Dep_Obj_Func_Name;


-- Gets BSC_KPIS_VL.INDICATOR using BIS_INDICATORS.SHORT_NAME
-- Used in UI

FUNCTION Get_Objective_By_AGKpi(
            p_Short_Name   IN VARCHAR2
) RETURN VARCHAR2
IS
  l_Count  NUMBER;
  l_Kpi_Id VARCHAR2(10);
BEGIN
  l_Count := 0;

  SELECT
    COUNT(1)
  INTO
    l_Count
  FROM
    bsc_sys_measures m,
    bsc_sys_datasets_vl d,
    bis_indicators i
  WHERE
    i.dataset_id  = d.dataset_id AND
    d.measure_id1 = m.measure_id AND
    i.short_name  = p_Short_Name AND
    m.source = BSC_BIS_MEASURE_PUB.c_BSC;

  -- Measure Does not exist or not a BSC Measure
  IF l_Count = 0 THEN
    RETURN BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY;
  END IF;

  SELECT DISTINCT INDICATOR
  INTO   l_Kpi_Id
  FROM   BSC_KPIS_B
  WHERE  SHORT_NAME = (SELECT SUBSTR(ACTUAL_DATA_SOURCE, 1, INSTR(ACTUAL_DATA_SOURCE, '.') - 1) REGION_CODE
                       FROM   BIS_INDICATORS
                       WHERE SHORT_NAME = p_Short_Name);

  RETURN l_Kpi_Id;

EXCEPTION
  WHEN OTHERS THEN
     RETURN BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY;

END Get_Objective_By_AGKpi;


--IF AG Report is NOT in Production Mode
PROCEDURE Convert_AutoGen_To_ViewBased (
      p_Commit                 IN VARCHAR2 := FND_API.G_FALSE
    , p_Region_Code            IN VARCHAR2
    , p_Region_Application_Id  IN NUMBER
    , x_Return_Status          OUT NOCOPY VARCHAR
    , x_Msg_Count              OUT NOCOPY NUMBER
    , x_Msg_Data               OUT NOCOPY VARCHAR
) IS
     l_Kpi_Id             NUMBER;
     l_Kpi_Group_Id       NUMBER;
     l_Tab_Id             NUMBER;
     l_Measure_Id         NUMBER;
     l_Measure_Group_Id   NUMBER;
     l_Count              NUMBER;
     l_Measure_List       BSC_VARCHAR2_TBL_TYPE;
     l_Measure_Col        BSC_SYS_MEASURES.MEASURE_COL%TYPE;
     l_Delete_Measure     VARCHAR2(1);
     l_Delete_Dimensions  VARCHAR2(1);

     l_report_region_rec               BIS_AK_REGION_PUB.Bis_Region_Rec_Type;


     CURSOR c_Measure_Short_Names IS
       SELECT I.SHORT_NAME
       FROM   BIS_INDICATORS               I,
              BSC_KPI_ANALYSIS_MEASURES_VL A
       WHERE  A.INDICATOR  = l_Kpi_Id
       AND    I.DATASET_ID = A.DATASET_ID;

  BEGIN
     SAVEPOINT MigAGRVBR;
     x_return_status :=  FND_API.G_RET_STS_SUCCESS;

     l_Kpi_Id := BSC_BIS_KPI_CRUD_PUB.Get_Kpi_Id(p_Region_Code);

     IF (l_Kpi_Id = BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY) THEN
       FND_MESSAGE.SET_NAME('BSC','BSC_SETUP_REPORT_DEF');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     l_Count := 0;
     FOR cMSN IN c_Measure_Short_Names LOOP
       l_Measure_List(l_Count) := cMSN.SHORT_NAME;
       l_Count                 := l_Count + 1;
       --DBMS_OUTPUT.PUT_LINE('l_Measure_List(' || l_Count || ') - ' || cMSN.SHORT_NAME);
     END LOOP;

     l_Delete_Measure    := FND_API.G_FALSE;
     l_Delete_Dimensions := FND_API.G_FALSE;

     BSC_BIS_KPI_CRUD_PUB.Delete_AG_Bsc_Metadata (
        p_Commit            => p_Commit
      , p_Region_Code       => p_Region_Code
      , p_Delete_Measures   => l_Delete_Measure
      , p_Delete_Dimensions => l_Delete_Dimensions
      , x_Return_Status     => x_Return_Status
      , x_Msg_Count         => x_Msg_Count
      , x_Msg_Data          => x_Msg_Data
     );

     IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     /*

     o PHASE 2 - Delete/Convert Measure to PMF type
     + Update BSC_SYS_DATASETS_B.SOURCE and BSC_SYS_MEASURES.SOURCE to "PMF"
       For each l_Measure_List, update BSC_SYS_MEASURES.SOURCE and BSC_SYS_DATASETS_B.SOURCE
       to PMF.
     + Delete entries in BSC_DB_MEASURE_COLS_TL and BSC_DB_MEASURE_GROUPS_TL
       for the Measure Column (Identified by BSC_SYS_MEASURES.MEASURE_COL)
       For each l_Measure_List, with its BSC_SYS_DATASETS_B.MEASURE_ID1 maps to BSC_SYS_MEASURES.MEASURE_ID.
       We need to call the following APIs ..

     Measure_Group_Id can be found out by querying BSC_DB_MEASURE_GROUPS_TL.SHORT_NAME
     with the passed REGION_CODE

     BSC_DB_MEASURE_GROUPS_PKG.DELETE_ROW(L_Measure_Group_Id)

     + Retain BIS_INDICATORS.ACTUAL_DATA_SOURCE_TYPE to "AK"
     + Retain BIS_INDICATORS.FUNCTION_NAME to the current function - no changes
     + Manipulate BIS_INDICATORS.ACTUAL_DATA_SOURCE - Open Issue

     */
     --DBMS_OUTPUT.PUT_LINE('Coming to ... BSC_BIS_KPI_CRUD_PUB.Switch_Measure_Type');

     IF (l_Delete_Measure = FND_API.G_FALSE) THEN
        FOR iCount IN 0..l_Measure_List.LAST LOOP
           --DBMS_OUTPUT.PUT_LINE('loop ... BSC_BIS_KPI_CRUD_PUB.Switch_Measure_Type ... ' || l_Measure_List(iCount));
            BSC_BIS_KPI_CRUD_PUB.Switch_Measure_Type (
                  p_Commit                     => p_Commit
                , p_Measure_Short_Name         => l_Measure_List(iCount)
                , p_Target_Source              => BSC_BIS_MEASURE_PUB.c_PMF
                , p_Delete_Columns             => FND_API.G_FALSE
                , p_Clean_Measure_Date_Source  => FND_API.G_TRUE
                , x_Return_Status              => x_Return_Status
                , x_Msg_Count                  => x_Msg_Count
                , x_Msg_Data                   => x_Msg_Data
            );
            --DBMS_OUTPUT.PUT_LINE(' loop ... x_Return_Status ' || x_Return_Status);
            --DBMS_OUTPUT.PUT_LINE(' loop ... x_Msg_Data ' || x_Msg_Data);
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END LOOP;
     END IF;

     /*
       Currently for AG and S2E based reports, we use the ACTUAL_DATA_SOURCE
       to be of the form REGION_CODE.ATRRIBUTE_CODE, In AG Reports we use it
       as <REGION_CODE>.<MEASURE_SHORT_NAME>.
     */
    l_report_region_rec.Region_Code            := p_Region_Code;
    l_report_region_rec.Region_Name            := BIS_COMMON_UTILS.G_DEF_CHAR;
    l_report_region_rec.Region_Description     := BIS_COMMON_UTILS.G_DEF_CHAR;
    l_report_region_rec.Region_Application_Id  := p_Region_Application_Id;
    l_report_region_rec.Database_Object_Name   := 'ICX_PROMPTS';
    l_report_region_rec.Region_Style           := BIS_COMMON_UTILS.G_DEF_CHAR;
    l_report_region_rec.Region_Object_Type     := NULL;
    l_report_region_rec.Help_Target            := NULL;
    l_report_region_rec.Display_Rows           := NULL;
    l_report_region_rec.Disable_View_By        := BIS_COMMON_UTILS.G_DEF_CHAR;
    l_report_region_rec.No_Of_Portlet_Rows     := NULL;
    l_report_region_rec.Schedule               := NULL;
    l_report_region_rec.Header_File_Procedure  := NULL;
    l_report_region_rec.Footer_File_Procedure  := NULL;
    l_report_region_rec.Group_By               := NULL;
    l_report_region_rec.Order_By               := NULL;
    l_report_region_rec.Plsql_For_Report_Query := ' ';
    l_report_region_rec.Display_Subtotals      := NULL;
    l_report_region_rec.Data_Source            := ' ';
    l_report_region_rec.Where_Clause           := NULL;
    l_report_region_rec.Dimension_Group        := NULL;
    l_report_region_rec.Parameter_Layout       := NULL;
    l_report_region_rec.Kpi_Id                 := NULL;
    l_report_region_rec.Analysis_Option_Id     := NULL;
    l_report_region_rec.Dim_Set_Id             := NULL;

    BIS_PMV_REGION_PVT.UPDATE_REGION
    (
        p_commit                 => p_Commit
       ,p_Report_Region_Rec      => l_report_region_rec
       ,x_return_status          => x_return_status
       ,x_msg_count              => x_msg_count
       ,x_msg_data               => x_msg_data
    );

    --DBMS_OUTPUT.PUT_LINE(' AK ... x_Return_Status ' || x_Return_Status);
    --DBMS_OUTPUT.PUT_LINE(' AK ... x_Msg_Data ' || x_Msg_Data);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        ROLLBACK TO MigAGRVBR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO MigAGRVBR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Convert_AutoGen_To_ViewBased ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Convert_AutoGen_To_ViewBased ';
        END IF;
        ROLLBACK TO MigAGRVBR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Convert_AutoGen_To_ViewBased ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Convert_AutoGen_To_ViewBased ';
        END IF;
        ROLLBACK TO MigAGRVBR;

END Convert_AutoGen_To_ViewBased;


-- Delete's all the BSC metadata associated with Report designer, with Measure optionally
PROCEDURE Delete_AG_Bsc_Metadata (
      p_Commit                   IN VARCHAR2 := FND_API.G_FALSE
    , p_Region_Code              IN VARCHAR2
    , p_Delete_Measures          IN VARCHAR2
    , p_Delete_Dimensions        IN VARCHAR2
    , x_Return_Status    OUT NOCOPY VARCHAR
    , x_Msg_Count        OUT NOCOPY NUMBER
    , x_Msg_Data         OUT NOCOPY VARCHAR
) IS
     l_Kpi_Id             NUMBER;
     l_Kpi_Group_Id       NUMBER;
     l_Tab_Id             NUMBER;
     l_Measure_Id         NUMBER;
     l_Measure_Group_Id   NUMBER;
     l_Count              NUMBER;
     l_Measure_List       BSC_VARCHAR2_TBL_TYPE;
     l_Measure_Col        BSC_SYS_MEASURES.MEASURE_COL%TYPE;
     l_Dataset_Id         NUMBER;
     iCount               NUMBER;
     l_Delete_Dimension   VARCHAR2(1);

     CURSOR c_Measure_Short_Names IS
       SELECT I.SHORT_NAME
       FROM   BIS_INDICATORS               I,
              BSC_KPI_ANALYSIS_MEASURES_VL A
       WHERE  A.INDICATOR  = l_Kpi_Id
       AND    I.DATASET_ID = A.DATASET_ID;

BEGIN

     SAVEPOINT DelAGRBscMD;
     x_return_status :=  FND_API.G_RET_STS_SUCCESS;


     -- Deleting of the Dimension has been disabled since, it will from now on have the
     -- where clase and during conversion from AG to PLSQL we need to retain the whereclase,
     l_Delete_Dimension := FND_API.G_FALSE;

     l_Kpi_Id := BSC_BIS_KPI_CRUD_PUB.Get_Kpi_Id(p_Region_Code);

     IF (l_Kpi_Id = BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY) THEN
       FND_MESSAGE.SET_NAME('BSC','BSC_SETUP_REPORT_DEF');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     l_Count := 0;
     FOR cMSN IN c_Measure_Short_Names LOOP
       l_Measure_List(l_Count) := cMSN.SHORT_NAME;
       l_Count                 := l_Count + 1;

       --DBMS_OUTPUT.PUT_LINE('l_Measure_List(' || l_Count || ') - ' || cMSN.SHORT_NAME);
     END LOOP;


     l_Tab_Id       := BSC_BIS_KPI_CRUD_PUB.Get_Tab_Id(p_Region_Code);
     l_kpi_Group_Id := BSC_BIS_KPI_CRUD_PUB.Get_Group_Id(p_Region_Code);

     --DBMS_OUTPUT.PUT_LINE(' l_Tab_Id       - ' || l_Tab_Id);
     --DBMS_OUTPUT.PUT_LINE(' l_kpi_Group_Id - ' || l_kpi_Group_Id);

     /*
     o PHASE 1 - Delete Base BSC Metadata

     1) The Kpi_Id, Kpi_Group_Id and Tab_Id should be obtained from the Region_Code level
     2) The list of Measures associated to the Objective must be noted down (Comma separated SHORT_NAME)
        and store it in l_Measure_List
     3) The Dimension Short_Name is the REGION_CODE.

     + Disassociate the 2 AG Measures associated to the Objective  -
       from Data Series (BSC_KPI_ANALSYSIS_MEASURES_B) (we dont want
       to delete the measure, but convert it rather)

     + Delete the Objective created for the Report (Deletes all
       Objecitve Metadata including Dataseries, Analysis Options,
       Objective-Dimension assiciation, Periodicities at the Objective
       Level). All BSC_KPI% tables are cleaned up.

      */


      BSC_PMF_UI_WRAPPER.Delete_Kpi(
           p_commit          =>  p_commit
          ,p_Kpi_Id          =>  l_Kpi_Id
          ,x_Return_Status   =>  x_Return_Status
          ,x_Msg_Count       =>  x_Msg_Count
          ,x_Msg_Data        =>  x_Msg_Data
      );
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

       /*****************************************88
         For Simulation Tree Enhancement we will not have the tab_id and
         kpi group created for the objective.. so corresponding tab_id and kpi
         group id will not be there for region code.so we need to check for null
         condition here.

      /*****************************************/

     /*
     + Delete the Objective Group created for the AG Report
     */
   IF(l_Tab_Id <> BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY AND l_kpi_Group_Id <> BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY) THEN

      BSC_PMF_UI_WRAPPER.Delete_Kpi_Group(
         p_commit        => p_Commit
        ,p_kpi_group_id  => l_kpi_Group_Id
        ,p_tab_id        => l_Tab_Id
        ,x_return_status => x_Return_Status
        ,x_msg_count     => x_Msg_Count
        ,x_msg_data      => x_Msg_Data
      );
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Delete the -1 entry as well.
      BSC_PMF_UI_WRAPPER.Delete_Kpi_Group(
         p_commit        => p_Commit
        ,p_kpi_group_id  => l_kpi_Group_Id
        ,p_tab_id        => -1
        ,x_return_status => x_Return_Status
        ,x_msg_count     => x_Msg_Count
        ,x_msg_data      => x_Msg_Data
      );
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     /*
     + Delete the Scorecard Created for the AG Report
     */

      BSC_PMF_UI_WRAPPER.Delete_Tab(
          p_commit         => p_Commit
        , p_tab_id         => l_Tab_Id
        , x_Return_Status  => x_Return_Status
        , x_Msg_Count      => x_Msg_Count
        , x_Msg_Data       => x_Msg_Data
      );
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

     /*
     + Delete the Dimension created for the AG Report.
     */

     -- This Dimension should not be deleted since it is currently being used
     -- for the 'where clauses'

      -- Added for Bug#5081180 to ensure Delete_Dimension API is not called when
      -- the Dimension does not exist.

      SELECT COUNT(1) INTO l_Count
      FROM   BSC_SYS_DIM_GROUPS_VL G
      WHERE  G.SHORT_NAME = p_Region_Code;

      IF ((p_Delete_Dimensions = FND_API.G_TRUE) AND (l_Count <> 0)) THEN
          BSC_BIS_DIMENSION_PUB.Delete_Dimension
          (       p_commit          => p_Commit
              ,   p_dim_short_name  => p_Region_Code
              ,   x_return_status   => x_Return_Status
              ,   x_msg_count       => x_Msg_Count
              ,   x_msg_data        => x_Msg_Data
          );
          IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END IF;

      -- Delete completely all measures associated to the report.
      /*
         This feature is best *not* used under any circumstances, except
         when a complete cleanup is required at the backend layer
       */

      IF (p_Delete_Measures = FND_API.G_TRUE) THEN
          --DBMS_OUTPUT.PUT_LINE(' Step 1');
          --DBMS_OUTPUT.PUT_LINE(' l_Measure_List.COUNT - ' || l_Measure_List.COUNT);
          --DBMS_OUTPUT.PUT_LINE(' l_Measure_List.LAST - ' || l_Measure_List.LAST);

          FOR iCount IN 0..l_Measure_List.LAST LOOP

            l_Dataset_Id := BSC_BIS_KPI_CRUD_PUB.Get_Dataset_Id(l_Measure_List(iCount));

            --DBMS_OUTPUT.PUT_LINE(' l_Dataset_Id           - ' || l_Dataset_Id);
            --DBMS_OUTPUT.PUT_LINE(' l_Measure_List(iCount) - ' || l_Measure_List(iCount));



            BSC_BIS_MEASURE_PUB.Delete_Measure(
               p_Commit         => p_commit
              ,p_Dataset_Id     => l_Dataset_Id
              ,x_return_status  => x_return_status
              ,x_msg_count      => x_msg_count
              ,x_msg_data       => x_msg_data
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END LOOP;
      END IF;

      IF (p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
      END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        ROLLBACK TO DelAGRBscMD;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO DelAGRBscMD;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Delete_AG_Bsc_Metadata ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Delete_AG_Bsc_Metadata ';
        END IF;
        ROLLBACK TO DelAGRBscMD;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Delete_AG_Bsc_Metadata ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Delete_AG_Bsc_Metadata ';
        END IF;
        ROLLBACK TO DelAGRBscMD;

END Delete_AG_Bsc_Metadata;


-- Converts a measure from AG to Existing Source with the following option
  -- Deletes the source groups
  -- Empties the BIS_INDICATORS source and type.
PROCEDURE Switch_Measure_Type (
      p_Commit                     IN VARCHAR2 := FND_API.G_FALSE
    , p_Measure_Short_Name         IN VARCHAR2
    , p_Target_Source              IN VARCHAR2
    , p_Delete_Columns             IN VARCHAR2
    , p_Clean_Measure_Date_Source  IN VARCHAR2
    , x_Return_Status              OUT NOCOPY VARCHAR
    , x_Msg_Count                  OUT NOCOPY NUMBER
    , x_Msg_Data                   OUT NOCOPY VARCHAR
) IS

  l_Measure_Source BSC_SYS_MEASURES.SOURCE%TYPE;
  l_Measure_Column BSC_SYS_MEASURES.MEASURE_COL%TYPE;
  l_Dataset_Id     NUMBER;

BEGIN
     SAVEPOINT SwitchMeasureType;
     x_Return_Status :=  FND_API.G_RET_STS_SUCCESS;
     l_Measure_Source := Get_Measure_Source(p_Measure_Short_Name);

     IF((p_Target_Source = BSC_BIS_MEASURE_PUB.c_BSC) OR (p_Target_Source = l_Measure_Source)) THEN
       --- Conversion from PMF to BSC is currently not supported,
       RETURN;
     END IF;

     IF (p_Target_Source = BSC_BIS_MEASURE_PUB.c_PMF) THEN
        -- begin the UPDATE process
        BEGIN
          UPDATE BSC_SYS_MEASURES M
          SET    M.SOURCE     = BSC_BIS_MEASURE_PUB.c_PMF
          WHERE  M.SHORT_NAME = p_Measure_Short_Name;

          l_Dataset_Id := BSC_BIS_KPI_CRUD_PUB.Get_Dataset_Id(p_Measure_Short_Name);
          --DBMS_OUTPUT.PUT_LINE('Suceess - Update - BSC_SYS_MEASURES - ' || l_Dataset_Id);

          UPDATE BSC_SYS_DATASETS_B D
          SET    D.SOURCE     = BSC_BIS_MEASURE_PUB.c_PMF
          WHERE  D.DATASET_ID = l_Dataset_Id;

          --DBMS_OUTPUT.PUT_LINE('Suceess - Update - BSC_SYS_DATASETS_B -- ' || BSC_BIS_KPI_CRUD_PUB.Get_Dataset_Id(p_Measure_Short_Name));

        EXCEPTION
          WHEN OTHERS THEN
             --DBMS_OUTPUT.PUT_LINE('Error -  ' || SQLERRM);
             NULL;
        END;

        IF(p_Delete_Columns = FND_API.G_TRUE) THEN
           -- delete the measure columns
           BSC_DB_MEASURE_COLS_PKG.DELETE_ROW(l_Measure_Column);
        END IF;

        IF (p_Clean_Measure_Date_Source = FND_API.G_TRUE) THEN
            BEGIN

              UPDATE BIS_INDICATORS B
              SET    B.ACTUAL_DATA_SOURCE = NULL
              WHERE  B.SHORT_NAME         = p_Measure_Short_Name;

            EXCEPTION
              WHEN OTHERS THEN
                 NULL;
            END;
        END IF;
     END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        ROLLBACK TO SwitchMeasureType;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO SwitchMeasureType;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Switch_Measure_Type ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Switch_Measure_Type ';
        END IF;
        ROLLBACK TO SwitchMeasureType;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Switch_Measure_Type ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Switch_Measure_Type ';
        END IF;
        ROLLBACK TO SwitchMeasureType;
END Switch_Measure_Type;


FUNCTION Get_Measure_Source (
   p_Measure_Short_Name IN VARCHAR2
) RETURN VARCHAR2
IS
   l_Measure_Source BSC_SYS_MEASURES.SOURCE%TYPE;
BEGIN
   l_Measure_Source := BSC_BIS_MEASURE_PUB.c_BSC;

   SELECT
     m.source
   INTO
     l_Measure_Source
   FROM
     bsc_sys_measures m,
     bsc_sys_datasets_vl d,
     bis_indicators i
   WHERE
     i.dataset_id  = d.dataset_id AND
     d.measure_id1 = m.measure_id AND
     i.short_name  = p_Measure_Short_Name;

   RETURN l_Measure_Source;

EXCEPTION
   WHEN OTHERS THEN
     RETURN BSC_BIS_MEASURE_PUB.c_BSC;
END Get_Measure_Source;


FUNCTION Is_Measure_Data_Source_Valid(
  p_Measures_Short_Name IN VARCHAR2 ,
  p_Actual_Data_Source  IN VARCHAR2
) RETURN VARCHAR2
IS
  l_meas_source        BSC_SYS_MEASURES.SOURCE%TYPE;
  l_count              NUMBER := 0;
  l_region_code        AK_REGIONS.REGION_CODE%TYPE;
BEGIN

  l_region_code := SUBSTR(p_Actual_Data_Source, 1, INSTR(p_Actual_Data_Source, '.') - 1);

  SELECT COUNT(1)
  INTO   l_count
  FROM   ak_regions
  WHERE  region_code = l_region_code;

  -- When AG Report is deleted the actual_data_source of measures having this report as primary
  -- data source was not getting updated .This condition will check for such measures.
  l_meas_source := Get_Measure_Source(p_Measures_Short_Name);
  IF (l_count = 0 AND (BSC_BIS_KPI_CRUD_PUB.Get_Objective_By_AGKpi(p_Measures_Short_Name) = BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY) AND
      (l_meas_source = BSC_BIS_MEASURE_PUB.c_PMF OR l_meas_source = BSC_BIS_MEASURE_PUB.c_BSC)) THEN
      RETURN FND_API.G_FALSE;
  END IF;

  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
     RETURN FND_API.G_FALSE;
END Is_Measure_Data_Source_Valid;


-- changed the if condition for Bug#4642136
FUNCTION Get_Actual_Source_Data (
  p_Measures_Short_Name IN VARCHAR2
) RETURN VARCHAR2
IS
  l_Actual_Data_Source BIS_INDICATORS.ACTUAL_DATA_SOURCE%TYPE;
BEGIN

  l_Actual_Data_Source := NULL;

  SELECT B.ACTUAL_DATA_SOURCE
  INTO   l_Actual_Data_Source
  FROM   BIS_INDICATORS B
  WHERE  B.SHORT_NAME = p_Measures_Short_Name;


  -- Invalid Data sources should be returned as NULL (so that they are updatable)
  IF (Is_Measure_Data_Source_Valid(p_Measures_Short_Name,l_Actual_Data_Source) = FND_API.G_FALSE) THEN
    RETURN NULL;
  ELSE
    RETURN l_Actual_Data_Source;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     RETURN l_Actual_Data_Source;
END Get_Actual_Source_Data;

-- changed the if condition for Bug#4642136
FUNCTION Get_Measure_Function_Name (
  p_Measures_Short_Name IN VARCHAR2
) RETURN VARCHAR2
IS
  l_Measure_Function_Name BIS_INDICATORS.FUNCTION_NAME%TYPE;
  l_Count                 NUMBER := 0;
BEGIN

  l_Measure_Function_Name := NULL;

  SELECT B.FUNCTION_NAME
  INTO   l_Measure_Function_Name
  FROM   BIS_INDICATORS B
  WHERE  B.SHORT_NAME = p_Measures_Short_Name;

  IF(l_Measure_Function_Name IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT COUNT(1)
  INTO  l_Count
  FROM  fnd_form_functions
  WHERE function_name = l_Measure_Function_Name;

  -- For BSC Type of measure an invalid function name should be overwritten.
  --This happens only if the report with this function name is deleted
  IF (l_Count = 0 AND (BSC_BIS_KPI_CRUD_PUB.Get_Objective_By_AGKpi(p_Measures_Short_Name) = BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY) AND
      Get_Measure_Source(p_Measures_Short_Name) = BSC_BIS_MEASURE_PUB.c_BSC) THEN
    RETURN NULL;
  ELSE
    RETURN l_Measure_Function_Name;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     RETURN l_Measure_Function_Name;
END Get_Measure_Function_Name;

-- changed the if condition for Bug#4642136
-- Added for Bug#4599432
FUNCTION Get_Actual_Source_Data_Type (
  p_Measures_Short_Name IN VARCHAR2
) RETURN VARCHAR2
IS
  l_Actual_Data_Source_Type BIS_INDICATORS.ACTUAL_DATA_SOURCE_TYPE%TYPE;
  l_Actual_Data_Source BIS_INDICATORS.ACTUAL_DATA_SOURCE%TYPE;
BEGIN

  l_Actual_Data_Source_Type := NULL;

  SELECT B.ACTUAL_DATA_SOURCE_TYPE, B.ACTUAL_DATA_SOURCE
  INTO   l_Actual_Data_Source_Type, l_Actual_Data_Source
  FROM   BIS_INDICATORS B
  WHERE  B.SHORT_NAME = p_Measures_Short_Name;

  -- Invalid Data sources should be returned as NULL (so that they are updatable)
  IF (Is_Measure_Data_Source_Valid(p_Measures_Short_Name,l_Actual_Data_Source) = FND_API.G_FALSE) THEN
    RETURN NULL;
  ELSE
    RETURN l_Actual_Data_Source_Type;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     RETURN l_Actual_Data_Source_Type;
END Get_Actual_Source_Data_Type;


-- API added for Bug#4339686
FUNCTION is_Scorecard_From_AG_Report (
  p_Tab_id IN NUMBER
) RETURN VARCHAR2 IS
    l_Count NUMBER;
BEGIN

    SELECT COUNT(1) INTO l_Count
    FROM   BSC_TABS_B                 T,
           BSC_TAB_INDICATORS         K,
           BSC_KPI_ANALYSIS_OPTIONS_B A
    WHERE  T.TAB_ID     = p_Tab_id
    AND    K.TAB_ID     = T.TAB_ID
    AND    A.INDICATOR  = K.INDICATOR
    AND    A.SHORT_NAME = T.SHORT_NAME;

    -- The scorecard is the same as the analysis_option,
    -- hence it must have been created from AG Report flow
    IF (l_Count <> 0) THEN
        RETURN FND_API.G_TRUE;
    END IF;

    RETURN FND_API.G_FALSE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END is_Scorecard_From_AG_Report;


-- Check if the Periodicities have been changed from the Parameter Section
-- when compared to the Objective

FUNCTION Has_Time_Dim_Obj_Changed (
     p_Time_Dim_Objects IN VARCHAR2
   , p_Kpi_Id           IN NUMBER
   , p_Is_Xtd           IN VARCHAR2
) RETURN VARCHAR2 IS
    l_Time_Dim_Obj_Short_Name  VARCHAR2(30);
    l_Time_Dim_Obj_Short_Names VARCHAR2(1000);
    l_Periodicity_Id           NUMBER;
    l_Count                    NUMBER;
    l_Calendar_Id              NUMBER := NULL;
    l_Calendar_Id_Aux          NUMBER := NULL;
    l_Message                  VARCHAR2(400);
    l_Flag                     BOOLEAN;
    l_Loop_Count               NUMBER;
    l_Time_Dim_Object          VARCHAR2(30);
    TYPE period_array IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    l_periods                    period_array;
    l_Period_Count             NUMBER;
    l_Found                    BOOLEAN;
    l_Daily_Found              BOOLEAN;
    l_Daily_Diff               NUMBER;

BEGIN

    l_Time_Dim_Obj_Short_Names := p_Time_Dim_Objects;

    IF (p_Time_Dim_Objects IS NULL) THEN
        RETURN FND_API.G_TRUE;
    END IF;

    l_Loop_Count := 0;
    l_Period_Count := 0;
    l_Daily_Found := FALSE;

    WHILE (is_more(p_dim_short_names  =>  l_Time_Dim_Obj_Short_Names
                  ,p_dim_name         =>  l_Time_Dim_Obj_Short_Name)) LOOP


        l_Periodicity_Id := NULL;

        l_Time_Dim_Object := l_Time_Dim_Obj_Short_Name;

        l_flag  := BSC_PERIODS_UTILITY_PKG.Get_Bsc_Periodicity(
                     x_time_level_name    => l_Time_Dim_Object
                      ,x_periodicity_id     => l_Periodicity_Id
                      ,x_calendar_id        => l_Calendar_Id_Aux
                      ,x_message            => l_Message
                   );

        l_Found := FALSE;
        FOR counter IN 1..l_Period_Count LOOP
          IF (l_periods(counter) = l_Time_Dim_Object) THEN
            l_Found := TRUE;
          END IF;
        END LOOP;

        IF (NOT l_Found) THEN

          l_Period_Count := l_Period_Count + 1;
          l_periods(l_Period_Count) := l_Time_Dim_Object;

          l_Calendar_Id := l_Calendar_Id_Aux;

          SELECT COUNT(1) INTO l_Count
          FROM   BSC_KPI_PERIODICITIES K
          WHERE  K.INDICATOR      = p_Kpi_Id
          AND    K.PERIODICITY_ID = l_Periodicity_Id;

          IF(NOT BSC_PERIODS_UTILITY_PKG.Is_Base_Periodicity_Daily(l_Periodicity_Id))THEN
            l_Loop_Count := l_Loop_Count + 1;
          ELSE
            l_Daily_Found := TRUE;
          END IF;

          IF (l_Count <> 1) THEN
              RETURN FND_API.G_TRUE;
          END IF;
        END IF;

    END LOOP;

    SELECT COUNT(1) INTO l_Count
    FROM   BSC_KPI_PERIODICITIES K
    WHERE  K.INDICATOR = p_Kpi_Id;

    -- We need to ignore the DAY365, since it is mandatory.
    IF ((p_Is_Xtd <> FND_API.G_TRUE) AND (NOT l_Daily_Found)) THEN
      l_Daily_Diff := 0;
    ELSE
      l_Daily_Diff := 1;
    END IF;

    IF (l_Loop_Count <> (l_Count-l_Daily_Diff)) THEN
      RETURN FND_API.G_TRUE;
    END IF;


    RETURN FND_API.G_FALSE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Has_Time_Dim_Obj_Changed;


FUNCTION Has_Non_Time_Dim_Obj_Changed (
     p_Non_Time_Dim_Objects IN VARCHAR2
   , p_Kpi_Id               IN NUMBER
) RETURN VARCHAR2 IS
    l_Non_Time_Dim_Obj_Short_Name  VARCHAR2(30);
    l_Non_Time_Dim_Obj_Short_Names VARCHAR2(1000);
    l_Obj_NT_Dim_Obj_Short_Names   VARCHAR2(1000);
    l_Count                        NUMBER;

    CURSOR c_Objective_Dim_Obj IS
        SELECT B.LEVEL_SHORTNAME
        FROM   BSC_KPI_DIM_LEVELS_VL B
        WHERE  B.INDICATOR = p_Kpi_Id
        ORDER BY B.DIM_LEVEL_INDEX;

BEGIN

    l_Non_Time_Dim_Obj_Short_Names := p_Non_Time_Dim_Objects;
    l_Obj_NT_Dim_Obj_Short_Names := NULL;


    FOR cODO IN c_Objective_Dim_Obj LOOP
        IF(l_Obj_NT_Dim_Obj_Short_Names IS NULL) THEN
            l_Obj_NT_Dim_Obj_Short_Names := cODO.LEVEL_SHORTNAME;
        ELSE
            l_Obj_NT_Dim_Obj_Short_Names := l_Obj_NT_Dim_Obj_Short_Names ||',' || cODO.LEVEL_SHORTNAME;
        END IF;
    END LOOP;


    IF ((l_Non_Time_Dim_Obj_Short_Names IS NULL AND l_Obj_NT_Dim_Obj_Short_Names IS NOT NULL) OR
        (l_Non_Time_Dim_Obj_Short_Names IS NOT NULL AND l_Obj_NT_Dim_Obj_Short_Names IS NULL) OR
        (l_Non_Time_Dim_Obj_Short_Names <> l_Obj_NT_Dim_Obj_Short_Names)) THEN
      RETURN FND_API.G_TRUE;
    END IF;

    RETURN FND_API.G_FALSE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Has_Non_Time_Dim_Obj_Changed;

-- Check if the measure sequence has changed or not
FUNCTION Has_Measure_Column_Changed (
     p_Measure_Short_Names IN VARCHAR2
   , p_Kpi_id              IN NUMBER
) RETURN VARCHAR2 IS
    CURSOR c_Meas_Short_Names IS
        SELECT I.SHORT_NAME
        FROM    BSC_KPI_ANALYSIS_MEASURES_B K
              , BIS_INDICATORS I
        WHERE  K.INDICATOR  = p_Kpi_Id
        AND    K.ANALYSIS_OPTION0 = 0
        AND    K.ANALYSIS_OPTION1 = 0
        AND    K.ANALYSIS_OPTION2 = 0
        AND    I.DATASET_ID = K.DATASET_ID
        AND    K.DATASET_ID <>-1
        ORDER BY K.SERIES_ID;

    l_Measure_Short_Names VARCHAR2(1000);
BEGIN
    FOR c_MSN IN c_Meas_Short_Names LOOP
        IF (l_Measure_Short_Names IS NULL) THEN
            l_Measure_Short_Names := c_MSN.SHORT_NAME;
        ELSE
            l_Measure_Short_Names := l_Measure_Short_Names || ',' || c_MSN.SHORT_NAME;
        END IF;
    END LOOP;

    IF ((l_Measure_Short_Names <> p_Measure_Short_Names) OR
         (p_Measure_Short_Names IS NULL AND l_Measure_Short_Names IS NOT NULL) OR
       (l_Measure_Short_Names IS NULL AND p_Measure_Short_Names IS NOT NULL)) THEN
        RETURN FND_API.G_TRUE;
    END IF;

    RETURN FND_API.G_FALSE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Has_Measure_Column_Changed;

-- Checks if the measures have been changed or not
FUNCTION Have_Measures_Changed (
     p_Measure_Short_Names IN VARCHAR2
   , p_Kpi_id              IN NUMBER
) RETURN VARCHAR2 IS

    CURSOR c_Meas_Short_Names IS
        SELECT I.SHORT_NAME
        FROM    BSC_KPI_ANALYSIS_MEASURES_B K
              , BIS_INDICATORS I
        WHERE  K.INDICATOR  = p_Kpi_Id
        AND    K.ANALYSIS_OPTION0 = 0
        AND    K.ANALYSIS_OPTION1 = 0
        AND    K.ANALYSIS_OPTION2 = 0
        AND    I.DATASET_ID = K.DATASET_ID
        AND    K.DATASET_ID <>-1
        ORDER BY K.SERIES_ID;

    l_Measure_Short_Names VARCHAR2(1000);
    l_Cur_Meas_Short_Name BIS_INDICATORS.SHORT_NAME%TYPE;
    l_PreviousMeasCnt     NUMBER := 0;
    l_CurrentMeasCnt      NUMBER := 0;
BEGIN

    IF( p_Measure_Short_Names IS NOT NULL) THEN
      l_Measure_Short_Names := p_Measure_Short_Names;
      l_CurrentMeasCnt := LENGTH(l_Measure_Short_Names) - LENGTH(REPLACE(l_Measure_Short_Names,',')) + 1 ;
    END IF;

    SELECT COUNT(1) INTO l_PreviousMeasCnt
    FROM    BSC_KPI_ANALYSIS_MEASURES_B K
          , BIS_INDICATORS I
    WHERE  K.INDICATOR  = p_Kpi_Id
    AND    K.ANALYSIS_OPTION0 = 0
    AND    K.ANALYSIS_OPTION1 = 0
    AND    K.ANALYSIS_OPTION2 = 0
    AND    I.DATASET_ID = K.DATASET_ID
    AND    K.DATASET_ID <>-1
    ORDER BY K.SERIES_ID;

    IF (l_CurrentMeasCnt <> l_PreviousMeasCnt) THEN
       RETURN FND_API.G_TRUE;
    END IF;

    l_Measure_Short_Names := ',' || p_Measure_Short_Names || ',';
    FOR c_MSN IN c_Meas_Short_Names LOOP
  l_Cur_Meas_Short_Name := ',' || c_MSN.SHORT_NAME || ',';
  IF(LENGTH(l_Measure_Short_Names) - LENGTH(REPLACE(l_Measure_Short_Names,l_Cur_Meas_Short_Name)) = 0) THEN
           RETURN FND_API.G_TRUE;
        END IF;
    END LOOP;

    RETURN FND_API.G_FALSE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Have_Measures_Changed;


/************************************************************
 Name           : Delete_Tab_And_TabViews
 Description    : This API is used to delete the scorecard and the associated
                  tab_views which are attached to it.
 Creator        : ashankar 25-May-2005
 Note           : Before using this API from Report designer we need to check if BSC
                  is installed or not.If not then we will not call this API.
/************************************************************/

PROCEDURE Delete_Tab_And_TabViews
(
      p_commit         IN         VARCHAR2 := FND_API.G_FALSE
    , p_region_code    IN         AK_REGION_ITEMS.region_code%TYPE
    , x_Return_Status  OUT NOCOPY VARCHAR2
    , x_Msg_Count      OUT NOCOPY NUMBER
    , x_Msg_Data       OUT NOCOPY VARCHAR2
)IS
   l_tab_id          BSC_TABS_B.tab_id%TYPE;

   CURSOR c_GetTabId IS
      SELECT tab_id
      FROM   BSC_TABS_B
      WHERE  SHORT_NAME = p_region_code;

BEGIN
    FND_MSG_PUB.INITIALIZE;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR cTabId IN c_GetTabId LOOP
     l_tab_id := cTabId.tab_id;
   END LOOP;

   IF(l_tab_id IS NOT NULL) THEN

       BSC_PMF_UI_WRAPPER.Delete_Tab
       (
              p_commit         => p_commit
          , p_tab_id         => l_tab_id
          , x_Return_Status  => x_Return_Status
          , x_Msg_Count      => x_Msg_Count
          , x_Msg_Data       => x_Msg_Data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    IF(p_commit =FND_API.G_TRUE)THEN
     COMMIT;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_Msg_Data IS NULL) THEN
          FND_MSG_PUB.Count_And_Get
            (    p_encoded   =>  FND_API.G_FALSE
                ,p_count     =>  x_Msg_Data
                ,p_data      =>  x_Msg_Count
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_Msg_Data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (    p_encoded   =>  FND_API.G_FALSE
                ,p_count     =>  x_Msg_Data
                ,p_data      =>  x_Msg_Count
            );
        END IF;

        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
      --DBMS_OUTPUT.PUT_LINE\n('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);

     WHEN NO_DATA_FOUND THEN
      x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (x_Msg_Data IS NOT NULL) THEN
        x_msg_data      :=  x_Msg_Data||' -> BSC_BIS_KPI_CRUD_PUB.Delete_Tab_And_TabViews ';
      ELSE
        x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Delete_Tab_And_TabViews ';
      END IF;

      --DBMS_OUTPUT.PUT_LINE\n('EXCEPTION NO_DATA_FOUND '||x_msg_data);

     WHEN OTHERS THEN
      x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (x_Msg_Data IS NOT NULL) THEN
        x_Msg_Data      :=  x_Msg_Data||' -> BSC_BIS_KPI_CRUD_PUB.Delete_Tab_And_TabViews ';
      ELSE
        x_Msg_Data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Delete_Tab_And_TabViews ';
      END IF;

END Delete_Tab_And_TabViews;

/************************************************************
 Name           : Get_Measures_From_CustomView
 Description    : This API is used to get the list of measure short names which are used in
                  a custom view and that custom view is attached to a report
 Input          : p_region_code   Region code of the report
                  p_region_app_id application id of the report
 Ouput          : x_has_cust_view
                   FND_API.G_FALSE   --> indicates custom view was not created for the report
                   FND_API.G_TRUE    --> indicates custom view exists for the report along with the measures
                                         Even though custom view exists but with no measures even then this
                                         out values will be false.
                : x_meas_sht_names   --> Comma separated measure short names.
 Creator        : ashankar 27-May-2005
/************************************************************/
PROCEDURE Get_Measures_From_CustomView
(
      p_region_code       IN            AK_REGION_ITEMS.region_code%TYPE
    , p_region_app_id     IN            AK_REGION_ITEMS.region_application_id%TYPE
    , x_has_cust_view     OUT NOCOPY    VARCHAR2
    , x_meas_sht_names    OUT NOCOPY    VARCHAR2
    , x_scorecard_id      OUT NOCOPY    NUMBER
    , x_tabview_id        OUT NOCOPY    NUMBER
    --, x_last_update_date  OUT NOCOPY    VARCHAR
    , x_return_status     OUT NOCOPY    VARCHAR2
    , x_msg_count         OUT NOCOPY    NUMBER
    , x_msg_data          OUT NOCOPY    VARCHAR2
) IS
   l_count           NUMBER;
   l_meas_sht_names  VARCHAR2(4000);


   CURSOR c_meas_sht IS
   SELECT B.short_name
   FROM   BIS_INDICATORS        B
         ,BSC_TAB_VIEW_LABELS_B C
         ,BSC_TABS_B            A
   WHERE A.tab_id = C.tab_id
   AND   C.link_id = B.dataset_id
   AND   A.short_name = p_region_code;

   CURSOR c_cust_views IS
   SELECT  A.tab_id
          ,B.tab_view_id
          ,B.last_update_date
   FROM    BSC_TABS_B A
          ,BSC_TAB_VIEWS_B B
   WHERE   A.tab_id =B.tab_id
   AND     A.short_name = p_region_code;

BEGIN
    FND_MSG_PUB.INITIALIZE;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    x_has_cust_view := FND_API.G_FALSE;

    SELECT COUNT(0)
    INTO   l_count
    FROM   AK_REGION_ITEMS
    WHERE  region_code = p_region_code
    AND    region_application_id = p_region_app_id;

    IF(l_count > 0) THEN
       FOR cd IN c_meas_sht LOOP
          IF(l_meas_sht_names IS NULL) THEN
            l_meas_sht_names := cd.short_name;
          ELSE
            l_meas_sht_names := l_meas_sht_names || ','|| cd.short_name;
          END IF;
       END LOOP;

       FOR cd1 IN  c_cust_views LOOP
        x_scorecard_id      := cd1.tab_id;
        x_tabview_id        := cd1.tab_view_id;
        x_has_cust_view  := FND_API.G_TRUE;
      --  x_last_update_date  := TO_CHAR(cd1.last_update_date, BSC_BIS_LOCKS_PUB.C_TIME_STAMP_FORMAT);
       END LOOP;

    END IF;
    x_meas_sht_names :=  l_meas_sht_names;


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Get_Measures_From_CustomView ';
    ELSE
        x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Get_Measures_From_CustomView ';
    END IF;
END Get_Measures_From_CustomView;


/*****************************************************
 Name           :    is_Scorecard_From_Reports
 Description    :  This API checks if the scoreacrd was created
                   from report designer or not.If WEB_HTML_CALL of FND_FORM_FUNCTIONS is bisviewer.showreport or BISReportPG then it is created
                   from report designer.If it is OA.jsp?akRegionCode=BIS_COMPONENT_PAGE?akRegionApplicationId=191 then it is created from page designer.
                   Scorecard created from page designer can be deleted from Scorecard designers but not the scorecard created from
                   report designer.
INPUT           :  p_tab_sht_name
OUPTUT          : 'F' --> Not from report designer
                  'T' --> From report designer
Created by      : ashankar 08-JUL-2005
/****************************************************/

FUNCTION is_Scorecard_From_Reports (
   p_tab_sht_name    IN   BSC_TABS_B.short_name%TYPE
) RETURN VARCHAR2 IS

  CURSOR c_form_function IS
  SELECT Web_html_call
  FROM   FND_FORM_FUNCTIONS
  WHERE  FUNCTION_NAME =p_tab_sht_name;

  l_web_html_call   FND_FORM_FUNCTIONS.web_html_call%TYPE;
BEGIN

    IF(c_form_function%ISOPEN) THEN
     CLOSE c_form_function;
    END IF;

    OPEN c_form_function;
    FETCH c_form_function INTO l_web_html_call;
    CLOSE c_form_function;

    IF((UPPER(l_web_html_call)=BSC_BIS_KPI_CRUD_PUB.C_BISVIEWER_SHOWREPORT) OR (UPPER(l_web_html_call) = UPPER(BSC_BIS_KPI_CRUD_PUB.c_bisreportpg)))THEN
      RETURN FND_API.G_TRUE;
    END IF;

    RETURN FND_API.G_FALSE;

EXCEPTION
    WHEN OTHERS THEN
        IF(c_form_function%ISOPEN) THEN
         CLOSE c_form_function;
        END IF;
        RETURN FND_API.G_FALSE;
END is_Scorecard_From_Reports;

-- Check if the Dimension Object is a BSC periodicity
FUNCTION Is_DimObj_Periodicity(
     p_Short_Name IN VARCHAR2
) RETURN VARCHAR2 IS
    l_Count NUMBER;
BEGIN
    l_Count := 0;

    SELECT COUNT(1) INTO l_Count
    FROM   BSC_SYS_PERIODICITIES P
    WHERE  P.SHORT_NAME = p_Short_Name;

    IF (l_Count <> 0) THEN
        RETURN FND_API.G_TRUE;
    END IF;

    RETURN FND_API.G_FALSE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Is_DimObj_Periodicity;


-- Check if the Dimension is a Custom/DBI Calendar
FUNCTION Is_Dimension_Calendar(
     p_Short_Name IN VARCHAR2
) RETURN VARCHAR2 IS
    l_Count NUMBER;
BEGIN
    l_Count := 0;

    SELECT COUNT(1) INTO l_Count
    FROM   BSC_SYS_CALENDARS_B P
    WHERE  P.SHORT_NAME = p_Short_Name;

    IF (l_Count <> 0) THEN
        RETURN FND_API.G_TRUE;
    END IF;

    RETURN FND_API.G_FALSE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Is_Dimension_Calendar;

-- This API is similar to BSC_DBI_CALENDAR.get_bsc_Periodicity,
-- except that it queries directly from the BSC_SYS_PERIODICITIES table
PROCEDURE Get_Non_DBI_Periodicities (
      p_Time_Short_Name     IN VARCHAR2
    , x_Periodicity_Id      OUT NOCOPY VARCHAR2
    , x_Calendar_Id         OUT NOCOPY VARCHAR2
    , x_Return_Status       OUT NOCOPY VARCHAR
    , x_Msg_Count           OUT NOCOPY NUMBER
    , x_Msg_Data            OUT NOCOPY VARCHAR
) IS
BEGIN
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    IF (p_Time_Short_Name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_TIME_PERIODICITY_NULL');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    SELECT B.PERIODICITY_ID, B.CALENDAR_ID
    INTO   x_Periodicity_Id, x_Calendar_Id
    FROM   BSC_SYS_PERIODICITIES B
    WHERE  B.SHORT_NAME = p_Time_Short_Name;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF(x_Msg_Data IS NULL) THEN
            x_Msg_Data := BSC_APPS.Get_Message('BSC_PER_CAL_NOT_EXIST');
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
END Get_Non_DBI_Periodicities;


PROCEDURE Is_Struct_Change_For_AG_Report
( p_Region_Code           IN VARCHAR2
, p_Region_Application_Id IN NUMBER
, p_Dim_Obj_Short_Names   IN VARCHAR2
, p_Measure_Short_Names   IN VARCHAR2
, x_Result                OUT NOCOPY   VARCHAR2
, x_Return_Status         OUT NOCOPY   VARCHAR2
, x_Msg_Count             OUT NOCOPY   NUMBER
, x_Msg_Data              OUT NOCOPY   VARCHAR2
)
IS
  l_Kpi_Id                          NUMBER;
  l_Non_Time_Dimension_Groups       BSC_VARCHAR2_TBL_TYPE;
  l_Non_Time_Dimension_Objects      BSC_VARCHAR2_TBL_TYPE;
  l_Non_Time_Dim_Obj_Short_Names    VARCHAR2(2056);
  l_Time_Dimension_Groups           BSC_VARCHAR2_TBL_TYPE;
  l_Time_Dimension_Objects          BSC_VARCHAR2_TBL_TYPE;
  l_Time_Dim_Obj_Short_Names        VARCHAR2(2056);
  l_All_Dim_Group_Ids               BSC_NUMBER_TBL_TYPE;
  l_Non_Time_Counter                NUMBER;
  l_Time_Counter                    NUMBER;
  l_Is_XTD_Enabled                  VARCHAR2(1);
BEGIN
  x_Result := FND_API.G_FALSE;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;
  l_Kpi_Id := Get_Kpi_Id(p_Region_Code);
  Get_Dim_Info_From_ParamPortlet(
       p_Dimension_Info               => p_Dim_Obj_Short_Names
      ,x_non_time_dimension_groups    => l_Non_Time_Dimension_Groups
      ,x_non_time_dimension_objects   => l_Non_Time_Dimension_Objects
      ,x_non_time_dim_obj_short_names => l_Non_Time_Dim_Obj_Short_Names
      ,x_all_dim_group_ids            => l_All_Dim_Group_Ids
      ,x_non_time_counter             => l_Non_Time_Counter
      ,x_time_dimension_groups        => l_Time_Dimension_Groups
      ,x_time_dimension_objects       => l_Time_Dimension_Objects
      ,x_time_dim_obj_short_names     => l_Time_Dim_Obj_Short_Names
      ,x_time_counter                 => l_Time_Counter
      ,x_msg_data                     => x_Msg_Data
      ,x_is_as_of_date                => l_Is_XTD_Enabled
    );

    IF((Has_Time_Dim_Obj_Changed(l_Time_Dim_Obj_Short_Names, l_Kpi_Id, l_Is_XTD_Enabled) = FND_API.G_TRUE) OR
       (Has_Non_Time_Dim_Obj_Changed(l_Non_Time_Dim_Obj_Short_Names,l_Kpi_Id) = FND_API.G_TRUE)) THEN
       x_Result := FND_API.G_TRUE;
       RETURN;
    END IF;
  IF (Have_Measures_Changed(p_Measure_Short_Names,l_Kpi_Id) = FND_API.G_TRUE) THEN
      x_Result := FND_API.G_TRUE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Is_Struct_Change_For_AG_Report ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Is_Struct_Change_For_AG_Report ';
    END IF;
END Is_Struct_Change_For_AG_Report;

FUNCTION Get_Attribute_Code_For_Measure
( p_Report_Region_Code  IN  VARCHAR2
 ,p_Measure_Short_Name    IN  VARCHAR2
) RETURN VARCHAR2 IS
  l_attribute_code  AK_REGION_ITEMS.ATTRIBUTE_CODE%TYPE;
BEGIN
  IF (p_Report_Region_Code IS NOT NULL AND p_Measure_Short_Name IS NOT NULL) THEN
    SELECT attribute_code
    INTO l_attribute_code
    FROM ak_region_items
    WHERE region_code = p_Report_Region_Code
    AND attribute2 = p_Measure_Short_Name;
  END IF;
  RETURN l_attribute_code;
EXCEPTION
  WHEN OTHERS THEN
    RETURN l_attribute_code;
END Get_Attribute_Code_For_Measure;

/*******************************************
** START **
Added the following API for dynamic
parameter portlet creation logic as required
by Bug#4558279
********************************************/

FUNCTION Is_Dim_Exist_In_Current_Region (
     p_Region_Code            IN AK_REGIONS.REGION_CODE%TYPE
   , p_Region_Application_Id  IN AK_REGIONS.REGION_APPLICATION_ID%TYPE
) RETURN VARCHAR2 IS
    l_Count NUMBER;
BEGIN
    l_Count := 0;

    SELECT   COUNT(1) INTO l_Count
    FROM     AK_REGION_ITEMS A
    WHERE    A.REGION_CODE           = p_Region_Code
    AND      A.REGION_APPLICATION_ID = p_Region_Application_Id
    AND      A.ATTRIBUTE1  IN
             ('DIMENSION LEVEL',
              'DIM LEVEL SINGLE VALUE',
              'DIMENSION VALUE',
              'HIDE_VIEW_BY',
              'HIDE_VIEW_BY_SINGLE',
              'HIDE PARAMETER',
              'VIEWBY PARAMETER',
              'HIDE_DIM_LVL',
              'HIDE DIMENSION LEVEL',
              'HIDE VIEW BY DIMENSION',
              'HIDE_VIEW_BY_DIM_SINGLE');


    IF (l_Count <> 0) THEN
        RETURN FND_API.G_TRUE;
    END IF;


    RETURN FND_API.G_FALSE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Is_Dim_Exist_In_Current_Region;


/*******************************************

********************************************/

FUNCTION Is_Dim_Exist_In_Nested_Region (
     p_Region_Code            IN AK_REGIONS.REGION_CODE%TYPE
   , p_Region_Application_Id  IN AK_REGIONS.REGION_APPLICATION_ID%TYPE
) RETURN VARCHAR2 IS
    CURSOR c_Get_Nested_Region_Items IS
        SELECT  A.NESTED_REGION_CODE
               ,A.NESTED_REGION_APPLICATION_ID
        FROM    AK_REGION_ITEMS A
        WHERE   A.REGION_CODE = p_Region_Code
        AND     A.REGION_APPLICATION_ID = p_Region_Application_Id
        AND     A.ITEM_STYLE  = BIS_AK_REGION_PUB.c_NESTED_REGION_STYLE;
BEGIN

    FOR cGNR IN c_Get_Nested_Region_Items LOOP
        IF (Is_Dim_Exist_In_Current_Region(
               cGNR.NESTED_REGION_CODE,
               cGNR.NESTED_REGION_APPLICATION_ID
            ) = FND_API.G_TRUE) THEN
            RETURN FND_API.G_TRUE;
        END IF;
    END LOOP;

    RETURN FND_API.G_FALSE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Is_Dim_Exist_In_Nested_Region;


/*******************************************

********************************************/
FUNCTION Is_New_Param_Portlet_Required (
     p_Region_Code            IN AK_REGIONS.REGION_CODE%TYPE
   , p_Region_Application_Id  IN AK_REGIONS.REGION_APPLICATION_ID%TYPE
) RETURN VARCHAR2 IS
BEGIN
    IF ((Is_Dim_Exist_In_Current_Region(p_Region_Code, p_Region_Application_Id) = FND_API.G_TRUE) AND
        (Is_Dim_Exist_In_Nested_Region(p_Region_Code,p_Region_Application_Id) = FND_API.G_TRUE)) THEN
            RETURN FND_API.G_TRUE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Is_New_Param_Portlet_Required;



PROCEDURE Cascade_Parameter_Portlet (
      p_Commit                       IN VARCHAR2
    , p_Page_Function_Name           IN VARCHAR2
    , p_Param_Region_Code            IN AK_REGIONS.REGION_CODE%TYPE
    , p_Param_Region_Application_Id  IN AK_REGIONS.REGION_APPLICATION_ID%TYPE
    , p_Action_Type                  IN VARCHAR2
    , x_Region_Code                  OUT NOCOPY   VARCHAR2
    , x_Region_Application_Id        OUT NOCOPY   NUMBER
    , x_Return_Status                OUT NOCOPY   VARCHAR2
    , x_Msg_Count                    OUT NOCOPY   NUMBER
    , x_Msg_Data                     OUT NOCOPY   VARCHAR2
) IS
BEGIN
    IF(p_Action_Type = BSC_UTILITY.c_CREATE) THEN
        IF (Is_Dim_Exist_In_Nested_Region(
                    p_Param_Region_Code,
                    p_Param_Region_Application_Id
           ) = FND_API.G_TRUE) THEN
            IF (NOT Does_KPI_Exist(p_Page_Function_Name)) THEN
                BSC_BIS_KPI_CRUD_PUB.Create_Parameter_Portlet (
                      p_Commit                 => p_Commit
                    , p_Region_Code            => p_Param_Region_Code
                    , p_Region_Application_Id  => p_Param_Region_Application_Id
                    , x_Region_Code            => x_Region_Code
                    , x_Region_Application_Id  => x_Region_Application_Id
                    , x_Return_Status          => x_Return_Status
                    , x_Msg_Count              => x_Msg_Count
                    , x_Msg_Data               => x_Msg_Data
                );
                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            ELSE
                x_Region_Code           := Get_Param_Portlet_By_Dashboard(p_Page_Function_Name);
                x_Region_Application_Id := Get_Region_Application_Id(x_Region_Code);
            END IF;
        ELSE
            x_Region_Code           := p_Param_Region_Code;
            x_Region_Application_Id := p_Param_Region_Application_Id;
        END IF;
    ELSIF (p_Action_Type = BSC_UTILITY.c_UPDATE) THEN
        x_Region_Code           := Get_Param_Portlet_By_Dashboard(p_Page_Function_Name);
        x_Region_Application_Id := Get_Region_Application_Id(x_Region_Code);
    ELSIF (p_Action_Type = BSC_UTILITY.c_DELETE) THEN
        x_Region_Code           := Get_Param_Portlet_By_Dashboard(p_Page_Function_Name);
        x_Region_Application_Id := Get_Region_Application_Id(x_Region_Code);
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Cascade_Parameter_Portlet ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Cascade_Parameter_Portlet ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Cascade_Parameter_Portlet ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Cascade_Parameter_Portlet ';
        END IF;
END Cascade_Parameter_Portlet;

/*******************************************

********************************************/

PROCEDURE Create_Parameter_Portlet (
      p_Commit                    IN VARCHAR2
    , p_Region_Code               IN AK_REGIONS.REGION_CODE%TYPE
    , p_Region_Application_Id     IN AK_REGIONS.REGION_APPLICATION_ID%TYPE
    , x_Region_Code               OUT NOCOPY   VARCHAR2
    , x_Region_Application_Id     OUT NOCOPY   NUMBER
    , x_Return_Status             OUT NOCOPY   VARCHAR2
    , x_Msg_Count                 OUT NOCOPY   NUMBER
    , x_Msg_Data                  OUT NOCOPY   VARCHAR2
) IS
    l_Region_Code            AK_REGIONS.REGION_CODE%TYPE;
    l_Report_Region_Rec      BIS_AK_REGION_PUB.Bis_Region_Rec_Type;
    l_Region_Item_Tbl        BIS_AK_REGION_PUB.Bis_Region_Item_Tbl_Type;
BEGIN

    SAVEPOINT CascadeParamPortlet;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    -- get a new region_code
    l_Region_Code := Get_New_Region_Code;

    l_Report_Region_Rec.Region_Code            := l_Region_Code;
    l_Report_Region_Rec.Region_Name            := l_Region_Code;
    l_Report_Region_Rec.Region_Description     := l_Region_Code;
    l_Report_Region_Rec.Region_Application_Id  := BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID;
    l_Report_Region_Rec.Database_Object_Name   := C_ICX_PROMPTS;
    l_Report_Region_Rec.Region_Style           := C_TABLE;
    l_Report_Region_Rec.Region_Object_Type     := NULL;
    l_Report_Region_Rec.Help_Target            := NULL;
    l_Report_Region_Rec.Display_Rows           := NULL;
    l_Report_Region_Rec.Disable_View_By        := 'N';
    l_Report_Region_Rec.No_Of_Portlet_Rows     := NULL;
    l_Report_Region_Rec.Schedule               := NULL;
    l_Report_Region_Rec.Header_File_Procedure  := NULL;
    l_Report_Region_Rec.Footer_File_Procedure  := NULL;
    l_Report_Region_Rec.Group_By               := NULL;
    l_Report_Region_Rec.Order_By               := NULL;
    l_Report_Region_Rec.Plsql_For_Report_Query := NULL;
    l_Report_Region_Rec.Display_Subtotals      := NULL;
    l_Report_Region_Rec.Data_Source            := NULL;
    l_Report_Region_Rec.Where_Clause           := NULL;
    l_Report_Region_Rec.Dimension_Group        := NULL;
    l_Report_Region_Rec.Parameter_Layout       := NULL;
    l_Report_Region_Rec.Kpi_Id                 := NULL;
    l_Report_Region_Rec.Analysis_Option_Id     := NULL;
    l_Report_Region_Rec.Dim_Set_Id             := NULL;

    BIS_PMV_REGION_PVT.CREATE_REGION
    (
         p_commit                 => p_commit
        ,p_Report_Region_Rec      => l_report_region_rec
        ,x_return_status          => x_return_status
        ,x_msg_count              => x_msg_count
        ,x_msg_data               => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_BIS_KPI_CRUD_PUB.Unroll_RegionItems_Into_Record (
         p_Region_Code            => p_Region_Code
       , p_Region_Application_Id  => p_Region_Application_Id
       , x_Region_Item_Tbl        => l_Region_Item_Tbl
    );

    BIS_PMV_REGION_ITEMS_PVT.CREATE_REGION_ITEMS(
        p_commit                 => p_commit
       ,p_region_code            => l_Region_Code
       ,p_region_application_id  => BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID
       ,p_Region_Item_Tbl        => l_Region_Item_Tbl
       ,x_return_status          => x_return_status
       ,x_msg_count              => x_msg_count
       ,x_msg_data               => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_Region_Code           := l_Region_Code;
    x_Region_Application_Id := BSC_BIS_KPI_CRUD_PUB.C_BSC_APPLICATION_ID;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        ROLLBACK TO CascadeParamPortlet;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO CascadeParamPortlet;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Create_Parameter_Portlet ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Create_Parameter_Portlet ';
        END IF;
        ROLLBACK TO CascadeParamPortlet;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Create_Parameter_Portlet ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Create_Parameter_Portlet ';
        END IF;
        ROLLBACK TO CascadeParamPortlet;
END Create_Parameter_Portlet;

/*******************************************

********************************************/
-- Get a new region code every time.
FUNCTION Get_New_Region_Code
RETURN VARCHAR2 IS
BEGIN
    RETURN 'BSC_PARAM_'||TO_CHAR(SYSDATE,'J')||ABS(DBMS_UTILITY.GET_TIME);
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_New_Region_Code;


-- Unrolls all the Dimension based region items into the table BIS_AK_REGION_PUB.Bis_Region_Item_Tbl_Type
-- for any given region_code, this API all
PROCEDURE Unroll_RegionItems_Into_Record (
     p_Region_Code            IN AK_REGIONS.REGION_CODE%TYPE
   , p_Region_Application_Id  IN AK_REGIONS.REGION_APPLICATION_ID%TYPE
   , x_Region_Item_Tbl        OUT NOCOPY BIS_AK_REGION_PUB.Bis_Region_Item_Tbl_Type
) IS

    CURSOR c_Get_Nested_Region_Items IS
        SELECT  A.NESTED_REGION_CODE
               ,A.NESTED_REGION_APPLICATION_ID
        FROM    AK_REGION_ITEMS A
        WHERE   A.REGION_CODE           = p_Region_Code
        AND     A.REGION_APPLICATION_ID = p_Region_Application_Id
        AND     A.ITEM_STYLE            = BIS_AK_REGION_PUB.c_NESTED_REGION_STYLE
        ORDER BY A.DISPLAY_SEQUENCE;

    l_Region_Item_Tbl  BIS_AK_REGION_PUB.Bis_Region_Item_Tbl_Type;
    l_Display_Sequence NUMBER;
    l_Count            NUMBER;
BEGIN
    l_Display_Sequence := 10;
    l_Count            := 0;

    -- Get the items from nested region_items
    FOR cGNRI IN c_Get_Nested_Region_Items LOOP
        BSC_BIS_KPI_CRUD_PUB.Get_Non_Nested_Into_Rec (
             p_Region_Code            => cGNRI.NESTED_REGION_CODE
           , p_Region_Application_Id  => cGNRI.NESTED_REGION_APPLICATION_ID
           , x_Region_Item_Tbl        => l_Region_Item_Tbl
        );

        FOR i IN 1..l_Region_Item_Tbl.COUNT LOOP
            x_Region_Item_Tbl(l_Count+i) :=  l_Region_Item_Tbl(i);
            x_Region_Item_Tbl(l_Count+i).Display_Sequence := l_Display_Sequence;
            l_Display_Sequence := l_Display_Sequence + 10;
        END LOOP;

        l_Count := x_Region_Item_Tbl.COUNT;
    END LOOP;

    BSC_BIS_KPI_CRUD_PUB.Get_Non_Nested_Into_Rec (
         p_Region_Code            => p_Region_Code
       , p_Region_Application_Id  => p_Region_Application_Id
       , x_Region_Item_Tbl        => l_Region_Item_Tbl
    );

    FOR i IN 1..l_Region_Item_Tbl.COUNT LOOP
        x_Region_Item_Tbl(l_Count+i) :=  l_Region_Item_Tbl(i);
        x_Region_Item_Tbl(l_Count+i).Display_Sequence := l_Display_Sequence;
        l_Display_Sequence := l_Display_Sequence + 10;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        NULL;
END Unroll_RegionItems_Into_Record;

-- gets all the region items into the PL/SQL table BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type
PROCEDURE Get_Non_Nested_Into_Rec (
     p_Region_Code            IN AK_REGIONS.REGION_CODE%TYPE
   , p_Region_Application_Id  IN AK_REGIONS.REGION_APPLICATION_ID%TYPE
   , x_Region_Item_Tbl        OUT NOCOPY BIS_AK_REGION_PUB.Bis_Region_Item_Tbl_Type
) IS
    CURSOR c_NonNested IS
        SELECT
          AV.REGION_APPLICATION_ID
        , AV.REGION_CODE
        , AV.ATTRIBUTE_APPLICATION_ID
        , AV.ATTRIBUTE_CODE
        , AV.DISPLAY_SEQUENCE
        , AV.NODE_DISPLAY_FLAG
        , AV.REQUIRED_FLAG
        , AV.NODE_QUERY_FLAG
        , AV.DISPLAY_VALUE_LENGTH
        , AV.ATTRIBUTE_LABEL_LONG
        , AV.ORDER_SEQUENCE
        , AV.INITIAL_SORT_SEQUENCE
        , AV.ORDER_DIRECTION
        , AV.URL
        , AV.ATTRIBUTE1
        , AV.ATTRIBUTE2
        , AV.ATTRIBUTE3
        , AV.ATTRIBUTE4
        , AV.ATTRIBUTE5
        , AV.ATTRIBUTE6
        , AV.ATTRIBUTE7
        , AV.ATTRIBUTE8
        , AV.ATTRIBUTE9
        , AV.ATTRIBUTE10
        , AV.ATTRIBUTE11
        , AV.ATTRIBUTE12
        , AV.ATTRIBUTE13
        , AV.ATTRIBUTE14
        , AV.ATTRIBUTE15
       FROM  AK_REGION_ITEMS_VL AV
       WHERE AV.ITEM_STYLE            <> BIS_AK_REGION_PUB.c_NESTED_REGION_STYLE
       AND   AV.REGION_CODE           = p_Region_Code
       AND   AV.REGION_APPLICATION_ID = p_Region_Application_Id
       AND   AV.ATTRIBUTE1  IN ('DIMENSION LEVEL',
                                  'DIM LEVEL SINGLE VALUE',
                                  'DIMENSION VALUE',
                                  'HIDE_VIEW_BY',
                                  'HIDE_VIEW_BY_SINGLE',
                                  'HIDE PARAMETER',
                                  'VIEWBY PARAMETER',
                                  'HIDE_DIM_LVL',
                                  'HIDE DIMENSION LEVEL',
                                  'HIDE VIEW BY DIMENSION',
                                  'HIDE_VIEW_BY_DIM_SINGLE')
       ORDER BY AV.DISPLAY_SEQUENCE;


    iCount NUMBER;
BEGIN
    iCount := 1;
    FOR cNN IN c_NonNested LOOP
        x_Region_Item_Tbl(iCount).Attribute_Code            :=   cNN.ATTRIBUTE_CODE;
        x_Region_Item_Tbl(iCount).Attribute_Application_Id  :=   cNN.ATTRIBUTE_APPLICATION_ID;
        x_Region_Item_Tbl(iCount).Display_Sequence          :=   cNN.DISPLAY_SEQUENCE;
        x_Region_Item_Tbl(iCount).Node_Display_Flag         :=   cNN.NODE_DISPLAY_FLAG;
        x_Region_Item_Tbl(iCount).Required_Flag             :=   cNN.REQUIRED_FLAG;
        x_Region_Item_Tbl(iCount).Queryable_Flag            :=   cNN.NODE_QUERY_FLAG;
        x_Region_Item_Tbl(iCount).Display_Length            :=   cNN.DISPLAY_VALUE_LENGTH;
        x_Region_Item_Tbl(iCount).Long_Label                :=   cNN.ATTRIBUTE_LABEL_LONG;
        x_Region_Item_Tbl(iCount).Sort_Sequence             :=   cNN.ORDER_SEQUENCE;
        x_Region_Item_Tbl(iCount).Initial_Sort_Sequence     :=   cNN.INITIAL_SORT_SEQUENCE;
        x_Region_Item_Tbl(iCount).Sort_Direction            :=   cNN.ORDER_DIRECTION;
        x_Region_Item_Tbl(iCount).Url                       :=   cNN.URL;
        x_Region_Item_Tbl(iCount).Attribute_Type            :=   cNN.ATTRIBUTE1;
        x_Region_Item_Tbl(iCount).Display_Format            :=   cNN.ATTRIBUTE7;
        x_Region_Item_Tbl(iCount).Display_Type              :=   cNN.ATTRIBUTE14;
        x_Region_Item_Tbl(iCount).Measure_Level             :=   cNN.ATTRIBUTE2;
        x_Region_Item_Tbl(iCount).Base_Column               :=   cNN.ATTRIBUTE3;
        x_Region_Item_Tbl(iCount).Lov_Where_Clause          :=   cNN.ATTRIBUTE4;
        x_Region_Item_Tbl(iCount).Graph_Position            :=   cNN.ATTRIBUTE5;
        x_Region_Item_Tbl(iCount).Graph_Style               :=   cNN.ATTRIBUTE6;
        x_Region_Item_Tbl(iCount).Lov_Table                 :=   cNN.ATTRIBUTE15;
        x_Region_Item_Tbl(iCount).Aggregate_Function        :=   cNN.ATTRIBUTE9;
        x_Region_Item_Tbl(iCount).Display_Total             :=   cNN.ATTRIBUTE10;
        x_Region_Item_Tbl(iCount).Variance                  :=   cNN.ATTRIBUTE13;
        x_Region_Item_Tbl(iCount).Schedule                  :=   cNN.ATTRIBUTE8;
        x_Region_Item_Tbl(iCount).Override_Hierarchy        :=   cNN.ATTRIBUTE11;

        iCount := iCount + 1;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        NULL;
END Get_Non_Nested_Into_Rec;

-- Returns the Dimension Object group created for this Dashboard.
FUNCTION Get_Param_Portlet_By_Dashboard (
    p_Page_Function_Name IN VARCHAR2
) RETURN VARCHAR2 IS
    l_Region_Code BSC_SYS_DIM_GROUPS_VL.SHORT_NAME%TYPE;
BEGIN
    SELECT G.SHORT_NAME INTO l_Region_Code
    FROM   BSC_KPIS_B            K,
           BSC_KPI_DIM_GROUPS    KG,
           BSC_SYS_DIM_GROUPS_VL G
    WHERE K.SHORT_NAME  = p_Page_Function_Name
    AND KG.INDICATOR    = K.INDICATOR
    AND G.DIM_GROUP_ID  = KG.DIM_GROUP_ID;

    RETURN l_Region_Code;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Param_Portlet_By_Dashboard;

/*******************************************
Added the following API for dynamic
parameter portlet creation logic as required
by Bug#4558279
** END **
********************************************/

-- Added for Bug#4638384, returns the Compare To attribute code
FUNCTION Get_Compare_Attribute_Code (
     p_Region_Code IN VARCHAR2
   , p_Measure_Short_Name IN VARCHAR2
) RETURN VARCHAR2 IS
    l_Attribute_Code AK_REGION_ITEMS.ATTRIBUTE_CODE%TYPE;
BEGIN
    l_Attribute_Code := NULL;

    SELECT R.ATTRIBUTE_CODE INTO l_Attribute_Code
    FROM   AK_REGION_ITEMS  R
    WHERE  R.ATTRIBUTE1  = C_COMPARE_ATTRIBURE_TYPE
    AND    R.ATTRIBUTE2  = Get_Attribute_Code_For_Measure(p_Region_Code, p_Measure_Short_Name)
    AND    R.REGION_CODE = p_Region_Code;

    RETURN l_Attribute_Code;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Compare_Attribute_Code;


-- Added for Bug#4638384
FUNCTION Get_Comparison_Source (
  p_Measures_Short_Name IN VARCHAR2
) RETURN VARCHAR2
IS
  l_Comparison_Source BIS_INDICATORS.COMPARISON_SOURCE%TYPE;
BEGIN

  l_Comparison_Source := NULL;

  SELECT B.COMPARISON_SOURCE
  INTO   l_Comparison_Source
  FROM   BIS_INDICATORS B
  WHERE  B.SHORT_NAME = p_Measures_Short_Name;

  -- Invalid Data sources should be returned as NULL (so that they are updatable)
  IF ((BSC_BIS_KPI_CRUD_PUB.Get_Objective_By_AGKpi(p_Measures_Short_Name) = BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY)
       AND Get_Measure_Source(p_Measures_Short_Name) <> BSC_BIS_MEASURE_PUB.c_PMF) THEN
    RETURN NULL;
  ELSE
    RETURN l_Comparison_Source;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     RETURN l_Comparison_Source;
END Get_Comparison_Source;


PROCEDURE Migrate_AGR_To_PLSQL (
      p_Commit                      IN VARCHAR := FND_API.G_FALSE
    , p_Region_Application_Id       IN VARCHAR2
    , p_Region_Code                 IN VARCHAR2
    , p_Update_AK_Metadata          IN VARCHAR2
    , p_Plsql_For_Report_Query      IN VARCHAR2
    , p_Old_Attribute_Code_App_Ids  IN VARCHAR2
    , p_Old_Attribute_Codes         IN VARCHAR2
    , p_New_Attribute_Code_App_Ids  IN VARCHAR2
    , p_New_Attribute_Codes         IN VARCHAR2
    , x_Return_Status           OUT NOCOPY VARCHAR
    , x_Msg_Count               OUT NOCOPY NUMBER
    , x_Msg_Data                OUT NOCOPY VARCHAR
) IS
    l_Old_Attribute_Code_App_Ids   BSC_UTILITY.Varchar_Tabletype;
    l_Old_Attribute_Codes          BSC_UTILITY.Varchar_Tabletype;
    l_New_Attribute_Code_App_Ids   BSC_UTILITY.Varchar_Tabletype;
    l_New_Attribute_Codes          BSC_UTILITY.Varchar_Tabletype;
    l_Count_Old_App_Ids            NUMBER;
    l_Count_Old_Attribute_Codes    NUMBER;
    l_Count_New_App_Ids            NUMBER;
    l_Count_New_Attribute_Codes    NUMBER;
    l_Delete_Measure               VARCHAR2(1);
    l_Delete_Dimensions            VARCHAR2(1);

    l_report_region_rec            BIS_AK_REGION_PUB.Bis_Region_Rec_Type;

BEGIN
    SAVEPOINT MigrateAGRTOPLSQL1;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    --DBMS_OUTPUT.PUT_LINE(' Line 2 ');
    l_Delete_Measure    := FND_API.G_FALSE;
    l_Delete_Dimensions := FND_API.G_FALSE;

    BSC_BIS_KPI_CRUD_PUB.Delete_AG_Bsc_Metadata (
      p_Commit            => p_Commit
    , p_Region_Code       => p_Region_Code
    , p_Delete_Measures   => l_Delete_Measure
    , p_Delete_Dimensions => l_Delete_Dimensions
    , x_Return_Status     => x_Return_Status
    , x_Msg_Count         => x_Msg_Count
    , x_Msg_Data          => x_Msg_Data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- extended the condition for measures too for Bug#4958056 - for Cascade_Attr_Code_Into_Measure
    IF (p_Update_AK_Metadata = FND_API.G_TRUE) THEN
        l_report_region_rec.Region_Code            := p_Region_Code;
        l_report_region_rec.Region_Name            := BIS_COMMON_UTILS.G_DEF_CHAR;
        l_report_region_rec.Region_Description     := BIS_COMMON_UTILS.G_DEF_CHAR;
        l_report_region_rec.Region_Application_Id  := p_Region_Application_Id;
        l_report_region_rec.Database_Object_Name   := BIS_COMMON_UTILS.G_DEF_CHAR;
        l_report_region_rec.Region_Style           := BIS_COMMON_UTILS.G_DEF_CHAR;
        l_report_region_rec.Region_Object_Type     := BIS_COMMON_UTILS.G_DEF_CHAR;
        l_report_region_rec.Help_Target            := BIS_COMMON_UTILS.G_DEF_CHAR;
        l_report_region_rec.Display_Rows           := BIS_COMMON_UTILS.G_DEF_NUM;
        l_report_region_rec.Disable_View_By        := BIS_COMMON_UTILS.G_DEF_CHAR;
        l_report_region_rec.No_Of_Portlet_Rows     := BIS_COMMON_UTILS.G_DEF_NUM;
        l_report_region_rec.Schedule               := BIS_COMMON_UTILS.G_DEF_CHAR;
        l_report_region_rec.Header_File_Procedure  := BIS_COMMON_UTILS.G_DEF_CHAR;
        l_report_region_rec.Footer_File_Procedure  := BIS_COMMON_UTILS.G_DEF_CHAR;
        l_report_region_rec.Group_By               := BIS_COMMON_UTILS.G_DEF_CHAR;
        l_report_region_rec.Order_By               := BIS_COMMON_UTILS.G_DEF_CHAR;
        l_report_region_rec.Plsql_For_Report_Query := p_Plsql_For_Report_Query;
        l_report_region_rec.Display_Subtotals      := BIS_COMMON_UTILS.G_DEF_CHAR;
        l_report_region_rec.Data_Source            := BSC_BIS_KPI_CRUD_PUB.C_PLSQL_SOURCE;
        l_report_region_rec.Where_Clause           := BIS_COMMON_UTILS.G_DEF_CHAR;
        l_report_region_rec.Dimension_Group        := BIS_COMMON_UTILS.G_DEF_CHAR;
        l_report_region_rec.Parameter_Layout       := BIS_COMMON_UTILS.G_DEF_CHAR;
        l_report_region_rec.Kpi_Id                 := BIS_COMMON_UTILS.G_DEF_NUM;
        l_report_region_rec.Analysis_Option_Id     := BIS_COMMON_UTILS.G_DEF_NUM;
        l_report_region_rec.Dim_Set_Id             := BIS_COMMON_UTILS.G_DEF_NUM;

        BIS_PMV_REGION_PVT.UPDATE_REGION
        (
            p_commit                 => p_Commit
           ,p_Report_Region_Rec      => l_report_region_rec
           ,x_return_status          => x_return_status
           ,x_msg_count              => x_msg_count
           ,x_msg_data               => x_msg_data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        BSC_BIS_KPI_CRUD_PUB.Cascade_Attr_Code_Into_Measure (
              p_Commit                      => p_Commit
            , p_Region_Code                 => p_Region_Code
            , p_Region_Application_Id       => p_Region_Application_Id
            , p_Old_Attribute_Codes         => p_Old_Attribute_Codes
            , p_Old_Attribute_Code_App_Ids  => p_Old_Attribute_Code_App_Ids
            , p_New_Attribute_Codes         => p_New_Attribute_Codes
            , p_New_Attribute_Code_App_Ids  => p_New_Attribute_Code_App_Ids
            , x_Return_Status               => x_Return_Status
            , x_Msg_Count                   => x_Msg_Count
            , x_Msg_Data                    => x_Msg_Data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO MigrateAGRTOPLSQL1;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO MigrateAGRTOPLSQL1;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO MigrateAGRTOPLSQL1;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Migrate_AGR_To_PLSQL ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Migrate_AGR_To_PLSQL ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO MigrateAGRTOPLSQL1;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Migrate_AGR_To_PLSQL ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Migrate_AGR_To_PLSQL ';
        END IF;
END Migrate_AGR_To_PLSQL;


/*
    Trimmed down remove BSC Metadata only.

    NOTE: This API has been designed only to delete BSC Metadata and
          in no way modified/delete's AK Metadata.
*/

PROCEDURE Migrate_AGR_To_PLSQL (
      p_Commit                      IN VARCHAR := FND_API.G_FALSE
    , p_Region_Application_Id       IN VARCHAR2
    , p_Region_Code                 IN VARCHAR2
    , x_Return_Status           OUT NOCOPY VARCHAR
    , x_Msg_Count               OUT NOCOPY NUMBER
    , x_Msg_Data                OUT NOCOPY VARCHAR
) IS
BEGIN
    SAVEPOINT MigrateAGRTOPLSQL;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    BSC_BIS_KPI_CRUD_PUB.Migrate_AGR_To_PLSQL (
          p_Commit                     => p_Commit
        , p_Region_Application_Id      => p_Region_Application_Id
        , p_Region_Code                => p_Region_Code
        , p_Update_AK_Metadata         => FND_API.G_FALSE
        , p_Plsql_For_Report_Query     => NULL
        , p_Old_Attribute_Code_App_Ids => NULL
        , p_Old_Attribute_Codes        => NULL
        , p_New_Attribute_Code_App_Ids => NULL
        , p_New_Attribute_Codes        => NULL
        , x_Return_Status              => x_Return_Status
        , x_Msg_Count                  => x_Msg_Count
        , x_Msg_Data                   => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO MigrateAGRTOPLSQL;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO MigrateAGRTOPLSQL;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO MigrateAGRTOPLSQL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Migrate_AGR_To_PLSQL ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Migrate_AGR_To_PLSQL ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO MigrateAGRTOPLSQL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Migrate_AGR_To_PLSQL ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Migrate_AGR_To_PLSQL ';
        END IF;
END Migrate_AGR_To_PLSQL;


-- needs to be moved into an utility file.
FUNCTION Is_Primary_Source_Of_Measure (
      p_Measure_Short_Name IN VARCHAR2
    , p_Region_Code        IN VARCHAR2
) RETURN VARCHAR2 IS
    l_Region_Code         AK_REGIONS.REGION_CODE%TYPE;
    l_Actual_Data_Source  BIS_INDICATORS.ACTUAL_DATA_SOURCE%TYPE;
    l_Return              VARCHAR2(1);
BEGIN
    l_Return := FND_API.G_FALSE;

    l_Actual_Data_Source := BSC_BIS_KPI_CRUD_PUB.Get_Actual_Source_Data(p_Measure_Short_Name);
    IF((l_Actual_Data_Source IS NOT NULL) AND (p_Region_Code IS NOT NULL)) THEN
        l_Region_Code := SUBSTR(l_Actual_Data_Source, 1, INSTR(l_Actual_Data_Source, '.')-1);

        IF ((l_Region_Code IS NOT NULL) AND (l_Region_Code = p_Region_Code)) THEN
            l_Return := FND_API.G_TRUE;
        END IF;
    END IF;

    RETURN l_Return;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Is_Primary_Source_Of_Measure;

/*
  Provide WARNING notes - and usage guide.
*/

PROCEDURE Cascade_Attr_Code_Into_Measure (
      p_Commit                      IN VARCHAR := FND_API.G_FALSE
    , p_Region_Code                 IN VARCHAR2
    , p_Region_Application_Id       IN VARCHAR2
    , p_Old_Attribute_Codes         IN VARCHAR2
    , p_Old_Attribute_Code_App_Ids  IN VARCHAR2
    , p_New_Attribute_Codes         IN VARCHAR2
    , p_New_Attribute_Code_App_Ids  IN VARCHAR2
    , x_Return_Status           OUT NOCOPY VARCHAR
    , x_Msg_Count               OUT NOCOPY NUMBER
    , x_Msg_Data                OUT NOCOPY VARCHAR
) IS

    l_Measure_Short_Name  BIS_INDICATORS.SHORT_NAME%TYPE;
    l_Measure_Attr_Code   AK_REGION_ITEMS.ATTRIBUTE_CODE%TYPE;
    l_Compare_Attr_Code   AK_REGION_ITEMS.ATTRIBUTE_CODE%TYPE;

    l_Actual_Data_Source_Type   BIS_INDICATORS.ACTUAL_DATA_SOURCE_TYPE%TYPE;
    l_Actual_Data_Source        BIS_INDICATORS.ACTUAL_DATA_SOURCE%TYPE;
    l_Function_Name             BIS_INDICATORS.FUNCTION_NAME%TYPE;
    l_Enable_Link               BIS_INDICATORS.ENABLE_LINK%TYPE;
    l_Comparison_Source         BIS_INDICATORS.COMPARISON_SOURCE%TYPE;


    CURSOR cMeasureShortNames IS
        SELECT   AK.ATTRIBUTE_CODE
               , AK.ATTRIBUTE2
        FROM     AK_REGION_ITEMS AK
        WHERE    AK.REGION_CODE           = p_Region_Code
        AND      AK.REGION_APPLICATION_ID = p_Region_Application_Id
        AND      AK.ATTRIBUTE1 IN ('BUCKET_MEASURE', 'MEASURE', 'MEASURE_NOTARGET', 'SUB MEASURE')
        ORDER BY AK.DISPLAY_SEQUENCE;

    CURSOR cMeasureProperties IS
        SELECT   BIS.ACTUAL_DATA_SOURCE_TYPE
               , BIS.ACTUAL_DATA_SOURCE
               , BIS.FUNCTION_NAME
               , BIS.COMPARISON_SOURCE
               , BIS.ENABLE_LINK
        FROM  BIS_INDICATORS BIS
        WHERE BIS.SHORT_NAME = l_Measure_Short_Name;
BEGIN

    SAVEPOINT CascdAttrCode;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    FOR cMSN IN cMeasureShortNames LOOP
        l_Measure_Short_Name := cMSN.ATTRIBUTE2;
        l_Measure_Attr_Code  := cMSN.ATTRIBUTE_CODE;
        l_Compare_Attr_Code  := BSC_BIS_KPI_CRUD_PUB.Get_Compare_Attribute_Code(p_Region_Code, l_Measure_Short_Name);

        IF (BSC_UTILITY.Is_Measure_Seeded(l_Measure_Short_Name) = FND_API.G_FALSE AND
            BSC_BIS_KPI_CRUD_PUB.Is_Primary_Source_Of_Measure(l_Measure_Short_Name, p_Region_Code)
            = FND_API.G_FALSE) THEN

            FOR cMP IN cMeasureProperties LOOP
                l_Actual_Data_Source_Type := cMP.ACTUAL_DATA_SOURCE_TYPE;
                l_Actual_Data_Source      := cMP.ACTUAL_DATA_SOURCE;
                l_Function_Name           := cMP.FUNCTION_NAME;
                l_Enable_Link             := cMP.ENABLE_LINK;
                l_Comparison_Source       := cMP.COMPARISON_SOURCE;
            END LOOP;

            l_Actual_Data_Source := p_Region_Code || '.' || l_Measure_Attr_Code;
            l_Comparison_Source  := p_Region_Code || '.' || l_Compare_Attr_Code;

            BSC_ANALYSIS_OPTION_PVT.Cascade_Data_Src_Values (
                  p_Commit                  => p_Commit
                , p_Measure_Short_Name      => l_Measure_Short_Name
                , p_Empty_Source            => FND_API.G_FALSE
                , p_Actual_Data_Source_Type => l_Actual_Data_Source_Type
                , p_Actual_Data_Source      => l_Actual_Data_Source
                , p_Function_Name           => l_Function_Name
                , p_Enable_Link             => l_Enable_Link
                , p_Comparison_Source       => l_Comparison_Source
                , x_Return_Status           => x_Return_Status
                , x_Msg_Count               => x_Msg_Count
                , x_Msg_Data                => x_Msg_Data
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (Get_Measure_Source(l_Measure_Short_Name) = BSC_BIS_MEASURE_PUB.c_CDS) THEN
                IF ((p_Old_Attribute_Codes IS NOT NULL) AND (p_New_Attribute_Codes IS NOT NULL)) THEN
                    BSC_BIS_KPI_CRUD_PUB.Cascade_Changes_Into_Forumla (
                          p_Commit                      => p_Commit
                        , p_Measure_Short_Name          => l_Measure_Short_Name
                        , p_Old_Attribute_Codes         => p_Old_Attribute_Codes
                        , p_Old_Attribute_Code_App_Ids  => p_Old_Attribute_Code_App_Ids
                        , p_New_Attribute_Codes         => p_New_Attribute_Codes
                        , p_New_Attribute_Code_App_Ids  => p_New_Attribute_Code_App_Ids
                        , x_Return_Status               => x_Return_Status
                        , x_Msg_Count                   => x_Msg_Count
                        , x_Msg_Data                    => x_Msg_Data
                    );
                    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
            END IF;
        END IF;
    END LOOP;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CascdAttrCode;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CascdAttrCode;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CascdAttrCode;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Cascade_Attr_Code_Into_Measure ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Cascade_Attr_Code_Into_Measure ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CascdAttrCode;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Cascade_Attr_Code_Into_Measure ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Cascade_Attr_Code_Into_Measure ';
        END IF;
END Cascade_Attr_Code_Into_Measure;


-- This API will cascade the changes into CDS types of measures
-- whenever there is a change in the ATTRIBUTE_CODE of the Region_Items

PROCEDURE Cascade_Changes_Into_Forumla (
      p_Commit                      IN VARCHAR := FND_API.G_FALSE
    , p_Measure_Short_Name          IN VARCHAR2
    , p_Old_Attribute_Codes         IN VARCHAR2
    , p_Old_Attribute_Code_App_Ids  IN VARCHAR2
    , p_New_Attribute_Codes         IN VARCHAR2
    , p_New_Attribute_Code_App_Ids  IN VARCHAR2
    , x_Return_Status           OUT NOCOPY VARCHAR
    , x_Msg_Count               OUT NOCOPY NUMBER
    , x_Msg_Data                OUT NOCOPY VARCHAR
) IS
    CURSOR c_GetFormula IS
       SELECT
   m.measure_col, m.measure_id
       FROM
   bsc_sys_measures m,
   bsc_sys_datasets_vl d,
   bis_indicators i
       WHERE
   i.dataset_id  = d.dataset_id AND
   d.measure_id1 = m.measure_id AND
   i.short_name  = p_Measure_Short_Name;

    l_Formula                   BSC_SYS_MEASURES.MEASURE_COL%TYPE;
    l_Measure_Id                BSC_SYS_MEASURES.MEASURE_ID%TYPE;
    l_char                      VARCHAR2(1);
    l_Formula_Temp              VARCHAR2(2000);
    l_Comma_Old_Attribute_Codes VARCHAR2(2000);
    l_Comma_New_Attribute_Codes VARCHAR2(2000);
    l_Old_Attribute_Codes       BSC_UTILITY.Varchar_Tabletype;
    l_New_Attribute_Codes       BSC_UTILITY.Varchar_Tabletype;
    l_Count1                    NUMBER;
    l_Count2                    NUMBER;

    l_Dataset_Rec               BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;

BEGIN
    SAVEPOINT CascdAttrCodeIntoForm;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    FOR cForm IN c_GetFormula LOOP
        l_Formula    := cForm.MEASURE_COL;
        l_Measure_Id := cForm.MEASURE_ID;
    END LOOP;

    l_Comma_Old_Attribute_Codes := p_Old_Attribute_Codes;
    l_Comma_New_Attribute_Codes := p_New_Attribute_Codes;

    BSC_UTILITY.Parse_String
    (
       p_List        => l_Comma_Old_Attribute_Codes
     , p_Separator   => ','
     , p_List_Data   => l_Old_Attribute_Codes
     , p_List_number => l_Count1
    );

    BSC_UTILITY.Parse_String
    (
       p_List        => l_Comma_New_Attribute_Codes
     , p_Separator   => ','
     , p_List_Data   => l_New_Attribute_Codes
     , p_List_number => l_Count2
    );

    FOR i IN 1..LENGTH(l_Formula) LOOP
        l_Char := SUBSTR(l_Formula, i, 1);

        IF l_Char IN ('+', '-', '/', '*', '(', ')') THEN
            l_Formula_Temp := l_Formula_Temp || (',' || l_Char || ',');
        ELSIF(l_Char <> ' ') THEN
            l_Formula_Temp := l_Formula_Temp || l_Char;
        END IF;
    END LOOP;

    -- Replace 2 consecutive comma with one, which will
    -- get inserted in cases  like '+(' etc.
    l_Formula_Temp := ',' ||REPLACE(l_Formula_Temp, ',,', ',') || ',';

    FOR i IN 1..l_Count1 LOOP
        l_Formula_Temp := REPLACE(l_Formula_Temp,
                                  ',' ||l_Old_Attribute_Codes(i)||',',
                                  ',' ||l_New_Attribute_Codes(i)||','
                          );

    END LOOP;

    --DBMS_OUTPUT.PUT_LINE (' l_Formula_Temp      - ' || l_Formula_Temp);

    l_Formula_Temp := REPLACE (l_Formula_Temp, ',', '');
    --DBMS_OUTPUT.PUT_LINE (' l_Formula_Temp      - ' || l_Formula_Temp);


    -- after fixing the the Measure formula, update the measure using
    -- the private method - which exclusively updates BSC_SYS_MEASURES

    l_Dataset_Rec.Bsc_Measure_Id  := l_Measure_Id;
    l_Dataset_Rec.Bsc_Measure_Col := l_Formula_Temp;

    BSC_DATASETS_PVT.Update_Measures(
      p_commit        => p_commit
     ,p_Dataset_Rec   => l_Dataset_Rec
     ,x_return_status => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CascdAttrCodeIntoForm;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CascdAttrCodeIntoForm;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CascdAttrCodeIntoForm;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Cascade_Changes_Into_Forumla ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Cascade_Changes_Into_Forumla ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CascdAttrCodeIntoForm;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Cascade_Changes_Into_Forumla ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Cascade_Changes_Into_Forumla ';
        END IF;
END Cascade_Changes_Into_Forumla;


-- added for Bug#4923006
FUNCTION Is_Dim_Associated_To_Objective (
     p_Dimension_Short_Name IN VARCHAR2
   , p_Kpi_Id               IN NUMBER
) RETURN VARCHAR2 IS
    l_Count NUMBER;

BEGIN

    SELECT COUNT(1) INTO l_Count
    FROM   BSC_KPIS_B            K
         , BSC_KPI_DIM_GROUPS    KG
         , BSC_SYS_DIM_GROUPS_VL G
    WHERE
             K.INDICATOR     = p_Kpi_Id
         AND G.SHORT_NAME    = p_Dimension_Short_Name
         AND KG.INDICATOR    = K.INDICATOR
         AND KG.DIM_GROUP_ID = G.DIM_GROUP_ID;


    IF (l_Count = 0) THEN
        RETURN FND_API.G_FALSE;
    ELSE
        RETURN FND_API.G_TRUE;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Is_Dim_Associated_To_Objective;

-- Wrapper added for Bug#4932280
PROCEDURE Delete_AG_Bsc_Metadata (
      p_Commit                   IN VARCHAR2 := FND_API.G_FALSE
    , p_Region_Code              IN VARCHAR2
    , p_Delete_Measures          IN VARCHAR2
    , x_Return_Status    OUT NOCOPY VARCHAR
    , x_Msg_Count        OUT NOCOPY NUMBER
    , x_Msg_Data         OUT NOCOPY VARCHAR
) IS
BEGIN

    BSC_BIS_KPI_CRUD_PUB.Delete_AG_Bsc_Metadata (
          p_Commit             => p_Commit
        , p_Region_Code        => p_Region_Code
        , p_Delete_Measures    => p_Delete_Measures
        , p_Delete_Dimensions  => FND_API.G_TRUE
        , x_Return_Status      => x_Return_Status
        , x_Msg_Count          => x_Msg_Count
        , x_Msg_Data           => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Delete_AG_Bsc_Metadata ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Delete_AG_Bsc_Metadata ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Delete_AG_Bsc_Metadata ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Delete_AG_Bsc_Metadata ';
        END IF;
END Delete_AG_Bsc_Metadata;

--
--Wrapper added for bug#4741919
--Wrapper is required to call Rearrange_Data_Series API
--which will reset all the measures to the next datasource or null.
PROCEDURE Delete_AG_Report (
      p_Commit                   IN VARCHAR2 := FND_API.G_FALSE
    , p_Region_Code              IN VARCHAR2
    , p_Delete_Measures          IN VARCHAR2
    , x_Return_Status    OUT NOCOPY VARCHAR
    , x_Msg_Count        OUT NOCOPY NUMBER
    , x_Msg_Data         OUT NOCOPY VARCHAR
)
IS
     l_Kpi_Id             NUMBER;
BEGIN
     SAVEPOINT DelAGRep;
     FND_MSG_PUB.Initialize;
     x_return_status :=  FND_API.G_RET_STS_SUCCESS;

     l_Kpi_Id := BSC_BIS_KPI_CRUD_PUB.Get_Kpi_Id(p_Region_Code);
     IF (l_Kpi_Id = BSC_BIS_KPI_CRUD_PUB.C_INVALID_ENTITY) THEN
       FND_MESSAGE.SET_NAME('BSC','BSC_SETUP_REPORT_DEF');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     BSC_ANALYSIS_OPTION_PUB.Rearrange_Data_Series(
          p_commit            => FND_API.G_FALSE
         ,p_Kpi_Id            => l_Kpi_Id
         ,p_option_group0     => 0
         ,p_option_group1     => 0
         ,p_option_group2     => 0
         ,p_Measure_Seq       => NULL
         ,p_add_flag          => FND_API.G_TRUE
         ,p_remove_flag       => FND_API.G_TRUE
         ,x_return_status     => x_return_status
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
      );
      IF ((x_Return_Status IS NOT NULL) AND (x_Return_Status <> FND_API.G_RET_STS_SUCCESS)) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     BSC_BIS_KPI_CRUD_PUB.Delete_AG_Bsc_Metadata (
         p_Commit            => FND_API.G_FALSE
        ,p_Region_Code       => p_Region_Code
        ,p_Delete_Measures   => p_Delete_Measures
        ,x_return_status     => x_return_status
        ,x_msg_count         => x_msg_count
        ,x_msg_data          => x_msg_data
     );

     IF ((x_return_status IS NOT NULL) AND (x_return_status <> FND_API.G_RET_STS_SUCCESS)) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Delete_AG_Report ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Delete_AG_Report ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Delete_AG_Report ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Delete_AG_Report ';
        END IF;
END Delete_AG_Report;


-- Added from Enhancement Number#4952167
PROCEDURE Migrate_AGR_To_VBR (
      p_Commit                      IN VARCHAR2 := FND_API.G_FALSE
    , p_Region_Application_Id       IN VARCHAR2
    , p_Region_Code                 IN VARCHAR2
    , x_Return_Status           OUT NOCOPY VARCHAR
    , x_Msg_Count               OUT NOCOPY NUMBER
    , x_Msg_Data                OUT NOCOPY VARCHAR
) IS
    l_Delete_Measure               VARCHAR2(1);
    l_Delete_Dimensions            VARCHAR2(1);
BEGIN
    SAVEPOINT MigrateAGRTOVBR;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    l_Delete_Measure    := FND_API.G_FALSE;
    l_Delete_Dimensions := FND_API.G_FALSE;

    BSC_BIS_KPI_CRUD_PUB.Delete_AG_Bsc_Metadata (
      p_Commit            => p_Commit
    , p_Region_Code       => p_Region_Code
    , p_Delete_Measures   => l_Delete_Measure
    , p_Delete_Dimensions => l_Delete_Dimensions
    , x_Return_Status     => x_Return_Status
    , x_Msg_Count         => x_Msg_Count
    , x_Msg_Data          => x_Msg_Data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO MigrateAGRTOVBR;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO MigrateAGRTOVBR;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO MigrateAGRTOVBR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Migrate_AGR_To_VBR ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Migrate_AGR_To_VBR ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO MigrateAGRTOVBR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Migrate_AGR_To_VBR ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Migrate_AGR_To_VBR ';
        END IF;
END Migrate_AGR_To_VBR;


-- Added from Enhancement Number#4952167
PROCEDURE Migrate_To_Existing_Source (
      p_Commit                      IN VARCHAR2 := FND_API.G_FALSE
    , p_Existing_Report_Type        IN VARCHAR2
    , p_Region_Application_Id       IN VARCHAR2
    , p_Region_Code                 IN VARCHAR2
    , x_Return_Status           OUT NOCOPY VARCHAR
    , x_Msg_Count               OUT NOCOPY NUMBER
    , x_Msg_Data                OUT NOCOPY VARCHAR
) IS
BEGIN
    SAVEPOINT MigrateAGRTOEXTNSRC;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    IF (p_Existing_Report_Type = BSC_BIS_KPI_CRUD_PUB.C_PLSQL_BASED_REPORT_TYPE) THEN
        BSC_BIS_KPI_CRUD_PUB.Migrate_AGR_To_PLSQL (
              p_Commit                 => p_Commit
            , p_Region_Application_Id  => p_Region_Application_Id
            , p_Region_Code            => p_Region_Code
            , x_Return_Status          => x_Return_Status
            , x_Msg_Count              => x_Msg_Count
            , x_Msg_Data               => x_Msg_Data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSIF (p_Existing_Report_Type = BSC_BIS_KPI_CRUD_PUB.C_VIEW_BASED_REPORT_TYPE) THEN
        BSC_BIS_KPI_CRUD_PUB.Migrate_AGR_To_VBR (
              p_Commit                 => p_Commit
            , p_Region_Application_Id  => p_Region_Application_Id
            , p_Region_Code            => p_Region_Code
            , x_Return_Status          => x_Return_Status
            , x_Msg_Count              => x_Msg_Count
            , x_Msg_Data               => x_Msg_Data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO MigrateAGRTOEXTNSRC;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO MigrateAGRTOEXTNSRC;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO MigrateAGRTOEXTNSRC;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Migrate_To_Existing_Source ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Migrate_To_Existing_Source ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO MigrateAGRTOEXTNSRC;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Migrate_To_Existing_Source ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Migrate_To_Existing_Source ';
        END IF;
END Migrate_To_Existing_Source;

/*
Added this API for Bug#4249900

This API will return a list of Objectives, which uses the DImension created for
this report (p_region_code).
*/

PROCEDURE Get_Obj_By_Dim_Region_Code (
     p_Region_Code           IN VARCHAR2
   , p_Region_Application_Id IN NUMBER
   , p_Production_Only       IN VARCHAR2
   , x_Return_Status         OUT NOCOPY   VARCHAR2
   , x_Msg_Count             OUT NOCOPY   NUMBER
   , x_Msg_Data              OUT NOCOPY   VARCHAR2
) IS
    CURSOR c_Objective_List IS
        SELECT KP.NAME || '[' || KP.INDICATOR || ']' NAME
        FROM   BSC_SYS_DIM_GROUPS_VL GP,
               BSC_KPI_DIM_GROUPS    KG,
               BSC_KPIS_VL           KP
        WHERE  GP.SHORT_NAME   = p_Region_Code
        AND    KG.DIM_GROUP_ID = GP.DIM_GROUP_ID
        AND    KP.INDICATOR    = KG.INDICATOR
        AND    KP.PROTOTYPE_FLAG >= 0
        AND    KP.PROTOTYPE_FLAG <= DECODE(p_Production_Only, 'T', 0, 7);
BEGIN
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    FOR cOL IN c_Objective_List LOOP
        IF(x_Msg_Data IS NULL) THEN
            x_Msg_Data := cOL.NAME;
        ELSE
            x_Msg_Data := x_Msg_Data || ',' || cOL.NAME;
        END IF;
    END LOOP;

    IF (x_Msg_Data IS NULL) THEN
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
END Get_Obj_By_Dim_Region_Code;


-- This API will take the Region Code and try to cascase it to the pl/sql layer.
-- and hence will ensure that whenever the parameter section is changed for the report, the
-- same structure is passed down the Dimension/Objective entities.

PROCEDURE Cascade_Dimension_By_Region (
     p_Commit                IN VARCHAR2
   , p_Region_Code           IN VARCHAR2
   , p_Region_Application_Id IN NUMBER
   , p_Force_Change          IN VARCHAR2
   , x_Return_Status         OUT NOCOPY   VARCHAR2
   , x_Msg_Count             OUT NOCOPY   NUMBER
   , x_Msg_Data              OUT NOCOPY   VARCHAR2
) IS
    l_Kpi_Id                          BSC_KPIS_B.INDICATOR%TYPE;
    x_Non_Time_Dimension_Groups       BSC_VARCHAR2_TBL_TYPE;
    x_Non_Time_Dimension_Objects      BSC_VARCHAR2_TBL_TYPE;
    x_Non_Time_Dim_Obj_Short_Names    VARCHAR2(2056);
    x_Time_Dimension_Groups           BSC_VARCHAR2_TBL_TYPE;
    x_Time_Dimension_Objects          BSC_VARCHAR2_TBL_TYPE;
    x_Time_Dim_Obj_Short_Names        VARCHAR2(2056);
    x_All_Dim_Group_Ids               BSC_NUMBER_TBL_TYPE;
    x_Non_Time_Counter                NUMBER;
    x_Time_Counter                    NUMBER;
    l_Is_XTD_Enabled                  VARCHAR2(1);

    CURSOR c_Objective_List IS
        SELECT KP.INDICATOR
        FROM   BSC_SYS_DIM_GROUPS_VL GP,
               BSC_KPI_DIM_GROUPS    KG,
               BSC_KPIS_VL           KP
        WHERE  GP.SHORT_NAME   = p_Region_Code
        AND    KG.DIM_GROUP_ID = GP.DIM_GROUP_ID
        AND    KP.INDICATOR    = KG.INDICATOR;
BEGIN

    SAVEPOINT CascadeDimByRegion;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;


    FOR cOL IN c_Objective_List LOOP
        l_Kpi_Id := cOL.INDICATOR;

        BSC_BIS_KPI_CRUD_PUB.Get_Dim_Info_From_Region_Code(
              p_Param_Portlet_Region_Code    => p_Region_Code
            , x_Non_Time_Dimension_Groups    => x_Non_Time_Dimension_Groups
            , x_Non_Time_Dimension_Objects   => x_Non_Time_Dimension_Objects
            , x_Non_Time_Dim_Obj_Short_Names => x_Non_Time_Dim_Obj_Short_Names
            , x_All_Dim_Group_Ids            => x_All_Dim_Group_Ids
            , x_Non_Time_Counter             => x_Non_Time_Counter
            , x_Time_Dimension_Groups        => x_Time_Dimension_Groups
            , x_Time_Dimension_Objects       => x_Time_Dimension_Objects
            , x_Time_Dim_Obj_Short_Names     => x_Time_Dim_Obj_Short_Names
            , x_Time_Counter                 => x_Time_Counter
            , x_Msg_Data                     => x_Msg_Data
        );

        l_Is_XTD_Enabled := BSC_BIS_KPI_CRUD_PUB.is_XTD_Enabled(p_Region_Code);
        IF ((Has_Time_Dim_Obj_Changed(x_Time_Dim_Obj_Short_Names, l_Kpi_Id, l_Is_XTD_Enabled) = FND_API.G_TRUE) OR
            (p_Force_Change = FND_API.G_TRUE)) THEN
          BSC_BIS_KPI_CRUD_PUB.Assign_KPI_Periodicities(
                p_Commit            => p_Commit
               ,p_Kpi_Id            => l_Kpi_Id
               ,p_Time_Dim_Obj_Sns  => x_Time_Dim_Obj_Short_Names
               ,p_Dft_Dim_Obj_Sn    => NULL
               ,p_Daily_Flag        => l_Is_XTD_Enabled
               ,p_Is_XTD_Enabled    => l_Is_XTD_Enabled
               ,x_Return_Status     => x_Return_Status
               ,x_Msg_Count         => x_Msg_Count
               ,x_Msg_Data          => x_Msg_Data
          );
          IF (x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

        IF ((Has_Non_Time_Dim_Obj_Changed(x_Non_Time_Dim_Obj_Short_Names, l_Kpi_Id)= FND_API.G_TRUE) OR
            (p_Force_Change = FND_API.G_TRUE)) THEN
          BSC_BIS_DIMENSION_PUB.Update_Dimension
          (       p_commit                => p_Commit
              ,   p_dim_short_name        => p_Region_Code
              ,   p_display_name          => p_Region_Code
              ,   p_description           => p_Region_Code
              ,   p_application_id        => p_Region_Application_Id
              ,   p_dim_obj_short_names   => x_Non_Time_Dim_Obj_Short_Names
              ,   p_time_stamp            => NULL
              ,   x_return_status         => x_Return_Status
              ,   x_msg_count             => x_Msg_Count
              ,   x_msg_data              => x_Msg_Data
          );
          IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
    END LOOP;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        ROLLBACK TO CascadeDimByRegion;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO CascadeDimByRegion;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Cascade_Dimension_By_Region ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Cascade_Dimension_By_Region ';
        END IF;
        ROLLBACK TO CascadeDimByRegion;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_CRUD_PUB.Cascade_Dimension_By_Region ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_CRUD_PUB.Cascade_Dimension_By_Region ';
        END IF;
        ROLLBACK TO CascadeDimByRegion;
END Cascade_Dimension_By_Region;

PROCEDURE Get_Global_Menu_Title (
      p_Region_code         IN VARCHAR2
    , p_Region_Application_Id IN NUMBER
    , x_Global_Menu           OUT NOCOPY VARCHAR2
    , x_Global_Title          OUT NOCOPY VARCHAR2
) IS
BEGIN
  BEGIN
      SELECT attribute19, attribute20
      INTO   x_Global_Menu, x_Global_Title
      FROM   bis_ak_region_extension
      WHERE  region_code = p_Region_Code AND region_application_id = p_Region_Application_Id;
  EXCEPTION
     WHEN OTHERS THEN
      x_Global_Menu := NULL;
      x_Global_Title := NULL;
  END;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END Get_Global_Menu_Title;
--

/***************************************
   Overloaded for Simulation Designer in which the user
   can choose the objective group and the scorecard card to which
   he wants to add the simulation
/***************************************/

PROCEDURE Create_Bsc_Bis_Metadata(
      p_Commit                      IN VARCHAR2
    , p_Create_Region_Per_Ao        IN VARCHAR2
    , p_Param_Portlet_Region_Code   IN VARCHAR2
    , p_Page_Function_Name          IN VARCHAR2
    , p_Kpi_Portlet_Function_Name   IN VARCHAR2
    , p_Region_Function_Name        IN VARCHAR2    -- added for AGRD
    , p_Region_User_Function_Name   IN VARCHAR2    -- added for AGRD
    , p_Dim_Obj_Short_Names         IN VARCHAR2    -- added for AGRD
    , p_Force_Create_Dim            IN VARCHAR2    -- added for AGRD
    , p_Measure_Short_Name          IN VARCHAR2    -- added for AGRD
    , p_Responsibility_Id           IN NUMBER
    , p_Measure_Name                IN VARCHAR2
    , p_Measure_Description         IN VARCHAR2
    , p_Dataset_Format_Id           IN NUMBER
    , p_Dataset_Autoscale_Flag      IN NUMBER
    , p_Measure_Operation           IN VARCHAR2
    , p_Measure_Increase_In_Measure IN VARCHAR2
    , p_Measure_Obsolete            IN VARCHAR2 := FND_API.G_FALSE
    , p_Type                        IN VARCHAR2-- This is used for weighted kpis,This can take values CDS_SCORE,CDS_PERF or Null
    , p_Measure_Random_Style        IN NUMBER
    , p_Measure_Min_Act_Value       IN NUMBER
    , p_Measure_Max_Act_Value       IN NUMBER
    , p_Measure_Type                IN NUMBER
    , p_Measure_App_Id              IN NUMBER := NULL
    , p_Func_Area_Short_Name        IN VARCHAR2 := NULL
    , x_Measure_Short_Name          OUT NOCOPY   VARCHAR2
    , x_Kpi_Id                      OUT NOCOPY   NUMBER
    , x_Return_Status               OUT NOCOPY   VARCHAR2
    , x_Msg_Count                   OUT NOCOPY   NUMBER
    , x_Msg_Data                    OUT NOCOPY   VARCHAR2
 )IS
 BEGIN
     BSC_BIS_KPI_CRUD_PUB.Create_Bsc_Bis_Metadata(
           p_Commit                      =>  p_Commit
         , p_Create_Region_Per_Ao        =>  p_Create_Region_Per_Ao
         , p_Param_Portlet_Region_Code   =>  p_Param_Portlet_Region_Code
         , p_Page_Function_Name          =>  p_Page_Function_Name
         , p_Kpi_Portlet_Function_Name   =>  p_Kpi_Portlet_Function_Name
         , p_Region_Function_Name        =>  p_Region_Function_Name
         , p_Region_User_Function_Name   =>  p_Region_User_Function_Name
         , p_Dim_Obj_Short_Names         =>  p_Dim_Obj_Short_Names
         , p_Force_Create_Dim            =>  p_Force_Create_Dim
         , p_Measure_Short_Name          =>  p_Measure_Short_Name
         , p_Responsibility_Id           =>  p_Responsibility_Id
         , p_Measure_Name                =>  p_Measure_Name
         , p_Measure_Description         =>  p_Measure_Description
         , p_Dataset_Format_Id           =>  p_Dataset_Format_Id
         , p_Dataset_Autoscale_Flag      =>  p_Dataset_Autoscale_Flag
         , p_Measure_Operation           =>  p_Measure_Operation
         , p_Measure_Increase_In_Measure =>  p_Measure_Increase_In_Measure
         , p_Measure_Obsolete            =>  p_Measure_Obsolete
         , p_Type                        =>  p_Type
         , p_Measure_Random_Style        =>  p_Measure_Random_Style
         , p_Measure_Min_Act_Value       =>  p_Measure_Min_Act_Value
         , p_Measure_Max_Act_Value       =>  p_Measure_Max_Act_Value
         , p_Measure_Type                =>  p_Measure_Type
         , p_Measure_App_Id              =>  p_Measure_App_Id
         , p_Func_Area_Short_Name        =>  p_Func_Area_Short_Name
         , p_Obj_Grp_Id                  =>  NULL
         , p_Obj_Tab_Id                  =>  NULL
         , p_Obj_Type                    =>  BSC_BIS_KPI_CRUD_PUB.C_MULTI_BAR_INDICATOR
         , x_Measure_Short_Name          =>  x_Measure_Short_Name
         , x_Kpi_Id                      =>  x_Kpi_Id
         , x_Return_Status               =>  x_Return_Status
         , x_Msg_Count                   =>  x_Msg_Count
         , x_Msg_Data                    =>  x_Msg_Data
         );

END Create_Bsc_Bis_Metadata;


FUNCTION Get_Tab_Name
(
  p_tab_id NUMBER
)
RETURN VARCHAR2 IS
   l_tab_name     BSC_TABS_VL.name%TYPE;
BEGIN
   IF(p_tab_id IS NOT NULL)THEN

    SELECT name
    INTO   l_tab_name
    FROM   bsc_tabs_vl
    WHERE  tab_id = p_tab_id;

   END IF;
   RETURN l_tab_name;
END  Get_Tab_Name;

FUNCTION Get_Objective_Group_Name
(
  p_obj_grp_id NUMBER
)
RETURN VARCHAR2 IS
   l_obj_grp_name     BSC_TAB_IND_GROUPS_VL.name%TYPE;
BEGIN
   IF(p_obj_grp_id IS NOT NULL)THEN

    SELECT name
    INTO   l_obj_grp_name
    FROM   bsc_tab_ind_groups_vl
    WHERE  ind_group_id = p_obj_grp_id
    AND    tab_id = -1;

   END IF;
   RETURN l_obj_grp_name;
END   Get_Objective_Group_Name;



FUNCTION Generate_Unique_Region_Code
RETURN VARCHAR2 IS
l_region_code    VARCHAR2(100);

BEGIN

  SELECT BSC_BIS_KPI_CRUD_PUB.C_PMD || TO_CHAR(SYSDATE,'ddmmyyhh24miss')
  INTO   l_region_code
  FROM   dual;
  RETURN  l_region_code;

END Generate_Unique_Region_Code;


PROCEDURE Get_Non_Time_Dim_And_DimObjs
(
  p_region_code           IN         AK_REGIONS.region_code%TYPE
 ,x_non_time_dim_dimObjs  OUT NOCOPY BSC_VARCHAR2_TBL_TYPE
 ,x_non_time_counter      OUT NOCOPY NUMBER
) IS

l_attribute2     AK_REGION_ITEMS_VL.attribute2%TYPE;
l_displayseq     AK_REGION_ITEMS_VL.display_sequence%TYPE;
l_dim            VARCHAR2(1000);

CURSOR c_dim_dimObj IS
SELECT   DISTINCT a.attribute2, a.display_sequence
FROM     ak_region_items a
WHERE    a.region_code = p_region_code
AND      ATTRIBUTE1  IN ('DIMENSION LEVEL',
            'DIM LEVEL SINGLE VALUE',
            'DIMENSION VALUE',
            'HIDE_VIEW_BY',
            'HIDE_VIEW_BY_SINGLE',
            'HIDE PARAMETER',
            'VIEWBY PARAMETER',
            'HIDE_DIM_LVL',
            'HIDE DIMENSION LEVEL',
            'HIDE VIEW BY DIMENSION',
            'HIDE_VIEW_BY_DIM_SINGLE')
AND      a.attribute2 LIKE '%+%'
AND      a.attribute2  NOT LIKE 'TIME_COMPARISON_TYPE%'
ORDER BY a.display_sequence;

BEGIN
   x_non_time_counter :=0;
   IF(p_region_code IS NOT NULL) THEN
    FOR cd IN c_dim_dimObj LOOP
       l_attribute2 := cd.attribute2;
       l_dim := SUBSTR(l_attribute2, 1, INSTR(l_attribute2,'+')-1);
       IF((l_dim <> BSC_BIS_KPI_CRUD_PUB.c_oltp_time) AND
          (l_dim <> BSC_BIS_KPI_CRUD_PUB.c_edw_time) AND
            (BSC_BIS_KPI_CRUD_PUB.Is_Dimension_Calendar(l_dim) <> FND_API.G_TRUE)) THEN
           x_non_time_counter:=x_non_time_counter + 1;
           x_non_time_dim_dimObjs(x_non_time_counter) := l_attribute2;
       END IF;
    END LOOP;
   END IF;
EXCEPTION
 WHEN OTHERS THEN
   x_non_time_counter :=0;
END Get_Non_Time_Dim_And_DimObjs;


END BSC_BIS_KPI_CRUD_PUB;

/
