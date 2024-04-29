--------------------------------------------------------
--  DDL for Package Body BIS_ACTUAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_ACTUAL_PUB" AS
/* $Header: BISPACVB.pls 115.21 2003/05/20 05:26:43 sugopal ship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_ACTUAL_PUB';
--

-- Retrieves the KPIs users have selected to monitor on the personal homepage
-- or in the summary report.  This should be called before calling Post_Actual.
PROCEDURE Retrieve_User_Selections
(  p_api_version                  IN NUMBER
  ,p_Target_Level_Rec
     IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
  ,x_Indicator_Region_Tbl
     OUT NOCOPY BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
   l_target_level_rec BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE;
   l_indicator_region_tbl BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_Target_level_Rec := p_target_level_rec;

  -- mdamle 01/15/2001 - Resequence the dimensions levels for product teams still using Org and Time
  IF (l_target_level_rec.org_level_id IS NOT NULL) AND
     (l_target_level_rec.time_level_id IS NOT NULL) THEN
     BIS_UTILITIES_PVT.resequence_dim_levels
                   (p_target_level_rec
                   ,'N'
                   ,l_target_level_rec
       		       ,x_error_tbl);
  END IF;

  BIS_INDICATOR_REGION_PUB.Retrieve_User_Ind_Selections
  (  p_api_version           => p_api_version
   , p_all_info              => FND_API.G_TRUE
   , p_Target_level_Rec      => l_Target_level_Rec
   , x_Indicator_Region_Tbl  => x_Indicator_Region_Tbl
   , x_return_status	     => x_return_status
   , x_error_Tbl             => x_error_Tbl
  );

  -- mdamle 01/12/2001 Resequence the dimensions levels for product teams still using Org and Time
  IF (x_Indicator_Region_Tbl.COUNT > 0) THEN
     l_indicator_region_tbl := x_Indicator_Region_Tbl;
     FOR l_count IN 1..l_indicator_region_tbl.COUNT LOOP
       BIS_UTILITIES_PVT.reseq_ind_dim_level_values(
         l_indicator_region_tbl(l_count)
        ,'R'
        ,x_Indicator_Region_Tbl(l_count)
        ,x_Error_tbl
       );
     END LOOP;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Retrieve_User_Selections;


-- Posts actual value into BIS table.
PROCEDURE Post_Actual
(  p_api_version       IN NUMBER
  ,p_init_msg_list     IN VARCHAR2   Default FND_API.G_FALSE
  ,p_commit            IN VARCHAR2   Default FND_API.G_FALSE
  ,p_validation_level  IN NUMBER     Default FND_API.G_VALID_LEVEL_FULL
  ,p_Actual_Rec        IN BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_Actual_Rec BIS_ACTUAL_PUB.Actual_Rec_Type;
l_actual_rec_p BIS_ACTUAL_PUB.Actual_Rec_Type;
l_Actual_Rec_Validated BIS_ACTUAL_PUB.Actual_Rec_Type;  -- 2730145
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  -- meastmon 08/23/2001 Bug#1912417
  -- We need to resequence first and then value id conversion

  l_Actual_Rec := p_Actual_Rec;

  -- mdamle 01/15/2001 - Resequence the dimensions levels for product teams still using Org and Time
  IF (l_actual_rec.org_level_value_id IS NOT NULL) AND
     (l_actual_rec.time_level_value_id IS NOT NULL) THEN
        l_actual_rec_p := l_actual_rec;
	 BIS_UTILITIES_PVT.RESEQ_ACTUAL_DIM_LEVEL_VALUES
	   (p_dim_values_rec    => l_actual_rec_p
	   ,p_sequence_dir      => 'N'
	   ,x_dim_values_rec    => l_actual_rec
	   ,x_error_tbl         => x_error_tbl);
  END IF;

  BIS_ACTUAL_PVT.Value_ID_Conversion
  ( p_api_version   => p_api_version
  , p_Actual_Rec    => l_Actual_Rec
  , x_Actual_Rec    => l_Actual_Rec_Validated -- l_Actual_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );

  BIS_ACTUAL_PVT.Post_Actual
  ( p_api_version   => p_api_version
  , p_commit        => p_commit
  , p_Actual_Rec    => l_Actual_Rec_Validated -- l_Actual_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );

EXCEPTION
   when FND_API.G_EXC_ERROR then
  --dbms_output.put_line('PUB 1 Exception');
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
  --dbms_output.put_line('PUB 2 Exception');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
  --dbms_output.put_line('PUB 3 Exception');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Actual'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Post_Actual;

PROCEDURE Retrieve_Actual
(  p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 Default FND_API.G_FALSE
  ,p_validation_level             IN NUMBER  Default FND_API.G_VALID_LEVEL_FULL  ,p_all_info                     IN VARCHAR2 Default FND_API.G_TRUE
  ,p_Actual_Rec                   IN BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_Actual_Rec                   OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

 l_actual_rec       BIS_ACTUAL_PUB.Actual_Rec_Type;
 l_actual_rec_p     BIS_ACTUAL_PUB.Actual_Rec_Type;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- dbms_output.put_line('In PUB Retrieve_Actual');

  BIS_ACTUAL_PVT.Value_ID_Conversion
  ( p_api_version   => p_api_version
  , p_Actual_Rec    => p_Actual_Rec
  , x_Actual_Rec    => l_Actual_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );

  -- mdamle 01/15/2001 - Resequence the dimensions levels for product teams still using Org and Time
  IF (l_actual_rec.org_level_value_id IS NOT NULL) AND
     (l_actual_rec.time_level_value_id IS NOT NULL) THEN
     l_actual_rec_p := l_actual_rec;
     BIS_UTILITIES_PVT.reseq_actual_dim_level_values(
        l_actual_rec_p
       ,'N'
       ,l_Actual_Rec
       ,x_error_tbl
     );
   END IF;

  BIS_ACTUAL_PVT.Retrieve_Actual
  ( p_api_version      => 1.0
  , p_all_info         => p_all_info
  , p_Actual_Rec       => l_Actual_Rec
  , x_Actual_rec       => x_Actual_rec
  , x_return_status    => x_return_status
  , x_error_Tbl        => x_error_Tbl
  );

  l_actual_rec_p := x_Actual_Rec;

  -- mdamle 01/12/2001 Resequence the dimensions levels for product teams still using Org and Time
  BIS_UTILITIES_PVT.reseq_actual_dim_level_values (
     l_actual_rec_p
    ,'R'
    ,x_Actual_Rec
    ,x_error_tbl
  );

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Retrieve_Actual;


-- Retrieves all actual values for the specified Indicator Level
-- i.e. all organizations, all time periods, etc.
-- If information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Actuals
(  p_api_version         IN NUMBER
  ,p_init_msg_list       IN VARCHAR2 Default FND_API.G_FALSE
  ,p_validation_level    IN NUMBER  Default FND_API.G_VALID_LEVEL_FULL
  ,p_all_info            IN VARCHAR2 Default FND_API.G_TRUE
  ,p_Target_Level_Rec IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
  ,x_Actual_Tbl          OUT NOCOPY BIS_ACTUAL_PUB.Actual_Tbl_Type
  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2
  ,x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- dbms_output.put_line('In PUB Retrieve_Actuals');

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Retrieve_Actuals;


-- Retrieves the most current actual value for the specified set
-- of dimension values. (time level value not necessary.)
-- If information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Latest_Actual
(  p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 Default FND_API.G_FALSE
  ,p_validation_level             IN NUMBER Default FND_API.G_VALID_LEVEL_FULL
  ,p_all_info                     IN VARCHAR2 Default FND_API.G_TRUE
  ,p_Actual_Rec                   IN BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_Actual_Rec                   OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- dbms_output.put_line('In PUB Retrieve_Latest_Actual');

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Retrieve_Latest_Actual;


-- Retrieves the most current actual values for the specified Indicator Level
-- i.e. for all organizations, etc. (time level value not necessary.)
-- If information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Latest_Actuals
(  p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 Default FND_API.G_FALSE
  ,p_validation_level             IN NUMBER Default FND_API.G_VALID_LEVEL_FULL
  ,p_all_info                     IN VARCHAR2 Default FND_API.G_TRUE
  ,p_Target_Level_Rec IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
  ,x_Actual_Tbl                   OUT NOCOPY BIS_ACTUAL_PUB.Actual_Tbl_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- dbms_output.put_line('In PUB Retrieve_Latest_Actuals');

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Retrieve_Latest_Actuals;


PROCEDURE Validate_Actual
(  p_api_version          IN NUMBER
 , p_init_msg_list        IN VARCHAR2 Default FND_API.G_FALSE
 , p_validation_level     IN NUMBER Default FND_API.G_VALID_LEVEL_FULL
 , p_event                IN VARCHAR2
 , p_user_id              IN NUMBER
 , p_Actual_Rec           IN BIS_ACTUAL_PUB.Actual_Rec_Type
 , x_return_status        OUT NOCOPY VARCHAR2
 , x_msg_count            OUT NOCOPY NUMBER
 , x_msg_data             OUT NOCOPY VARCHAR2
  ,x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- dbms_output.put_line('In PUB Validate_Actual');



EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Validate_Actual;

END BIS_ACTUAL_PUB;

/
