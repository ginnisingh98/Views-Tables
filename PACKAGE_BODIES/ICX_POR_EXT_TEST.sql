--------------------------------------------------------
--  DDL for Package Body ICX_POR_EXT_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_EXT_TEST" AS
/* $Header: ICXEXTTB.pls 115.10 2004/03/31 18:46:32 vkartik ship $*/

TYPE tCursorType	IS REF CURSOR;
gTableTS		VARCHAR2(30) := NULL;
gIndexTS		VARCHAR2(30) := NULL;

--------------------------------------------------------------
--                   Test Preparing Procedures              --
--------------------------------------------------------------
-- Create tables for test
PROCEDURE createTables
IS
  xErrLoc	PLS_INTEGER:= 100;
  xTableTS	VARCHAR2(2000);
  xIndexTS	VARCHAR2(2000);

BEGIN
  xErrLoc:= 50;
  IF gTableTS IS NULL THEN
    xTableTS := NULL;
  ELSE
    xTableTS := 'TABLESPACE ' || gTableTS ||
    ' STORAGE (INITIAL 160K NEXT 160K PCTINCREASE 0)';
  END IF;

  IF gIndexTS IS NULL THEN
    xIndexTS := NULL;
  ELSE
    xIndexTS := 'TABLESPACE ' || gIndexTS ||
    ' STORAGE (INITIAL 160K NEXT 160K PCTINCREASE 0)';
  END IF;

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE imtl_categories_kfv');
  EXECUTE IMMEDIATE
    'CREATE TABLE imtl_categories_kfv( ' ||
    '  category_id		NUMBER, ' ||
    '  concatenated_segments	VARCHAR2(204), ' ||
    '  structure_id		NUMBER, ' ||
    '  web_status		VARCHAR2(1), ' ||
    '  start_date_active	DATE, ' ||
    '  end_date_active		DATE, ' ||
    '  disable_date		DATE, ' ||
    '  last_update_date		DATE) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX imtl_categories_kfv_i1 ON  ' ||
    '  imtl_categories_kfv(category_id) ' || xIndexTS;

  xErrLoc:= 100;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE imtl_category_set_valid_cats');
  EXECUTE IMMEDIATE
    'CREATE TABLE imtl_category_set_valid_cats( ' ||
    '  category_id	NUMBER, ' ||
    '  category_set_id	NUMBER, ' ||
    '  last_update_date	DATE) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX imtl_category_set_vcats_i1 ON  ' ||
    '  imtl_category_set_valid_cats(category_id) ' || xIndexTS;

  xErrLoc:= 120;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE imtl_categories_tl');
  EXECUTE IMMEDIATE
    'CREATE TABLE imtl_categories_tl( ' ||
    '  category_id	NUMBER, ' ||
    '  description	VARCHAR2(240), ' ||
    '  language		VARCHAR2(4), ' ||
    '  source_lang	VARCHAR2(4), ' ||
    '  last_update_date	DATE) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX imtl_categories_tl_i1 ON  ' ||
    '  imtl_categories_tl(category_id, language) ' || xIndexTS;

  xErrLoc:= 140;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE ipo_reqexpress_headers_all');
  EXECUTE IMMEDIATE
    'CREATE TABLE ipo_reqexpress_headers_all( ' ||
    '  org_id		NUMBER, ' ||
    '  express_name	VARCHAR2(25), ' ||
    '  type_lookup_code	VARCHAR2(25), ' ||
    '  inactive_date	DATE, ' ||
    '  last_update_date	DATE) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_reqexpress_headers_i1 ON  ' ||
    '  ipo_reqexpress_headers_all(org_id, express_name) ' || xIndexTS;

  xErrLoc:= 160;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE ipo_reqexpress_lines_all');
  EXECUTE IMMEDIATE
    'CREATE TABLE ipo_reqexpress_lines_all( ' ||
    '  org_id			NUMBER, ' ||
    '  express_name		VARCHAR2(25), ' ||
    '  sequence_num		NUMBER, ' ||
    '  source_type_code		VARCHAR2(25), ' ||
    '  po_header_id		NUMBER, ' ||
    '  po_line_id		NUMBER, ' ||
    '  item_id			NUMBER, ' ||
    '  category_id		NUMBER, ' ||
    '  item_description		VARCHAR2(240), ' ||
    '  item_revision		VARCHAR2(3), ' ||
    '  line_type_id		NUMBER, ' ||
    '  suggested_buyer_id	NUMBER, ' ||
    '  unit_price		NUMBER, ' ||
    '  unit_meas_lookup_code	VARCHAR2(25), ' ||
    '  suggested_vendor_id	NUMBER, ' ||
    '  suggested_vendor_site_id	NUMBER, ' ||
    '  suggested_vendor_product_code 	VARCHAR2(25), ' ||
    '  suggested_vendor_contact_id 	NUMBER, ' ||
    '  creation_date		DATE, ' ||
    '  last_update_date		DATE, ' ||
    '  allow_price_override_flag	VARCHAR2(1), ' ||
    '  not_to_exceed_price	NUMBER, ' ||
    '  amount                   NUMBER, ' ||
    '  suggested_quantity       NUMBER) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_reqexpress_lines_i1 ON  ' ||
    '  ipo_reqexpress_lines_all(org_id, express_name, sequence_num) ' || xIndexTS;

  xErrLoc:= 180;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE ipo_headers_all');
  EXECUTE IMMEDIATE
    'CREATE TABLE ipo_headers_all( ' ||
    '  po_header_id		NUMBER, ' ||
    '  org_id			NUMBER, ' ||
    '  segment1			VARCHAR2(20), ' ||
    '  type_lookup_code		VARCHAR2(25), ' ||
    '  rate_type		VARCHAR2(30), ' ||
    '  rate_date		DATE, ' ||
    '  rate			NUMBER, ' ||
    '  vendor_contact_id	NUMBER, ' ||
    '  agent_id			NUMBER, ' ||
    '  currency_code		VARCHAR2(15), ' ||
    '  vendor_id		NUMBER, ' ||
    '  vendor_site_id		NUMBER, ' ||
    '  approved_date		DATE, ' ||
    '  approved_flag 		VARCHAR2(1), ' ||
    '  approval_required_flag 	VARCHAR2(1), ' ||
    '  cancel_flag 		VARCHAR2(1), ' ||
    '  frozen_flag 		VARCHAR2(1), ' ||
    '  closed_code		VARCHAR2(25), ' ||
    '  status_lookup_code	VARCHAR2(25), ' ||
    '  quotation_class_code	VARCHAR2(25), ' ||
    '  start_date		DATE, ' ||
    '  end_date			DATE, ' ||
    '  global_agreement_flag 	VARCHAR2(1), ' ||
    '  last_update_date		DATE) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_headers_all_i1 ON  ' ||
    '  ipo_headers_all(po_header_id) ' || xIndexTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_headers_all_i2 ON  ' ||
    '  ipo_headers_all(org_id, segment1) ' || xIndexTS;

  -- FPJ FPSL Extractor Changes
  -- Add 3 columns for Amount, Allow Price Override Flag and
  -- Not to Exceed Price
  xErrLoc:= 200;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE ipo_lines_all');
  EXECUTE IMMEDIATE
    'CREATE TABLE ipo_lines_all( ' ||
    '  po_header_id		NUMBER, ' ||
    '  po_line_id		NUMBER, ' ||
    '  org_id			NUMBER, ' ||
    '  line_num			NUMBER, ' ||
    '  item_id			NUMBER, ' ||
    '  item_description		VARCHAR2(240), ' ||
    '  vendor_product_num	VARCHAR2(25), ' ||
    '  line_type_id		NUMBER, ' ||
    '  category_id		NUMBER, ' ||
    '  unit_price		NUMBER, ' ||
    '  unit_meas_lookup_code	VARCHAR2(25), ' ||
    '  attribute13		VARCHAR2(150), ' ||
    '  attribute14		VARCHAR2(150), ' ||
    '  cancel_flag 		VARCHAR2(1), ' ||
    '  closed_code		VARCHAR2(25), ' ||
    '  expiration_date		DATE, ' ||
    '  item_revision		VARCHAR2(3), ' ||
    '  creation_date		DATE, ' ||
    '  last_update_date		DATE, ' ||
    '  amount		        NUMBER, ' ||
    '  allow_price_override_flag VARCHAR2(1), ' ||
    '  not_to_exceed_price      NUMBER) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_lines_all_i1 ON  ' ||
    '  ipo_lines_all(po_header_id) ' || xIndexTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_lines_all_i2 ON  ' ||
    '  ipo_lines_all(po_line_id) ' || xIndexTS;

  xErrLoc:= 220;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE ipo_line_locations_all');
  EXECUTE IMMEDIATE
    'CREATE TABLE ipo_line_locations_all( ' ||
    '  line_location_id		NUMBER, ' ||
    '  po_line_id		NUMBER, ' ||
    '  start_date		DATE, ' ||
    '  end_date			DATE, ' ||
    '  last_update_date		DATE) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_line_locations_all_i1 ON  ' ||
    '  ipo_line_locations_all(line_location_id) ' || xIndexTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_line_locations_all_i2 ON  ' ||
    '  ipo_line_locations_all(po_line_id) ' || xIndexTS;

  xErrLoc:= 240;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE ipo_quotation_approvals_all');
  EXECUTE IMMEDIATE
    'CREATE TABLE ipo_quotation_approvals_all( ' ||
    '  line_location_id		NUMBER, ' ||
    '  approval_type		VARCHAR2(25), ' ||
    '  start_date_active	DATE, ' ||
    '  end_date_active		DATE, ' ||
    '  last_update_date		DATE) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_quotation_approvals_i1 ON  ' ||
    '  ipo_quotation_approvals_all(line_location_id) ' || xIndexTS;

  --FPJ FPSL project
  --Changing ipo_line_types to ipo_line_types_b
  --Since the columns required for catalog are present in po_line_types_b
  --No need of using po_line_types which is view on po_line_types_b and
  --po_line_types_tl
  -- Add 2 columns for order_type_lookup_code and purchase_basis
  xErrLoc:= 260;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE ipo_line_types_b');
  EXECUTE IMMEDIATE
    'CREATE TABLE ipo_line_types_b( ' ||
    '  line_type_id		NUMBER, ' ||
    '  outside_operation_flag	VARCHAR2(1), ' ||
    '  last_update_date		DATE, ' ||
    '  order_type_lookup_code   VARCHAR2(25), '||
    '  purchase_basis		VARCHAR2(30) ) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_line_types_b_i1 ON  ' ||
    '  ipo_line_types_b(line_type_id) ' || xIndexTS;

  xErrLoc:= 280;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE ipo_ga_org_assignments');
  EXECUTE IMMEDIATE
    'CREATE TABLE ipo_ga_org_assignments( ' ||
    '  po_header_id		NUMBER, ' ||
    '  organization_id		NUMBER, ' ||
    '  enabled_flag		VARCHAR2(1), ' ||
    '  vendor_site_id		NUMBER, ' ||
    '  purchasing_org_id        NUMBER, ' ||  -- Centralized Proc Impacts
    '  last_update_date		DATE) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_ga_org_assignments_i1 ON  ' ||
    '  ipo_ga_org_assignments(po_header_id) ' || xIndexTS;

  xErrLoc:= 300;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE ipo_asl_attributes');
  EXECUTE IMMEDIATE
    'CREATE TABLE ipo_asl_attributes( ' ||
    '  asl_id			NUMBER, ' ||
    '  purchasing_unit_of_measure VARCHAR2(25), ' ||
    '  last_update_date		DATE) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_asl_attributes_i1 ON  ' ||
    '  ipo_asl_attributes(asl_id) ' || xIndexTS;

  xErrLoc:= 320;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE ipo_approved_supplier_list');
  EXECUTE IMMEDIATE
    'CREATE TABLE ipo_approved_supplier_list( ' ||
    '  asl_id			NUMBER, ' ||
    '  asl_status_id		NUMBER, ' ||
    '  owning_organization_id	NUMBER, ' ||
    '  item_id			NUMBER, ' ||
    '  category_id		NUMBER, ' ||
    '  vendor_id		NUMBER, ' ||
    '  vendor_site_id		NUMBER, ' ||
    '  primary_vendor_item	VARCHAR2(25), ' ||
    '  disable_flag 		VARCHAR2(1), ' ||
    '  creation_date		DATE, ' ||
    '  last_update_date		DATE) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_asl_i1 ON  ' ||
    '  ipo_approved_supplier_list(asl_id) ' || xIndexTS;

  xErrLoc:= 340;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE ipo_asl_status_rules');
  EXECUTE IMMEDIATE
    'CREATE TABLE ipo_asl_status_rules( ' ||
    '  status_id		NUMBER, ' ||
    '  business_rule		VARCHAR2(25), ' ||
    '  allow_action_flag 	VARCHAR2(1), ' ||
    '  last_update_date		DATE) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_asl_status_rules_i1 ON  ' ||
    '  ipo_asl_status_rules(status_id) ' || xIndexTS;

  xErrLoc:= 360;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE ipo_vendors');
  EXECUTE IMMEDIATE
    'CREATE TABLE ipo_vendors( ' ||
    '  vendor_id		NUMBER, ' ||
    '  vendor_name		VARCHAR2(240), ' ||
    '  segment1			VARCHAR2(30), ' ||
    '  last_update_date		DATE) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_vendors_i1 ON  ' ||
    '  ipo_vendors(vendor_id) ' || xIndexTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_vendors_i2 ON  ' ||
    '  ipo_vendors(vendor_name) ' || xIndexTS;

  xErrLoc:= 380;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE ipo_vendor_sites_all');
  EXECUTE IMMEDIATE
    'CREATE TABLE ipo_vendor_sites_all( ' ||
    '  vendor_site_id		NUMBER, ' ||
    '  vendor_site_code		VARCHAR2(15), ' ||
    '  purchasing_site_flag 	VARCHAR2(1), ' ||
    '  inactive_date	 	DATE, ' ||
    '  last_update_date		DATE) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_vendor_sites_all_i1 ON  ' ||
    '  ipo_vendor_sites_all(vendor_site_id) ' || xIndexTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX ipo_vendor_sites_all_i2 ON  ' ||
    '  ipo_vendor_sites_all(vendor_site_code) ' || xIndexTS;

  xErrLoc:= 400;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE imtl_system_items_kfv');
  EXECUTE IMMEDIATE
    'CREATE TABLE imtl_system_items_kfv( ' ||
    '  inventory_item_id	NUMBER, ' ||
    '  organization_id		NUMBER, ' ||
    '  concatenated_segments	VARCHAR2(40), ' ||
    '  purchasing_enabled_flag 	VARCHAR2(1), ' ||
    '  outside_operation_flag 	VARCHAR2(1), ' ||
    '  internal_order_enabled_flag VARCHAR2(1), ' ||
    '  list_price_per_unit	NUMBER, ' ||
    '  primary_uom_code		VARCHAR2(3), ' ||
    '  replenish_to_order_flag 	VARCHAR2(1), ' ||
    '  base_item_id		NUMBER, ' ||
    '  auto_created_config_flag VARCHAR2(1), ' ||
    '  unit_of_issue		VARCHAR2(25), ' ||
    '  last_update_date		DATE) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX imtl_system_items_kfv_i1 ON  ' ||
    '  imtl_system_items_kfv(inventory_item_id, '||
    '  organization_id) ' || xIndexTS;

  xErrLoc:= 420;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE imtl_system_items_tl');
  EXECUTE IMMEDIATE
    'CREATE TABLE imtl_system_items_tl( ' ||
    '  inventory_item_id	NUMBER, ' ||
    '  organization_id		NUMBER, ' ||
    '  description		VARCHAR2(240), ' ||
    '  language 		VARCHAR2(4), ' ||
    '  source_lang 		VARCHAR2(4), ' ||
    '  last_update_date		DATE) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX imtl_system_items_tl_i1 ON  ' ||
    '  imtl_system_items_tl(inventory_item_id, '||
    '  organization_id, language) ' || xIndexTS;

  xErrLoc:= 440;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE imtl_item_categories');
  EXECUTE IMMEDIATE
    'CREATE TABLE imtl_item_categories( ' ||
    '  inventory_item_id	NUMBER, ' ||
    '  organization_id		NUMBER, ' ||
    '  category_id		NUMBER, ' ||
    '  category_set_id		NUMBER, ' ||
    '  last_update_date		DATE) ' || xTableTS;
  EXECUTE IMMEDIATE
    'CREATE INDEX imtl_item_categories_i1 ON  ' ||
    '  imtl_item_categories(inventory_item_id, category_id, '||
    '  organization_id) ' || xIndexTS;

  xErrLoc:= 460;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE ifinancials_system_params_all');
  EXECUTE IMMEDIATE
    'CREATE TABLE ifinancials_system_params_all( ' ||
    '  org_id			NUMBER, ' ||
    '  inventory_organization_id NUMBER, ' ||
    '  set_of_books_id		NUMBER) ' || xTableTS;

  xErrLoc:= 480;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE ipo_system_parameters_all');
  EXECUTE IMMEDIATE
    'CREATE TABLE ipo_system_parameters_all( ' ||
    '  org_id			NUMBER, ' ||
    '  default_rate_type	VARCHAR2(25), ' ||
    '  last_update_date		DATE) ' || xTableTS; -- Bug# 2945205 : pcreddy

  xErrLoc:= 500;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'CREATE TABLE igl_sets_of_books');
  EXECUTE IMMEDIATE
    'CREATE TABLE igl_sets_of_books( ' ||
    '  set_of_books_id		NUMBER, ' ||
    '  currency_code		VARCHAR2(15)) ' || xTableTS;

  xErrLoc:= 600;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.createTables-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END createTables;

