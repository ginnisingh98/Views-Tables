--------------------------------------------------------
--  DDL for Package Body CN_IMPORT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_IMPORT_TYPES_PKG" AS
/* $Header: cntimtpb.pls 115.2 2002/02/05 00:25:58 pkm ship    $*/


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
    ( p_import_types_rec IN IMPORT_TYPES_REC_TYPE) IS

BEGIN

   INSERT into CN_IMPORT_TYPES
      ( IMPORT_TYPE_ID,
        IMPORT_TYPE_CODE,
        VIEW_NAME,
        CONC_PROGRAM,
        TABLE_ID,
        OBJECT_VERSION_NUMBER,
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
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN)
    select
       DECODE(p_import_types_rec.IMPORT_TYPE_ID, FND_API.G_MISS_NUM, NULL,
              p_import_types_rec.IMPORT_TYPE_ID),
       DECODE(p_import_types_rec.IMPORT_TYPE_CODE, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.IMPORT_TYPE_CODE),
       DECODE(p_import_types_rec.VIEW_NAME, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.VIEW_NAME),
       DECODE(p_import_types_rec.CONC_PROGRAM, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.CONC_PROGRAM),
       DECODE(p_import_types_rec.TABLE_ID, FND_API.G_MISS_NUM, NULL,
              p_import_types_rec.TABLE_ID),
        1,
       DECODE(p_import_types_rec.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.ATTRIBUTE_CATEGORY),
       DECODE(p_import_types_rec.ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.ATTRIBUTE1),
       DECODE(p_import_types_rec.ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.ATTRIBUTE2),
       DECODE(p_import_types_rec.ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.ATTRIBUTE3),
       DECODE(p_import_types_rec.ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.ATTRIBUTE4),
       DECODE(p_import_types_rec.ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.ATTRIBUTE5),
       DECODE(p_import_types_rec.ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.ATTRIBUTE6),
       DECODE(p_import_types_rec.ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.ATTRIBUTE7),
       DECODE(p_import_types_rec.ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.ATTRIBUTE8),
       DECODE(p_import_types_rec.ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.ATTRIBUTE9),
       DECODE(p_import_types_rec.ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.ATTRIBUTE10),
       DECODE(p_import_types_rec.ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.ATTRIBUTE11),
       DECODE(p_import_types_rec.ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.ATTRIBUTE12),
       DECODE(p_import_types_rec.ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.ATTRIBUTE13),
       DECODE(p_import_types_rec.ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.ATTRIBUTE14),
       DECODE(p_import_types_rec.ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL,
              p_import_types_rec.ATTRIBUTE15),
        Sysdate,
        fnd_global.user_id,
        Sysdate,
        fnd_global.user_id,
        fnd_global.login_id
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
    ( p_import_types_rec IN IMPORT_TYPES_REC_TYPE) IS

