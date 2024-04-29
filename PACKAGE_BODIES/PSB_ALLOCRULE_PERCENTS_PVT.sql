--------------------------------------------------------
--  DDL for Package Body PSB_ALLOCRULE_PERCENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_ALLOCRULE_PERCENTS_PVT" AS
/* $Header: PSBVARPB.pls 120.2 2005/07/13 11:23:16 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_ALLOCRULE_PERCENTS_PVT';
  G_DBUG              VARCHAR2(2000);

/* ----------------------------------------------------------------------- */

PROCEDURE Insert_Row
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  P_ALLOCATION_RULE_PERCENT_ID  IN OUT  NOCOPY NUMBER,
  P_ALLOCATION_RULE_ID   IN     NUMBER,
  P_PERIOD_NUM           IN     NUMBER,
  P_MONTHLY              IN     NUMBER,
  P_QUARTERLY            IN     NUMBER,
  P_SEMI_ANNUAL          IN     NUMBER,
  P_ATTRIBUTE1           IN     VARCHAR2,
  P_ATTRIBUTE2           IN     VARCHAR2,
  P_ATTRIBUTE3           IN     VARCHAR2,
  P_ATTRIBUTE4           IN     VARCHAR2,
  P_ATTRIBUTE5           IN     VARCHAR2,
  P_CONTEXT              IN     VARCHAR2,
  P_LAST_UPDATE_DATE     IN     DATE,
  P_LAST_UPDATED_BY      IN     NUMBER,
  P_LAST_UPDATE_LOGIN    IN     NUMBER,
  P_CREATED_BY           IN     NUMBER,
  P_CREATION_DATE        IN     DATE
)   IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_allocation_rule_percent_id   NUMBER         ;


 CURSOR C IS
 select PSB_Allocrule_percents_S.NEXTVAL from DUAL ;
BEGIN

  -- Standard Start of API savepoint

     SAVEPOINT Insert_Row_Pvt;

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
  OPEN C;

  FETCH C into l_allocation_rule_percent_id;
  P_allocation_rule_percent_id := l_allocation_rule_percent_id;
  CLOSE C;

  INSERT INTO PSB_ALLOCRULE_PERCENTS (
	      allocation_rule_percent_id,
	      allocation_rule_id,
	      number_of_periods,
	      period_num,
	      percent,
	      last_update_date,
	      last_updated_by,
	      last_update_login,
	      created_by,
	      creation_date,
	      attribute1,
	      attribute2,
	      attribute3,
	      attribute4,
	      attribute5,
	      context)
     VALUES  (
	      P_ALLOCATION_RULE_PERCENT_ID,
	      P_ALLOCATION_RULE_ID,
	      12,
	      P_PERIOD_NUM,
	      P_MONTHLY,
	      P_LAST_UPDATE_DATE,
	      P_LAST_UPDATED_BY,
	      P_LAST_UPDATE_LOGIN,
	      P_CREATED_BY,
	      P_CREATION_DATE,
	      P_ATTRIBUTE1,
	      P_ATTRIBUTE2,
	      P_ATTRIBUTE3,
	      P_ATTRIBUTE4,
	      P_ATTRIBUTE5,
	      P_CONTEXT);

  OPEN C;

  FETCH C into l_allocation_rule_percent_id;
  P_allocation_rule_percent_id := l_allocation_rule_percent_id;
  CLOSE C;

  INSERT INTO PSB_ALLOCRULE_PERCENTS (
	      allocation_rule_percent_id,
	      allocation_rule_id,
	      number_of_periods,
	      period_num,
	      percent,
	      last_update_date,
	      last_updated_by,
	      last_update_login,
	      created_by,
	      creation_date,
	      attribute1,
	      attribute2,
	      attribute3,
	      attribute4,
	      attribute5,
	      context)
     VALUES  (
	      P_ALLOCATION_RULE_PERCENT_ID,
	      P_ALLOCATION_RULE_ID,
	      4,
	      P_PERIOD_NUM,
	      P_QUARTERLY,
	      P_LAST_UPDATE_DATE,
	      P_LAST_UPDATED_BY,
	      P_LAST_UPDATE_LOGIN,
	      P_CREATED_BY,
	      P_CREATION_DATE,
	      P_ATTRIBUTE1,
	      P_ATTRIBUTE2,
	      P_ATTRIBUTE3,
	      P_ATTRIBUTE4,
	      P_ATTRIBUTE5,
	      P_CONTEXT);

  OPEN C;

  FETCH C into l_allocation_rule_percent_id;
  P_allocation_rule_percent_id := l_allocation_rule_percent_id;
  CLOSE C;

  INSERT INTO PSB_ALLOCRULE_PERCENTS (
	      allocation_rule_percent_id,
	      allocation_rule_id,
	      number_of_periods,
	      period_num,
	      percent,
	      last_update_date,
	      last_updated_by,
	      last_update_login,
	      created_by,
	      creation_date,
	      attribute1,
	      attribute2,
	      attribute3,
	      attribute4,
	      attribute5,
	      context)
     VALUES  (
	      P_ALLOCATION_RULE_PERCENT_ID,
	      P_ALLOCATION_RULE_ID,
	      2,
	      P_PERIOD_NUM,
	      P_SEMI_ANNUAL,
	      P_LAST_UPDATE_DATE,
	      P_LAST_UPDATED_BY,
	      P_LAST_UPDATE_LOGIN,
	      P_CREATED_BY,
	      P_CREATION_DATE,
	      P_ATTRIBUTE1,
	      P_ATTRIBUTE2,
	      P_ATTRIBUTE3,
	      P_ATTRIBUTE4,
	      P_ATTRIBUTE5,
	      P_CONTEXT);


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

     rollback to Insert_Row_Pvt;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Insert_Row_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Insert_Row_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Insert_Row;

