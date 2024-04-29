--------------------------------------------------------
--  DDL for Package ZX_AP_TAX_CLASSIFICATN_DEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_AP_TAX_CLASSIFICATN_DEF_PKG" AUTHID CURRENT_USER as
/* $Header: zxaptxclsdefpkgs.pls 120.10.12010000.3 2009/08/11 15:45:43 tsen ship $ */

TYPE system_info_rec_type IS RECORD
(
  --
  -- This record holds general information used by the Tax Defaulting handler
  -- and its associated functions.
  --
	ap_info			zx_product_options_all%ROWTYPE,
	po_info			zx_product_options_all%ROWTYPE,
	cc_info			zx_product_options_all%ROWTYPE, -- Bug 6510307
	set_of_books_id       gl_sets_of_books.set_of_books_id%TYPE, --Bug 8353620
	chart_of_accounts_id	gl_sets_of_books.chart_of_accounts_id%TYPE,
	org_id			financials_system_parameters.org_id%TYPE
);
sysinfo	system_info_rec_type;

TYPE TaxHierTabType IS TABLE OF VARCHAR2(100)
     INDEX BY BINARY_INTEGER;

aptaxtab TaxHierTabType;
potaxtab TaxHierTabType;
cctaxtab TaxHierTabType; -- Bug 6510307

ap_info				zx_product_options_all%ROWTYPE;
po_info				zx_product_options_all%ROWTYPE;
cc_info				zx_product_options_all%ROWTYPE; -- Bug 6510307

-- get_default_tax_code is replaced by get_default_tax_classification
procedure get_default_tax_classification
(
--p_line_location_id		IN  po_line_locations.line_location_id%TYPE,
 p_ref_doc_application_id       IN  zx_lines_det_factors.ref_doc_application_id%TYPE,
 p_ref_doc_entity_code          IN  zx_lines_det_factors.ref_doc_entity_code%TYPE,
 p_ref_doc_event_class_code     IN  zx_lines_det_factors.ref_doc_event_class_code%TYPE,
 p_ref_doc_trx_id               IN  zx_lines_det_factors.ref_doc_trx_id%TYPE,
 p_ref_doc_line_id              IN  zx_lines_det_factors.ref_doc_line_id%TYPE,
 p_ref_doc_trx_level_type       IN  zx_lines_det_factors.ref_doc_trx_level_type%TYPE,
 p_vendor_id			IN  po_vendors.vendor_id%TYPE,
 p_vendor_site_id 		IN  po_vendor_sites.vendor_site_id%TYPE,
 p_code_combination_id  	IN  gl_code_combinations.code_combination_id%TYPE,
 p_concatenated_segments	IN  varchar2,
 p_templ_tax_classification_cd  IN  varchar2,
 p_ship_to_location_id		IN  hr_locations_all.location_id%TYPE,
 p_ship_to_loc_org_id   	IN  mtl_system_items.organization_id%TYPE,
 p_inventory_item_id   		IN  mtl_system_items.inventory_item_id%TYPE,
 p_item_org_id     		IN  mtl_system_items.organization_id%TYPE,
 p_tax_classification_code	IN  OUT NOCOPY varchar2,
 p_allow_tax_code_override_flag     OUT NOCOPY zx_acct_tx_cls_defs.allow_tax_code_override_flag%TYPE,
 p_legal_entity_id              IN  zx_lines.legal_entity_id%TYPE,
 APPL_SHORT_NAME		IN  fnd_application.application_short_name%TYPE,
 FUNC_SHORT_NAME		IN  VARCHAR2,
 p_calling_sequence		IN  VARCHAR2,
 p_event_class_code             IN  VARCHAR2,
 p_entity_code                  IN  VARCHAR2,
 p_application_id               IN  NUMBER,
 p_internal_organization_id     IN  NUMBER);

