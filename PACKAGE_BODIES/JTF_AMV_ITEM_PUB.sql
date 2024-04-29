--------------------------------------------------------
--  DDL for Package Body JTF_AMV_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AMV_ITEM_PUB" AS
/*  $Header: jtfpitmb.pls 115.8 2002/11/26 19:15:41 stopiwal ship $ */
--
-- NAME
--   JTF_AMV_ITEM_PUB
--
-- HISTORY
--   11/30/1999        PWU        CREATED
--
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'JTF_AMV_ITEM_PUB';
G_FILE_NAME         CONSTANT VARCHAR2(12) := 'jtfpitmb.pls';
--
G_EMP_RES_CATE      CONSTANT VARCHAR2(30) := 'EMPLOYEE';
G_USED_BY_ITEM      CONSTANT VARCHAR2(30) := 'ITEM';
G_MES_APPL_ID       CONSTANT NUMBER := 520;
-- G_ISTORE_APPL_ID    CONSTANT NUMBER := 671; --short name 'IBE'
--
TYPE    CursorType    IS REF CURSOR;
--
--------------------------------------------------------------------------------
------------------------------- Private Proceudre ------------------------------
FUNCTION CURRENT_USER_ID return number AS
BEGIN
    return FND_GLOBAL.user_id;
END CURRENT_USER_ID;
--
FUNCTION CURRENT_LOGIN_ID return number AS
BEGIN
    return FND_GLOBAL.conc_login_id;
END CURRENT_LOGIN_ID;

FUNCTION check_lookup_exists(
   p_lookup_table_name  IN VARCHAR2 := 'FND_LOOKUP_VALUES',
   p_lookup_type        IN VARCHAR2,
   p_lookup_code        IN VARCHAR2
) Return VARCHAR2 AS
   l_sql   VARCHAR2(200);
   l_count NUMBER;
BEGIN
   l_sql := 'SELECT COUNT(*) FROM ' || p_lookup_table_name;
   l_sql := l_sql || ' WHERE lookup_type = ''' || p_lookup_type ||'''';
   l_sql := l_sql || ' AND lookup_code = ''' || p_lookup_code ||'''';
   l_sql := l_sql || ' AND enabled_flag = ''Y''';

   EXECUTE IMMEDIATE l_sql INTO l_count;

   IF l_count = 0 THEN
      RETURN FND_API.g_false;
   ELSE
      RETURN FND_API.g_true;
   END IF;
END check_lookup_exists;

FUNCTION Is_ApplIdValid
(
    p_application_id IN NUMBER
) RETURN Boolean  AS
--
CURSOR Check_ApplicationID_csr is
Select application_id
From   fnd_application
where  application_id = p_application_id;
l_valid_flag  BOOLEAN := FALSE;
l_tmp_number  NUMBER;
--
BEGIN
  OPEN  Check_ApplicationID_csr;
  FETCH Check_ApplicationID_csr INTO l_tmp_number;
  IF (Check_ApplicationID_csr%NOTFOUND) THEN
      l_valid_flag := FALSE;
  ELSE
      l_valid_flag := TRUE;
  END IF;
  CLOSE Check_ApplicationID_csr;
  return l_valid_flag;
END Is_ApplIdValid;
--------------------------------------------------------------------------------
FUNCTION Is_ItemIdValid
(
    p_item_id IN NUMBER
) RETURN Boolean  AS
--
CURSOR Check_ItemID_csr is
Select item_id
From   jtf_amv_items_b
where  item_id = p_item_id;
l_valid_flag  BOOLEAN := FALSE;
l_tmp_number  NUMBER;
--
BEGIN
  OPEN  Check_ItemID_csr;
  FETCH Check_ItemID_csr INTO l_tmp_number;
  IF (Check_ItemID_csr%NOTFOUND) THEN
     l_valid_flag := FALSE;
  ELSE
     l_valid_flag := TRUE;
  END IF;
  CLOSE Check_ItemID_csr;
  return l_valid_flag;
END Is_ItemIdValid;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE Create_Item
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_item_rec          IN  ITEM_REC_TYPE,
    x_item_id           OUT NOCOPY  NUMBER
)  IS
l_api_name             CONSTANT VARCHAR2(30) := 'Create_Item';
l_api_version          CONSTANT NUMBER := 1.0;
--
l_row_id               VARCHAR2(500);
l_current_date         DATE;
l_item_rec             ITEM_REC_TYPE := p_item_rec;
--
CURSOR Get_DateAndId_csr IS
select
      JTF_AMV_ITEMS_B_S.nextval, sysdate
