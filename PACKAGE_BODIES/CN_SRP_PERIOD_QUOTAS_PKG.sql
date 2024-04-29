--------------------------------------------------------
--  DDL for Package Body CN_SRP_PERIOD_QUOTAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_PERIOD_QUOTAS_PKG" AS
  /* $Header: cnsrpqob.pls 120.9.12010000.5 2009/01/22 13:18:59 ppillai ship $ */
  --Date      Name          Description
  ---------------------------------------------------------------------------+
  --  25-JUL-95 P Cook Split the inserts into 3 statements for performance
  --                        Added delete stmnt for source quota type changes
  --                        Fixed locking error by removing period_id comparison.
  --                        Modified update to handle quarters and years
  --  22-AUG-95 P Cook Removed maintenance of cn_srp_per_quota_rc. This is
  --                        now done in other routines
  --  20-NOV-95 P Cook Added who columns.
  --  07-MAR-96 P Cook Bug:346506. distribute_target modified to distribute
  --                        according to the quotas period_type_code(Interval).
  --  10-JUN-99 S Kumar     Modified extensively like changing from start period
  --                        ids start date and end period id to end date.
  --                        1. insert_record procedure is modified to pass the
  --                        start date and end date, still start period id and
  --                        end period id exists but always null value
  --  25-AUG-99             Added the performance_goal column in the
  --                        srp_period_quotas and itd_performance_goal.
  --
  --  22-Apr-03 rarajara   Fixed the bug #2874991
  --  14-Sep-04 jasingh     Fixed the Bug# 3848446
FUNCTION cn_end_date_period
  (
    p_end_date DATE,
    p_org_id NUMBER)
  RETURN cn_acc_period_statuses_v.end_date%TYPE
IS
  l_next_end_date cn_acc_period_statuses_v.end_date%TYPE;
BEGIN
   SELECT end_date
     INTO l_next_end_date
     FROM cn_acc_period_statuses_v
    WHERE p_end_date BETWEEN start_date AND end_date
  AND org_id = p_org_id;
  RETURN l_next_end_date;
EXCEPTION
WHEN no_data_found THEN
  RETURN NULL;
END cn_end_date_period;
--bugfix #2874991 starts
-- Name
--
-- Purpose
--  Insert period quota for each rep using the quota in a period
--
-- Notes
-- This method is called whenever a quota is made
-- active for a new period
PROCEDURE populate_itd_values
  (
    x_start_srp_period_quota_id NUMBER)
                              IS
  l_previous_period_id    NUMBER :=0;
  l_end_period_id         NUMBER :=0;
  l_interval_type_id      NUMBER :=0;
  l_start_period_id       NUMBER :=0;
  l_salesrep_id           NUMBER :=0;
  l_srp_plan_assign_id    NUMBER :=0;
  l_quota_id              NUMBER :=0;
  l_org_id                NUMBER :=0;
  l_input_achieved_itd    NUMBER :=0;
  l_output_achieved_itd   NUMBER :=0;
  l_perf_achieved_itd     NUMBER :=0;
  l_commission_payed_itd  NUMBER :=0;
  l_advance_recovered_itd NUMBER :=0;
  l_advance_to_rec_itd    NUMBER :=0;
  l_recovery_amount_itd   NUMBER :=0;
  l_comm_pend_itd         NUMBER :=0;
  --clku, related to bug 2874991
  l_itd_target           NUMBER := 0;
  l_itd_payment          NUMBER := 0;
  l_performance_goal_itd NUMBER := 0;
  CURSOR max_prev_period_csr(p_interval_type_id NUMBER, p_start_period_id NUMBER, p_org_id NUMBER)
  IS
     SELECT MAX(cal_period_id) max_cal_period_id
       FROM cn_cal_per_int_types_all
      WHERE interval_type_id = p_interval_type_id
    AND org_id               = p_org_id
    AND cal_period_id        < p_start_period_id
    AND interval_number      =
      (SELECT interval_number
         FROM cn_cal_per_int_types_all
        WHERE cal_period_id = p_start_period_id
      AND org_id            = p_org_id
      AND interval_type_id  = p_interval_type_id
      );
  CURSOR max_period_csr(p_interval_type_id NUMBER, p_start_period_id NUMBER, p_org_id NUMBER)
  IS
     SELECT cal_period_id
       FROM cn_cal_per_int_types_all
      WHERE interval_type_id = p_interval_type_id
    AND org_id               = p_org_id
    AND cal_period_id       >= p_start_period_id
    AND interval_number      =
      (SELECT interval_number
         FROM cn_cal_per_int_types_all
        WHERE cal_period_id = p_start_period_id
      AND org_id            = p_org_id
      AND interval_type_id  = p_interval_type_id
      );
BEGIN
   SELECT period_id   ,
    salesrep_id       ,
    srp_plan_assign_id,
    quota_id          ,
    org_id
     INTO l_start_period_id,
    l_salesrep_id          ,
    l_srp_plan_assign_id   ,
    l_quota_id             ,
    l_org_id
     FROM cn_srp_period_quotas_all
    WHERE srp_period_quota_id = x_start_srp_period_quota_id;
   SELECT interval_type_id
     INTO l_interval_type_id
     FROM cn_quotas_all
    WHERE quota_id = l_quota_id;

  OPEN max_prev_period_csr(l_interval_type_id,l_start_period_id,l_org_id);
  FETCH max_prev_period_csr INTO l_previous_period_id ;
  IF max_prev_period_csr%NOTFOUND THEN
    raise NO_DATA_FOUND;
  END IF;
  CLOSE max_prev_period_csr;
  IF l_previous_period_id > 0 THEN
     SELECT NVL(spq.input_achieved_itd,0),
      NVL(spq.output_achieved_itd,0)     ,
      NVL(spq.perf_achieved_itd,0)       ,
      NVL(spq.commission_payed_itd,0)    ,
      NVL(spq.advance_recovered_itd,0)   ,
      NVL(spq.advance_to_rec_itd,0)      ,
      NVL(spq.recovery_amount_itd,0)     ,
      NVL(spq.comm_pend_itd,0)           ,
      -- clku, we need to take care of itd_target, itd_payment, performance_goal_itd also
      NVL(spq.itd_target,0) ,
      NVL(spq.itd_payment,0),
      NVL(spq.performance_goal_itd,0)
       INTO l_input_achieved_itd,
      l_output_achieved_itd     ,
      l_perf_achieved_itd       ,
      l_commission_payed_itd    ,
      l_advance_recovered_itd   ,
      l_advance_to_rec_itd      ,
      l_recovery_amount_itd     ,
      l_comm_pend_itd           ,
      -- clku, we need to take care of itd_target, itd_payment, performance_goal_itd also
      l_itd_target ,
      l_itd_payment,
      l_performance_goal_itd
       FROM cn_srp_period_quotas_all spq
      WHERE salesrep_id    = l_salesrep_id
    AND srp_plan_assign_id = l_srp_plan_assign_id
    AND quota_id           = l_quota_id
    AND period_id          = l_previous_period_id;

    FOR i_period_id IN max_period_csr(l_interval_type_id,l_start_period_id,l_org_id)
    LOOP
      UPDATE cn_srp_period_quotas_all
      SET input_achieved_itd  = nvl(input_achieved_ptd,0) + l_input_achieved_itd   ,
        output_achieved_itd   = nvl(output_achieved_ptd,0) + l_output_achieved_itd  ,
        perf_achieved_itd     = nvl(perf_achieved_ptd,0) + l_perf_achieved_itd    ,
        commission_payed_itd  = nvl(commission_payed_ptd,0) + l_commission_payed_itd ,
        advance_recovered_itd = nvl(advance_recovered_ptd,0) + l_advance_recovered_itd,
        advance_to_rec_itd    = nvl(advance_to_rec_ptd,0) + l_advance_to_rec_itd   ,
        recovery_amount_itd   = nvl(recovery_amount_ptd,0) + l_recovery_amount_itd  ,
        comm_pend_itd         = nvl(comm_pend_ptd,0) + l_comm_pend_itd        ,
        -- clku, we need to take care of itd_target, itd_payment, performance_goal_itd also
        itd_target           = nvl(target_amount,0) + l_itd_target ,
        itd_payment          = nvl(period_payment,0) + l_itd_payment,
        performance_goal_itd = nvl(performance_goal_ptd,0) + l_performance_goal_itd
      WHERE salesrep_id    = l_salesrep_id
      AND srp_plan_assign_id = l_srp_plan_assign_id
      AND quota_id           = l_quota_id
      AND period_id          = i_period_id.cal_period_id;

     SELECT NVL(spq.input_achieved_itd,0),
      NVL(spq.output_achieved_itd,0)     ,
      NVL(spq.perf_achieved_itd,0)       ,
      NVL(spq.commission_payed_itd,0)    ,
      NVL(spq.advance_recovered_itd,0)   ,
      NVL(spq.advance_to_rec_itd,0)      ,
      NVL(spq.recovery_amount_itd,0)     ,
      NVL(spq.comm_pend_itd,0)           ,
      -- clku, we need to take care of itd_target, itd_payment, performance_goal_itd also
      NVL(spq.itd_target,0) ,
      NVL(spq.itd_payment,0),
      NVL(spq.performance_goal_itd,0)
       INTO l_input_achieved_itd,
      l_output_achieved_itd     ,
      l_perf_achieved_itd       ,
      l_commission_payed_itd    ,
      l_advance_recovered_itd   ,
      l_advance_to_rec_itd      ,
      l_recovery_amount_itd     ,
      l_comm_pend_itd           ,
      -- clku, we need to take care of itd_target, itd_payment, performance_goal_itd also
      l_itd_target ,
      l_itd_payment,
      l_performance_goal_itd
       FROM cn_srp_period_quotas_all spq
      WHERE salesrep_id    = l_salesrep_id
    AND srp_plan_assign_id = l_srp_plan_assign_id
    AND quota_id           = l_quota_id
    AND period_id          = i_period_id.cal_period_id;
   END LOOP;
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  NULL;
WHEN OTHERS THEN
  NULL;
