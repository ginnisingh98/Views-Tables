--------------------------------------------------------
--  DDL for Package Body BIS_DIMENSION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_DIMENSION_PUB" AS
/* $Header: BISPDIMB.pls 120.2 2006/01/06 03:22:23 akoduri noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPDIMB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for managing Dimensions and dimension levels for the
REM |     Key Performance Framework.
REM |
REM |     This package should be maintaind by EDW once it gets integrated
REM |     with BIS.
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 05-DEC-98 irchen   Creation
REM | 01-FEB-99 ansingha added required dimension api
REM | 27-JAN-03 arhegde For having different local variables for IN and OUT |
REM |                   parameters (bug#2758428)                            |
REM | 20-FEB-03 PAJOHRI  Added Procedure  UPDATE_DIMENSION                  |
REM | 23-FEB-03 PAJOHRI  Added Procedures DELETE_DIMENSION                  |
REM |                                     CREATE_DIMENSION                  |
REM | 13-JUN-03 MAHRAO  Added Procedure   Load_Dimension_Group              |
REM | 07-JUL-2003 arhegde bug#3028436 Added call get_unique_dim_group_name()|
REM |    in Load_Dimension_Group()                                          |
REM | 09-JUL-2003 arhegde bug#3028436 Moved logic to BSC API from here      |
REM |            Removed get_unique_dim_group_name() call                   |
REM | 10-JUL-2003 mahrao Added a call to BSC_DIMENSION_GROUPS_PUB.          |
REM |                    ret_dimgrpid_fr_shname in Load_Dimension_Group     |
REM |                    procedure                                          |
REM | 30-Jul-04   rpenneru  Modified for enhancemen#3748519                 |
REM | 21-DEC-04   vtulasi   Modified for bug#4045278 - Addtion of LUD       |
REM | 08-Feb-05   ankgoel   Enh#4172034 DD Seeding by Product Teams         |
REM | 09-FEB-05   ankgoel   Bug#4172055 Dimension name validations          |
REM | 21-Jun-05   ankgoel   Bug#4437121 bisdimld/v.ldt compatible in 409    |
REM | 06-Jan-06   akoduri   Enh#4739401 - Hide Dimensions/Dim Objects       |
REM +=======================================================================+
*/
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_DIMENSION_PUB';


--
--
Procedure Load_Dimension_Wrapper
( p_commit            IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec     IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, p_Dim_Grp_Rec       IN  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
, p_Owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, p_force_mode        IN  BOOLEAN := FALSE
, x_return_status     OUT NOCOPY VARCHAR2
, x_msg_count         OUT NOCOPY NUMBER
, x_msg_data          OUT NOCOPY VARCHAR2
)
IS
  l_return_status  VARCHAR2(10);
  l_error_tbl      BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(4000);