PROCEDURE Update_Row
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  P_ALLOCATION_RULE_ID   IN     NUMBER,
  P_PERIOD_NUM           IN     NUMBER,
  P_MONTHLY              IN     NUMBER,
  P_QUARTERLY            IN     NUMBER,
  P_SEMI_ANNUAL          IN     NUMBER,
  P_ATTRIBUTE1           IN     VARCHAR2,
  P_ATTRIBUTE2           IN     VARCHAR2,
  P_ATTRIBUTE3           IN     VARCHAR2,
  P_ATTRIBUTE4           IN     VARCHAR2,
  P_ATTRIBUTE5           IN     VARCHAR2,
  P_CONTEXT              IN     VARCHAR2,
  P_LAST_UPDATE_DATE     IN     DATE,
  P_LAST_UPDATED_BY      IN     NUMBER,
  P_LAST_UPDATE_LOGIN    IN     NUMBER
)   IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
  l_api_version         CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

     SAVEPOINT Update_Row_Pvt;

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

  UPDATE PSB_ALLOCRULE_PERCENTS
  SET
	      percent            = P_MONTHLY,
	      last_update_date   = P_LAST_UPDATE_DATE,
	      last_updated_by    = P_LAST_UPDATED_BY,
	      last_update_login  = P_LAST_UPDATE_LOGIN,
	      attribute1         = P_ATTRIBUTE1,
	      attribute2         = P_ATTRIBUTE2,
	      attribute3         = P_ATTRIBUTE3,
	      attribute4         = P_ATTRIBUTE4,
	      attribute5         = P_ATTRIBUTE5,
	      context            = P_CONTEXT
  WHERE       allocation_rule_id = P_ALLOCATION_RULE_ID
    AND       number_of_periods  = 12
    AND       period_num         = P_PERIOD_NUM;

  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;


  UPDATE PSB_ALLOCRULE_PERCENTS
  SET
	      percent            = P_QUARTERLY,
	      last_update_date   = P_LAST_UPDATE_DATE,
	      last_updated_by    = P_LAST_UPDATED_BY,
	      last_update_login  = P_LAST_UPDATE_LOGIN,
	      attribute1         = P_ATTRIBUTE1,
	      attribute2         = P_ATTRIBUTE2,
	      attribute3         = P_ATTRIBUTE3,
	      attribute4         = P_ATTRIBUTE4,
	      attribute5         = P_ATTRIBUTE5,
	      context            = P_CONTEXT
  WHERE       allocation_rule_id = P_ALLOCATION_RULE_ID
    AND       number_of_periods  = 4
    AND       period_num         = P_PERIOD_NUM;

  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;

  UPDATE PSB_ALLOCRULE_PERCENTS
  SET
	      percent            = P_SEMI_ANNUAL,
	      last_update_date   = P_LAST_UPDATE_DATE,
	      last_updated_by    = P_LAST_UPDATED_BY,
	      last_update_login  = P_LAST_UPDATE_LOGIN,
	      attribute1         = P_ATTRIBUTE1,
	      attribute2         = P_ATTRIBUTE2,
	      attribute3         = P_ATTRIBUTE3,
	      attribute4         = P_ATTRIBUTE4,
	      attribute5         = P_ATTRIBUTE5,
	      context            = P_CONTEXT
  WHERE       allocation_rule_id = P_ALLOCATION_RULE_ID
    AND       number_of_periods  = 2
    AND       period_num         = P_PERIOD_NUM;

  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Update_Row_Pvt;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Update_Row_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Update_Row_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Update_Row;

PROCEDURE Delete_Row
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  P_ALLOCATION_RULE_ID   IN     NUMBER,
  P_PERIOD_NUM           IN     NUMBER
)   IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Delete_Row';
  l_api_version         CONSTANT NUMBER         := 1.0;

 CURSOR C IS
 select PSB_Allocrule_percents_S.NEXTVAL from DUAL ;
BEGIN

  -- Standard Start of API savepoint

     SAVEPOINT Delete_Row_Pvt;

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

  DELETE FROM PSB_ALLOCRULE_PERCENTS
  WHERE  ALLOCATION_RULE_ID = P_ALLOCATION_RULE_ID
    AND  PERIOD_NUM         = P_PERIOD_NUM;

  IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
  END IF;

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

     rollback to Delete_Row_Pvt;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Delete_Row_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Delete_Row_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Delete_Row;

