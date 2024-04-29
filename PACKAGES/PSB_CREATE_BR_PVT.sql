--------------------------------------------------------
--  DDL for Package PSB_CREATE_BR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_CREATE_BR_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVCBRS.pls 120.2 2005/07/13 11:23:38 shtripat ship $ */

--
--  Table type to store Budget_Revision_Id
--
TYPE Budget_Revision_Tbl_Type IS TABLE OF NUMBER
     INDEX BY BINARY_INTEGER;

PROCEDURE Enforce_BR_Concurrency
(
  p_api_version               IN      NUMBER   ,
  p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN      VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY     VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY     NUMBER   ,
  p_msg_data                  OUT  NOCOPY     VARCHAR2 ,
  --
  p_budget_revision_id        IN      NUMBER,
  p_parent_or_child_mode      IN      VARCHAR2 ,
  p_maintenance_mode          IN      VARCHAR2 := 'MAINTENANCE'
);


PROCEDURE Check_BR_Ops_Concurrency
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_budget_revision_id        IN       NUMBER,
  p_operation_type            IN       VARCHAR2
);

PROCEDURE Create_Budget_Revision
(
  p_api_version               IN      NUMBER   ,
  p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN      VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY     VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY     NUMBER   ,
  p_msg_data                  OUT  NOCOPY     VARCHAR2 ,
  --
  p_budget_revision_id        IN      NUMBER,
  p_revision_option_flag      IN      VARCHAR2,
  p_budget_group_id           IN      NUMBER,
  p_budget_revision_id_out    OUT  NOCOPY     NUMBER
);

PROCEDURE Freeze_Budget_Revision
(
  p_api_version               IN      NUMBER   ,
  p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN      VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY     VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY     NUMBER   ,
  p_msg_data                  OUT  NOCOPY     VARCHAR2 ,
  --
  p_budget_revision_id        IN      NUMBER,
  p_freeze_flag               IN      VARCHAR2
);

PROCEDURE Find_Parent_Budget_Revision
(
  p_api_version               IN      NUMBER,
  p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY     VARCHAR2,
  p_msg_count                 OUT  NOCOPY     NUMBER,
  p_msg_data                  OUT  NOCOPY     VARCHAR2,
  --
  p_budget_revision_id        IN      NUMBER,
  p_budget_revision_id_OUT    OUT  NOCOPY     NUMBER
);

PROCEDURE Find_Parent_Budget_Revisions
(
  p_api_version               IN      NUMBER,
  p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY     VARCHAR2,
  p_msg_count                 OUT  NOCOPY     NUMBER,
  p_msg_data                  OUT  NOCOPY     VARCHAR2,
  --
  p_budget_revision_id        IN      NUMBER,
  p_budget_revision_tbl       IN OUT  NOCOPY  Budget_Revision_Tbl_Type
);


PROCEDURE Find_Child_Budget_Revisions
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_budget_revision_id        IN       NUMBER,
  p_budget_revision_tbl       IN OUT  NOCOPY   Budget_Revision_Tbl_Type
);

PROCEDURE Update_Target_Budget_Revision
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_source_budget_revision_id IN       NUMBER,
  p_revision_option_flag      IN      VARCHAR2,
  p_target_budget_revision_id IN       NUMBER
);

END PSB_Create_BR_Pvt ;

 

/
