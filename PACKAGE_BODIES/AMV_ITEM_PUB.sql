--------------------------------------------------------
--  DDL for Package Body AMV_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_ITEM_PUB" AS
/*  $Header: amvpitmb.pls 115.27 2003/03/13 12:27:02 anraman ship $ */
--
-- NAME
--   AMV_ITEM_PUB
--
-- HISTORY
--   08/30/1999        PWU        CREATED
--   12/03/1999        PWU        modify to call jtf amv item api
--
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'AMV_ITEM_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'amvpitmb.pls';
--
G_USED_BY_ITEM      CONSTANT VARCHAR2(30) := 'ITEM';
-- Debug mode
--g_debug boolean := FALSE;
g_debug BOOLEAN := TRUE;
--
TYPE    CursorType    IS REF CURSOR;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE Create_Item
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_channel_id_array  IN  AMV_NUMBER_VARRAY_TYPE := NULL,
    p_item_obj          IN  AMV_ITEM_OBJ_TYPE,
    p_file_array        IN  AMV_NUMBER_VARRAY_TYPE,
    p_persp_array       IN  AMV_NAMEID_VARRAY_TYPE,
    p_author_array      IN  AMV_CHAR_VARRAY_TYPE,
    p_keyword_array     IN  AMV_CHAR_VARRAY_TYPE,
    x_item_id           OUT NOCOPY NUMBER
)  IS
l_api_name             CONSTANT VARCHAR2(30) := 'Create_Item';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_item_id              NUMBER;
l_return_status        VARCHAR2(1);
l_item_rec             JTF_AMV_ITEM_PUB.ITEM_REC_TYPE;
l_item_obj             AMV_ITEM_OBJ_TYPE := p_item_obj;
l_persp_id_array	   AMV_PERSPECTIVE_PVT.AMV_NUMBER_VARRAY_TYPE;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Create_Item_Pub;


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
              FND_MSG_PUB.ADD;
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
--
--Inserted the following check to fix bug # 2740293
--Because the application id should not be 0 while publishing an item
--
IF l_item_obj.application_id = 0 THEN

  l_item_obj.application_id := AMV_UTILITY_PVT.G_AMV_APP_ID;

END IF;

    --  MAKE SURE THE PASSED ITEM OBJECT HAS ALL THE RIGHT INFORMATION.
    -- Check if the object is really passed.
    IF (p_item_obj.item_name IS NULL) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_NEED_ITEM_INFO');
           FND_MSG_PUB.ADD;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    IF (l_item_obj.application_id = AMV_UTILITY_PVT.G_AMV_APP_ID ) THEN
        -- Check if item type in the item object is null
        IF (l_item_obj.item_type IS NULL OR
            l_item_obj.item_type = FND_API.G_MISS_CHAR ) THEN
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('AMV','AMV_NULL_ITEM_TYPE');
               FND_MSG_PUB.ADD;
           END IF;
           RAISE  FND_API.G_EXC_ERROR;
        END IF;
        -- Check if owner_id is valid
        IF (l_item_obj.owner_id IS NULL OR
            l_item_obj.owner_id = 0 OR
            l_item_obj.owner_id = FND_API.G_MISS_NUM) THEN
            l_item_obj.owner_id := l_resource_id;
        ELSE
           IF (AMV_UTILITY_PVT.Is_ResourceIdValid(l_item_obj.owner_id)
              <> TRUE) THEN
              IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_name('AMV','AMV_INVALID_OWNER_USER_ID');
                 FND_MESSAGE.Set_Token('ID', TO_CHAR(l_item_obj.owner_id));
                 FND_MSG_PUB.ADD;
              END IF;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;
        --
        -- Check if default_approver_id is valid
        IF (l_item_obj.default_approver_id IS NULL OR
            l_item_obj.default_approver_id = 0 OR
            l_item_obj.default_approver_id = FND_API.G_MISS_NUM) THEN
            l_item_obj.default_approver_id := l_resource_id;
        ELSE
          IF(AMV_UTILITY_PVT.Is_ResourceIdValid(l_item_obj.default_approver_id)
              <> TRUE) THEN
              IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_name('AMV','AMV_INVALID_APPROVER_ID');
                 FND_MESSAGE.Set_Token('ID',
                    TO_CHAR(l_item_obj.default_approver_id));
                 FND_MSG_PUB.ADD;
              END IF;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;
        --
        -- Check if content type id in the item object is valid
        IF (l_item_obj.content_type_id IS NULL OR
            l_item_obj.content_type_id = FND_API.G_MISS_NUM) THEN
            l_item_obj.content_type_id := NULL;
        ELSIF (AMV_UTILITY_PVT.Is_ContentTypeIdValid(l_item_obj.content_type_id)
            <> TRUE) THEN
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('AMV','AMV_INVALID_CONTENT_TYPE_ID');
               FND_MESSAGE.Set_Token('ID',
                   TO_CHAR( l_item_obj.content_type_id ) );
               FND_MSG_PUB.ADD;
           END IF;
           RAISE  FND_API.G_EXC_ERROR;
        END IF;
        -- Check if item_name(title) in the item object is null
        IF (l_item_obj.item_name IS NULL OR
            l_item_obj.item_name = FND_API.G_MISS_CHAR) THEN
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('AMV','AMV_NULL_ITEM_TITLE');
               FND_MSG_PUB.ADD;
           END IF;
           RAISE  FND_API.G_EXC_ERROR;
        END IF;
    END IF; --END OF IF (l_item_obj.application_id = ...G_AMV_APP_ID )

    --Do create the record now.

    l_item_rec.application_id       := l_item_obj.application_id;
    l_item_rec.external_access_flag := l_item_obj.external_access_flag;
    l_item_rec.item_name            := l_item_obj.item_name;
    l_item_rec.description          := l_item_obj.description;
    l_item_rec.text_string          := l_item_obj.text_string;
    l_item_rec.language_code        := l_item_obj.language_code;
    l_item_rec.status_code          := l_item_obj.status_code;
    l_item_rec.effective_start_date := l_item_obj.effective_start_date;
    l_item_rec.expiration_date      := l_item_obj.expiration_date;
    l_item_rec.item_type            := l_item_obj.item_type;
    l_item_rec.url_string           := l_item_obj.url_string;
    l_item_rec.publication_date     := l_item_obj.publication_date;
    l_item_rec.priority             := l_item_obj.priority;
    l_item_rec.content_type_id      := l_item_obj.content_type_id;
    l_item_rec.owner_id             := l_item_obj.owner_id;
    l_item_rec.default_approver_id  := l_item_obj.default_approver_id;
    l_item_rec.item_destination_type := l_item_obj.item_destination_type;

    JTF_AMV_ITEM_PUB.Create_Item
    (
       p_api_version       =>  p_api_version,
       p_init_msg_list     =>  FND_API.G_FALSE,
       p_commit            =>  FND_API.G_FALSE,
       x_return_status     =>  x_return_status,
       x_msg_count         =>  x_msg_count,
       x_msg_data          =>  x_msg_data,
       p_item_rec          =>  l_item_rec,
       x_item_id           =>  l_item_id
    );
    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Add item's perspectives
    IF (p_persp_array IS NOT NULL) THEN
	  l_persp_id_array := AMV_PERSPECTIVE_PVT.AMV_NUMBER_VARRAY_TYPE();
	  FOR i IN 1..p_persp_array.COUNT LOOP
		l_persp_id_array.extend;
		l_persp_id_array(i) := p_persp_array(i).id;
	  END LOOP;
       amv_perspective_pvt.Add_ItemPersps
       (
           p_api_version       => l_api_version,
           x_return_status     => l_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_check_login_user  => FND_API.G_FALSE,
           p_item_id           => l_item_id,
           p_perspective_array => l_persp_id_array
       );
       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
              x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;
    -- Add item's keywords
    IF (p_keyword_array IS NOT NULL) THEN
       Add_ItemKeyword
       (
           p_api_version       => l_api_version,
           x_return_status     => l_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_check_login_user  => FND_API.G_FALSE,
           p_item_id           => l_item_id,
           p_keyword_varray    => p_keyword_array
       );
       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
              x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;
    -- Add item's authors
    IF (p_author_array IS NOT NULL) THEN
       Add_ItemAuthor
       (
           p_api_version       => l_api_version,
           x_return_status     => l_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_check_login_user  => FND_API.G_FALSE,
           p_item_id           => l_item_id,
           p_author_varray     => p_author_array
       );
       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
              x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;
    IF (p_file_array IS NOT NULL) THEN
       Add_ItemFile
       (
           p_api_version       => l_api_version,
           x_return_status     => l_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_check_login_user  => FND_API.G_FALSE,
           p_application_id    => l_item_obj.application_id,
           p_item_id           => l_item_id,
           p_file_id_varray    => p_file_array
       );
       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
              x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;
    --Check if channel id array is passed and if so, make sure each id is valid.
    IF (p_channel_id_array IS NOT NULL) THEN
        FOR i IN 1..p_channel_id_array.COUNT LOOP
            IF (AMV_UTILITY_PVT.Is_ChannelIdValid(p_channel_id_array(i))=TRUE)
			THEN
               -- match the channel with the newly created content item
               AMV_MATCH_PVT.Do_ItemChannelMatch
               (
                    p_api_version       => l_api_version,
                    x_return_status     => l_return_status,
                    x_msg_count         => x_msg_count,
                    x_msg_data          => x_msg_data,
                    p_check_login_user  => FND_API.G_FALSE,
                    p_channel_id        => p_channel_id_array(i),
                    p_item_id           => l_item_id,
                    p_table_name_code   => G_USED_BY_ITEM,
                    p_match_type        => AMV_UTILITY_PVT.G_PUSH
               );
               IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
                      x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
               END IF;
            ELSE
               IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
                  FND_MESSAGE.Set_Token('RECORD', 'AMV_CHANNEL_TK', TRUE);
                  FND_MESSAGE.Set_Token('ID',
                      TO_CHAR(NVL(p_channel_id_array(i), -1)));
                  FND_MSG_PUB.ADD;
               END IF;
            END IF;
        END LOOP;
    END IF;
    --IF (l_item_obj.application_id = AMV_UTILITY_PVT.G_AMV_APP_ID) THEN
        -- insert a request to matching engine to process item match.
	   -- Ignore the Messages
	   IF  (l_item_rec.item_type  <> 'MESSAGE_ITEM' ) THEN
        	AMV_MATCH_PVT.Request_ItemMatch
        	(
           p_api_version       => l_api_version,
           x_return_status     => l_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_check_login_user  => FND_API.G_FALSE,
           p_item_id           => l_item_id
        	);
   		END IF;
    -- pass back the item id.
    x_item_id := l_item_id;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Create_Item_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Create_Item_Pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Create_Item_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Create_Item;
