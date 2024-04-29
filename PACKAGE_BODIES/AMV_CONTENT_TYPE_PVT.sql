--------------------------------------------------------
--  DDL for Package Body AMV_CONTENT_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_CONTENT_TYPE_PVT" AS
/*  $Header: amvvctpb.pls 120.1 2005/06/21 15:29:39 appldev ship $ */
--
-- NAME
--   AMV_CONTENT_TYPE_PVT
--
-- HISTORY
--   07/19/1999        PWU        CREATED
--
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'AMV_CONTENT_TYPE_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'amvvctpb.pls';
--
-- Debug mode
--g_debug boolean := FALSE;
g_debug boolean := TRUE;
--
TYPE    CursorType    IS REF CURSOR;
--
----------------------------- Private Cursors in this package ------------------
CURSOR Check_DupContTypeName_csr(p_name IN varchar2) IS
Select
    content_type_id
From   amv_i_content_types_tl
Where  content_type_name = p_name
And    language IN
    (
       Select L.language_code
       From  fnd_languages L
       Where L.installed_flag in ('I', 'B')
    )
;
--
CURSOR  Check_ValidContTypeName_csr(p_name varchar2) IS
Select
     content_type_id
From  amv_i_content_types_tl
Where content_type_name = p_name
And   language = userenv('lang');
--
--------------------------- Private Utility inside this package ----------------
--------------------------------------------------------------------------------
--
--
--------------------------------------------------------------------------------
PROCEDURE Add_ContentType
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,
    p_check_login_user     IN  VARCHAR2 := FND_API.G_TRUE,
    p_content_type_name    IN  VARCHAR2,
    p_cnt_type_description IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    x_content_type_id      OUT NOCOPY  NUMBER
)  IS
l_api_name             CONSTANT VARCHAR2(30) := 'Add_ContentType';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_rowid                VARCHAR2(500);
l_content_type_id      NUMBER;
l_description          VARCHAR2(2000);
l_current_date         date;
--
CURSOR Get_DateAndId_csr IS
select
      AMV_I_CONTENT_TYPES_B_S.nextval, sysdate
