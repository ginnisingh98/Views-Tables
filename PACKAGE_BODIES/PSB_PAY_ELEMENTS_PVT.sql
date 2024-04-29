--------------------------------------------------------
--  DDL for Package Body PSB_PAY_ELEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_PAY_ELEMENTS_PVT" AS
/* $Header: PSBVELMB.pls 120.2 2005/03/12 13:06:06 matthoma ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_PAY_ELEMENTS_PVT';
  g_dbug                VARCHAR2(2000);
  g_entity_set_id       NUMBER;
  -- The flag determines whether to print debug information or not.
  g_debug_flag          VARCHAR2(1) := 'N' ;

/* ---------------------- Private Procedures  -----------------------*/

  PROCEDURE  debug
  (
    p_message                   IN       VARCHAR2
  ) ;
/* ----------------------------------------------------------------------- */

PROCEDURE Insert_Row
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_ROW_ID                           in OUT  NOCOPY  VARCHAR2,
  P_PAY_ELEMENT_ID                   in      NUMBER,
  P_BUSINESS_GROUP_ID                in      NUMBER,
  P_DATA_EXTRACT_ID                  in      NUMBER,
  p_BUDGET_SET_ID                    in      NUMBER := FND_API.G_MISS_NUM,
  P_NAME                             in      VARCHAR2,
  P_DESCRIPTION                      in      VARCHAR2,
  P_ELEMENT_VALUE_TYPE               in      VARCHAR2,
  P_FORMULA_ID                       in      NUMBER,
  P_OVERWRITE_FLAG                   in      VARCHAR2,
  P_REQUIRED_FLAG                    in      VARCHAR2,
  P_FOLLOW_SALARY                    in      VARCHAR2,
  P_PAY_BASIS                        IN      VARCHAR2,
  P_START_DATE                       in      DATE,
  P_END_DATE                         in      DATE,
  P_PROCESSING_TYPE                  in      VARCHAR2,
  P_PERIOD_TYPE                      in      VARCHAR2,
  P_PROCESS_PERIOD_TYPE              in      VARCHAR2,
  P_MAX_ELEMENT_VALUE_TYPE           in      VARCHAR2,
  P_MAX_ELEMENT_VALUE                in      NUMBER,
  P_SALARY_FLAG                      in      VARCHAR2,
  P_SALARY_TYPE                      in      VARCHAR2,
  P_OPTION_FLAG                      in      VARCHAR2,
  P_HR_ELEMENT_TYPE_ID               in      NUMBER,
  P_ATTRIBUTE_CATEGORY               in      VARCHAR2,
  P_ATTRIBUTE1                       in      VARCHAR2,
  P_ATTRIBUTE2                       in      VARCHAR2,
  P_ATTRIBUTE3                       in      VARCHAR2,
  P_ATTRIBUTE4                       in      VARCHAR2,
  P_ATTRIBUTE5                       in      VARCHAR2,
  P_ATTRIBUTE6                       in      VARCHAR2,
  P_ATTRIBUTE7                       in      VARCHAR2,
  P_ATTRIBUTE8                       in      VARCHAR2,
  P_ATTRIBUTE9                       in      VARCHAR2,
  P_ATTRIBUTE10                      in      VARCHAR2,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER,
  P_CREATED_BY                       in      NUMBER,
  P_CREATION_DATE                    in      DATE
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         := 1.0;
  --
  cursor c1 is
     select ROWID from psb_pay_elements
     where pay_element_id = p_pay_element_id;

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
  INSERT INTO psb_pay_elements
  (
 PAY_ELEMENT_ID                 ,
 BUSINESS_GROUP_ID              ,
 DATA_EXTRACT_ID                ,
 BUDGET_SET_ID                  ,
 NAME                           ,
 DESCRIPTION                    ,
 ELEMENT_VALUE_TYPE             ,
 FORMULA_ID                     ,
 OVERWRITE_FLAG                 ,
 REQUIRED_FLAG                  ,
 FOLLOW_SALARY                  ,
 PAY_BASIS                      ,
 START_DATE                     ,
 END_DATE                       ,
 PROCESSING_TYPE                ,
 PERIOD_TYPE                    ,
 PROCESS_PERIOD_TYPE            ,
 MAX_ELEMENT_VALUE_TYPE         ,
 MAX_ELEMENT_VALUE              ,
 SALARY_FLAG                    ,
 SALARY_TYPE                    ,
 OPTION_FLAG                    ,
 HR_ELEMENT_TYPE_ID             ,
 ATTRIBUTE_CATEGORY             ,
 ATTRIBUTE1                     ,
 ATTRIBUTE2                     ,
 ATTRIBUTE3                     ,
 ATTRIBUTE4                     ,
 ATTRIBUTE5                     ,
 ATTRIBUTE6                     ,
 ATTRIBUTE7                     ,
 ATTRIBUTE8                     ,
 ATTRIBUTE9                     ,
 ATTRIBUTE10                    ,
 LAST_UPDATE_DATE               ,
 LAST_UPDATED_BY                ,
 LAST_UPDATE_LOGIN              ,
 CREATED_BY                     ,
 CREATION_DATE

  )
  VALUES
  (
 P_PAY_ELEMENT_ID              ,
 P_BUSINESS_GROUP_ID              ,
 P_DATA_EXTRACT_ID                ,
 decode(P_BUDGET_SET_ID, FND_API.G_MISS_NUM,null,P_BUDGET_SET_ID)    ,
 P_NAME                           ,
 P_DESCRIPTION                    ,
 P_ELEMENT_VALUE_TYPE             ,
 P_FORMULA_ID                     ,
 P_OVERWRITE_FLAG                 ,
 P_REQUIRED_FLAG                  ,
 P_FOLLOW_SALARY                  ,
 P_PAY_BASIS                      ,
 P_START_DATE                     ,
 P_END_DATE                       ,
 P_PROCESSING_TYPE                ,
 P_PERIOD_TYPE                    ,
 P_PROCESS_PERIOD_TYPE            ,
 P_MAX_ELEMENT_VALUE_TYPE         ,
 P_MAX_ELEMENT_VALUE              ,
 P_SALARY_FLAG                    ,
 P_SALARY_TYPE                    ,
 P_OPTION_FLAG                    ,
 P_HR_ELEMENT_TYPE_ID             ,
 P_ATTRIBUTE_CATEGORY             ,
 P_ATTRIBUTE1                     ,
 P_ATTRIBUTE2                     ,
 P_ATTRIBUTE3                     ,
 P_ATTRIBUTE4                     ,
 P_ATTRIBUTE5                     ,
 P_ATTRIBUTE6                     ,
 P_ATTRIBUTE7                     ,
 P_ATTRIBUTE8                     ,
 P_ATTRIBUTE9                     ,
 P_ATTRIBUTE10                    ,
 /* Bug 4222417 Start */
 NVL(P_LAST_UPDATE_DATE,SYSDATE)                ,
 NVL(P_LAST_UPDATED_BY,FND_GLOBAL.USER_ID)      ,
 NVL(P_LAST_UPDATE_LOGIN,FND_GLOBAL.LOGIN_ID)   ,
 NVL(P_CREATED_BY,FND_GLOBAL.USER_ID)           ,
 NVL(P_CREATION_DATE,SYSDATE)
 /* Bug 4222417 End */
  );

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

