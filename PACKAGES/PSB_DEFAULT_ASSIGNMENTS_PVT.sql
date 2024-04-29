--------------------------------------------------------
--  DDL for Package PSB_DEFAULT_ASSIGNMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_DEFAULT_ASSIGNMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVPDAS.pls 120.2 2005/07/13 11:28:02 shtripat ship $ */


PROCEDURE INSERT_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_ROW_ID                           IN OUT  NOCOPY  VARCHAR2,
  P_DEFAULT_ASSIGNMENT_ID            IN      NUMBER,
  P_DEFAULT_RULE_ID                  in      NUMBER,
  P_ASSIGNMENT_TYPE                  IN      VARCHAR2,
  P_ATTRIBUTE_ID                     IN      NUMBER,
  P_ATTRIBUTE_VALUE_ID               IN      NUMBER,
  P_ATTRIBUTE_VALUE                  IN      VARCHAR2,
  P_PAY_ELEMENT_ID                   IN      NUMBER,
  P_PAY_ELEMENT_OPTION_ID            IN      NUMBER,
  P_PAY_BASIS                        IN      VARCHAR2,
  P_ELEMENT_VALUE_TYPE               IN      VARCHAR2,
  P_ELEMENT_VALUE                    IN      NUMBER,
  P_CURRENCY_CODE                    IN      VARCHAR2,
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
  P_ROW_ID                           IN      VARCHAR2,
  P_DEFAULT_ASSIGNMENT_ID            IN      NUMBER,
  P_DEFAULT_RULE_ID                  in      NUMBER,
  P_ASSIGNMENT_TYPE                  IN      VARCHAR2,
  P_ATTRIBUTE_ID                     IN      NUMBER,
  P_ATTRIBUTE_VALUE_ID               IN      NUMBER,
  P_ATTRIBUTE_VALUE                  IN      VARCHAR2,
  P_PAY_ELEMENT_ID                   IN      NUMBER,
  P_PAY_ELEMENT_OPTION_ID            IN      NUMBER,
  P_PAY_BASIS                        IN      VARCHAR2,
  P_ELEMENT_VALUE_TYPE               IN      VARCHAR2,
  P_ELEMENT_VALUE                    IN      NUMBER,
  P_CURRENCY_CODE                    IN      VARCHAR2,
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
  P_ROW_ID                           IN      VARCHAR2,
  P_DEFAULT_ASSIGNMENT_ID            IN      NUMBER,
  P_DEFAULT_RULE_ID                  in      NUMBER,
  P_ASSIGNMENT_TYPE                  IN      VARCHAR2,
  P_ATTRIBUTE_ID                     IN      NUMBER,
  P_ATTRIBUTE_VALUE_ID               IN      NUMBER,
  P_ATTRIBUTE_VALUE                  IN      VARCHAR2,
  P_PAY_ELEMENT_ID                   IN      NUMBER,
  P_PAY_ELEMENT_OPTION_ID            IN      NUMBER,
  P_PAY_BASIS                        IN      VARCHAR2,
  P_ELEMENT_VALUE_TYPE               IN      VARCHAR2,
  P_ELEMENT_VALUE                    IN      NUMBER,
  P_CURRENCY_CODE                    IN      VARCHAR2
);

PROCEDURE CHECK_UNIQUE
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  p_return_value                     IN OUT  NOCOPY     VARCHAR2,
  --
  P_DEFAULT_RULE_ID                  IN      NUMBER,
  P_DEFAULT_ASSIGNMENT_ID            IN      NUMBER,
  P_ATTRIBUTE_ID                     IN      NUMBER,
  P_PAY_ELEMENT_ID                   IN      NUMBER,
  P_PAY_ELEMENT_OPTION_ID            IN      NUMBER
);


END PSB_DEFAULT_ASSIGNMENTS_PVT;

 

/
