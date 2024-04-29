--------------------------------------------------------
--  DDL for Package Body PSB_FLEX_MAPPING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_FLEX_MAPPING_PVT" AS
/* $Header: PSBVFLXB.pls 120.2.12010000.3 2009/04/29 09:33:43 rkotha ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_Flex_Mapping_PVT';

  g_chr10 CONSTANT VARCHAR2(1) := FND_GLOBAL.Newline;



/*=======================================================================+
 |                       PROCEDURE Insert_Row                            |
 +=======================================================================*/

PROCEDURE Insert_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  p_Row_Id                    IN OUT  NOCOPY   VARCHAR2,
  --
  p_Flex_Mapping_Set_ID       IN       NUMBER,
  p_Flex_Mapping_Value_ID     IN       NUMBER,
  p_Budget_Year_Type_ID       IN       NUMBER,
  p_Application_Column_Name   IN       VARCHAR2,
  p_Flex_Value_Set_ID         IN       NUMBER,
  p_Flex_Value_ID             IN       NUMBER,
  p_From_Flex_Value_ID        IN       NUMBER,

  p_mode                      in varchar2

)
IS

  CURSOR C IS
    SELECT rowid
    FROM   psb_flex_mapping_set_values
    WHERE  flex_mapping_value_id = p_flex_mapping_value_id ;

  --
    P_LAST_UPDATE_DATE DATE;
    P_LAST_UPDATED_BY NUMBER;
    P_LAST_UPDATE_LOGIN NUMBER;

  -- variables --
    l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
    l_api_version         CONSTANT NUMBER         :=  1.0;
    l_return_status       VARCHAR2(1);
  --
BEGIN
  --
  SAVEPOINT Insert_Row_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  P_LAST_UPDATE_DATE := SYSDATE;
  if(P_MODE = 'I') then
    P_LAST_UPDATED_BY := 1;
    P_LAST_UPDATE_LOGIN := 0;
  elsif (P_MODE = 'R') then
    P_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if P_LAST_UPDATED_BY is NULL then
      P_LAST_UPDATED_BY := -1;
    end if;
    P_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if P_LAST_UPDATE_LOGIN is NULL then
      P_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    FND_MSG_PUB.Add ;
    raise FND_API.G_EXC_ERROR;
  end if;
  --

  INSERT INTO psb_flex_mapping_set_values
	 (    flex_mapping_set_id,
	      flex_mapping_value_id,
	      budget_year_type_id,
	      application_column_name,
	      flex_value_set_id,
	      flex_value_id ,
	      from_flex_value_id ,
	      creation_date,
	      created_by,
	      last_update_date,
	      last_updated_by,
	      last_update_login
	 )
	 VALUES
	 (    p_flex_mapping_set_id,
	      p_flex_mapping_value_id,
	      p_budget_year_type_id,
	      p_application_column_name,
	      p_flex_value_set_id,
	      p_flex_value_id  ,
	      p_from_flex_value_id  ,
	      p_last_update_date,
	      p_last_updated_by,
	      p_last_update_date,
	      p_last_updated_by,
	      p_last_update_login


	 );
  OPEN C;
  FETCH C INTO p_Row_Id;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  CLOSE C;
  --

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
     --
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
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Flex_Mapping_Set_ID       IN       NUMBER,
  p_Flex_Mapping_Value_ID     IN       NUMBER,
  p_Budget_Year_Type_ID       IN       NUMBER,
  p_Application_Column_Name   IN       VARCHAR2,
  p_Flex_Value_Set_ID         IN      NUMBER,
  p_Flex_Value_ID             IN       NUMBER,
  p_From_Flex_Value_ID        IN       NUMBER,
  --
  p_row_locked                OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  l_return_status VARCHAR2(1);

  --
  Counter NUMBER;
  CURSOR C IS
       SELECT Flex_Mapping_Set_ID,
	      Flex_Mapping_Value_ID,
	      Budget_Year_Type_ID ,
	      Application_Column_Name,
	      Flex_Value_Set_ID,
	      Flex_Value_ID,
	      From_Flex_Value_ID
       FROM   psb_flex_mapping_set_values
       WHERE  Flex_Mapping_Value_ID = p_Flex_Mapping_Value_ID
       FOR UPDATE of Flex_Mapping_Value_ID NOWAIT;
  Recinfo C%ROWTYPE;

