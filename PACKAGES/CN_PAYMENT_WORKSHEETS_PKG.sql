--------------------------------------------------------
--  DDL for Package CN_PAYMENT_WORKSHEETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PAYMENT_WORKSHEETS_PKG" AUTHID CURRENT_USER AS
-- $Header: cntwkshs.pls 120.4 2005/09/24 14:11:25 fmburu ship $

   --============================================================================
-- Procedure Name : Insert_Record
-- Purpose        : Insert a Record in CN_PAYMENT_WORKSHEETS
--============================================================================
   PROCEDURE INSERT_RECORD (
      x_payment_worksheet_id              cn_payment_worksheets.payment_worksheet_id%TYPE := NULL,
      x_payrun_id                         cn_payment_worksheets.payrun_id%TYPE,
      x_salesrep_id                       cn_payment_worksheets.salesrep_id%TYPE,
      x_quota_id                          cn_payment_worksheets.quota_id%TYPE := NULL,
      x_cost_center_id                    cn_payment_worksheets.cost_center_id%TYPE := NULL,
      x_role_id                           cn_payment_worksheets.role_id%TYPE := NULL,
      x_credit_type_id                    cn_payment_worksheets.credit_type_id%TYPE,
      x_calc_pmt_amount                   cn_payment_worksheets.pmt_amount_calc%TYPE := 0,
      x_adj_pmt_amount_rec                cn_payment_worksheets.pmt_amount_calc%TYPE := 0,
      x_adj_pmt_amount_nrec               cn_payment_worksheets.pmt_amount_calc%TYPE := 0,
      x_adj_pmt_amount                    cn_payment_worksheets.pmt_amount_calc%TYPE := 0,
      x_held_amount                       cn_payment_worksheets.held_amount%TYPE := 0,
      x_pmt_amount_recovery               cn_payment_worksheets.pmt_amount_calc%TYPE := 0,
      x_comm_paid                         cn_payment_worksheets.draw_ptd%TYPE := 0,
      x_bonus_paid                        cn_payment_worksheets.draw_ptd%TYPE := 0,
      x_draw_paid                         cn_payment_worksheets.draw_ptd%TYPE := 0,
      x_comm_nrec                         cn_payment_worksheets.draw_ptd%TYPE := 0,
      x_created_by                        cn_payment_worksheets.created_by%TYPE,
      x_creation_date                     cn_payment_worksheets.creation_date%TYPE,
      x_worksheet_status                  cn_payment_worksheets.worksheet_status%TYPE,
      p_org_id                            cn_payment_worksheets.org_id%TYPE,
      p_object_version_number             cn_payment_worksheets.object_version_number%TYPE
   );

--============================================================================
-- Procedure Name : Lock_Record
-- Purpose        : Lock Recor
--============================================================================
   PROCEDURE LOCK_RECORD (
      x_payment_worksheet_id              NUMBER
   );

