--------------------------------------------------------
--  DDL for Package Body IBC_CONTENT_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CONTENT_ITEMS_PKG" AS
/* $Header: ibctconb.pls 120.2 2006/11/15 10:10:34 sharma ship $*/

-- Purpose: Table Handler for Ibc_Content_Items_Pkg table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for FND_API.G_MISS_XXX
-- shitij.vatsa      02/11/2003      Added parameter p_subitem_version_id
--                                   to the APIs
-- Edward Nunez      12/04/2003      Got rid of handling of ovn in update_row
-- Edward Nunez      12/09/2003      Hardcoding 'F' to wd_restricted_flag as it is
--                                   not support for current release. Only in insert_row
-- SHARMA 	     07/04/2005	     Modified LOAD_ROW, TRANSLATE_ROW and created
-- 			             LOAD_SEED_ROW for R12 LCT standards bug 4411674

G_PKG_NAME    CONSTANT VARCHAR2(30):= 'IBC_CONTENT_ITEMS_PKG';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'ibctconb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;


PROCEDURE INSERT_ROW (
 x_rowid                           OUT NOCOPY VARCHAR2
,px_content_item_id                IN OUT NOCOPY NUMBER
,p_content_type_code               IN VARCHAR2
,p_item_reference_code             IN VARCHAR2
,p_directory_node_id               IN NUMBER
,p_parent_item_id                  IN NUMBER
,p_live_citem_version_id           IN NUMBER
,p_content_item_status             IN VARCHAR2
,p_locked_by_user_id               IN NUMBER
,p_wd_restricted_flag              IN VARCHAR2
,p_base_language                   IN VARCHAR2
,p_translation_required_flag       IN VARCHAR2
,p_owner_resource_id               IN NUMBER
,p_owner_resource_type             IN VARCHAR2
,p_application_id                  IN NUMBER
,p_request_id                      IN NUMBER
,p_object_version_number           IN NUMBER        --DEFAULT 1
,p_creation_date                   IN DATE          --DEFAULT NULL
,p_created_by                      IN NUMBER        --DEFAULT NULL
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
,p_encrypt_flag                    IN VARCHAR2      --DEFAULT NULL
) IS
  CURSOR C IS SELECT ROWID FROM IBC_CONTENT_ITEMS
    WHERE CONTENT_ITEM_ID = px_CONTENT_ITEM_ID;

  CURSOR c2 IS SELECT ibc_content_items_s1.NEXTVAL FROM dual;

  G_API_NAME   CONSTANT VARCHAR2(30) := 'INSERT_ROW';

