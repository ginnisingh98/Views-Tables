--------------------------------------------------------
--  DDL for Package Body ZX_AP_TAX_CLASSIFICATN_DEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_AP_TAX_CLASSIFICATN_DEF_PKG" as
/* $Header: zxaptxclsdefpkgb.pls 120.19.12010000.5 2009/08/11 15:47:27 tsen ship $ */

-- Declare Public Procedure
-- Initialize

g_current_runtime_level     NUMBER;
g_level_statement           CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
g_level_procedure           CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
g_level_unexpected          CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;


  result                boolean;
  statement             varchar2(2000);
  search_for_ap_tax     boolean;
  search_for_po_tax     boolean;
  search_for_cc_tax     boolean; -- Bug 6510307
  search_ap_def_hier    boolean;
  search_po_def_hier    boolean;
  search_cc_def_hier    boolean; -- Bug 6510307
  debug_loc             VARCHAR2(30);
  curr_calling_sequence VARCHAR2(2000);

PROCEDURE Initialize;
PROCEDURE pop_ap_def_option_hier(p_org_id           IN    NUMBER,
                                 p_application_id   IN    NUMBER,
                                 p_event_class_code IN    VARCHAR2,
                                 p_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE pop_po_def_option_hier(p_org_id           IN    NUMBER,
                                 p_application_id   IN    NUMBER,
                                 p_return_status    OUT NOCOPY VARCHAR2);
--CC Change
PROCEDURE pop_cc_def_option_hier(p_org_id           IN    NUMBER,
                                 p_application_id   IN    NUMBER,
                                 p_return_status    OUT NOCOPY VARCHAR2);

-- Bug#5066122
PROCEDURE validate_tax_classif_code(
              p_tax_classification_code   IN  VARCHAR2,
              p_count                     OUT NOCOPY NUMBER);

-- Bug#4090842- change and split initialize to pop_ap_def_option_hier
-- and pop_po_def_option_hier
-------------------------------------------------------------------
--
-- PRIVATE PROCEDURE
-- Initialize
--
-- DESCRIPTION
-- This procedure gets chart_of_accounts_id from gl_sets_of_books
-- and initializes org_id stored in sysinfo to NULL
--

PROCEDURE Initialize
IS
  l_set_of_books_id    gl_sets_of_books.set_of_books_id%TYPE;
  l_chart_of_accounts_id    gl_sets_of_books.chart_of_accounts_id%TYPE;

  -- Bug#4090842- no need to get org_id here, it is passed in from products
  CURSOR c_financial_params IS
  SELECT sob.set_of_books_id,sob.chart_of_accounts_id
    FROM gl_sets_of_books sob,
         financials_system_parameters fsp
   WHERE fsp.set_of_books_id = sob.set_of_books_id;
BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Initialize.BEGIN',
                   'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: initialize(+)' );
  END IF;

  open c_financial_params;
     -- Bug#4090842- no need to fetch org_id
     -- fetch c_financial_params into chart_of_accounts_id, org_id;
  fetch c_financial_params into l_set_of_books_id,l_chart_of_accounts_id;
  close c_financial_params;

  IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.initialize',
                     'set_of_books_id  =='||to_char(l_set_of_books_id));

      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.initialize',
                     'chart_of_accounts_id  =='||to_char(l_chart_of_accounts_id));
     END IF;

  sysinfo.set_of_books_id       := l_set_of_books_id;
  sysinfo.chart_of_accounts_id  := l_chart_of_accounts_id;

  --
  -- init org_id to NULL
  --
  sysinfo.ap_info.org_id := NULL;
  sysinfo.po_info.org_id := NULL;
  sysinfo.cc_info.org_id := NULL; -- Bug 6510307

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Initialize.END',
                   'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: initialize(-)' );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_financial_params%ISOPEN THEN
      CLOSE c_financial_params;
    END IF;
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', 'initialize- '||
                          sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.initialize',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
END Initialize;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_default_tax_classification
--
--  DESCRIPTION
--
--  The procedure is passed a variety of parameters which may determine
--  the tax code that is to be used in Purchasing or in Payables, on
--  documents or document templates.
--
--  Given the parameters passed in the procedure will return a valid
--  tax classification code.
--  This API replaces get_default_tax_code of 11i
--
--  Current defaulting sources for the tax code in AP are:
--
--  Purchase Order Shipment
--  Supplier Site
--  Supplier
--  Natural Account
--  Financial Options
--  Invoice Header
--  Document Template
--
--  Current defaulting sources for the tax code in PO are:
--
--  Ship-to Location
--  Item
--  Supplier Site
--  Supplier
--  Financial Options
--
--  Current defaulting sources for the tax code in IGC are:
--
--  Supplier Site
--  Supplier
--  Financial Options
--
--  When the procedure is called from the transaction workbenches, the tax code
--  should be retrieved for the tax date (e.g. invoice date in AP)
--  When the API is called from setup screens, the tax code should be
--  retrieved for the system date.
--
--  The func_short_name parameter is for the purpose of future
--  application-specific defaulting enhancements.  The only current use
--  is to detect when a distribution set is in use on a form or process,
--  to determine which tax code to return when using document templates.
--
--
--  If the user-specified tax codes on
--  a document template is  required, it is  passed in to
--  the procedure
--  and may be returned as the defaulted tax code, if the procedure establishes
--  that that is the required tax code.
--
--  PARAMETERS
--  p_ref_doc_application_id            IN
--  p_ref_doc_entity_code               IN
--  p_ref_doc_event_class_code          IN
--  p_ref_doc_trx_id                    IN
--  p_ref_doc_line_id                   IN
--  p_ref_doc_trx_level_type            IN
--  p_vendor_id				IN
--  p_vendor_site_id 			IN
--  p_code_combination_id  		IN
--  p_concatenated_segments		IN
--  p_templ_tax_classification_cd       IN
--  p_ship_to_location_id		IN
--  p_ship_to_loc_org_id   		IN
--  p_inventory_item_id   		IN
--  p_item_org_id   			IN
--  p_tax_classification_code		IN  OUT NOCOPY
--  p_allow_tax_code_override_flag          OUT NOCOPY
--  p_tax_user_override_flag     	IN
--  p_user_tax_name              	IN
--  APPL_SHORT_NAME			IN
--  FUNC_SHORT_NAME			IN
--  p_calling_sequence			IN
--  p_event_class_code                  IN
--  p_entity_code                       IN
--  p_application_id                    IN
--  p_internal_organization_id          IN

--  CALLED BY
--  Payables and Purchasing workbenches, setup forms and programs
--
--  HISTORY
--  14-JUL-97	Fiona Purves	Created based on AR Tax Defaulting API.
--  18-NOV-97   Fiona Purves    Created overloaded package, adding two extra
--				parameters, p_user_tax_name and p_user_tax_override_flag.
--				These parameters are used to detect and return a user-
--				defined tax code, if the defaulted one has been explicitly
--				overidden.
--  31-DEC-98   Fiona Purves    Added changes for effective tax date handling.
--  24-Jun-04   Sudhir Sekuri   Bugfix 3611046. 11ix uptake for EBusiness Tax
--  10-May-05   Phong La        Bugfix4310278. Remove p_line_location_id and
--                              use ref_doc columns instead
---------------------------------------------------------------------------------

PROCEDURE  get_default_tax_classification(

 -- p_line_location_id		IN  po_line_locations.line_location_id%TYPE,
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
 p_item_org_id   		IN  mtl_system_items.organization_id%TYPE,
 p_tax_classification_code	IN  OUT NOCOPY VARCHAR2,
 p_allow_tax_code_override_flag     OUT NOCOPY zx_acct_tx_cls_defs.allow_tax_code_override_flag%TYPE,
 p_legal_entity_id              IN  zx_lines.legal_entity_id%TYPE,
 APPL_SHORT_NAME		IN  fnd_application.application_short_name%TYPE,
 FUNC_SHORT_NAME		IN  VARCHAR2,
 p_calling_sequence		IN  VARCHAR2,
 p_event_class_code             IN  VARCHAR2,
 p_entity_code                  IN  VARCHAR2,
 p_application_id               IN  NUMBER,
 p_internal_organization_id     IN  NUMBER) IS

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification.BEGIN',

                     'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: get_default_tax_classification (+)');
   END IF;

   --
   -- set default value
   --
  Initialize; --Bug 5712279

   ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification(
                                           -- p_line_location_id,
                                           p_ref_doc_application_id,
                                           p_ref_doc_entity_code,
                                           p_ref_doc_event_class_code,
                                           p_ref_doc_trx_id,
                                           p_ref_doc_line_id,
                                           p_ref_doc_trx_level_type,
					   p_vendor_id,
					   p_vendor_site_id,
					   p_code_combination_id,
				   	   p_concatenated_segments,
                                           p_templ_tax_classification_cd,
					   p_ship_to_location_id,
					   p_ship_to_loc_org_id,
					   p_inventory_item_id,
					   p_item_org_id ,
					   p_tax_classification_code,
					   p_allow_tax_code_override_flag,
					   'N',
					   null,
                                           p_legal_entity_id,
					   APPL_SHORT_NAME,
					   FUNC_SHORT_NAME,
					   p_calling_sequence,
                                           p_event_class_code,
                                           p_entity_code,
                                           p_application_id,
                                           p_internal_organization_id);
   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification.END',

                     'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: get_default_tax_classification (-)');
   END IF;

END get_default_tax_classification;

----------------------------------------------------------
--
-- bug#4891362- overloaded version
--

PROCEDURE  get_default_tax_classification(
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
 p_item_org_id   		IN  mtl_system_items.organization_id%TYPE,
 p_tax_classification_code	IN  OUT NOCOPY VARCHAR2,
 p_allow_tax_code_override_flag     OUT NOCOPY zx_acct_tx_cls_defs.allow_tax_code_override_flag%TYPE,
 APPL_SHORT_NAME		IN  fnd_application.application_short_name%TYPE,
 FUNC_SHORT_NAME		IN  VARCHAR2,
 p_calling_sequence		IN  VARCHAR2,
 p_event_class_code             IN  VARCHAR2,
 p_entity_code                  IN  VARCHAR2,
 p_application_id               IN  NUMBER,
 p_internal_organization_id     IN  NUMBER) IS

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification.BEGIN',

                     'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: get_default_tax_classification (+)');
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',

                     'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: overloaded version 1');

   END IF;

   --
   -- set default value
   --

   Initialize; --Bug 5712279

   ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification(
                                           p_ref_doc_application_id,
                                           p_ref_doc_entity_code,
                                           p_ref_doc_event_class_code,
                                           p_ref_doc_trx_id,
                                           p_ref_doc_line_id,
                                           p_ref_doc_trx_level_type,
					   p_vendor_id,
					   p_vendor_site_id,
					   p_code_combination_id,
				   	   p_concatenated_segments,
                                           p_templ_tax_classification_cd,
					   p_ship_to_location_id,
					   p_ship_to_loc_org_id,
					   p_inventory_item_id,
					   p_item_org_id ,
					   p_tax_classification_code,
					   p_allow_tax_code_override_flag,
					   'N',
					   null,
                                           null, --p_legal_entity_id,
					   APPL_SHORT_NAME,
					   FUNC_SHORT_NAME,
					   p_calling_sequence,
                                           p_event_class_code,
                                           p_entity_code,
                                           p_application_id,
                                           p_internal_organization_id);
   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification.END',

                     'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: get_default_tax_classification (-)');
   END IF;

END get_default_tax_classification;

--------------------------------------------------------------
-- The API get_default_tax_classification replaces 11i API get_default_tax_code
PROCEDURE  get_default_tax_classification(
   -- p_line_location_id			IN  po_line_locations.line_location_id%TYPE,
   p_ref_doc_application_id             IN  zx_lines_det_factors.ref_doc_application_id%TYPE,
   p_ref_doc_entity_code                IN  zx_lines_det_factors.ref_doc_entity_code%TYPE,
   p_ref_doc_event_class_code           IN  zx_lines_det_factors.ref_doc_event_class_code%TYPE,
   p_ref_doc_trx_id                     IN  zx_lines_det_factors.ref_doc_trx_id%TYPE,
   p_ref_doc_line_id                    IN  zx_lines_det_factors.ref_doc_line_id%TYPE,
   p_ref_doc_trx_level_type             IN  zx_lines_det_factors.ref_doc_trx_level_type%TYPE,
   p_vendor_id				IN  po_vendors.vendor_id%TYPE,
   p_vendor_site_id 			IN  po_vendor_sites.vendor_site_id%TYPE,
   p_code_combination_id  		IN  gl_code_combinations.code_combination_id%TYPE,
   p_concatenated_segments		IN  varchar2,
   p_templ_tax_classification_cd        IN  varchar2,
   p_ship_to_location_id		IN  hr_locations_all.location_id%TYPE,
   p_ship_to_loc_org_id   		IN  mtl_system_items.organization_id%TYPE,
   p_inventory_item_id   		IN  mtl_system_items.inventory_item_id%TYPE,
   p_item_org_id   			IN  mtl_system_items.organization_id%TYPE,
   p_tax_classification_code		IN  OUT NOCOPY VARCHAR2,
   p_allow_tax_code_override_flag           OUT NOCOPY zx_acct_tx_cls_defs.allow_tax_code_override_flag%TYPE,
   p_tax_user_override_flag		IN  VARCHAR2,
   p_user_tax_name	       		IN  VARCHAR2,
   p_legal_entity_id                    IN  zx_lines.legal_entity_id%TYPE,
   APPL_SHORT_NAME			IN  fnd_application.application_short_name%TYPE,
   FUNC_SHORT_NAME			IN  VARCHAR2,
   p_calling_sequence			IN  VARCHAR2,
   p_event_class_code                   IN  VARCHAR2,
   p_entity_code                        IN  VARCHAR2,
   p_application_id                     IN  NUMBER,
   p_internal_organization_id           IN  NUMBER) IS

 l_tax_classification_code      VARCHAR2(30);
 l_enforce_tax_from_acct_flag   VARCHAR2(1);
 l_enforce_tax_from_refdoc_flag VARCHAR2(1);
 l_enforced_tax_found	 	boolean := FALSE;
 l_tax_classification_found	boolean := FALSE;
 l_found                        boolean := FALSE;
 l_curr_calling_sequence 	VARCHAR2(2000);
 l_item_taxable_flag            VARCHAR2(1);
 -- Added the following variable as part of the fix for the bug 2608697 by zmohiudd.
 l_shipment_taxable_flag        VARCHAR2(1);
 l_count                        NUMBER;
 l_return_status                VARCHAR2(80);

CURSOR sel_item_taxable_flag
         (c_inventory_item_id   mtl_system_items_b.inventory_item_id%TYPE,
          c_item_org_id         mtl_system_items_b.organization_id%TYPE,
          c_ship_to_loc_org_id  mtl_system_items_b.organization_id%TYPE) IS

 SELECT taxable_flag
   FROM mtl_system_items si
  WHERE si.inventory_item_id = c_inventory_item_id
    AND si.organization_id = nvl(c_ship_to_loc_org_id, c_item_org_id);

  CURSOR c_evnt_cls_options (c_org_id           NUMBER,
                             c_application_id   NUMBER,
                             c_entity_code      VARCHAR2,
                             c_event_class_code VARCHAR2) IS
  select enforce_tax_from_acct_flag,
         enforce_tax_from_ref_doc_flag
    from zx_evnt_cls_options
   where application_id = c_application_id
     and entity_code = c_entity_code
     and event_class_code = c_event_class_code
     and first_pty_org_id = (Select party_tax_profile_id
                               From zx_party_tax_profile
                              where party_id = c_org_id
                                and party_type_code = 'OU')
     and sysdate >= effective_from
     and sysdate <= nvl(effective_to,sysdate)
     and enabled_flag = 'Y';

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification.BEGIN',
                       'Get_Default_Tax_Classification(+) ');