END populate_itd_values;
--bugfix #2874991 ends
--bugfix #2874991 starts
-- Name
--
-- Purpose
--  Insert period quota for each rep using the quota in a period
--
-- Notes
-- This method is called whenever a quota is made
-- active for a new period
PROCEDURE sync_ITD_values
  (
    x_quota_id NUMBER)
IS
  CURSOR srp_period_quotas(l_srp_quota_assign_id NUMBER, l_interval_number NUMBER, l_period_year NUMBER)
  IS
     SELECT spq.srp_period_quota_id srp_period_quota_id     ,
      NVL(spq.input_achieved_ptd,0) input_achieved_ptd      ,
      NVL(spq.output_achieved_ptd,0) output_achieved_ptd    ,
      NVL(spq.perf_achieved_ptd,0) perf_achieved_ptd        ,
      NVL(spq.commission_payed_ptd,0) commission_payed_ptd  ,
      NVL(spq.advance_recovered_ptd,0) advance_recovered_ptd,
      NVL(spq.advance_to_rec_ptd,0) advance_to_rec_ptd      ,
      NVL(spq.recovery_amount_ptd,0) recovery_amount_ptd    ,
      NVL(spq.comm_pend_ptd,0) comm_pend_ptd                ,
      NVL(spq.target_amount,0) target_amount                ,
      NVL(spq.period_payment,0) period_payment              ,
      NVL(spq.performance_goal_ptd,0) performance_goal_ptd
       FROM cn_srp_period_quotas_all spq,
      cn_period_statuses_all cp         ,
      cn_cal_per_int_types_all cpit     ,
      cn_quotas_all cq
      WHERE spq.quota_id        = x_quota_id
    AND spq.quota_id            = cq.quota_id
    AND spq.period_id           = cp.period_id
    AND spq.org_id              = cp.org_id
    AND spq.period_id           = cpit.cal_period_id
    AND spq.org_id              = cpit.org_id
    AND spq.srp_quota_assign_id = l_srp_quota_assign_id
    AND cpit.interval_type_id   = cq.interval_type_id
    AND cpit.interval_number    = l_interval_number
    AND cp.period_year          = l_period_year
   ORDER BY spq.period_id;

  pq_rec srp_period_quotas%ROWTYPE;
  -- Get the period quotas that belong to the quota assignment for each
  -- interval
  CURSOR interval_counts
  IS
     SELECT p.srp_quota_assign_id srp_quota_assign_id,
      COUNT(p.srp_period_quota_id) interval_count    ,
      cpit.interval_number interval_number           ,
      p.period_year period_year
       FROM cn_srp_period_quotas_v p,
      cn_period_statuses cp         ,
      cn_cal_per_int_types_all cpit ,
      cn_quotas_all cq
      WHERE p.quota_id        = x_quota_id
    AND p.quota_id            = cq.quota_id
    AND p.period_id           = cp.period_id
    AND cp.period_status     IN ('O', 'F')
    AND cq.org_id             = cp.org_id
    AND cp.period_id          = cpit.cal_period_id
    AND cp.org_id             = cpit.org_id
    AND cpit.interval_type_id = cq.interval_type_id
   GROUP BY p.srp_quota_assign_id,
      cpit.interval_number       ,
      p.period_year ;

  interval_rec interval_counts%ROWTYPE;
  l_target_total            NUMBER := 0;
  l_payment_total           NUMBER := 0;
  l_performance_goal_total  NUMBER := 0;
  l_input_achieved_total    NUMBER :=0;
  l_output_achieved_total   NUMBER :=0;
  l_perf_achieved_total     NUMBER :=0;
  l_commission_payed_total  NUMBER :=0;
  l_advance_recovered_total NUMBER :=0;
  l_advance_to_rec_total    NUMBER :=0;
  l_recovery_amount_total   NUMBER :=0;
  l_comm_pend_total         NUMBER :=0;
BEGIN
  FOR interval_rec IN interval_counts
  LOOP
    -- Initialize for each interval
    l_target_total            := 0;
    l_payment_total           := 0;
    l_performance_goal_total  := 0;
    l_input_achieved_total    :=0;
    l_output_achieved_total   :=0;
    l_perf_achieved_total     :=0;
    l_commission_payed_total  :=0;
    l_advance_recovered_total :=0;
    l_advance_to_rec_total    :=0;
    l_recovery_amount_total   :=0;
    l_comm_pend_total         :=0;
    -- Now that we know the counts per quarter/year we can divide the
    -- quota target correctly for each quarter and set the period quota
    -- target.
    FOR pq_rec IN srp_period_quotas ( l_srp_quota_assign_id => interval_rec.srp_quota_assign_id ,l_interval_number => interval_rec.interval_number ,l_period_year => interval_rec.period_year)
    LOOP
      l_target_total            := l_target_total            + pq_rec.target_amount;
      l_payment_total           := l_payment_total           + pq_rec.period_payment;
      l_performance_goal_total  := l_performance_goal_total  + pq_rec.performance_goal_ptd;
      l_input_achieved_total    := l_input_achieved_total    + pq_rec.input_achieved_ptd;
      l_output_achieved_total   := l_output_achieved_total   + pq_rec.output_achieved_ptd;
      l_perf_achieved_total     := l_perf_achieved_total     + pq_rec.perf_achieved_ptd;
      l_commission_payed_total  := l_commission_payed_total  + pq_rec.commission_payed_ptd;
      l_advance_recovered_total := l_advance_recovered_total + pq_rec.advance_recovered_ptd;
      l_advance_to_rec_total    := l_advance_to_rec_total    + pq_rec.advance_to_rec_ptd;
      l_recovery_amount_total   := l_recovery_amount_total   + pq_rec.recovery_amount_ptd;
      l_comm_pend_total         := l_comm_pend_total         + pq_rec.comm_pend_ptd;
       UPDATE cn_srp_period_quotas_all
      SET itd_target              = NVL(l_target_total,0)            ,
        itd_payment               = NVL(l_payment_total,0)           ,
        performance_goal_itd      = NVL(l_performance_goal_total,0)  ,
        input_achieved_itd        = NVL(l_input_achieved_total, 0)   ,
        output_achieved_itd       = NVL(l_output_achieved_total, 0)  ,
        perf_achieved_itd         = NVL(l_perf_achieved_total, 0)    ,
        commission_payed_itd      = NVL(l_commission_payed_total, 0) ,
        advance_recovered_itd     = NVL(l_advance_recovered_total, 0),
        advance_to_rec_itd        = NVL(l_advance_to_rec_total, 0)   ,
        recovery_amount_itd       = NVL(l_recovery_amount_total, 0)  ,
        comm_pend_itd             = NVL(l_comm_pend_total, 0)
        WHERE srp_period_quota_id = pq_rec.srp_period_quota_id ;
    END LOOP;
  END LOOP;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  NULL;
