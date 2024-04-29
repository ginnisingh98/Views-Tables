--------------------------------------------------------
--  DDL for Package Body PSB_DEFAULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_DEFAULTS_PVT" AS
/* $Header: PSBVPDFB.pls 120.3 2004/11/30 14:18:26 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_DEFAULTS_PVT';

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
  P_ROW_ID                           IN OUT  NOCOPY  VARCHAR2,
  P_DEFAULT_RULE_ID                  in      NUMBER,
  P_NAME                             in      VARCHAR2,
  P_GLOBAL_DEFAULT_FLAG              IN      VARCHAR2,
  P_DATA_EXTRACT_ID                  IN      NUMBER,
  P_BUSINESS_GROUP_ID                IN      NUMBER,
  P_ENTITY_ID                        IN      NUMBER,
  P_PRIORITY                         IN      NUMBER,
  P_CREATION_DATE                    in      DATE,
  P_CREATED_BY                       in      NUMBER,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER,
  /* Bug 1308558 Start */
  P_OVERWRITE                        IN      VARCHAR2 DEFAULT NULL
  /* Bug 1308558 End */
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'INSERT_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_row_id              varchar2(40);
  --
  cursor c1 is
     select ROWID from psb_defaults
     where default_rule_id = p_default_rule_id;

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
  INSERT INTO psb_defaults
  (
  DEFAULT_RULE_ID                  ,
  NAME                             ,
  GLOBAL_DEFAULT_FLAG              ,
  DATA_EXTRACT_ID                  ,
  BUSINESS_GROUP_ID                ,
  ENTITY_ID                        ,
  PRIORITY                         ,
  CREATION_DATE                    ,
  CREATED_BY                       ,
  LAST_UPDATE_DATE                 ,
  LAST_UPDATED_BY                  ,
  LAST_UPDATE_LOGIN                ,
  /* Bug 1308558 Start */
  OVERWRITE
  )
  VALUES
  (
  P_DEFAULT_RULE_ID                  ,
  P_NAME                             ,
  P_GLOBAL_DEFAULT_FLAG              ,
  P_DATA_EXTRACT_ID                  ,
  P_BUSINESS_GROUP_ID                ,
  P_ENTITY_ID                        ,
  P_PRIORITY                         ,
  P_CREATION_DATE                    ,
  P_CREATED_BY                       ,
  P_LAST_UPDATE_DATE                 ,
  P_LAST_UPDATED_BY                  ,
  P_LAST_UPDATE_LOGIN                ,
  P_OVERWRITE
  );

  open c1;
  fetch c1 into P_ROW_ID;
  if (c1%notfound) then
    close c1;

    FND_MESSAGE.Set_Name('PSB', 'PSB_NO_DATA_FOUND');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
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
  P_ROW_ID                           IN      VARCHAR2,
  P_DEFAULT_RULE_ID                  in      NUMBER,
  P_NAME                             in      VARCHAR2,
  P_GLOBAL_DEFAULT_FLAG              IN      VARCHAR2,
  P_DATA_EXTRACT_ID                  IN      NUMBER,
  P_BUSINESS_GROUP_ID                IN      NUMBER,
  P_ENTITY_ID                        IN      NUMBER,
  P_PRIORITY                         IN      NUMBER,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER,
  /* Bug 1308558 Start */
  P_OVERWRITE                        IN      VARCHAR2 DEFAULT NULL
  /* Bug 1308558 End */
) IS

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
  UPDATE psb_defaults SET
  DEFAULT_RULE_ID                 =  P_DEFAULT_RULE_ID,
  NAME                            =  P_NAME,
  GLOBAL_DEFAULT_FLAG             =  P_GLOBAL_DEFAULT_FLAG,
  DATA_EXTRACT_ID                 =  P_DATA_EXTRACT_ID,
  BUSINESS_GROUP_ID               =  P_BUSINESS_GROUP_ID,
  ENTITY_ID                       =  P_ENTITY_ID,
  PRIORITY                        =  P_PRIORITY,
  LAST_UPDATE_DATE                =  P_LAST_UPDATE_DATE,
  LAST_UPDATED_BY                 =  P_LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN               =  P_LAST_UPDATE_LOGIN,
  /* Bug 1308558 Start */
  OVERWRITE                       =  P_OVERWRITE
  /* Bug 1308558 End */

  WHERE rowid = p_row_id;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
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
( p_api_version         IN           NUMBER,
  p_init_msg_list       IN           VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN           VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN           NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  --
  P_DEFAULT_RULE_ID     IN           NUMBER,
  P_ENTITY_ID           IN           NUMBER,
  /* Bug 1308558 Start */
  P_SOURCE_FORM         IN           VARCHAR2 DEFAULT NULL
  /* Bug 1308558 End */

) IS

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

 /* Bug 1308558 Start */
 -- We need to conditionally delete the master record for
 -- the existing records before to enhancement..
 -- The p_overwrite flag value will be null for these records.

 IF NVL(P_source_form, 'X') = 'D' THEN
   --Deleting detail recordS to maintain the isolated delete
   --relation between the master and detail

   DELETE FROM psb_default_assignments
   WHERE default_rule_id = p_default_rule_id;

   DELETE FROM psb_default_account_distrs
   WHERE default_rule_id = p_default_rule_id;

   -- Check the existence of Non FTE record.
   DELETE FROM psb_defaults
   WHERE default_rule_id = p_default_rule_id
   AND NOT EXISTS(
                  SELECT 1
                  FROM PSB_FTE_RULES_V
                  WHERE default_rule_id = p_default_rule_id
                 );
 ELSE
   DELETE FROM psb_entity
   WHERE entity_id = p_entity_id;

   DELETE FROM psb_allocrule_percents
   WHERE allocation_rule_id = p_entity_id;

   IF NVL(P_source_form, 'X') = 'F' THEN
     -- Check the existence of FTE record.
     DELETE FROM psb_defaults
     WHERE default_rule_id = p_default_rule_id
     AND NOT EXISTS(
                    SELECT 1
                    FROM PSB_NON_FTE_RULES_V
                    WHERE default_rule_id = p_default_rule_id
                   );
   ELSE
     --Deleting detail recordS to maintain the isolated delete
     --relation between the master and detail

     DELETE FROM psb_default_assignments
     WHERE default_rule_id = p_default_rule_id;

     DELETE FROM psb_default_account_distrs
     WHERE default_rule_id = p_default_rule_id;

     DELETE FROM psb_defaults
     WHERE default_rule_id = p_default_rule_id;
   END IF;
  /*IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
   END IF;*/
 END IF;
 /* Bug 1308558 End */

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
  p_row_locked                  OUT  NOCOPY     VARCHAR2,
  --
  P_ROW_ID                           IN      VARCHAR2,
  P_DEFAULT_RULE_ID                  in      NUMBER,
  P_NAME                             in      VARCHAR2,
  P_GLOBAL_DEFAULT_FLAG              IN      VARCHAR2,
  P_DATA_EXTRACT_ID                  IN      NUMBER,
  P_BUSINESS_GROUP_ID                IN      NUMBER,
  P_ENTITY_ID                        IN      NUMBER,
  P_PRIORITY                         IN      NUMBER,
  /* Bug 1308558 Start */
  P_OVERWRITE                        IN      VARCHAR2 DEFAULT NULL,
  P_SOURCE_FORM                      IN      VARCHAR2 DEFAULT 'F'
  /* Bug 1308558 End */
  ) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'LOCK_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;
  --
  counter number;

  CURSOR C IS SELECT * FROM psb_defaults
  WHERE rowid = p_row_id
  FOR UPDATE of default_rule_id NOWAIT;
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
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  /* Bug 1308558 End */

  IF NVL(p_source_form, 'F') = 'D' THEN
    -- For Non FTE records
    IF
    (
	 (Recinfo.default_rule_id =  p_default_rule_id)
          AND (Recinfo.name = p_name)
	  AND ( (Recinfo.global_default_flag =  p_global_default_flag)
		 OR ( (Recinfo.global_default_flag IS NULL)
		       AND (p_global_default_flag IS NULL)))
	  AND ( (Recinfo.data_extract_id =  p_data_extract_id)
		 OR ( (Recinfo.data_extract_id IS NULL)
		       AND (p_data_extract_id IS NULL)))
	  AND ( (Recinfo.business_group_id =  p_business_group_id)
		 OR ( (Recinfo.business_group_id IS NULL)
		       AND (p_business_group_id IS NULL)))
          AND ( (Recinfo.entity_id =  p_entity_id)
		 OR ( (Recinfo.entity_id IS NULL)
		       AND (p_entity_id IS NULL)))
	  AND ( (Recinfo.priority =  p_priority)
		 OR ( (Recinfo.priority IS NULL)
		       AND (p_priority IS NULL)))
	  AND ( (Recinfo.overwrite =  p_overwrite)
		 OR ( (Recinfo.overwrite IS NULL)
		       AND (p_overwrite IS NULL)))
     )

    THEN
      Null;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
  ELSE
    -- For FTE records
    IF
    (
	 (Recinfo.default_rule_id =  p_default_rule_id)
	  AND (Recinfo.name = p_name)
	  AND ( (Recinfo.global_default_flag =  p_global_default_flag)
		 OR ( (Recinfo.global_default_flag IS NULL)
		       AND (p_global_default_flag IS NULL)))
	  AND ( (Recinfo.data_extract_id =  p_data_extract_id)
		 OR ( (Recinfo.data_extract_id IS NULL)
		       AND (p_data_extract_id IS NULL)))
	  AND ( (Recinfo.business_group_id =  p_business_group_id)
		 OR ( (Recinfo.business_group_id IS NULL)
		       AND (p_business_group_id IS NULL)))
          AND ( (Recinfo.entity_id =  p_entity_id)
		 OR ( (Recinfo.entity_id IS NULL)
		       AND (p_entity_id IS NULL)))
	  AND ( (Recinfo.priority =  p_priority)
		 OR ( (Recinfo.priority IS NULL)
		       AND (p_priority IS NULL)))
     )

    THEN
      Null;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    /* Bug 1308558 End */
  END IF;

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
    p_row_locked := FND_API.G_FALSE;
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
END LOCK_ROW;


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
  P_DEFAULT_RULE_ID                  in      NUMBER,
  P_NAME                             IN      VARCHAR2,
  P_DATA_EXTRACT_ID                  IN      NUMBER,
  P_RETURN_VALUE                     IN OUT  NOCOPY  VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Unique';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_tmp VARCHAR2(1);

  CURSOR c IS
    SELECT '1'
    FROM psb_defaults
    WHERE name = p_name
    AND   ( (p_default_rule_id IS NULL)
	     OR ( default_rule_id <> p_default_rule_id) )
    AND   (data_extract_id = p_data_extract_id);


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

  -- Checking the psb_defaults table for uniqueness.
  OPEN c;
  FETCH c INTO l_tmp;

  --
  -- p_Return_Value tells whether references exist or not.
  IF (l_tmp IS NULL)  THEN
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

