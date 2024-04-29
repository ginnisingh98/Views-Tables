--------------------------------------------------------
--  DDL for Package Body PSB_POSITION_ATTRIBUTES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_POSITION_ATTRIBUTES_PVT" AS
/* $Header: PSBVPATB.pls 120.9.12010000.3 2009/05/22 10:12:01 rkotha ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_POSITION_ATTRIBUTES_PVT';

/* ----------------------------------------------------------------------- */

PROCEDURE INSERT_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  p_ROW_ID                      IN OUT  NOCOPY  VARCHAR2,
  p_ATTRIBUTE_ID                IN      NUMBER,
  p_BUSINESS_GROUP_ID           IN      NUMBER,
  p_NAME                        IN      VARCHAR2,
  p_DISPLAY_IN_WORKSHEET        IN      VARCHAR2,
  p_DISPLAY_SEQUENCE            IN      NUMBER,
  p_DISPLAY_PROMPT              IN      VARCHAR2,
  p_REQUIRED_FOR_IMPORT_FLAG    IN      VARCHAR2,
  p_REQUIRED_FOR_POSITIONS_FLAG IN      VARCHAR2,
  p_ALLOW_IN_POSITION_SET_FLAG  IN      VARCHAR2,
  p_VALUE_TABLE_FLAG            IN      VARCHAR2,
  p_PROTECTED_FLAG              IN      VARCHAR2,
  p_DEFINITION_TYPE             IN      VARCHAR2,
  p_DEFINITION_STRUCTURE        IN      VARCHAR2,
  p_DEFINITION_TABLE            IN      VARCHAR2,
  p_DEFINITION_COLUMN           IN      VARCHAR2,
  p_ATTRIBUTE_TYPE_ID           IN      NUMBER,
  p_DATA_TYPE                   IN      VARCHAR2,
  p_APPLICATION_ID              IN      NUMBER,
  p_SYSTEM_ATTRIBUTE_TYPE       IN      VARCHAR2,
  p_LAST_UPDATE_DATE            IN      DATE,
  p_LAST_UPDATED_BY             IN      NUMBER,
  p_LAST_UPDATE_LOGIN           IN      NUMBER,
  p_CREATED_BY                  IN      NUMBER,
  p_CREATION_DATE               IN      DATE
) AS

  l_api_name            CONSTANT VARCHAR2(30)   := 'INSERT_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_attribute_id                 number;
  --
  cursor c1 is
     select row_id from psb_attributes_VL
     where attribute_id = p_attribute_id;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     INSERT_ROW_PVT;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


  -- API body
  INSERT INTO psb_attributes
  (ATTRIBUTE_ID                             ,
   BUSINESS_GROUP_ID                        ,
   NAME                                     ,
   DISPLAY_IN_WORKSHEET                     ,
   DISPLAY_SEQUENCE                         ,
   DISPLAY_PROMPT                           ,
   REQUIRED_FOR_IMPORT_FLAG                 ,
   REQUIRED_FOR_POSITIONS_FLAG              ,
   ALLOW_IN_POSITION_SET_FLAG               ,
   VALUE_TABLE_FLAG                         ,
   PROTECTED_FLAG                           ,
   DEFINITION_TYPE                          ,
   DEFINITION_STRUCTURE                     ,
   DEFINITION_TABLE                         ,
   DEFINITION_COLUMN                        ,
   ATTRIBUTE_TYPE_ID                        ,
   DATA_TYPE                                ,
   APPLICATION_ID                           ,
   SYSTEM_ATTRIBUTE_TYPE                    ,
   LAST_UPDATE_DATE                         ,
   LAST_UPDATED_BY                          ,
   LAST_UPDATE_LOGIN                        ,
   CREATED_BY                               ,
   CREATION_DATE
  )
  VALUES
  (
  p_attribute_id				,
  p_BUSINESS_GROUP_ID           ,
  p_NAME                        ,
  p_DISPLAY_IN_WORKSHEET        ,
  p_DISPLAY_SEQUENCE            ,
  p_DISPLAY_PROMPT              ,
  p_REQUIRED_FOR_IMPORT_FLAG    ,
  p_REQUIRED_FOR_POSITIONS_FLAG ,
  p_ALLOW_IN_POSITION_SET_FLAG  ,
  p_VALUE_TABLE_FLAG            ,
  p_PROTECTED_FLAG              ,
  p_DEFINITION_TYPE             ,
  p_DEFINITION_STRUCTURE        ,
  p_DEFINITION_TABLE            ,
  p_DEFINITION_COLUMN           ,
  p_ATTRIBUTE_TYPE_ID           ,
  p_DATA_TYPE                   ,
  p_APPLICATION_ID              ,
  P_SYSTEM_ATTRIBUTE_TYPE       ,
  p_LAST_UPDATE_DATE            ,
  p_LAST_UPDATED_BY             ,
  p_LAST_UPDATE_LOGIN           ,
  p_CREATED_BY                  ,
  p_CREATION_DATE
  );

    insert into PSB_ATTRIBUTES_TL (
      ATTRIBUTE_ID,
      NAME,
      DISPLAY_PROMPT,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATED_BY,
      CREATION_DATE,
      LANGUAGE,
      SOURCE_LANG
    ) select
      P_ATTRIBUTE_ID,
      P_NAME,
      P_DISPLAY_PROMPT,
      P_LAST_UPDATE_DATE,
      P_LAST_UPDATED_BY,
      P_LAST_UPDATE_LOGIN,
      P_CREATED_BY,
      P_CREATION_DATE,
      L.LANGUAGE_CODE,
      userenv('LANG')
    from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and not exists
    (select NULL
     from PSB_ATTRIBUTES_TL T
     where T.ATTRIBUTE_ID = P_ATTRIBUTE_ID
     and T.LANGUAGE = L.LANGUAGE_CODE);

    open c1;
    fetch c1 into P_ROW_ID;
    if (c1%notfound) then
      close c1;
      raise no_data_found;
    end if;

  -- End of API body.

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to INSERT_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to INSERT_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to INSERT_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END INSERT_ROW;