END Insert_Row;


PROCEDURE Update_Row
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
 --
  P_ROW_ID                           in      VARCHAR2,
  P_PAY_ELEMENT_ID                   in      NUMBER,
  P_BUSINESS_GROUP_ID                in      NUMBER,
  P_DATA_EXTRACT_ID                  in      NUMBER,
  P_BUDGET_SET_ID                    in      NUMBER := FND_API.G_MISS_NUM,
  P_NAME                             in      VARCHAR2,
  P_DESCRIPTION                      in      VARCHAR2,
  P_ELEMENT_VALUE_TYPE               in      VARCHAR2,
  P_FORMULA_ID                       in      NUMBER,
  P_OVERWRITE_FLAG                   in      VARCHAR2,
  P_REQUIRED_FLAG                    in      VARCHAR2,
  P_FOLLOW_SALARY                    in      VARCHAR2,
  P_PAY_BASIS                        IN      VARCHAR2,
  P_START_DATE                       in      DATE,
  P_END_DATE                         in      DATE,
  P_PROCESSING_TYPE                  in      VARCHAR2,
  P_PERIOD_TYPE                      in      VARCHAR2,
  P_PROCESS_PERIOD_TYPE              in      VARCHAR2,
  P_MAX_ELEMENT_VALUE_TYPE           in      VARCHAR2,
  P_MAX_ELEMENT_VALUE                in      NUMBER,
  P_SALARY_FLAG                      in      VARCHAR2,
  P_SALARY_TYPE                      in      VARCHAR2,
  P_OPTION_FLAG                      in      VARCHAR2,
  P_HR_ELEMENT_TYPE_ID               in      NUMBER,
  P_ATTRIBUTE_CATEGORY               in      VARCHAR2,
  P_ATTRIBUTE1                       in      VARCHAR2,
  P_ATTRIBUTE2                       in      VARCHAR2,
  P_ATTRIBUTE3                       in      VARCHAR2,
  P_ATTRIBUTE4                       in      VARCHAR2,
  P_ATTRIBUTE5                       in      VARCHAR2,
  P_ATTRIBUTE6                       in      VARCHAR2,
  P_ATTRIBUTE7                       in      VARCHAR2,
  P_ATTRIBUTE8                       in      VARCHAR2,
  P_ATTRIBUTE9                       in      VARCHAR2,
  P_ATTRIBUTE10                      in      VARCHAR2,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
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
  UPDATE psb_pay_elements SET
 PAY_ELEMENT_ID                 = P_PAY_ELEMENT_ID,
 BUSINESS_GROUP_ID              = P_BUSINESS_GROUP_ID,
 DATA_EXTRACT_ID                = P_DATA_EXTRACT_ID,
 BUDGET_SET_ID                  = decode(P_BUDGET_SET_ID,FND_API.G_MISS_NUM,null,P_BUDGET_SET_ID),
 NAME                           = P_NAME,
 DESCRIPTION                    = P_DESCRIPTION,
 ELEMENT_VALUE_TYPE             = P_ELEMENT_VALUE_TYPE,
 FORMULA_ID                     = P_FORMULA_ID,
 OVERWRITE_FLAG                 = P_OVERWRITE_FLAG,
 REQUIRED_FLAG                  = P_REQUIRED_FLAG,
 FOLLOW_SALARY                  = P_FOLLOW_SALARY,
 PAY_BASIS                      = P_PAY_BASIS,
 START_DATE                     = P_START_DATE,
 END_DATE                       = P_END_DATE,
 PROCESSING_TYPE                = P_PROCESSING_TYPE,
 PERIOD_TYPE                    = P_PERIOD_TYPE,
 PROCESS_PERIOD_TYPE            = P_PROCESS_PERIOD_TYPE,
 MAX_ELEMENT_VALUE_TYPE         = P_MAX_ELEMENT_VALUE_TYPE,
 MAX_ELEMENT_VALUE              = P_MAX_ELEMENT_VALUE,
 SALARY_FLAG                    = P_SALARY_FLAG,
 SALARY_TYPE                    = P_SALARY_TYPE,
 OPTION_FLAG                    = P_OPTION_FLAG,
 HR_ELEMENT_TYPE_ID             = P_HR_ELEMENT_TYPE_ID,
 ATTRIBUTE_CATEGORY             = P_ATTRIBUTE_CATEGORY,
 ATTRIBUTE1                     = P_ATTRIBUTE1,
 ATTRIBUTE2                     = P_ATTRIBUTE2,
 ATTRIBUTE3                     = P_ATTRIBUTE3,
 ATTRIBUTE4                     = P_ATTRIBUTE4,
 ATTRIBUTE5                     = P_ATTRIBUTE5,
 ATTRIBUTE6                     = P_ATTRIBUTE6,
 ATTRIBUTE7                     = P_ATTRIBUTE7,
 ATTRIBUTE8                     = P_ATTRIBUTE8,
 ATTRIBUTE9                     = P_ATTRIBUTE9,
 ATTRIBUTE10                    = P_ATTRIBUTE10,
 LAST_UPDATE_DATE               = P_LAST_UPDATE_DATE,
 LAST_UPDATED_BY                = P_LAST_UPDATED_BY,
 LAST_UPDATE_LOGIN              = P_LAST_UPDATE_LOGIN
  WHERE ROWID = P_ROW_ID;

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