--------------------------------------------------------------------------------
PROCEDURE Delete_Item
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Delete_Item';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_return_status        VARCHAR2(1);
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Delete_Item_Pub;
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
              FND_MSG_PUB.ADD;
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- Check if item id is valid.
    IF (AMV_UTILITY_PVT.Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_ITEM_TK', TRUE);
           FND_MESSAGE.Set_Token('ID',  TO_CHAR(p_item_id));
           FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Now do the deleting (real job).
    -- Delete item's perspectives
    amv_perspective_pvt.Delete_ItemPersps
    (
        p_api_version       => p_api_version,
        x_return_status     => l_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_check_login_user  => FND_API.G_FALSE,
        p_item_id           => p_item_id
    );
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
           x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    -- Remove item from all channels.
    DELETE FROM amv_c_chl_item_match
    WHERE item_id = p_item_id
    AND table_name_code = G_USED_BY_ITEM;
    -- Remove item's access.
    DELETE FROM amv_u_access
    WHERE access_to_table_record_id = p_item_id
    AND   access_to_table_code = G_USED_BY_ITEM;
/*
    AMV_DistRule_Pvt.Delete_ItemFromDistRules
    (
        p_api_version       => p_api_version,
        x_return_status     => l_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_item_id           => p_item_id
    );
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
           x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
*/
    -- Finally delete the item itself.
    JTF_AMV_ITEM_PUB.Delete_Item
    (
       p_api_version       =>  p_api_version,
       p_init_msg_list     =>  FND_API.G_FALSE,
       p_commit            =>  p_commit,
       x_return_status     =>  l_return_status,
       x_msg_count         =>  x_msg_count,
       x_msg_data          =>  x_msg_data,
       p_item_id           =>  p_item_id
    );
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
           x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Delete_Item_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Delete_Item_Pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Delete_Item_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Delete_Item;
--------------------------------------------------------------------------------
PROCEDURE Update_Item
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_channel_id_array  IN  AMV_NUMBER_VARRAY_TYPE := NULL,
    p_item_obj          IN  AMV_ITEM_OBJ_TYPE,
    p_file_array        IN  AMV_NUMBER_VARRAY_TYPE,
    p_persp_array       IN  AMV_NAMEID_VARRAY_TYPE,
    p_author_array      IN  AMV_CHAR_VARRAY_TYPE,
    p_keyword_array     IN  AMV_CHAR_VARRAY_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Update_Item';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_return_status        VARCHAR2(1);
l_item_rec             JTF_AMV_ITEM_PUB.ITEM_REC_TYPE;
l_persp_id_array	   AMV_PERSPECTIVE_PVT.AMV_NUMBER_VARRAY_TYPE;
l_channel_id_array	   AMV_NAMEID_VARRAY_TYPE;
l_channel_add_id	   AMV_NUMBER_VARRAY_TYPE;
l_channel_remove_id	   AMV_NUMBER_VARRAY_TYPE;
l_flag			   VARCHAR2(10);
l_rec_num			   NUMBER := 1;
l_application_id  NUMBER := p_item_obj.application_id;

CURSOR GetChannelMatch_csr IS
SELECT channel_id
FROM	  amv_c_chl_item_match
WHERE  item_id = p_item_obj.item_id
AND    available_due_to_type = AMV_UTILITY_PVT.G_PUSH;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Update_Item_Pub;
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
              FND_MSG_PUB.ADD;
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;

--
--Inserted the following check to fix bug # 2740293
--Because the application id should not be 0 while publishing an item
--
IF l_application_id = 0 THEN

  l_application_id := AMV_UTILITY_PVT.G_AMV_APP_ID;

END IF;


    --  MAKE SURE THE PASSED ITEM OBJECT HAS ALL THE RIGHT INFORMATION.
    -- Check if the object is really passed.
    IF (p_item_obj.item_id IS NULL) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_NEED_ITEM_INFO');
           FND_MSG_PUB.ADD;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --Do update the record now.

    l_item_rec.item_id              := p_item_obj.item_id;
    l_item_rec.object_version_number := p_item_obj.object_version_number;
    l_item_rec.application_id       := l_application_id;
    l_item_rec.external_access_flag := p_item_obj.external_access_flag;
    l_item_rec.item_name            := p_item_obj.item_name;
    l_item_rec.description          := p_item_obj.description;
    l_item_rec.text_string          := p_item_obj.text_string;
    l_item_rec.language_code        := p_item_obj.language_code;
    l_item_rec.status_code          := p_item_obj.status_code;
    l_item_rec.effective_start_date := p_item_obj.effective_start_date;
    l_item_rec.expiration_date      := p_item_obj.expiration_date;
    l_item_rec.item_type            := p_item_obj.item_type;
    l_item_rec.url_string           := p_item_obj.url_string;
    l_item_rec.publication_date     := p_item_obj.publication_date;
    l_item_rec.priority             := p_item_obj.priority;
    l_item_rec.content_type_id      := p_item_obj.content_type_id;
    l_item_rec.owner_id             := p_item_obj.owner_id;
    l_item_rec.default_approver_id  := p_item_obj.default_approver_id;
    l_item_rec.item_destination_type := p_item_obj.item_destination_type;
    IF (l_item_rec.application_id  = AMV_UTILITY_PVT.G_AMV_APP_ID) THEN
        IF (l_item_rec.external_access_flag <> FND_API.G_TRUE AND
           l_item_rec.external_access_flag <> FND_API.G_FALSE) THEN
           l_item_rec.external_access_flag := FND_API.G_MISS_CHAR;
        END IF;
        IF (l_item_rec.item_name IS NULL) THEN
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('AMV','AMV_NULL_ITEM_TITLE');
               FND_MSG_PUB.ADD;
           END IF;
            l_item_rec.item_name := FND_API.G_MISS_CHAR;
        END IF;
        IF (l_item_rec.item_type  IS NULL) THEN
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('AMV','AMV_NULL_ITEM_TYPE');
               FND_MSG_PUB.ADD;
           END IF;
            l_item_rec.item_type  := FND_API.G_MISS_CHAR;
        END IF;
        IF ( l_item_rec.content_type_id IS NOT NULL AND
             l_item_rec.content_type_id <> FND_API.G_MISS_NUM) THEN
           IF (AMV_UTILITY_PVT.Is_ContentTypeIdValid(l_item_rec.content_type_id)
               <> TRUE) THEN
              IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_name('AMV','AMV_INVALID_CONTENT_TYPE_ID');
                  FND_MESSAGE.Set_Token('ID',
                      TO_CHAR( l_item_rec.content_type_id ) );
                  FND_MSG_PUB.ADD;
              END IF;
              l_item_rec.content_type_id := FND_API.G_MISS_NUM;
           END IF;
        END IF;
    END IF;
    JTF_AMV_ITEM_PUB.Update_Item
    (
       p_api_version       =>  p_api_version,
       p_init_msg_list     =>  FND_API.G_FALSE,
       p_commit            =>  FND_API.G_FALSE,
       x_return_status     =>  x_return_status,
       x_msg_count         =>  x_msg_count,
       x_msg_data          =>  x_msg_data,
       p_item_rec          =>  l_item_rec
    );
    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_persp_array IS NOT NULL) THEN
	  l_persp_id_array := AMV_PERSPECTIVE_PVT.AMV_NUMBER_VARRAY_TYPE();
	  FOR i IN 1..p_persp_array.COUNT LOOP
		l_persp_id_array.extend;
		l_persp_id_array(i) := p_persp_array(i).id;
	  END LOOP;
       amv_perspective_pvt.Update_ItemPersps
       (
          p_api_version       => p_api_version,
          x_return_status     => l_return_status,
          x_msg_count         => x_msg_count,
          x_msg_data          => x_msg_data,
          p_check_login_user  => FND_API.G_FALSE,
          p_item_id           => p_item_obj.item_id,
          p_perspective_array => l_persp_id_array
       );
       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
              x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;
    IF (p_author_array IS NOT NULL) THEN
        Replace_ItemAuthor
        (
            p_api_version       => p_api_version,
            x_return_status     => l_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_check_login_user  => FND_API.G_FALSE,
            p_item_id           => p_item_obj.item_id,
            p_author_varray     => p_author_array
        );
       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
              x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;
    IF (p_file_array IS NOT NULL) THEN
       Replace_ItemFile
       (
           p_api_version       => l_api_version,
           x_return_status     => l_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_check_login_user  => FND_API.G_FALSE,
           p_item_id           => p_item_obj.item_id,
           p_file_id_varray    => p_file_array
       );
       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
              x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;


    IF (p_keyword_array IS NOT NULL) THEN
        Replace_ItemKeyword
        (
            p_api_version       => p_api_version,
            x_return_status     => l_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_check_login_user  => FND_API.G_FALSE,
            p_item_id           => p_item_obj.item_id,
            p_keyword_varray    => p_keyword_array
        );
       IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
              x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;
    --Check if channel id array is passed and if so, make sure each id is valid.
    l_channel_id_array := AMV_NAMEID_VARRAY_TYPE();
    l_rec_num := 1;
    IF (p_channel_id_array IS NOT NULL) THEN
	   -- get all channels matched with item on force mode
	   OPEN GetChannelMatch_csr;
	    	LOOP
 	        l_channel_id_array.extend;
		  FETCH GetChannelMatch_csr INTO l_channel_id_array(l_rec_num).id;
		  EXIT WHEN GetChannelMatch_csr%NOTFOUND;
		  l_rec_num := l_rec_num + 1;
		END LOOP;
	   CLOSE GetChannelMatch_csr;

	   -- initialize rec num
	   l_rec_num := 1;
           l_channel_add_id := AMV_NUMBER_VARRAY_TYPE();

	   -- check if channel exists in the list
	   FOR i IN 1..p_channel_id_array.COUNT LOOP
		FOR j IN 1..l_channel_id_array.COUNT LOOP
	   		IF p_channel_id_array(i) = l_channel_id_array(j).id THEN
				l_flag := 'EXISTS';
				l_channel_id_array(j).name := 'T';
		     ELSE
				l_flag := 'ADDED';
			END IF;
			EXIT WHEN p_channel_id_array(i) = l_channel_id_array(j).id;
		END LOOP;
		IF l_flag = 'ADDED' THEN
	   	  -- build channels list to add
	          l_channel_add_id.extend;
	          l_channel_add_id(l_rec_num) := p_channel_id_array(i);
			l_rec_num := l_rec_num + 1;
		ELSE
			l_flag := 'ADDED';
		END IF;
	   END LOOP;

	   -- initialize rec num
	   l_rec_num := 1;
	   l_channel_remove_id := AMV_NUMBER_VARRAY_TYPE();

	   -- build channels list to delete
	   FOR i in 1..l_channel_id_array.count LOOP
		IF l_channel_id_array(i).name is null THEN
	          l_channel_remove_id.extend;
	          l_channel_remove_id(l_rec_num) := l_channel_id_array(i).id;
			l_rec_num := l_rec_num + 1;
		END IF;
	   END LOOP;

	   -- delete removed channels
        FOR i IN 1..l_channel_remove_id.COUNT LOOP
           IF (AMV_UTILITY_PVT.Is_ChannelIdValid(l_channel_remove_id(i))=TRUE)
		  THEN
               -- remove the channel from content item
               AMV_MATCH_PVT.Remove_ItemChannelMatch
               (
                    p_api_version       => l_api_version,
                    x_return_status     => l_return_status,
                    x_msg_count         => x_msg_count,
                    x_msg_data          => x_msg_data,
                    p_check_login_user  => FND_API.G_FALSE,
                    p_channel_id        => l_channel_remove_id(i),
                    p_item_id           => p_item_obj.item_id,
                    p_table_name_code   => G_USED_BY_ITEM
               );
               IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
                      x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
               END IF;
            ELSE
               IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
                  FND_MESSAGE.Set_Token('RECORD', 'AMV_CHANNEL_TK', TRUE);
                  FND_MESSAGE.Set_Token('ID',
                      TO_CHAR(NVL(l_channel_remove_id(i), -1)));
                  FND_MSG_PUB.ADD;
               END IF;
            END IF;
	   END LOOP;

	   -- Add items to new channels
        FOR i IN 1..l_channel_add_id.COUNT LOOP
            IF (AMV_UTILITY_PVT.Is_ChannelIdValid(l_channel_add_id(i))=TRUE)
		  THEN
               -- match the channel with the newly created content item
               AMV_MATCH_PVT.Do_ItemChannelMatch
               (
                    p_api_version       => l_api_version,
                    x_return_status     => l_return_status,
                    x_msg_count         => x_msg_count,
                    x_msg_data          => x_msg_data,
                    p_check_login_user  => FND_API.G_FALSE,
                    p_channel_id        => l_channel_add_id(i),
                    p_item_id           => p_item_obj.item_id,
                    p_table_name_code   => G_USED_BY_ITEM,
                    p_match_type        => AMV_UTILITY_PVT.G_PUSH
               );
               IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
                      x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
               END IF;
            ELSE
               IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
                  FND_MESSAGE.Set_Token('RECORD', 'AMV_CHANNEL_TK', TRUE);
                  FND_MESSAGE.Set_Token('ID',
                      TO_CHAR(NVL(p_channel_id_array(i), -1)));
                  FND_MSG_PUB.ADD;
               END IF;
            END IF;
        END LOOP;
    END IF;
    --IF (p_item_obj.application_id = AMV_UTILITY_PVT.G_AMV_APP_ID) THEN
        -- insert a request to matching engine to process item match.
	 IF  (p_item_obj.item_type  <> 'MESSAGE_ITEM' ) THEN
        AMV_MATCH_PVT.Request_ItemMatch
        (
           p_api_version       => l_api_version,
           x_return_status     => l_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_check_login_user  => FND_API.G_FALSE,
           p_item_id           => p_item_obj.item_id
        );
      END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Update_Item_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Update_Item_Pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Update_Item_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Update_Item;
