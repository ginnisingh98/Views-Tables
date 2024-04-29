--------------------------------------------------------
--  DDL for Package Body PSB_SET_RELATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_SET_RELATION_PVT" AS
/* $Header: PSBVSTRB.pls 120.2 2004/11/30 12:39:41 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_Set_Relation_PVT';


/*=========================================================================+
 |                       PROCEDURE Insert_Row                              |
 +=========================================================================*/
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
  p_set_relation_id           IN OUT  NOCOPY   NUMBER,
  p_account_position_set_id   IN       NUMBER,
  p_allocation_Rule_id        IN       NUMBER,
  p_budget_group_id           IN       NUMBER,
  p_budget_workflow_rule_id   IN       NUMBER,
  p_constraint_id             IN       NUMBER,
  p_default_Rule_id           IN       NUMBER,
  p_Parameter_Id              IN       NUMBER,
  p_position_set_group_id     IN       NUMBER,
  p_gl_budget_id              IN       NUMBER := FND_API.G_MISS_NUM,
/* Budget Revision Rules Enhancement Start */
  p_rule_id                   IN       VARCHAR2,
  p_apply_balance_flag        IN       VARCHAR2,
/* Budget Revision Rules Enhancement End */
  p_effective_start_date      IN       DATE,
  p_effective_end_date        IN       DATE,
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
	   FROM   psb_set_relations
	   WHERE  set_relation_id = p_set_relation_id;

  CURSOR C2 IS
	    SELECT psb_set_relations_s.nextval
	    FROM   dual;
  --
  l_last_update_date    DATE   ;
  l_last_Updated_by     NUMBER ;
  l_last_update_login   NUMBER ;
  l_created_by          NUMBER ;
  l_creation_date       DATE   ;
  --
  l_gl_budget_id        psb_gl_budgets.gl_budget_id%TYPE ;
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
  IF FND_API.To_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  -- Resolve the defaulted parameters.
  IF p_gl_budget_id = FND_API.G_MISS_NUM THEN
    l_gl_budget_id := NULL ;
  ELSE
    l_gl_budget_id := p_gl_budget_id ;
  END IF;
  -- End resolving defaulted parameters.

  IF (p_set_relation_id IS NULL) THEN
    OPEN C2;
    FETCH C2 INTO p_set_relation_id;
    CLOSE C2;
  END IF;

  --
  -- Set Global fields.
  --
  l_last_update_date := SYSDATE ;
  --
  l_last_Updated_by  := FND_GLOBAL.User_Id;
  IF l_last_Updated_by IS NULL THEN
    l_last_Updated_by := -1;
  END IF ;
  --
  l_last_update_login := FND_GLOBAL.Login_Id ;
  IF l_last_update_login IS NULL THEN
    l_last_update_login := -1;
  END IF;
  --
  l_created_by          := l_last_Updated_by ;
  l_creation_date       := l_last_update_date ;
  --

  INSERT INTO psb_set_relations(
	      set_relation_id,
	      account_position_set_id,
	      allocation_rule_id,
	      budget_group_id,
	      budget_workflow_rule_id,
	      constraint_id,
	      default_rule_id,
	      parameter_id,
	      position_set_group_id,
	      gl_budget_id,
/* Budget Revision Rules Enhancement Start */
	      rule_id,
	      apply_balance_flag,
/* Budget Revision Rules Enhancement End */
	      effective_start_date,
	      effective_end_date,
	      last_update_date,
	      last_updated_by,
	      last_update_login,
	      created_by,
	      creation_date)
	VALUES (
	      p_set_relation_id,
	      p_account_position_set_id,
	      p_allocation_Rule_id,
	      p_budget_group_id,
	      p_budget_workflow_rule_id,
	      p_constraint_id,
	      p_default_Rule_id,
	      p_Parameter_Id,
	      p_position_set_group_id,
	      l_gl_budget_id,
/* Budget Revision Rules Enhancement Start */
	      p_rule_id,
	      p_apply_balance_flag,
/* Budget Revision Rules Enhancement End */
	      p_effective_start_date,
	      p_effective_end_date,
	      l_last_update_date,
	      l_last_Updated_by,
	      l_last_update_login,
	      l_created_by,
	      l_creation_date
	     ) ;

  OPEN C;
  FETCH C INTO p_row_id;
  --
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  --
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
/* ----------------------------------------------------------------------- */



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
  p_row_id                    IN       VARCHAR2,
  p_set_relation_id           IN       NUMBER,
  p_account_position_set_id   IN       NUMBER,
  p_allocation_Rule_id        IN       NUMBER,
  p_budget_group_id           IN       NUMBER,
  p_budget_workflow_rule_id   IN       NUMBER,
  p_constraint_id             IN       NUMBER,
  p_default_Rule_id           IN       NUMBER,
  p_Parameter_Id              IN       NUMBER,
  p_position_set_group_id     IN       NUMBER,
  p_gl_budget_id              IN       NUMBER := FND_API.G_MISS_NUM,