BEGIN

  -- Primary key validation check

  IF ((px_CONTENT_ITEM_ID IS NULL) OR
      (px_CONTENT_ITEM_ID = FND_API.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO px_CONTENT_ITEM_ID;
    CLOSE c2;
  END IF;

  INSERT INTO IBC_CONTENT_ITEMS (
    CONTENT_ITEM_ID,
    CONTENT_TYPE_CODE,
    ITEM_REFERENCE_CODE,
    DIRECTORY_NODE_ID,
    parent_item_id,
    LIVE_CITEM_VERSION_ID,
    CONTENT_ITEM_STATUS,
    LOCKED_BY_USER_ID,
    WD_RESTRICTED_FLAG,
    BASE_LANGUAGE,
    TRANSLATION_REQUIRED_FLAG,
    OWNER_RESOURCE_ID,
    OWNER_RESOURCE_TYPE,
    APPLICATION_ID,
    REQUEST_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    encrypt_flag
  ) VALUES (
     px_content_item_id
    ,p_content_type_code
    ,UPPER(DECODE(p_item_reference_code,FND_API.G_MISS_CHAR,NULL,p_item_reference_code))
    ,p_directory_node_id
    ,DECODE(p_parent_item_id,FND_API.G_MISS_NUM,NULL,p_parent_item_id)
    ,DECODE(p_live_citem_version_id,FND_API.G_MISS_NUM,NULL,p_live_citem_version_id)
    ,DECODE(p_content_item_status,FND_API.G_MISS_CHAR,NULL,p_content_item_status)
    ,DECODE(p_locked_by_user_id,FND_API.G_MISS_NUM,NULL,p_locked_by_user_id)
    ,'F' -- p_wd_restricted_flag -- Setting hardcoded to 'F' as it is not being used at the moment
    ,p_base_language
    ,p_translation_required_flag
    ,DECODE(p_owner_resource_id,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_owner_resource_id)
    ,p_owner_resource_type
    ,DECODE(p_application_id,FND_API.G_MISS_NUM,FND_GLOBAL.resp_appl_id,NULL,FND_GLOBAL.resp_appl_id,p_application_id)
    ,DECODE(p_request_id,FND_API.G_MISS_NUM,NULL,p_request_id)
    ,DECODE(p_object_version_number,FND_API.G_MISS_NUM,1,NULL,1,p_object_version_number)
    ,DECODE(p_creation_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_creation_date)
    ,DECODE(p_created_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_created_by)
    ,DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
    ,DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
    ,DECODE(p_encrypt_flag,FND_API.G_MISS_CHAR,NULL,p_encrypt_flag)

  );

  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
     FND_MESSAGE.Set_Name('IBC', 'IBC_ERROR_RETURNED');
        FND_MESSAGE.Set_token('PKG_NAME' , G_pkg_name);
        FND_MESSAGE.Set_token('API_NAME' , G_api_name);
        FND_MSG_PUB.ADD;
  RAISE FND_API.G_EXC_ERROR;
     -- RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;

PROCEDURE LOCK_ROW (
  p_CONTENT_ITEM_ID IN NUMBER,
  p_CONTENT_TYPE_CODE IN VARCHAR2,
  p_ITEM_REFERENCE_CODE IN VARCHAR2,
  p_DIRECTORY_NODE_ID IN NUMBER,
  p_parent_item_ID IN NUMBER,
  p_LIVE_CITEM_VERSION_ID IN NUMBER,
  p_CONTENT_ITEM_STATUS IN VARCHAR2,
  p_LOCKED_BY_USER_ID IN NUMBER,
  p_WD_RESTRICTED_FLAG IN VARCHAR2,
  p_BASE_LANGUAGE IN VARCHAR2,
  p_TRANSLATION_REQUIRED_FLAG IN VARCHAR2,
  p_OWNER_RESOURCE_ID IN NUMBER,
  p_APPLICATION_ID IN NUMBER,
  p_REQUEST_ID IN NUMBER,
  p_OBJECT_VERSION_NUMBER IN NUMBER
) IS
  CURSOR c IS SELECT
      CONTENT_TYPE_CODE,
      ITEM_REFERENCE_CODE,
      DIRECTORY_NODE_ID,
      LIVE_CITEM_VERSION_ID,
      CONTENT_ITEM_STATUS,
      LOCKED_BY_USER_ID,
      WD_RESTRICTED_FLAG,
      BASE_LANGUAGE,
      TRANSLATION_REQUIRED_FLAG,
      OWNER_RESOURCE_ID,
      APPLICATION_ID,
      REQUEST_ID,
      OBJECT_VERSION_NUMBER
    FROM IBC_CONTENT_ITEMS
    WHERE CONTENT_ITEM_ID = p_CONTENT_ITEM_ID
    FOR UPDATE OF CONTENT_ITEM_ID NOWAIT;
  recinfo c%ROWTYPE;


  G_API_NAME   CONSTANT VARCHAR2(30) := 'LOCK_ROW';

BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c;
  IF (    (recinfo.CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE)
      AND (recinfo.DIRECTORY_NODE_ID = p_DIRECTORY_NODE_ID)
      AND ((recinfo.LIVE_CITEM_VERSION_ID = p_LIVE_CITEM_VERSION_ID)
           OR ((recinfo.LIVE_CITEM_VERSION_ID IS NULL) AND (p_LIVE_CITEM_VERSION_ID IS NULL)))
      AND ((recinfo.ITEM_REFERENCE_CODE = p_ITEM_REFERENCE_CODE)
           OR ((recinfo.ITEM_REFERENCE_CODE IS NULL) AND (p_ITEM_REFERENCE_CODE IS NULL)))
      AND ((recinfo.CONTENT_ITEM_STATUS = p_CONTENT_ITEM_STATUS)
           OR ((recinfo.CONTENT_ITEM_STATUS IS NULL) AND (p_CONTENT_ITEM_STATUS IS NULL)))
      AND ((recinfo.LOCKED_BY_USER_ID = p_LOCKED_BY_USER_ID)
           OR ((recinfo.LOCKED_BY_USER_ID IS NULL) AND (p_LOCKED_BY_USER_ID IS NULL)))
      AND (recinfo.WD_RESTRICTED_FLAG = p_WD_RESTRICTED_FLAG)
      AND (recinfo.BASE_LANGUAGE = p_BASE_LANGUAGE)
      AND (recinfo.TRANSLATION_REQUIRED_FLAG = p_TRANSLATION_REQUIRED_FLAG)
      AND (recinfo.OWNER_RESOURCE_ID = p_OWNER_RESOURCE_ID)
      AND (recinfo.APPLICATION_ID = p_APPLICATION_ID)
      AND ((recinfo.REQUEST_ID = p_REQUEST_ID)
           OR ((recinfo.REQUEST_ID IS NULL) AND (p_REQUEST_ID IS NULL)))
      AND (recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

END LOCK_ROW;

PROCEDURE UPDATE_ROW (
 p_content_item_id                 IN NUMBER
,p_content_type_code               IN VARCHAR2      --DEFAULT NULL
,p_item_reference_code             IN VARCHAR2      --DEFAULT NULL
,p_directory_node_id               IN NUMBER        --DEFAULT NULL
,p_parent_item_id                  IN NUMBER        --DEFAULT NULL
,p_live_citem_version_id           IN NUMBER        --DEFAULT NULL
,p_content_item_status             IN VARCHAR2      --DEFAULT NULL
,p_locked_by_user_id               IN NUMBER        --DEFAULT NULL
,p_wd_restricted_flag              IN VARCHAR2      --DEFAULT NULL
,p_base_language                   IN VARCHAR2      --DEFAULT NULL
,p_translation_required_flag       IN VARCHAR2      --DEFAULT NULL
,p_owner_resource_id               IN NUMBER        --DEFAULT NULL
,p_owner_resource_type             IN VARCHAR2      --DEFAULT NULL
,p_application_id                  IN NUMBER        --DEFAULT NULL
,p_request_id                      IN NUMBER        --DEFAULT NULL
,px_object_version_number          IN OUT NOCOPY NUMBER
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
,p_encrypt_flag                    IN VARCHAR2      --DEFAULT NULL
)  IS

  G_API_NAME   CONSTANT VARCHAR2(30) := 'UPDATE_ROW';
  CURSOR cur_object_version(cv_content_item_id NUMBER) IS
    SELECT object_version_number
      FROM ibc_content_items
     WHERE content_item_id = cv_content_item_id;
  l_object_version_number               NUMBER;

BEGIN
  UPDATE IBC_CONTENT_ITEMS SET
     content_type_code              = DECODE(p_content_type_code,FND_API.G_MISS_CHAR,NULL,NULL,content_type_code,p_content_type_code)
    ,item_reference_code            = UPPER(DECODE(p_item_reference_code,FND_API.G_MISS_CHAR,NULL,NULL,item_reference_code,p_item_reference_code))
    ,directory_node_id              = DECODE(p_directory_node_id,FND_API.G_MISS_NUM,NULL,NULL,directory_node_id,p_directory_node_id)
    ,parent_item_id                 = DECODE(p_parent_item_id,FND_API.G_MISS_NUM,NULL,NULL,parent_item_id,p_parent_item_id)
    ,live_citem_version_id          = DECODE(p_live_citem_version_id,FND_API.G_MISS_NUM,NULL,NULL,live_citem_version_id,p_live_citem_version_id)
    ,content_item_status            = DECODE(p_content_item_status,FND_API.G_MISS_CHAR,NULL,NULL,content_item_status,p_content_item_status)
    ,locked_by_user_id              = DECODE(p_locked_by_user_id,FND_API.G_MISS_NUM,NULL,NULL,locked_by_user_id,p_locked_by_user_id)
--  ,wd_restricted_flag		    = DECODE(p_wd_restricted_flag,FND_API.G_MISS_CHAR,NULL,NULL,wd_restricted_flag,p_wd_restricted_flag)
    ,wd_restricted_flag		    ='F' -- p_wd_restricted_flag -- Setting hardcoded to 'F' as it is not being used at the moment
    ,base_language                  = DECODE(p_base_language,FND_API.G_MISS_CHAR,NULL,NULL,base_language,p_base_language)
    ,translation_required_flag      = DECODE(p_translation_required_flag,FND_API.G_MISS_CHAR,NULL,NULL,translation_required_flag,p_translation_required_flag)
    ,owner_resource_id              = DECODE(p_owner_resource_id,FND_API.G_MISS_NUM,NULL,NULL,owner_resource_id,p_owner_resource_id)
    ,owner_resource_type            = DECODE(p_owner_resource_type,FND_API.G_MISS_CHAR,NULL,NULL,owner_resource_type,p_owner_resource_type)
    ,application_id                 = DECODE(p_application_id,FND_API.G_MISS_NUM,FND_GLOBAL.resp_appl_id,NULL,application_id,p_application_id)
    ,request_id                     = DECODE(p_request_id,FND_API.G_MISS_NUM,NULL,NULL,request_id,p_request_id)
    -- ,object_version_number          = NVL(object_version_number,0) + 1
    ,object_version_number          = 1
    ,last_update_date               = DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,last_updated_by                = DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
    ,last_update_login              = DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
    ,encrypt_flag                   = DECODE(p_encrypt_flag,FND_API.G_MISS_CHAR,NULL,NULL,encrypt_flag,p_encrypt_flag)
 WHERE CONTENT_ITEM_ID = p_CONTENT_ITEM_ID;

--    AND object_version_number = DECODE(px_object_version_number,
--                                       FND_API.G_MISS_NUM,
--                                       object_version_number,
--                                       NULL,
--                                       object_version_number,
--                                       px_object_version_number);

  px_object_version_number := 1;

--   IF (
--       (px_object_version_number IS NULL)
--        OR
--       (px_object_version_number = FND_API.G_MISS_NUM )
--      ) THEN
--      OPEN cur_object_version(p_CONTENT_ITEM_ID);
--      FETCH cur_object_version INTO l_object_version_number;
--      CLOSE cur_object_version;
--      px_object_version_number := l_object_version_number;
--   ELSE
--      px_object_version_number := px_object_version_number + 1;
--   END IF;
--

  IF (SQL%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('IBC', 'IBC_ERROR_RETURNED');
        FND_MESSAGE.Set_token('PKG_NAME' , G_pkg_name);
        FND_MESSAGE.Set_token('API_NAME' , G_api_name);
        FND_MSG_PUB.ADD;
  RAISE FND_API.G_EXC_ERROR;
  -- RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  p_CONTENT_ITEM_ID IN NUMBER
) IS

  G_API_NAME   CONSTANT VARCHAR2(30) := 'DELETE_ROW';

BEGIN

  DELETE FROM IBC_CONTENT_ITEMS
  WHERE CONTENT_ITEM_ID = p_CONTENT_ITEM_ID;

  IF (SQL%NOTFOUND) THEN
     FND_MESSAGE.Set_Name('IBC', 'IBC_ERROR_RETURNED');
        FND_MESSAGE.Set_token('PKG_NAME' , G_pkg_name);
        FND_MESSAGE.Set_token('API_NAME' , G_api_name);
        FND_MSG_PUB.ADD;
  RAISE FND_API.G_EXC_ERROR;
    -- RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

PROCEDURE LOAD_ROW (
  p_UPLOAD_MODE VARCHAR2,
  p_CONTENT_ITEM_ID    NUMBER,
  p_ITEM_REFERENCE_CODE   VARCHAR2,
  p_CONTENT_TYPE_CODE   VARCHAR2,
  p_DIRECTORY_NODE_ID   NUMBER,
  p_parent_item_ID     IN NUMBER ,--DEFAULT NULL,
  p_LIVE_CITEM_VERSION_ID NUMBER,
  p_CONTENT_ITEM_STATUS   VARCHAR2,
  p_LOCKED_BY_USER_ID   NUMBER,
  --p_REUSABLE_FLAG    VARCHAR2 ,--DEFAULT NULL,
  p_WD_RESTRICTED_FLAG   VARCHAR2,
  p_BASE_LANGUAGE    VARCHAR2,
  p_TRANSLATION_REQUIRED_FLAG VARCHAR2,
  p_OWNER_RESOURCE_ID   NUMBER,
  p_OWNER_RESOURCE_TYPE   VARCHAR2,
  p_APPLICATION_ID    NUMBER,
  p_OWNER    IN VARCHAR2,
  p_ENCRYPT_FLAG  IN VARCHAR2,      --DEFAULT NULL
  p_LAST_UPDATE_DATE VARCHAR2
  ) IS
BEGIN
  DECLARE
    l_user_id    NUMBER := 0;
    l_row_id     VARCHAR2(64);
    lx_object_version_number NUMBER := FND_API.G_MISS_NUM;
    lx_CONTENT_ITEM_ID  NUMBER := p_CONTENT_ITEM_ID;
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
	FROM IBC_CONTENT_ITEMS
	WHERE CONTENT_ITEM_ID = p_CONTENT_ITEM_ID;

	IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
		db_user_id, db_last_update_date, p_upload_mode )) THEN


		Ibc_Content_Items_Pkg.UPDATE_ROW (
			p_content_item_id => NVL(p_content_item_id,FND_API.G_MISS_NUM)
		       ,p_item_reference_code  => NVL(p_item_reference_code,FND_API.G_MISS_CHAR)
		       ,p_content_type_code   => NVL(p_content_type_code,FND_API.G_MISS_CHAR)
		       ,p_directory_node_id   => NVL(p_directory_node_id,FND_API.G_MISS_NUM)
		       ,p_parent_item_id      => NVL(p_parent_item_id,FND_API.G_MISS_NUM)
		       ,p_live_citem_version_id  => NVL(p_live_citem_version_id,FND_API.G_MISS_NUM)
		       ,p_content_item_status    => NVL(p_content_item_status,FND_API.G_MISS_CHAR)
		       ,p_locked_by_user_id   => NVL(p_locked_by_user_id,FND_API.G_MISS_NUM)
		       ,p_wd_restricted_flag  => NVL(p_wd_restricted_flag,FND_API.G_MISS_CHAR)
		       ,p_base_language       => NVL(p_base_language,FND_API.G_MISS_CHAR)
		       ,p_translation_required_flag    => NVL(p_translation_required_flag,FND_API.G_MISS_CHAR)
		       ,p_owner_resource_id   => l_user_id
		       ,p_owner_resource_type => 'USER'
		       ,p_application_id      => NVL(p_application_id,FND_API.G_MISS_NUM)
		       ,p_last_updated_by     => l_user_id
		       ,p_last_update_date    => l_last_update_date
		       ,p_last_update_login   => 0
		       ,px_object_version_number => lx_object_version_number
		       ,p_encrypt_flag       => NVL(p_encrypt_flag,FND_API.G_MISS_CHAR)
		);
	END IF;
  EXCEPTION
    WHEN no_data_found  THEN
       Ibc_Content_Items_Pkg.INSERT_ROW (
          X_ROWID => l_row_id,
          px_CONTENT_ITEM_ID    => lx_CONTENT_ITEM_ID,
          p_ITEM_REFERENCE_CODE  => p_ITEM_REFERENCE_CODE,
          p_CONTENT_TYPE_CODE  => p_CONTENT_TYPE_CODE,
          p_DIRECTORY_NODE_ID  => p_DIRECTORY_NODE_ID,
          p_parent_item_ID    =>  p_parent_item_ID,
          p_LIVE_CITEM_VERSION_ID => p_LIVE_CITEM_VERSION_ID,
          p_CONTENT_ITEM_STATUS  => p_CONTENT_ITEM_STATUS,
          p_LOCKED_BY_USER_ID  => p_LOCKED_BY_USER_ID,
          p_WD_RESTRICTED_FLAG  => p_WD_RESTRICTED_FLAG,
          p_BASE_LANGUAGE   => p_BASE_LANGUAGE,
          p_TRANSLATION_REQUIRED_FLAG => p_TRANSLATION_REQUIRED_FLAG,
          p_OWNER_RESOURCE_ID   => l_user_id,
          p_OWNER_RESOURCE_TYPE   => 'USER',
          p_APPLICATION_ID    => p_APPLICATION_ID,
          p_request_id     => NULL,
          p_OBJECT_VERSION_NUMBER => 1,
          p_CREATION_DATE     => SYSDATE,
          p_CREATED_BY      => l_user_id,
          p_LAST_UPDATE_DATE    => l_last_update_date,
          p_LAST_UPDATED_BY    => l_user_id,
          p_LAST_UPDATE_LOGIN    => 0,
          p_encrypt_flag        => p_encrypt_flag);
   END;
END LOAD_ROW;


PROCEDURE LOAD_SEED_ROW (
  p_UPLOAD_MODE VARCHAR2,
  p_CONTENT_ITEM_ID    NUMBER,
  p_ITEM_REFERENCE_CODE   VARCHAR2,
  p_CONTENT_TYPE_CODE   VARCHAR2,
  p_DIRECTORY_NODE_ID   NUMBER,
  p_parent_item_ID     IN NUMBER ,--DEFAULT NULL,
  p_LIVE_CITEM_VERSION_ID NUMBER,
  p_CONTENT_ITEM_STATUS   VARCHAR2,
  p_LOCKED_BY_USER_ID   NUMBER,
  --p_REUSABLE_FLAG    VARCHAR2 DEFAULT NULL,
  p_WD_RESTRICTED_FLAG   VARCHAR2,
  p_BASE_LANGUAGE    VARCHAR2,
  p_TRANSLATION_REQUIRED_FLAG VARCHAR2,
  p_OWNER_RESOURCE_ID   NUMBER,
  p_OWNER_RESOURCE_TYPE   VARCHAR2,
  p_APPLICATION_ID    NUMBER,
  p_OWNER    IN VARCHAR2,
  p_ENCRYPT_FLAG    IN VARCHAR2   DEFAULT NULL,
  p_LAST_UPDATE_DATE VARCHAR2) IS

BEGIN
	IF (p_UPLOAD_MODE = 'NLS') THEN
		NULL;
	ELSE
		IBC_CONTENT_ITEMS_PKG.LOAD_ROW (
		p_UPLOAD_MODE => p_UPLOAD_MODE,
		p_CONTENT_ITEM_ID	=>	TO_NUMBER(p_CONTENT_ITEM_ID),
		p_ITEM_REFERENCE_CODE	=>	p_ITEM_REFERENCE_CODE,
		p_CONTENT_TYPE_CODE	=>	p_CONTENT_TYPE_CODE,
		p_DIRECTORY_NODE_ID	=>	TO_NUMBER(p_DIRECTORY_NODE_ID),
		p_LIVE_CITEM_VERSION_ID	=>	TO_NUMBER(p_LIVE_CITEM_VERSION_ID),
		p_CONTENT_ITEM_STATUS	=>	p_CONTENT_ITEM_STATUS,
		p_LOCKED_BY_USER_ID	=>	TO_NUMBER(p_LOCKED_BY_USER_ID),
		p_PARENT_ITEM_ID	=>	TO_NUMBER(p_PARENT_ITEM_ID),
		p_WD_RESTRICTED_FLAG	=>	p_WD_RESTRICTED_FLAG,
		p_BASE_LANGUAGE		=>	p_BASE_LANGUAGE,
		p_TRANSLATION_REQUIRED_FLAG	=>p_TRANSLATION_REQUIRED_FLAG,
		p_OWNER_RESOURCE_ID	=>	TO_NUMBER(p_OWNER_RESOURCE_ID),
		p_OWNER_RESOURCE_TYPE	=>	p_OWNER_RESOURCE_TYPE,
		p_APPLICATION_ID	=>	TO_NUMBER(p_APPLICATION_ID),
		p_ENCRYPT_FLAG		=>	p_ENCRYPT_FLAG,
		p_OWNER			=>	p_OWNER,
		p_LAST_UPDATE_DATE => p_LAST_UPDATE_DATE );
	END IF;

END LOAD_SEED_ROW;


END Ibc_Content_Items_Pkg;

/