from dual;
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
    -- Check if application id of the item record is valid
    IF (Is_ApplIdValid(l_item_rec.application_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('JTF','JTF_AMV_APPLICATIONID_INVALID');
           FND_MESSAGE.Set_Token('ID',
               to_char( nvl(l_item_rec.application_id, -1) ) );
           FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    -- Get the item id from sequence and date from current date.
    OPEN  Get_DateAndId_csr;
    FETCH Get_DateAndId_csr Into l_item_rec.item_id, l_current_date;
    CLOSE Get_DateAndId_csr;
    -- set version number to 1.
    l_item_rec.object_version_number := 1;
    IF (l_item_rec.external_access_flag <> FND_API.G_TRUE OR
        l_item_rec.external_access_flag IS NULL) THEN
        l_item_rec.external_access_flag := FND_API.G_FALSE;
    END IF;
    IF (l_item_rec.item_name is null OR
        l_item_rec.item_name = FND_API.G_MISS_CHAR) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_NAME_NULL');
           FND_MSG_PUB.Add;
       END IF;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;
    IF (l_item_rec.description = FND_API.G_MISS_CHAR) THEN
        l_item_rec.description := null;
    END IF;
    IF (l_item_rec.text_string = FND_API.G_MISS_CHAR) THEN
        l_item_rec.text_string := null;
    END IF;
    IF (l_item_rec.language_code = FND_API.G_MISS_CHAR OR
        l_item_rec.language_code IS NULL) THEN
        l_item_rec.language_code := USERENV('LANG');
    END IF;
    IF (l_item_rec.status_code is null OR
        l_item_rec.status_code = FND_API.G_MISS_CHAR) THEN
        l_item_rec.status_code := 'ACTIVE';
    END IF;
    IF (l_item_rec.effective_start_date = FND_API.G_MISS_DATE) THEN
        l_item_rec.effective_start_date := null;
    END IF;
    IF (l_item_rec.expiration_date = FND_API.G_MISS_DATE) THEN
        l_item_rec.expiration_date := null;
    END IF;
    IF (l_item_rec.item_type = FND_API.G_MISS_CHAR) THEN
        l_item_rec.item_type := null;
    END IF;
    IF (l_item_rec.url_string = FND_API.G_MISS_CHAR) THEN
        l_item_rec.url_string := null;
    END IF;
    IF (l_item_rec.publication_date = FND_API.G_MISS_DATE) THEN
        l_item_rec.publication_date := null;
    END IF;
    IF (l_item_rec.priority = FND_API.G_MISS_CHAR) THEN
        l_item_rec.priority := null;
    END IF;
    IF (l_item_rec.content_type_id = FND_API.G_MISS_NUM) THEN
        l_item_rec.content_type_id := null;
    END IF;
    IF (l_item_rec.owner_id = FND_API.G_MISS_NUM) THEN
        l_item_rec.owner_id := null;
    END IF;
    IF (l_item_rec.default_approver_id = FND_API.G_MISS_NUM) THEN
        l_item_rec.default_approver_id := null;
    END IF;
    IF (l_item_rec.item_destination_type = FND_API.G_MISS_CHAR) THEN
        l_item_rec.item_destination_type := null;
    END IF;
    IF (l_item_rec.access_name = FND_API.G_MISS_CHAR) THEN
        l_item_rec.access_name := null;
    END IF;
    IF (l_item_rec.deliverable_type_code = FND_API.G_MISS_CHAR) THEN
        l_item_rec.deliverable_type_code := null;
    END IF;
    IF (l_item_rec.applicable_to_code = FND_API.G_MISS_CHAR) THEN
        l_item_rec.applicable_to_code := null;
    END IF;
    -- If called from MES (MES has its own requirement)
    IF (l_item_rec.application_id = G_MES_APPL_ID) THEN
        -- Check if item type in the item record is null
        IF (l_item_rec.item_type IS NULL ) THEN
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('JTF','JTF_AMV_NULL_ITEM_TYPE');
               FND_MSG_PUB.Add;
           END IF;
           RAISE  FND_API.G_EXC_ERROR;
        END IF;

        -- Check if effective start date in the item object is null
        -- If so, make it effective immediately.
        IF (l_item_rec.effective_start_date is null) THEN
           l_item_rec.effective_start_date := sysdate;
        END IF;
        -- Check if priority in the item object is null
        -- Maybe we should check if the priority is valid
        IF (l_item_rec.priority is null ) THEN
           l_item_rec.priority := 'LOW';
        END IF;
/*
    ELSIF (l_item_rec.application_id = G_ISTORE_APPL_ID ) THEN
       IF (l_item_rec.access_name is null ) THEN
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('JTF','JTF_AMV_ACCESS_NAME_MISSING');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
       IF (l_item_rec.deliverable_type_code is null ) THEN
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('JTF','JTF_AMV_TYPE_CODE_NULL');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       ELSE
          IF check_lookup_exists
             (
               p_lookup_type  => 'JTF_AMV_DELV_TYPE_CODE',
               p_lookup_code  => l_item_rec.deliverable_type_code
             ) = FND_API.G_FALSE THEN
             IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_name('JTF','JTF_AMV_TYPE_CODE_WRONG');
                 FND_MSG_PUB.Add;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;
       IF (l_item_rec.applicable_to_code is null ) THEN
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('JTF','JTF_AMV_APPLICABLE_CODE_NULL');
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       ELSE
          IF check_lookup_exists
             (
               p_lookup_type  => 'JTF_AMV_APPLI_TO_CODE',
               p_lookup_code  => l_item_rec.applicable_to_code
             ) = FND_API.G_FALSE THEN
             IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_name('JTF','JTF_AMV_APPL_TO_CODE_WRONG');
                 FND_MSG_PUB.Add;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;
    */
    END IF; --END OF (OUTER) IF
    --Do create the record now.
    JTF_AMV_ITEMS_PKG.INSERT_ROW
    (
        X_ROWID => l_row_id,
        X_ITEM_ID =>l_item_rec.item_id,
        X_OBJECT_VERSION_NUMBER => 1,
        X_CREATION_DATE => l_current_date,
        X_CREATED_BY    => CURRENT_USER_ID,
        X_LAST_UPDATE_DATE => l_current_date,
        X_LAST_UPDATED_BY => CURRENT_USER_ID,
        X_LAST_UPDATE_LOGIN => CURRENT_LOGIN_ID,
        X_APPLICATION_ID => l_item_rec.application_id,
        X_EXTERNAL_ACCESS_FLAG => l_item_rec.external_access_flag,
        X_ITEM_NAME => l_item_rec.item_name,
        X_DESCRIPTION => l_item_rec.description,
        X_TEXT_STRING => l_item_rec.text_string,
        X_LANGUAGE_CODE => l_item_rec.language_code,
        X_STATUS_CODE => l_item_rec.status_code,
        X_EFFECTIVE_START_DATE => l_item_rec.effective_start_date,
        X_EXPIRATION_DATE => l_item_rec.expiration_date,
        X_ITEM_TYPE => l_item_rec.item_type,
        X_URL_STRING => l_item_rec.url_string,
        X_PUBLICATION_DATE => l_item_rec.publication_date,
        X_PRIORITY => l_item_rec.priority,
        X_CONTENT_TYPE_ID => l_item_rec.content_type_id,
        X_OWNER_ID => l_item_rec.owner_id,
        X_DEFAULT_APPROVER_ID => l_item_rec.default_approver_id,
        X_ITEM_DESTINATION_TYPE => l_item_rec.item_destination_type,
        X_ACCESS_NAME => l_item_rec.access_name,
        X_DELIVERABLE_TYPE_CODE => l_item_rec.deliverable_type_code,
        X_APPLICABLE_TO_CODE => l_item_rec.applicable_to_code,
        X_ATTRIBUTE_CATEGORY => null,
        X_ATTRIBUTE1 => null,
        X_ATTRIBUTE2 => null,
        X_ATTRIBUTE3 => null,
        X_ATTRIBUTE4 => null,
        X_ATTRIBUTE5 => null,
        X_ATTRIBUTE6 => null,
        X_ATTRIBUTE7 => null,
        X_ATTRIBUTE8 => null,
        X_ATTRIBUTE9 => null,
        X_ATTRIBUTE10 => null,
        X_ATTRIBUTE11 => null,
        X_ATTRIBUTE12 => null,
        X_ATTRIBUTE13 => null,
        X_ATTRIBUTE14 => null,
        X_ATTRIBUTE15 => null
    );
    -- pass back the item id.
    x_item_id := l_item_rec.item_id;
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
       ROLLBACK TO Create_Item_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Create_Item_Pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO Create_Item_Pub;
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_item_id           IN  NUMBER
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Delete_Item';
l_api_version          CONSTANT NUMBER := 1.0;
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
    -- Check if item id is valid.
    IF (Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_RECORD_MISSING');
           FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_item_id, -1) ));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Delete the item's authors.
    Delete from jtf_amv_item_authors
    where item_id = p_item_id;
    -- Delete the item's keywords.
    Delete from jtf_amv_item_keywords
    where item_id = p_item_id;
    -- Remove item's files.
    Delete from jtf_amv_attachments
    where attachment_used_by_id = p_item_id
    and   attachment_used_by = G_USED_BY_ITEM;
    -- Finally delete the item itself.
    JTF_AMV_ITEMS_PKG.DELETE_ROW ( p_item_id );
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_item_rec          IN  ITEM_REC_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Update_Item';
l_api_version          CONSTANT NUMBER := 1.0;
--
l_item_id              NUMBER;
l_current_date         DATE;
l_new_item_rec         ITEM_REC_TYPE := p_item_rec;
l_old_item_rec         ITEM_REC_TYPE;
l_record_change_flag   boolean  := false;
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
    --  MAKE SURE THE PASSED ITEM RECORD HAS ALL THE RIGHT INFORMATION.
    -- Get the original record data
    Get_Item
    (
      p_api_version       => p_api_version,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data,
      p_item_id           => p_item_rec.item_id,
      x_item_rec          => l_old_item_rec
    );
    -- Check if item id is valid.
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Check to see if the record has been changed,
    -- via compare object version number.
    IF (l_old_item_rec.object_version_number =
       l_new_item_rec.object_version_number) THEN
       l_new_item_rec.object_version_number :=
          l_new_item_rec.object_version_number +1;
    ELSE
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_RECORD_CHANGED');
           FND_MESSAGE.Set_Token('ID',
              to_char(nvl(l_new_item_rec.item_id,-1)) );
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    --Checking application id.
    IF ( l_new_item_rec.application_id IS NULL  OR
       l_new_item_rec.application_id = FND_API.G_MISS_NUM OR
       l_new_item_rec.application_id = l_old_item_rec.application_id) THEN
       l_new_item_rec.application_id := l_old_item_rec.application_id;
    ELSE
       -- Check if application in the item object is valid
       l_record_change_flag := true;
       IF (Is_ApplIdValid(l_new_item_rec.application_id) <> TRUE) THEN
          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_name('JTF','JTF_AMV_APPLICATIONID_INVALID');
              FND_MESSAGE.Set_Token('ID',
                  to_char( l_new_item_rec.application_id ) );
              FND_MSG_PUB.Add;
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    --Checking external access flag
    If (l_new_item_rec.external_access_flag is NULL OR
          l_new_item_rec.external_access_flag =
          l_old_item_rec.external_access_flag OR
        l_new_item_rec.external_access_flag = FND_API.G_MISS_CHAR ) THEN
        l_new_item_rec.external_access_flag :=
              l_old_item_rec.external_access_flag;
    ELSE
       IF (l_new_item_rec.external_access_flag <> FND_API.G_TRUE) THEN
           l_new_item_rec.external_access_flag := FND_API.G_FALSE;
       END IF;
       IF (l_new_item_rec.external_access_flag <>
           l_old_item_rec.external_access_flag) THEN
           l_record_change_flag := true;
       END IF;
    END IF;
    --Checking item name, which is translatable so default to G_MISS
    If (l_new_item_rec.item_name is NULL OR
        l_new_item_rec.item_name = FND_API.G_MISS_CHAR  OR
        l_new_item_rec.item_name = l_old_item_rec.item_name) THEN
       l_new_item_rec.item_name := FND_API.G_MISS_CHAR;
    ELSE
       l_record_change_flag := true;
    END IF;
    --Checking description which is translatable so default to G_MISS
    IF ( l_new_item_rec.description = FND_API.G_MISS_CHAR  OR
         l_new_item_rec.description IS NULL AND
         l_old_item_rec.description IS NULL        OR
       l_new_item_rec.description = l_old_item_rec.description) THEN
       l_new_item_rec.description := FND_API.G_MISS_CHAR;
    ELSE
       l_record_change_flag := true;
    END IF;
    --Checking text string which is translatable so default to G_MISS
    IF ( l_new_item_rec.text_string = FND_API.G_MISS_CHAR  OR
         l_new_item_rec.text_string IS NULL AND
         l_old_item_rec.text_string IS NULL        OR
       l_new_item_rec.text_string = l_old_item_rec.text_string) THEN
       l_new_item_rec.text_string := FND_API.G_MISS_CHAR;
    ELSE
       l_record_change_flag := true;
    END IF;
    --Checking language code
    IF ( l_new_item_rec.language_code IS NULL OR
       l_new_item_rec.language_code = FND_API.G_MISS_CHAR  OR
       l_new_item_rec.language_code = l_old_item_rec.language_code) THEN
       l_new_item_rec.language_code := l_old_item_rec.language_code;
    ELSE
       l_record_change_flag := true;
    END IF;
    --Checking status code
    IF ( l_new_item_rec.status_code IS NULL OR
       l_new_item_rec.status_code = FND_API.G_MISS_CHAR  OR
       l_new_item_rec.status_code = l_old_item_rec.status_code) THEN
       l_new_item_rec.status_code := l_old_item_rec.status_code;
    ELSE
       l_record_change_flag := true;
    END IF;
    --Checking starting date.
    If ( l_new_item_rec.effective_start_date = FND_API.G_MISS_DATE  OR
            l_new_item_rec.effective_start_date is NULL AND
            l_old_item_rec.effective_start_date is NULL OR
            l_new_item_rec.effective_start_date =
            l_old_item_rec.effective_start_date) THEN
       l_new_item_rec.effective_start_date :=
           l_old_item_rec.effective_start_date;
    ELSE
       l_record_change_flag := true;
    END IF;
    --Checking end date.
    IF ( l_new_item_rec.expiration_date = FND_API.G_MISS_DATE  OR
            l_new_item_rec.expiration_date is NULL AND
            l_old_item_rec.expiration_date is NULL     OR
            l_new_item_rec.expiration_date =
            l_old_item_rec.expiration_date) THEN
       l_new_item_rec.expiration_date := l_old_item_rec.expiration_date;
    ELSE
       l_record_change_flag := true;
    END IF;
    --Checking item type
    IF (l_new_item_rec.item_type = FND_API.G_MISS_CHAR  OR
       l_new_item_rec.item_type is null and
       l_old_item_rec.item_type is null      OR
       l_new_item_rec.item_type = l_old_item_rec.item_type) THEN
       l_new_item_rec.item_type := l_old_item_rec.item_type;
    ELSE
       l_record_change_flag := true;
    END IF;
    --Checking URL
    IF ( l_new_item_rec.url_string = FND_API.G_MISS_CHAR  OR
       l_new_item_rec.url_string IS NULL AND
       l_old_item_rec.url_string IS NULL         OR
       l_new_item_rec.url_string = l_old_item_rec.url_string) THEN
       l_new_item_rec.url_string := l_old_item_rec.url_string;
    ELSE
       l_record_change_flag := true;
    END IF;
    --Checking publication date
    IF ( l_new_item_rec.publication_date = FND_API.G_MISS_DATE  OR
            l_new_item_rec.publication_date IS NULL AND
            l_old_item_rec.publication_date IS NULL      OR
            l_new_item_rec.publication_date =
            l_old_item_rec.publication_date) THEN
       l_new_item_rec.publication_date := l_old_item_rec.publication_date;
    ELSE
       l_record_change_flag := true;
    END IF;
    --Checking priority
    IF ( l_new_item_rec.priority = FND_API.G_MISS_CHAR  OR
       l_new_item_rec.priority IS NULL  AND
       l_old_item_rec.priority IS NULL       OR
       l_new_item_rec.priority = l_old_item_rec.priority) THEN
       l_new_item_rec.priority := l_old_item_rec.priority;
    ELSE
       l_record_change_flag := true;
    END IF;
    --Checking content type id.
    IF ( l_new_item_rec.content_type_id = FND_API.G_MISS_NUM  OR
        l_new_item_rec.content_type_id is NULL AND
        l_old_item_rec.content_type_id is NULL     OR
       l_new_item_rec.content_type_id = l_old_item_rec.content_type_id) THEN
       l_new_item_rec.content_type_id := l_old_item_rec.content_type_id;
    ELSE
       l_record_change_flag := true;
    END IF;
    --Checking owner user id.
    IF ( l_new_item_rec.owner_id = FND_API.G_MISS_NUM  OR
       l_new_item_rec.owner_id IS NULL AND
       l_old_item_rec.owner_id IS NULL     OR
       l_new_item_rec.owner_id = l_old_item_rec.owner_id) THEN
       l_new_item_rec.owner_id := l_old_item_rec.owner_id;
    ELSE
       l_record_change_flag := true;
    END IF;
    --Checking default approver user id.
    IF ( l_new_item_rec.default_approver_id = FND_API.G_MISS_NUM  OR
       l_new_item_rec.default_approver_id IS NULL AND
       l_old_item_rec.default_approver_id IS NULL      OR
       l_new_item_rec.default_approver_id =
       l_old_item_rec.default_approver_id) THEN
       l_new_item_rec.default_approver_id := l_old_item_rec.default_approver_id;
    ELSE
       l_record_change_flag := true;
    END IF;
    --Checking destination type
    IF ( l_new_item_rec.item_destination_type = FND_API.G_MISS_CHAR  OR
       l_new_item_rec.item_destination_type IS NULL AND
       l_old_item_rec.item_destination_type IS NULL     OR
       l_new_item_rec.item_destination_type =
       l_old_item_rec.item_destination_type) THEN
       l_new_item_rec.item_destination_type :=
          l_old_item_rec.item_destination_type;
    ELSE
       l_record_change_flag := true;
    END IF;
    --Checking access name
    IF ( l_new_item_rec.access_name = FND_API.G_MISS_CHAR  OR
       l_new_item_rec.access_name IS NULL AND
       l_old_item_rec.access_name IS NULL     OR
       l_new_item_rec.access_name =
       l_old_item_rec.access_name) THEN
       l_new_item_rec.access_name := l_old_item_rec.access_name;
    ELSE
       l_record_change_flag := true;
       /*
       -- Istore specific.
       IF (l_new_item_rec.application_id = G_ISTORE_APPL_ID OR
           l_new_item_rec.application_id = FND_API.G_MISS_CHAR and
           l_old_item_rec.application_id = G_ISTORE_APPL_ID ) THEN
          IF (l_new_item_rec.access_name IS NULL) THEN
             IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_name('JTF','JTF_AMV_ACCESS_NAME_MISSING');
                 FND_MSG_PUB.Add;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;
       */
    END IF;
    --Checking deliverable type code.
    IF ( l_new_item_rec.deliverable_type_code = FND_API.G_MISS_CHAR  OR
       l_new_item_rec.deliverable_type_code IS NULL AND
       l_old_item_rec.deliverable_type_code IS NULL     OR
       l_new_item_rec.deliverable_type_code =
       l_old_item_rec.deliverable_type_code) THEN
       l_new_item_rec.deliverable_type_code :=
             l_old_item_rec.deliverable_type_code;
    ELSE
       l_record_change_flag := true;
       /*
       -- Istore specific.
       IF (l_new_item_rec.application_id = G_ISTORE_APPL_ID) THEN
          IF check_lookup_exists
             (
               p_lookup_type  => 'JTF_AMV_DELV_TYPE_CODE',
               p_lookup_code  => l_new_item_rec.deliverable_type_code
             ) = FND_API.G_FALSE THEN
             IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_name('JTF','JTF_AMV_TYPE_CODE_WRONG');
                 FND_MSG_PUB.Add;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;
       */
    END IF;
    --Checking applicable_to_code
    IF ( l_new_item_rec.applicable_to_code = FND_API.G_MISS_CHAR  OR
       l_new_item_rec.applicable_to_code IS NULL AND
       l_old_item_rec.applicable_to_code IS NULL     OR
       l_new_item_rec.applicable_to_code =
       l_old_item_rec.applicable_to_code) THEN
       l_new_item_rec.applicable_to_code :=
          l_old_item_rec.applicable_to_code;
    ELSE
       l_record_change_flag := true;
       /*
       -- Istore specific.
       IF (l_new_item_rec.application_id = G_ISTORE_APPL_ID) THEN
          IF check_lookup_exists
             (
               p_lookup_type  => 'JTF_AMV_APPLI_TO_CODE',
               p_lookup_code  => l_new_item_rec.applicable_to_code
             ) = FND_API.G_FALSE THEN
             IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_name('JTF','JTF_AMV_APPL_TO_CODE_WRONG');
                 FND_MSG_PUB.Add;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;
       */
    END IF;
    -- Now update the item record.
    IF (l_record_change_flag = TRUE) THEN
        JTF_AMV_ITEMS_PKG.UPDATE_ROW
        (
            X_ITEM_ID =>l_new_item_rec.item_id,
            X_OBJECT_VERSION_NUMBER => l_new_item_rec.object_version_number,
            X_LAST_UPDATE_DATE => sysdate,
            X_LAST_UPDATED_BY => CURRENT_USER_ID,
            X_LAST_UPDATE_LOGIN => CURRENT_LOGIN_ID,
            X_APPLICATION_ID => l_new_item_rec.application_id,
            X_EXTERNAL_ACCESS_FLAG => l_new_item_rec.external_access_flag,
            X_ITEM_NAME => l_new_item_rec.item_name,
            X_DESCRIPTION => l_new_item_rec.description,
            X_TEXT_STRING => l_new_item_rec.text_string,
            X_LANGUAGE_CODE => l_new_item_rec.language_code,
            X_STATUS_CODE => l_new_item_rec.status_code,
            X_EFFECTIVE_START_DATE => l_new_item_rec.effective_start_date,
            X_EXPIRATION_DATE => l_new_item_rec.expiration_date,
            X_ITEM_TYPE => l_new_item_rec.item_type,
            X_URL_STRING => l_new_item_rec.url_string,
            X_PUBLICATION_DATE => l_new_item_rec.publication_date,
            X_PRIORITY => l_new_item_rec.priority,
            X_CONTENT_TYPE_ID => l_new_item_rec.content_type_id,
            X_OWNER_ID => l_new_item_rec.owner_id,
            X_DEFAULT_APPROVER_ID => l_new_item_rec.default_approver_id,
            X_ITEM_DESTINATION_TYPE => l_new_item_rec.item_destination_type,
            X_ACCESS_NAME => l_new_item_rec.access_name,
            X_DELIVERABLE_TYPE_CODE => l_new_item_rec.deliverable_type_code,
            X_APPLICABLE_TO_CODE => l_new_item_rec.applicable_to_code,

            X_ATTRIBUTE_CATEGORY => FND_API.G_MISS_CHAR,
            X_ATTRIBUTE1 => FND_API.G_MISS_CHAR,
            X_ATTRIBUTE2 => FND_API.G_MISS_CHAR,
            X_ATTRIBUTE3 => FND_API.G_MISS_CHAR,
            X_ATTRIBUTE4 => FND_API.G_MISS_CHAR,
            X_ATTRIBUTE5 => FND_API.G_MISS_CHAR,
            X_ATTRIBUTE6 => FND_API.G_MISS_CHAR,
            X_ATTRIBUTE7 => FND_API.G_MISS_CHAR,
            X_ATTRIBUTE8 => FND_API.G_MISS_CHAR,
            X_ATTRIBUTE9 => FND_API.G_MISS_CHAR,
            X_ATTRIBUTE10 => FND_API.G_MISS_CHAR,
            X_ATTRIBUTE11 => FND_API.G_MISS_CHAR,
            X_ATTRIBUTE12 => FND_API.G_MISS_CHAR,
            X_ATTRIBUTE13 => FND_API.G_MISS_CHAR,
            X_ATTRIBUTE14 => FND_API.G_MISS_CHAR,
            X_ATTRIBUTE15 => FND_API.G_MISS_CHAR
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_item_id           IN  NUMBER,
    x_item_rec          OUT NOCOPY  ITEM_REC_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_Item';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  NUMBER;
--
CURSOR Get_Item_csr IS
Select
     item_id,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     OBJECT_VERSION_NUMBER,
     APPLICATION_ID,
     EXTERNAL_ACCESS_FLAG,
     ITEM_NAME,
     DESCRIPTION,
     TEXT_STRING,
     LANGUAGE_CODE,
     STATUS_CODE,
     effective_start_date,
     expiration_date,
     ITEM_TYPE,
     URL_STRING,
     PUBLICATION_DATE,
     PRIORITY,
     CONTENT_TYPE_ID,
     OWNER_ID,
     DEFAULT_APPROVER_ID,
     ITEM_DESTINATION_TYPE,
     access_name,
     deliverable_type_code,
     applicable_to_code
From  jtf_amv_items_vl
Where item_id = p_item_id;
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
    -- Now get the item data.
    OPEN  Get_Item_csr;
    FETCH Get_Item_csr  INTO x_item_rec;
    IF (Get_Item_csr%NOTFOUND) THEN
       CLOSE Get_Item_csr;
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_RECORD_MISSING');
           FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_item_id, -1) ));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE Get_Item_csr;
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
------------------------------ ITEM_KEYWORD ------------------------------------
PROCEDURE Add_ItemKeyword
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_item_id           IN  NUMBER,
    p_keyword_tab       IN  CHAR_TAB_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Add_ItemKeyword';
