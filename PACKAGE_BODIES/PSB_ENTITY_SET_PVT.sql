--------------------------------------------------------
--  DDL for Package Body PSB_ENTITY_SET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_ENTITY_SET_PVT" AS
 /* $Header: PSBVESPB.pls 120.4.12010000.3 2009/04/02 15:47:55 rkotha ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_ENTITY_SET_PVT';
  -- The flag determines whether to print debug information or not.
  g_debug_flag          VARCHAR2(1) := 'N' ;

/* ---------------------- Private Procedures  -----------------------*/

  PROCEDURE  debug
  (
    p_message                   IN       VARCHAR2

  ) ;

  PROCEDURE Copy_Attributes
  (
    p_api_version               IN      NUMBER,
    p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE,
    p_commit                    IN      VARCHAR2 := FND_API.G_FALSE,
    p_validation_level          IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
    p_return_status             OUT  NOCOPY     VARCHAR2,
    p_msg_count                 OUT  NOCOPY     NUMBER,
    p_msg_data                  OUT  NOCOPY     VARCHAR2,
    p_source_entity_set_id      IN      NUMBER,
    p_source_data_extract_id    IN      NUMBER,
    p_target_data_extract_id    IN      NUMBER,
    p_entity_type               IN      VARCHAR2
  );

/* ------------------ End of Private Procedures  ----------------------*/

procedure INSERT_ROW (
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  P_ROWID in OUT  NOCOPY VARCHAR2,
  P_ENTITY_SET_ID in NUMBER,
  P_ENTITY_TYPE in VARCHAR2,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_BUDGET_GROUP_ID in NUMBER,
  P_SET_OF_BOOKS_ID in NUMBER,
  P_DATA_EXTRACT_ID IN NUMBER,
  P_CONSTRAINT_THRESHOLD in NUMBER,
  /* Budget Revision Rules Enhancement Start */
  P_ENABLE_FLAG in VARCHAR2,
  /* Budget Revision Rules Enhancement End */
  /* Bug 4151746 Start */
  P_EXECUTABLE_FROM_POSITION IN VARCHAR2 DEFAULT NULL,
  /* Bug 4151746 End */
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_CONTEXT in VARCHAR2,
  p_Last_Update_Date                   DATE,
  p_Last_Updated_By                    NUMBER,
  p_Last_Update_Login                  NUMBER,
  p_Created_By                         NUMBER,
  p_Creation_Date                      DATE
) is
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
    cursor C is select ROWID from PSB_ENTITY_SET
      where ENTITY_SET_ID = P_ENTITY_SET_ID;
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
  insert into PSB_ENTITY_SET (
    ENTITY_SET_ID,
    ENTITY_TYPE,
    NAME,
    DESCRIPTION,
    BUDGET_GROUP_ID,
    SET_OF_BOOKS_ID,
    DATA_EXTRACT_ID,
    CONSTRAINT_THRESHOLD,
    /* Budget Revision Rules Enhancement Start */
    ENABLE_FLAG,
    /* Budget Revision Rules Enhancement End */
    /* Bug 4151746 Start */
    EXECUTABLE_FROM_POSITION,
    /* Bug 4151746 End */
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    CONTEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_ENTITY_SET_ID,
    P_ENTITY_TYPE,
    P_NAME,
    P_DESCRIPTION,
    P_BUDGET_GROUP_ID,
    P_SET_OF_BOOKS_ID,
    P_DATA_EXTRACT_ID,
    P_CONSTRAINT_THRESHOLD,
    /* Budget Revision Rules Enhancement Start */
    P_ENABLE_FLAG,
    /* Budget Revision Rules Enhancement End */
    /* Bug 4151746 Start */
    P_EXECUTABLE_FROM_POSITION,
    /* Bug 4151746 End */
    P_ATTRIBUTE1,
    P_ATTRIBUTE2,
    P_ATTRIBUTE3,
    P_ATTRIBUTE4,
    P_ATTRIBUTE5,
    P_ATTRIBUTE6,
    P_ATTRIBUTE7,
    P_ATTRIBUTE8,
    P_ATTRIBUTE9,
    P_ATTRIBUTE10,
    P_CONTEXT,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN
  );
  open c;
  fetch c into P_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
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

procedure LOCK_ROW (
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  p_lock_row                  OUT  NOCOPY      VARCHAR2,
--
  P_ENTITY_SET_ID in NUMBER,
  P_ENTITY_TYPE in VARCHAR2,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_BUDGET_GROUP_ID in NUMBER,
  P_SET_OF_BOOKS_ID in NUMBER,
  P_DATA_EXTRACT_ID IN NUMBER,
  P_CONSTRAINT_THRESHOLD in NUMBER,
  /* Budget Revision Rules Enhancement Start */
  P_ENABLE_FLAG in VARCHAR2,
  /* Budget Revision Rules Enhancement End */
  /* Bug 4151746 Start */
  P_EXECUTABLE_FROM_POSITION IN VARCHAR2 DEFAULT NULL,
  /* Bug 4151746 End */
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_CONTEXT in VARCHAR2
) is
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  Counter NUMBER;
  cursor c1 is select
      ENTITY_TYPE,
      NAME,
      DESCRIPTION,
      BUDGET_GROUP_ID,
      SET_OF_BOOKS_ID,
      DATA_EXTRACT_ID,
      CONSTRAINT_THRESHOLD,
      /* Budget Revision Rules Enhancement Start */
      ENABLE_FLAG,
      /* Budget Revision Rules Enhancement End */
      /* Bug 4151746 Start */
      EXECUTABLE_FROM_POSITION,
      /* Bug 4151746 End */
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      CONTEXT
    from PSB_ENTITY_SET
    where ENTITY_SET_ID = P_ENTITY_SET_ID
    for update of ENTITY_SET_ID nowait;
  tlinfo c1%rowtype;
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
  --
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;
  if ( (tlinfo.ENTITY_TYPE = P_ENTITY_TYPE)
      AND ((tlinfo.NAME = P_NAME)
	   OR ((tlinfo.NAME is null)
	       AND (P_NAME is null)))
      AND ((tlinfo.DESCRIPTION = P_DESCRIPTION)
	   OR ((tlinfo.DESCRIPTION is null)
	       AND (P_DESCRIPTION is null)))
      AND ((tlinfo.BUDGET_GROUP_ID = P_BUDGET_GROUP_ID)
	   OR ((tlinfo.BUDGET_GROUP_ID is null)
	       AND (P_BUDGET_GROUP_ID is null)))
      AND ((tlinfo.SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID)
	   OR ((tlinfo.SET_OF_BOOKS_ID is null)
	       AND (P_SET_OF_BOOKS_ID is null)))
      AND ((tlinfo.DATA_EXTRACT_ID = P_DATA_EXTRACT_ID)
	   OR ((tlinfo.DATA_EXTRACT_ID is null)
	       AND (P_DATA_EXTRACT_ID is null)))
      AND ((tlinfo.CONSTRAINT_THRESHOLD = P_CONSTRAINT_THRESHOLD)
	   OR ((tlinfo.CONSTRAINT_THRESHOLD is null)
	       AND (P_CONSTRAINT_THRESHOLD is null)))
      /* Budget Revision Rules Enhancement Start */
      AND ((tlinfo.ENABLE_FLAG = P_ENABLE_FLAG)
	   OR ((tlinfo.ENABLE_FLAG is null)
	       AND (P_ENABLE_FLAG is null)))
      /* Budget Revision Rules Enhancement End */
      /* Bug 4151746 Start */
      AND ((tlinfo.EXECUTABLE_FROM_POSITION = P_EXECUTABLE_FROM_POSITION)
	   OR ((tlinfo.EXECUTABLE_FROM_POSITION is null)
	       AND (P_EXECUTABLE_FROM_POSITION is null)))
      /* Bug 4151746 End */
      AND ((tlinfo.ATTRIBUTE1 = P_ATTRIBUTE1)
	   OR ((tlinfo.ATTRIBUTE1 is null)
	       AND (P_ATTRIBUTE1 is null)))
      AND ((tlinfo.ATTRIBUTE2 = P_ATTRIBUTE2)
	   OR ((tlinfo.ATTRIBUTE2 is null)
	       AND (P_ATTRIBUTE2 is null)))
      AND ((tlinfo.ATTRIBUTE3 = P_ATTRIBUTE3)
	   OR ((tlinfo.ATTRIBUTE3 is null)
	       AND (P_ATTRIBUTE3 is null)))
      AND ((tlinfo.ATTRIBUTE4 = P_ATTRIBUTE4)
	   OR ((tlinfo.ATTRIBUTE4 is null)
	       AND (P_ATTRIBUTE4 is null)))
      AND ((tlinfo.ATTRIBUTE5 = P_ATTRIBUTE5)
	   OR ((tlinfo.ATTRIBUTE5 is null)
	       AND (P_ATTRIBUTE5 is null)))
      AND ((tlinfo.ATTRIBUTE6 = P_ATTRIBUTE6)
	   OR ((tlinfo.ATTRIBUTE6 is null)
	       AND (P_ATTRIBUTE6 is null)))
      AND ((tlinfo.ATTRIBUTE7 = P_ATTRIBUTE7)
	   OR ((tlinfo.ATTRIBUTE7 is null)
	       AND (P_ATTRIBUTE7 is null)))
      AND ((tlinfo.ATTRIBUTE8 = P_ATTRIBUTE8)
	   OR ((tlinfo.ATTRIBUTE8 is null)
	       AND (P_ATTRIBUTE8 is null)))
      AND ((tlinfo.ATTRIBUTE9 = P_ATTRIBUTE9)
	   OR ((tlinfo.ATTRIBUTE9 is null)
	       AND (P_ATTRIBUTE9 is null)))
      AND ((tlinfo.ATTRIBUTE10 = P_ATTRIBUTE10)
	   OR ((tlinfo.ATTRIBUTE10 is null)
	       AND (P_ATTRIBUTE10 is null)))
      AND ((tlinfo.CONTEXT = P_CONTEXT)
	   OR ((tlinfo.CONTEXT is null)
	       AND (P_CONTEXT is null)))
  ) then
     p_lock_row  :=  FND_API.G_TRUE;
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
    p_lock_row  :=  FND_API.G_FALSE;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_lock_row  :=  FND_API.G_FALSE;
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

