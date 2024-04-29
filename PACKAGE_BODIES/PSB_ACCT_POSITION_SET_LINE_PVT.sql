--------------------------------------------------------
--  DDL for Package Body PSB_ACCT_POSITION_SET_LINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_ACCT_POSITION_SET_LINE_PVT" AS
/* $Header: PSBVSTLB.pls 120.2 2005/07/13 11:29:56 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_Acct_Position_Set_Line_PVT';



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
  p_Row_Id                    IN OUT  NOCOPY   VARCHAR2,
  p_Line_Sequence_Id          IN OUT  NOCOPY   NUMBER,
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
  p_Last_Update_Date          IN       DATE,
  p_Last_Updated_By           IN       NUMBER,
  p_Last_Update_Login         IN       NUMBER,
  p_Created_By                IN       NUMBER,
  p_Creation_Date             IN       DATE
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  CURSOR C  IS SELECT rowid
	       FROM   psb_account_position_set_lines
	       WHERE  line_sequence_id = p_Line_Sequence_Id;
  CURSOR C2 IS SELECT psb_acct_position_set_lines_s.nextval
	       FROM   dual;
BEGIN
  --
  SAVEPOINT Insert_Row_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  IF (p_Line_Sequence_Id is NULL) THEN
    OPEN C2;
    FETCH C2 INTO p_Line_Sequence_Id;
    CLOSE C2;
  END IF;

  INSERT INTO psb_account_position_set_lines
	    (
	      line_sequence_id,
	      account_position_set_id,
	      description,
	      business_group_id,
	      attribute_id,
	      include_or_exclude_type,
	      segment1_low,
	      segment2_low,
	      segment3_low,
	      segment4_low,
	      segment5_low,
	      segment6_low,
	      segment7_low,
	      segment8_low,
	      segment9_low,
	      segment10_low,
	      segment11_low,
	      segment12_low,
	      segment13_low,
	      segment14_low,
	      segment15_low,
	      segment16_low,
	      segment17_low,
	      segment18_low,
	      segment19_low,
	      segment20_low,
	      segment21_low,
	      segment22_low,
	      segment23_low,
	      segment24_low,
	      segment25_low,
	      segment26_low,
	      segment27_low,
	      segment28_low,
	      segment29_low,
	      segment30_low,
	      segment1_high,
	      segment2_high,
	      segment3_high,
	      segment4_high,
	      segment5_high,
	      segment6_high,
	      segment7_high,
	      segment8_high,
	      segment9_high,
	      segment10_high,
	      segment11_high,
	      segment12_high,
	      segment13_high,
	      segment14_high,
	      segment15_high,
	      segment16_high,
	      segment17_high,
	      segment18_high,
	      segment19_high,
	      segment20_high,
	      segment21_high,
	      segment22_high,
	      segment23_high,
	      segment24_high,
	      segment25_high,
	      segment26_high,
	      segment27_high,
	      segment28_high,
	      segment29_high,
	      segment30_high,
	      context,
	      attribute1,
	      attribute2,
	      attribute3,
	      attribute4,
	      attribute5,
	      attribute6,
	      attribute7,
	      attribute8,
	      attribute9,
	      attribute10,
	      last_update_date,
	      last_updated_by,
	      last_update_login,
	      created_by,
	      creation_date
	    )
	  VALUES
	    (
	      p_Line_Sequence_Id,
	      p_Account_Position_Set_Id,
	      p_Description,
	      p_Business_Group_Id,
	      p_Attribute_Id,
	      p_Include_Or_Exclude_Type,
	      p_Segment1_Low,
	      p_Segment2_Low,
	      p_Segment3_Low,
	      p_Segment4_Low,
	      p_Segment5_Low,
	      p_Segment6_Low,
	      p_Segment7_Low,
	      p_Segment8_Low,
	      p_Segment9_Low,
	      p_Segment10_Low,
	      p_Segment11_Low,
	      p_Segment12_Low,
	      p_Segment13_Low,
	      p_Segment14_Low,
	      p_Segment15_Low,
	      p_Segment16_Low,
	      p_Segment17_Low,
	      p_Segment18_Low,
	      p_Segment19_Low,
	      p_Segment20_Low,
	      p_Segment21_Low,
	      p_Segment22_Low,
	      p_Segment23_Low,
	      p_Segment24_Low,
	      p_Segment25_Low,
	      p_Segment26_Low,
	      p_Segment27_Low,
	      p_Segment28_Low,
	      p_Segment29_Low,
	      p_Segment30_Low,
	      p_Segment1_High,
	      p_Segment2_High,
	      p_Segment3_High,
	      p_Segment4_High,
	      p_Segment5_High,
	      p_Segment6_High,
	      p_Segment7_High,
	      p_Segment8_High,
	      p_Segment9_High,
	      p_Segment10_High,
	      p_Segment11_High,
	      p_Segment12_High,
	      p_Segment13_High,
	      p_Segment14_High,
	      p_Segment15_High,
	      p_Segment16_High,
	      p_Segment17_High,
	      p_Segment18_High,
	      p_Segment19_High,
	      p_Segment20_High,
	      p_Segment21_High,
	      p_Segment22_High,
	      p_Segment23_High,
	      p_Segment24_High,
	      p_Segment25_High,
	      p_Segment26_High,
	      p_Segment27_High,
	      p_Segment28_High,
	      p_Segment29_High,
	      p_Segment30_High,
	      p_context,
	      p_attribute1,
	      p_attribute2,
	      p_attribute3,
	      p_attribute4,
	      p_attribute5,
	      p_attribute6,
	      p_attribute7,
	      p_attribute8,
	      p_attribute9,
	      p_attribute10,
	      p_Last_Update_Date,
	      p_Last_Updated_By,
	      p_Last_Update_Login,
	      p_Created_By,
	      p_Creation_Date
	    );
  OPEN C;
  FETCH C INTO p_Row_Id;
  IF (C%NOTFOUND) then
    CLOSE C;
    RAISE FND_API.G_EXC_ERROR ;
    -- Raise NO_DATA_FOUND;
  END IF;
  CLOSE C;
  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
     --

END Insert_Row;
/*-------------------------------------------------------------------------*/



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
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  CURSOR C IS
	SELECT *
	FROM  psb_account_position_set_lines
	WHERE rowid = p_Row_Id
	FOR UPDATE of Line_Sequence_Id NOWAIT;
    Recinfo C%ROWTYPE;

