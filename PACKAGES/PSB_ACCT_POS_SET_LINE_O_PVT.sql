--------------------------------------------------------
--  DDL for Package PSB_ACCT_POS_SET_LINE_O_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_ACCT_POS_SET_LINE_O_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBWSLOS.pls 120.2 2005/07/13 11:37:59 shtripat ship $ */

PROCEDURE Update_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Row_Id                             VARCHAR2,
  p_Line_Sequence_Id                   NUMBER,
  p_Account_Position_Set_Id            NUMBER,
  p_Description                        VARCHAR2,
  p_Business_Group_Id                  NUMBER,
  p_Attribute_Id                       NUMBER,
  p_Include_Or_Exclude_Type            VARCHAR2,
  p_Segment1_Low                       VARCHAR2,
  p_Segment2_Low                       VARCHAR2,
  p_Segment3_Low                       VARCHAR2,
  p_Segment4_Low                       VARCHAR2,
  p_Segment5_Low                       VARCHAR2,
  p_Segment6_Low                       VARCHAR2,
  p_Segment7_Low                       VARCHAR2,
  p_Segment8_Low                       VARCHAR2,
  p_Segment9_Low                       VARCHAR2,
  p_Segment10_Low                      VARCHAR2,
  p_Segment11_Low                      VARCHAR2,
  p_Segment12_Low                      VARCHAR2,
  p_Segment13_Low                      VARCHAR2,
  p_Segment14_Low                      VARCHAR2,
  p_Segment15_Low                      VARCHAR2,
  p_Segment16_Low                      VARCHAR2,
  p_Segment17_Low                      VARCHAR2,
  p_Segment18_Low                      VARCHAR2,
  p_Segment19_Low                      VARCHAR2,
  p_Segment20_Low                      VARCHAR2,
  p_Segment21_Low                      VARCHAR2,
  p_Segment22_Low                      VARCHAR2,
  p_Segment23_Low                      VARCHAR2,
  p_Segment24_Low                      VARCHAR2,
  p_Segment25_Low                      VARCHAR2,
  p_Segment26_Low                      VARCHAR2,
  p_Segment27_Low                      VARCHAR2,
  p_Segment28_Low                      VARCHAR2,
  p_Segment29_Low                      VARCHAR2,
  p_Segment30_Low                      VARCHAR2,
  p_Segment1_High                      VARCHAR2,
  p_Segment2_High                      VARCHAR2,
  p_Segment3_High                      VARCHAR2,
  p_Segment4_High                      VARCHAR2,
  p_Segment5_High                      VARCHAR2,
  p_Segment6_High                      VARCHAR2,
  p_Segment7_High                      VARCHAR2,
  p_Segment8_High                      VARCHAR2,
  p_Segment9_High                      VARCHAR2,
  p_Segment10_High                     VARCHAR2,
  p_Segment11_High                     VARCHAR2,
  p_Segment12_High                     VARCHAR2,
  p_Segment13_High                     VARCHAR2,
  p_Segment14_High                     VARCHAR2,
  p_Segment15_High                     VARCHAR2,
  p_Segment16_High                     VARCHAR2,
  p_Segment17_High                     VARCHAR2,
  p_Segment18_High                     VARCHAR2,
  p_Segment19_High                     VARCHAR2,
  p_Segment20_High                     VARCHAR2,
  p_Segment21_High                     VARCHAR2,
  p_Segment22_High                     VARCHAR2,
  p_Segment23_High                     VARCHAR2,
  p_Segment24_High                     VARCHAR2,
  p_Segment25_High                     VARCHAR2,
  p_Segment26_High                     VARCHAR2,
  p_Segment27_High                     VARCHAR2,
  p_Segment28_High                     VARCHAR2,
  p_Segment29_High                     VARCHAR2,
  p_Segment30_High                     VARCHAR2,
  p_context                            VARCHAR2,
  p_attribute1                         VARCHAR2,
  p_attribute2                         VARCHAR2,
  p_attribute3                         VARCHAR2,
  p_attribute4                         VARCHAR2,
  p_attribute5                         VARCHAR2,
  p_attribute6                         VARCHAR2,
  p_attribute7                         VARCHAR2,
  p_attribute8                         VARCHAR2,
  p_attribute9                         VARCHAR2,
  p_attribute10                        VARCHAR2,
  p_Last_Update_Date                   DATE,
  p_Last_Updated_By                    NUMBER,
  p_Last_Update_Login                  NUMBER
);

PROCEDURE Delete_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Row_Id                             VARCHAR2
);

END PSB_Acct_Pos_Set_Line_O_PVT ;

 

/
