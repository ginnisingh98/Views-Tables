--------------------------------------------------------
--  DDL for Package Body PSB_WS_DISTRIBUTION_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_DISTRIBUTION_RULES_PVT" AS
/* $Header: PSBVWDRB.pls 120.2 2005/07/13 11:30:49 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_WS_Distribution_Rules_PVT';

  g_chr10 CONSTANT VARCHAR2(1) := FND_GLOBAL.Newline;

  G_DBUG              VARCHAR2(2000) := 'start';

PROCEDURE Pass_Rule_ID ( p_rule_id IN NUMBER) AS
  BEGIN
    g_rule_id := p_rule_id;
  END Pass_Rule_ID;

/*=======================================================================+
 |                       PROCEDURE Insert_Row                            |
 +=======================================================================*/

PROCEDURE Insert_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  p_Row_Id                    IN OUT  NOCOPY   VARCHAR2,
  --
  p_Distribution_Rule_Line_Id IN       NUMBER,
  p_Distribution_Rule_Id      IN       NUMBER,
  p_Budget_Group_Id           IN       NUMBER,
  p_distribute_flag           IN       VARCHAR2,
  p_distribute_all_level_flag IN       VARCHAR2,
  p_download_flag             IN       VARCHAR2,
  p_download_all_level_flag   IN       VARCHAR2,
  p_year_category_type        IN       VARCHAR2,
  p_attribute1                in varchar2,
  p_attribute2                in varchar2,
  p_attribute3                in varchar2,
  p_attribute4                in varchar2,
  p_attribute5                in varchar2,
  p_attribute6                in varchar2,
  p_attribute7                in varchar2,
  p_attribute8                in varchar2,
  p_attribute9                in varchar2,
  p_attribute10               in varchar2,
  p_context                   in varchar2,
  p_mode                      in varchar2

)
IS

  CURSOR C IS
    SELECT rowid
    FROM   psb_ws_distribution_rule_lines
    WHERE  distribution_rule_line_id = p_distribution_rule_line_id ;

  --
    P_LAST_UPDATE_DATE DATE;
    P_LAST_UPDATED_BY NUMBER;
    P_LAST_UPDATE_LOGIN NUMBER;
  -- variables --
    l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
    l_api_version         CONSTANT NUMBER         :=  1.0;
    l_return_status       VARCHAR2(1);
  --
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
  P_LAST_UPDATE_DATE := SYSDATE;
  if(P_MODE = 'I') then
    P_LAST_UPDATED_BY := 1;
    P_LAST_UPDATE_LOGIN := 0;
  elsif (P_MODE = 'R') then
    P_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if P_LAST_UPDATED_BY is NULL then
      P_LAST_UPDATED_BY := -1;
    end if;
    P_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if P_LAST_UPDATE_LOGIN is NULL then
      P_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    FND_MSG_PUB.Add ;
    raise FND_API.G_EXC_ERROR;
  end if;
  --

  INSERT INTO psb_ws_distribution_rule_lines
	 (    distribution_rule_line_id,
	      distribution_rule_id,
	      budget_group_id,
	      distribute_flag,
	      distribute_all_level_flag,
	      download_flag ,
	      download_all_level_flag ,
	      year_category_type,
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
	      context,
	      creation_date,
	      created_by,
	      last_update_date,
	      last_updated_by,
	      last_update_login
	 )
	 VALUES
	 (    p_distribution_rule_line_id,
	      p_Distribution_rule_id,
	      p_budget_group_id,
	      p_distribute_flag,
	      p_distribute_all_level_flag,
	      p_download_flag ,
	      p_download_all_level_flag ,
	      p_year_category_type,
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
	      p_context,
	      p_last_update_date,
	      p_last_updated_by,
	      p_last_update_date,
	      p_last_updated_by,
	      p_last_update_login


	 );
  OPEN C;
  FETCH C INTO p_Row_Id;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  CLOSE C;
  --

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



