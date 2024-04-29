--------------------------------------------------------
--  DDL for Package Body IBC_CITEM_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CITEM_VERSIONS_PKG" AS
/* $Header: ibctcivb.pls 120.7.12010000.1 2008/07/28 11:02:22 appldev ship $*/

-- Purpose: Table Handler for Ibc_Citem_Versions table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002  Created Package
-- shitij.vatsa      11/04/2002  Updated for FND_API.G_MISS_XXX
-- shitij.vatsa      02/11/2003  Added parameter p_subitem_version_id
--                               to the APIs
-- Ed Nunez          08/14/2003  Content Item Name Uniqueness
-- Ed Nunez          09/19/2003  Content Item Name accross folder and items
-- Ed Nunez          03/09/2004  Gettid rid of enforcing unique name accross versions
-- shitij.vatsa      05/03/2004  Updated the Update_Row API to update the TL table
--                               in two phases once for the installed language
--                               and once for both the installed and the source language.
--                               Bug Fix:3589057
-- shitij.vatsa      05/04/2004  Added a new API-
--                               populate_all_attachments
--                               Bug Fix:3597752
-- Subir Anshumali   03/11/2005  Added TEXTIDX = 'X' in update_row.
--                               Also, added SYNC_INDEX.
-- Subir Anshumali   06/03/2005  Declared OUT and IN OUT arguments as references using the NOCOPY hint.
--                               Also commented logic of TEXTIDX as of now.
--                               To add this again once we do intermedia search using userdatastore.
-- Sri.Rangarajan    06/29/2005  Enhancement Bug 3664840 Content Item Name should be the same across
--                               all versions for that language.
-- SHARMA 	     07/04/2005	 Modified LOAD_ROW, TRANSLATE_ROW and created
-- 			         LOAD_SEED_ROW for R12 LCT standards bug 4411674
-- Sri.Rangarajan    08/20/2005  Added TEXTIDX = 'X' in update_row.Added concurrent request
--				 to sync Content Text indexes


  G_PKG_NAME  CONSTANT VARCHAR2(100)  := 'IBC_CITEM_VERSIONS_PKG';


PROCEDURE INSERT_ROW (
 x_rowid                           OUT NOCOPY VARCHAR2
,px_citem_version_id               IN OUT NOCOPY NUMBER
,p_content_item_id                 IN NUMBER
,p_version_number                  IN NUMBER
,p_citem_version_status            IN VARCHAR2
,p_start_date                      IN DATE
,p_end_date                        IN DATE
,px_object_version_number          IN OUT NOCOPY NUMBER
,p_attribute_file_id               IN NUMBER
,p_attachment_attribute_code       IN VARCHAR2
,p_attachment_file_id              IN NUMBER
,p_content_item_name               IN VARCHAR2
,p_attachment_file_name            IN VARCHAR2      --DEFAULT NULL
,p_description                     IN VARCHAR2
,p_default_rendition_mime_type     IN VARCHAR2      --DEFAULT NULL
,p_creation_date                   IN DATE          --DEFAULT NULL
,p_created_by                      IN NUMBER        --DEFAULT NULL
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
,p_citem_translation_status        IN VARCHAR2      --DEFAULT NULL
)
IS
  CURSOR C IS SELECT ROWID FROM IBC_CITEM_VERSIONS_B
    WHERE CITEM_VERSION_ID = px_CITEM_VERSION_ID;

  CURSOR c2 IS SELECT ibc_citem_versions_s1.NEXTVAL FROM dual;

  CURSOR c_citem_dirnode(p_content_item_id NUMBER)
  IS
  SELECT directory_node_id
    FROM ibc_content_items citems
   WHERE content_item_id = p_content_item_id;


  l_dirnode     NUMBER;
  G_API_NAME    CONSTANT VARCHAR2(30) := 'INSERT_ROW';
  l_object_type VARCHAR2(30);
  l_object_id   NUMBER;

BEGIN

  -- Validation of Unique Name in a particular directory for a especific
  -- Language.
  OPEN c_citem_dirnode(p_content_item_id);
  FETCH c_citem_dirnode INTO l_dirnode;
  CLOSE c_citem_dirnode;