--  	FND_LOG.STRING(g_level_statement,
--                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
--                       'p_line_location_id  == >'||to_char(p_line_location_id ));
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_ref_doc_application_id == >'||TO_CHAR(p_ref_doc_application_id));
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_ref_doc_entity_code == >'||p_ref_doc_entity_code);
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_ref_doc_event_class_code == >'||p_ref_doc_event_class_code);
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_ref_doc_trx_id == >'||TO_CHAR(p_ref_doc_trx_id));
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_ref_doc_line_id == >'||TO_CHAR(p_ref_doc_line_id));
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_ref_doc_trx_level_type == >'||p_ref_doc_trx_level_type);
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_vendor_id  == >'       ||to_char(p_vendor_id ));
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_vendor_site_id  == >'  ||to_char(p_vendor_site_id ));
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_code_combination_id = >'||to_char(p_code_combination_id) );
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_concatenated_segments== >'||p_concatenated_segments );
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_templ_tax_classification_cd == >'||
                        p_templ_tax_classification_cd);
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_ship_to_location_id == >'||to_char(p_ship_to_location_id) );
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_ship_to_loc_org_id  == >'||to_char(p_ship_to_loc_org_id) );
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_inventory_item_id  == >'||to_char(p_inventory_item_id) );
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_item_org_id  == >'     ||to_char( p_item_org_id));
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_tax_classification_code  == >' ||p_tax_classification_code);
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_allow_tax_code_override_flag ==>'|| p_allow_tax_code_override_flag);
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_tax_user_override_flag  ==>'||p_tax_user_override_flag);
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_user_tax_name  ==>'||p_user_tax_name);
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_legal_entity_id ==>'||TO_CHAR(p_legal_entity_id));

  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'APPL_SHORT_NAME  == >'||APPL_SHORT_NAME );
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'FUNC_SHORT_NAME   == >'||FUNC_SHORT_NAME );
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_calling_sequence  == >'||p_calling_sequence );
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_event_class_code  == >'||p_event_class_code );
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_entity_code  == >'||p_entity_code );
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_application_id == >'||TO_CHAR(p_application_id));
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_internal_organization_id == >'||TO_CHAR(p_internal_organization_id));

  END IF;

  -- Bug#4090842- call populate ap/po default options here
  -- Initialize;

  --
  -- check if need to repopulate AP/PO/IGC default options
  --
  IF APPL_SHORT_NAME = 'SQLAP' THEN
    IF (sysinfo.ap_info.org_id IS NULL OR
        (sysinfo.ap_info.org_id <> p_internal_organization_id)) THEN
      pop_ap_def_option_hier(
                    p_internal_organization_id,
                    p_application_id,
                    p_event_class_code,
                    l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;
    END IF;
  ELSIF APPL_SHORT_NAME = 'PO' THEN
    IF (sysinfo.po_info.org_id IS NULL OR
        (sysinfo.po_info.org_id <> p_internal_organization_id)) THEN
      pop_po_def_option_hier(
                    p_internal_organization_id,
                    p_application_id,
                    l_return_status);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;
    END IF;
  ELSIF APPL_SHORT_NAME = 'IGC' THEN -- Bug 6510307
    IF (sysinfo.cc_info.org_id IS NULL OR
        (sysinfo.cc_info.org_id <> p_internal_organization_id)) THEN
      pop_cc_def_option_hier(
                    p_internal_organization_id,
                    p_application_id,
                    l_return_status);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;
    END IF;
  END IF;

  l_tax_classification_found := FALSE;

  debug_loc := 'Get_Default_Tax_Classification';

  l_curr_calling_sequence := 'ZX_AP_TAX_CLASSIFICATN_DEF_PKG.'||debug_loc||'<-'||p_calling_sequence;

  --
  -- Get Payables/Purchasing default tax code.
  -- Hierarchy for PO:  Ship-to Location, Item, Vendor, Vendor Site and System.
  -- Hierarchy for AP:  Purchase Order Shipment, Vendor, Vendor Site, Natural Account, System,
  -- and Template.
  -- Hierarchy for CC:  Vendor Site, Vendor and System.
  -- The search ends when a tax code is found.
  --

  --
  -- if use_tax_classification_flag is no, set tax_classification_code
  -- to NULL and return, no need to search the default hierachy
  --

  IF (APPL_SHORT_NAME = 'SQLAP' AND
      NOT search_for_ap_tax) THEN
    p_tax_classification_code := NULL;
    RETURN;
  ELSIF (APPL_SHORT_NAME = 'PO' AND
      NOT search_for_po_tax) THEN
    p_tax_classification_code := NULL;
    RETURN;
  ELSIF (APPL_SHORT_NAME = 'IGC' AND -- Bug 6510307
      NOT search_for_cc_tax) THEN
     p_tax_classification_code := NULL;
     RETURN;
  END IF;

  IF (p_tax_user_override_flag = 'Y') THEN
     -- User has overridden tax code and the user tax code should be used.
     -- If tax name is null, then this is an explicit request for a null
     -- tax name and null should be returned.

     p_tax_classification_code := p_user_tax_name;
     l_tax_classification_found := TRUE;
  END IF;

  -- Following statement is to deal with the following problem:
  -- User has overridden default tax code with a user-specified one.
  -- User has committed the shipment and re-queried it, losing the
  -- tax_user_override_flag information, which is only available in the form.
  -- User has then changed the ship-to location code.
  -- Tax will be re-defaulted under these circumstances, which is incorrect
  -- if tax is not set up to re-default from the ship-to location.
  -- Real fix is to add the tax_user_override_flag as a database field.

  IF (search_po_def_hier) THEN
    IF (NVL(func_short_name, 'NONE')  = 'SHIP_TO_LOC') Then
       FOR i in 1..7
       Loop
          If potaxtab(i) = 'SHIP_TO_LOCATION' OR potaxtab(i) = 'ITEM' Then
             l_found := TRUE;
             exit;
          End If;
       End Loop;
       If NOT l_found Then
          l_tax_classification_code := p_user_tax_name;
          l_tax_classification_found := TRUE;
       End If;
    END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                    'l_tax_classification_code is found  =='||l_tax_classification_code);
  END IF;

  IF (l_tax_classification_found = FALSE) THEN
     IF (APPL_SHORT_NAME = 'SQLAP') THEN
        IF (search_ap_def_hier = TRUE) THEN

           IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                             'Getting Event Class Options');
           END IF;

