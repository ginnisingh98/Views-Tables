--------------------------------------------------------
--  DDL for Package Body EGO_SCTX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_SCTX" AS
/* $Header: EGOSCTXB.pls 115.0 2002/12/19 08:28:09 wwahid noship $ */
/*---------------------------------------------------------------------------+
 | This package contains public API for Security Context                     |
 +---------------------------------------------------------------------------*/

 g_user_id	           NUMBER  :=-1;
 g_party_org_id            NUMBER  :=-1;
 g_party_person_id         NUMBER  :=-1;
 g_object_name             VARCHAR2(30):='';
 g_object_key              NUMBER  :=-1;
 G_LANGUAGE_NAME           VARCHAR2(30):='LANGUAGE';
 G_USER_ID_NAME            VARCHAR2(30):='USER_ID';
 G_PARTY_ORG_ID_NAME       VARCHAR2(30):='PARTY_ORG_ID';
 G_PARTY_PERSON_ID_NAME    VARCHAR2(30):='PARTY_PERSON_ID';
 TYPE VARCHAR_TBL_TYPE IS TABLE OF VARCHAR2(2000)
    INDEX BY BINARY_INTEGER;



  --Private. Parse the name value pair message
  --   E.g. <Name1>Value1</Name1><Name2>Value1</Name2>
  ----------------------------------------------------------------------
  PROCEDURE Parse_Name_Value_Pairs_Msg
  (
    p_message                 IN   VARCHAR2
   ,x_name_tbl                OUT  NOCOPY VARCHAR_TBL_TYPE
   ,x_value_tbl               OUT  NOCOPY VARCHAR_TBL_TYPE
  )
  IS


    l_index                   NUMBER;
    pos1                      NUMBER;
    pos2                      NUMBER;
    pos3                      NUMBER;
    l_message                 VARCHAR2(32767);

 BEGIN
    -- parse name-value pair

    l_message:=p_message;
    l_index:=0;
    WHILE length(l_message)>0 LOOP
      pos1:=instr(l_message,'<');
      pos2:=instr(l_message,'>');
      IF (pos1 >0) THEN
         x_name_tbl(l_index):=substr(l_message, pos1+1, pos2-(pos1+1) );
         pos3:=instr(l_message,'</') ;
         x_value_tbl(l_index):=substr(l_message, pos2+1, pos3 - (pos2+1));
         l_message := substr(l_message, pos2-pos1+pos3+2);
         l_index:=l_index+1;
      ELSE
         EXIT;
      END IF;
   END LOOP;

  END Parse_Name_Value_Pairs_Msg;
-----------------------------------------------------------

-- private: set fnd_global params
----------------------------------------
  PROCEDURE set_fnd_global_user_id
  IS

  BEGIN
   FND_GLOBAL.APPS_INITIALIZE
    ( user_id          => g_user_id,
    resp_id            => FND_GLOBAL.RESP_ID,
    resp_appl_id       => FND_GLOBAL.resp_appl_id,
    security_group_id  => FND_GLOBAL.security_group_id
    );
  END set_fnd_global_user_id;
