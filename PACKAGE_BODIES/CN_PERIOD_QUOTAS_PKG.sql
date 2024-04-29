--------------------------------------------------------
--  DDL for Package Body CN_PERIOD_QUOTAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PERIOD_QUOTAS_PKG" AS
/* $Header: cnprdqob.pls 120.3 2006/03/22 05:53:28 chanthon ship $ */

   /* ------------------------------------------------------------------------+
 |                            Public Routine Bodies                         |
  --------------------------------------------------------------------------*/
-- Name
--
-- Purpose
--
-- Notes Modified the Package due to changes in the Design
-- Modified Date 20-JUL-99 By Kumar Sivasankaran
-- Modified Date 14-Sep-04 By Jxsingh, Fixed Bug# 3848446
   g_precision                   NUMBER;
   g_ext_precision               NUMBER;
   g_min_acct_unit               NUMBER;

   PROCEDURE get_uid (
      x_period_quota_id          IN OUT NOCOPY NUMBER
   )
   IS
   BEGIN
      SELECT cn_period_quotas_s.NEXTVAL
        INTO x_period_quota_id
        FROM DUAL;
   END get_uid;

--| ---------------------------------------------------------------------+
--| Function Name :  previous_period
--| ---------------------------------------------------------------------+
   FUNCTION previous_period (
      p_start_date                        DATE,
      p_org_id NUMBER
   )
      RETURN cn_acc_period_statuses_v.start_date%TYPE
   IS
      l_previous_start_date         cn_acc_period_statuses_v.start_date%TYPE;
   BEGIN
      SELECT MAX (start_date)
        INTO l_previous_start_date
        FROM cn_acc_period_statuses_v
       WHERE TRUNC (start_date) <= TRUNC (p_start_date)
	   AND period_status IN ('F', 'O')
	   AND org_id = p_org_id;

      -- Begin fix of Bug 1942390 hlchen
      IF (l_previous_start_date IS NULL)
      THEN
         SELECT MIN (start_date)
           INTO l_previous_start_date
           FROM cn_acc_period_statuses_v
          WHERE period_status IN ('F', 'O')
		  AND org_id = p_org_id;
      END IF;

      -- End fix of Bug 1942390 hlchen
      RETURN l_previous_start_date;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END previous_period;

-- Name Begin Record
--
-- Purpose: Depending on the Operation the right procudure,
--    Insert_record, Delete_Records, Lock_Record or
--    Update_Record is called
--
-- Notes:   This is the table handler for the CN_Period_Quotas_Pkg
--
--
   PROCEDURE begin_record (
      x_operation                         VARCHAR2,
      x_period_quota_id          IN OUT NOCOPY NUMBER,
      x_period_id                         NUMBER,
      x_quota_id                          NUMBER,
      x_period_target                     NUMBER,
      x_itd_target                        NUMBER,
      x_period_payment                    NUMBER,
      x_itd_payment                       NUMBER,
      x_quarter_num                       NUMBER,
      x_period_year                       NUMBER,
      x_creation_date                     DATE,
      x_last_update_date                  DATE,
      x_last_update_login                 NUMBER,
      x_last_updated_by                   NUMBER,
      x_created_by                        NUMBER,
      x_period_type_code                  VARCHAR2,
      x_performance_goal                  NUMBER
   )
   IS
      l_org_id                      NUMBER;
      l_varchar                     VARCHAR2 (1000) := NULL;
      l_itd_perf_goal               NUMBER;
      l_itd_pmt_amount              NUMBER;
      l_itd_tgt                     NUMBER;
      l_object_version_number       NUMBER;
   BEGIN
      SELECT org_id
        INTO l_org_id
        FROM cn_quotas
       WHERE quota_id = x_quota_id;

      fnd_currency.get_info (cn_global_var.get_currency_code (p_org_id => l_org_id), g_precision, g_ext_precision, g_min_acct_unit);

      IF x_operation = 'INSERT'
      THEN
         INSERT_RECORD (x_period_quota_id        => x_period_quota_id,
                        p_period_id              => x_period_id,
                        p_quota_id               => x_quota_id,
                        p_period_target          => x_period_target,
                        p_itd_target             => x_itd_target,
                        p_period_payment         => x_period_payment,
                        p_itd_payment            => x_itd_payment,
                        p_quarter_num            => x_quarter_num,
                        p_period_year            => x_period_year,
                        p_creation_date          => x_creation_date,
                        p_last_update_date       => x_last_update_date,
                        p_last_update_login      => x_last_update_login,
                        p_last_updated_by        => x_last_updated_by,
                        p_created_by             => x_created_by,
                        p_period_type_code       => x_period_type_code,
                        p_performance_goal       => x_performance_goal
                       );
      ELSIF x_operation = 'UPDATE'
      THEN
         UPDATE_RECORD (x_period_quota_id,
                        x_quota_id,
                        x_period_id,
                        x_period_target,
                        x_period_payment,
                        x_performance_goal,
                        x_last_update_date,
                        x_last_update_login,
                        x_last_updated_by,
                        l_itd_tgt,
                        l_itd_pmt_amount,
                        l_itd_perf_goal,
                        l_object_version_number
                       );
      ELSIF x_operation = 'DELETE'
      THEN
         DELETE_RECORD (x_quota_id);
      END IF;
   END begin_record;