END sync_ITD_values;
-- Name
--
-- Purpose
--  Insert period quota for each rep using the quota in a period
--
-- Notes        Parameters
--   o Called once for each new srp plan assignment.    x_srp_plan_assign_id
--   o Called one insert of new quota assignment -+
--     once for each srp plan assignment that           x_srp_plan_assign_id
--     references the comp plan id on the new comp      x_quota_id
--     plan quota assignment
--  The quota_id restriction ensures only the newly
--     assigned quota is inserted.
--   o Called on update of srp plan assign period range x_srp_plan_assign_id
--     The not exists subselect is specifically for this
--  situation. refer to delete_row procedure for more info
--
--       |-----Plan Assignment Active range---|
--     |--------- Comp Plan active Range--------|
--   |-----|----------Quota Active Range--|-------|
--   o All quota types have cn_srp_period_quotas althouhg revenue types
--     do not display or allow the user to maintain a target value
-- New Comments Added on 10/JUN/99
-- Start period id and End period is not used any more in the sales comp
-- Instead we pass start Date and End Date
-- We are not removing the column, we assign default null to
-- start_period_id  and end period_id
--   o Called once for each new srp plan assignment. x_srp_plan_assign_id
--   o Called one insert of new quota assignment     x_srp_plan_assign_id,
--                                                   quota_id
--   o calling Place 1.cn_srp_quota_assigns_pkg.insert record
---------------------------------------------------------------------------+
-- PROCEDURE INSERT_RECORD
-- Description:
-- CASE 1: Quota period has changed like end date changed from NOT NULL to
--         null ( means extending the quota active range ) or
--         new end date is greater than old end date
--         called from cn_quotas_pkg
--         Value passed x_quota_id, x_start_date, x_end_date
---------------------------------------------------------------------------+
PROCEDURE Insert_Record
  (
    x_srp_plan_assign_id NUMBER ,
    x_quota_id           NUMBER ,
    x_start_period_id    NUMBER ,
    x_end_period_id      NUMBER ,
    x_start_date DATE := NULL ,
    x_end_date DATE   := NULL )
                      IS
  l_user_id          NUMBER(15);
  l_resp_id          NUMBER(15);
  l_login_id         NUMBER(15);
  x_itd_flag_checked VARCHAR2(1);
  -- Get the itd_flag for each quota
  CURSOR ytd_flag
  IS
     SELECT q.quota_id quota_id,
      q.org_id
       FROM cn_srp_quota_assigns_all qa ,
      cn_quotas_all q
      WHERE qa.srp_plan_assign_id = x_srp_plan_assign_id
      -- do not need itd and formula id anymore, bug 2462767,AND q.calc_formula_id       = cf.calc_formula_id(+)
    AND qa.quota_id = q.quota_id;
  -- clku bug 2845024, performance fix, avoid full table scan by avoiding
  -- is null condition of the cursor.
  CURSOR srp_period_quota_ids1(l_quota_id NUMBER, l_srp_plan_assign_id NUMBER)
  IS
     SELECT srp_period_quota_id
       FROM cn_srp_period_quotas_all
      WHERE quota_id       = l_quota_id
    AND srp_plan_assign_id = l_srp_plan_assign_id ;
  CURSOR srp_period_quota_ids2(l_quota_id NUMBER)
  IS
     SELECT srp_period_quota_id
       FROM cn_srp_period_quotas_all
      WHERE quota_id = l_quota_id;
  --bugfix for #2874991 starts
  CURSOR start_period_quota_id_csr1(p_srp_plan_assign_id NUMBER,p_quota_id NUMBER,x_start_period_id NUMBER)
  IS
     SELECT srp_period_quota_id
       FROM cn_srp_period_quotas_all
      WHERE srp_plan_assign_id = p_srp_plan_assign_id
    AND quota_id               = p_quota_id
    AND period_id              = x_start_period_id;
  CURSOR start_period_quota_id_csr2(p_quota_id NUMBER,x_start_period_id NUMBER)
  IS
     SELECT MAX(srp_period_quota_id)
       FROM cn_srp_period_quotas_all
      WHERE quota_id = p_quota_id
    AND period_id    = x_start_period_id
   GROUP BY srp_plan_assign_id;

  l_srp_start_period_quota_id NUMBER :=0;
  l_count                     NUMBER :=0;
  l_value                     NUMBER;
TYPE l_start_period_quota_id_type
IS
  TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_start_period_quota_id_tbl l_start_period_quota_id_type;
  --bugfix for #2874991 ends
  itd_p_rec ytd_flag%ROWTYPE;
  --clku bug 2845024
  srp_period_quota_id_rec1 srp_period_quota_ids1%ROWTYPE;
  srp_period_quota_id_rec2 srp_period_quota_ids2%ROWTYPE;
  -- get number_dim
  CURSOR get_number_dim(l_quota_id NUMBER)
  IS
     SELECT ccf.number_dim
       FROM cn_quotas_all cq,
      cn_calc_formulas_all ccf
      WHERE cq.quota_id    = l_quota_id
    AND cq.calc_formula_id = ccf.calc_formula_id;

  l_number_dim NUMBER;
