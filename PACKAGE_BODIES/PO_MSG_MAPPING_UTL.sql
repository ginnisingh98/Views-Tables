--------------------------------------------------------
--  DDL for Package Body PO_MSG_MAPPING_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_MSG_MAPPING_UTL" AS
/* $Header: PO_MSG_MAPPING_UTL.plb 120.3 2006/06/19 23:15:51 bao noship $ */

g_msg_tsfm_context_list MSG_MAPPING_CONTEXT_LIST;

d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_MSG_MAPPING_UTL');

g_APP_PO CONSTANT VARCHAR2(30) := 'PO';
g_APP_ICX CONSTANT VARCHAR2(30) := 'ICX';
--------------------------------------------------------------------------
---------------------- PRIVATE PROCEDURES PROTOTYPE ----------------------
--------------------------------------------------------------------------

PROCEDURE init_catalog_upload_msg;

FUNCTION create_msg_record
(
  p_message_name             IN VARCHAR2,
  p_column_name              IN VARCHAR2 := NULL,
  p_column_value_key         IN VARCHAR2 := NULL,
  p_num_of_tokens            IN NUMBER   := 0,
  p_app_name                 IN VARCHAR2 := NULL,
  p_token1_name              IN VARCHAR2 := NULL,
  p_token1_value_key         IN VARCHAR2 := NULL,
  p_token2_name              IN VARCHAR2 := NULL,
  p_token2_value_key         IN VARCHAR2 := NULL,
  p_token3_name              IN VARCHAR2 := NULL,
  p_token3_value_key         IN VARCHAR2 := NULL,
  p_token4_name              IN VARCHAR2 := NULL,
  p_token4_value_key         IN VARCHAR2 := NULL,
  p_token5_name              IN VARCHAR2 := NULL,
  p_token5_value_key         IN VARCHAR2 := NULL,
  p_token6_name              IN VARCHAR2 := NULL,
  p_token6_value_key         IN VARCHAR2 := NULL
) RETURN msg_rec_type;

-------------------------------------------------------
-------------- PUBLIC PROCEDURES ----------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: find_msg
--Function:
--  Find the message based on the context and message id
--Parameters:
--IN:
--p_results
--  The validation results that contains the errored line information.
--IN OUT:
--p_price_diffs
--  The record contains the values to be validated.
--  If there is error(s) on any attribute of the price differential row,
--  corresponding value in error_flag_tbl will be set with value
--  FND_API.G_TRUE.
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE find_msg
( p_context IN VARCHAR2,
  p_id      IN NUMBER,
  x_msg_exists OUT NOCOPY VARCHAR2,
  x_msg_rec    OUT NOCOPY msg_rec_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'find_msg';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);

d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
     PO_LOG.proc_begin(d_module);
  END IF;

  x_msg_exists := FND_API.G_FALSE;

  IF (g_msg_tsfm_context_list.EXISTS(p_context)) THEN
    IF (g_msg_tsfm_context_list(p_context).EXISTS(p_id)) THEN
      x_msg_rec := g_msg_tsfm_context_list(p_context)(p_id);
      x_msg_exists := FND_API.G_TRUE;
    END IF;
  END IF;

  IF (PO_LOG.d_proc) THEN
     PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END find_msg;

-------------------------------------------------------
-------------- PRIVATE PROCEDURES ----------------------
-------------------------------------------------------
PROCEDURE init_msg_mappings IS

d_api_name CONSTANT VARCHAR2(30) := 'init_msg_mappings';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);

d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
     PO_LOG.proc_begin(d_module);
  END IF;

  g_msg_tsfm_context_list.DELETE;

  -- If we need to initialize message mappings for other contexts, add a
  -- procedure here and define mappings in that procedure
  init_catalog_upload_msg;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END init_msg_mappings;


PROCEDURE init_catalog_upload_msg IS
d_api_name CONSTANT VARCHAR2(30) := 'init_catalog_upload_msg';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);

d_position NUMBER;

l_context VARCHAR2(25) := PO_PDOI_CONSTANTS.g_CALL_MOD_CATALOG_UPLOAD;

l_msg_tsfm_list MSG_MAPPING_LIST;