BEGIN
  --
  SAVEPOINT Lock_Row_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  p_row_locked    := FND_API.G_TRUE ;
  --
  OPEN C;
  --
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    FND_MSG_PUB.Add;
    CLOSE c;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  CLOSE C;
  IF
  (
	  ( Recinfo.Flex_Mapping_Set_ID =  p_Flex_Mapping_Set_ID )
      AND ( Recinfo.Flex_Mapping_Value_ID =  p_Flex_Mapping_Value_ID )
      AND ( Recinfo.budget_year_type_id =  p_budget_year_type_id)
      AND ( Recinfo.application_column_name =  p_application_column_name)
  --
      AND ((recinfo.flex_value_set_id = P_flex_value_set_id)
	   OR ((recinfo.flex_value_set_id is null)
	       AND (P_flex_value_set_id is null)))
      AND ((recinfo.flex_value_id             = P_flex_value_id)
	   OR ((recinfo.flex_value_id is null)
	       AND (P_flex_value_id is null)))
      AND ((recinfo.from_flex_value_id             = P_from_flex_value_id)
	   OR ((recinfo.from_flex_value_id is null)
	       AND (P_from_flex_value_id is null)))
  )
  THEN
    NULL ;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED') ;
    FND_MSG_PUB.Add ;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  --
/*--
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
*/
  --
EXCEPTION
  --
  WHEN App_Exception.Record_Lock_Exception THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_row_locked    := FND_API.G_FALSE ;
    p_return_status := FND_API.G_RET_STS_ERROR ;
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
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
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Flex_Mapping_Set_ID       IN       NUMBER,
  p_Flex_Mapping_Value_ID     IN       NUMBER,
  p_Budget_Year_Type_ID       IN       NUMBER,
  p_Application_Column_Name   IN       VARCHAR2,
  p_Flex_Value_Set_ID         IN      NUMBER,
  p_Flex_Value_ID             IN       NUMBER,
  p_From_Flex_Value_ID        IN       NUMBER,
  --
  p_mode        in varchar2

)
IS
    P_LAST_UPDATE_DATE DATE;
    P_LAST_UPDATED_BY NUMBER;
    P_LAST_UPDATE_LOGIN NUMBER;
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  l_return_status VARCHAR2(1);
  --
BEGIN
  --
  SAVEPOINT Update_Row_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  P_LAST_UPDATE_DATE := SYSDATE;
  if(P_MODE = 'I') then
    P_LAST_UPDATED_BY := 1;
    P_LAST_UPDATE_LOGIN := 0;
  elsif (P_MODE = 'R') then
    P_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if P_LAST_UPDATED_BY is NULL then
      P_LAST_UPDATED_BY := -1;
    end if;
    P_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if P_LAST_UPDATE_LOGIN is NULL then
      P_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    FND_MSG_PUB.Add ;
    raise FND_API.G_EXC_ERROR ;
  end if;
  --
  UPDATE psb_flex_mapping_set_values
  SET
	Flex_Mapping_Set_ID   =  p_Flex_Mapping_Set_ID,
	Flex_Mapping_Value_ID        =  p_Flex_Mapping_Value_ID      ,
	Budget_Year_Type_ID        = p_Budget_Year_Type_ID            ,
	Application_Column_Name = p_Application_Column_Name  ,
	Flex_Value_Set_ID          = p_Flex_Value_Set_ID              ,
	Flex_Value_ID   = p_Flex_Value_ID ,
	From_Flex_Value_ID   = p_From_Flex_Value_ID ,
	last_update_date = p_last_update_date,
	last_updated_by = p_last_updated_by,
	last_update_login = p_last_update_login
  WHERE Flex_Mapping_Value_ID = p_Flex_Mapping_Value_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  --
  --
  -- Standard check of p_commit.

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  --
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
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
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Flex_Mapping_Value_ID     IN       NUMBER
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Delete_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
BEGIN
  --
  SAVEPOINT Delete_Row_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  --
  -- Deleting the record in psb_flex_mapping_set_values.
  --
  DELETE psb_flex_mapping_set_values
  WHERE  Flex_Mapping_Value_ID  = p_Flex_Mapping_Value_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND ;
  END IF;

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
END Delete_Row;
/* ----------------------------------------------------------------------- */





/* ----------------------------------------------------------------------- */


PROCEDURE Sets_Insert_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Flex_Mapping_Set_ID       IN       NUMBER,
  p_Name                      IN       VARCHAR2,
  p_Description               IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  --
  p_mode                      in varchar2

)
IS

  CURSOR C IS
    SELECT rowid
    FROM   psb_flex_mapping_sets
    WHERE  Flex_Mapping_Set_ID = p_Flex_Mapping_Set_ID ;

  --
    P_LAST_UPDATE_DATE DATE;
    P_LAST_UPDATED_BY NUMBER;
    P_LAST_UPDATE_LOGIN NUMBER;
  -- variables --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Sets_Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  l_return_status       VARCHAR2(1);
  l_row_id              VARCHAR(18);
  --
