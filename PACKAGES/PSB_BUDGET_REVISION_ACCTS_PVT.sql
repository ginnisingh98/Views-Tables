--------------------------------------------------------
--  DDL for Package PSB_BUDGET_REVISION_ACCTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_BUDGET_REVISION_ACCTS_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBBACCS.pls 120.2 2005/07/13 11:22:19 shtripat ship $ */

PROCEDURE Insert_Row
(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status              OUT  NOCOPY      VARCHAR2,
  p_msg_count                  OUT  NOCOPY      NUMBER,
  p_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_budget_revision_id              IN      NUMBER   := FND_API.G_MISS_NUM,
  p_budget_revision_acct_line_id IN OUT  NOCOPY  NUMBER,
  p_code_combination_id             IN      NUMBER,
  p_budget_group_id                 IN      NUMBER,
  p_gl_period_name                  IN      VARCHAR2,
  p_gl_budget_version_id            IN      NUMBER := FND_API.G_MISS_NUM,
  p_currency_code                   IN      VARCHAR2,
  p_budget_balance                  IN      NUMBER,
  p_revision_type                   IN      VARCHAR2,
  p_revision_value_type             IN      VARCHAR2,
  p_revision_amount                 IN      NUMBER,
  p_funds_status_code               IN      VARCHAR2,
  p_funds_result_code               IN      VARCHAR2,
  p_funds_control_timestamp         IN      DATE,
  p_note_id                         IN      NUMBER,
  p_freeze_flag                     IN      VARCHAR2,
  p_view_line_flag                  IN      VARCHAR2
);


PROCEDURE Update_Row
(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status              OUT  NOCOPY      VARCHAR2,
  p_msg_count                  OUT  NOCOPY      NUMBER,
  p_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_budget_revision_id              IN      NUMBER   := FND_API.G_MISS_NUM,
  p_budget_revision_acct_line_id IN OUT  NOCOPY  NUMBER,
  p_code_combination_id             IN      NUMBER,
  p_budget_group_id                 IN      NUMBER,
  p_gl_period_name                  IN      VARCHAR2,
  p_gl_budget_version_id            IN      NUMBER := FND_API.G_MISS_NUM,
  p_currency_code                   IN      VARCHAR2,
  p_budget_balance                  IN      NUMBER,
  p_revision_type                   IN      VARCHAR2,
  p_revision_value_type             IN      VARCHAR2,
  p_revision_amount                 IN      NUMBER,
  p_funds_status_code               IN      VARCHAR2,
  p_funds_result_code               IN      VARCHAR2,
  p_funds_control_timestamp         IN      DATE,
  p_note_id                         IN      NUMBER,
  p_freeze_flag                     IN      VARCHAR2,
  p_view_line_flag                  IN      VARCHAR2
);
END PSB_BUDGET_REVISION_ACCTS_PVT;

 

/
