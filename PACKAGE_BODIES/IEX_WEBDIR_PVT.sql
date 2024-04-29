--------------------------------------------------------
--  DDL for Package Body IEX_WEBDIR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_WEBDIR_PVT" AS
/* $Header: iexvadwb.pls 120.1 2005/07/06 19:23:34 jypark noship $ */
  G_PKG_NAME    CONSTANT VARCHAR2(30)   :='iex_WebDir_Pvt';
  G_FILE_NAME   CONSTANT VARCHAR2(12)   :='iexvadws.pls';

  G_APPL_ID     NUMBER;
  G_LOGIN_ID    NUMBER;
  G_PROGRAM_ID  NUMBER;
  G_USER_ID     NUMBER;
  G_REQUEST_ID  NUMBER;

  PG_DEBUG NUMBER(2);

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

    l_assist_rec IEX_WEBDIR_PKG.assist_rec_type;
    l_web_assist_rec IEX_WEBDIR_PKG.web_assist_rec_type;
    l_web_search_rec IEX_WEBDIR_PKG.web_search_rec_type;
    l_query_string_rec IEX_WEBDIR_PKG.query_string_rec_type;
    l_assist_id NUMBER;
    l_web_assist_id NUMBER;
    l_search_id NUMBER;
    l_query_string_id NUMBER;
    l_user_id NUMBER;
    l_login_id NUMBER;

    CURSOR c_web_assist IS
	 SELECT WEB_ASSIST_ID
	 FROM IEX_WEB_ASSISTS
	 WHERE PROXY_HOST = l_web_assist_rec.proxy_host
	 AND PROXY_PORT = l_web_assist_rec.proxy_port;

    CURSOR c_web_search IS
	 SELECT SEARCH_ID
	 FROM IEX_WEB_SEARCHES
	 WHERE SEARCH_URL = l_web_search_rec.search_url
	 AND CGI_SERVER = l_web_search_rec.cgi_server;

    CURSOR c_query_seq IS
	 SELECT IEX_QUERY_STRINGS_S.NEXTVAL
      FROM SYS.DUAL;

  BEGIN
    --  Standard begin of API savepoint
    SAVEPOINT Create_WebAssist_PVT;

    -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

   -- Implementation of User Hooks
    /*   Copy all parameters to local variables to be passed to Pre, Post AND Business APIs  */
    /*  l_rec      -  will be used as In Out NOCOPY parameter  in pre/post/Business  API calls */
    /*  l_return_status  -  will be a out NOCOPY variable to get return code FROM called APIs  */

    l_user_id := fnd_profile.value('USER_ID');
    l_login_id := fnd_profile.value('LOGIN_ID');

    l_assist_rec.assistance_type := 'WEB_ASSIST';
    l_assist_rec.object_version_number := 1.0;
    l_assist_rec.last_update_date := sysdate;
    l_assist_rec.creation_date := sysdate;
    l_assist_rec.created_by := l_user_id;
    l_assist_rec.last_updated_by := l_user_id;
    l_assist_rec.last_update_login := l_login_id;

    l_web_assist_rec.object_version_number := 1.0;
    l_web_assist_rec.proxy_host   := p_web_assist_rec.proxy_host;
    l_web_assist_rec.proxy_port   := p_web_assist_rec.proxy_port;
    l_web_assist_rec.enabled_flag := p_web_search_rec.enabled_flag;
    l_web_assist_rec.last_update_date := sysdate;
    l_web_assist_rec.creation_date := sysdate;
    l_web_assist_rec.created_by := l_user_id;
    l_web_assist_rec.last_updated_by := l_user_id;
    l_web_assist_rec.last_update_login := l_login_id;

    l_web_search_rec.object_version_number := 1.0;
    l_web_search_rec.enabled_flag := p_web_search_rec.enabled_flag;
    l_web_search_rec.search_url   := p_web_search_rec.search_url;
    l_web_search_rec.cgi_server   := p_web_search_rec.cgi_server;
    l_web_search_rec.next_page_ident     := p_web_search_rec.next_page_ident;
    l_web_search_rec.max_nbr_pages := p_web_search_rec.max_nbr_pages;
    l_web_search_rec.last_update_date := sysdate;
    l_web_search_rec.creation_date := sysdate;
    l_web_search_rec.created_by := l_user_id;
    l_web_search_rec.last_updated_by := l_user_id;
    l_web_search_rec.last_update_login := l_login_id;
    l_web_search_rec.directory_assist_flag := p_web_search_rec.directory_assist_flag;


    l_query_string_rec.object_version_number := 1.0;
    l_query_string_rec.switch_separator    := p_query_string_rec.switch_separator;
    l_query_string_rec.url_separator := p_query_string_rec.url_separator;
    l_query_string_rec.header_const := p_query_string_rec.header_const;
    l_query_string_rec.trailer_const := p_query_string_rec.trailer_const;
    l_query_string_rec.enabled_flag := p_web_search_rec.enabled_flag;
    l_query_string_rec.last_update_date := sysdate;
    l_query_string_rec.creation_date := sysdate;
    l_query_string_rec.created_by := l_user_id;
    l_query_string_rec.last_updated_by := l_user_id;
    l_query_string_rec.last_update_login := l_login_id;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    OPEN c_web_assist;
    FETCH c_web_assist INTO l_web_assist_id;
    IF c_web_assist%NOTFOUND THEN
      DECLARE
	    CURSOR c_web_assist_seq IS
		  SELECT IEX_WEB_ASSISTS_S.NEXTVAL
	      FROM SYS.DUAL;
      BEGIN
	    CLOSE c_web_assist;
	    OPEN c_web_assist_seq;
	    FETCH c_web_assist_seq INTO l_web_assist_id;
	    CLOSE c_web_assist_seq;
	  EXCEPTION
	    WHEN OTHERS THEN
	      null;
	 END;
    ELSE
      --dbms_output.put_line('OLD ID1 > ' || l_web_assist_id);
	 CLOSE c_web_assist;
    END IF;

    OPEN c_web_search;
    FETCH c_web_search INTO l_search_id;
    IF c_web_search%NOTFOUND THEN
	  DECLARE
        CURSOR c_search_seq IS
	     SELECT IEX_WEB_SEARCHES_S.NEXTVAL
	     FROM SYS.DUAL;
      BEGIN
	    CLOSE c_web_search;
	    OPEN c_search_seq;
	    FETCH c_search_seq INTO l_search_id;
	    CLOSE c_search_seq;
	  EXCEPTION
	    WHEN OTHERS THEN
	      null;
	 END;
    ELSE
      CLOSE c_web_search;
    END IF;

    OPEN c_query_seq;
    FETCH c_query_seq INTO l_query_string_id;
    CLOSE c_query_seq;

    l_assist_rec.assist_id := l_assist_id;

    l_web_assist_rec.web_assist_id := l_web_assist_id;
    l_web_assist_rec.assist_id := l_assist_id;

    l_web_search_rec.search_id := l_search_id;
    l_web_search_rec.web_assist_id := l_web_assist_id;

    l_query_string_rec.query_string_id := l_query_string_id;
    l_query_string_rec.search_id := l_search_id;

    IEX_WEBDIR_PKG.Create_WebAssist(
 	P_API_VERSION => l_api_version,
     P_INIT_MSG_LIST => p_init_msg_list,
 	P_COMMIT => p_commit,
 	P_VALIDATION_LEVEL => p_validation_level,
 	X_RETURN_STATUS => x_return_status,
 	X_MSG_COUNT => x_msg_count,
 	X_MSG_DATA => x_msg_data,
 	p_assist_rec => l_assist_rec,
 	p_web_assist_rec => l_web_assist_rec,
 	p_web_search_rec => l_web_search_rec,
 	p_query_string_rec => l_query_string_rec
    );

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
  END Create_WebAssist;

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
    l_api_version     CONSTANT     NUMBER       :=  1.0;
    l_api_name        CONSTANT     VARCHAR2(30) :=  'Create_WebAssist';
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

    l_assist_rec IEX_WEBDIR_PKG.assist_rec_type;
    l_web_assist_rec IEX_WEBDIR_PKG.web_assist_rec_type;
    l_web_search_rec IEX_WEBDIR_PKG.web_search_rec_type;
    l_query_string_rec IEX_WEBDIR_PKG.query_string_rec_type;

    l_user_id NUMBER;
    l_login_id NUMBER;

  BEGIN
    --  Standard begin of API savepoint
    SAVEPOINT Update_WebAssist_PVT;

    -- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

   -- Implementation of User Hooks
    /*   Copy all parameters to local variables to be passed to Pre, Post AND Business APIs  */
    /*  l_rec      -  will be used as In Out NOCOPY parameter  in pre/post/Business  API calls */
    /*  l_return_status  -  will be a out NOCOPY variable to get return code FROM called APIs  */

    l_user_id := fnd_profile.value('USER_ID');
    l_login_id := fnd_profile.value('LOGIN_ID');

    l_assist_rec.assist_id := p_assist_rec.assist_id;
    l_assist_rec.assistance_type := p_assist_rec.assistance_type;
    l_assist_rec.object_version_number := p_assist_rec.object_version_number;
    l_assist_rec.last_update_date := sysdate;
    l_assist_rec.last_updated_by := l_user_id;
    l_assist_rec.last_update_login := l_login_id;
    l_assist_rec.creation_date := p_assist_rec.creation_date;
    l_assist_rec.created_by := p_assist_rec.created_by;

    l_web_assist_rec.web_assist_id := p_web_assist_rec.web_assist_id;
    l_web_assist_rec.assist_id := p_web_assist_rec.assist_id;
    l_web_assist_rec.object_version_number := 1.0;
    l_web_assist_rec.proxy_host   := p_web_assist_rec.proxy_host;
    l_web_assist_rec.proxy_port   := p_web_assist_rec.proxy_port;
    l_web_assist_rec.enabled_flag := p_web_search_rec.enabled_flag;
    l_web_assist_rec.last_update_date := sysdate;
    l_web_assist_rec.last_updated_by := l_user_id;
    l_web_assist_rec.last_update_login := l_login_id;
    l_web_assist_rec.creation_date := p_web_assist_rec.creation_date;
    l_web_assist_rec.created_by := p_web_assist_rec.created_by;

    l_web_search_rec.search_id := p_web_search_rec.search_id;
    l_web_search_rec.web_assist_id := p_web_search_rec.web_assist_id;
    l_web_search_rec.object_version_number := 1.0;
    l_web_search_rec.enabled_flag := p_web_search_rec.enabled_flag;
    l_web_search_rec.search_url   := p_web_search_rec.search_url;
    l_web_search_rec.cgi_server   := p_web_search_rec.cgi_server;
    l_web_search_rec.next_page_ident     := p_web_search_rec.next_page_ident;
    l_web_search_rec.max_nbr_pages := p_web_search_rec.max_nbr_pages;
    l_web_search_rec.last_update_date := sysdate;
    l_web_search_rec.last_updated_by := l_user_id;
    l_web_search_rec.last_update_login := l_login_id;
    l_web_search_rec.directory_assist_flag := p_web_search_rec.directory_assist_flag;
    l_web_search_rec.creation_date := p_web_search_rec.creation_date;
    l_web_search_rec.created_by := p_web_search_rec.created_by;


    l_query_string_rec.query_string_id := p_query_string_rec.query_string_id;
    l_query_string_rec.search_id := p_query_string_rec.search_id;
    l_query_string_rec.object_version_number := 1.0;
    l_query_string_rec.switch_separator    := p_query_string_rec.switch_separator;
    l_query_string_rec.url_separator := p_query_string_rec.url_separator;
    l_query_string_rec.header_const := p_query_string_rec.header_const;
    l_query_string_rec.trailer_const := p_query_string_rec.trailer_const;
    l_query_string_rec.enabled_flag := p_web_search_rec.enabled_flag;
    l_query_string_rec.last_update_date := sysdate;
    l_query_string_rec.last_updated_by := l_user_id;
    l_query_string_rec.last_update_login := l_login_id;
    l_query_string_rec.creation_date := p_query_string_rec.creation_date;
    l_query_string_rec.created_by := p_query_string_rec.created_by;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    IEX_WEBDIR_PKG.Update_WebAssist(
 	P_API_VERSION => l_api_version,
     P_INIT_MSG_LIST => p_init_msg_list,
 	P_COMMIT => p_commit,
 	P_VALIDATION_LEVEL => p_validation_level,
 	X_RETURN_STATUS => x_return_status,
 	X_MSG_COUNT => x_msg_count,
 	X_MSG_DATA => x_msg_data,
 	p_assist_rec => l_assist_rec,
 	p_web_assist_rec => l_web_assist_rec,
 	p_web_search_rec => l_web_search_rec,
 	p_query_string_rec => l_query_string_rec
    );

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
 END Update_WebAssist;
BEGIN
  G_APPL_ID     := FND_GLOBAL.Prog_Appl_Id;
  G_LOGIN_ID    := FND_GLOBAL.Conc_Login_Id;
  G_PROGRAM_ID  := FND_GLOBAL.Conc_Program_Id;
  G_USER_ID     := FND_GLOBAL.User_Id;
  G_REQUEST_ID  := FND_GLOBAL.Conc_Request_Id;

  PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

END iex_WebDir_Pvt;

/
