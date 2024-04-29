--------------------------------------------------------
--  DDL for Package ICX_POR_EXT_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_EXT_TEST" AUTHID CURRENT_USER AS
/* $Header: ICXEXTTS.pls 115.5 2003/07/08 12:16:17 sosingha ship $*/

TEST_USER_ID	PLS_INTEGER := -99999;

--------------------------------------------------------------
--                   Global Variables                       --
--------------------------------------------------------------
gCategorySetId		NUMBER;
gValidateFlag		VARCHAR2(1);
gStructureId		NUMBER;
gTestMode		VARCHAR2(1) := NULL;
gBaseLang		ICX_CAT_ITEMS_TLP.language%TYPE;
gCommitSize		PLS_INTEGER := 2000;

-- Utilities
PROCEDURE setCommitSize(pCommitSize	NUMBER);
PROCEDURE setTestMode(pTestMode		VARCHAR2);
PROCEDURE setTableSpace(pTableTS	VARCHAR2,
                        pIndexTS	VARCHAR2);
PROCEDURE createTables;
PROCEDURE prepare(pCreateTables		VARCHAR2 DEFAULT NULL);
PROCEDURE dropTables;
PROCEDURE cleanupData;
PROCEDURE cleanup;

-- Classification
PROCEDURE createCategory(p_category_id			IN NUMBER,
			 p_concatenated_segments	IN VARCHAR2,
			 p_description			IN VARCHAR2,
			 p_web_status			IN VARCHAR2,
			 p_start_date_active		IN DATE,
			 p_end_date_active		IN DATE,
			 p_disable_date			IN DATE);
PROCEDURE updateCategory(p_category_id			IN NUMBER,
			 p_concatenated_segments	IN VARCHAR2,
			 p_description			IN VARCHAR2,
			 p_web_status			IN VARCHAR2,
			 p_start_date_active		IN DATE,
			 p_end_date_active		IN DATE,
			 p_disable_date			IN DATE);
PROCEDURE translateCategory(p_category_id		IN NUMBER,
			    p_description		IN VARCHAR2,
			    p_language			IN VARCHAR2);
PROCEDURE createTemplateHeader(p_org_id			IN NUMBER,
			       p_express_name		IN VARCHAR2,
			       p_type_lookup_code	IN VARCHAR2,
			       p_inactive_date		IN DATE);
PROCEDURE updateTemplateHeader(p_org_id			IN NUMBER,
			       p_express_name		IN VARCHAR2,
			       p_inactive_date		IN DATE);

FUNCTION existCategory(p_category_key			IN VARCHAR2,
		       p_category_name			IN VARCHAR2,
		       p_category_type			IN NUMBER)
  RETURN BOOLEAN;
FUNCTION notExistCategory(p_category_key		IN VARCHAR2)
  RETURN BOOLEAN;
FUNCTION existCategoryTL(p_category_key			IN VARCHAR2,
			 p_category_name		IN VARCHAR2,
		         p_language			IN VARCHAR2)
  RETURN BOOLEAN;

-- Item
PROCEDURE createGSB(p_set_of_books_id			IN NUMBER,
                    p_currency_code			IN VARCHAR2);

PROCEDURE createFSP(p_org_id				IN NUMBER,
                    p_inventory_organization_id		IN NUMBER,
                    p_set_of_books_id			IN NUMBER);
PROCEDURE createItem(p_inventory_item_id		IN NUMBER,
                     p_organization_id			IN NUMBER,
                     p_concatenated_segments		IN VARCHAR2,
		     p_purchasing_enabled_flag		IN VARCHAR2,
		     p_outside_operation_flag		IN VARCHAR2,
		     p_internal_order_enabled_flag	IN VARCHAR2,
		     p_list_price_per_unit		IN NUMBER,
		     p_primary_uom_code			IN VARCHAR2,
		     p_replenish_to_order_flag		IN VARCHAR2,
		     p_base_item_id			IN NUMBER,
		     p_auto_created_config_flag		IN VARCHAR2,
		     p_unit_of_issue			IN VARCHAR2,
		     p_description			IN VARCHAR2,
		     p_category_id			IN NUMBER);
