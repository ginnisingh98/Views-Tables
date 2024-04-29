--------------------------------------------------------
--  DDL for Package BSC_BIS_KPI_MEAS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_BIS_KPI_MEAS_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCKPMDS.pls 120.4 2007/04/13 12:24:41 ankgoel ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCKPMDS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper for Dimension, part of PMD APIs                   |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 14-FEB-2003 PAJOHRI  Created.                                         |
REM | 20-Sep-2003 ADEULGAO fixed bug#3126401                                |
REM | 04-NOV-2003 PAJOHRI  Bug #3152258                                     |
REM | 08-DEC-2003 KYADAMAK Bug #3225685                                     |
REM | 14-JUN-2004 ADRAO added Short_Name to Analysis Option for Enh#3540302 |
REM |             (ADMINISTRATOR TO ADD KPI TO KPI REGION)                  |
REM | 17-AUG-2004 WLEUNG   added function Remove_Empty_Dims_For_DimSet      |
REM |                      Bug #3784852                                     |
REM | 29-SEP-2004 ashankar added modules is_Period_Circular,                |
REM |                      Parse_Base_Periods and Find_Period_CircularRef   |
REM |                      for bug#3908204                                  |
REM | 10-OCT-2004 ashankar Moved Parse_Base_Periods to BSC_UTILITY package  |
REM |                      and renamed it to Parse_String to make it Generic|
REM |                      enough.This was done as per the review comment   |
REM | 22-AUG-2005 ashankar Bug#4220400 Made public store_kpi_anal_group     |
REM | 15-FEB-2006 akoduri  Bug#4305536  Support new attribute type in       |
REM |                      Objective designer                               |
REM | 31-Jan-2007 akoduri  Enh #5679096 Migration of multibar functionality |
REM |                      from VB to Html                                  |
REM | 13-APR-2007 ankgoel  Bug#5943068 Impact on common dimension by dim    |
REM |                      reorder in a dim set                             |
REM +=======================================================================+
*/

/*******************************************************************
    Adeulgao changed bug#3126401
     description: Moved this from body to here to
                  to make it public.
 *******************************************************************/
 CONFIG_LIMIT_DIM              CONSTANT        NUMBER       := 8;
 CONFIG_LIMIT_DIMSET           CONSTANT        NUMBER       := 2;
 CONFIG_LIMIT_RELS             CONSTANT        NUMBER       := 5;
 COMMA_SEPARATOR               CONSTANT        VARCHAR2(3)  :=',';
 CIR_REF_EXISTS                CONSTANT        VARCHAR2(3)  := 'Y';
 CIR_REF_NOTEXISTS             CONSTANT        VARCHAR2(3)  := 'N';

 c_VIEWBY       CONSTANT VARCHAR2(6)   :=  'VIEWBY';
 c_ALL          CONSTANT VARCHAR2(3)   :=  'ALL';
 C_HIDE_DIM_OBJ CONSTANT VARCHAR2(4)   :=  'HIDE';
-- TYPE varchar_tabletype IS TABLE OF varchar2(32000) INDEX BY binary_integer;


TYPE DimObj_Viewby_Rec_Type IS RECORD
(       p_Measure_Short_Name         BSC_SYS_MEASURES.Short_Name%TYPE
    ,   p_Region_Code                VARCHAR2(30)
    ,   p_Function_Code              VARCHAR2(30)
    ,   p_Is_Time_There              BOOLEAN
    ,   p_Dimension_Name             VARCHAR2(2000)
    ,   p_Dim_Object_Names           VARCHAR2(8000)
    ,   p_View_By_There              VARCHAR2(8000)
    ,   p_All_There                  VARCHAR2(8000)
);
/*******************************************************************/
TYPE DimObj_Viewby_Tbl_Type IS TABLE OF DimObj_Viewby_Rec_Type INDEX BY BINARY_INTEGER;
/*******************************************************************
    Adeulgao changed bug#3126401
     description: Moved this from body to here to
                  to make it public.
 *******************************************************************/
PROCEDURE Get_Dimobj_Viewby_Tbl
(       p_Measure_Short_Name   IN             VARCHAR2
    ,   p_Region_Code          IN             VARCHAR2
    ,   x_DimObj_ViewBy_Tbl    OUT   NOCOPY   BSC_BIS_KPI_MEAS_PUB.DimObj_Viewby_Tbl_Type
    ,   x_return_status        OUT   NOCOPY   VARCHAR2
    ,   x_msg_count            OUT   NOCOPY   NUMBER
    ,   x_msg_data             OUT   NOCOPY   VARCHAR2
);

