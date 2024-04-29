--------------------------------------------------------
--  DDL for Package Body PSB_ACCOUNT_POSITION_SET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_ACCOUNT_POSITION_SET_PVT" AS
/* $Header: PSBVSETB.pls 115.10 2002/11/12 11:18:13 msuram ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_Account_Position_Set_Pvt';

  -- The flag determines whether to print debug information or not.
  g_debug_flag        VARCHAR2(1) := 'N' ;


/* ---------------------- Private Routine prototypes  -----------------------*/

  PROCEDURE  pd
  (
    p_message                   IN       VARCHAR2
  ) ;

/* ------------------ End Private Routines prototypes  ----------------------*/



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
  --
  p_row_id                    IN OUT  NOCOPY   VARCHAR2,
  p_account_position_set_id   IN OUT  NOCOPY   NUMBER,
  p_name                      IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  p_use_in_budget_group_flag  IN       VARCHAR2 := FND_API.G_MISS_CHAR,
  p_data_extract_id           IN       NUMBER,
  p_budget_group_id           IN       NUMBER := FND_API.G_MISS_NUM,
  p_global_or_local_type      IN       VARCHAR2,
  p_account_or_position_type  IN       VARCHAR2,
  p_attribute_selection_type  IN       VARCHAR2,
  p_business_group_id         IN       NUMBER,
  p_last_update_date          IN       DATE,
  p_last_updated_by           IN       NUMBER,
  p_last_update_login         IN       NUMBER,
  p_created_by                IN       NUMBER,
  p_creation_date             IN       DATE
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  CURSOR C IS
    SELECT rowid
    FROM   psb_account_position_sets
    WHERE  account_position_set_id = p_account_position_set_id;

  CURSOR C2 IS
    SELECT psb_account_position_sets_s.nextval
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

  IF (p_account_position_set_id is NULL) THEN
    OPEN C2;

    FETCH C2 INTO p_account_position_set_id;
    CLOSE C2;
  END IF;

  INSERT INTO psb_account_position_sets(
	 account_position_set_id,
	 name,
	 set_of_books_id,
	 use_in_budget_group_flag,
	 data_extract_id,
	 budget_group_id,
	 global_or_local_type,
	 account_or_position_type,
	 attribute_selection_type,
	 business_group_id,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 created_by,
	 creation_date )
      VALUES
      (
	 p_account_position_set_id,
	 p_name,
	 p_set_of_books_id,
	 DECODE(p_use_in_budget_group_flag,
		FND_API.G_MISS_CHAR, NULL,
		p_use_in_budget_group_flag),
	 p_data_extract_id,
	 DECODE(p_budget_group_id,FND_API.G_MISS_NUM,null,p_budget_group_id),
	 p_global_or_local_Type,
	 p_account_or_position_Type,
	 p_attribute_selection_Type,
	 p_business_group_Id,
	 p_last_update_date,
	 p_last_updated_by,
	 p_last_update_login,
	 p_created_by,
	 p_creation_date
      );
  OPEN C;
  FETCH C INTO p_row_id;
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
  p_row_id                    IN       VARCHAR2,
  p_account_position_set_id   IN       NUMBER,
  p_name                      IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  p_use_in_budget_group_flag  IN       VARCHAR2 := FND_API.G_MISS_CHAR,
  p_data_extract_id           IN       NUMBER,
  p_budget_group_id           IN       NUMBER := FND_API.G_MISS_NUM,
  p_global_or_local_type      IN       VARCHAR2,
  p_account_or_position_type  IN       VARCHAR2,
  p_attribute_selection_type  IN       VARCHAR2,
  p_business_group_id         IN       NUMBER,
  --
  p_row_locked                OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  Counter NUMBER;
  CURSOR C IS
       SELECT *
       FROM   psb_account_position_sets
       WHERE  rowid = p_row_id
       FOR UPDATE of Account_Position_Set_Id NOWAIT;
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
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  CLOSE C;

  IF
  (
	 (Recinfo.account_position_set_id =  p_account_position_set_id)

	  AND ( (Recinfo.name =  p_name)
		 OR ( (Recinfo.name IS NULL)
		       AND (p_name IS NULL)))

	  AND ( (Recinfo.set_of_books_id =  p_set_of_books_id)
		 OR ( (Recinfo.set_of_books_id IS NULL)
		       AND (p_set_of_books_id IS NULL)))

	  AND ( (Recinfo.use_in_budget_group_flag =  p_use_in_budget_group_flag)
		 OR ( (Recinfo.use_in_budget_group_flag IS NULL)
		       AND (p_use_in_budget_group_flag IS NULL))
		 OR ((Recinfo.use_in_budget_group_flag is NULL)
		       AND (p_use_in_budget_group_flag = FND_API.G_MISS_NUM )))

	  AND ( (Recinfo.data_extract_id = p_data_extract_id)
		 OR ( (Recinfo.data_extract_id IS NULL)
		       AND (p_data_extract_id IS NULL)))

	  AND ( (Recinfo.budget_group_id = p_budget_group_id)
		 OR ( (Recinfo.budget_group_id IS NULL)
		       AND (p_budget_group_id IS NULL))
		 OR ((Recinfo.budget_group_id is null)
	       AND (p_budget_group_id = FND_API.G_MISS_NUM )))

	  AND ( (Recinfo.global_or_local_type = p_global_or_local_type)
		 OR ( (Recinfo.global_or_local_type IS NULL)
		       AND (p_global_or_local_type IS NULL)))

	  AND ( (Recinfo.account_or_position_type = p_account_or_position_type)
		 OR ( (Recinfo.account_or_position_type IS NULL)
		       AND (p_account_or_position_type IS NULL)))

	  AND ( (Recinfo.attribute_selection_type = p_attribute_selection_type)
		 OR ( (Recinfo.attribute_selection_type IS NULL)
		       AND (p_attribute_selection_type IS NULL)))

	  AND ( (Recinfo.business_group_id =  p_business_group_id)
		 OR (Recinfo.business_group_id IS NULL)
		     AND (p_business_group_id IS NULL)))

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
  p_row_id                    IN       VARCHAR2,
  p_account_position_set_id   IN       NUMBER,
  p_name                      IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  p_use_in_budget_group_flag  IN       VARCHAR2 := FND_API.G_MISS_CHAR,
  p_data_extract_id           IN       NUMBER,
  p_budget_group_id           IN       NUMBER := FND_API.G_MISS_NUM,
  p_global_or_local_type      IN       VARCHAR2,
  p_account_or_position_type  IN       VARCHAR2,
  p_attribute_selection_type  IN       VARCHAR2,
  p_business_group_id         IN       NUMBER,
  p_last_update_date          IN       DATE,
  p_last_updated_by           IN       NUMBER,
  p_last_update_login         IN       NUMBER
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

  UPDATE psb_account_position_sets
  SET
    account_position_set_id  = p_account_position_set_id,
    name                     = p_name,
    set_of_books_id          = p_set_of_books_id,
    use_in_budget_group_flag = DECODE( p_use_in_budget_group_flag,
				       FND_API.G_MISS_CHAR, NULL,
				       p_use_in_budget_group_flag),
    data_extract_id          = p_data_extract_id,
    budget_group_id          = DECODE( p_budget_group_id,
				       FND_API.G_MISS_NUM,null,
				       p_budget_group_id),
    global_or_local_type     = p_global_or_local_type,
    account_or_position_type = p_account_or_position_type,
    attribute_selection_type = p_attribute_selection_type,
    business_group_id        = p_business_group_id,
    last_update_date         = p_last_update_date,
    last_updated_by          = p_last_updated_by,
    last_update_login        = p_last_update_login
  WHERE rowid = p_row_id;

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
  p_row_id                    IN        VARCHAR2
)
IS
  --
  l_api_name                CONSTANT VARCHAR2(30)   := 'Delete_Row';
  l_api_version             CONSTANT NUMBER         :=  1.0;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_account_position_set_id
		  psb_account_position_set_lines.account_position_set_id%TYPE;
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
  END IF ;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  --
  -- Deleting dependent detail records from psb_account_position_set_lines.
  -- ( To maintain ISOLATED master-detail form relation also. )
  --

  SELECT account_position_set_id INTO l_account_position_set_id
  FROM   psb_account_position_sets
  WHERE  rowid = p_row_id ;

  --
  -- When we delete a set line, we also need to delete all records associated
  -- with Psb_position_set_line_values table. The Delete_Row API deletes
  -- not only the line_id but related child records as well.
  --
  FOR l_lines_rec IN
  (
    SELECT rowid
    FROM   psb_account_position_set_lines
    WHERE  account_position_set_id = l_account_position_set_id
  )
  LOOP
    --
    PSB_Acct_Position_Set_Line_Pvt.Delete_Row
    (
       p_api_version             =>   1.0 ,
       p_init_msg_list           =>   FND_API.G_FALSE,
       p_commit                  =>   FND_API.G_FALSE,
       p_validation_level        =>   FND_API.G_VALID_LEVEL_FULL,
       p_return_status           =>   l_return_status,
       p_msg_count               =>   l_msg_count,
       p_msg_data                =>   l_msg_data,
       --
       p_row_id                  =>   l_lines_rec.rowid
    );
    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF ;
    --
  END LOOP ;

  --
  -- Deleting the record in psb_account_position_sets.
  --
  DELETE FROM psb_account_position_sets
  WHERE rowid = p_row_id;

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
  p_row_id                    IN       VARCHAR2,
  p_name                      IN       VARCHAR2,
  p_account_or_position_type  IN       VARCHAR2,
  p_data_extract_id           IN       NUMBER,
  p_return_value              IN OUT  NOCOPY   VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Unique';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_tmp                 VARCHAR2(1);

  CURSOR c IS
    SELECT '1'
    FROM   psb_account_position_sets
    WHERE  name                     = p_name
    AND    account_or_position_type = p_account_or_position_type
    AND    ( p_data_extract_id IS NULL
	     OR
	     data_extract_id = p_data_extract_id
	   )
    AND    (
	     p_row_id IS NULL
	     OR
	     rowid <> p_row_id
	   );
  --
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

  -- p_Return_Value specifies whether unique value exists or not.
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