procedure UPDATE_ROW (
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  P_ENTITY_SET_ID in NUMBER,
  P_ENTITY_TYPE in VARCHAR2,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_BUDGET_GROUP_ID in NUMBER,
  P_SET_OF_BOOKS_ID in NUMBER,
  P_DATA_EXTRACT_ID IN NUMBER,
  P_CONSTRAINT_THRESHOLD in NUMBER,
  /* Budget Revision Rules Enhancement Start */
  P_ENABLE_FLAG in VARCHAR2,
  /* Budget Revision Rules Enhancement End */
  /* Bug 4151746 Start */
  P_EXECUTABLE_FROM_POSITION IN VARCHAR2 DEFAULT NULL,
  /* Bug 4151746 End */
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_CONTEXT in VARCHAR2,
  p_Last_Update_Date                   DATE,
  p_Last_Updated_By                    NUMBER,
  p_Last_Update_Login                  NUMBER
) is
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
  update PSB_ENTITY_SET set
    ENTITY_TYPE = P_ENTITY_TYPE,
    NAME = P_NAME,
    DESCRIPTION = P_DESCRIPTION,
    BUDGET_GROUP_ID = P_BUDGET_GROUP_ID,
    SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID,
    DATA_EXTRACT_ID = P_DATA_EXTRACT_ID,
    CONSTRAINT_THRESHOLD = P_CONSTRAINT_THRESHOLD,
    /* Budget Revision Rules Enhancement Start */
    ENABLE_FLAG = P_ENABLE_FLAG,
    /* Budget Revision Rules Enhancement End */
    /* Bug 4151746 Start */
    EXECUTABLE_FROM_POSITION = P_EXECUTABLE_FROM_POSITION,
    /* Bug 4151746 End */
    ATTRIBUTE1 = P_ATTRIBUTE1,
    ATTRIBUTE2 = P_ATTRIBUTE2,
    ATTRIBUTE3 = P_ATTRIBUTE3,
    ATTRIBUTE4 = P_ATTRIBUTE4,
    ATTRIBUTE5 = P_ATTRIBUTE5,
    ATTRIBUTE6 = P_ATTRIBUTE6,
    ATTRIBUTE7 = P_ATTRIBUTE7,
    ATTRIBUTE8 = P_ATTRIBUTE8,
    ATTRIBUTE9 = P_ATTRIBUTE9,
    ATTRIBUTE10 = P_ATTRIBUTE10,
    CONTEXT = P_CONTEXT,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where ENTITY_SET_ID = P_ENTITY_SET_ID
  ;

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

procedure DELETE_ROW (
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  P_ENTITY_SET_ID in NUMBER
) is
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
  delete from PSB_ENTITY_SET
  where ENTITY_SET_ID = P_ENTITY_SET_ID;

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

PROCEDURE Copy_Entity_Set
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  p_source_entity_set_id        IN      NUMBER,
  p_target_entity_set_id        IN      NUMBER,
  p_target_data_extract_id      IN      NUMBER,
  p_entity_type                 IN      VARCHAR2
)
  AS

  l_api_name                   CONSTANT VARCHAR2(30)    := 'Copy_Parameter_Set';
  l_api_version                CONSTANT NUMBER  := 1.0;
  --
  l_last_update_date           DATE;
  l_last_updated_by            NUMBER;
  l_last_update_login          NUMBER;
  l_creation_date              DATE;
  l_created_by                 NUMBER;
  --
  l_set_name                   VARCHAR2(30);
  l_position_set_name          VARCHAR2(30);
  l_entity_name                VARCHAR2(30);
  l_rowid                      VARCHAR2(100);
  l_status                     VARCHAR2(1);
  l_return_status              VARCHAR2(1);
  l_msg_count                  NUMBER;
  l_msg_data                   VARCHAR2(1000);
  l_count                      NUMBER;
  l_entity_id                  NUMBER;
  l_source_entity_id           NUMBER;
  l_parameter_id               NUMBER;
  l_constraint_id              NUMBER;
/* Budget Revision Rules Enhancement Start */
  l_rule_id                    NUMBER;
