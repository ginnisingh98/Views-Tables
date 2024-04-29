--------------------------------------------------------
--  DDL for Package PSB_WS_POSITION_CPC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_POSITION_CPC_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBWPPCS.pls 120.2 2005/07/13 11:37:02 shtripat ship $ */

--Called from Forms when the worksheet is changed

PROCEDURE Calculate_Position_Cost
(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  --
  p_return_status              OUT  NOCOPY      VARCHAR2,
  p_msg_count                  OUT  NOCOPY      NUMBER,
  p_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_worksheet_id                IN      NUMBER,
  p_position_line_id            IN      NUMBER
);


END PSB_WS_POSITION_CPC_PVT;

 

/
