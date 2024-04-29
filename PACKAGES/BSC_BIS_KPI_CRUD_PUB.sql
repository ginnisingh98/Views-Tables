--------------------------------------------------------
--  DDL for Package BSC_BIS_KPI_CRUD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_BIS_KPI_CRUD_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCCRUDS.pls 120.26 2007/10/09 12:59:30 bijain ship $ */

/*REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCCRUDS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper API for KPI CRUD                                  |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |     15-APR-04    akchan   Created.                                    |
REM |     23-APR-04    adrao   Added Update/Delete  APIs                    |
REM |     07-MAY-04    adrao   Modified CRUD APIs to handle 1 Dimension     |
REM |                          per Analysis Option                          |
REM |     11-MAY-04    adrao   KPI End-to-end Phase II: Modified CRUD APIs  |
REM |                          to add Parameter Portlet Region Code as an   |
REM |                          nested region item and not add Dimension     |
REM |                          Level region items.                          |
REM |     14-MAY-04    adrao   Added 2 additional regions/analysis options  |
REM |     20-MAY-04    adrao   Added the Create_Dimension API               |
REM |     26-MAY-04    akchan  Removed method Create_PPX_Region_Item()      |
REM |                          Added constant for String "MEASURE_NOTARGET" |
REM |     27-MAY-04    adrao   Modularized all CRUD APIs                    |
REM |     04-JUN-04    adrao   Added Autofactoring for Meaaure,  Compare To |
REM |     10-JUN-04    adrao   Added C_NO_PROJECTION to disable Projection  |
REM |     14-JUN-04    adrao   Added APIs to check for Time Dimension Objs  |
REM |     18-JUN-04    adrao   Added C_FORMAT_POINTER for Bug#3701687       |
REM |     18-JUN-04    adrao   Added API Get_Next_Region_Code_By_AO for     |
REM |                          Enh#3691035                                  |
REM |     15-JUL-04    adrao   Fixed Bug#3766839 to get KPI_ID from         |
REM |                          measure short_name instead of Page Function  |
REM |     19-JUL-04    adrao   added API is_XTD_Enabled for                 |
REM |                          Bug#3767168 for Paramter Portlets            |
REM |     21-JUL-04    adrao   added API Get_S2EObjective_With_XTD for      |
REM |                          Bug#3780082                                  |
REM |     22-JUL-04    adrao   Fixed Bug#3770986 (please see bug)           |
REM |     04-AUG-04    adrao   Added API Populate_DBI_Calendar()            |
REM |                          for Bug#3809721                              |
REM |     11-AUG-04    adrao   Added API Get_Region_Codes_By_Short_Name     |
REM |                          for Bug#3777647                              |
REM |     18-AUG-04    adrao   Added API Check_XTD_Summarization() for      |
REM |                          Bug#3831859                                  |
REM |     02-SEP-04    adrao   Added API Get_Kpi_Details for Bug#3814292    |
REM |     09-SEP-04    adrao   Added API Get_Change_Disp_Type_By_Mask() for |
REM |                          Bug#3876413                                  |
REM |     20-SEP-04    ankgoel Added Get_Pmf_Metadata_By_Objective for      |
REM |                          Bug#3759819                                  |
REM |     27-SEP-04    ankgoel Added constant C_AK_DATASOURCE for bug#3916377
REM |     29-SEP-04    adrao   Added constants C_CHANGE_TYPE_INTEGER and    |
REM |                          C_CHANGE_TYPE_PERCENT for Bug#3919666        |
REM |     30-SEP-04   rpenneru Added Get_S2ESCR_DeleteMessage,              |
REM |                           , Delete_S2E_Metadata for bug#3893949       |
REM |     05-OCT-04   ankgoel  Bug#3933075 Moved Get_Pmf_Metadata_By_Objective
REM |                          and C_AK_DATASOURCE to BSCCSUBB.pls. Moved   |
REM |                          C_BSC_UNDERSCORE to BSCUTILB.pls.            |
REN |     06-OCT-04   adrao    Fixed Bug#3935595                            |
REM |     21-DEC-04   adrao    Modified for 8i compatibility, Bug#4079898   |
REN |     27-DEC-04   adrao    Moved DIMOBJ_SHORT_NAME_CLASS to BSCPMFWB    |
REM |     08-FEB-05   visuri   added Has_Compare_To_Or_Plan() for Enh.      |
REM |                          4065089                                      |
REM |     08-FEB-05   visuri   added constants :C_BIS_APPLICATION_ID,       |
REM |                          C_DAILY_PERIOD_ATTR_CODE,C_HIDE_PARAMETER,   |
REM |                          C_DAILY_PERIOD_ATTR2 for enh. 4065098        |
REM |     22-FEB-05   adrao   Autogenerated Measures Enhancement for Report |
REM |                         Designer                                      |
REM |     07-MAR-05   vtulasi Added procedure Get_Dep_Obj_Func_Name         |
REM |                         for bug# 3786130                              |
REM |     21-Feb-05   rpenneru Enh#4059160, Add FA as property to Custom KPIs|
REM |     10-MAR-05   adrao   added API Convert_AutoGen_To_ViewBased for    |
REM |                         Convert AGR to VBR enhancement.               |
REM |     18-MAR-05   adrao   Made modification to ensure Duplication of    |
REM |                         reports and added a few util APIs             |
REM |     22-APR-05 akoduri   Enhancement#3865711 -- Obsolete Seeded Objects|
REM |     04-MAY-05   adrao   Added constant C_DEFAULT_MEASURE_GROUP_ID     |
REM |     03-MAY-2005  akoduri  Enh #4268374 -- Weighted Average Measures   |
REM |     11-MAY-2005  adrao   Created the following APIs for               |
REM |                         selective cascading of Dimensions and Measures|
REM |                               Has_Measure_Column_Changed              |
REM |                               Has_Time_Dim_Obj_Changed                |
REM |                               Has_Non_Time_Dim_Obj_Changed            |
REM |     08-jul-2005  ASHANKAR   added the method is_Scorecard_From_Reports|
REM |                             and CONSTANT C_BISVIEWER_SHOWREPORT       |
REM |     02-JUN-2005  adrao  Added APIs for Calendar Enhancement (4376162) |
REM |     13-JUL-2005  adrao  Enabled addition of Time based Periodicities  |
REM |                         in the Calendar+Periodicity format #4376162   |
REM |     15-JUL-2005  akoduri  Provided warning messasges for strucutural |
REM |                          and color changes #4492177                   |
REM |     04-AUG-2005  adrao  Fixed Bug#4520525                             |
REM |     16-AUG-2005  akoduri  Bug#4482355   Removing attribute_code and   |
REM |                            attribute2 dependency in Report Designer   |
REM |     07-SEP-2005  adrao  Implemented dynamic Parameter Portlet builder |
REM |                         as required by Bug#4558279                    |
REM |     30-SEP-2005 adrao   Fixed Bug#4638384 added API                   |
REM |                         Get_Compare_Attribute_Code ()                 |
REM |     07-NOV-2005 arhegde bug# 4720781 c_bisreportpg constant added     |
REM |     25-DEC-2005 adrao   Added APIs following APIs for Enh#3909868     |
REM |                           - Migrate_AGR_To_PLSQL                      |
REM |                           - Is_Primary_Source_Of_Measure              |
REM |                           - Cascade_Attr_Code_Into_Measure            |
REM |                           - Cascade_Changes_Into_Forumla              |
REM |     03-JAN-2005 adrao   Added API for Is_Dim_Associated_To_Objective()|
REM |                         for Bug#4923006                               |
REM |     06-JAN-2006 akoduri  Enh#4739401 - Hide Dimensions/Dim Objects    |
REM |     17-JAN-2006 rpenneru bug#4741919 - added  Delete_AG_Report        |
REM |                          for AG report deletion                       |
REM |     19-JAN-2006 adrao    Added API Migrate_To_Existing_Source() for   |
REM |                          Enhancement#4952167                          |
REM |     07-FEB-2006 hengliu  Bug#4955493 - Not overwrite global menu/title|
REM |     07-FEB-2006 ppandey  Bug#4771854 - Rolling Periods for AG         |
REM |     09-feb-2007 ashankar Simulation Tree Enhacement 5386112           |
REM +=======================================================================+ */


