--------------------------------------------------------
--  DDL for Package Body JTF_XML_IA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_XML_IA_PUB" AS
/* $Header: jtfxmliab.pls 115.5 2001/04/10 09:57:33 pkm ship       $ */

-- global variables --
G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_XML_IA_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(16):='jtfxmliab.pls';

G_LOGIN_ID      NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
G_USER_ID       NUMBER := FND_GLOBAL.USER_ID;


PROCEDURE CREATE_AUTH (
  p_api_version		IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_URL			IN	VARCHAR2,
  p_AUTH_NAME		IN	VARCHAR2,
  p_AUTH_TYPE		IN	VARCHAR2,
  p_AUTH_INFO		IN	VARCHAR2,

  p_AUTH_ID 		OUT 	NUMBER,
  p_OBJECT_VERSION	OUT	NUMBER,

  x_return_status       OUT     VARCHAR2,
  x_msg_count           OUT     NUMBER,
  x_msg_data            OUT     VARCHAR2
) AS
        -- local variables --
        l_api_name       	CONSTANT VARCHAR2(30)   := 'CREATE_AUTH';
        l_api_version    	NUMBER  := p_api_version;
        l_return_status  	VARCHAR2(240) := FND_API.G_RET_STS_SUCCESS;
        l_commit         	VARCHAR2(1)     := FND_API.G_FALSE;

	l_row_id		VARCHAR2(30) := NULL;
        l_auth_id		NUMBER := NULL;

        CURSOR auth_id_s IS SELECT JTF_XML_INV_AUTHS_S.NEXTVAL FROM sys.dual;

BEGIN
      	-- Standard Start of API savepoint
      	SAVEPOINT CREATE_AUTH;

       	-- Standard call to check for call compatibility.
       	IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
       	THEN
           	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       	END IF;

      	-- Initialize message list if p_init_msg_list is set to TRUE.
      	IF FND_API.To_Boolean( p_init_msg_list ) THEN
          	FND_MSG_PUB.initialize;
      	END IF;

      	-- Initialize API return status to success
      	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- real logic --
	----------------
   	-- Use Sequence as the unique key
   	OPEN auth_id_s;
   	FETCH auth_id_s INTO l_auth_id;
   	CLOSE auth_id_s;

	insert into JTF_XML_INV_AUTHS (
		AUTH_ID,
    		URL,
    		AUTH_NAME,
    		AUTH_TYPE,
		AUTH_INFO,
    		END_DATE,
    		SECURITY_GROUP_ID,
    		OBJECT_VERSION_NUMBER,
    		CREATION_DATE,
    		CREATED_BY,
    		LAST_UPDATE_DATE,
    		LAST_UPDATED_BY,
    		LAST_UPDATE_LOGIN
  	) values (
    		l_auth_id,
		p_URL,
		p_AUTH_NAME,
		p_AUTH_TYPE,
		p_AUTH_INFO,
		NULL,
		NULL,
		1,
		SYSDATE,
		G_USER_ID,
		SYSDATE,
		G_USER_ID,
		G_LOGIN_ID
  	);

	p_AUTH_ID := l_auth_id;
	p_OBJECT_VERSION := 1;
	-----------------------
	-- end of real logic --

	-- Standard check of p_commit.
	IF (FND_API.To_Boolean(p_commit)) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get(
		p_count => x_msg_count,
		p_data  => x_msg_data );

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO CREATE_AUTH;
		x_return_status := FND_API.G_RET_STS_ERROR ;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO CREATE_AUTH;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

	WHEN OTHERS THEN
		ROLLBACK TO CREATE_AUTH;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
		END IF;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

END CREATE_AUTH;


procedure REMOVE_AUTH (
  p_api_version		IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_AUTH_ID		IN 	NUMBER,
  p_OBJ_VER_NUMBER 	IN OUT	NUMBER,

  x_return_status       OUT     VARCHAR2,
  x_msg_count           OUT     NUMBER,
  x_msg_data            OUT     VARCHAR2
) AS
  	l_api_name		CONSTANT VARCHAR2(30) := 'REMOVE_AUTH';
  	l_api_version		CONSTANT NUMBER := p_api_version;

  	l_object_version	NUMBER := NULL;

  	-- l_ip_row		JTF_XML_INV_PARAMS%ROWTYPE;