BEGIN
  --
  SAVEPOINT Sets_Insert_Row_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  P_LAST_UPDATE_DATE := SYSDATE;
  if(P_MODE = 'I') then
    P_LAST_UPDATED_BY := 1;
    P_LAST_UPDATE_LOGIN := 0;
  elsif (P_MODE = 'R') then
    P_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if P_LAST_UPDATED_BY is NULL then
      P_LAST_UPDATED_BY := -1;
    end if;
    P_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if P_LAST_UPDATE_LOGIN is NULL then
      P_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    FND_MSG_PUB.Add ;
    raise FND_API.G_EXC_ERROR;
  end if;
  --

  INSERT INTO psb_flex_mapping_sets
	 (    Flex_Mapping_Set_ID ,
	      Name,
	      Description,
	      set_of_books_id,
	      creation_date,
	      created_by,
	      last_update_date,
	      last_updated_by,
	      last_update_login
	 )
	 VALUES
	 (    p_Flex_Mapping_Set_ID,
	      p_Name,
	      p_Description,
	      p_Set_of_Books_ID,
	      p_last_update_date,
	      p_last_updated_by,
	      p_last_update_date,
	      p_last_updated_by,
	      p_last_update_login

	 );
  OPEN C;
  FETCH C INTO l_Row_Id;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  CLOSE C;
  --

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Sets_Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Sets_Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Sets_Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
     --
END Sets_Insert_Row;
/*==========================================================================+
 |                       PROCEDURE Delete_Row                               |
 +==========================================================================*/

PROCEDURE Sets_Delete_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Flex_Mapping_Set_ID       IN       NUMBER
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Delete_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_ws_count            NUMBER;
BEGIN
  --
  SAVEPOINT Sets_Delete_Row_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  DELETE psb_flex_mapping_set_values
    WHERE  flex_mapping_set_id   = p_flex_mapping_set_id ;

  DELETE psb_flex_mapping_sets
    WHERE flex_mapping_set_id  = p_flex_mapping_set_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND ;
  END IF;

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Sets_Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Sets_Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Sets_Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
END Sets_Delete_Row;

/*==========================================================================+
 |                       PROCEDURE Lock_Row                                 |
 +==========================================================================*/

PROCEDURE Sets_Lock_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Flex_Mapping_Set_ID       IN       NUMBER,
  p_Name                      IN       VARCHAR2,
  p_Description               IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  --
  p_row_locked                OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  l_return_status VARCHAR2(1);

  --
  Counter NUMBER;
  CURSOR C IS
       SELECT Flex_Mapping_Set_ID,
	      Name,
	      description ,
	      set_of_books_id
       FROM   psb_flex_mapping_sets
       WHERE  Flex_Mapping_Set_Id = p_Flex_Mapping_Set_Id
       FOR UPDATE of Flex_Mapping_Set_Id NOWAIT;
  Recinfo C%ROWTYPE;

BEGIN
  --
  SAVEPOINT Lock_Row_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  p_row_locked    := FND_API.G_TRUE ;
  --
  OPEN C;
  --
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    FND_MSG_PUB.Add;
    CLOSE c;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  CLOSE C;
  IF
  (
	  ( Recinfo.Flex_Mapping_Set_ID =  p_Flex_Mapping_Set_ID )
      AND ( Recinfo.Name =  p_Name )
      AND ( Recinfo.set_of_books_id =  p_set_of_books_id)
  --
      AND ((recinfo.description = P_description)
	   OR ((recinfo.description is null)
	       AND (P_description is null)))
  )
  THEN
    NULL ;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED') ;
    FND_MSG_PUB.Add ;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  --

EXCEPTION
  --
  WHEN App_Exception.Record_Lock_Exception THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_row_locked    := FND_API.G_FALSE ;
    p_return_status := FND_API.G_RET_STS_ERROR ;
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
END Sets_Lock_Row;
/* ----------------------------------------------------------------------- */




/*==========================================================================+
 |                       PROCEDURE Update_Row                               |
 +==========================================================================*/

PROCEDURE Sets_Update_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Flex_Mapping_Set_ID       IN       NUMBER,
  p_Name                      IN       VARCHAR2,
  p_Description               IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,

  --
  p_mode        in varchar2

)
IS
    P_LAST_UPDATE_DATE DATE;
    P_LAST_UPDATED_BY NUMBER;
    P_LAST_UPDATE_LOGIN NUMBER;
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  l_return_status VARCHAR2(1);
  --
