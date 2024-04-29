--------------------------------------------------------
--  DDL for Package Body IEX_WEBSWITCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WEBSWITCH_PVT" as
/* $Header: iexvadsb.pls 120.1 2005/07/06 19:23:53 jypark noship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30)   :='IEX_WEBSWITCH_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12) :='iexvadsb.pls';

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
    l_api_name                CONSTANT         VARCHAR2(30)     :=  'Create_WebSwitch';
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

     -- added these for user hooks
    l_cgi_switch_rec IEX_WEBSWITCH_PKG.cgi_switch_rec_type;
    l_switch_data_rec IEX_WEBSWITCH_PKG.switch_data_rec_type;
	l_cgi_switch_id NUMBER;
	l_switch_data_id NUMBER;

    CURSOR c_cgi_switch IS SELECT CGI_SWITCH_ID
                FROM IEX_CGI_SWITCHES
                WHERE QUERY_STRING_ID =l_cgi_switch_rec.QUERY_STRING_ID
                AND SWITCH_CODE = l_cgi_switch_rec.SWITCH_CODE;
    CURSOR c_switch_data IS SELECT IEX_SWITCH_DATA_S.NEXTVAL
               FROM SYS.DUAL;
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

   -- Implementation of User Hooks
    /*   Copy all parameters to local variables to be passed to Pre, Post and Business APIs  */
    /*  l_rec      -  will be used as In Out NOCOPY parameter  in pre/post/Business  API calls */
    /*  l_return_status  -  will be a out NOCOPY variable to get return code from called APIs  */

    l_cgi_switch_rec.query_string_id  := p_cgi_switch_rec.query_string_id;
    l_cgi_switch_rec.object_version_number := 1.0;
    l_cgi_switch_rec.enabled_flag := p_cgi_switch_rec.enabled_flag;
    l_cgi_switch_rec.switch_code  := p_cgi_switch_rec.switch_code;
    l_cgi_switch_rec.switch_type  := p_cgi_switch_rec.switch_type;
    l_cgi_switch_rec.is_required_yn  := p_cgi_switch_rec.is_required_yn;
    l_cgi_switch_rec.sort_order  := p_cgi_switch_rec.sort_order;
    l_cgi_switch_rec.data_separator := p_cgi_switch_rec.data_separator;
    l_cgi_switch_rec.last_update_date := sysdate;
    l_cgi_switch_rec.creation_date := sysdate;
    l_cgi_switch_rec.created_by := g_user_id;
    l_cgi_switch_rec.last_updated_by := g_user_id;
    l_cgi_switch_rec.last_update_login := g_login_id;
    l_cgi_switch_rec.attribute_category := p_cgi_switch_rec.attribute_category;
    l_cgi_switch_rec.attribute1 := p_cgi_switch_rec.attribute1;
    l_cgi_switch_rec.attribute2 := p_cgi_switch_rec.attribute2;
    l_cgi_switch_rec.attribute3 := p_cgi_switch_rec.attribute3;
    l_cgi_switch_rec.attribute4 := p_cgi_switch_rec.attribute4;
    l_cgi_switch_rec.attribute5 := p_cgi_switch_rec.attribute5;
    l_cgi_switch_rec.attribute6 := p_cgi_switch_rec.attribute6;
    l_cgi_switch_rec.attribute7 := p_cgi_switch_rec.attribute7;
    l_cgi_switch_rec.attribute8 := p_cgi_switch_rec.attribute8;
    l_cgi_switch_rec.attribute9 := p_cgi_switch_rec.attribute9;
    l_cgi_switch_rec.attribute10 := p_cgi_switch_rec.attribute10;
    l_cgi_switch_rec.attribute11 := p_cgi_switch_rec.attribute11;
    l_cgi_switch_rec.attribute12 := p_cgi_switch_rec.attribute12;
    l_cgi_switch_rec.attribute13 := p_cgi_switch_rec.attribute13;
    l_cgi_switch_rec.attribute14 := p_cgi_switch_rec.attribute14;
    l_cgi_switch_rec.attribute15 := p_cgi_switch_rec.attribute15;

    l_switch_data_rec.object_version_number := 1.0;
    l_switch_data_rec.enabled_flag := p_switch_data_rec.enabled_flag;
    l_switch_data_rec.first_name_yn  := p_switch_data_rec.first_name_yn;
    l_switch_data_rec.last_name_yn := p_switch_data_rec.last_name_yn;
    l_switch_data_rec.city_yn := p_switch_data_rec.city_yn;
    l_switch_data_rec.state_yn := p_switch_data_rec.state_yn;
    l_switch_data_rec.zip_yn := p_switch_data_rec.zip_yn;
    l_switch_data_rec.country_yn := p_switch_data_rec.country_yn;
    l_switch_data_rec.address_yn := p_switch_data_rec.address_yn;
    l_switch_data_rec.last_update_date := sysdate;
    l_switch_data_rec.creation_date := sysdate;
    l_switch_data_rec.created_by := g_user_id;
    l_switch_data_rec.last_updated_by := g_user_id;
    l_switch_data_rec.last_update_login := g_login_id;
    l_switch_data_rec.attribute_category := p_switch_data_rec.attribute_category;
    l_switch_data_rec.attribute1 := p_switch_data_rec.attribute1;
    l_switch_data_rec.attribute2 := p_switch_data_rec.attribute2;
    l_switch_data_rec.attribute3 := p_switch_data_rec.attribute3;
    l_switch_data_rec.attribute4 := p_switch_data_rec.attribute4;
    l_switch_data_rec.attribute5 := p_switch_data_rec.attribute5;
    l_switch_data_rec.attribute6 := p_switch_data_rec.attribute6;
    l_switch_data_rec.attribute7 := p_switch_data_rec.attribute7;
    l_switch_data_rec.attribute8 := p_switch_data_rec.attribute8;
    l_switch_data_rec.attribute9 := p_switch_data_rec.attribute9;
    l_switch_data_rec.attribute10 := p_switch_data_rec.attribute10;
    l_switch_data_rec.attribute11 := p_switch_data_rec.attribute11;
    l_switch_data_rec.attribute12 := p_switch_data_rec.attribute12;
    l_switch_data_rec.attribute13 := p_switch_data_rec.attribute13;
    l_switch_data_rec.attribute14 := p_switch_data_rec.attribute14;
    l_switch_data_rec.attribute15 := p_switch_data_rec.attribute15;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body
    OPEN c_cgi_switch;
    FETCH c_cgi_switch INTO l_cgi_switch_id;
    IF c_cgi_switch%NOTFOUND THEN
      CLOSE c_cgi_switch;
      DECLARE
        CURSOR c_cgi_switch_seq IS SELECT IEX_CGI_SWITCHES_S.NEXTVAL
                   FROM SYS.DUAL;
      BEGIN
        OPEN c_cgi_switch_seq;
        FETCH c_cgi_switch_seq INTO l_cgi_switch_id;
        CLOSE c_cgi_switch_seq;
      EXCEPTION
        WHEN OTHERS THEN
          null;
      END;
    ELSE
	  CLOSE c_cgi_switch;
    END IF;

    OPEN c_switch_data;
    FETCH c_switch_data INTO l_switch_data_id;
    CLOSE c_switch_data;


    l_cgi_switch_rec.cgi_switch_id  := l_cgi_switch_id;
    l_switch_data_rec.switch_data_id  := l_switch_data_id;
    l_switch_data_rec.cgi_switch_id  := l_cgi_switch_id;

    IEX_WEBSWITCH_PKG.Create_WebSwitch(
          p_api_version => p_api_version,
          p_init_msg_list => p_init_msg_list,
          p_commit => p_commit,
          p_validation_level => p_validation_level,
          x_return_status => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data,
          p_cgi_switch_rec => l_cgi_switch_rec,
          p_switch_data_rec => l_switch_data_rec
          );

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
    l_cgi_switch_rec IEX_WEBSWITCH_PKG.cgi_switch_rec_type;
    l_switch_data_rec IEX_WEBSWITCH_PKG.switch_data_rec_type;

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

   -- Implementation of User Hooks
    /*   Copy all parameters to local variables to be passed to Pre, Post and Business APIs  */
    /*  l_rec      -  will be used as In Out NOCOPY parameter  in pre/post/Business  API calls */
    /*  l_return_status  -  will be a out NOCOPY variable to get return code from called APIs  */

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

    l_cgi_switch_rec.query_string_id  := p_cgi_switch_rec.query_string_id;
    l_cgi_switch_rec.cgi_switch_id  := p_cgi_switch_rec.cgi_switch_id;
    l_cgi_switch_rec.object_version_number := 1.0;
    l_cgi_switch_rec.enabled_flag := p_cgi_switch_rec.enabled_flag;
    l_cgi_switch_rec.switch_code  := p_cgi_switch_rec.switch_code;
    l_cgi_switch_rec.switch_type  := p_cgi_switch_rec.switch_type;
    l_cgi_switch_rec.is_required_yn  := p_cgi_switch_rec.is_required_yn;
    l_cgi_switch_rec.sort_order  := p_cgi_switch_rec.sort_order;
    l_cgi_switch_rec.data_separator := p_cgi_switch_rec.data_separator;
    l_cgi_switch_rec.last_update_date := sysdate;
    l_cgi_switch_rec.creation_date := p_cgi_switch_rec.creation_date;
    l_cgi_switch_rec.created_by := p_cgi_switch_rec.created_by;
    l_cgi_switch_rec.last_updated_by := g_user_id;
    l_cgi_switch_rec.last_update_login := g_login_id;
    l_cgi_switch_rec.attribute_category := p_cgi_switch_rec.attribute_category;
    l_cgi_switch_rec.attribute1 := p_cgi_switch_rec.attribute1;
    l_cgi_switch_rec.attribute2 := p_cgi_switch_rec.attribute2;
    l_cgi_switch_rec.attribute3 := p_cgi_switch_rec.attribute3;
    l_cgi_switch_rec.attribute4 := p_cgi_switch_rec.attribute4;
    l_cgi_switch_rec.attribute5 := p_cgi_switch_rec.attribute5;
    l_cgi_switch_rec.attribute6 := p_cgi_switch_rec.attribute6;
    l_cgi_switch_rec.attribute7 := p_cgi_switch_rec.attribute7;
    l_cgi_switch_rec.attribute8 := p_cgi_switch_rec.attribute8;
    l_cgi_switch_rec.attribute9 := p_cgi_switch_rec.attribute9;
    l_cgi_switch_rec.attribute10 := p_cgi_switch_rec.attribute10;
    l_cgi_switch_rec.attribute11 := p_cgi_switch_rec.attribute11;
    l_cgi_switch_rec.attribute12 := p_cgi_switch_rec.attribute12;
    l_cgi_switch_rec.attribute13 := p_cgi_switch_rec.attribute13;
    l_cgi_switch_rec.attribute14 := p_cgi_switch_rec.attribute14;
    l_cgi_switch_rec.attribute15 := p_cgi_switch_rec.attribute15;

    l_switch_data_rec.switch_data_id := p_switch_data_rec.switch_data_id;
    l_switch_data_rec.cgi_switch_id := p_switch_data_rec.cgi_switch_id;
    l_switch_data_rec.object_version_number := 1.0;
    l_switch_data_rec.enabled_flag := p_switch_data_rec.enabled_flag;
    l_switch_data_rec.first_name_yn  := p_switch_data_rec.first_name_yn;
    l_switch_data_rec.last_name_yn := p_switch_data_rec.last_name_yn;
    l_switch_data_rec.city_yn := p_switch_data_rec.city_yn;
    l_switch_data_rec.state_yn := p_switch_data_rec.state_yn;
    l_switch_data_rec.zip_yn := p_switch_data_rec.zip_yn;
    l_switch_data_rec.country_yn := p_switch_data_rec.country_yn;
    l_switch_data_rec.address_yn := p_switch_data_rec.address_yn;
    l_switch_data_rec.last_update_date := sysdate;
    l_switch_data_rec.creation_date := p_switch_data_rec.creation_date;
    l_switch_data_rec.created_by := p_switch_data_rec.created_by;
    l_switch_data_rec.last_updated_by := g_user_id;
    l_switch_data_rec.last_update_login := g_login_id;
    l_switch_data_rec.attribute_category := p_switch_data_rec.attribute_category;
    l_switch_data_rec.attribute1 := p_switch_data_rec.attribute1;
    l_switch_data_rec.attribute2 := p_switch_data_rec.attribute2;
    l_switch_data_rec.attribute3 := p_switch_data_rec.attribute3;
    l_switch_data_rec.attribute4 := p_switch_data_rec.attribute4;
    l_switch_data_rec.attribute5 := p_switch_data_rec.attribute5;
    l_switch_data_rec.attribute6 := p_switch_data_rec.attribute6;
    l_switch_data_rec.attribute7 := p_switch_data_rec.attribute7;
    l_switch_data_rec.attribute8 := p_switch_data_rec.attribute8;
    l_switch_data_rec.attribute9 := p_switch_data_rec.attribute9;
    l_switch_data_rec.attribute10 := p_switch_data_rec.attribute10;
    l_switch_data_rec.attribute11 := p_switch_data_rec.attribute11;
    l_switch_data_rec.attribute12 := p_switch_data_rec.attribute12;
    l_switch_data_rec.attribute13 := p_switch_data_rec.attribute13;
    l_switch_data_rec.attribute14 := p_switch_data_rec.attribute14;
    l_switch_data_rec.attribute15 := p_switch_data_rec.attribute15;


    IEX_WEBSWITCH_PKG.Update_WebSwitch(
          p_api_version => p_api_version,
          p_init_msg_list => p_init_msg_list,
          p_commit => p_commit,
          p_validation_level => p_validation_level,
          x_return_status => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data,
          p_cgi_switch_rec => l_cgi_switch_rec,
          p_switch_data_rec => l_switch_data_rec
          );

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
BEGIN

G_APPL_ID         := FND_GLOBAL.Prog_Appl_Id;
G_LOGIN_ID        := FND_GLOBAL.Conc_Login_Id;
G_PROGRAM_ID      := FND_GLOBAL.Conc_Program_Id;
G_USER_ID         := FND_GLOBAL.User_Id;
G_REQUEST_ID      := FND_GLOBAL.Conc_Request_Id;
END;

/
