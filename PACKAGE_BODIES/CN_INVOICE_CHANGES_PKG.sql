--------------------------------------------------------
--  DDL for Package Body CN_INVOICE_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_INVOICE_CHANGES_PKG" AS
/* $Header: cninvlnb.pls 115.3 2002/01/28 20:01:40 pkm ship      $*/


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
    ( p_invoice_changes_all_rec IN INVOICE_CHANGES_ALL_REC_TYPE) IS

BEGIN

   INSERT into CN_INVOICE_CHANGES_ALL
      ( INVOICE_CHANGE_ID,
        SALESREP_ID,
        INVOICE_NUMBER,
        LINE_NUMBER,
        REVENUE_TYPE,
        SPLIT_PCT,
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
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER,
        COMM_LINES_API_ID)
    select
       DECODE(p_invoice_changes_all_rec.INVOICE_CHANGE_ID, FND_API.G_MISS_NUM, NULL,
              p_invoice_changes_all_rec.INVOICE_CHANGE_ID),
       DECODE(p_invoice_changes_all_rec.SALESREP_ID, FND_API.G_MISS_NUM, NULL,
              p_invoice_changes_all_rec.SALESREP_ID),
       DECODE(p_invoice_changes_all_rec.INVOICE_NUMBER, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.INVOICE_NUMBER),
       DECODE(p_invoice_changes_all_rec.LINE_NUMBER, FND_API.G_MISS_NUM, NULL,
              p_invoice_changes_all_rec.LINE_NUMBER),
       DECODE(p_invoice_changes_all_rec.REVENUE_TYPE, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.REVENUE_TYPE),
       DECODE(p_invoice_changes_all_rec.SPLIT_PCT, FND_API.G_MISS_NUM, NULL,
              p_invoice_changes_all_rec.SPLIT_PCT),
       DECODE(p_invoice_changes_all_rec.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.ATTRIBUTE_CATEGORY),
       DECODE(p_invoice_changes_all_rec.ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.ATTRIBUTE1),
       DECODE(p_invoice_changes_all_rec.ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.ATTRIBUTE2),
       DECODE(p_invoice_changes_all_rec.ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.ATTRIBUTE3),
       DECODE(p_invoice_changes_all_rec.ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.ATTRIBUTE4),
       DECODE(p_invoice_changes_all_rec.ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.ATTRIBUTE5),
       DECODE(p_invoice_changes_all_rec.ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.ATTRIBUTE6),
       DECODE(p_invoice_changes_all_rec.ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.ATTRIBUTE7),
       DECODE(p_invoice_changes_all_rec.ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.ATTRIBUTE8),
       DECODE(p_invoice_changes_all_rec.ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.ATTRIBUTE9),
       DECODE(p_invoice_changes_all_rec.ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.ATTRIBUTE10),
       DECODE(p_invoice_changes_all_rec.ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.ATTRIBUTE11),
       DECODE(p_invoice_changes_all_rec.ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.ATTRIBUTE12),
       DECODE(p_invoice_changes_all_rec.ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.ATTRIBUTE13),
       DECODE(p_invoice_changes_all_rec.ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.ATTRIBUTE14),
       DECODE(p_invoice_changes_all_rec.ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL,
              p_invoice_changes_all_rec.ATTRIBUTE15),
        Sysdate,
        fnd_global.user_id,
        Sysdate,
        fnd_global.user_id,
        fnd_global.login_id,
        1,
       DECODE(p_invoice_changes_all_rec.COMM_LINES_API_ID, FND_API.G_MISS_NUM, NULL,
              p_invoice_changes_all_rec.COMM_LINES_API_ID)
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
    ( p_invoice_changes_all_rec IN INVOICE_CHANGES_ALL_REC_TYPE) IS