-- get_default_tax_code is replaced by get_default_tax_classification
procedure get_default_tax_classification
(
--p_line_location_id		IN  po_line_locations.line_location_id%TYPE,
p_ref_doc_application_id        IN  zx_lines_det_factors.ref_doc_application_id%TYPE,
p_ref_doc_entity_code           IN  zx_lines_det_factors.ref_doc_entity_code%TYPE,
p_ref_doc_event_class_code      IN  zx_lines_det_factors.ref_doc_event_class_code%TYPE,
p_ref_doc_trx_id                IN  zx_lines_det_factors.ref_doc_trx_id%TYPE,
p_ref_doc_line_id               IN  zx_lines_det_factors.ref_doc_line_id%TYPE,
p_ref_doc_trx_level_type        IN  zx_lines_det_factors.ref_doc_trx_level_type%TYPE,
p_vendor_id			IN  po_vendors.vendor_id%TYPE,
p_vendor_site_id 		IN  po_vendor_sites.vendor_site_id%TYPE,
p_code_combination_id  		IN  gl_code_combinations.code_combination_id%TYPE,
p_concatenated_segments		IN  varchar2,
p_templ_tax_classification_cd   IN  varchar2,
p_ship_to_location_id		IN  hr_locations_all.location_id%TYPE,
p_ship_to_loc_org_id   		IN  mtl_system_items.organization_id%TYPE,
p_inventory_item_id   		IN  mtl_system_items.inventory_item_id%TYPE,
p_item_org_id     		IN  mtl_system_items.organization_id%TYPE,
p_tax_classification_code	IN  OUT NOCOPY varchar2,
p_allow_tax_code_override_flag      OUT NOCOPY zx_acct_tx_cls_defs.allow_tax_code_override_flag%TYPE,
p_tax_user_override_flag       	IN  VARCHAR2,
p_user_tax_name                	IN  varchar2,
p_legal_entity_id               IN  zx_lines.legal_entity_id%TYPE,
APPL_SHORT_NAME			IN  fnd_application.application_short_name%TYPE,
FUNC_SHORT_NAME			IN  VARCHAR2,
p_calling_sequence		IN  VARCHAR2,
p_event_class_code              IN  VARCHAR2,
p_entity_code                   IN  VARCHAR2,
p_application_id                IN  NUMBER,
p_internal_organization_id      IN  NUMBER);

FUNCTION  get_input_tax_classif_code (
 --p_line_location_id		IN  po_line_locations.line_location_id%TYPE,
 p_ref_doc_application_id       IN  zx_lines_det_factors.ref_doc_application_id%TYPE,
 p_ref_doc_entity_code          IN  zx_lines_det_factors.ref_doc_entity_code%TYPE,
 p_ref_doc_event_class_code     IN  zx_lines_det_factors.ref_doc_event_class_code%TYPE,
 p_ref_doc_trx_id               IN  zx_lines_det_factors.ref_doc_trx_id%TYPE,
 p_ref_doc_line_id              IN  zx_lines_det_factors.ref_doc_line_id%TYPE,
 p_ref_doc_trx_level_type       IN  zx_lines_det_factors.ref_doc_trx_level_type%TYPE,
 p_calling_sequence		IN VARCHAR2 )

  RETURN VARCHAR2;

FUNCTION  get_site_tax (
 p_vendor_site_id		IN  po_vendor_sites.vendor_site_id%TYPE,
 p_calling_sequence		IN VARCHAR2 )

  RETURN VARCHAR2;

FUNCTION  get_vendor_tax (
 p_vendor_id			IN  po_vendors.vendor_id%TYPE,
 p_calling_sequence		IN VARCHAR2)

RETURN VARCHAR2;

FUNCTION  get_ship_to_location_tax (
 p_ship_to_loc_id		IN  hr_locations_all.location_id%TYPE,
 p_ship_to_loc_org_id		IN  hr_locations_all.inventory_organization_id%TYPE,
 p_legal_entity_id              IN  zx_lines.legal_entity_id%TYPE,
 p_calling_sequence		IN VARCHAR2)

RETURN VARCHAR2;

FUNCTION  get_item_tax (
 p_item_id			IN  mtl_system_items.inventory_item_id%TYPE,
 p_ship_to_loc_org_id		IN  mtl_system_items.organization_id%TYPE,
 p_item_org_id			IN  mtl_system_items.organization_id%TYPE,
 p_calling_sequence		IN VARCHAR2)

  RETURN VARCHAR2;