-- Name : Insert_record
--
-- Purpose : To insert the record with the different paras
--
-- Notes:  Insert_Record for CN_Period_Quotas
--
--
   PROCEDURE INSERT_RECORD (
      x_period_quota_id          IN OUT NOCOPY NUMBER,
      p_period_id                         NUMBER,
      p_quota_id                          NUMBER,
      p_period_target                     NUMBER,
      p_itd_target                        NUMBER,
      p_period_payment                    NUMBER,
      p_itd_payment                       NUMBER,
      p_quarter_num                       NUMBER,
      p_period_year                       NUMBER,
      p_creation_date                     DATE,
      p_last_update_date                  DATE,
      p_last_update_login                 NUMBER,
      p_last_updated_by                   NUMBER,
      p_created_by                        NUMBER,
      p_period_type_code                  VARCHAR2,
      p_performance_goal                  NUMBER
   )
   IS
      CURSOR l_period_quotas_cr
      IS
         SELECT                                                                                                         --cn_period_quotas_s.nextval,
                p_period_id c1,
                p_quota_id c2,
                p_period_target c3,
                0 c4,
                p_period_payment c5,
                p_performance_goal c6,
                0 c7,
                p.quarter_num c8,
                p.period_year c9,
                p_creation_date c10,
                p_last_update_date c11,
                p_last_update_login c12,
                p_last_updated_by c13,
                p_created_by c14,
                q.org_id  org_id
           FROM cn_acc_period_statuses_v p, cn_quotas q
          WHERE q.org_id = p.org_id
          AND   q.quota_id = p_quota_id
          AND   p.period_id = p_period_id
		  AND   NOT EXISTS (SELECT 'this period_quota already exists'
                            FROM cn_period_quotas pq
                            WHERE pq.period_id = p.period_id
							AND pq.quota_id    = q.quota_id
							AND pq.org_id      = q.org_id);

      l_period_quota                l_period_quotas_cr%ROWTYPE;
      l_pqs                         NUMBER;
   BEGIN
      IF p_quota_id IS NOT NULL
      THEN
         FOR l_period_quota IN l_period_quotas_cr
         LOOP
            SELECT cn_period_quotas_s.NEXTVAL
              INTO l_pqs
              FROM DUAL;

            INSERT INTO cn_period_quotas
                        (period_quota_id,
                         period_id,
                         quota_id,
                         period_target,
                         itd_target,
                         period_payment,
                         performance_goal,
                         itd_payment,
                         quarter_num,
                         period_year,
                         creation_date,
                         last_update_date,
                         last_update_login,
                         last_updated_by,
                         created_by,
                         org_id
                        )
               SELECT l_pqs,
                      l_period_quota.c1,
                      l_period_quota.c2,
                      l_period_quota.c3,
                      l_period_quota.c4,
                      l_period_quota.c5,
                      l_period_quota.c6,
                      l_period_quota.c7,
                      l_period_quota.c8,
                      l_period_quota.c9,
                      l_period_quota.c10,
                      l_period_quota.c11,
                      l_period_quota.c12,
                      l_period_quota.c13,
                      l_period_quota.c14,
                      l_period_quota.org_id
                 FROM DUAL;

                -- clku, call populate_itd_values to populate itd value
            -- of the newly inserted records
            populate_itd_values (l_pqs, l_period_quota.c2);
         END LOOP;
      END IF;
   END INSERT_RECORD;

   -- Name : Insert_record
   -- Purpose : To insert the records
   -- Notes:  Insert_Record for CN_Period_Quotas
   PROCEDURE INSERT_RECORD (
      x_quota_id                          NUMBER
   )
   IS
      l_user_id                     NUMBER (15);
      l_resp_id                     NUMBER (15);
      l_login_id                    NUMBER (15);

      --clku
      CURSOR l_period_quotas_cr
      IS
         SELECT p.period_id c1,
                q.quota_id c2,
                0 c3,
                0 c4,
                0 c5,
                0 c6,
                0 c7,
                p.quarter_num c8,
                p.period_year c9,
                SYSDATE c10,
                SYSDATE c11,
                l_login_id c12,
                l_user_id c13,
                l_user_id c14,
                q.org_id
           FROM cn_quotas q,
                cn_acc_period_statuses_v p
          WHERE q.quota_id = x_quota_id
            AND p.start_date >= previous_period (q.start_date, q.org_id)
            AND p.end_date <= cn_api.next_period (NVL (q.end_date, p.end_date), q.org_id)
            AND q.org_id = p.org_id
            AND NOT EXISTS (SELECT 'this period_quota already exists'
                              FROM cn_period_quotas pq
                             WHERE pq.period_id = p.period_id
							 AND pq.quota_id = q.quota_id
							 AND pq.org_id  = q.org_id)
            -- bug 2460926, check if all the open period ends before the specified start_date
            AND EXISTS (SELECT r1.end_date
                          FROM cn_acc_period_statuses_v r1
                         WHERE r1.end_date > q.start_date
						   AND r1.org_id = q.org_id);

      l_period_quota                l_period_quotas_cr%ROWTYPE;
      l_pqs                         NUMBER;

    l_min_date cn_acc_period_statuses_v.start_date%TYPE;
    l_insert_flag VARCHAR2(1);
    l_end_date DATE;
    l_org_id NUMBER;


   BEGIN
      l_user_id := fnd_global.user_id;
      l_resp_id := fnd_global.resp_id;
      l_login_id := fnd_global.login_id;
   l_insert_flag := 'Y';

   select end_date, org_id into l_end_date, l_org_id from
   cn_quotas_v where quota_id = x_quota_id;

   select min(start_date) into l_min_date from cn_acc_period_statuses_v
   where period_status IN ('F', 'O')  and org_id = l_org_id;


   IF (l_end_date IS NOT NULL AND trunc(l_end_date) < trunc(l_min_date)) THEN
    l_insert_flag := 'N';
   END IF;

   IF (x_quota_id IS NOT NULL AND l_insert_flag = 'Y') THEN

         FOR l_period_quota IN l_period_quotas_cr
         LOOP
            SELECT cn_period_quotas_s.NEXTVAL
              INTO l_pqs
              FROM DUAL;

            INSERT INTO cn_period_quotas
                        (period_quota_id,
                         period_id,
                         quota_id,
                         period_target,
                         itd_target,
                         period_payment,
                         performance_goal,
                         itd_payment,
                         quarter_num,
                         period_year,
                         creation_date,
                         last_update_date,
                         last_update_login,
                         last_updated_by,
                         created_by,
                         org_id)
               SELECT l_pqs,
                      l_period_quota.c1,
                      l_period_quota.c2,
                      l_period_quota.c3,
                      l_period_quota.c4,
                      l_period_quota.c5,
                      l_period_quota.c6,
                      l_period_quota.c7,
                      l_period_quota.c8,
                      l_period_quota.c9,
                      l_period_quota.c10,
                      l_period_quota.c11,
                      l_period_quota.c12,
                      l_period_quota.c13,
                      l_period_quota.c14,
                      l_period_quota.org_id
                 FROM DUAL;

            -- clku, call populate_itd_values to populate itd value
            -- of the newly inserted records
