--------------------------------------------------------
--  DDL for Package PSB_ENTITY_SET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_ENTITY_SET_PVT" AUTHID CURRENT_USER as
 /* $Header: PSBVESPS.pls 120.5 2005/03/16 05:32:46 shtripat ship $ */

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
  P_ENTITY_SET_ID in NUMBER,
  P_ENTITY_TYPE in VARCHAR2,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_BUDGET_GROUP_ID in NUMBER,
  P_SET_OF_BOOKS_ID in NUMBER,
  P_DATA_EXTRACT_ID IN NUMBER,
  P_CONSTRAINT_THRESHOLD in NUMBER,
  /* Budget Revision Rules Enhancement Start */
  P_ENABLE_FLAG in VARCHAR2,
  /* Budget Revision Rules Enhancement End */
  /* Bug 4151746 Start */
  P_EXECUTABLE_FROM_POSITION IN VARCHAR2 DEFAULT NULL,
  /* Bug 4151746 End */
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
  P_ENTITY_SET_ID in NUMBER,
  P_ENTITY_TYPE in VARCHAR2,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_BUDGET_GROUP_ID in NUMBER,
  P_SET_OF_BOOKS_ID in NUMBER,
  P_DATA_EXTRACT_ID IN NUMBER,
  P_CONSTRAINT_THRESHOLD in NUMBER,
  /* Budget Revision Rules Enhancement Start */
  P_ENABLE_FLAG in VARCHAR2,
  /* Budget Revision Rules Enhancement End */
  /* Bug 4151746 Start */
  P_EXECUTABLE_FROM_POSITION IN VARCHAR2 DEFAULT NULL,
  /* Bug 4151746 End */
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
  P_ENTITY_SET_ID in NUMBER,
  P_ENTITY_TYPE in VARCHAR2,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_BUDGET_GROUP_ID in NUMBER,
  P_SET_OF_BOOKS_ID in NUMBER,
  P_DATA_EXTRACT_ID IN NUMBER,
  P_CONSTRAINT_THRESHOLD in NUMBER,
  /* Budget Revision Rules Enhancement Start */
  P_ENABLE_FLAG in VARCHAR2,
  /* Budget Revision Rules Enhancement End */
  /* Bug 4151746 Start */
  P_EXECUTABLE_FROM_POSITION IN VARCHAR2 DEFAULT NULL,
  /* Bug 4151746 End */
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
  P_ENTITY_SET_ID in NUMBER
);

PROCEDURE Copy_Entity_Set
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  p_source_entity_set_id        IN      NUMBER,
  p_target_entity_set_id        IN      NUMBER,
  p_target_data_extract_id      IN      NUMBER,
  p_entity_type                 IN      VARCHAR2
);

/*For Bug No : 2397852 Start*/
PROCEDURE Check_References
(
  p_api_version               IN             NUMBER,
  p_init_msg_list             IN             VARCHAR2,
  p_commit                    IN             VARCHAR2,
  p_validation_level          IN             NUMBER,
  p_return_status             OUT    NOCOPY  VARCHAR2,
  p_msg_count                 OUT    NOCOPY  NUMBER,
  p_msg_data                  OUT    NOCOPY  VARCHAR2,
  --
  p_entity_set_id             IN             NUMBER,
  p_return_value              OUT    NOCOPY  VARCHAR2
);
/*For Bug No : 2397852 End*/

end PSB_ENTITY_SET_PVT;

 

/
