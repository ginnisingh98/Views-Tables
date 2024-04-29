--------------------------------------------------------
--  DDL for Package Body BIS_DIMENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_DIMENSION_PVT" AS
/* $Header: BISVDIMB.pls 120.1 2006/01/06 03:24:15 akoduri noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVDIMB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for managing Dimensions and dimension levels for the
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
REM | 04-JAN-03 mahrao   Changed OUT parameter to IN OUT in Valu_Id_Conevrsion
REM |                    as fix for bug 2735908
REM | 27-JAN-03 arhegde For having different local variables for IN and OUT |
REM |                   parameters (bug#2758428)                            |
REM | 19-MAR-03 PAJOHRI  Bug #2856554, Added 'description' as one more      |
REM |                    selection parameter in procedure Retrieve_Dimension|
REM |                    cursor's select query.                             |
REM | 20-MAR-03 PAJOHRI  Bug #2860782, Added 'description' in               |
REM |                                  Retrieve_Dimensions API              |
REM | 23-FEB-03 PAJOHRI  Modified the package, to handle Application_ID     |
REM |                         which is added into the bis_levels            |
REM | 23-FEB-03 PAJOHRI  Added procedures    DELETE_DIMENSION               |
REM | 10-JUN-03 rchandra use -1 as dimension_id if short name is UNASSIGNED |
REM |                      for bug 2994108
REM | 07-JUL-2003 arhegde bug#3028436 Added get_unique_dim_group_name()     |
REM | 09-JUL-2003 arhegde bug#3028436 Moved logic to BSC API from here      |
REM |            Removed get_unique_dim_group_name()                        |
REM | 11-JUL-03 MAHRAO Modified the package, to handle dim_grp_ID           |
REM |                         which is added into the bis_dimensions        |
REM | 29-JUN-2004 ankgoel bug#3711250 Handle translation of dimension_id=-1 |
REM | 30-Jul-04   rpenneru  Modified for enhancemen#3748519                 |
REM | 29-SEP-2004 ankgoel   Added WHO columns in Rec for Bug#3891748        |
REM | 21-DEC-04   vtulasi   Modified for bug#4045278 - Addtion of LUD       |
REM | 09-FEB-05   ankgoel   Bug#4172055 Dimension name validations          |
REM | 06-Jan-06   akoduri   Enh#4739401 - Hide Dimensions/Dim Objects       |
REM +=======================================================================+
*/
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_DIMENSION_PVT';
C_UNASSIGNED CONSTANT VARCHAR2(30):='UNASSIGNED';
C_PMF CONSTANT VARCHAR2(10) := '_PMF';

