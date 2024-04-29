--------------------------------------------------------
--  DDL for Package Body CN_PAY_APPROVAL_FLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PAY_APPROVAL_FLOW_PKG" AS
/* $Header: cntpflwb.pls 120.1 2005/08/29 15:41:17 fmburu noship $*/


-- * -------------------------------------------------------------------------*
--   Procedure Name
--  Insert_row
--   Purpose
--      Main insert procedure
--   Note
--      1. Primary key should be populated from sequence before call
--         this procedure. No refernece to sequence in this procedure.
--      2. All paramaters are IN parameter.
-- * -------------------------------------------------------------------------*
PROCEDURE insert_row
    ( p_pay_approval_flow_rec IN PAY_APPROVAL_FLOW_REC_TYPE) IS

BEGIN

   INSERT into CN_PAY_APPROVAL_FLOW
      ( PAY_APPROVAL_FLOW_ID,
        PAYRUN_ID,
        PAYMENT_WORKSHEET_ID,
        SUBMIT_BY_RESOURCE_ID,
        SUBMIT_BY_USER_ID,
        SUBMIT_BY_EMAIL,
        SUBMIT_TO_RESOURCE_ID,
        SUBMIT_TO_USER_ID,
        SUBMIT_TO_EMAIL,
        APPROVAL_STATUS,
        UPDATED_BY_RESOURCE_ID,
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
        ORG_ID)
    select
       DECODE(p_pay_approval_flow_rec.PAY_APPROVAL_FLOW_ID, FND_API.G_MISS_NUM, NULL,
              p_pay_approval_flow_rec.PAY_APPROVAL_FLOW_ID),
       DECODE(p_pay_approval_flow_rec.PAYRUN_ID, FND_API.G_MISS_NUM, NULL,
              p_pay_approval_flow_rec.PAYRUN_ID),
       DECODE(p_pay_approval_flow_rec.PAYMENT_WORKSHEET_ID, FND_API.G_MISS_NUM, NULL,
              p_pay_approval_flow_rec.PAYMENT_WORKSHEET_ID),
       DECODE(p_pay_approval_flow_rec.SUBMIT_BY_RESOURCE_ID, FND_API.G_MISS_NUM, NULL,
              p_pay_approval_flow_rec.SUBMIT_BY_RESOURCE_ID),
       DECODE(p_pay_approval_flow_rec.SUBMIT_BY_USER_ID, FND_API.G_MISS_NUM, NULL,
              p_pay_approval_flow_rec.SUBMIT_BY_USER_ID),
       DECODE(p_pay_approval_flow_rec.SUBMIT_BY_EMAIL, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.SUBMIT_BY_EMAIL),
       DECODE(p_pay_approval_flow_rec.SUBMIT_TO_RESOURCE_ID, FND_API.G_MISS_NUM, NULL,
              p_pay_approval_flow_rec.SUBMIT_TO_RESOURCE_ID),
       DECODE(p_pay_approval_flow_rec.SUBMIT_TO_USER_ID, FND_API.G_MISS_NUM, NULL,
              p_pay_approval_flow_rec.SUBMIT_TO_USER_ID),
       DECODE(p_pay_approval_flow_rec.SUBMIT_TO_EMAIL, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.SUBMIT_TO_EMAIL),
       DECODE(p_pay_approval_flow_rec.APPROVAL_STATUS, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.APPROVAL_STATUS),
       DECODE(p_pay_approval_flow_rec.UPDATED_BY_RESOURCE_ID, FND_API.G_MISS_NUM, NULL,
              p_pay_approval_flow_rec.UPDATED_BY_RESOURCE_ID),
       DECODE(p_pay_approval_flow_rec.ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.ATTRIBUTE_CATEGORY),
       DECODE(p_pay_approval_flow_rec.ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.ATTRIBUTE1),
       DECODE(p_pay_approval_flow_rec.ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.ATTRIBUTE2),
       DECODE(p_pay_approval_flow_rec.ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.ATTRIBUTE3),
       DECODE(p_pay_approval_flow_rec.ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.ATTRIBUTE4),
       DECODE(p_pay_approval_flow_rec.ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.ATTRIBUTE5),
       DECODE(p_pay_approval_flow_rec.ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.ATTRIBUTE6),
       DECODE(p_pay_approval_flow_rec.ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.ATTRIBUTE7),
       DECODE(p_pay_approval_flow_rec.ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.ATTRIBUTE8),
       DECODE(p_pay_approval_flow_rec.ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.ATTRIBUTE9),
       DECODE(p_pay_approval_flow_rec.ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.ATTRIBUTE10),
       DECODE(p_pay_approval_flow_rec.ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.ATTRIBUTE11),
       DECODE(p_pay_approval_flow_rec.ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.ATTRIBUTE12),
       DECODE(p_pay_approval_flow_rec.ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.ATTRIBUTE13),
       DECODE(p_pay_approval_flow_rec.ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.ATTRIBUTE14),
       DECODE(p_pay_approval_flow_rec.ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL,
              p_pay_approval_flow_rec.ATTRIBUTE15),
        Sysdate,
        fnd_global.user_id,
        Sysdate,
        fnd_global.user_id,
        fnd_global.login_id,
        1,
        p_pay_approval_flow_rec.org_id
   from dual;

