--------------------------------------------------------
--  DDL for Package BIS_WEIGHTED_MEASURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_WEIGHTED_MEASURE_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVWMES.pls 120.1 2005/09/16 17:01:28 jxyu noship $ */
/*======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BISPWMEB.pls                                                     |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      April 11, 2005                                                  |
 | Creator:                                                                             |
 |                      William Cano                                                    |
 |                                                                                      |
 | Description:                                                                         |
 |                      Private spec version.		                     				|
 |			This package handle bis Weighted Measure Metadata                           |
 |   History:                                                                           |
 |       04/11/05    wcano    Created.                                                  |
 |       09/15/05    jxyu     Added Update_WM_Last_Update_Info API for bug#4427932.     |
 |                                                                                      |
 +======================================================================================*/
 ------- APIs for tables BIS_WEIGHTED_MEASURE_DEPENDS

PROCEDURE Create_WM_Dependency(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Retrieve_WM_Dependency(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Update_WM_Dependency(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec    OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_WM_Dependency(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

 ------- APIs for table BIS_WEIGHTED_MEASURE_DEFNS

PROCEDURE Create_WM_Definition(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Retrieve_WM_Definition(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Update_WM_Definition(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_WM_Definition(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec     OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

 ------- APIs for table BIS_WEIGHTED_MEASURE_PARAMS

PROCEDURE Create_WM_Parameter(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec    OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Retrieve_WM_Parameter(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Update_WM_Parameter(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_WM_Parameter(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

------- APIs for table BIS_WEIGHTED_MEASURE_WEIGHTS

PROCEDURE Create_WM_Weight(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Retrieve_WM_Weight(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Update_WM_Weight(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_WM_Weight(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

------- APIs for table BIS_WEIGHTED_MEASURE_SCORES

PROCEDURE Create_WM_Score(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Retrieve_WM_Score(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Update_WM_Score(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_WM_Score(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);


-------------------------------------------------------
PROCEDURE Update_WM_Last_Update_Info(
  p_commit          IN VARCHAR2 := FND_API.G_FALSE
 ,p_Weighted_Measure_Id      IN NUMBER
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
);

function validate_measure_id(
  measure_id     IN   NUMBER
) RETURN VARCHAR2;

-------------------------------------------------------

END BIS_WEIGHTED_MEASURE_PVT;

 

/