--
--
PROCEDURE Rename_BSC_Dimension
( p_Dimension_Short_Name  IN  VARCHAR2
, p_Dimension_Name        IN  VARCHAR2
);
--
-- returns the record with the G_MISS_CHAR/G_MISS_NUM replaced
-- by null
--
PROCEDURE SetNULL
( p_Dimension_Rec IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_Dimension_Rec OUT NOCOPY BIS_DIMENSION_PUB.Dimension_Rec_Type
);
--
-- queries database to retrieve the dimension from the database
-- updates the record with the changes sent in
--
PROCEDURE UpdateRecord
( p_Dimension_Rec BIS_Dimension_PUB.Dimension_Rec_Type
, x_Dimension_Rec OUT NOCOPY BIS_Dimension_PUB.Dimension_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Create_New_Dimension
( p_dimension_id          IN NUMBER,    -- l_id
  p_dimension_short_name  IN VARCHAR2,  -- l_Dimension_Rec.Dimension_Short_Name
  p_application_id        IN NUMBER  := NULL,
  p_dim_grp_id            IN NUMBER,
  p_hide                  IN VARCHAR2 := FND_API.G_FALSE,
  p_created_by            IN NUMBER,    -- created_by
  p_last_updated_by       IN NUMBER,    -- last_updated_by
  p_login_id              IN NUMBER,    -- l_login_id
  p_dimension_name        IN VARCHAR2,  -- l_Dimension_Rec.Dimension_Name
  p_description           IN VARCHAR2,   -- l_Dimension_Rec.Description
  p_last_update_date      IN DATE := SYSDATE
);
--
PROCEDURE SetNULL
( p_Dimension_Rec IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_Dimension_Rec OUT NOCOPY BIS_DIMENSION_PUB.Dimension_Rec_Type
)
IS
BEGIN

  x_Dimension_rec.Dimension_ID
    := BIS_UTILITIES_PVT.CheckMissNum(p_Dimension_rec.Dimension_ID);
  x_Dimension_rec.Dimension_Short_Name
    := BIS_UTILITIES_PVT.CheckMissChar
       (p_Dimension_rec.Dimension_Short_Name);
  x_Dimension_rec.Dimension_Name
    := BIS_UTILITIES_PVT.CheckMissChar(p_Dimension_rec.Dimension_Name);
  x_Dimension_rec.Description
    := BIS_UTILITIES_PVT.CheckMissChar(p_Dimension_rec.Description);
  x_Dimension_rec.Application_ID
    := BIS_UTILITIES_PVT.CheckMissChar(p_Dimension_rec.Application_ID);
  x_Dimension_rec.dim_grp_id
    := BIS_UTILITIES_PVT.CheckMissChar(p_Dimension_rec.dim_grp_id);
  x_Dimension_rec.hide
    := BIS_UTILITIES_PVT.CheckMissChar(p_Dimension_rec.hide);
  x_Dimension_rec.Created_By := BIS_UTILITIES_PVT.CheckMissNum(p_Dimension_Rec.Created_By);
  x_Dimension_rec.Creation_Date := BIS_UTILITIES_PVT.CheckMissDate(p_Dimension_Rec.Creation_Date);
  x_Dimension_rec.Last_Updated_By := BIS_UTILITIES_PVT.CheckMissNum(p_Dimension_Rec.Last_Updated_By);
  x_Dimension_rec.Last_Update_Date := BIS_UTILITIES_PVT.CheckMissDate(p_Dimension_Rec.Last_Update_Date);
  x_Dimension_rec.Last_Update_Login := BIS_UTILITIES_PVT.CheckMissNum(p_Dimension_Rec.Last_Update_Login);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END SetNULL;
--
PROCEDURE UpdateRecord
( p_Dimension_Rec BIS_Dimension_PUB.Dimension_Rec_Type
, x_Dimension_Rec OUT NOCOPY BIS_Dimension_PUB.Dimension_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
  l_Dimension_Rec BIS_Dimension_PUB.Dimension_Rec_Type;
  l_return_status VARCHAR2(10);
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status:= FND_API.G_RET_STS_SUCCESS;

  -- retrieve record from db
  BIS_Dimension_PVT.Retrieve_Dimension
  ( p_api_version   => 1.0
  , p_Dimension_Rec => p_Dimension_Rec
  , x_Dimension_Rec => l_Dimension_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- apply changes
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Rec.Dimension_ID)
      = FND_API.G_TRUE
    ) THEN
    l_Dimension_Rec.Dimension_ID := p_Dimension_Rec.Dimension_ID;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing
                        (p_Dimension_Rec.Dimension_Short_Name)
      = FND_API.G_TRUE
    ) THEN
    l_Dimension_Rec.Dimension_Short_Name
      := p_Dimension_Rec.Dimension_Short_Name ;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Rec.Dimension_Name)
      = FND_API.G_TRUE
    ) THEN
    l_Dimension_Rec.Dimension_Name := p_Dimension_Rec.Dimension_Name;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Rec.Description)
      = FND_API.G_TRUE
    ) THEN
    l_Dimension_Rec.Description := p_Dimension_Rec.Description;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Rec.Application_ID)
      = FND_API.G_TRUE
    ) THEN
    l_Dimension_Rec.Application_ID := p_Dimension_Rec.Application_ID;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Rec.dim_grp_id)
      = FND_API.G_TRUE
    ) THEN
    l_Dimension_Rec.dim_grp_id := p_Dimension_Rec.dim_grp_id;
  END IF;

  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Rec.hide)
      = FND_API.G_TRUE
    ) THEN
    l_Dimension_Rec.hide := p_Dimension_Rec.hide;
  END IF;

  --
  x_Dimension_Rec := l_Dimension_Rec;

  --
--commented out NOCOPY RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UpdateRecord;
--
--