from dual;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Add_ContentType_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_resource_id => l_resource_id,
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    OPEN  Check_DupContTypeName_csr(p_content_type_name);
    FETCH Check_DupContTypeName_csr Into l_content_type_id;
    IF Check_DupContTypeName_csr%FOUND THEN
        -- The name is already used
        CLOSE Check_DupContTypeName_csr;
        IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_name('AMV','AMV_RECORD_NAME_DUPLICATED');
            FND_MESSAGE.Set_Token('RECORD', 'AMV_CONTENTTYPE_TK', TRUE);
            FND_MESSAGE.Set_Token('NAME', p_content_type_name);
            FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    CLOSE Check_DupContTypeName_csr;
    --
    OPEN  Get_DateAndId_csr;
    FETCH Get_DateAndId_csr Into l_content_type_id, l_current_date;
    CLOSE Get_DateAndId_csr;
    --
    IF (p_cnt_type_description = FND_API.G_MISS_CHAR) THEN
        l_description := NULL;
    ELSE
        l_description := p_cnt_type_description;
    END IF;
    --Do create the record now.
    AMV_I_CONTENT_TYPES_PKG.INSERT_ROW
       (
        X_ROWID => l_rowid,
        X_CONTENT_TYPE_ID => l_content_type_id,
        X_OBJECT_VERSION_NUMBER => 1,
        X_CONTENT_TYPE_NAME => p_content_type_name,
        X_DESCRIPTION => l_description,
        X_CREATION_DATE => l_current_date,
        X_CREATED_BY => l_current_user_id,
        X_LAST_UPDATE_DATE => l_current_date,
        X_LAST_UPDATED_BY => l_current_user_id,
        X_LAST_UPDATE_LOGIN => l_current_login_id
       );
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_ContentType_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_ContentType_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_ContentType_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
--
END Add_ContentType;
--------------------------------------------------------------------------------
PROCEDURE Delete_ContentType
(
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2,
    p_check_login_user   IN  VARCHAR2 := FND_API.G_TRUE,
    p_content_type_id    IN  NUMBER   := FND_API.G_MISS_NUM,
    p_content_type_name  IN  VARCHAR2 := FND_API.G_MISS_CHAR
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Delete_ContentType';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_content_type_id      NUMBER;
l_item_id              NUMBER;
--
CURSOR Get_Item_csr (p_ContentType_id IN NUMBER) IS
Select
    item_id
From jtf_amv_items_b
Where content_type_id = p_ContentType_id;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Delete_ContentType_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_resource_id => l_resource_id,
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    IF (p_content_type_id <> FND_API.G_MISS_NUM) THEN
       -- Check if user pass the valid content type id
       IF AMV_UTILITY_PVT.Is_ContentTypeIdValid(p_content_type_id) = TRUE THEN
           l_content_type_id := p_content_type_id;
       ELSE
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
              FND_MESSAGE.Set_Token('RECORD', 'AMV_CONTENTTYPE_TK', TRUE);
              FND_MESSAGE.Set_Token('ID', to_char(p_content_type_id));
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSIF (p_content_type_name <> FND_API.G_MISS_CHAR) THEN
       OPEN  Check_ValidContTypeName_csr(p_content_type_name);
       FETCH Check_ValidContTypeName_csr Into l_content_type_id;
       IF (Check_ValidContTypeName_csr%NOTFOUND) THEN
          CLOSE Check_ValidContTypeName_csr;
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_RECORD_NAME_MISSING');
              FND_MESSAGE.Set_Token('RECORD', 'AMV_CONTENTTYPE_TK', TRUE);
              FND_MESSAGE.Set_Token('NAME',  p_content_type_name);
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE Check_ValidContTypeName_csr;
    ELSE
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_NEED_RECORD_NAME_OR_ID');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_CONTENTTYPE_TK', TRUE);
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    -- Check if any item uses this content type. If so, error out.
    OPEN  Get_Item_csr (l_content_type_id);
    FETCH Get_Item_csr INTO l_item_id;
    IF (Get_Item_csr%FOUND) THEN
       CLOSE Get_Item_csr;
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_ITEM_USING_ATTR');
           FND_MESSAGE.Set_Token('RECORDID', TO_CHAR(l_item_id) );
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    ELSE
       CLOSE Get_Item_csr;
    END IF;
    -- Now do the deleting:
    Delete from amv_c_content_types
    where content_type_id = l_content_type_id;
    --
    AMV_I_CONTENT_TYPES_PKG.DELETE_ROW
    (
       X_CONTENT_TYPE_ID => l_content_type_id
    );
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Delete_ContentType_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Delete_ContentType_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Delete_ContentType_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
--
END Delete_ContentType;
--------------------------------------------------------------------------------
PROCEDURE Update_ContentType
(
    p_api_version            IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,
    p_check_login_user       IN  VARCHAR2 := FND_API.G_TRUE,
    p_content_type_id        IN  NUMBER   := FND_API.G_MISS_NUM,
    p_content_type_name      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_content_type_new_name  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_cnt_type_description   IN  VARCHAR2 := FND_API.G_MISS_CHAR
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Update_ContentType';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_content_type_id      NUMBER;
l_object_version       NUMBER;
--
CURSOR Get_Version_csr(p_ctype_id IN NUMBER) IS
Select
   object_version_number
from  Amv_i_content_types_b
where content_type_id = p_ctype_id;
--
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Update_ContentType_Pvt;
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_resource_id => l_resource_id,
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       AMV_USER_PVT.Is_Administrator
       (
           p_api_version         => 1.0,
           x_return_status       => x_return_status,
           x_msg_count           => x_msg_count,
           x_msg_data            => x_msg_data,
           p_check_login_user    => FND_API.G_FALSE,
           p_resource_id         => l_resource_id,
           x_result_flag         => l_admin_flag
       );
       IF (l_admin_flag <> FND_API.G_TRUE) THEN
          -- User is not an administrator.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_HAVE_PRIVILEGE');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    -- Ensure the name is not used yet.
    OPEN  Check_DupContTypeName_csr(p_content_type_new_name);
    FETCH Check_DupContTypeName_csr INTO l_content_type_id;
    IF Check_DupContTypeName_csr%FOUND THEN
        CLOSE Check_DupContTypeName_csr;
        IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_name('AMV','AMV_RECORD_NAME_DUPLICATED');
            FND_MESSAGE.Set_Token('RECORD', 'AMV_CONTENTTYPE_TK', TRUE);
            FND_MESSAGE.Set_Token('NAME', p_content_type_new_name);
            FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE Check_DupContTypeName_csr;
    --
    IF (p_content_type_id <> FND_API.G_MISS_NUM) THEN
       -- Check if user pass the valid content type id
       IF AMV_UTILITY_PVT.Is_ContentTypeIdValid(p_content_type_id) = TRUE THEN
           l_content_type_id := p_content_type_id;
       ELSE
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
              FND_MESSAGE.Set_Token('RECORD', 'AMV_CONTENTTYPE_TK', TRUE);
              FND_MESSAGE.Set_Token('ID', to_char(p_content_type_id));
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSIF (p_content_type_name <> FND_API.G_MISS_CHAR) THEN
       OPEN  Check_ValidContTypeName_csr(p_content_type_name);
       FETCH Check_ValidContTypeName_csr Into l_content_type_id;
       IF (Check_ValidContTypeName_csr%NOTFOUND) THEN
          CLOSE Check_ValidContTypeName_csr;
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_RECORD_NAME_MISSING');
              FND_MESSAGE.Set_Token('RECORD', 'AMV_CONTENTTYPE_TK', TRUE);
              FND_MESSAGE.Set_Token('NAME',  p_content_type_name);
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE Check_ValidContTypeName_csr;
    ELSE
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_NEED_RECORD_NAME_OR_ID');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_CONTENTTYPE_TK', TRUE);
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Get the current version number
    OPEN  Get_Version_csr(l_content_type_id);
    FETCH  Get_Version_csr INTO l_object_version;
    CLOSE  Get_Version_csr;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_name('AMV','Updating Content Type.');
        FND_MSG_PUB.Add;
    END IF;
    -- Now do the updating:
    AMV_I_CONTENT_TYPES_PKG.UPDATE_ROW
        (
           X_CONTENT_TYPE_ID =>l_content_type_id,
           X_OBJECT_VERSION_NUMBER => l_object_version + 1,
           X_CONTENT_TYPE_NAME => p_content_type_new_name,
           X_DESCRIPTION       => p_cnt_type_description,
           X_LAST_UPDATE_DATE  => sysdate,
           X_LAST_UPDATED_BY   => l_current_user_id,
           X_LAST_UPDATE_LOGIN => l_current_login_id
        );
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Update_ContentType_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Update_ContentType_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Update_ContentType_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
END Update_ContentType;
--
--------------------------------------------------------------------------------
PROCEDURE Get_ContentType
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_content_type_id     IN  NUMBER   := FND_API.G_MISS_NUM,
    p_content_type_name   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    x_content_type_obj    OUT NOCOPY  AMV_CONTENT_TYPE_OBJ_TYPE
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_ContentType';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_content_type_id       NUMBER;
--
CURSOR Get_CntTypeRecord_csr (p_ID IN NUMBER) IS
Select
    B.CONTENT_TYPE_ID,
    B.OBJECT_VERSION_NUMBER,
    T.CONTENT_TYPE_NAME,
    T.DESCRIPTION,
    T.LANGUAGE,
    T.SOURCE_LANG,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN
