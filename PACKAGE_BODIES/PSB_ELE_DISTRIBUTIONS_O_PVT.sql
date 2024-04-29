--------------------------------------------------------
--  DDL for Package Body PSB_ELE_DISTRIBUTIONS_O_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_ELE_DISTRIBUTIONS_O_PVT" AS
/* $Header: PSBWEDOB.pls 120.2 2005/07/13 11:33:18 shtripat ship $ */


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
) IS

BEGIN

PSB_ELEMENT_DISTRIBUTIONS_PVT.DELETE_ROW
(
  p_api_version               ,
  p_init_msg_list             ,
  p_commit                    ,
  p_validation_level          ,
  p_return_status             ,
  p_msg_count                 ,
  p_msg_data                  ,
  --
  P_DISTRIBUTION_ID                  ,
  P_POSITION_SET_GROUP_ID            ,
  P_CHART_OF_ACCOUNTS_ID             ,
  P_EFFECTIVE_START_DATE
);

END DELETE_ROW;

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
  P_DISTRIBUTION_SET_ID       IN       NUMBER,
  P_Return_Value_date         IN OUT  NOCOPY   VARCHAR2,
  P_Return_Value_ccid         IN OUT  NOCOPY   VARCHAR2
) IS

BEGIN

PSB_ELEMENT_DISTRIBUTIONS_PVT.CHECK_UNIQUE
(
  p_api_version               ,
  p_init_msg_list             ,
  p_commit                    ,
  p_validation_level          ,
  p_return_status             ,
  p_msg_count                 ,
  p_msg_data                  ,
  --
  P_DISTRIBUTION_ID           ,
  P_POSITION_SET_GROUP_ID     ,
  P_CHART_OF_ACCOUNTS_ID      ,
  P_EFFECTIVE_START_DATE      ,
  P_EFFECTIVE_END_DATE        ,
  P_CODE_COMBINATION_ID       ,
  P_DISTRIBUTION_SET_ID       ,
  P_Return_Value_date         ,
  P_Return_Value_ccid
);

END CHECK_UNIQUE;

END PSB_ELE_DISTRIBUTIONS_O_PVT;

/
