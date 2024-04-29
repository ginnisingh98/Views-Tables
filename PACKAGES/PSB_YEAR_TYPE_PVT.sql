--------------------------------------------------------
--  DDL for Package PSB_YEAR_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_YEAR_TYPE_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVYTPS.pls 120.2 2005/07/13 11:31:56 shtripat ship $ */



PROCEDURE Check_Unique_Sequence
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_year_type_id        IN      NUMBER,
  p_year_type_seq       IN      NUMBER
) ;
--
--
PROCEDURE Check_Unique_Name
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_year_type_id        IN      NUMBER,
  p_name                IN      VARCHAR2
) ;
--
--
PROCEDURE Check_Sequence
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_year_type           IN      VARCHAR2,
  p_year_type_seq       IN      NUMBER
);
--
--
PROCEDURE Check_CY_Count
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_year_type_id        IN      NUMBER
);
--
--
PROCEDURE Check_Reference
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_year_type_id        IN      NUMBER
);
--
--
FUNCTION get_debug RETURN VARCHAR2;
--
--
procedure INSERT_ROW
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_ROWID in OUT  NOCOPY VARCHAR2,
  p_BUDGET_YEAR_TYPE_ID in NUMBER,
  p_YEAR_CATEGORY_TYPE in VARCHAR2,
  p_SEQUENCE_NUMBER in NUMBER,
  p_NAME in VARCHAR2,
  p_DESCRIPTION in VARCHAR2,
  p_CREATION_DATE in DATE,
  p_CREATED_BY in NUMBER,
  p_LAST_UPDATE_DATE in DATE,
  p_LAST_UPDATED_BY in NUMBER,
  p_LAST_UPDATE_LOGIN in NUMBER);


procedure LOCK_ROW
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_BUDGET_YEAR_TYPE_ID in NUMBER,
  p_YEAR_CATEGORY_TYPE in VARCHAR2,
  p_SEQUENCE_NUMBER in NUMBER,
  p_NAME in VARCHAR2,
  p_DESCRIPTION in VARCHAR2
);


procedure UPDATE_ROW
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_BUDGET_YEAR_TYPE_ID in NUMBER,
  p_YEAR_CATEGORY_TYPE in VARCHAR2,
  p_SEQUENCE_NUMBER in NUMBER,
  p_NAME in VARCHAR2,
  p_DESCRIPTION in VARCHAR2,
  p_LAST_UPDATE_DATE in DATE,
  p_LAST_UPDATED_BY in NUMBER,
  p_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_BUDGET_YEAR_TYPE_ID in NUMBER
);

procedure ADD_LANGUAGE;
--
--
END PSB_Year_Type_PVT ;

 

/