--============================================================================
-- Procedure Name : Update_Record
-- Purpose        : Update Record
--============================================================================
   PROCEDURE UPDATE_RECORD (
      x_payment_worksheet_id              cn_payment_worksheets.payment_worksheet_id%TYPE,
      x_payrun_id                         cn_payment_worksheets.payrun_id%TYPE := cn_api.g_miss_id,
      x_salesrep_id                       cn_payment_worksheets.salesrep_id%TYPE := cn_api.g_miss_id,
      x_cost_center_id                    cn_payment_worksheets.cost_center_id%TYPE := cn_api.g_miss_id,
      x_role_id                           cn_payment_worksheets.role_id%TYPE := cn_api.g_miss_id,
      x_credit_type_id                    cn_payment_worksheets.credit_type_id%TYPE := cn_api.g_miss_id,
      x_returned_funds_flag               cn_payment_worksheets.returned_funds_flag%TYPE := '~',
      x_post_subledger_flag               cn_payment_worksheets.post_subledger_flag%TYPE := '~',
      x_pay_cap                           cn_payment_worksheets.pay_cap%TYPE := fnd_api.g_miss_num,
      x_minimum_amount                    cn_payment_worksheets.minimum_amount%TYPE := fnd_api.g_miss_num,
      x_comm_due_bb                       cn_payment_worksheets.comm_due_bb%TYPE := fnd_api.g_miss_num,
      x_comm_ptd                          cn_payment_worksheets.comm_ptd%TYPE := fnd_api.g_miss_num,
      x_draw_paid                         cn_payment_worksheets.draw_paid%TYPE := fnd_api.g_miss_num,
      x_comm_nrec                         cn_payment_worksheets.comm_nrec%TYPE := fnd_api.g_miss_num,
      x_comm_draw                         cn_payment_worksheets.comm_draw%TYPE := fnd_api.g_miss_num,
      x_comm_paid                         cn_payment_worksheets.comm_paid%TYPE := fnd_api.g_miss_num,
      x_reg_bonus_due_bb                  cn_payment_worksheets.reg_bonus_due_bb%TYPE := fnd_api.g_miss_num,
      x_reg_bonus_ptd                     cn_payment_worksheets.reg_bonus_ptd%TYPE := fnd_api.g_miss_num,
      x_reg_bonus_rec                     cn_payment_worksheets.reg_bonus_rec%TYPE := fnd_api.g_miss_num,
      x_reg_bonus_to_rec                  cn_payment_worksheets.reg_bonus_to_rec%TYPE := fnd_api.g_miss_num,
      x_reg_bonus_paid                    cn_payment_worksheets.reg_bonus_paid%TYPE := fnd_api.g_miss_num,
      x_bonus_due_bb                      cn_payment_worksheets.bonus_due_bb%TYPE := fnd_api.g_miss_num,
      x_bonus_ptd                         cn_payment_worksheets.bonus_ptd%TYPE := fnd_api.g_miss_num,
      x_bonus_paid                        cn_payment_worksheets.bonus_paid%TYPE := fnd_api.g_miss_num,
      x_payee_comm_due_bb                 cn_payment_worksheets.payee_comm_due_bb%TYPE := fnd_api.g_miss_num,
      x_payee_comm_ptd                    cn_payment_worksheets.payee_comm_ptd%TYPE := fnd_api.g_miss_num,
      x_payee_comm_paid                   cn_payment_worksheets.payee_comm_paid%TYPE := fnd_api.g_miss_num,
      x_payee_bonus_due_bb                cn_payment_worksheets.payee_bonus_due_bb%TYPE := fnd_api.g_miss_num,
      x_payee_bonus_ptd                   cn_payment_worksheets.payee_bonus_ptd%TYPE := fnd_api.g_miss_num,
      x_payee_bonus_paid                  cn_payment_worksheets.payee_bonus_paid%TYPE := fnd_api.g_miss_num,
      x_convert_to_type_id                cn_payment_worksheets.convert_to_type_id%TYPE := cn_api.g_miss_id,
      x_credit_conv_fct_id                cn_payment_worksheets.credit_conv_fct_id%TYPE := cn_api.g_miss_id,
      x_convert_to_paid                   cn_payment_worksheets.convert_to_paid%TYPE := fnd_api.g_miss_num,
      x_reviewed_by_analyst               cn_payment_worksheets_all.reviewed_by_analyst%TYPE := fnd_api.g_miss_char,
      x_analyst_notes                     cn_payment_worksheets_all.analyst_notes%TYPE := fnd_api.g_miss_char,
      x_posting_status                    cn_payment_worksheets.posting_status%TYPE := fnd_api.g_miss_char,
      x_draw_recoverable_begin            cn_payment_worksheets.draw_recoverable_begin%TYPE := fnd_api.g_miss_num,
      x_adjust_paid                       cn_payment_worksheets.adjust_paid%TYPE := fnd_api.g_miss_num,
      x_bonus_draw                        cn_payment_worksheets.bonus_draw%TYPE := fnd_api.g_miss_num,
      x_reason                            cn_payment_worksheets.reason%TYPE := fnd_api.g_miss_char,
      x_bonus_reason                      cn_payment_worksheets.bonus_reason%TYPE := fnd_api.g_miss_char,
      x_recovery_method                   cn_payment_worksheets.recovery_method%TYPE := fnd_api.g_miss_char,
      x_draw_ptd                          cn_payment_worksheets.draw_ptd%TYPE := fnd_api.g_miss_num,
      x_bonus_given                       cn_payment_worksheets.bonus_given%TYPE := fnd_api.g_miss_num,
      x_guarantee                         cn_payment_worksheets.guarantee%TYPE := fnd_api.g_miss_num,
      x_worksheet_status                  cn_payment_worksheets.worksheet_status%TYPE := fnd_api.g_miss_char,
      x_last_update_date                  cn_payment_worksheets.last_update_date%TYPE,
      x_last_updated_by                   cn_payment_worksheets.last_updated_by%TYPE,
      x_last_update_login                 cn_payment_worksheets.last_update_login%TYPE
   );

--============================================================================
-- Procedure Name : Update_Record
-- Purpose        : Update the Payment Worksheets ( batch Update )
--      : Called from Payment Transactions cnvpmtrb.pls
--============================================================================
   PROCEDURE UPDATE_RECORD (
      p_salesrep_id                          NUMBER,
      p_payrun_id                            NUMBER,
      p_quota_id                             NUMBER,
      p_pmt_amount_calc                      NUMBER := 0,
      p_pmt_amount_adj_rec                   NUMBER := 0,
      p_pmt_amount_adj_nrec                  NUMBER := 0,
      p_pmt_amount_recovery                  NUMBER := 0,
      p_pmt_amount_adj                       NUMBER := 0,
      x_object_version_number    OUT NOCOPY  cn_payment_worksheets.object_version_number%TYPE
   );

--============================================================================
-- Procedure Name : Update_Record
-- Purpose        : Update the Payment Worksheets ( batch Update )
--      : Called from Update Worksheets
--============================================================================
   PROCEDURE UPDATE_STATUS (
      p_salesrep_id                         NUMBER,
      p_payrun_id                           NUMBER,
      p_worksheet_status                    VARCHAR2
   );

--============================================================================
-- Procedure Name : Delete_Record ( Batch Operation )
-- Purpose        : Delete Worksheet
-- Description    : Delete all the Worksheet for the Given salesrep_id and
--        Payrun_id
--============================================================================
   PROCEDURE DELETE_RECORD (
      p_payrun_id                         NUMBER,
      p_salesrep_id                       NUMBER
   );

--============================================================================
-- Procedure Name : Delete_Record
-- Purpose        : Delete Worksheet
--============================================================================
   PROCEDURE DELETE_RECORD (
      x_payment_worksheet_id              NUMBER
   );


END cn_payment_worksheets_pkg;
 

/
