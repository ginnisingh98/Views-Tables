--------------------------------------------------------
--  DDL for Package Body GMD_TEST_METHODS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_TEST_METHODS_PVT" as
/* $Header: GMDVMTDB.pls 120.1 2006/06/16 11:28:51 rlnagara noship $ */

PROCEDURE TRANSLATE_ROW
  (
   	X_TEST_METHOD_ID      		IN NUMBER,
   	X_TEST_METHOD_DESC    		IN VARCHAR2,
   	X_OWNER       	 		    IN VARCHAR2
  ) IS
BEGIN
   UPDATE GMD_TEST_METHODS_TL SET
     TEST_METHOD_ID             = X_TEST_METHOD_ID,
     TEST_METHOD_DESC		    = X_TEST_METHOD_DESC,
     LAST_UPDATE_DATE           = sysdate,
     LAST_UPDATED_BY            = Decode(X_OWNER, 'SEED', 1, 0),
     LAST_UPDATE_LOGIN          = 0,
     SOURCE_LANG                = userenv('LANG')
     WHERE TEST_METHOD_ID       = X_TEST_METHOD_ID AND
           userenv('LANG') IN (language, source_lang);
END TRANSLATE_ROW;

PROCEDURE LOAD_ROW
  (
 	X_TEST_METHOD_ID                   IN  NUMBER,
 	X_TEST_METHOD_CODE                 IN  VARCHAR2,
 	X_TEST_METHOD_DESC                 IN  VARCHAR2,
 	X_TEST_QTY                         IN  NUMBER,
 	X_TEST_QTY_UOM                     IN  VARCHAR2,
 	X_DELETE_MARK                      IN NUMBER,
 	X_DISPLAY_PRECISION                IN NUMBER,
 	X_TEST_DURATION                    IN NUMBER,
 	X_DAYS                             IN NUMBER,
 	X_HOURS                            IN NUMBER,
 	X_MINUTES                          IN NUMBER,
 	X_SECONDS                          IN NUMBER,
 	X_TEST_REPLICATE                   IN NUMBER,
 	X_RESOURCES                        IN VARCHAR2,
 	X_TEST_KIT_ORGANIZATION_ID         IN NUMBER,
 	X_TEST_KIT_INV_ITEM_ID             IN NUMBER,
 	X_TEXT_CODE                        IN NUMBER,
 	X_ATTRIBUTE_CATEGORY               IN VARCHAR2,
 	X_ATTRIBUTE1                       IN VARCHAR2,
 	X_ATTRIBUTE2                       IN VARCHAR2,
 	X_ATTRIBUTE3                       IN VARCHAR2,
 	X_ATTRIBUTE4                       IN VARCHAR2,
 	X_ATTRIBUTE5                       IN VARCHAR2,
 	X_ATTRIBUTE6                       IN VARCHAR2,
 	X_ATTRIBUTE7                       IN VARCHAR2,
 	X_ATTRIBUTE8                       IN VARCHAR2,
 	X_ATTRIBUTE9                       IN VARCHAR2,
 	X_ATTRIBUTE10                      IN VARCHAR2,
 	X_ATTRIBUTE11                      IN VARCHAR2,
 	X_ATTRIBUTE12                      IN VARCHAR2,
 	X_ATTRIBUTE13                      IN VARCHAR2,
 	X_ATTRIBUTE14                      IN VARCHAR2,
 	X_ATTRIBUTE15                      IN VARCHAR2,
 	X_ATTRIBUTE16                      IN VARCHAR2,
 	X_ATTRIBUTE17                      IN VARCHAR2,
 	X_ATTRIBUTE18                      IN VARCHAR2,
 	X_ATTRIBUTE19                      IN VARCHAR2,
 	X_ATTRIBUTE20                      IN VARCHAR2,
 	X_ATTRIBUTE21                      IN VARCHAR2,
 	X_ATTRIBUTE22                      IN VARCHAR2,
 	X_ATTRIBUTE23                      IN VARCHAR2,
 	X_ATTRIBUTE24                      IN VARCHAR2,
 	X_ATTRIBUTE25                      IN VARCHAR2,
 	X_ATTRIBUTE26                      IN VARCHAR2,
 	X_ATTRIBUTE27                      IN VARCHAR2,
 	X_ATTRIBUTE28                      IN VARCHAR2,
 	X_ATTRIBUTE29                      IN VARCHAR2,
 	X_ATTRIBUTE30                      IN VARCHAR2,
    X_OWNER                            IN VARCHAR2
  )IS
    cursor c1 is select * from GMD_TEST_METHODS_B where (TEST_METHOD_ID=X_TEST_METHOD_ID);
    l_pkpresent c1%rowtype;
    l_user_id                  NUMBER := 0;
    l_sysdate                  DATE;
    l_test_method_id           NUMBER;

   BEGIN
     IF (x_owner = 'SEED') THEN
         l_user_id := 1;
     END IF;
     select sysdate into l_sysdate from dual;

     OPEN c1;
     fetch c1 into l_pkpresent;
     IF (c1%found) THEN

  	UPDATE GMD_TEST_METHODS_B SET
 		TEST_METHOD_CODE               = X_TEST_METHOD_CODE,
 		TEST_QTY                       = X_TEST_QTY,
 		TEST_QTY_UOM                   = X_TEST_QTY_UOM,
 		DELETE_MARK                    = X_DELETE_MARK ,
 		DISPLAY_PRECISION              = X_DISPLAY_PRECISION,
 		TEST_DURATION                  = X_TEST_DURATION,
 		DAYS                           = X_DAYS,
 		HOURS                          = X_HOURS ,
 		MINUTES                        = X_MINUTES ,
 		SECONDS                        = X_SECONDS ,
 		TEST_REPLICATE                 = X_TEST_REPLICATE,
 		RESOURCES                      = X_RESOURCES,
 		TEST_KIT_ORGANIZATION_ID       = X_TEST_KIT_ORGANIZATION_ID,
 		TEST_KIT_INV_ITEM_ID           = X_TEST_KIT_INV_ITEM_ID,
 		TEXT_CODE                      = X_TEXT_CODE,
 		ATTRIBUTE_CATEGORY             = X_ATTRIBUTE_CATEGORY,
 		ATTRIBUTE1                     = X_ATTRIBUTE1,
 		ATTRIBUTE2                     = X_ATTRIBUTE2,
 		ATTRIBUTE3                     = X_ATTRIBUTE3,
 		ATTRIBUTE4                     = X_ATTRIBUTE4,
 		ATTRIBUTE5                     = X_ATTRIBUTE5,
 		ATTRIBUTE6                     = X_ATTRIBUTE6,
 		ATTRIBUTE7                     = X_ATTRIBUTE7,
 		ATTRIBUTE8                     = X_ATTRIBUTE8,
 		ATTRIBUTE9                     = X_ATTRIBUTE9,
 		ATTRIBUTE10                    = X_ATTRIBUTE10,
 		ATTRIBUTE11                    = X_ATTRIBUTE11,
 		ATTRIBUTE12                    = X_ATTRIBUTE12,
 		ATTRIBUTE13                    = X_ATTRIBUTE13,
 		ATTRIBUTE14                    = X_ATTRIBUTE14,
 		ATTRIBUTE15                    = X_ATTRIBUTE15,
 		ATTRIBUTE16                    = X_ATTRIBUTE16,
 		ATTRIBUTE17                    = X_ATTRIBUTE17,
 		ATTRIBUTE18                    = X_ATTRIBUTE18,
 		ATTRIBUTE19                    = X_ATTRIBUTE19,
 		ATTRIBUTE20                    = X_ATTRIBUTE20,
 		ATTRIBUTE21                    = X_ATTRIBUTE21,
 		ATTRIBUTE22                    = X_ATTRIBUTE22,
 		ATTRIBUTE23                    = X_ATTRIBUTE23,
 		ATTRIBUTE24                    = X_ATTRIBUTE24,
 		ATTRIBUTE25                    = X_ATTRIBUTE25,
 		ATTRIBUTE26                    = X_ATTRIBUTE26,
 		ATTRIBUTE27                    = X_ATTRIBUTE27,
 		ATTRIBUTE28                    = X_ATTRIBUTE28,
 		ATTRIBUTE29                    = X_ATTRIBUTE29,
 		ATTRIBUTE30                    = X_ATTRIBUTE30,
             	LAST_UPDATE_DATE	       = l_sysdate,
             	LAST_UPDATED_BY		       = l_user_id,
             	LAST_UPDATE_LOGIN              = 0
  	WHERE  TEST_METHOD_ID		       = X_TEST_METHOD_ID;

   	UPDATE GMD_TEST_METHODS_TL SET
  		TEST_METHOD_DESC 	       = X_TEST_METHOD_DESC,
	        LAST_UPDATE_DATE	       = l_sysdate,
                LAST_UPDATED_BY                = l_user_id,
                LAST_UPDATE_LOGIN              = 0,
                SOURCE_LANG                    = userenv('LANG')
       	WHERE TEST_METHOD_ID = X_TEST_METHOD_ID and
             userenv('LANG') in (LANGUAGE,SOURCE_LANG);

      	ELSIF (c1%notfound) then

       	INSERT INTO  GMD_TEST_METHODS_B(
  		TEST_METHOD_ID,
  		TEST_METHOD_CODE,
  		TEST_QTY,
  		TEST_QTY_UOM,
  		DELETE_MARK,
  		DISPLAY_PRECISION,
  		TEST_DURATION,
  		DAYS,
  		HOURS,
  		MINUTES,
  		SECONDS,
  		TEST_REPLICATE,
  		RESOURCES,
  		TEST_KIT_ORGANIZATION_ID,
  		TEST_KIT_INV_ITEM_ID,
  		TEXT_CODE,
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
  		ATTRIBUTE16,
  		ATTRIBUTE17,
  		ATTRIBUTE18,
  		ATTRIBUTE19,
  		ATTRIBUTE20,
  		ATTRIBUTE21,
  		ATTRIBUTE22,
  		ATTRIBUTE23,
  		ATTRIBUTE24,
  		ATTRIBUTE25,
  		ATTRIBUTE26,
  		ATTRIBUTE27,
  		ATTRIBUTE28,
  		ATTRIBUTE29,
 		ATTRIBUTE30,
 		CREATION_DATE,
                CREATED_BY,
             	LAST_UPDATE_DATE,
             	LAST_UPDATED_BY,
             	LAST_UPDATE_LOGIN)
            VALUES(
        	X_TEST_METHOD_ID,
        	X_TEST_METHOD_CODE,
        	X_TEST_QTY,
        	X_TEST_QTY_UOM,
        	X_DELETE_MARK,
        	X_DISPLAY_PRECISION,
        	X_TEST_DURATION,
        	X_DAYS,
        	X_HOURS,
        	X_MINUTES,
        	X_SECONDS,
        	X_TEST_REPLICATE,
        	X_RESOURCES,
        	X_TEST_KIT_ORGANIZATION_ID,
        	X_TEST_KIT_INV_ITEM_ID,
        	X_TEXT_CODE,
        	X_ATTRIBUTE_CATEGORY,
        	X_ATTRIBUTE1,
        	X_ATTRIBUTE2,
        	X_ATTRIBUTE3,
        	X_ATTRIBUTE4,
        	X_ATTRIBUTE5,
        	X_ATTRIBUTE6,
        	X_ATTRIBUTE7,
        	X_ATTRIBUTE8,
        	X_ATTRIBUTE9,
        	X_ATTRIBUTE10,
        	X_ATTRIBUTE11,
        	X_ATTRIBUTE12,
        	X_ATTRIBUTE13,
        	X_ATTRIBUTE14,
        	X_ATTRIBUTE15,
        	X_ATTRIBUTE16,
        	X_ATTRIBUTE17,
        	X_ATTRIBUTE18,
        	X_ATTRIBUTE19,
        	X_ATTRIBUTE20,
        	X_ATTRIBUTE21,
        	X_ATTRIBUTE22,
        	X_ATTRIBUTE23,
        	X_ATTRIBUTE24,
        	X_ATTRIBUTE25,
        	X_ATTRIBUTE26,
        	X_ATTRIBUTE27,
        	X_ATTRIBUTE28,
        	X_ATTRIBUTE29,
        	X_ATTRIBUTE30,
           	l_sysdate,
           	l_user_id,
            	l_sysdate,
            	l_user_id,
            	0);

	INSERT into GMD_TEST_METHODS_TL(
  		TEST_METHOD_ID,
	  	TEST_METHOD_DESC,
	       	CREATION_DATE,
	       	CREATED_BY,
	       	LAST_UPDATE_DATE,
	        LAST_UPDATED_BY,
	        LAST_UPDATE_LOGIN,
	       	LANGUAGE,
	        SOURCE_LANG
	       )SELECT
	             X_TEST_METHOD_ID,
	             X_TEST_METHOD_DESC,
	             l_sysdate,
	             l_user_id,
	             l_sysdate,
	             l_user_id,
	             0,
	             L.LANGUAGE_CODE,
	             userenv('LANG')
	         FROM FND_LANGUAGES L
	         WHERE L.INSTALLED_FLAG in ('I','B') and not exists
                         (select NULL
                         from GMD_TEST_METHODS_TL T
                         where T.TEST_METHOD_ID = X_TEST_METHOD_ID
                         and T.LANGUAGE = L.LANGUAGE_CODE);

      END IF;
     CLOSE c1;
     COMMIT;
