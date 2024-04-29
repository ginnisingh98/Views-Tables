--------------------------------------------------------
--  DDL for Package Body JTF_BRMPARAMETER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_BRMPARAMETER_PVT" AS
/* $Header: jtfvbpb.pls 120.2 2005/07/05 07:44:29 abraina ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_BRMParameter_PVT';

--------------------------------------------------------------------------
-- Start of comments
--  Procedure   : Create_BRMParameter
--  Description : Create record in JTF_BRM_PARAMETERS table
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      p_api_version        IN         NUMBER   required
--      p_init_msg_list      IN         VARCHAR2 optional
--      p_commit             IN         VARCHAR2 optional
--      p_validation_level   IN         NUMBER   optional
--      x_return_status         OUT     VARCHAR2 required
--      x_msg_count             OUT     NUMBER   required
--      x_msg_data              OUT     VARCHAR2 required
--      p_bp_rec             IN         brm_parameter_rec_type required
--      x_record_id             OUT     NUMBER  required
--
--  Version : Current  version 1.1
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Create_BRMParameter
( p_api_version      IN     NUMBER
, p_init_msg_list    IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_bp_rec           IN     BRM_PARAMETER_rec_type
, x_record_id           OUT NOCOPY NUMBER
)
IS
  l_api_name              CONSTANT VARCHAR2(30)    := 'Create_BRMParameter';
  l_api_version           CONSTANT NUMBER          := 1.1;
  l_api_name_full         CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_object_version_number          NUMBER          := 1;
  l_return_status                  VARCHAR2(1);
  l_rowid                          ROWID;
  l_parameter_id                   NUMBER;

  CURSOR c IS SELECT ROWID
              FROM   JTF_BRM_PARAMETERS
              WHERE  PARAMETER_ID = l_parameter_id;

BEGIN
  --
  -- Standard start of API savepoint
  --
  SAVEPOINT Create_BRMParameter_PVT;

  --
  -- Standard call to check for call compatibility
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize message list if p_init_msg_list is set to TRUE
  --
  IF FND_API.To_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --
  -- Initialize API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -------------------------------------------------------------------------
  -- Perform the database operation. Set the parameter ID to 1, then insert
  -- the passed in attributes into the JTF_BRM_PARAMETERS table.
  -------------------------------------------------------------------------
  l_parameter_id := 1;

  --
  -- Insert into table
  --
  INSERT INTO JTF_BRM_PARAMETERS
  ( PARAMETER_ID
  , CREATED_BY
  , CREATION_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATE_LOGIN
  , BRM_UOM_TYPE
  , BRM_UOM_CODE
  , BRM_INTERVAL
  , BRM_WF_COMMAND_TYPE
  , BRM_WF_COMMAND_CODE
  , WORKFLOW_PROCESS_ID
  , WORKFLOW_ITEM_TYPE
  , WORKFLOW_PROCESS_NAME
  , ATTRIBUTE1
  , ATTRIBUTE2
  , ATTRIBUTE3
  , ATTRIBUTE4
  , ATTRIBUTE5
  , ATTRIBUTE6
  , ATTRIBUTE7
  , ATTRIBUTE8
  , ATTRIBUTE9
  , ATTRIBUTE10
  , ATTRIBUTE11
  , ATTRIBUTE12
  , ATTRIBUTE13
  , ATTRIBUTE14
  , ATTRIBUTE15
  , ATTRIBUTE_CATEGORY
  , SECURITY_GROUP_ID
  , OBJECT_VERSION_NUMBER
  , APPLICATION_ID
  ) VALUES
  ( l_parameter_id
  , p_bp_rec.CREATED_BY
  , p_bp_rec.CREATION_DATE
  , p_bp_rec.LAST_UPDATED_BY
  , p_bp_rec.LAST_UPDATE_DATE
  , p_bp_rec.LAST_UPDATE_LOGIN
  , p_bp_rec.BRM_UOM_TYPE
  , p_bp_rec.BRM_UOM_CODE
  , p_bp_rec.BRM_INTERVAL
  , p_bp_rec.BRM_WF_COMMAND_TYPE
  , p_bp_rec.BRM_WF_COMMAND_CODE
  , p_bp_rec.WORKFLOW_PROCESS_ID
  , p_bp_rec.WORKFLOW_ITEM_TYPE
  , p_bp_rec.WORKFLOW_PROCESS_NAME
  , p_bp_rec.ATTRIBUTE1
  , p_bp_rec.ATTRIBUTE2
  , p_bp_rec.ATTRIBUTE3
  , p_bp_rec.ATTRIBUTE4
  , p_bp_rec.ATTRIBUTE5
  , p_bp_rec.ATTRIBUTE6
  , p_bp_rec.ATTRIBUTE7
  , p_bp_rec.ATTRIBUTE8
  , p_bp_rec.ATTRIBUTE9
  , p_bp_rec.ATTRIBUTE10
  , p_bp_rec.ATTRIBUTE11
  , p_bp_rec.ATTRIBUTE12
  , p_bp_rec.ATTRIBUTE13
  , p_bp_rec.ATTRIBUTE14
  , p_bp_rec.ATTRIBUTE15
  , p_bp_rec.ATTRIBUTE_CATEGORY
  , p_bp_rec.SECURITY_GROUP_ID
  , l_object_version_number
  , p_bp_rec.APPLICATION_ID
  );

  --
  -- Check if insert was done
  --
  OPEN c;
  FETCH c INTO L_ROWID;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

  --
  -- Return the key value to the caller
  --
  x_record_id := l_parameter_id;

  --
  -- Standard check of p_commit
  --
  IF FND_API.To_Boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message info
  --
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data
                           );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    ROLLBACK TO Create_BRMParameter_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    ROLLBACK TO Create_BRMParameter_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
  WHEN OTHERS
  THEN
    ROLLBACK TO Create_BRMParameter_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , l_api_name
                             );
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

END Create_BRMParameter;

--------------------------------------------------------------------------
-- Start of comments
--  Procedure   : Update_BRMParameter
--  Description : Update record in JTF_BRM_PARAMETERS table
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      p_api_version        IN         NUMBER   required
--      p_init_msg_list      IN         VARCHAR2 optional
--      p_commit             IN         VARCHAR2 optional
--      p_validation_level   IN         NUMBER   optional
--      x_return_status         OUT     VARCHAR2 required
--      x_msg_count             OUT     NUMBER   required
--      x_msg_data              OUT     VARCHAR2 required
--      p_bp_rec             IN         brm_parameter_rec_type required
--
--  Version : Current  version 1.1
--            Previous version 1.0
--            Initial  version 1.0
--
--
--  Notes :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Update_BRMParameter
( p_api_version      IN     NUMBER
, p_init_msg_list    IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_bp_rec           IN     BRM_Parameter_rec_type
)
IS
  l_api_name              CONSTANT VARCHAR2(30)    := 'Update_BRMParameter';
  l_api_version           CONSTANT NUMBER          := 1.1;
  l_api_name_full         CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_object_version_number          NUMBER;
  l_return_status                  VARCHAR2(1);
  l_msg_count                      NUMBER;
  l_msg_data                       VARCHAR2(2000);

BEGIN
  --
  -- Standard start of API savepoint
  --
  SAVEPOINT Update_BRMParameter_PVT;

  --
  -- Standard call to check for call compatibility
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize message list if p_init_msg_list is set to TRUE
  --
  IF FND_API.To_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --
  -- Initialize API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Get a new object version number
  --
  SELECT JTF_BRM_OBJECT_VERSION_S.NEXTVAL
  INTO l_object_version_number
  FROM DUAL;

  UPDATE JTF_BRM_PARAMETERS
  SET LAST_UPDATED_BY = p_bp_rec.LAST_UPDATED_BY
  ,   LAST_UPDATE_DATE = p_bp_rec.LAST_UPDATE_DATE
  ,   LAST_UPDATE_LOGIN = p_bp_rec.LAST_UPDATE_LOGIN
  ,   BRM_UOM_TYPE = p_bp_rec.BRM_UOM_TYPE
  ,   BRM_UOM_CODE = p_bp_rec.BRM_UOM_CODE
  ,   BRM_INTERVAL = p_bp_rec.BRM_INTERVAL
  ,   BRM_WF_COMMAND_TYPE = p_bp_rec.BRM_WF_COMMAND_TYPE
  ,   BRM_WF_COMMAND_CODE = p_bp_rec.BRM_WF_COMMAND_CODE
  ,   WORKFLOW_PROCESS_ID = p_bp_rec.WORKFLOW_PROCESS_ID
  ,   WORKFLOW_ITEM_TYPE = p_bp_rec.WORKFLOW_ITEM_TYPE
  ,   WORKFLOW_PROCESS_NAME = p_bp_rec.WORKFLOW_PROCESS_NAME
  ,   ATTRIBUTE1 = p_bp_rec.ATTRIBUTE1
  ,   ATTRIBUTE2 = p_bp_rec.ATTRIBUTE2
  ,   ATTRIBUTE3 = p_bp_rec.ATTRIBUTE3
  ,   ATTRIBUTE4 = p_bp_rec.ATTRIBUTE4
  ,   ATTRIBUTE5 = p_bp_rec.ATTRIBUTE5
  ,   ATTRIBUTE6 = p_bp_rec.ATTRIBUTE6
  ,   ATTRIBUTE7 = p_bp_rec.ATTRIBUTE7
  ,   ATTRIBUTE8 = p_bp_rec.ATTRIBUTE9
  ,   ATTRIBUTE9 = p_bp_rec.ATTRIBUTE9
  ,   ATTRIBUTE10 = p_bp_rec.ATTRIBUTE10
  ,   ATTRIBUTE11 = p_bp_rec.ATTRIBUTE11
  ,   ATTRIBUTE12 = p_bp_rec.ATTRIBUTE12
  ,   ATTRIBUTE13 = p_bp_rec.ATTRIBUTE13
  ,   ATTRIBUTE14 = p_bp_rec.ATTRIBUTE14
  ,   ATTRIBUTE15 = p_bp_rec.ATTRIBUTE15
  ,   ATTRIBUTE_CATEGORY = p_bp_rec.ATTRIBUTE_CATEGORY
  ,   SECURITY_GROUP_ID = p_bp_rec.SECURITY_GROUP_ID
  ,   OBJECT_VERSION_NUMBER = l_object_version_number
  ,   APPLICATION_ID = p_bp_rec.APPLICATION_ID
  WHERE PARAMETER_ID = p_bp_rec.PARAMETER_ID;

  --
  -- Check if update has been done
  --
  IF (SQL%NOTFOUND)
  THEN
    RAISE no_data_found;
  END IF;

  --
  -- Standard check of p_commit
  --
  IF FND_API.To_Boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message info
  --
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data
                           );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    ROLLBACK TO Update_BRMParameter_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    ROLLBACK TO Update_BRMParameter_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

  WHEN OTHERS
  THEN
    ROLLBACK TO Update_BRMParameter_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , l_api_name
                             );
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

END Update_BRMParameter;

--------------------------------------------------------------------------
-- Start of comments
--  Procedure   : Delete_BRMParameter
--  Description : Delete record in JTF_BRM_PARAMETERS table
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      p_api_version        IN         NUMBER   required
--      p_init_msg_list      IN         VARCHAR2 optional
--      p_commit             IN         VARCHAR2 optional
--      p_validation_level   IN         NUMBER   optional
--      x_return_status         OUT     VARCHAR2 required
--      x_msg_count             OUT     NUMBER   required
--      x_msg_data              OUT     VARCHAR2 required
--      p_parameter_id       IN         NUMBER  required
--
--  Version : Current  version 1.1
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Delete_BRMParameter
( p_api_version      IN     NUMBER
, p_init_msg_list    IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_parameter_id     IN     NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'Delete_BRMParameter';
  l_api_version   CONSTANT NUMBER       := 1.1;
  l_api_name_full CONSTANT VARCHAR2(62) := G_PKG_NAME||'.'||l_api_name;
  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
BEGIN
    --
    -- Establish save point
    --
    SAVEPOINT Delete_BRMParameter_PVT;

    --
    -- Check version number
    --
    IF NOT FND_API.Compatible_API_Call( l_api_version
                                      , p_api_version
                                      , l_api_name
                                      , G_PKG_NAME
                                      )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Initialize message list if requested
    --
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    --
    -- Initialize return status to SUCCESS
    --
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    DELETE FROM JTF_BRM_PARAMETERS
    WHERE PARAMETER_ID = p_parameter_id;

    IF (SQL%NOTFOUND)
    THEN
      RAISE no_data_found;
    END IF;

    IF FND_API.To_Boolean( p_commit )
    THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get( p_count => X_MSG_COUNT
                             , p_data  => X_MSG_DATA
                             );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR
    THEN
      ROLLBACK TO Delete_BRMParameter_PVT;
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => X_MSG_COUNT
                               , p_data  => X_MSG_DATA
                               );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
      ROLLBACK TO Delete_BRMParameter_PVT;
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => X_MSG_COUNT
                               , p_data  => X_MSG_DATA
                               );

    WHEN OTHERS
    THEN
      ROLLBACK TO Delete_BRMParameter_PVT;
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                               , l_api_name
                               );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count => X_MSG_COUNT
                               , p_data  => X_MSG_DATA
                               );

END Delete_BRMParameter;

END JTF_BRMParameter_PVT;

/
