--------------------------------------------------------
--  DDL for Package Body EGO_LIFECYCLE_ADMIN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_LIFECYCLE_ADMIN_PUB" AS
/* $Header: EGOPLCAB.pls 115.5 2004/05/26 09:55:19 srajapar noship $ */

  g_pkg_name                VARCHAR2(30) := 'EGO_LIFECYCLE_ADMIN_PUB';
  g_current_user_id         NUMBER       := EGO_SCTX.Get_User_Id();
  g_current_login_id        NUMBER       := FND_GLOBAL.Login_Id;
  g_app_name                VARCHAR2(3)  := 'EGO';
  g_plsql_err               VARCHAR2(17) := 'EGO_PLSQL_ERR';
  g_pkg_name_token          VARCHAR2(8)  := 'PKG_NAME';
  g_api_name_token          VARCHAR2(8)  := 'API_NAME';
  g_sql_err_msg_token       VARCHAR2(11) := 'SQL_ERR_MSG';

 PROCEDURE Check_Delete_Lifecycle_OK
(
     p_api_version             IN      NUMBER
   , p_lifecycle_id            IN      PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
   , p_init_msg_list           IN      VARCHAR2   := fnd_api.g_FALSE
   , x_delete_ok               OUT     NOCOPY VARCHAR2
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
)
IS
  l_count  NUMBER;
  l_api_name        CONSTANT VARCHAR2(30)     := 'Check_Delete_Lifecycle_OK';
  l_message VARCHAR2(4000) := NULL;
 BEGIN

  IF FND_API.To_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.Initialize;
  END IF;

   x_delete_ok := FND_API.G_TRUE;
   --Check if there are any entries for it in MTL_SYSTEM_ITEMS
  BEGIN
    SELECT 1
    INTO l_count
    FROM DUAL
    WHERE EXISTS
      (SELECT 'X'
       FROM  MTL_SYSTEM_ITEMS_B
       WHERE LIFECYCLE_ID = p_lifecycle_id);
    x_delete_ok := FND_API.G_FALSE;
    l_message := 'EGO_ITEM_ASSOCIATED_LC';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
      -- no rows found
      -- check item revisions
  END;

  IF (l_message IS NULL) THEN
    BEGIN
      SELECT 1
      INTO l_count
      FROM DUAL
      WHERE EXISTS
        (SELECT 'X'
        FROM  MTL_ITEM_REVISIONS_B
        WHERE LIFECYCLE_ID = p_lifecycle_id);
      x_delete_ok := FND_API.G_FALSE;
      l_message := 'EGO_REVISION_ASSOCIATED_LC';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
        -- no rows found
        -- check for pending item status
    END;
  END IF;

  IF (l_message IS NULL) THEN
    BEGIN
      SELECT 1
      INTO l_count
      FROM DUAL
      WHERE EXISTS
        (SELECT 'X'
         FROM  MTL_PENDING_ITEM_STATUS
         WHERE LIFECYCLE_ID = p_lifecycle_id);
      x_delete_ok := FND_API.G_FALSE;
      l_message := 'EGO_PENDING_ITEM_LC';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
        -- no rows found
        -- every thing is fine
    END;
  END IF;

  IF (l_message IS NOT NULL)  THEN
    FND_MESSAGE.Set_Name(g_app_name
		        ,l_message);
    FND_MSG_PUB.Add;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
   WHEN OTHERS THEN
     x_delete_ok := FND_API.G_FALSE;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.Set_Name(g_app_name
                         ,g_plsql_err);
     FND_MESSAGE.Set_Token(g_pkg_name_token, g_pkg_name);
     FND_MESSAGE.Set_Token(g_api_name_token, l_api_name);
     FND_MESSAGE.Set_Token(g_sql_err_msg_token, SQLERRM);
     FND_MSG_PUB.Add;

END Check_Delete_Lifecycle_OK;

PROCEDURE Check_Delete_Phase_OK
(
    p_api_version             IN      NUMBER
  , p_phase_id                IN      PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE
  , p_init_msg_list           IN      VARCHAR2   := FND_API.G_FALSE
  , x_delete_ok               OUT     NOCOPY VARCHAR2
  , x_return_status           OUT     NOCOPY VARCHAR2
  , x_errorcode               OUT     NOCOPY NUMBER
  , x_msg_count               OUT     NOCOPY NUMBER
  , x_msg_data                OUT     NOCOPY VARCHAR2
)
IS
    l_count           NUMBER;
    l_message         VARCHAR2(4000);
    l_api_name        CONSTANT VARCHAR2(30)     := 'Check_Delete_Phase_OK';
