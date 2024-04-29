--------------------------------------------------------
--  DDL for Package Body ENG_LIFECYCLE_USER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_LIFECYCLE_USER_PUB" AS
/* $Header: ENGPLCUB.pls 115.0 2003/02/06 00:22:51 hshou noship $ */

  g_pkg_name                 CONSTANT VARCHAR2(30) := 'ENG_LIFECYCLE_USER_PUB';
  g_app_name                 CONSTANT VARCHAR2(3)  := 'ENG';
  g_current_user_id          NUMBER                := FND_GLOBAL.User_Id;
  g_current_login_id         NUMBER                := FND_GLOBAL.Login_Id;
  g_validation_error         EXCEPTION;
  g_same_sequence_error      EXCEPTION;
  g_project_assoc_type       CONSTANT VARCHAR2(24) := 'ENG_ITEM_PROJ_ASSOC_TYPE';
  g_lifecycle_tracking_code  CONSTANT VARCHAR2(18) := 'LIFECYCLE_TRACKING';
  g_promote                  CONSTANT VARCHAR2(7)  := 'PROMOTE';
  g_demote                   CONSTANT VARCHAR2(6)  := 'DEMOTE';
  g_plsql_err                VARCHAR2(17)          := 'ENG_PLSQL_ERR';
  g_pkg_name_token           VARCHAR2(8)           := 'PKG_NAME';
  g_api_name_token           VARCHAR2(8)           := 'API_NAME';
  g_sql_err_msg_token        VARCHAR2(11)          := 'SQL_ERR_MSG';
  g_not_allowed              CONSTANT VARCHAR2(11) := 'NOT_ALLOWED';



-- Public Procedures
----------------------------------------------------------------------
PROCEDURE Check_Delete_Project_OK
(
     p_api_version             IN      NUMBER
   , p_project_id              IN      PA_PROJECTS.PROJECT_ID%TYPE
   , p_init_msg_list           IN      VARCHAR2   := fnd_api.g_FALSE
   , x_delete_ok               OUT     NOCOPY VARCHAR2
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
)
IS

    l_api_version  CONSTANT NUMBER           := 1.0;
    l_exist VARCHAR2(1);
    l_api_name     CONSTANT VARCHAR2(30)     := 'Check_Delete_Project_OK';
    l_message      VARCHAR2(4000);

    Cursor check_project_used(X_project_id number
        ) is
        select 'y'
        from dual
        where exists(
        select null
        from ENG_ENGINEERING_CHANGES
        where PROJECT_ID = X_project_id);

  BEGIN

    --Standard checks
    IF NOT FND_API.Compatible_API_Call (l_api_version
                                       ,p_api_version
                                       ,l_api_name
                                       ,g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --Check if there are any projects referred by changes
    open check_project_used(p_project_id);
    fetch check_project_used into l_exist;
    IF check_project_used%found
    THEN
      x_delete_ok := FND_API.G_FALSE;
      l_message := 'ENG_CHNAGE_ASSOCIATED_PROJ';
    END IF;

    IF (l_message IS NOT NULL)
    THEN
      FND_MESSAGE.Set_Name(g_app_name, l_message);
    FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(
        p_encoded        => FND_API.G_FALSE,
        p_count          => x_msg_count,
        p_data           => x_msg_data
      );
      x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_delete_ok := FND_API.G_FALSE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name(g_app_name, g_plsql_err);
      FND_MESSAGE.Set_Token(g_pkg_name_token, g_pkg_name);
      FND_MESSAGE.Set_Token(g_api_name_token, l_api_name);
      FND_MESSAGE.Set_Token(g_sql_err_msg_token, SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(
        p_encoded        => FND_API.G_FALSE,
        p_count          => x_msg_count,
        p_data           => x_msg_data
      );

END Check_Delete_Project_OK;

----------------------------------------------------------------------

 PROCEDURE Check_Delete_Task_OK
(
     p_api_version             IN      NUMBER
   , p_task_id                 IN      PA_TASKS.TASK_ID%TYPE
   , p_init_msg_list           IN      VARCHAR2   := fnd_api.g_FALSE
   , x_delete_ok               OUT     NOCOPY VARCHAR2
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
)
IS

    l_api_version  CONSTANT NUMBER           := 1.0;
    l_exist VARCHAR2(1);
    l_api_name     CONSTANT VARCHAR2(30)     := 'Check_Delete_Project_OK';
    l_message      VARCHAR2(4000);

    Cursor check_task_used(X_task_id number
        ) is
        select 'y'
        from dual
        where exists(
        select null
        from ENG_ENGINEERING_CHANGES
        where TASK_ID = X_task_id );


BEGIN

    --Standard checks
    IF NOT FND_API.Compatible_API_Call (l_api_version
                                       ,p_api_version
                                       ,l_api_name
                                       ,g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    --Check if there are any projects referred by changes
    open check_task_used(p_task_id);
    fetch check_task_used into l_exist;
    IF check_task_used%found
    THEN
      x_delete_ok := FND_API.G_FALSE;
      l_message := 'ENG_CHNAGE_ASSOCIATED_TASK';
    END IF;

    IF (l_message IS NOT NULL)
    THEN
      FND_MESSAGE.Set_Name(g_app_name, l_message);
    FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(
        p_encoded        => FND_API.G_FALSE,
        p_count          => x_msg_count,
        p_data           => x_msg_data
      );
      x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_delete_ok := FND_API.G_FALSE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name(g_app_name, g_plsql_err);
      FND_MESSAGE.Set_Token(g_pkg_name_token, g_pkg_name);
      FND_MESSAGE.Set_Token(g_api_name_token, l_api_name);
      FND_MESSAGE.Set_Token(g_sql_err_msg_token, SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(
        p_encoded        => FND_API.G_FALSE,
        p_count          => x_msg_count,
        p_data           => x_msg_data
      );

END Check_Delete_Task_OK;




END ENG_LIFECYCLE_USER_PUB;


/
