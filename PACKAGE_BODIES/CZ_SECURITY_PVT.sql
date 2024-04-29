--------------------------------------------------------
--  DDL for Package Body CZ_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_SECURITY_PVT" 
/*      $Header: czsecurb.pls 120.4 2007/09/05 20:38:54 smanna ship $       */

AS

-----Pkg body declarations
TYPE ref_cursor IS REF CURSOR;

-----exception declarations
FUNCTION_NAME_NULL       EXCEPTION;
PRIVILEGE_IS_NULL        EXCEPTION;
INVALID_PRIVILEGE        EXCEPTION;
INSTANCE_SET_ERR         EXCEPTION;
MENU_ID_NOT_FOUND        EXCEPTION;
OBJECT_ID_NOT_FOUND      EXCEPTION;
PRIV_ALREADY_EXISTS      EXCEPTION;
NO_PRIV_EXISTS           EXCEPTION;
NO_ENTITY_ACCESS_CONTROL EXCEPTION;
ENTITY_IS_ALREADY_LOCKED EXCEPTION;
HAS_NO_LOCK_PRIV         EXCEPTION;
INVALID_USER_NAME        EXCEPTION;
INVALID_APPLICATION      EXCEPTION;
INVALID_RESPONSIBILITY   EXCEPTION;
USER_NAME_NULL           EXCEPTION;
APPL_NAME_NULL           EXCEPTION;
RESP_NAME_NULL           EXCEPTION;
NO_LOCK_CONTROL_REQUIRED EXCEPTION;
NO_LOCKS_REQD_FOR_EDIT   EXCEPTION;
NULL_USER_NAME           EXCEPTION;
RESP_IS_NULL             EXCEPTION;
ENTITY_ROLE_IS_NULL      EXCEPTION;
INVALID_ROLE             EXCEPTION;
INVALID_UI_STYLE         EXCEPTION;
PROJECT_IS_LOCKED        EXCEPTION;
ENTITY_LOCKED_BY_USER    EXCEPTION;
ENTITY_LOCKED_OTH_USER   EXCEPTION;
MODEL_LOCKED             EXCEPTION;

----------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
---get default acces profile value
FUNCTION get_default_access_profile
RETURN VARCHAR2
IS
l_return_value VARCHAR2(100):= '0';
BEGIN
  l_return_value := FND_PROFILE.value(DEFAULT_ENTITY_ACCESS);
  RETURN l_return_value ;
END get_default_access_profile;

------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-----get profile value
FUNCTION get_profile_value(p_profile IN VARCHAR2)
RETURN VARCHAR2
IS
l_profile_value VARCHAR2(30);

BEGIN
 IF (p_profile IS NOT NULL) THEN
    l_profile_value := FND_PROFILE.value(p_profile);
 ELSE
    l_profile_value := NULL;
 END IF;
 RETURN l_profile_value;
END get_profile_value;

----------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-----function that returns function_id for a function name
FUNCTION get_function_id (p_function_name IN VARCHAR2)
RETURN NUMBER
IS
l_function_id NUMBER := 0;
BEGIN
    SELECT function_id
    INTO   l_function_id
    FROM   fnd_form_functions
    WHERE  function_name = UPPER(p_function_name);
    RETURN l_function_id;
EXCEPTION
WHEN NO_DATA_FOUND THEN
 l_function_id := 0;
 RETURN l_function_id;
END get_function_id ;

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE log_lock_history (p_entity_type IN NUMBER,
                            p_entity_id   IN NUMBER,
                            p_event       IN VARCHAR2,
                            p_event_note  IN VARCHAR2)
IS

BEGIN
  insert into cz_lock_history (ENTITY_TYPE,INSTANCE_PK1_VALUE,INSTANCE_PK2_VALUE,INSTANCE_PK3_VALUE
,INSTANCE_PK4_VALUE,EVENT,EVENT_DATE,USER_NAME,EVENT_NOTE)
  VALUES (p_entity_type,p_entity_id ,0,0,0,p_event,sysdate,FND_GLOBAL.user_name,p_event_note);
EXCEPTION
WHEN OTHERS THEN
  NULL;  ----message needs to be logged
END log_lock_history ;

----------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-----function that returns the menu id for a menu name
FUNCTION get_menu_id_for_menuname (p_menu_name IN VARCHAR2)
RETURN NUMBER
IS
l_menu_id      NUMBER := 0;
BEGIN
      SELECT  menu_id
      INTO   l_menu_id
      FROM   fnd_menus
      WHERE  fnd_menus.menu_name = p_menu_name
      AND    fnd_menus.type = SECURITY_MENU;
      RETURN l_menu_id;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    l_menu_id := 0;
    RETURN l_menu_id;
END get_menu_id_for_menuname;

----------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-----Function that returns a menu_id for a function name
-----
FUNCTION get_menu_id_for_func_name(p_function_name IN VARCHAR2,
                                   p_menu_name     IN VARCHAR2)
RETURN NUMBER
IS

l_menu_id      NUMBER := 0;

BEGIN
     SELECT  menu_id
      INTO   l_menu_id
      FROM   fnd_compiled_menu_functions
      WHERE  fnd_compiled_menu_functions.function_id IN (SELECT function_id
                                                         FROM   fnd_form_functions
                                                         WHERE  fnd_form_functions.function_name = p_function_name)
      AND  fnd_compiled_menu_functions.menu_id = (SELECT menu_id
                                                  FROM   fnd_menus
                                                  WHERE  fnd_menus.menu_name = p_menu_name);
      RETURN l_menu_id;
EXCEPTION
WHEN NO_DATA_FOUND THEN
      RETURN l_menu_id;
END get_menu_id_for_func_name;

----------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-----function that returns an object_id for an entity type
FUNCTION get_object_id (p_entity_type IN VARCHAR2)
RETURN NUMBER
IS

l_object_id NUMBER := 0;

BEGIN
      SELECT object_id
      INTO   l_object_id
      FROM   fnd_objects
      WHERE  obj_name = UPPER(p_entity_type);
      RETURN l_object_id;
EXCEPTION
WHEN NO_DATA_FOUND THEN
      l_object_id := 0;
      RETURN l_object_id;
END get_object_id ;

----------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
----function that returns the instance_set_id for a given object_name
----and predicate
FUNCTION get_instance_set_id(p_object_id IN NUMBER,
                             p_predicate IN VARCHAR2)
RETURN NUMBER
IS

l_instance_set_id NUMBER := 0;
BEGIN
    SELECT instance_set_id
    INTO   l_instance_set_id
    FROM   FND_OBJECT_INSTANCE_SETS
    WHERE  object_id = p_object_id
    AND    instance_set_name = UPPER(p_predicate);
    RETURN l_instance_set_id;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  l_instance_set_id := 0;
  RETURN l_instance_set_id;
END get_instance_set_id;
---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION get_priv(p_instance_set_id IN NUMBER,
                p_menu_id IN VARCHAR2,
                p_user_name IN VARCHAR2)
RETURN VARCHAR2
IS
l_check_grant VARCHAR2(1) := 'F';
BEGIN
  SELECT 'T'
  INTO   l_check_grant
  FROM   fnd_grants
  WHERE  grantee_key     = UPPER(p_user_name)
  AND    instance_set_id = p_instance_set_id
  AND    menu_id         = p_menu_id;
  RETURN l_check_grant;
EXCEPTION
WHEN OTHERS THEN
  l_check_grant := 'F';
  RETURN l_check_grant;
END;

-------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION get_grant_access(p_model_id IN NUMBER)
RETURN VARCHAR2  IS
l_user_name VARCHAR2(100) := 'NOUSER';
l_priv      VARCHAR2(1) := 'N';
l_cur            REF_CURSOR;
BEGIN
  l_user_name := FND_GLOBAL.user_name;
  OPEN l_cur FOR 'SELECT '||l_user_name||'_MANAGE FROM  CZ_GRANTS_ON_ENTITIES_VIEW
                  WHERE model_id = '||p_model_id||' AND  entity_type = ''MODEL'' ';
  LOOP
      FETCH l_cur INTO l_priv;
      EXIT WHEN l_cur%NOTFOUND;
  END LOOP;
  CLOSE l_cur;
  RETURN l_priv;
EXCEPTION
WHEN OTHERS THEN
  RETURN l_priv;
END get_grant_access;
--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Stubbed as part of the bug 4861666, as this code is not utilized
-- in the system due to the obsoletion of "View Entity Access" feature
PROCEDURE GET_CZ_ACCESS_SUMMARY (p_model_id NUMBER)
AS
BEGIN
  NULL;
END GET_CZ_ACCESS_SUMMARY ;
--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE create_grants_on_models_v
AS
CURSOR C1 IS SELECT obj_name from fnd_objects;
l_column_name fnd_objects.obj_name%TYPE;
l_execute_str VARCHAR2(2000);

BEGIN
    l_execute_str := 'CREATE OR REPLACE VIEW CZ_GRANTS_ON_MODELS as SELECT model_id, object_name as model_name,';
    OPEN C1;
    LOOP
       FETCH C1 INTO l_column_name;
       EXIT WHEN C1%NOTFOUND;
       l_execute_str := l_execute_str||' '||l_column_name||',';
    END LOOP;
    CLOSE C1;
    l_execute_str := RTRIM(l_execute_str,',');
    l_execute_str := l_execute_str ||', cz_security_pvt.get_grant_access(model_id) as has_grant_access ' ||
     ' FROM CZ_GRANTS_ON_ENTITIES_VIEW WHERE entity_type = ''MODEL'' ';
    EXECUTE IMMEDIATE l_execute_str;
EXCEPTION
WHEN OTHERS THEN
   RAISE;
END create_grants_on_models_v;

----------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Stubbed as part of the bug 4861666, as this code is not utilized
-- in the system due to the obsoletion of "View Entity Access" feature
PROCEDURE GET_CZ_GRANTS_VIEW
AS
BEGIN
  NULL;
END GET_CZ_GRANTS_VIEW;

----------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-----function that returns predicate for an entity type
FUNCTION get_instance_set_name(p_entity_type IN VARCHAR2,
                               p_instance_pk1_value IN NUMBER)
RETURN VARCHAR2
IS

l_set_name VARCHAR2(30);

BEGIN
   IF (p_entity_type = cz_security_pvt.MODEL) THEN
      l_set_name := 'CZ_MODEL:'||to_char(p_instance_pk1_value);
   ELSIF (p_entity_type = cz_security_pvt.UI) THEN
      l_set_name := 'CZ_UI_DEF_ID:'||to_char(p_instance_pk1_value);
   ELSIF (p_entity_type = cz_security_pvt.RULEFOLDER) THEN
      l_set_name := 'CZ_RULEFOLDER:'||to_char(p_instance_pk1_value);
   END IF;
   RETURN l_set_name ;
END get_instance_set_name;

---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-----function that returns predicate for an entity type
FUNCTION get_predicate(p_entity_type IN VARCHAR2,
                       p_instance_pk1_value IN NUMBER)
RETURN VARCHAR2
IS

l_predicate VARCHAR2(4000);

BEGIN
   IF (p_entity_type = cz_security_pvt.MODEL) THEN
      l_predicate := 'DEVL_PROJECT_ID='||p_instance_pk1_value;
   ELSIF (p_entity_type = cz_security_pvt.UI) THEN
      l_predicate := 'DEVL_PROJECT_ID='||p_instance_pk1_value;
   ELSIF (p_entity_type = cz_security_pvt.RULEFOLDER) THEN
      l_predicate := 'RULE_FOLDER_ID='||p_instance_pk1_value;
   END IF;
   RETURN l_predicate;
END get_predicate;

----------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-----procedure to grant privilege
PROCEDURE grant_privilege(p_api_version           IN NUMBER,
                          p_user_name          IN VARCHAR2,
                          p_entity_role           IN VARCHAR2,
                          p_instance_pk1_value IN NUMBER,
                          x_return_status           OUT NOCOPY VARCHAR2,
                          x_msg_count           OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2)
IS

l_api_name        CONSTANT VARCHAR2(30) := 'grant_privilege';
l_api_version     CONSTANT NUMBER       := 1.0;
l_user_name       fnd_grants.grantee_key%TYPE;
l_ctx_resp_id     fnd_grants.CTX_RESP_ID%TYPE;
l_privilege       VARCHAR2(100);
l_menu_name       VARCHAR2(100);
l_menu_id            NUMBER;
l_object_id       NUMBER;
l_instance_set_id NUMBER;
l_resp_id            NUMBER;
l_function_name   fnd_form_functions.function_name%TYPE;
l_check_grant      NUMBER := 0;
l_inst_name       VARCHAR2(30);
l_entity_type     VARCHAR2(30);


BEGIN
      x_return_status := 'S';
      x_msg_count := 0;
        ---check api version
        IF NOT FND_API.Compatible_API_Call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
            RAISE G_INCOMPATIBLE_API;
        END IF;

      ----default user name
      IF (p_user_name IS NULL) THEN
           l_user_name := FND_GLOBAL.USER_NAME;
      ELSE
           l_user_name := p_user_name;
      END IF;

      IF (l_user_name IS NULL) THEN
            RAISE NULL_USER_NAME;
      END IF;

      IF (p_entity_role IS NULL) THEN
            RAISE ENTITY_ROLE_IS_NULL;
      END IF;
      l_menu_id    := get_menu_id_for_menuname(p_entity_role);
      IF (l_menu_id = 0) THEN
            RAISE MENU_ID_NOT_FOUND;
      END IF;

      IF (p_entity_role = cz_security_pvt.MANAGE_MODEL_ROLE) THEN
            l_entity_type := cz_security_pvt.MODEL;
                 l_inst_name := 'CZ_MODEL:'||p_instance_pk1_value;
      ELSIF (p_entity_role = cz_security_pvt.EDIT_MODEL_ROLE) THEN
            l_entity_type := cz_security_pvt.MODEL;
                 l_inst_name := 'CZ_MODEL:'||p_instance_pk1_value;
      ELSIF (p_entity_role = cz_security_pvt.EDIT_RULE_ROLE) THEN
            l_entity_type := cz_security_pvt.RULEFOLDER;
               l_inst_name := 'CZ_RULEFOLDER:'||p_instance_pk1_value;
      ELSIF (p_entity_role = cz_security_pvt.EDIT_UI_ROLE) THEN
            l_entity_type := cz_security_pvt.UI;
               l_inst_name := 'CZ_UI_DEF_ID:'||p_instance_pk1_value;
      ELSE
            RAISE INVALID_ROLE;
      END IF;

      ----get object id from fnd_objects
      l_object_id := get_object_id(l_entity_type);
      IF (l_object_id = 0) THEN
            RAISE OBJECT_ID_NOT_FOUND;
      END IF;

      -----initialize resp id
      l_resp_id := FND_GLOBAL.resp_id;
      IF (l_resp_id IS NULL) THEN
            RAISE RESP_IS_NULL;
      END IF;

      ----get instance_set_id
      l_instance_set_id := get_instance_set_id(l_object_id,l_inst_name);
      IF (l_instance_set_id = 0) THEN
            RAISE INSTANCE_SET_ERR;
      END IF;

      ---check if grant exists
      BEGIN
            SELECT 1
            INTO   l_check_grant
            FROM   fnd_grants
            WHERE  grantee_key     = UPPER(l_user_name)
            AND    instance_set_id = l_instance_set_id
            AND    menu_id         = l_menu_id
            AND    object_id       = l_object_id;
      EXCEPTION
      WHEN OTHERS THEN
            l_check_grant := 0;
      END;

      IF (l_check_grant = 1) THEN
            RAISE PRIV_ALREADY_EXISTS;
      ELSE
        ----insert into fnd_grants table
        INSERT INTO FND_GRANTS ( GRANT_GUID,GRANTEE_TYPE,GRANTEE_KEY,MENU_ID,START_DATE,OBJECT_ID
                              ,INSTANCE_TYPE,INSTANCE_SET_ID,INSTANCE_PK1_VALUE,INSTANCE_PK2_VALUE
                              ,INSTANCE_PK3_VALUE,INSTANCE_PK4_VALUE,INSTANCE_PK5_VALUE,CREATED_BY
                              ,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN
                              ,CTX_SECGRP_ID,CTX_RESP_ID,CTX_RESP_APPL_ID,CTX_ORG_ID)
        VALUES (sys_guid(),'GLOBAL',p_user_name,l_menu_id,sysdate,l_object_id
             ,'INSTANCE',l_instance_set_id,p_instance_pk1_value,'*NULL*','*NULL*','*NULL*','*NULL*',FND_GLOBAL.USER_ID,
             sysdate,FND_GLOBAL.USER_ID,sysdate,FND_GLOBAL.USER_ID,-1,l_resp_id,-1,-1);
      END IF;
EXCEPTION
WHEN G_INCOMPATIBLE_API THEN
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_API_VERSION_ERR','CODEVERSION',l_api_version,'VERSION',p_api_version);
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
WHEN NULL_USER_NAME THEN
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_USER_IS_NULL');
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
WHEN RESP_IS_NULL THEN
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_RESP_IS_NULL');
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
WHEN INVALID_ROLE THEN
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_INVALID_ROLE');
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
WHEN FUNCTION_NAME_NULL THEN
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_FUNC_NAME_IS_NULL');
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
WHEN ENTITY_ROLE_IS_NULL THEN
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_ENTITY_ROLE_IS_NULL');
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
WHEN MENU_ID_NOT_FOUND THEN
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_INVALID_ROLE', 'Privilege', p_entity_role  );
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
WHEN OBJECT_ID_NOT_FOUND THEN
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_OBJECT_ID_ERR', 'object_id',l_entity_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
WHEN INSTANCE_SET_ERR THEN
    x_msg_data  := CZ_UTILS.GET_TEXT('CZ_INVALID_INSTANCE_SET', 'SET',l_inst_name,
                                     'ENTITY_TYPE',l_entity_type, 'ERROR', SQLERRM);
    x_msg_count := 1;
    x_return_status := FND_API.G_RET_STS_ERROR;
WHEN PRIV_ALREADY_EXISTS THEN
      NULL;   ---not necessary to return a message
WHEN OTHERS THEN
    x_msg_data := SQLERRM;
    x_return_status := FND_API.G_RET_STS_ERROR;
END grant_privilege;

----------------------------------------------------------------
------revoke privilege on an entity
PROCEDURE revoke_privilege(p_api_version           IN NUMBER,
                          p_user_name          IN VARCHAR2,
                          p_entity_role           IN VARCHAR2,
                          p_instance_pk1_value IN NUMBER,
                          x_return_status           OUT NOCOPY VARCHAR2,
                          x_msg_count           OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2)
IS

l_api_name          CONSTANT VARCHAR2(30) := 'revoke_privilege';
l_api_version       CONSTANT NUMBER       := 1.0;
l_object_id         NUMBER;
l_instance_set_id   NUMBER;
l_predicate         VARCHAR2(2000);
l_menu_id           NUMBER;
l_function_id       NUMBER;
l_check_grant       NUMBER := 0;
l_instance_set_name VARCHAR2(30);
l_entity_type       VARCHAR2(30);

