--------------------------------------------------------
--  DDL for Package Body CN_PMT_TRANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PMT_TRANS_PVT" AS
-- $Header: cnvpmtrb.pls 120.15 2006/01/20 18:51:53 fmburu ship $
   g_pkg_name           CONSTANT VARCHAR2 (30) := 'CN_Pmt_Trans_PVT';
   g_credit_type_id              NUMBER := -1000;

   CURSOR get_transactions_details(
             c_payrun_id         NUMBER,
             c_salesrep_id       NUMBER,
             c_quota_id          NUMBER,
             c_revenue_class_id  NUMBER,
             c_invoice_number    VARCHAR2,
             c_order_number      NUMBER,
             c_customer_name     VARCHAR2,
             c_hold_flag         VARCHAR2,
             c_action            VARCHAR2)
    IS
    SELECT
      pmttrxeo.payment_transaction_id,
      pmttrxeo.quota_id quotaId,
      pmttrxeo.hold_flag,
      pmttrxeo.amount,
      pmttrxeo.payment_amount,
      pmttrxeo.payrun_id,
      pmttrxeo.credited_salesrep_id,
      pmttrxeo.org_id,
      pmttrxeo.object_version_number,
      pmttrxeo.incentive_type_code,
      pmttrxeo.waive_flag,
      pmttrxeo.recoverable_flag
    FROM
      cn_payment_transactions pmttrxeo,
      cn_commission_headers ch,
      (select cust_acct.cust_account_id customer_id,
              party.party_name customer_name
           from hz_parties party, hz_cust_accounts cust_acct
           where cust_acct.party_id = party.party_id) cus
    WHERE
          pmttrxeo.payrun_id =            c_payrun_id
      and pmttrxeo.credited_salesrep_id = c_salesrep_id
      and pmttrxeo.incentive_type_code in ('COMMISSION','BONUS')
      and pmttrxeo.commission_header_id = ch.commission_header_id
      and pmttrxeo.quota_id =           NVL(c_quota_id, pmttrxeo.quota_id)
      and (ch.revenue_class_id =   NVL(c_revenue_class_id, ch.revenue_class_id)
          OR (ch.revenue_class_id IS NULL and c_revenue_class_id IS NULL))
      and pmttrxeo.hold_flag LIKE NVL(c_hold_flag, pmttrxeo.hold_flag)
      -- hold or release only when necessary
      and pmttrxeo.hold_flag = DECODE(c_action, 'HOLD_ALL', 'N', 'RELEASE_ALL', 'Y', pmttrxeo.hold_flag)
      and NVL(ch.invoice_number, '%') LIKE  NVL(c_invoice_number, NVL(ch.invoice_number, '%'))
      and (ch.order_number = nvl(c_order_number,ch.order_number)
           OR (c_order_number IS NULL and ch.order_number IS NULL))
      and nvl(ch.customer_id,-0.9999) = cus.customer_id(+)
      and NVL(cus.customer_name, '%') LIKE  NVL(c_customer_name,  NVL(cus.customer_name, '%')) ;

--============================================================================
-- Procedure : DEBUG PROCEDURE
-- Description: To debug information
--============================================================================
   PROCEDURE DEBUG( ID NUMBER, MSG VARCHAR2)
   IS
   BEGIN
       --dbms_output.put_line('Msg:'|| id || ': Text : ' || msg ) ;
       NULL ;
   END ;

--============================================================================
-- Procedure : Update_Pmt_Transactions
-- Description: To update Payment Transctions information
--============================================================================
    PROCEDURE validate_hold_processing (
          p_api_version              IN       NUMBER,
          p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
          p_commit                   IN       VARCHAR2 := fnd_api.g_false,
          p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
          p_rec                      IN OUT NOCOPY pmt_process_rec,
          x_return_status            OUT NOCOPY VARCHAR2,
          x_msg_count                OUT NOCOPY NUMBER,
          x_msg_data                 OUT NOCOPY VARCHAR2 )
     IS
          l_api_name           CONSTANT VARCHAR2 (30) := 'validate_hold_processing';
          l_api_version        CONSTANT NUMBER := 1.0;
          l_request_id         NUMBER := NULL ;
          l_org_id             NUMBER := NULL ;
          l_worksheet_id       NUMBER := NULL;
          l_status             cn_payment_worksheets.worksheet_status%TYPE ;
          l_ovn                NUMBER := NULL ;
          request_id NUMBER;
          l_phase VARCHAR2(4000);
          l_req_status VARCHAR2(4000);
          l_dev_phase VARCHAR2(4000);
          l_dev_status VARCHAR2(4000);
          l_message VARCHAR2(4000);
          l_ret_val BOOLEAN ;
          pmt_trxn_rec get_transactions_details%ROWTYPE ;
     BEGIN
          -- Standard Start of API savepoint
          SAVEPOINT validate_hold_processing;

          -- Standard call to check for call compatibility.
          IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
          THEN
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          -- Initialize message list if p_init_msg_list is set to TRUE.
          IF fnd_api.to_boolean (p_init_msg_list)
          THEN
             fnd_msg_pub.initialize;
          END IF;

          --  Initialize API return status to success
          x_return_status := fnd_api.g_ret_sts_success;

          --debug(1, 'IN VALIDATE_HOLD_PROCESSING') ;

          BEGIN
              SELECT worksheet_status,
                     request_id,
                     payment_worksheet_id,
                     object_version_number,
                     org_id
              INTO  l_status, l_request_id, p_rec.worksheet_id,l_ovn, p_rec.org_id
              FROM  cn_payment_worksheets
              WHERE quota_id is null
              AND   payrun_id =   p_rec.payrun_id
              AND   salesrep_id = p_rec.salesrep_id ;

          EXCEPTION
          WHEN NO_DATA_FOUND THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_WKSHT_DOES_NOT_EXIST');
                  fnd_msg_pub.ADD;
               END IF;
               --debug(222, 'In the NO_DATA_FOUND') ;
               RAISE fnd_api.g_exc_error;
          END ;

          IF p_rec.object_version_number IS NOT NULL AND l_ovn <> p_rec.object_version_number THEN
               -- record has changed
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_RECORD_CHANGED');
                  fnd_msg_pub.ADD;
               END IF;
               RAISE fnd_api.g_exc_error;
          END IF ;

          IF NVL(p_rec.hold_flag, 'N') NOT IN ('N', 'Y') THEN
              IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
              THEN
                fnd_message.set_name ('CN', 'CN_INVALID_HOLD_PARAM');
                fnd_msg_pub.ADD;
              END IF;
              RAISE fnd_api.g_exc_error;
          END IF ;

          IF p_rec.p_action IN (CN_PMT_TRANS_PVT.G_HOLD_ALL,CN_PMT_TRANS_PVT.G_RELEASE_ALL)
          THEN
               BEGIN
                  OPEN get_transactions_details(
                      p_rec.payrun_id,
                      p_rec.salesrep_id,
                      p_rec.quota_id,
                      p_rec.revenue_class_id,
                      p_rec.invoice_number,
                      p_rec.order_number,
                      p_rec.customer,
                      p_rec.hold_flag,
                      p_rec.p_action) ;

                  FETCH get_transactions_details INTO pmt_trxn_rec;
                  IF get_transactions_details%NOTFOUND THEN
                      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                      THEN
                        fnd_message.set_name ('CN', 'CN_NO_TRXNS_TO_PROCESS');
                        fnd_msg_pub.ADD;
                      END IF;
                      RAISE fnd_api.g_exc_error;
                  END IF;
                  CLOSE get_transactions_details ;
               EXCEPTION
               WHEN OTHERS THEN
                    CLOSE get_transactions_details ;
                    RAISE ;
               END ;
          ELSIF p_rec.p_action = CN_PMT_TRANS_PVT.G_RESET_TO_UNPAID
          THEN
               NULL ;
          ELSE
               -- throw the error, should not be calling this procedure in this start
              IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
              THEN
                fnd_message.set_name ('CN', 'CN_WKSHT_ACTION_NOT_EXIST');
                fnd_msg_pub.ADD;
              END IF;
              RAISE fnd_api.g_exc_error;
          END IF ;

         --debug(2, 'IF l_status = PROCESSING THEN') ;

          IF l_status = 'PROCESSING' AND nvl(p_rec.is_processing,'NO') <> 'YES' THEN
             -- cannot resubmit a new request when worksheet is processing if the last request is not complete or cancelled
             -- should send error message saying that another has already been submitted

             l_ret_val := fnd_concurrent.get_request_status( l_request_id,
                                                NULL,
                                                NULL,
                                                l_phase,
                                                l_req_status,
                                                l_dev_phase,
                                                l_dev_status,
                                                l_message);
             IF l_phase = 'INACTIVE' THEN
                 -- the previous request has not yet completed. Please check with system admin
                 -- cannot submit another request.
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                 THEN
                    fnd_message.set_name ('CN', 'CN_LAST_REQ_INACTIVE');
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_error;
             ELSE
                 IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                 THEN
                    fnd_message.set_name ('CN', 'CN_LAST_REQ_NOT_COMPLETED');
                    fnd_msg_pub.ADD;
                 END IF;
                 RAISE fnd_api.g_exc_error;
             END IF ;

          ELSIF l_status IN ( 'FAILED', 'UNPAID' ) THEN
             -- can resubmit the request but we need a new request id
            NULL ;
          END IF;

          cn_payment_security_pvt.worksheet_action(p_api_version           => p_api_version,
                                                   p_init_msg_list         => p_init_msg_list,
                                                   p_commit                => fnd_api.g_false,
                                                   p_validation_level      => p_validation_level,
                                                   x_return_status         => x_return_status,
                                                   x_msg_count             => x_msg_count,
                                                   x_msg_data              => x_msg_data,
                                                   p_worksheet_id          => p_rec.worksheet_id,
                                                   p_action                => p_rec.p_action,
                                                   p_do_audit              => fnd_api.g_false
                                                  );

        IF x_return_status <> fnd_api.g_ret_sts_success
        THEN
          --debug(4, 'raise expcetion cn_payment_security_pvt.worksaction' || x_return_status ) ;
          RAISE fnd_api.g_exc_error;
        END IF;

     EXCEPTION
          WHEN fnd_api.g_exc_error
          THEN
             ROLLBACK TO validate_hold_processing;
             x_return_status := fnd_api.g_ret_sts_error;
             fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
          WHEN fnd_api.g_exc_unexpected_error
          THEN
             ROLLBACK TO validate_hold_processing;
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
          WHEN OTHERS
          THEN
             ROLLBACK TO validate_hold_processing;
             x_return_status := fnd_api.g_ret_sts_unexp_error;

             IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
             THEN
                fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
             END IF;
             fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
    END validate_hold_processing;