--           open c_evnt_cls_options (to_number(substrb(userenv('CLIENT_INFO'),1,10)),
             open c_evnt_cls_options (
                                    p_internal_organization_id,
                                    200,
                                    p_entity_code,
                                    p_event_class_code);
           fetch c_evnt_cls_options into l_enforce_tax_from_acct_flag,
                                         l_enforce_tax_from_refdoc_flag;
           close c_evnt_cls_options;

           IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                             'Entity Code:' || p_entity_code);
              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                             'Event Class Code:' || p_event_class_code);
              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                             'Enforce Tax From Account  =='
                              || l_enforce_tax_from_acct_flag);

  	      FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                             'Getting tax code for AP ');
           END IF;

           IF (l_enforce_tax_from_refdoc_flag = 'Y') THEN
	      -- Tax code from the PO shipment is enforced
	      -- If a tax code exists for shipment then there is
	      -- no need to search any further, as this takes
	      -- precedence over the rest of the hierarchy.

              IF (g_level_statement >= g_current_runtime_level ) THEN
                 FND_LOG.STRING(g_level_statement,
                                'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                'Matching is enforced');
              END IF;

              /*
               * comment out for bug#4310278
               * need to confirm with Helen
               *
               --start  of code fix added for the bug 2608697 by  zmohiudd
               If p_line_location_id is not null then
	          select taxable_flag
	            into l_shipment_taxable_flag
	            from po_line_locations
	           where line_location_id = p_line_location_id ;

                  IF (g_level_statement >= g_current_runtime_level ) THEN
           	    FND_LOG.STRING(g_level_statement,
                                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                    ' l_shipment_taxable_flag is ' || l_shipment_taxable_flag );
                  END IF;
 	         If (l_shipment_taxable_flag = 'Y' ) then
 		    IF (g_level_statement >= g_current_runtime_level ) THEN
 		       FND_LOG.STRING(g_level_statement,
                                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                       'Calling get_po_shipment tax ' );
 		    END IF;
 		    l_tax_classification_code := get_input_tax_classif_code (p_line_location_id,
                                                                       l_curr_calling_sequence);
 	         else
 		    l_enforced_tax_found := TRUE;
    	         end if;
               else
      	         l_tax_classification_code := get_input_tax_classif_code (p_line_location_id,
 					                           l_curr_calling_sequence);
               end if;
               -- End of the code fix added for the bug 2608697 by  zmohiudd
              *
              *
              */
              --
              -- bug#4310278
              --
              l_tax_classification_code := get_input_tax_classif_code (
                                             p_ref_doc_application_id,
                                             p_ref_doc_entity_code,
                                             p_ref_doc_event_class_code,
                                             p_ref_doc_trx_id,
                                             p_ref_doc_line_id,
                                             p_ref_doc_trx_level_type,
                                             l_curr_calling_sequence);

              IF (l_tax_classification_code is not NULL) THEN
	         -- Tax found on PO shipment, do not search further
                 l_enforced_tax_found := TRUE;
                 IF (g_level_statement >= g_current_runtime_level ) THEN
            	    FND_LOG.STRING(g_level_statement,
                                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                   'l_tax_classification_code =='||l_tax_classification_code );
                 END IF;
              END IF;
           ELSIF (l_enforce_tax_from_acct_flag = 'Y') THEN
                 -- Tax code from the account is enforced
                 -- If a tax code exists for this account and
                 -- override of the tax code is not allowed then
                 -- no need to search any further, as the non-overridable accounts take
                 -- precedence over the rest of the tax defaulting hierarchy
                 -- This includes both Input and Non-taxable accounts.

                 IF (g_level_statement >= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_statement,
                                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                   'Tax from account is enforced');
                    FND_LOG.STRING(g_level_statement,
                                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                   ' Calling get_account_tax ');
                 END IF;
                 get_account_tax (p_code_combination_id,
		          	  p_concatenated_segments,
          			  p_tax_classification_code,
          			  p_allow_tax_code_override_flag,
          			  l_tax_classification_found,
          			  l_curr_calling_sequence);
                 l_tax_classification_code := p_tax_classification_code;
                 IF (g_level_statement >= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_statement,
                                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                   'l_tax_classification_code =='||l_tax_classification_code);
                 END IF;
                 IF (p_allow_tax_code_override_flag = 'N') THEN
          	    -- Override is not allowed, do not search further
                    l_enforced_tax_found := TRUE;
                 END IF;
           END IF; -- ap_match_on_tax_flag

           IF (l_enforced_tax_found = FALSE ) THEN
              -- If tax is not enforced from the account, or is enforced but
              -- the tax code is overrideable, then continue the search

              l_count := aptaxtab.COUNT;

              <<Ap_Tax_Loop>>
              FOR i in 1..l_count  LOOP
                  IF (aptaxtab (i) is NULL) THEN
                     --
                     -- default hierachy options from 1 to 7 can not
                     -- have gap, if the current one is NULL, the
                     -- rest would be NULL, there is no need to
                     -- continue looping
                     --

                     exit Ap_Tax_Loop;
                   ELSE
                   --  aptaxtab (i) is not NULL

   	             IF (aptaxtab (i) = 'REFERENCE_DOCUMENT') THEN
                        IF (g_level_statement >= g_current_runtime_level ) THEN
         	           FND_LOG.STRING(g_level_statement,
                                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                          'Getting tax code from shipment');
         	           FND_LOG.STRING(g_level_statement,
                                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                          'Calling get_input_tax_classif_code ');
                        END IF;
      	                l_tax_classification_code := get_input_tax_classif_code (
                                             p_ref_doc_application_id,
                                             p_ref_doc_entity_code,
                                             p_ref_doc_event_class_code,
                                             p_ref_doc_trx_id,
                                             p_ref_doc_line_id,
                                             p_ref_doc_trx_level_type,
                                             l_curr_calling_sequence);

                        IF (l_tax_classification_code is not NULL) THEN
                           l_tax_classification_found := TRUE;
                           IF (g_level_statement >= g_current_runtime_level ) THEN
                              FND_LOG.STRING(g_level_statement,
                                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                             'l_tax_classification_code =='
                                              ||l_tax_classification_code);
                           END IF;
                           exit Ap_Tax_Loop;
                        END IF;
                     END IF;

                     IF (aptaxtab (i) = 'SHIP_FROM_PARTY_SITE') THEN
                        IF (g_level_statement >= g_current_runtime_level ) THEN
         	           FND_LOG.STRING(g_level_statement,
                                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                          'Getting tax code from supplier site');
                        END IF;
                        l_tax_classification_code := get_site_tax (
                                                        p_vendor_site_id,
					                l_curr_calling_sequence);
                        IF (l_tax_classification_code is not NULL) THEN
                           l_tax_classification_found := TRUE;
                           IF (g_level_statement >= g_current_runtime_level ) THEN
                              FND_LOG.STRING(g_level_statement,
                                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                             'l_tax_classification_code =='
                                              ||l_tax_classification_code);
                           END IF;
                           exit Ap_Tax_Loop;
                        END IF;
                     END IF;

                     IF (aptaxtab (i) = 'SHIP_FROM_PARTY') THEN
                        IF (g_level_statement >= g_current_runtime_level ) THEN
                	    FND_LOG.STRING(g_level_statement,
                                           'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                           'Getting tax code from supplier');
                        END IF;
                        l_tax_classification_code := get_vendor_tax (
                                                        p_vendor_id,
       					                l_curr_calling_sequence);
                        IF (l_tax_classification_code is not NULL) THEN
                           l_tax_classification_found := TRUE;
                           IF (g_level_statement >= g_current_runtime_level ) THEN
                              FND_LOG.STRING(g_level_statement,
                                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                             'l_tax_classification_code =='
                                                 ||l_tax_classification_code);
                           END IF;
                           exit Ap_Tax_Loop;
                        END IF;
                     END IF;

                     IF (aptaxtab (i) = 'NATURAL_ACCOUNT') THEN
                        IF (g_level_statement >= g_current_runtime_level ) THEN
         	            FND_LOG.STRING(g_level_statement,
                                           'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                           'Getting tax code from account');
                        END IF;
                        get_account_tax (p_code_combination_id,
	       			         p_concatenated_segments,
			         	 p_tax_classification_code,
				         p_allow_tax_code_override_flag,
				         l_tax_classification_found,
			              	 l_curr_calling_sequence);
                        l_tax_classification_code := p_tax_classification_code;
                        IF (g_level_statement >= g_current_runtime_level ) THEN
         	            FND_LOG.STRING(g_level_statement,
                                           'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                           'l_tax_classification_code =='
                                            ||l_tax_classification_code);
                        END IF;
       	                IF (l_tax_classification_found = TRUE) THEN
                           IF (g_level_statement >= g_current_runtime_level ) THEN
                              FND_LOG.STRING(g_level_statement,
                                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                             'l_tax_classification_code is Found =='
                                              ||l_tax_classification_code);
                           END IF;
                           exit Ap_Tax_Loop;
                        END IF;
                     END IF;

                     IF (aptaxtab (i) = 'FINANCIAL_OPTIONS') THEN
                        IF (g_level_statement >= g_current_runtime_level ) THEN
         	            FND_LOG.STRING(g_level_statement,
                                           'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                           'Getting tax code from financial system parameters');
         	            FND_LOG.STRING(g_level_statement,
                                           'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                           'sysinfo.vat_code =='
                                            ||sysinfo.ap_info.tax_classification_code );
                        END IF;
                        l_tax_classification_code := sysinfo.ap_info.tax_classification_code;
                        IF (l_tax_classification_code is not NULL) THEN
                           l_tax_classification_found := TRUE;
                           IF (g_level_statement >= g_current_runtime_level ) THEN
                              FND_LOG.STRING(g_level_statement,
                                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                             'l_tax_classification_code =='
                                              ||l_tax_classification_code);
                           END IF;
                           exit Ap_Tax_Loop;
                        END IF;
                     END IF;

                     IF (aptaxtab (i) = 'TEMPLATE') THEN
                        IF (g_level_statement >= g_current_runtime_level ) THEN
                            FND_LOG.STRING(g_level_statement,
                                           'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                           'Getting tax code from template');
                        END IF;
                        -- If the API has been called from a form or process
                        -- where a template is being used, then we should always
                        -- return the tax code on the template item, even if it
                        -- is null.  This is because a null tax code on a template
                        -- is considered as an explicit request for a non-taxable
                        -- item.  See bug #558756.
                        --
                        -- We use the func_short_name to determine if the
                        -- API is being called anywhere where a distribution set
                        -- is in use, and use the calling_sequence to determine
                        -- whether we are being called from the Expense Reports form
                        -- (and are by implication using an expense report template).

                        -- 2544633 fbreslin: Add APXXXDER to list of forms that uses this code.
                        IF (p_calling_sequence IN ('APXXXEER', 'APXXXDER') OR
                            func_short_name = 'AP_INSERT_FROM_DSET') THEN
                           l_tax_classification_code := p_templ_tax_classification_cd;
                           l_tax_classification_found := TRUE;
                           IF (g_level_statement >= g_current_runtime_level ) THEN
                             FND_LOG.STRING(g_level_statement,
                                           'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                           'l_tax_classification_code =='
                                            ||l_tax_classification_code);
                           END IF;
                           exit Ap_Tax_Loop;
                        END IF;
                    END IF;
                  END IF;
              END LOOP Ap_Tax_Loop;
           END IF; -- l_enforced_tax_found
        END IF; -- search_for_ap_tax
     ELSIF (APPL_SHORT_NAME = 'PO') THEN -- Bug 6510307
        --  APPL_SHORT_NAME is PO
        IF (search_po_def_hier = TRUE) THEN

           IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                             'Getting tax code for PO');
           END IF;

           l_count := potaxtab.COUNT;

           <<Po_Tax_Loop>>
           FOR i in 1..l_count  LOOP
               IF (potaxtab (i) is  NULL) THEN
                  --
                  -- default hierachy options from 1 to 7 can not
                  -- have gap, if the current one is NULL, the
                  -- rest would be NULL, there is no need to
                  -- continue looping
                  --
                 exit Po_Tax_Loop;
               ELSE
                 --  potaxtab (i) is not NULL
                  IF (potaxtab (i) = 'SHIP_TO_LOCATION') THEN
                     IF (g_level_statement >= g_current_runtime_level ) THEN
               	        FND_LOG.STRING(g_level_statement,
                                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                       ' Calling get_ship_to_location_tax ');
                     END IF;

	             l_tax_classification_code :=
                         get_ship_to_location_tax (p_ship_to_location_id,
		   				   p_ship_to_loc_org_id,
                                                   p_legal_entity_id,
   						   l_curr_calling_sequence);
                     IF (l_tax_classification_code is not NULL) THEN
                        l_tax_classification_found := TRUE;
                        IF (g_level_statement >= g_current_runtime_level ) THEN
                  	   FND_LOG.STRING(g_level_statement,
                                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                          'l_tax_classification_code =='
                                          ||l_tax_classification_code);
                        END IF;
                        exit Po_Tax_Loop;
                     END IF;
                  END IF;

                  IF (potaxtab (i) = 'ITEM') THEN
                     IF (g_level_statement >= g_current_runtime_level ) THEN
     	                FND_LOG.STRING(g_level_statement,
                                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                       'Getting tax code from item');
     	                FND_LOG.STRING(g_level_statement,
                                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                       'Calling get_item_tax ');
                     END IF;
   	             l_tax_classification_code := get_item_tax (p_inventory_item_id,
   		   			                        p_ship_to_loc_org_id,
   					                        p_item_org_id,
   					                        l_curr_calling_sequence);
                     -- Fixed bug 1753904: Tax code is defaultin
                     -- in PO documents for non-taxable item.

                     OPEN sel_item_taxable_flag (p_inventory_item_id,
                                                 p_item_org_id,
                                                 p_ship_to_loc_org_id);
                     FETCH sel_item_taxable_flag INTO l_item_taxable_flag;
                     CLOSE sel_item_taxable_flag;

                     --If the item's taxable flag is not set to 'Y',
                     --the tax code defaulting PKG should not look further to the next hierarchy
                     --even a null tax code is returned.
                     IF (g_level_statement >= g_current_runtime_level ) THEN
                  	FND_LOG.STRING(g_level_statement,
                                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                       'l_item_taxable_flag =  ' || l_item_taxable_flag );
                     END IF;

                     IF (l_item_taxable_flag  = 'N' or l_tax_classification_code is not null) THEN
                        l_tax_classification_found := TRUE;
                        IF (g_level_statement >= g_current_runtime_level ) THEN
               	           FND_LOG.STRING(g_level_statement,
                                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                          'l_tax_classification_code =='||l_tax_classification_code);
                        END IF;
                        exit Po_Tax_Loop;
                     END IF;
                  END IF;

                  IF (potaxtab (i) = 'SHIP_FROM_PARTY_SITE') THEN
                     IF (g_level_statement >= g_current_runtime_level ) THEN
     	                FND_LOG.STRING(g_level_statement,
                                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                       'Getting tax code from supplier site');
     	                FND_LOG.STRING(g_level_statement,
                                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                       'Calling get_site_tax ');
                     END IF;
                     l_tax_classification_code := get_site_tax (
                                                     p_vendor_site_id,
   					             l_curr_calling_sequence);
                     IF (l_tax_classification_code is not NULL) THEN
                        l_tax_classification_found := TRUE;
                        IF (g_level_statement >= g_current_runtime_level ) THEN
                  	   FND_LOG.STRING(g_level_statement,
                                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                          'l_tax_classification_code =='||l_tax_classification_code);
                        END IF;
                        exit Po_Tax_Loop;
                     END IF;
                  END IF;

                  IF (potaxtab (i) = 'SHIP_FROM_PARTY') THEN
                     IF (g_level_statement >= g_current_runtime_level ) THEN
  	                FND_LOG.STRING(g_level_statement,
                                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                       'Getting tax code from supplier');
  	                FND_LOG.STRING(g_level_statement,
                                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                       'Calling get_vendor_tax ');
                     END IF;
                     l_tax_classification_code := get_vendor_tax (
                                                     p_vendor_id,
					             l_curr_calling_sequence);
                     IF (l_tax_classification_code is not NULL) THEN
                        l_tax_classification_found := TRUE;
                        IF (g_level_statement >= g_current_runtime_level ) THEN
                  	   FND_LOG.STRING(g_level_statement,
                                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                          'l_tax_classification_code =='||l_tax_classification_code);
                        END IF;
                        exit Po_Tax_Loop;
                     END IF;
                  END IF;

                  IF (potaxtab (i) = 'FINANCIAL_OPTIONS') THEN
                     IF (g_level_statement >= g_current_runtime_level ) THEN
  	                FND_LOG.STRING(g_level_statement,
                                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                       'Getting tax code from financial system parameters');
  	                FND_LOG.STRING(g_level_statement,
                                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                       'sysinfo.po_info.tax_classification_code  =='
                                           ||sysinfo.po_info.tax_classification_code);
                     END IF;
                     l_tax_classification_code := sysinfo.po_info.tax_classification_code;
                     IF (l_tax_classification_code is not NULL) THEN
                        l_tax_classification_found := TRUE;
                        IF (g_level_statement >= g_current_runtime_level ) THEN
               	           FND_LOG.STRING(g_level_statement,
                                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                       'l_tax_classification_code =='||l_tax_classification_code);
                        END IF;
                        exit Po_Tax_Loop;
                     END IF;
                  END IF;

               END IF;
           END LOOP Po_Tax_Loop;
        END IF; -- search_for_po_tax
    ELSIF (APPL_SHORT_NAME = 'IGC') THEN -- Bug 6510307

	IF (search_cc_def_hier = TRUE) THEN

           IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                             'Getting tax code for CC');
           END IF;

           l_count := cctaxtab.COUNT;

           <<Cc_Tax_Loop>>
           FOR i in 1..l_count  LOOP
               IF (cctaxtab (i) is  NULL) THEN
                  --
                  -- default hierachy options from 1 to 7 can not
                  -- have gap, if the current one is NULL, the
                  -- rest would be NULL, there is no need to
                  -- continue looping
                  --
                 exit Cc_Tax_Loop;
               ELSE
                 --  cctaxtab (i) is not NULL
                    IF (cctaxtab (i) = 'SHIP_FROM_PARTY_SITE') THEN
                        IF (g_level_statement >= g_current_runtime_level ) THEN
         	           FND_LOG.STRING(g_level_statement,
                                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                          'Getting tax code from supplier site');
                        END IF;
                        l_tax_classification_code := get_site_tax (
                                                        p_vendor_site_id,
					                l_curr_calling_sequence);
                        IF (l_tax_classification_code is not NULL) THEN
                           l_tax_classification_found := TRUE;
                           IF (g_level_statement >= g_current_runtime_level ) THEN
                              FND_LOG.STRING(g_level_statement,
                                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                             'l_tax_classification_code =='
                                              ||l_tax_classification_code);
                           END IF;
                           exit Cc_Tax_Loop;
                        END IF;
                     END IF;

		      IF (cctaxtab (i) = 'SHIP_FROM_PARTY') THEN
                        IF (g_level_statement >= g_current_runtime_level ) THEN
                	    FND_LOG.STRING(g_level_statement,
                                           'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                           'Getting tax code from supplier');
                        END IF;
                        l_tax_classification_code := get_vendor_tax (
                                                        p_vendor_id,
       					                l_curr_calling_sequence);
                        IF (l_tax_classification_code is not NULL) THEN
                           l_tax_classification_found := TRUE;
                           IF (g_level_statement >= g_current_runtime_level ) THEN
                              FND_LOG.STRING(g_level_statement,
                                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                             'l_tax_classification_code =='
                                                 ||l_tax_classification_code);
                           END IF;
                           exit Cc_Tax_Loop;
                        END IF;
                     END IF;

		       IF (cctaxtab (i) = 'FINANCIAL_OPTIONS') THEN
                        IF (g_level_statement >= g_current_runtime_level ) THEN
         	            FND_LOG.STRING(g_level_statement,
                                           'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                           'Getting tax code from financial system parameters');
         	            FND_LOG.STRING(g_level_statement,
                                           'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                           'sysinfo.vat_code =='
                                            ||sysinfo.cc_info.tax_classification_code );
                        END IF;
                        l_tax_classification_code := sysinfo.cc_info.tax_classification_code;
                        IF (l_tax_classification_code is not NULL) THEN
                           l_tax_classification_found := TRUE;
                           IF (g_level_statement >= g_current_runtime_level ) THEN
                              FND_LOG.STRING(g_level_statement,
                                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                                             'l_tax_classification_code =='
                                              ||l_tax_classification_code);
                           END IF;
                           exit Cc_Tax_Loop;
                        END IF;
                     END IF;
               END IF;
           END LOOP cc_Tax_Loop;
        END IF; -- search_for_cc_tax

     END IF; -- appl_short_name
   END IF; -- tax_code_found

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                     'After Po_Tax_Loop ,l_tax_classification_code  =='
                      ||l_tax_classification_code);
   END IF;

   IF (nvl (p_tax_user_override_flag, 'N') <> 'Y') THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
      	 FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                        'p_tax_user_override_flag =='||p_tax_user_override_flag);
   	 FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                        'l_tax_classification_code =='||l_tax_classification_code);
      END IF;
      IF (l_tax_classification_code is not null) THEN
   	 p_tax_classification_code := l_tax_classification_code;
      END IF;
   END IF;
   IF (g_level_statement >= g_current_runtime_level ) THEN
   	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                       'p_tax_classification_code  =='||p_tax_classification_code);
   	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification.END',
                        'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: get_default_tax_classification (-)');
   END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       IF (g_level_unexpected >= g_current_runtime_level ) THEN
  	  FND_LOG.STRING(g_level_unexpected,
                         'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                          sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80) );
       END IF;
       IF (l_tax_classification_found = FALSE ) THEN
	  RAISE NO_DATA_FOUND;
       END IF;
  WHEN OTHERS THEN
       IF (SQLCODE <> -20001) THEN
         IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                         'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',
                         sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80) );
         END IF;
          IF (appl_short_name = 'SQLAP') THEN
             FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
             FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS',
	          ' p_ref_doc_application_id = '|| to_char (p_ref_doc_application_id) ||
                 ', p_ref_doc_entity_code = '||p_ref_doc_entity_code ||
                 ',p_ref_doc_event_class_code = '||p_ref_doc_event_class_code ||
                 ',p_ref_doc_trx_id = '||TO_CHAR(p_ref_doc_trx_id) ||
                 ',p_ref_doc_line_id = '||TO_CHAR(p_ref_doc_line_id) ||
                 ',p_ref_doc_trx_level_type = '||p_ref_doc_trx_level_type ||
	         ', p_vendor_id = '|| to_char (p_vendor_id) ||
	         ', p_vendor_site_id = '|| to_char (p_vendor_site_id) ||
	         ', p_code_combination_id = '|| to_char (p_code_combination_id) ||
	         ', p_concatenated_segments = '||p_concatenated_segments ||
                 ', p_templ_tax_classification_cd = '||p_templ_tax_classification_cd||
	         ', p_tax_classification_code = '||p_tax_classification_code ||
                 ', p_allow_tax_code_override_flag = '||p_allow_tax_code_override_flag ||
     	         ', APPL_SHORT_NAME = '||APPL_SHORT_NAME ||
	         ', FUNC_SHORT_NAME = '||FUNC_SHORT_NAME ||
	         ', p_calling_sequence = '||p_calling_sequence);

          ELSIF (appl_short_name = 'PO') THEN --Bug 6510307
             FND_MESSAGE.SET_NAME('PO', 'PO_DEBUG');
             FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS',
	         'p_ship_to_location_id = '||to_char (p_ship_to_location_id) ||
	         ', p_ship_to_loc_org_id = '||to_char (p_ship_to_loc_org_id) ||
	         ', p_inventory_item_id = '||to_char (p_inventory_item_id) ||
	         ', p_item_org_id = '||to_char (p_item_org_id) ||
	         ', p_vendor_id = '|| to_char (p_vendor_id) ||
	         ', p_vendor_site_id = '|| to_char (p_vendor_site_id) ||
	         ', p_tax_classification_code = '||p_tax_classification_code ||
	         ', APPL_SHORT_NAME = '||APPL_SHORT_NAME ||
	         ', FUNC_SHORT_NAME = '||FUNC_SHORT_NAME ||
	         ', p_calling_sequence = '||p_calling_sequence);

	   ELSE --Bug 6510307
	     FND_MESSAGE.SET_NAME('IGC', 'IGC_DEBUG');
             FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS',
	          ' p_ref_doc_application_id = '|| to_char (p_ref_doc_application_id) ||
                 ', p_ref_doc_entity_code = '||p_ref_doc_entity_code ||
                 ',p_ref_doc_event_class_code = '||p_ref_doc_event_class_code ||
                 ',p_ref_doc_trx_id = '||TO_CHAR(p_ref_doc_trx_id) ||
                 ',p_ref_doc_line_id = '||TO_CHAR(p_ref_doc_line_id) ||
                 ',p_ref_doc_trx_level_type = '||p_ref_doc_trx_level_type ||
	         ', p_vendor_id = '|| to_char (p_vendor_id) ||
	         ', p_vendor_site_id = '|| to_char (p_vendor_site_id) ||
	         ', p_code_combination_id = '|| to_char (p_code_combination_id) ||
	         ', p_concatenated_segments = '||p_concatenated_segments ||
                 ', p_templ_tax_classification_cd = '||p_templ_tax_classification_cd||
	         ', p_tax_classification_code = '||p_tax_classification_code ||
                 ', p_allow_tax_code_override_flag = '||p_allow_tax_code_override_flag ||
     	         ', APPL_SHORT_NAME = '||APPL_SHORT_NAME ||
	         ', FUNC_SHORT_NAME = '||FUNC_SHORT_NAME ||
	         ', p_calling_sequence = '||p_calling_sequence);


          END IF;
       END IF;
       APP_EXCEPTION.RAISE_EXCEPTION;
