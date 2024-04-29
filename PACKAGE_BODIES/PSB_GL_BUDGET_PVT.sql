--------------------------------------------------------
--  DDL for Package Body PSB_GL_BUDGET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_GL_BUDGET_PVT" AS
/* $Header: PSBVGBDB.pls 120.2 2005/07/13 11:26:29 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_GL_Budget_Pvt';

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
  p_gl_budget_id              IN OUT  NOCOPY   NUMBER,
  p_gl_budget_set_id          IN       NUMBER,
  p_gl_budget_version_id      IN       NUMBER,
  p_start_period              IN       VARCHAR2,
  p_end_period                IN       VARCHAR2,
  p_start_date                IN       DATE,
  p_end_date                  IN       DATE,
  p_dual_posting_type         IN       VARCHAR2,
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
    FROM   psb_gl_budgets
    WHERE  gl_budget_id = p_gl_budget_id ;

  CURSOR C2 IS
    SELECT psb_gl_budgets_s.NEXTVAL
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

  IF ( p_gl_budget_id IS NULL ) THEN
    OPEN C2 ;
    FETCH C2 INTO p_gl_budget_id ;
    CLOSE C2 ;
  END IF;

  INSERT INTO psb_gl_budgets
	      (
		gl_budget_id         ,
		gl_budget_set_id     ,
		gl_budget_version_id ,
		start_period         ,
		end_period           ,
		start_date           ,
		end_date             ,
		dual_posting_type    ,
		last_update_date     ,
		last_updated_by      ,
		last_update_login    ,
		created_by           ,
		creation_date )
	      VALUES
	      (
		p_gl_budget_id         ,
		p_gl_budget_set_id     ,
		p_gl_budget_version_id ,
		p_start_period         ,
		p_end_period           ,
		p_start_date           ,
		p_end_date             ,
		p_dual_posting_type    ,
		p_last_update_date     ,
		p_last_updated_by      ,
		p_last_update_login    ,
		p_created_by           ,
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
  p_gl_budget_id              IN       NUMBER,
  p_gl_budget_set_id          IN       NUMBER,
  p_gl_budget_version_id      IN       NUMBER,
  p_start_period              IN       VARCHAR2,
  p_end_period                IN       VARCHAR2,
  p_start_date                IN       DATE,
  p_end_date                  IN       DATE,
  p_dual_posting_type         IN       VARCHAR2,
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
       FROM   psb_gl_budgets
       WHERE  rowid = p_row_id
       FOR UPDATE OF gl_budget_id NOWAIT;
  --
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
     (Recinfo.gl_budget_id =  p_gl_budget_id)


      AND ( (Recinfo.gl_budget_set_id =  p_gl_budget_set_id)
	     OR ( (Recinfo.gl_budget_set_id IS NULL)
		   AND (p_gl_budget_set_id IS NULL)))

      AND ( (Recinfo.gl_budget_version_id =  p_gl_budget_version_id)
	     OR ( (Recinfo.gl_budget_version_id IS NULL)
		   AND (p_gl_budget_version_id IS NULL)))

      AND ( (Recinfo.start_period =  p_start_period)
	     OR ( (Recinfo.start_period IS NULL)
		   AND (p_start_period IS NULL)))

      AND ( (Recinfo.end_period =  p_end_period)
	     OR ( (Recinfo.end_period IS NULL)
		   AND (p_end_period IS NULL)))

      AND ( (Recinfo.start_date =  p_start_date)
	     OR ( (Recinfo.start_date IS NULL)
		   AND (p_start_date IS NULL)))

      AND ( (Recinfo.end_date =  p_end_date)
	     OR ( (Recinfo.end_date IS NULL)
		   AND (p_end_date IS NULL)))

      AND ( (Recinfo.dual_posting_type =  p_dual_posting_type)
	     OR ( (Recinfo.dual_posting_type IS NULL)
		   AND (p_dual_posting_type IS NULL)))
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
  p_gl_budget_set_id          IN       NUMBER,
  p_gl_budget_version_id      IN       NUMBER,
  p_start_period              IN       VARCHAR2,
  p_end_period                IN       VARCHAR2,
  p_start_date                IN       DATE,
  p_end_date                  IN       DATE,
  p_dual_posting_type         IN       VARCHAR2,
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

  UPDATE psb_gl_budgets
  SET    gl_budget_set_id     = p_gl_budget_set_id     ,
	 gl_budget_version_id = p_gl_budget_version_id ,
	 start_period         = p_start_period         ,
	 end_period           = p_end_period           ,
	 start_date           = p_start_date           ,
	 end_date             = p_end_date             ,
	 dual_posting_type    = p_dual_posting_type    ,
	 last_update_date     = p_last_update_date     ,
	 last_updated_by      = p_last_updated_by      ,
	 last_update_login    = p_last_update_login
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
  l_gl_budget_id            psb_gl_budgets.gl_budget_id%TYPE;
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

  --
  -- First delete all the set related information.
  --

  SELECT gl_budget_id INTO l_gl_budget_id
  FROM   psb_gl_budgets
  WHERE  rowid = p_row_id ;

  PSB_Set_Relation_PVT.Delete_Entity_Relation
  (
     p_api_version      => 1.0 ,
     p_init_msg_list    => FND_API.G_FALSE,
     p_commit           => FND_API.G_FALSE,
     p_validation_level => FND_API.G_VALID_LEVEL_FULL,
     p_return_status    => l_return_status,
     p_msg_count        => l_msg_count,
     p_msg_data         => l_msg_data,
     --
     p_entity_type      => 'GBS' ,
     p_entity_id        => l_gl_budget_id
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF ;

  --
  -- End deleting set related information.
  --

  --
  -- Deleting the record in psb_gl_budgets.
  --
  DELETE psb_gl_budgets
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



/*===========================================================================+
 |                     PROCEDURE Find_GL_Budget                              |
 +===========================================================================*/
