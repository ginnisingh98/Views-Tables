--------------------------------------------------------
--  DDL for Package PSB_RULE_WITHIN_SEGMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_RULE_WITHIN_SEGMENT_PVT" AUTHID CURRENT_USER as
 /* $Header: PSBVWSPS.pls 120.2 2005/07/13 11:31:32 shtripat noship $ */

procedure INSERT_ROW (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_ROWID                       IN OUT  NOCOPY  VARCHAR2,
  P_RULE_ID                     IN      NUMBER,
  P_SEGMENT_NAME                IN      VARCHAR2,
  P_APPLICATION_COLUMN_NAME     IN      VARCHAR2,
  p_Last_Update_Date                    DATE,
  p_Last_Updated_By                     NUMBER,
  p_Last_Update_Login                   NUMBER,
  p_Created_By                          NUMBER,
  p_Creation_Date                       DATE
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
  P_RULE_ID                     IN      NUMBER,
  P_SEGMENT_NAME                IN      VARCHAR2,
  P_APPLICATION_COLUMN_NAME     IN      VARCHAR2
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
  P_RULE_ID                     IN      NUMBER,
  P_SEGMENT_NAME                IN      VARCHAR2,
  P_APPLICATION_COLUMN_NAME     IN      VARCHAR2,
  p_Last_Update_Date                    DATE,
  p_Last_Updated_By                     NUMBER,
  p_Last_Update_Login                   NUMBER
);


procedure DELETE_ROW (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_RULE_ID                     IN      NUMBER,
  P_APPLICATION_COLUMN_NAME     IN      VARCHAR2
);

FUNCTION VALIDATE_ACCOUNT_SEGMENT (
  p_str                         IN      VARCHAR2,
  p_sets                        IN      VARCHAR2,
  p_chart_of_accounts_id        IN      VARCHAR2,
  p_app_column_name             IN      VARCHAR2
)  RETURN BOOLEAN;

end PSB_RULE_WITHIN_SEGMENT_PVT;

 

/