--  IF IBC_UTILITIES_PVT.is_name_already_used(p_dir_node_id => l_dirnode,
--                                            p_name        => p_content_item_name,
--                                            p_language    => USERENV('lang'),
--                                            p_chk_content_item_id => p_content_item_id,
--                                                                                        x_object_type => l_object_type,
--                                                                                        x_object_id   => l_object_id)
--  THEN
--    IF l_object_type = 'DIRNODE' THEN
--      Fnd_Message.Set_Name('IBC', 'IBC_NAME_ALREADY_FOLDER');
--    ELSE
--      Fnd_Message.Set_Name('IBC', 'IBC_CITEM_NAME_UNIQUE');
--      Fnd_Message.Set_token('NEW_ITEM_NAME' , p_content_item_name);
--      Fnd_Message.Set_token('CONFLICTING_ITEM_NAME' , IBC_UTILITIES_PVT.get_citem_name(l_object_id));
--    END IF;
--    Fnd_Msg_Pub.ADD;
--    RAISE Fnd_Api.G_EXC_ERROR;
--  END IF;


  Ibc_Content_Items_Pkg.UPDATE_ROW (
    p_CONTENT_ITEM_ID      =>p_CONTENT_ITEM_ID
    ,px_OBJECT_VERSION_NUMBER   =>px_object_version_number
    ,p_last_updated_by    =>p_last_updated_by);


  -- Primary key validation check

  IF ((px_CITEM_VERSION_ID IS NULL) OR
      (px_CITEM_VERSION_ID = Fnd_Api.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO px_CITEM_VERSION_ID;
    CLOSE c2;
  END IF;

  INSERT INTO IBC_CITEM_VERSIONS_B (
    CITEM_VERSION_ID,
    CONTENT_ITEM_ID,
    VERSION_NUMBER,
    CITEM_VERSION_STATUS,
    START_DATE,
    END_DATE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
     DECODE(px_citem_version_id,FND_API.G_MISS_NUM,NULL,px_citem_version_id)
    ,DECODE(p_content_item_id,FND_API.G_MISS_NUM,NULL,p_content_item_id)
    ,DECODE(p_version_number,FND_API.G_MISS_NUM,NULL,p_version_number)
    ,DECODE(p_citem_version_status,FND_API.G_MISS_CHAR,NULL,p_citem_version_status)
    ,DECODE(p_start_date,FND_API.G_MISS_DATE,NULL,p_start_date)
    ,DECODE(p_end_date,FND_API.G_MISS_DATE,NULL,p_end_date)
    ,DECODE(px_object_version_number,FND_API.G_MISS_NUM,1,NULL,1,px_object_version_number)
    ,DECODE(p_creation_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_creation_date)
    ,DECODE(p_created_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_created_by)
    ,DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
    ,DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
    );

  INSERT INTO IBC_CITEM_VERSIONS_TL (
    CITEM_VERSION_ID,
    ATTRIBUTE_FILE_ID,
    ATTACHMENT_ATTRIBUTE_CODE,
    CONTENT_ITEM_NAME,
    ATTACHMENT_FILE_ID,
    ATTACHMENT_FILE_NAME,
    DESCRIPTION,
    DEFAULT_RENDITION_MIME_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    CITEM_TRANSLATION_STATUS
  ) SELECT
     DECODE(px_citem_version_id,FND_API.G_MISS_NUM,NULL,px_citem_version_id)
    ,DECODE(p_attribute_file_id,FND_API.G_MISS_NUM,NULL,p_attribute_file_id)
    ,DECODE(p_attachment_attribute_code,FND_API.G_MISS_CHAR,NULL,p_attachment_attribute_code)
    ,DECODE(p_content_item_name,FND_API.G_MISS_CHAR,NULL,p_content_item_name)
    ,DECODE(p_attachment_file_id,FND_API.G_MISS_NUM,NULL,p_attachment_file_id)
    ,DECODE(p_attachment_file_name,FND_API.G_MISS_CHAR,NULL,p_attachment_file_name)
    ,DECODE(p_description,FND_API.G_MISS_CHAR,NULL,p_description)
    ,DECODE(p_default_rendition_mime_type,FND_API.G_MISS_CHAR,NULL,p_default_rendition_mime_type)
    ,DECODE(p_creation_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_creation_date)
    ,DECODE(p_created_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_created_by)
    ,DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
    ,DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
    ,L.LANGUAGE_CODE
    ,USERENV('LANG')
    ,DECODE(p_citem_translation_status,FND_API.G_MISS_CHAR,NULL,p_citem_translation_status)
  FROM FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM IBC_CITEM_VERSIONS_TL T
    WHERE T.CITEM_VERSION_ID = px_CITEM_VERSION_ID
    AND T.LANGUAGE = L.LANGUAGE_CODE);

  OPEN c;
  FETCH c INTO x_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

  /*
  Due to new requirement (03-09-2004) Same name accross versions is
  not being enforced anymore -- Reverted
  */

  -- Reverting back the previous change. In R12 Enhancement Bug 3664840 Content Item Name should be the same
  -- across all versions for that language

  -- Update Content Item Name for all versions of current language
     UPDATE IBC_CITEM_VERSIONS_TL
     SET CONTENT_ITEM_NAME = DECODE(p_content_item_name,Fnd_Api.G_MISS_CHAR,NULL,NULL,content_item_name,p_content_item_name)
   	 WHERE citem_version_id IN (SELECT citem_version_id
                   FROM IBC_CITEM_VERSIONS_B verb
                  WHERE verb.content_item_id = p_content_item_id);


END INSERT_ROW;

PROCEDURE POPULATE_ALL_LANG (
  p_CITEM_VERSION_ID IN NUMBER,
  p_CONTENT_ITEM_ID IN NUMBER,
  p_VERSION_NUMBER IN NUMBER,
  p_CITEM_VERSION_STATUS IN VARCHAR2,
  p_START_DATE IN DATE,
  p_END_DATE IN DATE,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_ATTRIBUTE_FILE_ID IN NUMBER,
  p_ATTACHMENT_ATTRIBUTE_CODE IN VARCHAR2,
  P_SOURCE_LANG   IN VARCHAR2 ,--DEFAULT USERENV('LANG'),
  p_ATTACHMENT_FILE_ID IN NUMBER,
  p_CONTENT_ITEM_NAME IN VARCHAR2,
  p_ATTACHMENT_FILE_NAME IN VARCHAR2,
  p_DESCRIPTION IN VARCHAR2,
  p_DEFAULT_RENDITION_MIME_TYPE   IN VARCHAR2 ,--DEFAULT NULL,
  p_CREATION_DATE IN DATE      ,--DEFAULT NULL,
  p_CREATED_BY IN NUMBER     ,--DEFAULT NULL,
  p_LAST_UPDATE_DATE IN DATE    ,--DEFAULT NULL,
  p_LAST_UPDATED_BY IN NUMBER   ,--DEFAULT NULL,
  p_LAST_UPDATE_LOGIN IN NUMBER  ,--DEFAULT NULL,
  p_CITEM_TRANSLATION_STATUS  IN VARCHAR2  --DEFAULT NULL
)
IS


  CURSOR c_prev_version(p_content_item_id NUMBER,
                        p_citem_version_id NUMBER)
  IS
    SELECT citem_version_id
      FROM ibc_citem_versions_b
     WHERE content_item_id = p_content_item_id
       AND version_number < (SELECT version_number
                               FROM ibc_citem_versions_b
                              WHERE content_item_id = p_content_item_id
                                AND citem_version_id = p_citem_version_id)
     ORDER BY version_number desc;

  CURSOR c_citem_dirnode(p_content_item_id NUMBER)
  IS
  SELECT directory_node_id
    FROM ibc_content_items citems
   WHERE content_item_id = p_content_item_id;

  l_prev_version_id NUMBER;
  l_dirnode    NUMBER;
  l_object_type VARCHAR2(30);
  l_object_id   NUMBER;

BEGIN

  -- Validation of Unique Name in a particular directory for all languages
  OPEN c_citem_dirnode(p_content_item_id);
  FETCH c_citem_dirnode INTO l_dirnode;
  CLOSE c_citem_dirnode;

  IF IBC_UTILITIES_PVT.is_name_already_used(p_dir_node_id => l_dirnode,
                                            p_name        => p_content_item_name,
                                            p_language    => USERENV('lang'),
                                            p_chk_content_item_id => p_content_item_id,
                                                                                        x_object_type => l_object_type,
                                                                                        x_object_id   => l_object_id)
  THEN
    IF l_object_type = 'DIRNODE' THEN
      Fnd_Message.Set_Name('IBC', 'IBC_NAME_ALREADY_FOLDER');
    ELSE
      Fnd_Message.Set_Name('IBC', 'IBC_CITEM_NAME_UNIQUE');
      Fnd_Message.Set_token('NEW_ITEM_NAME' , p_content_item_name);
      Fnd_Message.Set_token('CONFLICTING_ITEM_NAME' , IBC_UTILITIES_PVT.get_citem_name(l_object_id));
    END IF;
    Fnd_Msg_Pub.ADD;
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;


  IF p_version_number > 1 THEN
    -- Copy Translations from previous version
    OPEN  c_prev_version(p_content_item_id, p_citem_version_id);
    FETCH c_prev_version INTO l_prev_version_id;
    IF c_prev_version%FOUND THEN

      INSERT INTO IBC_CITEM_VERSIONS_TL (
        CITEM_VERSION_ID,
        ATTRIBUTE_FILE_ID,
        ATTACHMENT_ATTRIBUTE_CODE,
        CONTENT_ITEM_NAME,
        ATTACHMENT_FILE_ID,
        ATTACHMENT_FILE_NAME,
        DESCRIPTION,
        DEFAULT_RENDITION_MIME_TYPE,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LANGUAGE,
        SOURCE_LANG,
        CITEM_TRANSLATION_STATUS
      ) SELECT DECODE(p_CITEM_VERSION_ID,Fnd_Api.G_MISS_NUM,NULL,p_CITEM_VERSION_ID),
               L.attribute_file_id,
               L.attachment_attribute_code,
               L.content_item_name,
               L.attachment_file_id,
               L.attachment_file_name,
               L.description,
               L.default_rendition_mime_type,
               DECODE(p_creation_date, Fnd_Api.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
                      p_creation_date) ,
               DECODE(p_created_by, Fnd_Api.G_MISS_NUM, Fnd_Global.user_id,
                      NULL, Fnd_Global.user_id, p_created_by),
               DECODE(p_last_update_date, Fnd_Api.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
                      p_last_update_date),
               DECODE(p_last_updated_by, Fnd_Api.G_MISS_NUM, Fnd_Global.user_id,
                      NULL, Fnd_Global.user_id, p_last_updated_by),
               DECODE(p_last_update_login, Fnd_Api.G_MISS_NUM, Fnd_Global.login_id,
                      NULL, Fnd_Global.login_id, p_last_update_login),
               language,
               DECODE(P_SOURCE_LANG, Fnd_Api.G_MISS_CHAR,USERENV('LANG'), NULL, USERENV('LANG'),P_SOURCE_LANG),
               DECODE(p_CITEM_TRANSLATION_STATUS,Fnd_Api.G_MISS_CHAR,NULL,p_CITEM_TRANSLATION_STATUS)
          FROM ibc_citem_versions_tl L
         WHERE L.citem_version_id = l_prev_version_id
           AND NOT EXISTS
              (SELECT NULL
                 FROM IBC_CITEM_VERSIONS_TL T
                WHERE T.CITEM_VERSION_ID = p_CITEM_VERSION_ID
                  AND T.LANGUAGE = L.LANGUAGE);

    END IF;
    CLOSE c_prev_version;
  END IF;

  INSERT INTO IBC_CITEM_VERSIONS_TL (
    CITEM_VERSION_ID,
    ATTRIBUTE_FILE_ID,
    ATTACHMENT_ATTRIBUTE_CODE,
    CONTENT_ITEM_NAME,
    ATTACHMENT_FILE_ID,
    ATTACHMENT_FILE_NAME,
    DESCRIPTION,
    DEFAULT_RENDITION_MIME_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    CITEM_TRANSLATION_STATUS
  ) SELECT
    DECODE(p_CITEM_VERSION_ID,Fnd_Api.G_MISS_NUM,NULL,p_CITEM_VERSION_ID),
    DECODE(p_ATTRIBUTE_FILE_ID,Fnd_Api.G_MISS_NUM,NULL,p_ATTRIBUTE_FILE_ID),
    DECODE(p_ATTACHMENT_ATTRIBUTE_CODE,Fnd_Api.G_MISS_CHAR,NULL,p_ATTACHMENT_ATTRIBUTE_CODE),
    DECODE(p_CONTENT_ITEM_NAME,Fnd_Api.G_MISS_CHAR,NULL,p_CONTENT_ITEM_NAME),
    DECODE(p_ATTACHMENT_FILE_ID,Fnd_Api.G_MISS_NUM,NULL,p_ATTACHMENT_FILE_ID),
    DECODE(p_ATTACHMENT_FILE_NAME,Fnd_Api.G_MISS_CHAR,NULL,p_ATTACHMENT_FILE_NAME),
    DECODE(p_DESCRIPTION,Fnd_Api.G_MISS_CHAR,NULL,p_DESCRIPTION),
    DECODE(p_DEFAULT_RENDITION_MIME_TYPE,Fnd_Api.G_MISS_CHAR,NULL,p_DEFAULT_RENDITION_MIME_TYPE),
    DECODE(p_creation_date, Fnd_Api.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
           p_creation_date) ,
    DECODE(p_created_by, Fnd_Api.G_MISS_NUM, Fnd_Global.user_id,
           NULL, Fnd_Global.user_id, p_created_by),
    DECODE(p_last_update_date, Fnd_Api.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
           p_last_update_date),
    DECODE(p_last_updated_by, Fnd_Api.G_MISS_NUM, Fnd_Global.user_id,
           NULL, Fnd_Global.user_id, p_last_updated_by),
    DECODE(p_last_update_login, Fnd_Api.G_MISS_NUM, Fnd_Global.login_id,
           NULL, Fnd_Global.login_id, p_last_update_login),
    L.LANGUAGE_CODE,
    DECODE(P_SOURCE_LANG, Fnd_Api.G_MISS_CHAR,USERENV('LANG'), NULL, USERENV('LANG'),P_SOURCE_LANG),
    DECODE(p_CITEM_TRANSLATION_STATUS,Fnd_Api.G_MISS_CHAR,NULL,p_CITEM_TRANSLATION_STATUS)
  FROM FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM IBC_CITEM_VERSIONS_TL T
    WHERE T.CITEM_VERSION_ID = p_CITEM_VERSION_ID
    AND T.LANGUAGE = L.LANGUAGE_CODE);

  -- Added by svatsa
  populate_attachments (p_citem_version_id => p_CITEM_VERSION_ID
                       ,p_base_lang        => P_SOURCE_LANG
                       );