PROCEDURE UPDATE_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  p_ATTRIBUTE_ID                IN      NUMBER,
  p_BUSINESS_GROUP_ID           IN      NUMBER,
  p_NAME                        IN      VARCHAR2,
  p_DISPLAY_IN_WORKSHEET        IN      VARCHAR2,
  p_DISPLAY_SEQUENCE            IN      NUMBER,
  p_DISPLAY_PROMPT              IN      VARCHAR2,
  p_REQUIRED_FOR_IMPORT_FLAG    IN      VARCHAR2,
  p_REQUIRED_FOR_POSITIONS_FLAG IN      VARCHAR2,
  p_ALLOW_IN_POSITION_SET_FLAG  IN      VARCHAR2,
  p_VALUE_TABLE_FLAG            IN      VARCHAR2,
  p_PROTECTED_FLAG              IN      VARCHAR2,
  p_DEFINITION_TYPE             IN      VARCHAR2,
  p_DEFINITION_STRUCTURE        IN      VARCHAR2,
  p_DEFINITION_TABLE            IN      VARCHAR2,
  p_DEFINITION_COLUMN           IN      VARCHAR2,
  p_ATTRIBUTE_TYPE_ID           IN      NUMBER,
  p_DATA_TYPE                   IN      VARCHAR2,
  p_APPLICATION_ID              IN      NUMBER,
  p_SYSTEM_ATTRIBUTE_TYPE       IN      VARCHAR2,
  p_LAST_UPDATE_DATE            IN      DATE,
  p_LAST_UPDATED_BY             IN      NUMBER,
  p_LAST_UPDATE_LOGIN           IN      NUMBER
) AS

  l_api_name            CONSTANT VARCHAR2(30)   := 'UPDATE_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     UPDATE_ROW_PVT;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  UPDATE psb_attributes SET
    ATTRIBUTE_ID                = p_ATTRIBUTE_ID,
    BUSINESS_GROUP_ID           = p_BUSINESS_GROUP_ID ,
    NAME                        = p_NAME ,
    DISPLAY_IN_WORKSHEET        = p_DISPLAY_IN_WORKSHEET,
    DISPLAY_SEQUENCE            = p_DISPLAY_SEQUENCE,
    DISPLAY_PROMPT              = p_DISPLAY_PROMPT,
    REQUIRED_FOR_IMPORT_FLAG    = p_REQUIRED_FOR_IMPORT_FLAG,
    REQUIRED_FOR_POSITIONS_FLAG = p_REQUIRED_FOR_POSITIONS_FLAG,
    ALLOW_IN_POSITION_SET_FLAG  = p_ALLOW_IN_POSITION_SET_FLAG,
    VALUE_TABLE_FLAG            = p_VALUE_TABLE_FLAG,
    PROTECTED_FLAG              = p_PROTECTED_FLAG,
    DEFINITION_TYPE             = p_DEFINITION_TYPE,
    DEFINITION_STRUCTURE        = p_DEFINITION_STRUCTURE,
    DEFINITION_TABLE            = p_DEFINITION_TABLE,
    DEFINITION_COLUMN           = p_DEFINITION_COLUMN,
    ATTRIBUTE_TYPE_ID           = p_ATTRIBUTE_TYPE_ID,
    DATA_TYPE                   = p_DATA_TYPE,
    APPLICATION_ID              = P_APPLICATION_ID,
    SYSTEM_ATTRIBUTE_TYPE       = P_SYSTEM_ATTRIBUTE_TYPE
  WHERE attribute_id = p_attribute_id;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

  update PSB_ATTRIBUTES_TL set
    NAME = P_NAME,
    DISPLAY_PROMPT = P_DISPLAY_PROMPT,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ATTRIBUTE_ID = P_ATTRIBUTE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

  -- End of API body.

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to UPDATE_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to UPDATE_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to UPDATE_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END UPDATE_ROW;

PROCEDURE DELETE_ROW
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  --
  p_ATTRIBUTE_ID        IN      NUMBER
) AS

  l_api_name            CONSTANT VARCHAR2(30)   := 'DELETE_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     DELETE_ROW_PVT;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Perform the delete

  delete from PSB_ATTRIBUTES_TL
  where ATTRIBUTE_ID = P_ATTRIBUTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  DELETE FROM psb_attributes WHERE attribute_id = p_attribute_id;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;


  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to DELETE_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to DELETE_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to DELETE_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END DELETE_ROW;

