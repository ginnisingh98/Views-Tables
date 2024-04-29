--------------------------------------------------------
--  DDL for Package PSB_GL_BUDGET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_GL_BUDGET_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVGBDS.pls 120.2 2005/07/13 11:26:34 shtripat ship $ */

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
  p_gl_budget_id              IN OUT  NOCOPY   NUMBER,
  p_gl_budget_set_id          IN       NUMBER,
  p_gl_budget_version_id      IN       NUMBER,
  p_start_period              IN       VARCHAR2,
  p_end_period                IN       VARCHAR2,
  p_start_date                IN       DATE,
  p_end_date                  IN       DATE,
  p_dual_posting_type         IN       VARCHAR2,
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
  p_gl_budget_id              IN       NUMBER,
  p_gl_budget_set_id          IN       NUMBER,
  p_gl_budget_version_id      IN       NUMBER,
  p_start_period              IN       VARCHAR2,
  p_end_period                IN       VARCHAR2,
  p_start_date                IN       DATE,
  p_end_date                  IN       DATE,
  p_dual_posting_type         IN       VARCHAR2,
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
  p_gl_budget_set_id          IN       NUMBER,
  p_gl_budget_version_id      IN       NUMBER,
  p_start_period              IN       VARCHAR2,
  p_end_period                IN       VARCHAR2,
  p_start_date                IN       DATE,
  p_end_date                  IN       DATE,
  p_dual_posting_type         IN       VARCHAR2,
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


PROCEDURE Find_GL_Budget
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_gl_budget_set_id          IN       NUMBER,
  p_code_combination_id       IN       NUMBER,
  p_start_date                IN       DATE,
  p_dual_posting_type         IN       VARCHAR2 := FND_API.G_MISS_CHAR,
  --
  p_gl_budget_version_id      OUT  NOCOPY      NUMBER
);

END PSB_GL_Budget_Pvt ;

 

/
