--------------------------------------------------------
--  DDL for Package Body CN_PAYMENT_WORKSHEETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PAYMENT_WORKSHEETS_PKG" AS
-- $Header: cntwkshb.pls 120.4 2005/09/24 14:11:13 fmburu ship $

   --============================================================================
  -- Procedure Name : Insert_Record
  -- Purpose        : Main insert procedure
  -- Called from    : cn_prepost_pvt
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
   )
   IS
   BEGIN
      INSERT INTO cn_payment_worksheets
                  (payment_worksheet_id,
                   payrun_id,
                   salesrep_id,
                   cost_center_id,
                   quota_id,
                   role_id,
                   credit_type_id,
                   pmt_amount_calc,
                   pmt_amount_adj_rec,
                   pmt_amount_adj_nrec,
                   pmt_amount_adj,
                   pmt_amount_recovery,
                   held_amount,
                   draw_paid,
                   bonus_paid,
                   comm_paid,
                   comm_nrec,
                   worksheet_status,
                   created_by,
                   creation_date,
                   --R12
                   org_id,
                   object_version_number
                  )
           VALUES (NVL (x_payment_worksheet_id, cn_payment_worksheets_s.NEXTVAL),
                   x_payrun_id,
                   x_salesrep_id,
                   x_cost_center_id,
                   x_quota_id,
                   x_role_id,
                   x_credit_type_id,
                   x_calc_pmt_amount,
                   x_adj_pmt_amount_rec,
                   x_adj_pmt_amount_nrec,
                   x_adj_pmt_amount,
                   x_pmt_amount_recovery,
                   x_held_amount,
                   x_draw_paid,
                   x_bonus_paid,
                   x_comm_paid,
                   x_comm_nrec,
                   x_worksheet_status,
                   x_created_by,
                   x_creation_date,
                   --R12
                   p_org_id,
                   p_object_version_number
                  );
   END INSERT_RECORD;

--============================================================================
  -- Procedure Name : Lock_Record
  -- Purpose        : Lock db row after form record is changed
  -- Notes          : Only called from the form
