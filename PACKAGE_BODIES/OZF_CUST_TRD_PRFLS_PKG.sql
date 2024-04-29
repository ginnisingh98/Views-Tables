--------------------------------------------------------
--  DDL for Package Body OZF_CUST_TRD_PRFLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CUST_TRD_PRFLS_PKG" as
/* $Header: ozftctpb.pls 120.2 2005/09/14 05:11:43 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_cust_trd_prfls_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_cust_trd_prfls_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftctpb.pls';

G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

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
          px_trade_profile_id   IN OUT NOCOPY NUMBER,
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
          p_party_id    NUMBER,
          p_site_use_id    NUMBER,
          p_autopay_flag    VARCHAR2,
          p_claim_threshold    NUMBER,
          p_claim_currency    VARCHAR2,
          p_print_flag    VARCHAR2,
          p_internet_deal_view_flag    VARCHAR2,
          p_internet_claims_flag    VARCHAR2,
          p_autopay_periodicity    NUMBER,
          p_autopay_periodicity_type    VARCHAR2,
          p_payment_method    VARCHAR2,
          p_discount_type    VARCHAR2,
          p_cust_account_id    NUMBER,
          p_cust_acct_site_id    NUMBER,
          p_vendor_id    NUMBER,
          p_vendor_site_id    NUMBER,
          p_vendor_site_code    VARCHAR2,
          p_context    VARCHAR2,
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
          px_org_id   IN OUT NOCOPY NUMBER,
          p_days_due    NUMBER,
    	  p_pos_write_off_threshold NUMBER,
	  p_neg_write_off_threshold NUMBER,
    	  p_un_earned_pay_allow_to VARCHAR2,
	  p_un_earned_pay_thold_type VARCHAR2,
    	  p_un_earned_pay_threshold NUMBER,
	  p_un_earned_pay_thold_flag VARCHAR2,
          p_header_tolerance_calc_code VARCHAR2,
          p_header_tolerance_operand NUMBER,
          p_line_tolerance_calc_code VARCHAR2,
          p_line_tolerance_operand NUMBER
          )

 IS
   x_rowid    VARCHAR2(30);


BEGIN
       IF g_debug THEN
          OZF_UTILITY_PVT.debug_message( 'Into begin 1');
       END IF;

 -- R12 Enhancements
   IF (px_org_id IS NULL OR px_org_id = FND_API.G_MISS_NUM) THEN
       px_org_id := MO_GLOBAL.get_current_org_id();
   END IF;

   px_object_version_number := 1;
   IF g_debug THEN
           OZF_UTILITY_PVT.debug_message( 'before insert 2');
       OZF_UTILITY_PVT.debug_message( 'Party id is'||p_party_id );
       OZF_UTILITY_PVT.debug_message( 'vendor id is'||p_vendor_id );
       OZF_UTILITY_PVT.debug_message( 'vendor site id is'||p_vendor_site_id );
    END IF;

   INSERT INTO ozf_cust_trd_prfls_all(
           trade_profile_id,
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
           party_id,
           site_use_id,
           autopay_flag,
           claim_threshold,
           claim_currency,
           print_flag,
           internet_deal_view_flag,
           internet_claims_flag,
           autopay_periodicity,
           autopay_periodicity_type,
           payment_method,
           discount_type,
           cust_account_id,
           cust_acct_site_id,
           vendor_id,
           vendor_site_id,
           vendor_site_code,
           context,
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
           days_due,
	   pos_write_off_threshold,
           neg_write_off_threshold,
	   un_earned_pay_allow_to,
    	   un_earned_pay_thold_type,
	   un_earned_pay_thold_amount,
	   un_earned_pay_thold_flag,
           header_tolerance_calc_code,
           header_tolerance_operand,
           line_tolerance_calc_code,
           line_tolerance_operand
   ) VALUES (
           px_trade_profile_id,
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
           p_party_id,
           p_site_use_id,
           p_autopay_flag,
           p_claim_threshold,
           p_claim_currency,
           p_print_flag,
           p_internet_deal_view_flag,
           p_internet_claims_flag,
           p_autopay_periodicity,
           p_autopay_periodicity_type,
           p_payment_method,
           p_discount_type,
           p_cust_account_id,
           p_cust_acct_site_id,
           p_vendor_id,
           p_vendor_site_id,
           p_vendor_site_code,
           p_context,
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
           p_days_due,
           p_pos_write_off_threshold,
           p_neg_write_off_threshold,
           p_un_earned_pay_allow_to,
           p_un_earned_pay_thold_type,
           p_un_earned_pay_threshold,
           p_un_earned_pay_thold_flag,
           p_header_tolerance_calc_code,
           p_header_tolerance_operand,
           p_line_tolerance_calc_code,
           p_line_tolerance_operand
          );
       IF g_debug THEN
	  OZF_UTILITY_PVT.debug_message( 'after insert 2');
       END IF;

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
          p_trade_profile_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_created_from    VARCHAR2,
          p_party_id    NUMBER,
          p_site_use_id    NUMBER,
          p_autopay_flag    VARCHAR2,
          p_claim_threshold    NUMBER,
          p_claim_currency    VARCHAR2,
          p_print_flag    VARCHAR2,
          p_internet_deal_view_flag    VARCHAR2,
          p_internet_claims_flag    VARCHAR2,
          p_autopay_periodicity    NUMBER,
          p_autopay_periodicity_type    VARCHAR2,
          p_payment_method    VARCHAR2,
          p_discount_type    VARCHAR2,
          p_cust_account_id    NUMBER,
          p_cust_acct_site_id    NUMBER,
          p_vendor_id    NUMBER,
          p_vendor_site_id    NUMBER,
          p_vendor_site_code    VARCHAR2,
          p_context    VARCHAR2,
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
          p_days_due    NUMBER,
    	  p_pos_write_off_threshold NUMBER,
	  p_neg_write_off_threshold NUMBER,
    	  p_un_earned_pay_allow_to VARCHAR2,
	  p_un_earned_pay_thold_type VARCHAR2,
    	  p_un_earned_pay_threshold NUMBER,
	  p_un_earned_pay_thold_flag VARCHAR2,
          p_header_tolerance_calc_code VARCHAR2,
          p_header_tolerance_operand NUMBER,
          p_line_tolerance_calc_code VARCHAR2,
          p_line_tolerance_operand NUMBER
          )
IS
BEGIN

   IF g_debug THEN
      OZF_UTILITY_PVT.debug_message( 'Inside update table ');
      OZF_UTILITY_PVT.debug_message( 'Inside update table 2' || p_trade_profile_id);
      OZF_UTILITY_PVT.debug_message( 'Inside update table3'|| p_object_version_number);
   END IF;

   Update ozf_cust_trd_prfls_all
   SET
       trade_profile_id = p_trade_profile_id,
       object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number + 1),
       last_update_date = p_last_update_date,
       last_updated_by = p_last_updated_by,
       last_update_login = p_last_update_login,
       request_id = p_request_id,
       program_application_id = p_program_application_id,
       program_update_date = p_program_update_date,
       program_id = p_program_id,
       created_from = p_created_from,
       party_id = p_party_id,
       site_use_id = p_site_use_id,
       autopay_flag = p_autopay_flag,
       claim_threshold = p_claim_threshold,
       claim_currency = p_claim_currency,
       print_flag = p_print_flag,
       internet_deal_view_flag = p_internet_deal_view_flag,
       internet_claims_flag = p_internet_claims_flag,
       autopay_periodicity = p_autopay_periodicity,
       autopay_periodicity_type = p_autopay_periodicity_type,
       payment_method = p_payment_method,
       discount_type = p_discount_type,
       cust_account_id = p_cust_account_id,
       cust_acct_site_id = p_cust_acct_site_id,
       vendor_id = p_vendor_id,
       vendor_site_id = p_vendor_site_id,
       vendor_site_code = p_vendor_site_code,
       context = p_context,
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
       days_due = p_days_due,
       pos_write_off_threshold = p_pos_write_off_threshold,
       neg_write_off_threshold = p_neg_write_off_threshold,
       un_earned_pay_allow_to = p_un_earned_pay_allow_to,
       un_earned_pay_thold_type = p_un_earned_pay_thold_type,
       un_earned_pay_thold_amount = p_un_earned_pay_threshold,
       un_earned_pay_thold_flag = p_un_earned_pay_thold_flag,
       header_tolerance_calc_code = p_header_tolerance_calc_code,
       header_tolerance_operand = p_header_tolerance_operand,
       line_tolerance_calc_code = p_line_tolerance_calc_code,
       line_tolerance_operand = p_line_tolerance_operand
   WHERE TRADE_PROFILE_ID = p_trade_profile_id;
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
    p_TRADE_PROFILE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM ozf_cust_trd_prfls_all
    WHERE TRADE_PROFILE_ID = p_TRADE_PROFILE_ID;
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
          p_trade_profile_id    NUMBER,
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
          p_party_id    NUMBER,
          p_site_use_id    NUMBER,
          p_autopay_flag    VARCHAR2,
          p_claim_threshold    NUMBER,
          p_claim_currency    VARCHAR2,
          p_print_flag    VARCHAR2,
          p_internet_deal_view_flag    VARCHAR2,
          p_internet_claims_flag    VARCHAR2,
          p_autopay_periodicity    NUMBER,
          p_autopay_periodicity_type    VARCHAR2,
          p_payment_method    VARCHAR2,
          p_discount_type    VARCHAR2,
          p_cust_account_id    NUMBER,
          p_cust_acct_site_id    NUMBER,
          p_vendor_id    NUMBER,
          p_vendor_site_id    NUMBER,
          p_vendor_site_code    VARCHAR2,
          p_context    VARCHAR2,
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
          p_days_due    NUMBER)

IS
   CURSOR C IS
      SELECT *
      FROM ozf_cust_trd_prfls_all
      WHERE TRADE_PROFILE_ID =  p_TRADE_PROFILE_ID
      FOR UPDATE of TRADE_PROFILE_ID NOWAIT;
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
   IF(
           (      Recinfo.trade_profile_id = p_trade_profile_id)
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
       AND (    ( Recinfo.party_id = p_party_id)
            OR (    ( Recinfo.party_id IS NULL )
                AND (  p_party_id IS NULL )))
       AND (    ( Recinfo.site_use_id = p_site_use_id)
            OR (    ( Recinfo.site_use_id IS NULL )
                AND (  p_site_use_id IS NULL )))
       AND (    ( Recinfo.autopay_flag = p_autopay_flag)
            OR (    ( Recinfo.autopay_flag IS NULL )
                AND (  p_autopay_flag IS NULL )))
       AND (    ( Recinfo.claim_threshold = p_claim_threshold)
            OR (    ( Recinfo.claim_threshold IS NULL )
                AND (  p_claim_threshold IS NULL )))
       AND (    ( Recinfo.claim_currency = p_claim_currency)
            OR (    ( Recinfo.claim_currency IS NULL )
                AND (  p_claim_currency IS NULL )))
       AND (    ( Recinfo.print_flag = p_print_flag)
            OR (    ( Recinfo.print_flag IS NULL )
                AND (  p_print_flag IS NULL )))
       AND (    ( Recinfo.internet_deal_view_flag = p_internet_deal_view_flag)
            OR (    ( Recinfo.internet_deal_view_flag IS NULL )
                AND (  p_internet_deal_view_flag IS NULL )))
       AND (    ( Recinfo.internet_claims_flag = p_internet_claims_flag)
            OR (    ( Recinfo.internet_claims_flag IS NULL )
                AND (  p_internet_claims_flag IS NULL )))
       AND (    ( Recinfo.autopay_periodicity = p_autopay_periodicity)
            OR (    ( Recinfo.autopay_periodicity IS NULL )
                AND (  p_autopay_periodicity IS NULL )))
       AND (    ( Recinfo.autopay_periodicity_type = p_autopay_periodicity_type)
            OR (    ( Recinfo.autopay_periodicity_type IS NULL )
                AND (  p_autopay_periodicity_type IS NULL )))
       AND (    ( Recinfo.payment_method = p_payment_method)
            OR (    ( Recinfo.payment_method IS NULL )
                AND (  p_payment_method IS NULL )))
       AND (    ( Recinfo.discount_type = p_discount_type)
            OR (    ( Recinfo.discount_type IS NULL )
                AND (  p_discount_type IS NULL )))
       AND (    ( Recinfo.cust_account_id = p_cust_account_id)
            OR (    ( Recinfo.cust_account_id IS NULL )
                AND (  p_cust_account_id IS NULL )))
       AND (    ( Recinfo.cust_acct_site_id = p_cust_acct_site_id)
            OR (    ( Recinfo.cust_acct_site_id IS NULL )
                AND (  p_cust_acct_site_id IS NULL )))
       AND (    ( Recinfo.vendor_id = p_vendor_id)
            OR (    ( Recinfo.vendor_id IS NULL )
                AND (  p_vendor_id IS NULL )))
       AND (    ( Recinfo.vendor_site_id = p_vendor_site_id)
            OR (    ( Recinfo.vendor_site_id IS NULL )
                AND (  p_vendor_site_id IS NULL )))
       AND (    ( Recinfo.vendor_site_code = p_vendor_site_code)
            OR (    ( Recinfo.vendor_site_code IS NULL )
                AND (  p_vendor_site_code IS NULL )))
       AND (    ( Recinfo.context = p_context)
            OR (    ( Recinfo.context IS NULL )
                AND (  p_context IS NULL )))
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
       AND (    ( Recinfo.days_due = p_days_due)
            OR (    ( Recinfo.days_due IS NULL )
                AND (  p_days_due IS NULL )))
       ) THEN
       RETURN;
   ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END OZF_cust_trd_prfls_PKG;

/