/* Budget Revision Rules Enhancement End */
  l_source_parameter_id        NUMBER;
  l_set_relation_id            NUMBER;
  l_account_position_set_id    NUMBER;
  l_parameter_formula_id       NUMBER;
  l_constraint_formula_id      NUMBER;
  l_business_group_id          psb_data_extracts.business_group_id%TYPE ;
  l_source_data_extract_id     psb_data_extracts.data_extract_id%TYPE ;
  l_attribute_id               psb_attribute_values.attribute_id%TYPE;
  l_attribute_value_id         psb_attribute_values.attribute_value_id%TYPE;
  l_attribute_value            psb_attribute_values.attribute_value%TYPE;
  l_create_formula_flag        VARCHAR2(1);
  l_value_table_flag           psb_attributes.value_table_flag%TYPE;
  l_source_option_flag         psb_pay_elements.option_flag%TYPE;
  l_source_salary_flag         psb_pay_elements.salary_flag%TYPE;
  l_source_pay_element_id      psb_pay_elements.pay_element_id%TYPE;
  l_source_pay_element_option_id
			       psb_pay_element_options.pay_element_option_id%TYPE;
  l_source_element_value       psb_pay_element_rates.element_value%TYPE;
  l_target_pay_element_id      psb_pay_elements.pay_element_id%TYPE;
  l_target_pay_element_option_id
			       psb_pay_element_options.pay_element_option_id%TYPE;
  l_target_pay_element_rate_id psb_pay_element_rates.pay_element_rate_id%TYPE;


  CURSOR l_entity_set_csr IS
	 SELECT  *
	 FROM    psb_entity_set
	 WHERE   entity_set_id = p_source_entity_set_id ;
  --
  CURSOR l_find_position_set_id_csr IS
	 SELECT account_position_set_id
	 FROM   psb_account_position_sets
	 WHERE  name                    = l_position_set_name
	 and    data_extract_id         = p_target_data_extract_id ;
  --
  CURSOR l_find_attribute_value_id_csr IS
	 SELECT attribute_value_id
	 FROM   psb_attribute_values
	 WHERE  attribute_id            = l_attribute_id
	 and    attribute_value         = l_attribute_value
	 and    data_extract_id         = p_target_data_extract_id ;
  --
  CURSOR l_find_source_element_csr IS
	 SELECT pay_element_id ,
		option_flag    ,
		salary_flag
	 FROM   psb_pay_elements
	 WHERE  name            = (select name
				   from   psb_pay_elements
				   where  pay_element_id=l_source_pay_element_id)
	 and    data_extract_id = p_target_data_extract_id ;
  --
  CURSOR l_find_element_rate_csr IS
	 SELECT pay_element_rate_id
	 FROM   psb_pay_element_rates
	 WHERE  pay_element_id  = l_target_pay_element_id
	 and    element_value   = (select element_value
				   from   psb_pay_element_rates
				   where  pay_element_id=l_source_pay_element_id);
  --
  CURSOR l_find_element_option_csr IS
	 SELECT pay_element_option_id
	 FROM   psb_pay_element_options
	 WHERE  pay_element_id  = l_target_pay_element_id
	 and    name            = (select name
				   from   psb_pay_element_options
				   where  pay_element_option_id =
					  l_source_pay_element_option_id);
  --
  CURSOR l_find_element_option_rate_csr IS
	 SELECT pay_element_rate_id
	 FROM   psb_pay_element_rates
	 WHERE  pay_element_id        = l_target_pay_element_id
	 and    pay_element_option_id = l_target_pay_element_option_id
	 and    element_value         = (select element_value
					 from  psb_pay_element_rates
		    where pay_element_id =l_source_pay_element_id
		    and pay_element_option_id = l_source_pay_element_option_id);
  --
  CURSOR l_source_data_extract_csr IS
	 SELECT data_extract_id
	 FROM   psb_entity_set
	 WHERE  entity_set_id = p_source_entity_set_id ;
  --

  CURSOR l_parameter_formula_csr IS
      SELECT  *
      FROM    psb_parameter_formulas
      WHERE   parameter_id = l_source_entity_id;

  --
  CURSOR l_constraint_formula_csr IS
      SELECT  *
      FROM    psb_constraint_formulas
      WHERE   constraint_id = l_source_entity_id;
  --
  l_entity_set_rec                l_entity_set_csr%ROWTYPE ;
  l_source_data_extract_rec       l_source_data_extract_csr%ROWTYPE;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT Copy_Parameter_Set_Pvt;

  -- Standard call to check for call compatibility.

  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  -- Initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  l_last_update_date  := SYSDATE;
  l_last_updated_by   := FND_GLOBAL.USER_ID;
  l_last_update_login := FND_GLOBAL.LOGIN_ID;
  l_creation_date     := SYSDATE;
  l_created_by        := FND_GLOBAL.USER_ID;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate the input parameters.
  OPEN  l_source_data_extract_csr  ;
  FETCH l_source_data_extract_csr INTO l_source_data_extract_id ;
  CLOSE l_source_data_extract_csr ;

  IF l_source_data_extract_id IS NULL THEN

    Fnd_Message.Set_Name ('PSB',        'PSB_INVALID_DATA_EXTRACT') ;
    Fnd_Message.Set_Token('DATA_EXTRACT_ID', l_source_data_extract_id ) ;
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;

  ELSE

    SELECT business_group_id INTO l_business_group_id
    FROM   psb_data_extracts
    WHERE  data_extract_id = l_source_data_extract_id ;

  END IF ;

  -- Code to copy attributes in advance.

  OPEN  l_source_data_extract_csr  ;
  FETCH l_source_data_extract_csr INTO l_source_data_extract_rec ;
  CLOSE l_source_data_extract_csr ;

  PSB_ENTITY_SET_PVT.Copy_Attributes
  ( p_api_version               => 1.0,
    p_init_msg_list             => null,
    p_commit                    => null,
    p_validation_level          => null,
    p_return_status             => l_return_status,
    p_msg_count                 => l_msg_count,
    p_msg_data                  => l_msg_data,
    p_source_entity_set_id      => p_source_entity_set_id,
    p_source_data_extract_id    => l_source_data_extract_rec.data_extract_id,
    p_target_data_extract_id    => p_target_data_extract_id,
    p_entity_type               => p_entity_type
   );

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    debug( 'Copy Attributes Process Failed');

    RAISE FND_API.G_EXC_ERROR ;

  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    debug( 'Copy Attributes Process Failed');

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

  END IF;

  -- Code to copy all the desired position sets onto the target data extract

  -- A FOR loop which finds all the position sets associated with the
  -- source entity set.

  -- Creating entities
  FOR l_entity_rec IN
  (
    SELECT  pe.entity_id, pe.entity_type, pe.entity_subtype,
	    pe.name, pe.description, pe.data_extract_id,
	    pe.set_of_books_id, pe.budget_group_id, pe.allocation_type,
	    pe.budget_year_type_id, pe.balance_type,
	    pe.parameter_autoinc_rule, pe.parameter_compound_annually,
	    pe.currency_code, pe.fte_constraint,
	    pe.constraint_detailed_flag,
/* Budget Revision Rules Enhancement Start */
	    pe.apply_account_set_flag, pe.balance_account_set_flag,
/* Budget Revision Rules Enhancement End */
	    pe.attribute1, pe.attribute2,
	    pe.attribute3, pe.attribute4, pe.attribute5,
	    pe.attribute6, pe.attribute7, pe.attribute8,
	    pe.attribute9, pe.attribute10, pe.context,
	    pe.effective_start_date start_date, pe.effective_end_date end_date,
	    pea.priority,
	    pea.severity_level, pea.effective_start_date,
	    pea.effective_end_date
    FROM    psb_entity pe, psb_entity_assignment pea
    WHERE   pea.entity_set_id = p_source_entity_set_id
    and     pea.entity_id = pe.entity_id
  )
  LOOP

    debug( 'Creating entity for the entity id : ' ||
	    l_entity_rec.entity_id ) ;

    --use this assignment for formula rec
    l_source_entity_id := l_entity_rec.entity_id;

    SELECT psb_entity_s.nextval INTO l_entity_id
    FROM dual;

    -- Call Create parameter API.

    -- name for the new parameter
    l_count := 30-(length(l_entity_id)+1);

    IF length(l_entity_rec.name) < l_count THEN
    l_count := length(l_entity_rec.name);
    END IF;

    l_entity_name := substr(l_entity_rec.name,1,l_count)||'_'||
			to_char(l_entity_id);

    PSB_ENTITY_PVT.INSERT_ROW
    (
      p_api_version                 => 1.0,
      p_init_msg_list               => null,
      p_commit                      => null,
      p_validation_level            => null,
      p_return_status               => l_return_status,
      p_msg_count                   => l_msg_count,
      p_msg_data                    => l_msg_data,
      p_rowid                       => l_rowid,
      p_entity_id                   => l_entity_id,
      p_entity_type                 => l_entity_rec.entity_type,
      p_entity_subtype              => l_entity_rec.entity_subtype,
      p_name                        => l_entity_name,
      p_description                 => l_entity_rec.description,
      p_data_extract_id             => p_target_data_extract_id,
      p_set_of_books_id             => l_entity_rec.set_of_books_id,
      p_budget_group_id             => l_entity_rec.budget_group_id,
      p_allocation_type             => l_entity_rec.allocation_type,
      p_budget_year_type_id         => l_entity_rec.budget_year_type_id,
      p_balance_type                => l_entity_rec.balance_type,
      p_parameter_autoinc_rule      =>
				   l_entity_rec.parameter_autoinc_rule,
      p_parameter_compound_annually =>
				   l_entity_rec.parameter_compound_annually,
      p_currency_code               => l_entity_rec.currency_code,
      p_fte_constraint              => l_entity_rec.fte_constraint,
      p_constraint_detailed_flag    =>
				   l_entity_rec.constraint_detailed_flag,
/* Budget Revision Rules Enhancement Start */
      p_apply_account_set_flag      => l_entity_rec.apply_account_set_flag,
      p_balance_account_set_flag    => l_entity_rec.balance_account_set_flag,
/* Budget Revision Rules Enhancement End */
      p_attribute1                  => l_entity_rec.attribute1,
      p_attribute2                  => l_entity_rec.attribute2,
      p_attribute3                  => l_entity_rec.attribute3,
      p_attribute4                  => l_entity_rec.attribute4,
      p_attribute5                  => l_entity_rec.attribute5,
      p_attribute6                  => l_entity_rec.attribute6,
      p_attribute7                  => l_entity_rec.attribute7,
      p_attribute8                  => l_entity_rec.attribute8,
      p_attribute9                  => l_entity_rec.attribute9,
      p_attribute10                 => l_entity_rec.attribute10,
      p_context                     => l_entity_rec.context,
      p_effective_start_date        => l_entity_rec.start_date,
      p_effective_end_date          => l_entity_rec.end_date,
      p_last_update_date            => l_last_update_date,
      p_last_updated_by             => l_last_updated_by,
      p_last_update_login           => l_last_update_login,
      p_created_by                  => l_created_by,
      p_creation_date               => l_creation_date
    );

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      debug( 'Entity not Copied for Entity id : ' ||
	      l_entity_rec.entity_id);
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      debug( 'Entity not Copied for Entity id:' ||
	      l_entity_rec.entity_id);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;


    -- creating assignment between the copied parameter set and the
    -- copied parameters

    PSB_ENTITY_ASSIGNMENT_PVT.INSERT_ROW
    (
      p_api_version             => 1.0,
      p_init_msg_list           => null,
      p_commit                  => null,
      p_validation_level        => null,
      p_return_status           => l_return_status,
      p_msg_count               => l_msg_count,
      p_msg_data                => l_msg_data,
      p_rowid                   => l_rowid,
      p_entity_set_id           => p_target_entity_set_id,
      p_entity_id               => l_entity_id,
      p_priority                => l_entity_rec.priority,
      p_severity_level          => l_entity_rec.severity_level,
      p_effective_start_date    => l_entity_rec.effective_start_date,
      p_effective_end_date      => l_entity_rec.effective_end_date,
      p_last_update_date        => l_last_update_date,
      p_last_updated_by         => l_last_updated_by,
      p_last_update_login       => l_last_update_login,
      p_created_by              => l_created_by,
      p_creation_date           => l_creation_date
    );

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      debug( 'Assignment not created for Source and New
	      Entity Id:'||l_entity_rec.entity_id||','||l_entity_id);

      RAISE FND_API.G_EXC_ERROR ;

    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      debug( 'Assignment not created for Source and New
	      Entity Id:'||l_entity_rec.entity_id||','||l_entity_id);

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF;

    -- Code to copy sets associated with the parameter.
    FOR l_sets_rec IN
    (
      SELECT  pas.name, pas.account_or_position_type, psr.*
      FROM    psb_account_position_sets  pas,
	      psb_set_relations          psr
      WHERE   DECODE(p_entity_type,
			'P', psr.parameter_id,
			'C', psr.constraint_id,
/* Budget Revision Rules Enhancement Start */
			'BRR', psr.rule_id ) = l_entity_rec.entity_id
/* Budget Revision Rules Enhancement End */
      and     pas.account_position_set_id  = psr.account_position_set_id
     )
    LOOP

      IF l_sets_rec.account_or_position_type = 'A' THEN

	debug('Processing Account set ' || l_sets_rec.name);

	l_account_position_set_id := l_sets_rec.Account_Position_Set_Id;

      ELSIF l_sets_rec.account_or_position_type = 'P' THEN

	debug('Processing Position set ' || l_sets_rec.name);

	l_position_set_name := l_sets_rec.name ;
	l_account_position_set_id := NULL ;

	OPEN  l_find_position_set_id_csr  ;
	FETCH l_find_position_set_id_csr INTO l_account_position_set_id ;
	CLOSE l_find_position_set_id_csr ;

	debug ('Matching l_account_position_set_id before creation : ' ||
		l_account_position_set_id ) ;

	IF l_account_position_set_id IS NULL THEN

	  PSB_Account_Position_Set_Pvt.Copy_Position_Set
	  (
	    p_api_version              => 1.0,
	    p_init_msg_list            => null,
	    p_commit                   => null,
	    p_validation_level         => null,
	    p_return_status            => l_return_status,
	    p_msg_count                => l_msg_count,
	    p_msg_data                 => l_msg_data,
	    p_source_position_set_id   => l_sets_rec.account_position_set_id,
	    p_source_data_extract_id   => l_source_data_extract_id,
	    p_target_data_extract_id   => p_target_data_extract_id,
	    p_target_business_group_id => l_business_group_id,
	    p_new_position_set_id      => l_account_position_set_id
	  );

	  debug( 'New Position Set Id : ' || l_account_position_set_id);

	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    debug( 'Position Set not Copied for Source'||
	    l_sets_rec.account_position_set_id);

	    RAISE FND_API.G_EXC_ERROR ;

	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    debug( 'Position Set not Copied for Source'||
	    l_sets_rec.account_position_set_id);

	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

	  END IF;

	END IF; -- End checking whether to create a new position set or not.

      END IF;  -- End checking account position set type.

      IF l_sets_rec.account_or_position_type = 'A' OR
	 l_account_position_set_id IS NOT NULL
      THEN

	SELECT psb_set_relations_s.nextval INTO l_set_relation_id
	FROM dual;

	IF p_entity_type = 'P' THEN
	  l_parameter_id    := l_entity_id;
	  l_constraint_id   := l_sets_rec.constraint_id;
	  l_rule_id         := l_sets_rec.rule_id;
	ELSIF p_entity_type  = 'C' THEN
	  l_parameter_id    := l_sets_rec.parameter_id;
	  l_constraint_id   := l_entity_id;
	  l_rule_id         := l_sets_rec.rule_id;
/* Budget Revision Rules Enhancement Start */
	ELSIF p_entity_type  = 'BRR' THEN
	  l_parameter_id    := l_sets_rec.parameter_id;
	  l_constraint_id   := l_sets_rec.constraint_id;
	  l_rule_id         := l_entity_id;
/* Budget Revision Rules Enhancement End */
	END IF;

	PSB_SET_RELATION_PVT.INSERT_ROW
	(
	  p_api_version              =>  1.0,
	  p_init_msg_list            => null,
	  p_commit                   => null,
	  p_validation_level         => null,
	  p_return_status            => l_return_status,
	  p_msg_count                => l_msg_count,
	  p_msg_data                 => l_msg_data,
	  p_row_id                   => l_rowid,
	  p_Set_Relation_Id          => l_Set_Relation_Id,
	  p_Account_Position_Set_Id  => l_Account_Position_Set_Id,
	  p_Allocation_Rule_Id       => l_sets_rec.Allocation_Rule_Id,
	  p_Budget_Group_Id          => l_sets_rec.Budget_Group_Id,
	  p_Budget_Workflow_Rule_Id  => l_sets_rec.Budget_Workflow_Rule_Id,
	  p_Constraint_Id            => l_Constraint_Id,
	  p_Default_Rule_Id          => l_sets_rec.Default_Rule_Id,
	  p_Parameter_Id             => l_Parameter_Id,
	  p_Position_Set_Group_Id    => l_sets_rec.Position_Set_Group_Id,
/* Budget Revision Rules Enhancement Start */
	  p_Rule_Id                  => l_Rule_Id,
	  p_Apply_Balance_Flag       => l_sets_rec.Apply_Balance_Flag,
/* Budget Revision Rules Enhancement End */
	  p_Effective_Start_Date     => l_sets_rec.Effective_Start_Date,
	  p_Effective_End_Date       => l_sets_rec.Effective_End_Date,
	  p_last_update_date         => l_last_update_date,
	  p_last_updated_by          => l_last_updated_by,
	  p_last_update_login        => l_last_update_login,
	  p_created_by               => l_created_by,
	  p_creation_date            => l_creation_date
	);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  debug( 'Set Relation not created for:'||l_sets_rec.set_relation_id);
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  debug( 'Set Relation not created for:'||l_sets_rec.set_relation_id);
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;

      END IF;

    END LOOP; -- Processing sets within a parameter.

    -- Code to copy formulas associated with the parameter.
    -- Find the matching IDs based on the assignment type.

    IF p_entity_type ='P' THEN

    FOR l_para_formula_rec IN l_parameter_formula_csr

    LOOP

      l_create_formula_flag := 'N' ;

      IF l_entity_rec.entity_subtype = 'ACCOUNT' THEN
	l_create_formula_flag := 'Y' ;
      END IF;

      IF l_entity_rec.entity_subtype = 'POSITION' THEN

	IF l_para_formula_rec.assignment_type = 'ATTRIBUTE' THEN

	  debug('Processing Entity formula - attribute value :  ' ||
		 l_para_formula_rec.attribute_value );

	  l_attribute_id       := l_para_formula_rec.attribute_id;
	  l_attribute_value    := l_para_formula_rec.attribute_value;
	  l_attribute_value_id := NULL;

	  -- Find if the value table exists for the attribute.
	  SELECT NVL(value_table_flag, 'N') INTO l_value_table_flag
	  FROM   psb_attributes
	  WHERE  attribute_id = l_attribute_id ;

	  IF l_value_table_flag = 'Y' THEN

	    OPEN  l_find_attribute_value_id_csr  ;
	    FETCH l_find_attribute_value_id_csr INTO l_attribute_value_id ;
	    CLOSE l_find_attribute_value_id_csr ;

	    debug ('Found matching l_attribute_value_id : ' ||
		    l_attribute_value_id ) ;

	    IF l_attribute_value_id IS NOT NULL THEN
	       l_create_formula_flag := 'Y' ;
	    END IF ;

	  ELSIF l_value_table_flag = 'N' THEN

	    l_create_formula_flag := 'Y' ;

	  END IF ;

	ELSIF l_para_formula_rec.assignment_type = 'ELEMENT' THEN

	  l_source_pay_element_id        := l_para_formula_rec.pay_element_id;
	  l_source_pay_element_option_id :=
				     l_para_formula_rec.pay_element_option_id;
	  l_source_element_value         := l_para_formula_rec.element_value;
	  l_target_pay_element_id        := NULL;
	  l_target_pay_element_option_id := NULL;
	  l_target_pay_element_rate_id   := NULL;

	  OPEN  l_find_source_element_csr  ;
	  FETCH l_find_source_element_csr INTO
					l_target_pay_element_id,
					l_source_option_flag,
					l_source_salary_flag ;
	  CLOSE l_find_source_element_csr ;

	  --Call to create element used in the formula if it does not
	  --exist in target data extract

	  IF l_target_pay_element_id IS NULL THEN

	  OPEN  l_source_data_extract_csr  ;
	  FETCH l_source_data_extract_csr INTO l_source_data_extract_rec ;
	  CLOSE l_source_data_extract_csr ;

	  debug( 'Processing Copy Entity Element:'||
					   l_para_formula_rec.pay_element_id);

	  PSB_PAY_ELEMENTS_PVT.Copy_Pay_Elements
	  ( p_api_version             => 1.0,
	    p_init_msg_list           => null,
	    p_commit                  => null,
	    p_validation_level        => null,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_source_pay_element_id   => l_para_formula_rec.pay_element_id,
	    p_source_data_extract_id  => l_source_data_extract_rec.data_extract_id,
	    p_target_data_extract_id  => p_target_data_extract_id
	  );

	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    debug( 'Copy Entity Element Process Failed');
	    RAISE FND_API.G_EXC_ERROR ;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    debug( 'Copy Entity Element Process Failed');
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	  END IF;

	  END IF;

	  -- Check if the new element was created or not.
	  -- opened the cursor to get new element id, and option and salary flags

	  OPEN  l_find_source_element_csr  ;
	  FETCH l_find_source_element_csr INTO
					l_target_pay_element_id,
					l_source_option_flag,
					l_source_salary_flag ;
	  CLOSE l_find_source_element_csr ;

	  IF l_target_pay_element_id IS NOT NULL
	     -- and l_source_option_flag = l_target_option_flag
	     -- and l_source_salary_flag = l_target_salary_flag
	  THEN

	    IF l_source_option_flag = 'N' THEN

	      IF l_source_salary_flag = 'N' THEN

		l_create_formula_flag := 'Y' ;

	      ELSIF l_source_salary_flag = 'Y' THEN

		-- As per the element logic, the salary_type has to be 'VALUE'
		OPEN  l_find_element_rate_csr  ;
		FETCH l_find_element_rate_csr INTO
						l_target_pay_element_rate_id ;
		CLOSE l_find_element_rate_csr ;

		IF l_target_pay_element_rate_id IS NOT NULL THEN

		  l_create_formula_flag := 'Y' ;

		END IF ;

	      END IF;

	    ELSIF l_source_option_flag = 'Y' THEN

	      --The Salary flag check is for salary type and in this case
	      --we assume that salary type matches

	      IF l_source_salary_flag in ('N','Y') THEN

		OPEN  l_find_element_option_csr  ;
		FETCH l_find_element_option_csr INTO
						l_target_pay_element_option_id ;
		CLOSE l_find_element_option_csr ;

		OPEN  l_find_element_option_rate_csr  ;
		FETCH l_find_element_option_rate_csr INTO
						l_target_pay_element_rate_id ;
		CLOSE l_find_element_option_rate_csr ;

		IF l_target_pay_element_rate_id IS NOT NULL THEN

		  l_create_formula_flag := 'Y' ;

		END IF ; --target rate id check

	      END IF; --salary flag check

	    END IF; -- option flag check

	  ELSE

	    l_create_formula_flag := 'N' ;

	  END IF ; -- Checking element name in the target data extract.
  /* Start bug:5602565*/
  ELSIF l_entity_rec.parameter_autoinc_rule = 'Y'
     AND l_para_formula_rec.parameter_formula_id IS NOT NULL THEN
	     l_create_formula_flag := 'Y';
  /* End bug:5602565*/
	END IF ; -- Checking assignment type for a formula within an entity.

      END IF;-- checking entity subtype

      IF l_create_formula_flag = 'Y' THEN

	SELECT psb_parameter_formulas_s.nextval INTO l_parameter_formula_id
	FROM   dual;

	debug('Processing formula' || l_para_formula_rec.parameter_formula_id);

	PSB_PARAMETER_FORMULAS_PVT.INSERT_ROW
	( p_api_version                 => 1.0,
	  p_init_msg_list               => null,
	  p_commit                      => null,
	  p_validation_level            => null,
	  p_return_status               => l_return_status,
	  p_msg_count                   => l_msg_count,
	  p_msg_data                    => l_msg_data,
	  p_rowid                       => l_rowid,
	  p_parameter_formula_id        => l_parameter_formula_id,
	  p_parameter_id                => l_entity_id,
	  p_step_number                 => l_para_formula_rec.step_number,
		    p_budget_year_type_id               => l_para_formula_rec.budget_year_type_id,
	  p_balance_type                => l_para_formula_rec.balance_type,
	  p_template_id                 => l_para_formula_rec.template_id,
	  p_concatenated_segments       => l_para_formula_rec.concatenated_segments,
	  p_segment1                    => l_para_formula_rec.segment1,
	  p_segment2                    => l_para_formula_rec.segment2,
	  p_segment3                    => l_para_formula_rec.segment3,
	  p_segment4                    => l_para_formula_rec.segment4,
	  p_segment5                    => l_para_formula_rec.segment5,
	  p_segment6                    => l_para_formula_rec.segment6,
	  p_segment7                    => l_para_formula_rec.segment7,
	  p_segment8                    => l_para_formula_rec.segment8,
	  p_segment9                    => l_para_formula_rec.segment9,
	  p_segment10                   => l_para_formula_rec.segment10,
	  p_segment11                   => l_para_formula_rec.segment11,
	  p_segment12                   => l_para_formula_rec.segment12,
	  p_segment13                   => l_para_formula_rec.segment13,
	  p_segment14                   => l_para_formula_rec.segment14,
	  p_segment15                   => l_para_formula_rec.segment15,
	  p_segment16                   => l_para_formula_rec.segment16,
	  p_segment17                   => l_para_formula_rec.segment17,
	  p_segment18                   => l_para_formula_rec.segment18,
	  p_segment19                   => l_para_formula_rec.segment19,
	  p_segment20                   => l_para_formula_rec.segment20,
	  p_segment21                   => l_para_formula_rec.segment21,
	  p_segment22                   => l_para_formula_rec.segment22,
	  p_segment23                   => l_para_formula_rec.segment23,
	  p_segment24                   => l_para_formula_rec.segment24,
	  p_segment25                   => l_para_formula_rec.segment25,
	  p_segment26                   => l_para_formula_rec.segment26,
	  p_segment27                   => l_para_formula_rec.segment27,
	  p_segment28                   => l_para_formula_rec.segment28,
	  p_segment29                   => l_para_formula_rec.segment29,
	  p_segment30                   => l_para_formula_rec.segment30,
	  p_currency_code               => l_para_formula_rec.currency_code,
	  p_amount                      => l_para_formula_rec.amount,
	  p_prefix_operator             => l_para_formula_rec.prefix_operator,
	  p_postfix_operator            => l_para_formula_rec.postfix_operator,
	  p_hiredate_between_FROM       =>
					l_para_formula_rec.hiredate_between_from,
	  p_hiredate_between_to         => l_para_formula_rec.hiredate_between_to,
	  p_adjdate_between_FROM        =>
					l_para_formula_rec.adjdate_between_from,
	  p_adjdate_between_to          => l_para_formula_rec.adjdate_between_to,
	  p_increment_by                => l_para_formula_rec.increment_by,
	  p_increment_type              => l_para_formula_rec.increment_type,
	  p_assignment_type             => l_para_formula_rec.assignment_type,
	  p_attribute_id                => l_para_formula_rec.attribute_id,
	  p_attribute_value             => l_para_formula_rec.attribute_value,
	  p_pay_element_id              => l_target_pay_element_id,
	  p_pay_element_option_id       => l_target_pay_element_option_id,
	  p_grade_step                  => l_para_formula_rec.grade_step,
	  p_element_value               => l_para_formula_rec.element_value,
	  p_element_value_type          => l_para_formula_rec.element_value_type,
	  p_effective_start_date        =>
					 l_para_formula_rec.effective_start_date,
	  p_effective_end_date          => l_para_formula_rec.effective_end_date,
	  p_attribute1                  => l_para_formula_rec.attribute1,
	  p_attribute2                  => l_para_formula_rec.attribute2,
	  p_attribute3                  => l_para_formula_rec.attribute3,
	  p_attribute4                  => l_para_formula_rec.attribute4,
	  p_attribute5                  => l_para_formula_rec.attribute5,
	  p_attribute6                  => l_para_formula_rec.attribute6,
	  p_attribute7                  => l_para_formula_rec.attribute7,
	  p_attribute8                  => l_para_formula_rec.attribute8,
	  p_attribute9                  => l_para_formula_rec.attribute9,
	  p_attribute10                 => l_para_formula_rec.attribute10,
	  p_context                     => l_para_formula_rec.context,
	  p_last_update_date            => l_last_update_date,
	  p_last_updated_by             => l_last_updated_by,
	  p_last_update_login           => l_last_update_login,
	  p_created_by                  => l_created_by,
	  p_creation_date               => l_creation_date
	);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  debug( 'Formula not created for:' ||
		  l_para_formula_rec.parameter_formula_id);
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  debug( 'Formula not created for:' ||
		  l_para_formula_rec.parameter_formula_id);
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;

      END IF; -- Checking position sub type while processing
	      -- a formula within a parameter.

    END LOOP; -- Processing formulas within a parameter.

    ELSIF

    p_entity_type = 'C' THEN

    FOR l_const_formula_rec IN l_constraint_formula_csr

    LOOP

      l_create_formula_flag := 'N' ;

      IF l_entity_rec.entity_subtype = 'ACCOUNT' THEN
	l_create_formula_flag := 'Y' ;
      END IF;

      IF l_entity_rec.entity_subtype = 'POSITION' THEN

	  l_source_pay_element_id        := l_const_formula_rec.pay_element_id;
	  l_source_pay_element_option_id :=
				       l_const_formula_rec.pay_element_option_id;
	  l_source_element_value         := l_const_formula_rec.element_value;
	  l_target_pay_element_id        := NULL;
	  l_target_pay_element_option_id := NULL;
	  l_target_pay_element_rate_id   := NULL;

	  OPEN  l_find_source_element_csr  ;
	  FETCH l_find_source_element_csr INTO
					l_target_pay_element_id,
					l_source_option_flag,
					l_source_salary_flag ;
	  CLOSE l_find_source_element_csr ;

	  --Call to create element used in the constraint if it does not
	  --exist in target data extract

	  IF l_target_pay_element_id IS NULL THEN

	  OPEN  l_source_data_extract_csr  ;
	  FETCH l_source_data_extract_csr INTO l_source_data_extract_rec ;
	  CLOSE l_source_data_extract_csr ;

	  debug( 'Processing Copy Entity Element:'||
					     l_const_formula_rec.pay_element_id);

	  PSB_PAY_ELEMENTS_PVT.Copy_Pay_Elements
	  ( p_api_version             => 1.0,
	    p_init_msg_list           => null,
	    p_commit                  => null,
	    p_validation_level        => null,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_source_pay_element_id   => l_const_formula_rec.pay_element_id,
	    p_source_data_extract_id  => l_source_data_extract_rec.data_extract_id,
	    p_target_data_extract_id  => p_target_data_extract_id
	  );

	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    debug( 'Copy Entity Element Process Failed');
	    RAISE FND_API.G_EXC_ERROR ;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    debug( 'Copy Entity Element Process Failed');
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	  END IF;

	  END IF;

	  -- Check if the new element was created or not.
	  -- opened the cursor to get new element id, and option and salary flags

	  OPEN  l_find_source_element_csr  ;
	  FETCH l_find_source_element_csr INTO
					l_target_pay_element_id,
					l_source_option_flag,
					l_source_salary_flag ;
	  CLOSE l_find_source_element_csr ;

	  IF l_target_pay_element_id IS NOT NULL
	     -- and l_source_option_flag = l_target_option_flag
	     -- and l_source_salary_flag = l_target_salary_flag
	  THEN

	    IF l_source_option_flag = 'N' THEN

	      IF l_source_salary_flag = 'N' THEN

		l_create_formula_flag := 'Y' ;

	      ELSIF l_source_salary_flag = 'Y' THEN

		-- As per the element logic, the salary_type has to be 'VALUE'
		OPEN  l_find_element_rate_csr  ;
		FETCH l_find_element_rate_csr INTO
						l_target_pay_element_rate_id ;
		CLOSE l_find_element_rate_csr ;

		IF l_target_pay_element_rate_id IS NOT NULL THEN

		  l_create_formula_flag := 'Y' ;

		END IF ;

	      END IF;

	    ELSIF l_source_option_flag = 'Y' THEN

	      --The Salary flag check is for salary type and in this case
	      --we assume that salary type matches

	      IF l_source_salary_flag in ('N','Y') THEN

		OPEN  l_find_element_option_csr  ;
		FETCH l_find_element_option_csr INTO
						l_target_pay_element_option_id ;
		CLOSE l_find_element_option_csr ;

		OPEN  l_find_element_option_rate_csr  ;
		FETCH l_find_element_option_rate_csr INTO
						l_target_pay_element_rate_id ;
		CLOSE l_find_element_option_rate_csr ;

		IF l_target_pay_element_rate_id IS NOT NULL THEN

		   l_create_formula_flag := 'Y' ;

		END IF ;

	      END IF;--Salary flag check

	    END IF;--option flag check

	  ELSE

	     l_create_formula_flag := 'N' ;

	   END IF ; -- Checking element name in the target data extract.

      END IF;--checking entity_subtype

      IF l_create_formula_flag = 'Y' THEN

	SELECT psb_constraint_formulas_s.nextval INTO l_constraint_formula_id
	FROM   dual;

	debug('Processing formula for constraint_formula_id: ' ||
			  l_const_formula_rec.constraint_formula_id);

	PSB_CONSTRAINT_FORMULAS_PVT.INSERT_ROW
	( p_api_version                 => 1.0,
	  p_init_msg_list               => null,
	  p_commit                      => null,
	  p_validation_level            => null,
	  p_return_status               => l_return_status,
	  p_msg_count                   => l_msg_count,
	  p_msg_data                    => l_msg_data,
	  p_rowid                       => l_rowid,
	  p_constraint_formula_id       => l_constraint_formula_id,
	  p_constraint_id               => l_entity_id,
	  p_step_number                 => l_const_formula_rec.step_number,
	  p_budget_year_type_id         => l_const_formula_rec.budget_year_type_id,
	  p_balance_type                => l_const_formula_rec.balance_type,
	  p_currency_code               => l_const_formula_rec.currency_code,
	  p_template_id                 => l_const_formula_rec.template_id,
	  p_segment1                    => l_const_formula_rec.segment1,
	  p_segment2                    => l_const_formula_rec.segment2,
	  p_segment3                    => l_const_formula_rec.segment3,
	  p_segment4                    => l_const_formula_rec.segment4,
	  p_segment5                    => l_const_formula_rec.segment5,
	  p_segment6                    => l_const_formula_rec.segment6,
	  p_segment7                    => l_const_formula_rec.segment7,
	  p_segment8                    => l_const_formula_rec.segment8,
	  p_segment9                    => l_const_formula_rec.segment9,
	  p_segment10                   => l_const_formula_rec.segment10,
	  p_segment11                   => l_const_formula_rec.segment11,
	  p_segment12                   => l_const_formula_rec.segment12,
	  p_segment13                   => l_const_formula_rec.segment13,
	  p_segment14                   => l_const_formula_rec.segment14,
	  p_segment15                   => l_const_formula_rec.segment15,
	  p_segment16                   => l_const_formula_rec.segment16,
	  p_segment17                   => l_const_formula_rec.segment17,
	  p_segment18                   => l_const_formula_rec.segment18,
	  p_segment19                   => l_const_formula_rec.segment19,
	  p_segment20                   => l_const_formula_rec.segment20,
	  p_segment21                   => l_const_formula_rec.segment21,
	  p_segment22                   => l_const_formula_rec.segment22,
	  p_segment23                   => l_const_formula_rec.segment23,
	  p_segment24                   => l_const_formula_rec.segment24,
	  p_segment25                   => l_const_formula_rec.segment25,
	  p_segment26                   => l_const_formula_rec.segment26,
	  p_segment27                   => l_const_formula_rec.segment27,
	  p_segment28                   => l_const_formula_rec.segment28,
	  p_segment29                   => l_const_formula_rec.segment29,
	  p_segment30                   => l_const_formula_rec.segment30,
	  p_amount                      => l_const_formula_rec.amount,
	  p_prefix_operator             => l_const_formula_rec.prefix_operator,
	  p_postfix_operator            => l_const_formula_rec.postfix_operator,
	  p_pay_element_id              => l_target_pay_element_id,
	  p_pay_element_option_id       => l_target_pay_element_option_id,
	  p_allow_modify                => l_const_formula_rec.allow_modify,
	  p_element_value               => l_const_formula_rec.element_value,
	  p_element_value_type          =>
					 l_const_formula_rec.element_value_type,
	  p_effective_start_date        =>
					 l_const_formula_rec.effective_start_date,
	  p_effective_end_date          => l_const_formula_rec.effective_end_date,
	  p_attribute1                  => l_const_formula_rec.attribute1,
	  p_attribute2                  => l_const_formula_rec.attribute2,
	  p_attribute3                  => l_const_formula_rec.attribute3,
	  p_attribute4                  => l_const_formula_rec.attribute4,
	  p_attribute5                  => l_const_formula_rec.attribute5,
	  p_context                     => l_const_formula_rec.context,
	  p_concatenated_segments       =>
					l_const_formula_rec.concatenated_segments,
	  p_last_update_date            => l_last_update_date,
	  p_last_updated_by             => l_last_updated_by,
	  p_last_update_login           => l_last_update_login,
	  p_created_by                  => l_created_by,
	  p_creation_date               => l_creation_date
	);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  debug( 'Constraint not created for:' ||
		  l_const_formula_rec.constraint_formula_id);
	  RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  debug( 'Constraint not created for:' ||
		  l_const_formula_rec.constraint_formula_id);
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;

      END IF; -- Checking account or position sub type while processing
	      -- a constraint within a parameter.

    END LOOP; -- Processing formulas within a constraint

   END IF; --Checking for entity type

  END LOOP; -- Processing parameters.


  -- Standard check of p_commit.
  IF FND_API.to_Boolean (p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Copy_Parameter_Set_Pvt;

    p_return_status := FND_API.G_RET_STS_ERROR;

    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			       p_data  => p_msg_data);


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Copy_Parameter_Set_Pvt;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			       p_data  => p_msg_data);

  WHEN OTHERS THEN

    ROLLBACK TO Copy_Parameter_Set_Pvt;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

    FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
			     l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			       p_data  => p_msg_data);