PROCEDURE LOCK_ROW(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  p_lock_row                    OUT  NOCOPY     VARCHAR2,
  --
  p_ROW_ID                      IN      VARCHAR2,
  p_ATTRIBUTE_ID                IN      NUMBER,
  p_BUSINESS_GROUP_ID           IN      NUMBER,
  p_NAME                        IN      VARCHAR2,
  p_DISPLAY_IN_WORKSHEET        IN      VARCHAR2,
  p_DISPLAY_SEQUENCE            IN      NUMBER,
  p_DISPLAY_PROMPT              IN      VARCHAR2,
  p_REQUIRED_FOR_IMPORT_FLAG    IN      VARCHAR2,
  p_REQUIRED_FOR_POSITIONS_FLAG IN      VARCHAR2,
  p_ALLOW_IN_POSITION_SET_FLAG  IN      VARCHAR2,
  p_VALUE_TABLE_FLAG            IN      VARCHAR2,
  p_PROTECTED_FLAG              IN      VARCHAR2,
  p_DEFINITION_TYPE             IN      VARCHAR2,
  p_DEFINITION_STRUCTURE        IN      VARCHAR2,
  p_DEFINITION_TABLE            IN      VARCHAR2,
  p_DEFINITION_COLUMN           IN      VARCHAR2,
  p_ATTRIBUTE_TYPE_ID           IN      NUMBER,
  p_DATA_TYPE                   IN      VARCHAR2,
  p_APPLICATION_ID              IN      NUMBER,
  p_SYSTEM_ATTRIBUTE_TYPE       IN      VARCHAR2
) AS

  l_api_name            CONSTANT VARCHAR2(30)   := 'LOCK_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;
  --
  counter number;

  cursor c is select
      ALLOW_IN_POSITION_SET_FLAG,
      VALUE_TABLE_FLAG,
      APPLICATION_ID,
      DEFINITION_TYPE,
      ATTRIBUTE_TYPE_ID,
      DATA_TYPE,
      SYSTEM_ATTRIBUTE_TYPE,
      BUSINESS_GROUP_ID,
      REQUIRED_FOR_POSITIONS_FLAG,
      REQUIRED_FOR_IMPORT_FLAG,
      PROTECTED_FLAG,
      DEFINITION_STRUCTURE,
      DEFINITION_TABLE,
      DEFINITION_COLUMN,
      DISPLAY_SEQUENCE,
      DISPLAY_IN_WORKSHEET
    from PSB_ATTRIBUTES
    where ATTRIBUTE_ID = p_ATTRIBUTE_ID
    for update of ATTRIBUTE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DISPLAY_PROMPT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PSB_ATTRIBUTES_TL
    where ATTRIBUTE_ID = p_ATTRIBUTE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ATTRIBUTE_ID nowait;

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
  p_lock_row    := FND_API.G_TRUE ;
  --
  OPEN C;
  --
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  CLOSE C;

  if (    ((recinfo.ALLOW_IN_POSITION_SET_FLAG = p_ALLOW_IN_POSITION_SET_FLAG)
	   OR ((recinfo.ALLOW_IN_POSITION_SET_FLAG is null) AND (p_ALLOW_IN_POSITION_SET_FLAG is null)))
      AND ((recinfo.VALUE_TABLE_FLAG = p_VALUE_TABLE_FLAG)
	   OR ((recinfo.VALUE_TABLE_FLAG is null) AND (p_VALUE_TABLE_FLAG is null)))
      AND ((recinfo.APPLICATION_ID = p_APPLICATION_ID)
	   OR ((recinfo.APPLICATION_ID is null) AND (p_APPLICATION_ID is null)))
      AND ((recinfo.DEFINITION_TYPE = p_DEFINITION_TYPE)
	   OR ((recinfo.DEFINITION_TYPE is null) AND (p_DEFINITION_TYPE is null)))
      AND ((recinfo.ATTRIBUTE_TYPE_ID = p_ATTRIBUTE_TYPE_ID)
	   OR ((recinfo.ATTRIBUTE_TYPE_ID is null) AND (p_ATTRIBUTE_TYPE_ID is null)))
      AND ((recinfo.DATA_TYPE = p_DATA_TYPE)
	   OR ((recinfo.DATA_TYPE is null) AND (p_DATA_TYPE is null)))
      AND ((recinfo.SYSTEM_ATTRIBUTE_TYPE = p_SYSTEM_ATTRIBUTE_TYPE)
	   OR ((recinfo.SYSTEM_ATTRIBUTE_TYPE is null) AND (p_SYSTEM_ATTRIBUTE_TYPE is null)))
      AND (recinfo.BUSINESS_GROUP_ID = p_BUSINESS_GROUP_ID)
      AND ((recinfo.REQUIRED_FOR_POSITIONS_FLAG = p_REQUIRED_FOR_POSITIONS_FLAG)
	   OR ((recinfo.REQUIRED_FOR_POSITIONS_FLAG is null) AND (p_REQUIRED_FOR_POSITIONS_FLAG is null)))
      AND ((recinfo.REQUIRED_FOR_IMPORT_FLAG = p_REQUIRED_FOR_IMPORT_FLAG)
	   OR ((recinfo.REQUIRED_FOR_IMPORT_FLAG is null) AND (p_REQUIRED_FOR_IMPORT_FLAG is null)))
      AND ((recinfo.PROTECTED_FLAG = p_PROTECTED_FLAG)
	   OR ((recinfo.PROTECTED_FLAG is null) AND (p_PROTECTED_FLAG is null)))
      AND ((recinfo.DEFINITION_STRUCTURE = p_DEFINITION_STRUCTURE)
	   OR ((recinfo.DEFINITION_STRUCTURE is null) AND (p_DEFINITION_STRUCTURE is null)))
      AND ((recinfo.DEFINITION_TABLE = p_DEFINITION_TABLE)
	   OR ((recinfo.DEFINITION_TABLE is null) AND (p_DEFINITION_TABLE is null)))
      AND ((recinfo.DEFINITION_COLUMN = p_DEFINITION_COLUMN)
	   OR ((recinfo.DEFINITION_COLUMN is null) AND (p_DEFINITION_COLUMN is null)))
      AND ((recinfo.DISPLAY_SEQUENCE = p_DISPLAY_SEQUENCE)
	   OR ((recinfo.DISPLAY_SEQUENCE is null) AND (p_DISPLAY_SEQUENCE is null)))
      AND ((recinfo.DISPLAY_IN_WORKSHEET = p_DISPLAY_IN_WORKSHEET)
	   OR ((recinfo.DISPLAY_IN_WORKSHEET is null) AND (p_DISPLAY_IN_WORKSHEET is null)))
)
  THEN
    Null;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

   for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = p_NAME)
	  AND ((tlinfo.DISPLAY_PROMPT = p_DISPLAY_PROMPT)
	       OR ((tlinfo.DISPLAY_PROMPT is null) AND (p_DISPLAY_PROMPT is null)))
      ) then
	null;
      else
	fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
	app_exception.raise_exception;
      end if;
    end if;
  end loop;

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
  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_lock_row := FND_API.G_FALSE;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
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


PROCEDURE Check_Unique
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Row_Id                    IN       VARCHAR2,
  p_Name                      IN       VARCHAR2,
  p_business_group_id         IN       NUMBER,
  p_Return_Value              IN OUT  NOCOPY   VARCHAR2
)
AS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Unique';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_tmp VARCHAR2(1);

  CURSOR c IS
    SELECT '1'
    FROM psb_attributes_VL
    WHERE name = p_name
    AND   business_group_id = p_business_group_id
    AND   ( (p_Row_Id IS NULL)
	     OR (row_id <> p_Row_Id) );
BEGIN
  --
  SAVEPOINT Check_Unique_Pvt ;
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

  -- Checking the Psb_set_relations table for references.
  OPEN c;
  FETCH c INTO l_tmp;
  --
  -- p_Return_Value tells whether references exist or not.
  IF l_tmp IS NULL THEN
    p_Return_Value := 'FALSE';
  ELSE
    p_Return_Value := 'TRUE';
  END IF;

  CLOSE c;
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
    ROLLBACK TO Check_Unique_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Check_Unique_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Check_Unique_Pvt ;
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
END Check_Unique;

PROCEDURE Check_References1
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_ATTRIBUTE_ID              IN       NUMBER,
  p_Return_Value              IN OUT  NOCOPY   VARCHAR2
)
AS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_References';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_tmp VARCHAR2(1);

  CURSOR c IS
    SELECT '1'
    FROM psb_position_assignments
    WHERE attribute_id = p_attribute_Id;

  Cursor c1 IS
   SELECT '1'
   FROM   psb_account_position_set_lines
   WHERE  attribute_id = p_attribute_Id;