C_SINGLE_BAR_INDICATOR         CONSTANT NUMBER := 1;
C_MULTI_BAR_INDICATOR          CONSTANT NUMBER := 10;
C_SIMULATION_INDICATOR         CONSTANT NUMBER := 7;

C_NORMAL_INDICATOR_CONFIG_TYPE CONSTANT NUMBER := 1;
C_SIM_INDICATOR_CONFIG_TYPE    CONSTANT NUMBER := 7;

C_BSC_APPLICATION_ID           CONSTANT NUMBER := 271;
C_BIS_APPLICATION_ID           CONSTANT NUMBER := 191;

C_BSC_SOURCE                   CONSTANT VARCHAR2(16) :=  'BSC_DATA_SOURCE';

c_oltp_time                    CONSTANT VARCHAR2(5)  := 'TIME';
c_edw_time                     CONSTANT VARCHAR2(11) := 'EDW_TIME_M';
C_TIME_COMPARISON              CONSTANT VARCHAR2(21) := 'TIME_COMPARISON_TYPE';
C_BISVIEWER_SHOWREPORT         CONSTANT VARCHAR2(21) := 'BISVIEWER.SHOWREPORT';
c_bisreportpg                  CONSTANT VARCHAR2(70) := 'OA.jsp?page=/oracle/apps/bis/report/webui/BISReportPG';

c_measure_group_id_error       CONSTANT NUMBER := -999;

C_COMPARISON_APPEND_STRING     CONSTANT VARCHAR2(2) := '_B';
C_CHANGE_APPEND_STRING         CONSTANT VARCHAR2(2) := '_C';

C_CHANGE_ATTRIBURE_TYPE        CONSTANT VARCHAR2(24) := 'CHANGE_MEASURE_NO_TARGET';
C_COMPARE_ATTRIBURE_TYPE       CONSTANT VARCHAR2(28) := 'COMPARE_TO_MEASURE_NO_TARGET';

C_DAILY_PERIOD_ATTR_CODE       CONSTANT VARCHAR2(12) := 'FII_TIME_DAY';
C_HIDE_PARAMETER               CONSTANT VARCHAR2(14) := 'HIDE PARAMETER';
C_DAILY_PERIOD_ATTR2           CONSTANT VARCHAR2(17) := 'TIME+FII_TIME_DAY';

C_GRAND_TOTAL_ACTUAL           CONSTANT VARCHAR2(2) := '_G';
C_GRAND_TOTAL_COMPARE_TO       CONSTANT VARCHAR2(3) := '_G1';
C_COLSPAN                      CONSTANT VARCHAR2(3) := '_CS';

C_GRAND_TOTAL_ATTRIBURE_TYPE   CONSTANT VARCHAR2(24) := 'GRAND_TOTAL';
C_COLUMN_SPAN_ATTRIBURE_TYPE   CONSTANT VARCHAR2(7)  := 'COLSPAN';

C_MEASURE_ATTRIBURE_TYPE       CONSTANT VARCHAR2(16)  := 'MEASURE_NOTARGET';

C_INVALID_ENTITY               CONSTANT NUMBER := -999;

C_AUTOFACTOR_GROUP1            CONSTANT VARCHAR2(2) := 'AU';
C_AUTOFACTOR_GROUP2            CONSTANT VARCHAR2(3) := 'AU1';
C_AUTOFACTOR_GROUP3            CONSTANT VARCHAR2(3) := 'AU2';
C_AUTOFACTOR_GROUP4            CONSTANT VARCHAR2(3) := 'AU3';
C_AUTOFACTOR_GROUP5            CONSTANT VARCHAR2(3) := 'AU4';

C_NO_PROJECTION                CONSTANT NUMBER := 0;

C_CALC_TC                      CONSTANT NUMBER := 3;
C_CALC_GROWTH                  CONSTANT NUMBER := 4;
C_CALC_QTD                     CONSTANT NUMBER := 6;
C_CALC_YDG                     CONSTANT NUMBER := 7;
C_CALC_AVG                     CONSTANT NUMBER := 8;
C_CALC_YYG                     CONSTANT NUMBER := 9;
C_CALC_XTD                     CONSTANT NUMBER := 12;
C_CALC_DV                      CONSTANT NUMBER := 20;

C_ENABLE_CALC_U0               CONSTANT NUMBER := 2;
C_ENABLE_CALC_U1               CONSTANT NUMBER := 2;

C_DISABLE_CALC_U0              CONSTANT NUMBER := 0;
C_DISABLE_CALC_U1              CONSTANT NUMBER := 0;

C_DISABLE_CALC_KPI             CONSTANT NUMBER := 0;
C_ENABLE_CALC_KPI              CONSTANT NUMBER := 1;

C_FORMAT_POINTER               CONSTANT VARCHAR2(2) := 'FP';
C_FORMAT_INTEGER               CONSTANT VARCHAR2(1) := 'I';


-- Added for Bug#3767168
C_AS_OF_DATE                   CONSTANT VARCHAR2(10) := 'AS_OF_DATE';

C_MAX_OBJECTIVES_DISPLAY       CONSTANT NUMBER := 200;

-- Added for Bug#3919666, changed for Bug#3935595 to 2
C_CHANGE_TYPE_INTEGER          CONSTANT NUMBER := 2;
C_CHANGE_TYPE_PERCENT          CONSTANT NUMBER := 1;


-- added for Default Group fix
C_DEFAULT_MEASURE_GROUP_ID     CONSTANT NUMBER := -1;
C_BSC_CHAR_COMMA               CONSTANT VARCHAR2(1) := ',';
C_PLSQL_SOURCE                 CONSTANT VARCHAR2(20) := 'PLSQL_PARAMETERS';


C_PLSQL_BASED_REPORT_TYPE   CONSTANT VARCHAR2(30) := 'PLSQL_REPORT';
C_VIEW_BASED_REPORT_TYPE    CONSTANT VARCHAR2(30) := 'VIEW_REPORT';


G_PKG_NAME CONSTANT VARCHAR2(30):='BSC_BIS_KPI_CRUD_PUB';
C_PMD      CONSTANT VARCHAR2(10):='PMD_';



/******** CONSTANT LIST ********/
-- Added by ADRAO for Constant Class management Bug#3770986
-- define a VARRAY, which will hold the short_names - moved to BSCUTILS.pls