PROCEDURE  get_account_tax (
 p_code_combination_id 		IN  gl_code_combinations.code_combination_id%TYPE,
 p_concatenated_segments	IN  varchar2,
 p_tax_classification_code	IN  OUT NOCOPY varchar2,
 p_allow_tax_code_override_flag OUT NOCOPY zx_acct_tx_cls_defs.allow_tax_code_override_flag%TYPE,
 p_tax_classification_found	IN  OUT NOCOPY boolean,
 p_calling_sequence		IN  VARCHAR2);

-- bug#4891362- add overloaded versions :

procedure get_default_tax_classification
(
 p_ref_doc_application_id       IN  zx_lines_det_factors.ref_doc_application_id%TYPE,
 p_ref_doc_entity_code          IN  zx_lines_det_factors.ref_doc_entity_code%TYPE,
 p_ref_doc_event_class_code     IN  zx_lines_det_factors.ref_doc_event_class_code%TYPE,
 p_ref_doc_trx_id               IN  zx_lines_det_factors.ref_doc_trx_id%TYPE,
 p_ref_doc_line_id              IN  zx_lines_det_factors.ref_doc_line_id%TYPE,
 p_ref_doc_trx_level_type       IN  zx_lines_det_factors.ref_doc_trx_level_type%TYPE,
 p_vendor_id			IN  po_vendors.vendor_id%TYPE,
 p_vendor_site_id 		IN  po_vendor_sites.vendor_site_id%TYPE,
 p_code_combination_id  	IN  gl_code_combinations.code_combination_id%TYPE,
 p_concatenated_segments	IN  varchar2,
 p_templ_tax_classification_cd  IN  varchar2,
 p_ship_to_location_id		IN  hr_locations_all.location_id%TYPE,
 p_ship_to_loc_org_id   	IN  mtl_system_items.organization_id%TYPE,
 p_inventory_item_id   		IN  mtl_system_items.inventory_item_id%TYPE,
 p_item_org_id     		IN  mtl_system_items.organization_id%TYPE,
 p_tax_classification_code	IN  OUT NOCOPY varchar2,
 p_allow_tax_code_override_flag     OUT NOCOPY zx_acct_tx_cls_defs.allow_tax_code_override_flag%TYPE,
-- p_legal_entity_id              IN  zx_lines.legal_entity_id%TYPE,
 APPL_SHORT_NAME		IN  fnd_application.application_short_name%TYPE,
 FUNC_SHORT_NAME		IN  VARCHAR2,
 p_calling_sequence		IN  VARCHAR2,
 p_event_class_code             IN  VARCHAR2,
 p_entity_code                  IN  VARCHAR2,
 p_application_id               IN  NUMBER,
 p_internal_organization_id     IN  NUMBER);

procedure get_default_tax_classification
(
p_ref_doc_application_id        IN  zx_lines_det_factors.ref_doc_application_id%TYPE,
p_ref_doc_entity_code           IN  zx_lines_det_factors.ref_doc_entity_code%TYPE,
p_ref_doc_event_class_code      IN  zx_lines_det_factors.ref_doc_event_class_code%TYPE,
p_ref_doc_trx_id                IN  zx_lines_det_factors.ref_doc_trx_id%TYPE,
p_ref_doc_line_id               IN  zx_lines_det_factors.ref_doc_line_id%TYPE,
p_ref_doc_trx_level_type        IN  zx_lines_det_factors.ref_doc_trx_level_type%TYPE,
p_vendor_id			IN  po_vendors.vendor_id%TYPE,
p_vendor_site_id 		IN  po_vendor_sites.vendor_site_id%TYPE,
p_code_combination_id  		IN  gl_code_combinations.code_combination_id%TYPE,
p_concatenated_segments		IN  varchar2,
p_templ_tax_classification_cd   IN  varchar2,
p_ship_to_location_id		IN  hr_locations_all.location_id%TYPE,
p_ship_to_loc_org_id   		IN  mtl_system_items.organization_id%TYPE,
p_inventory_item_id   		IN  mtl_system_items.inventory_item_id%TYPE,
p_item_org_id     		IN  mtl_system_items.organization_id%TYPE,
p_tax_classification_code	IN  OUT NOCOPY varchar2,
p_allow_tax_code_override_flag      OUT NOCOPY zx_acct_tx_cls_defs.allow_tax_code_override_flag%TYPE,
p_tax_user_override_flag       	IN  VARCHAR2,
p_user_tax_name                	IN  varchar2,
--p_legal_entity_id               IN  zx_lines.legal_entity_id%TYPE,
APPL_SHORT_NAME			IN  fnd_application.application_short_name%TYPE,
FUNC_SHORT_NAME			IN  VARCHAR2,
p_calling_sequence		IN  VARCHAR2,
p_event_class_code              IN  VARCHAR2,
p_entity_code                   IN  VARCHAR2,
p_application_id                IN  NUMBER,
p_internal_organization_id      IN  NUMBER);


