--------------------------------------------------------
--  DDL for Package PSB_ALLOCRULE_PERCENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_ALLOCRULE_PERCENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVARPS.pls 120.3 2005/07/13 11:23:22 shtripat ship $ */


PROCEDURE Insert_Row
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  P_ALLOCATION_RULE_PERCENT_ID  IN OUT  NOCOPY NUMBER,
  P_ALLOCATION_RULE_ID   IN     NUMBER,
  P_PERIOD_NUM           IN     NUMBER,
  P_MONTHLY              IN     NUMBER,
  P_QUARTERLY            IN     NUMBER,
  P_SEMI_ANNUAL          IN     NUMBER,
  P_ATTRIBUTE1           IN     VARCHAR2,
  P_ATTRIBUTE2           IN     VARCHAR2,
  P_ATTRIBUTE3           IN     VARCHAR2,
  P_ATTRIBUTE4           IN     VARCHAR2,
  P_ATTRIBUTE5           IN     VARCHAR2,
  P_CONTEXT              IN     VARCHAR2,
  P_LAST_UPDATE_DATE     IN     DATE,
  P_LAST_UPDATED_BY      IN     NUMBER,
  P_LAST_UPDATE_LOGIN    IN     NUMBER,
  P_CREATED_BY           IN     NUMBER,
  P_CREATION_DATE        IN     DATE
);

PROCEDURE Update_Row
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  P_ALLOCATION_RULE_ID   IN     NUMBER,
  P_PERIOD_NUM           IN     NUMBER,
  P_MONTHLY              IN     NUMBER,
  P_QUARTERLY            IN     NUMBER,
  P_SEMI_ANNUAL          IN     NUMBER,
  P_ATTRIBUTE1           IN     VARCHAR2,
  P_ATTRIBUTE2           IN     VARCHAR2,
  P_ATTRIBUTE3           IN     VARCHAR2,
  P_ATTRIBUTE4           IN     VARCHAR2,
  P_ATTRIBUTE5           IN     VARCHAR2,
  P_CONTEXT              IN     VARCHAR2,
  P_LAST_UPDATE_DATE     IN     DATE,
  P_LAST_UPDATED_BY      IN     NUMBER,
  P_LAST_UPDATE_LOGIN    IN     NUMBER
);


PROCEDURE Delete_Row
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  P_ALLOCATION_RULE_ID   IN     NUMBER,
  P_PERIOD_NUM           IN     NUMBER
);

PROCEDURE Lock_Row
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_lock_row            OUT  NOCOPY     VARCHAR2,
  P_ALLOCATION_RULE_ID   IN     NUMBER,
  P_PERIOD_NUM           IN     NUMBER,
  P_MONTHLY              IN     NUMBER,
  P_QUARTERLY            IN     NUMBER,
  P_SEMI_ANNUAL          IN     NUMBER
);

FUNCTION get_debug RETURN VARCHAR2;

END PSB_ALLOCRULE_PERCENTS_PVT;

 

/