BEGIN
  --
  SAVEPOINT Check_References_Pvt ;
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

  -- Checking the Psb_set_relations table for references.
  OPEN c;
  FETCH c INTO l_tmp;
  --
  -- p_Return_Value tells whether references exist or not.
  IF l_tmp IS NULL THEN
    p_Return_Value := 'FALSE';
  ELSE
    p_Return_Value := 'TRUE';
  END IF;

  CLOSE c;
  --
  -- Checking the Psb_Account_Position_Set_lines table for references.
  l_tmp := null;
  OPEN c1;
  FETCH c1 INTO l_tmp;
  --
  -- p_Return_Value tells whether references exist or not.
  IF l_tmp IS NULL THEN
    p_Return_Value := 'FALSE';
  ELSE
    p_Return_Value := 'TRUE';
  END IF;

  CLOSE c1;
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
    ROLLBACK TO Check_References_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Check_References_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Check_References_Pvt ;
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
END Check_References1;



PROCEDURE Check_References2
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_attribute_id              IN       NUMBER,
  p_Return_Value              IN OUT  NOCOPY   VARCHAR2
)
AS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_References';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_tmp VARCHAR2(1);

  CURSOR c IS
    SELECT '1'
    FROM psb_attribute_values
    WHERE attribute_id = p_attribute_Id;

BEGIN
  --
  SAVEPOINT Check_References_Pvt ;
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

  -- Checking the Psb_set_relations table for references.
  OPEN c;
  FETCH c INTO l_tmp;
  --
  -- p_Return_Value tells whether references exist or not.
  IF l_tmp IS NULL THEN
    p_Return_Value := 'FALSE';
  ELSE
    p_Return_Value := 'TRUE';
  END IF;

  CLOSE c;
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
    ROLLBACK TO Check_References_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Check_References_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Check_References_Pvt ;
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
END Check_References2;


PROCEDURE Insert_System_Attributes
(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  p_business_group_id   IN      NUMBER
)
AS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_System_Attributes';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  l_attribute_name      VARCHAR2(30);

  Temp_ID               NUMBER(20);
  Temp_Type             VARCHAR2(30);

  /* bug start 3953023 */
  Type l_sys_attributes_rec_type IS RECORD (
    l_sys_attribute_type psb_attributes.system_attribute_type%TYPE,
    l_attribute_name     psb_attributes.name%TYPE,
    l_display_worksheet  psb_attributes.DISPLAY_IN_WORKSHEET%TYPE,
    l_display_seq	 psb_attributes.DISPLAY_SEQUENCE%TYPE,
    l_req_import_flg     psb_attributes.REQUIRED_FOR_IMPORT_FLAG%TYPE,
    l_req_position_flg   psb_attributes.REQUIRED_FOR_POSITIONS_FLAG%TYPE,
    l_value_table_flg    psb_attributes.VALUE_TABLE_FLAG%TYPE,
    l_application_id     psb_attributes.APPLICATION_ID%TYPE,
    l_data_type	         psb_attributes.DATA_TYPE%TYPE,
    l_allow_pos_set_flg  psb_attributes.ALLOW_IN_POSITION_SET_FLAG%TYPE);

  -- table defenition and declaration
  Type l_sys_attributes_tbl_type IS TABLE OF
    l_sys_attributes_rec_type INDEX  BY BINARY_INTEGER;

  l_sys_attributes_tbl l_sys_attributes_tbl_type;

  -- local variables defined
  l_exists_attribute 	 BOOLEAN;
  l_rowid		 VARCHAR2(100);
  l_attribute_id	 NUMBER;
  /* bug end 3953023 */

