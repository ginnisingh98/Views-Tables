--------------------------------------------------------
--  DDL for Package Body JTF_BRMWFATTRVALUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_BRMWFATTRVALUE_PVT" AS
/* $Header: jtfvbwab.pls 120.2 2005/07/05 07:45:10 abraina ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_BRMWFAttrValue_PVT';

--------------------------------------------------------------------------
-- Start of comments
--  API name    : Create_WFAttrValue
--  Type        : Private
--  Function    : Create record in JTF_BRM_WF_ATTR_VALUES table.
--  Pre-reqs    : None.
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
--      p_bwa_rec            IN         brm_wf_attr_value_rec_type   required
--      x_record_id             OUT     NUMBER   required
--
--  Version  : Current  version  1.1
--             Previous version  1.0
--             Initial  version  1.0
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Create_WFAttrValue
( p_api_version      IN      NUMBER
, p_init_msg_list    IN      VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN      VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN      NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY  VARCHAR2
, x_msg_count           OUT NOCOPY  NUMBER
, x_msg_data            OUT NOCOPY  VARCHAR2
, p_bwa_rec          IN      brm_wf_attr_value_rec_type
, x_record_id           OUT NOCOPY  NUMBER
)
IS
  l_api_name              CONSTANT VARCHAR2(30)    := 'Create_WFAttrValue';
  l_api_version           CONSTANT NUMBER          := 1.1;
  l_api_name_full         CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_object_version_number          NUMBER          := 1;
  l_return_status                  VARCHAR2(1);
  l_rowid                          ROWID;
  l_wf_attr_value_id               NUMBER;

  CURSOR c IS SELECT ROWID
              FROM  JTF_BRM_WF_ATTR_VALUES
              WHERE WF_ATTR_VALUE_ID = l_wf_attr_value_id;

BEGIN
  --
  -- Standard start of API savepoint
  --
  SAVEPOINT Create_WFAttrValue_PVT;

  --
  -- Standard call to check for call compatibility
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME)
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

  -- ----------------------------------------------------------------------
  -- Perform the database operation. Generate the ID from the
  -- sequence, then insert the passed in attributes into the
  -- JTF_BRM_WF_ATTR_VALUES table.
  ----------------------------------------------------------------------
  IF (p_bwa_rec.wf_attr_value_id IS NULL)
  THEN
    SELECT jtf_brm_wf_attr_values_s.NEXTVAL INTO l_wf_attr_value_id
    FROM DUAL;
  ELSE
    l_wf_attr_value_id := p_bwa_rec.wf_attr_value_id;
  END IF;

  --
  -- Insert into table
  --
  INSERT INTO JTF_BRM_WF_ATTR_VALUES
  ( WF_ATTR_VALUE_ID
  , PROCESS_ID
  , WF_ITEM_TYPE
  , WF_ACTIVITY_NAME
  , WF_ACTIVITY_VERSION
  , WF_ACTIVITY_ATTRIBUTE_NAME
  , CREATED_BY
  , CREATION_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATE_LOGIN
  , TEXT_VALUE
  , NUMBER_VALUE
  , DATE_VALUE
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
  ( l_wf_attr_value_id
  , p_bwa_rec.PROCESS_ID
  , p_bwa_rec.WF_ITEM_TYPE
  , p_bwa_rec.WF_ACTIVITY_NAME
  , p_bwa_rec.WF_ACTIVITY_VERSION
  , p_bwa_rec.WF_ACTIVITY_ATTRIBUTE_NAME
  , p_bwa_rec.CREATED_BY
  , p_bwa_rec.CREATION_DATE
  , p_bwa_rec.LAST_UPDATED_BY
  , p_bwa_rec.LAST_UPDATE_DATE
  , p_bwa_rec.LAST_UPDATE_LOGIN
  , p_bwa_rec.TEXT_VALUE
  , p_bwa_rec.NUMBER_VALUE
  , p_bwa_rec.DATE_VALUE
  , p_bwa_rec.ATTRIBUTE1
  , p_bwa_rec.ATTRIBUTE2
  , p_bwa_rec.ATTRIBUTE3
  , p_bwa_rec.ATTRIBUTE4
  , p_bwa_rec.ATTRIBUTE5
  , p_bwa_rec.ATTRIBUTE6
  , p_bwa_rec.ATTRIBUTE7
  , p_bwa_rec.ATTRIBUTE8
  , p_bwa_rec.ATTRIBUTE9
  , p_bwa_rec.ATTRIBUTE10
  , p_bwa_rec.ATTRIBUTE11
  , p_bwa_rec.ATTRIBUTE12
  , p_bwa_rec.ATTRIBUTE13
  , p_bwa_rec.ATTRIBUTE14
  , p_bwa_rec.ATTRIBUTE15
  , p_bwa_rec.ATTRIBUTE_CATEGORY
  , p_bwa_rec.SECURITY_GROUP_ID
  , l_object_version_number
  , p_bwa_rec.APPLICATION_ID
  );

  --
  -- Check whether insert was succesful
  --
  OPEN c;
  FETCH c INTO l_rowid;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    RAISE no_data_found;
  END IF;
  CLOSE c;

  --
  -- Return the key value to the caller
  --
  x_record_id := l_wf_attr_value_id;

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
    ROLLBACK TO Create_WFAttrValue_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    ROLLBACK TO Create_WFAttrValue_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

  WHEN OTHERS
  THEN
    ROLLBACK TO Create_WFAttrValue_PVT;
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

END Create_WFAttrValue;

--------------------------------------------------------------------------
-- Start of comments
--  API name    : Update_WFAttrValue
--  Type        : Private
--  Function    : Update record in JTF_BRM_WF_ATTR_VALUES table.
--  Pre-reqs    : None.
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
--      p_bel_rec            IN         brm_wf_attr_value_rec_type   required
--
--  Version  : Current version   1.1
--             Previous version  1.0
--             Initial Version   1.0
--
--  Notes:
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Update_WFAttrValue
( p_api_version      IN      NUMBER
, p_init_msg_list    IN      VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN      VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN      NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY  VARCHAR2
, x_msg_count           OUT NOCOPY  NUMBER
, x_msg_data            OUT NOCOPY  VARCHAR2
, p_bwa_rec          IN      brm_wf_attr_value_rec_type
)
IS
  l_api_name              CONSTANT VARCHAR2(30)    := 'Update_WFAttrValue';
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
  SAVEPOINT Update_WFAttrValue_PVT;

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

  UPDATE JTF_BRM_WF_ATTR_VALUES
  SET PROCESS_ID = p_bwa_rec.PROCESS_ID
  ,   WF_ITEM_TYPE = p_bwa_rec.WF_ITEM_TYPE
  ,   WF_ACTIVITY_NAME = p_bwa_rec.WF_ACTIVITY_NAME
  ,   WF_ACTIVITY_VERSION = p_bwa_rec.WF_ACTIVITY_VERSION
  ,   WF_ACTIVITY_ATTRIBUTE_NAME = p_bwa_rec.WF_ACTIVITY_ATTRIBUTE_NAME
  ,   LAST_UPDATED_BY = p_bwa_rec.LAST_UPDATED_BY
  ,   LAST_UPDATE_DATE = p_bwa_rec.LAST_UPDATE_DATE
  ,   LAST_UPDATE_LOGIN = p_bwa_rec.LAST_UPDATE_LOGIN
  ,   TEXT_VALUE = p_bwa_rec.TEXT_VALUE
  ,   NUMBER_VALUE = p_bwa_rec.NUMBER_VALUE
  ,   DATE_VALUE = p_bwa_rec.DATE_VALUE
  ,   ATTRIBUTE1 = p_bwa_rec.ATTRIBUTE1
  ,   ATTRIBUTE2 = p_bwa_rec.ATTRIBUTE2
  ,   ATTRIBUTE3 = p_bwa_rec.ATTRIBUTE3
  ,   ATTRIBUTE4 = p_bwa_rec.ATTRIBUTE4
  ,   ATTRIBUTE5 = p_bwa_rec.ATTRIBUTE5
  ,   ATTRIBUTE6 = p_bwa_rec.ATTRIBUTE6
  ,   ATTRIBUTE7 = p_bwa_rec.ATTRIBUTE7
  ,   ATTRIBUTE8 = p_bwa_rec.ATTRIBUTE8
  ,   ATTRIBUTE9 = p_bwa_rec.ATTRIBUTE9
  ,   ATTRIBUTE10 = p_bwa_rec.ATTRIBUTE10
  ,   ATTRIBUTE11 = p_bwa_rec.ATTRIBUTE11
  ,   ATTRIBUTE12 = p_bwa_rec.ATTRIBUTE12
  ,   ATTRIBUTE13 = p_bwa_rec.ATTRIBUTE13
  ,   ATTRIBUTE14 = p_bwa_rec.ATTRIBUTE14
  ,   ATTRIBUTE15 = p_bwa_rec.ATTRIBUTE15
  ,   ATTRIBUTE_CATEGORY = p_bwa_rec.ATTRIBUTE_CATEGORY
  ,   SECURITY_GROUP_ID = p_bwa_rec.SECURITY_GROUP_ID
  ,   OBJECT_VERSION_NUMBER = l_object_version_number
  ,   APPLICATION_ID = p_bwa_rec.APPLICATION_ID
  WHERE WF_ATTR_VALUE_ID = p_bwa_rec.WF_ATTR_VALUE_ID;

  --
  -- Check whether update was succesful
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
    ROLLBACK TO Update_WFAttrValue_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    ROLLBACK TO Update_WFAttrValue_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

  WHEN OTHERS
  THEN
    ROLLBACK TO Update_WFAttrValue_PVT;
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

END Update_WFAttrValue;

--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Delete_WFAttrValue
--  Type        : Private
--  Description : Delete record in JTF_BRM_WF_ATTR_VALUES table.
--  Pre-reqs    : None
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
--      p_wf_attr_value_id  IN          NUMBER   required
--
--  Version  : Current  version  1.1
--             Previous version  1.0
--             Initial  version  1.0
--
--  Notes:  :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Delete_WFAttrValue
( p_api_version      IN      NUMBER
, p_init_msg_list    IN      VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN      VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN      NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY  VARCHAR2
, x_msg_count           OUT NOCOPY  NUMBER
, x_msg_data            OUT NOCOPY  VARCHAR2
, p_wf_attr_value_id IN      NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'Delete_WFAttrValue';
  l_api_version   CONSTANT NUMBER       := 1.1;
  l_api_name_full CONSTANT VARCHAR2(62) := G_PKG_NAME||'.'||l_api_name;
  l_return_status          VARCHAR2(1);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
BEGIN
    --
    -- Establish save point
    --
    SAVEPOINT Delete_WFAttrValue_PVT;

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

    DELETE FROM JTF_BRM_WF_ATTR_VALUES
    WHERE WF_ATTR_VALUE_ID = p_wf_attr_value_id;

    --
    -- Check whether delete was succesful
    --
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
      ROLLBACK TO Delete_WFAttrValue_PVT;
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => X_MSG_COUNT
                               , p_data  => X_MSG_DATA
                               );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
      ROLLBACK TO Delete_WFAttrValue_PVT;
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => X_MSG_COUNT
                               , p_data  => X_MSG_DATA
                               );

    WHEN OTHERS
    THEN
      ROLLBACK TO Delete_WFAttrValue_PVT;
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

END Delete_WFAttrValue;

END JTF_BRMWFAttrValue_PVT;

/