END get_default_tax_classification;


------------------------------------------------------------------
--
-- bug#4891362- overloaded version
--

PROCEDURE  get_default_tax_classification(
   p_ref_doc_application_id             IN  zx_lines_det_factors.ref_doc_application_id%TYPE,
   p_ref_doc_entity_code                IN  zx_lines_det_factors.ref_doc_entity_code%TYPE,
   p_ref_doc_event_class_code           IN  zx_lines_det_factors.ref_doc_event_class_code%TYPE,
   p_ref_doc_trx_id                     IN  zx_lines_det_factors.ref_doc_trx_id%TYPE,
   p_ref_doc_line_id                    IN  zx_lines_det_factors.ref_doc_line_id%TYPE,
   p_ref_doc_trx_level_type             IN  zx_lines_det_factors.ref_doc_trx_level_type%TYPE,
   p_vendor_id				IN  po_vendors.vendor_id%TYPE,
   p_vendor_site_id 			IN  po_vendor_sites.vendor_site_id%TYPE,
   p_code_combination_id  		IN  gl_code_combinations.code_combination_id%TYPE,
   p_concatenated_segments		IN  varchar2,
   p_templ_tax_classification_cd        IN  varchar2,
   p_ship_to_location_id		IN  hr_locations_all.location_id%TYPE,
   p_ship_to_loc_org_id   		IN  mtl_system_items.organization_id%TYPE,
   p_inventory_item_id   		IN  mtl_system_items.inventory_item_id%TYPE,
   p_item_org_id   			IN  mtl_system_items.organization_id%TYPE,
   p_tax_classification_code		IN  OUT NOCOPY VARCHAR2,
   p_allow_tax_code_override_flag           OUT NOCOPY zx_acct_tx_cls_defs.allow_tax_code_override_flag%TYPE,
   p_tax_user_override_flag		IN  VARCHAR2,
   p_user_tax_name	       		IN  VARCHAR2,
   --p_legal_entity_id                    IN  zx_lines.legal_entity_id%TYPE,
   APPL_SHORT_NAME			IN  fnd_application.application_short_name%TYPE,
   FUNC_SHORT_NAME			IN  VARCHAR2,
   p_calling_sequence			IN  VARCHAR2,
   p_event_class_code                   IN  VARCHAR2,
   p_entity_code                        IN  VARCHAR2,
   p_application_id                     IN  NUMBER,
   p_internal_organization_id           IN  NUMBER) IS

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification.BEGIN',

                     'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: get_default_tax_classification (+)');
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification',

                     'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: overloaded version 2');

   END IF;
   Initialize; --Bug 5712279
   --
   -- set default value
   --

   ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification(
                                           p_ref_doc_application_id,
                                           p_ref_doc_entity_code,
                                           p_ref_doc_event_class_code,
                                           p_ref_doc_trx_id,
                                           p_ref_doc_line_id,
                                           p_ref_doc_trx_level_type,
					   p_vendor_id,
					   p_vendor_site_id,
					   p_code_combination_id,
				   	   p_concatenated_segments,
                                           p_templ_tax_classification_cd,
					   p_ship_to_location_id,
					   p_ship_to_loc_org_id,
					   p_inventory_item_id,
					   p_item_org_id ,
					   p_tax_classification_code,
					   p_allow_tax_code_override_flag,
					   p_tax_user_override_flag,  --'N',
					   p_user_tax_name,    --null,
                                           null, --p_legal_entity_id,
					   APPL_SHORT_NAME,
					   FUNC_SHORT_NAME,
					   p_calling_sequence,
                                           p_event_class_code,
                                           p_entity_code,
                                           p_application_id,
                                           p_internal_organization_id);
   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification.END',

                     'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: get_default_tax_classification (-)');
   END IF;

END get_default_tax_classification;

-------------------------------------------------------------------------------
--
-- PRIVATE FUNCTION
-- get_input_tax_classif_code
--
-- DESCRIPTION
-- This function will look for the tax code that is specified at the
-- po shipment level, if the system options specify that tax is defaulted
-- from this level. It will return the tax code if one is found for the
-- po shipment and the given date. It returns null if a valid tax code is
-- not found.
--
-- RETURNS
-- Tax code if one is found at the shipment level.
-- Null if a valid tax code is not found.
--
-- CALLED FROM
-- get_default_tax_classification()
--
-- HISTORY
-- 15-JUL-97  Fiona Purves created based on AR API.
-- 11-MAY-05  Phong La     modified for bug#4310278, po_line_locations
--                         will no longer carry tax columns, need to
--                         get input_tax_classification_code from
--                         zx_lines_det_factors
-------------------------------------------------------------------------------

FUNCTION  get_input_tax_classif_code (
  --p_line_location_id	IN  po_line_locations.line_location_id%TYPE,
  p_ref_doc_application_id   IN  zx_lines_det_factors.ref_doc_application_id%TYPE,
  p_ref_doc_entity_code      IN  zx_lines_det_factors.ref_doc_entity_code%TYPE,
  p_ref_doc_event_class_code IN  zx_lines_det_factors.ref_doc_event_class_code%TYPE,
  p_ref_doc_trx_id           IN  zx_lines_det_factors.ref_doc_trx_id%TYPE,
  p_ref_doc_line_id          IN  zx_lines_det_factors.ref_doc_line_id%TYPE,
  p_ref_doc_trx_level_type   IN  zx_lines_det_factors.ref_doc_trx_level_type%TYPE,
  p_calling_sequence	   IN varchar2) RETURN VARCHAR2 IS

  l_curr_calling_sequence 	VARCHAR2(2000);
  l_tax_classification_code	VARCHAR2(30);

-- NOTE: TAX_CODE_ID column in PO_LINE_LOCATIONS should be replaced
--       with tax classification code and the following query needs
--       to replace tax_code_id with right column
/*
 * bug#4310278 get input_tax_classification_code from
 * zx_lines_det_factors
  CURSOR sel_input_tax_cls_cd IS
  SELECT tc.lookup_code
    FROM fnd_lookups tc,
	 po_line_locations ll
   WHERE ll.line_location_id = p_line_location_id
     AND tc.lookup_code = ll.tax_code_id -- replace with classification_code
     AND tc.lookup_type = 'ZX_INPUT_CLASSIFICATIONS'
     AND nvl(tc.enabled_flag,'Y') = 'Y';
*/

  CURSOR sel_input_tax_cls_cd
    (c_ref_doc_application_id    ZX_LINES_DET_FACTORS.application_id%TYPE,
     c_ref_doc_entity_code       ZX_LINES_DET_FACTORS.entity_code%TYPE,
     c_ref_doc_event_class_code  ZX_LINES_DET_FACTORS.event_class_code%TYPE,
     c_ref_doc_trx_id            ZX_LINES_DET_FACTORS.trx_id%TYPE,
     c_ref_doc_line_id           ZX_LINES_DET_FACTORS.trx_line_id%TYPE,
     c_ref_doc_trx_level_type    ZX_LINES_DET_FACTORS.trx_level_type%TYPE)
   IS
    SELECT input_tax_classification_code
      FROM zx_lines_det_factors
      WHERE application_id   = c_ref_doc_application_id
        AND entity_code      = c_ref_doc_entity_code
        AND event_class_code = c_ref_doc_event_class_code
        AND trx_id           = c_ref_doc_trx_id
        AND trx_line_id      = c_ref_doc_line_id
        AND trx_level_type   = c_ref_doc_trx_level_type;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_input_tax_classif_code.BEGIN',
                    'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: get_input_tax_classif_code (+)');
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_input_tax_classif_code',

                    'p_calling_sequence == >'||p_calling_sequence);
  END IF;

  debug_loc := 'get_input_tax_classif_code';
  l_curr_calling_sequence := 'ZX_AP_TAX_CLASSIFICATN_DEF_PKG.'||debug_loc||'<-'||p_calling_sequence;

  l_tax_classification_code := NULL;

  OPEN sel_input_tax_cls_cd
             (p_ref_doc_application_id,
              p_ref_doc_entity_code,
              p_ref_doc_event_class_code,
              p_ref_doc_trx_id,
              p_ref_doc_line_id,
              p_ref_doc_trx_level_type);
  FETCH sel_input_tax_cls_cd INTO l_tax_classification_code;
  CLOSE sel_input_tax_cls_cd;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_input_tax_classif_code',

                    'l_tax_classification_code  =='||l_tax_classification_code);
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_input_tax_classif_code.END',
                    'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: get_input_tax_classif_code (-)');
  END IF;

  RETURN (l_tax_classification_code);

  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', 'get_input_tax_classif_code- '||
                          sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_MSG_PUB.Add;
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_input_tax_classif_code',
                        sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      END IF;
      IF (sel_input_tax_cls_cd%ISOPEN ) THEN
         CLOSE sel_input_tax_cls_cd;
      END IF;
      RAISE;
END get_input_tax_classif_code;


-------------------------------------------------------------------------------
--
-- PRIVATE FUNCTION
-- get_site_tax
--
-- DESCRIPTION
-- This function will look for the tax code that is specified at the
-- supplier site level, if the system options specify that tax is defaulted
-- from this level. It will return the tax code if one is found for the
-- supplier site and the given date. It returns null if a valid tax code is
-- not found.
--
-- RETURNS
-- Tax code if one is found at the supplier site level
-- Null if a valid tax code is not found.
--
-- CALLED FROM
-- get_default_tax_classification()
--
-- HISTORY
-- 15-JUL-97  Fiona Purves created based on AR API.
-- 07-DEC-05  Phong La     bug#4868489- changed party_type_code
--                         to THIRD_PARTY_SITE
-------------------------------------------------------------------------------

FUNCTION  get_site_tax (
  p_vendor_site_id	     IN  po_vendor_sites.vendor_site_id%TYPE,
  p_calling_sequence	     IN  varchar2) RETURN VARCHAR2 IS

  l_curr_calling_sequence 	VARCHAR2(2000);
  l_tax_classification_code	VARCHAR2(30);

  -- Bug#5066122
  l_party_site_id               NUMBER;
  l_count                       NUMBER;

  CURSOR sel_site_tax_sup_site
    (c_vendor_site_id   NUMBER)
  IS
  SELECT vat_code, party_site_id
    FROM ap_supplier_sites
   WHERE vendor_site_id = c_vendor_site_id;

  CURSOR sel_site_tax_ptp
    (c_party_site_id   NUMBER)
  IS
  SELECT vs.tax_classification_code
    FROM zx_party_tax_profile vs,
         zx_input_classifications_v tc
   WHERE vs.party_id = c_party_site_id
     AND vs.party_type_code = 'THIRD_PARTY_SITE'
     AND vs.tax_classification_code = tc.lookup_code
     AND tc.lookup_type = 'ZX_INPUT_CLASSIFICATIONS'
     AND nvl(tc.enabled_flag,'Y') = 'Y'
     AND tc.org_id in (sysinfo.org_id,-99);

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_site_tax.BEGIN',
                    'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: Get_site_tax (+)');
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_site_tax',
                    'p_vendor_site_id == >'||to_char(p_vendor_site_id));
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_site_tax',
                    'p_calling_sequence == >'||p_calling_sequence);
  END IF;
  debug_loc := 'Get_Site_Tax';
  l_curr_calling_sequence := 'ZX_AP_TAX_CLASSIFICATN_DEF_PKG.'||debug_loc||'<-'||p_calling_sequence;
  IF (g_level_statement >= g_current_runtime_level ) THEN
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_site_tax',
                        'p_calling_sequence  =='||p_calling_sequence);
  END IF;

  l_tax_classification_code := NULL;
  l_party_site_id           := NULL;

  -- Bug#5066122

  IF p_vendor_site_id IS NOT NULL THEN
    OPEN sel_site_tax_sup_site(p_vendor_site_id);
    FETCH sel_site_tax_sup_site INTO
              l_tax_classification_code,
              l_party_site_id;
    CLOSE sel_site_tax_sup_site;
  END IF;

  IF l_tax_classification_code IS NOT NULL THEN
    --
    -- check if tax_classification_code is valid in fnd_lookups
    --
    validate_tax_classif_code(l_tax_classification_code,
                              l_count);

    IF l_count =  0 THEN
      --
      -- l_tax_classification_code is no longer valid
      -- need to get it from zx_party_tax_profiles
      l_tax_classification_code := NULL;
    END IF;
  END IF;

  IF (l_tax_classification_code IS NULL AND
      l_party_site_id IS NOT NULL) THEN
    OPEN sel_site_tax_ptp(l_party_site_id);
    FETCH sel_site_tax_ptp INTO l_tax_classification_code;
    CLOSE sel_site_tax_ptp;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.G
et_Vendor_Tax',
                    'l_party_site_id == >'||to_char(l_party_site_id));
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_site_tax',
                    'l_tax_classification_code  =='||l_tax_classification_code);
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_site_tax.END',
                    'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: Get_site_tax (-)');
  END IF;

  RETURN (l_tax_classification_code);

  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', 'Get_site_tax- '||
                          sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_MSG_PUB.Add;
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_site_tax',
                        sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      END IF;
      IF (sel_site_tax_sup_site%ISOPEN ) THEN
        CLOSE sel_site_tax_sup_site;
      END IF;
      IF (sel_site_tax_ptp%ISOPEN ) THEN
        CLOSE sel_site_tax_ptp;
      END IF;
      RAISE;
END get_site_tax;

