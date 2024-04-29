--------------------------------------------------------
--  DDL for Package BSC_ANALYSIS_OPTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_ANALYSIS_OPTION_PUB" AUTHID CURRENT_USER as
/* $Header: BSCPANOS.pls 120.2 2007/02/08 13:59:31 akoduri ship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCPANOS.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 10, 2001                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                                                                                      |
 | Description:                                                                         |
 |                      Public Specs version.                                           |
 |      This package creates a BSC Analysis Option.                                     |
 |                                                                                      |
 |      14-JUN-2004   ADRAO   Modified Records Bsc_Option_Rec_Type and                  |
 |                            Bsc_Analysis_Option_Rec to include Short_Name for AO      |
 |                            Enhancement#3540302                                       |
 |      02-jul-2004   rpenneru Modified for Enhancement#3532517                         |
 |      22-AUG-2005   ashankar Bug#4220400 added the constants                          |
 |                             c_ANALYSIS_GROUP0                                        |
 |                             c_ANALYSIS_GROUP1                                        |
 |                             c_ANALYSIS_GROUP2                                        |
 |                             c_ANAL_SERIES_ENABLED                                    |
 |                             c_ANAL_SERIES_DISABLED                                   |
 |                    added the following APIS                                          |
 |                    1.Set_Default_Analysis_Option                                     |
 |                    2.Default_Anal_Option_Changed                                     |
 |                    3.Get_Analysis_Group_Id                                           |
 |                    4.Get_Num_Analysis_options                                        |
 |      31-Jan-2007   akoduri   Enh #5679096 Migration of multibar functionality from   |
 |                              VB to Html                                              |
 +======================================================================================+
*/

C_BSC_UNDERSCORE               CONSTANT VARCHAR2(5) := 'BSC_';
c_ANALYSIS_GROUP0              CONSTANT NUMBER      := 0;
c_ANALYSIS_GROUP1              CONSTANT NUMBER      := 1;
c_ANALYSIS_GROUP2              CONSTANT NUMBER      := 2;
c_ANAL_SERIES_ENABLED          CONSTANT NUMBER      := 1;
c_ANAL_SERIES_DISABLED         CONSTANT NUMBER      := 0;



Type Anal_Opt_Comb_Num_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

/* RECORD Type for Data Sets.*/

TYPE Bsc_Option_Rec_Type is RECORD(
  Bsc_Analysis_Group_Id         number
 ,Bsc_Analysis_Option_Id        number
 ,Bsc_Dataset_Axis              number
 ,Bsc_Dataset_Bm_Color          number
 ,Bsc_Dataset_Bm_Flag           number
 ,Bsc_Dataset_Budget_Flag       number
 ,Bsc_Dataset_Default_Value     number
 ,Bsc_Dataset_Help              BSC_SYS_DATASETS_TL.Help%TYPE
 ,Bsc_Dataset_Id                number
 ,Bsc_Dataset_Name              BSC_SYS_DATASETS_TL.Name%TYPE
 ,Bsc_Dataset_Series_Color      number
 ,Bsc_Dataset_Series_Id         number
 ,Bsc_Dataset_New_Series_Id     number
 ,Bsc_Dataset_Series_Type       number
 ,Bsc_Dataset_Stack_Series_Id   number
 ,Bsc_Dim_Set_Id                number
 ,Bsc_Grandparent_Option_Id     number
 ,Bsc_Kpi_Id                    number
 ,Bsc_Language                  varchar2(5)
 ,Bsc_Measure_Help              BSC_KPI_ANALYSIS_MEASURES_TL.Help%TYPE
 ,Bsc_Measure_Long_Name         BSC_KPI_ANALYSIS_MEASURES_TL.Name%TYPE
 ,Bsc_Measure_Prototype_Flag    number
 ,Bsc_New_Kpi                   varchar2(1)
 ,Bsc_Option_Group0             number
 ,Bsc_Option_Group1             number
 ,Bsc_Option_Group2             number
 ,Bsc_Option_Help               BSC_KPI_ANALYSIS_OPTIONS_TL.Help%TYPE
 ,Bsc_Option_Name               BSC_KPI_ANALYSIS_OPTIONS_TL.Name%TYPE
 ,Bsc_Parent_Option_Id          number
 ,Bsc_Source_Language           varchar2(5)
 ,Bsc_User_Level0               number
 ,Bsc_User_Level1               number
 ,Bsc_User_Level1_Default       number
 ,Bsc_User_Level2               number
 ,Bsc_User_Level2_Default       number
 ,Bsc_Option_Short_Name         BSC_KPI_ANALYSIS_OPTIONS_B.SHORT_NAME%TYPE
 ,Bsc_Kpi_Measure_Id            BSC_KPI_ANALYSIS_MEASURES_B.kpi_measure_id%TYPE
 ,Bsc_Option_Default_Value      BSC_KPI_ANALYSIS_GROUPS.default_value%TYPE
 ,Bsc_Change_Action_Flag        VARCHAR2(1) := FND_API.G_TRUE
);