l_api_version          CONSTANT NUMBER := 1.0;
--
l_current_user_id      NUMBER := CURRENT_USER_ID;
l_current_login_id     NUMBER := CURRENT_LOGIN_ID;
l_count                NUMBER;
l_temp_number          NUMBER;
l_date                 DATE;
--
CURSOR Check_Itemkeyword_csr (p_kword in VARCHAR2) IS
Select
     item_keyword_id
From jtf_amv_item_keywords
Where keyword = p_kword
And   item_id = p_item_id;
--
CURSOR Get_IDandDate_csr is
Select jtf_amv_item_keywords_s.nextval, sysdate
From  Dual;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Add_ItemKeyword_Pub;
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
    -- Check if item id is valid.
    IF (Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_RECORD_MISSING');
           FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_item_id, -1) ));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_keyword_tab is null) THEN
        l_count := 0;
    ELSE
        l_count := p_keyword_tab.count;
    END IF;
    FOR i IN 1..l_count LOOP
        OPEN  Check_Itemkeyword_csr( p_keyword_tab(i) );
        FETCH Check_Itemkeyword_csr INTO l_temp_number;
        IF (Check_Itemkeyword_csr%FOUND) THEN
           CLOSE Check_Itemkeyword_csr;
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_HAS_KEYWORD');
               FND_MESSAGE.Set_Token('ID',  to_char(p_item_id) );
               FND_MESSAGE.Set_Token('KEYWORD',  p_keyword_tab(i));
               FND_MSG_PUB.Add;
           END IF;
        ELSE
           CLOSE Check_Itemkeyword_csr;
           OPEN  Get_IDandDate_csr;
           FETCH Get_IDandDate_csr Into l_temp_number, l_date;
           CLOSE Get_IDandDate_csr;
           Insert Into jtf_amv_item_keywords
             (
                ITEM_KEYWORD_ID,
                OBJECT_VERSION_NUMBER,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                ITEM_ID,
                KEYWORD
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
                p_keyword_tab(i)
             );
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
       ROLLBACK TO Add_ItemKeyword_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Add_ItemKeyword_Pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO Add_ItemKeyword_Pub;
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_item_id           IN  NUMBER,
    p_keyword           IN  VARCHAR2
) AS
l_char_tab           CHAR_TAB_TYPE;
BEGIN
    l_char_tab := CHAR_TAB_TYPE();
    l_char_tab.extend;
    l_char_tab(1) := p_keyword;
    --
    Add_ItemKeyword
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit            => p_commit,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_item_id           => p_item_id,
        p_keyword_tab       => l_char_tab
    );
