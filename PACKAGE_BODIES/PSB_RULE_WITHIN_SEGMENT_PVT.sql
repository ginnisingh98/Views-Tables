--------------------------------------------------------
--  DDL for Package Body PSB_RULE_WITHIN_SEGMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_RULE_WITHIN_SEGMENT_PVT" AS
 /* $Header: PSBVWSPB.pls 120.2 2005/07/13 11:31:26 shtripat noship $ */


  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_RULE_WITHIN_SEGMENT_PVT';

procedure INSERT_ROW (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_ROWID                       IN OUT  NOCOPY  VARCHAR2,
  P_RULE_ID                     IN      NUMBER,
  P_SEGMENT_NAME                IN      VARCHAR2,
  P_APPLICATION_COLUMN_NAME     IN      VARCHAR2,
  p_Last_Update_Date                    DATE,
  p_Last_Updated_By                     NUMBER,
  p_Last_Update_Login                   NUMBER,
  p_Created_By                          NUMBER,
  p_Creation_Date                       DATE
) is
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  cursor C is
  select ROWID
  from PSB_RULE_WITHIN_SEGMENT
  where RULE_ID = P_RULE_ID;

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

  insert into PSB_RULE_WITHIN_SEGMENT (
    RULE_ID,
    SEGMENT_NAME,
    APPLICATION_COLUMN_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_RULE_ID,
    P_SEGMENT_NAME,
    P_APPLICATION_COLUMN_NAME,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into P_ROWID;
  if (c%notfound) then
    close c;
    raise FND_API.G_EXC_ERROR;
  end if;
  close c;

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

procedure LOCK_ROW (
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  p_lock_row                  OUT  NOCOPY      VARCHAR2,
  --
  P_RULE_ID                   IN       NUMBER,
  P_SEGMENT_NAME              IN       VARCHAR2,
  P_APPLICATION_COLUMN_NAME   IN       VARCHAR2
) is
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  Counter NUMBER;
  cursor c1 is select
      SEGMENT_NAME, APPLICATION_COLUMN_NAME
    from PSB_RULE_WITHIN_SEGMENT
    where RULE_ID = P_RULE_ID
    for update of RULE_ID nowait;
  tlinfo c1%rowtype;

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
  --
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  if ( (tlinfo.SEGMENT_NAME = P_SEGMENT_NAME)
	   AND (tlinfo.APPLICATION_COLUMN_NAME = P_APPLICATION_COLUMN_NAME)
  ) then
     p_lock_row  :=  FND_API.G_TRUE;
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
    p_lock_row  :=  FND_API.G_FALSE;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_lock_row  :=  FND_API.G_FALSE;
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

procedure UPDATE_ROW (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_RULE_ID                     IN      NUMBER,
  P_SEGMENT_NAME                IN      VARCHAR2,
  P_APPLICATION_COLUMN_NAME     IN      VARCHAR2,
  p_Last_Update_Date                    DATE,
  p_Last_Updated_By                     NUMBER,
  p_Last_Update_Login                   NUMBER
) is
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
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
  update PSB_RULE_WITHIN_SEGMENT set
    SEGMENT_NAME                = P_SEGMENT_NAME,
    APPLICATION_COLUMN_NAME     = P_APPLICATION_COLUMN_NAME,
    LAST_UPDATE_DATE            = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY             = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN           = P_LAST_UPDATE_LOGIN
  where RULE_ID = P_RULE_ID
  ;
  if (sql%notfound) then
    raise FND_API.G_EXC_ERROR;
  end if;
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


procedure DELETE_ROW (
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  P_RULE_ID                   IN       NUMBER,
  P_APPLICATION_COLUMN_NAME   IN       VARCHAR2
) is
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
  delete from PSB_RULE_WITHIN_SEGMENT
  where RULE_ID = P_RULE_ID
  and APPLICATION_COLUMN_NAME = P_APPLICATION_COLUMN_NAME;
  if (sql%notfound) then
    raise no_data_found;
  end if;
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


FUNCTION VALIDATE_ACCOUNT_SEGMENT (
  p_str                         IN      VARCHAR2,
  p_sets                        IN      VARCHAR2,
  p_chart_of_accounts_id        IN      VARCHAR2,
  p_app_column_name             IN      VARCHAR2
)  RETURN BOOLEAN
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Validate_Account_Segment';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  TYPE SegmentCurTyp IS REF CURSOR;
  cur                   SegmentCurTyp;
  segmentno             VARCHAR2(30);

  l_sql_validate        VARCHAR2(4000);
  l_sql_str             VARCHAR2(3000);
  l_sql_sets            VARCHAR2(3000);

/* Bug No 2131859 Start */
  ctr1                  NUMBER := 0;
  ctr2                  NUMBER := 0;
/* Bug No 2131859 End */

  --
BEGIN
  --
  --  Building query for finding segment numbers for a particular segment
  --

  l_sql_str :=  'SELECT distinct glcc.'||p_app_column_name||
		' FROM gl_code_combinations glcc,'||
		' psb_account_position_set_lines apsl'||
		' where glcc.chart_of_accounts_id = '||p_chart_of_accounts_id||
		' AND apsl.account_position_set_id in '||p_str||
		' AND glcc.'||p_app_column_name||
		' BETWEEN apsl.'||p_app_column_name||
		'_low AND apsl.'||p_app_column_name||
		'_high';

  l_sql_sets := 'SELECT distinct glcc.'||p_app_column_name||
		' FROM gl_code_combinations glcc,'||
		' psb_account_position_set_lines apsl'||
		' where glcc.chart_of_accounts_id = '||p_chart_of_accounts_id||
		' AND apsl.account_position_set_id in '||p_sets||
		' AND glcc.'||p_app_column_name||
		' BETWEEN apsl.'||p_app_column_name||
		'_low AND apsl.'||p_app_column_name||
		'_high';

/* Bug No 2131859 Start */
  OPEN cur FOR l_sql_str;
  LOOP
     FETCH cur INTO segmentno;
     if (cur%notfound) then
	EXIT;
     else
	ctr1 := ctr1 + 1;
     end if;
  END LOOP;

  OPEN cur FOR l_sql_sets;
  LOOP
     FETCH cur INTO segmentno;
     if (cur%notfound) then
	EXIT;
     else
	ctr2 := ctr2 + 1;
     end if;
  END LOOP;

  IF ctr1 > ctr2 then
	l_sql_validate := l_sql_str||' minus '||l_sql_sets;
  ELSE
	l_sql_validate := l_sql_sets||' minus '||l_sql_str;
  END IF;
/* Bug No 2131859 End */

  OPEN cur FOR l_sql_validate;
--  USING P_STR, P_SETS, P_CHART_OF_ACCOUNTS_ID;

  LOOP
	FETCH cur INTO segmentno;

	if (cur%notfound) then
	   RETURN(TRUE);
	else
	   RETURN(FALSE);
	end if;
	EXIT;
  END LOOP;
  CLOSE cur;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    RETURN (FALSE);

END Validate_Account_Segment;


end PSB_RULE_WITHIN_SEGMENT_PVT;

/