BEGIN

  SAVEPOINT Insert_System_Attributes ;

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

  /* bug no 3953023 */
  -- load all system attributes into the record type
  -- there are 6 system defined attributes that has to be loaded

  l_sys_attributes_tbl(1).l_sys_attribute_type := 'JOB_CLASS';
  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_JOB_CLASS_NAME');
  l_sys_attributes_tbl(1).l_attribute_name     := FND_MESSAGE.get;
  l_sys_attributes_tbl(1).l_display_worksheet  := 'Y';
  l_sys_attributes_tbl(1).l_display_seq        := '1';
  l_sys_attributes_tbl(1).l_req_import_flg     := 'Y';
  l_sys_attributes_tbl(1).l_req_position_flg   := 'Y';
  l_sys_attributes_tbl(1).l_value_table_flg    := 'Y';
  l_sys_attributes_tbl(1).l_application_id     := '';
  l_sys_attributes_tbl(1).l_data_type 	       := 'C';
  l_sys_attributes_tbl(1).l_allow_pos_set_flg  := 'Y';

  -- for fte
  l_sys_attributes_tbl(2).l_sys_attribute_type := 'FTE';
  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_FTE_NAME');
  l_sys_attributes_tbl(2).l_attribute_name     := FND_MESSAGE.get;
  l_sys_attributes_tbl(2).l_display_worksheet  := 'Y';
  l_sys_attributes_tbl(2).l_display_seq        := '2';
  l_sys_attributes_tbl(2).l_req_import_flg     := 'Y';
  l_sys_attributes_tbl(2).l_req_position_flg   := 'Y';
  l_sys_attributes_tbl(2).l_value_table_flg    := 'N';
  l_sys_attributes_tbl(2).l_application_id     := '';
  l_sys_attributes_tbl(2).l_data_type 	       := 'N';
  l_sys_attributes_tbl(2).l_allow_pos_set_flg  := '';

  -- for organization
  l_sys_attributes_tbl(3).l_sys_attribute_type := 'ORG';
  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_ORGANIZATION_NAME');
  l_sys_attributes_tbl(3).l_attribute_name     := FND_MESSAGE.get;
  l_sys_attributes_tbl(3).l_display_worksheet  := 'Y';
  l_sys_attributes_tbl(3).l_display_seq        := '6';
  l_sys_attributes_tbl(3).l_req_import_flg     := '';
  l_sys_attributes_tbl(3).l_req_position_flg   := 'Y';
  l_sys_attributes_tbl(3).l_value_table_flg    := 'Y';
  l_sys_attributes_tbl(3).l_application_id     := '';
  l_sys_attributes_tbl(3).l_data_type 	       := 'C';
  l_sys_attributes_tbl(3).l_allow_pos_set_flg  := 'Y';

  -- for hire Date
  l_sys_attributes_tbl(4).l_sys_attribute_type := 'HIREDATE';
  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_HIRE_DATE_NAME');
  l_sys_attributes_tbl(4).l_attribute_name     := FND_MESSAGE.get;
  l_sys_attributes_tbl(4).l_display_worksheet  := '';
  l_sys_attributes_tbl(4).l_display_seq        := '';
  l_sys_attributes_tbl(4).l_req_import_flg     := '';
  l_sys_attributes_tbl(4).l_req_position_flg   := '';
  l_sys_attributes_tbl(4).l_value_table_flg    := '';
  l_sys_attributes_tbl(4).l_application_id     := '';
  l_sys_attributes_tbl(4).l_data_type 	       := 'D';
  l_sys_attributes_tbl(4).l_allow_pos_set_flg  := '';

  -- for adjustment date
  l_sys_attributes_tbl(5).l_sys_attribute_type := 'ADJUSTMENT_DATE';
  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_ADJUSTMENT_DATE_NAME');
  l_sys_attributes_tbl(5).l_attribute_name     := FND_MESSAGE.get;
  l_sys_attributes_tbl(5).l_display_worksheet  := '';
  l_sys_attributes_tbl(5).l_display_seq        := '';
  l_sys_attributes_tbl(5).l_req_import_flg     := '';
  l_sys_attributes_tbl(5).l_req_position_flg   := '';
  l_sys_attributes_tbl(5).l_value_table_flg    := '';
  l_sys_attributes_tbl(5).l_application_id     := '';
  l_sys_attributes_tbl(5).l_data_type 	       := 'D';
  l_sys_attributes_tbl(5).l_allow_pos_set_flg  := '';

  -- for default weekly hours
  l_sys_attributes_tbl(6).l_sys_attribute_type := 'DEFAULT_WEEKLY_HOURS';
  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_DFLT_WEEKLY_HOURS_NAME');
  l_sys_attributes_tbl(6).l_attribute_name     := FND_MESSAGE.get;
  l_sys_attributes_tbl(6).l_display_worksheet  := '';
  l_sys_attributes_tbl(6).l_display_seq        := '';
  l_sys_attributes_tbl(6).l_req_import_flg     := 'Y';
  l_sys_attributes_tbl(6).l_req_position_flg   := '';
  l_sys_attributes_tbl(6).l_value_table_flg    := '';
  l_sys_attributes_tbl(6).l_application_id     := '';
  l_sys_attributes_tbl(6).l_data_type 	       := 'N';
  l_sys_attributes_tbl(6).l_allow_pos_set_flg  := '';

  FOR l_rec IN 1..l_sys_attributes_tbl.COUNT
  LOOP
    l_exists_attribute := FALSE;
    FOR l_sys_attribute_exist IN
      (SELECT system_attribute_type,
	      attribute_id
       FROM  psb_attributes
       WHERE system_attribute_type =
              l_sys_attributes_tbl(l_rec).l_sys_attribute_type
       AND   business_group_id = p_business_group_id)
    LOOP
      --update statement as the system attribute statement already exists
      l_exists_attribute := TRUE;

      /*bug:7114143:Used 'NONE' for defintion_type instead of NULL in the update statement*/

      UPDATE psb_attributes
      SET definition_type   = 'NONE',
	  last_update_date  = sysdate,
	  last_updated_by   = 1,
	  last_update_login = null
      WHERE attribute_id = l_sys_attribute_exist.attribute_id;

    END LOOP;


    IF NOT l_exists_attribute THEN
      IF l_sys_attributes_tbl(l_rec).l_sys_attribute_type = 'ORG' THEN
        FOR l_org_rec IN
          (SELECT attribute_id
           FROM psb_attributes
           WHERE name = l_sys_attributes_tbl(l_rec).l_attribute_name
           AND business_group_id = p_business_group_id
           )
        LOOP
          -- update the psb_attributes_tl table
	  UPDATE psb_attributes_tl
	  SET name = name || '_X',
	      last_update_date = sysdate,
	      last_updated_by  = 1,
	      last_update_login = null
	  WHERE attribute_id = l_org_rec.attribute_id;
	  --
	  -- Bug#5022777 Start.
          -- update psb_attributes table also.
	  UPDATE psb_attributes
	  SET
	    name              = name || '_X'
	  , last_update_date  = SYSDATE
	  , last_updated_by   = 1
	  , last_update_login = NULL
	  WHERE
	    attribute_id = l_org_rec.attribute_id ;
	  --
	  -- Bug#5022777 End.
        END LOOP;
      END IF;

      FOR l_attribute_id_rec IN
        (SELECT psb_attributes_s.nextval attribute_id
         FROM dual)
      LOOP
        l_attribute_id := l_attribute_id_rec.attribute_id;
      END LOOP;

      PSB_POSITION_ATTRIBUTES_PVT.INSERT_ROW
      ( p_api_version 	    => 1.0,
        p_return_status     => p_return_status,
        p_msg_count 	    => l_msg_count,
        p_msg_data          => l_msg_data,
        p_row_id            => l_rowid,
        p_attribute_id      => l_attribute_id,
        p_business_group_id => p_business_group_id,
        p_name
          => l_sys_attributes_tbl(l_rec).l_attribute_name,
        p_display_in_worksheet
          => l_sys_attributes_tbl(l_rec).l_display_worksheet,
        p_display_sequence
          => l_sys_attributes_tbl(l_rec).l_display_seq,
        p_display_prompt
          => l_sys_attributes_tbl(l_rec).l_attribute_name,
        p_required_for_import_flag
          => l_sys_attributes_tbl(l_rec).L_req_import_flg,
        p_required_for_positions_flag
          => l_sys_attributes_tbl(l_rec).l_req_position_flg,
        p_allow_in_position_set_flag
          => l_sys_attributes_tbl(l_rec).l_allow_pos_set_flg,
        p_value_table_flag
          => l_sys_attributes_tbl(l_rec).l_value_table_flg,
        p_protected_flag    => null,
        p_definition_type   => 'NONE',  --bug:7114143:Passed 'NONE' instead of NULL
        p_definition_structure
          => null,
        p_definition_table  => null,
        p_definition_column => null,
        p_attribute_type_id => null,
        p_data_type
          => l_sys_attributes_tbl(l_rec).l_data_type,
        p_application_id
          => l_sys_attributes_tbl(l_rec).l_application_id,
        p_system_attribute_type
          => l_sys_attributes_tbl(l_rec).l_sys_attribute_type,
        p_last_update_date  => sysdate,
        p_last_updated_by   => 1,
        p_last_update_login => null,
        p_created_by        => 1,
        p_creation_date     => sysdate
       );

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;
  END LOOP;

  /* bug end 3953023 */

  /* bug start 3953023 */
  -- Commenting this piece of code as the code above
  -- takes care of inserting system attributes by calling
  -- INSERT_ROW api.

  /*Begin

  Temp_ID := Null;
  Temp_Type := '';

  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_JOB_CLASS_NAME');
  l_attribute_name := FND_MESSAGE.Get ;

   Begin
    select SYSTEM_ATTRIBUTE_TYPE,
	   ATTRIBUTE_ID
      into Temp_Type
	 , Temp_ID
      from PSB_ATTRIBUTES
     where SYSTEM_ATTRIBUTE_TYPE = 'JOB_CLASS'
       and BUSINESS_GROUP_ID     = p_business_group_id;
   Exception
	When NO_DATA_FOUND then
	  Temp_Type := '';
	  Temp_ID := NULL;
   End;

  if (nvl(Temp_Type,'NULL') <> 'JOB_CLASS') then

    select psb_attributes_s.nextval
      into Temp_ID
      from dual;

    INSERT INTO PSB_ATTRIBUTES (
	ATTRIBUTE_ID,
	BUSINESS_GROUP_ID,
	NAME,
	DISPLAY_IN_WORKSHEET,
	DISPLAY_SEQUENCE,
	DISPLAY_PROMPT,
	REQUIRED_FOR_IMPORT_FLAG,
	REQUIRED_FOR_POSITIONS_FLAG,
	VALUE_TABLE_FLAG,
	APPLICATION_ID,
	DATA_TYPE,
	SYSTEM_ATTRIBUTE_TYPE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE,
	ALLOW_IN_POSITION_SET_FLAG)
    VALUES (
	Temp_ID,
	p_business_group_id,
	l_attribute_name,
	'Y',
	1,
	l_attribute_name,
	'Y',
	'Y',
	'Y',
	NULL,
	'C',
	'JOB_CLASS',
	sysdate,
	1,
	NULL,
	1,
	sysdate,
	'Y'
	);

    INSERT INTO PSB_ATTRIBUTES_TL(
	ATTRIBUTE_ID,
	NAME,
	DISPLAY_PROMPT,
	LANGUAGE,
	SOURCE_LANG,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE)
    VALUES (
	Temp_ID,
	l_attribute_name,
	l_attribute_name,
--Bug No 2740368 Start
--	'US',
--	userenv('LANG'),
-- Bug No 2740368 End
	'US',
	sysdate,
	1,
	NULL,
	1,
	sysdate
	);
  else
     Update psb_attributes
	set definition_type   = 'NONE'   --bug:7114143:Passed 'NONE' instead of NULL.
	  , last_update_date  = sysdate
	  , last_updated_by   = 1
	  , last_update_login = null
      where attribute_id = Temp_ID;

  end if;
  End;


  Begin

  Temp_ID := Null;
  Temp_Type := '';

  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_FTE_NAME');
  l_attribute_name := FND_MESSAGE.Get ;

  Begin
    select SYSTEM_ATTRIBUTE_TYPE
	 , ATTRIBUTE_ID
      into Temp_Type
	 , Temp_ID
      from PSB_ATTRIBUTES
     where SYSTEM_ATTRIBUTE_TYPE = 'FTE'
       and BUSINESS_GROUP_ID     = p_business_group_id;
   Exception
	When NO_DATA_FOUND then
	  Temp_Type := '';
	  Temp_ID := NULL;
   End;

  if (nvl(Temp_Type, 'NULL') <> 'FTE') then
    select psb_attributes_s.nextval
      into Temp_ID
      from dual;

  INSERT INTO PSB_ATTRIBUTES (
	ATTRIBUTE_ID,
	BUSINESS_GROUP_ID,
	NAME,
	DISPLAY_IN_WORKSHEET,
	DISPLAY_SEQUENCE,
	DISPLAY_PROMPT,
	REQUIRED_FOR_IMPORT_FLAG,
	REQUIRED_FOR_POSITIONS_FLAG,
	VALUE_TABLE_FLAG,
	APPLICATION_ID,
	DATA_TYPE,
	SYSTEM_ATTRIBUTE_TYPE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE,
	ALLOW_IN_POSITION_SET_FLAG)
  VALUES (
	Temp_ID,
	p_business_group_id,
	l_attribute_name,
	'Y',
	2,
	l_attribute_name,
-- Bug No 2549894 Start
--	NULL,
--	'Y',
-- Bug No 2549894 End
	'Y',
	'N',
	NULL,
	'N',
	'FTE',
	sysdate,
	1,
	NULL,
	1,
	sysdate,
	NULL
	);

    INSERT INTO PSB_ATTRIBUTES_TL(
	ATTRIBUTE_ID,
	NAME,
	DISPLAY_PROMPT,
	LANGUAGE,
	SOURCE_LANG,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE)
    VALUES (
	Temp_ID,
	l_attribute_name,
	l_attribute_name,
-- Bug No 2740368 Start
--	'US',
--	userenv('LANG'),
-- Bug No 2740368 End
	'US',
	sysdate,
	1,
	NULL,
	1,
	sysdate
	);
  else
     Update psb_attributes
	set definition_type   = 'NONE'  --bug:7114143:Passed 'NONE' instead of NULL.
	  , last_update_date  = sysdate
	  , last_updated_by   = 1
	  , last_update_login = null
      where attribute_id = Temp_ID;
  end if;
  End;

  Begin

  Temp_ID := Null;
  Temp_Type := '';

  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_ORGANIZATION_NAME');
  l_attribute_name := FND_MESSAGE.Get ;

  Begin
    select SYSTEM_ATTRIBUTE_TYPE
	 , ATTRIBUTE_ID
      into Temp_Type
	 , Temp_ID
      from PSB_ATTRIBUTES
     where SYSTEM_ATTRIBUTE_TYPE = 'ORG'
       and BUSINESS_GROUP_ID     = p_business_group_id;
   Exception
	When NO_DATA_FOUND then
	  Temp_Type := '';
	  Temp_ID := NULL;
   End;

  if (nvl(Temp_Type, 'NULL') <> 'ORG') then

     For C_org_rec in
	 ( Select attribute_id
	     From psb_attributes
	    where upper(name) = upper(l_attribute_name)
	      and business_group_id = p_business_group_id
	 )
     Loop
	update psb_attributes
	   set name = name || '_X'
	     , last_update_date = sysdate
	     , last_updated_by  = 1
	     , last_update_login = null
	 where attribute_id = c_org_rec.attribute_id;

	update psb_attributes_tl
	   set name = name || '_X'
	     , last_update_date = sysdate
	     , last_updated_by  = 1
	     , last_update_login = null
	 where attribute_id = c_org_rec.attribute_id;
     End Loop;

    select psb_attributes_s.nextval
      into Temp_ID
      from dual;

  INSERT INTO PSB_ATTRIBUTES (
	ATTRIBUTE_ID,
	BUSINESS_GROUP_ID,
	NAME,
	DISPLAY_IN_WORKSHEET,
	DISPLAY_SEQUENCE,
	DISPLAY_PROMPT,
	REQUIRED_FOR_IMPORT_FLAG,
	REQUIRED_FOR_POSITIONS_FLAG,
	VALUE_TABLE_FLAG,
	APPLICATION_ID,
	DATA_TYPE,
	SYSTEM_ATTRIBUTE_TYPE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE,
	ALLOW_IN_POSITION_SET_FLAG)
  VALUES (
	Temp_ID,
	p_business_group_id,
	l_attribute_name,
	'Y',
	6,
	l_attribute_name,
	NULL,
	'Y',
	'Y',
	NULL,
	'C',
	'ORG',
	sysdate,
	1,
	NULL,
	1,
	sysdate,
-- Bug No 2549894 Start
--	NULL,
--	'Y'
-- Bug No 2549894 End
	);

    INSERT INTO PSB_ATTRIBUTES_TL(
	ATTRIBUTE_ID,
	NAME,
	DISPLAY_PROMPT,
	LANGUAGE,
	SOURCE_LANG,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE)
    VALUES (
	Temp_ID,
	l_attribute_name,
	l_attribute_name,
-- Bug No 2740368 Start
--	'US',
--	userenv('LANG'),
-- Bug No 2740368 End
	'US',
	sysdate,
	1,
	NULL,
	1,
	sysdate
	);
  else
     Update psb_attributes
	set definition_type   = 'NONE'   --bug:7114143:Passed 'NONE' instead of NULL.
	  , last_update_date  = sysdate
	  , last_updated_by   = 1
	  , last_update_login = null
      where attribute_id = Temp_ID;
  end if;
  End;

  Begin

  Temp_ID := Null;
  Temp_Type := '';

  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_HIRE_DATE_NAME');
  l_attribute_name := FND_MESSAGE.Get ;

  Begin
    select SYSTEM_ATTRIBUTE_TYPE
	 , ATTRIBUTE_ID
      into Temp_Type
	 , Temp_ID
      from PSB_ATTRIBUTES
     where SYSTEM_ATTRIBUTE_TYPE = 'HIREDATE'
       and BUSINESS_GROUP_ID     = p_business_group_id;
   Exception
	When NO_DATA_FOUND then
	  Temp_Type := '';
	  Temp_ID   := NULL;
   End;

  if (nvl(Temp_Type, 'NULL') <> 'HIREDATE') then
    select psb_attributes_s.nextval
      into Temp_ID
      from dual;


  INSERT INTO PSB_ATTRIBUTES (
	ATTRIBUTE_ID,
	BUSINESS_GROUP_ID,
	NAME,
	DISPLAY_IN_WORKSHEET,
	DISPLAY_SEQUENCE,
	DISPLAY_PROMPT,
	REQUIRED_FOR_IMPORT_FLAG,
	REQUIRED_FOR_POSITIONS_FLAG,
	VALUE_TABLE_FLAG,
	APPLICATION_ID,
	DATA_TYPE,
	SYSTEM_ATTRIBUTE_TYPE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE,
	ALLOW_IN_POSITION_SET_FLAG)
  VALUES (
	Temp_ID,
	p_business_group_id,
	l_attribute_name,
	NULL,
	NULL,
	l_attribute_name,
	NULL,
	NULL,
	NULL,
	NULL,
	'D',
	'HIREDATE',
	sysdate,
	1,
	NULL,
	1,
	sysdate,
	NULL
	);

    INSERT INTO PSB_ATTRIBUTES_TL(
	ATTRIBUTE_ID,
	NAME,
	DISPLAY_PROMPT,
	LANGUAGE,
	SOURCE_LANG,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE)
    VALUES (
	Temp_ID,
	l_attribute_name,
	l_attribute_name,
-- Bug No 2740368 Start
--	'US',
--	userenv('LANG'),
-- Bug No 2740368 End
	'US',
	sysdate,
	1,
	NULL,
	1,
	sysdate
	);
  else
     Update psb_attributes
	set definition_type   = 'NONE'  --bug:7114143:Passed 'NONE' instead of NULL.
	  , last_update_date  = sysdate
	  , last_updated_by   = 1
	  , last_update_login = null
      where attribute_id = Temp_ID;
  end if;
  End;


  Begin

  Temp_ID := Null;
  Temp_Type := '';

  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_ADJUSTMENT_DATE_NAME');
  l_attribute_name := FND_MESSAGE.Get ;

  Begin
    select SYSTEM_ATTRIBUTE_TYPE
      into Temp_Type
      from PSB_ATTRIBUTES
     where SYSTEM_ATTRIBUTE_TYPE = 'ADJUSTMENT_DATE'
       and BUSINESS_GROUP_ID     = p_business_group_id;
   Exception
	When NO_DATA_FOUND then
	  Temp_Type := '';
   End;

  if (nvl(Temp_Type, 'NULL') <> 'ADJUSTMENT_DATE') then
    select psb_attributes_s.nextval
      into Temp_ID
      from dual;


  INSERT INTO PSB_ATTRIBUTES (
	ATTRIBUTE_ID,
	BUSINESS_GROUP_ID,
	NAME,
	DISPLAY_IN_WORKSHEET,
	DISPLAY_SEQUENCE,
	DISPLAY_PROMPT,
	REQUIRED_FOR_IMPORT_FLAG,
	REQUIRED_FOR_POSITIONS_FLAG,
	VALUE_TABLE_FLAG,
	APPLICATION_ID,
	DATA_TYPE,
	SYSTEM_ATTRIBUTE_TYPE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE,
	ALLOW_IN_POSITION_SET_FLAG)
  VALUES (
	Temp_ID,
	p_business_group_id,
	l_attribute_name,
	NULL,
	NULL,
	l_attribute_name,
	NULL,
	NULL,
	NULL,
	NULL,
	'D',
	'ADJUSTMENT_DATE',
	sysdate,
	1,
	NULL,
	1,
	sysdate,
	NULL
	);

    INSERT INTO PSB_ATTRIBUTES_TL(
	ATTRIBUTE_ID,
	NAME,
	DISPLAY_PROMPT,
	LANGUAGE,
	SOURCE_LANG,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE)
    VALUES (
	Temp_ID,
	l_attribute_name,
	l_attribute_name,
-- Bug No 2740368 Start
--	'US',
--	userenv('LANG'),
-- Bug No 2740368 End
	'US',
	sysdate,
	1,
	NULL,
	1,
	sysdate
	);

  end if;
  End;


  Begin

  Temp_ID := Null;
  Temp_Type := '';

  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_DFLT_WEEKLY_HOURS_NAME');
  l_attribute_name := FND_MESSAGE.Get ;

  Begin
    select SYSTEM_ATTRIBUTE_TYPE
	 , ATTRIBUTE_ID
      into Temp_Type
	 , Temp_ID
      from PSB_ATTRIBUTES
     where SYSTEM_ATTRIBUTE_TYPE = 'DEFAULT_WEEKLY_HOURS'
       and BUSINESS_GROUP_ID     = p_business_group_id;
   Exception
	When NO_DATA_FOUND then
	  Temp_Type := '';
	  Temp_ID   := NULL;
   End;

  if (nvl(Temp_Type, 'NULL') <> 'DEFAULT_WEEKLY_HOURS') then
    select psb_attributes_s.nextval
      into Temp_ID
      from dual;


  INSERT INTO PSB_ATTRIBUTES (
	ATTRIBUTE_ID,
	BUSINESS_GROUP_ID,
	NAME,
	DISPLAY_IN_WORKSHEET,
	DISPLAY_SEQUENCE,
	DISPLAY_PROMPT,
	REQUIRED_FOR_IMPORT_FLAG,
	REQUIRED_FOR_POSITIONS_FLAG,
	VALUE_TABLE_FLAG,
	APPLICATION_ID,
	DATA_TYPE,
	SYSTEM_ATTRIBUTE_TYPE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE,
	ALLOW_IN_POSITION_SET_FLAG)
  VALUES (
	Temp_ID,
	p_business_group_id,
	l_attribute_name,
	NULL,
	NULL,
	l_attribute_name,
-- Bug No 2549894 Start
--	NULL,
--	'Y',
-- Bug No 2549894 End
	NULL,
	NULL,
	NULL,
	'N',
	'DEFAULT_WEEKLY_HOURS',
	sysdate,
	1,
	NULL,
	1,
	sysdate,
	NULL
	);

    INSERT INTO PSB_ATTRIBUTES_TL(
	ATTRIBUTE_ID,
	NAME,
	DISPLAY_PROMPT,
	LANGUAGE,
	SOURCE_LANG,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE)
    VALUES (
	Temp_ID,
	l_attribute_name,
	l_attribute_name,
-- Bug No 2740368 Start
--	'US',
--	userenv('LANG'),
-- Bug No 2740368 End
	'US',
	sysdate,
	1,
	NULL,
	1,
	sysdate
	);
  else
     Update psb_attributes
	set definition_type   = 'NONE'  --bug:7114143:Passed 'NONE' instead of NULL.
	  , last_update_date  = sysdate
	  , last_updated_by   = 1
	  , last_update_login = null
      where attribute_id = Temp_ID;
  end if;
  End;*/
  -- The code comment ends here

  /* bug end 3953023 */

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
    ROLLBACK TO Insert_System_Attributes ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Insert_System_Attributes ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Insert_System_Attributes ;
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
END Insert_System_Attributes ;