/*==========================================================================+
 |                       PROCEDURE Check_References                         |
 +==========================================================================*/
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
  p_account_position_set_id   IN       NUMBER,
  p_return_value              IN OUT  NOCOPY   VARCHAR2,
  p_frozen_bg_reference       IN OUT  NOCOPY   VARCHAR2
)
IS
  --
  l_api_name                  CONSTANT VARCHAR2(30)   := 'Check_References';
  l_api_version               CONSTANT NUMBER         :=  1.0;
  --
  l_tmp                                VARCHAR2(1);
  l_use_in_budget_group_flag           VARCHAR2(1);
  l_freeze_hierarchy_flag              VARCHAR2(1);
  --
  CURSOR l_check_set_relation_csr IS
    SELECT '1'
    FROM   psb_set_relations
    WHERE  account_position_set_id = p_account_position_set_id;

  CURSOR l_check_budget_group_csr IS
    SELECT '1'
    FROM   psb_budget_groups
    WHERE  root_budget_group = 'Y'
    AND    budget_group_type = 'R'
    AND    ( ps_account_position_set_id = p_account_position_set_id
	     OR
	     nps_account_position_set_id = p_account_position_set_id
	   ) ;

  CURSOR l_check_frozen_bg_csr IS
    SELECT '1'
    FROM   psb_budget_groups
    WHERE  root_budget_group = 'Y'
    AND    budget_group_type = 'R'
    AND    NVL(freeze_hierarchy_flag, 'N') = 'Y'
    AND    ( ps_account_position_set_id = p_account_position_set_id
	     OR
	     nps_account_position_set_id = p_account_position_set_id
	   ) ;
