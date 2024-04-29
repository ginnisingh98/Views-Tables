--------------------------------------------------------
--  DDL for Package PSB_BUDGET_REVISION_POS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_BUDGET_REVISION_POS_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBBPOSS.pls 120.2 2005/07/13 11:22:30 shtripat ship $ */

PROCEDURE Insert_Row
(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status              OUT NOCOPY      VARCHAR2,
  p_msg_count                  OUT NOCOPY      NUMBER,
  p_msg_data                   OUT NOCOPY      VARCHAR2,
  --
  p_budget_revision_id              IN      NUMBER   := FND_API.G_MISS_NUM,
  p_budget_revision_pos_line_id     IN OUT NOCOPY  NUMBER,
  p_position_id                     IN      NUMBER,
  p_budget_group_id                 IN      NUMBER,
  p_effective_start_date            IN      DATE,
  p_effective_end_date              IN      DATE,
  p_revision_type                   IN      VARCHAR2,
  p_revision_value_type             IN      VARCHAR2,
  p_revision_value                  IN      NUMBER,
  p_note_id                         IN      NUMBER,
  p_freeze_flag                     IN      VARCHAR2,
  p_view_line_flag                  IN      VARCHAR2,
  p_last_update_date                IN      DATE,
  p_last_updated_by                 IN      NUMBER,
  p_last_update_login               IN      NUMBER,
  p_created_by                      IN      NUMBER,
  p_creation_date                   IN      DATE
);


PROCEDURE Update_Row
(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status              OUT NOCOPY      VARCHAR2,
  p_msg_count                  OUT NOCOPY      NUMBER,
  p_msg_data                   OUT NOCOPY      VARCHAR2,
  --
  p_budget_revision_id              IN      NUMBER   := FND_API.G_MISS_NUM,
  p_budget_revision_pos_line_id     IN OUT NOCOPY  NUMBER,
  p_position_id                     IN      NUMBER,
  p_budget_group_id                 IN      NUMBER,
  p_effective_start_date            IN      DATE,
  p_effective_end_date              IN      DATE,
  p_revision_type                   IN      VARCHAR2,
  p_revision_value_type             IN      VARCHAR2,
  p_revision_value                  IN      NUMBER,
  p_note_id                         IN      NUMBER,
  p_freeze_flag                     IN      VARCHAR2,
  p_view_line_flag                  IN      VARCHAR2,
  p_last_update_date                IN      DATE,
  p_last_updated_by                 IN      NUMBER,
  p_last_update_login               IN      NUMBER,
  p_created_by                      IN      NUMBER,
  p_creation_date                   IN      DATE
);

END PSB_BUDGET_REVISION_POS_PVT;

 

/
