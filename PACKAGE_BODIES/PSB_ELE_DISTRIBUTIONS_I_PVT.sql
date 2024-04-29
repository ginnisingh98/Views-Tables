--------------------------------------------------------
--  DDL for Package Body PSB_ELE_DISTRIBUTIONS_I_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_ELE_DISTRIBUTIONS_I_PVT" AS
/* $Header: PSBWEDIB.pls 120.2 2005/07/13 11:32:56 shtripat ship $ */

PROCEDURE INSERT_ROW
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
  P_EFFECTIVE_START_DATE             IN      DATE,
  P_EFFECTIVE_END_DATE               IN      DATE,
  P_DISTRIBUTION_PERCENT             IN      NUMBER,
  P_CONCATENATED_SEGMENTS            IN      VARCHAR2,
  P_CODE_COMBINATION_ID              IN      NUMBER,
  P_DISTRIBUTION_SET_ID              IN      NUMBER,
  P_SEGMENT1                         IN      VARCHAR2,
  P_SEGMENT2                         IN      VARCHAR2,
  P_SEGMENT3                         IN      VARCHAR2,
  P_SEGMENT4                         IN      VARCHAR2,
  P_SEGMENT5                         IN      VARCHAR2,
  P_SEGMENT6                         IN      VARCHAR2,
  P_SEGMENT7                         IN      VARCHAR2,
  P_SEGMENT8                         IN      VARCHAR2,
  P_SEGMENT9                         IN      VARCHAR2,
  P_SEGMENT10                        IN      VARCHAR2,
  P_SEGMENT11                        IN      VARCHAR2,
  P_SEGMENT12                        IN      VARCHAR2,
  P_SEGMENT13                        IN      VARCHAR2,
  P_SEGMENT14                        IN      VARCHAR2,
  P_SEGMENT15                        IN      VARCHAR2,
  P_SEGMENT16                        IN      VARCHAR2,
  P_SEGMENT17                        IN      VARCHAR2,
  P_SEGMENT18                        IN      VARCHAR2,
  P_SEGMENT19                        IN      VARCHAR2,
  P_SEGMENT20                        IN      VARCHAR2,
  P_SEGMENT21                        IN      VARCHAR2,
  P_SEGMENT22                        IN      VARCHAR2,
  P_SEGMENT23                        IN      VARCHAR2,
  P_SEGMENT24                        IN      VARCHAR2,
  P_SEGMENT25                        IN      VARCHAR2,
  P_SEGMENT26                        IN      VARCHAR2,
  P_SEGMENT27                        IN      VARCHAR2,
  P_SEGMENT28                        IN      VARCHAR2,
  P_SEGMENT29                        IN      VARCHAR2,
  P_SEGMENT30                        IN      VARCHAR2,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER,
  P_CREATED_BY                       in      NUMBER,
  P_CREATION_DATE                    in      DATE
) IS

BEGIN

PSB_ELEMENT_DISTRIBUTIONS_PVT.INSERT_ROW
(
  p_api_version                 ,
  p_init_msg_list               ,
  p_commit                      ,
  p_validation_level            ,
  p_return_status               ,
  p_msg_count                   ,
  p_msg_data                    ,
  --
  P_DISTRIBUTION_ID                  ,
  P_POSITION_SET_GROUP_ID            ,
  P_CHART_OF_ACCOUNTS_ID             ,
  P_EFFECTIVE_START_DATE             ,
  P_EFFECTIVE_END_DATE               ,
  P_DISTRIBUTION_PERCENT             ,
  P_CONCATENATED_SEGMENTS            ,
  P_CODE_COMBINATION_ID              ,
  P_DISTRIBUTION_SET_ID              ,
  P_SEGMENT1                         ,
  P_SEGMENT2                         ,
  P_SEGMENT3                         ,
  P_SEGMENT4                         ,
  P_SEGMENT5                         ,
  P_SEGMENT6                         ,
  P_SEGMENT7                         ,
  P_SEGMENT8                         ,
  P_SEGMENT9                         ,
  P_SEGMENT10                        ,
  P_SEGMENT11                        ,
  P_SEGMENT12                        ,
  P_SEGMENT13                        ,
  P_SEGMENT14                        ,
  P_SEGMENT15                        ,
  P_SEGMENT16                        ,
  P_SEGMENT17                        ,
  P_SEGMENT18                        ,
  P_SEGMENT19                        ,
  P_SEGMENT20                        ,
  P_SEGMENT21                        ,
  P_SEGMENT22                        ,
  P_SEGMENT23                        ,
  P_SEGMENT24                        ,
  P_SEGMENT25                        ,
  P_SEGMENT26                        ,
  P_SEGMENT27                        ,
  P_SEGMENT28                        ,
  P_SEGMENT29                        ,
  P_SEGMENT30                        ,
  P_LAST_UPDATE_DATE                 ,
  P_LAST_UPDATED_BY                  ,
  P_LAST_UPDATE_LOGIN                ,
  P_CREATED_BY                       ,
  P_CREATION_DATE
);

END INSERT_ROW;

END PSB_ELE_DISTRIBUTIONS_I_PVT;

/
