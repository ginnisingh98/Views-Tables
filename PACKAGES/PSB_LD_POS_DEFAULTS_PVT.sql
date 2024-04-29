--------------------------------------------------------
--  DDL for Package PSB_LD_POS_DEFAULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_LD_POS_DEFAULTS_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVLDRS.pls 120.2 2005/07/13 11:27:04 shtripat ship $ */


-- Global Variables
--g_debug    VARCHAR(2000);
--
PROCEDURE Create_LD_Default_Assignments
( p_api_version          IN   NUMBER,
  p_init_msg_list        IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status        OUT  NOCOPY  VARCHAR2,
  p_msg_count            OUT  NOCOPY  NUMBER,
  p_msg_data             OUT  NOCOPY  VARCHAR2,
  p_worksheet_id         IN   NUMBER := FND_API.G_MISS_NUM,
  p_data_extract_id      IN   NUMBER
);
--
PROCEDURE Assign_LD_Pos_Defaults_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  p_data_extract_id            IN      NUMBER
);
--
FUNCTION get_debug RETURN VARCHAR2;
--
END PSB_LD_POS_DEFAULTS_PVT;

 

/