--            populate_itd_values (l_pqs, l_period_quota.c2);
         END LOOP;
      END IF;
     IF x_quota_id IS NOT NULL THEN
       sync_ITD_values(x_quota_id);
     END IF;

   END INSERT_RECORD;

--
-- Name:    Update Record
-- Notes:   Update record for the CN_Period_Quotas
   --,
   --x_itd_payment                       NUMBER,
   --x_quarter_num                       NUMBER,
   --x_period_year                       NUMBER,
   --x_period_type_code                  VARCHAR2,
   PROCEDURE UPDATE_RECORD (
      p_period_quota_id                   NUMBER,
      p_quota_id                          NUMBER,
      p_period_id                         NUMBER,
      p_period_target                     NUMBER,
      p_period_payment                    NUMBER,
      p_performance_goal                  NUMBER,
      p_last_update_date                  DATE,
      p_last_update_login                 NUMBER,
      p_last_updated_by                   NUMBER,
      x_itd_target             OUT NOCOPY     NUMBER,
      x_itd_payment_amount     OUT NOCOPY      NUMBER,
      x_itd_performance_amount OUT NOCOPY      NUMBER,
      x_object_version_number  OUT NOCOPY      NUMBER
   )
   IS
      -- Get the srp_quota_assign info based on this quota
      CURSOR srp_quota_assigns
      IS
         SELECT srp_plan_assign_id
           FROM cn_srp_quota_assigns
          WHERE quota_id = p_quota_id AND customized_flag = 'N';

      CURSOR period_quotas (
         l_interval_number                   NUMBER,
         l_period_year                       NUMBER
      )  IS
         SELECT   p.period_quota_id,
                  p.period_target,
                  p.period_payment,
                  p.performance_goal
             FROM cn_period_quotas p,
                  cn_acc_period_statuses_v cp,
                  cn_cal_per_int_types cpit,
                  cn_quotas cq
            WHERE p.quota_id = p_quota_id
              AND p.quota_id = cq.quota_id
              AND cq.org_id  = p.org_id
              AND p.period_id = cp.period_id
              AND cp.period_id = cpit.cal_period_id
              AND cpit.interval_type_id = cq.interval_type_id
              AND cpit.interval_number = l_interval_number
              AND p.period_year = l_period_year
              AND cq.org_id  = p.org_id
              AND cq.org_id  = cp.org_id
              AND cq.org_id  = cpit.org_id
         ORDER BY p.period_id;

      -- Get the period quotas that belong to the quota assignment for each interval
      CURSOR interval_counts
      IS SELECT   COUNT (p.period_quota_id) interval_count,
                  cpit.interval_number interval_number,
                  p.period_year period_year
             FROM cn_period_quotas p,
                  cn_acc_period_statuses_v cp,
                  cn_cal_per_int_types cpit,
                  cn_quotas cq
            WHERE p.quota_id = p_quota_id
              AND p.quota_id = cq.quota_id
              AND p.period_id = cp.period_id
              AND cp.period_id = cpit.cal_period_id
              AND cpit.interval_type_id = cq.interval_type_id
              AND cq.org_id = p.org_id
              AND cq.org_id = cp.org_id
              AND cq.org_id = cpit.org_id
         GROUP BY cpit.interval_number, p.period_year;

      sqa_rec                       srp_quota_assigns%ROWTYPE;
      pq_rec                        period_quotas%ROWTYPE;
      interval_rec                  interval_counts%ROWTYPE;
      l_target_total                NUMBER;
      l_payment_total               NUMBER;
      l_performance_goal_total      NUMBER;
      l_period_id                   NUMBER;
   BEGIN
      -- get the current ovn
      SELECT object_version_number
        INTO x_object_version_number
        FROM cn_period_quotas
       WHERE period_quota_id = p_period_quota_id
	   AND period_id = p_period_id AND quota_id = p_quota_id;

      x_object_version_number := NVL (x_object_version_number, 0) + 1;

      UPDATE cn_period_quotas
         SET period_target = p_period_target,
             quota_id = p_quota_id,
             period_id = p_period_id,
             period_payment = p_period_payment,
             performance_goal = p_performance_goal,
             last_update_date = p_last_update_date,
             last_update_login = p_last_update_login,
             last_updated_by = p_last_updated_by,
             object_version_number = x_object_version_number
       WHERE period_quota_id = p_period_quota_id;

      --UPDATE INTERVAL_TO_DATE COLUMNS
      FOR interval_rec IN interval_counts
      LOOP
         -- Initialize for each interval
         l_target_total := 0;
         l_payment_total := 0;
         l_performance_goal_total := 0;

         -- Now that we know the counts per quarter/year we can divide the
         -- quota target correctly for each quarter and set the period quota target.
         FOR pq_rec IN period_quotas (l_interval_number => interval_rec.interval_number, l_period_year => interval_rec.period_year)
         LOOP
            l_target_total := l_target_total + pq_rec.period_target;
            l_payment_total := l_payment_total + pq_rec.period_payment;
            l_performance_goal_total := l_performance_goal_total + pq_rec.performance_goal;
            -- null precision bad for business
            g_ext_precision := NVL (g_ext_precision, 10);
            l_target_total := ROUND (NVL (l_target_total, 0), g_ext_precision);
            l_payment_total := ROUND (NVL (l_payment_total, 0), g_ext_precision);
            l_performance_goal_total := ROUND (NVL (l_performance_goal_total, 0), g_ext_precision);

            UPDATE cn_period_quotas
               SET itd_target = l_target_total,
                   itd_payment = l_payment_total,
                   performance_goal_itd = l_performance_goal_total
             WHERE period_quota_id = pq_rec.period_quota_id;

            IF pq_rec.period_quota_id = p_period_quota_id
            THEN
               x_itd_target := l_target_total;
               x_itd_payment_amount := l_payment_total;
               x_itd_performance_amount := l_performance_goal_total;
            END IF;
         END LOOP;
      END LOOP;

      -- End - Bug# 3848446, Fixed by Jagpreet Singh
      FOR sqa_rec IN srp_quota_assigns
      LOOP                                                                                                    -- Bug# 3848446, Fixed by Jagpreet Singh
         cn_srp_period_quotas_pkg.DELETE_RECORD (x_srp_plan_assign_id      => sqa_rec.srp_plan_assign_id,
                                                 x_quota_id                => p_quota_id,
                                                 x_start_period_id         => p_period_id,
                                                 x_end_period_id           => NULL
                                                );
         -- Bug# 3848446, Fixed by Jagpreet Singh
         cn_srp_period_quotas_pkg.INSERT_RECORD (x_srp_plan_assign_id      => sqa_rec.srp_plan_assign_id,
                                                 x_quota_id                => p_quota_id,
                                                 x_start_period_id         => p_period_id,
                                                 x_end_period_id           => NULL,
                                                 x_start_date              => NULL,
                                                 x_end_date                => NULL
                                                );
      END LOOP;
   END UPDATE_RECORD;

