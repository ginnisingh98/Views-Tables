--------------------------------------------------------
--  DDL for Package PSB_WS_POSITION_LINE_L_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_POSITION_LINE_L_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVPLLS.pls 120.2 2005/07/13 11:28:38 shtripat ship $ */


PROCEDURE Lock_Row
(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status              OUT  NOCOPY      VARCHAR2,
  p_msg_count                  OUT  NOCOPY      NUMBER,
  p_msg_data                   OUT  NOCOPY      VARCHAR2,
  p_row_locked                 OUT  NOCOPY      VARCHAR2,
  --
  p_position_line_id            IN      NUMBER,
  p_position_id                 IN      NUMBER
  --
 );


END PSB_WS_POSITION_LINE_L_PVT;

 

/