PROCEDURE Retrieve_Dimensions
( p_api_version   IN  NUMBER
, x_Dimension_Tbl OUT NOCOPY BIS_DIMENSION_PUB.Dimension_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Dimension_Rec  BIS_DIMENSION_PUB.Dimension_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

  cursor cr_all_dimensions is
       SELECT dimension_id
            , dimension_short_name
            , dimension_name
            , description
            , application_id
            , dim_grp_id
            , hide_in_design
       from bisbv_dimensions;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  for cr in cr_all_dimensions loop
    l_Dimension_Rec.dimension_id         := cr.dimension_id;
    l_Dimension_Rec.dimension_short_name := cr.dimension_short_name;
    l_Dimension_Rec.dimension_name       := cr.dimension_name;
    l_Dimension_Rec.description          := cr.description;
    l_Dimension_Rec.application_id       := cr.application_id;
    l_Dimension_Rec.dim_grp_id           := cr.dim_grp_id;
    l_Dimension_Rec.hide                 := cr.hide_in_design;

    x_dimension_tbl(x_dimension_tbl.count + 1) := l_Dimension_Rec;
  END loop;

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Dimensions'
       , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Dimensions;
--

PROCEDURE Retrieve_Dimension
( p_api_version   IN  NUMBER
, p_Dimension_Rec IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_Dimension_Rec OUT NOCOPY BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
is
 l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
 CURSOR cr_dim_id IS
  SELECT dimension_id, short_name, name, description,
         application_id, dim_grp_id, hide_in_design
  FROM bis_dimensions_vl
  WHERE dimension_id=p_Dimension_Rec.dimension_id;

 CURSOR cr_dim_short_name IS
  SELECT dimension_id, short_name, name, description,
         application_id, dim_grp_id, hide_in_design
  FROM bis_dimensions_vl
  WHERE short_name=p_Dimension_Rec.dimension_short_name;

 CURSOR cr_dim_name IS
  SELECT dimension_id, short_name, name, description,
         application_id, dim_grp_id, hide_in_design
  FROM bis_dimensions_vl
  WHERE name=p_Dimension_Rec.dimension_name;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_Dimension_Rec := p_Dimension_Rec;

  IF BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Rec.dimension_id)
     = FND_API.G_TRUE
  THEN
    OPEN cr_dim_id;
    FETCH cr_dim_id
    INTO x_Dimension_Rec.dimension_id
       , x_Dimension_Rec.dimension_short_name
       , x_Dimension_Rec.dimension_name
       , x_Dimension_Rec.description
       , x_Dimension_Rec.Application_ID
       , x_Dimension_Rec.dim_grp_id
       , x_Dimension_Rec.hide;
    IF cr_dim_id%ROWCOUNT = 0 THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE cr_dim_id;

  ELSIF
     BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Rec.dimension_short_name)
     = FND_API.G_TRUE
  THEN

    OPEN cr_dim_short_name;
    FETCH cr_dim_short_name
    INTO x_Dimension_Rec.dimension_id
       , x_Dimension_Rec.dimension_short_name
       , x_Dimension_Rec.dimension_name
       , x_Dimension_Rec.description
       , x_Dimension_Rec.Application_ID
       , x_Dimension_Rec.dim_grp_id
       , x_Dimension_Rec.hide;
    IF cr_dim_short_name%ROWCOUNT = 0 THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE cr_dim_short_name;

  ELSIF
     BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Rec.dimension_name)
     = FND_API.G_TRUE
  THEN
    OPEN cr_dim_name;
    FETCH cr_dim_short_name
    INTO x_Dimension_Rec.dimension_id
       , x_Dimension_Rec.dimension_short_name
       , x_Dimension_Rec.dimension_name
       , x_Dimension_Rec.description
       , x_Dimension_Rec.Application_ID
       , x_Dimension_Rec.dim_grp_id
       , x_Dimension_Rec.hide;
    IF cr_dim_name%ROWCOUNT = 0 THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE cr_dim_name;

  ELSE
    --added Add Error Message
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_VALUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Dimension'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

   --added this check
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_DIMENSION__VALUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Dimension'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
     RAISE FND_API.G_EXC_ERROR;
  END IF;


-- commented the RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      -- added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Dimension'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Dimension;
--
PROCEDURE Create_Dimension
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Dimension_Rec BIS_DIMENSION_PUB.Dimension_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  l_Dimension_Rec := p_Dimension_Rec;
  l_Dimension_Rec.Last_Update_Date := NVL(p_Dimension_Rec.Last_Update_Date, SYSDATE);
  Create_Dimension
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Dimension_Rec     => l_Dimension_Rec
  , p_owner             => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

