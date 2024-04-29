--------------------------------------------------------
--  DDL for Package PSB_ACCOUNT_POSITION_SET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_ACCOUNT_POSITION_SET_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVSETS.pls 120.2 2005/07/13 11:29:37 shtripat ship $ */

--
--  Table type to store entity types.
--
TYPE Entity_Tbl_Type IS TABLE OF VARCHAR2(10)
     INDEX BY BINARY_INTEGER;


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
  p_row_id                    IN OUT  NOCOPY   VARCHAR2,
  p_account_position_set_id   IN OUT  NOCOPY   NUMBER,
  p_name                      IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  p_use_in_budget_group_flag  IN       VARCHAR2 := FND_API.G_MISS_CHAR,
  p_data_extract_id           IN       NUMBER,
  p_budget_group_id           IN       NUMBER := FND_API.G_MISS_NUM,
  p_global_or_local_type      IN       VARCHAR2,
  p_account_or_position_type  IN       VARCHAR2,
  p_attribute_selection_type  IN       VARCHAR2,
  p_business_group_id         IN       NUMBER,
  p_last_update_date          IN       DATE,
  p_last_updated_by           IN       NUMBER,
  p_last_update_login         IN       NUMBER,
  p_created_by                IN       NUMBER,
  p_creation_date             IN       DATE
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
  p_row_id                    IN       VARCHAR2,
  p_account_position_set_id   IN       NUMBER,
  p_name                      IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  p_use_in_budget_group_flag  IN       VARCHAR2 := FND_API.G_MISS_CHAR,
  p_data_extract_id           IN       NUMBER,
  p_budget_group_id           IN       NUMBER := FND_API.G_MISS_NUM,
  p_global_or_local_type      IN       VARCHAR2,
  p_account_or_position_type  IN       VARCHAR2,
  p_attribute_selection_type  IN       VARCHAR2,
  p_business_group_id         IN       NUMBER,
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
  p_row_id                    IN       VARCHAR2,
  p_account_position_set_id   IN       NUMBER,
  p_name                      IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  p_use_in_budget_group_flag  IN       VARCHAR2 := FND_API.G_MISS_CHAR,
  p_data_extract_id           IN       NUMBER,
  p_budget_group_id           IN       NUMBER := FND_API.G_MISS_NUM,
  p_global_or_local_type      IN       VARCHAR2,
  p_account_or_position_type  IN       VARCHAR2,
  p_attribute_selection_type  IN       VARCHAR2,
  p_business_group_id         IN       NUMBER,
  p_last_update_date          IN       DATE,
  p_last_updated_by           IN       NUMBER,
  p_last_update_login         IN       NUMBER
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
  p_row_id                    IN       VARCHAR2
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
  p_row_id                    IN       VARCHAR2,
  p_name                      IN       VARCHAR2,
  p_account_or_position_type  IN       VARCHAR2,
  p_data_extract_id           IN       NUMBER,
  p_return_value              IN OUT  NOCOPY   VARCHAR2
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
  p_account_position_set_id   IN       NUMBER,
  p_return_value              IN OUT  NOCOPY   VARCHAR2,
  p_frozen_bg_reference       IN OUT  NOCOPY   VARCHAR2

);


PROCEDURE Copy_Position_Sets
(
  p_api_version             IN   NUMBER,
  p_init_msg_list           IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level        IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status           OUT  NOCOPY  VARCHAR2,
  p_msg_count               OUT  NOCOPY  NUMBER,
  p_msg_data                OUT  NOCOPY  VARCHAR2,
  --
  p_source_data_extract_id  IN   NUMBER,
  p_target_data_extract_id  IN   NUMBER,
  p_entity_table            IN   PSB_Account_Position_Set_PVT.Entity_Tbl_Type
);


PROCEDURE Copy_Position_Set
(
  p_api_version               IN   NUMBER,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_msg_count                 OUT  NOCOPY  NUMBER,
  p_msg_data                  OUT  NOCOPY  VARCHAR2,
  --
  p_source_position_set_id    IN   NUMBER ,
  p_source_data_extract_id    IN   NUMBER ,
  p_target_data_extract_id    IN   NUMBER ,
  p_target_business_group_id  IN   NUMBER ,
  p_new_position_set_id       OUT  NOCOPY  NUMBER
);


END PSB_Account_Position_Set_PVT;

 

/