BEGIN
  l_user_id               := fnd_global.user_id;
  l_resp_id               := fnd_global.resp_id;
  l_login_id              := fnd_global.login_id;
  IF x_srp_plan_assign_id IS NOT NULL AND x_quota_id IS NULL THEN
    -- A new plan is assigned to a salesrep
    -- case 1: callled from cn_srp_quota_assigns_pkg
    FOR itd_p_rec IN ytd_flag
    LOOP
      -- enhancement, clku, 2431086,we do not check if the PE is ITD or not.
      --IF (itd_p_rec.itd_flag = 'Y') THEN
       INSERT
         INTO cn_srp_period_quotas_all
        (
          srp_period_quota_id  ,
          srp_plan_assign_id   ,
          srp_quota_assign_id  ,
          salesrep_id          ,
          period_id            ,
          quota_id             ,
          target_amount        ,
          itd_target           ,
          period_payment       ,
          itd_payment          ,
          performance_goal_ptd ,
          performance_goal_itd ,
          commission_payed_ptd ,
          creation_date        ,
          created_by           ,
          last_update_date     ,
          last_updated_by      ,
          last_update_login    ,
          org_id
        )
       SELECT cn_srp_period_quotas_s.nextval ,
        qa.srp_plan_assign_id                ,
        qa.srp_quota_assign_id               ,
        pa.salesrep_id                       ,
        p.period_id                          ,
        qa.quota_id                          ,
        NVL(pq.period_target,0)              ,
        pq.itd_target                        ,
        pq.period_payment                    ,
        pq.itd_payment                       ,
        pq.performance_goal                  ,
        pq.performance_goal_itd              ,
        0                                    ,
        sysdate                              ,
        l_user_id                            ,
        sysdate                              ,
        l_user_id                            ,
        l_login_id                           ,
        qa.org_id
         FROM cn_srp_quota_assigns_all qa ,
        cn_period_quotas_all pq           ,
        cn_srp_plan_assigns_all pa        ,
        cn_period_statuses p
        WHERE qa.srp_plan_assign_id                                 = x_srp_plan_assign_id
      AND pa.srp_plan_assign_id                                     = x_srp_plan_assign_id
      AND pa.srp_plan_assign_id                                     = qa.srp_plan_assign_id --bugfix3633222
      AND qa.quota_id                                               = pq.quota_id
      AND pq.period_id                                              = p.period_id
      AND p.period_status                                          IN ('O', 'F')
      AND pq.org_id                                                 = p.org_id
      AND QA.ORG_ID                                                 = PQ.ORG_ID --bug fix 7381426
      AND pq.quota_id                                               = itd_p_rec.quota_id
      AND greatest(p.start_date, NVL(x_start_date, pa.start_date)) <= least(p.end_date, NVL(x_end_date, NVL(pa.end_date,p.end_date)))
      AND NOT EXISTS
        (SELECT 'srp_period_quota already exists'
           FROM cn_srp_period_quotas_all spq
          WHERE spq.srp_quota_assign_id = qa.srp_quota_assign_id
        AND spq.period_id               = p.period_id
        )
        -- bug 2460926, clku, check if all the open period ends before the specified start_date
        -- 2479359, Nvl(x_start_date, pa.start_date) added to deal with NULL x_start_date
      AND EXISTS
        (SELECT r1.end_date
           FROM CN_PERIOD_STATUSES_ALL R1
          WHERE r1.end_date                        >= NVL(x_start_date, pa.start_date)
        AND (R1.PERIOD_SET_ID, R1.PERIOD_TYPE_ID ) IN
          (SELECT CR.PERIOD_SET_ID,
            CR.PERIOD_TYPE_ID
             FROM CN_REPOSITORIES_ALL CR
            WHERE cr.org_id= r1.org_id
          )
        AND R1.PERIOD_STATUS IN ('O', 'F')
        AND r1.org_id         = pa.org_id
        ) ;
      --added for bugfix#2874991
      l_value := NULL;
      OPEN start_period_quota_id_csr1(x_srp_plan_assign_id,itd_p_rec.quota_id,x_start_period_id);
      FETCH start_period_quota_id_csr1 INTO l_value;
      IF l_value                             IS NOT NULL THEN
        l_count                              := l_count+1;
        l_start_period_quota_id_tbl(l_count) := l_value;
      END IF;
      CLOSE start_period_quota_id_csr1;
      --added for bugfix#2874991 ends here
      -- get number_dim
      l_number_dim := 0;
      OPEN get_number_dim(itd_p_rec.quota_id);
      FETCH get_number_dim INTO l_number_dim;

      CLOSE get_number_dim;
      --clku bug 2845024
      IF l_number_dim                 > 1 THEN
        FOR srp_period_quota_id_rec1 IN srp_period_quota_ids1(itd_p_rec.quota_id, x_srp_plan_assign_id)
        LOOP
          populate_srp_period_quotas_ext ('INSERT',srp_period_quota_id_rec1.srp_period_quota_id, itd_p_rec.org_id, l_number_dim);
        END LOOP;
      END IF;
    END LOOP;
    --bugfix #2874991
    IF l_start_period_quota_id_tbl.count > 0 THEN
      FOR counter                       IN 1..l_start_period_quota_id_tbl.count
      LOOP
        populate_itd_values(l_start_period_quota_id_tbl(counter));
      END LOOP;
    END IF;
    --added for bugfix#2874991 ends here
  ELSIF (x_srp_plan_assign_id IS NOT NULL AND x_quota_id IS NOT NULL) THEN
    -- A new quota has been assigned to a compensation plan
    -- Check whether itd_flag for this quota is checked
    -- case 1: called from cn_srp_quota_assigns_pkg.
    -- enhancement, clku, 2431086, we do not check if the PE is ITD or not.
    --IF x_itd_flag_checked = 'Y' THEN
     INSERT
       INTO cn_srp_period_quotas_all
      (
        srp_period_quota_id  ,
        srp_plan_assign_id   ,
        srp_quota_assign_id  ,
        salesrep_id          ,
        period_id            ,
        quota_id             ,
        target_amount        ,
        itd_target           ,
        performance_goal_ptd ,
        performance_goal_itd ,
        period_payment       ,
        itd_payment          ,
        commission_payed_ptd ,
        creation_date        ,
        created_by           ,
        last_update_date     ,
        last_updated_by      ,
        last_update_login    ,
        org_id
      )
     SELECT cn_srp_period_quotas_s.nextval ,
      qa.srp_plan_assign_id                ,
      qa.srp_quota_assign_id               ,
      pa.salesrep_id                       ,
      p.period_id                          ,
      qa.quota_id                          ,
      NVL(pq.period_target,0)              ,
      pq.itd_target                        ,
      pq.performance_goal                  ,
      pq.performance_goal_itd              ,
      pq.period_payment                    ,
      pq.itd_payment                       ,
      0                                    ,
      sysdate                              ,
      l_user_id                            ,
      sysdate                              ,
      l_user_id                            ,
      l_login_id                           ,
      qa.org_id
       FROM cn_srp_quota_assigns_all qa ,
      cn_period_quotas_all pq           ,
      cn_srp_plan_assigns_all pa        ,
      cn_period_statuses p
      WHERE qa.srp_plan_assign_id              = x_srp_plan_assign_id
    AND pa.srp_plan_assign_id                  = qa.srp_plan_assign_id
    AND qa.quota_id                            = x_quota_id
    AND greatest(pa.start_date, p.start_date) <= least(NVL(pa.end_date,p.end_date), p.end_date)
    AND pq.period_id                           = p.period_id
    AND p.period_status                       IN ('O', 'F')
    AND pq.org_id                              = p.org_id
    AND pq.quota_id                            = qa.quota_id
    AND NOT EXISTS
      (SELECT 'srp_period_quota already exists'
         FROM cn_srp_period_quotas_all spq
        WHERE spq.srp_quota_assign_id = qa.srp_quota_assign_id
      AND spq.period_id               = p.period_id
      )
    AND EXISTS
      (SELECT r1.end_date
         FROM cn_acc_period_statuses_v r1
        WHERE r1.end_date > pa.start_date
      AND r1.org_id       = pa.org_id
      );
    --bugfix #2874991 starts
    OPEN start_period_quota_id_csr1(x_srp_plan_assign_id,itd_p_rec.quota_id,x_start_period_id);
    FETCH start_period_quota_id_csr1 INTO l_srp_start_period_quota_id;

    CLOSE start_period_quota_id_csr1;
    IF l_srp_start_period_quota_id <> 0 THEN
      populate_itd_values(l_srp_start_period_quota_id);
    END IF;
    --bugfix #2874991 ends
    -- get number_dim
    l_number_dim := 0;
    OPEN get_number_dim(x_quota_id);
    FETCH get_number_dim INTO l_number_dim;

    CLOSE get_number_dim;
    --clku bug 2845024
    IF l_number_dim                 > 1 THEN
      FOR srp_period_quota_id_rec1 IN srp_period_quota_ids1(x_quota_id, x_srp_plan_assign_id)
      LOOP
        populate_srp_period_quotas_ext ('INSERT',srp_period_quota_id_rec1.srp_period_quota_id, itd_p_rec.org_id, l_number_dim);
      END LOOP;
    END IF;
  ELSIF x_srp_plan_assign_id IS NULL AND x_quota_id IS NOT NULL THEN
    -- Quota's period range has been changed and we are inserting a
    -- new set of records based on the period interval
     INSERT
       INTO cn_srp_period_quotas_all
      (
        srp_period_quota_id  ,
        srp_plan_assign_id   ,
        srp_quota_assign_id  ,
        salesrep_id          ,
        period_id            ,
        quota_id             ,
        target_amount        ,
        itd_target           ,
        period_payment       ,
        itd_payment          ,
        performance_goal_ptd ,
        performance_goal_itd ,
        commission_payed_ptd ,
        creation_date        ,
        created_by           ,
        last_update_date     ,
        last_updated_by      ,
        last_update_login    ,
        org_id
      )
     SELECT cn_srp_period_quotas_s.nextval ,
      qa.srp_plan_assign_id                ,
      qa.srp_quota_assign_id               ,
      pa.salesrep_id                       ,
      p.period_id                          ,
      qa.quota_id                          ,
      0 -- clku, enhancement 2431086, Nvl(q.payment_amount,0)
      ,
      0          ,
      0          ,
      0          ,
      0          ,
      0          ,
      0          ,
      sysdate    ,
      l_user_id  ,
      sysdate    ,
      l_user_id  ,
      l_login_id ,
      qa.org_id
       FROM cn_srp_quota_assigns_all qa ,
      cn_quotas_all q                   ,
      cn_srp_plan_assigns_all pa        ,
      cn_acc_period_statuses_v p
      -- bug fix 4042235
      ,
      cn_period_statuses p2 ,
      cn_period_statuses p3
      WHERE qa.srp_plan_assign_id = pa.srp_plan_assign_id
    AND qa.quota_id               = x_quota_id
    AND q.quota_id                = x_quota_id
    AND q.quota_id                = qa.quota_id --bugfix#3633222
    AND p.org_id                  = qa.org_id
    AND (
      -- bug 2150333, changed to improved performance
      -- set 1: pa.start_date
      (pa.start_date BETWEEN p2.start_date AND p2.end_date
    AND pa.org_id        = p2.org_id)
    AND p.start_date    >= p2.start_date
    AND p.period_type_id = p2.period_type_id
    AND p.period_set_id  = p2.period_set_id
      -- set 2: pa.end_date
      -- clku, fixed a date insert issue
    AND (least(NVL(pa.end_date,p.end_date), p.end_date) BETWEEN p3.start_date AND p3.end_date)
    AND p.end_date                           <= p3.end_date
    AND p.org_id                              = p3.org_id
    AND p.period_type_id                      = p3.period_type_id
    AND p.period_set_id                       = p3.period_set_id )
    AND greatest(p.start_date, x_start_date) <= least(p.end_date, NVL(x_end_date, p.end_date))
    AND NOT EXISTS
      (SELECT 'srp_quota_assign already exists'
         FROM cn_srp_period_quotas_all pq
        WHERE pq.srp_quota_assign_id = qa.srp_quota_assign_id
      AND pq.period_id               = p.period_id
      )
      -- bug 2460926, check if all the open period ends before the specified start_date
    AND EXISTS
      (SELECT r1.end_date
         FROM cn_acc_period_statuses_v r1
        WHERE r1.end_date > x_start_date
      AND r1.org_id       = pa.org_id
      ) ;
    --bugfix #2874991 starts
    OPEN start_period_quota_id_csr2(x_quota_id,x_start_period_id);
    FETCH start_period_quota_id_csr2 BULK COLLECT
       INTO l_start_period_quota_id_tbl;

    CLOSE start_period_quota_id_csr2;
    IF l_start_period_quota_id_tbl.count > 0 THEN
      FOR counter                       IN 1..l_start_period_quota_id_tbl.count
      LOOP
        populate_itd_values(l_start_period_quota_id_tbl(counter));
      END LOOP;
    END IF;
    --bugfix #2874991 ends
    -- get number_dim
    l_number_dim := 0;
    OPEN get_number_dim(x_quota_id);
    FETCH get_number_dim INTO l_number_dim;

    CLOSE get_number_dim;
    --clku bug 2845024
    IF l_number_dim                 > 1 THEN
      FOR srp_period_quota_id_rec2 IN srp_period_quota_ids2(x_quota_id)
      LOOP
        populate_srp_period_quotas_ext ('INSERT',srp_period_quota_id_rec2.srp_period_quota_id, itd_p_rec.org_id, l_number_dim);
      END LOOP;
    END IF;
  END IF;
  -- End Insert Record.
