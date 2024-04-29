--------------------------------------------------------
--  DDL for Package OZF_PROMOTIONAL_OFFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_PROMOTIONAL_OFFERS_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftopos.pls 120.3 2006/04/05 14:47:38 rssharma noship $ */
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
--   17-Oct-2002  RSSHARMA added last_recal_date and buyer_name
--   24-Oct-2002  RSSHARMA Added date_qualifier_profile_value
-- Wed Apr 05 2006:2/29 PM RSSHARMA Fixed bug # 5142859.Added fund_request_curr_code to insert_row
--  Tue May 03 2005:3/35 PM RSSHARMA Added sales_method_flag field
-- End of Comments
-- ===============================================================

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
	  );

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
          p_sales_method_flag            VARCHAR2,
          p_org_id                 NUMBER,
          p_start_date             DATE
	  );

PROCEDURE Delete_Row(
    p_OFFER_ID  NUMBER);
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
          p_sales_method_flag VARCHAR2,
          p_org_id                 NUMBER
	  );

END OZF_Promotional_Offers_PKG;

 

/