--commented out NOCOPY RAISE
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message (
       p_error_msg_id      => SQLCODE
     , p_error_description => SQLERRM
     , p_error_proc_name   => G_PKG_NAME||'.Create_Dimension'
     , p_error_table       => l_error_tbl
     , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Create_Dimension;
--
PROCEDURE Create_Dimension
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, p_owner            IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_user_id          NUMBER;
  l_login_id         NUMBER;
  l_id               NUMBER;
  l_Dimension_Rec BIS_DIMENSION_PUB.Dimension_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

DUPLICATE_DIMENSION_VALUE EXCEPTION;
PRAGMA EXCEPTION_INIT(DUPLICATE_DIMENSION_VALUE, -1);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_Dimension_Rec := p_dimension_Rec;

  SetNULL
  ( p_dimension_Rec => p_dimension_Rec
  , x_dimension_Rec => l_Dimension_Rec
  );

  Validate_Dimension( p_api_version
                    , p_validation_level
                    , l_Dimension_Rec
                    , x_return_status
                    , x_error_Tbl
                    );

  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_NAME_SHORT_NAME_MISSING'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Create_Dimension'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- ankgoel: bug#3891748 - Created_By will take precedence over Owner.
  -- Last_Updated_By can be different from Created_By while creating dimensions
  -- during sync-up
  IF (l_Dimension_Rec.Created_By IS NULL) THEN
    l_Dimension_Rec.Created_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  END IF;
  IF (l_Dimension_Rec.Last_Updated_By IS NULL) THEN
    l_Dimension_Rec.Last_Updated_By := l_Dimension_Rec.Created_By;
  END IF;
  IF (l_Dimension_Rec.Last_Update_Login IS NULL) THEN
    l_Dimension_Rec.Last_Update_Login := fnd_global.LOGIN_ID;
  END IF;

  --

  IF ( l_Dimension_Rec.Dimension_Short_Name = C_UNASSIGNED ) THEN
    l_id := -1;
  ELSE
    SELECT bis_dimensions_s.NextVal INTO l_id from dual;
  END IF;

  l_Dimension_Rec.Last_Update_Date := NVL(p_Dimension_Rec.Last_Update_Date, SYSDATE);

  Create_New_Dimension
  ( p_dimension_id          => l_id
  , p_dimension_short_name  => l_Dimension_Rec.Dimension_Short_Name
  , p_application_id        => l_Dimension_Rec.Application_ID
  , p_dim_grp_id            => l_Dimension_Rec.dim_grp_id
  , p_hide                  => l_Dimension_Rec.hide
  , p_created_by            => l_Dimension_Rec.Created_By
  , p_last_updated_by       => l_Dimension_Rec.Last_Updated_By
  , p_login_id              => l_Dimension_Rec.Last_Update_Login
  , p_dimension_name        => l_Dimension_Rec.Dimension_Name
  , p_description           => l_Dimension_Rec.Description
  , p_last_update_date      => l_Dimension_Rec.Last_Update_Date
  );

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END if;

EXCEPTION
    WHEN DUPLICATE_DIMENSION_VALUE THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_DIMENSION_UNIQUENESS_ERROR'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Create_Dimension'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );

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
      , p_error_proc_name   => G_PKG_NAME||'.Create_Dimension'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );


END Create_Dimension;

--

PROCEDURE Create_New_Dimension
( p_dimension_id          IN NUMBER,    -- l_id
  p_dimension_short_name  IN VARCHAR2,  -- l_Dimension_Rec.Dimension_Short_Name
  p_application_id        IN NUMBER := NULL,
  p_dim_grp_id            IN NUMBER,
  p_hide                  IN VARCHAR2 := FND_API.G_FALSE,
  p_created_by            IN NUMBER,    -- created_by
  p_last_updated_by       IN NUMBER,    -- last_updated_by
  p_login_id              IN NUMBER,    -- l_login_id
  p_dimension_name        IN VARCHAR2,  -- l_Dimension_Rec.Dimension_Name
  p_description           IN VARCHAR2,   -- l_Dimension_Rec.Description
  p_last_update_date      IN DATE := SYSDATE
)
IS

 l_msg      VARCHAR2(3000);