BEGIN
  	-- Standard Start of API savepoint
 	SAVEPOINT REMOVE_AUTH;

  	-- dbms_output.PUT_LINE('$$$$');

       	-- Standard call to check for call compatibility.
       	IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
       	THEN
           	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       	END IF;

      	-- Initialize message list if p_init_msg_list is set to TRUE.
      	IF FND_API.To_Boolean( p_init_msg_list ) THEN
          	FND_MSG_PUB.initialize;
      	END IF;

      	-- Initialize API return status to success
      	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- real logic --
	----------------
  	SELECT OBJECT_VERSION_NUMBER INTO l_object_version
    	FROM JTF_XML_INV_AUTHS
    	WHERE AUTH_ID = p_AUTH_ID;

  	-- checking for object version number
  	-- if (l_object_version IS NULL OR l_object_version > p_OBJ_VER_NUMBER) THEN
    	--	RAISE FND_API.G_EXC_ERROR;
  	-- ELSE
    	--	l_object_version := p_OBJ_VER_NUMBER + 1;
  	-- END IF;

  	-- SELECT * INTO l_ip_row FROM JTF_XML_INV_PARAMS
    	-- WHERE PARAM_ID = p_PARAM_ID;

  	update JTF_XML_INV_AUTHS set
    		END_DATE = SYSDATE,
    		OBJECT_VERSION_NUMBER = l_object_version,
    		LAST_UPDATE_DATE = SYSDATE,
    		LAST_UPDATED_BY = G_USER_ID,
    		LAST_UPDATE_LOGIN = G_LOGIN_ID
  	where AUTH_ID = p_AUTH_ID;

	-- P_OBJ_VER_NUMBER := P_OBJ_VER_NUMBER + 1;
	-----------------------
	-- end of real logic --

	-- Standard check of p_commit.
	IF (FND_API.To_Boolean(p_commit)) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get(
		p_count => x_msg_count,
		p_data  => x_msg_data );

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO REMOVE_AUTH;
		x_return_status := FND_API.G_RET_STS_ERROR ;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO REMOVE_AUTH;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

    	WHEN OTHERS THEN
		ROLLBACK TO REMOVE_AUTH;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
		END IF;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

END REMOVE_AUTH;


procedure GET_OBJECT_VERSION (
  p_api_version		IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_AUTH_ID		IN	NUMBER,
  x_OBJ_VER_NUMBER	OUT	NUMBER,

  x_return_status       OUT     VARCHAR2,
  x_msg_count           OUT     NUMBER,
  x_msg_data            OUT     VARCHAR2
) AS
        ---- local variables ----
        l_api_name              CONSTANT VARCHAR2(30)   := 'GET_OBJECT_VERSION';
        l_api_version    	NUMBER  := p_api_version;
        l_return_status         VARCHAR2(240) := FND_API.G_RET_STS_SUCCESS;
        l_commit                VARCHAR2(1) := FND_API.G_FALSE;

BEGIN
	-- Standard Start of API savepoint
	SAVEPOINT GET_OBJECT_VERSION;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.To_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- real logic --
	-------------------------------
	SELECT OBJECT_VERSION_NUMBER into x_OBJ_VER_NUMBER
	FROM JTF_XML_INV_AUTHS
	WHERE AUTH_ID = p_AUTH_ID;

	IF (sql%notfound) THEN
		--raise no_data_found;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	--------------------------------------
	-- end of real logic --

	-- Standard check of p_commit.
	IF (FND_API.To_Boolean(p_commit)) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get(
		p_count => x_msg_count,
		p_data  => x_msg_data );

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO GET_OBJECT_VERSION;
		x_return_status := FND_API.G_RET_STS_ERROR ;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO GET_OBJECT_VERSION;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

	WHEN OTHERS THEN
		ROLLBACK TO GET_OBJECT_VERSION;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
		END IF;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

END GET_OBJECT_VERSION;