END POPULATE_ALL_LANG;


PROCEDURE INSERT_BASE_LANG (
  x_ROWID  OUT NOCOPY VARCHAR2,
  px_CITEM_VERSION_ID IN OUT NOCOPY NUMBER,
  p_CONTENT_ITEM_ID IN NUMBER,
  p_VERSION_NUMBER IN NUMBER,
  p_CITEM_VERSION_STATUS IN VARCHAR2,
  p_START_DATE IN DATE,
  p_END_DATE IN DATE,
  px_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER,
  p_ATTRIBUTE_FILE_ID IN NUMBER,
  p_ATTACHMENT_ATTRIBUTE_CODE IN VARCHAR2,
  P_SOURCE_LANG   IN VARCHAR2 ,--DEFAULT USERENV('LANG'),
  p_ATTACHMENT_FILE_ID IN NUMBER ,--DEFAULT NULL,
  p_CONTENT_ITEM_NAME IN VARCHAR2,
  p_ATTACHMENT_FILE_NAME IN VARCHAR2  ,--DEFAULT NULL,
  p_DESCRIPTION IN VARCHAR2,
  p_DEFAULT_RENDITION_MIME_TYPE   IN VARCHAR2 ,--DEFAULT NULL,
  p_CREATION_DATE IN DATE      ,--DEFAULT NULL,
  p_CREATED_BY IN NUMBER     ,--DEFAULT NULL,
  p_LAST_UPDATE_DATE IN DATE    ,--DEFAULT NULL,
  p_LAST_UPDATED_BY IN NUMBER   ,--DEFAULT NULL,
  p_LAST_UPDATE_LOGIN IN NUMBER  ,--DEFAULT NULL,
  p_CITEM_TRANSLATION_STATUS  IN VARCHAR2  --DEFAULT NULL
  )


IS
  CURSOR C IS SELECT ROWID FROM IBC_CITEM_VERSIONS_B
    WHERE CITEM_VERSION_ID = px_CITEM_VERSION_ID;
  CURSOR c2 IS SELECT ibc_citem_versions_s1.NEXTVAL FROM dual;

  CURSOR c_citem_dirnode(p_content_item_id NUMBER)
  IS
  SELECT directory_node_id
    FROM ibc_content_items citems
   WHERE content_item_id = p_content_item_id;

  l_dirnode     NUMBER;

  l_object_type VARCHAR2(30);
  l_object_id   NUMBER;

  G_API_NAME    CONSTANT VARCHAR2(30) := 'INSERT_BASE_LANG';

