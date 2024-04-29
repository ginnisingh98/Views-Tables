--------------------------------------------------------
--  DDL for Package Body CN_PMT_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PMT_TRANS_PKG" AS
-- $Header: cntpmtrb.pls 120.9.12000000.2 2007/06/08 21:22:10 fmburu ship $ --+
   g_pkg_name           CONSTANT VARCHAR2 (30) := 'CN_PMT_TRANS_PKG';
--G_LAST_UPDATE_DATE        DATE         := SYSDATE;
   g_last_updated_by             NUMBER := fnd_global.user_id;
--G_CREATION_DATE           DATE         := SYSDATE;
   g_created_by                  NUMBER := fnd_global.user_id;
   g_last_update_login           NUMBER := fnd_global.login_id;
--Bug 3866089 (the same as 11.5.8 bug 3841926, 11.5.10 3866116) by jjhuang on 11/1/04
   g_payment_transaction_id      cn_payment_transactions.payment_transaction_id%TYPE;

--==============================================================================
--  Procedure      : Get_UID
--  Description    : Get the sequence number to create a new Payment Transactions
--==============================================================================
   PROCEDURE get_uid (
      x_payment_transaction_id   IN OUT NOCOPY NUMBER
   )
   IS
      CURSOR get_id
      IS
         SELECT cn_payment_transactions_s.NEXTVAL
           FROM DUAL;
   BEGIN
      OPEN get_id;

      FETCH get_id
       INTO x_payment_transaction_id;

      CLOSE get_id;

      --Bug 3866089 (the same as 11.5.8 bug 3841926, 11.5.10 3866116) by jjhuang on 11/1/04
      g_payment_transaction_id := x_payment_transaction_id;
   END get_uid;

