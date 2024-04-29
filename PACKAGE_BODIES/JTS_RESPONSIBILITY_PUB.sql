--------------------------------------------------------
--  DDL for Package Body JTS_RESPONSIBILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTS_RESPONSIBILITY_PUB" as
/* $Header: jtsprspb.pls 115.4 2002/01/24 19:15:57 pkm ship       $ */


-- Start of Comments
-- Package name     : JTS_RESPONSIBILITY_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME     CONSTANT VARCHAR2(30)    := 'JTS_RESPONSIBILITY_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(12)     := 'jtsprspb.pls';


PROCEDURE Create_Responsibility
(   p_api_version_number     IN    NUMBER,
    p_init_msg_list         IN    VARCHAR2      :=FND_API.G_FALSE,
    p_commit                IN    VARCHAR2       := FND_API.G_FALSE,
    p_appl_id               IN      NUMBER,
    p_menu_id               IN      NUMBER,
    p_start_date            IN      DATE,
    p_end_date              IN      DATE,
    p_resp_key              IN      VARCHAR2,
    p_resp_name             IN      VARCHAR2,
    p_description           IN      VARCHAR2,
    x_return_status         OUT   VARCHAR2,
    x_msg_count             OUT   NUMBER,
    x_msg_data              OUT   VARCHAR2,
    x_resp_id               OUT  NUMBER
)
IS
    l_api_name                CONSTANT VARCHAR2(30) := 'Create_Responsibility';
    l_api_version_number      CONSTANT NUMBER   := 1.0;
    l_rowid        VARCHAR2(50);
    l_resp_id        NUMBER;

    CURSOR c_dup_key IS
    SELECT 'Y' FROM FND_RESPONSIBILITY
    WHERE application_id = p_appl_id
          AND responsibility_key = p_resp_key;
    l_found_dup         VARCHAR2(1) := 'N';

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT CREATE_RESPONSIBILITY_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version_number,
                                   p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --

    If (p_menu_id is NULL or
        p_menu_id = FND_API.G_MISS_NUM ) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_MISSING_DATA');
      FND_MESSAGE.Set_Token('COLUMN', 'Menu_Id');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if;

    If (p_appl_id is NULL or
        p_appl_id = FND_API.G_MISS_NUM ) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_MISSING_DATA');
      FND_MESSAGE.Set_Token('COLUMN', 'Application_Id');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if;

    If (p_resp_key is NULL or
        p_resp_key = FND_API.G_MISS_CHAR ) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_MISSING_DATA');
      FND_MESSAGE.Set_Token('COLUMN', 'Responsibility_Key');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if;

    OPEN C_Dup_Key;
    FETCH C_Dup_Key INTO l_found_dup;
    CLOSE C_Dup_Key;
    IF (l_found_dup = 'Y') THEN
      FND_MESSAGE.Set_Name('JTS', 'JTS_DUPLICATE_RESP_KEY');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    END IF;

    If (p_resp_name is NULL or
        p_resp_name = FND_API.G_MISS_CHAR ) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_MISSING_DATA');
      FND_MESSAGE.Set_Token('COLUMN', 'Responsibility_Name');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if;

    If (p_start_date is NULL or
        p_start_date = FND_API.G_MISS_Date ) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_MISSING_DATA');
      FND_MESSAGE.Set_Token('COLUMN', 'Start_Date');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if;


    SELECT fnd_responsibility_s.nextval
    INTO l_resp_id
    FROM dual;
    x_resp_id := l_resp_id;

    FND_RESPONSIBILITY_PKG.INSERT_ROW(
        X_ROWID => l_rowid,
            X_RESPONSIBILITY_ID => l_resp_id,
        X_APPLICATION_ID => p_appl_id,
            X_WEB_HOST_NAME => NULL,
                X_WEB_AGENT_NAME => NULL,
            X_DATA_GROUP_APPLICATION_ID => p_appl_id,
            X_DATA_GROUP_ID => 0,
            X_MENU_ID => p_menu_id,
        X_START_DATE => p_start_date,
            X_END_DATE => p_end_date,
            X_GROUP_APPLICATION_ID => NULL,
            X_REQUEST_GROUP_ID => NULL,
        X_VERSION => 'W',
            X_RESPONSIBILITY_KEY => p_resp_key,
            X_RESPONSIBILITY_NAME => p_resp_name,
                X_DESCRIPTION => p_description,
            X_CREATION_DATE => sysdate,
        X_CREATED_BY => FND_GLOBAL.USER_ID,
                X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
        X_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID);

    --
    -- End of API body.
    --

    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get(
        p_count    =>   x_msg_count,
        p_data     =>   x_msg_data
      );
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('JTS', 'Error number ' || to_char(SQLCODE));
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(
        p_count    =>   x_msg_count,
        p_data     =>   x_msg_data
      );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Create_Responsibility;


