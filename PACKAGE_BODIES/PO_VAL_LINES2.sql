--------------------------------------------------------
--  DDL for Package Body PO_VAL_LINES2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VAL_LINES2" AS
   -- $Header: PO_VAL_LINES2.plb 120.30.12010000.29 2014/07/17 10:40:52 yuandli ship $
   c_entity_type_line CONSTANT VARCHAR2(30) := po_validations.c_entity_type_line;
   -- The module base for this package.
   d_package_base CONSTANT VARCHAR2(50) := po_log.get_package_base('PO_VAL_LINES2');

   -- The module base for the subprogram.
   d_over_tolerance_error_flag CONSTANT VARCHAR2(100)
                    := po_log.get_subprogram_base(d_package_base, 'OVER_TOLERANCE_ERROR_FLAG');
   d_expiration_date_blanket CONSTANT VARCHAR2(100)
                    := po_log.get_subprogram_base(d_package_base, 'EXPIRATION_DATE_BLANKET');
   d_global_agreement_flag CONSTANT VARCHAR2(100)
                    := po_log.get_subprogram_base(d_package_base, 'GLOBAL_AGREEMENT_FLAG');
   d_amount_blanket CONSTANT VARCHAR2(100)
                    := po_log.get_subprogram_base(d_package_base, 'AMOUNT_BLANKET');
   d_order_type_lookup_code CONSTANT VARCHAR2(100)
                    := po_log.get_subprogram_base(d_package_base, 'ORDER_TYPE_LOOKUP_CODE');
   d_contractor_name CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'CONTRACTOR_NAME');
   d_job_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'JOB_ID');
   d_job_business_group_id CONSTANT VARCHAR2(100)
                    := po_log.get_subprogram_base(d_package_base, 'JOB_BUSINESS_GROUP_ID');
   d_capital_expense_flag CONSTANT VARCHAR2(100)
                    := po_log.get_subprogram_base(d_package_base, 'CAPITAL_EXPENSE_FLAG');
   d_un_number_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'UN_NUMBER_ID');
   d_hazard_class_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'HAZARD_CLASS_ID');
   d_item_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'ITEM_ID');
   d_item_description CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'ITEM_DESCRIPTION');
   d_unit_meas_lookup_code CONSTANT VARCHAR2(100)
                     := po_log.get_subprogram_base(d_package_base, 'UNIT_MEAS_LOOKUP_CODE');
   d_item_revision CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'ITEM_REVISION');
   d_category_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'CATEGORY_ID');
   d_ip_category_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'IP_CATEGORY_ID');
   d_unit_price CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'UNIT_PRICE');
   d_quantity CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'QUANTITY');
   d_amount CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'AMOUNT');
   d_rate_type CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'RATE_TYPE');
   d_line_num CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'LINE_NUM');
   d_po_line_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'PO_LINE_ID');
   d_line_type_id CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'LINE_TYPE_ID');
   d_style_related_info CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'STYLE_RELATED_INFO');
   d_price_type_lookup_code CONSTANT VARCHAR2(100)
                      := po_log.get_subprogram_base(d_package_base, 'PRICE_TYPE_LOOKUP_CODE');
   d_start_date_standard CONSTANT VARCHAR2(100)
                      := po_log.get_subprogram_base(d_package_base, 'START_DATE_STANDARD');
   d_item_id_standard CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'ITEM_ID_STANDARD');
   d_quantity_standard CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'QUANTITY_STANDARD');
   d_amount_standard CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'AMOUNT_STANDARD');
   d_price_break_lookup_code CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'PRICE_BREAK_LOOKUP_CODE');
   d_not_to_exceed_price CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'NOT_TO_EXCEED_PRICE');
   d_ip_category_id_update CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'IP_CATEGORY_ID_UPDATE');
   d_uom_update CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'UOM_UPDATE');
   d_item_desc_update CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'ITEM_DESC_UPDATE');
   d_negotiated_by_preparer CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'NEGOTIATED_BY_PREPARER');
   d_negotiated_by_prep_update CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'NEGOTIATED_BY_PREPARER_UPDATE');
   d_category_id_update CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'CATEGORY_ID_UPDATE');
   d_unit_price_update CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'UNIT_PRICE_UPDATE');
   d_amount_update CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'AMOUNT_UPDATE');
   -- bug 8633959
   d_category_comb_valid CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'CATEGORY_COMBINATION_VALID');

   -- bug 14075368
   d_item_comb_valid CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'ITEM_COMBINATION_VALID');

   -- <PDOI Enhancement Bug#17063664 Start>
   D_validate_source_doc CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SOURCE_DOC');
   D_validate_src_blanket_exists CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_BLANKET_EXISTS');
   D_validate_src_contract_exists CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_CONTRACT_EXISTS');
   D_validate_src_only_one CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_ONLY_ONE');
   D_validate_src_doc_global CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_DOC_GLOBAL');
   D_validate_src_doc_vendor CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_DOC_VENDOR');
   D_validate_src_doc_vendor_site CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_DOC_VENDOR_SITE');
   D_validate_src_doc_approved CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_DOC_APPROVED');
   D_validate_src_doc_hold CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_DOC_HOLD');
   D_validate_src_doc_currency CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_DOC_CURRENCY');
   D_validate_src_doc_closed_code CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_DOC_CLOSED_CODE');
   D_validate_src_doc_cancel CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_DOC_CANCEL');
   D_validate_src_doc_frozen CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'ITEM_COMBINATION_VALID');
   D_validate_src_bpa_expiry_date CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_BPA_EXPIRY_DATE');
   D_validate_src_cpa_expiry_date CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_CPA_EXPIRY_DATE');
   D_validate_src_doc_style CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_DOC_STYLE');
   D_validate_src_line_not_null CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_LINE_NOT_NULL');
   D_validate_src_line_item CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_LINE_ITEM');
   D_validate_src_line_item_rev CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_LINE_ITEM_REV');
   D_validate_src_line_job CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_LINE_JOB');

   D_validate_src_line_cancel CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_LINE_CANCEL');
   D_validate_src_line_closed CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_LINE_CLOSED');
   D_validate_src_line_order_type CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_LINE_ORDER_TYPE');
   D_validate_src_line_pur_basis CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_LINE_PUR_BASIS');
   D_validate_src_line_match CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_LINE_MATCH');
   D_validate_src_line_uom CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_LINE_UOM');
   D_validate_src_allow_price_ovr CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_SRC_ALLOW_PRICE_OVR');

   D_validate_req_reference CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQ_REFERENCE');
   D_validate_req_exists CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQ_EXITS');
   D_validate_no_ship_dist CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_NO_SHIP_DIST');
   D_validate_req_status CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQ_STATUS');
   D_validate_reqs_in_pool_flag CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQS_IN_POOL_FLAG');
   D_validate_reqs_cancel_flag CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQS_CANCEL_FLAG');
   D_validate_reqs_closed_code CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQS_CLOSED_CODE');
   D_validate_reqs_modfd_by_agt CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQS_MODFD_BY_AGT');
   D_validate_reqs_at_srcing_flg CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQS_AT_SRCING_FLAG');
   D_validate_reqs_line_loc CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQS_LINE_LOC');
   D_validate_req_item CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQ_ITEM');
   D_validate_req_job CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQ_JOB');
   D_validate_req_pur_basis CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQ_PUR_BASIS');
   D_validate_req_match_basis CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQ_MATCH_BASIS');
   D_validate_pcard CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_PCARD');
   D_validate_reqorg_srcdoc CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQ_ORG_SRC_DOC');
   D_validate_style_dest_progress CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_STYLE_DEST_PROGRESS');
   D_validate_style_line_progress CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_STYLE_LINE_TYPE_PROGRESS');
   D_validate_style_pcard CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_STYLE_PCARD');
   D_validate_req_vmi_bpa CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQ_VMI_BPA');
   D_validate_req_vmi_supplier CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQ_VMI_SUPPLIER');
   D_validate_req_on_spo CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQ_ON_SPO');
   D_validate_req_pcard_supp CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_REQ_PCARD_SUPP');
   D_validate_oke_contract_hdr CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_OKE_CONTRACT_HDR');
   D_validate_oke_contract_ver CONSTANT VARCHAR2(100) := po_log.get_subprogram_base(d_package_base, 'VALIDATE_OKE_CONTRACT_VER');

   c_FROM_HEADER_ID CONSTANT VARCHAR2(30) := 'FROM_HEADER_ID';
   c_CONTRACT_ID CONSTANT VARCHAR2(30) := 'CONTRACT_ID';
   c_FROM_LINE_ID CONSTANT VARCHAR2(30) := 'FROM_LINE_ID';
   c_UNIT_PRICE CONSTANT VARCHAR2(30) := 'UNIT_PRICE';
   c_REQUISITION_LINE_ID CONSTANT VARCHAR2(30) := 'REQUISITION_LINE_ID';
   c_OKE_CONTRACT_HDR_ID CONSTANT VARCHAR2(30) := 'OKE_CONTRACT_HEADER_ID';
   c_OKE_CONTRACT_VERSION CONSTANT VARCHAR2(30) := 'OKE_CONTRACT_HEADER_NUM';

   -- <PDOI Enhancement Bug#17063664 END>

   -- Indicates that the calling program is PDOI.
   c_program_PDOI CONSTANT VARCHAR2(10) := 'PDOI';

   --Bug 19139957
   --Remove change in 18646482 to refix the issue.
   D_format_category_segment CONSTANT VARCHAR(100) := po_log.get_subprogram_base(d_package_base, 'FORMAT_CATEGORY_SEGMENT');


