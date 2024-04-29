--------------------------------------------------------
--  DDL for Package Body JTS_CONFIGURATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTS_CONFIGURATION_PVT" as
/* $Header: jtsvcfgb.pls 115.12 2002/06/07 11:53:25 pkm ship    $ */


-- --------------------------------------------------------------------
-- Package name     : JTS_CONFIGURATION_PVT
-- Purpose          : Configurations.
-- History          : 21-Feb-02  SHuh  Created.
--		      06-Jun-02  SHUH  DELETE_ROW moved to JTS_CONFIGURATIONS_PKG
-- --------------------------------------------------------------------

-- get next sequence for configuration id
FUNCTION GET_NEXT_CONFIG_ID RETURN NUMBER IS
    l_new_config_id		JTS_CONFIGURATIONS_B.configuration_id%TYPE;
BEGIN
    SELECT jts_configurations_b_s.nextval
    INTO   l_new_config_id
    FROM   sys.dual;

    return (l_new_config_id);
EXCEPTION
   WHEN OTHERS THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
END GET_NEXT_CONFIG_ID;

FUNCTION GET_CONFIG_ID(p_config_name IN VARCHAR2) RETURN NUMBER IS
    l_config_id		JTS_CONFIGURATIONS_B.configuration_id%TYPE;
BEGIN
     SELECT configuration_id
     INTO   l_config_id
     FROM   jts_configurations_b
     WHERE  config_name = p_config_name;

     return l_config_id;
EXCEPTION
   WHEN OTHERS THEN
      return NULL;
END GET_CONFIG_ID;

FUNCTION GET_CONFIG_NAME(p_config_id IN NUMBER) RETURN VARCHAR2 IS
    l_config_name		JTS_CONFIGURATIONS_B.config_name%TYPE;
BEGIN
     SELECT config_name
     INTO   l_config_name
     FROM   jts_configurations_b
     WHERE  configuration_id = p_config_id;

     return l_config_name;
EXCEPTION
   WHEN OTHERS THEN
      return NULL;
END GET_CONFIG_NAME;

-- Inserts a row into jts_configurations table
PROCEDURE  INSERT_ROW(p_config_rec 	IN  Config_Rec_Type,
   		      x_config_id	OUT NUMBER
) IS
BEGIN

  x_config_id := GET_NEXT_CONFIG_ID;

  insert into JTS_CONFIGURATIONS_B (
    CONFIGURATION_ID,
    CONFIG_NAME,
    FLOW_ID,
    RECORD_MODE,
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
    X_CONFIG_ID,
    p_config_rec.CONFIG_NAME,
    p_config_rec.FLOW_ID,
    p_config_rec.RECORD_MODE,
    1,
    p_config_rec.ATTRIBUTE_CATEGORY,
    p_config_rec.ATTRIBUTE1,
    p_config_rec.ATTRIBUTE2,
    p_config_rec.ATTRIBUTE3,
    p_config_rec.ATTRIBUTE4,
    p_config_rec.ATTRIBUTE5,
    p_config_rec.ATTRIBUTE6,
    p_config_rec.ATTRIBUTE7,
    p_config_rec.ATTRIBUTE8,
    p_config_rec.ATTRIBUTE9,
    p_config_rec.ATTRIBUTE10,
    p_config_rec.ATTRIBUTE11,
    p_config_rec.ATTRIBUTE12,
    p_config_rec.ATTRIBUTE13,
    p_config_rec.ATTRIBUTE14,
    p_config_rec.ATTRIBUTE15,
    sysdate,
    FND_GLOBAL.user_id,
    sysdate,
    FND_GLOBAL.user_id,
    FND_GLOBAL.user_id
  );

  insert into JTS_CONFIGURATIONS_TL (
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
    X_CONFIG_ID,
    p_config_rec.DESCRIPTION,
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
    from JTS_CONFIGURATIONS_TL T
    where T.CONFIGURATION_ID = X_CONFIG_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

EXCEPTION
   WHEN OTHERS THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
END INSERT_ROW;

--  Checks for Uniqueness of configuration name against existing --   rows
FUNCTION CHECK_CONFIG_NAME_UNIQUE(p_config_name  IN VARCHAR2,
				  p_config_id	 IN NUMBER
) return BOOLEAN IS
  l_count	NUMBER := 0;
  l_config_id   JTS_CONFIGURATIONS_B.config_name%TYPE;
BEGIN
  SELECT count(*)
  INTO   l_count
  FROM	 jts_configurations_b
  WHERE  config_name = p_config_name;

  IF l_count = 0 THEN
     return TRUE;
  ELSIF l_count = 1 THEN
     l_config_id := get_config_id(p_config_name);

     IF (p_config_id IS NOT NULL AND p_config_id = l_config_id) THEN
 	return TRUE;
     END IF;
     return FALSE;
  ELSE
    return FALSE;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
END CHECK_CONFIG_NAME_UNIQUE;

--
-- Check if the selected flow exists in the tables.  If it
-- doesn't, this is an unexpected error (programmer or setup
-- error)
FUNCTION CHECK_FLOW_EXISTS(p_flow_id 	IN NUMBER) return BOOLEAN IS
  l_count	NUMBER := 0;