PROCEDURE Lock_Row
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_lock_row            OUT  NOCOPY     VARCHAR2,
  P_ALLOCATION_RULE_ID   IN     NUMBER,
  P_PERIOD_NUM           IN     NUMBER,
  P_MONTHLY              IN     NUMBER,
  P_QUARTERLY            IN     NUMBER,
  P_SEMI_ANNUAL          IN     NUMBER
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_lock_row1           number(1);
  l_lock_row2           number(1);
  l_lock_row3           number(1);

  Counter NUMBER;
  CURSOR C IS
	 SELECT ALLOCATION_RULE_ID,
		PERIOD_NUM,
		NUMBER_OF_PERIODS,
		PERCENT
	   FROM PSB_ALLOCRULE_PERCENTS
	  WHERE ALLOCATION_RULE_ID = P_ALLOCATION_RULE_ID
	    AND PERIOD_NUM         = P_PERIOD_NUM
	  ORDER BY NUMBER_OF_PERIODS
	 FOR UPDATE OF PERCENT NOWAIT;

  Recinfo C%ROWTYPE;
BEGIN

  -- Standard Start of API savepoint

     SAVEPOINT Lock_Row_Pvt;

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

     OPEN C;


     FETCH C INTO Recinfo;

     IF (C%NOTFOUND) THEN
	CLOSE C;
	FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
     END IF;

    IF ((Recinfo.allocation_rule_id = P_ALLOCATION_RULE_ID) AND
	( (Recinfo.period_num = P_PERIOD_NUM) OR
	  ((Recinfo.period_num  IS NULL ) AND (P_PERIOD_NUM IS NULL)))
    AND ( (Recinfo.number_of_periods = 2) OR
	  ((Recinfo.number_of_periods  IS NULL ) AND (P_SEMI_ANNUAL IS NULL)))
    AND ( (Recinfo.percent = P_SEMI_ANNUAL) OR
	  ((Recinfo.percent  IS NULL ) AND (P_SEMI_ANNUAL IS NULL)))) THEN
    l_lock_row1 := 1;
    ELSE
      FND_MESSAGE.Set_Name('FND','FORM_RECORD_CHANGED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

     FETCH C INTO Recinfo;

     IF (C%NOTFOUND) THEN
	CLOSE C;
	FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
     END IF;

    IF ((Recinfo.allocation_rule_id = P_ALLOCATION_RULE_ID) AND
	( (Recinfo.period_num = P_PERIOD_NUM) OR
	  ((Recinfo.period_num  IS NULL ) AND (P_PERIOD_NUM IS NULL)))
    AND ( (Recinfo.number_of_periods = 4) OR
	  ((Recinfo.number_of_periods  IS NULL ) AND (P_QUARTERLY IS NULL)))
    AND ( (Recinfo.percent = P_QUARTERLY) OR
	  ((Recinfo.percent  IS NULL ) AND (P_QUARTERLY IS NULL)))) THEN
    l_lock_row2 := 1;
    ELSE
      FND_MESSAGE.Set_Name('FND','FORM_RECORD_CHANGED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

     FETCH C INTO Recinfo;

     IF (C%NOTFOUND) THEN
	CLOSE C;
	FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
     END IF;

    IF ((Recinfo.allocation_rule_id = P_ALLOCATION_RULE_ID) AND
	( (Recinfo.period_num = P_PERIOD_NUM) OR
	  ((Recinfo.period_num  IS NULL ) AND (P_PERIOD_NUM IS NULL)))
    AND ( (Recinfo.number_of_periods = 12) OR
	  ((Recinfo.number_of_periods  IS NULL ) AND (P_MONTHLY IS NULL)))
    AND ( (Recinfo.percent = P_MONTHLY) OR
	  ((Recinfo.percent  IS NULL ) AND (P_MONTHLY IS NULL)))) THEN
    l_lock_row3 := 1;
    ELSE
      FND_MESSAGE.Set_Name('FND','FORM_RECORD_CHANGED');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    CLOSE C;
    if ((l_lock_row1 = 1) AND (l_lock_row2 = 1) AND (l_lock_row3 = 1))then
    p_lock_row := FND_API.G_TRUE;
    end if;
  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Lock_Row_Pvt;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Lock_Row_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Lock_Row_Pvt;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Lock_Row;

  -- API body
  -- Get Debug Information

  -- This Module is used to retrieve Debug Information for this routine. It
  -- prints Debug Information when run as a Batch Process from SQL*Plus. For
  -- the Debug Information to be printed on the Screen, the SQL*Plus parameter
  -- 'Serveroutput' should be set to 'ON'

  FUNCTION get_debug RETURN VARCHAR2 IS
  BEGIN

    return(g_dbug);

  END get_debug;

/* ----------------------------------------------------------------------- */

END PSB_ALLOCRULE_PERCENTS_PVT;

/
