--------------------------------------------------------
--  DDL for Package Body BIS_MEASURE_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_MEASURE_SECURITY_PVT" AS
/* $Header: BISVMSEB.pls 115.42 2003/12/01 14:05:26 gramasam ship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVMSES.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for creating and managing Performance Measurements
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 28-NOV-98 irchen Creation
REM | Sep-2000  JPRABHUD added a new procedure Get_Measure_Sec_Sorted
REM | 23-JAN-03 sugopal For having different local variables for IN and OUT |
REM |                   parameters (bug#2758428)              	            |
REM | 25-NOV-03 gramasam Included a new procedure for deleting 				|
REM |	responsibilities at target level									|
REM +=======================================================================+
*/
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_MEASURE_SECURITY_PVT';
--
-- creates one Measure_Security, with the dimensions sequenced in the order
-- they are passed in
Procedure Create_Measure_Security
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,p_Measure_Security_Rec IN BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, p_owner            IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER --2465354
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_user_id         number;
l_login_id        number;
l_id              number;
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;

--added this
DUPLICATE_DIMENSION_VALUE EXCEPTION;
PRAGMA EXCEPTION_INIT(DUPLICATE_DIMENSION_VALUE, -1);
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  Validate_Measure_Security
  ( p_api_version          => p_api_version
  , p_Measure_Security_Rec => p_Measure_Security_Rec
  , x_return_status        => x_return_status
  , x_error_Tbl            => x_error_Tbl
  );

  --added this check
  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --2465354
  IF p_owner = BIS_UTILITIES_PUB.G_SEED_OWNER THEN
    l_user_id := BIS_UTILITIES_PUB.G_SEED_USER_ID;
  ELSE
    l_user_id := fnd_global.USER_ID;
  END IF;
--2465354

  l_login_id := fnd_global.LOGIN_ID;
  select bis_indicator_resps_s.NextVal into l_id from dual;

  BEGIN
  insert into bis_indicator_resps
  (
    INDICATOR_RESP_ID
  , RESPONSIBILITY_ID
  , TARGET_LEVEL_ID
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  )
  values
  ( l_id
  , p_Measure_Security_Rec.RESPONSIBILITY_ID
  , p_Measure_Security_Rec.TARGET_LEVEL_ID
  , SYSDATE
  , l_user_id
  , SYSDATE
  , l_user_id
  , l_login_id
  );
  EXCEPTION
    WHEN OTHERS THEN
    null;

  END;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