PROCEDURE UPDATE_AUTH (
  p_api_version		IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_AUTH_ID	 	IN 	NUMBER,
  p_OBJ_VER_NUMBER 	IN OUT	NUMBER,
  p_URL			IN	VARCHAR2,
  p_AUTH_NAME		IN	VARCHAR2,
  p_AUTH_TYPE		IN	VARCHAR2,
  p_AUTH_INFO		IN 	VARCHAR2,

  x_return_status       OUT     VARCHAR2,
  x_msg_count           OUT     NUMBER,
  x_msg_data            OUT     VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30)   := 'UPDATE_AUTH';
        l_api_version    	NUMBER  := p_api_version;
        l_return_status         VARCHAR2(240) := FND_API.G_RET_STS_SUCCESS;
        l_commit                VARCHAR2(1)   := FND_API.G_FALSE;
        l_object_version	NUMBER := NULL;

	--l_ip_row		JTF_XML_INV_PARAMS%ROWTYPE;
BEGIN
  	-- Standard Start of API savepoint
 	SAVEPOINT UPDATE_AUTH;

       	-- Standard call to check for call compatibility.
       	IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
       	THEN
           	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       	END IF;

      	-- Initialize message list if p_init_msg_list is set to TRUE.
      	IF FND_API.To_Boolean( p_init_msg_list ) THEN
          	FND_MSG_PUB.initialize;
      	END IF;

      	-- Initialize API return status to success
      	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- real logic --
	----------------
  	SELECT OBJECT_VERSION_NUMBER INTO l_object_version
    	FROM JTF_XML_INV_AUTHS
    	WHERE AUTH_ID = p_AUTH_ID;

  	-- checking for object version number
  	-- if (l_object_version IS NULL OR l_object_version > p_OBJ_VER_NUMBER) THEN
    	--	RAISE FND_API.G_EXC_ERROR;
  	-- ELSE
    	--	l_object_version := p_OBJ_VER_NUMBER + 1;
  	-- END IF;

  	-- SELECT * INTO l_ip_row FROM JTF_XML_INV_PARAMS
    	-- WHERE PARAM_ID = p_PARAM_ID;

  	update JTF_XML_INV_AUTHS set
		URL = p_URL,
		AUTH_NAME = p_AUTH_NAME,
		AUTH_TYPE = p_AUTH_TYPE,
		AUTH_INFO = p_AUTH_INFO,
    		OBJECT_VERSION_NUMBER = l_object_version,
    		LAST_UPDATE_DATE = SYSDATE,
    		LAST_UPDATED_BY = G_USER_ID,
    		LAST_UPDATE_LOGIN = G_LOGIN_ID
  	where AUTH_ID = p_AUTH_ID;

	-- P_OBJ_VER_NUMBER := P_OBJ_VER_NUMBER + 1;
	-----------------------
	-- end of real logic --

	-- Standard check of p_commit.
	IF (FND_API.To_Boolean(p_commit)) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get(
		p_count => x_msg_count,
		p_data  => x_msg_data );

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO UPDATE_AUTH;
		x_return_status := FND_API.G_RET_STS_ERROR ;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO UPDATE_AUTH;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

    	WHEN OTHERS THEN
		ROLLBACK TO UPDATE_AUTH;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
		END IF;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

END UPDATE_AUTH;

procedure REMOVE_URL (
  p_api_version		IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_URL			IN 	VARCHAR2,

  x_return_status       OUT     VARCHAR2,
  x_msg_count           OUT     NUMBER,
  x_msg_data            OUT     VARCHAR2
) AS
  	l_api_name		CONSTANT VARCHAR2(30) := 'REMOVE_URL';
  	l_api_version		CONSTANT NUMBER := p_api_version;