BEGIN
      x_return_status := 'S';
      x_msg_count := 0;
      ---check api version
      IF NOT FND_API.Compatible_API_Call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
        RAISE G_INCOMPATIBLE_API;
      END IF;

      IF (p_entity_role IS NULL) THEN
            RAISE ENTITY_ROLE_IS_NULL;
      END IF;
      l_menu_id := get_menu_id_for_menuname(p_entity_role);
      IF (l_menu_id = 0) THEN
            RAISE MENU_ID_NOT_FOUND;
      END IF;

      IF (p_entity_role = cz_security_pvt.MANAGE_MODEL_ROLE) THEN
            l_entity_type := cz_security_pvt.MODEL;
      ELSIF (p_entity_role = cz_security_pvt.EDIT_MODEL_ROLE) THEN
            l_entity_type := cz_security_pvt.MODEL;
      ELSIF (p_entity_role = cz_security_pvt.EDIT_RULE_ROLE) THEN
            l_entity_type := cz_security_pvt.RULEFOLDER;
      ELSIF (p_entity_role = cz_security_pvt.EDIT_UI_ROLE) THEN
            l_entity_type := cz_security_pvt.UI;
      ELSE
            RAISE INVALID_ROLE;
      END IF;

     -----get object_id
     l_object_id := get_object_id (l_entity_type);
     IF (l_object_id = 0) THEN
       RAISE OBJECT_ID_NOT_FOUND;
     END IF;

     ----get predicate
     l_instance_set_name := get_instance_set_name(l_entity_type,p_instance_pk1_value);

     -----get instance_set_id
     l_instance_set_id := get_instance_set_id(l_object_id,l_instance_set_name);

      ----check if privilege actually exists
     SELECT 1
     INTO   l_check_grant
     FROM   fnd_grants
     WHERE  grantee_key     = UPPER(p_user_name)
     AND    instance_set_id = l_instance_set_id
     AND    menu_id         = l_menu_id
     AND    object_id       = l_object_id;

     IF (l_check_grant <> 1) THEN
            RAISE NO_PRIV_EXISTS;   ---do we need to do a check and return an error message
     ELSE
           DELETE FROM fnd_grants
           WHERE  grantee_key = UPPER(p_user_name)
           AND    menu_id = l_menu_id
           AND    object_id = l_object_id
           AND    instance_set_id = l_instance_set_id
           AND    instance_pk1_value = to_char(p_instance_pk1_value);
     END IF;
EXCEPTION
WHEN G_INCOMPATIBLE_API THEN
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_API_VERSION_ERR','CODEVERSION',l_api_version,'VERSION',p_api_version);
    x_return_status := FND_API.G_RET_STS_ERROR;
WHEN OBJECT_ID_NOT_FOUND THEN
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_OBJECT_ID_ERR', 'object_id', l_entity_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
WHEN INVALID_ENTITY_TYPE THEN
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_INVALID_ENTITY_TYP', 'OBJECTTYPE', l_entity_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
WHEN ENTITY_ROLE_IS_NULL THEN
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_ENTITY_ROLE_IS_NULL');
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
WHEN MENU_ID_NOT_FOUND THEN
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_INVALID_ROLE', 'Privilege', p_entity_role  );
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := 1;
WHEN NO_PRIV_EXISTS THEN
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_NO_PRIV_EXISTS');
    -----x_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
    x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_FATAL_ERR', 'SQLERRM', SQLERRM);
    x_return_status := FND_API.G_RET_STS_ERROR;
END revoke_privilege;

-------------------------------------------------------------
PROCEDURE revoke_privilege(p_api_version            IN NUMBER,
                           p_instance_pk1_value IN NUMBER,
                           x_return_status      OUT NOCOPY VARCHAR2,
                           x_msg_count            OUT NOCOPY NUMBER,
                           x_msg_data           OUT NOCOPY VARCHAR2)
IS

l_object_id         NUMBER;
l_instance_set_id   NUMBER;
l_predicate         VARCHAR2(2000);
l_menu_id           NUMBER;
l_function_id       NUMBER;
l_check_grant       NUMBER := 0;
l_instance_set_name VARCHAR2(30);
l_entity_type       VARCHAR2(30);

BEGIN
      l_entity_type := cz_security_pvt.MODEL;
      l_object_id := get_object_id (l_entity_type);
      l_instance_set_name := get_instance_set_name(l_entity_type,p_instance_pk1_value);
      l_instance_set_id := get_instance_set_id(l_object_id,l_instance_set_name);
      l_menu_id := get_menu_id_for_menuname(cz_security_pvt.MANAGE_MODEL_ROLE);

      DELETE FROM fnd_grants WHERE  menu_id = l_menu_id AND object_id = l_object_id
      AND instance_set_id = l_instance_set_id AND instance_pk1_value = to_char(p_instance_pk1_value);

      l_object_id := get_object_id (l_entity_type);
      l_instance_set_name := get_instance_set_name(l_entity_type,p_instance_pk1_value);
      l_instance_set_id := get_instance_set_id(l_object_id,l_instance_set_name);
      l_menu_id := get_menu_id_for_menuname(cz_security_pvt.EDIT_MODEL_ROLE);

      DELETE FROM fnd_grants WHERE  menu_id = l_menu_id AND object_id = l_object_id
      AND instance_set_id = l_instance_set_id AND instance_pk1_value = to_char(p_instance_pk1_value);

      l_entity_type := cz_security_pvt.RULEFOLDER;
      l_object_id := get_object_id (l_entity_type);
      l_instance_set_name := get_instance_set_name(l_entity_type,p_instance_pk1_value);
      l_instance_set_id := get_instance_set_id(l_object_id,l_instance_set_name);
      l_menu_id := get_menu_id_for_menuname(cz_security_pvt.EDIT_RULE_ROLE);

      DELETE FROM fnd_grants WHERE  menu_id = l_menu_id AND object_id = l_object_id
      AND instance_set_id = l_instance_set_id AND instance_pk1_value = to_char(p_instance_pk1_value);

      l_entity_type := cz_security_pvt.UI;
      l_object_id := get_object_id (l_entity_type);
      l_instance_set_name := get_instance_set_name(l_entity_type,p_instance_pk1_value);
      l_instance_set_id := get_instance_set_id(l_object_id,l_instance_set_name);
      l_menu_id := get_menu_id_for_menuname(cz_security_pvt.EDIT_UI_ROLE);

      DELETE FROM fnd_grants WHERE  menu_id = l_menu_id AND object_id = l_object_id
      AND instance_set_id = l_instance_set_id AND instance_pk1_value = to_char(p_instance_pk1_value);
END;

--------------------------------------------------------------------
--------check privilege
----@p_api_version : api version current version is 1.0
----@p_user_name : fnd user ex: OPERATIONS
----@p_function_name : fnd function , function name of the task
----@p_entity_type   : Fnd_objects.obj_name ex MODEL, UI RULEFOLDER
----for the above use global constants
----@p_instance_pk1_value : primary key of the object ex devl_project_id or rule_folder_id
FUNCTION has_privileges  (p_api_version        IN NUMBER,
                          p_user_name          IN VARCHAR2,
                          p_function_name      IN VARCHAR2,
                          p_entity_type        IN VARCHAR2,
                          p_instance_pk1_value IN NUMBER)
RETURN VARCHAR2
IS

l_priv VARCHAR2(100) := 'T';
l_profile_value VARCHAR2(1000);
l_api_name      CONSTANT VARCHAR2(1000) := 'has_privileges';
l_api_version   CONSTANT NUMBER         := 1.0;
l_function_name  fnd_form_functions.function_name%TYPE;
l_user_name      VARCHAR2(40);
BEGIN
    ---check api version
   IF NOT FND_API.Compatible_API_Call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
      RAISE G_INCOMPATIBLE_API;
   END IF;
   l_profile_value := get_profile_value(USE_ENTITY_ACCESS_CONTROL);
   IF ( (l_profile_value <> 'Y') ) THEN
      RAISE NO_ENTITY_ACCESS_CONTROL;
   ELSE
      l_priv := 'T';
   END IF;
   RETURN l_priv;
EXCEPTION
WHEN G_INCOMPATIBLE_API THEN
    l_priv := 'F';
    RETURN l_priv;
WHEN NO_ENTITY_ACCESS_CONTROL THEN
    l_priv := 'T';
    RETURN l_priv;
END has_privileges;

---------------------------------------------------
FUNCTION has_privileges  (p_function_name      IN VARCHAR2,
                          p_entity_type        IN VARCHAR2,
                          p_instance_pk1_value IN NUMBER)
RETURN VARCHAR2
IS
l_function_name fnd_form_functions.function_name%TYPE;
l_user_name       VARCHAR2(40);
BEGIN
  RETURN 'T';
EXCEPTION
WHEN OTHERS THEN
    RETURN 'U';
END has_privileges;

------------------------------------------------------------------------
-----check lock on a entity
FUNCTION is_locked (p_entity_name           IN VARCHAR2,
                    p_primary_key          IN VARCHAR2,
                    p_primary_key_value IN NUMBER )
RETURN VARCHAR2
IS

l_checkout_user      VARCHAR2(40) := NULL;
checkout_cur       ref_cursor;

BEGIN
      OPEN checkout_cur FOR 'SELECT checkout_user FROM '||p_entity_name||'
                             WHERE  '||p_primary_key||' = '||p_primary_key_value;
      LOOP
            FETCH checkout_cur INTO l_checkout_user;
            EXIT WHEN checkout_cur%NOTFOUND;
      END LOOP;
      CLOSE checkout_cur;
      RETURN l_checkout_user;