-------------------------------------------------------------------------
-- The lookup code specified in over_tolerance_error_flag with the lookup type
-- 'RECEIVING CONTROL LEVEL' has to exist in po_lookup_codes and still active.
-- This method is called only for Standard PO and quotation documents
-------------------------------------------------------------------------
   PROCEDURE over_tolerance_err_flag(
      p_id_tbl                        IN              po_tbl_number,
      p_over_tolerance_err_flag_tbl   IN              po_tbl_varchar30,
      x_result_set_id                 IN OUT NOCOPY   NUMBER,
      x_result_type                   OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_over_tolerance_error_flag;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_over_tolerance_err_flag_tbl', p_over_tolerance_err_flag_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_OVER_TOL_ERROR',
                   'OVER_TOLERANCE_ERROR_FLAG',
                   p_over_tolerance_err_flag_tbl(i),
                   'OVER_TOLERANCE_ERROR_FLAG',
                   p_over_tolerance_err_flag_tbl(i),
                   PO_VAL_CONSTANTS.c_over_tolerance_error_flag
              FROM DUAL
             WHERE p_over_tolerance_err_flag_tbl(i) IS NOT NULL AND
                   NOT EXISTS(
                      SELECT 1
                        FROM po_lookup_codes plc
                       WHERE plc.lookup_type = 'RECEIVING CONTROL LEVEL'
                         AND SYSDATE < NVL(plc.inactive_date, SYSDATE + 1)
                         AND plc.lookup_code = p_over_tolerance_err_flag_tbl(i));

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      ELSE
         x_result_type := po_validations.c_result_type_success;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END over_tolerance_err_flag;

-------------------------------------------------------------------------
-- Expiration date on the line cannot be earlier than the header effective start date and
-- cannot be later than header effective end date
-------------------------------------------------------------------------
   PROCEDURE expiration_date_blanket(
      p_id_tbl                  IN              po_tbl_number,
      p_expiration_date_tbl     IN              po_tbl_date,
      p_header_start_date_tbl   IN              po_tbl_date,
      p_header_end_date_tbl     IN              po_tbl_date,
      x_results                 IN OUT NOCOPY   po_validation_results_type,
      x_result_type             OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_expiration_date_blanket;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      x_result_type := po_validations.c_result_type_success;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_expiration_date_tbl', p_expiration_date_tbl);
         po_log.proc_begin(d_mod, 'p_header_start_date_tbl', p_header_start_date_tbl);
         po_log.proc_begin(d_mod, 'p_header_end_date_tbl', p_header_end_date_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_expiration_date_tbl(i) = PO_PDOI_CONSTANTS.g_NULLIFY_DATE THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'EXPIRATION_DATE',
                                 p_column_val        => p_expiration_date_tbl(i),
                                 p_message_name      => 'PO_PDOI_COLUMN_NOT_NULL',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'EXPIRATION_DATE',
                 p_validation_id     => PO_VAL_CONSTANTS.c_expiration_date_blk_not_null);
            x_result_type := po_validations.c_result_type_failure;
         ELSIF p_expiration_date_tbl(i) IS NOT NULL
            AND (p_header_start_date_tbl(i) > p_expiration_date_tbl(i)
                 OR p_header_end_date_tbl(i) < p_expiration_date_tbl(i)) THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'EXPIRATION_DATE',
                                 p_column_val        => p_expiration_date_tbl(i),
                                 p_message_name      => 'POX_EXPIRATION_DATES',
                 p_validation_id     => PO_VAL_CONSTANTS.c_expiration_date_blk_exc_hdr);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END expiration_date_blanket;

-------------------------------------------------------------------------
-- For blanket document with purchase type 'TEMP LABOR', the global agreement
-- flag has to be 'Y'.  Global_agreement_flag and outside operation flag
-- cannot both be 'Y'
-------------------------------------------------------------------------
   PROCEDURE global_agreement_flag(
      p_id_tbl                      IN              po_tbl_number,
      p_global_agreement_flag_tbl   IN              po_tbl_varchar1,
      p_purchase_basis_tbl          IN              po_tbl_varchar30,
      p_line_type_id_tbl            IN              po_tbl_number,
      x_result_set_id               IN OUT NOCOPY   NUMBER,
      x_results                     IN OUT NOCOPY   po_validation_results_type,
      x_result_type                 OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_global_agreement_flag;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_global_agreement_flag_tbl', p_global_agreement_flag_tbl);
         po_log.proc_begin(d_mod, 'p_purchase_basis_tbl', p_purchase_basis_tbl);
         po_log.proc_begin(d_mod, 'p_line_type_id_tbl', p_line_type_id_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF NVL(p_global_agreement_flag_tbl(i), 'N') = 'N'
            AND p_purchase_basis_tbl(i) = 'TEMP LABOR' THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'GLOBAL_AGREEMENT_FLAG',
                                 p_column_val        => p_global_agreement_flag_tbl(i),
                                 p_message_name      => 'PO_PDOI_SVC_NO_LOCAL_BLANKET',
	               p_validation_id     => PO_VAL_CONSTANTS.c_ga_flag_temp_labor);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;
     -- Bug 14016721 - Osp project - PDOI will now import OSP lines for GBPA
    /*
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_GA_OSP_NA',
                   PO_VAL_CONSTANTS.c_ga_flag_op
              FROM DUAL
             WHERE p_line_type_id_tbl(i) IS NOT NULL
               AND EXISTS(
                      SELECT 1
                        FROM po_line_types_b plt
                       WHERE p_line_type_id_tbl(i) = plt.line_type_id
                         AND NVL(p_global_agreement_flag_tbl(i), 'N') = 'Y'
                         AND NVL(plt.outside_operation_flag, 'N') = 'Y');

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF; */

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END global_agreement_flag;

-------------------------------------------------------------------------
-- If order_type_lookup_code is 'RATE', amount has to be null;
-- If order_type_lookup_code is 'FIXED PRICE',and amount is not empty,
-- then amount must be greater than or equal to zero
-------------------------------------------------------------------------
   PROCEDURE amount_blanket(
      p_id_tbl                       IN              po_tbl_number,
      p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
      p_amount_tbl                   IN              po_tbl_number,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_amount_blanket;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'p_amount_tbl', p_amount_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- If order_type_lookup_code is 'RATE', amount has to be null
      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_order_type_lookup_code_tbl(i) = 'RATE' AND p_amount_tbl(i) IS NOT NULL THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'AMOUNT',
                                 p_column_val        => p_amount_tbl(i),
                                 p_message_name      => 'PO_PDOI_SVC_BLKT_NO_AMT',
                 p_validation_id     => PO_VAL_CONSTANTS.c_amount_blanket);
            x_result_type := po_validations.c_result_type_failure;
          ELSIF (p_order_type_lookup_code_tbl(i) = 'FIXED PRICE'
                AND p_amount_tbl(i) IS NOT NULL
                AND p_amount_tbl(i) < 0) THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'AMOUNT',
                                 p_column_val        => p_amount_tbl(i),
                                 p_message_name      => 'PO_PDOI_LT_ZERO',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'AMOUNT',
                                 p_token2_name       => 'VALUE',
                                 p_token2_value      => p_amount_tbl(i),
                                 p_validation_id     => PO_VAL_CONSTANTS.c_amount_ge_zero);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END amount_blanket;

-------------------------------------------------------------------------
-- If services procurement is not enabled, the order_type_lookup_code cannot
-- be  'FIXED PRICE' or 'RATE'.
-------------------------------------------------------------------------
   PROCEDURE order_type_lookup_code(
      p_id_tbl                       IN              po_tbl_number,
      p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_order_type_lookup_code;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- If services procurement not enabled, order_type_lookup_code
      -- cannot be 'FIXED PRICE' or 'RATE'
      IF (po_setup_s1.get_services_enabled_flag = 'N') THEN
         FOR i IN 1 .. p_id_tbl.COUNT LOOP
            IF p_order_type_lookup_code_tbl(i) = 'RATE'
                OR p_order_type_lookup_code_tbl(i) = 'FIXED PRICE' THEN
               x_results.add_result(p_entity_type       => c_entity_type_line,
                                    p_entity_id         => p_id_tbl(i),
                                    p_column_name       => 'ORDER_TYPE_LOOKUP_CODE',
                                    p_column_val        => p_order_type_lookup_code_tbl(i),
                                    p_message_name      => 'PO_SVC_NOT_ENABLED',
                  p_validation_id     => PO_VAL_CONSTANTS.c_order_type_lookup_code);
               x_result_type := po_validations.c_result_type_failure;
            END IF;
         END LOOP;
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END order_type_lookup_code;

-------------------------------------------------------------------------
-- If purchase basis is 'TEMP LABOR' and document type is SPO,
-- contractor first name and last name fields could be populated;
-- otherwise, they should be empty
-------------------------------------------------------------------------
   PROCEDURE contractor_name(
      p_id_tbl                      IN              po_tbl_number,
      p_doc_type                    IN              VARCHAR2,
      p_purchase_basis_tbl          IN              po_tbl_varchar30,
      p_contractor_last_name_tbl    IN              po_tbl_varchar2000,
      p_contractor_first_name_tbl   IN              po_tbl_varchar2000,
      x_results                     IN OUT NOCOPY   po_validation_results_type,
      x_result_type                 OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_contractor_name;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_purchase_basis_tbl', p_purchase_basis_tbl);
         po_log.proc_begin(d_mod, 'p_contractor_last_name_tbl', p_contractor_last_name_tbl);
         po_log.proc_begin(d_mod, 'p_contractor_first_name_tbl', p_contractor_first_name_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF (p_purchase_basis_tbl(i) <> 'TEMP LABOR'
             OR p_doc_type <> 'STANDARD')
            AND (p_contractor_last_name_tbl(i) IS NOT NULL
              OR p_contractor_first_name_tbl(i) IS NOT NULL) THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'CONTRACTOR FIRST/LAST NAME',
                                 p_column_val        => p_contractor_last_name_tbl(i),
                                 p_message_name      => 'PO_PDOI_SVC_NO_NAME',
                                 p_validation_id     => PO_VAL_CONSTANTS.c_contractor_name);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END contractor_name;

-------------------------------------------------------------------------
-- If purchase basis is TEMP LABOR, then job id must not be null
-------------------------------------------------------------------------
   PROCEDURE job_id(
      p_id_tbl                      IN              po_tbl_number,
      p_job_id_tbl                  IN              po_tbl_number,
      p_job_business_group_id_tbl   IN              po_tbl_number,
      p_purchase_basis_tbl          IN              po_tbl_varchar30,
      p_category_id_tbl             IN              po_tbl_number,
      x_result_set_id               IN OUT NOCOPY   NUMBER,
      x_results                     IN OUT NOCOPY   po_validation_results_type,
      x_result_type                 OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_job_id;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_job_id_tbl', p_job_id_tbl);
         po_log.proc_begin(d_mod, 'p_job_business_group_id_tbl', p_job_business_group_id_tbl);
         po_log.proc_begin(d_mod, 'p_purchase_basis_tbl', p_purchase_basis_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_purchase_basis_tbl(i) <> 'TEMP LABOR' AND p_job_id_tbl(i) IS NOT NULL THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'JOB_ID',
                                 p_column_val        => p_job_id_tbl(i),
                                 p_message_name      => 'PO_PDOI_SVC_NO_JOB',
                                 p_validation_id     => PO_VAL_CONSTANTS.c_job_id_null );
            x_result_type := po_validations.c_result_type_failure;
         ELSIF p_purchase_basis_tbl(i) = 'TEMP LABOR' AND p_job_id_tbl(i) IS NULL THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'JOB_ID',
                                 p_column_val        => p_job_id_tbl(i),
                                 p_message_name      => 'PO_PDOI_SVC_MUST_JOB',
                                 p_validation_id     => PO_VAL_CONSTANTS.c_job_id_not_null );
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      --check that job_id is valid within the relevant business group.
      IF NVL(hr_general.get_xbg_profile, 'N') = 'N' THEN
         -- xbg profile is N or job business_group_id is null
         FORALL i IN 1 .. p_id_tbl.COUNT
            INSERT INTO po_validation_results_gt
                        (result_set_id,
                         result_type,
                         entity_type,
                         entity_id,
                         message_name,
                         column_name,
                         column_val,
                         token1_name,
                         token1_value,
                         token2_name,
                         token2_value,
                         validation_id)
               SELECT x_result_set_id,
                      po_validations.c_result_type_failure,
                      c_entity_type_line,
                      p_id_tbl(i),
                      'PO_PDOI_SVC_INVALID_JOB',
                      'JOB_ID',
                      p_job_id_tbl(i),
                      'JOB_ID',
                      p_job_id_tbl(i),
                      'JOB_BG_ID',
                      p_job_business_group_id_tbl(i),
                      PO_VAL_CONSTANTS.c_job_id_valid
                 FROM DUAL
                WHERE p_purchase_basis_tbl(i) = 'TEMP LABOR'
                  AND NOT EXISTS(
                         SELECT 1
                           FROM per_jobs_vl pj, financials_system_parameters fsp
                          WHERE pj.job_id = p_job_id_tbl(i)
                            AND pj.business_group_id = fsp.business_group_id
                            AND fsp.business_group_id = NVL(p_job_business_group_id_tbl(i),
                                                            fsp.business_group_id)
                            AND TRUNC(SYSDATE) BETWEEN NVL(TRUNC(pj.date_from),
                                                           TRUNC(SYSDATE))
                                                       AND NVL(TRUNC(pj.date_to),
                                                               TRUNC(SYSDATE)));

         IF (SQL%ROWCOUNT > 0) THEN
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      ELSE
         -- Cross Business group profile is 'Y'
         FORALL i IN 1 .. p_id_tbl.COUNT
            INSERT INTO po_validation_results_gt
                        (result_set_id,
                         result_type,
                         entity_type,
                         entity_id,
                         message_name,
                         column_name,
                         column_val,
                         token1_name,
                         token1_value,
                         token2_name,
                         token2_value,
                         validation_id)
               SELECT x_result_set_id,
                      po_validations.c_result_type_failure,
                      c_entity_type_line,
                      p_id_tbl(i),
                      'PO_PDOI_SVC_INVALID_JOB',
                      'JOB_ID',
                      p_job_id_tbl(i),
                      'JOB_ID',
                      p_job_id_tbl(i),
                      'JOB_BG_ID',
                      p_job_business_group_id_tbl(i),
                      PO_VAL_CONSTANTS.c_job_id_valid
                 FROM DUAL
                WHERE p_job_business_group_id_tbl(i) IS NOT NULL
                  AND p_purchase_basis_tbl(i) = 'TEMP LABOR'
                  AND NOT EXISTS(
                         SELECT 1
                           FROM per_jobs_vl pj, per_business_groups_perf pbg
                          WHERE pj.job_id = p_job_id_tbl(i)
                            AND pj.business_group_id = p_job_business_group_id_tbl(i)
                            AND pj.business_group_id = pbg.business_group_id
                            AND TRUNC(SYSDATE) BETWEEN NVL(TRUNC(pj.date_from),
                                                           TRUNC(SYSDATE))
                                                           AND NVL(TRUNC(pj.date_to),
                                                                   TRUNC(SYSDATE))
                            AND TRUNC(SYSDATE) BETWEEN NVL(TRUNC(pbg.date_from),
                                                           TRUNC(SYSDATE))
                                                   AND NVL(TRUNC(pbg.date_to),
                                                           TRUNC(SYSDATE)));
           IF (SQL%ROWCOUNT > 0) THEN
             x_result_type := po_validations.c_result_type_failure;
           END IF;
         END IF;

         -- job must be valid for the specified category
         FORALL i IN 1 .. p_id_tbl.COUNT
           INSERT INTO po_validation_results_gt
                       (result_set_id,
                        result_type,
                        entity_type,
                        entity_id,
                        message_name,
                        column_name,
                        column_val,
                        validation_id)
               SELECT x_result_set_id,
                      po_validations.c_result_type_failure,
                      c_entity_type_line,
                      p_id_tbl(i),
                      'PO_PDOI_SVC_INVALID_JOB_CAT',
                      'JOB_ID',
                      p_job_id_tbl(i),
                      PO_VAL_CONSTANTS.c_job_id_valid_cat
                 FROM DUAL
                WHERE p_purchase_basis_tbl(i) = 'TEMP LABOR'
                  AND p_category_id_tbl(i) IS NOT NULL
                  AND NOT EXISTS(
                         SELECT 1
                           FROM po_job_associations_b pja, per_jobs_vl pj
                          WHERE pja.job_id = p_job_id_tbl(i)
                            AND pja.category_id = p_category_id_tbl(i)
                            AND pja.job_id = pj.job_id
                            AND NVL(TRUNC(pja.inactive_date), TRUNC(sysdate)) >= TRUNC(sysdate)
                            AND TRUNC(SYSDATE) BETWEEN NVL(TRUNC(pj.date_from), TRUNC(SYSDATE))
                                               AND NVL(TRUNC(pj.date_to), TRUNC(SYSDATE)));

      IF (SQL%ROWCOUNT > 0) THEN
        x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END job_id;

-------------------------------------------------------------------------
-- If services procurement not enabled, order_type_lookup_code cannot be
-- 'FIXED PRICE' or 'RATE'
-------------------------------------------------------------------------
   PROCEDURE job_business_group_id(
      p_id_tbl                      IN              po_tbl_number,
      p_job_id_tbl                  IN              po_tbl_number,
      p_job_business_group_id_tbl   IN              po_tbl_number,
      p_purchase_basis_tbl          IN              po_tbl_varchar30,
      x_result_set_id               IN OUT NOCOPY   NUMBER,
      x_result_type                 OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_job_business_group_id;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_job_id_tbl', p_job_id_tbl);
         po_log.proc_begin(d_mod, 'p_job_business_group_id_tbl', p_job_business_group_id_tbl);
         po_log.proc_begin(d_mod, 'p_purchase_basis_tbl', p_purchase_basis_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      IF NVL(hr_general.get_xbg_profile, 'N') = 'N' THEN
         -- xbg profile is N but job_business_group_id not in FSP
         FORALL i IN 1 .. p_id_tbl.COUNT
            INSERT INTO po_validation_results_gt
                        (result_set_id,
                         result_type,
                         entity_type,
                         entity_id,
                         message_name,
                         column_name,
                         column_val,
                         validation_id)
               SELECT x_result_set_id,
                      po_validations.c_result_type_failure,
                      c_entity_type_line,
                      p_id_tbl(i),
                      'PO_PDOI_SVC_CANNOT_CROSS_BG',
                      'JOB_BUSINESS_GROUP_ID',
                      p_job_business_group_id_tbl(i),
                      PO_VAL_CONSTANTS.c_job_bg_id_not_cross_bg
                 FROM DUAL
                WHERE p_job_business_group_id_tbl(i) IS NOT NULL
                  AND p_purchase_basis_tbl(i) = 'TEMP LABOR'
                  AND NOT EXISTS(SELECT 1
                                   FROM financials_system_parameters fsp
                                  WHERE fsp.business_group_id = p_job_business_group_id_tbl(i));

         IF (SQL%ROWCOUNT > 0) THEN
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      ELSE
         -- Cross Business group profile is 'Y', need to validate job business group id
         FORALL i IN 1 .. p_id_tbl.COUNT
            INSERT INTO po_validation_results_gt
                        (result_set_id,
                         result_type,
                         entity_type,
                         entity_id,
                         message_name,
                         column_name,
                         column_val,
                         validation_id)
               SELECT x_result_set_id,
                      po_validations.c_result_type_failure,
                      c_entity_type_line,
                      p_id_tbl(i),
                      'PO_PDOI_SVC_INVALID_BG',
                      'JOB_BUSINESS_GROUP_ID',
                      p_job_business_group_id_tbl(i),
                      PO_VAL_CONSTANTS.c_job_business_group_id_valid
                 FROM DUAL
                WHERE p_job_business_group_id_tbl(i) IS NOT NULL
                  AND p_purchase_basis_tbl(i) = 'TEMP LABOR'
                  AND NOT EXISTS(
                         SELECT 1
                           FROM per_business_groups_perf pbg
                          WHERE pbg.business_group_id = p_job_business_group_id_tbl(i)
                            AND TRUNC(SYSDATE) BETWEEN NVL(TRUNC(pbg.date_from), TRUNC(SYSDATE))
                                                   AND NVL(TRUNC(pbg.date_to), TRUNC(SYSDATE)));

         IF (SQL%ROWCOUNT > 0) THEN
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END job_business_group_id;

-------------------------------------------------------------------------
-- If purchase_basis = 'TEMP LABOR', then capital_expense_flag cannot = 'Y'
-------------------------------------------------------------------------
   PROCEDURE capital_expense_flag(
      p_id_tbl                     IN              po_tbl_number,
      p_purchase_basis_tbl         IN              po_tbl_varchar30,
      p_capital_expense_flag_tbl   IN              po_tbl_varchar1,
      x_results                    IN OUT NOCOPY   po_validation_results_type,
      x_result_type                OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_capital_expense_flag;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_purchase_basis_tbl', p_purchase_basis_tbl);
         po_log.proc_begin(d_mod, 'p_capital_expense_flag_tbl', p_capital_expense_flag_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_purchase_basis_tbl(i) = 'TEMP LABOR' AND p_capital_expense_flag_tbl(i) = 'Y' THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'CAPITAL_EXPENSE_FLAG',
                                 p_column_val        => p_capital_expense_flag_tbl(i),
                                 p_message_name      => 'PO_SVC_NO_CAP_EXPENSE',
                 p_validation_id     => PO_VAL_CONSTANTS.c_capital_expense_flag_null);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END capital_expense_flag;

-------------------------------------------------------------------------
-- If purchase_basis = 'TEMP LABOR', then un_number must be null
-------------------------------------------------------------------------
   PROCEDURE un_number_id(
      p_id_tbl               IN              po_tbl_number,
      p_purchase_basis_tbl   IN              po_tbl_varchar30,
      p_un_number_id_tbl     IN              po_tbl_number,
      x_result_set_id        IN OUT NOCOPY   NUMBER,
      x_results              IN OUT NOCOPY   po_validation_results_type,
      x_result_type          OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_un_number_id;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_purchase_basis_tbl', p_purchase_basis_tbl);
         po_log.proc_begin(d_mod, 'p_un_number_id_tbl', p_un_number_id_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_purchase_basis_tbl(i) = 'TEMP LABOR' AND p_un_number_id_tbl(i) IS NOT NULL THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'UN_NUMBER',
                                 p_column_val        => p_un_number_id_tbl(i),
                                 p_message_name      => 'PO_PDOI_SVC_NO_UNNUMBER',
                 p_validation_id     => PO_VAL_CONSTANTS.c_un_number_id_null);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
                      validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_UN_NUMBER_ID',
                   'UN_NUMBER_ID',
                   p_un_number_id_tbl(i),
                   'VALUE',
                   p_un_number_id_tbl(i),
                   PO_VAL_CONSTANTS.c_un_number_id_valid
              FROM DUAL
             WHERE p_un_number_id_tbl(i) IS NOT NULL
               AND p_purchase_basis_tbl(i) <> 'TEMP LABOR'
               AND NOT EXISTS(SELECT 1
                                FROM po_un_numbers_val_v pun
                               WHERE pun.un_number_id = p_un_number_id_tbl(i));

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END un_number_id;

-------------------------------------------------------------------------
-- If purchase_basis = 'TEMP LABOR', then un_number must be null
-------------------------------------------------------------------------
   PROCEDURE hazard_class_id(
      p_id_tbl                IN              po_tbl_number,
      p_purchase_basis_tbl    IN              po_tbl_varchar30,
      p_hazard_class_id_tbl   IN              po_tbl_number,
      x_result_set_id         IN OUT NOCOPY   NUMBER,
      x_results               IN OUT NOCOPY   po_validation_results_type,
      x_result_type           OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_hazard_class_id;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_purchase_basis_tbl', p_purchase_basis_tbl);
         po_log.proc_begin(d_mod, 'p_hazard_class_id_tbl', p_hazard_class_id_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_purchase_basis_tbl(i) = 'TEMP LABOR' AND p_hazard_class_id_tbl(i) IS NOT NULL THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'HAZARD_CLASS',
                                 p_column_val        => p_hazard_class_id_tbl(i),
                                 p_message_name      => 'PO_PDOI_SVC_NO_HAZARD_CLASS',
                 p_validation_id     => PO_VAL_CONSTANTS.c_hazard_class_id_null );
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
                      validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_HAZ_ID',
                   'HAZARD_CLASS_ID',
                   p_hazard_class_id_tbl(i),
                   'VALUE',
                   p_hazard_class_id_tbl(i),
                   PO_VAL_CONSTANTS.c_hazard_class_id_valid
              FROM DUAL
             WHERE p_hazard_class_id_tbl(i) IS NOT NULL
               AND p_purchase_basis_tbl(i) <> 'TEMP LABOR'
               AND NOT EXISTS(SELECT 'Y'
                                FROM po_hazard_classes_val_v phc
                               WHERE phc.hazard_class_id = p_hazard_class_id_tbl(i));

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END hazard_class_id;

-------------------------------------------------------------------------
-- If order_type_lookup_code is 'FIXED PRICE', 'RATE', or 'AMOUNT', item_id has to be null
-------------------------------------------------------------------------
   PROCEDURE item_id(
      p_id_tbl                       IN              po_tbl_number,
      p_item_id_tbl                  IN              po_tbl_number,
      p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
      p_line_type_id_tbl             IN              po_tbl_number,
      p_inventory_org_id             IN              NUMBER,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_item_id;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_item_id_tbl', p_item_id_tbl);
         po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'p_line_type_id_tbl', p_line_type_id_tbl);
         po_log.proc_begin(d_mod, 'p_inventory_org_id', p_inventory_org_id);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF (p_order_type_lookup_code_tbl(i) = 'FIXED PRICE' OR p_order_type_lookup_code_tbl(i) = 'RATE')
            AND p_item_id_tbl(i) IS NOT NULL THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'ITEM_ID',
                                 p_column_val        => p_item_id_tbl(i),
                                 p_message_name      => 'PO_PDOI_COLUMN_NULL',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'ITEM_ID',
                                 p_validation_id     => PO_VAL_CONSTANTS.c_item_id_null);
            x_result_type := po_validations.c_result_type_failure;
         ELSIF p_order_type_lookup_code_tbl(i) = 'AMOUNT' AND p_item_id_tbl(i) IS NOT NULL THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'ITEM_ID',
                                 p_column_val        => p_item_id_tbl(i),
                                 p_message_name      => 'PO_PDOI_COLUMN_NULL',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'ITEM_ID',
                                 p_validation_id     => PO_VAL_CONSTANTS.c_item_id_null);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      -- If order_type_lookup_code is Quantity and outside_operation flag is 'Y'
      -- , then the item_id cannot be null
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_ITEM_NOT_NULL',
                   'ITEM_ID',
                   p_item_id_tbl(i),
                   PO_VAL_CONSTANTS.c_item_id_not_null
              FROM DUAL
             WHERE p_order_type_lookup_code_tbl(i) = 'QUANTITY'
               AND p_item_id_tbl(i) IS NULL
               AND EXISTS(
                      SELECT 1
                        FROM po_line_types_b plt
                       WHERE p_line_type_id_tbl(i) IS NOT NULL
                         AND p_line_type_id_tbl(i) = plt.line_type_id
                         AND plt.outside_operation_flag = 'Y');

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      -- if item id is not null, it has to exist in mtl_system_items table
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
                      validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   DECODE(plt.outside_operation_flag, 'N', 'PO_PDOI_INVALID_ITEM_ID', 'PO_PDOI_INVALID_OP_ITEM_ID'),
                   'ITEM_ID',
                   p_item_id_tbl(i),
                   'VALUE',
                   p_item_id_tbl(i),
                   DECODE(plt.outside_operation_flag, 'N', PO_VAL_CONSTANTS.c_item_id_valid,
                          PO_VAL_CONSTANTS.c_item_id_op_valid)
              FROM po_line_types_b plt
             WHERE p_item_id_tbl(i) IS NOT NULL
               AND p_line_type_id_tbl(i) IS NOT NULL
               AND p_line_type_id_tbl(i) = plt.line_type_id
               AND plt.outside_operation_flag IS NOT NULL
               AND NOT EXISTS(
                      SELECT 1
                        FROM mtl_system_items msi
                       WHERE msi.inventory_item_id = p_item_id_tbl(i)
                         AND msi.organization_id = p_inventory_org_id
                         AND msi.enabled_flag = 'Y'
                         AND msi.purchasing_item_flag = 'Y'
                         AND msi.purchasing_enabled_flag = 'Y'
                         AND msi.outside_operation_flag = plt.outside_operation_flag
                         AND TRUNC(NVL(msi.start_date_active, SYSDATE)) <= TRUNC(SYSDATE)
                         AND TRUNC(NVL(msi.end_date_active, SYSDATE)) >= TRUNC(SYSDATE));

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END item_id;

-------------------------------------------------------------------------
-- Make sure that the item_description is populated, and also need to find out if it is different
-- from what is setup for the item. Would not allow item_description update  if item attribute
-- allow_item_desc_update_flag is N.
-------------------------------------------------------------------------
   PROCEDURE item_description(
      p_id_tbl                       IN              po_tbl_number,
      p_item_description_tbl         IN              po_tbl_varchar2000,
      p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
      p_item_id_tbl                  IN              po_tbl_number,
      p_create_or_update_item        IN              VARCHAR2,
      p_inventory_org_id             IN              NUMBER,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_item_description;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_item_description_tbl', p_item_description_tbl);
         po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'p_item_id_tbl', p_item_id_tbl);
         po_log.proc_begin(d_mod, 'p_create_or_update_item', p_create_or_update_item);
         po_log.proc_begin(d_mod, 'p_inventory_org_id', p_inventory_org_id);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

/* Bug 5366732 Modified the inner query to select item description from mtl_system_items_tl instead of from mtl_system_items */
      x_result_type := po_validations.c_result_type_success;
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
                      validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   DECODE(p_item_description_tbl(i), NULL, 'PO_PDOI_COLUMN_NOT_NULL', 'PO_PDOI_DIFF_ITEM_DESC'),
                   'ITEM_DESCRIPTION',
                   p_item_description_tbl(i),
                   DECODE(p_item_description_tbl(i), NULL, 'COLUMN_NAME', NULL),
                   DECODE(p_item_description_tbl(i), NULL, 'ITEM_DESCRIPTION', NULL),
                   DECODE(p_item_description_tbl(i), NULL, PO_VAL_CONSTANTS.c_item_desc_not_null,
                          PO_VAL_CONSTANTS.c_item_desc_not_updatable)
              FROM DUAL
             WHERE p_item_description_tbl(i) IS NULL
                OR (    p_order_type_lookup_code_tbl(i) NOT IN('RATE', 'FIXED PRICE')
                    AND p_item_id_tbl(i) IS NOT NULL
                    AND EXISTS(
		    SELECT 1 FROM
		    mtl_system_items msi,mtl_system_items_tl mtl
		              where msi.inventory_item_id = p_item_id_tbl(i) AND
			      mtl.inventory_item_id = msi.inventory_item_id
                              AND msi.organization_id = p_inventory_org_id
			      AND mtl.organization_id = msi.organization_id
                              AND msi.allow_item_desc_update_flag = 'N'
			      and mtl.language = USERENV('LANG')
			      AND p_item_description_tbl(i) <> mtl.description
			      AND p_create_or_update_item = 'N'));





      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END item_description;

-------------------------------------------------------------------------
-- check to see if x_item_unit_of_measure is valid in mtl_item_uoms_view
-------------------------------------------------------------------------
   PROCEDURE unit_meas_lookup_code(
      p_id_tbl                       IN              po_tbl_number,
      p_unit_meas_lookup_code_tbl    IN              po_tbl_varchar30,
      p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
      p_item_id_tbl                  IN              po_tbl_number,
      p_line_type_id_tbl             IN              po_tbl_number,
      p_inventory_org_id             IN              NUMBER,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_unit_meas_lookup_code;
    l_service_uom_class VARCHAR2(2000);
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_unit_meas_lookup_code_tbl', p_unit_meas_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'p_item_id_tbl', p_item_id_tbl);
         po_log.proc_begin(d_mod, 'p_line_type_id_tbl', p_line_type_id_tbl);
         po_log.proc_begin(d_mod, 'p_inventory_org_id', p_inventory_org_id);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- If order_type_lookup_code is 'FIXED PRICE', unit_meas_lookup_code has
      -- to be null. Otherwise, it cannot be null.
      FOR i IN 1 .. p_id_tbl.COUNT LOOP

         -- <<PDOI Enhancement Bug#17063664>>
         -- Unable to create Fixed Price lines due to validation PO_PDOI_SVC_NO_UOM
         -- Removed this as it is incorrect.

         IF (p_order_type_lookup_code_tbl(i) <> 'FIXED PRICE' AND p_unit_meas_lookup_code_tbl(i) IS NULL) THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'UNIT_MEAS_LOOKUP_CODE',
                                 p_column_val        => p_unit_meas_lookup_code_tbl(i),
                                 p_message_name      => 'PO_PDOI_COLUMN_NOT_NULL',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'UNIT_MEAS_LOOKUP_CODE',
                 p_validation_id     => PO_VAL_CONSTANTS.c_unit_meas_lookup_not_null);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,  -- bug5252804
                      token1_name,
                      token2_name,
                      token3_name,
                      token1_value,
                      token2_value,
                      token3_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_ITEM_RELATED_INFO',
                   'UNIT_MEAS_LOOKUP_CODE',
                   p_unit_meas_lookup_code_tbl(i),  -- bug5252804
                   'COLUMN_NAME',
                   'VALUE',
                   'ITEM',
                   'UNIT_MEAS_LOOKUP_CODE',
                   p_unit_meas_lookup_code_tbl(i),
                   p_item_id_tbl(i),
                   PO_VAL_CONSTANTS.c_unit_meas_lookup_item
              FROM DUAL
             WHERE p_order_type_lookup_code_tbl(i) NOT IN('RATE', 'FIXED PRICE')
               AND p_item_id_tbl(i) IS NOT NULL
               AND p_unit_meas_lookup_code_tbl(i) IS NOT NULL
               AND NOT EXISTS(
                      SELECT 1
                        FROM mtl_item_uoms_view miuv
                       WHERE miuv.inventory_item_id = p_item_id_tbl(i)
                         AND miuv.organization_id = p_inventory_org_id
                         AND miuv.unit_of_measure = p_unit_meas_lookup_code_tbl(i));

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;


      -- check to see if x_uom_code is valid in po_units_of_measure_val_v
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_UOM_CODE',
                   'UNIT_MEAS_LOOKUP_CODE',
                   p_unit_meas_lookup_code_tbl(i),
                   'VALUE',
                   p_unit_meas_lookup_code_tbl(i),
                   PO_VAL_CONSTANTS.c_unit_meas_lookup_valid
              FROM DUAL
             WHERE p_order_type_lookup_code_tbl(i) NOT IN('RATE', 'FIXED PRICE')
               AND p_item_id_tbl(i) IS NULL
               AND p_unit_meas_lookup_code_tbl(i) IS NOT NULL
               AND NOT EXISTS(SELECT 1
                                FROM po_units_of_measure_val_v pumv
                               WHERE pumv.unit_of_measure = p_unit_meas_lookup_code_tbl(i));

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;


      -- validation for AMOUNT based line type
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token2_name,
                      token3_name,
                      token1_value,
                      token2_value,
                      token3_value,
                      validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_LINE_TYPE_INFO',
                   'UNIT_MEAS_LOOKUP_CODE',
                   p_unit_meas_lookup_code_tbl(i),
                   'COLUMN_NAME',
                   'VALUE',
                   'LINE_TYPE',
                   'UNIT_MEAS_LOOKUP_CODE',
                   p_unit_meas_lookup_code_tbl(i),
                   pltb.unit_of_measure,
                   PO_VAL_CONSTANTS.c_unit_meas_lookup_line_type
              FROM PO_LINE_TYPES_B pltb
             WHERE pltb.line_type_id = p_line_type_id_tbl(i)
               AND p_order_type_lookup_code_tbl(i) = 'AMOUNT'
               AND p_unit_meas_lookup_code_tbl(i) <> pltb.unit_of_measure;

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;


      -- validation for 'RATE' based line
      l_service_uom_class := NVL(FND_PROFILE.value('PO_RATE_UOM_CLASS'), '999');
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token2_name,
                      token1_value,
                      token2_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_SVC_INVALID_UOM',
                   'UNIT_MEAS_LOOKUP_CODE',
                   p_unit_meas_lookup_code_tbl(i),
                   'COLUMN_NAME',
                   'VALUE',
                   'UNIT_MEAS_LOOKUP_CODE',
                   p_unit_meas_lookup_code_tbl(i),
                   PO_VAL_CONSTANTS.c_unit_meas_lookup_svc_valid
              FROM DUAL
             WHERE p_order_type_lookup_code_tbl(i) = 'RATE'
               AND NOT EXISTS(SELECT 1
                                FROM mtl_units_of_measure_vl muomv
                               WHERE muomv.uom_class = l_service_uom_class
                                 AND muomv.unit_of_measure = p_unit_meas_lookup_code_tbl(i)
                 AND TRUNC(sysdate) < NVL(muomv.disable_date, TRUNC(sysdate) + 1));

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;


      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END unit_meas_lookup_code;

-------------------------------------------------------------------------
--  If order_type_lookup_code is FIXED PRICE or RATE, or item id is null, then item revision has to
--  be NULL. Check to see if there are x_item_revision exists in mtl_item_revisions table
-------------------------------------------------------------------------
   PROCEDURE item_revision(
      p_id_tbl                       IN              po_tbl_number,
      p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
      p_item_revision_tbl            IN              po_tbl_varchar5,
      p_item_id_tbl                  IN              po_tbl_number,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_item_revision;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'p_item_revision_tbl', p_item_revision_tbl);
         po_log.proc_begin(d_mod, 'p_item_id_tbl', p_item_id_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- if order_type_lookup_code is FIXED PRICE or RATE, or item id is null,
      -- then item revision has to be NULL
      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF (((p_order_type_lookup_code_tbl(i) = 'RATE'
               OR p_order_type_lookup_code_tbl(i) = 'FIXED PRICE')
            OR p_item_id_tbl(i) IS NULL) AND p_item_revision_tbl(i) IS NOT NULL) THEN
            x_results.add_result(p_entity_type     => c_entity_type_line,
                                 p_entity_id       => p_id_tbl(i),
                                 p_column_name     => 'ITEM_REVISION',
                                 p_column_val      => p_item_revision_tbl(i),
                                 p_message_name    => 'PO_PDOI_COLUMN_NULL',
                 p_validation_id   => PO_VAL_CONSTANTS.c_item_revision_null);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      -- check to see if there are x_item_revision exists in mtl_item_revisions
      -- table
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token2_name,
                      token3_name,
                      token1_value,
                      token2_value,
                      token3_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_ITEM_RELATED_INFO',
                   'ITEM_REVISION',
                   p_item_revision_tbl(i),
                   'COLUMN_NAME',
                   'VALUE',
                   'ITEM',
                   'item_revision',
                   p_item_revision_tbl(i),
                   p_item_id_tbl(i),
                   PO_VAL_CONSTANTS.c_item_revision_item
              FROM DUAL
             WHERE p_order_type_lookup_code_tbl(i) NOT IN('RATE', 'FIXED PRICE')
               AND p_item_revision_tbl(i) IS NOT NULL
               AND p_item_id_tbl(i) IS NOT NULL
               AND NOT EXISTS(SELECT 1
                                FROM mtl_item_revisions mir
                               WHERE mir.inventory_item_id = p_item_id_tbl(i)
                                 AND mir.revision = p_item_revision_tbl(i));

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END item_revision;

-------------------------------------------------------------------------
-- Validate and make sure category_id is a valid category within the default category set for Purchasing.
-- Validate if X_category_id belong to the X_item.  Check if the Purchasing Category set has
-- 'Validate flag' ON. If Yes, we will validate the Category to exist in the 'Valid Category List'.
-- If No, we will just validate if the category is Enable and Active.
-------------------------------------------------------------------------
   PROCEDURE category_id(
      p_id_tbl                       IN              po_tbl_number,
      p_category_id_tbl              IN              po_tbl_number,
      p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
      p_item_id_tbl                  IN              po_tbl_number,
      p_inventory_org_id             IN              NUMBER,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_category_id;
      x_flag mtl_category_sets_v.validate_flag%TYPE;
      x_category_set_id mtl_category_sets_v.category_set_id%TYPE;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_category_id_tbl', p_category_id_tbl);
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'p_item_id_tbl', p_item_id_tbl);
         po_log.proc_begin(d_mod, 'p_inventory_org_id', p_inventory_org_id);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- Find out the default category_set_id and  flag for function_area
      -- of PURCHASING".
      SELECT validate_flag,
             category_set_id
        INTO x_flag,
             x_category_set_id
        FROM mtl_category_sets_v
       WHERE category_set_id = (SELECT category_set_id
                                  FROM mtl_default_category_sets
                                 WHERE functional_area_id = 2); /*** purchasing***/

      -- Validate if X_category_id belong to the X_item
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
                      token2_name,
                      token2_value,
                      token3_name,
                      token3_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_ITEM_RELATED_INFO',
                   'CATEGORY_ID',
                   p_category_id_tbl(i),
                   'COLUMN_NAME',
                   'CATEGORY_ID',
                   'VALUE',
                   p_category_id_tbl(i),
                   'ITEM',
                   p_item_id_tbl(i),
                   PO_VAL_CONSTANTS.c_category_id_item
              FROM DUAL
             WHERE p_order_type_lookup_code_tbl(i) NOT IN('FIXED PRICE', 'RATE')
               AND p_item_id_tbl(i) IS NOT NULL
               AND p_category_id_tbl(i) IS NOT NULL
               AND NOT EXISTS(
                      SELECT 1
                        FROM mtl_item_categories mic, mtl_categories mcs
                       WHERE mic.category_id = mcs.category_id
                         AND mic.category_set_id = x_category_set_id
                         AND mic.category_id = p_category_id_tbl(i)
                         AND mic.inventory_item_id = p_item_id_tbl(i)
                         AND mic.organization_id = p_inventory_org_id
                         AND SYSDATE < NVL(mcs.disable_date, SYSDATE + 1)
                         AND mcs.enabled_flag = 'Y');

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF x_flag = 'Y' THEN
         FORALL i IN 1 .. p_id_tbl.COUNT
            INSERT INTO po_validation_results_gt
                        (result_set_id,
                         result_type,
                         entity_type,
                         entity_id,
                         message_name,
                         column_name,
                         column_val,
                         token1_name,
                         token1_value,
             validation_id)
               SELECT x_result_set_id,
                      po_validations.c_result_type_failure,
                      c_entity_type_line,
                      p_id_tbl(i),
                      'PO_PDOI_INVALID_CATEGORY_ID',
                      'CATEGORY_ID',
                      p_category_id_tbl(i),
                      'VALUE',
                      p_category_id_tbl(i),
                      PO_VAL_CONSTANTS.c_category_id_valid
                 FROM DUAL
                WHERE p_order_type_lookup_code_tbl(i) NOT IN('FIXED PRICE', 'RATE')
                  AND p_item_id_tbl(i) IS NULL
                  AND p_category_id_tbl(i) IS NOT NULL
                  AND NOT EXISTS(
                         SELECT 'Y'
                           FROM mtl_categories_vl mcs, mtl_category_set_valid_cats mcsvc
                          WHERE mcs.category_id = p_category_id_tbl(i)
                            AND mcs.category_id = mcsvc.category_id
                            AND mcsvc.category_set_id = x_category_set_id
                            AND SYSDATE < NVL(mcs.disable_date, SYSDATE + 1)
                            AND mcs.enabled_flag = 'Y');

         -- bug5111418
         -- fail the record if this validation fails
         IF (SQL%ROWCOUNT > 0) THEN
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      ELSE
         FORALL i IN 1 .. p_id_tbl.COUNT
            INSERT INTO po_validation_results_gt
                        (result_set_id,
                         result_type,
                         entity_type,
                         entity_id,
                         message_name,
                         column_name,
                         column_val,
                         token1_name,
                         token1_value,
             validation_id)
               SELECT x_result_set_id,
                      po_validations.c_result_type_failure,
                      c_entity_type_line,
                      p_id_tbl(i),
                      'PO_PDOI_INVALID_CATEGORY_ID',
                      'CATEGORY_ID',
                      p_category_id_tbl(i),
                      'VALUE',
                      p_category_id_tbl(i),
                      PO_VAL_CONSTANTS.c_category_id_valid
                 FROM DUAL
                WHERE p_order_type_lookup_code_tbl(i) NOT IN('FIXED PRICE', 'RATE')
                  AND p_item_id_tbl(i) IS NULL
                  AND p_category_id_tbl(i) IS NOT NULL
                  AND NOT EXISTS(
                         SELECT 1
                           FROM mtl_categories_vl mcs
                          WHERE mcs.category_id = p_category_id_tbl(i)
                            AND SYSDATE < NVL(mcs.disable_date, SYSDATE + 1)
                            AND mcs.enabled_flag = 'Y');

         IF (SQL%ROWCOUNT > 0) THEN
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END category_id;

-------------------------------------------------------------------------
-- Validate ip_category_id is not empty for Blanket and Quotation;
-- Validate ip_category_id is valid if not empty
-------------------------------------------------------------------------
   PROCEDURE ip_category_id(
      p_id_tbl                       IN              po_tbl_number,
      p_ip_category_id_tbl           IN              po_tbl_number,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_ip_category_id;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_ip_category_id_tbl', p_ip_category_id_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
      -- validate ip_category_id is not null
      po_validation_helper.not_null(p_calling_module      => c_program_pdoi,
                                    p_value_tbl           => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_ip_category_id_tbl),
                                    p_entity_id_tbl       => p_id_tbl,
                                    p_entity_type         => c_entity_type_line,
                                    p_column_name         => 'IP_CATEGORY_ID',
                                    p_message_name        => 'PO_PDOI_COLUMN_NOT_NULL',
                                    p_token1_name         => 'COLUMN_NAME',
                                    p_token1_value        => 'IP_CATEGORY_ID',
                                    p_token2_name         => 'VALUE',
                                    p_token2_value_tbl    => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_ip_category_id_tbl),
                                    p_validation_id       => PO_VAL_CONSTANTS.c_ip_category_id_not_null,
                                    x_results             => x_results,
                                    x_result_type         => x_result_type);

      -- Validate if x_category_id is valid if not empty
      FORALL i IN 1 .. p_id_tbl.COUNT
        INSERT INTO po_validation_results_gt
                    (result_set_id,
                     result_type,
                     entity_type,
                     entity_id,
                     message_name,
                     column_name,
                     column_val,
                     token1_name,
                     token1_value,
           validation_id)
           SELECT x_result_set_id,
                  po_validations.c_result_type_failure,
                  c_entity_type_line,
                  p_id_tbl(i),
                  'PO_PDOI_INVALID_IP_CATEGORY_ID',
                  'IP_CATEGORY_ID',
                  p_ip_category_id_tbl(i),
                  'VALUE',
                  p_ip_category_id_tbl(i),
                  PO_VAL_CONSTANTS.c_ip_category_id_valid
           FROM DUAL
           WHERE p_ip_category_id_tbl(i) IS NOT NULL
           AND   p_ip_category_id_tbl(i) <> -2
       AND   NOT EXISTS(
                  SELECT 'Y'
                  FROM icx_cat_categories_v
                  WHERE rt_category_id = p_ip_category_id_tbl(i));

      IF (SQL%ROWCOUNT > 0) THEN
        x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END ip_category_id;

-------------------------------------------------------------------------
--If order_type_lookup_code is not  'FIXED PRICE', unit_price cannot be null
--  and cannot be less than zero.
--If line_type_id is not null and order_type_lookup_code is 'AMOUNT',
-- unit_price should be the same as the one defined in the line_type.
--If order_type_lookup_code is 'FIXED PRICE', unit_price has to be null.
-------------------------------------------------------------------------
   PROCEDURE unit_price(
      p_id_tbl                       IN              po_tbl_number,
      p_unit_price_tbl               IN              po_tbl_number,
      p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
      p_line_type_id_tbl             IN              po_tbl_number,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_unit_price;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_unit_price_tbl', p_unit_price_tbl);
         po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'p_line_type_id_tbl', p_line_type_id_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
      -- If order_type_lookup_code is not 'FIXED PRICE', unit_price cannot be
      -- null and cannot be less than zero.
      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_order_type_lookup_code_tbl(i) <> 'FIXED PRICE' AND p_unit_price_tbl(i) IS NULL THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'UNIT_PRICE',
                                 p_column_val        => p_unit_price_tbl(i),
                                 p_message_name      => 'PO_PDOI_COLUMN_NOT_NULL',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'UNIT_PRICE',
                 p_validation_id     => PO_VAL_CONSTANTS.c_unit_price_not_null);
            x_result_type := po_validations.c_result_type_failure;
         ELSIF p_order_type_lookup_code_tbl(i) <> 'FIXED PRICE' AND p_unit_price_tbl(i) < 0 THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'UNIT_PRICE',
                                 p_column_val        => p_unit_price_tbl(i),
                                 p_message_name      => 'PO_PDOI_LT_ZERO',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'UNIT_PRICE',
                                 p_token2_name       => 'VALUE',
                                 p_token2_value      => p_unit_price_tbl(i),
                 p_validation_id     => PO_VAL_CONSTANTS.c_unit_price_ge_zero);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;


      -- bug5130037
      -- Provide correct token names/values for the message

      -- If line_type_id is not null and order_type_lookup_code is 'AMOUNT',
      -- unit_price should be the same as the one defined in the line_type.

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
        --<PDOI Enhancement Bug#17063664> Removed the fix of bug 12631717 done here
        -- as it was incorrect. The bug is correctly fixed in PO_PDOI_LINE_PROCESS_PVT.
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token2_name,
                      token1_value,
                      token2_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_LINE_TYPE_INFO',
                   'UNIT_PRICE',
                   p_unit_price_tbl(i),
                   'COLUMN_NAME',
                   'VALUE',
                   'UNIT_PRICE',
                   p_unit_price_tbl(i),
                   PO_VAL_CONSTANTS.c_unit_price_line_type
              FROM DUAL
             WHERE p_line_type_id_tbl(i) IS NOT NULL
               AND p_order_type_lookup_code_tbl(i) = 'AMOUNT'
               AND NOT EXISTS(SELECT 1
                                FROM po_line_types_b plt
                               WHERE p_line_type_id_tbl(i) = plt.line_type_id
                                 AND p_unit_price_tbl(i) = plt.unit_price);

         IF (SQL%ROWCOUNT > 0) THEN
           x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      -- If order_type_lookup_code is 'FIXED PRICE', unit_price has to be null
      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_order_type_lookup_code_tbl(i) = 'FIXED PRICE' AND p_unit_price_tbl(i) IS NOT NULL THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'UNIT_PRICE',
                                 p_column_val        => p_unit_price_tbl(i),
                                 p_message_name      => 'PO_PDOI_SVC_NO_PRICE',
                 p_validation_id     => PO_VAL_CONSTANTS.c_unit_price_null);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END unit_price;

-------------------------------------------------------------------------
--   If order_type_lookup_code is not 'FIXED PRICE' or 'RATE', quantity cannot be less than zero
-- If order_type_lookup_code is 'FIXED PRICE' or 'RATE', quantity has to be null.
-------------------------------------------------------------------------
   PROCEDURE quantity(
      p_id_tbl                       IN              po_tbl_number,
      p_quantity_tbl                 IN              po_tbl_number,
      p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_quantity;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_quantity_tbl', p_quantity_tbl);
         po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- If order_type_lookup_code is not 'FIXED PRICE' or 'RATE', quantity cannot
      -- be less than zero
      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF (p_order_type_lookup_code_tbl(i) NOT IN('FIXED PRICE', 'RATE')
             AND p_quantity_tbl(i) IS NOT NULL
             AND p_quantity_tbl(i) < 0) THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'QUANTITY',
                                 p_column_val        => p_quantity_tbl(i),
                                 p_message_name      => 'PO_PDOI_LT_ZERO',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'QUANTITY',
                                 p_token2_name       => 'VALUE',
                                 p_token2_value      => p_quantity_tbl(i),
                 p_validation_id     => PO_VAL_CONSTANTS.c_quantity_ge_zero);
            x_result_type := po_validations.c_result_type_failure;
         -- If order_type_lookup_code is 'FIXED PRICE' or 'RATE', quantity
         -- must be null
         ELSIF (p_order_type_lookup_code_tbl(i) = 'FIXED PRICE' OR p_order_type_lookup_code_tbl(i) = 'RATE') AND
                p_quantity_tbl(i) IS NOT NULL THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'QUANTITY',
                                 p_column_val        => p_quantity_tbl(i),
                                 p_message_name      => 'PO_SVC_NO_QTY',
                 p_validation_id     => PO_VAL_CONSTANTS.c_quantity_null);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END quantity;

-------------------------------------------------------------------------
-- If order_type_lookup_code is not 'FIXED PRICE' or 'RATE', amount has to be null
-------------------------------------------------------------------------
   PROCEDURE amount(
      p_id_tbl                       IN              po_tbl_number,
      p_amount_tbl                   IN              po_tbl_number,
      p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_amount;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_amount_tbl', p_amount_tbl);
         po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- If order_type_lookup_code is not 'FIXED PRICE' or 'RATE', amount has to
      -- be null
      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF (p_order_type_lookup_code_tbl(i) NOT IN('FIXED PRICE', 'RATE')
             AND p_amount_tbl(i) IS NOT NULL) THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'AMOUNT',
                                 p_column_val        => p_amount_tbl(i),
                                 p_message_name      => 'PO_SVC_NO_AMT',
                 p_validation_id     => PO_VAL_CONSTANTS.c_amount_null);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END amount;

-------------------------------------------------------------------------
-- For rate based temp labor line, the currency rate_type cannot be 'user'
-------------------------------------------------------------------------
   PROCEDURE rate_type(
      p_id_tbl                       IN              po_tbl_number,
      p_rate_type_tbl                IN              po_tbl_varchar30,
      p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_rate_type;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_rate_type_tbl', p_rate_type_tbl);
         po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF (p_order_type_lookup_code_tbl(i) = 'RATE' AND
             p_rate_type_tbl(i) = 'User') THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'RATE_TYPE',
                                 p_column_val        => p_rate_type_tbl(i),
                                 p_message_name      => 'PO_PDOI_SVC_RATE_TYPE_NO_USR',
                                 p_validation_id     => PO_VAL_CONSTANTS.c_rate_type_no_usr);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END rate_type;

-------------------------------------------------------------------------
-- Line num must be populated and cannot be <= 0.
-- Line num has to be unique in a requisition.
-------------------------------------------------------------------------
   PROCEDURE line_num(
      p_id_tbl                       IN              po_tbl_number,
      p_po_header_id_tbl             IN              po_tbl_number,
      p_line_num_tbl                 IN              po_tbl_number,
      p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
      p_draft_id_tbl                 IN              PO_TBL_NUMBER,   -- bug5129752
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_line_num;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_po_header_id_tbl', p_po_header_id_tbl);
         po_log.proc_begin(d_mod, 'p_line_num_tbl', p_line_num_tbl);
         po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- Line num must be populated and cannot be <= 0.
      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF (p_line_num_tbl(i) IS NULL) THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'LINE_NUM',
                                 p_column_val        => p_line_num_tbl(i),
                                 p_message_name      => 'PO_PDOI_COLUMN_NOT_NULL',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'LINE_NUM',
                 p_validation_id     => PO_VAL_CONSTANTS.c_line_num_not_null);
            x_result_type := po_validations.c_result_type_failure;
         ELSIF p_line_num_tbl(i) <= 0 THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'LINE_NUM',
                                 p_column_val        => p_line_num_tbl(i),
                                 p_message_name      => 'PO_PDOI_LT_ZERO',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'LINE_NUM',
                                 p_token2_name       => 'VALUE',
                                 p_token2_value      => p_line_num_tbl(i),
                 p_validation_id     => PO_VAL_CONSTANTS.c_line_num_gt_zero);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;


      -- bug 5129752
      -- Log error if there's line number duplicate in draft table as well

      -- check for uniqueness
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_LINE_NUM_UNIQUE',
                   'LINE_NUM',
                   p_line_num_tbl(i),
                   'VALUE',
                   p_line_num_tbl(i),
                   PO_VAL_CONSTANTS.c_line_num_unique
              FROM DUAL
             WHERE p_po_header_id_tbl(i) IS NOT NULL
               AND p_line_num_tbl(i) IS NOT NULL
               AND (EXISTS(SELECT 'Y'
                            FROM po_lines_all pln
                           WHERE pln.po_header_id = p_po_header_id_tbl(i)
                             AND pln.line_num = p_line_num_tbl(i)
                             AND NOT EXISTS (SELECT 'Y'
                                             FROM   po_lines_draft_all PLD
                                             WHERE  PLN.po_line_id = PLD.po_line_id
                                             AND    PLD.draft_id = p_draft_id_tbl(i)))
                    OR
                    EXISTS (SELECT 'Y'
                            FROM   po_lines_draft_all PLD
                            WHERE  PLD.draft_id = p_draft_id_tbl(i)
                            AND    PLD.po_header_id = p_po_header_id_tbl(i)
                            AND    PLD.line_num = p_line_num_tbl(i)
                            AND    NVL(PLD.delete_flag, 'N') <> 'Y'));

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END line_num;

-------------------------------------------------------------------------
-- Po_line_id must be populated and unique.
-------------------------------------------------------------------------
   PROCEDURE po_line_id(
      p_id_tbl             IN              po_tbl_number,
      p_po_line_id_tbl     IN              po_tbl_number,
      p_po_header_id_tbl   IN              po_tbl_number,
      x_result_set_id      IN OUT NOCOPY   NUMBER,
      x_result_type        OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_po_line_id;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_po_line_id_tbl', p_po_line_id_tbl);
         po_log.proc_begin(d_mod, 'p_po_header_id_tbl', p_po_header_id_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
                      token2_name,
                      token2_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   DECODE(p_id_tbl(i), NULL, 'PO_PDOI_COLUMN_NOT_NULL', 'PO_PDOI_LINE_ID_UNIQUE'),
                   'PO_LINE_ID',
                   p_po_line_id_tbl(i),
                   'COLUMN',
                   'PO_LINE_ID',
                   'VALUE',
                   p_po_line_id_tbl(i),
                   DECODE(p_id_tbl(i), NULL, PO_VAL_CONSTANTS.c_po_line_id_not_null,
                          PO_VAL_CONSTANTS.c_po_line_id_unique)
              FROM DUAL
             WHERE p_po_line_id_tbl(i) IS NULL
                OR (    p_po_header_id_tbl(i) IS NOT NULL
                    AND EXISTS(SELECT 1
                                 FROM po_lines pln
                                WHERE pln.po_header_id = p_po_header_id_tbl(i)
                                  AND pln.po_line_id = p_po_line_id_tbl(i)));

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END po_line_id;

-------------------------------------------------------------------------
-- Line type id must be populated and exist in po_line_types_val_v
-------------------------------------------------------------------------
   PROCEDURE line_type_id(
      p_id_tbl             IN              po_tbl_number,
      p_line_type_id_tbl   IN              po_tbl_number,
      x_result_set_id      IN OUT NOCOPY   NUMBER,
      x_result_type        OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_line_type_id;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_line_type_id_tbl', p_line_type_id_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
                      token2_name,
                      token2_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   DECODE(p_line_type_id_tbl(i), NULL, 'PO_PDOI_COLUMN_NOT_NULL', 'PO_PDOI_INVALID_LINE_TYPE_ID'),
                   'LINE_TYPE_ID',
                   p_line_type_id_tbl(i),
                   'COLUMN_NAME',
                   'LINE_TYPE_ID',
                   'VALUE',
                   p_line_type_id_tbl(i),
                   DECODE(p_line_type_id_tbl(i), NULL, PO_VAL_CONSTANTS.c_line_type_id_not_null,
                          PO_VAL_CONSTANTS.c_line_type_id_valid)
              FROM DUAL
             WHERE p_line_type_id_tbl(i) IS NULL OR
             NOT EXISTS(SELECT 1
                        FROM   po_line_types_val_v pltv
                        WHERE  pltv.line_type_id = p_line_type_id_tbl(i));

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END line_type_id;

-------------------------------------------------------------------------
-- Validate style_id related information.
-------------------------------------------------------------------------
   PROCEDURE style_related_info(
      p_id_tbl                       IN              po_tbl_number,
      p_style_id_tbl                 IN              po_tbl_number,
      p_line_type_id_tbl             IN              po_tbl_number,
      p_purchase_basis_tbl           IN              po_tbl_varchar30,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_style_related_info;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_style_id_tbl', p_style_id_tbl);
         po_log.proc_begin(d_mod, 'p_line_type_id_tbl', p_line_type_id_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- validate line_type_id is valid for the given style
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
                      token2_name,
                      token2_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_LINE_TYPE_ID_STYLE',
                   'LINE_TYPE_ID',
                   p_line_type_id_tbl(i),
                   'STYLE_ID',
                   p_style_id_tbl(i),
                   'LINE_TYPE_ID',
                   p_line_type_id_tbl(i),
                   PO_VAL_CONSTANTS.c_line_style_on_line_type
              FROM po_doc_style_headers pdsh
             WHERE p_style_id_tbl(i) IS NOT NULL AND
                   pdsh.style_id = p_style_id_tbl(i) AND
                   pdsh.line_type_allowed = 'SPECIFIED' AND
                   NOT EXISTS(SELECT 1
                              FROM  po_doc_style_values  pdv
                              WHERE pdv.style_id = pdsh.style_id
                                AND pdv.style_attribute_name = 'LINE_TYPES'
                                AND pdv.style_allowed_value = to_char(p_line_type_id_tbl(i))
                                AND nvl(pdv.enabled_flag, 'N') = 'Y');

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      -- validate the purchase_basis is valid for the given style
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
                      token2_name,
                      token2_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_PURCHASE_BASIS_STYLE',
                   'PURCHASE_BASIS',
                   p_purchase_basis_tbl(i),
                   'STYLE_ID',
                   p_style_id_tbl(i),
                   'PURCHASE_BASIS',
                   p_purchase_basis_tbl(i),
                   PO_VAL_CONSTANTS.c_line_style_on_purchase_basis
              FROM DUAL
             WHERE NOT EXISTS(SELECT 1
                                FROM po_doc_style_values pdsv
                               WHERE pdsv.style_id = p_style_id_tbl(i)
                                 AND pdsv.style_attribute_name = 'PURCHASE_BASES'
                                 AND pdsv.style_allowed_value = p_purchase_basis_tbl(i)
                                 AND nvl(pdsv.enabled_flag, 'N') = 'Y');

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;

   END style_related_info;

-------------------------------------------------------------------------
-- If price_type_lookup_code is not null, it has to be a valid price type in po_lookup_codes
-------------------------------------------------------------------------
   PROCEDURE price_type_lookup_code(
      p_id_tbl                       IN              po_tbl_number,
      p_price_type_lookup_code_tbl   IN              po_tbl_varchar30,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_price_type_lookup_code;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_price_type_lookup_code_tbl', p_price_type_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_PRICE_TYPE',
                   'PRICE_TYPE_LOOKUP_CODE',
                   p_price_type_lookup_code_tbl(i),
                   'VALUE',
                   p_price_type_lookup_code_tbl(i),
                   PO_VAL_CONSTANTS.c_price_type_lookup_code
              FROM DUAL
             WHERE p_price_type_lookup_code_tbl(i) IS NOT NULL
               AND NOT EXISTS(
                      SELECT 'Y'
                        FROM po_lookup_codes plc
                       WHERE plc.lookup_type = 'PRICE TYPE'
                         AND SYSDATE < NVL(plc.inactive_date, SYSDATE + 1)
                         AND plc.lookup_code = p_price_type_lookup_code_tbl(i));

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END price_type_lookup_code;

-------------------------------------------------------------------------
--Start date is required for Standard PO with purchase basis 'TEMP LABOR'
--Expiration date if provided should be later than the start date
--If purchase basis is not 'TEMP LABOR', start_date and expiration_date have to be null
-------------------------------------------------------------------------
   PROCEDURE start_date_standard(
      p_id_tbl                IN              po_tbl_number,
      p_start_date_tbl        IN              po_tbl_date,
      p_expiration_date_tbl   IN              po_tbl_date,
      p_purchase_basis_tbl    IN              po_tbl_varchar30,
      x_results               IN OUT NOCOPY   po_validation_results_type,
      x_result_type           OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_start_date_standard;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_start_date_tbl', p_start_date_tbl);
         po_log.proc_begin(d_mod, 'p_expiration_date_tbl', p_expiration_date_tbl);
         po_log.proc_begin(d_mod, 'p_purchase_basis_tbl', p_purchase_basis_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF (p_purchase_basis_tbl(i) = 'TEMP LABOR') THEN
            IF (p_start_date_tbl(i) IS NULL) THEN
               -- --Start date is required for Standard PO with purchase basis 'TEMP LABOR'
               x_results.add_result(p_entity_type       => c_entity_type_line,
                                    p_entity_id         => p_id_tbl(i),
                                    p_column_name       => 'START_DATE',
                                    p_column_val        => p_start_date_tbl(i),
                                    p_message_name      => 'PO_PDOI_SVC_MUST_START_DATE');
               x_result_type := po_validations.c_result_type_failure;
            ELSIF(NVL(p_expiration_date_tbl(i), p_start_date_tbl(i)) < p_start_date_tbl(i)) THEN
               -- If expiration date provided, it must be later than the start date
               x_results.add_result(p_entity_type       => c_entity_type_line,
                                    p_entity_id         => p_id_tbl(i),
                                    p_column_name       => 'START_DATE',
                                    p_column_val        => p_start_date_tbl(i),
                                    p_message_name      => 'PO_SVC_NO_START_END_DATE');
               x_result_type := po_validations.c_result_type_failure;
            END IF;
         ELSE
            -- purchase basis is not 'TEMP LABOR'
            IF (p_start_date_tbl(i) IS NOT NULL) THEN
               -- start date must be null
               x_results.add_result(p_entity_type       => c_entity_type_line,
                                    p_entity_id         => p_id_tbl(i),
                                    p_column_name       => 'START_DATE',
                                    p_column_val        => p_start_date_tbl(i),
                                    p_message_name      => 'PO_SVC_NO_START_END_DATE');
               x_result_type := po_validations.c_result_type_failure;
            END IF;

            IF (p_start_date_tbl(i) IS NOT NULL) THEN
               -- expiration date must be null
               x_results.add_result(p_entity_type       => c_entity_type_line,
                                    p_entity_id         => p_id_tbl(i),
                                    p_column_name       => 'EXPIRATION_DATE',
                                    p_column_val        => p_expiration_date_tbl(i),
                                    p_message_name      => 'PO_SVC_NO_START_END_DATE');
               x_result_type := po_validations.c_result_type_failure;
            END IF;
         END IF;
      END LOOP;

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END start_date_standard;

-------------------------------------------------------------------------
-- If order_type_lookup_code is not 'RATE' or 'FIXED PRICE', and item_id is not null,
-- then bom_item_type cannot be 1 or 2.
-------------------------------------------------------------------------
   PROCEDURE item_id_standard(
      p_id_tbl                       IN              po_tbl_number,
      p_item_id_tbl                  IN              po_tbl_number,
      p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
      p_inventory_org_id             IN              NUMBER,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_item_id_standard;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_item_id_tbl', p_item_id_tbl);
         po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'p_inventory_org_id', p_inventory_org_id);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_ATO_ITEM_NA',
                   'ITEM_ID',
                   p_item_id_tbl(i),
                   'ITEM_ID',
                   p_item_id_tbl(i)
              FROM DUAL
             WHERE p_item_id_tbl(i) IS NOT NULL
               AND p_order_type_lookup_code_tbl(i) NOT IN('RATE', 'FIXED PRICE')
               AND EXISTS(
                      SELECT 1
                        FROM mtl_system_items msi
                       WHERE msi.inventory_item_id = p_item_id_tbl(i)
                         AND msi.organization_id = p_inventory_org_id
                         AND msi.bom_item_type IN(1, 2));

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END item_id_standard;

-------------------------------------------------------------------------
-- Quantity cannot be zero for SPO
-------------------------------------------------------------------------
   PROCEDURE quantity_standard(
      p_id_tbl                     IN              po_tbl_number,
      p_quantity_tbl               IN              po_tbl_number,
      p_order_type_lookup_code_tbl IN              po_tbl_varchar30,
      x_results                    IN OUT NOCOPY   po_validation_results_type,
      x_result_type                OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_quantity_standard;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_quantity_tbl', p_quantity_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF (p_quantity_tbl(i) IS NOT NULL AND p_quantity_tbl(i) = 0) THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'QUANTITY',
                                 p_column_val        => p_quantity_tbl(i),
                                 p_message_name      => 'PO_PDOI_ZERO_QTY');
            x_result_type := po_validations.c_result_type_failure;
         ELSIF (p_quantity_tbl(i) IS NULL AND
                p_order_type_lookup_code_tbl(i) IN ('QUANTITY', 'AMOUNT')) THEN
           x_results.add_result(p_entity_type       => c_entity_type_line,
                                p_entity_id         => p_id_tbl(i),
                                p_column_name       => 'QUANTITY',
                                p_column_val        => p_quantity_tbl(i),
                                p_message_name      => 'PO_PDOI_COLUMN_NOT_NULL');
           x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END quantity_standard;

-------------------------------------------------------------------------
-- If order_type_lookup_code is 'FIXED PRICE' or 'RATE', amount cannot be null;
-- If order_type_lookup_code is 'FIXED PRICE' or 'RATE' and amount is not
-- empty, amount value must be greater than zero
-------------------------------------------------------------------------
   PROCEDURE amount_standard(
      p_id_tbl                       IN              po_tbl_number,
      p_amount_tbl                   IN              po_tbl_number,
      p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_amount_standard;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_amount_tbl', p_amount_tbl);
         po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF (p_order_type_lookup_code_tbl(i) IN('FIXED PRICE', 'RATE') AND p_amount_tbl(i) IS NULL) THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'AMOUNT',
                                 p_column_val        => p_amount_tbl(i),
                                 p_message_name      => 'PO_PDOI_SVC_MUST_AMT');
            x_result_type := po_validations.c_result_type_failure;
          ELSIF (p_order_type_lookup_code_tbl(i) IN ('FIXED PRICE', 'RATE')
                AND p_amount_tbl(i) IS NOT NULL
                AND p_amount_tbl(i) <= 0) THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'AMOUNT',
                                 p_column_val        => p_amount_tbl(i),
                                 p_message_name      => 'PO_PDOI_LT_ZERO',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'AMOUNT',
                                 p_token2_name       => 'VALUE',
                                 p_token2_value      => p_amount_tbl(i),
                                 p_validation_id     => PO_VAL_CONSTANTS.c_amount_gt_zero);
            x_result_type := po_validations.c_result_type_failure;

         END IF;
      END LOOP;

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END amount_standard;

-------------------------------------------------------------------------
--  Price break lookup code should be valid
-------------------------------------------------------------------------
-- bug5016163 START
   PROCEDURE price_break_lookup_code(
      p_id_tbl                     IN              po_tbl_number,
      p_price_break_lookup_code_tbl IN              po_tbl_varchar30,
      p_global_agreement_flag_tbl   IN               po_tbl_varchar1,
      p_order_type_lookup_code_tbl  IN              po_tbl_varchar30,
      p_purchase_basis_tbl          IN              po_tbl_varchar30,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_price_break_lookup_code;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_price_break_lookup_code_tbl', p_price_break_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'p_global_agreement_flag_tbl', p_global_agreement_flag_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      -- If price break lookup code is provided, it has to be a valid lookup
      -- code
      x_result_type := po_validations.c_result_type_success;
      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
											column_val,
											token1_name,
											token1_value)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_PRICE_BREAK',
                   'PRICE_BREAK_LOOKUP_CODE',
                   p_price_break_lookup_code_tbl(i),
                   'VALUE',
                   p_price_break_lookup_code_tbl(i)
              FROM DUAL
             WHERE p_price_break_lookup_code_tbl(i) IS NOT NULL
               AND p_price_break_lookup_code_tbl(i) NOT IN
                   ( SELECT lookup_code
                     FROM   po_lookup_codes PLC
                     WHERE  PLC.lookup_type = 'PRICE BREAK TYPE');

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      -- Cumulative Pricing is not allowed for GA
      FOR i IN 1 .. p_id_tbl.COUNT LOOP
        IF (p_price_break_lookup_code_tbl(i) = 'CUMULATIVE') THEN
				  IF (p_global_agreement_flag_tbl(i) = 'Y') THEN

            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'PRICE_BREAK_LOOKUP_CODE',
                                 p_column_val        => p_price_break_lookup_code_tbl(i),
                                 p_message_name      => 'PO_PDOI_GA_PRICE_BREAK_NA'
																 );

            x_result_type := po_validations.c_result_type_failure;
          ELSIF ( p_order_type_lookup_code_tbl(i) = 'FIXED PRICE' AND
                  p_purchase_basis_tbl(i) = 'SERVICES') THEN

            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'PRICE_BREAK_LOOKUP_CODE',
                                 p_column_val        => p_price_break_lookup_code_tbl(i),
                                 p_message_name      => 'PO_PDOI_SVC_NO_CUMULATIVE_PB'
																 );

            x_result_type := po_validations.c_result_type_failure;
          END IF;
        END IF;
      END LOOP;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
    END price_break_lookup_code;
-- bug5016163 END


-------------------------------------------------------------------------
--  If allow_price_override_flag is 'N', then not_to_exceed_price has to be null.
-- If not_to_exceed_price is not null, then it cannot be less than unit_price.
-------------------------------------------------------------------------
   PROCEDURE not_to_exceed_price(
      p_id_tbl                     IN              po_tbl_number,
      p_not_to_exceed_price_tbl    IN              po_tbl_number,
      p_allow_price_override_tbl   IN              po_tbl_varchar1,
      p_unit_price_tbl             IN              po_tbl_number,
      x_results                    IN OUT NOCOPY   po_validation_results_type,
      x_result_type                OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_not_to_exceed_price;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_not_to_exceed_price_tbl', p_not_to_exceed_price_tbl);
         po_log.proc_begin(d_mod, 'p_allow_price_override_tbl', p_allow_price_override_tbl);
         po_log.proc_begin(d_mod, 'p_unit_price_tbl', p_unit_price_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF (p_allow_price_override_tbl(i) = 'N' AND p_not_to_exceed_price_tbl(i) IS NOT NULL) THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'NOT_TO_EXCEED_PRICE',
                                 p_column_val        => p_not_to_exceed_price_tbl(i),
                                 p_message_name      => 'PO_PDOI_EXCEED_PRICE_NULL',
                 p_validation_id     => PO_VAL_CONSTANTS.c_not_to_exceed_price_null);
            x_result_type := po_validations.c_result_type_failure;
         ELSIF p_not_to_exceed_price_tbl(i) IS NOT NULL
           AND p_not_to_exceed_price_tbl(i) < p_unit_price_tbl(i) THEN
            -- If not_to_exceed_price is not null, then it cannot be less than
            -- unit_price
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'NOT_TO_EXCEED_PRICE',
                                 p_column_val        => p_not_to_exceed_price_tbl(i),
                                 p_message_name      => 'PO_PDOI_INVALID_PRICE',
                                 p_token1_name       => 'VALUE',
                                 p_token1_value      => p_not_to_exceed_price_tbl(i),
                                 p_token2_name       => 'UNIT_PRICE',
                                 p_token2_value      => p_unit_price_tbl(i),
                 p_validation_id     => PO_VAL_CONSTANTS.c_not_to_exceed_price_valid);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END not_to_exceed_price;

-------------------------------------------------------------------------
-- Validate ip_category_id is valid if not empty
-------------------------------------------------------------------------
   PROCEDURE ip_category_id_update(
      p_id_tbl                       IN              po_tbl_number,
      p_ip_category_id_tbl           IN              po_tbl_number,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_ip_category_id_update;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_ip_category_id_tbl', p_ip_category_id_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_ip_category_id_tbl(i) = PO_PDOI_CONSTANTS.g_NULLIFY_NUM THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'IP_CATEGORY_ID',
                                 p_column_val        => p_ip_category_id_tbl(i),
                                 p_message_name      => 'PO_PDOI_COLUMN_NOT_NULL',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'IP_CATEGORY_ID',
                 p_validation_id     => PO_VAL_CONSTANTS.c_ip_cat_id_update_not_null);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      -- Validate if x_category_id is valid if not empty
      FORALL i IN 1 .. p_id_tbl.COUNT
        INSERT INTO po_validation_results_gt
                    (result_set_id,
                     result_type,
                     entity_type,
                     entity_id,
                     message_name,
                     column_name,
                     column_val,
                     token1_name,
                     token1_value,
           validation_id)
           SELECT x_result_set_id,
                  po_validations.c_result_type_failure,
                  c_entity_type_line,
                  p_id_tbl(i),
                  'PO_PDOI_INVALID_IP_CATEGORY_ID',
                  'IP_CATEGORY_ID',
                  p_ip_category_id_tbl(i),
                  'VALUE',
                  p_ip_category_id_tbl(i),
                  PO_VAL_CONSTANTS.c_ip_cat_id_update_valid
           FROM DUAL
           WHERE p_ip_category_id_tbl(i) IS NOT NULL
           AND   p_ip_category_id_tbl(i) <> -2
           AND NOT EXISTS(
                  SELECT 'Y'
                  FROM icx_cat_categories_v
                  WHERE rt_category_id = p_ip_category_id_tbl(i));

      IF (SQL%ROWCOUNT > 0) THEN
        x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END ip_category_id_update;

-----------------------------------------------------------------------------
-- We need to validate UOM against po_lines_all and po_units_of_measure_val_v
-----------------------------------------------------------------------------
   PROCEDURE uom_update(
      p_id_tbl                       IN              po_tbl_number,
      p_unit_meas_lookup_code_tbl    IN              po_tbl_varchar30,
      p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
      p_po_header_id_tbl             IN              po_tbl_number,
      p_po_line_id_tbl               IN              po_tbl_number,
      x_results                      IN OUT NOCOPY   po_validation_results_type,      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_uom_update;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_unit_meas_lookup_code_tbl', p_unit_meas_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'p_po_header_id_tbl', p_po_header_id_tbl);
         po_log.proc_begin(d_mod, 'p_po_line_id_tbl', p_po_line_id_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
      FOR i IN 1 .. p_id_tbl.COUNT LOOP
          IF p_unit_meas_lookup_code_tbl(i) = PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR THEN
             x_results.add_result(p_entity_type       => c_entity_type_line,
                                  p_entity_id         => p_id_tbl(i),
                                  p_column_name       => 'UNIT_MEAS_LOOKUP_CODE',
                                  p_column_val        => p_unit_meas_lookup_code_tbl(i),
                                  p_message_name      => 'PO_PDOI_COLUMN_NOT_NULL',
                                  p_token1_name       => 'COLUMN_NAME',
                                  p_token1_value      => 'UNIT_MEAS_LOOKUP_CODE',
                  p_validation_id     => PO_VAL_CONSTANTS.c_uom_update_not_null);
             x_result_type := po_validations.c_result_type_failure;
          END IF;
      END LOOP;

	  --- Bug#13936604: Changing line UOM on BPA using the upload program, the error occurs
	  --- that specified value is inactive or invalid even when the UOM passed is valid.

      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_INVALID_UOM_CODE',
                   'UNIT_MEAS_LOOKUP_CODE',
                   p_unit_meas_lookup_code_tbl(i),
                   'UNIT_MEAS_LOOKUP_CODE',
                   p_unit_meas_lookup_code_tbl(i),
                   PO_VAL_CONSTANTS.c_uom_update_valid
              FROM DUAL
             WHERE EXISTS(
                      SELECT 1
                        FROM po_lines_all pol
                        WHERE po_header_id = p_po_header_id_tbl(i) AND
                              po_line_id   = p_po_line_id_tbl(i) AND
                              p_unit_meas_lookup_code_tbl(i) IS NOT NULL AND
                              p_unit_meas_lookup_code_tbl(i) <> NVL(pol.unit_meas_lookup_code,
                                                                    p_unit_meas_lookup_code_tbl(i)) AND
                              p_unit_meas_lookup_code_tbl(i) NOT IN                  --- Bug#13936604
							  (select unit_of_measure from po_units_of_measure_val_v))
                OR EXISTS(
                      SELECT 1
                      FROM po_lines_all pol
                      WHERE p_order_type_lookup_code_tbl(i) NOT IN('RATE', 'FIXED PRICE') AND
                            po_header_id = p_po_header_id_tbl(i) AND
                            po_line_id   = p_po_line_id_tbl(i) AND
                            pol.unit_meas_lookup_code IS NULL AND
                            p_unit_meas_lookup_code_tbl(i) NOT IN                     --- Bug#13936604
							  (select unit_of_measure from po_units_of_measure_val_v));

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;


      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END uom_update;

   -------------------------------------------------------------------------
   -- Make sure that the item_description can be different from what is setup in the item master.
   -- Would not allow item_description update if item attribute allow_item_desc_update_flag is N.
   -- Also need to check the value in po_lines_all to make sure it is the same there, if necessary.
   -------------------------------------------------------------------------
   PROCEDURE item_desc_update(
      p_id_tbl                       IN              po_tbl_number,
      p_item_description_tbl         IN              po_tbl_varchar2000,
      p_item_id_tbl                  IN              po_tbl_number,
      p_inventory_org_id             IN              NUMBER,
      p_po_header_id_tbl             IN              po_tbl_number,
      p_po_line_id_tbl               IN              po_tbl_number,
      x_results                      IN OUT NOCOPY   po_validation_results_type,      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_item_desc_update;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_item_description_tbl', p_item_description_tbl);
         po_log.proc_begin(d_mod, 'p_item_id_tbl', p_item_id_tbl);
         po_log.proc_begin(d_mod, 'p_inventory_org_id', p_inventory_org_id);
         po_log.proc_begin(d_mod, 'p_po_header_id_tbl', p_po_header_id_tbl);
         po_log.proc_begin(d_mod, 'p_po_line_id_tbl', p_po_line_id_tbl);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
      FOR i IN 1 .. p_id_tbl.COUNT LOOP
          IF p_item_description_tbl(i) = PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR THEN
             x_results.add_result(p_entity_type       => c_entity_type_line,
                                  p_entity_id         => p_id_tbl(i),
                                  p_column_name       => 'ITEM_DESCRIPTION',
                                  p_column_val        => p_item_description_tbl(i),
                                  p_message_name      => 'PO_PDOI_COLUMN_NOT_NULL',
                                  p_token1_name       => 'COLUMN_NAME',
                                  p_token1_value      => 'ITEM_DESCRIPTION',
                  p_validation_id     => PO_VAL_CONSTANTS.c_item_desc_update_not_null);
             x_result_type := po_validations.c_result_type_failure;
          END IF;
      END LOOP;

/* Bug 5366732 Modified the inner query to select item description from mtl_system_items_tl instead of from mtl_system_items */


      FORALL i IN 1 .. p_id_tbl.COUNT
         INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      entity_id,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
            validation_id)
            SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_line,
                   p_id_tbl(i),
                   'PO_PDOI_DIFF_ITEM_DESC',
                   'ITEM_DESCRIPTION',
                   p_item_description_tbl(i),
                   'ITEM_DESCRIPTION',
                   p_item_description_tbl(i),
                   PO_VAL_CONSTANTS.c_item_desc_update_unupdatable
              FROM DUAL
             WHERE EXISTS(
                           SELECT 1
                             FROM mtl_system_items msi,
                                  po_lines_all pol,
				  mtl_system_items_tl mtl
                            WHERE p_po_line_id_tbl(i) IS NOT NULL AND
                                  p_item_id_tbl(i) IS NOT NULL AND
                                  pol.po_header_id = nvl(p_po_header_id_tbl(i),pol.po_header_id) AND
                                  pol.po_line_id = p_po_line_id_tbl(i) AND
                                  msi.inventory_item_id = p_item_id_tbl(i) AND
				  msi.inventory_item_id = mtl.inventory_item_id AND
                                  msi.organization_id = p_inventory_org_id AND
  				  msi.organization_id = mtl.organization_id AND
                                  msi.allow_item_desc_update_flag = 'N'  AND
				  mtl.language = USERENV('LANG') AND
                                  (p_item_description_tbl(i) <> mtl.description OR
                                   p_item_description_tbl(i) <> pol.item_description))
				   OR EXISTS(
                           SELECT 1
                             FROM mtl_system_items msi,
			     mtl_system_items_tl mtl
                            WHERE p_po_line_id_tbl(i) IS NULL AND
                                  p_item_id_tbl(i) IS NOT NULL AND
                                  msi.inventory_item_id = p_item_id_tbl(i) AND
				  mtl.inventory_item_id = msi.inventory_item_id AND
                                  msi.organization_id = p_inventory_org_id AND
				  mtl.organization_id = msi.organization_id AND
                                  msi.allow_item_desc_update_flag = 'N' AND
				  mtl.language = USERENV('LANG') AND
                                  p_item_description_tbl(i) <> mtl.description);

      IF (SQL%ROWCOUNT > 0) THEN
         x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END item_desc_update;

   ----------------------------------------------------------------------------------------
   -- Called in create case for Blanket AND SPO, negotiated_by_preparer must be 'Y' or 'N'.
   ----------------------------------------------------------------------------------------
   PROCEDURE negotiated_by_preparer(
      p_id_tbl                       IN              po_tbl_number,
      p_negotiated_by_preparer_tbl   IN              po_tbl_varchar1,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_negotiated_by_preparer;
   BEGIN

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_negotiated_by_preparer_tbl', p_negotiated_by_preparer_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;
      FOR i IN 1 .. p_id_tbl.COUNT LOOP
          IF p_negotiated_by_preparer_tbl(i) NOT IN ('Y', 'N') THEN
             x_results.add_result(p_entity_type       => c_entity_type_line,
                                  p_entity_id         => p_id_tbl(i),
                                  p_column_name       => 'NEGOTIATED_BY_PREPARER',
                                  p_column_val        => p_negotiated_by_preparer_tbl(i),
                                  p_message_name      => 'PO_PDOI_INVALID_FLAG_VALUE',
                                  p_token1_name       => 'COLUMN_NAME',
                                  p_token1_value      => 'NEGOTIATED_BY_PREPARER',
                                  p_token2_name       => 'VALUE',
                                  p_token2_value      => p_negotiated_by_preparer_tbl(i),
                  p_validation_id     => PO_VAL_CONSTANTS.c_negotiated_by_preparer);
             x_result_type := po_validations.c_result_type_failure;
          END IF;
      END LOOP;

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END negotiated_by_preparer;

   --------------------------------------------------------------------------------------
   -- Called in update case for Blanket, negotiated_by_preparer must be NULL, 'Y' or 'N'.
   --------------------------------------------------------------------------------------
   PROCEDURE negotiated_by_prep_update(
      p_id_tbl                       IN              po_tbl_number,
      p_negotiated_by_preparer_tbl   IN              po_tbl_varchar1,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := d_negotiated_by_prep_update;
   BEGIN

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_negotiated_by_preparer_tbl', p_negotiated_by_preparer_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;
      FOR i IN 1 .. p_id_tbl.COUNT LOOP
          IF p_negotiated_by_preparer_tbl(i) = PO_PDOI_CONSTANTS.g_NULLIFY_VARCHAR THEN
             x_results.add_result(p_entity_type       => c_entity_type_line,
                                  p_entity_id         => p_id_tbl(i),
                                  p_column_name       => 'NEGOTIATED_BY_PREPARER',
                                  p_column_val        => p_negotiated_by_preparer_tbl(i),
                                  p_message_name      => 'PO_PDOI_COLUMN_NOT_NULL',
                                  p_token1_name       => 'COLUMN_NAME',
                                  p_token1_value      => 'NEGOTIATED_BY_PREPARER',
                  p_validation_id     => PO_VAL_CONSTANTS.c_nego_by_prep_update_not_null);
             x_result_type := po_validations.c_result_type_failure;
          ELSIF p_negotiated_by_preparer_tbl(i) NOT IN (NULL, 'Y', 'N') THEN
             x_results.add_result(p_entity_type       => c_entity_type_line,
                                  p_entity_id         => p_id_tbl(i),
                                  p_column_name       => 'NEGOTIATED_BY_PREPARER',
                                  p_column_val        => p_negotiated_by_preparer_tbl(i),
                                  p_message_name      => 'PO_PDOI_INVALID_FLAG_VALUE',
                                  p_token1_name       => 'COLUMN_NAME',
                                  p_token1_value      => 'NEGOTIATED_BY_PREPARER',
                                  p_token2_name       => 'VALUE',
                                  p_token2_value      => p_negotiated_by_preparer_tbl(i),
                  p_validation_id     => PO_VAL_CONSTANTS.c_nego_by_prep_update_valid);
             x_result_type := po_validations.c_result_type_failure;
          END IF;
      END LOOP;

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END negotiated_by_prep_update;

   -------------------------------------------------------------------------
   -- If either item_id or job_id are populated, then you are not allowed to change the po_category_id
   -- If change is allowed, the new category_id must be valid.
   -------------------------------------------------------------------------
   PROCEDURE category_id_update(
      p_id_tbl                       IN              po_tbl_number,
      p_category_id_tbl              IN              po_tbl_number,
      p_po_line_id_tbl               IN              po_tbl_number,
      p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
      p_item_id_tbl                  IN              po_tbl_number,
      p_job_id_tbl                   IN              po_tbl_number,
      p_inventory_org_id             IN              NUMBER,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2)
   IS
    d_mod CONSTANT VARCHAR2(100) := d_category_id_update;
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_category_id_tbl', p_category_id_tbl);
         po_log.proc_begin(d_mod, 'p_po_line_id_tbl', p_po_line_id_tbl);
         po_log.proc_begin(d_mod, 'p_order_type_lookup_code_tbl', p_order_type_lookup_code_tbl);
         po_log.proc_begin(d_mod, 'p_item_id_tbl', p_item_id_tbl);
         po_log.proc_begin(d_mod, 'p_job_id_tbl', p_job_id_tbl);
         po_log.proc_begin(d_mod, 'p_inventory_org_id', p_inventory_org_id);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;
      FOR i IN 1 .. p_id_tbl.COUNT LOOP
         IF p_category_id_tbl(i) = PO_PDOI_CONSTANTS.g_NULLIFY_NUM THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'CATEGORY_ID',
                                 p_column_val        => p_category_id_tbl(i),
                                 p_message_name      => 'PO_PDOI_COLUMN_NOT_NULL',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'CATEGORY_ID',
                 p_validation_id     => PO_VAL_CONSTANTS.c_cat_id_update_not_null);
            x_result_type := po_validations.c_result_type_failure;
         END IF;
      END LOOP;

      FORALL i IN 1 .. p_id_tbl.COUNT
           INSERT INTO po_validation_results_gt
                       (result_set_id,
                        result_type,
                        entity_type,
                        entity_id,
                        message_name,
                        column_name,
                        column_val,
            validation_id)
              SELECT x_result_set_id,
                     po_validations.c_result_type_failure,
                     c_entity_type_line,
                     p_id_tbl(i),
                     'PO_PDOI_NO_PO_CAT_UPDATE',
                     'CATEGORY_ID',
                     p_category_id_tbl(i),
                     PO_VAL_CONSTANTS.c_cat_id_update_not_updatable
                FROM DUAL
               WHERE p_category_id_tbl(i) IS NOT NULL
                 AND (p_item_id_tbl(i) IS NOT NULL OR p_job_id_tbl(i) IS NOT NULL)
                 AND (EXISTS(SELECT 1
                             FROM  po_lines_all pol
                             WHERE p_po_line_id_tbl(i) = pol.po_line_id
                               AND p_category_id_tbl(i) <> pol.category_id)
                      OR EXISTS(SELECT 1
                                FROM  po_lines_draft_all pld
                                WHERE p_po_line_id_tbl(i) = pld.po_line_id
                                  AND p_category_id_tbl(i) <> pld.category_id));

      IF (SQL%ROWCOUNT > 0) THEN
          x_result_type := po_validations.c_result_type_failure;
      END IF;

      PO_VAL_LINES2.category_id(p_id_tbl                         => p_id_tbl,
                                p_category_id_tbl                => p_category_id_tbl,
                                p_order_type_lookup_code_tbl     => p_order_type_lookup_code_tbl,
                                p_item_id_tbl                    => p_item_id_tbl,
                                p_inventory_org_id               => p_inventory_org_id,
                                x_result_set_id                  => x_result_set_id,
                                x_results                        => x_results,
                                x_result_type                    => x_result_type);

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END category_id_update;

-------------------------------------------------------------------------
-- In the UPDATE case, unit_price cannot be negative.  Also handle #DEL.
-------------------------------------------------------------------------
   PROCEDURE unit_price_update
   (  p_id_tbl          IN              po_tbl_number,
      p_po_line_id_tbl  IN              po_tbl_number, -- bug5008206
      p_draft_id_tbl    IN              po_tbl_number,
      p_unit_price_tbl  IN              po_tbl_number,
      x_results         IN OUT NOCOPY   po_validation_results_type,
      x_result_set_id   IN OUT NOCOPY   NUMBER,        -- bug5008206
      x_result_type     OUT NOCOPY      VARCHAR2
   )
   IS
    d_mod CONSTANT VARCHAR2(100) := d_unit_price_update;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_unit_price_tbl', p_unit_price_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      FOR i IN 1 .. p_id_tbl.COUNT LOOP

         IF p_unit_price_tbl(i) = PO_PDOI_CONSTANTS.g_NULLIFY_NUM THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'UNIT_PRICE',
                                 p_column_val        => p_unit_price_tbl(i),
                                 p_message_name      => 'PO_PDOI_COLUMN_NOT_NULL',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'UNIT_PRICE',
                 p_validation_id     => PO_VAL_CONSTANTS.c_unit_price_update_not_null);
            x_result_type := po_validations.c_result_type_failure;
         ELSIF p_unit_price_tbl(i) IS NOT NULL AND p_unit_price_tbl(i) < 0 THEN
            x_results.add_result(p_entity_type       => c_entity_type_line,
                                 p_entity_id         => p_id_tbl(i),
                                 p_column_name       => 'UNIT_PRICE',
                                 p_column_val        => p_unit_price_tbl(i),
                                 p_message_name      => 'PO_PDOI_LT_ZERO',
                                 p_token1_name       => 'COLUMN_NAME',
                                 p_token1_value      => 'UNIT_PRICE',
                                 p_token2_name       => 'VALUE',
                                 p_token2_value      => p_unit_price_tbl(i),
                 p_validation_id     => PO_VAL_CONSTANTS.c_unit_price_update_ge_zero);
            x_result_type := po_validations.c_result_type_failure;

        END IF;
      END LOOP;

      -- bug5258790
      -- For fixed price line update, unit price has to be NULL
      FORALL i IN 1..p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   validation_id)
         SELECT x_result_set_id,
                po_validations.c_result_type_failure,
                c_entity_type_line,
                p_id_tbl(i),
                'PO_PDOI_SVC_NO_PRICE',
                'UNIT_PRICE',
                p_unit_price_tbl(i),
                PO_VAL_CONSTANTS.c_unit_price_null
          FROM  po_lines_all POL
          WHERE POL.po_line_id = p_po_line_id_tbl(i)
          AND   POL.order_type_lookup_code = 'FIXED PRICE'
          AND   p_unit_price_tbl(i) IS NOT NULL
-- missin draft id
          UNION
          SELECT x_result_set_id,
                po_validations.c_result_type_failure,
                c_entity_type_line,
                p_id_tbl(i),
                'PO_PDOI_SVC_NO_PRICE',
                'UNIT_PRICE',
                p_unit_price_tbl(i),
                PO_VAL_CONSTANTS.c_unit_price_null
          FROM  po_lines_draft_all POL
          WHERE POL.po_line_id = p_po_line_id_tbl(i)
          AND   POL.draft_id = p_draft_id_tbl(i)
          AND   POL.order_type_lookup_code = 'FIXED PRICE'
          AND   p_unit_price_tbl(i) IS NOT NULL;

      IF (SQL%ROWCOUNT > 0) THEN
        x_result_type := po_validations.c_result_type_failure;
      END IF;

      -- bug5008026
      -- Make sure that the new price does not exceed price limit
      FORALL i IN 1 .. p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   token1_name,
                   token1_value,
                   token2_name,
                   token2_value,
                   column_name,
                   column_val,
                   validation_id)
         SELECT x_result_set_id,
                po_validations.c_result_type_failure,
                c_entity_type_line,
                p_id_tbl(i),
                'PO_PDOI_INVALID_PRICE',
                'VALUE',
                POL.not_to_exceed_price,
                'UNIT_PRICE',
                p_unit_price_tbl(i),
                'UNIT_PRICE',
                p_unit_price_tbl(i),
                PO_VAL_CONSTANTS.c_not_to_exceed_price_valid
           FROM po_lines_all POL
          WHERE POL.po_line_id = p_po_line_id_tbl(i)
          AND   POL.not_to_exceed_price < p_unit_price_tbl(i);

      IF (SQL%ROWCOUNT > 0) THEN
        x_result_type := po_validations.c_result_type_failure;
      END IF;

      -- Enhanced Pricing Start
      -- For line with price adjustments, the unit_price should not changed
      FORALL i IN 1..p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   validation_id)
         SELECT x_result_set_id,
                po_validations.c_result_type_failure,
                c_entity_type_line,
                p_id_tbl(i),
                'PO_PDOI_ADJ_PRICE_UPDATE_NA',
                'UNIT_PRICE',
                p_unit_price_tbl(i),
                PO_VAL_CONSTANTS.c_price_adjustment_exist
          FROM  po_lines_all POL
          WHERE POL.po_line_id = p_po_line_id_tbl(i)
          AND   POL.unit_price <> p_unit_price_tbl(i)
          AND EXISTS (SELECT 1
                      FROM PO_PRICE_ADJUSTMENTS ADJ
                      WHERE ADJ.po_line_id = p_po_line_id_tbl(i));

      IF (SQL%ROWCOUNT > 0) THEN
        x_result_type := po_validations.c_result_type_failure;
      END IF;
      -- Enhanced Pricing End

     --<Bug 18372756>: don't allow to change price when there are unvalidated
     --debit memo for the lines/distributions.
     FORALL i IN 1..p_id_tbl.COUNT
          INSERT INTO po_validation_results_gt
                      (result_set_id,
                       result_type,
                       entity_type,
                       entity_id,
                       message_name,
                       column_name,
                       column_val,
                       validation_id)
             SELECT x_result_set_id,
                    po_validations.c_result_type_failure,
                    c_entity_type_line,
                    p_id_tbl(i),
                    'PO_AP_DEBIT_MEMO_UNVALIDATED',
                    'UNIT_PRICE',
                    p_unit_price_tbl(i),
                    PO_VAL_CONSTANTS.c_unvalidated_debit_memo_exist
               FROM  po_lines_all POL
               WHERE POL.po_line_id = p_po_line_id_tbl(i)
               AND EXISTS (
                       SELECT 'unvalidated debit memo'
                       FROM PO_HEADERS_ALL POH,
                            po_line_locations_all poll,
                            po_releases_all por
                       WHERE poll.po_line_id = pol.po_line_id
                        AND POH.po_header_id = POL.po_header_id
                        AND por.po_header_id(+) = poh.po_header_id
                        AND (poll.quantity_billed = 0 OR poll.quantity_billed is null)
                        AND PO_DOCUMENT_CHECKS_PVT.chk_unv_invoices('CREDIT', poh.po_header_id, por.po_release_id, pol.po_line_id, poll.line_location_id, NULL, NULL, 'PO_AP_DEBIT_MEMO_UNVALIDATED') = 1);

           IF (SQL%ROWCOUNT > 0) THEN
             x_result_type := po_validations.c_result_type_failure;
           END IF;
      --<End Bug 18372756>

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END unit_price_update;


-- bug5258790 START
-------------------------------------------------------------------------
-- In the UPDATE case, amount should not be udpated if it's not 'FIXED PRICE'
-------------------------------------------------------------------------
   PROCEDURE amount_update
   (  p_id_tbl          IN              po_tbl_number,
      p_po_line_id_tbl  IN              po_tbl_number, -- bug5008206
      p_draft_id_tbl    IN              po_tbl_number,
      p_amount_tbl      IN              po_tbl_number,
      x_results         IN OUT NOCOPY   po_validation_results_type,
      x_result_set_id   IN OUT NOCOPY   NUMBER,        -- bug5008206
      x_result_type     OUT NOCOPY      VARCHAR2
   )
   IS
    d_mod CONSTANT VARCHAR2(100) := d_amount_update;
   BEGIN
      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_amount_tbl', p_amount_tbl);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      -- bug5258790
      -- For fixed price line update, unit price has to be NULL
      FORALL i IN 1..p_id_tbl.COUNT
      INSERT INTO po_validation_results_gt
                  (result_set_id,
                   result_type,
                   entity_type,
                   entity_id,
                   message_name,
                   column_name,
                   column_val,
                   validation_id)
         SELECT x_result_set_id,
                po_validations.c_result_type_failure,
                c_entity_type_line,
                p_id_tbl(i),
                'PO_PDOI_SVC_BLKT_NO_AMT',
                'AMOUNT',
                p_amount_tbl(i),
                PO_VAL_CONSTANTS.c_amount_blanket
          FROM  po_lines_all POL
          WHERE POL.po_line_id = p_po_line_id_tbl(i)
          AND   POL.order_type_lookup_code <> 'FIXED PRICE'
          AND   p_amount_tbl(i) IS NOT NULL
-- missin draft id
          UNION
          SELECT x_result_set_id,
                po_validations.c_result_type_failure,
                c_entity_type_line,
                p_id_tbl(i),
                'PO_PDOI_SVC_BLKT_NO_AMT',
                'AMOUNT',
                p_amount_tbl(i),
                PO_VAL_CONSTANTS.c_amount_blanket
          FROM  po_lines_draft_all POL
          WHERE POL.po_line_id = p_po_line_id_tbl(i)
          AND   POL.draft_id = p_draft_id_tbl(i)
          AND   POL.order_type_lookup_code <> 'FIXED PRICE'
          AND   p_amount_tbl(i) IS NOT NULL;


      IF (SQL%ROWCOUNT > 0) THEN
        x_result_type := po_validations.c_result_type_failure;
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;

         RAISE;
   END amount_update;
-- bug5258790 END
-- bug8633959 START
-------------------------------------------------------------------------
-- Check valid category got selected or not from the category LOV in BWC
-- It is called when leaving category field to trigger PPR event in BWC
-------------------------------------------------------------------------

PROCEDURE check_valid_category(
      p_category            IN  VARCHAR2,
      x_results             OUT NOCOPY VARCHAR2,
      x_result_msg          OUT NOCOPY VARCHAR2 )
   IS
   validateSegments BOOLEAN := TRUE;
   x_structure_id NUMBER;
   x_resp_id NUMBER;
   x_resp_appl_id NUMBER;
   x_user_id NUMBER;

   --Bug 19139957
   x_format_category Mtl_Categories_Kfv.Concatenated_Segments%type;

BEGIN

 BEGIN
 SELECT mdsv.structure_id
   INTO x_structure_id
   FROM mtl_default_sets_view mdsv
  WHERE mdsv.functional_area_id = 2;
 EXCEPTION
   WHEN No_Data_Found THEN
     NULL;
   WHEN OTHERS THEN
     NULL;
 END;
x_user_id := fnd_global.user_id;
x_resp_id := fnd_global.resp_id;
x_resp_appl_id := fnd_global.resp_appl_id;

 --Bug19139957 Format the category segment value.
 --If there's character the same as separator in the category segment
 --Add a '\' before the character.
 format_category_segment(p_category, x_structure_id, x_format_category);

 validateSegments := fnd_flex_keyval.validate_segs('CHECK_SEGMENTS',
                                                    'INV',
                                                    'MCAT',
                                                    x_structure_id,
                                                    x_format_category,
                                                    'V',
                                                    SYSDATE,
                                                    'ALL',
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    FALSE,
                                                    FALSE,
                                                    x_resp_appl_id,
                                                    x_resp_id,
                                                    x_user_id,
                                                    'MTL_CATEGORIES_VL',
                                                    NULL,
                                                    'APPL=PO;NAME=PO_RI_INVALID_CATEGORY_ID') ;
  --Bug 18646482 End
  IF  (validateSegments)  THEN
      x_results := 'Y';
      x_result_msg := 'Segments Valid';
  ELSE
      x_results := 'N';
      IF fnd_flex_keyval.error_segment IS NOT NULL THEN
         x_result_msg := fnd_flex_keyval.segment_value ( fnd_flex_keyval.error_segment ) || ' - '|| fnd_flex_keyval.error_message ;
      ELSE
         x_result_msg :=  fnd_flex_keyval.error_message;
      END IF;
  END IF;

EXCEPTION
      WHEN OTHERS THEN
         x_result_msg :=  'Exception Raised in PO_VAL_LINES2.check_valid_category';
         x_results := 'N';

END check_valid_category;

------------------------------------------------------------------------------------------
-- Check valid category got selected or not for all the lines from the category LOV in BWC
-- It is called when saving agreements/orders in BWC
------------------------------------------------------------------------------------------
   PROCEDURE category_combination_valid
   (  p_po_line_id_tbl  IN              po_tbl_number,
      p_category_id_tbl IN              po_tbl_number,
      x_results         IN OUT NOCOPY   po_validation_results_type,
      x_result_type     OUT NOCOPY      VARCHAR2
   )
   IS
      d_mod CONSTANT VARCHAR2(100) := d_category_comb_valid;
      l_results_count NUMBER;
      v_category BOOLEAN;
      x_structure_id NUMBER;
      x_resp_id NUMBER;
      x_resp_appl_id NUMBER;
      x_user_id NUMBER;
      x_category Mtl_Categories_Kfv.Concatenated_Segments%type; --14050066
      l_query_count NUMBER;  --17207004

      --Bug 19139957
      x_format_category Mtl_Categories_Kfv.Concatenated_Segments%type;

   BEGIN

      IF PO_LOG.d_proc THEN
        PO_LOG.proc_begin(d_mod,'p_po_line_id_tbl',p_po_line_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_category_id_tbl',p_category_id_tbl);
        PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
      END IF;

        IF (x_results IS NULL) THEN
          x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
        END IF;
     l_results_count := x_results.result_type.COUNT;
     x_result_type := po_validations.c_result_type_success;
      BEGIN
      SELECT mdsv.structure_id
        INTO x_structure_id
        FROM mtl_default_sets_view mdsv
        WHERE mdsv.functional_area_id = 2;
      EXCEPTION
        WHEN No_Data_Found THEN
          NULL;
        WHEN OTHERS THEN
          NULL;
      END;
      x_user_id := fnd_global.user_id;
      x_resp_id := fnd_global.resp_id;
      x_resp_appl_id := fnd_global.resp_appl_id;

      FOR i IN 1..p_po_line_id_tbl.Count
      LOOP
         v_category := fnd_flex_keyval.validate_ccid('INV',
                                                    'MCAT',
                                                    x_structure_id,
                                                    p_category_id_tbl(i)  ,
                                                    'ALL',
                                                    NULL,
                                                    NULL,
                                                    'ENFORCE',
                                                    NULL,
                                                    x_resp_appl_id,
                                                    x_resp_id ,
                                                    x_user_id,
                                                    'MTL_CATEGORIES_VL' );
          -- 14050066: Valid category should pass through
          -- both validate_ccid and validate_segs
          IF (v_category) THEN

             Select Mck.Concatenated_Segments
               into x_category
               From Mtl_Categories_Kfv Mck
              where mck.category_id = p_category_id_tbl(i);

	      --Bug19139957 Format the category segment value.
              --If there's character the same as separator in the category segment
              --Add a '\' before the character.
              format_category_segment(x_category, x_structure_id, x_format_category);

             v_category := fnd_flex_keyval.validate_segs('CHECK_SEGMENTS',
                                                    'INV',
                                                    'MCAT',
                                                    x_structure_id,
                                                    x_format_category,
                                                    'V',
                                                    SYSDATE,
                                                    'ALL',
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    FALSE,
                                                    FALSE,
                                                    x_resp_appl_id,
                                                    x_resp_id,
                                                    x_user_id,
                                                    'MTL_CATEGORIES_VL',
                                                    NULL,
                                                    'APPL=PO;NAME=PO_RI_INVALID_CATEGORY_ID') ;
          END IF;
           -- 17207004 START
           -- Valid category shoule be active
           IF (v_category) THEN

             BEGIN
               SELECT COUNT(*)
               INTO l_query_count
               FROM mtl_categories_vl
               WHERE structure_id = x_structure_id
               AND category_id = p_category_id_tbl(i)
               AND NVL(disable_date, SYSDATE + 1) > SYSDATE;
             EXCEPTION
               WHEN OTHERS THEN
                 l_query_count := 0;
             END;

             IF (l_query_count = 0) THEN
               v_category := FALSE;
             END IF;

           END IF;
           -- 17207004 END
          IF  NOT (v_category)  THEN
             x_results.add_result(
                                  p_entity_type => c_entity_type_line
                                  , p_entity_id => p_po_line_id_tbl(i)
                                  , p_column_name => 'CATEGORY_ID'
                                  , p_message_name => 'PO_RI_INVALID_CATEGORY_ID'
                                  );
          END IF;
       END LOOP;

      IF (l_results_count < x_results.result_type.COUNT) THEN
          x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
      ELSE
          x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;
         RAISE;
 END category_combination_valid;
-- bug 8633959 END

-- bug14075368 START
-------------------------------------------------------------------------
-- Check valid item got selected or not from the item LOV in BWC
-- It is called when leaving item field to trigger PPR event in BWC
-------------------------------------------------------------------------

   PROCEDURE check_valid_item(
     p_item                IN  VARCHAR2,
     x_results             OUT NOCOPY VARCHAR2,
     x_result_msg          OUT NOCOPY VARCHAR2 )
   IS
     validateSegments BOOLEAN := TRUE;
     x_structure_id NUMBER;
     x_resp_id NUMBER;
     x_resp_appl_id NUMBER;
     x_user_id NUMBER;
   BEGIN

     BEGIN
       --bug 14541831
       SELECT ffs.id_flex_num
         INTO x_structure_id
         FROM fnd_id_flex_structures ffs
         WHERE id_flex_code='MSTK';
     EXCEPTION
       WHEN No_Data_Found THEN
         NULL;
       WHEN OTHERS THEN
         NULL;
     END;

     x_user_id := fnd_global.user_id;
     x_resp_id := fnd_global.resp_id;
     x_resp_appl_id := fnd_global.resp_appl_id;

     --Bug 14415818 , no need to validate for one time item
     IF (p_item is NOT null)
       THEN
       validateSegments := fnd_flex_keyval.validate_segs(operation => 'CHECK_SEGMENTS',
                              appl_short_name =>  'INV',
                              key_flex_code => 'MSTK',
                              structure_number => x_structure_id,
                              concat_segments => p_item,
                              resp_appl_id => x_resp_appl_id,
                              resp_id => x_resp_id,
                              user_id => x_user_id,
                              select_comb_from_view => 'MTL_SYSTEM_ITEMS_VL',
                              where_clause_msg => 'APPL=PO;NAME=PO_RI_INVALID_ITEM_ID') ;
     END IF;

     IF  (validateSegments)  THEN
       x_results := 'Y';
       x_result_msg := 'Segments Valid';
     ELSE
       x_results := 'N';
       IF fnd_flex_keyval.error_segment IS NOT NULL THEN
         x_result_msg := fnd_flex_keyval.segment_value ( fnd_flex_keyval.error_segment )
          || ' - '|| fnd_flex_keyval.error_message ;
       ELSE
         x_result_msg :=  fnd_flex_keyval.error_message;
       END IF;
     END IF;
     EXCEPTION
      WHEN OTHERS THEN
        x_result_msg :=  'Exception Raised in PO_VAL_LINES2.check_valid_item';
        x_results := 'N';

   END check_valid_item;

------------------------------------------------------------------------------------------
-- Check valid item got selected or not for all the lines from the item LOV in BWC
-- It is called when saving agreements/orders in BWC
------------------------------------------------------------------------------------------
   PROCEDURE item_combination_valid
   (  p_po_line_id_tbl  IN              po_tbl_number,
      p_item_id_tbl     IN              po_tbl_number,
      x_results         IN OUT NOCOPY   po_validation_results_type,
      x_result_type     OUT NOCOPY      VARCHAR2
   )
   IS
      d_mod CONSTANT VARCHAR2(100) := d_item_comb_valid;
      l_results_count NUMBER;
      v_item BOOLEAN;
      x_structure_id NUMBER;
      x_resp_id NUMBER;
      x_resp_appl_id NUMBER;
      x_user_id NUMBER;
      x_org_id NUMBER;
      x_item mtl_system_items_vl.Concatenated_Segments%type;

   BEGIN

      IF PO_LOG.d_proc THEN
        PO_LOG.proc_begin(d_mod,'p_po_line_id_tbl',p_po_line_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_item_id_tbl',p_item_id_tbl);
        PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
      END IF;

        IF (x_results IS NULL) THEN
          x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
        END IF;
     l_results_count := x_results.result_type.COUNT;
     x_result_type := po_validations.c_result_type_success;
     BEGIN
       --bug 14541831
       SELECT ffs.id_flex_num
         INTO x_structure_id
         FROM fnd_id_flex_structures ffs
         WHERE id_flex_code='MSTK';
       EXCEPTION
         WHEN No_Data_Found THEN
           NULL;
         WHEN OTHERS THEN
           NULL;
      END;

      x_user_id := fnd_global.user_id;
      x_resp_id := fnd_global.resp_id;
      x_resp_appl_id := fnd_global.resp_appl_id;
      -- x_org_id  := fnd_global.org_id;

      -- Bug 14622747
      -- When we call the validate_ccid() function, we should ideally be passing inventory_org_id for the OU in which the PO is created.
      -- Currently we are passing the org_id of the OU in which the PO is created.
      select  inventory_organization_id
      into    x_org_id
      from    financials_system_parameters;
      -- <end> Bug 14622747


      FOR i IN 1..p_po_line_id_tbl.Count
      LOOP
        --Bug 14415818 , no need to validate for one time item
        IF (p_item_id_tbl(i) is null)
          THEN
            v_item :=true;
          ELSE

            v_item :=fnd_flex_keyval.validate_ccid(
              APPL_SHORT_NAME=>'INV',
              KEY_FLEX_CODE=>'MSTK',
              STRUCTURE_NUMBER=>x_structure_id,
              COMBINATION_ID=>p_item_id_tbl(i),
              DISPLAYABLE=>'ALL',
              DATA_SET=>x_org_id,
              VRULE=>NULL,
              SECURITY=>'ENFORCE',
              GET_COLUMNS=>NULL,
              RESP_APPL_ID=>x_resp_appl_id,
              RESP_ID=>x_resp_id,
              USER_ID=>x_user_id,
              select_comb_from_view=>'MTL_SYSTEM_ITEMS_VL'
            );

          --  Valid item should pass through
          -- both validate_ccid and validate_segs
          IF (v_item) THEN

             Select msi.Concatenated_Segments
               into x_item
               From mtl_system_items_vl msi
               where msi.inventory_item_id = p_item_id_tbl(i)
               AND MSI.ORGANIZATION_ID=x_org_id;

             v_item := fnd_flex_keyval.validate_segs(operation => 'CHECK_SEGMENTS',
                              appl_short_name =>  'INV',
                              key_flex_code => 'MSTK',
                              structure_number => x_structure_id,
                              concat_segments => x_item,
                              resp_appl_id => x_resp_appl_id,
                              resp_id => x_resp_id,
                              user_id => x_user_id,
                              select_comb_from_view => 'MTL_SYSTEM_ITEMS_VL',
                              where_clause_msg => 'APPL=PO;NAME=PO_RI_INVALID_ITEM_ID') ;
          END IF;
        END IF;
          IF  NOT (v_item)  THEN
             x_results.add_result(
                                  p_entity_type => c_entity_type_line
                                  , p_entity_id => p_po_line_id_tbl(i)
                                  , p_column_name => 'ITEM_ID'
                                  , p_message_name => 'PO_RI_INVALID_ITEM_ID'
                                  );
          END IF;
      END LOOP;

      IF (l_results_count < x_results.result_type.COUNT) THEN
          x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
      ELSE
          x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;
         RAISE;
 END item_combination_valid;
-- bug 14075368 END

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- Validate Source Doc Reference
  -------------------------------------------------------------------------
  PROCEDURE validate_source_doc(
                       p_id_tbl                       IN              po_tbl_number,
                       p_from_header_id_tbl           IN              po_tbl_number,
                       p_from_line_id_tbl             IN              po_tbl_number,
                       p_contract_id_tbl              IN              po_tbl_number,
                       p_org_id_tbl                   IN              po_tbl_number,
                       p_item_id_tbl                  IN              po_tbl_number,
                       p_item_rev_tbl                 IN              po_tbl_varchar5,
                       p_item_descp_tbl               IN              po_tbl_varchar2000,
                       p_job_id_tbl                   IN              po_tbl_number,
                       p_order_type_lookup_tbl        IN              po_tbl_varchar30,
                       p_purchase_basis_tbl           IN              po_tbl_varchar30,
                       p_matching_basis_tbl           IN              po_tbl_varchar30,
                       p_category_id                  IN              po_tbl_number,
                       p_uom_tbl                      IN              po_tbl_varchar30,
                       p_vendor_id_tbl                IN              po_tbl_number,
                       p_vendor_site_id_tbl           IN              po_tbl_number,
                       p_currency_code_tbl            IN              po_tbl_varchar30,
                       p_style_id_tbl                 IN              po_tbl_number,
                       p_unit_price_tbl               IN              po_tbl_number,
                       x_results                      IN OUT NOCOPY   po_validation_results_type,
                       x_result_set_id                IN OUT NOCOPY   NUMBER,
                       x_result_type                  OUT NOCOPY      VARCHAR2)
  IS
   d_mod CONSTANT VARCHAR2(100) := D_validate_source_doc;
   l_key NUMBER;

   l_blanket PO_SOURCE_DOC_VAL_TYPE := PO_SOURCE_DOC_VAL_TYPE();
   l_contract PO_SOURCE_DOC_VAL_TYPE := PO_SOURCE_DOC_VAL_TYPE();

   CURSOR blanket_details IS
     SELECT gt.index_num1, -- p_id
          pha.type_lookup_code, -- src_doc_type
          gt.num3, -- src_header_id
          gt.num1,  -- vendor_id
          gt.num2,  -- vendor_site_id
          gt.char1, -- currency code
          gt.num5,  -- org_id
          gt.num6,  -- style_id
          /*Line Level attributes*/
          line_gt.from_line_id, -- src_line_id
          line_gt.item_id,
          line_gt.item_revision,
          line_gt.item_description,
          gt.num4, -- job_id
          line_gt.order_type_lookup_code,
          line_gt.purchase_basis,
          line_gt.matching_basis,
          line_gt.category_id,
          line_gt.unit_meas_lookup_code,
          line_gt.unit_price,
          /*Source Doc Header attributes*/
          NVL(pha.global_agreement_flag, 'N'),
          NVL(pha.enable_all_sites, 'N'),
          pha.vendor_id,
          pha.vendor_site_id,
          pha.currency_code,
          pha.org_id,
          NVL(pha.closed_code, 'OPEN'),
          NVL(pha.cancel_flag, 'N'),
          NVL(pha.frozen_flag, 'N'),
          NVL(pha.user_hold_flag,'N'),
          pha.start_date,
          pha.end_date,
          NVL(pha.authorization_status, 'INCOMPLETE'),
          pha.approved_date,
          NVL(pha.approved_flag,'N'),
          pha.style_id,
          /*Source Doc Line attributes*/
          pla.item_id,
          pla.item_revision,
          pla.item_description,
          pla.job_id,
          NVL(pla.cancel_flag, 'N'),
          NVL(pla.closed_code, 'OPEN'),
          pla.order_type_lookup_code,
          pla.purchase_basis,
          pla.matching_basis,
          pla.category_id,
          pla.unit_meas_lookup_code,
          pla.expiration_date,
          pla.allow_price_override_flag
      FROM po_headers_all pha,
           po_lines_all pla,
           po_session_gt gt,
           po_lines_gt line_gt
     WHERE gt.key = l_key
       AND line_gt.po_line_id = gt.index_num1
       AND line_gt.from_header_id = gt.num3
       AND pha.type_lookup_code = 'BLANKET'
       AND line_gt.from_header_id = pha.po_header_id
       AND line_gt.from_header_id = pla.po_header_id
       AND line_gt.from_line_id = pla.po_line_id;

   CURSOR contract_details IS
     SELECT gt.index_num1, -- p_id
          pha.type_lookup_code, -- src_doc_type
          gt.num3, -- src_header_id
          gt.num1,  -- vendor_id
          gt.num2,  -- vendor_site_id
          gt.char1, -- currency code
          gt.num5,  -- org_id
          gt.num6,  -- style_id
          /*Source Doc Header attributes*/
          NVL(pha.global_agreement_flag, 'N'),
          NVL(pha.enable_all_sites, 'N'),
          pha.vendor_id,
          pha.vendor_site_id,
          pha.currency_code,
          pha.org_id,
          NVL(pha.closed_code, 'OPEN'),
          NVL(pha.cancel_flag, 'N'),
          NVL(pha.frozen_flag, 'N'),
          NVL(pha.user_hold_flag,'N'),
          pha.start_date,
          pha.end_date,
          NVL(pha.authorization_status, 'INCOMPLETE'),
          pha.approved_date,
          NVL(pha.approved_flag,'N'),
          pha.style_id
       FROM po_headers_all pha,
             po_session_gt gt
      WHERE gt.key = l_key
        AND  pha.type_lookup_code = 'CONTRACT'
        AND gt.num3 = pha.po_header_id;

  BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_from_header_id_tbl', p_from_header_id_tbl);
         po_log.proc_begin(d_mod, 'p_from_line_id_tbl', p_from_line_id_tbl);
         po_log.proc_begin(d_mod, 'p_contract_id_tbl', p_contract_id_tbl);
         po_log.proc_begin(d_mod, 'p_org_id_tbl', p_org_id_tbl);
         po_log.proc_begin(d_mod, 'p_item_id_tbl', p_item_id_tbl);
         po_log.proc_begin(d_mod, 'p_item_rev_tbl', p_item_rev_tbl);
         po_log.proc_begin(d_mod, 'p_item_descp_tbl', p_item_descp_tbl);
         po_log.proc_begin(d_mod, 'p_job_id_tbl', p_job_id_tbl);
         po_log.proc_begin(d_mod, 'p_order_type_lookup_tbl', p_order_type_lookup_tbl);
         po_log.proc_begin(d_mod, 'p_purchase_basis_tbl', p_purchase_basis_tbl);
         po_log.proc_begin(d_mod, 'p_matching_basis_tbl', p_matching_basis_tbl);
         po_log.proc_begin(d_mod, 'p_category_id', p_category_id);
         po_log.proc_begin(d_mod, 'p_uom_tbl', p_uom_tbl);
         po_log.proc_begin(d_mod, 'p_vendor_id_tbl', p_vendor_id_tbl);
         po_log.proc_begin(d_mod, 'p_vendor_site_id_tbl', p_vendor_site_id_tbl);
         po_log.proc_begin(d_mod, 'p_currency_code_tbl', p_currency_code_tbl);
         po_log.proc_begin(d_mod, 'p_style_id_tbl', p_style_id_tbl);
         po_log.proc_begin(d_mod, 'p_unit_price_tbl', p_unit_price_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      l_key := PO_CORE_S.get_session_gt_nextval();

      -- Insert Header attributes in po_session_gt
      FORALL i IN 1..p_id_tbl.COUNT
        INSERT INTO po_session_gt
        (key,
         index_num1, -- p_id
         num1,       -- vendor_id
         num2,       -- vendor_site_id
         char1,      -- currency_code
         num3,        -- src_doc_header_id
         num4,        -- job_id
         num5,        -- org_id
         num6         -- style_id
         )
         SELECT
            l_key,
            p_id_tbl(i),
            p_vendor_id_tbl(i),
            p_vendor_site_id_tbl(i),
            p_currency_code_tbl(i),
            NVL(p_from_header_id_tbl(i), p_contract_id_tbl(i)),
            p_job_id_tbl(i), -- Adding job_id here as lines_gt does not have job_id column
            p_org_id_tbl(i),
            p_style_id_tbl(i)
         FROM dual
         WHERE (p_from_header_id_tbl(i) IS NOT NULL
                OR p_contract_id_tbl(i) IS NOT NULL);

      -- Insert line attributes for Source Doc Blanket.
      FORALL i IN 1..p_id_tbl.COUNT
        INSERT INTO po_lines_gt
        (
          po_line_id, -- interface_id
          from_header_id,
          from_line_id,
          item_id,
          item_revision,
          item_description,
          order_type_lookup_code,
          purchase_basis,
          matching_basis,
          category_id,
          unit_meas_lookup_code,
          unit_price
        )
        SELECT
          p_id_tbl(i),
          p_from_header_id_tbl(i),
          p_from_line_id_tbl(i),
          p_item_id_tbl(i),
          p_item_rev_tbl(i),
          p_item_descp_tbl(i),
          p_order_type_lookup_tbl(i),
          p_purchase_basis_tbl(i),
          p_matching_basis_tbl(i),
          p_category_id(i),
          p_uom_tbl(i),
          p_unit_price_tbl(i)
        FROM dual
        WHERE p_from_header_id_tbl(i) IS NOT NULL;

     OPEN blanket_details;

     FETCH blanket_details
     BULK COLLECT INTO
        l_blanket.INTERFACE_ID,
        l_blanket.SRC_DOC_TYPE,
        l_blanket.SRC_HEADER_ID,
        l_blanket.HDR_VENDOR_ID,
        l_blanket.HDR_VENDOR_SITE_ID,
        l_blanket.HDR_CURRENCY_CODE,
        l_blanket.ORG_ID,
        l_blanket.HDR_STYLE_ID,

        l_blanket.SRC_LINE_ID,
        l_blanket.ITEM_ID,
        l_blanket.ITEM_REVISION,
        l_blanket.ITEM_DESCRIPTION,
        l_blanket.JOB_ID,
        l_blanket.ORDER_TYPE_LOOKUP_CODE,
        l_blanket.PURCHASE_BASIS,
        l_blanket.MATCHING_BASIS,
        l_blanket.CATEGORY_ID,
        l_blanket.UNIT_MEAS_LOOKUP_CODE,
        l_blanket.UNIT_PRICE,

        l_blanket.SRC_GLOBAL_AGREEMENT_FLAG,
        l_blanket.SRC_ENABLE_ALL_SITES,
        l_blanket.SRC_VENDOR_ID,
        l_blanket.SRC_VENDOR_SITE_ID,
        l_blanket.SRC_CURRENCY_CODE,
        l_blanket.SRC_ORG_ID,
        l_blanket.SRC_CLOSED_CODE,
        l_blanket.SRC_CANCEL_FLAG,
        l_blanket.SRC_FROZEN_FLAG,
        l_blanket.SRC_USER_HOLD_FLAG,
        l_blanket.SRC_START_DATE,
        l_blanket.SRC_END_DATE,
        l_blanket.SRC_AUTH_STATUS,
        l_blanket.SRC_APPROVED_DATE,
        l_blanket.SRC_APPROVED_FLAG,
        l_blanket.SRC_STYLE_ID,

        l_blanket.SRC_LINE_ITEM_ID,
        l_blanket.SRC_LINE_ITEM_REVISION,
        l_blanket.SRC_LINE_ITEM_DESCRIPTION,
        l_blanket.SRC_JOB_ID,
        l_blanket.SRC_LINE_CANCEL_FLAG,
        l_blanket.SRC_LINE_CLOSED_CODE,
        l_blanket.SRC_LINE_TYPE_LOOKUP_CODE,
        l_blanket.SRC_LINE_PURCHASE_BASIS,
        l_blanket.SRC_LINE_MATCHING_BASIS,
        l_blanket.SRC_LINE_CATEGORY_ID,
        l_blanket.SRC_LINE_UOM,
        l_blanket.SRC_LINE_EXPIRATION_DATE,
        l_blanket.SRC_LINE_ALLOW_PRICE_OVR;

     CLOSE blanket_details;

     IF l_blanket.INTERFACE_ID.COUNT > 0 THEN
         PO_VALIDATIONS.validate_source_doc(  p_source_doc        => l_blanket ,
                                              p_source_doc_type   => 'BLANKET',
                                              x_result_type       => x_result_type,
                                              x_result_set_id     => x_result_set_id,
                                              x_results           => x_results);
     END IF;

     OPEN contract_details;

     FETCH contract_details
     BULK COLLECT INTO
        l_contract.INTERFACE_ID,
        l_contract.SRC_DOC_TYPE,
        l_contract.SRC_HEADER_ID,
        l_contract.HDR_VENDOR_ID,
        l_contract.HDR_VENDOR_SITE_ID,
        l_contract.HDR_CURRENCY_CODE,
        l_contract.ORG_ID,
        l_contract.HDR_STYLE_ID,

        l_contract.SRC_GLOBAL_AGREEMENT_FLAG,
        l_contract.SRC_ENABLE_ALL_SITES,
        l_contract.SRC_VENDOR_ID,
        l_contract.SRC_VENDOR_SITE_ID,
        l_contract.SRC_CURRENCY_CODE,
        l_contract.SRC_ORG_ID,
        l_contract.SRC_CLOSED_CODE,
        l_contract.SRC_CANCEL_FLAG,
        l_contract.SRC_FROZEN_FLAG,
        l_contract.SRC_USER_HOLD_FLAG,
        l_contract.SRC_START_DATE,
        l_contract.SRC_END_DATE,
        l_contract.SRC_AUTH_STATUS,
        l_contract.SRC_APPROVED_DATE,
        l_contract.SRC_APPROVED_FLAG,
        l_contract.SRC_STYLE_ID;

     CLOSE contract_details;

     IF l_contract.INTERFACE_ID.COUNT > 0 THEN
         PO_VALIDATIONS.validate_source_doc(  p_source_doc        => l_contract ,
                                              p_source_doc_type   => 'CONTRACT',
                                              x_result_type       => x_result_type,
                                              x_result_set_id     => x_result_set_id,
                                              x_results           => x_results);
     END IF;

     DELETE FROM po_session_gt
     WHERE key = l_key;

     FORALL i IN 1..l_blanket.INTERFACE_ID.COUNT
       DELETE FROM po_lines_gt
       WHERE po_line_id = l_blanket.INTERFACE_ID(i);

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
         po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;
         RAISE;
  END validate_source_doc;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source blanket exists in system
  -------------------------------------------------------------------------
  PROCEDURE validate_src_blanket_exists(
                    p_line_id_tbl        IN            PO_TBL_NUMBER
                  , p_src_doc_hdr_id_tbl IN            PO_TBL_NUMBER
                  , x_result_set_id      IN OUT NOCOPY NUMBER
                  , x_result_type        OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_blanket_exists;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_hdr_id_tbl',p_src_doc_hdr_id_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_FROM_HEADER_ID
  , TO_CHAR(p_src_doc_hdr_id_tbl(i))
  , 'PO_PDOI_SRC_BPA_NOT_EXIST'
  FROM dual
  WHERE p_src_doc_hdr_id_tbl(i) IS NOT NULL
  AND NOT EXISTS (SELECT 'exists'
                      FROM po_headers_all pha
                     WHERE pha.po_header_id = p_src_doc_hdr_id_tbl(i)
                       AND pha.type_lookup_code = 'BLANKET') ;

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_blanket_exists;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source contract exists in system
  -------------------------------------------------------------------------
  PROCEDURE validate_src_contract_exists(
                    p_line_id_tbl        IN            PO_TBL_NUMBER
                  , p_src_doc_hdr_id_tbl IN            PO_TBL_NUMBER
                  , x_result_set_id      IN OUT NOCOPY NUMBER
                  , x_result_type        OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_contract_exists;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_hdr_id_tbl',p_src_doc_hdr_id_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_CONTRACT_ID
  , TO_CHAR(p_src_doc_hdr_id_tbl(i))
  , 'PO_PDOI_SRC_CPA_NOT_EXIST'
  FROM dual
  WHERE p_src_doc_hdr_id_tbl(i) IS NOT NULL
  AND NOT EXISTS (SELECT 'exists'
                      FROM po_headers_all pha
                     WHERE pha.po_header_id = p_src_doc_hdr_id_tbl(i)
                       AND pha.type_lookup_code = 'CONTRACT') ;

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_contract_exists;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That only one source document is given either BLANKET or CONTRACT
  -------------------------------------------------------------------------
  PROCEDURE validate_src_only_one(
                    p_line_id_tbl        IN            PO_TBL_NUMBER
                  , p_from_hdr_id_tbl    IN            PO_TBL_NUMBER
                  , p_contract_id_tbl    IN            PO_TBL_NUMBER
                  , x_result_set_id      IN OUT NOCOPY NUMBER
                  , x_result_type        OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_only_one;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_from_hdr_id_tbl',p_from_hdr_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_contract_id_tbl',p_contract_id_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_FROM_HEADER_ID
  , TO_CHAR(p_from_hdr_id_tbl(i))
  , 'PO_PDOI_SRC_ONLY_ONE'
  FROM dual
  WHERE p_from_hdr_id_tbl(i) IS NOT NULL
  AND p_contract_id_tbl(i) IS NOT NULL;

    FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_CONTRACT_ID
  , TO_CHAR(p_contract_id_tbl(i))
  , 'PO_PDOI_SRC_ONLY_ONE'
  FROM dual
  WHERE p_from_hdr_id_tbl(i) IS NOT NULL
  AND p_contract_id_tbl(i) IS NOT NULL;

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_only_one;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source doc is global
  -------------------------------------------------------------------------
  PROCEDURE validate_src_doc_global(
                    p_line_id_tbl        IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl   IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl IN            PO_TBL_NUMBER
                  , p_src_doc_ga_flg_tbl IN            PO_TBL_VARCHAR1
                  , x_result_set_id      IN OUT NOCOPY NUMBER
                  , x_result_type        OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_doc_global;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_type_tbl',p_src_doc_type_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_hdr_id_tbl',p_src_doc_hdr_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_ga_flg_tbl',p_src_doc_ga_flg_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , decode(p_src_doc_type_tbl(i), 'BLANKET', c_FROM_HEADER_ID, 'CONTRACT', c_CONTRACT_ID)
  , TO_CHAR(p_src_doc_hdr_id_tbl(i))
  , 'PO_PDOI_SRC_NOT_GLOBAL'
  FROM dual
  WHERE p_src_doc_ga_flg_tbl(i) = 'N';

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_doc_global;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That vendor on referenced source doc is same as vendor on PO.
  -------------------------------------------------------------------------
  PROCEDURE validate_src_doc_vendor(
                    p_line_id_tbl           IN            PO_TBL_NUMBER
                  , p_vendor_id_tbl         IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl      IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl    IN            PO_TBL_NUMBER
                  , p_src_doc_vendor_id_tbl IN            PO_TBL_NUMBER
                  , x_result_set_id         IN OUT NOCOPY NUMBER
                  , x_result_type           OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_doc_vendor;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_vendor_id_tbl',p_vendor_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_type_tbl',p_src_doc_type_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_hdr_id_tbl',p_src_doc_hdr_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_vendor_id_tbl',p_src_doc_vendor_id_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;


  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , decode(p_src_doc_type_tbl(i), 'BLANKET', c_FROM_HEADER_ID, 'CONTRACT', c_CONTRACT_ID)
  , TO_CHAR(p_src_doc_hdr_id_tbl(i))
  , 'PO_PDOI_SRC_VEND_MIS'
  FROM dual
  WHERE p_vendor_id_tbl(i) <> p_src_doc_vendor_id_tbl(i);

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_doc_vendor;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source doc vendor site is valid.
  -------------------------------------------------------------------------
  PROCEDURE validate_src_doc_vendor_site(
                    p_line_id_tbl          IN            PO_TBL_NUMBER
                  , p_vendor_site_id_tbl   IN            PO_TBL_NUMBER
                  , p_org_id_tbl           IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl     IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl   IN            PO_TBL_NUMBER
                  , p_src_enable_all_sites IN            PO_TBL_VARCHAR1
                  , x_result_set_id        IN OUT NOCOPY NUMBER
                  , x_result_type          OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_doc_vendor_site;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_vendor_site_id_tbl',p_vendor_site_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_org_id_tbl',p_org_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_type_tbl',p_src_doc_type_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_hdr_id_tbl',p_src_doc_hdr_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_enable_all_sites',p_src_enable_all_sites);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;


  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , decode(p_src_doc_type_tbl(i), 'BLANKET', c_FROM_HEADER_ID, 'CONTRACT', c_CONTRACT_ID)
  , TO_CHAR(p_src_doc_hdr_id_tbl(i))
  , 'PO_PDOI_SRC_VSITE_MIS'
  FROM dual
  WHERE (p_vendor_site_id_tbl(i) IS NOT NULL
        AND NOT EXISTS (SELECT 'Enabled vendor site'
           FROM PO_GA_ORG_ASSIGNMENTS pgoa
          WHERE PGOA.po_header_id = p_src_doc_hdr_id_tbl(i)
            AND PGOA.vendor_site_id = decode(p_src_enable_all_sites(i),'N',p_vendor_site_id_tbl(i), PGOA.vendor_site_id)
            AND PGOA.enabled_flag = 'Y'))
      OR NOT EXISTS (SELECT 'org enabled for source doc'
	         FROM po_ga_org_assignments PGOA
	       WHERE PGOA.po_header_id = p_src_doc_hdr_id_tbl(i)
	           AND PGOA.purchasing_org_id = p_org_id_tbl(i)
	           AND PGOA.enabled_flag = 'Y');

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_doc_vendor_site;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source doc is approved
  -------------------------------------------------------------------------
  PROCEDURE validate_src_doc_approved(
                    p_line_id_tbl           IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl      IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl    IN            PO_TBL_NUMBER
                  , p_src_auth_status_tbl   IN            PO_TBL_VARCHAR30
                  , p_src_approved_date_tbl IN            PO_TBL_DATE
                  , p_src_approved_flag_tbl IN            PO_TBL_VARCHAR1
                  , x_result_set_id         IN OUT NOCOPY NUMBER
                  , x_result_type           OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_doc_approved;
  l_allow_cpa_under_amd VARCHAR2(1);

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_type_tbl',p_src_doc_type_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_hdr_id_tbl',p_src_doc_hdr_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_auth_status_tbl',p_src_auth_status_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_approved_date_tbl',p_src_approved_date_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_approved_flag_tbl',p_src_approved_flag_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  l_allow_cpa_under_amd := NVL(FND_PROFILE.VALUE('ALLOW_REFERENCING_CPA_UNDER_AMENDMENT'), 'N');

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , decode(p_src_doc_type_tbl(i), 'BLANKET', c_FROM_HEADER_ID, 'CONTRACT', c_CONTRACT_ID)
  , TO_CHAR(p_src_doc_hdr_id_tbl(i))
  , 'PO_PDOI_SRC_NOT_APPR'
  FROM dual
  WHERE (p_src_doc_type_tbl(i) = 'BLANKET'
        AND p_src_auth_status_tbl(i) <> 'APPROVED')
  OR (p_src_doc_type_tbl(i) = 'CONTRACT'
      AND ((l_allow_cpa_under_amd = 'Y'
           AND p_src_approved_date_tbl(i) IS NULL)
           OR (l_allow_cpa_under_amd = 'N'
              AND p_src_approved_flag_tbl(i) <> 'Y')));

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_doc_approved;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source doc is not on hold.
  -------------------------------------------------------------------------
  PROCEDURE validate_src_doc_hold(
                    p_line_id_tbl          IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl     IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl   IN            PO_TBL_NUMBER
                  , p_src_doc_hold_flg_tbl IN            PO_TBL_VARCHAR1
                  , x_result_set_id        IN OUT NOCOPY NUMBER
                  , x_result_type          OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_doc_hold;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_type_tbl',p_src_doc_type_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_hdr_id_tbl',p_src_doc_hdr_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_hold_flg_tbl',p_src_doc_hold_flg_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , decode(p_src_doc_type_tbl(i), 'BLANKET', c_FROM_HEADER_ID, 'CONTRACT', c_CONTRACT_ID)
  , TO_CHAR(p_src_doc_hdr_id_tbl(i))
  , 'PO_PDOI_SRC_ON_HOLD'
  FROM dual
  WHERE p_src_doc_hold_flg_tbl(i) = 'Y';

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_doc_hold;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate currency of referenced GBPA is same as that of PO.
  -- In case of GCPA, currency is allowed to differ if it is in same OU.
  -------------------------------------------------------------------------
  PROCEDURE validate_src_doc_currency(
                    p_line_id_tbl          IN            PO_TBL_NUMBER
                  , p_currency_tbl         IN            PO_TBL_VARCHAR30
                  , p_org_id_tbl           IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl     IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl   IN            PO_TBL_NUMBER
                  , p_src_doc_currency_tbl IN            PO_TBL_VARCHAR30
                  , p_src_doc_org_id_tbl   IN            PO_TBL_NUMBER
                  , x_result_set_id        IN OUT NOCOPY NUMBER
                  , x_result_type          OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_doc_currency;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_currency_tbl',p_currency_tbl);
    PO_LOG.proc_begin(d_mod,'p_org_id_tbl',p_org_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_type_tbl',p_src_doc_type_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_hdr_id_tbl',p_src_doc_hdr_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_currency_tbl',p_src_doc_currency_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_org_id_tbl',p_src_doc_org_id_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , decode(p_src_doc_type_tbl(i), 'BLANKET', c_FROM_HEADER_ID, 'CONTRACT', c_CONTRACT_ID)
  , TO_CHAR(p_src_doc_hdr_id_tbl(i))
  , decode(p_src_doc_type_tbl(i), 'BLANKET', 'PO_PDOI_SRC_BPA_CUR_MIS', 'CONTRACT', 'PO_PDOI_SRC_CPA_CUR_MIS')
  FROM dual
  WHERE (p_src_doc_type_tbl(i) = 'BLANKET'
          AND p_currency_tbl(i) <> p_src_doc_currency_tbl(i))
     OR (p_src_doc_type_tbl(i) = 'CONTRACT'
        AND p_org_id_tbl(i) <> p_src_doc_org_id_tbl(i)
        AND p_currency_tbl(i) <> p_src_doc_currency_tbl(i));


  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_doc_currency;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source doc is open
  -------------------------------------------------------------------------
  PROCEDURE validate_src_doc_closed_code(
                    p_line_id_tbl             IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl        IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl      IN            PO_TBL_NUMBER
                  , p_src_doc_closed_code_tbl IN            PO_TBL_VARCHAR30
                  , x_result_set_id           IN OUT NOCOPY NUMBER
                  , x_result_type             OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_doc_closed_code;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_type_tbl',p_src_doc_type_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_hdr_id_tbl',p_src_doc_hdr_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_closed_code_tbl',p_src_doc_closed_code_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , decode(p_src_doc_type_tbl(i), 'BLANKET', c_FROM_HEADER_ID, 'CONTRACT', c_CONTRACT_ID)
  , TO_CHAR(p_src_doc_hdr_id_tbl(i))
  , 'PO_PDOI_SRC_NOT_OPEN'
  FROM dual
  WHERE p_src_doc_closed_code_tbl(i) <> 'OPEN';

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_doc_closed_code;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source doc is not cancelled.
  -------------------------------------------------------------------------
  PROCEDURE validate_src_doc_cancel(
                    p_line_id_tbl            IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl       IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl     IN            PO_TBL_NUMBER
                  , p_src_doc_cancel_flg_tbl IN            PO_TBL_VARCHAR1
                  , x_result_set_id          IN OUT NOCOPY NUMBER
                  , x_result_type            OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_doc_cancel;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_type_tbl',p_src_doc_type_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_hdr_id_tbl',p_src_doc_hdr_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_cancel_flg_tbl',p_src_doc_cancel_flg_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , decode(p_src_doc_type_tbl(i), 'BLANKET', c_FROM_HEADER_ID, 'CONTRACT', c_CONTRACT_ID)
  , TO_CHAR(p_src_doc_hdr_id_tbl(i))
  , 'PO_PDOI_SRC_CANCEL'
  FROM dual
  WHERE p_src_doc_cancel_flg_tbl(i) = 'Y';

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_doc_cancel;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source doc is not frozen.
  -------------------------------------------------------------------------
  PROCEDURE validate_src_doc_frozen(
                    p_line_id_tbl            IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl       IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl     IN            PO_TBL_NUMBER
                  , p_src_doc_frozen_flg_tbl IN            PO_TBL_VARCHAR1
                  , x_result_set_id          IN OUT NOCOPY NUMBER
                  , x_result_type            OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_doc_frozen;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_type_tbl',p_src_doc_type_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_hdr_id_tbl',p_src_doc_hdr_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_frozen_flg_tbl',p_src_doc_frozen_flg_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , decode(p_src_doc_type_tbl(i), 'BLANKET', c_FROM_HEADER_ID, 'CONTRACT', c_CONTRACT_ID)
  , TO_CHAR(p_src_doc_hdr_id_tbl(i))
  , 'PO_PDOI_SRC_FROZEN'
  FROM dual
  WHERE p_src_doc_frozen_flg_tbl(i) = 'Y';

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_doc_frozen;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That sysdate <= NVL(expiration_date,
  -- end_date of referenced doc + PO_REL_CREATE_TOLERANCE.)
  -------------------------------------------------------------------------
  PROCEDURE validate_src_bpa_expiry_date(
                    p_line_id_tbl            IN            PO_TBL_NUMBER
                  , p_src_doc_hdr_id_tbl     IN            PO_TBL_NUMBER
                  , p_src_doc_end_date_tbl   IN            PO_TBL_DATE
                  , p_src_doc_expiration_tbl IN            PO_TBL_DATE
                  , x_result_set_id          IN OUT NOCOPY NUMBER
                  , x_result_type            OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_bpa_expiry_date;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_hdr_id_tbl',p_src_doc_hdr_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_end_date_tbl',p_src_doc_end_date_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_expiration_tbl',p_src_doc_expiration_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_FROM_HEADER_ID
  , TO_CHAR(p_src_doc_hdr_id_tbl(i))
  , 'PO_SUB_STD_AFTER_GA_DATE'
  FROM dual
  WHERE TRUNC(sysdate) > TRUNC(COALESCE(p_src_doc_expiration_tbl(i),
                                        p_src_doc_end_date_tbl(i) + NVL(FND_PROFILE.VALUE('PO_REL_CREATE_TOLERANCE'), 0),
                                        sysdate));

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_bpa_expiry_date;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That sysdate <=
  -- end_date of referenced doc + PO_REL_CREATE_TOLERANCE
  -------------------------------------------------------------------------
  PROCEDURE validate_src_cpa_expiry_date(
                    p_line_id_tbl            IN            PO_TBL_NUMBER
                  , p_src_doc_hdr_id_tbl     IN            PO_TBL_NUMBER
                  , p_src_doc_end_date_tbl   IN            PO_TBL_DATE
                  , x_result_set_id          IN OUT NOCOPY NUMBER
                  , x_result_type            OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_cpa_expiry_date;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_hdr_id_tbl',p_src_doc_hdr_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_end_date_tbl',p_src_doc_end_date_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_CONTRACT_ID
  , TO_CHAR(p_src_doc_hdr_id_tbl(i))
  , 'PO_SUB_STD_AFTER_GA_DATE'
  FROM dual
  WHERE TRUNC(sysdate) > TRUNC(NVL(p_src_doc_end_date_tbl(i) + NVL(FND_PROFILE.VALUE('PO_REL_CREATE_TOLERANCE'), 0),
                                   sysdate));

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_cpa_expiry_date;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That style of referenced source doc is same as the PO.
  -------------------------------------------------------------------------
  PROCEDURE validate_src_doc_style(
                    p_line_id_tbl            IN            PO_TBL_NUMBER
                  , p_style_id_tbl           IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl       IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl     IN            PO_TBL_NUMBER
                  , p_src_doc_style_id_tbl   IN            PO_TBL_NUMBER
                  , x_result_set_id          IN OUT NOCOPY NUMBER
                  , x_result_type            OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_doc_style;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_style_id_tbl',p_style_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_type_tbl',p_src_doc_type_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_hdr_id_tbl',p_src_doc_hdr_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_style_id_tbl',p_src_doc_style_id_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , decode(p_src_doc_type_tbl(i), 'BLANKET', c_FROM_HEADER_ID, 'CONTRACT', c_CONTRACT_ID)
  , TO_CHAR(p_src_doc_hdr_id_tbl(i))
  , 'PO_PDOI_SRC_STYLE_MIS'
  FROM dual
  WHERE p_style_id_tbl(i) <> p_src_doc_style_id_tbl(i);

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_doc_style;


  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That from_line_id is not NULL if from_header_id is populated.
  -------------------------------------------------------------------------
  PROCEDURE validate_src_line_not_null(
                   p_line_id_tbl         IN            PO_TBL_NUMBER
                 , p_src_doc_hdr_id_tbl  IN            PO_TBL_NUMBER
                 , p_src_doc_line_id_tbl IN            PO_TBL_NUMBER
                 , x_result_set_id       IN OUT NOCOPY NUMBER
                 , x_result_type         OUT    NOCOPY VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := D_validate_src_line_not_null;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_hdr_id_tbl',p_src_doc_hdr_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_line_id_tbl',p_src_doc_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  , token1_name
  , token1_value
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_FROM_LINE_ID
  , TO_CHAR(p_src_doc_line_id_tbl(i))
  , 'PO_PDOI_COLUMN_NOT_NULL'
  , 'COLUMN_NAME'
  , c_FROM_LINE_ID
  FROM dual
  WHERE p_src_doc_hdr_id_tbl(i) IS NOT NULL
    AND p_src_doc_line_id_tbl(i) IS NULL;

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_line_not_null;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source item is same as that on PO.
  -------------------------------------------------------------------------
  PROCEDURE validate_src_line_item(
                    p_line_id_tbl         IN            PO_TBL_NUMBER
                  , p_item_id_tbl         IN            PO_TBL_NUMBER
                  , p_item_descp_tbl      IN            PO_TBL_VARCHAR2000
                  , p_category_id_tbl     IN            PO_TBL_NUMBER
                  , p_src_doc_line_id_tbl IN            PO_TBL_NUMBER
                  , p_src_item_id_tbl     IN            PO_TBL_NUMBER
                  , p_src_item_descp_tbl  IN            PO_TBL_VARCHAR2000
                  , p_src_category_id_tbl IN            PO_TBL_NUMBER
                  , x_result_set_id       IN OUT NOCOPY NUMBER
                  , x_result_type         OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_line_item;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_item_id_tbl',p_item_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_item_descp_tbl',p_item_descp_tbl);
    PO_LOG.proc_begin(d_mod,'p_category_id_tbl',p_category_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_line_id_tbl',p_src_doc_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_item_id_tbl',p_src_item_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_item_descp_tbl',p_src_item_descp_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_category_id_tbl',p_src_category_id_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_FROM_LINE_ID
  , TO_CHAR(p_src_doc_line_id_tbl(i))
  , 'PO_PDOI_SRC_ITEM_MIS'
  FROM dual
  WHERE NVL(p_item_id_tbl(i), -9999) <> NVL(p_src_item_id_tbl(i), -9999)
        OR NVL(p_item_descp_tbl(i), 'NULL') <> NVL(p_src_item_descp_tbl(i), 'NULL')
        OR NVL(p_category_id_tbl(i), -9999) <> NVL(p_src_category_id_tbl(i), -9999);

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_line_item;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source line item revision is same as that on PO.
  -------------------------------------------------------------------------
  PROCEDURE validate_src_line_item_rev(
                    p_line_id_tbl        IN            PO_TBL_NUMBER
                  , p_item_rev_tbl       IN            PO_TBL_VARCHAR5
                  , p_src_doc_line_id_tbl IN            PO_TBL_NUMBER
                  , p_src_item_rev_tbl   IN            PO_TBL_VARCHAR5
                  , x_result_set_id      IN OUT NOCOPY NUMBER
                  , x_result_type        OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_line_item_rev;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_item_rev_tbl',p_item_rev_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_line_id_tbl',p_src_doc_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_item_rev_tbl',p_src_item_rev_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_FROM_LINE_ID
  , TO_CHAR(p_src_doc_line_id_tbl(i))
  , 'PO_PDOI_SRC_ITEM_REV_MIS'
  FROM dual
  WHERE (p_item_rev_tbl(i) IS NOT NULL
      AND p_src_item_rev_tbl(i) IS NULL)
  OR (p_item_rev_tbl(i) IS NULL
      AND p_src_item_rev_tbl(i) IS NOT NULL)
  OR (p_item_rev_tbl(i) IS NOT NULL
      AND p_src_item_rev_tbl(i) IS NOT NULL
      AND p_item_rev_tbl(i) <> p_src_item_rev_tbl(i));

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_line_item_rev;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source line job is same as that on PO.
  -------------------------------------------------------------------------
  PROCEDURE validate_src_line_job(
                    p_line_id_tbl        IN            PO_TBL_NUMBER
                  , p_job_id_tbl         IN            PO_TBL_NUMBER
                  , p_src_doc_line_id_tbl IN            PO_TBL_NUMBER
                  , p_src_job_id_tbl     IN            PO_TBL_NUMBER
                  , x_result_set_id      IN OUT NOCOPY NUMBER
                  , x_result_type        OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_line_job;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_job_id_tbl',p_job_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_line_id_tbl',p_src_doc_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_job_id_tbl',p_src_job_id_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_FROM_LINE_ID
  , TO_CHAR(p_src_doc_line_id_tbl(i))
  , 'PO_PDOI_SRC_JOB_MIS'
  FROM dual
  WHERE (p_job_id_tbl(i) IS NULL
      AND p_src_job_id_tbl(i) IS NOT NULL)
  OR (p_job_id_tbl(i) IS NOT NULL
      AND p_src_job_id_tbl(i) IS NULL)
  OR (p_job_id_tbl(i) IS NOT NULL
      AND p_src_job_id_tbl(i) IS NOT NULL
      AND p_job_id_tbl(i) <> p_src_job_id_tbl(i));

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_line_job;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source line is not cancelled.
  -------------------------------------------------------------------------
  PROCEDURE validate_src_line_cancel_flag(
                    p_line_id_tbl         IN            PO_TBL_NUMBER
                  , p_src_doc_line_id_tbl IN            PO_TBL_NUMBER
                  , p_src_line_cancel_tbl IN            PO_TBL_VARCHAR1
                  , x_result_set_id       IN OUT NOCOPY NUMBER
                  , x_result_type         OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_line_cancel;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_line_id_tbl',p_src_doc_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_line_cancel_tbl',p_src_line_cancel_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_FROM_LINE_ID
  , TO_CHAR(p_src_doc_line_id_tbl(i))
  , 'PO_PDOI_SRC_LINE_CANCEL'
  FROM dual
  WHERE p_src_line_cancel_tbl(i) = 'Y';

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_line_cancel_flag;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source line is OPEN
  -------------------------------------------------------------------------
  PROCEDURE validate_src_line_closed_code(
                    p_line_id_tbl         IN            PO_TBL_NUMBER
                  , p_src_doc_line_id_tbl IN            PO_TBL_NUMBER
                  , p_src_line_closed_tbl IN            PO_TBL_VARCHAR30
                  , x_result_set_id       IN OUT NOCOPY NUMBER
                  , x_result_type         OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_line_closed;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_line_id_tbl',p_src_doc_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_line_closed_tbl',p_src_line_closed_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_FROM_LINE_ID
  , TO_CHAR(p_src_doc_line_id_tbl(i))
  , 'PO_PDOI_SRC_LINE_NOT_OPEN'
  FROM dual
  WHERE p_src_line_closed_tbl(i) <> 'OPEN';

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_line_closed_code;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source line order_type_lookup_code
  -- is same as that on PO.
  -------------------------------------------------------------------------
  PROCEDURE validate_src_line_order_type(
                    p_line_id_tbl             IN            PO_TBL_NUMBER
                  , p_order_type_lookup_tbl   IN            PO_TBL_VARCHAR30
                  , p_src_doc_line_id_tbl     IN            PO_TBL_NUMBER
                  , p_src_line_order_type_tbl IN            PO_TBL_VARCHAR30
                  , x_result_set_id           IN OUT NOCOPY NUMBER
                  , x_result_type             OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_line_order_type;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_order_type_lookup_tbl',p_order_type_lookup_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_line_id_tbl',p_src_doc_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_line_order_type_tbl',p_src_line_order_type_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_FROM_LINE_ID
  , TO_CHAR(p_src_doc_line_id_tbl(i))
  , 'PO_PDOI_SRC_ORDERTYPE_MIS'
  FROM dual
  WHERE p_order_type_lookup_tbl(i) <> p_src_line_order_type_tbl(i);

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_line_order_type;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source line purchase basis
  -- is same as that on PO.
  -------------------------------------------------------------------------
  PROCEDURE validate_src_line_pur_basis(
                    p_line_id_tbl           IN            PO_TBL_NUMBER
                  , p_purchase_basis_tbl    IN            PO_TBL_VARCHAR30
                  , p_src_doc_line_id_tbl   IN            PO_TBL_NUMBER
                  , p_src_line_purchase_tbl IN            PO_TBL_VARCHAR30
                  , x_result_set_id         IN OUT NOCOPY NUMBER
                  , x_result_type           OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_line_pur_basis;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_purchase_basis_tbl',p_purchase_basis_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_line_id_tbl',p_src_doc_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_line_purchase_tbl',p_src_line_purchase_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_FROM_LINE_ID
  , TO_CHAR(p_src_doc_line_id_tbl(i))
  , 'PO_PDOI_SRC_PUR_BAS_MIS'
  FROM dual
  WHERE p_purchase_basis_tbl(i) <> p_src_line_purchase_tbl(i);

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_line_pur_basis;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source line matching basis
  -- is same as that on PO.
  -------------------------------------------------------------------------
  PROCEDURE validate_src_line_match_basis(
                    p_line_id_tbl           IN            PO_TBL_NUMBER
                  , p_matching_basis_tbl    IN            PO_TBL_VARCHAR30
                  , p_src_doc_line_id_tbl   IN            PO_TBL_NUMBER
                  , p_src_line_matching_tbl IN            PO_TBL_VARCHAR30
                  , x_result_set_id         IN OUT NOCOPY NUMBER
                  , x_result_type           OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_line_match;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_matching_basis_tbl',p_matching_basis_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_line_id_tbl',p_src_doc_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_line_matching_tbl',p_src_line_matching_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_FROM_LINE_ID
  , TO_CHAR(p_src_doc_line_id_tbl(i))
  , 'PO_PDOI_SRC_MAT_BAS_MIS'
  FROM dual
  WHERE p_matching_basis_tbl(i) <> p_src_line_matching_tbl(i);

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_line_match_basis;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That referenced source line UOM
  -- is same as that on PO.
  -------------------------------------------------------------------------
  PROCEDURE validate_src_line_uom(
                    p_line_id_tbl           IN            PO_TBL_NUMBER
                  , p_uom_tbl               IN            PO_TBL_VARCHAR30
                  , p_src_doc_line_id_tbl   IN            PO_TBL_NUMBER
                  , p_src_line_uom_tbl      IN            PO_TBL_VARCHAR30
                  , x_result_set_id         IN OUT NOCOPY NUMBER
                  , x_result_type           OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_line_uom;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_uom_tbl',p_uom_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_doc_line_id_tbl',p_src_doc_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_line_uom_tbl',p_src_line_uom_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_FROM_LINE_ID
  , TO_CHAR(p_src_doc_line_id_tbl(i))
  , 'PO_PDOI_SRC_UOM_MIS'
  FROM dual
  WHERE p_uom_tbl(i) <> p_src_line_uom_tbl(i);

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_line_uom;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- To Validate That if allow price override is N in source blanket line
  -- then user cannot give unit_price.
  -------------------------------------------------------------------------
  PROCEDURE validate_src_allow_price_ovr(
                    p_line_id_tbl           IN            PO_TBL_NUMBER
                  , p_unit_price_tbl        IN            PO_TBL_NUMBER
                  , p_src_allow_price_tbl   IN            PO_TBL_VARCHAR1
                  , x_result_set_id         IN OUT NOCOPY NUMBER
                  , x_result_type           OUT NOCOPY    VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_src_allow_price_ovr;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_unit_price_tbl',p_unit_price_tbl);
    PO_LOG.proc_begin(d_mod,'p_src_allow_price_tbl',p_src_allow_price_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_UNIT_PRICE
  , TO_CHAR(p_unit_price_tbl(i))
  , 'PO_PDOI_PRICE_NOT_ALLWD'
  FROM dual
  WHERE p_unit_price_tbl(i) IS NOT NULL
  AND p_src_allow_price_tbl(i) = 'N';

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

  END validate_src_allow_price_ovr;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- Validate Req Reference
  -------------------------------------------------------------------------
  PROCEDURE validate_req_reference(
                       p_id_tbl                       IN              po_tbl_number,
                       p_po_line_id_tbl               IN              po_tbl_number,
                       p_req_line_id_tbl              IN              po_tbl_number,
                       p_from_header_id_tbl           IN              po_tbl_number,
                       p_contract_id_tbl              IN              po_tbl_number,
                       p_style_id_tbl                 IN              po_tbl_number,
                       p_purchasing_org_id_tbl        IN              po_tbl_number,
                       p_item_id_tbl                  IN              po_tbl_number,
                       p_job_id_tbl                   IN              po_tbl_number,
                       p_purchase_basis_tbl           IN              po_tbl_varchar30,
                       p_matching_basis_tbl           IN              po_tbl_varchar30,
                       p_document_type_tbl            IN              po_tbl_varchar30,
                       p_cons_from_supp_flag_tbl      IN              po_tbl_varchar1,
                       p_txn_flow_header_id_tbl       IN              po_tbl_number,
                       p_vendor_id_tbl                IN              po_tbl_number,
                       p_vendor_site_id_tbl           IN              po_tbl_number,
                       x_results                      IN OUT NOCOPY   po_validation_results_type,
                       x_result_set_id                IN OUT NOCOPY   NUMBER,
                       x_result_type                  OUT NOCOPY      VARCHAR2)
  IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_req_reference;
  l_key NUMBER;

  CURSOR req_details IS
      SELECT gt.index_num1, -- p_id
             gt.num1,       -- po_line_id
             gt.num2,       -- req_line_id
             gt.num3,       -- from_header_id
             gt.num4,       -- style_id
             gt.num5,       -- purchasing_org_id
             gt.num6,       -- item_id
             gt.num7,       -- job_id
             gt.num8,       -- vendor_id
             gt.num9,       -- vendor_site_id
             gt.num10,      -- txn_flow_header_id
             gt.char1,      -- document_type_tbl
             gt.char2,      -- cons_from_supp_flag
             gt.char3,      -- purchase basis
             gt.char4,      -- matching basis
             gt.char5,      -- source_doc_type
             NVL(prl.reqs_in_pool_flag, 'N'),
             NVL(prl.vmi_flag, 'N'),
             prh.pcard_id,
             prh.emergency_po_num,
             prh.org_id,
             prl.item_id,
             prl.job_id,
             prl.purchase_basis,
             prl.matching_basis,
             prl.line_type_id,
             prl.destination_type_code,
             prl.order_type_lookup_code,
             TO_NUMBER(hoi.org_information3),
             prl.deliver_to_location_id,
             nvl(prl.destination_organization_id, fsp.inventory_organization_id),
             NVL(prh.authorization_status,'INCOMPLETE'),
             prl.supplier_ref_number,
             NVL(prl.cancel_flag,'N'),
             NVL(prl.closed_code,'OPEN'),
             NVL(prl.modified_by_agent_flag,'N'),
             prl.line_location_id,
             NVL(prl.at_sourcing_flag,'N'),
             pv.vendor_id,
             pvs.vendor_site_id
      FROM po_requisition_headers_all prh,
           po_requisition_lines_all prl,
           financials_system_params_all fsp,
           hr_organization_information hoi,
           mtl_parameters mp,
           po_session_gt gt,
           po_vendors pv,
           po_vendor_sites pvs
      WHERE gt.key = l_key
        AND gt.num2 = prl.requisition_line_id
        AND prl.requisition_header_id     = prh.requisition_header_id
        AND prl.org_id                    = fsp.org_id
        AND mp.organization_id            = prl.destination_organization_id
        AND mp.organization_id            = hoi.organization_id
        AND hoi.org_information_context   = 'Accounting Information'
        AND prl.suggested_vendor_name     = pv.vendor_name(+)
        AND prl.suggested_vendor_location = pvs.vendor_site_code(+);


  l_req_val_type PO_REQ_REF_VAL_TYPE := PO_REQ_REF_VAL_TYPE();
  BEGIN

      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF (x_results IS NULL) THEN
         x_results := po_validation_results_type.new_instance();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_id_tbl', p_id_tbl);
         po_log.proc_begin(d_mod, 'p_po_line_id_tbl', p_po_line_id_tbl);
         po_log.proc_begin(d_mod, 'p_req_line_id_tbl', p_req_line_id_tbl);
         po_log.proc_begin(d_mod, 'p_from_header_id_tbl', p_from_header_id_tbl);
         po_log.proc_begin(d_mod, 'p_contract_id_tbl', p_contract_id_tbl);
         po_log.proc_begin(d_mod, 'p_style_id_tbl', p_style_id_tbl);
         po_log.proc_begin(d_mod, 'p_item_id_tbl', p_item_id_tbl);
         po_log.proc_begin(d_mod, 'p_job_id_tbl', p_job_id_tbl);
         po_log.proc_begin(d_mod, 'p_purchase_basis_tbl', p_purchase_basis_tbl);
         po_log.proc_begin(d_mod, 'p_matching_basis_tbl', p_matching_basis_tbl);
         po_log.proc_begin(d_mod, 'p_purchasing_org_id_tbl', p_purchasing_org_id_tbl);
         po_log.proc_begin(d_mod, 'p_document_type_tbl', p_document_type_tbl);
         po_log.proc_begin(d_mod, 'p_cons_from_supp_flag_tbl', p_cons_from_supp_flag_tbl);
         po_log.proc_begin(d_mod, 'p_txn_flow_header_id_tbl', p_txn_flow_header_id_tbl);
         po_log.proc_begin(d_mod, 'p_vendor_id_tbl', p_vendor_id_tbl);
         po_log.proc_begin(d_mod, 'p_vendor_site_id_tbl', p_vendor_site_id_tbl);
         po_log.LOG(po_log.c_proc_begin, d_mod, NULL, 'x_results', x_results);
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;

      x_result_type := po_validations.c_result_type_success;

      l_key := PO_CORE_S.get_session_gt_nextval();

      FORALL i in 1..p_id_tbl.COUNT
        INSERT INTO po_session_gt
        (
         key,
         index_num1, --p_id
         num1, -- po_line_id
         num2, -- req_line_id
         num3, -- from_header_id
         num4, -- style_id
         num5, -- purchasing_org_id
         num6, -- item_id
         num7, -- job_id
         num8, -- vendor_id
         num9, -- vendor_site_id
         num10,-- txn_flow_header_id
         char1,-- document_type_tbl
         char2,-- cons_from_supp_flag
         char3,-- purchase_basis
         char4,-- matching_basis
         char5 -- source_doc_type
        )
        SELECT l_key,
               p_id_tbl(i),
               p_po_line_id_tbl(i),
               p_req_line_id_tbl(i),
               NVL(p_from_header_id_tbl(i), p_contract_id_tbl(i)),
               p_style_id_tbl(i),
               p_purchasing_org_id_tbl(i),
               p_item_id_tbl(i),
               p_job_id_tbl(i),
               p_vendor_id_tbl(i),
               p_vendor_site_id_tbl(i),
               p_txn_flow_header_id_tbl(i),
               p_document_type_tbl(i),
               p_cons_from_supp_flag_tbl(i),
               p_purchase_basis_tbl(i),
               p_matching_basis_tbl(i),
               DECODE(p_from_header_id_tbl(i),
                           NULL, DECODE(p_contract_id_tbl(i),
                                           NULL, NULL,
                                           'CONTRACT'),
                           'BLANKET')
        FROM dual
        WHERE p_req_line_id_tbl(i) IS NOT NULL;

      OPEN req_details;

      FETCH req_details
      BULK COLLECT INTO l_req_val_type.INTERFACE_ID,
                        l_req_val_type.PO_LINE_ID,
                        l_req_val_type.REQUISITION_LINE_ID,
                        l_req_val_type.SOURCE_DOC_ID,
                        l_req_val_type.HDR_STYLE_ID,
                        l_req_val_type.ORG_ID,
                        l_req_val_type.ITEM_ID,
                        l_req_val_type.JOB_ID,
                        l_req_val_type.HDR_VENDOR_ID,
                        l_req_val_type.HDR_VENDOR_SITE_ID,
                        l_req_val_type.TXN_FLOW_HEADER_ID,
                        l_req_val_type.HDR_TYPE_LOOKUP_CODE,
                        l_req_val_type.CONS_FROM_SUPP_FLAG,
                        l_req_val_type.PURCHASE_BASIS,
                        l_req_val_type.MATCHING_BASIS,
                        l_req_val_type.SOURCE_DOC_TYPE,
                        l_req_val_type.REQS_IN_POOL_FLAG,
                        l_req_val_type.VMI_FLAG,
                        l_req_val_type.REQ_PCARD_ID,
                        l_req_val_type.REQ_EMERGENCY_PO_NUM,
                        l_req_val_type.REQUESTING_ORG_ID,
                        l_req_val_type.REQ_ITEM_ID,
                        l_req_val_type.REQ_JOB_ID,
                        l_req_val_type.REQ_PURCHASE_BASIS,
                        l_req_val_type.REQ_MATCHING_BASIS,
                        l_req_val_type.LINE_TYPE_ID,
                        l_req_val_type.DESTINATION_TYPE_CODE,
                        l_req_val_type.ORDER_TYPE_LOOKUP_CODE,
                        l_req_val_type.DEST_INV_ORG_OU_ID,
                        l_req_val_type.DELIVER_TO_LOCATION_ID,
                        l_req_val_type.DESTINATION_ORG_ID,
                        l_req_val_type.AUTHORIZATION_STATUS,
                        l_req_val_type.SUPPLIER_CONFIG_ID,
                        l_req_val_type.CANCEL_FLAG,
                        l_req_val_type.CLOSED_CODE,
                        l_req_val_type.MODIFIED_BY_AGENT_FLAG,
                        l_req_val_type.LINE_LOCATION_ID,
                        l_req_val_type.AT_SOURCING_FLAG,
                        l_req_val_type.SUGGESTED_VENDOR_ID,
                        l_req_val_type.SUGGESTED_VENDOR_SITE_ID;

      CLOSE req_details;

      DELETE FROM po_session_gt
       WHERE key = l_key;

      IF  l_req_val_type.INTERFACE_ID.COUNT > 0 THEN
          PO_VALIDATIONS.validate_req_reference(  p_req_reference     => l_req_val_type,
                                                  x_result_type       => x_result_type,
                                                  x_result_set_id     => x_result_set_id,
                                                  x_results           => x_results);
      END IF;

        IF po_log.d_proc THEN
           po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
           po_log.proc_end(d_mod, 'x_result_type', x_result_type);
           po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
           po_log.LOG(po_log.c_proc_end, d_mod, NULL, 'x_results', x_results);
        END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;
         RAISE;
  END validate_req_reference;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- Validate req exists in system
  -------------------------------------------------------------------------
  PROCEDURE validate_req_exists(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
  d_mod CONSTANT VARCHAR2(100) := D_validate_req_exists;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  -- Check reqs exists in system
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_NOT_EXIST'
  FROM dual
  WHERE p_req_line_id_tbl(i) IS NOT NULL
  AND NOT EXISTS (SELECT 'Y'
                    FROM po_requisition_lines_all prl,
                         po_requisition_headers_all prh
                    WHERE prl.requisition_line_id = p_req_line_id_tbl(i)
                    AND prl.requisition_header_id = prh.requisition_header_id);

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_req_exists;

    -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- Validate that if req reference is given then there
  -- should not be any records in shipment and distribution.
  -------------------------------------------------------------------------
  PROCEDURE validate_no_ship_dist(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
  d_mod CONSTANT VARCHAR2(100) := D_validate_no_ship_dist;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  -- Check shipment exists in interface.
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_SHIP_EXIST'
  FROM dual
  WHERE p_req_line_id_tbl(i) IS NOT NULL
    AND EXISTS (SELECT 'shipment interface exists'
                  FROM po_line_locations_interface
                 WHERE interface_line_id = p_line_id_tbl(i));

  -- Check distributions exists in interface.
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_DIST_EXIST'
  FROM dual
  WHERE p_req_line_id_tbl(i) IS NOT NULL
    AND EXISTS (SELECT 'distribution interface exists'
                  FROM po_distributions_interface
                 WHERE interface_line_id = p_line_id_tbl(i));

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_no_ship_dist;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- Validate req is approved
  -------------------------------------------------------------------------
  PROCEDURE validate_req_status(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_req_status_tbl       IN            PO_TBL_VARCHAR30
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
  d_mod CONSTANT VARCHAR2(100) := D_validate_req_status;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_status_tbl',p_req_status_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  -- Check reqs exists in system
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_NOT_APRV'
  FROM dual
  WHERE p_req_status_tbl(i) <> 'APPROVED';

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_req_status;


  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- Validate reqs_in_pool_flag = Y
  -------------------------------------------------------------------------
  PROCEDURE validate_reqs_in_pool_flag(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_reqs_in_pool_flg_tbl IN            PO_TBL_VARCHAR1
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
  d_mod CONSTANT VARCHAR2(100) := D_validate_reqs_in_pool_flag;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_reqs_in_pool_flg_tbl',p_reqs_in_pool_flg_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  -- Check reqs in pool flag
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_NOT_POOL'
  FROM dual
  WHERE p_reqs_in_pool_flg_tbl(i) <> 'Y';


  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_reqs_in_pool_flag;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- Validate req line is not cancelled.
  -------------------------------------------------------------------------
  PROCEDURE validate_reqs_cancel_flag(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_reqs_cancel_flag_tbl IN            PO_TBL_VARCHAR1
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
  d_mod CONSTANT VARCHAR2(100) := D_validate_reqs_cancel_flag;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_reqs_cancel_flag_tbl',p_reqs_cancel_flag_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  -- Check req is not cancelled
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_CANCEL'
  FROM dual
  WHERE p_reqs_cancel_flag_tbl(i) = 'Y';


  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_reqs_cancel_flag;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- Validate req line is open.
  -------------------------------------------------------------------------
  PROCEDURE validate_reqs_closed_code(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_reqs_closed_code_tbl IN            PO_TBL_VARCHAR30
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
  d_mod CONSTANT VARCHAR2(100) := D_validate_reqs_closed_code;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_reqs_closed_code_tbl',p_reqs_closed_code_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  -- Check reqs closed_code is not closed.
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_NOT_OPEN'
  FROM dual
  WHERE p_reqs_closed_code_tbl(i) <> 'OPEN';


  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_reqs_closed_code;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- Validate req modified by agent flag <> Y
  -------------------------------------------------------------------------
  PROCEDURE validate_reqs_modfd_by_agt(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_reqs_mod_by_agnt_tbl IN            PO_TBL_VARCHAR1
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
  d_mod CONSTANT VARCHAR2(100) := D_validate_reqs_modfd_by_agt;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_reqs_mod_by_agnt_tbl',p_reqs_mod_by_agnt_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  -- Check reqs modified_by_agent_flag is not Y
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_MODFD'
  FROM dual
  WHERE p_reqs_mod_by_agnt_tbl(i) = 'Y';


  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_reqs_modfd_by_agt;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- Validate req at_sourcing_flag <> Y
  -------------------------------------------------------------------------
  PROCEDURE validate_reqs_at_srcing_flg(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_reqs_at_src_flag_tbl IN            PO_TBL_VARCHAR1
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
  d_mod CONSTANT VARCHAR2(100) := D_validate_reqs_at_srcing_flg;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_reqs_at_src_flag_tbl',p_reqs_at_src_flag_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  -- Check reqs_at_sourcing_flag is not Y
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_AT_SRC'
  FROM dual
  WHERE p_reqs_at_src_flag_tbl(i) = 'Y';


  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_reqs_at_srcing_flg;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- Validate line_location_id is null in req lines
  -------------------------------------------------------------------------
  PROCEDURE validate_reqs_line_loc(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_reqs_line_loc_tbl    IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
  d_mod CONSTANT VARCHAR2(100) := D_validate_reqs_line_loc;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_reqs_line_loc_tbl',p_reqs_line_loc_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  -- Check line_location id is NULL
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_LINE_LOC'
  FROM dual
  WHERE p_reqs_line_loc_tbl(i) IS NOT NULL;


  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_reqs_line_loc;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- Validate item id in req is same as that populated in interface.
  -------------------------------------------------------------------------
  PROCEDURE validate_req_item(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_item_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_item_id_tbl      IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
  d_mod CONSTANT VARCHAR2(100) := D_validate_req_item;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_item_id_tbl',p_item_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_item_id_tbl',p_req_item_id_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  -- Check line_location id is NULL
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_ITEM_MIS'
  FROM dual
  WHERE NVL(p_item_id_tbl(i), -9999) <> NVL(p_req_item_id_tbl(i), -9999);


  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_req_item;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- Validate job id in req is same as that populated in interface.
  -------------------------------------------------------------------------
  PROCEDURE validate_req_job(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_job_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_job_id_tbl      IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
  d_mod CONSTANT VARCHAR2(100) := D_validate_req_job;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_job_id_tbl',p_job_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_job_id_tbl',p_req_job_id_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  -- Check line_location id is NULL
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_JOB_MIS'
  FROM dual
  WHERE NVL(p_job_id_tbl(i), -9999) <> NVL(p_req_job_id_tbl(i), -9999);


  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_req_job;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- Validate purchase basis in req is same as that populated in interface.
  -------------------------------------------------------------------------
  PROCEDURE validate_req_pur_basis(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_pur_basis_tbl        IN            PO_TBL_VARCHAR30
                 , p_req_pur_bas_tbl      IN            PO_TBL_VARCHAR30
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
  d_mod CONSTANT VARCHAR2(100) := D_validate_req_pur_basis;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_pur_basis_tbl',p_pur_basis_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_pur_bas_tbl',p_req_pur_bas_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  -- Check line_location id is NULL
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_PUR_BAS_MIS'
  FROM dual
  WHERE p_pur_basis_tbl(i) <> p_req_pur_bas_tbl(i);


  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_req_pur_basis;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- Validate matching basis in req is same as that populated in interface.
  -------------------------------------------------------------------------
  PROCEDURE validate_req_match_basis(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_match_basis_tbl      IN            PO_TBL_VARCHAR30
                 , p_req_match_bas_tbl    IN            PO_TBL_VARCHAR30
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
  d_mod CONSTANT VARCHAR2(100) := D_validate_req_match_basis;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_match_basis_tbl',p_match_basis_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_match_bas_tbl',p_req_match_bas_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  -- Check line_location id is NULL
  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_line
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_MAT_BAS_MIS'
  FROM dual
  WHERE p_match_basis_tbl(i) <> p_req_match_bas_tbl(i);


  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_req_match_basis;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- Validate p_card
  -------------------------------------------------------------------------
  PROCEDURE validate_pcard(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_req_pcard_id_tbl     IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
  d_mod CONSTANT VARCHAR2(100) := D_validate_pcard;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_pcard_id_tbl',p_req_pcard_id_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_LINE
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_PCARD_INVALID'
  FROM dual
  WHERE p_req_pcard_id_tbl(i) IS NOT NULL
  AND NOT EXISTS (SELECT 1
                     FROM ap_cards apc,
                          ap_card_programs apcp
                    WHERE apc.card_id = p_req_pcard_id_tbl(i)
                      AND apc.card_program_id = apcp.card_program_id
                      AND apcp.card_type_lookup_code = 'PROCUREMENT'
                      AND nvl(apc.card_expiration_date, sysdate+1) > sysdate
                      AND nvl(apc.inactive_date, sysdate+1) >= sysdate
                      AND nvl(apcp.inactive_date, sysdate+1) >= sysdate);

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_pcard;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- Validate req org is enabled in source doc
  -------------------------------------------------------------------------
  PROCEDURE validate_reqorg_srcdoc(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_source_doc_id_tbl    IN            PO_TBL_NUMBER
                 , p_req_org_id_tbl       IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
  d_mod CONSTANT VARCHAR2(100) := D_validate_reqorg_srcdoc;

  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_source_doc_id_tbl',p_source_doc_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_org_id_tbl',p_req_org_id_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_LINE
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_ORG_NOT_SRC'
  FROM dual
  WHERE p_source_doc_id_tbl(i) IS NOT NULL
    AND NOT EXISTS (SELECT purchasing_org_id
                      FROM po_ga_org_assignments
                      WHERE po_header_id = p_source_doc_id_tbl(i)
                        AND organization_id = p_req_org_id_tbl(i)
                        AND enabled_flag = 'Y');


  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_reqorg_srcdoc;

  -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- "This requisition line that has a destination type of Inventory
  -- or Shop Floor and cannot be added to a document with a style that
  -- mallows progress payments."
  -------------------------------------------------------------------------
  PROCEDURE validate_style_dest_progress(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_hdr_style_id_tbl     IN            PO_TBL_NUMBER
                 , p_hdr_type_tbl         IN            PO_TBL_VARCHAR30
                 , p_req_dest_code_tbl    IN            PO_TBL_VARCHAR30
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := D_validate_style_dest_progress;
  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_hdr_style_id_tbl',p_hdr_style_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_hdr_type_tbl',p_hdr_type_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_dest_code_tbl',p_req_dest_code_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_LINE
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_NO_INV_SF_PROGRESS'
  FROM dual
  WHERE p_hdr_type_tbl(i) = 'STANDARD'
    AND p_hdr_style_id_tbl(i) IS NOT NULL
    AND p_req_dest_code_tbl(i) IN ('INVENTORY','SHOP FLOOR')
    AND exists (SELECT 'complex po'
                  FROM po_doc_style_headers
                 WHERE style_id = p_hdr_style_id_tbl(i)
                   AND NVL(progress_payment_flag,'N') = 'Y') ;

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_style_dest_progress;

-------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- "This requisition line does not have a purchase basis = Services,
  --  Temp Labor or Goods, and the Value basis = Fixed Price or Quantity.
  --  It cannot be added to a document with a style that allows progress
  --  payments."
-------------------------------------------------------------------------
  PROCEDURE validate_style_line_progress(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_hdr_style_id_tbl     IN            PO_TBL_NUMBER
                 , p_hdr_type_tbl         IN            PO_TBL_VARCHAR30
                 , p_req_pur_basis_tbl    IN            PO_TBL_VARCHAR30
                 , p_req_order_type_tbl   IN            PO_TBL_VARCHAR30
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := D_validate_style_line_progress;
  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_hdr_style_id_tbl',p_hdr_style_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_hdr_type_tbl',p_hdr_type_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_pur_basis_tbl',p_req_pur_basis_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_order_type_tbl',p_req_order_type_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_LINE
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_NO_RATE_PROGRESS'
  FROM dual
  WHERE p_hdr_type_tbl(i) = 'STANDARD'
    AND p_hdr_style_id_tbl(i) IS NOT NULL
    AND ((p_req_order_type_tbl(i) = 'RATE'
         AND p_req_pur_basis_tbl(i) = 'TEMP LABOR')
         OR (p_req_order_type_tbl(i) = 'AMOUNT'
            AND p_req_pur_basis_tbl(i) = 'SERVICES'))
    AND EXISTS (SELECT 'complex po'
                  FROM po_doc_style_headers
                 WHERE style_id = p_hdr_style_id_tbl(i)
                   AND NVL(progress_payment_flag,'N') = 'Y') ;

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_style_line_progress;

   -------------------------------------------------------------------------
  -- <PDOI Enhancement Bug#17063664>
  -- "This requisition line that has a pcard
  --  cannot be added to a document with a style that
  -- allows progress payments."
  -------------------------------------------------------------------------
  PROCEDURE validate_style_pcard(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_hdr_style_id_tbl     IN            PO_TBL_NUMBER
                 , p_hdr_type_tbl         IN            PO_TBL_VARCHAR30
                 , p_req_pcard_id_tbl     IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := D_validate_style_pcard;
  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_hdr_style_id_tbl',p_hdr_style_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_hdr_type_tbl',p_hdr_type_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_pcard_id_tbl',p_req_pcard_id_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_LINE
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_NO_PCARD_PROGRESS'
  FROM dual
  WHERE p_hdr_type_tbl(i) = 'STANDARD'
    AND p_hdr_style_id_tbl(i) IS NOT NULL
    AND p_req_pcard_id_tbl(i) IS NOT NULL
    AND exists (SELECT 'complex po'
                  FROM po_doc_style_headers
                 WHERE style_id = p_hdr_style_id_tbl(i)
                   AND NVL(progress_payment_flag,'N') = 'Y') ;

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_style_pcard;


-------------------------------------------------------------------------
-- <PDOI Enhancement Bug#17063664>
-- If reference req line's is VMI enabled then it
-- must be referenced by GBPA.
-------------------------------------------------------------------------
  PROCEDURE validate_req_vmi_bpa(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_req_vmi_flag_tbl     IN            PO_TBL_VARCHAR1
                 , p_source_doc_id_tbl    IN            PO_TBL_NUMBER
                 , p_source_doc_type_tbl  IN            PO_TBL_VARCHAR30
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := D_validate_req_vmi_bpa;
  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_vmi_flag_tbl',p_req_vmi_flag_tbl);
    PO_LOG.proc_begin(d_mod,'p_source_doc_id_tbl',p_source_doc_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_source_doc_type_tbl',p_source_doc_type_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_LINE
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_VMI_BLANKET'
  FROM dual
  WHERE p_req_vmi_flag_tbl(i) = 'Y'
    AND (p_source_doc_id_tbl(i) IS NULL
         OR NVL(p_source_doc_type_tbl(i), 'NULL') <> 'BLANKET');

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_req_vmi_bpa;

-------------------------------------------------------------------------
-- <PDOI Enhancement Bug#17063664>
-- If reference req line's is VMI enabled then
-- vendor, vendor site on interface should be same as
-- suggested vendor, vendor site on req.
-------------------------------------------------------------------------
  PROCEDURE validate_req_vmi_supplier(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_vendor_id_tbl        IN            PO_TBL_NUMBER
                 , p_vendor_site_tbl      IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_req_vmi_flag_tbl     IN            PO_TBL_VARCHAR1
                 , p_sugstd_vend_id_tbl   IN            PO_TBL_NUMBER
                 , p_sugstd_vend_site_tbl IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := D_validate_req_vmi_supplier;
  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_vendor_id_tbl',p_vendor_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_vendor_site_tbl',p_vendor_site_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_vmi_flag_tbl',p_req_vmi_flag_tbl);
    PO_LOG.proc_begin(d_mod,'p_sugstd_vend_id_tbl',p_sugstd_vend_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_sugstd_vend_site_tbl',p_sugstd_vend_site_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_LINE
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_VMI_SUP'
  FROM dual
  WHERE p_req_vmi_flag_tbl(i) = 'Y'
    AND (p_vendor_id_tbl(i) <> p_sugstd_vend_id_tbl(i)
         OR p_vendor_site_tbl(i) <> p_sugstd_vend_site_tbl(i));

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_req_vmi_supplier;

-------------------------------------------------------------------------
-- <PDOI Enhancement Bug#17063664>
-- Lines that reference a Requisition
-- can only be placed on a standard purchase order.
-------------------------------------------------------------------------
  PROCEDURE validate_req_on_spo(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_hdr_type_lookup_tbl  IN            PO_TBL_VARCHAR30
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := D_validate_req_on_spo;
  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_hdr_type_lookup_tbl',p_hdr_type_lookup_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_LINE
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_ON_SPO'
  FROM dual
  WHERE p_req_line_id_tbl(i) IS NOT NULL
    AND p_hdr_type_lookup_tbl(i) <> 'STANDARD';

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_req_on_spo;

-------------------------------------------------------------------------
-- <PDOI Enhancement Bug#17063664>
-- If reference req line's has pacard
-- vendor, vendor site on interface should be same as
-- suggested vendor, vendor site on req.
-------------------------------------------------------------------------
  PROCEDURE validate_req_pcard_supp(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_vendor_id_tbl        IN            PO_TBL_NUMBER
                 , p_vendor_site_tbl      IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_req_pcard_id_tbl     IN            PO_TBL_NUMBER
                 , p_sugstd_vend_id_tbl   IN            PO_TBL_NUMBER
                 , p_sugstd_vend_site_tbl IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := D_validate_req_pcard_supp;
  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_vendor_id_tbl',p_vendor_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_vendor_site_tbl',p_vendor_site_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_req_pcard_id_tbl',p_req_pcard_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_sugstd_vend_id_tbl',p_sugstd_vend_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_sugstd_vend_site_tbl',p_sugstd_vend_site_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_LINE
  , p_line_id_tbl(i)
  , c_REQUISITION_LINE_ID
  , TO_CHAR(p_req_line_id_tbl(i))
  , 'PO_PDOI_REQ_PCARD_SUP'
  FROM dual
  WHERE p_req_pcard_id_tbl(i) IS NOT NULL
    AND (p_vendor_id_tbl(i) <> p_sugstd_vend_id_tbl(i)
         OR p_vendor_site_tbl(i) <> p_sugstd_vend_site_tbl(i));

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_req_pcard_supp;

-------------------------------------------------------------------------
-- <PDOI Enhancement Bug#17063664>
-- Validate oke_contract_header should exist in  okc_k_headers_b
-------------------------------------------------------------------------
  PROCEDURE validate_oke_contract_hdr(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_oke_contract_hdr_tbl IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := D_validate_oke_contract_hdr;
  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_oke_contract_hdr_tbl',p_oke_contract_hdr_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_LINE
  , p_line_id_tbl(i)
  , c_OKE_CONTRACT_HDR_ID
  , TO_CHAR(p_oke_contract_hdr_tbl(i))
  , 'PO_PDOI_OKE_HDR_INVALID'
  FROM dual
  WHERE p_oke_contract_hdr_tbl(i) IS NOT NULL
    AND NOT EXISTS (SELECT 'Y'
                    FROM     okc_k_headers_b
                    WHERE id = p_oke_contract_hdr_tbl(i));

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_oke_contract_hdr;


-------------------------------------------------------------------------
-- <PDOI Enhancement Bug#17063664>
-- Validate oke_contract_version exists
-------------------------------------------------------------------------
  PROCEDURE validate_oke_contract_ver(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_oke_contract_hdr_tbl IN            PO_TBL_NUMBER
                 , p_oke_contract_ver_tbl IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2)
  IS
    d_mod CONSTANT VARCHAR2(100) := D_validate_oke_contract_ver;
  BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_oke_contract_hdr_tbl',p_oke_contract_hdr_tbl);
    PO_LOG.proc_begin(d_mod,'p_oke_contract_ver_tbl',p_oke_contract_ver_tbl);
    PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  IF (x_result_set_id IS NULL) THEN
    x_result_set_id := PO_VALIDATIONS.next_result_set_id();
  END IF;

  FORALL i IN 1 .. p_line_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , column_name
  , column_val
  , message_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_LINE
  , p_line_id_tbl(i)
  , c_OKE_CONTRACT_VERSION
  , TO_CHAR(p_oke_contract_ver_tbl(i))
  , 'PO_PDOI_OKE_VER_INVALID'
  FROM dual
  WHERE p_oke_contract_ver_tbl(i) IS NOT NULL
    AND NOT EXISTS (SELECT 'Y'
                    FROM   oke_k_vers_numbers_v
                    WHERE  chr_id = p_oke_contract_hdr_tbl(i)
                    AND    major_version = p_oke_contract_ver_tbl(i)
                    UNION
                    SELECT 'Y'
                    FROM   okc_k_vers_numbers_h
                    WHERE  chr_id = p_oke_contract_hdr_tbl(i)
                    AND    major_version = p_oke_contract_ver_tbl(i));

  IF (SQL%ROWCOUNT > 0) THEN
    x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
  ELSE
    x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
  END IF;

  IF PO_LOG.d_proc THEN
    PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;
  END validate_oke_contract_ver;

  --Bug 19139957 Start
  -------------------------------------------------------------------------
  -- Check the category segment value.
  -- If there's character the same as segment separator in the value,
  -- add a '\' before the separator value so that fnd code can identify it.

  -- p_category  The category code combination before formatted
  -- p_structure_id  The structure id of the item category
  -- p_format_category The category code combination after formatted.
  -------------------------------------------------------------------------
  PROCEDURE format_category_segment
  (
    p_category IN VARCHAR2,
    p_structure_id IN NUMBER,
    p_format_category OUT NOCOPY VARCHAR2
  )
  IS
  d_mod CONSTANT VARCHAR2(100) := D_format_category_segment;
  x_category_id NUMBER;
  x_delimiter VARCHAR(5);
  x_segment VARCHAR2(20);
  category_stmt VARCHAR(800);

  -- Cursor to retrieve the application column names used for the category KFF
  CURSOR get_application_segments(structure_id NUMBER) IS
  SELECT application_column_name
  FROM FND_ID_FLEX_SEGMENTS_VL
  WHERE id_flex_num = structure_id
  AND id_flex_code  ='MCAT'
  AND application_id=401
  AND enabled_flag = 'Y'
  ORDER BY segment_num;

  BEGIN
    --Get the category id
    SELECT mck.category_id
    INTO   x_category_id
    FROM mtl_categories_kfv mck,
         mtl_category_sets mcs,
         mtl_default_category_sets mdcs
    WHERE mck.structure_id = mcs.structure_id
          AND mcs.category_set_id = mdcs.category_set_id
          AND mdcs.functional_area_id = 2
          AND mck.concatenated_segments = p_category ;

    IF po_log.d_proc THEN
       po_log.proc_begin(d_mod, 'category_id ', x_category_id);
	   po_log.proc_begin(d_mod, 'category before constructed ', p_category);
    END IF;

    --Get the separatpor for this structure
    SELECT concatenated_segment_delimiter
    INTO x_delimiter
    FROM fnd_id_flex_structures
    WHERE application_id = 401
      AND id_flex_code  ='MCAT'
      AND id_flex_num = p_structure_id;

    IF po_log.d_proc THEN
      po_log.proc_begin(d_mod, 'separator ', x_delimiter);
    END IF;

    --Construct a query to retrieve the category value with
    --the '\' added.
    category_stmt := 'SELECT ';
    OPEN get_application_segments(p_structure_id);
    LOOP
     FETCH get_application_segments INTO x_segment;
     EXIT WHEN (get_application_segments%NOTFOUND);
     IF(get_application_segments%ROWCOUNT <> 1) THEN
       category_stmt := category_stmt || ' || ''' || x_delimiter
	                    || '''' || ' || ';
     END IF;
     category_stmt := category_stmt || 'REPLACE(' || x_segment
                      || ', ' || '''' || x_delimiter || ''''
                      || ', ''\' || x_delimiter || ''')';
     END LOOP;
     CLOSE get_application_segments;
     category_stmt := category_stmt || 'FROM mtl_categories_kfv '
                      || 'WHERE category_id = ' || x_category_id;

	 IF po_log.d_proc THEN
        po_log.proc_begin(d_mod, 'category_stmt ', category_stmt);
	 END IF;

    EXECUTE IMMEDIATE category_stmt INTO p_format_category;

    IF po_log.d_proc THEN
       po_log.proc_begin(d_mod, 'category after constructed ', p_format_category);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
       p_format_category := p_category;
       IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'category after constructed ', p_format_category);
       END IF;
  END format_category_segment;

  --Bug 19139957 End

END PO_VAL_LINES2;

/
