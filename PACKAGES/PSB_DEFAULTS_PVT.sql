--------------------------------------------------------
--  DDL for Package PSB_DEFAULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_DEFAULTS_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVPDFS.pls 120.3 2004/11/30 14:16:25 shtripat ship $ */


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
  P_DEFAULT_RULE_ID                  in      NUMBER,
  P_NAME                             in      VARCHAR2,
  P_GLOBAL_DEFAULT_FLAG              IN      VARCHAR2,
  P_DATA_EXTRACT_ID                  IN      NUMBER,
  P_BUSINESS_GROUP_ID                IN      NUMBER,
  P_ENTITY_ID                        IN      NUMBER,
  P_PRIORITY                         IN      NUMBER,
  P_CREATION_DATE                    in      DATE,
  P_CREATED_BY                       in      NUMBER,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER,
  /* Bug 1308558 Start */
  P_OVERWRITE                        IN      VARCHAR2 DEFAULT NULL
  /* Bug 1308558 End */
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
  P_DEFAULT_RULE_ID                  in      NUMBER,
  P_NAME                             in      VARCHAR2,
  P_GLOBAL_DEFAULT_FLAG              IN      VARCHAR2,
  P_DATA_EXTRACT_ID                  IN      NUMBER,
  P_BUSINESS_GROUP_ID                IN      NUMBER,
  P_ENTITY_ID                        IN      NUMBER,
  P_PRIORITY                         IN      NUMBER,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER,
  /* Bug 1308558 Start */
  P_OVERWRITE                        IN      VARCHAR2 DEFAULT NULL
  /* Bug 1308558 End */
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
  P_DEFAULT_RULE_ID             IN      NUMBER,
  P_ENTITY_ID                   IN      NUMBER,
  /* Bug 1308558 Start */
  P_SOURCE_FORM                      IN      VARCHAR2 DEFAULT NULL
  /* Bug 1308558 End */
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
  P_DEFAULT_RULE_ID                  in      NUMBER,
  P_NAME                             in      VARCHAR2,
  P_GLOBAL_DEFAULT_FLAG              IN      VARCHAR2,
  P_DATA_EXTRACT_ID                  IN      NUMBER,
  P_BUSINESS_GROUP_ID                IN      NUMBER,
  P_ENTITY_ID                        IN      NUMBER,
  P_PRIORITY                         IN      NUMBER,
  /* Bug 1308558 Start */
  P_OVERWRITE                        IN      VARCHAR2 DEFAULT NULL,
  P_SOURCE_FORM                      IN      VARCHAR2 DEFAULT 'F'
  /* Bug 1308558 End */
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
  P_DEFAULT_RULE_ID                  in      NUMBER,
  P_NAME                             in      VARCHAR2,
  P_DATA_EXTRACT_ID                  IN      NUMBER,
  P_RETURN_VALUE                     IN OUT  NOCOPY  VARCHAR2
);

PROCEDURE Check_Global_Default
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  P_ROW_ID                    IN       VARCHAR2,
  P_DATA_EXTRACT_ID           IN       NUMBER,
  P_GLOBAL_DEFAULT_FLAG       IN       VARCHAR2,
  P_RETURN_VALUE              IN OUT  NOCOPY   VARCHAR2
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
  P_DEFAULT_RULE_ID                  in      NUMBER,
  P_NAME                             in      VARCHAR2,
  P_RETURN_VALUE                     IN OUT  NOCOPY  VARCHAR2
);


END PSB_DEFAULTS_PVT;

 

/
