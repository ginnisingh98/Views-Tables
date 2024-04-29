--------------------------------------------------------
--  DDL for Package Body CS_SR_PREFERRED_LANG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_PREFERRED_LANG_PVT" AS
/* $Header: csvprlb.pls 120.0 2006/03/23 11:28:08 spusegao noship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'CS_SR_Preferred_Lang_PVT';
G_INITIALIZED       CONSTANT VARCHAR2(1)  := 'R';


--------------------------------------------------------------------------
-- Create_Preferred_Language
--------------------------------------------------------------------------

PROCEDURE Create_Preferred_Language
  ( p_api_version            IN    NUMBER,
    p_init_msg_list          IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                 IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level       IN    NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status          OUT   NOCOPY VARCHAR2,
    x_msg_count              OUT   NOCOPY NUMBER,
    x_msg_data               OUT   NOCOPY VARCHAR2,
    p_resp_appl_id           IN    NUMBER   DEFAULT NULL,
    p_resp_id                IN    NUMBER   DEFAULT NULL,
    p_user_id                IN    NUMBER,
    p_login_id               IN    NUMBER   DEFAULT NULL,
    p_preferred_language_rec IN    preferred_language_rec_type
  )
  IS
     l_api_name                   CONSTANT VARCHAR2(30)    := 'Create_Preferred_Language';
     l_api_version                CONSTANT NUMBER          := 1.0;
     l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
     l_return_status              VARCHAR2(1);
     l_preferred_language_rec     preferred_language_rec_type DEFAULT p_preferred_language_rec;
     --
     --
     l_row_id       VARCHAR2(64);
     l_msg_id       NUMBER;
     l_msg_count    NUMBER;
     l_msg_data     VARCHAR2(2000);


BEGIN
-- Standard start of API savepoint
   SAVEPOINT Create_Preferred_Language_PVT;

-- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (l_preferred_language_rec.initialize_flag IS NULL
  OR  l_preferred_language_rec.initialize_flag <> G_INITIALIZED) THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_INVALID_ARGUMENT');
    FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
    FND_MESSAGE.Set_Token('VALUE', l_preferred_language_rec.initialize_flag);
    FND_MESSAGE.Set_Token('PARAMETER', 'Initialize_Flag');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


/*
--
-- Start of Code for User Hooks
--
 --
  -- Make the preprocessing call to the user hooks
  --
  -- Pre call to the Customer Type User Hook
  --
   IF jtf_usr_hks.Ok_To_Execute('CS_SR_Preferred_Lang_PVT',
                                      'Create_Preferred-Language',
                                      'B', 'C')  THEN

    cs_preferred_language_cuhk.Create_Preferred_Language_Pre(p_preferred_language_rec=>l_preferred_language_rec,
                                                     x_return_status=>l_return_status);



    cs_preferred_language_cuhk.Create_Preferred_Language_Pre(
    p_api_version            =>   l_api_version,
    p_init_msg_list          =>   p_init_msg_list,
    p_commit                 =>   p_commit,
    p_validation_level       =>   p_validation_level,
    x_return_status          =>   l_return_status,
    x_msg_count              =>   x_msg_count ,
    x_msg_data               =>   x_msg_data,
    p_resp_appl_id           =>   p_resp_appl_id,
    p_resp_id                =>   p_resp_id,
    p_user_id                =>   p_user_id,
    p_login_id               =>   p_login_id,
    p_request_id             =>   l_request_id,
    p_request_number         =>   l_request_number,
    p_preferred_language_rec    =>   l_preferred_language_rec);



    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
      FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ERR_PRE_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_SR_Preferred_Lang_PVT',
                                      'Create_Preferred_Language',
                                      'B', 'V')  THEN

    cs_preferred_language_vuhk.Create_Preferred_Language_Pre(p_preferred_language_rec=>l_preferred_language_rec,
                                                     x_return_status=>l_return_status);

    cs_preferred_language_vuhk.Create_Preferred_Language_Pre(
    p_api_version            =>   l_api_version,
    p_init_msg_list          =>   p_init_msg_list,
    p_commit                 =>   p_commit,
    p_validation_level       =>   p_validation_level,
    x_return_status          =>   l_return_status,
    x_msg_count              =>   x_msg_count ,
    x_msg_data               =>   x_msg_data,
    p_resp_appl_id           =>   p_resp_appl_id,
    p_resp_id                =>   p_resp_id,
    p_user_id                =>   p_user_id,
    p_login_id               =>   p_login_id,
    p_request_id             =>   l_request_id,
    p_request_number         =>   l_request_number,
    p_preferred_language_rec =>   l_preferred_language_rec);



    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ERR_PRE_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  -- Pre call to the Internal Type User Hook
  --
  --Code to populate the global record type with the passed record type
  --

  IF jtf_usr_hks.Ok_To_Execute('CS_SR_Preferred_Language_PVT',
                                      'Create_Preferred_Language',
                                      'B', 'I')  THEN


    cs_preferred_language_iuhk.Create_Preferred_Language_Pre( x_return_status=>l_return_status);


    cs_preferred_language_iuhk.call_internal_hook( p_package_name => 'Create_Preferred_Language_PVT',
									  p_api_name  => 'Create_Preferred_Language'
									  p_processing_type => 'B',
                                               x_return_status=>l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ERR_PRE_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


  --END IF;

--
--  End of User Hooks
--
*/



