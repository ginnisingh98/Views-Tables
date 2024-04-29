--------------------------------------------------------
--  DDL for Package Body AMV_PERSPECTIVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_PERSPECTIVE_PVT" AS
/*  $Header: amvvpspb.pls 120.1 2005/06/21 16:51:18 appldev ship $ */
--
-- NAME
--   AMV_PERSPECTIVE_PVT
--
-- HISTORY
--   07/19/1999        PWU        CREATED
--
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'AMV_PERSPECTIVE_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'amvvpspb.pls';
--
-- Debug mode
g_debug boolean := TRUE;
TYPE    CursorType    IS REF CURSOR;
--
----------------------------- Private Cursors in this package ------------------
CURSOR Check_DupPerspectName_csr(p_name IN varchar2) IS
Select
    perspective_id
From   amv_i_perspectives_tl
Where  perspective_name = p_name
And    language IN
    (
       Select L.language_code
       From  fnd_languages L
       Where L.installed_flag in ('I', 'B')
    )
;
--
CURSOR  Check_ValidPerspectName_csr(p_name varchar2) IS
Select
     perspective_id
From   amv_i_perspectives_tl
Where perspective_name = p_name
And   language = userenv('lang');
--
--------------------------- Private Utility inside this package ----------------
--------------------------------------------------------------------------------
--
--
--------------------------------------------------------------------------------
PROCEDURE Add_Perspective
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_perspective_name  IN  VARCHAR2,
    p_persp_description IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    x_perspective_id    OUT NOCOPY  NUMBER
)  IS
l_api_name             CONSTANT VARCHAR2(30) := 'Add_Perspective';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_rowid                VARCHAR2(500);
l_perspective_id       NUMBER;
l_persp_description    VARCHAR2(2000);
l_current_date         date;
--
CURSOR Get_DateAndId_csr IS
select
      AMV_I_PERSPECTIVES_B_S.nextval, sysdate
