--------------------------------------------------------
--  DDL for Package Body PSB_DEFAULT_ASSIGNMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_DEFAULT_ASSIGNMENTS_PVT" AS
/* $Header: PSBVPDAB.pls 120.2 2005/07/13 11:27:57 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_DEFAULT_ASSIGNMENTS_PVT';

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
  P_DEFAULT_ASSIGNMENT_ID            IN      NUMBER,
  P_DEFAULT_RULE_ID                  in      NUMBER,
  P_ASSIGNMENT_TYPE                  IN      VARCHAR2,
  P_ATTRIBUTE_ID                     IN      NUMBER,
  P_ATTRIBUTE_VALUE_ID               IN      NUMBER,
  P_ATTRIBUTE_VALUE                  IN      VARCHAR2,
  P_PAY_ELEMENT_ID                   IN      NUMBER,
  P_PAY_ELEMENT_OPTION_ID            IN      NUMBER,
  P_PAY_BASIS                        IN      VARCHAR2,
  P_ELEMENT_VALUE_TYPE               IN      VARCHAR2,
  P_ELEMENT_VALUE                    IN      NUMBER,
  P_CURRENCY_CODE                    IN      VARCHAR2,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER,
  P_CREATED_BY                       in      NUMBER,
  P_CREATION_DATE                    in      DATE
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'INSERT_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_row_id              varchar2(40);
  --
  cursor c1 is
     select ROWID from psb_default_assignments
     where default_rule_id = p_default_rule_id
     and default_assignment_id = p_default_assignment_id;

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
  INSERT INTO psb_default_assignments
  (
  DEFAULT_ASSIGNMENT_ID            ,
  DEFAULT_RULE_ID                  ,
  ASSIGNMENT_TYPE                  ,
  ATTRIBUTE_ID                     ,
  ATTRIBUTE_VALUE_ID               ,
  ATTRIBUTE_VALUE                  ,
  PAY_ELEMENT_ID                   ,
  PAY_ELEMENT_OPTION_ID            ,
  PAY_BASIS                        ,
  ELEMENT_VALUE_TYPE               ,
  ELEMENT_VALUE                    ,
  CURRENCY_CODE                    ,
  LAST_UPDATE_DATE                 ,
  LAST_UPDATED_BY                  ,
  LAST_UPDATE_LOGIN                ,
  CREATED_BY                       ,
  CREATION_DATE
  )
  VALUES
  (
  P_DEFAULT_ASSIGNMENT_ID           ,
  P_DEFAULT_RULE_ID                 ,
  P_ASSIGNMENT_TYPE                 ,
  P_ATTRIBUTE_ID                    ,
  P_ATTRIBUTE_VALUE_ID              ,
  P_ATTRIBUTE_VALUE                 ,
  P_PAY_ELEMENT_ID                  ,
  P_PAY_ELEMENT_OPTION_ID           ,
  P_PAY_BASIS                       ,
  P_ELEMENT_VALUE_TYPE              ,
  P_ELEMENT_VALUE                   ,
  P_CURRENCY_CODE                   ,
  P_LAST_UPDATE_DATE                ,
  P_LAST_UPDATED_BY                 ,
  P_LAST_UPDATE_LOGIN               ,
  P_CREATED_BY                      ,
  P_CREATION_DATE
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
  P_DEFAULT_ASSIGNMENT_ID            IN      NUMBER,
  P_DEFAULT_RULE_ID                  in      NUMBER,
  P_ASSIGNMENT_TYPE                  IN      VARCHAR2,
  P_ATTRIBUTE_ID                     IN      NUMBER,
  P_ATTRIBUTE_VALUE_ID               IN      NUMBER,
  P_ATTRIBUTE_VALUE                  IN      VARCHAR2,
  P_PAY_ELEMENT_ID                   IN      NUMBER,
  P_PAY_ELEMENT_OPTION_ID            IN      NUMBER,
  P_PAY_BASIS                        IN      VARCHAR2,
  P_ELEMENT_VALUE_TYPE               IN      VARCHAR2,
  P_ELEMENT_VALUE                    IN      NUMBER,
  P_CURRENCY_CODE                    IN      VARCHAR2,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER
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
  UPDATE psb_default_assignments SET
  DEFAULT_ASSIGNMENT_ID           =  P_DEFAULT_ASSIGNMENT_ID,
  DEFAULT_RULE_ID                 =  P_DEFAULT_RULE_ID,
  ASSIGNMENT_TYPE                 =  P_ASSIGNMENT_TYPE,
  ATTRIBUTE_ID                    =  P_ATTRIBUTE_ID,
  ATTRIBUTE_VALUE_ID              =  P_ATTRIBUTE_VALUE_ID,
  ATTRIBUTE_VALUE                 =  P_ATTRIBUTE_VALUE,
  PAY_ELEMENT_ID                  =  P_PAY_ELEMENT_ID,
  PAY_ELEMENT_OPTION_ID           =  P_PAY_ELEMENT_OPTION_ID,
  PAY_BASIS                       =  P_PAY_BASIS,
  ELEMENT_VALUE_TYPE              =  P_ELEMENT_VALUE_TYPE,
  ELEMENT_VALUE                   =  P_ELEMENT_VALUE,
  CURRENCY_CODE                   =  P_CURRENCY_CODE,
  LAST_UPDATE_DATE                =  P_LAST_UPDATE_DATE,
  LAST_UPDATED_BY                 =  P_LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN               =  P_LAST_UPDATE_LOGIN
  where ROWID = P_ROW_ID;

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
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  --
  P_ROW_ID              IN      VARCHAR2
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


  --Delete the record in the table
  DELETE FROM psb_default_assignments
  where rowid = p_row_id;


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
  p_row_locked                  OUT  NOCOPY     VARCHAR2,
  --
  P_ROW_ID                           IN      VARCHAR2,
  P_DEFAULT_ASSIGNMENT_ID            IN      NUMBER,
  P_DEFAULT_RULE_ID                  in      NUMBER,
  P_ASSIGNMENT_TYPE                  IN      VARCHAR2,
  P_ATTRIBUTE_ID                     IN      NUMBER,
  P_ATTRIBUTE_VALUE_ID               IN      NUMBER,
  P_ATTRIBUTE_VALUE                  IN      VARCHAR2,
  P_PAY_ELEMENT_ID                   IN      NUMBER,
  P_PAY_ELEMENT_OPTION_ID            IN      NUMBER,
  P_PAY_BASIS                        IN      VARCHAR2,
  P_ELEMENT_VALUE_TYPE               IN      VARCHAR2,
  P_ELEMENT_VALUE                    IN      NUMBER,
  P_CURRENCY_CODE                    IN      VARCHAR2
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'LOCK_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;
  --
  counter number;

  CURSOR C IS SELECT * FROM psb_default_assignments
  WHERE rowid = p_row_id
  FOR UPDATE of default_assignment_id NOWAIT;
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
	 (Recinfo.default_assignment_id = p_default_assignment_id)
	 AND (Recinfo.default_rule_id = p_default_rule_id)
	 AND (Recinfo.assignment_type = p_assignment_type)

	 AND ((Recinfo.attribute_id = p_attribute_id)
	      OR((Recinfo.attribute_id IS NULL)
		 AND(p_attribute_id IS NULL)))
	 AND ((Recinfo.attribute_value_id = p_attribute_value_id)
	      OR((Recinfo.attribute_value_id IS NULL)
		 AND(p_attribute_value_id IS NULL)))
	 AND ((Recinfo.attribute_value = p_attribute_value)
	      OR((Recinfo.attribute_value IS NULL)
		 AND(p_attribute_value IS NULL)))
	 AND ((Recinfo.pay_element_id = p_pay_element_id)
	      OR((Recinfo.pay_element_id IS NULL)
		 AND(p_pay_element_id IS NULL)))
	 AND ((Recinfo.pay_element_option_id = p_pay_element_option_id)
	      OR((Recinfo.pay_element_option_id IS NULL)
		 AND(p_pay_element_option_id IS NULL)))
	 AND ((Recinfo.pay_basis = p_pay_basis)
	      OR((Recinfo.pay_basis IS NULL)
		 AND(p_pay_basis IS NULL)))
	 AND ((Recinfo.element_value_type = p_element_value_type)
	      OR((Recinfo.element_value_type IS NULL)
		 AND(p_element_value_type IS NULL)))
	 AND ((Recinfo.element_value = p_element_value)
	      OR((Recinfo.element_value IS NULL)
		 AND(p_element_value IS NULL)))
	 AND ((Recinfo.currency_code = p_currency_code)
	      OR((Recinfo.currency_code IS NULL)
		 AND(p_currency_code IS NULL)))

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
  p_Return_Value                     IN OUT  NOCOPY   VARCHAR2,
  --
  P_DEFAULT_RULE_ID                  IN      NUMBER,
  P_DEFAULT_ASSIGNMENT_ID            IN      NUMBER,
  P_ATTRIBUTE_ID                     IN      NUMBER,
  P_PAY_ELEMENT_ID                   IN      NUMBER,
  P_PAY_ELEMENT_OPTION_ID            IN      NUMBER

)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Unique';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_tmp VARCHAR2(1);

  CURSOR c IS
    SELECT '1'
    FROM psb_default_assignments
    WHERE   ( attribute_id = p_attribute_id
	     OR pay_element_id = p_pay_element_id
	     OR (pay_element_option_id = p_pay_element_option_id
		 and pay_element_id = p_pay_element_id )
	     )
    AND (default_rule_id = p_default_rule_id )
    AND (default_assignment_id <> p_default_assignment_id);

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

END PSB_DEFAULT_ASSIGNMENTS_PVT;

/