END Insert_Record;
---------------------------------------------------------------------------+
-- PROCEDURE LOCK RECORD
---------------------------------------------------------------------------+
PROCEDURE lock_record
  (
    x_srp_period_quota_id NUMBER ,
    x_period_id           NUMBER ,
    x_target_amount       NUMBER)
IS
  CURSOR c
  IS
     SELECT target_amount
       FROM cn_srp_period_quotas_all
      WHERE srp_period_quota_id = x_srp_period_quota_id FOR UPDATE OF srp_period_quota_id NOWAIT;

  recinfo c%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  IF (c%notfound) THEN
    CLOSE C;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE C;
  IF ( recinfo.target_amount = x_target_amount) THEN
    RETURN;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;
  -- End Lock Record.
END lock_record;
---------------------------------------------------------------------------+
-- PROCEDURE UPDATE RECORD
---------------------------------------------------------------------------+
PROCEDURE update_record
  (
    x_period_target_unit_code VARCHAR2 ,
    x_srp_period_quota_id     NUMBER ,
    x_srp_quota_assign_id     NUMBER ,
    x_period_id               NUMBER ,
    x_target_amount           NUMBER ,
    x_period_payment          NUMBER ,
    x_performance_goal        NUMBER ,
    x_quarter_num             NUMBER ,
    x_period_year             NUMBER ,
    x_quota_type_code         VARCHAR2 ,
    x_quota_id                NUMBER := NULL -- only for bonus pay
    ,
    x_salesrep_id NUMBER := NULL -- only for bonus pay
    ,
    x_end_date DATE := NULL -- only for bonus pay
    ,
    x_commission_payed_ptd NUMBER := NULL -- only for bonus pay
    ,
    x_last_update_date DATE ,
    x_last_updated_by   NUMBER ,
    x_last_update_login NUMBER)
IS
  -- Count the number of periods in each quarter/year combination that the
  -- quota assignment covers
  CURSOR quart_counts
  IS
     SELECT COUNT(srp_period_quota_id) quart_yr_count ,
      quarter_num                                     ,
      period_year
       FROM cn_srp_period_quotas_v
      WHERE srp_quota_assign_id = x_srp_quota_assign_id
   GROUP BY quarter_num,
      period_year ;

  quart_rec quart_counts%ROWTYPE;
  -- Count the number of periods in each year that the quota assignment
  -- covers.
  CURSOR year_counts
  IS
     SELECT COUNT(srp_period_quota_id) year_count ,
      period_year
       FROM cn_srp_period_quotas_v
      WHERE srp_quota_assign_id = x_srp_quota_assign_id
   GROUP BY period_year ;

  year_rec year_counts%ROWTYPE;
  CURSOR period_quotas(l_interval_number NUMBER, l_period_year NUMBER)
  IS
     SELECT spq.srp_period_quota_id ,
      spq.target_amount             ,
      spq.period_payment            ,
      spq.performance_goal_ptd
       FROM cn_srp_period_quotas_v spq,
      cn_period_statuses cp           ,
      cn_cal_per_int_types_all cpit   ,
      cn_quotas_all cq
      WHERE spq.srp_quota_assign_id = x_srp_quota_assign_id
    AND spq.quota_id                = cq.quota_id
    AND spq.period_id               = cp.period_id
    AND cp.period_status           IN ('O', 'F')
    AND cq.org_id                   = cp.org_id
    AND cp.period_id                = cpit.cal_period_id
    AND cp.org_id                   = cpit.org_id
    AND cpit.interval_type_id       = cq.interval_type_id
    AND cpit.interval_number        = l_interval_number
    AND spq.period_year             = l_period_year
   ORDER BY spq.period_id ;

  pq_rec period_quotas%ROWTYPE;
  -- Get the period quotas that belong to the quota assignment for each
  -- interval
  CURSOR interval_counts
  IS
     SELECT COUNT(spq.srp_period_quota_id) interval_count,
      cpit.interval_number interval_number               ,
      spq.period_year period_year
       FROM cn_srp_period_quotas_v spq,
      cn_period_statuses cp           ,
      cn_cal_per_int_types_all cpit   ,
      cn_quotas_all cq
      WHERE spq.srp_quota_assign_id = x_srp_quota_assign_id
    AND spq.quota_id                = cq.quota_id
    AND spq.period_id               = cp.period_id
    AND cp.period_status           IN ('O', 'F')
    AND cq.org_id                   = cp.org_id
    AND cp.period_id                = cpit.cal_period_id
    AND cp.org_id                   = cpit.org_id
    AND cpit.interval_type_id       = cq.interval_type_id
   GROUP BY cpit.interval_number,
      spq.period_year ;

  interval_rec interval_counts%ROWTYPE;
  -- added for intelligent calculation
  CURSOR l_get_intel_temp_csr
  IS
     SELECT period.target_amount,
      period.period_payment     ,
      srp.name                  ,
      acc.start_date            ,
      acc.end_date              ,
      srp.org_id
       FROM cn_srp_period_quotas_all period,
      cn_salesreps srp                     ,
      cn_period_statuses acc
      WHERE period.srp_period_quota_id = x_srp_period_quota_id
    AND acc.period_id                  = period.period_id
    AND acc.org_id                     = period.org_id
    AND acc.period_status             IN ('O', 'F')
    AND srp.salesrep_id                = period.salesrep_id
    AND srp.org_id                     = period.org_id;

  l_temp_target_amount  NUMBER;
  l_temp_period_payment NUMBER;
  l_temp_salesrep_name  VARCHAR2(240);
  l_temp_start_date DATE;
  l_temp_end_date DATE;
  l_temp_org_id NUMBER;
  -- end of add
  l_target_total           NUMBER;
  l_payment_total          NUMBER;
  l_performance_goal_total NUMBER;
  l_commission_payed_total NUMBER;
  l_target_amount          NUMBER;
  l_period_payment         NUMBER;
  l_performance_goal       NUMBER;
  l_commission_payed       NUMBER;
  g_ext_precision          NUMBER;
BEGIN
  -- get precision
   SELECT c.extended_precision
     INTO g_ext_precision
     FROM cn_repositories r,
    gl_sets_of_books b     ,
    fnd_currencies c       ,
    cn_srp_period_quotas spq
    WHERE r.org_id            = spq.org_id
  AND r.set_of_books_id       = b.set_of_books_id
  AND b.currency_code         = c.currency_code
  AND spq.srp_period_quota_id = x_srp_period_quota_id;
  IF x_quota_type_code       IN ('EXTERNAL','FORMULA') THEN
    -- newly added by Kai Chen for intellegent calculaltion
    -- make event on target_amount and period_amount
    OPEN l_get_intel_temp_csr;
    FETCH l_get_intel_temp_csr
       INTO l_temp_target_amount,
      l_temp_period_payment     ,
      l_temp_salesrep_name      ,
      l_temp_start_date         ,
      l_temp_end_date           ,
      l_temp_org_id;

    CLOSE l_get_intel_temp_csr;
    -- end of addition
     UPDATE cn_srp_period_quotas_all
    SET target_amount           = ROUND(NVL(x_target_amount, 0), g_ext_precision),
      period_payment            = ROUND(NVL(x_period_payment,0), g_ext_precision),
      performance_goal_ptd      = ROUND(NVL(x_performance_goal,0), g_ext_precision)
      WHERE srp_period_quota_id = x_srp_period_quota_id ;
    -- newly added for intel calc
    IF (l_temp_target_amount <> x_target_amount ) OR (l_temp_period_payment <> x_period_payment) THEN
      cn_mark_events_pkg.mark_event_srp_period_quota( 'CHANGE_SRP_QUOTA_CALC', l_temp_salesrep_name, x_srp_period_quota_id, NULL, NULL, l_temp_start_date, NULL, l_temp_end_date, l_temp_org_id);
    END IF;
    -- end of addition
    FOR interval_rec IN interval_counts
    LOOP
      -- Initialize for each interval
      l_target_total           := 0;
      l_payment_total          := 0;
      l_performance_goal_total := 0;
      -- Now that we know the counts per quarter/year we can divide the
      -- quota target correctly for each quarter and set the period quota
      -- target.
      FOR pq_rec IN period_quotas ( l_interval_number => interval_rec.interval_number ,l_period_year => interval_rec.period_year)
      LOOP
        l_target_total           := l_target_total           + pq_rec.target_amount;
        l_payment_total          := l_payment_total          + pq_rec.period_payment;
        l_performance_goal_total := l_performance_goal_total + pq_rec.performance_goal_ptd;
         UPDATE cn_srp_period_quotas_all
        SET itd_target              = ROUND(NVL(l_target_total,0), g_ext_precision) ,
          itd_payment               = ROUND(NVL(l_payment_total,0), g_ext_precision),
          performance_goal_itd      = ROUND(NVL(l_performance_goal_total,0),g_ext_precision)
          WHERE srp_period_quota_id = pq_rec.srp_period_quota_id ;
      END LOOP;
    END LOOP;
  ELSE
    -- only in the case of bonus at the time payee run Bonus commission update
    IF x_salesrep_id IS NOT NULL AND x_end_date IS NOT NULL AND x_quota_id IS NOT NULL THEN
       UPDATE cn_srp_period_quotas_all spq
      SET spq.commission_payed_ptd = x_commission_payed_ptd +spq.commission_payed_ptd
        WHERE spq.salesrep_id      = x_salesrep_id
      AND spq.quota_id             = x_quota_id
      AND EXISTS
        (SELECT 1
           FROM cn_period_statuses aps
          WHERE x_end_date BETWEEN aps.start_date AND aps.end_date
        AND aps.period_id      = spq.period_id
        AND aps.period_status IN ('O', 'F')
        AND aps.org_id         = spq.org_id
        ) ;
    END IF;
  END IF;