-- Include the list of excluded SHORT_NAMES as CONSTANT VARCHAR2(30), use C_DO as a prefix
C_DO_PLAN_SNAPSHOT            CONSTANT BIS_LEVELS.SHORT_NAME%TYPE := 'PLAN_SNAPSHOT';

-- Defines a list of Short_Names as a part of Global class G_EXCLUDE_DIMOBJ_CLASS
G_EXCLUDE_DIMOBJ_CLASS CONSTANT BSC_PMF_UI_WRAPPER.DIMOBJ_SHORT_NAME_CLASS := BSC_PMF_UI_WRAPPER.DIMOBJ_SHORT_NAME_CLASS (
                                                             C_DO_PLAN_SNAPSHOT
                                                           );

/******** CONSTANT LIST ********/

C_COMP_TO_DIM_LEVEL        CONSTANT VARCHAR2(26) := 'COMPARE TO DIMENSION LEVEL';

--Called by Java API
--------------------------------------------------------------------------------
-- Create BSC KPI with BIS Dimension from start to end.
--
-- Created by: Alex Chan  04/15/2004
--------------------------------------------------------------------------------

TYPE bsc_varchar2_tbl_type IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
TYPE bsc_number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


-- added for Calendar Enh in Report Designer (Enh#4376162)
C_BSC_TIME                     CONSTANT VARCHAR2(8) := 'BSC_TIME';

-- added for Bug#4520525
C_MAX_MESSAGE_SIZE             CONSTANT NUMBER := 1800;

--added constants for Bug#4558279

C_ICX_PROMPTS   CONSTANT VARCHAR2(30) := 'ICX_PROMPTS';
C_TABLE         CONSTANT VARCHAR2(30) := 'TABLE';



PROCEDURE Create_Kpi_End_To_End(
  p_commit                          IN             VARCHAR2 := FND_API.G_FALSE
 ,p_responsibility_id               IN             number
 ,p_create_new_kpi                  IN             VARCHAR2 := FND_API.G_FALSE
 ,p_kpi_id_to_add_measure           IN             VARCHAR2 := NULL
 ,p_param_portlet_region_code       IN             VARCHAR2
 ,p_kpi_name                        IN             VARCHAR2 := NULL
 ,p_kpi_description                 IN             VARCHAR2 := NULL
 ,p_measure_name                    IN             varchar2
 ,p_measure_short_name              IN             varchar2 := NULL
 ,p_measure_description             IN             varchar2 := NULL
 ,p_measure_type                    IN             number := NULL --Activity/Balance
 ,p_measure_operation               IN             varchar2 := BSC_BIS_MEASURE_PUB.c_SUM --Aggregation method
 ,p_dataset_format_id               IN             number := NULL --data format
 ,p_dataset_autoscale_flag          IN             number := NULL  --autoscale flag
 ,p_measure_increase_in_measure     IN             varchar2 := NULL --Measure Improvement
 ,p_measure_random_style            IN             number := NULL --Measure random style
 ,p_measure_min_act_value           IN             number := NULL --min value for actual
 ,p_measure_max_act_value           IN             number := NULL --max value for actual
 ,p_page_function_name              IN             VARCHAR2
 ,p_kpi_portlet_function_name       IN             VARCHAR2
 ,p_Create_Region_Per_AO            IN             VARCHAR2 := FND_API.G_TRUE -- Create a region per analysis option.
 ,p_Measure_App_Id                  IN             NUMBER   := NULL
 ,p_Func_Area_Short_Name            IN             VARCHAR2 := NULL
 ,x_measure_short_name              OUT NOCOPY     VARCHAR2
 ,x_kpi_id                          OUT NOCOPY     number
 ,x_return_status                   OUT NOCOPY     varchar2
 ,x_msg_count                       OUT NOCOPY     number
 ,x_msg_data                        OUT NOCOPY     varchar2
);


PROCEDURE Get_Dim_Info_From_Region_Code(
            p_param_portlet_region_code    IN         VARCHAR2
           ,x_non_time_dimension_groups    OUT NOCOPY bsc_varchar2_tbl_type
           ,x_non_time_dimension_objects   OUT NOCOPY bsc_varchar2_tbl_type
           ,x_non_time_dim_obj_short_names OUT NOCOPY VARCHAR2
           ,x_all_dim_group_ids            OUT NOCOPY bsc_number_tbl_type
           ,x_non_time_counter             OUT NOCOPY NUMBER
           ,x_time_dimension_groups        OUT NOCOPY bsc_varchar2_tbl_type
           ,x_time_dimension_objects       OUT NOCOPY bsc_varchar2_tbl_type
           ,x_time_dim_obj_short_names     OUT NOCOPY VARCHAR2
           ,x_time_counter                 OUT NOCOPY NUMBER
           ,x_msg_data                     OUT NOCOPY VARCHAR2);


PROCEDURE Create_Dim_Level_Region_Item(
      p_commit                               VARCHAR2 := FND_API.G_FALSE
     ,p_non_time_counter                     NUMBER
     ,p_non_time_dimension_objects           bsc_varchar2_tbl_type
     ,p_non_time_dimension_groups            bsc_varchar2_tbl_type
     ,p_time_counter                         NUMBER
     ,p_time_dimension_objects           bsc_varchar2_tbl_type
     ,p_time_dimension_groups            bsc_varchar2_tbl_type
     ,p_kpi_id                               NUMBER
     ,p_Analysis_Option                      NUMBER  := NULL
     ,x_sequence                      IN OUT NOCOPY NUMBER
     ,x_return_status                 OUT    NOCOPY VARCHAR2
     ,x_msg_count                     OUT    NOCOPY NUMBER
     ,x_msg_data                      OUT    NOCOPY VARCHAR2);




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
     ,p_type                          VARCHAR2
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
);


PROCEDURE Associate_KPI_To_AO(
      p_commit                        VARCHAR2 := FND_API.G_FALSE
     ,p_indicator                     NUMBER
     ,p_dataset_id                    NUMBER
     ,p_measure_name                  VARCHAR2
     ,p_measure_description           VARCHAR2
     ,x_measure_short_name            OUT NOCOPY VARCHAR2
     ,x_return_status                 OUT NOCOPY VARCHAR2
     ,x_msg_count                     OUT NOCOPY NUMBER
     ,x_msg_data                      OUT NOCOPY VARCHAR2);


PROCEDURE Create_Measure_Region_Item(
      p_commit                            VARCHAR2 := FND_API.G_FALSE
     ,p_measure_short_name                VARCHAR2
     ,p_sequence_number                   NUMBER
     ,p_kpi_id                            NUMBER
     ,p_Analysis_Option                   NUMBER := NULL
     ,p_dataset_format_id                 NUMBER
     ,p_dataset_autoscale_flag            NUMBER
     ,p_Analysis_Option_Name              VARCHAR2
     ,x_return_status      OUT NOCOPY     varchar2
     ,x_msg_count          OUT NOCOPY     number
     ,x_msg_data           OUT NOCOPY     varchar2
);



FUNCTION Does_Dim_Grp_Exist(p_param_portlet_region_code VARCHAR2) RETURN BOOLEAN;

FUNCTION Does_KPI_Exist(p_portlet_function_name VARCHAR2) RETURN BOOLEAN;


FUNCTION FIND_MAX_SEQ_OF_REGION_ITEM(p_region_code VARCHAR2) RETURN NUMBER;