end Add_ItemKeyword;
--------------------------------------------------------------------------------
PROCEDURE Delete_ItemKeyword
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_item_id           IN  NUMBER,
    p_keyword_tab       IN  CHAR_TAB_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Delete_ItemKeyword';
l_api_version          CONSTANT NUMBER := 1.0;
--
l_count                NUMBER;
l_temp_number          NUMBER;
l_date                 DATE;
--
CURSOR Check_Itemkeyword_csr (p_kword in VARCHAR2) IS
Select
     item_keyword_id
From jtf_amv_item_keywords
Where keyword = p_kword
And   item_id = p_item_id;
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Delete_ItemKeyword_Pub;
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
    -- Check if item id is valid.
    IF (Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_RECORD_MISSING');
           FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_item_id, -1) ));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_keyword_tab IS NOT NULL) THEN
       l_count := p_keyword_tab.count;
       FOR i IN 1..l_count LOOP
           OPEN  Check_Itemkeyword_csr( p_keyword_tab(i) );
           FETCH Check_Itemkeyword_csr INTO l_temp_number;
           IF (Check_Itemkeyword_csr%NOTFOUND) THEN
              CLOSE Check_Itemkeyword_csr;
              x_return_status := FND_API.G_RET_STS_ERROR;
              IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_HASNOT_KEYWORD');
                  FND_MESSAGE.Set_Token('ID',  to_char(p_item_id) );
                  FND_MESSAGE.Set_Token('KEYWORD',  p_keyword_tab(i));
                  FND_MSG_PUB.Add;
              END IF;
           ELSE
              CLOSE Check_Itemkeyword_csr;
              Delete from jtf_amv_item_keywords
              Where  item_keyword_id = l_temp_number;
           END IF;
       END LOOP;
    ELSE
       -- If no keyword specified, delete all the keywords of the item.
       Delete from jtf_amv_item_keywords
       Where  item_id = p_item_id;
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_item_id           IN  NUMBER,
    p_keyword           IN  VARCHAR2
) AS
l_char_tab           CHAR_TAB_TYPE;
BEGIN
    l_char_tab := CHAR_TAB_TYPE(p_keyword);
    Delete_ItemKeyword
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit            => p_commit,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_item_id           => p_item_id,
        p_keyword_tab       => l_char_tab
    );