/* Budget Revision Rules Enhancement Start */
  p_rule_id                   IN       VARCHAR2,
  p_apply_balance_flag        IN       VARCHAR2,
/* Budget Revision Rules Enhancement End */
  p_effective_start_date      IN       DATE,
  p_effective_end_date        IN       DATE,
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
    FROM   psb_set_relations
    WHERE  rowid = p_row_id
    FOR UPDATE of set_relation_id NOWAIT;
  Recinfo C%ROWTYPE;
  --
  l_gl_budget_id        psb_gl_budgets.gl_budget_id%TYPE ;
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

  -- Resolve the defaulted parameters.
  IF p_gl_budget_id = FND_API.G_MISS_NUM THEN
    l_gl_budget_id := NULL ;
  ELSE
    l_gl_budget_id := p_gl_budget_id ;
  END IF;
  -- End resolving defaulted parameters.

  OPEN C;
  FETCH C INTO Recinfo;
  --
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  --
  CLOSE C;
  --
  IF
  (
	 (Recinfo.set_relation_id =  p_set_relation_id)

	  AND (Recinfo.account_position_set_id =  p_account_position_set_id)

	  AND (   (Recinfo.allocation_rule_id =  p_allocation_Rule_id)
	       OR (    (Recinfo.allocation_rule_id IS NULL)
		   AND (p_allocation_Rule_id IS NULL)))

	  AND (   (Recinfo.budget_group_id =  p_budget_group_id)
	       OR (    (Recinfo.budget_group_id IS NULL)
		   AND (p_budget_group_id IS NULL)))

	  AND (   (Recinfo.budget_workflow_rule_id =  p_budget_workflow_rule_id)
	       OR (    (Recinfo.budget_workflow_rule_id IS NULL)
		   AND (p_budget_workflow_rule_id IS NULL)))

	  AND (   (Recinfo.constraint_id =  p_constraint_id)
	       OR (    (Recinfo.constraint_id IS NULL)
		   AND (p_constraint_id IS NULL)))

	  AND (   (Recinfo.default_rule_id =  p_default_Rule_id)
	       OR (    (Recinfo.default_rule_id IS NULL)
		   AND (p_default_Rule_id IS NULL)))

	  AND (   (Recinfo.parameter_id =  p_Parameter_Id)
	       OR (    (Recinfo.parameter_id IS NULL)
		   AND (p_Parameter_Id IS NULL)))

	  AND (   (Recinfo.position_set_group_id =  p_position_set_group_id)
	       OR (    (Recinfo.position_set_group_id IS NULL)
		   AND (p_position_set_group_id IS NULL)))

	  AND (   (Recinfo.gl_budget_id =  l_gl_budget_id)
	       OR (    (Recinfo.gl_budget_id IS NULL)
		   AND (l_gl_budget_id IS NULL)))

/* Budget Revision Rules Enhancement Start */
	  AND (   (Recinfo.rule_id =  p_rule_id)
	       OR (    (Recinfo.rule_id IS NULL)
		   AND (p_rule_id IS NULL)))

	  AND (   (Recinfo.apply_balance_flag =  p_apply_balance_flag)
	       OR (    (Recinfo.apply_balance_flag IS NULL)
		   AND (p_apply_balance_flag IS NULL)))
/* Budget Revision Rules Enhancement End */

	  AND (   (Recinfo.effective_start_date =  p_effective_start_date)
	       OR (    (Recinfo.effective_start_date IS NULL)
		   AND (p_effective_start_date IS NULL)))

	  AND (   (Recinfo.effective_end_date =  p_effective_end_date)
	       OR (    (Recinfo.effective_end_date IS NULL)
		   AND (p_effective_end_date IS NULL)))
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
    p_row_locked    := FND_API.G_FALSE;
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



/*=========================================================================+
 |                       PROCEDURE Update_Row                              |
 +=========================================================================*/
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
  p_set_relation_id           IN       NUMBER,
  p_account_position_set_id   IN       NUMBER,
  p_allocation_Rule_id        IN       NUMBER,
  p_budget_group_id           IN       NUMBER,
  p_budget_workflow_rule_id   IN       NUMBER,
  p_constraint_id             IN       NUMBER,
  p_default_Rule_id           IN       NUMBER,
  p_Parameter_Id              IN       NUMBER,
  p_position_set_group_id     IN       NUMBER,
  p_gl_budget_id              IN       NUMBER := FND_API.G_MISS_NUM,
/* Budget Revision Rules Enhancement Start */
  p_rule_id                   IN       VARCHAR2,
  p_apply_balance_flag        IN       VARCHAR2,
/* Budget Revision Rules Enhancement End */
  p_effective_start_date      IN       DATE,
  p_effective_end_date        IN       DATE,
  p_last_update_date          IN       DATE,
  p_last_updated_by           IN       NUMBER,
  p_last_update_login         IN       NUMBER
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_last_update_date    DATE   ;
  l_last_Updated_by     NUMBER ;
  l_last_update_login   NUMBER ;
  --
  l_gl_budget_id        psb_gl_budgets.gl_budget_id%TYPE ;
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

  -- Resolve the defaulted parameters.
  IF p_gl_budget_id = FND_API.G_MISS_NUM THEN
    l_gl_budget_id := NULL ;
  ELSE
    l_gl_budget_id := p_gl_budget_id ;
  END IF;
  -- End resolving defaulted parameters.

  --
  -- Set Global fields.
  --
  l_last_update_date := SYSDATE ;
  --
  l_last_Updated_by  := FND_GLOBAL.User_Id;
  IF l_last_Updated_by IS NULL THEN
    l_last_Updated_by := -1;
  END IF ;
  --
  l_last_update_login := FND_GLOBAL.Login_Id ;
  IF l_last_update_login IS NULL THEN
    l_last_update_login := -1;
  END IF;
  --

  UPDATE psb_set_relations
  SET
       set_relation_id                 =     p_set_relation_id,
       account_position_set_id         =     p_account_position_set_id,
       allocation_rule_id              =     p_allocation_Rule_id,
       budget_group_id                 =     p_budget_group_id,
       budget_workflow_rule_id         =     p_budget_workflow_rule_id,
       constraint_id                   =     p_constraint_id,
       default_rule_id                 =     p_default_Rule_id,
       parameter_id                    =     p_Parameter_Id,
       position_set_group_id           =     p_position_set_group_id,
       gl_budget_id                    =     l_gl_budget_id,
/* Budget Revision Rules Enhancement Start */
       rule_id                         =     p_rule_id,
       apply_balance_flag              =     p_apply_balance_flag,
/* Budget Revision Rules Enhancement End */
       effective_start_date            =     p_effective_start_date,
       effective_end_date              =     p_effective_end_date,
       last_update_date                =     l_last_update_date,
       last_updated_by                 =     l_last_Updated_by,
       last_update_login               =     l_last_update_login
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



/*=========================================================================+
 |                       PROCEDURE Delete_Row                              |
 +=========================================================================*/
PROCEDURE Delete_Row
( p_api_version               IN       NUMBER,
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

  DELETE psb_set_relations
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



/*=========================================================================+
 |                     PROCEDURE Delete_Entity_Relation                    |
 +=========================================================================*/
PROCEDURE Delete_Entity_Relation
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_entity_type               IN       VARCHAR2,
  p_entity_id                 IN       NUMBER
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Delete_Entity_Relation';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
BEGIN
  --
  SAVEPOINT  Delete_Entity_Relation_Pvt ;
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
  -- Finding all the sets for the given p_entity_id
  --
  FOR l_relations_rec IN
  (
    SELECT account_position_set_id   ,
	   account_or_position_type  ,
	   global_or_local_type      ,
	   set_relation_id
    FROM   psb_set_relations_v
    WHERE  DECODE( p_entity_type,
		     'AR',  allocation_rule_id,
		     'BG',  budget_group_id,
		     'BWR', budget_workflow_rule_id,
		     'C',   constraint_id,
		     'DR',  default_rule_id,
		     'P',   parameter_id,
		     'PSG', position_set_group_id,
		     'GBS', gl_budget_id,
/* Budget Revision Rules Enhancement Start */
		     'BRR', rule_id
/* Budget Revision Rules Enhancement End */
		 ) = p_entity_id
  )
  LOOP

    IF l_relations_rec.global_or_local_type = 'L' OR p_entity_type = 'BG' THEN

      --
      -- Delete all the set line values for position set related set lines.
      --
      IF l_relations_rec.account_or_position_type = 'P' THEN

	DELETE psb_position_set_line_values
	WHERE  line_sequence_id IN
	       (
		 SELECT line_sequence_id
		 FROM   psb_account_position_set_lines
		 WHERE  account_position_set_id =
				    l_relations_rec.account_position_set_id
	       ) ;

      END IF ;

      --
      -- Delete all the set lines for Local sets.
      --
      DELETE psb_account_position_set_lines
      WHERE  account_position_set_id =
				 l_relations_rec.account_position_set_id ;

      --
      -- Delete the set.
      --
      DELETE psb_account_position_sets
      WHERE  account_position_set_id = l_relations_rec.account_position_set_id ;
      --
    END IF;

    --
    -- Delete the relation.
    --
    DELETE psb_set_relations
    WHERE  set_relation_id = l_relations_rec.set_relation_id;

  END LOOP;

  /* Bug 1308558 Start */
  -- There is no need for this check as above are implicit cursors
  -- and the following condition will always become true and so will
  -- raise the error message.
  /*IF (SQL%NOTFOUND) THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF;*/
  /* Bug 1308558 End */


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
    ROLLBACK TO Delete_Entity_Relation_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Delete_Entity_Relation_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Delete_Entity_Relation_Pvt ;
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


END Delete_Entity_Relation;
/* ----------------------------------------------------------------------- */



/*=========================================================================+
 |                       PROCEDURE Check_Unique                            |
 +=========================================================================*/
--
-- This procedure is called to check duplicate global sets  for a given
-- entity.
--
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
  p_account_position_set_id   IN       NUMBER,
  p_account_or_position_Type  IN       VARCHAR2,
  p_entity_Type               IN       VARCHAR2,
  p_entity_Id                 IN       NUMBER,
/* Bug No 2131841 Start */
  p_apply_balance_flag        IN       VARCHAR2,
/* Bug No 2131841 End */
  p_return_value              IN OUT  NOCOPY   VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Unique';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_tmp VARCHAR2(1);

  CURSOR c IS
    SELECT '1'
    FROM  psb_set_relations_v
    WHERE account_or_position_type = p_account_or_position_type
    AND   DECODE( p_entity_type,
		    'AR',  allocation_rule_id,
		    'BG',  budget_group_id,
		    'BWR', budget_workflow_rule_id,
		    'C',   constraint_id,
		    'DR',  default_rule_id,
		    'P',   parameter_id,
		    'PSG', position_set_group_id,
		    'GBS', gl_budget_id,
/* Budget Revision Rules Enhancement Start */
		    'BRR', rule_id
/* Budget Revision Rules Enhancement End */
		 ) = p_entity_id

    AND   account_position_set_id = p_account_position_set_id
    AND   ( (p_row_id IS NULL)
	     OR (Row_Id <> p_row_id) );

/* Bug No 2131841 Start */
  CURSOR c1 IS
    SELECT '1'
    FROM  psb_set_relations_v
    WHERE account_or_position_type = p_account_or_position_type
    AND   DECODE( p_entity_type,
		    'AR',  allocation_rule_id,
		    'BG',  budget_group_id,
		    'BWR', budget_workflow_rule_id,
		    'C',   constraint_id,
		    'DR',  default_rule_id,
		    'P',   parameter_id,
		    'PSG', position_set_group_id,
		    'GBS', gl_budget_id,
		    'BRR', rule_id
		 ) = p_entity_id

    AND   account_position_set_id = p_account_position_set_id
    AND   ( (p_row_id IS NULL)
	     OR (Row_Id <> p_row_id) )
    AND   apply_balance_flag = p_apply_balance_flag;
/* Bug No 2131841 End */

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
/* Bug No 2131841 Start */
  IF p_entity_type = 'BRR' THEN
     OPEN c1;
     FETCH c1 INTO l_tmp;
  ELSE
     OPEN c;
     FETCH c INTO l_tmp;
  END IF;
/* BUG NO 2131841 END */

  -- p_return_value tells whether references exist or not.
  IF l_tmp IS NULL THEN
    p_return_value := 'FALSE';
  ELSE
    p_return_value := 'TRUE';
  END IF;

/* Bug No 2131841 Start */
  IF p_entity_type = 'BRR' THEN
    CLOSE c1;
  ELSE
    CLOSE c;
  END IF;
/* Bug No 2131841 End */

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


END PSB_Set_Relation_PVT;

/