PROCEDURE updateItem(p_inventory_item_id		IN NUMBER,
                     p_organization_id			IN NUMBER,
                     p_concatenated_segments		IN VARCHAR2,
		     p_purchasing_enabled_flag		IN VARCHAR2,
		     p_outside_operation_flag		IN VARCHAR2,
		     p_internal_order_enabled_flag	IN VARCHAR2,
		     p_list_price_per_unit		IN NUMBER,
		     p_primary_uom_code			IN VARCHAR2,
		     p_replenish_to_order_flag		IN VARCHAR2,
		     p_base_item_id			IN NUMBER,
		     p_auto_created_config_flag		IN VARCHAR2,
		     p_unit_of_issue			IN VARCHAR2,
		     p_description			IN VARCHAR2,
		     p_category_id			IN NUMBER);
PROCEDURE translateItem(p_inventory_item_id		IN NUMBER,
                        p_organization_id		IN NUMBER,
			p_description			IN VARCHAR2,
			p_language			IN VARCHAR2);
PROCEDURE deleteItem(p_inventory_item_id		IN NUMBER,
                     p_organization_id			IN NUMBER);
-- Vendor
PROCEDURE createVendor(p_vendor_id			IN NUMBER,
                       p_vendor_name			IN VARCHAR2);
PROCEDURE updateVendor(p_vendor_id			IN NUMBER,
                       p_vendor_name			IN VARCHAR2);
PROCEDURE createVendorSite(p_vendor_site_id		IN NUMBER,
                           p_vendor_site_code		IN VARCHAR2,
                           p_purchasing_site_flag	IN VARCHAR2);
PROCEDURE updateVendorSite(p_vendor_site_id		IN NUMBER,
                           p_purchasing_site_flag	IN VARCHAR2,
                           p_inactive_date		IN DATE);
-- ASL
PROCEDURE createASL(p_asl_id				IN NUMBER,
                    p_asl_status_id			IN NUMBER,
                    p_owning_organization_id		IN NUMBER,
		    p_item_id				IN NUMBER,
		    p_category_id			IN NUMBER,
		    p_vendor_id				IN NUMBER,
		    p_vendor_site_id			IN NUMBER,
		    p_primary_vendor_item		IN VARCHAR2,
		    p_disable_flag			IN VARCHAR2,
		    p_allow_action_flag			IN VARCHAR2,
		    p_purchasing_unit_of_measure	IN VARCHAR2);
PROCEDURE updateASL(p_asl_id				IN NUMBER,
                    p_asl_status_id			IN NUMBER,
		    p_vendor_site_id			IN NUMBER,
		    p_primary_vendor_item		IN VARCHAR2,
		    p_disable_flag			IN VARCHAR2,
		    p_allow_action_flag			IN VARCHAR2,
		    p_purchasing_unit_of_measure	IN VARCHAR2);
-- Template Line
PROCEDURE createTemplateLine(p_org_id			IN NUMBER,
			     p_express_name		IN VARCHAR2,
			     p_sequence_num		IN NUMBER,
			     p_source_type_code		IN VARCHAR2,
			     p_po_header_id		IN NUMBER,
			     p_po_line_id		IN NUMBER,
			     p_item_id			IN NUMBER,
			     p_category_id		IN NUMBER,
			     p_item_description		IN VARCHAR2,
			     p_unit_price		IN NUMBER,
			     p_unit_meas_lookup_code	IN VARCHAR2,
			     p_suggested_vendor_id	IN NUMBER,
			     p_suggested_vendor_site_id	IN NUMBER,
			     p_vendor_product_code 	IN VARCHAR2);
-- FPJ Bug# 3007068 sosingha: Extractor Changes For Kit Support Project
-- Overload Template Line to accept Suggested Quantity
PROCEDURE createTemplateLine(p_org_id                   IN NUMBER,
                             p_express_name             IN VARCHAR2,
                             p_sequence_num             IN NUMBER,
                             p_source_type_code         IN VARCHAR2,
                             p_po_header_id             IN NUMBER,
                             p_po_line_id               IN NUMBER,
                             p_item_id                  IN NUMBER,
                             p_category_id              IN NUMBER,
                             p_item_description         IN VARCHAR2,
                             p_unit_price               IN NUMBER,
                              -- FPJ Bug# 3007068 sosingha: Extractor Changes for Kit Support project
                             p_suggested_quantity       IN NUMBER,
                             p_unit_meas_lookup_code    IN VARCHAR2,
                             p_suggested_vendor_id      IN NUMBER,
                             p_suggested_vendor_site_id IN NUMBER,
                             p_vendor_product_code      IN VARCHAR2);