PROCEDURE RETRIEVE_DIMENSION_OBJECTS(p_region_code                VARCHAR2,
                                     x_dim_obj_list    OUT NOCOPY VARCHAR2,
                                     x_msg_data        OUT NOCOPY VARCHAR2);

FUNCTION GET_TAB_ID(p_page_function_name VARCHAR2) RETURN NUMBER;

FUNCTION GET_GROUP_ID(p_kpi_portlet_function_name VARCHAR2) RETURN NUMBER;

procedure Assign_Kpi_Periodicities(
  p_commit              IN             VARCHAR2 --:= FND_API.G_FALSE
 ,p_kpi_id              IN             NUMBER
 ,p_Time_Dim_obj_sns    IN             VARCHAR2 -- 'MONTH,QUATERLY'
 ,p_Dft_Dim_obj_sn      IN             VARCHAR2 --:= NULL
 ,p_Daily_Flag          IN             VARCHAR2 --:= FND_API.G_FALSE
 ,p_Is_XTD_Enabled      IN             VARCHAR2 -- := 'F' or 'T'
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
);


FUNCTION Is_More( p_dim_short_names IN  OUT NOCOPY  VARCHAR2
              ,   p_dim_name        OUT NOCOPY      VARCHAR2
) RETURN BOOLEAN;




PROCEDURE Update_Actual_Data_Source(
             p_kpi_id               IN NUMBER
           , p_dataset_id           IN NUMBER
           , p_measure_short_name   IN VARCHAR2
           , p_Create_Region_Per_AO IN VARCHAR2 := FND_API.G_FALSE

);



PROCEDURE Update_Dim_Dim_Level_Columns(
        p_dim_object_short_name                  VARCHAR2,
        p_non_time_dimension_objects             bsc_varchar2_tbl_type,
        p_non_time_counter                       NUMBER,
        x_msg_data                    OUT NOCOPY VARCHAR2);


PROCEDURE Update_Kpi_End_To_End(
  p_commit                      IN         VARCHAR2 := FND_API.G_FALSE
 ,p_param_portlet_region_code   IN         VARCHAR2
 ,p_page_function_name          IN         VARCHAR2
 ,p_kpi_portlet_function_name   IN         VARCHAR2
 ,p_measure_name                IN         VARCHAR2
 ,p_measure_short_name          IN         VARCHAR2 := NULL
 ,p_measure_description         IN         VARCHAR2 := NULL
 ,p_measure_type                IN         NUMBER   := NULL --Activity/Balance
 ,p_measure_operation           IN         VARCHAR2 := BSC_BIS_MEASURE_PUB.c_SUM --Aggregation method
 ,p_dataset_format_id           IN         NUMBER   := NULL --data format
 ,p_dataset_autoscale_flag      IN         NUMBER   := NULL  --autoscale flag
 ,p_measure_increase_in_measure IN         VARCHAR2 := NULL --Measure Improve.
 ,p_measure_random_style        IN         NUMBER   := NULL --Measure random style
 ,p_measure_min_act_value       IN         NUMBER   := NULL --min value for actual
 ,p_measure_max_act_value       IN         NUMBER   := NULL --max value for actual
 ,p_Measure_App_Id              IN         NUMBER   := NULL
 ,p_Func_Area_Short_Name        IN         VARCHAR2 := NULL
 ,x_return_status               OUT NOCOPY VARCHAR2
 ,x_msg_count                   OUT NOCOPY NUMBER
 ,x_msg_data                    OUT NOCOPY VARCHAR2
);


PROCEDURE Update_Measure_Region_Item(
      p_commit                   VARCHAR2
      ,p_measure_short_name       VARCHAR2
      ,p_sequence_number          NUMBER
      ,p_kpi_id                   NUMBER
      ,p_Analysis_Option          NUMBER := NULL
      ,p_dataset_format_id        NUMBER
      ,p_dataset_autoscale_flag   NUMBER
      ,p_Analysis_Option_Name     VARCHAR2
      ,x_return_status OUT NOCOPY VARCHAR2
      ,x_msg_count     OUT NOCOPY NUMBER
      ,x_msg_data      OUT NOCOPY VARCHAR2
);


PROCEDURE Delete_Kpi_End_To_End(
  p_commit                      IN         VARCHAR2 := FND_API.G_FALSE
 ,p_param_portlet_region_code   IN         VARCHAR2
 ,p_measure_short_name          IN         VARCHAR2 := NULL
 ,p_page_function_name          IN         VARCHAR2
 ,p_kpi_portlet_function_name   IN         VARCHAR2
 ,x_return_status               OUT NOCOPY VARCHAR2
 ,x_msg_count                   OUT NOCOPY NUMBER
 ,x_msg_data                    OUT NOCOPY VARCHAR2
) ;


PROCEDURE Delete_Measure_Region_Item(
  p_commit                    VARCHAR2 := FND_API.G_FALSE
 ,p_Param_Portlet_Region_Code VARCHAR2
 ,p_Measure_Short_Name        VARCHAR2
 ,p_Application_Id            NUMBER
 ,x_return_status             OUT NOCOPY VARCHAR2
 ,x_msg_count                 OUT NOCOPY NUMBER
 ,x_msg_data                  OUT NOCOPY VARCHAR2
);

PROCEDURE  Unassign_Kpi_Analysis_Option (
  p_Commit         VARCHAR2 := FND_API.G_FALSE
 ,p_Kpi_Id         NUMBER
 ,p_Dataset_Id     NUMBER
 ,x_return_status  OUT NOCOPY VARCHAR2
 ,x_msg_count      OUT NOCOPY NUMBER
 ,x_msg_data       OUT NOCOPY VARCHAR2
);


FUNCTION Get_Num_Measures_By_Kpi(p_Kpi_Id NUMBER) RETURN NUMBER;

FUNCTION Get_Kpi_Id(p_Page_Function_Name VARCHAR2) RETURN NUMBER;

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
     ,x_Msg_Data                      OUT    NOCOPY VARCHAR2
);


FUNCTION Get_Function_Id_By_Name(p_kpi_portlet_function_name VARCHAR2) RETURN NUMBER;

PROCEDURE Update_Kpi_Analysis_Option (
           p_Commit               VARCHAR2 := FND_API.G_FALSE
          ,p_Kpi_Id               NUMBER
          ,p_Dataset_Id           NUMBER
          ,p_Measure_Name         VARCHAR2
          ,p_Measure_Description  VARCHAR2
          ,x_return_status        OUT NOCOPY VARCHAR2
          ,x_msg_count            OUT NOCOPY NUMBER
          ,x_msg_data             OUT NOCOPY VARCHAR2
 );

 FUNCTION Get_Sequence_Id_By_Region(
              p_Region_Code              VARCHAR2
            , p_Region_Application_Id    NUMBER
            , p_Attribute_Code           VARCHAR2
            , p_Attribute_Application_Id NUMBER
)  RETURN NUMBER;


FUNCTION Get_Dataset_Id(
    p_measure_short_name IN VARCHAR2
    ) RETURN NUMBER;

PROCEDURE Get_Page_Name (
          p_Page_Function_Name        IN VARCHAR2
        , p_Kpi_Portlet_Function_Name IN VARCHAR2
        , x_Page_Names                OUT NOCOPY VARCHAR2
);

FUNCTION Get_AO_Id_By_Measure (
            p_Kpi_Id   NUMBER
           ,p_Dataset_Id NUMBER
) RETURN NUMBER ;


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
);

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
);