--commented RAISE
EXCEPTION
     --added this
   WHEN DUPLICATE_DIMENSION_VALUE THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
     ( p_error_msg_name    => 'BIS_TAR_LEVEL_UNIQUENESS_ERROR'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Create_Measure_Security'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Measure_Security'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Create_Measure_Security;
--
--
-- Gets All Performance Measure_Securitys
-- If information about the dimensions are not required, set all_info to
-- FALSE
--
PROCEDURE Retrieve_Measure_Securities
( p_api_version      IN  NUMBER
, p_Target_Level_Rec IN BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Measure_Security_tbl
    OUT NOCOPY BIS_MEASURE_SECURITY_PUB.Measure_Security_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_meas_rec BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type;
l_resp_rec BIS_Responsibility_PVT.Responsibility_rec_Type;
l_resp_rec_p BIS_Responsibility_PVT.Responsibility_rec_Type;

cursor sec_cursor is
select RESPONSIBILITY_ID
from bis_indicator_resps
where TARGET_LEVEL_ID=p_Target_Level_Rec.Target_Level_Id;

l_flag number := 0;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
 -- htp.p('in Retrieve_Measure_Securities ');

  --changed this call to the following call
/*
  BIS_Target_Level_PVT.Validate_Target_Level
  ( p_api_version         => 1.0
  , p_Target_Level_Rec => p_Target_Level_Rec
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );
*/
  --call this instead
  l_meas_rec.target_level_id := p_Target_Level_Rec.Target_Level_Id;
  BIS_MEASURE_SEC_VALIDATE_PVT.Validate_Target_Level_ID
    ( p_api_version      => p_api_version
    , p_MEASURE_Sec_Rec  => l_meas_rec
    , x_return_status 	 => x_return_status
    , x_error_Tbl     	 => x_error_Tbl
    );

 -- htp.p('AFTER BIS_MEASURE_SEC_VALIDATE_PVT.Validate_Target_Level_ID: '
 -- ||x_return_status  );

    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

--
 -- l_meas_rec.target_level_id := p_Target_Level_Rec.Target_Level_Id;


  for cr in sec_cursor loop
   -- l_flag :=1;
    l_meas_rec.RESPONSIBILITY_ID := cr.RESPONSIBILITY_ID;
    l_resp_rec.RESPONSIBILITY_ID := cr.RESPONSIBILITY_ID;
    l_resp_rec_p := l_resp_rec;
    BIS_RESPONSIBILITY_PVT.Retrieve_Responsibility
    ( p_api_version         => 1.0
    , p_Responsibility_Rec  => l_resp_rec_p
    , x_Responsibility_Rec  => l_resp_rec
    , x_return_status       => x_return_status
    , x_error_tbl           => x_error_tbl
    );

    l_meas_rec.Responsibility_Short_name
      :=l_resp_rec.Responsibility_Short_name;
    l_meas_rec.Responsibility_name:=l_resp_rec.Responsibility_name;
    x_Measure_Security_tbl(x_Measure_Security_tbl.COUNT+1) := l_meas_rec;
  END LOOP;

  IF sec_cursor%ISOPEN THEN CLOSE sec_cursor; END IF;
  /*
  if(l_flag =0) then
    RAISE FND_API.G_EXC_ERROR;
  end if;
*/
EXCEPTION
  --WHEN OTHERS THEN
   -- HTP.HEADER(5,'ERROR in measure sec: '||SQLERRM);
   --added this entire section
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF sec_cursor%ISOPEN THEN CLOSE sec_cursor; END IF;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF sec_cursor%ISOPEN THEN CLOSE sec_cursor; END IF;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF sec_cursor%ISOPEN THEN CLOSE sec_cursor; END IF;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF sec_cursor%ISOPEN THEN CLOSE sec_cursor; END IF;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Measure_Securities'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Measure_Securities;




----------------added this new procedure to return the list as a sorted list-------------------
-- Gets All Performance Measure_Securities in a soretd order
-- If information about the dimensions are not required, set all_info to
-- FALSE
--
PROCEDURE Retrieve_Measure_Sec_Sorted
( p_api_version      IN  NUMBER
, p_Target_Level_Rec IN BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Measure_Security_tbl
    OUT NOCOPY BIS_MEASURE_SECURITY_PUB.Measure_Security_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_meas_rec BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type;
l_resp_rec BIS_Responsibility_PVT.Responsibility_rec_Type;

cursor sec_cursor is
select a.RESPONSIBILITY_ID
         , a.RESPONSIBILITY_KEY
         , a.RESPONSIBILITY_NAME
    from fnd_responsibility_vl a, bis_indicator_resps b
    where VERSION='W'
    and start_date <= sysdate
    and nvl(end_date, sysdate) >= sysdate
    and a.RESPONSIBILITY_ID=b.RESPONSIBILITY_ID and b.TARGET_LEVEL_ID=p_Target_Level_Rec.Target_Level_Id
    order by RESPONSIBILITY_NAME;

l_flag number := 0;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --changed this call to the following call
/*
  BIS_Target_Level_PVT.Validate_Target_Level
  ( p_api_version         => 1.0
  , p_Target_Level_Rec => p_Target_Level_Rec
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );
*/
  --call this instead
  l_meas_rec.target_level_id := p_Target_Level_Rec.Target_Level_Id;
  BIS_MEASURE_SEC_VALIDATE_PVT.Validate_Target_Level_ID
    ( p_api_version      => p_api_version
    , p_MEASURE_Sec_Rec  => l_meas_rec
    , x_return_status 	 => x_return_status
    , x_error_Tbl     	 => x_error_Tbl
    );
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

--
 -- l_meas_rec.target_level_id := p_Target_Level_Rec.Target_Level_Id;


  for cr in sec_cursor loop
   -- l_flag :=1;
    l_meas_rec.Responsibility_ID  := cr.RESPONSIBILITY_ID ;
    l_meas_rec.Responsibility_Short_Name := cr.RESPONSIBILITY_KEY;
    l_meas_rec.Responsibility_Name := cr.RESPONSIBILITY_NAME;
    x_Measure_Security_tbl(x_Measure_Security_tbl.COUNT+1) := l_meas_rec;
  END LOOP;

  IF sec_cursor%ISOPEN THEN CLOSE sec_cursor; END IF;
 /*
  if(l_flag =0) then
    RAISE FND_API.G_EXC_ERROR;
  end if;
*/
EXCEPTION
  --WHEN OTHERS THEN
   -- HTP.HEADER(5,'ERROR in measure sec: '||SQLERRM);
   --added this entire section
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF sec_cursor%ISOPEN THEN CLOSE sec_cursor; END IF;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF sec_cursor%ISOPEN THEN CLOSE sec_cursor; END IF;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF sec_cursor%ISOPEN THEN CLOSE sec_cursor; END IF;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF sec_cursor%ISOPEN THEN CLOSE sec_cursor; END IF;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Measure_Securities'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Measure_Sec_Sorted;
-------------------------------

-- Gets Information for One Performance Measure_Security
-- If information about the dimension are not required, set all_info to FALSE.
--
--
PROCEDURE Retrieve_Measure_Security
( p_api_version   IN  NUMBER
, p_Measure_Security_Rec  IN BIS_Measure_SECURITY_PUB.Measure_Security_Rec_Type
, x_Measure_Security_Rec OUT NOCOPY BIS_Measure_SECURITY_PUB.Measure_Security_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Measure_Security'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Measure_Security;
--
-- PLEASE VERIFY COMMENT BELOW
-- Update_Measure_Securitys one Measure_Security if
--   1) no Measure_Security levels or targets exist
--   2) no users have selected to see actuals for the Measure_Security
Procedure Update_Measure_Security
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Security_Rec IN BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  Validate_Measure_Security
  ( p_api_version          => p_api_version
  , p_Measure_Security_Rec => p_Measure_Security_Rec
  , x_return_status        => x_return_status
  , x_error_Tbl            => x_error_Tbl
  );

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Update_Measure_Security'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Measure_Security;
--
--
-- PLEASE VERIFY COMMENT BELOW
-- Deletes ALL responsibilities associated with a target level
Procedure Delete_Measure_Security
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
is
begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;
--  Validate_Measure_Security
--  ( p_api_version          => p_api_version
--  , p_Measure_Security_Rec => p_Measure_Security_Rec
--  , x_return_status        => x_return_status
--  , x_error_Tbl            => x_error_Tbl-
--  );

  delete from bis_indicator_resps
  where target_level_id = p_Target_Level_Rec.Target_Level_Id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;


end Delete_Measure_Security;

Procedure Delete_Measure_Security
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_Security_Rec IN BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  Validate_Measure_Security
  ( p_api_version          => p_api_version
  , p_Measure_Security_Rec => p_Measure_Security_Rec
  , x_return_status        => x_return_status
  , x_error_Tbl            => x_error_Tbl
  );
   --added this check
  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  delete from bis_indicator_resps
  where target_level_id = p_Measure_Security_Rec.Target_Level_Id
    and RESPONSIBILITY_ID = p_Measure_Security_Rec.Responsibility_id;

  if (p_commit = FND_API.G_TRUE) then
    commit;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Delete_Measure_Security'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Measure_Security;
--
-- Validates Measure_Security
PROCEDURE Validate_Measure_Security
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,p_Measure_Security_Rec IN BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
l_error     VARCHAR2(10) := FND_API.G_FALSE;
l_error_Tbl_p BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    BIS_MEASURE_SEC_VALIDATE_PVT.Validate_Target_Level_ID
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Sec_Rec  => p_MEASURE_Security_Rec
    , x_return_status 	 => x_return_status
    , x_error_Tbl     	 => l_error_Tbl
    );
 -- EXCEPTION
   -- when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                                              , l_error_Tbl
                                              , x_error_tbl
                                              );
      x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
  END;

  BEGIN
    BIS_MEASURE_SEC_VALIDATE_PVT.Validate_Responsibility_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Sec_Rec  => p_MEASURE_Security_Rec
    , x_return_status 	 => x_return_status
    , x_error_Tbl     	 => l_error_Tbl
    );