--============================================================================
-- Procedure : Update_Pmt_Transactions
-- Description: To update Payment Transctions information
--       1. Manual Adjustments
--    2. Manual Adjustments Recoverable or Non recoverable
--    3. Waive Recovery
--    4. Commission or Bonus Adjustments
--    5. Commission or Bonus Hold
--============================================================================
   PROCEDURE update_pmt_transactions (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_commit                   IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_payment_transaction_id   IN       cn_payment_transactions.payment_transaction_id%TYPE,
      p_hold_flag                IN       cn_payment_transactions.hold_flag%TYPE,
      p_recoverable_flag         IN       cn_payment_transactions.recoverable_flag%TYPE,
      p_payment_amount           IN       cn_payment_transactions.payment_amount%TYPE,
      p_waive_flag               IN       cn_payment_transactions.waive_flag%TYPE,
      p_incentive_type_code      IN       cn_payment_transactions.incentive_type_code%TYPE,
      p_payrun_id                IN       cn_payment_transactions.payrun_id%TYPE,
      p_salesrep_id              IN       cn_payment_transactions.credited_salesrep_id%TYPE,
      x_status                   OUT NOCOPY VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2,
      --R12
      p_org_id                   IN       cn_payment_transactions.org_id%TYPE,
      p_object_version_number    IN OUT NOCOPY cn_payment_transactions.object_version_number%TYPE
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Update_Pmt_Transactions';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_counter                     NUMBER;
      l_rec_amount                  NUMBER;
      l_nrec_amount                 NUMBER;
      l_calc_amount                 NUMBER;
      l_adj_amount                  NUMBER;
      l_old_amount                  NUMBER;
      l_new_amount                  NUMBER;
      l_pbt_profile_value           VARCHAR2 (01) := 'N';
      l_count                       NUMBER;
      l_earnings                    NUMBER;
      l_pmt_trans_rec               cn_pmt_trans_pkg.pmt_trans_rec_type;
      l_recovery_amount             NUMBER;
      l_payment_amount              NUMBER;
      l_wksht_ovn                   NUMBER;

      CURSOR get_pmt_trans
      IS
         SELECT payment_transaction_id,
                amount,
                payment_amount,
                hold_flag,
                recoverable_flag,
                quota_id,
                payrun_id,
                credited_salesrep_id,
                --R12
                org_id,
                object_version_number ovn
           FROM cn_payment_transactions
          WHERE payment_transaction_id = p_payment_transaction_id;

      -- clku, bug 2451907, fixed the Group by statement, adding waive_flag
      CURSOR get_earnings (
         p_quota_id                          cn_payment_transactions.quota_id%TYPE
      )
      IS
         SELECT NVL (SUM (NVL (amount, 0)), 0) earn_amount
           -- 12/25/02 RC bug 2710066
           -- Commenting out waive_flag and quota_id from group by
           -- quota_id
           --, waive_flag
         FROM   cn_payment_transactions
          WHERE payrun_id = p_payrun_id
            AND credited_salesrep_id = p_salesrep_id
            AND NVL (paid_flag, 'N') = 'N'
            AND NVL (hold_flag, 'N') = 'N'
            AND incentive_type_code IN ('COMMISSION', 'BONUS')
            AND quota_id = p_quota_id
            --R12
            AND org_id = p_org_id;

      l_earn                        NUMBER;

      -- 12/25/02 RC bug 2710066
      CURSOR get_wksht_nullqid
      IS
         SELECT NVL (SUM (NVL (pmt_amount_calc, 0)), 0) earn_amount
           FROM cn_payment_worksheets
          WHERE payrun_id = p_payrun_id
          AND salesrep_id = p_salesrep_id
          AND quota_id IS NULL;

      l_wksht_null_earn             NUMBER;

      CURSOR get_wksht_notnullqid
      IS
         SELECT NVL (SUM (NVL (pmt_amount_calc, 0)), 0) earn_amount
           FROM cn_payment_worksheets
          WHERE payrun_id = p_payrun_id
          AND salesrep_id = p_salesrep_id AND quota_id IS NOT NULL
          AND org_id = p_org_id;

      l_wksht_not_null_earn         NUMBER;
      l_delta_earn                  NUMBER;
      pmt_trans_rec                 get_pmt_trans%ROWTYPE;

      -- get the worksheet when waive the recovery
      CURSOR get_wksht (
         p_payrun_id                         cn_payment_transactions.payrun_id%TYPE,
         p_salesrep_id                       cn_payment_transactions.credited_salesrep_id%TYPE,
         p_quota_id                          cn_payment_transactions.quota_id%TYPE
      )
      IS
         SELECT *
           FROM cn_payment_worksheets
          WHERE payrun_id = p_payrun_id
            AND salesrep_id = p_salesrep_id
            AND quota_id = p_quota_id
            AND EXISTS (
                   SELECT 1
                     FROM cn_payment_transactions
                    WHERE payrun_id = p_payrun_id
                      AND credited_salesrep_id = p_salesrep_id
                      AND quota_id = p_quota_id
                      AND NVL (waive_flag, 'N') = 'N'
                      AND incentive_type_code <> 'PMTPLN');

      CURSOR get_payment_worksheet (
         p_quota_id                          cn_payment_transactions.quota_id%TYPE
      )
      IS
         SELECT *
           FROM cn_payment_worksheets
          WHERE salesrep_id = p_salesrep_id
          AND quota_id = p_quota_id
          AND payrun_id = p_payrun_id;

      -- Bug 2795606 : use amount since get_cp will handle adj amt
      CURSOR get_mpa (
         p_quota_id                          cn_payment_transactions.quota_id%TYPE
      )
      IS
         SELECT NVL (SUM (NVL (amount, 0)), 0) mpa_amount
           FROM cn_payment_transactions
          WHERE credited_salesrep_id = p_salesrep_id
            AND quota_id = p_quota_id
            AND payrun_id = p_payrun_id
            AND incentive_type_code = 'MANUAL_PAY_ADJ' ;

      l_mpa                         NUMBER;

      CURSOR get_cp (
         p_quota_id                          cn_payment_transactions.quota_id%TYPE
      )
      IS
         SELECT NVL (SUM (NVL (payment_amount, 0) - NVL (amount, 0)), 0) cp_amount
           FROM cn_payment_transactions
          WHERE credited_salesrep_id = p_salesrep_id
            AND quota_id = p_quota_id
            AND payrun_id = p_payrun_id
            AND incentive_type_code NOT IN ('PMTPLN', 'PMTPLN_REC')
            AND hold_flag <> 'Y'
            ;

      l_cp                          NUMBER;

      -- (3) get payment holds
      CURSOR get_ph (
         p_quota_id                          cn_payment_transactions.quota_id%TYPE
      )
      IS
         SELECT NVL (SUM (NVL (payment_amount, 0)), 0) ph_amount
           FROM cn_payment_transactions
          WHERE credited_salesrep_id = p_salesrep_id
          AND quota_id = p_quota_id
          AND payrun_id = p_payrun_id
          AND hold_flag = 'Y'
          ;

      l_ph                          NUMBER;

      -- (4) get waive = nrec
      --bug 3114349, issue 3.  Added quota_id as a parameter.
      CURSOR get_wv (
         p_quota_id                          cn_payment_transactions.quota_id%TYPE
      )
      IS
         SELECT -NVL (SUM (NVL (payment_amount, 0)), 0) wv_amount
           FROM cn_payment_transactions
          WHERE credited_salesrep_id = p_salesrep_id
            -- AND quota_id is null
            AND payrun_id = p_payrun_id
            AND waive_flag = 'Y'
            AND quota_id = p_quota_id
            ;

      l_wv                          NUMBER;

      --fix for bug: 2848235
      CURSOR get_pmt_trans_amt (
         p_quota_id                          cn_payment_transactions.quota_id%TYPE
      )
      IS
         SELECT NVL (SUM (NVL (amount, 0)), 0) amount,
                NVL (SUM (NVL (payment_amount, 0)), 0) payment_amount
           FROM cn_payment_transactions
          WHERE credited_salesrep_id = p_salesrep_id
            AND quota_id = p_quota_id
            AND payrun_id = p_payrun_id
            AND (hold_flag = 'N' OR hold_flag IS NULL)
            AND incentive_type_code IN ('COMMISSION', 'BONUS')
            ;

      pmt_trans_rec_amount          get_pmt_trans_amt%ROWTYPE;

      --bug 3114349, issue 3.
      CURSOR get_waive_quota_id (
         p_payrun_id                         cn_payruns.payrun_id%TYPE,
         p_salesrep_id                       cn_payment_transactions.credited_salesrep_id%TYPE
      )
      IS
         SELECT   -NVL (SUM (NVL (payment_amount, 0)), 0) payment_amount,
                  quota_id
             FROM cn_payment_transactions
            WHERE payrun_id = p_payrun_id
              AND credited_salesrep_id = p_salesrep_id
              AND credit_type_id = -1000
              AND incentive_type_code = 'PMTPLN_REC'
              GROUP BY quota_id;

      CURSOR get_waive_flag (
         p_payrun_id                         cn_payruns.payrun_id%TYPE,
         p_salesrep_id                       cn_payment_transactions.credited_salesrep_id%TYPE
      )
      IS
         SELECT NVL (waive_flag, 'N') waive_flag,
                object_version_number ovn
           FROM cn_payment_transactions
          WHERE payrun_id = p_payrun_id
            AND credited_salesrep_id = p_salesrep_id
            AND credit_type_id = -1000
            AND incentive_type_code = 'PMTPLN_REC'
            AND ROWNUM < 2;

      l_waive_flag                  cn_payment_transactions.waive_flag%TYPE;
      l_waive_flag_db               cn_payment_transactions.waive_flag%TYPE;
      l_change_waive_flag           NUMBER;
      l_waive_amount                NUMBER;
      l_waive_amount_total          NUMBER;
      l_waive_factor                NUMBER;
   BEGIN
      --
      -- Standard Start of API savepoint
      --
      SAVEPOINT update_pmt_transactions;

      --
      -- Standard call to check for call compatibility.
      --
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
      -- Initialize message list if p_init_msg_list is set to TRUE.
      --
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --
      --  Initialize API return status to success
      --
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := 'UPDATED';

      --
      -- API body
      --
      -- check the payrun status and valid payrun
      IF cn_api.chk_payrun_status_paid (
             p_payrun_id => p_payrun_id,
             p_loading_status => x_loading_status,
             x_loading_status => x_loading_status) = fnd_api.g_true
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- check the salesrep id is valid and not on HOLD
      IF cn_api.chk_srp_hold_status (p_salesrep_id         => p_salesrep_id,
                                     --R12
                                     p_org_id              => p_org_id,
                                     p_loading_status      => x_loading_status,
                                     x_loading_status      => x_loading_status
                                    ) = fnd_api.g_true
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check worksheet status
      IF cn_api.chk_worksheet_status (p_payrun_id           => p_payrun_id,
                                      p_salesrep_id         => p_salesrep_id,
                                      --R12
                                      p_org_id              => p_org_id,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => x_loading_status
                                     ) = fnd_api.g_true
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- R12: obtain pay_by_mode from the payrun
      l_pbt_profile_value := cn_payment_security_pvt.get_pay_by_mode(p_payrun_id) ;


      -- Valid Flag Passed
      -- Check Waive_flag Flag must be Y/N
      IF p_waive_flag NOT IN ('Y', 'N') AND p_incentive_type_code = 'PMTPLN_REC'
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_WAIVE_FLAG');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_INVALID_WAIVE_FLAG';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check Recoverable Flag must be Y/N
      IF p_recoverable_flag NOT IN ('Y', 'N') AND p_incentive_type_code = 'MANUAL_PAY_ADJ'
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_RECOVERABLE_FLAG');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_INVALID_RECOVERABLE_FLAG';
         RAISE fnd_api.g_exc_error;
      END IF;

      --
      -- Get worksheet earnings for NULL quota id
      --
      FOR earn IN get_wksht_notnullqid
      LOOP
         l_wksht_not_null_earn := earn.earn_amount;
      END LOOP;

      --
      -- Get worksheet earnings for NOT NULL quota id
      --
      FOR earn IN get_wksht_nullqid
      LOOP
         l_wksht_null_earn := earn.earn_amount;
      END LOOP;

      l_delta_earn := l_wksht_null_earn - l_wksht_not_null_earn;

      --
      -- Get Payment Transaction
      --
      IF p_payment_transaction_id IS NOT NULL
      THEN
         OPEN get_pmt_trans;

         FETCH get_pmt_trans
          INTO pmt_trans_rec;

         CLOSE get_pmt_trans;

         IF pmt_trans_rec.ovn <> p_object_version_number
         THEN
            IF (fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error))
            THEN
               fnd_message.set_name ('CN', 'CN_RECORD_CHANGED');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      UPDATE cn_payment_transactions
         SET hold_flag = p_hold_flag,
             recoverable_flag = DECODE (p_incentive_type_code, 'MANUAL_PAY_ADJ', p_recoverable_flag, 'N'),
             -- bug 3146137
             amount = DECODE (p_incentive_type_code, 'MANUAL_PAY_ADJ', p_payment_amount, amount),
             payment_amount = p_payment_amount,
             waive_flag = DECODE (p_incentive_type_code, 'PMTPLN_REC', p_waive_flag, 'N'),
             -- bug 3080846
             last_update_date = SYSDATE,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id,
             object_version_number = nvl(object_version_number,1) + 1
       WHERE payment_transaction_id = p_payment_transaction_id;

      --This if statement is for waive recovery.
      IF p_payment_transaction_id IS NULL
      THEN

         --bug 3114349, issue 3.
         --Update detail waive records.
         l_waive_amount := 0;
         l_waive_amount_total := 0;

         --Find the value of waive flag in db.
         FOR i IN get_waive_flag (p_payrun_id, p_salesrep_id)
         LOOP
            l_waive_flag_db := i.waive_flag;
         END LOOP;

         l_change_waive_flag := 0;
         l_waive_flag := NVL (p_waive_flag, 'N');

         IF l_waive_flag = 'Y' AND l_waive_flag_db = 'N'
         THEN
            l_waive_factor := 1;
            l_change_waive_flag := 1;
         ELSIF l_waive_flag = 'N' AND l_waive_flag_db = 'Y'
         THEN
            l_waive_factor := -1;
            l_change_waive_flag := 1;
         END IF;

         IF l_change_waive_flag = 1
         THEN

            SELECT object_version_number
            INTO l_wksht_ovn
            FROM cn_payment_worksheets
            WHERE payrun_id = p_payrun_id
            AND salesrep_id = p_salesrep_id
            AND quota_id IS NULL;

            IF l_wksht_ovn <> p_object_version_number
            THEN
               IF (fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error))
               THEN
                  fnd_message.set_name ('CN', 'CN_RECORD_CHANGED');
                  fnd_msg_pub.ADD;
               END IF;
               RAISE fnd_api.g_exc_error;
            END IF;

            FOR waive_per_quota IN get_waive_quota_id (p_payrun_id, p_salesrep_id)
            LOOP
               --l_waive_factor = 1 is for waive_flag changes from N to Y.
               --l_waive_factor = -1 is for waive_flag changes from Y to N.
               l_waive_amount := waive_per_quota.payment_amount * l_waive_factor;

               UPDATE cn_payment_worksheets
                  SET pmt_amount_adj = NVL (pmt_amount_adj, 0) + l_waive_amount,
                      object_version_number = object_version_number + 1,
                      last_update_date = SYSDATE,
                      last_updated_by = fnd_global.user_id,
                      last_update_login = fnd_global.login_id
                WHERE payrun_id = p_payrun_id
                AND salesrep_id = p_salesrep_id
                AND quota_id = waive_per_quota.quota_id
                ;

               l_waive_amount_total := l_waive_amount_total + l_waive_amount;
            END LOOP;

            --Update summary waive record.
            UPDATE cn_payment_worksheets
               SET pmt_amount_adj = NVL (pmt_amount_adj, 0) + l_waive_amount_total,
                   object_version_number = nvl(object_version_number,0) + 1,
                   last_update_date = SYSDATE,
                   last_updated_by = fnd_global.user_id,
                   last_update_login = fnd_global.login_id
             WHERE payrun_id = p_payrun_id
             AND salesrep_id = p_salesrep_id
             AND quota_id IS NULL
             ;
         END IF;

         UPDATE cn_payment_transactions
            SET waive_flag = p_waive_flag,
                object_version_number = nvl(object_version_number,0) + 1,
                -- bug 3080846
                last_update_date = SYSDATE,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
          WHERE incentive_type_code = 'PMTPLN_REC'
          AND credited_salesrep_id = p_salesrep_id
          AND payrun_id = p_payrun_id
          ;

      END IF;

      --Bug Fix : 2848235
      IF (l_pbt_profile_value = 'N' AND pmt_trans_rec.hold_flag = 'Y' AND (p_hold_flag = 'N' OR p_hold_flag IS NULL))
      THEN
         OPEN get_pmt_trans_amt (pmt_trans_rec.quota_id);

         FETCH get_pmt_trans_amt
          INTO pmt_trans_rec_amount;

         CLOSE get_pmt_trans_amt;

         DELETE FROM cn_payment_transactions
               WHERE payment_transaction_id IN (
                        SELECT payment_transaction_id
                          FROM cn_payment_transactions
                         WHERE quota_id = pmt_trans_rec.quota_id
                           AND payrun_id = p_payrun_id
                           AND credited_salesrep_id = p_salesrep_id
                           AND (hold_flag = 'N' OR hold_flag IS NULL)
                           AND incentive_type_code IN ('COMMISSION', 'BONUS')
                           )
                 AND payment_transaction_id <> p_payment_transaction_id;

         UPDATE cn_payment_transactions
            SET amount = pmt_trans_rec_amount.amount,
                payment_amount = pmt_trans_rec_amount.payment_amount,
                object_version_number = object_version_number + 1,
                -- bug 3080846
                last_update_date = SYSDATE,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
          WHERE payment_transaction_id = p_payment_transaction_id
            AND payrun_id = p_payrun_id
            AND credited_salesrep_id = p_salesrep_id
            AND (hold_flag = 'N' OR hold_flag IS NULL) ;

      END IF;

      --end of Bug fix 2848235
      FOR worksheet IN get_payment_worksheet (pmt_trans_rec.quota_id)
      LOOP
         -- (1) get manual pay adjustments
         FOR mpa IN get_mpa (worksheet.quota_id)
         LOOP
            l_mpa := mpa.mpa_amount;
         END LOOP;

         -- (2) get control payments
         FOR cp IN get_cp (worksheet.quota_id)
         LOOP
            l_cp := cp.cp_amount;
         END LOOP;

         -- (3) get payment holds
         FOR ph IN get_ph (worksheet.quota_id)
         LOOP
            l_ph := ph.ph_amount;
         END LOOP;

         -- (4) get waive = nrec
         --bug 3114349, issue 3. Added quota_id.
         FOR wv IN get_wv (worksheet.quota_id)
         LOOP
            l_wv := wv.wv_amount;
         END LOOP;

         -- (5) get worksheet earnings
         FOR earn IN get_earnings (worksheet.quota_id)
         LOOP
            l_earn := earn.earn_amount;
         END LOOP;

         -- 12/25/02 RC bug 2710066
         UPDATE cn_payment_worksheets
            SET pmt_amount_adj = l_wv + l_cp + l_mpa,
                held_amount = l_ph,
                pmt_amount_calc = l_earn,
                object_version_number = object_version_number + 1,
                -- bug 3080846
                last_update_date = SYSDATE,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
          WHERE payment_worksheet_id = worksheet.payment_worksheet_id;
      END LOOP;

      -- updating the summary record with totals
      UPDATE cn_payment_worksheets
         SET pmt_amount_adj =
                (SELECT NVL (SUM (NVL (pmt_amount_adj, 0)), 0)
                   FROM cn_payment_worksheets
                  WHERE quota_id IS NOT NULL
                    AND salesrep_id = pmt_trans_rec.credited_salesrep_id
                    AND payrun_id = pmt_trans_rec.payrun_id
                    ),
             held_amount =
                (SELECT NVL (SUM (NVL (held_amount, 0)), 0)
                   FROM cn_payment_worksheets
                  WHERE quota_id IS NOT NULL
                    AND salesrep_id = pmt_trans_rec.credited_salesrep_id
                    AND payrun_id = pmt_trans_rec.payrun_id
                    ),
             pmt_amount_calc =
                (SELECT l_delta_earn + NVL (SUM (NVL (pmt_amount_calc, 0)), 0)
                   FROM cn_payment_worksheets
                  WHERE quota_id IS NOT NULL
                    AND salesrep_id = pmt_trans_rec.credited_salesrep_id
                    AND payrun_id = pmt_trans_rec.payrun_id
                    ),
             object_version_number = object_version_number + 1,
             -- bug 3080846
             last_update_date = SYSDATE,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id
       WHERE quota_id IS NULL
         AND salesrep_id = pmt_trans_rec.credited_salesrep_id
         AND payrun_id = pmt_trans_rec.payrun_id
         AND org_id = p_org_id;

      --Need to pass back the ovn.
      IF p_payment_transaction_id IS NOT NULL
      THEN
         SELECT object_version_number
           INTO p_object_version_number
           FROM cn_payment_transactions
          WHERE payment_transaction_id = p_payment_transaction_id;

      -- when waiving recovery on all trxns
      ELSIF p_payment_transaction_id IS NULL
      THEN
         SELECT object_version_number
           INTO p_object_version_number
           FROM cn_payment_worksheets
          WHERE payrun_id = p_payrun_id
            AND salesrep_id = p_salesrep_id
            AND quota_id IS NULL;
      END IF;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO update_pmt_transactions;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO update_pmt_transactions;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO update_pmt_transactions;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END update_pmt_transactions;


