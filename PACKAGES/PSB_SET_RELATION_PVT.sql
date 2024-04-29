--------------------------------------------------------
--  DDL for Package PSB_SET_RELATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_SET_RELATION_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVSTRS.pls 120.2 2005/07/13 11:30:07 shtripat ship $ */

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
  p_set_relation_id           IN OUT  NOCOPY   NUMBER,
  p_account_Position_set_id   IN       NUMBER,
  p_allocation_Rule_id        IN       NUMBER,
  p_budget_group_id           IN       NUMBER,
  p_budget_workflow_rule_id   IN       NUMBER,
  p_constraint_id             IN       NUMBER,
  p_default_Rule_id           IN       NUMBER,
  p_parameter_id              IN       NUMBER,
  p_position_set_group_id     IN       NUMBER,
  p_gl_budget_id              IN       NUMBER := FND_API.G_MISS_NUM,
/* Budget Revision Rules Enhancement Start */
  p_rule_id                   IN       VARCHAR2,
  p_apply_balance_flag        IN       VARCHAR2,
/* Budget Revision Rules Enhancement End */
  p_effective_start_date      IN       DATE,
  p_effective_end_date        IN       DATE,
  p_last_update_date          IN       DATE,
  p_last_updated_By           IN       NUMBER,
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
  p_set_Relation_id           IN       NUMBER,
  p_account_Position_set_id   IN       NUMBER,
  p_allocation_Rule_id        IN       NUMBER,
  p_budget_group_id           IN       NUMBER,
  p_budget_workflow_rule_id   IN       NUMBER,
  p_Constraint_id             IN       NUMBER,
  p_default_Rule_id           IN       NUMBER,
  p_parameter_id              IN       NUMBER,
  p_position_set_group_id     IN       NUMBER,
  p_gl_budget_id              IN       NUMBER := FND_API.G_MISS_NUM,
/* Budget Revision Rules Enhancement Start */
  p_rule_id                   IN       VARCHAR2,
  p_apply_balance_flag        IN       VARCHAR2,
/* Budget Revision Rules Enhancement End */
  p_effective_start_date      IN       DATE,
  p_effective_end_date        IN       DATE,
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
  p_set_Relation_id           IN       NUMBER,
  p_account_Position_set_id   IN       NUMBER,
  p_allocation_Rule_id        IN       NUMBER,
  p_budget_group_id           IN       NUMBER,
  p_budget_workflow_rule_id   IN       NUMBER,
  p_Constraint_id             IN       NUMBER,
  p_default_Rule_id           IN       NUMBER,
  p_parameter_id              IN       NUMBER,
  p_position_set_group_id     IN       NUMBER,
  p_gl_budget_id              IN       NUMBER := FND_API.G_MISS_NUM,
/* Budget Revision Rules Enhancement Start */
  p_rule_id                   IN       VARCHAR2,
  p_apply_balance_flag        IN       VARCHAR2,
/* Budget Revision Rules Enhancement End */
  p_effective_start_date      IN       DATE,
  p_effective_end_date        IN       DATE,
  p_last_update_date          IN       DATE,
  p_last_updated_By           IN       NUMBER,
  p_last_update_login         IN       NUMBER
);



PROCEDURE Delete_Row
( p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_row_id                    IN       VARCHAR2
);


PROCEDURE Delete_Entity_Relation
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_entity_type               IN       VARCHAR2,
  p_entity_id                 IN       NUMBER
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
  p_account_position_set_id   IN       NUMBER,
  p_account_or_position_type  IN       VARCHAR2,
  p_entity_type               IN       VARCHAR2,
  p_entity_id                 IN       NUMBER,
/* Bug No 2131841 Start */
  p_apply_balance_flag        IN       VARCHAR2,
/* Bug No 2131841 End */
  p_return_value              IN OUT  NOCOPY   VARCHAR2
);


END PSB_Set_Relation_PVT;

 

/