--
--  Validate Preferred Language Record
--

  IF (l_preferred_language_rec.pref_lang_id = FND_API.G_MISS_NUM )
  OR (l_preferred_language_rec.pref_lang_id is null ) THEN
    DECLARE
      l_key_val       NUMBER;
    BEGIN
      select CS_SR_PREFERRED_LANG_S.nextval
      into l_key_val
      from dual;

      l_preferred_language_rec.pref_lang_id := l_key_val;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      WHEN OTHERS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;


  IF (l_preferred_language_rec.language_code = FND_API.G_MISS_CHAR  OR
      l_preferred_language_rec.language_code IS NULL) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_INVALID_ARGUMENT');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MESSAGE.Set_Token('VALUE', l_preferred_language_rec.language_code);
      FND_MESSAGE.Set_Token('PARAMETER', 'Language_Code');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN
    DECLARE
      l_dummy  varchar2(1);
    BEGIN
      select 'x' into l_dummy
      from fnd_languages
      where language_code = l_preferred_language_rec.language_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_INVALID_ARGUMENT');
            FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
            FND_MESSAGE.Set_Token('VALUE', l_preferred_language_rec.language_code);
            FND_MESSAGE.Set_Token('PARAMETER', 'Language_Code');
            FND_MSG_PUB.Add;
	    RAISE FND_API.G_EXC_ERROR;
      WHEN OTHERS THEN
	    RAISE FND_API.G_EXC_ERROR;
    END;

    DECLARE
      l_dummy  varchar2(1);
    BEGIN
      select 'x' into l_dummy
      from CS_SR_PREFERRED_LANG
      where language_code = l_preferred_language_rec.language_code;

      FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_INVALID_ARGUMENT');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MESSAGE.Set_Token('VALUE', l_preferred_language_rec.language_code);
      FND_MESSAGE.Set_Token('PARAMETER', 'Language_Code');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	    null;
      WHEN OTHERS THEN
	    RAISE FND_API.G_EXC_ERROR;
    END;
  END IF;


  IF (l_preferred_language_rec.start_date_active = FND_API.G_MISS_DATE ) THEN
      l_preferred_language_rec.start_date_active := NULL;
  END IF;

  IF (l_preferred_language_rec.end_date_active = FND_API.G_MISS_DATE ) THEN
      l_preferred_language_rec.end_date_active := NULL;
  END IF;

  IF  (l_preferred_language_rec.start_date_active is not null)
  AND (l_preferred_language_rec.end_date_active is not null)
  AND (l_preferred_language_rec.start_date_active > l_preferred_language_rec.end_date_active) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_INVALID_ARGUMENT');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MESSAGE.Set_Token('VALUE', to_char(l_preferred_language_rec.end_date_active));
      FND_MESSAGE.Set_Token('PARAMETER', 'End_Date_Active');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END IF ;

  --
  -- Validate the descriptive flexfields
  --

  IF (l_preferred_language_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute_category := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute1 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute2 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute3 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute4 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute5 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute6 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute7 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute8 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute9 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute10 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute11 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute12 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute13 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute14 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute15 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute1 is not null)
  OR (l_preferred_language_rec.attribute2 is not null)
  OR (l_preferred_language_rec.attribute3 is not null)
  OR (l_preferred_language_rec.attribute4 is not null)
  OR (l_preferred_language_rec.attribute5 is not null)
  OR (l_preferred_language_rec.attribute6 is not null)
  OR (l_preferred_language_rec.attribute7 is not null)
  OR (l_preferred_language_rec.attribute8 is not null)
  OR (l_preferred_language_rec.attribute9 is not null)
  OR (l_preferred_language_rec.attribute10 is not null)
  OR (l_preferred_language_rec.attribute11 is not null)
  OR (l_preferred_language_rec.attribute12 is not null)
  OR (l_preferred_language_rec.attribute13 is not null)
  OR (l_preferred_language_rec.attribute14 is not null)
  OR (l_preferred_language_rec.attribute15 is not null)
  OR (l_preferred_language_rec.attribute_category is not null) THEN
    Validate_Desc_Flex(
        p_api_name               => l_api_name_full,
        p_application_short_name => 'CS',
        p_desc_flex_name         => 'CS_SR_PREFERRED_LANG',
        p_desc_segment1          => l_preferred_language_rec.attribute1,
        p_desc_segment2          => l_preferred_language_rec.attribute2,
        p_desc_segment3          => l_preferred_language_rec.attribute3,
        p_desc_segment4          => l_preferred_language_rec.attribute4,
        p_desc_segment5          => l_preferred_language_rec.attribute5,
        p_desc_segment6          => l_preferred_language_rec.attribute6,
        p_desc_segment7          => l_preferred_language_rec.attribute7,
        p_desc_segment8          => l_preferred_language_rec.attribute8,
        p_desc_segment9          => l_preferred_language_rec.attribute9,
        p_desc_segment10         => l_preferred_language_rec.attribute10,
        p_desc_segment11         => l_preferred_language_rec.attribute11,
        p_desc_segment12         => l_preferred_language_rec.attribute12,
        p_desc_segment13         => l_preferred_language_rec.attribute13,
        p_desc_segment14         => l_preferred_language_rec.attribute14,
        p_desc_segment15         => l_preferred_language_rec.attribute15,
        p_desc_context           => l_preferred_language_rec.attribute_category,
        p_resp_appl_id           => p_resp_appl_id,
        p_resp_id                => p_resp_id,
        p_return_status          => l_return_status );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      raise FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  IF (l_preferred_language_rec.object_version_number = FND_API.G_MISS_NUM )
  OR (l_preferred_language_rec.object_version_number is null) THEN
      l_preferred_language_rec.object_version_number := 1;
  END IF;

  --
  -- Insert into table through the table handlers
  --

CS_SR_PREFERRED_LANG_PKG.INSERT_ROW (
  X_ROWID              => l_preferred_language_rec.row_id,
  X_PREF_LANG_ID       => l_preferred_language_rec.pref_lang_id,
  X_LANGUAGE_CODE      => l_preferred_language_rec.language_code,
  X_START_DATE_ACTIVE  => l_preferred_language_rec.start_date_active,
  X_END_DATE_ACTIVE    => l_preferred_language_rec.end_date_active,
  X_ATTRIBUTE_CATEGORY => l_preferred_language_rec.attribute_category,
  X_ATTRIBUTE1         => l_preferred_language_rec.attribute1,
  X_ATTRIBUTE2         => l_preferred_language_rec.attribute2,
  X_ATTRIBUTE3         => l_preferred_language_rec.attribute3,
  X_ATTRIBUTE4         => l_preferred_language_rec.attribute4,
  X_ATTRIBUTE5         => l_preferred_language_rec.attribute5,
  X_ATTRIBUTE6         => l_preferred_language_rec.attribute6,
  X_ATTRIBUTE7         => l_preferred_language_rec.attribute7,
  X_ATTRIBUTE8         => l_preferred_language_rec.attribute8,
  X_ATTRIBUTE9         => l_preferred_language_rec.attribute9,
  X_ATTRIBUTE10        => l_preferred_language_rec.attribute10,
  X_ATTRIBUTE11        => l_preferred_language_rec.attribute11,
  X_ATTRIBUTE12        => l_preferred_language_rec.attribute12,
  X_ATTRIBUTE13        => l_preferred_language_rec.attribute13,
  X_ATTRIBUTE14        => l_preferred_language_rec.attribute14,
  X_ATTRIBUTE15        => l_preferred_language_rec.attribute15,
  X_OBJECT_VERSION_NUMBER => l_preferred_language_rec.object_version_number,
  X_CREATION_DATE      => sysdate,
  X_CREATED_BY         => p_user_id,
  X_LAST_UPDATE_DATE   => sysdate,
  X_LAST_UPDATED_BY    => p_user_id,
  X_LAST_UPDATE_LOGIN  => p_login_id);

