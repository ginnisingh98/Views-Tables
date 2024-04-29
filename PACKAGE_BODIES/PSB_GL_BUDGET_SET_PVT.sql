--------------------------------------------------------
--  DDL for Package Body PSB_GL_BUDGET_SET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_GL_BUDGET_SET_PVT" AS
/* $Header: PSBVGBSB.pls 120.4.12010000.3 2009/04/29 09:50:11 rkotha ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_GL_Budget_Set_Pvt';

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
  p_gl_budget_set_id          IN OUT  NOCOPY   NUMBER,
  p_gl_budget_set_name        IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  p_last_update_date          IN       DATE,
  p_last_updated_by           IN       NUMBER,
  p_last_update_login         IN       NUMBER,
  p_created_by                IN       NUMBER,
  p_creation_date             IN       DATE  ,
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
  p_attribute10               IN       VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  CURSOR C IS
    SELECT rowid
    FROM   psb_gl_budget_sets
    WHERE  gl_budget_set_id = p_gl_budget_set_id ;

  CURSOR C2 IS
    SELECT psb_gl_budget_sets_s.NEXTVAL
    FROM   dual ;
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

  IF ( p_gl_budget_set_id IS NULL ) THEN
    OPEN C2;

    FETCH C2 INTO p_gl_budget_set_id ;
    CLOSE C2;
  END IF;

  INSERT INTO psb_gl_budget_sets
	      (
		gl_budget_set_id   ,
		gl_budget_set_name ,
		set_of_books_id    ,
		last_update_date   ,
		last_updated_by    ,
		last_update_login  ,
		created_by         ,
		creation_date      ,
		context            ,
		attribute1         ,
		attribute2         ,
		attribute3         ,
		attribute4         ,
		attribute5         ,
		attribute6         ,
		attribute7         ,
		attribute8         ,
		attribute9         ,
		attribute10  )
	      VALUES
	      (
		p_gl_budget_set_id   ,
		p_gl_budget_set_name ,
		p_set_of_books_id    ,
		p_last_update_date   ,
		p_last_updated_by    ,
		p_last_update_login  ,
		p_created_by         ,
		p_creation_date      ,
		p_context            ,
		p_attribute1         ,
		p_attribute2         ,
		p_attribute3         ,
		p_attribute4         ,
		p_attribute5         ,
		p_attribute6         ,
		p_attribute7         ,
		p_attribute8         ,
		p_attribute9         ,
		p_attribute10
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
  p_gl_budget_set_id          IN       NUMBER,
  p_gl_budget_set_name        IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
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
  Counter NUMBER;
  CURSOR C IS
       SELECT *
       FROM   psb_gl_budget_sets
       WHERE  rowid = p_row_id
       FOR UPDATE of gl_budget_set_id NOWAIT;
  Recinfo C%ROWTYPE;
  --
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
     (Recinfo.gl_budget_set_id =  p_gl_budget_set_id)

      AND ( (Recinfo.gl_budget_set_name =  p_gl_budget_set_name)
	     OR ( (Recinfo.gl_budget_set_name IS NULL)
		   AND (p_gl_budget_set_name IS NULL)))

      AND ( (Recinfo.set_of_books_id =  p_set_of_books_id)
	     OR ( (Recinfo.set_of_books_id IS NULL)
		   AND (p_set_of_books_id IS NULL)))

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
  p_gl_budget_set_name        IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  p_last_update_date          IN       DATE,
  p_last_updated_by           IN       NUMBER,
  p_last_update_login         IN       NUMBER,
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
  p_attribute10               IN       VARCHAR2
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

  UPDATE psb_gl_budget_sets
  SET    gl_budget_set_name = p_gl_budget_set_name ,
	 set_of_books_id    = p_set_of_books_id    ,
	 last_update_date   = p_last_update_date   ,
	 last_updated_by    = p_last_updated_by    ,
	 last_update_login  = p_last_update_login  ,
	 context            = p_Context            ,
	 attribute1         = p_Attribute1         ,
	 attribute2         = p_Attribute2         ,
	 attribute3         = p_Attribute3         ,
	 attribute4         = p_Attribute4         ,
	 attribute5         = p_Attribute5         ,
	 attribute6         = p_Attribute6         ,
	 attribute7         = p_Attribute7         ,
	 attribute8         = p_Attribute8         ,
	 attribute9         = p_Attribute9         ,
	 attribute10        = p_Attribute10
  WHERE  rowid = p_row_id;

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
  p_row_id                    IN       VARCHAR2
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
  l_gl_budget_set_id        psb_gl_budget_sets.gl_budget_set_id%TYPE;
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
  -- Deleting dependent detail records from psb_gl_budgets.
  -- ( To maintain ISOLATED master-detail form relation also. )
  --

  SELECT gl_budget_set_id INTO l_gl_budget_set_id
  FROM   psb_gl_budget_sets
  WHERE  rowid = p_row_id ;

  --
  -- Delete all the related GL Budgets and associated set information.
  --
  FOR l_budget_rec IN
  (
    SELECT ROWID
    FROM   psb_gl_budgets
    WHERE  gl_budget_set_id = l_gl_budget_set_id
  )
  LOOP
    --
    PSB_GL_Budget_Pvt.Delete_Row
    (
      p_api_version      => 1.0 ,
      p_init_msg_list    => FND_API.G_FALSE,
      p_commit           => FND_API.G_FALSE,
      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
      p_return_status    => l_return_status,
      p_msg_count        => l_msg_count,
      p_msg_data         => l_msg_data,
      --
      p_row_id           => l_budget_rec.rowid
    );
    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF ;
    --
  END LOOP ;
  --
  -- End deleting GL Budgets related information.
  --


  -- Deleting the record in psb_gl_budget_sets.
  DELETE psb_gl_budget_sets
  WHERE  rowid = p_row_id;

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
  p_gl_budget_set_name        IN       VARCHAR2,
  p_set_of_books_id           IN       NUMBER,
  p_return_value              IN OUT  NOCOPY   VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Unique';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_tmp                 VARCHAR2(1);
  --
  CURSOR c IS
    SELECT '1'
    FROM   psb_gl_budget_sets
    WHERE  gl_budget_set_name = p_gl_budget_set_name
    AND    set_of_books_id = p_set_of_books_id
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
 |                     PROCEDURE Validate_Account_Overlap                   |
 +==========================================================================*/
