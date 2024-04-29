--------------------------------------------------------
--  DDL for Package PSB_FLEX_MAPPING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_FLEX_MAPPING_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVFLXS.pls 120.2 2005/07/13 11:26:07 shtripat ship $ */

--
-- Global Variables for Views
--
g_Application_Column_Name  VARCHAR2(30) ;
g_Flex_Set_ID              NUMBER;

g_seg_name                 FND_FLEX_EXT.SEGMENTARRAY;
g_flex_code                NUMBER;
g_num_segs                 NUMBER;

TYPE SegNumArray IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_seg_num                  segnumarray;

--
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
  p_Flex_Mapping_Set_ID       IN       NUMBER,
  p_Flex_Mapping_Value_ID     IN       NUMBER,
  p_Budget_Year_Type_ID       IN       NUMBER,
  p_Application_Column_Name   IN       VARCHAR2,
  p_Flex_Value_Set_ID         IN       NUMBER,
  p_Flex_Value_ID             IN       NUMBER,
  p_From_Flex_Value_ID        IN       NUMBER,
  p_mode                      IN varchar2 default 'R'
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
  p_Flex_Mapping_Set_ID       IN       NUMBER,
  p_Flex_Mapping_Value_ID     IN       NUMBER,
  p_Budget_Year_Type_ID       IN       NUMBER,
  p_Application_Column_Name   IN       VARCHAR2,
  p_Flex_Value_Set_ID         IN      NUMBER,
  p_Flex_Value_ID             IN       NUMBER,
  p_From_Flex_Value_ID        IN       NUMBER,
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
  p_Flex_Mapping_Set_ID       IN       NUMBER,
  p_Flex_Mapping_Value_ID     IN       NUMBER,
  p_Budget_Year_Type_ID       IN       NUMBER,
  p_Application_Column_Name   IN       VARCHAR2,
  p_Flex_Value_Set_ID         IN       NUMBER,
  p_Flex_Value_ID             IN       NUMBER,
  p_From_Flex_Value_ID        IN       NUMBER,
  p_mode                      IN       VARCHAR2 default 'R'
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
  p_Flex_Mapping_Value_ID     IN       NUMBER
);

---
--- table handler for psb_flex_mapping_sets
---

PROCEDURE Sets_Insert_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Flex_Mapping_Set_ID       IN       NUMBER,
  p_Name                      IN       VARCHAR2,
  p_Description               IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  p_mode                      in varchar2 default 'R'
);


PROCEDURE Sets_Update_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Flex_Mapping_Set_ID       IN       NUMBER,
  p_Name                      IN       VARCHAR2,
  p_Description               IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  p_mode                      in varchar2 default 'R'
);

PROCEDURE Sets_Lock_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Flex_Mapping_Set_ID       IN       NUMBER,
  p_Name                      IN       VARCHAR2,
  p_Description               IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  --
  p_row_locked                OUT  NOCOPY      VARCHAR2
);
PROCEDURE Sets_Delete_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Flex_Mapping_Set_ID      IN       NUMBER
);

--
PROCEDURE Flex_Info
( p_return_status  OUT  NOCOPY  VARCHAR2,
  p_flex_code      IN   NUMBER
);
--
FUNCTION Get_Mapped_CCID
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  --
  p_CCID                      IN       NUMBER,
  p_Budget_Year_Type_ID       IN       NUMBER,
  p_Flexfield_Mapping_Set_ID  IN       NUMBER,
  p_Mapping_Mode              IN       VARCHAR2     := 'WORKSHEET'

) RETURN NUMBER;

FUNCTION Get_Mapped_Account
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  --
  p_CCID                      IN       NUMBER,
  p_Budget_Year_Type_ID       IN       NUMBER,
  p_Flexfield_Mapping_Set_ID  IN       NUMBER

) RETURN VARCHAR2;

PROCEDURE Pass_View_Parameters  ( p_flex_set_id IN NUMBER,
				  p_application_column_name IN VARCHAR2);
FUNCTION Get_Application_Column_Name RETURN varchar2;
     pragma RESTRICT_REFERENCES  ( Get_Application_Column_Name, WNDS, WNPS );

FUNCTION Get_Flex_Set_ID RETURN NUMBER;
     pragma RESTRICT_REFERENCES  ( Get_Flex_Set_ID, WNDS, WNPS );

END PSB_Flex_Mapping_PVT ;

 

/