FUNCTION  get_ship_to_location_tax (
 p_ship_to_loc_id               IN  hr_locations_all.location_id%TYPE,
 p_ship_to_loc_org_id           IN  hr_locations_all.inventory_organization_id%TYPE,
-- p_legal_entity_id              IN  zx_lines.legal_entity_id%TYPE,
 p_calling_sequence             IN VARCHAR2)
RETURN VARCHAR2;

-- get_default_tax_code is replaced by get_default_tax_classification
-- bug#8717533
procedure get_def_tax_classif_from_acc
(
   p_ref_doc_application_id             IN  zx_lines_det_factors.ref_doc_application_id%TYPE,
   p_ref_doc_entity_code                IN  zx_lines_det_factors.ref_doc_entity_code%TYPE,
   p_ref_doc_event_class_code           IN  zx_lines_det_factors.ref_doc_event_class_code%TYPE,
   p_ref_doc_trx_id                     IN  zx_lines_det_factors.ref_doc_trx_id%TYPE,
   p_ref_doc_line_id                    IN  zx_lines_det_factors.ref_doc_line_id%TYPE,
   p_ref_doc_trx_level_type             IN  zx_lines_det_factors.ref_doc_trx_level_type%TYPE,
   p_vendor_id				                  IN  po_vendors.vendor_id%TYPE,
   p_vendor_site_id 		              	IN  po_vendor_sites.vendor_site_id%TYPE,
   p_code_combination_id  		          IN  gl_code_combinations.code_combination_id%TYPE,
   p_concatenated_segments		          IN  varchar2,
   p_templ_tax_classification_cd        IN  varchar2,
   p_ship_to_location_id		            IN  hr_locations_all.location_id%TYPE,
   p_ship_to_loc_org_id   		          IN  mtl_system_items.organization_id%TYPE,
   p_inventory_item_id   		            IN  mtl_system_items.inventory_item_id%TYPE,
   p_item_org_id   			                IN  mtl_system_items.organization_id%TYPE,
   p_tax_classification_code		        IN  OUT NOCOPY VARCHAR2,
   p_allow_tax_code_override_flag           OUT NOCOPY zx_acct_tx_cls_defs.allow_tax_code_override_flag%TYPE,
   p_tax_user_override_flag		          IN  VARCHAR2 DEFAULT 'N',
   p_user_tax_name	       		          IN  VARCHAR2 DEFAULT NULL,
   p_legal_entity_id                    IN  zx_lines.legal_entity_id%TYPE DEFAULT NULL,
   APPL_SHORT_NAME			                IN  fnd_application.application_short_name%TYPE,
   FUNC_SHORT_NAME			                IN  VARCHAR2,
   p_calling_sequence		              	IN  VARCHAR2,
   p_event_class_code                   IN  VARCHAR2,
   p_entity_code                        IN  VARCHAR2,
   p_application_id                     IN  NUMBER,
   p_internal_organization_id           IN  NUMBER,
   p_default_hierarchy                      OUT NOCOPY BOOLEAN);

end ZX_AP_TAX_CLASSIFICATN_DEF_PKG;

/