BEGIN
  	-- Standard Start of API savepoint
 	SAVEPOINT REMOVE_URL;

  	-- dbms_output.PUT_LINE('$$$$');

       	-- Standard call to check for call compatibility.
       	IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
       	THEN
           	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       	END IF;

      	-- Initialize message list if p_init_msg_list is set to TRUE.
      	IF FND_API.To_Boolean( p_init_msg_list ) THEN
          	FND_MSG_PUB.initialize;
      	END IF;

      	-- Initialize API return status to success
      	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- real logic --
	----------------
  	-- checking for object version number
  	-- if (l_object_version IS NULL OR l_object_version > p_OBJ_VER_NUMBER) THEN
    	--	RAISE FND_API.G_EXC_ERROR;
  	-- ELSE
    	--	l_object_version := p_OBJ_VER_NUMBER + 1;
  	-- END IF;

  	-- SELECT * INTO l_ip_row FROM JTF_XML_INV_PARAMS
    	-- WHERE PARAM_ID = p_PARAM_ID;

  	update JTF_XML_INV_AUTHS set
    		END_DATE = SYSDATE,
    		LAST_UPDATE_DATE = SYSDATE,
    		LAST_UPDATED_BY = G_USER_ID,
    		LAST_UPDATE_LOGIN = G_LOGIN_ID
  	where URL = p_URL and END_DATE is NULL;

	-- P_OBJ_VER_NUMBER := P_OBJ_VER_NUMBER + 1;
	-----------------------
	-- end of real logic --

	-- Standard check of p_commit.
	IF (FND_API.To_Boolean(p_commit)) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get(
		p_count => x_msg_count,
		p_data  => x_msg_data );

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO REMOVE_URL;
		x_return_status := FND_API.G_RET_STS_ERROR ;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO REMOVE_URL;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

    	WHEN OTHERS THEN
		ROLLBACK TO REMOVE_URL;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
		END IF;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

END REMOVE_URL;

procedure UPDATE_URL (
  p_api_version		IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_URL			IN 	VARCHAR2,
  p_NEW_URL		IN	VARCHAR2,

  x_return_status       OUT     VARCHAR2,
  x_msg_count           OUT     NUMBER,
  x_msg_data            OUT     VARCHAR2
) AS
        l_api_name              CONSTANT VARCHAR2(30)   := 'UPDATE_URL';
        l_api_version    	NUMBER  := p_api_version;
        l_return_status         VARCHAR2(240) := FND_API.G_RET_STS_SUCCESS;
        l_commit                VARCHAR2(1)   := FND_API.G_FALSE;
BEGIN
  	-- Standard Start of API savepoint
 	SAVEPOINT UPDATE_URL;

       	-- Standard call to check for call compatibility.
       	IF NOT FND_API.Compatible_API_Call (
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME)
       	THEN
           	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       	END IF;

      	-- Initialize message list if p_init_msg_list is set to TRUE.
      	IF FND_API.To_Boolean( p_init_msg_list ) THEN
          	FND_MSG_PUB.initialize;
      	END IF;

      	-- Initialize API return status to success
      	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- real logic --
	----------------
  	-- checking for object version number
  	-- if (l_object_version IS NULL OR l_object_version > p_OBJ_VER_NUMBER) THEN
    	--	RAISE FND_API.G_EXC_ERROR;
  	-- ELSE
    	--	l_object_version := p_OBJ_VER_NUMBER + 1;
  	-- END IF;

  	-- SELECT * INTO l_ip_row FROM JTF_XML_INV_PARAMS
    	-- WHERE PARAM_ID = p_PARAM_ID;

  	update JTF_XML_INV_AUTHS set
		URL = p_NEW_URL,
    		LAST_UPDATE_DATE = SYSDATE,
    		LAST_UPDATED_BY = G_USER_ID,
    		LAST_UPDATE_LOGIN = G_LOGIN_ID
  	where URL = p_URL and END_DATE is NULL;
	-----------------------
	-- end of real logic --

	-- Standard check of p_commit.
	IF (FND_API.To_Boolean(p_commit)) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get(
		p_count => x_msg_count,
		p_data  => x_msg_data );

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO UPDATE_URL;
		x_return_status := FND_API.G_RET_STS_ERROR ;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO UPDATE_URL;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

    	WHEN OTHERS THEN
		ROLLBACK TO UPDATE_URL;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
		END IF;

		FND_MSG_PUB.Count_And_Get(
			p_count => x_msg_count,
			p_data  => x_msg_data );

END UPDATE_URL;


END JTF_XML_IA_PUB;

/
