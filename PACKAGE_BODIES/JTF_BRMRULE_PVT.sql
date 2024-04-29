--------------------------------------------------------
--  DDL for Package Body JTF_BRMRULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_BRMRULE_PVT" AS
/* $Header: jtfvbrb.pls 120.2 2005/07/05 07:44:49 abraina ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_BRMRule_PVT';

--------------------------------------------------------------------------
-- Start of comments
--  API name    : Create_BRMRule
--  Type        : Private
--  Function    : Create record in JTF_BRM_RULES_B and _TL tables.
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
--      p_br_rec             IN         BRM_Rule_rec_type   required
--      x_record_id             OUT     NUMBER  required
--
--  Version : Current  version 1.1
--            Previous version 1.0
--            Initial  version 1.1
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Create_BRMRule
( p_api_version       IN     NUMBER
, p_init_msg_list     IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit            IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level  IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
, p_br_rec            IN     BRM_Rule_rec_type
, x_record_id            OUT NOCOPY NUMBER
)
IS
  l_api_name              CONSTANT VARCHAR2(30)    := 'Create_BRMRule';
  l_api_version           CONSTANT NUMBER          := 1.1;
  l_api_name_full         CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_object_version_number          NUMBER          := 1;
  l_return_status                  VARCHAR2(1);
  l_rowid                          ROWID;
  l_rule_id                        NUMBER;

  CURSOR c IS SELECT ROWID
              FROM JTF_BRM_RULES_B
              WHERE RULE_ID = l_rule_id;

BEGIN
  --
  -- Standard start of API savepoint
  --
  SAVEPOINT Create_BRMRule_PVT;

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

  ------------------------------------------------------------------------
  -- Perform the database operation. Generate the method ID from the
  -- sequence, then insert the passed in attributes into the
  -- JTF_BRM_Rule tables.
  ----------------------------------------------------------------------
  IF (p_br_rec.RULE_ID IS NULL)
  THEN
    SELECT JTF_BRM_RULES_S.NEXTVAL INTO l_rule_id
    FROM DUAL;
  ELSE
    l_rule_id := p_br_rec.RULE_ID;
  END IF;

  --
  -- Insert into _B table
  --
  INSERT INTO JTF_BRM_RULES_B
  ( RULE_ID
  , BRM_OBJECT_TYPE
  , BRM_OBJECT_CODE
  , SEEDED_FLAG
  , VIEW_DEFINITION
  , VIEW_NAME
  , RULE_OWNER
  , START_DATE_ACTIVE
  , END_DATE_ACTIVE
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
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  , OBJECT_VERSION_NUMBER
  , APPLICATION_ID
  ) VALUES
  ( l_rule_id
  , p_br_rec.BRM_OBJECT_TYPE
  , p_br_rec.BRM_OBJECT_CODE
  , p_br_rec.SEEDED_FLAG
  , p_br_rec.VIEW_DEFINITION
  , p_br_rec.VIEW_NAME
  , p_br_rec.RULE_OWNER
  , p_br_rec.START_DATE_ACTIVE
  , p_br_rec.END_DATE_ACTIVE
  , p_br_rec.ATTRIBUTE1
  , p_br_rec.ATTRIBUTE2
  , p_br_rec.ATTRIBUTE3
  , p_br_rec.ATTRIBUTE4
  , p_br_rec.ATTRIBUTE5
  , p_br_rec.ATTRIBUTE6
  , p_br_rec.ATTRIBUTE7
  , p_br_rec.ATTRIBUTE8
  , p_br_rec.ATTRIBUTE9
  , p_br_rec.ATTRIBUTE10
  , p_br_rec.ATTRIBUTE11
  , p_br_rec.ATTRIBUTE12
  , p_br_rec.ATTRIBUTE13
  , p_br_rec.ATTRIBUTE14
  , p_br_rec.ATTRIBUTE15
  , p_br_rec.ATTRIBUTE_CATEGORY
  , p_br_rec.CREATION_DATE
  , p_br_rec.CREATED_BY
  , p_br_rec.LAST_UPDATE_DATE
  , p_br_rec.LAST_UPDATED_BY
  , p_br_rec.LAST_UPDATE_LOGIN
  , l_object_version_number
  , p_br_rec.APPLICATION_ID
  );

  --
  -- Insert into _TL table
  --
  INSERT INTO JTF_BRM_RULES_TL
  ( RULE_ID
  , RULE_NAME
  , RULE_DESCRIPTION
  , CREATED_BY
  , CREATION_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATE_LOGIN
  , LANGUAGE
  , SOURCE_LANG
  , APPLICATION_ID
  ) SELECT  l_rule_id
    ,       p_br_rec.RULE_NAME
    ,       p_br_rec.RULE_DESCRIPTION
    ,       p_br_rec.CREATED_BY
    ,       p_br_rec.CREATION_DATE
    ,       p_br_rec.LAST_UPDATED_BY
    ,       p_br_rec.LAST_UPDATE_DATE
    ,       p_br_rec.LAST_UPDATE_LOGIN
    ,       l.LANGUAGE_CODE
    ,       userenv('LANG')
    ,       p_br_rec.APPLICATION_ID
    FROM  FND_LANGUAGES l
    WHERE l.INSTALLED_FLAG IN ('I','B')
    AND   NOT EXISTS ( SELECT NULL
                       FROM JTF_BRM_RULES_TL t
                       WHERE t.RULE_ID = l_rule_id
                       AND   t.LANGUAGE = l.LANGUAGE_CODE);

  --
  -- Check whether the insert was succesfull
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
  x_record_id := l_rule_id;

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
    ROLLBACK TO Create_BRMRule_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    ROLLBACK TO Create_BRMRule_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
  WHEN OTHERS
  THEN
    ROLLBACK TO Create_BRMRule_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME
                             , l_api_name
                             );
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

END Create_BRMRule;

--------------------------------------------------------------------------
-- Start of comments
--  API name   : Update_BRMRule
--  Type       : Private
--  Function   : Update record in JTF_BRM_RULES_B and _TL tables.
--  Pre-reqs   : None.
--  Parameters :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      p_api_version        IN         NUMBER   required
--      p_init_msg_list      IN         VARCHAR2 optional
--      p_commit             IN         VARCHAR2 optional
--      p_validation_level   IN         NUMBER   optional
--      x_return_status         OUT     VARCHAR2 required
--      x_msg_count             OUT     NUMBER   required
--      x_msg_data              OUT     VARCHAR2 required
--      p_br_rec             IN         BRM_Rule_rec_type   required
--
--  Version : Current  version 1.1
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes:
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Update_BRMRule
( p_api_version      IN     NUMBER
, p_init_msg_list    IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_br_rec           IN     BRM_Rule_rec_type
)
IS
  l_api_name              CONSTANT VARCHAR2(30)  := 'Update_BRMRule';
  l_api_version           CONSTANT NUMBER        := 1.1;
  l_api_name_full         CONSTANT VARCHAR2(61)  := G_PKG_NAME||'.'||l_api_name;
  l_object_version_number          NUMBER;
  l_return_status                  VARCHAR2(1);
  l_msg_count                      NUMBER;
  l_msg_data                       VARCHAR2(2000);

BEGIN
  --
  -- Standard start of API savepoint
  --
  SAVEPOINT Update_BRMRule_PVT;

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

  --
  -- Get new object versio number
  --
  SELECT JTF_BRM_OBJECT_VERSION_S.NEXTVAL
  INTO l_object_version_number
  FROM DUAL;

  UPDATE JTF_BRM_RULES_B
  SET BRM_OBJECT_TYPE = p_br_rec.BRM_OBJECT_TYPE
  ,   BRM_OBJECT_CODE = p_br_rec.BRM_OBJECT_CODE
  ,   SEEDED_FLAG = p_br_rec.SEEDED_FLAG
  ,   VIEW_DEFINITION = p_br_rec.VIEW_DEFINITION
  ,   VIEW_NAME = p_br_rec.VIEW_NAME
  ,   RULE_OWNER = p_br_rec.RULE_OWNER
  ,   START_DATE_ACTIVE = p_br_rec.START_DATE_ACTIVE
  ,   END_DATE_ACTIVE = p_br_rec.END_DATE_ACTIVE
  ,   ATTRIBUTE1 = p_br_rec.ATTRIBUTE1
  ,   ATTRIBUTE2 = p_br_rec.ATTRIBUTE2
  ,   ATTRIBUTE3 = p_br_rec.ATTRIBUTE3
  ,   ATTRIBUTE4 = p_br_rec.ATTRIBUTE4
  ,   ATTRIBUTE5 = p_br_rec.ATTRIBUTE5
  ,   ATTRIBUTE6 = p_br_rec.ATTRIBUTE6
  ,   ATTRIBUTE7 = p_br_rec.ATTRIBUTE7
  ,   ATTRIBUTE8 = p_br_rec.ATTRIBUTE8
  ,   ATTRIBUTE9 = p_br_rec.ATTRIBUTE9
  ,   ATTRIBUTE10 = p_br_rec.ATTRIBUTE10
  ,   ATTRIBUTE11 = p_br_rec.ATTRIBUTE11
  ,   ATTRIBUTE12 = p_br_rec.ATTRIBUTE12
  ,   ATTRIBUTE13 = p_br_rec.ATTRIBUTE13
  ,   ATTRIBUTE14 = p_br_rec.ATTRIBUTE14
  ,   ATTRIBUTE15 = p_br_rec.ATTRIBUTE15
  ,   ATTRIBUTE_CATEGORY = p_br_rec.ATTRIBUTE_CATEGORY
  ,   LAST_UPDATE_DATE = p_br_rec.LAST_UPDATE_DATE
  ,   LAST_UPDATED_BY = p_br_rec.LAST_UPDATED_BY
  ,   LAST_UPDATE_LOGIN = p_br_rec.LAST_UPDATE_LOGIN
  ,   OBJECT_VERSION_NUMBER = l_object_version_number
  ,   APPLICATION_ID = p_br_rec.APPLICATION_ID
  WHERE RULE_ID = p_br_rec.RULE_ID;

  --
  -- Check whether update was succesful
  --
  IF (SQL%NOTFOUND)
  THEN
    RAISE NO_DATA_FOUND;
  END IF;

  UPDATE JTF_BRM_RULES_TL
  SET RULE_NAME = p_br_rec.RULE_NAME
  ,   RULE_DESCRIPTION = p_br_rec.RULE_DESCRIPTION
  ,   LAST_UPDATE_DATE = p_br_rec.LAST_UPDATE_DATE
  ,   LAST_UPDATED_BY = p_br_rec.LAST_UPDATED_BY
  ,   LAST_UPDATE_LOGIN = p_br_rec.LAST_UPDATE_LOGIN
  ,   SOURCE_LANG = userenv('LANG')
  ,   APPLICATION_ID = p_br_rec.APPLICATION_ID
  WHERE RULE_ID = p_br_rec.RULE_ID
  AND   userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  --
  -- Check whether update was succesful
  --
  IF (SQL%NOTFOUND)
  THEN
    RAISE NO_DATA_FOUND;
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
    ROLLBACK TO Update_BRMRule_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    ROLLBACK TO Update_BRMRule_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

  WHEN OTHERS
  THEN
    ROLLBACK TO Update_BRMRule_PVT;
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

END Update_BRMRule;

--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Delete_BRMRule
--  Type        : Private
--  Description : Delete record in JTF_BRM_RULES_B and _TL tables.
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
--      p_rule_id            IN         NUMBER   required
--
--  Version : Current  version 1.1
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Delete_BRMRule
( p_api_version      IN      NUMBER
, p_init_msg_list    IN      VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN      VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN      NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_rule_id          IN     NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'Delete_BRMRule';
  l_api_version   CONSTANT NUMBER       := 1.1;
  l_api_name_full CONSTANT VARCHAR2(62) := G_PKG_NAME||'.'||l_api_name;
  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
BEGIN
    --
    -- Establish save point
    --
    SAVEPOINT Delete_BRMRule_PVT;

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

    DELETE FROM JTF_BRM_RULES_TL
    WHERE RULE_ID = p_rule_id;

    --
    -- Check whether delete was succesful
    --
    IF (SQL%NOTFOUND)
    THEN
       RAISE no_data_found;
    END IF;

    DELETE FROM JTF_BRM_RULES_B
    WHERE RULE_ID = p_rule_id;

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
      ROLLBACK TO Delete_BRMRule_PVT;
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => X_MSG_COUNT
                               , p_data  => X_MSG_DATA
                               );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
      ROLLBACK TO Delete_BRMRule_PVT;
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => X_MSG_COUNT
                               , p_data  => X_MSG_DATA
                               );

    WHEN OTHERS
    THEN
      ROLLBACK TO Delete_BRMRule_PVT;
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

END Delete_BRMRule;

--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Add_Language
--  Type        : Private
--  Description : Additional Language processing for JTF_BRM_RULES_B and
--                _TL tables.
--  Pre-reqs    : None
--  Parameters  : None
--  Version : Current  version 1.0
--            Previous version none
--            Initial  version 1.0
--
--  Notes: :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Add_Language
IS
BEGIN

  --
  -- Delete all records that don't have a base record
  --
  DELETE FROM JTF_BRM_RULES_TL t
  WHERE NOT EXISTS (SELECT NULL
                    FROM JTF_BRM_RULES_B b
                    WHERE b.RULE_ID = t.RULE_ID
                    );

  --
  -- Translate the records that already exists
  --
  UPDATE JTF_BRM_RULES_TL T
  SET ( RULE_NAME
      , RULE_DESCRIPTION
      ) = ( SELECT B.RULE_NAME
            ,      B.RULE_DESCRIPTION
            FROM JTF_BRM_RULES_TL B
            WHERE B.RULE_ID = T.RULE_ID
            AND B.LANGUAGE = T.SOURCE_LANG
          )
  WHERE ( T.RULE_ID
        , T.LANGUAGE
        ) IN ( SELECT  SUBT.RULE_ID
               ,       SUBT.LANGUAGE
               FROM JTF_BRM_RULES_TL SUBB
               ,    JTF_BRM_RULES_TL SUBT
               WHERE SUBB.RULE_ID = SUBT.RULE_ID
               AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
               AND (  SUBB.RULE_NAME <> SUBT.RULE_NAME
                   OR SUBB.RULE_DESCRIPTION <> SUBT.RULE_DESCRIPTION
                   OR (   SUBB.RULE_DESCRIPTION IS NULL
                      AND SUBT.RULE_DESCRIPTION IS NOT NULL
                      )
                   OR (   SUBB.RULE_DESCRIPTION IS NOT NULL
                      AND SUBT.RULE_DESCRIPTION IS NULL
                      )
                   )
              );

    --
    -- add records for new languages
    --
    INSERT INTO JTF_BRM_RULES_TL
    ( RULE_ID
    , CREATED_BY
    , CREATION_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATE_LOGIN
    , RULE_NAME
    , RULE_DESCRIPTION
    , LANGUAGE
    , SOURCE_LANG
    , APPLICATION_ID
  ) SELECT B.RULE_ID
    ,      B.CREATED_BY
    ,      B.CREATION_DATE
    ,      B.LAST_UPDATED_BY
    ,      B.LAST_UPDATE_DATE
    ,      B.LAST_UPDATE_LOGIN
    ,      B.RULE_NAME
    ,      B.RULE_DESCRIPTION
    ,      L.LANGUAGE_CODE
    ,      B.SOURCE_LANG
    ,      B.APPLICATION_ID
    FROM JTF_BRM_RULES_TL B, FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG IN ('I', 'B')
    AND   B.LANGUAGE = USERENV('LANG')
    AND   NOT EXISTS (SELECT NULL
                      FROM JTF_BRM_RULES_TL T
                      WHERE T.RULE_ID = B.RULE_ID
                      AND T.LANGUAGE = L.LANGUAGE_CODE
                     );
END Add_Language;

--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Translate_Row
--  Type        : Private
--  Description : Additional Language processing for JTF_BRM_RULES_B and
--                _TL tables. Used in the FNDLOAD definition file (.lct)
--  Pre-reqs    : None
--  Parameters  : None
--  Version : Current  version 1.0
--            Previous version none
--            Initial  version 1.0
--
--  Notes: :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Translate_Row
( p_rule_id          IN NUMBER
, p_rule_name        IN VARCHAR2
, p_rule_description IN VARCHAR2
, p_owner            IN VARCHAR2
)
IS
BEGIN
  UPDATE JTF_BRM_RULES_TL
  SET RULE_NAME         = p_rule_name
  ,   RULE_DESCRIPTION  = p_rule_description
  ,   LAST_UPDATE_DATE  = SYSDATE
  ,   LAST_UPDATED_BY   = DECODE(p_owner, 'SEED',1,0)
  ,   LAST_UPDATE_LOGIN = 0
  ,   SOURCE_LANG       = userenv('LANG')
  WHERE userenv('LANG') IN (LANGUAGE, SOURCE_LANG)
  AND   RULE_ID = p_rule_id;
END Translate_Row;

--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Load_Row
--  Type        : Private
--  Description : Additional Language processing for JTF_BRM_RULES_B and
--                _TL tables. Used in the FNDLOAD definition file (.lct)
--  Pre-reqs    : None
--  Parameters  : None
--  Version : Current  version 1.0
--            Previous version none
--            Initial  version 1.0
--
--  Notes: :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Load_Row
( p_rule_id  IN NUMBER
, p_br_rec   IN BRM_Rule_rec_type
, p_owner    IN VARCHAR2
)
IS
  l_user_id NUMBER;

BEGIN
  ------------------------------------------------------------------------
  -- Determine the user_id from p_owner
  ------------------------------------------------------------------------
  IF (p_owner IS NOT NULL) AND (p_owner = 'SEED')
  THEN
    l_user_id := 1;
  ELSE
    l_user_id := 0;
  END IF;

  ------------------------------------------------------------------------
  -- Try to update the record in the base table
  ------------------------------------------------------------------------
  UPDATE JTF_BRM_RULES_B
  SET BRM_OBJECT_TYPE       = p_br_rec.brm_object_type
  ,   BRM_OBJECT_CODE       = p_br_rec.brm_object_code
  ,   SEEDED_FLAG           = p_br_rec.seeded_flag
  ,   VIEW_DEFINITION       = P_br_rec.view_definition
  ,   VIEW_NAME             = p_br_rec.view_name
  ,   RULE_OWNER            = p_br_rec.rule_owner
  ,   START_DATE_ACTIVE     = p_br_rec.start_date_active
  ,   END_DATE_ACTIVE       = p_br_rec.end_date_active
  ,   ATTRIBUTE1            = p_br_rec.attribute1
  ,   ATTRIBUTE2            = p_br_rec.attribute2
  ,   ATTRIBUTE3            = p_br_rec.attribute3
  ,   ATTRIBUTE4            = p_br_rec.attribute4
  ,   ATTRIBUTE5            = p_br_rec.attribute5
  ,   ATTRIBUTE6            = p_br_rec.attribute6
  ,   ATTRIBUTE7            = p_br_rec.attribute7
  ,   ATTRIBUTE8            = p_br_rec.attribute8
  ,   ATTRIBUTE9            = p_br_rec.attribute9
  ,   ATTRIBUTE10           = p_br_rec.attribute10
  ,   ATTRIBUTE11           = p_br_rec.attribute11
  ,   ATTRIBUTE12           = p_br_rec.attribute12
  ,   ATTRIBUTE13           = p_br_rec.attribute13
  ,   ATTRIBUTE14           = p_br_rec.attribute14
  ,   ATTRIBUTE15           = p_br_rec.attribute15
  ,   ATTRIBUTE_CATEGORY    = p_br_rec.attribute_category
  ,   OBJECT_VERSION_NUMBER = p_br_rec.object_version_number
  ,   APPLICATION_ID        = p_br_rec.application_id
  ,   LAST_UPDATE_DATE      = SYSDATE
  ,   LAST_UPDATED_BY       = l_user_id
  ,   LAST_UPDATE_LOGIN     = 0
  WHERE RULE_ID = p_rule_id;

  ------------------------------------------------------------------------
  -- Apparently the record doesn't exist so create it
  ------------------------------------------------------------------------
  IF (SQL%NOTFOUND)
  THEN
    INSERT INTO JTF_BRM_RULES_B
    (  RULE_ID
    ,  BRM_OBJECT_TYPE
    ,  BRM_OBJECT_CODE
    ,  SEEDED_FLAG
    ,  VIEW_DEFINITION
    ,  VIEW_NAME
    ,  RULE_OWNER
    ,  START_DATE_ACTIVE
    ,  END_DATE_ACTIVE
    ,  ATTRIBUTE1
    ,  ATTRIBUTE2
    ,  ATTRIBUTE3
    ,  ATTRIBUTE4
    ,  ATTRIBUTE5
    ,  ATTRIBUTE6
    ,  ATTRIBUTE7
    ,  ATTRIBUTE8
    ,  ATTRIBUTE9
    ,  ATTRIBUTE10
    ,  ATTRIBUTE11
    ,  ATTRIBUTE12
    ,  ATTRIBUTE13
    ,  ATTRIBUTE14
    ,  ATTRIBUTE15
    ,  ATTRIBUTE_CATEGORY
    ,  OBJECT_VERSION_NUMBER
    ,  APPLICATION_ID
    ,  CREATION_DATE
    ,  CREATED_BY
    ,  LAST_UPDATE_DATE
    ,  LAST_UPDATED_BY
    ,  LAST_UPDATE_LOGIN
    ) VALUES
    (  p_rule_id
    ,  p_br_rec.BRM_OBJECT_TYPE
    ,  p_br_rec.BRM_OBJECT_CODE
    ,  p_br_rec.SEEDED_FLAG
    ,  p_br_rec.VIEW_DEFINITION
    ,  p_br_rec.VIEW_NAME
    ,  p_br_rec.RULE_OWNER
    ,  p_br_rec.START_DATE_ACTIVE
    ,  p_br_rec.END_DATE_ACTIVE
    ,  p_br_rec.ATTRIBUTE1
    ,  p_br_rec.ATTRIBUTE2
    ,  p_br_rec.ATTRIBUTE3
    ,  p_br_rec.ATTRIBUTE4
    ,  p_br_rec.ATTRIBUTE5
    ,  p_br_rec.ATTRIBUTE6
    ,  p_br_rec.ATTRIBUTE7
    ,  p_br_rec.ATTRIBUTE8
    ,  p_br_rec.ATTRIBUTE9
    ,  p_br_rec.ATTRIBUTE10
    ,  p_br_rec.ATTRIBUTE11
    ,  p_br_rec.ATTRIBUTE12
    ,  p_br_rec.ATTRIBUTE13
    ,  p_br_rec.ATTRIBUTE14
    ,  p_br_rec.ATTRIBUTE15
    ,  p_br_rec.ATTRIBUTE_CATEGORY
    ,  p_br_rec.object_version_number
    ,  p_br_rec.application_id
    ,  SYSDATE
    ,  l_user_id
    ,  SYSDATE
    ,  l_user_id
    ,  0
    );
  END IF;

  ------------------------------------------------------------------------
  -- Try to update the record in the language table
  ------------------------------------------------------------------------
  UPDATE JTF_BRM_RULES_TL
  SET    RULE_NAME         = p_br_rec.rule_name
  ,      RULE_DESCRIPTION  = p_br_rec.rule_description
  ,      LAST_UPDATE_DATE  = SYSDATE
  ,      LAST_UPDATED_BY   = l_user_id
  ,      LAST_UPDATE_LOGIN = 0
  ,      SOURCE_LANG       = userenv('LANG')
  WHERE RULE_ID = p_rule_id
  AND   userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  ------------------------------------------------------------------------
  -- Apparently the record doesn't exist so create it
  ------------------------------------------------------------------------
  IF (SQL%NOTFOUND)
  THEN
    INSERT INTO JTF_BRM_RULES_TL
    (  RULE_ID
    ,  CREATED_BY
    ,  CREATION_DATE
    ,  LAST_UPDATED_BY
    ,  LAST_UPDATE_DATE
    ,  LAST_UPDATE_LOGIN
    ,  RULE_NAME
    ,  RULE_DESCRIPTION
    ,  LANGUAGE
    ,  SOURCE_LANG
    ,  APPLICATION_ID
    ) SELECT p_rule_id
      ,      l_user_id
      ,      SYSDATE
      ,      l_user_id
      ,      SYSDATE
      ,      0
      ,      p_br_rec.rule_name
      ,      p_br_rec.rule_description
      ,      l.LANGUAGE_CODE
      ,      userenv('LANG')
      ,      p_br_rec.application_id
      FROM FND_LANGUAGES    l
      WHERE l.INSTALLED_FLAG IN ('I', 'B')
      AND NOT EXISTS( SELECT NULL
                      FROM JTF_BRM_RULES_TL t
                      WHERE t.RULE_ID = p_rule_id
                      AND   t.LANGUAGE = l.LANGUAGE_CODE
                    );
  END IF;
END Load_Row;

END JTF_BRMRule_PVT;

/
