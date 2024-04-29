--------------------------------------------------------
--  DDL for Package Body PSB_WORKSHEET_CONSOLIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WORKSHEET_CONSOLIDATE_PVT" AS
/* $Header: PSBPWCDB.pls 120.2 2005/07/13 11:22:58 shtripat ship $ */

  G_PKG_NAME CONSTANT   VARCHAR2(30):= 'PSB_WORKSHEET_CONSOLIDATE_PVT';

/* ----------------------------------------------------------------------- */

PROCEDURE Consolidate_Worksheets
( p_api_version          IN   NUMBER,
  p_init_msg_list        IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status        OUT NOCOPY  VARCHAR2,
  p_msg_count            OUT NOCOPY  NUMBER,
  p_msg_data             OUT NOCOPY  VARCHAR2,
  p_global_worksheet_id  IN   NUMBER
) IS

  l_api_name             CONSTANT VARCHAR2(30)   := 'Consolidate_Worksheets';
  l_api_version          CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Consolidate_Worksheets_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WORKSHEET_CONSOLIDATE.Consolidate_Worksheets
     (p_api_version => 1.0,
      p_return_status => p_return_status,
      p_global_worksheet_id => p_global_worksheet_id);

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Consolidate_Worksheets_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Consolidate_Worksheets_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     rollback to Consolidate_Worksheets_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Consolidate_Worksheets;

/* ----------------------------------------------------------------------- */

PROCEDURE Validate_Consolidation
( p_api_version          IN   NUMBER,
  p_init_msg_list        IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status        OUT NOCOPY  VARCHAR2,
  p_msg_count            OUT NOCOPY  NUMBER,
  p_msg_data             OUT NOCOPY  VARCHAR2,
  p_global_worksheet_id  IN   NUMBER
) IS

  l_api_name             CONSTANT VARCHAR2(30)   := 'Validate_Consolidation';
  l_api_version          CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WORKSHEET_CONSOLIDATE.Validate_Consolidation
     (p_api_version => 1.0,
      p_return_status => p_return_status,
      p_global_worksheet_id => p_global_worksheet_id);

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Validate_Consolidation;

/* ----------------------------------------------------------------------- */

PROCEDURE Insert_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT NOCOPY      VARCHAR2,
  p_msg_count                 OUT NOCOPY      NUMBER,
  p_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id                    IN OUT NOCOPY   VARCHAR2,
  p_global_worksheet_id       IN       NUMBER,
  p_local_worksheet_id        IN       NUMBER,
  p_last_update_date          IN       DATE,
  p_last_updated_by           IN       NUMBER,
  p_last_update_login         IN       NUMBER,
  p_created_by                IN       NUMBER,
  p_creation_date             IN       DATE,
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
  p_context                   IN       VARCHAR2
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  CURSOR C IS
    SELECT rowid
    FROM   psb_ws_consolidation_details
    WHERE  global_worksheet_id = p_global_worksheet_id
    AND    local_worksheet_id = p_local_worksheet_id;

BEGIN

  SAVEPOINT Insert_Row_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  INSERT INTO psb_ws_consolidation_details(
	      global_worksheet_id,
	      local_worksheet_id,
	      last_update_date ,
	      last_updated_by,
	      last_update_login,
	      created_by,
	      creation_date,
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
	      context)
  VALUES
	      (
	      p_global_worksheet_id,
	      p_local_worksheet_id,
	      p_last_update_date ,
	      p_last_updated_by,
	      p_last_update_login,
	      p_created_by,
	      p_creation_date,
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
	      p_context);

  OPEN C;
  FETCH C INTO p_row_id;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;
  CLOSE C;


  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

END Insert_Row;


PROCEDURE Lock_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT NOCOPY      VARCHAR2,
  p_msg_count                 OUT NOCOPY      NUMBER,
  p_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id                    IN       VARCHAR2,
  p_global_worksheet_id       IN       NUMBER,
  p_local_worksheet_id        IN       NUMBER,
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
  p_context                   IN       VARCHAR2,

  p_row_locked                OUT NOCOPY      VARCHAR2
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  Counter NUMBER;
  CURSOR C IS
       SELECT *
       FROM   psb_ws_consolidation_details
       WHERE  rowid = p_row_id
       FOR UPDATE NOWAIT;
  Recinfo C%ROWTYPE;