BEGIN

  -- Bug#4172055: Rename the dimension if a BSC type dimension already exists
  -- with the same name. However, if a PMF type dimension exists with the same
  -- name, throw an error.
  BIS_DIMENSION_PVT.Validate_PMF_Unique_Name(
    p_Dimension_Short_Name => p_Dimension_Rec.Dimension_Short_Name
  , p_Dimension_Name       => p_Dimension_Rec.Dimension_Name
  , x_return_status        => x_return_status
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    BIS_UTILITIES_PVT.Add_Error_Message(
      p_error_msg_name    => 'BIS_DIMENSION_UNIQUENESS_ERROR'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Create_Dimension'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  BIS_DIMENSION_PUB.Load_dimension
  ( p_api_version    => 1.0
  , p_commit         => FND_API.G_FALSE
  , p_Dimension_Rec  => p_Dimension_Rec
  , p_owner          => p_Owner
  , x_return_status  => l_return_status
  , x_error_Tbl      => l_error_Tbl
  , p_force_mode     => p_force_mode
  );

  IF((l_return_status IS NOT NULL) AND (l_return_status <> FND_API.G_RET_STS_SUCCESS)) THEN
    IF(l_error_Tbl.COUNT > 0) THEN
      l_msg_data := l_error_Tbl(l_error_Tbl.FIRST).Error_Description;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BIS_DIMENSION_PUB.Load_Dimension_Group
  ( p_Commit         => FND_API.G_FALSE
  , p_dim_grp_rec    => p_Dim_Grp_Rec
  , x_return_status  => l_return_status
  , x_msg_count      => l_msg_count
  , x_msg_data       => l_msg_data
  , p_force_mode     => p_force_mode
  );

  IF((l_return_status IS NOT NULL) AND (l_return_status <> FND_API.G_RET_STS_SUCCESS)) THEN
    RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    IF(x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                                ,p_count   => x_msg_count
                                ,p_data    => x_msg_data);
    END IF;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF(x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                                ,p_count   => x_msg_count
                                ,p_data    => x_msg_data);
    END IF;
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF(x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                                ,p_count   => x_msg_count
                                ,p_data    => x_msg_data);
    END IF;
    RAISE;
END Load_Dimension_Wrapper;
--

Procedure Translate_Dimension_Wrapper
( p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec     IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, p_Dim_Grp_Rec       IN  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
, p_Owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_msg_count         OUT NOCOPY NUMBER
, x_msg_data          OUT NOCOPY VARCHAR2
)
IS
  l_return_status  VARCHAR2(10);
  l_error_tbl      BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(4000);
BEGIN

  BIS_DIMENSION_PUB.Translate_dimension
  ( p_api_version       => 1.0
  , p_commit            => FND_API.G_FALSE
  , p_Dimension_Rec     => p_Dimension_Rec
  , p_owner             => p_Owner
  , x_return_status     => l_return_status
  , x_error_Tbl         => l_error_Tbl
  );

  IF((l_return_status IS NOT NULL) AND (l_return_status <> FND_API.G_RET_STS_SUCCESS)) THEN
    IF(l_error_Tbl.COUNT > 0) THEN
      l_msg_data := l_error_Tbl(l_error_Tbl.FIRST).Error_Description;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_DIMENSION_GROUPS_PUB.Translate_Dimension_Group
  ( p_commit        => FND_API.G_FALSE
  , p_Dim_Grp_Rec   => p_Dim_Grp_Rec
  , x_return_status => l_return_status
  , x_msg_count     => l_msg_count
  , x_msg_data      => l_msg_data
  );

  IF((l_return_status IS NOT NULL) AND (l_return_status <> FND_API.G_RET_STS_SUCCESS)) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    IF(x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                                ,p_count   => x_msg_count
                                ,p_data    => x_msg_data);
    END IF;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF(x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                                ,p_count   => x_msg_count
                                ,p_data    => x_msg_data);
    END IF;
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF(x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                                ,p_count   => x_msg_count
                                ,p_data    => x_msg_data);
    END IF;
    RAISE;
END Translate_Dimension_Wrapper;
--

Procedure Retrieve_Dimensions
( p_api_version   IN  NUMBER
, x_Dimension_Tbl OUT NOCOPY BIS_DIMENSION_PUB.Dimension_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  BIS_DIMENSION_PVT.Retrieve_Dimensions
  ( p_api_version   => p_api_version
  , x_Dimension_Tbl => x_Dimension_Tbl
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
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Dimensions'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_Dimensions;
--
Procedure Retrieve_Dimension
( p_api_version   IN  NUMBER
, p_Dimension_Rec IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_Dimension_Rec OUT NOCOPY BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Dimension_Rec BIS_DIMENSION_PUB.Dimension_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  BIS_DIMENSION_PVT.Value_ID_Conversion
  ( p_api_version   => 1.0
  , p_Dimension_Rec => p_Dimension_Rec
  , x_Dimension_Rec => l_Dimension_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_tbl
  );

 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
   --Added last two parameters
    l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message (
       p_error_msg_name    => 'BIS_INVALID_DIMENSION_VALUE'
     , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
     , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Dimension'
     , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
     , p_error_table       => l_error_tbl
     , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;

  BIS_DIMENSION_PVT.Retrieve_Dimension
  ( p_api_version   => 1.0
  , p_Dimension_Rec => l_Dimension_Rec
  , x_Dimension_Rec => x_Dimension_Rec
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
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message(
         p_error_msg_id      => SQLCODE
       , p_error_description => SQLERRM
       , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Dimension'
       , p_error_table       => l_error_tbl
       , x_error_table       => x_error_tbl
      );

END Retrieve_Dimension;
--
-- API to retrieve the first and the second required dimension
-- this p_num can be either 1 or 2
-- I wish I had enumerated types :-(
Procedure Retrieve_Required_Dimension
( p_api_version   IN  NUMBER
, p_num           IN  NUMBER
, x_dimension_rec OUT NOCOPY BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Dimension_Rec BIS_DIMENSION_PUB.Dimension_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  if (p_num = 1) then
    l_Dimension_Rec.dimension_short_name := 'ORGANIZATION';
  elsif (p_num = 2) then
    l_Dimension_Rec.dimension_short_name := 'TIME';
  else
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_REQUIRED_DIMENSION'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Required_Dimension'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;

  BIS_DIMENSION_PUB.Retrieve_Dimension
  ( p_api_version   => 1.0
  , p_Dimension_Rec => l_Dimension_Rec
  , x_Dimension_Rec => x_Dimension_Rec
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
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Required_Dimension'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_Required_Dimension;
--
--
Procedure Translate_Dimension
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec     IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Dimension_Rec BIS_DIMENSION_PUB.Dimension_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_return_status  VARCHAR2(10);
  l_return_msg     VARCHAR2(32000);

BEGIN

  bis_utilities_pvt.init_debug_flag -- 2694978
  ( x_return_status   => l_return_status
  , x_return_msg      => l_return_msg
  );


  BIS_DIMENSION_PVT.Value_ID_Conversion
  ( p_api_version   => p_api_version
  , p_Dimension_Rec => p_Dimension_Rec
  , x_Dimension_Rec => l_Dimension_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_tbl
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_VALUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Translate_Dimension'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_Dimension_Rec.Last_Update_Date := NVL(p_Dimension_Rec.Last_Update_Date, SYSDATE);
  BIS_DIMENSION_PVT.Translate_Dimension
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Dimension_Rec     => l_Dimension_Rec
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
      , p_error_proc_name   => G_PKG_NAME||'.Translate_Dimension'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Translate_Dimension ;
--
Procedure Load_Dimension
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec     IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
, p_force_mode        IN  BOOLEAN := FALSE
)
IS
  l_Dimension_Rec  BIS_DIMENSION_PUB.Dimension_Rec_Type;
  l_error_tbl      BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_return_status  VARCHAR2(10);
  l_return_msg     VARCHAR2(32000);
  l_count          NUMBER;
  l_ret_code       BOOLEAN;

BEGIN

  bis_utilities_pvt.init_debug_flag -- 2694978
  ( x_return_status   => l_return_status
  , x_return_msg      => l_return_msg
  );

  -- BIS_UTILITIES_PUB.put_line(p_text => 'YYYYYYYYY' );

--  l_Dimension_Rec := p_Dimension_Rec;

  BIS_DIMENSION_PVT.Value_ID_Conversion
  ( p_api_version   => p_api_version
  , p_Dimension_Rec => p_Dimension_Rec
  , x_Dimension_Rec => l_Dimension_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_tbl
  );

  l_Dimension_Rec.Last_Update_Date := NVL(p_Dimension_Rec.Last_Update_Date, SYSDATE);

  SELECT COUNT(short_name) INTO l_count
  FROM BIS_DIMENSIONS
  WHERE short_name = p_Dimension_Rec.Dimension_short_Name;

  IF (l_count > 0) THEN

    BIS_UTIL.Validate_For_Update (p_last_update_date  => l_Dimension_Rec.Last_Update_Date
                                 ,p_owner             => p_owner
			         ,p_force_mode        => p_force_mode
			         ,p_table_name        => 'BIS_DIMENSIONS'
			         ,p_key_value         => p_Dimension_Rec.Dimension_short_Name
			         ,x_ret_code          => l_ret_code
			         ,x_return_status     => x_return_status
			         ,x_msg_data          => l_return_msg
			         );
    IF (l_ret_code) THEN

      BIS_DIMENSION_PVT.Update_Dimension
      ( p_api_version       => p_api_version
      , p_commit            => p_commit
      , p_validation_level  => p_validation_level
      , p_Dimension_Rec     => l_Dimension_Rec
      , p_owner             => p_owner
      , x_return_status     => x_return_status
      , x_error_Tbl         => x_error_Tbl
      );

    END IF;

  ELSE

    BIS_DIMENSION_PVT.Create_Dimension
     ( p_api_version       => p_api_version
     , p_commit            => p_commit
     , p_validation_level  => p_validation_level
     , p_Dimension_Rec     => l_Dimension_Rec
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
      , p_error_proc_name   => G_PKG_NAME||'.Load_Dimension'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Load_Dimension ;
--
PROCEDURE Update_Dimension
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec    IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status    OUT NOCOPY  VARCHAR2
, x_error_Tbl        OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  BIS_DIMENSION_PVT.Update_Dimension
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Dimension_Rec     => p_Dimension_Rec
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Update_Dimension'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Update_Dimension;
--
PROCEDURE Delete_Dimension
(
        p_commit                IN          VARCHAR2 := FND_API.G_FALSE
    ,   p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL
    ,   p_Dimension_Rec         IN          BIS_DIMENSION_PUB.Dimension_Rec_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_error_Tbl             OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
    BIS_DIMENSION_PVT.Delete_Dimension
    (
        p_commit                => p_commit
    ,   p_validation_level      => p_validation_level
    ,   p_Dimension_Rec         => p_Dimension_Rec
    ,   x_return_status         => x_return_status
    ,   x_error_Tbl             => x_error_Tbl
);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl     := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Delete_Dimension'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Delete_Dimension;
--

PROCEDURE Create_Dimension
(
        p_api_version       IN          NUMBER
    ,   p_commit            IN          VARCHAR2   := FND_API.G_FALSE
    ,   p_validation_level  IN          NUMBER := FND_API.G_VALID_LEVEL_FULL
    ,   p_Dimension_Rec     IN          BIS_DIMENSION_PUB.Dimension_Rec_Type
    ,   x_return_status     OUT NOCOPY  VARCHAR2
    ,   x_error_Tbl         OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
    BIS_DIMENSION_PVT.Create_Dimension
    (
      p_api_version       =>  p_api_version
    , p_commit            =>  p_commit
    , p_validation_level  =>  p_validation_level
    , p_Dimension_Rec     =>  p_Dimension_Rec
    , x_return_status     =>  x_return_status
    , x_error_Tbl         =>  x_error_Tbl
    );
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl     := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Dimension'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
END Create_Dimension;
--=============================================================================
/*
 * Used for "All" enhancement from BISDIMLV.lct
 */
PROCEDURE Load_Dimension_Group (
  p_Commit IN VARCHAR2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec IN  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
 ,p_force_mode IN BOOLEAN := FALSE
)
IS
  l_Bsc_Dim_Group_Rec BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
  l_dim_grp_id NUMBER;
BEGIN

-- Information coming from ldt file
  l_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Name       := p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name;
  l_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Short_Name := p_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name;
-- WHO columns are populated from the Lct file.
  l_Bsc_Dim_Group_Rec.Bsc_Created_By                 := p_Dim_Grp_Rec.Bsc_Created_By;
  l_Bsc_Dim_Group_Rec.Bsc_Last_Updated_By            := p_Dim_Grp_Rec.Bsc_Last_Updated_By;
  l_Bsc_Dim_Group_Rec.Bsc_Last_Update_Date           := NVL(p_Dim_Grp_Rec.Bsc_Last_Update_Date, SYSDATE);

  BSC_DIMENSION_GROUPS_PUB.load_dimension_group (
     p_commit => FND_API.G_TRUE
    ,p_Dim_Grp_Rec => l_Bsc_Dim_Group_Rec
    ,x_return_status => x_return_status
    ,x_msg_count => x_msg_count
    ,x_msg_data => x_msg_data
    ,p_force_mode => p_force_mode
  );

  BSC_DIMENSION_GROUPS_PUB.ret_dimgrpid_fr_shname (
     p_dim_short_name => l_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Short_Name
    ,x_dim_grp_id => l_dim_grp_id
    ,x_return_status => x_return_status
    ,x_msg_count => x_msg_count
    ,x_msg_data => x_msg_data
  );

  IF (l_dim_grp_id IS NOT NULL) THEN
    UPDATE bis_dimensions
    SET    dim_grp_id = l_dim_grp_id
    WHERE  short_name = l_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Short_Name;
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
   END;

--=============================================================================

PROCEDURE Translate_Dim_By_Given_Lang
(
      p_commit                IN          VARCHAR2 := FND_API.G_FALSE
  ,   p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,   p_Dimension_Rec         IN          BIS_DIMENSION_PUB.Dimension_Rec_Type
  ,   x_return_status         OUT NOCOPY  VARCHAR2
  ,   x_error_Tbl             OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
) IS
        l_error_tbl                 BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
        BIS_DIMENSION_PVT.Translate_Dim_By_Given_Lang
        (
                    p_commit                =>  p_commit
                ,   p_validation_level      =>  p_validation_level
                ,   p_Dimension_Rec         =>  p_Dimension_Rec
                ,   x_return_status         =>  x_return_status
                ,   x_error_Tbl             =>  x_error_Tbl
        );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl     := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Translate_Dim_By_Given_Lang'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
END Translate_Dim_By_Given_Lang;

PROCEDURE Update_Dimension_Obsolete_Flag (
    p_commit                      IN VARCHAR2 := FND_API.G_FALSE,
    p_dim_short_name              IN VARCHAR2,
    p_hide                        IN VARCHAR2,
    x_return_status               OUT nocopy VARCHAR2,
    x_Msg_Count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT nocopy VARCHAR2
) IS
  l_dim_rec          BIS_DIMENSION_PUB.Dimension_Rec_Type;
  x_dim_rec          BIS_DIMENSION_PUB.Dimension_Rec_Type;
  l_dim_obj_sht_name BSC_SYS_DIM_LEVELS_B.SHORT_NAME%TYPE;
  l_error_tbl        BIS_UTILITIES_PUB.Error_Tbl_Type;

  CURSOR cr_dim_obj IS
  SELECT
    obj_short_name short_name
  FROM
    bsc_bis_dim_obj_by_dim_vl b
  WHERE
    dim_short_name =  p_dim_short_name AND
	  (SELECT COUNT(1)
	   FROM
	     bsc_bis_dim_obj_by_dim_vl a
	   WHERE
	     a.obj_short_name  =  b.obj_short_name AND
  	   a.dim_short_name  <> b.dim_short_name AND
	     a.dim_short_name  <> 'UNASSIGNED' AND
	     (SELECT NVL(hide_in_design,'F') FROM bis_dimensions WHERE short_name = a.dim_short_name) = 'F' AND
	     (SELECT bis_util.is_Seeded(created_by,'T','F') FROM bis_dimensions WHERE short_name = a.dim_short_name) = 'T') = 0;

 BEGIN
    SAVEPOINT DimObsoleteUpdate;
    IF (p_dim_short_name IS NULL OR p_dim_short_name = '') THEN
       FND_MESSAGE.SET_NAME('BIS','BIS_PMF_INVALID_DIMENSION_VALUE');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_hide IS NULL OR (p_hide <> FND_API.G_TRUE AND p_hide <> FND_API.G_FALSE)) THEN
       FND_MESSAGE.SET_NAME('BIS','BIS_PMF_INVALID_OBSOLETE_FLAG');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR cr in cr_dim_obj LOOP
      -- Hide or Unhide all the dimension objects that are attached only to this dimension(Cascade the obsoletion)
      BIS_DIMENSION_LEVEL_PUB.Update_Dim_Obj_Obsolete_Flag (
          p_dim_obj_short_name => cr.short_name
        , p_hide               => p_hide
        , x_return_status      => x_return_status
        , x_Msg_Count          => x_Msg_Count
        , x_msg_data           => x_msg_data
      );
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;

    l_dim_rec.Dimension_Short_Name := p_dim_short_name;

    BIS_DIMENSION_PVT.Retrieve_Dimension
    ( p_api_version         => 1.0
    , p_Dimension_Rec       => l_dim_rec
    , x_Dimension_Rec       => x_dim_rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => l_error_tbl
    );

    x_dim_rec.Hide := p_Hide;

    BIS_DIMENSION_PVT.Update_Dimension
    (  p_api_version        => 1.0
    , p_Dimension_Rec       => x_dim_rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => l_error_tbl
    );

    IF(p_Commit = FND_API.G_TRUE) THEN
     COMMIT;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
         (      p_encoded   =>  FND_API.G_FALSE
            ,   p_count     =>  x_msg_count
            ,   p_data      =>  x_msg_data
         );
      END IF;
      x_Return_Status :=  FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO DimObsoleteUpdate;
      IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BIS_DIMENSION_PUB.Update_Dimension_Obsolete_Flag ';
      ELSE
         x_msg_data      :=  SQLERRM||' at BIS_DIMENSION_PUB.Update_Dimension_Obsolete_Flag ';
      END IF;
 END Update_Dimension_Obsolete_Flag;

--=============================================================================
END BIS_DIMENSION_PUB;

/