From   AMV_I_CONTENT_TYPES_TL T, AMV_I_CONTENT_TYPES_B B
Where  B.CONTENT_TYPE_ID = T.CONTENT_TYPE_ID
And    T.LANGUAGE = userenv('LANG')
And    B.CONTENT_TYPE_ID = p_ID;
--
l_content_type_rec  Get_CntTypeRecord_csr%ROWTYPE;
--
BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_resource_id => l_resource_id,
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    IF (p_content_type_id <> FND_API.G_MISS_NUM) THEN
       -- Check if user pass the valid content type id
       IF AMV_UTILITY_PVT.Is_ContentTypeIdValid(p_content_type_id) = TRUE THEN
           l_content_type_id := p_content_type_id;
       ELSE
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
              FND_MESSAGE.Set_Token('RECORD', 'AMV_CONTENTTYPE_TK', TRUE);
              FND_MESSAGE.Set_Token('ID', to_char(p_content_type_id));
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSIF (p_content_type_name <> FND_API.G_MISS_CHAR) THEN
       OPEN  Check_ValidContTypeName_csr(p_content_type_name);
       FETCH Check_ValidContTypeName_csr Into l_content_type_id;
       IF (Check_ValidContTypeName_csr%NOTFOUND) THEN
          CLOSE Check_ValidContTypeName_csr;
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_RECORD_NAME_MISSING');
              FND_MESSAGE.Set_Token('RECORD', 'AMV_CONTENTTYPE_TK', TRUE);
              FND_MESSAGE.Set_Token('NAME',  p_content_type_name);
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE Check_ValidContTypeName_csr;
    ELSE
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_NEED_RECORD_NAME_OR_ID');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_CONTENTTYPE_TK', TRUE);
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Now query and return the content type record
    OPEN  Get_CntTypeRecord_csr(l_content_type_id);
    FETCH Get_CntTypeRecord_csr INTO l_content_type_rec;
    IF (Get_CntTypeRecord_csr%NOTFOUND) THEN
        CLOSE Get_CntTypeRecord_csr;
        IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_name('AMV','AMV_RECORD_NOT_FOUND');
            FND_MESSAGE.Set_Token('RECORD', 'AMV_CONTENTTYPE_TK', TRUE);
            FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    ELSE
        x_content_type_obj.content_type_id := l_content_type_rec.content_type_id;
        x_content_type_obj.object_version_number := l_content_type_rec.object_version_number;
        x_content_type_obj.content_type_name := l_content_type_rec.content_type_name;
        x_content_type_obj.description := l_content_type_rec.description;
        x_content_type_obj.language := l_content_type_rec.language;
        x_content_type_obj.source_lang := l_content_type_rec.source_lang;
        x_content_type_obj.creation_date := l_content_type_rec.creation_date;
        x_content_type_obj.created_by := l_content_type_rec.created_by;
        x_content_type_obj.last_update_date := l_content_type_rec.last_update_date;
        x_content_type_obj.last_updated_by := l_content_type_rec.last_updated_by;
        x_content_type_obj.last_update_login := l_content_type_rec.last_update_login;

     /* x_content_type_obj := AMV_CONTENT_TYPE_OBJ_TYPE
           (
              l_content_type_rec.content_type_id,
              l_content_type_rec.object_version_number,
              l_content_type_rec.content_type_name,
              l_content_type_rec.description,
              l_content_type_rec.language,
              l_content_type_rec.source_lang,
              l_content_type_rec.creation_date,
              l_content_type_rec.created_by,
              l_content_type_rec.last_update_date,
              l_content_type_rec.last_updated_by,
              l_content_type_rec.last_update_login
           );
     */
    END IF;
    CLOSE Get_CntTypeRecord_csr;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
