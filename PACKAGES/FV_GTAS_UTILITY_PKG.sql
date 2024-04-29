--------------------------------------------------------
--  DDL for Package FV_GTAS_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_GTAS_UTILITY_PKG" AUTHID CURRENT_USER AS
-- $Header: FVGTSUTS.pls 120.0.12010000.17 2014/11/19 16:12:56 snama noship $


PROCEDURE ap_check_gdf_valid(P_id NUMBER, --invoice_id/interface_invoice_id,supplier_id
                              P_calling_mode VARCHAR2, -- invoice validation (INV_VLD)/invoice import (INV_IMP)/supplier import (SUP_IMP)
                              P_table_name VARCHAR2,   -- which table to query
                              P_hold_reject_exists_flag OUT NOCOPY VARCHAR2, --to release/place hold and import/reject invoice
                              P_return_code  OUT NOCOPY VARCHAR2, --hold code/reject code/null if valid
                              P_return_status  OUT NOCOPY BOOLEAN); --success without any exceptions

-------------------------------------------------------------------------------
 PROCEDURE ar_check_gdf_pre_processor(p_id NUMBER, --Request id of the AR interface run
                                      p_mode VARCHAR2, --mode like AUTO_INV, COPY_INV, IMP_API, etc
                                      p_return_status OUT NOCOPY BOOLEAN
                                      );
-------------------------------------------------------------------------------
PROCEDURE ar_check_gdf_pre_processor(p_id NUMBER, --Request id of the AR interface run
                                      p_mode VARCHAR2, --mode like AUTO_INV, COPY_INV, IMP_API, etc
                                      p_msg_count OUT NOCOPY NUMBER,
                                      p_msg_data OUT NOCOPY VARCHAR2,
                                      p_return_status OUT NOCOPY VARCHAR2
                                      );
-------------------------------------------------------------------------------
 PROCEDURE ar_check_gdf_post_processor(p_id NUMBER,  --Request id of the AR interface run
                                       p_mode VARCHAR2,--mode like AUTO_INV, COPY_INV, IMP_API, etc
                                       p_return_status OUT NOCOPY BOOLEAN
                                      );
-------------------------------------------------------------------------------
 PROCEDURE ar_check_gdf_post_processor(p_id NUMBER,  --Request id of the AR interface run
                                       p_mode VARCHAR2,--mode like AUTO_INV, COPY_INV, IMP_API, etc
                                    p_msg_count OUT NOCOPY NUMBER,
                                     p_msg_data OUT NOCOPY VARCHAR2,
                                      p_return_status OUT NOCOPY VARCHAR2
                                      );
-------------------------------------------------------------------------------

PROCEDURE PO_VALIDATE_DISTRIBUTIONS
             (p_distributions IN PO_DISTRIBUTIONS_VAL_TYPE,
              p_other_params_tbl  IN PO_NAME_VALUE_PAIR_TAB,
              x_results       OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
              x_result_type   OUT NOCOPY VARCHAR2);
-------------------------------------------------------------------------------
PROCEDURE PO_DEFAULT_DISTRIBUTIONS
    (p_distributions IN OUT NOCOPY PO_PDOI_TYPES.DISTRIBUTIONS_REC_TYPE,
     p_other_params  IN            PO_NAME_VALUE_PAIR_TAB,
     x_return_status OUT    NOCOPY VARCHAR2);
-------------------------------------------------------------------------------
PROCEDURE po_bwc_validate_fv_gdf
    ( p_document_id in NUMBER,
      p_release_id IN NUMBER,
      p_draft_id in NUMBER,
      p_online_report_id IN NUMBER,
      p_user_id IN NUMBER,
      p_login_id IN NUMBER,
      p_sequence IN OUT NOCOPY NUMBER,
      x_return_status OUT NOCOPY VARCHAR2
   );
-------------------------------------------------------------------------------
PROCEDURE PA_SUMM_FUND_CHECK_GDF_VALID(
   p_task_id IN NUMBER,
   p_task_num IN VARCHAR2,
   p_project_id IN NUMBER,
   p_project_num IN VARCHAR2,
   p_agreement_id IN NUMBER,
   p_agreement_num IN VARCHAR2,
   p_pm_produce_code IN VARCHAR2,
   p_pm_agreement_reference IN VARCHAR2,
   p_customer_id IN NUMBER,
   p_global_attribute_category IN OUT NOCOPY VARCHAR2,
   p_global_attribute1 IN OUT NOCOPY VARCHAR2,
   p_global_attribute2 IN OUT NOCOPY VARCHAR2,
   p_global_attribute3 IN OUT NOCOPY VARCHAR2,
   p_global_attribute4 IN OUT NOCOPY VARCHAR2,
   p_global_attribute5 IN OUT NOCOPY VARCHAR2,
   p_global_attribute6 IN OUT NOCOPY VARCHAR2,
   p_global_attribute7 IN OUT NOCOPY VARCHAR2,
   p_global_attribute8 IN OUT NOCOPY VARCHAR2,
   p_global_attribute9 IN OUT NOCOPY VARCHAR2,
   p_global_attribute10 IN OUT NOCOPY VARCHAR2,
   p_global_attribute11 IN OUT NOCOPY VARCHAR2,
   p_global_attribute12 IN OUT NOCOPY VARCHAR2,
   p_global_attribute13 IN OUT NOCOPY VARCHAR2,
   p_global_attribute14 IN OUT NOCOPY VARCHAR2,
   p_global_attribute15 IN OUT NOCOPY VARCHAR2,
   p_global_attribute16 IN OUT NOCOPY VARCHAR2,
   p_global_attribute17 IN OUT NOCOPY VARCHAR2,
   p_global_attribute18 IN OUT NOCOPY VARCHAR2,
   p_global_attribute19 IN OUT NOCOPY VARCHAR2,
   p_global_attribute20 IN OUT NOCOPY VARCHAR2,
   p_global_attribute21 IN OUT NOCOPY VARCHAR2,
   p_global_attribute22 IN OUT NOCOPY VARCHAR2,
   p_global_attribute23 IN OUT NOCOPY VARCHAR2,
   p_global_attribute24 IN OUT NOCOPY VARCHAR2,
   p_global_attribute25 IN OUT NOCOPY VARCHAR2,
   p_global_attribute26 IN OUT NOCOPY VARCHAR2,
   p_global_attribute27 IN OUT NOCOPY VARCHAR2,
   p_global_attribute28 IN OUT NOCOPY VARCHAR2,
   p_global_attribute29 IN OUT NOCOPY VARCHAR2,
   p_global_attribute30 IN OUT NOCOPY VARCHAR2,
   p_return_msg OUT NOCOPY VARCHAR2,
   p_valid_status OUT NOCOPY VARCHAR2
   );
-------------------------------------------------------------------------------

END FV_GTAS_UTILITY_PKG;

/
