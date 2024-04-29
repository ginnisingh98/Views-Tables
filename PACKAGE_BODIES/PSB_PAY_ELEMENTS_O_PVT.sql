--------------------------------------------------------
--  DDL for Package Body PSB_PAY_ELEMENTS_O_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_PAY_ELEMENTS_O_PVT" AS
/* $Header: PSBWELOB.pls 120.2 2005/07/13 11:34:01 shtripat ship $ */


PROCEDURE DELETE_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_ROW_ID                      IN      VARCHAR2
) IS

BEGIN

PSB_PAY_ELEMENTS_PVT.DELETE_ROW
(
 p_api_version                  ,
  p_init_msg_list               ,
  p_commit                      ,
  p_validation_level            ,
  p_return_status               ,
  p_msg_count                   ,
  p_msg_data                    ,
  --
  P_ROW_ID
);

END DELETE_ROW;


PROCEDURE Check_Unique
(
  p_api_version              IN      NUMBER ,
  p_init_msg_list            IN      VARCHAR2 := FND_API.G_FALSE ,
  p_commit                   IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level         IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status            OUT  NOCOPY     VARCHAR2 ,
  p_msg_count                OUT  NOCOPY     NUMBER ,
  p_msg_data                 OUT  NOCOPY     VARCHAR2 ,
  --
  P_Row_Id                   IN      VARCHAR2 ,
  P_Name                     IN      VARCHAR2 ,
  P_DATA_EXTRACT_ID          IN       NUMBER,
  P_Return_Value             IN OUT  NOCOPY  VARCHAR2
) IS

BEGIN

PSB_PAY_ELEMENTS_PVT.CHECK_UNIQUE
(p_api_version               ,
  p_init_msg_list            ,
  p_commit                   ,
  p_validation_level         ,
  p_return_status            ,
  p_msg_count                ,
  p_msg_data                 ,
  --
  P_Row_Id                   ,
  P_Name                     ,
  P_DATA_EXTRACT_ID          ,
  P_Return_Value
);

END Check_Unique;

PROCEDURE Check_References
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  P_PAY_ELEMENT_Id            IN       NUMBER,
  P_Return_Value              IN OUT  NOCOPY   VARCHAR2
) IS

BEGIN

PSB_PAY_ELEMENTS_PVT.Check_References
(
  p_api_version               ,
  p_init_msg_list             ,
  p_commit                    ,
  p_validation_level          ,
  p_return_status             ,
  p_msg_count                 ,
  p_msg_data                  ,
  --
  P_PAY_ELEMENT_Id            ,
  P_Return_Value
);

END Check_References;

END PSB_PAY_ELEMENTS_O_PVT;

/
