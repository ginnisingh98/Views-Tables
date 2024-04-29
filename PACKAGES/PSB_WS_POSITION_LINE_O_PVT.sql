--------------------------------------------------------
--  DDL for Package PSB_WS_POSITION_LINE_O_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_POSITION_LINE_O_PVT" AUTHID CURRENT_USER as
 /* $Header: PSBVPLOS.pls 120.2 2005/07/13 11:28:49 shtripat ship $ */

procedure UPDATE_ROW (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_POSITION_LINE_ID          IN       NUMBER,
  P_POSITION_ID               IN       NUMBER,
  P_DESCRIPTION               IN       VARCHAR2,
  P_ATTRIBUTE1                in       VARCHAR2,
  P_ATTRIBUTE2                in       VARCHAR2,
  P_ATTRIBUTE3                in       VARCHAR2,
  P_ATTRIBUTE4                in       VARCHAR2,
  P_ATTRIBUTE5                in       VARCHAR2,
  P_ATTRIBUTE6                in       VARCHAR2,
  P_ATTRIBUTE7                in       VARCHAR2,
  P_ATTRIBUTE8                in       VARCHAR2,
  P_ATTRIBUTE9                in       VARCHAR2,
  P_ATTRIBUTE10               in       VARCHAR2,
  P_CONTEXT                   in       VARCHAR2
);

end PSB_WS_POSITION_LINE_O_PVT;

 

/
