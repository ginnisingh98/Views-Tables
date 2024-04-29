--------------------------------------------------------
--  DDL for Package Body IBC_COMPOUND_RELATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_COMPOUND_RELATIONS_PKG" AS
/* $Header: ibctcrlb.pls 120.1 2005/07/29 15:03:56 appldev ship $*/

-- Purpose: Table Handler for Ibc_Compound_Relations table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for FND_API.G_MISS_XXX
-- shitij.vatsa      02/11/2003      Added parameter p_subitem_version_id
--                                   to the APIs
-- SHARMA 	     07/04/2005	     Modified LOAD_ROW, TRANSLATE_ROW and created
-- 			             LOAD_SEED_ROW for R12 LCT standards bug 4411674

PROCEDURE INSERT_ROW (
 x_rowid                           OUT NOCOPY VARCHAR2
,px_compound_relation_id           IN OUT NOCOPY NUMBER
,p_content_item_id                 IN NUMBER
,p_attribute_type_code             IN VARCHAR2
,p_content_type_code               IN VARCHAR2
,p_citem_version_id                IN NUMBER
,p_object_version_number           IN NUMBER
,p_sort_order                      IN NUMBER
,p_creation_date                   IN DATE          --DEFAULT NULL
,p_created_by                      IN NUMBER        --DEFAULT NULL
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
,p_subitem_version_id              IN NUMBER        --DEFAULT NULL
) IS
  CURSOR C IS SELECT ROWID FROM IBC_COMPOUND_RELATIONS
  WHERE   compound_relation_id =   compound_relation_id;

  CURSOR c2 IS SELECT ibc_compound_relations_s1.NEXTVAL FROM dual;