BEGIN

   UPDATE CN_IMPORT_TYPES oldrec
      SET
         IMPORT_TYPE_CODE = DECODE(p_import_types_rec.IMPORT_TYPE_CODE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.IMPORT_TYPE_CODE,
                                      p_import_types_rec.IMPORT_TYPE_CODE),
         VIEW_NAME = DECODE(p_import_types_rec.VIEW_NAME,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.VIEW_NAME,
                                      p_import_types_rec.VIEW_NAME),
         CONC_PROGRAM = DECODE(p_import_types_rec.CONC_PROGRAM,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.CONC_PROGRAM,
                                      p_import_types_rec.CONC_PROGRAM),
         TABLE_ID = DECODE(p_import_types_rec.TABLE_ID,
                                      FND_API.G_MISS_NUM,
                                      oldrec.TABLE_ID,
                                      p_import_types_rec.TABLE_ID),
         OBJECT_VERSION_NUMBER = oldrec.OBJECT_VERSION_NUMBER + 1,
         ATTRIBUTE_CATEGORY = DECODE(p_import_types_rec.ATTRIBUTE_CATEGORY,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE_CATEGORY,
                                      p_import_types_rec.ATTRIBUTE_CATEGORY),
         ATTRIBUTE1 = DECODE(p_import_types_rec.ATTRIBUTE1,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE1,
                                      p_import_types_rec.ATTRIBUTE1),
         ATTRIBUTE2 = DECODE(p_import_types_rec.ATTRIBUTE2,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE2,
                                      p_import_types_rec.ATTRIBUTE2),
         ATTRIBUTE3 = DECODE(p_import_types_rec.ATTRIBUTE3,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE3,
                                      p_import_types_rec.ATTRIBUTE3),
         ATTRIBUTE4 = DECODE(p_import_types_rec.ATTRIBUTE4,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE4,
                                      p_import_types_rec.ATTRIBUTE4),
         ATTRIBUTE5 = DECODE(p_import_types_rec.ATTRIBUTE5,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE5,
                                      p_import_types_rec.ATTRIBUTE5),
         ATTRIBUTE6 = DECODE(p_import_types_rec.ATTRIBUTE6,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE6,
                                      p_import_types_rec.ATTRIBUTE6),
         ATTRIBUTE7 = DECODE(p_import_types_rec.ATTRIBUTE7,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE7,
                                      p_import_types_rec.ATTRIBUTE7),
         ATTRIBUTE8 = DECODE(p_import_types_rec.ATTRIBUTE8,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE8,
                                      p_import_types_rec.ATTRIBUTE8),
         ATTRIBUTE9 = DECODE(p_import_types_rec.ATTRIBUTE9,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE9,
                                      p_import_types_rec.ATTRIBUTE9),
         ATTRIBUTE10 = DECODE(p_import_types_rec.ATTRIBUTE10,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE10,
                                      p_import_types_rec.ATTRIBUTE10),
         ATTRIBUTE11 = DECODE(p_import_types_rec.ATTRIBUTE11,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE11,
                                      p_import_types_rec.ATTRIBUTE11),
         ATTRIBUTE12 = DECODE(p_import_types_rec.ATTRIBUTE12,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE12,
                                      p_import_types_rec.ATTRIBUTE12),
         ATTRIBUTE13 = DECODE(p_import_types_rec.ATTRIBUTE13,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE13,
                                      p_import_types_rec.ATTRIBUTE13),
         ATTRIBUTE14 = DECODE(p_import_types_rec.ATTRIBUTE14,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE14,
                                      p_import_types_rec.ATTRIBUTE14),
         ATTRIBUTE15 = DECODE(p_import_types_rec.ATTRIBUTE15,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE15,
                                      p_import_types_rec.ATTRIBUTE15),
         LAST_UPDATE_DATE = Sysdate,
         LAST_UPDATED_BY = fnd_global.user_id,
         LAST_UPDATE_LOGIN = fnd_global.login_id
     WHERE import_type_id = p_import_types_rec.import_type_id;

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
    ( p_import_types_rec IN IMPORT_TYPES_REC_TYPE) IS

   CURSOR c IS
     SELECT object_version_number
       FROM CN_IMPORT_TYPES
     WHERE import_type_id = p_import_types_rec.import_type_id;

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

   if (tlinfo.object_version_number <> p_import_types_rec.object_version_number) then
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
   end if;
   UPDATE CN_IMPORT_TYPES oldrec
      SET
         IMPORT_TYPE_CODE = DECODE(p_import_types_rec.IMPORT_TYPE_CODE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.IMPORT_TYPE_CODE,
                                      p_import_types_rec.IMPORT_TYPE_CODE),
         VIEW_NAME = DECODE(p_import_types_rec.VIEW_NAME,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.VIEW_NAME,
                                      p_import_types_rec.VIEW_NAME),
         CONC_PROGRAM = DECODE(p_import_types_rec.CONC_PROGRAM,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.CONC_PROGRAM,
                                      p_import_types_rec.CONC_PROGRAM),
         TABLE_ID = DECODE(p_import_types_rec.TABLE_ID,
                                      FND_API.G_MISS_NUM,
                                      oldrec.TABLE_ID,
                                      p_import_types_rec.TABLE_ID),
         OBJECT_VERSION_NUMBER = oldrec.OBJECT_VERSION_NUMBER + 1,
         ATTRIBUTE_CATEGORY = DECODE(p_import_types_rec.ATTRIBUTE_CATEGORY,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE_CATEGORY,
                                      p_import_types_rec.ATTRIBUTE_CATEGORY),
         ATTRIBUTE1 = DECODE(p_import_types_rec.ATTRIBUTE1,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE1,
                                      p_import_types_rec.ATTRIBUTE1),
         ATTRIBUTE2 = DECODE(p_import_types_rec.ATTRIBUTE2,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE2,
                                      p_import_types_rec.ATTRIBUTE2),
         ATTRIBUTE3 = DECODE(p_import_types_rec.ATTRIBUTE3,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE3,
                                      p_import_types_rec.ATTRIBUTE3),
         ATTRIBUTE4 = DECODE(p_import_types_rec.ATTRIBUTE4,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE4,
                                      p_import_types_rec.ATTRIBUTE4),
         ATTRIBUTE5 = DECODE(p_import_types_rec.ATTRIBUTE5,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE5,
                                      p_import_types_rec.ATTRIBUTE5),
         ATTRIBUTE6 = DECODE(p_import_types_rec.ATTRIBUTE6,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE6,
                                      p_import_types_rec.ATTRIBUTE6),
         ATTRIBUTE7 = DECODE(p_import_types_rec.ATTRIBUTE7,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE7,
                                      p_import_types_rec.ATTRIBUTE7),
         ATTRIBUTE8 = DECODE(p_import_types_rec.ATTRIBUTE8,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE8,
                                      p_import_types_rec.ATTRIBUTE8),
         ATTRIBUTE9 = DECODE(p_import_types_rec.ATTRIBUTE9,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE9,
                                      p_import_types_rec.ATTRIBUTE9),
         ATTRIBUTE10 = DECODE(p_import_types_rec.ATTRIBUTE10,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE10,
                                      p_import_types_rec.ATTRIBUTE10),
         ATTRIBUTE11 = DECODE(p_import_types_rec.ATTRIBUTE11,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE11,
                                      p_import_types_rec.ATTRIBUTE11),
         ATTRIBUTE12 = DECODE(p_import_types_rec.ATTRIBUTE12,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE12,
                                      p_import_types_rec.ATTRIBUTE12),
         ATTRIBUTE13 = DECODE(p_import_types_rec.ATTRIBUTE13,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE13,
                                      p_import_types_rec.ATTRIBUTE13),
         ATTRIBUTE14 = DECODE(p_import_types_rec.ATTRIBUTE14,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE14,
                                      p_import_types_rec.ATTRIBUTE14),
         ATTRIBUTE15 = DECODE(p_import_types_rec.ATTRIBUTE15,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE15,
                                      p_import_types_rec.ATTRIBUTE15),
         LAST_UPDATE_DATE = Sysdate,
         LAST_UPDATED_BY = fnd_global.user_id,
         LAST_UPDATE_LOGIN = fnd_global.login_id
     WHERE import_type_id = p_import_types_rec.import_type_id;

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
      p_import_type_id	NUMBER
    ) IS

BEGIN

   DELETE FROM CN_IMPORT_TYPES
     WHERE import_type_id = p_import_type_id;

   IF (SQL%ROWCOUNT=0) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END Delete_row;


END CN_IMPORT_TYPES_PKG;

/