BEGIN

  OPEN c_citem_dirnode(p_content_item_id);
  FETCH c_citem_dirnode INTO l_dirnode;
  CLOSE c_citem_dirnode;

  IF IBC_UTILITIES_PVT.is_name_already_used(p_dir_node_id => l_dirnode,
                                            p_name        => p_content_item_name,
                                            p_language    => USERENV('lang'),
                                            p_chk_content_item_id => p_content_item_id,
                                                                                        x_object_type => l_object_type,
                                                                                        x_object_id   => l_object_id)
  THEN
    IF l_object_type = 'DIRNODE' THEN
      Fnd_Message.Set_Name('IBC', 'IBC_NAME_ALREADY_FOLDER');
    ELSE
      Fnd_Message.Set_Name('IBC', 'IBC_CITEM_NAME_UNIQUE');
      Fnd_Message.Set_token('NEW_ITEM_NAME' , p_content_item_name);
      Fnd_Message.Set_token('CONFLICTING_ITEM_NAME' , IBC_UTILITIES_PVT.get_citem_name(l_object_id));
    END IF;
    Fnd_Msg_Pub.ADD;
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;


  Ibc_Content_Items_Pkg.UPDATE_ROW (
    p_CONTENT_ITEM_ID      =>p_CONTENT_ITEM_ID
    ,px_OBJECT_VERSION_NUMBER   =>px_object_version_number
    ,p_last_updated_by    =>p_last_updated_by);

  -- Primary key validation check

  IF ((px_CITEM_VERSION_ID IS NULL) OR
      (px_CITEM_VERSION_ID = Fnd_Api.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO px_CITEM_VERSION_ID;
    CLOSE c2;
  END IF;

  INSERT INTO IBC_CITEM_VERSIONS_B (
    CITEM_VERSION_ID,
    CONTENT_ITEM_ID,
    VERSION_NUMBER,
    CITEM_VERSION_STATUS,
    START_DATE,
    END_DATE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    DECODE(px_CITEM_VERSION_ID,Fnd_Api.G_MISS_NUM,NULL,px_CITEM_VERSION_ID),
    DECODE(p_CONTENT_ITEM_ID,Fnd_Api.G_MISS_NUM,NULL,p_CONTENT_ITEM_ID),
    DECODE(p_VERSION_NUMBER,Fnd_Api.G_MISS_NUM,NULL,p_VERSION_NUMBER),
    DECODE(p_CITEM_VERSION_STATUS,Fnd_Api.G_MISS_CHAR,NULL,p_CITEM_VERSION_STATUS),
    DECODE(p_START_DATE,Fnd_Api.G_MISS_DATE,NULL,p_START_DATE),
    DECODE(p_END_DATE,Fnd_Api.G_MISS_DATE,NULL,p_END_DATE),
    DECODE(px_OBJECT_VERSION_NUMBER,Fnd_Api.G_MISS_NUM,1,px_OBJECT_VERSION_NUMBER),
    DECODE(p_creation_date, Fnd_Api.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
           p_creation_date),
    DECODE(p_created_by, Fnd_Api.G_MISS_NUM, Fnd_Global.user_id,
           NULL, Fnd_Global.user_id, p_created_by),
    DECODE(p_last_update_date, Fnd_Api.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
           p_last_update_date),
    DECODE(p_last_updated_by, Fnd_Api.G_MISS_NUM, Fnd_Global.user_id,
           NULL, Fnd_Global.user_id, p_last_updated_by),
    DECODE(p_last_update_login, Fnd_Api.G_MISS_NUM, Fnd_Global.login_id,
           NULL, Fnd_Global.login_id, p_last_update_login)
     );

  INSERT INTO IBC_CITEM_VERSIONS_TL (
    CITEM_VERSION_ID,
    ATTRIBUTE_FILE_ID,
    ATTACHMENT_ATTRIBUTE_CODE,
    CONTENT_ITEM_NAME,
    ATTACHMENT_FILE_ID,
    ATTACHMENT_FILE_NAME,
    DESCRIPTION,
    DEFAULT_RENDITION_MIME_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    CITEM_TRANSLATION_STATUS
  ) VALUES (
    DECODE(px_CITEM_VERSION_ID,Fnd_Api.G_MISS_NUM,NULL,px_CITEM_VERSION_ID),
    DECODE(p_ATTRIBUTE_FILE_ID,Fnd_Api.G_MISS_NUM,NULL,p_ATTRIBUTE_FILE_ID),
    DECODE(p_ATTACHMENT_ATTRIBUTE_CODE,Fnd_Api.G_MISS_CHAR,NULL,p_ATTACHMENT_ATTRIBUTE_CODE),
    DECODE(p_CONTENT_ITEM_NAME,Fnd_Api.G_MISS_CHAR,NULL,p_CONTENT_ITEM_NAME),
    DECODE(p_ATTACHMENT_FILE_ID,Fnd_Api.G_MISS_NUM,NULL,p_ATTACHMENT_FILE_ID),
    DECODE(p_ATTACHMENT_FILE_NAME,Fnd_Api.G_MISS_CHAR,NULL,p_ATTACHMENT_FILE_NAME),
    DECODE(p_DESCRIPTION,Fnd_Api.G_MISS_CHAR,NULL,p_DESCRIPTION),
    DECODE(p_DEFAULT_RENDITION_MIME_TYPE,Fnd_Api.G_MISS_CHAR,NULL,p_DEFAULT_RENDITION_MIME_TYPE),
    DECODE(p_creation_date, Fnd_Api.G_MISS_DATE, SYSDATE, NULL, SYSDATE,p_creation_date) ,
    DECODE(p_created_by, Fnd_Api.G_MISS_NUM, Fnd_Global.user_id,
           NULL, Fnd_Global.user_id, p_created_by),
    DECODE(p_last_update_date, Fnd_Api.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
           p_last_update_date),
    DECODE(p_last_updated_by, Fnd_Api.G_MISS_NUM, Fnd_Global.user_id,
           NULL, Fnd_Global.user_id, p_last_updated_by),
    DECODE(p_last_update_login, Fnd_Api.G_MISS_NUM, Fnd_Global.login_id,
           NULL, Fnd_Global.login_id, p_last_update_login),
 DECODE(P_SOURCE_LANG, Fnd_Api.G_MISS_CHAR,USERENV('LANG'), NULL, USERENV('LANG'),P_SOURCE_LANG),
 DECODE(P_SOURCE_LANG, Fnd_Api.G_MISS_CHAR,USERENV('LANG'), NULL, USERENV('LANG'),P_SOURCE_LANG),
 DECODE(p_CITEM_TRANSLATION_STATUS,Fnd_Api.G_MISS_CHAR,NULL,p_CITEM_TRANSLATION_STATUS)
 );

  OPEN c;
  FETCH c INTO x_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
     Fnd_Message.Set_Name('IBC', 'IBC_ERROR_RETURNED');
        Fnd_Message.Set_token('PKG_NAME' , G_pkg_name);
        Fnd_Message.Set_token('API_NAME' , G_api_name);
        Fnd_Msg_Pub.ADD;
  RAISE Fnd_Api.G_EXC_ERROR;
  --RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

 /*
  Due to new requirement (03-09-2004) Same name accross versions is
  not being enforced anymore -- Reverted
  */

  -- Reverting back the previous change. In R12 Enhancement Bug 3664840 Content Item Name should be the same
  -- across all versions for that language

  -- Update Content Item Name for all versions of current language
     UPDATE IBC_CITEM_VERSIONS_TL
     SET CONTENT_ITEM_NAME = DECODE(p_content_item_name,Fnd_Api.G_MISS_CHAR,NULL,NULL,content_item_name,p_content_item_name)
   	 WHERE citem_version_id IN (SELECT citem_version_id
                   FROM IBC_CITEM_VERSIONS_B verb
                  WHERE verb.content_item_id = p_content_item_id);

END INSERT_BASE_LANG;

PROCEDURE LOCK_ROW (
  p_CITEM_VERSION_ID IN NUMBER,
  p_CONTENT_ITEM_ID IN NUMBER,
  p_VERSION_NUMBER IN NUMBER,
  p_CITEM_VERSION_STATUS IN VARCHAR2,
  p_START_DATE IN DATE,
  p_END_DATE IN DATE,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_ATTRIBUTE_FILE_ID IN NUMBER,
  p_ATTACHMENT_FILE_ID IN NUMBER,
  p_CONTENT_ITEM_NAME IN VARCHAR2,
  p_ATTACHMENT_FILE_NAME IN VARCHAR2,
  p_DESCRIPTION IN VARCHAR2
) IS
  CURSOR c IS SELECT
      CONTENT_ITEM_ID,
      VERSION_NUMBER,
      CITEM_VERSION_STATUS,
      START_DATE,
      END_DATE,
      OBJECT_VERSION_NUMBER
    FROM IBC_CITEM_VERSIONS_B
    WHERE CITEM_VERSION_ID = p_CITEM_VERSION_ID
    FOR UPDATE OF CITEM_VERSION_ID NOWAIT;
  recinfo c%ROWTYPE;

  CURSOR c1 IS SELECT
      ATTRIBUTE_FILE_ID,
      CONTENT_ITEM_NAME,
      DESCRIPTION,
      DECODE(LANGUAGE, USERENV('LANG'), 'Y', 'N') BASELANG
    FROM IBC_CITEM_VERSIONS_TL
    WHERE CITEM_VERSION_ID = p_CITEM_VERSION_ID
    AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG)
    FOR UPDATE OF CITEM_VERSION_ID NOWAIT;
BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    Fnd_Message.set_name('FND', 'FORM_RECORD_DELETED');
    App_Exception.raise_exception;
  END IF;
  CLOSE c;
  IF (    (recinfo.CONTENT_ITEM_ID = p_CONTENT_ITEM_ID)
      AND (recinfo.VERSION_NUMBER = p_VERSION_NUMBER)
      AND ((recinfo.CITEM_VERSION_STATUS = p_CITEM_VERSION_STATUS)
           OR ((recinfo.CITEM_VERSION_STATUS IS NULL) AND (p_CITEM_VERSION_STATUS IS NULL)))
      AND ((recinfo.START_DATE = p_START_DATE)
           OR ((recinfo.START_DATE IS NULL) AND (p_START_DATE IS NULL)))
      AND ((recinfo.END_DATE = p_END_DATE)
           OR ((recinfo.END_DATE IS NULL) AND (p_END_DATE IS NULL)))
      AND (recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER))
  THEN
    NULL;
  ELSE
    Fnd_Message.set_name('FND', 'FORM_RECORD_CHANGED');
    App_Exception.raise_exception;
  END IF;

  FOR tlinfo IN c1 LOOP
    IF (tlinfo.BASELANG = 'Y') THEN
      IF (    (tlinfo.ATTRIBUTE_FILE_ID = p_ATTRIBUTE_FILE_ID)
          AND (tlinfo.CONTENT_ITEM_NAME = p_CONTENT_ITEM_NAME)
          AND ((tlinfo.DESCRIPTION = p_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION IS NULL) AND (p_DESCRIPTION IS NULL)))
      ) THEN
        NULL;
      ELSE
        Fnd_Message.set_name('FND', 'FORM_RECORD_CHANGED');
        App_Exception.raise_exception;
      END IF;
    END IF;
  END LOOP;
  RETURN;
END LOCK_ROW;

PROCEDURE UPDATE_ROW (
 p_citem_version_id                IN NUMBER
,p_content_item_id                 IN NUMBER        --DEFAULT NULL
,p_source_lang                     IN VARCHAR2      --DEFAULT USERENV('LANG')
,p_version_number                  IN NUMBER        --DEFAULT NULL
,p_citem_version_status            IN VARCHAR2      --DEFAULT NULL
,p_attachment_attribute_code       IN VARCHAR2      --DEFAULT NULL
,p_start_date                      IN DATE          --DEFAULT NULL
,p_end_date                        IN DATE          --DEFAULT NULL
,px_object_version_number          IN OUT NOCOPY NUMBER
,p_attribute_file_id               IN NUMBER        --DEFAULT NULL
,p_attachment_file_id              IN NUMBER        --DEFAULT NULL
,p_content_item_name               IN VARCHAR2      --DEFAULT NULL
,p_attachment_file_name            IN VARCHAR2      --DEFAULT NULL
,p_description                     IN VARCHAR2      --DEFAULT NULL
,p_default_rendition_mime_type     IN VARCHAR2      --DEFAULT NULL
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
,p_citem_translation_status        IN VARCHAR2      --DEFAULT NULL
)
IS

  CURSOR c_citem_dirnode(p_content_item_id NUMBER)
  IS
  SELECT directory_node_id
    FROM ibc_content_items citems
   WHERE content_item_id = p_content_item_id;

  l_dirnode     NUMBER;

  l_object_type VARCHAR2(30);
  l_object_id   NUMBER;

  G_API_NAME    CONSTANT VARCHAR2(100) := 'UPDATE_ROW';