PROCEDURE Validate_Account_Overlap
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_gl_budget_set_id          IN       NUMBER,
  p_validation_status         IN OUT  NOCOPY   VARCHAR2
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
  l_gl_budget_set_id        psb_gl_budget_sets.gl_budget_set_id%TYPE;
  l_start_date              DATE ;
  l_end_date                DATE ;
  --
  l_first_time_flag         VARCHAR2(1) ;

  /*bug:5931905:start*/

   l_gl_budget_name          VARCHAR2(200);

    CURSOR c_dup_gl_budget_csr IS
    SELECT pgbv.gl_budget_name,
	   pba.account_position_set_id,
	   pba.code_combination_id,
	   pgbv1.gl_budget_name target_budget_name
    FROM   psb_gl_budgets_v    pgbv,
           psb_set_relations   rel ,
           psb_budget_accounts pba,
           psb_gl_budgets_v    pgbv1,
           psb_set_relations   rel1 ,
           psb_budget_accounts pba1
    WHERE  pgbv.gl_budget_set_id = p_gl_budget_set_id
      AND  rel.gl_budget_id        = pgbv.gl_budget_id
      AND  pba.account_position_set_id = rel.account_position_set_id
      AND  pgbv1.gl_budget_set_id = p_gl_budget_set_id
      AND  rel1.gl_budget_id       <> rel.gl_budget_id
      AND  rel1.gl_budget_id       = pgbv1.gl_budget_id
      AND  pba1.account_position_set_id = rel1.account_position_set_id
      AND  pba1.code_combination_id     = pba.code_combination_id
      AND  (
	     ( pgbv.start_date BETWEEN pgbv1.start_date AND pgbv1.end_date )
	      OR
		 ( pgbv.end_date BETWEEN pgbv1.start_date AND pgbv1.end_date )
		 OR
		 (
		   pgbv.start_date < pgbv1.start_date
		   AND
		   pgbv.end_date > pgbv1.end_date
		 )
	       )
	AND    NVL( pgbv.dual_posting_type, 'P' ) =  NVL( pgbv1.dual_posting_type, 'P' )
    ORDER BY pgbv.gl_budget_name;

    TYPE l_gl_budget_name_type IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
    TYPE l_ccid_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE l_account_pset_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE l_target_budget_name_type IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;

    l_gl_budget_name_tab l_gl_budget_name_type;
    l_ccid_tab           l_ccid_type;
    l_account_pset_tab   l_account_pset_type;
    l_target_budget_name l_target_budget_name_type;

  /*bug:5931905:end*/

