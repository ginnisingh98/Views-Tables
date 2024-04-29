--------------------------------------------------------
--  DDL for Package Body BIS_MEASURE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_MEASURE_PUB" AS
/* $Header: BISPMEAB.pls 120.0 2005/06/01 17:02:39 appldev noship $ */
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
REM |
REM | 27-JAN-03 arhegde For having different local variables for IN and OUT |
REM |                   parameters (bug#2758428)                            |
REM | 25-SEP-03 mdamle  Bug#3160325 - Sync up measures for all installed    |
REM |                   languages                       |
REM | 29-SEP-2003 adrao  Bug#3160325 - Sync up measures for all installed   |
REM |                    source languages                                   |
REM | 12-NOV-2003 smargand  added new function to determine whether the     |
REM |                       given indicator is customized                   |
REM | 27-JUL-2004 sawu      Propagated p_owner to PVT apis for create/update|
REM +=======================================================================+
*/
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_MEASURE_PUB';


-- creates one Measure, with the dimensions sequenced in the order
-- they are passed in
Procedure Create_Measure
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_Rec   IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner            IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Measure_Rec BIS_MEASURE_PUB.Measure_Rec_Type;
  l_measure_rec_p BIS_MEASURE_PUB.Measure_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  if (BIS_UTILITIES_PUB.Value_Missing
         (p_Measure_Rec.Measure_id) = FND_API.G_TRUE
    OR BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Measure_id)
                                    = FND_API.G_TRUE) then
     --changed to call Measure_Value_ID_Conversion
     BIS_Measure_PVT.Measure_Value_ID_Conversion
         ( p_api_version   => p_api_version
     , p_Measure_Rec   => p_Measure_Rec
     , x_Measure_Rec   => l_Measure_Rec
     , x_return_status => x_return_status
     , x_error_Tbl     => x_error_Tbl
     );
      --Added this check
      IF( x_return_status = FND_API.G_RET_STS_SUCCESS) then
        l_error_tbl := x_error_tbl;
        BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_MEASURE_SHORT_NAME_UNIQUE'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Create_Measure'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
       );
       RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;



  -- used the following proc instead and added the if check
   l_measure_rec_p := l_Measure_Rec;
   BIS_MEASURE_PVT.Dimension_Value_ID_Conversion
  ( p_api_version   => p_api_version
  , p_Measure_Rec   => l_measure_rec_p
  , x_Measure_Rec   => l_Measure_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_tbl
  );

 --Added this check
  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    RAISE FND_API.G_EXC_ERROR;
  END IF;

 BIS_Measure_PVT.Create_Measure
  ( p_api_version   => p_api_version
  , p_commit        => p_commit
  , p_Measure_Rec   => l_Measure_Rec
  , p_owner           => p_owner
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );


EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Create_Measure;
--
--
-- Gets All Performance Measures
-- If information about the dimensions are not required, set all_info to
-- FALSE
Procedure Retrieve_Measures
( p_api_version   IN  NUMBER
, p_all_info      IN  VARCHAR2   := FND_API.G_TRUE
, x_Measure_tbl   OUT NOCOPY BIS_MEASURE_PUB.Measure_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Measure_Rec BIS_Measure_PUB.Measure_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  BIS_Measure_PVT.Retrieve_Measures
  ( p_api_version         => p_api_version
  , p_all_info            => p_all_info
  , x_Measure_Tbl         => x_Measure_Tbl
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );


EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Measures'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_Measures;
--
--
-- Gets Information for One Performance Measure
-- If information about the dimension are not required, set all_info to FALSE.
Procedure Retrieve_Measure
( p_api_version   IN  NUMBER
, p_Measure_Rec   IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_all_info      IN  VARCHAR2   := FND_API.G_TRUE
, x_Measure_Rec   IN OUT NOCOPY BIS_MEASURE_PUB.Measure_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_Measure_Rec BIS_Measure_PUB.Measure_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
   l_measure_rec := p_measure_rec;

   if (BIS_UTILITIES_PUB.Value_Missing
       (p_Measure_Rec.Measure_id) = FND_API.G_TRUE
       OR
       BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Measure_id) = FND_API.G_TRUE)
     THEN
      --changed to call Measure_Value_ID_Conversion
      BIS_Measure_PVT.Measure_Value_ID_Conversion
    ( p_api_version         => p_api_version
      , p_Measure_Rec         => p_Measure_Rec
      , x_Measure_Rec         => l_Measure_Rec
      , x_return_status       => x_return_status
      , x_error_Tbl           => x_error_Tbl
     );

      --Added this check
      IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) then
        RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF;

  BIS_Measure_PVT.Retrieve_Measure
  ( p_api_version         => p_api_version
  , p_Measure_Rec         => l_Measure_Rec
  , p_all_info            => p_all_info
  , x_Measure_Rec         => x_Measure_Rec
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );


EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_Measure;
--
--
-- PLEASE VERIFY COMMENT BELOW
-- Update_Measures one Measure if
--   1) no Measure levels or targets exist
--   2) no users have selected to see actuals for the Measure
Procedure Update_Measure
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_Rec   IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner            IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Measure_Rec BIS_MEASURE_PUB.Measure_Rec_Type;
  l_measure_rec_p BIS_MEASURE_PUB.Measure_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

   l_measure_rec := p_measure_rec;

  if (BIS_UTILITIES_PUB.Value_Missing
         (p_Measure_Rec.Measure_id) = FND_API.G_TRUE
    OR BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Measure_id)
                                    = FND_API.G_TRUE) then
     --changed to call Measure_Value_ID_Conversion
     BIS_Measure_PVT.Measure_Value_ID_Conversion
       ( p_api_version   => p_api_version
     , p_Measure_Rec   => p_Measure_Rec
     , x_Measure_Rec   => l_Measure_Rec
     , x_return_status => x_return_status
     , x_error_Tbl     => x_error_Tbl
       );
      --added this check
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
           RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

   --added this call
     l_measure_rec_p := l_Measure_Rec;
     BIS_Measure_PVT.Dimension_Value_ID_Conversion
       ( p_api_version   => p_api_version
     , p_Measure_Rec   => l_measure_rec_p
     , x_Measure_Rec   => l_Measure_Rec
     , x_return_status => x_return_status
     , x_error_Tbl     => x_error_Tbl
       );
      --added this check
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
           RAISE FND_API.G_EXC_ERROR;
     END IF;

  BIS_Measure_PVT.Update_Measure
  ( p_api_version   => p_api_version
  , p_commit        => p_commit
  , p_Measure_Rec   => l_Measure_Rec
  , p_owner         => p_owner
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );


EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Update_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Update_Measure;
--
--
-- PLEASE VERIFY COMMENT BELOW
-- deletes one Measure if
-- 1) no Measure levels, targets exist and
-- 2) the Measure access has not been granted to a resonsibility
-- 3) no users have selected to see actuals for the Measure
Procedure Delete_Measure
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_Rec   IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Measure_Rec BIS_MEASURE_PUB.Measure_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  l_Measure_Rec := p_Measure_rec;
  if (BIS_UTILITIES_PUB.Value_Missing
         (p_Measure_Rec.Measure_id) = FND_API.G_TRUE
    OR BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Measure_id)
                                    = FND_API.G_TRUE) then
      --changed to call Measure_Value_ID_Conversion
      --used to call Value_ID_Conv with shortname
      BIS_Measure_PVT.Measure_Value_ID_Conversion
      ( p_api_version   => p_api_version
     , p_Measure_Rec   => p_Measure_Rec
     , x_Measure_Rec   => l_Measure_Rec
     , x_return_status => x_return_status
     , x_error_Tbl     => x_error_Tbl
       );
        --added this check
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
           RAISE FND_API.G_EXC_ERROR;
     END IF;

  end if;

  BIS_Measure_PVT.Delete_Measure
  ( p_api_version   => p_api_version
  , p_commit        => p_commit
  , p_Measure_Rec   => l_Measure_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Delete_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Delete_Measure;
--
--
-- Validates measure
PROCEDURE Validate_Measure
( p_api_version     IN  NUMBER
, p_Measure_Rec     IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Measure_Rec BIS_MEASURE_PUB.Measure_Rec_Type;
  l_measure_rec_p BIS_MEASURE_PUB.Measure_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  l_Measure_Rec := p_Measure_Rec;
  --changed to call Measure_Value_ID_Conversion
  BIS_Measure_PVT.Measure_Value_ID_Conversion
  ( p_api_version   => p_api_version
  , p_Measure_Rec   => p_Measure_Rec
  , x_Measure_Rec   => l_Measure_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );
   --added this check
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  --added this call
  l_measure_rec_p := l_Measure_Rec;
  BIS_Measure_PVT.Dimension_Value_ID_Conversion
  ( p_api_version   => p_api_version
  , p_Measure_Rec   => l_measure_rec_p
  , x_Measure_Rec   => l_Measure_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );
  --added this check
 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
     RAISE FND_API.G_EXC_ERROR;
 END IF;

  BIS_Measure_PVT.Validate_Measure
  ( p_api_version     => p_api_version
  , p_Measure_Rec     => l_Measure_Rec
  , x_return_status   => x_return_status
  , x_error_Tbl       => x_error_Tbl
  );


EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Validate_Measure;
--
Procedure Retrieve_Measure_Dimensions
( p_api_version   IN  NUMBER
, p_Measure_Rec   IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_dimension_Tbl OUT NOCOPY BIS_DIMENSION_PUB.Dimension_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Measure_Rec BIS_MEASURE_PUB.Measure_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  l_measure_rec := p_measure_rec;

  if (BIS_UTILITIES_PUB.Value_Missing
         (l_Measure_Rec.Measure_id) = FND_API.G_TRUE
    OR BIS_UTILITIES_PUB.Value_NULL(l_Measure_Rec.Measure_id)
                                    = FND_API.G_TRUE) then
    --changed to call Measure_Value_ID_Conversion
    --used to call Value_ID_Conversion with short name
    BIS_MEASURE_PVT.Measure_Value_ID_Conversion
    ( p_api_version   => p_api_version
    , p_Measure_Rec   => p_Measure_Rec
    , x_Measure_Rec   => l_Measure_Rec
    , x_return_status => x_return_status
    , x_error_Tbl     => x_error_Tbl
    );
     --added this check
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
        RAISE FND_API.G_EXC_ERROR;
    END IF;
  end if;

  BIS_Measure_PVT.Retrieve_Measure_Dimensions
  ( p_api_version     => p_api_version
  , p_Measure_Rec     => l_Measure_Rec
  , x_dimension_Tbl   => x_dimension_Tbl
  , x_return_status   => x_return_status
  , x_error_Tbl       => x_error_Tbl
  );


EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Measure_Dimensions'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_Measure_Dimensions;
--
--
Procedure Translate_Measure
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec     IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Measure_Rec BIS_MEASURE_PUB.Measure_Rec_Type;
  l_measure_rec_p BIS_MEASURE_PUB.Measure_Rec_Type;
  l_return_status  VARCHAR2(10);
  l_return_msg     VARCHAR2(32000);
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  bis_utilities_pvt.init_debug_flag -- 2694978
  ( x_return_status   => l_return_status
  , x_return_msg      => l_return_msg
  );

  l_Measure_Rec := p_Measure_Rec;

  --changed to call Measure_Value_ID_Conversion
  BIS_MEASURE_PVT.Measure_Value_ID_Conversion
  ( p_api_version   => p_api_version
  , p_Measure_Rec => p_Measure_Rec
  , x_Measure_Rec => l_Measure_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_tbl
  );

  --just if check
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
     RAISE FND_API.G_EXC_ERROR;
  end if;

  --added this call
     l_measure_rec_p := l_Measure_Rec;
     BIS_Measure_PVT.Dimension_Value_ID_Conversion
     ( p_api_version   => p_api_version
     , p_Measure_Rec   => l_measure_rec_p
     , x_Measure_Rec   => l_Measure_Rec
     , x_return_status => x_return_status
     , x_error_Tbl     => x_error_Tbl
     );

     --added this check
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
       RAISE FND_API.G_EXC_ERROR;
     END IF;

  BIS_MEASURE_PVT.Translate_Measure
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Measure_Rec       => l_Measure_Rec
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
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Translate_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Translate_Measure ;
--
Procedure Load_Measure
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Measure_Rec BIS_MEASURE_PUB.Measure_Rec_Type;
  l_measure_rec_p BIS_MEASURE_PUB.Measure_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  l_measure_rec := p_measure_rec;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BEGIN
  --added check
  if (BIS_UTILITIES_PUB.Value_Missing
         (p_Measure_Rec.Measure_id) = FND_API.G_TRUE
    OR BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Measure_id)
                                    = FND_API.G_TRUE) then
      --changed to call Measure_Value_ID_Conversion
      BIS_MEASURE_PVT.Measure_Value_ID_Conversion
      ( p_api_version   => p_api_version
      , p_Measure_Rec   => p_Measure_Rec
      , x_Measure_Rec   => l_Measure_Rec
      , x_return_status => x_return_status
      , x_error_Tbl     => x_error_tbl
     );
  end if;

 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
     l_measure_rec_p := l_Measure_Rec;
     --added this call
     BIS_Measure_PVT.Dimension_Value_ID_Conversion
     ( p_api_version   => p_api_version
     , p_Measure_Rec   => l_measure_rec_p
     , x_Measure_Rec   => l_Measure_Rec
     , x_return_status => x_return_status
     , x_error_Tbl     => x_error_Tbl
     );
     --added this check
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     BIS_MEASURE_PVT.Create_Measure
     ( p_api_version       => p_api_version
     , p_commit            => p_commit
     , p_validation_level  => p_validation_level
     , p_Measure_Rec       => l_Measure_Rec
     , p_owner             => p_owner
     , x_return_status     => x_return_status
     , x_error_Tbl         => x_error_Tbl
     );
  ELSE
     --added this call
     l_measure_rec_p := l_Measure_Rec;
     BIS_Measure_PVT.Dimension_Value_ID_Conversion
     ( p_api_version   => p_api_version
     , p_Measure_Rec   => l_measure_rec_p
     , x_Measure_Rec   => l_Measure_Rec
     , x_return_status => x_return_status
     , x_error_Tbl     => x_error_Tbl
     );
   --added this check
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     BIS_MEASURE_PVT.Update_Measure
    ( p_api_version       => p_api_version
    , p_commit            => p_commit
    , p_validation_level  => p_validation_level
    , p_Measure_Rec       => l_Measure_Rec
    , p_owner             => p_owner
    , x_return_status     => x_return_status
    , x_error_Tbl         => x_error_Tbl
    );

  END IF;

END;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Load_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Load_Measure ;


--
--Overload Load_Measure so that old data model ldts can be uploaded using
--The latest lct file. The lct file can call this overloaded procedure
--by passing in Org and Time dimension short_names also
Procedure Load_Measure
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, p_Org_Dimension_Short_Name  IN  VARCHAR2
, p_Time_Dimension_Short_Name IN  VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Measure_Rec BIS_MEASURE_PUB.Measure_Rec_Type;
  l_measure_rec_p BIS_MEASURE_PUB.Measure_Rec_Type;
  l_Org_Dimension_ID NUMBER;
  l_Time_Dimension_ID NUMBER;
  l_msg     VARCHAR2(3000);
  l_return_status  VARCHAR2(10);
  l_return_msg     VARCHAR2(32000);
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  bis_utilities_pvt.init_debug_flag -- 2694978
  ( x_return_status   => l_return_status
  , x_return_msg      => l_return_msg
  );

  -- BIS_UTILITIES_PUB.put_line(p_text =>'XXXXXXXXX');

  /*
  fnd_message.set_name('BIS', 'BIS_KPI_NOT_CREATED');
  fnd_message.set_token('NAME', p_measure_rec.measure_name);
  l_msg := fnd_message.get;
  */

  l_msg := 'The Performance Measure ' || p_measure_rec.measure_name ;
  l_msg := l_msg || ' could not be created/updated.';


  l_measure_rec := p_measure_rec;
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  IF (BIS_UTILITIES_PUB.Value_Missing
         (p_Measure_Rec.Measure_id) = FND_API.G_TRUE
    OR BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Measure_id)
                                    = FND_API.G_TRUE) then
      BIS_MEASURE_PVT.Measure_Value_ID_Conversion
      ( p_api_version   => p_api_version
      , p_Measure_Rec   => p_Measure_Rec
      , x_Measure_Rec   => l_Measure_Rec
      , x_return_status => x_return_status
      , x_error_Tbl     => x_error_tbl
     );
  END IF;


  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
     l_measure_rec_p := l_Measure_Rec;
     BIS_Measure_PVT.Dimension_Value_ID_Conversion
     ( p_api_version   => p_api_version
     , p_Measure_Rec   => l_measure_rec_p
     , x_Measure_Rec   => l_Measure_Rec
     , x_return_status => x_return_status
     , x_error_Tbl     => x_error_Tbl
     );

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
       RAISE FND_API.G_EXC_ERROR;
     END IF;


     IF (BIS_UTILITIES_PUB.Value_Not_Missing
         (p_Org_Dimension_Short_Name) = FND_API.G_TRUE
     AND BIS_UTILITIES_PUB.Value_Not_NULL(p_Org_Dimension_Short_Name)
                                    = FND_API.G_TRUE) then
       BIS_DIMENSION_PVT.Value_ID_Conversion
       ( p_api_version => p_api_version
       , p_Dimension_Short_Name => p_Org_Dimension_Short_Name
       , p_Dimension_Name => FND_API.G_MISS_CHAR
       , x_Dimension_ID => l_Org_Dimension_ID
       , x_return_status => x_return_status
       , x_error_Tbl => x_error_Tbl
       );

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
         RAISE FND_API.G_EXC_ERROR;
       END IF;

     END IF;

     -- added this call for getting Time Dimension Id
     IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_Time_Dimension_Short_Name) = FND_API.G_TRUE
          AND BIS_UTILITIES_PUB.Value_Not_NULL(p_Time_Dimension_Short_Name)
                                    = FND_API.G_TRUE) THEN
       BIS_DIMENSION_PVT.Value_ID_Conversion
       ( p_api_version => p_api_version
       , p_Dimension_Short_Name => p_Time_Dimension_Short_Name
       , p_Dimension_Name => FND_API.G_MISS_CHAR
       , x_Dimension_ID => l_Time_Dimension_ID
       , x_return_status => x_return_status
       , x_error_Tbl => x_error_Tbl
       );

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
         RAISE FND_API.G_EXC_ERROR;
       END IF;

     END IF;

     -- Changed to call the new overloaded Create_Measure
     BIS_MEASURE_PVT.Create_Measure
     ( p_api_version       => p_api_version
     , p_commit            => p_commit
     , p_validation_level  => p_validation_level
     , p_Measure_Rec       => l_Measure_Rec
     , p_owner             => p_owner
     , p_Org_Dimension_ID  => l_Org_Dimension_ID
     , p_Time_Dimension_ID => l_Time_Dimension_ID
     , x_return_status     => x_return_status
     , x_error_Tbl         => x_error_Tbl
     );

  ELSE
     l_measure_rec_p := l_Measure_Rec;
     BIS_Measure_PVT.Dimension_Value_ID_Conversion
     ( p_api_version   => p_api_version
     , p_Measure_Rec   => l_measure_rec_p
     , x_Measure_Rec   => l_Measure_Rec
     , x_return_status => x_return_status
     , x_error_Tbl     => x_error_Tbl
     );

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- added this call for getting Org Dimension Id
     IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_Org_Dimension_Short_Name) = FND_API.G_TRUE
       AND BIS_UTILITIES_PUB.Value_Not_NULL(p_Org_Dimension_Short_Name)
                                    = FND_API.G_TRUE) THEN
       BIS_DIMENSION_PVT.Value_ID_Conversion
       ( p_api_version => p_api_version
       , p_Dimension_Short_Name => p_Org_Dimension_Short_Name
       , p_Dimension_Name => FND_API.G_MISS_CHAR
       , x_Dimension_ID => l_Org_Dimension_ID
       , x_return_status => x_return_status
       , x_error_Tbl => x_error_Tbl
       );

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
         RAISE FND_API.G_EXC_ERROR;
       END IF;

     END IF;

     -- added this call for getting Time Dimension Id
     IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_Time_Dimension_Short_Name) = FND_API.G_TRUE
       AND BIS_UTILITIES_PUB.Value_Not_NULL(p_Time_Dimension_Short_Name)
                                    = FND_API.G_TRUE) THEN

       BIS_DIMENSION_PVT.Value_ID_Conversion
       ( p_api_version => p_api_version
       , p_Dimension_Short_Name => p_Time_Dimension_Short_Name
       , p_Dimension_Name => FND_API.G_MISS_CHAR
       , x_Dimension_ID => l_Time_Dimension_ID
       , x_return_status => x_return_status
       , x_error_Tbl => x_error_Tbl
       );

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
         RAISE FND_API.G_EXC_ERROR;
       END IF;

     END IF;

     -- Changed to call the new overloaded Create_Measure
     BIS_MEASURE_PVT.Update_Measure
     ( p_api_version       => p_api_version
     , p_commit            => p_commit
     , p_validation_level  => p_validation_level
     , p_Measure_Rec       => l_Measure_Rec
     , p_owner             => p_owner
     , p_Org_Dimension_ID  => l_Org_Dimension_ID
     , p_Time_Dimension_ID => l_Time_Dimension_ID
     , x_return_status     => x_return_status
     , x_error_Tbl         => x_error_Tbl
     );

  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      BIS_UTILITIES_PUB.put_line(p_text =>l_msg);
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      BIS_UTILITIES_PUB.put_line(p_text =>l_msg);
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      BIS_UTILITIES_PUB.put_line(p_text =>l_msg);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      BIS_UTILITIES_PUB.put_line(p_text =>l_msg);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Load_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Load_Measure ;
--
-- Given a performance measure short name update the
--  bis_indicators, bis_indicators_tl and  bis_indicator_dimensions
-- for last_updated_by , created_by as 1
PROCEDURE updt_pm_owner(p_pm_short_name  IN VARCHAR2
                       ,x_return_status OUT NOCOPY VARCHAR2) AS
BEGIN
  BIS_MEASURE_PVT.updt_pm_owner(p_pm_short_name  => p_pm_short_name
                               ,x_return_status  => x_return_status);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END updt_pm_owner;

-- mdamle 09/25/2003 - Sync up measures for all installed languages
Procedure Translate_Measure_By_lang
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2 := FND_API.G_FALSE
, p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, p_lang              IN  VARCHAR2
, p_source_lang       IN  VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

BEGIN

  BIS_MEASURE_PVT.Translate_Measure_By_lang
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_Measure_Rec       => p_Measure_Rec
  , p_owner             => p_owner
  , p_lang              => p_lang
  , p_source_lang       => p_source_lang
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
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Translate_Measure'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );

END Translate_Measure_by_lang ;
--added new function to determine whether the given indicator is customized

FUNCTION GET_CUSTOMIZED_ENABLED( p_indicator_id IN NUMBER )
RETURN VARCHAR2
 IS
BEGIN
 RETURN BIS_MEASURE_PVT.GET_CUSTOMIZED_ENABLED (p_indicator_id => p_indicator_id);

END GET_CUSTOMIZED_ENABLED;

END BIS_MEASURE_PUB;

/