PROCEDURE setCommitSize(pCommitSize	NUMBER)
IS
BEGIN
  gCommitSize := pCommitSize;
END setCommitSize;

PROCEDURE setTestMode(pTestMode	VARCHAR2)
IS
BEGIN
  gTestMode := pTestMode;
END setTestMode;

PROCEDURE setTableSpace(pTableTS	VARCHAR2,
                        pIndexTS	VARCHAR2)
IS
BEGIN
  gTableTS := pTableTS;
  gIndexTS := pIndexTS;
END setTableSpace;

-- Prepare unit testing
PROCEDURE prepare(pCreateTables	VARCHAR2)
IS
  xErrLoc	PLS_INTEGER:= 100;
  xReturnErr	VARCHAR2(2000);
  xStatus	VARCHAR2(20);
  xIndustry	VARCHAR2(20);
  xIndex	PLS_INTEGER:= 0;
BEGIN
  xErrLoc:= 50;
  gTestMode := 'Y';

  xErrLoc:= 80;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'Prepare...');

  xErrLoc:= 100;
  IF NVL(pCreateTables, 'Y') = 'Y' THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
      'Prepare: Create testing tables');
    createTables;
  END IF;

  xErrLoc:= 120;
  -- get category set info
  SELECT category_set_id,
         validate_flag,
         structure_id
  INTO   gCategorySetId,
         gValidateFlag,
         gStructureId
  FROM   mtl_default_sets_view
  WHERE  functional_area_id = 2;

  xErrLoc:= 140;
  SELECT language_code
  INTO   gBaseLang
  FROM   fnd_languages
  WHERE  installed_flag = 'B';

  xErrLoc:= 300;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.prepare-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END prepare;

--------------------------------------------------------------
--                   Test Cleanup Procedures                --
--------------------------------------------------------------
-- Drop tables for test
PROCEDURE dropTables
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 100;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE imtl_categories_kfv');
  EXECUTE IMMEDIATE
    'DROP TABLE imtl_categories_kfv';

  xErrLoc:= 120;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE imtl_category_set_valid_cats');
  EXECUTE IMMEDIATE
    'DROP TABLE imtl_category_set_valid_cats';

  xErrLoc:= 140;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE imtl_categories_tl');
  EXECUTE IMMEDIATE
    'DROP TABLE imtl_categories_tl';

  xErrLoc:= 160;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE ipo_reqexpress_headers_all');
  EXECUTE IMMEDIATE
    'DROP TABLE ipo_reqexpress_headers_all';

  xErrLoc:= 180;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE ipo_reqexpress_lines_all');
  EXECUTE IMMEDIATE
    'DROP TABLE ipo_reqexpress_lines_all';

  xErrLoc:= 200;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE ipo_headers_all');
  EXECUTE IMMEDIATE
    'DROP TABLE ipo_headers_all';

  xErrLoc:= 220;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE ipo_lines_all');
  EXECUTE IMMEDIATE
    'DROP TABLE ipo_lines_all';

  xErrLoc:= 240;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE ipo_line_locations_all');
  EXECUTE IMMEDIATE
    'DROP TABLE ipo_line_locations_all';

  xErrLoc:= 260;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE ipo_quotation_approvals_all');
  EXECUTE IMMEDIATE
    'DROP TABLE ipo_quotation_approvals_all';

  xErrLoc:= 280;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE ipo_line_types_b');
  EXECUTE IMMEDIATE
    'DROP TABLE ipo_line_types_b';
  xErrLoc:= 300;

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE ipo_ga_org_assignments');
  EXECUTE IMMEDIATE
    'DROP TABLE ipo_ga_org_assignments';

  xErrLoc:= 320;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE ipo_asl_attributes');
  EXECUTE IMMEDIATE
    'DROP TABLE ipo_asl_attributes';

  xErrLoc:= 340;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE ipo_approved_supplier_list');
  EXECUTE IMMEDIATE
    'DROP TABLE ipo_approved_supplier_list';

  xErrLoc:= 360;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE ipo_asl_status_rules');
  EXECUTE IMMEDIATE
    'DROP TABLE ipo_asl_status_rules';

  xErrLoc:= 380;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE ipo_vendors');
  EXECUTE IMMEDIATE
    'DROP TABLE ipo_vendors';

  xErrLoc:= 400;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE ipo_vendor_sites_all');
  EXECUTE IMMEDIATE
    'DROP TABLE ipo_vendor_sites_all';

  xErrLoc:= 420;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE imtl_system_items_kfv');
  EXECUTE IMMEDIATE
    'DROP TABLE imtl_system_items_kfv';

  xErrLoc:= 440;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE imtl_system_items_tl');
  EXECUTE IMMEDIATE
    'DROP TABLE imtl_system_items_tl';

  xErrLoc:= 460;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE imtl_item_categories');
  EXECUTE IMMEDIATE
    'DROP TABLE imtl_item_categories';

  xErrLoc:= 480;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE ifinancials_system_params_all');
  EXECUTE IMMEDIATE
    'DROP TABLE ifinancials_system_params_all';

  xErrLoc:= 500;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE ipo_system_parameters_all');
  EXECUTE IMMEDIATE
    'DROP TABLE ipo_system_parameters_all';

  xErrLoc:= 520;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'DROP TABLE igl_sets_of_books');
  EXECUTE IMMEDIATE
    'DROP TABLE igl_sets_of_books';

  xErrLoc:= 600;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.dropTables-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END dropTables;

-- Clean up data for unit test
PROCEDURE cleanupData
IS
  xErrLoc	PLS_INTEGER:= 100;
  xString	VARCHAR2(2000);
  cTestRows	tCursorType;
  xRowIds	DBMS_SQL.UROWID_TABLE;
  xRowCount	PLS_INTEGER := 0;

BEGIN
  xErrLoc:= 100;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'Delete test data from icx_cat_categories_tl');
  xErrLoc:= 120;
  OPEN cTestRows FOR
    SELECT ROWID FROM icx_cat_categories_tl
    WHERE last_updated_by = TEST_USER_ID;
  xErrLoc := 140;
  LOOP
    xRowIds.DELETE;
    xErrLoc := 160;
    FETCH cTestRows
    BULK  COLLECT INTO xRowIds
    LIMIT gCommitSize;
    EXIT  WHEN xRowIds.COUNT = 0;
    xRowCount := xRowCount + xRowIds.COUNT;
    xErrLoc := 180;
    FORALL i IN 1..xRowIds.COUNT
      DELETE icx_cat_categories_tl
      WHERE  rowid = xRowIds(i);
    COMMIT;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
      'Processed records: ' || xRowCount);
  END LOOP;
  CLOSE cTestRows;

  xErrLoc:= 200;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'Delete test data from icx_por_category_data_sources');
  xErrLoc:= 220;
  xRowCount := 0;
  OPEN cTestRows FOR
    SELECT ROWID FROM icx_por_category_data_sources
    WHERE last_updated_by = TEST_USER_ID;
  xErrLoc := 240;
  LOOP
    xRowIds.DELETE;
    xErrLoc := 260;
    FETCH cTestRows
    BULK  COLLECT INTO xRowIds
    LIMIT gCommitSize;
    EXIT  WHEN xRowIds.COUNT = 0;
    xRowCount := xRowCount + xRowIds.COUNT;
    xErrLoc := 280;
    FORALL i IN 1..xRowIds.COUNT
      DELETE icx_por_category_data_sources
      WHERE  rowid = xRowIds(i);
    COMMIT;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
      'Processed records: ' || xRowCount);
  END LOOP;
  CLOSE cTestRows;

  xErrLoc:= 300;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'Delete test data from icx_por_category_order_map');
  xErrLoc:= 320;
  xRowCount := 0;
  OPEN cTestRows FOR
    SELECT ROWID FROM icx_por_category_order_map
    WHERE last_updated_by =  TEST_USER_ID;
  xErrLoc := 340;
  LOOP
    xRowIds.DELETE;
    xErrLoc := 360;
    FETCH cTestRows
    BULK  COLLECT INTO xRowIds
    LIMIT gCommitSize;
    EXIT  WHEN xRowIds.COUNT = 0;
    xRowCount := xRowCount + xRowIds.COUNT;
    xErrLoc := 380;
    FORALL i IN 1..xRowIds.COUNT
      DELETE icx_por_category_order_map
      WHERE  rowid = xRowIds(i);
    COMMIT;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
      'Processed records: ' || xRowCount);
  END LOOP;
  CLOSE cTestRows;

  xErrLoc:= 400;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'Delete test data from icx_cat_items_b');
  xErrLoc:= 420;
  xRowCount := 0;
  OPEN cTestRows FOR
    SELECT ROWID FROM icx_cat_items_b
    WHERE last_updated_by =  TEST_USER_ID;
  xErrLoc := 440;
  LOOP
    xRowIds.DELETE;
    xErrLoc := 460;
    FETCH cTestRows
    BULK  COLLECT INTO xRowIds
    LIMIT gCommitSize;
    EXIT  WHEN xRowIds.COUNT = 0;
    xRowCount := xRowCount + xRowIds.COUNT;
    xErrLoc := 480;
    FORALL i IN 1..xRowIds.COUNT
      DELETE icx_cat_items_b
      WHERE  rowid = xRowIds(i);
    COMMIT;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
      'Processed records: ' || xRowCount);
  END LOOP;
  CLOSE cTestRows;

  xErrLoc:= 500;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'Delete test data from icx_cat_items_tlp');
  xErrLoc:= 520;
  xRowCount := 0;
  OPEN cTestRows FOR
    SELECT ROWID FROM icx_cat_items_tlp
    WHERE last_updated_by =  TEST_USER_ID;
  xErrLoc := 540;
  LOOP
    xRowIds.DELETE;
    xErrLoc := 560;
    FETCH cTestRows
    BULK  COLLECT INTO xRowIds
    LIMIT gCommitSize;
    EXIT  WHEN xRowIds.COUNT = 0;
    xRowCount := xRowCount + xRowIds.COUNT;
    xErrLoc := 580;
    FORALL i IN 1..xRowIds.COUNT
      DELETE icx_cat_items_tlp
      WHERE  rowid = xRowIds(i);
    COMMIT;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
      'Processed records: ' || xRowCount);
  END LOOP;
  CLOSE cTestRows;

  xErrLoc:= 600;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'Delete test data from icx_cat_category_items');
  xErrLoc:= 620;
  xRowCount := 0;
  OPEN cTestRows FOR
    SELECT ROWID FROM icx_cat_category_items
    WHERE last_updated_by =  TEST_USER_ID;
  xErrLoc := 640;
  LOOP
    xRowIds.DELETE;
    xErrLoc := 660;
    FETCH cTestRows
    BULK  COLLECT INTO xRowIds
    LIMIT gCommitSize;
    EXIT  WHEN xRowIds.COUNT = 0;
    xRowCount := xRowCount + xRowIds.COUNT;
    xErrLoc := 680;
    FORALL i IN 1..xRowIds.COUNT
      DELETE icx_cat_category_items
      WHERE  rowid = xRowIds(i);
    COMMIT;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
      'Processed records: ' || xRowCount);
  END LOOP;
  CLOSE cTestRows;

  xErrLoc:= 700;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'Delete test data from icx_cat_ext_items_tlp');
  xErrLoc:= 720;
  xRowCount := 0;
  OPEN cTestRows FOR
    SELECT ROWID FROM icx_cat_ext_items_tlp
    WHERE last_updated_by =  TEST_USER_ID;
  xErrLoc := 740;
  LOOP
    xRowIds.DELETE;
    xErrLoc := 760;
    FETCH cTestRows
    BULK  COLLECT INTO xRowIds
    LIMIT gCommitSize;
    EXIT  WHEN xRowIds.COUNT = 0;
    xRowCount := xRowCount + xRowIds.COUNT;
    xErrLoc := 780;
    FORALL i IN 1..xRowIds.COUNT
      DELETE icx_cat_ext_items_tlp
      WHERE  rowid = xRowIds(i);
    COMMIT;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
      'Processed records: ' || xRowCount);
  END LOOP;
  CLOSE cTestRows;

  xErrLoc:= 800;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
    'Delete test data from icx_cat_item_prices');
  xErrLoc:= 820;
  xRowCount := 0;
  OPEN cTestRows FOR
    SELECT ROWID FROM icx_cat_item_prices
    WHERE last_updated_by =  TEST_USER_ID;
  xErrLoc := 840;
  LOOP
    xRowIds.DELETE;
    xErrLoc := 860;
    FETCH cTestRows
    BULK  COLLECT INTO xRowIds
    LIMIT gCommitSize;
    EXIT  WHEN xRowIds.COUNT = 0;
    xRowCount := xRowCount + xRowIds.COUNT;
    xErrLoc := 880;
    FORALL i IN 1..xRowIds.COUNT
      DELETE icx_cat_item_prices
      WHERE  rowid = xRowIds(i);
    COMMIT;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.INFO_LEVEL,
      'Processed records: ' || xRowCount);
  END LOOP;
  CLOSE cTestRows;

  xErrLoc:= 900;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    IF (cTestRows%ISOPEN) THEN
      CLOSE cTestRows;
    END IF;
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.cleanupData-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END cleanupData;

-- Cleanup unit testing
PROCEDURE cleanup
IS
  xErrLoc	PLS_INTEGER:= 100;
  xReturnErr	varchar2(2000);

BEGIN
  xErrLoc:= 100;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'Drop tables');
  dropTables;
  xErrLoc:= 200;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'Clean up data for unit test');
  cleanupData;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.cleanup-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END cleanup;

--------------------------------------------------------------
--               Classification Test Utilities              --
--------------------------------------------------------------
-- Create a category
PROCEDURE createCategory(p_category_id			IN NUMBER,
			 p_concatenated_segments	IN VARCHAR2,
			 p_description			IN VARCHAR2,
			 p_web_status			IN VARCHAR2,
			 p_start_date_active		IN DATE,
			 p_end_date_active		IN DATE,
			 p_disable_date			IN DATE)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'createCategory(p_category_id: ' || p_category_id ||
      ', p_concatenated_segments: ' || p_concatenated_segments ||
      ', p_description: ' || p_description ||
      ', p_web_status: ' || p_web_status ||
      ', p_start_date_active: ' || p_start_date_active ||
      ', p_end_date_active: ' || p_end_date_active ||
      ', p_disable_date: ' || p_disable_date || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'INSERT INTO imtl_categories_kfv( ' ||
    'category_id, ' ||
    'concatenated_segments, ' ||
    'structure_id, ' ||
    'web_status, ' ||
    'start_date_active, ' ||
    'end_date_active, ' ||
    'disable_date, ' ||
    'last_update_date) ' ||
    'VALUES( ' ||
    ':category_id, ' ||
    ':concatenated_segments, ' ||
    ':structure_id, ' ||
    ':web_status, ' ||
    ':start_date_active, ' ||
    ':end_date_active, ' ||
    ':disable_date, ' ||
    'SYSDATE) '
    USING p_category_id, p_concatenated_segments, gStructureId,
          p_web_status, p_start_date_active, p_end_date_active,
          p_disable_date;

  xErrLoc:= 200;
  EXECUTE IMMEDIATE
    'INSERT INTO imtl_category_set_valid_cats( ' ||
    'category_id, ' ||
    'category_set_id, ' ||
    'last_update_date) ' ||
    'VALUES( ' ||
    ':category_id, ' ||
    ':category_set_id, ' ||
    'SYSDATE) '
    USING p_category_id, gCategorySetId;

  xErrLoc:= 300;
  EXECUTE IMMEDIATE
    'INSERT INTO imtl_categories_tl( ' ||
    'category_id, ' ||
    'description, ' ||
    'language, ' ||
    'source_lang, ' ||
    'last_update_date) ' ||
    'VALUES( '||
    ':category_id, ' ||
    ':description, ' ||
    ':language, ' ||
    ':language, ' ||
    'SYSDATE) '
    USING p_category_id, p_description,
          gBaseLang, gBaseLang;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.createCategory-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END createCategory;

-- Update a category
PROCEDURE updateCategory(p_category_id			IN NUMBER,
			 p_concatenated_segments	IN VARCHAR2,
			 p_description			IN VARCHAR2,
			 p_web_status			IN VARCHAR2,
			 p_start_date_active		IN DATE,
			 p_end_date_active		IN DATE,
			 p_disable_date			IN DATE)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'updateCategory(p_category_id: ' || p_category_id ||
      ', p_concatenated_segments: ' || p_concatenated_segments ||
      ', p_description: ' || p_description ||
      ', p_web_status: ' || p_web_status ||
      ', p_start_date_active: ' || p_start_date_active ||
      ', p_end_date_active: ' || p_end_date_active ||
      ', p_disable_date: ' || p_disable_date || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'UPDATE imtl_categories_kfv ' ||
    'SET concatenated_segments = DECODE(:concatenated_segments, ' ||
    ':miss_char, concatenated_segments,:concatenated_segments), ' ||
    'web_status = DECODE(:web_status,:miss_char, ' ||
    'web_status,:web_status), ' ||
    'start_date_active = DECODE(:start_date_active,:miss_date, ' ||
    'start_date_active,:start_date_active), ' ||
    'end_date_active = DECODE(:end_date_active,:miss_date, ' ||
    'end_date_active,:end_date_active), ' ||
    'disable_date = DECODE(:disable_date,:miss_date, disable_date, ' ||
    ':disable_date), ' ||
    'last_update_date = SYSDATE ' ||
    'WHERE category_id =:category_id '
    USING p_concatenated_segments, FND_API.G_MISS_CHAR, p_concatenated_segments,
          p_web_status, FND_API.G_MISS_CHAR, p_web_status,
          p_start_date_active, FND_API.G_MISS_DATE, p_start_date_active,
          p_end_date_active, FND_API.G_MISS_DATE, p_end_date_active,
          p_disable_date, FND_API.G_MISS_DATE, p_disable_date,
          p_category_id;


  xErrLoc:= 200;
  EXECUTE IMMEDIATE
    'UPDATE imtl_categories_tl ' ||
    'SET description = DECODE(:description,:miss_char, ' ||
    'description,:description), ' ||
    'last_update_date = SYSDATE ' ||
    'WHERE category_id =:category_id ' ||
    'AND language =:language '
    USING p_description, FND_API.G_MISS_CHAR, p_description,
          p_category_id, gBaseLang;

  xErrLoc:= 300;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.updateCategory-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END updateCategory;