--  EXCEPTION
   -- when FND_API.G_EXC_ERROR then
   IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                                              , l_error_Tbl
                                              , x_error_tbl
                                              );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;

  BEGIN
  BIS_MEASURE_SEC_VALIDATE_PVT.Validate_Record
  ( p_api_version        => p_api_version
  , p_validation_level   => p_validation_level
  , p_MEASURE_Sec_Rec    => p_MEASURE_Security_Rec
  , x_return_status 	 => x_return_status
  , x_error_Tbl     	 => l_error_Tbl
  );

  --changed this
/*
  if (x_error_tbl.count > 0) then
    BIS_UTILITIES_PVT.concatenateErrorTables( x_error_Tbl
                                            , l_error_Tbl
                                            , x_error_tbl
                                            );
    RAISE FND_API.G_EXC_ERROR;
  end if;
*/
--added this
 IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
   l_error_Tbl_p := x_error_Tbl;
   BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                                              , l_error_Tbl
                                              , x_error_tbl
                                              );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
 END;

 --added this
 if (l_error = FND_API.G_TRUE) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Measure_Security'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
    --  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Measure_Security;
--
-- Value - ID conversion
PROCEDURE Value_ID_Conversion
( p_api_version     IN  NUMBER
, p_Measure_Security_Rec IN BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, x_Measure_Security_Rec OUT NOCOPY BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_Measure_Security_Rec := p_Measure_Security_Rec;

  if (BIS_UTILITIES_PUB.Value_Missing(p_Measure_Security_Rec.Target_Level_id)=
                                                       FND_API.G_TRUE
     OR BIS_UTILITIES_PUB.Value_NULL(p_Measure_Security_Rec.Target_Level_id)=
                                                       FND_API.G_TRUE) THEN
    BIS_Target_Level_PVT.Value_ID_Conversion
    ( p_api_version                => 1.0
    , p_Target_Level_Short_Name =>
  				p_Measure_Security_Rec.Target_Level_Short_Name
    , p_Target_Level_Name       => p_Measure_Security_Rec.Target_Level_Name
    , x_Target_Level_ID         => x_Measure_Security_Rec.Target_Level_ID
    , x_return_status              => x_return_status
    , x_error_Tbl                  => x_error_Tbl
    );
  END IF;
--
-- This will be the value id for responsibility
--  BIS_Target_Level_PVT.Value_ID_Conversion
--  ( p_api_version                => 1.0
-- - , p_Target_Level_Short_Name =>
--                              p_Measure_Security_Rec.Target_Level_Short_Name
--  , p_Target_Level_Name       => p_Measure_Security_Rec.Target_Level_Name
--  , x_Target_Level_ID         => x_Measure_Security_Rec.Target_Level_ID
--  , x_return_status              => x_return_status
--  , x_error_Tbl                  => x_error_Tbl
--  );

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_ID_Conversion;
--
Procedure Retrieve_Tar_Level_User_Resps
( p_api_version           IN NUMBER
, p_user_id               IN NUMBER
, p_Target_Level_Rec      IN BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Measure_security_Tbl OUT NOCOPY BIS_MEASURE_SECURITY_PUB.Measure_Security_Tbl_Type
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
is

CURSOR ind_res_id IS
  select il.target_level_id
       , il.target_level_short_name
       , il.target_level_name
       , ir.Responsibility_ID
       , fr.RESPONSIBILITY_NAME
       , fr.RESPONSIBILITY_KEY
  from bis_indicator_resps  ir
     , fnd_user_resp_groups ur
     , bisbv_target_levels  il
     , fnd_responsibility_vl fr
  where ur.user_id           = p_user_id
  and   ir.responsibility_id = ur.responsibility_id
  and   ir.responsibility_id = fr.responsibility_id
  and   il.target_level_id   = ir.target_level_id
  and   il.target_level_id   = p_target_level_rec.target_level_id;

CURSOR ind_res_short_name IS
  select il.target_level_id
       , il.target_level_short_name
       , il.target_level_name
       , ir.Responsibility_ID
       , fr.RESPONSIBILITY_NAME
       , fr.RESPONSIBILITY_KEY
  from bis_indicator_resps  ir
     , fnd_user_resp_groups ur
     , bisbv_target_levels  il
     , fnd_responsibility_vl fr
  where ur.user_id           = p_user_id
  and   ir.responsibility_id = ur.responsibility_id
  and   ir.responsibility_id = fr.responsibility_id
  and   il.target_level_id   = ir.target_level_id
  and   il.target_level_short_name=p_target_level_rec.target_level_short_name;

CURSOR ind_res_name IS
  select il.target_level_id
       , il.target_level_short_name
       , il.target_level_name
       , ir.Responsibility_ID
       , fr.RESPONSIBILITY_NAME
       , fr.RESPONSIBILITY_KEY
  from bis_indicator_resps  ir
     , fnd_user_resp_groups ur
     , bisbv_target_levels  il
     , fnd_responsibility_vl fr
  where ur.user_id           = p_user_id
  and   ir.responsibility_id = ur.responsibility_id
  and   ir.responsibility_id = fr.responsibility_id
  and   il.target_level_id   = ir.target_level_id
  and   il.target_level_name = p_target_level_rec.target_level_name;

l_rec BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type;
l_flag number := 0;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_Rec.Target_Level_id)=
                                                       FND_API.G_TRUE)
  THEN
    for cr in ind_res_id loop
      l_flag := 1;
      l_rec.Target_Level_ID           := cr.target_level_id    ;
      l_rec.Target_Level_Short_Name   := cr.target_level_short_name;
      l_rec.Target_Level_Name         := cr.target_level_name;
      l_rec.Responsibility_ID         := cr.Responsibility_ID  ;
      l_rec.Responsibility_Short_Name := cr.RESPONSIBILITY_KEY;
      l_rec.Responsibility_Name       := cr.RESPONSIBILITY_NAME ;
      x_Measure_security_Tbl(x_Measure_security_Tbl.count+1) := l_rec;
    end loop;

  ELSIF (BIS_UTILITIES_PUB.Value_Not_Missing
                   (p_target_level_Rec.Target_Level_short_name)=FND_API.G_TRUE)
    THEN
      for cr in ind_res_short_name loop
        l_flag := 1;
        l_rec.Target_Level_ID           := cr.target_level_id    ;
        l_rec.Target_Level_Short_Name   := cr.target_level_short_name;
        l_rec.Target_Level_Name         := cr.target_level_name;
        l_rec.Responsibility_ID         := cr.Responsibility_ID  ;
        l_rec.Responsibility_Short_Name := cr.RESPONSIBILITY_KEY;
        l_rec.Responsibility_Name       := cr.RESPONSIBILITY_NAME ;
        x_Measure_security_Tbl(x_Measure_security_Tbl.count+1) := l_rec;
      end loop;

  ELSIF (BIS_UTILITIES_PUB.Value_Not_Missing
                   (p_target_level_Rec.Target_Level_name)=FND_API.G_TRUE)
    THEN
      for cr in ind_res_name loop
        l_flag := 1;
        l_rec.Target_Level_ID           := cr.target_level_id    ;
        l_rec.Target_Level_Short_Name   := cr.target_level_short_name;
        l_rec.Target_Level_Name         := cr.target_level_name;
        l_rec.Responsibility_ID         := cr.Responsibility_ID  ;
        l_rec.Responsibility_Short_Name := cr.RESPONSIBILITY_KEY;
        l_rec.Responsibility_Name       := cr.RESPONSIBILITY_NAME ;
        x_Measure_security_Tbl(x_Measure_security_Tbl.count+1) := l_rec;
      end loop;
  ELSE
    --added message
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_MSR_SECURITY_VALUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target_Level_User_Resps'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF ind_res_name%ISOPEN THEN CLOSE ind_res_name; END IF;
  --added this
  if(l_flag =0) then
     --added message
     l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_MSR_SECURITY_VALUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target_Level_User_Resps'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
    RAISE FND_API.G_EXC_ERROR;
  end if;