BEGIN

  SAVEPOINT Lock_Row_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  p_row_locked    := FND_API.G_TRUE ;

  OPEN C;

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
	 (Recinfo.global_worksheet_id =  p_global_worksheet_id)  AND
	 (Recinfo.local_worksheet_id =  p_local_worksheet_id)

	  AND ( (Recinfo.attribute1 =  p_attribute1)
		 OR ( (Recinfo.attribute1 IS NULL)
		       AND (p_attribute1 IS NULL)))

	  AND ( (Recinfo.attribute2 =  p_attribute2)
		 OR ( (Recinfo.attribute2 IS NULL)
		       AND (p_attribute2 IS NULL)))

	  AND ( (Recinfo.attribute3 =  p_attribute3)
		 OR ( (Recinfo.attribute3 IS NULL)
		       AND (p_attribute3 IS NULL)))

	  AND ( (Recinfo.attribute4 =  p_attribute4)
		 OR ( (Recinfo.attribute4 IS NULL)
		       AND (p_attribute4 IS NULL)))

	  AND ( (Recinfo.attribute5 =  p_attribute5)
		 OR ( (Recinfo.attribute5 IS NULL)
		       AND (p_attribute5 IS NULL)))

	  AND ( (Recinfo.attribute6 =  p_attribute6)
		 OR ( (Recinfo.attribute6 IS NULL)
		       AND (p_attribute6 IS NULL)))

	  AND ( (Recinfo.attribute7 =  p_attribute7)
		 OR ( (Recinfo.attribute7 IS NULL)
		       AND (p_attribute7 IS NULL)))

	  AND ( (Recinfo.attribute8 =  p_attribute8)
		 OR ( (Recinfo.attribute8 IS NULL)
		       AND (p_attribute8 IS NULL)))

	  AND ( (Recinfo.attribute9 =  p_attribute9)
		 OR ( (Recinfo.attribute9 IS NULL)
		       AND (p_attribute9 IS NULL)))

	  AND ( (Recinfo.attribute10 =  p_attribute10)
		 OR ( (Recinfo.attribute10 IS NULL)
		       AND (p_attribute10 IS NULL)))
	  AND ( (Recinfo.context =  p_context)
		 OR ( (Recinfo.context IS NULL)
		       AND (p_context IS NULL)))
   )

  THEN
    Null;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;


  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );

EXCEPTION

  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN

    ROLLBACK TO Lock_Row_Pvt ;
    p_row_locked := FND_API.G_FALSE;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

END Lock_Row;


PROCEDURE Update_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT NOCOPY      VARCHAR2,
  p_msg_count                 OUT NOCOPY      NUMBER,
  p_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id                    IN       VARCHAR2,
  p_global_worksheet_id       IN       NUMBER,
  p_local_worksheet_id        IN       NUMBER,
  p_last_update_date          IN       DATE,
  p_last_updated_by           IN       NUMBER,
  p_last_update_login         IN       NUMBER,
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
  p_context                   IN       VARCHAR2
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

BEGIN

  SAVEPOINT Update_Row_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS ;


  UPDATE psb_ws_consolidation_details
  SET
       global_worksheet_id     =   p_global_worksheet_id ,
       local_worksheet_id      =   p_local_worksheet_id ,
       last_update_date        =   p_last_update_date ,
       last_updated_by         =   p_last_updated_by ,
       last_update_login       =   p_last_update_login ,
       attribute1              =   p_attribute1 ,
       attribute2              =   p_attribute2 ,
       attribute3              =   p_attribute3 ,
       attribute4              =   p_attribute4 ,
       attribute5              =   p_attribute5 ,
       attribute6              =   p_attribute6 ,
       attribute7              =   p_attribute7 ,
       attribute8              =   p_attribute8 ,
       attribute9              =   p_attribute9 ,
       attribute10             =   p_attribute10,
       context                 =   p_context
  WHERE rowid = p_row_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND ;
  END IF;


  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