-- Name
--
-- Purpose
--
-- Notes
--
--
   PROCEDURE DELETE_RECORD (x_quota_id  NUMBER)
   IS
      period_quotas_count           NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO period_quotas_count
        FROM cn_period_quotas pq
       WHERE pq.quota_id = x_quota_id;

      IF period_quotas_count > 0
      THEN
         DELETE FROM cn_period_quotas
         WHERE quota_id = x_quota_id;
      END IF;
   END DELETE_RECORD;

-- Name
--   Distribute_Target
-- Purpose
--   Distribute target/payment amount over periods
-- Notes
   PROCEDURE distribute_target (
      x_quota_id                          NUMBER
   )
   IS

  l_start_date DATE;
  l_end_date DATE;
  l_start_period_id NUMBER;
  l_end_period_id NUMBER;
  l_max_date cn_acc_period_statuses_v.end_date%TYPE;
  l_min_date cn_acc_period_statuses_v.start_date%TYPE;
  l_delete_all_flag CHAR(1);
  l_org_id cn_quotas.org_id%TYPE;
   BEGIN
   -- get start date, end date for the pe
   l_delete_all_flag := 'N';
   select start_date, end_date, org_id
   into l_start_date, l_end_date, l_org_id from
   cn_quotas_v where quota_id = x_quota_id;
   -- max date of open or future entry periods
   select max(end_date) into l_max_date from cn_acc_period_statuses_v
   where period_status IN ('F', 'O') and org_id = l_org_id;
   -- min date of open or future entry periods
   select min(start_date) into l_min_date from cn_acc_period_statuses_v
   where period_status IN ('F', 'O') and org_id = l_org_id;


   IF (trunc(l_start_date) < trunc(l_min_date)) THEN
     select min(period_id) into l_start_period_id
     from cn_acc_period_statuses_v
     where period_status IN ('F', 'O')  and org_id = l_org_id;
   ELSIF (trunc(l_start_date) > trunc(l_max_date)) THEN