end Delete_ItemKeyword;
--------------------------------------------------------------------------------
PROCEDURE Replace_ItemKeyword
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_item_id           IN  NUMBER,
    p_keyword_tab       IN  CHAR_TAB_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Replace_ItemKeyword';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  NUMBER;
--
l_count                NUMBER;
l_temp_number          NUMBER;
l_date                 DATE;
--
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
    -- Check if item id is valid.
    IF (Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_RECORD_MISSING');
           FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_item_id, -1) ));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Delete all the item's original keyword
    Delete from jtf_amv_item_keywords
    Where  item_id = p_item_id;
    -- now add the new keywords
    Add_ItemKeyword
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit            => p_commit,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_item_id           => p_item_id,
        p_keyword_tab       => p_keyword_tab
    );
    IF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF ( x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_item_id           IN  NUMBER,
    x_keyword_tab       OUT NOCOPY  CHAR_TAB_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_ItemKeyword';
l_api_version          CONSTANT NUMBER := 1.0;
--
l_fetch_count          NUMBER := 0;
CURSOR Get_Keyword_csr is
Select
    KEYWORD
from  JTF_AMV_ITEM_KEYWORDS
Where item_id = p_item_id;
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
    -- Check if item id is valid.
    IF (Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_RECORD_MISSING');
           FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_item_id, -1) ));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    --Execute the SQL statements to get records
    x_keyword_tab     := CHAR_TAB_TYPE();
    FOR kword in Get_Keyword_csr LOOP
        l_fetch_count := l_fetch_count + 1;
        x_keyword_tab.extend;
        x_keyword_tab(l_fetch_count) := kword.keyword;
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
END Get_ItemKeyword;
--------------------------------------------------------------------------------
------------------------------ ITEM_AUTHOR -------------------------------------
PROCEDURE Add_ItemAuthor
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_item_id           IN  NUMBER,
    p_author_tab        IN  CHAR_TAB_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Add_ItemAuthor';
