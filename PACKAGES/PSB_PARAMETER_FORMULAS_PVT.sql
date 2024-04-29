--------------------------------------------------------
--  DDL for Package PSB_PARAMETER_FORMULAS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_PARAMETER_FORMULAS_PVT" AUTHID CURRENT_USER as
 /* $Header: PSBVPFPS.pls 120.2 2005/07/13 11:28:27 shtripat ship $ */
procedure INSERT_ROW (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_ROWID in OUT  NOCOPY VARCHAR2,
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
  P_CONTEXT in VARCHAR2,
  p_Last_Update_Date                   DATE,
  p_Last_Updated_By                    NUMBER,
  p_Last_Update_Login                  NUMBER,
  p_Created_By                         NUMBER,
  p_Creation_Date                      DATE
);


procedure LOCK_ROW (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  p_lock_row                    OUT  NOCOPY     VARCHAR2,
  --
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
);

procedure UPDATE_ROW (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
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
  P_CONTEXT in VARCHAR2,
  p_Last_Update_Date                   DATE,
  p_Last_Updated_By                    NUMBER,
  p_Last_Update_Login                  NUMBER
);

procedure DELETE_ROW (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_PARAMETER_FORMULA_ID in NUMBER
);

end PSB_PARAMETER_FORMULAS_PVT;

 

/