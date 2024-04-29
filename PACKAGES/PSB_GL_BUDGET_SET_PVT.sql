--------------------------------------------------------
--  DDL for Package PSB_GL_BUDGET_SET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_GL_BUDGET_SET_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVGBSS.pls 115.8 2002/11/29 10:16:37 vbellur ship $ */

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
  p_gl_budget_set_id          IN OUT  NOCOPY   NUMBER,
  p_gl_budget_set_name        IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  p_last_update_date          IN       DATE,
  p_last_updated_by           IN       NUMBER,
  p_last_update_login         IN       NUMBER,
  p_created_by                IN       NUMBER,
  p_creation_date             IN       DATE  ,
  p_context                   IN       VARCHAR2,
  p_attribute1                IN       VARCHAR2,
  p_attribute2                IN       VARCHAR2,
  p_attribute3                IN       VARCHAR2,
  p_attribute4                IN       VARCHAR2,
  p_attribute5                IN       VARCHAR2,
  p_attribute6                IN       VARCHAR2,
  p_attribute7                IN       VARCHAR2,
  p_attribute8                IN       VARCHAR2,
  p_attribute9                IN       VARCHAR2,
  p_attribute10               IN       VARCHAR2
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
  p_gl_budget_set_id          IN       NUMBER,
  p_gl_budget_set_name        IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  p_context                   IN       VARCHAR2,
  p_attribute1                IN       VARCHAR2,
  p_attribute2                IN       VARCHAR2,
  p_attribute3                IN       VARCHAR2,
  p_attribute4                IN       VARCHAR2,
  p_attribute5                IN       VARCHAR2,
  p_attribute6                IN       VARCHAR2,
  p_attribute7                IN       VARCHAR2,
  p_attribute8                IN       VARCHAR2,
  p_attribute9                IN       VARCHAR2,
  p_attribute10               IN       VARCHAR2,
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
  p_gl_budget_set_name        IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  p_last_update_date          IN       DATE,
  p_last_updated_by           IN       NUMBER,
  p_last_update_login         IN       NUMBER,
  p_context                   IN       VARCHAR2,
  p_attribute1                IN       VARCHAR2,
  p_attribute2                IN       VARCHAR2,
  p_attribute3                IN       VARCHAR2,
  p_attribute4                IN       VARCHAR2,
  p_attribute5                IN       VARCHAR2,
  p_attribute6                IN       VARCHAR2,
  p_attribute7                IN       VARCHAR2,
  p_attribute8                IN       VARCHAR2,
  p_attribute9                IN       VARCHAR2,
  p_attribute10               IN       VARCHAR2
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
  p_gl_budget_set_name        IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  p_return_value              IN OUT  NOCOPY   VARCHAR2
);


PROCEDURE Validate_Account_Overlap
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
  p_validation_status         IN OUT  NOCOPY   VARCHAR2
);


PROCEDURE Validate_Account_Overlap_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_gl_budget_set_id          IN       NUMBER
);

/* Bug No. 2564791 start */
PROCEDURE Check_References
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2,
  p_commit                    IN       VARCHAR2,
  p_validation_level          IN       NUMBER,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_gl_budget_set_id	      IN  	NUMBER
);
/* Bug No. 2564791 End */

END PSB_GL_Budget_Set_Pvt ;

 

/