PROCEDURE Get_KPI_AO_From_Region(
              p_Region_Code             IN         VARCHAR2
            , x_Kpi_Id                  OUT NOCOPY NUMBER
            , x_Analysis_Option_Id      OUT NOCOPY NUMBER
) ;

FUNCTION Has_Region_Per_Measure (
           p_Region_Code IN VARCHAR2
) RETURN BOOLEAN;

FUNCTION is_Valid_Region_Code (
           p_Region_Code IN VARCHAR2
)  RETURN BOOLEAN;

FUNCTION has_Measure_AK_Region (
            p_Kpi_Id   NUMBER
           ,p_Dataset_Id NUMBER
) RETURN BOOLEAN ;

FUNCTION has_Dim_Level (
            p_Region_Code VARCHAR2
) RETURN BOOLEAN;

FUNCTION Get_Region_Application_Id (
            p_Region_Code VARCHAR2
) RETURN NUMBER;


FUNCTION Get_Format_Mask (
          p_Format_Id NUMBER
) RETURN VARCHAR2;

-- Create a nested region for a parameter portlet region code.

PROCEDURE Create_Nested_Region_Item(
      p_commit                       IN VARCHAR2
    , p_Root_AK_Region_Code          IN VARCHAR2
    , p_Param_Portlet_Region_Code    IN VARCHAR2
    , p_sequence_number              IN NUMBER
    , x_return_status                OUT NOCOPY VARCHAR2
    , x_msg_count                    OUT NOCOPY NUMBER
    , x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Nested_Region_Item(
     p_commit                    VARCHAR2 := FND_API.G_FALSE,
     p_Root_AK_Region            VARCHAR2,
     p_Application_Id            NUMBER,
     p_Nested_Region_Code        VARCHAR2,
     x_return_status             OUT NOCOPY VARCHAR2,
     x_msg_count                 OUT NOCOPY NUMBER,
     x_msg_data                  OUT NOCOPY VARCHAR2
);


/*this function will return 'T' if the passed short_name of KPI Group
  is created through KPI End to End module otherwise 'F'
*/
FUNCTION is_KPI_EndToEnd_Group(p_Short_Name VARCHAR2) RETURN VARCHAR2;


/*this function will return 'T' if the passed short_name of KPI
  is created through KPI End to End module otherwise 'F'
*/
FUNCTION is_KPI_EndToEnd_KPI(p_Short_Name VARCHAR2) RETURN VARCHAR2;


/*this function will return 'T' if the passed short_name of Dimension
  is created through KPI End to End module otherwise 'F'
*/
FUNCTION is_KPI_EndToEnd_Dimension(p_Short_Name VARCHAR2) RETURN VARCHAR2;

/*this function will return 'T' if the passed short_name of Dimension Object
  is created through KPI End to End module otherwise 'F'
*/
FUNCTION is_KPI_EndToEnd_DimObject(p_Short_Name VARCHAR2) RETURN VARCHAR2;

FUNCTION is_KPI_EndToEnd_AnaOpt(p_Short_Name VARCHAR2) RETURN VARCHAR2;

-- Gets a unqiue region item Attribute Code.
FUNCTION get_Unique_Attribute_Code (
               p_Region_Code         IN VARCHAR2
             , p_Measure_Short_Name  IN VARCHAR2
             , p_Append_String       IN VARCHAR2
) RETURN VARCHAR2;


FUNCTION get_measure_group_id (p_kpi_portlet_function_name  IN VARCHAR2,
                               x_return_status              OUT NOCOPY VARCHAR2,                               x_msg_data                   OUT NOCOPY VARCHAR2

) RETURN NUMBER;


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
);

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
);


PROCEDURE Delete_Misc_Region_Items(
             p_commit                    VARCHAR2 := FND_API.G_FALSE,
             p_Region_Code               VARCHAR2,
             p_Application_Id            NUMBER,
             x_return_status             OUT NOCOPY VARCHAR2,
             x_msg_count                 OUT NOCOPY NUMBER,
             x_msg_data                  OUT NOCOPY VARCHAR2
);

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
);

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
);


PROCEDURE is_Kpi_In_Production(
               p_Page_Function_Name   IN VARCHAR2
             , x_Is_Kpi_In_Production OUT NOCOPY VARCHAR2
);


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
);

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
);


/*
Added the following parameter for Report Designer

- p_Region_Function_Name        IN VARCHAR2
- p_Region_User_Function_Name   IN VARCHAR2
- p_Dim_Obj_Short_Names         IN NUMBER
- p_Measure_Short_Name          IN NUMBER
*/

PROCEDURE Create_Bsc_Bis_Metadata(
      p_Commit                      IN VARCHAR2
    , p_Create_Region_Per_Ao        IN VARCHAR2
    , p_Param_Portlet_Region_Code   IN VARCHAR2
    , p_Page_Function_Name          IN VARCHAR2
    , p_Kpi_Portlet_Function_Name   IN VARCHAR2
    , p_Region_Function_Name        IN VARCHAR2
    , p_Region_User_Function_Name   IN VARCHAR2
    , p_Dim_Obj_Short_Names         IN VARCHAR2
    , p_Force_Create_Dim            IN VARCHAR2
    , p_Measure_Short_Name          IN VARCHAR2
    , p_Responsibility_Id           IN NUMBER
    , p_Measure_Name                IN VARCHAR2
    , p_Measure_Description         IN VARCHAR2
    , p_Dataset_Format_Id           IN NUMBER
    , p_Dataset_Autoscale_Flag      IN NUMBER
    , p_Measure_Operation           IN VARCHAR2
    , p_Measure_Increase_In_Measure IN VARCHAR2
     ,p_Measure_Obsolete            IN VARCHAR2 := FND_API.G_FALSE
     ,p_Type                        IN VARCHAR2
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
);

PROCEDURE Delete_AK_Metadata(
      p_Commit                     IN VARCHAR2
    , p_Region_Code                IN VARCHAR2
    , p_Region_Code_Application_Id IN NUMBER
    , x_Return_Status              OUT NOCOPY   VARCHAR2
    , x_Msg_Count                  OUT NOCOPY   NUMBER
    , x_Msg_Data                   OUT NOCOPY   VARCHAR2
);

PROCEDURE Referesh_AK_Metadata (
            p_Commit                    IN VARCHAR2
          , p_Kpi_Id                    IN NUMBER
          , p_Deleted_AO_Index          IN NUMBER
          , p_Param_Portlet_Region_Code IN VARCHAR2
          , x_Return_Status             OUT NOCOPY   VARCHAR2
          , x_Msg_Count                 OUT NOCOPY   NUMBER
          , x_Msg_Data                  OUT NOCOPY   VARCHAR2
);

PROCEDURE Apply_Disabled_Calculations (
        p_Commit                    IN VARCHAR2
      , p_Dataset_Id                IN NUMBER
      , x_Return_Status             OUT NOCOPY   VARCHAR2
      , x_Msg_Count                 OUT NOCOPY   NUMBER
      , x_Msg_Data                  OUT NOCOPY   VARCHAR2
);

PROCEDURE Enable_Kpi_Calculation (
        p_Commit                    IN VARCHAR2
      , p_Kpi_Id                    IN NUMBER
      , p_Calculation_Id            IN NUMBER
      , p_Default_Checked           IN NUMBER
      , x_Return_Status             OUT NOCOPY   VARCHAR2
      , x_Msg_Count                 OUT NOCOPY   NUMBER
      , x_Msg_Data                  OUT NOCOPY   VARCHAR2
);

