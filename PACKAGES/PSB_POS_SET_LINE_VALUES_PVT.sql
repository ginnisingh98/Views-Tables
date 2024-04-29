--------------------------------------------------------
--  DDL for Package PSB_POS_SET_LINE_VALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_POS_SET_LINE_VALUES_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVSLVS.pls 120.2 2005/07/13 11:29:49 shtripat ship $ */


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
  p_Value_Sequence_Id         IN OUT  NOCOPY   NUMBER,
  p_Line_Sequence_Id          IN       NUMBER,
  p_Attribute_Value_Id        IN       NUMBER,
  p_Attribute_Value           IN       VARCHAR2,
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
  p_Value_Sequence_Id         IN       NUMBER,
  p_Line_Sequence_Id          IN       NUMBER,
  p_Attribute_Value_Id        IN       NUMBER,
  p_Attribute_Value           IN       VARCHAR2,
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
  p_Value_Sequence_Id         IN       NUMBER,
  p_Line_Sequence_Id          IN       NUMBER,
  p_Attribute_Value_Id        IN       NUMBER,
  p_Attribute_Value           IN       VARCHAR2,
  p_Last_Update_Date          IN       DATE,
  p_Last_Updated_By           IN       NUMBER,
  p_Last_Update_Login         IN       NUMBER
) ;


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
  p_Line_Sequence_id          IN       NUMBER,
  p_Attribute_Value_Id        IN       NUMBER,
  p_Attribute_Value           IN       VARCHAR2,
  p_Return_Value              IN OUT  NOCOPY   VARCHAR2
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
  p_Account_Position_Set_Id   IN       NUMBER,
  p_Return_Value              IN OUT  NOCOPY   VARCHAR2
);


END PSB_Pos_Set_Line_Values_Pvt;

 

/
