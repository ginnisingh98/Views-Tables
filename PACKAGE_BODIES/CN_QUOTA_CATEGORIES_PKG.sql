--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_CATEGORIES_PKG" AS
/* $Header: cntqcatb.pls 115.5 2002/01/28 20:05:11 pkm ship      $*/


-- * -------------------------------------------------------------------------*
--   Procedure Name
--	Insert_row
--   Purpose
--      Main insert procedure
--   Note
--      1. Primary key should be populated from sequence before call
--         this procedure. No refernece to sequence in this procedure.
--      2. All paramaters are IN parameter.
-- * -------------------------------------------------------------------------*
PROCEDURE insert_row
    ( p_quota_categories_rec IN QUOTA_CATEGORIES_REC_TYPE) IS

   l_quota_category_id		NUMBER := 0;

BEGIN
   --
   SELECT cn_quota_categories_s.NEXTVAL
	INTO l_quota_category_id
	FROM dual;
   --
   INSERT into CN_QUOTA_CATEGORIES
      ( QUOTA_CATEGORY_ID,
        NAME,
        DESCRIPTION,
        TYPE,
        COMPUTE_FLAG,
        INTERVAL_TYPE_ID,
        QUOTA_UNIT_CODE,
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
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        CREATION_DATE,
        CREATED_BY,
        OBJECT_VERSION_NUMBER)
    select
	  l_quota_category_id,
       DECODE(p_quota_categories_rec.NAME, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.NAME),
       DECODE(p_quota_categories_rec.DESCRIPTION, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.DESCRIPTION),
       DECODE(p_quota_categories_rec.TYPE, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.TYPE),
       DECODE(p_quota_categories_rec.COMPUTE_FLAG, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.COMPUTE_FLAG),
       DECODE(p_quota_categories_rec.INTERVAL_TYPE_ID, FND_API.G_MISS_NUM, NULL,
              p_quota_categories_rec.INTERVAL_TYPE_ID),
       DECODE(p_quota_categories_rec.QUOTA_UNIT_CODE, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.QUOTA_UNIT_CODE),
       DECODE(p_quota_categories_rec.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.ATTRIBUTE_CATEGORY),
       DECODE(p_quota_categories_rec.ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.ATTRIBUTE1),
       DECODE(p_quota_categories_rec.ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.ATTRIBUTE2),
       DECODE(p_quota_categories_rec.ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.ATTRIBUTE3),
       DECODE(p_quota_categories_rec.ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.ATTRIBUTE4),
       DECODE(p_quota_categories_rec.ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.ATTRIBUTE5),
       DECODE(p_quota_categories_rec.ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.ATTRIBUTE6),
       DECODE(p_quota_categories_rec.ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.ATTRIBUTE7),
       DECODE(p_quota_categories_rec.ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.ATTRIBUTE8),
       DECODE(p_quota_categories_rec.ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.ATTRIBUTE9),
       DECODE(p_quota_categories_rec.ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.ATTRIBUTE10),
       DECODE(p_quota_categories_rec.ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.ATTRIBUTE11),
       DECODE(p_quota_categories_rec.ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.ATTRIBUTE12),
       DECODE(p_quota_categories_rec.ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.ATTRIBUTE13),
       DECODE(p_quota_categories_rec.ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.ATTRIBUTE14),
       DECODE(p_quota_categories_rec.ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL,
              p_quota_categories_rec.ATTRIBUTE15),
        G_LAST_UPDATE_DATE,
        G_LAST_UPDATED_BY,
        G_LAST_UPDATE_LOGIN,
        G_CREATION_DATE,
        G_CREATED_BY,
        1
   from dual;

END insert_row;


-- * -------------------------------------------------------------------------*
--   Procedure Name
--	update_row
--   Purpose
--      Main update procedure
--   Note
--      1. No object version checking, overwrite may happen
--      2. Calling lock_update for object version checking
--      3. All paramaters are IN parameter.
--      4. Raise NO_DATA_FOUND exception if no reocrd updated (??)
-- * -------------------------------------------------------------------------*
PROCEDURE update_row
    ( p_quota_categories_rec IN QUOTA_CATEGORIES_REC_TYPE) IS