from dual;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Add_Perspective_Pvt;
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
    --
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
    --
    OPEN  Check_DupPerspectName_csr(p_perspective_name);
    FETCH Check_DupPerspectName_csr Into l_perspective_id;
    IF Check_DupPerspectName_csr%FOUND THEN
        -- The name is already used
        CLOSE Check_DupPerspectName_csr;
        IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_name('AMV','AMV_RECORD_NAME_DUPLICATED');
            FND_MESSAGE.Set_Token('RECORD', 'AMV_PERSPECTIVE_TK', TRUE);
            FND_MESSAGE.Set_Token('NAME', p_perspective_name);
            FND_MSG_PUB.Add;
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    CLOSE Check_DupPerspectName_csr;
    --
    OPEN  Get_DateAndId_csr;
    FETCH Get_DateAndId_csr Into l_perspective_id, l_current_date;
    CLOSE Get_DateAndId_csr;
    --
    IF (p_persp_description = FND_API.G_MISS_CHAR) THEN
        l_persp_description := NULL;
    ELSE
        l_persp_description := p_persp_description;
    END IF;
    --Do create the record now.
    AMV_I_PERSPECTIVES_PKG.INSERT_ROW
       (
        X_ROWID => l_rowid,
        X_PERSPECTIVE_ID => l_perspective_id,
        X_OBJECT_VERSION_NUMBER => 1,
        X_PERSPECTIVE_NAME => p_perspective_name,
        X_DESCRIPTION => l_persp_description,
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
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_name('AMV','PVT Add Persp. API: End');
        FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_Perspective_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_Perspective_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_Perspective_Pvt;
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
END Add_Perspective;
--------------------------------------------------------------------------------
PROCEDURE Delete_Perspective
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_perspective_id    IN  NUMBER   := FND_API.G_MISS_NUM,
    p_perspective_name  IN  VARCHAR2 := FND_API.G_MISS_CHAR
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Delete_Perspective';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_perspective_id       NUMBER;
--
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Delete_Perspective_Pvt;
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
    --
    IF (p_perspective_id <> FND_API.G_MISS_NUM) THEN
       -- Check if user pass the valid perspective id
       IF AMV_UTILITY_PVT.Is_PerspectiveIdValid(p_perspective_id) = TRUE THEN
           l_perspective_id := p_perspective_id;
       ELSE
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
              FND_MESSAGE.Set_Token('RECORD', 'AMV_PERSPECTIVE_TK', TRUE);
              FND_MESSAGE.Set_Token('ID',  to_char(p_perspective_id));
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSIF (p_perspective_name <> FND_API.G_MISS_CHAR) THEN
       OPEN  Check_ValidPerspectName_csr(p_perspective_name);
       FETCH Check_ValidPerspectName_csr Into l_perspective_id;
       IF (Check_ValidPerspectName_csr%NOTFOUND) THEN
          CLOSE Check_ValidPerspectName_csr;
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_RECORD_NAME_MISSING');
              FND_MESSAGE.Set_Token('RECORD', 'AMV_PERSPECTIVE_TK', TRUE);
              FND_MESSAGE.Set_Token('NAME',  p_perspective_name);
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE Check_ValidPerspectName_csr;
    ELSE
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_NEED_RECORD_NAME_OR_ID');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_PERSPECTIVE_TK', TRUE);
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Now do the deleting:
    Delete from amv_c_chl_perspectives
    where perspective_id = l_perspective_id;
    --
    Delete from amv_i_item_perspectives
    where perspective_id = l_perspective_id;
    --
    AMV_I_PERSPECTIVES_PKG.DELETE_ROW
    (
       X_PERSPECTIVE_ID => l_perspective_id
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
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Delete_Perspective_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Delete_Perspective_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Delete_Perspective_Pvt;
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
END Delete_Perspective;
--------------------------------------------------------------------------------
PROCEDURE Update_Perspective
(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,
    p_check_login_user      IN  VARCHAR2 := FND_API.G_TRUE,
    p_perspective_id        IN  NUMBER   := FND_API.G_MISS_NUM,
    p_perspective_name      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_perspective_new_name  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_persp_description     IN  VARCHAR2 := FND_API.G_MISS_CHAR
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Update_Perspective';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_perspective_id       NUMBER;
l_object_version       NUMBER;
--
CURSOR Get_Version_csr(p_persp_id IN NUMBER) IS
Select
   object_version_number
from  Amv_i_perspectives_b
where perspective_id = p_persp_id;
--
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Update_Perspective_Pvt;
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
    OPEN  Check_DupPerspectName_csr(p_perspective_new_name);
    FETCH Check_DupPerspectName_csr INTO l_perspective_id;
    IF Check_DupPerspectName_csr%FOUND THEN
        CLOSE Check_DupPerspectName_csr;
        IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_name('AMV','AMV_RECORD_NAME_DUPLICATED');
            FND_MESSAGE.Set_Token('RECORD', 'AMV_PERSPECTIVE_TK', TRUE);
            FND_MESSAGE.Set_Token('NAME', p_perspective_new_name);
            FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE Check_DupPerspectName_csr;
    --
    IF (p_perspective_id <> FND_API.G_MISS_NUM) THEN
       -- Check if user pass the valid perspective id
       IF AMV_UTILITY_PVT.Is_PerspectiveIdValid(p_perspective_id) = TRUE THEN
          l_perspective_id := p_perspective_id;
       ELSE
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
              FND_MESSAGE.Set_Token('RECORD', 'AMV_PERSPECTIVE_TK', TRUE);
              FND_MESSAGE.Set_Token('ID',  to_char(p_perspective_id));
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSIF (p_perspective_name <> FND_API.G_MISS_CHAR) THEN
       OPEN  Check_ValidPerspectName_csr(p_perspective_name);
       FETCH Check_ValidPerspectName_csr Into l_perspective_id;
       IF (Check_ValidPerspectName_csr%NOTFOUND) THEN
          CLOSE Check_ValidPerspectName_csr;
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_name('AMV','AMV_RECORD_NAME_MISSING');
             FND_MESSAGE.Set_Token('RECORD', 'AMV_PERSPECTIVE_TK', TRUE);
             FND_MESSAGE.Set_Token('NAME',  p_perspective_name);
             FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE Check_ValidPerspectName_csr;
    ELSE
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_NEED_RECORD_NAME_OR_ID');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_PERSPECTIVE_TK', TRUE);
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Get the current version number
    OPEN  Get_Version_csr(l_perspective_id);
    FETCH  Get_Version_csr INTO l_object_version;
    CLOSE  Get_Version_csr;
    -- Now do the updating:
    AMV_I_PERSPECTIVES_PKG.UPDATE_ROW
        (
           X_PERSPECTIVE_ID    => l_perspective_id,
           X_OBJECT_VERSION_NUMBER => l_object_version + 1,
           X_PERSPECTIVE_NAME  => p_perspective_new_name,
           X_DESCRIPTION       => p_persp_description,
           X_LAST_UPDATE_DATE  => sysdate,
           X_LAST_UPDATED_BY   => l_current_user_id,
           X_LAST_UPDATE_LOGIN => l_current_login_id
        );
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_name('AMV','PVT Update Persp. API: End');
        FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );
