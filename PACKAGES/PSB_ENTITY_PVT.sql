--------------------------------------------------------
--  DDL for Package PSB_ENTITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_ENTITY_PVT" AUTHID CURRENT_USER as
 /* $Header: PSBVENPS.pls 120.2 2005/07/13 11:24:54 shtripat ship $ */

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
  P_EFFECTIVE_END_DATE   in DATE := FND_API.G_MISS_DATE);

procedure UPDATE_ROW (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
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
);


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
  P_BUDGET_GROUP_ID             in NUMBER := FND_API.G_MISS_NUM,
  P_ALLOCATION_TYPE             in VARCHAR2,
  P_BUDGET_YEAR_TYPE_ID         in NUMBER,
  P_BALANCE_TYPE                in VARCHAR2,
  P_PARAMETER_AUTOINC_RULE      in VARCHAR2,
  P_PARAMETER_COMPOUND_ANNUALLY in VARCHAR2,
  P_CURRENCY_CODE               in VARCHAR2,
  P_FTE_CONSTRAINT              in VARCHAR2,
  P_CONSTRAINT_DETAILED_FLAG    in VARCHAR2,
/* Budget Revision Rules Enhancement Start */
  P_APPLY_ACCOUNT_SET_FLAG in VARCHAR2,
  P_BALANCE_ACCOUNT_SET_FLAG in VARCHAR2,
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
  P_ENTITY_ID in NUMBER
);


end PSB_ENTITY_PVT;

 

/
