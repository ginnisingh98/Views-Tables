--------------------------------------------------------
--  DDL for Package Body PSB_ELEMENT_DISTRIBUTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_ELEMENT_DISTRIBUTIONS_PVT" AS
/* $Header: PSBVPEDB.pls 120.2 2005/07/13 11:28:08 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_ELEMENT_DISTRIBUTIONS_PVT';

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
  P_DISTRIBUTION_ID                  IN      NUMBER,
  P_POSITION_SET_GROUP_ID            in      NUMBER,
  P_CHART_OF_ACCOUNTS_ID             IN      NUMBER,
  P_EFFECTIVE_START_DATE             IN      DATE,
  P_EFFECTIVE_END_DATE               IN      DATE,
  P_DISTRIBUTION_PERCENT             IN      NUMBER,
  P_CONCATENATED_SEGMENTS            IN      VARCHAR2,
  P_CODE_COMBINATION_ID              IN      NUMBER,
  P_DISTRIBUTION_SET_ID              IN      NUMBER,
  P_SEGMENT1                         IN      VARCHAR2,
  P_SEGMENT2                         IN      VARCHAR2,
  P_SEGMENT3                         IN      VARCHAR2,
  P_SEGMENT4                         IN      VARCHAR2,
  P_SEGMENT5                         IN      VARCHAR2,
  P_SEGMENT6                         IN      VARCHAR2,
  P_SEGMENT7                         IN      VARCHAR2,
  P_SEGMENT8                         IN      VARCHAR2,
  P_SEGMENT9                         IN      VARCHAR2,
  P_SEGMENT10                        IN      VARCHAR2,
  P_SEGMENT11                        IN      VARCHAR2,
  P_SEGMENT12                        IN      VARCHAR2,
  P_SEGMENT13                        IN      VARCHAR2,
  P_SEGMENT14                        IN      VARCHAR2,
  P_SEGMENT15                        IN      VARCHAR2,
  P_SEGMENT16                        IN      VARCHAR2,
  P_SEGMENT17                        IN      VARCHAR2,
  P_SEGMENT18                        IN      VARCHAR2,
  P_SEGMENT19                        IN      VARCHAR2,
  P_SEGMENT20                        IN      VARCHAR2,
  P_SEGMENT21                        IN      VARCHAR2,
  P_SEGMENT22                        IN      VARCHAR2,
  P_SEGMENT23                        IN      VARCHAR2,
  P_SEGMENT24                        IN      VARCHAR2,
  P_SEGMENT25                        IN      VARCHAR2,
  P_SEGMENT26                        IN      VARCHAR2,
  P_SEGMENT27                        IN      VARCHAR2,
  P_SEGMENT28                        IN      VARCHAR2,
  P_SEGMENT29                        IN      VARCHAR2,
  P_SEGMENT30                        IN      VARCHAR2,
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
     select ROWID from psb_pay_element_distributions
     where distribution_id = p_distribution_id
     and position_set_group_id = p_position_set_group_id
     and chart_of_accounts_id = p_chart_of_accounts_id
     and effective_start_date = p_effective_start_date;

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
  INSERT INTO psb_pay_element_distributions
  (
  DISTRIBUTION_ID                  ,
  POSITION_SET_GROUP_ID            ,
  CHART_OF_ACCOUNTS_ID             ,
  EFFECTIVE_START_DATE             ,
  EFFECTIVE_END_DATE               ,
  DISTRIBUTION_PERCENT             ,
  CONCATENATED_SEGMENTS            ,
  CODE_COMBINATION_ID              ,
  DISTRIBUTION_SET_ID              ,
  SEGMENT1                         ,
  SEGMENT2                         ,
  SEGMENT3                         ,
  SEGMENT4                         ,
  SEGMENT5                         ,
  SEGMENT6                         ,
  SEGMENT7                         ,
  SEGMENT8                         ,
  SEGMENT9                         ,
  SEGMENT10                        ,
  SEGMENT11                        ,
  SEGMENT12                        ,
  SEGMENT13                        ,
  SEGMENT14                        ,
  SEGMENT15                        ,
  SEGMENT16                        ,
  SEGMENT17                        ,
  SEGMENT18                        ,
  SEGMENT19                        ,
  SEGMENT20                        ,
  SEGMENT21                        ,
  SEGMENT22                        ,
  SEGMENT23                        ,
  SEGMENT24                        ,
  SEGMENT25                        ,
  SEGMENT26                        ,
  SEGMENT27                        ,
  SEGMENT28                        ,
  SEGMENT29                        ,
  SEGMENT30                        ,
  LAST_UPDATE_DATE                 ,
  LAST_UPDATED_BY                  ,
  LAST_UPDATE_LOGIN                ,
  CREATED_BY                       ,
  CREATION_DATE
  )
  VALUES
  (
  P_DISTRIBUTION_ID                  ,
  P_POSITION_SET_GROUP_ID            ,
  P_CHART_OF_ACCOUNTS_ID             ,
  P_EFFECTIVE_START_DATE             ,
  P_EFFECTIVE_END_DATE               ,
  P_DISTRIBUTION_PERCENT             ,
  P_CONCATENATED_SEGMENTS            ,
  P_CODE_COMBINATION_ID              ,
  P_DISTRIBUTION_SET_ID              ,
  P_SEGMENT1                         ,
  P_SEGMENT2                         ,
  P_SEGMENT3                         ,
  P_SEGMENT4                         ,
  P_SEGMENT5                         ,
  P_SEGMENT6                         ,
  P_SEGMENT7                         ,
  P_SEGMENT8                         ,
  P_SEGMENT9                         ,
  P_SEGMENT10                        ,
  P_SEGMENT11                        ,
  P_SEGMENT12                        ,
  P_SEGMENT13                        ,
  P_SEGMENT14                        ,
  P_SEGMENT15                        ,
  P_SEGMENT16                        ,
  P_SEGMENT17                        ,
  P_SEGMENT18                        ,
  P_SEGMENT19                        ,
  P_SEGMENT20                        ,
  P_SEGMENT21                        ,
  P_SEGMENT22                        ,
  P_SEGMENT23                        ,
  P_SEGMENT24                        ,
  P_SEGMENT25                        ,
  P_SEGMENT26                        ,
  P_SEGMENT27                        ,
  P_SEGMENT28                        ,
  P_SEGMENT29                        ,
  P_SEGMENT30                        ,
  P_LAST_UPDATE_DATE                 ,
  P_LAST_UPDATED_BY                  ,
  P_LAST_UPDATE_LOGIN                ,
  P_CREATED_BY                       ,
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
  P_DISTRIBUTION_ID                  IN      NUMBER,
  P_POSITION_SET_GROUP_ID            in      NUMBER,
  P_CHART_OF_ACCOUNTS_ID             IN      NUMBER,
  P_EFFECTIVE_START_DATE             IN      DATE,
  P_EFFECTIVE_END_DATE               IN      DATE,
  P_DISTRIBUTION_PERCENT             IN      NUMBER,
  P_CONCATENATED_SEGMENTS            IN      VARCHAR2,
  P_CODE_COMBINATION_ID              IN      NUMBER,
  P_DISTRIBUTION_SET_ID              IN      NUMBER,
  P_SEGMENT1                         IN      VARCHAR2,
  P_SEGMENT2                         IN      VARCHAR2,
  P_SEGMENT3                         IN      VARCHAR2,
  P_SEGMENT4                         IN      VARCHAR2,
  P_SEGMENT5                         IN      VARCHAR2,
  P_SEGMENT6                         IN      VARCHAR2,
  P_SEGMENT7                         IN      VARCHAR2,
  P_SEGMENT8                         IN      VARCHAR2,
  P_SEGMENT9                         IN      VARCHAR2,
  P_SEGMENT10                        IN      VARCHAR2,
  P_SEGMENT11                        IN      VARCHAR2,
  P_SEGMENT12                        IN      VARCHAR2,
  P_SEGMENT13                        IN      VARCHAR2,
  P_SEGMENT14                        IN      VARCHAR2,
  P_SEGMENT15                        IN      VARCHAR2,
  P_SEGMENT16                        IN      VARCHAR2,
  P_SEGMENT17                        IN      VARCHAR2,
  P_SEGMENT18                        IN      VARCHAR2,
  P_SEGMENT19                        IN      VARCHAR2,
  P_SEGMENT20                        IN      VARCHAR2,
  P_SEGMENT21                        IN      VARCHAR2,
  P_SEGMENT22                        IN      VARCHAR2,
  P_SEGMENT23                        IN      VARCHAR2,
  P_SEGMENT24                        IN      VARCHAR2,
  P_SEGMENT25                        IN      VARCHAR2,
  P_SEGMENT26                        IN      VARCHAR2,
  P_SEGMENT27                        IN      VARCHAR2,
  P_SEGMENT28                        IN      VARCHAR2,
  P_SEGMENT29                        IN      VARCHAR2,
  P_SEGMENT30                        IN      VARCHAR2,
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
  UPDATE psb_pay_element_distributions SET
  EFFECTIVE_START_DATE             = P_EFFECTIVE_START_DATE,
  EFFECTIVE_END_DATE               = P_EFFECTIVE_END_DATE,
  DISTRIBUTION_PERCENT             = P_DISTRIBUTION_PERCENT,
  CONCATENATED_SEGMENTS            = P_CONCATENATED_SEGMENTS,
  CODE_COMBINATION_ID              = P_CODE_COMBINATION_ID,
  DISTRIBUTION_SET_ID              = P_DISTRIBUTION_SET_ID,
  SEGMENT1                         = P_SEGMENT1,
  SEGMENT2                         = P_SEGMENT2,
  SEGMENT3                         = P_SEGMENT3,
  SEGMENT4                         = P_SEGMENT4,
  SEGMENT5                         = P_SEGMENT5,
  SEGMENT6                         = P_SEGMENT6,
  SEGMENT7                         = P_SEGMENT7,
  SEGMENT8                         = P_SEGMENT8,
  SEGMENT9                         = P_SEGMENT9,
  SEGMENT10                        = P_SEGMENT10,
  SEGMENT11                        = P_SEGMENT11,
  SEGMENT12                        = P_SEGMENT12,
  SEGMENT13                        = P_SEGMENT13,
  SEGMENT14                        = P_SEGMENT14,
  SEGMENT15                        = P_SEGMENT15,
  SEGMENT16                        = P_SEGMENT16,
  SEGMENT17                        = P_SEGMENT17,
  SEGMENT18                        = P_SEGMENT18,
  SEGMENT19                        = P_SEGMENT19,
  SEGMENT20                        = P_SEGMENT20,
  SEGMENT21                        = P_SEGMENT21,
  SEGMENT22                        = P_SEGMENT22,
  SEGMENT23                        = P_SEGMENT23,
  SEGMENT24                        = P_SEGMENT24,
  SEGMENT25                        = P_SEGMENT25,
  SEGMENT26                        = P_SEGMENT26,
  SEGMENT27                        = P_SEGMENT27,
  SEGMENT28                        = P_SEGMENT28,
  SEGMENT29                        = P_SEGMENT29,
  SEGMENT30                        = P_SEGMENT30,
  LAST_UPDATE_DATE                 = P_LAST_UPDATE_DATE,
  LAST_UPDATED_BY                  = P_LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN                = P_LAST_UPDATE_LOGIN
  where DISTRIBUTION_ID                  = P_DISTRIBUTION_ID
  and   POSITION_SET_GROUP_ID            = P_POSITION_SET_GROUP_ID
  and   CHART_OF_ACCOUNTS_ID             = P_CHART_OF_ACCOUNTS_ID;

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
  P_DISTRIBUTION_ID                  IN      NUMBER,
  P_POSITION_SET_GROUP_ID            IN      NUMBER,
  P_CHART_OF_ACCOUNTS_ID             IN      NUMBER,
  P_EFFECTIVE_START_DATE             IN      DATE
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
  DELETE FROM psb_pay_element_distributions
  where DISTRIBUTION_ID                  = P_DISTRIBUTION_ID
  and   POSITION_SET_GROUP_ID            = P_POSITION_SET_GROUP_ID
  and   CHART_OF_ACCOUNTS_ID             = P_CHART_OF_ACCOUNTS_ID
  and   EFFECTIVE_START_DATE             = P_EFFECTIVE_START_DATE;


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
  P_DISTRIBUTION_ID                  IN      NUMBER,
  P_POSITION_SET_GROUP_ID            in      NUMBER,
  P_CHART_OF_ACCOUNTS_ID             IN      NUMBER,
  P_EFFECTIVE_START_DATE             IN      DATE,
  P_EFFECTIVE_END_DATE               IN      DATE,
  P_DISTRIBUTION_PERCENT             IN      NUMBER,
  P_CONCATENATED_SEGMENTS            IN      VARCHAR2,
  P_CODE_COMBINATION_ID              IN      NUMBER,
  P_DISTRIBUTION_SET_ID              IN      NUMBER,
  P_SEGMENT1                         IN      VARCHAR2,
  P_SEGMENT2                         IN      VARCHAR2,
  P_SEGMENT3                         IN      VARCHAR2,
  P_SEGMENT4                         IN      VARCHAR2,
  P_SEGMENT5                         IN      VARCHAR2,
  P_SEGMENT6                         IN      VARCHAR2,
  P_SEGMENT7                         IN      VARCHAR2,
  P_SEGMENT8                         IN      VARCHAR2,
  P_SEGMENT9                         IN      VARCHAR2,
  P_SEGMENT10                        IN      VARCHAR2,
  P_SEGMENT11                        IN      VARCHAR2,
  P_SEGMENT12                        IN      VARCHAR2,
  P_SEGMENT13                        IN      VARCHAR2,
  P_SEGMENT14                        IN      VARCHAR2,
  P_SEGMENT15                        IN      VARCHAR2,
  P_SEGMENT16                        IN      VARCHAR2,
  P_SEGMENT17                        IN      VARCHAR2,
  P_SEGMENT18                        IN      VARCHAR2,
  P_SEGMENT19                        IN      VARCHAR2,
  P_SEGMENT20                        IN      VARCHAR2,
  P_SEGMENT21                        IN      VARCHAR2,
  P_SEGMENT22                        IN      VARCHAR2,
  P_SEGMENT23                        IN      VARCHAR2,
  P_SEGMENT24                        IN      VARCHAR2,
  P_SEGMENT25                        IN      VARCHAR2,
  P_SEGMENT26                        IN      VARCHAR2,
  P_SEGMENT27                        IN      VARCHAR2,
  P_SEGMENT28                        IN      VARCHAR2,
  P_SEGMENT29                        IN      VARCHAR2,
  P_SEGMENT30                        IN      VARCHAR2
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'LOCK_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;
  --
  counter number;

  CURSOR C IS SELECT * FROM PSB_PAY_ELEMENT_DISTRIBUTIONS
  WHERE DISTRIBUTION_ID                  = P_DISTRIBUTION_ID
  AND   POSITION_SET_GROUP_ID            = P_POSITION_SET_GROUP_ID
  FOR UPDATE of DISTRIBUTION_Id NOWAIT;
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
	 (Recinfo.distribution_id = p_distribution_id)
	 AND (Recinfo.position_set_group_id =  p_position_set_group_id)
	 AND (Recinfo.chart_of_accounts_id = p_chart_of_accounts_id)
	 AND (Recinfo.effective_start_date = p_effective_start_date)

	 AND ((Recinfo.effective_end_date = p_effective_end_date)
	     OR((Recinfo.effective_end_date IS NULL)
		 AND(p_effective_end_date IS NULL)))
	 AND ((Recinfo.distribution_percent = p_distribution_percent)
	     OR((Recinfo.distribution_percent IS NULL)
		 AND(p_distribution_percent IS NULL)))
	 AND ((Recinfo.concatenated_segments = p_concatenated_segments)
	      OR((Recinfo.concatenated_segments IS NULL)
		 AND(p_concatenated_segments IS NULL)))
	 AND ((Recinfo.code_combination_id = p_code_combination_id)
	      OR((Recinfo.code_combination_id IS NULL)
		 AND(p_code_combination_id IS NULL)))
	 AND ((Recinfo.distribution_set_id = p_distribution_set_id)
	      OR((Recinfo.distribution_set_id IS NULL)
		 AND(p_distribution_set_id IS NULL)))
	 AND ((Recinfo.segment1 = p_segment1)
	      OR((Recinfo.segment1 IS NULL)
		 AND(p_segment1 IS NULL)))
	 AND ((Recinfo.segment2 = p_segment2)
	      OR((Recinfo.segment2 IS NULL)
		 AND(p_segment2 IS NULL)))
	 AND ((Recinfo.segment3 = p_segment3)
	      OR((Recinfo.segment3 IS NULL)
		 AND(p_segment3 IS NULL)))
	 AND ((Recinfo.segment4 = p_segment4)
	      OR((Recinfo.segment4 IS NULL)
		 AND(p_segment4 IS NULL)))
	 AND ((Recinfo.segment5 = p_segment5)
	      OR((Recinfo.segment5 IS NULL)
		 AND(p_segment5 IS NULL)))
	 AND ((Recinfo.segment6 = p_segment6)
	      OR((Recinfo.segment6 IS NULL)
		 AND(p_segment6 IS NULL)))
	 AND ((Recinfo.segment7 = p_segment7)
	      OR((Recinfo.segment7 IS NULL)
		 AND(p_segment7 IS NULL)))
	 AND ((Recinfo.segment8 = p_segment8)
	      OR((Recinfo.segment8 IS NULL)
		 AND(p_segment8 IS NULL)))
	 AND ((Recinfo.segment9 = p_segment9)
	      OR((Recinfo.segment9 IS NULL)
		 AND(p_segment9 IS NULL)))
	 AND ((Recinfo.segment10 = p_segment10)
	      OR((Recinfo.segment10 IS NULL)
		 AND(p_segment10 IS NULL)))
	 AND ((Recinfo.segment11 = p_segment11)
	      OR((Recinfo.segment11 IS NULL)
		 AND(p_segment11 IS NULL)))
	 AND ((Recinfo.segment12 = p_segment12)
	      OR((Recinfo.segment12 IS NULL)
		 AND(p_segment12 IS NULL)))
	 AND ((Recinfo.segment13 = p_segment13)
	      OR((Recinfo.segment13 IS NULL)
		 AND(p_segment13 IS NULL)))
	 AND ((Recinfo.segment14 = p_segment14)
	      OR((Recinfo.segment14 IS NULL)
		 AND(p_segment14 IS NULL)))
	 AND ((Recinfo.segment15 = p_segment15)
	      OR((Recinfo.segment15 IS NULL)
		 AND(p_segment15 IS NULL)))
	 AND ((Recinfo.segment16 = p_segment16)
	      OR((Recinfo.segment16 IS NULL)
		 AND(p_segment16 IS NULL)))
	 AND ((Recinfo.segment17 = p_segment17)
	      OR((Recinfo.segment17 IS NULL)
		 AND(p_segment17 IS NULL)))
	 AND ((Recinfo.segment18 = p_segment18)
	      OR((Recinfo.segment18 IS NULL)
		 AND(p_segment18 IS NULL)))
	 AND ((Recinfo.segment19 = p_segment19)
	      OR((Recinfo.segment19 IS NULL)
		 AND(p_segment19 IS NULL)))
	 AND ((Recinfo.segment20 = p_segment20)
	      OR((Recinfo.segment20 IS NULL)
		 AND(p_segment20 IS NULL)))
	 AND ((Recinfo.segment21 = p_segment21)
	      OR((Recinfo.segment21 IS NULL)
		 AND(p_segment21 IS NULL)))
	 AND ((Recinfo.segment22 = p_segment22)
	      OR((Recinfo.segment22 IS NULL)
		 AND(p_segment22 IS NULL)))
	 AND ((Recinfo.segment23 = p_segment23)
	      OR((Recinfo.segment23 IS NULL)
		 AND(p_segment23 IS NULL)))
	 AND ((Recinfo.segment24 = p_segment24)
	      OR((Recinfo.segment24 IS NULL)
		 AND(p_segment24 IS NULL)))
	 AND ((Recinfo.segment25 = p_segment25)
	      OR((Recinfo.segment25 IS NULL)
		 AND(p_segment25 IS NULL)))
	 AND ((Recinfo.segment26 = p_segment26)
	      OR((Recinfo.segment26 IS NULL)
		 AND(p_segment26 IS NULL)))
	 AND ((Recinfo.segment27 = p_segment27)
	      OR((Recinfo.segment27 IS NULL)
		 AND(p_segment27 IS NULL)))
	 AND ((Recinfo.segment28 = p_segment28)
	      OR((Recinfo.segment28 IS NULL)
		 AND(p_segment28 IS NULL)))
	 AND ((Recinfo.segment29 = p_segment29)
	      OR((Recinfo.segment29 IS NULL)
		 AND(p_segment29 IS NULL)))
	 AND ((Recinfo.segment30 = p_segment30)
	      OR((Recinfo.segment30 IS NULL)
		 AND(p_segment30 IS NULL)))
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
  P_DISTRIBUTION_ID           IN       NUMBER,
  P_POSITION_SET_GROUP_ID     IN       NUMBER,
  P_CHART_OF_ACCOUNTS_ID      IN       NUMBER,
  P_EFFECTIVE_START_DATE      IN       DATE,
  P_EFFECTIVE_END_DATE        IN       DATE,
  P_CODE_COMBINATION_ID       IN       NUMBER,
  P_DISTRIBUTION_SET_ID       IN       NUMBER,
  P_Return_Value_date         IN OUT  NOCOPY   VARCHAR2,
  P_Return_Value_ccid         IN OUT  NOCOPY   VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Unique';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_tmp_date VARCHAR2(1);
  l_tmp_ccid varchar2(1);

  CURSOR c_date IS
    SELECT '1'
    FROM psb_pay_element_distributions
    WHERE (  (effective_start_date >= p_effective_start_date
		 AND effective_start_date <= p_effective_end_date)
	      OR (effective_end_date >= p_effective_start_date
		 AND effective_end_date <= p_effective_end_date)  )
    AND   (position_set_group_id = p_position_set_group_id)
    AND   (distribution_set_id <> p_distribution_set_id);

  CURSOR c_ccid IS
    SELECT '1'
    FROM psb_pay_element_distributions
    WHERE code_combination_id = p_code_combination_id
    AND position_set_group_id = p_position_set_group_id
    AND distribution_set_id = p_distribution_set_id;

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

  -- Checking the Psb_element_pos_set_groups table for references.
  OPEN c_date;
  FETCH c_date INTO l_tmp_date;
  --
  -- p_Return_Value tells whether references exist or not.
  IF l_tmp_date IS NULL THEN
    p_Return_Value_date := 'FALSE';
  ELSE
    p_Return_Value_date := 'TRUE';
  END IF;

  CLOSE c_date;

  OPEN c_ccid;
  FETCH c_ccid INTO l_tmp_ccid;
  --
  -- p_Return_Value tells whether references exist or not.
  IF l_tmp_ccid IS NULL THEN
    p_Return_Value_ccid := 'FALSE';
  ELSE
    p_Return_Value_ccid := 'TRUE';
  END IF;

  CLOSE c_ccid;
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


END PSB_ELEMENT_DISTRIBUTIONS_PVT;

/
