--------------------------------------------------------
--  DDL for Package PSB_PURGE_DATA_EXTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_PURGE_DATA_EXTRACT_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBPHRXS.pls 120.2 2005/07/13 11:22:46 shtripat ship $ */

PROCEDURE Purge_Data_Extract
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_data_extract_id     IN      NUMBER,
  p_purge               OUT  NOCOPY     VARCHAR2
);

PROCEDURE Purge_Data_Extract_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_data_extract_id            IN      NUMBER
);

FUNCTION get_debug RETURN VARCHAR2;

END PSB_PURGE_DATA_EXTRACT_PVT;

 

/
