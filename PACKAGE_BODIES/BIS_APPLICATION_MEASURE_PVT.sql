--------------------------------------------------------
--  DDL for Package Body BIS_APPLICATION_MEASURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_APPLICATION_MEASURE_PVT" AS
/* $Header: BISVAPMB.pls 120.0 2005/06/01 14:09:16 appldev noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVAPMB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for creating and managing Application Measures
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 28-NOV-98 irchen Creation
REM | 20-JAN-2003 rchandra  added statements for OSERROR for GSCC
REM | 23-JAN-03   mahrao  For having different local variables for IN and OUT
REM |                     parameters.
REM | 26-JUN-2003 rchandra  bug 3004651, populated dataset_id in API        |
REM |                       Retrieve_Application_Measures                   |
REM | 08-JUL-2003 mdamle  Fix to support bad data 			    |
REM | 08-JUL-2003 rchandra For bug 3008385,Only one record can be created in|
REM |                       BIS_APPICATION_MEASURES table for an indicator  | 			    |
REM | 27-JUL-2004 sawu    Modified create/update application measure to use |
REM |                     BIS_UTILITIES_PUB.Get_Owner_Id to lookup user_id  |
REM | 29-SEP-2004 ankgoel Added WHO columns in Rec for Bug#3891748          |
REM | 21-MAR-2005 ankagarw   bug#4235732 - changing count(*) to count(1)    |
REM | 01-JUN-2005 akoduri    Modified for Bug #4397786                      |
REM +=======================================================================+
*/
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_APPLICATION_MEASURE_PVT';
--
--
PROCEDURE Create_Application_Measure
( p_api_version             IN  NUMBER
, p_commit                  IN  VARCHAR2   := FND_API.G_FALSE
, p_Application_Measure_Rec IN
                      BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, x_return_status           OUT NOCOPY VARCHAR2
, x_error_Tbl               OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Create_Application_Measure
  ( p_api_version             => p_api_version
  , p_commit                  => p_commit
  , p_Application_Measure_Rec => p_Application_Measure_Rec
  , p_owner                   => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , x_return_status           => x_return_status
  , x_error_Tbl               => x_error_Tbl
  );

--commented RAISE
EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --added last two params
  	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Create_Application_Measure'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Create_Application_Measure;
--
--
PROCEDURE Create_Application_Measure
( p_api_version             IN  NUMBER
, p_commit                  IN  VARCHAR2   := FND_API.G_FALSE
, p_Application_Measure_Rec IN
                      BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, p_owner                   IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_error_Tbl               OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_count     number;
l_user_id         number;
l_login_id        number;
l_rec             BIS_Application_Measure_PVT.Application_Measure_Rec_Type;
l_rec_p           BIS_Application_Measure_PVT.Application_Measure_Rec_Type;
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;

  CURSOR c_app_meas(cp_ind_id IN  NUMBER) IS
    SELECT count(1) FROM BIS_APPLICATION_MEASURES
    WHERE  indicator_id = cp_ind_id;
  l_count         NUMBER := 0;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_rec := p_Application_Measure_Rec;

  l_rec_p := l_rec;
  BIS_Application_Measure_PVT.Value_ID_Conversion
                             ( p_api_version
                             , l_rec_p
                             , l_rec
                             , x_return_status
                             , x_error_Tbl
                             );


  BIS_Application_Measure_PVT.Validate_Application_Measure
                             ( p_api_version
                             , l_rec
                             , x_return_status
                             , x_error_Tbl
                             );

  IF (c_app_meas%ISOPEN) THEN
    CLOSE c_app_meas;
  END IF;

  OPEN c_app_meas(cp_ind_id => l_rec.Measure_ID);
  FETCH c_app_meas INTO l_count;
  CLOSE c_app_meas;

  IF (l_count > 0) THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  IF ( l_Rec.APPLICATION_ID <> -1 ) THEN
    l_Rec.OWNING_APPLICATION := FND_API.G_TRUE;
  ELSE
    l_Rec.OWNING_APPLICATION := FND_API.G_FALSE;
  END IF;

  -- ankgoel: bug#3891748 - Created_By will take precedence over Owner.
  -- Last_Updated_By can be different from Created_By while creating measures
  -- during sync-up
  IF (l_Rec.Created_By IS NULL) THEN
    l_Rec.Created_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  END IF;
  IF (l_Rec.Last_Updated_By IS NULL) THEN
    l_Rec.Last_Updated_By := l_Rec.Created_By;
  END IF;
  IF (l_Rec.Last_Update_Login IS NULL) THEN
    l_Rec.Last_Update_Login := fnd_global.LOGIN_ID;
  END IF;

--  dbms_output.put_line('Application Measures PVT: BEFORE INSERT');
--  dbms_output.put_line( l_Rec.Measure_ID);
--  dbms_output.put_line( l_Rec.APPLICATION_ID);
--  dbms_output.put_line( l_Rec.OWNING_APPLICATION);
--  dbms_output.put_line( l_user_id);
--  dbms_output.put_line(l_login_id );

  insert into bis_application_measures
  (
    INDICATOR_ID
  , APPLICATION_ID
  , OWNING_APPLICATION
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  )
  values
  ( l_Rec.Measure_ID
  , l_Rec.APPLICATION_ID
  , l_Rec.OWNING_APPLICATION
  , SYSDATE
  , l_Rec.Created_By
  , SYSDATE
  , l_Rec.Last_Updated_By
  , l_Rec.Last_Update_Login
  );

  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
      IF (c_app_meas%ISOPEN) THEN
        CLOSE c_app_meas;
      END IF;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
      IF (c_app_meas%ISOPEN) THEN
        CLOSE c_app_meas;
      END IF;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      IF (c_app_meas%ISOPEN) THEN
        CLOSE c_app_meas;
      END IF;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    	l_error_tbl := x_error_Tbl;
      IF (c_app_meas%ISOPEN) THEN
        CLOSE c_app_meas;
      END IF;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Application_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Create_Application_Measure;
--
--
PROCEDURE Retrieve_Application_Measures
( p_api_version             IN  NUMBER
, p_Measure_Rec            IN BIS_Measure_PUB.Measure_Rec_Type
, p_all_info                IN VARCHAR2
, x_Application_Measure_tbl OUT NOCOPY
                      BIS_Application_Measure_PVT.Application_Measure_Tbl_Type
, x_return_status           OUT NOCOPY VARCHAR2
, x_error_Tbl               OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

CURSOR all_info_cursor is
select Measure_id
  , MEASURE_SHORT_NAME
  , MEASURE_NAME
  , Application_id
  , Application_Short_name
  , Application_name
  , owning_application
  , Dataset_Id
from bisfv_application_measures
where measure_id = p_Measure_Rec.Measure_id;

CURSOR basic_info_cursor is
select Measure_id
  , MEASURE_SHORT_NAME
  , MEASURE_NAME
  , Application_id
  , owning_application
  , Dataset_Id
from bisbv_application_measures
where measure_id = p_Measure_Rec.Measure_id;

l_rec BIS_Application_Measure_PVT.Application_Measure_Rec_Type;
l_flag number := 0;
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if (p_all_info = FND_API.G_FALSE) then
    for cr in basic_info_cursor LOOP
      l_flag := 1;
      l_rec.Measure_id := cr.Measure_id;
      l_rec.MEASURE_SHORT_NAME := cr.MEASURE_SHORT_NAME;
      l_rec.MEASURE_NAME := cr.MEASURE_NAME;
      l_rec.owning_application := cr.owning_application;
      l_rec.Dataset_ID := cr.Dataset_Id;

      x_Application_Measure_tbl(x_Application_Measure_tbl.COUNT+1) := l_rec;
    end LOOP;
  else
    for cr in all_info_cursor LOOP
      l_flag := 1;
      l_rec.Measure_id := cr.Measure_id;
      l_rec.MEASURE_SHORT_NAME := cr.MEASURE_SHORT_NAME;
      l_rec.MEASURE_NAME := cr.MEASURE_NAME;
      l_rec.Application_ID := cr.Application_id;
      l_rec.Application_SHORT_NAME := cr.Application_SHORT_NAME;
      l_rec.Application_NAME := cr.Application_NAME;
      l_rec.owning_application := cr.owning_application;
      l_rec.Dataset_ID := cr.Dataset_Id;

      x_Application_Measure_tbl(x_Application_Measure_tbl.COUNT+1) := l_rec;
    end LOOP;
  end if;

  IF basic_info_cursor%ISOPEN THEN CLOSE basic_info_cursor; END IF;
  IF all_info_cursor%ISOPEN THEN CLOSE all_info_cursor; END IF;


  --added this check
  if (l_flag = 0) then
     l_error_tbl := x_error_Tbl;
     BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_MEASURE_ID'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Application_Measures'
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
     IF basic_info_cursor%ISOPEN THEN CLOSE basic_info_cursor; END IF;
     IF all_info_cursor%ISOPEN THEN CLOSE all_info_cursor; END IF;
     --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF basic_info_cursor%ISOPEN THEN CLOSE basic_info_cursor; END IF;
      IF all_info_cursor%ISOPEN THEN CLOSE all_info_cursor; END IF;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF basic_info_cursor%ISOPEN THEN CLOSE basic_info_cursor; END IF;
      IF all_info_cursor%ISOPEN THEN CLOSE all_info_cursor; END IF;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF basic_info_cursor%ISOPEN THEN CLOSE basic_info_cursor; END IF;
      IF all_info_cursor%ISOPEN THEN CLOSE all_info_cursor; END IF;
    	l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Application_Measures'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Retrieve_Application_Measures;
--
--
PROCEDURE Update_Application_Measure
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Application_Measure_Rec IN
                       BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Update_Application_Measure
  ( p_api_version             => p_api_version
  , p_commit                  => p_commit
  , p_Application_Measure_Rec => p_Application_Measure_Rec
  , p_owner                   => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , x_return_status           => x_return_status
  , x_error_Tbl               => x_error_Tbl
  );

--commented RAISE
EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --added last two params
  	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Update_Application_Measure'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Application_Measure;
--
--
PROCEDURE Update_Application_Measure
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Application_Measure_Rec IN
                       BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, p_owner            IN  VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_user_id         number;
l_login_id        number;
l_rec             BIS_Application_Measure_PVT.Application_Measure_Rec_Type;
l_rec_p           BIS_Application_Measure_PVT.Application_Measure_Rec_Type;
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
l_count		  number;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_rec := p_Application_Measure_Rec;

  if ( BIS_UTILITIES_PUB.Value_Missing(l_Rec.Owning_Application)=FND_API.G_TRUE
     OR BIS_UTILITIES_PUB.Value_NULL(l_Rec.Owning_Application)=FND_API.G_TRUE
     ) then
    --added last two params
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_OWNING_APP_VALUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Update_Application_Measure'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;
  l_rec_p := l_rec;
  BIS_Application_Measure_PVT.Value_ID_Conversion
                             ( p_api_version
                             , l_rec_p
                             , l_rec
                             , x_return_status
                             , x_error_Tbl
                             );

  BIS_Application_Measure_PVT.Validate_Application_Measure
                             ( p_api_version
                             , p_Application_Measure_Rec
                             , x_return_status
                             , x_error_Tbl
                             );


  l_user_id := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);

  l_login_id := fnd_global.LOGIN_ID;

  -- mdamle 07/08/2003 - There have been occurrences of bad data when
  -- an application_id record is missing for an indicator.
  select count(1) into l_count
  from bis_application_measures
  where INDICATOR_ID     = l_rec.Measure_Id;

  if (l_count = 0) then
	Create_Application_Measure
    	( p_api_version             => p_api_version
      	, p_commit                  => p_commit
      	, p_Application_Measure_Rec => l_rec
      	, p_owner                   => p_owner
      	, x_return_status           => x_return_status
      	, x_error_tbl               => x_error_tbl
      	);
  else

    IF ( l_Rec.APPLICATION_ID <> -1 ) THEN
      l_Rec.OWNING_APPLICATION := FND_API.G_TRUE;
    ELSE
      l_Rec.OWNING_APPLICATION := FND_API.G_FALSE;
    END IF;

  Update bis_application_measures
  set
    OWNING_APPLICATION   = l_Rec.OWNING_APPLICATION
  , LAST_UPDATE_DATE     = SYSDATE
  , LAST_UPDATED_BY      = l_user_id
  , LAST_UPDATE_LOGIN    = l_login_id
  , APPLICATION_ID       = l_Rec.Application_Id  --2465354
  where INDICATOR_ID     = l_rec.Measure_Id ;
  --AND Application_ID     = l_Rec.Application_Id; --2465354
  end if;
  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

--commented RAISE
EXCEPTION
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
    	l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Update_Application_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Update_Application_Measure;
--
--
PROCEDURE Delete_Application_Measure
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2   := FND_API.G_FALSE
, p_Application_Measure_Rec IN
                       BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_rec             BIS_Application_Measure_PVT.Application_Measure_Rec_Type;
l_rec_p           BIS_Application_Measure_PVT.Application_Measure_Rec_Type;
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_rec := p_Application_Measure_Rec;
  l_rec_p := l_rec;
  BIS_Application_Measure_PVT.Value_ID_Conversion
                             ( p_api_version
                             , l_rec_p
                             , l_rec
                             , x_return_status
                             , x_error_Tbl
                             );

  BIS_Application_Measure_PVT.Validate_Application_Measure
                             ( p_api_version
                             , l_rec
                             , x_return_status
                             , x_error_Tbl
                             );

  delete from bis_application_measures
  where APPLICATION_ID = l_Rec.Application_id
    AND indicator_id = l_Rec.Measure_id;


  if SQL%NOTFOUND then
     RAISE NO_DATA_FOUND;
  end if;

  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
       --added more params
    	l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name  => 'BIS_INVALID_APPORMEASURE_ID'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name => G_PKG_NAME||'.Delete_Application_Measure'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    	l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Delete_Application_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Delete_Application_Measure;
--
-- Validates measure
PROCEDURE Validate_Application_Measure
( p_api_version     IN  NUMBER
,p_Application_Measure_Rec IN
                       BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_measure_rec BIS_MEASURE_PUB.Measure_Rec_Type;
l_app_rec     BIS_APPLICATION_PVT.Application_Rec_Type;
l_error_Tbl   BIS_UTILITIES_PUB.Error_Tbl_Type;
l_error_Tbl_p BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- if application id is -1 then we need to skip validating the application
  if (p_Application_Measure_Rec.Application_id = -1) then
    return;
  end if;

  BEGIN
    l_measure_rec.measure_id := p_Application_Measure_Rec.Measure_id;
    l_measure_rec.measure_short_name :=
                                 p_Application_Measure_Rec.Measure_Short_name;
    l_measure_rec.measure_name := p_Application_Measure_Rec.Measure_name;

    BIS_MEASURE_PUB.Validate_Measure
    ( p_api_version   => 1.0
    , p_Measure_Rec   => l_measure_rec
    , x_return_status => x_return_status
    , x_error_Tbl     => l_error_tbl
    );

  EXCEPTION
    when FND_API.G_EXC_ERROR then
   	 l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
					      , l_error_Tbl
					      , x_error_tbl
					      );
      x_return_status := FND_API.G_RET_STS_ERROR;
  END;

  BEGIN
    l_app_rec.application_id := p_Application_Measure_Rec.Application_id;
    l_app_rec.Application_short_name :=
                              p_Application_Measure_Rec.Application_Short_name;
    l_app_rec.Application_name := p_Application_Measure_Rec.Application_name;

    BIS_APPLICATION_PVT.Validate_Application
    ( p_api_version       => 1.0
    , p_application_Rec   => l_app_rec
    , x_return_status     => x_return_status
    , x_error_Tbl         => l_error_tbl
    );
  EXCEPTION
    when FND_API.G_EXC_ERROR then
   	 l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
					      , l_error_Tbl
					      , x_error_tbl
					      );
      x_return_status := FND_API.G_RET_STS_ERROR;
  END;

--commented RAISE
EXCEPTION
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
    	l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Application_Measure'
      , p_error_table       => l_error_tbl_p
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Validate_Application_Measure;
--
--
-- Value - ID conversion
PROCEDURE Value_ID_Conversion
( p_api_version     IN  NUMBER
, p_Application_Measure_Rec IN
                       BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, x_Application_Measure_Rec IN OUT NOCOPY
                       BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
-- l_error_count    number;
   l_measure_rec BIS_MEASURE_PUB.Measure_Rec_Type;
   l_app_rec     BIS_APPLICATION_PVT.Application_Rec_Type;
   l_error_Tbl   BIS_UTILITIES_PUB.Error_Tbl_Type;
   l_measure_rec_p  BIS_MEASURE_PUB.Measure_Rec_Type;
   l_app_rec_p      BIS_APPLICATION_PVT.Application_Rec_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Not done because redundant
  l_measure_rec.measure_id := p_Application_Measure_Rec.Measure_id;
  l_measure_rec.measure_short_name
    := p_Application_Measure_Rec.Measure_Short_name;
  l_measure_rec.measure_name := p_Application_Measure_Rec.Measure_name;

    if (BIS_UTILITIES_PUB.Value_Missing
         (l_Measure_Rec.Measure_id) = FND_API.G_TRUE
    OR BIS_UTILITIES_PUB.Value_NULL(l_Measure_Rec.Measure_id)
	= FND_API.G_TRUE)
      then
      BEGIN
        l_measure_rec_p := l_measure_rec;
	 BIS_MEASURE_PVT.Value_Id_conversion
	   ( p_api_version   => 1.0
	     , p_Measure_Rec   => l_measure_rec_p
	     , x_Measure_Rec   => l_measure_rec
	     , x_return_status => x_return_status
	     , x_error_Tbl     => l_error_tbl
	     );
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR then
        NULL;
    END;
  end if;

  l_app_rec.application_id := p_Application_Measure_Rec.Application_id;
  l_app_rec.Application_short_name :=
                            p_Application_Measure_Rec.Application_Short_name;
  l_app_rec.Application_name := p_Application_Measure_Rec.Application_name;

  if (  l_app_rec.application_id is NULL
     OR BIS_UTILITIES_PUB.Value_Missing(l_app_rec.application_id) = FND_API.G_TRUE) then
    l_app_rec_p := l_app_rec;
		BIS_APPLICATION_PVT.Value_Id_conversion
    ( p_api_version       => 1.0
    , p_application_Rec   => l_app_rec_p
    , x_application_Rec   => l_app_rec
    , x_return_status     => x_return_status
    , x_error_Tbl         => l_error_tbl
    );
  end if;

  x_application_measure_rec.Owning_Application
    := p_Application_Measure_Rec.Owning_Application;

  x_application_measure_rec.Measure_id := l_measure_rec.Measure_id;
  x_application_measure_rec.measure_short_name
    := l_measure_rec.measure_short_name;
  x_application_measure_rec.measure_name := l_measure_rec.measure_name;

  x_application_measure_rec.Application_id := l_app_rec.Application_id;
  x_application_measure_rec.Application_Short_name
    := l_app_rec.Application_Short_name;
  x_application_measure_rec.Application_name := l_app_rec.Application_name;

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
    	l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Value_ID_Conversion;
--
PROCEDURE Retrieve_Last_Update_Date
( p_api_version      IN  NUMBER
, p_Application_Measure_Rec IN
                       BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, x_last_update_date OUT NOCOPY DATE
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF( BIS_UTILITIES_PUB.Value_Missing(p_Application_Measure_Rec.Measure_id)
      = FND_API.G_FALSE
  AND BIS_UTILITIES_PUB.Value_Missing(p_Application_Measure_Rec.Application_id)
      = FND_API.G_FALSE
    ) THEN
    SELECT NVL(LAST_UPDATE_DATE, CREATION_DATE)
    INTO x_last_update_date
    FROM bis_application_measures
    WHERE INDICATOR_ID = p_Application_Measure_Rec.Measure_id
      AND Application_ID = p_Application_Measure_Rec.Application_id;

  END IF;
  --
--commented RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
      --added this message
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_APPORMEASURE_ID'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Last_Update_Date'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Retrieve_Last_Update_Date;
--
PROCEDURE Lock_Record
( p_api_version   IN  NUMBER
, p_Application_Measure_Rec IN
                       BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, p_timestamp     IN  VARCHAR  := NULL
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_form_date        DATE;
l_last_update_date DATE;
l_Rec              BIS_Application_Measure_PVT.Application_Measure_Rec_Type;
l_error_tbl        BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  l_rec := p_Application_Measure_Rec;
  Retrieve_Last_Update_Date
                 ( p_api_version             => 1.0
                 , p_Application_Measure_Rec => p_Application_Measure_Rec
                 , x_last_update_date 	     => l_last_update_date
                 , x_return_status    	     => x_return_status
                 , x_error_Tbl        	     => x_error_Tbl
                 );

  IF(p_timestamp IS NOT NULL) THEN
    l_form_date := TO_DATE(p_timestamp, BIS_UTILITIES_PVT.G_DATE_FORMAT);
    IF(l_form_date = l_last_update_date) THEN
      x_return_status := FND_API.G_TRUE;
    ELSE
      x_return_status := FND_API.G_FALSE;
    END IF;
  ELSE
    x_return_status := FND_API.G_FALSE;
  END IF;
  --

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Lock_Record;

PROCEDURE Update_Application_Measure
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_Short_Name IN   BIS_INDICATORS.SHORT_NAME%TYPE
, p_Application_Id   IN  BIS_APPLICATION_MEASURES.APPLICATION_ID%TYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
l_rec BIS_APPLICATION_MEASURE_PVT.Application_Measure_Rec_type;
l_error_tbl        BIS_UTILITIES_PUB.Error_Tbl_Type;
l_measure_id  BIS_INDICATORS.INDICATOR_ID%TYPE;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SELECT indicator_id
  INTO l_measure_id
  FROM BIS_INDICATORS
  WHERE SHORT_NAME = p_Measure_Short_Name;

  l_rec.Measure_id         := l_measure_id;
  l_rec.Application_id     := p_Application_Id;
  l_rec.owning_application := FND_API.G_FALSE;

  BIS_APPLICATION_MEASURE_PVT.Update_Application_Measure( p_api_version
                                                        , p_commit
                                                        , l_rec
                                                        , x_return_status
                                                        , l_error_tbl);
  IF ((x_return_status  IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
     IF (l_error_tbl.COUNT > 0) THEN
        x_msg_data  :=  l_error_tbl(l_error_tbl.COUNT).Error_Description;
        IF(INSTR(x_msg_data, ' ')  =  0 ) THEN
          FND_MESSAGE.SET_NAME('BIS',x_msg_data);
          FND_MSG_PUB.ADD;
          x_msg_data  :=  NULL;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF(p_Commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded =>  FND_API.G_FALSE
                              ,p_count  =>   x_msg_count
                              ,p_data   =>   x_msg_data);
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_APPLICATION_MEASURE_PVT.Update_Application_Measure ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_APPLICATION_MEASURE_PVT.Update_Application_Measure ';
    END IF;
END Update_Application_Measure;
--
END BIS_Application_Measure_PVT;

/
