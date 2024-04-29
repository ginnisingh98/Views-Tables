--------------------------------------------------------
--  DDL for Package PSB_RULE_TRANSACTION_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_RULE_TRANSACTION_TYPE_PVT" AUTHID CURRENT_USER as
 /* $Header: PSBVTTPS.pls 120.2 2005/07/13 11:30:18 shtripat noship $ */

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
  P_TRANSACTION_TYPE            IN      VARCHAR2,
--Following 1 parameter added for Bug # 2123930.
  P_ENABLE_FLAG                 IN      VARCHAR2,
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
  P_TRANSACTION_TYPE            IN      VARCHAR2,
--Following 1 parameter added for Bug # 2123930.
  P_ENABLE_FLAG                 IN      VARCHAR2
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
  P_TRANSACTION_TYPE            IN      VARCHAR2,
--Following 1 parameter added for Bug # 2123930.
  P_ENABLE_FLAG                 IN      VARCHAR2,
  p_Last_Update_Date                    DATE,
  p_Last_Updated_By                     NUMBER,
  p_Last_Update_Login                   NUMBER
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
  P_RULE_ID                     IN      NUMBER,
  P_TRANSACTION_TYPE            IN      VARCHAR2,
--Following 1 parameter added for Bug # 2123930.
  P_ENABLE_FLAG                 IN      VARCHAR2
);


end PSB_RULE_TRANSACTION_TYPE_PVT;

 

/