-- Translate a category
PROCEDURE translateCategory(p_category_id	IN NUMBER,
			    p_description	IN VARCHAR2,
			    p_language		IN VARCHAR2)
IS
  xErrLoc	PLS_INTEGER:= 100;
  xExist	PLS_INTEGER:= 0;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'translateCategory(p_category_id: ' || p_category_id ||
      ', p_description: ' || p_description ||
      ', p_language: ' || p_language || ')');
  END IF;

  xErrLoc:= 100;
  BEGIN
    SELECT 1
    INTO   xExist
    FROM   dual
    WHERE  EXISTS (SELECT 'installed language'
                   FROM   fnd_languages
                   WHERE  installed_flag = 'I'
                   AND    language_code = p_language);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
        'Not an installed language: ' || p_language);
      RETURN;
  END;

  xErrLoc:= 120;
  EXECUTE IMMEDIATE
    'INSERT INTO imtl_categories_tl( ' ||
    'category_id, ' ||
    'description, ' ||
    'language, ' ||
    'source_lang, ' ||
    'last_update_date) ' ||
    'SELECT:category_id, ' ||
    ':description, ' ||
    ':language, ' ||
    ':language, ' ||
    'SYSDATE ' ||
    'FROM dual ' ||
    'WHERE NOT EXISTS (SELECT 1 ' ||
    'FROM imtl_categories_tl ' ||
    'WHERE category_id =:category_id ' ||
    'AND language =:language) '
    USING p_category_id, p_description, p_language,
          p_language, p_category_id, p_language;

  xErrLoc:= 200;
  EXECUTE IMMEDIATE
    'UPDATE imtl_categories_tl ' ||
    'SET description =:description, ' ||
    'last_update_date = SYSDATE ' ||
    'WHERE category_id =:category_id ' ||
    'AND language =:language '
    USING p_description, p_category_id, p_language;

  xErrLoc:= 300;
  COMMIT;

EXCEPTION
  when others then
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.translateCategory-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END translateCategory;

-- Create a template header
PROCEDURE createTemplateHeader(p_org_id			IN NUMBER,
			       p_express_name		IN VARCHAR2,
			       p_type_lookup_code	IN VARCHAR2,
			       p_inactive_date		IN DATE)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'createTemplateHeader(p_org_id: ' || p_org_id ||
      ', p_express_name: ' || p_express_name ||
      ', p_type_lookup_code: ' || p_type_lookup_code ||
      ', p_inactive_date: ' || p_inactive_date || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'INSERT INTO ipo_reqexpress_headers_all( ' ||
    'org_id, ' ||
    'express_name, ' ||
    'type_lookup_code, ' ||
    'inactive_date, ' ||
    'last_update_date) ' ||
    'VALUES( ' ||
    ':org_id, ' ||
    ':express_name, ' ||
    ':type_lookup_code, ' ||
    ':inactive_date, ' ||
    'SYSDATE) '
    USING p_org_id, p_express_name,
          p_type_lookup_code, p_inactive_date;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.createTemplateHeader-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END createTemplateHeader;

-- Update a template header
PROCEDURE updateTemplateHeader(p_org_id		IN NUMBER,
			       p_express_name	IN VARCHAR2,
			       p_inactive_date	IN DATE)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'updateTemplateHeader(p_org_id: ' || p_org_id ||
      ', p_express_name: ' || p_express_name ||
      ', p_inactive_date: ' || p_inactive_date || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'UPDATE ipo_reqexpress_headers_all ' ||
    'SET inactive_date =:inactive_date, ' ||
    'last_update_date = SYSDATE ' ||
    'WHERE org_id =:org_id ' ||
    'AND express_name =:express_name '
    USING p_inactive_date, p_org_id, p_express_name;

  xErrLoc:= 200;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.updateTemplateHeader-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END updateTemplateHeader;

--------------------------------------------------------------
--            Classification Test Result Checking           --
--------------------------------------------------------------
FUNCTION existCategory(p_category_key	IN VARCHAR2,
		       p_category_name	IN VARCHAR2,
		       p_category_type	IN NUMBER)
  RETURN BOOLEAN
IS
  xErrLoc	PLS_INTEGER;
  xResult	PLS_INTEGER;
BEGIN
  xErrLoc:= 100;
  SELECT 1
  INTO   xResult
  FROM   icx_cat_categories_tl
  WHERE  key = p_category_key
  AND    category_name = p_category_name
  AND    ROWNUM = 1;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
    'Category[Key: ' || p_category_key || ', Name: ' ||
    p_category_name || '] exists in ICX_CAT_CATEGORIES_TL');

  xErrLoc:= 140;
  SELECT 2
  INTO   xResult
  FROM   icx_por_category_data_sources
  WHERE  category_key = p_category_key
  AND    external_source_key = p_category_key
  AND    ROWNUM = 1;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
    'Category[Key: ' || p_category_key || ', Name: ' ||
    p_category_name || '] exists in ICX_POR_CATEGORY_DATA_SOURCES');

  xErrLoc:= 180;
  IF p_category_type = ICX_POR_EXT_CLASS.CATEGORY_TYPE THEN
    SELECT 3
    INTO   xResult
    FROM   icx_por_category_order_map
    WHERE  external_source_key = p_category_key
    AND    ROWNUM = 1;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
      'Category[Key: ' || p_category_key || ', Name: ' ||
      p_category_name || '] exists in ICX_POR_CATEGORY_ORDER_MAP');
  END IF;

  xErrLoc:= 200;
  RETURN TRUE;
EXCEPTION
  when NO_DATA_FOUND then
    xResult:= 0;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
      'Category[Key: ' || p_category_key || ', Name: ' ||
      p_category_name || '] does not exist');
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
      'Category[Key: ' || p_category_key || ', Name: ' ||
      p_category_name || '] does not exist');
    RETURN FALSE;
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.existCategory-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END existCategory;

FUNCTION notExistCategory(p_category_key	IN VARCHAR2)
  RETURN BOOLEAN
IS
  xErrLoc	PLS_INTEGER;
  xResult	PLS_INTEGER;
BEGIN
  xErrLoc:= 100;
  SELECT 0
  INTO   xResult
  FROM   icx_cat_categories_tl
  WHERE  key = p_category_key
  AND    ROWNUM = 1;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
    'Category[Key: ' || p_category_key || '] exists in ICX_CAT_CATEGORIES_TL');
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
    'Category[Key: ' || p_category_key || '] exist');

  xErrLoc:= 200;
  RETURN FALSE;
EXCEPTION
  when NO_DATA_FOUND then
    xResult:= 1;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
      'Category[Key: ' || p_category_key || '] does not exists');
    RETURN TRUE;
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.notExistCategory-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END notExistCategory;

FUNCTION existCategoryTL(p_category_key		IN VARCHAR2,
			 p_category_name	IN VARCHAR2,
		         p_language		IN VARCHAR2)
  RETURN BOOLEAN
IS
  xErrLoc	PLS_INTEGER;
  xResult	PLS_INTEGER;
BEGIN
  xErrLoc:= 100;
  SELECT 1
  INTO   xResult
  FROM   icx_cat_categories_tl
  WHERE  key = p_category_key
  AND    category_name = p_category_name
  AND    language = p_language
  AND    ROWNUM = 1;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
    'Category[Key: ' || p_category_key || ', Name: ' ||
    p_category_name || ', Language: ' || p_language ||
    '] exists in ICX_CAT_CATEGORIES_TL');

  xErrLoc:= 200;
  RETURN TRUE;
EXCEPTION
  when NO_DATA_FOUND then
    xResult:= 0;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
      'Category[Key: ' || p_category_key || ', Name: ' ||
      p_category_name || ', Language: ' || p_language ||
      '] does not exist');
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
      'Category[Key: ' || p_category_key || ', Name: ' ||
      p_category_name || ', Language: ' || p_language ||
      '] does not exist');
    RETURN FALSE;
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.existCategoryTL-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END existCategoryTL;

--------------------------------------------------------------
--                   Item Test Utilities                    --
--------------------------------------------------------------
-- Create a sets of book
PROCEDURE createGSB(p_set_of_books_id		IN NUMBER,
                    p_currency_code		IN VARCHAR2)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'createGSB(p_set_of_books_id: ' || p_set_of_books_id ||
      ', p_currency_code: ' || p_currency_code || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'INSERT INTO igl_sets_of_books( ' ||
    'set_of_books_id, ' ||
    'currency_code) ' ||
    'VALUES( ' ||
    ':set_of_books_id, ' ||
    ':currency_code) '
    USING p_set_of_books_id, p_currency_code;

  xErrLoc:= 400;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.createGSB-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END createGSB;