--     select max(period_id) into l_start_period_id
--     from cn_acc_period_statuses_v
--     where period_status IN ('F', 'O');
-- delete all records
       l_delete_all_flag := 'Y';
   ELSE
     SELECT period_id
     INTO l_start_period_id
     FROM cn_acc_period_statuses_v
     WHERE l_start_date BETWEEN start_date and end_date
     AND  period_status IN ('F', 'O')  and org_id = l_org_id;
   END IF;

   IF (l_end_date IS NOT NULL) THEN
     IF (trunc(l_end_date) < trunc(l_min_date)) THEN
--       select min(period_id) into l_end_period_id
--       from cn_acc_period_statuses_v
--       where period_status IN ('F', 'O');
-- delete all records
       l_delete_all_flag := 'Y';
     ELSIF (trunc(l_end_date) > trunc(l_max_date)) THEN
       select max(period_id) into l_end_period_id
       from cn_acc_period_statuses_v
       where period_status IN ('F', 'O')  and org_id = l_org_id;
     ELSE
       SELECT period_id
       INTO l_end_period_id
       FROM cn_acc_period_statuses_v
       WHERE l_end_date BETWEEN start_date and end_date
       AND  period_status IN ('F', 'O')  and org_id = l_org_id;
     END IF;
   END IF;