FUNCTION Get_Dimobj_Properties
(       p_Measure_Short_Name   IN             VARCHAR2
    ,   p_Dim_Obj_Short_Name   IN             VARCHAR2
    ,   p_Property_Type        IN             VARCHAR2
) RETURN VARCHAR2;

/*********************************************************************************
                        CREATE DIMENSION-SETS
*********************************************************************************/
PROCEDURE Create_Dim_Set
(
        p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_display_name          IN              VARCHAR2
    ,   p_dim_short_names       IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2   := NULL  -- Granular Locking
    ,   p_dim_set_short_name    IN              VARCHAR2   := NULL
    ,   x_return_status         OUT    NOCOPY   VARCHAR2            -- Send the KPI Time Stamp
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);
/*********************************************************************************
                        UPDATE DIMENSION-SETS
*********************************************************************************/
PROCEDURE Update_Dim_Set
(
        p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_display_name          IN              VARCHAR2
    ,   p_assign_dim_names      IN              VARCHAR2
    ,   p_unassign_dim_names    IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2   := NULL  -- Granular Locking
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);
/*********************************************************************************
                        UPDATE DIMENSION-SETS
*********************************************************************************/
PROCEDURE Update_Dim_Set
(
        p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_display_name          IN              VARCHAR2
    ,   p_dim_short_names       IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2   := NULL  -- Granular Locking
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);

/*********************************************************************************
                        UPDATE DIMENSION-SET
*********************************************************************************/
PROCEDURE Update_Dim_Set
(
        p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_display_name          IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2   := NULL  -- Granular Locking
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);
/*********************************************************************************
                        DELETE DIMENSION-SETS
*********************************************************************************/
PROCEDURE Delete_Dim_Set
(
        p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);
/*********************************************************************************
                        ASSIGN DIMENSION TO  DIMENSION-SETS
*********************************************************************************/
PROCEDURE Assign_Dims_To_Dim_Set
(
        p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_dim_short_names       IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2   := NULL  -- Granular Locking
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);
/*********************************************************************************
                        REMOVE DIMENSION FROM DIMENSION-SETS
*********************************************************************************/
PROCEDURE Unassign_Dims_From_Dim_Set
(
        p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_dim_short_names       IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2   := NULL  -- Granular Locking
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);

/*********************************************************************************
                        ASSIGN DIMENSION TO  DIMENSION-SETS
*********************************************************************************/
PROCEDURE Assign_Unassign_Dimensions
(
        p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_assign_dim_names      IN              VARCHAR2
    ,   p_unassign_dim_names    IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2   := NULL  -- Granular Locking
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);

/*********************************************************************************
                        ASSIGN DIMENSION-SETS
*********************************************************************************/
PROCEDURE Assign_DSet_Analysis_Options
(
        p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_analysis_grp_id       IN              NUMBER
    ,   p_option_id             IN              NUMBER
    ,   p_time_stamp            IN              VARCHAR2   := NULL  -- Granular Locking
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);
/*********************************************************************************
         API TO UPDATE PMF/BSC MEASURES/ANALYSIS OPTIONS WITHIN AN INDICATOR
*********************************************************************************/
PROCEDURE Update_KPI_Analysis_Options
(
        p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN          NUMBER
    ,   p_data_source           IN          VARCHAR2
    ,   p_analysis_group_id     IN          NUMBER
    ,   p_analysis_option_id0   IN          NUMBER
    ,   p_analysis_option_id1   IN          NUMBER
    ,   p_analysis_option_id2   IN          NUMBER
    ,   p_series_id             IN          NUMBER
    ,   p_data_set_id           IN          NUMBER
    ,   p_dim_set_id            IN          NUMBER
    ,   p_option0_Name          IN          VARCHAR2
    ,   p_option1_Name          IN          VARCHAR2
    ,   p_option2_Name          IN          VARCHAR2
    ,   p_measure_short_name    IN          VARCHAR2
    ,   p_dim_obj_short_names   IN          VARCHAR2  --comma seperated dimension objects needed for PMF Measures
    ,   p_default_short_names   IN          VARCHAR2  :=  NULL
    ,   p_view_by_name          IN          VARCHAR2  :=  NULL
    ,   p_measure_name          IN          VARCHAR2  --BSC_KPI_ANALYSIS_MEASURES_VL.name
    ,   p_measure_help          IN          VARCHAR2  --BSC_KPI_ANALYSIS_MEASURES_VL.help
    ,   p_default_value         IN          NUMBER
    ,   p_time_stamp            IN          VARCHAR2  := NULL
    ,   p_update_ana_opt        IN          BOOLEAN := FALSE
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
);