END is_locked ;
--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE lock_entity(p_model_id IN NUMBER,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_data      OUT NOCOPY VARCHAR2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_data      := '';
END lock_entity ;

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE unlock_entity(p_model_id      IN NUMBER,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_data      OUT NOCOPY VARCHAR2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_data      := '';
END unlock_entity;

---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE get_entities_to_lock(p_entity_type     IN VARCHAR2,
                               p_entity_id       IN NUMBER,
                               x_locked_entities OUT NOCOPY number_type_tbl)
IS

rec_count                     NUMBER := 0;
l_ui_style             cz_ui_defs.ui_style%TYPE;
l_devl_project_id      cz_ui_defs.devl_project_id%TYPE;
l_cz_ui_defs_id_tbl    number_type_tbl;
l_cz_ui_defs_style_tbl varchar_type_tbl;

BEGIN
 IF (p_entity_type = cz_security_pvt.MODEL) THEN
    -----get all model entities to lock
    BEGIN
      SELECT distinct component_id
      BULK
      COLLECT
      INTO   x_locked_entities
      FROM   cz_model_ref_expls
      WHERE  cz_model_ref_expls.model_id = p_entity_id
      AND    cz_model_ref_expls.deleted_flag = '0'
      AND    cz_model_ref_expls.ps_node_type = 263;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    END;

    rec_count := x_locked_entities.COUNT + 1;
    x_locked_entities(rec_count) := p_entity_id;

 ELSIF (p_entity_type = cz_security_pvt.UI) THEN

    -----get UI style
    BEGIN
     SELECT ui_style
     INTO   l_ui_style
     FROM   cz_ui_defs
     WHERE  cz_ui_defs.devl_project_id = p_entity_id
     AND    cz_ui_defs.deleted_flag = '0';
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         NULL;
    END;
    -----get all UI entities to lock
    IF (l_ui_style IN ('0','3') ) THEN

     BEGIN
      SELECT ui_def_ref_id
      BULK
      COLLECT
      INTO       x_locked_entities
      FROM   cz_ui_nodes
      WHERE  cz_ui_nodes.deleted_flag = '0'
      AND    cz_ui_nodes.ui_def_ref_id IS NOT NULL
      AND    cz_ui_nodes.ui_def_id = p_entity_id;
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
         NULL;
     END;

     rec_count := x_locked_entities.COUNT + 1;
     x_locked_entities(rec_count) := p_entity_id;

    ELSIF (l_ui_style = '7') THEN

      BEGIN
       SELECT ref_ui_def_id
       BULK
       COLLECT
       INTO   x_locked_entities
       FROM   cz_ui_refs
       WHERE  cz_ui_refs.ui_def_id = p_entity_id
       AND    cz_ui_refs.deleted_flag = '0'
       AND    cz_ui_refs.ref_ui_def_id IN (SELECT ui_def_id
                                        FROM   cz_ui_defs
                                        WHERE  cz_ui_defs.deleted_flag = '0'
                                         AND   cz_ui_defs.ui_style = '7');
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
         NULL;
     END;
     rec_count := x_locked_entities.COUNT + 1;
     x_locked_entities(rec_count) := p_entity_id;
   END IF;

 ELSIF (p_entity_type = cz_security_pvt.RULEFOLDER) THEN
    -----get all RULEFOLDER entities to lock
    -----Do we user connect by or developer will handle it
    BEGIN
     SELECT rule_folder_id
     BULK
     COLLECT
     INTO   x_locked_entities
     FROM   cz_rule_folders
     WHERE  cz_rule_folders.object_type = 'RFL'
     AND    cz_rule_folders.deleted_flag = '0'
     AND    cz_rule_folders.rule_folder_id = p_entity_id;
     EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    END;
 END IF;
EXCEPTION
WHEN OTHERS THEN
    RAISE;
END get_entities_to_lock;

------------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE get_already_locked_entities(p_entity_type       IN  VARCHAR2,
                                      p_entity_id         IN  NUMBER,
                                      x_locked_entities   OUT NOCOPY number_type_tbl,
                                      x_checkout_user_tbl OUT NOCOPY varchar_type_tbl)
IS

rec_count                NUMBER := 0;
l_ui_style          cz_ui_defs.ui_style%TYPE;
l_locked_entities   number_type_tbl;
l_checkout_user_tbl varchar_type_tbl;

BEGIN
 IF (p_entity_type = cz_security_pvt.MODEL) THEN
    -----get all model entities to lock
    SELECT component_id
    BULK
    COLLECT
    INTO   l_locked_entities
    FROM   cz_model_ref_expls
    WHERE  model_id = p_entity_id
    AND    deleted_flag = '0'
    AND    component_id IN (SELECT devl_project_id
                            FROM   cz_devl_projects
                            WHERE  cz_devl_projects.deleted_flag = '0'
                                AND    checkout_user IS NOT NULL );

   IF (l_locked_entities.COUNT > 0) THEN
      FOR J IN l_locked_entities.FIRST..l_locked_entities.LAST
      LOOP
          SELECT checkout_user
          BULK
          COLLECT
          INTO   l_checkout_user_tbl
          FROM   cz_ps_nodes
          WHERE  cz_ps_nodes.ps_node_id = l_locked_entities(j)
           AND   cz_ps_nodes.deleted_flag = '0'
           AND   cz_ps_nodes.checkout_user IS NOT NULL;

          IF (l_checkout_user_tbl.COUNT > 0) THEN
             rec_count := x_locked_entities.COUNT + 1;
             x_locked_entities(rec_count) := l_locked_entities(j);
             x_checkout_user_tbl(rec_count) := l_checkout_user_tbl(1);
          END IF;
      END LOOP;
   END IF;

 ELSIF (p_entity_type = cz_security_pvt.UI) THEN

    -----get UI style
    SELECT ui_style
    INTO   l_ui_style
    FROM   cz_ui_defs
    WHERE  cz_ui_defs.ui_def_id = p_entity_id
    AND    cz_ui_defs.deleted_flag = '0';

    -----get all UI entities to lock
    IF (l_ui_style IN ('0','3') ) THEN

      SELECT ui_def_ref_id
      BULK
      COLLECT
      INTO       l_locked_entities
      FROM   cz_ui_nodes
      WHERE  deleted_flag = '0'
      AND    ui_def_ref_id IS NOT NULL
      AND    ui_def_id = p_entity_id;

      IF (l_locked_entities.COUNT > 0) THEN
         FOR J IN l_locked_entities.FIRST..l_locked_entities.LAST
         LOOP
            SELECT checkout_user
            BULK
            COLLECT
            INTO   l_checkout_user_tbl
            FROM   cz_ui_defs
            WHERE  cz_ui_defs.ui_def_id = l_locked_entities(j)
            AND    cz_ui_defs.deleted_flag = '0'
            AND    cz_ui_defs.checkout_user IS NOT NULL;

            IF (l_checkout_user_tbl.COUNT > 0) THEN
             rec_count := x_locked_entities.COUNT + 1;
             x_locked_entities(rec_count) := l_locked_entities(j);
             x_checkout_user_tbl(rec_count) := l_checkout_user_tbl(1);
            END IF;
         END LOOP;
      END IF;

    ELSIF (l_ui_style = '7') THEN

      SELECT ref_ui_def_id
      BULK
      COLLECT
      INTO   l_locked_entities
      FROM   cz_ui_refs
      WHERE  cz_ui_refs.ui_def_id = p_entity_id
      AND    cz_ui_refs.deleted_flag = '0'
      AND    cz_ui_refs.ref_ui_def_id  IN (SELECT ui_def_id
                                    FROM  cz_ui_defs x
                                    WHERE x.deleted_flag = '0'
                                    AND   x.checkout_user IS NOT NULL
                                    AND   x.ui_style = '7');

      IF (l_locked_entities.COUNT > 0) THEN
         FOR J IN l_locked_entities.FIRST..l_locked_entities.LAST
         LOOP
            SELECT checkout_user
            BULK
            COLLECT
            INTO   l_checkout_user_tbl
            FROM   cz_ui_defs
            WHERE  cz_ui_defs.ui_def_id = l_locked_entities(j)
            AND    cz_ui_defs.deleted_flag = '0'
            AND    cz_ui_defs.checkout_user IS NOT NULL;

            IF (l_checkout_user_tbl.COUNT > 0) THEN
             rec_count := x_locked_entities.COUNT + 1;
             x_locked_entities(rec_count) := l_locked_entities(j);
             x_checkout_user_tbl(rec_count) := l_checkout_user_tbl(1);
            END IF;
         END LOOP;
      END IF;
   END IF;

 ELSIF (p_entity_type = cz_security_pvt.RULEFOLDER) THEN

    -----get all RULEFOLDER entities to lock
    -----Do we user connect by or developer will handle it
    SELECT rule_folder_id,checkout_user
    BULK
    COLLECT
    INTO   x_locked_entities,x_checkout_user_tbl
    FROM   cz_rule_folders
    WHERE  cz_rule_folders.object_type = 'RFL'
    AND    cz_rule_folders.deleted_flag = '0'
    AND    cz_rule_folders.devl_project_id = p_entity_id
    AND    cz_rule_folders.checkout_user IS NOT NULL;

 END IF;
EXCEPTION
WHEN OTHERS THEN
    RAISE;
END get_already_locked_entities;

----------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE  update_to_lock_entities(p_entity_type IN VARCHAR2,
                                   p_user_name   IN VARCHAR2,
                                   p_entities_to_lock IN number_type_tbl)
IS

l_table_name VARCHAR2(128);
l_primary_key_name VARCHAR2(128);
l_user_id NUMBER := FND_GLOBAL.USER_ID;
l_str VARCHAR2(2000);
l_event_note    VARCHAR2(2000);
l_entity        NUMBER;
BEGIN
   IF (p_entity_type = cz_security_pvt.MODEL) THEN
      l_table_name := 'cz_devl_projects';
      l_primary_key_name := 'devl_project_id';
      l_entity := 2;
   ELSIF (p_entity_type = cz_security_pvt.UI) THEN
      l_table_name := 'cz_ui_defs';
      l_primary_key_name := 'ui_def_id';
      l_entity := 3;
   ELSIF (p_entity_type = cz_security_pvt.RULEFOLDER) THEN
      l_table_name := 'cz_rule_folders';
      l_primary_key_name := 'rule_folder_id';
      l_entity := 4;
   END IF;

   IF (p_entities_to_lock.COUNT > 0) THEN
      FOR toLock IN p_entities_to_lock.FIRST..p_entities_to_lock.LAST
      LOOP
          EXECUTE IMMEDIATE
        'UPDATE '||l_table_name||'  SET checkout_user = :1 WHERE  '||l_primary_key_name||'  = :2  '
         USING p_user_name,p_entities_to_lock(toLock);
      END LOOP;
   END IF;
EXCEPTION
WHEN OTHERS THEN
   RAISE;
END update_to_lock_entities;

---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE  update_to_unlock_entities(p_entity_type   IN VARCHAR2,
                                p_entities_to_unlock IN number_type_tbl)
IS

BEGIN
   update_to_lock_entities(p_entity_type,'',p_entities_to_unlock);
EXCEPTION
WHEN OTHERS THEN
   RAISE;
END update_to_unlock_entities;

----------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------function that checks if it is necessary to lock
------a model
PROCEDURE is_lock_required (p_lock_profile  IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER)
IS
l_profile_value VARCHAR2(100);
PROFILE_VALUE_NULL EXCEPTION;

BEGIN
  l_profile_value := FND_PROFILE.value(p_lock_profile);
  IF (l_profile_value IS NULL) THEN
     RAISE PROFILE_VALUE_NULL;
  END IF;

  IF ( (l_profile_value = 'Y') OR (l_profile_value = 'YES') )  THEN
      x_return_status := 'Y';
  ELSE
      x_return_status := 'N';
  END IF;
EXCEPTION
WHEN PROFILE_VALUE_NULL THEN
   x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_PROFILE_NULL');
   x_msg_count := 1;
   x_return_status := 'U';
WHEN OTHERS THEN
   x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_PRIV_FATAL_ERR', 'ERR', SQLERRM);
   x_msg_count := 1;
   x_return_status := 'U';
END is_lock_required ;

------------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-----procedure to lock entity
PROCEDURE lock_entity   (p_api_version            IN NUMBER,
                            p_user_name           IN VARCHAR2,
                            p_entity_type         IN VARCHAR2,
                            p_instance_pk1_value  IN NUMBER,
                            p_lock_type           IN VARCHAR2,
                            x_locked_entities     OUT NOCOPY number_type_tbl,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := 0;
  x_msg_data      := '';
END lock_entity;

---------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-----procedure called by back end PL/SQL API(s)
-----to lock an entity
PROCEDURE lock_entity (p_model_id IN NUMBER,
                       p_function_name IN VARCHAR2,
                          x_locked_entities  OUT NOCOPY number_type_tbl,
                          x_return_status    OUT NOCOPY VARCHAR2,
                          x_msg_count        OUT NOCOPY NUMBER,
                          x_msg_data         OUT NOCOPY VARCHAR2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := 0;
  x_msg_data      := '';
END lock_entity;

--------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-----API used for Developer check out
PROCEDURE lock_entity (p_model_id IN NUMBER,
                       p_function_name IN VARCHAR2,
                          x_return_status    OUT NOCOPY VARCHAR2,
                          x_msg_count        OUT NOCOPY NUMBER,
                          x_msg_data         OUT NOCOPY VARCHAR2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := 0;
  x_msg_data      := '';
END lock_entity;

--------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE lock_entity   (p_api_version            IN NUMBER,
                            p_user_name           IN VARCHAR2,
                            p_entity_type         IN VARCHAR2,
                            p_instance_pk1_value  IN NUMBER,
                            p_lock_type           IN VARCHAR2,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := 0;
  x_msg_data      := '';
END lock_entity;

---------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE unlock_entity  (p_api_version           IN NUMBER,
                          p_user_name          IN VARCHAR2,
                          p_entity_type             IN VARCHAR2,
                          p_instance_pk1_value IN NUMBER,
                          p_locked_entities    IN OUT NOCOPY number_type_tbl,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2)
IS

l_api_name      CONSTANT VARCHAR2(30) := 'ulock_entity';
l_api_version   CONSTANT NUMBER       := 1.0;
l_user_priv     VARCHAR2(1);
l_function_name fnd_form_functions.function_name%TYPE;
l_proj_id          NUMBER := 0;
l_locked_entities_tbl number_type_tbl;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := 0;
  x_msg_data      := '';
END unlock_entity;

-------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE unlock_entity  (p_model_id IN NUMBER,
                          p_function_name IN VARCHAR2,
                          p_locked_entities IN OUT NOCOPY number_type_tbl,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := 0;
  x_msg_data      := '';
END unlock_entity;

------------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE unlock_entity  (p_model_id      IN NUMBER,
                          p_function_name IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := 0;
  x_msg_data      := '';
END unlock_entity;

------------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE unlock_model (p_model_id IN NUMBER,
                         x_return_status    OUT NOCOPY VARCHAR2,
                         x_msg_count        OUT NOCOPY NUMBER,
                         x_msg_data         OUT NOCOPY VARCHAR2)
IS
BEGIN
    x_return_status := 'T';
    x_msg_count     := 0;
    x_msg_data      := '';
END unlock_model;

----------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE unlock_entity   (p_api_version          IN NUMBER,
                            p_user_name           IN VARCHAR2,
                            p_entity_type         IN VARCHAR2,
                            p_instance_pk1_value  IN NUMBER,
                            p_lock_type           IN VARCHAR2,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := 0;
  x_msg_data      := '';
END unlock_entity;

------------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION get_user_id(p_user_name IN VARCHAR2)
RETURN NUMBER
IS

l_user_id NUMBER := 0;

BEGIN
  SELECT user_id
   INTO  l_user_id
   FROM  fnd_user
  WHERE  user_name = UPPER(p_user_name);
  RETURN l_user_id;
END get_user_id;

------------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION get_application_id(p_application IN VARCHAR2)
RETURN NUMBER
IS

l_application_id NUMBER := 0;

BEGIN
  SELECT application_id
   INTO  l_application_id
   FROM  fnd_application
  WHERE  application_short_name = UPPER(p_application);
  RETURN l_application_id ;
END get_application_id;

------------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION get_responsibility_id(p_responsibility IN VARCHAR2)
RETURN NUMBER
IS

l_responsibility_id NUMBER := 0;

BEGIN
  SELECT responsibility_id
   INTO  l_responsibility_id
   FROM  fnd_responsibility
  WHERE  responsibility_key = UPPER(p_responsibility)
   AND   application_id = 708;
  RETURN l_responsibility_id;
END get_responsibility_id;

------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------procedure called by back end PL/SQL API(s)
------to check if the user has privilege to execute
------the stored procedure on the model
PROCEDURE has_privileges(p_model_id IN NUMBER,
                    p_function_name IN VARCHAR2,
                    x_return_status OUT NOCOPY VARCHAR2,
                    x_msg_data      OUT NOCOPY VARCHAR2,
                    x_msg_count     OUT NOCOPY NUMBER)
IS
BEGIN
   x_return_status := HAS_PRIVILEGE;
   x_msg_count     := 0;
   x_msg_data      := '';
END has_privileges;

-------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
----This API would return 'T' if the user has edit access on atleast one entity (MODEL,UI,RULEFOLDER),
-----otherwise it will return 'F'.
-----This is used for the enable or disable the edit icon in the repository.
FUNCTION has_model_privileges(p_model_id IN NUMBER)
RETURN VARCHAR2
IS
BEGIN
    RETURN 'T';
END has_model_privileges;

------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-----procedure called by back end API(s) to check for priv
-----and locking entities
PROCEDURE check_priv_and_lock_entity (p_api_version     IN  NUMBER,
                                      p_user_name       IN  VARCHAR2,
                                      p_responsibility  IN  VARCHAR2,
                                      p_application     IN  VARCHAR2,
                                      p_entity_type     IN  VARCHAR2,
                                      p_instance_pk1_value  IN NUMBER,
                                      x_locked_entities OUT NOCOPY number_type_tbl,
                                      x_return_status   OUT NOCOPY VARCHAR2,
                                      x_msg_count       OUT NOCOPY NUMBER,
                                      x_msg_data        OUT NOCOPY VARCHAR2)
IS

l_api_name       CONSTANT VARCHAR2(30) := 'check_priv_and_lock_entity';
l_api_version    CONSTANT NUMBER       := 1.0;
l_user_id        NUMBER := 0;
l_application_id NUMBER := 0;
l_resp_id        NUMBER := 0;
l_profile_value  VARCHAR2(255) := '';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := 0;

  ---check api version
  IF NOT FND_API.Compatible_API_Call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;

  -----check if models have to be locked for global operations
  l_profile_value := get_profile_value(LOCK_MODELS_FOR_GLOPS);
  IF (l_profile_value = 'NO') THEN
      RAISE NO_LOCK_CONTROL_REQUIRED;
  END IF;

  ----get user id
  IF (p_user_name IS NULL) THEN
     RAISE USER_NAME_NULL;
  END IF;

  l_user_id := get_user_id(p_user_name);
  IF (l_user_id = 0) THEN
     RAISE INVALID_USER_NAME;
  END IF;

  ----get application id
  IF (p_application IS NULL) THEN
     RAISE APPL_NAME_NULL;
  END IF;

  l_application_id := get_application_id(p_application);
  IF (l_application_id = 0) THEN
      RAISE INVALID_APPLICATION;
  END IF;

  ----get responsibility id
  IF (p_responsibility IS NULL) THEN
     RAISE RESP_NAME_NULL;
  END IF;

  l_resp_id := get_responsibility_id(p_responsibility);
  IF (l_resp_id = 0) THEN
    RAISE INVALID_RESPONSIBILITY;
  END IF;

  ----fnd initialize
  fnd_global.apps_initialize(l_user_id,l_resp_id,l_application_id);

  -----lock entity
  cz_security_pvt.lock_entity (p_api_version,
                               p_user_name,
                               p_entity_type,
                               p_instance_pk1_value,
                               DEEP_LOCK,
                               x_locked_entities,
                               x_return_status,
                               x_msg_count,
                               x_msg_data);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     x_msg_data  := CZ_UTILS.GET_TEXT('CZ_SEC_LOCK_ENTITY_ERR');
     x_msg_count := 1;
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

EXCEPTION
WHEN G_INCOMPATIBLE_API THEN
   x_msg_data  := CZ_UTILS.GET_TEXT('CZ_SEC_API_VERSION_ERR','CODEVERSION',l_api_version,'VERSION',p_api_version);
   x_msg_count := 1;
   x_return_status := FND_API.G_RET_STS_ERROR;
WHEN NO_LOCK_CONTROL_REQUIRED THEN
   NULL; ----do nothing
WHEN USER_NAME_NULL THEN
   x_msg_data  := CZ_UTILS.GET_TEXT('CZ_SEC_USER_NAME_NULL');
   x_msg_count := 1;
   x_return_status := FND_API.G_RET_STS_ERROR;
WHEN INVALID_USER_NAME THEN
   x_msg_data  := CZ_UTILS.GET_TEXT('CZ_SEC_INVALID_USER_NAME','USERNAME',p_user_name);
   x_msg_count := 1;
   x_return_status := FND_API.G_RET_STS_ERROR;
WHEN APPL_NAME_NULL THEN
   x_msg_data  := CZ_UTILS.GET_TEXT('CZ_SEC_APPL_NAME_NULL');
   x_msg_count := 1;
   x_return_status := FND_API.G_RET_STS_ERROR;
WHEN RESP_NAME_NULL THEN
   x_msg_data  := CZ_UTILS.GET_TEXT('CZ_SEC_RESP_NAME_NULL');
   x_msg_count := 1;
   x_return_status := FND_API.G_RET_STS_ERROR;
WHEN INVALID_APPLICATION THEN
   x_msg_data  := CZ_UTILS.GET_TEXT('CZ_SEC_INVALID_APPLICATION','APPLICATION',p_application);
   x_msg_count := 1;
   x_return_status := FND_API.G_RET_STS_ERROR;
WHEN INVALID_RESPONSIBILITY THEN
   x_msg_data  := CZ_UTILS.GET_TEXT('CZ_SEC_INVALID_RESPONSIBILITY','RESPONSIBILITY',p_responsibility);
   x_msg_count := 1;
   x_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
   x_msg_data  := SQLERRM;
   x_msg_count := 1;
   x_return_status := FND_API.G_RET_STS_ERROR;
END check_priv_and_lock_entity;

-------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION are_models_locked (p_model_id IN NUMBER)
RETURN VARCHAR2
IS
l_models  number_type_tbl;
l_status  VARCHAR2(2000);
rec_count NUMBER := 0;
l_checkout_user VARCHAR2(40) := '';
l_model_id      NUMBER := 0;
MODEL_ID_IS_NULL EXCEPTION;

BEGIN
   l_status   := '0';
   IF (p_model_id IS NULL) THEN
      RAISE MODEL_ID_IS_NULL;
   END IF;

   SELECT component_id
   BULK
   COLLECT
   INTO   l_models
   FROM   cz_model_ref_expls
   WHERE  model_id = p_model_id
   AND    ps_node_type = 263
   AND    deleted_flag = '0';

   rec_count := l_models.COUNT + 1;
   l_models(rec_count) := p_model_id;

   IF (l_models.COUNT > 0) THEN
      FOR modelId IN l_models.FIRST..l_models.LAST
      LOOP
          l_model_id := l_models(modelId);
          SELECT checkout_user
           INTO  l_checkout_user
          FROM   cz_devl_projects
          WHERE  cz_devl_projects.devl_project_id = l_model_id
           AND   cz_devl_projects.deleted_flag = '0';

         IF (l_checkout_user IS NULL) THEN
               l_status := '0';
         ELSIF (l_checkout_user = FND_GLOBAL.user_name) THEN
               l_status := '1';
         ELSE
               l_status := '2';
               EXIT;
         END IF;
       END LOOP;
    END IF;
RETURN l_status;
EXCEPTION
WHEN MODEL_ID_IS_NULL THEN
   l_status := CZ_UTILS.GET_TEXT('CZ_SEC_MODEL_ID_NULL');
   RETURN l_status;
WHEN OTHERS THEN
  l_status := SQLERRM;
  RETURN l_status;
END are_models_locked;

------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION are_models_locked (p_model_id IN NUMBER, p_checkout_user IN VARCHAR2)
RETURN VARCHAR2
IS
l_models  number_type_tbl;
l_status  VARCHAR2(2000);
l_checkout_user_tbl varchar_type_tbl;

BEGIN
   l_status   := '0';
   SELECT checkout_user
   BULK
   COLLECT
   INTO   l_checkout_user_tbl
   FROM   cz_devl_projects
   WHERE  cz_devl_projects.devl_project_id IN ( SELECT component_id
                                                  FROM cz_model_ref_expls
                                                 WHERE model_id = p_model_id
                                                   AND ps_node_type = 263
                                                   AND deleted_flag = '0')

   AND    cz_devl_projects.deleted_flag = '0'
   AND    cz_devl_projects.checkout_user IS NOT NULL;

   IF (l_checkout_user_tbl.COUNT > 0) THEN
      FOR I IN l_checkout_user_tbl.FIRST..l_checkout_user_tbl.LAST
      LOOP
          IF (l_checkout_user_tbl(i) = FND_GLOBAL.user_name) THEN
               l_status := '1';
          ELSIF (l_checkout_user_tbl(i) <> FND_GLOBAL.user_name) THEN
               l_status := '2';
               EXIT;
         END IF;
      END LOOP;
    END IF;
RETURN l_status;
EXCEPTION
WHEN OTHERS THEN
  l_status := SQLERRM;
  RETURN l_status;
END are_models_locked;

------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION check_devl_project(p_entity_id IN NUMBER,
                            p_entity IN VARCHAR2)
RETURN VARCHAR2
IS
l_checkout_user VARCHAR2(40);
l_proj_id       NUMBER := 0 ;
l_status          VARCHAR2(1) := '0';
BEGIN
  IF (p_entity = cz_security_pvt.MODEL) THEN
     l_proj_id := p_entity_id;
  ELSIF (p_entity = cz_security_pvt.UI) THEN
     SELECT devl_project_id INTO l_proj_id
     FROM   cz_ui_defs
     WHERE  ui_def_id = p_entity_id
      AND   deleted_flag = '0';
  ELSIF (p_entity = cz_security_pvt.RULEFOLDER) THEN
    begin
     SELECT devl_project_id INTO l_proj_id
     FROM   cz_rule_folders
     WHERE  rule_folder_id = p_entity_id
      AND   object_type = 'RFL'
      AND   deleted_flag = '0';
    exception
    when no_data_found then
       null;
    end;
  END IF;

  begin
    SELECT checkout_user INTO l_checkout_user
    FROM  cz_devl_projects
    WHERE cz_devl_projects.devl_project_id = l_proj_id;
  exception
  when no_data_found then
    null;
  end;

  IF ( (l_checkout_user IS NOT NULL) AND (l_checkout_user = FND_GLOBAL.user_name) ) THEN
      RETURN '3';
  ELSIF ( (l_checkout_user IS NOT NULL) AND (l_checkout_user <> FND_GLOBAL.user_name) ) THEN
      RETURN '4';
  ELSE
      RETURN '0';
  END IF;
EXCEPTION
WHEN OTHERS tHEN
   RETURN l_status;
END check_devl_project;

------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION check_devl_project(p_checkout_user IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF ( (p_checkout_user IS NOT NULL) AND (p_checkout_user = FND_GLOBAL.user_name) ) THEN
      RETURN '3';
  ELSIF ( (p_checkout_user IS NOT NULL) AND (p_checkout_user <> FND_GLOBAL.user_name) ) THEN
      RETURN '4';
  ELSE
      RETURN '0';
  END IF;
EXCEPTION
WHEN OTHERS tHEN
   RETURN '0';
END check_devl_project;

------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION lock_model_structure (p_model_id IN NUMBER)
RETURN VARCHAR2
IS
l_ret_status    VARCHAR2(1);
l_checkout_user VARCHAR2(40);
l_event_note    VARCHAR2(2000);

BEGIN
  l_ret_status := 'T';
  BEGIN
     SELECT checkout_user
     INTO   l_checkout_user
     FROM   cz_ps_nodes
     WHERE  ps_node_id = p_model_id;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      l_checkout_user := NULL;
  END;

  IF (l_checkout_user IS NULL) THEN
        UPDATE cz_ps_nodes
        SET    checkout_user = FND_GLOBAL.user_name
        WHERE  ps_node_id = p_model_id;

       l_event_note := CZ_UTILS.GET_TEXT('CZ_SEC_LOCK_MODEL_STRUCTURE',
                                        'LOCKEDBY',FND_GLOBAL.user_name,'LOCKDATE',
                                        to_char(sysdate,'mm-dd-yyyy hh24:mi:ss'));
       log_lock_history (2,p_model_id,'LOCK_STRUCTURE',l_event_note);
  ELSIF (l_checkout_user <> FND_GLOBAL.user_name) THEN
        l_ret_status := 'F';
  END IF;
  RETURN  l_ret_status;
EXCEPTION
WHEN OTHERS THEN
  RETURN 'F';
END lock_model_structure ;
------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION is_model_structure_locked (p_model_id IN NUMBER)
RETURN VARCHAR2
IS

l_status  VARCHAR2(2000) := '0';
l_checkout_user VARCHAR2(40) := '';
MODEL_ID_IS_NULL EXCEPTION;

BEGIN
   l_status   := '0';
   IF (p_model_id IS NULL) THEN
      RAISE MODEL_ID_IS_NULL;
   END IF;

   l_status  := check_devl_project(p_model_id,cz_security_pvt.MODEL);
   IF (l_status IN ('3','4')) THEN
      RAISE MODEL_LOCKED;
   END IF;

   SELECT checkout_user
   INTO   l_checkout_user
   FROM   cz_ps_nodes
   WHERE  cz_ps_nodes.ps_node_id = p_model_id
   AND    cz_ps_nodes.deleted_flag = '0';

   IF (l_checkout_user IS NULL) THEN
         l_status := '0';
   ELSIF (l_checkout_user = FND_GLOBAL.user_name) THEN
         l_status := '1';
   ELSE
         l_status := '2';
   END IF;
   RETURN l_status;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   l_status := CZ_UTILS.GET_TEXT('CZ_SEC_NO_MODEL_FOUND', 'MODELID', p_model_id);
   RETURN l_status;
WHEN MODEL_LOCKED THEN
      RETURN l_status;
WHEN MODEL_ID_IS_NULL THEN
   l_status := CZ_UTILS.GET_TEXT('CZ_SEC_MODEL_ID_NULL');
   RETURN l_status;
WHEN OTHERS THEN
  l_status := SQLERRM;
  RETURN l_status;
END is_model_structure_locked;

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION unlock_model_structure (p_model_id IN NUMBER)
RETURN VARCHAR2
IS
l_ret_status    VARCHAR2(1) := 'T';
l_checkout_user VARCHAR2(40);
l_event_note    VARCHAR2(2000);
BEGIN
  l_ret_status :=  check_devl_project(p_model_id,cz_security_pvt.MODEL);
  IF (l_ret_status <> '0')  THEN
      RETURN 'F';
  ELSE
      l_ret_status := 'T';
  END IF;

  BEGIN
     SELECT checkout_user
     INTO   l_checkout_user
     FROM   cz_ps_nodes
     WHERE  ps_node_id = p_model_id;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      l_checkout_user := NULL;
  END;

  IF ( (l_checkout_user IS NOT NULL) AND (l_checkout_user = FND_GLOBAL.user_name) )  THEN
        UPDATE cz_ps_nodes
        SET   checkout_user = NULL
        WHERE  ps_node_id = p_model_id;

        l_event_note := CZ_UTILS.GET_TEXT('CZ_SEC_UNLOCK_MODEL_STRUCTURE',
                'UNLOCKEDBY',FND_GLOBAL.user_name,'UNLOCKDATE',to_char(sysdate,'mm-dd-yyyy hh24:mi:ss'));
         log_lock_history (2,p_model_id,'UNLOCK_STRUCTURE',l_event_note);
  ELSIF ( (l_checkout_user IS NOT NULL) AND (l_checkout_user <> FND_GLOBAL.user_name) )THEN
        l_ret_status := 'F';
  END IF;
  RETURN  l_ret_status;
EXCEPTION
WHEN OTHERS THEN
  RETURN 'F';
END unlock_model_structure ;

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION is_root_ui_locked (p_ui_def_id IN NUMBER)
RETURN VARCHAR2
IS
l_ui_bl             number_type_tbl;
l_status            VARCHAR2(2000);
rec_count           NUMBER := 0;
l_checkout_user     VARCHAR2(40) := '';
l_checkout_user_tbl varchar_type_tbl;
UI_DEF_ID_IS_NULL   EXCEPTION;

BEGIN
  l_status   := '0';
  IF (p_ui_def_id IS NULL) THEN
      RAISE UI_DEF_ID_IS_NULL;
  END IF;

  l_status  := check_devl_project(p_ui_def_id,cz_security_pvt.UI);
  IF ( (l_status = '3') OR (l_status = '4') )   THEN
      RAISE MODEL_LOCKED;
  END IF;

  get_already_locked_entities(cz_security_pvt.UI,p_ui_def_id,l_ui_bl,l_checkout_user_tbl);
  IF (l_checkout_user_tbl.COUNT > 0) THEN
      FOR uiId IN l_checkout_user_tbl.FIRST..l_checkout_user_tbl.LAST
      LOOP
         IF ( (l_checkout_user IS NOT NULL) AND (l_checkout_user_tbl(uiId) <> FND_GLOBAL.user_name)) THEN
              l_status := CZ_UTILS.GET_TEXT('CZ_SEC_ENTITY_IS_LOCKED','ObjectId', cz_security_pvt.UI,
                                    'Id',l_ui_bl(uiId),'User', l_checkout_user_tbl(uiId) );
             EXIT;
         END IF;
       END LOOP;
  END IF;
RETURN l_status;
EXCEPTION
WHEN UI_DEF_ID_IS_NULL THEN
   l_status := CZ_UTILS.GET_TEXT('CZ_SEC_UI_DEF_ID_NULL');
   RETURN l_status;
WHEN MODEL_LOCKED THEN
   RETURN l_status;
WHEN OTHERS THEN
  l_status := SQLERRM;
  RETURN l_status;
END is_root_ui_locked ;

------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION is_ui_def_locked (p_ui_def_id IN NUMBER)
RETURN VARCHAR2
IS

l_status             VARCHAR2(2000);
l_checkout_user   VARCHAR2(40) := '';
UI_DEF_ID_IS_NULL EXCEPTION;

BEGIN
   l_status   := '0';
   IF (p_ui_def_id IS NULL) THEN
      RAISE UI_DEF_ID_IS_NULL;
   END IF;

  l_status  := check_devl_project(p_ui_def_id,cz_security_pvt.UI);
  IF ( (l_status = '3') OR (l_status = '4') ) THEN
      RAISE MODEL_LOCKED;
  END IF;

   SELECT checkout_user
   INTO   l_checkout_user
   FROM   cz_ui_defs
   WHERE  cz_ui_defs.ui_def_id = p_ui_def_id
   AND    cz_ui_defs.deleted_flag = '0';

   IF (l_checkout_user IS NULL) THEN
         l_status := '0';
   ELSIF (l_checkout_user = FND_GLOBAL.user_name) THEN
         l_status := '1';
   ELSE
         l_status := '2';
   END IF;
   RETURN l_status;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   l_status := CZ_UTILS.GET_TEXT('CZ_SEC_NO_MODEL_FOUND', 'UIDEFID', p_ui_def_id);
   RETURN l_status;
WHEN MODEL_LOCKED THEN
   RETURN l_status;
WHEN UI_DEF_ID_IS_NULL THEN
   l_status := CZ_UTILS.GET_TEXT('CZ_SEC_UI_DEF_ID_NULL');
   RETURN l_status;
WHEN OTHERS THEN
  l_status := SQLERRM;
  RETURN l_status;
END is_ui_def_locked ;

----->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION is_ui_def_locked (p_ui_def_id IN NUMBER,
                           p_checkout_user IN VARCHAR2)
RETURN VARCHAR2
IS

l_status              VARCHAR2(2000);
l_checkout_user   VARCHAR2(40) := '';

BEGIN
   l_status   := '0';
   IF (l_checkout_user = FND_GLOBAL.user_name) THEN
         l_status := '1';
   ELSIF (l_checkout_user <> FND_GLOBAL.user_name) THEN
         l_status := '2';
   END IF;
   RETURN l_status;
EXCEPTION
WHEN OTHERS THEN
  l_status := SQLERRM;
  RETURN l_status;
END is_ui_def_locked ;

----->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION lock_ui_def (p_ui_def_id IN NUMBER)
RETURN VARCHAR2
IS
l_ret_status VARCHAR2(1);
l_checkout_user VARCHAR2(40);
l_event_note VARCHAR2(2000);
BEGIN
  l_ret_status := 'T';
  BEGIN
     SELECT checkout_user
     INTO   l_checkout_user
     FROM   cz_ui_defs
     WHERE  ui_def_id = p_ui_def_id ;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      l_checkout_user := NULL;
  END;

  IF (l_checkout_user IS NULL) THEN
        UPDATE cz_ui_defs
        SET    checkout_user = FND_GLOBAL.user_name
        WHERE  ui_def_id = p_ui_def_id ;
        l_event_note := CZ_UTILS.GET_TEXT('CZ_SEC_LOCK_UI_EVENT',
                'LOCKEDBY',FND_GLOBAL.user_name,'LOCKDATE',to_char(sysdate,'mm-dd-yyyy hh24:mi:ss'));
         log_lock_history (3,p_ui_def_id,'LOCK_UI',l_event_note);
  ELSIF (l_checkout_user <> FND_GLOBAL.user_name) THEN
        l_ret_status := 'F';
  END IF;
  RETURN  l_ret_status;
EXCEPTION
WHEN OTHERS THEN
  RETURN 'F';
END lock_ui_def ;

------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION unlock_ui_def (p_ui_def_id IN NUMBER)
RETURN VARCHAR2
IS
l_ret_status VARCHAR2(1) := 'T';
l_checkout_user VARCHAR2(40);
l_event_note VARCHAR2(2000);
BEGIN
  l_ret_status :=  check_devl_project(p_ui_def_id,cz_security_pvt.UI);
  IF (l_ret_status <> '0')  THEN
      RETURN 'F';
  ELSE
      l_ret_status := 'T';
  END IF;

  BEGIN
     SELECT checkout_user
     INTO   l_checkout_user
     FROM   cz_ui_defs
     WHERE  ui_def_id = p_ui_def_id ;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      l_checkout_user := NULL;
  END;

  IF ( (l_checkout_user IS NOT NULL) AND (l_checkout_user = FND_GLOBAL.user_name) )  THEN
        UPDATE cz_ui_defs
        SET   checkout_user = NULL
        WHERE  ui_def_id = p_ui_def_id ;
        l_event_note := CZ_UTILS.GET_TEXT('CZ_SEC_UNLOCK_UI_EVENT',
                'UNLOCKEDBY',FND_GLOBAL.user_name,'UNLOCKDATE',to_char(sysdate,'mm-dd-yyyy hh24:mi:ss'));
         log_lock_history (3,p_ui_def_id,'UNLOCK_UI',l_event_note);
  ELSIF ( (l_checkout_user IS NOT NULL) AND (l_checkout_user <> FND_GLOBAL.user_name) )THEN
        l_ret_status := 'F';
  END IF;
  RETURN  l_ret_status;
EXCEPTION
WHEN OTHERS THEN
  RETURN 'F';
END unlock_ui_def ;

---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION is_root_rulefolder_locked (p_model_id IN NUMBER)
RETURN VARCHAR2
IS
l_rule_tbl          number_type_tbl;
l_status            VARCHAR2(2000);
rec_count           NUMBER := 0;
l_checkout_user     VARCHAR2(40) := '';
l_checkout_user_tbl varchar_type_tbl;
l_user_name              VARCHAR2(40) := FND_GLOBAL.user_name;
MODELID_IS_NULL   EXCEPTION;

BEGIN
  l_status   := '0';
  IF (p_model_id IS NULL) THEN
      RAISE MODELID_IS_NULL;
  END IF;

  l_status  := check_devl_project(p_model_id,cz_security_pvt.RULEFOLDER);
  IF ( (l_status = '3') OR (l_status = '4') ) THEN
      RAISE MODEL_LOCKED;
  END IF;

  get_already_locked_entities(cz_security_pvt.RULEFOLDER,p_model_id,l_rule_tbl,l_checkout_user_tbl);
  IF (l_checkout_user_tbl.COUNT > 0) THEN
      FOR FldId IN l_checkout_user_tbl.FIRST..l_checkout_user_tbl.LAST
      LOOP
         l_checkout_user := l_checkout_user_tbl(FldId);
            IF (l_checkout_user IS NULL) THEN
               l_status := '0';
            ELSIF (l_checkout_user = FND_GLOBAL.user_name) THEN
               l_status := '1';
            ELSE
              l_status := '2';
            EXIT;
            END IF;
       END LOOP;
  END IF;
RETURN l_status;
EXCEPTION
WHEN MODELID_IS_NULL THEN
   l_status := CZ_UTILS.GET_TEXT('CZ_SEC_MODELID_IS_NULL');
   RETURN l_status;
WHEN MODEL_LOCKED THEN
   RETURN l_status;
WHEN OTHERS THEN
  l_status := SQLERRM;
  RETURN l_status;
END is_root_rulefolder_locked ;

------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION is_root_rulefolder_locked (p_model_id IN NUMBER, p_checkout_user IN VARCHAR2)
RETURN VARCHAR2
IS
l_rule_tbl          number_type_tbl;
l_status            VARCHAR2(2000);
rec_count           NUMBER := 0;
l_checkout_user     VARCHAR2(40) := '';
l_checkout_user_tbl varchar_type_tbl;
l_user_name              VARCHAR2(40) := FND_GLOBAL.user_name;

BEGIN
  l_status   := '0';
  SELECT rule_folder_id,checkout_user
  BULK
  COLLECT
  INTO   l_rule_tbl,l_checkout_user_tbl
  FROM   cz_rule_folders
  WHERE  cz_rule_folders.object_type = 'RFL'
  AND    cz_rule_folders.deleted_flag = '0'
  AND    cz_rule_folders.devl_project_id = p_model_id
  AND    cz_rule_folders.checkout_user IS NOT NULL;

  IF (l_checkout_user_tbl.COUNT > 0) THEN
      FOR FldId IN l_checkout_user_tbl.FIRST..l_checkout_user_tbl.LAST
      LOOP
         l_checkout_user := l_checkout_user_tbl(FldId);
            IF (l_checkout_user = FND_GLOBAL.user_name) THEN
               l_status := '1';
            ELSIF (l_checkout_user <> FND_GLOBAL.user_name) THEN
              l_status := '2';
            EXIT;
            END IF;
       END LOOP;
  END IF;
RETURN l_status;
EXCEPTION
WHEN OTHERS THEN
  l_status := SQLERRM;
  RETURN l_status;
END is_root_rulefolder_locked ;

------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION is_rulefolder_lockable (p_rule_folder_id IN NUMBER)
RETURN VARCHAR2
IS

l_status                   VARCHAR2(2000);
l_checkout_user        VARCHAR2(40) := '';
l_parent_user          VARCHAR2(40) := '';
l_user_name                 VARCHAR2(40) := FND_GLOBAL.user_name;
l_parent_rule_folder_id NUMBER := 0;
l_fld_user             VARCHAR2(40) := '';

RULE_FOLDER_ID_IS_NULL EXCEPTION;
CURSOR checkout_user_cur IS
       select checkout_user
       FROM   cz_rule_folders
       where deleted_flag = '0'
       and object_type = 'RFL'
       and checkout_user is not null
       start with  rule_folder_id = p_rule_folder_id
      connect by prior parent_rule_folder_id = rule_folder_id;

BEGIN
   l_status   := 'Y';
   IF (p_rule_folder_id IS NULL) THEN
      RAISE RULE_FOLDER_ID_IS_NULL;
   END IF;

  l_status  := check_devl_project(p_rule_folder_id,cz_security_pvt.RULEFOLDER);
  IF ( (l_status = '3') OR (l_status = '4') ) THEN
      l_status := 'N';
      RAISE MODEL_LOCKED;
  ELSE
      l_status := 'Y';
  END IF;

  BEGIN
     SELECT checkout_user INTO l_fld_user
     FROM   cz_rule_folders
     WHERE  cz_rule_folders.rule_folder_id = p_rule_folder_id
      AND   cz_rule_folders.object_type = 'RFL';
  EXCEPTION
  WHEN OTHERS THEN
    l_fld_user := NULL;
  END;

  IF ( (l_fld_user IS NOT NULL) AND (l_fld_user = FND_GLOBAL.user_name) ) THEN
      RETURN 'Y';
  ELSIF ( (l_fld_user IS NOT NULL) AND (l_fld_user <> FND_GLOBAL.user_name) ) THEN
      RETURN 'N';
  END IF;

  BEGIN
      SELECT checkout_user,parent_rule_folder_id
      INTO   l_parent_user,l_parent_rule_folder_id
      FROM   cz_rule_folders
      WHERE  cz_rule_folders.rule_folder_id = (SELECT parent_rule_folder_id
                                               FROM   cz_rule_folders
                                               WHERE  rule_folder_id = p_rule_folder_id
                                               AND    object_type = 'RFL'
                                               AND    deleted_flag = '0')
      AND   cz_rule_folders.object_type = 'RFL';
  EXCEPTION
  WHEN OTHERS THEN
      l_parent_rule_folder_id := 0;
      l_parent_user := NULL;
  END;

  IF (l_parent_user IS NOT NULL) THEN ----AND (l_parent_user <> FND_GLOBAL.user_name) THEN
        l_status := 'N';
        RAISE MODEL_LOCKED;
  END IF;

 IF (l_parent_rule_folder_id > 0) THEN

    OPEN checkout_user_cur;
    LOOP
      FETCH checkout_user_cur INTO l_checkout_user;
      EXIT WHEN checkout_user_cur%NOTFOUND;
           IF ( (l_checkout_user IS NOT NULL) ) THEN
            l_status := 'N';
            EXIT;
      END IF;
     END LOOP;
     CLOSE checkout_user_cur;
  END IF;
  RETURN l_status;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   l_status := CZ_UTILS.GET_TEXT('CZ_SEC_NO_MODEL_FOUND','RULEFOLDERID',p_rule_folder_id );
   RETURN l_status;
WHEN MODEL_LOCKED THEN
   RETURN l_status;
WHEN RULE_FOLDER_ID_IS_NULL THEN
   l_status := CZ_UTILS.GET_TEXT('CZ_SEC_RULE_FOLDER_ID_NULL');
   RETURN l_status;
WHEN OTHERS THEN
  l_status := SQLERRM;
  RETURN l_status;
END is_rulefolder_lockable;

-------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION is_rulefolder_locked (p_rule_folder_id IN NUMBER)
RETURN VARCHAR2
IS

l_status                   VARCHAR2(2000);
l_checkout_user        VARCHAR2(40) := '';
l_user_name                 VARCHAR2(40) := FND_GLOBAL.user_name;
l_is_locakable         VARCHAR2(2000) := 'N';
RULE_FOLDER_ID_IS_NULL EXCEPTION;

BEGIN
   l_status   := '0';
   IF (p_rule_folder_id IS NULL) THEN
      RAISE RULE_FOLDER_ID_IS_NULL;
   END IF;

  l_status  := check_devl_project(p_rule_folder_id,cz_security_pvt.RULEFOLDER);
  IF (l_status IN ('3','4')) THEN
      RAISE MODEL_LOCKED;
  END IF;

   l_is_locakable := is_rulefolder_lockable(p_rule_folder_id);
   IF (l_is_locakable <> 'Y') THEN
      l_status := '2';
      RAISE MODEL_LOCKED;
   END IF;

   BEGIN
      SELECT checkout_user
      INTO   l_checkout_user
      FROM   cz_rule_folders
      WHERE  cz_rule_folders.rule_folder_id = p_rule_folder_id
      AND    cz_rule_folders.object_type = 'RFL'
      AND    cz_rule_folders.deleted_flag = '0';
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
       l_checkout_user := NULL;
   END;

   IF (l_checkout_user IS NULL) THEN
         l_status := '0';
   ELSIF (l_checkout_user = FND_GLOBAL.user_name) THEN
         l_status := '1';
   ELSE
         l_status := '2';
   END IF;
  RETURN l_status;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   l_status := CZ_UTILS.GET_TEXT('CZ_SEC_NO_MODEL_FOUND','RULEFOLDERID',p_rule_folder_id );
   RETURN l_status;
WHEN MODEL_LOCKED THEN
   RETURN l_status;
WHEN RULE_FOLDER_ID_IS_NULL THEN
   l_status := CZ_UTILS.GET_TEXT('CZ_SEC_RULE_FOLDER_ID_NULL');
   RETURN l_status;
WHEN OTHERS THEN
  l_status := SQLERRM;
  RETURN l_status;
END is_rulefolder_locked;

------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION lock_rulefolder(p_rule_folder_id IN NUMBER)
RETURN VARCHAR2
IS
l_ret_status    VARCHAR2(1);
l_rule_fld_tbl  number_type_tbl;
l_checkout_user_tbl varchar_type_tbl;
rec_count          NUMBER := 0;
l_checkout_user VARCHAR2(40) := '';
l_event_note    VARCHAR2(2000);
BEGIN
  l_ret_status := 'T';
  BEGIN
     SELECT checkout_user
     INTO   l_checkout_user
     FROM   cz_rule_folders
     WHERE  rule_folder_id = p_rule_folder_id
      AND   deleted_flag = '0'
      AND   object_type = 'RFL';
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      l_checkout_user := NULL;
  END;

  IF (l_checkout_user IS NULL) THEN
    BEGIN
       select rule_folder_id,checkout_user
       BULK
       COLLECT
       INTO   l_rule_fld_tbl,l_checkout_user_tbl
       FROM   cz_rule_folders
       where deleted_flag = '0'
       and object_type = 'RFL'
       start with  rule_folder_id = p_rule_folder_id
      connect by prior rule_folder_id = parent_rule_folder_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
       NULL;
    END;

    IF (l_checkout_user_tbl.COUNT > 0) THEN
       FOR FldId IN l_checkout_user_tbl.FIRST..l_checkout_user_tbl.LAST
       LOOP
         l_checkout_user := l_checkout_user_tbl(FldId);
         IF ( (l_checkout_user IS NOT NULL) AND (l_checkout_user <> FND_GLOBAL.user_name) ) THEN
              RETURN 'F';
            END IF;
       END LOOP;
    END IF;

    IF (l_rule_fld_tbl.COUNT > 0) THEN
      FOR I IN l_rule_fld_tbl.FIRST..l_rule_fld_tbl.LAST
      LOOP
           UPDATE cz_rule_folders
           SET    checkout_user = FND_GLOBAL.user_name
               WHERE  rule_folder_id = l_rule_fld_tbl(i)
            AND  object_type = 'RFL';
               l_event_note := CZ_UTILS.GET_TEXT('CZ_SEC_LOCK_RFL_EVENT',
                'LOCKEDBY',FND_GLOBAL.user_name,'LOCKDATE',to_char(sysdate,'mm-dd-yyyy hh24:mi:ss'));
            log_lock_history (4,p_rule_folder_id,'LOCK_RULEFOLDER',l_event_note);
      END LOOP;
    END IF;
  ELSIF (l_checkout_user <> FND_GLOBAL.user_name) THEN
        l_ret_status := 'F';
  END IF;
  RETURN  l_ret_status;
EXCEPTION
WHEN OTHERS THEN
  RETURN 'F';
END lock_rulefolder;

------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION unlock_rulefolder(p_rule_folder_id IN NUMBER)
RETURN VARCHAR2
IS
l_ret_status     VARCHAR2(1) := 'T';
l_checkout_user  VARCHAR2(40);
l_rule_fld_tbl   number_type_tbl;
l_event_note     VARCHAR2(2000);
BEGIN
  l_ret_status :=  check_devl_project(p_rule_folder_id,cz_security_pvt.RULEFOLDER);
  IF (l_ret_status <> '0')  THEN
      RETURN 'F';
  ELSE
      l_ret_status := 'T';
  END IF;

  BEGIN
     SELECT checkout_user
     INTO   l_checkout_user
     FROM   cz_rule_folders
     WHERE  rule_folder_id = p_rule_folder_id
     AND    object_type = 'RFL';
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      l_checkout_user := NULL;
  END;

  IF ( (l_checkout_user IS NOT NULL) AND (l_checkout_user = FND_GLOBAL.user_name) )  THEN
    BEGIN
       select rule_folder_id
       BULK
       COLLECT
       INTO   l_rule_fld_tbl
       FROM   cz_rule_folders
       where deleted_flag = '0'
       and object_type = 'RFL'
       start with  rule_folder_id = p_rule_folder_id
      connect by prior rule_folder_id = parent_rule_folder_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
       NULL;
    END;

    IF (l_rule_fld_tbl.COUNT > 0) THEN
      FOR I IN l_rule_fld_tbl.FIRST..l_rule_fld_tbl.LAST
      LOOP
          UPDATE cz_rule_folders
          SET    checkout_user = NULL
          WHERE  rule_folder_id = l_rule_fld_tbl(i)
            AND  object_type = 'RFL';
                l_event_note := CZ_UTILS.GET_TEXT('CZ_SEC_UNLOCK_RFL_EVENT',
                'UNLOCKEDBY',FND_GLOBAL.user_name,'UNLOCKDATE',to_char(sysdate,'mm-dd-yyyy hh24:mi:ss'));
            log_lock_history (4,p_rule_folder_id,'UNLOCK_RULEFOLDER',l_event_note);
      END LOOP;
    END IF;
  ELSIF ( (l_checkout_user IS NOT NULL) AND (l_checkout_user <> FND_GLOBAL.user_name) )THEN
        l_ret_status := 'F';
  END IF;
  RETURN  l_ret_status;
EXCEPTION
WHEN OTHERS THEN
  RETURN 'F';
END unlock_rulefolder;

---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION is_model_locked (p_model_id IN NUMBER)
RETURN VARCHAR2
IS
l_ui_tbl             number_type_tbl;
l_are_models_locked  VARCHAR2(2000) := '0';
l_are_uis_locked     VARCHAR2(2000) := '0';
l_are_rulefld_locked VARCHAR2(2000) := '0';
l_is_structure_locked VARCHAR2(2000) := '0';
l_checkout_user      VARCHAR2(40);
BEGIN
   ----check devl proj
  SELECT checkout_user
  INTO   l_checkout_user
  FROM   cz_devl_projects
  WHERE  cz_devl_projects.devl_project_id = p_model_id;

  IF ( (l_checkout_user IS NOT NULL) AND (l_checkout_user = FND_GLOBAL.user_name) ) THEN
       RETURN '1';
  ELSIF ((l_checkout_user IS NOT NULL) AND (l_checkout_user <> FND_GLOBAL.user_name) ) THEN
       RETURN '2';
  END IF;

   ---check model structure
   l_are_models_locked   := are_models_locked (p_model_id);
   l_is_structure_locked := is_model_structure_locked (p_model_id);
   IF ( (l_is_structure_locked = '2') OR (l_is_structure_locked = '4') ) THEN
       RETURN l_is_structure_locked ;
   END IF;

   BEGIN
      SELECT ui_def_id
      BULK
      COLLECT
      INTO   l_ui_tbl
      FROM   cz_ui_defs
      WHERE  cz_ui_defs.devl_project_id = p_model_id
      AND    cz_ui_defs.deleted_flag = '0'
      AND    cz_ui_defs.checkout_user IS NOT NULL;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;
   END;

   ----check uis
   IF (l_ui_tbl.COUNT > 0) THEN
      FOR ui IN l_ui_tbl.FIRST..l_ui_tbl.LAST
      LOOP
         l_are_uis_locked := is_ui_def_locked (l_ui_tbl(ui));
         IF (l_are_uis_locked NOT IN ('0','1') ) THEN
            EXIT;
         END IF;
      END LOOP;
   END IF;

   ---check rulefolders
   l_are_rulefld_locked := is_root_rulefolder_locked (p_model_id);
   IF ( (l_are_models_locked = '0') AND (l_are_rulefld_locked = '0')
      AND (l_are_uis_locked = '0') AND (l_is_structure_locked = '0') ) THEN
      RETURN '0';
   ELSE
      RETURN '3';
   END IF;
EXCEPTION
WHEN OTHERS THEN
    RETURN 'U';
END is_model_locked;

---------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION is_model_locked (p_model_id IN NUMBER, p_checkout_user IN VARCHAR2, p_username IN VARCHAR2)
RETURN VARCHAR2
IS
l_ui_tbl             number_type_tbl;
l_are_models_locked  VARCHAR2(2000) := '0';
l_are_uis_locked     VARCHAR2(2000) := '0';
l_are_rulefld_locked VARCHAR2(2000) := '0';
l_checkout_user      VARCHAR2(40);
l_ui_checkout_tbl    varchar_type_tbl;


BEGIN
  IF ( (p_checkout_user IS NOT NULL) AND (p_checkout_user = FND_GLOBAL.user_name) ) THEN
       RETURN '1';
  ELSIF ((p_checkout_user IS NOT NULL) AND (p_checkout_user <> FND_GLOBAL.user_name) ) THEN
       RETURN '2';
  END IF;

  ---check model structure
  l_are_models_locked := are_models_locked (p_model_id,p_checkout_user);

   BEGIN
      SELECT ui_def_id,checkout_user
      BULK
      COLLECT
      INTO   l_ui_tbl,l_ui_checkout_tbl
      FROM   cz_ui_defs
      WHERE  cz_ui_defs.devl_project_id = p_model_id
      AND    cz_ui_defs.deleted_flag = '0'
      AND    cz_ui_defs.checkout_user IS NOT NULL;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;
   END;

   ----check uis
   IF (l_ui_tbl.COUNT > 0) THEN
      FOR ui IN l_ui_tbl.FIRST..l_ui_tbl.LAST
      LOOP
         l_are_uis_locked := is_ui_def_locked (l_ui_tbl(ui),l_ui_checkout_tbl(ui));
         IF (l_are_uis_locked NOT IN ('0','1') ) THEN
            EXIT;
         END IF;
      END LOOP;
   END IF;

   ---check rulefolders
   l_are_rulefld_locked := is_root_rulefolder_locked (p_model_id,p_checkout_user);
   IF ( (l_are_models_locked = '0') AND (l_are_rulefld_locked = '0')
      AND (l_are_uis_locked = '0') ) THEN
      RETURN '0';
   ELSE
      RETURN '3';
   END IF;
EXCEPTION
WHEN OTHERS THEN
    RETURN 'U';
END is_model_locked;

----------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-----check lock on a entity
PROCEDURE is_model_locked (p_devl_project_id IN VARCHAR2,
                              x_return_status         OUT NOCOPY VARCHAR2,
                          x_msg_count         OUT NOCOPY NUMBER,
                          x_msg_data         OUT NOCOPY VARCHAR2)
IS

l_checkout_user      VARCHAR2(40) := NULL;
l_deleted_flag      VARCHAR2(1)  := '0';
MODEL_DELETED     EXCEPTION;
MODEL_IS_LOCKED   EXCEPTION;

BEGIN
    x_return_status := 'F';
    x_msg_count := 0;
    x_msg_data := '';
    SELECT checkout_user,deleted_flag INTO l_checkout_user,l_deleted_flag
    FROM   cz_devl_projects
    WHERE  cz_devl_projects.devl_project_id = p_devl_project_id;

    IF (l_deleted_flag = '1') THEN
        RAISE MODEL_DELETED;
    END IF;

    IF (l_checkout_user IS NOT NULL) THEN
      RAISE MODEL_IS_LOCKED;
    END IF;
EXCEPTION
WHEN MODEL_DELETED THEN
   x_return_status := 'T';
   x_msg_count := 1;
   x_msg_data := CZ_UTILS.GET_TEXT('CZ_MODEL_DOES_NOT_EXIST', 'PROJID', p_devl_project_id);
WHEN MODEL_IS_LOCKED THEN
   x_return_status := 'T';
   x_msg_count := 1;
   x_msg_data := CZ_UTILS.GET_TEXT('CZ_MODEL_IS_LOCKED', 'USER', l_checkout_user);
WHEN OTHERS THEN
   x_return_status := 'T';
   x_msg_count := 1;
   x_msg_data := CZ_UTILS.GET_TEXT('CZ_SEC_FATAL_ERR', 'ERROR', SQLERRM);
END is_model_locked ;

------------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION is_model_lockable (p_model_id IN NUMBER)
RETURN VARCHAR2
IS
l_ui_tbl             number_type_tbl;
l_are_models_locked  VARCHAR2(2000) := '0';
l_are_uis_locked     VARCHAR2(2000) := '0';
l_are_rulefld_locked VARCHAR2(2000) := '0';
l_checkout_user      VARCHAR2(40);

BEGIN
   ----check devl proj
  SELECT checkout_user
  INTO   l_checkout_user
  FROM   cz_devl_projects
  WHERE  cz_devl_projects.devl_project_id = p_model_id;

  IF ( (l_checkout_user IS NOT NULL) AND (l_checkout_user = FND_GLOBAL.user_name) ) THEN
       RETURN 'Y';
  ELSIF ((l_checkout_user IS NOT NULL) AND (l_checkout_user <> FND_GLOBAL.user_name) ) THEN
       RETURN 'N';
  END IF;

   ---check model structure
   l_are_models_locked := are_models_locked (p_model_id);

   BEGIN
      SELECT ui_def_id
      BULK
      COLLECT
      INTO   l_ui_tbl
      FROM   cz_ui_defs
      WHERE  cz_ui_defs.devl_project_id = p_model_id
      AND    cz_ui_defs.deleted_flag = '0';
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;
   END;

   ----check uis
   IF (l_ui_tbl.COUNT > 0) THEN
      FOR ui IN l_ui_tbl.FIRST..l_ui_tbl.LAST
      LOOP
         l_are_uis_locked := is_ui_def_locked (l_ui_tbl(ui));
         IF (l_are_uis_locked NOT IN ('0','1') ) THEN
            EXIT;
         END IF;
      END LOOP;
   END IF;

   ---check rulefolders
   l_are_rulefld_locked := is_root_rulefolder_locked (p_model_id);
   IF ( (l_are_models_locked = '0') AND (l_are_rulefld_locked = '0')
      AND (l_are_uis_locked = '0') ) THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;
EXCEPTION
WHEN OTHERS THEN
    RETURN 'U';
END is_model_lockable;

------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION is_model_editable (p_model_id IN NUMBER)
RETURN VARCHAR2
IS
l_has_priv_status VARCHAR2(1) := 'F';
l_is_lockable     VARCHAR2(1) := 'T';
l_status VARCHAR2(1) := 'N';
l_checkout_user VARCHAR2(40);
l_profile_value  VARCHAR2(100);
BEGIN
  SELECT checkout_user
  INTO l_checkout_user
  FROM  cz_devl_projects
  WHERE devl_project_id = p_model_id
  AND   deleted_flag = '0';

  IF ( (l_checkout_user IS NOT NULL) AND (l_checkout_user <> FND_GLOBAL.user_name) ) THEN
       l_is_lockable := 'F';
  END IF;
  l_has_priv_status := has_model_privileges(p_model_id);
  IF ((l_has_priv_status = 'T') AND (l_is_lockable = 'T') ) THEN
    RETURN 'T';
  ELSE
    RETURN 'F';
  END IF;
END;

------->>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION is_model_editable (p_model_id IN NUMBER, p_checkout_user IN VARCHAR2, p_user_name IN VARCHAR2)
RETURN VARCHAR2
IS
l_has_priv_status VARCHAR2(1) := 'F';
l_is_lockable     VARCHAR2(1) := 'T';
l_status VARCHAR2(1) := 'N';
l_checkout_user VARCHAR2(40);
l_profile_value  VARCHAR2(100);
BEGIN
  IF ( (p_checkout_user IS NOT NULL) AND (p_checkout_user <> FND_GLOBAL.user_name) ) THEN
       l_is_lockable := 'F';
  END IF;
  IF ((g_has_priv_status = 'T') AND (l_is_lockable = 'T') ) THEN
    RETURN 'T';
  ELSE
    RETURN 'F';
  END IF;
END;

-------->>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION is_structure_editable (p_model_id IN NUMBER)
RETURN VARCHAR2
IS
l_has_priv_status VARCHAR2(1) := 'F';
l_is_lockable     VARCHAR2(1) := 'N';
l_status VARCHAR2(1) := 'N';
l_profile_value  VARCHAR2(100);
BEGIN
  l_has_priv_status := has_model_privileges(p_model_id);
  l_is_lockable     := is_model_structure_locked (p_model_id);
  l_profile_value   := FND_PROFILE.value(LOCK_MODELS_FOR_EDIT);

  IF (l_profile_value = 'N') THEN
        IF ((l_has_priv_status = 'T') AND (l_is_lockable = '0') ) THEN
          RETURN 'F';
      ELSIF ((l_has_priv_status = 'T') AND (l_is_lockable = '1') ) THEN
           RETURN 'T';
      ELSIF ((l_has_priv_status = 'T') AND (l_is_lockable = '3') ) THEN
          RETURN 'T';
      ELSE
          RETURN 'F';
        END IF;
  ELSIF (l_profile_value = 'Y') THEN
      IF ((l_has_priv_status = 'T') AND (l_is_lockable = '0')) THEN
          RETURN 'F';
      ELSIF ((l_has_priv_status = 'T') AND (l_is_lockable IN ('1','3'))  ) THEN
              RETURN 'T';
      ELSE
          RETURN 'F';
        END IF;
  END IF;

END is_structure_editable ;

------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION is_ui_def_editable(p_ui_def_id IN NUMBER)
RETURN VARCHAR2

IS
l_has_priv_status VARCHAR2(1) := 'F';
l_is_lockable     VARCHAR2(2000) := 'N';
l_status             VARCHAR2(1) := 'N';
l_proj_id             NUMBER;
l_profile_value  VARCHAR2(100);
BEGIN
  SELECT devl_project_id INTO l_proj_id FROM cz_ui_defs WHERE ui_def_id = p_ui_def_id ;
  l_has_priv_status := has_privileges(1.0,FND_GLOBAL.user_name,LOCK_UI_FUNC,cz_security_pvt.UI,l_proj_id);
  l_is_lockable     := is_ui_def_locked(p_ui_def_id);
  l_profile_value   := FND_PROFILE.value(LOCK_MODELS_FOR_EDIT);
  IF (l_profile_value = 'N') THEN
        IF ((l_has_priv_status = 'T') AND (l_is_lockable = '0') ) THEN
          RETURN 'F';
      ELSIF ((l_has_priv_status = 'T') AND (l_is_lockable = '1') ) THEN
           RETURN 'T';
      ELSIF ((l_has_priv_status = 'T') AND (l_is_lockable = '3') ) THEN
          RETURN 'T';
      ELSE
          RETURN 'F';
        END IF;
  ELSIF (l_profile_value = 'Y') THEN
      IF ((l_has_priv_status = 'T') AND (l_is_lockable = '0')) THEN
          RETURN 'F';
      ELSIF ((l_has_priv_status = 'T') AND (l_is_lockable IN ('1','3'))  ) THEN
              RETURN 'T';
      ELSE
          RETURN 'F';
        END IF;
  END IF;
END is_ui_def_editable;

------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION is_rulefolder_editable(p_rulefolder_id IN NUMBER)
RETURN VARCHAR2

IS
l_has_priv_status VARCHAR2(2000) := 'F';
l_is_lockable     VARCHAR2(2000) := 'N';
l_status             VARCHAR2(1) := 'N';
l_profile_value  VARCHAR2(100);
BEGIN
  l_has_priv_status := has_privileges(1.0,FND_GLOBAL.user_name,LOCK_RULEFOLDER_FUNC,
                                      cz_security_pvt.RULEFOLDER,p_rulefolder_id);
  l_is_lockable     := is_rulefolder_locked(p_rulefolder_id);
  l_profile_value   := FND_PROFILE.value(LOCK_MODELS_FOR_EDIT);

  IF (l_profile_value = 'N') THEN
        IF ((l_has_priv_status = 'T') AND (l_is_lockable = '0') ) THEN
          RETURN 'F';
      ELSIF ((l_has_priv_status = 'T') AND (l_is_lockable = '1') ) THEN
           RETURN 'T';
      ELSIF ((l_has_priv_status = 'T') AND (l_is_lockable = '3') ) THEN
          RETURN 'T';
      ELSE
          RETURN 'F';
        END IF;
  ELSIF (l_profile_value = 'Y') THEN
      IF ((l_has_priv_status = 'T') AND (l_is_lockable = '0')) THEN
          RETURN 'F';
      ELSIF ((l_has_priv_status = 'T') AND (l_is_lockable IN ('1','3'))  ) THEN
              RETURN 'T';
      ELSE
          RETURN 'F';
        END IF;
  END IF;
END is_rulefolder_editable;

-----------to be deleted
------------------to be deletd
FUNCTION is_root_model_locked (p_model_id IN NUMBER)
RETURN VARCHAR2
IS
l_ui_tbl             number_type_tbl;
l_are_models_locked  VARCHAR2(2000) := 'N';
l_are_uis_locked     VARCHAR2(2000) := 'N';
l_are_rulefld_locked VARCHAR2(2000) := 'N';

BEGIN
   ---check model structure
   l_are_models_locked := are_models_locked (p_model_id);
   BEGIN
      SELECT ui_def_id
      BULK
      COLLECT
      INTO   l_ui_tbl
      FROM   cz_ui_defs
      WHERE  cz_ui_defs.devl_project_id = p_model_id
      AND    cz_ui_defs.deleted_flag = '0';
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;
   END;

   ----check uis
   IF (l_ui_tbl.COUNT > 0) THEN
      FOR ui IN l_ui_tbl.FIRST..l_ui_tbl.LAST
      LOOP
         l_are_uis_locked := is_root_ui_locked (l_ui_tbl(ui));
         IF (l_are_uis_locked <> 'N') THEN
            EXIT;
         END IF;
      END LOOP;
    END IF;

   ---check rulefolders
   l_are_rulefld_locked := is_root_rulefolder_locked (p_model_id);
   IF ( (l_are_models_locked = 'Y') OR (l_are_rulefld_locked = 'Y')
      OR (l_are_uis_locked = 'Y') ) THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;
EXCEPTION
WHEN OTHERS THEN
    RETURN 'U';
END is_root_model_locked;

---------------
FUNCTION is_parent_rulefolder_locked (p_rule_folder_id IN NUMBER)
RETURN VARCHAR2
IS

l_status             VARCHAR2(2000);
l_checkout_user  VARCHAR2(40) := '';
RULE_FOLDER_ID_IS_NULL EXCEPTION;

BEGIN
   l_status   := 'N';
   IF (p_rule_folder_id IS NULL) THEN
      RAISE RULE_FOLDER_ID_IS_NULL;
   END IF;

   SELECT checkout_user
   INTO   l_checkout_user
   FROM   cz_rule_folders
   WHERE  cz_rule_folders.rule_folder_id = p_rule_folder_id
   AND    cz_rule_folders.object_type = 'RFL'
   AND    cz_rule_folders.deleted_flag = '0';

   IF ( (l_checkout_user IS NOT NULL) AND (l_checkout_user <> FND_GLOBAL.user_name)) THEN
      l_status := CZ_UTILS.GET_TEXT('CZ_SEC_ENTITY_IS_LOCKED','ObjectId', cz_security_pvt.RULEFOLDER,
                              'Id',p_rule_folder_id,'User', l_checkout_user);
   END IF;
   RETURN l_status;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   l_status := CZ_UTILS.GET_TEXT('CZ_SEC_NO_MODEL_FOUND','RULEFOLDERID',p_rule_folder_id );
   RETURN l_status;
WHEN RULE_FOLDER_ID_IS_NULL THEN
   l_status := CZ_UTILS.GET_TEXT('CZ_SEC_RULE_FOLDER_ID_NULL');
   RETURN l_status;
WHEN OTHERS THEN
  l_status := SQLERRM;
  RETURN l_status;
END is_parent_rulefolder_locked;

------------
FUNCTION is_parent_ui_locked (p_ui_def_id IN NUMBER)
RETURN VARCHAR2
IS

l_status             VARCHAR2(2000);
l_checkout_user   VARCHAR2(40) := '';
UI_DEF_ID_IS_NULL EXCEPTION;

BEGIN
   l_status   := 'N';
   IF (p_ui_def_id IS NULL) THEN
      RAISE UI_DEF_ID_IS_NULL;
   END IF;

   SELECT checkout_user
   INTO   l_checkout_user
   FROM   cz_ui_defs
   WHERE  cz_ui_defs.ui_def_id = p_ui_def_id
   AND    cz_ui_defs.deleted_flag = '0';

   IF ( (l_checkout_user IS NOT NULL) AND (l_checkout_user <> FND_GLOBAL.user_name)) THEN
      l_status := CZ_UTILS.GET_TEXT('CZ_SEC_ENTITY_IS_LOCKED','ObjectId', cz_security_pvt.UI,
                              'Id',p_ui_def_id,'User', l_checkout_user);
   END IF;
   RETURN l_status;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   l_status := CZ_UTILS.GET_TEXT('CZ_SEC_NO_MODEL_FOUND', 'UIDEFID', p_ui_def_id);
   RETURN l_status;
WHEN UI_DEF_ID_IS_NULL THEN
   l_status := CZ_UTILS.GET_TEXT('CZ_SEC_UI_DEF_ID_NULL');
   RETURN l_status;
WHEN OTHERS THEN
  l_status := SQLERRM;
  RETURN l_status;
END is_parent_ui_locked ;

----------------------
FUNCTION is_parent_model_locked (p_model_id IN NUMBER)
RETURN VARCHAR2
IS

l_status  VARCHAR2(2000) := 'N';
l_checkout_user VARCHAR2(40) := '';
MODEL_ID_IS_NULL EXCEPTION;

BEGIN
   l_status   := 'N';
   IF (p_model_id IS NULL) THEN
      RAISE MODEL_ID_IS_NULL;
   END IF;

   SELECT checkout_user
   INTO   l_checkout_user
   FROM   cz_devl_projects
   WHERE  cz_devl_projects.devl_project_id = p_model_id
   AND    cz_devl_projects.deleted_flag = '0';

   IF (l_checkout_user IS NOT NULL)  THEN
      ------l_status := CZ_UTILS.GET_TEXT('CZ_SEC_ENTITY_IS_LOCKED','ObjectId', cz_security_pvt.MODEL,
      -----      'Id',p_model_id,'User', l_checkout_user); */
        l_status := 'Y';
   ELSE
        l_status := 'N';
   END IF;
   RETURN l_status;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   l_status := CZ_UTILS.GET_TEXT('CZ_SEC_NO_MODEL_FOUND', 'MODELID', p_model_id);
   RETURN l_status;
WHEN MODEL_ID_IS_NULL THEN
   l_status := CZ_UTILS.GET_TEXT('CZ_SEC_MODEL_ID_NULL');
   RETURN l_status;
WHEN OTHERS THEN
  l_status := SQLERRM;
  RETURN l_status;
END is_parent_model_locked;

------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION has_model_privileges(p_model_id IN NUMBER, p_object_type IN VARCHAR2)
RETURN VARCHAR2
IS
l_return_status VARCHAR2(1);
BEGIN
  IF (p_object_type = 'PRJ') THEN
    l_return_status := has_model_privileges(p_model_id);
  ELSE
    l_return_status := 'T';
  END IF;
  RETURN l_return_status;
END has_model_privileges;


FUNCTION is_rulefolder_locked(p_rule_folder_id IN NUMBER,p_object_type IN VARCHAR2)
RETURN VARCHAR2
IS
l_return_status VARCHAR2(1);
BEGIN
  IF (p_object_type = 'RFL') THEN
    l_return_status := is_rulefolder_locked(p_rule_folder_id);
  ELSE
    l_return_status := 'T';
  END IF;
RETURN l_return_status;
END is_rulefolder_locked;

FUNCTION is_rulefolder_editable(p_rulefolder_id        IN NUMBER,
                                p_object_type          IN VARCHAR2,
                                p_parent_rulefolder_id IN NUMBER)
RETURN VARCHAR2
IS
l_return_status VARCHAR2(1);
BEGIN
  IF (p_object_type = 'RFL') THEN
    l_return_status := is_rulefolder_editable(p_rulefolder_id);
  ELSE
    l_return_status := is_rulefolder_editable(p_parent_rulefolder_id);
  END IF;
RETURN l_return_status;
END is_rulefolder_editable;


FUNCTION is_model_locked (p_model_id IN NUMBER,p_object_type IN VARCHAR2)
RETURN VARCHAR2
IS
l_return_status VARCHAR2(1);
BEGIN
  IF (p_object_type = 'PRJ') THEN
    l_return_status := is_model_locked (p_model_id);
  ELSE
    l_return_status := 'T';
  END IF;
RETURN l_return_status;
END is_model_locked;

---------------------------------
FUNCTION is_model_locked (p_model_id      IN NUMBER,
                          p_object_type   IN VARCHAR2,
                          p_checkout_user IN VARCHAR2,
                          p_flag          IN NUMBER)
RETURN VARCHAR2
IS
l_return_status VARCHAR2(1);
BEGIN
  IF (p_object_type = 'PRJ') THEN
    l_return_status := is_model_locked (p_model_id,p_checkout_user,fnd_global.user_name);
  ELSE
    l_return_status := 'T';
  END IF;
RETURN l_return_status;
END is_model_locked;

-----------------------------------
FUNCTION is_model_editable (p_model_id IN NUMBER,p_object_type IN VARCHAR2)
RETURN VARCHAR2
IS
l_return_status VARCHAR2(1);
BEGIN
  IF (p_object_type = 'PRJ') THEN
    l_return_status := is_model_editable (p_model_id);
  ELSE
    l_return_status := 'T';
  END IF;
RETURN l_return_status;
END is_model_editable;

--------------------------------------
FUNCTION is_model_editable (p_model_id IN NUMBER,
                            p_object_type IN VARCHAR2,
                            p_checkout_user IN VARCHAR2,
                            p_flag IN VARCHAR2 )
RETURN VARCHAR2
IS
l_return_status VARCHAR2(1);
BEGIN
  IF (p_object_type = 'PRJ') THEN
    l_return_status := is_model_editable (p_model_id,p_checkout_user,fnd_global.user_name);
  ELSE
    l_return_status := 'T';
  END IF;
RETURN l_return_status;
END is_model_editable;

-------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION get_user_name(p_user_id IN NUMBER)
RETURN VARCHAR2
IS
  l_user_name VARCHAR2(100);
BEGIN
  SELECT user_name INTO l_user_name
  FROM   fnd_user
  WHERE  user_id = p_user_id ;
  RETURN l_user_name ;
EXCEPTION
WHEN OTHERS THEN
   RETURN 'NONE';
END get_user_name;

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION get_resp_name (p_user_id IN NUMBER)
RETURN VARCHAR2
IS

CURSOR resp_cur IS SELECT responsibility_id from FND_USER_RESP_GROUPS
                   WHERE user_id = p_user_id
                   AND   responsibility_application_id = 708;

l_responsibility_id NUMBER := 0;
l_resp_name              VARCHAR2(2000);
l_return_str        VARCHAR2(2000) := NULL;
BEGIN
   OPEN resp_cur;
   LOOP
      FETCH resp_cur INTO l_responsibility_id;
      EXIT WHEN resp_cur%NOTFOUND;
      SELECT responsibility_name INTO l_resp_name
      FROM   fnd_responsibility_tl
      WHERE  responsibility_id = l_responsibility_id
      AND    language = userenv('LANG');
      l_return_str := l_return_str||', '||l_resp_name;
   END LOOP;
   CLOSE resp_cur;
   l_return_str := RTRIM(l_return_str, ', ');
   l_return_str := LTRIM(l_return_str, ', ');
   return l_return_str;
EXCEPTION
WHEN OTHERS THEN
  l_return_str := ' ';
  return l_return_str ;
END get_resp_name ;

----------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- Stubbed as part of the bug 4861666, as this code is not utilized
-- in the system due to the obsoletion of "View Entity Access" feature
PROCEDURE GET_CZ_GRANTS_UPDATE (p_entity_id   IN NUMBER,
                                p_entity_type IN VARCHAR2,
                                p_model_id    IN NUMBER,
                                p_priv        IN VARCHAR2,
                                p_user_name   in varchar2,
                                p_role        in varchar2)
AS
BEGIN
  NULL;
END GET_CZ_GRANTS_UPDATE;
-------------------------------------------------
-----11.5.10 + Locking only
------------------------------------------------
FUNCTION get_locking_profile_value
RETURN VARCHAR2
IS
  l_profile_value VARCHAR2(255);
BEGIN
  l_profile_value := FND_PROFILE.VALUE(LOCK_REQUIRE_LOCKING);
  RETURN  l_profile_value;
END;

-------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE add_to_error_stack(p_model_id IN NUMBER,
                             x_model_name_tbl IN OUT NOCOPY model_name_tbl,
                             x_checkout_user_tbl IN OUT NOCOPY checkout_user_tbl)
IS

BEGIN
  SELECT name, checkout_user
  BULK
  COLLECT
  INTO   x_model_name_tbl, x_checkout_user_tbl
  FROM   cz_devl_projects
  WHERE  cz_devl_projects.devl_project_id IN (SELECT component_id
                                    FROM   cz_model_ref_expls
                                    WHERE  cz_model_ref_expls.deleted_flag = '0'
                                    AND    cz_model_ref_expls.model_id = p_model_id)
  AND    (cz_devl_projects.checkout_user IS NOT NULL
            AND  cz_devl_projects.checkout_user <> FND_GLOBAL.user_name)
  AND   cz_devl_projects.deleted_flag = '0';
EXCEPTION
WHEN OTHERS THEN
  NULL;
END;

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE get_checkout_user(p_obj_id IN NUMBER,
                           p_obj_type IN VARCHAR2,
                           x_checkout_user IN OUT NOCOPY VARCHAR2,
                           x_model_name    IN OUT NOCOPY VARCHAR2)
IS
BEGIN
  IF (p_obj_type = 'PRJ') THEN
      SELECT name, checkout_user
      INTO   x_model_name,x_checkout_user
      FROM   cz_devl_projects
      WHERE  cz_devl_projects.devl_project_id = p_obj_id ;
  ELSIF (p_obj_type = 'UIT') THEN
      SELECT template_name, checkout_user
      INTO   x_model_name,x_checkout_user
      FROM   cz_ui_templates
      WHERE  cz_ui_templates.template_id = p_obj_id ;
  END IF;
EXCEPTION
WHEN OTHERS THEN
   NULL;
END get_checkout_user;

------------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE get_models_to_lock (p_model_id      IN NUMBER,
                             p_references    IN NUMBER,
                             x_models_to_lock OUT NOCOPY number_type_tbl)
IS
BEGIN
  x_models_to_lock.DELETE;
  IF (p_references = 0) THEN
      SELECT distinct a.component_id
      BULK
      COLLECT
      INTO   x_models_to_lock
      FROM   cz_model_ref_expls a
      WHERE  a.model_id = p_model_id
      AND    a.deleted_flag = '0'
      AND    a.component_id IN ( SELECT devl_project_id
                                 FROM   cz_devl_projects
                                 WHERE  checkout_user IS NULL
                                 AND   devl_project_id = a.component_id  );
  ELSIF (p_references = 1) THEN
      SELECT  devl_project_id
      BULK
      COLLECT
      INTO    x_models_to_lock
       FROM   cz_devl_projects
       WHERE  checkout_user IS NULL
       AND    devl_project_id = p_model_id;
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
      NULL;
END;

------------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
/*#
 * This is the public interface for force unlock operations on a model in Oracle Configurator
 * @param p_api_version number.  Current version of the API is 1.0
 * @param p_model_id    number.  devl_project_id of the model from cz_devl_projects table
 * @param p_unlock_references   A value of FND_API.G_TRUE indicates that the child models if any should be
 *                              force unlocked. A value of FND_API.G_FALSE indicates that only the root model
 *                              will be unlocked
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname API for working with force unlock operations on a model
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_SECURITY
 */

PROCEDURE force_unlock_model (p_api_version        IN NUMBER,
                              p_model_id           IN NUMBER,
                              p_unlock_references  IN VARCHAR2,
                              p_init_msg_list      IN VARCHAR2,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_msg_count         OUT NOCOPY NUMBER,
                              x_msg_data          OUT NOCOPY VARCHAR2)
IS

MODELID_IS_NULL         EXCEPTION;
MODEL_UNLOCK_ERR        EXCEPTION;
NO_FORCE_UNLOCK_PRIV    EXCEPTION;
l_model_tbl             cz_security_pvt.number_type_tbl;
l_count                 NUMBER := 0;
l_unlock_references     VARCHAR2(1);
l_has_priv              BOOLEAN;
l_checkout_user     cz_devl_projects.checkout_user%TYPE;
l_model_name        cz_devl_projects.name%TYPE;

BEGIN
   ----initialize FND stack
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_data      := NULL;
   x_msg_count     := 0;

   ----initialize the message stack depending on the input parameter
   IF(p_init_msg_list = FND_API.G_TRUE)THEN fnd_msg_pub.initialize; END IF;

   ----check if the input parameter p_model_id is NULL
   ----if it is NULL raise an exception
   IF (p_model_id IS NULL) THEN
      RAISE MODELID_IS_NULL;
   END IF;  /* end if of IF (p_model_id IS NULL) */

   -----check if the user has privilege to force unlock
   -----a model.  If the user has no privilege to force
   -----unlock the model raise an exception
   l_has_priv := FND_FUNCTION.TEST(UNLOCK_FUNCTION);
   IF (NOT l_has_priv) THEN
      RAISE NO_FORCE_UNLOCK_PRIV;
   END IF; /* IF (NOT l_has_priv) */

   -----validate input parameter p_unlock_references
   IF (p_unlock_references IS NULL) THEN
      l_unlock_references := DO_NOT_UNLOCK_CHILD_MODELS;
   ELSIF (p_unlock_references = FND_API.G_FALSE) THEN
      l_unlock_references := DO_NOT_UNLOCK_CHILD_MODELS;
   ELSIF (p_unlock_references = FND_API.G_TRUE) THEN
      l_unlock_references := UNLOCK_CHILD_MODELS;
   END IF; /* end if of (p_unlock_references IS NULL) */

   ------if p_unlock_references IS FND_API.G_TRUE then
   ------do the following
   IF (l_unlock_references = UNLOCK_CHILD_MODELS) THEN
         l_model_tbl.DELETE;
         BEGIN
               SELECT distinct component_id
               BULK
               COLLECT
               INTO   l_model_tbl
               FROM   cz_model_ref_expls
               WHERE  model_id = p_model_id
               AND    deleted_flag = '0'
               AND    ps_node_type IN (263,264);
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
         END;
         l_count := l_model_tbl.COUNT + 1;
         l_model_tbl(l_count) := p_model_id;
         IF (l_model_tbl.COUNT > 0) THEN
            FOR I IN l_model_tbl.FIRST..l_model_tbl.LAST
            LOOP
                 UPDATE cz_devl_projects
                 SET    cz_devl_projects.checkout_user = NULL,
                        cz_devl_projects.checkout_time = NULL
                 WHERE  cz_devl_projects.devl_project_id = l_model_tbl(i);
                 IF (SQL%ROWCOUNT = 0) THEN
                  get_checkout_user(l_model_tbl(i),'PRJ',l_checkout_user,l_model_name);
                     RAISE MODEL_UNLOCK_ERR ;
               END IF;
             END LOOP;
          END IF;
      ELSE  /* else of IF (l_unlock_references = UNLOCK_CHILD_MODELS) THEN */
          UPDATE cz_devl_projects
          SET    cz_devl_projects.checkout_user = NULL,
                 cz_devl_projects.checkout_time = NULL
          WHERE  cz_devl_projects.devl_project_id = p_model_id;

         IF (SQL%ROWCOUNT = 0) THEN
            get_checkout_user(p_model_id,'PRJ',l_checkout_user,l_model_name);
                    RAISE MODEL_UNLOCK_ERR;
         END IF;
      END IF; /* end if of IF (l_unlock_references = UNLOCK_CHILD_MODELS) */
COMMIT;
EXCEPTION
WHEN MODELID_IS_NULL THEN
   NULL;
WHEN NO_FORCE_UNLOCK_PRIV THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := 1;
   FND_MESSAGE.SET_NAME( 'CZ','CZ_NO_FORCE_UNLOCK_PRIV');
   --FND_MESSAGE.SET_TOKEN('USERNAME',FND_GLOBAL.USER_NAME);
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);
WHEN MODEL_UNLOCK_ERR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := 1;
   FND_MESSAGE.SET_NAME( 'CZ','CZ_MODEL_UNLOCK_ERR');
   FND_MESSAGE.SET_TOKEN('MODELNAME', l_model_name);
   FND_MESSAGE.SET_TOKEN('USERNAME', l_checkout_user);
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := 1;
   get_checkout_user(p_model_id, 'PRJ', l_checkout_user, l_model_name);
   x_msg_data := CZ_UTILS.GET_TEXT('CZ_UNLOCK_FATAL_ERR', 'OBJECTNAME', l_model_name, 'SQLERRM', SQLERRM);
   fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
END force_unlock_model;

--------------------
/*#
 * This is the public interface for force unlock operations on a UI content template in Oracle Configurator
 * @param p_api_version number.  Current version of the API is 1.0
 * @param p_template_id number.  Template_id of the template from cz_ui_templates table
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname API for working with force unlock operations on a UI content template
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_SECURITY
 */

PROCEDURE force_unlock_template (p_api_version    IN NUMBER,
                                 p_template_id    IN NUMBER,
                                 p_init_msg_list  IN VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2)
IS

templateID_IS_NULL      EXCEPTION;
template_UNLOCK_ERR     EXCEPTION;
NO_FORCE_UNLOCK_PRIV    EXCEPTION;
l_template_tbl          cz_security_pvt.number_type_tbl;
l_count                 NUMBER := 0;
l_unlock_references     VARCHAR2(1);
l_has_priv              BOOLEAN;
l_checkout_user         cz_devl_projects.checkout_user%TYPE;
l_template_name         cz_devl_projects.name%TYPE;

BEGIN

   ----initialize FND stack
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_data      := NULL;
   x_msg_count     := 0;

   ----initialize the message stack depending on the input parameter
   IF(p_init_msg_list = FND_API.G_TRUE)THEN fnd_msg_pub.initialize; END IF;

   ----check if the input parameter p_template_id is NULL
   ----if it is NULL raise an exception
   IF (p_template_id IS NULL) THEN
      RAISE templateID_IS_NULL;
   END IF; /* IF (p_template_id IS NULL) */

   -----check if the user has privilege to force unlock
   -----a template.  If the user has no privilege to force
   -----unlock the template then raise an exception
   l_has_priv := FND_FUNCTION.TEST(UNLOCK_FUNCTION);
   IF (NOT l_has_priv) THEN
      RAISE NO_FORCE_UNLOCK_PRIV;
   END IF; /* IF (NOT l_has_priv) */

   -----unlock the template by setting the checkout user
   -----and check out time to NULL
   UPDATE cz_ui_templates
   SET    cz_ui_templates.checkout_user = NULL,
          cz_ui_templates.checkout_time = NULL
   WHERE  cz_ui_templates.template_id = p_template_id;

   IF (SQL%ROWCOUNT = 0) THEN
      get_checkout_user(p_template_id,'UIT',l_checkout_user,l_template_name);
      RAISE template_UNLOCK_ERR;
   END IF;
COMMIT;
EXCEPTION
WHEN TEMPLATEID_IS_NULL THEN
   NULL;
WHEN NO_FORCE_UNLOCK_PRIV THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := 1;
   FND_MESSAGE.SET_NAME( 'CZ','CZ_NO_FORCE_UNLOCK_PRIV');
   --FND_MESSAGE.SET_TOKEN('USERNAME',FND_GLOBAL.USER_NAME);
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);
WHEN TEMPLATE_UNLOCK_ERR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := 1;
   FND_MESSAGE.SET_NAME( 'CZ','CZ_UNLOCK_TMPL_ERR');
   FND_MESSAGE.SET_TOKEN('TEMPLATENAME', l_template_name);
   FND_MESSAGE.SET_TOKEN('USERNAME', l_checkout_user);
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := 1;
   get_checkout_user(p_template_id, 'UIT', l_checkout_user, l_template_name);
   x_msg_data := CZ_UTILS.GET_TEXT('CZ_UNLOCK_FATAL_ERR', 'OBJECTNAME', l_template_name, 'SQLERRM', SQLERRM);
   fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
END force_unlock_template;

--------------------
/*#
 * This is the public interface for lock operations on a UI content template in Oracle Configurator
 * @param p_api_version number.  Current version of the API is 1.0
 * @param p_template_id number.  Template_id of the template from cz_ui_templates table
 * @param p_commit_flag A value of FND_API.G_TRUE indicates that the a commit be issued at the end of the
 *          the procedure. A value of FND_API.G_FALSE indicates that no COMMIT is done.
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname API for working with force lock operations on a UI content template
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_SECURITY
 */

PROCEDURE lock_template(p_api_version       IN NUMBER,
                        p_template_id       IN NUMBER,
                        p_commit_flag       IN VARCHAR2,
                        p_init_msg_list     IN VARCHAR2,
                        x_return_status    OUT NOCOPY VARCHAR2,
                        x_msg_count        OUT NOCOPY NUMBER,
                        x_msg_data         OUT NOCOPY VARCHAR2)
IS

l_checkout_user     cz_ui_templates.checkout_user%TYPE;
l_template_name     cz_ui_templates.template_name%TYPE;
TEMPLATE_IS_LOCKED  EXCEPTION;
TEMPLATEID_IS_NULL  EXCEPTION;
NO_LOCKING_REQUIRED EXCEPTION;
l_commit_flag       VARCHAR2(1);
l_lock_profile      VARCHAR2(3);

BEGIN

   ----initialize FND stack
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_data      := NULL;
   x_msg_count     := 0;

   ----initialize the message stack depending on the input parameter
   IF(p_init_msg_list = FND_API.G_TRUE)THEN fnd_msg_pub.initialize; END IF;

   ----check if locking is enabled
   ----if the site level profile for locking is not enabled then
   ----there is no need to do locking
   l_lock_profile := get_locking_profile_value;
   IF (UPPER(NVL(l_lock_profile,'Y')) IN ('N','NO')) THEN
      RAISE NO_LOCKING_REQUIRED;
   END IF; /*IF (UPPER(NVL(l_lock_profile,'Y')) IN ('N','NO')) */

   -----check if the input parameter p_template_id
   -----has a value
   IF (p_template_id IS NULL) THEN
      RAISE TEMPLATEID_IS_NULL;
   END IF; /* IF (p_template_id IS NULL) */

   -----initialize l_commit_flag
   IF (p_commit_flag IS NULL) THEN
      l_commit_flag := DO_NOT_COMMIT;
   ELSIF (p_commit_flag = FND_API.G_TRUE) THEN
      l_commit_flag := DO_COMMIT;
   ELSIF (p_commit_flag = FND_API.G_FALSE) THEN
      l_commit_flag := DO_NOT_COMMIT;
   END IF; /* IF (p_commit_flag IS NULL) */

   -----set the checkout_user and checkout_time
   UPDATE cz_ui_templates
     SET  cz_ui_templates.checkout_user = FND_GLOBAL.user_name,
          cz_ui_templates.checkout_time = sysdate
   WHERE  cz_ui_templates.template_id = p_template_id
    AND   (cz_ui_templates.checkout_user IS NULL);
   IF (SQL%ROWCOUNT = 0) THEN
         get_checkout_user(p_template_id,'UIT',l_checkout_user,l_template_name);
         IF(l_checkout_user<>FND_GLOBAL.user_name AND l_checkout_user is not null)
         THEN
             RAISE TEMPLATE_IS_LOCKED;
         END IF;
   END IF;
IF (l_commit_flag = DO_COMMIT) THEN COMMIT; END IF;  /* IF (l_commit_flag = '0') */
EXCEPTION
WHEN NO_LOCKING_REQUIRED THEN
   NULL;
WHEN TEMPLATEID_IS_NULL THEN
   NULL;
WHEN TEMPLATE_IS_LOCKED THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME( 'CZ','CZ_LOCK_TEMPLATE_ERR');
   FND_MESSAGE.SET_TOKEN('TEMPLATENAME', l_template_name);
   FND_MESSAGE.SET_TOKEN('USERNAME' , l_checkout_user);
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data, p_encoded => FND_API.G_FALSE);
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := 1;
   get_checkout_user(p_template_id, 'UIT', l_checkout_user, l_template_name);
   FND_MESSAGE.SET_NAME('CZ','CZ_LOCK_FATAL_ERR');
   FND_MESSAGE.SET_TOKEN('OBJECTNAME', l_template_name);
   FND_MESSAGE.SET_TOKEN('SQLERRM', SQLERRM);
   fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);
END lock_template;

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
/*#
 * This is the public interface for lock operations on a UI content template in Oracle Configurator
 * @param p_api_version number.  Current version of the API is 1.0
 * @param p_templates_to_lock array of templates to lock
 * @param p_commit_flag A value of FND_API.G_TRUE indicates that the a commit be issued at the end of the
 *          the procedure. A value of FND_API.G_FALSE indicates that no COMMIT is done.
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_locked_templates templates locked by this procedure
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname API for working with force lock operations on a UI content template
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_SECURITY
 */
PROCEDURE lock_template(p_api_version            IN  NUMBER,
                        p_templates_to_lock      IN  cz_security_pvt.number_type_tbl,
                        p_commit_flag            IN  VARCHAR2,
                        p_init_msg_list          IN  VARCHAR2,
                        x_locked_templates       OUT NOCOPY cz_security_pvt.number_type_tbl,
                        x_return_status          OUT NOCOPY VARCHAR2,
                        x_msg_count              OUT NOCOPY NUMBER,
                        x_msg_data               OUT NOCOPY VARCHAR2)
IS

NO_TEMPLATES_IDS EXCEPTION;
l_count          NUMBER;
l_checkout_user  cz_ui_templates.checkout_user%TYPE;
l_return_status  VARCHAR2(1);

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ----initialize the message stack depending on the input parameter
   IF(p_init_msg_list = FND_API.G_TRUE)THEN fnd_msg_pub.initialize; END IF;

   -----check if the input parameter p_template_id
   -----has a value
   IF (p_templates_to_lock.COUNT = 0) THEN
      RAISE NO_TEMPLATES_IDS;
   END IF; /* IF (p_templates_to_lock.COUNT = 0) */

   IF (p_templates_to_lock.COUNT > 0) THEN
      FOR I IN p_templates_to_lock.FIRST..p_templates_to_lock.LAST
      LOOP
         l_checkout_user := NULL;
         BEGIN
            SELECT checkout_user
             INTO  l_checkout_user
            FROM   cz_ui_templates
            WHERE  template_id = p_templates_to_lock(i)
             AND   checkout_user = FND_GLOBAL.user_name;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_checkout_user := NULL;
         END;

         IF (l_checkout_user IS NULL) THEN
            l_count := x_locked_templates.COUNT + 1;
            x_locked_templates(l_count) := p_templates_to_lock(i);
            cz_security_pvt.lock_template(1.0,
                        p_templates_to_lock(i),
                        FND_API.G_FALSE,
                        FND_API.G_FALSE,
                        l_return_status,
                        x_msg_count,
                        x_msg_data);
           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
        END IF;
      END LOOP;
   END IF;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data,p_encoded => FND_API.G_FALSE);
   IF (p_commit_flag =  FND_API.G_TRUE) THEN COMMIT; END IF;  /* IF (p_commit_flag = '0') */
EXCEPTION
WHEN NO_TEMPLATES_IDS THEN
   NULL;
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_return_status := SQLERRM;
   x_msg_count := 1;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);
END lock_template;

------------------------------
---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
/*#
 * This is the public interface for unlock operations on a UI content template in Oracle Configurator
 * @param p_template_id number.  Template_id of the template from cz_ui_templates table
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname API for working with unlock operations on a UI content template
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_SECURITY
 */

PROCEDURE unlock_template(p_api_version      IN NUMBER,
                          p_template_id      IN NUMBER,
                          p_init_msg_list    IN VARCHAR2,
                          x_return_status    OUT NOCOPY VARCHAR2,
                          x_msg_count        OUT NOCOPY NUMBER,
                          x_msg_data         OUT NOCOPY VARCHAR2)
IS

TEMPLATEID_IS_NULL       EXCEPTION;
TEMPLATE_UNLOCK_ERR      EXCEPTION;
NO_LOCKING_REQUIRED      EXCEPTION;
l_count                  NUMBER := 0;
l_checkout_user          cz_ui_templates.checkout_user%TYPE;
l_template_name          cz_ui_templates.template_name%TYPE;
l_commit_flag            VARCHAR2(1);
l_lock_profile           VARCHAR2(3);

BEGIN
   ----initialize FND stack
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_count := 0;
   x_msg_data  := NULL;
   ----initialize the message stack depending on the input parameter
   IF(p_init_msg_list = FND_API.G_TRUE)THEN fnd_msg_pub.initialize; END IF;

   -----check if the input parameter p_template_id
   -----has a value
   IF (p_template_id IS NULL) THEN
      RAISE TEMPLATEID_IS_NULL;
   END IF; /* IF (p_template_id IS NULL) */

   ----check if locking is enabled
   ----if the site level profile for locking is not enabled then
   ----there is no need to do unlocking
   l_lock_profile := get_locking_profile_value;
   IF (UPPER(NVL(l_lock_profile,'Y')) IN ('N','NO')) THEN
      RAISE NO_LOCKING_REQUIRED;
   END IF; /* IF (UPPER(NVL(l_lock_profile,'Y')) IN ('N','NO')) */

   -----set the checkout_user and checkout_time
   UPDATE cz_ui_templates
   SET    cz_ui_templates.checkout_user = NULL,
          cz_ui_templates.checkout_time = NULL
   WHERE  cz_ui_templates.template_id = p_template_id
   AND   (cz_ui_templates.checkout_user IS NULL
      OR    cz_ui_templates.checkout_user = FND_GLOBAL.user_name);
   IF (SQL%ROWCOUNT = 0) THEN
      get_checkout_user(p_template_id,'UIT',l_checkout_user,l_template_name);
           RAISE TEMPLATE_UNLOCK_ERR;
   END IF; /* IF (SQL%ROWCOUNT = 0) */
EXCEPTION
WHEN NO_LOCKING_REQUIRED THEN
   NULL;
WHEN TEMPLATEID_IS_NULL THEN
   NULL;
WHEN TEMPLATE_UNLOCK_ERR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := 1;
   FND_MESSAGE.SET_NAME( 'CZ','CZ_UNLOCK_TMPL_ERR');
   FND_MESSAGE.SET_TOKEN('TEMPLATENAME', l_template_name);
   FND_MESSAGE.SET_TOKEN('USERNAME', l_checkout_user);
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := 1;
   get_checkout_user(p_template_id, 'UIT', l_checkout_user, l_template_name);
   x_msg_data := CZ_UTILS.GET_TEXT('CZ_UNLOCK_FATAL_ERR', 'OBJECTNAME', l_template_name, 'SQLERRM', SQLERRM);
   fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
END unlock_template;

----------------------
PROCEDURE unlock_template(p_api_version IN  NUMBER,
                        p_templates_to_unlock    IN  cz_security_pvt.number_type_tbl,
                        p_commit_flag            IN  VARCHAR2,
                        p_init_msg_list          IN  VARCHAR2,
                        x_return_status          OUT NOCOPY VARCHAR2,
                        x_msg_count              OUT NOCOPY NUMBER,
                        x_msg_data               OUT NOCOPY VARCHAR2)
IS

NO_TEMPLATES_IDS EXCEPTION;
l_return_status  VARCHAR2(1);

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_count := 0;
   ----initialize the message stack depending on the input parameter
   IF(p_init_msg_list = FND_API.G_TRUE)THEN fnd_msg_pub.initialize; END IF;

   -----check if the input parameter p_template_id
   -----has a value
   IF (p_templates_to_unlock.COUNT = 0) THEN
      RAISE NO_TEMPLATES_IDS;
   END IF; /* IF (p_templates_to_lock.COUNT = 0) */

   IF (p_templates_to_unlock.COUNT > 0) THEN
      FOR I IN p_templates_to_unlock.FIRST..p_templates_to_unlock.LAST
      LOOP
          cz_security_pvt.unlock_template(1.0,
                        p_templates_to_unlock(i),
                        FND_API.G_FALSE,
                        l_return_status,
                        x_msg_count,
                        x_msg_data);
           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
      END LOOP;
   END IF;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);
   IF (p_commit_flag =  FND_API.G_TRUE) THEN COMMIT; END IF;  /* IF (p_commit_flag = '0') */
EXCEPTION
WHEN NO_TEMPLATES_IDS THEN
   NULL;
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_return_status := SQLERRM;
   x_msg_count := 1;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);
END unlock_template;

---------------------
/*#
 * This is the public interface for lock operations on a model in Oracle Configurator
 * @param p_model_id    number.  devl_project_id of the model from cz_devl_projects table
 * @param p_lock_child_models   A value of FND_API.G_TRUE indicates that the child models if any should be
 *                              locked. A value of FND_API.G_FALSE indicates that only the root model
 *                              will be locked
 * @param p_commit_flag A value of FND_API.G_TRUE indicates that the a commit be issued at the end of the
 *          the procedure. A value of FND_API.G_FALSE indicates that no COMMIT is done.
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_locked_entities Contains models locked by this procedure call.  This when passed as an input parameter
           to unlock_model API would ensure that only those models that have been locked by the lock API are unlocked.  Models
 *         that were previously locked would not be unlocked (by the same user).  The retaining of the lock state
 *         is done only during implicit locks and not when an unlock is done from developer.
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname API for working with lock operations on a model
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_SECURITY
 *
 * Validations: The lock_model API validates the following:
 *              1. validate input parameters
 *              2. Check for the profile value 'CZ: Require Locking'. If 'Yes' then lock model
 *                 otherwise return a status of 'S'
 *              3. When doing a lock on the model and its children, if any of the model(s)
 *                 are locked by a different user (it is ok to be locked by the same user)
 *                 an exception is raised.
 *                 The error messages are written to the FND stack and there would be one message
 *                 for each model locked by a different user.
 *                 The message would contain the name of the model and the user who locked it.
 *
 * Error reporting: Messages are written to FND error stack.  The caller would have to get all the
 *                  messages from the stack.  No messages are logged to cz_db_logs.
 *
 * Usage
 * lock model and its children  :    cz_security_pvt.lock_model(
 *                             p_model_id => <devl_project_id of the model>,
 *                             p_lock_child_models =>  FND_API.G_TRUE,
 *                             p_commit_flag =>  FND_API.G_TRUE,
 *                             p_init_msg_list => FND_API.G_TRUE,
 *                             x_prev_locked_entities =>  l_locked_entities,
 *                             x_return_status => x_return_status,
 *                             x_msg_count =>   x_msg_count,
 *                             x_msg_data =>   x_msg_data);
 *
 * lock root model only         :    cz_security_pvt.lock_model(
 *                             p_model_id => <devl_project_id of the model>,
 *                             p_lock_child_models =>  FND_API.G_FALSE,
 *                             p_commit_flag =>  FND_API.G_TRUE,
 *                             p_init_msg_list => FND_API.G_TRUE,
 *                             x_locked_entities =>  l_locked_entities,
 *                             x_return_status => x_return_status,
 *                             x_msg_count =>   x_msg_count,
 *                             x_msg_data =>   x_msg_data);
 */

PROCEDURE lock_model(p_api_version            IN NUMBER,
                     p_model_id               IN NUMBER,
                     p_lock_child_models      IN VARCHAR2,
                     p_commit_flag            IN VARCHAR2,
                     p_init_msg_list          IN VARCHAR2,
                     x_locked_entities  OUT NOCOPY number_type_tbl,
                     x_return_status         OUT NOCOPY VARCHAR2,
                     x_msg_count             OUT NOCOPY NUMBER,
                     x_msg_data              OUT NOCOPY VARCHAR2)
IS

l_checkout_user       cz_devl_projects.checkout_user%TYPE;
l_model_name          cz_devl_projects.name%TYPE;
l_model_name_tbl      cz_security_pvt.model_name_tbl;
l_checkout_user_tbl   cz_security_pvt.checkout_user_tbl;
MODEL_IS_LOCKED       EXCEPTION;
MODELID_IS_NULL       EXCEPTION;
INVALID_MODEL_ID	    EXCEPTION;
NO_LOCKING_REQUIRED   EXCEPTION;
LOCK_SINGLE_MODEL_ERR EXCEPTION;
l_model_tbl           cz_security_pvt.number_type_tbl;
l_prev_locked_models  cz_security_pvt.number_type_tbl;
l_count               NUMBER := 0;
l_lock_child_models   VARCHAR2(1);
l_commit_flag         VARCHAR2(1);
l_lock_profile        VARCHAR2(3);
l_model_id		    cz_devl_projects.devl_project_id%TYPE;
l_seeded_flag		    cz_rp_entries.seeded_flag%TYPE;

BEGIN
   ----initialize FND stack
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_data      := NULL;
   x_msg_count     := 0;
   x_locked_entities.DELETE;

   ----initialize the message stack depending on the input parameter
   IF(p_init_msg_list = FND_API.G_TRUE)THEN fnd_msg_pub.initialize; END IF;

   ----check if locking is enabled
   ----if the site level profile for locking is not enabled then
   ----there is no need to do locking
   l_lock_profile := get_locking_profile_value;
   IF (UPPER(NVL(l_lock_profile,'Y')) IN ('N','NO')) THEN
      RAISE NO_LOCKING_REQUIRED;
   END IF;

    ----check if the input parameter p_model_id
   -----has a value
   IF (p_model_id IS NULL) THEN
      RAISE MODELID_IS_NULL;
   ELSE
     BEGIN
       SELECT devl_project_id, seeded_flag
       INTO   l_model_id, l_seeded_flag
       FROM   cz_rp_entries a, cz_devl_projects b
       WHERE  b.devl_project_id = p_model_id
       AND    b.devl_project_id = a.object_id
       AND    a.deleted_flag = '0'
       AND    b.deleted_flag = '0'
       AND    a.object_type='PRJ';
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RAISE INVALID_MODEL_ID;
     END;
   END IF; /* IF (p_model_id IS NULL) */

   IF (l_seeded_flag = '1') THEN
      RAISE NO_LOCKING_REQUIRED;
   END IF;

   -----initialize l_commit_flag
   IF (p_commit_flag IS NULL) THEN
      l_commit_flag := DO_NOT_COMMIT;
   ELSIF (p_commit_flag = FND_API.G_TRUE) THEN
      l_commit_flag := DO_COMMIT;
   ELSIF (p_commit_flag = FND_API.G_FALSE) THEN
      l_commit_flag := DO_NOT_COMMIT;
   END IF; /* IF (p_commit_flag IS NULL) */

   IF (p_lock_child_models IS NULL) THEN
      l_lock_child_models := DO_NOT_LOCK_CHILD_MODELS;
   ELSIF (p_lock_child_models = FND_API.G_TRUE) THEN
      l_lock_child_models := LOCK_CHILD_MODELS;
   ELSIF (p_lock_child_models = FND_API.G_FALSE) THEN
      l_lock_child_models := DO_NOT_LOCK_CHILD_MODELS;
   END IF; /* IF (p_lock_child_models IS NULL) */

   IF (l_lock_child_models = LOCK_CHILD_MODELS) THEN
         l_model_tbl.DELETE;
      get_models_to_lock(p_model_id,0,x_locked_entities);
         BEGIN
               SELECT distinct component_id
               BULK
               COLLECT
               INTO   l_model_tbl
               FROM   cz_model_ref_expls
               WHERE  model_id = p_model_id
               AND    deleted_flag = '0'
               AND    ps_node_type IN (263,264);
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
         END;
         l_count := l_model_tbl.COUNT + 1;
         l_model_tbl(l_count) := p_model_id;
          IF (l_model_tbl.COUNT > 0) THEN
            FOR I IN l_model_tbl.FIRST..l_model_tbl.LAST
            LOOP
                 l_count := 0;
                 UPDATE cz_devl_projects
                 SET    cz_devl_projects.checkout_user = FND_GLOBAL.user_name,
                        cz_devl_projects.checkout_time = sysdate
                 WHERE  cz_devl_projects.devl_project_id = l_model_tbl(i)
                 AND    (cz_devl_projects.checkout_user IS NULL)
                 AND    cz_devl_projects.deleted_flag = '0';

                l_count := SQL%ROWCOUNT;
                IF (l_count = 0)
                THEN
                  get_checkout_user(l_model_tbl(i),'PRJ',l_checkout_user,l_model_name);
                  IF(l_checkout_user<>FND_GLOBAL.user_name AND l_checkout_user is not null)
                  THEN
                  RAISE MODEL_IS_LOCKED;
                  END IF;
                END IF;
             END LOOP;
          END IF;
      ELSE
          l_count := 0;
          get_models_to_lock(p_model_id,1,x_locked_entities);
          UPDATE cz_devl_projects
          SET    cz_devl_projects.checkout_user = FND_GLOBAL.user_name,
                 cz_devl_projects.checkout_time = SYSDATE
          WHERE  cz_devl_projects.devl_project_id = p_model_id
          AND    (cz_devl_projects.checkout_user IS NULL);
          l_count := SQL%ROWCOUNT;
           IF (l_count = 0)
           THEN
               get_checkout_user(p_model_id,'PRJ',l_checkout_user,l_model_name);
               IF(l_checkout_user<>FND_GLOBAL.user_name AND l_checkout_user is not null)
               THEN
                 RAISE LOCK_SINGLE_MODEL_ERR;
               END IF;
          END IF;
      END IF; /* IF (l_lock_child_models = LOCK_CHILD_MODELS) */
IF (l_commit_flag = DO_COMMIT) THEN
      COMMIT;
END IF; /* IF (l_commit_flag = 1) */
EXCEPTION
WHEN INVALID_MODEL_ID THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := 1;
   FND_MESSAGE.SET_NAME( 'CZ','CZ_INVALID_MODEL_ID');
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);
WHEN LOCK_SINGLE_MODEL_ERR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := 1;
   FND_MESSAGE.SET_NAME( 'CZ','CZ_LOCK_MODEL_ERR');
   FND_MESSAGE.SET_TOKEN('MODELNAME', l_model_name);
   FND_MESSAGE.SET_TOKEN('USERNAME', l_checkout_user);
   FND_MSG_PUB.ADD;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);
