--------------------------------------------------------
--  DDL for Package Body IBC_ASSOCIATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_ASSOCIATIONS_PKG" AS
/* $Header: ibctasnb.pls 120.1 2005/07/29 15:10:16 appldev ship $ */


-- Purpose: Table Handler for IBC_ASSOCIATIONS table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for FND_API.G_MISS_XXX
-- SHARMA 	     07/04/2005	     Modified LOAD_ROW, TRANSLATE_ROW and created
-- 			             LOAD_SEED_ROW for R12 LCT standards bug 4411674


PROCEDURE INSERT_ROW (
 x_rowid                           OUT NOCOPY VARCHAR2
,px_association_id                 IN OUT NOCOPY NUMBER
,p_content_item_id                 IN NUMBER
,p_citem_version_id                IN NUMBER
,p_association_type_code           IN VARCHAR2
,p_associated_object_val1          IN VARCHAR2
,p_associated_object_val2          IN VARCHAR2
,p_associated_object_val3          IN VARCHAR2
,p_associated_object_val4          IN VARCHAR2
,p_associated_object_val5          IN VARCHAR2
,p_object_version_number           IN NUMBER
,p_creation_date                   IN DATE          --DEFAULT NULL
,p_created_by                      IN NUMBER        --DEFAULT NULL
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
) IS

  CURSOR c IS SELECT ROWID FROM ibc_associations
    WHERE association_id = px_association_id;

  CURSOR c2 IS SELECT ibc_associations_s1.NEXTVAL FROM dual;

