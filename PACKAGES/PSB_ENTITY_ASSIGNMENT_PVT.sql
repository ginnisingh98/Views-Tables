--------------------------------------------------------
--  DDL for Package PSB_ENTITY_ASSIGNMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_ENTITY_ASSIGNMENT_PVT" AUTHID CURRENT_USER as
 /* $Header: PSBVEAPS.pls 120.2 2005/07/13 11:24:36 shtripat ship $ */

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
  P_ENTITY_ID in NUMBER,
  P_PRIORITY in NUMBER,
  P_SEVERITY_LEVEL in NUMBER,
  P_EFFECTIVE_START_DATE in DATE,
  P_EFFECTIVE_END_DATE in DATE,
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
  P_ENTITY_ID in NUMBER,
  P_PRIORITY in NUMBER,
  P_SEVERITY_LEVEL in NUMBER,
  P_EFFECTIVE_START_DATE in DATE,
  P_EFFECTIVE_END_DATE in DATE
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
  P_ENTITY_ID in NUMBER,
  P_PRIORITY in NUMBER,
  P_SEVERITY_LEVEL in NUMBER,
  P_EFFECTIVE_START_DATE in DATE,
  P_EFFECTIVE_END_DATE in DATE,
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
  P_ENTITY_SET_ID in NUMBER,
  P_ENTITY_ID in NUMBER
);

end PSB_ENTITY_ASSIGNMENT_PVT;

 

/