BEGIN
  --
  SAVEPOINT Lock_Row_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  p_row_locked    := FND_API.G_TRUE ;
  --
  OPEN C;
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  CLOSE C;

  IF
	(
	 (Recinfo.line_sequence_id =  p_line_sequence_id)
	  AND ( (Recinfo.account_position_set_id =  p_account_position_set_id)
		 OR ( (Recinfo.account_position_set_id IS NULL)
		       AND (p_account_position_set_id IS NULL)))
	  AND ( (Recinfo.description =  p_description)
		 OR ( (Recinfo.description IS NULL)
		       AND (p_description IS NULL)))
	  AND ( (Recinfo.business_group_id =  p_Business_Group_Id)
		 OR ( (Recinfo.business_group_id IS NULL)
		       AND (p_Business_Group_Id IS NULL)))
	  AND ( (Recinfo.attribute_id = p_attribute_id)
		 OR ( (Recinfo.attribute_id IS NULL)
		       AND (p_attribute_Id IS NULL)))
	  AND ( (Recinfo.include_or_exclude_type = p_include_or_exclude_type)
		 OR ( (Recinfo.include_or_exclude_type IS NULL)
		       AND (p_include_or_exclude_type IS NULL)))
	  AND ( (Recinfo.segment1_low = p_segment1_low)
		 OR ( (Recinfo.segment1_low IS NULL)
		       AND (p_segment1_low IS NULL)))
	  AND ( (Recinfo.segment2_low = p_segment2_low)
		 OR ( (Recinfo.segment2_low IS NULL)
		       AND (p_segment2_low IS NULL)))
	  AND ( (Recinfo.segment3_low = p_segment3_low)
		 OR ( (Recinfo.segment3_low IS NULL)
		       AND (p_segment3_low IS NULL)))
	  AND ( (Recinfo.segment4_low = p_segment4_low)
		 OR ( (Recinfo.segment4_low IS NULL)
		       AND (p_segment4_low IS NULL)))
	  AND ( (Recinfo.segment5_low = p_segment5_low)
		 OR ( (Recinfo.segment5_low IS NULL)
		       AND (p_segment5_low IS NULL)))
	  AND ( (Recinfo.segment6_low = p_segment6_low)
		 OR ( (Recinfo.segment6_low IS NULL)
		       AND (p_segment6_low IS NULL)))
	  AND ( (Recinfo.segment7_low = p_segment7_low)
		 OR ( (Recinfo.segment7_low IS NULL)
		       AND (p_segment7_low IS NULL)))
	  AND ( (Recinfo.segment8_low = p_segment8_low)
		 OR ( (Recinfo.segment8_low IS NULL)
		       AND (p_segment8_low IS NULL)))
	  AND ( (Recinfo.segment9_low = p_segment9_low)
		 OR ( (Recinfo.segment9_low IS NULL)
		       AND (p_segment9_low IS NULL)))
	  AND ( (Recinfo.segment10_low = p_segment10_low)
		 OR ( (Recinfo.segment10_low IS NULL)
		       AND (p_segment10_low IS NULL)))
	  AND ( (Recinfo.segment11_low = p_segment11_low)
		 OR ( (Recinfo.segment11_low IS NULL)
		       AND (p_segment11_low IS NULL)))
	  AND ( (Recinfo.segment12_low = p_segment12_low)
		 OR ( (Recinfo.segment12_low IS NULL)
		       AND (p_segment12_low IS NULL)))
	  AND ( (Recinfo.segment13_low = p_segment13_low)
		 OR ( (Recinfo.segment13_low IS NULL)
		       AND (p_segment13_low IS NULL)))
	  AND ( (Recinfo.segment14_low = p_segment14_low)
		 OR ( (Recinfo.segment14_low IS NULL)
		       AND (p_segment14_low IS NULL)))
	  AND ( (Recinfo.segment15_low = p_segment15_low)
		 OR ( (Recinfo.segment15_low IS NULL)
		       AND (p_segment15_low IS NULL)))
	  AND ( (Recinfo.segment16_low = p_segment16_low)
		 OR ( (Recinfo.segment16_low IS NULL)
		       AND (p_segment16_low IS NULL)))
	  AND ( (Recinfo.segment17_low = p_segment17_low)
		 OR ( (Recinfo.segment17_low IS NULL)
		       AND (p_segment17_low IS NULL)))
	  AND ( (Recinfo.segment18_low = p_segment18_low)
		 OR ( (Recinfo.segment18_low IS NULL)
		       AND (p_segment18_low IS NULL)))
	  AND ( (Recinfo.segment19_low = p_segment19_low)
		 OR ( (Recinfo.segment19_low IS NULL)
		       AnD (p_segment19_low IS NULL)))
	  AND ( (Recinfo.segment20_low = p_segment20_low)
		 OR ( (Recinfo.segment20_low IS NULL)
		       AND (p_segment20_low IS NULL)))
	  AND ( (Recinfo.segment21_low = p_segment21_low)
		 OR ( (Recinfo.segment21_low IS NULL)
		       AND (p_segment21_low IS NULL)))
	  AND ( (Recinfo.segment22_low = p_segment22_low)
		 OR ( (Recinfo.segment22_low IS NULL)
		       AND (p_segment22_low IS NULL)))
	  AND ( (Recinfo.segment23_low = p_segment23_low)
		 OR ( (Recinfo.segment23_low IS NULL)
		       AND (p_segment23_low IS NULL)))
	  AND ( (Recinfo.segment24_low = p_segment24_low)
		 OR ( (Recinfo.segment24_low IS NULL)
		       AND (p_segment24_low IS NULL)))
	  AND ( (Recinfo.segment25_low = p_segment25_low)
		 OR ( (Recinfo.segment25_low IS NULL)
		       AND (p_segment25_low IS NULL)))
	  AND ( (Recinfo.segment26_low = p_segment26_low)
		 OR ( (Recinfo.segment26_low IS NULL)
		       AND (p_segment26_low IS NULL)))
	  AND ( (Recinfo.segment27_low = p_segment27_low)
		 OR ( (Recinfo.segment27_low IS NULL)
		       AND (p_segment27_low IS NULL)))
	  AND ( (Recinfo.segment28_low = p_segment28_low)
		 OR ( (Recinfo.segment28_low IS NULL)
		       AND (p_segment28_low IS NULL)))
	  AND ( (Recinfo.segment29_low = p_segment29_low)
		 OR ( (Recinfo.segment29_low IS NULL)
		       AND (p_segment29_low IS NULL)))
	  AND ( (Recinfo.segment30_low = p_segment30_low)
		 OR ( (Recinfo.segment30_low IS NULL)
		       AND (p_segment30_low IS NULL)))
	  AND ( (Recinfo.segment1_high =  p_segment1_high)
		 OR ( (Recinfo.segment1_high IS NULL)
		       AND (p_segment1_high IS NULL)))
	  AND ( (Recinfo.segment2_high = p_segment2_high)
		 OR ( (Recinfo.segment2_high IS NULL)
		       AND (p_segment2_high IS NULL)))
	  AND ( (Recinfo.segment3_high = p_segment3_high)
		 OR ( (Recinfo.segment3_high IS NULL)
		       AND (p_segment3_high IS NULL)))
	  AND ( (Recinfo.segment4_high = p_segment4_high)
		 OR ( (Recinfo.segment4_high IS NULL)
		       AND (p_segment4_high IS NULL)))
	  AND ( (Recinfo.segment5_high = p_segment5_high)
		 OR ( (Recinfo.segment5_high IS NULL)
		       AND (p_segment5_high IS NULL)))
	  AND ( (Recinfo.segment6_high = p_segment6_high)
		 OR ( (Recinfo.segment6_high IS NULL)
		       AND (p_segment6_high IS NULL)))
	  AND ( (Recinfo.segment7_high = p_segment7_high)
		 OR ( (Recinfo.segment7_high IS NULL)
		       AND (p_segment7_high IS NULL)))
	  AND ( (Recinfo.segment8_high = p_segment8_high)
		 OR ( (Recinfo.segment8_high IS NULL)
		       AND (p_segment8_high IS NULL)))
	  AND ( (Recinfo.segment9_high = p_segment9_high)
		 OR ( (Recinfo.segment9_high IS NULL)
		       AND (p_segment9_high IS NULL)))
	  AND ( (Recinfo.segment10_high = p_segment10_high)
		 OR ( (Recinfo.segment10_high IS NULL)
		       AND (p_segment10_high IS NULL)))
	  AND ( (Recinfo.segment11_high = p_segment11_high)
		 OR ( (Recinfo.segment11_high IS NULL)
		       AND (p_segment11_high IS NULL)))
	  AND ( (Recinfo.segment12_high = p_segment12_high)
		 OR ( (Recinfo.segment12_high IS NULL)
		       AND (p_segment12_high IS NULL)))
	  AND ( (Recinfo.segment13_high = p_segment13_high)
		 OR ( (Recinfo.segment13_high IS NULL)
		       AND (p_segment13_high IS NULL)))
	  AND ( (Recinfo.segment14_high = p_segment14_high)
		 OR ( (Recinfo.segment14_high IS NULL)
		       AND (p_segment14_high IS NULL)))
	  AND ( (Recinfo.segment15_high = p_segment15_high)
		 OR ( (Recinfo.segment15_high IS NULL)
		       AND (p_segment15_high IS NULL)))
	  AND ( (Recinfo.segment16_high = p_segment16_high)
		 OR ( (Recinfo.segment16_high IS NULL)
		       AND (p_segment16_high IS NULL)))
	  AND ( (Recinfo.segment17_high = p_segment17_high)
		 OR ( (Recinfo.segment17_high IS NULL)
		       AND (p_segment17_high IS NULL)))
	  AND ( (Recinfo.segment18_high = p_segment18_high)
		 OR ( (Recinfo.segment18_high IS NULL)
		       AND (p_segment18_high IS NULL)))
	  AND ( (Recinfo.segment19_high = p_segment19_high)
		 OR ( (Recinfo.segment19_high IS NULL)
		       AND (p_segment19_high IS NULL)))
	  AND ( (Recinfo.segment20_high = p_segment20_high)
		 OR ( (Recinfo.segment20_high IS NULL)
		       AND (p_segment20_high IS NULL)))
	  AND ( (Recinfo.segment21_high = p_segment21_high)
		 OR ( (Recinfo.segment21_high IS NULL)
		       AND (p_segment21_high IS NULL)))
	  AND ( (Recinfo.segment22_high = p_segment22_high)
		 OR ( (Recinfo.segment22_high IS NULL)
		       AND (p_segment22_high IS NULL)))
	  AND ( (Recinfo.segment23_high = p_segment23_high)
		 OR ( (Recinfo.segment23_high IS NULL)
		       AND (p_segment23_high IS NULL)))
	  AND ( (Recinfo.segment24_high = p_segment24_high)
		 OR ( (Recinfo.segment24_high IS NULL)
		       AND (p_segment24_high IS NULL)))
	  AND ( (Recinfo.segment25_high = p_segment25_high)
		 OR ( (Recinfo.segment25_high IS NULL)
		       AND (p_segment25_high IS NULL)))
	  AND ( (Recinfo.segment26_high = p_segment26_high)
		 OR ( (Recinfo.segment26_high IS NULL)
		       AND (p_segment26_high IS NULL)))
	  AND ( (Recinfo.segment27_high = p_segment27_high)
		 OR ( (Recinfo.segment27_high IS NULL)
		       AND (p_segment27_high IS NULL)))
	  AND ( (Recinfo.segment28_high = p_segment28_high)
		 OR ( (Recinfo.segment28_high IS NULL)
		       AND (p_segment28_high IS NULL)))
	  AND ( (Recinfo.segment29_high = p_segment29_high)
		 OR ( (Recinfo.segment29_high IS NULL)
		       AND (p_segment29_high IS NULL)))
	  AND ( (Recinfo.segment30_high = p_segment30_high)
		 OR ( (Recinfo.segment30_high IS NULL)
		       AND (p_segment30_high IS NULL)))
	  AND ( (Recinfo.context = p_context)
		 OR ( (Recinfo.context IS NULL)
		       AND (p_context IS NULL)))
	  AND ( (Recinfo.attribute1 = p_attribute1)
		 OR ( (Recinfo.attribute1 IS NULL)
		       AND (p_attribute1 IS NULL)))
	  AND ( (Recinfo.attribute2 = p_attribute2)
		 OR ( (Recinfo.attribute2 IS NULL)
		       AND (p_attribute2 IS NULL)))
	  AND ( (Recinfo.attribute3 = p_attribute3)
		 OR ( (Recinfo.attribute3 IS NULL)
		       AND (p_attribute3 IS NULL)))
	  AND ( (Recinfo.attribute4 = p_attribute4)
		 OR ( (Recinfo.attribute4 IS NULL)
		       AND (p_attribute4 IS NULL)))
	  AND ( (Recinfo.attribute5 = p_attribute5)
		 OR ( (Recinfo.attribute5 IS NULL)
		       AND (p_attribute5 IS NULL)))
	  AND ( (Recinfo.attribute6 = p_attribute6)
		 OR ( (Recinfo.attribute6 IS NULL)
		       AND (p_attribute6 IS NULL)))
	  AND ( (Recinfo.attribute7 = p_attribute7)
		 OR ( (Recinfo.attribute7 IS NULL)
		       AND (p_attribute7 IS NULL)))
	  AND ( (Recinfo.attribute8 = p_attribute8)
		 OR ( (Recinfo.attribute8 IS NULL)
		       AND (p_attribute8 IS NULL)))
	  AND ( (Recinfo.attribute9 = p_attribute9)
		 OR ( (Recinfo.attribute9 IS NULL)
		       AND (p_attribute9 IS NULL)))
	  AND ( (Recinfo.attribute10 = p_attribute10)
		 OR ( (Recinfo.attribute10 IS NULL)
		       AND (p_attribute10 IS NULL)))
	)
  THEN
    Null;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  --
