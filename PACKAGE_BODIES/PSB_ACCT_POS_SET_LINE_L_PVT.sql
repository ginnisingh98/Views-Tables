--------------------------------------------------------
--  DDL for Package Body PSB_ACCT_POS_SET_LINE_L_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_ACCT_POS_SET_LINE_L_PVT" AS
/* $Header: PSBWSLLB.pls 120.2 2005/07/13 11:37:41 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_Acct_Pos_Set_Line_L_PVT';



/*=========================================================================+
 |                       PROCEDURE Lock_Row                                |
 +=========================================================================*/

PROCEDURE Lock_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Row_Id                    IN       VARCHAR2,
  p_Line_Sequence_Id          IN       NUMBER,
  p_Account_Position_Set_Id   IN       NUMBER,
  p_Description               IN       VARCHAR2,
  p_Business_Group_Id         IN       NUMBER,
  p_Attribute_Id              IN       NUMBER,
  p_Include_Or_Exclude_Type   IN       VARCHAR2,
  p_Segment1_Low              IN       VARCHAR2,
  p_Segment2_Low              IN       VARCHAR2,
  p_Segment3_Low              IN       VARCHAR2,
  p_Segment4_Low              IN       VARCHAR2,
  p_Segment5_Low              IN       VARCHAR2,
  p_Segment6_Low              IN       VARCHAR2,
  p_Segment7_Low              IN       VARCHAR2,
  p_Segment8_Low              IN       VARCHAR2,
  p_Segment9_Low              IN       VARCHAR2,
  p_Segment10_Low             IN       VARCHAR2,
  p_Segment11_Low             IN       VARCHAR2,
  p_Segment12_Low             IN       VARCHAR2,
  p_Segment13_Low             IN       VARCHAR2,
  p_Segment14_Low             IN       VARCHAR2,
  p_Segment15_Low             IN       VARCHAR2,
  p_Segment16_Low             IN       VARCHAR2,
  p_Segment17_Low             IN       VARCHAR2,
  p_Segment18_Low             IN       VARCHAR2,
  p_Segment19_Low             IN       VARCHAR2,
  p_Segment20_Low             IN       VARCHAR2,
  p_Segment21_Low             IN       VARCHAR2,
  p_Segment22_Low             IN       VARCHAR2,
  p_Segment23_Low             IN       VARCHAR2,
  p_Segment24_Low             IN       VARCHAR2,
  p_Segment25_Low             IN       VARCHAR2,
  p_Segment26_Low             IN       VARCHAR2,
  p_Segment27_Low             IN       VARCHAR2,
  p_Segment28_Low             IN       VARCHAR2,
  p_Segment29_Low             IN       VARCHAR2,
  p_Segment30_Low             IN       VARCHAR2,
  p_Segment1_High             IN       VARCHAR2,
  p_Segment2_High             IN       VARCHAR2,
  p_Segment3_High             IN       VARCHAR2,
  p_Segment4_High             IN       VARCHAR2,
  p_Segment5_High             IN       VARCHAR2,
  p_Segment6_High             IN       VARCHAR2,
  p_Segment7_High             IN       VARCHAR2,
  p_Segment8_High             IN       VARCHAR2,
  p_Segment9_High             IN       VARCHAR2,
  p_Segment10_High            IN       VARCHAR2,
  p_Segment11_High            IN       VARCHAR2,
  p_Segment12_High            IN       VARCHAR2,
  p_Segment13_High            IN       VARCHAR2,
  p_Segment14_High            IN       VARCHAR2,
  p_Segment15_High            IN       VARCHAR2,
  p_Segment16_High            IN       VARCHAR2,
  p_Segment17_High            IN       VARCHAR2,
  p_Segment18_High            IN       VARCHAR2,
  p_Segment19_High            IN       VARCHAR2,
  p_Segment20_High            IN       VARCHAR2,
  p_Segment21_High            IN       VARCHAR2,
  p_Segment22_High            IN       VARCHAR2,
  p_Segment23_High            IN       VARCHAR2,
  p_Segment24_High            IN       VARCHAR2,
  p_Segment25_High            IN       VARCHAR2,
  p_Segment26_High            IN       VARCHAR2,
  p_Segment27_High            IN       VARCHAR2,
  p_Segment28_High            IN       VARCHAR2,
  p_Segment29_High            IN       VARCHAR2,
  p_Segment30_High            IN       VARCHAR2,
  p_context                   IN       VARCHAR2,
  p_attribute1                IN       VARCHAR2,
  p_attribute2                IN       VARCHAR2,
  p_attribute3                IN       VARCHAR2,
  p_attribute4                IN       VARCHAR2,
  p_attribute5                IN       VARCHAR2,
  p_attribute6                IN       VARCHAR2,
  p_attribute7                IN       VARCHAR2,
  p_attribute8                IN       VARCHAR2,
  p_attribute9                IN       VARCHAR2,
  p_attribute10               IN       VARCHAR2,
  --
  p_row_locked                OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  --
BEGIN
  --
  SAVEPOINT Lock_Row_Pvt ;
  --

  PSB_ACCT_POSITION_SET_LINE_PVT.Lock_Row
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
    --
    p_row_locked               =>    p_row_locked
  );


EXCEPTION
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
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
END Lock_Row;
/*-------------------------------------------------------------------------*/


END PSB_Acct_Pos_Set_Line_L_PVT;

/