--==============================================================================
--  Procedure      : Insert_Record
--  Description    : Insert Record into Cn_payment_Transactions
--  Called From:     cnvpmtrb.pls ( Create Manual Transactions )
--==============================================================================
   PROCEDURE INSERT_RECORD (
      p_tran_rec                 IN       pmt_trans_rec_type
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Insert_Record';
      l_payment_transaction_id      NUMBER;
   BEGIN
      -- Get Unique ID for posting detail
      get_uid (l_payment_transaction_id);

      -- Insert Record
      INSERT INTO cn_payment_transactions
                  (payment_transaction_id,
                   posting_batch_id,
                   credited_salesrep_id,
                   payee_salesrep_id,
                   quota_id,
                   pay_period_id,
                   incentive_type_code,
                   credit_type_id,
                   payrun_id,
                   amount,
                   payment_amount,
                   hold_flag,
                   paid_flag,
                   waive_flag,
                   recoverable_flag,
                   commission_header_id,
                   commission_line_id,
                   pay_element_type_id,
                   srp_plan_assign_id,
                   processed_date,
                   processed_period_id,
                   quota_rule_id,
                   event_factor,
                   payment_factor,
                   quota_factor,
                   input_achieved,
                   rate_tier_id,
                   payee_line_id,
                   commission_rate,
                   trx_type,
                   role_id,
                   expense_ccid,
                   liability_ccid,
                   attribute_category,
                   attribute1,
                   attribute2,
                   attribute3,
                   attribute4,
                   attribute5,
                   attribute6,
                   attribute7,
                   attribute8,
                   attribute9,
                   attribute10,
                   attribute11,
                   attribute12,
                   attribute13,
                   attribute14,
                   attribute15,
                   last_update_date,
                   last_updated_by,
                   last_update_login,
                   creation_date,
                   created_by,
                   --R12
                   org_id,
                   object_version_number
                  )
         (SELECT l_payment_transaction_id,
                 DECODE (p_tran_rec.posting_batch_id, cn_api.g_miss_id, NULL, p_tran_rec.posting_batch_id),
                 DECODE (p_tran_rec.credited_salesrep_id, cn_api.g_miss_id, NULL, p_tran_rec.credited_salesrep_id),
                 DECODE (p_tran_rec.payee_salesrep_id, cn_api.g_miss_id, NULL, p_tran_rec.payee_salesrep_id),
                 DECODE (p_tran_rec.quota_id, cn_api.g_miss_id, NULL, p_tran_rec.quota_id),
                 DECODE (p_tran_rec.pay_period_id, cn_api.g_miss_id, NULL, p_tran_rec.pay_period_id),
                 DECODE (p_tran_rec.incentive_type_code, fnd_api.g_miss_char, NULL, p_tran_rec.incentive_type_code),
                 DECODE (p_tran_rec.credit_type_id, cn_api.g_miss_id, -1000, p_tran_rec.credit_type_id),
                 DECODE (p_tran_rec.payrun_id, cn_api.g_miss_id, NULL, p_tran_rec.payrun_id),
                 DECODE (p_tran_rec.amount, cn_api.g_miss_num, 0, p_tran_rec.amount),
                 DECODE (p_tran_rec.payment_amount, cn_api.g_miss_num, 0, p_tran_rec.payment_amount),
                 DECODE (p_tran_rec.hold_flag, fnd_api.g_miss_char, 'N', p_tran_rec.hold_flag),
                 DECODE (p_tran_rec.paid_flag, fnd_api.g_miss_char, 'N', p_tran_rec.paid_flag),
                 DECODE (p_tran_rec.waive_flag, fnd_api.g_miss_char, 'N', p_tran_rec.waive_flag),
                 DECODE (p_tran_rec.recoverable_flag, fnd_api.g_miss_char, 'N', p_tran_rec.recoverable_flag),
                 DECODE (p_tran_rec.commission_header_id, cn_api.g_miss_id, NULL, p_tran_rec.commission_header_id),
                 DECODE (p_tran_rec.commission_line_id, cn_api.g_miss_id, NULL, p_tran_rec.commission_line_id),
                 DECODE (p_tran_rec.pay_element_type_id, cn_api.g_miss_id, NULL, p_tran_rec.pay_element_type_id),
                 DECODE (p_tran_rec.srp_plan_assign_id, cn_api.g_miss_id, NULL, p_tran_rec.srp_plan_assign_id),
                 DECODE (p_tran_rec.processed_date, fnd_api.g_miss_date, NULL, p_tran_rec.processed_date),
                 DECODE (p_tran_rec.processed_period_id, cn_api.g_miss_id, NULL, p_tran_rec.processed_period_id),
                 DECODE (p_tran_rec.quota_rule_id, cn_api.g_miss_id, NULL, p_tran_rec.quota_rule_id),
                 DECODE (p_tran_rec.event_factor, cn_api.g_miss_num, NULL, p_tran_rec.event_factor),
                 DECODE (p_tran_rec.payment_factor, cn_api.g_miss_num, NULL, p_tran_rec.payment_factor),
                 DECODE (p_tran_rec.quota_factor, cn_api.g_miss_num, NULL, p_tran_rec.quota_factor),
                 DECODE (p_tran_rec.input_achieved, cn_api.g_miss_num, NULL, p_tran_rec.input_achieved),
                 DECODE (p_tran_rec.rate_tier_id, cn_api.g_miss_id, NULL, p_tran_rec.rate_tier_id),
                 DECODE (p_tran_rec.payee_line_id, cn_api.g_miss_id, NULL, p_tran_rec.payee_line_id),
                 DECODE (p_tran_rec.commission_rate, cn_api.g_miss_num, NULL, p_tran_rec.commission_rate),
                 DECODE (p_tran_rec.trx_type, fnd_api.g_miss_char, NULL, p_tran_rec.trx_type),
                 DECODE (p_tran_rec.role_id, cn_api.g_miss_id, NULL, p_tran_rec.role_id),
                 DECODE (p_tran_rec.expense_ccid, cn_api.g_miss_id, NULL, p_tran_rec.expense_ccid),
                 DECODE (p_tran_rec.liability_ccid, cn_api.g_miss_id, NULL, p_tran_rec.liability_ccid),
                 DECODE (p_tran_rec.attribute_category, fnd_api.g_miss_char, NULL, p_tran_rec.attribute_category),
                 DECODE (p_tran_rec.attribute1, fnd_api.g_miss_char, NULL, p_tran_rec.attribute1),
                 DECODE (p_tran_rec.attribute2, fnd_api.g_miss_char, NULL, p_tran_rec.attribute2),
                 DECODE (p_tran_rec.attribute3, fnd_api.g_miss_char, NULL, p_tran_rec.attribute3),
                 DECODE (p_tran_rec.attribute4, fnd_api.g_miss_char, NULL, p_tran_rec.attribute4),
                 DECODE (p_tran_rec.attribute5, fnd_api.g_miss_char, NULL, p_tran_rec.attribute5),
                 DECODE (p_tran_rec.attribute6, fnd_api.g_miss_char, NULL, p_tran_rec.attribute6),
                 DECODE (p_tran_rec.attribute7, fnd_api.g_miss_char, NULL, p_tran_rec.attribute7),
                 DECODE (p_tran_rec.attribute8, fnd_api.g_miss_char, NULL, p_tran_rec.attribute8),
                 DECODE (p_tran_rec.attribute9, fnd_api.g_miss_char, NULL, p_tran_rec.attribute9),
                 DECODE (p_tran_rec.attribute10, fnd_api.g_miss_char, NULL, p_tran_rec.attribute10),
                 DECODE (p_tran_rec.attribute11, fnd_api.g_miss_char, NULL, p_tran_rec.attribute11),
                 DECODE (p_tran_rec.attribute12, fnd_api.g_miss_char, NULL, p_tran_rec.attribute12),
                 DECODE (p_tran_rec.attribute13, fnd_api.g_miss_char, NULL, p_tran_rec.attribute13),
                 DECODE (p_tran_rec.attribute14, fnd_api.g_miss_char, NULL, p_tran_rec.attribute14),
                 DECODE (p_tran_rec.attribute15, fnd_api.g_miss_char, NULL, p_tran_rec.attribute15),
                 SYSDATE,
                 fnd_global.user_id,
                 fnd_global.login_id,
                 SYSDATE,
                 fnd_global.user_id,
                 p_tran_rec.org_id,
                 nvl(p_tran_rec.object_version_number,1)
            FROM DUAL);
   END INSERT_RECORD;

--============================================================================
-- Procedure Name : Delete_Record
-- Purpose        : Delete the Payment Transactions
--============================================================================
   PROCEDURE DELETE_RECORD (
      p_payment_transaction_id            NUMBER
   )
   IS
   BEGIN
      DELETE FROM cn_payment_transactions
            WHERE payment_transaction_id = p_payment_transaction_id;
   END DELETE_RECORD;

--============================================================================
-- Procedure Name: Insert Record ( Batch Insert record
-- Description:    Insert Record API called from Create Worksheet
--       If the User calls this Table Hander
--                 we need need to check the pay by transaction value
--                 if the value is N we need to insert the record from
--          cn_commission_lines
--            if the value is Y then we need to insert from
--       cn_srp_periods
--       for all Quota ID and the Null QUOTA ID
-- Called from :   cnvwkshb.pls  ( Worksheet Creation )
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
   )
   IS
      -- Bug 2875120/2892822 : remove cn_api function call in sql statement
      -- Bug 2972172: Added distinct to get only one quota_id.
      CURSOR get_quotas
      IS
         SELECT DISTINCT q.quota_id,
                         q.incentive_type_code,
                         DECODE (r.payroll_flag, NULL, NULL, 'N', NULL, 'Y', qp.pay_element_type_id, NULL) pay_element_type_id
                    FROM cn_srp_periods srp,
                         cn_quotas_all q,
                         cn_quota_pay_elements_all qp,
                         cn_rs_salesreps s,
                         cn_repositories r
                   WHERE srp.salesrep_id = p_salesrep_id
                     AND srp.period_id = p_pay_period_id
                     AND srp.quota_id = q.quota_id
                     AND srp.credit_type_id = p_credit_type_id
                     AND q.incentive_type_code =
                            DECODE (NVL (p_incentive_type, q.incentive_type_code),
                                    'COMMISSION', 'COMMISSION',
                                    'BONUS', 'BONUS',
                                    q.incentive_type_code
                                   )
                     AND qp.quota_id(+) = q.quota_id
                     AND p_pay_date BETWEEN qp.start_date(+) AND qp.end_date(+)
                     AND s.salesrep_id = srp.salesrep_id
                     AND NVL (s.status, 'A') = NVL (qp.status, NVL (s.status, 'A'))
                     --R12
                     AND srp.org_id = q.org_id
                     AND q.org_id = s.org_id
                     AND s.org_id = r.org_id
                     AND r.org_id = p_org_id;

      l_held_amount                 NUMBER;
      l_quota_id                    cn_payment_transactions.quota_id%TYPE;

      l_payroll_flag cn_repositories.payroll_flag%TYPE;
      l_org_id   cn_repositories.org_id%TYPE ;
      l_status   cn_salesreps.status%TYPE ;
      l_period_set_id    cn_repositories.period_set_id%TYPE ;
      l_period_type_id   cn_repositories.period_type_id%TYPE ;

   BEGIN

      SELECT s.org_id, s.status, r.period_set_id, r.period_type_id, NVL(r.payroll_flag,'N')
      INTO   l_org_id, l_status, l_period_set_id, l_period_type_id, l_payroll_flag
      FROM   cn_salesreps s, cn_repositories_all r, cn_payruns_all pr
      WHERE  s.salesrep_id = p_salesrep_id
      AND    s.org_id =  r.org_id
      AND    pr.org_id = r.org_id
      AND    pr.payrun_id = p_payrun_id
      ;

      IF p_pay_by_transaction = 'N'
      THEN
         -- 11/21/02 RC Added the following code to remove
          --             non payment plan recovery transactions
          --             when profile is changed from pay by transaction
          --             to pay by summary
         DELETE FROM cn_payment_transactions
               WHERE incentive_type_code <> 'PMTPLN_REC'
                 AND NVL (hold_flag, 'N') = 'N'
                 AND NVL (paid_flag, 'N') = 'N'
                 AND credited_salesrep_id = p_salesrep_id
                 AND pay_period_id <= p_pay_period_id
                 AND payrun_id IS NULL
                 --R12
                 AND org_id = p_org_id;

         FOR each_quota IN get_quotas
         LOOP
            SELECT NVL (SUM (NVL (amount, 0)), 0)
              INTO l_held_amount
              FROM cn_payment_transactions
             WHERE credited_salesrep_id = p_salesrep_id
               AND pay_period_id <= p_pay_period_id
               AND quota_id = each_quota.quota_id
               AND payrun_id IS NULL
               AND NVL (hold_flag, 'N') = 'Y'
               AND NVL (paid_flag, 'N') = 'N' ;

            -- Bug 2868584 :Add SUM and Group By clause
            -- handle scenarios where a salesrep has multiple role assignments
            -- during the same period, with an overlapping quota assignment
            INSERT INTO cn_payment_transactions
                        (payment_transaction_id,
                         posting_batch_id,
                         incentive_type_code,
                         credit_type_id,
                         pay_period_id,
                         amount,
                         payment_amount,
                         credited_salesrep_id,
                         payee_salesrep_id,
                         paid_flag,
                         hold_flag,
                         waive_flag,
                         payrun_id,
                         quota_id,
                         pay_element_type_id,
                         created_by,
                         creation_date,
                         last_update_date,
                         --Bug 3080846 for who columns
                         last_updated_by,
                         --Bug 3080846 for who columns
                         last_update_login,
                         --Bug 3080846 for who columns
                         org_id,
                         object_version_number
                        )
               SELECT cn_payment_transactions_s.NEXTVAL,
                      p_posting_batch_id,
                      v1.incentive_type_code,
                      v1.credit_type_id,
                      v1.period_id,
                      v1.amount,
                      v1.payment_amount,
                      v1.salesrep_id,
                      v1.salesrep_id,
                      'N',
                      'N',
                      'N',
                      p_payrun_id,
                      v1.quota_id,
                      v1.pay_element_type_id,
                      g_created_by,
                      SYSDATE,
                      SYSDATE,
                      --Bug 3080846 for who columns
                      g_last_updated_by,
                      g_last_update_login,
                      --Bug 3080846 for who columns
                                 --R12
                      v1.org_id,
                      1
                 FROM (SELECT   each_quota.incentive_type_code incentive_type_code,
                                srp.credit_type_id,
                                srp.period_id,
                                SUM (  (NVL (srp.balance2_dtd, 0) - NVL (srp.balance2_ctd, 0) + NVL (srp.balance2_bbd, 0) - NVL (srp.balance2_bbc, 0))
                                     - l_held_amount
                                    ) amount,
                                SUM (  (NVL (srp.balance2_dtd, 0) - NVL (srp.balance2_ctd, 0) + NVL (srp.balance2_bbd, 0) - NVL (srp.balance2_bbc, 0))
                                     - l_held_amount
                                    ) payment_amount,
                                srp.salesrep_id,
                                srp.quota_id,
                                each_quota.pay_element_type_id pay_element_type_id,
                                --R12
                                srp.org_id
                           FROM cn_srp_periods srp
                          WHERE srp.salesrep_id = p_salesrep_id
                            AND srp.period_id = p_pay_period_id
                            AND srp.quota_id = each_quota.quota_id
                            AND srp.quota_id <> -1000
                            -- Bug 2819874:add carry over record
                            AND srp.credit_type_id = p_credit_type_id
                            --R12
                            AND srp.org_id = p_org_id
                       GROUP BY srp.quota_id,
                                srp.credit_type_id,
                                srp.period_id,
                                srp.salesrep_id,
                                srp.org_id) v1;
         END LOOP;

         -- Bug 2819874 -  Insert the carry over Record,regardless incentive type
         -- code
         SELECT NVL (SUM (NVL (amount, 0)), 0)
           INTO l_held_amount
           FROM cn_payment_transactions
          WHERE credited_salesrep_id = p_salesrep_id
            AND pay_period_id <= p_pay_period_id
            AND quota_id = -1000
            AND payrun_id IS NULL
            AND NVL (hold_flag, 'N') = 'Y'
            AND NVL (paid_flag, 'N') = 'N'
            --R12
            AND org_id = p_org_id;

         INSERT INTO cn_payment_transactions
                     (payment_transaction_id,
                      posting_batch_id,
                      incentive_type_code,
                      credit_type_id,
                      pay_period_id,
                      amount,
                      payment_amount,
                      credited_salesrep_id,
                      payee_salesrep_id,
                      paid_flag,
                      hold_flag,
                      waive_flag,
                      payrun_id,
                      quota_id,
                      pay_element_type_id,
                      -- Bug 2880233 : add pay_element_type_id
                      created_by,
                      creation_date,
                      last_update_date,
                      --Bug 3080846 for who columns
                      last_updated_by,
                      --Bug 3080846 for who columns
                      last_update_login,
                      org_id,
                      object_version_number
                     )
            SELECT cn_payment_transactions_s.NEXTVAL,
                   p_posting_batch_id,
                   'COMMISSION',
                   srp.credit_type_id,
                   srp.period_id,
                     NVL ((NVL (srp.balance2_dtd, 0) - NVL (srp.balance2_ctd, 0) + NVL (srp.balance2_bbd, 0) - NVL (srp.balance2_bbc, 0)), 0)
                   - l_held_amount,
                     NVL ((NVL (srp.balance2_dtd, 0) - NVL (srp.balance2_ctd, 0) + NVL (srp.balance2_bbd, 0) - NVL (srp.balance2_bbc, 0)), 0)
                   - l_held_amount,
                   srp.salesrep_id,
                   srp.salesrep_id,
                   'N',
                   'N',
                   'N',
                   p_payrun_id,
                   -1000,
                   DECODE (r.payroll_flag, NULL, NULL, 'N', NULL, 'Y', qp.pay_element_type_id, NULL) pay_element_type_id,
                   g_created_by,
                   SYSDATE,
                   SYSDATE,
                   --Bug 3080846 for who columns
                   g_last_updated_by,
                   --Bug 3080846 for who columns
                   g_last_update_login,--Bug 3080846 for who columns
                   srp.org_id,
                   1
              FROM cn_srp_periods srp,
                   cn_quota_pay_elements_all qp,
                   cn_rs_salesreps s,
                   cn_repositories r
             WHERE srp.salesrep_id = p_salesrep_id
               AND srp.period_id = p_pay_period_id
               AND srp.credit_type_id = p_credit_type_id
               AND srp.quota_id = -1000
               AND   NVL ((NVL (srp.balance2_dtd, 0) - NVL (srp.balance2_ctd, 0) + NVL (srp.balance2_bbd, 0) - NVL (srp.balance2_bbc, 0)), 0)
                   - l_held_amount <> 0
               AND qp.quota_id(+) = srp.quota_id
               AND p_pay_date BETWEEN qp.start_date(+) AND qp.end_date(+)
               AND s.salesrep_id = srp.salesrep_id
               AND NVL (s.status, 'A') = NVL (qp.status, NVL (s.status, 'A'))
               --R12
               AND srp.org_id = r.org_id
               AND s.org_id = p_org_id
               AND r.org_id = p_org_id;
      ELSE
      -- pay by transaction
         --Payee bug 3140343.
         IF cn_api.is_payee (p_salesrep_id, p_pay_period_id, p_org_id) = 1
         THEN
            --New insert here for payee
            INSERT INTO cn_payment_transactions
                        (payment_transaction_id,
                         posting_batch_id,
                         trx_type,
                         payee_salesrep_id,
                         role_id,
                         incentive_type_code,
                         credit_type_id,
                         pay_period_id,
                         amount,
                         commission_header_id,
                         commission_line_id,
                         srp_plan_assign_id,
                         quota_id,
                         credited_salesrep_id,
                         processed_period_id,
                         quota_rule_id,
                         event_factor,
                         payment_factor,
                         quota_factor,
                         input_achieved,
                         rate_tier_id,
                         payee_line_id,
                         commission_rate,
                         hold_flag,
                         paid_flag,
                         waive_flag,
                         recoverable_flag,
                         payrun_id,
                         payment_amount,
                         pay_element_type_id,
                         creation_date,
                         created_by,
                         last_update_date,
                         last_updated_by,
                         last_update_login,
                         org_id,
                         object_version_number,
                         processed_date
                        )
               SELECT cn_payment_transactions_s.NEXTVAL,
                      p_posting_batch_id,
                      cl.trx_type,
                      spayee.payee_id,
                      cl.role_id,
                      pe.incentive_type_code,
                      cl.credit_type_id,
                      cl.pay_period_id,
                      NVL (cl.commission_amount, 0),
                      cl.commission_header_id,
                      cl.commission_line_id,
                      cl.srp_plan_assign_id,
                      cl.quota_id,
                      spayee.payee_id,
                      cl.processed_period_id,
                      cl.quota_rule_id,
                      cl.event_factor,
                      cl.payment_factor,
                      cl.quota_factor,
                      cl.input_achieved,
                      cl.rate_tier_id,
                      cl.payee_line_id,
                      cl.commission_rate,
                      'N',
                      'N',
                      'N',
                      'N',
                      p_payrun_id,
                      NVL (cl.commission_amount, 0),
                      DECODE (l_payroll_flag, NULL, NULL, 'N', NULL, 'Y', qp.pay_element_type_id, NULL) pay_element_type_id,
                      SYSDATE,
                      fnd_global.user_id,
                      SYSDATE,
                      g_last_updated_by,
                      g_last_update_login,
                      cl.org_id,
                      1,
                      cl.processed_date
                 FROM cn_commission_lines cl,
                      cn_quotas_all pe,
                      cn_quota_pay_elements_all qp,
                      cn_srp_payee_assigns_all spayee
                WHERE cl.srp_payee_assign_id IS NOT NULL
                  AND cl.srp_payee_assign_id = spayee.srp_payee_assign_id
                  AND spayee.payee_id = p_salesrep_id
                  AND cl.credited_salesrep_id = spayee.salesrep_id
                  AND cl.processed_period_id <= p_pay_period_id
                  AND cl.status = 'CALC'
                  AND cl.posting_status = 'UNPOSTED'
                  AND cl.quota_id = pe.quota_id
                  AND cl.credit_type_id = p_credit_type_id
                  AND pe.incentive_type_code =
                         DECODE (NVL (p_incentive_type, pe.incentive_type_code),
                                 'COMMISSION', 'COMMISSION',
                                 'BONUS', 'BONUS',
                                 pe.incentive_type_code
                                )
                  AND qp.quota_id(+) = cl.quota_id
                  AND p_pay_date BETWEEN qp.start_date(+) AND qp.end_date(+)
                  AND cl.org_id = spayee.org_id
                  AND NVL (l_status, 'A') = NVL (qp.status, NVL (l_status, 'A'))
                  AND cl.processed_date <= p_pay_date
                  AND cl.org_id = spayee.org_id
                  AND cl.org_id = p_org_id ;

         ELSE
            INSERT INTO cn_payment_transactions
                        (payment_transaction_id,
                         posting_batch_id,
                         trx_type,
                         payee_salesrep_id,
                         role_id,
                         incentive_type_code,
                         credit_type_id,
                         pay_period_id,
                         amount,
                         commission_header_id,
                         commission_line_id,
                         srp_plan_assign_id,
                         quota_id,
                         credited_salesrep_id,
                         processed_period_id,
                         quota_rule_id,
                         event_factor,
                         payment_factor,
                         quota_factor,
                         input_achieved,
                         rate_tier_id,
                         payee_line_id,
                         commission_rate,
                         hold_flag,
                         paid_flag,
                         waive_flag,
                         recoverable_flag,
                         payrun_id,
                         payment_amount,
                         pay_element_type_id,
                         creation_date,
                         created_by,
                         last_update_date,
                         last_updated_by,
                         last_update_login,
                         org_id,
                         object_version_number,
                         processed_date
                        )
               SELECT cn_payment_transactions_s.NEXTVAL,
                      p_posting_batch_id,
                      cl.trx_type,
                      cl.credited_salesrep_id,
                      cl.role_id,
                      pe.incentive_type_code,
                      cl.credit_type_id,
                      -- 2/7/03 AC Bug 2792037
                      cl.pay_period_id,
                      NVL (cl.commission_amount, 0),
                      cl.commission_header_id,
                      cl.commission_line_id,
                      cl.srp_plan_assign_id,
                      cl.quota_id,
                      cl.credited_salesrep_id,
                      cl.processed_period_id,
                      cl.quota_rule_id,
                      cl.event_factor,
                      cl.payment_factor,
                      cl.quota_factor,
                      cl.input_achieved,
                      cl.rate_tier_id,
                      cl.payee_line_id,
                      cl.commission_rate,
                      'N',
                      'N',
                      'N',
                      'N',
                      p_payrun_id,
                      NVL (cl.commission_amount, 0),
                      -- Bug 2875120 : remove cn_api function call in sql statement
                      DECODE (l_payroll_flag, NULL, NULL, 'N', NULL, 'Y', qp.pay_element_type_id, NULL) pay_element_type_id,
                      SYSDATE,
                      fnd_global.user_id,
                      SYSDATE,
                      --Bug 3080846 for who columns
                      g_last_updated_by,
                      g_last_update_login,
                      --Bug 3080846 for who columns
                      cl.org_id,
                      1,
                      cl.processed_date
                 FROM cn_commission_lines cl,
                      cn_quotas_all pe,
                      cn_quota_pay_elements_all qp
                WHERE cl.credited_salesrep_id = p_salesrep_id
                  AND cl.processed_period_id <= p_pay_period_id
                  AND cl.status = 'CALC'
                  AND cl.posting_status = 'UNPOSTED'
                  AND cl.quota_id = pe.quota_id
                  AND cl.credit_type_id = p_credit_type_id
                  AND pe.incentive_type_code =
                         DECODE (NVL (p_incentive_type, pe.incentive_type_code),
                                 'COMMISSION', 'COMMISSION',
                                 'BONUS', 'BONUS',
                                 pe.incentive_type_code
                                )
                  AND qp.quota_id(+) = cl.quota_id
                  AND p_pay_date BETWEEN qp.start_date(+) AND qp.end_date(+)
                  AND NVL (l_status, 'A') = NVL (qp.status, NVL (l_status, 'A'))
                  -- Payee bug 3140343.
                  AND cl.srp_payee_assign_id IS NULL
                  -- 3/16/04 Julia Huang for bug 3486328
                  AND cl.processed_date <= p_pay_date
                  AND cl.org_id = p_org_id;

         END IF;
         --end of checking if it's a payee for payee bug 3140343.
      END IF;

      --PBS
      IF p_pay_by_transaction = 'N'
      THEN
         UPDATE cn_payment_transactions ptx
            SET payrun_id = p_payrun_id,
                pay_element_type_id =
                   (SELECT DECODE (l_payroll_flag, 'Y', p.pay_element_type_id, NULL) pay_element_type_id
                      FROM cn_quota_pay_elements p
                     WHERE p.quota_id = ptx.quota_id
                       AND p_pay_date BETWEEN p.start_date AND p.end_date
                       AND NVL (l_status, 'A') = p.status),
                --bug 3080846
                last_update_date = SYSDATE,
                last_updated_by = g_last_updated_by,
                last_update_login = g_last_update_login
          WHERE credited_salesrep_id = p_salesrep_id
            AND pay_period_id <= p_pay_period_id
            AND incentive_type_code =
                               DECODE (NVL (p_incentive_type, incentive_type_code),
                                       'COMMISSION', 'COMMISSION',
                                       'BONUS', 'BONUS',
                                       incentive_type_code
                                      )
            AND incentive_type_code IN ('COMMISSION', 'BONUS')
            AND payrun_id IS NULL
            --R12
            AND org_id = p_org_id;
      ELSE                               --PBT
         UPDATE cn_payment_transactions ptx
            SET payrun_id = p_payrun_id,
                pay_element_type_id =
                   (SELECT DECODE (l_payroll_flag, 'Y', p.pay_element_type_id, NULL) pay_element_type_id
                      FROM cn_quota_pay_elements p
                     WHERE p.quota_id = ptx.quota_id
                       AND p_pay_date BETWEEN p.start_date AND p.end_date
                       AND NVL (l_status, 'A') = p.status),
                --bug 3080846
                last_update_date = SYSDATE,
                last_updated_by = g_last_updated_by,
                last_update_login = g_last_update_login
          WHERE credited_salesrep_id = p_salesrep_id
            AND pay_period_id <= p_pay_period_id
            AND incentive_type_code =
                               DECODE (NVL (p_incentive_type, incentive_type_code),
                                       'COMMISSION', 'COMMISSION',
                                       'BONUS', 'BONUS',
                                       incentive_type_code
                                      )
            AND incentive_type_code IN ('COMMISSION', 'BONUS')
            AND payrun_id IS NULL
            --- bug5170930 instead of looking at the header for processed date
            AND processed_date <= p_pay_date
            AND ptx.org_id = p_org_id ;

      END IF;

      UPDATE cn_payment_transactions ptx
         SET payrun_id = p_payrun_id,
             pay_element_type_id =
                (SELECT DECODE (l_payroll_flag, 'Y', p.pay_element_type_id, NULL) pay_element_type_id
                   FROM cn_quota_pay_elements p
                  WHERE p.quota_id = -1001
                    AND p_pay_date BETWEEN p.start_date AND p.end_date
                    AND NVL (l_status, 'A') = p.status
                    AND p.org_id = p_org_id),
             last_update_date = SYSDATE,
             last_updated_by = g_last_updated_by,
             last_update_login = g_last_update_login
       WHERE credited_salesrep_id = p_salesrep_id
         AND pay_period_id <= p_pay_period_id
         AND incentive_type_code = 'PMTPLN_REC'
         AND payrun_id IS NULL
         --Added by Julia Huang on 10/1/03 for 'COMMISSON' or 'BONUS' type payrun.
         AND ptx.quota_id IN (
                SELECT quota_id
                  FROM cn_quotas_all cqa
                 WHERE cqa.quota_id = ptx.quota_id
                   AND cqa.incentive_type_code =
                          DECODE (NVL (p_incentive_type, cqa.incentive_type_code),
                                  'COMMISSION', 'COMMISSION',
                                  'BONUS', 'BONUS',
                                  cqa.incentive_type_code
                                 )
                   AND cqa.org_id = p_org_id);
   END INSERT_RECORD;

--============================================================================
--  Function      : get_pmt_tran_id
--  Description    : Main update procedure to update payment
--         transactions
--  Called From    : cnvpmtrb.pls ( Create_Pmt_Transactions )
--  Bug 3866089 (the same as 11.5.8 bug 3841926, 11.5.10 3866116) by jjhuang on 11/1/04
--============================================================================
   FUNCTION get_pmt_tran_id
      RETURN NUMBER
   IS
   BEGIN
      RETURN g_payment_transaction_id;
   END get_pmt_tran_id;
END cn_pmt_trans_pkg;

/