EXCEPTION
  --
  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_row_locked := FND_API.G_FALSE;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
END Lock_Row;
/*-------------------------------------------------------------------------*/




/*==========================================================================+
 |                       PROCEDURE Update_Row                               |
 +==========================================================================*/

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
  p_Last_Update_Date          IN       DATE,
  p_Last_Updated_By           IN       NUMBER,
  p_Last_Update_Login         IN       NUMBER
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
BEGIN
  --
  SAVEPOINT Update_Row_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  UPDATE psb_account_position_set_lines
  SET
       line_sequence_id                =     p_Line_Sequence_Id,
       account_position_set_id         =     p_Account_Position_Set_Id,
       description                     =     p_Description,
       business_group_id               =     p_Business_Group_Id,
       attribute_id                    =     p_Attribute_Id,
       include_or_exclude_type         =     p_Include_Or_Exclude_Type,
       segment1_low                    =     p_Segment1_Low,
       segment2_low                    =     p_Segment2_Low,
       segment3_low                    =     p_Segment3_Low,
       segment4_low                    =     p_Segment4_Low,
       segment5_low                    =     p_Segment5_Low,
       segment6_low                    =     p_Segment6_Low,
       segment7_low                    =     p_Segment7_Low,
       segment8_low                    =     p_Segment8_Low,
       segment9_low                    =     p_Segment9_Low,
       segment10_low                   =     p_Segment10_Low,
       segment11_low                   =     p_Segment11_Low,
       segment12_low                   =     p_Segment12_Low,
       segment13_low                   =     p_Segment13_Low,
       segment14_low                   =     p_Segment14_Low,
       segment15_low                   =     p_Segment15_Low,
       segment16_low                   =     p_Segment16_Low,
       segment17_low                   =     p_Segment17_Low,
       segment18_low                   =     p_Segment18_Low,
       segment19_low                   =     p_Segment19_Low,
       segment20_low                   =     p_Segment20_Low,
       segment21_low                   =     p_Segment21_Low,
       segment22_low                   =     p_Segment22_Low,
       segment23_low                   =     p_Segment23_Low,
       segment24_low                   =     p_Segment24_Low,
       segment25_low                   =     p_Segment25_Low,
       segment26_low                   =     p_Segment26_Low,
       segment27_low                   =     p_Segment27_Low,
       segment28_low                   =     p_Segment28_Low,
       segment29_low                   =     p_Segment29_Low,
       segment30_low                   =     p_Segment30_Low,
       segment1_high                   =     p_Segment1_High,
       segment2_high                   =     p_Segment2_High,
       segment3_high                   =     p_Segment3_High,
       segment4_high                   =     p_Segment4_High,
       segment5_high                   =     p_Segment5_High,
       segment6_high                   =     p_Segment6_High,
       segment7_high                   =     p_Segment7_High,
       segment8_high                   =     p_Segment8_High,
       segment9_high                   =     p_Segment9_High,
       segment10_high                  =     p_Segment10_High,
       segment11_high                  =     p_Segment11_High,
       segment12_high                  =     p_Segment12_High,
       segment13_high                  =     p_Segment13_High,
       segment14_high                  =     p_Segment14_High,
       segment15_high                  =     p_Segment15_High,
       segment16_high                  =     p_Segment16_High,
       segment17_high                  =     p_Segment17_High,
       segment18_high                  =     p_Segment18_High,
       segment19_high                  =     p_Segment19_High,
       segment20_high                  =     p_Segment20_High,
       segment21_high                  =     p_Segment21_High,
       segment22_high                  =     p_Segment22_High,
       segment23_high                  =     p_Segment23_High,
       segment24_high                  =     p_Segment24_High,
       segment25_high                  =     p_Segment25_High,
       segment26_high                  =     p_Segment26_High,
       segment27_high                  =     p_Segment27_High,
       segment28_high                  =     p_Segment28_High,
       segment29_high                  =     p_Segment29_High,
       segment30_high                  =     p_Segment30_High,
       context                         =     p_Context,
       attribute1                      =     p_Attribute1,
       attribute2                      =     p_Attribute2,
       attribute3                      =     p_Attribute3,
       attribute4                      =     p_Attribute4,
       attribute5                      =     p_Attribute5,
       attribute6                      =     p_Attribute6,
       attribute7                      =     p_Attribute7,
       attribute8                      =     p_Attribute8,
       attribute9                      =     p_Attribute9,
       attribute10                     =     p_Attribute10,
       last_update_date                =     p_Last_Update_Date,
       last_updated_by                 =     p_Last_Updated_By,
       last_update_login               =     p_Last_Update_Login
  WHERE rowid = p_Row_Id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND ;
  END IF;
  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
END Update_Row;
/*-------------------------------------------------------------------------*/




/*==========================================================================+
 |                       PROCEDURE Delete_Row                               |
 +==========================================================================*/

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
  p_Row_Id                    IN       VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Delete_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_line_sequence_id    psb_account_position_set_lines.line_sequence_id%TYPE;
  --
BEGIN
  --
  SAVEPOINT Delete_Row_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  --
  -- Deleting dependent detail records from psb_position_set_line_values.
  -- ( To maintain ISOLATED master-detail form relation also. )
  -- Get the line_sequence_id to perform the delete.
  --
  SELECT line_sequence_id INTO l_line_sequence_id
  FROM   psb_account_position_set_lines
  WHERE  rowid = p_Row_Id ;

  DELETE psb_position_set_line_values
  WHERE  line_sequence_id = l_line_sequence_id ;

  --
  -- Deleting the record in psb_account_position_sets.
  --
  DELETE psb_account_position_set_lines
  WHERE  rowid = p_Row_Id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND ;
  END IF;
  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
END Delete_Row;
/*-------------------------------------------------------------------------*/


END PSB_Acct_Position_Set_Line_PVT;

/