BEGIN

   UPDATE CN_INVOICE_CHANGES_ALL oldrec
      SET
         SALESREP_ID = DECODE(p_invoice_changes_all_rec.SALESREP_ID,
                                      FND_API.G_MISS_NUM,
                                      oldrec.SALESREP_ID,
                                      p_invoice_changes_all_rec.SALESREP_ID),
         INVOICE_NUMBER = DECODE(p_invoice_changes_all_rec.INVOICE_NUMBER,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.INVOICE_NUMBER,
                                      p_invoice_changes_all_rec.INVOICE_NUMBER),
         LINE_NUMBER = DECODE(p_invoice_changes_all_rec.LINE_NUMBER,
                                      FND_API.G_MISS_NUM,
                                      oldrec.LINE_NUMBER,
                                      p_invoice_changes_all_rec.LINE_NUMBER),
         REVENUE_TYPE = DECODE(p_invoice_changes_all_rec.REVENUE_TYPE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.REVENUE_TYPE,
                                      p_invoice_changes_all_rec.REVENUE_TYPE),
         SPLIT_PCT = DECODE(p_invoice_changes_all_rec.SPLIT_PCT,
                                      FND_API.G_MISS_NUM,
                                      oldrec.SPLIT_PCT,
                                      p_invoice_changes_all_rec.SPLIT_PCT),
         ATTRIBUTE_CATEGORY = DECODE(p_invoice_changes_all_rec.ATTRIBUTE_CATEGORY,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE_CATEGORY,
                                      p_invoice_changes_all_rec.ATTRIBUTE_CATEGORY),
         ATTRIBUTE1 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE1,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE1,
                                      p_invoice_changes_all_rec.ATTRIBUTE1),
         ATTRIBUTE2 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE2,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE2,
                                      p_invoice_changes_all_rec.ATTRIBUTE2),
         ATTRIBUTE3 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE3,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE3,
                                      p_invoice_changes_all_rec.ATTRIBUTE3),
         ATTRIBUTE4 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE4,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE4,
                                      p_invoice_changes_all_rec.ATTRIBUTE4),
         ATTRIBUTE5 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE5,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE5,
                                      p_invoice_changes_all_rec.ATTRIBUTE5),
         ATTRIBUTE6 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE6,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE6,
                                      p_invoice_changes_all_rec.ATTRIBUTE6),
         ATTRIBUTE7 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE7,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE7,
                                      p_invoice_changes_all_rec.ATTRIBUTE7),
         ATTRIBUTE8 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE8,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE8,
                                      p_invoice_changes_all_rec.ATTRIBUTE8),
         ATTRIBUTE9 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE9,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE9,
                                      p_invoice_changes_all_rec.ATTRIBUTE9),
         ATTRIBUTE10 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE10,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE10,
                                      p_invoice_changes_all_rec.ATTRIBUTE10),
         ATTRIBUTE11 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE11,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE11,
                                      p_invoice_changes_all_rec.ATTRIBUTE11),
         ATTRIBUTE12 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE12,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE12,
                                      p_invoice_changes_all_rec.ATTRIBUTE12),
         ATTRIBUTE13 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE13,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE13,
                                      p_invoice_changes_all_rec.ATTRIBUTE13),
         ATTRIBUTE14 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE14,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE14,
                                      p_invoice_changes_all_rec.ATTRIBUTE14),
         ATTRIBUTE15 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE15,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE15,
                                      p_invoice_changes_all_rec.ATTRIBUTE15),
         LAST_UPDATE_DATE = Sysdate,
         LAST_UPDATED_BY = fnd_global.user_id,
         LAST_UPDATE_LOGIN = fnd_global.login_id,
         OBJECT_VERSION_NUMBER = oldrec.OBJECT_VERSION_NUMBER + 1,
         COMM_LINES_API_ID = DECODE(p_invoice_changes_all_rec.COMM_LINES_API_ID,
                                      FND_API.G_MISS_NUM,
                                      oldrec.COMM_LINES_API_ID,
                                      p_invoice_changes_all_rec.COMM_LINES_API_ID)
     WHERE invoice_change_id = p_invoice_changes_all_rec.invoice_change_id;

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
    ( p_invoice_changes_all_rec IN INVOICE_CHANGES_ALL_REC_TYPE) IS

   CURSOR c IS
     SELECT object_version_number
       FROM CN_INVOICE_CHANGES_ALL
     WHERE invoice_change_id = p_invoice_changes_all_rec.invoice_change_id;

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

   if (tlinfo.object_version_number <> p_invoice_changes_all_rec.object_version_number) then
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
   end if;
   UPDATE CN_INVOICE_CHANGES_ALL oldrec
      SET
         SALESREP_ID = DECODE(p_invoice_changes_all_rec.SALESREP_ID,
                                      FND_API.G_MISS_NUM,
                                      oldrec.SALESREP_ID,
                                      p_invoice_changes_all_rec.SALESREP_ID),
         INVOICE_NUMBER = DECODE(p_invoice_changes_all_rec.INVOICE_NUMBER,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.INVOICE_NUMBER,
                                      p_invoice_changes_all_rec.INVOICE_NUMBER),
         LINE_NUMBER = DECODE(p_invoice_changes_all_rec.LINE_NUMBER,
                                      FND_API.G_MISS_NUM,
                                      oldrec.LINE_NUMBER,
                                      p_invoice_changes_all_rec.LINE_NUMBER),
         REVENUE_TYPE = DECODE(p_invoice_changes_all_rec.REVENUE_TYPE,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.REVENUE_TYPE,
                                      p_invoice_changes_all_rec.REVENUE_TYPE),
         SPLIT_PCT = DECODE(p_invoice_changes_all_rec.SPLIT_PCT,
                                      FND_API.G_MISS_NUM,
                                      oldrec.SPLIT_PCT,
                                      p_invoice_changes_all_rec.SPLIT_PCT),
         ATTRIBUTE_CATEGORY = DECODE(p_invoice_changes_all_rec.ATTRIBUTE_CATEGORY,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE_CATEGORY,
                                      p_invoice_changes_all_rec.ATTRIBUTE_CATEGORY),
         ATTRIBUTE1 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE1,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE1,
                                      p_invoice_changes_all_rec.ATTRIBUTE1),
         ATTRIBUTE2 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE2,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE2,
                                      p_invoice_changes_all_rec.ATTRIBUTE2),
         ATTRIBUTE3 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE3,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE3,
                                      p_invoice_changes_all_rec.ATTRIBUTE3),
         ATTRIBUTE4 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE4,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE4,
                                      p_invoice_changes_all_rec.ATTRIBUTE4),
         ATTRIBUTE5 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE5,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE5,
                                      p_invoice_changes_all_rec.ATTRIBUTE5),
         ATTRIBUTE6 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE6,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE6,
                                      p_invoice_changes_all_rec.ATTRIBUTE6),
         ATTRIBUTE7 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE7,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE7,
                                      p_invoice_changes_all_rec.ATTRIBUTE7),
         ATTRIBUTE8 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE8,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE8,
                                      p_invoice_changes_all_rec.ATTRIBUTE8),
         ATTRIBUTE9 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE9,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE9,
                                      p_invoice_changes_all_rec.ATTRIBUTE9),
         ATTRIBUTE10 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE10,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE10,
                                      p_invoice_changes_all_rec.ATTRIBUTE10),
         ATTRIBUTE11 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE11,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE11,
                                      p_invoice_changes_all_rec.ATTRIBUTE11),
         ATTRIBUTE12 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE12,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE12,
                                      p_invoice_changes_all_rec.ATTRIBUTE12),
         ATTRIBUTE13 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE13,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE13,
                                      p_invoice_changes_all_rec.ATTRIBUTE13),
         ATTRIBUTE14 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE14,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE14,
                                      p_invoice_changes_all_rec.ATTRIBUTE14),
         ATTRIBUTE15 = DECODE(p_invoice_changes_all_rec.ATTRIBUTE15,
                                      FND_API.G_MISS_CHAR,
                                      oldrec.ATTRIBUTE15,
                                      p_invoice_changes_all_rec.ATTRIBUTE15),
         LAST_UPDATE_DATE = Sysdate,
         LAST_UPDATED_BY = fnd_global.user_id,
         LAST_UPDATE_LOGIN = fnd_global.login_id,
         OBJECT_VERSION_NUMBER = oldrec.OBJECT_VERSION_NUMBER + 1,
         COMM_LINES_API_ID = DECODE(p_invoice_changes_all_rec.COMM_LINES_API_ID,
                                      FND_API.G_MISS_NUM,
                                      oldrec.COMM_LINES_API_ID,
                                      p_invoice_changes_all_rec.COMM_LINES_API_ID)
     WHERE invoice_change_id = p_invoice_changes_all_rec.invoice_change_id;

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
      p_invoice_change_id	NUMBER
    ) IS

BEGIN

   DELETE FROM CN_INVOICE_CHANGES_ALL
     WHERE invoice_change_id = p_invoice_change_id;

   IF (SQL%ROWCOUNT=0) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END Delete_row;


END CN_INVOICE_CHANGES_PKG;

/