-- Create financial system parameters
PROCEDURE createFSP(p_org_id			IN NUMBER,
                    p_inventory_organization_id	IN NUMBER,
                    p_set_of_books_id		IN NUMBER)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'createFSP(p_org_id: ' || p_org_id ||
      ', p_inventory_organization_id: ' || p_inventory_organization_id ||
      ', p_set_of_books_id: ' || p_set_of_books_id || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'INSERT INTO ifinancials_system_params_all( ' ||
    'org_id, ' ||
    'inventory_organization_id, ' ||
    'set_of_books_id) ' ||
    'VALUES( ' ||
    ':org_id, ' ||
    ':inventory_organization_id, ' ||
    ':set_of_books_id) '
    USING p_org_id, p_inventory_organization_id, p_set_of_books_id;

  xErrLoc:= 200;
  EXECUTE IMMEDIATE
    'INSERT INTO ipo_system_parameters_all( ' ||
    'org_id, ' ||
    'default_rate_type, ' ||
    'last_update_date) ' ||  -- Bug# 2945205 : pcreddy
    'VALUES( ' ||
    ':org_id, ' ||
    '''Corporate'', ' ||
    'SYSDATE) '   -- Bug# 2945205 : pcreddy
    USING p_org_id;

  xErrLoc:= 400;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.createFSP-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END createFSP;

-- Create an item
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
		     p_category_id			IN NUMBER)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'createItem(p_inventory_item_id: ' || p_inventory_item_id ||
      ', p_organization_id: ' || p_organization_id ||
      ', p_concatenated_segments: ' || p_concatenated_segments ||
      ', p_purchasing_enabled_flag: ' || p_purchasing_enabled_flag ||
      ', p_outside_operation_flag: ' || p_outside_operation_flag ||
      ', p_internal_order_enabled_flag: ' || p_internal_order_enabled_flag ||
      ', p_list_price_per_unit: ' || p_list_price_per_unit ||
      ', p_primary_uom_code: ' || p_primary_uom_code ||
      ', p_replenish_to_order_flag: ' || p_replenish_to_order_flag ||
      ', p_base_item_id: ' || p_base_item_id ||
      ', p_auto_created_config_flag: ' || p_auto_created_config_flag ||
      ', p_unit_of_issue: ' || p_unit_of_issue ||
      ', p_description: ' || p_description ||
      ', p_category_id: ' || p_category_id || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'INSERT INTO imtl_system_items_kfv( ' ||
    'inventory_item_id, ' ||
    'organization_id, ' ||
    'concatenated_segments, ' ||
    'purchasing_enabled_flag, ' ||
    'outside_operation_flag, ' ||
    'internal_order_enabled_flag, ' ||
    'list_price_per_unit, ' ||
    'primary_uom_code, ' ||
    'replenish_to_order_flag, ' ||
    'base_item_id, ' ||
    'auto_created_config_flag, ' ||
    'unit_of_issue, ' ||
    'last_update_date) ' ||
    'VALUES( ' ||
    ':inventory_item_id, ' ||
    ':organization_id, ' ||
    ':concatenated_segments, ' ||
    ':purchasing_enabled_flag, ' ||
    ':outside_operation_flag, ' ||
    ':internal_order_enabled_flag, ' ||
    ':list_price_per_unit, ' ||
    ':primary_uom_code, ' ||
    ':replenish_to_order_flag, ' ||
    ':base_item_id, ' ||
    ':auto_created_config_flag, ' ||
    ':unit_of_issue, ' ||
    'SYSDATE) '
    USING p_inventory_item_id, p_organization_id,
          p_concatenated_segments, p_purchasing_enabled_flag,
          p_outside_operation_flag, p_internal_order_enabled_flag,
          p_list_price_per_unit, p_primary_uom_code,
          p_replenish_to_order_flag, p_base_item_id,
          p_auto_created_config_flag, p_unit_of_issue;

  xErrLoc:= 200;
  EXECUTE IMMEDIATE
    'INSERT INTO imtl_system_items_tl( ' ||
    'inventory_item_id, ' ||
    'organization_id, ' ||
    'description, ' ||
    'language, ' ||
    'source_lang, ' ||
    'last_update_date) ' ||
    'VALUES( ' ||
    ':inventory_item_id, ' ||
    ':organization_id, ' ||
    ':description, ' ||
    ':language, ' ||
    ':language, ' ||
    'SYSDATE) '
    USING p_inventory_item_id, p_organization_id,
          p_description, gBaseLang, gBaseLang;

  xErrLoc:= 300;
  EXECUTE IMMEDIATE
    'INSERT INTO imtl_item_categories( ' ||
    'inventory_item_id, ' ||
    'organization_id, ' ||
    'category_id, ' ||
    'category_set_id, ' ||
    'last_update_date) ' ||
    'VALUES( ' ||
    ':inventory_item_id, ' ||
    ':organization_id, ' ||
    ':category_id, ' ||
    ':category_set_id, ' ||
    'SYSDATE) '
    USING p_inventory_item_id, p_organization_id,
          p_category_id, gCategorySetId;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.createItem-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END createItem;

-- Update an item
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
		     p_category_id			IN NUMBER)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'updateItem(p_inventory_item_id: ' || p_inventory_item_id ||
      ', p_organization_id: ' || p_organization_id ||
      ', p_concatenated_segments: ' || p_concatenated_segments ||
      ', p_purchasing_enabled_flag: ' || p_purchasing_enabled_flag ||
      ', p_outside_operation_flag: ' || p_outside_operation_flag ||
      ', p_internal_order_enabled_flag: ' || p_internal_order_enabled_flag ||
      ', p_list_price_per_unit: ' || p_list_price_per_unit ||
      ', p_primary_uom_code: ' || p_primary_uom_code ||
      ', p_replenish_to_order_flag: ' || p_replenish_to_order_flag ||
      ', p_base_item_id: ' || p_base_item_id ||
      ', p_auto_created_config_flag: ' || p_auto_created_config_flag ||
      ', p_unit_of_issue: ' || p_unit_of_issue ||
      ', p_description: ' || p_description ||
      ', p_category_id: ' || p_category_id || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'UPDATE imtl_system_items_kfv SET ' ||
    'concatenated_segments = DECODE(:concatenated_segments, '||
    ':miss_char, concatenated_segments,:concatenated_segments), '||
    'purchasing_enabled_flag = DECODE(:purchasing_enabled_flag, '||
    ':miss_char, purchasing_enabled_flag,:purchasing_enabled_flag), '||
    'outside_operation_flag = DECODE(:outside_operation_flag, ' ||
    ':miss_char, outside_operation_flag,:outside_operation_flag), '||
    'internal_order_enabled_flag = DECODE(:internal_order_enabled_flag, '||
    ':miss_char, internal_order_enabled_flag,:internal_order_enabled_flag), '||
    'list_price_per_unit = DECODE(:list_price_per_unit, '||
    ':miss_num, list_price_per_unit,:list_price_per_unit), '||
    'primary_uom_code = DECODE(:primary_uom_code, '||
    ':miss_char, primary_uom_code,:primary_uom_code), '||
    'replenish_to_order_flag = DECODE(:replenish_to_order_flag, '||
    ':miss_char, replenish_to_order_flag,:replenish_to_order_flag), '||
    'base_item_id = DECODE(:base_item_id, '||
    ':miss_num, base_item_id,:base_item_id), '||
    'auto_created_config_flag = DECODE(:auto_created_config_flag, '||
    ':miss_char, auto_created_config_flag,:auto_created_config_flag), '||
    'unit_of_issue = DECODE(:unit_of_issue, '||
    ':miss_char, unit_of_issue,:unit_of_issue), '||
    'last_update_date = SYSDATE ' ||
    'WHERE inventory_item_id =:inventory_item_id ' ||
    'AND organization_id =:organization_id '
    USING p_concatenated_segments, FND_API.G_MISS_CHAR, p_concatenated_segments,
          p_purchasing_enabled_flag, FND_API.G_MISS_CHAR, p_purchasing_enabled_flag,
          p_outside_operation_flag, FND_API.G_MISS_CHAR, p_outside_operation_flag,
          p_internal_order_enabled_flag, FND_API.G_MISS_CHAR, p_internal_order_enabled_flag,
          p_list_price_per_unit, FND_API.G_MISS_NUM, p_list_price_per_unit,
          p_primary_uom_code, FND_API.G_MISS_CHAR, p_primary_uom_code,
          p_replenish_to_order_flag, FND_API.G_MISS_CHAR, p_replenish_to_order_flag,
          p_base_item_id, FND_API.G_MISS_NUM, p_base_item_id,
          p_auto_created_config_flag, FND_API.G_MISS_CHAR, p_auto_created_config_flag,
          p_unit_of_issue, FND_API.G_MISS_CHAR, p_unit_of_issue,
          p_inventory_item_id, p_organization_id;

  xErrLoc:= 200;
  EXECUTE IMMEDIATE
    'UPDATE imtl_system_items_tl SET ' ||
    'description = DECODE(:description, '||
    ':miss_char, description,:description), '||
    'last_update_date = SYSDATE ' ||
    'WHERE inventory_item_id =:inventory_item_id ' ||
    'AND organization_id =:organization_id '
    USING p_description, FND_API.G_MISS_CHAR, p_description,
          p_inventory_item_id, p_organization_id;

  xErrLoc:= 300;
  EXECUTE IMMEDIATE
    'UPDATE imtl_item_categories SET ' ||
    'category_id = DECODE(:category_id, '||
    ':miss_num, category_id,:category_id), '||
    'last_update_date = SYSDATE ' ||
    'WHERE inventory_item_id =:inventory_item_id ' ||
    'AND organization_id =:organization_id '
    USING p_category_id, FND_API.G_MISS_NUM, p_category_id,
          p_inventory_item_id, p_organization_id;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.updateItem-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END updateItem;

-- Translate an item
PROCEDURE translateItem(p_inventory_item_id	IN NUMBER,
                        p_organization_id	IN NUMBER,
			p_description		IN VARCHAR2,
			p_language		IN VARCHAR2)
IS
  xErrLoc	PLS_INTEGER:= 100;
  xExist	PLS_INTEGER:= 0;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'translateItem(p_inventory_item_id: ' || p_inventory_item_id ||
      ', p_organization_id: ' || p_organization_id ||
      ', p_description: ' || p_description ||
      ', p_language: ' || p_language || ')');
  END IF;

  xErrLoc:= 100;
  BEGIN
    SELECT 1
    INTO   xExist
    FROM   dual
    WHERE  EXISTS (SELECT 'installed language'
                   FROM   fnd_languages
                   WHERE  installed_flag = 'I'
                   AND    language_code = p_language);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
        'Not an installed language: ' || p_language);
      RETURN;
  END;

  xErrLoc:= 120;
  EXECUTE IMMEDIATE
    'INSERT INTO imtl_system_items_tl( ' ||
    'inventory_item_id, ' ||
    'organization_id, ' ||
    'description, ' ||
    'language, ' ||
    'source_lang, ' ||
    'last_update_date) ' ||
    'SELECT:inventory_item_id, ' ||
    ':organization_id, ' ||
    ':description, ' ||
    ':language, ' ||
    ':language, ' ||
    'SYSDATE ' ||
    'FROM dual ' ||
    'WHERE NOT EXISTS (SELECT 1 ' ||
    'FROM imtl_system_items_tl ' ||
    'WHERE inventory_item_id =:inventory_item_id ' ||
    'AND organization_id =:organization_id ' ||
    'AND language =:language) '
    USING p_inventory_item_id, p_organization_id,
          p_description, p_language, p_language,
          p_inventory_item_id, p_organization_id,
          p_language;

  xErrLoc:= 200;
  EXECUTE IMMEDIATE
    'UPDATE imtl_system_items_tl ' ||
    'SET description =:description, ' ||
    'last_update_date = SYSDATE ' ||
    'WHERE inventory_item_id =:inventory_item_id ' ||
    'AND organization_id =:organization_id ' ||
    'AND language =:language '
    USING p_description, p_inventory_item_id,
          p_organization_id, p_language;

  xErrLoc:= 300;
  COMMIT;

EXCEPTION
  when others then
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.translateItem-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END translateItem;

-- Delete an item
PROCEDURE deleteItem(p_inventory_item_id		IN NUMBER,
                     p_organization_id			IN NUMBER)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'deleteItem(p_inventory_item_id: ' || p_inventory_item_id ||
      ', p_organization_id: ' || p_organization_id || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'DELETE FROM imtl_system_items_kfv ' ||
    'WHERE inventory_item_id =:inventory_item_id ' ||
    'AND organization_id =:organization_id '
    USING p_inventory_item_id, p_organization_id;

  xErrLoc:= 200;
  EXECUTE IMMEDIATE
    'DELETE FROM imtl_system_items_tl ' ||
    'WHERE inventory_item_id =:inventory_item_id ' ||
    'AND organization_id =:organization_id '
    USING p_inventory_item_id, p_organization_id;

  xErrLoc:= 300;
  EXECUTE IMMEDIATE
    'DELETE FROM imtl_item_categories ' ||
    'WHERE inventory_item_id =:inventory_item_id ' ||
    'AND organization_id =:organization_id '
    USING p_inventory_item_id, p_organization_id;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.deleteItem-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END deleteItem;

-- Create a vendor
PROCEDURE createVendor(p_vendor_id	IN NUMBER,
                       p_vendor_name	IN VARCHAR2)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'createVendor(p_vendor_id: ' || p_vendor_id ||
      ', p_vendor_name: ' || p_vendor_name || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'INSERT INTO ipo_vendors( ' ||
    'vendor_id, ' ||
    'vendor_name, ' ||
    'last_update_date) ' ||
    'VALUES( ' ||
    ':vendor_id, ' ||
    ':vendor_name, ' ||
    'SYSDATE) '
    USING p_vendor_id, p_vendor_name;

  xErrLoc:= 400;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.createVendor-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END createVendor;

-- Update a vendor
PROCEDURE updateVendor(p_vendor_id	IN NUMBER,
                       p_vendor_name	IN VARCHAR2)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'updateVendor(p_vendor_id: ' || p_vendor_id ||
      ', p_vendor_name: ' || p_vendor_name || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'UPDATE ipo_vendors ' ||
    'SET vendor_name =:vendor_name, ' ||
    'last_update_date = SYSDATE ' ||
    'WHERE vendor_id =:vendor_id '
    USING p_vendor_name, p_vendor_id;

  xErrLoc:= 200;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.updateVendor-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END updateVendor;

-- Create a vendor site
PROCEDURE createVendorSite(p_vendor_site_id		IN NUMBER,
                           p_vendor_site_code		IN VARCHAR2,
                           p_purchasing_site_flag	IN VARCHAR2)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'createVendorSite(p_vendor_site_id: ' || p_vendor_site_id ||
      ', p_vendor_site_code: ' || p_vendor_site_code ||
      ', p_purchasing_site_flag: ' || p_purchasing_site_flag || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'INSERT INTO ipo_vendor_sites_all( ' ||
    'vendor_site_id, ' ||
    'vendor_site_code, ' ||
    'purchasing_site_flag, ' ||
    'inactive_date, ' ||
    'last_update_date) ' ||
    'VALUES( ' ||
    ':vendor_site_id, ' ||
    ':vendor_site_code, ' ||
    ':purchasing_site_flag, ' ||
    'NULL, ' ||
    'SYSDATE) '
    USING p_vendor_site_id, p_vendor_site_code, p_purchasing_site_flag;

  xErrLoc:= 400;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.createVendorSite-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END createVendorSite;

-- Update a vendor site
PROCEDURE updateVendorSite(p_vendor_site_id		IN NUMBER,
                           p_purchasing_site_flag	IN VARCHAR2,
                           p_inactive_date		IN DATE)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'createVendor(p_vendor_site_id: ' || p_vendor_site_id ||
      ', p_purchasing_site_flag: ' || p_purchasing_site_flag ||
      ', p_inactive_date: ' || p_inactive_date || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'UPDATE ipo_vendor_sites_all SET ' ||
    'purchasing_site_flag = DECODE(:purchasing_site_flag, '||
    ':miss_char, purchasing_site_flag,:purchasing_site_flag), '||
    'inactive_date = DECODE(:inactive_date, '||
    ':miss_date, inactive_date,:inactive_date), '||
    'last_update_date = SYSDATE ' ||
    'WHERE vendor_site_id =:vendor_site_id '
    USING p_purchasing_site_flag, FND_API.G_MISS_CHAR, p_purchasing_site_flag,
          p_inactive_date, FND_API.G_MISS_DATE, p_inactive_date,
          p_vendor_site_id;

  xErrLoc:= 400;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.updateVendorSite-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END updateVendorSite;

-- Create an ASL
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
		    p_purchasing_unit_of_measure	IN VARCHAR2)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'createASL(p_asl_id: ' || p_asl_id ||
      ', p_asl_status_id: ' || p_asl_status_id ||
      ', p_owning_organization_id: ' || p_owning_organization_id ||
      ', p_item_id: ' || p_item_id ||
      ', p_category_id: ' || p_category_id ||
      ', p_vendor_id: ' || p_vendor_id ||
      ', p_vendor_site_id: ' || p_vendor_site_id ||
      ', p_primary_vendor_item: ' || p_primary_vendor_item ||
      ', p_disable_flag: ' || p_disable_flag ||
      ', p_allow_action_flag: ' || p_allow_action_flag ||
      ', p_purchasing_unit_of_measure: ' || p_purchasing_unit_of_measure || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'INSERT INTO ipo_approved_supplier_list( ' ||
    'asl_id, ' ||
    'asl_status_id, ' ||
    'owning_organization_id, ' ||
    'item_id, ' ||
    'category_id, ' ||
    'vendor_id, ' ||
    'vendor_site_id, ' ||
    'primary_vendor_item, ' ||
    'disable_flag, ' ||
    'creation_date, ' ||
    'last_update_date) ' ||
    'VALUES( ' ||
    ':asl_id, ' ||
    ':asl_status_id, ' ||
    ':owning_organization_id, ' ||
    ':item_id, ' ||
    ':category_id, ' ||
    ':vendor_id, ' ||
    ':vendor_site_id, ' ||
    ':primary_vendor_item, ' ||
    ':disable_flag, ' ||
    'SYSDATE, ' ||
    'SYSDATE) '
    USING p_asl_id, p_asl_status_id,
          p_owning_organization_id, p_item_id,
          p_category_id, p_vendor_id, p_vendor_site_id,
	  p_primary_vendor_item, p_disable_flag;

  xErrLoc:= 200;
  EXECUTE IMMEDIATE
    'INSERT INTO ipo_asl_status_rules( ' ||
    'status_id, ' ||
    'business_rule, ' ||
    'allow_action_flag, ' ||
    'last_update_date) ' ||
    'VALUES( ' ||
    ':status_id, ' ||
    '''2_SOURCING'', ' ||
    ':allow_action_flag, ' ||
    'SYSDATE) '
    USING p_asl_status_id, p_allow_action_flag;

  xErrLoc:= 300;
  EXECUTE IMMEDIATE
    'INSERT INTO ipo_asl_attributes( ' ||
    'asl_id, ' ||
    'purchasing_unit_of_measure, ' ||
    'last_update_date) ' ||
    'VALUES( ' ||
    ':asl_id, ' ||
    ':purchasing_unit_of_measure, ' ||
    'SYSDATE) '
    USING p_asl_id, p_purchasing_unit_of_measure;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.createASL-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END createASL;

-- Update an ASL
PROCEDURE updateASL(p_asl_id				IN NUMBER,
                    p_asl_status_id			IN NUMBER,
		    p_vendor_site_id			IN NUMBER,
		    p_primary_vendor_item		IN VARCHAR2,
		    p_disable_flag			IN VARCHAR2,
		    p_allow_action_flag			IN VARCHAR2,
		    p_purchasing_unit_of_measure	IN VARCHAR2)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'updateASL(p_asl_id: ' || p_asl_id ||
      ', p_asl_status_id: ' || p_asl_status_id ||
      ', p_vendor_site_id: ' || p_vendor_site_id ||
      ', p_primary_vendor_item: ' || p_primary_vendor_item ||
      ', p_disable_flag: ' || p_disable_flag ||
      ', p_allow_action_flag: ' || p_allow_action_flag ||
      ', p_purchasing_unit_of_measure: ' || p_purchasing_unit_of_measure || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'UPDATE ipo_approved_supplier_list SET ' ||
    'vendor_site_id = DECODE(:vendor_site_id, '||
    ':miss_num, vendor_site_id,:vendor_site_id), '||
    'primary_vendor_item = DECODE(:primary_vendor_item, '||
    ':miss_char, primary_vendor_item,:primary_vendor_item), '||
    'disable_flag = DECODE(:disable_flag, '||
    ':miss_char, disable_flag,:disable_flag), '||
    'last_update_date = SYSDATE ' ||
    'WHERE asl_id =:asl_id '
    USING p_vendor_site_id, FND_API.G_MISS_NUM, p_vendor_site_id,
          p_primary_vendor_item, FND_API.G_MISS_CHAR, p_primary_vendor_item,
          p_disable_flag, FND_API.G_MISS_CHAR, p_disable_flag,
          p_asl_id;

  xErrLoc:= 200;
  EXECUTE IMMEDIATE
    'UPDATE ipo_asl_status_rules SET ' ||
    'allow_action_flag = DECODE(:allow_action_flag, '||
    ':miss_char, allow_action_flag,:allow_action_flag), '||
    'last_update_date = SYSDATE ' ||
    'WHERE status_id =:status_id '
    USING p_allow_action_flag, FND_API.G_MISS_CHAR, p_allow_action_flag,
          p_asl_status_id;

  xErrLoc:= 300;
  EXECUTE IMMEDIATE
    'UPDATE ipo_asl_attributes SET ' ||
    'purchasing_unit_of_measure = DECODE(:purchasing_unit_of_measure, '||
    ':miss_char, purchasing_unit_of_measure,:purchasing_unit_of_measure), '||
    'last_update_date = SYSDATE ' ||
    'WHERE asl_id =:asl_id '
    USING p_purchasing_unit_of_measure, FND_API.G_MISS_CHAR,
          p_purchasing_unit_of_measure, p_asl_id;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.updateASL-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END updateASL;

-- Create a template line
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
			     p_vendor_product_code 	IN VARCHAR2)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'createTemplateLine(p_org_id: ' || p_org_id ||
      ', p_express_name: ' || p_express_name ||
      ', p_sequence_num: ' || p_sequence_num ||
      ', p_source_type_code: ' || p_source_type_code ||
      ', p_po_header_id: ' || p_po_header_id ||
      ', p_po_line_id: ' || p_po_line_id ||
      ', p_item_id: ' || p_item_id ||
      ', p_category_id: ' || p_category_id ||
      ', p_item_description: ' || p_item_description ||
      ', p_unit_price: ' || p_unit_price ||
      ', p_unit_meas_lookup_code: ' || p_unit_meas_lookup_code ||
      ', p_suggested_vendor_id: ' || p_suggested_vendor_id ||
      ', p_suggested_vendor_site_id: ' || p_suggested_vendor_site_id ||
      ', p_vendor_product_code: ' || p_vendor_product_code || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'INSERT INTO ipo_reqexpress_lines_all( ' ||
    'org_id, ' ||
    'express_name, ' ||
    'sequence_num, ' ||
    'source_type_code, ' ||
    'po_header_id, ' ||
    'po_line_id, ' ||
    'item_id, ' ||
    'category_id, ' ||
    'item_description, ' ||
    'unit_price, ' ||
    'unit_meas_lookup_code, ' ||
    'suggested_vendor_id, ' ||
    'suggested_vendor_site_id, ' ||
    'suggested_vendor_product_code, ' ||
    'creation_date, ' ||
    'last_update_date) '||
    'VALUES( ' ||
    ':org_id, ' ||
    ':express_name, ' ||
    ':sequence_num, ' ||
    ':source_type_code, ' ||
    ':po_header_id, ' ||
    ':po_line_id, ' ||
    ':item_id, ' ||
    ':category_id, ' ||
    ':item_description, ' ||
    ':unit_price, ' ||
    ':unit_meas_lookup_code, ' ||
    ':suggested_vendor_id, ' ||
    ':suggested_vendor_site_id, ' ||
    ':suggested_vendor_product_code, ' ||
    'SYSDATE, ' ||
    'SYSDATE) '
    USING p_org_id, p_express_name,
	  p_sequence_num, p_source_type_code,
	  p_po_header_id, p_po_line_id,
	  p_item_id, p_category_id,
	  p_item_description, p_unit_price,
	  p_unit_meas_lookup_code,
	  p_suggested_vendor_id,
	  p_suggested_vendor_site_id,
	  p_vendor_product_code;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.createTemplateLine-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END createTemplateLine;

-- FPJ Bug# 3007068 sosingha: Extractor Changes For Kit Support Project
-- Overloaded createTemplateLine Procedure to create a template line accepting Suggested Quantity

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
                             p_suggested_quantity       IN NUMBER,
                             p_unit_meas_lookup_code    IN VARCHAR2,
                             p_suggested_vendor_id      IN NUMBER,
                             p_suggested_vendor_site_id IN NUMBER,
                             p_vendor_product_code      IN VARCHAR2)