END Update_Record;
-- Name
--
-- Purpose
--  Delete period quota from each rep using the quota in a period
--
-- When the procedure is called     Passed Parameters
-- 1. after delete of srp plan assignment.     x_srp_plan_assign_id
-- 2. after update of srp plan assign period range    x_srp_plan_assign_id
-- We cannot delete all period quotas and then x_start_date
-- simply resinsert for the new period range x_end_date
--  Note:
--      because we want to keep the original target
--      distribution on the periods that remain.
--      NB This is an oracle internal requirement.29/mar/95
-- 3. after delete of comp plan quota assignment  x_srp_plan_assign_id
--       x_quota_id
--
---------------------------------------------------------------------------+
-- PROCEDURE DELETE_RECORD
-- Description:
-- Case 1: Delete will be called from cn_quotas date range has changed
--         if end date is less than the end date of the old quota date
--         Delete will be called from cn_quotas if start_date <> old_start_dt
--         called from cn_quotas_pkg.
--         Values Passed x_quota_id( M) , x_start_date, x_end_date
--
-- Case 2: Delete will be called from cn_period_quotas if the amount
--         columns get updated and check the srp_plan_assigns customised
--         flag if N then delete delete the srp_period_quotas and re create.
--         called from cn_period_quotas
--         Values Passed x_quota_id (M )
--
-- Case 3: Delete will be called from cn_srp_plan_assigns date range has
--         changed if end date is less than the end date of the old plan date
--         Delete will be called from cn_srp_plan_assigns if start_date
--         <> old_start_dt called from cn_srp_plan_assigns_pkg
--         Values Passed : x_srp_plan_assign_id, x_start_date, x_end_date
--
-- Case 4 Delete srp_plan_assigns Called cn_srp_quota_assigns and
--        cn_srp_quota_assigns make a call here
--        srp_plan_assign_id and/or quota_id
---------------------------------------------------------------------------+
PROCEDURE Delete_Record
  (
    x_srp_plan_assign_id NUMBER ,
    x_quota_id           NUMBER ,
    x_start_period_id    NUMBER ,
    x_end_period_id      NUMBER ,
    x_start_date DATE         := NULL ,
    x_end_date DATE           := NULL )
                              IS
  l_return_status  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS ;
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
  l_loading_status VARCHAR2(2000);
  l_org_id         NUMBER;
  CURSOR srp_period_quota_ids(l_quota_id NUMBER)
  IS
     SELECT srp_period_quota_id,
      org_id
       FROM cn_srp_period_quotas_all
      WHERE quota_id       = l_quota_id
    AND srp_plan_assign_id = NVL(x_srp_plan_assign_id, srp_plan_assign_id)
    AND EXISTS
      (SELECT 1
         FROM cn_period_statuses p
        WHERE TRUNC(p.start_date)           >= TRUNC(NVL(x_start_date,p.start_date))
      AND TRUNC(p.end_date)                 <= TRUNC(NVL(x_end_date ,p.end_date))
      AND cn_srp_period_quotas_all.period_id = p.period_id
      AND p.period_status                   IN ('O', 'F')
      AND cn_srp_period_quotas_all.org_id    = p.org_id
      );

  l_srp_prd_rec cn_srp_periods_pvt.delta_srp_period_rec_type := cn_srp_periods_pvt.g_miss_delta_srp_period_rec;
  CURSOR l_bal_id
  IS
     SELECT salesrep_id,
      period_id        ,
      credit_type_id   ,
      role_id          ,
      balance2_dtd     ,
      balance3_ctd     ,
      srp_period_id
       FROM cn_srp_periods_all
      WHERE quota_id = x_quota_id
    AND org_id       = l_org_id
    AND EXISTS
      (SELECT 1
         FROM cn_period_statuses p
        WHERE TRUNC(p.start_date)     >= TRUNC(NVL(x_start_date,p.start_date))
      AND TRUNC(p.end_date)           <= TRUNC(NVL(x_end_date ,p.end_date))
      AND cn_srp_periods_all.period_id = p.period_id
      AND p.period_status             IN ('O', 'F')
      AND cn_srp_periods_all.org_id    = p.org_id
      )
  AND (balance2_dtd <> 0
  OR balance3_ctd   <> 0)
 ORDER BY salesrep_id,
    credit_type_id   ,
    role_id          ,
    period_id;

  l_bal_rec l_bal_id%ROWTYPE;
  srp_period_quota_id_rec srp_period_quota_ids%ROWTYPE;
  -- get number_dim
  CURSOR get_number_dim(l_quota_id NUMBER)
  IS
     SELECT ccf.number_dim,
      cq.org_id
       FROM cn_quotas_all cq,
      cn_calc_formulas_all ccf
      WHERE cq.quota_id    = l_quota_id
    AND cq.calc_formula_id = ccf.calc_formula_id;

  l_number_dim NUMBER;
  CURSOR get_quotas
  IS
     SELECT quota_id
       FROM cn_srp_quota_assigns_all
      WHERE srp_plan_assign_id = x_srp_plan_assign_id;

  l_last_period_id   NUMBER := -1;
  l_last_salesrep_id NUMBER := -1;
  l_last_ct_id       NUMBER := -1;
  l_last_role_id     NUMBER := -1;
  l_end_date_pd DATE;
BEGIN
  -- maybe we don't need to check srp_period_quotas_ext
  IF x_quota_id  IS NOT NULL THEN
    l_number_dim := 0;
    OPEN get_number_dim(x_quota_id);
    FETCH get_number_dim INTO l_number_dim, l_org_id;

    CLOSE get_number_dim;
    IF l_number_dim                > 1 THEN
      FOR srp_period_quota_id_rec IN srp_period_quota_ids(x_quota_id)
      LOOP
        populate_srp_period_quotas_ext('DELETE',srp_period_quota_id_rec.srp_period_quota_id, srp_period_quota_id_rec.org_id);
      END LOOP;
    END IF;
  ELSE
    FOR q IN get_quotas
    LOOP
      l_number_dim := 0;
      OPEN get_number_dim(q.quota_id);
      FETCH get_number_dim INTO l_number_dim, l_org_id;

      CLOSE get_number_dim;
      IF l_number_dim                > 1 THEN
        FOR srp_period_quota_id_rec IN srp_period_quota_ids(q.quota_id)
        LOOP
          populate_srp_period_quotas_ext('DELETE',srp_period_quota_id_rec.srp_period_quota_id, srp_period_quota_id_rec.org_id);
        END LOOP;
      END IF;
    END LOOP;
  END IF;
  IF x_srp_plan_assign_id IS NOT NULL THEN
    IF x_quota_id         IS NULL THEN
      IF x_start_date     IS NULL THEN
        -- Deleted plan assignment
         DELETE
           FROM cn_srp_period_quotas_all
          WHERE srp_plan_assign_id = x_srp_plan_assign_id ;
      ELSE
        -- make sure we have the right org ID
         SELECT org_id
           INTO l_org_id
           FROM cn_srp_plan_assigns
          WHERE srp_plan_assign_id = x_srp_plan_assign_id;
        -- get end date period of x_end_date
        l_end_date_pd := TRUNC(cn_end_date_period(x_end_date, l_org_id));
        -- plan assignment range changed
         DELETE
           FROM cn_srp_period_quotas_all
          WHERE srp_plan_assign_id = x_srp_plan_assign_id
        AND EXISTS
          (SELECT 1
             FROM cn_period_statuses p
            WHERE TRUNC(p.start_date) >= TRUNC(NVL(x_start_date,p.start_date))
            -- following line changed for bug 4424669, 4885986
          AND TRUNC(p.end_date) <= NVL(l_end_date_pd, p.end_date)
            --AND trunc(p.end_date)  <=     trunc(cn_end_date_period(nvl(x_end_date  ,p.end_date), p.org_id))
          AND p.period_status                   IN ('O', 'F')
          AND cn_srp_period_quotas_all.period_id = p.period_id
          AND cn_srp_period_quotas_all.org_id    = p.org_id
          );
      END IF;
    ELSE -- Quota id IS NOT NULL
      -- quota is no longer assigned to the comp plan
      -- same as the start date us null
       DELETE
         FROM cn_srp_period_quotas_all
        WHERE srp_plan_assign_id             = x_srp_plan_assign_id
      AND quota_id                           = x_quota_id
      AND NVL(x_start_period_id, period_id) <= period_id -- Bug 3848446, Fixed by Jagpreet Singh.
        ;
    END IF;
  ELSE -- srp_plan_assign_id is NULL
    -- changed to no_sync for bug 4019235
    FOR l_bal_rec IN l_bal_id
    LOOP
      l_srp_prd_rec.srp_period_id                                       := l_bal_rec.srp_period_id;
      l_srp_prd_rec.del_balance2_dtd                                    := l_bal_rec.balance2_dtd*(-1);
      l_srp_prd_rec.del_balance3_ctd                                    := l_bal_rec.balance3_ctd*(-1);
      cn_srp_periods_pvt.Update_Delta_Srp_Pds_No_Sync (p_api_version     => 1.0, x_return_status => l_return_status, x_msg_count => l_msg_count, x_msg_data => l_msg_data, p_del_srp_prd_rec => l_srp_prd_rec, x_loading_status => l_loading_status);
      IF l_bal_rec.salesrep_id                                          <> l_last_salesrep_id OR l_bal_rec.role_id <> l_last_role_id OR l_bal_rec.credit_type_id <> l_last_ct_id THEN
        IF l_last_salesrep_id                                           <> -1 THEN
          cn_srp_periods_pvt.sync_accum_balances_start_pd (p_salesrep_id => l_last_salesrep_id, p_org_id => l_org_id, p_credit_type_id => l_last_ct_id, p_role_id => l_last_role_id, p_start_period_id => l_last_period_id);
        END IF;
        l_last_salesrep_id := l_bal_rec.salesrep_id;
        l_last_role_id     := l_bal_rec.role_id;
        l_last_ct_id       := l_bal_rec.credit_type_id;
        l_last_period_id   := l_bal_rec.period_id;
      END IF;
    END LOOP;
    IF l_last_salesrep_id                                           <> -1 THEN
      cn_srp_periods_pvt.sync_accum_balances_start_pd (p_salesrep_id => l_last_salesrep_id, p_org_id => l_org_id, p_credit_type_id => l_last_ct_id, p_role_id => l_last_role_id, p_start_period_id => l_last_period_id);
    END IF;
    -- done with changes for bug 4019235
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- quota date range changed. remove the old periods in preparation
    -- for insert of new range
     DELETE
       FROM cn_srp_period_quotas_all
      WHERE quota_id = x_quota_id
    AND EXISTS
      (SELECT 1
         FROM cn_period_statuses p
        WHERE TRUNC(p.start_date)           >= TRUNC(NVL(x_start_date,p.start_date))
      AND TRUNC(p.end_date)                 <= TRUNC(NVL(x_end_date ,p.end_date))
      AND cn_srp_period_quotas_all.period_id = p.period_id
      AND p.period_status                   IN ('O', 'F')
      AND cn_srp_period_quotas_all.org_id    = p.org_id
      );
  END IF;
