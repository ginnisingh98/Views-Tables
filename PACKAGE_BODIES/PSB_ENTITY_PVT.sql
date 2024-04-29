--------------------------------------------------------
--  DDL for Package Body PSB_ENTITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_ENTITY_PVT" AS
 /* $Header: PSBVENPB.pls 120.2 2005/07/13 11:24:48 shtripat ship $ */


  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_ENTITY_PVT';

procedure INSERT_ROW (
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  P_ROWID in OUT  NOCOPY VARCHAR2,
  P_ENTITY_ID in NUMBER,
  P_ENTITY_TYPE in VARCHAR2,
  P_ENTITY_SUBTYPE in VARCHAR2,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_DATA_EXTRACT_ID in NUMBER,
  P_SET_OF_BOOKS_ID in NUMBER,
  P_BUDGET_GROUP_ID in NUMBER := FND_API.G_MISS_NUM,
  P_ALLOCATION_TYPE in VARCHAR2,
  P_BUDGET_YEAR_TYPE_ID in NUMBER,
  P_BALANCE_TYPE in VARCHAR2,
  P_PARAMETER_AUTOINC_RULE in VARCHAR2,
  P_PARAMETER_COMPOUND_ANNUALLY in VARCHAR2,
  P_CURRENCY_CODE in VARCHAR2,
  P_FTE_CONSTRAINT in VARCHAR2,
  P_CONSTRAINT_DETAILED_FLAG in VARCHAR2,
/* Budget Revision Rules Enhancement Start */
  P_APPLY_ACCOUNT_SET_FLAG in VARCHAR2,
  P_BALANCE_ACCOUNT_SET_FLAG in VARCHAR2,
/* Budget Revision Rules Enhancement End */
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_CONTEXT in VARCHAR2,
  P_EFFECTIVE_START_DATE in DATE := FND_API.G_MISS_DATE,
  P_EFFECTIVE_END_DATE   in DATE := FND_API.G_MISS_DATE,
  p_Last_Update_Date                   DATE,
  p_Last_Updated_By                    NUMBER,
  p_Last_Update_Login                  NUMBER,
  p_Created_By                         NUMBER,
  p_Creation_Date                      DATE
) is
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  cursor C is
  select ROWID
  from PSB_ENTITY
  where ENTITY_ID = P_ENTITY_ID;

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

  insert into PSB_ENTITY (
    ENTITY_ID,
    ENTITY_TYPE,
    ENTITY_SUBTYPE,
    NAME,
    DESCRIPTION,
    DATA_EXTRACT_ID,
    SET_OF_BOOKS_ID,
    BUDGET_GROUP_ID,
    ALLOCATION_TYPE,
    BUDGET_YEAR_TYPE_ID,
    BALANCE_TYPE,
    PARAMETER_AUTOINC_RULE,
    PARAMETER_COMPOUND_ANNUALLY,
    CURRENCY_CODE,
    FTE_CONSTRAINT,
    CONSTRAINT_DETAILED_FLAG,
/* Budget Revision Rules Enhancement Start */
    APPLY_ACCOUNT_SET_FLAG,
    BALANCE_ACCOUNT_SET_FLAG,
/* Budget Revision Rules Enhancement End */
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    CONTEXT,
    EFFECTIVE_START_DATE,
    EFFECTIVE_END_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_ENTITY_ID,
    P_ENTITY_TYPE,
    P_ENTITY_SUBTYPE,
    P_NAME,
    P_DESCRIPTION,
    P_DATA_EXTRACT_ID,
    P_SET_OF_BOOKS_ID,
    decode(P_BUDGET_GROUP_ID, FND_API.G_MISS_NUM, null, P_BUDGET_GROUP_ID),
    P_ALLOCATION_TYPE,
    P_BUDGET_YEAR_TYPE_ID,
    P_BALANCE_TYPE,
    P_PARAMETER_AUTOINC_RULE,
    P_PARAMETER_COMPOUND_ANNUALLY,
    P_CURRENCY_CODE,
    P_FTE_CONSTRAINT,
    P_CONSTRAINT_DETAILED_FLAG,
/* Budget Revision Rules Enhancement Start */
    P_APPLY_ACCOUNT_SET_FLAG,
    P_BALANCE_ACCOUNT_SET_FLAG,
/* Budget Revision Rules Enhancement End */
    P_ATTRIBUTE1,
    P_ATTRIBUTE2,
    P_ATTRIBUTE3,
    P_ATTRIBUTE4,
    P_ATTRIBUTE5,
    P_ATTRIBUTE6,
    P_ATTRIBUTE7,
    P_ATTRIBUTE8,
    P_ATTRIBUTE9,
    P_ATTRIBUTE10,
    P_CONTEXT,
    decode(P_EFFECTIVE_START_DATE, FND_API.G_MISS_DATE, null,
			       P_EFFECTIVE_START_DATE),
    decode(P_EFFECTIVE_END_DATE, FND_API.G_MISS_DATE, null,
			       P_EFFECTIVE_END_DATE),
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
  P_ENTITY_ID in NUMBER,
  P_ENTITY_TYPE in VARCHAR2,
  P_ENTITY_SUBTYPE in VARCHAR2,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_DATA_EXTRACT_ID in NUMBER,
  P_SET_OF_BOOKS_ID in NUMBER,
  P_BUDGET_GROUP_ID in NUMBER := FND_API.G_MISS_NUM,
  P_ALLOCATION_TYPE in VARCHAR2,
  P_BUDGET_YEAR_TYPE_ID in NUMBER,
  P_BALANCE_TYPE in VARCHAR2,
  P_PARAMETER_AUTOINC_RULE in VARCHAR2,
  P_PARAMETER_COMPOUND_ANNUALLY in VARCHAR2,
  P_CURRENCY_CODE in VARCHAR2,
  P_FTE_CONSTRAINT in VARCHAR2,
  P_CONSTRAINT_DETAILED_FLAG in VARCHAR2,
/* Budget Revision Rules Enhancement Start */
  P_APPLY_ACCOUNT_SET_FLAG in VARCHAR2,
  P_BALANCE_ACCOUNT_SET_FLAG in VARCHAR2,
/* Budget Revision Rules Enhancement End */
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_CONTEXT in VARCHAR2,
  P_EFFECTIVE_START_DATE in DATE := FND_API.G_MISS_DATE,
  P_EFFECTIVE_END_DATE   in DATE := FND_API.G_MISS_DATE
) is
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  Counter NUMBER;
  cursor c1 is select
      ENTITY_TYPE,
      ENTITY_SUBTYPE,
      NAME,
      DESCRIPTION,
      DATA_EXTRACT_ID,
      SET_OF_BOOKS_ID,
      BUDGET_GROUP_ID,
      ALLOCATION_TYPE,
      BUDGET_YEAR_TYPE_ID,
      BALANCE_TYPE,
      PARAMETER_AUTOINC_RULE,
      PARAMETER_COMPOUND_ANNUALLY,
      CURRENCY_CODE,
      FTE_CONSTRAINT,
      CONSTRAINT_DETAILED_FLAG,