BEGIN

  -- Validation of Unique Name in a particular directory for a especific
  -- Language.
  OPEN c_citem_dirnode(p_content_item_id);
  FETCH c_citem_dirnode INTO l_dirnode;
  CLOSE c_citem_dirnode;

  IF IBC_UTILITIES_PVT.is_name_already_used(p_dir_node_id => l_dirnode,
                                            p_name        => p_content_item_name,
                                            p_language    => USERENV('lang'),
                                            p_chk_content_item_id => p_content_item_id,
                                                                                        x_object_type => l_object_type,
                                                                                        x_object_id   => l_object_id)
  THEN
    IF l_object_type = 'DIRNODE' THEN
      Fnd_Message.Set_Name('IBC', 'IBC_NAME_ALREADY_FOLDER');
    ELSE
      Fnd_Message.Set_Name('IBC', 'IBC_CITEM_NAME_UNIQUE');
      Fnd_Message.Set_token('NEW_ITEM_NAME' , p_content_item_name);
      Fnd_Message.Set_token('CONFLICTING_ITEM_NAME' , IBC_UTILITIES_PVT.get_citem_name(l_object_id));
    END IF;
    Fnd_Msg_Pub.ADD;
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;


Ibc_Content_Items_Pkg.UPDATE_ROW (
  p_CONTENT_ITEM_ID      =>p_CONTENT_ITEM_ID
  ,px_OBJECT_VERSION_NUMBER   =>px_object_version_number
  ,p_last_updated_by    =>p_last_updated_by);


  UPDATE IBC_CITEM_VERSIONS_B SET
    content_item_id           = DECODE(p_content_item_id,FND_API.G_MISS_NUM,NULL,NULL,content_item_id,p_content_item_id)
   ,version_number            = DECODE(p_version_number,FND_API.G_MISS_NUM,NULL,NULL,version_number,p_version_number)
   ,citem_version_status      = DECODE(p_citem_version_status,FND_API.G_MISS_CHAR,NULL,NULL,citem_version_status,p_citem_version_status)
   ,start_date                = DECODE(p_start_date,FND_API.G_MISS_DATE,NULL,NULL,start_date,p_start_date)
   ,end_date                  = DECODE(p_end_date,FND_API.G_MISS_DATE,NULL,NULL,end_date,p_end_date)
   ,object_version_number     = px_object_version_number
   ,last_update_date          = DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
   ,last_updated_by           = DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
   ,last_update_login         = DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
  WHERE CITEM_VERSION_ID = p_CITEM_VERSION_ID;

  /*AND object_version_number = DECODE(p_object_version_number,
                                       FND_API.G_MISS_NUM,
                                       object_version_number,
                                       NULL,
                                       object_version_number,
                                       p_object_version_number);*/


  IF (SQL%NOTFOUND) THEN
        Fnd_Message.Set_Name('IBC', 'IBC_ERROR_RETURNED');
        Fnd_Message.Set_token('PKG_NAME' , G_pkg_name);
        Fnd_Message.Set_token('API_NAME' , G_api_name);
        Fnd_Msg_Pub.ADD;
  RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

  --Bug Fix:3589057
  UPDATE IBC_CITEM_VERSIONS_TL SET
     content_item_name           = DECODE(p_content_item_name,FND_API.G_MISS_CHAR,NULL,NULL,content_item_name,p_content_item_name)
    ,description                 = DECODE(p_description,FND_API.G_MISS_CHAR,NULL,NULL,description,p_description)
    ,last_update_date            = DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,last_updated_by             = DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
    ,last_update_login           = DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
    ,source_lang                 = DECODE(p_source_lang,FND_API.G_MISS_CHAR,USERENV('LANG'),NULL,USERENV('LANG'),p_source_lang)
    ,TEXTIDX = 'X'
  WHERE CITEM_VERSION_ID = p_CITEM_VERSION_ID
  AND P_SOURCE_LANG IN (LANGUAGE, SOURCE_LANG);

  IF (SQL%NOTFOUND) THEN
        Fnd_Message.Set_Name('IBC', 'IBC_ERROR_RETURNED');
        Fnd_Message.Set_token('PKG_NAME' , G_pkg_name);
        Fnd_Message.Set_token('API_NAME' , G_api_name);
        Fnd_Msg_Pub.ADD;
  RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

--Bug Fix:3589057
  UPDATE IBC_CITEM_VERSIONS_TL SET
     attribute_file_id           = DECODE(p_attribute_file_id,FND_API.G_MISS_NUM,NULL,NULL,attribute_file_id,p_attribute_file_id)
    ,attachment_file_id          = DECODE(p_attachment_file_id,FND_API.G_MISS_NUM,NULL,NULL,attachment_file_id,p_attachment_file_id)
    ,attachment_file_name        = DECODE(p_attachment_file_name,FND_API.G_MISS_CHAR,NULL,NULL,attachment_file_name,p_attachment_file_name)
    ,attachment_attribute_code   = DECODE(p_attachment_attribute_code,FND_API.G_MISS_CHAR,NULL,NULL,attachment_attribute_code,p_attachment_attribute_code)
    ,default_rendition_mime_type = DECODE(p_default_rendition_mime_type,FND_API.G_MISS_CHAR,NULL,NULL,default_rendition_mime_type,p_default_rendition_mime_type)
    ,citem_translation_status    = DECODE(p_citem_translation_status,FND_API.G_MISS_CHAR,NULL,NULL,citem_translation_status,p_citem_translation_status)
  WHERE CITEM_VERSION_ID = p_CITEM_VERSION_ID
  AND P_SOURCE_LANG IN (LANGUAGE);

  IF (SQL%NOTFOUND) THEN
        Fnd_Message.Set_Name('IBC', 'IBC_ERROR_RETURNED');
        Fnd_Message.Set_token('PKG_NAME' , G_pkg_name);
        Fnd_Message.Set_token('API_NAME' , G_api_name);
        Fnd_Msg_Pub.ADD;
  RAISE Fnd_Api.G_EXC_ERROR;
  END IF;


  /*
  Due to new requirement (03-09-2004) Same name accross versions is
  not being enforced anymore -- Reverted
  */

  -- Reverting back the previous change. In R12 Enhancement Bug 3664840 Content Item Name should be the same
  -- across all versions for that language

  -- Update Content Item Name for all versions of current language
  UPDATE IBC_CITEM_VERSIONS_TL
     SET CONTENT_ITEM_NAME = DECODE(p_content_item_name,FND_API.G_MISS_CHAR,NULL,NULL,content_item_name,p_content_item_name)
   WHERE P_SOURCE_LANG IN (LANGUAGE, SOURCE_LANG)
     AND EXISTS (SELECT 'X'
                   FROM IBC_CITEM_VERSIONS_B verb
                  WHERE verb.content_item_id = p_content_item_id
                    AND IBC_CITEM_VERSIONS_TL.citem_version_id = verb.citem_version_id
                 );

--
-- submits a concurrent request
-- to sync Content Text indexes.
DECLARE
 x_request_id    NUMBER;
 x_return_status VARCHAR2(100);
BEGIN

IBC_CONTENT_SYNC_INDEX_PKG.Request_Content_Sync_Index( x_request_id,x_return_status);

EXCEPTION WHEN OTHERS THEN
	NULL;
END;
--
-- end of submission
--

END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  p_CITEM_VERSION_ID IN NUMBER
) IS

G_API_NAME CONSTANT VARCHAR2(30) := 'DELETE_ROW';

BEGIN
  DELETE FROM IBC_CITEM_VERSIONS_TL
  WHERE CITEM_VERSION_ID = p_CITEM_VERSION_ID;

  IF (SQL%NOTFOUND) THEN
        Fnd_Message.Set_Name('IBC', 'IBC_ERROR_RETURNED');
        Fnd_Message.Set_token('PKG_NAME' , G_pkg_name);
        Fnd_Message.Set_token('API_NAME' , G_api_name);
        Fnd_Msg_Pub.ADD;
  RAISE Fnd_Api.G_EXC_ERROR;
    --RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM IBC_CITEM_VERSIONS_B
  WHERE CITEM_VERSION_ID = p_CITEM_VERSION_ID;

  IF (SQL%NOTFOUND) THEN
        Fnd_Message.Set_Name('IBC', 'IBC_ERROR_RETURNED');
        Fnd_Message.Set_token('PKG_NAME' , G_pkg_name);
        Fnd_Message.Set_token('API_NAME' , G_api_name);
        Fnd_Msg_Pub.ADD;
  RAISE Fnd_Api.G_EXC_ERROR;
    -- RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

