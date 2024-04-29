--------------------------------------------------------
--  DDL for Package Body IEX_WEBDIR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WEBDIR_PKG" AS
/* $Header: iexvwbab.pls 120.2 2005/07/06 19:16:17 jypark noship $ */


  G_PKG_NAME    CONSTANT VARCHAR2(30)   :='IEX_WEBDIR_PKG';
  G_FILE_NAME   CONSTANT VARCHAR2(12)   :='iexvwbas.pls';

  G_APPL_ID     NUMBER;
  G_LOGIN_ID    NUMBER;
  G_PROGRAM_ID  NUMBER;
  G_USER_ID     NUMBER;
  G_REQUEST_ID  NUMBER;

  PROCEDURE Create_WebAssist(
                      p_api_version IN NUMBER,
                      p_init_msg_list IN VARCHAR2,
                      p_commit IN VARCHAR2,
                      p_validation_level IN NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_msg_count OUT NOCOPY NUMBER,
                      x_msg_data OUT NOCOPY VARCHAR2,
                      p_assist_rec IN assist_rec_type,
                      p_web_assist_rec IN web_assist_rec_type,
                      p_web_search_rec IN web_search_rec_type,
                      p_query_string_rec IN query_string_rec_type
                      )
  IS
    l_api_version     CONSTANT     NUMBER       :=  1.0;
    l_api_name        CONSTANT     VARCHAR2(30) :=  'Create_WebAssist';
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

    CURSOR c1 IS SELECT 'X' FROM IEX_WEB_ASSISTS
     WHERE web_assist_id = p_web_assist_rec.web_assist_id;

    CURSOR c2 IS SELECT 'X' FROM IEX_WEB_SEARCHES
     WHERE search_id = p_web_search_rec.search_id;

    CURSOR c3 IS SELECT 'X' FROM IEX_QUERY_STRINGS
     WHERE query_string_id = p_query_string_rec.query_string_id;

    p_dummy CHAR(1);

    l_web_assist_rec web_assist_rec_type;
    l_web_search_rec web_search_rec_type;
    l_query_string_rec query_string_rec_type;
  BEGIN
    --  Standard begin of API savepoint
    SAVEPOINT Create_WebAssist_PVT;

    -- Standard call to check FOR call compatibility.
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
    IF p_web_assist_rec.web_assist_id IS NOT NULL
    THEN
      OPEN c1;
      FETCH c1 INTO P_DUMMY;
      IF c1%notfound THEN
        INSERT INTO IEX_WEB_ASSISTS(
          web_assist_id,
          assist_id,
          object_version_number,
          proxy_host,
          proxy_port,
          enabled_flag,
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
        VALUES(
           p_web_assist_rec.web_assist_id,
           p_web_assist_rec.assist_id,
           p_web_assist_rec.object_version_number,
           p_web_assist_rec.proxy_host,
           p_web_assist_rec.proxy_port,
           p_web_assist_rec.enabled_flag,
           p_web_assist_rec.last_update_date,
           p_web_assist_rec.creation_date,
           p_web_assist_rec.created_by,
           p_web_assist_rec.last_updated_by,
           p_web_assist_rec.last_update_login,
           p_web_assist_rec.attribute_category,
           p_web_assist_rec.attribute1,
           p_web_assist_rec.attribute2,
           p_web_assist_rec.attribute3,
           p_web_assist_rec.attribute4,
           p_web_assist_rec.attribute5,
           p_web_assist_rec.attribute6,
           p_web_assist_rec.attribute7,
           p_web_assist_rec.attribute8,
           p_web_assist_rec.attribute9,
           p_web_assist_rec.attribute10,
           p_web_assist_rec.attribute11,
           p_web_assist_rec.attribute12,
           p_web_assist_rec.attribute13,
           p_web_assist_rec.attribute14,
           p_web_assist_rec.attribute15
          );
      END IF;

      CLOSE c1;
    END IF;

    IF p_web_search_rec.search_id IS NOT NULL
    THEN
      OPEN c2;
      FETCH c2 INTO P_DUMMY;
      IF c2%notfound THEN
        INSERT INTO IEX_WEB_SEARCHES(
           search_id,
           web_assist_id,
           object_version_number,
           enabled_flag,
           search_url ,
           cgi_server,
           next_page_ident,
           max_nbr_pages,
           last_update_date,
           creation_date,
           created_by,
           last_updated_by,
           last_update_login,
           directory_assist_flag,  -- add by jypark 12/26/2000 for new requirement
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
        VALUES(
           p_web_search_rec.search_id,
           p_web_search_rec.web_assist_id,
           p_web_search_rec.object_version_number,
           p_web_search_rec.enabled_flag,
           p_web_search_rec.search_url,
           p_web_search_rec.cgi_server,
           p_web_search_rec.next_page_ident,
           p_web_search_rec.max_nbr_pages,
           p_web_search_rec.last_update_date,
           p_web_search_rec.creation_date,
           p_web_search_rec.created_by,
           p_web_search_rec.last_updated_by,
           p_web_search_rec.last_update_login,
           p_web_search_rec.directory_assist_flag,  -- add by jypark 12/26/2000 for new requirement
           p_web_search_rec.attribute_category,
           p_web_search_rec.attribute1,
           p_web_search_rec.attribute2,
           p_web_search_rec.attribute3,
           p_web_search_rec.attribute4,
           p_web_search_rec.attribute5,
           p_web_search_rec.attribute6,
           p_web_search_rec.attribute7,
           p_web_search_rec.attribute8,
           p_web_search_rec.attribute9,
           p_web_search_rec.attribute10,
           p_web_search_rec.attribute11,
           p_web_search_rec.attribute12,
           p_web_search_rec.attribute13,
           p_web_search_rec.attribute14,
           p_web_search_rec.attribute15
         );
      END IF;
      CLOSE c2;
    END IF;

    IF p_query_string_rec.query_string_id IS NOT NULL
    THEN
      OPEN c3;
      FETCH c3 INTO P_DUMMY;
      IF c3%notfound THEN
        INSERT INTO IEX_QUERY_STRINGS(
          query_string_id,
          search_id,
          object_version_number,
          switch_separator,
          url_separator,
          header_const,
          trailer_const,
          enabled_flag,
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
        VALUES(
           p_query_string_rec.query_string_id,
           p_query_string_rec.search_id,
           p_query_string_rec.object_version_number,
           p_query_string_rec.switch_separator,
           p_query_string_rec.url_separator,
           p_query_string_rec.header_const,
           p_query_string_rec.trailer_const,
           p_query_string_rec.enabled_flag,
           p_query_string_rec.last_update_date,
           p_query_string_rec.creation_date,
           p_query_string_rec.created_by,
           p_query_string_rec.last_updated_by,
           p_query_string_rec.last_update_login,
           p_query_string_rec.attribute_category,
           p_query_string_rec.attribute1,
           p_query_string_rec.attribute2,
           p_query_string_rec.attribute3,
           p_query_string_rec.attribute4,
           p_query_string_rec.attribute5,
           p_query_string_rec.attribute6,
           p_query_string_rec.attribute7,
           p_query_string_rec.attribute8,
           p_query_string_rec.attribute9,
           p_query_string_rec.attribute10,
           p_query_string_rec.attribute11,
           p_query_string_rec.attribute12,
           p_query_string_rec.attribute13,
           p_query_string_rec.attribute14,
           p_query_string_rec.attribute15
         );
      END IF;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count AND IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                p_data   =>  x_msg_data );


  --
  -- Normal API Exception handling, IF exception occurs outside of phone processing loop
  --
  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_WebAssist_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_WebAssist_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
      ROLLBACK TO Create_WebAssist_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );
  END;

  PROCEDURE Lock_WebAssist(
                      p_api_version IN NUMBER,
                      p_init_msg_list IN VARCHAR2,
                      p_commit IN VARCHAR2,
                      p_validation_level IN NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_msg_count OUT NOCOPY NUMBER,
                      x_msg_data OUT NOCOPY VARCHAR2,
                      p_assist_rec IN assist_rec_type,
                      p_web_assist_rec IN web_assist_rec_type,
                      p_web_search_rec IN web_search_rec_type,
                      p_query_string_rec IN query_string_rec_type
                      )
AS
    l_api_version     CONSTANT     NUMBER    :=  1.0;
    l_api_name        CONSTANT     VARCHAR2(30) :=  'Lock_WebAssist';
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

    l_web_assist_rec web_assist_rec_type;
    l_web_search_rec web_search_rec_type;
    l_query_string_rec query_string_rec_type;

BEGIN

    --  Standard begin of API savepoint
    SAVEPOINT Lock_WebAssist_PVT;

             -- Standard call to check FOR call compatibility.
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
      v_dummy char(1);

      CURSOR c1 IS SELECT 'X'
          FROM IEX_WEB_assists
          WHERE web_assist_id = p_web_assist_rec.web_assist_id
          FOR UPDATE;
    BEGIN
      OPEN c1;
      FETCH c1 INTO v_dummy;
      CLOSE c1;
    END;

    DECLARE
      v_dummy char(1);
      CURSOR c1 IS SELECT 'X'
          FROM IEX_WEB_searches
          WHERE search_id = p_web_search_rec.search_id
          FOR UPDATE;
    BEGIN
      OPEN c1;
      FETCH c1 INTO v_dummy;
      CLOSE c1;
    END;

    DECLARE
      v_dummy char(1);
      CURSOR c1 IS SELECT 'X'
          FROM iex_query_strings
          WHERE query_string_id = p_query_string_rec.query_string_id
          FOR UPDATE;
    BEGIN
      OPEN c1;
      FETCH c1 INTO v_dummy;
      CLOSE c1;
    END;

    -- ENDof API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count AND IF count is 1, get message info.

    FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                p_data   =>  x_msg_data );


  --
  -- Normal API Exception handling, IF exception occurs outside of phone processing loop
  --

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Lock_WebAssist_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Lock_WebAssist_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
      ROLLBACK TO Lock_WebAssist_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );
  END;

  PROCEDURE Update_WebAssist(
                      p_api_version IN NUMBER,
                      p_init_msg_list IN VARCHAR2,
                      p_commit IN VARCHAR2,
                      p_validation_level IN NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_msg_count OUT NOCOPY NUMBER,
                      x_msg_data OUT NOCOPY VARCHAR2,
                      p_assist_rec IN assist_rec_type,
                      p_web_assist_rec IN web_assist_rec_type,
                      p_web_search_rec IN web_search_rec_type,
                      p_query_string_rec IN query_string_rec_type
                      )
  IS
    l_api_version            CONSTANT     NUMBER    :=  1.0;
    l_api_name        CONSTANT     VARCHAR2(30) :=  'Update_WebAssist';
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

    l_web_assist_rec  web_assist_rec_type;
    l_web_search_rec  web_search_rec_type;
    l_query_string_rec  query_string_rec_type;

  BEGIN
    --  Standard begin of API savepoint
    SAVEPOINT Update_WebAssist_PVT;
    -- Standard call to check FOR call compatibility.
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
    /*   Copy all parameters to local variables to be passed to Pre, Post AND Business APIs  */
    /*  l_rec      -  will be used as In Out parameter  in pre/post/Business  API calls */
    /*  l_return_status  -  will be a OUT NOCOPY VARiable to get return code FROM called APIs  */
    l_web_assist_rec := p_web_assist_rec;
    l_web_search_rec := p_web_search_rec;
    l_query_string_rec := p_query_string_rec;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- API body
    UPDATE IEX_WEB_assists
    SET
      proxy_host = p_web_assist_rec.proxy_host,
      proxy_port = p_web_assist_rec.proxy_port,
      last_update_date = p_web_assist_rec.last_update_date,
      last_updated_by = p_web_assist_rec.last_updated_by,
      last_update_login = p_web_assist_rec.last_update_login,
      attribute_category = p_web_assist_rec.attribute_category,
      attribute1 = p_web_assist_rec.attribute1,
      attribute2 = p_web_assist_rec.attribute2,
      attribute3 = p_web_assist_rec.attribute3,
      attribute4 = p_web_assist_rec.attribute4,
      attribute5 = p_web_assist_rec.attribute5,
      attribute6 = p_web_assist_rec.attribute6,
      attribute7 = p_web_assist_rec.attribute7,
      attribute8 = p_web_assist_rec.attribute8,
      attribute9 = p_web_assist_rec.attribute9,
      attribute10 = p_web_assist_rec.attribute10,
      attribute11 = p_web_assist_rec.attribute11,
      attribute12 = p_web_assist_rec.attribute12,
      attribute13 = p_web_assist_rec.attribute13,
      attribute14 = p_web_assist_rec.attribute14,
      attribute15 = p_web_assist_rec.attribute15
    WHERE web_assist_id = p_web_assist_rec.web_assist_id;

    UPDATE IEX_WEB_searches
    SET
      enabled_flag = p_web_search_rec.enabled_flag,
      search_url  = p_web_search_rec.search_url,
      cgi_server = p_web_search_rec.cgi_server,
      next_page_ident = p_web_search_rec.next_page_ident,
      max_nbr_pages = p_web_search_rec.max_nbr_pages,
      last_update_date = p_web_search_rec.last_update_date,
      last_updated_by = p_web_search_rec.last_updated_by,
      last_update_login = p_web_search_rec.last_update_login,
	 directory_assist_flag = p_web_search_rec.directory_assist_flag, -- add by jypakr 12/26/2000 for new requirement
      attribute_category = p_web_search_rec.attribute_category,
      attribute1 = p_web_search_rec.attribute1,
      attribute2 = p_web_search_rec.attribute2,
      attribute3 = p_web_search_rec.attribute3,
      attribute4 = p_web_search_rec.attribute4,
      attribute5 = p_web_search_rec.attribute5,
      attribute6 = p_web_search_rec.attribute6,
      attribute7 = p_web_search_rec.attribute7,
      attribute8 = p_web_search_rec.attribute8,
      attribute9 = p_web_search_rec.attribute9,
      attribute10 = p_web_search_rec.attribute10,
      attribute11 = p_web_search_rec.attribute11,
      attribute12 = p_web_search_rec.attribute12,
      attribute13 = p_web_search_rec.attribute13,
      attribute14 = p_web_search_rec.attribute14,
      attribute15 = p_web_search_rec.attribute15
    WHERE search_id = p_web_search_rec.search_id;

    UPDATE iex_query_strings
    SET
      switch_separator = p_query_string_rec.switch_separator,
      url_separator = p_query_string_rec.url_separator,
      header_const = p_query_string_rec.header_const,
      trailer_const = p_query_string_rec.trailer_const,
      last_update_date = p_query_string_rec.last_update_date,
      last_updated_by = p_query_string_rec.last_updated_by,
      last_update_login = p_query_string_rec.last_update_login,
      attribute_category = p_query_string_rec.attribute_category,
      attribute1 = p_query_string_rec.attribute1,
      attribute2 = p_query_string_rec.attribute2,
      attribute3 = p_query_string_rec.attribute3,
      attribute4 = p_query_string_rec.attribute4,
      attribute5 = p_query_string_rec.attribute5,
      attribute6 = p_query_string_rec.attribute6,
      attribute7 = p_query_string_rec.attribute7,
      attribute8 = p_query_string_rec.attribute8,
      attribute9 = p_query_string_rec.attribute9,
      attribute10 = p_query_string_rec.attribute10,
      attribute11 = p_query_string_rec.attribute11,
      attribute12 = p_query_string_rec.attribute12,
      attribute13 = p_query_string_rec.attribute13,
      attribute14 = p_query_string_rec.attribute14,
      attribute15 = p_query_string_rec.attribute15
    WHERE query_string_id = p_query_string_rec.query_string_id;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count AND IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                p_data   =>  x_msg_data );


  --
  -- Normal API Exception handling, IF exception occurs outside of phone processing loop
  --
  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Update_WebAssist_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;

      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Update_WebAssist_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );

    WHEN OTHERS THEN

      ROLLBACK TO Update_WebAssist_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );

  END;

  PROCEDURE Delete_WebAssist(
                      p_api_version IN NUMBER,
                      p_init_msg_list IN VARCHAR2,
                      p_commit IN VARCHAR2,
                      p_validation_level IN NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_msg_count OUT NOCOPY NUMBER,
                      x_msg_data OUT NOCOPY VARCHAR2,
                      p_assist_rec IN assist_rec_type,
                      p_web_assist_rec IN web_assist_rec_type,
                      p_web_search_rec IN web_search_rec_type,
                      p_query_string_rec IN query_string_rec_type
                      )
  IS
    l_api_version      CONSTANT     NUMBER    :=  1.0;
    l_api_name        CONSTANT     VARCHAR2(30) :=  'Delete_WebAssist';
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

    l_web_assist_rec web_assist_rec_type;
    l_web_search_rec web_search_rec_type;
    l_query_string_rec query_string_rec_type;

  BEGIN
    --  Standard begin of API savepoint
    SAVEPOINT Delete_WebAssist_PVT;

    -- Standard call to check FOR call compatibility.
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
    /*   Copy all parameters to local variables to be passed to Pre, Post AND Business APIs  */
    /*  l_rec      -  will be used as In Out parameter  in pre/post/Business  API calls */
    /*  l_return_status  -  will be a OUT NOCOPY VARiable to get return code FROM called APIs  */
    l_web_assist_rec := p_web_assist_rec;
    l_web_search_rec := p_web_search_rec;
    l_query_string_rec := p_query_string_rec;

    --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- API body
    IF p_query_string_rec.query_string_id IS NOT NULL THEN
      DELETE FROM ast_query_strings
      WHERE query_string_id = p_query_string_rec.query_string_id;
    END IF;

    IF p_web_search_rec.search_id IS NOT NULL THEN
      DELETE FROM IEX_WEB_searches
      WHERE search_id = p_web_search_rec.search_id;
    END IF;

    IF p_web_assist_rec.web_assist_id IS NOT NULL THEN
      DELETE FROM IEX_WEB_assists
      WHERE web_assist_id = p_web_assist_rec.web_assist_id;
    END IF;


    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit ) THEN
      commit work;
    END IF;
    -- ENDof API body

    -- Standard call to get message count AND IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                p_data   =>  x_msg_data );


  --
  -- Normal API Exception handling, IF exception occurs outside of phone processing loop
  --
  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_WebAssist_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_WebAssist_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
      ROLLBACK TO Delete_WebAssist_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get ( p_count  =>  x_msg_count,
                                  p_data   =>  x_msg_data );
 END;
BEGIN

  G_APPL_ID     := FND_GLOBAL.Prog_Appl_Id;
  G_LOGIN_ID    := FND_GLOBAL.Conc_Login_Id;
  G_PROGRAM_ID  := FND_GLOBAL.Conc_Program_Id;
  G_USER_ID     := FND_GLOBAL.User_Id;
  G_REQUEST_ID  := FND_GLOBAL.Conc_Request_Id;
END IEX_WEBDIR_PKG;

/