-------------------------------------------------------------------------------
--
-- PRIVATE FUNCTION
-- get_vendor_tax
--
-- DESCRIPTION
-- This function will look for the tax code that is specified at the
-- supplier level, if the system options specify that tax is defaulted
-- from this level. It will return the tax code if one is found for the
-- supplier and the given date. It returns null if a valid tax code is
-- not found.
--
-- RETURNS
-- Tax code if one is found at the supplier level and valid for the
-- given date.  Null if a valid tax code is not found.
--
-- CALLED FROM
-- get_default_tax_classification()
--
-- HISTORY
-- 15-JUL-97  Fiona Purves created based on AR API.
-- 07-DEC-05  Phong La     Bug#4868489- changed party_type_code
--                         to THIRD_PARTY
-------------------------------------------------------------------------------

FUNCTION  get_vendor_tax (
    p_vendor_id		 IN  po_vendors.vendor_id%TYPE,
    p_calling_sequence	 IN  varchar2)

RETURN VARCHAR2 IS

  l_curr_calling_sequence 	VARCHAR2(2000);
  l_tax_classification_code	VARCHAR2(30);

  -- Bug#5066122
  l_party_id                    NUMBER;
  l_count                       NUMBER;

  CURSOR sel_vendor_tax_sup
    (c_vendor_id       NUMBER)
  IS
  SELECT vat_code, party_id
    FROM ap_suppliers
   WHERE vendor_id = c_vendor_id;

  CURSOR sel_vendor_tax_ptp
    (c_party_id  NUMBER)
  IS
  SELECT v.tax_classification_code
    FROM zx_party_tax_profile v,
         zx_input_classifications_v tc
   WHERE v.party_id = c_party_id
     AND v.party_type_code = 'THIRD_PARTY'
     AND v.tax_classification_code = tc.lookup_code
     AND tc.lookup_type = 'ZX_INPUT_CLASSIFICATIONS'
     AND nvl(tc.enabled_flag,'Y') = 'Y'
     AND tc.org_id in (sysinfo.org_id,-99);

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_vendor_tax.BEGIN',
                    'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: Get_Vendor_Tax (+)');
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Vendor_Tax',
                    'p_vendor_id == >'||to_char(p_vendor_id));
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Vendor_Tax',
                    'p_calling_sequence == >'||p_calling_sequence);
  END IF;
  debug_loc := 'Get_Vendor_Tax';
  l_curr_calling_sequence := 'ZX_AP_TAX_CLASSIFICATN_DEF_PKG.'||debug_loc||'<-'||p_calling_sequence;
  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Vendor_Tax',
                    'l_curr_calling_sequence =='||l_curr_calling_sequence );
  END IF;

  l_tax_classification_code := NULL;
  l_party_id                := NULL;

  -- Bug#5066122

  IF p_vendor_id IS NOT NULL THEN
    OPEN sel_vendor_tax_sup(p_vendor_id);
    FETCH sel_vendor_tax_sup INTO
             l_tax_classification_code,
             l_party_id;
    CLOSE sel_vendor_tax_sup;
  END IF;

  IF l_tax_classification_code IS NOT NULL THEN
    --
    -- check if tax_classification_code is valid in fnd_lookups
    --
    validate_tax_classif_code(l_tax_classification_code,
                              l_count);

    IF l_count =  0 THEN
      --
      -- l_tax_classification_code is no longer valid
      -- need to get it from zx_party_tax_profiles
      l_tax_classification_code := NULL;
    END IF;
  END IF;

  IF (l_tax_classification_code IS NULL AND
      l_party_id IS NOT NULL) THEN
    OPEN sel_vendor_tax_ptp(l_party_id);
    FETCH sel_vendor_tax_ptp INTO l_tax_classification_code;
    CLOSE sel_vendor_tax_ptp;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Vendor_Tax',
                    'l_party_id == >'||to_char(l_party_id));
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Vendor_Tax',
                    'From get_vendor_tax ,l_tax_classification_code  =='
                     ||l_tax_classification_code);
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Vendor_Tax.END',
                    'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: Get_Vendor_Tax (-)');
  END IF;

  RETURN (l_tax_classification_code);

  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', 'Get_Vendor_Tax- '||
                            sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_MSG_PUB.Add;
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Vendor_Tax',
                        sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      END IF;
      IF (sel_vendor_tax_sup%ISOPEN) THEN
        CLOSE sel_vendor_tax_sup;
      END IF;
      IF (sel_vendor_tax_ptp%ISOPEN) THEN
        CLOSE sel_vendor_tax_ptp;
      END IF;

      RAISE;
END get_vendor_tax;

-------------------------------------------------------------------------------
--
-- PRIVATE FUNCTION
-- get_ship_to_location_tax
--
-- DESCRIPTION
-- This function will look for the tax code that is specified at the
-- ship-to location level, if the system options specify that tax is defaulted
-- from this level. It will return the tax code if one is found for the
-- ship-to location and the given date. It returns null if a valid tax code is
-- not found.
--
-- The SELECT statement that retrieved the tax name was different in the
-- workbenches and the server-side code, as follows:
--
-- In the Enter Purchase Orders and Enter Releases forms, the tax name
-- was retrieved where the location_id matched the given location_id, and the
-- inventory_organization_id matched the given ship_to_organization_id,
-- or was null.
-- In the AutoCreate and the Create Releases programs, the tax name was
-- retrieved using the location_id only.
-- The API will manage cases where a ship-to organization is passed or not.
--
-- RETURNS
-- Tax code if one is found at the ship-to location level and valid for the
-- given date.  Null if a valid tax code is not found.
--
-- CALLED FROM
-- get_default_tax_classification()
--
-- HISTORY
-- 15-JUL-97  Fiona Purves created based on AR API.
-- 07-DEC-05  Phong La     bug#4868489- modified to get ptp_id from TCM api
-------------------------------------------------------------------------------

FUNCTION  get_ship_to_location_tax (
  p_ship_to_loc_id	IN  hr_locations_all.location_id%TYPE,
  p_ship_to_loc_org_id	IN  hr_locations_all.inventory_organization_id%TYPE,
  p_legal_entity_id     IN  zx_lines.legal_entity_id%TYPE,
  p_calling_sequence	IN  varchar2 )

RETURN VARCHAR2 IS
  l_curr_calling_sequence 	VARCHAR2(2000);
  l_tax_classification_code	VARCHAR2(30);
  l_party_type_code             VARCHAR2(30);
  l_return_status               VARCHAR2(30);
  l_ptp_id                      ZX_PARTY_TAX_PROFILE.party_tax_profile_id%TYPE;

  CURSOR sel_ship_to_loc_tax
    (c_ptp_id    ZX_PARTY_TAX_PROFILE.party_tax_profile_id%TYPE)
  IS
  SELECT ptp.tax_classification_code
    FROM zx_party_tax_profile ptp,
         zx_input_classifications_v tc
   WHERE ptp.party_tax_profile_id = c_ptp_id
     AND ptp.tax_classification_code = tc.lookup_code
     AND tc.lookup_type = 'ZX_INPUT_CLASSIFICATIONS'
     AND nvl(tc.enabled_flag,'Y') = 'Y'
     AND tc.org_id in (sysinfo.org_id,-99);

  CURSOR get_ship_to_tax
    (c_ship_to_loc_id    HR_LOCATIONS_ALL.location_id%TYPE)
  IS
  SELECT hr.tax_name
    FROM hr_locations_all hr,
         zx_input_classifications_v tc
   WHERE hr.location_id = c_ship_to_loc_id
     AND hr.tax_name = tc.lookup_code
     AND tc.lookup_type IN ('ZX_INPUT_CLASSIFICATIONS', 'ZX_WEB_EXP_TAX_CLASSIFICATIONS')
     AND nvl(tc.enabled_flag,'Y') = 'Y'
     AND tc.org_id in (sysinfo.org_id,-99);

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Ship_To_Location_Tax.BEGIN',
                    'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: Get_Ship_To_Location_Tax (+)');
  END IF;
  debug_loc := 'Get_Ship_To_Location_Tax';
  l_curr_calling_sequence := 'ZX_AP_TAX_CLASSIFICATN_DEF_PKG.'||debug_loc||'<-'||p_calling_sequence;
  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Ship_To_Location_Tax',
                    'Getting tax classification code from ship-to location');
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Ship_To_Location_Tax',
                    'p_ship_to_loc_id == > '||to_char(p_ship_to_loc_id ));
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Ship_To_Location_Tax',
                    'p_ship_to_loc_org_id   == >'||to_char(p_ship_to_loc_org_id ));
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Ship_To_Location_Tax',
                    'p_calling_sequence == > '|| p_calling_sequence );
  END IF;

  l_tax_classification_code := NULL;
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- get ptp id
  --

  l_party_type_code   := 'LEGAL_ESTABLISHMENT';

  ZX_TCM_PTP_PKG.get_ptp(
           p_party_id          => p_ship_to_loc_org_id, --Inventory Org Id
           p_Party_Type_Code   => l_party_type_code,    --Legal Establishment
           p_le_id             => p_legal_entity_id,    --Legal Entity ID
           p_inventory_loc     => p_ship_to_loc_id,     --Inventory Location ID
           p_ptp_id            => l_ptp_id,             -- ptp id
           p_return_status     => l_return_status);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Ship_To_Location_Tax',
                   'l_ptp_id = ' || TO_CHAR(l_ptp_id));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Ship_To_Location_Tax',
                   'l_return_status = ' || l_return_status);
  END IF;

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS )THEN
      -- return NULL to caller
      RETURN l_tax_classification_code;
  END IF;

  OPEN sel_ship_to_loc_tax(l_ptp_id);
  FETCH sel_ship_to_loc_tax INTO l_tax_classification_code;
  CLOSE sel_ship_to_loc_tax;

  IF l_tax_classification_code IS NULL THEN
    OPEN get_ship_to_tax(p_ship_to_loc_id);
    FETCH get_ship_to_tax INTO l_tax_classification_code;
    CLOSE get_ship_to_tax;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Ship_To_Location_Tax',
                    'l_tax_classification_code  =='||l_tax_classification_code );
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Ship_To_Location_Tax.END',
                    'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: Get_Ship_To_Location_Tax (-)');
  END IF;

  RETURN (l_tax_classification_code);

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', 'Get_Ship_To_Location_Tax- '||
                          sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_ship_to_location_tax',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
    IF (sel_ship_to_loc_tax%ISOPEN) THEN
      CLOSE sel_ship_to_loc_tax;
    END IF;
    RAISE;
END get_ship_to_location_tax;

-----------------------------------------------------------------------------
--
-- bug#4891362-  overloaded version
--

FUNCTION  get_ship_to_location_tax (
  p_ship_to_loc_id	IN  hr_locations_all.location_id%TYPE,
  p_ship_to_loc_org_id	IN  hr_locations_all.inventory_organization_id%TYPE,
  --p_legal_entity_id     IN  zx_lines.legal_entity_id%TYPE,
  p_calling_sequence	IN  varchar2 )

RETURN VARCHAR2 IS

  l_tax_classification_code     VARCHAR2(30);

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Ship_To_Location_Tax.BEGIN',
                    'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: Get_Ship_To_Location_Tax (+)');
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Ship_To_Location_Tax',
                    'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: Get_Ship_To_Location_Tax overloaded version');

  END IF;

  l_tax_classification_code := NULL;

  l_tax_classification_code := get_ship_to_location_tax(
                                    p_ship_to_loc_id,
                                    p_ship_to_loc_org_id,
                                    null,    --p_legal_entity_id,
                                    p_calling_sequence);


  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Ship_To_Location_Tax.END',
                    'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: Get_Ship_To_Location_Tax (-)');
  END IF;

  RETURN (l_tax_classification_code);

END get_ship_to_location_tax;

--------------------------------------------------------------
--
-- bug#8717533
--
PROCEDURE  get_def_tax_classif_from_acc(
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
   p_default_hierarchy                      OUT NOCOPY BOOLEAN) IS

 l_tax_classification_code      VARCHAR2(30);
 l_enforce_tax_from_acct_flag   VARCHAR2(1);
 l_enforce_tax_from_refdoc_flag VARCHAR2(1);
 l_enforced_tax_found	 	boolean := FALSE;
 l_tax_classification_found	boolean := FALSE;
 l_found                        boolean := FALSE;
 l_curr_calling_sequence 	VARCHAR2(2000);
 l_item_taxable_flag            VARCHAR2(1);
 -- Added the following variable as part of the fix for the bug 2608697 by zmohiudd.
 l_shipment_taxable_flag        VARCHAR2(1);
 l_count                        NUMBER;
 l_return_status                VARCHAR2(80);

