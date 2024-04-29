--------------------------------------------------------
--  DDL for Package PSB_WS_DISTRIBUTION_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_DISTRIBUTION_RULES_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVWDRS.pls 120.2 2005/07/13 11:30:56 shtripat ship $ */

 g_rule_id number;

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
  p_Distribution_Rule_Line_Id IN       NUMBER,
  p_Distribution_Rule_Id      IN       NUMBER,
  p_Budget_Group_Id           IN       NUMBER,
  p_distribute_flag           IN       VARCHAR2,
  p_distribute_all_level_flag IN       VARCHAR2,
  p_download_flag             IN       VARCHAR2,
  p_download_all_level_flag   IN       VARCHAR2,
  p_year_category_type        IN       VARCHAR2,
  p_attribute1  in varchar2,
  p_attribute2  in varchar2,
  p_attribute3  in varchar2,
  p_attribute4  in varchar2,
  p_attribute5  in varchar2,
  p_attribute6  in varchar2,
  p_attribute7  in varchar2,
  p_attribute8  in varchar2,
  p_attribute9  in varchar2,
  p_attribute10 in varchar2,
  p_context     in varchar2,
  p_mode        in varchar2 default 'R'
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
  p_Distribution_Rule_Line_Id IN       NUMBER,
  p_Distribution_Rule_Id      IN       NUMBER,
  p_Budget_Group_Id           IN       NUMBER,
  p_distribute_flag           IN       VARCHAR2,
  p_distribute_all_level_flag IN       VARCHAR2,
  p_download_flag             IN       VARCHAR2,
  p_download_all_level_flag   IN       VARCHAR2,
  p_year_category_type        IN       VARCHAR2,
  p_attribute1  in varchar2,
  p_attribute2  in varchar2,
  p_attribute3  in varchar2,
  p_attribute4  in varchar2,
  p_attribute5  in varchar2,
  p_attribute6  in varchar2,
  p_attribute7  in varchar2,
  p_attribute8  in varchar2,
  p_attribute9  in varchar2,
  p_attribute10 in varchar2,
  p_context     in varchar2,
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
  p_Distribution_Rule_Line_Id IN       NUMBER,
  p_Distribution_Rule_Id      IN       NUMBER,
  p_Budget_Group_Id           IN       NUMBER,
  p_distribute_flag           IN       VARCHAR2,
  p_distribute_all_level_flag IN       VARCHAR2,
  p_download_flag             IN       VARCHAR2,
  p_download_all_level_flag   IN       VARCHAR2,
  p_year_category_type        IN       VARCHAR2,
  p_attribute1  in varchar2,
  p_attribute2  in varchar2,
  p_attribute3  in varchar2,
  p_attribute4  in varchar2,
  p_attribute5  in varchar2,
  p_attribute6  in varchar2,
  p_attribute7  in varchar2,
  p_attribute8  in varchar2,
  p_attribute9  in varchar2,
  p_attribute10 in varchar2,
  p_context     in varchar2,
  p_mode        in varchar2 default 'R'
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
  p_Distribution_Rule_Line_Id IN       NUMBER
);

PROCEDURE Rules_Insert_Row
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
  p_Distribution_Rule_Id      IN       NUMBER,
  P_Budget_Group_Id           IN       NUMBER,
  p_Name                      IN       VARCHAR2,
  p_mode                      in varchar2 default 'R'
);


PROCEDURE Rules_Delete_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Distribution_Rule_Id      IN       NUMBER
);

PROCEDURE Distribution_Insert_Row
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
  p_Distribution_Id           IN       NUMBER,
  p_Distribution_Rule_Id      IN       NUMBER,
  p_Worksheet_ID              IN       NUMBER,
  p_Distribution_Date         IN       DATE,
  p_distributed_flag          IN       VARCHAR2,
  p_distribution_instructions IN       VARCHAR2,
  p_distribution_option_flag  IN       VARCHAR2,
  p_revision_option_flag      IN       VARCHAR2,
  p_mode                      IN       VARCHAR2 DEFAULT 'R'
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
  p_Return_Value              OUT  NOCOPY      VARCHAR2
);
--
PROCEDURE Copy_Rule
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Source_Distribution_Rule_Id   IN   NUMBER ,
  p_Source_Budget_Group       In       NUMBER,
  p_Target_Rule_Name          In       VARCHAR2 ,
  p_Target_Rule_ID            OUT  NOCOPY       NUMBER,
  p_mode                      in varchar2 default 'R'
);

--
 PROCEDURE Pass_Rule_ID ( p_rule_id IN NUMBER);

-- functions

  FUNCTION Get_Rule_ID RETURN NUMBER;
     pragma RESTRICT_REFERENCES  ( Get_Rule_ID, WNDS, WNPS );

  FUNCTION get_debug RETURN VARCHAR2;
--

END PSB_WS_Distribution_Rules_PVT ;

 

/
