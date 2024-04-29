--------------------------------------------------------
--  DDL for Package Body IGC_CC_ACCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_ACCESS_PKG" AS
/*$Header: IGCCACCB.pls 120.3.12000000.1 2007/08/20 12:10:32 mbremkum ship $*/

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_ACCESS_PKG';

  -- The flag determines whether to print debug information or not.
  g_debug_flag        VARCHAR2(1) := 'N' ;


/*=======================================================================+
 |                       PROCEDURE Insert_Row                            |
 +=======================================================================*/
PROCEDURE Insert_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id                     IN OUT NOCOPY   VARCHAR2,
  p_CC_HEADER_ID                       NUMBER,
  p_USER_ID                            NUMBER,
  p_CC_GROUP_ID                        NUMBER,
  p_CC_ACCESS_ID               IN OUT NOCOPY  NUMBER,
  p_CC_ACCESS_LEVEL                    VARCHAR2,
  p_CC_ACCESS_TYPE                     VARCHAR2,
  p_LAST_UPDATE_DATE                   DATE,
  p_LAST_UPDATED_BY                    NUMBER,
  p_CREATION_DATE                      DATE,
  p_CREATED_BY                         NUMBER,
  p_LAST_UPDATE_LOGIN                  NUMBER
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  CURSOR C IS
    SELECT rowid
    FROM   igc_cc_access
    WHERE  cc_access_id = p_cc_access_id;

BEGIN

  SAVEPOINT Insert_Row_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  INSERT INTO igc_cc_access(
        CC_HEADER_ID,
        USER_ID,
        CC_GROUP_ID,
        CC_ACCESS_ID,
        CC_ACCESS_LEVEL,
        CC_ACCESS_TYPE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
              )
  VALUES
              (
        p_CC_HEADER_ID,
        p_USER_ID,
        p_CC_GROUP_ID,
        NVL(p_CC_ACCESS_ID, igc_cc_access_s.NEXTVAL),
        p_CC_ACCESS_LEVEL,
        p_CC_ACCESS_TYPE,
        p_LAST_UPDATE_DATE,
        p_LAST_UPDATED_BY,
        p_CREATION_DATE,
        p_CREATED_BY,
        p_LAST_UPDATE_LOGIN
              )
    RETURNING cc_access_id INTO p_CC_ACCESS_ID;
  OPEN C;
  FETCH C INTO p_row_id;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  CLOSE C;


  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Insert_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END Insert_Row;
/*-------------------------------------------------------------------------*/



/*==========================================================================+
 |                       PROCEDURE Lock_Row                                 |
 +==========================================================================*/
PROCEDURE Lock_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id                              VARCHAR2,
  p_CC_HEADER_ID                       NUMBER,
  p_USER_ID                            NUMBER,
  p_CC_GROUP_ID                        NUMBER,
  p_CC_ACCESS_ID                       NUMBER,
  p_CC_ACCESS_LEVEL                    VARCHAR2,
  p_CC_ACCESS_TYPE                     VARCHAR2,

  p_row_locked                OUT NOCOPY      VARCHAR2
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  Counter NUMBER;
  CURSOR C IS
       SELECT *
       FROM   igc_cc_access
       WHERE  rowid = p_row_id
       FOR UPDATE NOWAIT;
  Recinfo C%ROWTYPE;

BEGIN

  SAVEPOINT Lock_Row_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  p_row_locked    := FND_API.G_TRUE ;

  OPEN C;

  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  CLOSE C;

  IF (
        (recinfo.CC_HEADER_ID = p_CC_HEADER_ID)
        AND (recinfo.CC_ACCESS_ID = p_CC_ACCESS_ID)
  /*    AND ((recinfo.USER_ID = p_USER_ID)
                OR ((recinfo.USER_ID IS NULL)
                     AND (p_USER_ID IS NULL)))
        AND ((recinfo.CC_GROUP_ID = p_CC_GROUP_ID)
                OR ((recinfo.CC_GROUP_ID IS NULL)
                     AND (p_CC_GROUP_ID IS NULL))) */
        AND ((recinfo.CC_ACCESS_LEVEL = p_CC_ACCESS_LEVEL)
                OR ((recinfo.CC_ACCESS_LEVEL IS NULL)
                     AND (p_CC_ACCESS_LEVEL IS NULL)))
        AND ((recinfo.CC_ACCESS_TYPE = p_CC_ACCESS_TYPE)
                OR ((recinfo.CC_ACCESS_TYPE IS NULL)
                     AND (p_CC_ACCESS_TYPE IS NULL)))
   )

  THEN
    Null;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;


  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

EXCEPTION

  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN

    ROLLBACK TO Lock_Row_Pvt ;
    p_row_locked := FND_API.G_FALSE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Lock_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END Lock_Row;
/* ----------------------------------------------------------------------- */




