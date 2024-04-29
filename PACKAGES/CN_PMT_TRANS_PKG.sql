--------------------------------------------------------
--  DDL for Package CN_PMT_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PMT_TRANS_PKG" AUTHID CURRENT_USER AS
-- $Header: cntpmtrs.pls 120.5 2005/09/24 14:10:57 fmburu ship $ --+
   TYPE pmt_trans_rec_type IS RECORD (
      payment_transaction_id        cn_payment_transactions.payment_transaction_id%TYPE,
      posting_batch_id              cn_payment_transactions.posting_batch_id%TYPE := cn_api.g_miss_id,
      credited_salesrep_id          cn_payment_transactions.credited_salesrep_id%TYPE := cn_api.g_miss_id,
      payee_salesrep_id             cn_payment_transactions.payee_salesrep_id%TYPE := cn_api.g_miss_id,
      quota_id                      cn_payment_transactions.quota_id%TYPE := cn_api.g_miss_id,
      pay_period_id                 cn_payment_transactions.pay_period_id%TYPE := cn_api.g_miss_id,
      incentive_type_code           cn_payment_transactions.incentive_type_code%TYPE := fnd_api.g_miss_char,
      credit_type_id                cn_payment_transactions.credit_type_id%TYPE := cn_api.g_miss_id,
      payrun_id                     cn_payment_transactions.payrun_id%TYPE := cn_api.g_miss_id,
      amount                        cn_payment_transactions.amount%TYPE := cn_api.g_miss_num,
      payment_amount                cn_payment_transactions.payment_amount%TYPE := cn_api.g_miss_num,
      hold_flag                     cn_payment_transactions.hold_flag%TYPE := fnd_api.g_miss_char,
      paid_flag                     cn_payment_transactions.paid_flag%TYPE := fnd_api.g_miss_char,
      waive_flag                    cn_payment_transactions.waive_flag%TYPE := fnd_api.g_miss_char,
      recoverable_flag              cn_payment_transactions.recoverable_flag%TYPE := fnd_api.g_miss_char,
      commission_header_id          cn_payment_transactions.commission_header_id%TYPE := cn_api.g_miss_id,
      commission_line_id            cn_payment_transactions.commission_line_id%TYPE := cn_api.g_miss_id,
      pay_element_type_id           cn_payment_transactions.pay_element_type_id%TYPE,
      srp_plan_assign_id            cn_payment_transactions.srp_plan_assign_id%TYPE := cn_api.g_miss_id,
      processed_date                cn_payment_transactions.processed_date%TYPE := fnd_api.g_miss_date,
      processed_period_id           cn_payment_transactions.processed_period_id%TYPE := cn_api.g_miss_id,
      quota_rule_id                 cn_payment_transactions.quota_rule_id%TYPE := cn_api.g_miss_id,
      event_factor                  cn_payment_transactions.event_factor%TYPE := cn_api.g_miss_num,
      payment_factor                cn_payment_transactions.payment_factor%TYPE := cn_api.g_miss_num,
      quota_factor                  cn_payment_transactions.quota_factor%TYPE := cn_api.g_miss_num,
      input_achieved                cn_payment_transactions.input_achieved%TYPE := cn_api.g_miss_num,
      rate_tier_id                  cn_payment_transactions.rate_tier_id%TYPE := cn_api.g_miss_id,
      payee_line_id                 cn_payment_transactions.payee_line_id%TYPE := cn_api.g_miss_id,
      commission_rate               cn_payment_transactions.commission_rate%TYPE := cn_api.g_miss_num,
      trx_type                      cn_payment_transactions.trx_type%TYPE := fnd_api.g_miss_char,
      role_id                       cn_payment_transactions.role_id%TYPE := cn_api.g_miss_id,
      expense_ccid                  cn_payment_transactions.expense_ccid%TYPE := cn_api.g_miss_id,
      liability_ccid                cn_payment_transactions.liability_ccid%TYPE := cn_api.g_miss_id,
      attribute_category            cn_payment_transactions.attribute_category%TYPE := fnd_api.g_miss_char,
      attribute1                    cn_payment_transactions.attribute1%TYPE := fnd_api.g_miss_char,
      attribute2                    cn_payment_transactions.attribute2%TYPE := fnd_api.g_miss_char,
      attribute3                    cn_payment_transactions.attribute3%TYPE := fnd_api.g_miss_char,
      attribute4                    cn_payment_transactions.attribute4%TYPE := fnd_api.g_miss_char,
      attribute5                    cn_payment_transactions.attribute5%TYPE := fnd_api.g_miss_char,
      attribute6                    cn_payment_transactions.attribute6%TYPE := fnd_api.g_miss_char,
      attribute7                    cn_payment_transactions.attribute7%TYPE := fnd_api.g_miss_char,
      attribute8                    cn_payment_transactions.attribute8%TYPE := fnd_api.g_miss_char,
      attribute9                    cn_payment_transactions.attribute9%TYPE := fnd_api.g_miss_char,
      attribute10                   cn_payment_transactions.attribute10%TYPE := fnd_api.g_miss_char,
      attribute11                   cn_payment_transactions.attribute11%TYPE := fnd_api.g_miss_char,
      attribute12                   cn_payment_transactions.attribute12%TYPE := fnd_api.g_miss_char,
      attribute13                   cn_payment_transactions.attribute13%TYPE := fnd_api.g_miss_char,
      attribute14                   cn_payment_transactions.attribute14%TYPE := fnd_api.g_miss_char,
      attribute15                   cn_payment_transactions.attribute15%TYPE,
      --R12
      org_id                        cn_payment_transactions.org_id%TYPE,
      object_version_number         cn_payment_transactions.object_version_number%TYPE
   );

   TYPE pmt_trans_rec_tbl_type IS TABLE OF pmt_trans_rec_type
      INDEX BY BINARY_INTEGER;

--============================================================================
-- Procedure Name: Insert Record
-- Description:    Insert Record ( Only One record )
--============================================================================
   PROCEDURE INSERT_RECORD (
      p_tran_rec                 IN       pmt_trans_rec_type
   );

--============================================================================
  -- Procedure Name : Delete_Record
  -- Purpose        : Delete the Payment Transactions
--============================================================================
   PROCEDURE DELETE_RECORD (
      p_payment_transaction_id            NUMBER
   );

--============================================================================
-- Procedure Name: Insert Record ( Batch Insert )
-- Description:    Insert Record API called from Create Worksheet
-- Called From:    cnvwkshb.pls
--============================================================================
   PROCEDURE INSERT_RECORD (
      p_pay_by_transaction       IN       VARCHAR2,
      p_salesrep_id              IN       NUMBER,
      p_payrun_id                IN       NUMBER,
      p_pay_date                 IN       DATE,
      p_incentive_type           IN       VARCHAR2,
      p_pay_period_id            IN       NUMBER,
      p_credit_type_id           IN       NUMBER,
      p_posting_batch_id         IN       NUMBER,
      --R12
      p_org_id                   IN       NUMBER
   );

--============================================================================
--  Function      : get_pmt_tran_id
--  Description    : Main update procedure to update payment
--         transactions
--  Called From    : cnvpmtrb.pls ( Create_Pmt_Transactions )
--  Bug 3866089 (the same as 11.5.8 bug 3841926, 11.5.10 3866116) by jjhuang on 11/1/04
--============================================================================
   FUNCTION get_pmt_tran_id
      RETURN NUMBER;
END cn_pmt_trans_pkg;

 

/