BEGIN
  --
  SAVEPOINT Update_Row_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  P_LAST_UPDATE_DATE := SYSDATE;
  if(P_MODE = 'I') then
    P_LAST_UPDATED_BY := 1;
    P_LAST_UPDATE_LOGIN := 0;
  elsif (P_MODE = 'R') then
    P_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if P_LAST_UPDATED_BY is NULL then
      P_LAST_UPDATED_BY := -1;
    end if;
    P_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if P_LAST_UPDATE_LOGIN is NULL then
      P_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    FND_MSG_PUB.Add ;
    raise FND_API.G_EXC_ERROR ;
  end if;
  --
  UPDATE psb_flex_mapping_sets
  SET
	Flex_Mapping_Set_ID   =  p_Flex_Mapping_Set_ID,
	Name                  =  p_Name      ,
	Description           = p_Description            ,
	Set_of_Books_ID       = p_Set_of_Books_ID  ,
	last_update_date      = p_last_update_date,
	last_updated_by       = p_last_updated_by,
	last_update_login     = p_last_update_login
  WHERE Flex_Mapping_Set_ID   = p_Flex_Mapping_Set_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  --
  --
  -- Standard check of p_commit.

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  --
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
END Sets_Update_Row;

-- +++++++++++++++++++++++++++++++++
-- This function maps segment values from psb_flex_mapping_set_values to the segment values
-- of the input ccid.  If no mapping record found, input ccid segment is unchanged
-- p_mapping_mode of Worksheet,Report,GL_Posting
-- return mapped ccid value if a valid ccid or 0 if invalid ccid
-- +++++++++++++++++++++++++++++++++

FUNCTION  Get_Mapped_CCID
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  --
  p_CCID                      IN       NUMBER,
  p_Budget_Year_Type_ID       IN       NUMBER,
  p_Flexfield_Mapping_Set_ID  IN       NUMBER,
  p_Mapping_Mode              IN       VARCHAR2     := 'WORKSHEET'


) RETURN NUMBER IS
  l_ccid                NUMBER := 0;
  l_flex_code           NUMBER := 0;
  l_seg_val             FND_FLEX_EXT.SegmentArray;
  l_return_status       VARCHAR2(1);
  l_cy_budget_year_type_id NUMBER ;
  l_py_budget_year_type_id NUMBER ;
  l_cy_id               NUMBER ;
  l_index               NUMBER;
  l_segment_num         NUMBER;
  l_from_value          VARCHAR2(150);
  l_to_value            VARCHAR2(150);
  l_py_from_value       VARCHAR2(150);
  l_py_to_value         VARCHAR2(150);
  l_seg_value           VARCHAR2(150);
  /*bug:7140527:start*/
  l_seg_delimeter       VARCHAR2(3);
  l_new_seg_value       VARCHAR2(250);
  /*bug:7140527:end*/

  CURSOR c_flex IS
     SELECT s.chart_of_accounts_id,
            fnd.concatenated_segment_delimiter  --bug:7140527
       FROM psb_flex_mapping_sets   f,
	    gl_sets_of_books    s,
	    fnd_id_flex_structures_vl fnd       --bug:7140527
      WHERE flex_mapping_set_id = p_flexfield_mapping_set_id AND
	    f.set_of_books_id = s.set_of_books_id AND
	    /*bug:7140527:start*/
	    s.chart_of_accounts_id = fnd.id_flex_num AND
	    application_id = 101 AND
	    id_flex_code = 'GL#';
	    /*bug:7140527:end*/

  -- cursor for gl_posting mapping_mode
  -- get the flex map record with from value if it exists is first record;
  -- otherwise, null from value will do ... pass segment num
  cursor c_seginfo_subs is
    select fval.flex_value to_val ,
	   fromval.flex_value from_val
      from fnd_flex_values_vl fval,
	   fnd_flex_values_vl fromval,
	   psb_flex_mapping_set_values map,
	   fnd_id_flex_segments seg
     where flex_mapping_set_id =  p_flexfield_mapping_set_id
       and budget_year_type_id = p_budget_year_type_id
       and map.flex_value_id = fval.flex_value_id(+)
       and map.from_flex_value_id = fromval.flex_value_id
       and seg.application_id = 101
       and seg.id_flex_code = 'GL#'
       and seg.id_flex_num = l_flex_code
       and seg.enabled_flag = 'Y'
       and seg.application_column_name = map.application_column_name
       and map.application_column_name = g_seg_name(l_segment_num)
       and ( fval.flex_value is  null
       or  fromval.flex_value =  l_seg_val(l_segment_num)  )
       order by fromval.flex_value

      ;
    -- need to outer join fromval so that null from values will selected also
    -- the record has already been selected and to further select the record with
    -- null from value, the map record is now the bigger table(null) than fromval
    -- read only values for a segment which matches the input segment or is null
    -- and is ordered by with null values last.  Specific value matched supercedes
    -- null from value so it will be read first when first rec is read.

  -- cursor for worksheet mapping_mode - uses from value
  cursor c_seginfo_ws is
    select fval.flex_value from_val , seg.application_column_name
      from fnd_flex_values_vl fval,
	   psb_flex_mapping_set_values map,
	   fnd_id_flex_segments seg
     where flex_mapping_set_id = p_flexfield_mapping_set_id
       and budget_year_type_id = l_cy_budget_year_type_id
       and map.from_flex_value_id = fval.flex_value_id
       and seg.application_id = 101
       and seg.id_flex_code = 'GL#'
       and seg.id_flex_num = l_flex_code
       and seg.enabled_flag = 'Y'
       and seg.application_column_name = map.application_column_name ;

  cursor c_cy is
    select fval.flex_value curr_val
      from fnd_flex_values_vl fval,
	   psb_flex_mapping_set_values map,
	   fnd_id_flex_segments seg
     where flex_mapping_set_id = p_flexfield_mapping_set_id
       and budget_year_type_id = l_cy_budget_year_type_id
       and map.from_flex_value_id = fval.flex_value_id
       and seg.application_id = 101
       and seg.id_flex_code = 'GL#'
       and seg.id_flex_num = l_flex_code
       and seg.enabled_flag = 'Y'
       and seg.application_column_name = map.application_column_name
       and map.application_column_name = g_seg_name(l_segment_num)
     ;

  cursor c_py is
    select fval.flex_value curr_val
      from fnd_flex_values_vl fval,
	   psb_flex_mapping_set_values map,
	   fnd_id_flex_segments seg
     where flex_mapping_set_id = p_flexfield_mapping_set_id
       and budget_year_type_id = l_py_budget_year_type_id
       and map.from_flex_value_id = fval.flex_value_id
       and seg.application_id = 101
       and seg.id_flex_code = 'GL#'
       and seg.id_flex_num = l_flex_code
       and seg.enabled_flag = 'Y'
       and seg.application_column_name = map.application_column_name
       and map.application_column_name = g_seg_name(l_segment_num)
     ;

  cursor c_cy_type    is
    select budget_year_type_id
      from psb_budget_year_types_vl
     where year_category_type = 'CY';

  cursor c_py_type    is
    select budget_year_type_id
      from psb_budget_year_types_vl y
     where year_category_type = 'PY'
       and budget_year_type_id = p_budget_year_type_id
  ;