WHEN NO_LOCKING_REQUIRED THEN
   NULL;
WHEN MODELID_IS_NULL THEN
   NULL;
WHEN MODEL_IS_LOCKED THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   add_to_error_stack(p_model_id,l_model_name_tbl,l_checkout_user_tbl);
   IF (l_model_name_tbl.COUNT > 0) THEN
     FOR I IN l_model_name_tbl.FIRST..l_model_name_tbl.LAST
     LOOP
       x_msg_count := x_msg_count + 1;
       FND_MESSAGE.SET_NAME('CZ', 'CZ_LOCK_MODEL_ERR');
       FND_MESSAGE.SET_TOKEN('MODELNAME', l_model_name_tbl(i));
       FND_MESSAGE.SET_TOKEN('USERNAME',l_checkout_user_tbl(i));
       FND_MSG_PUB.ADD;
     END LOOP;
   END IF;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_count := 1;
   get_checkout_user(p_model_id, 'PRJ', l_checkout_user, l_model_name);
   FND_MESSAGE.SET_NAME('CZ','CZ_LOCK_FATAL_ERR');
   FND_MESSAGE.SET_TOKEN('OBJECTNAME', l_model_name);
   FND_MESSAGE.SET_TOKEN('SQLERRM', SQLERRM);
   fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);