BEGIN

  SAVEPOINT InsertIntoBISDims;

  INSERT INTO bis_dimensions(
        DIMENSION_ID
      , SHORT_NAME
      , APPLICATION_ID
      , DIM_GRP_ID
      , HIDE_IN_DESIGN
      , CREATION_DATE
      , CREATED_BY
      , LAST_UPDATE_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_LOGIN
      )
  VALUES
      ( p_dimension_id
      , p_dimension_short_name
      , p_application_id
      , p_dim_grp_id
      , p_hide
      , p_last_update_date
      , p_created_by
      , p_last_update_date
      , p_last_updated_by
      , p_login_id
      );


  INSERT INTO bis_dimensions_tl (
        DIMENSION_ID,
        LANGUAGE,
        NAME,
        DESCRIPTION,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        TRANSLATED,
        SOURCE_LANG
      )
       SELECT
        p_dimension_id
      , L.LANGUAGE_CODE
      , p_dimension_name
      , p_description
      , p_last_update_date
      , p_created_by
      , p_last_update_date
      , p_last_updated_by
      , p_login_id
      ,  'Y'
      , userenv('LANG')
       FROM FND_LANGUAGES L
          , BIS_DIMENSIONS D
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
       AND D.SHORT_NAME = p_dimension_short_name
       AND NOT EXISTS
          (SELECT 'EXISTS'
          FROM BIS_DIMENSIONS_TL TL
             , BIS_DIMENSIONS D
          WHERE TL.DIMENSION_ID = D.DIMENSION_ID
          AND D.SHORT_NAME = p_dimension_short_name
          AND TL.LANGUAGE  = L.LANGUAGE_CODE) ;

EXCEPTION

  WHEN OTHERS THEN

    /*
    fnd_message.set_name('BIS', 'BIS_DIM_UPLD_FAIL');
    fnd_message.set_token('SHORT_NAME', p_dimension_short_name);
    fnd_message.set_token('NAME', p_dimension_name);
    l_msg := fnd_message.get;
    */
    l_msg := 'Failed to upload ' || p_dimension_short_name;
    l_msg := l_msg || ' . Dimension name: ' || p_dimension_name ;
    l_msg := l_msg || ' already exists in the database.' ;
    BIS_UTILITIES_PUB.put_line(p_text =>l_msg);

    ROLLBACK TO InsertIntoBISDims;
    RAISE;

END Create_New_Dimension;

--