/*
--
--  Start of User Hooks post code
--

  -- Make the post processing call to the user hooks
  --
  -- Post call to the Customer Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_SR_Preferred_Language_PVT',
                                      'Create_Preferred_Language',
                                      'A', 'C')  THEN

    cs_preferred_Language_cuhk.Create_Preferred_Language_Post(p_preferred_language_rec=>l_preferred_language_rec,
                                                     x_return_status=>l_return_status);


    cs_preferred_language_cuhk.Create_Preferred_Language_Post(
    p_api_version            =>   l_api_version,
    p_init_msg_list          =>   p_init_msg_list,
    p_commit                 =>   p_commit,
    p_validation_level       =>   p_validation_level,
    x_return_status          =>   l_return_status,
    x_msg_count              =>   x_msg_count ,
    x_msg_data               =>   x_msg_data,
    p_resp_appl_id           =>   p_resp_appl_id,
    p_resp_id                =>   p_resp_id,
    p_user_id                =>   p_user_id,
    p_login_id               =>   p_login_id,
    p_preferred_language_rec =>   l_preferred_language_rec);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Post Customer User Hook');
      FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ERR_POST_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;


  -- Post call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_Preferred_Language_PVT',
                                      'Create_Preferred_Language',
                                      'A', 'V')  THEN

    cs_preferred_language_vuhk.Create_Preferred_Language_Post(p_preferred_language_rec=>l_preferred_language_rec,
                                                     x_return_status=>l_return_status);


    cs_preferred_language_vuhk.Create_Preferred_Language_Post(
    p_api_version            =>   l_api_version,
    p_init_msg_list          =>   p_init_msg_list,
    p_commit                 =>   p_commit,
    p_validation_level       =>   p_validation_level,
    x_return_status          =>   l_return_status,
    x_msg_count              =>   x_msg_count ,
    x_msg_data               =>   x_msg_data,
    p_resp_appl_id           =>   p_resp_appl_id,
    p_resp_id                =>   p_resp_id,
    p_user_id                =>   p_user_id,
    p_login_id               =>   p_login_id,
    p_request_id             =>   l_request_id,
    p_request_number         =>   l_request_number,
    p_preferred_language_rec =>   l_preferred_language_rec);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Post Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ERR_POST_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;



  -- Post call to the internal Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Create_ServiceRequest',
                                      'A', 'I')  THEN

    cs_servicerequest_iuhk.Create_ServiceRequest_Post( x_return_status=>l_return_status);

    cs_servicerequest_iuhk.call_internal_hook( p_package_name => 'Create_ServiceRequest_PVT',
									  p_api_name  => 'Create_ServiceRequest'
									  p_processing_type => 'A',
                                               x_return_status=>l_return_status);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Post Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ERR_POST_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  --END IF;


--
-- End of User Hooks post code
--

*/


  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;


  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Preferred_Language_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Preferred_Language_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO Create_Preferred_Language_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
END Create_Preferred_Language;



--------------------------------------------------------------------------
-- Update_Preferred_Language
--------------------------------------------------------------------------


PROCEDURE Update_Preferred_Language
  ( p_api_version	    IN	NUMBER,
    p_init_msg_list	    IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit		    IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level	    IN	NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status	    OUT	NOCOPY VARCHAR2,
    x_msg_count		    OUT	NOCOPY NUMBER,
    x_msg_data		    OUT	NOCOPY VARCHAR2,
    p_pref_lang_id          IN  NUMBER,
    p_object_version_number IN  NUMBER,
    p_resp_appl_id	    IN	NUMBER   DEFAULT NULL,
    p_resp_id		    IN	NUMBER   DEFAULT NULL,
    p_user_id               IN  NUMBER,
    p_login_id              IN  NUMBER   DEFAULT NULL,
    p_last_updated_by	    IN	NUMBER,
    p_last_update_login	    IN	NUMBER   DEFAULT NULL,
    p_last_update_date	    IN	DATE,
    p_preferred_language_rec IN  preferred_language_rec_type
    )
  IS
     l_api_name                   CONSTANT VARCHAR2(30)    := 'Update_Preferred_Language';
     l_api_version                CONSTANT NUMBER          := 1.0;
     l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
     l_return_status              VARCHAR2(1);
     l_preferred_language_rec     preferred_language_rec_type DEFAULT p_preferred_language_rec;

     l_msg_id   NUMBER;
     l_msg_count    NUMBER;
     l_msg_data   VARCHAR2(2000);


     CURSOR l_Preferred_Language_csr(p_id number, p_obj_num number) IS
       SELECT *
       FROM   cs_sr_preferred_lang
       WHERE  pref_lang_id = p_id
       AND    object_version_number = p_obj_num
       FOR UPDATE OF pref_lang_id;

     l_old_preferred_language_rec   l_Preferred_Language_csr%ROWTYPE;

     l_count                  NUMBER;


BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Update_Preferred_Language_PVT;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (l_preferred_language_rec.initialize_flag IS NULL
  OR  l_preferred_language_rec.initialize_flag <> G_INITIALIZED) THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_INVALID_ARGUMENT');
    FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
    FND_MESSAGE.Set_Token('VALUE', l_preferred_language_rec.initialize_flag);
    FND_MESSAGE.Set_Token('PARAMETER', 'Initialize_Flag');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


--
-- Check if mandatory parameter is passed
--
--dbms_output.put_line('Check Mandatory') ;
  IF (p_pref_lang_id IS NULL ) THEN
      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(l_api_name_full, 'Preferred Language ID');
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_object_version_number IS NULL ) THEN
      CS_ServiceRequest_UTIL.Add_Null_Parameter_Msg(l_api_name_full, 'Object Version Number');
      RAISE FND_API.G_EXC_ERROR;
  END IF;