CURSOR sel_item_taxable_flag
         (c_inventory_item_id   mtl_system_items_b.inventory_item_id%TYPE,
          c_item_org_id         mtl_system_items_b.organization_id%TYPE,
          c_ship_to_loc_org_id  mtl_system_items_b.organization_id%TYPE) IS

 SELECT taxable_flag
   FROM mtl_system_items si
  WHERE si.inventory_item_id = c_inventory_item_id
    AND si.organization_id = nvl(c_ship_to_loc_org_id, c_item_org_id);

  CURSOR c_evnt_cls_options (c_org_id           NUMBER,
                             c_application_id   NUMBER,
                             c_entity_code      VARCHAR2,
                             c_event_class_code VARCHAR2) IS
  select enforce_tax_from_acct_flag,
         enforce_tax_from_ref_doc_flag
    from zx_evnt_cls_options
   where application_id = c_application_id
     and entity_code = c_entity_code
     and event_class_code = c_event_class_code
     and first_pty_org_id = (Select party_tax_profile_id
                               From zx_party_tax_profile
                              where party_id = c_org_id
                                and party_type_code = 'OU')
     and sysdate >= effective_from
     and sysdate <= nvl(effective_to,sysdate)
     and enabled_flag = 'Y';

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc.BEGIN',
                       'get_def_tax_classif_from_acc(+) ');
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_ref_doc_application_id == >'||TO_CHAR(p_ref_doc_application_id));
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_ref_doc_entity_code == >'||p_ref_doc_entity_code);
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_ref_doc_event_class_code == >'||p_ref_doc_event_class_code);
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_ref_doc_trx_id == >'||TO_CHAR(p_ref_doc_trx_id));
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_ref_doc_line_id == >'||TO_CHAR(p_ref_doc_line_id));
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_ref_doc_trx_level_type == >'||p_ref_doc_trx_level_type);
      	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_vendor_id  == >'       ||to_char(p_vendor_id ));
  	    FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_vendor_site_id  == >'  ||to_char(p_vendor_site_id ));
  	    FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_code_combination_id = >'||to_char(p_code_combination_id) );
  	    FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_concatenated_segments== >'||p_concatenated_segments );
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_templ_tax_classification_cd == >'||p_templ_tax_classification_cd);
  	    FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_ship_to_location_id == >'||to_char(p_ship_to_location_id) );
  	    FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_ship_to_loc_org_id  == >'||to_char(p_ship_to_loc_org_id) );
  	    FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_inventory_item_id  == >'||to_char(p_inventory_item_id) );
  	    FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_item_org_id  == >'     ||to_char( p_item_org_id));
  	    FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_tax_classification_code  == >' ||p_tax_classification_code);
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_allow_tax_code_override_flag ==>'|| p_allow_tax_code_override_flag);
  	    FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_tax_user_override_flag  ==>'||p_tax_user_override_flag);
  	    FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_user_tax_name  ==>'||p_user_tax_name);
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_legal_entity_id ==>'||TO_CHAR(p_legal_entity_id));
  	    FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'APPL_SHORT_NAME  == >'||APPL_SHORT_NAME );
  	    FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'FUNC_SHORT_NAME   == >'||FUNC_SHORT_NAME );
  	    FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_calling_sequence  == >'||p_calling_sequence );
  	    FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_event_class_code  == >'||p_event_class_code );
  	    FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_entity_code  == >'||p_entity_code );
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_application_id == >'||TO_CHAR(p_application_id));
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'p_internal_organization_id == >'||TO_CHAR(p_internal_organization_id));

  END IF;

  -- Bug#4090842- call populate ap/po default options here
  -- Initialize;

  --
  -- check if need to repopulate AP/PO/IGC default options
  --
  IF APPL_SHORT_NAME = 'SQLAP' THEN
    IF (sysinfo.ap_info.org_id IS NULL OR
        (sysinfo.ap_info.org_id <> p_internal_organization_id)) THEN
      pop_ap_def_option_hier(
                    p_internal_organization_id,
                    p_application_id,
                    p_event_class_code,
                    l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;
    END IF;
   END IF;

  l_tax_classification_found := FALSE;

  debug_loc := 'get_def_tax_classif_from_acc';

  l_curr_calling_sequence := 'ZX_AP_TAX_CLASSIFICATN_DEF_PKG.'||debug_loc||'<-'||p_calling_sequence;

  --
  -- Get Payables/Purchasing default tax code.
  -- Hierarchy for PO:  Ship-to Location, Item, Vendor, Vendor Site and System.
  -- Hierarchy for AP:  Purchase Order Shipment, Vendor, Vendor Site, Natural Account, System,
  -- and Template.
  -- Hierarchy for CC:  Vendor Site, Vendor and System.
  -- The search ends when a tax code is found.
  --

  --
  -- if use_tax_classification_flag is no, set tax_classification_code
  -- to NULL and return, no need to search the default hierachy
  --

  IF (APPL_SHORT_NAME = 'SQLAP' AND
      NOT search_for_ap_tax) THEN
    p_tax_classification_code := NULL;
    p_default_hierarchy := FALSE;
    RETURN;
  END IF;

  IF (p_tax_user_override_flag = 'Y') THEN
     -- User has overridden tax code and the user tax code should be used.
     -- If tax name is null, then this is an explicit request for a null
     -- tax name and null should be returned.

     p_tax_classification_code := p_user_tax_name;
     l_tax_classification_found := TRUE;
     p_default_hierarchy := FALSE;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                    'l_tax_classification_code is found  =='||l_tax_classification_code);
  END IF;

  IF (l_tax_classification_found = FALSE) THEN
    IF (APPL_SHORT_NAME = 'SQLAP') THEN
      IF (search_ap_def_hier = TRUE) THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                             'Getting Event Class Options');
        END IF;
        open c_evnt_cls_options (p_internal_organization_id,
                                 200,
                                 p_entity_code,
                                 p_event_class_code);
        fetch c_evnt_cls_options into l_enforce_tax_from_acct_flag,
                                      l_enforce_tax_from_refdoc_flag;
        close c_evnt_cls_options;

        IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                             'Entity Code:' || p_entity_code);
              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                             'Event Class Code:' || p_event_class_code);
              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                             'Enforce Tax From Account  ==' || l_enforce_tax_from_acct_flag);
       	      FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                             'Getting tax code for AP ');
        END IF;

        IF (l_enforce_tax_from_refdoc_flag = 'Y') THEN
	        -- Tax code from the PO shipment is enforced
	        -- If a tax code exists for shipment then there is
	        -- no need to search any further, as this takes
	        -- precedence over the rest of the hierarchy.

          l_tax_classification_code := get_input_tax_classif_code (
                                             p_ref_doc_application_id,
                                             p_ref_doc_entity_code,
                                             p_ref_doc_event_class_code,
                                             p_ref_doc_trx_id,
                                             p_ref_doc_line_id,
                                             p_ref_doc_trx_level_type,
                                             l_curr_calling_sequence);

          IF (l_tax_classification_code is not NULL) THEN
	          -- Tax found on PO shipment, do not search further
            l_enforced_tax_found := TRUE;
            p_default_hierarchy := FALSE;
            IF (g_level_statement >= g_current_runtime_level ) THEN
            	    FND_LOG.STRING(g_level_statement,
                                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                                   'l_tax_classification_code =='||l_tax_classification_code );
            END IF;
          END IF;
        ELSIF (l_enforce_tax_from_acct_flag = 'Y') THEN
          -- Tax code from the account is enforced
          -- If a tax code exists for this account and
          -- override of the tax code is not allowed then
          -- no need to search any further, as the non-overridable accounts take
          -- precedence over the rest of the tax defaulting hierarchy
          -- This includes both Input and Non-taxable accounts.

          IF (g_level_statement >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                   'Tax from account is enforced');
               FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                   ' Calling get_account_tax ');
          END IF;
          get_account_tax (p_code_combination_id,
		                    	 p_concatenated_segments,
          			           p_tax_classification_code,
          			           p_allow_tax_code_override_flag,
          			           l_tax_classification_found,
          			           l_curr_calling_sequence);
          l_tax_classification_code := p_tax_classification_code;
          IF (g_level_statement >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                   'l_tax_classification_code =='||l_tax_classification_code);
          END IF;
          IF (p_allow_tax_code_override_flag = 'N') THEN
            -- Override is not allowed, do not search further
            l_enforced_tax_found := TRUE;
            p_default_hierarchy := TRUE;
          END IF;
        END IF; -- ap_match_on_tax_flag

        IF (l_enforced_tax_found = FALSE ) THEN
          p_default_hierarchy := FALSE;
          l_count := aptaxtab.COUNT;
          <<Ap_Tax_Loop1>>
          FOR i in 1..l_count  LOOP
            IF (aptaxtab (i) = 'NATURAL_ACCOUNT') THEN
              p_default_hierarchy := TRUE;
              exit Ap_Tax_Loop1;
            END IF;
          END LOOP Ap_Tax_Loop1;
          IF NOT p_default_hierarchy THEN
            RETURN;
          END IF;
        END IF;

        IF (l_enforced_tax_found = FALSE ) THEN
          -- If tax is not enforced from the account, or is enforced but
          -- the tax code is overrideable, then continue the search

          l_count := aptaxtab.COUNT;
          <<Ap_Tax_Loop>>
          FOR i in 1..l_count  LOOP
            IF (aptaxtab (i) is NULL) THEN
              --
              -- default hierachy options from 1 to 7 can not
              -- have gap, if the current one is NULL, the
              -- rest would be NULL, there is no need to
              -- continue looping
              --
              p_default_hierarchy := FALSE;
              exit Ap_Tax_Loop;
            ELSE
              --  aptaxtab (i) is not NULL

   	          IF (aptaxtab (i) = 'REFERENCE_DOCUMENT') THEN
                IF (g_level_statement >= g_current_runtime_level ) THEN
         	           FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                        'Getting tax code from shipment');
         	           FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                        'Calling get_input_tax_classif_code ');
                END IF;
      	        l_tax_classification_code := get_input_tax_classif_code (
                                             p_ref_doc_application_id,
                                             p_ref_doc_entity_code,
                                             p_ref_doc_event_class_code,
                                             p_ref_doc_trx_id,
                                             p_ref_doc_line_id,
                                             p_ref_doc_trx_level_type,
                                             l_curr_calling_sequence);

                IF (l_tax_classification_code IS NOT NULL) THEN
                  l_tax_classification_found := TRUE;
                  p_default_hierarchy := FALSE;
                  IF (g_level_statement >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                          'l_tax_classification_code ==' ||l_tax_classification_code);
                  END IF;
                  exit Ap_Tax_Loop;
                END IF;
              END IF;

              IF (aptaxtab (i) = 'SHIP_FROM_PARTY_SITE') THEN
                IF (g_level_statement >= g_current_runtime_level ) THEN
         	        FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                     'Getting tax code from supplier site');
                END IF;
                l_tax_classification_code := get_site_tax (
                                                        p_vendor_site_id,
					                                              l_curr_calling_sequence);
                IF (l_tax_classification_code IS NOT NULL) THEN
                  l_tax_classification_found := TRUE;
                  p_default_hierarchy := FALSE;
                  IF (g_level_statement >= g_current_runtime_level ) THEN
                     FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                       'l_tax_classification_code ==' ||l_tax_classification_code);
                  END IF;
                  exit Ap_Tax_Loop;
                END IF;
              END IF;

              IF (aptaxtab (i) = 'SHIP_FROM_PARTY') THEN
                IF (g_level_statement >= g_current_runtime_level ) THEN
             	    FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                      'Getting tax code from supplier');
                END IF;
                l_tax_classification_code := get_vendor_tax (
                                                        p_vendor_id,
       					                                        l_curr_calling_sequence);
                IF (l_tax_classification_code IS NOT NULL) THEN
                  l_tax_classification_found := TRUE;
                  p_default_hierarchy := FALSE;
                  IF (g_level_statement >= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                      'l_tax_classification_code ==' ||l_tax_classification_code);
                  END IF;
                  exit Ap_Tax_Loop;
                END IF;
              END IF;

              IF (aptaxtab (i) = 'NATURAL_ACCOUNT') THEN
                IF (g_level_statement >= g_current_runtime_level ) THEN
         	        FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                    'Getting tax code from account');
                  END IF;
                  get_account_tax (p_code_combination_id,
	       			                     p_concatenated_segments,
			         	                   p_tax_classification_code,
				                           p_allow_tax_code_override_flag,
				                           l_tax_classification_found,
			              	             l_curr_calling_sequence);
                  l_tax_classification_code := p_tax_classification_code;
                  IF (g_level_statement >= g_current_runtime_level ) THEN
         	          FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                      'l_tax_classification_code ==' ||l_tax_classification_code);
                  END IF;
       	          IF (l_tax_classification_found = TRUE) THEN
                    p_default_hierarchy := TRUE;
                    IF (g_level_statement >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                        'l_tax_classification_code is Found ==' ||l_tax_classification_code);
                    END IF;
                    exit Ap_Tax_Loop;
                  END IF;
                END IF;

                IF (aptaxtab (i) = 'FINANCIAL_OPTIONS') THEN
                  IF (g_level_statement >= g_current_runtime_level ) THEN
         	          FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                      'Getting tax code from financial system parameters');
         	          FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                      'sysinfo.vat_code ==' ||sysinfo.ap_info.tax_classification_code );
                  END IF;
                  l_tax_classification_code := sysinfo.ap_info.tax_classification_code;
                  IF (l_tax_classification_code IS NOT NULL) THEN
                    l_tax_classification_found := TRUE;
                    p_default_hierarchy := FALSE;
                    IF (g_level_statement >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                        'l_tax_classification_code ==' ||l_tax_classification_code);
                    END IF;
                    exit Ap_Tax_Loop;
                  END IF;
                END IF;

                IF (aptaxtab (i) = 'TEMPLATE') THEN
                  IF (g_level_statement >= g_current_runtime_level ) THEN
                    FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                      'Getting tax code from template');
                  END IF;
                  -- If the API has been called from a form or process
                  -- where a template is being used, then we should always
                  -- return the tax code on the template item, even if it
                  -- is null.  This is because a null tax code on a template
                  -- is considered as an explicit request for a non-taxable
                  -- item.  See bug #558756.
                  --
                  -- We use the func_short_name to determine if the
                  -- API is being called anywhere where a distribution set
                  -- is in use, and use the calling_sequence to determine
                  -- whether we are being called from the Expense Reports form
                  -- (and are by implication using an expense report template).
                  -- 2544633 fbreslin: Add APXXXDER to list of forms that uses this code.
                  IF (p_calling_sequence IN ('APXXXEER', 'APXXXDER') OR
                      func_short_name = 'AP_INSERT_FROM_DSET') THEN
                    l_tax_classification_code := p_templ_tax_classification_cd;
                    l_tax_classification_found := TRUE;
                    p_default_hierarchy := FALSE;
                    IF (g_level_statement >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
                        'l_tax_classification_code ==' ||l_tax_classification_code);
                    END IF;
                    exit Ap_Tax_Loop;
                  END IF;
                END IF;
              END IF;
            END LOOP Ap_Tax_Loop;
          END IF; -- l_enforced_tax_found
        END IF; -- search_for_ap_tax
    END IF; -- appl_short_name
  END IF; -- tax_code_found

  IF (nvl (p_tax_user_override_flag, 'N') <> 'Y') THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
    	FND_LOG.STRING(g_level_statement,
        'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
        'p_tax_user_override_flag =='||p_tax_user_override_flag);
   	  FND_LOG.STRING(g_level_statement,
        'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
        'l_tax_classification_code =='||l_tax_classification_code);
    END IF;
  END IF;
  IF (g_level_statement >= g_current_runtime_level ) THEN
  	FND_LOG.STRING(g_level_statement,
      'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
      'p_tax_classification_code  =='||p_tax_classification_code);
    FND_LOG.STRING(g_level_statement,
      'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc.END',
      'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: get_def_tax_classif_from_acc (-)');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
  	  FND_LOG.STRING(g_level_unexpected,
        'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
         sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80) );
    END IF;
    IF (l_tax_classification_found = FALSE ) THEN
	    RAISE NO_DATA_FOUND;
    END IF;
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_def_tax_classif_from_acc',
           sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80) );
      END IF;
      IF (appl_short_name = 'SQLAP') THEN
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
	      ' p_ref_doc_application_id = '|| to_char (p_ref_doc_application_id) ||
        ',p_ref_doc_entity_code = '||p_ref_doc_entity_code ||
        ',p_ref_doc_event_class_code = '||p_ref_doc_event_class_code ||
        ',p_ref_doc_trx_id = '||TO_CHAR(p_ref_doc_trx_id) ||
        ',p_ref_doc_line_id = '||TO_CHAR(p_ref_doc_line_id) ||
        ',p_ref_doc_trx_level_type = '||p_ref_doc_trx_level_type ||
	      ',p_vendor_id = '|| to_char (p_vendor_id) ||
	      ',p_vendor_site_id = '|| to_char (p_vendor_site_id) ||
	      ',p_code_combination_id = '|| to_char (p_code_combination_id) ||
	      ',p_concatenated_segments = '||p_concatenated_segments ||
        ',p_templ_tax_classification_cd = '||p_templ_tax_classification_cd||
	      ',p_tax_classification_code = '||p_tax_classification_code ||
        ',p_allow_tax_code_override_flag = '||p_allow_tax_code_override_flag ||
     	  ',APPL_SHORT_NAME = '||APPL_SHORT_NAME ||
	      ',FUNC_SHORT_NAME = '||FUNC_SHORT_NAME ||
	      ',p_calling_sequence = '||p_calling_sequence);
      END IF;
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END get_def_tax_classif_from_acc;

-------------------------------------------------------------------------------
--
-- PRIVATE FUNCTION
-- get_item_tax
--
-- DESCRIPTION
-- This function will look for the tax code that is specified at the
-- item level, if the system options specify that tax is defaulted
-- from this level. It will return the tax code if one is found for the
-- item and the given date. It returns null if a valid tax code is
-- not found.
--
-- If the ship-to organization ID is passed in, use that, else use the
-- item organization ID.  This is in keeping with the existing
-- defaulting rules used for the taxable flag in Purchasing.

-- RETURNS
-- Tax code if one is found at the shipment level and valid for the
-- given date.  Null if a valid tax code is not found.
--
-- CALLED FROM
-- get_default_tax_classification()
--
-- HISTORY
-- 15-JUL-97  Fiona Purves created based on AR API.
--
-------------------------------------------------------------------------------