PROCEDURE updateTemplateLine(p_org_id			IN NUMBER,
			     p_express_name		IN VARCHAR2,
			     p_sequence_num		IN NUMBER,
			     p_po_header_id		IN NUMBER,
			     p_po_line_id		IN NUMBER,
			     p_item_description		IN VARCHAR2,
			     p_unit_price		IN NUMBER,
                             -- FPJ Bug# 3007068 sosingha: Extractor Changes for Kit Support project
                             p_suggested_quantity       IN NUMBER,
			     p_unit_meas_lookup_code	IN VARCHAR2,
			     p_suggested_vendor_site_id	IN NUMBER,
			     p_vendor_product_code 	IN VARCHAR2);

-- Contract
PROCEDURE createContractHeader(p_po_header_id		IN NUMBER,
			       p_org_id			IN NUMBER,
			       p_segment1		IN VARCHAR2,
			       p_type_lookup_code	IN VARCHAR2,
			       p_rate			IN NUMBER,
			       p_currency_code		IN VARCHAR2,
			       p_vendor_id		IN NUMBER,
			       p_vendor_site_id		IN NUMBER,
			       p_approved_date		IN DATE,
			       p_approved_flag		IN VARCHAR2,
			       p_approval_required_flag	IN VARCHAR2,
			       p_cancel_flag		IN VARCHAR2,
			       p_frozen_flag		IN VARCHAR2,
			       p_closed_code		IN VARCHAR2,
			       p_status_lookup_code	IN VARCHAR2,
			       p_quotation_class_code	IN VARCHAR2,
			       p_start_date		IN DATE,
			       p_end_date		IN DATE,
			       p_global_agreement_flag	IN VARCHAR2);
PROCEDURE createContractLine(p_po_header_id		IN NUMBER,
			     p_po_line_id		IN NUMBER,
			     p_org_id			IN NUMBER,
			     p_line_num			IN NUMBER,
			     p_item_id			IN NUMBER,
			     p_item_description		IN VARCHAR2,
			     p_vendor_product_num	IN VARCHAR2,
			     p_line_type_id		IN NUMBER,
			     p_category_id		IN NUMBER,
			     p_unit_price		IN NUMBER,
			     p_unit_meas_lookup_code	IN VARCHAR2,
			     p_attribute13		IN VARCHAR2,
			     p_attribute14		IN VARCHAR2,
			     p_cancel_flag 		IN VARCHAR2,
			     p_closed_code		IN VARCHAR2,
			     p_expiration_date		IN DATE,
			     p_outside_operation_flag	IN VARCHAR2);
-- FPJ FPSL Extractor Changes
-- Add 5 parameters for Amount, Allow Price Override Flag,
-- Not to Exceed Price, Value Basis, Purchase Basis
-- Create a contract line
PROCEDURE createContractLine(p_po_header_id             IN NUMBER,
                             p_po_line_id               IN NUMBER,
                             p_org_id                   IN NUMBER,
                             p_line_num                 IN NUMBER,
                             p_item_id                  IN NUMBER,
                             p_item_description         IN VARCHAR2,
                             p_vendor_product_num       IN VARCHAR2,
                             p_line_type_id             IN NUMBER,
                             p_category_id              IN NUMBER,
                             p_unit_price               IN NUMBER,
                             p_unit_meas_lookup_code    IN VARCHAR2,
                             p_attribute13              IN VARCHAR2,
                             p_attribute14              IN VARCHAR2,
                             p_cancel_flag              IN VARCHAR2,
                             p_closed_code              IN VARCHAR2,
                             p_expiration_date          IN DATE,
                             p_outside_operation_flag   IN VARCHAR2,
                             p_amount                   IN NUMBER,
                             p_allow_price_override_flag IN VARCHAR2,
                             p_not_to_exceed_price      IN NUMBER,
                             p_value_basis              IN VARCHAR2,
                             p_purchase_basis           IN VARCHAR2);