FUNCTION get_DimensionSetSource
(
        p_Indicator IN NUMBER
    ,   p_DimSetId  IN NUMBER
) RETURN VARCHAR2;

--ASHANKAR added on 09-Jun-2003
FUNCTION GET_AO_NAME
(
        p_indicator     in  NUMBER
    ,   p_a0            in  NUMBER
    ,   p_a1            in  NUMBER
    ,   p_a2            in  NUMBER
    ,   p_group_id      in  NUMBER
) RETURN VARCHAR2;

FUNCTION GET_SERIES_COUNT
(
        p_indicator     IN  NUMBER
    ,   p_a0            IN  NUMBER
    ,   p_a1            IN  NUMBER
    ,   p_a2            IN  NUMBER
) RETURN NUMBER;

/************************************************************************************
                            UPDATE KPIS
************************************************************************************/
PROCEDURE Update_Kpi
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN          NUMBER
    ,   p_kpi_name              IN          VARCHAR2
    ,   p_kpi_help              IN          VARCHAR2   := NULL
    ,   p_responsibility_id     IN          NUMBER     := NULL
    ,   p_default_value         IN          NUMBER
    ,   p_BM_Property_Value     IN          NUMBER     := BSC_KPI_PUB.Benchmark_Kpi_Line_Graph -- 0 For Lines and 1 for Bars
    ,   p_time_stamp            IN          VARCHAR2   := NULL
    ,   p_Anal_opt0             IN          BSC_KPI_ANALYSIS_MEASURES_B.analysis_option0%TYPE
    ,   p_Anal_opt1             IN          BSC_KPI_ANALYSIS_MEASURES_B.analysis_option1%TYPE
    ,   p_Anal_opt2             IN          BSC_KPI_ANALYSIS_MEASURES_B.analysis_option2%TYPE
    ,   p_Anal_Series           IN          BSC_KPI_ANALYSIS_MEASURES_B.series_id%TYPE
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
);
/************************************************************************************
************************************************************************************/

PROCEDURE Create_Kpi
(
        p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_group_id              IN              NUMBER
    ,   p_kpi_name              IN              VARCHAR2
    ,   p_kpi_help              IN              VARCHAR2
    ,   p_responsibility_id     IN              NUMBER
    ,   x_return_status         OUT NOCOPY      VARCHAR2
    ,   x_msg_count             OUT NOCOPY      NUMBER
    ,   x_msg_data              OUT NOCOPY      VARCHAR2
);
/*********************************************************************************
         API TO DELETE PMF/BSC MEASURES/ANALYSIS OPTIONS WITHIN AN INDICATOR
*********************************************************************************/
/*PROCEDURE Delete_KPI_Analysis_Options
(
        p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN          NUMBER
    ,   p_data_source           IN          VARCHAR2
    ,   p_option_id             IN          NUMBER
    ,   p_time_stamp            IN          VARCHAR2   := NULL
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
);
/*********************************************************************************
         API TO CREATE PMF/BSC MEASURES/ANALYSIS OPTIONS WITHIN AN INDICATOR
*********************************************************************************/
-- ADRAO added Short_Name to Analysis Option for Enh#3540302 (ADMINISTRATOR TO ADD KPI TO KPI REGION)
PROCEDURE Create_KPI_Analysis_Options
(
        p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN          NUMBER
    ,   p_analysis_group_id     IN          NUMBER
    ,   p_data_set_id           IN          NUMBER
    ,   p_measure_short_name    IN          VARCHAR2
    ,   p_measure_name          IN          VARCHAR2
    ,   p_measure_help          IN          VARCHAR2
    ,   p_time_stamp            IN          VARCHAR2   := NULL
    ,   p_Short_Name            IN          VARCHAR2   := NULL
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
);