PROCEDURE ADD_LANGUAGE
IS
BEGIN
  DELETE FROM IBC_CITEM_VERSIONS_TL T
  WHERE NOT EXISTS
    (SELECT NULL
    FROM IBC_CITEM_VERSIONS_B B
    WHERE B.CITEM_VERSION_ID = T.CITEM_VERSION_ID
    );

  UPDATE IBC_CITEM_VERSIONS_TL T SET (
      ATTACHMENT_ATTRIBUTE_CODE,
      ATTRIBUTE_FILE_ID,
      CONTENT_ITEM_NAME,
      DESCRIPTION,
      ATTACHMENT_FILE_NAME,
      ATTACHMENT_FILE_ID,
      default_rendition_mime_type,
      citem_translation_status
    ) = (SELECT
      B.ATTACHMENT_ATTRIBUTE_CODE,
      B.ATTRIBUTE_FILE_ID,
      B.CONTENT_ITEM_NAME,
      B.DESCRIPTION,
      B.ATTACHMENT_FILE_NAME,
      B.ATTACHMENT_FILE_ID,
      B.default_rendition_mime_type,
      B.citem_translation_status
      FROM IBC_CITEM_VERSIONS_TL B
    WHERE B.CITEM_VERSION_ID = T.CITEM_VERSION_ID
    AND B.LANGUAGE = T.SOURCE_LANG)
  WHERE (
      T.CITEM_VERSION_ID,
      T.LANGUAGE
  ) IN (SELECT
      SUBT.CITEM_VERSION_ID,
      SUBT.LANGUAGE
    FROM IBC_CITEM_VERSIONS_TL SUBB, IBC_CITEM_VERSIONS_TL SUBT
    WHERE SUBB.CITEM_VERSION_ID = SUBT.CITEM_VERSION_ID
    AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
    AND (SUBB.ATTACHMENT_ATTRIBUTE_CODE <> SUBT.ATTACHMENT_ATTRIBUTE_CODE
      OR (SUBB.ATTACHMENT_ATTRIBUTE_CODE IS NULL AND SUBT.ATTACHMENT_ATTRIBUTE_CODE IS NOT NULL)
      OR (SUBB.ATTACHMENT_ATTRIBUTE_CODE IS NOT NULL AND SUBT.ATTACHMENT_ATTRIBUTE_CODE IS NULL)
      OR SUBB.ATTRIBUTE_FILE_ID <> SUBT.ATTRIBUTE_FILE_ID
      OR (SUBB.ATTRIBUTE_FILE_ID IS NULL AND SUBT.ATTRIBUTE_FILE_ID IS NOT NULL)
      OR (SUBB.ATTRIBUTE_FILE_ID IS NOT NULL AND SUBT.ATTRIBUTE_FILE_ID IS NULL)
      OR SUBB.CONTENT_ITEM_NAME <> SUBT.CONTENT_ITEM_NAME
      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
      OR SUBB.ATTACHMENT_FILE_NAME <> SUBT.ATTACHMENT_FILE_NAME
      OR (SUBB.ATTACHMENT_FILE_NAME IS NULL AND SUBT.ATTACHMENT_FILE_NAME IS NOT NULL)
      OR (SUBB.ATTACHMENT_FILE_NAME IS NOT NULL AND SUBT.ATTACHMENT_FILE_NAME IS NULL)
      OR SUBB.ATTACHMENT_FILE_ID <> SUBT.ATTACHMENT_FILE_ID
      OR (SUBB.ATTACHMENT_FILE_ID IS NULL AND SUBT.ATTACHMENT_FILE_ID IS NOT NULL)
      OR (SUBB.ATTACHMENT_FILE_ID IS NOT NULL AND SUBT.ATTACHMENT_FILE_ID IS NULL)
      OR (SUBB.default_rendition_mime_type IS NULL AND SUBT.default_rendition_mime_type IS NOT NULL)
      OR (SUBB.default_rendition_mime_type IS NOT NULL AND SUBT.default_rendition_mime_type IS NULL)
  ));

  INSERT INTO IBC_CITEM_VERSIONS_TL (
    ATTACHMENT_FILE_ID,
    ATTACHMENT_FILE_NAME,
    CITEM_VERSION_ID,
    ATTACHMENT_ATTRIBUTE_CODE,
    ATTRIBUTE_FILE_ID,
    CONTENT_ITEM_NAME,
    default_rendition_mime_type,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG,
    citem_translation_status
  ) SELECT /*+ ORDERED */
    B.ATTACHMENT_FILE_ID,
    B.ATTACHMENT_FILE_NAME,
    B.CITEM_VERSION_ID,
    B.ATTACHMENT_ATTRIBUTE_CODE,
    B.ATTRIBUTE_FILE_ID,
    B.CONTENT_ITEM_NAME,
    B.default_rendition_mime_type,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.citem_translation_status
  FROM IBC_CITEM_VERSIONS_TL B, FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND B.LANGUAGE = USERENV('LANG')
  AND NOT EXISTS
    (SELECT NULL
    FROM IBC_CITEM_VERSIONS_TL T
    WHERE T.CITEM_VERSION_ID = B.CITEM_VERSION_ID
    AND T.LANGUAGE = L.LANGUAGE_CODE);
END ADD_LANGUAGE;


PROCEDURE LOAD_ROW (
  p_UPLOAD_MODE IN VARCHAR2,
  p_CITEM_VERSION_ID    IN NUMBER,
  p_CONTENT_ITEM_ID     IN NUMBER,
  p_VERSION_NUMBER     IN NUMBER,
  p_CITEM_VERSION_STATUS   IN VARCHAR2,
  p_START_DATE      IN DATE,
  p_END_DATE      IN DATE,
  p_ATTACHMENT_ATTRIBUTE_CODE IN VARCHAR2,
  p_ATTRIBUTE_FILE_ID   IN NUMBER  ,
  p_ATTACHMENT_FILE_ID   IN NUMBER  ,--DEFAULT NULL,
  p_CONTENT_ITEM_NAME   IN VARCHAR2,
  p_ATTACHMENT_FILE_NAME  IN VARCHAR2 ,--DEFAULT NULL,
  p_DESCRIPTION     IN VARCHAR2,
  p_DEFAULT_RENDITION_MIME_TYPE   IN VARCHAR2 ,--DEFAULT NULL,
  p_OWNER       IN VARCHAR2,
  p_CITEM_TRANSLATION_STATUS  IN VARCHAR2,  --DEFAULT NULL
  p_LAST_UPDATE_DATE IN VARCHAR2  ) IS

  CURSOR c_citem_dirnode(p_content_item_id NUMBER)
  IS
  SELECT directory_node_id
    FROM ibc_content_items citems
   WHERE content_item_id = p_content_item_id;

  l_dirnode     NUMBER;

  l_user_id        NUMBER := 0;
  l_row_id            VARCHAR2(64);
  lx_object_version_number  NUMBER;
  lx_citem_version_id     NUMBER := p_citem_version_id;
  l_object_type VARCHAR2(30);
  l_object_id   NUMBER;
  l_last_update_date DATE;

  db_user_id    NUMBER := 0;
  db_last_update_date DATE;

BEGIN


  --get last updated by user id
  l_user_id := FND_LOAD_UTIL.OWNER_ID(p_OWNER);

  --translate data type VARCHAR2 to DATE for last_update_date
  l_last_update_date := nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'),SYSDATE);

  -- get updatedby  and update_date values if existing in db
  SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE INTO db_user_id, db_last_update_date
  FROM IBC_CITEM_VERSIONS_B
  WHERE CITEM_VERSION_ID = p_CITEM_VERSION_ID;

  -- Validation of Unique Name in a particular directory for a especific
  -- Language.
  OPEN c_citem_dirnode(p_content_item_id);
  FETCH c_citem_dirnode INTO l_dirnode;
  CLOSE c_citem_dirnode;

  IF IBC_UTILITIES_PVT.is_name_already_used(p_dir_node_id => l_dirnode,
                                            p_name        => p_content_item_name,
                                            p_language    => USERENV('lang'),
                                            p_chk_content_item_id => p_content_item_id,
                                            x_object_type => l_object_type,
                                            x_object_id   => l_object_id)
  THEN
    IF l_object_type = 'DIRNODE' THEN
      Fnd_Message.Set_Name('IBC', 'IBC_NAME_ALREADY_FOLDER');
    ELSE
      Fnd_Message.Set_Name('IBC', 'IBC_CITEM_NAME_UNIQUE');
      Fnd_Message.Set_token('NEW_ITEM_NAME' , p_content_item_name);
      Fnd_Message.Set_token('CONFLICTING_ITEM_NAME' , IBC_UTILITIES_PVT.get_citem_name(l_object_id));
    END IF;
    Fnd_Msg_Pub.ADD;
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

  SELECT MAX(object_version_number) INTO lx_object_version_number
    FROM IBC_CONTENT_ITEMS
   WHERE content_item_id = p_content_item_id;

  IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
	db_user_id, db_last_update_date, p_upload_mode )) THEN

	Ibc_Citem_Versions_Pkg.UPDATE_ROW (
                p_citem_version_id             => NVL(p_citem_version_id,FND_API.G_MISS_NUM)
               ,p_content_item_id              => NVL(p_content_item_id,FND_API.G_MISS_NUM)
               ,p_version_number               => NVL(p_version_number,FND_API.G_MISS_NUM)
               ,p_citem_version_status         => NVL(p_citem_version_status,FND_API.G_MISS_CHAR)
               ,p_start_date                   => NVL(p_start_date,FND_API.G_MISS_DATE)
               ,p_end_date                     => NVL(p_end_date,FND_API.G_MISS_DATE)
               ,p_attachment_attribute_code    => NVL(p_attachment_attribute_code,FND_API.G_MISS_CHAR)
               ,p_attribute_file_id            => NVL(p_attribute_file_id,FND_API.G_MISS_NUM)
               ,p_attachment_file_id           => NVL(p_attachment_file_id,FND_API.G_MISS_NUM)
               ,p_content_item_name            => NVL(p_content_item_name,FND_API.G_MISS_CHAR)
               ,p_attachment_file_name         => NVL(p_attachment_file_name,FND_API.G_MISS_CHAR)
               ,p_description                  => NVL(p_description,FND_API.G_MISS_CHAR)
               ,p_default_rendition_mime_type  => NVL(p_default_rendition_mime_type,FND_API.G_MISS_CHAR)
               ,p_last_updated_by              => l_user_id
               ,p_last_update_date             => l_last_update_date
               ,p_last_update_login            => 0
               ,px_object_version_number       => lx_object_version_number
               ,p_citem_translation_status     => NVL(p_citem_translation_status,FND_API.G_MISS_CHAR)
               );
  END IF;

