--------------------------------------------------------
--  DDL for Package Body OZF_SETTLEMENT_DOCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SETTLEMENT_DOCS_PKG" as
/* $Header: ozftcsdb.pls 120.1 2005/07/08 06:59:59 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_SETTLEMENT_DOCS_PKG
-- Purpose
--
-- History
--
--    MCHANG      23-OCT-2001      Remove security_group_id.
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_SETTLEMENT_DOCS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftcsdb.pls';


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_settlement_doc_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_created_from    VARCHAR2,
          p_claim_id    NUMBER,
          p_claim_line_id    NUMBER,
          p_payment_method    VARCHAR2,
          p_settlement_id    NUMBER,
          p_settlement_type    VARCHAR2,
          p_settlement_type_id    NUMBER,
          p_settlement_number    VARCHAR2,
          p_settlement_date    DATE,
          p_settlement_amount    NUMBER,
          p_settlement_acctd_amount    NUMBER,
          p_status_code    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          px_org_id      IN OUT NOCOPY NUMBER,
          p_payment_reference_id       NUMBER,
          p_payment_reference_number   VARCHAR2,
          p_payment_status             VARCHAR2,
          p_group_claim_id             NUMBER,
          p_gl_date                    DATE,
          p_wo_rec_trx_id              NUMBER
)

 IS
   x_rowid    VARCHAR2(30);


BEGIN

  -- R12 Enhancements
  /* IF (px_org_id IS NULL OR px_org_id = FND_API.G_MISS_NUM) THEN
       SELECT NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99)
       INTO px_org_id
       FROM DUAL;
   END IF; */


   px_object_version_number := 1;


   INSERT INTO OZF_SETTLEMENT_DOCS_ALL(
           settlement_doc_id,
           object_version_number,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           request_id,
           program_application_id,
           program_update_date,
           program_id,
           created_from,
           claim_id,
           claim_line_id,
           payment_method,
           settlement_id,
           settlement_type,
           settlement_type_id,
           settlement_number,
           settlement_date,
           settlement_amount,
           settlement_acctd_amount,
           status_code,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           org_id,
           payment_reference_id,
           payment_reference_number,
           payment_status,
           group_claim_id,
           gl_date,
           wo_rec_trx_id
   ) VALUES (
           px_settlement_doc_id,
           px_object_version_number,
           p_last_update_date,
           p_last_updated_by,
           p_creation_date,
           p_created_by,
           p_last_update_login,
           p_request_id,
           p_program_application_id,
           p_program_update_date,
           p_program_id,
           p_created_from,
           p_claim_id,
           p_claim_line_id,
           p_payment_method,
           p_settlement_id,
           p_settlement_type,
           p_settlement_type_id,
           p_settlement_number,
           p_settlement_date,
           p_settlement_amount,
           p_settlement_acctd_amount,
           p_status_code,
           p_attribute_category,
           p_attribute1,
           p_attribute2,
           p_attribute3,
           p_attribute4,
           p_attribute5,
           p_attribute6,
           p_attribute7,
           p_attribute8,
           p_attribute9,
           p_attribute10,
           p_attribute11,
           p_attribute12,
           p_attribute13,
           p_attribute14,
           p_attribute15,
           px_org_id,
           p_payment_reference_id,
           p_payment_reference_number,
           p_payment_status,
           p_group_claim_id,
           p_gl_date,
           p_wo_rec_trx_id
           );