/*********************************************************************************
          API to CREATE DIMENSION-OBJECTS IN  DIMENSION SETS USED IN CASCADING
*********************************************************************************/
PROCEDURE Create_Dim_Objs_In_DSet
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_kpi_flag_change       IN              NUMBER     := NULL
    ,   p_delete                IN              BOOLEAN    := FALSE
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);
/*********************************************************************************
          API to DELETE DIMENSION-OBJECTS IN  DIMENSION SETS USED IN CASCADING
*********************************************************************************/
PROCEDURE Delete_Dim_Objs_In_DSet
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);
--=============================================================================
FUNCTION get_KPIs
(       p_Kpi_ID                IN          NUMBER
    ,   p_Dim_Set_ID            IN          NUMBER
) RETURN VARCHAR2;
--=============================================================================
FUNCTION is_KPI_Flag_For_Dim_In_DimSets
(       p_Kpi_ID                IN          NUMBER
    ,   p_Dim_Set_ID            IN          NUMBER
    ,   p_Unassign_dim_names    IN          VARCHAR2
    ,   p_Dim_Short_Names       IN          VARCHAR2
) RETURN VARCHAR2;
--=============================================================================
FUNCTION check_config_impact_dimset
(       p_Kpi_ID                IN          NUMBER
    ,   p_Dim_Set_ID            IN          NUMBER :=NULL
    ,   p_Unassign_dim_names    IN          VARCHAR2
    ,   p_Dim_Short_Names       IN          VARCHAR2
) RETURN VARCHAR2;
--============================================================================
FUNCTION get_no_rels
(   p_dim_obj_sht_names IN VARCHAR2
)RETURN NUMBER;
--====================================================================
/*********************************************************************************
         API TO DELETE PMF/BSC MEASURES/ANALYSIS OPTIONS WITHIN AN INDICATOR
*********************************************************************************/
PROCEDURE Delete_KPI_Multi_Groups_Opts
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN          NUMBER
    ,   p_data_source           IN          VARCHAR2
    ,   p_Option_0              IN          NUMBER
    ,   p_Option_1              IN          NUMBER
    ,   p_Option_2              IN          NUMBER
    ,   p_Sid                   IN          NUMBER
    ,   p_time_stamp            IN          VARCHAR2   := NULL
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
);

/*********************************************************************************
         API TO GET THE ANALYSIS OPTION COMBINATION MESSAGE
*********************************************************************************/

FUNCTION get_anal_opt_comb_message
(
      p_Kpi_Id          IN          BSC_KPIS_B.indicator%TYPE
  ,   p_Option_0        IN          NUMBER
  ,   p_Option_1        IN          NUMBER
  ,   p_Option_2        IN          NUMBER
  ,   p_Sid             IN          NUMBER
)RETURN VARCHAR2;

/*********************************************************************************
         API TO CHECK FOR CIRCULAR REFERENCE AMONG PERIODS
*********************************************************************************/

FUNCTION Find_Period_CircularRef
(
     p_basePeriod      IN   BSC_SYS_PERIODICITIES.periodicity_id%TYPE
 ,   p_current_period  IN   BSC_SYS_PERIODICITIES.periodicity_id%TYPE

) RETURN BOOLEAN;

FUNCTION is_Period_Circular
(
     p_basePeriod      IN   BSC_SYS_PERIODICITIES.periodicity_id%TYPE
 ,   p_current_period  IN   BSC_SYS_PERIODICITIES.periodicity_id%TYPE
) RETURN VARCHAR2;

PROCEDURE check_pmf_validveiw_for_mes
(
        p_dataset_id            IN          NUMBER
    ,   x_dimobj_name           OUT NOCOPY  VARCHAR2
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2

);

PROCEDURE store_kpi_anal_group
(     p_kpi_id        IN            NUMBER
  ,   x_Anal_Opt_Tbl  IN OUT NOCOPY BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type
);

PROCEDURE Remove_Unused_PMF_Dimenison
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_Kpi_Id                IN          NUMBER
    ,   p_dim_set_id            IN          NUMBER
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
);

FUNCTION Is_More
(       p_dim_short_names   IN  OUT NOCOPY  VARCHAR2
    ,   p_dim_short_name        OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN;

PROCEDURE get_common_dimensions_tabs (
  p_dim_short_name  IN  VARCHAR2
, p_objective_id    IN  NUMBER
, x_tab_ids         OUT NOCOPY VARCHAR2
);

END BSC_BIS_KPI_MEAS_PUB;

/