END lock_model;

---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
/*#
 * This is the public interface for unlock operations on a model in Oracle Configurator
 * @param p_model_id    number. devl_project_id of the model from cz_devl_projects table
 * @param p_unlock_child_models A value of FND_API.G_TRUE indicates that the child models if any should be
 *                              unlocked. A value of FND_API.G_FALSE indicates that only the root model
 *                              will be unlocked
 * @param p_models_to_unlock would contain an array of model id(s) that have been populated with
 * locked models during the execution of the lock model API.  The unlock_model API will unlock only the models
 * in this array .
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname API for working with unlock operations on a model
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_SECURITY
 *
 * Usage
 *
 * unlock models in the array
 * p_models_to_unlock :    cz_security_pvt.unlock_model(
 *                             p_commit_flag =>  FND_API.G_TRUE,
 *                             p_models_to_unlock =>  l_locked_entities,
 *                             p_init_msg_list => FND_API.G_TRUE,
 *                             x_return_status => x_return_status,
 *                             x_msg_count =>   x_msg_count,
 *                             x_msg_data =>   x_msg_data);
 *
 */

PROCEDURE unlock_model(p_api_version         IN NUMBER,
                       p_commit_flag         IN VARCHAR2,
                       p_models_to_unlock    IN number_type_tbl,
                       p_init_msg_list       IN VARCHAR2,
                       x_return_status      OUT NOCOPY VARCHAR2,
                       x_msg_count          OUT NOCOPY NUMBER,
                       x_msg_data           OUT NOCOPY VARCHAR2)
