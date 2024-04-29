--------------------------------------------------------
--  DDL for Package PSB_BUDGET_POSITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_BUDGET_POSITION_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVMBPS.pls 120.3.12010000.3 2009/02/26 12:04:27 rkotha ship $ */

PROCEDURE Populate_Budget_Positions
(
  p_api_version       IN  NUMBER ,
  p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE ,
  p_commit            IN  VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status     OUT  NOCOPY VARCHAR2 ,
  p_msg_count         OUT  NOCOPY NUMBER   ,
  p_msg_data          OUT  NOCOPY VARCHAR2 ,
  --
  p_position_set_id   IN  psb_account_position_sets.account_position_set_id%TYPE
			  := FND_API.G_MISS_NUM ,

  p_data_extract_id   IN  psb_data_extracts.data_extract_id%TYPE
			  := FND_API.G_MISS_NUM
);

-- Bug 4545909 added the in parameter p_worksheet_id
-- bug #5450510
-- added parameter p_data_extract_id to the following api
PROCEDURE Add_Position_To_Position_Sets
(
  p_api_version       IN  NUMBER ,
  p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE ,
  p_commit            IN  VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status     OUT  NOCOPY VARCHAR2 ,
  p_msg_count         OUT  NOCOPY NUMBER   ,
  p_msg_data          OUT  NOCOPY VARCHAR2 ,
  --
  p_position_id       IN  psb_positions.position_id%TYPE,
  p_worksheet_id      IN  NUMBER DEFAULT NULL,
  p_data_extract_id   IN  psb_data_extracts.data_extract_id%TYPE
);


PROCEDURE Populate_Budget_Positions_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_data_extract_id           IN       NUMBER   := FND_API.G_MISS_NUM ,
  p_position_set_id           IN       NUMBER   := FND_API.G_MISS_NUM
);


END PSB_Budget_Position_Pvt;

/
