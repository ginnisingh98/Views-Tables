--------------------------------------------------------
--  DDL for Package Body PSB_ACCT_POS_SET_LINE_I_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_ACCT_POS_SET_LINE_I_PVT" AS
/* $Header: PSBWSLIB.pls 120.2 2005/07/13 11:37:30 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_Acct_Pos_Set_Line_I_PVT';



/*=========================================================================+
 |                       PROCEDURE Insert_Row                              |
 +========================================================================*/

PROCEDURE Insert_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Row_Id                    IN OUT  NOCOPY VARCHAR2,
  p_Line_Sequence_Id          IN OUT  NOCOPY NUMBER,
  p_Account_Position_Set_Id       NUMBER,
  p_Description                   VARCHAR2,
  p_Business_Group_Id             NUMBER,
  p_Attribute_Id                  NUMBER,
  p_Include_Or_Exclude_Type       VARCHAR2,
  p_Segment1_Low                  VARCHAR2,
  p_Segment2_Low                  VARCHAR2,
  p_Segment3_Low                  VARCHAR2,
  p_Segment4_Low                  VARCHAR2,
  p_Segment5_Low                  VARCHAR2,
  p_Segment6_Low                  VARCHAR2,
  p_Segment7_Low                  VARCHAR2,
  p_Segment8_Low                  VARCHAR2,
  p_Segment9_Low                  VARCHAR2,
  p_Segment10_Low                 VARCHAR2,
  p_Segment11_Low                 VARCHAR2,
  p_Segment12_Low                 VARCHAR2,
  p_Segment13_Low                 VARCHAR2,
  p_Segment14_Low                 VARCHAR2,
  p_Segment15_Low                 VARCHAR2,
  p_Segment16_Low                 VARCHAR2,
  p_Segment17_Low                 VARCHAR2,
  p_Segment18_Low                 VARCHAR2,
  p_Segment19_Low                 VARCHAR2,
  p_Segment20_Low                 VARCHAR2,
  p_Segment21_Low                 VARCHAR2,
  p_Segment22_Low                 VARCHAR2,
  p_Segment23_Low                 VARCHAR2,
  p_Segment24_Low                 VARCHAR2,
  p_Segment25_Low                 VARCHAR2,
  p_Segment26_Low                 VARCHAR2,
  p_Segment27_Low                 VARCHAR2,
  p_Segment28_Low                 VARCHAR2,
  p_Segment29_Low                 VARCHAR2,
  p_Segment30_Low                 VARCHAR2,
  p_Segment1_High                 VARCHAR2,
  p_Segment2_High                 VARCHAR2,
  p_Segment3_High                 VARCHAR2,
  p_Segment4_High                 VARCHAR2,
  p_Segment5_High                 VARCHAR2,
  p_Segment6_High                 VARCHAR2,
  p_Segment7_High                 VARCHAR2,
  p_Segment8_High                 VARCHAR2,
  p_Segment9_High                 VARCHAR2,
  p_Segment10_High                VARCHAR2,
  p_Segment11_High                VARCHAR2,
  p_Segment12_High                VARCHAR2,
  p_Segment13_High                VARCHAR2,
  p_Segment14_High                VARCHAR2,
  p_Segment15_High                VARCHAR2,
  p_Segment16_High                VARCHAR2,
  p_Segment17_High                VARCHAR2,
  p_Segment18_High                VARCHAR2,
  p_Segment19_High                VARCHAR2,
  p_Segment20_High                VARCHAR2,
  p_Segment21_High                VARCHAR2,
  p_Segment22_High                VARCHAR2,
  p_Segment23_High                VARCHAR2,
  p_Segment24_High                VARCHAR2,
  p_Segment25_High                VARCHAR2,
  p_Segment26_High                VARCHAR2,
  p_Segment27_High                VARCHAR2,
  p_Segment28_High                VARCHAR2,
  p_Segment29_High                VARCHAR2,
  p_Segment30_High                VARCHAR2,
  p_context                       VARCHAR2,
  p_attribute1                    VARCHAR2,
  p_attribute2                    VARCHAR2,
  p_attribute3                    VARCHAR2,
  p_attribute4                    VARCHAR2,
  p_attribute5                    VARCHAR2,
  p_attribute6                    VARCHAR2,
  p_attribute7                    VARCHAR2,
  p_attribute8                    VARCHAR2,
  p_attribute9                    VARCHAR2,
  p_attribute10                   VARCHAR2,
  p_Last_Update_Date              DATE,
  p_Last_Updated_By               NUMBER,
  p_Last_Update_Login             NUMBER,
  p_Created_By                    NUMBER,
  p_Creation_Date                 DATE
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  --
BEGIN
  --
  SAVEPOINT Insert_Row_Pvt ;
  --

  PSB_ACCT_POSITION_SET_LINE_PVT.Insert_Row
  (
    p_api_version              =>    p_api_version ,
    p_init_msg_list            =>    p_init_msg_list ,
    p_commit                   =>    p_commit ,
    p_validation_level         =>    p_validation_level,
    p_return_status            =>    p_return_status,
    p_msg_count                =>    p_msg_count,
    p_msg_data                 =>    p_msg_data,
    --
    p_Row_Id                   =>    p_Row_Id,
    p_Line_Sequence_Id         =>    p_Line_Sequence_Id,
    p_Account_Position_Set_Id  =>    p_Account_Position_Set_Id,
    p_Description              =>    p_Description,
    p_Business_Group_Id        =>    p_Business_Group_Id,
    p_Attribute_Id             =>    p_Attribute_Id,
    p_Include_Or_Exclude_Type  =>    p_Include_Or_Exclude_Type,
    p_Segment1_Low             =>    p_Segment1_Low,
    p_Segment2_Low             =>    p_Segment2_Low,
    p_Segment3_Low             =>    p_Segment3_Low,
    p_Segment4_Low             =>    p_Segment4_Low,
    p_Segment5_Low             =>    p_Segment5_Low,
    p_Segment6_Low             =>    p_Segment6_Low,
    p_Segment7_Low             =>    p_Segment7_Low,
    p_Segment8_Low             =>    p_Segment8_Low,
    p_Segment9_Low             =>    p_Segment9_Low,
    p_Segment10_Low            =>    p_Segment10_Low,
    p_Segment11_Low            =>    p_Segment11_Low,
    p_Segment12_Low            =>    p_Segment12_Low,
    p_Segment13_Low            =>    p_Segment13_Low,
    p_Segment14_Low            =>    p_Segment14_Low,
    p_Segment15_Low            =>    p_Segment15_Low,
    p_Segment16_Low            =>    p_Segment16_Low,
    p_Segment17_Low            =>    p_Segment17_Low,
    p_Segment18_Low            =>    p_Segment18_Low,
    p_Segment19_Low            =>    p_Segment19_Low,
    p_Segment20_Low            =>    p_Segment20_Low,
    p_Segment21_Low            =>    p_Segment21_Low,
    p_Segment22_Low            =>    p_Segment22_Low,
    p_Segment23_Low            =>    p_Segment23_Low,
    p_Segment24_Low            =>    p_Segment24_Low,
    p_Segment25_Low            =>    p_Segment25_Low,
    p_Segment26_Low            =>    p_Segment26_Low,
    p_Segment27_Low            =>    p_Segment27_Low,
    p_Segment28_Low            =>    p_Segment28_Low,
    p_Segment29_Low            =>    p_Segment29_Low,
    p_Segment30_Low            =>    p_Segment30_Low,
    p_Segment1_High            =>    p_Segment1_High,
    p_Segment2_High            =>    p_Segment2_High,
    p_Segment3_High            =>    p_Segment3_High,
    p_Segment4_High            =>    p_Segment4_High,
    p_Segment5_High            =>    p_Segment5_High,
    p_Segment6_High            =>    p_Segment6_High,
    p_Segment7_High            =>    p_Segment7_High,
    p_Segment8_High            =>    p_Segment8_High,
    p_Segment9_High            =>    p_Segment9_High,
    p_Segment10_High           =>    p_Segment10_High,
    p_Segment11_High           =>    p_Segment11_High,
    p_Segment12_High           =>    p_Segment12_High,
    p_Segment13_High           =>    p_Segment13_High,
    p_Segment14_High           =>    p_Segment14_High,
    p_Segment15_High           =>    p_Segment15_High,
    p_Segment16_High           =>    p_Segment16_High,
    p_Segment17_High           =>    p_Segment17_High,
    p_Segment18_High           =>    p_Segment18_High,
    p_Segment19_High           =>    p_Segment19_High,
    p_Segment20_High           =>    p_Segment20_High,
    p_Segment21_High           =>    p_Segment21_High,
    p_Segment22_High           =>    p_Segment22_High,
    p_Segment23_High           =>    p_Segment23_High,
    p_Segment24_High           =>    p_Segment24_High,
    p_Segment25_High           =>    p_Segment25_High,
    p_Segment26_High           =>    p_Segment26_High,
    p_Segment27_High           =>    p_Segment27_High,
    p_Segment28_High           =>    p_Segment28_High,
    p_Segment29_High           =>    p_Segment29_High,
    p_Segment30_High           =>    p_Segment30_High,
    p_context                  =>    p_context,
    p_attribute1               =>    p_attribute1,
    p_attribute2               =>    p_attribute2,
    p_attribute3               =>    p_attribute3,
    p_attribute4               =>    p_attribute4,
    p_attribute5               =>    p_attribute5,
    p_attribute6               =>    p_attribute6,
    p_attribute7               =>    p_attribute7,
    p_attribute8               =>    p_attribute8,
    p_attribute9               =>    p_attribute9,
    p_attribute10              =>    p_attribute10,
    p_Last_Update_Date         =>    p_Last_Update_Date,
    p_Last_Updated_By          =>    p_Last_Updated_By,
    p_Last_Update_Login        =>    p_Last_Update_Login,
    p_Created_By               =>    p_Created_By,
    p_Creation_Date            =>    p_Creation_Date
  );

EXCEPTION
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Insert_Row_Pvt ;
    --
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name );
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
     --

END Insert_Row;
/*-------------------------------------------------------------------------*/


END PSB_Acct_Pos_Set_Line_I_PVT;

/
