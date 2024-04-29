--------------------------------------------------------
--  DDL for Package PSB_PAY_ELEMENT_OPTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_PAY_ELEMENT_OPTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVOPTS.pls 120.2 2005/07/13 11:27:33 shtripat ship $ */


PROCEDURE INSERT_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_PAY_ELEMENT_OPTION_ID            in      NUMBER,
  P_PAY_ELEMENT_ID                   in      NUMBER,
  P_NAME                             in      VARCHAR2,
  P_GRADE_STEP                       in      NUMBER,
  P_SEQUENCE_NUMBER                  IN      NUMBER,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER,
  P_CREATED_BY                       in      NUMBER,
  P_CREATION_DATE                    in      DATE
);

PROCEDURE UPDATE_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_PAY_ELEMENT_OPTION_ID            in      NUMBER,
  P_PAY_ELEMENT_ID                   in      NUMBER,
  P_NAME                             in      VARCHAR2,
  P_GRADE_STEP                       in      NUMBER,
  P_SEQUENCE_NUMBER                  IN      NUMBER,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER
);

PROCEDURE DELETE_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_PAY_ELEMENT_OPTION_ID            in      NUMBER,
  P_PAY_ELEMENT_ID                   in      NUMBER
);

PROCEDURE LOCK_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  p_row_locked                       OUT  NOCOPY     VARCHAR2,
  --
  P_PAY_ELEMENT_OPTION_ID            in      NUMBER,
  P_PAY_ELEMENT_ID                   in      NUMBER,
  P_NAME                             in      VARCHAR2,
  P_GRADE_STEP                       in      NUMBER,
  P_SEQUENCE_NUMBER                  IN      NUMBER
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
  P_PAY_ELEMENT_OPTION_ID     in       NUMBER,
  P_PAY_ELEMENT_ID            in       NUMBER,
  P_Name                      IN       VARCHAR2,
  P_GRADE_STEP                IN       NUMBER,
  P_Return_Value              IN OUT  NOCOPY   VARCHAR2
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
  P_PAY_ELEMENT_OPTION_ID     in       NUMBER,
  P_PAY_ELEMENT_ID            in       NUMBER,
  P_Return_Value              IN OUT  NOCOPY   VARCHAR2
);


END PSB_PAY_ELEMENT_OPTIONS_PVT;

 

/