--
END Get_ContentType;
--
--------------------------------------------------------------------------------
PROCEDURE Find_ContentType
(
    p_api_version             IN  NUMBER,
    p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    p_check_login_user        IN  VARCHAR2 := FND_API.G_TRUE,
    p_content_type_name       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_cnt_type_description    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_subset_request_obj      IN  AMV_REQUEST_OBJ_TYPE,
    x_subset_return_obj       OUT NOCOPY  AMV_RETURN_OBJ_TYPE,
    x_content_type_obj_varray OUT NOCOPY  AMV_CONTENT_TYPE_OBJ_VARRAY
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Find_ContentType';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_cursor             CursorType;
l_sql_statement      VARCHAR2(2000);
l_sql_statement2     VARCHAR2(2000);
l_where_clause       VARCHAR2(2000);
l_total_count        NUMBER := 1;
l_fetch_count        NUMBER := 0;
l_start_with         NUMBER;
l_total_record_count NUMBER;
--
l_content_type_id    NUMBER;
l_object_version_number  NUMBER;
l_content_type_name  VARCHAR2(80);
l_description        VARCHAR2(2000);
l_language           VARCHAR2(4);
l_source_lang        VARCHAR2(4);
l_creation_date      DATE;
l_created_by         NUMBER;
l_last_update_date   DATE;
l_last_updated_by    NUMBER;
l_last_update_login  NUMBER;
--
BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
         l_api_version,
         p_api_version,
         l_api_name,
         G_PKG_NAME) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get the current (login) user id.
    AMV_UTILITY_PVT.Get_UserInfo(
       x_resource_id => l_resource_id,
       x_user_id     => l_current_user_id,
       x_login_id    => l_current_login_id,
       x_user_status => l_current_user_status
       );
    IF (p_check_login_user = FND_API.G_TRUE) THEN
       -- Check if user is login and has the required privilege.
       IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
          -- User is not login.
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- This is to make database happy
    IF (l_current_login_id = FND_API.G_MISS_NUM) THEN
        l_current_login_id := -1;
        l_current_user_id  := -1;
    END IF;
    -- Now create SQL statement and find the results:
    l_sql_statement :=
       'Select ' ||
           'B.CONTENT_TYPE_ID, ' ||
           'B.OBJECT_VERSION_NUMBER, ' ||
           'T.CONTENT_TYPE_NAME, ' ||
           'T.DESCRIPTION, ' ||
           'T.LANGUAGE, ' ||
           'T.SOURCE_LANG, ' ||
           'B.CREATION_DATE, ' ||
           'B.CREATED_BY, ' ||
           'B.LAST_UPDATE_DATE, ' ||
           'B.LAST_UPDATED_BY, ' ||
           'B.LAST_UPDATE_LOGIN ' ||
       'From   AMV_I_CONTENT_TYPES_TL T, AMV_I_CONTENT_TYPES_B B ';
    l_sql_statement2 :=
       'Select count(*) ' ||
       'From   AMV_I_CONTENT_TYPES_TL T, AMV_I_CONTENT_TYPES_B B ';
    --
    l_where_clause :=
       'Where  B.CONTENT_TYPE_ID = T.CONTENT_TYPE_ID ' ||
       'And    T.LANGUAGE = userenv(''LANG'') ';
    IF (p_content_type_name IS NOT NULL AND
        p_content_type_name <> FND_API.G_MISS_CHAR) THEN
        l_where_clause := l_where_clause ||
             'And T.CONTENT_TYPE_NAME Like ''' || p_content_type_name || ''' ';
    END IF;
    IF (p_cnt_type_description IS NOT NULL AND
        p_cnt_type_description <> FND_API.G_MISS_CHAR) THEN
        l_where_clause := l_where_clause ||
             'And T.DESCRIPTION Like ''' || p_cnt_type_description || ''' ';
    END IF;
    l_sql_statement := l_sql_statement ||
         l_where_clause || 'ORDER BY T.CONTENT_TYPE_NAME ';
    l_sql_statement2 := l_sql_statement2 || l_where_clause;
    --
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.Set_name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_sql_statement);
       FND_MSG_PUB.Add;
       --
       FND_MESSAGE.Set_name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_sql_statement2);
       FND_MSG_PUB.Add;
    END IF;

    --Execute the SQL statements to get the total count:
    IF (p_subset_request_obj.return_total_count_flag = FND_API.G_TRUE) THEN
        OPEN  l_cursor FOR l_sql_statement2;
        FETCH l_cursor INTO l_total_record_count;
        CLOSE l_cursor;
    END IF;
    --dbms_output.put_line('Total=' || l_total_record_count);
    --Execute the SQL statements to get records
    l_start_with := p_subset_request_obj.start_record_position;
    x_content_type_obj_varray := AMV_CONTENT_TYPE_OBJ_VARRAY();
    OPEN l_cursor FOR l_sql_statement;
    LOOP
      FETCH l_cursor INTO
         l_content_type_id,
         l_object_version_number,
         l_content_type_name,
         l_description,
         l_language,
         l_source_lang,
         l_creation_date,
         l_created_by,
         l_last_update_date,
         l_last_updated_by,
         l_last_update_login;
      EXIT WHEN l_cursor%NOTFOUND;
      IF (l_start_with <= l_total_count AND
          l_fetch_count < p_subset_request_obj.records_requested) THEN
         l_fetch_count := l_fetch_count + 1;
         x_content_type_obj_varray.extend;
         x_content_type_obj_varray(l_fetch_count).content_type_id := l_content_type_id;
         x_content_type_obj_varray(l_fetch_count).object_version_number := l_object_version_number;
         x_content_type_obj_varray(l_fetch_count).content_type_name := l_content_type_name;
         x_content_type_obj_varray(l_fetch_count).description := l_description;
         x_content_type_obj_varray(l_fetch_count).language := l_language;
         x_content_type_obj_varray(l_fetch_count).source_lang := l_source_lang;
         x_content_type_obj_varray(l_fetch_count).creation_date := l_creation_date;
         x_content_type_obj_varray(l_fetch_count).created_by := l_created_by;
         x_content_type_obj_varray(l_fetch_count).last_update_date := l_last_update_date;
         x_content_type_obj_varray(l_fetch_count).last_updated_by := l_last_updated_by;
         x_content_type_obj_varray(l_fetch_count).last_update_login := l_last_update_login;

/*
         x_content_type_obj_varray(l_fetch_count) := amv_content_type_obj_type
           (
              l_content_type_id,
              l_object_version_number,
              l_content_type_name,
              l_description,
              l_language,
              l_source_lang,
              l_creation_date,
              l_created_by,
              l_last_update_date,
              l_last_updated_by,
              l_last_update_login
           );
*/
      END IF;
      IF (l_fetch_count >= p_subset_request_obj.records_requested) THEN
         exit;
      END IF;
      l_total_count := l_total_count + 1;
    END LOOP;
    CLOSE l_cursor;
    x_subset_return_obj.returned_record_count := l_fetch_count;
    x_subset_return_obj.next_record_position := p_subset_request_obj.start_record_position + l_fetch_count;
    x_subset_return_obj.total_record_count := l_total_record_count;

 /*:= AMV_RETURN_OBJ_TYPE
       (
          l_fetch_count,
          p_subset_request_obj.start_record_position + l_fetch_count,
          l_total_record_count
       );
 */

    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
--
END Find_ContentType;
--
--
--------------------------------------------------------------------------------
END amv_content_type_pvt;

/