BEGIN

  -- Primary key validation check

  IF ((px_compound_relation_id IS NULL) OR
      (px_compound_relation_id = FND_API.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO px_compound_relation_id;
    CLOSE c2;
  END IF;

  INSERT INTO IBC_COMPOUND_RELATIONS (
    compound_relation_id,
    CONTENT_ITEM_ID,
    ATTRIBUTE_TYPE_CODE,
    CONTENT_TYPE_CODE,
    CITEM_VERSION_ID,
    SORT_ORDER,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SUBITEM_VERSION_ID
  ) VALUES (
     px_compound_relation_id
    ,p_content_item_id
    ,p_attribute_type_code
    ,p_content_type_code
    ,p_citem_version_id
    ,p_sort_order
    ,DECODE(p_object_version_number,FND_API.G_MISS_NUM,1,NULL,1,p_object_version_number)
    ,DECODE(p_creation_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_creation_date)
    ,DECODE(p_created_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_created_by)
    ,DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
    ,DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
    ,p_subitem_version_id
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
  p_compound_relation_id IN NUMBER,
  p_CONTENT_ITEM_ID IN NUMBER,
  p_ATTRIBUTE_TYPE_CODE IN VARCHAR2,
  p_CONTENT_TYPE_CODE IN VARCHAR2,
  p_CITEM_VERSION_ID IN NUMBER,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_SORT_ORDER IN NUMBER
) IS
  CURSOR c IS SELECT
      OBJECT_VERSION_NUMBER,
   SORT_ORDER
    FROM IBC_COMPOUND_RELATIONS
    WHERE compound_relation_id = p_compound_relation_id
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
  IF (    (recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
    AND (recinfo.SORT_ORDER = p_SORT_ORDER)
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

END LOCK_ROW;

PROCEDURE UPDATE_ROW (
 p_compound_relation_id            IN NUMBER
,p_attribute_type_code             IN VARCHAR2      --DEFAULT NULL
,p_citem_version_id                IN NUMBER        --DEFAULT NULL
,p_content_item_id                 IN NUMBER        --DEFAULT NULL
,p_content_type_code               IN VARCHAR2      --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
,p_object_version_number           IN NUMBER        --DEFAULT NULL
,p_sort_order                      IN NUMBER        --DEFAULT NULL
,p_subitem_version_id              IN NUMBER        --DEFAULT NULL
) IS
BEGIN
  UPDATE IBC_COMPOUND_RELATIONS SET
     content_item_id                = DECODE(p_content_item_id,FND_API.G_MISS_NUM,NULL,NULL,content_item_id,p_content_item_id)
    ,attribute_type_code            = DECODE(p_attribute_type_code,FND_API.G_MISS_CHAR,NULL,NULL,attribute_type_code,p_attribute_type_code)
    ,content_type_code              = DECODE(p_content_type_code,FND_API.G_MISS_CHAR,NULL,NULL,content_type_code,p_content_type_code)
    ,citem_version_id               = DECODE(p_citem_version_id,FND_API.G_MISS_NUM,NULL,NULL,citem_version_id,p_citem_version_id)
    ,sort_order                     = DECODE(p_sort_order,FND_API.G_MISS_NUM,NULL,NULL,sort_order,p_sort_order)
    ,object_version_number          = NVL(object_version_number,0) + 1
    ,last_update_date               = DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,last_updated_by                = DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
    ,last_update_login              = DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
    ,subitem_version_id             = DECODE(p_subitem_version_id,FND_API.G_MISS_NUM,NULL,NULL,subitem_version_id,p_subitem_version_id)
  WHERE compound_relation_id =   p_compound_relation_id;

 -- Ignore object_version number as this table will always be updated in conjuction
 -- with
 /* AND object_version_number = DECODE(p_object_version_number,
                                       FND_API.G_MISS_NUM,
                                       object_version_number,
                                       NULL,
                                       object_version_number,
                                       p_object_version_number);*/

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  p_compound_relation_id IN NUMBER
) IS
BEGIN

  DELETE FROM IBC_COMPOUND_RELATIONS
  WHERE compound_relation_id =   p_compound_relation_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

PROCEDURE LOAD_SEED_ROW (
  p_UPLOAD_MODE IN VARCHAR2,
  p_CONTENT_ITEM_ID    NUMBER,
  p_ATTRIBUTE_TYPE_CODE   VARCHAR2,
  p_CONTENT_TYPE_CODE      VARCHAR2,
  p_COMPOUND_RELATION_ID   NUMBER,
  p_CITEM_VERSION_ID     NUMBER,
  p_SORT_ORDER       NUMBER,
  p_OWNER    IN VARCHAR2,
  p_subitem_version_id    IN NUMBER        DEFAULT NULL,
  p_LAST_UPDATE_DATE IN VARCHAR2) IS
BEGIN
	IF (p_UPLOAD_MODE = 'NLS') THEN
		NULL;
	ELSE
		Ibc_Compound_Relations_Pkg.LOAD_ROW (
			p_UPLOAD_MODE => p_UPLOAD_MODE,
			p_CONTENT_ITEM_ID => p_CONTENT_ITEM_ID,
			p_ATTRIBUTE_TYPE_CODE => p_ATTRIBUTE_TYPE_CODE,
			p_CONTENT_TYPE_CODE => p_CONTENT_TYPE_CODE,
			p_COMPOUND_RELATION_ID => p_COMPOUND_RELATION_ID,
			p_CITEM_VERSION_ID => p_CITEM_VERSION_ID,
			p_SORT_ORDER  => p_SORT_ORDER,
			p_OWNER => p_OWNER,
			p_subitem_version_id => p_subitem_version_id,
			p_LAST_UPDATE_DATE => p_LAST_UPDATE_DATE );
	END IF;
END;


PROCEDURE LOAD_ROW (
  p_UPLOAD_MODE IN VARCHAR2,
  p_CONTENT_ITEM_ID    NUMBER,
  p_ATTRIBUTE_TYPE_CODE   VARCHAR2,
  p_CONTENT_TYPE_CODE      VARCHAR2,
  p_COMPOUND_RELATION_ID   NUMBER,
  p_CITEM_VERSION_ID     NUMBER,
  p_SORT_ORDER       NUMBER,
  p_OWNER    IN VARCHAR2,
  p_subitem_version_id    IN NUMBER        DEFAULT NULL,
  p_LAST_UPDATE_DATE IN VARCHAR2) IS

  l_user_id    NUMBER := 0;
  l_row_id     VARCHAR2(64);
  lx_object_version_number NUMBER := FND_API.G_MISS_NUM;
  lx_COMPOUND_RELATION_ID  NUMBER := p_COMPOUND_RELATION_ID;
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
	FROM IBC_COMPOUND_RELATIONS
	WHERE p_compound_relation_id = p_compound_relation_id;

	IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
		db_user_id, db_last_update_date, p_upload_mode )) THEN

		 UPDATE_ROW (
			p_compound_relation_id         => NVL(p_compound_relation_id,FND_API.G_MISS_NUM)
			,p_content_item_id              => NVL(p_content_item_id,FND_API.G_MISS_NUM)
			,p_attribute_type_code          => NVL(p_attribute_type_code,FND_API.G_MISS_CHAR)
			,p_content_type_code            => NVL(p_content_type_code,FND_API.G_MISS_CHAR)
		       ,p_citem_version_id             => NVL(p_citem_version_id,FND_API.G_MISS_NUM)
		       ,p_sort_order                   => NVL(p_sort_order,FND_API.G_MISS_NUM)
		       ,p_last_updated_by              => l_user_id
		       ,p_last_update_date             => SYSDATE
		       ,p_last_update_login            => 0
		       ,p_object_version_number        => NULL
		       ,p_subitem_version_id           => NVL(p_subitem_version_id,FND_API.G_MISS_NUM)
		       );
	END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       INSERT_ROW (
          X_ROWID => l_row_id,
          px_COMPOUND_RELATION_ID => lx_COMPOUND_RELATION_ID,
          p_CONTENT_ITEM_ID     => p_CONTENT_ITEM_ID,
          p_ATTRIBUTE_TYPE_CODE  => p_ATTRIBUTE_TYPE_CODE,
          p_CONTENT_TYPE_CODE  => p_CONTENT_TYPE_CODE,
          p_CITEM_VERSION_ID  => p_CITEM_VERSION_ID,
          p_SORT_ORDER    => p_SORT_ORDER,
          p_OBJECT_VERSION_NUMBER => 1,
          p_CREATION_DATE     => SYSDATE,
          p_CREATED_BY      => l_user_id,
          p_LAST_UPDATE_DATE    => SYSDATE,
          p_LAST_UPDATED_BY    => l_user_id,
          p_LAST_UPDATE_LOGIN    => 0,
          p_subitem_version_id => p_subitem_version_id);
END LOAD_ROW;


END Ibc_Compound_Relations_Pkg;

/