--
-- This API finds the name of the GL Budget for a given GL Budget Set and a
-- Code combination id.
--
PROCEDURE Find_GL_Budget
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
  p_code_combination_id       IN       NUMBER,
  p_start_date                IN       DATE,
  p_dual_posting_type         IN       VARCHAR2 := FND_API.G_MISS_CHAR,
  --
  p_gl_budget_version_id      OUT  NOCOPY      NUMBER
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Find_GL_Budget' ;
  l_api_version         CONSTANT NUMBER         :=  1.0 ;
  --
  CURSOR l_find_ccid_csr
	 (
	   c_gl_budget_id          psb_gl_budgets.gl_budget_id%TYPE ,
	   c_code_combination_id   psb_budget_accounts.code_combination_id%TYPE
	 )
	 IS
	 SELECT '1'
	 FROM   psb_set_relations   rel ,
		psb_budget_accounts pba
	 WHERE  rel.gl_budget_id            = c_gl_budget_id
	 AND    pba.account_position_set_id = rel.account_position_set_id
	 AND    pba.code_combination_id     = c_code_combination_id ;
  --
  l_tmp                          VARCHAR2(1) ;
  l_budget_found_flag            VARCHAR2(1) := NULL ;
  l_dual_posting_type            VARCHAR2(1) ;
  --
BEGIN
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.To_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  --
  -- Missing p_dual_posting_type is equivalent to 'P' (Permanent).
  --
  IF ( p_dual_posting_type = FND_API.G_MISS_CHAR) OR
     ( p_dual_posting_type IS NULL)
  THEN
    l_dual_posting_type := 'P' ;
  ELSE
    l_dual_posting_type := p_dual_posting_type ;
  END IF;

  --
  -- Validate the parameters.
  --

  IF l_dual_posting_type NOT IN ( 'A', 'P' ) THEN
    Fnd_Message.Set_Name ('PSB', 'PSB_INVALID_ARGUMENT') ;
    Fnd_Message.Set_Token('ROUTINE', l_api_name ) ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;


  BEGIN

    SELECT '1' INTO l_tmp
    FROM   psb_gl_budget_sets
    WHERE  gl_budget_set_id = p_gl_budget_set_id ;

  EXCEPTION
    WHEN no_data_found THEN
      Fnd_Message.Set_Name ('PSB', 'PSB_INVALID_ARGUMENT') ;
      Fnd_Message.Set_Token('ROUTINE', l_api_name ) ;
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR ;
  END ;

  --
  -- End validatiing parameters.
  --

  --
  -- Scan all the GL budgets to find out which one contains the given CCID.
  -- Only one GL Budget (GL_BUDGET_ID) can contain it for a given period
  -- and a given dual_posting_type. The dual_posting_type being NULL is
  -- equivalent to being 'P'.
  --
  FOR l_gl_budget_rec IN
  (
    SELECT gl_budget_id         ,
	   gl_budget_version_id
    FROM   psb_gl_budgets
    WHERE  gl_budget_set_id = p_gl_budget_set_id
    AND    p_start_date BETWEEN start_date AND end_date
    AND    NVL( dual_posting_type, 'P' ) = l_dual_posting_type

  )
  LOOP

    -- pd('Budget id : ' || l_gl_budget_rec.gl_budget_id ) ;

    l_budget_found_flag := NULL;

    -- Check whether the CCID belongs to this GL Budget ot not.
    OPEN  l_find_ccid_csr
	  ( l_gl_budget_rec.gl_budget_id,
	    p_code_combination_id
	  );
    FETCH l_find_ccid_csr INTO l_budget_found_flag ;
    CLOSE l_find_ccid_csr;

    IF l_budget_found_flag IS NOT NULL THEN

      -- It means the CCID belongs to the current GL Budget Id.
      p_gl_budget_version_id := l_gl_budget_rec.gl_budget_version_id ;

      -- Exit the loop now.
      EXIT ;

    END IF;

  END LOOP ; -- End processing GL budgets related to p_gl_budget_set_id.

  -- Assign NULL to out parameters if GL Budget is not found.
  IF l_budget_found_flag IS NULL THEN
    p_gl_budget_version_id := NULL ;
  END IF ;

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END IF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    IF ( l_find_ccid_csr%ISOPEN ) THEN
      CLOSE l_find_ccid_csr ;
    END IF ;
    --
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
END Find_GL_Budget ;
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


END PSB_GL_Budget_Pvt ;

/