FUNCTION GET_TRANSLATED_NAME(p_sys_attribute_type IN varchar2)
RETURN varchar2 IS
l_attribute_name varchar2(2000);
BEGIN
  IF p_sys_attribute_type = 'JOB_CLASS' THEN
  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_JOB_CLASS_NAME');
  l_attribute_name     := FND_MESSAGE.get;
  ELSIF
  -- for fte
  p_sys_attribute_type = 'FTE' THEN
  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_FTE_NAME');
  l_attribute_name     := FND_MESSAGE.get;

  ELSIF
  -- for organization
  p_sys_attribute_type = 'ORG' THEN
  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_ORGANIZATION_NAME');
  l_attribute_name     := FND_MESSAGE.get;

  ELSIF
  -- for hire Date
  p_sys_attribute_type = 'HIREDATE' THEN
  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_HIRE_DATE_NAME');
  l_attribute_name     := FND_MESSAGE.get;

  ELSIF
  -- for adjustment date
  p_sys_attribute_type = 'ADJUSTMENT_DATE' THEN
  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_ADJUSTMENT_DATE_NAME');
  l_attribute_name     := FND_MESSAGE.get;

  ELSIF
  -- for default weekly hours
  p_sys_attribute_type = 'DEFAULT_WEEKLY_HOURS' THEN
  FND_MESSAGE.Set_Name('PSB', 'PSB_PAT_DFLT_WEEKLY_HOURS_NAME');
  l_attribute_name     := FND_MESSAGE.get;
  END IF;