END Update_Row;


PROCEDURE Delete_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT NOCOPY      VARCHAR2,
  p_msg_count                 OUT NOCOPY      NUMBER,
  p_msg_data                  OUT NOCOPY      VARCHAR2,

  p_row_id                    IN        VARCHAR2
)
IS

  l_api_name                CONSTANT VARCHAR2(30)   := 'Delete_Row';
  l_api_version             CONSTANT NUMBER         :=  1.0;

  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;

BEGIN

  SAVEPOINT Delete_Row_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF ;

  p_return_status := FND_API.G_RET_STS_SUCCESS ;


  DELETE FROM psb_ws_consolidation_details
  WHERE rowid = p_row_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND ;
  END IF;


  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

END Delete_Row;


PROCEDURE Check_Unique
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT NOCOPY      VARCHAR2,
  p_msg_count                 OUT NOCOPY      NUMBER,
  p_msg_data                  OUT NOCOPY      VARCHAR2,
  --
  p_row_id                    IN       VARCHAR2,
  p_global_worksheet_id       IN       NUMBER,
  p_local_worksheet_id        IN       NUMBER,
  p_return_value              IN OUT NOCOPY   VARCHAR2
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Unique';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  l_tmp                 VARCHAR2(1);

  CURSOR c IS
    SELECT '1'
    FROM   psb_ws_consolidation_details
    WHERE  global_worksheet_id = p_global_worksheet_id
    AND    local_worksheet_id = p_local_worksheet_id;

BEGIN

  SAVEPOINT Check_Unique_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Checking the Psb_ws_consolidations table for references.
  OPEN c;
  FETCH c INTO l_tmp;

  -- p_Return_Value specifies whether unique value exists or not.
  IF l_tmp IS NULL THEN
    p_Return_Value := 'FALSE';
  ELSE
    p_Return_Value := 'TRUE';
  END IF;

  CLOSE c;

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Check_Unique_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Check_Unique_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Check_Unique_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );

END Check_Unique;


/*===========================================================================+
 |                   PROCEDURE Worksheet_Consolidate_CP                      |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Worksheet_Consolidate'
--
PROCEDURE Worksheet_Consolidate_CP
(
  errbuf                      OUT NOCOPY      VARCHAR2  ,
  retcode                     OUT NOCOPY      VARCHAR2  ,
  --
  p_worksheet_id              IN       NUMBER
)
IS
  l_api_name       CONSTANT VARCHAR2(30)   := 'Worksheet_Consolidate_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;

BEGIN

  PSB_WORKSHEET_CONSOLIDATE_PVT.Validate_Consolidation
     (p_api_version       =>  1.0,
      p_init_msg_list     =>  FND_API.G_TRUE,
      p_validation_level  =>  FND_API.G_VALID_LEVEL_NONE,
      p_return_status     =>  l_return_status,
      p_msg_count         =>  l_msg_count,
      p_msg_data          =>  l_msg_data,
      p_global_worksheet_id      =>  p_worksheet_id
      );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_WORKSHEET_CONSOLIDATE_PVT.Consolidate_Worksheets
     (p_api_version       =>  1.0,
      p_init_msg_list     =>  FND_API.G_TRUE,
      p_commit            =>  FND_API.G_TRUE,
      p_validation_level  =>  FND_API.G_VALID_LEVEL_NONE,
      p_return_status     =>  l_return_status,
      p_msg_count         =>  l_msg_count,
      p_msg_data          =>  l_msg_data,
      p_global_worksheet_id      =>  p_worksheet_id
      );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
			       p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
   WHEN OTHERS THEN
     --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
END Worksheet_Consolidate_CP;
/* ----------------------------------------------------------------------- */


END PSB_WORKSHEET_CONSOLIDATE_PVT;

/
