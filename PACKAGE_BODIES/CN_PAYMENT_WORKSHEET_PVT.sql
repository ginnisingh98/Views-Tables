--------------------------------------------------------
--  DDL for Package Body CN_PAYMENT_WORKSHEET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PAYMENT_WORKSHEET_PVT" AS
    -- $Header: cnvwkshb.pls 120.26.12010000.3 2009/09/30 03:20:05 rnagired ship $
    g_api_version CONSTANT NUMBER := 1.0;
    g_pkg_name    CONSTANT VARCHAR2(30) := 'CN_Payment_Worksheet_PVT';
    --G_last_update_date      DATE    := sysdate;
   -- g_last_updated_by NUMBER := fnd_global.user_id;
    --G_creation_date         DATE    := sysdate;
    --g_created_by         NUMBER := fnd_global.user_id;
    --g_last_update_login NUMBER := fnd_global.login_id;
    g_credit_type_id CONSTANT NUMBER := -1000;


    PROCEDURE update_ptd_details (
       	p_salesrep_id IN NUMBER,
       	p_payrun_id   IN NUMBER
    )
    IS
        l_comm_ptd    number ;
        l_bonus_ptd   number ;
        l_bal         NUMBER ;
        l_bb_earn     NUMBER ;
        l_bb_pmt_recover NUMBER ;
        l_bb4_begin  NUMBER ;
    BEGIN

         BEGIN

              -- get data from summary record where quota_id is null
              SELECT SUM(nvl(balance2_bbd, 0) - nvl(balance2_bbc, 0)) prior_earning,
                     - (SUM(nvl(balance4_bbd, 0) - nvl(balance4_bbc, 0))) - (SUM(nvl(balance4_dtd, 0) - nvl(balance4_ctd, 0))),
                     SUM(nvl(balance4_bbc, 0) - nvl(balance4_bbd, 0)) begin_b4
                INTO l_bb_earn,
                     l_bb_pmt_recover,
                     l_bb4_begin
                FROM cn_srp_periods_all s,
                     cn_payruns_all pr
               WHERE s.salesrep_id = p_salesrep_id
                 AND s.org_id = pr.org_id
                 AND pr.payrun_id = p_payrun_id
                 AND s.quota_id IS NULL
                 AND pr.pay_period_id = s.period_id
                 AND s.credit_type_id = g_credit_type_id ;

         EXCEPTION
              WHEN no_data_found THEN
                  l_bb_earn    := 0;
                  l_bb_pmt_recover := 0;
         END;

         l_bal := nvl(l_bb_earn,0) + nvl(l_bb4_begin,0) ;

         BEGIN

            SELECT SUM(CASE
                           WHEN quota.quota_group_code = 'BONUS' THEN
                            nvl(cspq.commission_payed_ptd, 0)
                           ELSE
                            0
                       END) bonus_ptd,
                   SUM(CASE
                           WHEN quota.quota_group_code = 'QUOTA' THEN
                            nvl(cspq.commission_payed_ptd, 0)
                           ELSE
                            0
                       END) comm_ptd
              INTO l_bonus_ptd,
                   l_comm_ptd
              FROM cn_srp_period_quotas_all cspq,
                   cn_quotas_all            quota,
                   cn_payruns_all           pr
             WHERE cspq.quota_id = quota.quota_id
               AND quota.quota_id > 0
               AND quota.org_id = cspq.org_id
               AND pr.pay_period_id = cspq.period_id
               AND quota.credit_type_id = -1000
               AND pr.payrun_id = p_payrun_id
               AND cspq.salesrep_id = p_salesrep_id
             GROUP BY cspq.salesrep_id,
                      cspq.period_id;

        EXCEPTION
            WHEN no_data_found THEN
            l_comm_ptd := 0 ;
            l_bonus_ptd := 0 ;
        END;

        UPDATE cn_payment_worksheets_all w
           SET w.comm_ptd = l_comm_ptd,
               w.bonus_ptd = l_bonus_ptd,
               w.comm_due_bb = l_bal
         WHERE w.salesrep_id = p_salesrep_id
           AND w.payrun_id  = p_payrun_id
           AND w.quota_id IS NULL ;

    END update_ptd_details ;

  /*
      Procedure : conc_submit
      Added for bug 5910965
    */

      PROCEDURE conc_submit
      (
          p_conc_program     IN VARCHAR2,
          p_description      IN VARCHAR2,
          p_logical_batch_id IN NUMBER,
          p_batch_id         IN NUMBER,
          p_payrun_id        IN NUMBER,
          p_org_id           IN cn_payruns.org_id%TYPE,
          p_params           IN conc_params,
          x_request_id       OUT NOCOPY NUMBER
      ) IS
      BEGIN
          fnd_file.put_line(fnd_file.log, 'Conc_submit BatchId = ' || p_batch_id);

          x_request_id := fnd_request.submit_request(application => 'CN',
                                                     program     => p_conc_program,
                                                     description => p_description,
                                                     argument1   => p_batch_id,
                                                     argument2   => p_payrun_id,
                                                     argument3   => p_logical_batch_id,
                                                     argument4   => p_org_id
                                                     );
          IF x_request_id = 0
          THEN
              fnd_file.put_line(fnd_file.log, 'Failed to create concurrent request for (payrun_id,batch_id) = ' || p_payrun_id ||','|| p_batch_id);
              fnd_file.put_line(fnd_file.log, 'Conc_submit: ' || fnd_message.get);
              raise fnd_api.G_EXC_ERROR;
          ELSE
              fnd_file.put_line(fnd_file.log, 'Concurrent request, ID = ' || x_request_id || ', for (payrun_id,batch_id) = ' || p_payrun_id ||','|| p_batch_id );
          END IF;

      EXCEPTION
          WHEN OTHERS THEN
              fnd_file.put_line(fnd_file.log, 'Conc_submit err:' || SQLERRM);
              RAISE;
      END conc_submit;



    -- ===========================================================================
    --   Procedure   : get_pay_rec_period_ids
    --   Description : This procedure is used to get pay period id and recover period id given
    --                  pay_interval_type_id and recoverable_interval_type_id.
    --                  Added for bug 2776847 by jjhuang.
    --   Calls       :
    -- ===========================================================================
    PROCEDURE get_pay_rec_period_ids
    (
        p_period_id                    IN cn_period_statuses.period_id%TYPE,
        p_quarter_num                  IN cn_period_statuses.quarter_num%TYPE,
        p_period_year                  IN cn_period_statuses.period_year%TYPE,
        p_pay_interval_type_id         IN cn_pmt_plans.pay_interval_type_id%TYPE,
        p_recoverable_interval_type_id IN cn_pmt_plans.recoverable_interval_type_id%TYPE,
        x_pay_period_id                OUT NOCOPY cn_pmt_plans.pay_interval_type_id%TYPE,
        x_rec_period_id                OUT NOCOPY cn_pmt_plans.recoverable_interval_type_id%TYPE,
        --R12
        p_org_id IN cn_payruns.org_id%TYPE
    ) IS
        CURSOR get_max_period_id_in_qtr(p_quarter_num cn_period_statuses.quarter_num%TYPE, p_period_year cn_period_statuses.period_year%TYPE) IS
            SELECT MAX(p.period_id) max_period_id
              FROM cn_period_statuses p,
                   cn_period_types    pt
             WHERE p.quarter_num = p_quarter_num
               AND p.period_year = p_period_year
               AND p.period_type = pt.period_type
               AND pt.period_type_id = 0
                  --R12
               AND p.org_id = p_org_id
               AND pt.org_id = p_org_id;

        CURSOR get_max_period_id_in_yr(p_period_year cn_period_statuses.period_year%TYPE) IS
            SELECT MAX(p.period_id) max_period_id
              FROM cn_period_statuses p,
                   cn_period_types    pt
             WHERE period_year = p_period_year
               AND p.period_type = pt.period_type
               AND pt.period_type_id = 0
                  --R12
               AND p.org_id = p_org_id
               AND pt.org_id = p_org_id;

        l_pay_period_id cn_pmt_plans.pay_interval_type_id%TYPE;
        l_rec_period_id cn_pmt_plans.recoverable_interval_type_id%TYPE;
    BEGIN
        IF p_pay_interval_type_id = -1000 --pay interval is period
        THEN
            l_pay_period_id := p_period_id;
        ELSIF p_pay_interval_type_id = -1001 --pay interval is quarter
        THEN
            FOR rec IN get_max_period_id_in_qtr(p_quarter_num, p_period_year)
            LOOP
                l_pay_period_id := rec.max_period_id;
            END LOOP;
        ELSIF p_pay_interval_type_id = -1002 --pay interval is year
        THEN
            FOR rec IN get_max_period_id_in_yr(p_period_year)
            LOOP
                l_pay_period_id := rec.max_period_id;
            END LOOP;
        END IF;

        IF p_recoverable_interval_type_id = -1000 --recover interval is period
        THEN
            l_rec_period_id := p_period_id;
        ELSIF p_recoverable_interval_type_id = -1001 --recover interval is quarter
        THEN
            FOR rec IN get_max_period_id_in_qtr(p_quarter_num, p_period_year)
            LOOP
                l_rec_period_id := rec.max_period_id;
            END LOOP;
        ELSIF p_recoverable_interval_type_id = -1002 --recover interval is year
        THEN
            FOR rec IN get_max_period_id_in_yr(p_period_year)
            LOOP
                l_rec_period_id := rec.max_period_id;
            END LOOP;
        END IF;

        x_pay_period_id := l_pay_period_id;
        x_rec_period_id := l_rec_period_id;
    END get_pay_rec_period_ids;

    -- ===========================================================================
    --   Procedure   : reset_payrun_id
    --   Description : This procedure is used to Reset payrun_id to NULL in
    --                  cn_payment_transactions for PMTPLN_REC, COMMISSION and BONUS
    --                  to be included in the next payrun.
    --                  Added for bug 2776847 by jjhuang.
    --   Calls       :
    -- ===========================================================================
    PROCEDURE reset_payrun_id
    (
        p_payrun_id          IN cn_payruns.payrun_id%TYPE,
        p_salesrep_id        IN cn_salesreps.salesrep_id%TYPE,
        p_incentive_type     IN cn_payruns.incentive_type_code%TYPE,
        p_payment_group_code IN cn_pmt_plans.payment_group_code%TYPE
    ) IS
    BEGIN
        IF p_incentive_type = 'ALL'
           OR p_incentive_type IS NULL
        THEN
            UPDATE cn_payment_transactions ptrx
               SET payrun_id         = NULL,
                   last_update_date  = SYSDATE,
                   last_updated_by   = fnd_global.user_id,
                   last_update_login = fnd_global.login_id
             WHERE ptrx.payrun_id = p_payrun_id
               AND ptrx.credited_salesrep_id = p_salesrep_id
               AND ptrx.incentive_type_code IN ('PMTPLN_REC', 'COMMISSION', 'BONUS')
               AND EXISTS (SELECT 1
                      FROM cn_quotas_all q
                     WHERE q.quota_id = ptrx.quota_id
                       AND q.payment_group_code = p_payment_group_code);
        ELSE
            UPDATE cn_payment_transactions ptrx
               SET payrun_id         = NULL,
                   last_update_date  = SYSDATE,
                   last_updated_by   = fnd_global.user_id,
                   last_update_login = fnd_global.login_id
             WHERE ptrx.payrun_id = p_payrun_id
               AND ptrx.credited_salesrep_id = p_salesrep_id
               AND ptrx.incentive_type_code IN ('PMTPLN_REC', decode(p_incentive_type, 'COMMISSION', 'COMMISSION', 'BONUS', 'BONUS'))
               AND EXISTS (SELECT 1
                      FROM cn_quotas_all q
                     WHERE q.quota_id = ptrx.quota_id
                       AND q.payment_group_code = p_payment_group_code);
        END IF;
    END reset_payrun_id;

    -- ===========================================================================
    --   Procedure   : give_min_as_pmt_plan
    --   Description : This procedure is used to give the minimum amount as a payment
    --                  plan amount when it's a pay period, but not a recover period
    --                  when pay against commission is 'N'.
    --                  Added for bug 2776847 by jjhuang.
    --   Calls       :
    -- ===========================================================================
    PROCEDURE give_min_as_pmt_plan
    (
        p_min                 IN cn_pmt_plans.minimum_amount%TYPE,
        p_min_rec_flag        IN cn_pmt_plans.min_rec_flag%TYPE,
        x_pmt_amount_adj_rec  OUT NOCOPY NUMBER,
        x_pmt_amount_adj_nrec OUT NOCOPY NUMBER
    ) IS
        l_pmt_amount_adj_rec  NUMBER := 0;
        l_pmt_amount_adj_nrec NUMBER := 0;
    BEGIN
        --minimum calculation
        IF (p_min IS NOT NULL)
        THEN
            IF p_min_rec_flag = 'Y'
            THEN
                l_pmt_amount_adj_rec := p_min;
            ELSE
                l_pmt_amount_adj_nrec := p_min;
            END IF;
        END IF;

        x_pmt_amount_adj_rec  := l_pmt_amount_adj_rec;
        x_pmt_amount_adj_nrec := l_pmt_amount_adj_nrec;
    END give_min_as_pmt_plan;

    -- ===========================================================================
    --   Procedure   : get_start_and_end_dates
    --   Description : This procedure is used to get the start date and end date of
    --                  a interval.  An interval could be period, quarter or year
    --                  depending on p_interval_type_id.
    --                  Added for bug 2776847 by jjhuang.
    --   Calls       :
    -- ===========================================================================
    PROCEDURE get_start_and_end_dates
    (
        p_interval_type_id    IN NUMBER,
        p_period_set_id       IN cn_period_statuses.period_set_id%TYPE,
        p_period_type_id      IN cn_period_statuses.period_type_id%TYPE,
        p_period_year         IN cn_period_statuses.period_year%TYPE,
        p_quarter_num         IN cn_period_statuses.period_year%TYPE,
        p_start_date          IN cn_period_statuses.start_date%TYPE,
        p_end_date            IN cn_period_statuses.end_date%TYPE,
        x_interval_start_date OUT NOCOPY cn_period_statuses.start_date%TYPE,
        x_interval_end_date   OUT NOCOPY cn_period_statuses.end_date%TYPE,
        --R12
        p_org_id IN cn_payruns.org_id%TYPE
    ) IS
        l_interval_start_date cn_period_statuses.start_date%TYPE;
        l_interval_end_date   cn_period_statuses.end_date%TYPE;
    BEGIN
        IF p_interval_type_id = -1000
        THEN
            --period
            l_interval_start_date := p_start_date;
            l_interval_end_date   := p_end_date;
        ELSIF p_interval_type_id = -1001
        THEN
            --quarter, get the start, end dates of the quarter.
            SELECT MIN(start_date),
                   MAX(end_date)
              INTO l_interval_start_date,
                   l_interval_end_date
              FROM cn_period_statuses
             WHERE period_set_id = p_period_set_id
               AND period_type_id = p_period_type_id
               AND quarter_num = p_quarter_num
               AND period_year = p_period_year
                  --R12
               AND org_id = p_org_id;
        ELSIF p_interval_type_id = -1002
        THEN
            SELECT MIN(start_date),
                   MAX(end_date)
              INTO l_interval_start_date,
                   l_interval_end_date
              FROM cn_period_statuses
             WHERE period_set_id = p_period_set_id
               AND period_type_id = p_period_type_id
               AND period_year = p_period_year
                  --R12
               AND org_id = p_org_id;
        END IF;

        x_interval_start_date := l_interval_start_date;
        x_interval_end_date   := l_interval_end_date;
    END get_start_and_end_dates;

    -- ===========================================================================
    --   Procedure   : distribute_pmt_plan_amount
    --   Description : This procedure is used to distribute payment plan amount evenly on
    --                  all quotas on a pay interval basis.  A pay interval could be
    --                  a period, or a quarter or a year depending on the pay interval
    --                  type that associates with the payment plan.
    --                  Taken out from original calculate_totals procedure for bug 2776847 by jjhuang.
    --   Calls       :
    -- ===========================================================================
    PROCEDURE distribute_pmt_plan_amount
    (
        p_salesrep_id         IN cn_salesreps.salesrep_id%TYPE,
        p_pmt_amount_adj_rec  IN NUMBER,
        p_pmt_amount_adj_nrec IN NUMBER,
        p_payment_group_code  IN cn_srp_pmt_plans_v.payment_group_code%TYPE,
        p_period_id           IN cn_payruns.pay_period_id%TYPE,
        p_incentive_type      IN cn_quotas.incentive_type_code%TYPE,
        x_calc_rec_tbl        IN OUT NOCOPY calc_rec_tbl_type,
        --R12
        p_org_id IN cn_payruns.org_id%TYPE
    ) IS
        CURSOR get_pe_pg_count(p_payment_group_code VARCHAR2) IS
            SELECT COUNT(DISTINCT cnq.quota_id) num_pe
              FROM cn_srp_period_quotas cspq,
                   cn_quotas_all        cnq
             WHERE cnq.payment_group_code = p_payment_group_code
               AND cspq.quota_id = cnq.quota_id
               AND cnq.credit_type_id = -1000
               AND cspq.salesrep_id = p_salesrep_id
               AND cspq.period_id = p_period_id
                  --R12
               AND cspq.org_id = cnq.org_id
               AND cspq.org_id = p_org_id
                  --bug 3107646, issue 4
               AND cnq.incentive_type_code =
                   decode(nvl(p_incentive_type, cnq.incentive_type_code), 'COMMISSION', 'COMMISSION', 'BONUS', 'BONUS', cnq.incentive_type_code)
                  -- BUG 3140343 Payee design
               AND cspq.quota_id NOT IN (SELECT spayee.quota_id
                                           FROM cn_srp_payee_assigns spayee,
                                                cn_period_statuses   ps
                                          WHERE (spayee.salesrep_id = p_salesrep_id OR spayee.payee_id = p_salesrep_id)
                                            AND ps.period_id = p_period_id
                                            AND ps.end_date >= spayee.start_date
                                               --R12
                                            AND spayee.org_id = ps.org_id
                                            AND spayee.org_id = p_org_id
                                            AND ps.start_date <= nvl(spayee.end_date, ps.end_date));
        CURSOR get_pe_pg(p_payment_group_code VARCHAR2) IS
            SELECT DISTINCT cnq.quota_id quota_id
              FROM cn_srp_period_quotas cspq,
                   cn_quotas_all        cnq
             WHERE cnq.payment_group_code = p_payment_group_code
               AND cspq.quota_id = cnq.quota_id
               AND cnq.credit_type_id = -1000
               AND cspq.salesrep_id = p_salesrep_id
               AND cspq.period_id = p_period_id
                  --R12
               AND cspq.org_id = cnq.org_id
               AND cspq.org_id = p_org_id
                  --bug 3107646, issue 4
               AND cnq.incentive_type_code =
                   decode(nvl(p_incentive_type, cnq.incentive_type_code), 'COMMISSION', 'COMMISSION', 'BONUS', 'BONUS', cnq.incentive_type_code)
                  -- BUG 3140343 Payee design
               AND cspq.quota_id NOT IN (SELECT spayee.quota_id
                                           FROM cn_srp_payee_assigns spayee,
                                                cn_period_statuses   ps
                                          WHERE (spayee.salesrep_id = p_salesrep_id OR spayee.payee_id = p_salesrep_id)
                                            AND ps.period_id = p_period_id
                                            AND ps.end_date >= spayee.start_date
                                               --R12
                                            AND spayee.org_id = ps.org_id
                                            AND spayee.org_id = p_org_id
                                            AND ps.start_date <= nvl(spayee.end_date, ps.end_date));
        l_pe_count NUMBER := 0;
    BEGIN
        -- If payment plan adjustments exist, determine how to distribute them
        IF p_pmt_amount_adj_rec <> 0
           OR p_pmt_amount_adj_nrec <> 0
        THEN
            -- How many plan elements assigned to this rep have this payment group code?
            FOR rec IN get_pe_pg_count(p_payment_group_code)
            LOOP
                l_pe_count := rec.num_pe;
            END LOOP;

            -- Update rec and nrec amount for each worksheet
            -- that is created for pe that is assigned the current payment group code
            FOR pe IN get_pe_pg(p_payment_group_code)
            LOOP
                FOR i IN x_calc_rec_tbl.FIRST .. x_calc_rec_tbl.LAST
                LOOP
                    IF x_calc_rec_tbl(i).quota_id = pe.quota_id
                    THEN
                        x_calc_rec_tbl(i).pmt_amount_adj_rec := nvl(x_calc_rec_tbl(i).pmt_amount_adj_rec, 0) + p_pmt_amount_adj_rec / l_pe_count;
                        x_calc_rec_tbl(i).pmt_amount_adj_nrec := nvl(x_calc_rec_tbl(i).pmt_amount_adj_nrec, 0) + p_pmt_amount_adj_nrec / l_pe_count;
                    END IF;
                END LOOP;
            END LOOP; -- end of loop to fetch plan elements for current payment group code
        END IF; --end of p_pmt_amount_adj_rec <> 0 OR p_pmt_amount_adj_nrec <> 0
    END distribute_pmt_plan_amount;

    -- ===========================================================================
    --   Procedure   : proc_pmt_trans_by_pe
    --   Description : This procedure is used to process (sum up) all payment transactions by pe.
    --                  Taken out from original calculate_totals procedure for bug 2776847 by jjhuang.
    --               : Comments for Bug 3198445 by jjhuang:
    --               : 1. The following case does not exist for bug 3198445 by jjhuang:
    --                  p_payment_group_code IS NOT NULL AND p_applied_pgc.COUNT = 0
    --               : 2. When p_payment_group_code is NULL, it includes two cases:
    --                  i.  No payment plan assignments for this salesrep at this period.
    --                  ii. Post action for 1 to n-1 paymenet group codes applied to this srp at the period
    --                      where there are n payment group codes at the current period.
    --                  iii. If n payment group codes applied already given there are n payment group codes,
    --                      do nothing.
    --   Calls       :
    -- ===========================================================================
    PROCEDURE proc_pmt_trans_by_pe
    (
        p_salesrep_id        IN cn_payment_worksheets.salesrep_id%TYPE,
        p_incentive_type     IN cn_payruns.incentive_type_code%TYPE,
        p_payrun_id          IN cn_payruns.payrun_id%TYPE,
        p_payment_group_code IN cn_pmt_plans.payment_group_code%TYPE, --bug 3175375 by jjhuang.
        p_applied_pgc        IN dbms_sql.varchar2_table, --bug 3198445 by jjhuang.
        x_calc_rec_tbl       IN OUT NOCOPY calc_rec_tbl_type,
        --R12
        p_org_id IN cn_payruns.org_id%TYPE
    ) IS
        -- 2/7/03 AC Bug 2792037 get list of PE from cn_payment_transactions
        -- 2/12/03 AC Bug 2800968 union all to old cursor(against cn_srp_periods)
        -- to take care srp with no transaction but want to apply pmt plan
        -- Bug 3140343 : Payee Design.
        -- Bug 3198445 by jjhuang:  Added payment_group_code for cursor get_srp_pe
        CURSOR get_srp_pe IS
        --Added cn_quotas_all for bug 3175375 by jjhuang.
            SELECT DISTINCT v.quota_id,
                            v.payment_group_code
              FROM (SELECT cnpt.quota_id,
                           cq.payment_group_code
                      FROM cn_payment_transactions cnpt,
                           cn_quotas_all           cq
                     WHERE cnpt.credit_type_id = g_credit_type_id
                       AND cnpt.credited_salesrep_id = p_salesrep_id
                       AND cnpt.payrun_id = p_payrun_id
                       AND ((cnpt.incentive_type_code NOT IN ('COMMISSION', 'BONUS')) OR
                           (cnpt.incentive_type_code = nvl(p_incentive_type, cnpt.incentive_type_code)))
                       AND cnpt.quota_id = cq.quota_id
                       AND cq.payment_group_code = nvl(p_payment_group_code, cq.payment_group_code)
                    UNION ALL
                    SELECT cnsp.quota_id,
                           cnq.payment_group_code
                      FROM cn_srp_period_quotas cnsp,
                           cn_quotas_all        cnq,
                           cn_payruns           cnp
                     WHERE cnsp.salesrep_id = p_salesrep_id
                       AND cnq.credit_type_id = g_credit_type_id
                       AND cnq.incentive_type_code = nvl(p_incentive_type, cnq.incentive_type_code)
                       AND cnp.payrun_id = p_payrun_id
                       AND cnp.pay_period_id = cnsp.period_id
                       AND cnsp.quota_id = cnq.quota_id
                       AND cnq.payment_group_code = nvl(p_payment_group_code, cnq.payment_group_code)
                       AND NOT EXISTS (
                            -- separate queries for performance reasons. merge cartesian reported
                            SELECT 1
                              FROM cn_srp_payee_assigns_all spayee,
                                    cn_period_statuses_all   ps
                             WHERE (spayee.salesrep_id = p_salesrep_id)
                               AND ps.period_id = cnp.pay_period_id
                               AND ps.end_date >= spayee.start_date
                               AND ps.org_id = p_org_id
                               AND cnsp.quota_id = spayee.quota_id
                               AND ps.start_date <= nvl(spayee.end_date, ps.end_date)
                            UNION ALL
                            SELECT 1
                              FROM cn_srp_payee_assigns_all spayee,
                                   cn_period_statuses_all   ps
                             WHERE spayee.payee_id = p_salesrep_id
                               AND ps.period_id = cnp.pay_period_id
                               AND ps.end_date >= spayee.start_date
                               AND ps.org_id = p_org_id
                               AND cnsp.quota_id = spayee.quota_id
                               AND ps.start_date <= nvl(spayee.end_date, ps.end_date))) v;

        -- Bug 3198445 by jjhuang:  get distinct payment group code count.
        --Added cn_quotas_all for bug 3175375 by jjhuang.
        CURSOR get_pgc_count IS
            SELECT COUNT(DISTINCT v.payment_group_code) pgc_count
              FROM (SELECT cnpt.quota_id,
                           cq.payment_group_code
                      FROM cn_payment_transactions cnpt,
                           cn_quotas_all           cq
                     WHERE cnpt.credit_type_id = g_credit_type_id
                       AND cnpt.credited_salesrep_id = p_salesrep_id
                       AND cnpt.payrun_id = p_payrun_id
                       AND ((cnpt.incentive_type_code NOT IN ('COMMISSION', 'BONUS')) OR
                           (cnpt.incentive_type_code = nvl(p_incentive_type, cnpt.incentive_type_code)))
                       AND cnpt.quota_id = cq.quota_id
                       AND cq.payment_group_code = nvl(p_payment_group_code, cq.payment_group_code)
                    UNION ALL
                    SELECT cnsp.quota_id,
                           cnq.payment_group_code
                      FROM cn_srp_period_quotas cnsp,
                           cn_quotas_all        cnq,
                           cn_payruns           cnp
                     WHERE cnsp.salesrep_id = p_salesrep_id
                       AND cnq.credit_type_id = g_credit_type_id
                       AND cnq.incentive_type_code = nvl(p_incentive_type, cnq.incentive_type_code)
                       AND cnp.payrun_id = p_payrun_id
                       AND cnp.pay_period_id = cnsp.period_id
                       AND cnsp.quota_id = cnq.quota_id
                       AND cnq.payment_group_code = nvl(p_payment_group_code, cnq.payment_group_code)
                       AND NOT EXISTS (
                            -- separate queries for performance reasons. merge cartesian reported
                            SELECT 1
                              FROM cn_srp_payee_assigns_all spayee,
                                    cn_period_statuses_all   ps
                             WHERE (spayee.salesrep_id = p_salesrep_id)
                               AND ps.period_id = cnp.pay_period_id
                               AND ps.end_date >= spayee.start_date
                               AND ps.org_id = p_org_id
                               AND cnsp.quota_id = spayee.quota_id
                               AND ps.start_date <= nvl(spayee.end_date, ps.end_date)
                            UNION ALL
                            SELECT 1
                              FROM cn_srp_payee_assigns_all spayee,
                                   cn_period_statuses_all   ps
                             WHERE spayee.payee_id = p_salesrep_id
                               AND ps.period_id = cnp.pay_period_id
                               AND ps.end_date >= spayee.start_date
                               AND ps.org_id = p_org_id
                               AND cnsp.quota_id = spayee.quota_id
                               AND ps.start_date <= nvl(spayee.end_date, ps.end_date))) v;

        -- remove join to cn_quotas_all since can get quota_id from cnpt
        -- 03/24/03 -9999 is used in cnupsp2.sql, change to -9990
        CURSOR get_earnings_total_by_pe(p_quota_id NUMBER) IS
        -- earnings to populate pmt_amount_calc
            SELECT nvl(SUM(nvl(cnpt.amount, 0)), 0) pmt_amount_calc,
                   cnpt.quota_id quota_id,
                   0 pmt_amount_recovery,
                   0 pmt_amount_adj,
                   0 held_amount
              FROM cn_payment_transactions cnpt
             WHERE cnpt.credited_salesrep_id = p_salesrep_id
               AND cnpt.incentive_type_code = nvl(p_incentive_type, cnpt.incentive_type_code)
               AND cnpt.incentive_type_code IN ('COMMISSION', 'BONUS')
               AND cnpt.payrun_id = p_payrun_id
               AND nvl(hold_flag, 'N') = 'N'
               AND nvl(cnpt.quota_id, -9990) = nvl(p_quota_id, -9990)
                  --R12
               AND cnpt.org_id = p_org_id
             GROUP BY cnpt.quota_id
            UNION ALL
            -- Recovery to populate pmt_amount_recovery
            SELECT 0 pmt_amount_calc,
                   cnpt.quota_id quota_id,
                   nvl(SUM(nvl(cnpt.amount, 0)), 0) pmt_amount_recovery,
                   0 pmt_amount_adj,
                   0 held_amount
              FROM cn_payment_transactions cnpt
             WHERE cnpt.credited_salesrep_id = p_salesrep_id
               AND cnpt.incentive_type_code = 'PMTPLN_REC'
               AND cnpt.payrun_id = p_payrun_id
               AND nvl(cnpt.quota_id, -9990) = nvl(p_quota_id, -9990)
                  --R12
               AND cnpt.org_id = p_org_id
             GROUP BY cnpt.quota_id
            UNION ALL
            -- to populate manual pay adjustments in pmt_amount_adj
            SELECT 0 pmt_amount_calc,
                   cnpt.quota_id quota_id,
                   0 pmt_amount_recovery,
                   nvl(SUM(nvl(cnpt.amount, 0)), 0) pmt_amount_adj,
                   0 held_amount
              FROM cn_payment_transactions cnpt
             WHERE cnpt.credited_salesrep_id = p_salesrep_id
               AND cnpt.incentive_type_code IN ('MANUAL_PAY_ADJ')
               AND cnpt.payrun_id = p_payrun_id
               AND nvl(cnpt.quota_id, -9990) = nvl(p_quota_id, -9990)
                  --R12
               AND cnpt.org_id = p_org_id
             GROUP BY cnpt.quota_id
            UNION ALL
            -- to populate control payments in pmt_amount_adj
            SELECT 0 pmt_amount_calc,
                   cnpt.quota_id quota_id,
                   0 pmt_amount_recovery,
                   nvl(SUM(nvl(cnpt.payment_amount, 0)), 0) - nvl(SUM(nvl(cnpt.amount, 0)), 0) pmt_amount_adj,
                   0 held_amount
              FROM cn_payment_transactions cnpt
             WHERE cnpt.credited_salesrep_id = p_salesrep_id
               AND cnpt.incentive_type_code = nvl(p_incentive_type, cnpt.incentive_type_code)
               AND cnpt.incentive_type_code IN ('COMMISSION', 'BONUS')
               AND nvl(cnpt.hold_flag, 'N') = 'N'
               AND cnpt.payrun_id = p_payrun_id
               AND nvl(cnpt.quota_id, -9990) = nvl(p_quota_id, -9990)
                  --R12
               AND cnpt.org_id = p_org_id
             GROUP BY cnpt.quota_id
            UNION ALL
            -- to populate hold in pmt_amount_adj
            SELECT 0 pmt_amount_calc,
                   cnpt.quota_id quota_id,
                   0 pmt_amount_recovery,
                   0 pmt_amount_adj,
                   nvl(SUM(nvl(cnpt.payment_amount, 0)), 0) held_amount
              FROM cn_payment_transactions cnpt
             WHERE cnpt.credited_salesrep_id = p_salesrep_id
               AND cnpt.incentive_type_code = nvl(p_incentive_type, cnpt.incentive_type_code)
               AND cnpt.incentive_type_code IN ('COMMISSION', 'BONUS')
               AND nvl(cnpt.hold_flag, 'N') = 'Y'
               AND cnpt.payrun_id = p_payrun_id
               AND nvl(cnpt.quota_id, -9990) = nvl(p_quota_id, -9990)
                  --R12
               AND cnpt.org_id = p_org_id
             GROUP BY cnpt.quota_id
            UNION ALL
            -- to populate waive recovery in pmt_amount_adj
            -- changed recovery amount to negative for fix  BUG#2545629|
            SELECT 0 pmt_amount_calc,
                   cnpt.quota_id quota_id,
                   0 pmt_amount_recovery,
                   -nvl(SUM(nvl(cnpt.amount, 0)), 0) pmt_amount_adj,
                   0 held_amount
              FROM cn_payment_transactions cnpt
             WHERE cnpt.credited_salesrep_id = p_salesrep_id
               AND cnpt.incentive_type_code = 'PMTPLN_REC'
               AND nvl(cnpt.waive_flag, 'N') = 'Y'
               AND cnpt.payrun_id = p_payrun_id
               AND nvl(cnpt.quota_id, -9990) = nvl(p_quota_id, -9990)
                  --R12
               AND cnpt.org_id = p_org_id
             GROUP BY cnpt.quota_id;

        --local variables
        l_record_count    NUMBER := 0;
        l_pmt_amount_calc NUMBER := 0;
        l_pmt_amount_rec  NUMBER := 0;
        l_pmt_amount_adj  NUMBER := 0;
        l_held_amount     NUMBER := 0;
        --variables used for bug 3198445 by jjhuang -begin
        l_pgc_count   NUMBER := 0;
        l_post_action NUMBER := 0; --0 is false, 1 is true;
        l_count       NUMBER := 0;

        TYPE quotas_rec_type IS RECORD(
            quota_id cn_quotas.quota_id%TYPE);

        TYPE quotas_rec_tbl_type IS TABLE OF quotas_rec_type INDEX BY BINARY_INTEGER;

        l_quota_tbl       quotas_rec_tbl_type;
        l_quotas_to_apply NUMBER;
        --variables used for bug 3198445 by jjhuang -end
    BEGIN
        -- Bug 3198445 by jjhuang.
        --Find total number of payment group codes need to be applied.
        FOR each_row IN get_pgc_count
        LOOP
            l_pgc_count := each_row.pgc_count;
        END LOOP;

        --Post step after applying 1 to n-1 payment group codes out of n payment group codes
        --for this srp at the current period. For bug 3198445 by jjhuang.
        --Only create those quotas that are in different payment group codes.
        IF (p_payment_group_code IS NULL AND p_applied_pgc.COUNT <> 0 AND l_pgc_count <> p_applied_pgc.COUNT)
        THEN
            l_post_action     := 1;
            l_quotas_to_apply := 0;

            FOR each_quota IN get_srp_pe
            LOOP
                l_count := 0;

                FOR i IN p_applied_pgc.FIRST .. p_applied_pgc.LAST
                LOOP
                    IF (each_quota.payment_group_code = p_applied_pgc(i))
                    THEN
                        l_count := l_count + 1;
                    END IF;
                END LOOP;

                IF l_count = 0
                THEN
                    l_quota_tbl(l_quotas_to_apply).quota_id := each_quota.quota_id;
                    l_quotas_to_apply := l_quotas_to_apply + 1;

                    --payment group codes already applied before, do nothing.
                ELSIF l_count > 0
                THEN
                    NULL;
                END IF;
            END LOOP;
        END IF;

        -- Bug 3140343 : Payee Design.
        l_record_count := x_calc_rec_tbl.COUNT;

        IF l_post_action = 1
        THEN
            FOR i IN l_quota_tbl.FIRST .. l_quota_tbl.LAST
            LOOP
                x_calc_rec_tbl(l_record_count).quota_id := NULL;
                x_calc_rec_tbl(l_record_count).pmt_amount_adj_rec := 0;
                x_calc_rec_tbl(l_record_count).pmt_amount_adj_nrec := 0;
                x_calc_rec_tbl(l_record_count).pmt_amount_calc := 0;
                x_calc_rec_tbl(l_record_count).pmt_amount_rec := 0;
                x_calc_rec_tbl(l_record_count).pmt_amount_ctr := 0;
                x_calc_rec_tbl(l_record_count).held_amount := 0;
                l_pmt_amount_calc := 0;
                l_pmt_amount_rec := 0;
                l_pmt_amount_adj := 0;
                l_held_amount := 0;

                FOR earnings IN get_earnings_total_by_pe(l_quota_tbl(i).quota_id)
                LOOP
                    l_pmt_amount_calc := l_pmt_amount_calc + earnings.pmt_amount_calc;
                    l_pmt_amount_rec  := l_pmt_amount_rec + earnings.pmt_amount_recovery;
                    l_pmt_amount_adj  := l_pmt_amount_adj + earnings.pmt_amount_adj;
                    l_held_amount     := l_held_amount + earnings.held_amount;
                END LOOP;

                x_calc_rec_tbl(l_record_count).quota_id := l_quota_tbl(i).quota_id;
                x_calc_rec_tbl(l_record_count).pmt_amount_calc := l_pmt_amount_calc;
                x_calc_rec_tbl(l_record_count).pmt_amount_rec := l_pmt_amount_rec;
                x_calc_rec_tbl(l_record_count).pmt_amount_ctr := l_pmt_amount_adj;
                x_calc_rec_tbl(l_record_count).held_amount := l_held_amount;
                l_record_count := l_record_count + 1;
            END LOOP;
            -- This elsif branch includes the following cases for bug 3198445 by jjhuang.
            -- 1.  No payment plans for this srp for this period. That is:
            --      p_payment_group_code is NULL AND p_applied_pgc.COUNT = 0
            -- 2.  Apply the current payment group code to this srp. That is:
            --      p_payment_group_code IS NOT NULL AND p_applied_pgc.COUNT <> 0
        ELSIF ((l_post_action = 0 AND p_payment_group_code IS NULL AND p_applied_pgc.COUNT = 0) OR
              (l_post_action = 0 AND p_payment_group_code IS NOT NULL AND p_applied_pgc.COUNT <> 0))
        THEN
            FOR each_quota IN get_srp_pe
            LOOP
                x_calc_rec_tbl(l_record_count).quota_id := NULL;
                x_calc_rec_tbl(l_record_count).pmt_amount_adj_rec := 0;
                x_calc_rec_tbl(l_record_count).pmt_amount_adj_nrec := 0;
                x_calc_rec_tbl(l_record_count).pmt_amount_calc := 0;
                x_calc_rec_tbl(l_record_count).pmt_amount_rec := 0;
                x_calc_rec_tbl(l_record_count).pmt_amount_ctr := 0;
                x_calc_rec_tbl(l_record_count).held_amount := 0;
                l_pmt_amount_calc := 0;
                l_pmt_amount_rec := 0;
                l_pmt_amount_adj := 0;
                l_held_amount := 0;

                FOR earnings IN get_earnings_total_by_pe(each_quota.quota_id)
                LOOP
                    l_pmt_amount_calc := l_pmt_amount_calc + earnings.pmt_amount_calc;
                    l_pmt_amount_rec  := l_pmt_amount_rec + earnings.pmt_amount_recovery;
                    l_pmt_amount_adj  := l_pmt_amount_adj + earnings.pmt_amount_adj;
                    l_held_amount     := l_held_amount + earnings.held_amount;
                END LOOP;

                x_calc_rec_tbl(l_record_count).quota_id := each_quota.quota_id;
                x_calc_rec_tbl(l_record_count).pmt_amount_calc := l_pmt_amount_calc;
                x_calc_rec_tbl(l_record_count).pmt_amount_rec := l_pmt_amount_rec;
                x_calc_rec_tbl(l_record_count).pmt_amount_ctr := l_pmt_amount_adj;
                x_calc_rec_tbl(l_record_count).held_amount := l_held_amount;
                l_record_count := l_record_count + 1;
            END LOOP;
            -- This elsif branch includes the following case for bug 3198445 by jjhuang.
            -- All the payment group codes have been applied to this srp. Do nothing.
        ELSIF (l_post_action = 0 AND p_payment_group_code IS NULL AND p_applied_pgc.COUNT <> 0 AND l_pgc_count = p_applied_pgc.COUNT)
        THEN
            NULL;
        END IF;
    END proc_pmt_trans_by_pe;

    -- ===========================================================================
    --   Procedure   : Calculate_totals
    --   Description : This procedure is used to calculate totals from payment plans.
    --                  This procedure takes care of all cases which are accessiable from UI.
    --                  All other cases will be blocked by UI.
    --
    --                  PayAgainstCommission        PayInterval     RecoveryInterval
    --                  Y                           P               P
    --                  Y                           Q               Q
    --                  Y                           Y               Y
    --                  N                           P               P
    --                  N                           Q               Q
    --                  N                           Y               Y
    --                  N                           P               Q
    --                  N                           P               Y
    --                  N                           Q               Y
    --
    --                  P stands for period, Q stands for quarter and Y stands for Year in
    --                  PayInterval and RecoveryInterval.
    --                  Y stands for yes and N stands for no in PayAgainstCommission.
    --
    --                  The logic in this procedure is:
    --
    --                  IF payment plans exist
    --                  THEN
    --                      IF ( srp_pmt_plan.pay_against_commission in ('Y', 'N')
    --                          AND l_period_id = l_pay_period_id
    --                          AND l_period_id = l_rec_period_id )
    --                      THEN
    --                          do payment plans;
    --                      ELSE
    --                          IF ( srp_pmt_plan.pay_against_commission = 'N'
    --                              AND l_period_id = l_pay_period_id
    --                              AND l_period_id <> l_rec_period_id )
    --                          THEN
    --                              give min as payment plan;
    --                          ELSIF ( srp_pmt_plan.pay_against_commission = 'N'
    --                              AND l_period_id <> l_pay_period_id )
    --                          THEN
    --                              reset payrun_id to NULL to be included in the next payrun calculation;
    --                          ELSIF ( srp_pmt_plan.pay_against_commission = 'Y'
    --                              AND l_period_id <> l_rec_period_id )
    --                          THEN
    --                              pay earnings;
    --                          END IF;
    --                      END IF;
    --                  END IF;
    --
    --                  IF no payment plans
    --                  THEN
    --                      pay earnings;
    --                  END IF;
    --   Calls       :
    -- ===========================================================================
    PROCEDURE calculate_totals
    (
        p_salesrep_id    IN cn_payment_worksheets.salesrep_id%TYPE,
        p_period_id      IN cn_payruns.pay_period_id%TYPE,
        p_incentive_type IN cn_payruns.incentive_type_code%TYPE,
        p_payrun_id      IN cn_payruns.payrun_id%TYPE,
        x_calc_rec_tbl   IN OUT NOCOPY calc_rec_tbl_type,
        --R12
        p_org_id IN cn_payruns.org_id%TYPE
    ) IS
        CURSOR get_earnings_total(p_payment_group_code VARCHAR2) IS
            SELECT SUM(cnpt.payment_amount) payment_amount
              FROM cn_payment_transactions cnpt,
                   cn_quotas_all           cnq
             WHERE cnpt.credited_salesrep_id = p_salesrep_id
               AND cnpt.payrun_id = p_payrun_id
               AND cnpt.quota_id = cnq.quota_id
               AND nvl(hold_flag, 'N') = 'N'
               AND nvl(waive_flag, 'N') = 'N'
               AND cnq.payment_group_code = p_payment_group_code
               AND cnpt.incentive_type_code <> 'PMTPLN';

        TYPE srppmtplncurtype IS REF CURSOR;

        srp_pmt_plan_cur srppmtplncurtype;
        srp_pmt_plan     cn_srp_pmt_plans_v%ROWTYPE;
        l_stmt           VARCHAR2(4000);

        --  Cursor to get the Periods
        CURSOR get_prd_statuses(p_period_id NUMBER) IS
            SELECT quarter_num,
                   period_year,
                   period_set_id,
                   period_type_id,
                   start_date,
                   end_date
              FROM cn_period_statuses
             WHERE period_id = p_period_id
                  --R12
               AND org_id = p_org_id;

        l_get_prd_statuses get_prd_statuses%ROWTYPE;

        CURSOR get_qtr_sdate(p_period_set_id NUMBER, p_period_type_id NUMBER, p_period_year NUMBER, p_quarter_num NUMBER) IS
            SELECT MIN(start_date)
              FROM cn_period_statuses
             WHERE period_set_id = p_period_set_id
               AND period_type_id = p_period_type_id
               AND period_year = p_period_year
               AND quarter_num = p_quarter_num
                  --R12
               AND org_id = p_org_id;

        CURSOR get_qtr_edate(p_period_set_id NUMBER, p_period_type_id NUMBER, p_period_year NUMBER, p_quarter_num NUMBER) IS
            SELECT MAX(end_date)
              FROM cn_period_statuses
             WHERE period_set_id = p_period_set_id
               AND period_type_id = p_period_type_id
               AND period_year = p_period_year
               AND quarter_num = p_quarter_num
                  --R12
               AND org_id = p_org_id;

        CURSOR get_year_sdate(p_period_set_id NUMBER, p_period_type_id NUMBER, p_period_year NUMBER) IS
            SELECT MIN(start_date)
              FROM cn_period_statuses
             WHERE period_set_id = p_period_set_id
               AND period_type_id = p_period_type_id
               AND period_year = p_period_year
               AND org_id = p_org_id;

        CURSOR get_year_edate(p_period_set_id NUMBER, p_period_type_id NUMBER, p_period_year NUMBER) IS
            SELECT MAX(end_date)
              FROM cn_period_statuses
             WHERE period_set_id = p_period_set_id
               AND period_type_id = p_period_type_id
               AND period_year = p_period_year
               AND org_id = p_org_id;

        -- Bug 2875120/2892822 : combine 2 cursor
        -- get the amount paid at the payment group code level
        CURSOR get_itd_amount_paid(p_period_set_id NUMBER, p_period_type_id NUMBER, p_interval_sdate DATE, p_interval_edate DATE, p_pg_code cn_pmt_plans.payment_group_code%TYPE) IS
            SELECT nvl(SUM(balance1_dtd - balance1_ctd), 0) payment
              FROM cn_srp_periods     csp,
                   cn_quotas_all      q,
                   cn_period_statuses ps
             WHERE csp.period_id = ps.period_id
               AND ps.period_set_id = p_period_set_id
               AND ps.period_type_id = p_period_type_id
               AND ps.start_date >= p_interval_sdate
               AND ps.end_date <= p_interval_edate
               AND csp.salesrep_id = p_salesrep_id
               AND csp.credit_type_id = g_credit_type_id
               AND csp.quota_id = q.quota_id
               AND q.payment_group_code = p_pg_code
               AND csp.org_id = q.org_id
               AND q.org_id = ps.org_id
               AND ps.org_id = p_org_id;

        --local variables
        -- variable to hold pre - pmt plan value
        l_net_pre_pmtplan     NUMBER := 0;
        l_itd_paid            NUMBER := 0;
        l_pe_count            NUMBER := 0;
        l_pmt_amount_adj_rec  NUMBER := 0;
        l_pmt_amount_adj_nrec NUMBER := 0;
        -- Variables for determining if current period is eligible for
        -- payment plan adjustments
        l_period_set_id  NUMBER;
        l_period_type_id NUMBER;
        l_start_date     DATE;
        l_end_date       DATE;
        l_qtr_num        NUMBER;
        l_year_num       NUMBER;
        l_period_id      NUMBER;
        l_interval_sdate DATE;
        l_interval_edate DATE;
        l_count          NUMBER;
        l_srp_earnings   NUMBER := 0;
        l_srp_recovery   NUMBER := 0;
        l_total_amount   NUMBER := 0;
        l_amount         NUMBER := 0;
        l_earnings       NUMBER := 0;
        l_recovery       NUMBER := 0;
        l_ctr_amount     NUMBER := 0;
        --variables added for bug 2776847 by jjhuang
        l_pay_period_id  cn_period_statuses.period_id%TYPE;
        l_rec_period_id  cn_period_statuses.period_id%TYPE;
        l_pmt_plan_count NUMBER := 0;
        -- varialve added for Bug 3140343
        l_ispayee NUMBER := 0;
        --Bug 3198445 by jjhuang
        l_applied_pgc       dbms_sql.varchar2_table;
        l_applied_pgc_count NUMBER;
    BEGIN
        --
        -- get quarter Number and Year Number
        --
        OPEN get_prd_statuses(p_period_id);

        FETCH get_prd_statuses
            INTO l_get_prd_statuses;

        CLOSE get_prd_statuses;

        -- Build dynamic sql for cursor
        l_stmt := 'SELECT v.pay_interval_type_id, v.recoverable_interval_type_id, ' || 'v.pay_against_commission, v.payment_group_code, v.minimum_amount, ' ||
                  'v.maximum_amount, v.min_rec_flag, v.max_rec_flag, v.name ' || 'FROM ' || '(SELECT ' || ' cnpp.pay_interval_type_id,' ||
                  ' cnpp.recoverable_interval_type_id,' || ' nvl(cnpp.pay_against_commission, ''Y'') pay_against_commission,' || ' cnpp.payment_group_code,' ||
                  ' cspp.minimum_amount,' || ' cnpp.min_rec_flag,' || ' cnpp.max_rec_flag,' || ' cspp.maximum_amount,' || ' cnps.period_id,' ||
                  ' cspp.salesrep_id,' || ' cnps.start_date prd_start_date,' || ' cnps.end_date prd_end_date,' || ' cnpp.name,' ||
                  ' ROW_NUMBER() over (PARTITION BY cnpp.payment_group_code' || '       ORDER BY cspp.start_date DESC) AS row_nums ,' || ' cnpp.credit_type_id' ||
                  ' FROM cn_srp_pmt_plans cspp,cn_pmt_plans cnpp,cn_period_statuses cnps ' || ' WHERE ' || ' cspp.salesrep_id = :p_salesrep_id' ||
                  ' AND cnpp.pmt_plan_id = cspp.pmt_plan_id ' || ' AND cnps.period_id   = :p_period_id' || ' AND cnpp.credit_type_id = -1000' ||
                  ' AND cspp.start_date <= cnps.end_date' ||
                 -- ' AND Nvl(cspp.end_date,cnps.start_date) >= cnps.start_date' ||
                 --bug 3395792 by jjhuang on 1/23/04
                 --' AND NVL(cspp.end_date, cnpp.end_date) >= cnps.end_date ' ||
                 --for bug 3395792 on 2/4/04 by jjhuang.  This is to include the following test case:
                 --If there are two or more payment plans (with the same payment group code) within one period, for example:
                 --pmt_plan1 from "01-MAY-2003" to "15-MAY-2003", pmt_plan2 from "16-MAY-2003" to "28-MAY-2003".
                  ' AND NVL(NVL(cspp.end_date, cnpp.end_date),cnps.start_date) >= cnps.start_date ' || ' AND cspp.org_id = cnpp.org_id ' || --R12
                  ' AND cnpp.org_id = cnps.org_id ' || --R12
                  ' AND cnps.org_id = :p_org_id ' || --R12
                  ' ) v           ' || ' WHERE row_nums = 1' || '  AND EXISTS' || '  (' || '   SELECT ''x''' ||
                  '   FROM cn_srp_period_quotas cspq, cn_quotas_all cq' || '   WHERE decode(:p_incentive_type,''ALL'', cq.incentive_type_code,' ||
                  '                NULL, cq.incentive_type_code,' || '                 :p_incentive_type) = cq.incentive_type_code' ||
                  '   AND v.credit_type_id = cq.credit_type_id' || '   AND v.payment_group_code = cq.payment_group_code' ||
                  '   AND v.salesrep_id = cspq.salesrep_id' || '   AND cspq.quota_id = cq.quota_id' || '   AND cspq.org_id = cq.org_id' ||
                  '   AND v.period_id = cspq.period_id ' || '   AND cspq.org_id = cq.org_id ' || --R12
                  '   AND cq.org_id = :p_org_id ' || --R12
                  '   AND cspq.quota_id NOT IN ' || '   ( SELECT spayee.quota_id ' || '   FROM cn_srp_payee_assigns spayee' ||
                  '   WHERE (spayee.salesrep_id = v.salesrep_id OR ' || '    spayee.payee_id = v.salesrep_id)' || '   AND v.prd_end_date >= spayee.start_date' ||
                  '    AND spayee.org_id = :p_org_id' || --R12
                  '   AND v.prd_start_date <= Nvl(spayee.end_date, v.prd_end_date) )' || ' )';
        -- Bug 3140343 : Payee Design. Check if this salesrep is a Payee
        l_ispayee := cn_api.is_payee(p_period_id => p_period_id, p_salesrep_id => p_salesrep_id, p_org_id => p_org_id);

        -- if not a payee
        IF l_ispayee <> 1
        THEN
            --
            -- get Payment plans
            --
            -- Find payment plans assigned to the rep for the current payrun
            -- period that match the payment group codes of the plan elements

            --      FOR srp_pmt_plan IN get_srp_pmt_plan LOOP

            --Bug 3198445 by jjhuang
            l_applied_pgc.DELETE;
            l_applied_pgc_count := 0;

            OPEN srp_pmt_plan_cur FOR l_stmt
                USING p_salesrep_id, p_period_id, p_org_id, p_incentive_type, p_incentive_type, p_org_id, p_org_id;

            LOOP
                FETCH srp_pmt_plan_cur
                    INTO srp_pmt_plan.pay_interval_type_id, srp_pmt_plan.recoverable_interval_type_id,
                    srp_pmt_plan.pay_against_commission, srp_pmt_plan.payment_group_code, srp_pmt_plan.minimum_amount,
                    srp_pmt_plan.maximum_amount, srp_pmt_plan.min_rec_flag, srp_pmt_plan.max_rec_flag, srp_pmt_plan.NAME;

                EXIT WHEN srp_pmt_plan_cur%NOTFOUND;
                --With payment plans.
                l_pmt_plan_count      := l_pmt_plan_count + 1;
                l_period_id           := p_period_id;
                l_pmt_amount_adj_rec  := 0;
                l_pmt_amount_adj_nrec := 0;

                --Bug 2776847 by jjhuang
                get_pay_rec_period_ids(p_period_id                    => p_period_id,
                                       p_quarter_num                  => l_get_prd_statuses.quarter_num,
                                       p_period_year                  => l_get_prd_statuses.period_year,
                                       p_pay_interval_type_id         => srp_pmt_plan.pay_interval_type_id,
                                       p_recoverable_interval_type_id => srp_pmt_plan.recoverable_interval_type_id,
                                       x_pay_period_id                => l_pay_period_id,
                                       x_rec_period_id                => l_rec_period_id,
                                       --R12
                                       p_org_id => p_org_id);
                --Bug 3198445 by jjhuang
                l_applied_pgc(l_applied_pgc_count) := srp_pmt_plan.payment_group_code;

                --Bug 2776847 by jjhuang
                --It's recovery period and pay period regardless of pay_against_commission = 'Y' or 'N', do payment plans.
                --IF 1.
                IF ((srp_pmt_plan.pay_against_commission = 'Y' OR srp_pmt_plan.pay_against_commission = 'N') AND l_period_id = l_pay_period_id AND
                   l_period_id = l_rec_period_id)
                THEN
                    proc_pmt_trans_by_pe(p_salesrep_id        => p_salesrep_id,
                                         p_incentive_type     => p_incentive_type,
                                         p_payrun_id          => p_payrun_id,
                                         p_payment_group_code => srp_pmt_plan.payment_group_code, --bug 3175375 by jjhuang.
                                         p_applied_pgc        => l_applied_pgc, --Bug 3198445 by jjhuang
                                         x_calc_rec_tbl       => x_calc_rec_tbl,
                                         --R12
                                         p_org_id => p_org_id);
                    --
                    -- get the start date and end date for the given period
                    --
                    l_qtr_num        := l_get_prd_statuses.quarter_num;
                    l_year_num       := l_get_prd_statuses.period_year;
                    l_period_set_id  := l_get_prd_statuses.period_set_id;
                    l_period_type_id := l_get_prd_statuses.period_type_id;
                    l_start_date     := l_get_prd_statuses.start_date;
                    l_end_date       := l_get_prd_statuses.end_date;

                    IF srp_pmt_plan.pay_interval_type_id = -1001 --interval is quarter
                    THEN
                        OPEN get_qtr_sdate(l_period_set_id, l_period_type_id, l_year_num, l_qtr_num);

                        FETCH get_qtr_sdate
                            INTO l_interval_sdate;

                        CLOSE get_qtr_sdate;

                        OPEN get_qtr_edate(l_period_set_id, l_period_type_id, l_year_num, l_qtr_num);

                        FETCH get_qtr_edate
                            INTO l_interval_edate;

                        CLOSE get_qtr_edate;
                    ELSIF srp_pmt_plan.pay_interval_type_id = -1002
                    THEN
                        OPEN get_year_sdate(l_period_set_id, l_period_type_id, l_year_num);

                        FETCH get_year_sdate
                            INTO l_interval_sdate;

                        CLOSE get_year_sdate;

                        OPEN get_year_edate(l_period_set_id, l_period_type_id, l_year_num);

                        FETCH get_year_edate
                            INTO l_interval_edate;

                        CLOSE get_year_edate;
                    ELSE
                        -- pay interval is period
                        l_interval_sdate := l_start_date;
                        l_interval_edate := l_end_date;
                    END IF;

                    l_itd_paid := 0;

                    --Get the cash paid interval to date
                    -- Bug 2875120 : combine 2 cursor and for loop into one
                    FOR amount IN get_itd_amount_paid(l_period_set_id, l_period_type_id, l_interval_sdate, l_interval_edate, srp_pmt_plan.payment_group_code)
                    LOOP
                        l_itd_paid := nvl(l_itd_paid, 0) + nvl(amount.payment, 0);
                    END LOOP;

                    -- Determine due amount for current payrun from payment transactions
                    -- Add earnings from current period
                    l_net_pre_pmtplan := 0;

                    OPEN get_earnings_total(srp_pmt_plan.payment_group_code);

                    FETCH get_earnings_total
                        INTO l_net_pre_pmtplan;

                    CLOSE get_earnings_total;

                    l_itd_paid := l_itd_paid + nvl(l_net_pre_pmtplan, 0);

                    IF srp_pmt_plan.minimum_amount IS NOT NULL
                       AND srp_pmt_plan.minimum_amount > l_itd_paid
                    THEN
                        IF nvl(srp_pmt_plan.min_rec_flag, 'N') = 'Y'
                        THEN
                            l_pmt_amount_adj_rec := srp_pmt_plan.minimum_amount - l_itd_paid;
                        ELSE
                            l_pmt_amount_adj_nrec := srp_pmt_plan.minimum_amount - l_itd_paid;
                        END IF;
                    END IF; -- End of minimum calculation

                    IF srp_pmt_plan.maximum_amount IS NOT NULL
                       AND srp_pmt_plan.maximum_amount < l_itd_paid
                    THEN
                        IF nvl(srp_pmt_plan.max_rec_flag, 'N') = 'Y'
                        THEN
                            l_pmt_amount_adj_rec := srp_pmt_plan.maximum_amount - l_itd_paid;
                        ELSE
                            l_pmt_amount_adj_nrec := srp_pmt_plan.maximum_amount - l_itd_paid;
                        END IF;
                    END IF; -- End of maximum calculation

                    --If payment plan adjustments exist, determine how to distribute them.
                    --In other words, do distribution evenly on all quotas on pay interval basis.
                    distribute_pmt_plan_amount(p_salesrep_id         => p_salesrep_id,
                                               p_pmt_amount_adj_rec  => l_pmt_amount_adj_rec,
                                               p_pmt_amount_adj_nrec => l_pmt_amount_adj_nrec,
                                               p_payment_group_code  => srp_pmt_plan.payment_group_code,
                                               p_period_id           => p_period_id,
                                               p_incentive_type      => p_incentive_type, --bug 3107646, issue 4
                                               x_calc_rec_tbl        => x_calc_rec_tbl,
                                               --R12
                                               p_org_id => p_org_id);
                ELSE
                    --not recovery period, but pay period, reset payrun_id to NULL. Give min as payment plan, then distribute it.
                    IF (srp_pmt_plan.pay_against_commission = 'N' AND l_period_id = l_pay_period_id AND l_period_id <> l_rec_period_id)
                    THEN
                        reset_payrun_id(p_payrun_id          => p_payrun_id,
                                        p_salesrep_id        => p_salesrep_id,
                                        p_incentive_type     => p_incentive_type,
                                        p_payment_group_code => srp_pmt_plan.payment_group_code);
                        proc_pmt_trans_by_pe(p_salesrep_id        => p_salesrep_id,
                                             p_incentive_type     => p_incentive_type,
                                             p_payrun_id          => p_payrun_id,
                                             p_payment_group_code => srp_pmt_plan.payment_group_code, --bug 3175375 by jjhuang.
                                             p_applied_pgc        => l_applied_pgc, --Bug 3198445 by jjhuang
                                             x_calc_rec_tbl       => x_calc_rec_tbl,
                                             --R12
                                             p_org_id => p_org_id);
                        give_min_as_pmt_plan(p_min                 => srp_pmt_plan.minimum_amount,
                                             p_min_rec_flag        => nvl(srp_pmt_plan.min_rec_flag, 'N'),
                                             x_pmt_amount_adj_rec  => l_pmt_amount_adj_rec,
                                             x_pmt_amount_adj_nrec => l_pmt_amount_adj_nrec);
                        get_start_and_end_dates(p_interval_type_id    => srp_pmt_plan.pay_interval_type_id,
                                                p_period_set_id       => l_get_prd_statuses.period_set_id,
                                                p_period_type_id      => l_get_prd_statuses.period_type_id,
                                                p_period_year         => l_get_prd_statuses.period_year,
                                                p_quarter_num         => l_get_prd_statuses.quarter_num,
                                                p_start_date          => l_get_prd_statuses.start_date,
                                                p_end_date            => l_get_prd_statuses.end_date,
                                                x_interval_start_date => l_interval_sdate,
                                                x_interval_end_date   => l_interval_edate,
                                                --R12
                                                p_org_id => p_org_id);
                        --Do distribution evenly on all quotas on pay interval basis.
                        distribute_pmt_plan_amount(p_salesrep_id         => p_salesrep_id,
                                                   p_pmt_amount_adj_rec  => l_pmt_amount_adj_rec,
                                                   p_pmt_amount_adj_nrec => l_pmt_amount_adj_nrec,
                                                   p_payment_group_code  => srp_pmt_plan.payment_group_code,
                                                   p_period_id           => p_period_id,
                                                   p_incentive_type      => p_incentive_type, --bug 3107646, issue 4
                                                   x_calc_rec_tbl        => x_calc_rec_tbl,
                                                   --R12
                                                   p_org_id => p_org_id);
                        --not pay period, reset payrun_id to NULL so those amount will be included into the next payrun.
                    ELSIF (srp_pmt_plan.pay_against_commission = 'N' AND l_period_id <> l_pay_period_id)
                    THEN
                        reset_payrun_id(p_payrun_id          => p_payrun_id,
                                        p_salesrep_id        => p_salesrep_id,
                                        p_incentive_type     => p_incentive_type,
                                        p_payment_group_code => srp_pmt_plan.payment_group_code);
                        proc_pmt_trans_by_pe(p_salesrep_id        => p_salesrep_id,
                                             p_incentive_type     => p_incentive_type,
                                             p_payrun_id          => p_payrun_id,
                                             p_payment_group_code => srp_pmt_plan.payment_group_code, --bug 3175375 by jjhuang.
                                             p_applied_pgc        => l_applied_pgc, --Bug 3198445 by jjhuang
                                             x_calc_rec_tbl       => x_calc_rec_tbl,
                                             --R12
                                             p_org_id => p_org_id);
                        --not recovery period for pay_against_commission = 'Y', so pay earnings.
                    ELSIF (srp_pmt_plan.pay_against_commission = 'Y' AND l_period_id <> l_rec_period_id)
                    THEN
                        proc_pmt_trans_by_pe(p_salesrep_id        => p_salesrep_id,
                                             p_incentive_type     => p_incentive_type,
                                             p_payrun_id          => p_payrun_id,
                                             p_payment_group_code => srp_pmt_plan.payment_group_code, --bug 3175375 by jjhuang.
                                             p_applied_pgc        => l_applied_pgc, --Bug 3198445 by jjhuang
                                             x_calc_rec_tbl       => x_calc_rec_tbl,
                                             --R12
                                             p_org_id => p_org_id);
                    END IF;
                END IF; --end of IF 1.

                --Bug 3198445 by jjhuang
                l_applied_pgc_count := l_applied_pgc_count + 1;
                NULL;
            END LOOP; --end of loop FOR srp_pmt_plan IN get_srp_pmt_plan

            CLOSE srp_pmt_plan_cur;
        END IF; -- end if l_ispayee <> 1

        --For Bug 2776847 by jjhuang.
        --If no payment plans assigned, we need to only get x_calc_rec_tbl to pay the earnings.
        -- Commented out by jjhuang for bug 3198445.
        --proc_pmt_trans_by_pe includes the case where no payment plans assigned.
        proc_pmt_trans_by_pe(p_salesrep_id        => p_salesrep_id,
                             p_incentive_type     => p_incentive_type,
                             p_payrun_id          => p_payrun_id,
                             p_payment_group_code => NULL, --bug 3175375 by jjhuang.
                             p_applied_pgc        => l_applied_pgc, --Bug 3198445 by jjhuang
                             x_calc_rec_tbl       => x_calc_rec_tbl,
                             --R12
                             p_org_id => p_org_id);
        -- Commented out by jjhuang for bug 3198445. END IF;
    END calculate_totals;

    -- ===========================================================================
    -- Procedure  : Create_Worksheet
    -- Description: Private API to create a payment worksheet
    -- ===========================================================================
    PROCEDURE create_worksheet
    (
        p_api_version      IN NUMBER,
        p_init_msg_list    IN VARCHAR2,
        p_commit           IN VARCHAR2,
        p_validation_level IN NUMBER,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,
        p_worksheet_rec    IN worksheet_rec_type,
        x_loading_status   OUT NOCOPY VARCHAR2,
        x_status           OUT NOCOPY VARCHAR2
    ) IS
        l_api_name CONSTANT VARCHAR2(30) := 'Create_Worksheet';
        l_payment_worksheet_id NUMBER;
        l_calc_pmt_amount      NUMBER;
        l_adj_pmt_amount_rec   NUMBER;
        l_adj_pmt_amount_nrec  NUMBER;
        l_held_amount          NUMBER;
        l_pay_element_type_id  NUMBER;
        l_quota_id             NUMBER;
        l_count                NUMBER := 0;
        l_payroll_flag         VARCHAR2(01);
        l_period_id            NUMBER;
        l_pbt_profile_value    VARCHAR2(01) := 'N';
        l_calc_rec_tbl         calc_rec_tbl_type;
        cls_posting_batch_id   NUMBER;
        recv_posting_batch_id  NUMBER;
        l_pmt_amount_rec       NUMBER := 0;
        l_pmt_amount_ctr       NUMBER := 0;
        l_incentive_type       VARCHAR2(30);
        l_rowid                VARCHAR2(30);
        l_srp_total            NUMBER;
        l_pmt_total            NUMBER;
        l_comm_total           NUMBER;
        l_found                NUMBER;
        l_call_from            VARCHAR2(30);
        TYPE num_tab IS TABLE OF NUMBER;
        l_wk_plan_elements num_tab;

        -- changes for bug#2568937
        -- for ap integration population of account
        l_payables_flag       cn_repositories.payables_flag%TYPE;
        l_payables_ccid_level cn_repositories.payables_ccid_level%TYPE;

        -- changes for bug#2568937
        -- for ap integration population of account
        --R12
        CURSOR get_apps IS
            SELECT payables_flag,
                   payroll_flag,
                   payables_ccid_level
              FROM cn_repositories
             WHERE org_id = p_worksheet_rec.org_id;

        CURSOR get_worksheet IS
            SELECT 1
              FROM cn_payment_worksheets,
                   cn_payruns
             WHERE cn_payment_worksheets.salesrep_id = p_worksheet_rec.salesrep_id
               AND cn_payment_worksheets.payrun_id = cn_payruns.payrun_id
               AND quota_id IS NULL
               AND cn_payruns.status <> 'PAID';

        err_num NUMBER;

        -- Get the Payrun informations
        CURSOR get_payrun IS
            SELECT payrun_id,
                   pay_period_id,
                   incentive_type_code,
                   pay_date
              FROM cn_payruns
             WHERE payrun_id = p_worksheet_rec.payrun_id
               FOR UPDATE NOWAIT;

       -- Get the Payrun informations for conc program
        CURSOR get_payrun_for_conc_program IS
            SELECT payrun_id,
                   pay_period_id,
                   incentive_type_code,
                   pay_date
              FROM cn_payruns
             WHERE payrun_id = p_worksheet_rec.payrun_id;

        -- Get the period information
        CURSOR get_prd_statuses(p_period_id NUMBER) IS
            SELECT quarter_num,
                   period_year,
                   period_set_id,
                   period_type_id,
                   start_date,
                   end_date
              FROM cn_period_statuses
             WHERE period_id = p_period_id
               AND org_id = p_worksheet_rec.org_id;

        CURSOR get_srp_total(p_period_id NUMBER) IS
            SELECT nvl(SUM(nvl(srp.balance2_dtd, 0) - nvl(srp.balance2_ctd, 0) + nvl(srp.balance2_bbd, 0) - nvl(srp.balance2_bbc, 0)), 0)
              FROM cn_srp_periods srp
             WHERE srp.period_id = p_period_id
               AND srp.salesrep_id = p_worksheet_rec.salesrep_id
               AND srp.credit_type_id = g_credit_type_id
               AND quota_id IS NULL
               AND org_id = p_worksheet_rec.org_id;

        CURSOR get_pmt_total(p_period_id NUMBER) IS
            SELECT nvl(SUM(nvl(amount, 0)), 0)
              FROM cn_payment_transactions pmt
             WHERE pmt.pay_period_id <= p_period_id
               AND pmt.credited_salesrep_id = p_worksheet_rec.salesrep_id
               AND pmt.credit_type_id = g_credit_type_id
               AND pmt.incentive_type_code IN ('COMMISSION', 'BONUS')
               AND (pmt.payrun_id IS NULL OR pmt.payrun_id = p_worksheet_rec.payrun_id)
                  --R12
               AND pmt.org_id = p_worksheet_rec.org_id;

        -- 12/27/04 : Bug 4090737 Performance Issue Creating Worksheet START
        CURSOR get_comm_total(p_period_id NUMBER) IS
            SELECT
             nvl(SUM(nvl(commission_amount, 0)), 0)
              FROM cn_commission_lines_all ccl
             WHERE credited_salesrep_id = p_worksheet_rec.salesrep_id
               AND processed_period_id <= p_period_id
               AND credit_type_id = g_credit_type_id
               AND status = 'CALC'
               AND posting_status = 'UNPOSTED'
               AND srp_payee_assign_id IS NULL
                  -- posting_status not set to posted yet
               AND NOT EXISTS (SELECT NULL
                      FROM cn_payment_transactions_all pmt
                     WHERE pmt.credited_salesrep_id = ccl.credited_salesrep_id
                       AND pmt.commission_line_id = ccl.commission_line_id
                       AND pmt.credit_type_id = ccl.credit_type_id
                       AND pmt.incentive_type_code IN ('COMMISSION', 'BONUS')
                       AND pmt.payrun_id = p_worksheet_rec.payrun_id)
               AND ccl.org_id = p_worksheet_rec.org_id;

        -- 12/27/04 : Bug 4090737 Performance Issue Creating Worksheet END

        -- Bug 3140343 : Payee Design
        CURSOR get_comm_total_payee(p_period_id NUMBER) IS
            SELECT /*+ index(cl CN_COMMISSION_LINES_N14) */
             nvl(SUM(nvl(commission_amount, 0)), 0)
              FROM cn_commission_lines      cl,
                   cn_srp_payee_assigns_all spayee
             WHERE cl.srp_payee_assign_id IS NOT NULL
               AND cl.srp_payee_assign_id = spayee.srp_payee_assign_id
               AND spayee.payee_id = p_worksheet_rec.salesrep_id
               AND cl.credited_salesrep_id = spayee.salesrep_id
               AND cl.processed_period_id <= p_period_id
               AND cl.status = 'CALC'
               AND cl.credit_type_id = g_credit_type_id
               AND cl.posting_status = 'UNPOSTED'
               AND cl.org_id = spayee.org_id
               AND cl.commission_line_id NOT IN (SELECT pmt.commission_line_id
                                                   FROM cn_payment_transactions pmt
                                                  WHERE pmt.credited_salesrep_id = p_worksheet_rec.salesrep_id
                                                    AND pmt.credit_type_id = g_credit_type_id
                                                    AND pmt.incentive_type_code IN ('COMMISSION', 'BONUS')
                                                    AND pmt.payrun_id = p_worksheet_rec.payrun_id)
                  --R12
               AND cl.org_id = p_worksheet_rec.org_id
               AND spayee.org_id = p_worksheet_rec.org_id;

        CURSOR get_worksheet_id IS
            SELECT payment_worksheet_id
              FROM cn_payment_worksheets
             WHERE payrun_id = p_worksheet_rec.payrun_id
               AND salesrep_id = p_worksheet_rec.salesrep_id
               AND quota_id IS NULL;

        l_get_payrun_rec   get_payrun%ROWTYPE; -- Payrun
        l_get_prd_statuses get_prd_statuses%ROWTYPE; -- Period
        l_pmt_trans_rec    cn_pmt_trans_pkg.pmt_trans_rec_type; -- PmtTrans
        l_batch_rec        cn_prepostbatches.posting_batch_rec_type;
        l_tmp              NUMBER := 0;
        l_calc_status      cn_srp_intel_periods.processing_status_code%TYPE;
        l_ispayee          NUMBER := 0;
        l_has_access       BOOLEAN;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT create_worksheet;

        -- Standard call to check for call compatibility.
        IF NOT fnd_api.compatible_api_call(g_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF fnd_api.to_boolean(p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status  := fnd_api.g_ret_sts_success;
        x_loading_status := 'CN_INSERTED';
        --Added for R12 payment security check begin.
        l_has_access := cn_payment_security_pvt.get_security_access(cn_payment_security_pvt.g_type_wksht, cn_payment_security_pvt.g_access_wksht_create);

        IF (l_has_access = FALSE)
        THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        -- API body
        -- The following validations are performed by this API
        -- Check for the following mandatory parameters payrun_id, salesrep_id,
        -- Pay run should be unpaid
        -- Salesrep should not be on hold -cn_salesreps.hold_payment
        -- Subledger entry should exist for salesrep,  credit_type and period
        -- cn_srp_periods
        -- Mandatory parameters check for payrun_id, salesrep_id
        IF ((cn_api.chk_miss_null_num_para(p_num_para       => p_worksheet_rec.payrun_id,
                                           p_obj_name       => cn_api.get_lkup_meaning('PAY_RUN_NAME', 'PAY_RUN_VALIDATION_TYPE'),
                                           p_loading_status => x_loading_status,
                                           x_loading_status => x_loading_status)) = fnd_api.g_true)
        THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        IF ((cn_api.chk_miss_null_num_para(p_num_para       => p_worksheet_rec.salesrep_id,
                                           p_obj_name       => cn_api.get_lkup_meaning('SALES_PERSON', 'PAY_RUN_VALIDATION_TYPE'),
                                           p_loading_status => x_loading_status,
                                           x_loading_status => x_loading_status)) = fnd_api.g_true)
        THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        -- Check Payrun Status
        IF cn_api.chk_payrun_status_paid(p_payrun_id => p_worksheet_rec.payrun_id, p_loading_status => x_loading_status, x_loading_status => x_loading_status) =
           fnd_api.g_true
        THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        -- Check if the salesrep is on hold
        IF cn_api.chk_srp_hold_status(p_salesrep_id => p_worksheet_rec.salesrep_id,
                                      --R12
                                      p_org_id         => p_worksheet_rec.org_id,
                                      p_loading_status => x_loading_status,
                                      x_loading_status => x_loading_status) = fnd_api.g_true
        THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        -- Get the Payrun
        BEGIN
            l_call_from := p_worksheet_rec.call_from;

            IF l_call_from = cn_payment_worksheet_pvt.concurrent_program_call
            THEN
                OPEN get_payrun_for_conc_program;
                FETCH get_payrun_for_conc_program
                    INTO l_get_payrun_rec;
                CLOSE get_payrun_for_conc_program;
            ELSE
                OPEN get_payrun;
                FETCH get_payrun
                    INTO l_get_payrun_rec;
                CLOSE get_payrun;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                err_num := SQLCODE;
                IF l_call_from = cn_payment_worksheet_pvt.concurrent_program_call
                THEN
                    CLOSE get_payrun_for_conc_program;
                ELSE
                    CLOSE get_payrun;
                END IF;

                IF err_num = -54
                THEN
                    fnd_message.set_name('CN', 'CN_INVALID_OBJECT_VERSION');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_error;
                ELSE
                    RAISE;
                END IF;
        END;

        -- fix for bug 5334261
        OPEN get_worksheet;
        FETCH get_worksheet
            INTO l_found;
        CLOSE get_worksheet;

        IF l_found = 1
        THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
            THEN
                fnd_message.set_name('CN', 'CN_DUPLICATE_WORKSHEET');
                fnd_msg_pub.add;
            END IF;

            x_loading_status := 'CN_DUPLICATE_WORKSHEET';
            RAISE fnd_api.g_exc_error;
        END IF;

        -- Get the Pay By Summary Profile value
        -- N - Pay by Summary Y - Pay by Transaction
        l_pbt_profile_value := cn_payment_security_pvt.get_pay_by_mode(p_worksheet_rec.payrun_id);

        -- Bug 3140343 : Payee Design. Check if this salesrep is a Payee
        l_ispayee := cn_api.is_payee(p_period_id   => l_get_payrun_rec.pay_period_id,
                                     p_salesrep_id => p_worksheet_rec.salesrep_id,
                                     p_org_id      => p_worksheet_rec.org_id);

        -- Check duplicate worksheet
        IF cn_api.chk_duplicate_worksheet(p_payrun_id      => p_worksheet_rec.payrun_id,
                                          p_salesrep_id    => p_worksheet_rec.salesrep_id,
                                          p_org_id         => p_worksheet_rec.org_id,
                                          p_loading_status => x_loading_status,
                                          x_loading_status => x_loading_status) = fnd_api.g_true
        THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        -- get quarter Number and Year Number
        OPEN get_prd_statuses(l_get_payrun_rec.pay_period_id);

        FETCH get_prd_statuses
            INTO l_get_prd_statuses;

        CLOSE get_prd_statuses;

        -- get the posting batch id
        SELECT cn_posting_batches_s.NEXTVAL
          INTO cls_posting_batch_id
          FROM dual;

        -- if the payrun incentive type code is ALL
        -- we will set the incentive type as NULL
        -- which means we will get both Bonus and Commissions
        IF l_get_payrun_rec.incentive_type_code = 'ALL'
        THEN
            l_incentive_type := NULL;
        ELSE
            l_incentive_type := l_get_payrun_rec.incentive_type_code;
        END IF;

        -- Main Insert started for Create Worksheet
        -- Call the Table hander to Insert Records
        cn_pmt_trans_pkg.insert_record(p_pay_by_transaction => nvl(l_pbt_profile_value, 'N'),
                                       p_salesrep_id        => p_worksheet_rec.salesrep_id,
                                       p_payrun_id          => p_worksheet_rec.payrun_id,
                                       p_pay_date           => l_get_payrun_rec.pay_date,
                                       p_incentive_type     => l_incentive_type,
                                       p_pay_period_id      => l_get_payrun_rec.pay_period_id,
                                       p_credit_type_id     => g_credit_type_id,
                                       p_posting_batch_id   => cls_posting_batch_id,
                                       p_org_id             => p_worksheet_rec.org_id);

        -- Bug 2760379 : only check bal mismatch when it's pay by trx
        -- check Balance Miss Match
        IF l_pbt_profile_value = 'Y'
        THEN
            OPEN get_srp_total(l_get_payrun_rec.pay_period_id);

            FETCH get_srp_total
                INTO l_srp_total;

            CLOSE get_srp_total;

            OPEN get_pmt_total(l_get_payrun_rec.pay_period_id);

            FETCH get_pmt_total
                INTO l_pmt_total;

            CLOSE get_pmt_total;

            -- Bug 3140343 : Payee Design.
            IF l_ispayee <> 1
            THEN
                -- 08/26/03 : Bug 3114349 Issue 2
                OPEN get_comm_total(l_get_payrun_rec.pay_period_id);

                FETCH get_comm_total
                    INTO l_comm_total;

                CLOSE get_comm_total;
            ELSE
                OPEN get_comm_total_payee(l_get_payrun_rec.pay_period_id);

                FETCH get_comm_total_payee
                    INTO l_comm_total;

                CLOSE get_comm_total_payee;
            END IF;

            IF abs(nvl(l_srp_total, 0) - nvl(l_pmt_total, 0) - nvl(l_comm_total, 0)) > .1
            THEN
                SELECT processing_status_code
                  INTO l_calc_status
                  FROM cn_srp_intel_periods
                 WHERE salesrep_id = p_worksheet_rec.salesrep_id
                   AND period_id = l_get_payrun_rec.pay_period_id
                   AND org_id = p_worksheet_rec.org_id;

                IF l_calc_status NOT IN ('CALCULATED', 'CLEAN', 'ROLLED_UP')
                THEN
                    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
                    THEN
                        fnd_message.set_name('CN', 'CN_CALC_NOT_COMPLETE');
                        fnd_msg_pub.add;
                    END IF;

                    x_loading_status := 'CN_CALC_NOT_COMPLETE';
                    RAISE fnd_api.g_exc_error;
                END IF;

                IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
                THEN
                    fnd_message.set_name('CN', 'CN_WKSHT_SRP_COMM_MISMATCH');
                    fnd_msg_pub.add;
                END IF;

                x_loading_status := 'CN_WKSHT_SRP_COMM_MISMATCH';
                RAISE fnd_api.g_exc_error;
            END IF; -- end if ABS() > .1
        END IF; --end if l_pbt_profile_value = 'Y'

        -- calculate values for payment plan records
        calculate_totals(p_salesrep_id    => p_worksheet_rec.salesrep_id,
                         p_period_id      => l_get_payrun_rec.pay_period_id,
                         p_incentive_type => l_incentive_type,
                         p_payrun_id      => l_get_payrun_rec.payrun_id,
                         x_calc_rec_tbl   => l_calc_rec_tbl,
                         --R12
                         p_org_id => p_worksheet_rec.org_id);

        -- Bug 2692801 : avoid PL/SQL error when l_calc_rec_tbl is null
        IF l_calc_rec_tbl.COUNT > 0
        THEN
            FOR i IN l_calc_rec_tbl.FIRST .. l_calc_rec_tbl.LAST
            LOOP
                IF l_calc_rec_tbl(i).quota_id IS NOT NULL
                THEN
                    IF l_calc_rec_tbl(i).pmt_amount_adj_rec <> 0
                       OR l_calc_rec_tbl(i).pmt_amount_adj_nrec <> 0
                    THEN
                        -- Bug 2880233:  should find pay_element for PMTPLN base on quota_id

                        -- IF l_calc_rec_tbl(i).pmt_amount_adj_rec <> 0  THEN
                        l_pay_element_type_id := cn_api.get_pay_element_id(l_calc_rec_tbl(i).quota_id,
                                                                           p_worksheet_rec.salesrep_id,
                                                                           --R12
                                                                           p_worksheet_rec.org_id,
                                                                           l_get_payrun_rec.pay_date);

                        -- Get the Sequence Number
                        SELECT cn_posting_batches_s.NEXTVAL
                          INTO recv_posting_batch_id
                          FROM dual;

                        l_batch_rec.posting_batch_id  := recv_posting_batch_id;
                        l_batch_rec.NAME              := 'PMTPLN batch number:' || l_get_payrun_rec.payrun_id || ':' || p_worksheet_rec.salesrep_id || ':' ||
                                                         l_calc_rec_tbl(i).quota_id || ':' || recv_posting_batch_id;
                        l_batch_rec.created_by        := fnd_global.user_id;
                        l_batch_rec.creation_date     := SYSDATE;
                        l_batch_rec.last_updated_by   := fnd_global.user_id;
                        l_batch_rec.last_update_date  := SYSDATE;
                        l_batch_rec.last_update_login := fnd_global.login_id;
                        -- Create the Posting Batches
                        cn_prepostbatches.begin_record(x_operation         => 'INSERT',
                                                       x_rowid             => l_rowid,
                                                       x_posting_batch_rec => l_batch_rec,
                                                       x_program_type      => NULL,
                                                       p_org_id            => p_worksheet_rec.org_id);
                        l_pmt_trans_rec.posting_batch_id     := recv_posting_batch_id;
                        l_pmt_trans_rec.incentive_type_code  := 'PMTPLN';
                        l_pmt_trans_rec.credit_type_id       := g_credit_type_id;
                        l_pmt_trans_rec.payrun_id            := p_worksheet_rec.payrun_id;
                        l_pmt_trans_rec.credited_salesrep_id := p_worksheet_rec.salesrep_id;
                        l_pmt_trans_rec.payee_salesrep_id    := p_worksheet_rec.salesrep_id;
                        l_pmt_trans_rec.pay_period_id        := l_get_payrun_rec.pay_period_id;
                        l_pmt_trans_rec.hold_flag            := 'N';
                        l_pmt_trans_rec.waive_flag           := 'N';
                        l_pmt_trans_rec.paid_flag            := 'N';
                        l_pmt_trans_rec.recoverable_flag     := 'N';
                        l_pmt_trans_rec.pay_element_type_id  := l_pay_element_type_id;
                        l_pmt_trans_rec.quota_id             := l_calc_rec_tbl(i).quota_id;
                        l_pmt_trans_rec.amount               := nvl(l_calc_rec_tbl(i).pmt_amount_adj_rec, 0) + nvl(l_calc_rec_tbl(i).pmt_amount_adj_nrec, 0);
                        l_pmt_trans_rec.payment_amount       := nvl(l_calc_rec_tbl(i).pmt_amount_adj_rec, 0) + nvl(l_calc_rec_tbl(i).pmt_amount_adj_nrec, 0);
                        --R12
                        l_pmt_trans_rec.org_id                := p_worksheet_rec.org_id;
                        l_pmt_trans_rec.object_version_number := 1;
                        -- Create the Payment Plan Record
                        cn_pmt_trans_pkg.insert_record(p_tran_rec => l_pmt_trans_rec);
                    END IF;

                    IF l_calc_rec_tbl(i).quota_id <> -1000
                       OR abs(nvl(l_calc_rec_tbl(i).pmt_amount_calc, 0)) + abs(nvl(l_calc_rec_tbl(i).pmt_amount_adj_rec, 0)) +
                       abs(nvl(l_calc_rec_tbl(i).pmt_amount_adj_nrec, 0)) + abs(nvl(l_calc_rec_tbl(i).pmt_amount_ctr, 0)) +
                       abs(nvl(l_calc_rec_tbl(i).pmt_amount_rec, 0)) + abs(nvl(l_calc_rec_tbl(i).held_amount, 0)) <> 0
                    THEN
                        -- Create the Worksheet at the Quota Level
                        cn_payment_worksheets_pkg.insert_record(x_payrun_id             => p_worksheet_rec.payrun_id,
                                                                x_salesrep_id           => p_worksheet_rec.salesrep_id,
                                                                x_quota_id              => l_calc_rec_tbl(i).quota_id,
                                                                x_credit_type_id        => g_credit_type_id,
                                                                x_calc_pmt_amount       => nvl(l_calc_rec_tbl(i).pmt_amount_calc, 0),
                                                                x_adj_pmt_amount_rec    => nvl(l_calc_rec_tbl(i).pmt_amount_adj_rec, 0),
                                                                x_adj_pmt_amount_nrec   => nvl(l_calc_rec_tbl(i).pmt_amount_adj_nrec, 0),
                                                                x_adj_pmt_amount        => nvl(l_calc_rec_tbl(i).pmt_amount_ctr, 0),
                                                                x_held_amount           => nvl(l_calc_rec_tbl(i).held_amount, 0),
                                                                x_pmt_amount_recovery   => nvl(l_calc_rec_tbl(i).pmt_amount_rec, 0),
                                                                x_worksheet_status      => 'UNPAID',
                                                                x_created_by            => fnd_global.user_id,
                                                                x_creation_date         => SYSDATE,
                                                                p_org_id                => p_worksheet_rec.org_id,
                                                                p_object_version_number => 1);
                        x_loading_status := 'CN_INSERTED';
                    END IF;
                END IF;

                -- for summary record
                l_calc_pmt_amount     := nvl(l_calc_pmt_amount, 0) + nvl(l_calc_rec_tbl(i).pmt_amount_calc, 0);
                l_adj_pmt_amount_rec  := nvl(l_adj_pmt_amount_rec, 0) + nvl(l_calc_rec_tbl(i).pmt_amount_adj_rec, 0);
                l_adj_pmt_amount_nrec := nvl(l_adj_pmt_amount_nrec, 0) + nvl(l_calc_rec_tbl(i).pmt_amount_adj_nrec, 0);
                l_pmt_amount_rec      := nvl(l_pmt_amount_rec, 0) + nvl(l_calc_rec_tbl(i).pmt_amount_rec, 0);
                l_held_amount         := nvl(l_held_amount, 0) + nvl(l_calc_rec_tbl(i).held_amount, 0);
            END LOOP;
        END IF; -- end  IF l_calc_rec_tbl.COUNT > 0 THEN

        -- Create the Summary Record for for each salesrep
        x_loading_status := 'CN_INSERTED';

        -- BUG 2774167 : Check duplicate summary worksheet
        BEGIN
            l_tmp := 0;

            SELECT 1
              INTO l_tmp
              FROM cn_payment_worksheets
             WHERE payrun_id = p_worksheet_rec.payrun_id
               AND salesrep_id = p_worksheet_rec.salesrep_id
               AND quota_id IS NULL;

            IF l_tmp <> 0
            THEN
                --Error condition
                IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
                THEN
                    fnd_message.set_name('CN', 'CN_DUPLICATE_WORKSHEET');
                    fnd_msg_pub.add;
                END IF;

                x_loading_status := 'CN_DUPLICATE_WORKSHEET';
                RAISE fnd_api.g_exc_error;
            END IF;
        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;

        -- Create the Summary Record in the Worksheet
        cn_payment_worksheets_pkg.insert_record(x_payrun_id             => p_worksheet_rec.payrun_id,
                                                x_salesrep_id           => p_worksheet_rec.salesrep_id,
                                                x_credit_type_id        => g_credit_type_id,
                                                x_calc_pmt_amount       => nvl(l_calc_pmt_amount, 0),
                                                x_adj_pmt_amount_rec    => nvl(l_adj_pmt_amount_rec, 0),
                                                x_adj_pmt_amount_nrec   => nvl(l_adj_pmt_amount_nrec, 0),
                                                x_adj_pmt_amount        => nvl(l_pmt_amount_ctr, 0),
                                                x_held_amount           => nvl(l_held_amount, 0),
                                                x_pmt_amount_recovery   => nvl(l_pmt_amount_rec, 0),
                                                x_worksheet_status      => 'UNPAID',
                                                x_created_by            => fnd_global.user_id,
                                                x_creation_date         => SYSDATE,
                                                p_org_id                => p_worksheet_rec.org_id,
                                                p_object_version_number => 1);

        IF x_loading_status <> 'CN_INSERTED'
        THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        OPEN get_worksheet_id;

        FETCH get_worksheet_id
            INTO l_payment_worksheet_id;

        CLOSE get_worksheet_id;

       update_ptd_details (
   	     p_salesrep_id => p_worksheet_rec.salesrep_id ,
   	     p_payrun_id   => p_worksheet_rec.payrun_id
       ) ;

        -- Bug 3140343 : Payee Design.
        IF l_ispayee <> 1
        THEN
            x_loading_status := 'CN_INSERTED';
        END IF;

        -- Bug 3140343 : Payee Design. set commission_lines to POSTED
        IF l_pbt_profile_value = 'Y'
        THEN
            IF l_ispayee <> 1
            THEN
                UPDATE cn_commission_lines cls
                   SET posting_status    = 'POSTED',
                       last_update_date  = SYSDATE,
                       last_updated_by   = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                 WHERE posting_status <> 'POSTED'
                   AND status = 'CALC'
                   AND srp_payee_assign_id IS NULL
                   AND commission_line_id IN (SELECT commission_line_id
                                                FROM cn_payment_transactions
                                               WHERE posting_batch_id = cls_posting_batch_id
                                                 AND commission_line_id IS NOT NULL);
            ELSE
                --payee
                UPDATE cn_commission_lines cls
                   SET posting_status    = 'POSTED',
                       last_update_date  = SYSDATE,
                       last_updated_by   = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                 WHERE posting_status <> 'POSTED'
                   AND status = 'CALC'
                   AND srp_payee_assign_id IS NOT NULL
                   AND commission_line_id IN (SELECT commission_line_id
                                                FROM cn_payment_transactions
                                               WHERE posting_batch_id = cls_posting_batch_id
                                                 AND commission_line_id IS NOT NULL);
            END IF;

        ELSE

            SELECT DISTINCT pw.quota_id
             BULK COLLECT INTO l_wk_plan_elements
              FROM cn_payment_worksheets pw
             WHERE pw.payrun_id = l_get_payrun_rec.payrun_id
               AND pw.salesrep_id = p_worksheet_rec.salesrep_id
               AND pw.quota_id IS NOT NULL ;

            --PBS
            IF l_ispayee <> 1
            THEN

                    FORALL m IN 1..l_wk_plan_elements.COUNT
                        UPDATE cn_commission_lines cls
                           SET posting_status    = 'POSTED',
                               last_update_date  = SYSDATE,
                               last_updated_by   = fnd_global.user_id,
                               last_update_login = fnd_global.login_id
                         WHERE posting_status <> 'POSTED'
                           AND credit_type_id = g_credit_type_id
                           AND processed_period_id <= l_get_payrun_rec.pay_period_id
                           AND status = 'CALC'
                           AND srp_payee_assign_id IS NULL
                           AND credited_salesrep_id = p_worksheet_rec.salesrep_id
                           AND quota_id = l_wk_plan_elements(m) ;

            ELSE

                UPDATE cn_commission_lines clk
                   SET posting_status    = 'POSTED',
                       last_update_date  = SYSDATE,
                       last_updated_by   = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                 WHERE processed_period_id <= l_get_payrun_rec.pay_period_id
                   AND status = 'CALC'
                   AND credit_type_id = g_credit_type_id
                   AND posting_status <> 'POSTED'
                   AND org_id = p_worksheet_rec.org_id
                   AND clk.srp_payee_assign_id IS NOT NULL
                   AND EXISTS (SELECT 1
                          FROM cn_srp_payee_assigns_all spayee,
                               cn_payment_worksheets    wksht
                         WHERE clk.srp_payee_assign_id = spayee.srp_payee_assign_id
                           AND spayee.quota_id = wksht.quota_id
                           AND spayee.payee_id = p_worksheet_rec.salesrep_id
                           AND wksht.payrun_id = l_get_payrun_rec.payrun_id
                           AND wksht.salesrep_id = p_worksheet_rec.salesrep_id);

            END IF; -- end IF l_ispayee <> 1
        END IF; -- end IF l_pbt_profile_value = 'Y'

        -- changes for bug#2568937
        -- for payroll integration population of account
        OPEN get_apps;

        FETCH get_apps
            INTO l_payables_flag, l_payroll_flag, l_payables_ccid_level;

        CLOSE get_apps;

        -- changes for bug#2568937
        -- for payroll integration population of account
        -- use if AP / Payroll integration has been enabled.
        IF l_payables_flag = 'Y'
        THEN
            -- Populate ccid's in payment worksheets
            IF (cn_payrun_pvt.populate_ccids(p_payrun_id      => p_worksheet_rec.payrun_id,
                                             p_salesrep_id    => p_worksheet_rec.salesrep_id,
                                             p_loading_status => x_loading_status,
                                             x_loading_status => x_loading_status)) = fnd_api.g_true
            THEN
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;

        -- End of API body.
        -- Standard check of p_commit.
        IF fnd_api.to_boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        --
        -- Standard call to get message count and if count is 1, get message info.
        --
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            ROLLBACK TO create_worksheet;
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO create_worksheet;
            x_loading_status := 'UNEXPECTED_ERR';
            x_return_status  := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
        WHEN OTHERS THEN
            ROLLBACK TO create_worksheet;
            x_loading_status := 'UNEXPECTED_ERR';
            x_return_status  := fnd_api.g_ret_sts_unexp_error;

            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
                fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
            END IF;

            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
    END create_worksheet;

    -- ===========================================================================
    -- Procedure   : Create_Multiple_Worksheets
    -- Description : This API is used to create multiple worksheets
    -- ===========================================================================
    PROCEDURE create_multiple_worksheets (
              errbuf             OUT NOCOPY VARCHAR2,
              retcode            OUT NOCOPY NUMBER,
              p_batch_id         IN NUMBER,
              p_payrun_id        IN NUMBER,
              p_logical_batch_id IN NUMBER,
              --R12
              p_org_id                   IN       cn_payruns.org_id%TYPE
           )
           IS
              l_api_name           CONSTANT VARCHAR2 (30) := 'Create_Multiple_Worksheets';
              g_api_version        CONSTANT NUMBER := 1.0;
              x_return_status  VARCHAR2(10) := fnd_api.g_ret_sts_success;
              x_msg_count      NUMBER;
              x_msg_data       VARCHAR2(4000);
              l_worksheet_rec  cn_payment_worksheet_pvt.worksheet_rec_type;
              x_status         VARCHAR2(200);
              x_loading_status VARCHAR2(20) := 'CN_INSERTED';
              l_start_time     DATE;
              l_error_count    NUMBER := 0;

              --Cursor below was modified by Sundar Venkat to fix bug 2775288
              --The following change is made to ensure, that worksheets are created
              --only for those salesreps, who have a valid comp. plan assignment
              --during the payperiod of the payrun
              -- Bug 3140343 : Payee Design.
          BEGIN
              --
              --  Initialize API return status to success
              --
              x_return_status := fnd_api.g_ret_sts_success;
              x_loading_status := 'CN_INSERTED';
              --
              -- API body
              --
              l_start_time := SYSDATE;
              fnd_file.put_line(fnd_file.log, '  Input Parameters Payrun_id = ' || p_payrun_id);
              fnd_file.put_line(fnd_file.log, '  Input Parameters Batch_id  = ' || p_batch_id);
              fnd_file.put_line(fnd_file.log, '  Current time               = ' || to_char(l_start_time, 'Dy DD-Mon-YYYY HH24:MI:SS'));

              l_worksheet_rec.payrun_id := p_payrun_id;
              l_worksheet_rec.org_id := p_org_id;
              l_worksheet_rec.call_from   := cn_payment_worksheet_pvt.concurrent_program_call;

                FOR emp IN (SELECT salesrep_id
                            FROM cn_process_batches
                            WHERE logical_batch_id = p_logical_batch_id
                            AND physical_batch_id = p_batch_id)
                LOOP

                    -- Run create worksheet for this salesrep.
                    l_worksheet_rec.salesrep_id := emp.salesrep_id;
                    l_worksheet_rec.call_from   := cn_payment_worksheet_pvt.concurrent_program_call;

                    fnd_file.put_line(fnd_file.log, '    Create worksheet for  = ' || l_worksheet_rec.salesrep_id || ' salesrepID');

                    cn_payment_worksheet_pvt.create_worksheet(p_api_version      => 1.0,
                                                              p_init_msg_list    => 'T',
                                                              p_commit           => 'F',
                                                              p_validation_level => fnd_api.g_valid_level_full,
                                                              x_return_status    => x_return_status,
                                                              x_msg_count        => x_msg_count,
                                                              x_msg_data         => x_msg_data,
                                                              p_worksheet_rec    => l_worksheet_rec,
                                                              x_loading_status   => x_loading_status,
                                                              x_status           => x_status);

                    IF x_return_status <> fnd_api.g_ret_sts_success
                    THEN
                        l_error_count := l_error_count + 1;
                        cn_message_pkg.debug('Error when creating Worksheet for :  ' || l_worksheet_rec.salesrep_id);
                        fnd_file.put_line(fnd_file.log, 'Failed to create worksheet for ' || l_worksheet_rec.salesrep_id);
                        FOR i IN 1 .. x_msg_count
                        LOOP
                            fnd_file.put_line(fnd_file.log, 'msg: ' || fnd_msg_pub.get(i, 'F'));
                        END LOOP;
                        fnd_file.put_line(fnd_file.log, '+------------------------------+');
                        ROLLBACK;
                    ELSE
                        COMMIT;
                    END IF;

                END LOOP;


           IF l_error_count <> 0
                THEN
                    retcode := 2;
                    errbuf  := '  Batch# '||p_batch_id||' : Creation of worksheets was not successful for some resources. Count = ' || to_char(l_error_count) ;
                    fnd_file.put_line(fnd_file.log,errbuf) ;
                END IF;

                fnd_file.put_line(fnd_file.log, '  Finish time = ' || to_char(SYSDATE, 'Dy DD-Mon-YYYY HH24:MI:SS'));
                fnd_file.put_line(fnd_file.log, '  Batch time  = ' || (SYSDATE - l_start_time) * 1400 || ' minutes ');

            EXCEPTION
                WHEN OTHERS THEN
                    fnd_file.put_line(fnd_file.log, 'Unexpected exception in processing the (payrun_id,batch) = ' || p_payrun_id || ',' || p_batch_id);
                    fnd_file.put_line(fnd_file.log, SQLERRM);
                    RAISE;
       END create_multiple_worksheets;


    --============================================================================
    --Name :create_worksheet_conc
    --Description : Procedure which will be used as the executable for the
    --            : concurrent program. Create Worksheet
    --============================================================================
    PROCEDURE create_mult_worksheet_conc
            (
                errbuf  OUT NOCOPY VARCHAR2,
                retcode OUT NOCOPY NUMBER,
                p_name  cn_payruns.NAME%TYPE
              ) IS
                l_proc_audit_id  NUMBER;
                l_return_status  VARCHAR2(1000);
                l_msg_data       VARCHAR2(2000);
                l_msg_count      NUMBER;
                l_loading_status VARCHAR2(1000);
                l_status         VARCHAR2(2000);
                l_payrun_id      NUMBER;
                --R12
                l_org_id cn_payruns.org_id%TYPE;
                l_conc_params conc_params;
                errmsg       VARCHAR2(4000) := '';
                l_max_batch_id      NUMBER;
                salesrep_t          salesrep_tab_typ;
                l_batch_sz          NUMBER := 80;

                CURSOR get_payrun_id_curs(c_name cn_payruns.NAME%TYPE, c_org_id cn_payruns.org_id%TYPE) IS
                    SELECT cp.payrun_id,
                           cp.org_id,
                           cp.status
                     FROM cn_payruns cp
                     WHERE cp.NAME = c_name
                       AND cp.org_id = c_org_id;

              CURSOR c_payrun_srp(c_payrun_id cn_payruns.payrun_id%TYPE, c_batch_sz number) IS
                   SELECT salesrep_id,ceil(rownum / c_batch_sz) FROM  (SELECT DISTINCT cns.salesrep_id salesrep_id,
                                        cns.NAME        salesrep_name
                          FROM cn_payruns         cnp,
                               cn_srp_pay_groups  cnspg,
                               cn_salesreps       cns,
                               cn_period_statuses cnps
                          WHERE cnp.payrun_id = c_payrun_id
                          AND cnp.status = 'UNPAID'
                          AND cnp.pay_group_id = cnspg.pay_group_id
                          AND cnspg.salesrep_id = cns.salesrep_id
                          AND cns.hold_payment = 'N'
                          AND cnp.pay_period_id = cnps.period_id
                          AND cnp.org_id = cnps.org_id
                          AND cnp.org_id = cnspg.org_id
                          AND cnp.org_id = cns.org_id
                          AND ((cnspg.start_date <= cnps.end_date) AND (cnps.start_date <= nvl(cnspg.end_date, cnps.start_date)))
                          AND NOT EXISTS (SELECT 1
                                          FROM cn_payment_worksheets_all cnpw
                                          WHERE cnpw.salesrep_id = cnspg.salesrep_id
                                          AND cnp.payrun_id = cnpw.payrun_id)
                          AND (EXISTS (SELECT 1
                                       FROM cn_srp_payee_assigns cnspa
                                       WHERE ((cnspa.start_date <= cnps.end_date) AND (cnps.start_date <= nvl(cnspa.end_date, cnps.start_date)))
                                       AND cnspa.payee_id = cnspg.salesrep_id
                                          --R12
                                       AND cnspa.org_id = cnp.org_id) OR EXISTS
                            (SELECT 1
                               FROM cn_srp_plan_assigns cnspa
                               WHERE ((cnspa.start_date <= cnps.end_date) AND (cnps.start_date <= nvl(cnspa.end_date, cnps.start_date)))
                               AND cnspa.salesrep_id = cnspg.salesrep_id
                                   --R12
                               AND cnspa.org_id = cnp.org_id)));

                l_has_access BOOLEAN;
            BEGIN
                fnd_file.put_line(fnd_file.log, 'Entering create_mult_worksheet_conc ');
                retcode := 0;
                --Added for R12 payment security check begin.
                l_has_access := cn_payment_security_pvt.get_security_access(cn_payment_security_pvt.g_type_wksht, cn_payment_security_pvt.g_access_wksht_create);
                --Get the salesrep batch size from profile option.
        	    l_batch_sz := nvl(fnd_profile.value('CN_PMT_SRP_BATCH_SIZE'),251);
        	    fnd_file.put_line(fnd_file.log,'Batch size : ' ||l_batch_sz);

        	   IF l_batch_sz < 1
        	     THEN
        	     errmsg := 'The batch size should be greater than zero.';
        	     fnd_file.put_line(fnd_file.log, errmsg);
        	     raise_application_error(-20000, errmsg);
                END IF;

                IF (l_has_access = FALSE) THEN
                  RAISE fnd_api.g_exc_error;
                END IF;

                --Added for R12 payment security check end.
                l_org_id := mo_global.get_current_org_id;


                -- get payrun id
                OPEN get_payrun_id_curs(p_name, l_org_id);
                FETCH get_payrun_id_curs
                    INTO l_payrun_id, l_org_id,l_status;
                CLOSE get_payrun_id_curs;
                IF l_status <> 'UNPAID'
                THEN
                    errmsg := 'Worksheets can only be created for payruns in UNPAID status.';
                    fnd_file.put_line(fnd_file.log, errmsg);
                    raise_application_error(-20000, errmsg);
                END IF;
                cn_message_pkg.begin_batch(x_process_type         => 'WKSHT',
                                           x_process_audit_id     => l_proc_audit_id,
                                           x_parent_proc_audit_id => l_payrun_id,
                                           x_request_id           => NULL,
                                           --R12
                                           p_org_id => l_org_id);
                BEGIN

                  OPEN c_payrun_srp(l_payrun_id, l_batch_sz);
                    LOOP
                      FETCH c_payrun_srp
                      BULK COLLECT INTO salesrep_t LIMIT 1000;

                    -- get the salesreps for the payrun.
        	        /*SELECT salesrep_id,ceil(rownum / l_batch_sz)
                    BULK COLLECT INTO salesrep_t
        	        FROM (SELECT DISTINCT cns.salesrep_id salesrep_id,
                                        cns.NAME        salesrep_name
                          FROM cn_payruns         cnp,
                               cn_srp_pay_groups  cnspg,
                               cn_salesreps       cns,
                               cn_period_statuses cnps
                          WHERE cnp.payrun_id = l_payrun_id
                          AND cnp.status = 'UNPAID'
                          AND cnp.pay_group_id = cnspg.pay_group_id
                          AND cnspg.salesrep_id = cns.salesrep_id
                          AND cns.hold_payment = 'N'
                          AND cnp.pay_period_id = cnps.period_id
                          AND cnp.org_id = cnps.org_id
                          AND cnp.org_id = cnspg.org_id
                          AND cnp.org_id = cns.org_id
                          AND ((cnspg.start_date <= cnps.end_date) AND (cnps.start_date <= nvl(cnspg.end_date, cnps.start_date)))
                          AND NOT EXISTS (SELECT 1
                                          FROM cn_payment_worksheets_all cnpw
                                          WHERE cnpw.salesrep_id = cnspg.salesrep_id
                                          AND cnp.payrun_id = cnpw.payrun_id)
                          AND (EXISTS (SELECT 1
                                       FROM cn_srp_payee_assigns cnspa
                                       WHERE ((cnspa.start_date <= cnps.end_date) AND (cnps.start_date <= nvl(cnspa.end_date, cnps.start_date)))
                                       AND cnspa.payee_id = cnspg.salesrep_id
                                          --R12
                                       AND cnspa.org_id = cnp.org_id) OR EXISTS
                            (SELECT 1
                               FROM cn_srp_plan_assigns cnspa
                               WHERE ((cnspa.start_date <= cnps.end_date) AND (cnps.start_date <= nvl(cnspa.end_date, cnps.start_date)))
                               AND cnspa.salesrep_id = cnspg.salesrep_id
                                   --R12
                               AND cnspa.org_id = cnp.org_id))); */
                   -- Call the CN_CREATE_WKSHT_INT conc program
        	       l_conc_params.conc_program_name := 'CN_CREATE_WKSHT_INT' ;

    	           generic_conc_processor(p_payrun_id    => l_payrun_id,
        	                              p_salesrep_tbl => salesrep_t,
        	                              p_org_id       => l_org_id,
        	                              p_params       => l_conc_params,
        	                              x_errbuf       => errbuf,
        	                              x_retcode      => retcode);

                      EXIT WHEN c_payrun_srp%NOTFOUND;
                    END LOOP;
                  CLOSE c_payrun_srp;

        	        EXCEPTION
        	        WHEN no_data_found THEN
        	            errmsg := 'No salesreps found that were eligible for worksheet creation in the payrun : ';
        	            fnd_file.put_line(fnd_file.log, errmsg);
        	            retcode := 2;
        	            errbuf  := errmsg;
        	            RAISE ;
        	        WHEN OTHERS THEN
        	            fnd_file.put_line(fnd_file.log, 'Unexpected exception in cn_payment_worksheet_pvt.create_mult_worksheet_conc');
        	            fnd_file.put_line(fnd_file.log, errmsg);
        	            fnd_file.put_line(fnd_file.log, SQLERRM);
                    RAISE;
                  END;


        	      fnd_file.put_line(fnd_file.log, errbuf);
        	      fnd_file.put_line(fnd_file.log, 'Count of worksheets to be created = ' || salesrep_t.COUNT);
        	      fnd_file.put_line(fnd_file.log, 'Completed create worksheet process....');

        	    IF l_return_status <> fnd_api.g_ret_sts_success
                THEN
                    retcode := 2;
                    fnd_message.set_name('CN', 'CN_CONC_REQ_FAIL');
                    fnd_msg_pub.add;
                    errbuf := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
                END IF;

                cn_message_pkg.end_batch(l_proc_audit_id);
                COMMIT;
    END create_mult_worksheet_conc;
    -- ===========================================================================
    -- Procedure : Update_Worksheet
    -- Description used for Refreshing the Worksheets
    --                      Locking and Unlocking the Worksheets
    -- ===========================================================================
    PROCEDURE update_worksheet
    (
        p_api_version      IN NUMBER,
        p_init_msg_list    IN VARCHAR2,
        p_commit           IN VARCHAR2,
        p_validation_level IN NUMBER,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,
        p_worksheet_id     IN NUMBER,
        p_operation        IN VARCHAR2,
        x_status           OUT NOCOPY VARCHAR2,
        x_loading_status   OUT NOCOPY VARCHAR2,
        x_ovn              IN OUT NOCOPY NUMBER
    ) IS
        l_api_name CONSTANT VARCHAR2(30) := 'Update_Worksheet';

        CURSOR get_worksheet_id IS
            SELECT cnpw.salesrep_id,
                   cnp.payrun_id,
                   cnpw.worksheet_status,
                   cnp.pay_period_id,
                   decode(cnp.incentive_type_code, 'ALL', '', cnp.incentive_type_code) incentive_type_code,
                   cnp.pay_date,
                   cnpw.object_version_number ovn,
                   cnpw.org_id
              FROM cn_payment_worksheets cnpw,
                   cn_payruns            cnp
             WHERE payment_worksheet_id = p_worksheet_id
               AND cnpw.payrun_id = cnp.payrun_id;

        -- changes for bug#2568937
        -- for payroll integration population of account
        CURSOR get_apps IS
            SELECT payables_flag,
                   payroll_flag,
                   payables_ccid_level
              FROM cn_repositories       rp,
                   cn_payment_worksheets wk
             WHERE rp.org_id = wk.org_id;

        wksht_rec                  get_worksheet_id%ROWTYPE;
        l_status                   cn_payment_worksheets.worksheet_status%TYPE;
        l_posting_batch_id         NUMBER;
        recv_posting_batch_id      NUMBER;
        carryover_posting_batch_id NUMBER;

        l_calc_rec_tbl        calc_rec_tbl_type;
        l_batch_rec           cn_prepostbatches.posting_batch_rec_type;
        l_calc_pmt_amount     NUMBER;
        l_adj_pmt_amount_rec  NUMBER;
        l_adj_pmt_amount_nrec NUMBER;
        l_pmt_amount_rec      NUMBER;
        l_pmt_trans_rec       cn_pmt_trans_pkg.pmt_trans_rec_type; -- PmtTrans
        l_pmt_amount_ctr      NUMBER;
        l_rowid               VARCHAR2(30);
        -- changes for bug#2568937
        -- for payroll integration population of account
        l_payables_flag       cn_repositories.payables_flag%TYPE;
        l_payroll_flag        cn_repositories.payroll_flag%TYPE;
        l_payables_ccid_level cn_repositories.payables_ccid_level%TYPE;
        l_ispayee             NUMBER := 0;
        TYPE num_tab IS TABLE OF NUMBER;
        l_wk_plan_elements num_tab;
        l_has_access          BOOLEAN;
        l_org_id              NUMBER;
        l_pay_by_mode         VARCHAR2(1);
        l_srp_status          cn_salesreps.status%TYPE;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT update_worksheet;

        -- Standard call to check for call compatibility.
        IF NOT fnd_api.compatible_api_call(g_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        --
        -- Initialize message list if p_init_msg_list is set to TRUE.
        --
        IF fnd_api.to_boolean(p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        --
        --  Initialize API return status to success
        --
        x_return_status  := fnd_api.g_ret_sts_success;
        x_loading_status := 'CN_UPDATED';

        OPEN get_worksheet_id;

        FETCH get_worksheet_id
            INTO wksht_rec;

        CLOSE get_worksheet_id;

        --This part is added for OA.
        IF wksht_rec.ovn <> x_ovn
        THEN
            IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error))
            THEN
                fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
                fnd_msg_pub.add;
            END IF;

            RAISE fnd_api.g_exc_error;
        END IF;

        l_pay_by_mode := cn_payment_security_pvt.get_pay_by_mode(wksht_rec.payrun_id);

        SELECT s.status,
               nvl(r.payroll_flag, 'N'),
               r.payables_flag
          INTO l_srp_status,
               l_payroll_flag,
               l_payables_flag
          FROM cn_salesreps        s,
               cn_repositories_all r,
               cn_payruns_all      pr
         WHERE s.salesrep_id = wksht_rec.salesrep_id
           AND s.org_id = r.org_id
           AND pr.org_id = r.org_id
           AND pr.payrun_id = wksht_rec.payrun_id;

        -- Bug 3140343 : Payee Design. Check if this salesrep is a Payee
        l_ispayee := cn_api.is_payee(p_period_id => wksht_rec.pay_period_id, p_salesrep_id => wksht_rec.salesrep_id, p_org_id => wksht_rec.org_id);

        IF p_operation = 'REFRESH'
        THEN

            --Added for R12 payment security check end.
            cn_payment_security_pvt.worksheet_action(p_api_version      => p_api_version,
                                                     p_init_msg_list    => p_init_msg_list,
                                                     p_commit           => 'F',
                                                     p_validation_level => p_validation_level,
                                                     x_return_status    => x_return_status,
                                                     x_msg_count        => x_msg_count,
                                                     x_msg_data         => x_msg_data,
                                                     p_worksheet_id     => p_worksheet_id,
                                                     p_action           => p_operation);

            IF x_return_status <> fnd_api.g_ret_sts_success
            THEN
                RAISE fnd_api.g_exc_error;
            END IF;

            --  get sequence number
            SELECT cn_posting_batches_s.NEXTVAL
              INTO l_posting_batch_id
              FROM dual;

            -- Refresh payment transactions
            IF l_pay_by_mode = 'N'
            THEN
                -- Update amount on all payment transactions
                -- The following change was made by Sundar for bug fix 2772834
                -- This will handle scenarios where a salesrep has multiple role assignments
                -- during the same period, with an overlapping quota assignment
                -- changes records that have changed and not held
                UPDATE cn_payment_transactions cnpt
                   SET (                    amount, payment_amount) = (SELECT SUM(balance2_bbd - balance2_bbc + balance2_dtd - balance2_ctd),
                                                                              SUM(balance2_bbd - balance2_bbc + balance2_dtd - balance2_ctd)
                                                                         FROM cn_srp_periods csp
                                                                        WHERE csp.period_id = wksht_rec.pay_period_id
                                                                          AND csp.salesrep_id = cnpt.credited_salesrep_id
                                                                          AND csp.quota_id = cnpt.quota_id
                                                                          AND csp.credit_type_id = cnpt.credit_type_id
                                                                             --R12
                                                                          AND csp.org_id = wksht_rec.org_id),
                       pay_element_type_id   = (SELECT decode(r.payroll_flag, NULL, NULL, 'N', NULL, 'Y', p.pay_element_type_id, NULL) pay_element_type_id
                                                  FROM cn_quota_pay_elements p,
                                                       cn_rs_salesreps       s,
                                                       cn_repositories       r
                                                 WHERE p.quota_id = cnpt.quota_id
                                                   AND wksht_rec.pay_date BETWEEN p.start_date AND p.end_date
                                                   AND s.salesrep_id = cnpt.credited_salesrep_id
                                                   AND nvl(s.status, 'A') = p.status
                                                      --R12
                                                   AND p.org_id = wksht_rec.org_id
                                                   AND s.org_id = wksht_rec.org_id
                                                   AND r.org_id = wksht_rec.org_id),
                       last_update_date      = SYSDATE,
                       last_updated_by       = fnd_global.user_id,
                       last_update_login     = fnd_global.login_id,
                       object_version_number = nvl(object_version_number, 0) + 1
                 WHERE cnpt.payrun_id = wksht_rec.payrun_id
                   AND cnpt.amount = cnpt.payment_amount
                   AND incentive_type_code IN ('COMMISSION', 'BONUS')
                      -- 01/03/03 gasriniv added hold flag check for bug 2710066
                   AND (cnpt.hold_flag IS NULL OR cnpt.hold_flag = 'N')
                   AND cnpt.credited_salesrep_id = wksht_rec.salesrep_id
                      --R12
                   AND cnpt.org_id = wksht_rec.org_id;

                -- for those records that have changed, dont update the payment amount
                UPDATE cn_payment_transactions cnpt
                   SET amount              = (SELECT SUM(balance2_bbd - balance2_bbc + balance2_dtd - balance2_ctd)
                                                FROM cn_srp_periods csp
                                               WHERE csp.period_id = wksht_rec.pay_period_id
                                                 AND csp.salesrep_id = cnpt.credited_salesrep_id
                                                 AND csp.quota_id = cnpt.quota_id
                                                 AND csp.credit_type_id = cnpt.credit_type_id
                                                    --R12
                                                 AND csp.org_id = wksht_rec.org_id),
                       pay_element_type_id = (SELECT decode(r.payroll_flag, NULL, NULL, 'N', NULL, 'Y', p.pay_element_type_id, NULL) pay_element_type_id
                                                FROM cn_quota_pay_elements p,
                                                     cn_rs_salesreps       s,
                                                     cn_repositories       r
                                               WHERE p.quota_id = cnpt.quota_id
                                                 AND wksht_rec.pay_date BETWEEN p.start_date AND p.end_date
                                                 AND s.salesrep_id = cnpt.credited_salesrep_id
                                                 AND nvl(s.status, 'A') = p.status
                                                    --R12
                                                 AND p.org_id = wksht_rec.org_id
                                                 AND s.org_id = wksht_rec.org_id
                                                 AND r.org_id = wksht_rec.org_id),
                       last_update_date    = SYSDATE,
                       last_updated_by     = fnd_global.user_id,
                       last_update_login   = fnd_global.login_id
                 WHERE cnpt.payrun_id = wksht_rec.payrun_id
                   AND cnpt.amount <> cnpt.payment_amount
                   AND incentive_type_code IN ('COMMISSION', 'BONUS')
                      -- 01/03/03 gasriniv added hold flag check for bug 2710066
                   AND (cnpt.hold_flag IS NULL OR cnpt.hold_flag = 'N')
                   AND cnpt.credited_salesrep_id = wksht_rec.salesrep_id
                      --R12
                   AND cnpt.org_id = wksht_rec.org_id;

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
                     --R12
                     org_id)
                    SELECT cn_payment_transactions_s.NEXTVAL,
                           l_posting_batch_id,
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
                           wksht_rec.payrun_id,
                           v1.quota_id,
                           v1.pay_element_type_id,
                           fnd_global.user_id,
                           SYSDATE,
                           --R12
                           wksht_rec.org_id
                      FROM (SELECT q.incentive_type_code,
                                   srp.credit_type_id,
                                   srp.period_id,
                                   SUM((nvl(srp.balance2_dtd, 0) - nvl(srp.balance2_ctd, 0) + nvl(srp.balance2_bbd, 0) - nvl(srp.balance2_bbc, 0))) amount,
                                   SUM((nvl(srp.balance2_dtd, 0) - nvl(srp.balance2_ctd, 0) + nvl(srp.balance2_bbd, 0) - nvl(srp.balance2_bbc, 0))) payment_amount,
                                   srp.salesrep_id,
                                   srp.quota_id,
                                   decode(r.payroll_flag, NULL, NULL, 'N', NULL, 'Y', qp.pay_element_type_id, NULL) pay_element_type_id
                              FROM cn_srp_periods            srp,
                                   cn_quotas_all             q,
                                   cn_quota_pay_elements_all qp,
                                   cn_rs_salesreps           s,
                                   cn_repositories           r
                            -- 01/03/03 gasriniv added hold flag check for bug 2710066
                             WHERE srp.salesrep_id = wksht_rec.salesrep_id
                               AND srp.period_id = wksht_rec.pay_period_id
                               AND srp.quota_id = q.quota_id
                               AND srp.quota_id <> -1000
                                  -- Bug 2819874
                               AND srp.credit_type_id = -1000
                               AND q.incentive_type_code = decode(nvl(wksht_rec.incentive_type_code, q.incentive_type_code),
                                                                  'COMMISSION',
                                                                  'COMMISSION',
                                                                  'BONUS',
                                                                  'BONUS',
                                                                  q.incentive_type_code)
                               AND qp.quota_id(+) = srp.quota_id
                               AND wksht_rec.pay_date BETWEEN qp.start_date(+) AND qp.end_date(+)
                               AND s.salesrep_id = srp.salesrep_id
                               AND nvl(s.status, 'A') = nvl(qp.status, nvl(s.status, 'A'))
                                  --R12
                               AND srp.org_id = s.org_id
                               AND srp.org_id = r.org_id
                               AND srp.org_id = wksht_rec.org_id
                               AND NOT EXISTS (SELECT 'X'
                                      FROM cn_payment_transactions_all cnpt
                                     WHERE cnpt.payrun_id = wksht_rec.payrun_id
                                       AND cnpt.credited_salesrep_id = wksht_rec.salesrep_id
                                       AND cnpt.quota_id = q.quota_id
                                       AND cnpt.incentive_type_code IN ('COMMISSION', 'BONUS')
                                          -- 01/03/03 gasriniv added hold flag check for bug 2710066
                                       AND (cnpt.hold_flag IS NULL OR cnpt.hold_flag = 'N')
                                          --R12
                                       AND cnpt.org_id = wksht_rec.org_id)
                             GROUP BY srp.quota_id,
                                      q.incentive_type_code,
                                      srp.credit_type_id,
                                      srp.period_id,
                                      srp.salesrep_id,
                                      r.payroll_flag,
                                      qp.pay_element_type_id) v1;

                IF SQL%ROWCOUNT <> 0
                THEN
                    l_batch_rec.posting_batch_id  := l_posting_batch_id;
                    l_batch_rec.NAME              := 'Refresh batch number:' || wksht_rec.payrun_id || ':' || wksht_rec.salesrep_id || ':' ||
                                                     l_posting_batch_id;
                    l_batch_rec.created_by        := fnd_global.user_id;
                    l_batch_rec.creation_date     := SYSDATE;
                    l_batch_rec.last_updated_by   := fnd_global.user_id;
                    l_batch_rec.last_update_date  := SYSDATE;
                    l_batch_rec.last_update_login := fnd_global.login_id;
                    -- Create the Posting Batches
                    cn_prepostbatches.begin_record(x_operation         => 'INSERT',
                                                   x_rowid             => l_rowid,
                                                   x_posting_batch_rec => l_batch_rec,
                                                   x_program_type      => NULL,
                                                   p_org_id            => wksht_rec.org_id);
                END IF;

                -- Bug 2819874 :Add in carry over record if exist,regardless
                -- incentive type code
                --  get sequence number
                SELECT cn_posting_batches_s.NEXTVAL
                  INTO carryover_posting_batch_id
                  FROM dual;

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
                     --R12
                     org_id)
                    SELECT cn_payment_transactions_s.NEXTVAL,
                           carryover_posting_batch_id,
                           'COMMISSION',
                           srp.credit_type_id,
                           srp.period_id,
                           nvl((nvl(srp.balance2_dtd, 0) - nvl(srp.balance2_ctd, 0) + nvl(srp.balance2_bbd, 0) - nvl(srp.balance2_bbc, 0)), 0),
                           nvl((nvl(srp.balance2_dtd, 0) - nvl(srp.balance2_ctd, 0) + nvl(srp.balance2_bbd, 0) - nvl(srp.balance2_bbc, 0)), 0),
                           srp.salesrep_id,
                           srp.salesrep_id,
                           'N',
                           'N',
                           'N',
                           wksht_rec.payrun_id,
                           -1000,
                           decode(r.payroll_flag, NULL, NULL, 'N', NULL, 'Y', qp.pay_element_type_id, NULL) pay_element_type_id,
                           fnd_global.user_id,
                           SYSDATE,
                           --R12
                           wksht_rec.org_id
                      FROM cn_srp_periods            srp,
                           cn_quota_pay_elements_all qp,
                           cn_rs_salesreps           s,
                           cn_repositories           r
                     WHERE srp.salesrep_id = wksht_rec.salesrep_id
                       AND srp.period_id = wksht_rec.pay_period_id
                       AND srp.credit_type_id = -1000
                       AND srp.quota_id = -1000
                       AND nvl((nvl(srp.balance2_dtd, 0) - nvl(srp.balance2_ctd, 0) + nvl(srp.balance2_bbd, 0) - nvl(srp.balance2_bbc, 0)), 0) <> 0
                       AND qp.quota_id(+) = srp.quota_id
                       AND wksht_rec.pay_date BETWEEN qp.start_date(+) AND qp.end_date(+)
                       AND s.salesrep_id = srp.salesrep_id
                       AND nvl(s.status, 'A') = nvl(qp.status, nvl(s.status, 'A'))
                          --R12
                       AND srp.org_id = s.org_id
                       AND srp.org_id = r.org_id
                       AND srp.org_id = wksht_rec.org_id
                       AND NOT EXISTS (SELECT 'X'
                              FROM cn_payment_transactions cnpt
                             WHERE cnpt.payrun_id = wksht_rec.payrun_id
                               AND cnpt.credited_salesrep_id = wksht_rec.salesrep_id
                               AND cnpt.quota_id = -1000
                                  -- 07/18/03 check exist only for commission/bonus
                               AND cnpt.incentive_type_code IN ('COMMISSION', 'BONUS')
                               AND (cnpt.hold_flag IS NULL OR cnpt.hold_flag = 'N'));

                IF SQL%ROWCOUNT <> 0
                THEN
                    l_batch_rec.posting_batch_id  := carryover_posting_batch_id;
                    l_batch_rec.NAME              := 'Refresh batch number:' || wksht_rec.payrun_id || ':' || wksht_rec.salesrep_id || ':' ||
                                                     carryover_posting_batch_id;
                    l_batch_rec.created_by        := fnd_global.user_id;
                    l_batch_rec.creation_date     := SYSDATE;
                    l_batch_rec.last_updated_by   := fnd_global.user_id;
                    l_batch_rec.last_update_date  := SYSDATE;
                    l_batch_rec.last_update_login := fnd_global.login_id;
                    -- Create the Posting Batches
                    cn_prepostbatches.begin_record(x_operation         => 'INSERT',
                                                   x_rowid             => l_rowid,
                                                   x_posting_batch_rec => l_batch_rec,
                                                   x_program_type      => NULL,
                                                   p_org_id            => wksht_rec.org_id);
                END IF;

                -- 01/03/03 gasriniv added hold flag check for bug 2710066
                UPDATE cn_payment_transactions cnpt
                   SET (                amount, payment_amount) = (SELECT cnpt.amount - SUM(cnptheld.amount),
                                                                          cnpt.payment_amount - SUM(cnptheld.amount)
                                                                     FROM cn_payment_transactions cnptheld
                                                                    WHERE cnptheld.payrun_id = wksht_rec.payrun_id
                                                                      AND cnptheld.credited_salesrep_id = wksht_rec.salesrep_id
                                                                      AND cnptheld.quota_id = cnpt.quota_id
                                                                      AND cnptheld.hold_flag = 'Y'
                                                                      AND cnptheld.paid_flag = 'N'
                                                                         --R12
                                                                      AND cnptheld.org_id = wksht_rec.org_id),
                       last_update_date  = SYSDATE,
                       last_updated_by   = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                 WHERE cnpt.payrun_id = wksht_rec.payrun_id
                   AND cnpt.credited_salesrep_id = wksht_rec.salesrep_id
                   AND cnpt.hold_flag = 'N'
                   AND cnpt.paid_flag = 'N'
                   AND incentive_type_code IN ('COMMISSION', 'BONUS')
                      --R12
                   AND cnpt.org_id = wksht_rec.org_id
                   AND EXISTS (SELECT 'X'
                          FROM cn_payment_transactions cnptchk
                         WHERE cnptchk.payrun_id = wksht_rec.payrun_id
                           AND cnptchk.credited_salesrep_id = wksht_rec.salesrep_id
                           AND cnptchk.quota_id = cnpt.quota_id
                           AND cnptchk.hold_flag = 'Y'
                              --R12
                           AND cnptchk.org_id = wksht_rec.org_id);
            ELSE
                -- PBT

                -- Bug 3140343 : Payee Design
                IF l_ispayee <> 1
                THEN
                    -- IF PBT, then create all unposted lines
                    -- Create new payment transactions for unposted payment transactions
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
                         --R12
                         org_id,
                         object_version_number,
                         processed_date)
                        SELECT
                         cn_payment_transactions_s.NEXTVAL,
                         l_posting_batch_id,
                         cl.trx_type,
                         cl.credited_salesrep_id,
                         cl.role_id,
                         pe.incentive_type_code,
                         pe.credit_type_id,
                         cl.pay_period_id,
                         nvl(cl.commission_amount, 0),
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
                         wksht_rec.payrun_id,
                         nvl(cl.commission_amount, 0),
                         -- Bug 2875120 : remove cn_api function call in sql statement
                         decode(l_payroll_flag, NULL, NULL, 'N', NULL, 'Y', qp.pay_element_type_id, NULL) pay_element_type_id,
                         SYSDATE,
                         fnd_global.user_id,
                         --R12
                         wksht_rec.org_id,
                         1,
                         cl.processed_date
                          FROM cn_commission_lines   cl,
                               cn_quotas_all         pe,
                               cn_quota_pay_elements qp
                         WHERE cl.credited_salesrep_id = wksht_rec.salesrep_id
                           AND cl.processed_period_id <= wksht_rec.pay_period_id
                           AND cl.processed_date <= wksht_rec.pay_date
                           AND cl.status = 'CALC'
                           AND cl.srp_payee_assign_id IS NULL
                           AND cl.posting_status = 'UNPOSTED'
                           AND cl.quota_id = pe.quota_id
                           AND cl.credit_type_id = -1000
                           AND pe.incentive_type_code = decode(nvl(wksht_rec.incentive_type_code, pe.incentive_type_code),
                                                               'COMMISSION',
                                                               'COMMISSION',
                                                               'BONUS',
                                                               'BONUS',
                                                               pe.incentive_type_code)
                           AND qp.quota_id(+) = cl.quota_id
                           AND wksht_rec.pay_date BETWEEN qp.start_date(+) AND qp.end_date(+)
                           AND nvl(l_srp_status, 'A') = nvl(qp.status, nvl(l_srp_status, 'A'))
                           AND cl.org_id = wksht_rec.org_id;

                ELSE
                    -- refresh record for Payee. Get unposted trx from comm_lines
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
                         --R12
                         org_id,
                         object_version_number,
                         processed_date)
                        SELECT
                         cn_payment_transactions_s.NEXTVAL,
                         l_posting_batch_id,
                         cl.trx_type,
                         spayee.payee_id,
                         cl.role_id,
                         pe.incentive_type_code,
                         pe.credit_type_id,
                         cl.pay_period_id,
                         nvl(cl.commission_amount, 0),
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
                         wksht_rec.payrun_id,
                         nvl(cl.commission_amount, 0),
                         -- Bug 2875120 : remove cn_api function call in sql statement
                         decode(l_payroll_flag, NULL, NULL, 'N', NULL, 'Y', qp.pay_element_type_id, NULL) pay_element_type_id,
                         SYSDATE,
                         fnd_global.user_id,
                         --R12
                         wksht_rec.org_id,
                         1,
                         cl.processed_date
                          FROM cn_commission_lines       cl,
                               cn_srp_payee_assigns_all  spayee,
                               cn_quotas_all             pe,
                               cn_quota_pay_elements_all qp
                         WHERE cl.srp_payee_assign_id IS NOT NULL
                           AND cl.srp_payee_assign_id = spayee.srp_payee_assign_id
                           AND spayee.payee_id = wksht_rec.salesrep_id
                           AND cl.credited_salesrep_id = spayee.salesrep_id
                           AND cl.processed_period_id <= wksht_rec.pay_period_id
                           AND cl.processed_date <= wksht_rec.pay_date
                           AND cl.status = 'CALC'
                           AND cl.posting_status = 'UNPOSTED'
                           AND cl.quota_id = pe.quota_id
                           AND cl.credit_type_id = -1000
                           AND pe.incentive_type_code = decode(nvl(wksht_rec.incentive_type_code, pe.incentive_type_code),
                                                               'COMMISSION',
                                                               'COMMISSION',
                                                               'BONUS',
                                                               'BONUS',
                                                               pe.incentive_type_code)
                           AND qp.quota_id(+) = cl.quota_id
                           AND wksht_rec.pay_date BETWEEN qp.start_date(+) AND qp.end_date(+)
                           AND nvl(l_srp_status, 'A') = nvl(qp.status, nvl(l_srp_status, 'A'))
                           AND cl.org_id = spayee.org_id
                           AND cl.org_id = wksht_rec.org_id;

                END IF;
                -- end IF l_ispayee <> 1 THEN

                -- update payrun id on all payment transactions
                UPDATE cn_payment_transactions cnpt
                   SET payrun_id             = wksht_rec.payrun_id,
                       pay_element_type_id   = (SELECT decode(l_payroll_flag, 'Y', p.pay_element_type_id, NULL) pay_element_type_id
                                                  FROM cn_quota_pay_elements p
                                                 WHERE p.quota_id = cnpt.quota_id
                                                   AND wksht_rec.pay_date BETWEEN p.start_date AND p.end_date
                                                   AND nvl(l_srp_status, 'A') = nvl(p.status, nvl(l_srp_status, 'A'))),
                       last_update_date      = SYSDATE,
                       last_updated_by       = fnd_global.user_id,
                       last_update_login     = fnd_global.login_id,
                       object_version_number = nvl(object_version_number, 0) + 1
                 WHERE credited_salesrep_id = wksht_rec.salesrep_id
                   AND pay_period_id <= wksht_rec.pay_period_id
                   AND incentive_type_code =
                       decode(nvl(wksht_rec.incentive_type_code, incentive_type_code), 'COMMISSION', 'COMMISSION', 'BONUS', 'BONUS', incentive_type_code)
                   AND incentive_type_code IN ('COMMISSION', 'BONUS')
                   AND payrun_id IS NULL
                   AND processed_date <= wksht_rec.pay_date;

                -- update pay_element_type_id
                UPDATE cn_payment_transactions cnpt
                   SET pay_element_type_id   = (SELECT decode(l_payroll_flag, 'Y', p.pay_element_type_id, NULL) pay_element_type_id
                                                  FROM cn_quota_pay_elements p
                                                 WHERE p.quota_id = decode(cnpt.incentive_type_code, 'PMTPLN_REC', -1001, cnpt.quota_id)
                                                   AND wksht_rec.pay_date BETWEEN p.start_date AND p.end_date
                                                   AND nvl(l_srp_status, 'A') = nvl(p.status, nvl(l_srp_status, 'A'))
                                                   AND p.org_id = wksht_rec.org_id),
                       last_update_date      = SYSDATE,
                       last_updated_by       = fnd_global.user_id,
                       last_update_login     = fnd_global.login_id,
                       object_version_number = nvl(object_version_number, 0) + 1
                 WHERE credited_salesrep_id = wksht_rec.salesrep_id
                   AND payrun_id = wksht_rec.payrun_id;
            END IF;
            -- end IF CN_PAY_BY_MODE = 'N'

            -- calculate totals
            calculate_totals(p_salesrep_id    => wksht_rec.salesrep_id,
                             p_period_id      => wksht_rec.pay_period_id,
                             p_incentive_type => wksht_rec.incentive_type_code,
                             p_payrun_id      => wksht_rec.payrun_id,
                             x_calc_rec_tbl   => l_calc_rec_tbl,
                             --R12
                             p_org_id => wksht_rec.org_id);

            -- Bug 2692801 : avoid PL/SQL error when l_calc_rec_tbl is null
            IF l_calc_rec_tbl.COUNT > 0
            THEN
                FOR i IN l_calc_rec_tbl.FIRST .. l_calc_rec_tbl.LAST
                LOOP
                    IF l_calc_rec_tbl(i).quota_id IS NOT NULL
                    THEN
                        IF l_calc_rec_tbl(i).pmt_amount_adj_rec <> 0
                           OR l_calc_rec_tbl(i).pmt_amount_adj_nrec <> 0
                        THEN
                            UPDATE cn_payment_transactions cnpt
                               SET amount                = l_calc_rec_tbl(i).pmt_amount_adj_rec + l_calc_rec_tbl(i).pmt_amount_adj_nrec,
                                   payment_amount        = l_calc_rec_tbl(i).pmt_amount_adj_rec + l_calc_rec_tbl(i).pmt_amount_adj_nrec,
                                   pay_element_type_id   = (SELECT decode(r.payroll_flag, NULL, NULL, 'N', NULL, 'Y', p.pay_element_type_id, NULL) pay_element_type_id
                                                              FROM cn_quota_pay_elements p,
                                                                   cn_rs_salesreps       s,
                                                                   cn_repositories       r
                                                             WHERE p.quota_id = cnpt.quota_id
                                                               AND wksht_rec.pay_date BETWEEN p.start_date AND p.end_date
                                                               AND s.salesrep_id = cnpt.credited_salesrep_id
                                                               AND nvl(s.status, 'A') = p.status
                                                                  --R12
                                                               AND p.org_id = wksht_rec.org_id
                                                               AND s.org_id = wksht_rec.org_id
                                                               AND r.org_id = wksht_rec.org_id),
                                   last_update_date      = SYSDATE,
                                   last_updated_by       = fnd_global.user_id,
                                   last_update_login     = fnd_global.login_id,
                                   object_version_number = nvl(object_version_number, 0) + 1
                             WHERE credited_salesrep_id = wksht_rec.salesrep_id
                               AND payrun_id = wksht_rec.payrun_id
                               AND incentive_type_code = 'PMTPLN'
                               AND quota_id = l_calc_rec_tbl(i).quota_id
                                  --R12
                               AND cnpt.org_id = wksht_rec.org_id;

                            IF SQL%ROWCOUNT = 0
                            THEN
                                -- Get the Sequence Number
                                SELECT cn_posting_batches_s.NEXTVAL
                                  INTO recv_posting_batch_id
                                  FROM dual;

                                l_batch_rec.posting_batch_id  := recv_posting_batch_id;
                                l_batch_rec.NAME              := 'PMTPLN batch number:' || wksht_rec.payrun_id || ':' || wksht_rec.salesrep_id || ':' ||
                                                                 l_calc_rec_tbl(i).quota_id || ':' || recv_posting_batch_id;
                                l_batch_rec.created_by        := fnd_global.user_id;
                                l_batch_rec.creation_date     := SYSDATE;
                                l_batch_rec.last_updated_by   := fnd_global.user_id;
                                l_batch_rec.last_update_date  := SYSDATE;
                                l_batch_rec.last_update_login := fnd_global.login_id;
                                -- Create the Posting Batches
                                cn_prepostbatches.begin_record(x_operation         => 'INSERT',
                                                               x_rowid             => l_rowid,
                                                               x_posting_batch_rec => l_batch_rec,
                                                               x_program_type      => NULL,
                                                               p_org_id            => wksht_rec.org_id);
                                l_pmt_trans_rec.posting_batch_id     := recv_posting_batch_id;
                                l_pmt_trans_rec.incentive_type_code  := 'PMTPLN';
                                l_pmt_trans_rec.credit_type_id       := -1000;
                                l_pmt_trans_rec.payrun_id            := wksht_rec.payrun_id;
                                l_pmt_trans_rec.credited_salesrep_id := wksht_rec.salesrep_id;
                                l_pmt_trans_rec.payee_salesrep_id    := wksht_rec.salesrep_id;
                                l_pmt_trans_rec.pay_period_id        := wksht_rec.pay_period_id;
                                l_pmt_trans_rec.hold_flag            := 'N';
                                l_pmt_trans_rec.waive_flag           := 'N';
                                l_pmt_trans_rec.paid_flag            := 'N';
                                l_pmt_trans_rec.recoverable_flag     := 'N';
                                l_pmt_trans_rec.quota_id             := l_calc_rec_tbl(i).quota_id;
                                l_pmt_trans_rec.amount               := nvl(l_calc_rec_tbl(i).pmt_amount_adj_rec, 0) +
                                                                        nvl(l_calc_rec_tbl(i).pmt_amount_adj_nrec, 0);
                                l_pmt_trans_rec.payment_amount       := nvl(l_calc_rec_tbl(i).pmt_amount_adj_rec, 0) +
                                                                        nvl(l_calc_rec_tbl(i).pmt_amount_adj_nrec, 0);
                                --R12
                                l_pmt_trans_rec.org_id                := wksht_rec.org_id;
                                l_pmt_trans_rec.object_version_number := 1;
                                l_pmt_trans_rec.pay_element_type_id   := cn_api.get_pay_element_id(l_calc_rec_tbl(i).quota_id,
                                                                                                   wksht_rec.salesrep_id,
                                                                                                   wksht_rec.org_id,
                                                                                                   wksht_rec.pay_date);
                                -- Create the Payment Plan Record
                                cn_pmt_trans_pkg.insert_record(p_tran_rec => l_pmt_trans_rec);
                            END IF;
                        ELSE
                            UPDATE cn_payment_transactions cnpt
                               SET amount                = 0,
                                   payment_amount        = 0,
                                   pay_element_type_id   = (SELECT decode(r.payroll_flag, NULL, NULL, 'N', NULL, 'Y', p.pay_element_type_id, NULL) pay_element_type_id
                                                              FROM cn_quota_pay_elements p,
                                                                   cn_rs_salesreps       s,
                                                                   cn_repositories       r
                                                             WHERE p.quota_id = cnpt.quota_id
                                                               AND wksht_rec.pay_date BETWEEN p.start_date AND p.end_date
                                                               AND s.salesrep_id = cnpt.credited_salesrep_id
                                                               AND nvl(s.status, 'A') = p.status
                                                                  --R12
                                                               AND p.org_id = wksht_rec.org_id
                                                               AND s.org_id = wksht_rec.org_id
                                                               AND r.org_id = wksht_rec.org_id),
                                   last_update_date      = SYSDATE,
                                   last_updated_by       = fnd_global.user_id,
                                   last_update_login     = fnd_global.login_id,
                                   object_version_number = nvl(object_version_number, 0) + 1
                             WHERE incentive_type_code = 'PMTPLN'
                               AND payrun_id = wksht_rec.payrun_id
                               AND credited_salesrep_id = wksht_rec.salesrep_id
                               AND quota_id = l_calc_rec_tbl(i).quota_id
                                  --R12
                               AND cnpt.org_id = wksht_rec.org_id;
                        END IF; -- End IF l_calc_rec_tbl(i).pmt_amount_adj_rec  <> 0

                        -- Update the Worksheet at the Quota Level
                        UPDATE cn_payment_worksheets
                           SET pmt_amount_calc       = nvl(l_calc_rec_tbl(i).pmt_amount_calc, 0),
                               pmt_amount_adj_rec    = nvl(l_calc_rec_tbl(i).pmt_amount_adj_rec, 0),
                               pmt_amount_adj_nrec   = nvl(l_calc_rec_tbl(i).pmt_amount_adj_nrec, 0),
                               pmt_amount_adj        = nvl(l_calc_rec_tbl(i).pmt_amount_ctr, 0),
                               pmt_amount_recovery   = nvl(l_calc_rec_tbl(i).pmt_amount_rec, 0),
                               last_update_date      = SYSDATE,
                               last_updated_by       = fnd_global.user_id,
                               last_update_login     = fnd_global.login_id,
                               object_version_number = nvl(object_version_number, 0) + 1
                         WHERE payrun_id = wksht_rec.payrun_id
                           AND salesrep_id = wksht_rec.salesrep_id
                           AND quota_id = l_calc_rec_tbl(i).quota_id;

                        IF SQL%ROWCOUNT = 0
                           AND (l_calc_rec_tbl(i)
                           .quota_id <> -1000 OR abs(nvl(l_calc_rec_tbl(i).pmt_amount_calc, 0)) + abs(nvl(l_calc_rec_tbl(i).pmt_amount_adj_rec, 0)) +
                            abs(nvl(l_calc_rec_tbl(i).pmt_amount_adj_nrec, 0)) + abs(nvl(l_calc_rec_tbl(i).pmt_amount_ctr, 0)) +
                            abs(nvl(l_calc_rec_tbl(i).pmt_amount_rec, 0)) <> 0)
                        THEN
                            -- Create the Worksheet at the Quota Level
                            cn_payment_worksheets_pkg.insert_record(x_payrun_id             => wksht_rec.payrun_id,
                                                                    x_salesrep_id           => wksht_rec.salesrep_id,
                                                                    x_quota_id              => l_calc_rec_tbl(i).quota_id,
                                                                    x_credit_type_id        => -1000,
                                                                    x_calc_pmt_amount       => nvl(l_calc_rec_tbl(i).pmt_amount_calc, 0),
                                                                    x_adj_pmt_amount_rec    => nvl(l_calc_rec_tbl(i).pmt_amount_adj_rec, 0),
                                                                    x_adj_pmt_amount_nrec   => nvl(l_calc_rec_tbl(i).pmt_amount_adj_nrec, 0),
                                                                    x_adj_pmt_amount        => nvl(l_calc_rec_tbl(i).pmt_amount_ctr, 0),
                                                                    x_pmt_amount_recovery   => nvl(l_calc_rec_tbl(i).pmt_amount_rec, 0),
                                                                    x_worksheet_status      => 'UNPAID',
                                                                    x_created_by            => fnd_global.user_id,
                                                                    x_creation_date         => SYSDATE,
                                                                    p_org_id                => wksht_rec.org_id,
                                                                    p_object_version_number => 1);
                        END IF;
                    END IF; -- End  IF l_calc_rec_tbl(i).quota_id is NOT NULL

                    -- for summary record
                    l_calc_pmt_amount     := nvl(l_calc_pmt_amount, 0) + nvl(l_calc_rec_tbl(i).pmt_amount_calc, 0);
                    l_adj_pmt_amount_rec  := nvl(l_adj_pmt_amount_rec, 0) + nvl(l_calc_rec_tbl(i).pmt_amount_adj_rec, 0);
                    l_adj_pmt_amount_nrec := nvl(l_adj_pmt_amount_nrec, 0) + nvl(l_calc_rec_tbl(i).pmt_amount_adj_nrec, 0);
                    l_pmt_amount_rec      := nvl(l_pmt_amount_rec, 0) + nvl(l_calc_rec_tbl(i).pmt_amount_rec, 0);
                    l_pmt_amount_ctr      := nvl(l_pmt_amount_ctr, 0) + nvl(l_calc_rec_tbl(i).pmt_amount_ctr, 0);
                END LOOP;
            END IF; -- end  IF l_calc_rec_tbl.COUNT > 0 THEN

            -- UPDATE the Summary Record in the Worksheet
            UPDATE cn_payment_worksheets
               SET pmt_amount_calc       = l_calc_pmt_amount,
                   pmt_amount_adj_rec    = l_adj_pmt_amount_rec,
                   pmt_amount_adj_nrec   = l_adj_pmt_amount_nrec,
                   pmt_amount_adj        = l_pmt_amount_ctr,
                   pmt_amount_recovery   = l_pmt_amount_rec,
                   last_update_date      = SYSDATE,
                   last_updated_by       = fnd_global.user_id,
                   last_update_login     = fnd_global.login_id,
                   object_version_number = nvl(object_version_number, 0) + 1
             WHERE payrun_id = wksht_rec.payrun_id
               AND salesrep_id = wksht_rec.salesrep_id
               AND quota_id IS NULL;

           update_ptd_details (
       	     p_salesrep_id => wksht_rec.salesrep_id ,
       	     p_payrun_id   =>  wksht_rec.payrun_id
           ) ;

            -- Bug 3140343 : Payee Design. set commission_lines to POSTED
            IF l_pay_by_mode = 'Y'
            THEN
                -- Bug 3191079 by jjhuang.
                IF l_ispayee <> 1
                THEN
                    UPDATE cn_commission_lines cls
                       SET posting_status    = 'POSTED',
                           last_update_date  = SYSDATE,
                           last_updated_by   = fnd_global.user_id,
                           last_update_login = fnd_global.login_id
                     WHERE posting_status <> 'POSTED'
                       AND status = 'CALC'
                       AND srp_payee_assign_id IS NULL
                       AND commission_line_id IN (SELECT commission_line_id
                                                    FROM cn_payment_transactions
                                                   WHERE posting_batch_id = l_posting_batch_id);

                ELSE
                    -- payee
                    UPDATE cn_commission_lines cls
                       SET posting_status    = 'POSTED',
                           last_update_date  = SYSDATE,
                           last_updated_by   = fnd_global.user_id,
                           last_update_login = fnd_global.login_id
                     WHERE posting_status <> 'POSTED'
                       AND status = 'CALC'
                       AND srp_payee_assign_id IS NOT NULL
                       AND commission_line_id IN (SELECT commission_line_id
                                                    FROM cn_payment_transactions
                                                   WHERE posting_batch_id = l_posting_batch_id);
                END IF;
            ELSE

                SELECT DISTINCT pw.quota_id
                 BULK COLLECT INTO l_wk_plan_elements
                  FROM cn_payment_worksheets pw
                 WHERE pw.payrun_id = wksht_rec.payrun_id
                   AND pw.salesrep_id = wksht_rec.salesrep_id
                   AND pw.quota_id IS NOT NULL ;

                --PBS
                IF l_ispayee <> 1
                THEN

                  FORALL m IN 1..l_wk_plan_elements.COUNT
                    UPDATE  cn_commission_lines cls
                       SET posting_status    = 'POSTED',
                           last_update_date  = SYSDATE,
                           last_updated_by   = fnd_global.user_id,
                           last_update_login = fnd_global.login_id
                     WHERE posting_status <> 'POSTED'
                       AND credit_type_id = g_credit_type_id
                       AND processed_period_id <= wksht_rec.pay_period_id
                       AND status = 'CALC'
                       AND srp_payee_assign_id IS NULL
                          --R12
                       AND org_id = wksht_rec.org_id
                       AND credited_salesrep_id = wksht_rec.salesrep_id
                       AND quota_id = l_wk_plan_elements(m);

                ELSE
                    UPDATE cn_commission_lines clk
                       SET posting_status    = 'POSTED',
                           last_update_date  = SYSDATE,
                           last_updated_by   = fnd_global.user_id,
                           last_update_login = fnd_global.login_id
                     WHERE processed_period_id <= wksht_rec.pay_period_id
                       AND status = 'CALC'
                       AND credit_type_id = g_credit_type_id
                       AND posting_status <> 'POSTED'
                       AND org_id = wksht_rec.org_id
                       AND clk.srp_payee_assign_id IS NOT NULL
                       AND EXISTS (SELECT 1
                              FROM cn_srp_payee_assigns_all spayee,
                                   cn_payment_worksheets    wksht
                             WHERE clk.srp_payee_assign_id = spayee.srp_payee_assign_id
                               AND spayee.quota_id = wksht.quota_id
                               AND spayee.payee_id = wksht_rec.salesrep_id
                               AND wksht.payrun_id = wksht_rec.payrun_id
                               AND wksht.salesrep_id = wksht_rec.salesrep_id);

                END IF; -- end IF l_ispayee <> 1
            END IF; -- end IF l_pbt_profile_value = 'Y'

            -- for payroll integration population of account
            -- changes for bug#2568937
            -- use if AP / Payroll integration has been enabled.
            IF l_payables_flag = 'Y'
            THEN
                -- Populate ccid's in payment worksheets
                IF (cn_payrun_pvt.populate_ccids(p_payrun_id      => wksht_rec.payrun_id,
                                                 p_salesrep_id    => wksht_rec.salesrep_id,
                                                 p_loading_status => x_loading_status,
                                                 x_loading_status => x_loading_status)) = fnd_api.g_true
                THEN
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
            END IF;

        ELSIF p_operation IN ('LOCK', 'RELEASE_HOLD')
        THEN

            cn_payment_security_pvt.worksheet_action(p_api_version      => p_api_version,
                                                     p_init_msg_list    => p_init_msg_list,
                                                     p_commit           => 'F',
                                                     p_validation_level => p_validation_level,
                                                     x_return_status    => x_return_status,
                                                     x_msg_count        => x_msg_count,
                                                     x_msg_data         => x_msg_data,
                                                     p_worksheet_id     => p_worksheet_id,
                                                     p_action           => p_operation,
                                                     p_do_audit         => fnd_api.g_false);

            IF x_return_status <> fnd_api.g_ret_sts_success
            THEN
                RAISE fnd_api.g_exc_error;
            END IF;

            IF p_operation = 'LOCK'
            THEN

                -- save current image if LOCK worksheet
                set_ced_and_bb(p_api_version   => 1.0,
                               x_return_status => x_return_status,
                               x_msg_count     => x_msg_count,
                               x_msg_data      => x_msg_data,
                               p_worksheet_id  => p_worksheet_id);

                IF x_return_status <> fnd_api.g_ret_sts_success
                THEN
                    RAISE fnd_api.g_exc_error;
                END IF;
            ELSIF p_operation = 'RELEASE_HOLD'
            THEN

                -- Call api to release all hold pmt trx
                cn_pmt_trans_pvt.release_wksht_hold(p_api_version          => p_api_version,
                                                    p_init_msg_list        => p_init_msg_list,
                                                    p_commit               => 'F',
                                                    p_validation_level     => p_validation_level,
                                                    x_return_status        => x_return_status,
                                                    x_msg_count            => x_msg_count,
                                                    x_msg_data             => x_msg_data,
                                                    p_payment_worksheet_id => p_worksheet_id);

                IF x_return_status <> fnd_api.g_ret_sts_success
                THEN
                    RAISE fnd_api.g_exc_error;
                END IF;
            END IF;

            -- set wksht audit
            cn_payment_security_pvt.worksheet_audit(p_worksheet_id  => p_worksheet_id,
                                                    p_payrun_id     => wksht_rec.payrun_id,
                                                    p_salesrep_id   => wksht_rec.salesrep_id,
                                                    p_action        => p_operation,
                                                    x_return_status => x_return_status,
                                                    x_msg_count     => x_msg_count,
                                                    x_msg_data      => x_msg_data);

            IF x_return_status <> fnd_api.g_ret_sts_success
            THEN
                RAISE fnd_api.g_exc_error;
            END IF;
        ELSIF p_operation IN ('UNLOCK', 'SUBMIT')
        THEN
            -- 'UNLOCK', 'SUBMIT'
            cn_payment_security_pvt.worksheet_action(p_api_version      => p_api_version,
                                                     p_init_msg_list    => p_init_msg_list,
                                                     p_commit           => 'F',
                                                     p_validation_level => p_validation_level,
                                                     x_return_status    => x_return_status,
                                                     x_msg_count        => x_msg_count,
                                                     x_msg_data         => x_msg_data,
                                                     p_worksheet_id     => p_worksheet_id,
                                                     p_action           => p_operation);

            IF x_return_status <> fnd_api.g_ret_sts_success
            THEN
                RAISE fnd_api.g_exc_error;
            END IF;
        ELSIF p_operation IN ('APPROVE', 'REJECT')
        THEN
            cn_payment_security_pvt.worksheet_action(p_api_version      => p_api_version,
                                                     p_init_msg_list    => p_init_msg_list,
                                                     p_commit           => 'F',
                                                     p_validation_level => p_validation_level,
                                                     x_return_status    => x_return_status,
                                                     x_msg_count        => x_msg_count,
                                                     x_msg_data         => x_msg_data,
                                                     p_worksheet_id     => p_worksheet_id,
                                                     p_action           => p_operation,
                                                     p_do_audit         => fnd_api.g_true);

            IF x_return_status <> fnd_api.g_ret_sts_success
            THEN
                RAISE fnd_api.g_exc_error;
            END IF;
        ELSIF p_operation IN ('HOLD_ALL', 'RELEASE_ALL', 'RESET_TO_UNPAID')
        THEN
            cn_payment_security_pvt.worksheet_action(p_api_version      => p_api_version,
                                                     p_init_msg_list    => p_init_msg_list,
                                                     p_commit           => 'F',
                                                     p_validation_level => p_validation_level,
                                                     x_return_status    => x_return_status,
                                                     x_msg_count        => x_msg_count,
                                                     x_msg_data         => x_msg_data,
                                                     p_worksheet_id     => p_worksheet_id,
                                                     p_action           => p_operation,
                                                     p_do_audit         => fnd_api.g_true);

            IF x_return_status <> fnd_api.g_ret_sts_success
            THEN
                RAISE fnd_api.g_exc_error;
            END IF;
        END IF;

        --Update object_version_number
        UPDATE cn_payment_worksheets
           SET object_version_number = nvl(object_version_number, 0) + 1,
               last_update_date      = SYSDATE,
               last_updated_by       = fnd_global.user_id,
               last_update_login     = fnd_global.login_id
         WHERE (payrun_id, salesrep_id) IN (SELECT payrun_id,
                                                   salesrep_id
                                              FROM cn_payment_worksheets
                                             WHERE payment_worksheet_id = p_worksheet_id);

        SELECT object_version_number
          INTO x_ovn
          FROM cn_payment_worksheets
         WHERE payment_worksheet_id = p_worksheet_id;

        -- End of API body.
        -- Standard check of p_commit.
        IF fnd_api.to_boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            ROLLBACK TO update_worksheet;
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO update_worksheet;
            x_loading_status := 'UNEXPECTED_ERR';
            x_return_status  := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
        WHEN OTHERS THEN
            ROLLBACK TO update_worksheet;
            x_loading_status := 'UNEXPECTED_ERR';
            x_return_status  := fnd_api.g_ret_sts_unexp_error;

            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
                fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
            END IF;

            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
    END update_worksheet;

    -- ===========================================================================
    -- Procedure : delete_worksheet
    -- Description :
    -- ===========================================================================
    PROCEDURE delete_worksheet
    (
        p_api_version      IN NUMBER,
        p_init_msg_list    IN VARCHAR2,
        p_commit           IN VARCHAR2,
        p_validation_level IN NUMBER,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,
        p_worksheet_id     IN NUMBER,
        p_validation_only  IN VARCHAR2,
        x_status           OUT NOCOPY VARCHAR2,
        x_loading_status   OUT NOCOPY VARCHAR2,
        p_ovn              IN NUMBER
    ) IS
        l_api_name CONSTANT VARCHAR2(30) := 'Delete_Worksheet';
        l_profile_value VARCHAR2(02);

        CURSOR get_worksheet_dtls IS
            SELECT wk.salesrep_id,
                   wk.payrun_id,
                   wk.org_id,
                   pr.payrun_mode
              FROM cn_payment_worksheets wk,
                   cn_payruns            pr
             WHERE payment_worksheet_id = p_worksheet_id
               AND wk.payrun_id = pr.payrun_id;

        --R12 for OA.
        l_validation_only VARCHAR2(1);
        l_has_access      BOOLEAN;
        l_ovn             NUMBER;
    BEGIN
        --
        -- Standard Start of API savepoint
        --
        SAVEPOINT delete_worksheet;

        --
        -- Standard call to check for call compatibility.
        --
        IF NOT fnd_api.compatible_api_call(g_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        --
        -- Initialize message list if p_init_msg_list is set to TRUE.
        --
        IF fnd_api.to_boolean(p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        --
        --  Initialize API return status to success
        --
        x_return_status  := fnd_api.g_ret_sts_success;
        x_loading_status := 'CN_DELETED';

        -- API body
        --R12 for OA.  When p_validation_only = 'Y', only do validation for delete from OA.
        l_validation_only := nvl(p_validation_only, 'N');

        FOR wksht IN get_worksheet_dtls
        LOOP
            cn_payment_security_pvt.worksheet_action(p_api_version      => p_api_version,
                                                     p_init_msg_list    => p_init_msg_list,
                                                     p_commit           => 'F',
                                                     p_validation_level => p_validation_level,
                                                     x_return_status    => x_return_status,
                                                     x_msg_count        => x_msg_count,
                                                     x_msg_data         => x_msg_data,
                                                     p_worksheet_id     => p_worksheet_id,
                                                     p_action           => 'REMOVE',
                                                     p_do_audit         => fnd_api.g_false);

            IF x_return_status <> fnd_api.g_ret_sts_success
            THEN
                RAISE fnd_api.g_exc_error;
            END IF;

            --R12
            EXIT WHEN l_validation_only = 'Y';

            UPDATE cn_payment_transactions
               SET payrun_id         = NULL,
                   waive_flag        = 'N',
                   last_update_date  = SYSDATE,
                   last_updated_by   = fnd_global.user_id,
                   last_update_login = fnd_global.login_id
             WHERE payrun_id = wksht.payrun_id
               AND credited_salesrep_id = wksht.salesrep_id
               AND incentive_type_code = 'PMTPLN_REC';

            -- Bug 2760379 : Do not reset cn_commission_lines
            DELETE FROM cn_payment_transactions
             WHERE incentive_type_code IN ('PMTPLN', 'MANUAL_PAY_ADJ')
               AND payrun_id = wksht.payrun_id
               AND credited_salesrep_id = wksht.salesrep_id;

            -- Bug 2715543
            IF wksht.payrun_mode = 'Y'
            THEN
                -- Bug 2760379 : Do not delete from cn_payment_transactions,
                -- just set the payrun_id to null
                -- 3. Set payrun_id to null for remaining tr
                -- Bug 2795606 : reset paymnet_amount when delete wkshtx
                UPDATE cn_payment_transactions
                   SET payrun_id         = NULL,
                       payment_amount    = amount,
                       last_update_date  = SYSDATE,
                       last_updated_by   = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                 WHERE payrun_id = wksht.payrun_id
                   AND credited_salesrep_id = wksht.salesrep_id
                   AND commission_line_id IS NOT NULL;
            ELSE
                -- Delete cn_payment_transactions for Pay by Summary
                DELETE FROM cn_payment_transactions
                 WHERE payrun_id = wksht.payrun_id
                   AND credited_salesrep_id = wksht.salesrep_id
                   AND nvl(hold_flag, 'N') = 'N';

                UPDATE cn_payment_transactions
                   SET payrun_id         = '',
                       last_update_date  = SYSDATE,
                       last_updated_by   = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                 WHERE payrun_id = wksht.payrun_id
                   AND credited_salesrep_id = wksht.salesrep_id
                   AND nvl(hold_flag, 'N') = 'Y';
            END IF;

            -- Delete the Posting Batches
            DELETE FROM cn_posting_batches cnpb
             WHERE cnpb.posting_batch_id IN (SELECT cnpd.posting_batch_id
                                               FROM cn_payment_transactions cnpd
                                              WHERE cnpd.payrun_id = wksht.payrun_id
                                                AND cnpd.credited_salesrep_id = wksht.salesrep_id
                                                AND nvl(cnpd.hold_flag, 'N') = 'N');

            -- add notes and audit
            cn_payment_security_pvt.worksheet_audit(p_worksheet_id  => p_worksheet_id,
                                                    p_payrun_id     => wksht.payrun_id,
                                                    p_salesrep_id   => wksht.salesrep_id,
                                                    p_action        => 'REMOVE',
                                                    x_return_status => x_return_status,
                                                    x_msg_count     => x_msg_count,
                                                    x_msg_data      => x_msg_data);

            -- Delete the Worksheets
            cn_payment_worksheets_pkg.delete_record(p_salesrep_id => wksht.salesrep_id, p_payrun_id => wksht.payrun_id);
        END LOOP;

        -- End of API body.
        -- Standard check of p_commit.
        IF fnd_api.to_boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        --
        -- Standard call to get message count and if count is 1, get message info.
        --
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            ROLLBACK TO delete_worksheet;
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO delete_worksheet;
            x_loading_status := 'UNEXPECTED_ERR';
            x_return_status  := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
        WHEN OTHERS THEN
            ROLLBACK TO delete_worksheet;
            x_loading_status := 'UNEXPECTED_ERR';
            x_return_status  := fnd_api.g_ret_sts_unexp_error;

            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
                fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
            END IF;

            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
    END delete_worksheet;


    PROCEDURE get_ced_and_bb
    (
        p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2,
        p_commit                IN VARCHAR2,
        p_validation_level      IN NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        p_worksheet_id          IN NUMBER,
        x_bb_prior_period_adj   OUT NOCOPY NUMBER,
        x_bb_pmt_recovery_plans OUT NOCOPY NUMBER,
        x_curr_earnings         OUT NOCOPY NUMBER,
        x_curr_earnings_due     OUT NOCOPY NUMBER,
        x_bb_total              OUT NOCOPY NUMBER
    ) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'get_ced_and_bb';
        l_api_version CONSTANT NUMBER := 1.0;
        l_held_amount_prior NUMBER := 0;

        CURSOR c_wksht_csr IS
            SELECT w.worksheet_status wksht_status,
                   w.quota_id,
                   w.salesrep_id,
                   p.status payrun_status,
                   p.pay_period_id,
                   p.payrun_id,
                   w.org_id --R12
              FROM cn_payment_worksheets w,
                   cn_payruns            p
             WHERE w.payment_worksheet_id = p_worksheet_id
               AND w.payrun_id = p.payrun_id
                  --R12
               AND w.org_id = p.org_id;

        l_wksht_rec c_wksht_csr%ROWTYPE;
    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT get_ced_and_bb;

        -- Standard call to check for call compatibility.
        IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF fnd_api.to_boolean(p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := fnd_api.g_ret_sts_success;
        -- API Body
        x_curr_earnings         := 0;
        x_curr_earnings_due     := 0;
        x_bb_prior_period_adj   := 0;
        x_bb_pmt_recovery_plans := 0;
        x_bb_total              := 0;

        -- Get the Worksheet Info
        OPEN c_wksht_csr;

        FETCH c_wksht_csr
            INTO l_wksht_rec;

        IF c_wksht_csr%ROWCOUNT = 0
        THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
            THEN
                fnd_message.set_name('CN', 'CN_WKSHT_DOES_NOT_EXIST');
                fnd_msg_pub.add;
            END IF;

            RAISE fnd_api.g_exc_error;
        END IF;

        CLOSE c_wksht_csr;

        -- only show summary record
        IF (l_wksht_rec.quota_id IS NULL)
        THEN
            IF ((l_wksht_rec.payrun_status <> 'UNPAID') OR (l_wksht_rec.wksht_status <> 'UNPAID'))
            THEN
                -- get data from cn_payment_worksheets
                SELECT bb_prior_period_adj,
                       bb_pmt_recovery_plans,
                       current_earnings
                  INTO x_bb_prior_period_adj,
                       x_bb_pmt_recovery_plans,
                       x_curr_earnings
                  FROM cn_payment_worksheets
                 WHERE payment_worksheet_id = p_worksheet_id;
            ELSE
                -- get data from cn_srp_periods
                BEGIN
                    -- get curr_earnings from all not null quota_id
                    -- Bug 2690859 :  add '     AND srp.credit_type_id = -1000'
                    -- so only get functional currecny credit type records
                    SELECT SUM(nvl(balance2_dtd, 0) - nvl(balance2_ctd, 0)) curr_earnings
                      INTO x_curr_earnings
                      FROM cn_srp_periods srp
                     WHERE srp.salesrep_id = l_wksht_rec.salesrep_id
                       AND srp.period_id = l_wksht_rec.pay_period_id
                       AND srp.quota_id IS NOT NULL
                       AND srp.credit_type_id = g_credit_type_id
                          --R12
                       AND srp.org_id = l_wksht_rec.org_id;
                EXCEPTION
                    WHEN no_data_found THEN
                        x_curr_earnings := 0;
                END;

                BEGIN
                    -- get data from summary record where quota_id is null
                    SELECT SUM(nvl(balance2_bbd, 0) - nvl(balance2_bbc, 0)) pri_adj,
                           - (SUM(nvl(balance4_bbd, 0) - nvl(balance4_bbc, 0))) - (SUM(nvl(balance4_dtd, 0) - nvl(balance4_ctd, 0))) pmt_recovery
                      INTO x_bb_prior_period_adj,
                           x_bb_pmt_recovery_plans
                      FROM cn_srp_periods srp
                     WHERE srp.quota_id IS NULL
                       AND srp.salesrep_id = l_wksht_rec.salesrep_id
                       AND srp.period_id = l_wksht_rec.pay_period_id
                       AND srp.credit_type_id = g_credit_type_id
                          --R12
                       AND srp.org_id = l_wksht_rec.org_id;
                EXCEPTION
                    WHEN no_data_found THEN
                        x_bb_prior_period_adj   := 0;
                        x_bb_pmt_recovery_plans := 0;
                END;
            END IF;
            -- 01/03/03 pramadas added hold flag check for bug 2710066
            -- commented the code for Bug Fix 2849715
            /* BEGIN
               SELECT SUM(nvl(amount,0))
                  INTO l_held_amount_prior
                  FROM cn_payment_transactions cnpt
                  WHERE cnpt.quota_id IS NOT NULL
                  AND cnpt.credited_salesrep_id = l_wksht_rec.salesrep_id
                  AND cnpt.pay_period_id < l_wksht_rec.pay_period_id
                  AND cnpt.credit_type_id = G_credit_type_id
                  AND cnpt.hold_flag = 'Y'
                  AND cnpt.paid_flag ='N'
                            ;
            EXCEPTION
               WHEN no_data_found THEN
                  l_held_amount_prior := 0 ;
            END;*/
            -- 01/03/03 pramadas added hold flag check for bug 2710066
        END IF;

        x_bb_total          := nvl(x_bb_prior_period_adj, 0) + nvl(x_bb_pmt_recovery_plans, 0);
        x_curr_earnings_due := x_bb_total + nvl(x_curr_earnings, 0); -- + Nvl(l_held_amount_prior,0);

        -- End of API body.
        -- Standard check of p_commit.
        IF fnd_api.to_boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        --
        -- Standard call to get message count and if count is 1, get message info.
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            ROLLBACK TO get_ced_and_bb;
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO get_ced_and_bb;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
        WHEN OTHERS THEN
            ROLLBACK TO get_ced_and_bb;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
                fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
            END IF;

            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
    END get_ced_and_bb;

    --============================================================================
    --Name :set_ced_and_bb
    --Description : Procedure which will be used to set value of current earning
    --              due, begin balance values
    --============================================================================
    PROCEDURE set_ced_and_bb
    (
        p_api_version      IN NUMBER,
        p_init_msg_list    IN VARCHAR2,
        p_commit           IN VARCHAR2,
        p_validation_level IN NUMBER,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,
        p_worksheet_id     IN NUMBER
    ) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'set_ced_and_bb';
        l_api_version CONSTANT NUMBER := 1.0;
        l_held_amount_prior NUMBER := 0;

        CURSOR c_status_csr IS
            SELECT w.worksheet_status wksht_status,
                   w.salesrep_id,
                   p.status payrun_status,
                   p.pay_period_id,
                   p.payrun_id,
                   w.org_id
              FROM cn_payment_worksheets w,
                   cn_payruns            p
             WHERE w.payment_worksheet_id = p_worksheet_id
               AND w.payrun_id = p.payrun_id;

        l_status_rec c_status_csr%ROWTYPE;

        CURSOR c_wksht_sum_csr(l_payrun_id cn_payruns.payrun_id%TYPE, l_srp_id cn_payment_worksheets.salesrep_id%TYPE,
        --R12
        p_org_id cn_payment_worksheets.org_id%TYPE) IS
            SELECT w.payment_worksheet_id,
                   w.quota_id,
                   w.salesrep_id,
                   w.object_version_number
              FROM cn_payment_worksheets w
             WHERE w.payrun_id = l_payrun_id
               AND w.salesrep_id = l_srp_id
               AND w.quota_id IS NULL
               AND w.org_id = p_org_id;

        l_wksht_sum_rec         c_wksht_sum_csr%ROWTYPE;
        l_curr_earnings         NUMBER := 0;
        s_bb_prior_period_adj   NUMBER := 0;
        s_bb_pmt_recovery_plans NUMBER := 0;
        s_curr_earnings_due     NUMBER := 0;
        l_loading_status        VARCHAR2(30);
        -- varialve added for Bug 3140343
        l_ispayee NUMBER := 0;
    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT set_ced_and_bb;

        -- Standard call to check for call compatibility.
        IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF fnd_api.to_boolean(p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := fnd_api.g_ret_sts_success;

        -- API Body
        -- Get the Status Info
        OPEN c_status_csr;

        FETCH c_status_csr
            INTO l_status_rec;

        IF c_status_csr%ROWCOUNT = 0
        THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
            THEN
                fnd_message.set_name('CN', 'CN_WKSHT_DOES_NOT_EXIST');
                fnd_msg_pub.add;
            END IF;

            RAISE fnd_api.g_exc_error;
        END IF;

        CLOSE c_status_csr;

        IF ((l_status_rec.payrun_status = 'UNPAID') AND (l_status_rec.wksht_status = 'UNPAID'))
        THEN
            -- quota_id is null, summary record
            FOR l_wksht_sum_rec IN c_wksht_sum_csr(l_status_rec.payrun_id, l_status_rec.salesrep_id, l_status_rec.org_id)
            LOOP
                BEGIN
                    -- get curr_earnings from all not null quota_id
                    -- Bug 2690859 :  add '     AND srp.credit_type_id = -1000'
                    -- so only get functional currecny credit type records
                    SELECT SUM(nvl(balance2_dtd, 0) - nvl(balance2_ctd, 0)) curr_earnings
                      INTO l_curr_earnings
                      FROM cn_srp_periods srp
                     WHERE srp.salesrep_id = l_wksht_sum_rec.salesrep_id
                       AND srp.period_id = l_status_rec.pay_period_id
                       AND srp.quota_id IS NOT NULL
                       AND srp.credit_type_id = g_credit_type_id
                       AND srp.org_id = l_status_rec.org_id;
                EXCEPTION
                    WHEN no_data_found THEN
                        l_curr_earnings := 0;
                END;

                BEGIN
                    -- get data from summary record where quota_id is null
                    SELECT SUM(nvl(balance2_bbd, 0) - nvl(balance2_bbc, 0)) pri_adj,
                           - (SUM(nvl(balance4_bbd, 0) - nvl(balance4_bbc, 0))) - (SUM(nvl(balance4_dtd, 0) - nvl(balance4_ctd, 0))) pmt_recovery
                      INTO s_bb_prior_period_adj,
                           s_bb_pmt_recovery_plans
                      FROM cn_srp_periods srp
                     WHERE srp.quota_id IS NULL
                       AND srp.salesrep_id = l_wksht_sum_rec.salesrep_id
                       AND srp.period_id = l_status_rec.pay_period_id
                       AND srp.credit_type_id = g_credit_type_id
                       AND srp.org_id = l_status_rec.org_id;
                EXCEPTION
                    WHEN no_data_found THEN
                        s_bb_prior_period_adj   := 0;
                        s_bb_pmt_recovery_plans := 0;
                END;

                -- 01/03/03 pramadas added hold flag check for bug 2710066
                -- commented the code for Bug Fix 2849715

                s_curr_earnings_due := s_bb_prior_period_adj + s_bb_pmt_recovery_plans + l_curr_earnings;
                -- removed  + l_held_amount_prior; (held amount is in s_bb_prior_period_adj)

                -- update worksheet record
                UPDATE cn_payment_worksheets
                   SET bb_prior_period_adj   = s_bb_prior_period_adj,
                       bb_pmt_recovery_plans = s_bb_pmt_recovery_plans,
                       current_earnings      = l_curr_earnings,
                       current_earnings_due  = s_curr_earnings_due,
                       last_update_date      = SYSDATE,
                       last_update_login     = fnd_global.login_id,
                       last_updated_by       = fnd_global.user_id,
                       object_version_number = l_wksht_sum_rec.object_version_number + 1
                 WHERE payment_worksheet_id = l_wksht_sum_rec.payment_worksheet_id;
            END LOOP;

            -- REMOVED cn_worksheet_qg_dtls code => re-create cn_worksheet_qg_dtls
            -- Bug 3140343 : Payee Design.
        END IF;

        -- End of API body.
        -- Standard check of p_commit.
        IF fnd_api.to_boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        --
        -- Standard call to get message count and if count is 1, get message info.
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            ROLLBACK TO set_ced_and_bb;
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO set_ced_and_bb;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
        WHEN OTHERS THEN
            ROLLBACK TO set_ced_and_bb;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
                fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
            END IF;

            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
    END set_ced_and_bb;



PROCEDURE generic_conc_processor
    (
         p_payrun_id    IN NUMBER,
         p_params       IN  conc_params,
         p_org_id       cn_payment_worksheets.org_id%TYPE,
         p_salesrep_tbl IN salesrep_tab_typ,
         x_errbuf       OUT NOCOPY VARCHAR2,
         x_retcode      OUT NOCOPY NUMBER
    ) IS
        l_payrun_id         NUMBER;
        l_logical_batch_id  NUMBER;
        l_max_batch_id      NUMBER;
        l_physical_batch_id NUMBER;
        l_job_count         NUMBER := 0;
        l_conc_request_id   NUMBER(15) := fnd_global.conc_request_id;
        l_runner_count      NUMBER := 0;
        l_error_count       NUMBER := 0;
        l_warning_count     NUMBER := 0;
        mysysdate CONSTANT DATE := SYSDATE;
        l_request_id NUMBER := 0;
        l_sleep_time NUMBER := to_number(nvl(fnd_profile.VALUE('CN_SLEEP_TIME'), '20'));
        duration     NUMBER(7, 1);
        errmsg       VARCHAR2(4000) := '';
        err_num      NUMBER := NULL;
        l_org_id     cn_payruns.org_id%TYPE;
    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT generic_conc_processor;
        -- SUBMIT BATCHES
        fnd_file.put_line(fnd_file.LOG,'Start the batching process for payrun_id = ' || p_payrun_id);
        l_org_id := p_org_id;
        BEGIN
           -- lock payrun when when batching
            BEGIN
                SELECT pr.PAYRUN_ID
                INTO l_payrun_id
                FROM cn_payruns pr
                WHERE pr.PAYRUN_ID = p_payrun_id
                FOR UPDATE NOWAIT;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              fnd_file.put_line(fnd_file.LOG,'Invalid payrun. Could not find payrun with ID = ' || l_payrun_id);
              cn_message_pkg.debug('Invalid payrun. Could not find payrun with ID = ' || l_payrun_id);
              RAISE ;
            END;

            l_max_batch_id := p_salesrep_tbl(p_salesrep_tbl.COUNT).batch_id;

            -- Get logical batch ID
            SELECT cn_process_batches_s2.NEXTVAL
              INTO l_logical_batch_id
              FROM sys.dual;

            fnd_file.put_line(fnd_file.LOG,'Logical Batch ID in cn_process_batches_all = ' || l_logical_batch_id);

            FOR currbatch IN 1 .. l_max_batch_id
            LOOP

                /* Load batches into cn_process_batches*/
                -- sequence s1 is for Physical batch id
                SELECT cn_process_batches_s3.NEXTVAL
                  INTO l_physical_batch_id
                  FROM sys.dual;

               FOR kk IN 1 .. p_salesrep_tbl.COUNT
                LOOP
                    IF (p_salesrep_tbl(kk).batch_id = currbatch)
                    THEN
                    INSERT INTO cn_process_batches
                            (process_batch_id,
                             logical_batch_id,
                             physical_batch_id,
                             srp_period_id,
                             period_id,
                             salesrep_id,
                             status_code,
                             org_id,
                             process_batch_type,
                             creation_date,
                             created_by,
                             last_update_date,
                             last_updated_by,
                             last_update_login,
                             request_id,
                             program_application_id,
                             program_id,
                             program_update_date)
                        VALUES
                            (cn_process_batches_s1.NEXTVAL,
                             l_logical_batch_id,
                             l_physical_batch_id,
                             1,
                             1,
                             p_salesrep_tbl(kk).salesrep_id,
                             'VOID',
                             p_org_id,
                             p_params.conc_program_name,
                             mysysdate,
                             fnd_global.user_id,
                             mysysdate,
                             fnd_global.user_id,
                             fnd_global.login_id,
                             fnd_global.conc_request_id,
                             fnd_global.prog_appl_id,
                             fnd_global.conc_program_id,
                             mysysdate);

                    END IF;

                END LOOP; -- kk
                --COMMIT;

                /***************** Launching Threads ***********************/
                l_job_count := l_job_count + 1;

                -- SUBMIT BATCHES
                fnd_file.put_line(fnd_file.LOG,' Now submit physical batch id ' || l_physical_batch_id);

                conc_submit(p_conc_program     => p_params.conc_program_name,
                            p_description      => 'Runner physical batch ID ' || l_physical_batch_id,
                            p_logical_batch_id => l_logical_batch_id,
                            p_batch_id         => l_physical_batch_id,
                            p_org_id           => l_org_id,
                            p_payrun_id        => l_payrun_id,
                            x_request_id       => l_request_id,
                            p_params           => p_params);
                fnd_file.put_line(fnd_file.LOG,' Created child concurrent request. ID = ' || l_request_id);

            END LOOP; --currbatch

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO generic_conc_processor ;
                x_retcode := 2;
                x_errbuf  := 'Error occured when processing payrun = ' || l_payrun_id || '. Check the error log.';

                err_num := SQLCODE;
                IF err_num = -54
                THEN
                    errmsg := 'This payrun is already involved in another process. Please try again later.';
                    fnd_file.put_line(fnd_file.log, errmsg);
                    x_errbuf := errmsg ;
                    raise_application_error(-20000, errmsg);
                ELSE
                    RAISE;
                END IF;
        END;

        -- commit the child requests and start waiting for the children to complete
        COMMIT ;

        -- Monitor batches
        LOOP
            SELECT COUNT(0)
              INTO l_runner_count
              FROM fnd_concurrent_requests fcr
             WHERE fcr.parent_request_id = l_conc_request_id
               AND fcr.phase_code <> 'C';
            EXIT WHEN l_runner_count = 0;
            dbms_lock.sleep(l_sleep_time);
        END LOOP;

        FOR rs_errors IN (SELECT fcr.request_id,
                                 fcr.actual_completion_date,
                                 fcr.completion_text
                            FROM fnd_concurrent_requests fcr
                           WHERE parent_request_id = l_conc_request_id
                             AND upper(status_code) = 'E')
        LOOP
            l_error_count := l_error_count + 1;
            IF l_error_count = 1
            THEN
                fnd_file.put_line(fnd_file.log, 'ERRORED REQUESTS');
                fnd_file.put_line(fnd_file.log, '================');
            END IF;
            fnd_file.put_line(fnd_file.LOG,'   ' || rs_errors.request_id || ' @ ' || rs_errors.actual_completion_date || ' due to ' || rs_errors.completion_text);
        END LOOP;

        -- Count the warning batches
        l_warning_count := 0;
        BEGIN
            SELECT COUNT(0)
              INTO l_warning_count
              FROM fnd_concurrent_requests fcr
             WHERE parent_request_id = l_conc_request_id
               AND upper(status_code) = 'G';

            fnd_file.put_line(fnd_file.log, 'WARNING REQUESTS: ' || l_warning_count);
        EXCEPTION
            WHEN no_data_found THEN
                NULL;
            WHEN OTHERS THEN
                fnd_file.put_line(fnd_file.log, 'Error getting warnings: ' || SQLERRM);
        END;

        duration := (SYSDATE - mysysdate) * 1440;

        IF l_error_count <> 0
        THEN
            x_retcode := 2;
            x_errbuf  := to_char(l_error_count) || ' batches in error';
        ELSIF l_warning_count <> 0
        THEN
            x_retcode := 1;
            x_errbuf  := 'WARNINGS: ' || to_char(l_warning_count);
        ELSE
            x_retcode := 0;
            x_errbuf  := 'SUCCESS: ';
        END IF;

        x_errbuf := x_errbuf || '.  Worksheet process completed in ' || to_char(duration) ||' minutes. ';

    EXCEPTION
    WHEN OTHERS THEN
        x_retcode := 2;
        x_errbuf  := x_errbuf || '. Error processing payrun ID = ' || l_payrun_id ;
        fnd_file.put_line(fnd_file.log, x_errbuf);
        RAISE ;
    END generic_conc_processor;

        --============================================================================
    -- This procedure is used as executable for the concurrent program
    -- REFRESH_WORKSHEET".This program will take payrun name as the input
    -- and then call the procedure "refresh_worksheet_child" which refreshes
    -- worksheets.
    --============================================================================

    PROCEDURE refresh_worksheet_parent
    (
        errbuf  OUT NOCOPY VARCHAR2,
        retcode OUT NOCOPY NUMBER,
        p_name  cn_payruns.NAME%TYPE
    ) IS
        salesrep_t   salesrep_tab_typ;
        l_batch_sz   NUMBER := 80;
        errmsg       VARCHAR2(4000) := '';
        l_min_period NUMBER;
        l_max_period NUMBER;
        l_payrun_id  NUMBER;
        x_reps_exist NUMBER := 0;

        l_status     VARCHAR2(30);
        --R12
        l_org_id cn_payruns.org_id%TYPE;
        l_conc_params conc_params ;
        l_has_access BOOLEAN;

        CURSOR get_payrun_id_curs IS
            SELECT payrun_id,
                   status
              FROM cn_payruns pr
             WHERE NAME = p_name
             AND org_id = mo_global.get_current_org_id;

      CURSOR c_payrun_srp(c_payrun_id cn_payruns.payrun_id%TYPE, c_batch_sz number) IS
           SELECT salesrep_id,
                   ceil(rownum / c_batch_sz)
              FROM (SELECT DISTINCT wk.salesrep_id
                      FROM cn_payment_worksheets wk
                     WHERE wk.worksheet_status = 'UNPAID'
                       AND wk.quota_id IS NULL
                       AND wk.payrun_id = c_payrun_id
                       AND wk.org_id = mo_global.get_current_org_id);

    BEGIN
        fnd_file.put_line(fnd_file.log, 'Input Parameters Payrun_Name =' || p_name);
        l_has_access := cn_payment_security_pvt.get_security_access(cn_payment_security_pvt.g_type_wksht, cn_payment_security_pvt.g_access_payrun_refresh);
        --Get the salesrep batch size from profile option.
        l_batch_sz := nvl(fnd_profile.value('CN_PMT_SRP_BATCH_SIZE'),251);
        fnd_file.put_line(fnd_file.log, 'Batch Size =' || to_char(l_batch_sz));

        IF l_batch_sz < 1
        THEN
            errmsg := 'The batch size should be greater than zero.';
            fnd_file.put_line(fnd_file.log, errmsg);
            raise_application_error(-20000, errmsg);
        END IF;

        -- TODO Handle error message
        BEGIN
            OPEN get_payrun_id_curs;
            FETCH get_payrun_id_curs
                INTO l_payrun_id, l_status;
            CLOSE get_payrun_id_curs;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                errmsg := 'Invalid payrun name. Could not find payrun with the name = ' || p_name;
                fnd_file.put_line(fnd_file.log, errmsg);
                raise_application_error(-20000, errmsg);
        END;

        IF l_status NOT IN ('UNPAID')
        THEN
            errmsg := 'Cannot perform worksheet refresh when paid is in status = ' || l_status;
            raise_application_error(-20000, errmsg);
        END IF;

        BEGIN

          OPEN c_payrun_srp(l_payrun_id, l_batch_sz);
          LOOP
            FETCH c_payrun_srp
             BULK COLLECT INTO salesrep_t LIMIT 1000;

            /*SELECT salesrep_id,
                   ceil(rownum / l_batch_sz) BULK COLLECT
              INTO salesrep_t
              FROM (SELECT DISTINCT wk.salesrep_id
                      FROM cn_payment_worksheets wk
                     WHERE wk.worksheet_status = 'UNPAID'
                       AND wk.quota_id IS NULL
                       AND wk.payrun_id = l_payrun_id
                       AND wk.org_id = mo_global.get_current_org_id);*/

            l_conc_params.conc_program_name := 'CN_REFRESH_WKSHT_CHILD' ;

            -- batch
            generic_conc_processor(p_payrun_id    => l_payrun_id,
                                   p_salesrep_tbl => salesrep_t,
                                   p_params       => l_conc_params,
                                   p_org_id       => mo_global.get_current_org_id,
                                   x_errbuf       => errbuf,
                                   x_retcode      => retcode);

            EXIT WHEN c_payrun_srp%NOTFOUND;
           END LOOP;
         CLOSE c_payrun_srp;

        EXCEPTION
        WHEN no_data_found THEN
            errmsg := 'No salesreps found that were eligible for worksheet creation in the payrun : ';
            fnd_file.put_line(fnd_file.log, errmsg);
            retcode := 2;
            errbuf  := errmsg;
            RAISE ;
        END;

        fnd_file.put_line(fnd_file.log, errbuf);
        fnd_file.put_line(fnd_file.LOG,'   Count of worksheets to be refreshed = ' || salesrep_t.COUNT);
        fnd_file.put_line(fnd_file.log,'   Completed refresh worksheet process....');

    EXCEPTION
        WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.LOG,'Unexpected exception in cn_payment_worksheet_pvt.refresh_worksheet_parent');
            fnd_file.put_line(fnd_file.log, errmsg);
            fnd_file.put_line(fnd_file.log, SQLERRM);
            RAISE;
    END refresh_worksheet_parent;

  --============================================================================
    --  Name : refresh_worksheet_child
    --  Description : This procedure is used as executable for the concurrent program
    --   "CN_REFRESH_WKSHT_CHILD".This program will take payrun_id as the input
    --  and refresh worksheets for that payrun.
    --============================================================================

    PROCEDURE refresh_worksheet_child
    (
        errbuf             OUT NOCOPY VARCHAR2,
        retcode            OUT NOCOPY NUMBER,
        p_batch_id         IN NUMBER,
        p_payrun_id        IN NUMBER,
        p_logical_batch_id IN NUMBER,
        --R12
        p_org_id           IN       cn_payruns.org_id%TYPE
    ) IS
        x_return_status  VARCHAR2(10) := fnd_api.g_ret_sts_success;
        x_msg_count      NUMBER;
        x_msg_data       VARCHAR2(4000);
        l_worksheet_rec  cn_payment_worksheet_pvt.worksheet_rec_type;
        x_status         VARCHAR2(200);
        x_loading_status VARCHAR2(20) := 'CN_UPDATED';
        l_start_time     DATE;
        l_error_count    NUMBER := 0;
        l_ovn            cn_payment_worksheets.object_version_number%TYPE;
    BEGIN
        l_start_time := SYSDATE;
        fnd_file.put_line(fnd_file.log, '  Input Parameters Payrun_id = ' || p_payrun_id);
        fnd_file.put_line(fnd_file.log, '  Input Parameters Batch_id  = ' || p_batch_id);
        fnd_file.put_line(fnd_file.log, '  Current time               = ' || to_char(l_start_time, 'Dy DD-Mon-YYYY HH24:MI:SS'));

        l_worksheet_rec.payrun_id := p_payrun_id;
        l_worksheet_rec.org_id := p_org_id;

        FOR emp IN (SELECT salesrep_id
                      FROM cn_process_batches
                     WHERE logical_batch_id = p_logical_batch_id
                       AND physical_batch_id = p_batch_id)
        LOOP
            -- Run refresh worksheet for this salesrep.
            l_worksheet_rec.salesrep_id := emp.salesrep_id;
            l_worksheet_rec.call_from   := cn_payment_worksheet_pvt.concurrent_program_call;

            SELECT wk.payment_worksheet_id,wk.object_version_number
              INTO l_worksheet_rec.worksheet_id,l_ovn
              FROM cn_payment_worksheets_all wk
             WHERE wk.payrun_id = l_worksheet_rec.payrun_id
               AND wk.salesrep_id = l_worksheet_rec.salesrep_id
               AND quota_id IS NULL;

            fnd_file.put_line(fnd_file.log,'Refresh worksheet for  = ' || l_worksheet_rec.salesrep_id || ' salesrepID');

            cn_payment_worksheet_pvt.update_worksheet(p_api_version      => 1.0,
                                                      p_init_msg_list    => 'T',
                                                      p_commit           => 'F',
                                                      p_validation_level => fnd_api.g_valid_level_full,
                                                      x_return_status    => x_return_status,
                                                      x_msg_count        => x_msg_count,
                                                      x_msg_data         => x_msg_data,
                                                      p_worksheet_id     => l_worksheet_rec.worksheet_id,
                                                      p_operation        => 'REFRESH',
                                                      x_loading_status   => x_loading_status,
                                                      x_status           => x_status,
                                                      x_ovn              => l_ovn
                                                      );

        END LOOP;

        IF x_return_status <> fnd_api.g_ret_sts_success
        THEN
            l_error_count := l_error_count + 1;

            --ROLLBACK TO create_single_worksheet;
            cn_message_pkg.debug('Error when refreshing Worksheet for :  ' || l_worksheet_rec.salesrep_id);
            fnd_file.put_line(fnd_file.log,'Failed to refresh worksheet for ' || l_worksheet_rec.salesrep_id);

            FOR i IN 1 .. x_msg_count
            LOOP
                fnd_file.put_line(fnd_file.log, 'msg: ' || fnd_msg_pub.get(i, 'F'));
            END LOOP;
            fnd_file.put_line(fnd_file.log, '+------------------------------+');
            ROLLBACK;

        ELSE

            COMMIT;
        END IF;

        IF l_error_count <> 0
        THEN
            retcode := 2;
            errbuf  := '  Batch# ' || p_batch_id || ' : Refresh of worksheets was not successful for some resources. Count = ' || to_char(l_error_count);
            fnd_file.put_line(fnd_file.log, errbuf);
        END IF;

        fnd_file.put_line(fnd_file.LOG,'  Finish time = ' || to_char(SYSDATE, 'Dy DD-Mon-YYYY HH24:MI:SS'));
        fnd_file.put_line(fnd_file.LOG, '  Batch time  = ' || (SYSDATE - l_start_time) * 1400 || ' minutes ');

    EXCEPTION
        WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.LOG,'Unexpected exception in processing the (payrun_id,batch) = ' ||p_payrun_id || ',' || p_batch_id);
            fnd_file.put_line(fnd_file.log, SQLERRM);
            RAISE;

    END refresh_worksheet_child;



END cn_payment_worksheet_pvt;

/