l_api_version          CONSTANT NUMBER := 1.0;
--
l_current_user_id      NUMBER := CURRENT_USER_ID;
l_current_login_id     NUMBER := CURRENT_LOGIN_ID;
l_count                NUMBER;
l_temp_number          NUMBER;
l_date                 DATE;
--
CURSOR Check_Itemauthor_csr (p_author in VARCHAR2) IS
Select
     item_author_id
From jtf_amv_item_authors
Where author = p_author
And   item_id = p_item_id;
--
CURSOR Get_IDandDate_csr is
Select jtf_amv_item_authors_s.nextval, sysdate
From  Dual;
--
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Add_ItemAuthor_Pub;
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
    -- Check if item id is valid.
    IF (Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_RECORD_MISSING');
           FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_item_id, -1) ));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_author_tab is null) THEN
        l_count := 0;
    ELSE
        l_count := p_author_tab.count;
    END IF;
    FOR i IN 1..l_count LOOP
        OPEN  Check_Itemauthor_csr( p_author_tab(i) );
        FETCH Check_Itemauthor_csr INTO l_temp_number;
        IF (Check_Itemauthor_csr%FOUND) THEN
           CLOSE Check_Itemauthor_csr;
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_HAS_AUTHOR');
               FND_MESSAGE.Set_Token('ID',  to_char(p_item_id) );
               FND_MESSAGE.Set_Token('AUTHOR',  p_author_tab(i));
               FND_MSG_PUB.Add;
           END IF;
        ELSE
           CLOSE Check_Itemauthor_csr;
           OPEN  Get_IDandDate_csr;
           FETCH Get_IDandDate_csr Into l_temp_number, l_date;
           CLOSE Get_IDandDate_csr;
           Insert Into jtf_amv_item_authors
             (
                ITEM_AUTHOR_ID,
                OBJECT_VERSION_NUMBER,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                ITEM_ID,
                AUTHOR
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
                p_author_tab(i)
             );
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
       ROLLBACK TO Add_ItemAuthor_Pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Add_ItemAuthor_Pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO Add_ItemAuthor_Pub;
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_item_id           IN  NUMBER,
    p_author            IN  VARCHAR2
) AS
l_char_tab           CHAR_TAB_TYPE;
BEGIN
    l_char_tab := CHAR_TAB_TYPE(p_author);
    --
    Add_ItemAuthor
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit            => p_commit,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_item_id           => p_item_id,
        p_author_tab       => l_char_tab
    );