FUNCTION  get_item_tax (
  p_item_id		IN  mtl_system_items.inventory_item_id%TYPE,
  p_ship_to_loc_org_id	IN  mtl_system_items.organization_id%TYPE,
  p_item_org_id		IN  mtl_system_items.organization_id%TYPE,
  p_calling_sequence	IN  varchar2 )

  RETURN VARCHAR2 IS
  l_curr_calling_sequence 	VARCHAR2(2000);
  l_tax_classification_code	VARCHAR2(30);

  CURSOR sel_item_tax IS
  SELECT si.purchasing_tax_code
    FROM fnd_lookups tc,
         mtl_system_items si
   WHERE si.inventory_item_id = p_item_id
     AND si.organization_id = nvl(p_ship_to_loc_org_id, p_item_org_id)
     AND tc.lookup_code = si.purchasing_tax_code
     AND tc.lookup_type = 'ZX_INPUT_CLASSIFICATIONS'
     AND nvl(tc.enabled_flag,'Y') = 'Y';

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Item_Tax.BEGIN',
                    'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: Get_Item_Tax (+)');
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Item_Tax',
                    'p_item_id == > '||to_char(p_item_id ));
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Item_Tax',
                    'p_ship_to_loc_org_id == > '||to_char(p_ship_to_loc_org_id ));
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Item_Tax',
                    'p_item_org_id == > '||to_char(p_item_org_id ));
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Item_Tax',
                    'p_calling_sequence == >'||p_calling_sequence);
  END IF;
  debug_loc := 'Get_Item_Tax';
  l_curr_calling_sequence := 'ZX_AP_TAX_CLASSIFICATN_DEF_PKG.'||debug_loc||'<-'||p_calling_sequence;

  OPEN sel_item_tax;
  FETCH sel_item_tax INTO l_tax_classification_code;
  CLOSE sel_item_tax;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Item_Tax',
                    'l_tax_classification_code  =='||l_tax_classification_code);
     FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Item_Tax.END',
                    'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: Get_Item_Tax (-)');
  END IF;

  RETURN (l_tax_classification_code);

  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Get_Item_Tax- '||
                           sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_MSG_PUB.Add;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Item_Tax',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      END IF;
	 IF (sel_item_tax%ISOPEN) THEN
	    CLOSE sel_item_tax;
	 END IF;
         RAISE;
END get_item_tax;

-------------------------------------------------------------------------------
--
-- PRIVATE FUNCTION
-- get_account_tax
--
-- DESCRIPTION
-- This function will look for the tax code that is specified at the
-- account level, if the system options specify that tax is defaulted
-- from this level. It will return the tax code if one is found for the
-- account and the given date. It returns null if a valid tax code is
-- not found.
--
-- The function will search for the tax code on the account using
--
--     a)  The code combination ID
--     b)  The concatenated segment string
--
-- depending on which parameter is passed.
--
-- The function searches for the account where the tax type is 'Input'
-- or 'Non-taxable'.  If the tax type is 'Input', then the tax code is
-- returned.  If non-taxable, the function explicitly returns a null
-- tax code, and the search for tax code is considered finished.
-- This is a different result to not finding a tax code for an account.
--
-- Note that this function currently only caters for Accounts Payable, where
-- there is no distinction between line and accounting distribution.
-- It is sufficient in this case to pass the code combination ID from the
-- AP accounting distribution.

-- When defaulting tax code from natural account in Purchasing is implemented,
-- this function will need to be changed, to deal with the PO
-- which does have shipments and distributions.   The tax defaulting API
-- in AR already does this, and passes the transaction line ID to the
-- function.  See ARP_TAX.get_natural_account_tax.
--
-- RETURNS
--
-- Tax code if one is found at the account level and valid for the
-- given date.  It also returns a flag to indicate whether the user
-- may override the tax code for the given account.
--
-- CALLED FROM
-- get_default_tax_classification()
--
-- HISTORY
-- 15-JUL-97  Fiona Purves created based on AR API.
--
-------------------------------------------------------------------------------




PROCEDURE  get_account_tax (
  p_code_combination_id 	  IN gl_code_combinations.code_combination_id%TYPE,
  p_concatenated_segments	  IN varchar2,
  p_tax_classification_code	  IN OUT NOCOPY varchar2,
  p_allow_tax_code_override_flag  OUT NOCOPY zx_acct_tx_cls_defs.allow_tax_code_override_flag%TYPE,
  p_tax_classification_found      IN OUT NOCOPY boolean,
  p_calling_sequence		  IN varchar2) IS

  l_curr_calling_sequence 		VARCHAR2(2000);
  l_bind_org_id				financials_system_parameters.org_id%TYPE;
  l_app_column_name			fnd_id_flex_segments.application_column_name%TYPE;
  l_account_seg_value			gl_code_combinations.segment1%TYPE;
--  l_tax_type_code			gl_tax_option_accounts.tax_type_code%TYPE;
  l_tax_type_code                       zx_acct_tx_cls_defs.tax_class%TYPE;
  l_delimiter				varchar2(5) := NULL;
  l_result				number;
  l_flexsegtab				fnd_flex_ext.SegmentArray;
  l_account_seg_num			number;
  l_tax_classification_code             varchar2(30);

  TYPE   taxcurtype  IS REF CURSOR  ;
  l_def_tax_cur      taxcurtype;


  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

     IF (g_level_statement >= g_current_runtime_level ) THEN
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax.BEGIN',
                       'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: Get_Account_Tax (+)');
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                       'p_code_combination_id ==>'||to_char(p_code_combination_id));
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                       'p_concatenated_segments ==>'||p_concatenated_segments);
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                       'p_tax_classification_code ==>'|| p_tax_classification_code );
  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                       'p_allow_tax_code_override_flag ==>'||p_allow_tax_code_override_flag);

  	FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                       'p_calling_sequence ==>'||p_calling_sequence );
     END IF;

     debug_loc := 'Get_Account_Tax';
     l_curr_calling_sequence := 'ZX_AP_TAX_CLASSIFICATN_DEF_PKG.'||debug_loc||'<-'||p_calling_sequence;

     IF (p_code_combination_id is not NULL and p_code_combination_id <> -1) THEN
	--  Get the column name that holds the account segment in GL_CODE_COMBINATIONS
        IF (g_level_statement >= g_current_runtime_level ) THEN
  	   FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                       'Getting tax code using code combination ID');
  	   FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                       'p_code_combination_id is not Null =='||to_char(p_code_combination_id));
        END IF;

        result := fnd_flex_apis.get_segment_column (101,
					    	    'GL#',
						    sysinfo.chart_of_accounts_id,
						    'GL_ACCOUNT',
						    l_app_column_name);
        --Bug Fix 1064036
	statement := 'SELECT ' || l_app_column_name ||
	             ' FROM gl_code_combinations cc' ||
		     ' WHERE cc.code_combination_id = ' || p_code_combination_id;

        execute immediate statement into l_account_seg_value ;
        IF (g_level_statement >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                          'l_account_seg_value =='||l_account_seg_value);
        END IF;
     ELSE
       IF (p_concatenated_segments is not NULL) THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                            'p_concatenated_segments is not Null =='||p_concatenated_segments);
          END IF;
	  --  Get account segment from the concatenated string
          IF (g_level_statement >= g_current_runtime_level ) THEN
  	     FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                            'Getting tax code using concatenated segments');
          END IF;
	  l_delimiter := fnd_flex_ext.get_delimiter ('SQLGL',
                                                     'GL#',
                                                     sysinfo.chart_of_accounts_id);
	  l_result := fnd_flex_ext.breakup_segments (p_concatenated_segments,
                                                     l_delimiter,
                                                     l_flexsegtab);
	  result := fnd_flex_apis.get_qualifier_segnum (101,
							'GL#',
							sysinfo.chart_of_accounts_id,
							'GL_ACCOUNT',
							 l_account_seg_num);
	  l_account_seg_value := l_flexsegtab(l_account_seg_num);

          IF (g_level_statement >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                            'l_account_seg_value =='|| l_account_seg_value);
             FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                            'l_delimiter =='||l_delimiter );
             FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                            'l_result =='||to_char(l_result));
          END IF;
       END IF;
     END IF;

     IF (l_account_seg_value is not NULL) THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                          'l_account_seg_value is not null =='||l_account_seg_value);
        END IF;
        BEGIN
           --1064036
           -- 1952304. Added an extra condition toa.org_id = -1 in both the select clauses.
           -- This would ensure that the tax code is defaulted even in a single org instance.
	   statement := 'SELECT	toa.allow_tax_code_override_flag, ' ||
				'toa.tax_classification_code, ' ||
				'toa.tax_class  ' ||
		        'FROM	zx_acct_tx_cls_defs_all toa, ' ||
				'zx_input_classifications_v tc ' ||
		        'WHERE	toa.account_segment_value = :l_account_seg_value ' ||
		        'AND  toa.ledger_id = :l_bind_set_of_books_id ' || -- Bug 8353620
		        'AND	(toa.org_id = :l_bind_org_id or toa.org_id = -1)' ||
		        'AND	toa.tax_class  = ''INPUT'' ' ||
		        'AND	tc.lookup_code = toa.tax_classification_code ' ||
		        'AND	tc.lookup_type = ''ZX_INPUT_CLASSIFICATIONS'' ' ||
		        'AND 	nvl(tc.enabled_flag,''Y'') = ''Y'' ' ||
		        'AND    tc.org_id in (:l_bind_org_id,-99) '||
		        'UNION	' ||
		        'SELECT	toa.allow_tax_code_override_flag, ' ||
				'toa.tax_classification_code, ' ||
				'toa.tax_class ' ||
		        'FROM	zx_acct_tx_cls_defs_all toa ' ||
		        'WHERE	toa.account_segment_value = :l_account_seg_value ' ||
		        'AND	( toa.org_id = :l_bind_org_id or toa.org_id = -1 )' ||
		        'AND	toa.tax_class  = ''N'' ';
           IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                             'statement='||statement);
      	      FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                             'Executing Dynamic SQL statement  ');
           END IF;
           execute immediate statement into p_allow_tax_code_override_flag,
                                            p_tax_classification_code,
                                            l_tax_type_code
                                      using l_account_seg_value,
                                            sysinfo.set_of_books_id,
                                            sysinfo.org_id,
                                            sysinfo.org_id,
                                            l_account_seg_value,
                                            sysinfo.org_id;
           IF (g_level_statement >= g_current_runtime_level ) THEN
	      FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                             'statement  =='||substr(statement,1,700));
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                             'sysinfo.org_id  =='||to_char(sysinfo.org_id));
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                             'p_allow_tax_code_override_flag  =='||p_allow_tax_code_override_flag );
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                             ' p_tax_classification_code  =='|| p_tax_classification_code );
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                             'l_tax_type_code  =='||l_tax_type_code );
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                             'l_account_seg_value  =='||l_account_seg_value );

              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax.END',
                             'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: Get_Account_Tax (-)');
           END IF;

          EXCEPTION
            WHEN no_data_found THEN
              IF (g_level_unexpected >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_unexpected,
                               'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.Get_Account_Tax',
                                sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
               END IF;

            WHEN  others THEN
              FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
              FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', 'get_account_tax- '||
                                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
              FND_MSG_PUB.Add;

              IF (g_level_unexpected >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_unexpected,
                               'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_account_tax',
                                sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
              END IF;
                   RAISE;
        END;

        IF (p_tax_classification_code is not NULL OR l_tax_type_code = 'N') THEN
           p_tax_classification_found := TRUE;
	END IF;
     END IF;

END get_account_tax;

-- Bug#4090842- new procedure
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  pop_ap_def_option_hier
--
--  DESCRIPTION
--
--  This procedure populates tax default option hierachies for products
--  using 'AP'
--

PROCEDURE pop_ap_def_option_hier(p_org_id           IN   NUMBER,
                                 p_application_id   IN   NUMBER,
                                 p_event_class_code IN   VARCHAR2,
                                 p_return_status    OUT NOCOPY VARCHAR2)
IS
  l_event_class_mapping_id       NUMBER;

  CURSOR c_ap_default_options (c_org_id         NUMBER,
                               c_application_id NUMBER) IS
    SELECT org_id,
           use_tax_classification_flag,
           tax_classification_code,
           def_option_hier_1_code,
           def_option_hier_2_code,
           def_option_hier_3_code,
           def_option_hier_4_code,
           def_option_hier_5_code,
           def_option_hier_6_code,
           def_option_hier_7_code
     FROM  zx_product_options_all
     WHERE org_id         = c_org_id
       AND application_id = c_application_id
       AND event_class_mapping_id IS NULL;

  --
  -- Bug#4102742- handle Internet Expense
  -- only IOE has event_class_mapping_id not NULL
  -- in zx_product_options_all
  --
  CURSOR c_get_event_class_mapping_id (
              c_event_class_code      VARCHAR2,
              c_application_id        NUMBER,
              c_entity_code           VARCHAR2)  IS
    SELECT event_class_mapping_id
      FROM zx_evnt_cls_mappings
      WHERE event_class_code = c_event_class_code
        AND application_id   = c_application_id
        AND entity_code      = c_entity_code;

  CURSOR c_ioe_default_options (c_org_id                 NUMBER,
                                c_application_id         NUMBER,
                                c_event_class_mapping_id NUMBER) IS
    SELECT org_id,
           use_tax_classification_flag,
           tax_classification_code,
           def_option_hier_1_code,
           def_option_hier_2_code,
           def_option_hier_3_code,
           def_option_hier_4_code,
           def_option_hier_5_code,
           def_option_hier_6_code,
           def_option_hier_7_code
     FROM  zx_product_options_all
     WHERE org_id                 = c_org_id
       AND application_id         = c_application_id
       AND event_class_mapping_id = c_event_class_mapping_id;
BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_ap_def_option_hier.BEGIN',
                   'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: pop_ap_def_option_hier(+)' );
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_ap_def_option_hier',
                   'p_event_class_code : ' || p_event_class_code);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_ap_def_option_hier',
                   'Getting default options ');
  END IF;

  -- init return status
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- init search for ap tax to FALSE
  search_for_ap_tax  := FALSE;
  search_ap_def_hier := FALSE;

  --
  -- determine if it is Internet Expense
  --
  IF p_event_class_code = 'EXPENSE REPORTS' THEN
    --
    -- Bug#4102742- Internet expense case, get event_class_mapping_id
    --
    OPEN c_get_event_class_mapping_id(p_event_class_code,
                                      200,
                                      'AP_INVOICES');
    FETCH c_get_event_class_mapping_id INTO
            l_event_class_mapping_id;
    CLOSE c_get_event_class_mapping_id;

    IF l_event_class_mapping_id IS NULL THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_ap_def_option_hier',
                       'event_class_mapping_id not found for Internet expense');
      END IF;
      RETURN;
    END IF;

    OPEN c_ioe_default_options(p_org_id, 200, l_event_class_mapping_id);
    FETCH c_ioe_default_options INTO
           ap_info.org_id,
           ap_info.use_tax_classification_flag,
           ap_info.tax_classification_code,
           ap_info.def_option_hier_1_code,
           ap_info.def_option_hier_2_code,
           ap_info.def_option_hier_3_code,
           ap_info.def_option_hier_4_code,
           ap_info.def_option_hier_5_code,
           ap_info.def_option_hier_6_code,
           ap_info.def_option_hier_7_code;
    CLOSE c_ioe_default_options;
  ELSE
    -- non Internet expense case
    -- Bug#4090842- use org_id passed in
    -- open c_default_options(to_number(substrb(userenv('CLIENT_INFO'),1,10)),
    --                        200);
    OPEN c_ap_default_options(p_org_id, 200);
    FETCH c_ap_default_options INTO
           ap_info.org_id,
           ap_info.use_tax_classification_flag,
           ap_info.tax_classification_code,
           ap_info.def_option_hier_1_code,
           ap_info.def_option_hier_2_code,
           ap_info.def_option_hier_3_code,
           ap_info.def_option_hier_4_code,
           ap_info.def_option_hier_5_code,
           ap_info.def_option_hier_6_code,
           ap_info.def_option_hier_7_code;
    CLOSE c_ap_default_options;
  END IF;

  IF NVL(ap_info.use_tax_classification_flag, 'N') = 'Y' THEN
    search_for_ap_tax := TRUE;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_ap_def_option_hier',
                       'Use Tax Classification: '|| NVL(ap_info.use_tax_classification_flag,'N'));
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_ap_def_option_hier',
                       'Hierarchy Level 1: ' ||ap_info.def_option_hier_1_code );
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_ap_def_option_hier',
                       'Hierarchy Level 2: ' ||ap_info.def_option_hier_2_code );
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_ap_def_option_hier',
                       'Hierarchy Level 3: ' ||ap_info.def_option_hier_3_code );
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_ap_def_option_hier',
                       'Hierarchy Level 4: ' ||ap_info.def_option_hier_4_code );
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_ap_def_option_hier',
                       'Hierarchy Level 5: ' ||ap_info.def_option_hier_5_code );
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_ap_def_option_hier',
                       'Hierarchy Level 6: ' ||ap_info.def_option_hier_6_code );
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_ap_def_option_hier',
                       'Hierarchy Level 7: ' ||ap_info.def_option_hier_7_code );

  END IF;

  sysinfo.ap_info               := ap_info;
  sysinfo.org_id                := p_org_id;

  IF search_for_ap_tax THEN
    IF (sysinfo.ap_info.def_option_hier_1_code IS NOT NULL
           OR sysinfo.ap_info.def_option_hier_2_code IS NOT NULL
           OR sysinfo.ap_info.def_option_hier_3_code IS NOT NULL
           OR sysinfo.ap_info.def_option_hier_4_code IS NOT NULL
           OR sysinfo.ap_info.def_option_hier_5_code IS NOT NULL
           OR sysinfo.ap_info.def_option_hier_6_code IS NOT NULL
           OR sysinfo.ap_info.def_option_hier_7_code IS NOT NULL) THEN

      IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_ap_def_option_hier',
                        'Initializing AP defaulting information');
      END IF;

      aptaxtab(1) := sysinfo.ap_info.def_option_hier_1_code;
      aptaxtab(2) := sysinfo.ap_info.def_option_hier_2_code;
      aptaxtab(3) := sysinfo.ap_info.def_option_hier_3_code;
      aptaxtab(4) := sysinfo.ap_info.def_option_hier_4_code;
      aptaxtab(5) := sysinfo.ap_info.def_option_hier_5_code;
      aptaxtab(6) := sysinfo.ap_info.def_option_hier_6_code;
      aptaxtab(7) := sysinfo.ap_info.def_option_hier_7_code;

      search_ap_def_hier := TRUE;
    END IF;

  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_ap_def_option_hier.END',
                   'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: pop_ap_def_option_hier(-)' );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF c_ap_default_options%ISOPEN THEN
      CLOSE c_ap_default_options;
    END IF;
    IF c_ioe_default_options%ISOPEN THEN
      CLOSE c_ioe_default_options;
    END IF;
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', 'pop_ap_def_option_hier- '||
                          sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_ap_def_option_hier',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END pop_ap_def_option_hier;

