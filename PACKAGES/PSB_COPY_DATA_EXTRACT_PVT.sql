--------------------------------------------------------
--  DDL for Package PSB_COPY_DATA_EXTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_COPY_DATA_EXTRACT_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVCDES.pls 120.2 2005/07/13 11:23:55 shtripat ship $ */


PROCEDURE Copy_Attributes
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_extract_method      IN      VARCHAR2,
  p_src_data_extract_id IN      NUMBER,
  p_data_extract_id     IN      NUMBER
);

PROCEDURE Copy_Elements
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_extract_method      IN      VARCHAR2,
  p_src_data_extract_id IN      NUMBER,
  p_copy_salary_flag    IN      VARCHAR2,
  p_data_extract_id     IN      NUMBER
);

PROCEDURE Copy_Position_Sets
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_extract_method      IN      VARCHAR2,
  p_src_data_extract_id IN      NUMBER,
  p_data_extract_id     IN      NUMBER
);

PROCEDURE Copy_Default_Rules
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_extract_method      IN      VARCHAR2,
  p_src_data_extract_id IN      NUMBER,
  p_data_extract_id     IN      NUMBER
);

FUNCTION get_debug RETURN VARCHAR2;

END PSB_COPY_DATA_EXTRACT_PVT;

 

/