BEGIN

  SELECT count(*)
  INTO   l_count
  FROM	 jts_setup_flows_b
  WHERE  flow_id = p_flow_id;

  IF l_count = 0 THEN
     return FALSE;
  ELSE
     return TRUE;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
END CHECK_FLOW_EXISTS;

-- Performs Validation
--  Checks for: Unique Configuration Name
--
PROCEDURE VALIDATE_ROW(p_api_version            IN       NUMBER,
   p_configuration_rec 		IN  Config_Rec_Type,
   x_return_status      	OUT VARCHAR2
) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'VALIDATE_ROW';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
BEGIN

   x_return_status := fnd_api.g_ret_sts_success;

   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   IF (NOT CHECK_CONFIG_NAME_UNIQUE(p_configuration_rec.config_name, p_configuration_rec.configuration_id)) THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('JTS', 'JTS_CONFIG_NAME_EXISTS');
            fnd_msg_pub.add;
         END IF;
	 x_return_status := fnd_api.g_ret_sts_error;
   END IF;

   IF (NOT CHECK_FLOW_EXISTS(p_configuration_rec.flow_id)) THEN
      raise FND_API.g_exc_unexpected_error;
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name || ': flow_id not found');
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END VALIDATE_ROW;

-----------------------------------------------------------
--Creates a configuration and an initial version
--Values passed in:
--config_name			config_configName,
--description			config_desc,
--flow_id				config_flowId,
--flow_type			setupFlow_flowType,
--record_mode			config_recordMode,
-----------------------------------------------------------
PROCEDURE  CREATE_CONFIGURATION(
      p_api_version            IN       NUMBER,
      p_configuration_rec      IN  	Config_Rec_Type,
      x_config_id	       OUT 	NUMBER,
      x_return_status          OUT      VARCHAR2,
      x_msg_count              OUT      NUMBER,
      x_msg_data               OUT      VARCHAR2
) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'CREATE_CONFIGURATION';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
   l_version_id	   JTS_CONFIG_VERSIONS_B.version_id%TYPE;
   --l_version_rec   JTS_CONFIG_VERSION_PVT.Config_Version_Rec_Type;
   l_flows	   JTS_SETUP_FLOW_PVT.Setup_Flow_Tbl_Type;
