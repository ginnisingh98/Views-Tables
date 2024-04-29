--------------------------------------------------------
--  DDL for Package Body BIS_DIMENSION_LEVEL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_DIMENSION_LEVEL_PUB" AS
/* $Header: BISPDMLB.pls 120.6 2006/09/29 14:28:50 ppandey ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPDMLB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for managing dimension levels for the
REM |     Key Performance Framework.
REM |
REM |     This package should be maintaind by EDW once it gets integrated
REM |     with BIS.
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | 27-JAN-03 arhegde For having different local variables for IN and OUT |
REM |                   parameters (bug#2758428)                            |
REM | 20-FEB-2003  PAJOHRI      Added Procedure     UPDATE_DIMENSION_LEVEL  |
REM | 23-FEB-2003  PAJOHRI ,    Added procedures    DELETE_DIMENSION_LEVEL  |
REM |                                               CREATE_DIMENSION_LEVEL  |
REM | 13-JUN-03    MAHRAO       Added Procedure     Load_Dimension_Level    |
REM | 20-JUN-03    arhegde   bug# 3015484 create relationship when          |
REM |   it is not present, else update it                                   |
REM | 09-JUL-2003 arhegde bug#3028436 Moved logic to BSC API from here      |
REM | 10-JUL-2003 mahrao  bug#3042968 Added extra parameter to              |
REM |                                 Load_Dimension_Level                  |
REM | 02-SEP-2003 mahrao  bug#3099977 Changed code in load_dim_levels       |
REM |                                 so that table_type flag is set to -1  |
REM |                                 if underlying view doesnot exist.     |
REM | 29-OCT-03    MAHRAO enh of adding new attributes to dim objects       |
REM | 14-NOV-03    RCHANDRA enh  2997632, customization APIs                |
REM | 25-NOV-03    MAHRAO enh of populated DimLvlList and where_clause_list |
REM | 04-DEC-03    ANKGOEL bug#3264490 Made changes for performance issues  |
REM |                      in uploading dimension levels        |
REM | 07-JAN-04    rpenneru bug#3459443 Modified for getting where clause   |
REM |                                  from BSC data model                  |
REM | arhegde 07/23/2004 bug# 3760735 dim object caching.                   |
REM | 30-Jul-04   rpenneru  Modified for enhancemen#3748519                 |
REM | 13-Oct-04   rpenneru  Modified for bug#3945655                        |
REM | 21-DEC-04   vtulasi   Modified for bug#4045278 - Addtion of LUD       |
REM | 08-Feb-04   skchoudh  Enh#3873195 drill_to_form_function column       |
REM |                  is added                                             |
REM | 08-Feb-05   ankgoel   Enh#4172034 DD Seeding by Product Teams         |
REM | 09-Feb-05   ankgoel   Bug#4172055 LUD validations for dim_lvls_by_group
REM | 02-MAR-05   ashankar  Bug#3583110 Modifed load_dim_level              |
REM | 08-APR-2005 kyadamak generating unique master table for PMF dimension |
REM |                       objects for the bug# 4290359                    |
REM | 22-Aug-05   ankgoel   Bug#4557713 LUD validation for dim_lvls_by_group|
REM | 07-NOV-05   akoduri   Bug#4696105,Added overloaded API                |
REM |                       get_customized_enabled                          |
REM | 12-Dec-05   ankgoel   Enh#4640165 - Select dim objects from Report    |
REM | 06-Jan-06   akoduri   Enh#4739401 - Hide Dimensions/Dim Objects       |
REM | 24-May-06   akoduri   Bug#5128863 - LUD of bsc_sys_dim_levels should  |
REM |                       also get updated                                |
REM +=======================================================================+
*/
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_DIMENSION_LEVEL_PUB';
--
PROCEDURE load_dim_levels_in_group(
  p_commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN          BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,p_Bsc_Pmf_Dim_Rec     IN          BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
 ,x_return_status       OUT NOCOPY  VARCHAR2
 ,x_msg_count           OUT NOCOPY  NUMBER
 ,x_msg_data            OUT NOCOPY  VARCHAR2
);

--=======================================================================

PROCEDURE load_dim_levels(
  p_commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_bsc_pmf_dim_rec     IN          BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
 ,p_Bsc_Dim_Level_Rec   IN          BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY  VARCHAR2
 ,x_msg_count           OUT NOCOPY  NUMBER
 ,x_msg_data            OUT NOCOPY  VARCHAR2
);

--

Procedure Load_Dimension_Level_Wrapper
( p_commit              IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_Dim_Grp_Rec         IN  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
, p_Bsc_Pmf_Dim_Rec     IN  BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
, p_Bsc_Dim_Level_Rec   IN  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
, p_Owner               IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, p_force_mode          IN  BOOLEAN := FALSE
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
)
IS
  l_return_status  VARCHAR2(10);
  l_error_tbl      BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(4000);
