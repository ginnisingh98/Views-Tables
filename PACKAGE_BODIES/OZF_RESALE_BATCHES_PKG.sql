--------------------------------------------------------
--  DDL for Package Body OZF_RESALE_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_RESALE_BATCHES_PKG" as
/* $Header: ozftrsbb.pls 120.2.12000000.2 2007/05/28 10:32:13 ateotia ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_RESALE_BATCHES_PKG
-- Purpose
--
-- History
-- Anuj Teotia              28/05/2007       bug # 5997978 fixed
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_RESALE_BATCHES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftrsbb.pls';


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
          px_resale_batch_id   IN OUT NOCOPY  NUMBER,
          px_object_version_number   IN OUT NOCOPY  NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_request_id    NUMBER,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_batch_number    VARCHAR2,
          p_batch_type    VARCHAR2,
          p_batch_count    NUMBER,
          p_year    NUMBER,
          p_month    NUMBER,
          p_report_date    DATE,
          p_report_start_date    DATE,
          p_report_end_date    DATE,
          p_status_code    VARCHAR2,
          p_data_source_code VARCHAR2, -- BUG 5077213
          p_reference_type    VARCHAR2,
          p_reference_number    VARCHAR2,
          p_comments    VARCHAR2,
          p_partner_claim_number    VARCHAR2,
          p_transaction_purpose_code VARCHAR2,
          p_transaction_type_code  VARCHAR2,
          p_partner_type    VARCHAR2,
          p_partner_id      NUMBER,
          p_partner_party_id  NUMBER,
          p_partner_cust_account_id    NUMBER,
          p_partner_site_id    NUMBER,
          p_partner_contact_party_id   NUMBER,
          p_partner_contact_name    VARCHAR2,
          p_partner_email    VARCHAR2,
          p_partner_phone    VARCHAR2,
          p_partner_fax    VARCHAR2,
          p_header_tolerance_operand    NUMBER,
          p_header_tolerance_calc_code    VARCHAR2,
          p_line_tolerance_operand    NUMBER,
          p_line_tolerance_calc_code    VARCHAR2,
          p_currency_code    VARCHAR2,
          p_claimed_amount    NUMBER,
          p_allowed_amount    NUMBER,
          p_paid_amount    NUMBER,
          p_disputed_amount    NUMBER,
          p_accepted_amount    NUMBER,
          p_lines_invalid    NUMBER,
          p_lines_w_tolerance    NUMBER,
          p_lines_disputed    NUMBER,
          p_batch_set_id_code    VARCHAR2,
          p_credit_code    VARCHAR2,
          p_credit_advice_date  DATE,
          p_purge_flag    VARCHAR2,
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
          px_org_id   IN OUT NOCOPY  NUMBER)

 IS
   x_rowid    VARCHAR2(30);

BEGIN

   -- Start: bug # 5997978 fixed
   -- org id can be null at batch level but then should always be given at lines level.
   /*IF (px_org_id IS NULL OR px_org_id = FND_API.G_MISS_NUM)
     SELECT NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99)
     INTO px_org_id
     FROM DUAL;
     END IF; */
   -- End: bug # 5997978 fixed

   px_object_version_number := 1;


   INSERT INTO OZF_RESALE_BATCHES_ALL(
           resale_batch_id,
           object_version_number,
           last_update_date,
           last_updated_by,
           creation_date,
           request_id,
           created_by,
           created_from,
           last_update_login,
           program_application_id,
           program_update_date,
           program_id,
           batch_number,
           batch_type,
           batch_count,
           year,
           month,
           report_date,
           batch_set_id_code,
           reference_type,
           reference_number,
           report_start_date,
           report_end_date,
           status_code,
           data_source_code, -- BUG 5077213
           comments,
           transaction_purpose_code,
           transaction_type_code,
           partner_type,
           partner_id,
           partner_party_id,
           partner_cust_account_id,
           partner_site_id,
           partner_contact_party_id,
           partner_contact_name,
           partner_email,
           partner_phone,
           partner_fax,
           partner_claim_number,
           claimed_amount,
           allowed_amount,
           paid_amount,
           disputed_amount,
           accepted_amount,
           currency_code,
           credit_code,
           credit_advice_date,
           lines_w_tolerance,
           lines_disputed,
           lines_invalid,
           header_tolerance_operand,
           header_tolerance_calc_code,
           line_tolerance_operand,
           line_tolerance_calc_code,
           purge_flag,
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
           org_id
   ) VALUES (
           px_resale_batch_id,
           px_object_version_number,
           p_last_update_date,
           p_last_updated_by,
           p_creation_date,
           p_request_id,
           p_created_by,
           p_created_from,
           p_last_update_login,
           p_program_application_id,
           p_program_update_date,
           p_program_id,
           p_batch_number,
           p_batch_type,
           p_batch_count,
           p_year,
           p_month,
           p_report_date,
           p_batch_set_id_code,
           p_reference_type,
           p_reference_number,
           p_report_start_date,
           p_report_end_date,
           p_status_code,
           p_data_source_code, -- BUG 5077213
           p_comments,
           p_transaction_purpose_code,
           p_transaction_type_code,
           p_partner_type,
           p_partner_id,
           p_partner_party_id,
           p_partner_cust_account_id,
           p_partner_site_id,
           p_partner_contact_party_id,
           p_partner_contact_name,
           p_partner_email,
           p_partner_phone,
           p_partner_fax,
           p_partner_claim_number,
           p_claimed_amount,
           p_allowed_amount,
           p_paid_amount,
           p_disputed_amount,
           p_accepted_amount,
           p_currency_code,
           p_credit_code,
           p_credit_advice_date,
           p_lines_w_tolerance,
           p_lines_disputed,
           p_lines_invalid,
           p_header_tolerance_operand,
           p_header_tolerance_calc_code,
           p_line_tolerance_operand,
           p_line_tolerance_calc_code,
           p_purge_flag,
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
           px_org_id);
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
          p_resale_batch_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_request_id    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_batch_number    VARCHAR2,
          p_batch_type    VARCHAR2,
          p_batch_count    NUMBER,
          p_year    NUMBER,
          p_month    NUMBER,
          p_report_date    DATE,
          p_report_start_date    DATE,
          p_report_end_date    DATE,
          p_status_code    VARCHAR2,
          --p_data_source_code VARCHAR2, -- BUG 5077213
          p_reference_type    VARCHAR2,
          p_reference_number    VARCHAR2,
          p_comments    VARCHAR2,
          p_partner_claim_number    VARCHAR2,
          p_transaction_purpose_code VARCHAR2,
          p_transaction_type_code  VARCHAR2,
          p_partner_type    VARCHAR2,
          p_partner_id      NUMBER,
          p_partner_party_id  NUMBER,
          p_partner_cust_account_id    NUMBER,
          p_partner_site_id    NUMBER,
          p_partner_contact_party_id   NUMBER,
          p_partner_contact_name    VARCHAR2,
          p_partner_email    VARCHAR2,
          p_partner_phone    VARCHAR2,
          p_partner_fax    VARCHAR2,
          p_header_tolerance_operand    NUMBER,
          p_header_tolerance_calc_code    VARCHAR2,
          p_line_tolerance_operand    NUMBER,
          p_line_tolerance_calc_code    VARCHAR2,
          p_currency_code    VARCHAR2,
          p_claimed_amount    NUMBER,
          p_allowed_amount    NUMBER,
          p_paid_amount    NUMBER,
          p_disputed_amount    NUMBER,
          p_accepted_amount    NUMBER,
          p_lines_invalid    NUMBER,
          p_lines_w_tolerance    NUMBER,
          p_lines_disputed    NUMBER,
          p_batch_set_id_code    VARCHAR2,
          p_credit_code    VARCHAR2,
          p_credit_advice_date  DATE,
          p_purge_flag    VARCHAR2,
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
          p_org_id    NUMBER)

 IS
 BEGIN
    UPDATE OZF_RESALE_BATCHES_ALL
    SET
              resale_batch_id = p_resale_batch_id,
              object_version_number = p_object_version_number,
              last_update_date = p_last_update_date,
              last_updated_by = p_last_updated_by,
              request_id = p_request_id,
              created_from = p_created_from,
              last_update_login = p_last_update_login,
              program_application_id = p_program_application_id,
              program_update_date = p_program_update_date,
              program_id = p_program_id,
              batch_number = p_batch_number,
              batch_type = p_batch_type,
              batch_count = p_batch_count,
              year = p_year,
              month = p_month,
              report_date = p_report_date,
              batch_set_id_code = p_batch_set_id_code,
              reference_type = p_reference_type,
              reference_number = p_reference_number,
              report_start_date = p_report_start_date,
              report_end_date = p_report_end_date,
              status_code = p_status_code,
              comments = p_comments,
              transaction_purpose_code = p_transaction_purpose_code,
              transaction_type_code = p_transaction_type_code,
              partner_type = p_partner_type,
              partner_id = p_partner_id,
              partner_party_id = p_partner_party_id,
              partner_cust_account_id = p_partner_cust_account_id,
              partner_site_id = p_partner_site_id,
              partner_contact_party_id = p_partner_contact_party_id,
              partner_contact_name = p_partner_contact_name,
              partner_email = p_partner_email,
              partner_phone = p_partner_phone,
              partner_fax = p_partner_fax,
              partner_claim_number = p_partner_claim_number,
              claimed_amount = p_claimed_amount,
              allowed_amount = p_allowed_amount,
              paid_amount = p_paid_amount,
              disputed_amount = p_disputed_amount,
              accepted_amount = p_accepted_amount,
              currency_code = p_currency_code,
              credit_code = p_credit_code,
              credit_advice_date = p_credit_advice_date,
              lines_w_tolerance = p_lines_w_tolerance,
              lines_disputed = p_lines_disputed,
              lines_invalid = p_lines_invalid,
              header_tolerance_operand = p_header_tolerance_operand,
              header_tolerance_calc_code = p_header_tolerance_calc_code,
              line_tolerance_operand = p_line_tolerance_operand,
              line_tolerance_calc_code = p_line_tolerance_calc_code,
              purge_flag = p_purge_flag,
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
              org_id = p_org_id
   WHERE resale_batch_id = p_resale_batch_id
   AND   object_version_number = p_object_version_number;

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
    p_RESALE_BATCH_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM OZF_RESALE_BATCHES_ALL
    WHERE RESALE_BATCH_ID = p_RESALE_BATCH_ID;
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
          p_resale_batch_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_request_id    NUMBER,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_batch_number    VARCHAR2,
          p_batch_type    VARCHAR2,
          p_batch_count    NUMBER,
          p_year    NUMBER,
          p_month    NUMBER,
          p_report_date    DATE,
          p_report_start_date    DATE,
          p_report_end_date    DATE,
          p_status_code    VARCHAR2,
          p_data_source_code VARCHAR2,
          p_reference_type    VARCHAR2,
          p_reference_number    VARCHAR2,
          p_comments    VARCHAR2,
          p_partner_claim_number    VARCHAR2,
          p_transaction_purpose_code VARCHAR2,
          p_transaction_type_code  VARCHAR2,
          p_partner_type    VARCHAR2,
          p_partner_id      NUMBER,
          p_partner_party_id  NUMBER,
          p_partner_cust_account_id    NUMBER,
          p_partner_site_id    NUMBER,
          p_partner_contact_party_id   NUMBER,
          p_partner_contact_name    VARCHAR2,
          p_partner_email    VARCHAR2,
          p_partner_phone    VARCHAR2,
          p_partner_fax    VARCHAR2,
          p_header_tolerance_operand    NUMBER,
          p_header_tolerance_calc_code    VARCHAR2,
          p_line_tolerance_operand    NUMBER,
          p_line_tolerance_calc_code    VARCHAR2,
          p_currency_code    VARCHAR2,
          p_claimed_amount    NUMBER,
          p_allowed_amount    NUMBER,
          p_paid_amount    NUMBER,
          p_disputed_amount    NUMBER,
          p_accepted_amount    NUMBER,
          p_lines_invalid    NUMBER,
          p_lines_w_tolerance    NUMBER,
          p_lines_disputed    NUMBER,
          p_batch_set_id_code    VARCHAR2,
          p_credit_code    VARCHAR2,
          p_credit_advice_date  DATE,
          p_purge_flag    VARCHAR2,
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
          p_org_id    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_RESALE_BATCHES_ALL
        WHERE RESALE_BATCH_ID =  p_RESALE_BATCH_ID
        FOR UPDATE of RESALE_BATCH_ID NOWAIT;
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
           (      Recinfo.resale_batch_id = p_resale_batch_id)
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
       AND (    ( Recinfo.request_id = p_request_id)
            OR (    ( Recinfo.request_id IS NULL )
                AND (  p_request_id IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.created_from = p_created_from)
            OR (    ( Recinfo.created_from IS NULL )
                AND (  p_created_from IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.program_application_id = p_program_application_id)
            OR (    ( Recinfo.program_application_id IS NULL )
                AND (  p_program_application_id IS NULL )))
       AND (    ( Recinfo.program_update_date = p_program_update_date)
            OR (    ( Recinfo.program_update_date IS NULL )
                AND (  p_program_update_date IS NULL )))
       AND (    ( Recinfo.program_id = p_program_id)
            OR (    ( Recinfo.program_id IS NULL )
                AND (  p_program_id IS NULL )))
       AND (    ( Recinfo.batch_number = p_batch_number)
            OR (    ( Recinfo.batch_number IS NULL )
                AND (  p_batch_number IS NULL )))
       AND (    ( Recinfo.batch_type = p_batch_type)
            OR (    ( Recinfo.batch_type IS NULL )
                AND (  p_batch_type IS NULL )))
       AND (    ( Recinfo.batch_count = p_batch_count)
            OR (    ( Recinfo.batch_count IS NULL )
                AND (  p_batch_count IS NULL )))
       AND (    ( Recinfo.year = p_year)
            OR (    ( Recinfo.year IS NULL )
                AND (  p_year IS NULL )))
       AND (    ( Recinfo.month = p_month)
            OR (    ( Recinfo.month IS NULL )
                AND (  p_month IS NULL )))
       AND (    ( Recinfo.report_date = p_report_date)
            OR (    ( Recinfo.report_date IS NULL )
                AND (  p_report_date IS NULL )))
       AND (    ( Recinfo.batch_set_id_code = p_batch_set_id_code)
            OR (    ( Recinfo.batch_set_id_code IS NULL )
                AND (  p_batch_set_id_code IS NULL )))
       AND (    ( Recinfo.reference_type = p_reference_type)
            OR (    ( Recinfo.reference_type IS NULL )
                AND (  p_reference_type IS NULL )))
       AND (    ( Recinfo.reference_number = p_reference_number)
            OR (    ( Recinfo.reference_number IS NULL )
                AND (  p_reference_number IS NULL )))
       AND (    ( Recinfo.report_start_date = p_report_start_date)
            OR (    ( Recinfo.report_start_date IS NULL )
                AND (  p_report_start_date IS NULL )))
       AND (    ( Recinfo.report_end_date = p_report_end_date)
            OR (    ( Recinfo.report_end_date IS NULL )
                AND (  p_report_end_date IS NULL )))
       AND (    ( Recinfo.status_code = p_status_code)
            OR (    ( Recinfo.status_code IS NULL )
                AND (  p_status_code IS NULL )))
       AND (    ( Recinfo.comments = p_comments)
            OR (    ( Recinfo.comments IS NULL )
                AND (  p_comments IS NULL )))
       AND (    ( Recinfo.transaction_purpose_code = p_transaction_purpose_code)
            OR (    ( Recinfo.transaction_purpose_code IS NULL )
                AND (  p_transaction_purpose_code IS NULL )))
       AND (    ( Recinfo.transaction_type_code = p_transaction_type_code)
            OR (    ( Recinfo.transaction_type_code IS NULL )
                AND (  p_transaction_type_code IS NULL )))
       AND (    ( Recinfo.partner_type = p_partner_type)
            OR (    ( Recinfo.partner_type IS NULL )
                AND (  p_partner_type IS NULL )))
       AND (    ( Recinfo.partner_id = p_partner_id)
            OR (    ( Recinfo.partner_id IS NULL )
                AND (  p_partner_id IS NULL )))
       AND (    ( Recinfo.partner_party_id = p_partner_party_id)
            OR (    ( Recinfo.partner_party_id IS NULL )
                AND (  p_partner_party_id IS NULL )))
       AND (    ( Recinfo.partner_cust_account_id = p_partner_cust_account_id)
            OR (    ( Recinfo.partner_cust_account_id IS NULL )
                AND (  p_partner_cust_account_id IS NULL )))
       AND (    ( Recinfo.partner_site_id = p_partner_site_id)
            OR (    ( Recinfo.partner_site_id IS NULL )
                AND (  p_partner_site_id IS NULL )))
       AND (    ( Recinfo.partner_contact_party_id = p_partner_contact_party_id)
            OR (    ( Recinfo.partner_contact_party_id IS NULL )
                AND (  p_partner_contact_party_id IS NULL )))
       AND (    ( Recinfo.partner_contact_name = p_partner_contact_name)
            OR (    ( Recinfo.partner_contact_name IS NULL )
                AND (  p_partner_contact_name IS NULL )))
       AND (    ( Recinfo.partner_email = p_partner_email)
            OR (    ( Recinfo.partner_email IS NULL )
                AND (  p_partner_email IS NULL )))
       AND (    ( Recinfo.partner_phone = p_partner_phone)
            OR (    ( Recinfo.partner_phone IS NULL )
                AND (  p_partner_phone IS NULL )))
       AND (    ( Recinfo.partner_fax = p_partner_fax)
            OR (    ( Recinfo.partner_fax IS NULL )
                AND (  p_partner_fax IS NULL )))
       AND (    ( Recinfo.partner_claim_number = p_partner_claim_number)
            OR (    ( Recinfo.partner_claim_number IS NULL )
                AND (  p_partner_claim_number IS NULL )))
       AND (    ( Recinfo.claimed_amount = p_claimed_amount)
            OR (    ( Recinfo.claimed_amount IS NULL )
                AND (  p_claimed_amount IS NULL )))
       AND (    ( Recinfo.allowed_amount = p_allowed_amount)
            OR (    ( Recinfo.allowed_amount IS NULL )
                AND (  p_allowed_amount IS NULL )))
       AND (    ( Recinfo.paid_amount = p_paid_amount)
            OR (    ( Recinfo.paid_amount IS NULL )
                AND (  p_paid_amount IS NULL )))
       AND (    ( Recinfo.disputed_amount = p_disputed_amount)
            OR (    ( Recinfo.disputed_amount IS NULL )
                AND (  p_disputed_amount IS NULL )))
       AND (    ( Recinfo.accepted_amount = p_accepted_amount)
            OR (    ( Recinfo.accepted_amount IS NULL )
                AND (  p_accepted_amount IS NULL )))
       AND (    ( Recinfo.currency_code = p_currency_code)
            OR (    ( Recinfo.currency_code IS NULL )
                AND (  p_currency_code IS NULL )))
       AND (    ( Recinfo.credit_code = p_credit_code)
            OR (    ( Recinfo.credit_code IS NULL )
                AND (  p_credit_code IS NULL )))
       AND (    ( Recinfo.credit_advice_date = p_credit_advice_date)
            OR (    ( Recinfo.credit_advice_date IS NULL )
                AND (  p_credit_advice_date IS NULL )))
       AND (    ( Recinfo.lines_w_tolerance = p_lines_w_tolerance)
            OR (    ( Recinfo.lines_w_tolerance IS NULL )
                AND (  p_lines_w_tolerance IS NULL )))
       AND (    ( Recinfo.lines_disputed = p_lines_disputed)
            OR (    ( Recinfo.lines_disputed IS NULL )
                AND (  p_lines_disputed IS NULL )))
       AND (    ( Recinfo.lines_invalid = p_lines_invalid)
            OR (    ( Recinfo.lines_invalid IS NULL )
                AND (  p_lines_invalid IS NULL )))
       AND (    ( Recinfo.header_tolerance_operand = p_header_tolerance_operand)
            OR (    ( Recinfo.header_tolerance_operand IS NULL )
                AND (  p_header_tolerance_operand IS NULL )))
       AND (    ( Recinfo.header_tolerance_calc_code = p_header_tolerance_calc_code)
            OR (    ( Recinfo.header_tolerance_calc_code IS NULL )
                AND (  p_header_tolerance_calc_code IS NULL )))
       AND (    ( Recinfo.line_tolerance_operand = p_line_tolerance_operand)
            OR (    ( Recinfo.line_tolerance_operand IS NULL )
                AND (  p_line_tolerance_operand IS NULL )))
       AND (    ( Recinfo.line_tolerance_calc_code = p_line_tolerance_calc_code)
            OR (    ( Recinfo.line_tolerance_calc_code IS NULL )
                AND (  p_line_tolerance_calc_code IS NULL )))
       AND (    ( Recinfo.purge_flag = p_purge_flag)
            OR (    ( Recinfo.purge_flag IS NULL )
                AND (  p_purge_flag IS NULL )))
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

END OZF_RESALE_BATCHES_PKG;

/