-- Fetch and get the original values
--dbms_output.put_line('Fetch id=' || p_pref_lang_id || ', object_ver_num=' || p_object_version_number) ;
  OPEN  l_Preferred_Language_csr(p_pref_lang_id, p_object_version_number);
  FETCH l_Preferred_Language_csr INTO l_old_Preferred_Language_rec;
  IF (l_Preferred_Language_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_INVALID_ARGUMENT');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MESSAGE.Set_Token('VALUE', to_char(p_pref_lang_id));
      FND_MESSAGE.Set_Token('PARAMETER', 'Pref_Lang_ID');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
  END IF;

--dbms_output.put_line('After Fetch') ;


--
-- Start of Pre User Hooks
--
/*
  -- Make the preprocessing call to the user hooks
  --
  -- Pre call to the Customer Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Update_ServiceRequest',
                                      'B', 'C')  THEN

    cs_servicerequest_cuhk.Update_ServiceRequest_Pre(p_request_id => p_request_id,
                                                     p_service_request_rec=>l_service_request_rec,
                                                     x_return_status=>l_return_status);


    cs_servicerequest_cuhk.Update_ServiceRequest_Pre
  ( p_api_version         => l_api_version,
    p_init_msg_list       => p_init_msg_list,
    p_commit              => p_commit,
    p_validation_level      =>  p_validation_level,
    x_return_status         =>  l_return_status,
    x_msg_count             =>  x_msg_count,
    x_msg_data              =>  x_msg_data,
    p_request_id            =>   p_request_id ,
    p_object_version_number  =>  p_object_version_number,
    p_resp_appl_id           =>  p_resp_appl_id,
    p_resp_id                =>  p_resp_id,
    p_last_updated_by        =>  p_last_updated_by,
    p_last_update_login      =>  p_last_update_login,
    p_last_update_date       =>  p_last_update_date,
    p_service_request_rec    =>  l_service_request_rec);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Customer User Hook');
      FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ERR_PRE_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;


  -- Pre call to the Vertical Type User Hook
  --


  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Update_ServiceRequest',
                                      'B', 'V')  THEN


    cs_servicerequest_vuhk.Update_ServiceRequest_Pre(p_request_id => p_request_id,
                                                     p_service_request_rec=>l_service_request_rec,
                                                     x_return_status=>l_return_status);

    cs_servicerequest_vuhk.Update_ServiceRequest_Pre
  ( p_api_version         => l_api_version,
    p_init_msg_list       => p_init_msg_list,
    p_commit              => p_commit,
    p_validation_level      =>  p_validation_level,
    x_return_status         =>  l_return_status,
    x_msg_count             =>  x_msg_count,
    x_msg_data              =>  x_msg_data,
    p_request_id            =>   p_request_id ,
    p_object_version_number  =>  p_object_version_number,
    p_resp_appl_id           =>  p_resp_appl_id,
    p_resp_id                =>  p_resp_id,
    p_last_updated_by        =>  p_last_updated_by,
    p_last_update_login      =>  p_last_update_login,
    p_last_update_date       =>  p_last_update_date,
    p_service_request_rec    =>  l_service_request_rec);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ERR_PRE_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  --
  -- Pre call to the Internal Type User Hook
  --

  --Code to populate the global record type with the passed record type
  --
  user_hooks_rec.customer_id  :=  l_old_ServiceRequest_rec.customer_id ;
  user_hooks_rec.request_id   :=  p_request_id ;



  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Update_ServiceRequest',
                                      'B', 'I')  THEN


 --  cs_servicerequest_iuhk.Update_ServiceRequest_Pre(x_return_status=>l_return_status);


    cs_servicerequest_iuhk.call_internal_hook( p_package_name => 'Create_ServiceRequest_PVT',
									  p_api_name  => 'Update_ServiceRequest'
									  p_processing_type => 'B',
                                               x_return_status=>l_return_status);



    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Pre Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ERR_PRE_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


  --END IF;
*/
--
-- End of Pre User Hooks
--




  --
  -- We first deal with some special validation rules
  --
  IF (p_validation_level > FND_API.G_VALID_LEVEL_NONE) THEN
    DECLARE
      l_dummy  varchar2(1);
    BEGIN
      select 'x' into l_dummy
      from fnd_languages
      where language_code = l_preferred_language_rec.language_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_INVALID_ARGUMENT');
          FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
          FND_MESSAGE.Set_Token('VALUE', l_preferred_language_rec.language_code);
          FND_MESSAGE.Set_Token('PARAMETER', 'Language_Code');
          FND_MSG_PUB.Add;
	  RAISE FND_API.G_EXC_ERROR;
      WHEN OTHERS THEN
	  RAISE FND_API.G_EXC_ERROR;
    END;

    DECLARE
      l_dummy  varchar2(1);
    BEGIN
      select 'x' into l_dummy
      from CS_SR_PREFERRED_LANG
      where language_code = l_preferred_language_rec.language_code
      and   pref_lang_id  <> p_pref_lang_id;

      FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_INVALID_ARGUMENT');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MESSAGE.Set_Token('VALUE', l_preferred_language_rec.language_code);
      FND_MESSAGE.Set_Token('PARAMETER', 'Language_Code');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	    null;
      WHEN OTHERS THEN
	    RAISE FND_API.G_EXC_ERROR;
    END;
  END IF ;  -- p_validation level end if

--dbms_output.put_line('Validate1') ;

  -- -----------------------------------------------------------
  -- Check to see if the descriptive flexfield is being updated
  -- -----------------------------------------------------------

  IF (l_preferred_language_rec.attribute_category = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute_category := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute1 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute2 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute2 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute3 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute3 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute4 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute4 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute5 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute5 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute6 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute6 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute7 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute7 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute8 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute8 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute9 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute9 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute10 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute11 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute11 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute12 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute12 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute13 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute13 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute14 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute14 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute15 = FND_API.G_MISS_CHAR ) THEN
      l_preferred_language_rec.attribute15 := NULL;
  END IF;

  IF (l_preferred_language_rec.attribute_category <>
                    l_old_Preferred_Language_rec.attribute_category)
  OR (l_preferred_language_rec.attribute1  <> l_old_Preferred_Language_rec.attribute1)
  OR (l_preferred_language_rec.attribute2  <> l_old_Preferred_Language_rec.attribute2)
  OR (l_preferred_language_rec.attribute3  <> l_old_Preferred_Language_rec.attribute3)
  OR (l_preferred_language_rec.attribute4  <> l_old_Preferred_Language_rec.attribute4)
  OR (l_preferred_language_rec.attribute5  <> l_old_Preferred_Language_rec.attribute5)
  OR (l_preferred_language_rec.attribute6  <> l_old_Preferred_Language_rec.attribute6)
  OR (l_preferred_language_rec.attribute7  <> l_old_Preferred_Language_rec.attribute7)
  OR (l_preferred_language_rec.attribute8  <> l_old_Preferred_Language_rec.attribute8)
  OR (l_preferred_language_rec.attribute9  <> l_old_Preferred_Language_rec.attribute9)
  OR (l_preferred_language_rec.attribute10 <> l_old_Preferred_Language_rec.attribute10)
  OR (l_preferred_language_rec.attribute11 <> l_old_Preferred_Language_rec.attribute11)
  OR (l_preferred_language_rec.attribute12 <> l_old_Preferred_Language_rec.attribute12)
  OR (l_preferred_language_rec.attribute13 <> l_old_Preferred_Language_rec.attribute13)
  OR (l_preferred_language_rec.attribute14 <> l_old_Preferred_Language_rec.attribute14)
  OR (l_preferred_language_rec.attribute15 <> l_old_Preferred_Language_rec.attribute15) THEN
    Validate_Desc_Flex(
        p_api_name               => l_api_name_full,
        p_application_short_name => 'CS',
        p_desc_flex_name         => 'CS_SR_PREFERRED_LANG',
        p_desc_segment1          => l_preferred_language_rec.attribute1,
        p_desc_segment2          => l_preferred_language_rec.attribute2,
        p_desc_segment3          => l_preferred_language_rec.attribute3,
        p_desc_segment4          => l_preferred_language_rec.attribute4,
        p_desc_segment5          => l_preferred_language_rec.attribute5,
        p_desc_segment6          => l_preferred_language_rec.attribute6,
        p_desc_segment7          => l_preferred_language_rec.attribute7,
        p_desc_segment8          => l_preferred_language_rec.attribute8,
        p_desc_segment9          => l_preferred_language_rec.attribute9,
        p_desc_segment10         => l_preferred_language_rec.attribute10,
        p_desc_segment11         => l_preferred_language_rec.attribute11,
        p_desc_segment12         => l_preferred_language_rec.attribute12,
        p_desc_segment13         => l_preferred_language_rec.attribute13,
        p_desc_segment14         => l_preferred_language_rec.attribute14,
        p_desc_segment15         => l_preferred_language_rec.attribute15,
        p_desc_context           => l_preferred_language_rec.attribute_category,
        p_resp_appl_id           => p_resp_appl_id,
        p_resp_id                => p_resp_id,
        p_return_status          => l_return_status );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      raise FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  ELSE
    l_preferred_language_rec.attribute1  := l_old_Preferred_Language_rec.attribute1;
    l_preferred_language_rec.attribute2  := l_old_Preferred_Language_rec.attribute2;
    l_preferred_language_rec.attribute3  := l_old_Preferred_Language_rec.attribute3;
    l_preferred_language_rec.attribute4  := l_old_Preferred_Language_rec.attribute4;
    l_preferred_language_rec.attribute5  := l_old_Preferred_Language_rec.attribute5;
    l_preferred_language_rec.attribute6  := l_old_Preferred_Language_rec.attribute6;
    l_preferred_language_rec.attribute7  := l_old_Preferred_Language_rec.attribute7;
    l_preferred_language_rec.attribute8  := l_old_Preferred_Language_rec.attribute8;
    l_preferred_language_rec.attribute9  := l_old_Preferred_Language_rec.attribute9;
    l_preferred_language_rec.attribute10 := l_old_Preferred_Language_rec.attribute10;
    l_preferred_language_rec.attribute11 := l_old_Preferred_Language_rec.attribute11;
    l_preferred_language_rec.attribute12 := l_old_Preferred_Language_rec.attribute12;
    l_preferred_language_rec.attribute13 := l_old_Preferred_Language_rec.attribute13;
    l_preferred_language_rec.attribute14 := l_old_Preferred_Language_rec.attribute14;
    l_preferred_language_rec.attribute15 := l_old_Preferred_Language_rec.attribute15;
    l_preferred_language_rec.attribute_category :=
                                   l_old_Preferred_Language_rec.attribute_category;
  END IF;


--dbms_output.put_line('Validate2') ;



---------------------------------------------------

-- Before the actual update, see if the all the fields
-- have their old values or null values
--(otherwise they will have the MISS_NUM constants)

  IF l_preferred_language_rec.language_code = FND_API.G_MISS_CHAR THEN
     l_preferred_language_rec.language_code :=
                       l_old_preferred_language_rec.language_code;
  END IF;

  IF l_preferred_language_rec.start_date_active = FND_API.G_MISS_DATE THEN
     l_preferred_language_rec.start_date_active :=
                       l_old_preferred_language_rec.start_date_active;
  END IF;

  IF l_preferred_language_rec.end_date_active = FND_API.G_MISS_DATE THEN
     l_preferred_language_rec.end_date_active :=
                       l_old_preferred_language_rec.end_date_active;
  END IF;



  --
  -- Update table through the table handlers
  --

--dbms_output.put_line('Before Update');

CS_SR_PREFERRED_LANG_PKG.UPDATE_ROW (
  X_PREF_LANG_ID       => l_preferred_language_rec.pref_lang_id,
  X_LANGUAGE_CODE      => l_preferred_language_rec.language_code,
  X_START_DATE_ACTIVE  => l_preferred_language_rec.start_date_active,
  X_END_DATE_ACTIVE    => l_preferred_language_rec.end_date_active,
  X_ATTRIBUTE_CATEGORY => l_preferred_language_rec.attribute_category,
  X_ATTRIBUTE1         => l_preferred_language_rec.attribute1,
  X_ATTRIBUTE2         => l_preferred_language_rec.attribute2,
  X_ATTRIBUTE3         => l_preferred_language_rec.attribute3,
  X_ATTRIBUTE4         => l_preferred_language_rec.attribute4,
  X_ATTRIBUTE5         => l_preferred_language_rec.attribute5,
  X_ATTRIBUTE6         => l_preferred_language_rec.attribute6,
  X_ATTRIBUTE7         => l_preferred_language_rec.attribute7,
  X_ATTRIBUTE8         => l_preferred_language_rec.attribute8,
  X_ATTRIBUTE9         => l_preferred_language_rec.attribute9,
  X_ATTRIBUTE10        => l_preferred_language_rec.attribute10,
  X_ATTRIBUTE11        => l_preferred_language_rec.attribute11,
  X_ATTRIBUTE12        => l_preferred_language_rec.attribute12,
  X_ATTRIBUTE13        => l_preferred_language_rec.attribute13,
  X_ATTRIBUTE14        => l_preferred_language_rec.attribute14,
  X_ATTRIBUTE15        => l_preferred_language_rec.attribute15,
  X_OBJECT_VERSION_NUMBER => p_object_version_number + 1,
  X_LAST_UPDATE_DATE   => sysdate,
  X_LAST_UPDATED_BY    => p_last_updated_by,
  X_LAST_UPDATE_LOGIN  => p_last_update_login);


  CLOSE l_Preferred_Language_csr;

--dbms_output.put_line('After Update');

/*
--
-- Start of Post User Hooks
--

   IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Update_ServiceRequest',
                                      'A', 'C')  THEN

    cs_servicerequest_cuhk.Update_ServiceRequest_Post( p_request_id  => p_request_id,
                                                      p_service_request_rec=>l_service_request_rec,
                                                     x_return_status=>l_return_status);


    cs_servicerequest_cuhk.Update_ServiceRequest_Post
    ( p_api_version         => l_api_version,
      p_init_msg_list       => p_init_msg_list,
      p_commit              => p_commit,
    p_validation_level      =>  p_validation_level,
    x_return_status         =>  l_return_status,
    x_msg_count             =>  x_msg_count,
    x_msg_data              =>  x_msg_data,
    p_request_id            =>   p_request_id ,
    p_object_version_number  =>  p_object_version_number,
    p_resp_appl_id           =>  p_resp_appl_id,
    p_resp_id                =>  p_resp_id,
    p_last_updated_by        =>  p_last_updated_by,
    p_last_update_login      =>  p_last_update_login,
    p_last_update_date       =>  p_last_update_date,
    p_service_request_rec    =>  l_service_request_rec);



    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Post Customer User Hook');
      FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ERR_POST_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;



  -- Post call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Update_ServiceRequest',
                                      'A', 'V')  THEN


    cs_servicerequest_vuhk.Update_ServiceRequest_Post( p_request_id  => p_request_id,

                                                      p_service_request_rec=>l_service_request_rec,
                                                     x_return_status=>l_return_status);


    cs_servicerequest_vuhk.Update_ServiceRequest_Post
    ( p_api_version         => l_api_version,
      p_init_msg_list       => p_init_msg_list,
      p_commit              => p_commit,
    p_validation_level      =>  p_validation_level,
    x_return_status         =>  l_return_status,
    x_msg_count             =>  x_msg_count,
    x_msg_data              =>  x_msg_data,
    p_request_id            =>   p_request_id ,
    p_object_version_number  =>  p_object_version_number,
    p_resp_appl_id           =>  p_resp_appl_id,
    p_resp_id                =>  p_resp_id,
    p_last_updated_by        =>  p_last_updated_by,
    p_last_update_login      =>  p_last_update_login,
    p_last_update_date       =>  p_last_update_date,
    p_service_request_rec    =>  l_service_request_rec);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Post Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ERR_POST_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;



  -- Post call to the Internal Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Update_ServiceRequest',
                                      'A', 'I')  THEN

 --   cs_servicerequest_iuhk.Update_ServiceRequest_Post( x_return_status=>l_return_status);



    cs_servicerequest_iuhk.call_internal_hook( p_package_name => 'Create_ServiceRequest_PVT',
                                                                          p_api_name  => 'Update_ServiceRequest'
                                                                          p_processing_type => 'A',
                                               x_return_status=>l_return_status)
;


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Post Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ERR_POST_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  --END IF;
     IF (cs_servicerequest_cuhk.Ok_To_Generate_Msg(p_request_id => p_request_id,
                                                   p_service_request_rec=>l_service_request_rec)) THEN
       l_bind_data_id := JTF_USR_HKS.Get_bind_data_id;

       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'incident_id', p_request_id, 'S', 'N');

       JTF_USR_HKS.generate_message(p_prod_code => 'CS',
                                 p_bus_obj_code => 'SR',
                                 p_action_code => 'U',
                                 p_bind_data_id => l_bind_data_id,
                                 x_return_code => l_return_status);


       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Message Generation Hook');
            FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ERR_MSG_GEN_HK');
            FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
            FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

      -- Standard check of p_commit
      IF FND_API.To_Boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      RAISE OnlyUpdStatus ;

    END IF;
--
--  End of User Hooks
--



  --
  -- Make the post processing call to the user hooks
  --
  -- Post call to the Customer Type User Hook
  --

    IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Update_ServiceRequest',
                                      'A', 'C')  THEN



    cs_servicerequest_cuhk.Update_ServiceRequest_Post( p_request_id  => p_request_id,
                                                      p_service_request_rec=>l_service_request_rec,
                                                     x_return_status=>l_return_status);


    cs_servicerequest_cuhk.Update_ServiceRequest_Post
    ( p_api_version         => l_api_version,
      p_init_msg_list       => p_init_msg_list,
      p_commit              => p_commit,
    p_validation_level      =>  p_validation_level,
    x_return_status         =>  l_return_status,
    x_msg_count             =>  x_msg_count,
    x_msg_data              =>  x_msg_data,
    p_request_id            =>   p_request_id ,
    p_object_version_number  =>  p_object_version_number,
    p_resp_appl_id           =>  p_resp_appl_id,
    p_resp_id                =>  p_resp_id,
    p_last_updated_by        =>  p_last_updated_by,
    p_last_update_login      =>  p_last_update_login,
    p_last_update_date       =>  p_last_update_date,
    p_service_request_rec    =>  l_service_request_rec);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Post Customer User Hook');
      FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ERR_POST_CUST_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;


  -- Post call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Update_ServiceRequest',
                                      'A', 'V')  THEN


    cs_servicerequest_vuhk.Update_ServiceRequest_Post( p_request_id  => p_request_id,
                                                      p_service_request_rec=>l_service_request_rec,
                                                     x_return_status=>l_return_status);


    cs_servicerequest_vuhk.Update_ServiceRequest_Post
    ( p_api_version         => l_api_version,
      p_init_msg_list       => p_init_msg_list,
      p_commit              => p_commit,
    p_validation_level      =>  p_validation_level,
    x_return_status         =>  l_return_status,
    x_msg_count             =>  x_msg_count,
    x_msg_data              =>  x_msg_data,
    p_request_id            =>   p_request_id ,
    p_object_version_number  =>  p_object_version_number,
    p_resp_appl_id           =>  p_resp_appl_id,
    p_resp_id                =>  p_resp_id,
    p_last_updated_by        =>  p_last_updated_by,
    p_last_update_login      =>  p_last_update_login,
    p_last_update_date       =>  p_last_update_date,
    p_service_request_rec    =>  l_service_request_rec);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Post Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ERR_POST_VERT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;



  -- Post call to the Internal Type User Hook
  --
  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Update_ServiceRequest',
                                      'A', 'I')  THEN


 --   cs_servicerequest_iuhk.Update_ServiceRequest_Post( x_return_status=>l_return_status);



    cs_servicerequest_iuhk.call_internal_hook( p_package_name => 'Create_ServiceRequest_PVT',
									  p_api_name  => 'Update_ServiceRequest'
									  p_processing_type => 'A',
                                               x_return_status=>l_return_status);


    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Post Vertical User Hook');
      FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ERR_POST_INT_USR_HK');
      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  --END IF;




  -- Standard call for message generation
  IF jtf_usr_hks.Ok_To_Execute('CS_ServiceRequest_PVT',
                                      'Create_ServiceRequest',
                                      'M', 'M')  THEN

     IF (cs_servicerequest_cuhk.Ok_To_Generate_Msg(p_request_id => p_request_id,
                                                   p_service_request_rec=>l_service_request_rec)) THEN

       l_bind_data_id := JTF_USR_HKS.Get_bind_data_id;

       JTF_USR_HKS.Load_bind_data(l_bind_data_id, 'incident_id', p_request_id, 'S', 'N');

       JTF_USR_HKS.generate_message(p_prod_code => 'CS',
                                 p_bus_obj_code => 'SR',
                                 p_action_code => 'U',
                                 p_bind_data_id => l_bind_data_id,
                                 x_return_code => l_return_status);


       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         -- DBMS_OUTPUT.PUT_LINE('Returned Error Status from the Message Generation Hook');
            FND_MESSAGE.Set_Name('CS', 'CS_API_SR_ERR_MSG_GEN_HK');
            FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
            FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;
  END IF;
--
-- End of Post User Hooks
--
*/


  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;


  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_Preferred_Language_PVT;
    IF (l_Preferred_Language_csr%ISOPEN) THEN
      CLOSE l_Preferred_Language_csr;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_Preferred_Language_PVT;
    IF (l_Preferred_Language_csr%ISOPEN) THEN
      CLOSE l_Preferred_Language_csr;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

  WHEN OTHERS THEN
    ROLLBACK TO Update_Preferred_Language_PVT;
    IF (l_Preferred_Language_csr%ISOPEN) THEN
      CLOSE l_Preferred_Language_csr;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );


END Update_Preferred_Language;




PROCEDURE initialize_rec(
  p_preferred_lang_record        IN OUT NOCOPY preferred_language_rec_type
) AS
BEGIN
  p_preferred_lang_record.PREF_LANG_ID           := FND_API.G_MISS_NUM;
  p_preferred_lang_record.LANGUAGE_CODE          := FND_API.G_MISS_CHAR;
  p_preferred_lang_record.START_DATE_ACTIVE      := FND_API.G_MISS_DATE;
  p_preferred_lang_record.END_DATE_ACTIVE        := FND_API.G_MISS_DATE;
  p_preferred_lang_record.OBJECT_VERSION_NUMBER  := FND_API.G_MISS_NUM;
  p_preferred_lang_record.LAST_UPDATE_DATE       := FND_API.G_MISS_DATE;
  p_preferred_lang_record.LAST_UPDATED_BY        := FND_API.G_MISS_NUM;
  p_preferred_lang_record.CREATION_DATE          := FND_API.G_MISS_DATE;
  p_preferred_lang_record.CREATED_BY             := FND_API.G_MISS_NUM;
  p_preferred_lang_record.LAST_UPDATE_LOGIN      := FND_API.G_MISS_NUM;
  p_preferred_lang_record.ATTRIBUTE1             := FND_API.G_MISS_CHAR;
  p_preferred_lang_record.ATTRIBUTE2             := FND_API.G_MISS_CHAR;
  p_preferred_lang_record.ATTRIBUTE3             := FND_API.G_MISS_CHAR;
  p_preferred_lang_record.ATTRIBUTE4             := FND_API.G_MISS_CHAR;
  p_preferred_lang_record.ATTRIBUTE5             := FND_API.G_MISS_CHAR;
  p_preferred_lang_record.ATTRIBUTE6             := FND_API.G_MISS_CHAR;
  p_preferred_lang_record.ATTRIBUTE7             := FND_API.G_MISS_CHAR;
  p_preferred_lang_record.ATTRIBUTE8             := FND_API.G_MISS_CHAR;
  p_preferred_lang_record.ATTRIBUTE9             := FND_API.G_MISS_CHAR;
  p_preferred_lang_record.ATTRIBUTE10            := FND_API.G_MISS_CHAR;
  p_preferred_lang_record.ATTRIBUTE11            := FND_API.G_MISS_CHAR;
  p_preferred_lang_record.ATTRIBUTE12            := FND_API.G_MISS_CHAR;
  p_preferred_lang_record.ATTRIBUTE13            := FND_API.G_MISS_CHAR;
  p_preferred_lang_record.ATTRIBUTE14            := FND_API.G_MISS_CHAR;
  p_preferred_lang_record.ATTRIBUTE15            := FND_API.G_MISS_CHAR;
  p_preferred_lang_record.ATTRIBUTE_CATEGORY     := FND_API.G_MISS_CHAR;
  p_preferred_lang_record.INITIALIZE_FLAG        := G_INITIALIZED;