PROCEDURE Get_Dim_Obj_By_Dimension
(
         p_Dim_Short_Name                IN VARCHAR2
       , x_Time_Dim_Obj_Short_Names      OUT NOCOPY VARCHAR2
       , x_Time_Dim_Obj_Counter          OUT NOCOPY NUMBER
       , x_Non_Time_Dim_Obj_Short_Names  OUT NOCOPY VARCHAR2
       , x_Non_Time_Dim_Obj_Counter      OUT NOCOPY NUMBER
       , x_Return_Status                 OUT NOCOPY VARCHAR2
       , x_Msg_Count                     OUT NOCOPY NUMBER
       , x_Msg_Data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Time_Dim_Obj_By_Dim
(
         p_Dim_Short_Name                IN VARCHAR2
       , x_Time_Dim_Obj_Short_Names      OUT NOCOPY VARCHAR2
       , x_Time_Dim_Obj_Counter          OUT NOCOPY NUMBER
       , x_Return_Status                 OUT NOCOPY VARCHAR2
       , x_Msg_Count                     OUT NOCOPY NUMBER
       , x_Msg_Data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Non_Time_Dim_Obj_By_Dim
(
         p_Dim_Short_Name                IN VARCHAR2
       , x_Non_Time_Dim_Obj_Short_Names  OUT NOCOPY VARCHAR2
       , x_Non_Time_Dim_Obj_Counter      OUT NOCOPY NUMBER
       , x_Return_Status                 OUT NOCOPY VARCHAR2
       , x_Msg_Count                     OUT NOCOPY NUMBER
       , x_Msg_Data                      OUT NOCOPY VARCHAR2
);

FUNCTION Is_Time_Dim_Obj (
          p_Dim_Obj_Short_Name IN VARCHAR2
) RETURN VARCHAR2;


PROCEDURE Is_Time_Dim_Obj (
            p_Dim_Obj_Short_Name IN VARCHAR2
          , x_Is_Time_Dim_Obj    OUT NOCOPY VARCHAR2
);

PROCEDURE Is_Time_Dimension (
            p_Dimension_Short_Name IN VARCHAR2
          , x_Is_Time_Dimension    OUT NOCOPY VARCHAR2
);

FUNCTION Get_Next_Region_Code_By_AO (
        p_Kpi_Id           IN NUMBER
      , p_Analysis_Group0  IN NUMBER
)  RETURN VARCHAR2;

FUNCTION Get_Objective_By_Kpi(
            p_Short_Name   IN VARCHAR2
) RETURN VARCHAR2;

-- Gets the parameter portlet associated with the current AK Region.
FUNCTION Get_Param_Portlet_By_Region (
           p_Region_Code IN VARCHAR2
) RETURN VARCHAR2;

-- Checks if AS_OF_DATE is enabled for the Parameter Portlet
FUNCTION  is_XTD_Enabled (
           p_Region_Code IN VARCHAR2
) RETURN VARCHAR2;


FUNCTION  Get_S2EObjective_With_XTD
RETURN VARCHAR2;

-- Returns if the Dimension Object(level) has been excluded from Constant Class
-- BSC_BIS_KPI_CRUD_PUB.G_EXCLUDE_DIMOBJ_CLASS

FUNCTION Is_Excluded_Dimension_Object(
             p_Short_Name  IN VARCHAR2
) RETURN VARCHAR2;

-- Validates of the Start-to-End KPI can be deleted using the Delete button from Update KPI Page.
PROCEDURE Validate_Kpi_Delete
(
         p_Measure_Short_Name            IN  VARCHAR2
       , x_Return_Status                 OUT NOCOPY VARCHAR2
       , x_Msg_Count                     OUT NOCOPY NUMBER
       , x_Msg_Data                      OUT NOCOPY VARCHAR2
);


-- Loads DBI calendar required for Start-to-End KPI.
PROCEDURE Populate_DBI_Calendar
(
         x_Return_Status                 OUT NOCOPY VARCHAR2
       , x_Msg_Count                     OUT NOCOPY NUMBER
       , x_Msg_Data                      OUT NOCOPY VARCHAR2
);

-- added for Bug#3777647
PROCEDURE Get_Region_Codes_By_Short_Name
(
        p_Short_Name    IN VARCHAR
      , x_Region_Codes  OUT NOCOPY VARCHAR2
);

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
);


PROCEDURE Get_Kpi_Details
(
         p_Measure_Short_Name            IN  VARCHAR2
       , x_Kpi_Name                      OUT NOCOPY VARCHAR2
       , x_Report_Code                   OUT NOCOPY VARCHAR2
);

-- added for Bug#3876413
FUNCTION Get_Change_Disp_Type_By_Mask (
          p_Format_Id NUMBER
) RETURN VARCHAR2;


-- added for bug#3893949

PROCEDURE Get_S2ESCR_DeleteMessage(
   p_tabId               IN      number
  ,x_return_status       OUT NOCOPY     varchar2
  ,x_msg_count           OUT NOCOPY     number
  ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_S2E_Metadata(
  p_commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_tab_id              IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);


FUNCTION Has_Compare_To_Or_Plan (p_param_portlet_region_code  IN   VARCHAR2) RETURN BOOLEAN ;

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
);


FUNCTION is_XTD_Enabled (
           p_Time_Dimension_Objects IN BSC_VARCHAR2_TBL_TYPE
) RETURN VARCHAR2;


/*
 Refresh the AK/BSC/BIS Metadata
*/

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
);

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
);

FUNCTION Get_DS_Sequence_From_AK (
      p_Region_Code     IN VARCHAR2
    , p_Kpi_Id          IN VARCHAR2
) RETURN VARCHAR2;



FUNCTION Get_Data_Series_Id(
     p_Kpi_Id     IN NUMBER
   , p_Dataset_Id IN NUMBER
) RETURN NUMBER;


PROCEDURE Get_Dep_Obj_Func_Name( p_dep_object_name               IN      VARCHAR2
                 ,p_dep_object_type              IN      VARCHAR2
                 ,p_object_type                  IN      VARCHAR2
                 ,x_ret_status                   OUT     NOCOPY  VARCHAR2
                     ,x_mesg_data                    OUT     NOCOPY  VARCHAR2
                );


FUNCTION Get_Objective_By_AGKpi( p_Short_Name   IN VARCHAR2) RETURN VARCHAR2;

--IF AG Report is NOT in Production Mode
PROCEDURE Convert_AutoGen_To_ViewBased (
      p_Commit                 IN VARCHAR2 := FND_API.G_FALSE
    , p_Region_Code            IN VARCHAR2
    , p_Region_Application_Id  IN NUMBER
    , x_Return_Status          OUT NOCOPY VARCHAR
    , x_Msg_Count              OUT NOCOPY NUMBER
    , x_Msg_Data               OUT NOCOPY VARCHAR
);


PROCEDURE Delete_AG_Bsc_Metadata (
      p_Commit                   IN VARCHAR2 := FND_API.G_FALSE
    , p_Region_Code              IN VARCHAR2
    , p_Delete_Measures          IN VARCHAR2
    , p_Delete_Dimensions        IN VARCHAR2
    , x_Return_Status    OUT NOCOPY VARCHAR
    , x_Msg_Count        OUT NOCOPY NUMBER
    , x_Msg_Data         OUT NOCOPY VARCHAR
);