IS
l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);

BEGIN
   ----initialize FND stack
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (p_init_msg_list = FND_API.G_TRUE) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF (p_models_to_unlock.COUNT > 0) THEN
      FOR I IN p_models_to_unlock.FIRST..p_models_to_unlock.LAST
      LOOP
	  unlock_model(1.0,p_models_to_unlock(i),FND_API.G_FALSE,FND_API.G_FALSE,
			   l_return_status,l_msg_count,l_msg_data);
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END LOOP;
    END IF;
   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);
   END IF;
    IF (p_commit_flag = FND_API.G_TRUE) THEN
 	  COMMIT;
    END IF;
END unlock_model;

---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE unlock_model(p_api_version         IN NUMBER,
                       p_model_id            IN NUMBER,
                       p_commit_flag         IN VARCHAR2,
                       p_init_msg_list       IN VARCHAR2,
                       x_return_status      OUT NOCOPY VARCHAR2,
                       x_msg_count          OUT NOCOPY NUMBER,
                       x_msg_data           OUT NOCOPY VARCHAR2)
IS

MODEL_IS_NOT_UNLOCKED   EXCEPTION;
MODELID_IS_NULL         EXCEPTION;
MODEL_UNLOCK_ERR        EXCEPTION;
NO_LOCKING_REQUIRED     EXCEPTION;
l_model_tbl             cz_security_pvt.number_type_tbl;
l_count                 NUMBER := 0;
l_checkout_user         cz_devl_projects.checkout_user%TYPE;
l_model_name_tbl        cz_security_pvt.model_name_tbl;
l_checkout_user_tbl     cz_security_pvt.checkout_user_tbl;
l_model_name            cz_devl_projects.name%TYPE;
l_commit_flag           VARCHAR2(1);
l_lock_profile          VARCHAR2(3);