--------------------------------------------------------------------------------
PROCEDURE Get_Item
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    x_item_obj          OUT NOCOPY AMV_ITEM_OBJ_TYPE,
    x_file_array        OUT NOCOPY  AMV_NUMBER_VARRAY_TYPE,
    x_persp_array       OUT NOCOPY  AMV_NAMEID_VARRAY_TYPE,
    x_author_array      OUT NOCOPY  AMV_CHAR_VARRAY_TYPE,
    x_keyword_array     OUT NOCOPY  AMV_CHAR_VARRAY_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_Item';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_return_status        VARCHAR2(1);
l_item_rec             JTF_AMV_ITEM_PUB.ITEM_REC_TYPE;
l_persp_obj_varray     AMV_PERSPECTIVE_PVT.AMV_PERSPECTIVE_OBJ_VARRAY;
l_persp_varray    	   AMV_NAMEID_VARRAY_TYPE;
l_author_varray        AMV_CHAR_VARRAY_TYPE;
l_keyword_varray       AMV_CHAR_VARRAY_TYPE;
l_file_id_varray       AMV_NUMBER_VARRAY_TYPE;
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- Check if item id is valid.
    IF (AMV_UTILITY_PVT.Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_ITEM_TK', TRUE);
           FND_MESSAGE.Set_Token('ID',  TO_CHAR(p_item_id));
           FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    JTF_AMV_ITEM_PUB.Get_Item
    (
       p_api_version       =>  p_api_version,
       p_init_msg_list     =>  FND_API.G_FALSE,
       x_return_status     =>  x_return_status,
       x_msg_count         =>  x_msg_count,
       x_msg_data          =>  x_msg_data,
       p_item_id           => p_item_id,
       x_item_rec          =>  l_item_rec
    );
    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Get item's perspectives.
    --l_persp_id_varray := AMV_NUMBER_VARRAY_TYPE();
    --l_persp_name_varray := AMV_CHAR_VARRAY_TYPE();
    l_persp_varray := AMV_NAMEID_VARRAY_TYPE();
    l_persp_obj_varray := AMV_PERSPECTIVE_PVT.AMV_PERSPECTIVE_OBJ_VARRAY();
    AMV_PERSPECTIVE_PVT.Get_ItemPersps
    (
        p_api_version            => p_api_version,
        x_return_status          => l_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_check_login_user       => FND_API.G_FALSE,
        p_item_id                => p_item_id,
        x_perspective_obj_varray => l_persp_obj_varray
    );
    IF (l_persp_obj_varray IS NOT NULL) THEN
       FOR i IN 1..l_persp_obj_varray.COUNT LOOP
           l_persp_varray.extend;
           l_persp_varray(i).id := l_persp_obj_varray(i).perspective_id;
           l_persp_varray(i).name := l_persp_obj_varray(i).perspective_name;
       END LOOP;
    END IF;
    -- Get item's keywords.
    Get_ItemKeyword
    (
        p_api_version       => p_api_version,
        x_return_status     => l_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_check_login_user  => FND_API.G_FALSE,
        p_item_id           => p_item_id,
        x_keyword_varray     => l_keyword_varray
    );
    IF (l_keyword_varray IS NULL) THEN
        l_keyword_varray := AMV_CHAR_VARRAY_TYPE();
    END IF;
    -- Get item's authors.
    Get_ItemAuthor
    (
        p_api_version       => p_api_version,
        x_return_status     => l_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_check_login_user  => FND_API.G_FALSE,
        p_item_id           => p_item_id,
        x_author_varray     => l_author_varray
    );
    IF (l_author_varray IS NULL) THEN
        l_author_varray := AMV_CHAR_VARRAY_TYPE();
    END IF;
    -- Get item's file id.
    Get_ItemFile
    (
        p_api_version       => p_api_version,
        x_return_status     => l_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_check_login_user  => FND_API.G_FALSE,
        p_item_id           => p_item_id,
        x_file_id_varray    => l_file_id_varray
    );
    IF (l_file_id_varray IS NULL) THEN
        l_file_id_varray := AMV_NUMBER_VARRAY_TYPE();
    END IF;
    -- Finally construct the return object.
    x_item_obj.item_id :=  p_item_id;
    x_item_obj.object_version_number := l_item_rec.OBJECT_VERSION_NUMBER;
    x_item_obj.creation_date := l_item_rec.CREATION_DATE;
    x_item_obj.created_by := l_item_rec.CREATED_BY;
    x_item_obj.last_update_date := l_item_rec.LAST_UPDATE_DATE;
    x_item_obj.last_updated_by := l_item_rec.LAST_UPDATED_BY;
    x_item_obj.last_update_login := l_item_rec.LAST_UPDATE_LOGIN;
    x_item_obj.application_id := l_item_rec.APPLICATION_ID;
    x_item_obj.external_access_flag := l_item_rec.EXTERNAL_ACCESS_FLAG;
    x_item_obj.item_name := l_item_rec.ITEM_NAME;
    x_item_obj.description := l_item_rec.DESCRIPTION;
    x_item_obj.text_string := l_item_rec.TEXT_STRING;
    x_item_obj.language_code := l_item_rec.LANGUAGE_CODE;
    x_item_obj.status_code := l_item_rec.STATUS_CODE;
    x_item_obj.effective_start_date := l_item_rec.EFFECTIVE_START_DATE;
    x_item_obj.expiration_date := l_item_rec.EXPIRATION_DATE;
    x_item_obj.item_type := l_item_rec.ITEM_TYPE;
    x_item_obj.url_string := l_item_rec.URL_STRING;
    x_item_obj.publication_date := l_item_rec.PUBLICATION_DATE;
    x_item_obj.priority := l_item_rec.PRIORITY;
    x_item_obj.content_type_id := l_item_rec.CONTENT_TYPE_ID;
    x_item_obj.owner_id := l_item_rec.OWNER_ID;
    x_item_obj.default_approver_id := l_item_rec.DEFAULT_APPROVER_ID;
    x_item_obj.item_destination_type := l_item_rec.ITEM_DESTINATION_TYPE;

    x_file_array := AMV_NUMBER_VARRAY_TYPE();
    x_file_array := l_file_id_varray;
    x_persp_array := AMV_NAMEID_VARRAY_TYPE();
    x_persp_array :=  l_persp_varray;
    x_author_array := AMV_CHAR_VARRAY_TYPE();
    x_author_array := l_author_varray;
    x_keyword_array := AMV_CHAR_VARRAY_TYPE();
    x_keyword_array := l_keyword_varray;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Get_Item;
--------------------------------------------------------------------------------
PROCEDURE Find_Item
(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_check_login_user    IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_name           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_description         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_item_type           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_subset_request_obj  IN  AMV_REQUEST_OBJ_TYPE,
    x_subset_return_obj   OUT NOCOPY AMV_RETURN_OBJ_TYPE,
    x_item_obj_array      OUT NOCOPY AMV_SIMPLE_ITEM_OBJ_VARRAY
) AS
--
l_api_name             CONSTANT VARCHAR2(30) := 'Find_Item';
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
l_item_id                   NUMBER;
l_object_version_number     NUMBER;
l_creation_date             DATE;
l_created_by                NUMBER;
l_last_update_date          DATE;
l_last_updated_by           NUMBER;
l_last_update_login         NUMBER;
l_application_id            NUMBER;
l_external_access           VARCHAR2(1);
l_item_name                 VARCHAR2(240);
l_description               VARCHAR2(4000);
l_text_string               VARCHAR2(4000);
l_language_code             VARCHAR2(4);
l_status_code               VARCHAR2(30);
l_owner_id                  NUMBER;
l_effective_start_date      DATE;
l_expiration_date           DATE;
l_item_type                 VARCHAR2(240);
l_content_type_id           NUMBER;
l_publication_date          DATE;
l_priority                  VARCHAR2(30);
l_default_approver_id       NUMBER;
l_url_string                VARCHAR2(2000);
l_item_destination_type     VARCHAR2(240);
--
l_return_status        VARCHAR2(1);
l_persp_obj_varray     AMV_PERSPECTIVE_PVT.AMV_PERSPECTIVE_OBJ_VARRAY;
l_persp_id_list        VARCHAR2(2000);
l_persp_name_list      VARCHAR2(2000);
l_keyword_varray       AMV_CHAR_VARRAY_TYPE;
l_keyword_list         VARCHAR2(2000);
l_author_varray        AMV_CHAR_VARRAY_TYPE;
l_author_list          VARCHAR2(2000);
l_file_id_varray       AMV_NUMBER_VARRAY_TYPE;
l_file_id_list         VARCHAR2(2000);
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
        FND_MESSAGE.Set_name('AMV','PVT Find Item API: Start');
        FND_MSG_PUB.ADD;
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
              FND_MSG_PUB.ADD;
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
           'ITEM_ID, ' ||
           'OBJECT_VERSION_NUMBER, ' ||
           'CREATION_DATE, ' ||
           'CREATED_BY, ' ||
           'LAST_UPDATE_DATE, ' ||
           'LAST_UPDATED_BY, ' ||
           'LAST_UPDATE_LOGIN, ' ||
           'APPLICATION_ID, ' ||
           'EXTERNAL_ACCESS_FLAG, ' ||
           'ITEM_NAME, ' ||
           'DESCRIPTION, ' ||
           'TEXT_STRING, ' ||
           'LANGUAGE_CODE, ' ||
           'STATUS_CODE, ' ||
           'EFFECTIVE_START_DATE, ' ||
           'EXPIRATION_DATE, ' ||
           'ITEM_TYPE, ' ||
           'URL_STRING, ' ||
           'PUBLICATION_DATE, ' ||
           'PRIORITY, ' ||
           'CONTENT_TYPE_ID, ' ||
           'OWNER_ID, ' ||
           'DEFAULT_APPROVER_ID, ' ||
           'ITEM_DESTINATION_TYPE ' ||
       'From   JTF_AMV_ITEMS_VL';
    l_sql_statement2 :=
       'Select count(*) ' ||
       'From   JTF_AMV_ITEMS_VL';
    --
    l_where_clause := ' ';
    IF (p_item_name IS NOT NULL AND
        p_item_name <> FND_API.G_MISS_CHAR) THEN
        l_where_clause := l_where_clause ||
             'And ITEM_NAME Like ''' || p_item_name || ''' ';
    END IF;
    IF (p_description IS NOT NULL AND
        p_description <> FND_API.G_MISS_CHAR) THEN
        l_where_clause := l_where_clause ||
             'And DESCRIPTION Like ''' || p_description || ''' ';
    END IF;
    IF (p_item_type IS NOT NULL AND
        p_item_type <> FND_API.G_MISS_CHAR) THEN
        l_where_clause := l_where_clause ||
             'And ITEM_TYPE Like ''' || p_item_type || ''' ';
    END IF;
    l_sql_statement := l_sql_statement ||
         l_where_clause || 'ORDER BY ITEM_NAME ';
    l_sql_statement2 := l_sql_statement2 ||
         l_where_clause;
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_sql_statement);
       FND_MSG_PUB.ADD;
       --
       FND_MESSAGE.Set_name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_sql_statement2);
       FND_MSG_PUB.ADD;
    END IF;
    --Execute the SQL statements to get the total count:
    IF (p_subset_request_obj.return_total_count_flag = FND_API.G_TRUE) THEN
        OPEN  l_cursor FOR l_sql_statement2;
        FETCH l_cursor INTO l_total_record_count;
        CLOSE l_cursor;
    END IF;
    --Execute the SQL statements to get records
    l_start_with := p_subset_request_obj.start_record_position;
    x_item_obj_array := AMV_SIMPLE_ITEM_OBJ_VARRAY();
    OPEN l_cursor FOR l_sql_statement;
    LOOP
      FETCH l_cursor INTO
         l_item_id,
         l_object_version_number,
         l_creation_date,
         l_created_by,
         l_last_update_date,
         l_last_updated_by,
         l_last_update_login,
         l_application_id,
         l_external_access,
         l_item_name,
         l_description,
         l_text_string,
         l_language_code,
         l_status_code,
         l_effective_start_date,
         l_expiration_date,
         l_item_type,
         l_url_string,
         l_publication_date,
         l_priority,
         l_content_type_id,
         l_owner_id,
         l_default_approver_id,
         l_item_destination_type;
      EXIT WHEN l_cursor%NOTFOUND;
      IF (l_start_with <= l_total_count AND
          l_fetch_count < p_subset_request_obj.records_requested) THEN
         l_fetch_count := l_fetch_count + 1;
         -- Get item's perspectives.
         AMV_PERSPECTIVE_PVT.Get_ItemPersps
         (
             p_api_version            => p_api_version,
             x_return_status          => l_return_status,
             x_msg_count              => x_msg_count,
             x_msg_data               => x_msg_data,
             p_check_login_user       => FND_API.G_FALSE,
             p_item_id                => l_item_id,
             x_perspective_obj_varray => l_persp_obj_varray
         );
         l_persp_id_list    := '';
         l_persp_name_list  := '';
         IF (l_persp_obj_varray IS NOT NULL) THEN
            FOR i IN 1..l_persp_obj_varray.COUNT LOOP
                l_persp_id_list := l_persp_id_list  ||
                       l_persp_obj_varray(i).perspective_id || ' ';
                l_persp_name_list := l_persp_name_list  ||
                       l_persp_obj_varray(i).perspective_name || ' ';
            END LOOP;
         END IF;
         -- Get item's keywords.
         Get_ItemKeyword
         (
             p_api_version       => p_api_version,
             x_return_status     => l_return_status,
             x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data,
             p_check_login_user  => FND_API.G_FALSE,
             p_item_id           => l_item_id,
             x_keyword_varray     => l_keyword_varray
         );
         l_keyword_list := '';
         IF (l_keyword_varray IS NOT NULL) THEN
            FOR i IN 1..l_keyword_varray.COUNT LOOP
                l_keyword_list := l_keyword_list  ||
                       l_keyword_varray(i) || ' ';
            END LOOP;
         END IF;
         -- Get item's authors.
         Get_ItemAuthor
         (
             p_api_version       => p_api_version,
             x_return_status     => l_return_status,
             x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data,
             p_check_login_user  => FND_API.G_FALSE,
             p_item_id           => l_item_id,
             x_author_varray     => l_author_varray
         );
         l_author_list := '';
         IF (l_author_varray IS NOT NULL) THEN
            FOR i IN 1..l_keyword_varray.COUNT LOOP
                l_author_list := l_author_list  ||
                       l_author_varray(i) || ' ';
            END LOOP;
         END IF;
         -- Get item's file id.
         Get_ItemFile
         (
             p_api_version       => p_api_version,
             x_return_status     => l_return_status,
             x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data,
             p_check_login_user  => FND_API.G_FALSE,
             p_item_id           => l_item_id,
             x_file_id_varray    => l_file_id_varray
         );
         l_file_id_list := '';
         IF (l_file_id_varray IS NOT NULL) THEN
            FOR i IN 1..l_file_id_varray.COUNT LOOP
                l_file_id_list := l_file_id_list||l_file_id_varray(i)||' ';
            END LOOP;
         END IF;
     x_item_obj_array.extend;
    	x_item_obj_array(l_fetch_count).item_id :=  l_item_id;
    	x_item_obj_array(l_fetch_count).object_version_number := l_OBJECT_VERSION_NUMBER;
    	x_item_obj_array(l_fetch_count).creation_date := l_CREATION_DATE;
    	x_item_obj_array(l_fetch_count).created_by := l_CREATED_BY;
    	x_item_obj_array(l_fetch_count).last_update_date := l_LAST_UPDATE_DATE;
    	x_item_obj_array(l_fetch_count).last_updated_by := l_LAST_UPDATED_BY;
    	x_item_obj_array(l_fetch_count).last_update_login := l_LAST_UPDATE_LOGIN;
    	x_item_obj_array(l_fetch_count).application_id := l_APPLICATION_ID;
    	x_item_obj_array(l_fetch_count).external_access_flag := l_EXTERNAL_ACCESS;
    	x_item_obj_array(l_fetch_count).item_name := l_ITEM_NAME;
    	x_item_obj_array(l_fetch_count).description := l_DESCRIPTION;
    	x_item_obj_array(l_fetch_count).text_string := l_TEXT_STRING;
    	x_item_obj_array(l_fetch_count).language_code := l_LANGUAGE_CODE;
    	x_item_obj_array(l_fetch_count).status_code := l_STATUS_CODE;
    	x_item_obj_array(l_fetch_count).effective_start_date := l_EFFECTIVE_START_DATE;
    	x_item_obj_array(l_fetch_count).expiration_date := l_EXPIRATION_DATE;
    	x_item_obj_array(l_fetch_count).item_type := l_ITEM_TYPE;
    	x_item_obj_array(l_fetch_count).url_string := l_URL_STRING;
    	x_item_obj_array(l_fetch_count).publication_date := l_PUBLICATION_DATE;
    	x_item_obj_array(l_fetch_count).priority := l_PRIORITY;
    	x_item_obj_array(l_fetch_count).content_type_id := l_CONTENT_TYPE_ID;
    	x_item_obj_array(l_fetch_count).owner_id := l_OWNER_ID;
    	x_item_obj_array(l_fetch_count).default_approver_id := l_DEFAULT_APPROVER_ID;
    	x_item_obj_array(l_fetch_count).item_destination_type := l_ITEM_DESTINATION_TYPE;
     x_item_obj_array(l_fetch_count).file_id_list := l_file_id_list;
     x_item_obj_array(l_fetch_count).persp_id_list := l_persp_id_list;
     x_item_obj_array(l_fetch_count).persp_name_list := l_persp_name_list;
     x_item_obj_array(l_fetch_count).author_list := l_author_list;
     x_item_obj_array(l_fetch_count).keyword_list := l_keyword_list;

      END IF;
      IF (l_fetch_count >= p_subset_request_obj.records_requested) THEN
         EXIT;
      END IF;
      l_total_count := l_total_count + 1;
    END LOOP;
    CLOSE l_cursor;
    x_subset_return_obj.returned_record_count := l_fetch_count;
    x_subset_return_obj.next_record_position :=
		p_subset_request_obj.start_record_position + l_fetch_count;
    x_subset_return_obj.total_record_count :=   l_total_record_count;
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
END Find_Item;
--------------------------------------------------------------------------------
------------------------------ ITEM_KEYWORD ------------------------------------
PROCEDURE Add_ItemKeyword
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_keyword_varray    IN  AMV_CHAR_VARRAY_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Add_ItemKeyword';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_char_tab             JTF_AMV_ITEM_PUB.CHAR_TAB_TYPE;
--
BEGIN
    SAVEPOINT Add_ItemKeyword_Pub;
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
              FND_MSG_PUB.ADD;
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    IF (p_keyword_varray IS NOT NULL) THEN
       l_char_tab := JTF_AMV_ITEM_PUB.CHAR_TAB_TYPE();
       FOR i IN 1..p_keyword_varray.COUNT LOOP
          l_char_tab.extend;
          l_char_tab(i) := initcap(p_keyword_varray(i));
       END LOOP;
       JTF_AMV_ITEM_PUB.Add_ItemKeyword
       (
          p_api_version       =>  p_api_version,
          p_init_msg_list     =>  FND_API.G_FALSE,
          p_commit            =>  p_commit,
          x_return_status     =>  x_return_status,
          x_msg_count         =>  x_msg_count,
          x_msg_data          =>  x_msg_data,
          p_item_id           =>  p_item_id,
          p_keyword_tab       =>  l_char_tab
       );
    ELSE
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
       );
    END IF;
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_ItemKeyword_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_ItemKeyword_Pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_ItemKeyword_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Add_ItemKeyword;
--------------------------------------------------------------------------------
PROCEDURE Add_ItemKeyword
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_keyword           IN  VARCHAR2
) AS
l_char_varray           AMV_CHAR_VARRAY_TYPE;
BEGIN
    l_char_varray := AMV_CHAR_VARRAY_TYPE();
    l_char_varray.extend;
    l_char_varray(1) := p_keyword;
    --
    Add_ItemKeyword
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit            => p_commit,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_check_login_user  => p_check_login_user,
        p_item_id           => p_item_id,
        p_keyword_varray    => l_char_varray
    );
END Add_ItemKeyword;
--------------------------------------------------------------------------------
PROCEDURE Delete_ItemKeyword
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_keyword_varray    IN  AMV_CHAR_VARRAY_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Delete_ItemKeyword';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_char_tab             JTF_AMV_ITEM_PUB.CHAR_TAB_TYPE;
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Delete_ItemKeyword_Pub;
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
              FND_MSG_PUB.ADD;
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    --
    IF (p_keyword_varray IS NULL) THEN
       l_char_tab := NULL;
    ELSE
       l_char_tab := JTF_AMV_ITEM_PUB.CHAR_TAB_TYPE();
       FOR i IN 1..p_keyword_varray.COUNT LOOP
          l_char_tab.extend;
          l_char_tab(i) := p_keyword_varray(i);
       END LOOP;
    END IF;
    -- Now call jtf procedure to do the job.
    JTF_AMV_ITEM_PUB.Delete_ItemKeyword
    (
       p_api_version       =>  p_api_version,
       p_init_msg_list     =>  FND_API.G_FALSE,
       p_commit            =>  p_commit,
       x_return_status     =>  x_return_status,
       x_msg_count         =>  x_msg_count,
       x_msg_data          =>  x_msg_data,
       p_item_id           =>  p_item_id,
       p_keyword_tab       =>  l_char_tab
    );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Delete_ItemKeyword_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Delete_ItemKeyword_Pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Delete_ItemKeyword_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Delete_ItemKeyword;
--------------------------------------------------------------------------------
PROCEDURE Delete_ItemKeyword
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_keyword           IN  VARCHAR2
) AS
l_char_varray           AMV_CHAR_VARRAY_TYPE;
BEGIN
    l_char_varray := AMV_CHAR_VARRAY_TYPE();
    l_char_varray.extend;
    l_char_varray(1) := p_keyword;
    --
    Delete_ItemKeyword
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit            => p_commit,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_check_login_user  => p_check_login_user,
        p_item_id           => p_item_id,
        p_keyword_varray    => l_char_varray
    );
END Delete_ItemKeyword;
--------------------------------------------------------------------------------
PROCEDURE Replace_ItemKeyword
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_keyword_varray    IN  AMV_CHAR_VARRAY_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Replace_ItemKeyword';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Replace_ItemKeyword_Pub;
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
              FND_MSG_PUB.ADD;
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- Delete all the item's original keyword
    JTF_AMV_ITEM_PUB.Delete_ItemKeyword
    (
       p_api_version       =>  p_api_version,
       p_init_msg_list     =>  FND_API.G_FALSE,
       p_commit            =>  FND_API.G_FALSE,
       x_return_status     =>  x_return_status,
       x_msg_count         =>  x_msg_count,
       x_msg_data          =>  x_msg_data,
       p_item_id           =>  p_item_id,
       p_keyword_tab       =>  NULL
    );
    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- now add the new keywords
    Add_ItemKeyword
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => FND_API.G_FALSE,
        p_commit            => p_commit,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_check_login_user  => FND_API.G_FALSE,
        p_item_id           => p_item_id,
        p_keyword_varray    => p_keyword_varray
    );
    IF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Replace_ItemKeyword_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Replace_ItemKeyword_Pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Replace_ItemKeyword_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Replace_ItemKeyword;
--------------------------------------------------------------------------------
PROCEDURE Get_ItemKeyword
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    x_keyword_varray    OUT NOCOPY AMV_CHAR_VARRAY_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_ItemKeyword';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_char_tab             JTF_AMV_ITEM_PUB.CHAR_TAB_TYPE;
--
BEGIN
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- Now call jtf procedure to do the job.
    JTF_AMV_ITEM_PUB.Get_ItemKeyword
    (
       p_api_version       =>  p_api_version,
       p_init_msg_list     =>  FND_API.G_FALSE,
       x_return_status     =>  x_return_status,
       x_msg_count         =>  x_msg_count,
       x_msg_data          =>  x_msg_data,
       p_item_id           =>  p_item_id,
       x_keyword_tab       =>  l_char_tab
    );
    -- Get back the result in the OUT parameters.
    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        x_keyword_varray  := AMV_CHAR_VARRAY_TYPE();
        FOR i IN 1..l_char_tab.COUNT LOOP
            x_keyword_varray.extend;
            x_keyword_varray(i) := l_char_tab(i);
        END LOOP;
    END IF;
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Get_ItemKeyword;
--------------------------------------------------------------------------------
------------------------------ ITEM_AUTHOR -------------------------------------
PROCEDURE Add_ItemAuthor
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_author_varray     IN  AMV_CHAR_VARRAY_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Add_ItemAuthor';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_char_tab             JTF_AMV_ITEM_PUB.CHAR_TAB_TYPE;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Add_ItemAuthor_Pub;
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
              FND_MSG_PUB.ADD;
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    IF (p_author_varray IS NOT NULL) THEN
       l_char_tab := JTF_AMV_ITEM_PUB.CHAR_TAB_TYPE();
       FOR i IN 1..p_author_varray.COUNT LOOP
          l_char_tab.extend;
          l_char_tab(i) := initcap(p_author_varray(i));
       END LOOP;
       JTF_AMV_ITEM_PUB.Add_ItemAuthor
       (
          p_api_version       =>  p_api_version,
          p_init_msg_list     =>  FND_API.G_FALSE,
          p_commit            =>  p_commit,
          x_return_status     =>  x_return_status,
          x_msg_count         =>  x_msg_count,
          x_msg_data          =>  x_msg_data,
          p_item_id           =>  p_item_id,
          p_author_tab        =>  l_char_tab
       );
    ELSE
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
       );
    END IF;
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_ItemAuthor_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_ItemAuthor_Pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_ItemAuthor_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Add_ItemAuthor;
--------------------------------------------------------------------------------
PROCEDURE Add_ItemAuthor
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_author            IN  VARCHAR2
) AS
l_char_varray           AMV_CHAR_VARRAY_TYPE;
BEGIN
    l_char_varray := AMV_CHAR_VARRAY_TYPE();
    l_char_varray.extend;
    l_char_varray(1) := p_author;
    --
    Add_ItemAuthor
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit            => p_commit,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_check_login_user  => p_check_login_user,
        p_item_id           => p_item_id,
        p_author_varray    => l_char_varray
    );
END Add_ItemAuthor;
--------------------------------------------------------------------------------
PROCEDURE Delete_ItemAuthor
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_author_varray     IN  AMV_CHAR_VARRAY_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Delete_ItemAuthor';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_char_tab             JTF_AMV_ITEM_PUB.CHAR_TAB_TYPE;
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Delete_ItemAuthor_Pub;
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
              FND_MSG_PUB.ADD;
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    IF (p_author_varray IS NULL) THEN
       l_char_tab := NULL;
    ELSE
       l_char_tab := JTF_AMV_ITEM_PUB.CHAR_TAB_TYPE();
       FOR i IN 1..p_author_varray.COUNT LOOP
          l_char_tab.extend;
          l_char_tab(i) := p_author_varray(i);
       END LOOP;
    END IF;
    -- Now call jtf procedure to do the job.
    JTF_AMV_ITEM_PUB.Delete_ItemAuthor
    (
       p_api_version       =>  p_api_version,
       p_init_msg_list     =>  FND_API.G_FALSE,
       p_commit            =>  p_commit,
       x_return_status     =>  x_return_status,
       x_msg_count         =>  x_msg_count,
       x_msg_data          =>  x_msg_data,
       p_item_id           =>  p_item_id,
       p_author_tab        =>  l_char_tab
    );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Delete_ItemAuthor_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Delete_ItemAuthor_Pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Delete_ItemAuthor_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Delete_ItemAuthor;
--------------------------------------------------------------------------------
PROCEDURE Delete_ItemAuthor
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_author            IN  VARCHAR2
) AS
l_char_varray           AMV_CHAR_VARRAY_TYPE;
BEGIN
    l_char_varray := AMV_CHAR_VARRAY_TYPE();
    l_char_varray.extend;
    l_char_varray(1) := p_author;
    --
    Delete_ItemAuthor
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit            => p_commit,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_check_login_user  => p_check_login_user,
        p_item_id           => p_item_id,
        p_author_varray    => l_char_varray
    );
END Delete_ItemAuthor;
--------------------------------------------------------------------------------
PROCEDURE Replace_ItemAuthor
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_author_varray     IN  AMV_CHAR_VARRAY_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Replace_ItemAuthor';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Replace_ItemAuthor_Pub;
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
              FND_MSG_PUB.ADD;
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- Check if item id is valid.
    IF (AMV_UTILITY_PVT.Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_ITEM_TK', TRUE);
           FND_MESSAGE.Set_Token('ID',  TO_CHAR(p_item_id));
           FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Delete all the item's original authors
    JTF_AMV_ITEM_PUB.Delete_ItemAuthor
    (
       p_api_version       =>  p_api_version,
       p_init_msg_list     =>  FND_API.G_FALSE,
       p_commit            =>  FND_API.G_FALSE,
       x_return_status     =>  x_return_status,
       x_msg_count         =>  x_msg_count,
       x_msg_data          =>  x_msg_data,
       p_item_id           =>  p_item_id,
       p_author_tab        =>  NULL
    );
    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- now add the new authors
    Add_ItemAuthor
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit            => p_commit,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_check_login_user  => p_check_login_user,
        p_item_id           => p_item_id,
        p_author_varray     => p_author_varray
    );
    IF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Replace_ItemAuthor_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Replace_ItemAuthor_Pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Replace_ItemAuthor_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Replace_ItemAuthor;
--------------------------------------------------------------------------------
PROCEDURE Get_ItemAuthor
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    x_author_varray     OUT NOCOPY AMV_CHAR_VARRAY_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_ItemAuthor';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_char_tab             JTF_AMV_ITEM_PUB.CHAR_TAB_TYPE;
--
BEGIN
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- Now call jtf procedure to do the job.
    JTF_AMV_ITEM_PUB.Get_ItemAuthor
    (
       p_api_version       =>  p_api_version,
       p_init_msg_list     =>  FND_API.G_FALSE,
       x_return_status     =>  x_return_status,
       x_msg_count         =>  x_msg_count,
       x_msg_data          =>  x_msg_data,
       p_item_id           =>  p_item_id,
       x_author_tab        =>  l_char_tab
    );
    -- Get back the result in the OUT parameters.
    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        x_author_varray  := AMV_CHAR_VARRAY_TYPE();
        FOR i IN 1..l_char_tab.COUNT LOOP
            x_author_varray.extend;
            x_author_varray(i) := l_char_tab(i);
        END LOOP;
    END IF;
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Get_ItemAuthor;
--
--------------------------------------------------------------------------------
------------------------------ ITEM_FILE ------------------------------------
PROCEDURE Add_ItemFile
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_application_id    IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
    p_item_id           IN  NUMBER,
    p_file_id_varray    IN  AMV_NUMBER_VARRAY_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Add_ItemFile';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_count                NUMBER;
l_return_status        VARCHAR2(1);
l_temp_number          NUMBER;
l_language_code        VARCHAR2(4);
l_act_attachment_rec   JTF_AMV_ATTACHMENT_PUB.ACT_ATTACHMENT_REC_TYPE;
--
CURSOR Get_FileLanguage_csr (p_file_id IN VARCHAR2) IS
SELECT
     NVL(language, USERENV('LANG'))
FROM fnd_lobs
WHERE file_id = p_file_id
--And   PROGRAM_NAME = 'MES'
--And   PROGRAM_TAG  = 'MES'
;
CURSOR Check_Itemfile_csr (p_file_id IN VARCHAR2) IS
SELECT
     file_id
FROM jtf_amv_attachments_v
WHERE  file_id = p_file_id
AND   attachment_used_by_id = p_item_id
AND   attachment_used_by = G_USED_BY_ITEM;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Add_ItemFile_Pub;
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
              FND_MSG_PUB.ADD;
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
              FND_MSG_PUB.ADD;
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
           fnd_MESSAGE.Set_Token('ID',  TO_CHAR(p_item_id));
           FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_count := p_file_id_varray.COUNT;
    FOR i IN 1..l_count LOOP
        -- Not only do we get language code, but also check if the file exists.
        OPEN  Get_FileLanguage_csr( p_file_id_varray(i) );
        FETCH Get_FileLanguage_csr INTO l_language_code;
        IF (Get_FileLanguage_csr%NOTFOUND) THEN
           CLOSE Get_FileLanguage_csr;
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
               FND_MESSAGE.Set_Token('RECORD', 'AMV_FILE_TK', TRUE);
               FND_MESSAGE.Set_Token('ID',  TO_CHAR(p_file_id_varray(i)) );
               FND_MSG_PUB.ADD;
           END IF;
           IF ( x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
        ELSE
           CLOSE Get_FileLanguage_csr;

           OPEN  Check_Itemfile_csr( p_file_id_varray(i) );
           FETCH Check_Itemfile_csr INTO l_temp_number;
           IF (Check_Itemfile_csr%FOUND) THEN
              CLOSE Check_Itemfile_csr;
              x_return_status := FND_API.G_RET_STS_ERROR;
              IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_name('AMV','AMV_ENTITY_HAS_ATTR');
                  FND_MESSAGE.Set_Token('ENTITY', 'AMV_ITEM_TK', TRUE);
                  FND_MESSAGE.Set_Token('ENTID',  TO_CHAR(p_item_id) );
                  FND_MESSAGE.Set_Token('ATTRIBUTE', 'AMV_FILE_TK', TRUE);
                  FND_MESSAGE.Set_Token('ATTRID',  p_file_id_varray(i));
                  FND_MSG_PUB.ADD;
              END IF;
              IF ( x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
           ELSE
              CLOSE Check_Itemfile_csr;
              l_act_attachment_rec.attachment_id := NULL;
              --l_act_attachment_rec.last_update_date := l_current_date;
              --l_act_attachment_rec.last_updated_by := l_current_user_id;
              --l_act_attachment_rec.creation_date := l_current_date;
              --l_act_attachment_rec.created_by := l_current_user_id;
              --l_act_attachment_rec.last_update_login := l_current_login_id;
              --l_act_attachment_rec.object_version_number := 1;
              l_act_attachment_rec.owner_user_id := NULL;
              l_act_attachment_rec.attachment_used_by_id := p_item_id;
              l_act_attachment_rec.attachment_used_by := G_USED_BY_ITEM;
              l_act_attachment_rec.version := NULL;
              l_act_attachment_rec.enabled_flag := 'Y';
              l_act_attachment_rec.can_fulfill_electronic_flag := 'N';
              l_act_attachment_rec.file_id := p_file_id_varray(i);
              l_act_attachment_rec.file_name := NULL;
              l_act_attachment_rec.file_extension := NULL;
              l_act_attachment_rec.keywords := NULL;
              l_act_attachment_rec.display_width := NULL;
              l_act_attachment_rec.display_height := NULL;
              l_act_attachment_rec.display_location := NULL;
              l_act_attachment_rec.link_to := NULL;
              l_act_attachment_rec.link_url := NULL;
              l_act_attachment_rec.send_for_preview_flag := 'N';
              l_act_attachment_rec.attachment_type := NULL;
              l_act_attachment_rec.language_code := l_language_code;
              l_act_attachment_rec.application_id := p_application_id;
              l_act_attachment_rec.description := NULL;
              l_act_attachment_rec.default_style_sheet := NULL;
              l_act_attachment_rec.display_url := NULL;
              l_act_attachment_rec.display_rule_id := NULL;
              l_act_attachment_rec.display_program := NULL;
              l_act_attachment_rec.attribute_category := NULL;
              l_act_attachment_rec.attribute1 := NULL;
              l_act_attachment_rec.attribute2 := NULL;
              l_act_attachment_rec.attribute3 := NULL;
              l_act_attachment_rec.attribute4 := NULL;
              l_act_attachment_rec.attribute5 := NULL;
              l_act_attachment_rec.attribute6 := NULL;
              l_act_attachment_rec.attribute7 := NULL;
              l_act_attachment_rec.attribute8 := NULL;
              l_act_attachment_rec.attribute9 := NULL;
              l_act_attachment_rec.attribute10 := NULL;
              l_act_attachment_rec.attribute11 := NULL;
              l_act_attachment_rec.attribute12 := NULL;
              l_act_attachment_rec.attribute13 := NULL;
              l_act_attachment_rec.attribute14 := NULL;
              l_act_attachment_rec.attribute15 := NULL;
              --
              jtf_amv_attachment_pub.create_act_attachment
              (
                 p_api_version        => p_api_version,
                 x_return_status      => l_return_status,
                 x_msg_count          => x_msg_count,
                 x_msg_data           => x_msg_data,
                 p_act_attachment_rec => l_act_attachment_rec,
                 x_act_attachment_id  => l_temp_number
              );
              IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
                     x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
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
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Add_ItemFile_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Add_ItemFile_Pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Add_ItemFile_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Add_ItemFile;
--------------------------------------------------------------------------------
PROCEDURE Add_ItemFile
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_application_id    IN  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID,
    p_item_id           IN  NUMBER,
    p_file_id           IN  NUMBER
) AS
l_number_varray           AMV_NUMBER_VARRAY_TYPE;
BEGIN
    l_number_varray := AMV_NUMBER_VARRAY_TYPE();
    l_number_varray.extend;
    l_number_varray(1) := p_file_id;
    Add_ItemFile
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit            => p_commit,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_check_login_user  => p_check_login_user,
        p_application_id    => p_application_id,
        p_item_id           => p_item_id,
        p_file_id_varray    => l_number_varray
    );
END Add_ItemFile;
--------------------------------------------------------------------------------
PROCEDURE Delete_ItemFile
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_file_id_varray    IN  AMV_NUMBER_VARRAY_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Delete_ItemFile';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_count                NUMBER;
l_temp_number          NUMBER;
l_object_version_number  NUMBER;
l_return_status        VARCHAR2(1);
--
CURSOR Check_Itemfile_csr (p_file_id IN VARCHAR2) IS
SELECT
     attachment_id, object_version_number
FROM jtf_amv_attachments_v
WHERE  file_id = p_file_id
AND   attachment_used_by_id = p_item_id
AND   attachment_used_by = G_USED_BY_ITEM;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Delete_ItemFile_Pub;
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
              FND_MSG_PUB.ADD;
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- Check if item id is valid.
    IF (AMV_UTILITY_PVT.Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_ITEM_TK', TRUE);
           FND_MESSAGE.Set_Token('ID',  TO_CHAR(p_item_id));
           FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_file_id_varray IS NOT NULL) THEN
       l_count := p_file_id_varray.COUNT;
       FOR i IN 1..l_count LOOP
           OPEN  Check_ItemFile_csr( p_file_id_varray(i) );
           FETCH Check_ItemFile_csr INTO l_temp_number, l_object_version_number;
           IF (Check_ItemFile_csr%NOTFOUND) THEN
              CLOSE Check_ItemFile_csr;
              x_return_status := FND_API.G_RET_STS_ERROR;
              IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_name('AMV','AMV_ENTITY_HAS_NOT_ATTR');
                  FND_MESSAGE.Set_Token('ENTITY', 'AMV_ITEM_TK', TRUE);
                  FND_MESSAGE.Set_Token('ENTID',  TO_CHAR(p_item_id) );
                  FND_MESSAGE.Set_Token('ATTRIBUTE', 'AMV_FILE_TK', TRUE);
                  FND_MESSAGE.Set_Token('ATTRID',
                                      TO_CHAR( p_file_id_varray(i) ) );
                  FND_MSG_PUB.ADD;
              END IF;
              IF ( x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
           ELSE
              CLOSE Check_ItemFile_csr;
              jtf_amv_attachment_pub.delete_act_attachment
              (
                 p_api_version        => p_api_version,
                 x_return_status      => l_return_status,
                 x_msg_count          => x_msg_count,
                 x_msg_data           => x_msg_data,
                 p_act_attachment_id  => l_temp_number,
                 p_object_version     => l_object_version_number
              );
              IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ELSIF (l_return_status = FND_API.G_RET_STS_ERROR AND
                     x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
           END IF;
       END LOOP;
    ELSE
       -- If no file ids specified, delete all the attached file of the item.
       DELETE FROM jtf_amv_attachments
       WHERE  attachment_used_by_id = p_item_id
       AND   attachment_used_by = G_USED_BY_ITEM;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Delete_ItemFile_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Delete_ItemFile_Pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Delete_ItemFile_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Delete_ItemFile;
--------------------------------------------------------------------------------
PROCEDURE Delete_ItemFile
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_file_id           IN  NUMBER
) AS
l_number_varray           AMV_NUMBER_VARRAY_TYPE;
BEGIN
    l_number_varray := AMV_NUMBER_VARRAY_TYPE();
    l_number_varray.extend;
    l_number_varray(1) := p_file_id;
    --
    Delete_ItemFile
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit            => p_commit,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_check_login_user  => p_check_login_user,
        p_item_id           => p_item_id,
        p_file_id_varray    => l_number_varray
    );
END Delete_ItemFile;
--------------------------------------------------------------------------------
PROCEDURE Replace_ItemFile
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    p_file_id_varray    IN  AMV_NUMBER_VARRAY_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Replace_ItemFile';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_admin_flag           VARCHAR2(1);
l_count                NUMBER;
l_temp_number          NUMBER;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Replace_ItemFile_Pub;
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
              FND_MSG_PUB.ADD;
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- Check if item id is valid.
    IF (AMV_UTILITY_PVT.Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_ITEM_TK', TRUE);
           FND_MESSAGE.Set_Token('ID',  TO_CHAR(p_item_id));
           FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Delete all the item's original files
    Delete_ItemFile
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_check_login_user  => p_check_login_user,
        p_item_id           => p_item_id,
        p_file_id_varray    => NULL
    );
    IF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    -- now add (attach) the new files
    Add_ItemFile
    (
        p_api_version       => p_api_version,
        p_commit            => p_commit,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_check_login_user  => p_check_login_user,
        p_item_id           => p_item_id,
        p_file_id_varray    => p_file_id_varray
    );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Replace_ItemFile_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Replace_ItemFile_Pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Replace_ItemFile_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Replace_ItemFile;
--------------------------------------------------------------------------------
PROCEDURE Get_ItemFile
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER,
    x_file_id_varray    OUT NOCOPY AMV_NUMBER_VARRAY_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_ItemFile';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_fetch_count          NUMBER := 0;
CURSOR Get_File_id_csr IS
SELECT
    File_id
FROM  jtf_amv_attachments_v
WHERE attachment_used_by_id = p_item_id
AND   attachment_used_by = G_USED_BY_ITEM;
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- Check if item id is valid.
    IF (AMV_UTILITY_PVT.Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('AMV','AMV_RECORD_ID_MISSING');
           FND_MESSAGE.Set_Token('RECORD', 'AMV_ITEM_TK', TRUE);
           FND_MESSAGE.Set_Token('ID',  TO_CHAR(p_item_id));
           FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    --Execute the SQL statements to get records
    x_file_id_varray  := AMV_NUMBER_VARRAY_TYPE();
    FOR rec IN Get_File_id_csr LOOP
        l_fetch_count := l_fetch_count + 1;
        x_file_id_varray.extend;
        x_file_id_varray(l_fetch_count) := rec.file_id;
    END LOOP;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Get_ItemFile;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE Get_UserMessage
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_user_id           IN  NUMBER,
    x_item_id_varray    OUT NOCOPY AMV_NUMBER_VARRAY_TYPE,
    x_message_varray    OUT NOCOPY AMV_CHAR_VARRAY_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_UserMessage';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_count                NUMBER;
--
CURSOR Get_Message_csr IS
SELECT
      item.item_id,
      item.item_name
FROM  jtf_amv_items_vl item, amv_c_chl_item_match match,
      amv_u_my_channels mych
WHERE item.item_type = 'MESSAGE_ITEM'
AND  item.item_id = match.item_id
AND  match.table_name_code = 'ITEM'
AND  match.approval_status_type = 'APPROVED'
AND  match.channel_id = mych.subscribing_to_id
AND  mych.subscribing_to_type = 'CHANNEL'
AND  mych.subscription_reason_type = 'ENFORCED'
AND  mych.user_or_group_type = 'USER'
AND  mych.user_or_group_id = p_user_id
UNION
SELECT
      item.item_id,
      item.item_name
FROM  jtf_amv_items_vl item, amv_c_chl_item_match match,
      amv_u_my_channels mych, jtf_rs_group_members mem,
      jtf_rs_groups_vl g
WHERE item.item_type = 'MESSAGE_ITEM'
AND  item.item_id = match.item_id
AND  match.table_name_code = 'ITEM'
AND  match.approval_status_type = 'APPROVED'
AND  match.channel_id = mych.subscribing_to_id
AND  mych.user_or_group_type = 'GROUP'
AND  mych.subscribing_to_type = 'CHANNEL'
AND  mych.subscription_reason_type = 'ENFORCED'
AND  mych.user_or_group_id = mem.group_id
AND  mem.delete_flag <> 'Y'
AND  mem.resource_id = p_user_id
AND  mem.group_id = g.group_id
AND  g.start_date_active <= SYSDATE
AND  NVL(g.end_date_active, SYSDATE+1) > SYSDATE
;
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    x_item_id_varray := AMV_NUMBER_VARRAY_TYPE();
    x_message_varray := AMV_CHAR_VARRAY_TYPE();
    l_count := 0;
    FOR cur IN  Get_Message_csr LOOP
      l_count := l_count + 1;
      x_item_id_varray.extend;
      x_item_id_varray(l_count) := cur.item_id;
      x_message_varray.extend;
      x_message_varray(l_count) := cur.item_name;
    END LOOP;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Get_UserMessage;
--------------------------------------------------------------------------------
PROCEDURE Get_UserMessage2
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_user_id           IN  NUMBER,
    x_item_varray       OUT NOCOPY AMV_SIMPLE_ITEM_OBJ_VARRAY
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_UserMessage';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_count                NUMBER;
--
CURSOR Get_Message_csr IS
SELECT
      item.item_id,
      item.object_version_number,
      item.creation_date,
      item.created_by,
      item.last_update_date,
      item.last_updated_by,
      item.last_update_login,
      item.application_id,
      item.external_access_flag,
      item.item_name,
      item.description,
      item.text_string,
      item.language_code,
      item.status_code,
      item.effective_start_date,
      item.expiration_date,
      item.item_type,
      item.url_string,
      item.publication_date,
      item.priority,
      item.content_type_id,
      item.owner_id,
      item.default_approver_id,
      item.item_destination_type
FROM  jtf_amv_items_vl item, amv_c_chl_item_match match,
      amv_u_my_channels mych
WHERE item.item_type = 'MESSAGE_ITEM'
AND  item.item_id = match.item_id
AND  match.table_name_code = 'ITEM'
AND  match.approval_status_type = 'APPROVED'
AND  match.channel_id = mych.subscribing_to_id
AND  mych.subscribing_to_type = 'CHANNEL'
AND  mych.subscription_reason_type = 'ENFORCED'
AND  mych.user_or_group_type = 'USER'
AND  mych.user_or_group_id = p_user_id
UNION
SELECT
      item.item_id,
      item.object_version_number,
      item.creation_date,
      item.created_by,
      item.last_update_date,
      item.last_updated_by,
      item.last_update_login,
      item.application_id,
      item.external_access_flag,
      item.item_name,
      item.description,
      item.text_string,
      item.language_code,
      item.status_code,
      item.effective_start_date,
      item.expiration_date,
      item.item_type,
      item.url_string,
      item.publication_date,
      item.priority,
      item.content_type_id,
      item.owner_id,
      item.default_approver_id,
      item.item_destination_type
FROM  jtf_amv_items_vl item, amv_c_chl_item_match match,
      amv_u_my_channels mych, jtf_rs_group_members mem,
      jtf_rs_groups_vl g
WHERE item.item_type = 'MESSAGE_ITEM'
AND  item.item_id = match.item_id
AND  match.table_name_code = 'ITEM'
AND  match.approval_status_type = 'APPROVED'
AND  match.channel_id = mych.subscribing_to_id
AND  mych.user_or_group_type = 'GROUP'
AND  mych.subscribing_to_type = 'CHANNEL'
AND  mych.subscription_reason_type = 'ENFORCED'
AND  mych.user_or_group_id = mem.group_id
AND  mem.delete_flag <> 'Y'
AND  mem.resource_id = p_user_id
AND  mem.group_id = g.group_id
AND  g.start_date_active <= SYSDATE
AND  NVL(g.end_date_active, SYSDATE+1) > SYSDATE
;
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    x_item_varray  := AMV_SIMPLE_ITEM_OBJ_VARRAY();
    l_count := 0;
    FOR cur IN  Get_Message_csr LOOP
      l_count := l_count + 1;
      x_item_varray.extend;
      x_item_varray(l_count).item_id :=  cur.item_id;
      x_item_varray(l_count).object_version_number := cur.OBJECT_VERSION_NUMBER;
      x_item_varray(l_count).creation_date := cur.CREATION_DATE;
      x_item_varray(l_count).created_by := cur.CREATED_BY;
      x_item_varray(l_count).last_update_date := cur.LAST_UPDATE_DATE;
      x_item_varray(l_count).last_updated_by := cur.LAST_UPDATED_BY;
      x_item_varray(l_count).last_update_login := cur.LAST_UPDATE_LOGIN;
      x_item_varray(l_count).application_id := cur.APPLICATION_ID;
      x_item_varray(l_count).external_access_flag := cur.EXTERNAL_ACCESS_FLAG;
      x_item_varray(l_count).item_name := cur.ITEM_NAME;
      x_item_varray(l_count).description := cur.DESCRIPTION;
      x_item_varray(l_count).text_string := cur.TEXT_STRING;
      x_item_varray(l_count).language_code := cur.LANGUAGE_CODE;
      x_item_varray(l_count).status_code := cur.STATUS_CODE;
      x_item_varray(l_count).effective_start_date := cur.EFFECTIVE_START_DATE;
      x_item_varray(l_count).expiration_date := cur.EXPIRATION_DATE;
      x_item_varray(l_count).item_type := cur.ITEM_TYPE;
      x_item_varray(l_count).url_string := cur.URL_STRING;
      x_item_varray(l_count).publication_date := cur.PUBLICATION_DATE;
      x_item_varray(l_count).priority := cur.PRIORITY;
      x_item_varray(l_count).content_type_id := cur.CONTENT_TYPE_ID;
      x_item_varray(l_count).owner_id := cur.OWNER_ID;
      x_item_varray(l_count).default_approver_id := cur.DEFAULT_APPROVER_ID;
      x_item_varray(l_count).item_destination_type := cur.ITEM_DESTINATION_TYPE;
	 x_item_varray(l_count).file_id_list := ' ';
	 x_item_varray(l_count).persp_id_list := ' ';
	 x_item_varray(l_count).persp_name_list := ' ';
	 x_item_varray(l_count).author_list := ' ';
	 x_item_varray(l_count).keyword_list := ' ';
    END LOOP;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Get_UserMessage2;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_ChannelsPerItem
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Query and return all the channels matched the specified item
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_match_type                       VARCHAR2  Optional
--                 p_item_id                          NUMBER    Required
--                    The item id to be add the files.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_channel_array                    AMV_NAMEID_VARRAY_TYPE
--                    file id array for all the files of the item.
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_ChannelsPerItem
(
 p_api_version       IN  NUMBER,
 p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
 x_return_status     OUT NOCOPY VARCHAR2,
 x_msg_count         OUT NOCOPY NUMBER,
 x_msg_data          OUT NOCOPY VARCHAR2,
 p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
 p_item_id           IN  NUMBER,
 p_match_type        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 x_channel_array     OUT NOCOPY AMV_NAMEID_VARRAY_TYPE
) AS

l_api_name             CONSTANT VARCHAR2(30) := 'Get_ChannelsPerItem';
l_api_version          CONSTANT NUMBER := 1.0;
l_resource_id          NUMBER  := -1;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  VARCHAR2(80);
--
l_channel_id	      NUMBER;
l_channel_name	      VARCHAR2(80);
l_count               NUMBER := 1;
l_all_match	VARCHAR2(60) := ''''||AMV_UTILITY_PVT.G_MATCH||''','''||AMV_UTILITY_PVT.G_PUSH||'''';
--
CURSOR GetChannels_csr IS
select c.channel_id
,      c.channel_name
from   amv_c_channels_vl c
,      amv_c_chl_item_match m
where  m.item_id = p_item_id
and    m.channel_id = c.channel_id
and	  c.channel_type = amv_utility_pvt.g_content
and	  c.access_level_type = amv_utility_pvt.g_public
and    m.approval_status_type = AMV_UTILITY_PVT.G_APPROVED
and    m.table_name_code = amv_utility_pvt.g_table_name_code
and    decode(p_match_type, FND_API.G_MISS_CHAR, p_match_type, m.available_due_to_type) = p_match_type;
--and    m.available_due_to_type in (decode(p_match_type,FND_API.G_MISS_CHAR,l_all_match,p_match_type));
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
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    --
    x_channel_array := AMV_NAMEID_VARRAY_TYPE();
    OPEN GetChannels_csr;
      LOOP
      	FETCH GetChannels_csr INTO l_channel_id, l_channel_name;
      	EXIT WHEN GetChannels_csr%NOTFOUND;
	x_channel_array.extend;
	x_channel_array(l_count).id := l_channel_id;
	x_channel_array(l_count).name := l_channel_name;
	l_count := l_count + 1;
      END LOOP;
    CLOSE GetChannels_csr;
    --

    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
    WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
END Get_ChannelsPerItem;
--------------------------------------------------------------------------------
END amv_item_pub;

/
