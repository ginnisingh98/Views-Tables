--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_LINES_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_LINES_INT_PKG" as
/* $Header: ozftclib.pls 120.1 2005/07/08 07:08:59 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_CLAIM_LINES_INT_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_CLAIM_LINES_INT_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftclib.pls';


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
          px_interface_claim_line_id   IN OUT NOCOPY NUMBER,
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
          p_interface_claim_id    NUMBER,
          p_line_number    NUMBER,
          p_split_from_claim_line_id    NUMBER,
          p_amount    NUMBER,
          p_claim_currency_amount    NUMBER,
          p_acctd_amount    NUMBER,
          p_currency_code    VARCHAR2,
          p_exchange_rate_type    VARCHAR2,
          p_exchange_rate_date    DATE,
          p_exchange_rate    NUMBER,
          p_set_of_books_id    NUMBER,
          p_valid_flag    VARCHAR2,
          p_source_object_id    NUMBER,
          p_source_object_class    VARCHAR2,
          p_source_object_type_id    NUMBER,
	  p_source_object_line_id    NUMBER,
          p_plan_id    NUMBER,
          p_offer_id    NUMBER,
          p_utilization_id    NUMBER,
          p_payment_method    VARCHAR2,
          p_payment_reference_id    NUMBER,
          p_payment_reference_number    VARCHAR2,
          p_payment_reference_date    DATE,
          p_voucher_id    NUMBER,
          p_voucher_number    VARCHAR2,
          p_payment_status    VARCHAR2,
          p_approved_flag    VARCHAR2,
          p_approved_date    DATE,
          p_approved_by    NUMBER,
          p_settled_date    DATE,
          p_settled_by    NUMBER,
          p_performance_complete_flag    VARCHAR2,
          p_performance_attached_flag    VARCHAR2,
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
          px_org_id   IN OUT NOCOPY NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN

  -- R12 Enhancements
  /* IF (px_org_id IS NULL OR px_org_id = FND_API.G_MISS_NUM) THEN
       SELECT NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99)
       INTO px_org_id
       FROM DUAL;
   END IF;  */


   px_object_version_number := 1;


   INSERT INTO OZF_CLAIM_LINES_INT_ALL(
           interface_claim_line_id,
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
           interface_claim_id,
           line_number,
           split_from_claim_line_id,
           amount,
           claim_currency_amount,
           acctd_amount,
           currency_code,
           exchange_rate_type,
           exchange_rate_date,
           exchange_rate,
           set_of_books_id,
           valid_flag,
           source_object_id,
           source_object_class,
           source_object_type_id,
           source_object_line_id,
           plan_id,
           offer_id,
           utilization_id,
           payment_method,
           payment_reference_id,
           payment_reference_number,
           payment_reference_date,
           voucher_id,
           voucher_number,
           payment_status,
           approved_flag,
           approved_date,
           approved_by,
           settled_date,
           settled_by,
           performance_complete_flag,
           performance_attached_flag,
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
           px_interface_claim_line_id,
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
           p_interface_claim_id,
           p_line_number,
           p_split_from_claim_line_id,
           p_amount,
           p_claim_currency_amount,
           p_acctd_amount,
           p_currency_code,
           p_exchange_rate_type,
           p_exchange_rate_date,
           p_exchange_rate,
           p_set_of_books_id,
           p_valid_flag,
           p_source_object_id,
           p_source_object_class,
           p_source_object_type_id,
	   p_source_object_line_id,
           p_plan_id,
           p_offer_id,
           p_utilization_id,
           p_payment_method,
           p_payment_reference_id,
           p_payment_reference_number,
           p_payment_reference_date,
           p_voucher_id,
           p_voucher_number,
           p_payment_status,
           p_approved_flag,
           p_approved_date,
           p_approved_by,
           p_settled_date,
           p_settled_by,
           p_performance_complete_flag,
           p_performance_attached_flag,
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
          p_interface_claim_line_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_created_from    VARCHAR2,
          p_interface_claim_id    NUMBER,
          p_line_number    NUMBER,
          p_split_from_claim_line_id    NUMBER,
          p_amount    NUMBER,
          p_claim_currency_amount    NUMBER,
          p_acctd_amount    NUMBER,
          p_currency_code    VARCHAR2,
          p_exchange_rate_type    VARCHAR2,
          p_exchange_rate_date    DATE,
          p_exchange_rate    NUMBER,
          p_set_of_books_id    NUMBER,
          p_valid_flag    VARCHAR2,
          p_source_object_id    NUMBER,
          p_source_object_class    VARCHAR2,
          p_source_object_type_id    NUMBER,
	  p_source_object_line_id    NUMBER,
          p_plan_id    NUMBER,
          p_offer_id    NUMBER,
          p_utilization_id    NUMBER,
          p_payment_method    VARCHAR2,
          p_payment_reference_id    NUMBER,
          p_payment_reference_number    VARCHAR2,
          p_payment_reference_date    DATE,
          p_voucher_id    NUMBER,
          p_voucher_number    VARCHAR2,
          p_payment_status    VARCHAR2,
          p_approved_flag    VARCHAR2,
          p_approved_date    DATE,
          p_approved_by    NUMBER,
          p_settled_date    DATE,
          p_settled_by    NUMBER,
          p_performance_complete_flag    VARCHAR2,
          p_performance_attached_flag    VARCHAR2,
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
    Update OZF_CLAIM_LINES_INT_ALL
    SET
              interface_claim_line_id = p_interface_claim_line_id,
              object_version_number = p_object_version_number,
              last_update_date = p_last_update_date,
              last_updated_by = p_last_updated_by,
              last_update_login = p_last_update_login,
              request_id = p_request_id,
              program_application_id = p_program_application_id,
              program_update_date = p_program_update_date,
              program_id = p_program_id,
              created_from = p_created_from,
              interface_claim_id = p_interface_claim_id,
              line_number = p_line_number,
              split_from_claim_line_id = p_split_from_claim_line_id,
              amount = p_amount,
              claim_currency_amount = p_claim_currency_amount,
              acctd_amount = p_acctd_amount,
              currency_code = p_currency_code,
              exchange_rate_type = p_exchange_rate_type,
              exchange_rate_date = p_exchange_rate_date,
              exchange_rate = p_exchange_rate,
              set_of_books_id = p_set_of_books_id,
              valid_flag = p_valid_flag,
              source_object_id = p_source_object_id,
              source_object_class = p_source_object_class,
              source_object_type_id = p_source_object_type_id,
              source_object_line_id = p_source_object_line_id,
              plan_id = p_plan_id,
              offer_id = p_offer_id,
              utilization_id = p_utilization_id,
              payment_method = p_payment_method,
              payment_reference_id = p_payment_reference_id,
              payment_reference_number = p_payment_reference_number,
              payment_reference_date = p_payment_reference_date,
              voucher_id = p_voucher_id,
              voucher_number = p_voucher_number,
              payment_status = p_payment_status,
              approved_flag = p_approved_flag,
              approved_date = p_approved_date,
              approved_by = p_approved_by,
              settled_date = p_settled_date,
              settled_by = p_settled_by,
              performance_complete_flag = p_performance_complete_flag,
              performance_attached_flag = p_performance_attached_flag,
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
   WHERE INTERFACE_CLAIM_LINE_ID = p_INTERFACE_CLAIM_LINE_ID
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
    p_INTERFACE_CLAIM_LINE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM OZF_CLAIM_LINES_INT_ALL
    WHERE INTERFACE_CLAIM_LINE_ID = p_INTERFACE_CLAIM_LINE_ID;
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
          p_interface_claim_line_id    NUMBER,
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
          p_interface_claim_id    NUMBER,
          p_line_number    NUMBER,
          p_split_from_claim_line_id    NUMBER,
          p_amount    NUMBER,
          p_claim_currency_amount    NUMBER,
          p_acctd_amount    NUMBER,
          p_currency_code    VARCHAR2,
          p_exchange_rate_type    VARCHAR2,
          p_exchange_rate_date    DATE,
          p_exchange_rate    NUMBER,
          p_set_of_books_id    NUMBER,
          p_valid_flag    VARCHAR2,
          p_source_object_id    NUMBER,
          p_source_object_class    VARCHAR2,
          p_source_object_type_id    NUMBER,
	  p_source_object_line_id    NUMBER,
          p_plan_id    NUMBER,
          p_offer_id    NUMBER,
          p_utilization_id    NUMBER,
          p_payment_method    VARCHAR2,
          p_payment_reference_id    NUMBER,
          p_payment_reference_number    VARCHAR2,
          p_payment_reference_date    DATE,
          p_voucher_id    NUMBER,
          p_voucher_number    VARCHAR2,
          p_payment_status    VARCHAR2,
          p_approved_flag    VARCHAR2,
          p_approved_date    DATE,
          p_approved_by    NUMBER,
          p_settled_date    DATE,
          p_settled_by    NUMBER,
          p_performance_complete_flag    VARCHAR2,
          p_performance_attached_flag    VARCHAR2,
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
         FROM OZF_CLAIM_LINES_INT_ALL
        WHERE INTERFACE_CLAIM_LINE_ID =  p_INTERFACE_CLAIM_LINE_ID
        FOR UPDATE of INTERFACE_CLAIM_LINE_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('OZF', 'OZF_API_RECORD_NOT_FOUND');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.interface_claim_line_id = p_interface_claim_line_id)
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
       AND (    ( Recinfo.interface_claim_id = p_interface_claim_id)
            OR (    ( Recinfo.interface_claim_id IS NULL )
                AND (  p_interface_claim_id IS NULL )))
       AND (    ( Recinfo.line_number = p_line_number)
            OR (    ( Recinfo.line_number IS NULL )
                AND (  p_line_number IS NULL )))
       AND (    ( Recinfo.split_from_claim_line_id = p_split_from_claim_line_id)
            OR (    ( Recinfo.split_from_claim_line_id IS NULL )
                AND (  p_split_from_claim_line_id IS NULL )))
       AND (    ( Recinfo.amount = p_amount)
            OR (    ( Recinfo.amount IS NULL )
                AND (  p_amount IS NULL )))
       AND (    ( Recinfo.claim_currency_amount = p_claim_currency_amount)
            OR (    ( Recinfo.claim_currency_amount IS NULL )
                AND (  p_claim_currency_amount IS NULL )))
       AND (    ( Recinfo.acctd_amount = p_acctd_amount)
            OR (    ( Recinfo.acctd_amount IS NULL )
                AND (  p_acctd_amount IS NULL )))
       AND (    ( Recinfo.currency_code = p_currency_code)
            OR (    ( Recinfo.currency_code IS NULL )
                AND (  p_currency_code IS NULL )))
       AND (    ( Recinfo.exchange_rate_type = p_exchange_rate_type)
            OR (    ( Recinfo.exchange_rate_type IS NULL )
                AND (  p_exchange_rate_type IS NULL )))
       AND (    ( Recinfo.exchange_rate_date = p_exchange_rate_date)
            OR (    ( Recinfo.exchange_rate_date IS NULL )
                AND (  p_exchange_rate_date IS NULL )))
       AND (    ( Recinfo.exchange_rate = p_exchange_rate)
            OR (    ( Recinfo.exchange_rate IS NULL )
                AND (  p_exchange_rate IS NULL )))
       AND (    ( Recinfo.set_of_books_id = p_set_of_books_id)
            OR (    ( Recinfo.set_of_books_id IS NULL )
                AND (  p_set_of_books_id IS NULL )))
       AND (    ( Recinfo.valid_flag = p_valid_flag)
            OR (    ( Recinfo.valid_flag IS NULL )
                AND (  p_valid_flag IS NULL )))
       AND (    ( Recinfo.source_object_id = p_source_object_id)
            OR (    ( Recinfo.source_object_id IS NULL )
                AND (  p_source_object_id IS NULL )))
       AND (    ( Recinfo.source_object_class = p_source_object_class)
            OR (    ( Recinfo.source_object_class IS NULL )
                AND (  p_source_object_class IS NULL )))
       AND (    ( Recinfo.source_object_type_id = p_source_object_type_id)
            OR (    ( Recinfo.source_object_type_id IS NULL )
                AND (  p_source_object_type_id IS NULL )))
       AND (    ( Recinfo.source_object_line_id = p_source_object_line_id)
            OR (    ( Recinfo.source_object_line_id IS NULL )
                AND (  p_source_object_line_id IS NULL )))
       AND (    ( Recinfo.plan_id = p_plan_id)
            OR (    ( Recinfo.plan_id IS NULL )
                AND (  p_plan_id IS NULL )))
       AND (    ( Recinfo.offer_id = p_offer_id)
            OR (    ( Recinfo.offer_id IS NULL )
                AND (  p_offer_id IS NULL )))
       AND (    ( Recinfo.utilization_id = p_utilization_id)
            OR (    ( Recinfo.utilization_id IS NULL )
                AND (  p_utilization_id IS NULL )))
       AND (    ( Recinfo.payment_method = p_payment_method)
            OR (    ( Recinfo.payment_method IS NULL )
                AND (  p_payment_method IS NULL )))
       AND (    ( Recinfo.payment_reference_id = p_payment_reference_id)
            OR (    ( Recinfo.payment_reference_id IS NULL )
                AND (  p_payment_reference_id IS NULL )))
       AND (    ( Recinfo.payment_reference_number = p_payment_reference_number)
            OR (    ( Recinfo.payment_reference_number IS NULL )
                AND (  p_payment_reference_number IS NULL )))
       AND (    ( Recinfo.payment_reference_date = p_payment_reference_date)
            OR (    ( Recinfo.payment_reference_date IS NULL )
                AND (  p_payment_reference_date IS NULL )))
       AND (    ( Recinfo.voucher_id = p_voucher_id)
            OR (    ( Recinfo.voucher_id IS NULL )
                AND (  p_voucher_id IS NULL )))
       AND (    ( Recinfo.voucher_number = p_voucher_number)
            OR (    ( Recinfo.voucher_number IS NULL )
                AND (  p_voucher_number IS NULL )))
       AND (    ( Recinfo.payment_status = p_payment_status)
            OR (    ( Recinfo.payment_status IS NULL )
                AND (  p_payment_status IS NULL )))
       AND (    ( Recinfo.approved_flag = p_approved_flag)
            OR (    ( Recinfo.approved_flag IS NULL )
                AND (  p_approved_flag IS NULL )))
       AND (    ( Recinfo.approved_date = p_approved_date)
            OR (    ( Recinfo.approved_date IS NULL )
                AND (  p_approved_date IS NULL )))
       AND (    ( Recinfo.approved_by = p_approved_by)
            OR (    ( Recinfo.approved_by IS NULL )
                AND (  p_approved_by IS NULL )))
       AND (    ( Recinfo.settled_date = p_settled_date)
            OR (    ( Recinfo.settled_date IS NULL )
                AND (  p_settled_date IS NULL )))
       AND (    ( Recinfo.settled_by = p_settled_by)
            OR (    ( Recinfo.settled_by IS NULL )
                AND (  p_settled_by IS NULL )))
       AND (    ( Recinfo.performance_complete_flag = p_performance_complete_flag)
            OR (    ( Recinfo.performance_complete_flag IS NULL )
                AND (  p_performance_complete_flag IS NULL )))
       AND (    ( Recinfo.performance_attached_flag = p_performance_attached_flag)
            OR (    ( Recinfo.performance_attached_flag IS NULL )
                AND (  p_performance_attached_flag IS NULL )))
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
       FND_MESSAGE.SET_NAME('OZF', 'OZF_API_RECORD_NOT_FOUND');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END OZF_CLAIM_LINES_INT_PKG;

/
