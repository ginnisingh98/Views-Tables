--------------------------------------------------------
--  DDL for Package Body IEX_WEBSWITCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WEBSWITCH_PKG" as
/* $Header: iexvwbsb.pls 120.1 2005/07/06 19:16:25 jypark noship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30)   :='IEX_WEBSWITCH_PKG';
G_FILE_NAME   CONSTANT VARCHAR2(12) :='iexvwbsw.pls';

G_APPL_ID         NUMBER;
G_LOGIN_ID        NUMBER;
G_PROGRAM_ID      NUMBER;
G_USER_ID         NUMBER;
G_REQUEST_ID      NUMBER;

  PROCEDURE Create_WebSwitch(
                      p_api_version              IN NUMBER,
                      p_init_msg_list            IN VARCHAR2,
                      p_commit                   IN VARCHAR2,
                      p_validation_level         IN NUMBER,
                      x_return_status            OUT NOCOPY VARCHAR2,
                      x_msg_count                OUT NOCOPY NUMBER,
                      x_msg_data                 OUT NOCOPY VARCHAR2,
                      p_cgi_switch_rec           IN cgi_switch_rec_type,
                      p_switch_data_rec          IN switch_data_rec_type
                      )
  AS
    l_api_version                CONSTANT         NUMBER            :=  1.0;
    l_api_name                CONSTANT         VARCHAR2(30)     :=  'Create_WebSearch';
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

    CURSOR c1 IS SELECT 'X' FROM  iex_cgi_switches
                 WHERE cgi_switch_id = p_cgi_switch_rec.cgi_switch_id;

    CURSOR c2 IS SELECT 'X' FROM iex_switch_data
                 WHERE switch_data_id = p_switch_data_rec.switch_data_id;

    l_dummy char(1);

     -- added these for user hooks
    l_cgi_switch_rec cgi_switch_rec_type;
    l_switch_data_rec switch_data_rec_type;
  begin
    --  Standard begin of API savepoint
    SAVEPOINT     Create_WebSwitch_PUB;

     -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                               p_api_version,
                               l_api_name,
                               G_PKG_NAME)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

     -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- API body
    OPEN c1;
    FETCH c1 INTO l_dummy;
    IF c1%notfound THEN

INSERT INTO iex_cgi_switches(
                            cgi_switch_id,
                            query_string_id,
                            enabled_flag,
                            object_version_number,
                            switch_code,
                            switch_type,
                            is_required_yn,
                            sort_order,
                            data_separator,
                            last_update_date,
                            creation_date,
                            created_by,
                            last_updated_by,
                            last_update_login,
                            attribute_category,
                            attribute1,
                            attribute2,
                            attribute3,
                            attribute4,
                            attribute5,
                            attribute6,
                            attribute7,
                            attribute8,
                            attribute9,
                            attribute10,
                            attribute11,
                            attribute12,
                            attribute13,
                            attribute14,
                            attribute15
                            )
      VALUES (
           p_cgi_switch_rec.cgi_switch_id,
           p_cgi_switch_rec.query_string_id,
           p_cgi_switch_rec.enabled_flag,
           p_cgi_switch_rec.object_version_number,
           p_cgi_switch_rec.switch_code,
           p_cgi_switch_rec.switch_type,
           p_cgi_switch_rec.is_required_yn,
           p_cgi_switch_rec.sort_order,
           p_cgi_switch_rec.data_separator,
           p_cgi_switch_rec.last_update_date,
           p_cgi_switch_rec.creation_date,
           p_cgi_switch_rec.created_by,
           p_cgi_switch_rec.last_updated_by,
           p_cgi_switch_rec.last_update_login,
           p_cgi_switch_rec.attribute_category,
           p_cgi_switch_rec.attribute1,
           p_cgi_switch_rec.attribute2,
           p_cgi_switch_rec.attribute3,
           p_cgi_switch_rec.attribute4,
           p_cgi_switch_rec.attribute5,
           p_cgi_switch_rec.attribute6,
           p_cgi_switch_rec.attribute7,
           p_cgi_switch_rec.attribute8,
           p_cgi_switch_rec.attribute9,
           p_cgi_switch_rec.attribute10,
           p_cgi_switch_rec.attribute11,
           p_cgi_switch_rec.attribute12,
           p_cgi_switch_rec.attribute13,
           p_cgi_switch_rec.attribute14,
           p_cgi_switch_rec.attribute15
           );
    END IF;
    CLOSE c1;

    OPEN c2;
    FETCH c2 INTO l_dummy;
    IF c2%notfound THEN
      INSERT INTO iex_switch_data(
                           switch_data_id,
                           cgi_switch_id,
                           enabled_flag,
                           object_version_number,
                           first_name_yn,
                           last_name_yn,
                           address_yn,
                           city_yn,
                           state_yn,
                           zip_yn,
                           country_yn,
                           last_update_date,
                           creation_date,
                           created_by,
                           last_updated_by,
                           last_update_login,
                           attribute_category,
                           attribute1,
                           attribute2,
                           attribute3,
                           attribute4,
                           attribute5,
                           attribute6,
                           attribute7,
                           attribute8,
                           attribute9,
                           attribute10,
                           attribute11,
                           attribute12,
                           attribute13,
                           attribute14,
                           attribute15
                           )
      VALUES (
           p_switch_data_rec.switch_data_id,
           p_switch_data_rec.cgi_switch_id,
           p_switch_data_rec.enabled_flag,
           p_switch_data_rec.object_version_number,
           p_switch_data_rec.first_name_yn,
           p_switch_data_rec.last_name_yn,
           p_switch_data_rec.address_yn,
           p_switch_data_rec.city_yn,
           p_switch_data_rec.state_yn,
           p_switch_data_rec.zip_yn,
           p_switch_data_rec.country_yn,
           p_switch_data_rec.last_update_date,
           p_switch_data_rec.creation_date,
           p_switch_data_rec.created_by,
           p_switch_data_rec.last_updated_by,
           p_switch_data_rec.last_update_login,
           p_switch_data_rec.attribute_category,
           p_switch_data_rec.attribute1,
           p_switch_data_rec.attribute2,
           p_switch_data_rec.attribute3,
           p_switch_data_rec.attribute4,
           p_switch_data_rec.attribute5,
           p_switch_data_rec.attribute6,
           p_switch_data_rec.attribute7,
           p_switch_data_rec.attribute8,
           p_switch_data_rec.attribute9,
           p_switch_data_rec.attribute10,
           p_switch_data_rec.attribute11,
           p_switch_data_rec.attribute12,
           p_switch_data_rec.attribute13,
           p_switch_data_rec.attribute14,
           p_switch_data_rec.attribute15
           );
    END IF;
    CLOSE c2;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
      FND_MESSAGE.Set_Name('ast', 'Pvt WebAssist API: End');
      FND_MSG_PUB.Add;
    END IF;

    -- Standard call to get message count and IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                p_data   =>  x_msg_data );


  --
  -- Normal API Exception handling, IF exception occurs outside of phone processing loop
  --
  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Create_WebSwitch_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Create_WebSwitch_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );

    WHEN OTHERS THEN

      ROLLBACK TO Create_WebSwitch_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );

  END;

  PROCEDURE Update_WebSwitch(
                      p_api_version              IN NUMBER,
                      p_init_msg_list            IN VARCHAR2,
                      p_commit                   IN VARCHAR2,
                      p_validation_level         IN NUMBER,
                      x_return_status            OUT NOCOPY VARCHAR2,
                      x_msg_count                OUT NOCOPY NUMBER,
                      x_msg_data                 OUT NOCOPY VARCHAR2,
                      p_cgi_switch_rec           IN cgi_switch_rec_type,
                      p_switch_data_rec          IN switch_data_rec_type
                      )
  AS
    l_api_version                CONSTANT         NUMBER            :=  1.0;
    l_api_name                CONSTANT         VARCHAR2(30)     :=  'Update_WebSwitch';
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    -- added these for user hooks
    l_cgi_switch_rec cgi_switch_rec_type;
    l_switch_data_rec switch_data_rec_type;

  begin
    --  Standard begin of API savepoint
    SAVEPOINT     Update_WebSwitch_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                               p_api_version,
                               l_api_name,
                               G_PKG_NAME)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

     -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;


     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body
    UPDATE iex_cgi_switches
    SET
      switch_code = p_cgi_switch_rec.switch_code,
      switch_type = p_cgi_switch_rec.switch_type,
      enabled_flag = p_cgi_switch_rec.enabled_flag,
      is_required_yn = p_cgi_switch_rec.is_required_yn,
      sort_order = p_cgi_switch_rec.sort_order,
      data_separator = p_cgi_switch_rec.data_separator,
      last_update_date = p_cgi_switch_rec.last_update_date,
      last_updated_by = p_cgi_switch_rec.last_updated_by,
      last_update_login = p_cgi_switch_rec.last_update_login,
      attribute_category = p_cgi_switch_rec.attribute_category,
      attribute1 = p_cgi_switch_rec.attribute1,
      attribute2 = p_cgi_switch_rec.attribute2,
      attribute3 = p_cgi_switch_rec.attribute3,
      attribute4 = p_cgi_switch_rec.attribute4,
      attribute5 = p_cgi_switch_rec.attribute5,
      attribute6 = p_cgi_switch_rec.attribute6,
      attribute7 = p_cgi_switch_rec.attribute7,
      attribute8 = p_cgi_switch_rec.attribute8,
      attribute9 = p_cgi_switch_rec.attribute9,
      attribute10 = p_cgi_switch_rec.attribute10,
      attribute11 = p_cgi_switch_rec.attribute11,
      attribute12 = p_cgi_switch_rec.attribute12,
      attribute13 = p_cgi_switch_rec.attribute13,
      attribute14 = p_cgi_switch_rec.attribute14,
      attribute15 = p_cgi_switch_rec.attribute15
    WHERE query_string_id = p_cgi_switch_rec.query_string_id
    AND cgi_switch_id = p_cgi_switch_rec.cgi_switch_id;

    UPDATE iex_switch_data
    SET
      first_name_yn = p_switch_data_rec.first_name_yn,
      last_name_yn = p_switch_data_rec.last_name_yn,
      address_yn = p_switch_data_rec.address_yn,
      city_yn = p_switch_data_rec.city_yn,
      state_yn = p_switch_data_rec.state_yn,
      zip_yn = p_switch_data_rec.zip_yn,
      country_yn = p_switch_data_rec.country_yn,
      enabled_flag = p_switch_data_rec.enabled_flag,
      last_update_date = p_switch_data_rec.last_update_date,
      last_updated_by = p_switch_data_rec.last_updated_by,
      last_update_login = p_switch_data_rec.last_update_login,
      attribute_category = p_switch_data_rec.attribute_category,
      attribute1 = p_switch_data_rec.attribute1,
      attribute2 = p_switch_data_rec.attribute2,
      attribute3 = p_switch_data_rec.attribute3,
      attribute4 = p_switch_data_rec.attribute4,
      attribute5 = p_switch_data_rec.attribute5,
      attribute6 = p_switch_data_rec.attribute6,
      attribute7 = p_switch_data_rec.attribute7,
      attribute8 = p_switch_data_rec.attribute8,
      attribute9 = p_switch_data_rec.attribute9,
      attribute10 = p_switch_data_rec.attribute10,
      attribute11 = p_switch_data_rec.attribute11,
      attribute12 = p_switch_data_rec.attribute12,
      attribute13 = p_switch_data_rec.attribute13,
      attribute14 = p_switch_data_rec.attribute14,
      attribute15 = p_switch_data_rec.attribute15
    WHERE cgi_switch_id = p_switch_data_rec.cgi_switch_id
    AND switch_data_id = p_switch_data_rec.switch_data_id;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                p_data   =>  x_msg_data );


  --
  -- Normal API Exception handling, IF exception occurs outside of phone processing loop
  --
  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Update_WebSwitch_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Update_WebSwitch_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );

    WHEN OTHERS THEN

      ROLLBACK TO Update_WebSwitch_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );

  END;

  PROCEDURE Lock_WebSwitch(                      p_api_version              IN NUMBER,
                      p_init_msg_list            IN VARCHAR2,
                      p_commit                   IN VARCHAR2,
                      p_validation_level         IN NUMBER,
                      x_return_status            OUT NOCOPY VARCHAR2,
                      x_msg_count                OUT NOCOPY NUMBER,
                      x_msg_data                 OUT NOCOPY VARCHAR2,
                      p_cgi_switch_rec           IN cgi_switch_rec_type,
                      p_switch_data_rec          IN switch_data_rec_type
                      )
  AS
    l_api_version                CONSTANT         NUMBER            :=  1.0;
    l_api_name                CONSTANT         VARCHAR2(30)     :=  'Lock_WebSwitch';
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

    -- added these for user hookes
    l_cgi_switch_rec cgi_switch_rec_type;
    l_switch_data_rec switch_data_rec_type;

  begin
   --  Standard begin of API savepoint
    SAVEPOINT     Lock_WebSwitch_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                               p_api_version,
                               l_api_name,
                               G_PKG_NAME)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

-- API body
     DECLARE
         v_dummy CHAR(1);
         CURSOR c1 IS SELECT 'X'
                   FROM iex_cgi_switches
                   WHERE cgi_switch_id = p_cgi_switch_rec.cgi_switch_id
                   FOR UPDATE;
      BEGIN
         OPEN c1;
         FETCH c1 INTO v_dummy;
         CLOSE c1;
      END;

      DECLARE
         v_dummy Char(1);
         CURSOR c1 IS SELECT 'X'
                   FROM iex_switch_data
                   WHERE switch_data_id = p_switch_data_rec.switch_data_id
                   FOR UPDATE;
      BEGIN
         OPEN c1;
         FETCH c1 INTO v_dummy;
         CLOSE c1;
      END;


    -- Success Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
      FND_MESSAGE.Set_Name('ast', 'API_ROWS_UPDATED');
      FND_MESSAGE.Set_Token('ROW', 'ast_QUERY_STRING', TRUE);
      FND_MESSAGE.Set_Token('NUMBER', 1, FALSE);
      FND_MSG_PUB.Add;
    END IF;

    -- END of API body



    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                p_data   =>  x_msg_data );


  --
  -- Normal API Exception handling, IF exception occurs outside of phone processing loop
  --
  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Lock_WebSwitch_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Lock_WebSwitch_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );

    WHEN OTHERS THEN

      ROLLBACK TO Lock_WebSwitch_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );

  END;

  PROCEDURE Delete_WebSwitch(
                      p_api_version              IN NUMBER,
                      p_init_msg_list            IN VARCHAR2,
                      p_commit                   IN VARCHAR2,
                      p_validation_level         IN NUMBER,
                      x_return_status            OUT NOCOPY VARCHAR2,
                      x_msg_count                OUT NOCOPY NUMBER,
                      x_msg_data                 OUT NOCOPY VARCHAR2,
                      p_cgi_switch_rec           IN cgi_switch_rec_type,
                      p_switch_data_rec          IN switch_data_rec_type
                      )
  AS
    l_api_version                CONSTANT         NUMBER            :=  1.0;
    l_api_name                CONSTANT         VARCHAR2(30)     :=  'Delete_WebSwitch';
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

    -- added these for user hookes
    l_cgi_switch_rec cgi_switch_rec_type;
    l_switch_data_rec switch_data_rec_type;

  begin
     --  Standard begin of API savepoint
    SAVEPOINT     Delete_WebSwitch_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                               p_api_version,
                               l_api_name,
                               G_PKG_NAME)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body
    IF p_switch_data_rec.switch_data_id IS NOT NULL THEN
      DELETE FROM iex_switch_data
      WHERE switch_data_id = p_switch_data_rec.switch_data_id;
    END IF;


    IF p_cgi_switch_rec.cgi_switch_id IS NOT NULL THEN
      DELETE FROM iex_cgi_switches
      WHERE cgi_switch_id = p_cgi_switch_rec.cgi_switch_id;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
      FND_MESSAGE.Set_Name('ast', 'Pvt WebAssist API: End');
      FND_MSG_PUB.Add;
    END IF;

    -- Standard call to get message count and IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                p_data   =>  x_msg_data );


  --
  -- Normal API Exception handling, IF exception occurs outside of phone processing loop
  --
  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Delete_WebSwitch_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Delete_WebSwitch_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );

    WHEN OTHERS THEN

      ROLLBACK TO Delete_WebSwitch_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );

  END;

BEGIN
G_APPL_ID  := FND_GLOBAL.Prog_Appl_Id;
G_LOGIN_ID := FND_GLOBAL.Conc_Login_Id;
G_PROGRAM_ID      := FND_GLOBAL.Conc_Program_Id;
G_USER_ID         := FND_GLOBAL.User_Id;
G_REQUEST_ID      := FND_GLOBAL.Conc_Request_Id;

END;

/