IS
  xErrLoc       PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'createTemplateLine(p_org_id: ' || p_org_id ||
      ', p_express_name: ' || p_express_name ||
      ', p_sequence_num: ' || p_sequence_num ||
      ', p_source_type_code: ' || p_source_type_code ||
      ', p_po_header_id: ' || p_po_header_id ||
      ', p_po_line_id: ' || p_po_line_id ||
      ', p_item_id: ' || p_item_id ||
      ', p_category_id: ' || p_category_id ||
      ', p_item_description: ' || p_item_description ||
      ', p_unit_price: ' || p_unit_price ||
      ', p_suggested_quantity:' || p_suggested_quantity ||
      ', p_unit_meas_lookup_code: ' || p_unit_meas_lookup_code ||
      ', p_suggested_vendor_id: ' || p_suggested_vendor_id ||
      ', p_suggested_vendor_site_id: ' || p_suggested_vendor_site_id ||
      ', p_vendor_product_code: ' || p_vendor_product_code || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'INSERT INTO ipo_reqexpress_lines_all( ' ||
    'org_id, ' ||
    'express_name, ' ||
    'sequence_num, ' ||
    'source_type_code, ' ||
    'po_header_id, ' ||
    'po_line_id, ' ||
    'item_id, ' ||
    'category_id, ' ||
    'item_description, ' ||
    'unit_price, ' ||
    'suggested_quantity, ' ||
    'unit_meas_lookup_code, ' ||
    'suggested_vendor_id, ' ||
    'suggested_vendor_site_id, ' ||
    'suggested_vendor_product_code, ' ||
    'creation_date, ' ||
    'last_update_date) '||
    'VALUES( ' ||
   ':org_id, ' ||
    ':express_name, ' ||
    ':sequence_num, ' ||
    ':source_type_code, ' ||
    ':po_header_id, ' ||
    ':po_line_id, ' ||
    ':item_id, ' ||
    ':category_id, ' ||
    ':item_description, ' ||
    ':unit_price, ' ||
    ':suggested_quantity, ' ||
    ':unit_meas_lookup_code, ' ||
    ':suggested_vendor_id, ' ||
    ':suggested_vendor_site_id, ' ||
    ':suggested_vendor_product_code, ' ||
    'SYSDATE, ' ||
    'SYSDATE) '
    USING p_org_id, p_express_name,
          p_sequence_num, p_source_type_code,
          p_po_header_id, p_po_line_id,
          p_item_id, p_category_id,
          p_item_description, p_unit_price,
          p_suggested_quantity,
          p_unit_meas_lookup_code,
          p_suggested_vendor_id,
          p_suggested_vendor_site_id,
          p_vendor_product_code;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.createTemplateLine-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END createTemplateLine;

-- Update a template line
PROCEDURE updateTemplateLine(p_org_id			IN NUMBER,
			     p_express_name		IN VARCHAR2,
			     p_sequence_num		IN NUMBER,
			     p_po_header_id		IN NUMBER,
			     p_po_line_id		IN NUMBER,
			     p_item_description		IN VARCHAR2,
			     p_unit_price		IN NUMBER,
                             -- FPJ Bug# 3007068 sosingha: Extractor Changes for Kit Support project.
                             p_suggested_quantity       IN NUMBER,
			     p_unit_meas_lookup_code	IN VARCHAR2,
			     p_suggested_vendor_site_id	IN NUMBER,
			     p_vendor_product_code 	IN VARCHAR2)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'updateTemplateLine(p_org_id: ' || p_org_id ||
      ', p_express_name: ' || p_express_name ||
      ', p_sequence_num: ' || p_sequence_num ||
      ', p_po_header_id: ' || p_po_header_id ||
      ', p_po_line_id: ' || p_po_line_id ||
      ', p_item_description: ' || p_item_description ||
      ', p_unit_price: ' || p_unit_price ||
      -- FPJ Bug# 3007068 sosingha: Extractor Changes For Kit Support Project
      ', p_suggested_quantity: ' || p_suggested_quantity ||
      ', p_unit_meas_lookup_code: ' || p_unit_meas_lookup_code ||
      ', p_suggested_vendor_site_id: ' || p_suggested_vendor_site_id ||
      ', p_vendor_product_code: ' || p_vendor_product_code || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'UPDATE ipo_reqexpress_lines_all SET ' ||
    'po_header_id = DECODE(:po_header_id, '||
    ':miss_num, po_header_id,:po_header_id), '||
    'po_line_id = DECODE(:po_line_id, '||
    ':miss_num, po_line_id,:po_line_id), '||
    'item_description = DECODE(:item_description, '||
    ':miss_char, item_description,:item_description), '||
    'unit_price = DECODE(:unit_price, '||
    ':miss_num, unit_price,:unit_price), '||
    -- FPJ Bug# 3007068 sosingha: Extractor Changes For Kit Support Project
    'suggested_quantity = DECODE(:suggested_quantity, '||
    ':miss_num, suggested_quantity,:suggested_quantity), '||
    'unit_meas_lookup_code = DECODE(:unit_meas_lookup_code, '||
    ':miss_char, unit_meas_lookup_code,:unit_meas_lookup_code), '||
    'suggested_vendor_site_id = DECODE(:suggested_vendor_site_id, '||
    ':miss_num, suggested_vendor_site_id,:suggested_vendor_site_id), '||
    'suggested_vendor_product_code = DECODE(:suggested_vendor_product_code, '||
    ':miss_char, suggested_vendor_product_code,:suggested_vendor_product_code), '||
    'last_update_date = SYSDATE ' ||
    'WHERE org_id =:org_id ' ||
    'AND express_name =:express_name ' ||
    'AND sequence_num =:sequence_num '
    USING p_po_header_id, FND_API.G_MISS_NUM, p_po_header_id,
          p_po_line_id, FND_API.G_MISS_NUM, p_po_line_id,
          p_item_description, FND_API.G_MISS_CHAR, p_item_description,
          p_unit_price, FND_API.G_MISS_NUM, p_unit_price,
          -- FPJ Bug# 3007068 sosingha: Extractor Changes for Kit Support project
          p_suggested_quantity, FND_API.G_MISS_NUM, p_suggested_quantity,
          p_unit_meas_lookup_code, FND_API.G_MISS_CHAR, p_unit_meas_lookup_code,
          p_suggested_vendor_site_id, FND_API.G_MISS_NUM, p_suggested_vendor_site_id,
          p_vendor_product_code, FND_API.G_MISS_CHAR, p_vendor_product_code,
          p_org_id, p_express_name, p_sequence_num;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.updateTemplateLine-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END updateTemplateLine;

-- Create a contract header
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
			       p_global_agreement_flag	IN VARCHAR2)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'createContractHeader(p_po_header_id: ' || p_po_header_id ||
      ', p_org_id: ' || p_org_id ||
      ', p_segment1: ' || p_segment1 ||
      ', p_type_lookup_code: ' || p_type_lookup_code ||
      ', p_rate: ' || p_rate ||
      ', p_currency_code: ' || p_currency_code ||
      ', p_vendor_id: ' || p_vendor_id ||
      ', p_vendor_site_id: ' || p_vendor_site_id ||
      ', p_approved_date: ' || p_approved_date ||
      ', p_approved_flag: ' || p_approved_flag ||
      ', p_approval_required_flag: ' || p_approval_required_flag ||
      ', p_cancel_flag: ' || p_cancel_flag ||
      ', p_frozen_flag: ' || p_frozen_flag ||
      ', p_closed_code: ' || p_closed_code ||
      ', p_status_lookup_code: ' || p_status_lookup_code ||
      ', p_quotation_class_code: ' || p_quotation_class_code ||
      ', p_start_date: ' || p_start_date ||
      ', p_end_date: ' || p_end_date ||
      ', p_global_agreement_flag: ' || p_global_agreement_flag || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'INSERT INTO ipo_headers_all( ' ||
    'po_header_id, ' ||
    'org_id, ' ||
    'segment1, ' ||
    'type_lookup_code, ' ||
    'rate, ' ||
    'currency_code, ' ||
    'vendor_id, ' ||
    'vendor_site_id, ' ||
    'approved_date, ' ||
    'approved_flag, ' ||
    'approval_required_flag, ' ||
    'cancel_flag, ' ||
    'frozen_flag, ' ||
    'closed_code, ' ||
    'status_lookup_code, ' ||
    'quotation_class_code, ' ||
    'start_date, ' ||
    'end_date, ' ||
    'global_agreement_flag, ' ||
    'last_update_date) ' ||
    'VALUES( ' ||
    ':po_header_id, ' ||
    ':org_id, ' ||
    ':segment1, ' ||
    ':type_lookup_code, ' ||
    ':rate, ' ||
    ':currency_code, ' ||
    ':vendor_id, ' ||
    ':vendor_site_id, ' ||
    ':approved_date, ' ||
    ':approved_flag, ' ||
    ':approval_required_flag, ' ||
    ':cancel_flag, ' ||
    ':frozen_flag, ' ||
    ':closed_code, ' ||
    ':status_lookup_code, ' ||
    ':quotation_class_code, ' ||
    ':start_date, ' ||
    ':end_date, ' ||
    ':global_agreement_flag, ' ||
    'SYSDATE) '
    USING p_po_header_id, p_org_id, p_segment1,
          p_type_lookup_code, p_rate, p_currency_code,
          p_vendor_id, p_vendor_site_id,
          p_approved_date, p_approved_flag,
          p_approval_required_flag, p_cancel_flag,
          p_frozen_flag, p_closed_code,
          p_status_lookup_code, p_quotation_class_code,
          p_start_date, p_end_date,
          p_global_agreement_flag;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.createContractHeader-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END createContractHeader;

-- Create a contract line
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
			     p_outside_operation_flag	IN VARCHAR2)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'createContractLine(p_po_header_id: ' || p_po_header_id ||
      ', p_po_line_id: ' || p_po_line_id ||
      ', p_org_id: ' || p_org_id ||
      ', p_line_num: ' || p_line_num ||
      ', p_item_id: ' || p_item_id ||
      ', p_item_description: ' || p_item_description ||
      ', p_vendor_product_num: ' || p_vendor_product_num ||
      ', p_line_type_id: ' || p_line_type_id ||
      ', p_category_id: ' || p_category_id ||
      ', p_unit_price: ' || p_unit_price ||
      ', p_unit_meas_lookup_code: ' || p_unit_meas_lookup_code ||
      ', p_attribute13: ' || p_attribute13 ||
      ', p_attribute14: ' || p_attribute14 ||
      ', p_cancel_flag: ' || p_cancel_flag ||
      ', p_closed_code: ' || p_closed_code ||
      ', p_expiration_date: ' || p_expiration_date ||
      ', p_outside_operation_flag: ' || p_outside_operation_flag || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'INSERT INTO ipo_lines_all( ' ||
    'po_header_id, ' ||
    'po_line_id, ' ||
    'org_id, ' ||
    'line_num, ' ||
    'item_id, ' ||
    'item_description, ' ||
    'vendor_product_num, ' ||
    'line_type_id, ' ||
    'category_id, ' ||
    'unit_price, ' ||
    'unit_meas_lookup_code, ' ||
    'attribute13, ' ||
    'attribute14, ' ||
    'cancel_flag, ' ||
    'closed_code, ' ||
    'expiration_date, ' ||
    'creation_date, ' ||
    'last_update_date) ' ||
    'VALUES( ' ||
    ':po_header_id, ' ||
    ':po_line_id, ' ||
    ':org_id, ' ||
    ':line_num, ' ||
    ':item_id, ' ||
    ':item_description, ' ||
    ':vendor_product_num, ' ||
    ':line_type_id, ' ||
    ':category_id, ' ||
    ':unit_price, ' ||
    ':unit_meas_lookup_code, ' ||
    ':attribute13, ' ||
    ':attribute14, ' ||
    ':cancel_flag, ' ||
    ':closed_code, ' ||
    ':expiration_date, ' ||
    'SYSDATE, ' ||
    'SYSDATE) '
    USING p_po_header_id, p_po_line_id, p_org_id,
          p_line_num, p_item_id, p_item_description,
          p_vendor_product_num, p_line_type_id,
          p_category_id, p_unit_price,
          p_unit_meas_lookup_code, p_attribute13,
          p_attribute14, p_cancel_flag,
          p_closed_code, p_expiration_date;

  xErrLoc:= 200;
  EXECUTE IMMEDIATE
    'INSERT INTO ipo_line_types_b( ' ||
    'line_type_id, ' ||
    'outside_operation_flag, ' ||
    'last_update_date) ' ||
    'VALUES( ' ||
    ':line_type_id, ' ||
    ':outside_operation_flag, ' ||
    'SYSDATE) '
    USING p_line_type_id, p_outside_operation_flag;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.createContractLine-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END createContractLine;

-- FPJ FPSL Extractor Changes
-- Add 5 parameters for Amount, Allow Price Override Flag,
-- Not to Exceed Price, Value Basis, Purchase Basis
-- Create a contract line
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
			     p_outside_operation_flag	IN VARCHAR2,
                             p_amount                   IN NUMBER,
                             p_allow_price_override_flag IN VARCHAR2,
                             p_not_to_exceed_price      IN NUMBER,
                             p_value_basis              IN VARCHAR2,
                             p_purchase_basis           IN VARCHAR2)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'createContractLine(p_po_header_id: ' || p_po_header_id ||
      ', p_po_line_id: ' || p_po_line_id ||
      ', p_org_id: ' || p_org_id ||
      ', p_line_num: ' || p_line_num ||
      ', p_item_id: ' || p_item_id ||
      ', p_item_description: ' || p_item_description ||
      ', p_vendor_product_num: ' || p_vendor_product_num ||
      ', p_line_type_id: ' || p_line_type_id ||
      ', p_category_id: ' || p_category_id ||
      ', p_unit_price: ' || p_unit_price ||
      ', p_unit_meas_lookup_code: ' || p_unit_meas_lookup_code ||
      ', p_attribute13: ' || p_attribute13 ||
      ', p_attribute14: ' || p_attribute14 ||
      ', p_cancel_flag: ' || p_cancel_flag ||
      ', p_closed_code: ' || p_closed_code ||
      ', p_expiration_date: ' || p_expiration_date ||
      ', p_outside_operation_flag: ' || p_outside_operation_flag ||
      ', p_amount: ' || p_amount ||
      ', p_allow_price_override_flag: ' || p_allow_price_override_flag ||
      ', p_not_to_exceed_price: ' || p_not_to_exceed_price ||
      ', p_value_basis: ' || p_value_basis ||
      ', p_purchase_basis: ' || p_purchase_basis || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'INSERT INTO ipo_lines_all( ' ||
    'po_header_id, ' ||
    'po_line_id, ' ||
    'org_id, ' ||
    'line_num, ' ||
    'item_id, ' ||
    'item_description, ' ||
    'vendor_product_num, ' ||
    'line_type_id, ' ||
    'category_id, ' ||
    'unit_price, ' ||
    'unit_meas_lookup_code, ' ||
    'attribute13, ' ||
    'attribute14, ' ||
    'cancel_flag, ' ||
    'closed_code, ' ||
    'expiration_date, ' ||
    'creation_date, ' ||
    'last_update_date, ' ||
    'amount, ' ||
    'allow_price_override_flag, ' ||
    'not_to_exceed_price) ' ||
    'VALUES( ' ||
    ':po_header_id, ' ||
    ':po_line_id, ' ||
    ':org_id, ' ||
    ':line_num, ' ||
    ':item_id, ' ||
    ':item_description, ' ||
    ':vendor_product_num, ' ||
    ':line_type_id, ' ||
    ':category_id, ' ||
    ':unit_price, ' ||
    ':unit_meas_lookup_code, ' ||
    ':attribute13, ' ||
    ':attribute14, ' ||
    ':cancel_flag, ' ||
    ':closed_code, ' ||
    ':expiration_date, ' ||
    'SYSDATE, ' ||
    'SYSDATE, ' ||
    ':amount, ' ||
    ':allow_price_override_flag, ' ||
    ':not_to_exceed_price) '
    USING p_po_header_id, p_po_line_id, p_org_id,
          p_line_num, p_item_id, p_item_description,
          p_vendor_product_num, p_line_type_id,
          p_category_id, p_unit_price,
          p_unit_meas_lookup_code, p_attribute13,
          p_attribute14, p_cancel_flag,
          p_closed_code, p_expiration_date,
          p_amount, p_allow_price_override_flag, p_not_to_exceed_price;

  xErrLoc:= 200;
  EXECUTE IMMEDIATE
    'INSERT INTO ipo_line_types_b( ' ||
    'line_type_id, ' ||
    'outside_operation_flag, ' ||
    'last_update_date, ' ||
    'order_type_lookup_code, ' ||
    'purchase_basis) ' ||
    'VALUES( ' ||
    ':line_type_id, ' ||
    ':outside_operation_flag, ' ||
    'SYSDATE, ' ||
    ':order_type_lookup_code, ' ||
    ':purchase_basis ) '
    USING p_line_type_id, p_outside_operation_flag,
          p_value_basis, p_purchase_basis;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.createContractLine-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END createContractLine;

