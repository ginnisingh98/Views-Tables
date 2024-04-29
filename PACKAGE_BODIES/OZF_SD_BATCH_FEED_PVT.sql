--------------------------------------------------------
--  DDL for Package Body OZF_SD_BATCH_FEED_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SD_BATCH_FEED_PVT" as
/* $Header: ozfvsdfb.pls 120.21.12010000.37 2009/12/23 11:10:04 annsrini ship $ */

-- Start of Comments
-- Package name     : OZF_SD_BATCH_FEED_PVT
-- Purpose          :
-- History          :
--                  : 30-JUN-2009 - Annsrini - If claim process is unsuccessful, then update batch header status as PENDING_CLAIM
--                  : 20-JUL-2009 - Annsrini - Adjustment related changes
--                  : 27-AUG-2009 - JMAHENDR - change of dispute code for
--                                             invalid / missing response as
--                                             OZF_SD_NO_RESPONSE
--                  : 27-AUG-2009 - JMAHENDR - removed nvl on
--                                             vendor_auth_quantity with shipped quantity
--                  : 07-DEC-2009 - ANNSRINI - changes w.r.t multicurrency
-- NOTE             :
-- End of Comments

  g_pkg_name constant VARCHAR2(30) := 'OZF_SD_BATCH_FEED_PVT';
  g_file_name constant VARCHAR2(12) := 'ozfvsdfb.pls';

  -- Author  : MBHATT
  -- Created : 11/16/2007 2:39:16 PM
  -- Purpose :
  -- Public function and procedure declarations
  -- Private type declarations
 PROCEDURE update_stale_data_batch_line(p_batch_number      IN VARCHAR2,
                                        p_batch_line_number IN VARCHAR2) AS

  BEGIN
    ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_stale_data_batch_line', 'Procedure Starts');

     UPDATE ozf_sd_batch_lines_int_all
        SET processed_flag = 'S',
	    last_update_date      = sysdate,
            last_updated_by       = fnd_global.user_id
      WHERE ship_frm_sd_claim_request_id = p_batch_number
        AND batch_line_number = p_batch_line_number
	AND processed_flag = 'N';

    ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_stale_data_batch_line', 'Procedure Ends');

  EXCEPTION
    WHEN others THEN
      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_stale_data_batch_line', 'Exception: '||sqlerrm);

  END update_stale_data_batch_line;

  PROCEDURE populate_interface(p_batch_number               IN VARCHAR2,
                               p_operating_unit             IN VARCHAR2,
                               p_frm_cntct1_name            IN VARCHAR2,
                               p_frm_cntct1_email           IN VARCHAR2,
                               p_frm_cntct1_fax             IN VARCHAR2,
                               p_frm_cntct1_phone           IN VARCHAR2,
                               p_frm_gbl_ptnr_role_class_cd IN VARCHAR2,
                               p_frm_gbl_business_id        IN VARCHAR2,
                               p_frm_gbl_supply_chain_cd    IN VARCHAR2,
                               p_frm_business_name          IN VARCHAR2,
                               p_frm_prop_business_id1      IN VARCHAR2,
                               p_frm_prop_domain_id1        IN VARCHAR2,
                               p_frm_auth_id1               IN VARCHAR2,
                               p_frm_gbl_ptnr_class_cd      IN VARCHAR2,
                               p_frm_cntct2_name            IN VARCHAR2,
                               p_frm_cntct2_email           IN VARCHAR2,
                               p_frm_cntct2_fax             IN VARCHAR2,
                               p_frm_cntct2_phone           IN VARCHAR2,
                               p_frm_gbl_loc_id             IN VARCHAR2,
                               p_frm_prop_domain_id2        IN VARCHAR2,
                               p_frm_prop_auth_id2          IN VARCHAR2,
                               p_frm_prop_loc_id            IN VARCHAR2,
                               p_frm_add_line1              IN VARCHAR2,
                               p_frm_add_line2              IN VARCHAR2,
                               p_frm_add_line3              IN VARCHAR2,
                               p_frm_city                   IN VARCHAR2,
                               p_frm_country                IN VARCHAR2,
                               p_frm_postal_code            IN VARCHAR2,
                               p_frm_po_box_id              IN VARCHAR2,
                               p_frm_region                 IN VARCHAR2,
                               p_gbl_doc_func_code          IN VARCHAR2,
                               p_ship_from_sd_auth_id       IN VARCHAR2,
                               p_dist_by_gbl_business_id    IN VARCHAR2,
                               p_dist_by_gbl_supp_chain_cd  IN VARCHAR2,
                               p_dist_by_business_name      IN VARCHAR2,
                               p_dist_by_prop_business_id   IN VARCHAR2,
                               p_dist_by_prop_domain_id1    IN VARCHAR2,
                               p_dist_by_prop_auth_id1      IN VARCHAR2,
                               p_dist_by_gbl_ptnr_class_cd  IN VARCHAR2,
                               p_dist_by_cntct_name         IN VARCHAR2,
                               p_dist_by_cntct_email        IN VARCHAR2,
                               p_dist_by_cntct_fax          IN VARCHAR2,
                               p_dist_by_cntct_phone        IN VARCHAR2,
                               p_dist_by_gbl_loc_id         IN VARCHAR2,
                               p_dist_by_prop_domain_id2    IN VARCHAR2,
                               p_dist_by_prop_auth_id2      IN VARCHAR2,
                               p_dist_by_prop_loc_id        IN VARCHAR2,
                               p_dist_by_add_line1          IN VARCHAR2,
                               p_dist_by_add_line2          IN VARCHAR2,
                               p_dist_by_add_line3          IN VARCHAR2,
                               p_dist_by_city               IN VARCHAR2,
                               p_dist_by_country            IN VARCHAR2,
                               p_dist_by_postal_code        IN VARCHAR2,
                               p_dist_by_po_box_id          IN VARCHAR2,
                               p_dist_by_region             IN VARCHAR2,
                               p_ship_to_business_name      IN VARCHAR2,
                               p_ship_to_gbl_business_id    IN VARCHAR2,
                               p_ship_to_gbl_supp_chain_cd  IN VARCHAR2,
                               p_ship_to_prop_business_id   IN VARCHAR2,
                               p_ship_to_prop_domain_id1    IN VARCHAR2,
                               p_ship_to_prop_auth_id1      IN VARCHAR2,
                               p_ship_to_gbl_ptnr_class_cd  IN VARCHAR2,
                               p_ship_to_cust_cntct_name    IN VARCHAR2,
                               p_ship_to_cust_cntct_email   IN VARCHAR2,
                               p_ship_to_cust_cntct_fax     IN VARCHAR2,
                               p_ship_to_cust_cntct_phone   IN VARCHAR2,
                               p_ship_to_cust_gbl_loc_id    IN VARCHAR2,
                               p_ship_to_prop_domain_id2    IN VARCHAR2,
                               p_ship_to_prop_auth_id2      IN VARCHAR2,
                               p_ship_to_cust_prop_loc_id   IN VARCHAR2,
                               p_ship_to_cust_add1          IN VARCHAR2,
                               p_ship_to_cust_add2          IN VARCHAR2,
                               p_ship_to_cust_add3          IN VARCHAR2,
                               p_ship_to_cust_city          IN VARCHAR2,
                               p_ship_to_cust_country       IN VARCHAR2,
                               p_ship_to_cust_postal_code   IN VARCHAR2,
                               p_ship_to_cust_po_box_id     IN VARCHAR2,
                               p_ship_to_cust_region        IN VARCHAR2,
                               p_sold_to_business_name      IN VARCHAR2,
                               p_sold_to_gbl_business_id    IN VARCHAR2,
                               p_sold_to_gbl_supp_chain_cd  IN VARCHAR2,
                               p_sold_to_prop_business_id   IN VARCHAR2,
                               p_sold_to_prop_domain_id1    IN VARCHAR2,
                               p_sold_to_prop_auth_id1      IN VARCHAR2,
                               p_sold_to_gbl_ptnr_class_cd  IN VARCHAR2,
                               p_sold_to_cust_cntct_name    IN VARCHAR2,
                               p_sold_to_cust_cntct_email   IN VARCHAR2,
                               p_sold_to_cust_cntct_fax     IN VARCHAR2,
                               p_sold_to_cust_cntct_phone   IN VARCHAR2,
                               p_sold_to_cust_gbl_loc_id    IN VARCHAR2,
                               p_sold_to_prop_domain_id2    IN VARCHAR2,
                               p_sold_to_prop_auth_id2      IN VARCHAR2,
                               p_sold_to_cust_prop_loc_id   IN VARCHAR2,
                               p_sold_to_cust_add1          IN VARCHAR2,
                               p_sold_to_cust_add2          IN VARCHAR2,
                               p_sold_to_cust_add3          IN VARCHAR2,
                               p_sold_to_cust_city          IN VARCHAR2,
                               p_sold_to_cust_country       IN VARCHAR2,
                               p_sold_to_cust_postal_code   IN VARCHAR2,
                               p_sold_to_cust_po_box_id     IN VARCHAR2,
                               p_sold_to_cust_region        IN VARCHAR2,
                               p_end_cust_business_name     IN VARCHAR2,
                               p_end_cust_gbl_business_id   IN VARCHAR2,
                               p_end_cust_gbl_supp_chain_cd IN VARCHAR2,
                               p_end_cust_prop_business_id  IN VARCHAR2,
                               p_end_cust_prop_domain_id1   IN VARCHAR2,
                               p_end_cust_prop_auth_id1     IN VARCHAR2,
                               p_end_cust_gbl_ptnr_class_cd IN VARCHAR2,
                               p_end_cust_cntct_name        IN VARCHAR2,
                               p_end_cust_cntct_email       IN VARCHAR2,
                               p_end_cust_cntct_fax         IN VARCHAR2,
                               p_end_cust_cntct_phone       IN VARCHAR2,
                               p_end_cust_gbl_loc_id        IN VARCHAR2,
                               p_end_cust_prop_domain_id2   IN VARCHAR2,
                               p_end_cust_prop_auth_id2     IN VARCHAR2,
                               p_end_cust_prop_loc_id       IN VARCHAR2,
                               p_end_cust_add1              IN VARCHAR2,
                               p_end_cust_add2              IN VARCHAR2,
                               p_end_cust_add3              IN VARCHAR2,
                               p_end_cust_city              IN VARCHAR2,
                               p_end_cust_country           IN VARCHAR2,
                               p_end_cust_postal_code       IN VARCHAR2,
                               p_end_cust_po_box_id         IN VARCHAR2,
                               p_end_cust_region            IN VARCHAR2,
                               p_ship_frm_sd_claim_req_date IN DATE,
                               p_ship_frm_sd_claim_req_id   IN VARCHAR2,
                               p_credit_ref_id              IN VARCHAR2,
                               p_debit_ref_id               IN VARCHAR2,
                               p_batch_line_id              IN NUMBER,
                               p_batch_line_number          IN NUMBER,
                               p_order_date                 IN DATE,
                               p_order_line_number          IN NUMBER,
                               p_order_number               IN NUMBER,
                               p_invoice_date               IN DATE,
                               p_invoice_line_number        IN NUMBER,
                               p_invoice_number             IN VARCHAR2,
			       p_discount_type              IN VARCHAR2,
			       p_discount_value             IN NUMBER,
		               p_discount_currency          IN VARCHAR2,
                               p_cost_price                 IN NUMBER,
                               p_cost_price_curr_code       IN VARCHAR2,
                               p_auth_price                 IN NUMBER,
                               p_auth_price_curr_code       IN VARCHAR2,
                               p_resale_price               IN NUMBER,
                               p_resale_price_curr_code     IN VARCHAR2,
                               p_uom                        IN VARCHAR2,
                               p_line_status                IN VARCHAR2,
                               p_disposition_code1          IN VARCHAR2,
                               p_disposition_code2          IN VARCHAR2,
                               p_disposition_code3          IN VARCHAR2,
                               p_disposition_code4          IN VARCHAR2,
                               p_disposition_code5          IN VARCHAR2,
                               p_disposition_code6          IN VARCHAR2,
                               p_disposition_code7          IN VARCHAR2,
                               p_disposition_code8          IN VARCHAR2,
                               p_disposition_code9          IN VARCHAR2,
                               p_disposition_code10         IN VARCHAR2,
                               p_vendor_part_number         IN VARCHAR2,
                               p_dist_part_number           IN VARCHAR2,
                               p_date_shipped               IN DATE,
                               p_qty_shipped                IN NUMBER,
                               p_claim_amt_curr_code        IN VARCHAR2,
                               p_last_sub_claim_amt         IN NUMBER,
                               p_vendor_auth_line_item_no   IN VARCHAR2,
                               p_vendor_apprvd_amt          IN NUMBER,
                               p_vendor_apprvd_amt_curr_cd  IN VARCHAR2,
			       p_vendor_apprvd_qty          IN NUMBER,
                               p_batch_submission_date      IN DATE,
                               p_batch_id                   IN NUMBER,
                               p_to_cntct1_name             IN VARCHAR2,
                               p_to_cntct1_email            IN VARCHAR2,
                               p_to_cntct1_fax              IN VARCHAR2,
                               p_to_cntct1_phone            IN VARCHAR2,
                               p_to_gbl_ptnr_role_class_cd  IN VARCHAR2,
                               p_to_gbl_business_id         IN VARCHAR2,
                               p_to_gbl_supply_chain_cd     IN VARCHAR2,
                               p_to_business_name           IN VARCHAR2,
                               p_to_prop_business_id1       IN VARCHAR2,
                               p_to_prop_domain_id1         IN VARCHAR2,
                               p_to_auth_id1                IN VARCHAR2,
                               p_to_gbl_ptnr_class_cd       IN VARCHAR2,
                               p_to_cntct2_name             IN VARCHAR2,
                               p_to_cntct2_email            IN VARCHAR2,
                               p_to_cntct2_fax              IN VARCHAR2,
                               p_to_cntct2_phone            IN VARCHAR2,
                               p_to_gbl_loc_id              IN VARCHAR2,
                               p_to_prop_domain_id2         IN VARCHAR2,
                               p_to_prop_auth_id2           IN VARCHAR2,
                               p_to_prop_loc_id             IN VARCHAR2,
                               p_to_add_line1               IN VARCHAR2,
                               p_to_add_line2               IN VARCHAR2,
                               p_to_add_line3               IN VARCHAR2,
                               p_to_city                    IN VARCHAR2,
                               p_to_country                 IN VARCHAR2,
                               p_to_postal_code             IN VARCHAR2,
                               p_to_po_box_id               IN VARCHAR2,
                               p_to_region                  IN VARCHAR2,
			       P_HDR_ATTR_CATG              IN VARCHAR2,
	 		       P_HDR_ATTR1                  IN VARCHAR2,
			       P_HDR_ATTR2                  IN VARCHAR2,
			       P_HDR_ATTR3                  IN VARCHAR2,
		               P_HDR_ATTR4                  IN VARCHAR2,
		               P_HDR_ATTR5                  IN VARCHAR2,
		               P_HDR_ATTR6                  IN VARCHAR2,
		               P_HDR_ATTR7                  IN VARCHAR2,
		               P_HDR_ATTR8                  IN VARCHAR2,
		               P_HDR_ATTR9                  IN VARCHAR2,
		               P_HDR_ATTR10                 IN VARCHAR2,
		               P_HDR_ATTR11                 IN VARCHAR2,
		               P_HDR_ATTR12                 IN VARCHAR2,
		               P_HDR_ATTR13                 IN VARCHAR2,
		               P_HDR_ATTR14                 IN VARCHAR2,
		               P_HDR_ATTR15                 IN VARCHAR2,
			       P_HDR_ATTR16                 IN VARCHAR2,
			       P_HDR_ATTR17                 IN VARCHAR2,
			       P_HDR_ATTR18                 IN VARCHAR2,
			       P_HDR_ATTR19                 IN VARCHAR2,
			       P_HDR_ATTR20                 IN VARCHAR2,
			       P_HDR_ATTR21                 IN VARCHAR2,
			       P_HDR_ATTR22                 IN VARCHAR2,
			       P_HDR_ATTR23                 IN VARCHAR2,
			       P_HDR_ATTR24                 IN VARCHAR2,
			       P_HDR_ATTR25                 IN VARCHAR2,
			       P_HDR_ATTR26                 IN VARCHAR2,
			       P_HDR_ATTR27                 IN VARCHAR2,
			       P_HDR_ATTR28                 IN VARCHAR2,
			       P_HDR_ATTR29                 IN VARCHAR2,
			       P_HDR_ATTR30                 IN VARCHAR2,
		               P_LINE_ATTR_CATG             IN VARCHAR2,
		               P_LINE_ATTR1                 IN VARCHAR2,
		               P_LINE_ATTR2                 IN VARCHAR2,
		               P_LINE_ATTR3                 IN VARCHAR2,
		               P_LINE_ATTR4                 IN VARCHAR2,
		               P_LINE_ATTR5                 IN VARCHAR2,
		               P_LINE_ATTR6                 IN VARCHAR2,
		               P_LINE_ATTR7                 IN VARCHAR2,
		               P_LINE_ATTR8                 IN VARCHAR2,
		               P_LINE_ATTR9                 IN VARCHAR2,
		               P_LINE_ATTR10                IN VARCHAR2,
		               P_LINE_ATTR11                IN VARCHAR2,
		               P_LINE_ATTR12                IN VARCHAR2,
		               P_LINE_ATTR13                IN VARCHAR2,
		               P_LINE_ATTR14                IN VARCHAR2,
		               P_LINE_ATTR15                IN VARCHAR2,
			       P_LINE_ATTR16                IN VARCHAR2,
			       P_LINE_ATTR17                IN VARCHAR2,
			       P_LINE_ATTR18                IN VARCHAR2,
			       P_LINE_ATTR19                IN VARCHAR2,
			       P_LINE_ATTR20                IN VARCHAR2,
			       P_LINE_ATTR21                IN VARCHAR2,
			       P_LINE_ATTR22                IN VARCHAR2,
			       P_LINE_ATTR23                IN VARCHAR2,
			       P_LINE_ATTR24                IN VARCHAR2,
			       P_LINE_ATTR25                IN VARCHAR2,
			       P_LINE_ATTR26                IN VARCHAR2,
			       P_LINE_ATTR27                IN VARCHAR2,
			       P_LINE_ATTR28                IN VARCHAR2,
			       P_LINE_ATTR29                IN VARCHAR2,
			       P_LINE_ATTR30                IN VARCHAR2
			       ) AS
    l_seq          NUMBER;
    l_batch_status VARCHAR2(15);

  BEGIN
    ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::populate_interface', 'Procedure Starts');

    ozf_sd_batch_feed_pvt.update_stale_data_batch_line(p_batch_number, p_batch_line_number);

    ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::populate_interface',
			          'WebADI Batch - before inserting into interface table');

    BEGIN
      INSERT INTO ozf_sd_batch_lines_int_all
        (batch_line_int_id,
         frm_contact1_name,
         frm_contact1_email,
         frm_contact1_fax,
         frm_contact1_phone,
         frm_gbl_ptnr_role_class_code,
         frm_business_name,
         frm_gbl_business_id,
         frm_gbl_supply_chain_code,
         frm_prop_business_id,
         frm_prop_domain_id1,
         frm_prop_id_authority1,
         frm_gbl_partner_class_code,
         frm_contact2_name,
         frm_contact2_email,
         frm_contact2_fax,
         frm_contact2_phone,
         frm_gbl_location_id,
         frm_prop_domain_id2,
         frm_prop_id_authority2,
         frm_prop_location_id,
         frm_address_line1,
         frm_address_line2,
         frm_address_line3,
         frm_city_name,
         frm_gbl_country_code,
         frm_national_postal_code,
         frm_pobox_id,
         frm_region_name,
         gbl_doc_function_code,
         ship_frm_sd_authorization_id,
         dist_by_business_name,
         dist_by_gbl_business_id,
         dist_by_gbl_supply_chain_code,
         dist_by_prop_business_id,
         dist_by_prop_domain_id1,
         dist_by_prop_idauthority1,
         dist_by_gbl_partner_class_code,
         dist_by_contact1_name,
         dist_by_contact1_email,
         dist_by_contact1_fax,
         dist_by_contact1_phone,
         dist_by_gbl_location_id,
         dist_by_prop_domain_id2,
         dist_by_prop_idauthority2,
         dist_by_prop_location_id,
         dist_by_address_line1,
         dist_by_address_line2,
         dist_by_address_line3,
         dist_by_city_name,
         dist_by_gbl_country_code,
         dist_by_national_postal_code,
         dist_by_pobox_id,
         dist_by_region_name,
         ship_to_business_name,
         ship_to_gbl_business_id,
         ship_to_gbl_supply_chain_code,
         ship_to_prop_business_id,
         ship_to_prop_domain_id1,
         ship_to_prop_id_authority1,
         ship_to_gbl_partner_class_code,
         ship_to_contact1_name,
         ship_to_contact1_email,
         ship_to_contact1_fax,
         ship_to_contact1_phone,
         ship_to_gbl_location_id,
         ship_to_prop_domain_id2,
         ship_to_prop_id_authority2,
         ship_to_prop_location_id,
         ship_to_address_line1,
         ship_to_address_line2,
         ship_to_address_line3,
         ship_to_city_name,
         ship_to_gbl_country_code,
         ship_to_national_postal_code,
         ship_to_pobox_id,
         ship_to_region_name,
         sold_to_business_name,
         sold_to_gbl_business_id,
         sold_to_gbl_supply_chain_code,
         sold_to_prop_business_id,
         sold_to_prop_domain_id1,
         sold_to_prop_id_authority1,
         sold_to_gbl_partner_class_code,
         sold_to_contact1_name,
         sold_to_contact1_email,
         sold_to_contact1_fax,
         sold_to_contact1_phone,
         sold_to_gbl_location_id,
         sold_to_prop_domain_id2,
         sold_to_prop_id_authority2,
         sold_to_prop_location_id,
         sold_to_address_line1,
         sold_to_address_line2,
         sold_to_address_line3,
         sold_to_city_name,
         sold_to_gbl_country_code,
         sold_to_national_postal_code,
         sold_to_pobox_id,
         sold_to_region_name,
         used_by_business_name,
         used_by_gbl_business_id,
         used_by_gbl_supply_chain_code,
         used_by_prop_business_id,
         used_by_prop_domain_id1,
         used_by_prop_id_authority1,
         used_by_gbl_partner_class_code,
         used_by_contact1_name,
         used_by_contact1_email,
         used_by_contact1_fax,
         used_by_contact1_phone,
         used_by_gbl_location_id,
         used_by_prop_domain_id2,
         used_by_prop_id_authority2,
         used_by_prop_location_id,
         used_by_address_line1,
         used_by_address_line2,
         used_by_address_line3,
         used_by_city_name,
         used_by_gbl_country_code,
         used_by_national_postal_code,
         used_by_pobox_id,
         used_by_region_name,
         ship_frm_sd_claim_request_date,
         ship_frm_sd_claim_request_id,
         credit_reference_id,
         debit_reference_id,
         batch_line_number,
         order_date,
         order_line_number,
         order_number,
         invoice_date,
         invoice_line_number,
         invoice_number,
         cost_currency_code,
         cost_monetary_amount,
         auth_cost_currency_code,
         auth_cost_monetary_amount,
         resale_currency_code,
         resale_monetary_amount,
         gbl_uom,
         gbl_claim_disposition_code,
         vendor_product_id,
         dist_product_id,
         ship_date,
         shipped_quantity,
         vendor_auth_lineitem_line_nbr,
         vendor_auth_cost_currency_code,
         vendor_auth_cost_monetary_amt,
	 vendor_auth_quantity,
         this_doc_generation_date,
         this_document_id,
         to_contact1_name,
         to_contact1_email,
         to_contact1_fax,
         to_contact1_phone,
         to_gbl_partner_role_class_code,
         to_business_name1,
         to_gbl_business_id,
         to_gbl_supply_chain_code,
         to_prop_business_id,
         to_prop_domain_id1,
         to_prop_id_authority1,
         to_gbl_partner_class_code,
         to_contact2_name,
         to_contact2_email,
         to_contact2_fax,
         to_contact2_phone,
         to_gbl_location_id,
         to_prop_domain_id2,
         to_prop_id_authority2,
         to_prop_location_id,
         to_address_line1,
         to_address_line2,
         to_address_line3,
         to_city_name,
         to_gbl_country_code,
         to_national_postal_code,
         to_pobox_id,
         to_region_name,
         creation_date,
         last_update_date,
         last_updated_by,
         created_by,
         processed_flag,
         batch_id,
         batch_line_id,
	 gbl_claim_rej_code1,
	 gbl_claim_rej_code2,
	 gbl_claim_rej_code3,
	 gbl_claim_rej_code4,
	 gbl_claim_rej_code5,
	 gbl_claim_rej_code6,
	 gbl_claim_rej_code7,
	 gbl_claim_rej_code8,
	 gbl_claim_rej_code9,
	 gbl_claim_rej_code10,
	 header_attribute_category,
	 header_attribute1,
	 header_attribute2,
	 header_attribute3,
	 header_attribute4,
	 header_attribute5,
	 header_attribute6,
	 header_attribute7,
	 header_attribute8,
	 header_attribute9,
	 header_attribute10,
	 header_attribute11,
	 header_attribute12,
	 header_attribute13,
	 header_attribute14,
	 header_attribute15,
	 header_attribute16,
	 header_attribute17,
	 header_attribute18,
	 header_attribute19,
	 header_attribute20,
	 header_attribute21,
	 header_attribute22,
	 header_attribute23,
	 header_attribute24,
	 header_attribute25,
	 header_attribute26,
	 header_attribute27,
	 header_attribute28,
	 header_attribute29,
	 header_attribute30,
	 line_attribute_category,
	 line_attribute1,
	 line_attribute2,
	 line_attribute3,
	 line_attribute4,
	 line_attribute5,
	 line_attribute6,
	 line_attribute7,
	 line_attribute8,
	 line_attribute9,
	 line_attribute10,
	 line_attribute11,
	 line_attribute12,
	 line_attribute13,
	 line_attribute14,
	 line_attribute15,
	 line_attribute16,
	 line_attribute17,
	 line_attribute18,
	 line_attribute19,
	 line_attribute20,
	 line_attribute21,
	 line_attribute22,
	 line_attribute23,
	 line_attribute24,
	 line_attribute25,
	 line_attribute26,
	 line_attribute27,
	 line_attribute28,
	 line_attribute29,
	 line_attribute30
	 )
      VALUES
        (ozf_sd_batch_lines_int_all_s.nextval,
         p_to_cntct1_name,
         p_to_cntct1_email,
         p_to_cntct1_fax,
         p_to_cntct1_phone,
         p_to_gbl_ptnr_role_class_cd,
         p_to_business_name,
         p_to_gbl_business_id,
         p_to_gbl_supply_chain_cd,
         p_to_prop_business_id1,
         p_to_prop_domain_id1,
         p_to_auth_id1,
         p_to_gbl_ptnr_class_cd,
         p_to_cntct2_name,
         p_to_cntct2_email,
         p_to_cntct2_fax,
         p_to_cntct2_phone,
         p_to_gbl_loc_id,
         p_to_prop_domain_id2,
         p_to_prop_auth_id2,
         p_to_prop_loc_id,
         p_to_add_line1,
         p_to_add_line2,
         p_to_add_line3,
         p_to_city,
         p_to_country,
         p_to_postal_code,
         p_to_po_box_id,
         p_to_region,
         'RESPONSE',
         p_ship_from_sd_auth_id,
         p_dist_by_business_name,
         p_dist_by_gbl_business_id,
         'Electronic Components', --P_DIST_BY_GBL_SUPP_CHAIN_CD ,
         p_dist_by_prop_business_id,
         p_dist_by_prop_domain_id1,
         p_dist_by_prop_auth_id1,
         'Distributor', --P_DIST_BY_GBL_PTNR_CLASS_CD ,
         p_dist_by_cntct_name,
         p_dist_by_cntct_email,
         p_dist_by_cntct_fax,
         p_dist_by_cntct_phone,
         p_dist_by_gbl_loc_id,
         p_dist_by_prop_domain_id2,
         p_dist_by_prop_auth_id2,
         p_dist_by_prop_loc_id,
         p_dist_by_add_line1,
         p_dist_by_add_line2,
         p_dist_by_add_line3,
         p_dist_by_city,
         p_dist_by_country,
         p_dist_by_postal_code,
         p_dist_by_po_box_id,
         p_dist_by_region,
         p_ship_to_business_name,
         p_ship_to_gbl_business_id,
         p_ship_to_gbl_supp_chain_cd,
         p_ship_to_prop_business_id,
         p_ship_to_prop_domain_id1,
         p_ship_to_prop_auth_id1,
         p_ship_to_gbl_ptnr_class_cd,
         p_ship_to_cust_cntct_name,
         p_ship_to_cust_cntct_email,
         p_ship_to_cust_cntct_fax,
         p_ship_to_cust_cntct_phone,
         p_ship_to_cust_gbl_loc_id,
         p_ship_to_prop_domain_id2,
         p_ship_to_prop_auth_id2,
         p_ship_to_cust_prop_loc_id,
         p_ship_to_cust_add1,
         p_ship_to_cust_add2,
         p_ship_to_cust_add3,
         p_ship_to_cust_city,
         p_ship_to_cust_country,
         p_ship_to_cust_postal_code,
         p_ship_to_cust_po_box_id,
         p_ship_to_cust_region,
         p_sold_to_business_name,
         p_sold_to_gbl_business_id,
         p_sold_to_gbl_supp_chain_cd,
         p_sold_to_prop_business_id,
         p_sold_to_prop_domain_id1,
         p_sold_to_prop_auth_id1,
         p_sold_to_gbl_ptnr_class_cd,
         p_sold_to_cust_cntct_name,
         p_sold_to_cust_cntct_email,
         p_sold_to_cust_cntct_fax,
         p_sold_to_cust_cntct_phone,
         p_sold_to_cust_gbl_loc_id,
         p_sold_to_prop_domain_id2,
         p_sold_to_prop_auth_id2,
         p_sold_to_cust_prop_loc_id,
         p_sold_to_cust_add1,
         p_sold_to_cust_add2,
         p_sold_to_cust_add3,
         p_sold_to_cust_city,
         p_sold_to_cust_country,
         p_sold_to_cust_postal_code,
         p_sold_to_cust_po_box_id,
         p_sold_to_cust_region,
         p_end_cust_business_name,
         p_end_cust_gbl_business_id,
         p_end_cust_gbl_supp_chain_cd,
         p_end_cust_prop_business_id,
         p_end_cust_prop_domain_id1,
         p_end_cust_prop_auth_id1,
         p_end_cust_gbl_ptnr_class_cd,
         p_end_cust_cntct_name,
         p_end_cust_cntct_email,
         p_end_cust_cntct_fax,
         p_end_cust_cntct_phone,
         p_end_cust_gbl_loc_id,
         p_end_cust_prop_domain_id2,
         p_end_cust_prop_auth_id2,
         p_end_cust_prop_loc_id,
         p_end_cust_add1,
         p_end_cust_add2,
         p_end_cust_add3,
         p_end_cust_city,
         p_end_cust_country,
         p_end_cust_postal_code,
         p_end_cust_po_box_id,
         p_end_cust_region,
         p_ship_frm_sd_claim_req_date,
         p_batch_number, --Inserting batch_number for SHIP_FRM_SD_CLAIM_REQ_ID to be in sync with xml
         p_credit_ref_id,
         p_debit_ref_id,
         p_batch_line_number,
         p_order_date,
         p_order_line_number,
         p_order_number,
         p_invoice_date,
         p_invoice_line_number,
         p_invoice_number,
         p_cost_price_curr_code,
         p_cost_price,
         p_auth_price_curr_code,
         p_auth_price,
         p_resale_price_curr_code,
         p_resale_price,
         p_uom,
         p_line_status,
         p_vendor_part_number,
         p_dist_part_number,
         p_date_shipped,
         p_qty_shipped,
         p_vendor_auth_line_item_no,
         p_vendor_apprvd_amt_curr_cd,
         p_vendor_apprvd_amt,
	 p_vendor_apprvd_qty,
         p_batch_submission_date,
         p_batch_number,
         p_frm_cntct1_name,
         p_frm_cntct1_email,
         p_frm_cntct1_fax,
         p_frm_cntct1_phone,
         p_frm_gbl_ptnr_role_class_cd,
         p_frm_business_name,
         p_frm_gbl_business_id,
         p_frm_gbl_supply_chain_cd,
         p_frm_prop_business_id1,
         p_frm_prop_domain_id1,
         p_frm_auth_id1,
         p_frm_gbl_ptnr_class_cd,
         p_frm_cntct2_name,
         p_frm_cntct2_email,
         p_frm_cntct2_fax,
         p_frm_cntct2_phone,
         p_frm_gbl_loc_id,
         p_frm_prop_domain_id2,
         p_frm_prop_auth_id2,
         p_frm_prop_loc_id,
         p_frm_add_line1,
         p_frm_add_line2,
         p_frm_add_line3,
         p_frm_city,
         p_frm_country,
         p_frm_postal_code,
         p_frm_po_box_id,
         p_frm_region,
         sysdate,
         sysdate,
         0,
         0,
         'N',
         p_batch_id,
         p_batch_line_id,
	 p_disposition_code1,
	 p_disposition_code2,
	 p_disposition_code3,
	 p_disposition_code4,
	 p_disposition_code5,
	 p_disposition_code6,
	 p_disposition_code7,
	 p_disposition_code8,
	 p_disposition_code9,
	 p_disposition_code10,
	 P_HDR_ATTR_CATG,
	 P_HDR_ATTR1,
	 P_HDR_ATTR2,
	 P_HDR_ATTR3,
	 P_HDR_ATTR4,
	 P_HDR_ATTR5,
	 P_HDR_ATTR6,
	 P_HDR_ATTR7,
	 P_HDR_ATTR8,
	 P_HDR_ATTR9,
	 P_HDR_ATTR10,
	 P_HDR_ATTR11,
	 P_HDR_ATTR12,
	 P_HDR_ATTR13,
	 P_HDR_ATTR14,
	 P_HDR_ATTR15,
	 P_HDR_ATTR16,
	 P_HDR_ATTR17,
	 P_HDR_ATTR18,
	 P_HDR_ATTR19,
	 P_HDR_ATTR20,
	 P_HDR_ATTR21,
	 P_HDR_ATTR22,
	 P_HDR_ATTR23,
	 P_HDR_ATTR24,
	 P_HDR_ATTR25,
	 P_HDR_ATTR26,
	 P_HDR_ATTR27,
	 P_HDR_ATTR28,
	 P_HDR_ATTR29,
	 P_HDR_ATTR30,
	 P_LINE_ATTR_CATG,
	 P_LINE_ATTR1,
	 P_LINE_ATTR2,
	 P_LINE_ATTR3,
	 P_LINE_ATTR4,
	 P_LINE_ATTR5,
	 P_LINE_ATTR6,
	 P_LINE_ATTR7,
	 P_LINE_ATTR8,
	 P_LINE_ATTR9,
	 P_LINE_ATTR10,
	 P_LINE_ATTR11,
	 P_LINE_ATTR12,
	 P_LINE_ATTR13,
	 P_LINE_ATTR14,
	 P_LINE_ATTR15,
	 P_LINE_ATTR16,
	 P_LINE_ATTR17,
	 P_LINE_ATTR18,
	 P_LINE_ATTR19,
	 P_LINE_ATTR20,
	 P_LINE_ATTR21,
	 P_LINE_ATTR22,
	 P_LINE_ATTR23,
	 P_LINE_ATTR24,
	 P_LINE_ATTR25,
	 P_LINE_ATTR26,
	 P_LINE_ATTR27,
	 P_LINE_ATTR28,
	 P_LINE_ATTR29,
	 P_LINE_ATTR30);

    EXCEPTION
      WHEN others THEN
        ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::populate_interface', 'Exception: '||sqlerrm);
    END;

    COMMIT;
    ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::populate_interface', 'Procedure Ends');

  END populate_interface;

  PROCEDURE update_data(p_batch_number   IN VARCHAR2,
                        x_return_status  OUT nocopy VARCHAR2,
                        x_msg_data       OUT nocopy VARCHAR2
                        ) IS
    l_cnt_hdr              NUMBER;
    l_cnt_line             NUMBER;
    l_cnt_tot_line         NUMBER;
    l_cnt_approved_lines   NUMBER;
    l_cnt_rejected_lines   NUMBER;
    l_message              VARCHAR2(500);
    l_to_amount            NUMBER;
    l_claim_number         NUMBER;
    l_accepted_amount      NUMBER;
    l_batch_id             NUMBER;
    l_batch_status         VARCHAR2(15);
    l_claim_id             NUMBER;
    l_claim_minor_version  NUMBER;
    l_currency_code        VARCHAR2(15);
    l_msg_count            NUMBER;
    l_org_id               NUMBER;
    l_ssd_dec_adj_type_id  NUMBER;
    l_ssd_inc_adj_type_id  NUMBER;
    l_tot_app_claim_amt    NUMBER ;
    l_func_currency        VARCHAR2(15);
    l_batch_currency       VARCHAR2(15);


    CURSOR C_MISS_REJ_APP IS
         SELECT batch_line_number,
	    auth_cost,
	    auth_curr_code,
	    stat_code,
	    credit_reference_id,
	    vendor_auth_quantity,
	    adjustment_type,
	    CASE
		       WHEN((auth_cost is null and vendor_auth_quantity is null) OR ( auth_curr_code <> CLAIM_AMOUNT_CURRENCY_CODE ) OR auth_cost < 0 OR vendor_auth_quantity < 0) then 0

		       WHEN (auth_cost is null and vendor_auth_quantity IS NOT NULL AND DISCOUNT_TYPE IN ('NEWPRICE','%')) THEN ((list_price-agreement_price) * vendor_auth_quantity)

		       WHEN (auth_cost is null and vendor_auth_quantity IS NOT NULL AND DISCOUNT_TYPE IN ('AMT')) THEN (discount_value * vendor_auth_quantity)

		       WHEN (vendor_auth_quantity is null and auth_cost is not null AND DISCOUNT_TYPE IN ('NEWPRICE','%')) THEN  ((list_price - auth_cost) * QUANTITY_SHIPPED)

		       WHEN (vendor_auth_quantity is null and auth_cost is not null AND DISCOUNT_TYPE IN ('AMT')) THEN  (auth_cost *  QUANTITY_SHIPPED)

		       WHEN (vendor_auth_quantity is not null and auth_cost is not null AND DISCOUNT_TYPE IN ('NEWPRICE','%')) THEN  ((list_price - auth_cost) * vendor_auth_quantity)
		       WHEN (vendor_auth_quantity is not null and auth_cost is not null AND DISCOUNT_TYPE IN ('AMT')) THEN  ((auth_cost) * vendor_auth_quantity)
	  END  approved_claim_amount,
	  line_status_code,
	  computed_batch_curr_claim_amt

	    FROM(
	    SELECT bint.batch_line_number batch_line_number,
		   DECODE(gbl_claim_disposition_code,'APPROVED', DECODE(discount_type, 'AMT' , discount_value , agreement_price), vendor_auth_cost_monetary_amt) auth_cost,
		   DECODE(gbl_claim_disposition_code,'APPROVED', DECODE(discount_type, 'AMT' , discount_currency_code, Agreement_currency_code), vendor_auth_cost_currency_code) auth_curr_code,
                   DECODE(NVL(gbl_claim_disposition_code,'REJECTED'), 'APPROVED', 'APPROVED', 'REJECTED') stat_code,
                   credit_reference_id,
                   DECODE(gbl_claim_disposition_code,'APPROVED',quantity_shipped , vendor_auth_quantity) vendor_auth_quantity,
                   clm.adjustment_type,
		   discount_type,
                   discount_value,
                   list_price,
                   agreement_price,
                   claim_amount_currency_code,
                   quantity_shipped,
		   gbl_claim_disposition_code line_status_code,
		   CASE
		        WHEN ((lines.claim_amount_currency_code = l_batch_currency) OR (l_func_currency = l_batch_currency)) THEN  lines.BATCH_CURR_CLAIM_AMOUNT
                        WHEN ((lines.claim_amount_currency_code = l_func_currency) AND (l_func_currency <> l_batch_currency)) THEN  OZF_SD_UTIL_PVT.GET_CONVERTED_CURRENCY(lines.claim_amount_currency_code,
																		                           l_batch_currency,
																		                           l_func_currency,
																		                           (SELECT fu.exchange_rate_type
																					      FROM ozf_funds_utilized_all_b fu
																					     WHERE fu.utilization_id = lines.utilization_id
																					       AND lines.batch_id = p_batch_number),
																					   NULL,
																		                           sysdate,
																		                           lines.claim_amount)

			WHEN ((lines.claim_amount_currency_code <> l_func_currency) AND (l_func_currency <> l_batch_currency)) THEN OZF_SD_UTIL_PVT.GET_CONVERTED_CURRENCY(lines.claim_amount_currency_code,
																					   l_batch_currency,
																					   l_func_currency,
																					   (SELECT fu.exchange_rate_type
																					      FROM ozf_funds_utilized_all_b fu
																					     WHERE fu.utilization_id = lines.utilization_id
																					       AND lines.batch_id = p_batch_number),
																					   NULL,
																					   (SELECT fu.exchange_rate_date
																					      FROM ozf_funds_utilized_all_b fu
																					     WHERE fu.utilization_id = lines.utilization_id
																					       AND lines.batch_id = p_batch_number),
																					   lines.claim_amount)
		    END computed_batch_curr_claim_amt
 	    FROM ozf_sd_batch_lines_int_all bint, ozf_sd_batch_lines_all lines, ozf_claim_types_all_vl clm
           WHERE ship_frm_sd_claim_request_id = p_batch_number
             AND processed_flag               = 'N'
             AND bint.ship_frm_sd_claim_request_id = lines.batch_id
             AND bint.batch_line_number = lines.batch_line_number
	     AND lines.adjustment_type_id = clm.claim_type_id(+)
            ) ;

  BEGIN

    ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_data', 'Procedure Starts');

    x_return_status := fnd_api.g_ret_sts_success;

    --Retreive batch id
     BEGIN
        SELECT batch_id, status_code, claim_minor_version, org_id, currency_code
          INTO l_batch_id, l_batch_status, l_claim_minor_version, l_org_id, l_batch_currency
          FROM ozf_sd_batch_headers_all
         WHERE batch_number = p_batch_number;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  UPDATE ozf_sd_batch_lines_int_all
             SET validation_txt = 'Batch ID does not exist',
	         last_update_date      = sysdate,
                 last_updated_by       = fnd_global.user_id
           WHERE ship_frm_sd_claim_request_id = p_batch_number
             AND processed_flag = 'N';
           COMMIT;
           x_return_status := fnd_api.g_ret_sts_error;
           x_msg_data      := FND_MESSAGE.GET_STRING('OZF','OZF_SD_BATCH_INVALID');
           RETURN;
        WHEN OTHERS THEN
           x_return_status := fnd_api.g_ret_sts_error;
           x_msg_data      := FND_MESSAGE.GET_STRING('OZF','OZF_SD_BATCH_INVALID');
           RETURN;
      END;

    ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_data',
	'Batch Id: '||l_batch_id||' and Batch Status: '||l_batch_status);

     --raising business event
     ozf_sd_util_pvt.sd_raise_event (l_batch_id, 'RESPONSE', x_return_status);

    IF l_batch_status NOT IN ('WIP','SUBMITTED' ) THEN
     UPDATE ozf_sd_batch_lines_int_all
        SET processed_flag = 'E',
            validation_txt = 'Batch not in WIP or SUBMITTED status',
	    last_update_date      = sysdate,
            last_updated_by       = fnd_global.user_id
      WHERE ship_frm_sd_claim_request_id = p_batch_number
        AND processed_flag = 'N';
      COMMIT;
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data      := FND_MESSAGE.GET_STRING('OZF','OZF_SD_BATCH_STATUS_INVALID');
      RETURN;
    END IF;

    --check whether lines exist for given batch id
    SELECT COUNT(1)
      INTO l_cnt_line
      FROM ozf_sd_batch_lines_int_all
     WHERE ship_frm_sd_claim_request_id = p_batch_number
       AND processed_flag = 'N';

    IF l_cnt_line = 0 THEN
        UPDATE ozf_sd_batch_lines_int_all
           SET validation_txt = 'There are no Lines for this Batch ID',
	       last_update_date      = sysdate,
               last_updated_by       = fnd_global.user_id
         WHERE ship_frm_sd_claim_request_id = p_batch_number
           AND processed_flag = 'N';
        COMMIT;
       x_return_status := fnd_api.g_ret_sts_error;
       x_msg_data      := 'There are no Lines for this Batch ID';
       RETURN;
    END IF;

       SELECT gs.currency_code
         INTO l_func_currency
	 FROM gl_sets_of_books gs,
	      ozf_sys_parameters_all org,
	      ozf_sd_batch_headers_all bh
	WHERE org.set_of_books_id = gs.set_of_books_id
	  AND org.org_id = bh.org_id
	  AND bh.batch_number = p_batch_number;


    BEGIN
      DELETE ozf_sd_batch_line_disputes
       WHERE batch_id = l_batch_id
              AND batch_line_id IN (SELECT bl.batch_line_id
						           FROM ozf_sd_batch_lines_all bl, ozf_sd_batch_lines_int_all intr
		                                       WHERE bl.batch_id = l_batch_id
		   					      AND bl.batch_id = intr.ship_frm_sd_claim_request_id
							      AND bl.batch_line_number = intr.batch_line_number
                                                              AND intr.processed_flag = 'N'
										  AND bl.purge_flag <> 'Y'
						       );
     EXCEPTION
      WHEN others THEN
       ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_data',
					'Exception Delete OZF_SD_BATCH_LINE_DISPUTES: '||sqlerrm);
    END;

    INSERT INTO ozf_sd_batch_line_disputes
	(batch_line_dispute_id,
	batch_id,
	batch_line_id,
	object_version_number,
	dispute_code,
	review_flag,
	creation_date,
	last_update_date,
	last_updated_by,
	request_id,
	created_by,
	created_from,
	last_update_login,
	program_application_id,
	program_update_date,
	program_id,
	security_group_id)

	SELECT ozf_sd_batch_line_disputes_s.nextval,
	  a.batch_id,
	  a.batch_line_id,
	  1,
	  a.dispute_code,
	  'N',
	  sysdate,
	  sysdate,
	  fnd_global.user_id,
	  fnd_global.conc_request_id,
	  fnd_global.user_id,
	  NULL,  --created from
	  fnd_global.conc_login_id,
	  fnd_global.prog_appl_id,
	  NULL,  --l_program_update_date,
	  fnd_global.conc_program_id,
	  fnd_global.security_group_id

	FROM  -- No rejection code for rejected line
	  (  SELECT intr.batch_id,
	            intr.batch_line_id,
	            'OZF_SD_MISSING_REJ_CODE' dispute_code
	     FROM ozf_sd_batch_lines_int_all intr,
	     ozf_sd_batch_lines_all bl
	   WHERE intr.ship_frm_sd_claim_request_id = p_batch_number
	   AND intr.processed_flag = 'N'
	   AND bl.purge_flag <> 'Y'
	   AND intr.gbl_claim_disposition_code = 'REJECTED'
	   AND intr.ship_frm_sd_claim_request_id = bl.batch_id
	   AND intr.batch_line_number = bl.batch_line_number
	   AND intr.gbl_claim_rej_code1 IS NULL
	   AND intr.gbl_claim_rej_code2 IS NULL
	   AND intr.gbl_claim_rej_code3 IS NULL
	   AND intr.gbl_claim_rej_code4 IS NULL
	   AND intr.gbl_claim_rej_code5 IS NULL
	   AND intr.gbl_claim_rej_code6 IS NULL
	   AND intr.gbl_claim_rej_code7 IS NULL
	   AND intr.gbl_claim_rej_code8 IS NULL
	   AND intr.gbl_claim_rej_code9 IS NULL
	   AND intr.gbl_claim_rej_code10 IS NULL

	   UNION ALL -- missing or invalid status for batch lines

	  SELECT  intr.batch_id,
	     intr.batch_line_id,
	     'OZF_SD_NO_RESPONSE' dispute_code
		FROM ozf_sd_batch_lines_int_all intr
		WHERE ship_frm_sd_claim_request_id =  p_batch_number
		AND processed_flag = 'N'
		AND (  (gbl_claim_disposition_code IS NULL) OR ( gbl_claim_disposition_code NOT IN ('APPROVED', 'REJECTED')  )  )


	   UNION ALL -- Currency code mismatch

	  SELECT intr.batch_id,
	     intr.batch_line_id,
	     'OZF_SD_CURR_CODE_MISMATCH' dispute_code
	   FROM ozf_sd_batch_lines_int_all intr,
	     ozf_sd_batch_lines_all bl
	   WHERE intr.ship_frm_sd_claim_request_id = p_batch_number
	   AND intr.processed_flag = 'N'
	   AND bl.purge_flag <> 'Y'
	   AND intr.gbl_claim_disposition_code = 'REJECTED'
	   AND intr.ship_frm_sd_claim_request_id = bl.batch_id
	   AND intr.batch_line_number = bl.batch_line_number
	   AND bl.claim_amount_currency_code <> intr.vendor_auth_cost_currency_code

	UNION ALL -- VENDOR_AUTH_COST_MONETARY_AMT CAN NOT BE NEGATIVE

	  SELECT intr.batch_id,
	     intr.batch_line_id,
	     'OZF_SD_VENDOR_AUTH_AMT_NGTVE' dispute_code
	   FROM ozf_sd_batch_lines_int_all intr,
	     ozf_sd_batch_lines_all bl
	   WHERE intr.ship_frm_sd_claim_request_id = p_batch_number
	   AND intr.processed_flag = 'N'
	   AND bl.purge_flag <> 'Y'
	   AND intr.gbl_claim_disposition_code = 'REJECTED'
	  AND intr.ship_frm_sd_claim_request_id = bl.batch_id
	  AND intr.batch_line_number = bl.batch_line_number
	  AND intr.vendor_auth_cost_monetary_amt < 0

	UNION ALL -- VENDOR_AUTH_QTY CAN NOT BE NEGATIVE

	  SELECT intr.batch_id,
	     intr.batch_line_id,
	     'OZF_SD_VENDOR_AUTH_QTY_NGTVE' dispute_code
	   FROM ozf_sd_batch_lines_int_all intr,
	     ozf_sd_batch_lines_all bl
	   WHERE intr.ship_frm_sd_claim_request_id = p_batch_number
	   AND intr.processed_flag = 'N'
	   AND bl.purge_flag <> 'Y'
	   AND intr.gbl_claim_disposition_code = 'REJECTED'
	  AND intr.ship_frm_sd_claim_request_id = bl.batch_id
	  AND intr.batch_line_number = bl.batch_line_number
	  AND bl.original_claim_amount > 0 -- only for non RMA lines
	  AND intr.vendor_auth_quantity < 0

	UNION ALL -- VENDOR_AUTH_COST_MONETARY_AMT is NULL and VENDOR_AUTH_QTY is NULL

	  SELECT intr.batch_id,
	     intr.batch_line_id,
	     'OZF_SD_AUTH_AMT_QTY_NULL' dispute_code
	   FROM ozf_sd_batch_lines_int_all intr,
	     ozf_sd_batch_lines_all bl
	   WHERE intr.ship_frm_sd_claim_request_id = p_batch_number
	   AND intr.processed_flag = 'N'
	   AND bl.purge_flag <> 'Y'
	   AND intr.gbl_claim_disposition_code = 'REJECTED'
	   AND intr.ship_frm_sd_claim_request_id = bl.batch_id
	   AND intr.batch_line_number = bl.batch_line_number
	   AND intr.vendor_auth_cost_monetary_amt is NULL
	   AND intr.vendor_auth_quantity is NULL

	) a ;

    update_dispute_data(p_batch_number,l_batch_id);

    SELECT SSD_DEC_ADJ_TYPE_ID, SSD_INC_ADJ_TYPE_ID
      INTO l_ssd_dec_adj_type_id, l_ssd_inc_adj_type_id
      FROM OZF_SYS_PARAMETERS_ALL
     WHERE org_id = l_org_id;