PROCEDURE Update_Dimension
( p_api_version   IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_Dimension_Rec BIS_DIMENSION_PUB.Dimension_Rec_Type;
BEGIN

  l_Dimension_Rec := p_Dimension_Rec;
  l_Dimension_Rec.Last_Update_Date := NVL(p_Dimension_Rec.Last_Update_Date, SYSDATE);
  Update_Dimension
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Dimension_Rec     => l_Dimension_Rec
  , p_owner             => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

--commented out NOCOPY RAISE
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --added last two parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Update_Dimension'
     , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Dimension;
--
PROCEDURE Update_Dimension
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec    IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, p_owner            IN  VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_user_id       number;
  l_login_id      number;
  l_count         NUMBER := 0;
  l_Dimension_Rec BIS_DIMENSION_PUB.Dimension_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

DUPLICATE_DIMENSION_VALUE EXCEPTION;
PRAGMA EXCEPTION_INIT(DUPLICATE_DIMENSION_VALUE, -1);

BEGIN

   -- retrieve record from database and apply changes
  UpdateRecord
  ( p_Dimension_Rec => p_Dimension_Rec
  , x_Dimension_Rec => l_Dimension_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );

  Validate_Dimension
  ( p_api_version
  , p_validation_level
  , l_Dimension_Rec
  , x_return_status
  , x_error_Tbl
  );

  --added  Add_Error_Message
  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     l_error_tbl := x_error_tbl;
     BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_ID'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Update_Dimension'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  l_user_id :=  BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  l_login_id := fnd_global.LOGIN_ID;
  --

  l_Dimension_Rec.Last_Update_Date := NVL(p_Dimension_Rec.Last_Update_Date, SYSDATE);

  Update bis_dimensions
  set
    SHORT_NAME        = l_Dimension_Rec.Dimension_Short_Name
  , APPLICATION_ID    = l_Dimension_Rec.Application_ID
  , DIM_GRP_ID        = l_Dimension_Rec.dim_grp_id
  , HIDE_IN_DESIGN    = l_Dimension_Rec.hide
  , LAST_UPDATE_DATE  = l_Dimension_Rec.Last_Update_Date
  , LAST_UPDATED_BY   = l_user_id
  , LAST_UPDATE_LOGIN = l_login_id
  where dimension_ID  = l_Dimension_Rec.Dimension_Id;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END if;

  Translate_dimension
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Dimension_Rec     => l_Dimension_Rec
  , p_owner             => p_owner
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

--commented out NOCOPY RAISE
EXCEPTION
   WHEN DUPLICATE_DIMENSION_VALUE THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_DIMENSION_UNIQUENESS_ERROR'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Update_Dimension'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Dimension;
--
--
PROCEDURE Translate_Dimension
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec     IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_Dimension_Rec BIS_DIMENSION_PUB.Dimension_Rec_Type;
BEGIN

  l_Dimension_Rec := p_Dimension_Rec;
  l_Dimension_Rec.Last_Update_Date := NVL(p_Dimension_Rec.Last_Update_Date, SYSDATE);
  Translate_Dimension
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Dimension_Rec     => l_Dimension_Rec
  , p_owner             => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

--commented out NOCOPY RAISE
  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Translate_Dimension'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );

    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Translate_Dimension;
--
PROCEDURE Translate_Dimension
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec     IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, p_owner             IN  VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_user_id           NUMBER;
  l_login_id          NUMBER;
  l_count             NUMBER := 0;
  l_Dimension_Rec BIS_DIMENSION_PUB.Dimension_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

   -- retrieve record from database and apply changes
  UpdateRecord
  ( p_Dimension_Rec => p_Dimension_Rec
  , x_Dimension_Rec => l_Dimension_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );

  Validate_Dimension
  ( p_api_version
  , p_validation_level
  , l_Dimension_Rec
  , x_return_status
  , x_error_Tbl
  );

  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  l_user_id :=  BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  l_login_id := fnd_global.LOGIN_ID;
  --

  l_Dimension_Rec.Last_Update_Date := NVL(p_Dimension_Rec.Last_Update_Date, SYSDATE);

  Update bis_dimensions_TL
  set
    NAME              = l_Dimension_Rec.Dimension_Name
  , DESCRIPTION       = l_Dimension_Rec.description
  , LAST_UPDATE_DATE  = l_Dimension_Rec.Last_Update_Date
  , LAST_UPDATED_BY   = l_user_id
  , LAST_UPDATE_LOGIN = l_login_id
  , SOURCE_LANG       = userenv('LANG')
  where DIMENSION_ID  = l_Dimension_Rec.Dimension_Id
  and userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END if;

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Translate_Dimension'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Translate_Dimension;
--
--
PROCEDURE Validate_Dimension
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec    IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_error_tbl_p BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  BEGIN

    BIS_DIMENSION_VALIDATE_PVT.Validate_Record
    ( p_api_version        => p_api_version
    , p_validation_level   => p_validation_level
    , p_Dimension_Rec      => p_Dimension_Rec
    , x_return_status      => x_return_status
    , x_error_tbl          => l_error_Tbl
    );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      l_error_tbl_p := x_error_tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
  END;

  IF (x_error_tbl.count > 0) THEN
    RAISE FND_API.G_EXC_ERROR;
  END if;

--commented out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl_p := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension'
      , p_error_table       => l_error_tbl_p
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Dimension;
--
-- Value - ID conversion
PROCEDURE Value_ID_Conversion
( p_api_version   IN  NUMBER
, p_Dimension_Rec IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_Dimension_Rec IN OUT NOCOPY BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_Dimension_Rec := p_Dimension_Rec;

  IF (BIS_UTILITIES_PUB.Value_Missing(x_Dimension_Rec.Dimension_id)
                       = FND_API.G_TRUE) THEN
    BIS_DIMENSION_PVT.Value_ID_Conversion
                       ( p_api_version
               , x_Dimension_Rec.Dimension_Short_Name
               , x_Dimension_Rec.Dimension_Name
               , x_Dimension_Rec.Dimension_ID
               , x_return_status
               , x_error_Tbl
                       );
  END if;

--comment out NOCOPY RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_ID_Conversion;
--
PROCEDURE Value_ID_Conversion
( p_api_version          IN  NUMBER
, p_Dimension_Short_Name IN  VARCHAR2
, p_Dimension_Name       IN  VARCHAR2
, x_Dimension_ID         OUT NOCOPY NUMBER
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
is
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
begin

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Short_Name)
                                          = FND_API.G_TRUE) THEN
    SELECT dimension_id INTO x_Dimension_ID
    FROM bis_dimensions_vl
    WHERE short_name = p_Dimension_Short_Name;
  elsIF (BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Name)
                                          = FND_API.G_TRUE) THEN
    SELECT dimension_id INTO x_Dimension_ID
    FROM bis_dimensions_vl
    WHERE name = p_Dimension_Name;
  else
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_NAME_SHORT_NAME_MISSING'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );

    RAISE FND_API.G_EXC_ERROR;
  END if;


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
      , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Value_ID_Conversion;