PROCEDURE updateContractHeader(p_po_header_id		IN NUMBER,
			       p_rate			IN NUMBER,
			       p_currency_code		IN VARCHAR2,
			       p_vendor_site_id		IN NUMBER,
			       p_approved_date		IN DATE,
			       p_approved_flag		IN VARCHAR2,
			       p_approval_required_flag	IN VARCHAR2,
			       p_cancel_flag		IN VARCHAR2,
			       p_frozen_flag		IN VARCHAR2,
			       p_closed_code		IN VARCHAR2,
			       p_start_date		IN DATE,
			       p_end_date		IN DATE,
			       p_global_agreement_flag	IN VARCHAR2);
PROCEDURE updateContractLine(p_po_line_id		IN NUMBER,
			     p_item_description		IN VARCHAR2,
			     p_vendor_product_num	IN VARCHAR2,
			     p_line_type_id		IN NUMBER,
			     p_category_id		IN NUMBER,
			     p_unit_price		IN NUMBER,
			     p_unit_meas_lookup_code	IN VARCHAR2,
			     p_attribute13		IN VARCHAR2,
			     p_attribute14		IN VARCHAR2,
			     p_cancel_flag 		IN VARCHAR2,
			     p_closed_code		IN VARCHAR2,
			     p_creation_date		IN DATE,
			     p_expiration_date		IN DATE,
			     p_outside_operation_flag	IN VARCHAR2);
-- Update a contract line
-- FPJ FPSL Extractor Changes
-- Add 3 parameters for Amount, Allow Price Override Flag and Not to Exceed Price
PROCEDURE updateContractLine(p_po_line_id               IN NUMBER,
                             p_item_description         IN VARCHAR2,
                             p_vendor_product_num       IN VARCHAR2,
                             p_line_type_id             IN NUMBER,
                             p_category_id              IN NUMBER,
                             p_unit_price               IN NUMBER,
                             p_unit_meas_lookup_code    IN VARCHAR2,
                             p_attribute13              IN VARCHAR2,
                             p_attribute14              IN VARCHAR2,
                             p_cancel_flag              IN VARCHAR2,
                             p_closed_code              IN VARCHAR2,
                             p_creation_date            IN DATE,
                             p_expiration_date          IN DATE,
                             p_outside_operation_flag   IN VARCHAR2,
                             p_amount                   IN NUMBER,
                             p_allow_price_override_flag        IN VARCHAR2,
                             p_not_to_exceed_price      IN NUMBER);
PROCEDURE createQuoteLL(p_line_location_id		IN NUMBER,
		        p_po_line_id			IN NUMBER,
			p_start_date			IN DATE,
			p_end_date			IN DATE,
			p_approval_type			IN VARCHAR2,
			p_start_date_active		IN DATE,
			p_end_date_active		IN DATE);
PROCEDURE updateQuoteLL(p_line_location_id		IN NUMBER,
			p_start_date			IN DATE,
			p_end_date			IN DATE,
			p_approval_type			IN VARCHAR2,
			p_start_date_active		IN DATE,
			p_end_date_active		IN DATE);
PROCEDURE createGlobalA(p_po_header_id			IN NUMBER,
		        p_organization_id		IN NUMBER,
			p_enabled_flag			IN VARCHAR2,
			p_vendor_site_id		IN NUMBER,
			p_purchasing_org_id		IN NUMBER);
PROCEDURE updateGlobalA(p_po_header_id			IN NUMBER,
		        p_organization_id		IN NUMBER,
			p_enabled_flag			IN VARCHAR2,
			p_vendor_site_id		IN NUMBER,
			p_purchasing_org_id		IN NUMBER);

FUNCTION existItemsB(p_rt_item_id			OUT NOCOPY NUMBER,
		     p_org_id				IN NUMBER,
		     p_supplier_id			IN NUMBER,
		     p_supplier				IN VARCHAR2,
		     p_supplier_part_num		IN VARCHAR2,
		     p_internal_item_id			IN NUMBER,
		     p_internal_item_num		IN VARCHAR2,
		     p_extractor_updated_flag		IN VARCHAR2,
		     p_internal_flag			IN VARCHAR2 DEFAULT NULL)
  RETURN BOOLEAN;
FUNCTION notExistItemsB(p_org_id			IN NUMBER,
		        p_supplier_id			IN NUMBER,
		        p_supplier_part_num		IN VARCHAR2,
		        p_internal_item_id		IN NUMBER,
		        p_internal_flag			IN VARCHAR2 DEFAULT NULL)
  RETURN BOOLEAN;
