--------------------------------------------------------
--  DDL for Package PSB_ELE_DISTRIBUTIONS_O_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_ELE_DISTRIBUTIONS_O_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBWEDOS.pls 120.2 2005/07/13 11:33:23 shtripat ship $ */


PROCEDURE DELETE_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_DISTRIBUTION_ID                  IN      NUMBER,
  P_POSITION_SET_GROUP_ID            in      NUMBER,
  P_CHART_OF_ACCOUNTS_ID             IN      NUMBER,
  P_EFFECTIVE_START_DATE             IN      DATE
);


PROCEDURE Check_Unique
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  P_DISTRIBUTION_ID           IN       NUMBER,
  P_POSITION_SET_GROUP_ID     IN       NUMBER,
  P_CHART_OF_ACCOUNTS_ID      IN       NUMBER,
  P_EFFECTIVE_START_DATE      IN       DATE,
  P_EFFECTIVE_END_DATE        IN       DATE,
  P_CODE_COMBINATION_ID       IN       NUMBER,
  P_DISTRIBUTION_SET_ID       IN      NUMBER,
  P_Return_Value_date         IN OUT  NOCOPY   VARCHAR2,
  P_Return_Value_ccid         IN OUT  NOCOPY   VARCHAR2
);

END PSB_ELE_DISTRIBUTIONS_O_PVT;

 

/