BEGIN

  -- +++++++++++++++++
  -- Setup flex code = coa
  -- +++++++++++++++++
  OPEN c_flex;
  FETCH c_flex INTO l_flex_code, l_seg_delimeter; --bug:7140527:added l_seg_delimeter
  IF c_flex%NOTFOUND THEN
     CLOSE c_flex;
     raise NO_DATA_FOUND;
  END IF;
  CLOSE c_flex;

  -- +++++++++++++++++
  -- Setup flex info (segments)
  -- +++++++++++++++++

  Flex_Info (p_flex_code => l_flex_code,
	     p_return_status => l_return_status);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
     raise FND_API.G_EXC_ERROR;
  end if;

  -- +++++++++++++++++
  -- Explode p_ccid into individual segments to l_seg_val array
  -- +++++++++++++++++

  if not FND_FLEX_EXT.Get_Segments
    (application_short_name => 'SQLGL',
     key_flex_code => 'GL#',
     structure_number => g_flex_code,
     combination_id => p_ccid,
     n_segments => g_num_segs,
     segments => l_seg_val ) then

    FND_MSG_PUB.Add;
    raise FND_API.G_EXC_ERROR;
  end if;


  -- +++++++++++++++++
  -- get current year budget year type id
  -- +++++++++++++++++

  for c_cy_type_rec    in c_cy_type    loop
     -- get cy id
     l_cy_budget_year_type_id  := c_cy_type_rec.budget_year_type_id;
  end loop;

  for c_py_type_rec    in c_py_type    loop
     -- get py id
     l_py_budget_year_type_id  := c_py_type_rec.budget_year_type_id;
  end loop;


  -- +++++++++++++++++
  -- for worksheet  mapping mode, always map using current year type since cy stores the
  -- values to be stored in worksheet
  -- +++++++++++++++++

  if p_mapping_mode = 'WORKSHEET' then
     -- substitute from value of each flex value mapping record to the appropriate segment
     -- using segment_name


     if p_budget_year_type_id = l_py_budget_year_type_id then
     -- map py to cy; no mapping for cy or pp
     for l_index in 1..g_num_segs loop
	 l_segment_num := l_index ;
	 open c_py;
	 fetch c_py into l_py_to_value;
	 if (c_py%NOTFOUND) THEN
	     close c_py;
	 else
	    open c_cy;
	    fetch c_cy into l_to_value;

	    if (c_cy%NOTFOUND) THEN
		close c_py;
		close c_cy;
		-- no py or cy so bypass this segment
	    else
		-- cy/py exists so try to map
		if l_py_to_value = l_seg_val(l_index) then
		  l_seg_val(l_index) := l_to_value;
		end if;

		close c_py;
		close c_cy;
	    end if;
	  --
	  end if;


	 -- process next iteration

     end loop;

     else
	null;
	-- p_budget_year_id is not py so for ws, should not map it -> ccid unchanged
     end if;

     -- ++ PY mapped to CY value if py segment match input segment
     -- ++ no mapping for CY and PP; input ccid becomes ws ccid; so for pp,
     -- ++ so if pp ccid is not the correct ccid for pp (i.e. still cy), then
     -- ++ that will be a separate account in ws

  else
     --- ++ for GL_POSTING; use the input budget year type id to map the values
     --- ++ this is specific from_value substitution in this order
     --- ++ 1. from value = input ccid segment
     --- ++ 2. from value is null, substitute to value to input ccid segment
     --- ++ 3. retain input ccid segment coz no flex mapping record found
     --- ++ if input budget year type id is current year, do not do a mapping
     --- ++ logically, call this routine only for PP type for GL_POSTING and
     --- ++ PY/CY/PP for REPORT where there is no mapping for CY

     if l_cy_budget_year_type_id = p_budget_year_type_id then
	null; -- no mapping
     else
	for l_index in 1..g_num_segs loop

	   l_segment_num := l_index ;
	   open c_seginfo_subs;
	   -- ++ for each of the input ccid, fetch the corresponding values for the
	   -- ++ segment name/value. Only process the first record found, which could
	   -- ++ either have from value = to l_seg_value, or null from_value

	   fetch c_seginfo_subs into l_to_value, l_from_value;

	   if (c_seginfo_subs%NOTFOUND) THEN
	     close c_seginfo_subs;
	   else
	     l_seg_val(l_index) := l_to_value ;
	     close c_seginfo_subs;
	   end if ;

	end loop;
     end if; -- cy type = p type

  end if;





  --+++++++++++++++++++
  -- If the composed Code Combination does not already exist in GL, it is
  -- dynamically created
  --+++++++++++++++++++

  if not FND_FLEX_EXT.Get_Combination_ID
     (application_short_name => 'SQLGL',
     key_flex_code => 'GL#',
     structure_number => g_flex_code,
     validation_date => sysdate,
     n_segments => g_num_segs,
     segments => l_seg_val,
     combination_id => l_ccid) then

     FND_MSG_PUB.Add;

    /*bug:7140527:start*/
     l_new_seg_value := '';

     for i in 1..g_num_segs loop
      if l_new_seg_value is null then
        l_new_seg_value := l_new_seg_value||l_seg_val(i);
      else
        l_new_seg_value := l_new_seg_value||l_seg_delimeter||l_seg_val(i);
      end if;
     end loop;

    FND_MESSAGE.SET_NAME('PSB','PSB_INVALID_MAP_ACCOUNT');
    FND_MESSAGE.SET_TOKEN('ACCOUNT', l_new_seg_value);

     FND_MSG_PUB.Add;
    /*bug:7140527:end*/
     l_ccid := 0;
     raise FND_API.G_EXC_ERROR;
  end if;

  --+++++++++++++++++++
  -- return the new ccid
  --+++++++++++++++++++

  return(l_ccid);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     if (c_py%ISOPEN) then
       close c_py;
     end if;
     if (c_cy%ISOPEN) then
	close c_cy;
     end if;
     l_ccid := 0;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     if (c_py%ISOPEN) then
       close c_py;
     end if;
     if (c_cy%ISOPEN) then
	close c_cy;
     end if;
     l_ccid := 0;

   when OTHERS then
     if (c_py%ISOPEN) then
       close c_py;
     end if;
     if (c_cy%ISOPEN) then
	close c_cy;
     end if;
     l_ccid := 0;