--
/* modified from ansingha's FUNCTION */
FUNCTION DuplicateDimension
( p_dimension_rec    BIS_DIMENSION_PUB.Dimension_Rec_Type
, p_dimensions_tbl   BIS_DIMENSION_PUB.Dimension_Tbl_Type
) return BOOLEAN
is
begin
  for i in 1 .. p_dimensions_tbl.count loop
    IF (p_dimensions_tbl(i).dimension_id = p_dimension_rec.dimension_id) THEN
      return TRUE;
    END if;
  END loop;
  return FALSE;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RAISE FND_API.G_EXC_ERROR;
   WHEN FND_API.G_EXC_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END DuplicateDimension;
--
PROCEDURE RemoveDuplicates
( p_dimension_table     in  BIS_DIMENSION_PUB.Dimension_tbl_type
, p_all_dimension_table in  BIS_DIMENSION_PUB.Dimension_tbl_type
, x_all_dimension_table out NOCOPY BIS_DIMENSION_PUB.Dimension_tbl_type
)
is
l_unique BOOLEAN;
l_rec    BIS_DIMENSION_PUB.Dimension_Rec_Type;
begin
--
  for i in 1 .. p_all_dimension_table.count loop
    l_rec := p_all_dimension_table(i);
    l_unique := true;
--
    for j in 1 .. p_dimension_table.count loop
      IF (p_dimension_table(j).Dimension_ID = l_rec.Dimension_ID) THEN
        l_unique := false;
        exit;
      END if;
    END loop;
--
    IF (l_unique) THEN
      x_all_dimension_table(x_all_dimension_table.count + 1) := l_rec;
    END if;
--
  END loop;
--
END RemoveDuplicates;
--

PROCEDURE Delete_Dimension
(
    p_commit                IN          VARCHAR2 := FND_API.G_FALSE
  , p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL
  , p_Dimension_Rec         IN          BIS_DIMENSION_PUB.Dimension_Rec_Type
  , x_return_status         OUT NOCOPY  VARCHAR2
  , x_error_Tbl             OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
) IS
    l_error_tbl                 BIS_UTILITIES_PUB.Error_Tbl_Type;
    l_Dimension_Rec             BIS_DIMENSION_PUB.Dimension_Rec_Type;