END initialize_rec;



-- Procedure Lock Row
-- This is called by the Preferred Language form to lock a record
PROCEDURE LOCK_ROW(
		    p_PREF_LANG_ID		IN	NUMBER,
		    p_OBJECT_VERSION_NUMBER	IN	NUMBER,
                    p_preferred_language_rec    IN      preferred_language_rec_type
		    )
IS
BEGIN

CS_SR_PREFERRED_LANG_PKG.LOCK_ROW (
  X_PREF_LANG_ID       => p_pref_lang_id,
  X_LANGUAGE_CODE      => p_preferred_language_rec.language_code,
  X_START_DATE_ACTIVE  => p_preferred_language_rec.start_date_active,
  X_END_DATE_ACTIVE    => p_preferred_language_rec.end_date_active,
  X_ATTRIBUTE_CATEGORY => p_preferred_language_rec.attribute_category,
  X_ATTRIBUTE1         => p_preferred_language_rec.attribute1,
  X_ATTRIBUTE2         => p_preferred_language_rec.attribute2,
  X_ATTRIBUTE3         => p_preferred_language_rec.attribute3,
  X_ATTRIBUTE4         => p_preferred_language_rec.attribute4,
  X_ATTRIBUTE5         => p_preferred_language_rec.attribute5,
  X_ATTRIBUTE6         => p_preferred_language_rec.attribute6,
  X_ATTRIBUTE7         => p_preferred_language_rec.attribute7,
  X_ATTRIBUTE8         => p_preferred_language_rec.attribute8,
  X_ATTRIBUTE9         => p_preferred_language_rec.attribute9,
  X_ATTRIBUTE10        => p_preferred_language_rec.attribute10,
  X_ATTRIBUTE11        => p_preferred_language_rec.attribute11,
  X_ATTRIBUTE12        => p_preferred_language_rec.attribute12,
  X_ATTRIBUTE13        => p_preferred_language_rec.attribute13,
  X_ATTRIBUTE14        => p_preferred_language_rec.attribute14,
  X_ATTRIBUTE15        => p_preferred_language_rec.attribute15,
  X_OBJECT_VERSION_NUMBER => p_object_version_number
);