-- Update a contract header
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
			       p_global_agreement_flag	IN VARCHAR2)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'updateContractHeader(p_po_header_id: ' || p_po_header_id ||
      ', p_rate: ' || p_rate ||
      ', p_currency_code: ' || p_currency_code ||
      ', p_vendor_site_id: ' || p_vendor_site_id ||
      ', p_approved_date: ' || p_approved_date ||
      ', p_approved_flag: ' || p_approved_flag ||
      ', p_approval_required_flag: ' || p_approval_required_flag ||
      ', p_cancel_flag: ' || p_cancel_flag ||
      ', p_frozen_flag: ' || p_frozen_flag ||
      ', p_closed_code: ' || p_closed_code ||
      ', p_start_date: ' || p_start_date ||
      ', p_end_date: ' || p_end_date ||
      ', p_global_agreement_flag: ' || p_global_agreement_flag || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'UPDATE ipo_headers_all SET ' ||
    'rate = DECODE(:rate, '||
    ':miss_num, rate,:rate), '||
    'currency_code = DECODE(:currency_code, '||
    ':miss_char, currency_code,:currency_code), '||
    'vendor_site_id = DECODE(:vendor_site_id, '||
    ':miss_num, vendor_site_id,:vendor_site_id), '||
    'approved_date = DECODE(:approved_date, '||
    ':miss_date, approved_date,:approved_date), '||
    'approved_flag = DECODE(:approved_flag, '||
    ':miss_char, approved_flag,:approved_flag), '||
    'approval_required_flag = DECODE(:approval_required_flag, '||
    ':miss_char, approval_required_flag,:approval_required_flag), '||
    'cancel_flag = DECODE(:cancel_flag, '||
    ':miss_char, cancel_flag,:cancel_flag), '||
    'frozen_flag = DECODE(:frozen_flag, '||
    ':miss_char, frozen_flag,:frozen_flag), '||
    'closed_code = DECODE(:closed_code, '||
    ':miss_char, closed_code,:closed_code), '||
    'start_date = DECODE(:start_date, '||
    ':miss_date, start_date,:start_date), '||
    'end_date = DECODE(:end_date, '||
    ':miss_date, end_date,:end_date), '||
    'global_agreement_flag = DECODE(:global_agreement_flag, '||
    ':miss_char, global_agreement_flag,:global_agreement_flag), '||
    'last_update_date = SYSDATE ' ||
    'WHERE po_header_id =:po_header_id '
    USING p_rate, FND_API.G_MISS_NUM, p_rate,
          p_currency_code, FND_API.G_MISS_CHAR, p_currency_code,
          p_vendor_site_id, FND_API.G_MISS_NUM, p_vendor_site_id,
          p_approved_date, FND_API.G_MISS_DATE, p_approved_date,
          p_approved_flag, FND_API.G_MISS_CHAR, p_approved_flag,
          p_approval_required_flag, FND_API.G_MISS_CHAR, p_approval_required_flag,
          p_cancel_flag, FND_API.G_MISS_CHAR, p_cancel_flag,
          p_frozen_flag, FND_API.G_MISS_CHAR, p_frozen_flag,
          p_closed_code, FND_API.G_MISS_CHAR, p_closed_code,
          p_start_date, FND_API.G_MISS_DATE, p_start_date,
          p_end_date, FND_API.G_MISS_DATE, p_end_date,
          p_global_agreement_flag, FND_API.G_MISS_CHAR, p_global_agreement_flag,
          p_po_header_id;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.updateContractHeader-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END updateContractHeader;

-- Update a contract line
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
			     p_outside_operation_flag	IN VARCHAR2)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'updateContractLine(p_po_line_id: ' || p_po_line_id ||
      ', p_item_description: ' || p_item_description ||
      ', p_vendor_product_num: ' || p_vendor_product_num ||
      ', p_line_type_id: ' || p_line_type_id ||
      ', p_unit_price: ' || p_unit_price ||
      ', p_unit_meas_lookup_code: ' || p_unit_meas_lookup_code ||
      ', p_attribute13: ' || p_attribute13 ||
      ', p_attribute14: ' || p_attribute14 ||
      ', p_cancel_flag: ' || p_cancel_flag ||
      ', p_closed_code: ' || p_closed_code ||
      ', p_creation_date: ' || p_creation_date ||
      ', p_expiration_date: ' || p_expiration_date ||
      ', p_outside_operation_flag: ' || p_outside_operation_flag || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'UPDATE ipo_lines_all SET ' ||
    'item_description = DECODE(:item_description, '||
    ':miss_char, item_description,:item_description), '||
    'vendor_product_num = DECODE(:vendor_product_num, '||
    ':miss_char, vendor_product_num,:vendor_product_num), '||
    'unit_price = DECODE(:unit_price, '||
    ':miss_num, unit_price,:unit_price), '||
    'unit_meas_lookup_code = DECODE(:unit_meas_lookup_code, '||
    ':miss_char, unit_meas_lookup_code,:unit_meas_lookup_code), '||
    'attribute13 = DECODE(:attribute13, '||
    ':miss_char, attribute13,:attribute13), '||
    'attribute14 = DECODE(:attribute14, '||
    ':miss_char, attribute14,:attribute14), '||
    'cancel_flag = DECODE(:cancel_flag, '||
    ':miss_char, cancel_flag,:cancel_flag), '||
    'closed_code = DECODE(:closed_code, '||
    ':miss_char, closed_code,:closed_code), '||
    'expiration_date = DECODE(:expiration_date, '||
    ':miss_date, expiration_date,:expiration_date), '||
    'last_update_date = SYSDATE ' ||
    'WHERE po_line_id =:po_line_id '
    USING p_item_description, FND_API.G_MISS_CHAR, p_item_description,
          p_vendor_product_num, FND_API.G_MISS_CHAR, p_vendor_product_num,
          p_unit_price, FND_API.G_MISS_NUM, p_unit_price,
          p_unit_meas_lookup_code, FND_API.G_MISS_CHAR, p_unit_meas_lookup_code,
          p_attribute13, FND_API.G_MISS_CHAR, p_attribute13,
          p_attribute14, FND_API.G_MISS_CHAR, p_attribute14,
          p_cancel_flag, FND_API.G_MISS_CHAR, p_cancel_flag,
          p_closed_code, FND_API.G_MISS_CHAR, p_closed_code,
          p_expiration_date, FND_API.G_MISS_DATE, p_expiration_date,
          p_po_line_id;

  xErrLoc:= 200;
  EXECUTE IMMEDIATE
    'UPDATE ipo_line_types_b SET ' ||
    'outside_operation_flag = DECODE(:outside_operation_flag, '||
    ':miss_char, outside_operation_flag,:outside_operation_flag), '||
    'last_update_date = SYSDATE ' ||
    'WHERE line_type_id =:line_type_id '
    USING p_outside_operation_flag, FND_API.G_MISS_CHAR, p_outside_operation_flag,
          p_line_type_id;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.updateContractLine-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END updateContractLine;

-- Update a contract line
-- FPJ FPSL Extractor Changes
-- Add 3 parameters for Amount, Allow Price Override Flag and Not to Exceed Price
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
			     p_outside_operation_flag	IN VARCHAR2,
			     p_amount    		IN NUMBER,
			     p_allow_price_override_flag	IN VARCHAR2,
			     p_not_to_exceed_price	IN NUMBER)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'updateContractLine(p_po_line_id: ' || p_po_line_id ||
      ', p_item_description: ' || p_item_description ||
      ', p_vendor_product_num: ' || p_vendor_product_num ||
      ', p_line_type_id: ' || p_line_type_id ||
      ', p_unit_price: ' || p_unit_price ||
      ', p_unit_meas_lookup_code: ' || p_unit_meas_lookup_code ||
      ', p_attribute13: ' || p_attribute13 ||
      ', p_attribute14: ' || p_attribute14 ||
      ', p_cancel_flag: ' || p_cancel_flag ||
      ', p_closed_code: ' || p_closed_code ||
      ', p_creation_date: ' || p_creation_date ||
      ', p_expiration_date: ' || p_expiration_date ||
      ', p_outside_operation_flag: ' || p_outside_operation_flag ||
      ', p_amount: ' || p_amount ||
      ', p_allow_price_override_flag: ' || p_allow_price_override_flag ||
      ', p_not_to_exceed_price: ' || p_not_to_exceed_price || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'UPDATE ipo_lines_all SET ' ||
    'item_description = DECODE(:item_description, '||
    ':miss_char, item_description,:item_description), '||
    'vendor_product_num = DECODE(:vendor_product_num, '||
    ':miss_char, vendor_product_num,:vendor_product_num), '||
    'unit_price = DECODE(:unit_price, '||
    ':miss_num, unit_price,:unit_price), '||
    'unit_meas_lookup_code = DECODE(:unit_meas_lookup_code, '||
    ':miss_char, unit_meas_lookup_code,:unit_meas_lookup_code), '||
    'attribute13 = DECODE(:attribute13, '||
    ':miss_char, attribute13,:attribute13), '||
    'attribute14 = DECODE(:attribute14, '||
    ':miss_char, attribute14,:attribute14), '||
    'cancel_flag = DECODE(:cancel_flag, '||
    ':miss_char, cancel_flag,:cancel_flag), '||
    'closed_code = DECODE(:closed_code, '||
    ':miss_char, closed_code,:closed_code), '||
    'expiration_date = DECODE(:expiration_date, '||
    ':miss_date, expiration_date,:expiration_date), '||
    'amount = DECODE(:amount, '||
    ':miss_num, amount,:amount), '||
    'allow_price_override_flag = DECODE(:allow_price_override_flag, '||
    ':miss_char, allow_price_override_flag,:allow_price_override_flag), '||
    'not_to_exceed_price = DECODE(:not_to_exceed_price, '||
    ':miss_num, not_to_exceed_price,:not_to_exceed_price), '||
    'last_update_date = SYSDATE ' ||
    'WHERE po_line_id =:po_line_id '
    USING p_item_description, FND_API.G_MISS_CHAR, p_item_description,
          p_vendor_product_num, FND_API.G_MISS_CHAR, p_vendor_product_num,
          p_unit_price, FND_API.G_MISS_NUM, p_unit_price,
          p_unit_meas_lookup_code, FND_API.G_MISS_CHAR, p_unit_meas_lookup_code,
          p_attribute13, FND_API.G_MISS_CHAR, p_attribute13,
          p_attribute14, FND_API.G_MISS_CHAR, p_attribute14,
          p_cancel_flag, FND_API.G_MISS_CHAR, p_cancel_flag,
          p_closed_code, FND_API.G_MISS_CHAR, p_closed_code,
          p_expiration_date, FND_API.G_MISS_DATE, p_expiration_date,
          p_amount, FND_API.G_MISS_NUM, p_amount,
          p_allow_price_override_flag, FND_API.G_MISS_CHAR, p_allow_price_override_flag,
          p_not_to_exceed_price, FND_API.G_MISS_NUM, p_not_to_exceed_price,
          p_po_line_id;

  xErrLoc:= 200;
  EXECUTE IMMEDIATE
    'UPDATE ipo_line_types_b SET ' ||
    'outside_operation_flag = DECODE(:outside_operation_flag, '||
    ':miss_char, outside_operation_flag,:outside_operation_flag), '||
    'last_update_date = SYSDATE ' ||
    'WHERE line_type_id =:line_type_id '
    USING p_outside_operation_flag, FND_API.G_MISS_CHAR, p_outside_operation_flag,
          p_line_type_id;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.updateContractLine-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END updateContractLine;

-- Create a quotation line location
PROCEDURE createQuoteLL(p_line_location_id	IN NUMBER,
		        p_po_line_id		IN NUMBER,
			p_start_date		IN DATE,
			p_end_date		IN DATE,
			p_approval_type		IN VARCHAR2,
			p_start_date_active	IN DATE,
			p_end_date_active	IN DATE)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'createQuoteLL(p_line_location_id: ' || p_line_location_id ||
      ', p_po_line_id: ' || p_po_line_id ||
      ', p_start_date: ' || p_start_date ||
      ', p_end_date: ' || p_end_date ||
      ', p_approval_type: ' || p_approval_type ||
      ', p_start_date_active: ' || p_start_date_active ||
      ', p_end_date_active: ' || p_end_date_active || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'INSERT INTO ipo_line_locations_all( ' ||
    'line_location_id, ' ||
    'po_line_id, ' ||
    'start_date, ' ||
    'end_date, ' ||
    'last_update_date) ' ||
    'VALUES( ' ||
    ':line_location_id, ' ||
    ':po_line_id, ' ||
    ':start_date, ' ||
    ':end_date, ' ||
    'SYSDATE) '
    USING p_line_location_id, p_po_line_id,
          p_start_date, p_end_date;

  xErrLoc:= 200;
  EXECUTE IMMEDIATE
    'INSERT INTO ipo_quotation_approvals_all( ' ||
    'line_location_id, ' ||
    'approval_type, ' ||
    'start_date_active, ' ||
    'end_date_active, ' ||
    'last_update_date) ' ||
    'VALUES( ' ||
    ':line_location_id, ' ||
    ':approval_type, ' ||
    ':start_date_active, ' ||
    ':end_date_active, ' ||
    'SYSDATE) '
    USING p_line_location_id, p_approval_type,
          p_start_date_active, p_end_date_active;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.createQuoteLL-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END createQuoteLL;

-- Update a quotation line location
PROCEDURE updateQuoteLL(p_line_location_id	IN NUMBER,
			p_start_date		IN DATE,
			p_end_date		IN DATE,
			p_approval_type		IN VARCHAR2,
			p_start_date_active	IN DATE,
			p_end_date_active	IN DATE)
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'updateQuoteLL(p_line_location_id: ' || p_line_location_id ||
      ', p_start_date: ' || p_start_date ||
      ', p_end_date: ' || p_end_date ||
      ', p_approval_type: ' || p_approval_type ||
      ', p_start_date_active: ' || p_start_date_active ||
      ', p_end_date_active: ' || p_end_date_active || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'UPDATE ipo_line_locations_all SET ' ||
    'start_date = DECODE(:start_date, '||
    ':miss_date, start_date,:start_date), '||
    'end_date = DECODE(:end_date, '||
    ':miss_date, end_date,:end_date), '||
    'last_update_date = SYSDATE ' ||
    'WHERE line_location_id =:line_location_id '
    USING p_start_date, FND_API.G_MISS_DATE, p_start_date,
          p_end_date, FND_API.G_MISS_DATE, p_end_date,
          p_line_location_id;

  xErrLoc:= 200;
  EXECUTE IMMEDIATE
    'UPDATE ipo_quotation_approvals_all SET ' ||
    'approval_type = DECODE(:approval_type, '||
    ':miss_char, approval_type,:approval_type), '||
    'approval_type, ' ||
    'start_date_active = DECODE(:start_date_active, '||
    ':miss_date, start_date_active,:start_date_active), '||
    'end_date_active = DECODE(:end_date_active, '||
    ':miss_date, end_date_active,:end_date_active), '||
    'last_update_date = SYSDATE ' ||
    'WHERE line_location_id =:line_location_id '
    USING p_approval_type, FND_API.G_MISS_CHAR, p_approval_type,
          p_start_date_active, FND_API.G_MISS_DATE, p_start_date_active,
          p_end_date_active, FND_API.G_MISS_DATE, p_end_date_active,
          p_line_location_id;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.updateQuoteLL-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END updateQuoteLL;

-- Create a global agreement assignment
PROCEDURE createGlobalA(p_po_header_id		IN NUMBER,
		        p_organization_id	IN NUMBER,
			p_enabled_flag		IN VARCHAR2,
			p_vendor_site_id	IN NUMBER,
                        p_purchasing_org_id     IN NUMBER)  -- Centralized Proc Impacts
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'createGlobalA(p_po_header_id: ' || p_po_header_id ||
      ', p_organization_id: ' || p_organization_id ||
      ', p_enabled_flag: ' || p_enabled_flag ||
      ', p_vendor_site_id: ' || p_vendor_site_id ||
      ', p_purchasing_org_id: ' || p_purchasing_org_id || ')'); -- Centralized Proc Impacts
  END IF;

  xErrLoc:= 100;
  -- Centralized Proc Impacts : Insert the value for purchasing_org_id also
  EXECUTE IMMEDIATE
    'INSERT INTO ipo_ga_org_assignments( ' ||
    'po_header_id, ' ||
    'organization_id, ' ||
    'enabled_flag, ' ||
    'vendor_site_id, ' ||
    'purchasing_org_id, ' ||
    'last_update_date) ' ||
    'VALUES( ' ||
    ':po_header_id, ' ||
    ':organization_id, ' ||
    ':enabled_flag, ' ||
    ':vendor_site_id, ' ||
    ':purchasing_org_id, ' ||
    'SYSDATE) '
    USING p_po_header_id, p_organization_id,
          p_enabled_flag, p_vendor_site_id, p_purchasing_org_id;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.createGlobalA-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END createGlobalA;

-- Update a global agreement assignment
PROCEDURE updateGlobalA(p_po_header_id		IN NUMBER,
		        p_organization_id	IN NUMBER,
			p_enabled_flag		IN VARCHAR2,
			p_vendor_site_id	IN NUMBER,
                        p_purchasing_org_id     IN NUMBER)  -- Centralized Proc Impacts
IS
  xErrLoc	PLS_INTEGER:= 100;

BEGIN
  xErrLoc:= 50;
  IF ICX_POR_EXT_UTL.gDebugLevel >= ICX_POR_EXT_UTL.DEBUG_LEVEL THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.DEBUG_LEVEL,
      'updateGlobalA(p_po_header_id: ' || p_po_header_id ||
      ', p_organization_id: ' || p_organization_id ||
      ', p_enabled_flag: ' || p_enabled_flag ||
      ', p_vendor_site_id: ' || p_vendor_site_id ||
      ', p_purchasing_org_id: ' || p_purchasing_org_id || ')');
  END IF;

  xErrLoc:= 100;
  EXECUTE IMMEDIATE
    'UPDATE ipo_ga_org_assignments SET ' ||
    'enabled_flag = DECODE(:enabled_flag, '||
    ':miss_char, enabled_flag,:enabled_flag), '||
    'vendor_site_id = DECODE(:vendor_site_id, '||
    ':miss_num, vendor_site_id,:vendor_site_id), '||
    'purchasing_org_id = DECODE(:purchasing_org_id, '|| -- Centralized Proc Impacts
    ':miss_num, purchasing_org_id,:purchasing_org_id), '||
    'last_update_date = SYSDATE ' ||
    'WHERE po_header_id =:po_header_id ' ||
    'AND organization_id =:organization_id '
    USING p_enabled_flag, FND_API.G_MISS_CHAR, p_enabled_flag,
          p_vendor_site_id, FND_API.G_MISS_NUM, p_vendor_site_id,
          p_purchasing_org_id, FND_API.G_MISS_NUM, p_purchasing_org_id,
          p_po_header_id, p_organization_id;

  xErrLoc:= 400;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.updateGlobalA-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END updateGlobalA;

