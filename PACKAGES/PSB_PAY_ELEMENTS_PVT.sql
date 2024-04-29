--------------------------------------------------------
--  DDL for Package PSB_PAY_ELEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_PAY_ELEMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVELMS.pls 120.2 2005/07/13 11:24:42 shtripat ship $ */


PROCEDURE INSERT_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_ROW_ID                           in OUT  NOCOPY  VARCHAR2,
  P_PAY_ELEMENT_ID                   in      NUMBER,
  P_BUSINESS_GROUP_ID                in      NUMBER,
  P_DATA_EXTRACT_ID                  in      NUMBER,
  P_BUDGET_SET_ID                    in      NUMBER := FND_API.G_MISS_NUM,
  P_NAME                             in      VARCHAR2,
  P_DESCRIPTION                      in      VARCHAR2,
  P_ELEMENT_VALUE_TYPE               in      VARCHAR2,
  P_FORMULA_ID                       in      NUMBER,
  P_OVERWRITE_FLAG                   in      VARCHAR2,
  P_REQUIRED_FLAG                    in      VARCHAR2,
  P_FOLLOW_SALARY                    in      VARCHAR2,
  P_PAY_BASIS                        IN      VARCHAR2,
  P_START_DATE                       in      DATE,
  P_END_DATE                         in      DATE,
  P_PROCESSING_TYPE                  in      VARCHAR2,
  P_PERIOD_TYPE                      in      VARCHAR2,
  P_PROCESS_PERIOD_TYPE              in      VARCHAR2,
  P_MAX_ELEMENT_VALUE_TYPE           in      VARCHAR2,
  P_MAX_ELEMENT_VALUE                in      NUMBER,
  P_SALARY_FLAG                      in      VARCHAR2,
  P_SALARY_TYPE                      in      VARCHAR2,
  P_OPTION_FLAG                      in      VARCHAR2,
  P_HR_ELEMENT_TYPE_ID               in      NUMBER,
  P_ATTRIBUTE_CATEGORY               in      VARCHAR2,
  P_ATTRIBUTE1                       in      VARCHAR2,
  P_ATTRIBUTE2                       in      VARCHAR2,
  P_ATTRIBUTE3                       in      VARCHAR2,
  P_ATTRIBUTE4                       in      VARCHAR2,
  P_ATTRIBUTE5                       in      VARCHAR2,
  P_ATTRIBUTE6                       in      VARCHAR2,
  P_ATTRIBUTE7                       in      VARCHAR2,
  P_ATTRIBUTE8                       in      VARCHAR2,
  P_ATTRIBUTE9                       in      VARCHAR2,
  P_ATTRIBUTE10                      in      VARCHAR2,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER,
  P_CREATED_BY                       in      NUMBER,
  P_CREATION_DATE                    in      DATE
);

PROCEDURE UPDATE_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_ROW_ID                           in      VARCHAR2,
  P_PAY_ELEMENT_ID                   in      NUMBER,
  P_BUSINESS_GROUP_ID                in      NUMBER,
  P_DATA_EXTRACT_ID                  in      NUMBER,
  P_BUDGET_SET_ID                    in      NUMBER := FND_API.G_MISS_NUM,
  P_NAME                             in      VARCHAR2,
  P_DESCRIPTION                      in      VARCHAR2,
  P_ELEMENT_VALUE_TYPE               in      VARCHAR2,
  P_FORMULA_ID                       in      NUMBER,
  P_OVERWRITE_FLAG                   in      VARCHAR2,
  P_REQUIRED_FLAG                    in      VARCHAR2,
  P_FOLLOW_SALARY                    in      VARCHAR2,
  P_PAY_BASIS                        IN      VARCHAR2,
  P_START_DATE                       in      DATE,
  P_END_DATE                         in      DATE,
  P_PROCESSING_TYPE                  in      VARCHAR2,
  P_PERIOD_TYPE                      in      VARCHAR2,
  P_PROCESS_PERIOD_TYPE              in      VARCHAR2,
  P_MAX_ELEMENT_VALUE_TYPE           in      VARCHAR2,
  P_MAX_ELEMENT_VALUE                in      NUMBER,
  P_SALARY_FLAG                      in      VARCHAR2,
  P_SALARY_TYPE                      in      VARCHAR2,
  P_OPTION_FLAG                      in      VARCHAR2,
  P_HR_ELEMENT_TYPE_ID               in      NUMBER,
  P_ATTRIBUTE_CATEGORY               in      VARCHAR2,
  P_ATTRIBUTE1                       in      VARCHAR2,
  P_ATTRIBUTE2                       in      VARCHAR2,
  P_ATTRIBUTE3                       in      VARCHAR2,
  P_ATTRIBUTE4                       in      VARCHAR2,
  P_ATTRIBUTE5                       in      VARCHAR2,
  P_ATTRIBUTE6                       in      VARCHAR2,
  P_ATTRIBUTE7                       in      VARCHAR2,
  P_ATTRIBUTE8                       in      VARCHAR2,
  P_ATTRIBUTE9                       in      VARCHAR2,
  P_ATTRIBUTE10                      in      VARCHAR2,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER
);

