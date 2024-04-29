--------------------------------------------------------
--  DDL for Package Body EGO_OBJ_TYPE_LIFECYCLES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_OBJ_TYPE_LIFECYCLES_PUB" AS
/* $Header: EGOPOTLB.pls 115.2 2002/12/19 08:34:15 wwahid noship $ */

-- ------------------------------------------------------------
-- -------------- Global variables and constants --------------
-- ------------------------------------------------------------

   g_pkg_name                VARCHAR2(30) := 'EGO_OBJ_TYPE_LIFECYCLES_PUB';
   g_current_user_id         NUMBER       := EGO_SCTX.Get_User_Id();
   g_current_login_id        NUMBER       := FND_GLOBAL.Login_Id;

   G_DUPLICATE_EXCEPTION             EXCEPTION;
   -- Character-set independent NEWLINE, TAB and WHITESPACE
   --
   NEWLINE                   CONSTANT VARCHAR2(4) := fnd_global.newline;
   MAX_SEG_SIZE              CONSTANT NUMBER      := 200;



----------------------------------------------------------------------
PROCEDURE Create_Obj_Type_Lifecycle(
          p_api_version                 IN   NUMBER
        , p_object_id                   IN   NUMBER
        , p_object_classification_code  IN   VARCHAR2
        , p_lifecycle_id                IN   NUMBER
        , p_init_msg_list               IN   VARCHAR2   := fnd_api.g_FALSE
        , p_commit                      IN   VARCHAR2   := fnd_api.g_FALSE
        , x_return_status               OUT  NOCOPY VARCHAR2
        , x_errorcode                   OUT  NOCOPY NUMBER
        , x_msg_count                   OUT  NOCOPY NUMBER
        , x_msg_data                    OUT  NOCOPY VARCHAR2
) IS

    l_api_name          CONSTANT VARCHAR2(30)   := 'Create_Lifecycle';
    l_api_version CONSTANT NUMBER         := 1.0;
    l_object_id         fnd_objects.object_id%TYPE;

    -- General variables

    l_Sysdate           DATE                    := Sysdate;
    l_language          VARCHAR2(4)             := userenv('LANG');
    l_count             NUMBER;

--------------------------------------------------

    BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT   Create_Obj_Type_Lifecycle_PUB;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

------------------------------

  -- Check if the obj_type_lifecycle already exists

    SELECT COUNT (*) INTO l_count
    FROM
      EGO_OBJ_TYPE_LIFECYCLES
    WHERE
      OBJECT_ID = p_object_id
      AND OBJECT_CLASSIFICATION_CODE = p_object_classification_code
      AND LIFECYCLE_ID = p_lifecycle_id;

    IF (l_count > 0)
    THEN
      RAISE G_DUPLICATE_EXCEPTION;
    END IF;

    INSERT INTO EGO_OBJ_TYPE_LIFECYCLES
    (
          OBJECT_ID
        , OBJECT_CLASSIFICATION_CODE
        , LIFECYCLE_ID
        , CREATED_BY
        , CREATION_DATE
        , LAST_UPDATED_BY
        , LAST_UPDATE_DATE
        , LAST_UPDATE_LOGIN
    )
    VALUES
    (
          p_object_id
        , p_object_classification_code
        , p_lifecycle_id
        , g_current_user_id
        , l_Sysdate
        , g_current_user_id
        , l_Sysdate
        , g_current_login_id
    );

------------------------------

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

------------------------------

    -- Standard call to get message count and if count is 1,
    -- get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display (or) to display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

--------------------------------------------------

    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO Create_Obj_Type_Lifecycle_PUB;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get
                (   p_count        =>      x_msg_count,
                    p_data         =>      x_msg_data
                );

         x_msg_data := 'Executing - ' || G_PKG_NAME || '.' || l_api_name || ' ' || SQLERRM;

        WHEN G_DUPLICATE_EXCEPTION THEN
            ROLLBACK TO Create_Obj_Type_Lifecycle_PUB;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get
                (   p_count        =>      x_msg_count,
                    p_data         =>      x_msg_data
                );

         x_msg_data := 'EGO_DUP_OBJ_TYPE_LIFECYCLE';

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO Create_Obj_Type_Lifecycle_PUB;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get
            (   p_count        =>      x_msg_count,
                p_data         =>      x_msg_data
            );
         x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
       WHEN OTHERS THEN
         ROLLBACK TO Create_Obj_Type_Lifecycle_PUB;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF  FND_MSG_PUB.Check_Msg_Level
             (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
             FND_MSG_PUB.Add_Exc_Msg
                 (   G_PKG_NAME,
                     l_api_name
                 );
         END IF;
         FND_MSG_PUB.Count_And_Get
             (   p_count        =>      x_msg_count,
                 p_data         =>      x_msg_data
             );
         x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;

END Create_Obj_Type_Lifecycle;

----------------------------------------------------------------------

PROCEDURE Delete_Obj_Type_Lifecycle(
          p_api_version                 IN   NUMBER
        , p_object_id                   IN   NUMBER
        , p_object_classification_code  IN   VARCHAR2
        , p_lifecycle_id                IN   NUMBER
        , p_init_msg_list               IN   VARCHAR2   := fnd_api.g_FALSE
        , p_commit                      IN   VARCHAR2   := fnd_api.g_FALSE
        , x_return_status               OUT  NOCOPY VARCHAR2
        , x_errorcode                   OUT  NOCOPY NUMBER
        , x_msg_count                   OUT  NOCOPY NUMBER
        , x_msg_data                    OUT  NOCOPY VARCHAR2
) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'Delete_Obj_Type_Lifecycle';
  -- In addition to any Required parameters the major version needs
  -- to change i.e. for eg. 1.X to 2.X.
  -- In addition to any Optional parameters the minor version needs
  -- to change i.e. for eg. X.6 to X.7.

  l_api_version        CONSTANT NUMBER         := 1.0;

  -- General variables

  l_Sysdate            DATE                    := Sysdate;
  l_language           VARCHAR2(4)             := userenv('LANG');

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT   Delete_Obj_Type_Lifecycle_PUB;

  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize API message list if necessary.
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

-----------------------------------


  DELETE FROM EGO_OBJ_TYPE_LIFECYCLES
  WHERE
    OBJECT_ID = p_object_id
    AND OBJECT_CLASSIFICATION_CODE = p_object_classification_code
    AND LIFECYCLE_ID = p_lifecycle_id;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------------------
  -- Make a standard call to get message count and if count is 1,
  -- get message info.
  -- The client will directly display the x_msg_data (which is already
  -- translated) if the x_msg_count = 1;
  -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
  -- Server-side procedure to access the messages, and consolidate them
  -- and display them all at once or display one message after another.

  FND_MSG_PUB.Count_And_Get
  (   p_count        =>      x_msg_count,
      p_data         =>      x_msg_data
  );

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO Delete_Obj_Type_Lifecycle_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF  FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
            l_api_name
        );
      END IF;
      FND_MSG_PUB.Count_And_Get
      (   p_count        =>      x_msg_count,
          p_data         =>      x_msg_data
      );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
END Delete_Obj_Type_Lifecycle;

----------------------------------------------------------------------

END EGO_OBJ_TYPE_LIFECYCLES_PUB;

/
