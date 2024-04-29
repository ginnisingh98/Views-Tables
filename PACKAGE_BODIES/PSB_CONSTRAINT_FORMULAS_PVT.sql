--------------------------------------------------------
--  DDL for Package Body PSB_CONSTRAINT_FORMULAS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_CONSTRAINT_FORMULAS_PVT" AS
 /* $Header: PSBVCFPB.pls 120.2 2005/07/13 11:24:01 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_CONSTRAINT_FORMULAS_PVT';

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
  P_CONSTRAINT_FORMULA_ID in NUMBER,
  P_CONSTRAINT_ID in NUMBER,
  P_STEP_NUMBER in NUMBER,
  P_BUDGET_YEAR_TYPE_ID in NUMBER,
  P_BALANCE_TYPE in VARCHAR2,
  P_CURRENCY_CODE in VARCHAR2,
  P_TEMPLATE_ID in NUMBER,
  P_SEGMENT1 in VARCHAR2,
  P_SEGMENT2 in VARCHAR2,
  P_SEGMENT3 in VARCHAR2,
  P_SEGMENT4 in VARCHAR2,
  P_SEGMENT5 in VARCHAR2,
  P_SEGMENT6 in VARCHAR2,
  P_SEGMENT7 in VARCHAR2,
  P_SEGMENT8 in VARCHAR2,
  P_SEGMENT9 in VARCHAR2,
  P_SEGMENT10 in VARCHAR2,
  P_SEGMENT11 in VARCHAR2,
  P_SEGMENT12 in VARCHAR2,
  P_SEGMENT13 in VARCHAR2,
  P_SEGMENT14 in VARCHAR2,
  P_SEGMENT15 in VARCHAR2,
  P_SEGMENT16 in VARCHAR2,
  P_SEGMENT17 in VARCHAR2,
  P_SEGMENT18 in VARCHAR2,
  P_SEGMENT19 in VARCHAR2,
  P_SEGMENT20 in VARCHAR2,
  P_SEGMENT21 in VARCHAR2,
  P_SEGMENT22 in VARCHAR2,
  P_SEGMENT23 in VARCHAR2,
  P_SEGMENT24 in VARCHAR2,
  P_SEGMENT25 in VARCHAR2,
  P_SEGMENT26 in VARCHAR2,
  P_SEGMENT27 in VARCHAR2,
  P_SEGMENT28 in VARCHAR2,
  P_SEGMENT29 in VARCHAR2,
  P_SEGMENT30 in VARCHAR2,
  P_AMOUNT in NUMBER,
  P_PREFIX_OPERATOR in VARCHAR2,
  P_POSTFIX_OPERATOR in VARCHAR2,
  P_PAY_ELEMENT_ID in NUMBER,
  P_PAY_ELEMENT_OPTION_ID in NUMBER,
  P_ALLOW_MODIFY in VARCHAR2,
  P_ELEMENT_VALUE in NUMBER,
  P_ELEMENT_VALUE_TYPE in VARCHAR2,
  P_EFFECTIVE_START_DATE in DATE,
  P_EFFECTIVE_END_DATE in DATE,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_CONTEXT in VARCHAR2,
  P_CONCATENATED_SEGMENTS in VARCHAR2,
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
    cursor C is select ROWID from PSB_CONSTRAINT_FORMULAS
      where CONSTRAINT_FORMULA_ID = P_CONSTRAINT_FORMULA_ID;

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

  insert into PSB_CONSTRAINT_FORMULAS (
    CONSTRAINT_ID,
    CONSTRAINT_FORMULA_ID,
    STEP_NUMBER,
    BUDGET_YEAR_TYPE_ID,
    BALANCE_TYPE,
    CURRENCY_CODE,
    TEMPLATE_ID,
    SEGMENT1,
    SEGMENT2,
    SEGMENT3,
    SEGMENT4,
    SEGMENT5,
    SEGMENT6,
    SEGMENT7,
    SEGMENT8,
    SEGMENT9,
    SEGMENT10,
    SEGMENT11,
    SEGMENT12,
    SEGMENT13,
    SEGMENT14,
    SEGMENT15,
    SEGMENT16,
    SEGMENT17,
    SEGMENT18,
    SEGMENT19,
    SEGMENT20,
    SEGMENT21,
    SEGMENT22,
    SEGMENT23,
    SEGMENT24,
    SEGMENT25,
    SEGMENT26,
    SEGMENT27,
    SEGMENT28,
    SEGMENT29,
    SEGMENT30,
    AMOUNT,
    PREFIX_OPERATOR,
    POSTFIX_OPERATOR,
    PAY_ELEMENT_ID,
    PAY_ELEMENT_OPTION_ID,
    ALLOW_MODIFY,
    ELEMENT_VALUE,
    ELEMENT_VALUE_TYPE,
    EFFECTIVE_START_DATE,
    EFFECTIVE_END_DATE,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    CONTEXT,
    CONCATENATED_SEGMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_CONSTRAINT_ID,
    P_CONSTRAINT_FORMULA_ID,
    P_STEP_NUMBER,
    P_BUDGET_YEAR_TYPE_ID,
    P_BALANCE_TYPE,
    P_CURRENCY_CODE,
    P_TEMPLATE_ID,
    P_SEGMENT1,
    P_SEGMENT2,
    P_SEGMENT3,
    P_SEGMENT4,
    P_SEGMENT5,
    P_SEGMENT6,
    P_SEGMENT7,
    P_SEGMENT8,
    P_SEGMENT9,
    P_SEGMENT10,
    P_SEGMENT11,
    P_SEGMENT12,
    P_SEGMENT13,
    P_SEGMENT14,
    P_SEGMENT15,
    P_SEGMENT16,
    P_SEGMENT17,
    P_SEGMENT18,
    P_SEGMENT19,
    P_SEGMENT20,
    P_SEGMENT21,
    P_SEGMENT22,
    P_SEGMENT23,
    P_SEGMENT24,
    P_SEGMENT25,
    P_SEGMENT26,
    P_SEGMENT27,
    P_SEGMENT28,
    P_SEGMENT29,
    P_SEGMENT30,
    P_AMOUNT,
    P_PREFIX_OPERATOR,
    P_POSTFIX_OPERATOR,
    P_PAY_ELEMENT_ID,
    P_PAY_ELEMENT_OPTION_ID,
    P_ALLOW_MODIFY,
    P_ELEMENT_VALUE,
    P_ELEMENT_VALUE_TYPE,
    P_EFFECTIVE_START_DATE,
    P_EFFECTIVE_END_DATE,
    P_ATTRIBUTE1,
    P_ATTRIBUTE2,
    P_ATTRIBUTE3,
    P_ATTRIBUTE4,
    P_ATTRIBUTE5,
    P_CONTEXT,
    P_CONCATENATED_SEGMENTS,
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
    raise no_data_found;
  end if;
  close c;
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
  P_CONSTRAINT_FORMULA_ID in NUMBER,
  P_CONSTRAINT_ID in NUMBER,
  P_STEP_NUMBER in NUMBER,
  P_BUDGET_YEAR_TYPE_ID in NUMBER,
  P_BALANCE_TYPE in VARCHAR2,
  P_CURRENCY_CODE in VARCHAR2,
  P_TEMPLATE_ID in NUMBER,
  P_SEGMENT1 in VARCHAR2,
  P_SEGMENT2 in VARCHAR2,
  P_SEGMENT3 in VARCHAR2,
  P_SEGMENT4 in VARCHAR2,
  P_SEGMENT5 in VARCHAR2,
  P_SEGMENT6 in VARCHAR2,
  P_SEGMENT7 in VARCHAR2,
  P_SEGMENT8 in VARCHAR2,
  P_SEGMENT9 in VARCHAR2,
  P_SEGMENT10 in VARCHAR2,
  P_SEGMENT11 in VARCHAR2,
  P_SEGMENT12 in VARCHAR2,
  P_SEGMENT13 in VARCHAR2,
  P_SEGMENT14 in VARCHAR2,
  P_SEGMENT15 in VARCHAR2,
  P_SEGMENT16 in VARCHAR2,
  P_SEGMENT17 in VARCHAR2,
  P_SEGMENT18 in VARCHAR2,
  P_SEGMENT19 in VARCHAR2,
  P_SEGMENT20 in VARCHAR2,
  P_SEGMENT21 in VARCHAR2,
  P_SEGMENT22 in VARCHAR2,
  P_SEGMENT23 in VARCHAR2,
  P_SEGMENT24 in VARCHAR2,
  P_SEGMENT25 in VARCHAR2,
  P_SEGMENT26 in VARCHAR2,
  P_SEGMENT27 in VARCHAR2,
  P_SEGMENT28 in VARCHAR2,
  P_SEGMENT29 in VARCHAR2,
  P_SEGMENT30 in VARCHAR2,
  P_AMOUNT in NUMBER,
  P_PREFIX_OPERATOR in VARCHAR2,
  P_POSTFIX_OPERATOR in VARCHAR2,
  P_PAY_ELEMENT_ID in NUMBER,
  P_PAY_ELEMENT_OPTION_ID in NUMBER,
  P_ALLOW_MODIFY in VARCHAR2,
  P_ELEMENT_VALUE in NUMBER,
  P_ELEMENT_VALUE_TYPE in VARCHAR2,
  P_EFFECTIVE_START_DATE in DATE,
  P_EFFECTIVE_END_DATE in DATE,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_CONTEXT in VARCHAR2,
  P_CONCATENATED_SEGMENTS in VARCHAR2
) is
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  Counter NUMBER;
  cursor c1 is select
      CONSTRAINT_ID,
      STEP_NUMBER,
      BUDGET_YEAR_TYPE_ID,
      BALANCE_TYPE,
      CURRENCY_CODE,
      TEMPLATE_ID,
      SEGMENT1,
      SEGMENT2,
      SEGMENT3,
      SEGMENT4,
      SEGMENT5,
      SEGMENT6,
      SEGMENT7,
      SEGMENT8,
      SEGMENT9,
      SEGMENT10,
      SEGMENT11,
      SEGMENT12,
      SEGMENT13,
      SEGMENT14,
      SEGMENT15,
      SEGMENT16,
      SEGMENT17,
      SEGMENT18,
      SEGMENT19,
      SEGMENT20,
      SEGMENT21,
      SEGMENT22,
      SEGMENT23,
      SEGMENT24,
      SEGMENT25,
      SEGMENT26,
      SEGMENT27,
      SEGMENT28,
      SEGMENT29,
      SEGMENT30,
      AMOUNT,
      PREFIX_OPERATOR,
      POSTFIX_OPERATOR,
      PAY_ELEMENT_ID,
      PAY_ELEMENT_OPTION_ID,
      ALLOW_MODIFY,
      ELEMENT_VALUE,
      ELEMENT_VALUE_TYPE,
      EFFECTIVE_START_DATE,
      EFFECTIVE_END_DATE,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      CONTEXT,
      CONCATENATED_SEGMENTS
    from PSB_CONSTRAINT_FORMULAS
    where CONSTRAINT_FORMULA_ID = P_CONSTRAINT_FORMULA_ID
    for update of CONSTRAINT_FORMULA_ID nowait;
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

  if ( (tlinfo.CONSTRAINT_ID = P_CONSTRAINT_ID)
      AND ((tlinfo.STEP_NUMBER = P_STEP_NUMBER)
	   OR ((tlinfo.STEP_NUMBER is null)
	       AND (P_STEP_NUMBER is null)))
      AND ((tlinfo.BUDGET_YEAR_TYPE_ID = P_BUDGET_YEAR_TYPE_ID)
	   OR ((tlinfo.BUDGET_YEAR_TYPE_ID is null)
	       AND (P_BUDGET_YEAR_TYPE_ID is null)))
      AND ((tlinfo.BALANCE_TYPE = P_BALANCE_TYPE)
	   OR ((tlinfo.BALANCE_TYPE is null)
	       AND (P_BALANCE_TYPE is null)))
      AND ((tlinfo.CURRENCY_CODE = P_CURRENCY_CODE)
	   OR ((tlinfo.CURRENCY_CODE is null)
	       AND (P_CURRENCY_CODE is null)))
      AND ((tlinfo.TEMPLATE_ID = P_TEMPLATE_ID)
	   OR ((tlinfo.TEMPLATE_ID is null)
	       AND (P_TEMPLATE_ID is null)))
      AND ((tlinfo.SEGMENT1 = P_SEGMENT1)
	   OR ((tlinfo.SEGMENT1 is null)
	       AND (P_SEGMENT1 is null)))
      AND ((tlinfo.SEGMENT2 = P_SEGMENT2)
	   OR ((tlinfo.SEGMENT2 is null)
	       AND (P_SEGMENT2 is null)))
      AND ((tlinfo.SEGMENT3 = P_SEGMENT3)
	   OR ((tlinfo.SEGMENT3 is null)
	       AND (P_SEGMENT3 is null)))
      AND ((tlinfo.SEGMENT4 = P_SEGMENT4)
	   OR ((tlinfo.SEGMENT4 is null)
	       AND (P_SEGMENT4 is null)))
      AND ((tlinfo.SEGMENT5 = P_SEGMENT5)
	   OR ((tlinfo.SEGMENT5 is null)
	       AND (P_SEGMENT5 is null)))
      AND ((tlinfo.SEGMENT6 = P_SEGMENT6)
	   OR ((tlinfo.SEGMENT6 is null)
	       AND (P_SEGMENT6 is null)))
      AND ((tlinfo.SEGMENT7 = P_SEGMENT7)
	   OR ((tlinfo.SEGMENT7 is null)
	       AND (P_SEGMENT7 is null)))
      AND ((tlinfo.SEGMENT8 = P_SEGMENT8)
	   OR ((tlinfo.SEGMENT8 is null)
	       AND (P_SEGMENT8 is null)))
      AND ((tlinfo.SEGMENT9 = P_SEGMENT9)
	   OR ((tlinfo.SEGMENT9 is null)
	       AND (P_SEGMENT9 is null)))
      AND ((tlinfo.SEGMENT10 = P_SEGMENT10)
	   OR ((tlinfo.SEGMENT10 is null)
	       AND (P_SEGMENT10 is null)))
      AND ((tlinfo.SEGMENT11 = P_SEGMENT11)
	   OR ((tlinfo.SEGMENT11 is null)
	       AND (P_SEGMENT11 is null)))
      AND ((tlinfo.SEGMENT12 = P_SEGMENT12)
	   OR ((tlinfo.SEGMENT12 is null)
	       AND (P_SEGMENT12 is null)))
      AND ((tlinfo.SEGMENT13 = P_SEGMENT13)
	   OR ((tlinfo.SEGMENT13 is null)
	       AND (P_SEGMENT13 is null)))
      AND ((tlinfo.SEGMENT14 = P_SEGMENT14)
	   OR ((tlinfo.SEGMENT14 is null)
	       AND (P_SEGMENT14 is null)))
      AND ((tlinfo.SEGMENT15 = P_SEGMENT15)
	   OR ((tlinfo.SEGMENT15 is null)
	       AND (P_SEGMENT15 is null)))
      AND ((tlinfo.SEGMENT16 = P_SEGMENT16)
	   OR ((tlinfo.SEGMENT16 is null)
	       AND (P_SEGMENT16 is null)))
      AND ((tlinfo.SEGMENT17 = P_SEGMENT17)
	   OR ((tlinfo.SEGMENT17 is null)
	       AND (P_SEGMENT17 is null)))
      AND ((tlinfo.SEGMENT18 = P_SEGMENT18)
	   OR ((tlinfo.SEGMENT18 is null)
	       AND (P_SEGMENT18 is null)))
      AND ((tlinfo.SEGMENT19 = P_SEGMENT19)
	   OR ((tlinfo.SEGMENT19 is null)
	       AND (P_SEGMENT19 is null)))
      AND ((tlinfo.SEGMENT20 = P_SEGMENT20)
	   OR ((tlinfo.SEGMENT20 is null)
	       AND (P_SEGMENT20 is null)))
      AND ((tlinfo.SEGMENT21 = P_SEGMENT21)
	   OR ((tlinfo.SEGMENT21 is null)
	       AND (P_SEGMENT21 is null)))
      AND ((tlinfo.SEGMENT22 = P_SEGMENT22)
	   OR ((tlinfo.SEGMENT22 is null)
	       AND (P_SEGMENT22 is null)))
      AND ((tlinfo.SEGMENT23 = P_SEGMENT23)
	   OR ((tlinfo.SEGMENT23 is null)
	       AND (P_SEGMENT23 is null)))
      AND ((tlinfo.SEGMENT24 = P_SEGMENT24)
	   OR ((tlinfo.SEGMENT24 is null)
	       AND (P_SEGMENT24 is null)))
      AND ((tlinfo.SEGMENT25 = P_SEGMENT25)
	   OR ((tlinfo.SEGMENT25 is null)
	       AND (P_SEGMENT25 is null)))
      AND ((tlinfo.SEGMENT26 = P_SEGMENT26)
	   OR ((tlinfo.SEGMENT26 is null)
	       AND (P_SEGMENT26 is null)))
      AND ((tlinfo.SEGMENT27 = P_SEGMENT27)
	   OR ((tlinfo.SEGMENT27 is null)
	       AND (P_SEGMENT27 is null)))
      AND ((tlinfo.SEGMENT28 = P_SEGMENT28)
	   OR ((tlinfo.SEGMENT28 is null)
	       AND (P_SEGMENT28 is null)))
      AND ((tlinfo.SEGMENT29 = P_SEGMENT29)
	   OR ((tlinfo.SEGMENT29 is null)
	       AND (P_SEGMENT29 is null)))
      AND ((tlinfo.SEGMENT30 = P_SEGMENT30)
	   OR ((tlinfo.SEGMENT30 is null)
	       AND (P_SEGMENT30 is null)))
      AND ((tlinfo.AMOUNT = P_AMOUNT)
	   OR ((tlinfo.AMOUNT is null)
	       AND (P_AMOUNT is null)))
      AND ((tlinfo.PREFIX_OPERATOR = P_PREFIX_OPERATOR)
	   OR ((tlinfo.PREFIX_OPERATOR is null)
	       AND (P_PREFIX_OPERATOR is null)))
      AND ((tlinfo.POSTFIX_OPERATOR = P_POSTFIX_OPERATOR)
	   OR ((tlinfo.POSTFIX_OPERATOR is null)
	       AND (P_POSTFIX_OPERATOR is null)))
      AND ((tlinfo.PAY_ELEMENT_ID = P_PAY_ELEMENT_ID)
	   OR ((tlinfo.PAY_ELEMENT_ID is null)
	       AND (P_PAY_ELEMENT_ID is null)))
      AND ((tlinfo.PAY_ELEMENT_OPTION_ID = P_PAY_ELEMENT_OPTION_ID)
	   OR ((tlinfo.PAY_ELEMENT_OPTION_ID is null)
	       AND (P_PAY_ELEMENT_OPTION_ID is null)))
      AND ((tlinfo.ALLOW_MODIFY = P_ALLOW_MODIFY)
	   OR ((tlinfo.ALLOW_MODIFY is null)
	       AND (P_ALLOW_MODIFY is null)))
      AND ((tlinfo.ELEMENT_VALUE = P_ELEMENT_VALUE)
	   OR ((tlinfo.ELEMENT_VALUE is null)
	       AND (P_ELEMENT_VALUE is null)))
      AND ((tlinfo.ELEMENT_VALUE_TYPE = P_ELEMENT_VALUE_TYPE)
	   OR ((tlinfo.ELEMENT_VALUE_TYPE is null)
	       AND (P_ELEMENT_VALUE_TYPE is null)))
      AND ((tlinfo.EFFECTIVE_START_DATE = P_EFFECTIVE_START_DATE)
	   OR ((tlinfo.EFFECTIVE_START_DATE is null)
	       AND (P_EFFECTIVE_START_DATE is null)))
      AND ((tlinfo.EFFECTIVE_END_DATE = P_EFFECTIVE_END_DATE)
	   OR ((tlinfo.EFFECTIVE_END_DATE is null)
	       AND (P_EFFECTIVE_END_DATE is null)))
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
      AND ((tlinfo.CONTEXT = P_CONTEXT)
	   OR ((tlinfo.CONTEXT is null)
	       AND (P_CONTEXT is null)))
      AND ((tlinfo.CONCATENATED_SEGMENTS = P_CONCATENATED_SEGMENTS)
	   OR ((tlinfo.CONCATENATED_SEGMENTS is null)
	       AND (P_CONCATENATED_SEGMENTS is null)))
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
  P_CONSTRAINT_FORMULA_ID in NUMBER,
  P_CONSTRAINT_ID in NUMBER,
  P_STEP_NUMBER in NUMBER,
  P_BUDGET_YEAR_TYPE_ID in NUMBER,
  P_BALANCE_TYPE in VARCHAR2,
  P_CURRENCY_CODE in VARCHAR2,
  P_TEMPLATE_ID in NUMBER,
  P_SEGMENT1 in VARCHAR2,
  P_SEGMENT2 in VARCHAR2,
  P_SEGMENT3 in VARCHAR2,
  P_SEGMENT4 in VARCHAR2,
  P_SEGMENT5 in VARCHAR2,
  P_SEGMENT6 in VARCHAR2,
  P_SEGMENT7 in VARCHAR2,
  P_SEGMENT8 in VARCHAR2,
  P_SEGMENT9 in VARCHAR2,
  P_SEGMENT10 in VARCHAR2,
  P_SEGMENT11 in VARCHAR2,
  P_SEGMENT12 in VARCHAR2,
  P_SEGMENT13 in VARCHAR2,
  P_SEGMENT14 in VARCHAR2,
  P_SEGMENT15 in VARCHAR2,
  P_SEGMENT16 in VARCHAR2,
  P_SEGMENT17 in VARCHAR2,
  P_SEGMENT18 in VARCHAR2,
  P_SEGMENT19 in VARCHAR2,
  P_SEGMENT20 in VARCHAR2,
  P_SEGMENT21 in VARCHAR2,
  P_SEGMENT22 in VARCHAR2,
  P_SEGMENT23 in VARCHAR2,
  P_SEGMENT24 in VARCHAR2,
  P_SEGMENT25 in VARCHAR2,
  P_SEGMENT26 in VARCHAR2,
  P_SEGMENT27 in VARCHAR2,
  P_SEGMENT28 in VARCHAR2,
  P_SEGMENT29 in VARCHAR2,
  P_SEGMENT30 in VARCHAR2,
  P_AMOUNT in NUMBER,
  P_PREFIX_OPERATOR in VARCHAR2,
  P_POSTFIX_OPERATOR in VARCHAR2,
  P_PAY_ELEMENT_ID in NUMBER,
  P_PAY_ELEMENT_OPTION_ID in NUMBER,
  P_ALLOW_MODIFY in VARCHAR2,
  P_ELEMENT_VALUE in NUMBER,
  P_ELEMENT_VALUE_TYPE in VARCHAR2,
  P_EFFECTIVE_START_DATE in DATE,
  P_EFFECTIVE_END_DATE in DATE,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_CONTEXT in VARCHAR2,
  P_CONCATENATED_SEGMENTS in VARCHAR2,
  p_Last_Update_Date                   DATE,
  p_Last_Updated_By                    NUMBER,
  p_Last_Update_Login                  NUMBER
)
 is
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

  update PSB_CONSTRAINT_FORMULAS set
    CONSTRAINT_ID = P_CONSTRAINT_ID,
    STEP_NUMBER = P_STEP_NUMBER,
    BUDGET_YEAR_TYPE_ID = P_BUDGET_YEAR_TYPE_ID,
    BALANCE_TYPE = P_BALANCE_TYPE,
    CURRENCY_CODE = P_CURRENCY_CODE,
    TEMPLATE_ID = P_TEMPLATE_ID,
    SEGMENT1 = P_SEGMENT1,
    SEGMENT2 = P_SEGMENT2,
    SEGMENT3 = P_SEGMENT3,
    SEGMENT4 = P_SEGMENT4,
    SEGMENT5 = P_SEGMENT5,
    SEGMENT6 = P_SEGMENT6,
    SEGMENT7 = P_SEGMENT7,
    SEGMENT8 = P_SEGMENT8,
    SEGMENT9 = P_SEGMENT9,
    SEGMENT10 = P_SEGMENT10,
    SEGMENT11 = P_SEGMENT11,
    SEGMENT12 = P_SEGMENT12,
    SEGMENT13 = P_SEGMENT13,
    SEGMENT14 = P_SEGMENT14,
    SEGMENT15 = P_SEGMENT15,
    SEGMENT16 = P_SEGMENT16,
    SEGMENT17 = P_SEGMENT17,
    SEGMENT18 = P_SEGMENT18,
    SEGMENT19 = P_SEGMENT19,
    SEGMENT20 = P_SEGMENT20,
    SEGMENT21 = P_SEGMENT21,
    SEGMENT22 = P_SEGMENT22,
    SEGMENT23 = P_SEGMENT23,
    SEGMENT24 = P_SEGMENT24,
    SEGMENT25 = P_SEGMENT25,
    SEGMENT26 = P_SEGMENT26,
    SEGMENT27 = P_SEGMENT27,
    SEGMENT28 = P_SEGMENT28,
    SEGMENT29 = P_SEGMENT29,
    SEGMENT30 = P_SEGMENT30,
    AMOUNT = P_AMOUNT,
    PREFIX_OPERATOR = P_PREFIX_OPERATOR,
    POSTFIX_OPERATOR = P_POSTFIX_OPERATOR,
    PAY_ELEMENT_ID = P_PAY_ELEMENT_ID,
    PAY_ELEMENT_OPTION_ID = P_PAY_ELEMENT_OPTION_ID,
    ALLOW_MODIFY = P_ALLOW_MODIFY,
    ELEMENT_VALUE = P_ELEMENT_VALUE,
    ELEMENT_VALUE_TYPE = P_ELEMENT_VALUE_TYPE,
    EFFECTIVE_START_DATE = P_EFFECTIVE_START_DATE,
    EFFECTIVE_END_DATE = P_EFFECTIVE_END_DATE,
    ATTRIBUTE1 = P_ATTRIBUTE1,
    ATTRIBUTE2 = P_ATTRIBUTE2,
    ATTRIBUTE3 = P_ATTRIBUTE3,
    ATTRIBUTE4 = P_ATTRIBUTE4,
    ATTRIBUTE5 = P_ATTRIBUTE5,
    CONTEXT = P_CONTEXT,
    CONCATENATED_SEGMENTS = P_CONCATENATED_SEGMENTS,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where CONSTRAINT_FORMULA_ID = P_CONSTRAINT_FORMULA_ID
  ;
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
  P_CONSTRAINT_FORMULA_ID in NUMBER
) is
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Delete_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_account_position_set_id
		  psb_account_position_set_lines.account_position_set_id%TYPE;
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

  delete from PSB_CONSTRAINT_FORMULAS
  where CONSTRAINT_FORMULA_ID = P_CONSTRAINT_FORMULA_ID;

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

end PSB_CONSTRAINT_FORMULAS_PVT;

/
