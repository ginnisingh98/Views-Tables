--------------------------------------------------------
--  DDL for Package PSB_ELE_DISTRIBUTIONS_L_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_ELE_DISTRIBUTIONS_L_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBWEDLS.pls 120.2 2005/07/13 11:33:12 shtripat ship $ */

PROCEDURE LOCK_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  p_row_locked                       OUT  NOCOPY     VARCHAR2,
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
  P_SEGMENT30                        IN      VARCHAR2
);

END PSB_ELE_DISTRIBUTIONS_L_PVT;

 

/