TYPE Bsc_Option_Tbl_Type IS TABLE OF Bsc_Option_Rec_Type
  INDEX BY BINARY_INTEGER;
TYPE Bsc_Analysis_Group_Rec is  RECORD
(      Bsc_analysis_group_id    BSC_KPI_ANALYSIS_GROUPS.analysis_group_id%TYPE
   ,   Bsc_no_option_id         BSC_KPI_ANALYSIS_GROUPS.num_of_options%TYPE
   ,   Bsc_dependency_flag      BSC_KPI_ANALYSIS_GROUPS.dependency_flag%TYPE
   ,   Bsc_Ana_Group_Short_Name BSC_KPI_ANALYSIS_GROUPS.SHORT_NAME%TYPE
   ,   Bsc_Change_Dim_Set       BSC_KPI_ANALYSIS_GROUPS.change_dim_set%TYPE
);

TYPE Bsc_Anal_Opt_Tbl_Type IS TABLE OF Bsc_Analysis_Group_Rec INDEX BY BINARY_INTEGER;


TYPE Bsc_Analysis_Option_Rec is RECORD
(
       Bsc_Option_Id              BSC_KPI_ANALYSIS_OPTIONS_B.Option_Id%TYPE
   ,   Bsc_Parent_Option_Id       BSC_KPI_ANALYSIS_OPTIONS_B.Parent_Option_Id%TYPE
   ,   Bsc_Grandparent_Option_Id  BSC_KPI_ANALYSIS_OPTIONS_B.Grandparent_Option_Id%TYPE
   ,   Bsc_dependency_flag        BSC_KPI_ANALYSIS_GROUPS.dependency_flag%TYPE
   ,   No_of_child                NUMBER
   ,   Bsc_Option_Short_Name      BSC_KPI_ANALYSIS_OPTIONS_B.SHORT_NAME%TYPE
);

TYPE Bsc_Anal_Opt_Det_Tbl_Type IS TABLE OF Bsc_Analysis_Option_Rec INDEX BY BINARY_INTEGER;