--   l_start_period_id := cn_api.get_acc_period_id(l_start_date);
--   IF (l_end_date IS NOT NULL) THEN
--      l_end_period_id := cn_api.get_acc_period_id(l_end_date);
--   END IF;
   IF (l_delete_all_flag = 'Y') THEN
     DELETE_RECORD(x_quota_id);
   ELSIF (l_end_date IS NOT NULL) THEN
     delete from cn_period_quotas where quota_id = x_quota_id
     and (period_id < l_start_period_id OR period_id > l_end_period_id);
   ELSE
     delete from cn_period_quotas where quota_id = x_quota_id
     and period_id < l_start_period_id;
   END IF;


      INSERT_RECORD (x_quota_id);
   END distribute_target;

-- Name
--
-- Purpose
-- populate itd values for newly inserted period_quotas
--
-- Notes
-- This method is called whenever a new period quotaa is inserted
   PROCEDURE populate_itd_values (
      x_start_period_quota_id             NUMBER,
      x_quota_id                          NUMBER
   )
   IS
      l_previous_period_id          NUMBER := 0;
      l_end_period_id               NUMBER := 0;
      l_interval_type_id            NUMBER := 0;
      l_start_period_id             NUMBER := 0;
      l_itd_target                  NUMBER := 0;
      l_itd_payment                 NUMBER := 0;
      l_performance_goal_itd        NUMBER := 0;
	  l_org_id                      NUMBER := 0;

      CURSOR max_prev_period_csr (
         p_interval_type_id                  NUMBER,
         p_start_period_id                   NUMBER,
         p_org_id                            NUMBER
      )
      IS
         SELECT MAX (cal_period_id) max_cal_period_id
           FROM cn_cal_per_int_types
          WHERE interval_type_id = p_interval_type_id
            AND cal_period_id < p_start_period_id
            AND org_id = p_org_id
            AND interval_number = (SELECT interval_number
                                   FROM cn_cal_per_int_types q
                                   WHERE q.cal_period_id = p_start_period_id
								   AND q.interval_type_id = p_interval_type_id
								   AND q.org_id = p_org_id);

      CURSOR max_period_csr (
         p_interval_type_id                  NUMBER,
         p_start_period_id                   NUMBER,
         p_org_id                            NUMBER)
      IS
         SELECT cal_period_id
           FROM cn_cal_per_int_types
          WHERE interval_type_id = p_interval_type_id
            AND cal_period_id >= p_start_period_id
            AND org_id         = p_org_id
            AND interval_number = (SELECT interval_number
                                     FROM cn_cal_per_int_types
                                    WHERE cal_period_id = p_start_period_id
									AND interval_type_id = p_interval_type_id
									AND org_id           = p_org_id);
   BEGIN
      SELECT period_id
        INTO l_start_period_id
        FROM cn_period_quotas
       WHERE quota_id = x_quota_id
	   AND period_quota_id = x_start_period_quota_id;

      SELECT interval_type_id, org_id
        INTO l_interval_type_id, l_org_id
        FROM cn_quotas
       WHERE quota_id = x_quota_id;

      OPEN max_prev_period_csr (l_interval_type_id, l_start_period_id, l_org_id);

      FETCH max_prev_period_csr
       INTO l_previous_period_id;

      IF max_prev_period_csr%NOTFOUND
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE max_prev_period_csr;

      IF l_previous_period_id > 0
      THEN
         SELECT NVL (pq.itd_target, 0),
                NVL (pq.itd_payment, 0),
                NVL (pq.performance_goal_itd, 0)
           INTO l_itd_target,
                l_itd_payment,
                l_performance_goal_itd
           FROM cn_period_quotas pq
          WHERE quota_id = x_quota_id AND period_id = l_previous_period_id;

         FOR i_period_id IN max_period_csr (l_interval_type_id, l_start_period_id, l_org_id)
         LOOP
            UPDATE cn_period_quotas
               SET itd_target = l_itd_target,
                   itd_payment = l_itd_payment,
                   performance_goal_itd = l_performance_goal_itd
             WHERE quota_id = x_quota_id AND period_id = i_period_id.cal_period_id;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
      WHEN OTHERS
      THEN
         NULL;
   END populate_itd_values;