BEGIN

  BIS_DIMENSION_LEVEL_PUB.Load_Dimension_Level
  ( p_api_version         => 1.0
  , p_commit              => FND_API.G_FALSE
  , p_Dimension_Level_Rec => p_Dimension_Level_Rec
  , p_owner               => p_Owner
  , x_return_status       => l_return_status
  , x_error_Tbl           => l_error_Tbl
  , p_force_mode          => p_force_mode
  );

  IF((l_return_status IS NOT NULL) AND (l_return_status <> FND_API.G_RET_STS_SUCCESS)) THEN
    IF(l_error_Tbl.COUNT > 0) THEN
      l_msg_data := l_error_Tbl(l_error_Tbl.FIRST).Error_Description;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BIS_DIMENSION_LEVEL_PUB.Load_Dimension_Level
  ( p_Commit            => FND_API.G_FALSE
  , p_Dim_Grp_Rec       => p_Dim_Grp_Rec
  , p_Bsc_Pmf_Dim_Rec   => p_Bsc_Pmf_Dim_Rec
  , p_Bsc_Dim_Level_Rec => p_Bsc_Dim_Level_Rec
  , x_return_status     => l_return_status
  , x_msg_count         => l_msg_count
  , x_msg_data          => l_msg_data
  , p_force_mode        => p_force_mode
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
END Load_Dimension_Level_Wrapper;
--

Procedure Translate_Dim_Level_Wrapper
( p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_Bsc_Pmf_Dim_Rec     IN  BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
, p_Bsc_Dim_Level_Rec   IN  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
, p_Owner               IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
)
IS
  l_return_status  VARCHAR2(10);
  l_error_tbl      BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(4000);
BEGIN

  BIS_DIMENSION_LEVEL_PUB.Translate_dimension_level
  ( p_api_version         => 1.0
  , p_commit              => FND_API.G_FALSE
  , p_Dimension_Level_Rec => p_Dimension_Level_Rec
  , p_owner               => p_Owner
  , x_return_status       => l_return_status
  , x_error_Tbl           => l_error_Tbl
  );

  IF((l_return_status IS NOT NULL) AND (l_return_status <> FND_API.G_RET_STS_SUCCESS)) THEN
    IF(l_error_Tbl.COUNT > 0) THEN
      l_msg_data := l_error_Tbl(l_error_Tbl.FIRST).Error_Description;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_DIMENSION_LEVELS_PUB.Translate_dimension_level
  ( p_commit            => FND_API.G_FALSE
  , p_Bsc_Pmf_Dim_Rec   => p_Bsc_Pmf_Dim_Rec
  , p_Bsc_Dim_Level_Rec => p_Bsc_Dim_Level_Rec
  , x_return_status     => l_return_status
  , x_msg_count         => l_msg_count
  , x_msg_data          => l_msg_data
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
END Translate_Dim_Level_Wrapper;
--

Procedure Retrieve_Dimension_Levels
( p_api_version         IN  NUMBER
, p_Dimension_Rec       IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_Dimension_Level_Tbl OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Dimension_Rec BIS_DIMENSION_PUB.Dimension_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
--commented out NOCOPY this section
/*
  BIS_DIMENSION_PVT.Value_ID_Conversion
  ( p_api_version   => 1.0
  , p_Dimension_Rec => p_Dimension_Rec
  , x_Dimension_Rec => l_Dimension_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_tbl
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    -- POPULATE THE ERROR TABLE
    --added this message
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_VALUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Dimension_Levels'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;
*/
  BIS_DIMENSION_LEVEL_PVT.Retrieve_Dimension_Levels
  ( p_api_version         => 1.0
  , p_Dimension_Rec       => l_Dimension_Rec
  , x_Dimension_Level_Tbl => x_Dimension_Level_Tbl
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_tbl
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
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Dimension_Levels'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );


END Retrieve_Dimension_Levels;
--
Procedure Retrieve_Dimension_Level
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dimension_Level_Rec IN OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  BIS_DIMENSION_LEVEL_PVT.Value_ID_Conversion
  ( p_api_version         => 1.0
  , p_Dimension_Level_Rec => p_Dimension_Level_Rec
  , x_Dimension_Level_Rec => l_Dimension_Level_Rec
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_tbl
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    -- POPULATE THE ERROR TABLE
    --added the error message
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_VALUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Dimension_Level'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;

  BIS_DIMENSION_LEVEL_PVT.Retrieve_Dimension_Level
  ( p_api_version         => 1.0
  , p_Dimension_Level_Rec => l_Dimension_Level_Rec
  , x_Dimension_Level_Rec => x_Dimension_Level_Rec
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_tbl
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
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Dimension_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_Dimension_Level;
--
--
Procedure Translate_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_owner               IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  BIS_DIMENSION_LEVEL_PVT.Value_ID_Conversion
  ( p_api_version         => p_api_version
  , p_Dimension_Level_Rec => p_Dimension_Level_Rec
  , x_Dimension_Level_Rec => l_Dimension_Level_Rec
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_tbl
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    --added last two parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_LEVEL_ID'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Translate_Dimension_Level'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_Dimension_Level_Rec.Last_Update_Date := NVL(p_Dimension_Level_Rec.Last_Update_Date, SYSDATE);
  BIS_DIMENSION_LEVEL_PVT.Translate_Dimension_Level
  ( p_api_version         => p_api_version
  , p_commit              => p_commit
  , p_validation_level    => p_validation_level
  , p_Dimension_Level_Rec => l_Dimension_Level_Rec
  , p_owner               => p_owner
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
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Translate_Dimension_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Translate_Dimension_Level ;
--
Procedure Load_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_owner               IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
, p_force_mode          IN  BOOLEAN := FALSE
)
IS
  l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_return_status  VARCHAR2(10);
  l_return_msg     VARCHAR2(32000);
  l_count          NUMBER;
  l_ret_code       BOOLEAN;
BEGIN

  l_Dimension_level_Rec := p_Dimension_level_Rec;

  BEGIN

  BIS_DIMENSION_LEVEL_PVT.Value_ID_Conversion
  ( p_api_version         => p_api_version
  , p_Dimension_Level_Rec => p_Dimension_Level_Rec
  , x_Dimension_Level_Rec => l_Dimension_Level_Rec
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_tbl
  );

-- commented out NOCOPY since we want to continue anyway
/*
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    --added last two parameters
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_LEVEL_ID'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Load_Dimension_Level'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;
*/

    l_Dimension_Level_Rec.Last_Update_Date := NVL(p_Dimension_Level_Rec.Last_Update_Date, SYSDATE);

    SELECT COUNT(short_name) INTO l_count
    FROM BIS_LEVELS
    WHERE short_name = p_Dimension_Level_Rec.Dimension_Level_Short_Name;

    IF (l_count > 0) THEN
        BIS_UTIL.Validate_For_Update ( p_last_update_date  => l_Dimension_Level_Rec.Last_Update_Date
                                      ,p_owner             => p_owner
                              ,p_force_mode        => p_force_mode
                              ,p_table_name        => 'BIS_LEVELS'
                              ,p_key_value         => p_Dimension_Level_Rec.Dimension_Level_Short_Name
                              ,x_ret_code          => l_ret_code
                              ,x_return_status     => x_return_status
                              ,x_msg_data          => l_return_msg
                             );
        IF (l_ret_code) THEN
          BIS_DIMENSION_LEVEL_PVT.Update_Dimension_Level
          ( p_api_version         => p_api_version
          , p_commit              => p_commit
          , p_validation_level    => p_validation_level
          , p_Dimension_Level_Rec => l_Dimension_Level_Rec
          , p_owner               => p_owner
          , x_return_status       => x_return_status
          , x_error_Tbl           => x_error_Tbl
          );
        END IF;
    ELSE
      BIS_DIMENSION_LEVEL_PVT.Create_Dimension_Level
      ( p_api_version         => p_api_version
      , p_commit              => p_commit
      , p_validation_level    => p_validation_level
      , p_Dimension_Level_Rec => l_Dimension_Level_Rec
      , p_owner               => p_owner
      , x_return_status       => x_return_status
      , x_error_Tbl           => x_error_Tbl
      );

    END IF;
/*
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Load_Dimension_Level'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
*/
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
      , p_error_proc_name   => G_PKG_NAME||'.Load_Dimension_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Load_Dimension_Level ;
--
PROCEDURE Create_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2    := FND_API.G_FALSE
, p_validation_level    IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY  VARCHAR2
, x_error_Tbl           OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

    BIS_DIMENSION_LEVEL_PVT.Create_Dimension_Level
    (
            p_api_version         => p_api_version
        ,   p_commit              => p_commit
        ,   p_validation_level    => p_validation_level
        ,   p_Dimension_Level_Rec => p_Dimension_Level_Rec
        ,   x_return_status       => x_return_status
        ,   x_error_Tbl           => x_error_Tbl
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
      , p_error_proc_name   => G_PKG_NAME||'.Create_Dimension_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
END Create_Dimension_Level;
--
PROCEDURE Update_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2    := FND_API.G_FALSE
, p_validation_level    IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

    BIS_DIMENSION_LEVEL_PVT.Update_Dimension_Level
    (
            p_api_version         => p_api_version
        ,   p_commit              => p_commit
        ,   p_validation_level    => p_validation_level
        ,   p_Dimension_Level_Rec => p_Dimension_Level_Rec
        ,   x_return_status       => x_return_status
        ,   x_error_Tbl           => x_error_Tbl
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
      , p_error_proc_name   => G_PKG_NAME||'.Update_Dimension_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
END Update_Dimension_Level;
--
PROCEDURE Delete_Dimension_Level
(
    p_commit                IN          VARCHAR2 := FND_API.G_FALSE
  , p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL
  , p_Dimension_Level_Rec   IN          BIS_Dimension_Level_PUB.Dimension_Level_Rec_Type
  , x_return_status         OUT NOCOPY  VARCHAR2
  , x_error_Tbl             OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
) IS
    l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
    BIS_DIMENSION_LEVEL_PVT.Delete_Dimension_Level
    (
        p_commit                =>  p_commit
      , p_validation_level      =>  p_validation_level
      , p_Dimension_Level_Rec   =>  p_Dimension_Level_Rec
      , x_return_status         =>  x_return_status
      , x_error_Tbl             =>  x_error_Tbl
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN OTHERS THEN
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Delete_Dimension_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Delete_Dimension_Level;

--============================================================================
-- Load into BSC's bsc_sys_dim_levels_b/tl table by calling update/insert API of BSC

PROCEDURE load_dim_levels(
  p_commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_bsc_pmf_dim_rec     IN          BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
 ,p_Bsc_Dim_Level_Rec   IN          BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status       OUT NOCOPY  VARCHAR2
 ,x_msg_count           OUT NOCOPY  NUMBER
 ,x_msg_data            OUT NOCOPY  VARCHAR2
)
IS
  l_Bsc_Pmf_Dim_Rec BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type;
  l_Bsc_Dim_Rec BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;

  l_alternate_level_view VARCHAR2(80);
  l_edw_sql VARCHAR2(1000);
  l_dim_lvl_sql VARCHAR2(2000);
  l_prefix VARCHAR2(2000);
  l_dimshortname VARCHAR2(80);
  l_rel_count NUMBER;
  TYPE Recdc_value IS REF CURSOR;
  dl_value Recdc_value;
  l_count NUMBER;
BEGIN
  l_Bsc_Pmf_Dim_Rec.Dimension_Long_Name := p_Bsc_Pmf_Dim_Rec.Dimension_Long_Name;
  l_Bsc_Pmf_Dim_Rec.Dimension_Short_Name := p_Bsc_Pmf_Dim_Rec.Dimension_Short_Name;
  l_Bsc_Pmf_Dim_Rec.Dimension_Level_Long_Name := p_Bsc_Pmf_Dim_Rec.Dimension_Level_Long_Name;
  l_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name := p_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name;

  -- If the source is oltp, retrieve all values in 1 sql, else if EDW, it will be overwritten below.
  SELECT source, name, level_values_view_name, 'ID', 'value'
    INTO   l_Bsc_Pmf_Dim_Rec.Dimension_Level_Source,
           l_Bsc_Pmf_Dim_Rec.Dimension_Level_Long_Name,
           l_Bsc_Pmf_Dim_Rec.Dimension_Level_View_Name,
           l_Bsc_Pmf_Dim_Rec.Dimension_Level_Pk_Key,
           l_Bsc_Pmf_Dim_Rec.Dimension_Level_Name_Column
    FROM  bis_levels_vl
    WHERE UPPER(short_name) = UPPER(p_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name);

  l_Bsc_Pmf_Dim_Rec.Dimension_Level_Disp_Size := 250;

  l_Bsc_Dim_Rec.Bsc_Level_Short_Name := l_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name;
  l_Bsc_Dim_Rec.Bsc_Dim_Level_Long_Name := l_Bsc_Pmf_Dim_Rec.Dimension_Level_Long_Name;
  l_Bsc_Dim_Rec.Bsc_Level_Disp_Key_Size := l_Bsc_Pmf_Dim_Rec.Dimension_Level_Disp_Size;

  l_Bsc_Dim_Rec.Bsc_Level_Name := bsc_utility.get_valid_bsc_master_tbl_name(l_Bsc_Dim_Rec.Bsc_Level_Short_Name);
  l_Bsc_Dim_Rec.Bsc_Level_View_Name := l_Bsc_Pmf_Dim_Rec.Dimension_Level_View_Name;
  IF (l_Bsc_Pmf_Dim_Rec.Dimension_Level_Source = 'OLTP') THEN
    l_Bsc_Dim_Rec.Bsc_Level_Pk_Key := l_Bsc_Pmf_Dim_Rec.Dimension_Level_Pk_Key;
    l_Bsc_Dim_Rec.Bsc_Pk_Col := REPLACE(l_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name,' ','_');
  ELSE
    l_Bsc_Dim_Rec.Bsc_Level_Pk_Key := l_Bsc_Pmf_Dim_Rec.Dimension_Level_Pk_Key_edw;
    l_Bsc_Dim_Rec.Bsc_Pk_Col := l_Bsc_Pmf_Dim_Rec.Dimension_Level_Pk_Key_edw;
  END IF;
  l_Bsc_Dim_Rec.Bsc_Source := 'PMF';
  l_Bsc_Dim_Rec.Source := l_Bsc_Pmf_Dim_Rec.Dimension_Level_Source;
  l_Bsc_Dim_Rec.Bsc_Level_Name_Column := l_Bsc_Pmf_Dim_Rec.Dimension_Level_Name_Column;
  l_Bsc_Dim_Rec.Bsc_Language := 'US';
  l_Bsc_Dim_Rec.Bsc_Source_Language := userenv('LANG'); --'US';

-- Total display name, Comparison display name and Help
  l_Bsc_Dim_Rec.Bsc_Dim_Comp_Disp_Name := p_Bsc_Dim_Level_Rec.Bsc_Dim_Comp_Disp_Name;
  l_Bsc_Dim_Rec.Bsc_Dim_Tot_Disp_Name := p_Bsc_Dim_Level_Rec.Bsc_Dim_Tot_Disp_Name;
  l_Bsc_Dim_Rec.Bsc_Dim_Level_Help := p_Bsc_Dim_Level_Rec.Bsc_Dim_Level_Help;

-- Who columns are populated from the lct file.
  l_Bsc_Dim_Rec.Bsc_Created_By := p_Bsc_Dim_Level_Rec.Bsc_Created_By;
  l_Bsc_Dim_Rec.Bsc_Last_Updated_By := p_Bsc_Dim_Level_Rec.Bsc_Last_Updated_By;

-- Defaulting all dim levels ,set this to bypass bsc view creation #3264490
  l_Bsc_Dim_Rec.Bsc_Level_Table_Type := -1;

  IF ( (l_Bsc_Dim_Rec.Bsc_Level_Pk_Key IS NULL) AND (l_Bsc_Dim_Rec.Bsc_Pk_Col IS NULL) ) THEN
    l_Bsc_Dim_Rec.Bsc_Level_Table_Type := -1;
    l_Bsc_Dim_Rec.Bsc_Level_Pk_Key := SUBSTR(l_Bsc_Dim_Rec.bsc_Level_Short_Name, 1, 23) ||'_PK_COL';
    l_Bsc_Dim_Rec.Bsc_Pk_Col := l_Bsc_Dim_Rec.Bsc_Level_Pk_Key;
  END IF;

  -- This will either update/insert dimension levels

  l_Bsc_Dim_Rec.Bsc_Last_Update_Date := NVL(p_Bsc_Dim_Level_Rec.Bsc_Last_Update_Date, SYSDATE);

  BSC_DIMENSION_LEVELS_PUB.load_dimension_level(
     p_commit => p_Commit
    ,p_Dim_Level_Rec => l_Bsc_Dim_Rec
    ,x_return_status => x_return_status
    ,x_msg_count => x_msg_count
    ,x_msg_data => x_msg_data
  );


EXCEPTION
   WHEN NO_DATA_FOUND THEN
     IF (dl_value%ISOPEN) THEN
       CLOSE dl_value;
     END IF;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
     IF (dl_value%ISOPEN) THEN
       CLOSE dl_value;
     END IF;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF (dl_value%ISOPEN) THEN
       CLOSE dl_value;
     END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
   WHEN OTHERS THEN
     IF (dl_value%ISOPEN) THEN
       CLOSE dl_value;
     END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);

END load_dim_levels;


--============================================================================
-- Load into BSC's bsc_sys_dim_levels_by_group table by calling update/insert API of BSC

PROCEDURE load_dim_levels_in_group(
  p_commit              IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec         IN          BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,p_Bsc_Pmf_Dim_Rec     IN          BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
 ,x_return_status       OUT NOCOPY  VARCHAR2
 ,x_msg_count           OUT NOCOPY  NUMBER
 ,x_msg_data            OUT NOCOPY  VARCHAR2
)
IS
  l_Bsc_Dim_Group_Rec BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
BEGIN

  l_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Name       := p_Bsc_Pmf_Dim_Rec.Dimension_Long_Name;
  l_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Group_Short_Name := p_Bsc_Pmf_Dim_Rec.Dimension_Short_Name;
  l_Bsc_Dim_Group_Rec.Bsc_Language                   := p_Dim_Grp_Rec.Bsc_Language;
  l_Bsc_Dim_Group_Rec.Bsc_Source_Language            := p_Dim_Grp_Rec.Bsc_Source_Language;
  l_Bsc_Dim_Group_Rec.Bsc_Group_Level_Default_Value  := p_Dim_Grp_Rec.Bsc_Group_Level_Default_Value;
  l_Bsc_Dim_Group_Rec.Bsc_Group_Level_Default_Type   := p_Dim_Grp_Rec.Bsc_Group_Level_Default_Type;
  l_Bsc_Dim_Group_Rec.Bsc_Group_Level_Filter_Col     := p_Dim_Grp_Rec.Bsc_Group_Level_Filter_Col;
  l_Bsc_Dim_Group_Rec.Bsc_Group_Level_Filter_Value   := p_Dim_Grp_Rec.Bsc_Group_Level_Filter_Value;
  l_Bsc_Dim_Group_Rec.Bsc_Group_Level_No_Items       := p_Dim_Grp_Rec.Bsc_Group_Level_No_Items;
  l_Bsc_Dim_Group_Rec.Bsc_Group_Level_Parent_In_Tot  := p_Dim_Grp_Rec.Bsc_Group_Level_Parent_In_Tot;
  l_Bsc_Dim_Group_Rec.Bsc_Group_Level_Total_Flag     := p_Dim_Grp_Rec.Bsc_Group_Level_Total_Flag;
  l_Bsc_Dim_Group_Rec.Bsc_Group_Level_Comp_Flag      := p_Dim_Grp_Rec.Bsc_Group_Level_Comp_Flag;
  l_Bsc_Dim_Group_Rec.Bsc_Group_Level_Where_Clause   := p_Dim_Grp_Rec.Bsc_Group_Level_Where_Clause;
  l_Bsc_Dim_Group_Rec.Bsc_Dim_Level_Index            := p_Dim_Grp_Rec.Bsc_Dim_Level_Index;

  -- call BSC API to load dim levels in group table (either insert/update)
  BSC_DIMENSION_GROUPS_PUB.load_dim_levels_in_group(
    p_commit => p_commit
   ,p_Bsc_Pmf_Dim_Rec => p_Bsc_Pmf_Dim_Rec
   ,p_Dim_Grp_Rec => l_bsc_dim_group_rec
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
 );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                ,p_data     =>      x_msg_data);
END load_dim_levels_in_group;


--=============================================================================
PROCEDURE Load_Dimension_Level (
  p_Commit IN VARCHAR2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec IN  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,p_Bsc_Pmf_Dim_Rec IN BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
 ,p_Bsc_Dim_Level_Rec  IN BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
 ,p_force_mode IN  BOOLEAN := FALSE
)
IS
  CURSOR c_bsc_dim_obj_exists IS
    SELECT short_name FROM bsc_sys_dim_levels_b
      WHERE short_name = p_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name;

  CURSOR c_dim_dimobj_mapping_exists IS
    SELECT 1
      FROM BSC_SYS_DIM_LEVELS_BY_GROUP A,
           BSC_SYS_DIM_LEVELS_B B,
           BIS_DIMENSIONS C
      WHERE C.short_name = p_Bsc_Pmf_Dim_Rec.Dimension_Short_Name
      AND   B.short_name = p_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name
      AND   A.dim_group_id = C.dim_grp_id
      AND   A.dim_level_id = B.dim_level_id;

  l_short_name        BIS_LEVELS.Short_Name%TYPE;
  l_owner_name        VARCHAR2(100);
  l_last_update_date  DATE;
  l_ret_code          BOOLEAN := TRUE;
BEGIN
    /*
    Bug#4172055: Even though BSC_SYS_DIM_LEVELS_BY_GROUP does not has LUD column
    still the upload of a dimension object should not modify this table unless
    other LUDs are validated. For this, LUD check is done here both for
    BSC_SYS_DIM_LEVELS_B and BSC_SYS_DIM_LEVELS_BY_GROUP, based on the LUD
    in BSC_SYS_DIM_LEVELS_B table.
    */

    IF (c_bsc_dim_obj_exists%ISOPEN) THEN
      CLOSE c_bsc_dim_obj_exists;
    END IF;
    OPEN c_bsc_dim_obj_exists;
    FETCH c_bsc_dim_obj_exists INTO l_short_name;

    IF (c_bsc_dim_obj_exists%FOUND) THEN  -- Update mode
      l_last_update_date := NVL(p_Bsc_Dim_Level_Rec.Bsc_Last_Update_Date, SYSDATE);
      l_owner_name := BIS_UTILITIES_PUB.Get_Owner_Name(p_Bsc_Dim_Level_Rec.Bsc_Last_Updated_By);

      /*BIS_UTIL.Validate_For_Update
        ( p_last_update_date  => l_last_update_date
        , p_owner             => l_owner_name
        , p_force_mode        => p_force_mode
        , p_table_name        => 'BSC_SYS_DIM_LEVELS_B'
        , p_key_value         => p_Bsc_Pmf_Dim_Rec.Dimension_Level_Short_Name
        , x_ret_code          => l_ret_code
        , x_return_status     => x_return_status
        , x_msg_data          => x_msg_data);*/
      l_ret_code := TRUE;
    END IF;

    IF (l_ret_code) THEN

      -- Load into BSC's bsc_sys_dim_levels_b/tl table by calling update/insert API of BSC
      load_dim_levels(
        p_commit => p_commit
       ,p_bsc_pmf_dim_rec => p_bsc_pmf_dim_rec
       ,p_Bsc_Dim_Level_Rec => p_Bsc_Dim_Level_Rec
       ,x_return_status => x_return_status
       ,x_msg_count => x_msg_count
       ,x_msg_data => x_msg_data
      );

      -- Load into BSC's bsc_sys_dim_levels_by_group table by calling update/insert API of BSC
      load_dim_levels_in_group(
        p_commit => p_commit
       ,p_Dim_Grp_Rec => p_Dim_Grp_Rec
       ,p_Bsc_Pmf_Dim_Rec => p_Bsc_Pmf_Dim_Rec
       ,x_return_status => x_return_status
       ,x_msg_count => x_msg_count
       ,x_msg_data => x_msg_data
      );

    ELSE

      IF (c_dim_dimobj_mapping_exists%ISOPEN) THEN
        CLOSE c_dim_dimobj_mapping_exists;
      END IF;
      OPEN c_dim_dimobj_mapping_exists;
      FETCH c_dim_dimobj_mapping_exists INTO l_short_name;

      IF (c_dim_dimobj_mapping_exists%NOTFOUND) THEN

        -- Load into BSC's bsc_sys_dim_levels_by_group table by calling update/insert API of BSC
        load_dim_levels_in_group(
          p_commit => p_commit
         ,p_Dim_Grp_Rec => p_Dim_Grp_Rec
         ,p_Bsc_Pmf_Dim_Rec => p_Bsc_Pmf_Dim_Rec
         ,x_return_status => x_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
        );

      END IF;

      CLOSE c_dim_dimobj_mapping_exists;

    END IF;

    CLOSE c_bsc_dim_obj_exists;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF(x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                  ,p_data     =>      x_msg_data);
      END IF;
      IF(c_bsc_dim_obj_exists%ISOPEN) THEN
        CLOSE c_bsc_dim_obj_exists;
      END IF;
      IF(c_dim_dimobj_mapping_exists%ISOPEN) THEN
        CLOSE c_dim_dimobj_mapping_exists;
      END IF;
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF(x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                  ,p_data     =>      x_msg_data);
      END IF;
      IF(c_bsc_dim_obj_exists%ISOPEN) THEN
        CLOSE c_bsc_dim_obj_exists;
      END IF;
      IF(c_dim_dimobj_mapping_exists%ISOPEN) THEN
        CLOSE c_dim_dimobj_mapping_exists;
      END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF(x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                  ,p_data     =>      x_msg_data);
      END IF;
      IF(c_bsc_dim_obj_exists%ISOPEN) THEN
        CLOSE c_bsc_dim_obj_exists;
      END IF;
      IF(c_dim_dimobj_mapping_exists%ISOPEN) THEN
        CLOSE c_dim_dimobj_mapping_exists;
      END IF;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF(x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                  ,p_data     =>      x_msg_data);
      END IF;
      IF(c_bsc_dim_obj_exists%ISOPEN) THEN
        CLOSE c_bsc_dim_obj_exists;
      END IF;
      IF(c_dim_dimobj_mapping_exists%ISOPEN) THEN
        CLOSE c_dim_dimobj_mapping_exists;
      END IF;
END;

--=============================================================================

PROCEDURE Trans_DimObj_By_Given_Lang
(
      p_commit                IN          VARCHAR2 := FND_API.G_FALSE
  ,   p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,   p_Dimension_Level_Rec   IN          BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
  ,   x_return_status         OUT NOCOPY  VARCHAR2
  ,   x_error_Tbl             OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
) IS
        l_error_tbl                 BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
        BIS_DIMENSION_LEVEL_PVT.Trans_DimObj_By_Given_Lang
        (
                    p_commit                =>  p_commit
                ,   p_validation_level      =>  p_validation_level
                ,   p_Dimension_Level_Rec   =>  p_Dimension_Level_Rec
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
      , p_error_proc_name   => G_PKG_NAME||'.Trans_DimObj_By_Given_Lang'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
END Trans_DimObj_By_Given_Lang;

--=============================================================================
FUNCTION Return_Master_Level (
  p_dim_level_short_name IN VARCHAR2
) RETURN VARCHAR2 IS

CURSOR c_master IS
  SELECT master_level
  FROM   bis_levels
  WHERE  short_name = p_dim_level_short_name;

  l_master_dim_level VARCHAR2(30);

BEGIN
  IF (c_master%ISOPEN) THEN
    CLOSE c_master;
  END IF;
  OPEN c_master;
  FETCH c_master INTO l_master_dim_level;
  CLOSE c_master;

  RETURN l_master_dim_level;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_master%ISOPEN) THEN
      CLOSE c_master;
    END IF;
    RETURN NULL;
END;
--=============================================================================
FUNCTION Is_Related_By_Master (
   p_dim_level_short_name IN VARCHAR2
  ,p_master_dim_level_short_name IN VARCHAR2
) RETURN VARCHAR2 IS

  l_master1 VARCHAR2(30);
  l_master2 VARCHAR2(30);

BEGIN

  l_master1 := Return_Master_Level(p_dim_level_short_name);

  IF ( (p_master_dim_level_short_name IS NULL) OR (l_master1 IS NULL) ) THEN
    RETURN C_NO_MASTER;
  ELSE
    l_master2 := Return_Master_Level(p_master_dim_level_short_name);
    IF (l_master1 = l_master2) THEN
      RETURN C_SIBLING;
    ELSIF (l_master1 = p_master_dim_level_short_name) THEN
      RETURN C_PARENT;
    ELSE
      RETURN C_NO_REL;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN C_NO_REL;
END;

--=============================================================================
 Procedure Retrieve_Dimension_Level_Wrap
( p_dim_level_short_name IN VARCHAR2
, p_master_dim_level_short_name IN VARCHAR2
, p_dim_short_name IN VARCHAR2
, x_dim_level_name OUT NOCOPY VARCHAR2
, x_dim_level_desc OUT NOCOPY VARCHAR2
, x_default_search OUT NOCOPY VARCHAR2
, x_long_lov OUT NOCOPY VARCHAR2
, x_master_level OUT NOCOPY VARCHAR2
, x_is_related_by_master OUT NOCOPY VARCHAR2
, x_view_object_name OUT NOCOPY VARCHAR2
, x_default_values_api OUT NOCOPY VARCHAR2
, x_enabled OUT NOCOPY VARCHAR2
, x_hide OUT NOCOPY VARCHAR2
, x_dim_group_id OUT NOCOPY  NUMBER
, x_dim_level_id OUT NOCOPY  NUMBER
, x_dim_level_index OUT NOCOPY  NUMBER
, x_total_flag OUT NOCOPY  NUMBER
, x_total_disp_name OUT NOCOPY  VARCHAR2
, x_dim_level_where_clause OUT NOCOPY VARCHAR2
, x_comparison_flag OUT NOCOPY  NUMBER
, x_comp_disp_name OUT NOCOPY  VARCHAR2
, x_filter_column OUT NOCOPY  VARCHAR2
, x_filter_value OUT NOCOPY  NUMBER
, x_default_value OUT NOCOPY  VARCHAR2
, x_default_type OUT NOCOPY  NUMBER
, x_parent_in_total OUT NOCOPY  NUMBER
, x_no_items OUT NOCOPY  NUMBER
, x_pmf_dim_id OUT NOCOPY  NUMBER
, x_pmf_dim_level_id OUT NOCOPY  NUMBER
, x_comparison_label_code OUT NOCOPY VARCHAR2
, x_level_values_view_name OUT NOCOPY VARCHAR2
, x_source OUT NOCOPY VARCHAR2
, x_attribute_code OUT NOCOPY VARCHAR2
, x_application_id OUT NOCOPY NUMBER
, x_drill_to_form_function OUT NOCOPY VARCHAR2
, x_dim_name OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY VARCHAR2
, x_msg_data OUT NOCOPY VARCHAR2
)
IS
  l_Dimension_Level_Rec_In  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_Dimension_Level_Rec_Out BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_return_status VARCHAR2(10);
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_count NUMBER;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  l_Dimension_Level_Rec_In.dimension_level_short_name := p_dim_level_short_name;

  BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level
  ( p_api_version         => 1.0
  , p_Dimension_Level_Rec => l_Dimension_Level_Rec_In
  , x_Dimension_Level_Rec => l_Dimension_Level_Rec_Out
  , x_return_status       => l_return_status
  , x_error_Tbl           => l_error_tbl
  );

  IF NOT ( (l_return_status = 'S') OR (l_return_status IS NULL) ) THEN
    IF (l_error_tbl.COUNT > 0) THEN
      FND_MESSAGE.SET_NAME('BIS',l_error_tbl(l_count).error_msg_name);
      FND_MSG_PUB.Add;
     END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  x_pmf_dim_id            := l_Dimension_Level_Rec_Out.dimension_id;
  x_pmf_dim_level_id      := l_Dimension_Level_Rec_Out.dimension_level_id;
  x_dim_name              := l_Dimension_Level_Rec_Out.dimension_name;
  x_default_search        := l_Dimension_Level_Rec_Out.default_search;
  x_long_lov              := l_Dimension_Level_Rec_Out.Long_Lov;
  x_master_level          := l_Dimension_Level_Rec_Out.Master_Level;
  x_view_object_name      := l_Dimension_Level_Rec_Out.View_Object_Name;
  x_default_values_api    := l_Dimension_Level_Rec_Out.Default_Values_Api;
  x_enabled               := l_Dimension_Level_Rec_Out.Enabled;
  x_hide                  := l_Dimension_Level_Rec_Out.Hide;
  x_dim_level_name        := l_Dimension_Level_Rec_Out.Dimension_Level_Name;
  x_dim_level_desc        := l_Dimension_Level_Rec_Out.Description;
  x_comparison_label_code := l_Dimension_Level_Rec_Out.Comparison_Label_Code;
  x_level_values_view_name:= l_Dimension_Level_Rec_Out.Level_Values_View_Name;
  x_source                := l_Dimension_Level_Rec_Out.source;
  x_attribute_code        := l_Dimension_Level_Rec_Out.Attribute_Code;
  x_application_id        := l_Dimension_Level_Rec_Out.Application_ID;
  x_drill_to_form_function := l_Dimension_Level_Rec_Out.Drill_To_Form_Function;

  BSC_DIMENSION_GROUPS_PUB.Retrieve_Sys_Dim_Lvls_Grp_Wrap (
     p_dim_level_shortname => p_dim_level_short_name
    ,p_dim_shortname => p_dim_short_name
    ,x_dim_group_id => x_dim_group_id
    ,x_dim_level_id => x_dim_level_id
    ,x_dim_level_index => x_dim_level_index
    ,x_total_flag => x_total_flag
    ,x_total_disp_name => x_total_disp_name
    ,x_dim_level_where_clause => x_dim_level_where_clause
    ,x_comparison_flag => x_comparison_flag
    ,x_comp_disp_name => x_comp_disp_name
    ,x_filter_column => x_filter_column
    ,x_filter_value => x_filter_value
    ,x_default_value => x_default_value
    ,x_default_type => x_default_type
    ,x_parent_in_total => x_parent_in_total
    ,x_no_items => x_no_items
    ,x_return_status => x_return_status
    ,x_msg_count => x_msg_count
    ,x_msg_data => x_msg_data
   );

  IF NOT ( (l_return_status = 'S') OR (l_return_status IS NULL) ) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  x_is_related_by_master := Is_Related_By_Master (
                               p_dim_level_short_name => p_dim_level_short_name
                  ,p_master_dim_level_short_name => p_master_dim_level_short_name);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get(
         p_encoded   => 'F'
        ,p_count     =>  x_msg_count
        ,p_data      =>  x_msg_data
       );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get(
         p_encoded   => 'F'
        ,p_count     =>  x_msg_count
        ,p_data      =>  x_msg_data
       );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level_Wrap ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level_Wrap ';
    END IF;
 END Retrieve_Dimension_Level_Wrap;
--
--=============================================================================
--

-- get customized values for name , description and enabled
FUNCTION get_customized_name( p_dim_level_id IN NUMBER) RETURN VARCHAR2 AS
BEGIN
  RETURN BIS_DIMENSION_LEVEL_PVT.get_customized_name( p_dim_level_id => p_dim_level_id);
END get_customized_name;

FUNCTION get_customized_description( p_dim_level_id IN NUMBER) RETURN VARCHAR2 AS
BEGIN
  RETURN BIS_DIMENSION_LEVEL_PVT.get_customized_description( p_dim_level_id => p_dim_level_id);
END get_customized_description;

FUNCTION get_customized_enabled( p_dim_level_id IN NUMBER) RETURN VARCHAR2 AS
BEGIN
  RETURN BIS_DIMENSION_LEVEL_PVT.get_customized_enabled( p_dim_level_id => p_dim_level_id);
END get_customized_enabled;

FUNCTION get_customized_enabled( p_dim_level_sht_name IN VARCHAR2) RETURN VARCHAR2 AS
BEGIN
  RETURN BIS_DIMENSION_LEVEL_PVT.get_customized_enabled( p_dim_level_sht_name => p_dim_level_sht_name);
END get_customized_enabled;

PROCEDURE validate_disabling (p_dim_level_id IN NUMBER) IS
BEGIN
  BIS_DIMENSION_LEVEL_PVT.validate_disabling(p_dim_level_id => p_dim_level_id );
END validate_disabling;

Procedure Retrieve_Dim_Level_Cust_Wrap
( p_dim_level_short_name    IN VARCHAR2
, p_dim_short_name          IN VARCHAR2
, x_dim_level_cust_name    OUT NOCOPY VARCHAR2
, x_dim_level_cust_desc    OUT NOCOPY VARCHAR2
, x_dim_level_cust_enabled OUT NOCOPY VARCHAR2
) AS
  CURSOR c_cust IS SELECT level_id FROM bis_levels WHERE short_name = p_dim_level_short_name;
  l_level_id   NUMBER;
BEGIN
  IF (c_cust%ISOPEN) THEN
    CLOSE c_cust;
  END IF;

  OPEN c_cust;
  FETCH c_cust INTO l_level_id;
  CLOSE c_cust;

  IF (l_level_id IS NOT NULL) THEN
    x_dim_level_cust_name    :=  get_customized_name( p_dim_level_id => l_level_id);
    x_dim_level_cust_desc    :=  get_customized_description( p_dim_level_id => l_level_id);
    x_dim_level_cust_enabled :=  get_customized_enabled( p_dim_level_id => l_level_id);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_cust%ISOPEN) THEN
      CLOSE c_cust;
    END IF;
END Retrieve_Dim_Level_Cust_Wrap;

PROCEDURE Update_Dim_Obj_Obsolete_Flag (
    p_commit                      IN VARCHAR2 := FND_API.G_FALSE,
    p_dim_obj_short_name          IN VARCHAR2,
    p_hide                        IN VARCHAR2,
    x_return_status               OUT nocopy VARCHAR2,
    x_Msg_Count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT nocopy VARCHAR2
) IS
  l_Dimension_Level_Rec BIS_Dimension_Level_PUB.Dimension_Level_Rec_Type;
  x_Dimension_Level_Rec BIS_Dimension_Level_PUB.Dimension_Level_Rec_Type;
  l_Bsc_Dim_Level_Rec_Type  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
  l_error_tbl      BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
    SAVEPOINT DimObjObsoleteUpdate;
    IF (p_dim_obj_short_name IS NULL OR p_dim_obj_short_name = '') THEN
       FND_MESSAGE.SET_NAME('BIS','BIS_PMF_INVALID_DIM_OBJECT_VALUE');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_hide IS NULL OR (p_hide <> FND_API.G_TRUE AND p_hide <> FND_API.G_FALSE)) THEN
       FND_MESSAGE.SET_NAME('BIS','BIS_PMF_INVALID_OBSOLETE_FLAG');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_Dimension_Level_Rec.Dimension_Level_Short_Name := p_dim_obj_short_name;

    BIS_Dimension_Level_PVT.Retrieve_Dimension_Level
    ( p_api_version         => 1.0
    , p_Dimension_Level_Rec => l_Dimension_Level_Rec
    , x_Dimension_Level_Rec => x_Dimension_Level_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => l_error_tbl
    );

    x_Dimension_Level_Rec.Hide := p_Hide;

    BIS_Dimension_Level_PVT.Update_Dimension_Level
    (  p_api_version         => 1.0
    , p_Dimension_Level_Rec => x_Dimension_Level_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => l_error_tbl
    );

    SELECT dim_level_id
    INTO   l_Bsc_Dim_Level_Rec_Type.Bsc_Level_Id
    FROM   bsc_sys_dim_levels_vl
    WHERE  short_name = p_dim_obj_short_name;

    IF(l_Bsc_Dim_Level_Rec_Type.Bsc_Level_Id IS NOT NULL) THEN
      BSC_DIMENSION_LEVELS_PUB.Update_Dim_Level
      ( p_commit         => FND_API.G_FALSE
      , p_Dim_Level_Rec  => l_Bsc_Dim_Level_Rec_Type
      , x_return_status  => x_return_status
      , x_msg_count      => x_msg_count
      , x_msg_data       => x_msg_data
      );
      IF((x_return_status IS NOT NULL) AND (x_return_status <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

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
      ROLLBACK TO DimObjObsoleteUpdate;
      IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Update_Dim_Obj_Obsolete_Flag ';
      ELSE
         x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Update_Dim_Obj_Obsolete_Flag ';
      END IF;
 END Update_Dim_Obj_Obsolete_Flag;


END BIS_DIMENSION_LEVEL_PUB;

/