EXCEPTION
    WHEN no_data_found THEN

     SELECT MAX(object_version_number) INTO lx_object_version_number
     FROM IBC_CONTENT_ITEMS
     WHERE content_item_id = p_content_item_id;

       Ibc_Citem_Versions_Pkg.INSERT_ROW (
          X_ROWID => l_row_id,
          px_CITEM_VERSION_ID => lx_CITEM_VERSION_ID,
          p_CONTENT_ITEM_ID  => p_CONTENT_ITEM_ID,
          p_VERSION_NUMBER  => p_VERSION_NUMBER,
          p_CITEM_VERSION_STATUS => p_CITEM_VERSION_STATUS,
          p_START_DATE    => p_START_DATE,
          p_END_DATE    => p_END_DATE,
          p_ATTACHMENT_ATTRIBUTE_CODE => p_ATTACHMENT_ATTRIBUTE_CODE,
          p_ATTRIBUTE_FILE_ID   => p_ATTRIBUTE_FILE_ID,
          p_ATTACHMENT_FILE_ID   => p_ATTACHMENT_FILE_ID,
          p_CONTENT_ITEM_NAME   => p_CONTENT_ITEM_NAME,
          p_ATTACHMENT_FILE_NAME  => p_ATTACHMENT_FILE_NAME,
          p_DESCRIPTION     => p_DESCRIPTION,
          p_DEFAULT_RENDITION_MIME_TYPE  => p_DEFAULT_RENDITION_MIME_TYPE,
          p_CREATION_DATE       => l_last_update_date,
          p_CREATED_BY        => l_user_id,
          p_LAST_UPDATE_DATE      => l_last_update_date,
          p_LAST_UPDATED_BY      => l_user_id,
          p_LAST_UPDATE_LOGIN      => 0,
          px_OBJECT_VERSION_NUMBER   => lx_object_version_number,
          p_citem_translation_status => p_citem_translation_status);

END LOAD_ROW;

PROCEDURE TRANSLATE_ROW (
  p_UPLOAD_MODE IN VARCHAR2,
  p_CITEM_VERSION_ID IN NUMBER,
  p_ATTACHMENT_ATTRIBUTE_CODE IN VARCHAR2,
  p_ATTRIBUTE_FILE_ID IN NUMBER,
  p_ATTACHMENT_FILE_ID IN NUMBER,
  p_CONTENT_ITEM_NAME IN VARCHAR2,
  p_ATTACHMENT_FILE_NAME IN VARCHAR2,
  p_DESCRIPTION    IN VARCHAR2,
  p_DEFAULT_RENDITION_MIME_TYPE   IN VARCHAR2 ,--DEFAULT NULL,
  p_OWNER     IN  VARCHAR2,
  p_CITEM_TRANSLATION_STATUS  IN VARCHAR2,  --DEFAULT NULL
  p_LAST_UPDATE_DATE IN VARCHAR2  ) IS

  l_user_id        NUMBER := 0;
  l_last_update_date DATE;

  db_user_id    NUMBER := 0;
  db_last_update_date DATE;


  CURSOR c_citem_dirnode(p_content_item_id NUMBER)
  IS
  SELECT directory_node_id
    FROM ibc_content_items citems
   WHERE content_item_id = p_content_item_id;

  l_dirnode     NUMBER;
  l_object_type VARCHAR2(30);
  l_object_id   NUMBER;

BEGIN

  --get last updated by user id
  l_user_id := FND_LOAD_UTIL.OWNER_ID(p_OWNER);

  --translate data type VARCHAR2 to DATE for last_update_date
  l_last_update_date := nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'),SYSDATE);

  -- get updatedby  and update_date values if existing in db
  SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE INTO db_user_id, db_last_update_date
  FROM IBC_CITEM_VERSIONS_TL
  WHERE CITEM_VERSION_ID = p_CITEM_VERSION_ID
  AND USERENV('LANG') IN (LANGUAGE, source_lang);

  -- Validation of Unique Name in a particular directory for a especific
  -- Language.
  FOR r_citem IN (SELECT content_item_id
                    FROM IBC_CITEM_VERSIONS_B
                   WHERE citem_version_id = p_citem_version_id)
  LOOP
    OPEN c_citem_dirnode(r_citem.content_item_id);
    FETCH c_citem_dirnode INTO l_dirnode;
    CLOSE c_citem_dirnode;
    /*
    IF IBC_UTILITIES_PVT.is_name_already_used(p_dir_node_id => l_dirnode,
                                              p_name        => p_content_item_name,
                                              p_language    => USERENV('lang'),
                                              p_chk_content_item_id => r_citem.content_item_id,
                                                                                          x_object_type => l_object_type,
                                                                                          x_object_id   => l_object_id)
    THEN
      IF l_object_type = 'DIRNODE' THEN
        Fnd_Message.Set_Name('IBC', 'IBC_NAME_ALREADY_FOLDER');
      ELSE
        Fnd_Message.Set_Name('IBC', 'IBC_CITEM_NAME_UNIQUE');
        Fnd_Message.Set_token('NEW_ITEM_NAME' , p_content_item_name);
        Fnd_Message.Set_token('CONFLICTING_ITEM_NAME' , IBC_UTILITIES_PVT.get_citem_name(l_object_id));
      END IF;
      Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
    */
  END LOOP;

  IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
	db_user_id, db_last_update_date, p_upload_mode )) THEN

	  -- Only update rows which have not been altered by user
	  UPDATE IBC_CITEM_VERSIONS_TL
	  SET
	    ATTRIBUTE_FILE_ID   = (SELECT ATTRIBUTE_FILE_ID FROM IBC_CITEM_VERSIONS_TL
	       WHERE citem_version_id = p_citem_version_id
	       AND   LANGUAGE = 'US'),
	    ATTACHMENT_FILE_ID   = (SELECT ATTACHMENT_FILE_ID FROM IBC_CITEM_VERSIONS_TL
	       WHERE citem_version_id = p_citem_version_id
	       AND   LANGUAGE = 'US'),
	   CONTENT_ITEM_NAME   = p_CONTENT_ITEM_NAME,
	    ATTACHMENT_FILE_NAME  = p_ATTACHMENT_FILE_NAME,
	    ATTACHMENT_ATTRIBUTE_CODE = p_ATTACHMENT_ATTRIBUTE_CODE,
	    DESCRIPTION      = p_DESCRIPTION,
	    DEFAULT_RENDITION_MIME_TYPE = p_DEFAULT_RENDITION_MIME_TYPE,
	    source_lang      = USERENV('LANG'),
	    last_update_date     = l_last_update_date,
	    last_updated_by     = l_user_id,
	    last_update_login     = 0,
	    CITEM_TRANSLATION_STATUS = p_CITEM_TRANSLATION_STATUS
	  WHERE CITEM_VERSION_ID     = p_CITEM_VERSION_ID
	    AND USERENV('LANG') IN (LANGUAGE, source_lang);

  END IF;

END TRANSLATE_ROW;


  -- Added by svatsa