BEGIN
   x_return_status := fnd_api.G_RET_STS_SUCCESS;

   -- Standard Start of API savepoint
   SAVEPOINT create_configuration;

   fnd_msg_pub.initialize;

   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   VALIDATE_ROW(p_api_version,
   		p_configuration_rec,
   		x_return_status ); --server-side validation for unique name

   IF (x_return_status = fnd_api.g_ret_sts_success) THEN
		INSERT_ROW(p_configuration_rec,
			   x_config_id);
		--Create the initial version
		--FND_MESSAGE.set_name('JTS', 'JTS_INITIAL_VERSION');
		--l_version_rec.version_name := FND_MESSAGE.get;
		--FND_MESSAGE.set_name('JTS', 'JTS_VERSION_DESCRIPTION');
		--FND_MESSAGE.set_token('VERSION', l_version_rec.version_name);
		--FND_MESSAGE.set_token('FLOWNAME', JTS_SETUP_FLOW_PVT.get_flow_name(p_configuration_rec.flow_id));
		--l_version_rec.description := FND_MESSAGE.get;

		JTS_CONFIG_VERSION_PVT.CREATE_VERSION(
			p_api_version => p_api_version,
			p_commit => FND_API.G_FALSE,
			p_configuration_id => x_config_id,
			p_init_version => FND_API.G_TRUE,
			x_version_id => l_version_id,
			x_return_status => x_return_status,
			x_msg_count => x_msg_count,
			x_msg_data => x_msg_data);
		IF (x_return_status = fnd_api.g_ret_sts_success) THEN
		   Commit;
		ELSE
		   raise fnd_api.g_exc_unexpected_error;
		END IF;
   END IF;

   fnd_msg_pub.count_and_get (
      p_encoded=> fnd_api.g_false
     ,p_count=> x_msg_count
     ,p_data=> x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_configuration;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO create_configuration;
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
END CREATE_CONFIGURATION;

-----------------------------------------------------------
--Updates a configuration
--Values passed in:
--config_name			config_configName,
--description			config_desc,
--Updated: config_name, description, last_update_date,
--last_updated_by, last_update_login
-----------------------------------------------------------
PROCEDURE  UPDATE_NAME_DESC (
      p_api_version            IN       NUMBER,
      p_config_id	       IN	NUMBER,
      p_config_name 	       IN  	VARCHAR2,
      p_config_desc 	       IN  	VARCHAR2,
      x_return_status          OUT      VARCHAR2,
      x_msg_count              OUT      NUMBER,
      x_msg_data               OUT      VARCHAR2
) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'UPDATE_ NAME_DESC';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
   l_config_rec	   Config_Rec_Type;
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   -- Standard Start of API savepoint
   SAVEPOINT update_name_and_desc;

   Fnd_msg_pub.initialize;

   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   l_config_rec.configuration_id := p_config_id;
   l_config_rec.config_name := p_config_name;
   l_config_rec.description := p_config_desc;
   GET_FLOW_ID(p_config_id,  l_config_rec.flow_id);

   VALIDATE_ROW(p_api_version => p_api_version,
		p_configuration_rec => l_config_rec,
		x_return_status => x_return_status);

   IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	UPDATE  jts_configurations_b
	SET     config_name = p_config_name,
		last_update_date = sysdate,
		last_updated_by = FND_GLOBAL.user_id,
		last_update_login = FND_GLOBAL.user_id
	WHERE   configuration_id = p_config_id;

	--take care of translation
	UPDATE  jts_configurations_tl
	SET     description = p_config_desc,
		last_update_date = sysdate,
		last_updated_by = FND_GLOBAL.user_id,
		last_update_login = FND_GLOBAL.user_id,
    		source_lang = USERENV('LANG')
	WHERE   configuration_id = p_config_id
	AND	USERENV('LANG') IN (language, source_lang);
   	COMMIT;
   END IF;

   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_name_and_desc;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );
    WHEN OTHERS THEN
      ROLLBACK TO update_name_and_desc;
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


-- Deletes a configuration and its versions
PROCEDURE  DELETE_CONFIGURATION(
      p_api_version            IN       NUMBER,
      p_config_id  	       IN 	NUMBER,
      x_return_status          OUT      VARCHAR2,
      x_msg_count              OUT      NUMBER,
      x_msg_data               OUT      VARCHAR2
) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'DELETE_CONFIGURATION';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Standard Start of API savepoint
   SAVEPOINT delete_configuration;

   fnd_msg_pub.initialize;

   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   JTS_CONFIG_VERSION_PVT.DELETE_VERSIONS(p_api_version,
					  p_config_id);
   JTS_CONFIGURATIONS_PKG.DELETE_ROW(p_config_id);
   Commit;

   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO delete_configuration;
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
END DELETE_CONFIGURATION;