BEGIN
  SAVEPOINT DeleteFromBISDims;

  BIS_DIMENSION_PVT.Retrieve_Dimension
  ( p_api_version   =>  1.0
  , p_Dimension_Rec =>  p_Dimension_Rec
  , x_Dimension_Rec =>  l_Dimension_Rec
  , x_return_status =>  x_return_status
  , x_error_Tbl     =>  x_error_Tbl
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE FROM bis_dimensions WHERE
  DIMENSION_ID = l_Dimension_Rec.dimension_id;

  DELETE FROM bis_dimensions_tl WHERE
  DIMENSION_ID = l_Dimension_Rec.dimension_id;
  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END if;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO DeleteFromBISDims;
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO DeleteFromBISDims;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO DeleteFromBISDims;
   WHEN OTHERS THEN
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Delete_Dimension'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO DeleteFromBISDims;
END Delete_Dimension;
--

PROCEDURE Translate_Dim_By_Given_Lang
(
      p_commit                IN          VARCHAR2 := FND_API.G_FALSE
  ,   p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,   p_Dimension_Rec         IN          BIS_DIMENSION_PUB.Dimension_Rec_Type
  ,   x_return_status         OUT NOCOPY  VARCHAR2
  ,   x_error_Tbl             OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
) IS

      l_dim_id                    NUMBER;
      l_error_tbl                 BIS_UTILITIES_PUB.Error_Tbl_Type;
      l_user_id           NUMBER;
      l_login_id          NUMBER;

BEGIN
       SAVEPOINT TransDimByLangPvt;

       l_user_id := FND_GLOBAL.USER_ID;
       l_login_id := fnd_global.LOGIN_ID;

       SELECT DIMENSION_ID
       INTO   l_dim_id
       FROM   BIS_DIMENSIONS
       WHERE  SHORT_NAME = p_Dimension_Rec.Dimension_Short_Name;

       UPDATE BIS_DIMENSIONS_TL
       SET    NAME           = p_Dimension_Rec.Dimension_Name
             ,DESCRIPTION    = p_Dimension_Rec.Description
             ,LAST_UPDATE_DATE  = p_Dimension_Rec.Last_Update_Date
             ,LAST_UPDATED_BY   = l_user_id
             ,LAST_UPDATE_LOGIN = l_login_id
             ,SOURCE_LANG    = p_Dimension_Rec.Source_Lang
       WHERE  DIMENSION_ID   = l_dim_id
       AND    LANGUAGE       = p_Dimension_Rec.Language;

       IF (p_commit = FND_API.G_TRUE) THEN
         COMMIT;
       END if;
       x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO TransDimByLangPvt;
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO TransDimByLangPvt;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO TransDimByLangPvt;
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
      ROLLBACK TO TransDimByLangPvt;
END Translate_Dim_By_Given_Lang;

-- Bug#4172055: This API validates only PMF type dimensions.
PROCEDURE Validate_PMF_Unique_Name
( p_Dimension_Short_Name  IN  VARCHAR2
, p_Dimension_Name        IN  VARCHAR2
, x_return_status         OUT NOCOPY  VARCHAR2
)
IS
  CURSOR c_unique_name IS
    SELECT BD.short_name, BD.name, DECODE((SELECT  count(1)
      FROM bsc_sys_dim_levels_by_group DLG, bsc_sys_dim_levels_b DLB
      WHERE DLB.source = 'PMF'
      AND   DLG.dim_level_id = DLB.dim_level_id
      AND   BG.dim_group_id = DLG.dim_group_id), 0, 'BSC', 'PMF') type
    FROM bis_dimensions_vl BD, bsc_sys_dim_groups_vl BG
    WHERE UPPER(BD.Name) = UPPER(p_Dimension_Name)
    AND BD.dim_grp_id = BG.dim_group_id
    AND BD.short_name <> p_Dimension_Short_Name;

  l_unique_name_rec  c_unique_name%ROWTYPE;
  l_count            NUMBER;
BEGIN
  SELECT  COUNT(1) INTO l_count
    FROM  bis_dimensions_vl
    WHERE UPPER(name) = UPPER(p_Dimension_Name)
    AND   short_name <> p_Dimension_Short_Name;

  IF (l_count <> 0) THEN
    FOR l_unique_name_rec IN c_unique_name LOOP
      IF (l_unique_name_rec.type = 'PMF') THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
        Rename_BSC_Dimension(l_unique_name_rec.Short_Name, l_unique_name_rec.Name);
      END IF;
    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Validate_PMF_Unique_Name;

PROCEDURE Rename_BSC_Dimension
( p_Dimension_Short_Name  IN  VARCHAR2
, p_Dimension_Name        IN  VARCHAR2
)
IS
  l_new_disp_name  VARCHAR2(255);
  l_count          NUMBER := 1;
BEGIN
  l_new_disp_name := p_Dimension_Name;
  WHILE (l_count > 0) LOOP
    l_new_disp_name := BSC_UTILITY.get_Next_DispName(l_new_disp_name);

    SELECT COUNT(1) INTO l_count
      FROM  bis_dimensions_vl
      WHERE UPPER(name) = UPPER(l_new_disp_name);

  END LOOP;

  UPDATE bis_dimensions_tl
    SET name = l_new_disp_name
    WHERE dimension_id = (SELECT dimension_id FROM bis_dimensions WHERE short_name = p_Dimension_Short_Name)
    AND   userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Rename_BSC_Dimension;

END BIS_DIMENSION_PVT;

/
