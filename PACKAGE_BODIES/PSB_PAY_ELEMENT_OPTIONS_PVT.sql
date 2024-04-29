--------------------------------------------------------
--  DDL for Package Body PSB_PAY_ELEMENT_OPTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_PAY_ELEMENT_OPTIONS_PVT" AS
/* $Header: PSBVOPTB.pls 120.2 2005/07/13 11:27:27 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_PAY_ELEMENT_OPTIONS_PVT';

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
  P_PAY_ELEMENT_OPTION_ID            in      NUMBER,
  P_PAY_ELEMENT_ID                   in      NUMBER,
  P_NAME                             in      VARCHAR2,
  P_GRADE_STEP                       in      NUMBER,
  P_SEQUENCE_NUMBER                  in      NUMBER,
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
     select ROWID from psb_pay_element_options
     where pay_element_option_id = p_pay_element_option_id
     and  pay_element_id = p_pay_element_id;

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
  INSERT INTO psb_pay_element_options
  (
 PAY_ELEMENT_OPTION_ID          ,
 PAY_ELEMENT_ID                 ,
 NAME                           ,
 GRADE_STEP                     ,
 SEQUENCE_NUMBER                ,
 LAST_UPDATE_DATE               ,
 LAST_UPDATED_BY                ,
 LAST_UPDATE_LOGIN              ,
 CREATED_BY                     ,
 CREATION_DATE
  )
  VALUES
  (
 P_PAY_ELEMENT_OPTION_ID          ,
 P_PAY_ELEMENT_ID                 ,
 P_NAME                           ,
 P_GRADE_STEP                     ,
 P_SEQUENCE_NUMBER                ,
 P_LAST_UPDATE_DATE               ,
 P_LAST_UPDATED_BY                ,
 P_LAST_UPDATE_LOGIN              ,
 P_CREATED_BY                     ,
 P_CREATION_DATE
  );

  open c1;
  fetch c1 into l_row_id;
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
  P_PAY_ELEMENT_OPTION_ID            in      NUMBER,
  P_PAY_ELEMENT_ID                   in      NUMBER,
  P_NAME                             in      VARCHAR2,
  P_GRADE_STEP                       in      NUMBER,
  P_SEQUENCE_NUMBER                  in      NUMBER,
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
  UPDATE psb_pay_element_options SET
  NAME                   =  P_NAME                     ,
  GRADE_STEP             =  P_GRADE_STEP               ,
  SEQUENCE_NUMBER        =  P_SEQUENCE_NUMBER          ,
  LAST_UPDATE_DATE       =  P_LAST_UPDATE_DATE         ,
  LAST_UPDATED_BY        =  P_LAST_UPDATED_BY          ,
  LAST_UPDATE_LOGIN      =  P_LAST_UPDATE_LOGIN
  WHERE pay_element_option_id = p_pay_element_option_id
  AND pay_element_id = p_pay_element_id;

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
  P_PAY_ELEMENT_OPTION_ID              IN      NUMBER,
  P_PAY_ELEMENT_ID                     IN      NUMBER
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

 --Deleting detail record from psb_pay_element_options and
 --from psb_pay_element_rates to maintain the isolated delete
 --relation between the master and detail

 DELETE FROM psb_pay_element_rates
 WHERE pay_element_option_id = p_pay_element_option_id
 AND pay_element_id = p_pay_element_id;

 --Delete the record in the master table
 DELETE FROM psb_pay_element_options
 WHERE pay_element_option_id = p_pay_element_option_id
 AND pay_element_id = p_pay_element_id;


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
  P_PAY_ELEMENT_OPTION_ID            in      NUMBER,
  P_PAY_ELEMENT_ID                   in      NUMBER,
  P_NAME                             in      VARCHAR2,
  P_GRADE_STEP                       in      NUMBER,
  P_SEQUENCE_NUMBER                  in      NUMBER

  ) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'LOCK_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;
  --
  counter number;

  CURSOR C IS SELECT * FROM PSB_PAY_ELEMENT_OPTIONS
  WHERE pay_element_option_id = p_pay_element_option_id
  AND pay_element_id = p_pay_element_id
  FOR UPDATE of PAY_ELEMENT_OPTION_Id NOWAIT;
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
	 (Recinfo.pay_element_option_id =  p_pay_element_option_id)
	 AND (Recinfo.pay_element_id = p_pay_element_id)

	  AND ( (Recinfo.name =  p_name)
		 OR ( (Recinfo.name IS NULL)
		       AND (p_name IS NULL)))

	  AND ( (Recinfo.grade_step =  p_grade_step)
		 OR ( (Recinfo.grade_step IS NULL)
		       AND (p_grade_step IS NULL)))

	  AND ( (Recinfo.sequence_number =  p_sequence_number)
		 OR ( (Recinfo.sequence_number IS NULL)
		       AND (p_sequence_number IS NULL)))
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
  p_PAY_ELEMENT_OPTION_ID     IN       NUMBER,
  p_PAY_ELEMENT_ID            IN       NUMBER,
  p_NAME                      IN       VARCHAR2,
  p_GRADE_STEP                IN       NUMBER,
  p_RETURN_VALUE              IN OUT  NOCOPY   VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Unique';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_tmp VARCHAR2(1);

  CURSOR c IS
    SELECT '1'
    FROM psb_pay_element_options
    WHERE name = p_name
    AND   ( (p_pay_element_option_id IS NULL)
	     OR ( pay_element_option_id <> p_pay_element_option_id) )
    AND   ( (pay_element_id = p_pay_element_id) );

  CURSOR c1 IS
    SELECT '1'
    FROM psb_pay_element_options
    WHERE name       = p_name
    AND   grade_step = p_grade_step
    AND   ( (p_pay_element_option_id IS NULL)
	     OR ( pay_element_option_id <> p_pay_element_option_id) )
    AND   ( ( pay_element_id = p_pay_element_id) );
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
  IF p_grade_step IS NULL THEN
     OPEN  c;
     FETCH c INTO l_tmp;
     CLOSE c;
  ELSE
     OPEN  c1;
     FETCH c1 INTO l_tmp;
     CLOSE c1;
  END IF;
  --
  -- p_Return_Value tells whether references exist or not.
  IF (l_tmp IS NULL) THEN
    p_Return_Value := 'FALSE';
  ELSE
    p_Return_Value := 'TRUE';
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
  P_PAY_ELEMENT_OPTION_ID     IN       NUMBER,
  p_PAY_ELEMENT_ID            IN       NUMBER,
  p_Return_Value              IN OUT  NOCOPY   VARCHAR2
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
    FROM psb_position_assignments
    WHERE pay_element_id = p_pay_element_Id
    OR pay_element_option_id = p_pay_element_option_id;

  CURSOR c1 IS
    SELECT '1'
    FROM psb_default_assignments
    WHERE pay_element_id = p_pay_element_Id
    OR pay_element_option_id = p_pay_element_option_id;


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

  OPEN c1;
  FETCH c1 INTO l_tmp1;

  --
  -- p_Return_Value tells whether references exist or not.
  IF ( (l_tmp IS NULL) AND (l_tmp1 IS NULL) ) THEN
    p_Return_Value := 'FALSE';
  ELSE
    p_Return_Value := 'TRUE';
  END IF;

  CLOSE c;
  CLOSE c1;
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




END PSB_PAY_ELEMENT_OPTIONS_PVT;

/