END insert_row;


-- * -------------------------------------------------------------------------*
--   Procedure Name
--  update_row
--   Purpose
--      Main update procedure
--   Note
--      1. No object version checking, overwrite may happen
--      2. Calling lock_update for object version checking
--      3. All paramaters are IN parameter.
--      4. Raise NO_DATA_FOUND exception if no reocrd updated (??)
-- * -------------------------------------------------------------------------*
PROCEDURE update_row
    ( p_pay_approval_flow_rec IN PAY_APPROVAL_FLOW_REC_TYPE) IS

BEGIN

   UPDATE CN_PAY_APPROVAL_FLOW oldrec
      SET
         PAYRUN_ID = DECODE(p_pay_approval_flow_rec.PAYRUN_ID,
                                      FND_API.G_MISS_NUM,
                                      NULL,
                                      NULL,
                                      oldrec.PAYRUN_ID,
                                      p_pay_approval_flow_rec.PAYRUN_ID),
         PAYMENT_WORKSHEET_ID = DECODE(p_pay_approval_flow_rec.PAYMENT_WORKSHEET_ID,
                                      FND_API.G_MISS_NUM,
                                      NULL,
                                      NULL,
                                      oldrec.PAYMENT_WORKSHEET_ID,
                                      p_pay_approval_flow_rec.PAYMENT_WORKSHEET_ID),
         SUBMIT_BY_RESOURCE_ID = DECODE(p_pay_approval_flow_rec.SUBMIT_BY_RESOURCE_ID,
                                      FND_API.G_MISS_NUM,
                                      NULL,
                                      NULL,
                                      oldrec.SUBMIT_BY_RESOURCE_ID,
                                      p_pay_approval_flow_rec.SUBMIT_BY_RESOURCE_ID),
         SUBMIT_BY_USER_ID = DECODE(p_pay_approval_flow_rec.SUBMIT_BY_USER_ID,
                                      FND_API.G_MISS_NUM,
                                      NULL,
                                      NULL,
                                      oldrec.SUBMIT_BY_USER_ID,
                                      p_pay_approval_flow_rec.SUBMIT_BY_USER_ID),
         SUBMIT_BY_EMAIL = DECODE(p_pay_approval_flow_rec.SUBMIT_BY_EMAIL,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.SUBMIT_BY_EMAIL,
                                      p_pay_approval_flow_rec.SUBMIT_BY_EMAIL),
         SUBMIT_TO_RESOURCE_ID = DECODE(p_pay_approval_flow_rec.SUBMIT_TO_RESOURCE_ID,
                                      FND_API.G_MISS_NUM,
                                      NULL,
                                      NULL,
                                      oldrec.SUBMIT_TO_RESOURCE_ID,
                                      p_pay_approval_flow_rec.SUBMIT_TO_RESOURCE_ID),
         SUBMIT_TO_USER_ID = DECODE(p_pay_approval_flow_rec.SUBMIT_TO_USER_ID,
                                      FND_API.G_MISS_NUM,
                                      NULL,
                                      NULL,
                                      oldrec.SUBMIT_TO_USER_ID,
                                      p_pay_approval_flow_rec.SUBMIT_TO_USER_ID),
         SUBMIT_TO_EMAIL = DECODE(p_pay_approval_flow_rec.SUBMIT_TO_EMAIL,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.SUBMIT_TO_EMAIL,
                                      p_pay_approval_flow_rec.SUBMIT_TO_EMAIL),
         APPROVAL_STATUS = DECODE(p_pay_approval_flow_rec.APPROVAL_STATUS,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.APPROVAL_STATUS,
                                      p_pay_approval_flow_rec.APPROVAL_STATUS),
         UPDATED_BY_RESOURCE_ID = DECODE(p_pay_approval_flow_rec.UPDATED_BY_RESOURCE_ID,
                                      FND_API.G_MISS_NUM,
                                      NULL,
                                      NULL,
                                      oldrec.UPDATED_BY_RESOURCE_ID,
                                      p_pay_approval_flow_rec.UPDATED_BY_RESOURCE_ID),
         ATTRIBUTE_CATEGORY = DECODE(p_pay_approval_flow_rec.ATTRIBUTE_CATEGORY,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE_CATEGORY,
                                      p_pay_approval_flow_rec.ATTRIBUTE_CATEGORY),
         ATTRIBUTE1 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE1,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE1,
                                      p_pay_approval_flow_rec.ATTRIBUTE1),
         ATTRIBUTE2 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE2,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE2,
                                      p_pay_approval_flow_rec.ATTRIBUTE2),
         ATTRIBUTE3 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE3,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE3,
                                      p_pay_approval_flow_rec.ATTRIBUTE3),
         ATTRIBUTE4 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE4,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE4,
                                      p_pay_approval_flow_rec.ATTRIBUTE4),
         ATTRIBUTE5 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE5,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE5,
                                      p_pay_approval_flow_rec.ATTRIBUTE5),
         ATTRIBUTE6 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE6,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE6,
                                      p_pay_approval_flow_rec.ATTRIBUTE6),
         ATTRIBUTE7 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE7,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE7,
                                      p_pay_approval_flow_rec.ATTRIBUTE7),
         ATTRIBUTE8 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE8,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE8,
                                      p_pay_approval_flow_rec.ATTRIBUTE8),
         ATTRIBUTE9 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE9,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE9,
                                      p_pay_approval_flow_rec.ATTRIBUTE9),
         ATTRIBUTE10 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE10,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE10,
                                      p_pay_approval_flow_rec.ATTRIBUTE10),
         ATTRIBUTE11 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE11,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE11,
                                      p_pay_approval_flow_rec.ATTRIBUTE11),
         ATTRIBUTE12 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE12,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE12,
                                      p_pay_approval_flow_rec.ATTRIBUTE12),
         ATTRIBUTE13 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE13,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE13,
                                      p_pay_approval_flow_rec.ATTRIBUTE13),
         ATTRIBUTE14 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE14,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE14,
                                      p_pay_approval_flow_rec.ATTRIBUTE14),
         ATTRIBUTE15 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE15,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE15,
                                      p_pay_approval_flow_rec.ATTRIBUTE15),
         LAST_UPDATE_DATE = Sysdate,
         LAST_UPDATED_BY = fnd_global.user_id,
         LAST_UPDATE_LOGIN = fnd_global.login_id,
         OBJECT_VERSION_NUMBER = oldrec.OBJECT_VERSION_NUMBER + 1
     WHERE pay_approval_flow_id = p_pay_approval_flow_rec.pay_approval_flow_id;

   IF (SQL%ROWCOUNT=0) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END update_row;