END Copy_Entity_Set;

/*==========================================================================+
|                  PROCEDURE Copy_Attributes (Private)                      |
+===========================================================================*/
--
-- Procedure to copy attributes associated with position sets
-- and formulas for parameters and constraints

 PROCEDURE Copy_Attributes
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  p_source_entity_set_id        IN      NUMBER,
  p_source_data_extract_id      IN      NUMBER,
  p_target_data_extract_id      IN      NUMBER,
  p_entity_type                 IN      VARCHAR2

) AS

  l_api_name                    CONSTANT VARCHAR2(30)   := 'Copy_Attributes';
  l_api_version                 CONSTANT NUMBER         := 1.0;
  l_last_update_date            DATE;
  l_last_updated_by             NUMBER;
  l_last_update_login           NUMBER;
  l_creation_date               DATE;
  l_created_by                  NUMBER;
  l_name                        VARCHAR2(30);
  l_rowid                       VARCHAR2(100);
  l_status                      VARCHAR2(1);
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(1000);
  l_count                       NUMBER := 0;
  l_attribute_value             psb_attribute_values.attribute_value%TYPE;
  l_attribute_id                NUMBER;
  l_attribute_value_id          NUMBER;

  CURSOR l_attr_value_csr IS
      (
	SELECT DISTINCT lines.attribute_id, attr_values.attribute_value
	FROM   psb_entity_assignment           assgn,
	       psb_entity                      entity,
	       psb_set_relations               rels,
	       psb_account_position_sets       sets,
	       psb_account_position_set_lines  lines,
	       psb_position_set_line_values    pos_val,
	       psb_attributes                  attrs,
	       psb_attribute_values            attr_values
	WHERE  assgn.entity_set_id           = p_source_entity_set_id
	and    assgn.entity_id               = entity.entity_id
	and    entity.entity_subtype         = 'POSITION'
	and    DECODE(p_entity_type,
			'P', rels.parameter_id,
			'C', rels.constraint_id) = entity.entity_id
	and    sets.account_position_set_id  = rels.account_position_set_id
	and    sets.account_position_set_id  = lines.account_position_set_id
	and    attrs.attribute_id            = lines.attribute_id
	and    attrs.attribute_id            = attr_values.attribute_id
	and    attr_values.data_extract_id   = p_source_data_extract_id
	and    attrs.value_table_flag        = 'Y'
	and    lines.line_sequence_id        = pos_val.line_sequence_id
	and    pos_val.attribute_value_id    = attr_values.attribute_value_id
      )
      UNION
      (
	SELECT DISTINCT formulas.attribute_id, attr_values.attribute_value
	FROM   psb_entity_assignment         assgn,
	       psb_entity                    entity,
	       psb_parameter_formulas        formulas,
	       psb_attributes                attrs,
	       psb_attribute_values          attr_values
	WHERE  assgn.entity_set_id         = p_source_entity_set_id
	and    assgn.entity_id             = entity.entity_id
	and    entity.entity_subtype       = 'POSITION'
	and    formulas.parameter_id       = entity.entity_id
	and    formulas.assignment_type    = 'ATTRIBUTE'
	and    formulas.attribute_id       = attrs.attribute_id
	and    attrs.value_table_flag      = 'Y'
	and    attrs.attribute_id          = attr_values.attribute_id
	and    attr_values.data_extract_id = p_source_data_extract_id
      );

  CURSOR l_attribute_value_csr IS
       SELECT  attr_values.*
	FROM   psb_attributes                attrs,
	       psb_attribute_values          attr_values
	WHERE  attrs.value_table_flag      = 'Y'
	and    attrs.attribute_id          = l_attribute_id
	and    attr_values.attribute_value = l_attribute_value
	and    attr_values.data_extract_id = p_source_data_extract_id;

  l_attribute_value_rec l_attribute_value_csr%ROWTYPE;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT Copy_Attributes_Pvt;

  -- Standard call to check for call compatibility.

  IF not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  l_last_update_date  := SYSDATE;
  l_last_updated_by   := FND_GLOBAL.USER_ID;
  l_last_update_login := FND_GLOBAL.LOGIN_ID;
  l_creation_date     := SYSDATE;
  l_created_by        := FND_GLOBAL.USER_ID;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  FOR l_attr_value_rec IN l_attr_value_csr
  LOOP

    l_attribute_id := l_attr_value_rec.attribute_id;
    l_attribute_value := l_attr_value_rec.attribute_value;

    SELECT  count(*) into l_count
    FROM    psb_attributes                attrs,
	    psb_attribute_values          attr_values
    WHERE   attrs.value_table_flag      = 'Y'
    and     attrs.attribute_id          = l_attribute_id
    and     attr_values.attribute_value = l_attribute_value
    and     attr_values.data_extract_id = p_target_data_extract_id;

    IF l_count = 0 THEN

      OPEN  l_attribute_value_csr;
      FETCH l_attribute_value_csr INTO l_attribute_value_rec;
      CLOSE l_attribute_value_csr;

      SELECT psb_attribute_values_s.nextval INTO l_attribute_value_id
      FROM   dual;

      PSB_ATTRIBUTE_VALUES_PVT.INSERT_ROW
      ( p_api_version             =>  1.0,
	p_init_msg_list           => null,
	p_commit                  => null,
	p_validation_level        => null,
	p_return_status           => l_return_status,
	p_msg_count               => l_msg_count,
	p_msg_data                => l_msg_data,
	p_rowid                   => l_rowid,
	p_attribute_value_id      => l_attribute_value_id,
	p_attribute_id            => l_attribute_value_rec.attribute_id,
	p_attribute_value         => l_attribute_value_rec.attribute_value,
	p_hr_value_id             => l_attribute_value_rec.hr_value_id,
	p_description             => l_attribute_value_rec.description,
	p_data_extract_id         => p_target_data_extract_id,
	p_context                 => l_attribute_value_rec.context,
	p_attribute1              => l_attribute_value_rec.attribute1,
	p_attribute2              => l_attribute_value_rec.attribute2,
	p_attribute3              => l_attribute_value_rec.attribute3,
	p_attribute4              => l_attribute_value_rec.attribute4,
	p_attribute5              => l_attribute_value_rec.attribute5,
	p_attribute6              => l_attribute_value_rec.attribute6,
	p_attribute7              => l_attribute_value_rec.attribute7,
	p_attribute8              => l_attribute_value_rec.attribute8,
	p_attribute9              => l_attribute_value_rec.attribute9,
	p_attribute10             => l_attribute_value_rec.attribute10,
	p_attribute11             => l_attribute_value_rec.attribute11,
	p_attribute12             => l_attribute_value_rec.attribute12,
	p_attribute13             => l_attribute_value_rec.attribute13,
	p_attribute14             => l_attribute_value_rec.attribute14,
	p_attribute15             => l_attribute_value_rec.attribute15,
	p_attribute16             => l_attribute_value_rec.attribute16,
	p_attribute17             => l_attribute_value_rec.attribute17,
	p_attribute18             => l_attribute_value_rec.attribute18,
	p_attribute19             => l_attribute_value_rec.attribute19,
	p_attribute20             => l_attribute_value_rec.attribute20,
	p_attribute21             => l_attribute_value_rec.attribute21,
	p_attribute22             => l_attribute_value_rec.attribute22,
	p_attribute23             => l_attribute_value_rec.attribute23,
	p_attribute24             => l_attribute_value_rec.attribute24,
	p_attribute25             => l_attribute_value_rec.attribute25,
	p_attribute26             => l_attribute_value_rec.attribute26,
	p_attribute27             => l_attribute_value_rec.attribute27,
	p_attribute28             => l_attribute_value_rec.attribute28,
	p_attribute29             => l_attribute_value_rec.attribute29,
	p_attribute30             => l_attribute_value_rec.attribute30,
	p_last_update_date        => l_last_update_date,
	p_last_updated_by         => l_last_updated_by,
	p_last_update_login       => l_last_update_login,
	p_created_by              => l_created_by,
	p_creation_date           => l_creation_date
      );

      debug( 'Attribute created for attribute value id'||l_attribute_value_id);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	debug( 'Attribute not created for attribute value id'||
	l_attribute_value_rec.attribute_value_id);

	RAISE FND_API.G_EXC_ERROR ;

      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	debug( 'Attribute not created for attribute value id'||
	l_attribute_value_rec.attribute_value_id);

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

      END IF;

    END IF;

  END LOOP;


  -- End of API body.

  -- Standard check of p_commit.

  IF FND_API.to_Boolean (p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Copy_Attributes_Pvt;

    p_return_status := FND_API.G_RET_STS_ERROR;

    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			       p_data  => p_msg_data);


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Copy_Attributes_Pvt;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			       p_data  => p_msg_data);

  WHEN OTHERS THEN

    ROLLBACK TO Copy_Attributes_Pvt;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

    FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
			     l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			       p_data  => p_msg_data);