END Get_Mapped_CCID;
----++++++++++

--++
-- function will return the concatenated segments with proper delimiter
-- call this function only for reports, not for gl_posting since it will not
-- dynamically insert a new ccid
--

FUNCTION  Get_Mapped_Account
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  --
  p_CCID                      IN       NUMBER,
  p_Budget_Year_Type_ID       IN       NUMBER,
  p_Flexfield_Mapping_Set_ID  IN       NUMBER

) RETURN VARCHAR2 IS

  l_concat_segments  VARCHAR2(2000) := null;
  l_flex_code           NUMBER := 0;
  l_seg_val             FND_FLEX_EXT.SegmentArray;
  l_return_status       VARCHAR2(1);
  l_cy_budget_year_type_id NUMBER ;
  l_cy_id               NUMBER ;
  l_index               NUMBER;
  l_segment_num         NUMBER;
  l_from_value          VARCHAR2(150);
  l_cy_from_value       VARCHAR2(150);
  l_to_value            VARCHAR2(150);
  l_seg_value           VARCHAR2(150);
  l_segment_delimiter   VARCHAR2(1);
  l_py_exists           VARCHAR2(1) := FND_API.G_FALSE;

  CURSOR c_flex IS
     SELECT s.chart_of_accounts_id,fnd.concatenated_segment_delimiter
       FROM psb_flex_mapping_sets   f,
	    gl_sets_of_books    s,
	    fnd_id_flex_structures_vl fnd
      WHERE flex_mapping_set_id = p_flexfield_mapping_set_id AND
	    f.set_of_books_id = s.set_of_books_id AND
	    s.chart_of_accounts_id = fnd.id_flex_num AND
	    application_id = 101 AND
	    id_flex_code = 'GL#'

      ;


  -- cursor for report
  -- get the flex map record with to value if it exists is first record;
  -- otherwise, null from value will do ... pass segment num

  cursor c_seginfo_subs is
    select fval.flex_value to_val ,
	   fromval.flex_value from_val
      from fnd_flex_values_vl fval,
	   fnd_flex_values_vl fromval,
	   psb_flex_mapping_set_values map,
	   fnd_id_flex_segments seg
     where flex_mapping_set_id =  p_flexfield_mapping_set_id
       and budget_year_type_id = p_budget_year_type_id
       and map.flex_value_id = fval.flex_value_id(+)
       and map.from_flex_value_id = fromval.flex_value_id
       and seg.application_id = 101
       and seg.id_flex_code = 'GL#'
       and seg.id_flex_num = l_flex_code
       and seg.enabled_flag = 'Y'
       and seg.application_column_name = map.application_column_name
       and map.application_column_name = g_seg_name(l_segment_num)
       and ( fval.flex_value is  null
       or  fromval.flex_value =  l_seg_val(l_segment_num)  )
       order by fromval.flex_value

      ;
    -- need to outer join fval so that null from values will selected also
    -- the record has already been selected and to further select the record with
    -- null from value, the map record is now the bigger table(null) than fromval
    -- read only values for a segment which matches the input segment or is null
    -- and is ordered by with null values last.  Specific value matched supercedes
    -- null from value so it will be read first when first rec is read.

  cursor c_cy is
    select fval.flex_value curr_val
      from fnd_flex_values_vl fval,
	   psb_flex_mapping_set_values map,
	   fnd_id_flex_segments seg
     where flex_mapping_set_id = p_flexfield_mapping_set_id
       and budget_year_type_id = l_cy_budget_year_type_id
       and map.from_flex_value_id = fval.flex_value_id
       and seg.application_id = 101
       and seg.id_flex_code = 'GL#'
       and seg.id_flex_num = l_flex_code
       and seg.enabled_flag = 'Y'
       and seg.application_column_name = map.application_column_name
       and map.application_column_name = g_seg_name(l_segment_num)
     ;


  cursor c_cy_type    is
    select budget_year_type_id
      from psb_budget_year_types_vl
     where year_category_type = 'CY'
   ;

  cursor c_py_exists is
    select 'Exists'
      from dual
     where exists
	  (select 1
      from psb_budget_year_types_vl
     where budget_year_type_id = p_Budget_Year_Type_ID
       and year_category_type = 'PY'
	  );
  -- flag indicating if input budget year id is PY since substitution
  -- of CY value to PY will take place

