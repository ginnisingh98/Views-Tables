--------------------------------------------------------
--  DDL for Package BSC_DATASETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DATASETS_PUB" AUTHID CURRENT_USER as
/* $Header: BSCPDTSS.pls 120.2 2007/02/08 13:25:53 akoduri ship $ */

/* RECORD Type for Data Sets.*/

TYPE Bsc_Dataset_Rec_Type is RECORD(
  Bsc_Dataset_Autoscale_Flag    number
 ,Bsc_Dataset_Color_Method  number
 ,Bsc_Dataset_Format_Id     number
 ,Bsc_Dataset_Help      bsc_sys_datasets_tl.help%TYPE
 ,Bsc_Dataset_Id                number
 -- mdamle 03/12/2003 - PMD - Measure Definer - Changed from 60 to 80 to match bis_indicators name
 ,Bsc_Dataset_Name          bsc_sys_datasets_tl.name%TYPE
 ,Bsc_Dataset_Projection_Flag   number
 -- mdamle 03/12/2003 - PMD - Measure Definer
 ,Bsc_Dataset_Operation     varchar2(3)
 ,Bsc_Disabled_Calc_Id          number
 ,Bsc_Language                  varchar2(5)
 ,Bsc_Measure_Col       varchar2(320)
 ,Bsc_Measure_Group_Id      number
 ,Bsc_Measure_Help          varchar2(45)
 ,Bsc_Measure_Id                number
 ,Bsc_Measure_Id2       number
 -- mdamle 03/12/2003 - PMD - Measure Definer - Changed from 60 to 80 to match bis_indicators name
 ,Bsc_Measure_Long_Name         bsc_sys_datasets_tl.name%TYPE
 ,Bsc_Measure_Max_Act_Value     number
 ,Bsc_Measure_Max_Bud_Value     number
 ,Bsc_Measure_Min_Act_Value     number
 ,Bsc_Measure_Min_Bud_Value     number
 ,Bsc_Measure_Operation         varchar2(15)
 ,Bsc_Measure_Projection_Id number
 ,Bsc_Measure_Random_Style      number
 ,Bsc_Measure_Short_Name        varchar2(30)
 ,Bsc_Measure_Type      number
 -- mdamle 03/12/2003 - PMD - Measure Definer
 ,Bsc_Measure_color_formula varchar2(4000)
 ,Bsc_Source            varchar2(10)
 ,Bsc_Source_Language           varchar2(5)
 ,Bsc_Y_Axis_Title      varchar2(90)
 -- 16-JUN-2003 ADRAO Added WHO Columns
 ,Bsc_Meas_Type                     NUMBER
 ,Bsc_Measure_Created_By            BSC_SYS_MEASURES.CREATED_BY%TYPE
 ,Bsc_Measure_Creation_Date         BSC_SYS_MEASURES.CREATION_DATE%TYPE
 ,Bsc_Measure_Last_Update_By        BSC_SYS_MEASURES.LAST_UPDATED_BY%TYPE
 ,Bsc_Measure_Last_Update_Date      BSC_SYS_MEASURES.LAST_UPDATE_DATE%TYPE
 ,Bsc_Measure_Last_Update_Login     BSC_SYS_MEASURES.LAST_UPDATE_LOGIN%TYPE

 ,Bsc_Dataset_Created_By            BSC_SYS_DATASETS_B.CREATED_BY%TYPE
 ,Bsc_Dataset_Creation_Date         BSC_SYS_DATASETS_B.CREATION_DATE%TYPE
 ,Bsc_Dataset_Last_Update_By        BSC_SYS_DATASETS_B.LAST_UPDATED_BY%TYPE
 ,Bsc_Dataset_Last_Update_Date      BSC_SYS_DATASETS_B.LAST_UPDATE_DATE%TYPE
 ,Bsc_Dataset_Last_Update_Login     BSC_SYS_DATASETS_B.LAST_UPDATE_LOGIN%TYPE

 -- 18-OCT-2004 ADRAO added for POSCO Bug#3817894
 -- Added Bsc_Measure_Group_Help for furture enhancements.
 ,Bsc_Measure_Col_Help              BSC_DB_MEASURE_COLS_TL.HELP%TYPE
 ,Bsc_Measure_Group_Help            BSC_DB_MEASURE_GROUPS_TL.HELP%TYPE
);

TYPE Bsc_Dataset_Tbl_Type IS TABLE OF Bsc_Dataset_Rec_Type
  INDEX BY BINARY_INTEGER;


procedure Create_Measures(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_Dataset_Id      OUT NOCOPY  number
 ,x_return_status       OUT NOCOPY      varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

-- ADRAO : Overloaded for iBuilder
procedure Create_Measures(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY      varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);
-- ADRAO : Overloaded for iBuilder

procedure Retrieve_Measures(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_Dataset_Rec         IN OUT NOCOPY      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Measures(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

-- mdamle 03/12/2003 - PMD - Measure Definer - Added p_update_dset_calc
procedure Update_Measures(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,p_update_dset_calc    IN      BOOLEAN
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Measures(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Dataset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_Dataset_Id      OUT NOCOPY  number
 ,x_return_status       OUT NOCOPY      varchar2
 ,x_msg_count           OUT NOCOPY      number
 ,x_msg_data            OUT NOCOPY      varchar2
);

-- ADRAO : Overloaded for iBuilder
procedure Create_Dataset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY      varchar2
 ,x_msg_count           OUT NOCOPY      number
 ,x_msg_data            OUT NOCOPY      varchar2
);
-- ADRAO : Overloaded for iBuilder

procedure Retrieve_Dataset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_Dataset_Rec         IN OUT NOCOPY      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Dataset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Dataset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Create_Dataset_Calc(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Retrieve_Dataset_Calc(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_Dataset_Rec         IN OUT NOCOPY      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Dataset_Calc(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Delete_Dataset_Calc(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

procedure Update_Dataset(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,p_update_dset_calc    IN      BOOLEAN
 ,x_return_status       OUT NOCOPY    varchar2
 ,x_msg_count           OUT NOCOPY    number
 ,x_msg_data            OUT NOCOPY    varchar2
);

--=============================================================================
PROCEDURE Translate_Measure
( p_commit IN VARCHAR2
, p_Measure_Rec IN BIS_MEASURE_PUB.Measure_Rec_Type
, p_Dataset_Rec IN BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
) ;
--=============================================================================

PROCEDURE Translate_Measure_By_Lang
( p_commit          IN VARCHAR2
, p_Dataset_Rec     IN BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
, p_lang            IN VARCHAR2
, p_source_lang     IN VARCHAR2
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_count       OUT NOCOPY NUMBER
, x_msg_data        OUT NOCOPY VARCHAR2
);

FUNCTION Get_DataSet_Name(
  p_DataSet_Id    IN NUMBER
) RETURN VARCHAR2;

FUNCTION Get_DataSet_Source(
  p_DataSet_Id    IN NUMBER
) RETURN VARCHAR2;

FUNCTION Get_DataSet_Full_Name(
  p_DataSet_Id    IN NUMBER
) RETURN VARCHAR2;

end BSC_DATASETS_PUB;

/