END Copy_Attributes;

/*---------------------------------------------------------------------------*/

/*For Bug No : 2397852 Start*/

PROCEDURE Check_References
(
  p_api_version               IN             NUMBER,
  p_init_msg_list             IN             VARCHAR2,
  p_commit                    IN             VARCHAR2,
  p_validation_level          IN             NUMBER,
  p_return_status             OUT    NOCOPY  VARCHAR2,
  p_msg_count                 OUT    NOCOPY  NUMBER,
  p_msg_data                  OUT    NOCOPY  VARCHAR2,
  --
  p_entity_set_id             IN             NUMBER,
  p_return_value              OUT    NOCOPY  VARCHAR2
)
IS
  --
  l_api_name                  CONSTANT       VARCHAR2(30)   := 'Check_References';
  l_api_version               CONSTANT       NUMBER         :=  1.0;
  l_return_value                             VARCHAR2(5)    := 'FALSE';
  --
CURSOR c_check_references_ws IS
    SELECT 1
      FROM DUAL
     WHERE EXISTS(
                  SELECT 1
                    FROM PSB_WORKSHEETS
                   WHERE ((parameter_set_id = p_entity_set_id)
                          OR
                          (constraint_set_id = p_entity_set_id)
                          OR
                          (allocrule_set_id = p_entity_set_id))
                 );