--============================================================================
   PROCEDURE LOCK_RECORD (
      x_payment_worksheet_id              NUMBER
   )
   IS
      CURSOR c
      IS
         SELECT        *
                  FROM cn_payment_worksheets
                 WHERE payment_worksheet_id = x_payment_worksheet_id
         FOR UPDATE OF payment_worksheet_id NOWAIT;

      recinfo                       c%ROWTYPE;
   BEGIN
      OPEN c;

      FETCH c
       INTO recinfo;

      IF (c%NOTFOUND)
      THEN
         CLOSE c;

         fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
         app_exception.raise_exception;
      END IF;

      CLOSE c;

      IF recinfo.payment_worksheet_id = x_payment_worksheet_id
      THEN
         RETURN;
      ELSE
         fnd_message.set_name ('FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
      END IF;
   END LOCK_RECORD;

--============================================================================
  -- Procedure Name : Update Record
  -- Purpose        : To Update the Payment worksheet
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
   )
   IS
      l_payment_worksheet_id        cn_payment_worksheets.payment_worksheet_id%TYPE;
      l_payrun_id                   cn_payment_worksheets.payrun_id%TYPE;
      l_salesrep_id                 cn_payment_worksheets.salesrep_id%TYPE;
      l_cost_center_id              cn_payment_worksheets.cost_center_id%TYPE;
      l_role_id                     cn_payment_worksheets.role_id%TYPE;
      l_credit_type_id              cn_payment_worksheets.credit_type_id%TYPE;
      l_returned_funds_flag         cn_payment_worksheets.returned_funds_flag%TYPE;
      l_post_subledger_flag         cn_payment_worksheets.post_subledger_flag%TYPE;
      l_pay_cap                     cn_payment_worksheets.pay_cap%TYPE;
      l_minimum_amount              cn_payment_worksheets.minimum_amount%TYPE;
      l_comm_due_bb                 cn_payment_worksheets.comm_due_bb%TYPE;
      l_comm_ptd                    cn_payment_worksheets.comm_ptd%TYPE;
      l_draw_paid                   cn_payment_worksheets.draw_paid%TYPE;
      l_comm_nrec                   cn_payment_worksheets.comm_nrec%TYPE;
      l_comm_draw                   cn_payment_worksheets.comm_draw%TYPE;
      l_comm_paid                   cn_payment_worksheets.comm_paid%TYPE;
      l_reg_bonus_due_bb            cn_payment_worksheets.reg_bonus_due_bb%TYPE;
      l_reg_bonus_ptd               cn_payment_worksheets.reg_bonus_ptd%TYPE;
      l_reg_bonus_rec               cn_payment_worksheets.reg_bonus_rec%TYPE;
      l_reg_bonus_to_rec            cn_payment_worksheets.reg_bonus_to_rec%TYPE;
      l_reg_bonus_paid              cn_payment_worksheets.reg_bonus_paid%TYPE;
      l_bonus_due_bb                cn_payment_worksheets.bonus_due_bb%TYPE;
      l_bonus_ptd                   cn_payment_worksheets.bonus_ptd%TYPE;
      l_bonus_paid                  cn_payment_worksheets.bonus_paid%TYPE;
      l_payee_comm_due_bb           cn_payment_worksheets.payee_comm_due_bb%TYPE;
      l_payee_comm_ptd              cn_payment_worksheets.payee_comm_ptd%TYPE;
      l_payee_comm_paid             cn_payment_worksheets.payee_comm_paid%TYPE;
      l_payee_bonus_due_bb          cn_payment_worksheets.payee_bonus_due_bb%TYPE;
      l_payee_bonus_ptd             cn_payment_worksheets.payee_bonus_ptd%TYPE;
      l_payee_bonus_paid            cn_payment_worksheets.payee_bonus_paid%TYPE;
      l_convert_to_type_id          cn_payment_worksheets.convert_to_type_id%TYPE;
      l_credit_conv_fct_id          cn_payment_worksheets.credit_conv_fct_id%TYPE;
      l_convert_to_paid             cn_payment_worksheets.convert_to_paid%TYPE;
      l_posting_status              cn_payment_worksheets.posting_status%TYPE;
      l_draw_recoverable_begin      cn_payment_worksheets.draw_recoverable_begin%TYPE;
      l_adjust_paid                 cn_payment_worksheets.adjust_paid%TYPE;
      l_bonus_draw                  cn_payment_worksheets.bonus_draw%TYPE;
      l_reason                      cn_payment_worksheets.reason%TYPE;
      l_bonus_reason                cn_payment_worksheets.bonus_reason%TYPE;
      l_recovery_method             cn_payment_worksheets.recovery_method%TYPE;
      l_draw_ptd                    cn_payment_worksheets.draw_ptd%TYPE;
      l_bonus_given                 cn_payment_worksheets.bonus_given%TYPE;
      l_guarantee                   cn_payment_worksheets.guarantee%TYPE;
      l_worksheet_status            cn_payment_worksheets.worksheet_status%TYPE;
      l_reviewed_by_analyst         cn_payment_worksheets.reviewed_by_analyst%TYPE;
      l_analyst_notes               cn_payment_worksheets.analyst_notes%TYPE;

      CURSOR payment_worksheet_cur
      IS
         SELECT *
           FROM cn_payment_worksheets
          WHERE payment_worksheet_id = x_payment_worksheet_id;

      l_payment_worksheet_rec       payment_worksheet_cur%ROWTYPE;
   BEGIN
      OPEN payment_worksheet_cur;

      FETCH payment_worksheet_cur
       INTO l_payment_worksheet_rec;

      CLOSE payment_worksheet_cur;

      SELECT DECODE (x_salesrep_id, cn_api.g_miss_id, l_payment_worksheet_rec.salesrep_id, x_salesrep_id),
             DECODE (x_cost_center_id, cn_api.g_miss_id, l_payment_worksheet_rec.cost_center_id, x_cost_center_id),
             DECODE (x_role_id, cn_api.g_miss_id, l_payment_worksheet_rec.role_id, x_role_id),
             DECODE (x_credit_type_id, cn_api.g_miss_id, l_payment_worksheet_rec.credit_type_id, x_credit_type_id),
             DECODE (x_returned_funds_flag, '~', l_payment_worksheet_rec.returned_funds_flag, x_returned_funds_flag),
             DECODE (x_post_subledger_flag, '~', l_payment_worksheet_rec.post_subledger_flag, x_post_subledger_flag),
             DECODE (x_pay_cap, fnd_api.g_miss_num, l_payment_worksheet_rec.pay_cap, x_pay_cap),
             DECODE (x_minimum_amount, fnd_api.g_miss_num, l_payment_worksheet_rec.minimum_amount, x_minimum_amount),
             DECODE (x_comm_due_bb, fnd_api.g_miss_num, l_payment_worksheet_rec.comm_due_bb, x_comm_due_bb),
             DECODE (x_comm_ptd, fnd_api.g_miss_num, l_payment_worksheet_rec.comm_ptd, x_comm_ptd),
             DECODE (x_draw_paid, fnd_api.g_miss_num, l_payment_worksheet_rec.draw_paid, x_draw_paid),
             DECODE (x_comm_nrec, fnd_api.g_miss_num, l_payment_worksheet_rec.comm_nrec, x_comm_nrec),
             DECODE (x_comm_draw, fnd_api.g_miss_num, l_payment_worksheet_rec.comm_draw, x_comm_draw),
             DECODE (x_comm_paid, fnd_api.g_miss_num, l_payment_worksheet_rec.comm_paid, x_comm_paid),
             DECODE (x_reg_bonus_due_bb, fnd_api.g_miss_num, l_payment_worksheet_rec.reg_bonus_due_bb, x_reg_bonus_due_bb),
             DECODE (x_reg_bonus_ptd, fnd_api.g_miss_num, l_payment_worksheet_rec.reg_bonus_ptd, x_reg_bonus_ptd),
             DECODE (x_reg_bonus_rec, fnd_api.g_miss_num, l_payment_worksheet_rec.reg_bonus_rec, x_reg_bonus_rec),
             DECODE (x_reg_bonus_to_rec, fnd_api.g_miss_num, l_payment_worksheet_rec.reg_bonus_to_rec, x_reg_bonus_to_rec),
             DECODE (x_reg_bonus_paid, fnd_api.g_miss_num, l_payment_worksheet_rec.reg_bonus_paid, x_reg_bonus_paid),
             DECODE (x_bonus_due_bb, fnd_api.g_miss_num, l_payment_worksheet_rec.bonus_due_bb, x_bonus_due_bb),
             DECODE (x_bonus_ptd, fnd_api.g_miss_num, l_payment_worksheet_rec.bonus_ptd, x_bonus_ptd),
             DECODE (x_bonus_paid, fnd_api.g_miss_num, l_payment_worksheet_rec.bonus_paid, x_bonus_paid),
             DECODE (x_payee_comm_due_bb, fnd_api.g_miss_num, l_payment_worksheet_rec.payee_comm_due_bb, x_payee_comm_due_bb),
             DECODE (x_payee_comm_ptd, fnd_api.g_miss_num, l_payment_worksheet_rec.payee_comm_ptd, x_payee_comm_ptd),
             DECODE (x_payee_comm_paid, fnd_api.g_miss_num, l_payment_worksheet_rec.payee_comm_paid, x_payee_comm_paid),
             DECODE (x_payee_bonus_due_bb, fnd_api.g_miss_num, l_payment_worksheet_rec.payee_bonus_due_bb, x_payee_bonus_due_bb),
             DECODE (x_payee_bonus_ptd, fnd_api.g_miss_num, l_payment_worksheet_rec.payee_bonus_ptd, x_payee_bonus_ptd),
             DECODE (x_payee_bonus_paid, fnd_api.g_miss_num, l_payment_worksheet_rec.payee_bonus_paid, x_payee_bonus_paid),
             DECODE (x_convert_to_type_id, cn_api.g_miss_id, l_payment_worksheet_rec.convert_to_type_id, x_convert_to_type_id),
             DECODE (x_credit_conv_fct_id, cn_api.g_miss_id, l_payment_worksheet_rec.credit_conv_fct_id, x_credit_conv_fct_id),
             DECODE (x_convert_to_paid, fnd_api.g_miss_num, l_payment_worksheet_rec.convert_to_paid, x_convert_to_paid),
             DECODE (x_reviewed_by_analyst, fnd_api.g_miss_char, l_payment_worksheet_rec.reviewed_by_analyst, x_reviewed_by_analyst),
             DECODE (x_analyst_notes, fnd_api.g_miss_char, l_payment_worksheet_rec.analyst_notes, x_analyst_notes),
             DECODE (x_posting_status, fnd_api.g_miss_char, l_payment_worksheet_rec.posting_status, x_posting_status),
             DECODE (x_draw_recoverable_begin, fnd_api.g_miss_num, l_payment_worksheet_rec.draw_recoverable_begin, x_draw_recoverable_begin),
             DECODE (x_adjust_paid, fnd_api.g_miss_num, l_payment_worksheet_rec.adjust_paid, x_adjust_paid),
             DECODE (x_bonus_draw, fnd_api.g_miss_num, l_payment_worksheet_rec.bonus_draw, x_bonus_draw),
             DECODE (x_reason, fnd_api.g_miss_char, l_payment_worksheet_rec.reason, x_reason),
             DECODE (x_bonus_reason, fnd_api.g_miss_char, l_payment_worksheet_rec.bonus_reason, x_bonus_reason),
             DECODE (x_recovery_method, fnd_api.g_miss_char, l_payment_worksheet_rec.recovery_method, x_recovery_method),
             DECODE (x_draw_ptd, fnd_api.g_miss_num, l_payment_worksheet_rec.draw_ptd, x_draw_ptd),
             DECODE (x_bonus_given, fnd_api.g_miss_num, l_payment_worksheet_rec.bonus_given, x_bonus_given),
             DECODE (x_guarantee, fnd_api.g_miss_num, l_payment_worksheet_rec.guarantee, x_guarantee),
             DECODE (x_worksheet_status, fnd_api.g_miss_char, l_payment_worksheet_rec.worksheet_status, x_worksheet_status)
        INTO l_salesrep_id,
             l_cost_center_id,
             l_role_id,
             l_credit_type_id,
             l_returned_funds_flag,
             l_post_subledger_flag,
             l_pay_cap,
             l_minimum_amount,
             l_comm_due_bb,
             l_comm_ptd,
             l_draw_paid,
             l_comm_nrec,
             l_comm_draw,
             l_comm_paid,
             l_reg_bonus_due_bb,
             l_reg_bonus_ptd,
             l_reg_bonus_rec,
             l_reg_bonus_to_rec,
             l_reg_bonus_paid,
             l_bonus_due_bb,
             l_bonus_ptd,
             l_bonus_paid,
             l_payee_comm_due_bb,
             l_payee_comm_ptd,
             l_payee_comm_paid,
             l_payee_bonus_due_bb,
             l_payee_bonus_ptd,
             l_payee_bonus_paid,
             l_convert_to_type_id,
             l_credit_conv_fct_id,
             l_convert_to_paid,
             l_reviewed_by_analyst,
             l_analyst_notes,
             l_posting_status,
             l_draw_recoverable_begin,
             l_adjust_paid,
             l_bonus_draw,
             l_reason,
             l_bonus_reason,
             l_recovery_method,
             l_draw_ptd,
             l_bonus_given,
             l_guarantee,
             l_worksheet_status
        FROM DUAL;

      UPDATE cn_payment_worksheets
         SET salesrep_id = l_salesrep_id,
             cost_center_id = l_cost_center_id,
             role_id = l_role_id,
             credit_type_id = l_credit_type_id,
             returned_funds_flag = l_returned_funds_flag,
             post_subledger_flag = l_post_subledger_flag,
             pay_cap = l_pay_cap,
             minimum_amount = l_minimum_amount,
             comm_due_bb = l_comm_due_bb,
             comm_ptd = l_comm_ptd,
             draw_paid = l_draw_paid,
             comm_nrec = l_comm_nrec,
             comm_draw = l_comm_draw,
             comm_paid = l_comm_paid,
             reg_bonus_due_bb = l_reg_bonus_due_bb,
             reg_bonus_ptd = l_reg_bonus_ptd,
             reg_bonus_rec = l_reg_bonus_rec,
             reg_bonus_to_rec = l_reg_bonus_to_rec,
             reg_bonus_paid = l_reg_bonus_paid,
             bonus_due_bb = l_bonus_due_bb,
             bonus_ptd = l_bonus_ptd,
             bonus_paid = l_bonus_paid,
             payee_comm_due_bb = l_payee_comm_due_bb,
             payee_comm_ptd = l_payee_comm_ptd,
             payee_comm_paid = l_payee_comm_paid,
             payee_bonus_due_bb = l_payee_bonus_due_bb,
             payee_bonus_ptd = l_payee_bonus_ptd,
             payee_bonus_paid = l_payee_bonus_paid,
             convert_to_type_id = l_convert_to_type_id,
             credit_conv_fct_id = l_credit_conv_fct_id,
             convert_to_paid = l_convert_to_paid,
             reviewed_by_analyst = l_reviewed_by_analyst,
             analyst_notes = l_analyst_notes,
             posting_status = l_posting_status,
             draw_recoverable_begin = l_draw_recoverable_begin,
             adjust_paid = l_adjust_paid,
             bonus_draw = l_bonus_draw,
             reason = l_reason,
             bonus_reason = l_bonus_reason,
             recovery_method = l_recovery_method,
             draw_ptd = l_draw_ptd,
             bonus_given = l_bonus_given,
             guarantee = l_guarantee,
             worksheet_status = l_worksheet_status,
             last_update_date = x_last_update_date,
             last_update_login = x_last_update_login,
             last_updated_by = x_last_updated_by
       WHERE payment_worksheet_id = x_payment_worksheet_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END UPDATE_RECORD;


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
   )
   IS
   BEGIN
      SELECT NVL(object_version_number,0) + 1
      INTO   x_object_version_number
      FROM   cn_payment_worksheets
      WHERE  salesrep_id = p_salesrep_id
      AND    payrun_id = p_payrun_id;

      UPDATE cn_payment_worksheets
         SET pmt_amount_adj_nrec = NVL (pmt_amount_adj_nrec, 0) + NVL (p_pmt_amount_adj_nrec, 0),
             pmt_amount_adj_rec = NVL (pmt_amount_adj_rec, 0) + NVL (p_pmt_amount_adj_rec, 0),
             pmt_amount_adj = NVL (pmt_amount_adj, 0) + NVL (p_pmt_amount_adj, 0),
             pmt_amount_calc = NVL (pmt_amount_calc, 0) + NVL (p_pmt_amount_calc, 0),
             pmt_amount_recovery = NVL (pmt_amount_recovery, 0) + NVL (p_pmt_amount_recovery, 0),
             last_updated_by = fnd_global.user_id,
             last_update_date = SYSDATE,
             last_update_login = fnd_global.login_id,
             object_version_number = x_object_version_number
       WHERE salesrep_id = p_salesrep_id
       AND payrun_id = p_payrun_id
       AND (quota_id = p_quota_id OR quota_id IS NULL);
   END UPDATE_RECORD;