PROCEDURE DELETE_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_ROW_ID                      IN      VARCHAR2
);

PROCEDURE LOCK_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  p_row_locked                       OUT  NOCOPY     VARCHAR2,
  --
  P_ROW_ID                           in      VARCHAR2,
  P_PAY_ELEMENT_ID                   in      NUMBER,
  P_BUSINESS_GROUP_ID                in      NUMBER,
  P_DATA_EXTRACT_ID                  in      NUMBER,
  P_BUDGET_SET_ID                    in      NUMBER := FND_API.G_MISS_NUM,
  P_NAME                             in      VARCHAR2,
  P_DESCRIPTION                      in      VARCHAR2,
  P_ELEMENT_VALUE_TYPE               in      VARCHAR2,
  P_FORMULA_ID                       in      NUMBER,
  P_OVERWRITE_FLAG                   in      VARCHAR2,
  P_REQUIRED_FLAG                    in      VARCHAR2,
  P_FOLLOW_SALARY                    in      VARCHAR2,
  P_PAY_BASIS                        IN      VARCHAR2,
  P_START_DATE                       in      DATE,
  P_END_DATE                         in      DATE,
  P_PROCESSING_TYPE                  in      VARCHAR2,
  P_PERIOD_TYPE                      in      VARCHAR2,
  P_PROCESS_PERIOD_TYPE              in      VARCHAR2,
  P_MAX_ELEMENT_VALUE_TYPE           in      VARCHAR2,
  P_MAX_ELEMENT_VALUE                in      NUMBER,
  P_SALARY_FLAG                      in      VARCHAR2,
  P_SALARY_TYPE                      in      VARCHAR2,
  P_OPTION_FLAG                      in      VARCHAR2,
  P_HR_ELEMENT_TYPE_ID               in      NUMBER,
  P_ATTRIBUTE_CATEGORY               in      VARCHAR2,
  P_ATTRIBUTE1                       in      VARCHAR2,
  P_ATTRIBUTE2                       in      VARCHAR2,
  P_ATTRIBUTE3                       in      VARCHAR2,
  P_ATTRIBUTE4                       in      VARCHAR2,
  P_ATTRIBUTE5                       in      VARCHAR2,
  P_ATTRIBUTE6                       in      VARCHAR2,
  P_ATTRIBUTE7                       in      VARCHAR2,
  P_ATTRIBUTE8                       in      VARCHAR2,
  P_ATTRIBUTE9                       in      VARCHAR2,
  P_ATTRIBUTE10                      in      VARCHAR2
);

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
  P_Row_Id                    IN       VARCHAR2,
  P_Name                      IN       VARCHAR2,
  P_DATA_EXTRACT_ID           IN       NUMBER,
  P_Return_Value              IN OUT  NOCOPY   VARCHAR2
);

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
  P_PAY_ELEMENT_Id            IN       NUMBER,
  P_Return_Value              IN OUT  NOCOPY   VARCHAR2
);

PROCEDURE Copy_Pay_Elements
( p_api_version            IN    NUMBER,
  p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN    VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN    NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status          OUT  NOCOPY   VARCHAR2,
  p_msg_count              OUT  NOCOPY   NUMBER,
  p_msg_data               OUT  NOCOPY   VARCHAR2,
  p_source_pay_element_id  IN    NUMBER,
  p_source_data_extract_id IN    NUMBER,
  p_target_data_extract_id IN    NUMBER
);

END PSB_PAY_ELEMENTS_PVT;

 

/