PROCEDURE Check_Global_Default
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  P_ROW_ID                    IN       VARCHAR2,
  P_DATA_EXTRACT_ID           IN       NUMBER,
  P_GLOBAL_DEFAULT_FLAG       IN       VARCHAR2,
  P_RETURN_VALUE              IN OUT  NOCOPY   VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Global_Default';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_tmp varchar2(10);

  CURSOR c IS
    SELECT (1)
    FROM psb_defaults
    WHERE data_extract_id     = p_data_extract_id
    AND   global_default_flag = p_global_default_flag
    AND   ( (p_row_id IS NULL)
	     OR ( rowid <> p_row_id) );


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

  -- Checking the psb_defaults table for uniqueness.
  OPEN c;
  FETCH c INTO l_tmp;

  --
  -- p_Return_Value tells whether references exist or not.
  IF ( l_tmp IS NOT NULL)  THEN
    P_Return_Value := 'TRUE';
  ELSE
    P_Return_Value := 'FALSE';
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
END Check_Global_Default;


PROCEDURE Check_References
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  P_DEFAULT_RULE_ID                  in      NUMBER,
  P_NAME                             in      VARCHAR2,
  p_Return_Value                     IN OUT  NOCOPY  VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_References';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_tmp VARCHAR2(1);
  l_tmp1 varchar2(1);

  CURSOR c IS
    SELECT '1'
    FROM psb_position_assignments pa, psb_position_pay_distributions ppd
    WHERE pa.assignment_default_rule_id = p_default_rule_id
    OR ppd.distribution_default_rule_id = p_default_rule_id;


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
  IF (l_tmp IS NULL)  THEN
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
END Check_References;


END PSB_DEFAULTS_PVT;

/