END LOCK_ROW;

-- -------------------------------------------------------------------
-- Validate_Desc_Flex
-- -------------------------------------------------------------------

PROCEDURE Validate_Desc_Flex
( p_api_name                    IN      VARCHAR2,
  p_application_short_name      IN      VARCHAR2,
  p_desc_flex_name              IN      VARCHAR2,
  p_desc_segment1               IN      VARCHAR2,
  p_desc_segment2               IN      VARCHAR2,
  p_desc_segment3               IN      VARCHAR2,
  p_desc_segment4               IN      VARCHAR2,
  p_desc_segment5               IN      VARCHAR2,
  p_desc_segment6               IN      VARCHAR2,
  p_desc_segment7               IN      VARCHAR2,
  p_desc_segment8               IN      VARCHAR2,
  p_desc_segment9               IN      VARCHAR2,
  p_desc_segment10              IN      VARCHAR2,
  p_desc_segment11              IN      VARCHAR2,
  p_desc_segment12              IN      VARCHAR2,
  p_desc_segment13              IN      VARCHAR2,
  p_desc_segment14              IN      VARCHAR2,
  p_desc_segment15              IN      VARCHAR2,
  p_desc_context                IN      VARCHAR2,
  p_resp_appl_id                IN      NUMBER          := NULL,
  p_resp_id                     IN      NUMBER          := NULL,
  p_return_status               OUT     NOCOPY VARCHAR2
)
IS
  l_error_message       VARCHAR2(2000);