BEGIN

  -- Primary key validation check

  IF ((px_association_id IS NULL) OR
      (px_association_id = Fnd_Api.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO px_association_id;
    CLOSE c2;
  END IF;

  INSERT INTO ibc_associations (
     association_id
    ,content_item_id
    ,citem_version_id
    ,association_type_code
    ,associated_object_val1
    ,associated_object_val2
    ,associated_object_val3
    ,associated_object_val4
    ,associated_object_val5
    ,object_version_number
    ,creation_date
    ,created_by
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    )
  VALUES (
     px_association_id
    ,DECODE(p_content_item_id,Fnd_Api.G_MISS_NUM,NULL,p_content_item_id)
    ,DECODE(p_citem_version_id,Fnd_Api.G_MISS_NUM,NULL,p_citem_version_id)
    ,DECODE(p_association_type_code,Fnd_Api.G_MISS_CHAR,NULL,p_association_type_code)
    ,DECODE(p_associated_object_val1,Fnd_Api.G_MISS_CHAR,NULL,p_associated_object_val1)
    ,DECODE(p_associated_object_val2,Fnd_Api.G_MISS_CHAR,NULL,p_associated_object_val2)
    ,DECODE(p_associated_object_val3,Fnd_Api.G_MISS_CHAR,NULL,p_associated_object_val3)
    ,DECODE(p_associated_object_val4,Fnd_Api.G_MISS_CHAR,NULL,p_associated_object_val4)
    ,DECODE(p_associated_object_val5,Fnd_Api.G_MISS_CHAR,NULL,p_associated_object_val5)
    ,DECODE(p_object_version_number,Fnd_Api.G_MISS_NUM,NULL,p_object_version_number)
    ,DECODE(p_creation_date,Fnd_Api.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_creation_date)
    ,DECODE(p_created_by,Fnd_Api.G_MISS_NUM,Fnd_Global.user_id,NULL,Fnd_Global.user_id,p_created_by)
    ,DECODE(p_last_update_date,Fnd_Api.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,DECODE(p_last_updated_by,Fnd_Api.G_MISS_NUM,Fnd_Global.user_id,NULL,Fnd_Global.user_id,p_last_updated_by)
    ,DECODE(p_last_update_login,Fnd_Api.G_MISS_NUM,Fnd_Global.login_id,NULL,Fnd_Global.user_id,p_last_update_login)
	);




  OPEN c;
  FETCH c INTO x_rowid;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;


PROCEDURE UPDATE_ROW (
 p_association_id                  IN NUMBER
,p_content_item_id                 IN NUMBER        --DEFAULT NULL
,p_citem_version_id                IN NUMBER
,p_association_type_code           IN VARCHAR2      --DEFAULT NULL
,p_associated_object_val1          IN VARCHAR2      --DEFAULT NULL
,p_associated_object_val2          IN VARCHAR2      --DEFAULT NULL
,p_associated_object_val3          IN VARCHAR2      --DEFAULT NULL
,p_associated_object_val4          IN VARCHAR2      --DEFAULT NULL
,p_associated_object_val5          IN VARCHAR2      --DEFAULT NULL
,p_object_version_number           IN NUMBER        --DEFAULT NULL
,p_created_by                      IN NUMBER        --DEFAULT NULL
,p_creation_date                   IN DATE          --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
)
IS
BEGIN
  UPDATE ibc_associations SET
     content_item_id           = DECODE(p_content_item_id,Fnd_Api.G_MISS_NUM,NULL,NULL,content_item_id,p_content_item_id)
    ,citem_version_id          = DECODE(p_citem_version_id,Fnd_Api.G_MISS_NUM,NULL,NULL,citem_version_id,p_citem_version_id)
    ,association_type_code     = DECODE(p_association_type_code,Fnd_Api.G_MISS_CHAR,NULL,NULL,association_type_code,p_association_type_code)
    ,associated_object_val1    = DECODE(p_associated_object_val1,Fnd_Api.G_MISS_CHAR,NULL,NULL,associated_object_val1,p_associated_object_val1)
    ,associated_object_val2    = DECODE(p_associated_object_val2,Fnd_Api.G_MISS_CHAR,NULL,NULL,associated_object_val2,p_associated_object_val2)
    ,associated_object_val3    = DECODE(p_associated_object_val3,Fnd_Api.G_MISS_CHAR,NULL,NULL,associated_object_val3,p_associated_object_val3)
    ,associated_object_val4    = DECODE(p_associated_object_val4,Fnd_Api.G_MISS_CHAR,NULL,NULL,associated_object_val4,p_associated_object_val4)
    ,associated_object_val5    = DECODE(p_associated_object_val5,Fnd_Api.G_MISS_CHAR,NULL,NULL,associated_object_val5,p_associated_object_val5)
    ,last_updated_by           = DECODE(p_last_updated_by,Fnd_Api.G_MISS_NUM,Fnd_Global.user_id,NULL,Fnd_Global.user_id,p_last_updated_by)
    ,last_update_date          = DECODE(p_last_update_date,Fnd_Api.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,last_update_login         = DECODE(p_last_update_login,Fnd_Api.G_MISS_NUM,Fnd_Global.login_id,NULL,Fnd_Global.user_id,p_last_update_login)
    ,object_version_number     = object_version_number + 1
  WHERE association_id = p_association_id
  AND object_version_number = DECODE(p_object_version_number,
                                       Fnd_Api.g_miss_num,
                                       object_version_number,
									   NULL,
                                       object_version_number,
                                       p_object_version_number);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_ROW;

PROCEDURE delete_row (
  p_association_id IN NUMBER
) IS
BEGIN

  DELETE FROM ibc_associations
  WHERE association_id = p_association_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END delete_row;

PROCEDURE lock_row (
  p_association_id IN NUMBER,
  p_content_item_id IN NUMBER,
  p_citem_version_id IN NUMBER,
  p_association_type_code IN VARCHAR2,
  p_associated_object_val1 IN VARCHAR2,
  p_associated_object_val2 IN VARCHAR2,
  p_associated_object_val3 IN VARCHAR2,
  p_associated_object_val4 IN VARCHAR2,
  p_associated_object_val5 IN VARCHAR2,
  p_object_version_number IN NUMBER
) IS
  CURSOR c IS SELECT
      content_item_id,
      citem_version_id,
      association_type_code,
      associated_object_val1,
      associated_object_val2,
      associated_object_val3,
      associated_object_val4,
      associated_object_val5,
 	  object_version_number
    FROM ibc_associations
    WHERE association_id = p_association_id
    FOR UPDATE OF association_id NOWAIT;
  recinfo c%ROWTYPE;

BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    Fnd_Message.set_name('fnd', 'form_record_deleted');
    App_Exception.raise_exception;
  END IF;
  CLOSE c;
  IF (    (recinfo.content_item_id = p_content_item_id)
      AND ((recinfo.citem_version_id = p_citem_version_id)
           OR ((recinfo.citem_version_id IS NULL) AND (p_citem_version_id IS NULL)))
      AND (recinfo.association_type_code = p_association_type_code)
      AND (recinfo.associated_object_val1 = p_associated_object_val1)
      AND ((recinfo.associated_object_val2 = p_associated_object_val2)
           OR ((recinfo.associated_object_val2 IS NULL) AND (p_associated_object_val2 IS NULL)))
      AND ((recinfo.associated_object_val3 = p_associated_object_val3)
           OR ((recinfo.associated_object_val3 IS NULL) AND (p_associated_object_val3 IS NULL)))
      AND ((recinfo.associated_object_val4 = p_associated_object_val4)
           OR ((recinfo.associated_object_val4 IS NULL) AND (p_associated_object_val4 IS NULL)))
      AND ((recinfo.associated_object_val5 = p_associated_object_val5)
           OR ((recinfo.associated_object_val5 IS NULL) AND (p_associated_object_val5 IS NULL)))
      AND (recinfo.object_version_number = p_object_version_number))
   THEN
    NULL;
  ELSE
    Fnd_Message.set_name('fnd', 'form_record_changed');
    App_Exception.raise_exception;
  END IF;

END lock_row;

PROCEDURE LOAD_ROW (
 p_upload_mode IN VARCHAR2,
 p_association_id                  IN NUMBER
,p_content_item_id                 IN NUMBER
,p_citem_version_id                IN NUMBER
,p_association_type_code           IN VARCHAR2
,p_associated_object_val1          IN VARCHAR2
,p_associated_object_val2          IN VARCHAR2
,p_associated_object_val3          IN VARCHAR2
,p_associated_object_val4          IN VARCHAR2
,p_associated_object_val5          IN VARCHAR2
,p_OWNER   IN VARCHAR2
,p_last_update_date in VARCHAR2) IS

	l_user_id    NUMBER := 0;
	lx_rowid 	 VARCHAR2(240);
	lx_association_id	NUMBER := p_association_id;
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
	FROM IBC_ASSOCIATIONS
	WHERE ASSOCIATION_ID = To_NUMBER(p_association_id);
  BEGIN

	IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
		db_user_id, db_last_update_date, p_upload_mode )) THEN

		Ibc_Associations_Pkg.UPDATE_ROW (
			   p_CONTENT_ITEM_ID	=> p_content_item_id
			   ,p_CITEM_VERSION_ID  => p_citem_version_id
			   ,p_ASSOCIATION_ID	=> p_association_id
			   ,p_ASSOCIATION_TYPE_CODE	=> p_association_type_code
			   ,p_ASSOCIATED_OBJECT_VAL1	=> p_ASSOCIATED_OBJECT_VAL1
			   ,p_ASSOCIATED_OBJECT_VAL2	=> NVL(p_ASSOCIATED_OBJECT_VAL2,Fnd_Api.G_MISS_CHAR)
			   ,p_ASSOCIATED_OBJECT_VAL3	=> NVL(p_ASSOCIATED_OBJECT_VAL3,Fnd_Api.G_MISS_CHAR)
			   ,p_ASSOCIATED_OBJECT_VAL4	=> NVL(p_ASSOCIATED_OBJECT_VAL4,Fnd_Api.G_MISS_CHAR)
			   ,p_ASSOCIATED_OBJECT_VAL5	=> NVL(p_ASSOCIATED_OBJECT_VAL5,Fnd_Api.G_MISS_CHAR)
			   ,p_last_updated_by           => l_user_id
			   ,p_last_update_date          => SYSDATE
			   ,p_last_update_login         => 0
			   ,p_object_version_number     => NULL);

	END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN

		Ibc_Associations_Pkg.INSERT_ROW (
			 x_rowid => lx_rowid
			,px_ASSOCIATION_ID => lx_association_id
			,p_CONTENT_ITEM_ID => p_content_item_id
			,p_CITEM_VERSION_ID => p_citem_version_id
			,p_ASSOCIATION_TYPE_CODE	=> p_association_type_code
			,p_ASSOCIATED_OBJECT_VAL1	=> p_ASSOCIATED_OBJECT_VAL1
			,p_ASSOCIATED_OBJECT_VAL2	=> NVL(p_ASSOCIATED_OBJECT_VAL2,Fnd_Api.G_MISS_CHAR)
			,p_ASSOCIATED_OBJECT_VAL3	=> NVL(p_ASSOCIATED_OBJECT_VAL3,Fnd_Api.G_MISS_CHAR)
			,p_ASSOCIATED_OBJECT_VAL4	=> NVL(p_ASSOCIATED_OBJECT_VAL4,Fnd_Api.G_MISS_CHAR)
			,p_ASSOCIATED_OBJECT_VAL5	=> NVL(p_ASSOCIATED_OBJECT_VAL5,Fnd_Api.G_MISS_CHAR)
			,p_CREATION_DATE       		=> SYSDATE
			,p_CREATED_BY        		=> l_user_id
			,p_LAST_UPDATE_DATE      	=> SYSDATE
			,p_LAST_UPDATED_BY      	=> l_user_id
			,p_LAST_UPDATE_LOGIN      	=> 0
			,p_OBJECT_VERSION_NUMBER   	=> 1);
   END;

END LOAD_ROW;

PROCEDURE LOAD_SEED_ROW (
 p_upload_mode IN VARCHAR2,
 p_association_id                  IN NUMBER
,p_content_item_id                 IN NUMBER
,p_citem_version_id                IN NUMBER DEFAULT NULL
,p_association_type_code           IN VARCHAR2
,p_associated_object_val1          IN VARCHAR2
,p_associated_object_val2          IN VARCHAR2
,p_associated_object_val3          IN VARCHAR2
,p_associated_object_val4          IN VARCHAR2
,p_associated_object_val5          IN VARCHAR2
,p_OWNER      			   IN VARCHAR2,
p_last_update_date in VARCHAR2) IS
BEGIN
	IF (p_UPLOAD_MODE = 'NLS') THEN
		NULL;
	ELSE
		IBC_ASSOCIATIONS_PKG.LOAD_ROW (
			p_upload_mode => p_upload_mode,
			 p_association_id =>  p_association_id
			,p_content_item_id   => p_content_item_id
			,p_citem_version_id    => p_citem_version_id
			,p_association_type_code  => p_association_type_code
			,p_associated_object_val1   => p_associated_object_val1
			,p_associated_object_val2    => p_associated_object_val2
			,p_associated_object_val3   => p_associated_object_val3
			,p_associated_object_val4    => p_associated_object_val4
			,p_associated_object_val5   => p_associated_object_val5
			,p_OWNER => p_OWNER,
			p_last_update_date => p_last_update_date);
	END IF;
END;

END Ibc_Associations_Pkg;

/