BEGIN

  /*
  p_return_value returns if the set is referenced by any entity.
  p_frozen_bg_reference returns if the set is referenced by a frozen bg.
  */

  SAVEPOINT Check_References_Pvt ;
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

  -- First check whether it has been referenced by any entity.
  OPEN  l_check_set_relation_csr;
  FETCH l_check_set_relation_csr INTO l_tmp;
  CLOSE l_check_set_relation_csr;

  IF l_tmp IS NULL THEN
    p_return_value := 'FALSE';
  ELSE
    p_return_value := 'TRUE';
  END IF;

  -- Now check if budget group top region references it.
  IF p_return_value = 'FALSE' THEN

    -- reset flag
    l_tmp := NULL;

    OPEN  l_check_budget_group_csr;
    FETCH l_check_budget_group_csr INTO l_tmp;
    CLOSE l_check_budget_group_csr;

    IF l_tmp IS NOT NULL THEN
      p_return_value := 'TRUE';
    END IF;

  END IF;

  -- Retrive use_in_budget_group_flag to return additional information through
  -- p_frozen_bg_reference parameter.
  SELECT NVL(use_in_budget_group_flag, 'N') INTO l_use_in_budget_group_flag
  FROM   psb_account_position_sets
  WHERE  account_position_set_id = p_account_position_set_id;

  IF l_use_in_budget_group_flag = 'Y'  THEN

    -- Need to check whether referenced by any frozen budget group. If yes,
    -- the set cannot be modified, otherwise the set can be performed only
    -- update operations.

    -- reset flag
    l_tmp := NULL;

    -- First check if any frozen budget group references it in the top region.
    OPEN  l_check_frozen_bg_csr;
    FETCH l_check_frozen_bg_csr INTO l_tmp;
    CLOSE l_check_frozen_bg_csr;

    IF l_tmp IS NULL THEN
      p_frozen_bg_reference := 'FALSE';
    ELSE
      p_frozen_bg_reference := 'TRUE';
    END IF;

    -- Now check if any frozen budget group references it in the account region.
    IF p_frozen_bg_reference = 'FALSE' THEN

      FOR l_budget_group_csr IN
      (
	SELECT DECODE( bg.root_budget_group, 'Y', bg.budget_group_id,
		       bg.root_budget_group_id ) as root_budget_group_id
	FROM   psb_set_relations rel,
	       psb_budget_groups bg
	WHERE  rel.account_position_set_id = p_account_position_set_id
	AND    bg.budget_group_type        = 'R'
	AND    bg.budget_group_id          = rel.budget_group_id
      )
      LOOP

	SELECT NVL(freeze_hierarchy_flag, 'N') into l_freeze_hierarchy_flag
	FROM   psb_budget_groups
	WHERE  budget_group_id = l_budget_group_csr.root_budget_group_id;

	-- Check if any referenced budget group is frozen.
	IF l_freeze_hierarchy_flag = 'Y' THEN
	  p_frozen_bg_reference := 'TRUE';
	  EXIT ;
	END IF;

      END LOOP ;

    END IF;

  END IF;
  -- End Checking references.

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
    ROLLBACK TO Check_References_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Check_References_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Check_References_Pvt ;
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
END Check_References;
/*-------------------------------------------------------------------------*/