PROCEDURE Update_Responsibility
(   p_api_version_number     IN    NUMBER,
    p_init_msg_list         IN    VARCHAR2      :=FND_API.G_FALSE,
    p_commit                IN    VARCHAR2       := FND_API.G_FALSE,
    p_resp_id               IN      NUMBER,
    p_appl_id               IN      NUMBER,
    p_last_update_date      IN    DATE,
    p_menu_id               IN      NUMBER,
    p_start_date            IN      DATE,
    p_end_date              IN      DATE,
    p_resp_name             IN      VARCHAR2,
    p_description           IN      VARCHAR2,
    x_return_status         OUT   VARCHAR2,
    x_msg_count             OUT   NUMBER,
    x_msg_data              OUT   VARCHAR2
)
IS
    l_api_name                CONSTANT VARCHAR2(30) := 'Update_Responsibility';
    l_api_version_number      CONSTANT NUMBER   := 1.0;

    CURSOR C_RESP IS
    SELECT *
    FROM FND_RESPONSIBILITY
    WHERE responsibility_id = p_resp_id
      AND application_id = p_appl_id
    For Update NOWAIT;

    l_resp C_RESP%ROWTYPE;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT UPDATE_RESPONSIBILITY_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version_number,
                                   p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --

    OPEN c_resp;
    FETCH c_resp INTO l_resp;
    IF c_resp%NOTFOUND THEN
      CLOSE c_resp;
      FND_MESSAGE.Set_Name('JTS', 'JTS_NO_RESP_FOUND');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_resp;


    If (p_last_update_date is NULL or
        p_last_update_date = FND_API.G_MISS_Date ) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_MISSING_DATA');
      FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if;

    -- Check Whether record has been changed by someone else
    If (p_last_update_date <> l_resp.last_update_date) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_RECORD_CHANGED');
      FND_MSG_PUB.ADD;
      raise FND_API.G_EXC_ERROR;
    End if;


    If (p_menu_id is NULL or
        p_menu_id = FND_API.G_MISS_NUM ) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_MISSING_DATA');
      FND_MESSAGE.Set_Token('COLUMN', 'Menu_Id');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if;

    If (p_resp_name is NULL or
        p_resp_name = FND_API.G_MISS_CHAR ) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_MISSING_DATA');
      FND_MESSAGE.Set_Token('COLUMN', 'Responsibility_Name');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if;

    If (p_start_date is NULL or
        p_start_date = FND_API.G_MISS_Date ) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_MISSING_DATA');
      FND_MESSAGE.Set_Token('COLUMN', 'Start_Date');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if;


    FND_RESPONSIBILITY_PKG.UPDATE_ROW(
        X_RESPONSIBILITY_ID => p_resp_id,
        X_APPLICATION_ID => p_appl_id,
        X_WEB_HOST_NAME => l_resp.WEB_HOST_NAME,
        X_WEB_AGENT_NAME => l_resp.WEB_AGENT_NAME,
        X_DATA_GROUP_APPLICATION_ID => l_resp.DATA_GROUP_APPLICATION_ID,
        X_DATA_GROUP_ID => l_resp.DATA_GROUP_ID,
        X_MENU_ID => p_menu_id,
        X_START_DATE => p_start_date,
        X_END_DATE => p_end_date,
        X_GROUP_APPLICATION_ID => l_resp.GROUP_APPLICATION_ID,
        X_REQUEST_GROUP_ID => l_resp.REQUEST_GROUP_ID,
        X_VERSION => l_resp.VERSION,
        X_RESPONSIBILITY_KEY => l_resp.RESPONSIBILITY_KEY,
        X_RESPONSIBILITY_NAME => p_resp_name,
        X_DESCRIPTION => p_description,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
        X_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID);
    --
    -- End of API body.
    --

    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get(
        p_count    =>   x_msg_count,
        p_data     =>   x_msg_data
      );
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('JTS', 'Error number ' || to_char(SQLCODE));
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(
        p_count    =>   x_msg_count,
        p_data     =>   x_msg_data
      );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Update_Responsibility;