END LOAD_ROW;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TEST_METHOD_ID in NUMBER,
  X_TEST_METHOD_CODE in VARCHAR2,
  X_TEST_QTY in NUMBER,
  X_TEST_QTY_UOM in VARCHAR2,
  X_DISPLAY_PRECISION in NUMBER,
  X_TEST_DURATION in NUMBER,
  X_DAYS in NUMBER,
  X_HOURS in NUMBER,
  X_MINUTES in NUMBER,
  X_SECONDS in NUMBER,
  X_TEST_REPLICATE in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_RESOURCES in VARCHAR2,
  X_TEST_KIT_ORGANIZATION_ID NUMBER,
  X_TEST_KIT_INV_ITEM_ID in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_TEST_METHOD_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMD_TEST_METHODS_B
    where TEST_METHOD_ID = X_TEST_METHOD_ID
    ;
begin
  insert into GMD_TEST_METHODS_B (
    TEST_METHOD_ID,
    TEST_METHOD_CODE,
    TEST_QTY,
    TEST_QTY_UOM,
    DISPLAY_PRECISION,
    TEST_DURATION,
    DAYS,
    HOURS,
    MINUTES,
    SECONDS,
    TEST_REPLICATE,
    DELETE_MARK,
    RESOURCES,
    TEST_KIT_ORGANIZATION_ID,
    TEST_KIT_INV_ITEM_ID,
    TEXT_CODE,
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
    ATTRIBUTE16,
    ATTRIBUTE17,
    ATTRIBUTE18,
    ATTRIBUTE19,
    ATTRIBUTE20,
    ATTRIBUTE21,
    ATTRIBUTE22,
    ATTRIBUTE23,
    ATTRIBUTE24,
    ATTRIBUTE25,
    ATTRIBUTE26,
    ATTRIBUTE27,
    ATTRIBUTE28,
    ATTRIBUTE29,
    ATTRIBUTE30,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_TEST_METHOD_ID,
    X_TEST_METHOD_CODE,
    X_TEST_QTY,
    X_TEST_QTY_UOM,
    X_DISPLAY_PRECISION,
    X_TEST_DURATION,
    X_DAYS,
    X_HOURS,
    X_MINUTES,
    X_SECONDS,
    X_TEST_REPLICATE,
    X_DELETE_MARK,
    X_RESOURCES,
    X_TEST_KIT_ORGANIZATION_ID,
    X_TEST_KIT_INV_ITEM_ID,
    X_TEXT_CODE,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_ATTRIBUTE16,
    X_ATTRIBUTE17,
    X_ATTRIBUTE18,
    X_ATTRIBUTE19,
    X_ATTRIBUTE20,
    X_ATTRIBUTE21,
    X_ATTRIBUTE22,
    X_ATTRIBUTE23,
    X_ATTRIBUTE24,
    X_ATTRIBUTE25,
    X_ATTRIBUTE26,
    X_ATTRIBUTE27,
    X_ATTRIBUTE28,
    X_ATTRIBUTE29,
    X_ATTRIBUTE30,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into GMD_TEST_METHODS_TL (
    TEST_METHOD_ID,
    TEST_METHOD_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TEST_METHOD_ID,
    X_TEST_METHOD_DESC,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from GMD_TEST_METHODS_TL T
    where T.TEST_METHOD_ID = X_TEST_METHOD_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_TEST_METHOD_ID in NUMBER,
  X_TEST_METHOD_CODE in VARCHAR2,
  X_TEST_QTY in NUMBER,
  X_TEST_QTY_UOM in VARCHAR2,
  X_DISPLAY_PRECISION in NUMBER,
  X_TEST_DURATION in NUMBER,
  X_DAYS in NUMBER,
  X_HOURS in NUMBER,
  X_MINUTES in NUMBER,
  X_SECONDS in NUMBER,
  X_TEST_REPLICATE in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_RESOURCES in VARCHAR2,
  X_TEST_KIT_ORGANIZATION_ID in NUMBER,
  X_TEST_KIT_INV_ITEM_ID in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_TEST_METHOD_DESC in VARCHAR2
) is
  cursor c is select
      TEST_METHOD_CODE,
      TEST_QTY,
      TEST_QTY_UOM,
      DISPLAY_PRECISION,
      TEST_DURATION,
      DAYS,
      HOURS,
      MINUTES,
      SECONDS,
      TEST_REPLICATE,
      DELETE_MARK,
      RESOURCES,
      TEST_KIT_ORGANIZATION_ID,
      TEST_KIT_INV_ITEM_ID,
      TEXT_CODE,
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
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      ATTRIBUTE21,
      ATTRIBUTE22,
      ATTRIBUTE23,
      ATTRIBUTE24,
      ATTRIBUTE25,
      ATTRIBUTE26,
      ATTRIBUTE27,
      ATTRIBUTE28,
      ATTRIBUTE29,
      ATTRIBUTE30
    from GMD_TEST_METHODS_B
    where TEST_METHOD_ID = X_TEST_METHOD_ID
    for update of TEST_METHOD_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TEST_METHOD_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMD_TEST_METHODS_TL
    where TEST_METHOD_ID = X_TEST_METHOD_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TEST_METHOD_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.TEST_METHOD_CODE = X_TEST_METHOD_CODE)
      AND ((recinfo.TEST_QTY = X_TEST_QTY)
           OR ((recinfo.TEST_QTY is null) AND (X_TEST_QTY is null)))
      AND ((recinfo.TEST_QTY_UOM = X_TEST_QTY_UOM)
           OR ((recinfo.TEST_QTY_UOM is null) AND (X_TEST_QTY_UOM is null)))
      AND ((recinfo.DISPLAY_PRECISION = X_DISPLAY_PRECISION)
           OR ((recinfo.DISPLAY_PRECISION is null) AND (X_DISPLAY_PRECISION is null)))
      AND ((recinfo.TEST_DURATION = X_TEST_DURATION)
           OR ((recinfo.TEST_DURATION is null) AND (X_TEST_DURATION is null)))
      AND ((recinfo.DAYS = X_DAYS)
           OR ((recinfo.DAYS is null) AND (X_DAYS is null)))
     AND ((recinfo.HOURS = X_HOURS)
           OR ((recinfo.HOURS is null) AND (X_HOURS is null)))
     AND ((recinfo.MINUTES = X_MINUTES)
           OR ((recinfo.MINUTES is null) AND (X_MINUTES is null)))
     AND ((recinfo.SECONDS = X_SECONDS)
           OR ((recinfo.SECONDS is null) AND (X_SECONDS is null)))
      AND (recinfo.TEST_REPLICATE = X_TEST_REPLICATE)
      AND (recinfo.DELETE_MARK = X_DELETE_MARK)
      AND ((recinfo.RESOURCES = X_RESOURCES)
           OR ((recinfo.RESOURCES is null) AND (X_RESOURCES is null)))
      AND ((recinfo.TEST_KIT_ORGANIZATION_ID = X_TEST_KIT_ORGANIZATION_ID)
           OR ((recinfo.TEST_KIT_ORGANIZATION_ID is null) AND (X_TEST_KIT_ORGANIZATION_ID is null)))
      AND ((recinfo.TEST_KIT_INV_ITEM_ID = X_TEST_KIT_INV_ITEM_ID)
           OR ((recinfo.TEST_KIT_INV_ITEM_ID is null) AND (X_TEST_KIT_INV_ITEM_ID is null)))
      AND ((recinfo.TEXT_CODE = X_TEXT_CODE)
           OR ((recinfo.TEXT_CODE is null) AND (X_TEXT_CODE is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
           OR ((recinfo.ATTRIBUTE16 is null) AND (X_ATTRIBUTE16 is null)))
      AND ((recinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
           OR ((recinfo.ATTRIBUTE17 is null) AND (X_ATTRIBUTE17 is null)))
      AND ((recinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
           OR ((recinfo.ATTRIBUTE18 is null) AND (X_ATTRIBUTE18 is null)))
      AND ((recinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
           OR ((recinfo.ATTRIBUTE19 is null) AND (X_ATTRIBUTE19 is null)))
      AND ((recinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
           OR ((recinfo.ATTRIBUTE20 is null) AND (X_ATTRIBUTE20 is null)))
      AND ((recinfo.ATTRIBUTE21 = X_ATTRIBUTE21)
           OR ((recinfo.ATTRIBUTE21 is null) AND (X_ATTRIBUTE21 is null)))
      AND ((recinfo.ATTRIBUTE22 = X_ATTRIBUTE22)
           OR ((recinfo.ATTRIBUTE22 is null) AND (X_ATTRIBUTE22 is null)))
      AND ((recinfo.ATTRIBUTE23 = X_ATTRIBUTE23)
           OR ((recinfo.ATTRIBUTE23 is null) AND (X_ATTRIBUTE23 is null)))
      AND ((recinfo.ATTRIBUTE24 = X_ATTRIBUTE24)
           OR ((recinfo.ATTRIBUTE24 is null) AND (X_ATTRIBUTE24 is null)))
      AND ((recinfo.ATTRIBUTE25 = X_ATTRIBUTE25)
           OR ((recinfo.ATTRIBUTE25 is null) AND (X_ATTRIBUTE25 is null)))
      AND ((recinfo.ATTRIBUTE26 = X_ATTRIBUTE26)
           OR ((recinfo.ATTRIBUTE26 is null) AND (X_ATTRIBUTE26 is null)))
      AND ((recinfo.ATTRIBUTE27 = X_ATTRIBUTE27)
           OR ((recinfo.ATTRIBUTE27 is null) AND (X_ATTRIBUTE27 is null)))
      AND ((recinfo.ATTRIBUTE28 = X_ATTRIBUTE28)
           OR ((recinfo.ATTRIBUTE28 is null) AND (X_ATTRIBUTE28 is null)))
      AND ((recinfo.ATTRIBUTE29 = X_ATTRIBUTE29)
           OR ((recinfo.ATTRIBUTE29 is null) AND (X_ATTRIBUTE29 is null)))
      AND ((recinfo.ATTRIBUTE30 = X_ATTRIBUTE30)
           OR ((recinfo.ATTRIBUTE30 is null) AND (X_ATTRIBUTE30 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.TEST_METHOD_DESC = X_TEST_METHOD_DESC)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_TEST_METHOD_ID in NUMBER,
  X_TEST_METHOD_CODE in VARCHAR2,
  X_TEST_QTY in NUMBER,
  X_TEST_QTY_UOM in VARCHAR2,
  X_DISPLAY_PRECISION in NUMBER,
  X_TEST_DURATION in NUMBER,
  X_DAYS in NUMBER,
  X_HOURS in NUMBER,
  X_MINUTES in NUMBER,
  X_SECONDS in NUMBER,
  X_TEST_REPLICATE in NUMBER,
  X_DELETE_MARK in NUMBER,
  X_RESOURCES in VARCHAR2,
  X_TEST_KIT_ORGANIZATION_ID NUMBER,
  X_TEST_KIT_INV_ITEM_ID in NUMBER,
  X_TEXT_CODE in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_TEST_METHOD_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMD_TEST_METHODS_B set
    TEST_METHOD_CODE = X_TEST_METHOD_CODE,
    TEST_QTY = X_TEST_QTY,
    TEST_QTY_UOM = X_TEST_QTY_UOM,
    DISPLAY_PRECISION = X_DISPLAY_PRECISION,
    TEST_DURATION = X_TEST_DURATION,
    DAYS = X_DAYS,
    HOURS = X_HOURS,
    MINUTES = X_MINUTES,
    SECONDS = X_SECONDS,
    TEST_REPLICATE = X_TEST_REPLICATE,
    DELETE_MARK = X_DELETE_MARK,
    RESOURCES = X_RESOURCES,
    TEST_KIT_ORGANIZATION_ID = X_TEST_KIT_ORGANIZATION_ID,
    TEST_KIT_INV_ITEM_ID = X_TEST_KIT_INV_ITEM_ID,
    TEXT_CODE = X_TEXT_CODE,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE16 = X_ATTRIBUTE16,
    ATTRIBUTE17 = X_ATTRIBUTE17,
    ATTRIBUTE18 = X_ATTRIBUTE18,
    ATTRIBUTE19 = X_ATTRIBUTE19,
    ATTRIBUTE20 = X_ATTRIBUTE20,
    ATTRIBUTE21 = X_ATTRIBUTE21,
    ATTRIBUTE22 = X_ATTRIBUTE22,
    ATTRIBUTE23 = X_ATTRIBUTE23,
    ATTRIBUTE24 = X_ATTRIBUTE24,
    ATTRIBUTE25 = X_ATTRIBUTE25,
    ATTRIBUTE26 = X_ATTRIBUTE26,
    ATTRIBUTE27 = X_ATTRIBUTE27,
    ATTRIBUTE28 = X_ATTRIBUTE28,
    ATTRIBUTE29 = X_ATTRIBUTE29,
    ATTRIBUTE30 = X_ATTRIBUTE30,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TEST_METHOD_ID = X_TEST_METHOD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMD_TEST_METHODS_TL set
    TEST_METHOD_DESC = X_TEST_METHOD_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TEST_METHOD_ID = X_TEST_METHOD_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TEST_METHOD_ID in NUMBER
) is
begin
  delete from GMD_TEST_METHODS_TL
  where TEST_METHOD_ID = X_TEST_METHOD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from GMD_TEST_METHODS_B
  where TEST_METHOD_ID = X_TEST_METHOD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMD_TEST_METHODS_TL T
  where not exists
    (select NULL
    from GMD_TEST_METHODS_B B
    where B.TEST_METHOD_ID = T.TEST_METHOD_ID
    );

  update GMD_TEST_METHODS_TL T set (
      TEST_METHOD_DESC
    ) = (select
      B.TEST_METHOD_DESC
    from GMD_TEST_METHODS_TL B
    where B.TEST_METHOD_ID = T.TEST_METHOD_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TEST_METHOD_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TEST_METHOD_ID,
      SUBT.LANGUAGE
    from GMD_TEST_METHODS_TL SUBB, GMD_TEST_METHODS_TL SUBT
    where SUBB.TEST_METHOD_ID = SUBT.TEST_METHOD_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TEST_METHOD_DESC <> SUBT.TEST_METHOD_DESC
  ));

  insert into GMD_TEST_METHODS_TL (
    TEST_METHOD_ID,
    TEST_METHOD_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TEST_METHOD_ID,
    B.TEST_METHOD_DESC,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMD_TEST_METHODS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMD_TEST_METHODS_TL T
    where T.TEST_METHOD_ID = B.TEST_METHOD_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


FUNCTION fetch_row (p_test_methods IN  gmd_test_methods%ROWTYPE,
		    x_test_methods OUT NOCOPY gmd_test_methods%ROWTYPE )
RETURN BOOLEAN
IS
BEGIN

  IF (p_test_methods.test_method_id IS NOT NULL) THEN
    SELECT *
    INTO   x_test_methods
    FROM   gmd_test_methods
    WHERE  test_method_id = p_test_methods.test_method_id
    ;
  ELSIF (p_test_methods.test_method_code IS NOT NULL) THEN

    SELECT *
    INTO   x_test_methods
    FROM   gmd_test_methods
    WHERE  test_method_code = p_test_methods.test_method_code;
  ELSE
    gmd_api_pub.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_test_methods');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
 WHEN NO_DATA_FOUND
   THEN
     gmd_api_pub.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_test_methods');
     RETURN FALSE;
 WHEN OTHERS
   THEN
     fnd_msg_pub.add_exc_msg ('GMD_test_methods_PVT', 'FETCH_ROW');
     RETURN FALSE;

END fetch_row;
END gmd_test_methods_pvt;

/
