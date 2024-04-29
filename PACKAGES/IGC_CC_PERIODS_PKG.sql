--------------------------------------------------------
--  DDL for Package IGC_CC_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_PERIODS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCCCCPS.pls 120.3.12000000.1 2007/08/20 12:11:32 mbremkum ship $ */

PROCEDURE Insert_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT NOCOPY      VARCHAR2,
  p_msg_count                 OUT NOCOPY      NUMBER,
  p_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id	              IN OUT NOCOPY   VARCHAR2,
  p_org_id			       NUMBER,
  p_period_set_name		       VARCHAR2,
  p_period_name			       VARCHAR2,
  p_cc_period_status		       VARCHAR2,
  p_last_update_date                   DATE,
  p_last_updated_by                    NUMBER,
  p_last_update_login                  NUMBER,
  p_created_by                         NUMBER,
  p_creation_date                      DATE
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

  p_row_id	              IN OUT NOCOPY   VARCHAR2,
  p_org_id			       NUMBER,
  p_period_set_name		       VARCHAR2,
  p_period_name			       VARCHAR2,
  p_cc_period_status		       VARCHAR2,

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

  p_row_id	              IN OUT NOCOPY   VARCHAR2,
  p_org_id			       NUMBER,
  p_period_set_name		       VARCHAR2,
  p_period_name			       VARCHAR2,
  p_cc_period_status		       VARCHAR2,
  p_last_update_date                   DATE,
  p_last_updated_by                    NUMBER,
  p_last_update_login                  NUMBER
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

  p_row_id	              IN       VARCHAR2
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

  p_row_id	              IN OUT NOCOPY   VARCHAR2,
  p_org_id			       NUMBER,
  p_period_set_name		       VARCHAR2,
  p_period_name			       VARCHAR2,

  p_return_value              IN OUT NOCOPY   VARCHAR2
);

END IGC_CC_PERIODS_PKG;

 

/