--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF ind_res_name%ISOPEN THEN CLOSE ind_res_name; END IF;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF ind_res_name%ISOPEN THEN CLOSE ind_res_name; END IF;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF ind_res_name%ISOPEN THEN CLOSE ind_res_name; END IF;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF ind_res_name%ISOPEN THEN CLOSE ind_res_name; END IF;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Tar_Level_User_Resps'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Retrieve_Tar_Level_User_Resps;
--

--new API to validate Measure Security for bug 1716213
PROCEDURE Validate_Measure_Security
( p_api_version      IN  NUMBER
, p_user_id         IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Security_Rec IN BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
l_error     VARCHAR2(10) := FND_API.G_FALSE;
l_dlc_sec   VARCHAR2(1);
CURSOR c_resp IS
  SELECT responsibility_id
  FROM fnd_user_resp_groups
  WHERE user_id=p_user_id;
CURSOR c_indresp(p_target_level_id IN NUMBER) IS
  SELECT responsibility_id
  FROM bis_indicator_Resps
  WHERE target_level_id=p_target_level_id;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BEGIN

    BIS_MEASURE_SEC_VALIDATE_PVT.Validate_Target_Level_ID
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_MEASURE_Sec_Rec  => p_MEASURE_Security_Rec
    , x_return_status 	 => x_return_status
    , x_error_Tbl     	 => l_error_Tbl
    );

    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;

      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_MSR_SECURITY_VALUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Measure_Security'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
     END IF;
  END;

  BEGIN

     l_dlc_sec := 'N';
     FOR c_rec IN c_resp LOOP
         FOR c_indrec IN c_indresp(p_Measure_Security_Rec.target_level_id) LOOP
            IF (c_indrec.responsibility_id = c_rec.responsibility_id)
            THEN
                l_dlc_sec := 'Y';
                EXIT;
            END IF;
        END LOOP;
     END LOOP;
     IF (l_dlc_sec = 'N') THEN
	  l_error_tbl := x_error_tbl;
          BIS_UTILITIES_PVT.Add_Error_Message
          ( p_error_msg_name    => 'BIS_INVALID_MSR_SECUIRTY_VALUE'
          , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
          , p_error_proc_name   => G_PKG_NAME||'.Validate_Measure_Security'
          , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
          , p_error_table       => l_error_tbl
          , x_error_table       => x_error_tbl
         );
         x_return_status := FND_API.G_RET_STS_ERROR;
         l_error := FND_API.G_TRUE;
     END IF;

  END;



 --added this
 if (l_error = FND_API.G_TRUE) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Measure_Security'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
    --  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Measure_Security;