--------------------------------------------------------------
--                Item Test Result Checking                 --
--------------------------------------------------------------
FUNCTION existItemsB(p_rt_item_id		OUT NOCOPY NUMBER,
		     p_org_id			IN NUMBER,
		     p_supplier_id		IN NUMBER,
		     p_supplier			IN VARCHAR2,
		     p_supplier_part_num	IN VARCHAR2,
		     p_internal_item_id		IN NUMBER,
		     p_internal_item_num	IN VARCHAR2,
		     p_extractor_updated_flag	IN VARCHAR2,
		     p_internal_flag		IN VARCHAR2)
  RETURN BOOLEAN
IS
  xErrLoc	PLS_INTEGER;
  xSearchType 	VARCHAR2(20);
  xResult	PLS_INTEGER;
BEGIN
  xErrLoc:= 100;
  IF NVL(p_internal_flag, 'N') = 'N' THEN
    xSearchType := 'SUPPLIER';
  ELSE
    xSearchType := 'INTERNAL';
  END IF;

  SELECT rt_item_id
  INTO   p_rt_item_id
  FROM   icx_cat_items_b i
  WHERE  (org_id IS NULL AND p_org_id IS NULL OR
          org_id = p_org_id)
  AND    (supplier_id = ICX_POR_EXT_ITEM.NULL_NUMBER AND
          NVL(p_supplier_id, ICX_POR_EXT_ITEM.NULL_NUMBER) =
            ICX_POR_EXT_ITEM.NULL_NUMBER OR
          supplier_id = p_supplier_id)
  AND    (supplier IS NULL AND p_supplier IS NULL OR
          supplier = p_supplier)
  AND    (supplier_part_num IS NULL AND p_supplier_part_num IS NULL OR
          supplier_part_num = p_supplier_part_num)
  AND    (internal_item_id IS NULL AND p_internal_item_id IS NULL OR
          internal_item_id = p_internal_item_id)
  AND    (internal_item_num IS NULL AND p_internal_item_num IS NULL OR
          internal_item_num = p_internal_item_num)
  AND    extractor_updated_flag = p_extractor_updated_flag
  AND    EXISTS (SELECT NULL
                 FROM   icx_cat_item_prices p
                 WHERE  p.rt_item_id = i.rt_item_id
                 AND    p.search_type = xSearchType);

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
    'ItemsB[ORG_ID: ' || p_org_id ||
    ', SUPPLIER_ID: ' || p_supplier_id ||
    ', SUPPLIER: ' || p_supplier ||
    ', SUPPLIER_PART_NUM: ' || p_supplier_part_num ||
    ', INTERNAL_ITEM_ID: ' || p_internal_item_id ||
    ', INTERNAL_ITEM_NUM: ' || p_internal_item_num ||
    ', EXTRACTOR_UPDATED_FLAG: ' || p_extractor_updated_flag ||
    ', INTERNAL_FLAG: ' || p_internal_flag ||
    '] exists in ICX_CAT_ITEMS_B with RT_ITEM_ID: ' || p_rt_item_id);

  xErrLoc:= 200;
  RETURN TRUE;
EXCEPTION
  when NO_DATA_FOUND then
    xResult:= 0;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
      'ItemsB[ORG_ID: ' || p_org_id ||
      ', SUPPLIER_ID: ' || p_supplier_id ||
      ', SUPPLIER: ' || p_supplier ||
      ', SUPPLIER_PART_NUM: ' || p_supplier_part_num ||
      ', INTERNAL_ITEM_ID: ' || p_internal_item_id ||
      ', INTERNAL_ITEM_NUM: ' || p_internal_item_num ||
      ', EXTRACTOR_UPDATED_FLAG: ' || p_extractor_updated_flag ||
      ', INTERNAL_FLAG: ' || p_internal_flag ||
      '] does not exist in ICX_CAT_ITEMS_B');
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
      'ItemsB[ORG_ID: ' || p_org_id ||
      ', SUPPLIER_ID: ' || p_supplier_id ||
      ', SUPPLIER: ' || p_supplier ||
      ', SUPPLIER_PART_NUM: ' || p_supplier_part_num ||
      ', INTERNAL_ITEM_ID: ' || p_internal_item_id ||
      ', INTERNAL_ITEM_NUM: ' || p_internal_item_num ||
      ', EXTRACTOR_UPDATED_FLAG: ' || p_extractor_updated_flag ||
      ', INTERNAL_FLAG: ' || p_internal_flag ||
      '] does not exist in ICX_CAT_ITEMS_B');
    RETURN FALSE;
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.existItemsB-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END existItemsB;

FUNCTION notExistItemsB(p_org_id		IN NUMBER,
		        p_supplier_id		IN NUMBER,
		        p_supplier_part_num	IN VARCHAR2,
		        p_internal_item_id	IN NUMBER,
		        p_internal_flag		IN VARCHAR2)
  RETURN BOOLEAN
IS
  xErrLoc	PLS_INTEGER;
  xSearchType 	VARCHAR2(20);
  xResult	PLS_INTEGER;
BEGIN
  xErrLoc:= 100;
  IF NVL(p_internal_flag, 'N') = 'N' THEN
    xSearchType := 'SUPPLIER';
  ELSE
    xSearchType := 'INTERNAL';
  END IF;

  SELECT 0
  INTO   xResult
  FROM   icx_cat_items_b i
  WHERE  (org_id IS NULL AND p_org_id IS NULL OR
          org_id = p_org_id)
  AND    (supplier_id = ICX_POR_EXT_ITEM.NULL_NUMBER AND
          NVL(p_supplier_id, ICX_POR_EXT_ITEM.NULL_NUMBER) =
            ICX_POR_EXT_ITEM.NULL_NUMBER OR
          supplier_id = p_supplier_id)
  AND    (supplier_part_num IS NULL AND p_supplier_part_num IS NULL OR
          supplier_part_num = p_supplier_part_num)
  AND    (internal_item_id IS NULL AND p_internal_item_id IS NULL OR
          internal_item_id = p_internal_item_id)
  AND    EXISTS (SELECT NULL
                 FROM   icx_cat_item_prices p
                 WHERE  p.rt_item_id = i.rt_item_id
                 AND    p.search_type = xSearchType);

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
    'ItemsB[ORG_ID: ' || p_org_id ||
    ', SUPPLIER_ID: ' || p_supplier_id ||
    ', SUPPLIER_PART_NUM: ' || p_supplier_part_num ||
    ', INTERNAL_ITEM_ID: ' || p_internal_item_id ||
    ', INTERNAL_FLAG: ' || p_internal_flag ||
    '] exists in ICX_CAT_ITEMS_B');
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
    'ItemsB[ORG_ID: ' || p_org_id ||
    ', SUPPLIER_ID: ' || p_supplier_id ||
    ', SUPPLIER_PART_NUM: ' || p_supplier_part_num ||
    ', INTERNAL_ITEM_ID: ' || p_internal_item_id ||
    ', INTERNAL_FLAG: ' || p_internal_flag ||
    '] exists in ICX_CAT_ITEMS_B');

  xErrLoc:= 200;
  RETURN FALSE;
EXCEPTION
  when NO_DATA_FOUND then
    xResult:= 1;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
      'ItemsB[ORG_ID: ' || p_org_id ||
      ', SUPPLIER_ID: ' || p_supplier_id ||
      ', SUPPLIER_PART_NUM: ' || p_supplier_part_num ||
      ', INTERNAL_ITEM_ID: ' || p_internal_item_id ||
      ', INTERNAL_FLAG: ' || p_internal_flag ||
      '] does not exist in ICX_CAT_ITEMS_B');
    RETURN TRUE;
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.notExistItemsB-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END notExistItemsB;

FUNCTION existItemsTLP(p_rt_item_id		IN NUMBER,
		       p_language		IN VARCHAR2,
		       p_item_source_type	IN VARCHAR2,
		       p_search_type		IN VARCHAR2,
		       p_primary_category_id	OUT NOCOPY NUMBER,
		       p_primary_category_name	IN VARCHAR2,
		       p_internal_item_id	IN NUMBER,
		       p_internal_item_num	IN VARCHAR2,
		       p_supplier_id		IN NUMBER,
		       p_supplier		IN VARCHAR2,
		       p_supplier_part_num	IN VARCHAR2,
		       p_description		IN VARCHAR2,
		       p_picture		IN VARCHAR2,
		       p_picture_url		IN VARCHAR2)
  RETURN BOOLEAN
IS
  xErrLoc	PLS_INTEGER;
  xResult	PLS_INTEGER;
BEGIN
  xErrLoc:= 100;
  SELECT primary_category_id
  INTO   p_primary_category_id
  FROM   icx_cat_items_tlp
  WHERE  rt_item_id = p_rt_item_id
  AND    language = p_language
  AND    item_source_type = p_item_source_type
  AND    search_type = p_search_type
  AND    primary_category_name = p_primary_category_name
  AND    (supplier_id = ICX_POR_EXT_ITEM.NULL_NUMBER AND
          NVL(p_supplier_id, ICX_POR_EXT_ITEM.NULL_NUMBER) =
            ICX_POR_EXT_ITEM.NULL_NUMBER OR
          supplier_id = p_supplier_id)
  AND    (supplier IS NULL AND p_supplier IS NULL OR
          supplier = p_supplier)
  AND    (supplier_part_num IS NULL AND p_supplier_part_num IS NULL OR
          supplier_part_num = p_supplier_part_num)
  AND    (internal_item_id IS NULL AND p_internal_item_id IS NULL OR
          internal_item_id = p_internal_item_id)
  AND    (internal_item_num IS NULL AND p_internal_item_num IS NULL OR
          internal_item_num = p_internal_item_num)
  AND    (description IS NULL AND p_description IS NULL OR
          description = p_description);
  /*
  AND    (picture IS NULL AND p_picture IS NULL OR
          picture = p_picture)
  AND    (picture_url IS NULL AND p_picture_url IS NULL OR
          picture_url = p_picture_url);
  */

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
    'ItemsTLP[RT_ITEM_ID: ' || p_rt_item_id ||
    ', LANGUAGE: ' || p_language ||
    ', ITEM_SOURCE_TYPE: ' || p_item_source_type ||
    ', SEARCH_TYPE: ' || p_search_type ||
    ', PRIMARY_CATEGORY_ID: ' || p_primary_category_id ||
    ', PRIMARY_CATEGORY_NAME: ' || p_primary_category_name ||
    ', INTERNAL_ITEM_ID: ' || p_internal_item_id ||
    ', INTERNAL_ITEM_NUM: ' || p_internal_item_num ||
    ', SUPPLIER_ID: ' || p_supplier_id ||
    ', SUPPLIER: ' || p_supplier ||
    ', SUPPLIER_PART_NUM: ' || p_supplier_part_num ||
    ', DESCRIPTION: ' || p_description ||
    ', PICTURE: ' || p_picture ||
    ', PICTURE_URL: ' || p_picture_url ||
    '] exists in ICX_CAT_ITEMS_TLP');

  xErrLoc:= 200;
  RETURN TRUE;
EXCEPTION
  when NO_DATA_FOUND then
    xResult:= 0;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
      'ItemsTLP[RT_ITEM_ID: ' || p_rt_item_id ||
      ', LANGUAGE: ' || p_language ||
      ', ITEM_SOURCE_TYPE: ' || p_item_source_type ||
      ', SEARCH_TYPE: ' || p_search_type ||
      ', PRIMARY_CATEGORY_ID: ' || p_primary_category_id ||
      ', PRIMARY_CATEGORY_NAME: ' || p_primary_category_name ||
      ', INTERNAL_ITEM_ID: ' || p_internal_item_id ||
      ', INTERNAL_ITEM_NUM: ' || p_internal_item_num ||
      ', SUPPLIER_ID: ' || p_supplier_id ||
      ', SUPPLIER: ' || p_supplier ||
      ', SUPPLIER_PART_NUM: ' || p_supplier_part_num ||
      ', DESCRIPTION: ' || p_description ||
      ', PICTURE: ' || p_picture ||
      ', PICTURE_URL: ' || p_picture_url ||
      '] does not exist in ICX_CAT_ITEMS_TLP');
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
      'ItemsTLP[RT_ITEM_ID: ' || p_rt_item_id ||
      ', LANGUAGE: ' || p_language ||
      ', ITEM_SOURCE_TYPE: ' || p_item_source_type ||
      ', SEARCH_TYPE: ' || p_search_type ||
      ', PRIMARY_CATEGORY_ID: ' || p_primary_category_id ||
      ', PRIMARY_CATEGORY_NAME: ' || p_primary_category_name ||
      ', INTERNAL_ITEM_ID: ' || p_internal_item_id ||
      ', INTERNAL_ITEM_NUM: ' || p_internal_item_num ||
      ', SUPPLIER_ID: ' || p_supplier_id ||
      ', SUPPLIER: ' || p_supplier ||
      ', SUPPLIER_PART_NUM: ' || p_supplier_part_num ||
      ', DESCRIPTION: ' || p_description ||
      ', PICTURE: ' || p_picture ||
      ', PICTURE_URL: ' || p_picture_url ||
      '] does not exist in ICX_CAT_ITEMS_TLP');
    RETURN FALSE;
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.existItemsTLP-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END existItemsTLP;

FUNCTION notExistItemsTLP(p_rt_item_id		IN NUMBER,
		          p_language		IN VARCHAR2)
  RETURN BOOLEAN
IS
  xErrLoc	PLS_INTEGER;
  xResult	PLS_INTEGER;
BEGIN
  xErrLoc:= 100;
  SELECT 0
  INTO   xResult
  FROM   icx_cat_items_tlp
  WHERE  rt_item_id = p_rt_item_id
  AND    language = p_language;

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
    'ItemsTLP[RT_ITEM_ID: ' || p_rt_item_id ||
    ', LANGUAGE: ' || p_language ||
    '] does not exist in ICX_CAT_ITEMS_TLP');
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
    'ItemsTLP[RT_ITEM_ID: ' || p_rt_item_id ||
    ', LANGUAGE: ' || p_language ||
    '] does not exist in ICX_CAT_ITEMS_TLP');

  xErrLoc:= 200;
  RETURN FALSE;
EXCEPTION
  when NO_DATA_FOUND then
    xResult:= 0;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
      'ItemsTLP[RT_ITEM_ID: ' || p_rt_item_id ||
      ', LANGUAGE: ' || p_language ||
      '] exists in ICX_CAT_ITEMS_TLP');
    RETURN TRUE;
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.notExistItemsTLP-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END notExistItemsTLP;

FUNCTION existCateoryItems(p_rt_item_id		IN NUMBER,
		           p_rt_category_id	IN NUMBER)
  RETURN BOOLEAN
IS
  xErrLoc	PLS_INTEGER;
  xResult	PLS_INTEGER;
BEGIN
  xErrLoc:= 100;
  SELECT 0
  INTO   xResult
  FROM   icx_cat_category_items
  WHERE  rt_item_id = p_rt_item_id
  AND    rt_category_id = p_rt_category_id;

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
    'CategoryItems[RT_ITEM_ID: ' || p_rt_item_id ||
    ', RT_CATEGORY_ID: ' || p_rt_category_id ||
    '] exists in ICX_CAT_CATEGORY_ITEMS');

  xErrLoc:= 200;
  RETURN TRUE;
EXCEPTION
  when NO_DATA_FOUND then
    xResult:= 0;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
      'CategoryItems[RT_ITEM_ID: ' || p_rt_item_id ||
      ', RT_CATEGORY_ID: ' || p_rt_category_id ||
      '] does not exist in ICX_CAT_CATEGORY_ITEMS');
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
      'CategoryItems[RT_ITEM_ID: ' || p_rt_item_id ||
      ', RT_CATEGORY_ID: ' || p_rt_category_id ||
      '] does not exist in ICX_CAT_CATEGORY_ITEMS');
    RETURN FALSE;
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.existCateoryItems-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END existCateoryItems;

FUNCTION notExistCateoryItems(p_rt_item_id		IN NUMBER,
		              p_rt_category_id		IN NUMBER)
  RETURN BOOLEAN
IS
  xErrLoc	PLS_INTEGER;
  xResult	PLS_INTEGER;
BEGIN
  xErrLoc:= 100;
  SELECT 0
  INTO   xResult
  FROM   icx_cat_category_items
  WHERE  rt_item_id = p_rt_item_id
  AND    rt_category_id = p_rt_category_id;

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
    'CategoryItems[RT_ITEM_ID: ' || p_rt_item_id ||
    ', RT_CATEGORY_ID: ' || p_rt_category_id ||
    '] does not exist in ICX_CAT_CATEGORY_ITEMS');
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
    'CategoryItems[RT_ITEM_ID: ' || p_rt_item_id ||
    ', RT_CATEGORY_ID: ' || p_rt_category_id ||
    '] does not exist in ICX_CAT_CATEGORY_ITEMS');

  xErrLoc:= 200;
  RETURN FALSE;
EXCEPTION
  when NO_DATA_FOUND then
    xResult:= 0;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
      'CategoryItems[RT_ITEM_ID: ' || p_rt_item_id ||
      ', RT_CATEGORY_ID: ' || p_rt_category_id ||
      '] exists in ICX_CAT_CATEGORY_ITEMS');
    RETURN TRUE;
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.notExistCateoryItems-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END notExistCateoryItems;

FUNCTION existExtItemsTLP(p_rt_item_id		IN NUMBER,
		          p_rt_category_id	IN NUMBER)
  RETURN BOOLEAN
