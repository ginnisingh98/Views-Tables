--------------------------------------------------------
--  DDL for Package IGC_CC_ACCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_ACCESS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCCACCS.pls 120.3.12000000.1 2007/08/20 12:10:35 mbremkum ship $ */


PROCEDURE Insert_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id                     IN OUT NOCOPY   VARCHAR2,
  p_CC_HEADER_ID                       NUMBER,
  p_USER_ID                            NUMBER,
  p_CC_GROUP_ID                        NUMBER,
  p_CC_ACCESS_ID               IN OUT NOCOPY  NUMBER,
  p_CC_ACCESS_LEVEL                    VARCHAR2,
  p_CC_ACCESS_TYPE                     VARCHAR2,
  p_LAST_UPDATE_DATE                   DATE,
  p_LAST_UPDATED_BY                    NUMBER,
  p_CREATION_DATE                      DATE,
  p_CREATED_BY                         NUMBER,
  p_LAST_UPDATE_LOGIN                  NUMBER
);

PROCEDURE Update_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id                              VARCHAR2,
  p_CC_HEADER_ID                       NUMBER,
  p_USER_ID                            NUMBER,
  p_CC_GROUP_ID                        NUMBER,
  p_CC_ACCESS_ID                       NUMBER,
  p_CC_ACCESS_LEVEL                    VARCHAR2,
  p_CC_ACCESS_TYPE                     VARCHAR2,
  p_LAST_UPDATE_DATE                   DATE,
  p_LAST_UPDATED_BY                    NUMBER,
  p_LAST_UPDATE_LOGIN                  NUMBER
  );


PROCEDURE Lock_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id                              VARCHAR2,
  p_CC_HEADER_ID                       NUMBER,
  p_USER_ID                            NUMBER,
  p_CC_GROUP_ID                        NUMBER,
  p_CC_ACCESS_ID                       NUMBER,
  p_CC_ACCESS_LEVEL                    VARCHAR2,
  p_CC_ACCESS_TYPE                     VARCHAR2,
  p_row_locked                OUT NOCOPY      VARCHAR2

  );


PROCEDURE Delete_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id                    IN       VARCHAR2
);


PROCEDURE Check_Unique
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id                    IN       VARCHAR2,
  p_cc_access_id              IN       NUMBER,
  p_return_value              IN OUT NOCOPY   VARCHAR2
);


Function get_access_level
(
  p_header_id                 IN       NUMBER,
  p_user_id                   IN       NUMBER,
  p_preparer_id               IN       NUMBER,
  p_owner_id                  IN       NUMBER
) RETURN Char;

 pragma RESTRICT_REFERENCES(get_access_level, WNDS, WNPS);

END IGC_CC_ACCESS_PKG;

 

/
