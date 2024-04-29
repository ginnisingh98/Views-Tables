--------------------------------------------------------
--  DDL for Package Body CN_REASONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_REASONS_PKG" AS
/* $Header: cntresnb.pls 115.1 2002/04/24 12:04:58 pkm ship       $*/


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
    ( p_reasons_all_rec IN REASONS_ALL_REC_TYPE) IS
   --
   l_reason	VARCHAR2(8000);
   --
BEGIN
   l_reason := p_reasons_all_rec.reason;
   INSERT into CN_REASONS
      ( REASON_ID,
        UPDATED_TABLE,
        UPD_TABLE_ID,
        REASON,
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
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER,
        LOOKUP_TYPE,
        REASON_CODE,
        UPDATE_FLAG)
    select
       DECODE(p_reasons_all_rec.REASON_ID, FND_API.G_MISS_NUM, NULL,
              p_reasons_all_rec.REASON_ID),
       DECODE(p_reasons_all_rec.UPDATED_TABLE, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.UPDATED_TABLE),
       DECODE(p_reasons_all_rec.UPD_TABLE_ID, FND_API.G_MISS_NUM, NULL,
              p_reasons_all_rec.UPD_TABLE_ID),
       --EMPTY_CLOB(),
       l_reason,
       DECODE(p_reasons_all_rec.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.ATTRIBUTE_CATEGORY),
       DECODE(p_reasons_all_rec.ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.ATTRIBUTE1),
       DECODE(p_reasons_all_rec.ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.ATTRIBUTE2),
       DECODE(p_reasons_all_rec.ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.ATTRIBUTE3),
       DECODE(p_reasons_all_rec.ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.ATTRIBUTE4),
       DECODE(p_reasons_all_rec.ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.ATTRIBUTE5),
       DECODE(p_reasons_all_rec.ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.ATTRIBUTE6),
       DECODE(p_reasons_all_rec.ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.ATTRIBUTE7),
       DECODE(p_reasons_all_rec.ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.ATTRIBUTE8),
       DECODE(p_reasons_all_rec.ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.ATTRIBUTE9),
       DECODE(p_reasons_all_rec.ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.ATTRIBUTE10),
       DECODE(p_reasons_all_rec.ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.ATTRIBUTE11),
       DECODE(p_reasons_all_rec.ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.ATTRIBUTE12),
       DECODE(p_reasons_all_rec.ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.ATTRIBUTE13),
       DECODE(p_reasons_all_rec.ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.ATTRIBUTE14),
       DECODE(p_reasons_all_rec.ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.ATTRIBUTE15),
        fnd_global.user_id,
        Sysdate,
        fnd_global.user_id,
        Sysdate,
        fnd_global.login_id,
        1,
       DECODE(p_reasons_all_rec.LOOKUP_TYPE, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.LOOKUP_TYPE),
       DECODE(p_reasons_all_rec.REASON_CODE, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.REASON_CODE),
       DECODE(p_reasons_all_rec.UPDATE_FLAG, FND_API.G_MISS_CHAR, NULL,
              p_reasons_all_rec.UPDATE_FLAG)
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
    ( p_reasons_all_rec IN REASONS_ALL_REC_TYPE) IS
   --
   l_reason		VARCHAR2(8000);
   --