IS
  xErrLoc	PLS_INTEGER;
  xResult	PLS_INTEGER;
BEGIN
  xErrLoc:= 100;
  SELECT 0
  INTO   xResult
  FROM   icx_cat_ext_items_tlp
  WHERE  rt_item_id = p_rt_item_id
  AND    rt_category_id = p_rt_category_id
  AND    ROWNUM = 1;

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
    'ExtItemsTLP[RT_ITEM_ID: ' || p_rt_item_id ||
    ', RT_CATEGORY_ID: ' || p_rt_category_id ||
    '] exists in ICX_CAT_EXT_ITEMS_TLP');

  xErrLoc:= 200;
  RETURN TRUE;
EXCEPTION
  when NO_DATA_FOUND then
    xResult:= 0;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
      'ExtItemsTLP[RT_ITEM_ID: ' || p_rt_item_id ||
      ', RT_CATEGORY_ID: ' || p_rt_category_id ||
      '] does not exist in ICX_CAT_EXT_ITEMS_TLP');
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
      'ExtItemsTLP[RT_ITEM_ID: ' || p_rt_item_id ||
      ', RT_CATEGORY_ID: ' || p_rt_category_id ||
      '] does not exist in ICX_CAT_EXT_ITEMS_TLP');
    RETURN FALSE;
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.existExtItemsTLP-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END existExtItemsTLP;

FUNCTION notExistExtItemsTLP(p_rt_item_id		IN NUMBER,
		             p_rt_category_id		IN NUMBER)
  RETURN BOOLEAN
IS
  xErrLoc	PLS_INTEGER;
  xResult	PLS_INTEGER;
BEGIN
  xErrLoc:= 100;
  SELECT 0
  INTO   xResult
  FROM   icx_cat_ext_items_tlp
  WHERE  rt_item_id = p_rt_item_id
  AND    rt_category_id = p_rt_category_id
  AND    ROWNUM = 1;

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
    'ExtItemsTLP[RT_ITEM_ID: ' || p_rt_item_id ||
    ', RT_CATEGORY_ID: ' || p_rt_category_id ||
    '] does not exist in ICX_CAT_EXT_ITEMS_TLP');
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
    'ExtItemsTLP[RT_ITEM_ID: ' || p_rt_item_id ||
    ', RT_CATEGORY_ID: ' || p_rt_category_id ||
    '] does not exist in ICX_CAT_EXT_ITEMS_TLP');

  xErrLoc:= 200;
  RETURN FALSE;
EXCEPTION
  when NO_DATA_FOUND then
    xResult:= 0;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
      'ExtItemsTLP[RT_ITEM_ID: ' || p_rt_item_id ||
      ', RT_CATEGORY_ID: ' || p_rt_category_id ||
      '] exists in ICX_CAT_EXT_ITEMS_TLP');
    RETURN TRUE;
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.notExistExtItemsTLP-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END notExistExtItemsTLP;

FUNCTION existItemPrices(p_rt_item_id		IN NUMBER,
		         p_org_id		IN VARCHAR2,
		         p_price_type		IN VARCHAR2,
		         p_active_flag		IN VARCHAR2,
		         p_asl_id		IN NUMBER,
		         p_contract_id		IN VARCHAR2,
		         p_contract_line_id	IN NUMBER,
		         p_template_id		IN VARCHAR2,
		         p_template_line_id	IN NUMBER,
		         p_inventory_item_id	IN VARCHAR2,
		         p_mtl_category_id	IN VARCHAR2,
		         p_search_type		IN VARCHAR2,
		         p_unit_price		IN VARCHAR2,
		         p_currency		IN VARCHAR2,
		         p_unit_of_measure	IN VARCHAR2,
		         p_supplier_site_id	IN VARCHAR2,
		         p_supplier_site_code	IN VARCHAR2,
		         p_contract_num		IN VARCHAR2,
		         p_contract_line_num	IN NUMBER,
		         p_local_rt_item_id	IN NUMBER)
  RETURN BOOLEAN
IS
  xErrLoc	PLS_INTEGER;
  xRtItemId	NUMBER;
  xResult	PLS_INTEGER;
BEGIN
  BEGIN
    xErrLoc:= 100;
    SELECT local_rt_item_id
    INTO   xRtItemId
    FROM   icx_cat_item_prices
    WHERE  rt_item_id = p_rt_item_id
    AND    org_id = p_org_id
    AND    price_type = p_price_type
    AND    active_flag = p_active_flag
    AND    asl_id = p_asl_id
    AND    contract_id = p_contract_id
    AND    contract_line_id = p_contract_line_id
    AND    template_id = p_template_id
    AND    template_line_id = p_template_line_id
    AND    inventory_item_id = p_inventory_item_id
    AND    mtl_category_id = p_mtl_category_id
    AND    search_type = p_search_type
    AND    (unit_price IS NULL AND p_unit_price IS NULL OR
            unit_price = p_unit_price)
    AND    (currency IS NULL AND p_currency IS NULL OR
            currency = p_currency)
    AND    (unit_of_measure IS NULL AND p_unit_of_measure IS NULL OR
            unit_of_measure = p_unit_of_measure)
    AND    supplier_site_id = p_supplier_site_id
    AND    (supplier_site_code IS NULL AND p_supplier_site_code IS NULL OR
            supplier_site_code = p_supplier_site_code)
    AND    (contract_num IS NULL AND p_contract_num IS NULL OR
            contract_num = p_contract_num)
    AND    (contract_line_num IS NULL AND p_contract_line_num IS NULL OR
            contract_line_num = p_contract_line_num);

    IF (p_local_rt_item_id IS NULL OR
        p_local_rt_item_id = xRtItemId)
    THEN
      xResult := 1;
    ELSE
      xResult := 0;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      xResult:= 0;
  END;

  IF xResult = 1 THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
      'ItemPrices[RT_ITEM_ID: ' || p_rt_item_id ||
      ', ORG_ID: ' || p_org_id ||
      ', PRICE_TYPE: ' || p_price_type ||
      ', ACTIVE_FLAG: ' || p_active_flag ||
      ', ASL_ID: ' || p_asl_id ||
      ', CONTRACT_ID: ' || p_contract_id ||
      ', CONTRACT_LINE_ID: ' || p_contract_line_id ||
      ', TEMPLATE_ID: ' || p_template_id ||
      ', TEMPLATE_LINE_ID: ' || p_template_line_id ||
      ', INVENTORY_ITEM_ID: ' || p_inventory_item_id ||
      ', MTL_CATEGORY_ID: ' || p_mtl_category_id ||
      ', SEARCH_TYPE: ' || p_search_type ||
      ', UNIT_PRICE: ' || p_unit_price ||
      ', CURRENCY: ' || p_currency ||
      ', UNIT_OF_MEASURE: ' || p_unit_of_measure ||
      ', SUPPLIER_SITE_ID: ' || p_supplier_site_id ||
      ', SUPPLIER_SITE_CODE: ' || p_supplier_site_code ||
      ', CONTRACT_NUM: ' || p_contract_num ||
      ', CONTRACT_LINE_NUM: ' || p_contract_line_num ||
      ', LOCAL_RT_ITEM_ID: ' || p_local_rt_item_id ||
      '] exists in ICX_CAT_ITEM_PRICES');

    xErrLoc:= 200;
    RETURN TRUE;
  ELSE
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
      'ItemPrices[RT_ITEM_ID: ' || p_rt_item_id ||
      ', ORG_ID: ' || p_org_id ||
      ', PRICE_TYPE: ' || p_price_type ||
      ', ACTIVE_FLAG: ' || p_active_flag ||
      ', ASL_ID: ' || p_asl_id ||
      ', CONTRACT_ID: ' || p_contract_id ||
      ', CONTRACT_LINE_ID: ' || p_contract_line_id ||
      ', TEMPLATE_ID: ' || p_template_id ||
      ', TEMPLATE_LINE_ID: ' || p_template_line_id ||
      ', INVENTORY_ITEM_ID: ' || p_inventory_item_id ||
      ', MTL_CATEGORY_ID: ' || p_mtl_category_id ||
      ', SEARCH_TYPE: ' || p_search_type ||
      ', UNIT_PRICE: ' || p_unit_price ||
      ', CURRENCY: ' || p_currency ||
      ', UNIT_OF_MEASURE: ' || p_unit_of_measure ||
      ', SUPPLIER_SITE_ID: ' || p_supplier_site_id ||
      ', SUPPLIER_SITE_CODE: ' || p_supplier_site_code ||
      ', CONTRACT_NUM: ' || p_contract_num ||
      ', CONTRACT_LINE_NUM: ' || p_contract_line_num ||
      ', LOCAL_RT_ITEM_ID: ' || p_local_rt_item_id ||
      '] does not exist in ICX_CAT_ITEM_PRICES');
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
      'ItemPrices[RT_ITEM_ID: ' || p_rt_item_id ||
      ', ORG_ID: ' || p_org_id ||
      ', PRICE_TYPE: ' || p_price_type ||
      ', ACTIVE_FLAG: ' || p_active_flag ||
      ', ASL_ID: ' || p_asl_id ||
      ', CONTRACT_ID: ' || p_contract_id ||
      ', CONTRACT_LINE_ID: ' || p_contract_line_id ||
      ', TEMPLATE_ID: ' || p_template_id ||
      ', TEMPLATE_LINE_ID: ' || p_template_line_id ||
      ', INVENTORY_ITEM_ID: ' || p_inventory_item_id ||
      ', MTL_CATEGORY_ID: ' || p_mtl_category_id ||
      ', SEARCH_TYPE: ' || p_search_type ||
      ', UNIT_PRICE: ' || p_unit_price ||
      ', CURRENCY: ' || p_currency ||
      ', UNIT_OF_MEASURE: ' || p_unit_of_measure ||
      ', SUPPLIER_SITE_ID: ' || p_supplier_site_id ||
      ', SUPPLIER_SITE_CODE: ' || p_supplier_site_code ||
      ', CONTRACT_NUM: ' || p_contract_num ||
      ', CONTRACT_LINE_NUM: ' || p_contract_line_num ||
      ', LOCAL_RT_ITEM_ID: ' || p_local_rt_item_id ||
      '] does not exist in ICX_CAT_ITEM_PRICES');
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.existItemPrices-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END existItemPrices;

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
  RETURN BOOLEAN
IS
  xErrLoc	PLS_INTEGER;
  xResult	PLS_INTEGER;
BEGIN
  xErrLoc:= 100;
  SELECT 0
  INTO   xResult
  FROM   icx_cat_item_prices
  WHERE  rt_item_id = p_rt_item_id
  AND    org_id = p_org_id
  AND    price_type = p_price_type
  AND    active_flag = p_active_flag
  AND    asl_id = p_asl_id
  AND    contract_id = p_contract_id
  AND    contract_line_id = p_contract_line_id
  AND    template_id = p_template_id
  AND    template_line_id = p_template_line_id
  AND    inventory_item_id = p_inventory_item_id;

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
    'ItemPrices[RT_ITEM_ID: ' || p_rt_item_id ||
    ', ORG_ID: ' || p_org_id ||
    ', PRICE_TYPE: ' || p_price_type ||
    ', ACTIVE_FLAG: ' || p_active_flag ||
    ', ASL_ID: ' || p_asl_id ||
    ', CONTRACT_ID: ' || p_contract_id ||
    ', CONTRACT_LINE_ID: ' || p_contract_line_id ||
    ', TEMPLATE_ID: ' || p_template_id ||
    ', TEMPLATE_LINE_ID: ' || p_template_line_id ||
    ', INVENTORY_ITEM_ID: ' || p_inventory_item_id ||
    '] exists in ICX_CAT_ITEM_PRICES');
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
    'ItemPrices[RT_ITEM_ID: ' || p_rt_item_id ||
    ', ORG_ID: ' || p_org_id ||
    ', PRICE_TYPE: ' || p_price_type ||
    ', ACTIVE_FLAG: ' || p_active_flag ||
    ', ASL_ID: ' || p_asl_id ||
    ', CONTRACT_ID: ' || p_contract_id ||
    ', CONTRACT_LINE_ID: ' || p_contract_line_id ||
    ', TEMPLATE_ID: ' || p_template_id ||
    ', TEMPLATE_LINE_ID: ' || p_template_line_id ||
    ', INVENTORY_ITEM_ID: ' || p_inventory_item_id ||
    '] exists in ICX_CAT_ITEM_PRICES');

  xErrLoc:= 200;
  RETURN FALSE;
EXCEPTION
  when NO_DATA_FOUND then
    xResult:= 0;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
      'ItemPrices[RT_ITEM_ID: ' || p_rt_item_id ||
      ', ORG_ID: ' || p_org_id ||
      ', PRICE_TYPE: ' || p_price_type ||
      ', ACTIVE_FLAG: ' || p_active_flag ||
      ', ASL_ID: ' || p_asl_id ||
      ', CONTRACT_ID: ' || p_contract_id ||
      ', CONTRACT_LINE_ID: ' || p_contract_line_id ||
      ', TEMPLATE_ID: ' || p_template_id ||
      ', TEMPLATE_LINE_ID: ' || p_template_line_id ||
      ', INVENTORY_ITEM_ID: ' || p_inventory_item_id ||
      '] does not exist in ICX_CAT_ITEM_PRICES');
    RETURN TRUE;
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.notExistItemPrices-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END notExistItemPrices;

-- FPJ Bug# 3007068 sosingha: Extractor Changes For Kit Support Project
-- Add new function checkSuggestedQuantity to check if the suggested_quantity extracted matches
-- the suggested_quantity inserted or updated previously in ipo_reqexpress_lines_all

FUNCTION checkSuggestedQuantity(p_rt_item_id   IN NUMBER,
                         p_org_id               IN VARCHAR2,
                         p_price_type           IN VARCHAR2,
                         p_active_flag          IN VARCHAR2,
                         p_template_id          IN VARCHAR2,
                         p_template_line_id     IN NUMBER,
                         p_inventory_item_id    IN VARCHAR2,
                         p_mtl_category_id      IN VARCHAR2,
                         p_suggested_quantity   IN NUMBER,
                         p_local_rt_item_id     IN NUMBER)
  RETURN BOOLEAN
IS
  xErrLoc       PLS_INTEGER;
  xRtItemId     NUMBER;
  xResult       PLS_INTEGER;
BEGIN
  BEGIN
    xErrLoc:= 100;
    SELECT local_rt_item_id
    INTO   xRtItemId
    FROM   icx_cat_item_prices
    WHERE  rt_item_id = p_rt_item_id
    AND    org_id = p_org_id
    AND    price_type = p_price_type
    AND    active_flag = p_active_flag
    AND    template_id = p_template_id
    AND    template_line_id = p_template_line_id
    AND    inventory_item_id = p_inventory_item_id
    AND    mtl_category_id = p_mtl_category_id
    AND    suggested_quantity = p_suggested_quantity;
    IF (p_local_rt_item_id IS NULL OR
        p_local_rt_item_id = xRtItemId)
    THEN
      xResult := 1;
    ELSE
      xResult := 0;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      xResult:= 0;
  END;

    IF xResult = 1 THEN
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
      'ItemPrices[RT_ITEM_ID: ' || p_rt_item_id ||
      ', ORG_ID: ' || p_org_id ||
      ', PRICE_TYPE: ' || p_price_type ||
      ', ACTIVE_FLAG: ' || p_active_flag ||
      ', TEMPLATE_ID: ' || p_template_id ||
      ', TEMPLATE_LINE_ID: ' || p_template_line_id ||
      ', INVENTORY_ITEM_ID: ' || p_inventory_item_id ||
      ', MTL_CATEGORY_ID: ' || p_mtl_category_id ||
      ', SUGGESTED_QUANTITY: ' || p_suggested_quantity ||
      ', LOCAL_RT_ITEM_ID: ' || p_local_rt_item_id ||
      '] exists in ICX_CAT_ITEM_PRICES');

    xErrLoc:= 200;
    RETURN TRUE;
  ELSE
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ANLYS_LEVEL,
      'ItemPrices[RT_ITEM_ID: ' || p_rt_item_id ||
      ', ORG_ID: ' || p_org_id ||
      ', PRICE_TYPE: ' || p_price_type ||
      ', ACTIVE_FLAG: ' || p_active_flag ||
      ', TEMPLATE_ID: ' || p_template_id ||
      ', TEMPLATE_LINE_ID: ' || p_template_line_id ||
      ', INVENTORY_ITEM_ID: ' || p_inventory_item_id ||
      ', MTL_CATEGORY_ID: ' || p_mtl_category_id ||
      ', SUGGESTED_QUANTITY: ' || p_suggested_quantity ||
      ', LOCAL_RT_ITEM_ID: ' || p_local_rt_item_id ||
      '] does not exist in ICX_CAT_ITEM_PRICES');
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL,
      'ItemPrices[RT_ITEM_ID: ' || p_rt_item_id ||
      ', ORG_ID: ' || p_org_id ||
      ', PRICE_TYPE: ' || p_price_type ||
      ', ACTIVE_FLAG: ' || p_active_flag ||
      ', TEMPLATE_ID: ' || p_template_id ||
      ', TEMPLATE_LINE_ID: ' || p_template_line_id ||
      ', INVENTORY_ITEM_ID: ' || p_inventory_item_id ||
      ', MTL_CATEGORY_ID: ' || p_mtl_category_id ||
      ', SUGGESTED_QUANTITY: ' || p_suggested_quantity ||
      ', LOCAL_RT_ITEM_ID: ' || p_local_rt_item_id ||
      '] does not exist in ICX_CAT_ITEM_PRICES');
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXT_TEST.existItemPrices-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END checkSuggestedQuantity;

END ICX_POR_EXT_TEST;

/
