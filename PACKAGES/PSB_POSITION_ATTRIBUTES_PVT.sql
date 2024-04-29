--------------------------------------------------------
--  DDL for Package PSB_POSITION_ATTRIBUTES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_POSITION_ATTRIBUTES_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVPATS.pls 120.3 2006/06/28 12:18:12 mvenugop ship $ */


PROCEDURE INSERT_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  p_ROW_ID                      IN OUT  NOCOPY  VARCHAR2,
  p_ATTRIBUTE_ID                IN      NUMBER,
  p_BUSINESS_GROUP_ID           IN      NUMBER,
  p_NAME                        IN      VARCHAR2,
  p_DISPLAY_IN_WORKSHEET        IN      VARCHAR2,
  p_DISPLAY_SEQUENCE            IN      NUMBER,
  p_DISPLAY_PROMPT              IN      VARCHAR2,
  p_REQUIRED_FOR_IMPORT_FLAG    IN      VARCHAR2,
  p_REQUIRED_FOR_POSITIONS_FLAG IN      VARCHAR2,
  p_ALLOW_IN_POSITION_SET_FLAG  IN      VARCHAR2,
  p_VALUE_TABLE_FLAG            IN      VARCHAR2,
  p_PROTECTED_FLAG              IN      VARCHAR2,
  p_DEFINITION_TYPE             IN      VARCHAR2,
  p_DEFINITION_STRUCTURE        IN      VARCHAR2,
  p_DEFINITION_TABLE            IN      VARCHAR2,
  p_DEFINITION_COLUMN           IN      VARCHAR2,
  p_ATTRIBUTE_TYPE_ID           IN      NUMBER,
  p_DATA_TYPE                   IN      VARCHAR2,
  p_APPLICATION_ID              IN      NUMBER,
  p_SYSTEM_ATTRIBUTE_TYPE       IN      VARCHAR2,
  p_LAST_UPDATE_DATE            IN      DATE,
  p_LAST_UPDATED_BY             IN      NUMBER,
  p_LAST_UPDATE_LOGIN           IN      NUMBER,
  p_CREATED_BY                  IN      NUMBER,
  p_CREATION_DATE               IN      DATE
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
  p_ATTRIBUTE_ID                IN      NUMBER,
  p_BUSINESS_GROUP_ID           IN      NUMBER,
  p_NAME                        IN      VARCHAR2,
  p_DISPLAY_IN_WORKSHEET        IN      VARCHAR2,
  p_DISPLAY_SEQUENCE            IN      NUMBER,
  p_DISPLAY_PROMPT              IN      VARCHAR2,
  p_REQUIRED_FOR_IMPORT_FLAG    IN      VARCHAR2,
  p_REQUIRED_FOR_POSITIONS_FLAG IN      VARCHAR2,
  p_ALLOW_IN_POSITION_SET_FLAG  IN      VARCHAR2,
  p_VALUE_TABLE_FLAG            IN      VARCHAR2,
  p_PROTECTED_FLAG              IN      VARCHAR2,
  p_DEFINITION_TYPE             IN      VARCHAR2,
  p_DEFINITION_STRUCTURE        IN      VARCHAR2,
  p_DEFINITION_TABLE            IN      VARCHAR2,
  p_DEFINITION_COLUMN           IN      VARCHAR2,
  p_ATTRIBUTE_TYPE_ID           IN      NUMBER,
  p_DATA_TYPE                   IN      VARCHAR2,
  p_APPLICATION_ID              IN      NUMBER,
  p_SYSTEM_ATTRIBUTE_TYPE       IN      VARCHAR2,
  p_LAST_UPDATE_DATE            IN      DATE,
  p_LAST_UPDATED_BY             IN      NUMBER,
  p_LAST_UPDATE_LOGIN           IN      NUMBER
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
  p_ATTRIBUTE_ID                IN      NUMBER
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
  p_lock_row                    OUT  NOCOPY     VARCHAR2,
  --
  p_ROW_ID                      IN      VARCHAR2,
  p_ATTRIBUTE_ID                IN      NUMBER,
  p_BUSINESS_GROUP_ID           IN      NUMBER,
  p_NAME                        IN      VARCHAR2,
  p_DISPLAY_IN_WORKSHEET        IN      VARCHAR2,
  p_DISPLAY_SEQUENCE            IN      NUMBER,
  p_DISPLAY_PROMPT              IN      VARCHAR2,
  p_REQUIRED_FOR_IMPORT_FLAG    IN      VARCHAR2,
  p_REQUIRED_FOR_POSITIONS_FLAG IN      VARCHAR2,
  p_ALLOW_IN_POSITION_SET_FLAG  IN      VARCHAR2,
  p_VALUE_TABLE_FLAG            IN      VARCHAR2,
  p_PROTECTED_FLAG              IN      VARCHAR2,
  p_DEFINITION_TYPE             IN      VARCHAR2,
  p_DEFINITION_STRUCTURE        IN      VARCHAR2,
  p_DEFINITION_TABLE            IN      VARCHAR2,
  p_DEFINITION_COLUMN           IN      VARCHAR2,
  p_ATTRIBUTE_TYPE_ID           IN      NUMBER,
  p_DATA_TYPE                   IN      VARCHAR2,
  p_APPLICATION_ID              IN      NUMBER,
  p_SYSTEM_ATTRIBUTE_TYPE       IN      VARCHAR2
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
  p_Row_Id                    IN       VARCHAR2,
  p_Name                      IN       VARCHAR2,
  p_Business_Group_ID         IN       NUMBER,
  p_Return_Value              IN OUT  NOCOPY   VARCHAR2
);

PROCEDURE Check_References1
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_ATTRIBUTE_ID              IN       NUMBER,
  p_Return_Value              IN OUT  NOCOPY   VARCHAR2
);



PROCEDURE Check_References2
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_attribute_id              IN       NUMBER,
  p_Return_Value              IN OUT  NOCOPY   VARCHAR2
);

PROCEDURE Insert_System_Attributes
(

  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  p_business_group_id           IN      NUMBER
);

FUNCTION GET_TRANSLATED_NAME(p_sys_attribute_type IN  varchar2)
RETURN varchar2;
PRAGMA RESTRICT_REFERENCES(GET_TRANSLATED_NAME, WNDS);

PROCEDURE ADD_LANGUAGE;

END PSB_POSITION_ATTRIBUTES_PVT;

 

/