BEGIN
   l_reason := p_reasons_all_rec.REASON;
   UPDATE CN_REASONS_ALL oldrec
      SET
         UPDATED_TABLE = DECODE(p_reasons_all_rec.UPDATED_TABLE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.UPDATED_TABLE,
                                      p_reasons_all_rec.UPDATED_TABLE),
         UPD_TABLE_ID = DECODE(p_reasons_all_rec.UPD_TABLE_ID,
                                      FND_API.G_MISS_NUM,
                                      oldrec.UPD_TABLE_ID,
                                      p_reasons_all_rec.UPD_TABLE_ID),
         REASON = l_reason,
         ATTRIBUTE_CATEGORY = DECODE(p_reasons_all_rec.ATTRIBUTE_CATEGORY,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE_CATEGORY,
                                      p_reasons_all_rec.ATTRIBUTE_CATEGORY),
         ATTRIBUTE1 = DECODE(p_reasons_all_rec.ATTRIBUTE1,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE1,
                                      p_reasons_all_rec.ATTRIBUTE1),
         ATTRIBUTE2 = DECODE(p_reasons_all_rec.ATTRIBUTE2,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE2,
                                      p_reasons_all_rec.ATTRIBUTE2),
         ATTRIBUTE3 = DECODE(p_reasons_all_rec.ATTRIBUTE3,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE3,
                                      p_reasons_all_rec.ATTRIBUTE3),
         ATTRIBUTE4 = DECODE(p_reasons_all_rec.ATTRIBUTE4,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE4,
                                      p_reasons_all_rec.ATTRIBUTE4),
         ATTRIBUTE5 = DECODE(p_reasons_all_rec.ATTRIBUTE5,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE5,
                                      p_reasons_all_rec.ATTRIBUTE5),
         ATTRIBUTE6 = DECODE(p_reasons_all_rec.ATTRIBUTE6,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE6,
                                      p_reasons_all_rec.ATTRIBUTE6),
         ATTRIBUTE7 = DECODE(p_reasons_all_rec.ATTRIBUTE7,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE7,
                                      p_reasons_all_rec.ATTRIBUTE7),
         ATTRIBUTE8 = DECODE(p_reasons_all_rec.ATTRIBUTE8,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE8,
                                      p_reasons_all_rec.ATTRIBUTE8),
         ATTRIBUTE9 = DECODE(p_reasons_all_rec.ATTRIBUTE9,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE9,
                                      p_reasons_all_rec.ATTRIBUTE9),
         ATTRIBUTE10 = DECODE(p_reasons_all_rec.ATTRIBUTE10,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE10,
                                      p_reasons_all_rec.ATTRIBUTE10),
         ATTRIBUTE11 = DECODE(p_reasons_all_rec.ATTRIBUTE11,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE11,
                                      p_reasons_all_rec.ATTRIBUTE11),
         ATTRIBUTE12 = DECODE(p_reasons_all_rec.ATTRIBUTE12,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE12,
                                      p_reasons_all_rec.ATTRIBUTE12),
         ATTRIBUTE13 = DECODE(p_reasons_all_rec.ATTRIBUTE13,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE13,
                                      p_reasons_all_rec.ATTRIBUTE13),
         ATTRIBUTE14 = DECODE(p_reasons_all_rec.ATTRIBUTE14,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE14,
                                      p_reasons_all_rec.ATTRIBUTE14),
         ATTRIBUTE15 = DECODE(p_reasons_all_rec.ATTRIBUTE15,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE15,
                                      p_reasons_all_rec.ATTRIBUTE15),
         LAST_UPDATED_BY = fnd_global.user_id,
         LAST_UPDATE_DATE = Sysdate,
         LAST_UPDATE_LOGIN = fnd_global.login_id,
         OBJECT_VERSION_NUMBER = oldrec.OBJECT_VERSION_NUMBER + 1,
         LOOKUP_TYPE = DECODE(p_reasons_all_rec.LOOKUP_TYPE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.LOOKUP_TYPE,
                                      p_reasons_all_rec.LOOKUP_TYPE),
         REASON_CODE = DECODE(p_reasons_all_rec.REASON_CODE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.REASON_CODE,
                                      p_reasons_all_rec.REASON_CODE)
     WHERE reason_id = p_reasons_all_rec.reason_id;

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
    ( p_reasons_all_rec IN REASONS_ALL_REC_TYPE) IS

   CURSOR c IS
     SELECT object_version_number
       FROM CN_REASONS_ALL
     WHERE reason_id = p_reasons_all_rec.reason_id;

   tlinfo c%ROWTYPE ;
   --
   l_reason		VARCHAR2(8000);
   --
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
   if (tlinfo.object_version_number <> p_reasons_all_rec.object_version_number) then
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
   end if;
   l_reason := p_reasons_all_rec.REASON;
   UPDATE CN_REASONS_ALL oldrec
      SET
         UPDATED_TABLE = DECODE(p_reasons_all_rec.UPDATED_TABLE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.UPDATED_TABLE,
                                      p_reasons_all_rec.UPDATED_TABLE),
         UPD_TABLE_ID = DECODE(p_reasons_all_rec.UPD_TABLE_ID,
                                      FND_API.G_MISS_NUM,
                                      oldrec.UPD_TABLE_ID,
                                      p_reasons_all_rec.UPD_TABLE_ID),
         REASON = l_reason,
         ATTRIBUTE_CATEGORY = DECODE(p_reasons_all_rec.ATTRIBUTE_CATEGORY,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE_CATEGORY,
                                      p_reasons_all_rec.ATTRIBUTE_CATEGORY),
         ATTRIBUTE1 = DECODE(p_reasons_all_rec.ATTRIBUTE1,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE1,
                                      p_reasons_all_rec.ATTRIBUTE1),
         ATTRIBUTE2 = DECODE(p_reasons_all_rec.ATTRIBUTE2,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE2,
                                      p_reasons_all_rec.ATTRIBUTE2),
         ATTRIBUTE3 = DECODE(p_reasons_all_rec.ATTRIBUTE3,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE3,
                                      p_reasons_all_rec.ATTRIBUTE3),
         ATTRIBUTE4 = DECODE(p_reasons_all_rec.ATTRIBUTE4,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE4,
                                      p_reasons_all_rec.ATTRIBUTE4),
         ATTRIBUTE5 = DECODE(p_reasons_all_rec.ATTRIBUTE5,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE5,
                                      p_reasons_all_rec.ATTRIBUTE5),
         ATTRIBUTE6 = DECODE(p_reasons_all_rec.ATTRIBUTE6,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE6,
                                      p_reasons_all_rec.ATTRIBUTE6),
         ATTRIBUTE7 = DECODE(p_reasons_all_rec.ATTRIBUTE7,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE7,
                                      p_reasons_all_rec.ATTRIBUTE7),
         ATTRIBUTE8 = DECODE(p_reasons_all_rec.ATTRIBUTE8,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE8,
                                      p_reasons_all_rec.ATTRIBUTE8),
         ATTRIBUTE9 = DECODE(p_reasons_all_rec.ATTRIBUTE9,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE9,
                                      p_reasons_all_rec.ATTRIBUTE9),
         ATTRIBUTE10 = DECODE(p_reasons_all_rec.ATTRIBUTE10,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE10,
                                      p_reasons_all_rec.ATTRIBUTE10),
         ATTRIBUTE11 = DECODE(p_reasons_all_rec.ATTRIBUTE11,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE11,
                                      p_reasons_all_rec.ATTRIBUTE11),
         ATTRIBUTE12 = DECODE(p_reasons_all_rec.ATTRIBUTE12,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE12,
                                      p_reasons_all_rec.ATTRIBUTE12),
         ATTRIBUTE13 = DECODE(p_reasons_all_rec.ATTRIBUTE13,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE13,
                                      p_reasons_all_rec.ATTRIBUTE13),
         ATTRIBUTE14 = DECODE(p_reasons_all_rec.ATTRIBUTE14,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE14,
                                      p_reasons_all_rec.ATTRIBUTE14),
         ATTRIBUTE15 = DECODE(p_reasons_all_rec.ATTRIBUTE15,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE15,
                                      p_reasons_all_rec.ATTRIBUTE15),
         LAST_UPDATED_BY = fnd_global.user_id,
         LAST_UPDATE_DATE = Sysdate,
         LAST_UPDATE_LOGIN = fnd_global.login_id,
         OBJECT_VERSION_NUMBER = oldrec.OBJECT_VERSION_NUMBER + 1,
         LOOKUP_TYPE = DECODE(p_reasons_all_rec.LOOKUP_TYPE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.LOOKUP_TYPE,
                                      p_reasons_all_rec.LOOKUP_TYPE),
         REASON_CODE = DECODE(p_reasons_all_rec.REASON_CODE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.REASON_CODE,
                                      p_reasons_all_rec.REASON_CODE)
     WHERE reason_id = p_reasons_all_rec.reason_id;
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
PROCEDURE delete_row(
      p_reason_id	NUMBER) IS
BEGIN
   DELETE FROM CN_REASONS_ALL
     WHERE reason_id = p_reason_id;
END Delete_row;
--
END CN_REASONS_PKG;

/