RETURN l_attribute_name;
END GET_TRANSLATED_NAME;

procedure ADD_LANGUAGE
is
begin
  delete from PSB_ATTRIBUTES_TL T
  where not exists
    (select NULL
    from PSB_ATTRIBUTES B
    where B.ATTRIBUTE_ID = T.ATTRIBUTE_ID
    );

  update PSB_ATTRIBUTES_TL T set (
      NAME
    ) = (select
      B.NAME
    from PSB_ATTRIBUTES_TL B
    where B.ATTRIBUTE_ID = T.ATTRIBUTE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ATTRIBUTE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ATTRIBUTE_ID,
      SUBT.LANGUAGE
    from PSB_ATTRIBUTES_TL SUBB, PSB_ATTRIBUTES_TL SUBT
    where SUBB.ATTRIBUTE_ID = SUBT.ATTRIBUTE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

 /*Bug#5237452. Added a new method to translate the name
   as per the session language. Also modified the sql to
   insert data for only the current session language */

  insert into PSB_ATTRIBUTES_TL (
    ATTRIBUTE_ID,
    NAME,
/* Bug No 2777757 Start */
    DISPLAY_PROMPT,
/* Bug No 2777757 End */
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ATTRIBUTE_ID,
    NVL(PSB_POSITION_ATTRIBUTES_PVT.get_translated_name(
                                         S.SYSTEM_ATTRIBUTE_TYPE),B.NAME),
    NVL(PSB_POSITION_ATTRIBUTES_PVT.get_translated_name(
                                   S.SYSTEM_ATTRIBUTE_TYPE),B.DISPLAY_PROMPT),
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    USERENV('LANG'),
    USERENV('LANG')
  from PSB_ATTRIBUTES_TL B, FND_LANGUAGES L,PSB_ATTRIBUTES S
  where L.INSTALLED_FLAG = 'B'
  and B.LANGUAGE = L.LANGUAGE_CODE
  and S.attribute_id=B.attribute_id
  and not exists
    (select NULL
    from PSB_ATTRIBUTES_TL T
    where T.ATTRIBUTE_ID = B.ATTRIBUTE_ID
    and T.LANGUAGE = USERENV('LANG'));
end ADD_LANGUAGE;

END PSB_POSITION_ATTRIBUTES_PVT;

/