end Add_ItemAuthor;
--------------------------------------------------------------------------------
PROCEDURE Delete_ItemAuthor
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_item_id           IN  NUMBER,
    p_author_tab        IN  CHAR_TAB_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Delete_ItemAuthor';
l_api_version          CONSTANT NUMBER := 1.0;
--
l_count                NUMBER;
l_temp_number          NUMBER;
l_date                 DATE;
--
CURSOR Check_Itemauthor_csr (p_author in VARCHAR2) IS
Select
     item_author_id
From jtf_amv_item_authors
Where author = p_author
And   item_id = p_item_id;
BEGIN
    -- Standard call to check for call compatibility.
    SAVEPOINT  Delete_ItemAuthor_Pub;
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
    -- Check if item id is valid.
    IF (Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_RECORD_MISSING');
           FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_item_id, -1) ));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_author_tab IS NOT NULL) THEN
       l_count := p_author_tab.count;
       FOR i IN 1..l_count LOOP
           OPEN  Check_Itemauthor_csr( p_author_tab(i) );
           FETCH Check_Itemauthor_csr INTO l_temp_number;
           IF (Check_Itemauthor_csr%NOTFOUND) THEN
              CLOSE Check_Itemauthor_csr;
              x_return_status := FND_API.G_RET_STS_ERROR;
              IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_HASNOT_AUTHOR');
                  FND_MESSAGE.Set_Token('ID',  to_char(p_item_id) );
                  FND_MESSAGE.Set_Token('AUTHOR',  p_author_tab(i));
                  FND_MSG_PUB.Add;
              END IF;
           ELSE
              CLOSE Check_Itemauthor_csr;
              Delete from jtf_amv_item_authors
              Where  item_author_id = l_temp_number;
           END IF;
       END LOOP;
    ELSE
       -- If no author specified, delete all the authors of the item.
       Delete from jtf_amv_item_authors
       Where  item_id = p_item_id;
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_item_id           IN  NUMBER,
    p_author            IN  VARCHAR2
) AS
l_char_tab           CHAR_TAB_TYPE;
BEGIN
    l_char_tab := CHAR_TAB_TYPE(p_author);
    Delete_ItemAuthor
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit            => p_commit,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_item_id           => p_item_id,
        p_author_tab       => l_char_tab
    );
