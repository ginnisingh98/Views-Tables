--------------------------------------------------------
--  DDL for Package BSC_PMF_UI_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_PMF_UI_WRAPPER" AUTHID CURRENT_USER as
/* $Header: BSCPMFWS.pls 120.6 2007/06/01 06:52:59 ashankar ship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCPMFWS.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 18, 2001                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                      Adrao fixed bug#3118110 added function is_In_Dimension          |
 |                                                                                      |
 | Description:                                                                         |
 |                                                                                      |
 |   11-MAR-04          jxyu  Modified for enhancement #3493589                         |
 |   18-MAY-04          adrao Modified PL/SQL records and CRUD to accept SHORT_NAME     |
 |   02-JUL-04         rpenneru Modified for enh# 3532517                               |
 |   30-SEP-04         visuri modified for bug 3852611                                  |
 |   27-DEC-04         adrao added DIMOBJ_SHORT_NAME_CLASS for Bug#4089297              |
 |   25-JUL_05         hengliu added Check_Tabview_Dependency for bug#4237294           |
 |   16-NOV-2006       ankgoel  Color By KPI enh#5244136                                |
 |   30-MAR-2007       akoduri  Enh #5928640 Migration of Periodicity properties from   |
 |                              VB to Html                                              |
 +======================================================================================+
*/

TYPE t_of_Bsc_Dim_Level_Rec IS TABLE OF BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    INDEX BY BINARY_INTEGER;

TYPE t_of_varchar2 IS TABLE OF VARCHAR2(500)
    INDEX BY BINARY_INTEGER;

-- added for Bug#4089297
TYPE DIMOBJ_SHORT_NAME_CLASS IS VARRAY(20) OF BIS_LEVELS.SHORT_NAME%TYPE;


-- added orginally for Bug#3459282 and for resolving Bug#3888428
TYPE Bsc_Tabs_Type is RECORD(
   Bsc_tab_id               BSC_TABS_VL.tab_id%TYPE
);

TYPE Bsc_Tabs_Tbl_Rec IS TABLE OF Bsc_Tabs_Type INDEX BY BINARY_INTEGER;

g_time_stamp_format VARCHAR2(200):= 'YY/MM/DD-HH:MI:SS';
C_SCORECARD_LOGO_TYPE   NUMBER :=3;

procedure Fire_Api(
  p_api_call        varchar2
);

procedure Table_Generator(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_id          number
 ,p_meas_short_name     varchar2
 ,p_dim_level_short_name    varchar2
);