-- Bug#4090842- new procedure
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  pop_po_def_option_hier
--
--  DESCRIPTION
--
--  This procedure populates tax default option hierachies for products
--  using 'PO'
--

PROCEDURE pop_po_def_option_hier(p_org_id            IN  NUMBER,
                                 p_application_id    IN  NUMBER,
                                 p_return_status    OUT NOCOPY VARCHAR2)
IS
  status_flag fnd_product_installations.status%TYPE;

  CURSOR  get_status_flag_csr(c_application_id    NUMBER) IS
    SELECT   status
      FROM   fnd_product_installations
      WHERE  application_id = c_application_id;

  CURSOR c_po_default_options (c_org_id         NUMBER,
                               c_application_id NUMBER) IS
    SELECT org_id,
           use_tax_classification_flag,
           tax_classification_code,
           def_option_hier_1_code,
           def_option_hier_2_code,
           def_option_hier_3_code,
           def_option_hier_4_code,
           def_option_hier_5_code,
           def_option_hier_6_code,
           def_option_hier_7_code
    FROM  zx_product_options_all
    WHERE org_id = c_org_id
      AND application_id = c_application_id
      AND event_class_mapping_id IS NULL;

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_po_def_option_hier.BEGIN',
                     'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: pop_po_def_option_hier(+)' );
  END IF;

  -- init return status
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- init search for po tax to FALSE
  search_for_po_tax  := FALSE;
  search_po_def_hier := FALSE;

  -- This variable is declared and pop_po_def_option_hierd for the bug 2836810 by zmohiudd..
  status_flag := 'N';

  --  The following select statement and if condition are added for the bug 2836810 by zmohiudd..
  OPEN  get_status_flag_csr(201);
  FETCH get_status_flag_csr INTO status_flag;
  CLOSE get_status_flag_csr;

  IF nvl(status_flag,'N') in ('I','S') THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_po_def_option_hier',
                       'Getting PO default options');
    END IF;

        -- Bug#4090842- use org_id passed in
        -- open c_default_options(to_number(substrb(userenv('CLIENT_INFO'),1,10)),
        --                        201);
    OPEN c_po_default_options(p_org_id, 201);
    FETCH c_po_default_options INTO
             po_info.org_id,
             po_info.use_tax_classification_flag,
             po_info.tax_classification_code,
             po_info.def_option_hier_1_code,
             po_info.def_option_hier_2_code,
             po_info.def_option_hier_3_code,
             po_info.def_option_hier_4_code,
             po_info.def_option_hier_5_code,
             po_info.def_option_hier_6_code,
             po_info.def_option_hier_7_code;
    CLOSE c_po_default_options;

    IF NVL(po_info.use_tax_classification_flag, 'N') = 'Y' THEN
      search_for_po_tax := TRUE;
    END IF;

    IF (g_level_statement >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_po_def_option_hier',
                          'PO Use Tax Classification: '|| NVL(po_info.use_tax_classification_flag,'N'));
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_po_def_option_hier',
                          'PO Hierarchy Level 1: ' ||po_info.def_option_hier_1_code );
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_po_def_option_hier',
                          'PO Hierarchy Level 2: ' ||po_info.def_option_hier_2_code );
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_po_def_option_hier',
                          'PO Hierarchy Level 3: ' ||po_info.def_option_hier_3_code );
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_po_def_option_hier',
                          'PO Hierarchy Level 4: ' ||po_info.def_option_hier_4_code );
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_po_def_option_hier',
                          'PO Hierarchy Level 5: ' ||po_info.def_option_hier_5_code );
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_po_def_option_hier',
                          'PO Hierarchy Level 6: ' ||po_info.def_option_hier_6_code );
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_po_def_option_hier',
                          'PO Hierarchy Level 7: ' ||po_info.def_option_hier_7_code );
    END IF;

    sysinfo.po_info               := po_info;
    sysinfo.org_id                := p_org_id;

    IF search_for_po_tax  THEN
      IF (sysinfo.po_info.def_option_hier_1_code IS NOT NULL
            OR sysinfo.po_info.def_option_hier_2_code IS NOT NULL
            OR sysinfo.po_info.def_option_hier_3_code IS NOT NULL
            OR sysinfo.po_info.def_option_hier_4_code IS NOT NULL
            OR sysinfo.po_info.def_option_hier_5_code IS NOT NULL
            OR sysinfo.po_info.def_option_hier_6_code IS NOT NULL
            OR sysinfo.po_info.def_option_hier_7_code IS NOT NULL) THEN

        IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_po_def_option_hier',
                           'Initializing PO information');
        END IF;

        potaxtab(1) := sysinfo.po_info.def_option_hier_1_code;
        potaxtab(2) := sysinfo.po_info.def_option_hier_2_code;
        potaxtab(3) := sysinfo.po_info.def_option_hier_3_code;
        potaxtab(4) := sysinfo.po_info.def_option_hier_4_code;
        potaxtab(5) := sysinfo.po_info.def_option_hier_5_code;
        potaxtab(6) := sysinfo.po_info.def_option_hier_6_code;
        potaxtab(7) := sysinfo.po_info.def_option_hier_7_code;

        search_po_def_hier := TRUE;
      END IF;
    END IF;

  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_po_def_option_hier.END',
                     'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: pop_po_def_option_hier(-)' );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF c_po_default_options%ISOPEN THEN
      CLOSE c_po_default_options;
    END IF;
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', 'pop_po_def_option_hier- '||
                          sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_po_def_option_hier',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
END pop_po_def_option_hier;

-- Bug 6510307
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  pop_cc_def_option_hier
--
--  DESCRIPTION
--
--  This procedure populates tax default option hierachies for product
--  'CC'
--

PROCEDURE pop_cc_def_option_hier(p_org_id            IN  NUMBER,
                                 p_application_id    IN  NUMBER,
                                 p_return_status    OUT NOCOPY VARCHAR2)
IS

    CURSOR c_cc_default_options (c_org_id         NUMBER,
                               c_application_id NUMBER) IS
    SELECT org_id,
           use_tax_classification_flag,
           tax_classification_code,
           def_option_hier_1_code,
           def_option_hier_2_code,
           def_option_hier_3_code,
           def_option_hier_4_code,
           def_option_hier_5_code,
           def_option_hier_6_code,
           def_option_hier_7_code
    FROM  zx_product_options_all
    WHERE org_id = c_org_id
      AND application_id = c_application_id
      AND event_class_mapping_id IS NULL;

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_cc_def_option_hier.BEGIN',
                     'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: pop_cc_def_option_hier(+)' );
  END IF;

  -- init return status
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- init search for cc tax to FALSE
  search_for_cc_tax  := FALSE;
  search_cc_def_hier := FALSE;

   IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_cc_def_option_hier',
                       'Getting CC default options');
    END IF;

    OPEN c_cc_default_options(p_org_id, 8407);
    FETCH c_cc_default_options INTO
             cc_info.org_id,
             cc_info.use_tax_classification_flag,
             cc_info.tax_classification_code,
             cc_info.def_option_hier_1_code,
             cc_info.def_option_hier_2_code,
             cc_info.def_option_hier_3_code,
             cc_info.def_option_hier_4_code,
             cc_info.def_option_hier_5_code,
             cc_info.def_option_hier_6_code,
             cc_info.def_option_hier_7_code;
    CLOSE c_cc_default_options;

    IF NVL(cc_info.use_tax_classification_flag, 'N') = 'Y' THEN
      search_for_cc_tax := TRUE;
    END IF;

    IF (g_level_statement >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_cc_def_option_hier',
                          'CC Use Tax Classification: '|| NVL(cc_info.use_tax_classification_flag,'N'));
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_cc_def_option_hier',
                          'CC Hierarchy Level 1: ' ||cc_info.def_option_hier_1_code );
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_cc_def_option_hier',
                          'CC Hierarchy Level 2: ' ||cc_info.def_option_hier_2_code );
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_cc_def_option_hier',
                          'CC Hierarchy Level 3: ' ||cc_info.def_option_hier_3_code );
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_cc_def_option_hier',
                          'CC Hierarchy Level 4: ' ||cc_info.def_option_hier_4_code );
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_cc_def_option_hier',
                          'CC Hierarchy Level 5: ' ||cc_info.def_option_hier_5_code );
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_cc_def_option_hier',
                          'CC Hierarchy Level 6: ' ||cc_info.def_option_hier_6_code );
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_cc_def_option_hier',
                          'CC Hierarchy Level 7: ' ||cc_info.def_option_hier_7_code );
    END IF;

    sysinfo.cc_info               := cc_info;
    sysinfo.org_id                := p_org_id;

    IF search_for_cc_tax  THEN
      IF (sysinfo.cc_info.def_option_hier_1_code IS NOT NULL
            OR sysinfo.cc_info.def_option_hier_2_code IS NOT NULL
            OR sysinfo.cc_info.def_option_hier_3_code IS NOT NULL
            OR sysinfo.cc_info.def_option_hier_4_code IS NOT NULL
            OR sysinfo.cc_info.def_option_hier_5_code IS NOT NULL
            OR sysinfo.cc_info.def_option_hier_6_code IS NOT NULL
            OR sysinfo.cc_info.def_option_hier_7_code IS NOT NULL) THEN

        IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_cc_def_option_hier',
                           'Initializing CC information');
        END IF;

        cctaxtab(1) := sysinfo.cc_info.def_option_hier_1_code;
        cctaxtab(2) := sysinfo.cc_info.def_option_hier_2_code;
        cctaxtab(3) := sysinfo.cc_info.def_option_hier_3_code;
        cctaxtab(4) := sysinfo.cc_info.def_option_hier_4_code;
        cctaxtab(5) := sysinfo.cc_info.def_option_hier_5_code;
        cctaxtab(6) := sysinfo.cc_info.def_option_hier_6_code;
        cctaxtab(7) := sysinfo.cc_info.def_option_hier_7_code;

        search_cc_def_hier := TRUE;
      END IF;
    END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_cc_def_option_hier.END',
                     'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: pop_cc_def_option_hier(-)' );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF c_cc_default_options%ISOPEN THEN
      CLOSE c_cc_default_options;
    END IF;
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', 'pop_cc_def_option_hier- '||
                          sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.pop_cc_def_option_hier',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
END pop_cc_def_option_hier;

-- Bug#5066122- new procedure
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  validate_tax_classif_code
--
--  DESCRIPTION
--
--  This procedure  checks if the tax classification code is
--  still valid
--

PROCEDURE validate_tax_classif_code(
              p_tax_classification_code   IN  VARCHAR2,
              p_count                     OUT NOCOPY NUMBER)
IS

  CURSOR chk_tax_classification_code
    (c_tax_classification_code    VARCHAR2)
  IS
  SELECT  count(1)
    FROM  fnd_lookups
    WHERE lookup_code = c_tax_classification_code
      AND lookup_type = 'ZX_INPUT_CLASSIFICATIONS'
      AND nvl(enabled_flag,'Y') = 'Y';

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.validate_tax_classif_code.BEGIN',
                   'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: validate_tax_classif_code(+)');

    FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.validate_tax_classif_code',
                    'p_tax_classification_code  =='
                     ||p_tax_classification_code);

  END IF;

  OPEN  chk_tax_classification_code(p_tax_classification_code);
  FETCH chk_tax_classification_code INTO p_count;
  CLOSE chk_tax_classification_code;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.validate_tax_classif_code',
                   'p_count  == >'||to_char(p_count));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_AP_TAX_CLASSIFICATN_DEF_PKG.validate_tax_classif_code.END',
                    'ZX_AP_TAX_CLASSIFICATN_DEF_PKG: validate_tax_classif_code(-)');
  END IF;

END validate_tax_classif_code;

-------------------------------------------------------------------------------
--
--   get_system_tax_defaults
--
-------------------------------------------------------------------------------

BEGIN

  curr_calling_sequence := 'ZX_AP_TAX_CLASSIFICATN_DEF_PKG.';
  Initialize;

END ZX_AP_TAX_CLASSIFICATN_DEF_PKG;

/