BEGIN
   ----initialize FND stack
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_data      := NULL;
   x_msg_count     := 0;

   ----initialize the message stack depending on the input parameter
   IF(p_init_msg_list = FND_API.G_TRUE)THEN fnd_msg_pub.initialize; END IF;

   -----check if the input parameter p_model_id
   -----has a value
   IF (p_model_id IS NULL) THEN
      RAISE MODELID_IS_NULL;
   END IF; /* IF (p_model_id IS NULL) */

   ----check if locking is enabled
   ----if the site level profile for locking is not enabled then
   ----there is no need to do locking
   l_lock_profile := get_locking_profile_value;
   IF (UPPER(NVL(l_lock_profile,'Y')) IN ('N','NO')) THEN
      RAISE NO_LOCKING_REQUIRED;
   END IF; /* IF (UPPER(NVL(l_lock_profile,'Y')) IN ('N','NO')) */

   -----initialize l_commit_flag
   IF (p_commit_flag IS NULL) THEN
      l_commit_flag := DO_NOT_COMMIT;
   ELSIF (p_commit_flag = FND_API.G_TRUE) THEN
      l_commit_flag := DO_COMMIT;
   ELSIF (p_commit_flag = FND_API.G_FALSE) THEN
      l_commit_flag := DO_NOT_COMMIT;
   END IF; /* IF (p_commit_flag IS NULL) */


   UPDATE cz_devl_projects
   SET    cz_devl_projects.checkout_user = NULL,
          cz_devl_projects.checkout_time = NULL
   WHERE  cz_devl_projects.devl_project_id = p_model_id
   AND   (cz_devl_projects.checkout_user IS NULL
   OR    cz_devl_projects.checkout_user = FND_GLOBAL.user_name);

   IF (SQL%ROWCOUNT = 0) THEN
       get_checkout_user(p_model_id,'PRJ',l_checkout_user,l_model_name);
       RAISE MODEL_UNLOCK_ERR;
    END IF;