FUNCTION existItemsTLP(p_rt_item_id			IN NUMBER,
		       p_language			IN VARCHAR2,
		       p_item_source_type		IN VARCHAR2,
		       p_search_type			IN VARCHAR2,
		       p_primary_category_id		OUT NOCOPY NUMBER,
		       p_primary_category_name		IN VARCHAR2,
		       p_internal_item_id		IN NUMBER,
		       p_internal_item_num		IN VARCHAR2,
		       p_supplier_id			IN NUMBER,
		       p_supplier			IN VARCHAR2,
		       p_supplier_part_num		IN VARCHAR2,
		       p_description			IN VARCHAR2,
		       p_picture			IN VARCHAR2,
		       p_picture_url			IN VARCHAR2)
  RETURN BOOLEAN;
FUNCTION notExistItemsTLP(p_rt_item_id			IN NUMBER,
		          p_language			IN VARCHAR2)
  RETURN BOOLEAN;
FUNCTION existCateoryItems(p_rt_item_id			IN NUMBER,
		           p_rt_category_id		IN NUMBER)
  RETURN BOOLEAN;
FUNCTION notExistCateoryItems(p_rt_item_id		IN NUMBER,
		              p_rt_category_id		IN NUMBER)
  RETURN BOOLEAN;
FUNCTION existExtItemsTLP(p_rt_item_id			IN NUMBER,
		          p_rt_category_id		IN NUMBER)
  RETURN BOOLEAN;
FUNCTION notExistExtItemsTLP(p_rt_item_id		IN NUMBER,
		             p_rt_category_id		IN NUMBER)
  RETURN BOOLEAN;
FUNCTION existItemPrices(p_rt_item_id			IN NUMBER,
		         p_org_id			IN VARCHAR2,
		         p_price_type			IN VARCHAR2,
		         p_active_flag			IN VARCHAR2,
		         p_asl_id			IN NUMBER,
		         p_contract_id			IN VARCHAR2,
		         p_contract_line_id		IN NUMBER,
		         p_template_id			IN VARCHAR2,
		         p_template_line_id		IN NUMBER,
		         p_inventory_item_id		IN VARCHAR2,
		         p_mtl_category_id		IN VARCHAR2,
		         p_search_type			IN VARCHAR2,
		         p_unit_price			IN VARCHAR2,
		         p_currency			IN VARCHAR2,
		         p_unit_of_measure		IN VARCHAR2,
		         p_supplier_site_id		IN VARCHAR2,
		         p_supplier_site_code		IN VARCHAR2,
		         p_contract_num			IN VARCHAR2,
		         p_contract_line_num		IN NUMBER,
		         p_local_rt_item_id		IN NUMBER DEFAULT NULL)
  RETURN BOOLEAN;
FUNCTION notExistItemPrices(p_rt_item_id		IN NUMBER,
		            p_org_id			IN VARCHAR2,
		            p_price_type		IN VARCHAR2,
		            p_active_flag		IN VARCHAR2,
		            p_asl_id			IN NUMBER,
		            p_contract_id		IN VARCHAR2,
		            p_contract_line_id		IN NUMBER,
		            p_template_id		IN VARCHAR2,
		            p_template_line_id		IN NUMBER,
		            p_inventory_item_id		IN VARCHAR2)
  RETURN BOOLEAN;

-- FPJ Bug# 3007068 sosingha: Extractor Changes For Kit Support Project
FUNCTION checkSuggestedQuantity(p_rt_item_id   IN NUMBER,
                                p_org_id               IN VARCHAR2,
                                p_price_type           IN VARCHAR2,
                                p_active_flag          IN VARCHAR2,
                                p_template_id          IN VARCHAR2,
                                p_template_line_id     IN NUMBER,
                                p_inventory_item_id    IN VARCHAR2,
                                p_mtl_category_id      IN VARCHAR2,
                                -- FPJ Bug# 3007068 sosingha: Extractor Changes for Kit Support Project
                                p_suggested_quantity   IN NUMBER,
                                p_local_rt_item_id     IN NUMBER)
  RETURN BOOLEAN;


END ICX_POR_EXT_TEST;

 

/