procedure Create_Analysis_Options(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Analysis_Options(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_Anal_Opt_Rec        IN OUT NOCOPY      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Analysis_Options(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_Anal_Opt_Rec        IN OUT NOCOPY     BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,p_data_source         IN             VARCHAR2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Analysis_Options(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,p_data_Source         IN             VARCHAR2
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Analysis_Options(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Analysis_Options(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Analysis_Measures(
  p_commit              IN      VARCHAR2  :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Analysis_Measures(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_Anal_Opt_Rec        IN OUT NOCOPY      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Analysis_Measures(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Analysis_Measures(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

/*********************************************************

/***********************************************************/
PROCEDURE Delete_Ana_Opt_Mult_Groups
(       p_commit              IN            VARCHAR2:=FND_API.G_FALSE
    ,   p_Kpi_id              IN            BSC_KPIS_B.indicator%TYPE
    ,   p_Anal_Opt_Tbl        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type
    ,   p_max_group_count     IN            NUMBER
    ,   p_Anal_Opt_Comb_Tbl   IN            BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type
    ,   p_Anal_Opt_Rec        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
    ,   x_return_status       OUT NOCOPY    VARCHAR2
    ,   x_msg_count           OUT NOCOPY    NUMBER
    ,   x_msg_data            OUT NOCOPY    VARCHAR2
);

PROCEDURE Synch_Kpi_Anal_Group
(
         p_commit              IN            VARCHAR2:=FND_API.G_FALSE
     ,   p_Kpi_Id              IN            BSC_KPIS_B.indicator%TYPE
     ,   p_Anal_Opt_Tbl        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type
     ,   x_return_status       OUT NOCOPY    VARCHAR2
     ,   x_msg_count           OUT NOCOPY    NUMBER
     ,   x_msg_data            OUT NOCOPY    VARCHAR2
);


PROCEDURE store_anal_opt_grp_count
(     p_kpi_id        IN            NUMBER
  ,   x_Anal_Opt_Tbl  IN OUT NOCOPY BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type
) ;

PROCEDURE Validate_Custom_Measure
(    p_kpi_id              IN         BSC_OAF_ANALYSYS_OPT_COMB_V.INDICATOR%TYPE
    , p_option0            IN         BSC_OAF_ANALYSYS_OPT_COMB_V.ANALYSIS_OPTION0%TYPE
    , p_option1            IN         BSC_OAF_ANALYSYS_OPT_COMB_V.ANALYSIS_OPTION1%TYPE
    , p_option2            IN         BSC_OAF_ANALYSYS_OPT_COMB_V.ANALYSIS_OPTION2%TYPE
    , p_series_id          IN         BSC_OAF_ANALYSYS_OPT_COMB_V.SERIES_ID%TYPE
    , x_return_status       OUT NOCOPY    VARCHAR2
    , x_msg_count           OUT NOCOPY    NUMBER
    , x_msg_data            OUT NOCOPY    VARCHAR2
);
PROCEDURE delete_extra_series(
      p_Bsc_Anal_Opt_Rec      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
    , x_return_status       OUT NOCOPY    VARCHAR2
    , x_msg_count           OUT NOCOPY    NUMBER
    , x_msg_data            OUT NOCOPY    VARCHAR2
);
-----------------------------------------------------------
PROCEDURE Create_Data_Series
(       p_commit              IN            varchar2 -- :=  FND_API.G_FALSE
    ,   p_Anal_Opt_Rec        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
    ,   x_Anal_Opt_Rec        OUT NOCOPY    BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
    ,   x_return_status       OUT NOCOPY    VARCHAR2
    ,   x_msg_count           OUT NOCOPY    NUMBER
    ,   x_msg_data            OUT NOCOPY    VARCHAR2
);
procedure Delete_Data_Series(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Data_Series
(       p_commit              IN            varchar2 -- :=  FND_API.G_FALSE
    ,   p_Anal_Opt_Rec        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
    ,   x_return_status       OUT NOCOPY    VARCHAR2
    ,   x_msg_count           OUT NOCOPY    NUMBER
    ,   x_msg_data            OUT NOCOPY    VARCHAR2
);

procedure Rearrange_Data_Series(
    p_commit            IN      varchar2  -- FND_API.G_FALSE
   ,p_Kpi_Id            IN      number
   ,p_option_group0     IN      number
   ,p_option_group1     IN      number
   ,p_option_group2     IN      number
   ,p_Measure_Seq       IN      varchar2   -- FND_API.G_FALSE
   ,p_add_flag          IN      varchar2   -- FND_API.G_FALSE
   ,p_remove_flag       IN      varchar2
   ,x_return_status     OUT NOCOPY     varchar2
   ,x_msg_count         OUT NOCOPY     number
   ,x_msg_data          OUT NOCOPY     varchar2
);


PROCEDURE Set_Default_Analysis_Option
(
      p_commit              IN             VARCHAR
    , p_obj_id              IN             BSC_KPIS_B.indicator%TYPE
    , p_Anal_Opt_Comb_Tbl   IN             BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type
    , p_Anal_Grp_Id         IN             BSC_KPIS_B.ind_group_id%TYPE
    , x_return_status       OUT NOCOPY     VARCHAR2
    , x_msg_count           OUT NOCOPY     NUMBER
    , x_msg_data            OUT NOCOPY     VARCHAR2
);

FUNCTION Get_Num_Analysis_options
(
    p_obj_id       IN  BSC_KPIS_B.indicator%TYPE
  , p_anal_grp_Id  IN  BSC_KPI_ANALYSIS_GROUPS.analysis_group_id%TYPE
) RETURN NUMBER;


FUNCTION Get_Analysis_Group_Id
(
   p_Anal_Opt_Comb_Tbl      IN   BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type
 , p_obj_id                 IN   BSC_KPIS_B.indicator%TYPE
) RETURN NUMBER ;

FUNCTION Default_Anal_Option_Changed
(
   p_Anal_Num_Tbl           IN   BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type
 , p_Old_Anal_Num_Tbl       IN   BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type
)RETURN BOOLEAN;

PROCEDURE Cascade_Deletion_Color_Props (
  p_commit              IN      VARCHAR2  :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) ;

end BSC_ANALYSIS_OPTION_PUB;

/