--
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Update_Perspective_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Update_Perspective_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Update_Perspective_Pvt;
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
END Update_Perspective;
--
--------------------------------------------------------------------------------
PROCEDURE Get_Perspective
(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,
    p_check_login_user      IN  VARCHAR2 := FND_API.G_TRUE,
    p_perspective_id        IN  NUMBER   := FND_API.G_MISS_NUM,
    p_perspective_name      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    x_perspective_obj       OUT NOCOPY  AMV_PERSPECTIVE_OBJ_TYPE
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_Perspective';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_perspective_id       NUMBER;
--
CURSOR Get_PerspRecord_csr (p_ID IN NUMBER) IS
Select
    B.PERSPECTIVE_ID,
    B.OBJECT_VERSION_NUMBER,
    T.PERSPECTIVE_NAME,
    T.DESCRIPTION,
    T.LANGUAGE,
    T.SOURCE_LANG,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN
From   AMV_I_PERSPECTIVES_TL T, AMV_I_PERSPECTIVES_B B
Where  B.PERSPECTIVE_ID = T.PERSPECTIVE_ID
And    T.LANGUAGE = userenv('LANG')
And    B.PERSPECTIVE_ID = p_ID;
--
l_perspective_rec  Get_PerspRecord_csr%ROWTYPE;
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
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_name('AMV','PVT Get Persp. API: Start');
        FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --
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
    IF (p_perspective_id <> FND_API.G_MISS_NUM) THEN
       -- Check if user pass the valid perspective id
       IF AMV_UTILITY_PVT.Is_PerspectiveIdValid(p_perspective_id) = TRUE THEN
           l_perspective_id := p_perspective_id;
       ELSE
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
              FND_MESSAGE.Set_Token('RECORD', 'AMV_PERSPECTIVE_TK', TRUE);
              FND_MESSAGE.Set_Token('ID',  to_char(p_perspective_id));
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSIF (p_perspective_name <> FND_API.G_MISS_CHAR) THEN
       OPEN  Check_ValidPerspectName_csr(p_perspective_name);
       FETCH Check_ValidPerspectName_csr Into l_perspective_id;
       IF (Check_ValidPerspectName_csr%NOTFOUND) THEN
          CLOSE Check_ValidPerspectName_csr;
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('AMV','AMV_RECORD_NAME_MISSING');
              FND_MESSAGE.Set_Token('RECORD', 'AMV_PERSPECTIVE_TK', TRUE);
              FND_MESSAGE.Set_Token('NAME',  p_perspective_name);
              FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE Check_ValidPerspectName_csr;
    ELSE
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_NEED_RECORD_NAME_OR_ID');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_PERSPECTIVE_TK', TRUE);
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Now query and return the perspective record
    OPEN  Get_PerspRecord_csr(l_perspective_id);
    FETCH Get_PerspRecord_csr INTO l_perspective_rec;
    IF (Get_PerspRecord_csr%NOTFOUND) THEN
        CLOSE Get_PerspRecord_csr;
        IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_name('AMV','AMV_RECORD_NOT_FOUND');
            FND_MESSAGE.Set_Token('RECORD', 'AMV_PERSPECTIVE_TK', TRUE);
            FND_MSG_PUB.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    ELSE
        x_perspective_obj.perspective_id := l_perspective_rec.perspective_id;
        x_perspective_obj.object_version_number := l_perspective_rec.object_version_number;
        x_perspective_obj.perspective_name := l_perspective_rec.perspective_name;
        x_perspective_obj.description := l_perspective_rec.description;
        x_perspective_obj.language := l_perspective_rec.language;
        x_perspective_obj.source_lang := l_perspective_rec.source_lang;
        x_perspective_obj.creation_date := l_perspective_rec.creation_date;
        x_perspective_obj.created_by := l_perspective_rec.created_by;
        x_perspective_obj.last_update_date := l_perspective_rec.last_update_date;
        x_perspective_obj.last_updated_by := l_perspective_rec.last_updated_by;
        x_perspective_obj.last_update_login := l_perspective_rec.last_update_login;