-- added for Bug#4932280
PROCEDURE Delete_AG_Bsc_Metadata (
      p_Commit                   IN VARCHAR2 := FND_API.G_FALSE
    , p_Region_Code              IN VARCHAR2
    , p_Delete_Measures          IN VARCHAR2
    , x_Return_Status    OUT NOCOPY VARCHAR
    , x_Msg_Count        OUT NOCOPY NUMBER
    , x_Msg_Data         OUT NOCOPY VARCHAR
);


PROCEDURE Switch_Measure_Type (
      p_Commit                     IN VARCHAR2 := FND_API.G_FALSE
    , p_Measure_Short_Name         IN VARCHAR2
    , p_Target_Source              IN VARCHAR2
    , p_Delete_Columns             IN VARCHAR2
    , p_Clean_Measure_Date_Source  IN VARCHAR2
    , x_Return_Status              OUT NOCOPY VARCHAR
    , x_Msg_Count                  OUT NOCOPY NUMBER
    , x_Msg_Data                   OUT NOCOPY VARCHAR
);

FUNCTION Get_Measure_Source (
   p_Measure_Short_Name IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION Get_Actual_Source_Data (
  p_Measures_Short_Name IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION Get_Measure_Function_Name (
  p_Measures_Short_Name IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION Get_Actual_Source_Data_Type (
  p_Measures_Short_Name IN VARCHAR2
) RETURN VARCHAR2;


-- API added for Bug#4339686
FUNCTION is_Scorecard_From_AG_Report (
  p_Tab_id IN NUMBER
) RETURN VARCHAR2;

FUNCTION Has_Non_Time_Dim_Obj_Changed (
     p_Non_Time_Dim_Objects IN VARCHAR2
   , p_Kpi_Id               IN NUMBER
) RETURN VARCHAR2;

FUNCTION Has_Time_Dim_Obj_Changed (
     p_Time_Dim_Objects IN VARCHAR2
   , p_Kpi_Id           IN NUMBER
   , p_Is_Xtd           IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION Has_Measure_Column_Changed (
     p_Measure_Short_Names IN VARCHAR2
   , p_Kpi_id              IN NUMBER
) RETURN VARCHAR2;


PROCEDURE Delete_Tab_And_TabViews
(
      p_commit         IN         VARCHAR2 := FND_API.G_FALSE
    , p_region_code    IN         AK_REGION_ITEMS.region_code%TYPE
    , x_Return_Status  OUT NOCOPY VARCHAR2
    , x_Msg_Count      OUT NOCOPY NUMBER
    , x_Msg_Data       OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Measures_From_CustomView
(
      p_region_code       IN            AK_REGION_ITEMS.region_code%TYPE
    , p_region_app_id     IN            AK_REGION_ITEMS.region_application_id%TYPE
    , x_has_cust_view     OUT NOCOPY    VARCHAR2
    , x_meas_sht_names    OUT NOCOPY    VARCHAR2
    , x_scorecard_id      OUT NOCOPY    NUMBER
    , x_tabview_id        OUT NOCOPY    NUMBER
   -- , x_last_update_date  OUT NOCOPY    VARCHAR
    , x_return_status     OUT NOCOPY    VARCHAR2
    , x_msg_count         OUT NOCOPY    NUMBER
    , x_msg_data          OUT NOCOPY    VARCHAR2
);

FUNCTION is_Scorecard_From_Reports (
   p_tab_sht_name    IN   BSC_TABS_B.short_name%TYPE
) RETURN VARCHAR2;


-- Check if the Dimension Object is a BSC periodicity
FUNCTION Is_DimObj_Periodicity(
     p_Short_NAme IN VARCHAR2
) RETURN VARCHAR2;

-- This API is similar to BSC_DBI_CALENDAR.get_bsc_Periodicity,
-- except that it queries directly from the BSC_SYS_PERIODICITIES table
PROCEDURE Get_Non_DBI_Periodicities (
      p_Time_Short_Name     IN VARCHAR2
    , x_Periodicity_Id      OUT NOCOPY VARCHAR2
    , x_Calendar_Id         OUT NOCOPY VARCHAR2
    , x_Return_Status       OUT NOCOPY VARCHAR
    , x_Msg_Count           OUT NOCOPY NUMBER
    , x_Msg_Data            OUT NOCOPY VARCHAR
);

FUNCTION Is_Dimension_Calendar(
     p_Short_Name IN VARCHAR2
) RETURN VARCHAR2;

PROCEDURE Is_Struct_Change_For_AG_Report
( p_Region_Code           IN VARCHAR2
, p_Region_Application_Id IN NUMBER
, p_Dim_Obj_Short_Names   IN VARCHAR2
, p_Measure_Short_Names   IN VARCHAR2
, x_Result                OUT NOCOPY   VARCHAR2
, x_Return_Status         OUT NOCOPY   VARCHAR2
, x_Msg_Count             OUT NOCOPY   NUMBER
, x_Msg_Data              OUT NOCOPY   VARCHAR2
);

FUNCTION Get_Attribute_Code_For_Measure
( p_Report_Region_Code    IN  VARCHAR2
 ,p_Measure_Short_Name    IN  VARCHAR2
) RETURN VARCHAR2;

-- Added the following APIs for Bug#4558279
/*******************************************
** START **
Added the following API for dynamic
parameter portlet creation logic as required
by Bug#4558279
********************************************/

FUNCTION Is_Dim_Exist_In_Current_Region (
     p_Region_Code            IN AK_REGIONS.REGION_CODE%TYPE
   , p_Region_Application_Id  IN AK_REGIONS.REGION_APPLICATION_ID%TYPE
) RETURN VARCHAR2;

FUNCTION Is_Dim_Exist_In_Nested_Region (
     p_Region_Code            IN AK_REGIONS.REGION_CODE%TYPE
   , p_Region_Application_Id  IN AK_REGIONS.REGION_APPLICATION_ID%TYPE
) RETURN VARCHAR2;

FUNCTION Is_New_Param_Portlet_Required (
     p_Region_Code            IN AK_REGIONS.REGION_CODE%TYPE
   , p_Region_Application_Id  IN AK_REGIONS.REGION_APPLICATION_ID%TYPE
) RETURN VARCHAR2;

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
);

PROCEDURE Create_Parameter_Portlet (
      p_Commit                    IN VARCHAR2
    , p_Region_Code               IN AK_REGIONS.REGION_CODE%TYPE
    , p_Region_Application_Id     IN AK_REGIONS.REGION_APPLICATION_ID%TYPE
    , x_Region_Code               OUT NOCOPY   VARCHAR2
    , x_Region_Application_Id     OUT NOCOPY   NUMBER
    , x_Return_Status             OUT NOCOPY   VARCHAR2
    , x_Msg_Count                 OUT NOCOPY   NUMBER
    , x_Msg_Data                  OUT NOCOPY   VARCHAR2
);


FUNCTION Get_New_Region_Code RETURN VARCHAR2;

PROCEDURE Unroll_RegionItems_Into_Record (
      p_Region_Code            IN AK_REGIONS.REGION_CODE%TYPE
    , p_Region_Application_Id  IN AK_REGIONS.REGION_APPLICATION_ID%TYPE
    , x_Region_Item_Tbl        OUT NOCOPY BIS_AK_REGION_PUB.Bis_Region_Item_Tbl_Type
);

PROCEDURE Get_Non_Nested_Into_Rec (
     p_Region_Code            IN AK_REGIONS.REGION_CODE%TYPE
   , p_Region_Application_Id  IN AK_REGIONS.REGION_APPLICATION_ID%TYPE
   , x_Region_Item_Tbl        OUT NOCOPY BIS_AK_REGION_PUB.Bis_Region_Item_Tbl_Type
);

FUNCTION Get_Param_Portlet_By_Dashboard (
    p_Page_Function_Name IN VARCHAR2
) RETURN VARCHAR2;

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
) RETURN VARCHAR2;

FUNCTION Get_Comparison_Source (
  p_Measures_Short_Name IN VARCHAR2
) RETURN VARCHAR2;

-- Added the API Migrate_AGR_To_PLSQL() for Enhancement#4878676
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
);


PROCEDURE Migrate_AGR_To_PLSQL (
      p_Commit                      IN VARCHAR := FND_API.G_FALSE
    , p_Region_Application_Id       IN VARCHAR2
    , p_Region_Code                 IN VARCHAR2
    , x_Return_Status           OUT NOCOPY VARCHAR
    , x_Msg_Count               OUT NOCOPY NUMBER
    , x_Msg_Data                OUT NOCOPY VARCHAR
);

-- needs to be moved into an utility file.
FUNCTION Is_Primary_Source_Of_Measure (
      p_Measure_Short_Name IN VARCHAR2
    , p_Region_Code        IN VARCHAR2
) RETURN VARCHAR2;


-- needs to be moved into an utility file.
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
);

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
);


