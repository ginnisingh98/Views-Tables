--------------------------------------------------------
--  DDL for Package Body PSB_PARAMETER_FORMULAS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_PARAMETER_FORMULAS_PVT" AS
 /* $Header: PSBVPFPB.pls 120.2 2005/07/13 11:28:21 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_PARAMETER_FORMULAS_PVT';


procedure INSERT_ROW (
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,

  P_ROWID in OUT  NOCOPY VARCHAR2,
  P_PARAMETER_FORMULA_ID in NUMBER,
  P_PARAMETER_ID in NUMBER,
  P_STEP_NUMBER in NUMBER,
  P_BUDGET_YEAR_TYPE_ID in NUMBER,
  P_BALANCE_TYPE in VARCHAR2,
  P_TEMPLATE_ID in NUMBER,
  P_CONCATENATED_SEGMENTS in VARCHAR2,
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
  P_CURRENCY_CODE in VARCHAR2,
  P_AMOUNT in NUMBER,
  P_PREFIX_OPERATOR in VARCHAR2,
  P_POSTFIX_OPERATOR in VARCHAR2,
  P_HIREDATE_BETWEEN_FROM in NUMBER,
  P_HIREDATE_BETWEEN_TO in NUMBER,
  P_ADJDATE_BETWEEN_FROM in NUMBER,
  P_ADJDATE_BETWEEN_TO in NUMBER,
  P_INCREMENT_BY in NUMBER,
  P_INCREMENT_TYPE in VARCHAR2,
  P_ASSIGNMENT_TYPE IN VARCHAR2,
  P_ATTRIBUTE_ID IN NUMBER,
  P_ATTRIBUTE_VALUE IN VARCHAR2,
  P_PAY_ELEMENT_ID in NUMBER,
  P_PAY_ELEMENT_OPTION_ID IN NUMBER,
  P_GRADE_STEP IN NUMBER,
  P_ELEMENT_VALUE in NUMBER,
  P_ELEMENT_VALUE_TYPE in VARCHAR2,
  P_EFFECTIVE_START_DATE in DATE,
  P_EFFECTIVE_END_DATE in DATE,
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
  p_Last_Update_Date                   DATE,
  p_Last_Updated_By                    NUMBER,
  p_Last_Update_Login                  NUMBER,
  p_Created_By                         NUMBER,
  p_Creation_Date                      DATE
) is

  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

    cursor C is select ROWID from PSB_PARAMETER_FORMULAS
      where PARAMETER_FORMULA_ID = P_PARAMETER_FORMULA_ID;
BEGIN

  SAVEPOINT Insert_Row_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  insert into PSB_PARAMETER_FORMULAS (
    PARAMETER_ID,
    PARAMETER_FORMULA_ID,
    STEP_NUMBER,
    BUDGET_YEAR_TYPE_ID,
    BALANCE_TYPE,
    TEMPLATE_ID,
    CONCATENATED_SEGMENTS,
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
    CURRENCY_CODE,
    AMOUNT,
    PREFIX_OPERATOR,
    POSTFIX_OPERATOR,
    HIREDATE_BETWEEN_FROM,
    HIREDATE_BETWEEN_TO,
    ADJDATE_BETWEEN_FROM,
    ADJDATE_BETWEEN_TO,
    INCREMENT_BY,
    INCREMENT_TYPE,
    ASSIGNMENT_TYPE,
    ATTRIBUTE_ID,
    ATTRIBUTE_VALUE,
    PAY_ELEMENT_ID,
    PAY_ELEMENT_OPTION_ID,
    GRADE_STEP,
    ELEMENT_VALUE,
    ELEMENT_VALUE_TYPE,
    EFFECTIVE_START_DATE,
    EFFECTIVE_END_DATE,
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
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_PARAMETER_ID,
    P_PARAMETER_FORMULA_ID,
    P_STEP_NUMBER,
    P_BUDGET_YEAR_TYPE_ID,
    P_BALANCE_TYPE,
    P_TEMPLATE_ID,
    P_CONCATENATED_SEGMENTS,
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
    P_CURRENCY_CODE,
    P_AMOUNT,
    P_PREFIX_OPERATOR,
    P_POSTFIX_OPERATOR,
    P_HIREDATE_BETWEEN_FROM,
    P_HIREDATE_BETWEEN_TO,
    P_ADJDATE_BETWEEN_FROM,
    P_ADJDATE_BETWEEN_TO,
    P_INCREMENT_BY,
    P_INCREMENT_TYPE,
    P_ASSIGNMENT_TYPE,
    P_ATTRIBUTE_ID,
    P_ATTRIBUTE_VALUE,
    P_PAY_ELEMENT_ID,
    P_PAY_ELEMENT_OPTION_ID,
    P_GRADE_STEP,
    P_ELEMENT_VALUE,
    P_ELEMENT_VALUE_TYPE,
    P_EFFECTIVE_START_DATE,
    P_EFFECTIVE_END_DATE,
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
    P_CREATION_DATE,
    P_CREATED_BY,
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


  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

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

  P_ROWID IN VARCHAR2,
  P_PARAMETER_FORMULA_ID in NUMBER,
  P_PARAMETER_ID in NUMBER,
  P_STEP_NUMBER in NUMBER,
  P_BUDGET_YEAR_TYPE_ID in NUMBER,
  P_BALANCE_TYPE in VARCHAR2,
  P_TEMPLATE_ID in NUMBER,
  P_CONCATENATED_SEGMENTS IN VARCHAR2,
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
  P_CURRENCY_CODE in VARCHAR2,
  P_AMOUNT in NUMBER,
  P_PREFIX_OPERATOR in VARCHAR2,
  P_POSTFIX_OPERATOR in VARCHAR2,
  P_HIREDATE_BETWEEN_FROM in NUMBER,
  P_HIREDATE_BETWEEN_TO in NUMBER,
  P_ADJDATE_BETWEEN_FROM in NUMBER,
  P_ADJDATE_BETWEEN_TO in NUMBER,
  P_INCREMENT_BY in NUMBER,
  P_INCREMENT_TYPE in VARCHAR2,
  P_ASSIGNMENT_TYPE IN VARCHAR2,
  P_ATTRIBUTE_ID IN NUMBER,
  P_ATTRIBUTE_VALUE IN VARCHAR2,
  P_PAY_ELEMENT_ID in NUMBER,
  P_PAY_ELEMENT_OPTION_ID IN NUMBER,
  P_GRADE_STEP IN NUMBER,
  P_ELEMENT_VALUE in NUMBER,
  P_ELEMENT_VALUE_TYPE in VARCHAR2,
  P_EFFECTIVE_START_DATE in DATE,
  P_EFFECTIVE_END_DATE in DATE,
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
  P_CONTEXT in VARCHAR2
) is

  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  Counter NUMBER;
  CURSOR c IS
    SELECT *
    FROM psb_parameter_formulas
    WHERE rowid = p_rowid
    FOR UPDATE OF parameter_formula_id NOWAIT;
  recinfo c%ROWTYPE;


BEGIN

  SAVEPOINT Lock_Row_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  p_lock_row := FND_API.G_TRUE;

  open c;
  fetch c into recinfo;
  if (c%notfound) then
     close c;
     FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
     FND_MSG_PUB.ADD;
     raise FND_API.G_EXC_ERROR;
  end if;
  close c;

  if (

     (recinfo.PARAMETER_ID = P_PARAMETER_ID)
      AND (recinfo.PARAMETER_FORMULA_ID = P_PARAMETER_FORMULA_ID)

      AND (recinfo.STEP_NUMBER = P_STEP_NUMBER)
	   OR ((recinfo.STEP_NUMBER is null)
	       AND (P_STEP_NUMBER is null)))

      AND ((recinfo.BUDGET_YEAR_TYPE_ID = P_BUDGET_YEAR_TYPE_ID)
	   OR ((recinfo.BUDGET_YEAR_TYPE_ID is null)
	       AND (P_BUDGET_YEAR_TYPE_ID is null)))

      AND ((recinfo.BALANCE_TYPE = P_BALANCE_TYPE)
	   OR ((recinfo.BALANCE_TYPE is null)
	       AND (P_BALANCE_TYPE is null)))

      AND ((recinfo.TEMPLATE_ID = P_TEMPLATE_ID)
	   OR ((recinfo.TEMPLATE_ID is null)
	       AND (P_TEMPLATE_ID is null)))

      AND ((recinfo.CONCATENATED_SEGMENTS = P_CONCATENATED_SEGMENTS)
	   OR ((recinfo.CONCATENATED_SEGMENTS is null)
	       AND (P_CONCATENATED_SEGMENTS is null)))

      AND ((recinfo.SEGMENT1 = P_SEGMENT1)
	   OR ((recinfo.SEGMENT1 is null)
	       AND (P_SEGMENT1 is null)))

      AND ((recinfo.SEGMENT2 = P_SEGMENT2)
	   OR ((recinfo.SEGMENT2 is null)
	       AND (P_SEGMENT2 is null)))

      AND ((recinfo.SEGMENT3 = P_SEGMENT3)
	   OR ((recinfo.SEGMENT3 is null)
	       AND (P_SEGMENT3 is null)))

      AND ((recinfo.SEGMENT4 = P_SEGMENT4)
	   OR ((recinfo.SEGMENT4 is null)
	       AND (P_SEGMENT4 is null)))

      AND ((recinfo.SEGMENT5 = P_SEGMENT5)
	   OR ((recinfo.SEGMENT5 is null)
	       AND (P_SEGMENT5 is null)))

      AND ((recinfo.SEGMENT6 = P_SEGMENT6)
	   OR ((recinfo.SEGMENT6 is null)
	       AND (P_SEGMENT6 is null)))

      AND ((recinfo.SEGMENT7 = P_SEGMENT7)
	   OR ((recinfo.SEGMENT7 is null)
	       AND (P_SEGMENT7 is null)))

      AND ((recinfo.SEGMENT8 = P_SEGMENT8)
	   OR ((recinfo.SEGMENT8 is null)
	       AND (P_SEGMENT8 is null)))

      AND ((recinfo.SEGMENT9 = P_SEGMENT9)
	   OR ((recinfo.SEGMENT9 is null)
	       AND (P_SEGMENT9 is null)))

      AND ((recinfo.SEGMENT10 = P_SEGMENT10)
	   OR ((recinfo.SEGMENT10 is null)
	       AND (P_SEGMENT10 is null)))

      AND ((recinfo.SEGMENT11 = P_SEGMENT11)
	   OR ((recinfo.SEGMENT11 is null)
	       AND (P_SEGMENT11 is null)))

      AND ((recinfo.SEGMENT12 = P_SEGMENT12)
	   OR ((recinfo.SEGMENT12 is null)
	       AND (P_SEGMENT12 is null)))

      AND ((recinfo.SEGMENT13 = P_SEGMENT13)
	   OR ((recinfo.SEGMENT13 is null)
	       AND (P_SEGMENT13 is null)))

      AND ((recinfo.SEGMENT14 = P_SEGMENT14)
	   OR ((recinfo.SEGMENT14 is null)
	       AND (P_SEGMENT14 is null)))

      AND ((recinfo.SEGMENT15 = P_SEGMENT15)
	   OR ((recinfo.SEGMENT15 is null)
	       AND (P_SEGMENT15 is null)))

      AND ((recinfo.SEGMENT16 = P_SEGMENT16)
	   OR ((recinfo.SEGMENT16 is null)
	       AND (P_SEGMENT16 is null)))

      AND ((recinfo.SEGMENT17 = P_SEGMENT17)
	   OR ((recinfo.SEGMENT17 is null)
	       AND (P_SEGMENT17 is null)))

      AND ((recinfo.SEGMENT18 = P_SEGMENT18)
	   OR ((recinfo.SEGMENT18 is null)
	       AND (P_SEGMENT18 is null)))

      AND ((recinfo.SEGMENT19 = P_SEGMENT19)
	   OR ((recinfo.SEGMENT19 is null)
	       AND (P_SEGMENT19 is null)))

      AND ((recinfo.SEGMENT20 = P_SEGMENT20)
	   OR ((recinfo.SEGMENT20 is null)
	       AND (P_SEGMENT20 is null)))

      AND ((recinfo.SEGMENT21 = P_SEGMENT21)
	   OR ((recinfo.SEGMENT21 is null)
	       AND (P_SEGMENT21 is null)))

      AND ((recinfo.SEGMENT22 = P_SEGMENT22)
	   OR ((recinfo.SEGMENT22 is null)
	       AND (P_SEGMENT22 is null)))

      AND ((recinfo.SEGMENT23 = P_SEGMENT23)
	   OR ((recinfo.SEGMENT23 is null)
	       AND (P_SEGMENT23 is null)))

      AND ((recinfo.SEGMENT24 = P_SEGMENT24)
	   OR ((recinfo.SEGMENT24 is null)
	       AND (P_SEGMENT24 is null)))

      AND ((recinfo.SEGMENT25 = P_SEGMENT25)
	   OR ((recinfo.SEGMENT25 is null)
	       AND (P_SEGMENT25 is null)))

      AND ((recinfo.SEGMENT26 = P_SEGMENT26)
	   OR ((recinfo.SEGMENT26 is null)
	       AND (P_SEGMENT26 is null)))

      AND ((recinfo.SEGMENT27 = P_SEGMENT27)
	   OR ((recinfo.SEGMENT27 is null)
	       AND (P_SEGMENT27 is null)))

      AND ((recinfo.SEGMENT28 = P_SEGMENT28)
	   OR ((recinfo.SEGMENT28 is null)
	       AND (P_SEGMENT28 is null)))

      AND ((recinfo.SEGMENT29 = P_SEGMENT29)
	   OR ((recinfo.SEGMENT29 is null)
	       AND (P_SEGMENT29 is null)))

      AND ((recinfo.SEGMENT30 = P_SEGMENT30)
	   OR ((recinfo.SEGMENT30 is null)
	       AND (P_SEGMENT30 is null)))

      AND ((recinfo.CURRENCY_CODE = P_CURRENCY_CODE)
	   OR ((recinfo.CURRENCY_CODE is null)
	       AND (P_CURRENCY_CODE is null)))

      AND ((recinfo.AMOUNT = P_AMOUNT)
	   OR ((recinfo.AMOUNT is null)
	       AND (P_AMOUNT is null)))

      AND ((recinfo.PREFIX_OPERATOR = P_PREFIX_OPERATOR)
	   OR ((recinfo.PREFIX_OPERATOR is null)
	       AND (P_PREFIX_OPERATOR is null)))

      AND ((recinfo.POSTFIX_OPERATOR = P_POSTFIX_OPERATOR)
	   OR ((recinfo.POSTFIX_OPERATOR is null)
	       AND (P_POSTFIX_OPERATOR is null)))

      AND ((recinfo.HIREDATE_BETWEEN_FROM = P_HIREDATE_BETWEEN_FROM)
	   OR ((recinfo.HIREDATE_BETWEEN_FROM is null)
	       AND (P_HIREDATE_BETWEEN_FROM is null)))

      AND ((recinfo.HIREDATE_BETWEEN_TO = P_HIREDATE_BETWEEN_TO)
	   OR ((recinfo.HIREDATE_BETWEEN_TO is null)
	       AND (P_HIREDATE_BETWEEN_TO is null)))

      AND ((recinfo.ADJDATE_BETWEEN_FROM = P_ADJDATE_BETWEEN_FROM)
	   OR ((recinfo.ADJDATE_BETWEEN_FROM is null)
	       AND (P_ADJDATE_BETWEEN_FROM is null)))

      AND ((recinfo.ADJDATE_BETWEEN_TO = P_ADJDATE_BETWEEN_TO)
	   OR ((recinfo.ADJDATE_BETWEEN_TO is null)
	       AND (P_ADJDATE_BETWEEN_TO is null)))

      AND ((recinfo.INCREMENT_BY = P_INCREMENT_BY)
	   OR ((recinfo.INCREMENT_BY is null)
	       AND (P_INCREMENT_BY is null)))

      AND ((recinfo.INCREMENT_TYPE = P_INCREMENT_TYPE)
	   OR ((recinfo.INCREMENT_TYPE is null)
	       AND (P_INCREMENT_TYPE is null)))

      AND ((recinfo.ASSIGNMENT_TYPE = P_ASSIGNMENT_TYPE)
	   OR ((recinfo.ASSIGNMENT_TYPE is null)
	       AND (P_ASSIGNMENT_TYPE is null)))

      AND ((recinfo.ATTRIBUTE_ID = P_ATTRIBUTE_ID)
	   OR ((recinfo.ATTRIBUTE_ID is null)
	       AND (P_ATTRIBUTE_ID is null)))

      AND ((recinfo.ATTRIBUTE_VALUE = P_ATTRIBUTE_VALUE)
	   OR ((recinfo.ATTRIBUTE_VALUE is null)
	       AND (P_ATTRIBUTE_VALUE is null)))

      AND ((recinfo.PAY_ELEMENT_ID = P_PAY_ELEMENT_ID)
	   OR ((recinfo.PAY_ELEMENT_ID is null)
	       AND (P_PAY_ELEMENT_ID is null)))

      AND ((recinfo.PAY_ELEMENT_OPTION_ID = P_PAY_ELEMENT_OPTION_ID)
	   OR ((recinfo.PAY_ELEMENT_OPTION_ID is null)
	       AND (P_PAY_ELEMENT_OPTION_ID is null)))

      AND ((recinfo.GRADE_STEP = P_GRADE_STEP)
	   OR ((recinfo.GRADE_STEP is null)
	       AND (P_GRADE_STEP is null)))

      AND ((recinfo.ELEMENT_VALUE = P_ELEMENT_VALUE)
	   OR ((recinfo.ELEMENT_VALUE is null)
	       AND (P_ELEMENT_VALUE is null)))

      AND ((recinfo.ELEMENT_VALUE_TYPE = P_ELEMENT_VALUE_TYPE)
	   OR ((recinfo.ELEMENT_VALUE_TYPE is null)
	       AND (P_ELEMENT_VALUE_TYPE is null)))

      AND ((recinfo.EFFECTIVE_START_DATE = P_EFFECTIVE_START_DATE)
	   OR ((recinfo.EFFECTIVE_START_DATE is null)
	       AND (P_EFFECTIVE_START_DATE is null)))

      AND ((recinfo.EFFECTIVE_END_DATE = P_EFFECTIVE_END_DATE)
	   OR ((recinfo.EFFECTIVE_END_DATE is null)
	       AND (P_EFFECTIVE_END_DATE is null)))

      AND ((recinfo.ATTRIBUTE1 = P_ATTRIBUTE1)
	   OR ((recinfo.ATTRIBUTE1 is null)
	       AND (P_ATTRIBUTE1 is null)))

      AND ((recinfo.ATTRIBUTE2 = P_ATTRIBUTE2)
	   OR ((recinfo.ATTRIBUTE2 is null)
	       AND (P_ATTRIBUTE2 is null)))

      AND ((recinfo.ATTRIBUTE3 = P_ATTRIBUTE3)
	   OR ((recinfo.ATTRIBUTE3 is null)
	       AND (P_ATTRIBUTE3 is null)))

      AND ((recinfo.ATTRIBUTE4 = P_ATTRIBUTE4)
	   OR ((recinfo.ATTRIBUTE4 is null)
	       AND (P_ATTRIBUTE4 is null)))

      AND ((recinfo.ATTRIBUTE5 = P_ATTRIBUTE5)
	   OR ((recinfo.ATTRIBUTE5 is null)
	       AND (P_ATTRIBUTE5 is null)))

      AND ((recinfo.ATTRIBUTE6 = P_ATTRIBUTE6)
	   OR ((recinfo.ATTRIBUTE6 is null)
	       AND (P_ATTRIBUTE6 is null)))

      AND ((recinfo.ATTRIBUTE7 = P_ATTRIBUTE7)
	   OR ((recinfo.ATTRIBUTE7 is null)
	       AND (P_ATTRIBUTE7 is null)))

      AND ((recinfo.ATTRIBUTE8 = P_ATTRIBUTE8)
	   OR ((recinfo.ATTRIBUTE8 is null)
	       AND (P_ATTRIBUTE8 is null)))

      AND ((recinfo.ATTRIBUTE9 = P_ATTRIBUTE9)
	   OR ((recinfo.ATTRIBUTE9 is null)
	       AND (P_ATTRIBUTE9 is null)))

      AND ((recinfo.ATTRIBUTE10 = P_ATTRIBUTE10)
	   OR ((recinfo.ATTRIBUTE10 is null)
	       AND (P_ATTRIBUTE10 is null)))

      AND ((recinfo.CONTEXT = P_CONTEXT)
	   OR ((recinfo.CONTEXT is null)
	       AND (P_CONTEXT is null)))


  THEN
     null;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );

EXCEPTION

  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN

    ROLLBACK TO Lock_Row_Pvt ;
    p_lock_row  :=  FND_API.G_FALSE;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt ;
    p_lock_row  :=  FND_API.G_FALSE;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

END Lock_Row;

procedure UPDATE_ROW (
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,

  P_ROWID IN VARCHAR2,
  P_PARAMETER_FORMULA_ID in NUMBER,
  P_PARAMETER_ID in NUMBER,
  P_STEP_NUMBER in NUMBER,
  P_BUDGET_YEAR_TYPE_ID in NUMBER,
  P_BALANCE_TYPE in VARCHAR2,
  P_TEMPLATE_ID in NUMBER,
  P_CONCATENATED_SEGMENTS in VARCHAR2,
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
  P_CURRENCY_CODE in VARCHAR2,
  P_AMOUNT in NUMBER,
  P_PREFIX_OPERATOR in VARCHAR2,
  P_POSTFIX_OPERATOR in VARCHAR2,
  P_HIREDATE_BETWEEN_FROM in NUMBER,
  P_HIREDATE_BETWEEN_TO in NUMBER,
  P_ADJDATE_BETWEEN_FROM in NUMBER,
  P_ADJDATE_BETWEEN_TO in NUMBER,
  P_INCREMENT_BY in NUMBER,
  P_INCREMENT_TYPE in VARCHAR2,
  P_ASSIGNMENT_TYPE IN VARCHAR2,
  P_ATTRIBUTE_ID IN NUMBER,
  P_ATTRIBUTE_VALUE IN VARCHAR2,
  P_PAY_ELEMENT_ID in NUMBER,
  P_PAY_ELEMENT_OPTION_ID IN NUMBER,
  P_GRADE_STEP IN NUMBER,
  P_ELEMENT_VALUE in NUMBER,
  P_ELEMENT_VALUE_TYPE in VARCHAR2,
  P_EFFECTIVE_START_DATE in DATE,
  P_EFFECTIVE_END_DATE in DATE,
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
  p_Last_Update_Date                   DATE,
  p_Last_Updated_By                    NUMBER,
  p_Last_Update_Login                  NUMBER
) is

  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

BEGIN

  SAVEPOINT Update_Row_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  update PSB_PARAMETER_FORMULAS set
    PARAMETER_ID = P_PARAMETER_ID,
    PARAMETER_FORMULA_ID = P_PARAMETER_FORMULA_ID,
    STEP_NUMBER = P_STEP_NUMBER,
    BUDGET_YEAR_TYPE_ID = P_BUDGET_YEAR_TYPE_ID,
    BALANCE_TYPE = P_BALANCE_TYPE,
    TEMPLATE_ID = P_TEMPLATE_ID,
    CONCATENATED_SEGMENTS = P_CONCATENATED_SEGMENTS,
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
    CURRENCY_CODE = P_CURRENCY_CODE,
    AMOUNT = P_AMOUNT,
    PREFIX_OPERATOR = P_PREFIX_OPERATOR,
    POSTFIX_OPERATOR = P_POSTFIX_OPERATOR,
    HIREDATE_BETWEEN_FROM = P_HIREDATE_BETWEEN_FROM,
    HIREDATE_BETWEEN_TO = P_HIREDATE_BETWEEN_TO,
    ADJDATE_BETWEEN_FROM = P_ADJDATE_BETWEEN_FROM,
    ADJDATE_BETWEEN_TO = P_ADJDATE_BETWEEN_TO,
    INCREMENT_BY = P_INCREMENT_BY,
    INCREMENT_TYPE = P_INCREMENT_TYPE,
    ASSIGNMENT_TYPE = P_ASSIGNMENT_TYPE,
    ATTRIBUTE_ID = P_ATTRIBUTE_ID,
    ATTRIBUTE_VALUE = P_ATTRIBUTE_VALUE,
    PAY_ELEMENT_ID = P_PAY_ELEMENT_ID,
    PAY_ELEMENT_OPTION_ID = P_PAY_ELEMENT_OPTION_ID,
    GRADE_STEP = P_GRADE_STEP,
    ELEMENT_VALUE = P_ELEMENT_VALUE,
    ELEMENT_VALUE_TYPE = P_ELEMENT_VALUE_TYPE,
    EFFECTIVE_START_DATE = P_EFFECTIVE_START_DATE,
    EFFECTIVE_END_DATE = P_EFFECTIVE_END_DATE,
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
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where ROWID = P_ROWID;


  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND ;
  END IF;

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

END Update_Row;

procedure DELETE_ROW (
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,

  P_PARAMETER_FORMULA_ID in NUMBER
) is

  l_api_name            CONSTANT VARCHAR2(30)   := 'Delete_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

BEGIN

  SAVEPOINT Delete_Row_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  delete from PSB_PARAMETER_FORMULAS
  where PARAMETER_FORMULA_ID = P_PARAMETER_FORMULA_ID;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND ;
  END IF;

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

END Delete_Row;

end PSB_PARAMETER_FORMULAS_PVT;

/
