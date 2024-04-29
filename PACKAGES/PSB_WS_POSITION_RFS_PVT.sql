--------------------------------------------------------
--  DDL for Package PSB_WS_POSITION_RFS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_POSITION_RFS_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBWPRSS.pls 120.2.12010000.3 2009/04/27 14:32:59 rkotha ship $ */


PROCEDURE Redistribute_Follow_Salary
(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status              OUT  NOCOPY      VARCHAR2,
  p_msg_count                  OUT  NOCOPY      NUMBER,
  p_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_worksheet_id                IN      NUMBER,
  p_position_line_id            IN      NUMBER,
  p_service_package_id          IN      NUMBER,
  p_stage_set_id                IN      NUMBER
);


PROCEDURE Delete_Pos_Service_Package
(
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_worksheet_id              IN       NUMBER   ,
  p_position_line_id          IN       NUMBER   , --bug:6650871
  p_service_package_id        IN       NUMBER
);

END PSB_WS_POSITION_RFS_PVT;

/