FOR V_MISS_REJ_APP_REC IN C_MISS_REJ_APP

LOOP

 UPDATE ozf_sd_batch_lines_all
   SET status_code            = V_MISS_REJ_APP_REC.stat_code,
       approved_amount        = (case  when (original_claim_amount > 0) THEN  V_MISS_REJ_APP_REC.auth_cost
                                       when (original_claim_amount < 0 AND V_MISS_REJ_APP_REC.line_status_code = 'APPROVED') then V_MISS_REJ_APP_REC.auth_cost end),

       approved_currency_code = (case  when (original_claim_amount > 0) THEN  V_MISS_REJ_APP_REC.auth_curr_code
                                       when (original_claim_amount < 0 AND V_MISS_REJ_APP_REC.line_status_code = 'APPROVED') THEN V_MISS_REJ_APP_REC.auth_curr_code end),

       object_version_number  = object_version_number + 1,
       last_update_date       = sysdate,
       last_updated_by        = fnd_global.user_id,
       vendor_ref_id          = V_MISS_REJ_APP_REC.credit_reference_id,
       quantity_approved      = (case  when (original_claim_amount > 0) THEN  V_MISS_REJ_APP_REC.vendor_auth_quantity
                                       when (original_claim_amount < 0 AND V_MISS_REJ_APP_REC.line_status_code = 'APPROVED') THEN V_MISS_REJ_APP_REC.vendor_auth_quantity end),

       batch_curr_claim_amount = decode(V_MISS_REJ_APP_REC.stat_code,'APPROVED',V_MISS_REJ_APP_REC.computed_batch_curr_claim_amt, batch_curr_claim_amount),
       adjustment_type_id     = (case  when ( (original_claim_amount > 0)
                                            AND (V_MISS_REJ_APP_REC.approved_claim_amount > original_claim_amount)
                                            AND V_MISS_REJ_APP_REC.adjustment_type <> 'STANDARD'
					    AND V_MISS_REJ_APP_REC.line_status_code<>'APPROVED' )
					    THEN l_ssd_inc_adj_type_id
                                       when ( (original_claim_amount > 0)
				            AND (V_MISS_REJ_APP_REC.approved_claim_amount < original_claim_amount)
					    AND V_MISS_REJ_APP_REC.adjustment_type <> 'DECREASE_EARNED'
				            AND V_MISS_REJ_APP_REC.line_status_code<>'APPROVED' )
					    THEN l_ssd_dec_adj_type_id
                                   else
				    adjustment_type_id
				   end)
 WHERE batch_id               = l_batch_id
   AND batch_line_number      = V_MISS_REJ_APP_REC.batch_line_number
   AND purge_flag            <> 'Y'
   AND status_code            = 'SUBMITTED';

 END LOOP ;

      --get total number of lines
    SELECT COUNT(1)
      INTO l_cnt_tot_line
      FROM ozf_sd_batch_lines_all
     WHERE batch_id = l_batch_id
       AND purge_flag <> 'Y';

      --get number of approved lines
    SELECT COUNT(1)
      INTO l_cnt_approved_lines
      FROM ozf_sd_batch_lines_all
     WHERE batch_id = l_batch_id
       AND status_code = 'APPROVED'
       AND purge_flag <> 'Y';

     --get number of rejected lines
    SELECT COUNT(1)
      INTO l_cnt_rejected_lines
      FROM ozf_sd_batch_lines_all
     WHERE batch_id = l_batch_id
       AND status_code = 'REJECTED'
       AND purge_flag <> 'Y';

    ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_data', 'number of total lines: '||l_cnt_tot_line);
    ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_data', 'number of rejected lines: '||l_cnt_rejected_lines);
    ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_data', 'number of approved lines: '||l_cnt_approved_lines);

    --All lines are rejected or if none approved

    IF  ( ( l_cnt_rejected_lines = l_cnt_tot_line) OR ( l_cnt_approved_lines = 0 ) ) THEN

      UPDATE ozf_sd_batch_headers_all
         SET status_code           = 'WIP',
             object_version_number = object_version_number + 1,
	     last_update_date      = sysdate,
             last_updated_by       = fnd_global.user_id
       WHERE batch_id = l_batch_id;

      UPDATE ozf_sd_batch_lines_int_all
         SET processed_flag = 'Y',
	     last_update_date      = sysdate,
             last_updated_by       = fnd_global.user_id
       WHERE ship_frm_sd_claim_request_id = p_batch_number
         AND processed_flag = 'N';

	 COMMIT;
	 RETURN;

    END IF; --All lines are rejected or if none approved

     -- All lines APPROVED case
    IF  l_cnt_approved_lines = l_cnt_tot_line THEN

	   UPDATE ozf_sd_batch_headers_all
	       SET status_code           = 'APPROVED',
		   claim_minor_version   = NULL,
		   object_version_number = object_version_number + 1,
		   last_update_date      = sysdate,
		   last_updated_by       = fnd_global.user_id
	     WHERE batch_id = l_batch_id;

	    --Mark all rows as processed
	    UPDATE ozf_sd_batch_lines_int_all
	       SET processed_flag               = 'Y',
		   last_update_date             = sysdate,
		   last_updated_by              = fnd_global.user_id
	     WHERE ship_frm_sd_claim_request_id = p_batch_number
	       AND processed_flag               = 'N';

	 SAVEPOINT  BEFORE_INVOKING_CLAIM;



	 -- Check if the batch is negative

	 select sum(batch_curr_claim_amount) INTO l_tot_app_claim_amt from ozf_sd_batch_lines_all
	 where batch_id=l_batch_id ;


	 IF (l_tot_app_claim_amt>0) THEN


			 PROCESS_CLAIM(l_batch_id, x_return_status, x_msg_data, l_claim_id);

			 IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

			       OZF_SD_UTIL_PVT.CREATE_ADJUSTMENT(l_batch_id, 'F', x_return_status, l_msg_count, x_msg_data); -- to pass p_comp_wrt_off

			       IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
					--raising business event
					ozf_sd_util_pvt.sd_raise_event (l_batch_id, 'CLAIM', x_return_status);
				       UPDATE ozf_sd_batch_headers_all
					  SET status_code           = 'CLOSED',
					      claim_id              = l_claim_id,
					      last_update_date      = sysdate,
					      last_updated_by       = fnd_global.user_id,
					      object_version_number = object_version_number + 1
					WHERE batch_id = l_batch_id;
				   ELSE -- If adjustment is not successful
				     ROLLBACK TO BEFORE_INVOKING_CLAIM;
					UPDATE ozf_sd_batch_headers_all
					   SET status_code           = 'PENDING_CLAIM',
					       last_update_date      = sysdate,
					       last_updated_by       = fnd_global.user_id,
					       object_version_number = object_version_number + 1
					 WHERE batch_id = l_batch_id;
			       END IF; -- If adjustment is successful

			 ELSE -- If claim is not successful

			    ROLLBACK TO BEFORE_INVOKING_CLAIM;
			    UPDATE ozf_sd_batch_headers_all
			       SET status_code           = 'PENDING_CLAIM',
				   last_update_date      = sysdate,
				   last_updated_by       = fnd_global.user_id,
				   object_version_number = object_version_number + 1
			     WHERE batch_id = l_batch_id;

			 END IF; -- If claim is successful

	END IF ;

	    COMMIT;
	    RETURN;

    END IF; -- All lines APPROVED case


   --Not all lines Approved and atleast there is one APPROVED line -- Forking required
    IF  (  ( l_cnt_approved_lines > 0 )  AND ( l_cnt_approved_lines <> l_cnt_tot_line )  )   THEN

        PROCESS_CHILD_BATCH(l_batch_id, x_return_status, x_msg_data);

	 --set batch header as WIP for parent batch
        UPDATE ozf_sd_batch_headers_all
           SET status_code           = 'WIP',
	       object_version_number = object_version_number + 1,
	       claim_minor_version   = l_claim_minor_version + 1,
	       last_update_date      = sysdate,
	       last_updated_by       = fnd_global.user_id
           --  child_batch_id        = l_new_batch_id
        WHERE batch_id = l_batch_id;

	--Mark all rows as processed
	UPDATE ozf_sd_batch_lines_int_all
	   SET processed_flag = 'Y',
	       last_update_date      = sysdate,
	       last_updated_by       = fnd_global.user_id
	 WHERE ship_frm_sd_claim_request_id = p_batch_number
	   AND processed_flag = 'N';

	COMMIT;
	RETURN;

    END IF; -- Not all lines Approved and atleast there is one APPROVED line

   IF x_return_status = fnd_api.g_ret_sts_error THEN
      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_data',
					'Entered throwing exception' || x_msg_data);
      fnd_message.set_name('OZF', 'OZF_SD_FEED_DATA_ERROR');
      fnd_message.set_token('MESSAGE', x_msg_data);
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_data',
					'Entered throwing unexpected exception');
      fnd_message.set_name('OZF', 'OZF_SD_FEED_DATA_ERROR');
      fnd_message.set_token('MESSAGE', x_msg_data);
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_data', 'Procedure Ends');

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_data',
					'OZF EXCEPTION G_EXC_ERROR: '||x_msg_data);
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('OZF', 'OZF_SD_FEED_DATA_ERROR');
      fnd_message.set_token('MESSAGE', x_msg_data);
      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_data',
					'OZF done:' || x_msg_data || '::::');

    WHEN fnd_api.g_exc_unexpected_error THEN
      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_data',
					'OZF EXCEPTION G_EXC_UNEXPECTED_ERROR');
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('OZF', 'OZF_SD_FEED_DATA_ERROR');
      fnd_message.set_token('MESSAGE', x_msg_data);
      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_data',
				        'OZF done G_EXC_UNEXPECTED_ERROR:' || x_msg_data || '::::');
    WHEN others THEN
      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_data',
					'OZF EXCEPTION OTHERS' || sqlerrm);
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('OZF', 'OZF_SD_FEED_DATA_ERROR');
      fnd_message.set_token('MESSAGE', x_msg_data);
      ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_data',
				        'OZF done OTHERS:' || x_msg_data ||'::::');
  END update_data;

  PROCEDURE PROCESS_CHILD_BATCH(p_batch_id IN NUMBER,
                                x_return_status  OUT nocopy VARCHAR2,
                                x_msg_data       OUT nocopy VARCHAR2) IS

    l_cnt_total_line    NUMBER;
    l_cnt_rejected_line NUMBER;
    l_new_batch_id      NUMBER := NULL;
    l_message           VARCHAR2(1000);
    l_vendor_id         NUMBER;
    l_vendor_site_id    NUMBER;
    l_org_id            NUMBER;
    l_claim_amount      NUMBER;
    l_dup_dispute       NUMBER;
    l_batch_threshold   NUMBER;
    l_line_threshold    NUMBER;
    l_currency_code     VARCHAR2(20);
    l_batch_number      VARCHAR2(20);
    l_par_batch_curr_code VARCHAR2(20);
    l_claim_number      VARCHAR2(30);
    l_claim_id          NUMBER;
    l_claim_minor_version NUMBER;
    l_msg_count         NUMBER;

    l_tot_app_claim_amt NUMBER ;

  BEGIN

    ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::PROCESS_CHILD_BATCH',
					'Procedure Starts: Batch Id :'||p_batch_id);

    SELECT batch_number, vendor_id, vendor_site_id, org_id,
           currency_code, batch_amount_threshold, batch_line_amount_threshold, claim_number, claim_minor_version
      INTO l_batch_number, l_vendor_id, l_vendor_site_id, l_org_id,
           l_par_batch_curr_code, l_batch_threshold, l_line_threshold, l_claim_number, l_claim_minor_version
      FROM ozf_sd_batch_headers_all
     WHERE batch_id = p_batch_id;

    ozf_sd_batch_pvt.create_batch_header(l_vendor_id,
                                         l_vendor_site_id,
                                         l_org_id,
                                         l_batch_threshold,
                                         l_line_threshold,
                                         l_par_batch_curr_code,
					 'F' ,
					 'APPROVED',
					 l_claim_number||'_'||l_claim_minor_version,
					 l_claim_minor_version,
                                         p_batch_id, -- current batch (i.e) parent batch_id
                                         l_new_batch_id);

    UPDATE ozf_sd_batch_lines_all
       SET batch_id = l_new_batch_id,
           object_version_number = object_version_number + 1,
	   last_update_date = sysdate,
	   last_updated_by = fnd_global.user_id
     WHERE batch_id = p_batch_id
       AND status_code = 'APPROVED'
       AND purge_flag <> 'Y';

    --raising business event
    ozf_sd_util_pvt.sd_raise_event (l_new_batch_id, 'CREATE', x_return_status);

    SAVEPOINT BEF_INVOKE_CLM_CHILD_BATCH;

       -- Check if the child batch is having -ve claim sum
    	select sum(batch_curr_claim_amount)
	      INTO l_tot_app_claim_amt
	      from ozf_sd_batch_lines_all
	 where batch_id=l_new_batch_id ;

    IF (l_tot_app_claim_amt)>0 THEN

	 PROCESS_CLAIM(l_new_batch_id, x_return_status, x_msg_data, l_claim_id);

		 IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN -- If claim is successful

			  OZF_SD_UTIL_PVT.CREATE_ADJUSTMENT(l_new_batch_id, 'F', x_return_status, l_msg_count, x_msg_data);

			 IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN -- If adjustment is successful
				--raising business event
				ozf_sd_util_pvt.sd_raise_event (l_new_batch_id, 'CLAIM', x_return_status);
				 UPDATE ozf_sd_batch_headers_all
				       SET status_code           = 'CLOSED',
					   claim_id              = l_claim_id,
					   last_update_date      = sysdate,
					   last_updated_by       = fnd_global.user_id,
					   object_version_number = object_version_number + 1
				     WHERE batch_id = l_new_batch_id;
			 ELSE
			     ROLLBACK TO BEF_INVOKE_CLM_CHILD_BATCH;
			    UPDATE ozf_sd_batch_headers_all
			       SET status_code           = 'PENDING_CLAIM',
				   last_update_date      = sysdate,
				   last_updated_by       = fnd_global.user_id,
				   object_version_number = object_version_number + 1
			     WHERE batch_id = l_new_batch_id;
		      END IF; -- If adjustment is successful

		  ELSE -- If claim is not successful
			    ROLLBACK TO BEF_INVOKE_CLM_CHILD_BATCH;
			    UPDATE ozf_sd_batch_headers_all
			       SET status_code           = 'PENDING_CLAIM',
				   last_update_date      = sysdate,
				   last_updated_by       = fnd_global.user_id,
				   object_version_number = object_version_number + 1
			     WHERE batch_id = l_new_batch_id;
		 END IF; -- If claim is successful

	END IF ;

     ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::PROCESS_CHILD_BATCH',
					'Procedure Ends');

  END PROCESS_CHILD_BATCH;





  PROCEDURE update_dispute_data(p_batch_number varchar2,p_batch_id number) IS

    type v_disputes IS TABLE OF VARCHAR2(50) INDEX BY binary_integer;
    l_disputes      v_disputes;
    l_dispute_index NUMBER(2);

  BEGIN
   ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_dispute_data',
	'Procedure Starts: Batch number -> '||p_batch_number||' Batch Id -> '||p_batch_id );

   FOR v_dispute_code IN (SELECT bl.batch_id,
                              bl.batch_line_id,
                              bint.gbl_claim_rej_code1,
                              bint.gbl_claim_rej_code2,
                              bint.gbl_claim_rej_code3,
                              bint.gbl_claim_rej_code4,
                              bint.gbl_claim_rej_code5,
                              bint.gbl_claim_rej_code6,
                              bint.gbl_claim_rej_code7,
                              bint.gbl_claim_rej_code8,
                              bint.gbl_claim_rej_code9,
                              bint.gbl_claim_rej_code10
                             FROM ozf_sd_batch_lines_all bl,
				  ozf_sd_batch_lines_int_all bint
			    WHERE bl.batch_id = bint.ship_frm_sd_claim_request_id
			      AND bl.batch_line_number = bint.batch_line_number
			      AND bint.GBL_CLAIM_DISPOSITION_CODE = 'REJECTED'
			      AND bint.ship_frm_sd_claim_request_id = p_batch_number
			      AND bint.processed_flag = 'N'
			      AND bl.purge_flag <> 'Y'
			 )

     LOOP


      l_dispute_index := 0;

      IF v_dispute_code.gbl_claim_rej_code1 IS NOT NULL THEN
        l_disputes(l_dispute_index) := v_dispute_code.gbl_claim_rej_code1;
        l_dispute_index := l_dispute_index + 1;
      END IF;

      IF v_dispute_code.gbl_claim_rej_code2 IS NOT NULL THEN
        l_disputes(l_dispute_index) := v_dispute_code.gbl_claim_rej_code2;
        l_dispute_index := l_dispute_index + 1;
      END IF;

      IF v_dispute_code.gbl_claim_rej_code3 IS NOT NULL THEN
        l_disputes(l_dispute_index) := v_dispute_code.gbl_claim_rej_code3;
        l_dispute_index := l_dispute_index + 1;
      END IF;

      IF v_dispute_code.gbl_claim_rej_code4 IS NOT NULL THEN
        l_disputes(l_dispute_index) := v_dispute_code.gbl_claim_rej_code4;
        l_dispute_index := l_dispute_index + 1;
      END IF;

      IF v_dispute_code.gbl_claim_rej_code5 IS NOT NULL THEN
        l_disputes(l_dispute_index) := v_dispute_code.gbl_claim_rej_code5;
        l_dispute_index := l_dispute_index + 1;
      END IF;

      IF v_dispute_code.gbl_claim_rej_code6 IS NOT NULL THEN
        l_disputes(l_dispute_index) := v_dispute_code.gbl_claim_rej_code6;
        l_dispute_index := l_dispute_index + 1;
      END IF;

      IF v_dispute_code.gbl_claim_rej_code7 IS NOT NULL THEN
        l_disputes(l_dispute_index) := v_dispute_code.gbl_claim_rej_code7;
        l_dispute_index := l_dispute_index + 1;
      END IF;

      IF v_dispute_code.gbl_claim_rej_code8 IS NOT NULL THEN
        l_disputes(l_dispute_index) := v_dispute_code.gbl_claim_rej_code8;
        l_dispute_index := l_dispute_index + 1;
      END IF;

      IF v_dispute_code.gbl_claim_rej_code9 IS NOT NULL THEN
        l_disputes(l_dispute_index) := v_dispute_code.gbl_claim_rej_code9;
        l_dispute_index := l_dispute_index + 1;
      END IF;

      IF v_dispute_code.gbl_claim_rej_code10 IS NOT NULL THEN
        l_disputes(l_dispute_index) := v_dispute_code.gbl_claim_rej_code10;
        l_dispute_index := l_dispute_index + 1;
      END IF;

      FOR i IN 0 .. l_dispute_index - 1 LOOP

        INSERT INTO ozf_sd_batch_line_disputes
          (batch_line_dispute_id,
           batch_id,
           batch_line_id,
           object_version_number,
           dispute_code,
           review_flag,
           creation_date,
           last_update_date,
           last_updated_by,
           request_id,
           created_by,
           created_from,
           last_update_login,
           program_application_id,
           program_update_date,
           program_id,
           security_group_id)
        VALUES
          (ozf_sd_batch_line_disputes_s.nextval,
           v_dispute_code.batch_id,
           v_dispute_code.batch_line_id,
           1,
           l_disputes(i),
           NULL, --review flag
           sysdate,
           sysdate,
           fnd_global.user_id,
           fnd_global.conc_request_id,
           fnd_global.user_id,
           NULL, --created from
           fnd_global.conc_login_id,
           fnd_global.prog_appl_id, --l_program_application_id,
           NULL, --l_program_update_date,
           fnd_global.conc_program_id, -- p_Operating_Unit,
           fnd_global.security_group_id);
      END LOOP;
    END LOOP;
   ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::update_dispute_data',
					'Procedure Ends');
  END update_dispute_data;

  PROCEDURE process_claim(p_batch_id IN NUMBER,
                          x_return_status OUT nocopy VARCHAR2,
                          x_msg_data      OUT nocopy VARCHAR2,
			  x_claim_id      OUT NOCOPY NUMBER
			  ) IS

    l_claim_id NUMBER := NULL;
    -- Incase auto claim is run
    l_claim_ret_status VARCHAR2(15) := NULL;
    l_claim_msg_count  NUMBER := NULL;
    l_claim_msg_data   VARCHAR2(500) := NULL;
    l_claim_type       VARCHAR2(20) := 'SUPPLIER';
    --always defaulted to external claim

  BEGIN
  ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::process_claim',
					'Procedure Starts: Batch Id -> '||p_batch_id);
    --call claim API
    ozf_claim_accrual_pvt.initiate_sd_payment(1,
                                              fnd_api.g_false,
                                              fnd_api.g_true,
                                              fnd_api.g_valid_level_full,
                                              l_claim_ret_status,
                                              l_claim_msg_count,
                                              l_claim_msg_data,
                                              p_batch_id,
                                              l_claim_type,
                                              l_claim_id);

  ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::process_claim',
  'Return Status of claim API:   '||l_claim_ret_status ||' Msg: '||l_claim_msg_data || 'Msg Count: '|| l_claim_msg_count);

   FOR I IN 1..l_claim_msg_count LOOP
 	ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_ERROR, 'OZF_SD_BATCH_FEED_PVT::process_claim',
              'Claim API Msg: '||  SUBSTR(FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F'), 1, 254) );
   END LOOP;

     x_return_status := l_claim_ret_status;
     x_msg_data      := l_claim_msg_data;
     x_claim_id      := l_claim_id;

  ozf_utility_pvt.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'OZF_SD_BATCH_FEED_PVT::process_claim',
					'Procedure Ends');
  END process_claim;

 END ozf_sd_batch_feed_pvt;


/