-- new API to delete the responsibilities attached to the target levels
-- pertaining to the measure specified by the measure short name
PROCEDURE Delete_TargetLevel_Resp
( p_commit 				IN  VARCHAR2	:= FND_API.G_FALSE
, p_measure_short_name	IN  VARCHAR2
, x_return_status   	OUT NOCOPY VARCHAR2
, x_error_Tbl			OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_indicator_id NUMBER;
  l_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  CURSOR target_level_cursor(cp_indicator_id IN NUMBER) IS
    SELECT target_level_id FROM bis_target_levels
      WHERE indicator_id = cp_indicator_id;

BEGIN
  SAVEPOINT delete_resps;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SELECT indicator_id INTO l_indicator_id FROM bis_indicators WHERE short_name = p_measure_short_name;
  FOR target_cursor IN target_level_cursor(l_indicator_id) LOOP
    DELETE FROM bis_indicator_resps
      WHERE target_level_id = target_cursor.target_level_id;
  END LOOP;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO delete_resps;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_MEASURE_SHORT_NAME'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Delete_TargetLevel_Resp'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO delete_resps;
  	x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_resps;
  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    ROLLBACK TO delete_resps;
  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Delete_TargetLevel_Resp'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Delete_TargetLevel_Resp;

END BIS_MEASURE_SECURITY_PVT;

/
