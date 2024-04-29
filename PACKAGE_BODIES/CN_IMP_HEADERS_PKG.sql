--------------------------------------------------------
--  DDL for Package Body CN_IMP_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_IMP_HEADERS_PKG" AS
/* $Header: cntimhrb.pls 115.4 2002/02/12 18:58:45 pkm ship   $*/


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
    ( p_imp_headers_rec IN CN_IMP_HEADERS_PVT.IMP_HEADERS_REC_TYPE) IS

BEGIN

   INSERT into CN_IMP_HEADERS
      ( IMP_HEADER_ID,
        NAME,
        DESCRIPTION,
        IMPORT_TYPE_CODE,
	OPERATION,
        SERVER_FLAG,
        USER_FILENAME,
        DATA_FILENAME,
        TERMINATED_BY,
        ENCLOSED_BY,
        HEADINGS_FLAG,
	STAGED_ROW,
        PROCESSED_ROW,
        FAILED_ROW,
        STATUS_CODE,
        IMP_MAP_ID,
        SOURCE_COLUMN_NUM,
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
       DECODE(p_imp_headers_rec.IMP_HEADER_ID, FND_API.G_MISS_NUM, NULL,
              p_imp_headers_rec.IMP_HEADER_ID),
       DECODE(p_imp_headers_rec.NAME, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.NAME),
       DECODE(p_imp_headers_rec.DESCRIPTION, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.DESCRIPTION),
       DECODE(p_imp_headers_rec.IMPORT_TYPE_CODE, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.IMPORT_TYPE_CODE),
       DECODE(p_imp_headers_rec.OPERATION, FND_API.G_MISS_CHAR, NULL,
	      p_imp_headers_rec.OPERATION),
       DECODE(p_imp_headers_rec.SERVER_FLAG, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.SERVER_FLAG),
       DECODE(p_imp_headers_rec.USER_FILENAME, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.USER_FILENAME),
       DECODE(p_imp_headers_rec.DATA_FILENAME, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.DATA_FILENAME),
       DECODE(p_imp_headers_rec.TERMINATED_BY, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.TERMINATED_BY),
       DECODE(p_imp_headers_rec.ENCLOSED_BY, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.ENCLOSED_BY),
       DECODE(p_imp_headers_rec.HEADINGS_FLAG, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.HEADINGS_FLAG),
       DECODE(p_imp_headers_rec.STAGED_ROW, FND_API.G_MISS_NUM, NULL,
              p_imp_headers_rec.STAGED_ROW),
       DECODE(p_imp_headers_rec.PROCESSED_ROW, FND_API.G_MISS_NUM, NULL,
              p_imp_headers_rec.PROCESSED_ROW),
       DECODE(p_imp_headers_rec.FAILED_ROW, FND_API.G_MISS_NUM, NULL,
              p_imp_headers_rec.FAILED_ROW),
       DECODE(p_imp_headers_rec.STATUS_CODE, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.STATUS_CODE),
       DECODE(p_imp_headers_rec.IMP_MAP_ID, FND_API.G_MISS_NUM, NULL,
              p_imp_headers_rec.IMP_MAP_ID),
       DECODE(p_imp_headers_rec.SOURCE_COLUMN_NUM, FND_API.G_MISS_NUM, NULL,
              p_imp_headers_rec.SOURCE_COLUMN_NUM),
        1,
       DECODE(p_imp_headers_rec.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.ATTRIBUTE_CATEGORY),
       DECODE(p_imp_headers_rec.ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.ATTRIBUTE1),
       DECODE(p_imp_headers_rec.ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.ATTRIBUTE2),
       DECODE(p_imp_headers_rec.ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.ATTRIBUTE3),
       DECODE(p_imp_headers_rec.ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.ATTRIBUTE4),
       DECODE(p_imp_headers_rec.ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.ATTRIBUTE5),
       DECODE(p_imp_headers_rec.ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.ATTRIBUTE6),
       DECODE(p_imp_headers_rec.ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.ATTRIBUTE7),
       DECODE(p_imp_headers_rec.ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.ATTRIBUTE8),
       DECODE(p_imp_headers_rec.ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.ATTRIBUTE9),
       DECODE(p_imp_headers_rec.ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.ATTRIBUTE10),
       DECODE(p_imp_headers_rec.ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.ATTRIBUTE11),
       DECODE(p_imp_headers_rec.ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.ATTRIBUTE12),
       DECODE(p_imp_headers_rec.ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.ATTRIBUTE13),
       DECODE(p_imp_headers_rec.ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.ATTRIBUTE14),
       DECODE(p_imp_headers_rec.ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL,
              p_imp_headers_rec.ATTRIBUTE15),
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
    ( p_imp_headers_rec IN CN_IMP_HEADERS_PVT.IMP_HEADERS_REC_TYPE) IS

BEGIN

   UPDATE CN_IMP_HEADERS oldrec
      SET
         NAME = DECODE(p_imp_headers_rec.NAME,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.NAME,
                                      p_imp_headers_rec.NAME),
         DESCRIPTION = DECODE(p_imp_headers_rec.DESCRIPTION,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.DESCRIPTION,
                                      p_imp_headers_rec.DESCRIPTION),
         IMPORT_TYPE_CODE = DECODE(p_imp_headers_rec.IMPORT_TYPE_CODE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.IMPORT_TYPE_CODE,
                                      p_imp_headers_rec.IMPORT_TYPE_CODE),
         OPERATION = DECODE(p_imp_headers_rec.OPERATION,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.OPERATION,
                                      p_imp_headers_rec.OPERATION),
         SERVER_FLAG = DECODE(p_imp_headers_rec.SERVER_FLAG,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.SERVER_FLAG,
                                      p_imp_headers_rec.SERVER_FLAG),
         USER_FILENAME = DECODE(p_imp_headers_rec.USER_FILENAME,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.USER_FILENAME,
                                      p_imp_headers_rec.USER_FILENAME),
         DATA_FILENAME = DECODE(p_imp_headers_rec.DATA_FILENAME,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.DATA_FILENAME,
                                      p_imp_headers_rec.DATA_FILENAME),
         TERMINATED_BY = DECODE(p_imp_headers_rec.TERMINATED_BY,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.TERMINATED_BY,
                                      p_imp_headers_rec.TERMINATED_BY),
         ENCLOSED_BY = DECODE(p_imp_headers_rec.ENCLOSED_BY,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ENCLOSED_BY,
                                      p_imp_headers_rec.ENCLOSED_BY),
         HEADINGS_FLAG = DECODE(p_imp_headers_rec.HEADINGS_FLAG,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.HEADINGS_FLAG,
                                      p_imp_headers_rec.HEADINGS_FLAG),
         STAGED_ROW = DECODE(p_imp_headers_rec.STAGED_ROW,
                                      FND_API.G_MISS_NUM,
                                      oldrec.STAGED_ROW,
                                      p_imp_headers_rec.STAGED_ROW),
         PROCESSED_ROW = DECODE(p_imp_headers_rec.PROCESSED_ROW,
                                      FND_API.G_MISS_NUM,
                                      oldrec.PROCESSED_ROW,
                                      p_imp_headers_rec.PROCESSED_ROW),
         FAILED_ROW = DECODE(p_imp_headers_rec.FAILED_ROW,
                                      FND_API.G_MISS_NUM,
                                      oldrec.FAILED_ROW,
                                      p_imp_headers_rec.FAILED_ROW),
         STATUS_CODE = DECODE(p_imp_headers_rec.STATUS_CODE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.STATUS_CODE,
                                      p_imp_headers_rec.STATUS_CODE),
         IMP_MAP_ID = DECODE(p_imp_headers_rec.IMP_MAP_ID,
                                      FND_API.G_MISS_NUM,
                                      oldrec.IMP_MAP_ID,
                                      p_imp_headers_rec.IMP_MAP_ID),
         SOURCE_COLUMN_NUM = DECODE(p_imp_headers_rec.SOURCE_COLUMN_NUM,
                                      FND_API.G_MISS_NUM,
                                      oldrec.SOURCE_COLUMN_NUM,
                                      p_imp_headers_rec.SOURCE_COLUMN_NUM),
         OBJECT_VERSION_NUMBER = oldrec.OBJECT_VERSION_NUMBER + 1,
         ATTRIBUTE_CATEGORY = DECODE(p_imp_headers_rec.ATTRIBUTE_CATEGORY,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE_CATEGORY,
                                      p_imp_headers_rec.ATTRIBUTE_CATEGORY),
         ATTRIBUTE1 = DECODE(p_imp_headers_rec.ATTRIBUTE1,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE1,
                                      p_imp_headers_rec.ATTRIBUTE1),
         ATTRIBUTE2 = DECODE(p_imp_headers_rec.ATTRIBUTE2,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE2,
                                      p_imp_headers_rec.ATTRIBUTE2),
         ATTRIBUTE3 = DECODE(p_imp_headers_rec.ATTRIBUTE3,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE3,
                                      p_imp_headers_rec.ATTRIBUTE3),
         ATTRIBUTE4 = DECODE(p_imp_headers_rec.ATTRIBUTE4,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE4,
                                      p_imp_headers_rec.ATTRIBUTE4),
         ATTRIBUTE5 = DECODE(p_imp_headers_rec.ATTRIBUTE5,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE5,
                                      p_imp_headers_rec.ATTRIBUTE5),
         ATTRIBUTE6 = DECODE(p_imp_headers_rec.ATTRIBUTE6,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE6,
                                      p_imp_headers_rec.ATTRIBUTE6),
         ATTRIBUTE7 = DECODE(p_imp_headers_rec.ATTRIBUTE7,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE7,
                                      p_imp_headers_rec.ATTRIBUTE7),
         ATTRIBUTE8 = DECODE(p_imp_headers_rec.ATTRIBUTE8,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE8,
                                      p_imp_headers_rec.ATTRIBUTE8),
         ATTRIBUTE9 = DECODE(p_imp_headers_rec.ATTRIBUTE9,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE9,
                                      p_imp_headers_rec.ATTRIBUTE9),
         ATTRIBUTE10 = DECODE(p_imp_headers_rec.ATTRIBUTE10,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE10,
                                      p_imp_headers_rec.ATTRIBUTE10),
         ATTRIBUTE11 = DECODE(p_imp_headers_rec.ATTRIBUTE11,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE11,
                                      p_imp_headers_rec.ATTRIBUTE11),
         ATTRIBUTE12 = DECODE(p_imp_headers_rec.ATTRIBUTE12,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE12,
                                      p_imp_headers_rec.ATTRIBUTE12),
         ATTRIBUTE13 = DECODE(p_imp_headers_rec.ATTRIBUTE13,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE13,
                                      p_imp_headers_rec.ATTRIBUTE13),
         ATTRIBUTE14 = DECODE(p_imp_headers_rec.ATTRIBUTE14,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE14,
                                      p_imp_headers_rec.ATTRIBUTE14),
         ATTRIBUTE15 = DECODE(p_imp_headers_rec.ATTRIBUTE15,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE15,
                                      p_imp_headers_rec.ATTRIBUTE15),
         LAST_UPDATE_DATE = Sysdate,
         LAST_UPDATED_BY = fnd_global.user_id,
         LAST_UPDATE_LOGIN = fnd_global.login_id
     WHERE imp_header_id = p_imp_headers_rec.imp_header_id;

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
    ( p_imp_headers_rec IN CN_IMP_HEADERS_PVT.IMP_HEADERS_REC_TYPE) IS

   CURSOR c IS
     SELECT object_version_number
       FROM CN_IMP_HEADERS
     WHERE imp_header_id = p_imp_headers_rec.imp_header_id;

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

   if (tlinfo.object_version_number <> p_imp_headers_rec.object_version_number) then
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
   end if;
   UPDATE CN_IMP_HEADERS oldrec
      SET
         NAME = DECODE(p_imp_headers_rec.NAME,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.NAME,
                                      p_imp_headers_rec.NAME),
         DESCRIPTION = DECODE(p_imp_headers_rec.DESCRIPTION,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.DESCRIPTION,
                                      p_imp_headers_rec.DESCRIPTION),
         IMPORT_TYPE_CODE = DECODE(p_imp_headers_rec.IMPORT_TYPE_CODE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.IMPORT_TYPE_CODE,
				   p_imp_headers_rec.IMPORT_TYPE_CODE),
         OPERATION = DECODE(p_imp_headers_rec.OPERATION,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.OPERATION,
                                      p_imp_headers_rec.OPERATION),
         SERVER_FLAG = DECODE(p_imp_headers_rec.SERVER_FLAG,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.SERVER_FLAG,
                                      p_imp_headers_rec.SERVER_FLAG),
         USER_FILENAME = DECODE(p_imp_headers_rec.USER_FILENAME,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.USER_FILENAME,
                                      p_imp_headers_rec.USER_FILENAME),
         DATA_FILENAME = DECODE(p_imp_headers_rec.DATA_FILENAME,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.DATA_FILENAME,
                                      p_imp_headers_rec.DATA_FILENAME),
         TERMINATED_BY = DECODE(p_imp_headers_rec.TERMINATED_BY,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.TERMINATED_BY,
                                      p_imp_headers_rec.TERMINATED_BY),
         ENCLOSED_BY = DECODE(p_imp_headers_rec.ENCLOSED_BY,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ENCLOSED_BY,
                                      p_imp_headers_rec.ENCLOSED_BY),
         HEADINGS_FLAG = DECODE(p_imp_headers_rec.HEADINGS_FLAG,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.HEADINGS_FLAG,
                                      p_imp_headers_rec.HEADINGS_FLAG),
         STAGED_ROW = DECODE(p_imp_headers_rec.STAGED_ROW,
                                      FND_API.G_MISS_NUM,
                                      oldrec.STAGED_ROW,
                                      p_imp_headers_rec.STAGED_ROW),
         PROCESSED_ROW = DECODE(p_imp_headers_rec.PROCESSED_ROW,
                                      FND_API.G_MISS_NUM,
                                      oldrec.PROCESSED_ROW,
                                      p_imp_headers_rec.PROCESSED_ROW),
         FAILED_ROW = DECODE(p_imp_headers_rec.FAILED_ROW,
                                      FND_API.G_MISS_NUM,
                                      oldrec.FAILED_ROW,
                                      p_imp_headers_rec.FAILED_ROW),
         STATUS_CODE = DECODE(p_imp_headers_rec.STATUS_CODE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.STATUS_CODE,
                                      p_imp_headers_rec.STATUS_CODE),
         IMP_MAP_ID = DECODE(p_imp_headers_rec.IMP_MAP_ID,
                                      FND_API.G_MISS_NUM,
                                      oldrec.IMP_MAP_ID,
                                      p_imp_headers_rec.IMP_MAP_ID),
         SOURCE_COLUMN_NUM = DECODE(p_imp_headers_rec.SOURCE_COLUMN_NUM,
                                      FND_API.G_MISS_NUM,
                                      oldrec.SOURCE_COLUMN_NUM,
                                      p_imp_headers_rec.SOURCE_COLUMN_NUM),
         OBJECT_VERSION_NUMBER = oldrec.OBJECT_VERSION_NUMBER + 1,
         ATTRIBUTE_CATEGORY = DECODE(p_imp_headers_rec.ATTRIBUTE_CATEGORY,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE_CATEGORY,
                                      p_imp_headers_rec.ATTRIBUTE_CATEGORY),
         ATTRIBUTE1 = DECODE(p_imp_headers_rec.ATTRIBUTE1,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE1,
                                      p_imp_headers_rec.ATTRIBUTE1),
         ATTRIBUTE2 = DECODE(p_imp_headers_rec.ATTRIBUTE2,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE2,
                                      p_imp_headers_rec.ATTRIBUTE2),
         ATTRIBUTE3 = DECODE(p_imp_headers_rec.ATTRIBUTE3,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE3,
                                      p_imp_headers_rec.ATTRIBUTE3),
         ATTRIBUTE4 = DECODE(p_imp_headers_rec.ATTRIBUTE4,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE4,
                                      p_imp_headers_rec.ATTRIBUTE4),
         ATTRIBUTE5 = DECODE(p_imp_headers_rec.ATTRIBUTE5,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE5,
                                      p_imp_headers_rec.ATTRIBUTE5),
         ATTRIBUTE6 = DECODE(p_imp_headers_rec.ATTRIBUTE6,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE6,
                                      p_imp_headers_rec.ATTRIBUTE6),
         ATTRIBUTE7 = DECODE(p_imp_headers_rec.ATTRIBUTE7,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE7,
                                      p_imp_headers_rec.ATTRIBUTE7),
         ATTRIBUTE8 = DECODE(p_imp_headers_rec.ATTRIBUTE8,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE8,
                                      p_imp_headers_rec.ATTRIBUTE8),
         ATTRIBUTE9 = DECODE(p_imp_headers_rec.ATTRIBUTE9,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE9,
                                      p_imp_headers_rec.ATTRIBUTE9),
         ATTRIBUTE10 = DECODE(p_imp_headers_rec.ATTRIBUTE10,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE10,
                                      p_imp_headers_rec.ATTRIBUTE10),
         ATTRIBUTE11 = DECODE(p_imp_headers_rec.ATTRIBUTE11,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE11,
                                      p_imp_headers_rec.ATTRIBUTE11),
         ATTRIBUTE12 = DECODE(p_imp_headers_rec.ATTRIBUTE12,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE12,
                                      p_imp_headers_rec.ATTRIBUTE12),
         ATTRIBUTE13 = DECODE(p_imp_headers_rec.ATTRIBUTE13,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE13,
                                      p_imp_headers_rec.ATTRIBUTE13),
         ATTRIBUTE14 = DECODE(p_imp_headers_rec.ATTRIBUTE14,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE14,
                                      p_imp_headers_rec.ATTRIBUTE14),
         ATTRIBUTE15 = DECODE(p_imp_headers_rec.ATTRIBUTE15,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE15,
                                      p_imp_headers_rec.ATTRIBUTE15),
         LAST_UPDATE_DATE = Sysdate,
         LAST_UPDATED_BY = fnd_global.user_id,
         LAST_UPDATE_LOGIN = fnd_global.login_id
     WHERE imp_header_id = p_imp_headers_rec.imp_header_id;

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
      p_imp_header_id	NUMBER
    ) IS

BEGIN

   DELETE FROM CN_IMP_HEADERS
     WHERE imp_header_id = p_imp_header_id;

   IF (SQL%ROWCOUNT=0) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END Delete_row;


END CN_IMP_HEADERS_PKG;

/