END Delete_Record;
---------------------------------------------------------------------------+
-- PROCEDURE BEGIN_RECORD
---------------------------------------------------------------------------+
PROCEDURE Begin_Record
  (
    x_operation               VARCHAR2 ,
    x_period_target_unit_code VARCHAR2 ,
    x_srp_period_quota_id     NUMBER ,
    x_srp_quota_assign_id     NUMBER ,
    x_srp_plan_assign_id      NUMBER ,
    x_quota_id                NUMBER ,
    x_period_id               NUMBER ,
    x_target_amount           NUMBER ,
    x_period_payment          NUMBER ,
    x_performance_goal        NUMBER ,
    x_quarter_num             NUMBER ,
    x_period_year             NUMBER ,
    x_quota_type_code         VARCHAR2 ,
    x_salesrep_id             NUMBER := NULL -- only for bonus pay
    ,
    x_end_date DATE := NULL -- only for
    ,
    x_commission_payed_ptd NUMBER := NULL -- only for bonus pay
    ,
    x_creation_date DATE ,
    x_created_by NUMBER ,
    x_last_update_date DATE ,
    x_last_updated_by   NUMBER ,
    x_last_update_login NUMBER )
IS
BEGIN
  IF x_operation = 'INSERT' THEN
    -- insert the record for the given quota and salesrep
    Insert_Record( x_srp_plan_assign_id => x_srp_plan_assign_id ,x_quota_id => x_quota_id ,x_start_period_id => NULL ,x_end_period_id => NULL ,x_start_date => NULL ,x_end_date => NULL );
  ELSIF x_operation                     = 'UPDATE' THEN
    -- Update record
    Update_Record ( x_period_target_unit_code => x_period_target_unit_code ,
                    x_srp_period_quota_id => x_srp_period_quota_id ,
                    x_srp_quota_assign_id => x_srp_quota_assign_id ,
                    x_period_id => x_period_id ,
                    x_target_amount => x_target_amount ,
                    x_period_payment => x_period_payment ,
                    x_performance_goal => x_performance_goal ,
                    x_quarter_num => x_quarter_num ,
                    x_period_year => x_period_year ,
                    x_quota_type_code => x_quota_type_code ,
                    x_quota_id => x_quota_id ,
                    x_salesrep_id => x_salesrep_id ,
                    x_end_date => x_end_date ,
                    x_commission_payed_ptd => x_commission_payed_ptd ,
                    x_last_update_date => x_last_update_date ,
                    x_last_updated_by => x_last_updated_by ,
                    x_last_update_login => x_last_update_login);
  ELSIF x_operation                           = 'LOCK' THEN
    -- Lock Record
    Lock_Record ( x_srp_period_quota_id => x_srp_period_quota_id ,x_period_id => x_period_id ,x_target_amount => x_target_amount);
  ELSIF X_Operation                     = 'DELETE' THEN
    -- Delete Record
    Delete_Record( x_srp_plan_assign_id => x_srp_plan_assign_id ,x_quota_id => x_quota_id ,x_start_period_id => NULL ,x_end_period_id => NULL ,x_start_date => NULL ,x_end_date => NULL );
  END IF;
END Begin_Record;
-- Name
--      Populate_srp_period_quotas_ext
-- Purpose
--   Populate cn_srp_period_quota_ext table
--   We take the following operations as parameters:
--       INSERT :  insert records in cn_srp_period_quotas_ext if necessary
--       DELETE :  delete all records in cn_srp_period_quotas_ext for certain srp_period_quota_id
PROCEDURE populate_srp_period_quotas_ext
  (
    x_operation           VARCHAR2,
    x_srp_period_quota_id NUMBER,
    x_org_id              NUMBER,
    x_number_dim          NUMBER)
                                 IS
  l_user_id    NUMBER(15);
  l_login_id   NUMBER(15);
  l_number_dim NUMBER(15);
  -- only use this if number_dim not used
  CURSOR DIM_NUMBER_CUR
  IS
     SELECT ccf.number_dim
       FROM cn_srp_period_quotas_all cspq,
      cn_quotas_all cq                   ,
      cn_calc_formulas_all ccf
      WHERE cspq.srp_period_quota_id = x_srp_period_quota_id
    AND cq.quota_id                  = cspq.quota_id
    AND cq.calc_formula_id           = ccf.calc_formula_id ;

  l_count NUMBER;
BEGIN
  l_user_id     := fnd_global.user_id;
  l_login_id    := fnd_global.login_id;
  IF x_operation = 'INSERT' THEN
    -- get number dim if necessary
    IF x_number_dim is NULL THEN
      l_number_dim := 0;
      OPEN dim_number_cur;
      FETCH dim_number_cur INTO l_number_dim;

      CLOSE dim_number_cur;
    ELSE
      l_number_dim := x_number_dim;
    END IF;
    FOR i_seq IN 2..l_number_dim
    LOOP
       INSERT
         INTO cn_srp_period_quotas_ext_all
        (
          srp_period_quota_ext_id,
          srp_period_quota_id    ,
          input_sequence         ,
          created_by             ,
          creation_date          ,
          last_update_login      ,
          last_update_date       ,
          last_updated_by        ,
          org_id
        )
       SELECT cn_srp_period_quotas_ext_s.nextval,
        x_srp_period_quota_id                   ,
        i_seq                                   ,
        l_user_id                               ,
        sysdate                                 ,
        l_login_id                              ,
        sysdate                                 ,
        l_user_id                               ,
        x_org_id
         FROM dual
        WHERE NOT EXISTS
        (SELECT 1
           FROM cn_srp_period_quotas_ext_all
          WHERE srp_period_quota_id = x_srp_period_quota_id
        AND input_sequence          = i_seq
        );
    END LOOP;
  ELSIF x_operation = 'DELETE' THEN
     DELETE
       FROM cn_srp_period_quotas_ext_all
      WHERE srp_period_quota_id = x_srp_period_quota_id;
  END IF;