-- Retrieves a configuration given a config_id
PROCEDURE  GET_CONFIGURATION(
      p_api_version             IN       NUMBER,
      p_init_msg_list		IN 	 VARCHAR2 DEFAULT FND_API.G_FALSE,
      p_config_id  		IN   	 NUMBER,
      x_configuration_rec 	OUT  	 NOCOPY  Config_Rec_Type,
      x_return_status          	OUT      VARCHAR2,
      x_msg_count              	OUT      NUMBER,
      x_msg_data               	OUT      VARCHAR2
) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'GET_CONFIGURATION';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;

BEGIN
   x_return_status := fnd_api.G_RET_STS_SUCCESS;

   IF (FND_API.to_boolean(p_init_msg_list)) THEN
       fnd_msg_pub.initialize;
   END IF;

   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   SELECT c.configuration_id, c.config_name, c.description, c.flow_id, fl.flow_name, fl.flow_type,
	  lf.meaning, c.record_mode, l.meaning, c.attribute_category, c.attribute1, c.attribute2,
	  c.attribute3, c.attribute4, c.attribute5, c.attribute6,
	  c.attribute7, c.attribute8, c.attribute9, c.attribute10,
	  c.attribute11, c.attribute12, c.attribute13, c.attribute14,
	  c.attribute15, c.creation_date, c.created_by, c.last_update_date,
	  c.last_updated_by, c.last_update_login, u1.user_name, u2.user_name
   INTO   x_configuration_rec
   FROM	  jts_configurations_vl c,
 	  fnd_lookup_values_vl l,
 	  fnd_lookup_values_vl lf,
 	  jts_setup_flows_vl fl,
	  fnd_user u1,
	  fnd_user u2
   WHERE  c.configuration_id = p_config_id
   AND 	  fl.flow_id = c.flow_id
   AND 	  l.lookup_type = C_RECORD_MODE_TYPE
   AND 	  l.lookup_code = c.record_mode
   AND 	  lf.lookup_type = C_FLOW_TYPE
   AND 	  lf.lookup_code = fl.flow_type
   AND	  u1.user_id (+) = c.created_by
   AND    u2.user_id (+) = c.last_updated_by;

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
END GET_CONFIGURATION;

