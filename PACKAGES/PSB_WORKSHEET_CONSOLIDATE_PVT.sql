--------------------------------------------------------
--  DDL for Package PSB_WORKSHEET_CONSOLIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WORKSHEET_CONSOLIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBPWCDS.pls 120.2 2005/07/13 11:23:03 shtripat ship $ */

/* ----------------------------------------------------------------------- */

  --    API name        : Consolidate_Worksheets
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WORKSHEET_CONSOLIDATE
  --    Parameters      :
  --    IN              : p_api_version          IN NUMBER    Required
  --                      p_init_msg_list        IN VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit               IN VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level     IN NUMBER    Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_global_worksheet_id  IN NUMBER    Required
  --                    .
  --    OUT NOCOPY      : p_return_status        OUT NOCOPY          VARCHAR2(1)
  --                    p_msg_count              OUT NOCOPY          NUMBER
  --                    p_msg_data               OUT NOCOPY          VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 06/06/1999 by Supriyo Ghosh
  --
  --    Notes           : Consolidate Global Worksheet
  --

PROCEDURE Consolidate_Worksheets
( p_api_version          IN   NUMBER,
  p_init_msg_list        IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status        OUT NOCOPY  VARCHAR2,
  p_msg_count            OUT NOCOPY  NUMBER,
  p_msg_data             OUT NOCOPY  VARCHAR2,
  p_global_worksheet_id  IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Validate_Consolidation
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WORKSHEET_CONSOLIDATE
  --    Parameters      :
  --    IN              : p_api_version          IN NUMBER    Required
  --                      p_init_msg_list        IN VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level     IN NUMBER    Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_global_worksheet_id  IN NUMBER    Required
  --                    .
  --    OUT NOCOPY      : p_return_status        OUT NOCOPY          VARCHAR2(1)
  --                    p_msg_count              OUT NOCOPY          NUMBER
  --                    p_msg_data               OUT NOCOPY          VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 06/06/1999 by Supriyo Ghosh
  --
  --    Notes           : Validate the Global Worksheet Consolidation
  --

PROCEDURE Validate_Consolidation
( p_api_version          IN   NUMBER,
  p_init_msg_list        IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status        OUT NOCOPY  VARCHAR2,
  p_msg_count            OUT NOCOPY  NUMBER,
  p_msg_data             OUT NOCOPY  VARCHAR2,
  p_global_worksheet_id  IN   NUMBER
);


/* ----------------------------------------------------------------------- */
  --   fmiao added Insert_Row, Update_Row, Lock_Row, Delete_Row, Check_Unique 07-JUN-99
  --   fmiao added Worksheet_consolidate_CP

PROCEDURE Insert_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT NOCOPY      VARCHAR2,
  p_msg_count                 OUT NOCOPY      NUMBER,
  p_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id                    IN OUT NOCOPY   VARCHAR2,
  p_global_worksheet_id       IN       NUMBER,
  p_local_worksheet_id        IN       NUMBER,
  p_last_update_date          IN       DATE,
  p_last_updated_by           IN       NUMBER,
  p_last_update_login         IN       NUMBER,
  p_created_by                IN       NUMBER,
  p_creation_date             IN       DATE,
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
  p_context                   IN       VARCHAR2
);


PROCEDURE Lock_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT NOCOPY      VARCHAR2,
  p_msg_count                 OUT NOCOPY      NUMBER,
  p_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id                    IN       VARCHAR2,
  p_global_worksheet_id       IN       NUMBER,
  p_local_worksheet_id        IN       NUMBER,
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
  p_context                   IN       VARCHAR2,

  p_row_locked                OUT NOCOPY      VARCHAR2
);


PROCEDURE Update_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT NOCOPY      VARCHAR2,
  p_msg_count                 OUT NOCOPY      NUMBER,
  p_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id                    IN       VARCHAR2,
  p_global_worksheet_id       IN       NUMBER,
  p_local_worksheet_id        IN       NUMBER,
  p_last_update_date          IN       DATE,
  p_last_updated_by           IN       NUMBER,
  p_last_update_login         IN       NUMBER,
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
  p_context                   IN       VARCHAR2
);


PROCEDURE Delete_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT NOCOPY      VARCHAR2,
  p_msg_count                 OUT NOCOPY      NUMBER,
  p_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id                    IN       VARCHAR2
);


PROCEDURE Check_Unique
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT NOCOPY      VARCHAR2,
  p_msg_count                 OUT NOCOPY      NUMBER,
  p_msg_data                  OUT NOCOPY      VARCHAR2,
  --
  p_row_id                    IN       VARCHAR2,
  p_global_worksheet_id       IN       NUMBER,
  p_local_worksheet_id        IN       NUMBER,
  p_return_value              IN OUT NOCOPY   VARCHAR2
);


PROCEDURE Worksheet_Consolidate_CP
(
  errbuf                      OUT NOCOPY      VARCHAR2,
  retcode                     OUT NOCOPY      VARCHAR2,
  --
  p_worksheet_id              IN       NUMBER
);

/* ----------------------------------------------------------------------- */

END PSB_WORKSHEET_CONSOLIDATE_PVT;

 

/