end Delete_ItemAuthor;
--------------------------------------------------------------------------------
PROCEDURE Replace_ItemAuthor
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_item_id           IN  NUMBER,
    p_author_tab        IN  CHAR_TAB_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Replace_ItemAuthor';
l_api_version          CONSTANT NUMBER := 1.0;
l_current_user_id      NUMBER  := -1;
l_current_login_id     NUMBER  := -1;
l_current_user_status  NUMBER;
--
l_count                NUMBER;
l_temp_number          NUMBER;
l_date                 DATE;
--
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
    -- Check if item id is valid.
    IF (Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_RECORD_MISSING');
           FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_item_id, -1) ));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Delete all the item's original author
    Delete from jtf_amv_item_authors
    Where  item_id = p_item_id;
    -- now add the new authors
    Add_ItemAuthor
    (
        p_api_version       => p_api_version,
        p_init_msg_list     => p_init_msg_list,
        p_commit            => p_commit,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_item_id           => p_item_id,
        p_author_tab        => p_author_tab
    );
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
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
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_item_id           IN  NUMBER,
    x_author_tab        OUT NOCOPY  CHAR_TAB_TYPE
) AS
l_api_name             CONSTANT VARCHAR2(30) := 'Get_ItemAuthor';
l_api_version          CONSTANT NUMBER := 1.0;
--
l_fetch_count          NUMBER := 0;
CURSOR Get_Author_csr is
Select
    AUTHOR
from  JTF_AMV_ITEM_AUTHORS
Where item_id = p_item_id;
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
    -- Check if item id is valid.
    IF (Is_ItemIdValid(p_item_id) <> TRUE) THEN
       IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_name('JTF','JTF_AMV_ITEM_RECORD_MISSING');
           FND_MESSAGE.Set_Token('ID',  to_char(nvl(p_item_id, -1) ));
           FND_MSG_PUB.Add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    --Execute the SQL statements to get records
    x_author_tab     := CHAR_TAB_TYPE();
    FOR rec in Get_Author_csr LOOP
        l_fetch_count := l_fetch_count + 1;
        x_author_tab.extend;
        x_author_tab(l_fetch_count) := rec.author;
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
END Get_ItemAuthor;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
END jtf_amv_item_pub;

/