BEGIN

  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_job_id_null) :=
    create_msg_record('PO_CAT_SVC_NO_JOB', 'JOB_NAME', c_job_name, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_job_bg_id_not_cross_bg) :=
    create_msg_record('PO_CAT_SVC_CANNOT_CROSS_BG', 'JOB_NAME', c_job_name, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_job_business_group_id_valid) :=
    create_msg_record('PO_CAT_SVC_INVALID_BG', 'JOB_NAME', c_job_name, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_job_id_not_null) :=
    create_msg_record('PO_CAT_SVC_MUST_JOB', 'JOB_NAME', c_job_name, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_job_id_valid) :=
    create_msg_record('PO_CAT_SVC_INVALID_JOB', 'JOB_NAME', c_job_name, 1, g_APP_PO,  'BG_NAME', c_job_business_group_name);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_job_id_valid_cat) :=
    create_msg_record('PO_PDOI_SVC_INVALID_JOB_CAT', 'JOB_NAME', c_job_name, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_unit_meas_lookup_valid) :=
    create_msg_record('PO_CAT_INACTIVE_VALUE', 'UOM_CODE', c_uom_code, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_uom_update_valid) :=
    create_msg_record('PO_CAT_INACTIVE_VALUE', 'UOM_CODE', c_uom_code, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_unit_meas_lookup_null) :=
    create_msg_record('PO_CAT_SVC_NO_UOM', 'UOM_CODE', c_uom_code, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_unit_meas_lookup_not_null) :=
    create_msg_record('PO_CAT_COLUMN_NOT_NULL', 'UOM_CODE', c_uom_code, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_uom_update_not_null) :=
    create_msg_record('PO_CAT_COLUMN_NOT_NULL', 'UOM_CODE', c_uom_code, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_unit_meas_lookup_svc_valid) :=
    create_msg_record('PO_PDOI_SVC_INVALID_UOM', 'UOM_CODE', c_uom_code, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_unit_meas_lookup_line_type) :=
    create_msg_record('PO_CAT_INVALID_LINE_TYPE_UOM', 'UOM_CODE', c_uom_code, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_unit_meas_lookup_item) :=
    create_msg_record('PO_CAT_ITEM_RELATED_INFO', 'UOM_CODE', c_uom_code, 1, g_APP_PO,  'ITEM_DESC', c_item_desc);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_amount_blanket) :=
    create_msg_record('PO_CAT_SVC_BLKT_NO_AMT', 'AMOUNT', c_amount, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_item_desc_not_null) :=
    create_msg_record('PO_CAT_COLUMN_NOT_NULL', 'ITEM_DESCRIPTION', c_item_desc, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_item_desc_update_not_null) :=
    create_msg_record('PO_CAT_COLUMN_NOT_NULL', 'ITEM_DESCRIPTION', c_item_desc, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_unit_price_null) :=
    create_msg_record('PO_PDOI_SVC_NO_PRICE', 'UNIT_PRICE', c_unit_price, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_unit_price_not_null) :=
    create_msg_record('PO_CAT_COLUMN_NOT_NULL', 'UNIT_PRICE', c_unit_price, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_unit_price_update_not_null) :=
    create_msg_record('PO_CAT_COLUMN_NOT_NULL', 'UNIT_PRICE', c_unit_price, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_unit_price_ge_zero) :=
    create_msg_record('PO_CAT_LT_ZERO', 'UNIT_PRICE', c_unit_price, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_unit_price_update_ge_zero) :=
    create_msg_record('PO_CAT_LT_ZERO', 'UNIT_PRICE', c_unit_price, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_unit_price_line_type) :=
    create_msg_record('PO_CAT_INV_LINE_TYPE_PRICE', 'UNIT_PRICE', c_unit_price, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_category_id_not_null) :=
    create_msg_record('PO_CAT_COLUMN_NOT_NULL', 'CATEGORY', c_category, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_cat_id_update_not_null) :=
    create_msg_record('PO_CAT_COLUMN_NOT_NULL', 'CATEGORY', c_category, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_category_id_item) :=
    create_msg_record('PO_CAT_ITEM_RELATED_INFO', 'CATEGORY', c_category, 1, g_APP_PO,  'ITEM_DESC', c_item_desc);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_category_id_valid) :=
    create_msg_record('PO_CAT_INACTIVE_VALUE', 'CATEGORY', c_category, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_line_type_id_not_null) :=
    create_msg_record('PO_CAT_COLUMN_NOT_NULL', 'LINE_TYPE', c_line_type, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_line_type_id_valid) :=
    create_msg_record('PO_CAT_INVALID_LINE_TYPE', 'LINE_TYPE', c_line_type, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_line_num_not_null) :=
    create_msg_record('PO_CAT_COLUMN_NOT_NULL', 'LINE_NUM', c_line_num, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_quantity_ge_zero) := create_msg_record('PO_CAT_LT_ZERO', 'QUANTITY', c_quantity, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_loc_quantity) :=
    create_msg_record('PO_PDOI_SVC_PB_NO_QTY', 'QUANTITY', c_quantity, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_item_id_valid) :=
    create_msg_record('PO_CAT_INVALID_ITEM', 'ITEM', c_item, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_item_id_op_valid) :=
    create_msg_record('PO_CAT_INVALID_OP_ITEM', 'ITEM', c_item, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_item_id_null) :=
    create_msg_record('PO_CAT_COLUMN_NULL', 'ITEM', c_item, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_item_id_not_null) :=
    create_msg_record('PO_CAT_ITEM_NOT_NULL', 'ITEM', c_item, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_item_revision_null) :=
    create_msg_record('PO_CAT_COLUMN_NULL', 'ITEM_REVISION', c_item_revision, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_item_revision_item) :=
    create_msg_record('PO_CAT_ITEM_RELATED_INFO', 'ITEM_REVISION', c_item_revision, 1, g_APP_PO,  'ITEM_DESC', c_item_desc);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_ga_flag_temp_labor) :=
    create_msg_record('PO_PDOI_SVC_NO_LOCAL_BLANKET', 'GLOBAL_AGREEMENT_FLAG', c_ga_flag, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_ga_flag_op) :=
    create_msg_record('PO_PDOI_GA_OSP_NA', 'GLOBAL_AGREEMENT_FLAG', c_ga_flag, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_price_break_not_allowed) :=
    create_msg_record('PO_PDOI_PRICE_BRK_AMT_BASED_LN', NULL, NULL, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_negotiated_by_preparer) :=
    create_msg_record('PO_CAT_INVALID_FLAG_VALUE', 'NEGOTIATED_BY_PREPARER_FLAG', c_negotiated_flag, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_loc_price_discount_not_null) :=
    create_msg_record('PO_CAT_COLUMN_NOT_NULL', 'PRICE_DISCOUNT', c_price_discount, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_loc_price_discount_valid) :=
    create_msg_record('PO_CAT_INVALID_DISCOUNT', 'PRICE_DISCOUNT', c_price_discount, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_ip_category_id_valid) :=
    create_msg_record('PO_CAT_INACTIVE_VALUE', 'IP_CATEGORY_NAME', c_ip_category, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_ip_cat_id_update_valid) :=
    create_msg_record('PO_CAT_INACTIVE_VALUE', 'IP_CATEGORY_NAME', c_ip_category, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_item_desc_not_updatable) :=
    create_msg_record('PO_CAT_DIFF_ITEM_DESC', 'ITEM_DESCRIPTION', c_item_desc, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_item_desc_update_unupdatable) :=
    create_msg_record('PO_CAT_DIFF_ITEM_DESC', 'ITEM_DESCRIPTION', c_item_desc, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_not_to_exceed_price_valid) :=
    create_msg_record('PO_CAT_INVALID_PRICE', 'UNIT_PRICE', c_unit_price, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_loc_ship_to_loc_id_valid) :=
    create_msg_record('PO_CAT_INACTIVE_VALUE', 'SHIP_TO_LOCATION', c_loc_ship_to_location, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_ship_to_organization_id) :=
    create_msg_record('PO_CAT_INACTIVE_VALUE', 'SHIP_TO_ORGANIZATION_CODE', c_ship_to_organization_code, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_line_style_on_line_type) :=
    create_msg_record('PO_CAT_LINE_TYPE_ID_STYLE', 'LINE_TYPE', c_line_type, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_cat_id_update_not_updatable) :=
    create_msg_record('PO_CAT_NO_PO_CAT_UPDATE', 'CATEGORY', c_category, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_loc_style_related_info) :=
    create_msg_record('PO_CAT_PRICE_BREAK_STYLE', NULL, NULL, 0); -- bug5262146
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_line_style_on_purchase_basis) :=
    create_msg_record('PO_CAT_PURCHASE_BASIS_STYLE', 'LINE_TYPE', c_line_type, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_loc_quantity) :=
    create_msg_record('PO_CAT_SVC_PB_NO_QTY', 'LINE_TYPE', c_line_type, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_rate_type_no_usr) :=
    create_msg_record('PO_CAT_SVC_RATE_TYPE_NO_USR', 'LINE_TYPE', c_line_type, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_line_type_derv) :=
    create_msg_record('ICX_CAT_INVALID_VALUE', 'LINE_TYPE', c_line_type, 0, g_APP_ICX);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_category_derv) :=
    create_msg_record('ICX_CAT_INVALID_VALUE', 'CATEGORY', c_category, 0, g_APP_ICX);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_ip_category_derv) :=
    create_msg_record('ICX_CAT_INVALID_VALUE', 'IP_CATEGORY_NAME', c_ip_category, 0, g_APP_ICX);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_job_name_derv) :=
    create_msg_record('ICX_CAT_INVALID_VALUE', 'JOB_NAME', c_job_name, 0, g_APP_ICX);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_uom_code_derv) :=
    create_msg_record('ICX_CAT_INVALID_VALUE', 'UOM_CODE', c_uom_code, 0, g_APP_ICX);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_item_derv) :=
    create_msg_record('ICX_CAT_INVALID_VALUE', 'ITEM', c_item, 0, g_APP_ICX);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_ship_to_org_code_derv) :=
    create_msg_record('ICX_CAT_INVALID_VALUE', 'SHIP_TO_ORGANIZATION_CODE', c_ship_to_organization_code, 0, g_APP_ICX);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_ship_to_location_derv) :=
    create_msg_record('ICX_CAT_INVALID_VALUE', 'SHIP_TO_LOCATION', c_loc_ship_to_location, 0, g_APP_ICX);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_part_num_derv) :=
    create_msg_record('PO_CAT_DERV_PART_NUM_ERROR', 'ITEM', c_item, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_line_rec_valid) :=
    create_msg_record('PO_CAT_INVALID_INTER_LINE_REC', NULL, NULL, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_language) :=
    create_msg_record('PO_PDOI_NO_TLP_IN_CREATE_LANG', 'CREATED_LANGUAGE', c_created_language, 0);
  l_msg_tsfm_list(PO_VAL_CONSTANTS.c_dates_cumulative_failed) :=
    create_msg_record('PO_CAT_CUMULATIVE_FAILED', NULL, NULL, 0); -- bug5262146

  g_msg_tsfm_context_list (l_context) := l_msg_tsfm_list;