PROCEDURE Create_Resp_Functions
(   p_api_version_number    IN    NUMBER,
    p_init_msg_list         IN    VARCHAR2      :=FND_API.G_FALSE,
    p_commit                IN    VARCHAR2       := FND_API.G_FALSE,
    p_app_id                IN      NUMBER,
    p_resp_id               IN    NUMBER,
    p_action_id             IN      NUMBER,
    p_rule_type             IN      VARCHAR2,
    x_return_status         OUT   VARCHAR2,
    x_msg_count             OUT   NUMBER,
    x_msg_data              OUT   VARCHAR2,
    x_rowid                 OUT  VARCHAR2
)
IS
    l_api_name              CONSTANT VARCHAR2(30) := 'Create_Resp_Functions';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    --l_rowid        VARCHAR2(50);

    CURSOR c_dup_key IS
    SELECT 'Y' FROM FND_RESP_FUNCTIONS
    WHERE application_id = p_app_id
          AND responsibility_id = p_resp_id
          AND action_id = p_action_id
          AND rule_type = p_rule_type;
    l_found_dup         VARCHAR2(1) := 'N';

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT CREATE_RESP_FUNCTIONS_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version_number,
                                   p_api_version_number,
                                   l_api_name,
                                   G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --

    If (p_action_id is NULL or
        p_action_id = FND_API.G_MISS_NUM ) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_MISSING_DATA');
      FND_MESSAGE.Set_Token('COLUMN', 'Action_Id');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if;

    If (p_app_id is NULL or
        p_app_id = FND_API.G_MISS_NUM ) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_MISSING_DATA');
      FND_MESSAGE.Set_Token('COLUMN', 'Application_Id');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if;

    If (p_resp_id is NULL or
        p_resp_id = FND_API.G_MISS_NUM ) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_MISSING_DATA');
      FND_MESSAGE.Set_Token('COLUMN', 'Responsibility_Id');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if;

    If (p_rule_type is NULL or
        p_rule_type = FND_API.G_MISS_CHAR ) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_MISSING_DATA');
      FND_MESSAGE.Set_Token('COLUMN', 'Rule_Type');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if;

    OPEN C_Dup_Key;
    FETCH C_Dup_Key INTO l_found_dup;
    CLOSE C_Dup_Key;
    IF (l_found_dup = 'Y') THEN
      FND_MESSAGE.Set_Name('JTS', 'JTS_DUPLICATE_APP_RESP_ACTUION_RULETYPE');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    END IF;

    FND_RESP_FUNCTIONS_PKG.INSERT_ROW(
        X_ROWID => x_rowid,
        X_APPLICATION_ID => p_app_id,
        X_RESPONSIBILITY_ID => p_resp_id,
        X_ACTION_ID => p_action_id,
        X_RULE_TYPE => p_rule_type,
        X_CREATED_BY => FND_GLOBAL.USER_ID,
        X_CREATION_DATE => sysdate,
        X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID);

    --
    -- End of API body.
    --

    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get(
        p_count    =>   x_msg_count,
        p_data     =>   x_msg_data
      );
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('JTS', 'Error number ' || to_char(SQLCODE));
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(
        p_count    =>   x_msg_count,
        p_data     =>   x_msg_data
      );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Create_Resp_functions;

PROCEDURE Delete_Resp_Functions
(   p_api_version_number    IN    NUMBER,
    p_init_msg_list         IN    VARCHAR2      :=FND_API.G_FALSE,
    p_commit                IN    VARCHAR2       := FND_API.G_FALSE,
    p_app_id                IN      NUMBER,
    p_resp_id               IN    NUMBER,
    p_rule_type             IN      VARCHAR2,
    p_action_id             IN      NUMBER,
    x_return_status         OUT   VARCHAR2,
    x_msg_count             OUT   NUMBER,
    x_msg_data              OUT   VARCHAR2
)
IS
    l_api_name              CONSTANT VARCHAR2(30) := 'Delete_Resp_Functions';
    l_api_version_number    CONSTANT NUMBER   := 1.0;

    CURSOR c_found IS
    SELECT 'Y' FROM FND_RESP_FUNCTIONS
    WHERE application_id = p_app_id
          AND responsibility_id = p_resp_id
          AND action_id = p_action_id
          AND rule_type = p_rule_type;
    l_found         VARCHAR2(1) := 'N';

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT DELETE_RESP_FUNCTIONS_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version_number,
                                   p_api_version_number,
                                   l_api_name,
                                   G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --

    If (p_action_id is NULL or
        p_action_id = FND_API.G_MISS_NUM ) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_MISSING_DATA');
      FND_MESSAGE.Set_Token('COLUMN', 'Action_Id');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if;

    If (p_app_id is NULL or
        p_app_id = FND_API.G_MISS_NUM ) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_MISSING_DATA');
      FND_MESSAGE.Set_Token('COLUMN', 'Application_Id');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if;

    If (p_resp_id is NULL or
        p_resp_id = FND_API.G_MISS_NUM ) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_MISSING_DATA');
      FND_MESSAGE.Set_Token('COLUMN', 'Responsibility_Id');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if;

    If (p_rule_type is NULL or
        p_rule_type = FND_API.G_MISS_CHAR ) Then
      FND_MESSAGE.Set_Name('JTS', 'JTS_MISSING_DATA');
      FND_MESSAGE.Set_Token('COLUMN', 'Rule_Type');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if;

    OPEN C_Found;
    FETCH C_Found INTO l_found;
    CLOSE C_Found;
    IF (l_found <> 'Y') THEN
      FND_MESSAGE.Set_Name('JTS', 'JTS_NOTFOUND');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    END IF;

    FND_RESP_FUNCTIONS_PKG.DELETE_ROW(
        X_APPLICATION_ID => p_app_id,
        X_RESPONSIBILITY_ID => p_resp_id,
        X_RULE_TYPE => p_rule_type,
        X_ACTION_ID => p_action_id);

    --
    -- End of API body.
    --

    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get(
        p_count    =>   x_msg_count,
        p_data     =>   x_msg_data
      );
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('JTS', 'Error number ' || to_char(SQLCODE));
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(
        p_count    =>   x_msg_count,
        p_data     =>   x_msg_data
      );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Delete_Resp_functions;

END JTS_RESPONSIBILITY_PUB;

/
