--------------------------------------------------------
--  DDL for Package Body IBC_CITEM_KEYWORDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CITEM_KEYWORDS_PKG" AS
/* $Header: ibctkwdb.pls 120.1 2005/05/31 00:04:33 appldev  $*/

-- Purpose: Table Handler for ibc_citem_keywords table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Edward Nunez    01/06/2002      Created Package

G_PKG_NAME    CONSTANT VARCHAR2(30):= 'IBC_CITEM_KEYWORDS_PKG';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'ibctkwdb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;



PROCEDURE INSERT_ROW (
  x_ROWID OUT NOCOPY VARCHAR2,
  p_CONTENT_ITEM_ID IN NUMBER,
  p_KEYWORD IN VARCHAR2,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_CREATION_DATE IN DATE 	  		DEFAULT NULL,
  p_CREATED_BY IN NUMBER	  		DEFAULT NULL,
  p_LAST_UPDATE_DATE IN DATE  		DEFAULT NULL,
  p_LAST_UPDATED_BY IN NUMBER 		DEFAULT NULL
) IS
  CURSOR C IS SELECT ROWID FROM IBC_CITEM_KEYWORDS
    WHERE CONTENT_ITEM_ID = p_CONTENT_ITEM_ID
      AND KEYWORD = p_KEYWORD;

  G_API_NAME   CONSTANT VARCHAR2(30) := 'INSERT_ROW';

BEGIN

  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%NOTFOUND) THEN
  INSERT INTO IBC_CITEM_KEYWORDS(
    CONTENT_ITEM_ID,
    KEYWORD,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY
  ) VALUES (
     p_content_item_id
    ,p_keyword
    ,DECODE(p_object_version_number,NULL,1,NULL,1,p_object_version_number)
    ,DECODE(p_creation_date,NULL,SYSDATE,NULL,SYSDATE,p_creation_date)
    ,DECODE(p_created_by,NULL,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_created_by)
    ,DECODE(p_last_update_date,NULL,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,DECODE(p_last_updated_by,NULL,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
  );
  END IF;
  CLOSE c;

END INSERT_ROW;


PROCEDURE LOCK_ROW (
  p_CONTENT_ITEM_ID IN NUMBER,
  p_KEYWORD IN VARCHAR2,
  p_OBJECT_VERSION_NUMBER IN NUMBER
) IS
  CURSOR c IS SELECT
      OBJECT_VERSION_NUMBER
    FROM IBC_CITEM_KEYWORDS
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
  IF  NOT ((recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)) THEN
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

END LOCK_ROW;


PROCEDURE UPDATE_ROW (
   p_CONTENT_ITEM_ID		IN  NUMBER,
   p_KEYWORD	IN  VARCHAR2,
   px_OBJECT_VERSION_NUMBER	IN OUT NOCOPY NUMBER -- DEFAULT  NULL
   ,p_last_update_date                IN DATE  --        DEFAULT NULL
    ,p_last_updated_by                 IN NUMBER  --      DEFAULT NULL
) IS

  G_API_NAME   CONSTANT VARCHAR2(30) := 'UPDATE_ROW';

BEGIN
  UPDATE IBC_CITEM_KEYWORDS SET
     object_version_number          = NVL(object_version_number,0) + 1
    ,last_update_date               = DECODE(p_last_update_date,NULL,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,last_updated_by                = DECODE(p_last_updated_by,NULL,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
 WHERE CONTENT_ITEM_ID = p_CONTENT_ITEM_ID
    AND KEYWORD = p_KEYWORD
    AND object_version_number = DECODE(px_object_version_number,
                                       NULL,
                                       object_version_number,
                                       NULL,
                                       object_version_number,
                                       px_object_version_number);

   px_object_version_number := px_object_version_number + 1;

  IF (SQL%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('IBC', 'IBC_ERROR_RETURNED');
        FND_MESSAGE.Set_token('PKG_NAME' , G_pkg_name);
        FND_MESSAGE.Set_token('API_NAME' , G_api_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
  END IF;

END UPDATE_ROW;


PROCEDURE DELETE_ROW (
  p_CONTENT_ITEM_ID IN NUMBER
  ,p_KEYWORD IN VARCHAR2
) IS

  G_API_NAME   CONSTANT VARCHAR2(30) := 'DELETE_ROW';

BEGIN

  DELETE FROM IBC_CITEM_KEYWORDS
   WHERE CONTENT_ITEM_ID = p_CONTENT_ITEM_ID
     AND KEYWORD = p_KEYWORD;

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
  p_CONTENT_ITEM_ID	IN	NUMBER,
  p_KEYWORD	IN	VARCHAR2,
  p_OWNER IN VARCHAR2
) IS
BEGIN
  DECLARE
    l_user_id    NUMBER := 0;
    l_row_id     VARCHAR2(64);
    lx_object_version_number NUMBER := NULL;
  BEGIN
    IF (p_OWNER = 'SEED') THEN
      l_user_id := 1;
    END IF;

    UPDATE_ROW (
                p_content_item_id              => p_content_item_id
               ,p_keyword                      => p_keyword
               ,p_last_updated_by              => l_user_id
               ,p_last_update_date             => SYSDATE
               ,px_object_version_number       => lx_object_version_number
               );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       INSERT_ROW (
          X_ROWID => l_row_id,
          p_CONTENT_ITEM_ID    => p_CONTENT_ITEM_ID,
          p_KEYWORD  => p_KEYWORD,
          p_OBJECT_VERSION_NUMBER => 1,
          p_CREATION_DATE     => SYSDATE,
          p_CREATED_BY      => l_user_id,
          p_LAST_UPDATE_DATE    => SYSDATE,
          p_LAST_UPDATED_BY    => l_user_id);
   END;
END LOAD_ROW;


END Ibc_citem_keywords_Pkg;

/