BEGIN

   IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
   END IF;
   x_delete_ok := FND_API.G_TRUE;

  BEGIN
    SELECT 1
    INTO l_count
    FROM DUAL
    WHERE EXISTS
      (SELECT 'X'
       FROM  MTL_SYSTEM_ITEMS_B
       WHERE CURRENT_PHASE_ID = p_phase_id);
    x_delete_ok := FND_API.G_FALSE;
    l_message := 'EGO_ITEM_ASSOCIATED_PH';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
      -- no rows found
      -- check item revisions
  END;

  IF (l_message IS NULL) THEN
    BEGIN
      SELECT 1
      INTO l_count
      FROM DUAL
      WHERE EXISTS
        (SELECT 'X'
         FROM  MTL_ITEM_REVISIONS_B
         WHERE CURRENT_PHASE_ID = p_phase_id);
      x_delete_ok := FND_API.G_FALSE;
      l_message := 'EGO_REVISION_ASSOCIATED_PH';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
        -- no rows found
        -- check if there are any pending item status
    END;
  END IF;

  IF (l_message IS NULL) THEN
    BEGIN
      SELECT 1
      INTO l_count
      FROM DUAL
      WHERE EXISTS
        (SELECT 'X'
         FROM  MTL_PENDING_ITEM_STATUS
         WHERE PHASE_ID = p_phase_id);
      x_delete_ok := FND_API.G_FALSE;
      l_message := 'EGO_PENDING_ITEM_PH';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
        -- no rows found
        -- every thing is fine
    END;
  END IF;

  IF (l_message IS NOT NULL)  THEN
    FND_MESSAGE.Set_Name(g_app_name
                      ,l_message
                      );
    FND_MSG_PUB.Add;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
   WHEN OTHERS THEN
     x_delete_ok := FND_API.G_FALSE;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.Set_Name(g_app_name
                         ,g_plsql_err);
     FND_MESSAGE.Set_Token(g_pkg_name_token, g_pkg_name);
     FND_MESSAGE.Set_Token(g_api_name_token, l_api_name);
     FND_MESSAGE.Set_Token(g_sql_err_msg_token, SQLERRM);
     FND_MSG_PUB.Add;

END Check_Delete_Phase_OK;


PROCEDURE Process_Phase_Delete
(
    p_api_version             IN  NUMBER
  , p_phase_id                IN  NUMBER
  , p_init_msg_list           IN   VARCHAR2   := fnd_api.g_FALSE
  , p_commit                  IN   VARCHAR2   := fnd_api.g_FALSE
  , x_return_status           OUT  NOCOPY VARCHAR2
  , x_errorcode               OUT  NOCOPY NUMBER
  , x_msg_count               OUT  NOCOPY NUMBER
  , x_msg_data                OUT  NOCOPY VARCHAR2
)
IS
  l_api_name        CONSTANT VARCHAR2(30)     := 'Process_Phase_Delete';
  l_api_version     CONSTANT NUMBER           := 1.0;
BEGIN
  IF FND_API.To_Boolean(p_commit) THEN
    SAVEPOINT Process_Phase_Delete_PUB;
  END IF;
  --Standard checks
 IF NOT FND_API.Compatible_API_Call (l_api_version
                                    ,p_api_version
                                    ,l_api_name
                                    ,g_pkg_name)
 THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
  IF FND_API.To_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.Initialize;
 END IF;

  --Delete the stale data from ego_lcphase_policy
 DELETE
 FROM
   EGO_LCPHASE_POLICY
 WHERE
   PHASE_ID = p_phase_id;

  -- Standard check of p_commit.
 IF FND_API.To_Boolean(p_commit)
 THEN
   COMMIT WORK;
 END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
   WHEN OTHERS THEN
     IF FND_API.To_Boolean(p_commit) THEN
       ROLLBACK TO Process_Phase_Delete_PUB;
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.Set_Name(g_app_name
                         ,g_plsql_err);
     FND_MESSAGE.Set_Token(g_pkg_name_token, g_pkg_name);
     FND_MESSAGE.Set_Token(g_api_name_token, l_api_name);
     FND_MESSAGE.Set_Token(g_sql_err_msg_token, SQLERRM);
     FND_MSG_PUB.Add;

END Process_Phase_Delete;