BEGIN
  --
  SAVEPOINT Validate_Account_Overlap_Pvt ;
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
  p_validation_status := FND_API.G_RET_STS_SUCCESS ;
  --
  -- Scan all the GL budgets to check for the overlap one at a time.
  --

    /*bug:5931905:start*/
  --Comparing each budget in the gl budget set against the other
  --gl budgets in that budget set to see if a given ccid in the
  --current validating gl budget is also present in another gl budget
  --in that budget set for a given period with the same posting type.

   l_first_time_flag := 'Y';

   OPEN c_dup_gl_budget_csr;
   FETCH c_dup_gl_budget_csr BULK COLLECT INTO l_gl_budget_name_tab,
                                               l_ccid_tab,
	                                       l_account_pset_tab,
	                                       l_target_budget_name;

   IF l_ccid_tab.COUNT > 0 THEN
    FOR i IN 1..l_ccid_tab.COUNT LOOP

	p_validation_status := FND_API.G_RET_STS_ERROR;

	-- Set the budget name being validated on the stack. To be done
	-- only one.

	IF l_gl_budget_name IS NULL THEN
	  l_gl_budget_name := l_gl_budget_name_tab(i);
          l_first_time_flag := 'Y';
        ELSIF l_gl_budget_name <> l_gl_budget_name_tab(i) THEN
           l_gl_budget_name := l_gl_budget_name_tab(i);
           l_first_time_flag := 'Y';
	END IF;
   /*bug:5931905:end*/

	IF l_first_time_flag = 'Y' THEN
	  --
	  l_first_time_flag := 'N' ;
	  --
	  FND_MESSAGE.SET_NAME ('PSB', 'PSB_GL_BUDGET_NAME_FOR_OVERLAP');
	  FND_MESSAGE.SET_TOKEN('BUDGET_NAME'        ,
				 l_gl_budget_name_tab(i));
	  FND_MSG_PUB.Add;
	END IF;

	-- Setup the error message for the current code_combination_id.
	FND_MESSAGE.SET_NAME ('PSB', 'PSB_GBS_OVERLAP_ACCOUNTS');
	FND_MESSAGE.SET_TOKEN('CCID'        ,
			       l_ccid_tab(i));
	FND_MESSAGE.SET_TOKEN('ACCOUNT_SET' ,
			       l_account_pset_tab(i));
	FND_MESSAGE.SET_TOKEN('BUDGET_NAME' ,
			       l_target_budget_name(i));
	FND_MSG_PUB.Add;

	pd('CCID ' || l_ccid_tab(i) || ' found ' ||
	   'Budget : ' || l_target_budget_name(i) ) ;

    END LOOP;
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
    ROLLBACK TO Validate_Account_Overlap_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Validate_Account_Overlap_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Validate_Account_Overlap_Pvt ;
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
END Validate_Account_Overlap ;
/* ----------------------------------------------------------------------- */



/*===========================================================================+
 |                    PROCEDURE Validate_Account_Overlap_CP                  |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Validate Account
-- Overlap for GL Budget Set'.
--
PROCEDURE Validate_Account_Overlap_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_gl_budget_set_id          IN       NUMBER
)
IS
  --
  l_api_name         CONSTANT VARCHAR2(30)   := 'Validate_Account_Overlap_CP' ;
  l_api_version      CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status             VARCHAR2(1) ;
  l_msg_count                 NUMBER ;
  l_msg_data                  VARCHAR2(2000) ;
  --
  l_validation_status          VARCHAR2(1) ;
  --
BEGIN
  --
  PSB_GL_Budget_Set_Pvt.Validate_Account_Overlap
  (
    p_api_version        => 1.0 ,
    p_init_msg_list      => FND_API.G_TRUE,
    p_commit             => FND_API.G_FALSE,
    p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
    p_return_status      => l_return_status,
    p_msg_count          => l_msg_count,
    p_msg_data           => l_msg_data,
    --
    p_gl_budget_set_id   => p_gl_budget_set_id,
    p_validation_status   => l_validation_status
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --

  --
  -- Check whether the API performed the overlap successfully or not. If not
  -- we will fail the concurrent program so that the user can fix it.
  --
  IF l_validation_status <> FND_API.G_RET_STS_SUCCESS THEN

    -- Print error on the OUTPUT file.
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.OUTPUT ,
				p_print_header => FND_API.G_TRUE ) ;
    --
    retcode := 2 ;
    --
  ELSE
    --
    retcode := 0 ;
    --
  END IF;
  --
  COMMIT WORK;
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN OTHERS THEN
    --
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         =>  FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
END Validate_Account_Overlap_CP ;
/*---------------------------------------------------------------------------*/

/* Bug No 2564791 Start */

PROCEDURE Check_References
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2,
  p_commit                    IN       VARCHAR2,
  p_validation_level          IN       NUMBER,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_gl_budget_set_id	      IN  	NUMBER
)
IS
  --
  l_api_name                  CONSTANT VARCHAR2(30)   := 'Check_References';
  l_api_version               CONSTANT NUMBER         :=  1.0;
  --
  l_return_status			     VARCHAR2(1);
  --
CURSOR l_check_references_br_csr IS
    SELECT 1
    FROM dual where exists(
    SELECT 1 FROM PSB_BUDGET_REVISIONS
    WHERE gl_budget_set_id = p_gl_budget_set_id);

CURSOR l_check_references_ws_csr IS
    SELECT 1
    FROM dual where exists(
    SELECT 1 FROM PSB_WORKSHEETS
    WHERE gl_budget_set_id = p_gl_budget_set_id);
BEGIN

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

  IF ( p_init_msg_list='T') THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  l_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  -- Start Checking References

  --
  for l_check_references_br_csr_rec in l_check_references_br_csr loop
    l_return_status:='T';
  END LOOP;
  --
  --
  for l_check_references_ws_csr_rec in l_check_references_ws_csr loop
       l_return_status:='T';
  END LOOP;

  -- End Checking References
  IF ( p_commit='T' ) THEN
    COMMIT WORK;
  END IF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  p_return_status:=l_return_status;
--
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
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Check_References_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END IF;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
END Check_References;

/* Bug No. 2564791 End */


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


END PSB_GL_Budget_Set_Pvt;

/