--============================================================================
-- Procedure Name : Update_Record
-- Purpose        : Update the Payment Worksheets ( batch Update )
--      : Called from Update Worksheets
--============================================================================
   PROCEDURE UPDATE_STATUS (
      p_salesrep_id                         NUMBER,
      p_payrun_id                           NUMBER,
      p_worksheet_status                    VARCHAR2
   )
   IS
   BEGIN

      UPDATE cn_payment_worksheets
         SET worksheet_status = p_worksheet_status,
             last_updated_by = fnd_global.user_id,
             last_update_date = SYSDATE,
             last_update_login = fnd_global.login_id,
             object_version_number = nvl(object_version_number,0) + 1
       WHERE salesrep_id = p_salesrep_id
       AND   payrun_id = p_payrun_id;

   END UPDATE_STATUS;

--============================================================================
-- Procedure Name : Delete_Record
-- Purpose        : Delete Worksheet
--============================================================================
   PROCEDURE DELETE_RECORD (
      p_payrun_id                         NUMBER,
      p_salesrep_id                       NUMBER
   )
   IS
   BEGIN
      DELETE
      FROM cn_payment_worksheets
      WHERE salesrep_id = p_salesrep_id
      AND payrun_id = p_payrun_id;

   END DELETE_RECORD;

--============================================================================
-- Procedure Name : Delete_Record
-- Purpose        : Delete the Payment Worksheets
--============================================================================
   PROCEDURE DELETE_RECORD (
      x_payment_worksheet_id              NUMBER
   )
   IS
   BEGIN
      DELETE
      FROM cn_payment_worksheets
      WHERE payment_worksheet_id = x_payment_worksheet_id;

   END DELETE_RECORD;


END cn_payment_worksheets_pkg;

/