CURSOR c_check_references_br IS
    SELECT 1
      FROM DUAL
     WHERE EXISTS(
                  SELECT 1
                    FROM PSB_BUDGET_REVISIONS
                   WHERE ((parameter_set_id = p_entity_set_id)
                          OR
                          (constraint_set_id = p_entity_set_id))
                  );
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

  IF ( FND_API.To_Boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  FOR c_check_references_ws_rec IN c_check_references_ws LOOP
    l_return_value := 'TRUE' ;
  END LOOP;

  IF l_return_value <> 'TRUE' THEN

    FOR c_check_references_br_rec IN c_check_references_br LOOP
      l_return_value := 'TRUE' ;
    END LOOP;

  END IF;

  IF ( FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                              p_data  => p_msg_data );

  p_return_value  := l_return_value;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Check_References_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    p_return_value  := l_return_value;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Check_References_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_return_value  := l_return_value;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
  WHEN OTHERS THEN
    --
    ROLLBACK TO Check_References_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_return_value  := l_return_value;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
  --
END Check_References;

/*For Bug No : 2397852 End*/


/*===========================================================================+
 |                     PROCEDURE debug (Private)                                |
 +===========================================================================*/
--
-- Private procedure to print debug info

PROCEDURE debug
(
  p_message                   IN   VARCHAR2
)
IS
--
BEGIN

  IF g_debug_flag = 'Y' THEN
    null;
--  dbms_output.put_line(p_message) ;
  END IF;

END debug ;


end PSB_ENTITY_SET_PVT;

/