-- added for Bug#4923006
FUNCTION Is_Dim_Associated_To_Objective (
     p_Dimension_Short_Name IN VARCHAR2
   , p_Kpi_Id               IN NUMBER
) RETURN VARCHAR2;

-- added for bug#4741919
PROCEDURE Delete_AG_Report (
      p_Commit                   IN VARCHAR2 := FND_API.G_FALSE
    , p_Region_Code              IN VARCHAR2
    , p_Delete_Measures          IN VARCHAR2
    , x_Return_Status    OUT NOCOPY VARCHAR
    , x_Msg_Count        OUT NOCOPY NUMBER
    , x_Msg_Data         OUT NOCOPY VARCHAR
);

-- Added from Enhancement Number#4952167
PROCEDURE Migrate_AGR_To_VBR (
      p_Commit                      IN VARCHAR2 := FND_API.G_FALSE
    , p_Region_Application_Id       IN VARCHAR2
    , p_Region_Code                 IN VARCHAR2
    , x_Return_Status           OUT NOCOPY VARCHAR
    , x_Msg_Count               OUT NOCOPY NUMBER
    , x_Msg_Data                OUT NOCOPY VARCHAR
);


-- Added from Enhancement Number#4952167
PROCEDURE Migrate_To_Existing_Source (
      p_Commit                      IN VARCHAR2 := FND_API.G_FALSE
    , p_Existing_Report_Type        IN VARCHAR2
    , p_Region_Application_Id       IN VARCHAR2
    , p_Region_Code                 IN VARCHAR2
    , x_Return_Status           OUT NOCOPY VARCHAR
    , x_Msg_Count               OUT NOCOPY NUMBER
    , x_Msg_Data                OUT NOCOPY VARCHAR
);

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
);

/*
This API will take the Region Code and try to cascase it to the pl/sql layer.
and hence will ensure that whenever the parameter section is changed for the report, the
same structure is passed down the Dimension/Objective entities.
*/
PROCEDURE Cascade_Dimension_By_Region (
     p_Commit                IN VARCHAR2
   , p_Region_Code           IN VARCHAR2
   , p_Region_Application_Id IN NUMBER
   , p_Force_Change          IN VARCHAR2
   , x_Return_Status         OUT NOCOPY   VARCHAR2
   , x_Msg_Count             OUT NOCOPY   NUMBER
   , x_Msg_Data              OUT NOCOPY   VARCHAR2
);

/*
This API will get the global menu (attribute19) and title (attribute20) from bis_ak_region_extension table
Added for Bug#4955493
*/
PROCEDURE Get_Global_Menu_Title(
        p_Region_Code           IN VARCHAR2
      , p_Region_Application_Id IN NUMBER
      , x_Global_Menu           OUT NOCOPY VARCHAR2
      , x_Global_Title          OUT NOCOPY VARCHAR2
);

PROCEDURE Create_Bsc_Bis_Metadata(
      p_Commit                      IN VARCHAR2
    , p_Create_Region_Per_Ao        IN VARCHAR2
    , p_Param_Portlet_Region_Code   IN VARCHAR2
    , p_Page_Function_Name          IN VARCHAR2
    , p_Kpi_Portlet_Function_Name   IN VARCHAR2
    , p_Region_Function_Name        IN VARCHAR2
    , p_Region_User_Function_Name   IN VARCHAR2
    , p_Dim_Obj_Short_Names         IN VARCHAR2
    , p_Force_Create_Dim            IN VARCHAR2
    , p_Measure_Short_Name          IN VARCHAR2
    , p_Responsibility_Id           IN NUMBER
    , p_Measure_Name                IN VARCHAR2
    , p_Measure_Description         IN VARCHAR2
    , p_Dataset_Format_Id           IN NUMBER
    , p_Dataset_Autoscale_Flag      IN NUMBER
    , p_Measure_Operation           IN VARCHAR2
    , p_Measure_Increase_In_Measure IN VARCHAR2
     ,p_Measure_Obsolete            IN VARCHAR2 := FND_API.G_FALSE
     ,p_Type                        IN VARCHAR2
    , p_Measure_Random_Style        IN NUMBER
    , p_Measure_Min_Act_Value       IN NUMBER
    , p_Measure_Max_Act_Value       IN NUMBER
    , p_Measure_Type                IN NUMBER
    , p_Measure_App_Id              IN NUMBER := NULL
    , p_Func_Area_Short_Name        IN VARCHAR2 := NULL
    , p_Obj_Grp_Id                  IN NUMBER
    , p_Obj_Tab_Id                  IN NUMBER
    , p_Obj_Type                    IN NUMBER
    , x_Measure_Short_Name          OUT NOCOPY   VARCHAR2
    , x_Kpi_Id                      OUT NOCOPY   NUMBER
    , x_Return_Status               OUT NOCOPY   VARCHAR2
    , x_Msg_Count                   OUT NOCOPY   NUMBER
    , x_Msg_Data                    OUT NOCOPY   VARCHAR2
);

FUNCTION Get_Tab_Name
(
  p_tab_id NUMBER
)
RETURN VARCHAR2;

FUNCTION Get_Objective_Group_Name
(
  p_obj_grp_id NUMBER
)
RETURN VARCHAR2;

FUNCTION Generate_Unique_Region_Code
RETURN VARCHAR2;

PROCEDURE Get_Non_Time_Dim_And_DimObjs
(
  p_region_code           IN         AK_REGIONS.region_code%TYPE
 ,x_non_time_dim_dimObjs  OUT NOCOPY BSC_VARCHAR2_TBL_TYPE
 ,x_non_time_counter      OUT NOCOPY NUMBER
);


END BSC_BIS_KPI_CRUD_PUB;

/