PROCEDURE populate_attachments (
  p_citem_version_id  IN NUMBER
 ,p_base_lang         IN VARCHAR2
 ) IS

  CURSOR version_cur (cv_version_id NUMBER
                     ,cv_language VARCHAR2) IS
       SELECT attachment_file_id
         FROM ibc_citem_versions_tl
        WHERE citem_version_id = cv_version_id
          AND language = cv_language
          AND attachment_file_id IS NOT NULL;
  base_ver_rec version_cur%ROWTYPE;
  base_file_id NUMBER := 0;
  trans_file_id NUMBER := null;

  CURSOR trans_ver_cur (cv_version_id NUMBER
                       ,cv_base_language VARCHAR2) IS
       SELECT citem_version_id, language, attachment_file_id
         FROM ibc_citem_versions_tl
        WHERE citem_version_id = cv_version_id
          AND language <> cv_base_language FOR UPDATE;
  trans_ver_rec trans_ver_cur%ROWTYPE ;

  isFile boolean := false;
  seq NUMBER := null;

BEGIN

  OPEN version_cur(p_citem_version_id,p_base_lang);
  FETCH version_cur INTO base_file_id;
    IF version_cur%FOUND THEN
      isFile := true;
    END IF;
  CLOSE version_cur;

  IF isFile THEN
    OPEN trans_ver_cur(p_citem_version_id,p_base_lang);
    LOOP
      FETCH trans_ver_cur INTO trans_ver_rec;
      EXIT WHEN trans_ver_cur%NOTFOUND;
      INSERT INTO fnd_lobs (file_id
                           ,file_name
                           ,file_content_type
                           ,file_data
                           ,upload_date
                           ,expiration_date
                           ,program_name
                           ,program_tag
                           ,oracle_charset
                           ,file_format
                           )
                     SELECT fnd_lobs_s.nextval
                           ,file_name
                           ,file_content_type
                           ,file_data
                           ,upload_date
                           ,expiration_date
                           ,program_name
                           ,program_tag
                           ,oracle_charset
                           ,file_format
                     FROM fnd_lobs
                    WHERE file_id = trans_ver_rec.attachment_file_id;

      -- Update the file_id in ibc_citem_versions_tl
      UPDATE ibc_citem_versions_tl
         SET attachment_file_id = fnd_lobs_s.currval
       WHERE citem_version_id = trans_ver_rec.citem_version_id
         AND language = trans_ver_rec.language;
    END LOOP;
  CLOSE trans_ver_cur;
  END IF;
END populate_attachments;

--Bug Fix:3597752
PROCEDURE populate_all_attachments (
  p_citem_version_id  IN NUMBER
 ,p_base_lang         IN VARCHAR2
 ) IS

  CURSOR version_cur (cv_version_id NUMBER
                     ,cv_language VARCHAR2) IS
       SELECT attachment_file_id
         FROM ibc_citem_versions_tl
        WHERE citem_version_id = cv_version_id
          AND LANGUAGE = cv_language
          AND attachment_file_id IS NOT NULL;
  base_ver_rec version_cur%ROWTYPE;
  base_file_id NUMBER := 0;
  trans_file_id NUMBER := NULL;

  CURSOR trans_ver_cur (cv_version_id NUMBER
                       ,cv_base_language VARCHAR2) IS
       SELECT citem_version_id, LANGUAGE, attachment_file_id
         FROM ibc_citem_versions_tl
        WHERE citem_version_id = cv_version_id;
      --    AND LANGUAGE <> cv_base_language FOR UPDATE;
  trans_ver_rec trans_ver_cur%ROWTYPE ;

  isFile BOOLEAN := FALSE;
  seq NUMBER := NULL;

BEGIN

  OPEN version_cur(p_citem_version_id,p_base_lang);
  FETCH version_cur INTO base_file_id;
    IF version_cur%FOUND THEN
      isFile := TRUE;
    END IF;
  CLOSE version_cur;

  IF isFile THEN
    OPEN trans_ver_cur(p_citem_version_id,p_base_lang);
    LOOP
      FETCH trans_ver_cur INTO trans_ver_rec;
      EXIT WHEN trans_ver_cur%NOTFOUND;
      INSERT INTO fnd_lobs (file_id
                           ,file_name
                           ,file_content_type
                           ,file_data
                           ,upload_date
                           ,expiration_date
                           ,program_name
                           ,program_tag
                           ,oracle_charset
                           ,file_format
                           )
                     SELECT fnd_lobs_s.NEXTVAL
                           ,file_name
                           ,file_content_type
                           ,file_data
                           ,upload_date
                           ,expiration_date
                           ,program_name
                           ,program_tag
                           ,oracle_charset
                           ,file_format
                     FROM fnd_lobs
                    WHERE file_id = trans_ver_rec.attachment_file_id;

      -- Update the file_id in ibc_citem_versions_tl
      UPDATE ibc_citem_versions_tl
         SET attachment_file_id = fnd_lobs_s.CURRVAL
       WHERE citem_version_id = trans_ver_rec.citem_version_id
         AND LANGUAGE = trans_ver_rec.LANGUAGE;
    END LOOP;
  CLOSE trans_ver_cur;
  END IF;
END populate_all_attachments;

PROCEDURE LOAD_SEED_ROW (
  p_UPLOAD_MODE IN VARCHAR2,
  p_CITEM_VERSION_ID    IN NUMBER,
  p_CONTENT_ITEM_ID     IN NUMBER,
  p_VERSION_NUMBER     IN NUMBER,
  p_CITEM_VERSION_STATUS   IN VARCHAR2,
  p_START_DATE      IN DATE,
  p_END_DATE      IN DATE,
  p_ATTACHMENT_ATTRIBUTE_CODE IN VARCHAR2,
  p_ATTRIBUTE_FILE_ID   IN NUMBER  ,
  p_ATTACHMENT_FILE_ID   IN NUMBER  DEFAULT NULL,
  p_CONTENT_ITEM_NAME   IN VARCHAR2,
  p_ATTACHMENT_FILE_NAME  IN VARCHAR2 DEFAULT NULL,
  p_DESCRIPTION     IN VARCHAR2,
  p_DEFAULT_RENDITION_MIME_TYPE   IN VARCHAR2 DEFAULT NULL,
  p_OWNER       IN VARCHAR2,
  p_CITEM_TRANSLATION_STATUS  IN VARCHAR2  DEFAULT NULL,
  p_LAST_UPDATE_DATE IN VARCHAR2  ) IS
BEGIN
	IF (p_UPLOAD_MODE = 'NLS') THEN
		Ibc_Citem_Versions_Pkg.TRANSLATE_ROW (
			p_UPLOAD_MODE => p_UPLOAD_MODE,
			p_CITEM_VERSION_ID => p_CITEM_VERSION_ID,
			p_ATTACHMENT_ATTRIBUTE_CODE => p_ATTACHMENT_ATTRIBUTE_CODE,
			p_ATTRIBUTE_FILE_ID => p_ATTRIBUTE_FILE_ID,
			p_ATTACHMENT_FILE_ID => p_ATTACHMENT_FILE_ID,
			p_CONTENT_ITEM_NAME => p_CONTENT_ITEM_NAME ,
			p_ATTACHMENT_FILE_NAME => p_ATTACHMENT_FILE_NAME,
			p_DESCRIPTION => p_DESCRIPTION,
			p_DEFAULT_RENDITION_MIME_TYPE => p_DEFAULT_RENDITION_MIME_TYPE,
			p_OWNER  =>  p_OWNER,
			p_CITEM_TRANSLATION_STATUS => p_CITEM_TRANSLATION_STATUS,
			p_LAST_UPDATE_DATE => p_LAST_UPDATE_DATE );

	ELSE
		Ibc_Citem_Versions_Pkg.LOAD_ROW (
			p_UPLOAD_MODE => p_UPLOAD_MODE,
			p_CITEM_VERSION_ID => p_CITEM_VERSION_ID,
			p_CONTENT_ITEM_ID => p_CONTENT_ITEM_ID,
			p_VERSION_NUMBER => p_VERSION_NUMBER,
			p_CITEM_VERSION_STATUS => p_CITEM_VERSION_STATUS,
			p_START_DATE => p_START_DATE,
			p_END_DATE => p_END_DATE,
			p_ATTACHMENT_ATTRIBUTE_CODE => p_ATTACHMENT_ATTRIBUTE_CODE,
			p_ATTRIBUTE_FILE_ID => p_ATTRIBUTE_FILE_ID,
			p_ATTACHMENT_FILE_ID => p_ATTACHMENT_FILE_ID,
			p_CONTENT_ITEM_NAME => p_CONTENT_ITEM_NAME ,
			p_ATTACHMENT_FILE_NAME => p_ATTACHMENT_FILE_NAME,
			p_DESCRIPTION => p_DESCRIPTION,
			p_DEFAULT_RENDITION_MIME_TYPE => p_DEFAULT_RENDITION_MIME_TYPE,
			p_OWNER  =>  p_OWNER,
			p_CITEM_TRANSLATION_STATUS => p_CITEM_TRANSLATION_STATUS,
			p_LAST_UPDATE_DATE => p_LAST_UPDATE_DATE );
	END IF;
END;

END Ibc_Citem_Versions_Pkg;

/
