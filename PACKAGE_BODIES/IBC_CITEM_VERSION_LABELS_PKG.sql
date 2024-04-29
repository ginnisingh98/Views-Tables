--------------------------------------------------------
--  DDL for Package Body IBC_CITEM_VERSION_LABELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CITEM_VERSION_LABELS_PKG" AS
/* $Header: ibctcvlb.pls 120.1 2005/07/29 15:07:45 appldev ship $*/

-- Purpose: Table Handler for Ibc_Citem_Version_Labels table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for FND_API.G_MISS_XXX
-- SHARMA 	     07/04/2005	     Modified LOAD_ROW, TRANSLATE_ROW and created
-- 			             LOAD_SEED_ROW for R12 LCT standards bug 4411674

PROCEDURE INSERT_ROW (
 x_rowid                           OUT NOCOPY VARCHAR2
,p_content_item_id                 IN NUMBER
,p_label_code                      IN VARCHAR2
,p_citem_version_id                IN NUMBER
,p_object_version_number           IN NUMBER
,p_creation_date                   IN DATE          --DEFAULT NULL
,p_created_by                      IN NUMBER        --DEFAULT NULL
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
) IS
  CURSOR C IS SELECT ROWID FROM IBC_CITEM_VERSION_LABELS
    WHERE CONTENT_ITEM_ID = p_CONTENT_ITEM_ID
    AND LABEL_CODE = p_LABEL_CODE;
BEGIN
  INSERT INTO IBC_CITEM_VERSION_LABELS (
    CONTENT_ITEM_ID,
    LABEL_CODE,
    CITEM_VERSION_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
     p_content_item_id
    ,p_label_code
    ,p_citem_version_id
    ,DECODE(p_object_version_number,FND_API.G_MISS_NUM,1,NULL,1,p_object_version_number)
    ,DECODE(p_creation_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_creation_date)
    ,DECODE(p_created_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_created_by)
    ,DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
    ,DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
  );


  OPEN c;
  FETCH c INTO x_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;

PROCEDURE LOCK_ROW (
  p_CONTENT_ITEM_ID IN NUMBER,
  p_LABEL_CODE IN VARCHAR2,
  p_CITEM_VERSION_ID IN NUMBER,
  p_OBJECT_VERSION_NUMBER IN NUMBER
) IS
  CURSOR c IS SELECT
      CITEM_VERSION_ID,
      OBJECT_VERSION_NUMBER
    FROM IBC_CITEM_VERSION_LABELS
    WHERE CONTENT_ITEM_ID = p_CONTENT_ITEM_ID
    AND LABEL_CODE = p_LABEL_CODE
    FOR UPDATE OF CONTENT_ITEM_ID NOWAIT;
  recinfo c%ROWTYPE;

BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c;
  IF (    (recinfo.CITEM_VERSION_ID = p_CITEM_VERSION_ID)
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
,p_label_code                      IN VARCHAR2
,p_citem_version_id                IN NUMBER        --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
,p_object_version_number           IN NUMBER        --DEFAULT NULL
) IS
BEGIN
  UPDATE IBC_CITEM_VERSION_LABELS SET
    citem_version_id               = DECODE(p_citem_version_id,FND_API.G_MISS_NUM,NULL,NULL,citem_version_id,p_citem_version_id)
   ,object_version_number          = NVL(object_version_number,0) + 1
   ,last_update_date               = DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
   ,last_updated_by                = DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
   ,last_update_login              = DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
  WHERE CONTENT_ITEM_ID = p_CONTENT_ITEM_ID
  AND LABEL_CODE = p_LABEL_CODE
  AND object_version_number = DECODE(p_object_version_number,
                                       FND_API.G_MISS_NUM,
                                       object_version_number,
                                       NULL,
                                       object_version_number,
                                       p_object_version_number);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  p_CONTENT_ITEM_ID IN NUMBER,
  p_LABEL_CODE IN VARCHAR2
) IS
BEGIN

  DELETE FROM IBC_CITEM_VERSION_LABELS
  WHERE CONTENT_ITEM_ID = p_CONTENT_ITEM_ID
  AND LABEL_CODE = p_LABEL_CODE;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