--clku, helper procedure for synchrozing ITD values of cn_period_quotas table
-- called whenever there is change of interval type of PE
   PROCEDURE sync_itd_values (
      x_quota_id                          NUMBER
   )
   IS
      CURSOR period_quotas (
         l_interval_number                   NUMBER,
         l_period_year                       NUMBER)
      IS
         SELECT   p.period_quota_id,
                  p.period_target,
                  p.period_payment,
                  p.performance_goal
             FROM cn_period_quotas p,
                  cn_acc_period_statuses_v cp,
                  cn_cal_per_int_types cpit,
                  cn_quotas cq
            WHERE p.quota_id = x_quota_id
              AND p.quota_id = cq.quota_id
              AND p.period_id = cp.period_id
              AND cp.period_id = cpit.cal_period_id
              AND cpit.interval_type_id = cq.interval_type_id
              AND cpit.interval_number = l_interval_number
              AND p.period_year = l_period_year
              AND cq.org_id = p.org_id
              AND cq.org_id   = cp.org_id
              AND cq.org_id   = cpit.org_id
         ORDER BY p.period_id;

      pq_rec                        period_quotas%ROWTYPE;

      -- Get the period quotas that belong to the quota assignment for each
      -- interval
      CURSOR interval_counts
      IS
         SELECT   COUNT (p.period_quota_id) interval_count,
                  cpit.interval_number interval_number,
                  p.period_year period_year
             FROM cn_period_quotas p,
                  cn_acc_period_statuses_v cp,
                  cn_cal_per_int_types cpit,
                  cn_quotas cq
            WHERE p.quota_id = x_quota_id
              AND p.quota_id = cq.quota_id
              AND p.period_id = cp.period_id
              AND cp.period_id = cpit.cal_period_id
              AND cpit.interval_type_id = cq.interval_type_id
              AND cq.org_id   = p.org_id
              AND cq.org_id   = cp.org_id
              AND cq.org_id   = cpit.org_id
         GROUP BY cpit.interval_number, p.period_year;

      interval_rec                  interval_counts%ROWTYPE;
      l_target_total                NUMBER;
      l_payment_total               NUMBER;
      l_performance_goal_total      NUMBER;
   BEGIN
      FOR interval_rec IN interval_counts
      LOOP
         -- Initialize for each interval
         l_target_total := 0;
         l_payment_total := 0;
         l_performance_goal_total := 0;

         -- Now that we know the counts per quarter/year we can divide the
         -- quota target correctly for each quarter and set the period quota
         -- target.
         FOR pq_rec IN period_quotas (l_interval_number => interval_rec.interval_number, l_period_year => interval_rec.period_year)
         LOOP
            l_target_total := l_target_total + pq_rec.period_target;
            l_payment_total := l_payment_total + pq_rec.period_payment;
            l_performance_goal_total := l_performance_goal_total + pq_rec.performance_goal;

            UPDATE cn_period_quotas
               SET itd_target = NVL (l_target_total, 0),
                   itd_payment = NVL (l_payment_total, 0),
                   performance_goal_itd = NVL (l_performance_goal_total, 0)
             WHERE period_quota_id = pq_rec.period_quota_id;
         END LOOP;
      END LOOP;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END sync_itd_values;
END cn_period_quotas_pkg;

/