BEGIN

   UPDATE CN_QUOTA_CATEGORIES oldrec
      SET
         NAME = DECODE(p_quota_categories_rec.NAME,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.NAME,
                                      p_quota_categories_rec.NAME),
         DESCRIPTION = DECODE(p_quota_categories_rec.DESCRIPTION,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.DESCRIPTION,
                                      p_quota_categories_rec.DESCRIPTION),
         TYPE = DECODE(p_quota_categories_rec.TYPE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.TYPE,
                                      p_quota_categories_rec.TYPE),
         COMPUTE_FLAG = DECODE(p_quota_categories_rec.COMPUTE_FLAG,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.COMPUTE_FLAG,
                                      p_quota_categories_rec.COMPUTE_FLAG),
         INTERVAL_TYPE_ID = DECODE(p_quota_categories_rec.INTERVAL_TYPE_ID,
                                      FND_API.G_MISS_NUM,
                                      oldrec.INTERVAL_TYPE_ID,
                                      p_quota_categories_rec.INTERVAL_TYPE_ID),
         QUOTA_UNIT_CODE = DECODE(p_quota_categories_rec.QUOTA_UNIT_CODE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.QUOTA_UNIT_CODE,
                                      p_quota_categories_rec.QUOTA_UNIT_CODE),
         ATTRIBUTE_CATEGORY = DECODE(p_quota_categories_rec.ATTRIBUTE_CATEGORY,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE_CATEGORY,
                                      p_quota_categories_rec.ATTRIBUTE_CATEGORY),
         ATTRIBUTE1 = DECODE(p_quota_categories_rec.ATTRIBUTE1,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE1,
                                      p_quota_categories_rec.ATTRIBUTE1),
         ATTRIBUTE2 = DECODE(p_quota_categories_rec.ATTRIBUTE2,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE2,
                                      p_quota_categories_rec.ATTRIBUTE2),
         ATTRIBUTE3 = DECODE(p_quota_categories_rec.ATTRIBUTE3,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE3,
                                      p_quota_categories_rec.ATTRIBUTE3),
         ATTRIBUTE4 = DECODE(p_quota_categories_rec.ATTRIBUTE4,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE4,
                                      p_quota_categories_rec.ATTRIBUTE4),
         ATTRIBUTE5 = DECODE(p_quota_categories_rec.ATTRIBUTE5,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE5,
                                      p_quota_categories_rec.ATTRIBUTE5),
         ATTRIBUTE6 = DECODE(p_quota_categories_rec.ATTRIBUTE6,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE6,
                                      p_quota_categories_rec.ATTRIBUTE6),
         ATTRIBUTE7 = DECODE(p_quota_categories_rec.ATTRIBUTE7,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE7,
                                      p_quota_categories_rec.ATTRIBUTE7),
         ATTRIBUTE8 = DECODE(p_quota_categories_rec.ATTRIBUTE8,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE8,
                                      p_quota_categories_rec.ATTRIBUTE8),
         ATTRIBUTE9 = DECODE(p_quota_categories_rec.ATTRIBUTE9,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE9,
                                      p_quota_categories_rec.ATTRIBUTE9),
         ATTRIBUTE10 = DECODE(p_quota_categories_rec.ATTRIBUTE10,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE10,
                                      p_quota_categories_rec.ATTRIBUTE10),
         ATTRIBUTE11 = DECODE(p_quota_categories_rec.ATTRIBUTE11,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE11,
                                      p_quota_categories_rec.ATTRIBUTE11),
         ATTRIBUTE12 = DECODE(p_quota_categories_rec.ATTRIBUTE12,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE12,
                                      p_quota_categories_rec.ATTRIBUTE12),
         ATTRIBUTE13 = DECODE(p_quota_categories_rec.ATTRIBUTE13,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE13,
                                      p_quota_categories_rec.ATTRIBUTE13),
         ATTRIBUTE14 = DECODE(p_quota_categories_rec.ATTRIBUTE14,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE14,
                                      p_quota_categories_rec.ATTRIBUTE14),
         ATTRIBUTE15 = DECODE(p_quota_categories_rec.ATTRIBUTE15,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE15,
                                      p_quota_categories_rec.ATTRIBUTE15),
         LAST_UPDATE_DATE = G_LAST_UPDATE_DATE,
         LAST_UPDATED_BY = G_LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN = G_LAST_UPDATE_LOGIN,
         OBJECT_VERSION_NUMBER = oldrec.OBJECT_VERSION_NUMBER + 1
     WHERE quota_category_id = p_quota_categories_rec.quota_category_id;

   IF (SQL%ROWCOUNT=0) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END update_row;


-- * -------------------------------------------------------------------------*
--   Procedure Name
--	lock_update_row
--   Purpose
--      Main lcok and update procedure
--   Note
--      1. Object version checking is performed before checking
--      2. Calling update_row if you don not want object version checking
--      3. All paramaters are IN parameter.
--      4. Raise NO_DATA_FOUND exception if no reocrd updated (??)
-- * -------------------------------------------------------------------------*
PROCEDURE lock_update_row
    ( p_quota_categories_rec IN QUOTA_CATEGORIES_REC_TYPE) IS

   CURSOR c IS
     SELECT object_version_number
       FROM CN_QUOTA_CATEGORIES
     WHERE quota_category_id = p_quota_categories_rec.quota_category_id;

   tlinfo c%ROWTYPE ;
