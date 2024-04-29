--------------------------------------------------------
--  DDL for Package OZF_RESALE_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_RESALE_ADJUSTMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftrsas.pls 120.1 2005/08/19 14:02:11 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_RESALE_ADJUSTMENTS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_resale_adjustment_id   IN OUT  NOCOPY NUMBER,
          px_object_version_number   IN OUT  NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_request_id    NUMBER,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_resale_line_id    NUMBER,
          p_resale_batch_id    NUMBER,
          p_orig_system_agreement_uom	varchar2,
          p_ORIG_SYSTEM_AGREEMENT_name  varchar2,
          p_orig_system_agreement_type      VARCHAR2,
          p_orig_system_agreement_status    VARCHAR2,
          p_orig_system_agreement_curr       VARCHAR2,
          p_orig_system_agreement_price     NUMBER,
          p_orig_system_agreement_quant  NUMBER,
          p_agreement_id    NUMBER,
          p_agreement_type    VARCHAR2,
          p_agreement_name    VARCHAR2,
          p_agreement_price    NUMBER,
          p_agreement_uom_code    VARCHAR2,
          p_corrected_agreement_id    NUMBER,
          p_corrected_agreement_name    VARCHAR2,
	  p_credit_code       varchar2,
	  p_credit_advice_date   DATE,
          p_allowed_amount    NUMBER,
          p_total_allowed_amount    NUMBER,
          p_accepted_amount    NUMBER,
          p_total_accepted_amount    NUMBER,
          p_claimed_amount    NUMBER,
          p_total_claimed_amount    NUMBER,
	  p_calculated_price             NUMBER,
          p_acctd_calculated_price       NUMBER,
          p_calculated_amount            NUMBER,
	  p_line_agreement_flag       varchar2,
          p_tolerance_flag    VARCHAR2,
          p_line_tolerance_amount    NUMBER,
          p_operand    NUMBER,
          p_operand_calculation_code    VARCHAR2,
          p_priced_quantity    NUMBER,
          p_priced_uom_code    VARCHAR2,
          p_priced_unit_price    NUMBER,
          p_list_header_id    NUMBER,
          p_list_line_id    NUMBER,
          p_status_code    VARCHAR2,
          px_org_id   IN OUT  NOCOPY NUMBER);

PROCEDURE Update_Row(
          p_resale_adjustment_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_request_id    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_resale_line_id    NUMBER,
          p_resale_batch_id    NUMBER,
	  p_orig_system_agreement_uom	varchar2,
          p_ORIG_SYSTEM_AGREEMENT_name  varchar2,
          p_orig_system_agreement_type      VARCHAR2,
          p_orig_system_agreement_status    VARCHAR2,
          p_orig_system_agreement_curr       VARCHAR2,
          p_orig_system_agreement_price     NUMBER,
          p_orig_system_agreement_quant  NUMBER,
          p_agreement_id    NUMBER,
          p_agreement_type    VARCHAR2,
          p_agreement_name    VARCHAR2,
          p_agreement_price    NUMBER,
          p_agreement_uom_code    VARCHAR2,
          p_corrected_agreement_id    NUMBER,
          p_corrected_agreement_name    VARCHAR2,
	  p_credit_code       varchar2,
	  p_credit_advice_date   DATE,
          p_allowed_amount    NUMBER,
          p_total_allowed_amount    NUMBER,
          p_accepted_amount    NUMBER,
          p_total_accepted_amount    NUMBER,
          p_claimed_amount    NUMBER,
          p_total_claimed_amount    NUMBER,
	  p_calculated_price             NUMBER,
          p_acctd_calculated_price       NUMBER,
          p_calculated_amount            NUMBER,
	  p_line_agreement_flag       varchar2,
          p_tolerance_flag    VARCHAR2,
          p_line_tolerance_amount    NUMBER,
          p_operand    NUMBER,
          p_operand_calculation_code    VARCHAR2,
          p_priced_quantity    NUMBER,
          p_priced_uom_code    VARCHAR2,
          p_priced_unit_price    NUMBER,
          p_list_header_id    NUMBER,
          p_list_line_id    NUMBER,
          p_status_code    VARCHAR2,
          p_org_id    NUMBER);

PROCEDURE Delete_Row(
    p_RESALE_ADJUSTMENT_ID  NUMBER);
PROCEDURE Lock_Row(
          p_resale_adjustment_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_request_id    NUMBER,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_last_update_login    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_resale_line_id    NUMBER,
          p_resale_batch_id    NUMBER,
	  p_orig_system_agreement_uom	varchar2,
          p_ORIG_SYSTEM_AGREEMENT_name  varchar2,
          p_orig_system_agreement_type      VARCHAR2,
          p_orig_system_agreement_status    VARCHAR2,
          p_orig_system_agreement_curr       VARCHAR2,
          p_orig_system_agreement_price     NUMBER,
          p_orig_system_agreement_quant  NUMBER,
          p_agreement_id    NUMBER,
          p_agreement_type    VARCHAR2,
          p_agreement_name    VARCHAR2,
          p_agreement_price    NUMBER,
          p_agreement_uom_code    VARCHAR2,
          p_corrected_agreement_id    NUMBER,
          p_corrected_agreement_name    VARCHAR2,
	  p_credit_code       varchar2,
	  p_credit_advice_date   DATE,
          p_allowed_amount    NUMBER,
          p_total_allowed_amount    NUMBER,
          p_accepted_amount    NUMBER,
          p_total_accepted_amount    NUMBER,
          p_claimed_amount    NUMBER,
          p_total_claimed_amount    NUMBER,
	  p_calculated_price             NUMBER,
          p_acctd_calculated_price       NUMBER,
          p_calculated_amount            NUMBER,
	  p_line_agreement_flag       varchar2,
          p_tolerance_flag    VARCHAR2,
          p_line_tolerance_amount    NUMBER,
          p_operand    NUMBER,
          p_operand_calculation_code    VARCHAR2,
          p_priced_quantity    NUMBER,
          p_priced_uom_code    VARCHAR2,
          p_priced_unit_price    NUMBER,
          p_list_header_id    NUMBER,
          p_list_line_id    NUMBER,
          p_status_code    VARCHAR2,
          p_org_id    NUMBER);

END OZF_RESALE_ADJUSTMENTS_PKG;

 

/