/*==========================================================================+
 |                       PROCEDURE Update_Row                               |
 +==========================================================================*/
PROCEDURE Update_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id                              VARCHAR2,
  p_CC_HEADER_ID                       NUMBER,
  p_USER_ID                            NUMBER,
  p_CC_GROUP_ID                        NUMBER,
  p_CC_ACCESS_ID                       NUMBER,
  p_CC_ACCESS_LEVEL                    VARCHAR2,
  p_CC_ACCESS_TYPE                     VARCHAR2,
  p_LAST_UPDATE_DATE                   DATE,
  p_LAST_UPDATED_BY                    NUMBER,
  p_LAST_UPDATE_LOGIN                  NUMBER
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

BEGIN

  SAVEPOINT Update_Row_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;


  UPDATE igc_cc_access
  SET
        CC_HEADER_ID                    = p_CC_HEADER_ID,
        USER_ID                         = p_USER_ID,
        CC_GROUP_ID                     = p_CC_GROUP_ID,
        CC_ACCESS_ID                    = p_CC_ACCESS_ID,
        CC_ACCESS_LEVEL                 = p_CC_ACCESS_LEVEL,
        CC_ACCESS_TYPE                  = p_CC_ACCESS_TYPE,
        LAST_UPDATE_DATE                = p_LAST_UPDATE_DATE,
        LAST_UPDATED_BY                 = p_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN               = p_LAST_UPDATE_LOGIN
  WHERE rowid = p_row_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND ;
  END IF;


  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Update_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END Update_Row;
/* ----------------------------------------------------------------------- */




/*==========================================================================+
 |                       PROCEDURE Delete_Row                               |
 +==========================================================================*/
PROCEDURE Delete_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id                    IN        VARCHAR2
)
IS

  l_api_name                CONSTANT VARCHAR2(30)   := 'Delete_Row';
  l_api_version             CONSTANT NUMBER         :=  1.0;

  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;

BEGIN

  SAVEPOINT Delete_Row_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF ;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Deleting the record in psb_dss_fdi_filters.

  DELETE FROM igc_cc_access
  WHERE rowid = p_row_id;


  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND ;
  END IF;


  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Delete_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END Delete_Row;



/*==========================================================================+
 |                       PROCEDURE Check_Unique                             |
 +==========================================================================*/
PROCEDURE Check_Unique
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,
  --
  p_row_id                    IN       VARCHAR2,
  p_cc_access_id              IN       NUMBER,
  p_return_value              IN OUT NOCOPY   VARCHAR2
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Unique';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  l_tmp                 VARCHAR2(1);

  CURSOR c IS
    SELECT '1'
    FROM   igc_cc_access
    WHERE  cc_access_id = p_cc_access_id
      AND  (
             p_row_id IS NULL
             OR
             rowid <> p_row_id
           );

BEGIN

  SAVEPOINT Check_Unique_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Checking the Psb_dss_fni_data_items table for references.
  OPEN c;
  FETCH c INTO l_tmp;

  -- p_Return_Value specifies whether unique value exists or not.
  IF l_tmp IS NULL THEN
    p_Return_Value := 'FALSE';
  ELSE
    p_Return_Value := 'TRUE';
  END IF;

  CLOSE c;

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Check_Unique_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Check_Unique_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Check_Unique_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END Check_Unique;
/* ----------------------------------------------------------------------- */

Function get_access_level
(
  p_header_id                 IN       NUMBER,
  p_user_id                   IN       NUMBER,
  p_preparer_id               IN       NUMBER,
  p_owner_id                  IN       NUMBER
) RETURN CHAR IS

 l_u_access_level char;
 l_g_access_level char;

 Begin


   if p_user_id = p_preparer_id then
     return('M');
   end if;

   if p_user_id = p_owner_id then
     return('M');
   end if;

   Begin
	Select  max(cc_access_level)
	 Into   l_u_access_level
  	From    IGC_CC_ACCESS
	Where   user_id = p_user_id
	  and   cc_access_type like 'U'
	  and   cc_header_id = p_header_id
	Group By cc_header_id;

	Exception When No_Data_Found then
          Null;
    End;

   Begin
	Select  max(cc_access_level)
	 Into   l_g_access_level
  	From    IGC_CC_ACCESS a,
                IGC_CC_GROUP_USERS b
	Where   b.user_id = p_user_id
	  and   a.cc_access_type like 'G'
	  and   a.cc_header_id = p_header_id
          and   a.cc_group_id = b.cc_group_id
        Group By cc_header_id;

	Exception When No_Data_Found then
          Null;
    End;

   if l_g_access_level = 'M' then
     return('M');
   elsif l_u_access_level = 'M' then
     return('M');
   elsif (l_u_access_level = 'R') OR (l_g_access_level = 'R') then
     return('R');
   else
     return('N');
   end if;


End get_access_level;


END IGC_CC_ACCESS_PKG;

/
