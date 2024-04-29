--------------------------------------------------------
--  DDL for Package Body BIS_BUSINESS_PLAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BUSINESS_PLAN_PVT" AS
/* $Header: BISVBPB.pls 115.9 2004/02/13 08:22:43 ankgoel noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVBPB.pls                                                       |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for managing business plans for the
REM |     Key Performance Framework.
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 14-JUL-1999  irchen   Creation					    |
REM | 13-FEB-2004  ankgoel  bug #3436033. Used the base tables for          |
REM |			    "Value_ID_Conversion" & "Retrieve_Business_Plan"|
REM +=======================================================================+
*/
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_BUSINESS_PLAN_PVT';
--
--
-- returns the record with the G_MISS_CHAR/G_MISS_NUM replaced
-- by null
--
PROCEDURE SetNULL
( p_Business_Plan_Rec      IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, x_Business_Plan_Rec      OUT NOCOPY BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
);
--
-- queries database to retrieve the business plan from the database
-- updates the record with the changes sent in
--
PROCEDURE UpdateRecord
( p_Business_Plan_Rec    BIS_Business_Plan_PUB.Business_Plan_Rec_Type
, x_Business_Plan_Rec OUT NOCOPY BIS_Business_Plan_PUB.Business_Plan_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE SetNULL
( p_Business_Plan_Rec      IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, x_Business_Plan_Rec      OUT NOCOPY BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
)
IS
BEGIN

  x_business_plan_rec.Business_Plan_ID
    := BIS_UTILITIES_PVT.CheckMissNum(p_business_plan_rec.Business_Plan_ID);
  x_business_plan_rec.Business_Plan_Short_Name
    := BIS_UTILITIES_PVT.CheckMissChar
       (p_business_plan_rec.Business_Plan_Short_Name);
  x_business_plan_rec.Business_Plan_Name
    := BIS_UTILITIES_PVT.CheckMissChar(p_business_plan_rec.Business_Plan_Name);
  x_business_plan_rec.Description
    := BIS_UTILITIES_PVT.CheckMissChar(p_business_plan_rec.Description);
  x_business_plan_rec.Version_Number
    := BIS_UTILITIES_PVT.CheckMissNum(p_business_plan_rec.Version_Number);
  x_business_plan_rec.Current_Plan_Flag
    := BIS_UTILITIES_PVT.CheckMissChar(p_business_plan_rec.Current_Plan_Flag);

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
( p_Business_Plan_Rec BIS_Business_Plan_PUB.Business_Plan_Rec_Type
, x_Business_Plan_Rec OUT NOCOPY BIS_Business_Plan_PUB.Business_Plan_Rec_Type
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_Business_Plan_Rec BIS_Business_Plan_PUB.Business_Plan_Rec_Type;
l_return_status     VARCHAR2(10);
--
BEGIN
  x_return_status:= FND_API.G_RET_STS_SUCCESS;

  -- retrieve record from db
  BIS_Business_Plan_PVT.Retrieve_Business_Plan
  ( p_api_version       => 1.0
  , p_Business_Plan_Rec => p_Business_Plan_Rec
  , x_Business_Plan_Rec => l_Business_Plan_Rec
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

  -- apply changes
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Business_Plan_Rec.Business_Plan_ID)
      = FND_API.G_TRUE
    ) THEN
    l_Business_Plan_Rec.Business_Plan_ID
      := p_Business_Plan_Rec.Business_Plan_ID;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(
                        p_Business_Plan_Rec.Business_Plan_Short_Name)
      = FND_API.G_TRUE
    ) THEN
    l_Business_Plan_Rec.Business_Plan_Short_Name
      := p_Business_Plan_Rec.Business_Plan_Short_Name ;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(
                        p_Business_Plan_Rec.Business_Plan_Name)
      = FND_API.G_TRUE
    ) THEN
    l_Business_Plan_Rec.Business_Plan_Name
      := p_Business_Plan_Rec.Business_Plan_Name;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Business_Plan_Rec.Description)
      = FND_API.G_TRUE
    ) THEN
    l_Business_Plan_Rec.Description
      := p_Business_Plan_Rec.Description;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Business_Plan_Rec.Version_number)
      = FND_API.G_TRUE
    ) THEN
    l_Business_Plan_Rec.Version_number
      := p_Business_Plan_Rec.Version_number;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(
                        p_Business_Plan_Rec.Current_Plan_Flag)
      = FND_API.G_TRUE
    ) THEN
    l_Business_Plan_Rec.Current_Plan_Flag
      := p_Business_Plan_Rec.Current_Plan_Flag;
  END IF;

  x_Business_Plan_Rec := l_Business_Plan_Rec;
  --
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UpdateRecord;
--
--
Procedure Retrieve_Business_Plans
( p_api_version       IN  NUMBER
, x_Business_Plan_Tbl OUT NOCOPY BIS_BUSINESS_PLAN_PUB.Business_Plan_Tbl_Type
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_business_plan_rec  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type;
cursor cr_all_business_plans is
       select plan_id
            , short_name
            , name
            , description
            , version_no
            , current_plan_flag
       from bisfv_business_plans;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  for cr in cr_all_business_plans loop
    l_business_plan_rec.business_plan_id         := cr.plan_id;
    l_business_plan_rec.business_plan_short_name := cr.short_name;
    l_business_plan_rec.business_plan_name       := cr.name;
    l_business_plan_rec.description              := cr.description;
    l_business_plan_rec.version_number           := cr.version_no;
    l_business_plan_rec.current_plan_flag        := cr.current_plan_flag;

    x_business_plan_tbl(x_business_plan_tbl.count + 1) := l_business_plan_rec;

  end loop;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Business_Plans'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Business_Plans;
--
Procedure Retrieve_Business_Plan
( p_api_version       IN  NUMBER
, p_Business_Plan_Rec IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, x_Business_Plan_Rec OUT NOCOPY BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
is
begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  x_Business_Plan_Rec := p_Business_Plan_Rec;
    SELECT    bp.short_name
            , bptl.name
            , bptl.description
            , bp.version_no
            , bp.current_plan_flag
  INTO x_Business_Plan_Rec.business_plan_short_name
     , x_Business_Plan_Rec.business_plan_name
     , x_Business_Plan_Rec.description
     , x_Business_Plan_Rec.version_number
     , x_Business_Plan_Rec.current_plan_flag
  FROM bis_business_plans bp, bis_business_plans_tl bptl
  WHERE bp.plan_id = p_Business_Plan_Rec.business_plan_id
    AND bp.plan_id = bptl.plan_id
    AND bptl.language = userenv('LANG');

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Business_Plan'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
end Retrieve_Business_Plan;
--
Procedure Create_Business_Plan
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Business_Plan_Rec IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN

  Create_Business_Plan
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Business_Plan_Rec => p_Business_Plan_Rec
  , p_owner             => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Business_Plan'
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Create_Business_Plan;
--
Procedure Create_Business_Plan
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Business_Plan_Rec IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_user_id           NUMBER;
l_login_id          NUMBER;
l_id                NUMBER;
l_business_plan_rec BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_business_plan_Rec := p_business_plan_Rec;

  SetNULL
  ( p_business_plan_Rec => p_business_plan_Rec
  , x_business_plan_Rec => l_business_plan_Rec
  );

  Validate_Business_Plan( p_api_version
                    , p_validation_level
                    , l_Business_Plan_Rec
                    , x_return_status
                    , x_error_Tbl
                    );

  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  IF p_owner = BIS_UTILITIES_PUB.G_SEED_OWNER THEN
    l_user_id := BIS_UTILITIES_PUB.G_SEED_USER_ID;
  ELSE
    l_user_id := fnd_global.USER_ID;
  END IF;

  l_login_id := fnd_global.LOGIN_ID;
  --

  select bis_business_plans_s.NextVal into l_id from dual;

  insert into bis_business_plans(
    PLAN_ID
  , SHORT_NAME
  , VERSION_NO
  , CURRENT_PLAN_FLAG
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  )
  values
  ( l_id
  , l_Business_Plan_Rec.Business_Plan_Short_Name
  , l_Business_Plan_Rec.Version_Number
  , l_Business_Plan_Rec.Current_Plan_Flag
  , SYSDATE
  , l_user_id
  , SYSDATE
  , l_user_id
  , l_login_id
  );

  insert into bis_BUSINESS_PLANS_TL (
    PLAN_ID,
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
  ) select
    P.Plan_id
  , L.LANGUAGE_CODE
  , l_Business_Plan_Rec.Business_Plan_Name
  , l_Business_Plan_Rec.Description
  , SYSDATE
  , l_user_id
  , SYSDATE
  , l_user_id
  , l_login_id
  ,  'Y'
  , userenv('LANG')
   FROM FND_LANGUAGES L
      , BIS_BUSINESS_PLANS P
   WHERE L.INSTALLED_FLAG IN ('I', 'B')
   AND P.SHORT_NAME = l_Business_Plan_Rec.Business_Plan_Short_Name
   AND NOT EXISTS
      (SELECT 'EXISTS'
      FROM BIS_BUSINESS_PLANS_TL TL
         , BIS_BUSINESS_PLANS P
      WHERE TL.PLAN_ID = P.PLAN_ID
      AND P.SHORT_NAME = l_Business_Plan_Rec.Business_Plan_Short_Name
      AND TL.LANGUAGE  = L.LANGUAGE_CODE) ;

  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Business_Plan'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Create_Business_Plan;
--
Procedure Update_Business_Plan
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Business_Plan_Rec IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN

  Update_Business_Plan
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Business_Plan_Rec => p_Business_Plan_Rec
  , p_owner             => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Business_Plan'
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Business_Plan;
--
Procedure Update_Business_Plan
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Business_Plan_Rec IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_user_id          number;
l_login_id         number;
l_count            NUMBER := 0;
l_business_plan_rec BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type;

BEGIN

  -- retrieve record from database and apply changes
  UpdateRecord
  ( p_Business_Plan_Rec => p_Business_Plan_Rec
  , x_Business_Plan_Rec => l_Business_Plan_Rec
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

  Validate_Business_Plan
  ( p_api_version
  , p_validation_level
  , l_Business_Plan_Rec
  , x_return_status
  , x_error_Tbl
  );

  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  IF p_owner = BIS_UTILITIES_PUB.G_SEED_OWNER THEN
    l_user_id := BIS_UTILITIES_PUB.G_SEED_USER_ID;
  ELSE
    l_user_id := fnd_global.USER_ID;
  END IF;

  l_login_id := fnd_global.LOGIN_ID;
  --

  Update bis_business_plans
  set
     SHORT_NAME
       = l_Business_Plan_Rec.Business_Plan_Short_Name
   , VERSION_NO
       = l_Business_Plan_Rec.Version_Number
   , CURRENT_PLAN_FLAG
       = l_Business_Plan_Rec.Current_Plan_Flag
   , LAST_UPDATE_DATE    = SYSDATE
   , LAST_UPDATED_BY     = l_user_id
   , LAST_UPDATE_LOGIN   = l_login_id
  where plan_ID = l_Business_Plan_Rec.Business_Plan_Id;

  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

  Translate_business_plan
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Business_Plan_Rec => l_Business_Plan_Rec
  , p_owner             => p_owner
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Update_Business_Plan'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Business_Plan;
--
Procedure Translate_Business_Plan
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Business_Plan_Rec IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN

  Translate_Business_Plan
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Business_Plan_Rec => p_Business_Plan_Rec
  , p_owner             => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Business_Plan'
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Translate_Business_Plan;
--
Procedure Translate_Business_Plan
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Business_Plan_Rec IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_user_id           NUMBER;
l_login_id          NUMBER;
l_count             NUMBER := 0;
l_business_plan_rec BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type;

BEGIN

   -- retrieve record from database and apply changes
  UpdateRecord
  ( p_Business_Plan_Rec => p_Business_Plan_Rec
  , x_Business_Plan_Rec => l_Business_Plan_Rec
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

  Validate_Business_Plan
  ( p_api_version
  , p_validation_level
  , l_Business_Plan_Rec
  , x_return_status
  , x_error_Tbl
  );

  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  IF p_owner = BIS_UTILITIES_PUB.G_SEED_OWNER THEN
    l_user_id := BIS_UTILITIES_PUB.G_SEED_USER_ID;
  ELSE
    l_user_id := fnd_global.USER_ID;
  END IF;

  l_login_id := fnd_global.LOGIN_ID;
  --

  Update bis_business_plans_TL
  set
    NAME              = l_Business_Plan_Rec.Business_Plan_Name
  , DESCRIPTION       = l_Business_Plan_Rec.description
  , LAST_UPDATE_DATE  = SYSDATE
  , LAST_UPDATED_BY   = l_user_id
  , LAST_UPDATE_LOGIN = l_login_id
  , SOURCE_LANG       = userenv('LANG')
  where PLAN_ID       = l_Business_Plan_Rec.Business_Plan_Id
  and userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Translate_Business_Plan'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Translate_Business_Plan;
--
--
PROCEDURE Validate_Business_Plan
( p_api_version        IN  NUMBER
, p_validation_level   IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Business_Plan_Rec  IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, x_return_status      OUT NOCOPY VARCHAR2
, x_error_Tbl          OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  BEGIN

    BIS_BUSINESS_PLAN_VALIDATE_PVT.Validate_Record
    ( p_api_version        => p_api_version
    , p_validation_level   => p_validation_level
    , p_Business_Plan_Rec  => p_Business_Plan_Rec
    , x_return_status 	   => x_return_status
    , x_error_Tbl     	   => l_error_Tbl
    );

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      BIS_UTILITIES_PVT.concatenateErrorTables( x_error_Tbl
					      , l_error_Tbl
					      , x_error_tbl
					      );
      x_return_status := FND_API.G_RET_STS_ERROR;
  END;

  if (x_error_tbl.count > 0) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Business_Plan'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Business_Plan;
--
-- Value - ID conversion
PROCEDURE Value_ID_Conversion
( p_api_version   IN  NUMBER
, p_Business_Plan_Rec IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, x_Business_Plan_Rec OUT NOCOPY BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
is
begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_Business_Plan_Rec := p_Business_Plan_Rec;

  if (BIS_UTILITIES_PUB.Value_Missing(x_Business_Plan_Rec.Business_Plan_id)
                       = FND_API.G_TRUE) then

    BIS_BUSINESS_PLAN_PVT.Value_ID_Conversion
                       ( p_api_version
		       , x_Business_Plan_Rec.Business_Plan_Short_Name
		       , x_Business_Plan_Rec.Business_Plan_Name
		       , x_Business_Plan_Rec.Business_Plan_ID
		       , x_return_status
		       , x_error_Tbl
                       );
  end if;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Value_ID_Conversion;
--
PROCEDURE Value_ID_Conversion
( p_api_version              IN  NUMBER
, p_Business_Plan_Short_Name IN  VARCHAR2
, p_Business_Plan_Name       IN  VARCHAR2
, x_Business_Plan_ID         OUT NOCOPY NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
, x_error_Tbl                OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
is
begin

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  if (BIS_UTILITIES_PUB.Value_Not_Missing(p_Business_Plan_Short_Name)
                                          = FND_API.G_TRUE) then

    SELECT plan_id into x_Business_Plan_ID
    FROM bis_business_plans
    WHERE short_name = p_Business_Plan_Short_Name;

  elsif (BIS_UTILITIES_PUB.Value_Not_Missing(p_Business_Plan_Name)
                                             = FND_API.G_TRUE) then

    SELECT plan_id into x_Business_Plan_ID
    FROM bis_business_plans_tl
    WHERE name = p_Business_Plan_Name
      AND language = userenv('LANG');
  else

    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_NAME_SHORT_NAME_MISSING'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    );

    RAISE FND_API.G_EXC_ERROR;
  end if;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Value_ID_Conversion;
--
END BIS_BUSINESS_PLAN_PVT;

/