--=====================================================================
--Procedure Name:Create_Pmt_Transaction
--Description: used to Create the Manual Payment Transaction Record
--=====================================================================
   PROCEDURE create_pmt_transactions (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_commit                   IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      p_payrun_id                IN       NUMBER,
      p_salesrep_id              IN       NUMBER,
      p_incentive_type_code      IN       VARCHAR2,
      p_recoverable_flag         IN       VARCHAR2,
      p_payment_amount           IN       NUMBER,
      p_quota_id                 IN       NUMBER,
      p_org_id                   IN       cn_payment_transactions.org_id%TYPE,
      p_object_version_number    IN       cn_payment_transactions.object_version_number%TYPE,
      x_pmt_transaction_id       OUT NOCOPY NUMBER,
      x_status                   OUT NOCOPY VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Create_Payment_Transaction';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_exist                       VARCHAR2 (02);
      l_incentive_type              cn_lookups.meaning%TYPE;
      l_pay_period_id               NUMBER;
      l_posting_batch_id            NUMBER;
      l_rec_amount                  NUMBER := 0;
      l_nrec_amount                 NUMBER := 0;
      l_pay_date                    DATE;
      l_pay_element_type_id         cn_payment_transactions.pay_element_type_id%TYPE;
      l_rowid                       VARCHAR2 (100);
      l_quota_id                    NUMBER;
      l_pmt_trans_rec               cn_pmt_trans_pkg.pmt_trans_rec_type;
      l_batch_rec                   cn_prepostbatches.posting_batch_rec_type;
      --Bug 3866089 (the same as 11.5.8 bug 3841926, 11.5.10 3866116) by Julia Huang on 9/1/04.
      l_payables_flag               cn_repositories.payables_flag%TYPE;
      l_pmt_tran_id                 cn_payment_transactions.payment_transaction_id%TYPE;

      CURSOR get_apps
      IS
         SELECT payables_flag
           FROM cn_repositories
          --R12
         WHERE  org_id = p_org_id;

      -- Payrun Curs
      CURSOR get_payrun
      IS
         SELECT pay_period_id,
                pay_date
           FROM cn_payruns
          WHERE payrun_id = p_payrun_id
          AND status = 'UNPAID';

   BEGIN
      --
      -- Standard Start of API savepoint
      --
      SAVEPOINT create_pmt_transactions;

      --
      -- Standard call to check for call compatibility.
      --
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
      -- Initialize message list if p_init_msg_list is set to TRUE.
      --
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --
      --  Initialize API return status to success
      --
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := 'CN_INSERTED';

      -- Mandatory parameters check for payrun_id, salesrep_id
      IF ((cn_api.chk_miss_null_num_para (p_num_para            => p_payrun_id,
                                          p_obj_name            => cn_api.get_lkup_meaning ('PAY_RUN_NAME', 'PAY_RUN_VALIDATION_TYPE'),
                                          p_loading_status      => x_loading_status,
                                          x_loading_status      => x_loading_status
                                         )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF ((cn_api.chk_miss_null_num_para (p_num_para            => p_salesrep_id,
                                          p_obj_name            => cn_api.get_lkup_meaning ('SALES_PERSON', 'PAY_RUN_VALIDATION_TYPE'),
                                          p_loading_status      => x_loading_status,
                                          x_loading_status      => x_loading_status
                                         )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- check Incentive Type Code
      IF ((cn_api.chk_null_char_para (p_char_para           => p_incentive_type_code,
                                      p_obj_name            => cn_api.get_lkup_meaning ('INCENTIVE_TYPE', 'PAY_RUN_VALIDATION_TYPE'),
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => x_loading_status
                                     )
          ) = fnd_api.g_true
         )
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check Recoverable Flag must be Y/N
      IF p_recoverable_flag NOT IN ('Y', 'N')
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_RECOVERABLE_FLAG');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_INVALID_RECOVERABLE_FLAG';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check/Valid Incentive Type
      IF (p_incentive_type_code NOT IN ('MANUAL_PAY_ADJ'))
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_INVALID_INCENTIVE_TYPE');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_INVALID_INCENTIVE_TYPE';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- check the payrun status and valid payrun
      IF cn_api.chk_payrun_status_paid (
              p_payrun_id      => p_payrun_id,
              p_loading_status => x_loading_status,
              x_loading_status => x_loading_status) =  fnd_api.g_true
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- check the salesrep id is valid and not on HOLD
      IF cn_api.chk_srp_hold_status (p_salesrep_id         => p_salesrep_id,
                                     --R12
                                     p_org_id              => p_org_id,
                                     p_loading_status      => x_loading_status,
                                     x_loading_status      => x_loading_status
                                    ) = fnd_api.g_true
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check Worksheet Status
      IF cn_api.chk_worksheet_status (p_payrun_id           => p_payrun_id,
                                      p_salesrep_id         => p_salesrep_id,
                                      --R12
                                      p_org_id              => p_org_id,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => x_loading_status
                                     ) = fnd_api.g_true
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check Quota ID
      IF p_quota_id IS NULL
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_QUOTA_NOT_EXISTS');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_QUOTA_NOT_EXISTS';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Check Valid Quota ID
      BEGIN
         SELECT quota_id
           INTO l_quota_id
           FROM cn_quotas_v
          WHERE quota_id = p_quota_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_QUOTA_NOT_EXISTS');
               fnd_msg_pub.ADD;
            END IF;

            x_loading_status := 'CN_QUOTA_NOT_EXISTS';
            RAISE fnd_api.g_exc_error;
      END;

      -- get pay period id and Pay Date
      OPEN get_payrun;

      FETCH get_payrun
       INTO l_pay_period_id,
            l_pay_date;

      CLOSE get_payrun;

      -- Bug 2880233: manual adj has quota_id, use assigned quota_id
      l_pay_element_type_id := cn_api.get_pay_element_id (p_quota_id, p_salesrep_id, p_org_id, l_pay_date);
      -- Create the Record in cn_posting_batches
      cn_prepostbatches.get_uid (l_posting_batch_id);
      l_batch_rec.posting_batch_id := l_posting_batch_id;
      l_batch_rec.NAME := 'MANUAL_PAY_ADJ batch number:' || p_payrun_id || ':' || p_salesrep_id || ':' || l_posting_batch_id;
      l_batch_rec.created_by := fnd_global.user_id;
      l_batch_rec.creation_date := SYSDATE;
      l_batch_rec.last_updated_by := fnd_global.user_id;
      l_batch_rec.last_update_date := SYSDATE;
      l_batch_rec.last_update_login := fnd_global.login_id;
      -- call table handler
      cn_prepostbatches.begin_record (x_operation              => 'INSERT',
                                      x_rowid                  => l_rowid,
                                      x_posting_batch_rec      => l_batch_rec,
                                      x_program_type           => NULL,
                                      p_org_id                 => p_org_id
                                     );
      l_pmt_trans_rec.posting_batch_id := l_posting_batch_id;
      l_pmt_trans_rec.incentive_type_code := 'MANUAL_PAY_ADJ';
      l_pmt_trans_rec.credit_type_id := g_credit_type_id;
      l_pmt_trans_rec.payrun_id := p_payrun_id;
      l_pmt_trans_rec.credited_salesrep_id := p_salesrep_id;
      l_pmt_trans_rec.payee_salesrep_id := p_salesrep_id;
      l_pmt_trans_rec.quota_id := p_quota_id;
      l_pmt_trans_rec.pay_period_id := l_pay_period_id;
      l_pmt_trans_rec.hold_flag := 'N';
      l_pmt_trans_rec.waive_flag := 'N';
      l_pmt_trans_rec.paid_flag := 'N';
      l_pmt_trans_rec.recoverable_flag := NVL (p_recoverable_flag, 'N');
      l_pmt_trans_rec.pay_element_type_id := l_pay_element_type_id;
      l_pmt_trans_rec.amount := p_payment_amount;
      l_pmt_trans_rec.payment_amount := p_payment_amount;
      --R12
      l_pmt_trans_rec.org_id := p_org_id;
      l_pmt_trans_rec.object_version_number := 1;
      -- Call Table hander to Insert Payment Transactions
      cn_pmt_trans_pkg.INSERT_RECORD (p_tran_rec => l_pmt_trans_rec);
      --  Bug 3866089 (the same as 11.5.8 bug 3841926, 11.5.10 3866116) by jjhuang on 11/1/04
      l_pmt_tran_id := cn_pmt_trans_pkg.get_pmt_tran_id;
      x_pmt_transaction_id := l_pmt_tran_id ;

      -- Update the payment Worksheets based on the recoverable flag
      IF NVL (p_recoverable_flag, 'N') = 'N'
      THEN
         l_nrec_amount := NVL (p_payment_amount, 0);
      ELSE
         l_rec_amount := NVL (p_payment_amount, 0);
      END IF;

      -- Update the Worksheet
      UPDATE cn_payment_worksheets
         SET pmt_amount_adj = NVL (pmt_amount_adj, 0) + NVL (l_rec_amount, 0) + NVL (l_nrec_amount, 0),
             last_updated_by = fnd_global.user_id,
             last_update_date = SYSDATE,
             last_update_login = fnd_global.login_id,
             object_version_number = NVL(object_version_number+1,1)
       WHERE salesrep_id = p_salesrep_id
         AND payrun_id = p_payrun_id
         AND quota_id = p_quota_id
         ;

      IF SQL%NOTFOUND
      THEN
         cn_payment_worksheets_pkg.INSERT_RECORD (x_payrun_id                  => p_payrun_id,
                                                  x_salesrep_id                => p_salesrep_id,
                                                  x_quota_id                   => p_quota_id,
                                                  x_credit_type_id             => g_credit_type_id,
                                                  x_calc_pmt_amount            => 0,
                                                  x_adj_pmt_amount_rec         => 0,
                                                  x_adj_pmt_amount_nrec        => 0,
                                                  x_adj_pmt_amount             => l_rec_amount + l_nrec_amount,
                                                  x_pmt_amount_recovery        => 0,
                                                  x_worksheet_status           => 'UNPAID',
                                                  x_created_by                 => fnd_global.user_id,
                                                  x_creation_date              => SYSDATE,
                                                  p_org_id                     => p_org_id,
                                                  p_object_version_number      => 1
                                                 );
      END IF;

      -- Update the Summary Record.
      UPDATE cn_payment_worksheets
         SET pmt_amount_adj = NVL (pmt_amount_adj, 0) + NVL (l_rec_amount, 0) + NVL (l_nrec_amount, 0),
             last_updated_by = fnd_global.user_id,
             last_update_date = SYSDATE,
             last_update_login = fnd_global.login_id,
             object_version_number = NVL(object_version_number+1,1)
       WHERE salesrep_id = p_salesrep_id
       AND payrun_id = p_payrun_id
       AND quota_id IS NULL
       ;

      --Bug 3866089 (the same as 11.5.8 bug 3841926, 11.5.10 3866116) by Julia Huang on 9/1/04.
      --For AP integration population of account
      OPEN get_apps;

      FETCH get_apps
       INTO l_payables_flag;

      CLOSE get_apps;

      IF l_payables_flag = 'Y'
      THEN
         -- Populate ccid's in payment worksheets
         -- Bug 3866089 (the same as 11.5.8 bug 3841926, 11.5.10 3866116) by jjhuang on 11/1/04
         IF (cn_payrun_pvt.populate_ccids
                               (p_payrun_id           => p_payrun_id,
                                p_salesrep_id         => p_salesrep_id,
                                p_pmt_tran_id         => l_pmt_tran_id,
                                p_loading_status      => x_loading_status,
                                x_loading_status      => x_loading_status
                               )
            ) = fnd_api.g_true
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO create_pmt_transactions;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO create_pmt_transactions;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO create_pmt_transactions;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END create_pmt_transactions;

--=====================================================================
--Procedure Name:Delete_Pmt_Transactions
--Description: Used to delete the Manual Payment Transaction Record
--=====================================================================
   PROCEDURE delete_pmt_transactions (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_commit                   IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_payment_transaction_id   IN       NUMBER,
      p_validation_only          IN       VARCHAR2,
      x_status                   OUT NOCOPY VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2,
      p_ovn                      IN       NUMBER
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Delete_Pmt_Transactions';
      l_api_version        CONSTANT NUMBER := 1.0;

      -- cursor to get the payment transaction to
      -- update the payment worksheets
      CURSOR get_pmt_trans
      IS
         SELECT payrun_id,
                credited_salesrep_id,
                payment_amount,
                incentive_type_code,
                recoverable_flag,
                posting_batch_id,
                quota_id,
                org_id,
                object_version_number ovn
           FROM cn_payment_transactions
          WHERE payment_transaction_id = p_payment_transaction_id;

      trans_rec                     get_pmt_trans%ROWTYPE;
      l_adj_rec                     NUMBER := 0;
      l_adj_nrec                    NUMBER := 0;
      --R12 for OA.
      l_validation_only             VARCHAR2 (1);
   BEGIN
      --
      -- Standard Start of API savepoint
      --
      SAVEPOINT delete_pmt_transactions;

      --
      -- Standard call to check for call compatibility.
      --
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
      -- Initialize message list if p_init_msg_list is set to TRUE.
      --
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --
      --  Initialize API return status to success
      --
      x_return_status := fnd_api.g_ret_sts_success;
      x_loading_status := 'CN_DELETED';
      --R12 for OA.  When p_validation_only = 'Y', only do validation for delete from OA.
      --Otherwise, do delete_pmt_transactions.
      l_validation_only := NVL (p_validation_only, 'N');

      --
      -- get the Payment Transactions
      --
      OPEN get_pmt_trans;

      FETCH get_pmt_trans
       INTO trans_rec;

      CLOSE get_pmt_trans;

      -- check deleting Allowed.
      -- Delete allowed only on Manual Transactions
      IF trans_rec.incentive_type_code <> 'MANUAL_PAY_ADJ'
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PMT_TRAN_DEL_NOT_ALLOWED');
            fnd_msg_pub.ADD;
         END IF;

         x_loading_status := 'CN_PMT_TRAN_DEL_NOT_ALLOWED';
         RAISE fnd_api.g_exc_error;
      END IF;

      -- check the payrun status
      -- check the payrun ID is valid
      -- if payrun status <> UNPAID you cannot delete Transactions
      IF cn_api.chk_payrun_status_paid (p_payrun_id           => trans_rec.payrun_id, p_loading_status => x_loading_status,
                                        x_loading_status      => x_loading_status) = fnd_api.g_true
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF cn_api.chk_worksheet_status (p_payrun_id           => trans_rec.payrun_id,
                                      p_salesrep_id         => trans_rec.credited_salesrep_id,
                                      p_org_id              => trans_rec.org_id,
                                      p_loading_status      => x_loading_status,
                                      x_loading_status      => x_loading_status
                                     ) = fnd_api.g_true
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      --R12
      IF l_validation_only = 'Y'
      THEN
         RETURN;
      END IF;

      -- Delete the Trasaction batches
      DELETE FROM cn_posting_batches cnpb
            WHERE cnpb.posting_batch_id = trans_rec.posting_batch_id;

      -- Delete the payment Transactions
      cn_pmt_trans_pkg.DELETE_RECORD (p_payment_transaction_id);

      -- assign to a variable to get the payment transaction amounts
      IF NVL (trans_rec.recoverable_flag, 'N') = 'N'
      THEN
         l_adj_rec := NVL (trans_rec.payment_amount, 0);
         l_adj_nrec := 0;
      ELSE
         l_adj_nrec := NVL (trans_rec.payment_amount, 0);
         l_adj_rec := 0;
      END IF;

      -- Update the Payment Worksheets
      UPDATE cn_payment_worksheets
         SET pmt_amount_adj = NVL (pmt_amount_adj, 0) - NVL (l_adj_rec, 0) - NVL (l_adj_nrec, 0),
             object_version_number = object_version_number + 1,
             last_updated_by = fnd_global.user_id,
             last_update_date = SYSDATE,
             -- bug 3080846
             last_update_login = fnd_global.login_id
       WHERE salesrep_id = trans_rec.credited_salesrep_id
         AND payrun_id = trans_rec.payrun_id
         AND (quota_id = trans_rec.quota_id OR quota_id IS NULL)
         ;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO delete_pmt_transactions;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO delete_pmt_transactions;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO delete_pmt_transactions;
         x_loading_status := 'UNEXPECTED_ERR';
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END delete_pmt_transactions;

--=====================================================================
--Procedure Name:release_wksht_hold
--Description: Used to release the payment holds at worksheet level.
--11.5.10
--=====================================================================
   PROCEDURE release_wksht_hold (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2,
      p_commit                   IN       VARCHAR2,
      p_validation_level         IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_payment_worksheet_id     IN       NUMBER
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'release_wksht_hold';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_status                      VARCHAR2 (30) := 'RELEASE_WKSHT_HOLD';
      l_loading_status              VARCHAR2 (100);

      -- cursor to get the hold payment transactions
      CURSOR get_hold_pmt_trans (
         p_payment_worksheet_id              cn_payment_worksheets.payment_worksheet_id%TYPE
      )
      IS
         SELECT cpt.payment_transaction_id,
                cpt.hold_flag,
                cpt.recoverable_flag,
                cpt.payment_amount,
                cpt.waive_flag,
                cpt.incentive_type_code,
                cp.payrun_id,
                cpw.salesrep_id,
                --R12
                cpw.org_id,
                cpt.object_version_number ovn
           FROM cn_payruns cp,
                cn_payment_worksheets cpw,
                cn_payment_transactions cpt
          WHERE cpw.payment_worksheet_id = p_payment_worksheet_id
            AND cp.payrun_id = cpw.payrun_id
            AND cp.payrun_id = cpt.payrun_id
            AND cpw.salesrep_id = cpt.credited_salesrep_id
            AND cpt.hold_flag = 'Y'
            --R12
            AND cpw.org_id = cp.org_id
            AND cpw.org_id = cpt.org_id;
   BEGIN
      --
      -- Standard Start of API savepoint
      --
      SAVEPOINT release_wksht_hold;

      --
      -- Standard call to check for call compatibility.
      --
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
      -- Initialize message list if p_init_msg_list is set to TRUE.
      --
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --
      --  Initialize API return status to success
      --
      x_return_status := fnd_api.g_ret_sts_success;

      FOR i IN get_hold_pmt_trans (p_payment_worksheet_id)
      LOOP
         update_pmt_transactions (p_api_version                 => p_api_version,
                                  p_init_msg_list               => p_init_msg_list,
                                  p_commit                      => p_commit,
                                  p_validation_level            => p_validation_level,
                                  x_return_status               => x_return_status,
                                  x_msg_count                   => x_msg_count,
                                  x_msg_data                    => x_msg_data,
                                  p_payment_transaction_id      => i.payment_transaction_id,
                                  p_hold_flag                   => 'N',
                                  p_recoverable_flag            => i.recoverable_flag,
                                  p_payment_amount              => i.payment_amount,
                                  p_waive_flag                  => i.waive_flag,
                                  p_incentive_type_code         => i.incentive_type_code,
                                  p_payrun_id                   => i.payrun_id,
                                  p_salesrep_id                 => i.salesrep_id,
                                  x_status                      => l_status,                                              --Not used by caller anymore
                                  x_loading_status              => l_loading_status,                                      --Not used by caller anymore
                                  --R12
                                  p_org_id                      => i.org_id,
                                  p_object_version_number       => i.ovn
                                 );
      END LOOP;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO release_wksht_hold;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO release_wksht_hold;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO release_wksht_hold;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END release_wksht_hold;

--=====================================================================
--Procedure Name:hold_multiple_trans_conc
--Description: Exceutable for the hold all the transactions.
--=====================================================================
PROCEDURE hold_multiple_trans_conc (
      errbuf                     OUT NOCOPY VARCHAR2,
      retcode                    OUT NOCOPY NUMBER,
      p_payrun_id                IN       NUMBER,
      p_salesrep_id              IN       NUMBER,
      p_quota_id                 IN       NUMBER,
      p_revenue_class_id         IN       NUMBER,
      p_invoice_number           IN       VARCHAR2,
      p_order_number             IN       NUMBER,
      p_customer                 IN       VARCHAR2,
      p_hold_flag                IN       VARCHAR2,
      p_action                   IN       VARCHAR2
   )
   IS
      l_return_status               VARCHAR2 (1000);
      l_msg_data                    VARCHAR2 (2000);
      l_msg_count                   NUMBER;
      l_loading_status              VARCHAR2 (1000);
      l_status                      VARCHAR2 (2000);
      l_worksheet_id                NUMBER;
      l_ovn                         NUMBER;
      l_msg_name                   VARCHAR2(200);
      l_note_msg                 VARCHAR2(240);
      l_note_id                  NUMBER;
      l_transaction_id              NUMBER;
      l_errNum                      NUMBER;
      l_errText                     VARCHAR2(200);
      l_processed                   VARCHAR2(20);
      l_flag                        varchar2(1);


      l_pmt_process_rec            cn_pmt_trans_pvt.pmt_process_rec;

    CURSOR get_paysheet_details IS
    SELECT
        payment_worksheet_id,object_version_number, name
    FROM
        cn_payment_worksheets wk, cn_salesreps srp
    WHERE
        quota_id is null
    AND wk.payrun_id   = p_payrun_id
    AND wk.salesrep_id = p_salesrep_id
    AND wk.salesrep_id = srp.salesrep_id ;

    l_new_status cn_payment_worksheets.worksheet_status%type ;
    l_srp_name   cn_salesreps.name%type ;

BEGIN
    SAVEPOINT hold_multiple_trans_conc;
    retcode := 0;
    -- Initial message list
    fnd_msg_pub.initialize;

    OPEN get_paysheet_details;
    FETCH get_paysheet_details
    INTO l_worksheet_id,l_ovn,l_srp_name;

    CLOSE get_paysheet_details;

    l_pmt_process_rec.payrun_id     := p_payrun_id;
    l_pmt_process_rec.salesrep_id   := p_salesrep_id;
    l_pmt_process_rec.p_action      :=  p_action;
    l_pmt_process_rec.is_processing := 'YES' ;
    l_pmt_process_rec.hold_flag     := p_hold_flag ;

    BEGIN
          IF p_action = 'HOLD_ALL' THEN
             l_flag := 'Y' ;
          ELSE
             l_flag := 'N' ;
          END IF ;
          --debug(2, 'begin validate_hold_processing') ;

          validate_hold_processing (
                p_api_version              =>       1.0,
                p_init_msg_list            =>       fnd_api.g_true,
                p_commit                   =>       fnd_api.g_false,
                p_validation_level         =>       fnd_api.g_valid_level_full,
                p_rec                      =>       l_pmt_process_rec,
                x_return_status            =>       l_return_status,
                x_msg_count                =>       l_msg_count,
                x_msg_data                 =>       l_msg_data );

          IF l_return_status <> fnd_api.g_ret_sts_success THEN
              --debug(2.1, 'error @ validate_hold_processing') ;
              RAISE fnd_api.g_exc_error;
          END IF;

          FOR transactions_details_rec IN get_transactions_details(p_payrun_id,
                                                                   p_salesrep_id,
                                                                   p_quota_id,
                                                                   p_revenue_class_id,
                                                                   p_invoice_number,
                                                                   p_order_number,
                                                                   p_customer,
                                                                   p_hold_flag,
                                                                   p_action)
          LOOP
              update_pmt_transactions(
                  p_api_version              =>       1.0,
                  p_init_msg_list            =>       fnd_api.g_true,
                  p_commit                   =>       fnd_api.g_false,--changed to false
                  p_validation_level         =>       fnd_api.g_valid_level_full,
                  x_return_status            =>       l_return_status,
                  x_msg_count                =>       l_msg_count,
                  x_msg_data                 =>       l_msg_data,
                  p_payment_transaction_id   =>       transactions_details_rec.payment_transaction_id,
                  p_hold_flag                =>       l_flag,
                  p_recoverable_flag         =>       transactions_details_rec.recoverable_flag,
                  p_payment_amount           =>       transactions_details_rec.payment_amount,
                  p_waive_flag               =>       transactions_details_rec.waive_flag,
                  p_incentive_type_code      =>       transactions_details_rec.incentive_type_code,
                  p_payrun_id                =>       p_payrun_id,
                  p_salesrep_id              =>       p_salesrep_id,
                  x_status                   =>       l_status,
                  x_loading_status           =>       l_loading_status,
                  p_org_id                   =>       transactions_details_rec.org_id,
                  p_object_version_number    =>       transactions_details_rec.object_version_number);

             IF l_return_status <> fnd_api.g_ret_sts_success THEN
                l_errText := fnd_msg_pub.get (p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
                IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                      fnd_message.set_name ('CN', 'CN_PROCESS_UPD_TRANS_NOTE');
                      fnd_message.set_token ('TRX_ID', transactions_details_rec.payment_transaction_id );
                      fnd_message.set_token('MESSAGE_TEXT', l_errText);
                      fnd_msg_pub.ADD;
                END IF;
                RAISE fnd_api.g_exc_error;
             END IF;
          END LOOP;

          --debug(5, 'end end for update_pmt_transactions') ;

          l_new_status := 'UNPAID' ;
          fnd_message.set_name('CN', 'CN_PROCESS_TRANS_NOTE');
          l_note_msg := fnd_message.get;

    EXCEPTION
    WHEN fnd_api.g_exc_error  THEN
         ROLLBACK TO hold_multiple_trans_conc;
         retcode := 2;
         errbuf := fnd_msg_pub.get (p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
         l_note_msg := fnd_message.get;
         l_new_status := 'FAILED' ;

    WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO hold_multiple_trans_conc;
         retcode := 2;
         errbuf := fnd_msg_pub.get (p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
         l_note_msg := fnd_message.get;
         l_new_status := 'FAILED' ;
    END ;

    cn_payment_worksheets_pkg.update_status(p_salesrep_id,p_payrun_id,l_new_status) ;

    BEGIN
        jtf_notes_pub.create_note (
            p_api_version         => 1.0,
            x_return_status       => l_return_status,
            x_msg_count           => l_msg_count,
            x_msg_data            => l_msg_data,
            p_source_object_id    => l_worksheet_id,
            p_source_object_code  => 'CN_PAYMENT_WORKSHEETS',
            p_notes               => l_note_msg,
            p_notes_detail        => l_note_msg,
            p_note_type           => 'CN_SYSGEN', -- for system generated
            x_jtf_note_id         => l_note_id   -- returned
            );
    EXCEPTION
    WHEN OTHERS THEN
         retcode := 2;
         errbuf := fnd_msg_pub.get (p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
    END ;

    COMMIT ;
EXCEPTION
WHEN OTHERS THEN
    ROLLBACK;
    l_errNum  := SQLCODE;
    l_errText := SUBSTR(SQLERRM,1,200);
    fnd_message.set_name ('CN', 'CN_PROCESS_WKSHT_FAIL_NOTE');
    fnd_message.set_token('SRP_NAME', l_srp_name );
    fnd_message.set_token('MESSAGE_TEXT', l_errText);
    fnd_msg_pub.ADD;

    cn_payment_worksheets_pkg.update_status(p_salesrep_id,p_payrun_id, 'FAILED') ;

    retcode := 2;
    errbuf := fnd_msg_pub.get (p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
    COMMIT ;
END  hold_multiple_trans_conc;


--============================================================================
-- Start of Comments
--
-- API name  : process_pmt_transactions
-- Type     : Private.
-- Pre-reqs : None.
-- Usage :    submits the hold all concurrent program.
-- Parameters  :
-- IN    :  p_api_version       IN NUMBER      Require
--          p_init_msg_list     IN VARCHAR2    Optional
--             Default = FND_API.G_FALSE
--          p_commit        IN VARCHAR2    Optional
--                Default = FND_API.G_FALSE
--          p_validation_level  IN NUMBER      Optional
--                Default = FND_API.G_VALID_LEVEL_FULL
-- IN    :  p_payrun_id          IN       NUMBER
-- IN    :  p_salesrep_id        IN          VARCHAR2(01)
-- IN    :  p_quota_id           IN          NUMBER
-- IN    :  p_revenue_class_id   IN          Varchar2(01)
-- IN    :  p_invoice_number     IN       Varchar2(01)
-- IN    :  p_customer           IN         Varchar2
-- IN    :  p_hold_flag          IN         Varchar2
-- IN    :  p_action             IN         Varchar2
--          Detailed Error Message
-- Version  : Current version 1.0
--      Initial version    1.0
--
-- End of comments
--============================================================================
    PROCEDURE process_pmt_transactions (
          p_api_version              IN       NUMBER,
          p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
          p_commit                   IN       VARCHAR2 := fnd_api.g_false,
          p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
          p_rec                      IN OUT NOCOPY pmt_process_rec,
          x_return_status            OUT NOCOPY VARCHAR2,
          x_msg_count                OUT NOCOPY NUMBER,
          x_msg_data                 OUT NOCOPY VARCHAR2
    )
     IS
          l_api_name           CONSTANT VARCHAR2 (30) := 'process_pmt_transactions';
          l_api_version        CONSTANT NUMBER := 1.0;
          l_request_id         NUMBER := NULL ;
          l_return_status      VARCHAR2 (1000);
          l_msg_data           VARCHAR2 (2000);
          l_msg_count          NUMBER;
          l_status             VARCHAR2(100)  ;
     BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT process_pmt_transactions;

        -- Standard call to check for call compatibility.
        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
           RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
           fnd_msg_pub.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := fnd_api.g_ret_sts_success;

        validate_hold_processing (
           p_api_version        => p_api_version ,
           p_init_msg_list      => p_init_msg_list,
           p_commit             => p_commit,
           p_validation_level   => p_validation_level,
           p_rec                => p_rec,
           x_return_status      => l_return_status,
           x_msg_count          => l_msg_count,
           x_msg_data           => l_msg_data
        ) ;

        IF l_return_status <> fnd_api.g_ret_sts_success
        THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF p_rec.p_action IN (CN_PMT_TRANS_PVT.G_HOLD_ALL, CN_PMT_TRANS_PVT.G_RELEASE_ALL) THEN

              -- init the org_id
              fnd_request.set_org_id(p_rec.org_id);

              --- create the request
              l_request_id := fnd_request.submit_request(
                   application    => 'CN'
                  ,program        => 'PROCESS_PMT_TRANSACTIONS'
                  ,description    => 'Process Payment Transactions'
                  ,start_time     => NULL
                  ,sub_request    => NULL
                  ,argument1      => p_rec.payrun_id
                  ,argument2      => p_rec.salesrep_id
                  ,argument3      => p_rec.quota_id
                  ,argument4      => p_rec.revenue_class_id
                  ,argument5      => p_rec.invoice_number
                  ,argument6      => p_rec.order_number
                  ,argument7      => p_rec.customer
                  ,argument8      => p_rec.hold_flag
                  ,argument9      => p_rec.p_action
                  );

              IF l_request_id = 0 THEN
                 cn_message_pkg.debug('Main : unable to submit batch conc program ');
                 cn_message_pkg.debug('Main : ' || fnd_message.get);

                 IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'cn.plsql.cn_pmt_trans_pvt.pmt_process.exception','Failed to submit request for BATCH_PROCESSOR.');
                 END IF;
                 RAISE fnd_api.g_exc_error;
              END IF ;
              p_rec.request_id := l_request_id ;

              UPDATE cn_payment_worksheets
              SET request_id = p_rec.request_id,
                  last_update_date = SYSDATE,
                  last_updated_by = fnd_global.user_id,
                  last_update_login = fnd_global.login_id
              WHERE payrun_id = p_rec.payrun_id
              AND salesrep_id = p_rec.salesrep_id
              AND quota_id IS NULL ;

        ELSIF p_rec.p_action = CN_PMT_TRANS_PVT.G_RESET_TO_UNPAID THEN
              NULL ;
        ELSE
              IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
              THEN
                fnd_message.set_name ('CN', 'CN_WKSHT_ACTION_NOT_EXIST');
                fnd_msg_pub.ADD;
              END IF;
              RAISE fnd_api.g_exc_error;
        END IF;

        cn_payment_worksheet_pvt.update_worksheet (
           p_api_version         =>   p_api_version,
           p_init_msg_list       =>   p_init_msg_list,
           p_commit              =>   p_commit,
           p_validation_level    =>   p_validation_level,
           x_return_status       =>   l_return_status,
           x_msg_count           =>   l_msg_count,
           x_msg_data            =>   l_msg_data,
           p_worksheet_id        =>   p_rec.worksheet_id,
           p_operation           =>   p_rec.p_action,
           x_status              =>   l_status,
           x_loading_status      =>   l_status,
           x_ovn                 =>   p_rec.object_version_number
        ) ;

        IF l_return_status <> fnd_api.g_ret_sts_success
        THEN
          RAISE fnd_api.g_exc_error;
        END IF;

     EXCEPTION
          WHEN fnd_api.g_exc_error
          THEN
             ROLLBACK TO process_pmt_transactions;
             x_return_status := fnd_api.g_ret_sts_error;
             fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
          WHEN fnd_api.g_exc_unexpected_error
          THEN
             ROLLBACK TO process_pmt_transactions;
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
          WHEN OTHERS
          THEN
             ROLLBACK TO process_pmt_transactions;
             x_return_status := fnd_api.g_ret_sts_unexp_error;

             IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
             THEN
                fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
             END IF;
             fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
    END process_pmt_transactions;


END cn_pmt_trans_pvt;

/