BEGIN

  -- +++++++++++++++++
  -- Setup flex code = coa
  -- +++++++++++++++++
  OPEN c_flex;
  FETCH c_flex INTO l_flex_code,l_segment_delimiter;
  IF c_flex%NOTFOUND THEN
     CLOSE c_flex;
     raise NO_DATA_FOUND;
  END IF;
  CLOSE c_flex;

  -- +++++++++++++++++
  -- Setup flex info (segments)
  -- +++++++++++++++++

  Flex_Info (p_flex_code => l_flex_code,
	     p_return_status => l_return_status);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
     raise FND_API.G_EXC_ERROR;
  end if;

  -- +++++++++++++++++
  -- Explode p_ccid into individual segments to l_seg_val array
  -- +++++++++++++++++

  if not FND_FLEX_EXT.Get_Segments
    (application_short_name => 'SQLGL',
     key_flex_code => 'GL#',
     structure_number => g_flex_code,
     combination_id => p_ccid,
     n_segments => g_num_segs,
     segments => l_seg_val ) then

    FND_MSG_PUB.Add;
    raise FND_API.G_EXC_ERROR;
  end if;


  -- +++++++++++++++++
  -- get current year budget year type id
  -- +++++++++++++++++

  for c_cy_type_rec    in c_cy_type    loop
     -- get cy id
     l_cy_budget_year_type_id  := c_cy_type_rec.budget_year_type_id;
  end loop;

  for c_py_exists_rec in c_py_exists loop
      l_py_exists := FND_API.G_TRUE;
      -- indicates if py budget group id is before cy where the ccid segment
      -- of the cy will be mapped back to py ; all other py will be unchanged
  end loop;

  -- +++++++++++++++++
  -- for worksheet  mapping mode, always map using current year type since cy stores the
  -- values to be stored in worksheet
  -- +++++++++++++++++

     --- ++ REPORT ; use the input budget year type id to map the values
     --- ++ this is specific from_value substitution in this order
     --- ++ 1. from value = input ccid segment
     --- ++ 2. from value is null, substitute to value to input ccid segment
     --- ++ 3. retain input ccid segment coz no flex mapping record found
     --- ++ if input budget year type id is current year, do not do a mapping
     --- ++ logically, call this routine only for PP type for GL_POSTING and
     --- ++ PY/CY/PP for REPORT where there is no mapping for CY

   if l_cy_budget_year_type_id = p_budget_year_type_id then
      null; -- no mapping
   else
      for l_index in 1..g_num_segs loop

	   l_segment_num := l_index ;
	   open c_seginfo_subs;

	   -- ++ for each of the input ccid, fetch the corresponding values for the
	   -- ++ segment name/value. Only process the first record found, which could
	   -- ++ either have from value = to l_seg_value, or null to_value

	   fetch c_seginfo_subs into l_to_value, l_from_value;

	   if (c_seginfo_subs%NOTFOUND) THEN
	     close c_seginfo_subs;
	   else

	       if (FND_API.to_Boolean(l_py_exists)) then

		  -- ++ substitute ws ccid from value for py to value
		  open c_cy;
		  fetch c_cy into l_cy_from_value;
		  if (c_cy%NOTFOUND) THEN
		     close c_cy;
		  end if;
		  if l_seg_val(l_index) = l_cy_from_value then

		     l_seg_val(l_index) := l_from_value; -- py value substituted

		     close c_cy;
		  end if;

	       else
		  -- ++ pp substitution is flex map's from/to value
		  -- ++ cursor should have done a match already
		  l_seg_val(l_index) := l_to_value;
	       end if;
	     close c_seginfo_subs;
	   end if ;

     end loop;
  end if; -- cy type = p type



  --+++++++++++++++++++
  -- Concatenate the segments of the account combination
  --+++++++++++++++++++
  l_concat_segments := FND_FLEX_EXT.Concatenate_Segments
		       (n_segments => g_num_segs,
		       segments => l_seg_val,
		       delimiter => l_segment_delimiter);


  --+++++++++++++++++++
  -- return the new ccid
  --+++++++++++++++++++

  return(l_concat_segments);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     if (c_cy%ISOPEN) then
	close c_cy;
     end if;
     l_concat_segments := p_ccid;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     if (c_cy%ISOPEN) then
	close c_cy;
     end if;
     l_concat_segments := p_ccid;

   when OTHERS then
     if (c_cy%ISOPEN) then
	close c_cy;
     end if;
     l_concat_segments := p_ccid;