/* Budget Revision Rules Enhancement Start */
      APPLY_ACCOUNT_SET_FLAG,
      BALANCE_ACCOUNT_SET_FLAG,
/* Budget Revision Rules Enhancement End */
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      CONTEXT,
      EFFECTIVE_START_DATE,
      EFFECTIVE_END_DATE
    from PSB_ENTITY
    where ENTITY_ID = P_ENTITY_ID
    for update of ENTITY_ID nowait;
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

  if ( (tlinfo.ENTITY_TYPE = P_ENTITY_TYPE)
      AND (tlinfo.ENTITY_SUBTYPE = P_ENTITY_SUBTYPE)
      AND (tlinfo.NAME = P_NAME)
      AND ((tlinfo.DESCRIPTION = P_DESCRIPTION)
	   OR ((tlinfo.DESCRIPTION is null)
	       AND (P_DESCRIPTION is null)))
      AND ((tlinfo.DATA_EXTRACT_ID = P_DATA_EXTRACT_ID)
	   OR ((tlinfo.DATA_EXTRACT_ID is null)
	       AND (P_DATA_EXTRACT_ID is null)))
      AND ((tlinfo.SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID)
	   OR ((tlinfo.SET_OF_BOOKS_ID is null)
	       AND (P_SET_OF_BOOKS_ID is null)))
      AND ((tlinfo.BUDGET_GROUP_ID = P_BUDGET_GROUP_ID)
	   OR ((tlinfo.BUDGET_GROUP_ID is null)
	       AND (P_BUDGET_GROUP_ID is null))
	   OR ((tlinfo.BUDGET_GROUP_ID is null)
	       AND (P_BUDGET_GROUP_ID = FND_API.G_MISS_NUM)))
      AND ((tlinfo.ALLOCATION_TYPE = P_ALLOCATION_TYPE)
	   OR ((tlinfo.ALLOCATION_TYPE is null)
	       AND (P_ALLOCATION_TYPE is null)))
      AND ((tlinfo.BUDGET_YEAR_TYPE_ID = P_BUDGET_YEAR_TYPE_ID)
	   OR ((tlinfo.BUDGET_YEAR_TYPE_ID is null)
	       AND (P_BUDGET_YEAR_TYPE_ID is null)))
      AND ((tlinfo.BALANCE_TYPE = P_BALANCE_TYPE)
	   OR ((tlinfo.BALANCE_TYPE is null)
	       AND (P_BALANCE_TYPE is null)))
      AND ((tlinfo.PARAMETER_AUTOINC_RULE = P_PARAMETER_AUTOINC_RULE)
	   OR ((tlinfo.PARAMETER_AUTOINC_RULE is null)
	       AND (P_PARAMETER_AUTOINC_RULE is null)))
      AND ((tlinfo.PARAMETER_COMPOUND_ANNUALLY = P_PARAMETER_COMPOUND_ANNUALLY)
	   OR ((tlinfo.PARAMETER_COMPOUND_ANNUALLY is null)
	       AND (P_PARAMETER_COMPOUND_ANNUALLY is null)))
      AND ((tlinfo.CURRENCY_CODE = P_CURRENCY_CODE)
	   OR ((tlinfo.CURRENCY_CODE is null)
	       AND (P_CURRENCY_CODE is null)))
      AND ((tlinfo.FTE_CONSTRAINT = P_FTE_CONSTRAINT)
	   OR ((tlinfo.FTE_CONSTRAINT is null)
	       AND (P_FTE_CONSTRAINT is null)))
      AND ((tlinfo.CONSTRAINT_DETAILED_FLAG = P_CONSTRAINT_DETAILED_FLAG)
	   OR ((tlinfo.CONSTRAINT_DETAILED_FLAG is null)
	       AND (P_CONSTRAINT_DETAILED_FLAG is null)))
/* Budget Revision Rules Enhancement Start */
      AND ((tlinfo.APPLY_ACCOUNT_SET_FLAG = P_APPLY_ACCOUNT_SET_FLAG)
	   OR ((tlinfo.APPLY_ACCOUNT_SET_FLAG is null)
	       AND (P_APPLY_ACCOUNT_SET_FLAG is null)))

      AND ((tlinfo.BALANCE_ACCOUNT_SET_FLAG = P_BALANCE_ACCOUNT_SET_FLAG)
	   OR ((tlinfo.BALANCE_ACCOUNT_SET_FLAG is null)
	       AND (P_BALANCE_ACCOUNT_SET_FLAG is null)))
/* Budget Revision Rules Enhancement End */
      AND ((tlinfo.ATTRIBUTE1 = P_ATTRIBUTE1)
	   OR ((tlinfo.ATTRIBUTE1 is null)
	       AND (P_ATTRIBUTE1 is null)))
      AND ((tlinfo.ATTRIBUTE2 = P_ATTRIBUTE2)
	   OR ((tlinfo.ATTRIBUTE2 is null)
	       AND (P_ATTRIBUTE2 is null)))
      AND ((tlinfo.ATTRIBUTE3 = P_ATTRIBUTE3)
	   OR ((tlinfo.ATTRIBUTE3 is null)
	       AND (P_ATTRIBUTE3 is null)))
      AND ((tlinfo.ATTRIBUTE4 = P_ATTRIBUTE4)
	   OR ((tlinfo.ATTRIBUTE4 is null)
	       AND (P_ATTRIBUTE4 is null)))
      AND ((tlinfo.ATTRIBUTE5 = P_ATTRIBUTE5)
	   OR ((tlinfo.ATTRIBUTE5 is null)
	       AND (P_ATTRIBUTE5 is null)))
      AND ((tlinfo.ATTRIBUTE6 = P_ATTRIBUTE6)
	   OR ((tlinfo.ATTRIBUTE6 is null)
	       AND (P_ATTRIBUTE6 is null)))
      AND ((tlinfo.ATTRIBUTE7 = P_ATTRIBUTE7)
	   OR ((tlinfo.ATTRIBUTE7 is null)
	       AND (P_ATTRIBUTE7 is null)))
      AND ((tlinfo.ATTRIBUTE8 = P_ATTRIBUTE8)
	   OR ((tlinfo.ATTRIBUTE8 is null)
	       AND (P_ATTRIBUTE8 is null)))
      AND ((tlinfo.ATTRIBUTE9 = P_ATTRIBUTE9)
	   OR ((tlinfo.ATTRIBUTE9 is null)
	       AND (P_ATTRIBUTE9 is null)))
      AND ((tlinfo.ATTRIBUTE10 = P_ATTRIBUTE10)
	   OR ((tlinfo.ATTRIBUTE10 is null)
	       AND (P_ATTRIBUTE10 is null)))
      AND ((tlinfo.CONTEXT = P_CONTEXT)
	   OR ((tlinfo.CONTEXT is null)
	       AND (P_CONTEXT is null)))
      AND ((tlinfo.EFFECTIVE_START_DATE = P_EFFECTIVE_START_DATE)
	   OR ((tlinfo.EFFECTIVE_START_DATE is null)
	       AND (P_EFFECTIVE_START_DATE is null))
	   OR ((tlinfo.EFFECTIVE_START_DATE is null)
	       AND (P_EFFECTIVE_START_DATE = FND_API.G_MISS_DATE)))
      AND ((tlinfo.EFFECTIVE_END_DATE = P_EFFECTIVE_END_DATE)
	   OR ((tlinfo.EFFECTIVE_END_DATE is null)
	       AND (P_EFFECTIVE_END_DATE is null))
	   OR ((tlinfo.EFFECTIVE_END_DATE is null)
	       AND (P_EFFECTIVE_END_DATE = FND_API.G_MISS_DATE)))
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
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  P_ENTITY_ID in NUMBER,
  P_ENTITY_TYPE in VARCHAR2,
  P_ENTITY_SUBTYPE in VARCHAR2,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_DATA_EXTRACT_ID in NUMBER,
  P_SET_OF_BOOKS_ID in NUMBER,
  P_BUDGET_GROUP_ID in NUMBER := FND_API.G_MISS_NUM,
  P_ALLOCATION_TYPE in VARCHAR2,
  P_BUDGET_YEAR_TYPE_ID in NUMBER,
  P_BALANCE_TYPE in VARCHAR2,
  P_PARAMETER_AUTOINC_RULE in VARCHAR2,
  P_PARAMETER_COMPOUND_ANNUALLY in VARCHAR2,
  P_CURRENCY_CODE in VARCHAR2,
  P_FTE_CONSTRAINT in VARCHAR2,
  P_CONSTRAINT_DETAILED_FLAG in VARCHAR2,
/* Budget Revision Rules Enhancement Start */
  P_APPLY_ACCOUNT_SET_FLAG in VARCHAR2,
  P_BALANCE_ACCOUNT_SET_FLAG in VARCHAR2,
/* Budget Revision Rules Enhancement End */
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_CONTEXT in VARCHAR2,
  P_EFFECTIVE_START_DATE in DATE := FND_API.G_MISS_DATE,
  P_EFFECTIVE_END_DATE   in DATE := FND_API.G_MISS_DATE,
  p_Last_Update_Date                   DATE,
  p_Last_Updated_By                    NUMBER,
  p_Last_Update_Login                  NUMBER
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
  update PSB_ENTITY set
    ENTITY_TYPE = P_ENTITY_TYPE,
    ENTITY_SUBTYPE = P_ENTITY_SUBTYPE,
    NAME = P_NAME,
    DESCRIPTION = P_DESCRIPTION,
    DATA_EXTRACT_ID = P_DATA_EXTRACT_ID,
    SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID,
    BUDGET_GROUP_ID = decode(P_BUDGET_GROUP_ID, FND_API.G_MISS_NUM,
			      null, P_BUDGET_GROUP_ID),
    ALLOCATION_TYPE = P_ALLOCATION_TYPE,
    BUDGET_YEAR_TYPE_ID = P_BUDGET_YEAR_TYPE_ID,
    BALANCE_TYPE = P_BALANCE_TYPE,
    PARAMETER_AUTOINC_RULE = P_PARAMETER_AUTOINC_RULE,
    PARAMETER_COMPOUND_ANNUALLY = P_PARAMETER_COMPOUND_ANNUALLY,
    CURRENCY_CODE = P_CURRENCY_CODE,
    FTE_CONSTRAINT = P_FTE_CONSTRAINT,
    CONSTRAINT_DETAILED_FLAG = P_CONSTRAINT_DETAILED_FLAG,
/* Budget Revision Rules Enhancement Start */
    APPLY_ACCOUNT_SET_FLAG = P_APPLY_ACCOUNT_SET_FLAG,
    BALANCE_ACCOUNT_SET_FLAG = P_BALANCE_ACCOUNT_SET_FLAG,
/* Budget Revision Rules Enhancement End */
    ATTRIBUTE1 = P_ATTRIBUTE1,
    ATTRIBUTE2 = P_ATTRIBUTE2,
    ATTRIBUTE3 = P_ATTRIBUTE3,
    ATTRIBUTE4 = P_ATTRIBUTE4,
    ATTRIBUTE5 = P_ATTRIBUTE5,
    ATTRIBUTE6 = P_ATTRIBUTE6,
    ATTRIBUTE7 = P_ATTRIBUTE7,
    ATTRIBUTE8 = P_ATTRIBUTE8,
    ATTRIBUTE9 = P_ATTRIBUTE9,
    ATTRIBUTE10 = P_ATTRIBUTE10,
    CONTEXT = P_CONTEXT,
    EFFECTIVE_START_DATE = decode(P_EFFECTIVE_START_DATE, FND_API.G_MISS_DATE,
			 null, P_EFFECTIVE_START_DATE),
    EFFECTIVE_END_DATE = decode(P_EFFECTIVE_END_DATE, FND_API.G_MISS_DATE,
			 null, P_EFFECTIVE_END_DATE),
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where ENTITY_ID = P_ENTITY_ID
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

procedure ADD_ROW(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_ROWID                       in OUT  NOCOPY VARCHAR2,
  P_ENTITY_ID                   in NUMBER,
  P_ENTITY_TYPE                 in VARCHAR2,
  P_ENTITY_SUBTYPE              in VARCHAR2,
  P_NAME                        in VARCHAR2,
  P_DESCRIPTION                 in VARCHAR2,
  P_DATA_EXTRACT_ID             in NUMBER,
  P_SET_OF_BOOKS_ID             in NUMBER,
  P_BUDGET_GROUP_ID             in NUMBER :=FND_API.G_MISS_NUM,
  P_ALLOCATION_TYPE             in VARCHAR2,
  P_BUDGET_YEAR_TYPE_ID         in NUMBER,
  P_BALANCE_TYPE                in VARCHAR2,
  P_PARAMETER_AUTOINC_RULE      in VARCHAR2,
  P_PARAMETER_COMPOUND_ANNUALLY in VARCHAR2,
  P_CURRENCY_CODE               in VARCHAR2,
  P_FTE_CONSTRAINT              in VARCHAR2,
  P_CONSTRAINT_DETAILED_FLAG    in VARCHAR2,
/* Budget Revision Rules Enhancement Start */
  P_APPLY_ACCOUNT_SET_FLAG      in VARCHAR2,
  P_BALANCE_ACCOUNT_SET_FLAG    in VARCHAR2,
/* Budget Revision Rules Enhancement End */
  P_ATTRIBUTE1                  in VARCHAR2,
  P_ATTRIBUTE2                  in VARCHAR2,
  P_ATTRIBUTE3                  in VARCHAR2,
  P_ATTRIBUTE4                  in VARCHAR2,
  P_ATTRIBUTE5                  in VARCHAR2,
  P_ATTRIBUTE6                  in VARCHAR2,
  P_ATTRIBUTE7                  in VARCHAR2,
  P_ATTRIBUTE8                  in VARCHAR2,
  P_ATTRIBUTE9                  in VARCHAR2,
  P_ATTRIBUTE10                 in VARCHAR2,
  P_CONTEXT                     in VARCHAR2,
  P_EFFECTIVE_START_DATE in DATE := FND_API.G_MISS_DATE,
  P_EFFECTIVE_END_DATE   in DATE := FND_API.G_MISS_DATE,
  p_Last_Update_Date                DATE,
  p_Last_Updated_By                 NUMBER,
  p_Last_Update_Login               NUMBER,
  p_Created_By                      NUMBER,
  p_Creation_Date                   DATE
) IS

  cursor c is
  select rowid
  from psb_entity
  where entity_id = p_entity_id;
  dummy c%rowtype;

  l_api_name CONSTANT varchar2(30) := 'Add Row';
  l_api_version CONSTANT number := 1.0;

BEGIN

  SAVEPOINT Add_Row;
  --
  -- Initialize message list if p_init_msg_list is set to TRUE.
  --
  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  open c;
  fetch c into dummy;
  if (c%notfound) then
    close c;

    INSERT_ROW (
     p_api_version,
     p_init_msg_list,
     p_commit,
     p_validation_level,
     p_return_status,
     p_msg_count,
     p_msg_data,

     p_rowid ,
     p_entity_id ,
     p_entity_type ,
     p_entity_subtype ,
     p_name ,
     p_description ,
     p_data_extract_id ,
     p_set_of_books_id ,
     p_budget_group_id,
     p_allocation_type ,
     p_budget_year_type_id ,
     p_balance_type ,
     p_parameter_autoinc_rule ,
     p_parameter_compound_annually ,
     p_currency_code ,
     p_fte_constraint ,
     p_constraint_detailed_flag ,
/* Budget Revision Rules Enhancement Start */
     p_apply_account_set_flag ,
     p_balance_account_set_flag ,
/* Budget Revision Rules Enhancement End */
     p_attribute1 ,
     p_attribute2 ,
     p_attribute3 ,
     p_attribute4 ,
     p_attribute5 ,
     p_attribute6 ,
     p_attribute7 ,
     p_attribute8 ,
     p_attribute9 ,
     p_attribute10 ,
     p_context ,
     p_effective_start_date,
     p_effective_end_date,
     p_last_update_date ,
     p_last_updated_by ,
     p_last_update_login ,
     p_created_by ,
     p_creation_date);
     return;
  end if;
  close c;

  UPDATE_ROW(
     p_api_version,
     p_init_msg_list,
     p_commit,
     p_validation_level,
     p_return_status,
     p_msg_count,
     p_msg_data,

     p_entity_id ,
     p_entity_type ,
     p_entity_subtype ,
     p_name ,
     p_description ,
     p_data_extract_id ,
     p_set_of_books_id ,
     p_budget_group_id,
     p_allocation_type ,
     p_budget_year_type_id ,
     p_balance_type ,
     p_parameter_autoinc_rule ,
     p_parameter_compound_annually ,
     p_currency_code ,
     p_fte_constraint ,
     p_constraint_detailed_flag ,
/* Budget Revision Rules Enhancement Start */
     p_apply_account_set_flag ,
     p_balance_account_set_flag ,
/* Budget Revision Rules Enhancement End */
     p_attribute1 ,
     p_attribute2 ,
     p_attribute3 ,
     p_attribute4 ,
     p_attribute5 ,
     p_attribute6 ,
     p_attribute7 ,
     p_attribute8 ,
     p_attribute9 ,
     p_attribute10 ,
     p_context ,
     p_effective_start_date,
     p_effective_end_date,
     p_last_update_date ,
     p_last_updated_by ,
     p_last_update_login );

  --
  -- Standard check of p_commit.
  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);
  --

EXCEPTION
   --
   when FND_API.G_EXC_ERROR then
     --
     rollback to ADD_ROW ;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     rollback to ADD_ROW ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when OTHERS then
     --
     rollback to ADD_ROW ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
END ADD_ROW;


procedure DELETE_ROW (
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  P_ENTITY_ID in NUMBER
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
  delete from PSB_ENTITY
  where ENTITY_ID = P_ENTITY_ID;
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


end PSB_ENTITY_PVT;

/
