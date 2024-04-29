--------------------------------------------------------
--  DDL for Package ZX_DEFAULT_AUTOMATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_DEFAULT_AUTOMATION_PKG" AUTHID CURRENT_USER as
/* $Header: zxdidefautopvts.pls 120.6 2006/11/10 15:35:19 vramamur ship $ */

/*  The following is a list of tax determine attributes that will be defaulted by defaulting
    automation.

         default_taxation_country        zx_lines_det_factors.default_taxation_country%type,
         document_sub_type		 zx_lines_det_factors.document_sub_type%type,
         trx_business_categoary		 zx_lines_det_factors.trx_business_categoary%type,
         line_intended_use		 zx_lines_det_factors.line_intended_use%type,
         product_fisc_classification	 zx_lines_det_factors.product_fisc_classification%type,
         product_category		 zx_lines_det_factors.product_category%type,
         assessable_value		 zx_lines_det_factors.assessable_value%type,
         user_defined_fisc_class	 zx_lines_det_factors.user_defined_fisc_class%type,
         product_type   	         zx_lines_det_factors.product_type%type,
         tax_classification_code   	 zx_lines_det_factors.tax_classification_code);
*/

/* =================================================================================*
 | defaulting_automation  - to be called by  lines determine factors UI and         |
 |                          calculate_tax API                                       |
 | Expected input trx line information should have been populated in                |
 | ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.                                      |
                                       					    	    |
 * ================================================================================*/


-- This is the main wrapper procedure
PROCEDURE DEFAULT_TAX_ATTRIBS
(
  p_trx_line_index         IN	         BINARY_INTEGER,
  p_event_class_rec        IN OUT NOCOPY ZX_API_PUB.event_class_rec_type,
  p_taxation_country	   IN            VARCHAR2,
  p_document_sub_type	   IN            VARCHAR2,
  p_tax_invoice_number     IN            VARCHAR2,
  p_tax_invoice_date       IN            DATE,
  x_return_status          OUT NOCOPY    VARCHAR2
);

PROCEDURE DEFAULT_TAX_DET_FACTORS
(
  p_trx_line_index         IN	         BINARY_INTEGER,
  p_event_class_rec        IN OUT NOCOPY ZX_API_PUB.event_class_rec_type,
  p_taxation_country	   IN            VARCHAR2,
  p_document_sub_type	   IN            VARCHAR2,
  x_return_status          OUT NOCOPY    VARCHAR2
);

PROCEDURE DEFAULT_TAX_REPORTING_ATTRIBS
(
  p_trx_line_index         IN  BINARY_INTEGER,
  p_tax_invoice_number     IN  VARCHAR2,
  p_tax_invoice_date       IN  DATE,
  x_return_status          OUT NOCOPY    VARCHAR2
);

PROCEDURE DEFAULT_TAX_CLASSIFICATION
(
  p_trx_line_index        IN  BINARY_INTEGER,
  x_return_status         OUT NOCOPY VARCHAR2
);

PROCEDURE GET_DEFAULT_COUNTRY_CODE
(
  p_tax_method_code      IN            VARCHAR2,
  p_internal_org_id      IN            NUMBER,
  p_legal_entity_id      IN            NUMBER,
  x_country_code            OUT NOCOPY VARCHAR2,
  x_return_status           OUT NOCOPY VARCHAR2
);

-- Re-defaulting APIs
--
PROCEDURE redefault_intended_use(
  p_application_id       IN            NUMBER,
  p_entity_code          IN            VARCHAR2,
  p_event_class_code     IN            VARCHAR2,
  p_internal_org_id      IN            NUMBER,
  p_country_code         IN            VARCHAR2,
  p_item_id              IN            NUMBER,
  p_item_org_id          IN            NUMBER,
  x_intended_use            OUT NOCOPY VARCHAR2,
  x_return_status           OUT NOCOPY VARCHAR2);

PROCEDURE redefault_prod_fisc_class_code(
  p_application_id       IN            NUMBER,
  p_entity_code          IN            VARCHAR2,
  p_event_class_code     IN            VARCHAR2,
  p_internal_org_id      IN            NUMBER,
  p_country_code         IN            VARCHAR2,
  p_item_id              IN            NUMBER,
  p_item_org_id          IN            NUMBER,
  x_prod_fisc_class_code    OUT NOCOPY VARCHAR2,
  x_return_status           OUT NOCOPY VARCHAR2);

PROCEDURE redefault_assessable_value(
  p_application_id       IN            NUMBER,
  p_entity_code          IN            VARCHAR2,
  p_event_class_code     IN            VARCHAR2,
  p_internal_org_id      IN            NUMBER,
  p_trx_id               IN            NUMBER,
  p_trx_line_id          IN            NUMBER,
  p_trx_level_type       IN            VARCHAR2,
  p_item_id              IN            NUMBER,
  p_item_org_id          IN            NUMBER,
  p_line_amt             IN            NUMBER,
  x_assessable_value        OUT NOCOPY NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2);

 PROCEDURE default_tax_attributes_for_po(
  p_trx_line_index       IN	         BINARY_INTEGER,
  x_return_status        OUT NOCOPY    VARCHAR2);

END ZX_DEFAULT_AUTOMATION_PKG;

 

/
