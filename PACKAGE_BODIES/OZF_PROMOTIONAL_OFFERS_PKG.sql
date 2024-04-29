--------------------------------------------------------
--  DDL for Package Body OZF_PROMOTIONAL_OFFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_PROMOTIONAL_OFFERS_PKG" as
/* $Header: ozftopob.pls 120.4 2006/04/24 14:48:08 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Promotional_Offers_PKG
-- Purpose
--
-- History
--   MAY-17-2002    julou    modified. See bug 2380113
--                  removed created_by and creation_date from update api
--
-- NOTE
--
-- End of Comments
--   17-Oct-2002  RSSHARMA added last_recal_date and buyer_name
--   24-Oct-2002  RSSHARMA Added date_qualifier_profile_value
--  Tue May 03 2005:3/35 PM RSSHARMA Added sales_method_flag field
-- Wed Apr 05 2006:2/30 PM RSSHARMA Fixed bug # 5142859.Added fund_request_curr_code to insert_row
-- Mon Apr 24 2006:2/28 PM RSSHARMA Fixed bug # 5181359. Do not let in null values into budget_offer_yn column.
-- for null or g_miss values sent in put in N into the table
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Promotional_Offers_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftopob.pls';


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
          px_offer_id   IN OUT NOCOPY NUMBER,
          p_qp_list_header_id    NUMBER,
          p_offer_type    VARCHAR2,
          p_offer_code    VARCHAR2,
          p_activity_media_id    NUMBER,
          p_reusable    VARCHAR2,
          p_user_status_id    NUMBER,
          p_owner_id    NUMBER,
          p_wf_item_key    VARCHAR2,
          p_customer_reference    VARCHAR2,
          p_buying_group_contact_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_perf_date_from    DATE,
          p_perf_date_to    DATE,
          p_status_code    VARCHAR2,
          p_status_date    DATE,
          p_modifier_level_code    VARCHAR2,
          p_order_value_discount_type    VARCHAR2,
          p_offer_amount    NUMBER,
          p_lumpsum_amount    NUMBER,
          p_lumpsum_payment_type    VARCHAR2,
          p_custom_setup_id    NUMBER,
          p_security_group_id    NUMBER,
          p_budget_amount_tc     NUMBER,
          p_budget_amount_fc     NUMBER,
          p_transaction_currency_Code VARCHAR2,
          p_functional_currency_code    VARCHAR2,
          p_distribution_type       VARCHAR2,
          p_qualifier_id            NUMBER,
          p_qualifier_type          VARCHAR2,
          p_account_closed_flag      VARCHAR2,
          p_budget_offer_yn          VARCHAR2,
          p_break_type               VARCHAR2,
          p_retroactive              VARCHAR2,
          p_volume_offer_type        VARCHAR2,
          p_confidential_flag        VARCHAR2,
	  p_budget_source_type       VARCHAR2,
	  p_budget_source_id         NUMBER,
	  p_source_from_parent       VARCHAR2,
	  p_buyer_name               VARCHAR2,
	  p_last_recal_date          DATE,
	  p_date_qualifier           VARCHAR2,
          p_autopay_flag       VARCHAR2,
          p_autopay_days              NUMBER,
          p_autopay_method            VARCHAR2,
          p_autopay_party_attr        VARCHAR2,
          p_autopay_party_id     NUMBER,
	  p_tier_level               VARCHAR2,
          p_na_rule_header_id        NUMBER,
          p_beneficiary_account_id NUMBER,
          p_sales_method_flag           VARCHAR2,
          p_org_id                 NUMBER,
          p_fund_request_curr_code VARCHAR2
)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO OZF_OFFERS(
           offer_id,
           qp_list_header_id,
           offer_type,
           offer_code,
           activity_media_id,
           reusable,
           user_status_id,
           owner_id,
           wf_item_key,
           customer_reference,
           buying_group_contact_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           perf_date_from,
           perf_date_to,
           status_code,
           status_date,
           modifier_level_code,
           order_value_discount_type,
           offer_amount,
           lumpsum_amount,
           lumpsum_payment_type,
           custom_setup_id,
           budget_amount_tc,
           budget_amount_fc,
           transaction_currency_Code,
           functional_currency_code,
           distribution_type,
           qualifier_id,
           qualifier_type,
	         account_closed_flag,
           budget_offer_yn,
           break_type,
           retroactive,
           volume_offer_type,
           confidential_flag,
	   budget_source_type,
	   budget_source_id ,
	   source_from_parent,
	   buyer_name,
	   last_recal_date,
	   date_qualifier_profile_value,
           autopay_flag,
           autopay_days,
           autopay_method,
           autopay_party_attr,
           autopay_party_id,
	   tier_level,
           na_rule_header_id,
           beneficiary_account_id,
           sales_method_flag,
           org_id,
           fund_request_curr_code
	   )
     VALUES (
           DECODE( px_offer_id, FND_API.g_miss_num, NULL, px_offer_id),
           DECODE( p_qp_list_header_id, FND_API.g_miss_num, NULL, p_qp_list_header_id),
           DECODE( p_offer_type, FND_API.g_miss_char, NULL, p_offer_type),
           DECODE( p_offer_code, FND_API.g_miss_char, NULL, p_offer_code),
           DECODE( p_activity_media_id, FND_API.g_miss_num, NULL, p_activity_media_id),
           DECODE( p_reusable, FND_API.g_miss_char, NULL, p_reusable),
           DECODE( p_user_status_id, FND_API.g_miss_num, NULL, p_user_status_id),
           DECODE( p_owner_id, FND_API.g_miss_num, NULL, p_owner_id),
           DECODE( p_wf_item_key, FND_API.g_miss_char, NULL, p_wf_item_key),
           DECODE( p_customer_reference, FND_API.g_miss_char, NULL, p_customer_reference),
           DECODE( p_buying_group_contact_id, FND_API.g_miss_num, NULL, p_buying_group_contact_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, to_date(NULL), p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, to_date(NULL), p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_perf_date_from, FND_API.g_miss_date, to_date(NULL), p_perf_date_from),
           DECODE( p_perf_date_to, FND_API.g_miss_date, to_date(NULL), p_perf_date_to),
           DECODE( p_status_code, FND_API.g_miss_char, NULL, p_status_code),
           DECODE( p_status_date, FND_API.g_miss_date, to_date(NULL), p_status_date),
           DECODE( p_modifier_level_code, FND_API.g_miss_char, NULL, p_modifier_level_code),
           DECODE( p_order_value_discount_type, FND_API.g_miss_char, NULL, p_order_value_discount_type),
           DECODE( p_offer_amount, FND_API.g_miss_num, NULL, p_offer_amount),
           DECODE( p_lumpsum_amount, FND_API.g_miss_num, NULL, p_lumpsum_amount),
           DECODE( p_lumpsum_payment_Type, FND_API.g_miss_char, NULL, p_lumpsum_payment_type),
           DECODE( p_custom_setup_id, FND_API.g_miss_num, NULL, p_custom_setup_id),
           DECODE( p_budget_amount_tc, FND_API.g_miss_num, NULL, p_budget_amount_tc),
           DECODE( p_budget_amount_fc, FND_API.g_miss_num, NULL, p_budget_amount_fc),
           DECODE( p_transaction_currency_Code, FND_API.g_miss_char, NULL, p_transaction_currency_Code),
           DECODE( p_functional_currency_code, FND_API.g_miss_char, NULL, p_functional_currency_code),
           DECODE( p_distribution_type, FND_API.g_miss_char, NULL, p_distribution_type),
           DECODE( p_qualifier_id, FND_API.g_miss_num, NULL, p_qualifier_id),
           DECODE( p_qualifier_type, FND_API.g_miss_char, NULL, p_qualifier_type),
	         DECODE( p_account_closed_flag, FND_API.g_miss_char, NULL, p_account_closed_flag),
           DECODE( p_budget_offer_yn, 'Y','Y', 'N'),
           DECODE( p_break_type, FND_API.g_miss_char, NULL, p_break_type),
           DECODE( p_retroactive, FND_API.g_miss_char, NULL, p_retroactive),
           DECODE( p_volume_offer_type, FND_API.g_miss_char, NULL, p_volume_offer_type),
           DECODE( p_confidential_flag, FND_API.g_miss_char, NVL(FND_PROFILE.value('OZF_OFFR_CONFIDENTIAL_FLAG'), 'N'), NULL, NVL(FND_PROFILE.value('OZF_OFFR_CONFIDENTIAL_FLAG'), 'N'), p_confidential_flag),
	   DECODE(p_budget_source_type, FND_API.g_miss_char,NULL,p_budget_source_type),
	   DECODE(p_budget_source_id , FND_API.g_miss_num,NULL,p_budget_source_id),
	   DECODE(p_source_from_parent , FND_API.g_miss_char,NULL,p_source_from_parent),
	   DECODE(p_buyer_name , FND_API.g_miss_char,NULL,p_buyer_name),
	   DECODE(p_last_recal_date , FND_API.g_miss_date,to_date(NULL),p_last_recal_date),
	   DECODE(p_date_qualifier , FND_API.g_miss_char,NULL,p_date_qualifier),
           DECODE(p_autopay_flag , FND_API.g_miss_char,NULL,p_autopay_flag),
           DECODE(p_autopay_days , FND_API.g_miss_num,NULL,p_autopay_days),
           DECODE(p_autopay_method , FND_API.g_miss_char,NULL,p_autopay_method),
           DECODE(p_autopay_party_attr , FND_API.g_miss_char,NULL,p_autopay_party_attr),
           DECODE(p_autopay_party_id , FND_API.g_miss_num,NULL,p_autopay_party_id),
	   DECODE(p_tier_level,FND_API.g_miss_char,NULL,p_tier_level),
	   DECODE(p_na_rule_header_id,FND_API.g_miss_num,NULL,p_na_rule_header_id),
	   DECODE(p_beneficiary_account_id,FND_API.g_miss_num,NULL,p_beneficiary_account_id),
           DECODE(p_sales_method_flag,FND_API.g_miss_char,NULL,p_sales_method_flag),
           DECODE(p_org_id,FND_API.g_miss_num,NULL,p_org_id),
           DECODE(p_fund_request_curr_code, FND_API.G_MISS_CHAR,FND_PROFILE.VALUE('JTF_PROFILE_DEFAULT_CURRENCY'),null, FND_PROFILE.VALUE('JTF_PROFILE_DEFAULT_CURRENCY'),p_fund_request_curr_code)
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
          p_offer_id    NUMBER,
          p_qp_list_header_id    NUMBER,
          p_offer_type    VARCHAR2,
          p_offer_code    VARCHAR2,
          p_activity_media_id    NUMBER,
          p_reusable    VARCHAR2,
          p_user_status_id    NUMBER,
          p_owner_id    NUMBER,
          p_wf_item_key    VARCHAR2,
          p_customer_reference    VARCHAR2,
          p_buying_group_contact_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_perf_date_from    DATE,
          p_perf_date_to    DATE,
          p_status_code    VARCHAR2,
          p_status_date    DATE,
          p_modifier_level_code    VARCHAR2,
          p_order_value_discount_type    VARCHAR2,
          p_offer_amount    NUMBER,
          p_lumpsum_amount    NUMBER,
          p_lumpsum_payment_type    VARCHAR2,
          p_custom_setup_id    NUMBER,
          p_security_group_id    NUMBER,
          p_budget_amount_tc     NUMBER,
          p_budget_amount_fc     NUMBER,
          p_transaction_currency_Code VARCHAR2,
          p_functional_currency_code    VARCHAR2,
          p_distribution_type       VARCHAR2,
          p_qualifier_id            NUMBER,
          p_qualifier_type          VARCHAR2,
          p_account_closed_flag      VARCHAR2,
          p_budget_offer_yn          VARCHAR2,
          p_break_type               VARCHAR2,
          p_retroactive              VARCHAR2,
          p_volume_offer_type        VARCHAR2,
          p_confidential_flag        VARCHAR2,
	  p_budget_source_type       VARCHAR2,
	  p_budget_source_id         NUMBER,
	  p_source_from_parent      VARCHAR2,
	  p_buyer_name              VARCHAR2,
	  p_last_recal_date              DATE,
	  p_date_qualifier          VARCHAR2,
          p_autopay_flag       VARCHAR2,
          p_autopay_days              NUMBER,
          p_autopay_method            VARCHAR2,
          p_autopay_party_attr        VARCHAR2,
          p_autopay_party_id     NUMBER,
	  p_tier_level              VARCHAR2,
          p_na_rule_header_id       NUMBER,
          p_beneficiary_account_id NUMBER,
          p_sales_method_flag           VARCHAR2,
          p_org_id                 NUMBER,
          p_start_date             DATE
)

 IS
 BEGIN

    Update OZF_OFFERS
    SET
              offer_id = DECODE( p_offer_id, FND_API.g_miss_num, offer_id, p_offer_id),
              qp_list_header_id = DECODE( p_qp_list_header_id, FND_API.g_miss_num, qp_list_header_id, p_qp_list_header_id),
              offer_type = DECODE( p_offer_type, FND_API.g_miss_char, offer_type, p_offer_type),
              offer_code = DECODE( p_offer_code, FND_API.g_miss_char, offer_code, p_offer_code),
              activity_media_id = DECODE( p_activity_media_id, FND_API.g_miss_num, activity_media_id, p_activity_media_id),
              reusable = DECODE( p_reusable, FND_API.g_miss_char, reusable, p_reusable),
              user_status_id = DECODE( p_user_status_id, FND_API.g_miss_num, user_status_id, p_user_status_id),
              owner_id = DECODE( p_owner_id, FND_API.g_miss_num, owner_id, p_owner_id),
              wf_item_key = DECODE( p_wf_item_key, FND_API.g_miss_char, wf_item_key, p_wf_item_key),
              customer_reference = DECODE( p_customer_reference, FND_API.g_miss_char, customer_reference, p_customer_reference),
              buying_group_contact_id = DECODE( p_buying_group_contact_id, FND_API.g_miss_num, buying_group_contact_id, p_buying_group_contact_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number +1, p_object_version_number+1),
              perf_date_from = DECODE( p_perf_date_from, FND_API.g_miss_date, perf_date_from, p_perf_date_from),
              perf_date_to = DECODE( p_perf_date_to, FND_API.g_miss_date, perf_date_to, p_perf_date_to),
              status_code = DECODE( p_status_code, FND_API.g_miss_char, status_code, p_status_code),
              status_date = DECODE( p_status_date, FND_API.g_miss_date, status_date, p_status_date),
              modifier_level_code = DECODE( p_modifier_level_code, FND_API.g_miss_char, modifier_level_code, p_modifier_level_code),
              order_value_discount_type = DECODE( p_order_value_discount_type, FND_API.g_miss_char, order_value_discount_type, p_order_value_discount_type),
              offer_amount = DECODE( p_offer_amount, FND_API.g_miss_num, offer_amount, p_offer_amount),
              lumpsum_amount = DECODE( p_lumpsum_amount, FND_API.g_miss_num, lumpsum_amount, p_lumpsum_amount),
              lumpsum_payment_type = DECODE( p_lumpsum_payment_type, FND_API.g_miss_char, lumpsum_payment_type, p_lumpsum_payment_type),
              custom_setup_id = DECODE( p_custom_setup_id, FND_API.g_miss_num, custom_setup_id, p_custom_setup_id),
              budget_amount_tc = DECODE( p_budget_amount_tc, FND_API.g_miss_num, budget_amount_tc, p_budget_amount_tc),
              budget_amount_fc = DECODE( p_budget_amount_fc, FND_API.g_miss_num, budget_amount_fc, p_budget_amount_fc),
              transaction_currency_Code = DECODE( p_transaction_currency_Code, FND_API.g_miss_char, transaction_currency_Code, p_transaction_currency_Code),
              functional_currency_code = DECODE( p_functional_currency_code, FND_API.g_miss_char, functional_currency_code, p_functional_currency_code),
              distribution_type = DECODE( p_distribution_type, FND_API.g_miss_char, distribution_type, p_distribution_type),
              qualifier_id = DECODE( p_qualifier_id, FND_API.g_miss_num, qualifier_id, p_qualifier_id),
              qualifier_type = DECODE( p_qualifier_type, FND_API.g_miss_char, qualifier_type, p_qualifier_type),
              account_closed_flag = DECODE( p_account_closed_flag, FND_API.g_miss_char, account_closed_flag, p_account_closed_flag),
              budget_offer_yn = DECODE( p_budget_offer_yn,'Y','Y', FND_API.g_miss_char, budget_offer_yn, 'N'),
              break_type = DECODE( p_break_type, FND_API.g_miss_char, break_type, p_break_type),
              retroactive = DECODE( p_retroactive, FND_API.g_miss_char, retroactive, p_retroactive),
              volume_offer_type = DECODE( p_volume_offer_type, FND_API.g_miss_char, volume_offer_type, p_volume_offer_type),
              confidential_flag = DECODE( p_confidential_flag, FND_API.g_miss_char, confidential_flag, NULL, NVL(FND_PROFILE.value('OZF_OFFR_CONFIDENTIAL_FLAG'), 'N'), p_confidential_flag),
	      budget_source_type = DECODE(p_budget_source_type,FND_API.g_miss_char,budget_source_type,p_budget_source_type),
	      budget_source_id = DECODE(p_budget_source_id , FND_API.g_miss_num,budget_source_id,p_budget_source_id),
	      source_from_parent = DECODE(p_source_from_parent , FND_API.g_miss_char,source_from_parent,p_source_from_parent),
	      buyer_name = DECODE(p_buyer_name , FND_API.g_miss_char,buyer_name,p_buyer_name),
              last_recal_date = DECODE(p_last_recal_date , FND_API.g_miss_date,last_recal_date,p_last_recal_date),
              date_qualifier_profile_value = DECODE(p_date_qualifier , FND_API.g_miss_char, date_qualifier_profile_value, p_date_qualifier),
              autopay_flag = DECODE(p_autopay_flag , FND_API.g_miss_char,autopay_flag,p_autopay_flag),
              autopay_days = DECODE(p_autopay_days , FND_API.g_miss_num,autopay_days,p_autopay_days),
              autopay_method = DECODE(p_autopay_method , FND_API.g_miss_char,autopay_method,p_autopay_method),
              autopay_party_attr = DECODE(p_autopay_party_attr , FND_API.g_miss_char,autopay_party_attr,p_autopay_party_attr),
              autopay_party_id = DECODE(p_autopay_party_id , FND_API.g_miss_num,autopay_party_id,p_autopay_party_id),
	      tier_level = DECODE(p_tier_level , FND_API.g_miss_char , tier_level,p_tier_level),
              na_rule_header_id = DECODE(p_na_rule_header_id , FND_API.g_miss_num , na_rule_header_id,p_na_rule_header_id),
              beneficiary_account_id = DECODE(p_beneficiary_account_id , FND_API.g_miss_num , beneficiary_account_id,p_beneficiary_account_id),
              sales_method_flag = DECODE(p_sales_method_flag , FND_API.g_miss_char , sales_method_flag,p_sales_method_flag),
              org_id = DECODE(p_org_id , FND_API.g_miss_char , org_id,p_org_id),
              start_date = DECODE( p_start_date, FND_API.g_miss_date, start_date, p_start_date)


   WHERE OFFER_ID = p_OFFER_ID
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
    p_OFFER_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM OZF_OFFERS
    WHERE OFFER_ID = p_OFFER_ID;
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
          p_offer_id    NUMBER,
          p_qp_list_header_id    NUMBER,
          p_offer_type    VARCHAR2,
          p_offer_code    VARCHAR2,
          p_activity_media_id    NUMBER,
          p_reusable    VARCHAR2,
          p_user_status_id    NUMBER,
          p_owner_id    NUMBER,
          p_wf_item_key    VARCHAR2,
          p_customer_reference    VARCHAR2,
          p_buying_group_contact_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_perf_date_from    DATE,
          p_perf_date_to    DATE,
          p_status_code    VARCHAR2,
          p_status_date    DATE,
          p_modifier_level_code    VARCHAR2,
          p_order_value_discount_type    VARCHAR2,
          p_offer_amount    NUMBER,
          p_lumpsum_amount    NUMBER,
          p_lumpsum_payment_type    VARCHAR2,
          p_custom_setup_id    NUMBER,
          p_security_group_id    NUMBER,
          p_budget_amount_tc     NUMBER,
          p_budget_amount_fc     NUMBER,
          p_transaction_currency_Code VARCHAR2,
          p_functional_currency_code    VARCHAR2,
          p_distribution_type       VARCHAR2,
          p_qualifier_id            NUMBER,
          p_qualifier_type          VARCHAR2,
          p_account_closed_flag      VARCHAR2,
          p_budget_offer_yn          VARCHAR2,
          p_break_type               VARCHAR2,
          p_retroactive              VARCHAR2,
          p_volume_offer_type        VARCHAR2,
          p_confidential_flag        VARCHAR2,
	  p_source_from_parent       VARCHAR2,
	  p_buyer_name               VARCHAR2,
	  p_last_recal_date          DATE,
          p_autopay_flag       VARCHAR2,
          p_autopay_days              NUMBER,
          p_autopay_method            VARCHAR2,
          p_autopay_party_attr        VARCHAR2,
          p_autopay_party_id     NUMBER,
	  p_tier_level               VARCHAR2,
          p_na_rule_header_id        NUMBER,
          p_beneficiary_account_id NUMBER,
          p_sales_method_flag   VARCHAR2,
          p_org_id                 NUMBER
          )

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_OFFERS
        WHERE OFFER_ID =  p_OFFER_ID
        FOR UPDATE of OFFER_ID NOWAIT;
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
           (      Recinfo.offer_id = p_offer_id)
       AND (    ( Recinfo.qp_list_header_id = p_qp_list_header_id)
            OR (    ( Recinfo.qp_list_header_id IS NULL )
                AND (  p_qp_list_header_id IS NULL )))
       AND (    ( Recinfo.offer_type = p_offer_type)
            OR (    ( Recinfo.offer_type IS NULL )
                AND (  p_offer_type IS NULL )))
       AND (    ( Recinfo.offer_code = p_offer_code)
            OR (    ( Recinfo.offer_code IS NULL )
                AND (  p_offer_code IS NULL )))
       AND (    ( Recinfo.activity_media_id = p_activity_media_id)
            OR (    ( Recinfo.activity_media_id IS NULL )
                AND (  p_activity_media_id IS NULL )))
       AND (    ( Recinfo.reusable = p_reusable)
            OR (    ( Recinfo.reusable IS NULL )
                AND (  p_reusable IS NULL )))
       AND (    ( Recinfo.user_status_id = p_user_status_id)
            OR (    ( Recinfo.user_status_id IS NULL )
                AND (  p_user_status_id IS NULL )))
       AND (    ( Recinfo.owner_id = p_owner_id)
            OR (    ( Recinfo.owner_id IS NULL )
                AND (  p_owner_id IS NULL )))
       AND (    ( Recinfo.wf_item_key = p_wf_item_key)
            OR (    ( Recinfo.wf_item_key IS NULL )
                AND (  p_wf_item_key IS NULL )))
       AND (    ( Recinfo.customer_reference = p_customer_reference)
            OR (    ( Recinfo.customer_reference IS NULL )
                AND (  p_customer_reference IS NULL )))
       AND (    ( Recinfo.buying_group_contact_id = p_buying_group_contact_id)
            OR (    ( Recinfo.buying_group_contact_id IS NULL )
                AND (  p_buying_group_contact_id IS NULL )))
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
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.perf_date_from = p_perf_date_from)
            OR (    ( Recinfo.perf_date_from IS NULL )
                AND (  p_perf_date_from IS NULL )))
       AND (    ( Recinfo.perf_date_to = p_perf_date_to)
            OR (    ( Recinfo.perf_date_to IS NULL )
                AND (  p_perf_date_to IS NULL )))
       AND (    ( Recinfo.status_code = p_status_code)
            OR (    ( Recinfo.status_code IS NULL )
                AND (  p_status_code IS NULL )))
       AND (    ( Recinfo.status_date = p_status_date)
            OR (    ( Recinfo.status_date IS NULL )
                AND (  p_status_date IS NULL )))
       AND (    ( Recinfo.modifier_level_code = p_modifier_level_code)
            OR (    ( Recinfo.modifier_level_code IS NULL )
                AND (  p_modifier_level_code IS NULL )))
       AND (    ( Recinfo.order_value_discount_type = p_order_value_discount_type)
            OR (    ( Recinfo.order_value_discount_type IS NULL )
                AND (  p_order_value_discount_type IS NULL )))
       AND (    ( Recinfo.offer_amount = p_offer_amount)
            OR (    ( Recinfo.offer_amount IS NULL )
                AND (  p_offer_amount IS NULL )))
       AND (    ( Recinfo.lumpsum_amount = p_lumpsum_amount)
            OR (    ( Recinfo.lumpsum_amount IS NULL )
                AND (  p_lumpsum_amount IS NULL )))
       AND (    ( Recinfo.lumpsum_payment_type = p_lumpsum_payment_type)
            OR (    ( Recinfo.lumpsum_payment_type IS NULL )
                AND (  p_lumpsum_payment_type IS NULL )))
       AND (    ( Recinfo.custom_setup_id = p_custom_setup_id)
            OR (    ( Recinfo.custom_setup_id IS NULL )
                AND (  p_custom_setup_id IS NULL )))
       AND (    ( Recinfo.security_group_id = p_security_group_id)
            OR (    ( Recinfo.security_group_id IS NULL )
                AND (  p_security_group_id IS NULL )))
       AND (    ( Recinfo.budget_amount_tc = p_budget_amount_tc)
            OR (    ( Recinfo.budget_amount_tc IS NULL )
                AND (  p_budget_amount_tc IS NULL )))
       AND (    ( Recinfo.budget_amount_fc = p_budget_amount_fc)
            OR (    ( Recinfo.budget_amount_fc IS NULL )
                AND (  p_budget_amount_tc IS NULL )))
       AND (    ( Recinfo.transaction_currency_Code = p_transaction_currency_Code)
            OR (    ( Recinfo.transaction_currency_Code IS NULL )
                AND (  p_transaction_currency_Code IS NULL )))
       AND (    ( Recinfo.functional_currency_code = p_functional_currency_code)
            OR (    ( Recinfo.functional_currency_code IS NULL )
                AND (  p_functional_currency_code IS NULL )))
       AND (    ( Recinfo.distribution_type = p_distribution_type)
            OR (    ( Recinfo.distribution_type IS NULL )
                AND (  p_distribution_type IS NULL )))
       AND (    ( Recinfo.qualifier_type = p_qualifier_type)
            OR (    ( Recinfo.qualifier_type IS NULL )
                AND (  p_qualifier_type IS NULL )))
       AND (    ( Recinfo.qualifier_id = p_qualifier_id)
            OR (    ( Recinfo.qualifier_id IS NULL )
                AND (  p_qualifier_id IS NULL )))
       AND (    ( Recinfo.account_closed_flag = p_account_closed_flag)
            OR (    ( Recinfo.account_closed_flag IS NULL )
                AND (  p_account_closed_flag IS NULL )))
       AND (    ( Recinfo.budget_offer_yn = p_budget_offer_yn)
            OR (    ( Recinfo.budget_offer_yn IS NULL )
                AND (  p_budget_offer_yn IS NULL )))
       AND (    ( Recinfo.break_type = p_break_type)
            OR (    ( Recinfo.break_type IS NULL )
                AND (  p_break_type IS NULL )))
       AND (    ( Recinfo.retroactive = p_retroactive)
            OR (    ( Recinfo.retroactive IS NULL )
                AND (  p_retroactive IS NULL )))
       AND (    ( Recinfo.volume_offer_type = p_volume_offer_type)
            OR (    ( Recinfo.volume_offer_type IS NULL )
                AND (  p_volume_offer_type IS NULL )))
       AND (    ( Recinfo.confidential_flag = p_confidential_flag)
            OR (    ( Recinfo.confidential_flag IS NULL )
                AND (  p_confidential_flag IS NULL )))
       AND (    ( Recinfo.source_from_parent = p_source_from_parent)
            OR (    ( Recinfo.source_from_parent IS NULL )
                AND (  p_source_from_parent IS NULL )))
       AND (    ( Recinfo.buyer_name = p_buyer_name)
            OR (    ( Recinfo.buyer_name IS NULL )
                AND (  p_buyer_name IS NULL )))
       AND (    ( Recinfo.last_recal_date = p_last_recal_date)
            OR (    ( Recinfo.last_recal_date IS NULL )
                AND (  p_last_recal_date IS NULL )))
       AND (    ( Recinfo.autopay_flag = p_autopay_flag)
            OR (    ( Recinfo.autopay_flag IS NULL )
                AND (  p_autopay_flag IS NULL )))
       AND (    ( Recinfo.autopay_days = p_autopay_days)
            OR (    ( Recinfo.autopay_days IS NULL )
                AND (  p_autopay_days IS NULL )))
       AND (    ( Recinfo.autopay_method = p_autopay_method)
            OR (    ( Recinfo.autopay_method IS NULL )
                AND (  p_autopay_method IS NULL )))
       AND (    ( Recinfo.autopay_party_attr = p_autopay_party_attr)
            OR (    ( Recinfo.autopay_party_attr IS NULL )
                AND (  p_autopay_party_attr IS NULL )))
       AND (    ( Recinfo.autopay_party_id = p_autopay_party_id)
            OR (    ( Recinfo.autopay_party_id IS NULL )
                AND (  p_autopay_party_id IS NULL )))
       AND (    ( Recinfo.tier_level = p_tier_level)
            OR (    ( Recinfo.tier_level IS NULL )
                AND (  p_tier_level IS NULL )))
       AND (    ( Recinfo.na_rule_header_id = p_na_rule_header_id)
            OR (    ( Recinfo.na_rule_header_id IS NULL )
                AND (  p_na_rule_header_id IS NULL )))
       AND (    ( Recinfo.beneficiary_account_id = p_beneficiary_account_id)
            OR (    ( Recinfo.beneficiary_account_id IS NULL )
                AND (  p_beneficiary_account_id IS NULL )))
       AND (    ( Recinfo.sales_method_flag = p_sales_method_flag)
            OR (    ( Recinfo.sales_method_flag IS NULL )
                AND (  p_sales_method_flag IS NULL )))
       AND (    ( Recinfo.org_id = p_org_id)
            OR (    ( Recinfo.org_id IS NULL )
                AND (  p_org_id IS NULL )))
       )THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END OZF_Promotional_Offers_PKG;

/