END;
-- Name
--   select_summary
-- Purpose
--   Maintain running totals
---------------------------------------------------------------------------+
-- PROCEDURE SELECT_SUMMARY
---------------------------------------------------------------------------+
PROCEDURE select_summary
  (
    x_srp_quota_assign_id NUMBER ,
    x_total         IN OUT NOCOPY NUMBER ,
    x_total_rtot_db IN OUT NOCOPY NUMBER)
                    IS
BEGIN
   SELECT NVL(SUM(target_amount),0)
     INTO x_total
     FROM cn_srp_period_quotas_all
    WHERE srp_quota_assign_id = x_srp_quota_assign_id ;

  x_total_rtot_db := x_total;
EXCEPTION
WHEN no_data_found THEN
  NULL;
END select_summary;
-- Name
--   Period_target
-- Purpose
--   Distribute target/payment amount over periods
-- Notes
--
-- If period_type_code(a.k.a "Interval") = "PERIOD"
--   We do not need to divide up the quota target and distribute it
--   over the srp periods because the entire quota target is applied
--   to each srp period. No math required.
-- If the period_type_code = "QUARTER"
--   We need to apply the quota target to each quarter which means
--   dividing the target by the number of periods in the quarter and
--   assigning that amount to each period
--   e.g. Target = 100  Jan 33.3333
--    Feb 33.3333
--    Mar 33.3333
--   If a quarter has less than 3 periods the target amount
--   will be divided over the reduced number of periods.
--   e.g. Target = 100 Jan 33.3333
--    Feb 33.3333
--    Mar 33.3333
--    Apr 100
-- If the period_type_code = "YEAR"
--   The target will be divided by the number of periods in each year that
--   the quota is active. This deals with situations where the quota is
--   assigned for less than 12 periods in any year.
---------------------------------------------------------------------------+
-- PROCEDURE DISTRIBUTE_TARGET
---------------------------------------------------------------------------+
PROCEDURE Distribute_Target
  (
    x_srp_quota_assign_id     NUMBER ,
    x_target                  NUMBER ,
    x_period_target_unit_code VARCHAR2)
IS
  CURSOR period_quotas(l_interval_number NUMBER, l_period_year NUMBER)
  IS
     SELECT spq.srp_period_quota_id
       FROM cn_srp_period_quotas_v spq,
      cn_period_statuses cp           ,
      cn_cal_per_int_types_all cpit   ,
      cn_quotas_all cq
      WHERE spq.srp_quota_assign_id = x_srp_quota_assign_id
    AND spq.quota_id                = cq.quota_id
    AND spq.period_id               = cp.period_id
    AND cp.period_status           IN ('O', 'F')
    AND cq.org_id                   = cp.org_id
    AND cp.period_id                = cpit.cal_period_id
    AND cp.org_id                   = cpit.org_id
    AND cpit.interval_type_id       = cq.interval_type_id
    AND cpit.interval_number        = l_interval_number
    AND spq.period_year             = l_period_year
   ORDER BY spq.period_id ;

  pq_rec period_quotas%ROWTYPE;
  -- Get the period quotas that belong to the quota assignment for each
  -- interval
  CURSOR interval_counts
  IS
     SELECT COUNT(spq.srp_period_quota_id) interval_count,
      cpit.interval_number interval_number               ,
      spq.period_year period_year
       FROM cn_srp_period_quotas_v spq,
      cn_period_statuses cp           ,
      cn_cal_per_int_types_all cpit   ,
      cn_quotas_all cq
      WHERE spq.srp_quota_assign_id = x_srp_quota_assign_id
    AND spq.quota_id                = cq.quota_id
    AND spq.period_id               = cp.period_id
    AND cp.period_status           IN ('O', 'F')
    AND cq.org_id                   = cp.org_id
    AND cp.period_id                = cpit.cal_period_id
    AND cp.org_id                   = cpit.org_id
    AND cpit.interval_type_id       = cq.interval_type_id
   GROUP BY cpit.interval_number,
      spq.period_year ;

  interval_rec interval_counts%ROWTYPE;
  l_period_count             NUMBER;
  l_running_total_target     NUMBER;
  l_total_periods            NUMBER;
  l_period_target            NUMBER;
  l_running_total_payment    NUMBER;
  l_period_payment           NUMBER;
  l_running_performance_goal NUMBER;
  l_performance_goal         NUMBER;
  l_srp_quota_assign_id      NUMBER(15);
  l_quota_target             NUMBER;
  l_quota_payment            NUMBER;
  l_quota_performance_goal   NUMBER;
  l_dist_rule_code           VARCHAR2(30);
  l_period_type_code         VARCHAR2(30);
  l_period_performance_goal  NUMBER;
  g_ext_precision            NUMBER;
BEGIN
  -- get precision
   SELECT c.extended_precision
     INTO g_ext_precision
     FROM cn_repositories r,
    gl_sets_of_books b     ,
    fnd_currencies c       ,
    cn_srp_quota_assigns sqa
    WHERE r.org_id            = sqa.org_id
  AND r.set_of_books_id       = b.set_of_books_id
  AND b.currency_code         = c.currency_code
  AND sqa.srp_quota_assign_id = x_srp_quota_assign_id;
  -- Get quota assignment info for the quota to be distributed
  --
   SELECT NVL(qa.target,0)          ,
    NVL(qa.payment_amount, 0)       ,
    NVL(qa.performance_goal,0)      ,
    qa.period_target_dist_rule_code ,
    cn_chk_plan_element_pkg.get_interval_name(q.interval_type_id, q.org_id) period_type_code
     INTO l_quota_target ,
    l_quota_payment      ,
    l_performance_goal   ,
    l_dist_rule_code     ,
    l_period_type_code
     FROM cn_srp_quota_assigns_all qa,
    cn_quotas_all q
    WHERE qa.srp_quota_assign_id       = x_srp_quota_assign_id
  AND q.quota_id                       = qa.quota_id
  AND qa.period_target_dist_rule_code <> 'USER_DEFINED' ;
  -- Currently this is the only distribution rule we support
  IF l_dist_rule_code = 'EQUAL' THEN
    FOR interval_rec IN interval_counts
    LOOP
      -- Initialize for each interval
      l_period_count             := 0;
      l_running_total_target     := 0;
      l_period_target            := 0;
      l_running_total_payment    := 0;
      l_period_payment           := 0;
      l_running_performance_goal := 0;
      l_period_performance_goal  := 0;
      -- Now that we know the counts per quarter/year we can divide the
      -- quota target correctly for each quarter and set the period quota
      -- target.
      FOR pq_rec IN period_quotas ( l_interval_number => interval_rec.interval_number ,l_period_year => interval_rec.period_year)
      LOOP
        l_period_count             := l_period_count             +1;
        l_period_target            := ( ( l_quota_target         * (l_period_count / interval_rec.interval_count) ) - l_running_total_target );
        l_running_total_target     := l_running_total_target     + l_period_target;
        l_period_payment           := ( ( l_quota_payment        * (l_period_count / interval_rec.interval_count) ) - l_running_total_payment );
        l_running_total_payment    := l_running_total_payment    + l_period_payment;
        l_period_performance_goal  := ( ( l_performance_goal     * (l_period_count / interval_rec.interval_count) ) - l_running_performance_goal );
        l_running_performance_goal := l_running_performance_goal + l_period_performance_goal;
         UPDATE cn_srp_period_quotas_all
        SET target_amount           = ROUND(NVL(l_period_target, 0), g_ext_precision)         ,
          itd_target                = ROUND(NVL(l_running_total_target,0), g_ext_precision)   ,
          period_payment            = ROUND(NVL(l_period_payment,0), g_ext_precision)         ,
          itd_payment               = ROUND(NVL(l_running_total_payment,0), g_ext_precision)  ,
          performance_goal_ptd      = ROUND(NVL(l_period_performance_goal,0), g_ext_precision),
          performance_goal_itd      = ROUND(NVL(l_running_performance_goal,0),g_ext_precision)
          WHERE srp_period_quota_id = pq_rec.srp_period_quota_id ;
      END LOOP;
    END LOOP;
  END IF;
END distribute_target;
--
-- Purpose: synchronize the target / payment of srp_period_quotas table
--     with period_quotas table when customized_flag is changed to
--          'N' and itd_flag is 'Y'
--
---------------------------------------------------------------------------+
-- PROCEDURE SYNCH_TARGET
---------------------------------------------------------------------------+
PROCEDURE synch_target
  (
    x_srp_plan_assign_id NUMBER,
    x_quota_id           NUMBER)
IS
BEGIN
  cn_srp_period_quotas_pkg.delete_record ( x_srp_plan_assign_id => x_srp_plan_assign_id ,x_quota_id => x_quota_id ,x_start_period_id => NULL ,x_end_period_id => NULL);
  cn_srp_period_quotas_pkg.insert_record ( x_srp_plan_assign_id => x_srp_plan_assign_id ,x_quota_id => x_quota_id ,x_start_period_id => NULL ,x_end_period_id => NULL);
END synch_target;
END CN_SRP_PERIOD_QUOTAS_PKG;

/