-- Retrieves all configurations with a certain order by clause
-- Uses Dynamic SQL
PROCEDURE  GET_CONFIGURATIONS(
      p_api_version            	IN   NUMBER,
      p_where_clause		IN   VARCHAR2,
      p_order_by  		IN   VARCHAR2,
      p_how_to_order		IN   VARCHAR2,
      x_configuration_tbl 	OUT  NOCOPY  Config_Rec_Tbl_Type,
      x_return_status          	OUT  VARCHAR2,
      x_msg_count              	OUT  NUMBER,
      x_msg_data               	OUT  VARCHAR2
) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'GET_CONFIGURATIONS';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;

   TYPE Config_Cur_Typ IS REF CURSOR;
   config_csr   	Config_Cur_Typ;
   i			NUMBER := 1;
   sqlStmt		VARCHAR2(2000);
   l_how_to_order	VARCHAR2(30);
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

   l_how_to_order := substrb(upper(p_how_to_order), 1,30);
   IF (l_how_to_order <> 'ASC' AND l_how_to_order <> 'DESC') THEN
       l_how_to_order := 'ASC';
   END IF;

   IF (l_order_by = 'DESCRIPTION') THEN
       l_order_by := 'c.description';
   ELSIF (l_order_by = 'CREATION_DATE') THEN
       l_order_by := 'c.creation_date';
   ELSIF (l_order_by = 'CREATED_BY') THEN
       l_order_by := 'u1.user_name';
   ELSIF (l_order_by = 'TYPE') THEN
       l_order_by := 'lf.meaning, fl.flow_name';
   ELSIF (l_order_by = 'MODE') THEN
       l_order_by := 'l.meaning';
   END IF;

   sqlStmt := 'SELECT c.configuration_id, c.config_name, c.description, ' ||
		  ' c.flow_id, fl.flow_name, fl.flow_type, lf.meaning, c.record_mode, ' ||
		  ' l.meaning, c.attribute_category, c.attribute1, c.attribute2, ' ||
	  	  ' c.attribute3, c.attribute4, c.attribute5, c.attribute6, ' ||
	  	  ' c.attribute7, c.attribute8, c.attribute9, c.attribute10, ' ||
	  	  ' c.attribute11, c.attribute12, c.attribute13, c.attribute14, ' ||
	  	  ' c.attribute15, c.creation_date, c.created_by,  ' ||
		  ' c.last_update_date, c.last_updated_by, c.last_update_login, ' ||
		  ' u1.user_name, u2.user_name ' ||
	   ' FROM   jts_configurations_vl c, ' ||
		  ' fnd_lookup_values_vl l, ' ||
	          ' fnd_lookup_values_vl lf, ' ||
		  ' jts_setup_flows_vl fl, ' ||
	  	  ' fnd_user u1, ' ||
	  	  ' fnd_user u2 ' ||
	 ' WHERE  fl.flow_id = c.flow_id ' ||
	 ' AND 	  l.lookup_type = ''' || C_RECORD_MODE_TYPE ||
	 ''' AND 	  l.lookup_code = c.record_mode  ' ||
	 ' AND 	  lf.lookup_type = ''' || C_FLOW_TYPE ||
	 ''' AND 	  lf.lookup_code = fl.flow_type  ' ||
   	 ' AND	  u1.user_id  = c.created_by ' ||
   	 ' AND    u2.user_id  = c.last_updated_by ' ||
         p_where_clause ||
	 ' ORDER BY ' || l_order_by || ' ' || l_how_to_order;

   i := 1;
   OPEN config_csr FOR sqlStmt;
   LOOP
      FETCH config_csr INTO
		x_configuration_tbl(i).configuration_id,
		x_configuration_tbl(i).config_name,
		x_configuration_tbl(i).description,
		x_configuration_tbl(i).flow_id,
		x_configuration_tbl(i).flow_name,
		x_configuration_tbl(i).flow_type_code,
		x_configuration_tbl(i).flow_type,
		x_configuration_tbl(i).record_mode,
		x_configuration_tbl(i).displayed_record_mode,
		x_configuration_tbl(i).attribute_category,
		x_configuration_tbl(i).attribute1,
		x_configuration_tbl(i).attribute2,
		x_configuration_tbl(i).attribute3,
		x_configuration_tbl(i).attribute4,
		x_configuration_tbl(i).attribute5,
		x_configuration_tbl(i).attribute6,
		x_configuration_tbl(i).attribute7,
		x_configuration_tbl(i).attribute8,
		x_configuration_tbl(i).attribute9,
		x_configuration_tbl(i).attribute10,
		x_configuration_tbl(i).attribute11,
		x_configuration_tbl(i).attribute12,
		x_configuration_tbl(i).attribute13,
		x_configuration_tbl(i).attribute14,
		x_configuration_tbl(i).attribute15,
		x_configuration_tbl(i).creation_date,
		x_configuration_tbl(i).created_by,
		x_configuration_tbl(i).last_update_date,
		x_configuration_tbl(i).last_updated_by,
		x_configuration_tbl(i).last_update_login,
		x_configuration_tbl(i).created_by_name,
		x_configuration_tbl(i).last_updated_by_name;
      EXIT WHEN config_csr%NOTFOUND;
      i := i + 1;
   END LOOP;
   CLOSE config_csr;

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
END GET_CONFIGURATIONS;

-- Retrieves flow_id for a particular configuration
PROCEDURE  GET_FLOW_ID(
      p_config_id 		IN   NUMBER,
      x_flow_id          	OUT  NUMBER
) IS

BEGIN
   SELECT flow_id
   INTO   x_flow_id
   FROM   jts_configurations_b
   WHERE  configuration_id = p_config_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_flow_id := NULL;
   WHEN OTHERS THEN
      APP_EXCEPTION.raise_exception;
END GET_FLOW_ID;

END JTS_CONFIGURATION_PVT;

/