/*==========================================================================+
 |                       PROCEDURE Lock_Row                                 |
 +==========================================================================*/

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
  p_Distribution_Rule_Line_Id IN       NUMBER,
  p_Distribution_Rule_Id      IN    NUMBER,
  p_Budget_Group_Id           IN       NUMBER,
  p_distribute_flag           IN       VARCHAR2,
  p_distribute_all_level_flag IN       VARCHAR2,
  p_download_flag             IN       VARCHAR2,
  p_download_all_level_flag   IN       VARCHAR2,
  p_year_category_type        IN       VARCHAR2,
  p_attribute1  IN varchar2,
  p_attribute2  IN varchar2,
  p_attribute3  IN varchar2,
  p_attribute4  IN varchar2,
  p_attribute5  IN varchar2,
  p_attribute6  IN varchar2,
  p_attribute7  IN varchar2,
  p_attribute8  IN varchar2,
  p_attribute9  IN varchar2,
  p_attribute10 IN varchar2,
  p_context     IN varchar2,
  --
  p_row_locked                OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  l_return_status VARCHAR2(1);

  --
  Counter NUMBER;
  CURSOR C IS
       SELECT distribution_rule_line_id,
	      distribution_rule_id,
	      budget_group_id,
	      distribute_flag,
	      distribute_all_level_flag,
	      download_flag,
	      download_all_level_flag ,
	      year_category_type,
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
      context
       FROM   psb_ws_distribution_rule_lines
       WHERE  distribution_rule_line_id = p_distribution_rule_line_id
       FOR UPDATE of distribution_rule_id NOWAIT;
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
  --
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    FND_MSG_PUB.Add;
    -- For bug # 2396565 : Following statement comented since Cursor is already closed
    -- CLOSE c;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  CLOSE C;
  IF
  (
	  ( Recinfo.distribution_rule_line_id =  p_distribution_rule_line_id )
      AND ( Recinfo.distribution_rule_id =  p_distribution_rule_id )
      AND ( Recinfo.budget_group_id =  p_budget_group_id)
      AND ( Recinfo.distribute_flag =  p_distribute_flag )
  --
      AND ((recinfo.distribute_all_level_flag = P_distribute_all_level_flag)
	   OR ((recinfo.distribute_all_level_flag is null)
	       AND (P_distribute_all_level_flag is null)))
      AND ((recinfo.download_flag             = P_download_flag)
	   OR ((recinfo.download_flag is null)
	       AND (P_download_flag is null)))
      AND ((recinfo.download_all_level_flag = P_download_all_level_flag)
	   OR ((recinfo.download_all_level_flag is null)
	       AND (P_download_all_level_flag is null)))
      AND ((recinfo.ATTRIBUTE1 = P_ATTRIBUTE1)
	   OR ((recinfo.ATTRIBUTE1 is null)
	       AND (P_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = P_ATTRIBUTE2)
	   OR ((recinfo.ATTRIBUTE2 is null)
	       AND (P_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = P_ATTRIBUTE3)
	   OR ((recinfo.ATTRIBUTE3 is null)
	       AND (P_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = P_ATTRIBUTE4)
	   OR ((recinfo.ATTRIBUTE4 is null)
	       AND (P_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = P_ATTRIBUTE5)
	   OR ((recinfo.ATTRIBUTE5 is null)
	       AND (P_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = P_ATTRIBUTE6)
	   OR ((recinfo.ATTRIBUTE6 is null)
	       AND (P_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = P_ATTRIBUTE7)
	   OR ((recinfo.ATTRIBUTE7 is null)
	       AND (P_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = P_ATTRIBUTE8)
	   OR ((recinfo.ATTRIBUTE8 is null)
	       AND (P_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = P_ATTRIBUTE9)
	   OR ((recinfo.ATTRIBUTE9 is null)
	       AND (P_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = P_ATTRIBUTE10)
	   OR ((recinfo.ATTRIBUTE10 is null)
	       AND (P_ATTRIBUTE10 is null)))
      AND ((recinfo.CONTEXT = P_CONTEXT)
	   OR ((recinfo.CONTEXT is null)
	       AND (P_CONTEXT is null)))
  --
  )
  THEN
    NULL ;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED') ;
    FND_MSG_PUB.Add ;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  --
/*--
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
*/
  --
EXCEPTION
  --
  WHEN App_Exception.Record_Lock_Exception THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_row_locked    := FND_API.G_FALSE ;
    p_return_status := FND_API.G_RET_STS_ERROR ;
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
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
/* ----------------------------------------------------------------------- */




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
  p_Distribution_Rule_Line_Id IN       NUMBER,
  p_Distribution_Rule_Id      IN       NUMBER,
  p_Budget_Group_Id           IN       NUMBER,
  p_distribute_flag           IN       VARCHAR2,
  p_distribute_all_level_flag IN       VARCHAR2,
  p_download_flag             IN       VARCHAR2,
  p_download_all_level_flag   IN       VARCHAR2,
  p_year_category_type        IN       VARCHAR2,
  p_attribute1  in varchar2,
  p_attribute2  in varchar2,
  p_attribute3  in varchar2,
  p_attribute4  in varchar2,
  p_attribute5  in varchar2,
  p_attribute6  in varchar2,
  p_attribute7  in varchar2,
  p_attribute8  in varchar2,
  p_attribute9  in varchar2,
  p_attribute10 in varchar2,
  p_context     in varchar2,
  p_mode        in varchar2

)
IS
    P_LAST_UPDATE_DATE DATE;
    P_LAST_UPDATED_BY NUMBER;
    P_LAST_UPDATE_LOGIN NUMBER;
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  l_return_status VARCHAR2(1);
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

  P_LAST_UPDATE_DATE := SYSDATE;
  if(P_MODE = 'I') then
    P_LAST_UPDATED_BY := 1;
    P_LAST_UPDATE_LOGIN := 0;
  elsif (P_MODE = 'R') then
    P_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if P_LAST_UPDATED_BY is NULL then
      P_LAST_UPDATED_BY := -1;
    end if;
    P_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if P_LAST_UPDATE_LOGIN is NULL then
      P_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    FND_MSG_PUB.Add ;
    raise FND_API.G_EXC_ERROR ;
  end if;
  --
  UPDATE psb_ws_distribution_rule_lines
  SET
	distribution_rule_id   =  p_distribution_rule_id,
	Budget_Group_Id        =  p_Budget_Group_Id      ,
	distribute_flag        = p_distribute_flag            ,
	distribute_all_level_flag = p_distribute_all_level_flag  ,
	download_flag          = p_download_flag              ,
	download_all_level_flag   = p_download_all_level_flag ,
	year_category_type    =   p_year_category_type       ,
    attribute1 = p_attribute1,
    attribute2 = p_attribute2,
    attribute3 = p_attribute3,
    attribute4 = p_attribute4,
    attribute5 = p_attribute5,
    attribute6 = p_attribute6,
    attribute7 = p_attribute7,
    attribute8 = p_attribute8,
    attribute9 = p_attribute9,
    attribute10 = p_attribute10,
    context = p_context,
    last_update_date = p_last_update_date,
    last_updated_by = p_last_updated_by,
    last_update_login = p_last_update_login
  WHERE distribution_rule_line_id = p_distribution_rule_line_id;

  IF (SQL%NOTFOUND) THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  --
  --
  -- Standard check of p_commit.

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  --
EXCEPTION

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
/* ----------------------------------------------------------------------- */




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
  p_Distribution_Rule_Line_Id IN       NUMBER
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Delete_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
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
  -- Deleting the record in psb_ws_distribution_rule_lines.
  --
  DELETE psb_ws_distribution_rule_lines
  WHERE  distribution_rule_line_id  = p_distribution_rule_line_id;

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
/* ----------------------------------------------------------------------- */





/*==========================================================================+
 |                       PROCEDURE Check_Unique                             |
 +==========================================================================*/

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
  p_Row_Id                    IN       VARCHAR2,
  p_Name                      IN       VARCHAR2,
  p_Return_Value              OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Unique';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_tmp VARCHAR2(1);

  CURSOR c IS
    SELECT '1'
    FROM   psb_ws_distribution_rules
    WHERE  name = p_name
    AND    ( (p_Row_Id IS NULL)
	      OR (RowId <> p_Row_Id) );
BEGIN
  --
  SAVEPOINT Check_Unique_Pvt ;
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

  -- Checking the Psb_set_relations table for references.
  OPEN c;
  FETCH c INTO l_tmp;
  --
  -- p_Return_Value tells whether references exist or not.
  --
  IF l_tmp IS NULL THEN
    p_Return_Value := 'FALSE';
  ELSE
    p_Return_Value := 'TRUE';
  END IF;

  CLOSE c;
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
    ROLLBACK TO Check_Unique_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Check_Unique_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Check_Unique_Pvt ;
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
END Check_Unique;
/* ----------------------------------------------------------------------- */



PROCEDURE Distribution_Insert_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  p_Row_Id                    IN OUT  NOCOPY   VARCHAR2,
  --
  p_Distribution_Id           IN       NUMBER,
  p_Distribution_Rule_Id      IN       NUMBER,
  p_Worksheet_Id              IN       NUMBER,
  p_distribution_date         IN       DATE,
  p_distributed_flag          IN       VARCHAR2,
  p_distribution_instructions IN       VARCHAR2,
  p_distribution_option_flag  IN       VARCHAR2,
  p_revision_option_flag      IN       VARCHAR2,
  p_mode                      IN       VARCHAR2
)
IS

  CURSOR C IS
    SELECT rowid
    FROM   psb_ws_distributions
    WHERE  distribution_id = p_distribution_id ;

  --
    P_LAST_UPDATE_DATE DATE;
    P_LAST_UPDATED_BY NUMBER;
    P_LAST_UPDATE_LOGIN NUMBER;
  -- variables --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Distribution_Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  l_return_status       VARCHAR2(1);
  --
BEGIN
  --
  SAVEPOINT Distribution_Insert_Row_Pvt ;
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
  P_LAST_UPDATE_DATE := SYSDATE;
  if(P_MODE = 'I') then
    P_LAST_UPDATED_BY := 1;
    P_LAST_UPDATE_LOGIN := 0;
  elsif (P_MODE = 'R') then
    P_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if P_LAST_UPDATED_BY is NULL then
      P_LAST_UPDATED_BY := -1;
    end if;
    P_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if P_LAST_UPDATE_LOGIN is NULL then
      P_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    FND_MSG_PUB.Add ;
    raise FND_API.G_EXC_ERROR;
  end if;
  --

  INSERT INTO psb_ws_distributions
	 (    distribution_id,
	      distribution_rule_id,
	      worksheet_id,
	      distribution_date,
	      distributed_flag,
	      distribution_instructions,
	      distribution_option_flag,
	      revision_option_flag,
	      creation_date,
	      created_by,
	      last_update_date,
	      last_updated_by,
	      last_update_login
	 )
	 VALUES
	 (    p_distribution_id,
	      p_Distribution_rule_id,
	      p_worksheet_id,
	      p_distribution_date,
	      p_distributed_flag,
	      p_distribution_instructions,
	      p_distribution_option_flag,
	      p_revision_option_flag,
	      p_last_update_date,
	      p_last_updated_by,
	      p_last_update_date,
	      p_last_updated_by,
	      p_last_update_login

	 );
  OPEN C;
  FETCH C INTO p_Row_Id;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  CLOSE C;
  --

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
    ROLLBACK TO Distribution_Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Distribution_Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Distribution_Insert_Row_Pvt ;
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
END Distribution_Insert_Row;
/*-------------------------------------------------------------------------*/

PROCEDURE Rules_Insert_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  p_Row_Id                    IN OUT  NOCOPY   VARCHAR2,
  --
  p_Distribution_Rule_Id      IN        NUMBER,
  p_Budget_Group_Id           IN        NUMBER,
  p_Name                      IN       VARCHAR2,
  p_mode                      in varchar2

)
IS

  CURSOR C IS
    SELECT rowid
    FROM   psb_ws_distribution_rules
    WHERE  distribution_rule_id = p_distribution_rule_id ;

  --
    P_LAST_UPDATE_DATE DATE;
    P_LAST_UPDATED_BY NUMBER;
    P_LAST_UPDATE_LOGIN NUMBER;
  -- variables --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Rules_Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  l_return_status       VARCHAR2(1);
  --
BEGIN
  --
  SAVEPOINT Rules_Insert_Row_Pvt ;
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
  P_LAST_UPDATE_DATE := SYSDATE;
  if(P_MODE = 'I') then
    P_LAST_UPDATED_BY := 1;
    P_LAST_UPDATE_LOGIN := 0;
  elsif (P_MODE = 'R') then
    P_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if P_LAST_UPDATED_BY is NULL then
      P_LAST_UPDATED_BY := -1;
    end if;
    P_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if P_LAST_UPDATE_LOGIN is NULL then
      P_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    FND_MSG_PUB.Add ;
    raise FND_API.G_EXC_ERROR;
  end if;
  --

  INSERT INTO psb_ws_distribution_rules
	 (    distribution_rule_id,
	      name,
	      budget_group_id,
	      creation_date,
	      created_by,
	      last_update_date,
	      last_updated_by,
	      last_update_login
	 )
	 VALUES
	 (    p_distribution_rule_id,
	      p_Name,
	      p_budget_group_id,
	      p_last_update_date,
	      p_last_updated_by,
	      p_last_update_date,
	      p_last_updated_by,
	      p_last_update_login

	 );
  OPEN C;
  FETCH C INTO p_Row_Id;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  CLOSE C;
  --

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
    ROLLBACK TO Rules_Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Rules_Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Rules_Insert_Row_Pvt ;
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
END Rules_Insert_Row;
/*==========================================================================+
 |                       PROCEDURE Delete_Row                               |
 +==========================================================================*/

PROCEDURE Rules_Delete_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Distribution_Rule_Id      IN       NUMBER
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Delete_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_ws_count            NUMBER;
BEGIN
  --
  SAVEPOINT Rules_Delete_Row_Pvt ;
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

  SELECT count(*) INTO l_ws_count
    FROM psb_ws_distributions
   WHERE distribution_rule_id = p_distribution_rule_id;

  IF (l_ws_count <> 0) THEN
    FND_MESSAGE.SET_NAME('PSB', 'PSB_RULE_IS_DISTRIBUTED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  --
  -- Deleting the record in psb_ws_distribution_rule_lines and rules.
  --
  DELETE psb_ws_distribution_rules
    WHERE  distribution_rule_id  = p_distribution_rule_id;

  DELETE psb_ws_distribution_rule_lines
    WHERE distribution_rule_id  = p_distribution_rule_id;

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
    ROLLBACK TO Rules_Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Rules_Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Rules_Delete_Row_Pvt ;
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
END Rules_Delete_Row;
/*-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*/



PROCEDURE Copy_Rule
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_Source_Distribution_Rule_Id IN      NUMBER,
  p_Source_Budget_Group       IN        NUMBER,
  p_Target_Rule_Name          IN        VARCHAR2,
  p_Target_Rule_ID            OUT  NOCOPY       NUMBER,
  p_mode                      in varchar2

)
IS

  CURSOR l_from_distr_lines_csr IS
    SELECT budget_group_id ,
	   distribute_flag ,
	   distribute_all_level_flag ,
	   download_flag ,
	   download_all_level_flag ,
	   year_category_type ,
	   attribute1 ,
	   attribute2 ,
	   attribute3 ,
	   attribute4 ,
	   attribute5 ,
	   attribute6 ,
	   attribute7 ,
	   attribute8 ,
	   attribute9 ,
	   attribute10 ,
	   context
    FROM psb_ws_distribution_rule_lines
   WHERE distribution_rule_id = p_Source_Distribution_Rule_Id ;

  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Copy_Rule';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_dist_rule_id        NUMBER ;
  l_return_status       VARCHAR2(1) ;
  l_rowid               VARCHAR2(100) ;
  l_dist_rule_line_id   NUMBER ;
  --
BEGIN
  -- Standard Start of API savepoint
g_dbug := g_dbug || ' copy rule';

  SAVEPOINT     Copy_Rule;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  l_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  -- ... insert distribution rules

  SELECT psb_ws_distribution_rules_s.NEXTVAL
    INTO l_dist_rule_id FROM dual;


  RULES_INSERT_ROW (
     p_api_version              => 1.0,
     p_init_msg_list            => fnd_api.g_false,
     p_commit                   => fnd_api.g_false,
     p_validation_level         => fnd_api.g_valid_level_full,
     p_return_status            => l_return_status,
     p_msg_count                => p_msg_count,
     p_msg_data                 => p_msg_data,
     p_row_id                    => l_rowid,
     p_distribution_rule_id     => l_dist_rule_id,
     p_name                     => p_target_rule_name,
     p_budget_group_id          => p_Source_Budget_Group ,
     p_mode                      => 'R'
    );

  -- ... insert distribution rule lines
g_dbug := g_dbug || g_chr10 || 'rule id is: ' || to_char(l_dist_rule_id);

    FOR lines_rec IN l_from_distr_lines_csr LOOP


     SELECT psb_ws_distribute_rule_lines_s.NEXTVAL
       INTO l_dist_rule_line_id FROM dual;

     INSERT_ROW (
      p_api_version              => 1.0,
      p_init_msg_list            => fnd_api.g_false,
      p_commit                   => fnd_api.g_false,
      p_validation_level         => fnd_api.g_valid_level_full,
      p_return_status            => l_return_status,
      p_msg_count                => p_msg_count,
      p_msg_data                 => p_msg_data,
      p_row_id                    => l_rowid,
      p_distribution_rule_line_id => l_dist_rule_line_id,
      p_distribution_rule_id      => l_dist_rule_id,
      p_budget_group_id           =>  lines_rec.budget_group_id,
      p_distribute_flag           => lines_rec.distribute_flag,
      p_distribute_all_level_flag => lines_rec.distribute_all_level_flag,
      p_download_flag             => lines_rec.download_flag  ,
      p_download_all_level_flag   => lines_rec.download_all_level_flag  ,
      p_year_category_type        => lines_rec.year_category_type ,
      p_attribute1                => lines_rec.attribute1,
      p_attribute2                => lines_rec.attribute2,
      p_attribute3                => lines_rec.attribute3,
      p_attribute4                => lines_rec.attribute4,
      p_attribute5                => lines_rec.attribute5,
      p_attribute6                => lines_rec.attribute6,
      p_attribute7                => lines_rec.attribute7,
      p_attribute8                => lines_rec.attribute8,
      p_attribute9                => lines_rec.attribute9,
      p_attribute10               => lines_rec.attribute10,
      p_context                   => lines_rec.context,
      p_mode                      => 'R'
    );

   --
g_dbug := g_dbug || g_chr10 || 'rule line id is: ' || to_char(l_dist_rule_line_id);
    END LOOP;
  --
    p_Target_Rule_ID := l_dist_rule_id;
g_dbug := g_dbug || g_chr10 || 'rule  id is: ' || to_char(l_dist_rule_id);
  --
EXCEPTION

   when FND_API.G_EXC_ERROR then
     --
     rollback to Copy_Rule;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     rollback to Copy_Rule;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when OTHERS then
     --
     rollback to Copy_Rule ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
END Copy_Rule;

--
-- FUNCTIONS
--

 FUNCTION Get_Rule_Id RETURN NUMBER IS
  BEGIN
     Return g_rule_id;
  END Get_Rule_Id;





  -- Get Debug Information

  -- This Module is used to retrieve Debug Information for Funds Checker. It
  -- prints Debug Information when run as a Batch Process from SQL*Plus. For
  -- the Debug Information to be printed on the Screen, the SQL*Plus parameter
  -- 'Serveroutput' should be set to 'ON'

  FUNCTION get_debug RETURN VARCHAR2 IS

  BEGIN

    return(g_dbug);

  END get_debug;

/* ----------------------------------------------------------------------- */

END PSB_WS_Distribution_Rules_PVT;

/