PROCEDURE LOAD_SEED_ROW (
 p_UPLOAD_MODE IN VARCHAR2,
 p_CONTENT_ITEM_ID IN NUMBER,
 p_LABEL_CODE IN VARCHAR2,
 p_CITEM_VERSION_ID IN NUMBER,
 p_OWNER    IN VARCHAR2,
 p_LAST_UPDATE_DATE IN VARCHAR2) IS

  l_temp NUMBER;

 BEGIN
	IF ( p_UPLOAD_MODE = 'NLS') THEN
		NULL;
	ELSE
	   BEGIN

		 SELECT '1' INTO l_temp
		 FROM IBC_LABELS_B
		 WHERE LABEL_CODE = p_LABEL_CODE;


		 SELECT '1' INTO l_temp FROM IBC_CITEM_VERSION_LABELS
		 WHERE last_updated_by <> 1
		 AND CITEM_VERSION_ID = p_CITEM_VERSION_ID
		 AND CONTENT_ITEM_ID = p_CONTENT_ITEM_ID;

		 EXCEPTION WHEN no_data_found THEN
			Ibc_Citem_Version_Labels_Pkg.LOAD_ROW(
				p_UPLOAD_MODE => p_UPLOAD_MODE,
				 p_CONTENT_ITEM_ID => p_UPLOAD_MODE,
				 p_LABEL_CODE => p_UPLOAD_MODE,
				 p_CITEM_VERSION_ID => p_UPLOAD_MODE,
				 p_OWNER  => p_UPLOAD_MODE,
				 p_LAST_UPDATE_DATE => p_UPLOAD_MODE);
            END;
	END IF;
 END LOAD_SEED_ROW;

PROCEDURE LOAD_ROW (
 p_UPLOAD_MODE IN VARCHAR2,
 p_CONTENT_ITEM_ID IN NUMBER,
 p_LABEL_CODE IN VARCHAR2,
 p_CITEM_VERSION_ID IN NUMBER,
 p_OWNER    IN VARCHAR2,
 p_LAST_UPDATE_DATE IN VARCHAR2) IS

 l_user_id    NUMBER := 0;
 l_row_id     VARCHAR2(64);
 l_object_version_number NUMBER := FND_API.G_MISS_NUM;
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
	FROM IBC_CITEM_VERSION_LABELS
	WHERE CONTENT_ITEM_ID = p_CONTENT_ITEM_ID
	AND LABEL_CODE = p_LABEL_CODE;

	IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
	db_user_id, db_last_update_date, p_upload_mode )) THEN
	BEGIN
		Ibc_Citem_Version_Labels_Pkg.UPDATE_ROW (
		p_content_item_id              => NVL(p_content_item_id,FND_API.G_MISS_NUM)
	       ,p_label_code                   => NVL(p_label_code,FND_API.G_MISS_CHAR)
	       ,p_citem_version_id             => NVL(p_citem_version_id,FND_API.G_MISS_NUM)
	       ,p_last_updated_by              => l_user_id
	       ,p_last_update_date             => SYSDATE
	       ,p_last_update_login            => 0
	       ,p_object_version_number        => l_object_version_number);
	   EXCEPTION
		WHEN NO_DATA_FOUND THEN
		Ibc_Citem_Version_Labels_Pkg.INSERT_ROW (
		x_rowid   => l_row_id,
		  p_CONTENT_ITEM_ID => p_CONTENT_ITEM_ID,
		  p_LABEL_CODE => p_LABEL_CODE,
		  p_CITEM_VERSION_ID => p_CITEM_VERSION_ID,
		  p_OBJECT_VERSION_NUMBER => 1,
		  p_CREATION_DATE     => SYSDATE,
		  p_CREATED_BY      => l_user_id,
		  p_LAST_UPDATE_DATE    => SYSDATE,
		  p_LAST_UPDATED_BY    => l_user_id,
		  p_LAST_UPDATE_LOGIN    => 0);
	END;
	END IF;
END LOAD_ROW;


END Ibc_Citem_Version_Labels_Pkg;

/
