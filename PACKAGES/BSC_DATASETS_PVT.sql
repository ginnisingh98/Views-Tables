--------------------------------------------------------
--  DDL for Package BSC_DATASETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DATASETS_PVT" AUTHID CURRENT_USER as
/* $Header: BSCVDTSS.pls 120.2 2006/01/05 05:59:56 ppandey noship $ */


procedure Create_Measures(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Dataset_Rec         IN      BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
);

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
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
);

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

function Validate_Measure(
  p_Measure_Name                varchar2
) return number;

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

-- mdamle 09/25/2003 - Sync up measures for all installed languages
PROCEDURE Translate_Measure_By_lang
( p_commit          IN VARCHAR2
, p_Dataset_Rec     IN BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
, p_lang            IN VARCHAR2
, p_source_lang     IN VARCHAR2
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_count       OUT NOCOPY NUMBER
, x_msg_data        OUT NOCOPY VARCHAR2
);

FUNCTION Is_Structure_change (
  p_old_formula         IN     varchar2
 ,p_new_formula         IN     varchar2
 ) RETURN BOOLEAN;

end BSC_DATASETS_PVT;

 

/
