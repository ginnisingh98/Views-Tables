--------------------------------------------------------
--  DDL for Package PSB_WS_POSITION_FTE_I_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_POSITION_FTE_I_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBWFTIS.pls 120.2 2005/07/13 11:34:28 shtripat ship $ */

--Called from Forms when the worksheet is changed

PROCEDURE Insert_Row
(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  --
  p_return_status              OUT  NOCOPY      VARCHAR2,
  p_msg_count                  OUT  NOCOPY      NUMBER,
  p_msg_data                   OUT  NOCOPY      VARCHAR2,
  p_fte_line_id                OUT  NOCOPY      NUMBER,
  --
  p_worksheet_id                IN      NUMBER,
  p_position_line_id            IN      NUMBER,
  p_budget_year_id              IN      NUMBER,
  p_service_package_id          IN      NUMBER,
  p_stage_set_id                IN      NUMBER,
  p_current_stage_seq           IN      NUMBER,
  p_period_1                    IN      NUMBER,
  p_period_2                    IN      NUMBER,
  p_period_3                    IN      NUMBER,
  p_period_4                    IN      NUMBER,
  p_period_5                    IN      NUMBER,
  p_period_6                    IN      NUMBER,
  p_period_7                    IN      NUMBER,
  p_period_8                    IN      NUMBER,
  p_period_9                    IN      NUMBER,
  p_period_10                   IN      NUMBER,
  p_period_11                   IN      NUMBER,
  p_period_12                   IN      NUMBER
);


END PSB_WS_POSITION_FTE_I_PVT;

 

/