procedure Add_Analysis_Option(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_option_name           IN VARCHAR2
 ,p_option_description    IN VARCHAR2
 ,p_meas_short_name       IN VARCHAR2
 ,p_dim_level_short_names IN VARCHAR2
 ,p_kpi_id                IN NUMBER
 ,x_bad_level           OUT NOCOPY     varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Kpi_Group(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_tab_id              IN      number
 ,p_kpi_group_id        IN      number
 ,x_return_status   OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
 ,p_kpi_group_name      IN      varchar2 DEFAULT null
 ,p_kpi_group_help      IN      varchar2 DEFAULT null
);

procedure Create_Kpi_Group(
  p_commit                IN             VARCHAR2 := FND_API.G_FALSE
 ,p_tab_id                IN             NUMBER  -- It needs to pass NULL or -1
 ,p_kpi_group_id          IN             NUMBER
 ,p_kpi_group_name        IN             VARCHAR2
 ,p_kpi_group_help        IN             VARCHAR2
 ,p_Kpi_Group_short_Name  IN             VARCHAR2 := NULL
 ,x_kpi_group_id          OUT NOCOPY     NUMBER  -- OUT parameter for kpi group id
 ,x_return_status         OUT NOCOPY     VARCHAR2
 ,x_msg_count             OUT NOCOPY     NUMBER
 ,x_msg_data              OUT NOCOPY     VARCHAR2
);

procedure Update_Kpi_Group(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_group_id        IN      number
 ,p_kpi_group_name      IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ,p_kpi_group_help      IN      varchar2 DEFAULT null
);

procedure Create_Kpi(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_group_id            IN      number
 ,p_responsibility_id   IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ,p_kpi_name            IN      varchar2 DEFAULT null
 ,p_kpi_help            IN      varchar2 DEFAULT null
);

procedure Create_Kpi(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_group_id            IN            NUMBER
 ,p_responsibility_id   IN            NUMBER
 ,p_kpi_name            IN            VARCHAR2
 ,p_kpi_help            IN            VARCHAR2
 ,p_Kpi_Short_Name      IN            VARCHAR2 := NULL
 ,p_Kpi_Indicator_Type  IN            NUMBER   := NULL
 ,x_kpi_id              OUT NOCOPY    NUMBER
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

procedure Update_Kpi(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_id              IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ,p_kpi_name            IN      varchar2 DEFAULT null
 ,p_kpi_help            IN      varchar2 DEFAULT null
);

procedure Create_Tab(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_responsibility_id   IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ,p_tab_name            IN      varchar2 := NULL
 ,p_tab_help            IN      varchar2 := NULL
);

PROCEDURE Create_Tab
(   p_commit            IN          VARCHAR2 := FND_API.G_TRUE
  , p_responsibility_id IN          NUMBER
  , p_parent_tab_id     IN          NUMBER
  , p_owner_id          IN          NUMBER
  , p_Short_Name        IN          VARCHAR2 := NULL
  , x_tab_id            OUT NOCOPY  NUMBER
  , x_return_status     OUT NOCOPY  VARCHAR2
  , x_msg_count         OUT NOCOPY  NUMBER
  , x_msg_data          OUT NOCOPY  VARCHAR2
  , p_tab_name          IN          VARCHAR2 := NULL
  , p_tab_help          IN          VARCHAR2 := NULL
  , p_tab_info          IN          VARCHAR2 := NULL
);

procedure Update_Tab(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_tab_id              IN      number
 ,p_tab_name            IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ,p_tab_help            IN      varchar2 DEFAULT null
);

procedure Update_Tab(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_tab_id              IN      number
 ,p_owner_id        IN  number
 ,p_tab_name            IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ,p_tab_help            IN      varchar2 DEFAULT null
 ,p_tab_info            IN      varchar2 DEFAULT null
 ,p_time_stamp          IN      varchar2  := NULL

);

procedure Update_Analysis_Option(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_id              IN      number
 ,p_option_group_id     IN      number
 ,p_option_id           IN      number
 ,p_option_name         IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ,p_option_help         IN      varchar2 DEFAULT null
);

procedure Delete_Analysis_Option(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_id              IN      number
 ,p_option_group_id     IN      number
 ,p_option_id           IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Kpi(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_id          IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Kpi_Group(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_group_id    IN      number
 ,p_tab_id              IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Tab(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_tab_id              IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Assign_KPI(
  p_commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_kpi_id              IN      number
 ,p_tab_id              IN      number
 ,x_return_status       IN OUT NOCOPY     varchar2
 ,x_msg_count           IN OUT NOCOPY     number
 ,x_msg_data            IN OUT NOCOPY     varchar2
 ,p_time_stamp          IN             varchar2 := NULL
);

procedure Unassign_KPI(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_id              IN      number
 ,p_tab_id              IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ,p_time_stamp          IN             varchar2 := NULL
);

function Is_KPI_Assigned(
  p_kpi_id              IN      number
 ,p_tab_id              IN      number
) return varchar2;

procedure Assign_KPI_Group(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_Group_id        IN      number
 ,p_tab_id              IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Assign_Analysis_Option(
  p_kpi_id                  IN      number
 ,p_analysis_group_id       IN      number
 ,p_option_id               IN      number
 ,p_parent_option_id        IN      number
 ,p_grandparent_option_id   IN      number
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
 ,p_commit                  IN      varchar2 := FND_API.G_TRUE
 ,p_time_stamp_to_check     IN      varchar2 := null
);

procedure Unassign_Analysis_Option(
  p_kpi_id                  IN      number
 ,p_analysis_group_id       IN      number
 ,p_option_id               IN      number
 ,p_parent_option_id        IN      number
 ,p_grandparent_Option_id   IN      number
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
 ,p_commit                  IN      varchar2 := FND_API.G_TRUE
 ,p_time_stamp_to_check     IN      varchar2 := null
);

function Is_Analysis_Option_Selected(
  p_kpi_id                  IN      number
 ,p_analysis_group_id       IN      number
 ,p_option_id               IN      number
 ,p_parent_option_id        IN      number
 ,p_grandparent_Option_id   IN      number
) return varchar2;

function Is_Leaf_Analysis_Option(
  p_kpi_id                  IN      number
 ,p_analysis_group_id       IN      number
 ,p_option_id               IN      number
 ,p_parent_option_id        IN      number
 ,p_grandparent_Option_id   IN      number
) return varchar2;

procedure Populate_Option_Dependency_Rec(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_kpi_id                  IN      number
 ,p_analysis_group_id       IN      number
 ,p_option_id               IN      number
 ,p_parent_option_id        IN      number
 ,p_grandparent_option_id   IN      number
 ,p_Bsc_kpi_Entity_Rec      OUT NOCOPY     BSC_KPI_PUB.Bsc_kpi_Entity_Rec
 ,x_return_status           OUT NOCOPY     varchar2
 ,x_msg_count               OUT NOCOPY     number
 ,x_msg_data                OUT NOCOPY     varchar2
);

/*********************************************************************************
-- Procedures to Handle Relationships between Dimension Levels
**********************************************************************************/
procedure Change_Error_Msg(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_msg_name        IN          varchar2 DEFAULT null
 ,p_new_msg_name    IN          varchar2 DEFAULT null
 ,p_token1          IN          varchar2 DEFAULT null
 ,p_token1_value    IN          varchar2 DEFAULT null
 ,p_token2          IN          varchar2 DEFAULT null
 ,p_token2_value    IN          varchar2 DEFAULT null
 ,p_initialize_flag IN          varchar2 DEFAULT 'Y'
 ,p_sys_admin_flag  IN          varchar2 DEFAULT 'F'
 ,x_return_status   IN OUT NOCOPY      varchar2
 ,x_msg_count       OUT NOCOPY     number
 ,x_msg_data        OUT NOCOPY     varchar2

);

PROCEDURE Import_Dim_Level(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_Short_Name          IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

PROCEDURE Update_RelationShips(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_Dim_Level_Id        IN      number
 ,p_Short_Name          IN      varchar2
 ,p_Parents             IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

FUNCTION Decompose_String_List(
 x_string IN VARCHAR2,
 x_varchar2_array IN OUT NOCOPY t_of_varchar2,
 x_separator IN VARCHAR2
 ) RETURN VARCHAR2;

procedure Create_PMF_Relationship (
  p_commit               IN      varchar := FND_API.G_FALSE
 ,p_SHORT_NAME          IN      VARCHAR2
 ,p_PARENT_SHORT_NAME   IN      VARCHAR2
 ,p_RELATION_COL        IN      VARCHAR2
);

procedure Order_Tab_Index(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_tab_ids     IN  varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Tab_Parent(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_tab_id      IN  number
 ,p_parent_tab_id   IN  number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Measure(
  p_commit                IN          VARCHAR2 := FND_API.G_TRUE
 ,p_short_name          IN      varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Measure_VB(
  p_short_name          IN      varchar2
);

procedure Get_PMV_Report_Levels(
  p_region_code     IN  varchar2
 ,p_measure_short_name  IN  varchar2
 ,x_dim1_name           OUT NOCOPY     varchar2
 ,x_dim1_levels         OUT NOCOPY     varchar2
 ,x_dim2_name           OUT NOCOPY     varchar2
 ,x_dim2_levels         OUT NOCOPY     varchar2
 ,x_dim3_name           OUT NOCOPY     varchar2
 ,x_dim3_levels         OUT NOCOPY     varchar2
 ,x_dim4_name           OUT NOCOPY     varchar2
 ,x_dim4_levels         OUT NOCOPY     varchar2
 ,x_dim5_name           OUT NOCOPY     varchar2
 ,x_dim5_levels         OUT NOCOPY     varchar2
 ,x_dim6_name           OUT NOCOPY     varchar2
 ,x_dim6_levels         OUT NOCOPY     varchar2
 ,x_dim7_name           OUT NOCOPY     varchar2
 ,x_dim7_levels         OUT NOCOPY     varchar2
 ,x_is_there_time       OUT NOCOPY     varchar2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

PROCEDURE Assign_Kpi_Tab
(
      p_commit              IN              VARCHAR2   := FND_API.G_FALSE
    , p_tab_id      IN      NUMBER
    , p_kpi_ids     IN      VARCHAR2
    , x_return_status   IN OUT NOCOPY   VARCHAR2
    , x_msg_count       IN OUT NOCOPY   NUMBER
    , x_msg_data        IN OUT NOCOPY   VARCHAR2
    , p_time_stamp  IN      VARCHAR2  :=  NULL
);

function get_KPI_Time_Stamp(
  p_kpi_id              IN      number
) return varchar2;

FUNCTION get_Tab_Id
(
    p_Tab_Name  IN  VARCHAR2
) RETURN NUMBER;


FUNCTION is_In_Dimension
(       p_measure_short_name IN  VARCHAR2
    ,   p_dims_short_name    IN  VARCHAR2
    ,   p_dim_obj            IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION is_group_selected
(
        p_tab_id    IN  NUMBER
    ,   p_group_id  IN  NUMBER

) RETURN VARCHAR2;

procedure Update_Kpi_Periodicities(
  p_commit              IN             VARCHAR2 := FND_API.G_FALSE
 ,p_kpi_id              IN             NUMBER
 ,p_calendar_id         IN             NUMBER
 ,p_periodicity_ids     IN             VARCHAR2
 ,p_Dft_periodicity_id  IN             NUMBER
 ,p_Periods_In_Graph    IN             FND_TABLE_OF_NUMBER := NULL
 ,p_Periodicity_Id_Tbl  IN             FND_TABLE_OF_NUMBER := NULL
 ,p_Number_Of_Years     IN             NUMBER := 10
 ,p_Previous_Years      IN             NUMBER := 5
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
);

procedure Check_Tab(
  p_tab_id              IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

PROCEDURE Check_Tabviews (
   p_tab_id              IN             NUMBER
  ,p_list_dependency     IN             VARCHAR2
  ,x_exist_dependency    OUT NOCOPY     VARCHAR2
  ,x_dep_obj_list        OUT NOCOPY     VARCHAR2
  ,x_return_status       OUT NOCOPY     VARCHAR2
  ,x_msg_count           OUT NOCOPY     NUMBER
  ,x_msg_data            OUT NOCOPY     VARCHAR2
 );

PROCEDURE Check_Tabview_Dependency (
   p_tab_id              IN             NUMBER
  ,p_tab_view_id		 IN 			NUMBER
  ,p_list_dependency     IN             VARCHAR2
  ,x_exist_dependency    OUT NOCOPY     VARCHAR2
  ,x_dep_obj_list        OUT NOCOPY     VARCHAR2
  ,x_return_status       OUT NOCOPY     VARCHAR2
  ,x_msg_count           OUT NOCOPY     NUMBER
  ,x_msg_data            OUT NOCOPY     VARCHAR2
 );


 PROCEDURE Create_Scorecard_logo (
    p_obj_id            IN NUMBER
   ,p_file_name         IN VARCHAR2
   ,p_description       IN VARCHAR2
   ,p_width             IN NUMBER
   ,p_height            IN NUMBER
   ,p_mime_type         IN VARCHAR2
   ,x_image_id          OUT NOCOPY NUMBER
   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER
   ,x_msg_data          OUT NOCOPY VARCHAR2
 );


 PROCEDURE  Add_Or_Update_Tab_Logo (
   p_tab_id            IN NUMBER
  ,p_image_id          IN NUMBER
  ,p_file_name         IN VARCHAR2
  ,p_description       IN VARCHAR2
  ,p_width             IN NUMBER
  ,p_height            IN NUMBER
  ,p_mime_type         IN VARCHAR2
  ,x_image_id          OUT NOCOPY NUMBER
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
 );

 PROCEDURE Delete_Tab_Logo
 (
    p_tab_id            IN         BSC_TABS_B.tab_id%TYPE
   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER
   ,x_msg_data          OUT NOCOPY VARCHAR2
 );


END BSC_PMF_UI_WRAPPER;

/
