--------------------------------------------------------
--  DDL for Package Body JTS_CONFIG_VERSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTS_CONFIG_VERSION_PVT" as
/* $Header: jtsvcvrb.pls 115.11 2002/06/07 11:53:26 pkm ship    $ */


-- --------------------------------------------------------------------
-- Package name     : JTS_CONFIG_VERSION_PVT
-- Purpose          : Configuration Versions.
-- History          : 21-Feb-02  SHuh  Created.
-- NOTE             :
-- --------------------------------------------------------------------

C_STATUS_TYPE 		CONSTANT 	Varchar2(30) := 'JTS_STATUS';

C_NEW			CONSTANT 	Varchar2(30) := 'NEW';
C_PROCESS		CONSTANT 	Varchar2(30) := 'PROCESS';
C_COMPLETE		CONSTANT 	Varchar2(30) := 'COMPLETE';
C_SUBMIT		CONSTANT 	Varchar2(30) := 'SUBMIT';
C_NOSUBMIT		CONSTANT 	Varchar2(30) := 'NOSUBMIT';
C_FAIL			CONSTANT 	Varchar2(30) := 'FAIL';
C_CANCEL		CONSTANT 	Varchar2(30) := 'CANCEL';
C_SUCCESS		CONSTANT 	Varchar2(30) := 'SUCCESS';
C_ERRORS		CONSTANT 	Varchar2(30) := 'ERRORS';
C_RUNNING		CONSTANT 	Varchar2(30) := 'RUNNING';

-- Returns the next value for version_number in
-- jts_config_versions
FUNCTION GET_NEXT_VERSION_NUMBER(p_config_id 	IN NUMBER) return NUMBER IS
  l_max_version		NUMBER := 1;
  l_exists		NUMBER := 0;
BEGIN
  SELECT count(*)
  INTO	l_exists
  FROM  jts_config_versions_b
  WHERE	configuration_id = p_config_id;

  IF (l_exists > 0) THEN

     SELECT max(version_number)
     INTO   l_max_version
     FROM  jts_config_versions_b
     WHERE configuration_id = p_config_id;

     return (l_max_version + 1);
  ELSE
     return 1;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
	return 1;
END GET_NEXT_VERSION_NUMBER;


--
-- Returns the next sequence in jts_config_versions for
-- version_id
FUNCTION GET_NEXT_VERSION_ID return NUMBER IS
   l_version_id	 	JTS_CONFIG_VERSIONS_B.version_ID%TYPE;
BEGIN
   SELECT jts_config_versions_b_s.NEXTVAL
   INTO   l_version_id
   FROM   sys.dual;

   return (l_version_id);

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END GET_NEXT_VERSION_ID;

--
-- Returns the versionin jts_config_versions for
-- version_name and configuration_id
FUNCTION GET_VERSION_ID(p_version_name  IN VARCHAR2,
			p_config_id	IN NUMBER) return NUMBER IS
   l_version_id		JTS_CONFIG_VERSIONS_B.version_id%TYPE;
BEGIN

  SELECT version_id
  INTO	l_version_id
  FROM  jts_config_versions_b
  WHERE	version_name = p_version_name
  AND   configuration_id = p_config_id;

  return (l_version_id);

EXCEPTION
   WHEN OTHERS THEN
	return NULL;
END GET_VERSION_ID;


--
-- Checks for Unique Version Name per Configuration
--
FUNCTION CHECK_VERSION_NAME_UNIQUE(p_version_name  	IN VARCHAR2,
				   p_version_id		IN NUMBER,
				   p_config_id		IN NUMBER
) RETURN BOOLEAN IS
  l_count	NUMBER := 0;
  l_version_id  JTS_CONFIG_VERSIONS_B.version_id%TYPE;
BEGIN
  SELECT count(*)
  INTO   l_count
  FROM	 jts_config_versions_vl
  WHERE  configuration_id = p_config_id
  AND	 version_name = p_version_name;

  IF  (l_count = 0) THEN
       return TRUE;
  ELSIF l_count = 1 THEN
     l_version_id := get_version_id(p_version_name, p_config_id);

     IF (p_version_id IS NOT NULL AND p_version_id = l_version_id) THEN
 	return TRUE;
     END IF;
     return FALSE;
  ELSE
    return FALSE;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END CHECK_VERSION_NAME_UNIQUE;