END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_settlement_doc_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_created_from    VARCHAR2,
          p_claim_id    NUMBER,
          p_claim_line_id    NUMBER,
          p_payment_method    VARCHAR2,
          p_settlement_id    NUMBER,
          p_settlement_type    VARCHAR2,
          p_settlement_type_id    NUMBER,
          p_settlement_number    VARCHAR2,
          p_settlement_date    DATE,
          p_settlement_amount    NUMBER,
          p_settlement_acctd_amount    NUMBER,
          p_status_code    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_org_id    NUMBER,
          p_payment_reference_id       NUMBER,
          p_payment_reference_number   VARCHAR2,
          p_payment_status             VARCHAR2,
          p_group_claim_id             NUMBER,
          p_gl_date                    DATE,
          p_wo_rec_trx_id              NUMBER
)

 IS
 BEGIN
    Update OZF_SETTLEMENT_DOCS_ALL
    SET
              settlement_doc_id = p_settlement_doc_id,
              object_version_number = p_object_version_number,
              last_update_date = p_last_update_date,
              last_updated_by = p_last_updated_by,
              last_update_login = p_last_update_login,
              request_id = p_request_id,
              program_application_id = p_program_application_id,
              program_update_date = p_program_update_date,
              program_id = p_program_id,
              created_from = p_created_from,
              claim_id = p_claim_id,
              claim_line_id = p_claim_line_id,
              payment_method = p_payment_method,
              settlement_id = p_settlement_id,
              settlement_type = p_settlement_type,
              settlement_type_id = p_settlement_type_id,
              settlement_number = p_settlement_number,
              settlement_date = p_settlement_date,
              settlement_amount = p_settlement_amount,
              settlement_acctd_amount = p_settlement_acctd_amount,
              status_code = p_status_code,
              attribute_category = p_attribute_category,
              attribute1 = p_attribute1,
              attribute2 = p_attribute2,
              attribute3 = p_attribute3,
              attribute4 = p_attribute4,
              attribute5 = p_attribute5,
              attribute6 = p_attribute6,
              attribute7 = p_attribute7,
              attribute8 = p_attribute8,
              attribute9 = p_attribute9,
              attribute10 = p_attribute10,
              attribute11 = p_attribute11,
              attribute12 = p_attribute12,
              attribute13 = p_attribute13,
              attribute14 = p_attribute14,
              attribute15 = p_attribute15,
              org_id = p_org_id,
              payment_reference_id = p_payment_reference_id,
              payment_reference_number = p_payment_reference_number,
              payment_status = p_payment_status,
              group_claim_id = p_group_claim_id,
              gl_date = p_gl_date,
              wo_rec_trx_id = p_wo_rec_trx_id
   WHERE SETTLEMENT_DOC_ID = p_SETTLEMENT_DOC_ID;

   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_SETTLEMENT_DOC_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM OZF_SETTLEMENT_DOCS_ALL
    WHERE SETTLEMENT_DOC_ID = p_SETTLEMENT_DOC_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
          p_settlement_doc_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_created_from    VARCHAR2,
          p_claim_id    NUMBER,
          p_claim_line_id    NUMBER,
          p_payment_method    VARCHAR2,
          p_settlement_id    NUMBER,
          p_settlement_type    VARCHAR2,
          p_settlement_type_id    NUMBER,
          p_settlement_number    VARCHAR2,
          p_settlement_date    DATE,
          p_settlement_amount    NUMBER,
          p_settlement_acctd_amount    NUMBER,
          p_status_code    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_org_id    NUMBER
)

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_SETTLEMENT_DOCS_ALL
        WHERE SETTLEMENT_DOC_ID =  p_SETTLEMENT_DOC_ID
        FOR UPDATE of SETTLEMENT_DOC_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.settlement_doc_id = p_settlement_doc_id)
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.request_id = p_request_id)
            OR (    ( Recinfo.request_id IS NULL )
                AND (  p_request_id IS NULL )))
       AND (    ( Recinfo.program_application_id = p_program_application_id)
            OR (    ( Recinfo.program_application_id IS NULL )
                AND (  p_program_application_id IS NULL )))
       AND (    ( Recinfo.program_update_date = p_program_update_date)
            OR (    ( Recinfo.program_update_date IS NULL )
                AND (  p_program_update_date IS NULL )))
       AND (    ( Recinfo.program_id = p_program_id)
            OR (    ( Recinfo.program_id IS NULL )
                AND (  p_program_id IS NULL )))
       AND (    ( Recinfo.created_from = p_created_from)
            OR (    ( Recinfo.created_from IS NULL )
                AND (  p_created_from IS NULL )))
       AND (    ( Recinfo.claim_id = p_claim_id)
            OR (    ( Recinfo.claim_id IS NULL )
                AND (  p_claim_id IS NULL )))
       AND (    ( Recinfo.claim_line_id = p_claim_line_id)
            OR (    ( Recinfo.claim_line_id IS NULL )
                AND (  p_claim_line_id IS NULL )))
       AND (    ( Recinfo.payment_method = p_payment_method)
            OR (    ( Recinfo.payment_method IS NULL )
                AND (  p_payment_method IS NULL )))
       AND (    ( Recinfo.settlement_id = p_settlement_id)
            OR (    ( Recinfo.settlement_id IS NULL )
                AND (  p_settlement_id IS NULL )))
       AND (    ( Recinfo.settlement_type = p_settlement_type)
            OR (    ( Recinfo.settlement_type IS NULL )
                AND (  p_settlement_type IS NULL )))
       AND (    ( Recinfo.settlement_type_id = p_settlement_type_id)
            OR (    ( Recinfo.settlement_type_id IS NULL )
                AND (  p_settlement_type_id IS NULL )))
       AND (    ( Recinfo.settlement_number = p_settlement_number)
            OR (    ( Recinfo.settlement_number IS NULL )
                AND (  p_settlement_number IS NULL )))
       AND (    ( Recinfo.settlement_date = p_settlement_date)
            OR (    ( Recinfo.settlement_date IS NULL )
                AND (  p_settlement_date IS NULL )))
       AND (    ( Recinfo.settlement_amount = p_settlement_amount)
            OR (    ( Recinfo.settlement_amount IS NULL )
                AND (  p_settlement_amount IS NULL )))
       AND (    ( Recinfo.settlement_acctd_amount = p_settlement_acctd_amount)
            OR (    ( Recinfo.settlement_acctd_amount IS NULL )
                AND (  p_settlement_amount IS NULL )))
       AND (    ( Recinfo.status_code = p_status_code)
            OR (    ( Recinfo.status_code IS NULL )
                AND (  p_status_code IS NULL )))
       AND (    ( Recinfo.attribute_category = p_attribute_category)
            OR (    ( Recinfo.attribute_category IS NULL )
                AND (  p_attribute_category IS NULL )))
       AND (    ( Recinfo.attribute1 = p_attribute1)
            OR (    ( Recinfo.attribute1 IS NULL )
                AND (  p_attribute1 IS NULL )))
       AND (    ( Recinfo.attribute2 = p_attribute2)
            OR (    ( Recinfo.attribute2 IS NULL )
                AND (  p_attribute2 IS NULL )))
       AND (    ( Recinfo.attribute3 = p_attribute3)
            OR (    ( Recinfo.attribute3 IS NULL )
                AND (  p_attribute3 IS NULL )))
       AND (    ( Recinfo.attribute4 = p_attribute4)
            OR (    ( Recinfo.attribute4 IS NULL )
                AND (  p_attribute4 IS NULL )))
       AND (    ( Recinfo.attribute5 = p_attribute5)
            OR (    ( Recinfo.attribute5 IS NULL )
                AND (  p_attribute5 IS NULL )))
       AND (    ( Recinfo.attribute6 = p_attribute6)
            OR (    ( Recinfo.attribute6 IS NULL )
                AND (  p_attribute6 IS NULL )))
       AND (    ( Recinfo.attribute7 = p_attribute7)
            OR (    ( Recinfo.attribute7 IS NULL )
                AND (  p_attribute7 IS NULL )))
       AND (    ( Recinfo.attribute8 = p_attribute8)
            OR (    ( Recinfo.attribute8 IS NULL )
                AND (  p_attribute8 IS NULL )))
       AND (    ( Recinfo.attribute9 = p_attribute9)
            OR (    ( Recinfo.attribute9 IS NULL )
                AND (  p_attribute9 IS NULL )))
       AND (    ( Recinfo.attribute10 = p_attribute10)
            OR (    ( Recinfo.attribute10 IS NULL )
                AND (  p_attribute10 IS NULL )))
       AND (    ( Recinfo.attribute11 = p_attribute11)
            OR (    ( Recinfo.attribute11 IS NULL )
                AND (  p_attribute11 IS NULL )))
       AND (    ( Recinfo.attribute12 = p_attribute12)
            OR (    ( Recinfo.attribute12 IS NULL )
                AND (  p_attribute12 IS NULL )))
       AND (    ( Recinfo.attribute13 = p_attribute13)
            OR (    ( Recinfo.attribute13 IS NULL )
                AND (  p_attribute13 IS NULL )))
       AND (    ( Recinfo.attribute14 = p_attribute14)
            OR (    ( Recinfo.attribute14 IS NULL )
                AND (  p_attribute14 IS NULL )))
       AND (    ( Recinfo.attribute15 = p_attribute15)
            OR (    ( Recinfo.attribute15 IS NULL )
                AND (  p_attribute15 IS NULL )))
       AND (    ( Recinfo.org_id = p_org_id)
            OR (    ( Recinfo.org_id IS NULL )
                AND (  p_org_id IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END OZF_SETTLEMENT_DOCS_PKG;

/