END Update_Row;


/*============================================================================+
 |                       PROCEDURE Delete_Row                                 |
 +============================================================================*/
PROCEDURE Delete_Row
(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  --
  p_row_id              IN      VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Delete_Row' ;
  l_api_version         CONSTANT NUMBER         := 1.0 ;
  --
  --
  l_return_status       VARCHAR2(1) ;
  l_msg_count           NUMBER ;
  l_msg_data            VARCHAR2(2000) ;
  --
  l_pay_element_id      psb_pay_elements.pay_element_id%TYPE ;
  --
BEGIN
  --
  SAVEPOINT Delete_Row_Pvt;
  --
  IF NOT FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;
  --
  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  -- Get pay_element_id to be used for deletion of detail records.
  SELECT pay_element_id INTO l_pay_element_id
  FROM   psb_pay_elements
  WHERE  rowid = p_row_id ;

  --
  -- Delete element position set group related position sets.
  --

  FOR l_pos_set_group_rec IN
  (
    SELECT position_set_group_id
    FROM   psb_element_pos_set_groups
    WHERE  pay_element_id = l_pay_element_id
  )
  LOOP

    PSB_Set_Relation_PVT.Delete_Entity_Relation
    (
      p_api_version       => 1.0                                         ,
      p_init_msg_list     => FND_API.G_FALSE                             ,
      p_commit            => FND_API.G_FALSE                             ,
      p_validation_level  => FND_API.G_VALID_LEVEL_FULL                  ,
      p_return_status     => l_return_status                             ,
      p_msg_count         => l_msg_count                                 ,
      p_msg_data          => l_msg_data                                  ,
      --
      p_entity_type       => 'PSG'                                       ,
      p_entity_id         => l_pos_set_group_rec.position_set_group_id
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  END LOOP ;


  --
  -- Delete dependent detail records to maintain ISOLATED master-detail
  -- form relation.
  --

  DELETE psb_pay_element_rates
  WHERE  pay_element_id = l_pay_element_id ;

  DELETE psb_pay_element_options
  WHERE  pay_element_id = l_pay_element_id ;

  DELETE psb_pay_element_distributions
  WHERE  position_set_group_id IN
	 (
	    SELECT position_set_group_id
	    FROM   psb_element_pos_set_groups
	    WHERE  pay_element_id = l_pay_element_id
	 ) ;

  DELETE psb_element_pos_set_groups
  WHERE  pay_element_id = l_pay_element_id ;


  --
  -- Delete the master record now in psb_pay_elements.
  --
  DELETE psb_pay_elements
  WHERE  rowid = p_row_id ;

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END IF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  --
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
/*----------------------------------------------------------------------------*/


PROCEDURE Lock_Row
(
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
  P_ROW_ID                           in      VARCHAR2,
  P_PAY_ELEMENT_ID                   in      NUMBER,
  P_BUSINESS_GROUP_ID                in      NUMBER,
  P_DATA_EXTRACT_ID                  in      NUMBER,
  P_BUDGET_SET_ID                    in      NUMBER := FND_API.G_MISS_NUM,
  P_NAME                             in      VARCHAR2,
  P_DESCRIPTION                      in      VARCHAR2,
  P_ELEMENT_VALUE_TYPE               in      VARCHAR2,
  P_FORMULA_ID                       in      NUMBER,
  P_OVERWRITE_FLAG                   in      VARCHAR2,
  P_REQUIRED_FLAG                    in      VARCHAR2,
  P_FOLLOW_SALARY                    in      VARCHAR2,
  P_PAY_BASIS                        IN      VARCHAR2,
  P_START_DATE                       in      DATE,
  P_END_DATE                         in      DATE,
  P_PROCESSING_TYPE                  in      VARCHAR2,
  P_PERIOD_TYPE                      in      VARCHAR2,
  P_PROCESS_PERIOD_TYPE              in      VARCHAR2,
  P_MAX_ELEMENT_VALUE_TYPE           in      VARCHAR2,
  P_MAX_ELEMENT_VALUE                in      NUMBER,
  P_SALARY_FLAG                      in      VARCHAR2,
  P_SALARY_TYPE                      in      VARCHAR2,
  P_OPTION_FLAG                      in      VARCHAR2,
  P_HR_ELEMENT_TYPE_ID               in      NUMBER,
  P_ATTRIBUTE_CATEGORY               in      VARCHAR2,
  P_ATTRIBUTE1                       in      VARCHAR2,
  P_ATTRIBUTE2                       in      VARCHAR2,
  P_ATTRIBUTE3                       in      VARCHAR2,
  P_ATTRIBUTE4                       in      VARCHAR2,
  P_ATTRIBUTE5                       in      VARCHAR2,
  P_ATTRIBUTE6                       in      VARCHAR2,
  P_ATTRIBUTE7                       in      VARCHAR2,
  P_ATTRIBUTE8                       in      VARCHAR2,
  P_ATTRIBUTE9                       in      VARCHAR2,
  P_ATTRIBUTE10                      in      VARCHAR2
  ) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         := 1.0;
  --
  counter number;

  CURSOR C IS SELECT * FROM PSB_PAY_ELEMENTS WHERE ROWID = p_Row_Id
  FOR UPDATE of PAY_ELEMENT_Id NOWAIT;
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

  IF
  (
	 (Recinfo.pay_element_id =  p_pay_element_id)
	 AND (Recinfo.business_group_id = p_business_group_id)
	 AND (Recinfo.data_extract_id = p_data_extract_id)
	 AND (Recinfo.name = p_name)

	  AND ( (Recinfo.budget_set_id =  p_budget_set_id)
		 OR ( (Recinfo.budget_set_id IS NULL)
		       AND (p_budget_set_id IS NULL))
		 OR (p_budget_set_id  = FND_API.G_MISS_NUM))

	  AND ( (Recinfo.description =  p_description)
		 OR ( (Recinfo.description IS NULL)
		       AND (p_description IS NULL)))

	  AND ( (Recinfo.element_value_type =  p_element_value_type)
		 OR ( (Recinfo.element_value_type IS NULL)
		       AND (p_element_value_type IS NULL)))

	  AND ( (Recinfo.formula_id = p_formula_id)
		 OR ( (Recinfo.formula_id IS NULL)
		       AND (p_formula_id IS NULL)))

	  AND ( (Recinfo.overwrite_flag = p_overwrite_flag)
		 OR ( (Recinfo.overwrite_flag IS NULL)
		       AND (p_overwrite_flag IS NULL)))

	  AND ( (Recinfo.required_flag = p_required_flag)
		 OR ( (Recinfo.required_flag IS NULL)
		       AND (p_required_flag IS NULL)))

	  AND ( (Recinfo.follow_salary = p_follow_salary)
		 OR ( (Recinfo.follow_salary IS NULL)
		       AND (p_follow_salary IS NULL)))

	  AND ( (Recinfo.pay_basis = p_pay_basis)
		 OR ( (Recinfo.pay_basis IS NULL)
		       AND (p_pay_basis IS NULL)))

	  AND ( (Recinfo.start_date = p_start_date)
		 OR ( (Recinfo.start_date IS NULL)
		       AND (p_start_date IS NULL)))

	  AND ( (Recinfo.end_date = p_end_date)
		 OR ( (Recinfo.end_date IS NULL)
		       AND (p_end_date IS NULL)))

	  AND ( (Recinfo.processing_type = p_processing_type)
		 OR ( (Recinfo.processing_type IS NULL)
		       AND (p_processing_type IS NULL)))

	  AND ( (Recinfo.period_type =  p_period_type)
		 OR ( (Recinfo.period_type IS NULL)
		     AND (p_period_type IS NULL)))

	  AND ( (Recinfo.process_period_type =  p_process_period_type)
		 OR ( (Recinfo.process_period_type IS NULL)
		     AND (p_process_period_type IS NULL)))

	  AND ( (Recinfo.max_element_value_type =  p_max_element_value_type)
		 OR ( (Recinfo.max_element_value_type IS NULL)
		     AND (p_max_element_value_type IS NULL)))

	  AND ( (Recinfo.max_element_value = p_max_element_value)
		 OR ( (Recinfo.max_element_value IS NULL)
		     AND (p_max_element_value IS NULL)))

	  AND ( (Recinfo.salary_flag = p_salary_flag)
		 OR ( (Recinfo.salary_flag IS NULL)
		     AND (p_salary_flag IS NULL)))

	  AND ( (Recinfo.salary_type = p_salary_type)
		 OR ( (Recinfo.salary_type IS NULL)
		     AND (p_salary_type IS NULL)))

	  AND ( (Recinfo.option_flag = p_option_flag)
		 OR ( (Recinfo.option_flag IS NULL)
		     AND (p_option_flag IS NULL)))

	  AND ( (Recinfo.hr_element_type_id = p_hr_element_type_id)
		 OR ( (Recinfo.hr_element_type_id IS NULL)
		     AND (p_hr_element_type_id IS NULL)))

	  AND ( (Recinfo.attribute_category = p_attribute_category)
		 OR ( (Recinfo.attribute_category IS NULL)
		     AND (p_attribute_category IS NULL)))

	  AND ( (Recinfo.attribute1 = p_attribute1)
		 OR ( (Recinfo.attribute1 IS NULL)
		     AND (p_attribute1 IS NULL)))

	  AND ( (Recinfo.attribute2 = p_attribute2)
		 OR ( (Recinfo.attribute2 IS NULL)
		     AND (p_attribute2 IS NULL)))

	  AND ( (Recinfo.attribute3 = p_attribute3)
		 OR ( (Recinfo.attribute3 IS NULL)
		     AND (p_attribute3 IS NULL)))

	  AND ( (Recinfo.attribute4 = p_attribute4)
		 OR ( (Recinfo.attribute4 IS NULL)
		     AND (p_attribute4 IS NULL)))

	  AND ( (Recinfo.attribute5 = p_attribute5)
		 OR ( (Recinfo.attribute5 IS NULL)
		     AND (p_attribute5 IS NULL)))

	  AND ( (Recinfo.attribute6 = p_attribute6)
		 OR ( (Recinfo.attribute6 IS NULL)
		     AND (p_attribute6 IS NULL)))

	  AND ( (Recinfo.attribute7 = p_attribute7)
		 OR ( (Recinfo.attribute7 IS NULL)
		     AND (p_attribute7 IS NULL)))

	  AND ( (Recinfo.attribute8 = p_attribute8)
		 OR ( (Recinfo.attribute8 IS NULL)
		     AND (p_attribute8 IS NULL)))

	  AND ( (Recinfo.attribute9 = p_attribute9)
		 OR ( (Recinfo.attribute9 IS NULL)
		     AND (p_attribute9 IS NULL)))

	  AND ( (Recinfo.attribute10 = p_attribute10)
		 OR ( (Recinfo.attribute10 IS NULL)
		     AND (p_attribute10 IS NULL)))
  )

  THEN
    Null;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
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
  P_DATA_EXTRACT_ID           IN       NUMBER,
  p_Return_Value              IN OUT  NOCOPY   VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Unique';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_tmp VARCHAR2(1);

  CURSOR c IS
    SELECT '1'
    FROM psb_pay_elements
    WHERE name = p_name
    AND   ( (p_Row_Id IS NULL)
	     OR (RowId <> p_Row_Id) )
    AND (DATA_EXTRACT_ID = P_DATA_EXTRACT_ID);
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



/*============================================================================+
 |                       PROCEDURE Check_References                           |
 +============================================================================*/
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
  p_pay_element_id            IN       NUMBER,
  p_return_value              IN OUT  NOCOPY   VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_References';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_tmp1                VARCHAR2(1);
  l_tmp2                VARCHAR2(1);
  l_tmp3                VARCHAR2(1);
  --
  CURSOR c1 IS
	 SELECT '1'
	 FROM   psb_position_assignments
	 WHERE  pay_element_id = p_pay_element_id ;

  CURSOR c2 IS
	 SELECT '1'
	 FROM   psb_ws_element_lines
	 WHERE  pay_element_id = p_pay_element_id ;

  CURSOR c3 IS
	 SELECT '1'
	 FROM   psb_default_assignments
	 WHERE  pay_element_id = p_pay_element_id ;
  --
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

  OPEN  c1 ;
  FETCH c1 INTO l_tmp1 ;
  CLOSE c1;

  OPEN  c2 ;
  FETCH c2 INTO l_tmp2 ;
  CLOSE c2;

  OPEN  c3 ;
  FETCH c3 INTO l_tmp3 ;
  CLOSE c3;

  --
  -- p_return_value specifies whether references exist or not.
  --
  IF ( l_tmp1 IS NULL AND l_tmp2 IS NULL AND l_tmp3 IS NULL ) THEN

    p_Return_Value := 'FALSE' ;

  ELSE

    p_Return_Value := 'TRUE' ;

  END IF;

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END IF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );

  --
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
/*----------------------------------------------------------------------------*/

/*===========================================================================+
 |                     PROCEDURE Copy_Pay_Elements                               |
 +===========================================================================*/
--

PROCEDURE Copy_Pay_Elements
( p_api_version            IN    NUMBER,
  p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN    VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN    NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status          OUT  NOCOPY   VARCHAR2,
  p_msg_count              OUT  NOCOPY   NUMBER,
  p_msg_data               OUT  NOCOPY   VARCHAR2,
  p_source_pay_element_id  IN    NUMBER,
  p_source_data_extract_id IN    NUMBER,
  p_target_data_extract_id IN    NUMBER
) AS

  l_api_name                       CONSTANT VARCHAR2(30) := 'Copy_Pay_Elements';
  l_api_version                    CONSTANT NUMBER        := 1.0;
  l_last_update_date               DATE;
  l_last_updated_by                NUMBER;
  l_last_update_login              NUMBER;
  l_pay_element_id                 NUMBER;
  lr_pay_element_id                NUMBER;
  l_pay_element_option_id          NUMBER;
  l_pay_element_rate_id            NUMBER;
  l_source_pay_element_option_id   NUMBER;
  l_position_set_group_id          NUMBER;
  l_source_set_group_id            NUMBER;
  l_set_relation_id                NUMBER;
  l_distribution_set_id            NUMBER;
  l_option_flag                    VARCHAR2(1);
  prev_distribution_set_id         NUMBER := -1;
  l_distribution_id                NUMBER;
  l_rowid2                         VARCHAR2(100);
  l_set_name                       VARCHAR2(100);
  l_element_dummy                  NUMBER;
  l_element_name                   VARCHAR2(30);
  l_budget_set_id                  NUMBER := NULL;
  l_rowid                          VARCHAR2(100);
  l_creation_date                  DATE;
  l_created_by                     NUMBER;
  l_status                         VARCHAR2(1);
  l_return_status                  VARCHAR2(1);
  l_msg_count                      NUMBER;
  l_msg_data                       VARCHAR2(1000);

  CURSOR l_pay_element_csr is
    SELECT DISTINCT *
      FROM psb_pay_elements
     WHERE pay_element_id = p_source_pay_element_id;

  CURSOR l_pay_element_options_csr is
    SELECT pay_element_option_id,pay_element_id,
	   name, grade_step, sequence_number
      FROM psb_pay_element_options
     WHERE pay_element_id = p_source_pay_element_id;

  CURSOR l_pay_element_rates_csr is
    SELECT pay_element_rate_id,pay_element_option_id,
	   effective_start_date,effective_end_date,
	   worksheet_id,element_value_type,
	   element_value,formula_id,
	   maximum_value,mid_value,
	   minimum_value,currency_code,pay_basis
      FROM psb_pay_element_rates
     WHERE (((pay_element_option_id = l_source_pay_element_option_id ) AND
	     (pay_element_id = p_source_pay_element_id)) or
	    ((pay_element_id = p_source_pay_element_id) AND
					     (pay_element_option_id IS NULL)))
       AND worksheet_id IS NULL;

  CURSOR l_set_groups_csr is
    select position_set_group_id,name
      FROM psb_element_pos_set_groups
     WHERE pay_element_id = p_source_pay_element_id;

  CURSOR l_position_sets_csr is
    SELECT aps.name,
	   effective_start_date,
	   effective_end_date
      FROM psb_set_relations rels, psb_account_position_sets aps
    WHERE  rels.account_position_set_id = aps.account_position_set_id
      AND  aps.data_extract_id  = p_source_data_extract_id
      AND  rels.position_set_group_id = l_source_set_group_id;

  CURSOR l_account_sets_csr is
    SELECT account_position_set_id
      FROM psb_account_position_sets
     WHERE name = l_set_name
       AND data_extract_id = p_target_data_extract_id;

  CURSOR l_account_distr_csr is
    SELECT distribution_id,distribution_set_id,
	   chart_of_accounts_id,effective_start_date,
	   effective_end_date,distribution_percent,
	   code_combination_id,concatenated_segments,
	   segment1,segment2,
	   segment3,segment4,
	   segment5,segment6,
	   segment7,segment8,
	   segment9,segment10,
	   segment11,segment12,
	   segment13,segment14,
	   segment15,segment16,
	   segment17,segment18,
	   segment19,segment20,
	   segment21,segment22,
	   segment23,segment24,
	   segment25,segment26,
	   segment27,segment28,
	   segment29,segment30
      FROM psb_pay_element_distributions
     WHERE position_set_group_id = l_source_set_group_id
     order by distribution_set_id;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT Copy_Pay_Elements_Pvt;

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
  l_last_update_date  := sysDATE;
  l_last_updated_by   := FND_GLOBAL.USER_ID;
  l_last_update_login := FND_GLOBAL.LOGIN_ID;
  l_creation_date     := sysDATE;
  l_created_by        := FND_GLOBAL.USER_ID;

  --creating a new element based on p_source_pay_element_id


    For l_pay_element_rec IN l_pay_element_csr
    Loop

    l_element_name := l_pay_element_rec.name;
    l_option_flag := l_pay_element_rec.option_flag;

    SELECT  psb_pay_elements_s.NEXTVAL
    INTO   l_pay_element_id
    FROM    DUAL;

    PSB_PAY_ELEMENTS_PVT.INSERT_ROW
    ( p_api_version             =>  1.0,
      p_init_msg_list           => null,
      p_commit                  => null,
      p_validation_level        => null,
      p_return_status           => l_return_status,
      p_msg_count               => l_msg_count,
      p_msg_data                => l_msg_data,
      p_row_id                  => l_rowid,
      p_pay_element_id          => l_pay_element_id,
      p_business_group_id       => l_pay_element_rec.business_group_id,
      p_data_extract_id         => p_target_data_extract_id,
      p_budget_set_id           => l_budget_set_id,
      p_name                    => l_pay_element_rec.name,
      p_description             => l_pay_element_rec.description,
      p_element_value_type      => l_pay_element_rec.element_value_type,
      p_formula_id              => l_pay_element_rec.formula_id,
      p_overwrite_flag          => l_pay_element_rec.overwrite_flag,
      p_required_flag           => l_pay_element_rec.required_flag,
      p_follow_salary           => l_pay_element_rec.follow_salary,
      p_pay_basis               => l_pay_element_rec.pay_basis,
      p_start_date              => l_pay_element_rec.start_date,
      p_end_date                => l_pay_element_rec.end_date,
      p_processing_type         => l_pay_element_rec.processing_type,
      p_period_type             => l_pay_element_rec.period_type,
      p_process_period_type     => l_pay_element_rec.process_period_type,
      p_max_element_value_type  => l_pay_element_rec.max_element_value_type,
      p_max_element_value       => l_pay_element_rec.max_element_value,
      p_salary_flag             => l_pay_element_rec.salary_flag,
      p_salary_type             => l_pay_element_rec.salary_type,
      p_option_flag             => l_pay_element_rec.option_flag,
      p_hr_element_type_id      => l_pay_element_rec.hr_element_type_id,
      p_attribute_category      => l_pay_element_rec.attribute_category,
      p_attribute1              => l_pay_element_rec.attribute1,
      p_attribute2              => l_pay_element_rec.attribute2,
      p_attribute3              => l_pay_element_rec.attribute3,
      p_attribute4              => l_pay_element_rec.attribute4,
      p_attribute5              => l_pay_element_rec.attribute5,
      p_attribute6              => l_pay_element_rec.attribute6,
      p_attribute7              => l_pay_element_rec.attribute7,
      p_attribute8              => l_pay_element_rec.attribute8,
      p_attribute9              => l_pay_element_rec.attribute9,
      p_attribute10             => l_pay_element_rec.attribute10,
      p_last_update_date        => l_last_update_date,
      p_last_updated_by         => l_last_updated_by,
      p_last_update_login       => l_last_update_login,
      p_created_by              => l_created_by,
      p_creation_date           => l_creation_date
    );

    debug( 'New Pay Element Created:'||l_pay_element_id);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      debug( 'Element not Copied for Pay Element Id : ' ||
	      p_source_pay_element_id);
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      debug( 'Element not Copied for Pay Element Id : ' ||
	      p_source_pay_element_id);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    For l_pay_element_options_rec in l_pay_element_options_csr
    Loop

      l_source_pay_element_option_id :=
				  l_pay_element_options_rec.pay_element_option_id;

      SELECT psb_pay_element_options_s.NEXTVAL
      INTO l_pay_element_option_id
      FROM DUAL;

      PSB_PAY_ELEMENT_OPTIONS_PVT.INSERT_ROW
      ( p_api_version             =>  1.0,
	p_init_msg_list           => null,
	p_commit                  => null,
	p_validation_level        => null,
	p_return_status           => l_return_status,
	p_msg_count               => l_msg_count,
	p_msg_data                => l_msg_data,
	p_pay_element_option_id   => l_pay_element_option_id,
	p_pay_element_id          => l_pay_element_id,
	p_name                    => l_pay_element_options_rec.name,
	p_grade_step              => l_pay_element_options_rec.grade_step,
	p_sequence_number         => l_pay_element_options_rec.sequence_number,
	p_last_update_date        => l_last_update_date,
	p_last_updated_by         => l_last_updated_by,
	p_last_update_login       => l_last_update_login,
	p_created_by              => l_created_by,
	p_creation_date           => l_creation_date
      );

      debug( 'New Pay Element Option Created:'||l_pay_element_option_id);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      debug( 'Element Option not Copied for Pay Element Option Id : ' ||
	      l_pay_element_options_rec.pay_element_option_id);
      RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      debug( 'Element Option not Copied for Pay Element Option Id : ' ||
	      l_pay_element_options_rec.pay_element_option_id);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;

      For l_pay_element_rates_rec in l_pay_element_rates_csr
      Loop

      SELECT psb_pay_element_rates_s.NEXTVAL
      INTO l_pay_element_rate_id
      FROM DUAL;

      PSB_PAY_ELEMENT_RATES_PVT.INSERT_ROW
      ( p_api_version             =>  1.0,
	p_init_msg_list           => null,
	p_commit                  => null,
	p_validation_level        => null,
	p_return_status           => l_return_status,
	p_msg_count               => l_msg_count,
	p_msg_data                => l_msg_data,
	p_pay_element_rate_id     => l_pay_element_rate_id,
	p_pay_element_option_id   => l_pay_element_option_id,
	p_pay_element_id          => l_pay_element_id,
	p_effective_start_date    => l_pay_element_rates_rec.effective_start_date,
	p_effective_end_date      => l_pay_element_rates_rec.effective_end_date,
	p_worksheet_id            => l_pay_element_rates_rec.worksheet_id,
	p_element_value_type      => l_pay_element_rates_rec.element_value_type,
	p_element_value           => l_pay_element_rates_rec.element_value,
	p_pay_basis               => l_pay_element_rates_rec.pay_basis,
	p_formula_id              => l_pay_element_rates_rec.formula_id,
	p_maximum_value           => l_pay_element_rates_rec.maximum_value,
	p_mid_value               => l_pay_element_rates_rec.mid_value,
	p_minimum_value           => l_pay_element_rates_rec.minimum_value,
	p_currency_code           => l_pay_element_rates_rec.currency_code,
	p_last_update_date        => l_last_update_date,
	p_last_updated_by         => l_last_updated_by,
	p_last_update_login       => l_last_update_login,
	p_created_by              => l_created_by,
	p_creation_date           => l_creation_date
      ) ;

      debug( 'New Pay Element Rate Created:'||l_pay_element_rate_id);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      debug( 'Element Rate not Copied for Pay Element Rate Id : ' ||
	      l_pay_element_rates_rec.pay_element_rate_id);
      RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      debug( 'Element Rate not Copied for Pay Element Rate Id : ' ||
	      l_pay_element_rates_rec.pay_element_rate_id);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;

      End Loop;
    End Loop;

	 if (l_option_flag <> 'Y') then
	   For l_pay_element_rates_rec in l_pay_element_rates_csr
	   Loop

	   SELECT psb_pay_element_rates_s.NEXTVAL
	     INTO l_pay_element_rate_id
	     FROM DUAL;

	  PSB_PAY_ELEMENT_RATES_PVT.INSERT_ROW
	  ( p_api_version             =>  1.0,
	    p_init_msg_list           => null,
	    p_commit                  => null,
	    p_validation_level        => null,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_pay_element_rate_id     => l_pay_element_rate_id,
	    p_pay_element_option_id   => l_pay_element_option_id,
	    p_pay_element_id          => l_pay_element_id,
	    p_effective_start_date    =>
				    l_pay_element_rates_rec.effective_start_date,
	    p_effective_end_date      =>
				    l_pay_element_rates_rec.effective_end_date,
	    p_worksheet_id            => l_pay_element_rates_rec.worksheet_id,
	    p_element_value_type      =>
				    l_pay_element_rates_rec.element_value_type,
	    p_element_value           => l_pay_element_rates_rec.element_value,
	    p_pay_basis               => l_pay_element_rates_rec.pay_basis,
	    p_formula_id              => l_pay_element_rates_rec.formula_id,
	    p_maximum_value           => l_pay_element_rates_rec.maximum_value,
	    p_mid_value               => l_pay_element_rates_rec.mid_value,
	    p_minimum_value           => l_pay_element_rates_rec.minimum_value,
	    p_currency_code           => l_pay_element_rates_rec.currency_code,
	    p_last_update_date        => l_last_update_date,
	    p_last_updated_by         => l_last_updated_by,
	    p_last_update_login       => l_last_update_login,
	    p_created_by              => l_created_by,
	    p_creation_date           => l_creation_date
	   ) ;

	   debug( 'New Pay Element Rate Created:'||l_pay_element_rate_id);

	   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	      debug( 'Element Rate not Copied for Pay Element Rate Id : ' ||
	      l_pay_element_rates_rec.pay_element_rate_id);
	   RAISE FND_API.G_EXC_ERROR ;
	   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      debug( 'Element Rate not Copied for Pay Element Rate Id : ' ||
	      l_pay_element_rates_rec.pay_element_rate_id);
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	   END IF;

	   End Loop;
	  end if;

	  For l_set_groups_rec in l_set_groups_csr
	  Loop
	    l_source_set_group_id := l_set_groups_rec.position_set_group_id;

	    SELECT psb_element_pos_set_groups_s.NEXTVAL
	    INTO l_position_set_group_id
	    FROM DUAL;

	    PSB_ELEMENT_POS_SET_GROUPS_PVT.Insert_Row
	    (    p_api_version           => 1.0,
		 p_init_msg_list         => FND_API.G_FALSE,
		 p_commit                => FND_API.G_FALSE,
		 p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
		 p_return_status         => l_return_status,
		 p_msg_count             => l_msg_count,
		 p_msg_data              => l_msg_data,
		 --
		 p_position_set_group_id => l_position_set_group_id,
		 p_pay_element_id        => l_pay_element_id,
		 p_name                  => l_set_groups_rec.name,
		 p_last_update_date      => l_last_update_date,
		 p_last_updated_by       => l_last_updated_by,
		 p_last_update_login     => l_last_update_login,
		 p_created_by            => l_created_by,
		 p_creation_date         => l_creation_date
	    );

	   debug( 'New Position Set Group Created:'||l_position_set_group_id);

	   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	     debug( 'Position Set Group not Copied for Set Group Id : ' ||
	     l_source_set_group_id);
	     RAISE FND_API.G_EXC_ERROR ;
	   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     debug( 'Position Set Group not Copied for Set Group Id : ' ||
	     l_source_set_group_id);
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	   END IF;


	  prev_distribution_set_id := -1;
	  For l_account_distr_rec in l_account_distr_csr
	  Loop
	    SELECT psb_pay_element_distribution_s.NEXTVAL INTO
		   l_distribution_id
	    FROM DUAL;

	   if ((l_account_distr_rec.distribution_set_id <>
			  prev_distribution_set_id)
	       or (prev_distribution_set_id  = -1)) then
	       SELECT psb_element_distribution_set_s.NEXTVAL INTO
		      l_distribution_set_id
	       FROM DUAL;
	   end if;

	    PSB_ELE_DISTRIBUTIONS_I_PVT.Insert_Row
	    (    p_api_version           => 1.0,
		 p_init_msg_list         => FND_API.G_FALSE,
		 p_commit                => FND_API.G_FALSE,
		 p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
		 p_return_status         => l_return_status,
		 p_msg_count             => l_msg_count,
		 p_msg_data              => l_msg_data,
		 --
		 p_distribution_id       => l_distribution_id,
		 p_position_set_group_id => l_position_set_group_id,
		 p_chart_of_accounts_id  =>
					 l_account_distr_rec.chart_of_accounts_id,
		 p_effective_start_date  =>
					 l_account_distr_rec.effective_start_date,
		 p_effective_end_date    =>
					 l_account_distr_rec.effective_end_date,
		 p_distribution_percent  =>
					 l_account_distr_rec.distribution_percent,
		 p_concatenated_segments =>
					l_account_distr_rec.concatenated_segments,
		 p_code_combination_id   =>
					l_account_distr_rec.code_combination_id,
		 p_distribution_set_id   => l_distribution_set_id,
		 p_segment1              => l_account_distr_rec.segment1,
		 p_segment2              => l_account_distr_rec.segment2,
		 p_segment3              => l_account_distr_rec.segment3,
		 p_segment4              => l_account_distr_rec.segment4,
		 p_segment5              => l_account_distr_rec.segment5,
		 p_segment6              => l_account_distr_rec.segment6,
		 p_segment7              => l_account_distr_rec.segment7,
		 p_segment8              => l_account_distr_rec.segment8,
		 p_segment9              => l_account_distr_rec.segment9,
		 p_segment10             => l_account_distr_rec.segment10,
		 p_segment11             => l_account_distr_rec.segment11,
		 p_segment12             => l_account_distr_rec.segment12,
		 p_segment13             => l_account_distr_rec.segment13,
		 p_segment14             => l_account_distr_rec.segment14,
		 p_segment15             => l_account_distr_rec.segment15,
		 p_segment16             => l_account_distr_rec.segment16,
		 p_segment17             => l_account_distr_rec.segment17,
		 p_segment18             => l_account_distr_rec.segment18,
		 p_segment19             => l_account_distr_rec.segment19,
		 p_segment20             => l_account_distr_rec.segment20,
		 p_segment21             => l_account_distr_rec.segment21,
		 p_segment22             => l_account_distr_rec.segment22,
		 p_segment23             => l_account_distr_rec.segment23,
		 p_segment24             => l_account_distr_rec.segment24,
		 p_segment25             => l_account_distr_rec.segment25,
		 p_segment26             => l_account_distr_rec.segment26,
		 p_segment27             => l_account_distr_rec.segment27,
		 p_segment28             => l_account_distr_rec.segment28,
		 p_segment29             => l_account_distr_rec.segment29,
		 p_segment30             => l_account_distr_rec.segment30,
		 p_last_update_date      => l_last_update_date,
		 p_last_updated_by       => l_last_updated_by,
		 p_last_update_login     => l_last_update_login,
		 p_created_by            => l_created_by,
		 p_creation_date         => l_creation_date
	  );

	  debug( 'New Distribution Created:'||l_distribution_id);

	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	     debug( 'Pay Element Distribution not Copied for Distribution Id
	     : ' || l_account_distr_rec.distribution_id);
	     RAISE FND_API.G_EXC_ERROR ;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     debug( 'Pay Element Distribution not Copied for Distribution Id
	     : ' || l_account_distr_rec.distribution_id);
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	  END IF;

	  prev_distribution_set_id := l_account_distr_rec.distribution_set_id;
	  End Loop;

	  For l_position_sets_rec in l_position_sets_csr
	  Loop
	     l_set_name := l_position_sets_rec.name;
	   For l_account_sets_rec in l_account_sets_csr
	   Loop
	    l_set_relation_id := null;
	    PSB_Set_Relation_PVT.Insert_Row
	    ( p_api_version              => 1.0,
	      p_init_msg_list            => FND_API.G_FALSE,
	      p_commit                   => FND_API.G_FALSE,
	      p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
	      p_return_status            => l_return_status,
	      p_msg_count                => l_msg_count,
	      p_msg_data                 => l_msg_data,
	      p_Row_Id                   => l_rowid2,
	      p_Set_Relation_Id          => l_set_relation_id,
	      p_Account_Position_Set_Id  =>
				      l_account_sets_rec.account_position_set_id,
	      p_Allocation_Rule_Id      => null,
	      p_Budget_Group_Id         => null,
	      p_Budget_Workflow_Rule_Id => null,
	      p_Constraint_Id           => null,
	      p_Default_Rule_Id         => null,
	      p_Parameter_Id            => null,
	      p_Position_Set_Group_Id   => l_position_set_group_id,
/* Budget Revision Rules Enhancement Start */
	      p_rule_id                 => null,
	      p_apply_balance_flag      => null,
/* Budget Revision Rules Enhancement End */
	      p_Effective_Start_Date    =>
				      l_position_sets_rec.effective_start_date,
	      p_Effective_End_Date      =>
				      l_position_sets_rec.effective_end_date,
	      p_last_update_date        => l_last_update_date,
	      p_last_updated_by         => l_last_updated_by,
	      p_last_update_login       => l_last_update_login,
	      p_created_by              => l_created_by,
	      p_creation_date           => l_creation_date
	   );
	  debug( 'New Relation Created for Set group ID:'||
						l_position_set_group_id);

	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	     debug( 'Set Relation not created for position set id
	     : ' || l_account_sets_rec.account_position_set_id);
	     RAISE FND_API.G_EXC_ERROR ;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     debug( 'Set Relation not created for position set id
	     : ' || l_account_sets_rec.account_position_set_id);
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	  END IF;

	  End Loop;
	  End Loop;
	  End Loop;
    End Loop;

  -- End of API body.

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count AND if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Copy_Pay_Elements_Pvt;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Copy_Pay_Elements_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Copy_Pay_Elements_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Copy_Pay_Elements;

/*===========================================================================+
 |                     PROCEDURE debug (Private)                                |
 +===========================================================================*/
--
-- Private procedure to print debug info

PROCEDURE debug
(
  p_message                   IN   VARCHAR2
)
IS
--
BEGIN

  IF g_debug_flag = 'Y' THEN
    null;
--  dbms_output.put_line(p_message) ;
  END IF;

END debug ;

END PSB_PAY_ELEMENTS_PVT;

/