--
-- Checks for Unique Version Name per Configuration
--
PROCEDURE VALIDATE_ROW(p_api_version	IN NUMBER,
   p_version_rec 		IN  Config_Version_Rec_Type,
   x_return_status      	OUT VARCHAR2
) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'VALIDATE_ROW';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF (NOT CHECK_VERSION_NAME_UNIQUE(p_version_rec.version_name,
				     p_version_rec.version_id,
				     p_version_rec.configuration_id)) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      	 FND_MESSAGE.set_name('JTS', 'JTS_VERSION_NAME_NOT_UNIQUE');
      	 FND_MSG_PUB.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END VALIDATE_ROW;

-- Inserts a row into jts_config_versions
-- Note: Since there is no UI for Create Version, attribute1 - 15 are set to null in insert
-- at this time
PROCEDURE INSERT_ROW(p_configuration_id  IN NUMBER,
     p_init_version IN VARCHAR2,
     x_version_id OUT NUMBER) IS
   l_queue_name		JTS_CONFIG_VERSIONS_B.queue_name%TYPE;
   l_version_number	NUMBER := 1;
   l_version_name	JTS_CONFIG_VERSIONS_B.version_name%TYPE;
   l_description	JTS_CONFIG_VERSIONS_TL.description%TYPE;
   l_config_name	JTS_CONFIGURATIONS_B.config_name%TYPE;
