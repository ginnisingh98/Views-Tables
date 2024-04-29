--------------------------------------------------------
--  DDL for Package Body JTF_BRMEXPRESSIONLINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_BRMEXPRESSIONLINE_PVT" AS
/* $Header: jtfvbelb.pls 120.2 2005/07/05 07:36:03 abraina ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_BRMExpressionLine_PVT';

--------------------------------------------------------------------------
-- Start of comments
--  Procedure   : Create_ExpressionLine
--  Description : Create record in JTF_BRM_EXPRESSION_LINES table
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
--      p_bel_rec            IN         brm_expression_line_rec_type required
--      x_record_id             OUT     NUMBER
--
--  Notes :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Create_ExpressionLine
( p_api_version        IN     NUMBER
, p_init_msg_list      IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit             IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level   IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_bel_rec            IN     brm_expression_line_rec_type
, x_record_id             OUT NOCOPY NUMBER
)
IS
  l_api_name              CONSTANT VARCHAR2(30)   := 'Create_ExpressionLine';
  l_api_version           CONSTANT NUMBER         := 1.1;
  l_api_name_full         CONSTANT VARCHAR2(61)   := G_PKG_NAME||'.'||l_api_name;
  l_object_version_number          NUMBER         := 1;
  l_return_status                  VARCHAR2(1);
  l_rowid                          ROWID;
  l_expression_line_id             NUMBER;

  CURSOR C IS SELECT ROWID
              FROM   JTF_BRM_EXPRESSION_LINES
              WHERE  expression_line_id = l_expression_line_id;

BEGIN
  --
  -- Standard start of API savepoint
  --
  SAVEPOINT Create_ExpressionLine_PVT;

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

  ------------------------------------------------------------------------
  -- Perform the database operation. Generate the ID from the
  -- sequence, then insert the passed in attributes into the
  -- JTF_BRM_EXPRESION_LINE table.
  ------------------------------------------------------------------------
  IF (p_bel_rec.expression_line_id IS NULL)
  THEN
    SELECT jtf_brm_expression_lines_s.NEXTVAL
    INTO   l_expression_line_id
    FROM   DUAL;
  ELSE
    l_expression_line_id := p_bel_rec.expression_line_id;
  END IF;

  --
  -- Insert into table
  --
  INSERT INTO JTF_BRM_EXPRESSION_LINES
  ( EXPRESSION_LINE_ID
  , RULE_ID
  , CREATED_BY
  , CREATION_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATE_LOGIN
  , SORT_SEQUENCE
  , BRM_LEFT_PARENTHESIS_TYPE
  , BRM_LEFT_PARENTHESIS_CODE
  , LEFT_VALUE
  , BRM_OPERATOR_TYPE
  , BRM_OPERATOR_CODE
  , RIGHT_VALUE
  , BRM_RIGHT_PARENTHESIS_TYPE
  , BRM_RIGHT_PARENTHESIS_CODE
  , BRM_BOOLEAN_OPERATOR_TYPE
  , BRM_BOOLEAN_OPERATOR_CODE
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
  ( l_expression_line_id
  , p_bel_rec.RULE_ID
  , p_bel_rec.CREATED_BY
  , p_bel_rec.CREATION_DATE
  , p_bel_rec.LAST_UPDATED_BY
  , p_bel_rec.LAST_UPDATE_DATE
  , p_bel_rec.LAST_UPDATE_LOGIN
  , p_bel_rec.SORT_SEQUENCE
  , p_bel_rec.BRM_LEFT_PARENTHESIS_TYPE
  , p_bel_rec.BRM_LEFT_PARENTHESIS_CODE
  , p_bel_rec.LEFT_VALUE
  , p_bel_rec.BRM_OPERATOR_TYPE
  , p_bel_rec.BRM_OPERATOR_CODE
  , p_bel_rec.RIGHT_VALUE
  , p_bel_rec.BRM_RIGHT_PARENTHESIS_TYPE
  , p_bel_rec.BRM_RIGHT_PARENTHESIS_CODE
  , p_bel_rec.BRM_BOOLEAN_OPERATOR_TYPE
  , p_bel_rec.BRM_BOOLEAN_OPERATOR_CODE
  , p_bel_rec.ATTRIBUTE1
  , p_bel_rec.ATTRIBUTE2
  , p_bel_rec.ATTRIBUTE3
  , p_bel_rec.ATTRIBUTE4
  , p_bel_rec.ATTRIBUTE5
  , p_bel_rec.ATTRIBUTE6
  , p_bel_rec.ATTRIBUTE7
  , p_bel_rec.ATTRIBUTE8
  , p_bel_rec.ATTRIBUTE9
  , p_bel_rec.ATTRIBUTE10
  , p_bel_rec.ATTRIBUTE11
  , p_bel_rec.ATTRIBUTE12
  , p_bel_rec.ATTRIBUTE13
  , p_bel_rec.ATTRIBUTE14
  , p_bel_rec.ATTRIBUTE15
  , p_bel_rec.ATTRIBUTE_CATEGORY
  , p_bel_rec.SECURITY_GROUP_ID
  , l_object_version_number
  , p_bel_rec.APPLICATION_ID
  );

  --
  -- Check if the record was created
  --
  OPEN c;
  FETCH c INTO l_ROWID;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    RAISE no_data_found;
  END IF;
  CLOSE c;

  --
  -- Return the key value to the caller
  --
  x_record_id := l_expression_line_id;

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
    ROLLBACK TO Create_ExpressionLine_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    ROLLBACK TO Create_ExpressionLine_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
  WHEN OTHERS
  THEN
    ROLLBACK TO Create_ExpressionLine_PVT;
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

END Create_ExpressionLine;

--------------------------------------------------------------------------
-- Start of comments
--  Procedure   : Update_ExpressionLine
--  Description : Update record in JTF_BRM_EXPRESSION_LINES table
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
--      p_bel_rec            IN         brm_expression_line_rec_type required
--
--  Notes :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Update_ExpressionLine
( p_api_version      IN     NUMBER
, p_init_msg_list    IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_bel_rec          IN     brm_expression_line_rec_type
)
IS
  l_api_name              CONSTANT VARCHAR2(30)    := 'Update_ExpressionLine';
  l_api_version           CONSTANT NUMBER          := 1.1;
  l_api_name_full         CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_object_version_number          NUMBER;
  l_return_status                  VARCHAR2(1);
  l_msg_count                      NUMBER;
  l_msg_data                       VARCHAR2(2000);

BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Update_ExpressionLine_PVT;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ------------------------------------------------------------------------
  -- Get a new object version number
  ------------------------------------------------------------------------
  SELECT jtf_brm_expression_lines_s.NEXTVAL
  INTO   l_object_version_number
  FROM   DUAL;

  UPDATE JTF_BRM_EXPRESSION_LINES
  SET RULE_ID = p_bel_rec.RULE_ID
  ,   LAST_UPDATED_BY = p_bel_rec.LAST_UPDATED_BY
  ,   LAST_UPDATE_DATE = p_bel_rec.LAST_UPDATE_DATE
  ,   LAST_UPDATE_LOGIN = p_bel_rec.LAST_UPDATE_LOGIN
  ,   SORT_SEQUENCE = p_bel_rec.SORT_SEQUENCE
  ,   BRM_LEFT_PARENTHESIS_TYPE = p_bel_rec.BRM_LEFT_PARENTHESIS_TYPE
  ,   BRM_LEFT_PARENTHESIS_CODE = p_bel_rec.BRM_LEFT_PARENTHESIS_CODE
  ,   LEFT_VALUE = p_bel_rec.LEFT_VALUE
  ,   BRM_OPERATOR_TYPE = p_bel_rec.BRM_OPERATOR_TYPE
  ,   BRM_OPERATOR_CODE = p_bel_rec.BRM_OPERATOR_CODE
  ,   RIGHT_VALUE = p_bel_rec.RIGHT_VALUE
  ,   BRM_RIGHT_PARENTHESIS_TYPE = p_bel_rec.BRM_RIGHT_PARENTHESIS_TYPE
  ,   BRM_RIGHT_PARENTHESIS_CODE = p_bel_rec.BRM_RIGHT_PARENTHESIS_CODE
  ,   BRM_BOOLEAN_OPERATOR_TYPE = p_bel_rec.BRM_BOOLEAN_OPERATOR_TYPE
  ,   BRM_BOOLEAN_OPERATOR_CODE = p_bel_rec.BRM_BOOLEAN_OPERATOR_CODE
  ,   ATTRIBUTE1 = p_bel_rec.ATTRIBUTE1
  ,   ATTRIBUTE2 = p_bel_rec.ATTRIBUTE2
  ,   ATTRIBUTE3 = p_bel_rec.ATTRIBUTE3
  ,   ATTRIBUTE4 = p_bel_rec.ATTRIBUTE4
  ,   ATTRIBUTE5 = p_bel_rec.ATTRIBUTE5
  ,   ATTRIBUTE6 = p_bel_rec.ATTRIBUTE6
  ,   ATTRIBUTE7 = p_bel_rec.ATTRIBUTE7
  ,   ATTRIBUTE8 = p_bel_rec.ATTRIBUTE8
  ,   ATTRIBUTE9 = p_bel_rec.ATTRIBUTE9
  ,   ATTRIBUTE10 = p_bel_rec.ATTRIBUTE10
  ,   ATTRIBUTE11 = p_bel_rec.ATTRIBUTE11
  ,   ATTRIBUTE12 = p_bel_rec.ATTRIBUTE12
  ,   ATTRIBUTE13 = p_bel_rec.ATTRIBUTE13
  ,   ATTRIBUTE14 = p_bel_rec.ATTRIBUTE14
  ,   ATTRIBUTE15 = p_bel_rec.ATTRIBUTE15
  ,   ATTRIBUTE_CATEGORY = p_bel_rec.ATTRIBUTE_CATEGORY
  ,   SECURITY_GROUP_ID = p_bel_rec.SECURITY_GROUP_ID
  ,   OBJECT_VERSION_NUMBER = l_object_version_number
  ,   APPLICATION_ID = p_bel_rec.APPLICATION_ID
  WHERE EXPRESSION_LINE_ID = p_bel_rec.EXPRESSION_LINE_ID;

  --
  -- Check if the update was succesfull
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
    ROLLBACK TO Update_ExpressionLine_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    ROLLBACK TO Update_ExpressionLine_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

  WHEN OTHERS
  THEN
    ROLLBACK TO Update_ExpressionLine_PVT;
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

END Update_ExpressionLine;


--------------------------------------------------------------------------
-- Start of comments
--  Procedure   : Delete_ExpressionLine
--  Description : Delete record in JTF_BRM_EXPRESSION_LINES table
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
--      p_expression_line_id IN         NUMBER   required
--
--  Notes :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Delete_ExpressionLine
( p_api_version        IN     NUMBER
, p_init_msg_list      IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit             IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level   IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_expression_line_id IN     NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'Delete_ExpressionLine';
  l_api_version   CONSTANT NUMBER       := 1.1;
  l_api_name_full CONSTANT VARCHAR2(62) := G_PKG_NAME||'.'||l_api_name;
  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
BEGIN
  --
  -- Establish save point
  --
  SAVEPOINT Delete_ExpressionLine_PVT;

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

  DELETE FROM JTF_BRM_EXPRESSION_LINES
  WHERE expression_line_id = p_expression_line_id;

  --
  -- Check if the delete was succesfull
  --
  IF (SQL%NOTFOUND)
  THEN
    RAISE NO_DATA_FOUND;
  END IF;

  IF FND_API.To_Boolean( p_commit )
  THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get( p_count  => X_MSG_COUNT
                           , p_data  => X_MSG_DATA
                           );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR
    THEN
      ROLLBACK TO Delete_ExpressionLine_PVT;
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => X_MSG_COUNT
                               , p_data  => X_MSG_DATA
                               );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
      ROLLBACK TO Delete_ExpressionLine_PVT;
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => X_MSG_COUNT
                               , p_data  => X_MSG_DATA
                               );

    WHEN OTHERS
    THEN
      ROLLBACK TO Delete_ExpressionLine_PVT;
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

END Delete_ExpressionLine;

END JTF_BRMExpressionLine_PVT;

/