BEGIN
  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --dbms_output.put_line(' In the desc flex proc ') ;

  IF ( p_desc_context   || p_desc_segment1  || p_desc_segment2  ||
       p_desc_segment3  || p_desc_segment4  || p_desc_segment5  ||
       p_desc_segment6  || p_desc_segment7  || p_desc_segment8  ||
       p_desc_segment9  || p_desc_segment10 || p_desc_segment11 ||
       p_desc_segment12 || p_desc_segment13 || p_desc_segment14 ||
       p_desc_segment15
     ) IS NOT NULL THEN

    FND_FLEX_DESCVAL.Set_Context_Value(p_desc_context);
    FND_FLEX_DESCVAL.Set_Column_Value('PREF_LANG_ATTRIBUTE1', p_desc_segment1);
    FND_FLEX_DESCVAL.Set_Column_Value('PREF_LANG_ATTRIBUTE2', p_desc_segment2);
    FND_FLEX_DESCVAL.Set_Column_Value('PREF_LANG_ATTRIBUTE3', p_desc_segment3);
    FND_FLEX_DESCVAL.Set_Column_Value('PREF_LANG_ATTRIBUTE4', p_desc_segment4);
    FND_FLEX_DESCVAL.Set_Column_Value('PREF_LANG_ATTRIBUTE5', p_desc_segment5);
    FND_FLEX_DESCVAL.Set_Column_Value('PREF_LANG_ATTRIBUTE6', p_desc_segment6);
    FND_FLEX_DESCVAL.Set_Column_Value('PREF_LANG_ATTRIBUTE7', p_desc_segment7);
    FND_FLEX_DESCVAL.Set_Column_Value('PREF_LANG_ATTRIBUTE8', p_desc_segment8);
    FND_FLEX_DESCVAL.Set_Column_Value('PREF_LANG_ATTRIBUTE9', p_desc_segment9);
    FND_FLEX_DESCVAL.Set_Column_Value('PREF_LANG_ATTRIBUTE10', p_desc_segment10);
    FND_FLEX_DESCVAL.Set_Column_Value('PREF_LANG_ATTRIBUTE11', p_desc_segment11);
    FND_FLEX_DESCVAL.Set_Column_Value('PREF_LANG_ATTRIBUTE12', p_desc_segment12);
    FND_FLEX_DESCVAL.Set_Column_Value('PREF_LANG_ATTRIBUTE13', p_desc_segment13);
    FND_FLEX_DESCVAL.Set_Column_Value('PREF_LANG_ATTRIBUTE14', p_desc_segment14);
    FND_FLEX_DESCVAL.Set_Column_Value('PREF_LANG_ATTRIBUTE15', p_desc_segment15);
    IF NOT FND_FLEX_DESCVAL.Validate_Desccols
             ( appl_short_name => p_application_short_name,
               desc_flex_name  => p_desc_flex_name,
               resp_appl_id    => p_resp_appl_id,
               resp_id         => p_resp_id
             ) THEN
      l_error_message := FND_FLEX_DESCVAL.Error_Message;
      CS_ServiceRequest_UTIL.Add_Desc_Flex_Msg(p_api_name, l_error_message);
      p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

END Validate_Desc_Flex;


END CS_SR_Preferred_Lang_PVT;

/