BEGIN
  x_version_id := GET_NEXT_VERSION_ID;
  l_queue_name := C_QUEUE_PREFIX || x_version_id;
  --nodpfxml l_version_number := GET_NEXT_VERSION_NUMBER(p_configuration_id);

  l_config_name := JTS_CONFIGURATION_PVT.get_config_name(p_configuration_id);

  --nodpfxml
  --IF (FND_API.to_boolean(p_init_version)) THEN  --initial version
  --    FND_MESSAGE.set_name('JTS', 'JTS_INITIAL_VERSION');
  --    l_version_name := FND_MESSAGE.get;
  --ELSE
      FND_MESSAGE.set_name('JTS', 'JTS_VERSION_NAME');
      --FND_MESSAGE.set_token('NUMBER', l_version_number || '.0');
      FND_MESSAGE.set_token('NUMBER', l_config_name);
      l_version_name := FND_MESSAGE.get;
  --END IF;

  FND_MESSAGE.set_name('JTS', 'JTS_VERSION_DESC');
  --nodpfxml FND_MESSAGE.set_token('NAME', l_version_name );
  --nodpfxml FND_MESSAGE.set_token('CONFIG_NAME', l_config_name);
  l_description := substrb(FND_MESSAGE.get, 1, 240);


  insert into JTS_CONFIG_VERSIONS_B (
    VERSION_ID,
    VERSION_NAME,
    CONFIGURATION_ID,
    VERSION_NUMBER,
    QUEUE_NAME,
    OBJECT_VERSION_NUMBER,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_VERSION_ID,
    l_version_name,
    P_CONFIGURATION_ID,
    L_VERSION_NUMBER,
    L_QUEUE_NAME,
    1,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    sysdate,
    FND_GLOBAL.user_id,
    sysdate,
    FND_GLOBAL.user_id,
    FND_GLOBAL.user_id
  );

  insert into JTS_CONFIG_VERSIONS_TL (
    VERSION_ID,
    CONFIGURATION_ID,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_VERSION_ID,
    P_CONFIGURATION_ID,
    l_description,
    sysdate,
    FND_GLOBAL.user_id,
    sysdate,
    FND_GLOBAL.user_id,
    FND_GLOBAL.user_id,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTS_CONFIG_VERSIONS_TL T
    where T.VERSION_ID = X_VERSION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END INSERT_ROW;


-- Deletes rows from jts_config_versions based on configuration_id
PROCEDURE DELETE_ROWS(p_config_id  	IN NUMBER
) IS
BEGIN
   DELETE FROM jts_config_versions_b
   WHERE  configuration_id = p_config_id;

   DELETE FROM jts_config_versions_tl
   WHERE  configuration_id = p_config_id;

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END DELETE_ROWS;


-----------------------------------------------------------------
-- Creates a version, version flows for the setup summary data,
-- and version status with "NEW" as the value
-- Values passed in:
-- 	version_name
-- 	description
-- 	configuration_id
-----------------------------------------------------------------
PROCEDURE CREATE_VERSION(p_api_version	IN   Number,
	P_commit			IN   Varchar2 DEFAULT FND_API.G_FALSE,
	p_configuration_id		IN   NUMBER,
        p_init_version 			IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
   	x_version_id			OUT  NUMBER,
   	x_return_status      		OUT  VARCHAR2,
   	x_msg_count          		OUT  NUMBER,
   	x_msg_data           		OUT  VARCHAR2) IS

   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'CREATE_VERSION';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
   l_flows	   JTS_SETUP_FLOW_PVT.Setup_Flow_Tbl_Type;
   l_flow_id	   JTS_CONFIGURATIONS_B.flow_id%TYPE;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Standard Start of API savepoint
   SAVEPOINT create_version;

   fnd_msg_pub.initialize;

   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;


   If (x_return_status = fnd_api.g_ret_sts_success) THEN
      INSERT_ROW(p_configuration_id,
		 p_init_version,
		 x_version_id);

      JTS_CONFIGURATION_PVT.get_flow_id(p_configuration_id,
					l_flow_id);

      JTS_SETUP_FLOW_PVT.GET_FLOW_HIEARCHY(
			p_api_version	 => p_api_version,
   		  	p_flow_id	 => l_flow_id,
 	   	  	x_flow_tbl	 => l_flows
      );

      JTS_CONFIG_VERSION_FLOW_PVT.CREATE_VERSION_FLOWS(
					p_api_version	 => p_api_version,
					p_version_id	 => x_version_id,
					p_flow_hiearchy  => l_flows);

      JTS_CONFIG_VER_STATUS_PVT.CREATE_VERSION_STATUS(
				p_api_version	=> p_api_version,
				p_commit	=> FND_API.G_FALSE,
   				p_version_id	=> x_version_id,
 				p_status	=> JTS_CONFIG_VER_STATUS_PVT.C_INIT_VERSION_STATUS);

      IF (FND_API.to_boolean(p_commit)) THEN
	  COMMIT;
      END IF;

   END IF;

   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO create_version;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END CREATE_VERSION;

-- Updates version_status_code, last_update_date, last_updated_by
PROCEDURE UPDATE_VERSION_STAT(p_api_version	IN  NUMBER,
			   p_version_id		IN  NUMBER,
			   p_status		IN  VARCHAR2
) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'UPDATE_VERSION_STAT';
BEGIN
   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   UPDATE  jts_config_versions_b
   SET     version_status_code = p_status,
	   last_update_date = sysdate,
   	   last_updated_by = FND_GLOBAL.user_id
   WHERE   version_id = p_version_id;

EXCEPTION
   WHEN OTHERS THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
END UPDATE_VERSION_STAT;

-- Updates version_status_code, last_update_date, last_updated_by
PROCEDURE UPDATE_REPLAY_DATA(p_api_version	IN  NUMBER,
			   p_version_id		IN  NUMBER,
			   p_status		IN  VARCHAR2
) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'UPDATE_REPLAY_DATA';
BEGIN
   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   UPDATE  jts_config_versions_b
   SET     replay_status_code = p_status,
	   replayed_on = sysdate,
	   replayed_by = FND_GLOBAL.user_id,
	   last_update_date = sysdate,
   	   last_updated_by = FND_GLOBAL.user_id
   WHERE   version_id = p_version_id;

EXCEPTION
   WHEN OTHERS THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
END UPDATE_REPLAY_DATA;

-- Updates last_update_date and last_updated_by
PROCEDURE UPDATE_LAST_MODIFIED(p_api_version	IN  NUMBER,
			   p_version_id		IN  NUMBER
) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'UPDATE_LAST_MODIFIED';
BEGIN
   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   UPDATE  jts_config_versions_b
   SET     last_update_date = sysdate,
   	   last_updated_by = FND_GLOBAL.user_id
   WHERE   version_id = p_version_id;

EXCEPTION
   WHEN OTHERS THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
END UPDATE_LAST_MODIFIED;

-- Updates version name and description.
-- May insert into version_statuses table
PROCEDURE UPDATE_NAME_DESC(p_api_version	IN  NUMBER,
			   p_version_id		IN  NUMBER,
			   p_config_id		IN  NUMBER,
			   p_version_name 	IN  VARCHAR2,
			   p_version_desc 	IN  VARCHAR2,
   			   x_return_status      OUT VARCHAR2,
   			   x_msg_count          OUT NUMBER,
   			   x_msg_data           OUT VARCHAR2
) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'UPDATE_NAME_DESC';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
   l_version_rec   Config_Version_Rec_Type;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_NAME_DESC;

   fnd_msg_pub.initialize;

   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   l_version_rec.version_id := p_version_id;
   l_version_rec.configuration_id := p_config_id;
   l_version_rec.version_name := p_version_name;
   l_version_rec.description := p_version_desc;

   VALIDATE_ROW(p_api_version => p_api_version,
		p_version_rec => l_version_rec,
		x_return_status => x_return_status);

   IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	UPDATE  jts_config_versions_b
	SET     version_name = p_version_name,
		last_update_date = sysdate,
		last_updated_by = FND_GLOBAL.user_id,
		last_update_login = FND_GLOBAL.user_id
	WHERE   version_id = p_version_id;

	--take care of translation
	UPDATE  jts_config_versions_tl
	SET     description = p_version_desc,
		last_update_date = sysdate,
    		last_updated_by = FND_GLOBAL.user_id,
    		last_update_login = FND_GLOBAL.user_id,
    		source_lang = USERENV('LANG')
	WHERE   version_id = p_version_id
	AND	USERENV('LANG') IN (language, source_lang);
   	COMMIT;
   END IF;

   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO UPDATE_NAME_DESC;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END UPDATE_NAME_DESC;

-- Deletes a version and its corresponding version_statuses and
-- version_flows
PROCEDURE DELETE_VERSION(p_api_version		IN  Number,
			 p_commit		IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
			 p_version_id		IN  NUMBER
) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'DELETE_VERSION';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT DELETE_VERSION;

   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   JTS_CONFIG_VER_STATUS_PVT.DELETE_VERSION_STATUSES(p_api_version, p_version_id);
   JTS_CONFIG_VERSION_FLOW_PVT.DELETE_VERSION_FLOWS(p_api_version, p_version_id);
   JTS_CONFIG_VERSIONS_PKG.DELETE_ROW(p_version_id);
   IF (FND_API.to_boolean(p_commit)) THEN
       COMMIT;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF (FND_API.to_boolean(p_commit)) THEN
        ROLLBACK TO DELETE_VERSION;
      ELSE
	APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
END DELETE_VERSION;

-- Deletes versions and their corresponding version_statuses and
-- version_flows given a table of version ids
PROCEDURE DELETE_SOME_VERSIONS(p_api_version		IN  Number,
   			       p_version_tbl		IN  Version_Id_Tbl_Type
) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'DELETE_SOME_VERSIONS';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
   i 		   NUMBER := 1;
BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT DELETE_SOME_VERSIONS;

   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   FOR I IN 1..p_version_tbl.count LOOP --loop through p_version_tbl
      DELETE_VERSION(p_api_version => p_api_version,
		     p_commit => FND_API.G_FALSE,
		     p_version_id => p_version_tbl(i));
   END LOOP;
   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO DELETE_SOME_VERSIONS;
END DELETE_SOME_VERSIONS;

-- Deletes all versions of a configuration and their corresponding -- version_statuses and version_flows
-- Commit is done in Configurations Pkg
PROCEDURE DELETE_VERSIONS(p_api_version		IN  NUMBER,
   			  p_config_id		IN  NUMBER
) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'DELETE_VERSIONS';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
BEGIN

   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   JTS_CONFIG_VER_STATUS_PVT.DELETE_CONFIG_VER_STATUSES(p_api_version, p_config_id);
   JTS_CONFIG_VERSION_FLOW_PVT.DELETE_CONFIG_VERSION_FLOWS(p_api_version, p_config_id);
   DELETE_ROWS(p_config_id);

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END DELETE_VERSIONS;


-- Gets version data based on version_id
PROCEDURE GET_VERSION(p_api_version	IN   NUMBER,
   		      p_version_id	IN   NUMBER,
		      x_version_rec 	OUT  NOCOPY Config_Version_Rec_Type,
      		      x_return_status   OUT  VARCHAR2,
      		      x_msg_count       OUT  NUMBER,
      		      x_msg_data        OUT  VARCHAR2) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'GET_VERSION';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
   l_config_rec	   JTS_CONFIGURATION_PVT.Config_Rec_Type;
   l_debug_info	   VARCHAR2(2000);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   fnd_msg_pub.initialize;

   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   l_debug_info := 'Version select';
   SELECT  	configuration_id, version_id, version_name, version_number, v.description, queue_name,
		v.attribute_category, v.attribute1, v.attribute2, v.attribute3, v.attribute4, v.attribute5,
		v.attribute6, v.attribute7, v.attribute8, v.attribute9, v.attribute10, v.attribute11,
		v.attribute12, v.attribute13, v.attribute14, v.attribute15,
   		v.creation_date, v.created_by, v.last_update_date, v.last_updated_by, v.last_update_login,
		u1.user_name, u2.user_name, replay_status_code, version_status_code,
		rep.meaning, ver.meaning, replayed_on, u3.user_name
   INTO		x_version_rec.configuration_id,
		x_version_rec.version_id,
		x_version_rec.version_name,
		x_version_rec.version_number,
		x_version_rec.description,
		x_version_rec.queue_name,
		x_version_rec.attribute_category,
		x_version_rec.attribute1,
		x_version_rec.attribute2,
		x_version_rec.attribute3,
		x_version_rec.attribute4,
		x_version_rec.attribute5,
		x_version_rec.attribute6,
		x_version_rec.attribute7,
		x_version_rec.attribute8,
		x_version_rec.attribute9,
		x_version_rec.attribute10,
		x_version_rec.attribute11,
		x_version_rec.attribute12,
		x_version_rec.attribute13,
		x_version_rec.attribute14,
		x_version_rec.attribute15,
		x_version_rec.creation_date,
		x_version_rec.created_by,
		x_version_rec.last_update_date,
		x_version_rec.last_updated_by,
		x_version_rec.last_update_login,
		x_version_rec.created_by_name,
		x_version_rec.last_updated_by_name,
   		x_version_rec.replay_status_code,
   		x_version_rec.version_status_code,
   		x_version_rec.replay_status,
   		x_version_rec.version_status,
   		x_version_rec.replayed_date,
   		x_version_rec.replayed_by_name
   FROM    	jts_config_versions_vl v,
	        fnd_lookup_values rep,
		fnd_lookup_values ver,
	 	fnd_user u1,
		fnd_user u2,
		fnd_user u3
   WHERE   	version_id = p_version_id
   AND		rep.lookup_type (+) = C_STATUS_TYPE
   AND	 	rep.lookup_code (+) = v.replay_status_code
   AND		ver.lookup_type = C_STATUS_TYPE
   AND	 	ver.lookup_code = nvl(v.version_status_code, C_NEW)
   AND		u1.user_id  = v.created_by
   AND		u2.user_id  = v.last_updated_by
   AND		u3.user_id  (+) = v.replayed_by;

   l_debug_info := 'Configuration';
   -- Get Configuration Data for Version
   JTS_CONFIGURATION_PVT.GET_CONFIGURATION(
      p_api_version 		=> p_api_version,
      p_init_msg_list		=> FND_API.G_FALSE,
      p_config_id  		=> x_version_rec.configuration_id,
      x_configuration_rec 	=> l_config_rec,
      x_return_status          	=> x_return_status,
      x_msg_count              	=> x_msg_count,
      x_msg_data               	=> x_msg_data
   );

   IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      raise fnd_api.g_exc_unexpected_error;
   END IF;

   l_debug_info := 'Set Record';
   -- Store Configuration Data for Version in the version record
   x_version_rec.config_name := l_config_rec.config_name;
   x_version_rec.config_desc := l_config_rec.description;
   x_version_rec.config_flow_id := l_config_rec.flow_id;
   x_version_rec.config_flow_name := l_config_rec.flow_name;
   x_version_rec.config_flow_type := l_config_rec.flow_type;
   x_version_rec.config_record_mode := l_config_rec.record_mode;
   x_version_rec.config_disp_record_mode := l_config_rec.displayed_record_mode;

   l_debug_info := 'Percent Completed';
   x_version_rec.percent_completed := JTS_CONFIG_VERSION_FLOW_PVT.GET_PERCENT_COMPLETE(p_api_version,
				x_version_rec.version_id);

   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END GET_VERSION;


-- Retrieves all versions under a configuration with a certain order by clause
-- Uses Dynamic SQL
PROCEDURE  GET_VERSIONS(
      p_api_version            	IN   NUMBER,
      p_config_id		IN   NUMBER,
      p_order_by  		IN   VARCHAR2,
      p_how_to_order		IN   VARCHAR2,
      x_version_tbl 		OUT  NOCOPY Config_Version_Tbl_Type,
      x_return_status          	OUT  VARCHAR2,
      x_msg_count              	OUT  NUMBER,
      x_msg_data               	OUT  VARCHAR2
) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'GET_VERSIONS';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;

   TYPE Version_Cur_Typ IS REF CURSOR;
   version_csr  	Version_Cur_Typ;
   i			NUMBER := 1;
   sqlStmt		VARCHAR2(4000);
   l_config_rec 	JTS_CONFIGURATION_PVT.Config_Rec_Type;
   l_how_to_order 	VARCHAR2(30);
   l_order_by	 	VARCHAR2(30) := upper(p_order_by);
BEGIN

   x_return_status := fnd_api.G_RET_STS_SUCCESS;

   fnd_msg_pub.initialize;

   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;


   -- Get Configuration Data for Version
   JTS_CONFIGURATION_PVT.GET_CONFIGURATION(
      p_api_version 		=> p_api_version,
      p_init_msg_list		=> FND_API.G_FALSE,
      p_config_id  		=> p_config_id,
      x_configuration_rec 	=> l_config_rec,
      x_return_status          	=> x_return_status,
      x_msg_count              	=> x_msg_count,
      x_msg_data               	=> x_msg_data
   );

   IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      raise fnd_api.g_exc_unexpected_error;
   END IF;

   l_how_to_order := substrb(upper(p_how_to_order), 1, 30);
   IF (l_how_to_order <> 'ASC' AND l_how_to_order <> 'DESC') THEN
       l_how_to_order := 'ASC';
   END IF;

   IF (l_order_by = 'DESCRIPTION') THEN
       l_order_by := 'v.description';
   ELSIF (l_order_by = 'CREATION_DATE') THEN
       l_order_by := 'v.creation_date';
   ELSIF (l_order_by = 'LAST_UPDATE_DATE') THEN
       l_order_by := 'v.last_update_date';
   ELSIF (l_order_by = 'CREATED_BY') THEN
       l_order_by := 'u1.user_name';
   ELSIF (l_order_by = 'LAST_UPDATED_BY') THEN
       l_order_by := 'u2.user_name';
   ELSIF (l_order_by = 'REPLAY_STATUS') THEN
       l_order_by := 'rs.replay_status_meaning';
   ELSIF (l_order_by = 'VERSION_STATUS') THEN
       l_order_by := 'vers.version_status_meaning';
   ELSIF (l_order_by = 'REPLAYED_BY') THEN
       l_order_by := 'rs.replayed_by';
   ELSIF (l_order_by = 'REPLAYED_ON') THEN
       l_order_by := 'rs.replayed_on';
   END IF;

   sqlStmt :=   'SELECT  configuration_id, version_id, version_name, version_number, v.description, queue_name, '
	     ||	' v.attribute_category, v.attribute1, v.attribute2, v.attribute3, v.attribute4, v.attribute5, '
	     || ' v.attribute6, v.attribute7, v.attribute8, v.attribute9, v.attribute10, v.attribute11, '
	     || ' v.attribute12, v.attribute13, v.attribute14, v.attribute15, '
	     || ' v.creation_date, v.created_by, v.last_update_date, v.last_updated_by, v.last_update_login, '
	     || ' u1.user_name, u2.user_name, '
	     || ' replay_status_code, version_status_code, rep.meaning, ver.meaning, '
	     || ' replayed_on, u3.user_name '
   	     || 'FROM    jts_config_versions_vl v, '
	     || '  	 fnd_lookup_values rep, '
	     || '  	 fnd_lookup_values ver, '
	     || '  	 fnd_user u1, '
	     || ' 	 fnd_user u2, '
	     || ' 	 fnd_user u3 '
   	     || 'WHERE   configuration_id = ' || p_config_id ||
   	      '	AND	rep.lookup_type (+) = ''' || C_STATUS_TYPE ||
   	    ''' AND	rep.lookup_code (+)=  v.replay_status_code ' ||
   	      '	AND	ver.lookup_type = ''' || C_STATUS_TYPE ||
   	    '''	AND	ver.lookup_code = nvl(v.version_status_code, ''' || C_NEW || ''') ' ||
   	      '	AND	u1.user_id = v.created_by ' ||
   	      '	AND	u2.user_id = v.last_updated_by ' ||
   	      '	AND	u3.user_id (+) = v.replayed_by ' ||
   	      '	ORDER BY ' || l_order_by || ' ' || l_how_to_order;
   i := 1;
   OPEN version_csr FOR sqlStmt;
   LOOP
      FETCH version_csr INTO
    		x_version_tbl(i).configuration_id,
		x_version_tbl(i).version_id,
		x_version_tbl(i).version_name,
		x_version_tbl(i).version_number,
		x_version_tbl(i).description,
		x_version_tbl(i).queue_name,
		x_version_tbl(i).attribute_category,
		x_version_tbl(i).attribute1,
		x_version_tbl(i).attribute2,
		x_version_tbl(i).attribute3,
		x_version_tbl(i).attribute4,
		x_version_tbl(i).attribute5,
		x_version_tbl(i).attribute6,
		x_version_tbl(i).attribute7,
		x_version_tbl(i).attribute8,
		x_version_tbl(i).attribute9,
		x_version_tbl(i).attribute10,
		x_version_tbl(i).attribute11,
		x_version_tbl(i).attribute12,
		x_version_tbl(i).attribute13,
		x_version_tbl(i).attribute14,
		x_version_tbl(i).attribute15,
		x_version_tbl(i).creation_date,
		x_version_tbl(i).created_by,
		x_version_tbl(i).last_update_date,
		x_version_tbl(i).last_updated_by,
		x_version_tbl(i).last_update_login,
		x_version_tbl(i).created_by_name,
		x_version_tbl(i).last_updated_by_name,
   		x_version_tbl(i).replay_status_code,
   		x_version_tbl(i).version_status_code,
   		x_version_tbl(i).replay_status,
   		x_version_tbl(i).version_status,
   		x_version_tbl(i).replayed_date,
   		x_version_tbl(i).replayed_by_name;
      EXIT WHEN version_csr%NOTFOUND;

       -- Store Configuration Data for Version in the version record
      x_version_tbl(i).config_name := l_config_rec.config_name;
      x_version_tbl(i).config_desc := l_config_rec.description;
      x_version_tbl(i).config_flow_id := l_config_rec.flow_id;
      x_version_tbl(i).config_flow_name := l_config_rec.flow_name;
      x_version_tbl(i).config_flow_type := l_config_rec.flow_type;
      x_version_tbl(i).config_record_mode := l_config_rec.record_mode;
      x_version_tbl(i).config_disp_record_mode := l_config_rec.displayed_record_mode;

      x_version_tbl(i).percent_completed := JTS_CONFIG_VERSION_FLOW_PVT.GET_PERCENT_COMPLETE(
				   p_api_version,
				   x_version_tbl(i).version_id);

      i := i + 1;
   END LOOP;
   CLOSE version_csr;

   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END GET_VERSIONS;

END JTS_CONFIG_VERSION_PVT;

/
