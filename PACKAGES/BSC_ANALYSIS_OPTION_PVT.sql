--------------------------------------------------------
--  DDL for Package BSC_ANALYSIS_OPTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_ANALYSIS_OPTION_PVT" AUTHID CURRENT_USER as
/* $Header: BSCVANOS.pls 120.2 2005/10/03 07:00:17 adrao noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCVANOS.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 10, 2001                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Mario-Jair Campos                                               |
 |                                                                                      |
 | Description:                                                                         |
 |                                                                                      |
 |       14-JUN-2004   ADRAO   Added API Refresh_Short_Names, to refresh short_names    |
 |                             when an Analysis Option is deleted for Enh#3691035       |
 |                                                                                      |
 |      02-jul-2004   rpenneru Modified for Enhancement#3532517                         |
 |      20-APR-2005   adrao added API Cascade_Series_Default_Value                      |
 |      22-AUG-2005   Bug #4220400 ashankar added Set_Default_Analysis_Option and made  |
 |                    public the following APIs Initialize_Anal_Opt_Tbl and             |
 |                    Validate_If_single_Anal_Opt                                       |
 +======================================================================================+
*/

C_API_UPDATE   CONSTANT VARCHAR2(6) := 'UPDATE';
C_API_CREATE   CONSTANT VARCHAR2(6) := 'CREATE';

procedure Create_Analysis_Options(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Analysis_Options
(
    p_commit              IN              varchar2 -- :=  FND_API.G_FALSE
 ,  p_Anal_Opt_Rec        IN              BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,  x_Anal_Opt_Rec        IN  OUT NOCOPY  BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,  p_data_source         IN              VARCHAR2
 ,  x_return_status       OUT NOCOPY      varchar2
 ,  x_msg_count           OUT NOCOPY      number
 ,  x_msg_data            OUT NOCOPY      varchar2
);

procedure Update_Analysis_Options
(
    p_commit              IN            varchar2 -- :=  FND_API.G_FALSE
 ,  p_Anal_Opt_Rec        IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,  p_data_source         IN            VARCHAR2
 ,  x_return_status       OUT NOCOPY    VARCHAR2
 ,  x_msg_count           OUT NOCOPY    NUMBER
 ,  x_msg_data            OUT NOCOPY    VARCHAR2
);

procedure Delete_Analysis_Options(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Analysis_Measures(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
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

procedure Delete_Data_Series(
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

function Delete_Analysis_Option(
  p_kpi_id      IN  number
 ,p_anal_option_id  IN  number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
 ,p_anal_group_id   IN  number DEFAULT 0
) return varchar2;

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


-- Added for Start-to-End KPI Project, Bug#3691035
PROCEDURE Refresh_Short_Names (
        p_Commit                    IN VARCHAR2
      , p_Kpi_Id                    IN NUMBER
      , x_Return_Status             OUT NOCOPY   VARCHAR2
      , x_Msg_Count                 OUT NOCOPY   NUMBER
      , x_Msg_Data                  OUT NOCOPY   VARCHAR2
);

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

procedure Swap_Data_Series_Id(
  p_commit              IN      varchar2 -- :=  FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) ;


-- added for Bug#4298940
PROCEDURE Cascade_Series_Default_Value (
      p_Commit        IN  VARCHAR2
    , p_Api_Mode      IN  VARCHAR2
    , p_Kpi_Id        IN  NUMBER
    , p_Option0       IN  NUMBER
    , p_Option1       IN  NUMBER
    , p_Option2       IN  NUMBER
    , p_Series_Id     IN  NUMBER
    , p_Default_Value IN  NUMBER
    , x_Default_Value OUT NOCOPY NUMBER
    , x_Return_Status OUT NOCOPY VARCHAR2
    , x_Msg_Count     OUT NOCOPY NUMBER
    , x_Msg_Data      OUT NOCOPY VARCHAR2
);


-- added for Bug#4324947
-- Returns the short_name of next associated Objective
-- of type AG only.
FUNCTION Get_Next_Associated_Obj_SN (
       p_Dataset_ID  IN NUMBER
) RETURN VARCHAR2;

-- Modified API for Bug#4638384 - changed signature to add p_Comparison_Source
-- added for Bug#4324947
PROCEDURE Cascade_Data_Src_Values (
      p_Commit                  IN  VARCHAR2
    , p_Measure_Short_Name      IN  VARCHAR2
    , p_Empty_Source            IN  VARCHAR2
    , p_Actual_Data_Source_Type IN VARCHAR2
    , p_Actual_Data_Source      IN VARCHAR2
    , p_Function_Name           IN VARCHAR2
    , p_Enable_Link             IN VARCHAR2
    , p_Comparison_Source       IN VARCHAR2
    , x_Return_Status           OUT NOCOPY VARCHAR2
    , x_Msg_Count               OUT NOCOPY NUMBER
    , x_Msg_Data                OUT NOCOPY VARCHAR2
);

FUNCTION Validate_If_single_Anal_Opt
(
    p_Anal_Opt_Tbl      IN    BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type

)RETURN BOOLEAN;

PROCEDURE Initialize_Anal_Opt_Tbl
(
        p_Kpi_id             IN            BSC_KPIS_B.indicator%TYPE
   ,    p_Anal_Opt_Tbl       IN            BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type
   ,    p_max_group_count    IN            NUMBER
   ,    p_Anal_Opt_Comb_Tbl  IN            BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type
   ,    p_Anal_Det_Opt_Tbl   IN OUT NOCOPY BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Det_Tbl_Type
);

PROCEDURE Set_Default_Analysis_Option
(
      p_commit              IN             VARCHAR2
    , p_obj_id              IN             BSC_KPIS_B.indicator%TYPE
    , p_Anal_Opt_Comb_Tbl   IN             BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type
    , p_Anal_Grp_Id         IN             BSC_KPIS_B.ind_group_id%TYPE
    , x_return_status       OUT NOCOPY     VARCHAR2
    , x_msg_count           OUT NOCOPY     NUMBER
    , x_msg_data            OUT NOCOPY     VARCHAR2
);



end BSC_ANALYSIS_OPTION_PVT;




 

/