END;



PROCEDURE Flex_Info
( p_return_status  OUT  NOCOPY  VARCHAR2,
  p_flex_code      IN   NUMBER
) IS

  cursor c_seginfo is
    select application_column_name,segment_num
      from fnd_id_flex_segments
     where application_id = 101
       and id_flex_code = 'GL#'
       and id_flex_num = p_flex_code
       and enabled_flag = 'Y'
     order by segment_num;

BEGIN

  -- this procedure sets the number of segments used by the coa and
  -- stores the segments names (i.e., SEGMENT1...)
  for l_init_index in 1..g_seg_name.Count loop
    g_seg_name(l_init_index) := null;
  end loop;

  g_num_segs := 0;

  g_flex_code := p_flex_code;

  for c_Seginfo_Rec in c_seginfo loop
    g_num_segs := g_num_segs + 1;
    g_seg_name(g_num_segs) := c_Seginfo_Rec.application_column_name;
    g_seg_num(g_num_segs)  := c_Seginfo_Rec.segment_num;
  end loop;


  --+++++++++++++++++++
  -- If the composed Code Combination does not already exist in GL, it is
  -- dynamically created
  --+++++++++++++++++++

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Flex_Info;

/*-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*/


PROCEDURE Pass_View_Parameters  ( p_flex_set_id IN NUMBER,
				  p_application_column_name IN VARCHAR2) IS

  BEGIN
    g_Flex_Set_ID := p_Flex_Set_ID;
    g_Application_Column_Name := p_Application_Column_Name;

END Pass_View_Parameters;

--
-- FUNCTIONS
--

FUNCTION Get_Flex_Set_ID  RETURN NUMBER IS
  BEGIN
     Return g_Flex_Set_ID;
  END Get_Flex_Set_ID ;

FUNCTION Get_Application_Column_Name RETURN varchar2 IS
  BEGIN
     Return g_Application_Column_Name;
END Get_Application_Column_Name;




/* ----------------------------------------------------------------------- */

END PSB_Flex_Mapping_PVT;

/