PROCEDURE Process_Phase_Code_Delete
(
     p_api_version             IN   NUMBER
   , p_phase_code              IN   VARCHAR2
   , p_init_msg_list           IN   VARCHAR2   := fnd_api.g_FALSE
   , p_commit                  IN   VARCHAR2   := fnd_api.g_FALSE
   , x_return_status           OUT  NOCOPY VARCHAR2
   , x_errorcode               OUT  NOCOPY NUMBER
   , x_msg_count               OUT  NOCOPY NUMBER
   , x_msg_data                OUT  NOCOPY VARCHAR2
)
IS
  l_api_name        CONSTANT VARCHAR2(30)     := 'Process_Phase_Code_Delete';
  l_api_version     CONSTANT NUMBER           := 1.0;
BEGIN
  IF FND_API.To_Boolean(p_commit) THEN
   SAVEPOINT Process_Phase_Code_Delete_PUB;
  END IF;
  --Standard checks
 IF NOT FND_API.Compatible_API_Call (l_api_version
                                    ,p_api_version
                                    ,l_api_name
                                    ,g_pkg_name)
 THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
  IF FND_API.To_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.Initialize;
 END IF;

  --Delete the stale data from ego_lcphase_item_status
  DELETE
  FROM
    EGO_LCPHASE_ITEM_STATUS
  WHERE
    PHASE_CODE = p_phase_code;

  -- Standard check of p_commit.
 IF FND_API.To_Boolean(p_commit)
 THEN
   COMMIT WORK;
 END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
   WHEN OTHERS THEN
     IF FND_API.To_Boolean(p_commit) THEN
       ROLLBACK TO Process_Phase_Code_Delete_PUB;
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.Set_Name(g_app_name
                         ,g_plsql_err);
     FND_MESSAGE.Set_Token(g_pkg_name_token, g_pkg_name);
     FND_MESSAGE.Set_Token(g_api_name_token, l_api_name);
     FND_MESSAGE.Set_Token(g_sql_err_msg_token, SQLERRM);
     FND_MSG_PUB.Add;

END Process_Phase_Code_Delete;

PROCEDURE Delete_Stale_Data_For_Lc
(
    p_api_version             IN  NUMBER
  , p_lifecycle_id            IN  NUMBER
  , p_init_msg_list           IN   VARCHAR2   := fnd_api.g_FALSE
  , p_commit                  IN   VARCHAR2   := fnd_api.g_FALSE
  , x_return_status           OUT  NOCOPY VARCHAR2
  , x_errorcode               OUT  NOCOPY NUMBER
  , x_msg_count               OUT  NOCOPY NUMBER
  , x_msg_data                OUT  NOCOPY VARCHAR2
)
IS
  l_api_name        CONSTANT VARCHAR2(30)     := 'Delete_Stale_Data_For_Lc';
  l_api_version     CONSTANT NUMBER           := 1.0;
BEGIN
  IF FND_API.To_Boolean(p_commit) THEN
    SAVEPOINT Delete_Stale_Data_Lc_PUB;
  END IF;
  --Standard checks
 IF NOT FND_API.Compatible_API_Call (l_api_version
                                    ,p_api_version
                                    ,l_api_name
                                    ,g_pkg_name)
 THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
  IF FND_API.To_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.Initialize;
 END IF;
  --Delete the stale data from ego_obj_type_lifecycles
 DELETE
 FROM
   EGO_OBJ_TYPE_LIFECYCLES
 WHERE
   LIFECYCLE_ID = p_lifecycle_id;
  -- Standard check of p_commit.
 IF FND_API.To_Boolean(p_commit)
 THEN
   COMMIT WORK;
 END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Make a standard call to get message count and if count is 1,
 -- get message info.
 -- The client will directly display the x_msg_data (which is already
 -- translated) if the x_msg_count = 1;
 -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
 -- Server-side procedure to access the messages, and consolidate them
 -- and display them all at once or display one message after another.
  FND_MSG_PUB.Count_And_Get
 (
     p_count        =>      x_msg_count,
     p_data         =>      x_msg_data
 );
  EXCEPTION
   WHEN OTHERS THEN
     IF FND_API.To_Boolean(p_commit) THEN
       ROLLBACK TO Delete_Stale_Data_Lc_PUB;
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MESSAGE.Set_Name(g_app_name
                         ,g_plsql_err);
     FND_MESSAGE.Set_Token(g_pkg_name_token, g_pkg_name);
     FND_MESSAGE.Set_Token(g_api_name_token, l_api_name);
     FND_MESSAGE.Set_Token(g_sql_err_msg_token, SQLERRM);
     FND_MSG_PUB.Add;

END Delete_Stale_Data_For_Lc;
END EGO_LIFECYCLE_ADMIN_PUB;


/