END init_catalog_upload_msg;


FUNCTION create_msg_record
(
  p_message_name             IN VARCHAR2,
  p_column_name              IN VARCHAR2 := NULL,
  p_column_value_key         IN VARCHAR2 := NULL,
  p_num_of_tokens            IN NUMBER   := 0,
  p_app_name                 IN VARCHAR2 := NULL,
  p_token1_name              IN VARCHAR2 := NULL,
  p_token1_value_key         IN VARCHAR2 := NULL,
  p_token2_name              IN VARCHAR2 := NULL,
  p_token2_value_key         IN VARCHAR2 := NULL,
  p_token3_name              IN VARCHAR2 := NULL,
  p_token3_value_key         IN VARCHAR2 := NULL,
  p_token4_name              IN VARCHAR2 := NULL,
  p_token4_value_key         IN VARCHAR2 := NULL,
  p_token5_name              IN VARCHAR2 := NULL,
  p_token5_value_key         IN VARCHAR2 := NULL,
  p_token6_name              IN VARCHAR2 := NULL,
  p_token6_value_key         IN VARCHAR2 := NULL
) RETURN msg_rec_type IS

d_api_name CONSTANT VARCHAR2(30) := 'create_msg_record';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);

d_position NUMBER;

l_msg_rec MSG_REC_TYPE;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
     PO_LOG.proc_begin(d_module);
  END IF;

  -- setup values in the error message record
  l_msg_rec.app_name          := p_app_name;
  l_msg_rec.message_name      := p_message_name;
  l_msg_rec.column_name       := p_column_name;
  l_msg_rec.column_value_key  := p_column_value_key;
  l_msg_rec.num_of_tokens     := p_num_of_tokens;
  l_msg_rec.token1_name       := p_token1_name;
  l_msg_rec.token1_value_key  := p_token1_value_key;
  l_msg_rec.token2_name       := p_token2_name;
  l_msg_rec.token2_value_key  := p_token2_value_key;
  l_msg_rec.token3_name       := p_token3_name;
  l_msg_rec.token3_value_key  := p_token3_value_key;
  l_msg_rec.token4_name       := p_token4_name;
  l_msg_rec.token4_value_key  := p_token4_value_key;
  l_msg_rec.token5_name       := p_token5_name;
  l_msg_rec.token5_value_key  := p_token5_value_key;
  l_msg_rec.token6_name       := p_token6_name;
  l_msg_rec.token6_value_key  := p_token6_value_key;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN l_msg_rec;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );

  RAISE;
END create_msg_record;



-----------------------------------------------------------------------------
-- Package initialization.
-----------------------------------------------------------------------------
BEGIN
  -- initialize error message mapping for ip upload
  init_msg_mappings;

END PO_MSG_MAPPING_UTL;

/