/*==========================================================================+
 |                       PROCEDURE Copy_Position_Sets                       |
 +==========================================================================*/
--
-- This API copies position sets from a source data extract to a target data
-- extract.
--
PROCEDURE Copy_Position_Sets
(
  p_api_version             IN   NUMBER,
  p_init_msg_list           IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level        IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status           OUT  NOCOPY  VARCHAR2,
  p_msg_count               OUT  NOCOPY  NUMBER,
  p_msg_data                OUT  NOCOPY  VARCHAR2,
  --
  p_source_data_extract_id  IN   NUMBER,
  p_target_data_extract_id  IN   NUMBER,
  p_entity_table            IN   PSB_Account_Position_Set_Pvt.Entity_Tbl_Type
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Copy_Position_Sets';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
  l_source_business_group_id    psb_data_extracts.business_group_id%TYPE ;
  l_target_business_group_id    psb_data_extracts.business_group_id%TYPE ;
  l_new_position_set_id
		      psb_account_position_sets.account_position_set_id%TYPE ;
  --
  CURSOR l_source_data_extract_csr IS
	 SELECT business_group_id
	 FROM   psb_data_extracts
	 WHERE  data_extract_id = p_source_data_extract_id ;
  --
  CURSOR l_target_data_extract_csr IS
	 SELECT business_group_id
	 FROM   psb_data_extracts
	 WHERE  data_extract_id = p_target_data_extract_id ;
  --
BEGIN
  --
  SAVEPOINT Copy_Position_Sets_Pvt ;
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
  -- Validate the p_entity_table.
  --
  FOR i IN 1..p_entity_table.COUNT
  LOOP

    IF p_entity_table(i) NOT IN ( 'BWR', 'C', 'DR', 'E', 'P', 'PSG' ) THEN
      --
      Fnd_Message.Set_Name ('PSB',        'PSB_INVALID_ENTITY_TYPE') ;
      Fnd_Message.Set_Token('ENTITY_TYPE', p_entity_table(i) ) ;
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR ;
      --
    END IF;

  END LOOP;

  --
  -- Validate the source data extract.
  --
  OPEN  l_source_data_extract_csr ;
  FETCH l_source_data_extract_csr INTO l_source_business_group_id ;

  IF ( l_source_data_extract_csr%NOTFOUND ) THEN
    --
    Fnd_Message.Set_Name ('PSB',         'PSB_INVALID_DATA_EXTRACT') ;
    Fnd_Message.Set_Token('DATA_EXTRACT', p_source_data_extract_id ) ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
    --
  END IF ;

  --
  -- Validate the target data extract.
  --
  OPEN  l_target_data_extract_csr ;
  FETCH l_target_data_extract_csr INTO l_target_business_group_id ;

  IF ( l_target_data_extract_csr%NOTFOUND ) THEN
    --
    Fnd_Message.Set_Name ('PSB',         'PSB_INVALID_DATA_EXTRACT') ;
    Fnd_Message.Set_Token('DATA_EXTRACT', p_target_data_extract_id ) ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
    --
  END IF ;


  -- First copy all the global position sets.
  FOR l_global_sets_rec IN
  (
    SELECT *
    FROM   psb_account_position_sets
    WHERE  account_or_position_type = 'P'
    AND    global_or_local_type     = 'G'
    AND    data_extract_id          = p_source_data_extract_id
  )
  LOOP

    Copy_Position_Set
    (
      p_api_version              => 1.0,
      p_init_msg_list            => FND_API.G_TRUE,
      p_commit                   => FND_API.G_FALSE,
      p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
      p_return_status            => l_return_status,
      p_msg_count                => l_msg_count,
      p_msg_data                 => l_msg_data,
      --
      p_source_position_set_id   => l_global_sets_rec.account_position_set_id ,
      p_source_data_extract_id   => p_source_data_extract_id,
      p_target_data_extract_id   => p_target_data_extract_id,
      p_target_business_group_id => l_target_business_group_id,
      p_new_position_set_id      => l_new_position_set_id
    ) ;
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --

  END LOOP ;


  --
  -- Now copy the local position sets as per the entities speficied in the
  -- PL/SQL table.
  --
  FOR i IN 1..p_entity_table.COUNT
  LOOP

    pd( 'Entity type :' || p_entity_table(i) ) ;

    FOR l_local_sets_rec IN
    (
      SELECT sets.account_position_set_id
      FROM   psb_set_relations          rels ,
	     psb_account_position_sets  sets
      WHERE  sets.account_position_set_id  = rels.account_position_set_id
      AND    sets.account_or_position_type = 'P'
      AND    sets.global_or_local_type     = 'L'
      AND    sets.data_extract_id          = p_source_data_extract_id
      AND    DECODE( p_entity_table(i) ,
			'BWR', budget_workflow_rule_id,
			'C',   constraint_id,
			'DR',  default_rule_id,
			'P',   parameter_id,
			'PSG', position_set_group_id
		    ) IS NOT NULL
    )
    LOOP

      --
      Copy_Position_Set
      (
	p_api_version              => 1.0,
	p_init_msg_list            => FND_API.G_TRUE,
	p_commit                   => FND_API.G_FALSE,
	p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
	p_return_status            => l_return_status,
	p_msg_count                => l_msg_count,
	p_msg_data                 => l_msg_data,
	--
	p_source_position_set_id   => l_local_sets_rec.account_position_set_id,
	p_source_data_extract_id   => p_source_data_extract_id,
	p_target_data_extract_id   => p_target_data_extract_id,
	p_target_business_group_id => l_target_business_group_id,
	p_new_position_set_id      => l_new_position_set_id
      ) ;
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      --

    END LOOP ;  -- End local sets.

  END LOOP ;  -- End p_entity_table table.

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
    ROLLBACK TO Copy_Position_Sets_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Copy_Position_Sets_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Copy_Position_Sets_Pvt ;
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
END Copy_Position_Sets ;
/*-------------------------------------------------------------------------*/



/*===========================================================================+
 |                        PROCEDURE Copy_Position_Set                        |
 +===========================================================================*/
--
-- This API copies a given position set.
--
PROCEDURE Copy_Position_Set
(
  p_api_version               IN   NUMBER,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_msg_count                 OUT  NOCOPY  NUMBER,
  p_msg_data                  OUT  NOCOPY  VARCHAR2,
  --
  p_source_position_set_id    IN   NUMBER ,
  p_source_data_extract_id    IN   NUMBER ,
  p_target_data_extract_id    IN   NUMBER ,
  p_target_business_group_id  IN   NUMBER ,
  p_new_position_set_id       OUT  NOCOPY  NUMBER
)
IS
  --
  l_api_name             CONSTANT VARCHAR2(30)  := 'Copy_Position_Set' ;
  l_api_version          CONSTANT NUMBER :=  1.0 ;
  --
  l_return_status        VARCHAR2(1) ;
  l_msg_count            NUMBER ;
  l_msg_data             VARCHAR2(2000) ;
  --
  l_current_date         DATE   := SYSDATE                       ;
  l_current_user_id      NUMBER := NVL( Fnd_Global.User_Id  , 0) ;
  l_current_login_id     NUMBER := NVL( Fnd_Global.Login_Id , 0) ;
  --
  l_count                NUMBER ;
  l_row_id               VARCHAR2(50) ;
  l_account_position_set_id
			 psb_account_position_sets.account_position_set_id%TYPE;

  l_line_sequence_id     psb_account_position_set_lines.line_sequence_id%TYPE ;
  l_value_sequence_id    psb_position_set_line_values.value_sequence_id%TYPE ;
  l_target_attribute_id  psb_account_position_set_lines.attribute_id%TYPE ;

  l_target_attribute_value_id
			 psb_position_set_line_values.attribute_value_id%TYPE ;
  --
  CURSOR l_sets_csr IS
	 SELECT *
	 FROM   psb_account_position_sets
	 WHERE  account_position_set_id = p_source_position_set_id ;
  --
  CURSOR l_find_matching_attribute_csr
	 (
	   c_name   psb_attributes_VL.name%TYPE
	 )
	 IS
	 SELECT attribute_id
	 FROM   psb_attributes_VL
	 WHERE  business_group_id          = p_target_business_group_id
	 AND    name                       = c_name
	 AND    allow_in_position_set_flag = 'Y' ;
  --
  CURSOR l_find_matching_value_csr
	 (
	   c_attribute_value   psb_attribute_values.attribute_value%TYPE
	 )
	 IS
	 SELECT attribute_value_id
	 FROM   psb_attribute_values
	 WHERE  data_extract_id = p_target_data_extract_id
	 AND    attribute_id    = l_target_attribute_id
	 AND    attribute_value = c_attribute_value ;
  --
  l_sets_rec             l_sets_csr%ROWTYPE ;
  --
BEGIN
  --
  SAVEPOINT Copy_Position_Set_Pvt ;
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

  pd( 'position set id :' || p_source_position_set_id ) ;

  --
  -- Copy the set.
  --

  OPEN  l_sets_csr ;
  FETCH l_sets_csr INTO l_sets_rec ;
  CLOSE l_sets_csr ;

  --
  -- Check whether the current position set already exists. If exists, then the
  -- set cannot be copied and a message is placed in the message stack.
  --
  SELECT count(*) INTO l_count
  FROM   psb_account_position_sets
  WHERE  account_position_set_id <> l_sets_rec.account_position_set_id
  AND    name                     = l_sets_rec.name
  AND    data_extract_id          = p_target_data_extract_id ;

  IF l_count <> 0 THEN

    pd( 'Cannot copy as set exists :' || l_sets_rec.name ) ;

    --
    Fnd_Message.Set_Name ('PSB',      'PSB_SET_CANNOT_BE_COPIED') ;
    Fnd_Message.Set_Token('SET_NAME', l_sets_rec.name ) ;
    FND_MSG_PUB.Add;
    RETURN;
    --
  END IF;

  PSB_Account_Position_Set_Pvt.Insert_Row
  (
    p_api_version                  => 1.0,
    p_init_msg_list                => FND_API.G_TRUE,
    p_commit                       => FND_API.G_FALSE,
    p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
    p_return_status                => l_return_status,
    p_msg_count                    => l_msg_count,
    p_msg_data                     => l_msg_data,
    --
    p_row_id                       => l_row_id,
    p_account_position_set_id      => l_account_position_set_id,
    p_name                         => l_sets_rec.name,
    p_set_of_books_id              => l_sets_rec.set_of_books_id,
    p_data_extract_id              => p_target_data_extract_id,
    p_budget_group_id              => l_sets_rec.budget_group_id,
    p_global_or_local_type         => l_sets_rec.global_or_local_type,
    p_account_or_position_type     => l_sets_rec.account_or_position_type,
    p_attribute_selection_type     => l_sets_rec.attribute_selection_type,
    p_business_group_id            => p_target_business_group_id,
    p_last_update_date             => l_current_date,
    p_last_updated_by              => l_current_user_id,
    p_last_update_login            => l_current_login_id,
    p_created_by                   => l_current_user_id,
    p_creation_date                => l_current_date
  );
  --
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  -- Populate the new position id field.
  p_new_position_set_id := l_account_position_set_id ;

  --
  -- Copy the set lines.
  --

  FOR l_lines_rec IN
  (
    SELECT *
    FROM   psb_acct_position_set_lines_v
    WHERE  account_position_set_id = p_source_position_set_id
  )
  LOOP


    -- Find the matching attribute in the target data extract.
    OPEN  l_find_matching_attribute_csr ( l_lines_rec.attribute_name ) ;
    FETCH l_find_matching_attribute_csr INTO l_target_attribute_id ;

    IF l_find_matching_attribute_csr%NOTFOUND THEN

      -- Skip this set line and process the next one.
      CLOSE l_find_matching_attribute_csr ;
      GOTO  end_lines_loop ;   -- PL/SQL lacks CONTINUE statement.

    END IF;
    CLOSE l_find_matching_attribute_csr ;

    -- Reset l_line_sequence_id variable as new values are created from
    -- the sequence.
    l_line_sequence_id := NULL;

    PSB_Acct_Position_Set_Line_Pvt.Insert_Row
    (
      p_api_version             => 1.0,
      p_init_msg_list           => FND_API.G_TRUE,
      p_commit                  => FND_API.G_FALSE,
      p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
      p_return_status           => l_return_status,
      p_msg_count               => l_msg_count,
      p_msg_data                => l_msg_data,
      --
      p_row_id                  => l_row_id,
      p_line_sequence_id        => l_line_sequence_id,
      p_account_position_set_id => l_account_position_set_id,
      p_description             => l_lines_rec.description,
      p_business_group_id       => p_target_business_group_id,
      p_attribute_id            => l_target_attribute_id,
      p_include_or_exclude_type => l_lines_rec.include_or_exclude_type,
      p_segment1_low            => l_lines_rec.segment1_low,
      p_segment2_low            => l_lines_rec.segment2_low,
      p_segment3_low            => l_lines_rec.segment3_low,
      p_segment4_low            => l_lines_rec.segment4_low,
      p_segment5_low            => l_lines_rec.segment5_low,
      p_segment6_low            => l_lines_rec.segment6_low,
      p_segment7_low            => l_lines_rec.segment7_low,
      p_segment8_low            => l_lines_rec.segment8_low,
      p_segment9_low            => l_lines_rec.segment9_low,
      p_segment10_low           => l_lines_rec.segment10_low,
      p_segment11_low           => l_lines_rec.segment11_low,
      p_segment12_low           => l_lines_rec.segment12_low,
      p_segment13_low           => l_lines_rec.segment13_low,
      p_segment14_low           => l_lines_rec.segment14_low,
      p_segment15_low           => l_lines_rec.segment15_low,
      p_segment16_low           => l_lines_rec.segment16_low,
      p_segment17_low           => l_lines_rec.segment17_low,
      p_segment18_low           => l_lines_rec.segment18_low,
      p_segment19_low           => l_lines_rec.segment19_low,
      p_segment20_low           => l_lines_rec.segment20_low,
      p_segment21_low           => l_lines_rec.segment21_low,
      p_segment22_low           => l_lines_rec.segment22_low,
      p_segment23_low           => l_lines_rec.segment23_low,
      p_segment24_low           => l_lines_rec.segment24_low,
      p_segment25_low           => l_lines_rec.segment25_low,
      p_segment26_low           => l_lines_rec.segment26_low,
      p_segment27_low           => l_lines_rec.segment27_low,
      p_segment28_low           => l_lines_rec.segment28_low,
      p_segment29_low           => l_lines_rec.segment29_low,
      p_segment30_low           => l_lines_rec.segment30_low,
      p_segment1_high           => l_lines_rec.segment1_high,
      p_segment2_high           => l_lines_rec.segment2_high,
      p_segment3_high           => l_lines_rec.segment3_high,
      p_segment4_high           => l_lines_rec.segment4_high,
      p_segment5_high           => l_lines_rec.segment5_high,
      p_segment6_high           => l_lines_rec.segment6_high,
      p_segment7_high           => l_lines_rec.segment7_high,
      p_segment8_high           => l_lines_rec.segment8_high,
      p_segment9_high           => l_lines_rec.segment9_high,
      p_segment10_high          => l_lines_rec.segment10_high,
      p_segment11_high          => l_lines_rec.segment11_high,
      p_segment12_high          => l_lines_rec.segment12_high,
      p_segment13_high          => l_lines_rec.segment13_high,
      p_segment14_high          => l_lines_rec.segment14_high,
      p_segment15_high          => l_lines_rec.segment15_high,
      p_segment16_high          => l_lines_rec.segment16_high,
      p_segment17_high          => l_lines_rec.segment17_high,
      p_segment18_high          => l_lines_rec.segment18_high,
      p_segment19_high          => l_lines_rec.segment19_high,
      p_segment20_high          => l_lines_rec.segment20_high,
      p_segment21_high          => l_lines_rec.segment21_high,
      p_segment22_high          => l_lines_rec.segment22_high,
      p_segment23_high          => l_lines_rec.segment23_high,
      p_segment24_high          => l_lines_rec.segment24_high,
      p_segment25_high          => l_lines_rec.segment25_high,
      p_segment26_high          => l_lines_rec.segment26_high,
      p_segment27_high          => l_lines_rec.segment27_high,
      p_segment28_high          => l_lines_rec.segment28_high,
      p_segment29_high          => l_lines_rec.segment29_high,
      p_segment30_high          => l_lines_rec.segment30_high,
      p_context                 => l_lines_rec.context,
      p_attribute1              => l_lines_rec.attribute1,
      p_attribute2              => l_lines_rec.attribute2,
      p_attribute3              => l_lines_rec.attribute3,
      p_attribute4              => l_lines_rec.attribute4,
      p_attribute5              => l_lines_rec.attribute5,
      p_attribute6              => l_lines_rec.attribute6,
      p_attribute7              => l_lines_rec.attribute7,
      p_attribute8              => l_lines_rec.attribute8,
      p_attribute9              => l_lines_rec.attribute9,
      p_attribute10             => l_lines_rec.attribute10,
      p_last_update_date        => l_current_date,
      p_last_updated_by         => l_current_user_id,
      p_last_update_login       => l_current_login_id,
      p_created_by              => l_current_user_id,
      p_creation_date           => l_current_date
    );
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --

    pd( 'Created set line:' || l_line_sequence_id ) ;

    --
    -- Copy the set line values.
    --

    FOR l_values_rec IN
    (
      SELECT *
      FROM   psb_position_set_line_values_v
      WHERE  line_sequence_id = l_lines_rec.line_sequence_id
    )
    LOOP

      --
      -- We need to find matching attribute_value_id only when value_table
      -- flag is 'Y', otherwise every value is good.
      --
      IF l_values_rec.attribute_value_table_flag = 'Y' THEN

	-- Find the matching attribute_value_id.
	-- ( The l_values_rec.attribute_value will be null. )
	OPEN  l_find_matching_value_csr ( l_values_rec.attribute_table_value );
	FETCH l_find_matching_value_csr INTO l_target_attribute_value_id ;

	IF l_find_matching_value_csr%NOTFOUND THEN

	  -- Skip this value line and process the next one.
	  CLOSE l_find_matching_value_csr ;
	  GOTO  end_values_loop ;   -- PL/SQL lacks CONTINUE statement.

	END IF;
	CLOSE l_find_matching_value_csr ;

      ELSE

	-- The l_values_rec.attribute_value will not be null.
	l_target_attribute_value_id := NULL ;

      END IF;

/* Bug No 2579818 Start */
      l_value_sequence_id := NULL;
/* Bug No 2579818 End */

      PSB_Pos_Set_Line_Values_Pvt.Insert_Row
      (
	 p_api_version           => 1.0,
	 p_init_msg_list         => FND_API.G_TRUE,
	 p_commit                => FND_API.G_FALSE,
	 p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
	 p_return_status         => l_return_status,
	 p_msg_count             => l_msg_count,
	 p_msg_data              => l_msg_data,
	 --
	 p_row_id                => l_row_id,
	 p_value_sequence_id     => l_value_sequence_id,
	 p_line_sequence_id      => l_line_sequence_id,
	 p_attribute_value_id    => l_target_attribute_value_id,
	 p_attribute_value       => l_values_rec.attribute_value,
	 p_last_update_date      => l_current_date,
	 p_last_updated_by       => l_current_user_id,
	 p_last_update_login     => l_current_login_id,
	 p_created_by            => l_current_user_id,
	 p_creation_date         => l_current_date
      );
      --
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      --

      pd( 'Created val :' || l_line_sequence_id || '-' || l_value_sequence_id);

      <<end_values_loop>>
      NULL;
    END LOOP ;

    <<end_lines_loop>>
    NULL;
  END LOOP ;

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
    ROLLBACK TO Copy_Position_Set_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Copy_Position_Set_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Copy_Position_Set_Pvt ;
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
END Copy_Position_Set ;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                     PROCEDURE pd (Private)                                |
 +===========================================================================*/
--
-- Private procedure to print debug info. The name is tried to keep as
-- short as possible for better documentaion.
--
PROCEDURE pd
(
   p_message                   IN   VARCHAR2
)
IS
--
BEGIN

  IF g_debug_flag = 'Y' THEN
    NULL;
    -- dbms_output.put_line(p_message) ;
  END IF;

END pd ;
/*---------------------------------------------------------------------------*/


END PSB_Account_Position_Set_Pvt;

/
