--------------------------------------------------------
--  DDL for Package Body BIS_TARGET_LEVEL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_TARGET_LEVEL_PUB" AS
/* $Header: BISPTALB.pls 120.0 2005/06/01 15:39:59 appldev noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPMEAB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for creating and managing Performance Measurements
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 28-NOV-98 irchen Creation
REM | 23-JAN-03 mahrao For having different local variables for IN and OUT
REM |                  parameters.
REM | 30-JAN-03 sugopal FND_API.G_MISS_xxx should not be used in            |
REM |                   initialization or declaration (bug#2774644)         |
REM | 28-JUN-04 ankgoel  Removed Retrieve_Measure_Notify_Resps for          |
REM |                    bug#3634587                                        |
REM +=======================================================================+
*/
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_TARGET_LEVEL_PUB';


--
-- creates one Indicator Level
PROCEDURE Create_Target_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_Target_Level_Rec    IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_Target_Level_Rec BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  BIS_Target_Level_PVT.Value_ID_Conversion
  ( p_api_version         => p_api_version
  , p_Target_Level_Rec    => p_Target_Level_Rec
  , x_Target_Level_Rec    => l_Target_Level_Rec
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );

  BIS_Target_Level_PVT.Create_Target_Level
  ( p_api_version         => p_api_version
  , p_commit              => p_commit
  , p_Target_Level_Rec    => l_Target_Level_Rec
  , p_owner               => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );


EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Target_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Create_Target_Level;
--
--
-- Gets All Indicator Levels
-- If information about the dimensions are not required, set all_info to
-- FALSE
PROCEDURE Retrieve_Target_Levels
( p_api_version         IN  NUMBER
, p_all_info            IN  VARCHAR2   := FND_API.G_TRUE
, p_Measure_Rec         IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_Target_Level_tbl    OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_Measure_Rec   BIS_MEASURE_PUB.Measure_Rec_Type;
l_error_tbl        BIS_UTILITIES_PUB.Error_Tbl_Type;
l_target_level_tbl BIS_Target_Level_PUB.Target_Level_Tbl_Type;
BEGIN

  l_measure_rec := p_measure_rec;

  if (BIS_UTILITIES_PUB.Value_Missing
         (l_Measure_Rec.Measure_id) = FND_API.G_TRUE
    OR BIS_UTILITIES_PUB.Value_NULL(l_Measure_Rec.Measure_id)
                                    = FND_API.G_TRUE) then
    BIS_MEASURE_PVT.Value_ID_Conversion
    ( p_api_version         => p_api_version
    , p_Measure_Short_Name  => l_Measure_Rec.Measure_Short_Name
    , p_Measure_Name        => l_Measure_Rec.Measure_Name
    , x_Measure_ID          => l_Measure_Rec.Measure_Id
    , x_return_status       => x_return_status
    , x_error_Tbl           => x_error_Tbl
    );
  end if;

  BIS_Target_Level_PVT.Retrieve_Target_Levels
  ( p_api_version         => p_api_version
  , p_all_info            => p_all_info
  , p_MeasurE_rec         => l_Measure_Rec
  , x_Target_Level_tbl    => x_Target_Level_tbl
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );
  -- Put the values in Org and Time Levels for the product teams still using this
  IF (x_target_level_tbl.COUNT > 0) THEN
	  l_target_level_tbl := x_target_level_tbl;
    FOR l_count IN 1..l_target_level_tbl.COUNT LOOP
        BIS_UTILITIES_PVT.resequence_dim_levels(l_target_level_tbl(l_count),
					        'R',
                                  	         x_target_level_tbl(l_count),
				                 x_Error_tbl);
        END LOOP;
  END IF;
--
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    	l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target_Levels'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_Target_Levels;
--
--
-- Gets Information for one Indicator Level
-- If information about the dimension are not required, set all_info to FALSE.
PROCEDURE Retrieve_Target_Level
( p_api_version      IN  NUMBER
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_all_info         IN  VARCHAR2   := FND_API.G_TRUE
, x_Target_Level_Rec IN OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_Target_Level_Rec BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Target_Level_Rec_p BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  l_target_level_rec := p_target_level_rec;

  BIS_Target_Level_PVT.Value_ID_Conversion
  ( p_api_version      => p_api_version
  , p_Target_Level_Rec => p_Target_Level_Rec
  , x_Target_Level_Rec => l_Target_Level_Rec
  , x_return_status    => x_return_status
  , x_error_Tbl        => x_error_Tbl
  );
  -- This is for backward compatibility. For the Product teams which still us Org/Time stuff
  -- in their code , the data model changes will be transparent.
  IF (l_target_level_rec.org_level_id IS NOT NULL) AND
     (l_target_level_rec.time_level_id IS NOT NULL) THEN
     --resequence the dimensions
     l_target_level_rec_p := l_target_level_rec;
		 BIS_UTILITIES_PVT.resequence_dim_levels(l_target_level_rec_p,
					'N',
                                  	l_target_level_Rec,
				        x_Error_tbl);
  END IF;


  BIS_Target_Level_PVT.Retrieve_Target_Level
  ( p_api_version         => p_api_version
  , p_Target_Level_Rec    => l_Target_Level_Rec
  , p_all_info            => p_all_info
  , x_Target_Level_Rec    => x_Target_Level_Rec
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );


  --For the time being
  if(x_return_status = FND_API.G_RET_STS_SUCCESS) then

    --Put the values back in Org/Time level stuff for product teams using this API
     l_target_level_rec_p := x_target_level_rec;
		 BIS_UTILITIES_PVT.resequence_dim_levels(l_target_level_rec_p,
					'R',
                                  	x_target_level_Rec,
				        x_error_tbl);
   end if;


EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_Target_Level;
--
--
-- Update_Target_Levels
PROCEDURE Update_Target_Level
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_Target_Level_Rec BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  BIS_Target_Level_PVT.Value_ID_Conversion
  ( p_api_version         => p_api_version
  , p_Target_Level_Rec    => p_Target_Level_Rec
  , x_Target_Level_Rec    => l_Target_Level_Rec
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );

  BIS_Target_Level_PVT.Update_Target_Level
  ( p_api_version         => p_api_version
  , p_commit              => p_commit
  , p_Target_Level_Rec    => l_Target_Level_Rec
  , p_owner               => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    	l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Update_Target_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Update_Target_Level;
--
--
-- deletes one Target_Level
PROCEDURE Delete_Target_Level
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_Target_Level_Rec BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_target_level_rec := p_target_level_rec;

  if (  BIS_UTILITIES_PUB.Value_Missing
         (p_Target_Level_Rec.Target_Level_id) = FND_API.G_TRUE
    OR BIS_UTILITIES_PUB.Value_NULL
         (p_Target_Level_Rec.Target_Level_id) = FND_API.G_TRUE) then
      BIS_Target_Level_PVT.Value_ID_Conversion
      ( p_api_version
      , p_Target_Level_Rec.Target_Level_Short_Name
      , p_Target_Level_Rec.Target_Level_Name
      , l_Target_Level_Rec.Target_Level_ID
      , x_return_status
      , x_error_Tbl
      );
  end if;

  BIS_Target_Level_PVT.Delete_Target_Level
  ( p_api_version         => p_api_version
  , p_commit              => p_commit
  , p_Target_Level_Rec    => l_Target_Level_Rec
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );


EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    	l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Delete_Target_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Delete_Target_Level;
--
--
-- Validates measure
PROCEDURE Validate_Target_Level
( p_api_version      IN  NUMBER
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_Target_Level_Rec BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  BIS_Target_Level_PVT.Value_ID_Conversion
  ( p_api_version         => p_api_version
  , p_Target_Level_Rec => p_Target_Level_Rec
  , x_Target_Level_Rec => l_Target_Level_Rec
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );

  BIS_Target_Level_PVT.Validate_Target_Level
  ( p_api_version         => p_api_version
  , p_Target_Level_Rec => p_Target_Level_Rec
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    	l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Target_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Validate_Target_Level;
--
PROCEDURE Get_User_Id
( p_api_version      IN NUMBER
, p_user_name        IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
, x_user_id          OUT NOCOPY NUMBER
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
is
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  select user_id into x_user_id
  from fnd_user where user_name = p_user_name
  and start_date <= sysdate
  and NVL(end_date,sysdate) >= sysdate;


EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    	l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Get_User_Id'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Get_User_Id;
--
Procedure Retrieve_User_Target_Levels
( p_api_version      IN NUMBER
, p_user_id          IN NUMBER
, p_user_name        IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
, p_all_info         IN VARCHAR2 := FND_API.G_TRUE
, x_Target_Level_Tbl OUT NOCOPY BIS_Target_LEVEL_PUB.Target_Level_Tbl_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_user_id number := p_user_id;
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  --checked for null also
  if (BIS_UTILITIES_PUB.Value_Missing(l_user_id) = FND_API.G_TRUE
     OR BIS_UTILITIES_PUB.Value_NULL(l_user_id)
                                    = FND_API.G_TRUE)
  then

    Get_User_Id( p_api_version   => 1.0
               , p_user_name     => p_user_name
               , x_user_id       => l_user_id
               , x_return_status => x_return_status
               , x_error_tbl     => x_error_tbl
               );



 end if;

  --passed in l_user_id instead of p_user_id
  BIS_Target_Level_PVT.Retrieve_User_Target_Levels
  ( p_api_version
  , l_user_id
  , p_all_info
  , x_Target_Level_Tbl
  , x_return_status
  , x_error_tbl
  );


EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    	l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_User_Target_Levels'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_User_Target_Levels;

--
Procedure Translate_Target_Level
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_Target_Level_Rec  IN  BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
, p_owner             IN  VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_Target_Level_Rec BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  BIS_TARGET_LEVEL_PVT.Value_ID_Conversion
  ( p_api_version      => p_api_version
  , p_Target_Level_Rec => p_Target_Level_Rec
  , x_Target_Level_Rec => l_Target_Level_Rec
  , x_return_status    => x_return_status
  , x_error_Tbl        => x_error_tbl
  );

  --added last two parameters
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
  	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_TAR_LEVEL_ID'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Translate_Target_Level'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
     , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;

  BIS_TARGET_LEVEL_PVT.Translate_Target_Level
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Target_Level_Rec  => l_Target_Level_Rec
  , p_owner             => p_owner
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    	l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Translate_Target_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Translate_Target_Level ;
--
Procedure Load_Target_Level
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Level_Rec  IN  BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
, p_owner             IN  VARCHAR2
, p_up_loaded         IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Target_Level_Rec     BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
  l_return_status 	 VARCHAR2(100);  -- 2486702
  l_return_msg 	       VARCHAR2(3000);  -- 2486702
  l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  l_Target_Level_Rec := p_Target_Level_Rec;

  BIS_TARGET_LEVEL_PVT.Value_ID_Conversion
  ( p_api_version      => p_api_version
  , p_Target_Level_Rec => p_Target_Level_Rec
  , x_Target_Level_Rec => l_Target_Level_Rec
  , x_return_status    => x_return_status
  , x_error_Tbl        => x_error_tbl
  );

  BIS_TARGET_LEVEL_PVT.Validate_Dimensions			-- 2486702
  (
    p_target_level_rec 	=> l_Target_Level_Rec
  , x_return_status 	=> l_return_status
  , x_return_msg 	      => l_return_msg
  );        -- BIS_UTILITIES_PUB.put_line(p_text => ' ok 2 x_return_status = ' || x_return_status ) ;

  IF ( l_return_status <> 'S' )  THEN  	  	 		-- 2486702
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  BIS_TARGET_LEVEL_PVT.Update_Target_Level
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Target_Level_Rec  => l_Target_Level_Rec
  , p_owner             => p_owner
  , p_up_loaded         => p_up_loaded
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

  IF x_return_status = FND_API.G_RET_STS_ERROR then

     BIS_TARGET_LEVEL_PVT.Create_Target_Level
     ( p_api_version       => p_api_version
     , p_commit            => p_commit
     , p_validation_level  => p_validation_level
     , p_Target_Level_Rec  => l_Target_Level_Rec
     , p_owner             => p_owner
     , x_return_status     => x_return_status
     , x_error_Tbl         => x_error_Tbl
     );
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    	l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Load_Target_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Load_Target_Level ;

--New Function to return target level id from shortname

FUNCTION Get_Id_From_DimLevelShortNames
( p_target_level_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
) RETURN NUMBER
IS
l_target_level_id NUMBER;
BEGIN
   l_target_level_id :=BIS_TARGET_LEVEL_PVT.Get_Id_From_DimLevelShortNames(p_target_level_rec);
   return l_target_level_id;
END Get_Id_From_DimLevelShortNames;

-- New Procedure to return TargetLevel given the DimensionLevel ShortNames in any sequence
-- and the Measure Short Name

PROCEDURE Retrieve_TL_From_DimLvlShNms
(p_api_version   IN  NUMBER
,p_target_level_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Target_Level_Rec OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
  BIS_Target_Level_PVT.Retrieve_TL_From_DimLvlShNms
  (
    p_api_version   =>  p_api_version
  , p_Target_Level_Rec  => p_Target_Level_Rec
  , x_Target_Level_Rec  => x_Target_Level_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    	l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
END Retrieve_TL_From_DimLvlShNms;

-- Given a target level short name update the
--  bis_target_levels, bis_target_levels_tl
-- for last_updated_by , created_by as 1
PROCEDURE updt_tl_attributes(p_tl_short_name  IN VARCHAR2
                       ,p_tl_new_short_name  IN VARCHAR2
                       ,x_return_status OUT NOCOPY VARCHAR2) AS
BEGIN
  BIS_TARGET_LEVEL_PVT.updt_tl_attributes(p_tl_short_name  => p_tl_short_name
                       ,p_tl_new_short_name => p_tl_new_short_name
                               ,x_return_status  => x_return_status);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END updt_tl_attributes;

--
--
END BIS_Target_Level_PUB;



/