-------------------------------------


  --1. Get User ID
  ------------------------------------
  FUNCTION get_user_id
  RETURN NUMBER
  IS

  BEGIN
    RETURN g_user_id;
  END get_user_id;

  --2. Get Party organization ID
  ------------------------------------
  FUNCTION get_party_org_id
  RETURN NUMBER
  IS

  BEGIN
    RETURN g_party_org_id;
  END get_party_org_id;


  --3. Get Party Person ID
  ------------------------------------
  FUNCTION get_party_person_id
  RETURN NUMBER
  IS

  BEGIN
    RETURN g_party_person_id;
  END get_party_person_id;

  --4. Set User ID
  ------------------------------------
  PROCEDURE set_user_id
  (
    p_user_id IN NUMBER
  )
  IS

  BEGIN
    g_user_id:=p_user_id;
    --set_fnd_global_user_id();
  END set_user_id;



 --5. Set Party organization ID
  ------------------------------------
  PROCEDURE set_party_org_id
  (
   p_party_org_id IN NUMBER
  )
  IS

  BEGIN
    g_party_org_id:=p_party_org_id ;
  END set_party_org_id;

 --6. Set Party Person ID
  ------------------------------------
  PROCEDURE set_party_person_id
  (
   p_party_person_id IN NUMBER
  )
  IS

  BEGIN
    g_party_person_id:=p_party_person_id ;
    --FND_GLOBAL.party_id:=p_party_person_id ;
  END set_party_person_id;




 --7. Set Context
  ------------------------------------
  PROCEDURE set_ctx
  (
    p_param_name  IN VARCHAR2,
    p_param_value IN NUMBER
  )
  IS

  BEGIN
    IF (p_param_name = 'PARTY_ORG_ID') THEN
       g_party_org_id := p_param_value;
    ELSIF  (p_param_name = 'PARTY_PERSON_ID') THEN
       g_party_person_id := p_param_value;
    ELSIF  (p_param_name = 'USER_ID') THEN
       g_user_id := p_param_value;
       --set_fnd_global_user_id();
    ELSE
      fnd_message.set_name('IPD','IPD_INVALID_PARAMETER');
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       null;

  END set_ctx;

  --8. Get Context
  ------------------------------------
  FUNCTION get_ctx
  (
    p_param_name  IN VARCHAR2
  ) RETURN NUMBER
  IS
  BEGIN
    IF (p_param_name = 'PARTY_ORG_ID') THEN
       RETURN g_party_org_id;
    ELSIF  (p_param_name = 'PARTY_PERSON_ID') THEN
       RETURN g_party_person_id;
    ELSIF  (p_param_name = 'USER_ID') THEN
       RETURN g_user_id;
    ELSE
      fnd_message.set_name('IPD','IPD_INVALID_PARAMETER');
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       null;

  END get_ctx;


 --9. Set Object Name
  ------------------------------------
  PROCEDURE set_object_name
  (
   p_object_name IN VARCHAR2
  )
  IS

  BEGIN
    g_object_name:=p_object_name ;
  END set_object_name;


 --10. Get Object Name
  ------------------------------------
  FUNCTION get_object_name
  RETURN VARCHAR2
  IS

  BEGIN
    RETURN g_object_name;
  END get_object_name;



 --11. Set Object Key
  ------------------------------------
  PROCEDURE set_object_key
  (
   p_object_key IN NUMBER
  )
  IS

  BEGIN
    g_object_key:=p_object_key ;
  END set_object_key;
  ------------------------------------

 --12. Get Object Key
  ------------------------------------
  FUNCTION get_object_key
  RETURN NUMBER
  IS

  BEGIN
    RETURN g_object_key;
  END get_object_key;
  ------------------------------------

  --13. Set Context params
  ------------------------------------
  PROCEDURE set_ctx
  (
    p_param_values  IN VARCHAR2
  )
  IS

  l_name_tbl                         VARCHAR_TBL_TYPE;
  l_value_tbl                        VARCHAR_TBL_TYPE;
  BEGIN

    Parse_Name_Value_Pairs_Msg
       ( p_message     => p_param_values,
         x_name_tbl  => l_name_tbl,
         x_value_tbl => l_value_tbl
       );

    IF ( l_name_tbl.count > 0) THEN
      FOR i IN l_name_tbl.first .. l_name_tbl.last LOOP
        IF( l_name_tbl(i) = G_USER_ID_NAME ) THEN
             g_user_id := to_number(l_value_tbl(i));
        ELSIF (l_name_tbl(i) =G_PARTY_PERSON_ID_NAME ) THEN
          g_party_person_id := to_number(l_value_tbl(i));
        ELSIF (l_name_tbl(i) =G_PARTY_ORG_ID_NAME ) THEN
          g_party_org_id := to_number(l_value_tbl(i));
        ELSIF (l_name_tbl(i) =G_LANGUAGE_NAME ) THEN
           IF(userenv('LANG') <> l_value_tbl(i)) THEN
              set_session_language(p_language=>l_value_tbl(i));
           END IF;
       ELSE
         fnd_message.set_name('IPD','IPD_INVALID_PARAMETER');
         fnd_msg_pub.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END LOOP;
   END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       null;

  END set_ctx;
  -----------------------------------------------




  --14. Set Session Language
  ------------------------------------
  PROCEDURE set_session_language
  (
     p_language in varchar2
  )
  IS
  l_dynamic_sql  varchar2(200);
  l_nls_lang     varchar2(30);
  CURSOR get_nls_language(cp_lang_code varchar2)
  IS
    SELECT nls_language
    FROM fnd_languages
    WHERE language_code=cp_lang_code;

  BEGIN
    IF(userenv('LANG') = p_language) THEN
      RETURN;
    END IF;
    OPEN  get_nls_language(cp_lang_code=>p_language);
    FETCH get_nls_language INTO l_nls_lang;
    CLOSE get_nls_language;
    l_dynamic_sql:='alter session set NLS_LANGUAGE ='''||l_nls_lang||'''';
    EXECUTE IMMEDIATE l_dynamic_sql;
  END set_session_language;
------------------------------------


END EGO_SCTX ;

/