/*
        x_perspective_obj := AMV_PERSPECTIVE_OBJ_TYPE
           (
              l_perspective_rec.perspective_id,
              l_perspective_rec.object_version_number,
              l_perspective_rec.perspective_name,
              l_perspective_rec.description,
              l_perspective_rec.language,
              l_perspective_rec.source_lang,
              l_perspective_rec.creation_date,
              l_perspective_rec.created_by,
              l_perspective_rec.last_update_date,
              l_perspective_rec.last_updated_by,
              l_perspective_rec.last_update_login
           );
*/
    END IF;
    CLOSE Get_PerspRecord_csr;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
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
END Get_Perspective;
--------------------------------------------------------------------------------
PROCEDURE Find_Perspective
(
    p_api_version             IN  NUMBER,
    p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    p_check_login_user        IN  VARCHAR2 := FND_API.G_TRUE,
    p_perspective_name        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_persp_description       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_subset_request_obj      IN  AMV_REQUEST_OBJ_TYPE,
    x_subset_return_obj       OUT NOCOPY  AMV_RETURN_OBJ_TYPE,
    x_perspective_obj_varray  OUT NOCOPY  AMV_PERSPECTIVE_OBJ_VARRAY
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Find_Perspective';
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
l_perspective_id     NUMBER;
l_object_version_number  NUMBER;
l_perspective_name   VARCHAR2(80);
l_persp_description  VARCHAR2(2000);
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
           'B.PERSPECTIVE_ID, ' ||
           'B.OBJECT_VERSION_NUMBER, ' ||
           'T.PERSPECTIVE_NAME, ' ||
           'T.DESCRIPTION, ' ||
           'T.LANGUAGE, ' ||
           'T.SOURCE_LANG, ' ||
           'B.CREATION_DATE, ' ||
           'B.CREATED_BY, ' ||
           'B.LAST_UPDATE_DATE, ' ||
           'B.LAST_UPDATED_BY, ' ||
           'B.LAST_UPDATE_LOGIN ' ||
       'From   AMV_I_PERSPECTIVES_TL T, AMV_I_PERSPECTIVES_B B ';
    l_sql_statement2 :=
       'Select count(*) ' ||
       'From   AMV_I_PERSPECTIVES_TL T, AMV_I_PERSPECTIVES_B B ';
    --
    l_where_clause :=
       'Where  B.PERSPECTIVE_ID = T.PERSPECTIVE_ID ' ||
       'And    T.LANGUAGE = userenv(''LANG'') ';
    IF (p_perspective_name IS NOT NULL AND
        p_perspective_name <> FND_API.G_MISS_CHAR) THEN
        l_where_clause := l_where_clause ||
             'And T.PERSPECTIVE_NAME Like ''' || p_perspective_name || ''' ';
    END IF;
    IF (p_persp_description IS NOT NULL AND
        p_persp_description <> FND_API.G_MISS_CHAR) THEN
        l_where_clause := l_where_clause ||
             'And T.DESCRIPTION Like ''' || p_persp_description || ''' ';
    END IF;
    l_sql_statement := l_sql_statement ||
         l_where_clause || 'ORDER BY T.PERSPECTIVE_NAME ';
    l_sql_statement2 := l_sql_statement2 ||
         l_where_clause;
    --
    --dbms_output.put_line('sql stmt = '|| substr(l_sql_statement, 1, 80));
    --dbms_output.put_line(substr(l_sql_statement, 81, 80));
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
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
    --Execute the SQL statements to get records
    l_start_with := p_subset_request_obj.start_record_position;
    x_perspective_obj_varray := AMV_PERSPECTIVE_OBJ_VARRAY();
    OPEN l_cursor FOR l_sql_statement;
    LOOP
      FETCH l_cursor INTO
         l_perspective_id,
         l_object_version_number,
         l_perspective_name,
         l_persp_description,
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
         x_perspective_obj_varray.extend;
         x_perspective_obj_varray(l_fetch_count).perspective_id := l_perspective_id;
         x_perspective_obj_varray(l_fetch_count).object_version_number := l_object_version_number;
         x_perspective_obj_varray(l_fetch_count).perspective_name := l_perspective_name;
         x_perspective_obj_varray(l_fetch_count).description := l_persp_description;
         x_perspective_obj_varray(l_fetch_count).language := l_language;
         x_perspective_obj_varray(l_fetch_count).source_lang := l_source_lang;
         x_perspective_obj_varray(l_fetch_count).creation_date := l_creation_date;
         x_perspective_obj_varray(l_fetch_count).created_by := l_created_by;
         x_perspective_obj_varray(l_fetch_count).last_update_date := l_last_update_date;
         x_perspective_obj_varray(l_fetch_count).last_updated_by := l_last_updated_by;
         x_perspective_obj_varray(l_fetch_count).last_update_login := l_last_update_login;
/*
         x_perspective_obj_varray(l_fetch_count) := amv_perspective_obj_type
           (
              l_perspective_id,
              l_object_version_number,
              l_perspective_name,
              l_persp_description,
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

/*
    x_subset_return_obj := AMV_RETURN_OBJ_TYPE
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
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
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
END Find_Perspective;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE Add_ItemPersps
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_perspective_array IN  AMV_NUMBER_VARRAY_TYPE
)  IS
l_api_name             CONSTANT VARCHAR2(30) := 'Add_ItemPersps';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_perspective_id       NUMBER;
l_count                NUMBER;
l_temp_number          NUMBER;
l_date                 DATE;
--
CURSOR Check_ItemPerspectives_csr (p_perspectiv_id IN NUMBER) is
Select
     perspective_id
From amv_i_item_perspectives
Where item_id = p_item_id
And   perspective_id = p_perspectiv_id;
--
CURSOR Get_IDandDate_csr is
Select amv_i_item_perspectives_s.nextval, sysdate
From  Dual;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Add_ItemPersps_Pvt;
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
    --
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
    -- Check if item id is valid.
    IF (AMV_UTILITY_PVT.Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_ITEM_TK', TRUE);
           FND_MESSAGE.Set_Token('ID',  to_char(p_item_id));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_count := p_perspective_array.count;
    FOR i IN 1..l_count LOOP
        l_perspective_id := p_perspective_array(i);
        OPEN  Check_ItemPerspectives_csr(l_perspective_id);
        FETCH Check_ItemPerspectives_csr INTO l_temp_number;
        IF (Check_ItemPerspectives_csr%FOUND) THEN
           CLOSE Check_ItemPerspectives_csr;
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('AMV','AMV_ENTITY_HAS_ATTR');
               FND_MESSAGE.Set_Token('ENTITY', 'AMV_ITEM_TK', TRUE);
               FND_MESSAGE.Set_Token('ENTID',  to_char(p_item_id));
               FND_MESSAGE.Set_Token('ATTRIBUTE', 'AMV_PERSPECTIVE_TK', TRUE);
               FND_MESSAGE.Set_Token('ATTRID',  to_char(l_perspective_id));
               FND_MSG_PUB.Add;
           END IF;
        ELSE
           CLOSE Check_ItemPerspectives_csr;
            IF AMV_UTILITY_PVT.Is_PerspectiveIdValid(l_perspective_id) THEN
               OPEN  Get_IDandDate_csr;
               FETCH Get_IDandDate_csr Into l_temp_number, l_date;
               CLOSE Get_IDandDate_csr;
               Insert Into amv_i_item_perspectives
                 (
                    ITEM_PERSPECTIVE_ID,
                    OBJECT_VERSION_NUMBER,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    ITEM_ID,
                    PERSPECTIVE_ID
                 ) VALUES
                 (
                    l_temp_number,
                    1,
                    l_date,
                    l_current_user_id,
                    l_date,
                    l_current_user_id,
                    l_current_login_id,
                    p_item_id,
                    l_perspective_id
                 );
            ELSE
               x_return_status := FND_API.G_RET_STS_ERROR;
               IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
                   FND_MESSAGE.Set_Token('RECORD', 'AMV_PERSPECTIVE_TK', TRUE);
                   FND_MESSAGE.Set_Token('ID',
                         to_char( nvl(l_perspective_id, -1) ) );
                   FND_MSG_PUB.Add;
               END IF;
            END IF;
        END IF;
    END LOOP;
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
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_ItemPersps_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_ItemPersps_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_ItemPersps_Pvt;
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
END Add_ItemPersps;
--------------------------------------------------------------------------------
PROCEDURE Add_ItemPersps
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_perspective_id    IN  NUMBER
)  IS
l_api_name             CONSTANT VARCHAR2(30) := 'Add_ItemPersps';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_item_persp           NUMBER;
l_date                 DATE;
--
CURSOR Check_ItemPerspectives_csr is
Select
     perspective_id
From amv_i_item_perspectives
Where item_id = p_item_id
And   perspective_id = p_perspective_id;
--
CURSOR Get_IDandDate_csr is
Select amv_i_item_perspectives_s.nextval, sysdate
From  Dual;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Add_ItemPersps_Pvt;
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
    -- Check if item id is valid.
    IF (AMV_UTILITY_PVT.Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_ITEM_TK', TRUE);
           FND_MESSAGE.Set_Token('ID',  to_char(p_item_id));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (AMV_UTILITY_PVT.Is_PerspectiveIdValid(p_perspective_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_PERSPECTIVE_TK', TRUE);
           FND_MESSAGE.Set_Token('ID',  to_char(p_perspective_id));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    OPEN  Check_ItemPerspectives_csr;
    FETCH Check_ItemPerspectives_csr INTO l_item_persp;
    IF (Check_ItemPerspectives_csr%FOUND) THEN
       CLOSE Check_ItemPerspectives_csr;
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_ENTITY_HAS_ATTR');
           FND_MESSAGE.Set_Token('ENTITY', 'AMV_ITEM_TK', TRUE);
           FND_MESSAGE.Set_Token('ENTID',  to_char(p_item_id));
           FND_MESSAGE.Set_Token('ATTRIBUTE', 'AMV_PERSPECTIVE_TK', TRUE);
           FND_MESSAGE.Set_Token('ATTRID',  to_char(p_perspective_id));
           FND_MSG_PUB.Add;
       END IF;
    ELSE
       CLOSE Check_ItemPerspectives_csr;
       OPEN  Get_IDandDate_csr;
       FETCH Get_IDandDate_csr Into l_item_persp, l_date;
       CLOSE Get_IDandDate_csr;
       Insert Into amv_i_item_perspectives
         (
            ITEM_PERSPECTIVE_ID,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            ITEM_ID,
            PERSPECTIVE_ID
         ) VALUES
         (
            l_item_persp,
            l_date,
            l_current_user_id,
            l_date,
            l_current_user_id,
            l_current_login_id,
            p_item_id,
            p_perspective_id
         );
    END IF;
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
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_ItemPersps_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_ItemPersps_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_ItemPersps_Pvt;
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
END Add_ItemPersps;
--------------------------------------------------------------------------------
PROCEDURE Delete_ItemPersps
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_perspective_array IN  AMV_NUMBER_VARRAY_TYPE
)  IS
l_api_name             CONSTANT VARCHAR2(30) := 'Delete_ItemPersps';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_perspective_id       NUMBER;
l_count                NUMBER;
l_temp_number          NUMBER;
l_date                 DATE;
--
--
CURSOR Check_ItemPerspectives_csr (p_perspectiv_id IN NUMBER) is
Select
     perspective_id
From amv_i_item_perspectives
Where item_id = p_item_id
And   perspective_id = p_perspectiv_id;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Delete_ItemPersps_Pvt;
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
    -- Check if item id is valid.
    IF (AMV_UTILITY_PVT.Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_ITEM_TK', TRUE);
           FND_MESSAGE.Set_Token('ID',  to_char(p_item_id));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_count := p_perspective_array.count;
    FOR i IN 1..l_count LOOP
        l_perspective_id := p_perspective_array(i);
        OPEN  Check_ItemPerspectives_csr(l_perspective_id);
        FETCH Check_ItemPerspectives_csr INTO l_temp_number;
        IF (Check_ItemPerspectives_csr%NOTFOUND) THEN
           CLOSE Check_ItemPerspectives_csr;
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('AMV','AMV_ENTITY_HAS_NOT_ATTR');
               FND_MESSAGE.Set_Token('ENTITY', 'AMV_ITEM_TK', TRUE);
               FND_MESSAGE.Set_Token('ENTID',  to_char(p_item_id));
               FND_MESSAGE.Set_Token('ATTRIBUTE', 'AMV_PERSPECTIVE_TK', TRUE);
               FND_MESSAGE.Set_Token('ATTRID',  to_char(l_perspective_id));
               FND_MSG_PUB.Add;
           END IF;
        ELSE
           CLOSE Check_ItemPerspectives_csr;
           Delete from amv_i_item_perspectives
           Where  item_id = p_item_id
           And    perspective_id = l_perspective_id;
        END IF;
    END LOOP;
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
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Delete_ItemPersps_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Delete_ItemPersps_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Delete_ItemPersps_Pvt;
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
end Delete_ItemPersps;
--
--------------------------------------------------------------------------------
PROCEDURE Delete_ItemPersps
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_perspective_id    IN  NUMBER   := FND_API.G_MISS_NUM
)  IS
l_api_name             CONSTANT VARCHAR2(30) := 'Delete_ItemPersps';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_temp_number          NUMBER;
--
CURSOR Check_ItemPerspectives_csr IS
Select
     perspective_id
From amv_i_item_perspectives
Where item_id = p_item_id
And   perspective_id = p_perspective_id;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Delete_ItemPersps_Pvt;
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
    -- Check if item id is valid.
    IF (AMV_UTILITY_PVT.Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_ITEM_TK', TRUE);
           FND_MESSAGE.Set_Token('ID',  to_char(p_item_id));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_perspective_id <> FND_API.G_MISS_NUM) THEN
        OPEN  Check_ItemPerspectives_csr;
        FETCH Check_ItemPerspectives_csr INTO l_temp_number;
        IF (Check_ItemPerspectives_csr%NOTFOUND) THEN
           CLOSE Check_ItemPerspectives_csr;
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('AMV','AMV_ENTITY_HAS_NOT_ATTR');
               FND_MESSAGE.Set_Token('ENTITY', 'AMV_ITEM_TK', TRUE);
               FND_MESSAGE.Set_Token('ENTID',  to_char(p_item_id));
               FND_MESSAGE.Set_Token('ATTRIBUTE', 'AMV_PERSPECTIVE_TK', TRUE);
               FND_MESSAGE.Set_Token('ATTRID',  to_char(p_perspective_id));
               FND_MSG_PUB.Add;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
        ELSE
           CLOSE Check_ItemPerspectives_csr;
           Delete from amv_i_item_perspectives
           Where  item_id = p_item_id
           And    perspective_id = p_perspective_id;
        END IF;
    ELSE
        -- p_perspective_id is not specified,
        -- caller wants to delete all the perspectives of the item.
        Delete from amv_i_item_perspectives
        Where  item_id = p_item_id;
    END IF;
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
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Delete_ItemPersps_Pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Delete_ItemPersps_Pvt;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Delete_ItemPersps_Pvt;
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
end Delete_ItemPersps;
--
--------------------------------------------------------------------------------
PROCEDURE Update_ItemPersps
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_perspective_array IN  AMV_NUMBER_VARRAY_TYPE
) is
begin
   Delete_ItemPersps
   (
      p_api_version       => p_api_version,
      p_init_msg_list     => p_init_msg_list,
  --  p_commit            => p_commit,
      p_validation_level  => p_validation_level,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data,
      p_check_login_user  => p_check_login_user,
      p_item_id           => p_item_id
   );
   IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       Add_ItemPersps
       (
          p_api_version       => p_api_version,
       -- p_init_msg_list     => p_init_msg_list,
          p_commit            => p_commit,
          p_validation_level  => p_validation_level,
          x_return_status     => x_return_status,
          x_msg_count         => x_msg_count,
          x_msg_data          => x_msg_data,
          p_check_login_user  => FND_API.G_FALSE,
          p_item_id           => p_item_id,
          p_perspective_array => p_perspective_array
       );
   END IF;
end Update_ItemPersps;
--
--------------------------------------------------------------------------------
PROCEDURE Get_ItemPersps
(
    p_api_version            IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,
    p_check_login_user       IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id                IN  NUMBER,
    x_perspective_obj_varray OUT NOCOPY  AMV_PERSPECTIVE_OBJ_VARRAY
) IS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_ItemPersps';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
CURSOR Get_ItemPerspective_csr IS
Select
    B.PERSPECTIVE_ID,
    B.OBJECT_VERSION_NUMBER,
    T.PERSPECTIVE_NAME,
    T.DESCRIPTION,
    T.LANGUAGE,
    T.SOURCE_LANG,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN
From   AMV_I_PERSPECTIVES_TL T, AMV_I_PERSPECTIVES_B B,
       AMV_I_ITEM_PERSPECTIVES I
Where  B.PERSPECTIVE_ID = I.PERSPECTIVE_ID
And    T.PERSPECTIVE_ID = I.PERSPECTIVE_ID
And    T.LANGUAGE = userenv('LANG')
And    I.ITEM_ID = p_item_id
Order BY T.PERSPECTIVE_NAME;
--
l_perspective_rec    Get_ItemPerspective_csr%ROWTYPE;
l_fetch_count        NUMBER := 0;
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
    -- Check if item id is valid.
    IF (AMV_UTILITY_PVT.Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_ITEM_TK', TRUE);
           FND_MESSAGE.Set_Token('ID',  to_char(p_item_id));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    --Execute the SQL statements to get records
    x_perspective_obj_varray := AMV_PERSPECTIVE_OBJ_VARRAY();
    FOR psp_rec in Get_ItemPerspective_csr LOOP
         l_fetch_count := l_fetch_count + 1;
         x_perspective_obj_varray.extend;
         x_perspective_obj_varray(l_fetch_count).perspective_id := psp_rec.perspective_id;
         x_perspective_obj_varray(l_fetch_count).object_version_number := psp_rec.object_version_number;
         x_perspective_obj_varray(l_fetch_count).perspective_name := psp_rec.perspective_name;
         x_perspective_obj_varray(l_fetch_count).description := psp_rec.description;
         x_perspective_obj_varray(l_fetch_count).language := psp_rec.language;
         x_perspective_obj_varray(l_fetch_count).source_lang := psp_rec.source_lang;
         x_perspective_obj_varray(l_fetch_count).creation_date := psp_rec.creation_date;
         x_perspective_obj_varray(l_fetch_count).created_by := psp_rec.created_by;
         x_perspective_obj_varray(l_fetch_count).last_update_date := psp_rec.last_update_date;
         x_perspective_obj_varray(l_fetch_count).last_updated_by := psp_rec.last_updated_by;
         x_perspective_obj_varray(l_fetch_count).last_update_login := psp_rec.last_update_login;
/*
         x_perspective_obj_varray(l_fetch_count) := amv_perspective_obj_type
           (
              psp_rec.perspective_id,
              psp_rec.object_version_number,
              psp_rec.perspective_name,
              psp_rec.description,
              psp_rec.language,
              psp_rec.source_lang,
              psp_rec.creation_date,
              psp_rec.created_by,
              psp_rec.last_update_date,
              psp_rec.last_updated_by,
              psp_rec.last_update_login
           );
*/
    END LOOP;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count   => x_msg_count,
       p_data    => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
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
END Get_ItemPersps;
--
--------------------------------------------------------------------------------
END amv_perspective_pvt;

/
