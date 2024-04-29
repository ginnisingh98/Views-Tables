--------------------------------------------------------
--  DDL for Package ZX_TAX_DEFAULT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TAX_DEFAULT_PKG" AUTHID CURRENT_USER as
/* $Header: zxdidefhierpvts.pls 120.8 2005/12/15 01:18:08 pla ship $ */

/************** Bug#4868489 ***************
TYPE def_info_rec_type IS RECORD (
--         line_location_id	         NUMBER,
         ref_doc_application_id          zx_lines_det_factors.ref_doc_application_id%TYPE,
         ref_doc_entity_code             zx_lines_det_factors.ref_doc_entity_code%TYPE,
         ref_doc_event_class_code        zx_lines_det_factors.ref_doc_event_class_code%TYPE,
         ref_doc_trx_id                  zx_lines_det_factors.ref_doc_trx_id%TYPE,
         ref_doc_line_id                 zx_lines_det_factors.ref_doc_line_id%TYPE,
         ref_doc_trx_level_type          zx_lines_det_factors.ref_doc_trx_level_type%TYPE,
         vendor_id		         NUMBER,
         vendor_site_id 		 NUMBER,
         code_combination_id  	         NUMBER,
         concatenated_segments	         VARCHAR2(2000),
         templ_tax_classification_code   zx_lines_det_factors.input_tax_classification_code%TYPE,
         ship_to_location_id	         NUMBER,
         ship_to_loc_org_id   	         NUMBER,
         inventory_item_id   	         NUMBER,
         item_org_id     	         NUMBER,
         input_tax_classification_code	 zx_lines_det_factors.input_tax_classification_code%TYPE,
         output_tax_classification_code  zx_lines_det_factors.output_tax_classification_code%TYPE,
         tax_user_override_flag          VARCHAR2(1),
         allow_tax_code_override_flag    VARCHAR2(1),
         user_tax_name                   zx_lines_det_factors.input_tax_classification_code%TYPE,
         application_id                  NUMBER,
         internal_organization_id        NUMBER,
         legal_entity_id                 zx_lines.legal_entity_id%TYPE,
         appl_short_name	         VARCHAR2(10),
         func_short_name	         VARCHAR2(10),
         calling_sequence	         VARCHAR2(2000),
         event_class_code                zx_evnt_cls_mappings.event_class_code%type,
         entity_code                     zx_evnt_cls_mappings.entity_code%type,
         ship_to_site_use_id             NUMBER,
         bill_to_site_use_id             NUMBER,
         organization_id                 NUMBER,
         set_of_books_id                 NUMBER,
         trx_date                        DATE,
         trx_type_id                     NUMBER,
         cust_trx_id                     NUMBER,
         cust_trx_line_id                NUMBER,
         customer_id                     NUMBER,
         memo_line_id                    NUMBER,
         party_flag                      VARCHAR2(1),
         party_location_id               VARCHAR2(30),
         project_id                      NUMBER,
         project_customer_id             NUMBER,
         event_id                        NUMBER,
         expenditure_item_id             NUMBER,
         line_type                       VARCHAR2(30),
         request_id                      NUMBER,
         user_id                         NUMBER,
         ship_to_customer_id             NUMBER,
         bill_to_customer_id             NUMBER);

  definfo def_info_rec_type;
***********************************/

PROCEDURE get_default_tax_classification (
    p_definfo               IN OUT NOCOPY  ZX_API_PUB.def_tax_cls_code_info_rec_type,
    p_return_status            OUT NOCOPY  VARCHAR2,
    p_error_buffer             OUT NOCOPY  VARCHAR2);


END ZX_TAX_DEFAULT_PKG;

 

/