IF (l_commit_flag = DO_COMMIT) THEN COMMIT; END IF;
EXCEPTION
WHEN NO_LOCKING_REQUIRED THEN
   NULL;
WHEN MODELID_IS_NULL THEN
   NULL;
WHEN MODEL_UNLOCK_ERR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   add_to_error_stack(p_model_id,l_model_name_tbl,l_checkout_user_tbl);
   IF (l_model_name_tbl.COUNT > 0) THEN
     FOR I IN l_model_name_tbl.FIRST..l_model_name_tbl.LAST
     LOOP
         x_msg_count := x_msg_count + 1;
       FND_MESSAGE.SET_NAME( 'CZ','CZ_MODEL_UNLOCK_ERR');
       FND_MESSAGE.SET_TOKEN('MODELNAME', l_model_name_tbl(i));
       FND_MESSAGE.SET_TOKEN('USERNAME', l_checkout_user_tbl(i));
       FND_MSG_PUB.ADD;
     END LOOP;
   END IF;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   get_checkout_user(p_model_id, 'PRJ', l_checkout_user, l_model_name);
   x_msg_data := CZ_UTILS.GET_TEXT('CZ_UNLOCK_FATAL_ERR', 'OBJECTNAME', l_model_name, 'SQLERRM', SQLERRM);
   fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
END unlock_model;
---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
------wrappers

PROCEDURE lock_template(p_api_version       IN NUMBER,
                        p_template_id       IN NUMBER,
                        p_init_msg_list     IN VARCHAR2,
                        x_return_status    OUT NOCOPY VARCHAR2,
                        x_msg_count        OUT NOCOPY NUMBER,
                        x_msg_data         OUT NOCOPY VARCHAR2)
IS

l_init_msg_list     VARCHAR2(1) := FND_API.G_FALSE;

BEGIN

   IF(p_init_msg_list = DO_INIT_MSG_LIST)THEN l_init_msg_list := FND_API.G_TRUE; END IF;

   lock_template(p_api_version, p_template_id, FND_API.G_FALSE, l_init_msg_list, x_return_status,
                 x_msg_count, x_msg_data);
END;

----------------
PROCEDURE unlock_template(p_api_version       IN NUMBER,
                          p_template_id       IN NUMBER,
                          p_force_unlock      IN VARCHAR2,
                          p_init_msg_list     IN VARCHAR2,
                          x_return_status    OUT NOCOPY VARCHAR2,
                          x_msg_count        OUT NOCOPY NUMBER,
                          x_msg_data         OUT NOCOPY VARCHAR2)
IS

l_init_msg_list     VARCHAR2(1) := FND_API.G_FALSE;

BEGIN

  IF(p_init_msg_list = DO_INIT_MSG_LIST)THEN l_init_msg_list := FND_API.G_TRUE; END IF;

  IF (p_force_unlock = '0') THEN
    unlock_template(p_api_version, p_template_id, l_init_msg_list, x_return_status, x_msg_count, x_msg_data);
  ELSE
    force_unlock_template (p_api_version, p_template_id, l_init_msg_list, x_return_status, x_msg_count,
                           x_msg_data);
  END IF;
END;

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
----For developer
PROCEDURE lock_model(p_api_version       IN NUMBER,
                     p_model_id          IN NUMBER,
                     p_lock_child_models IN VARCHAR2,
                     p_commit_flag       IN VARCHAR2,
                     p_init_msg_list     IN VARCHAR2,
                     x_return_status    OUT NOCOPY VARCHAR2,
                     x_msg_count        OUT NOCOPY NUMBER,
                     x_msg_data         OUT NOCOPY VARCHAR2)
IS

l_models_locked_tbl number_type_tbl;
l_lock_child_models VARCHAR2(1) := FND_API.G_FALSE;
l_commit_flag       VARCHAR2(1) := FND_API.G_FALSE;
l_init_msg_list     VARCHAR2(1) := FND_API.G_FALSE;

BEGIN

  IF(p_lock_child_models = LOCK_CHILD_MODELS)THEN l_lock_child_models := FND_API.G_TRUE; END IF;
  IF(p_commit_flag = DO_COMMIT)THEN l_commit_flag := FND_API.G_TRUE; END IF;
  IF(p_init_msg_list = DO_INIT_MSG_LIST)THEN l_init_msg_list := FND_API.G_TRUE; END IF;

  lock_model(p_api_version, p_model_id, l_lock_child_models, l_commit_flag, l_init_msg_list,
             l_models_locked_tbl, x_return_status, x_msg_count, x_msg_data);
END;

---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
----Wrappers to be used by Import, Publishing, Logic Gen and UI Gen. Hide the p_init_msg_list parameter.
----The message list is not initialized.
PROCEDURE lock_model(p_api_version           IN NUMBER,
                     p_model_id              IN NUMBER,
                     p_lock_child_models     IN VARCHAR2,
                     p_commit_flag           IN VARCHAR2,
                     x_locked_entities OUT NOCOPY number_type_tbl,
                     x_return_status        OUT NOCOPY VARCHAR2,
                     x_msg_count            OUT NOCOPY NUMBER,
                     x_msg_data             OUT NOCOPY VARCHAR2)
IS
BEGIN

  lock_model(p_api_version, p_model_id, p_lock_child_models, FND_API.G_TRUE, FND_API.G_FALSE,
             x_locked_entities, x_return_status, x_msg_count, x_msg_data);
END;

PROCEDURE unlock_model(p_api_version        IN  NUMBER,
                       p_commit_flag        IN  VARCHAR2,
                       p_models_to_unlock   IN  number_type_tbl,
                       x_return_status      OUT NOCOPY VARCHAR2,
                       x_msg_count          OUT NOCOPY NUMBER,
                       x_msg_data           OUT NOCOPY VARCHAR2)
IS
BEGIN

  unlock_model(p_api_version,p_commit_flag,p_models_to_unlock,
		   FND_API.G_FALSE, x_return_status,x_msg_count,x_msg_data);
END;

---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
----unlock model for rule import
PROCEDURE unlock_model (p_api_version   IN NUMBER,
		    p_model_id              IN NUMBER,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2)
IS

BEGIN
  ----initialize FND stack
   FND_MSG_PUB.initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_data      := NULL;
   x_msg_count     := 0;

   cz_security_pvt.unlock_model(1.0,p_model_id,FND_API.G_FALSE,FND_API.G_FALSE,
                               x_return_status,x_msg_count,x_msg_data);

END unlock_model;

----------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
PROCEDURE unlock_model(p_api_version         IN NUMBER,
                       p_models_to_unlock    IN SYSTEM.CZ_NUMBER_TBL_TYPE,
                       p_commit_flag         IN VARCHAR2,
                       p_init_msg_list       IN VARCHAR2,
                       x_return_status      OUT NOCOPY VARCHAR2,
                       x_msg_count          OUT NOCOPY NUMBER,
                       x_msg_data           OUT NOCOPY VARCHAR2)

IS
  l_api_name  CONSTANT VARCHAR2(30) := 'unlock_model';
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
  l_return_status VARCHAR2(1);
 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (p_init_msg_list = FND_API.G_TRUE) THEN
      FND_MSG_PUB.initialize;
      x_msg_data      := NULL;
      x_msg_count     := 0;
  END IF;

  IF (p_models_to_unlock.COUNT > 0) THEN
     FOR I IN p_models_to_unlock.FIRST..p_models_to_unlock.LAST
     LOOP
         cz_security_pvt.unlock_model(1.0,
                                     p_models_to_unlock(i),
                                     FND_API.G_FALSE,
                                     FND_API.G_FALSE,
                                     l_return_status,
                                     l_msg_count,
                                     l_msg_data);
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
     END LOOP;
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       fnd_msg_pub.count_and_get(FND_API.G_FALSE, x_msg_count, x_msg_data);
     END IF;
  END IF;
  IF (p_commit_flag = FND_API.G_TRUE) THEN COMMIT; END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
    fnd_msg_pub.count_and_get(FND_API.G_FALSE, x_msg_count, x_msg_data);
END;

---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
END cz_security_pvt;

/
