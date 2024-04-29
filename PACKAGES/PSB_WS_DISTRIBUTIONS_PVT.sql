--------------------------------------------------------
--  DDL for Package PSB_WS_DISTRIBUTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_DISTRIBUTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVWDTS.pls 120.2 2005/07/13 11:31:08 shtripat ship $ */


PROCEDURE Insert_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Row_Id                    IN OUT  NOCOPY   VARCHAR2,
  p_Distribution_Id           IN OUT  NOCOPY   NUMBER,
  p_Distribution_Rule_Id      IN       NUMBER,
  p_Worksheet_Id              IN       NUMBER,
  p_Distribution_Date         IN       DATE,
  p_Distributed_Flag          IN       VARCHAR2,
  p_Last_Update_Date          IN       DATE,
  p_Last_Updated_By           IN       NUMBER,
  p_Last_Update_Login         IN       NUMBER,
  p_Created_By                IN       NUMBER,
  p_Creation_Date             IN       DATE
);


PROCEDURE Lock_Row
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
  p_Distribution_Id           IN       NUMBER,
  p_Distribution_Rule_Id      IN       NUMBER,
  p_Worksheet_Id              IN       NUMBER,
  p_Distribution_Date         IN       DATE,
  p_Distributed_Flag          IN       VARCHAR2,
  --
  p_row_locked                OUT  NOCOPY      VARCHAR2
);


PROCEDURE Update_Row
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
  p_Distribution_Id           IN       NUMBER,
  p_Distribution_Rule_Id      IN       NUMBER,
  p_Worksheet_Id              IN       NUMBER,
  p_Distribution_Date         IN       DATE,
  p_Distributed_Flag          IN       VARCHAR2,
  p_Last_Update_Date          IN       DATE,
  p_Last_Updated_By           IN       NUMBER,
  p_Last_Update_Login         IN       NUMBER
);


PROCEDURE Delete_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Row_Id                    IN       VARCHAR2
);

END PSB_WS_Distributions_PVT ;

 

/