-- * -------------------------------------------------------------------------*
--   Procedure Name
--  lock_update_row
--   Purpose
--      Main lcok and update procedure
--   Note
--      1. Object version checking is performed before checking
--      2. Calling update_row if you don not want object version checking
--      3. All paramaters are IN parameter.
--      4. Raise NO_DATA_FOUND exception if no reocrd updated (??)
-- * -------------------------------------------------------------------------*
PROCEDURE lock_update_row
    ( p_pay_approval_flow_rec IN PAY_APPROVAL_FLOW_REC_TYPE) IS

   CURSOR c IS
     SELECT object_version_number
       FROM CN_PAY_APPROVAL_FLOW
     WHERE pay_approval_flow_id = p_pay_approval_flow_rec.pay_approval_flow_id;

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

   if (tlinfo.object_version_number <> p_pay_approval_flow_rec.object_version_number) then
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
   end if;
   UPDATE CN_PAY_APPROVAL_FLOW oldrec
      SET
         PAYRUN_ID = DECODE(p_pay_approval_flow_rec.PAYRUN_ID,
                                      FND_API.G_MISS_NUM,
                                      NULL,
                                      NULL,
                                      oldrec.PAYRUN_ID,
                                      p_pay_approval_flow_rec.PAYRUN_ID),
         PAYMENT_WORKSHEET_ID = DECODE(p_pay_approval_flow_rec.PAYMENT_WORKSHEET_ID,
                                      FND_API.G_MISS_NUM,
                                      NULL,
                                      NULL,
                                      oldrec.PAYMENT_WORKSHEET_ID,
                                      p_pay_approval_flow_rec.PAYMENT_WORKSHEET_ID),
         SUBMIT_BY_RESOURCE_ID = DECODE(p_pay_approval_flow_rec.SUBMIT_BY_RESOURCE_ID,
                                      FND_API.G_MISS_NUM,
                                      NULL,
                                      NULL,
                                      oldrec.SUBMIT_BY_RESOURCE_ID,
                                      p_pay_approval_flow_rec.SUBMIT_BY_RESOURCE_ID),
         SUBMIT_BY_USER_ID = DECODE(p_pay_approval_flow_rec.SUBMIT_BY_USER_ID,
                                      FND_API.G_MISS_NUM,
                                      NULL,
                                      NULL,
                                      oldrec.SUBMIT_BY_USER_ID,
                                      p_pay_approval_flow_rec.SUBMIT_BY_USER_ID),
         SUBMIT_BY_EMAIL = DECODE(p_pay_approval_flow_rec.SUBMIT_BY_EMAIL,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.SUBMIT_BY_EMAIL,
                                      p_pay_approval_flow_rec.SUBMIT_BY_EMAIL),
         SUBMIT_TO_RESOURCE_ID = DECODE(p_pay_approval_flow_rec.SUBMIT_TO_RESOURCE_ID,
                                      FND_API.G_MISS_NUM,
                                      NULL,
                                      NULL,
                                      oldrec.SUBMIT_TO_RESOURCE_ID,
                                      p_pay_approval_flow_rec.SUBMIT_TO_RESOURCE_ID),
         SUBMIT_TO_USER_ID = DECODE(p_pay_approval_flow_rec.SUBMIT_TO_USER_ID,
                                      FND_API.G_MISS_NUM,
                                      NULL,
                                      NULL,
                                      oldrec.SUBMIT_TO_USER_ID,
                                      p_pay_approval_flow_rec.SUBMIT_TO_USER_ID),
         SUBMIT_TO_EMAIL = DECODE(p_pay_approval_flow_rec.SUBMIT_TO_EMAIL,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.SUBMIT_TO_EMAIL,
                                      p_pay_approval_flow_rec.SUBMIT_TO_EMAIL),
         APPROVAL_STATUS = DECODE(p_pay_approval_flow_rec.APPROVAL_STATUS,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.APPROVAL_STATUS,
                                      p_pay_approval_flow_rec.APPROVAL_STATUS),
         UPDATED_BY_RESOURCE_ID = DECODE(p_pay_approval_flow_rec.UPDATED_BY_RESOURCE_ID,
                                      FND_API.G_MISS_NUM,
                                      NULL,
                                      NULL,
                                      oldrec.UPDATED_BY_RESOURCE_ID,
                                      p_pay_approval_flow_rec.UPDATED_BY_RESOURCE_ID),
         ATTRIBUTE_CATEGORY = DECODE(p_pay_approval_flow_rec.ATTRIBUTE_CATEGORY,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE_CATEGORY,
                                      p_pay_approval_flow_rec.ATTRIBUTE_CATEGORY),
         ATTRIBUTE1 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE1,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE1,
                                      p_pay_approval_flow_rec.ATTRIBUTE1),
         ATTRIBUTE2 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE2,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE2,
                                      p_pay_approval_flow_rec.ATTRIBUTE2),
         ATTRIBUTE3 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE3,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE3,
                                      p_pay_approval_flow_rec.ATTRIBUTE3),
         ATTRIBUTE4 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE4,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE4,
                                      p_pay_approval_flow_rec.ATTRIBUTE4),
         ATTRIBUTE5 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE5,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE5,
                                      p_pay_approval_flow_rec.ATTRIBUTE5),
         ATTRIBUTE6 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE6,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE6,
                                      p_pay_approval_flow_rec.ATTRIBUTE6),
         ATTRIBUTE7 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE7,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE7,
                                      p_pay_approval_flow_rec.ATTRIBUTE7),
         ATTRIBUTE8 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE8,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE8,
                                      p_pay_approval_flow_rec.ATTRIBUTE8),
         ATTRIBUTE9 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE9,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE9,
                                      p_pay_approval_flow_rec.ATTRIBUTE9),
         ATTRIBUTE10 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE10,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE10,
                                      p_pay_approval_flow_rec.ATTRIBUTE10),
         ATTRIBUTE11 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE11,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE11,
                                      p_pay_approval_flow_rec.ATTRIBUTE11),
         ATTRIBUTE12 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE12,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE12,
                                      p_pay_approval_flow_rec.ATTRIBUTE12),
         ATTRIBUTE13 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE13,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE13,
                                      p_pay_approval_flow_rec.ATTRIBUTE13),
         ATTRIBUTE14 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE14,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE14,
                                      p_pay_approval_flow_rec.ATTRIBUTE14),
         ATTRIBUTE15 = DECODE(p_pay_approval_flow_rec.ATTRIBUTE15,
                                      FND_API.G_MISS_CHAR,
                                      NULL,
                                      NULL,
                                      oldrec.ATTRIBUTE15,
                                      p_pay_approval_flow_rec.ATTRIBUTE15),
         LAST_UPDATE_DATE = Sysdate,
         LAST_UPDATED_BY = fnd_global.user_id,
         LAST_UPDATE_LOGIN = fnd_global.login_id,
         OBJECT_VERSION_NUMBER = oldrec.OBJECT_VERSION_NUMBER + 1
     WHERE pay_approval_flow_id = p_pay_approval_flow_rec.pay_approval_flow_id;

   IF (SQL%ROWCOUNT=0) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END lock_update_row;


-- * -------------------------------------------------------------------------*
--   Procedure Name
--  delete_row
--   Purpose
--      Main lcok and update procedure
--   Note
--      1. All paramaters are IN parameter.
--      2. Raise NO_DATA_FOUND exception if no reocrd deleted (??)
-- * -------------------------------------------------------------------------*
PROCEDURE delete_row
    (
      p_pay_approval_flow_id  NUMBER
    ) IS

BEGIN

   DELETE FROM CN_PAY_APPROVAL_FLOW
     WHERE pay_approval_flow_id = p_pay_approval_flow_id;

   IF (SQL%ROWCOUNT=0) THEN
      RAISE NO_DATA_FOUND;
   END IF;

END Delete_row;


END CN_PAY_APPROVAL_FLOW_PKG;

/