BEGIN

   open  c;
   fetch c into tlinfo;
   if (c%notfound) then
      close c;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
   end if;
   close c;

   if (tlinfo.object_version_number <> p_quota_categories_rec.object_version_number) then
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
   end if;
   UPDATE CN_QUOTA_CATEGORIES oldrec
      SET
         NAME = DECODE(p_quota_categories_rec.NAME,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.NAME,
                                      p_quota_categories_rec.NAME),
         DESCRIPTION = DECODE(p_quota_categories_rec.DESCRIPTION,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.DESCRIPTION,
                                      p_quota_categories_rec.DESCRIPTION),
         TYPE = DECODE(p_quota_categories_rec.TYPE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.TYPE,
                                      p_quota_categories_rec.TYPE),
         COMPUTE_FLAG = DECODE(p_quota_categories_rec.COMPUTE_FLAG,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.COMPUTE_FLAG,
                                      p_quota_categories_rec.COMPUTE_FLAG),
         INTERVAL_TYPE_ID = DECODE(p_quota_categories_rec.INTERVAL_TYPE_ID,
                                      FND_API.G_MISS_NUM,
                                      oldrec.INTERVAL_TYPE_ID,
                                      p_quota_categories_rec.INTERVAL_TYPE_ID),
         QUOTA_UNIT_CODE = DECODE(p_quota_categories_rec.QUOTA_UNIT_CODE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.QUOTA_UNIT_CODE,
                                      p_quota_categories_rec.QUOTA_UNIT_CODE),
         ATTRIBUTE_CATEGORY = DECODE(p_quota_categories_rec.ATTRIBUTE_CATEGORY,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE_CATEGORY,
                                      p_quota_categories_rec.ATTRIBUTE_CATEGORY),
         ATTRIBUTE1 = DECODE(p_quota_categories_rec.ATTRIBUTE1,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE1,
                                      p_quota_categories_rec.ATTRIBUTE1),
         ATTRIBUTE2 = DECODE(p_quota_categories_rec.ATTRIBUTE2,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE2,
                                      p_quota_categories_rec.ATTRIBUTE2),
         ATTRIBUTE3 = DECODE(p_quota_categories_rec.ATTRIBUTE3,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE3,
                                      p_quota_categories_rec.ATTRIBUTE3),
         ATTRIBUTE4 = DECODE(p_quota_categories_rec.ATTRIBUTE4,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE4,
                                      p_quota_categories_rec.ATTRIBUTE4),
         ATTRIBUTE5 = DECODE(p_quota_categories_rec.ATTRIBUTE5,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE5,
                                      p_quota_categories_rec.ATTRIBUTE5),
         ATTRIBUTE6 = DECODE(p_quota_categories_rec.ATTRIBUTE6,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE6,
                                      p_quota_categories_rec.ATTRIBUTE6),
         ATTRIBUTE7 = DECODE(p_quota_categories_rec.ATTRIBUTE7,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE7,
                                      p_quota_categories_rec.ATTRIBUTE7),
         ATTRIBUTE8 = DECODE(p_quota_categories_rec.ATTRIBUTE8,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE8,
                                      p_quota_categories_rec.ATTRIBUTE8),
         ATTRIBUTE9 = DECODE(p_quota_categories_rec.ATTRIBUTE9,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE9,
                                      p_quota_categories_rec.ATTRIBUTE9),
         ATTRIBUTE10 = DECODE(p_quota_categories_rec.ATTRIBUTE10,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE10,
                                      p_quota_categories_rec.ATTRIBUTE10),
         ATTRIBUTE11 = DECODE(p_quota_categories_rec.ATTRIBUTE11,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE11,
                                      p_quota_categories_rec.ATTRIBUTE11),
         ATTRIBUTE12 = DECODE(p_quota_categories_rec.ATTRIBUTE12,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE12,
                                      p_quota_categories_rec.ATTRIBUTE12),
         ATTRIBUTE13 = DECODE(p_quota_categories_rec.ATTRIBUTE13,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE13,
                                      p_quota_categories_rec.ATTRIBUTE13),
         ATTRIBUTE14 = DECODE(p_quota_categories_rec.ATTRIBUTE14,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE14,
                                      p_quota_categories_rec.ATTRIBUTE14),
         ATTRIBUTE15 = DECODE(p_quota_categories_rec.ATTRIBUTE15,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE15,
                                      p_quota_categories_rec.ATTRIBUTE15),
         LAST_UPDATE_DATE = G_LAST_UPDATE_DATE,
         LAST_UPDATED_BY = G_LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN = G_LAST_UPDATE_LOGIN,
         OBJECT_VERSION_NUMBER = oldrec.OBJECT_VERSION_NUMBER + 1
     WHERE quota_category_id = p_quota_categories_rec.quota_category_id;

   IF (SQL%ROWCOUNT=0) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END lock_update_row;


-- * -------------------------------------------------------------------------*
--   Procedure Name
--	delete_row
--   Purpose
--      Main lcok and update procedure
--   Note
--      1. All paramaters are IN parameter.
--      2. Raise NO_DATA_FOUND exception if no reocrd deleted (??)
-- * -------------------------------------------------------------------------*
PROCEDURE delete_row
    (
      p_quota_category_id	NUMBER
    ) IS

BEGIN

   DELETE FROM CN_QUOTA_CATEGORIES
     WHERE quota_category_id = p_quota_category_id;

   IF (SQL%ROWCOUNT=0) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END Delete_row;


END CN_QUOTA_CATEGORIES_PKG;

/
